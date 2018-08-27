$kDeployScript = "domainProfileCheckDeployer"
$scheduledScript = 'checkFwDomainProfile'
$Kdate = (Get-Date).ToString('yyyy-MM-dd_H-mm')
$kScriptRoot = 'C:\Scripts\'
$klogRoot = "$kScriptRoot\Logs"
$runAsAccount = "Domain\tasks"
$fileserver = 'fileserver'

$dc = Get-ADDomainController -Filter * | where {$_.OperatingSystem -notlike "*2008*"}
$kPassEncrypt = (Get-SavedCredential $runAsAccount -Context $scheduledScript -ErrorAction SilentlyContinue)
 
If (-not $kPassEncrypt ){Set-SavedCredential -UserName $runAsAccount -Context $scheduledScript}
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($kPassEncrypt.Password)
$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) 

Foreach ($d in $dc){
    If (-not(Test-Path "\\$($d.HostName)\C`$\Scripts\")){New-Item -ItemType directory -Path "\\$($d.HostName)\C`$\Scripts\"}
    If (-not(Test-Path "\\$($d.HostName)\C`$\Scripts\$scheduledScript.ps1")){Copy-Item -Recurse -Path "\\$fileserver\e$\Scripts\$scheduledScript.ps1" -Destination "\\$($d.HostName)\C$\Scripts" -PassThru}
    
    $session = New-PSSession -ComputerName $d.HostName -Credential $kPassEncrypt
    Invoke-Command -Session $session -ScriptBlock {
        $action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-NonInteractive -NoLogo -NoProfile -File ""$Using:kScriptRoot$Using:scheduledScript.ps1""" 
        $timeSpan = New-TimeSpan -Minutes 5 
        $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -Minutes 2)
        $settings = (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -ExecutionTimeLimit $timeSpan -RestartCount 3 -RestartInterval $timeSpan -RunOnlyIfNetworkAvailable -DontStopIfGoingOnBatteries -DontStopOnIdleEnd) 
        Register-ScheduledTask -RunLevel Highest -TaskName $Using:scheduledScript -User $Using:runAsAccount -Password $Using:Password -Action $action -Trigger $trigger -Settings $Settings
        }
    Remove-PSSession -Session $session
}

break


# Rollback
$dc = Get-ADDomainController -Filter * | where {$_.OperatingSystem -notlike "*2008*"}

Foreach ($d in $dc){
    $session = New-PSSession -ComputerName $d.HostName -Credential $kPassEncrypt
    Invoke-Command -Session $session -ScriptBlock {
        #Disable-ScheduledTask -TaskName $Using:scheduledScript
        Unregister-ScheduledTask -TaskName $Using:scheduledScript -Confirm:$false
        }
    Remove-PSSession -Session $session     
    }


break

# Validation
$dc = Get-ADDomainController -Filter * | where {$_.OperatingSystem -notlike "*2008*"}

Foreach ($d in $dc){
    $session = New-PSSession -ComputerName $d.HostName -Credential $kPassEncrypt
    Invoke-Command -Session $session -ScriptBlock {
        Get-ScheduledTask -TaskName $Using:scheduledScript
        }
    Remove-PSSession -Session $session  
    }
