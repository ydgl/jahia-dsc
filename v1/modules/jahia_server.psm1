# For this library, we hope the serveur is always in a stable state when executing actions
# So it may not work when starting or stopping


Set-StrictMode -Version Latest

Import-Module -Force $PSScriptRoot\utils

$script:JAHIA_SERVICE_NAME = "Tomcat7"

###############################################################################
#
# OLD JAHIA STOP/START TOOL USING BAT FILE & ADDRESSING JAVA PROCESS
#
##############################################################################

<#
    
#>
function Start-Jahia_JAVA(){

    Write-Host "Starting Jahia ... " -NoNewline

    if(Test-JahiaStarted){
        Write-Host "Already started"
        return
    }


    $cmdCall = "$env:CATALINA_HOME\bin\startup.bat"
    Write-Host "call $cmdCall " -NoNewline
    Start-Job { & "$cmdCall" } > $null

    Wait-For -ScriptBlock { Test-JahiaStarted } -limit 60 -LimitPassedBlock {
        raise "Jahia start too long"
    }

}


<#

#>
function Stop-Jahia_JAVA(){

    Write-Host "Stopping Jahia ... " -NoNewline

    if(Test-JahiaStopped){
        Write-Host "Already stopped"
        return
    }

    $previous_processes = Get-JahiaPotentialProcess

    $cmdCall = "$env:CATALINA_HOME\bin\shutdown.bat"
    Write-Host "call $cmdCall"
    Start-Job { & "$cmdCall" } > $null

    Write-Host "wait for webserver to stop responding"
    Wait-For -ScriptBlock { Test-JahiaStopped } -limit 60 -LimitPassedBlock {
        raise "Jahia server stop too long"
    }

    # now that jahia is on the way of shutting down, we wait for its process to shut

    Write-Host "wait for process to stop"
    Wait-For -ScriptBlock {
        Param($previous)
        return $previous -ne $(Get-JahiaPotentialProcess)
    } -ArgumentList $($previous_processes) -LimitPassedBlock {
        raise "Jahia process stop too long"
    } -limit 60

}


<#

#>
function Restart-Jahia_JAVA(){
    # make sure jahia is relaunched
    Stop-Jahia_BAT
    Start-Jahia_BAT
}



<#
.Description
  List all java process, because Jahia is listed as a java named process
  Because this list the potential jahia processes,
  the user should only use it for differential purpose (not knowing which process might be jahia)

#>
function Get-JahiaPotentialProcess(){
    Get-Process java -ErrorAction SilentlyContinue | foreach { $_.Id } | sort
}


##############################################################################
#
# JAHIA STOP/START TOOL USING WINDOWS SERVICE
#
##############################################################################







##############################################################################
#
# EVALUATE JAHIA RUN-LEVEL
#
##############################################################################


<#

#>
function Test-JahiaStopped(){
    return !$(Test-JahiaStarted)
}

function Test-JahiaStarted($maxTimeoutDelay = 5){
    $jahiaStarted = $false
    

    $jahiaStartedJMX = Test-TomcatJMX

    if ($jahiaStartedJMX -eq 2) {
        # Test Jahia status
        $test_url = 'http://localhost:8080/cms/login'
        $HTTP_Request = [System.Net.HttpWebRequest]::Create($test_url)
        $HTTP_Request.Timeout = 1000 * 5 # 5 seconds

        Try {

            $HTTP_Response = $HTTP_Request.GetResponse()
            $HTTP_Status = [int]$HTTP_Response.StatusCode # For debug purpose
            $HTTP_Response.Close()

            return $true
        } Catch {
            switch -Wildcard ($_) {
                '*(401)*' { return $true }   # server is running
                '*(503)*' { return $true }   # server is running
                '*Impossible de se connecter au serveur distant*' { return $false }
                '*Le d?lai d?attente de l?opération a expir?.*' { return $false }

                default {
                    # We don't return false in all cases,
                    # because we might have others exceptions thats mean true
                    throw "Return not known : $_"
                }
            }
        
        }
    }
    return $jahiaStarted

}

<#
    Return 3 state :
        0 : jahia is off
        1 : temporary state
        2 : jahia is up
#>
function Test-TomcatJMX(){
    $jahiaStarted = 0
   

    $JAVA_EXE = "$env:JAVA_HOME\bin\java.exe"
    $JMX_JAR_TOOL = "$PSScriptRoot\jmxterm-1.0-alpha-4-uber.jar"
    $JMX_SCRIPT_FILENAME = "$PSScriptRoot\jmxGetJahiaStateName.txt"
    $JMX_SCRIPT_OUTPUT_FILENAME = "$PSScriptRoot\jmxOutJahiaStateName.txt"

    <#
    We use jmxterm

    http://wiki.cyclopsgroup.org/jmxterm/
    https://github.com/jiaqi/jmxterm

    Invoke is like ;
    java -jar jmxterm-1.0-alpha-4-uber.jar -i scriptFileName.txt -n -verbose silent -o scriptOutputFileName

    Tomcat setup must comply with script : JMX port is 2405, no password AND only local access

    in setenv.bat :
    set CATALINA_OPTS=%CATALINA_OPTS%  -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=true -Dcom.sun.management.jmxremote.port=2405 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false

    #>

    Write-Host $PSScriptRoot\jmxGetJahiaStateName.txt
    #java.exe -jar $JMX_JAR_TOOL -i $JMX_SCRIPT_FILENAME -n -verbose silent -o $JMX_SCRIPT_OUTPUT_FILENAME
    $prm = '-jar',"$JMX_JAR_TOOL", "-i", "$JMX_SCRIPT_FILENAME", "-n", "-verbose", "silent", "-o", "$JMX_SCRIPT_OUTPUT_FILENAME"

    & $JAVA_EXE $prm

    Write-Host $PSScriptRoot\jmxOutJahiaStateName.txt

    $stateName = (gc $JMX_SCRIPT_OUTPUT_FILENAME).Replace("stateName = ","").Replace(";","")
    <#

    Available LifeCyle state for TOMCAT-8 (https://tomcat.apache.org/tomcat-7.0-doc/api/org/apache/catalina/Lifecycle.html)

                start()
      -----------------------------
      |                           |
      | init()                    |
     NEW ->-- INITIALIZING        |
     | |           |              |     ------------------<-----------------------
     | |           |auto          |     |                                        |
     | |          \|/    start() \|/   \|/     auto          auto         stop() |
     | |      INITIALIZED -->-- STARTING_PREP -->- STARTING -->- STARTED -->---  |
     | |         |                                                  |         |  |
     | |         |                                                  |         |  |
     | |         |                                                  |         |  |
     | |destroy()|                                                  |         |  |
     | -->-----<--       auto                    auto               |         |  |
     |     |       ---------<----- MUST_STOP ---------------------<--         |  |
     |     |       |                                                          |  |
     |    \|/      ---------------------------<--------------------------------  ^
     |     |       |                                                             |
     |     |      \|/            auto                 auto              start()  |
     |     |  STOPPING_PREP ------>----- STOPPING ------>----- STOPPED ---->------
     |     |                                ^                  |  |  ^
     |     |               stop()           |                  |  |  |
     |     |       --------------------------                  |  |  |
     |     |       |                                  auto     |  |  |
     |     |       |                  MUST_DESTROY------<-------  |  |
     |     |       |                    |                         |  |
     |     |       |                    |auto                     |  |
     |     |       |    destroy()      \|/              destroy() |  |
     |     |    FAILED ---->------ DESTROYING ---<-----------------  |
     |     |                        ^     |                          |
     |     |     destroy()          |     |auto                      |
     |     -------->-----------------    \|/                         |
     |                                 DESTROYED                     |
     |                                                               |
     |                            stop()                             |
     --->------------------------------>------------------------------



    DESTROYED 
    DESTROYING 
    FAILED 
    INITIALIZED 
    INITIALIZING 
    MUST_DESTROY 
    MUST_STOP 
    NEW 
    STARTED 
    STARTING 
    STARTING_PREP 
    STOPPED 
    STOPPING 
    STOPPING_PREP 

    #>

    switch ($stateName) {
        "STARTED"         { $jahiaStarted = 2 }
        # All Other state

        {"DESTROYING" ,
        "FAILED",
        "INITIALIZED",
        "INITIALIZING", 
        "MUST_DESTROY",
        "MUST_STOP",
        "NEW",
        "STARTED",
        "STARTING",
        "STARTING_PREP",
        "STOPPED",
        "STOPPING", 
        "STOPPING_PREP" -contains $_ } { 
            Write-Host "Tomcat is in temporary state : $stateName"
            $jahiaStarted = 1 
            }

        # All other state leave jahiaStarted to 0
    }

    return $jahiaStarted
}



function Clear-JahiaTmpFile(){
    Remove-Item -ErrorAction Ignore -Recurse "$env:JAHIA_CATALINA_HOME\logs\*"
}


Export-ModuleMember -Function *
