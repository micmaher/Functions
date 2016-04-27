#Requires -Modules TestConnectionAsync
#Requires -Version 3.0
Function Ping-All{  
<#
.SYNOPSIS
    Ping an entire subnet quickly (asynchronously)
.DESCRIPTION
    Uses TestConnectionAsync module from Boe Prox (Msft)
    The number of days to check back is a mandatory prarmeter
.EXAMPLE
    This command performs an asynchronous ping on all hosts within your subnet

    PS OneDrive:\> Ping-All

        Computername    Result
        ------------    ------
        192.168.192.1  Success
        192.168.192.17 Success
        192.168.192.20 Success
        192.168.192.23 Success
        192.168.192.28 Success
        192.168.192.30 Success
        192.168.192.47 Success
        192.168.192.49 Success
        192.168.192.60 Success

.EXAMPLE
     This command pings all hosts in the designated subnet

    PS OneDrive:\> ping-all -subnet 194.125.2.0

        Computername   Result
        ------------   ------
        194.125.2.207 Success
        194.125.2.240 Success
        194.125.2.241 Success
        194.125.2.252 Success
        194.125.2.253 Success
        194.125.2.254 Success
.NOTES
       # To get Test-ConnectionAsync in PowerShell 5.0 use Package Management 
       # Install-Module -Name TestConnectionAsync

       # If earlier version of PowerShell, download from Boe Prox's GitHub repo
       # https://github.com/proxb/AsyncFunctions/blob/master/Test-ConnectionAsync.ps1

#>     
    [cmdletbinding()]
    Param(
          # Subnet to ping (optional)
          [Parameter(Mandatory=$false,
                     ValueFromPipelineByPropertyName=$true,
                     Position=0)]
          $subnet)

    Begin{ 
        If (-Not($subnet)){
            $myIP = Get-NetIPConfiguration | Select IPv4Address
            $octect = $myIP.IPv4Address.IPv4Address -split "\." # backslash means newline in RegEx
            }
        Else{ 
            $octect = $subnet -split "\."
            } 
         
    }

    Process{
                        
        $range = for ($i = 1; $i -lt 255; $i += 1){
                [PSCustomObject]@{
                    testIP = "$($octect.Item(0)).$($octect.Item(1)).$($octect.Item(2)).$($i)"
                    }
        }         
        #Invoke-Async -Set $subnet -SetParam computername -Params @{count=1} -Cmdlet Test-Connection -ThreadCount 50 
        Test-ConnectionAsync -Computer $range.testip | select computername, result | where result -eq Success      
    }

}
