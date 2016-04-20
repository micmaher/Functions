Function Approve-Script{
<#
.SYNOPSIS
   Digitally sign scripts.

.DESCRIPTION
   Requires a code signing certificate that is trusted within your organisation.
   See help for New-SelfSignedCertificate cmdlet.
   New-SelfSignedCertificate uses makecert.exe. This tool is available as part of Visual Studio, or the Windows SDK.

.EXAMPLE
   The following example applies a digital signature to all scripts in C:\Scripts.

   Approve-Script -ScriptPath C:\Scripts\*.ps1

        Directory: C:\Scripts

    SignerCertificate                         Status                                                          Path                                                           
    -----------------                         ------                                                          ----                                                           
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           archiveSecLog.ps1                                                                                     
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           filesharegroups.ps1                                            
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           getADlocalAdmins.ps1                                            

.EXAMPLE
   The following example shows the Approve-Script accepting pipeline input from Get-ChildItem.

   Get-ChildItem -Path C:\scripts\*.ps1 | Approve-Script

        Directory: C:\scripts

    SignerCertificate                         Status                                                          Path                                                           
    -----------------                         ------                                                          ----                                                           
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           archiveSecLog.ps1                                                                                        
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           filesharegroups.ps1                                            
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           getADlocalAdmins.ps1                                             
#>
    [CmdletBinding(ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$scriptPath
    )

    Begin{}
    
    Process{
        if ($pscmdlet.ShouldProcess("Target", "Operation")){
                $cert=(dir cert:currentuser\my\ -CodeSigningCert)
                Set-AuthenticodeSignature $scriptPath $cert -TimestampServer http://timestamp.verisign.com/scripts/timstamp.dll
                }
        }
    
    End{}
}
