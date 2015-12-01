<#
.SYNOPSIS 
    Mise à jour de jahia avec la dernière version des livrables (Version LATEST) ou une version spécifique
    Par défaut la version est LATEST, les versions sont téléchargées depuis nexus


.LINK
    http://confluence.apec.fr/x/JAA-EQ

.EXAMPLE 
    .\update_jahia.ps1 -WithoutBackup -FileUpdate -VERSION "1.0.0-RC-19"
    Pour mettre à jour la version 1.0.0-RC-19 en copiant les module dans le répertoire (sans dialogue avec felix)

.EXAMPLE 
    .\update_jahia.ps1 -WithoutBackup -SRCDIR c:\mon_repertoire -FileUpdate
    Pour installer la version fourni dans un répertoire (sans backup, sans dialogue avec felix)

.EXAMPLE 
    .\update_jahia.ps1 -SRCDIR c:\mon_repertoire -FileUpdate -BACKUP_DIR d:\mesbackups
    Pour remplacer une version avec en faisant un backup de la version précédente dans un répertoire précis



.PARAMETER VERSION
    Version à installer
    Ex : 1.0.0-RC-10; LATEST (for SNAPSHOT VERSION)

.PARAMETER SRCDIR
    Indique le répertoire dans lequel les version à livrer sont disponible en local
    Ce mode désactive l'option VERSION

.PARAMETER WithoutBackup
    Ne backup pas les sites. Les modules ne sont pas backupés.

.PARAMETER FileUpdate
    Indique si la mise à jour se passe à chaud (via felix), à froid sinon (via le répertoire module) = FileUpdate indiqué
    Par défaut l'install se passe dans sans FileUpdate donc via felix

.PARAMETER JAHIA_HOME
    Surcharge le JAHIA_HOME actuellement positionnée comme variable d'environnement utilisateur.

.PARAMETER SERVICE
    Indique quel service arrêter / redémarrer pour tomcat
    Si aucun service n'est indiqué alors aucune service n'est arrêté ou redémarré.

.PARAMETER COULOIR
    Indique le couloir cible afin de déclencher les reconfigurations
    Si aucun couloir n'est spécifié alors aucune reconfiguration n'est appliqué

.PARAMETER BO_APEC_FR
    Indique si on configure un BO ou un FO. Voir doc setup_jahia.ps1


#>



param(
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [string]$JAHIA_HOME = $env:JAHIA_HOME,

    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [string]$BACKUP_DIR = "C:\JAHIA_BACKUP",

    [string]$VERSION,

    [string]$SRCDIR,

    [switch]$WithoutBackup,

    [String]$SERVICE,

    [string]$COULOIR = "",
    [string]$INTERN_DOMAIN  ,
    [string]$EXTERN_DOMAIN  ,

    [String]$BO_APEC_FR  ,

    [switch]$FileUpdate
)

$FileUpdate = $true

Set-StrictMode -Version Latest
trap { Write-Host $_ -f Red ; Write-Output $_ ; exit 1 }

Import-Module -Force $PSScriptRoot\modules\net
Import-Module -Force $PSScriptRoot\modules\nexus
Import-Module -Force $PSScriptRoot\modules\jahia_website
Import-Module -Force $PSScriptRoot\modules\jahia_server
Import-Module -Force $PSScriptRoot\modules\utils
Import-Module -Force $PSScriptRoot\configuration\configuration
Import-Module -Force $PSScriptRoot\modules\jahia_module

Assert-OrThrow $("$JAHIA_HOME" -ne "JAHIA_HOME not set") 




# 0 - Configuration
##############################################################################

$curdate = date -Format yyyyMMdd.HHmmss
$jahia_module_path = "$JAHIA_HOME\digital-factory-data\modules"
$tmpDlDir = "dl_$curdate.tmp"
$conf = Get-Conf

$hostname = '{0}:8080' -f $conf['ps_url']
$username, $password = $conf['jahia_cred']

$inputCouloir=$COULOIR

$internDomain = $INTERN_DOMAIN
$externDomain = $EXTERN_DOMAIN

$couloirDomain = Initialize-Couloir ([ref]$inputCouloir) ([ref]$internDomain) ([ref]$externDomain)

$serviceMode = $false
if ($SERVICE -ne "") {
    $serviceMode = Get-Service -ErrorAction SilentlyContinue $SERVICE
    if (-not $serviceMode) {
        Write-Host "Service $SERVICE inconnu sur cet environnement" -f Red
        Write-Host "Arrêt de l'update" -f Red
        Exit
    }
} 

# 1 - Backup current jahia sites
##############################################################################

if($WithoutBackup){ 
    Write-Host "No backup"
} else {
    Write-Host -NoNewline "Backup of sites ... "

    Export-JahiaSite $conf['jahia_cred'] 'all' "$BACKUP_DIR\export_$curdate"

    Write-Host "done" -f Green
}



# 2 - Remove modules (Cleaning left jar files)
##############################################################################

if (!$FileUpdate) {

    # Felix est l'outil qui gère les module OSGI (montage / démontage / arrêt / ...)

    $felix = Get-FelixObject

    $status = $(Jahia_telnet_getModules $felix $JAHIA_SITE_MODULES)
    Trace-Log "$($status.Length) modules loaded"

    Write-Host -NoNewline "Cleaning left jar ... "
    Trace-Log "Cleaning"
    foreach ($jar_base_name in $JAHIA_SITE_MODULES) {
        ls $jahia_module_path | ?{$_.Name -match "^$jar_base_name.*\.jar$"} | %{
            Trace-Log "rm $($_.FullName)"
            rm $_.FullName
        }
    }
    Write-Host "done" -f Green

} else {

    Write-Host -NoNewline "Cleaning left jar ... "
    Trace-Log "Cleaning"
    foreach ($jar_base_name in $JAHIA_SITE_MODULES) {
        ls $jahia_module_path | ?{$_.Name -match "^$jar_base_name.*\.jar$"} | %{
            Trace-Log "rm $($_.FullName)"
            rm $_.FullName
            Sleep -Milliseconds 3000 > $null
        }
        
    }
    Write-Host "done" -f Green

}

# Wait to be sure modules are uninstalled (asking felix or not)

if (!$FileUpdate) {

    Write-Host "Waiting for element to be removed ..." -NoNewline
    while($true){
           Sleep -Milliseconds 500 > $null
        
           $status = $(Jahia_telnet_getModules $felix $JAHIA_SITE_MODULES)
           Trace-Log "$($status.Length) elements left"
           if($status.Length -eq 0){
                break
           }
           $status_str = $status | %{ "$_" }
           Trace-Log "status : $status_str"
    }
    Write-Host " done" -f Green

} else {
    Write-Host "Attente une minute pour dé-déploiement ..." -NoNewline
    Sleep -Milliseconds 60000 > $null    
    Write-Host " done" -f Green
}


# 3 - Stop JAHIA (require service name indicated)
##############################################################################

if ($serviceMode) {

    Write-Host "Stop JAHIA..." 
    Stop-Service $SERVICE


    # Give service a bit to tidy up.
    Write-Host "Attente 30 secondes..." 
    Start-Sleep -Seconds 30

    # If the service isn't stopped yet, end the process forcefully.
    if ( (Get-Service -Name "$SERVICE").Status -ne 'Stopped' ) {
        Write-Host "Tomcat récalcitrant, on tue le process ..." -f Red
        Stop-Process -ProcessName "$SERVICE" -Force
        Write-Host "Attente 15 secondes..." 
        Start-Sleep -Seconds 15
    }

    $serviceState = (Get-Service -Name "$SERVICE").Status
    Write-Host "Etat du service : $serviceState"

    if ( $serviceState -ne 'Stopped' ) {
        Write-Host "Tomcat zombie mode tuer le tomcat manuellement ... Merci" -f Red
        Write-Host "Fin de l'opération" -f Red
        Exit
    }

} 



# 4 - Get new jar files 
##############################################################################

$tmp_files = @{}
New-Item -ItemType Directory "$tmpDlDir" > $null

if ($SRCDIR) {
    
    foreach ($jar_base_name in $JAHIA_SITE_MODULES) {
        $matchfile = Get-ChildItem $SRCDIR | where {$_ -match "$jar_base_name*" }     
        if ($matchfile -ne "") {
            Copy-Item $SRCDIR\$matchfile $tmpDlDir | Out-Null
            $tmp_files[$jar_base_name] = @("$SRCDIR\$matchfile")
            Write-Host $tmp_files[$jar_base_name]
        }
        
    }
} else {

    if (!(Test-ArtefactVersion $VERSION)) { 
        Write-Host "$VERSION n'est pas un numéro de version valide" -f Red 
        Exit -1
    }

    foreach ($jar_base_name in $JAHIA_SITE_MODULES) {
        Write-Host "Downloading ..." -NoNewline
        $artefactName = Get-NexusArtefact $jar_base_name $VERSION "$tmpDlDir"
        #Write-Host "$artefactName $VERSION $tmpDlDir ..." -NoNewline
        $tmp_files[$jar_base_name] = @("$tmpDlDir\$artefactName")
        Write-Host " $artefactName" -f Green
    }

}

# 5 - Install new jar files 
##############################################################################

if (!$FileUpdate) {
    # Install & start file in Jahia module directory

    foreach ($jar_base_name in $JAHIA_SITE_MODULES){


        $fileName = $tmp_files[$jar_base_name]


        Move-Item $fileName $jahia_module_path | Out-Null


        Write-Host "Waiting for $jar_base_name to be started ..." -NoNewline
        while($true){
            $status = $(Jahia_telnet_getModules $felix $($jar_base_name))

            if($status.Length -gt 0){
                Trace-Log "$jar_base_name status : $($status[0])"
                if($status[0][2] -eq "Started"){
                    break
                } elseif($status[0][2] -eq "Installed"){
                    Request-Felix $felix "felix:start $($status[0][1])" | Out-Null
                } elseif($Status[0][2] -eq "Stopped"){
                   Request-Felix $felix "felix:start $($status[0][1])" | Out-Null
                }

            } else {
                Trace-Log "$jar_base_name status : not loaded yet"
            }

            Sleep -Milliseconds 500 > $null    
        }
        Write-Host " done" -f Green

    }

    $felix.close()
} else {

    foreach ($jar_base_name in $JAHIA_SITE_MODULES){


        $fileName = $tmp_files[$jar_base_name]


        Move-Item $fileName $jahia_module_path | Out-Null


        Write-Host "$jar_base_name moved to $jahia_module_path"
    }

}

# 6 - Apply Apec.fr configuration
# If jahia is not stopped configuration will not be read by application
# $inputCouloir should be used in conjunction with $serviceMode ...
##############################################################################

if ($inputCouloir -ne "") {
    Write-Host "Lancement de la reconfiguration de jahia, COULOIR $inputCouloir via $PSScriptRoot\setup_jahia.ps1"
    $externDomainTmp = $externDomain.Substring([Math]::Min(1,$externDomain.Length),[Math]::Max(0,$externDomain.Length-1))
    & $PSScriptRoot\setup_jahia.ps1 -COULOIR $inputCouloir -INTERN_DOMAIN $internDomain -EXTERN_DOMAIN $externDomainTmp -BO_APEC_FR $BO_APEC_FR
    Write-Host "Fin de la reconfiguration de jahia"
} else {
    Write-Host "JAHIA n'est pas reconfiguré car l'option couloir n'est pas indiqué (c'est peut être délibéré)" -f Red
}


# 7 - Restart service 
##############################################################################
if ($serviceMode) {

    Write-Host "Suppression des logs..."
    Clear-JahiaTmpFile

    Write-Host "Start JAHIA..."
    Start-Service "$SERVICE"
    Write-Host "Attente 15 secondes..." 
    Start-Sleep -Seconds 15


    $serviceState = (Get-Service -Name "$SERVICE").Status
    Write-Host "Etat du service : $serviceState"


    Write-Host "done" -f Green
}


if (Test-Path $tmpDlDir) {
    Remove-Item -Recurse -Force $tmpDlDir
}

Write-Host " All modules loaded"
