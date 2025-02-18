function Get-MSADisk
{
<#
.SYNOPSIS
    Shows information about all disks or disk slots in the storage system.
.DESCRIPTION
    The command will show information about all installed disks by default, or you can use parameters to filter the output.
.NOTES
    In console format, to aid reading, disks are sorted to display in order by enclosure and disk number. 
    In API formats, output is not sorted because it is expected to be manipulated by a host application.
.EXAMPLE
    PS:> Get-MSADisk

    loca durable-id  vendor    model         serial-number         revis usage        size       storage-p led-status
    tion                                                           ion                           ool-name
    ---- ----------  ------    -----         -------------         ----- -----        ----       --------- ----------
    1.1  disk_01.01  SEAGATE   ST1800MM0129  WBN0RJ0M0000C906KYJN  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.2  disk_01.02  SEAGATE   ST1800MM0129  WBN0QQ7L0000C905NUQV  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.3  disk_01.03  SEAGATE   ST1800MM0129  WBN0RJCY0000C906KZAY  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.4  disk_01.04  SEAGATE   ST1800MM0129  WBN0S2NA0000C905NUCM  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.5  disk_01.05  SEAGATE   ST1800MM0129  WBN0R6A80000C906NRYN  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.6  disk_01.06  SEAGATE   ST1800MM0129  WBN0R3W90000C905NUBV  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.7  disk_01.07  SEAGATE   ST1800MM0129  WBN0QP620000C906NRWA  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.8  disk_01.08  SEAGATE   ST1800MM0129  WBN0QPZB0000C906NULJ  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.9  disk_01.09  SEAGATE   ST1800MM0129  WBN0R3TA0000C906NUB1  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.10 disk_01.10  SEAGATE   ST1800MM0129  WBN0R5L20000C906RTA6  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.11 disk_01.11  SEAGATE   ST1800MM0129  WBN0R5RD0000C906ST4L  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.12 disk_01.12  SEAGATE   ST1800MM0129  WBN0W6M70000C91182PH  C003  VIRTUAL POOL 1800.3GB   A          Online
    1.13 disk_01.13  SEAGATE   ST1800MM0129  WBN0VY0C0000C911CZGX  C003  VIRTUAL POOL 1800.3GB   B          Online
    1.14 disk_01.14  SEAGATE   ST1800MM0129  WBN0QP9D0000C904A7RP  C003  VIRTUAL POOL 1800.3GB   B          Online
#>
    $result = Invoke-MSAStorageRestAPI -noun disks -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSADiskParameter
{
<#
.SYNOPSIS
    Shows disk settings.
.DESCRIPTION
    Shows disk settings.
.EXAMPLE
    PS:> Get-MSADiskParameter

    object-name                    : drive-parameters
    meta                           : /meta/drive-parameters
    smart                          : Enabled
    smart-numeric                  : 1
    drive-write-back-cache         : Disabled
    drive-write-back-cache-numeric : 2
    drive-timeout-retry-max        : 3
    drive-attempt-timeout          : 8
    drive-overall-timeout          : 105
    disk-dsd-enable                : Disabled
    disk-dsd-enable-numeric        : 0
    disk-dsd-delay                 : 15
    remanufacture                  : Enabled
    remanufacture-numeric          : 1
#>
    $result = Invoke-MSAStorageRestAPI -noun 'disk-parameter' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSADiskStatistic
{
<#
.SYNOPSIS
    Shows live or historical performance statistics for disks.
.DESCRIPTION
    Shows live or historical performance statistics for disks.
    For disk performance statistics, the system samples live data every 15 seconds and historical data every quarter hour, and retains historical data for 6 months.
    The historical option allows you to specify a time range or a number (count) of data samples to include. 
    It is not recommended to specify both the time-rangeand countparameters. 
    If both parameters are specified, and more samples exist for the specified time range, the samples' values will be aggregated to show the required number of samples.
.EXAMPLE
    PS:> Get-MSADiskParameter

    durable-id  location  serial-number             power-on- bytes-per- iops           data-read      data-written   start-sample-time      stop-sample-time
                                                    hours     second
    ----------  --------  -------------             --------- ---------- ----           ---------      ------------   -----------------      ----------------
    disk_01.01  1.1       WBN0RJ0M0000C906KYJN      15756     28.1KB     0              42.6TB         1288.5MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.02  1.2       WBN0QQ7L0000C905NUQV      15756     28.1KB     0              42.6TB         2205.4MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.03  1.3       WBN0RJCY0000C906KZAY      15756     28.1KB     0              42.6TB         1298.9MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.04  1.4       WBN0S2NA0000C905NUCM      15756     56.8KB     0              42.7TB         2369.0MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.05  1.5       WBN0R6A80000C906NRYN      15756     56.8KB     0              42.7TB         1289.5MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.06  1.6       WBN0R3W90000C905NUBV      15756     56.8KB     0              42.6TB         1422.7MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.07  1.7       WBN0QP620000C906NRWA      15756     28.1KB     0              42.6TB         1289.5MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.08  1.8       WBN0QPZB0000C906NULJ      15756     28.1KB     0              42.7TB         1395.9MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.09  1.9       WBN0R3TA0000C906NUB1      15756     56.8KB     0              37.5TB         1497.6GB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.10  1.10      WBN0R5L20000C906RTA6      15756     56.8KB     0              42.7TB         1286.4MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.11  1.11      WBN0R5RD0000C906ST4L      15756     0B         0              42.6TB         1433.2MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.12  1.12      WBN0W6M70000C91182PH      15756     28.1KB     0              42.6TB         2361.7MB       2022-06-06 21:22:16    2022-06-06 21:22:35
    disk_01.13  1.13      WBN0VY0C0000C911CZGX      15756     227.8KB    0              48.9TB         5646.3KB       2022-06-06 21:22:16    2022-06-06 21:22:34
    disk_01.14  1.14      WBN0QP9D0000C904A7RP      15756     227.8KB    0              48.9TB         5646.3KB       2022-06-06 21:22:16    2022-06-06 21:22:34
PS:>
#>
    $result = Invoke-MSAStorageRestAPI -noun 'disk-statistics' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAFDEState
{
<#
.SYNOPSIS
    Shows full disk encryption information for the storage system.
.DESCRIPTION
    Shows full disk encryption information for the storage system.
.NOTES
    If you insert an FDE disk into a secured system and the disk does not come up in the expected state, perform a manual rescan by using the rescancommand.
.EXAMPLE
    PS:> Get-MSAFDEState

    object-name                 : fde-state
    meta                        : /meta/fde-state
    fde-security-status         : Unsecured
    fde-security-status-numeric : 1
    lock-key-id                 : 00000001
    import-lock-key-id          : 00000001
    fde-config-time             : 2020-08-07 14:37:08
    fde-config-time-numeric     : 1596811028
#>
    $result = Invoke-MSAStorageRestAPI -noun 'fde-state' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
