<#
.SYNOPSIS 
    Ce script configure jahia pour faire tourner le site apec.fr. Il configure deux niveaux distincts
    	- L'instance jahia (option INST_...)
        - L'application apec.fr installé dans Jahia

    	
.DESCRIPTION
    Ce script a pour but de prendre en charge l'installation de jahia dans les cas les plus standards ainsi que la configuration de l'application Apec.fr

    Cet installeur installe JAHIA sur une version "complète" de tomcat installée dans <CATALINA_HOME>

    La configuration de référence est dans SVN : http://svn2.apec.fr/si/trunk/si/jahia/pic/
        ./system : pour les éléments lié à l'installtion du serveur (license, driver ojdbc, ...)
        ./template : pour les éléments relatif à la configuration du site Apec.fr

    Dans les cas complexe (par exemple cluster) il est possible de procéder comme suit :
        Sauvegarder le fichier xml en fin de première installation.
        L'installation est alors rejouable avec la commande :
        java -jar installeur_jahia_au_format_jar.jar fichier_de_configuration.xml
        Par ailleurs il est possible d'utiliser ce script pour jouer l'installation en positionnant les fichier jar et xml ci dessus dans le répertoire "system"

    Détail sur le fonctionnement de l'option INST_JAHIA_HOME
        La version par défaut est reconfigurée en ce qui concerne son emplacement (JAHIA_HOME) et l'accès BDD
        Si une version est déjà présente, elle est supprimée.
        Si le couloir mentionné est ne se termine pas par 'apec.fr' install une version derby (sinon une version oracle).
        Si on veut surcharger les versions installées on peut au choix forcer l'installeur (fichier d'installation jahia au format jar) ou bien
            forcer le fichier de configuration de l'installeur (fichier xml). Pour cela il faut placer le ou les fichiers dans le sous répertoire 
            de cette la commande courante (il faut que system\jahia.jar ou system\jahia.xml existe). Par exemple :
                C:\jahia\Jahia7.x                    --> installation du serveur jahia
                C:\jahia\<script>                    --> Répertoire contenant les script
                C:\jahia\<script>\system\jahia.jar   --> version de jahia que l'on veut installer (surcharge optionnelle)
                C:\jahia\<script>\system\jahia.xml   --> configuration de l'installeur (surcharge optionnelle)

    
.PARAMETER INST_JAHIA_HOME
    Cette option indique où la version par défaut de jahia (ou standard) doit être installée.
    Attention : en cas d'installation sur un base externe ORACLE, il faut une intervention pour la vider.
    Attention : il faut que tomcat soit installé dans TOMCAT_HOME
    Cette option désactive le mode FROM_CLONE
    Voir description pour plus de détail
    
.PARAMETER FROM_CLONE
    Reconfigure jahia sur la base d'un environnement cloné (base et filesystem jahia)
    Le couloir à appliquer est donné par le paramètre COULOIR

.PARAMETER COULOIR
    Définit la fin de l'url des sites exposés par JAHIA.
    Cette option provoque une configuration / reconfiguration des sites Apec dans JAHIA
    Pour la production la valeur est "prod"
    Ex : int1 pour cadresin1.apec.fr, loc pour cadresloc

.PARAMETER EXTERN_DOMAIN
    Définit le domaine d'accès aux sites jahia.
    Ex : apec.fr pour cadresin1.apec.fr, "" pour cadresloc
    Voir HOST_MODE pour l'installation en dev

.PARAMETER FILE_CONF_FOLDER
    Définit le dossier ou sont stocké les conf à appliquer
    En environnement de production en particulier on ne souhaite pas mettre à jour directement les conf mais les générer pour ensuite
    les mettre à jour. Cette option permet de générer les fichier dans le répertoire indiqué avec un fichier ".bat" qui fait le 
    remplacement des fichiers aux bons emplacement (dans un deuxième temps).

.PARAMETER INTERN_DOMAIN
    Définit le domaine interne apec
    Par défaut dapec.internaluse
    Voir HOST_MODE pour l'installation en dev

.PARAMETER HOST_MODE
    Indique que l'installation concerne un poste de dev et que les domaines et url externe à apec.fr sont définit dans le fichier hosts
    Cette option force INTER_DOMAIN et EXTERN_DOMAIN à vide puisque c'est le fichier hosts local 
    Cf C:\Windows\System32\drivers\etc\hosts

.PARAMETER BO_APEC_FR
    Indique que la configuration concerne le backoffice du Apec.fr ($true)
    Le BO_APEC_FR écrit dans le JCR et pilote la mise à jour du cache
    La notion de la responsabilité foncitonnel (Backoffice / Frontoffice Apec.fr) est souvent aligné avec l'architecture du cluster.
    Dans un cluster il y a un seul processing node (MASTER) et des "Slaves". On parle souvent de MASTER du cluster pour désigner le BO CMS Apec.fr.
    Quand il n'y a qu'un CMS dans les environnement projet, le même CMS sert le besoin de BO et de FO (et il n'y a pas de cluster).


.EXAMPLE
        setup_jahia.ps1 -COULOIR int1 -BO_APEC_FR True
        Configuration / Reconfiguration d'Apec.fr lorsqu'il s'agit d'une instance qui fait BO de contribution

.EXAMPLE
        setup_jahia.ps1 -INST_FROM_CLONE -COULOIR rec1
        Clonage d'un JAHIA
        Ici on reconfigure le JAHIA pour qu'il fonctionne sur un environnement que l'on installe sur REC1

.EXAMPLE
        setup_jahia.ps1 -COULOIR prod -FILE_CONF_FOLDER c:\Jahia\config_file
        Génération des fichiers de configuration JAHIA dans un le dossier "c:\Jahia\config_file" pour les mettre à jour dans une deuxième temps.
        Avec cette commande les fichiers actuel et nouveau sont réunis dans le répertoire.
        L'analyse des différences et leur mise à jour se trouve simplifié

.EXAMPLE
        setup_jahia.ps1 -INST_JAHIA_HOME "C:\Jahia\Jahia7" -COULOIR xx -EXTERN_DOMAIN "" -INTERN_DOMAIN ""
        setup_jahia.ps1 -INST_JAHIA_HOME "C:\Jahia\Jahia7" -COULOIR xx -HOST_MODE
        Configure Jahia pour un poste de dev
        "xx" est le suffixe d'une adresse qui n'est pas dans le DNS, 
        ceci implique la configuration d'un poste local, souvent on met "loc" à la place de xx
        Dans cette commande EXTERN_DOMAIN = "" évite de rajouter ".apec.fr" en fin d'url et impact toute les règle de redirection
        Dans cette commande INTERN_DOMAIN = "" implique que les url des services métier (ou d'affinité) sont définit dans le fichier hosts
        On peut utiliser l'option (peut être plus explicite) qui dit d'utiliser le fichier hosts "-HOST_MODE"


.EXAMPLE
        setup_jahia.ps1 -INST_JAHIA_HOME "C:\Jahia\JahiaVersion_x" -COULOIR xx -EXTERN_DOMAIN "" -INTERN_DOMAIN ""
        + avec le fichier "system\jahia.jar" correspondant à jahia Version_y ==> cette commande installera la "Version_y" dans C:\Jahia\JahiaVersion_x
        Cet exemple est incohérent peut être, il cherche à expliquer la surcharge du jahia installé

#>


##############################################################################
##############################################################################
##############################################################################
#
# 


        ####### #     #  #####  ####### ######     #     #####  #######
        #       ##    # #     # #     # #     #   # #   #     # #
        #       # #   # #       #     # #     #  #   #  #       #
        #####   #  #  # #       #     # #     # #     # #  #### #####
        #       #   # # #       #     # #     # ####### #     # #
        #       #    ## #     # #     # #     # #     # #     # #
        ####### #     #  #####  ####### ######  #     #  #####  #######



        #     #   ###   #     #            #     #####  #######  #####
        #  #  #    #    ##    #           ##    #     # #       #     #
        #  #  #    #    # #   #          # #          # #             #
        #  #  #    #    #  #  #            #     #####  ######   #####
        #  #  #    #    #   # #            #    #             # #
        #  #  #    #    #    ##            #    #       #     # #
         ## ##    ###   #     #          #####  #######  #####  #######



#     (ou sinon vous vous retapez la doc en français et sans les accents)
#     (... bon courage !!!)
# Pour éditer un fichier powershell je vous recommande clic droit / modifier
##############################################################################
##############################################################################
##############################################################################



##############################################################################
# 0 - INITIALISATION (lecture paramètres)
##############################################################################



param(
    [string]$COULOIR = "",
    [string]$INST_JAHIA_HOME ,
    [string]$INST_DB_URL,
    [string]$INST_DB_LOGIN ,
    [string]$INST_DB_PASSWORD ,
    [string]$INST_TOOLS_LOGIN ,
    [string]$INST_TOOLS_PASSWORD ,
    [string]$INTERN_DOMAIN = "dapec.internaluse" ,
    [String]$FILE_CONF_FOLDER ,
    [string]$EXTERN_DOMAIN = "apec.fr" ,
    [switch]$INST_FROM_CLONE,
    [String]$BO_APEC_FR = "False",
    [switch]$HOST_MODE = $false,
    [switch]$BypassQuestion # Bypass question, for test or automation purpose
)


$CFG_ASPECT_JVWEAVER_URL = "http://nexus2.apec.fr:81/nexus/service/local/repositories/Jahia-Snapshot/content/org/aspectj/aspectjweaver/1.6.11/aspectjweaver-1.6.11.jar"

Set-StrictMode -Version Latest
trap { Write-Host "ERREUR: $_" -f Red ; Write-Host "" ; Write-Output $_ ; exit 1 }


Import-Module -Force $PSScriptRoot\configuration\configuration
Import-Module -Force $PSScriptRoot\modules\nexus
Import-Module -Force $PSScriptRoot\modules\utils
Import-Module -Force $PSScriptRoot\modules\jahia_server
Import-Module -Force $PSScriptRoot\modules\jahia_website
Import-Module -Force $PSScriptRoot\modules\jahia_module
Import-Module -Force $PSScriptRoot\modules\mklink



$conf = Get-Conf



function ask_if_not_given($name, $param, $default, $example){
    Write-Host ""
    if ($param){
        Write-Host "$name has content : [$param]"
        return $param
    }
    Write-Host "$name = `"$default`" (Appuyer sur entrée pour garder cette valeur)"
    if($ByPassQuestion){
        return $default
    }
    Write-Host "Exemple de valeur : $example"
    $newvalue = Read-Host "> "
    if ($newvalue -eq ""){
        Write-Host "$name = `"$default`""
        return $default
    }
    Write-Host "New $name = `"$newvalue`""
    return $newvalue
}


# JAHIA_CATALINA_HOME is for dev purpose (several tomcat-s)
# CATALINA_HOME is for server purpose (one single tomcat)
$CATALINA_HOME = [Environment]::GetEnvironmentVariable("JAHIA_CATALINA_HOME","User")
if (-not $CATALINA_HOME){
    $CATALINA_HOME = [Environment]::GetEnvironmentVariable("CATALINA_HOME","Machine")
    if (-not $CATALINA_HOME){
        Write-Host "La variable CATALINA_HOME n'est pas définit au niveau système"
        Write-Host "(ou JAHIA_CATALINA_HOME en tant que variable utilisateur sur un poste de dev)"
        Exit
    }
}

Write-Host "CATALINA_HOME = $CATALINA_HOME"


<#
# Tentative d'utilisation de Initialize-Couloir 1/2
$inputCouloir=$COULOIR

$internDomain = $INTERN_DOMAIN
$externDomain = $EXTERN_DOMAIN

#>


if ($HOST_MODE) {
    $EXTERN_DOMAIN = ""
    $INTERN_DOMAIN = ""
}

$INPUT_COULOIR = $COULOIR
$COULOIR_DOMAIN = ""

if ( $INPUT_COULOIR -ne "" ) {
    $COULOIR_DOMAIN = "$COULOIR.$EXTERN_DOMAIN"

    If ($COULOIR -eq "prod") {
        $COULOIR= ""
        $EXTERN_DOMAIN = ".$EXTERN_DOMAIN"
        $INTERN_DOMAIN = "prod.$INTERN_DOMAIN"
        $COULOIR_DOMAIN = "$COULOIR$EXTERN_DOMAIN"
    } else {
        # We add "dot" if domain not empty
        if ($INTERN_DOMAIN -ne "") {
            $INTERN_DOMAIN = ".$INTERN_DOMAIN"
        }
        if ($EXTERN_DOMAIN -ne "") {
            $EXTERN_DOMAIN = ".$EXTERN_DOMAIN"
        } else {
            $COULOIR_DOMAIN = "$COULOIR"
        }
    }
}

<#
# Tentative d'utilisation de Initialize-Couloir 2/2
Write-Host "1 $COULOIR_DOMAIN, $INTERN_DOMAIN, $EXTERN_DOMAIN, $INPUT_COULOIR"



$couloirDomain = Initialize-Couloir ([ref]$inputCouloir) ([ref]$internDomain) ([ref]$externDomain) $HOST_MODE



Write-Host "2 $couloirDomain, $internDomain, $externDomain, $inputCouloir"

$COULOIR_DOMAIN = "$COULOIR.$externDomain"
$INTERN_DOMAIN = "$internDomain"
$EXTERN_DOMAIN = "$externDomain"
$COULOIR = "$INPUT_COULOIR"

Write-Host "3 $COULOIR_DOMAIN, $INTERN_DOMAIN, $EXTERN_DOMAIN, $INPUT_COULOIR"

exit

#>

if ($FILE_CONF_FOLDER -ne "") {
    New-Item -ItemType Directory -Force "$FILE_CONF_FOLDER" > $null
    Start-FileConf("$FILE_CONF_FOLDER")
}


if ($INPUT_COULOIR -eq "prod" -and $INST_FROM_CLONE) {
    Write-Host "On ne peut pas cloner un environnement projet pour le mettre sur la prod" -f Red
    Write-Host "Cette opération n'est pas garantie" -f Red
    pause
}

$BO_APEC_FR_TRUE_FALSE=$BO_APEC_FR


##############################################################################
# 1 - JAHIA INSTALL OU CLONAGE (opérations à froid)
##############################################################################
# Section dedicated to system operation



# We run an install on catalina installed elsewhere 
if ($INST_JAHIA_HOME) {


    Write-Host "Installation JAHIA, la base de donnée de jahia doit être vide (sauf en cas d'install d'un noeud de cluster)" -f Red
    Write-Host "... aussi : on suppose que Jahia est arrêté !" -f Red
    Write-Host "... aussi : on suppose que tomcat est installé dans CATALINA_HOME !" -f Red


    # Setup JAHIA_HOME _______________________________________________________
    Write-Host "- Set JAHIA_HOME = $INST_JAHIA_HOME ... " -NoNewline
    $JAHIA_HOME = $INST_JAHIA_HOME
    Set-Env "JAHIA_HOME" $JAHIA_HOME -Scope "User"
    $env:JAHIA_HOME = $JAHIA_HOME
    Write-Host "done" -f Green

    # Install JAHIA __________________________________________________________
    # If upgrading JAHIA you should check xml installer content changes
    $tmp_path_build = [System.IO.Path]::GetTempFileName() + ".xml"

    $install_template= "$PSScriptRoot\system\jahia_install_oracle.template.xml"
    $init_install_template = $install_template
    if ("$EXTERN_DOMAIN" -eq "") {
        # We use a dedicated install template for local install
        $install_template= "$PSScriptRoot\system\jahia_install_derby.template.xml"
    }

    if (Test-Path "$PSScriptRoot\system\jahia.xml") {
        $install_template= "$PSScriptRoot\system\jahia.xml"
    }
    $init_install_template = $install_template
    Write-Host "- Use Jahia install template : $init_install_template "
    

    # Check if install_template file must be parsed
    $build_content = gc $install_template | Out-String

    if (Test-FileContains $install_template "JAHIA_HOME") {
        $build_content = $build_content -replace "JAHIA_HOME", $JAHIA_HOME
    }

    if (Test-FileContains $install_template "SCRIPT_ROOT") {
        $build_content = $build_content -replace "SCRIPT_ROOT", $PSScriptRoot
    }

    if (Test-FileContains $install_template "DB_URL") {
        Write-Host "- Saisie des informations de reconfiguration du fichier $init_install_template ..." 
        # VARIABLE                          DISPLAY NAME       PASSED PARAM.      DEFAULT VALUE           EXAMPLE
        $DB_URL         = ask_if_not_given "DATABASE URL"      $INST_DB_URL       $conf['db_url']         "jdbc:oracle:thin:@devdb.apec.fr:1521:INTSOCLE, jdbc:derby:directory:jahia;create=true"
        $DB_LOGIN       = ask_if_not_given "DATABASE LOGIN"    $INST_DB_LOGIN     $conf['db_username']    "INT1_JAHIA"
        $DB_PASSWORD    = ask_if_not_given "DATABASE PASSWORD" $INST_DB_PASSWORD  $conf['db_password']    "INT1_JAHIA"

        $build_content = $build_content -replace "DB_URL", $DB_URL
        $build_content = $build_content -replace "DB_LOGIN", $DB_LOGIN
        $build_content = $build_content -replace "DB_PASSWORD", $DB_PASSWORD
        Write-Host ""
    }

    # build_content has been modified
    if ($build_content -ne (gc $install_template)) {
        Set-Content -Path $tmp_path_build -Value $build_content
        $install_template = $tmp_path_build
        Write-Host "- Fichier de configuration modifié dans $install_template"
    }

    $install_jar = "$PSScriptRoot\system\jahia.jar"
    $init_install_jar = $install_jar

    if (Test-Path "$install_jar") {
        Write-Host "- Utilisation du fichier d'installation $install_jar ... " -NoNewline
        Write-Host "done" -f Green 
     } else {
        $jahia_url = "https://www.jahia.com/public/digitalfactory-7.1.0/bin/DigitalFactory-CommunityDistribution-7.1.0.0-r52740.jar" # 7.1 Community        
        $jahia_url = "https://www.jahia.com/downloads/jahia/digitalfactory7.0.0/DigitalFactory-EnterpriseDistribution-7.0.0.5-r52368.3363.jar" # 7.0.0.5 previous version
        $jahia_url = "https://www.jahia.com/downloads/jahia/digitalfactory7.1.0/DigitalFactory-EnterpriseDistribution-7.1.0.0-r52740.3425.jar" # 7.1 Current Version

        
        Write-Host "- Download jahia jar $jahia_url ... " -NoNewline
        (New-Object System.Net.WebClient).DownloadFile($jahia_url, $install_jar)
        Write-Host "done" -f Green         
        Write-Host "- Fichier enregistré sous $install_jar"
     }


    Write-Host ""
    Write-Host "Confirmez l'installation de jahia : $init_install_jar $init_install_template puis déploiement dans le tomcat $CATALINA_HOME"  -b DarkYellow -f Black
    pause
    Write-Host "DEBUT installation de JAHIA dans $INST_JAHIA_HOME"

    if(Test-Path $JAHIA_HOME){
        Write-Host "- Nettoyage de l'ancien JAHIA_HOME $JAHIA_HOME ... " -NoNewline
        Remove-Item -Recurse -Force $JAHIA_HOME
        Write-Host "done" -f Green
    }

    if($CATALINA_HOME -and (Test-Path $JAHIA_HOME)){
        Write-Host "Tomcat installé dans $CATALINA_HOME, on vient de purger $JAHIA_HOME mais pas le contenu éventuel dans tomcat" -BackgroundColor DarkYellow -ForegroundColor Black
    }


    & $env:JAVA_HOME\bin\java -jar $install_jar $install_template

    
    if (Test-Path $tmp_path_build) {

        Remove-Item $tmp_path_build
    }
    Write-Host "FIN installation de JAHIA"

    # Configuration de JAHIA dans le tomcat installé _________________________
    # Voir Configuration and fine tuning - Digital Factory 7.1.0.0
    Write-Host "DEBUT Reconfiguration de tomcat installé dans $CATALINA_HOME"
    Write-Host "- Copie $JAHIA_HOME\tomcat\lib\*.* --> $CATALINA_HOME\lib ... " -NoNewline
    Copy-Item -Recurse -Force "$JAHIA_HOME\tomcat\lib\*.*" "$CATALINA_HOME\lib"
    Write-Host "done" -f Green
    if (-not (Test-Path "$CATALINA_HOME\webapps\tomcat-root")) {
        Write-Host "- Renomage $CATALINA_HOME\webapps\ROOT --> $CATALINA_HOME\webapps\tomcat-root ... " -NoNewline
        Rename-Item "$CATALINA_HOME\webapps\ROOT" "$CATALINA_HOME\webapps\tomcat-root"
        Write-Host "done" -f Green
    } 
    
    if ((Test-Path "$CATALINA_HOME\webapps\ROOT") -and (Test-Path "$CATALINA_HOME\webapps\tomcat-root")) {
        Write-Host "- Remove $CATALINA_HOME\webapps\ROOT  ... " -NoNewline
        Remove-Item -Recurse -Force $CATALINA_HOME\webapps\ROOT
        Write-Host "done" -f Green
    }
    Write-Host "- Copie $JAHIA_HOME\tomcat\webapps --> $CATALINA_HOME\webapps ... " -NoNewline
    Copy-Item -Recurse -Force "$JAHIA_HOME\tomcat\webapps\ROOT" "$CATALINA_HOME\webapps"
    Write-Host "done" -f Green

    Remove-Item -Recurse -Force -ErrorAction:SilentlyContinue "$JAHIA_HOME\tomcat"

    Write-Host "FIN Reconfiguration de tomcat"

}




# We reconfigure a cloned version STEP 1/2
if ($INST_FROM_CLONE) {
    Write-Host "Reconfiguration d'une copie de JAHIA"

    $JAHIA_HOME=$env:JAHIA_HOME
    if ($JAHIA_HOME -eq ""){
        Assert-OrThrow ("$JAHIA_HOME" -ne "") "JAHIA_HOME n'est pas définit en tant que variable user"

        Exit
    } else {
        Write-Host "JAHIA_HOME = $JAHIA_HOME"
    }

    # Stop Jahia
    Write-Host ''
    Write-Host "Merci d'arrêter JAHIA" -f Red -b White
    pause
    #Stop-Jahia
    Write-Host ''


    $DB_URL         = ask_if_not_given "DATABASE URL"      $INST_DB_URL         $conf['db_url']         "jdbc:oracle:thin:@devdb.apec.fr:1521:INTSOCLE, jdbc:derby:directory:jahia;create=true"
    $DB_LOGIN       = ask_if_not_given "DATABASE LOGIN"    $INST_DB_LOGIN       $conf['db_username']    "INT1_JAHIA"
    $DB_PASSWORD    = ask_if_not_given "DATABASE PASSWORD" $INST_DB_PASSWORD    $conf['db_password']    "INT1_JAHIA"


    # Database config ________________________________________________________
    Write-Host "Reconfiguration de la connexion à la base de données ... " -NoNewline

    $context_xml = Find-FirstExistingPath @(
        "$CATALINA_HOME\webapps\ROOT\META-INF\context.xml"
    )
    $content = cat -Encoding UTF8 $context_xml

    $content = $content -replace "username=`"[^`"]*`"","username=`"$DB_LOGIN`""
    $content = $content -replace "password=`"[^`"]*`"","password=`"$DB_PASSWORD`""
    $content = $content -replace "url=`"[^`"]*`"","url=`"$DB_URL`""

    if ("$DB_URL" -match "oracle"){
        $content = $content -replace "driverClassName=`"[^`"]*`"","driverClassName=`"oracle.jdbc.OracleDriver`""
        $content = $content -replace "`"validationQuery=`"values(1)`"","validationQuery=`"select 1 from dual`""
    } elseif ("$DB_URL" -match "derby"){
        $content = $content -replace "driverClassName=`"[^`"]*`"","driverClassName=`"org.apache.derby.jdbc.EmbeddedDriver`""
        $content = $content -replace "`"validationQuery=`"values(1)`"","validationQuery=`"values(1)`""
    } else {
        Write-Error "!!! URL format not known !!!"
        exit
    }

    $content | Set-Content -Encoding UTF8 $context_xml

    Write-Host "done" -f Green


    # Clean copy of JAHIA ____________________________________________________
    Write-Host "- Remove logs ... " -NoNewline
    Clear-JahiaLog
    Write-Host "done" -f Green

    Write-Host "- Remove tomcat work ... " -NoNewline
    Remove-Item -Recurse -Force $CATALINA_HOME\Work\Catalina
    Write-Host "done" -f Green

    Write-Host "- Suppression $JAHIA_HOME\digital-config-data\repository\workspaces\default\lock ... " -NoNewline
    if (Test-Path $JAHIA_HOME\digital-config-data\repository\workspaces\default\lock) {
        Remove-Item -Recurse -Force $JAHIA_HOME\digital-config-data\repository\workspaces\default\lock
    }
    Write-Host "done" -f Green
    Write-Host "- Suppression $JAHIA_HOME\digital-config-data\repository\workspaces\live\lock ... " -NoNewline
    if (Test-Path $JAHIA_HOME\digital-config-data\repository\workspaces\live\lock) {
        Remove-Item -Recurse -Force $JAHIA_HOME\digital-config-data\repository\workspaces\live\lock
    }

    # Index files are not cleaned (see fine tuning documentation for explanation).

    Write-Host "done" -f Green

    # Reconfigure copy _______________________________________________________
    # Cette opération est nécessaire en cas de copie de la prod
    Write-Host "Copie de la clé de licence"
    Write-Host "  $PSScriptRoot\system\license.xml --> $JAHIA_HOME\digital-config-data\jahia\ ... " -NoNewline
    Copy-Item -Recurse -Force "$PSScriptRoot\system\license.xml" "$JAHIA_HOME\digital-config-data\jahia\"
    Write-Host "done" -f Green


    Write-Host "La reconfiguration suite au clonage se poursuit aprés le démarrage de JAHIA"
}


if ($INST_FROM_CLONE -or $INST_JAHIA_HOME) {

    # Configure LDAP access  _________________________________________________
    Write-Host "Configuration de l'accès LDAP ... " -NoNewline
    Copy-Item "$PSScriptRoot\system\org.jahia.services.usermanager.ldap-config.cfg" "$JAHIA_HOME\digital-factory-data\modules"
    # le fichier est déposé automatiquement si le fichier xml de configuration de l'installeur est correct
    # Copy-Item "$PSScriptRoot\system\ldap-3.0.0.jar" "$JAHIA_HOME\digital-factory-data\modules"
    Write-Host "$JAHIA_HOME\digital-factory-data\modules\org.jahia.services.usermanager.ldap-config.cfg" -f green
    Write-Host " - En production il faut corriger le fichier" -b Green -f White

    # Configure CA_APEC_RECETTE Cerificate ___________________________________
    # Add by default self signed APEC test CA certificate silently (if certificate store has the default password).
    # I did not manage to get powershell to prompt the user ... i then force password and remove prompt ... (DGL)
    Write-Host "Import CA_APEC_RECETTE (si installation sur environnement projet, pour la prod ce certificat est inutile) ... "
    Write-Host "Dans une fenetre CMD entrez la commande suivante ..."
    Write-Host "$env:JAVA_HOME\jre\bin\keytool.exe" -keystore $env:JAVA_HOME\jre\lib\security\cacerts -import -file .\system\ca.apec.fr.crt -alias CA_APEC_RECETTE -noprompt -storepass changeit | Out-Null
    Write-Host ""

         
    Write-Host "- Reconfiguration $PSScriptRoot\system\catalina.properties --> $CATALINA_HOME\conf\catalina.properties ... " -NoNewline
    $tempVal = $JAHIA_HOME -replace '\\' , '\\'
    Expand-SharpedString "$PSScriptRoot\system\catalina.properties" "$CATALINA_HOME\conf\catalina.properties" 'JAHIA_HOME' "$tempVal"
    Write-Host "done" -f Green

    Write-Host "- Reconfiguration $PSScriptRoot\system\setenv.bat --> $CATALINA_HOME\bin\setenv.bat ... " -NoNewline
    Expand-SharpedString "$PSScriptRoot\system\setenv.bat" "$CATALINA_HOME\bin\setenv.bat" 'JAHIA_HOME' "$JAHIA_HOME"
    Write-Host "done" -f Green

    Write-Host "- Reconfiguration $PSScriptRoot\system\server.xml --> $CATALINA_HOME\conf\ ... " -NoNewline
    Copy-Item -Recurse -Force "$PSScriptRoot\system\server.xml" "$CATALINA_HOME\conf\"
    Write-Host "done" -f Green

    # Patch des lib OJDBC ____________________________________________________
    Write-Host "DEBUT Reconfiguration du connecteur oracle installé dans $CATALINA_HOME"
    Write-Host "- Copie system\orai18n-12.1.0.2.jar --> $CATALINA_HOME\lib ... " -NoNewline
    Copy-Item -Recurse -Force "$PSScriptRoot\system\orai18n-12.1.0.2.jar" "$CATALINA_HOME\lib"
    Write-Host "done" -f Green
    Write-Host "- Copie system\ojdbc7-12.1.0.2.jar --> $CATALINA_HOME\lib ... " -NoNewline
    Copy-Item -Recurse -Force "$PSScriptRoot\system\ojdbc7-12.1.0.2.jar" "$CATALINA_HOME\lib"
    Write-Host "done" -f Green
    Write-Host "- Remove $CATALINA_HOME\lib\orai18n-12.1.0.1.jar  (livré avec JAHIA) ... " -NoNewline
    Remove-Item -Recurse -Force -ErrorAction:SilentlyContinue $CATALINA_HOME\lib\orai18n-12.1.0.1.jar
    Write-Host "done" -f Green
    Write-Host "- Remove $CATALINA_HOME\lib\ojdbc6-12.1.0.1.jar  (livré avec JAHIA) ... " -NoNewline
    Remove-Item -Recurse -Force -ErrorAction:SilentlyContinue $CATALINA_HOME\lib\ojdbc6-12.1.0.1.jar
    Write-Host "done" -f Green
    Write-Host "FIN Reconfiguration du connecteur oracle"

}

##############################################################################
# 2 - APEC.FR CONFIGURATION
##############################################################################
# Section dedicated to Apec.fr configuration




if ($INPUT_COULOIR  -ne "") {

    function replace_variable_set_in_current_file(){
        # COULOIR.DOMAIN_APEC n'est pas encadré par des # (raisons historiques)
        Rename-FileConf "COULOIR.DOMAIN_APEC"  $COULOIR_DOMAIN
        Expand-FileConf "COULOIR.DOMAIN_APEC"  $COULOIR_DOMAIN
        Expand-FileConf "COULOIR"  $COULOIR
        Expand-FileConf "INTERN_DOMAIN"  "$INTERN_DOMAIN"
        Expand-FileConf "EXTERN_DOMAIN"  "$EXTERN_DOMAIN"
        Expand-FileConf "BO_APEC_FR_TRUE_FALSE"  "$BO_APEC_FR_TRUE_FALSE"
    }

    $JAHIA_HOME=$env:JAHIA_HOME
    if ($JAHIA_HOME -eq ""){
        Assert-OrThrow ("$JAHIA_HOME" -ne "") "JAHIA_HOME n'est pas définit en tant que variable user"
        Exit
    } else {
        Write-Host "JAHIA_HOME = $JAHIA_HOME"
    }

    
    #for special purpose, check if we are on dev env or not
    $is_in_dev = ("$EXTERN_DOMAIN" -eq "") -and ("$INTERN_DOMAIN" -eq "")

    if ($is_in_dev) {
        Write-Host "#### MODE DEV ACTIF ###" -b DarkYellow -f Black
    }


    Write-Host "Vous devrez installer les modules bootstrap3-core-1.4.0 et bootstrap3-components-1.2.1 à la main via l'interface !!" -f Red



    # Suppression de l'utilisation des option d'environnement en doublon avec setenv.bat
    # Set-Env "CATALINA_OPTS" "-DapecConfiguration=$JAHIA_HOME\digital-factory-config\jahia\jahia-modules-apec.properties" -Scope "User"



    # Change jahia properties ________________________________________________
    if (Edit-FileConf "$JAHIA_HOME\digital-factory-config\jahia\jahia.properties" UTF8 "PROPERTIES") {
        Update-FileConf "felix.gogo.shell.telnet.port" "2019"
        Update-FileConf "urlRewriteSeoRulesEnabled" "true"
        Update-FileConf "urlRewriteRemoveCmsPrefix" "true"
        Update-FileConf "urlRewriteUseAbsoluteUrls" "true"
        Update-FileConf "jahia.jcr.maxNameSize" "256"
        Update-FileConf "jahia.dm.thumbnails.enabled" "true"
        Update-FileConf "storeAggregatedPageForGuest" "false"
        # Doit être égal à (nb Thread dans server.xml  / 3)
        Update-FileConf "maxModulesToGenerateInParallel" "800"
        Update-FileConf "moduleGenerationWaitTime" "20000"
        Update-FileConf "operatingMode" "production"
        Update-FileConf "sessionExpiryTime" "30"
        Save-FileConf "$JAHIA_HOME\digital-factory-config\jahia\jahia.properties"
   }    




    # Change jahia cache key mechanism ___________________________________________
    Copy-FileConf "$PSScriptRoot\template\apec-jahia-specific.jar" "$CATALINA_HOME\webapps\ROOT\WEB-INF\lib\apec-jahia-specific.jar"
    Copy-FileConf "$PSScriptRoot\template\applicationcontext-custom.xml" "$JAHIA_HOME\digital-factory-config\jahia\applicationcontext-custom.xml"

    # Change log level configuration _________________________________________
    Copy-FileConf "$PSScriptRoot\template\log4j.xml" "$JAHIA_HOME\digital-factory-config\jahia\log4j.xml"

    # Configuration de la Gestion des exceptions Rest dans spring-mvc
    Copy-FileConf "$PSScriptRoot\template\servlet-applicationcontext-renderer-custom.xml" "$JAHIA_HOME\digital-factory-config\jahia\servlet-applicationcontext-renderer-custom.xml"

    # Setup french analyzer (Pour la recherche éditoriale) _______________________
    if (Edit-FileConf "$JAHIA_HOME\digital-factory-data\repository\workspaces\default\workspace.xml" UTF8 "XML") {
        Update-FileConf "/Repository/Workspace/SearchIndex/param[@name='analyzer']/@value" "org.apache.lucene.analysis.fr.FrenchAnalyzer"
        Save-FileConf "$JAHIA_HOME\digital-factory-data\repository\workspaces\default\workspace.xml"
    }
    if (Edit-FileConf "$JAHIA_HOME\digital-factory-data\repository\workspaces\live\workspace.xml" UTF8 "XML") {
        Update-FileConf "/Repository/Workspace/SearchIndex/param[@name='analyzer']/@value" "org.apache.lucene.analysis.fr.FrenchAnalyzer"
        Save-FileConf "$JAHIA_HOME\digital-factory-data\repository\workspaces\live\workspace.xml"
    }
    if (Edit-FileConf "$CATALINA_HOME\webapps\ROOT\WEB-INF\etc\repository\jackrabbit\repository.xml" UTF8 "XML") {
        Update-FileConf "/Repository/Workspace/SearchIndex/param[@name='analyzer']/@value" "org.apache.lucene.analysis.fr.FrenchAnalyzer"
        Save-FileConf "$CATALINA_HOME\webapps\ROOT\WEB-INF\etc\repository\jackrabbit\repository.xml"
    }

    
    
    # Config rewrite rule ________________________________________________________
    if (Edit-FileConf "$PSScriptRoot\template\seo-urlrewrite.template.xml" Default "UTF8") {
        replace_variable_set_in_current_file
        Save-FileConf "$CATALINA_HOME\webapps\ROOT\WEB-INF\etc\config\seo-urlrewrite.xml"
    }

    # Install error page _________________________________________________________
    Copy-FileConf "$PSScriptRoot\template\error_404.jsp" "$CATALINA_HOME\webapps\ROOT\errors\error_404.jsp"
    Copy-FileConf "$PSScriptRoot\template\errors" "$CATALINA_HOME\webapps\ROOT\"




    # Mise à jour du fichier de configuration ____________________________________
    if (Edit-FileConf "$PSScriptRoot\template\jahia-modules-apec.properties" UTF8 "PROPERTIES") {
        replace_variable_set_in_current_file
        Save-FileConf "$JAHIA_HOME\digital-factory-config\jahia\jahia-modules-apec.properties"
    }

    # Anotations pour les habilitations __________________________________________
    #Write-Host "- Aspectjweaver ..." -NoNewline
    $jar_url = $CFG_ASPECT_JVWEAVER_URL
    $jar_name = [System.IO.Path]::GetFileName($jar_url)
    $goal_path = "$CATALINA_HOME\lib"
    if(Test-Path "$PSScriptRoot\template\$jar_name"){
        Copy-Item "$PSScriptRoot\template\$jar_name" "$goal_path"
    } else {
        $(New-Object System.Net.WebClient).DownloadFile($jar_url, "$PSScriptRoot\template\$jar_name")   
    }
    Copy-FileConf "$PSScriptRoot\template\$jar_name" "$goal_path\$jar_name"

    # Temps de cache par défaut des pages Jahia __________________________________
    if (Edit-FileConf "$CATALINA_HOME\webapps\ROOT\WEB-INF\classes\ehcache-jahia-html.xml" UTF8 "XML") {
        Update-FileConf "/ehcache/cache[@name='HTMLCache']/@timeToIdleSeconds" "120"
        New-FileConf "timeToLiveSeconds" "120" "/ehcache/cache[@name='HTMLCache']"
        Save-FileConf "$CATALINA_HOME\webapps\ROOT\WEB-INF\classes\ehcache-jahia-html.xml"
    }

    # Pourla fonctionnalité d'impression du site _________________________________
    if (Edit-FileConf "$CATALINA_HOME\webapps\ROOT\WEB-INF\scripts\ajaxResources.groovy" Default "GROOVY") {
        Rename-FileConf "screen" "all"
        Save-FileConf "$CATALINA_HOME\webapps\ROOT\WEB-INF\scripts\ajaxResources.groovy"
    }
     


    if (Edit-FileConf "$CATALINA_HOME\webapps\ROOT\WEB-INF\scripts\resources.groovy" Default "GROOVY") {
        Rename-FileConf "screen" "all"
        Save-FileConf "$CATALINA_HOME\webapps\ROOT\WEB-INF\scripts\resources.groovy"
    }

    # Pour le health check de NGINX+ _____________________________________________
    Copy-FileConf "$PSScriptRoot\template\ping.jsp" "$CATALINA_HOME\webapps\ROOT\ping.jsp"


    # Configurer les fichier hosts _______________________________________________
    Write-Host "Contournement dans C:\Windows\System32\drivers\etc\hosts" 
    #Write-Host "Definir <IP_NGINX> cache$COULOIR_DOMAIN"
    Write-Host "Definir <IP_NGINX> cadres$COULOIR_DOMAIN jd$COULOIR_DOMAIN recruteurs$COULOIR_DOMAIN www$COULOIR_DOMAIN presse$COULOIR_DOMAIN perso$COULOIR_DOMAIN edito$COULOIR_DOMAIN "

    # Configurer le fichier nginx ________________________________________________
    if (Edit-FileConf "$PSScriptRoot\template\nginx.conf.template" Default "PROPERTIES") {
        replace_variable_set_in_current_file
        Save-FileConf "$PSScriptRoot\nginx.conf"
    }



    ##############################################################################
    # 2.1 - JAHIA INSTALL & CONFIGURATION (DEV_MODE)
    ##############################################################################
    # Section dedicated to developper environment configuration





    if($is_in_dev){
        Write-Host "La configuration dev va être appliquée"
        Write-Host "Le répertoire $JAHIA_HOME\tomcat va être supprimé et replacée par un lien vers $CATALINA_HOME"
        pause

        # Configure Debug mode in tomcat _________________________________________
        Write-Host "- (host_mode) Setting debug in $CATALINA_HOME\bin\startup.bat ... " -NoNewline
            $su_content = Get-Content "$CATALINA_HOME\bin\startup.bat" | Out-String
            $su_content = $su_content -replace  'call "%EXECUTABLE%" start %CMD_LINE_ARGS%', 'call "%EXECUTABLE%" jpda start %CMD_LINE_ARGS%'
            $su_content | Set-Content "$CATALINA_HOME\bin\startup.bat"
        Write-Host "done" -f Green

        # Change jahia properties ________________________________________________
        Write-Host "- (host_mode) Changing jahia.properties to development ... " -NoNewline

        $jahia_properties = "$JAHIA_HOME\digital-factory-config\jahia\jahia.properties"

        (cat -Encoding UTF8 $jahia_properties) | %{
                switch -Regex ($_){
                    'mode\s*='{ return "operatingMode = development" }
                    default { return $_ }
                }
            } | Set-Content -Encoding UTF8 $jahia_properties


        Write-Host "done" -f Green

        # Lower memory usage _________________________________________________
        Write-Host "- (host_mode) Set memory footprint 4Go --> 2Go ... " -NoNewline
            $se_content = gc "$CATALINA_HOME\bin\setenv.bat" | Out-String
            $se_content = $se_content -replace  '4096m', '2048m'
            $se_content | Set-Content "$CATALINA_HOME\bin\setenv.bat"
        Write-Host "done" -f Green


        # Change log configuration ___________________________________________
        Write-Host "- (host_mode) Change logfile configuration  ... " -NoNewline
        Remove-Item -Recurse -Force -ErrorAction:SilentlyContinue "$JAHIA_HOME\digital-factory-config\jahia\log4j.xml"
        Write-Host "done" -f Green


        # insert tomcat ______________________________________________________
        if (Test-Symlink -Path $JAHIA_HOME\tomcat) {
            Write-Host "- (host_mode) $JAHIA_HOME\tomcat est déjà un lien symbolique vers $CATALINA_HOME : aucune modification"
            Write-Host "    (Supprimer le lien symbolique pour le recréer si besoin)"
        } else {
            Remove-Item -Recurse -Force -ErrorAction:SilentlyContinue "$JAHIA_HOME\tomcat"
            New-SymLink "$JAHIA_HOME\tomcat" "$CATALINA_HOME"
        }
        Copy-Item -ErrorAction:SilentlyContinue $PSScriptRoot\template\startDigitalFactory.bat $JAHIA_HOME
        Copy-Item -ErrorAction:SilentlyContinue $PSScriptRoot\template\stopDigitalFactory.bat $JAHIA_HOME
    
        # Configure hosts file _______________________________________________
        Write-Host "- (host_mode) Configuration host ... " -NoNewline
        $host_path = "$env:SystemRoot\System32\drivers\etc\hosts"
        $host_content = @(gc $host_path)

        $host_goal = @{
            "cadres$COULOIR"="127.0.0.1";
            "jd$COULOIR"="127.0.0.1";
            "recruteurs$COULOIR"="127.0.0.1";
            "www$COULOIR"="127.0.0.1";
            "presse$COULOIR"="127.0.0.1";
            "wsm$COULOIR"="192.168.14.66";
            "wsmrec"="192.168.14.67";
        }
    

        foreach ($h in $host_goal.GetEnumerator() | Sort-Object value, key) {
            # remove path from original
            $host_content = $host_content | ?{ "$_ " -notmatch "\s$($h.Key)\s" }
            # add to file end
            $line = "$($h.Value)`t$($h.Key)"
            $host_content += $line
        }

        $host_content | Set-Content $host_path
        Write-Host "done" -f Green
    }



}


##############################################################################
# 1 - JAHIA INSTALL OU CLONAGE (opérations à chaud)
##############################################################################
# Section dedicated to system operation

# We reconfigure a cloned version STEP 2/2
if ($INST_FROM_CLONE) {


    $JAHIA_HOME=$env:JAHIA_HOME


    # Stop Jahia
    Write-Host ''
    Write-Host "Merci de démarrer JAHIA complètement"  -f Red -b White
    pause
    #Start-Jahia
    Write-Host ''

    Write-Host "Poursuite de l'opération de clonage"  

    $TOOLS_LOGIN    = ask_if_not_given "TOOLS LOGIN"       $INST_TOOLS_LOGIN    $conf['tools_login']    "jahia"
    $TOOLS_PASSWORD = ask_if_not_given "TOOLS PASSWORD"    $INST_TOOLS_PASSWORD $conf['tools_password'] "password"
    

$code = @'
    def path = "<PATH>"

    try {

        def sites = session.getNode('/sites')
        def cadres = session.getNode('/sites/cadres')

        log.info "Changing [${sites}].defaultSite for [${cadres}]"
        sites.setProperty('j:defaultSite', cadres)

        for (name in ['cadres', 'jd', 'presse', 'recruteurs', 'www', 'perso']){
            try {
                def cur_node = session.getNode("/sites/${name}")
                def new_serverName = "${name}${path}"
                def old_serverName = cur_node.getProperty('j:serverName').getString()

       	        log.info "Changing [${cur_node}].serverName from [${old_serverName}] to ${new_serverName}"
                cur_node.setProperty('j:serverName', new_serverName)

            } catch(PathNotFoundException e){
                log.info "node [${name}] not found"
                continue
            }

        }

        log.info "commit"
        session.save()

    } catch(PathNotFoundException e){
        log.info "No site found"

    }
'@

    Import-Module -Force $PSScriptRoot\modules\jahia_website
    $code = $code -replace '<PATH>', $COULOIR_DOMAIN


    $jcr_cred2 = @($TOOLS_LOGIN, $TOOLS_PASSWORD);


    try {
        Request-JahiaToolsConsole $jcr_cred2 'default' $code
    } catch {
        Write-Host "Erreur lors de la connexion à la console Jahia Tools pour la configuration du site à publier: $_" -f red
    }


    # Reconfigure live site if any
    try {
        # For now, the live execution of this make the server goes Stackoverflow !
        Request-JahiaToolsConsole $jcr_cred2 'live' $code
    } catch {
        Write-Host "Erreur lors de la connexion à la console Jahia Tools pour la configuration du site publié: $_" -f red
    }



}

if ($FILE_CONF_FOLDER -ne "") {
    Stop-FileConf("$FILE_CONF_FOLDER")
}

Write-Host "Terminé !!!" -f Green

