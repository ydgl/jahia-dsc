
$lesnodes = @{ 
    "jahia" = "localhost" ;
    "jahia-master" = "localhost2", "localhostm" ;
    "nginx" = "nginx1" ;
    "phantom" = "ph1", "ph2", "ph3"
    }


function getNodes($type) {

    #TODO error on duplicate

    return $lesnodes[$type]

}