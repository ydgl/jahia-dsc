rem ---------------------------------------------------------------------------
rem Digital Factory settings
rem ---------------------------------------------------------------------------

Rem A NE PAS mettre dans la config de service (tomcat8w)
set CATALINA_OPTS=%CATALINA_OPTS% -server 

Rem A mettre dans la config de service (tomcat8w) dans onglet Java / zone "Java options". Mettre une option par ligne.
set CATALINA_OPTS=%CATALINA_OPTS%  -Dsun.io.useCanonCaches=false -verbose:gc -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintConcurrentLocks -Djava.net.preferIPv4Stack=true -DapecConfiguration="%JAHIA_HOME%\digital-factory-config\jahia\jahia-modules-apec.properties"

rem UNIQEMENT POUR UN POSTE DE DEV A mettre dans la config de service (tomcat8w) dans onglet Java / zone "Java options"
set CATALINA_OPTS=%CATALINA_OPTS% -Dderby.system.home="%JAHIA_HOME%\digital-factory-data\dbdata"

Rem A mettre dans la config de service (tomcat8w) dans onglet Java / zone "Initial (Xms) / Maximum (Xmx)" memory pool
set CATALINA_OPTS=%CATALINA_OPTS%  -Xms4096m -Xmx4096m

