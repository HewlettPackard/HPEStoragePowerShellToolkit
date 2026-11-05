# ProtectionSchedule.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSProtectionSchedule {
<#
.SYNOPSIS
  Create a protection schedule and add to specified protection template.
.DESCRIPTION
  Create a protection schedule and add to specified protection template.
.PARAMETER name
  Name of snapshot schedule to create.
.PARAMETER description
  Description of the schedule.
.PARAMETER volcoll_or_prottmpl_type
  Type of the protection policy this schedule is attached to. Valid values are protection_template and volume_collection.
.PARAMETER volcoll_or_prottmpl_id
  Identifier of the protection policy (protection_template or volume_collection) in 
  which this protection schedule is attached to.
.PARAMETER period
  Repeat interval for snapshots with respect to the period_unit.  For example, a value of 2 with 
  the 'period_unit' of 'hours' results in one snapshot every 2 hours.
.PARAMETER period_unit
  Time unit over which to take the number of snapshots specified in 'period'. For example, a value 
  of 'days' with a 'period' of '1' results in one snapshot every day.
.PARAMETER at_time
  Time of day when snapshot should be taken. In case repeat frequency specifies more than one snapshot 
  in a day then the until_time option specifies until what time of day to take snapshots.
.PARAMETER until_time
  Time of day to stop taking snapshots. Applicable only when repeat frequency specifies more than one snapshot in a day.
.PARAMETER days
  Specifies which days snapshots should be taken. 
  Comma separated list of days of the week or 'all'. Example: 'monday,sunday'.
.PARAMETER num_retain
  Number of snapshots to retain. If replication is enabled on this schedule the array will always retain the 
  latest replicated snapshot, which may exceed the specified retention value. This is necessary to
  ensure efficient replication performance.
.PARAMETER downstream_partner
  Specifies the partner name if snapshots created by this schedule should be replicated.
.PARAMETER downstream_partner_id
  Specifies the partner ID if snapshots created by this schedule should be replicated. In an update operation, 
  if snapshots should be replicated, set this attribute to the ID of the replication partner. If snapshots 
  should not be replicated, set this attribute to the empty string.
.PARAMETER replicate_every
  Specifies which snapshots should be replicated. If snapshots are replicated and 
  this option is not specified, every snapshot is replicated.
.PARAMETER num_retain_replica
  Number of snapshots to retain on the replica.
.PARAMETER repl_alert_thres
  Replication alert threshold in seconds. If the replication of a snapshot takes more than this amount of 
  time to complete an alert will be generated. Enter 0 to disable this alert.
.PARAMETER snap_verify
  Run verification tool on snapshot created by this schedule. This option can only be used with snapshot schedules of a 
  protection template that has application synchronization. The tool used to verify snapshot depends on the type of 
  application. For example, if application synchronization is VSS and the application ID is Exchange, eseutil tool is 
  run on the snapshots. If verification fails, the logs are not truncated.
.PARAMETER skip_db_consistency_check
  Skip consistency check for database files on snapshots created by this schedule. This option only applies 
  to snapshot schedules of a protection template with application synchronization set to VSS, application ID 
  set to MS Exchange 2010 or later w/DAG, this schedule's snap_verify option set to yes, and its disable_appsync 
  option set to false. Skipping consistency checks is only recommended if each database in a DAG has multiple copies.
.PARAMETER disable_appsync
  Disables application synchronized snapshots and creates crash consistent snapshots instead.
.PARAMETER schedule_type
  Normal schedules have internal timers which drive snapshot creation. An externally driven schedule has no 
  internal timers. All snapshot activity is driven by an external trigger. In other words, these
  schedules are used only for externally driven manual snapshots.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]  [string]  $name,
                                    [string]  $description,
    [Parameter(Mandatory = $True)]                              [ValidateSet( 'protection_template', 'volume_collection')]
                                    [string]  $volcoll_or_prottmpl_type,
    [Parameter(Mandatory = $True)]                              [ValidatePattern('([0-9a-f]{42})')]
                                    [string]  $volcoll_or_prottmpl_id,
                                    [int]     $period,
                                                                [ValidateSet( 'hours', 'weeks', 'minutes', 'days')]
                                    [string]  $period_unit,
                                                                [ValidateRange(0,86399)]
                                    [int]     $at_time,
                                                                [ValidateRange(0,86399)]
                                    [int]     $until_time,      
                                    [string]  $days,
                                    [int]     $num_retain,
                                    [string]  $downstream_partner,
                                                                [ValidatePattern('([0-9a-f]{42})')]
                                    [string]  $downstream_partner_id,
                                    [int]     $replicate_every,
                                    [int]     $num_retain_replica,
                                    [long]    $repl_alert_thres,
                                    [bool]    $snap_verify,
                                    [bool]    $skip_db_consistency_check,
                                    [bool]    $disable_appsync,
                                                                [ValidateSet( 'external_trigger', 'regular')]
                                    [string]  $schedule_type
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
            $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
            if($var -and ($PSBoundParameters.ContainsKey($key)))
            {
                $RequestData.Add("$($var.name)", ($var.value))
            }
        }
        $Params = @{
            ObjectName = 'ProtectionSchedule'
            APIPath = 'protection_schedules'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSProtectionSchedule {
<#
.DESCRIPTION
  List one or more protection schedules.
.PARAMETER id
  Identifier for protection schedule. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
  Name of snapshot schedule to create.
.PARAMETER description
  Description of the schedule.
.PARAMETER volcoll_or_prottmpl_type
  Type of the protection policy this schedule is attached to. Valid values are protection_template and volume_collection.
.PARAMETER volcoll_or_prottmpl_id
  Identifier of the protection policy (protection_template or volume_collection) in which this protection schedule is attached to.
.PARAMETER period
  Repeat interval for snapshots with respect to the period_unit.  For example, a value 
  of 2 with the 'period_unit' of 'hours' results in one snapshot every 2 hours.
.PARAMETER period_unit
  Time unit over which to take the number of snapshots specified in 'period'. For
  example, a value of 'days' with a 'period' of '1' results in one snapshot every day.
.PARAMETER at_time
  Time of day when snapshot should be taken. In case repeat frequency specifies more than one snapshot in a 
  day then the until_time option specifies until what time of day to take snapshots.
.PARAMETER until_time
  Time of day to stop taking snapshots. Applicable only when repeat frequency specifies more than one snapshot in a day.
.PARAMETER days
  Specifies which days snapshots should be taken.
.PARAMETER num_retain
  Number of snapshots to retain. If replication is enabled on this schedule the array will always retain the latest replicated 
  snapshot, which may exceed the specified retention value. This is necessary to ensure efficient replication performance.
.PARAMETER downstream_partner_name
  Specifies the partner name if snapshots created by this schedule should be replicated.
.PARAMETER downstream_partner_id
  Specifies the partner ID if snapshots created by this schedule should be replicated. In an update operation, 
  if snapshots should be replicated, set this attribute to the ID of the replication partner. 
  If snapshots should not be replicated, set this attribute to the empty string.
.PARAMETER upstream_partner_name
  Specifies the partner name from which snapshots created by this schedule are replicated.
.PARAMETER upstream_partner_id
  Specifies the partner ID from which snapshots created by this schedule are replicated.
.PARAMETER replicate_every
  Specifies which snapshots should be replicated. If snapshots are replicated 
  and this option is not specified, every snapshot is replicated.
.PARAMETER num_retain_replica
  Number of snapshots to retain on the replica.
.PARAMETER repl_alert_thres
  Replication alert threshold in seconds. If the replication of a snapshot takes more than this amount 
  of time to  complete an alert will be generated. Enter 0 to disable this alert.
.PARAMETER snap_verify
  Run verification tool on snapshot created by this schedule. This option can only be used with snapshot schedules 
  of a protection template that has application synchronization. The tool used to verify snapshot depends on the type 
  of application. For example, if application synchronization is VSS and the application ID is Exchange, eseutil tool 
  is run on the snapshots. If verification fails, the logs are not truncated.
.PARAMETER skip_db_consistency_check
  Skip consistency check for database files on snapshots created by this schedule. This option only applies to snapshot 
  schedules of a protection template with application synchronization set to VSS, application ID set to MS Exchange 2010 
  or later w/DAG, this schedule's snap_verify option set to yes, and its disable_appsync option set to false. Skipping 
  consistency checks is only recommended if each database in a DAG has multiple copies.
.PARAMETER disable_appsync
  Disables application synchronized snapshots and creates crash consistent snapshots instead.
.PARAMETER schedule_type
  Normal schedules have internal timers which drive snapshot creation. An externally driven schedule has no internal 
  timers. All snapshot activity is driven by an external trigger. In other words, these schedules are used only for 
  externally driven manual snapshots.
.PARAMETER last_replicated_snapcoll_name
  Specifies the name of last replicated snapshot collection.
.PARAMETER last_replicated_snapcoll_id
  Specifies the snapshot collection ID of last replicated snapshot collection.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]                                                [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $id,
    [Parameter(ParameterSetName='nonid')]   [string]  $name,
    [Parameter(ParameterSetName='nonid')]   [string]  $description,
    [Parameter(ParameterSetName='nonid')]                                             [ValidateSet( 'protection_template', 'volume_collection')]
                                            [string]  $volcoll_or_prottmpl_type,
    [Parameter(ParameterSetName='nonid')]                                             [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $volcoll_or_prottmpl_id,
    [Parameter(ParameterSetName='nonid')]   [long]    $period,
    [Parameter(ParameterSetName='nonid')]                                             [ValidateSet( 'hours', 'weeks', 'minutes', 'days')]  
                                            [string]  $period_unit,
    [Parameter(ParameterSetName='nonid')]   [long]    $at_time,
    [Parameter(ParameterSetName='nonid')]   [long]    $until_time,
    [Parameter(ParameterSetName='nonid')]   [string]  $days,
    [Parameter(ParameterSetName='nonid')]   [long]    $num_retain,
    [Parameter(ParameterSetName='nonid')]   [string]  $downstream_partner,
    [Parameter(ParameterSetName='nonid')]   [string]  $downstream_partner_name,
    [Parameter(ParameterSetName='nonid')]                                             [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $downstream_partner_id,
    [Parameter(ParameterSetName='nonid')]   [string]  $upstream_partner_name,
    [Parameter(ParameterSetName='nonid')]                                              [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $upstream_partner_id,
    [Parameter(ParameterSetName='nonid')]   [long]    $replicate_every,
    [Parameter(ParameterSetName='nonid')]   [long]    $num_retain_replica,
    [Parameter(ParameterSetName='nonid')]   [long]    $repl_alert_thres,
    [Parameter(ParameterSetName='nonid')]   [bool]    $snap_verify,
    [Parameter(ParameterSetName='nonid')]   [bool]    $skip_db_consistency_check,
    [Parameter(ParameterSetName='nonid')]   [bool]    $disable_appsync,
    [Parameter(ParameterSetName='nonid')]                                               [ValidateSet( 'external_trigger', 'regular')]
                                            [string]  $schedule_type,
    [Parameter(ParameterSetName='nonid')]   [bool]    $active,
    [Parameter(ParameterSetName='nonid')]   [string]  $last_replicated_snapcoll_name,
    [Parameter(ParameterSetName='nonid')]                                               [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $last_replicated_snapcoll_id
  )
process
  {
    $API = 'protection_schedules'
    $Param = @{
      ObjectName = 'ProtectionSchedule'
      APIPath = 'protection_schedules'
    }
    if ($id)
    {   # Get a single object for given Id.
        $Param.Id = $id
        $ResponseObject = Get-NimbleStorageAPIObject @Param
        return $ResponseObject
    }
    else
    {   # Get list of objects matching the given filter.
        $Param.Filter = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {   if ($key.ToLower() -ne 'fields')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                  {   $Param.Filter.Add("$($var.name)", ($var.value))
                  }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Set-NSProtectionSchedule {
<#
.SYNOPSIS
  Update a protection schedule.
.DESCRIPTION
  Update a protection schedule.
.PARAMETER id
  Identifier for protection schedule.
.PARAMETER name
  Name of snapshot schedule to create.
.PARAMETER description [<string>]
  Description of the schedule.
.PARAMETER period
  Repeat interval for snapshots with respect to the period_unit.  For example, a value of 2 with the 'period_unit' 
  of 'hours' results in one snapshot every 2 hours.
.PARAMETER period_unit
  Time unit over which to take the number of snapshots specified in 'period'. For example, a value of 'days' with 
  a 'period' of '1' results in one snapshot every day.
.PARAMETER at_time
  Time of day when snapshot should be taken. In case repeat frequency specifies more than one snapshot in a day then the
  until_time option specifies until what time of day to take snapshots.
.PARAMETER until_time
  Time of day to stop taking snapshots. Applicable only when repeat frequency specifies more than one snapshot in a day.
.PARAMETER days
  Specifies which days snapshots should be taken.
.PARAMETER num_retain
  Number of snapshots to retain. If replication is enabled on this schedule the array will always retain the latest replicated 
  snapshot, which may exceed the specified retention value. This is necessary to ensure efficient replication performance.
.PARAMETER downstream_partner
  Specifies the partner name if snapshots created by this schedule should be replicated.
.PARAMETER downstream_partner_id
  Specifies the partner ID if snapshots created by this schedule should be replicated. In an update operation, if snapshots 
  should be replicated, set this attribute to the ID of the replication partner. If snapshots should not be replicated, 
  set this attribute to the empty string.
.PARAMETER replicate_every
  Specifies which snapshots should be replicated. If snapshots are replicated and this option is not specified, every snapshot is replicated.
.PARAMETER num_retain_replica
  Number of snapshots to retain on the replica.
.PARAMETER repl_alert_thres
  Replication alert threshold in seconds. If the replication of a snapshot takes more than this amount of time to complete an alert will be generated. Enter 0 to disable this alert.
.PARAMETER snap_verify
  Run verification tool on snapshot created by this schedule. This option can only be used with snapshot schedules of a 
  protection template that has application synchronization. The tool used to verify snapshot depends on the type of application. 
  For example, if application synchronization is VSS and the application ID is Exchange, eseutil 
  tool is run on the snapshots. If verification fails, the logs are not truncated.
.PARAMETER skip_db_consistency_check
  Skip consistency check for database files on snapshots created by this schedule. This option only applies to snapshot 
  schedules of a protection template with application synchronization set to VSS, application ID set to MS Exchange 2010 
  or later w/DAG, this schedule's snap_verify option set to yes, and its disable_appsync option set to false. 
  Skipping consistency checks is only recommended if each database in a DAG has multiple copies.
.PARAMETER disable_appsync
  Disables application synchronized snapshots and creates crash consistent snapshots instead.
.PARAMETER schedule_type
  Normal schedules have internal timers which drive snapshot creation. An externally driven schedule has no internal timers. 
  All snapshot activity is driven by an external trigger. In other words, these schedules are used only for externally driven manual snapshots.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)][ValidatePattern('([0-9a-f]{42})')]
    [string]  $id,
    [string]  $name,
    [string]  $description,
    [long]    $period,
    [ValidateSet( 'hours', 'weeks', 'minutes', 'days')]
    [string]  $period_unit,
    [long]    $at_time,
    [long]    $until_time,
    [string]  $days,
    [long]    $num_retain,
    [string]  $downstream_partner,
    [ValidatePattern('([0-9a-f]{42})')]
    [string]  $downstream_partner_id,
    [long]    $replicate_every,
    [long]    $num_retain_replica,
    [long]    $repl_alert_thres,
    [bool]    $snap_verify,
    [bool]    $skip_db_consistency_check,
    [bool]    $disable_appsync,
    [ValidateSet( 'external_trigger', 'regular')]
    [string]  $schedule_type
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
            if ($key.ToLower() -ne 'id')
            {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {
                    $RequestData.Add("$($var.name)", ($var.value))
                }
            }
        }
        $Params = @{
            ObjectName = 'ProtectionSchedule'
            APIPath = 'protection_schedules'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSProtectionSchedule {
<#
.SYNOPSIS
  Delete a protection schedule.
.DESCRIPTION
  Delete a protection schedule.
.PARAMETER id
  Identifier for protection schedule. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]
        [string]$id
    )
process { $Params = @{  ObjectName = 'ProtectionSchedule'
                        APIPath = 'protection_schedules'
                        Id = $id
                    }
          Remove-NimbleStorageAPIObject @Params
        }
}
