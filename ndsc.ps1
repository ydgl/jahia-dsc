<#
Version evoluée à travailler
dscc.ps1 -stage <name> -nodeType master -nodeName hostmaster -nodeType slave -nodeName host2,host3 \
    -nodeType nginx -nodeName host4,host5 -nodeType phantom -nodeName host6,host7,host8 -assembly <assembly> -stateSequence conf1,conf2,conf3,...

    Format des fichiers de config nc_<nodeName>_<stateName>_<stage>_<nodeType>.ps1
    Les variable peuvent être   # : Première valeur
                                + : Incrément du début à la fin
                                - : Décrémente de la fin au début


#>