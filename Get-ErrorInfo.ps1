<#
.SYNOPSIS
  Pretty-Printing Error Objects (from http://powershell.com)
.DESCRIPTION
  Whenever you deal with error objects, you may want to use the following PowerShell function: Get-ErrorInfo. 
  It accepts any number of error records, and turns them into easily usable error information objects

.EXAMPLE
  You can use it inside any error handler (try or trap): pipe $_ to Get-ErrorInfo. And you can use it with error variables:

    $files = Get-ChildItem -Path $env:windir -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue -ErrorVariable myError

    $myError | Get-ErrorInfo | Select-Object -Property ErrorReason, Target

  The result would look similar to this and show the files that were inaccessible:

.NOTES
http://powershell.com/cs/blogs/tips/archive/2016/05/03/pretty-printing-error-objects.aspx
#>
function Get-ErrorInfo
{
  param
  (
    [System.Management.Automation.ErrorRecord]
    [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
    $ErrorInfo
  )

  process
  {
    $hash = [Ordered]@{
      ScriptName   = $ErrorInfo.InvocationInfo.ScriptName
      ErrorMessage = $ErrorInfo.Exception.Message
      LineNumber   = $ErrorInfo.InvocationInfo.ScriptLineNumber
      ColumnNumber = $ErrorInfo.InvocationInfo.OffsetInLine
      Category     = $ErrorInfo.CategoryInfo.Category
      ErrorReason  = $ErrorInfo.CategoryInfo.Reason
      Target       = $ErrorInfo.CategoryInfo.TargetName
      StackTrace   = $ErrorInfo.Exception.StackTrace
    }
    New-Object -TypeName PSObject -Property $hash
  }
}
