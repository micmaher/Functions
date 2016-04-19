Function Send-EWSMail
{
<#
	.SYNOPSIS
	Sends email via Exchange Web Services

	.DESCRIPTION
	Must be run with parameters
		
    .PARAMETER Username
    Your username (samAccountname) domain name not required

    .PARAMETER Password
    Your password. Enclose in single quotes to ensure special characters are parsed correctly

    .PARAMETER To
    The recipient address

    .PARAMETER Subject
    Optional. Subject line of email. Enclose in quotes

    .PARAMETER Body
    Optional. Body of message. Can also be read in from Get-Content, see examples
    
    .PARAMETER Attachment
    Optional. Attach a file

    .PARAMETER Domain
    Domain name. Defaults to CONTOSO
        	
	.EXAMPLE
    Sends and email with one line of text in the body

        Send-EWSMail -username mmaher -password myPassword -to jsmith@contoso.com -subject 'Just a test' -body 'test message'

	.EXAMPLE
    Sends and email with text file useed in the body

        Send-Email -username mmaher -password myPassword -to jsmith@contoso.com -subject 'Just a test' -body (Get-Content C:\Temp\message.txt)

	.EXAMPLE
    Sends and email with an attachment

        Send-EWSMail -username mmaher -password myPassword -to jsmith@contoso.com -subject 'Just a test' -body 'test message' -attachment 'C:\Temp\license.txt'
	
	.NOTES
    Author: Michael Maher
    
    Date: 14/2/16

    Requires .NET 3.5 installed      
    
    Just an FYI - for Office 2016/Office 365 use . . .
    "${env:ProgramFiles(x86)}\Microsoft Office\Office16\ADDINS\Microsoft Power Query for Excel Integrated\bin\Microsoft.Exchange.WebServices.dll"
    
    .LINK
    More Examples
    http://exchangeserverpro.com/test-lab-email-traffic-generator-powershell-script/

    Download EWS Managed API 1.1 which works with Exchange 2010 SP1
    http://www.mikepfeiffer.net/downloads/ExchangeLab.zip (under 'bin' folder)  
#>	 
    [CmdletBinding()]
       
    Param
    (
            # Send username and password
            [Parameter(mandatory=$true, Position=0)]
            [String]$username = $(throw "-username is required."),
            [String]$password = $( Read-Host -asSecureString "Input password" ),
            [String]$to,
            [String]$subject,
            [String]$body,
            [String]$attachment,
            [String]$domain = "CORPIR"
    )

    Begin{ 
                $3EWS = 'https://mail.three.co.uk/Ews/Exchange.asmx'
                $dllPath = "${env:ProgramFiles(x86)}\Microsoft Office\Microsoft.Exchange.WebServices.dll"
 
           }

    Process{
                # Using EWS Managed API 1.1
                Add-Type -Path  $dllPath
             
                $service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService -ArgumentList Exchange2010
                $service.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials -ArgumentList  $username, $password
                $service.Url = $3EWS

                $message = New-Object Microsoft.Exchange.WebServices.Data.EmailMessage -ArgumentList $service
                $message.Subject = $subject
                $message.Body = $body
                $message.ToRecipients.Add($to)
                If ($attachment){$message.Attachments.AddFileAttachment($attachment)}
                $message.SendAndSaveCopy()
            }  
}

