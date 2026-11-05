function Get-MSADiskGroup
{
<#
.SYNOPSIS
    Shows information about disk groups.
.DESCRIPTION
    The command will show information for all disk groups by default, or you can use parameters to filter the output.
.EXAMPLE
    PS:> Get-MSADiskGroup

    name       size       freespace  pool   raidtype  diskcount health
    ----       ----       ---------  ----   --------  --------- ------
    dgA01      14.3TB     14.3TB     A      MSA-DP+   12        OK
    dgB01      1781.2GB   1781.2GB   B      RAID1     2         OK
#>
    $result = Invoke-MSAStorageRestAPI -noun 'disk-groups' -verb 'show'
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSADiskGroupStatistic
{
<#
.SYNOPSIS
    Shows live performance statistics for disk groups.
.DESCRIPTION
    Shows live performance statistics for disk groups.
    The command shows information for all disk groups by default, or you can use parameters to filter the output. 
    For diskgroup performance statistics, the system samples live data every 30 seconds.
.EXAMPLE
    PS:> Get-MSADiskGroupStatistic

    name     time-since- number-of- number-of- data-read  data-written bytes-per- iops    avg-read- avg-write-
             sample      reads      writes                             second             rsp-time  rsp-time
    ----     ----------- ---------- ---------- ---------  ------------ ---------- ----    --------- ----------
    dgA01    11          640483     0          2667.3GB   0B           0B         0       36757     0
    dgB01    11          335094     0          1387.2GB   0B           0B         0       63580     0
#>
    $result = Invoke-MSAStorageRestAPI -noun 'disk-group-statistics' -verb 'show'
    $objResult = Register-MSAObjectType $result
    return $objResult
}
