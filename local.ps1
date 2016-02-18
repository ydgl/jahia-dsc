# Parameters are optional
param ( 
    $MyName,
    [String] $stage = "loc"
)

if (-not (Test-Path "$PSScriptRoot\nodes_${stage}.psm1")) {
    Write-Host "Fichier $PSScriptRoot\nodes_${stage}.psm1 introuvable"
    exit
} 

Import-Module -Force $PSScriptRoot\nodes_${stage}.psm1


Configuration mof_$stage
{
    # Il faut que les chemins soient accessibles sur la source et la destination
    $destinationPathDG = "C:\dgl\dst\cfg.properties"
    $sourcePathDG = "D:\jahia-dsc\src\cfg.properties"

    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource –ModuleName xReleaseManagement

    $nJahia = getNodes("jahia")

    Write-Host "$nJahia"

    Node $nJahia
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
         tokens = @{COULOIR=$stage}         
         useTokenFiles = $false
         path = $destinationPathDG
         #searchPattern = $Node.SearchPattern
      }
    }
}

Invoke-Expression "mof_${stage}"

# Start-DscConfiguration -Path mycfg -wait -Verbose

# $stage = int2
# $secpasswd = ConvertTo-SecureString "--------" -AsPlainText -Force
# $mycreds = New-Object System.Management.Automation.PSCredential ("PPROD-APEC.FR\servicesint", $secpasswd)
# local2.ps1 -stage $stage
# Get-ChildItem -Path D:\jahia-dsc\mof2_int2\ | ConvertTo-MrMOFv4 -Verbose
# Start-DscConfiguration -Path mof2_$stage -wait -Verbose -Force -Credential $mycreds
# 



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


POUR AVOIR LES CREDENTIALS
$secpasswd = ConvertTo-SecureString "--------" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("PPROD-APEC.FR\servicesint", $secpasswd)

Enter-PSSession cms2int2.pprod-apec.fr -Credential $mycreds

gci env: | sort name

PROCEDURE ####################################################################

# Installation et prérequis

1/ Il faut éviter WMF 4.0
$PSVersionTable.WSManStackVersion.Major >= 4  sinon Il faut installer WMF 4.0
Windows6.1-KB2819745-x64-MultiPkg.msu pour windows 7 SP 1

Mieux vaut install WMF 5.0
Win7AndW2K8R2-KB3066439-x64.msu sur windows 7 SP 1


Il faut winrm pour pousser les commandes ?

La commande Enter-PSSession localhost doit pouvoir fonctionner

get-service winrm 
Enable-PSRemoting / Disable-PSRemoting

La commande Ansible est : 
Enable-PSRemoting -Force -ErrorAction Stop

RESSOURCES ###############################################################

https://pwrshell.net/desired-state-configuration-for-linux/

Mes steps ###############################################################

Une lettre pour faire l'ordonnancement

W : Clean (wipe) si !Cold
O : Stop (O letter)
D : Deploy
C : Config
W : Clean si Cold
I : Start I Letter
M : Wait for a master
m : Wait for slave
T : Run test

deploy.ps1 -stageVar {a=g;f=d} -host <hostmaster[,host2,host3]> -assembly <assembly> -sequence <master_sequence_without_M>[<slave_sequence>,...] [-forceTypeAssembly type]

Version simple pour commencer
deploy.ps1 -COULOIR <COULOIR> -host <hostmaster[,host2,host3]> -assembly <assembly> -sequence cf_+_stop_#_+.ps1,cf_cms2_stop_+.ps1,cf_#_deploy_#.ps1,cf_cms1_config_#.ps1,cf_cms2_config_#.ps1

Format du fichier de conf : cf-<host>-<confName>-<COULOIR>-<clusterNodeType>.ps1

<master_sequence_without_M>[<slave_sequence>,...]

deploy.ps1 -stage prod -host cms1,cms2,cms3 -assembly myassembly.zip -sequence oODCWdcwIMi

grappe.ps1 -stage int1 -nodes [{[cms1prod],master.ps1},{[cms2prod,cms3prod],slave.ps1}] -assembly myassembly.zip -sequence oODCWdcwIMi

Version evoluée à travailler
dscc.ps1 -stage <name> -nodeType master -nodeName hostmaster -nodeType slave -nodeName host2,host3 \
    -nodeType nginx -nodeName host4,host5 -nodeType phantom -nodeName host6,host7,host8 -assembly <assembly> -stateSequence conf1,conf2,conf3,...

    Format des fichiers de config nc_<nodeName>_<stateName>_<stage>_<nodeType>.ps1
    Les variable peuvent être   # : Première valeur
                                + : Incrément du début à la fin
                                - : Décrémente de la fin au début


# Test ############################

local.ps1 -stage int2
Start-DscConfiguration -Path mof_int2 -wait -Verbose -Credentials $mycreds

erreur : 

PS D:\jahia-dsc> Start-DscConfiguration -Path mycfg_int2 -wait -Verbose -Credential $mycreds
VERBOSE: Perform operation 'Invoke CimMethod' with following parameters, ''methodName' = SendConfigurationApply,'className' = MSFT_DSCLocalConfigurationManager,'namespaceName' = root/Microsoft/Windows/DesiredStateConfiguration'.
VERBOSE: Perform operation 'Invoke CimMethod' with following parameters, ''methodName' = SendConfigurationApply,'className' = MSFT_DSCLocalConfigurationManager,'namespaceName' = root/Microsoft/Windows/DesiredStateConfiguration'.
VERBOSE: Un appel de méthode du Gestionnaire de configuration local est arrivé de l’ordinateur PO00027475 avec le SID utilisateur S-1-5-21-472488393-1914603911-3415694101-24568.
VERBOSE: [CMS3INT2] : Gestionnaire de configuration local :  [ Début  Définir  ]
VERBOSE: Un appel de méthode du Gestionnaire de configuration local est arrivé de l’ordinateur PO00027475 avec le SID utilisateur S-1-5-21-472488393-1914603911-3415694101-24568.
VERBOSE: [CMS2INT2] : Gestionnaire de configuration local :  [ Début  Définir  ]
VERBOSE: [CMS3INT2] : Gestionnaire de configuration local :  [ Fin    Définir  ]
Le fournisseur PowerShell xReleaseManagement n’existe pas à l’emplacement du module PowerShell et n’est pas non plus inscrit en tant que fournisseur WMI.
    + CategoryInfo          : InvalidOperation: (root/Microsoft/...gurationManager:String) [], CimException
    + FullyQualifiedErrorId : ModuleNameNotFound
    + PSComputerName        : cms3int2.pprod-apec.fr
 
VERBOSE: Operation 'Invoke CimMethod' complete.
VERBOSE: [CMS2INT2] : Gestionnaire de configuration local :  [ Fin    Définir  ]
Le fournisseur PowerShell xReleaseManagement n’existe pas à l’emplacement du module PowerShell et n’est pas non plus inscrit en tant que fournisseur WMI.
    + CategoryInfo          : InvalidOperation: (root/Microsoft/...gurationManager:String) [], CimException
    + FullyQualifiedErrorId : ModuleNameNotFound
    + PSComputerName        : cms2int2.pprod-apec.fr
 
VERBOSE: Operation 'Invoke CimMethod' complete.
VERBOSE: Time taken for configuration job to complete is 1.292 seconds


Réponse :
 
Il faut installer à la main le module manquant 'xReleaseManagement' en WMF5.0 il faut faire un install-module

Voir http://mikefrobbins.com/2014/10/30/powershell-desired-state-configuration-error-undefined-property-configurationname/

#>
