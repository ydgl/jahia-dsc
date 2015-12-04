
$lesnodes = @{ 
    "jahia" = "cms2int2.pprod-apec.fr"  ;
    "jahia-master" = "cms1int2.pprod-apec.fr" , "cms3int2.pprod-apec.fr" ;
    "nginx" = "nginx1" ;
    "phantom" = "ph1", "ph2", "ph3"
    }


function getNodes($type) {

    #TODO error on duplicate

    return $lesnodes[$type]

}