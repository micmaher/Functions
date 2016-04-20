Function Approve-Script{
<#
.Synopsis
   Digitally sign scripts

.DESCRIPTION
   Requires a code signing certificate that is trusted within your organisation

.EXAMPLE
   Approve-Script -ScriptPath .\copy-module.ps1

.EXAMPLE
   Get-ChildItem -Path *.ps1 | Approve-Script $_.path

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
