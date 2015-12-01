# remote routines

Set-StrictMode -Version Latest

function Get-PSCredentialByPassword($username, $password){
    $crypted_pass = ConvertTo-SecureString -AsPlainText $password -Force
    return New-Object System.Management.Automation.PSCredential -ArgumentList $username,$crypted_pass
}


function Get-PSSessionByPassword($computer_name, $username, $password){
    # Timeout is set to 15 min
    $cred = Get-PSCredentialByPassword $username $password
    $pso = New-PSSessionOption -IdleTimeout 90000 -MaximumRedirection 3
    $psSess = New-PSSession -ComputerName $computer_name -credential $cred -SessionOption $pso
    return $psSess

}


function Send-File {
    param(
        ## The path on the local computer
        [Parameter(Mandatory = $true)]
        $Source,

        ## The target path on the remote computer
        [Parameter(Mandatory = $true)]
        $Destination,

        ## The session that represents the remote computer
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Runspaces.PSSession] $Session
    )


    Set-StrictMode -Version Latest

    ## Get the source file, and then get its content
    $sourcePath = (Resolve-Path $source).Path
    $sourceBytes = [IO.File]::ReadAllBytes($sourcePath)
    $streamChunks = @()

    ## Now break it into chunks to stream
    Write-Progress -Activity "Sending $Source" -Status "Preparing file"
    $streamSize = 1MB
    for($position = 0; $position -lt $sourceBytes.Length;
        $position += $streamSize)
    {
        $remaining = $sourceBytes.Length - $position
        $remaining = [Math]::Min($remaining, $streamSize)

        $nextChunk = New-Object byte[] $remaining
        [Array]::Copy($sourcebytes, $position, $nextChunk, 0, $remaining)
        $streamChunks += ,$nextChunk
    }

    $remoteScript = {
        param($destination, $length)

        ## Convert the destination path to a full filesytem path (to support
        ## relative paths)
        $Destination = $executionContext.SessionState.`
            Path.GetUnresolvedProviderPathFromPSPath($Destination)

        ## Create a new array to hold the file content
        $destBytes = New-Object byte[] $length
        $position = 0

        ## Go through the input, and fill in the new array of file content
        foreach($chunk in $input)
        {
            Write-Progress -Activity "Writing $Destination" `
                -Status "Sending file" `
                -PercentComplete ($position / $length * 100)

            [GC]::Collect()
            [Array]::Copy($chunk, 0, $destBytes, $position, $chunk.Length)
            $position += $chunk.Length
        }

        ## Write the content to the new file
        [IO.File]::WriteAllBytes($destination, $destBytes)

        ## Show the result
        #Get-Item $destination
        [GC]::Collect()
    }

    ## Stream the chunks into the remote script
    $streamChunks | Invoke-Command -Session $session $remoteScript `
        -ArgumentList $destination,$sourceBytes.Length
}




function Send-Function(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Runspaces.PSSession] $session,

        [Parameter(Mandatory = $true)]
        $func_name
    ){

    $f_content = Invoke-Expression "`${function:$func_name}"
    $f_def = "function $func_name { $f_content }"

    Invoke-Command -Session $session -ScriptBlock {
        Param($f_def)
        . ([ScriptBlock]::Create($f_def))

    } -ArgumentList $f_def

}


function Send-Directory(
        ## The path on the local computer
        [Parameter(Mandatory = $true)]
        $Source,

        ## The target path on the remote computer
        [Parameter(Mandatory = $true)]
        $Destination,

        ## The session that represents the remote computer
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Runspaces.PSSession] $Session,

        [bool]$delete_existing = $false
    ){


    if(!(Get-Item "$Source").PSIsContainer){
        Write-Error "Send-Directory called on a non-directory, use Send-File instead"
        exit
    }

    if($delete_existing){
        Invoke-Command -Session $Session { Param($Path)
            remove-item -recurse $Path >$null
        } -ArgumentList $Destination
    }


    $location = pwd
    Set-Location $Source

    ls -Path "$Source" -recurse -Force -name | foreach {
        $item = get-item "$Source\$_"
        $dest_path = "$Destination\$_"

        if($item.PSIsContainer){
            Invoke-Command -Session $Session { Param($Path)
                mkdir -Path $path -Force >$null
            } -ArgumentList $dest_path

        } else {
            # create parent directory
            Invoke-Command -Session $Session { Param($Path)
                mkdir -Path $path -Force >$null
            } -ArgumentList (Split-Path $dest_path)

            Send-File $item $dest_path $Session
        }

    }
    
    Set-Location $location
}


Export-ModuleMember -Function *
