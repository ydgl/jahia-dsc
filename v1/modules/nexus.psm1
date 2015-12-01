
Set-StrictMode -Version Latest

Import-Module -Force $PSScriptRoot\net


function Test-ArtefactVersion($artefactVersion) {
    $retVal = $false

    switch -regex ($artefactVersion) {
        "^LATEST$" {
           $retVal = $true
        }

        "^SNAPSHOT$" {
           $retVal = $true
        }

        "^[0-9]+\.[0-9]+\.[0-9]+[\-,R,C,0-9,SNAPSHOT]*$" {
            $retVal = $true
        }
    }

    return $retVal
}

function Get-NexusUrl($artifact, $version){
    # http://nexus2.apec.fr:81/nexus/service/local/artifact/maven/content?r=snapshots&g=fr.apec.jahia&a=apec-modules&v=1.0.1-SNAPSHOT

    $group = "fr/apec/jahia"
    $nexus_url="http://nexus2.apec.fr:81/nexus/service/local/artifact/maven/redirect" 
    $query = @{
        "g" = $group -replace "/", ".";
        "a" = $artifact;
    }



    switch -regex ($version) {
        "^LATEST$" {
            $query.add("r" , "snapshots");
            $query.add("v" , "LATEST");
        }

        "\.*-SNAPSHOT$" {
           $query.add("r" , "snapshots");
           $query.add("v" , "$version");
        }

        default {
            $query.add("r" , "releases");
            $query.add("v" , "$version");
        }
    }


    $nexus_url = ConvertTo-URL $nexus_url $query
    Write-Host "nexus_url $nexus_url"

    return $nexus_url
}

function Get-NexusUrl_old($artifact, $version){

    $group = "fr/apec/jahia"

    if ($version -eq "LATEST"){
        $nexus_url="http://nexus2.apec.fr:81/nexus/service/local/artifact/maven/content" 
        $query = @{
            "r" = "snapshots";
            "g" = $group -replace "/", ".";
            "a" = $artifact;
            "v" = "LATEST";
        }
        $nexus_url = ConvertTo-URL $nexus_url $query
        #Write-Host "nexus_url $nexus_url"

        return $nexus_url
    }

    $nexus_base_url = "http://nexus2.apec.fr:81/nexus/service/local/repositories/releases/content"
    return "$nexus_base_url/$group/$artifact/$version/$artifact-$version.jar"
}


function Get-NexusArtefact($artifactBaseName, $version, $destDir) {
    $url = Get-NexusUrl $artifactBaseName $version

    If (!(Test-ArtefactVersion($version))) { return $null }

    Write-Host "url = $url"
    #getting the file name
    $filename_header = $(Invoke-WebRequest $url).Headers['Content-Disposition']
    if ($filename_header -match 'filename="([^"]*)"'){
        $file_name = $Matches[1]
    } else {
        $file_name = "$artifactBaseName-$version.jar"
    }

    #Write-Host "filename_header = $filename_header"

    # I suppose System.Net.WebClient is not native in powershell
    # $(New-Object System.Net.WebClient).DownloadFile($url, "$destDir\$file_name")
    wget $url -OutFile "$destDir\$file_name"

    return $file_name

}





Export-ModuleMember -Function *
