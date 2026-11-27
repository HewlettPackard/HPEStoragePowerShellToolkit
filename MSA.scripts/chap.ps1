function Get-MSAChap
{
<#
.SYNOPSIS
    Shows CHAP records for iSCSI originators.
.DESCRIPTION
    Shows CHAP records for iSCSI originators.
    This command is permitted whether or not CHAP is enabled.
.EXAMPLE
    PS:> Get-MSAChap

    This command may simply retunr nothing if CHAP is not being used.
#>
    $result = Invoke-MSAStorageRestAPI -noun 'chap-records' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
