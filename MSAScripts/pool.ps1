function Get-MSAPool
{
<#
.SYNOPSIS
    Shows information about pools.
.DESCRIPTION
    Shows information about pools.
.NOTES
    For a pool, new data will not be written to, or existing data migrated to, a degraded disk group unless it is the
    only disk group having sufficient available space for the data.
.EXAMPLE
    PS:> Get-MSAPool

    name owner  total-size  total-avail  volumes    overcommit      high-threshold  health
    ---- -----  ----------  -----------  -------    ----------      --------------  ------
    A    A      14.3TB      12.3TB       3          Enabled         98.50 %         OK
    B    B      1781.2GB    1781.2GB     0          Enabled         87.94 %         OK
#>
    $result = Invoke-MSAStorageRestAPI -noun pools -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
function Get-MSAPoolStatistics
{
<#
.SYNOPSIS
    Shows live or historical performance statistics for pools.
.DESCRIPTION
    Shows live or historical performance statistics for pools.
    For pool performance statistics, the system samples live data every 30 seconds and historical data every 5 minutes, and retains historical data for 6 months.
    The historical option allows you to specify a time range or a number (count) of data samples to include. 
    It is not recommended to specify both the time-rangeand countparameters. 
    If both parameters are specified, and more samples exist for the specified time range, the samples' values will be aggregated to show the required number of samples.
.EXAMPLE
    PS:> Get-MSAPoolStatistic

   sample-time          pool    pages-d pages-a pages-a pages-d pages-u pages-u num-blocke num-pag num-pag num-pag num-pag num-page- num-hot num-col
                                ealloc- lloc-pe lloc-pe ealloc- nmap-pe nmap-pe d-ssd-prom e-alloc e-alloc e-deall e-unmap promotion -page-m d-page-
                                per-min r-minut r-hour  per-hou r-minut r-hour  otions-per ations  ations  ocation s       s-to-ssd- oves    moves
                                ute     e               r       e               -minute                    s               blocked
    -----------         ----    ------- ------- ------- ------- ------- ------- ---------- ------- ------- ------- ------- --------- ------- -------
    2022-06-06 18:15:55 A       0       0       0       0       0       0       0          0       0       0       0       0         0       0
    2022-06-06 18:15:55 B       0       0       0       0       0       0       0          0       0       0       0       0         0       0
PS:>
#>
    $result = Invoke-MSAStorageRestAPI -noun 'pool-statistics' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
