
<#
.SYNOPSIS 
    Connect to a distant machine and execute the update_jahia(.ps1) routine
    This script is triggered buy hudson for remote deploy jobs

.PARAMETER ps_url
    PowerShell URL distant deploy vm

.PARAMETER ps_username
    Login Name. Ex : cmsint1.pprod-apec.fr

.PARAMETER ps_password
    Password for username

.PARAMETER WithoutBackup
    Avoid backup of site on site vm

.PARAMETER COULOIR
    COULOIR de déploiement. 
    Voir explication dans la commande update_jahia.ps1

.PARAMETER SERVICE
    Nom du service tomcat a arrêter/redémarrer
    Voir explication dans la commande update_jahia.ps1

.PARAMETER VERSION
    The version of nexus artifact
    Ex : 1.0.0-RC-10; LATEST; 1(for SNAPSHOT VERSION)

#>


# WARNING
#
# HUDSON USE VERSION OF THIS FILE AS SOON AS THEY ARE COMMITED (HEAD VERSION)
# ==> Test before you commit
#
# WARNING

param(
    [Parameter(Mandatory=$true)]
    [string]$ps_url ,
    [Parameter(Mandatory=$true)]
    [string]$ps_username,
    [Parameter(Mandatory=$true)]
    [string]$ps_password,
    [string]$VERSION = "LATEST",
    [string]$COULOIR ,
    [string]$SERVICE ,
    [String]$BO_APEC_FR ,
    [switch]$WithoutBackup
)

Set-StrictMode -Version Latest
trap { Write-Host $_ -f Red ; Write-Output $_ ; exit 1 }

Import-Module -Force $PSScriptRoot\configuration\configuration
Import-Module -Force $PSScriptRoot\modules\remote



# Get JAHIA_HOME _____________________________________________________________


Write-Host -NoNewline "Get Distant JAHIA_HOME ... "
$pssesion = Get-PSSessionByPassword $ps_url $ps_username $ps_password
$distant_JAHIA_HOME = Invoke-Command -Session $pssesion { $env:JAHIA_HOME }
$distant_JAHIA_script = "$distant_JAHIA_HOME\..\SetupJahia"
Remove-PSSession -Session $pssesion
Write-Host "done" -f Green


# Put this script directory in remote/distant JAHIA_HOME (Last version) ______


Write-Host -NoNewline ("Copy last version of scripts into {0} ... " -f $distant_JAHIA_script)
$pssesion = Get-PSSessionByPassword $ps_url $ps_username $ps_password
Send-Directory "$PSScriptRoot" "$distant_JAHIA_script" $pssesion
Remove-PSSession -Session $pssesion
Write-Host "done" -f Green

# Call the scripts ___________________________________________________________


$pssesion = Get-PSSessionByPassword $ps_url $ps_username $ps_password
$script_path = "$distant_JAHIA_script\update_jahia.ps1"
Write-Host "Call the local script : $script_path"


if ($WithoutBackup) {
    Invoke-Command -Session $pssesion {Param($script_path, $version, $COULOIR, $SERVICE, $BO_APEC_FR)
        & "$script_path" -VERSION $version -WithoutBackup -FileUpdate -COULOIR $COULOIR -SERVICE $SERVICE -BO_APEC_FR $BO_APEC_FR
    } -ArgumentList "$script_path", $version, $COULOIR, $SERVICE, $BO_APEC_FR
} else {
    Invoke-Command -Session $pssesion {Param($script_path, $version, $COULOIR, $SERVICE, $BO_APEC_FR)
        & "$script_path" -VERSION $version -FileUpdate -COULOIR $COULOIR -SERVICE $SERVICE -BO_APEC_FR $BO_APEC_FR
    } -ArgumentList "$script_path", $version, $COULOIR, $SERVICE, $BO_APEC_FR
}


Remove-PSSession -Session $pssesion
Write-Host "done" -f Green

# Can't this work ?
#Invoke-Command -Session $pssesion -FilePath $script_path -ArgumentList -VERSION, $version

exit $Error.Count
