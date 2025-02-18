function Get-MSAAlert
{
<#
.SYNOPSIS
    Shows information about the active alerts on the storage system.
.DESCRIPTION
    Shows information about the active alerts on the storage system.
.NOTES 
    The system presents a maximum of 512 alerts that are either unresolved, or resolved but unacknowledged. 
    If further alerts are detected, resolved alerts are deleted to generate active alerts. 
    If all 512 alerts are active, no new alerts are generated.
.EXAMPLE
    PS:> Get-MSAAlerts

    durable-id                   acknow reason                                                       recommended-action
                                 ledged
    ----------                   ------ ------                                                       ------------------
    alert_sas_port.00            Yes    No drive enclosure is connected to this expansion port. Thi… - No Action Required.
    alert_sas_port.01            Yes    No drive enclosure is connected to this expansion port. Thi… - No Action Required.
    alert_UnsecuredProtocol.03   Yes    At least one unsecure protocol is enabled.                   - Disable all unsecure protocols (usmis, telnet, ftp, http,…
    alert_update_server.04       Yes    The system was unable to connect or parse information from … - Check the connection with the update server. Verify the i…
#>
    $result = Invoke-MSAStorageRestAPI -noun 'alerts' -verb 'show'
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAAlertConditionHistory
{
<#
.SYNOPSIS
    Shows the history of the alert conditions that have generated alerts.
.DESCRIPTION
    Shows the history of the alert conditions that have generated alerts.
    The most recent 3000 alert conditions are maintained in this log history, regardless of whether they are resolved or unresolved.
.EXAMPLE
    PS:> Get-MSAAlertConditionHistory

    id                      severity        component                index resolved detected-time        resolved-time        reason
    --                      --------        ---------                ----- -------- -------------        -------------        ------
    condition_sas_port.01   INFORMATIONAL   expport_universal_1.A1   1     No       2020-08-19 12:59:12  N/A                  No drive enclosure is connected to this expansion…
    condition_mgmt_port.02  INFORMATIONAL   mgmtport_b               2     Yes      2020-08-19 12:59:13  2020-08-19 13:03:01  The network port health is unknown. It may be unh…
    condition_sas_port.03   INFORMATIONAL   expport_universal_1.B1   3     No       2020-08-19 12:59:13  N/A                  No drive enclosure is connected to this expansion…
    condition_mgmt_port.04  WARNING         mgmtport_a               4     Yes      2020-08-19 13:33:14  2020-08-19 13:33:17  The network port Ethernet cable is unplugged, or …
#>
    $result = Invoke-MSAStorageRestAPI -noun 'alert-condition-history' -verb 'show'
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAEvent
{
<#
.SYNOPSIS
    Shows events logged by each controller in the storage system.
.DESCRIPTION
    Shows events logged by each controller in the storage system.
    A separate set of event numbers is maintained for each controller. Each event number is prefixed with a letter
    identifying the controller that logged the event.
    Events are listed from newest to oldest, based on a timestamp with one-second granularity. Therefore the event log
    sequence matches the actual event sequence within about one second.
.EXAMPLE
    PS:> Get-MSAEvent

    PS:> (get-msaevent )[1..10]

    time-stamp             event- event- contr severity       message                                                      recommended-action
                           code   id     oller
    ----------             ------ ------ ----- --------       -------                                                      ------------------
    2022-06-06 17:17:26    207    B2733  B     INFORMATIONAL  A scrub-disk-group job completed. No errors were found. (di… - No action is required.
    2022-06-06 14:58:00    523    B2732  B     INFORMATIONAL  Details associated with a scrub-disk-group job. (related ev… Follow the recommended action…
    2022-06-06 14:58:00    206    B2731  B     INFORMATIONAL  A scrub-disk-group job was started. (disk group: dgB01, SN:… - No action is required.
    2022-06-06 12:46:00    523    A2910  A     INFORMATIONAL  Details associated with a scrub-disk-group job. (related ev… Follow the recommended action…
    2022-06-06 12:46:00    207    A2909  A     INFORMATIONAL  A scrub-disk-group job completed. No errors were found. (di… - No action is required.
    2022-06-06 08:39:40    523    A2908  A     INFORMATIONAL  Details associated with a scrub-disk-group job. (related ev… Follow the recommended action…
    2022-06-06 08:39:40    206    A2907  A     INFORMATIONAL  A scrub-disk-group job was started. (disk group: dgA01, SN:… - No action is required.
    2022-06-05 14:57:18    523    B2730  B     INFORMATIONAL  Details associated with a scrub-disk-group job. (related ev… Follow the recommended action…
    2022-06-05 14:57:18    207    B2729  B     INFORMATIONAL  A scrub-disk-group job completed. No errors were found. (di… - No action is required.
    2022-06-05 12:37:52    523    B2728  B     INFORMATIONAL  Details associated with a scrub-disk-group job. (related ev… Follow the recommended action…
#>
    $result = Invoke-MSAStorageRestAPI -noun events -verb 'show'
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAAuditLog
{
<#
.SYNOPSIS
    Shows audit log data.
.DESCRIPTION
    All user login and logout attempts and operations performed through the CLI, SMU, SMI-S, and FTP/SFTP interface are recorded in the audit log. Failed login attempts are also recorded.
    The audit log will contain the timestamp, username, and command that was run as well as the status code returned by that command. The audit log contains a subset of the data that is stored in controller logs. 
    The audit log will not contain specific value changes, such as old and new settings.
    Audit logs record host IP information for all interfaces. Audit logs also record snmpset commands.
    Each controller maintains its own audit log. Each audit log can contain up to 2MB of data, after which it will wrap.
    Audit log data will persist after restarting the Storage Controller or running the restore defaultscommand. 
    Audit logs are not associated with the managed logs feature. Audit logs will be cleared during factory refurbishment.
    Audit log data is not mirrored to the partner controller. In a failover scenario, the failed controller's audit log cannot beretrieved until the failed controller is recovered. 
    When the failed controller comes back online its audit log should be accessible.
.NOTES 
    The system presents a maximum of 512 alerts that are either unresolved, or resolved but unacknowledged. 
    If further alerts are detected, resolved alerts are deleted to generate active alerts. 
    If all 512 alerts are active, no new alerts are generated.
.EXAMPLE
    PS:> Get-MSAAuditLog

    The output of this command is not an object but instead a massive text dump.
#>
    $result = Invoke-MSAStorageRestAPI -noun 'audit-log' -verb 'show'
    $objResult = Register-MSAObjectType $result -SubobjectName 'audit-log' -verbose
    return $objResult
}

function Get-MSADebugLogSetting
{
<#
.SYNOPSIS
    Shows which debug message types are enabled (On) or disabled (Off) for inclusion in the Storage Controller debug log.
.DESCRIPTION
    Shows which debug message types are enabled (On) or disabled (Off) for inclusion in the Storage Controller debug log.

.NOTES 
    These settings shown in this command is for use by or with direction from technical support.
.EXAMPLE
    PS:> Get-MSADebugLogSetting

    object-name      : debug-log-parameters
    meta             : /meta/debug-log-parameters
    host-dbg         : On
    host-dbg-numeric : 1
    disk             : On
    disk-numeric     : 1
    mem              : Off
    mem-numeric      : 0
    fo               : On
    fo-numeric       : 1
    msg              : On
    msg-numeric      : 1
    ioa              : On
    ioa-numeric      : 1
    iob              : Off
    iob-numeric      : 0
    ioc              : Off
    ioc-numeric      : 0
    iod              : Off
    iod-numeric      : 0
    misc             : On
    misc-numeric     : 1
    host2            : Off
    host2-numeric    : 0
    raid             : On
    raid-numeric     : 1
    cache            : On
    cache-numeric    : 1
    emp              : On
    emp-numeric      : 1
    capi             : On
    capi-numeric     : 1
    mui              : On
    mui-numeric      : 1
    bkcfg            : On
    bkcfg-numeric    : 1
    awt              : Off
    awt-numeric      : 0
    res2             : Off
    res2-numeric     : 0
    capi2            : Off
    capi2-numeric    : 0
    dms              : On
    dms-numeric      : 1
    fruid            : On
    fruid-numeric    : 1
    resmgr           : Off
    resmgr-numeric   : 0
    init             : Off
    init-numeric     : 0
    ps               : On
    ps-numeric       : 1
    cache2           : Off
    cache2-numeric   : 0
    rtm              : Off
    rtm-numeric      : 0
    hb               : Off
    hb-numeric       : 0
    autotest         : Off
    autotest-numeric : 0
    cs               : On
    cs-numeric       : 1
#>
    $result = Invoke-MSAStorageRestAPI -noun 'debug-log-parameters' -verb 'show'
    $objResult = Register-MSAObjectType $result -SubobjectName 'audit-log'
    return $objResult
}

function Get-MSAMetric
{
<#
.SYNOPSIS
    Shows a list of all available types of metrics in the system.
.DESCRIPTION
    Shows a list of all available types of metrics in the system.
.OUTPUTS
    total-avg-response-time: Average response time of an operation in microseconds. Operations include both reads and writes. Applicable objects: controller, host-port, pool, system, volume. 
    total-bytes-per-second: Sum of read bytes per second and write bytes per second. Applicable objects: controller, host-port, pool, system, volume.
    total-iops: Sum of read IOPS and write IOPS. Applicable storage objects: controller, host-port, pool, system, volume.
    total-max-response-time: Sum of read maximum response time and write maximum response time. Applicable objects: controller, host-port, pool, system, volume.
    total-num-bytes: Sum of read bytes and write bytes. Applicable objects: controller, host-port, pool, system, volume.
    read-io-count: Number of read I/O operations. Applicable objects: controller, host-port, pool, system, volume.
    read-ahead-ops: Number of times that read ahead pre-fetched data for host reads. Applicable objects: controller, volume.
    read-avg-queue-depth: Average number of pending read operations being serviced since the last sampling time. This value represents periods of activity only and excludes periods of inactivity. Applicable objects: host-port, volume.
    read-avg-response-time: I/O read average response time in microseconds. Applicable objects: controller, host-port, pool, system, volume.
    read-bytes-per-second: Number of bytes read per second. Applicable storage objects: controller, hostport, pool, system, volume.
    read-iops: Number of I/Os per second. Applicable objects: controller, host-port, pool, system, volume.
    read-max-response-time: Maximum I/O read response time in microseconds. Applicable objects: controller, host-port, pool, system, volume.
    read-num-bytes: Number of bytes read since the last time this data point was sampled. Applicable objects: controller, host-port, pool, system, volume.
    small-destages: Number of partial stripe destages. (These tend to be very inefficient compared to full stripe writes.) Applicable objects: controller, volume.
    write-io-count: Number of write I/O operations. Applicable objects: controller, host-port, pool, system, volume.
    write-avg-queue-depth: Average number of pending write operations being serviced since the last sampline. time. This value represents periods of activity only and excludes periods of inactivity. Applicable objects: hostport, volume.
    write-avg-response-time: I/O write average response time in microseconds. Applicable objects: controller, host-port, pool, system, volume.
.EXAMPLE
    PS:> Get-MSAMetric

#>
    $result = Invoke-MSAStorageRestAPI -noun 'metrics-list' -verb 'show'
    $objResult = Register-MSAObjectType $result
    return $objResult
}
