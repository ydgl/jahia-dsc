# Coucou Reqs -Version 4.0
# Get-ChildItem -Path C:\tmp\ConfigureNewServer | ConvertTo-MrMOFv4 -Verbose
function ConvertTo-MrMOFv4 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateScript({Test-Path $_ -PathType Leaf -Include *.mof})]
        [Alias('FullName')]
        [string[]]$Path,
        [Parameter(DontShow)]
        [ValidateNotNullorEmpty()]
        [string]$Pattern = '^\s*Name=.*;$|^\s*ConfigurationName\s*=.*;$',
        [string[]]$Pattern2 = {"Name","ConfigurationName","MinimumCompatibleVersion","CompatibleVersionAdditionalProperties"}
    )
<#
il faur remplacer 
^\s*${string}= par //${string}
idem : 
Name

ConfigurationName
MinimumCompatibleVersion
CompatibleVersionAdditionalProperties
#>
    PROCESS {
        
        foreach ($file in $Path) {
            $mof = Get-Content -Path $file
            foreach ($pattern3 in $pattern2) {
                
            }
            if ($mof -match $Pattern) {
                Write-Verbose -Message "PowerShell v4 compatibility problems were found in file: $file"
                try {
                    $mof -replace $Pattern |
                    Set-Content -Path $file -Force -ErrorAction Stop
                }
                catch {
                    Write-Warning -Message "An error has occurred. Error details: $_.Exception.Message"
                }
                finally {
                    if ((Get-Content -Path $file) -notmatch $Pattern) {
                        Write-Verbose -Message "The file: $file was successfully modified."
                    }
                    else {
                        Write-Verbose -Message "Attempt to modify the file: $file was unsuccessful."
                    }
                }
            }
        }
    }
}