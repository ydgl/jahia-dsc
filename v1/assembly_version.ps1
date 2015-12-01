<#
.SYNOPSIS 
    Crée un dossier avec tous les éléments - dans une version précise - nécessaire à la livraison

    L'utilisation de cette commande requiert que les sources soit à jour (svn update), que le build hudson release ait été fait.

    Durant son execution la commande travaille dans un dossier temporaire dans c:\

    La commande stoppe avant la fin est demande à l'utilisateur d'ajouter les éléments complémentaire à la livraison (dans le dossier temporaire).
    Ceci a pour but de lui rappeler d'ajouter les documents relatif aux opérations manuelles.
    Il est toujours possible de les ajouter aprés coup.

    Le dossier temporaire est ensuite déplacé et renommé dans le répertoire courant.

    La procédure d'installation de l'assembly est ici : http://confluence.apec.fr/x/D4DEDw

    En général on transmet le zip de l'assembly et la référence vers la procédure d'installation (ci-dessus) à l'exploitation pour livraison en production.


.PARAMETER VersionNumber
    The version of nexus artifact
    Ex : 1.0.0-RC-10
#>



##############################################################################
# INITIALIZATION
##############################################################################

param(
    [Parameter(Mandatory=$true)]
    [string]$VersionNumber,
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [string]$OutputPath = $PWD
)


Set-StrictMode -Version Latest
trap { Write-Host $_ -f Red ; Write-Output $_ ; exit 1 }


Import-Module -Force "$PSScriptRoot\modules\jahia_module"
Import-Module -Force "$PSScriptRoot\modules\nexus"
Import-Module -Force "$PSScriptRoot\modules\utils"

$ScriptDirName   = "SetupJahia"
$ModulesDirName = "Module"
$EzpublishDirName = "Ezpublish"
$DeliaDirName = "Delia"
$BoostrapDirName = "Boostrap"
$SvnJahiaTagsRoot = "http://svn2.apec.fr/si/tags/jahia-"



if(!$(Test-Command svn)){

    Write-Host "!!! You don't have SVN !!!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Launch a cmd as administrator and put this cmd : "
    Write-Host "@powershell -NoProfile -ExecutionPolicy unrestricted -Command `"iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))`" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    Write-Host ""
    Write-Host "Then launch again a cmd as administrator and put this cmd : "
    Write-Host "choco install svn"
    Write-Host ""
    Write-Host "You're done, launch the powershell (with a new shell)"
    
    exit
}


##############################################################################
# CREATE ASSEMBLY
##############################################################################


# Create tmp folder __________________________________________________________

$curdate = date -Format yyyyMMdd.HHmmss
$TmpDirName = "c:\tmp${curdate}" # Use tmp dirname as short as possible (windows limit folder to 260 char)
$AssemblyDirName = "Assembly_${VersionNumber}_${curdate}"
$NginxStaticSites = "$TmpDirName\nginx_static_sites"

Write-Host "Creating folder in $TmpDirName ... " -NoNewline

if (Test-Path $TmpDirName) {
    Remove-Item -Recurse -Force $TmpDirName > $null
}
New-Item -ItemType Directory -Force "$TmpDirName" > $null

Write-Host " done" -f Green

# Extract scripts ____________________________________________________________

Write-Host "Exploit Scripts $SvnJahiaTagsRoot${VersionNumber}/pic ..." -NoNewline

svn export "$SvnJahiaTagsRoot${VersionNumber}/pic" "$TmpDirName\SetupJahia" > $null

Write-Host " done" -f Green

# Extract nginx site  ________________________________________________________

Write-Host "Nginx static sites $SvnJahiaTagsRoot${VersionNumber}/nginx/sites ..." -NoNewline

svn export "$SvnJahiaTagsRoot${VersionNumber}/nginx/static/sites" "$NginxStaticSites" > $null

Write-Host " done" -f Green


# Download module ____________________________________________________________

$ScriptDirPath = "$TmpDirName\$ScriptDirName"
$ModulesDirPath = "$TmpDirName\$ModulesDirName"
$PhantomDirPath = "$TmpDirName\Phantom"
$PagesDirPath = "$TmpDirName\pages"
$BoostrapDirPath = "$TmpDirName\$BoostrapDirName"

New-Item -ItemType Directory -Force "$TmpDirName" > $null


Write-Host "Downloading modules ..." 
New-Item -ItemType Directory "$ModulesDirPath" > $null
foreach ($jar_base_name in $JAHIA_SITE_MODULES) {

    Get-NexusArtefact $jar_base_name $VersionNumber "$ModulesDirPath"
}
Write-Host "                        done" -f Green

# Download phantom _________________________________________________________

Write-Host "Downloading phantom batch ..."
New-Item -ItemType Directory "$PhantomDirPath" > $null
$url = "http://nexus2.apec.fr:81/nexus/service/local/repositories/releases/content/fr/apec/jahia/apec-phantom-server/$VersionNumber/apec-phantom-server-$VersionNumber-binary.zip" 
$fileName = [System.IO.Path]::GetFileName($url)
$(New-Object System.Net.WebClient).DownloadFile($url, "$PhantomDirPath\$fileName")
Write-Host "                              done" -f Green


# Download bootstrap _________________________________________________________

Write-Host "Downloading bootstrap ..." -NoNewline
New-Item -ItemType Directory "$BoostrapDirPath" > $null
$url = Get-UrlJahiaStoreModule 'bootstrap3-core' '1.4.0'
$fileName = [System.IO.Path]::GetFileName($url)
$(New-Object System.Net.WebClient).DownloadFile($url, "$BoostrapDirPath\$fileName")

$url = Get-UrlJahiaStoreModule 'bootstrap3-components' '1.2.1'
$fileName = [System.IO.Path]::GetFileName($url)
$(New-Object System.Net.WebClient).DownloadFile($url, "$BoostrapDirPath\$fileName")
Write-Host " done" -f Green


# Download Jweaver ___________________________________________________________

Write-Host "Downloading Jweaver ..." -NoNewline
$url = "http://nexus2.apec.fr:81/nexus/service/local/repositories/Jahia-Snapshot/content/org/aspectj/aspectjweaver/1.6.11/aspectjweaver-1.6.11.jar"
$fileName = [System.IO.Path]::GetFileName($url)
$(New-Object System.Net.WebClient).DownloadFile($url, "$ScriptDirPath\template\$fileName")
Write-Host " done" -f Green


# Add pages folder ___________________________________________________________

Write-Host "Ajout du dossier pages ..." -NoNewline
Move-Item  "$TmpDirName\SetupJahia\pages" "$PagesDirPath"
Write-Host " done" -f Green


# Ajout de composants supplémentaires_________________________________________

Write-Host "Merci d'inclure les éléments supplémentaires (fichier à importer, procédure docx,...) dans $TmpDirName ..."
Write-Host "VERIFIER QUE PERSONNE N'UTILISE LE SITE (SITE PUBLIE COMPLETEMENT)" -f Red
pause


Write-Host " done" -f Green


# Save assembly _____________________________________________________________

Write-Host "Move to $AssemblyDirName ..." -NoNewline
New-Item -ItemType Directory -Force "$OutputPath" > $null
Move-Item "$TmpDirName" "$OutputPath\$AssemblyDirName"
Write-Host " done" -f Green


# We can doit now, it "seems" that Expand-ZIPFile require some cycle to ends (other remove-item trigger exception)
# Anyway : i don't care
#Remove-Item "WinPython-64bit-3.3.5.6.zip"