#Requires -Version 3.0
#Requires -Modules Test-ConnectionAsync
#https://github.com/proxb/AsyncFunctions/blob/master/Test-ConnectionAsync.ps1

$myIP = Get-NetIPConfiguration | Select IPv4Address
$octect = $myIP.IPv4Address.IPv4Address -split "\." # backslah means newline in RegEx

# Get the IP range for the subnet you are on
$subnet = for ($i = 1; $i -lt 255; $i += 1){
        [PSCustomObject]@{
            testIP = "$($octect.Item(0)).$($octect.Item(1)).$($octect.Item(2)).$($i)"
            }
}               
Test-ConnectionAsync -Computer $subnet.testip | select computername, result | where result -eq Success
