
Set-StrictMode -Version Latest

Import-Module -Force $PSScriptRoot\utils
Import-Module -Force $PSScriptRoot\net


$JAHIA_SITE_MODULES = $(ConvertFrom-Json $(gc "$PSScriptRoot\..\configuration\modules.json" | Out-String)).jahia_modules

$JAHIA_MODULE_PATH = $jahia_jar_path = Find-FirstExistingPath @(
	"$env:JAHIA_HOME\digital-factory-data\modules"
)

function Find-ExistingModules{
    Param([String[]]$jar_names)

    $res = @()
    foreach ($jar_name in $jar_names) {
        $res += ls $JAHIA_MODULE_PATH | ?{$_.Name -match "^$jar_name.*\.jar$"}
    }

    $res = $res | Sort-Object FullName -Unique
    return $res
}


function Get-UrlJahiaStoreModule {
    Param(
        $module_name,
        $module_version
    )

    $file_name = "${module_name}-${module_version}.jar"
    return "https://store.jahia.com/cms/mavenproxy/private-app-store/org/jahia/modules/${module_name}/${module_version}/${file_name}"
}


function Install-JahiaStoreModule{
    Param(
        $module_name,
        $module_version
    )

    $file_name = "${module_name}-${module_version}.jar"
    $url = "https://store.jahia.com/cms/mavenproxy/private-app-store/org/jahia/modules/${module_name}/${module_version}/${file_name}"

    Get-File $url $JAHIA_MODULE_PATH\$file_name
}



Export-ModuleMember -Function *
Export-ModuleMember -Variable *
