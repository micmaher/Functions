# My wrapper function around Boe Prox Test-ConnectionAsync
# https://github.com/proxb/AsyncFunctions/blob/master/Test-ConnectionAsync.ps1
Function Test-ConnectionAsync {
    <#
        .SYNOPSIS
            Performs a ping test asynchronously 
        .DESCRIPTION
            Performs a ping test asynchronously
        .PARAMETER Computername
            List of computers to test connection
        .PARAMETER Timeout
            Timeout in milliseconds
        .PARAMETER TimeToLive
            Sets a time to live on ping request
        .PARAMETER Fragment
            Tells whether to fragment the request
        .PARAMETER Buffer
            Supply a byte buffer in request
        .NOTES
            Name: Test-ConnectionAsync
            Author: Boe Prox
            Version History:
                1.0 //Boe Prox - 12/24/2015
                    - Initial result
        .OUTPUT
            Net.AsyncPingResult
        .EXAMPLE
            Test-ConnectionAsync -Computername server1,server2,server3
            Computername                Result
            ------------                ------
            Server1                     Success
            Server2                     TimedOut
            Server3                     No such host is known
            Description
            -----------
            Performs asynchronous ping test against listed systems.
    #>
    #Requires -Version 3.0
    [OutputType('Net.AsyncPingResult')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True)]
        [string[]]$Computername,
        [parameter()]
        [int32]$Timeout = 100,
        [parameter()]
        [Alias('Ttl')]
        [int32]$TimeToLive = 128,
        [parameter()]
        [switch]$Fragment,
        [parameter()]
        [byte[]]$Buffer
    )
    Begin {
        
        If (-NOT $PSBoundParameters.ContainsKey('Buffer')) {
            $Buffer = 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 
            0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69
        }
        $PingOptions = New-Object System.Net.NetworkInformation.PingOptions
        $PingOptions.Ttl = $TimeToLive
        If (-NOT $PSBoundParameters.ContainsKey('Fragment')) {
            $Fragment = $False
        }
        $PingOptions.DontFragment = $Fragment
        $Computerlist = New-Object System.Collections.ArrayList
        If ($PSBoundParameters.ContainsKey('Computername')) {
            [void]$Computerlist.AddRange($Computername)
        } Else {
            $IsPipeline = $True
        }
    }
    Process {
        If ($IsPipeline) {
            [void]$Computerlist.Add($Computername)
        }
    }
    End {
        $Task = ForEach ($Computer in $Computername) {
            [pscustomobject] @{
                Computername = $Computer
                Task = (New-Object System.Net.NetworkInformation.Ping).SendPingAsync($Computer,$Timeout, $Buffer, $PingOptions)
            }
        }        
        Try {
            [void][Threading.Tasks.Task]::WaitAll($Task.Task)
        } Catch {}
        $Task | ForEach {
            If ($_.Task.IsFaulted) {
                $Result = $_.Task.Exception.InnerException.InnerException.Message
                $IPAddress = $Null
            } Else {
                $Result = $_.Task.Result.Status
                $IPAddress = $_.task.Result.Address.ToString()
            }
            $Object = [pscustomobject]@{
                Computername = $_.Computername
                IPAddress = $IPAddress
                Result = $Result
            }
            $Object.pstypenames.insert(0,'Net.AsyncPingResult')
            $Object
        }
    }

}

Function Ping-Subnet{  
<#
.SYNOPSIS
    Ping an entire subnet quickly (asynchronously)
.DESCRIPTION
    Uses TestConnectionAsync module from Boe Prox (Msft)
    
.EXAMPLE
    This command performs an asynchronous ping on all hosts within your subnet
    PS OneDrive:\> Ping-Subnet
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
    PS OneDrive:\> Ping-Subnet -subnet 194.125.2.0
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
            Write-Verbose "Checking local subnet"
            $myIP = Get-NetIPConfiguration | Select IPv4Address
            $octect = $myIP.IPv4Address.IPv4Address -split "\." # backslash is escape char
            }
        Else{ 
            Write-Verbose "Parameter subnet set to $subnet"
            $octect = $subnet -split "\."
            Write-Verbose "$subnet split into $octect"
            } 
         
    }

    Process{
                        
        $range = for ($i = 1; $i -lt 255; $i += 1){
                [PSCustomObject]@{
                    testIP = "$($octect.Item(0)).$($octect.Item(1)).$($octect.Item(2)).$($i)"
                    }
        }         
        #Invoke-Async -Set $subnet -SetParam computername -Params @{count=1} -Cmdlet Test-Connection -ThreadCount 50 
        Write-Verbose "Range to be scanned is $($range.testip)"
        Test-ConnectionAsync -Computer $range.testip -TimeToLive 20 | select computername, result | where result -eq Success      
    }

} 

