function Get-MSAController
{
<#
.SYNOPSIS
    Shows information about each controller module.
.DESCRIPTION
    Shows information about each controller module.
.EXAMPLE
    PS:> Get-MSAController

    vendor model           durable-id      serial-number  position   ip-address         mac-address        health status
    ------ -----           ----------      -------------  --------   ----------         -----------        ------ ------
    HPE    MSA 2060 iSCSI  controller_a    7CE935R053     Top        192.168.100.98     00:C0:FF:50:43:7D  OK     Operational
    HPE    MSA 2060 iSCSI  controller_b    7CE935R039     Bottom     192.168.100.99     00:C0:FF:50:43:92  OK     Operational   
#>
    $result = Invoke-MSAStorageRestAPI -noun controllers -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
function Get-MSAControllerDate
{
<#
.SYNOPSIS
    Shows the system's current date and time.
.DESCRIPTION
    Shows the system's current date and time.
.EXAMPLE
    PS:> Get-MSAControllerDate

    object-name       : time-settings-table
    meta              : /meta/time-settings-table
    date-time         : 2022-06-06 23:10:16
    date-time-numeric : 1654557016
    time-zone-offset  : +00:00
    ntp-state         : Enabled
    ntp-address       : 192.168.1.70
#>
    $result = Invoke-MSAStorageRestAPI -noun 'controllers-date' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAControllerStatistic
{
<#
.SYNOPSIS
    Shows live performance statistics for controller modules.
.DESCRIPTION
    Shows live performance statistics for controller modules.
    For controller performance statistics, the system samples live data every 15 seconds
.EXAMPLE
    PS:> Get-MSAControllerStatistic

    durable-id   cpu- write-ca bytes-pe iops  number-o read-cac read-cach number-of write-cac write-cac data-re data-wr num-forwar start-sample-time      stop-sample-time
                 load che-used r-second       f-reads  he-hits  e-misses  -writes   he-hits   he-misses ad      itten   ded-cmds
    ----------   ---- -------- -------- ----  -------- -------- --------- --------- --------- --------- ------- ------- ---------- -----------------      ----------------
    controller_A 2    0        0B       0     0        0        0         0         0         0                         0          2022-06-06 23:34:41    2022-06-06 23:34:47
    controller_B 2    0        0B       0     0        0        0         0         0         0                         0          2022-06-06 23:34:34    2022-06-06 23:34:47

#>
    $result = Invoke-MSAStorageRestAPI -noun 'controller-statistic' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
