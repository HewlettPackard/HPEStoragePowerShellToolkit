function Get-MSAPort
{
<#
.SYNOPSIS
    Shows information about host ports in each controller.
.DESCRIPTION
    Shows information about host ports in each controller.
    This also shows additional detail about the port status, including SFP information. 
.EXAMPLE
    PS:> Get-MSAPorts

    durable-id   controller port   port-type target-id                                          status actual-speed health
    ----------   ---------- ----   --------- ---------                                          ------ ------------ ------
    hostport_A1  A          A1     iSCSI     iqn.2015-11.com.hpe:storage.msa2060.19275038e8     Up     10Gb         OK
    hostport_A2  A          A2     iSCSI     iqn.2015-11.com.hpe:storage.msa2060.19275038e8     Up     10Gb         OK
    hostport_A3  A          A3     iSCSI     iqn.2015-11.com.hpe:storage.msa2060.19275038e8     Up     10Gb         OK
    hostport_A4  A          A4     iSCSI     iqn.2015-11.com.hpe:storage.msa2060.19275038e8     Up     10Gb         OK
    hostport_B1  B          B1     iSCSI     iqn.2015-11.com.hpe:storage.msa2060.19275038e8     Up     10Gb         OK
    hostport_B2  B          B2     iSCSI     iqn.2015-11.com.hpe:storage.msa2060.19275038e8     Up     10Gb         OK
    hostport_B3  B          B3     iSCSI     iqn.2015-11.com.hpe:storage.msa2060.19275038e8     Up     10Gb         OK
    hostport_B4  B          B4     iSCSI     iqn.2015-11.com.hpe:storage.msa2060.19275038e8     Up     10Gb         OK
#>
    $result = Invoke-MSAStorageRestAPI -noun ports -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
