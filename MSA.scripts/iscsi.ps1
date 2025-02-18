function Get-MSAiSCSI
{
<#
.SYNOPSIS
    Shows system-wide parameters for iSCSI host ports in each controller module.
.DESCRIPTION
    Shows system-wide parameters for iSCSI host ports in each controller module.
.EXAMPLE
    PS:> Get-MSAiSCSI

    object-name          : iscsi-parameter
    meta                 : /meta/iscsi-parameters
    chap                 : Disabled
    chap-numeric         : 0
    jumbo-frames         : Enabled
    jumbo-frames-numeric : 1
    isns                 : Disabled
    isns-numeric         : 0
    isns-ip              : 0.0.0.0
    isns-alt-ip          : 0.0.0.0
    iscsi-speed          : auto
    iscsi-speed-numeric  : 0
    iscsi-ip-version     : 4
#>
    $result = Invoke-MSAStorageRestAPI -noun 'iscsi-parameters' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
