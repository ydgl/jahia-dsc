
$fileToTail = $args[0]
$scanDelay = $args[1]


Write-Host "tail.ps1 fichier [scan laps time]"

if ($fileToTail -eq $null) {
    $fileToTail = "$env:CATALINA_HOME\logs\jahia.log"
    $scanDelay = 1000
} else {
    if ($scanDelay -eq $null) {
        $scanDelay = 1000
    }
}


Write-Host "tail $fileToTail $scanDelay"

Get-Content -Tail 100 $fileToTail



do {
    $lines = Get-Content $fileToTail | Measure-Object -Line    
    sleep -Milliseconds $scanDelay
    $linesB = Get-Content $fileToTail | Measure-Object -Line    
    
    $nbLines = $lines.Lines
    $nbLinesB = $linesB.Lines

    #Write-Host "nb $nbLines ,  $nbLinesB"

    if ($nbLinesB -gt $nbLines) {
        $diffLine = ($nbLinesB - $nbLines)
        #Write-Host "nb $diffLine"   
        Get-Content -Tail $diffLine $fileToTail
    } 
} while ($true)

