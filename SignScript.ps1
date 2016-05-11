Function Approve-Script{
<#
.SYNOPSIS
   Digitally sign scripts.

.DESCRIPTION
   Requires a code signing certificate that is trusted within your organisation.
   See help for New-SelfSignedCertificate cmdlet.
   New-SelfSignedCertificate uses makecert.exe. This tool is available as part of Visual Studio, or the Windows SDK.


.EXAMPLE
   The following example applies a digital signature to all scripts in the current directory.
    PS C:\Scripts\Library> Approve-Script

        Directory: C:\Scripts\Library


    SignerCertificate                         Status                                                          Path                                                           
    -----------------                         ------                                                          ----                                                           
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           addtoGroup.ps1                                                 
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           aubehave.vbs                                                   
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           changeDeptDrivePermissions.ps1      

.EXAMPLE
   The following example applies a digital signature to all scripts in C:\Scripts.

   Approve-Script -Path C:\Scripts\*.ps1

        Directory: C:\Scripts

    SignerCertificate                         Status                                                          Path                                                           
    -----------------                         ------                                                          ----                                                           
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           archiveSecLog.ps1                                                                                     
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           filesharegroups.ps1                                            
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           getADlocalAdmins.ps1                                            

.EXAMPLE
   The following example shows the Approve-Script accepting pipeline input from Get-ChildItem.

   Get-ChildItem *.ps1 | Approve-Script

        Directory: C:\scripts

    SignerCertificate                         Status                                                          Path                                                           
    -----------------                         ------                                                          ----                                                           
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           archiveSecLog.ps1                                                                                        
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           filesharegroups.ps1                                            
    3FB56547449EF30E48A19FDE4B85C2DBB6B97309  Valid                                                           getADlocalAdmins.ps1                                             
#>
    [CmdletBinding(ConfirmImpact='Low')]
    Param(
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilePath = '*',

        [Parameter(ValueFromPipeline=$true)]
        $InputObject
    )

    Begin{
            $cert=(dir cert:currentuser\my\ -CodeSigningCert)
            If(-Not($cert)){
                Write-Error "Error: No Code Signing Certificate found in Certificate Store CERT:Currentuser\My\
                            Get a free code signing cert at http://www.cacert.org/"
                Break
                }
            }
    
    Process{      
              Set-AuthenticodeSignature $FilePath $cert -TimestampServer http://timestamp.verisign.com/scripts/timstamp.dll -ErrorAction SilentlyContinue
        }
    
    End{}
}
