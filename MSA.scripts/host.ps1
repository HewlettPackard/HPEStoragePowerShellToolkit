function Get-MSAHost
{
<#
.SYNOPSIS
    Shows information about host groups and hosts.
.DESCRIPTION
    Shows information about host groups and hosts.
    The command will show information for all host groups (and hosts) by default, or you can use parameters to filter the output.
.EXAMPLE
    PS:> Get-MSADisk

    name             durable-id serial-number                            member-count         host-group
    ----             ---------- -------------                            ------------         ----------
    PSTK2019         H0         00c0ff50437d0000467e096001010000         1                    UNGROUPEDHOSTS
    Crusher          H1         00c0ff504392000079aa465f01010000         1                    UNGROUPEDHOSTS
    Riker            H2         00c0ff50437d000062a63f5f01010000         1                    UNGROUPEDHOSTS
    -nohost-         HU         NOHOST                                   0                    UNGROUPEDHOSTS

#>
    $result = Invoke-MSAStorageRestAPI -noun host-groups -verb show
    $objResult = Register-MSAObjectType $result -subobjectname host
    return $objResult
}

function Get-MSAHostGroup
{
<#
.SYNOPSIS
    Shows information about host groups and hosts.
.DESCRIPTION
    Shows information about host groups and hosts.
    The command will show information for all host groups (and hosts) by default, or you can use parameters to filter the output.
.EXAMPLE
    PS:> Get-MSAHostGroup
    
    durable-id name                 serial-number        member-count
    ---------- ----                 -------------        ------------
    HGU        -ungrouped-          UNGROUPEDHOSTS       0
#>
    $result = Invoke-MSAStorageRestAPI -noun host-groups -verb show
    $objResult = Register-MSAObjectType $result -subobjectname 'host-group'
    return $objResult
}

function Get-MSAHostPhyStatistic
{
<#
.SYNOPSIS
    Shows diagnostic information relating to SAS controller physical channels, known as PHY lanes, for each host port.
.DESCRIPTION
    Shows diagnostic information relating to SAS controller physical channels, known as PHY lanes, for each host port.
    This command shows PHY status information for each host port found in an enclosure. 
    Each controller in an enclosure may have multiple host ports. A host port may have multiply PHYs. 
    For each PHY, this command shows statisticalinformation in the form of numerical values.
    There is no mechanism to reset the statistics. All counts start from the time the controller started up. 
    The counts stop at the maximum value for each statistic.
    This command is only applicable to systems that have controllers with SAS host ports.
.EXAMPLE
    PS:> Get-MSAHostPhyStatistic

    port   phy   disparity-errors  lost-dwords   invalid-dwords  reset-error-counter
    ----   ---   ----------------  -----------   --------------  -------------------
    A1     0     00000000          00000000      00000000        00000000
    A1     1     00000000          00000000      00000000        00000000
    A1     2     00000000          00000000      00000000        00000000
    A1     3     00000000          00000000      00000000        00000000
    A2     0     00000000          00000000      00000000        00000000
    A2     1     00000000          00000000      00000000        00000000
    A2     2     00000000          00000000      00000000        00000000
    A2     3     00000000          00000000      00000000        00000000
    A3     0     00000000          00000000      00000000        00000000
    A3     1     00000000          00000000      00000000        00000000
    A3     2     00000000          00000000      00000000        00000000
    A3     3     00000000          00000000      00000000        00000000
    A4     0     00000000          00000000      00000000        00000000
    A4     1     00000000          00000000      00000000        00000000
    A4     2     00000000          00000000      00000000        00000000
    A4     3     00000000          00000000      00000000        00000000
    B1     0     00000000          00000000      00000000        00000000
    B1     1     00000000          00000000      00000000        00000000
    B1     2     00000000          00000000      00000000        00000000
    B1     3     00000000          00000000      00000000        00000000
    B2     0     00000000          00000000      00000000        00000000
    B2     1     00000000          00000000      00000000        00000000
    B2     2     00000000          00000000      00000000        00000000
    B2     3     00000000          00000000      00000000        00000000
    B3     0     00000000          00000000      00000000        00000000
    B3     1     00000000          00000000      00000000        00000000
    B3     2     00000000          00000000      00000000        00000000
    B3     3     00000000          00000000      00000000        00000000
    B4     0     00000000          00000000      00000000        00000000
    B4     1     00000000          00000000      00000000        00000000
    B4     2     00000000          00000000      00000000        00000000
    B4     3     00000000          00000000      00000000        00000000

#>
    $result = Invoke-MSAStorageRestAPI -noun 'host-phy-statistics' -verb show
    $objResult = Register-MSAObjectType $result 
    return $objResult
}

function Get-MSAHostPortStatistic
{
<#
.SYNOPSIS
    Shows live performance statistics for each controller host port.
.DESCRIPTION
    Shows live performance statistics for each controller host port.
    For each host port these statistics quantify I/O operations through the port between a host and a volume. 
    For example, each time a host writes to a volume's cache, the host port's statistics are adjusted. 
    For host-port performance statistics, the system samples live data every 15 seconds.
.EXAMPLE
    PS:> Get-MSAHostPortStatistic

    durable-id  bytes-per iops   number-of number-of data-r data-w queue- avg-rsp- avg-read- start-sample-time     stop-sample-time
                -second          -reads    -writes   ead    ritten depth  time     rsp-time
    ----------  --------- ----   --------- --------- ------ ------ ------ -------- --------- -----------------     ----------------
    hostport_A1 0B        0      0         0         0B     0B     0      0        0         2022-06-07 22:10:40   2022-06-07 22:10:54
    hostport_A2 0B        0      0         0         0B     0B     0      0        0         2022-06-07 22:10:40   2022-06-07 22:10:54
    hostport_A3 0B        0      0         0         0B     0B     0      0        0         2022-06-07 22:10:40   2022-06-07 22:10:54
    hostport_A4 0B        0      0         0         0B     0B     0      0        0         2022-06-07 22:10:40   2022-06-07 22:10:54
    hostport_B1 0B        0      0         0         0B     0B     0      0        0         2022-06-07 22:10:39   2022-06-07 22:10:54
    hostport_B2 0B        0      0         0         0B     0B     0      0        0         2022-06-07 22:10:39   2022-06-07 22:10:54
    hostport_B3 0B        0      0         0         0B     0B     0      0        0         2022-06-07 22:10:39   2022-06-07 22:10:54
    hostport_B4 0B        0      0         0         0B     0B     0      0        0         2022-06-07 22:10:39   2022-06-07 22:10:54
#>
    $result = Invoke-MSAStorageRestAPI -noun 'host-port-statistics' -verb show
    $objResult = Register-MSAObjectType $result 
    return $objResult
}
