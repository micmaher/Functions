#Requires -Modules Test-ConnectionAsync
#Requires -Version 3.0

# To get Test-ConnectionAsync in PowerShell 5.0 use Package Management 
# Install-Module -Name TestConnectionAsync

# If earlier version of PowerShell, download from Boe Prox's GitHub repo
# https://github.com/proxb/AsyncFunctions/blob/master/Test-ConnectionAsync.ps1
       
[cmdletbinding()]
Param()

$myIP = Get-NetIPConfiguration | Select IPv4Address
$octect = $myIP.IPv4Address.IPv4Address -split "\." # backslash means newline in RegEx

$subnet = for ($i = 1; $i -lt 255; $i += 1){
        [PSCustomObject]@{
            testIP = "$($octect.Item(0)).$($octect.Item(1)).$($octect.Item(2)).$($i)"
            }
}               

Test-ConnectionAsync -Computer $subnet.testip | select computername, result | where result -eq Success
