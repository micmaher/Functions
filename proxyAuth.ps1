Function Grant-Proxy
{
<#
	.SYNOPSIS
	Sends logged in user credentials to proxy

	.DESCRIPTION
	Allows access via proxies like Bluecoat

	.EXAMPLE
    Open access to the Internet for PowerShell to update help files

         Grant-Proxy
         Update-Help

	.NOTES
    Author: Michael Maher
    
    Date: 14/4/16
#>	 
    [CmdletBinding()]
       
    Param()

    Begin{}

    Process{
            $wc = New-Object System.Net.WebClient
            $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
            }  
}


