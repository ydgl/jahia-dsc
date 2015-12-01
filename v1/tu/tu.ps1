

$MyScriptRoot = "$PSScriptRoot\.."

Import-Module -Force $MyScriptRoot\modules\utils

# On clean les sorties
Remove-Item -ErrorAction Ignore -Recurse "$PSScriptRoot\side_dir\*"



#Start-FileConf "$PSScriptRoot\side_dir"
         
$tmpBool = Edit-FileConf "$PSScriptRoot\src_dir\test.properties" Default "PROPERTIES"
$tempVal = "d:\utils\jahia" -replace '\\' , '\\'
Expand-FileConf 'JAHIA_HOME' "$tempVal"
Update-FileConf "tomcat.util.buf.StringCache.byte.enabled" "coucou"
Rename-FileConf "commons" "TESTTEST"
Save-FileConf "$PSScriptRoot\dst_dir\test.properties"

# Test behavior when output config file is the same as destination
$tmpBool = Edit-FileConf "$PSScriptRoot\src_dir\test_unchanged.properties" Default "PROPERTIES"
Update-FileConf "tomcat.util.buf.StringCache.byte.enabled" "coucou"
Rename-FileConf "commons" "TESTTEST"
Save-FileConf "$PSScriptRoot\dst_dir\test_unchanged.properties"




$tmpBool = Edit-FileConf "$PSScriptRoot\src_dir\test.xml" UTF8 "XML"
Update-FileConf "/Repository/Workspace/SearchIndex/param[@name='analyzer']/@value" "org.apache.lucene.analysis.fr.FrenchAnalyzer"
Expand-FileConf 'JAHIA_HOME' "$tempVal"
New-FileConf "timeToLiveSeconds" "3600" "/Repository/DataSources/DataSource/param[@name='driver']"
Save-FileConf "$PSScriptRoot\dst_dir\test.xml"

if (Edit-FileConf "rsdfqsdfqsdfqsdfqsdfqsoro.xmsdfsdl" UTF8 "XML") {
    Write-Host "c'est PAS normal"
} else {
    Write-Host "Fichier Inconnnu : rsdfqsdfqsdfqsdfqsdfqsoro.xmsdfsdl (c'est normal : OK)"
}



# Test Copy-FileConf on directories

# Destination must exist (we replace destination)
New-Item -ErrorAction Ignore "$PSScriptRoot\dst_dir\tocopy_dir" -type directory
Copy-FileConf "$PSScriptRoot\src_dir\tocopy_dir" "$PSScriptRoot\dst_dir\tocopy_dir"

Copy-FileConf "$PSScriptRoot\src_dir\tocopy_dir_unchanged" "$PSScriptRoot\dst_dir\tocopy_dir_unchanged"

# Test Copy-FileConf on file

Copy-FileConf "$PSScriptRoot\src_dir\apec-jahia-specific.jar" "$PSScriptRoot\dst_dir\apec-jahia-specific.jar"

Copy-FileConf "$PSScriptRoot\src_dir\tocopy_file.txt" "$PSScriptRoot\dst_dir\tocopy_file.txt"

Copy-FileConf "$PSScriptRoot\src_dir\tocopy_file_unchanged.txt" "$PSScriptRoot\dst_dir\tocopy_file_unchanged.txt"


Stop-FileConf
