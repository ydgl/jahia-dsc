
Set-StrictMode -Version Latest


<#
.Synopsis
  Wait for a command to success

.Description
  Will wait for a command to success,
  we can put a limit, a behavious in case of limit passed
  The script return true in case of sucess and false in case of passed limit

.Parameter ScriptBlock
  Block of script executed,
  the return will be used to know if the command success

.Parameter ArgumentList
  Arguments to give to the script block

.Parameter WaitSeconds
  Number of seconds between each atempts
  default is 10

.Parameter Printing
  Print each time we have to wait
  Put "" to have to printing

.Parameter Limit
  Number of time the wait will be allowed
  -1 means no limit

.Parameter LimitPassedBlock
  Action to do if the limit is passed
  By default write to Host and return false

.Example
  Wait-For {
    Test-Server-Start
  }

#>
function Wait-For (
    [Parameter(Mandatory)][Scriptblock]
    $ScriptBlock,
    [Object[]]$ArgumentList = @(),
    [int]$WaitSeconds = 10,
    [string]$Printing = "Wait-For not ready, waiting {0} seconds ...",
    [int]$Limit = -1,
    [Scriptblock]$LimitPassedBlock = {
            Write-Host "Waiting limit passed, return false"
        }
    ){

    while(!$(invoke-command -scriptblock $ScriptBlock -args $ArgumentList)){
        if($Limit -eq 0){
            invoke-command -scriptblock $LimitPassedBlock
            return
        }

        Write-Host ($Printing -f $WaitSeconds)
            sleep -Seconds $WaitSeconds
        $Limit -= 1
    }

    return
}



<#
.Synopsis
  Remove old files

.Description
  Walk through a directory contents
  Remove file older than nb_day, and remove empty directories
  Leave the other files as it

.Parameter path
  The directory where to find old files

.Parameter nb_day
  Number of day to compare the createdtime file with

#>
function Remove-OlderThan(
    $path,
    $nb_day
    ){
    # From a path, remove every file older than X Days
    # if it find empty directory, remove it (to clean empty stuff)

    $limit = (Get-Date).AddDays(-15)

    # Delete files older than the $limit.
    Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force

    # Delete any empty directories left behind after deleting the old files.
    Get-ChildItem -Path $path -Recurse -Force | Where-Object {
         $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null 
    } | Remove-Item -Force -Recurse

}

<#
.Synopsis
  Test if a command is present

#>
function Test-Command($name){
    Get-Command $name -ErrorAction SilentlyContinue
}

<#
.Synopsis
  Exit a script with a warning
#>

function Exit-Error($msg){
    Write-Error $msg
    exit 1
}


function Assert-OrThrow($cdt, $msg){
    if($cdt){ return }
    throw $msg
}


function Find-FirstExistingPath([string[]]$pathArray){
    $pathArray | ?{ Test-Path $_ } | Select-Object -First 1
}


<#
.Synopsis
   Shortcuts to a longer function
#>
function Set-Env(
    $name, $value, 
    [ValidateSet("Machine", "User")]
    $Scope = "Machine"){
    [Environment]::SetEnvironmentVariable($name, $value, $Scope)
}


function Format-Sha1($str){
    $enc = [system.Text.Encoding]::UTF8
    $data1 = $enc.GetBytes($str) 

    # Create a New SHA1 Crypto Provider 
    $sha = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider 

    # Now hash and display results 
    $result1 = $sha.ComputeHash($data1)
    return [System.Convert]::ToBase64String($result1)
}


$Global:_Trace_log_file = $null

function Trace-Log(){
    Param(
        [string] $str
    )

    if($Global:_Trace_log_file -eq $null){
        $dir_path = "$PSScriptRoot\..\logs"
        New-Item -Type Directory $dir_path -Force > $null

        $timestamp = get-date -Format "yyyy_MM_dd.HH_mm_ss"
        $file_path = '{0}\{1}.log' -f $dir_path, $timestamp
        $Global:_Trace_log_file = $file_path
    }

    Write-Host "$str" >> $Global:_Trace_log_file
    #Write-Host "$str"
}


function Test-Administrator{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}


function ZipFiles( $zipfilename, $sourcedir ){
   Add-Type -Assembly System.IO.Compression.FileSystem
   $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
   [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
        $zipfilename, $compressionLevel, $false)
}

function Expand-ZIPFile($zipfile, $destination){
    [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
    $entries = [IO.Compression.ZipFile]::OpenRead($zipfile).Entries
    foreach($entry in $entries){
        $file   = Join-Path $destination $entry.FullName
        $parent = Split-Path -Parent $file
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -Path $parent -Type Directory | Out-Null
        }

        if($entry.FullName -like "*/"){
            continue
        }

        [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $file, $true)

    }
}

<#
function WaitForPatternInFile($fileToScan, $pattern, $maxWaitInSec) {
    $content = Get-ChildItem $fileToScan | Get-Content

    while() {
        if ($content -contains $pattern) {
            return $true
        } else {
        }
    }
}

$StartDate=(GET-DATE)

$EndDate=[datetime]”01/01/2014 00:00”

NEW-TIMESPAN –Start $StartDate –End $EndDate
#>


function Write-AsUTF8WBOM($file_output, $content){
    # we got to have a UTF-8 w/o BOM encoding, because WTF !!!
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
    [System.IO.File]::WriteAllLines($file_output, $content, $Utf8NoBomEncoding)
    #Get-Content $content | Out-File -Encoding utf8 -FilePath $file_output
}


<#
.Synopsis
  Replace occurence of '#$stringToReplace#' (sharp,string,sharp) by '$newValue'
  Force encoding to UTF-8 w/o BOM

#>
function Expand-SharpedString($file_input, $file_output, $stringreplace, $newValue){

    $content = cat -Encoding UTF8 $file_input

    $content = $content -replace "#$stringreplace#", $newValue

    Write-AsUTF8WBOM $file_output $content

}

function Test-FileContains($file, $pattern) {
    $theFile = Get-Content $file
    $containsWord = $theFile | %{$_ -match $pattern}
    return ($containsWord -contains $true)
}

# New FileConf function ______________________________________________________

$script:fileConfSidePath = $null
$script:fileConfCurrentFile = $null
$script:fileConfCurrentFileType = $null
$script:fileConfCurrentEncoding = $null
$script:fileConfCurrentContentXml = $null
$script:fileConfCurrentContentTxt = $null
$script:fileConfOldFileSuffix = "-old"
$script:fileConfSideReplaceScript = "replace.bat"
$script:fileConfVerbose = $false

function Start-FileConf($filePath) {
    if ($filePath -ne $null) {
        if (Test-Path $filePath) {
            $script:fileConfSidePath = $filePath
            Remove-Item -Recurse -Force -ErrorAction:SilentlyContinue "$script:fileConfSidePath\*"
            "REM Fichier de remplacement des fichiers de configuration" | Out-File -Encoding Default -FilePath $script:fileConfSidePath\$script:fileConfSideReplaceScript
            Write-Host "Création du fichier $script:fileConfSidePath\$script:fileConfSideReplaceScript"
        } 
    }
}

function Stop-FileConf($filePath) {
    "pause" | Out-File -Encoding Default -Append -FilePath $script:fileConfSidePath\$script:fileConfSideReplaceScript
}

function Test-FileConf() {
    Write-Host "gg :  $script:fileConfSidePath "
}

function Edit-FileConf($filePath, $encoding, $fileType) {
    $retValue = $false

    $script:fileConfCurrentFileType = $null
    $script:fileConfCurrentFile = $null
    $script:fileConfCurrentEncoding = $null

    if (Test-Path $filePath) {
        $script:fileConfCurrentFileType = $fileType
        $script:fileConfCurrentFile = $filePath
        $script:fileConfCurrentEncoding = $encoding

        switch ($script:fileConfCurrentFileType) {
            "XML" {
                [xml] $script:fileConfCurrentContentXml = Get-Content $script:fileConfCurrentFile
            }
            default { #inclus PROPERTIES
                $script:fileConfCurrentContentTxt = cat -Encoding $script:fileConfCurrentEncoding $script:fileConfCurrentFile
            }
        }

        Write-Host "Début : $script:fileConfCurrentFile en $script:fileConfCurrentEncoding (Default veut dire Ansi/ASCII)"
        $retValue = $true
    } else {
        Write-Host "Fichier Inconnnu : $filePath" -f Red
    }
    return $retValue
}

function Expand-FileConf($stringreplace, $newValue){
    switch ($script:fileConfCurrentFileType) {
        "XML" {
            $newString = $script:fileConfCurrentContentXml.OuterXml
            $script:fileConfCurrentContentXml = [xml] ($newString -replace "#$stringreplace#", $newValue)
        }
        "PROPERTIES" {
            $script:fileConfCurrentContentTxt = $script:fileConfCurrentContentTxt -replace "#$stringreplace#", $newValue
        }
    }
}


function Save-FileConf($filePath) {
    $inputFilePath = $filePath
    $fileName = Split-Path -Path "$filePath" -leaf
    $fileDir = Split-Path -Path "$filePath" 

    $identicalFile = $false
    if (Test-Path $filePath) {
        switch ($script:fileConfCurrentFileType) {
            "XML" {
                [xml] $tmpXml = Get-Content $filePath
                $identicalFile = $script:fileConfCurrentContentXml.Equals($tmpXml)
            }
            default { #inclus PROPERTIES
                $tmpString = cat -Encoding $script:fileConfCurrentEncoding $filePath
                $identicalFile = ( "$script:fileConfCurrentContentTxt" -eq "$tmpString" )
            }
        }
    }
    #Write-Host "$filePath identique = $identicalFile"

    if ($identicalFile) {
        if ($script:fileConfSidePath -ne $null) {
            "REM $filePath Inchangé" | Out-File  -Encoding Default -Append -FilePath $script:fileConfSidePath\$script:fileConfSideReplaceScript
        } else {
            Write-Host "$filePath Inchangé" 
        }
    } else {
        if ($script:fileConfSidePath -ne $null) {
            $filePath = "$script:fileConfSidePath\$fileName"
            if (Test-Path $filePath) {
                if (Test-Path "$filePath-2") {
                    Write-Host "Là je gère pas !!!"
                    exit
                }
                $filePath = "$filePath-2"
            }
            Copy-Item -Force -ErrorAction:SilentlyContinue "$inputFilePath" "$filePath$script:fileConfOldFileSuffix"
            "copy $filePath $inputFilePath" | Out-File  -Encoding Default -Append -FilePath $script:fileConfSidePath\$script:fileConfSideReplaceScript
        }

        switch ($script:fileConfCurrentFileType) {
            "XML" {
                $script:fileConfCurrentContentXml.save($filePath)
            }
            default { #inclus PROPERTIES
                $script:fileConfCurrentContentTxt | Out-File -Encoding $script:fileConfCurrentEncoding -FilePath $filePath
            }
        }
    }
    

    Write-Host "Fin   : " -NoNewline
    Write-Host "$filePath" -NoNewLine -f Green 
    if ($identicalFile) {
        Write-Host ""
    } else {
        Write-Host " (modification) " -f Red 
    }

    $script:fileConfCurrentFile = $null
    $script:fileConfCurrentEncoding = $null
    $script:fileConfCurrentContentXml = $null
    $script:fileConfCurrentContentTxt = $null
    $script:fileConfCurrentFileType = $null
}


function Update-FileConf($varName, $newValue) {
    switch ($script:fileConfCurrentFileType) {
        "XML" {
            $nodes = $script:fileConfCurrentContentXml.SelectNodes($varName)
         
            foreach ($node in $nodes) {
                if ($node -ne $null) {
                    if ($node.NodeType -eq "Element") {
                        $node.InnerXml = $newValue
                    }
                    else {
                        $node.Value = $newValue
                    }
                }
            }
        }
        "PROPERTIES" {
            $script:fileConfCurrentContentTxt = $script:fileConfCurrentContentTxt -replace "^$varName.*=.*$", "$varName = $newValue"
            $script:fileConfCurrentContentTxt = $script:fileConfCurrentContentTxt -replace "^#$varName.*=.*$", "$varName = $newValue"
        }
    }
}

function New-FileConf($varName, $newValue, $afterName) {
    switch ($script:fileConfCurrentFileType) {
        "XML" {
            $nodes = $script:fileConfCurrentContentXml.SelectNodes($afterName)


            $newAttr = $script:fileConfCurrentContentXml.CreateAttribute($varName);
            $newAttr.Value = "$newValue";
        
         
            foreach ($node in $nodes) {
                if ($node -ne $null) {
                    $node.Attributes.append($newAttr) > $null
                }
            }
        }
        "PROPERTIES" {
            Write-Host "TODO New-FileConf for text file"
        }
    }
}

<#
.Synopsis
  Copy (Replace) file or directory to destination

.Description
  Replace destination by src (filePathSrc --> filePathDst)

.Parameter filePathSrc
  Block of script executed,
  the return will be used to know if the command success

.Parameter filePathDst
  Arguments to give to the script block

.Example
  Copy-FileConf directory-a directory-b
    replace directory-b with directory-a

.Example
  Copy-FileConf file-a file-b
    replace file-b with file-a

#>
function Copy-FileConf($filePathSrc, $filePathDst) {
    $inputFilePathDst = $filePathDst
    # ce n'est pas une erreur (le nom du repertoire destination est dans la source, pensez à "copy c:\Windows C:\Users")
    $itemDst = Split-Path -Path "$filePathSrc" -leaf


    $validDst = Split-Path -Path "$filePathDst"

    $tmpSrc = @((gci -Recurse $filePathSrc) | Where-Object { $_.GetType().FullName -eq "System.IO.FileInfo" })
    $tmpDst = @((gci -Recurse $filePathDst) | Where-Object { $_.GetType().FullName -eq "System.IO.FileInfo" })


    $changesFound = (Compare-FileConf $tmpSrc $tmpDst)
    
    if ($script:fileConfSidePath -ne $null) {
        $filePathDst = "$script:fileConfSidePath\$itemDst"
        if ($changesFound) {
            Copy-Item -Recurse -ErrorAction Ignore $inputFilePathDst$itemDst "$filePathDst$script:fileConfOldFileSuffix"
            if (Test-Path $inputFilePathDst$itemDst -PathType Container) {
                "xcopy /Y /I /E $filePathDst $inputFilePathDst$itemDst" | Out-File  -Encoding Default -Append -FilePath $script:fileConfSidePath\$script:fileConfSideReplaceScript
            } else {
                "xcopy /Y /I /E $filePathDst $inputFilePathDst" | Out-File  -Encoding Default -Append -FilePath $script:fileConfSidePath\$script:fileConfSideReplaceScript
            }
        } else {
            "REM $filePathSrc Inchangé" | Out-File  -Encoding Default -Append -FilePath $script:fileConfSidePath\$script:fileConfSideReplaceScript
        }
    }

    if ($changesFound) {
        Copy-Item -Recurse -ErrorAction Ignore $filePathSrc $filePathDst
        Write-Host "CopyDir: $filePathSrc --> " -NoNewline
        Write-Host "$filePathDst" -f Green -NoNewline
        Write-Host " (modification) " -f Red
    } else {
        Write-Host "CopyDir: $filePathSrc --> " -NoNewline
        Write-Host "No change" -f Green
    }

}

# gci -Recurse D:\jahia_7.1.0.0\pic\tu\src_dir\tocopy_file.txt | % { Write-Host $_.FullName }

function Compare-FileConf([System.IO.FileInfo[]]$fileListSrc , [System.IO.FileInfo[]] $fileListDst) {
    $filesAreDifferent = $false

    if ($fileListSrc.Count -eq $fileListDst.Count) {
        For ($i=0 ; $i -lt $fileListSrc.Count -and -not $filesAreDifferent ; $i++) {
            # Write-Host $fileListSrc[$i].FullName versus $fileListDst[$i].FullName
            if (@(Compare-Object (gc $fileListSrc[$i].FullName) (gc $fileListDst[$i].FullName)).count -ne 0) {
                $filesAreDifferent = $true
            }
        }
    } else {
        $filesAreDifferent = $true
    }

    return $filesAreDifferent
}

function Rename-FileConf($oldString, $newString) {
    switch ($script:fileConfCurrentFileType) {
        "XML" {
            Write-Host "TODO Rename-FileConf for XML file"
        }
        default {  #Inclus "PROPERTIES"
            $script:fileConfCurrentContentTxt = $script:fileConfCurrentContentTxt -replace "$oldString", "$newString"
        }
    }
}

Export-ModuleMember -Function *
