# Pour connaitre la version de PS $PSVersionTable

# Pour lister les modules DSC : Get-DscResource

<#

HOWTO ########################################################################

Pour connaitre les module dispo sur le store / PSGallery
Find-Module -tag DSC


Pour connaitre les resources installé sur son local
Get-DscResource

Pour installer un module 
install-module -Name "nom_de_module" -force

Pour connaitre la syntaxe d'une ressource
Get-DscResource -Name "nom_de_resource" -Syntax

Pour utiliser une resource dans une configuration mettre dans la configuration
Import-DscResource -ModuleName <nom_du_module>

Ou sont installés les modules DSC ?
C:\Program Files\WindowsPowerShell\Modules

Configuration du LCM 
Get-DscLocalConfigurationManager

HOWTO Resource Perso #########################################################
Install-Module xDSCResourceDesigner -force

Les resource perso on trois fonctions :
	Get-TargetResource
	Test-TargetResource
	Set-TargetResource


Ce module apporte 
	New-xDscResource -Name <name> ... : pour créer des ressources 
	New-DscResourceProperty ...       : Création des propriété de la ressource perso
	New-ModuleManifest ...		  : Créer le manifest pour pouvoir le distribuer

BUG ##########################################################################
Le tokenize ne gère pas l'encoding correctement (il fait que du 1252)

PROCEDURE ####################################################################

# Installation et prérequis

1/ Il faut WMF 4.0
$PSVersionTable.WSManStackVersion.Major >= 4  sinon Il faut installer WMF 4.0
Windows6.1-KB2819745-x64-MultiPkg.msu pour windows 7 SP 1

Pour installer WMF 5.0
Win7AndW2K8R2-KB3066439-x64.msu sur windows 7 SP 1


Il faut winrm pour pousser les commandes ?

La commande Enter-PSSession localhost doit pouvoir fonctionner

get-service winrm 
Enable-PSRemoting / Disable-PSRemoting

RESSOURCES ###############################################################

https://pwrshell.net/desired-state-configuration-for-linux/

#>


Configuration mycfg
{
    # Parameters are optional
    param ($MyName)
    $destinationPathDG = "C:\apec_fr-dsc\dst\cfg.properties"
    $sourcePathDG = "D:\apec_fr-dsc\src\cfg.properties"

    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource –ModuleName xReleaseManagement


    Node localhost
    {
      File MyFileExample
      {
         Ensure = "Present"  # You can also set Ensure to "Absent"
         #Type = "Directory“ # Default is “File”
         Recurse = $true
         Checksum = "ModifiedDate"
         SourcePath = $sourcePathDG # This is a path that has web files
         DestinationPath = $destinationPathDG # The path where we want to ensure the web files are present
         
         #DependsOn = "[WindowsFeature]MyRoleExample"  # This ensures that MyRoleExample completes successfully before this block runs
      }

      xTokenize TestConfig {
         dependsOn = "[File]MyFileExample"
         recurse = $true
         tokens = @{jojo="jiji"}         
         useTokenFiles = $false
         path = $destinationPathDG
         #searchPattern = $Node.SearchPattern
      }
    }
}

mycfg

# Start-DscConfiguration -Path mycfg -wait -Verbose
  
