function Approve-Script{
<#
.SYNOPSIS
   Digitally sign scripts

.DESCRIPTION
   Requires a code signing certificate that is trusted within your organisation

.EXAMPLE
   Approve-Script -ScriptPath .\copy-module.ps1

.EXAMPLE
   Get-ChildItem -Path *.ps1 | Approve-Script $_.path

#>
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  ConfirmImpact='Low')]
    [OutputType([String])]
    Param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $scriptPath = $(throw "Please specify a path to the script
                               For Example: .\signScript c:\scripts\archiveSecLog.ps1")
    )

    Begin{
            If(!(Test-path $scriptPath)) {Write-Output "Path not found:" $scriptPath; Exit}
            }
    
    Process{
        if ($pscmdlet.ShouldProcess("Target", "Operation")){
                $cert=(dir cert:currentuser\my\ -CodeSigningCert)
                Set-AuthenticodeSignature $scriptPath $cert -TimestampServer http://timestamp.verisign.com/scripts/timstamp.dll
                }
        }
    
    End{}
}
