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


Configuration mof2_$stage
{
    # Il faut que les chemins soient accessibles sur la source et la destination
    $destinationPathDG = "C:\dgl\dst\cfg.properties"
    $sourcePathDG = "D:\jahia-dsc\src2\cfg.properties"

    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource –ModuleName xReleaseManagement

    $nJahia = getNodes("jahia")

    Write-Host "$nJahia"

    Node $nJahia
    {
      File MyFileExample
      {
         Ensure = "Present"  # You can also set Ensure to "Absent"
         Recurse = $true
         Checksum = "ModifiedDate"
         SourcePath = $sourcePathDG # This is a path that has web files
         DestinationPath = $destinationPathDG # The path where we want to ensure the web files are present
         
      }

    }
}

Invoke-Expression "mof2_${stage}"

