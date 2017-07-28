@echo off
echo programme de dev pour reinitialiser un environnement avec un tomcat vierge pour tester les déploiement jahia
echo pour que cela fonctionnement bien il faut que tomcat "vierge" soit installé quelque part
echo je vais supprimer jahia dans %JAHIA_HOME%, et tomcat dans %JAHIA_CATALINA_HOME%
echo ensuite je restaure le tomcat initial qui doit être dispo dans le dossier : %JAHIA_CATALINA_HOME% - Source
echo 
pause
echo c est bien sûr ?
pause
rmdir /s /q "%JAHIA_HOME%"
rmdir /s /q "%JAHIA_CATALINA_HOME%"
xcopy /Y /E /I "%JAHIA_CATALINA_HOME% - Source" "%JAHIA_CATALINA_HOME%"
pause
