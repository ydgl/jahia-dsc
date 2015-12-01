# For this library, we wait for the jahia instance to be in localhost:8080
# If this fact changes, we would have to refactor a bit


# the $cred parameters is a size 2 array like @('username', 'password')

Set-StrictMode -Version Latest

Import-Module -Force $PSScriptRoot\net
Import-Module -Force $PSScriptRoot\utils
Import-Module -Force $PSScriptRoot\jahia_module

$JAHIA_SITE_URL = 'localhost:8080'
$JAHIA_SITE_NAMES = @("cadres", "jd", "recruteurs", "www", "presse", "edito", "perso")

<#
.Description
    Header to log into a jahia website

#>
function Get-JahiaHeaderCredentials{
    Param(
        [Parameter(Mandatory)]
        [String[]]$cred
    )

    $username, $password = $cred

    $base64encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))
    
    return ("Basic {0}" -f $base64encoded)
}


<#
.Description
    Launch a request into jahia tools -> console

#>
function Request-JahiaToolsConsole {
    Param(
        [Parameter(Mandatory)][String[]]$cred,
        [Parameter(Mandatory)][ValidateSet('default', 'live', 'both')][String]
        $workspace,
        [Parameter(Mandatory)][String] $code
    )

    if($workspace -eq 'both'){
        $res1 = Request-JahiaToolsConsole $cred 'default' $code
        $res2 = Request-JahiaToolsConsole $cred 'live' $code
        return @($res1, $res2)
    }

    $params = @{
        'workspace' = $workspace;
        'locale' = 'en';
        'action' = 'execute';
        'script' = $code;
    }


    $authheader = @{Authorization=(Get-JahiaHeaderCredentials $cred)}

    $res = Invoke-WebRequest -Headers $authheader -Uri "http://$JAHIA_SITE_URL/tools/jcrConsole.jsp" -Method POST -Body $params
    Assert-OrThrow ("$res" -notmatch "Error") "WebRequest tools returned error"
    
    Assert-OrThrow ("$res" -ne "") "WebRequest tools returned error empty"
    
    # cleaning result removing element not in result part
    $body = $res.ParsedHtml.body
    @('legend', 'form', 'img', 'a') | %{
        $body.getElementsByTagName($_) | %{ $_.removeNode($true) } > $null
    } > $null

    return $($body.getElementsByTagName('pre') | %{ $_.innerHTML } | Out-String)

}



<#
.Description
    Export a jahia site into a zip file
    if the parameter 'all' is used for sitename,
    then the output_path is not the filename but the directory the files will be stored to

#>
function Export-JahiaSite{

    Param(
        [Parameter(Mandatory)][String[]]$cred,
        [Parameter(Mandatory)][ValidateSet('cadres', 'jd', 'recruteurs', 'www', 'presse', 'edito', 'perso', 'nousrejoindre', 'all')][String]
        $sitename,
        [Parameter(Mandatory)][ValidateScript({!$(Test-Path $_)})] # path should not exists
        $output_path
    )

    if($sitename -eq 'all'){
        mkdir $output_path >$null
        $JAHIA_SITE_NAMES | %{
            Export-JahiaSite $cred $_ "$output_path\$_.zip" | Out-Null
        }
        return $true
    }

    Write-Host "extract $sitename to $output_path"

    $target_base = "http://$JAHIA_SITE_URL/cms/export/default/monexport.zip"
    $query = @{
        "exportformat"="site";
        "live"="false";
        "sitebox"=$sitename;
    }

    $url =  ConvertTo-URL $target_base $query
    $authheader = @{Authorization=(Get-JahiaHeaderCredentials $cred)}
    try{
        Invoke-RestMethod -Headers $authheader -OutFile $output_path $url
    } catch {
        Write-Output $_
        return $false
    }

    return $true
}



function Request-JahiaFelix {
    Param(
        [String[]] $commands
    )

    # Felix can't be called elsewhere than localhost
    return $(Get-Telnet -RemoteHost 'localhost' -Port 2019 -Commands $commands)
}



function Jahia_telnet_getModules {
    Param(
        [System.Net.Sockets.TcpClient] $connection = $null,
        [String[]]$module_names = $JAHIA_SITE_MODULES
    )

    # return jahia port stuff
    $res = @()


    $modules = Request-Felix $connection "jahia:modules"
    $modules = [Regex]::Split($modules,"[`r`n]+")

    $current_state = $null

    foreach ($line in $modules){
        $match = [Regex]::Match($line, "^([0-9]+) : ([^ ]+) ")
        if(!$match.Success){
            $match = [Regex]::Match($line, "^Module State: (.*)$")
            if($match.Success){
                $current_state = $match.groups[1].value
            }
            continue
        }

        $number = $match.groups[1].value
        $module_name = $match.groups[2].value

        $is_apec = $module_names | ?{$module_name -eq $_} | %{ $input -ne ""}
        if($is_apec){
            $res += , @($module_name, $number, $current_state)
        }

    }

    return , $res
}



Function Get-FelixObject {

    $res = New-Object System.Net.Sockets.TcpClient('localhost', '2019')
    Wait-FelixPrompt $res > $null
    return $res

}


Function Wait-FelixPrompt {
    Param (
        [System.Net.Sockets.TcpClient] $connection
    )

    $Stream = $connection.GetStream()
    $Buffer = New-Object System.Byte[] 1024 
    $Encoding = New-Object System.Text.AsciiEncoding

    $Result = ""

    while($true){

        While($Stream.DataAvailable){
            $Read = $Stream.Read($Buffer, 0, 1024) 
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
        }

        if($Result -match 'g! $'){
            return $($Result -replace 'g! $', '')
        }

        Start-Sleep -Milliseconds 500
        $Stream.flush()
    }

}


Function Request-Felix {
    Param (
        [System.Net.Sockets.TcpClient] $connection,
        [string]$command
    )

    $Writer = New-Object System.IO.StreamWriter($connection.GetStream())
    $writer.WriteLine($command)
    $writer.Flush()

    return $(Wait-FelixPrompt $connection)
}

<#
.Description
    Initialize couloir, internDomain, externDomain
    Return $couloir$domain

.Example
    input  : $inputCouloir = REc1, $interDomain = ""                  , $externDomain=""
    output :                 rec1                 .dapec.internaluse                  apec.fr
    return : rec1.apec.fr

.Example 
    input  : $inputCouloir = prod, $interDomain = dapec.internaluse,     $externDomain=apec.fr
    output :                  ""                  prod.dapec.internaluse               apec.fr
    return : .apec.fr
    

.Example 
    input  : $inputCouloir = xxxx, $interDomain = "", $externDomain="", $hostMode = true
    output :                 xxxx                 "",               ""
    return : xxxx

.Parameter internDomain 
    Return Domain including leading point ".domain", intern url is host+interDomain

.Parameter externDomain
    Return Extern domain, extern url is host+"."+externDomain

#>
Function Initialize-Couloir ([ref]$inputCouloir, [ref]$internDomain, [ref]$externDomain, $hostMode = $false) {

    $couloir_domain = ""

    $localInputCouloir = $inputCouloir.Value.ToLower()
    $localInternDomain = $internDomain.Value
    $localExternDomain = $externDomain.Value

    if ($hostMode) {
        $localInternDomain = ""
        $localExternDomain = ""
        $couloir_domain = $localInputCouloir
    } else {
        # If domain not specified setup default value
        if ($localInternDomain -eq "") {
            $localInternDomain = "dapec.internaluse"
        }
        if ($localExternDomain -eq "") {
            $localExternDomain = ".apec.fr"
        }
        $couloir_domain = "$localInputCouloir$localExternDomain"
    }


    # prod is a special word with particular treatment
    If ($localInputCouloir -eq "prod") {
        $localInputCouloir = ""
        $localExternDomain = ".$localExternDomain"
        $localInternDomain = "prod.$localInternDomain"
        $couloir_domain = "$localInputCouloir.$localExternDomain"
    }

    $inputCouloir.Value = $localInputCouloir
    $internDomain.Value = $localInternDomain
    $externDomain.Value = $localExternDomain

    return $couloir_domain
}



Export-ModuleMember -Variable *
Export-ModuleMember -Function *
