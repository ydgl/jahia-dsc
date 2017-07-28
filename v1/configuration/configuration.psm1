
Set-StrictMode -Version Latest

function Get-Conf( [string] $computer_name = $env:COMPUTERNAME){

    $non_value = '<no value>'
   

    switch -regex ($computer_name) {

        "CMSINT1" { #int1
            return @{
                'db_username'='INT1_JAHIA';
                'db_password'='INT1_JAHIA';
                'db_url'='jdbc:oracle:thin:@scsdrst01.dapec.internaluse:1521:INTSOCLE';
                'jahia_cred'=@('root', 'monpassword');
                'tools_login'='jahia';
                'tools_password'='monpassword';
            }
        }

        "CMSINT2" { #int2
            return @{
                'db_username'='INT2_JAHIA';
                'db_password'='INT2_JAHIA';
                'db_url'='jdbc:oracle:thin:@scsdrst01.dapec.internaluse:1521:INTSOCLE';
                'jahia_cred'=@('root', 'monpassword');
                'tools_login'='jahia';
                'tools_password'='monpassword';
            }
        }

        "CMSREC1" { #rec1
            return @{
                'db_username'='REC1_JAHIA';
                'db_password'='REC1_JAHIA';
                'db_url'='jdbc:oracle:thin:@scsdrst01.dapec.internaluse:1521:RECSOCLE';
                'jahia_cred'=@('root', 'monpassword');
                'tools_login'='jahia';
                'tools_password'='monpassword';
            }
        }

        "CMSHOM1" { #Homologation
            return @{
                'db_username'='HOM1_JAHIA';
                'db_password'='HOM1_JAHIA';
                'db_url'='jdbc:oracle:thin:@scsdrst01.dapec.internaluse:1521:HOMSOCLE';
                'jahia_cred'=@('root', 'monpassword');
                'tools_login'='jahia';
                'tools_password'='monpassword';
            }
        }

        "P[O,C][0-9]+" { #personal computer
            return @{
                'db_username'='';
                'db_password'='';
                'db_url'='jdbc:derby:directory:jahia;create=true';
                'jahia_cred'=@('root', 'root');
                'tools_login'='jahia';
                'tools_password'='monpassword';
            }

        }

        default { #not known
            Write-Host "Computer $env:COMPUTERNAME not known"
            return @{
                'db_username'=$non_value;
                'db_password'=$non_value;
                'db_url'=$non_value;
                'jahia_cred'=@($non_value, $non_value);
                'tools_login'='jahia';
                'tools_password'='monpassword';
            }



        }

    }
}




Export-ModuleMember -Function *
