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

# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAF0WwxF2z7
# g6UtZTQ3zHM10+T5dgExx0E60eWn7qIznFrD22h+dd4qGQF408XP/kDUZa1EHaYZ
# BkEnUtpkbMLAoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
# KoZIhvcNAQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExp
# bWl0ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0yMTA1
# MjUwMDAwMDBaFw0yODEyMzEyMzU5NTlaMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AI3nlBIiBCR0Lv8WIwKSirauNoWsR9QjkSs+3H3iMaBRb6yEkeNSirXilt7Qh2Mk
# iYr/7xKTO327toq9vQV/J5trZdOlDGmxvEk5mvFtbqrkoIMn2poNK1DpS1uzuGQ2
# pH5KPalxq2Gzc7M8Cwzv2zNX5b40N+OXG139HxI9ggN25vs/ZtKUMWn6bbM0rMF6
# eNySUPJkx6otBKvDaurgL6en3G7X6P/aIatAv7nuDZ7G2Z6Z78beH6kMdrMnIKHW
# uv2A5wHS7+uCKZVwjf+7Fc/+0Q82oi5PMpB0RmtHNRN3BTNPYy64LeG/ZacEaxjY
# cfrMCPJtiZkQsa3bPizkqhiwxgcBdWfebeljYx42f2mJvqpFPm5aX4+hW8udMIYw
# 6AOzQMYNDzjNZ6hTiPq4MGX6b8fnHbGDdGk+rMRoO7HmZzOatgjggAVIQO72gmRG
# qPVzsAaV8mxln79VWxycVxrHeEZ8cKqUG4IXrIfptskOgRxA1hYXKfxcnBgr6kX1
# 773VZ08oXgXukEx658b00Pz6zT4yRhMgNooE6reqB0acDZM6CWaZWFwpo7kMpjA4
# PNBGNjV8nLruw9X5Cnb6fgUbQMqSNenVetG1fwCuqZCqxX8BnBCxFvzMbhjcb2L+
# plCnuHu4nRU//iAMdcgiWhOVGZAA6RrVwobx447sX/TlAgMBAAGjggESMIIBDjAf
# BgNVHSMEGDAWgBSgEQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUMuuSmv81
# lkgvKEBCcCA2kVwXheYwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEE
# ATBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFD
# ZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAQEA
# Er+h74t0mphEuGlGtaskCgykime4OoG/RYp9UgeojR9OIYU5o2teLSCGvxC4rnk7
# U820+9hEvgbZXGNn1EAWh0SGcirWMhX1EoPC+eFdEUBn9kIncsUj4gI4Gkwg4tsB
# 981GTyaifGbAUTa2iQJUx/xY+2wA7v6Ypi6VoQxTKR9v2BmmT573rAnqXYLGi6+A
# p72BSFKEMdoy7BXkpkw9bDlz1AuFOSDghRpo4adIOKnRNiV3wY0ZFsWITGZ9L2PO
# mOhp36w8qF2dyRxbrtjzL3TPuH7214OdEZZimq5FE9p/3Ef738NSn+YGVemdjPI6
# YlG87CQPKdRYgITkRXta2DCCBeEwggRJoAMCAQICEQCZcNC3tMFYljiPBfASsES3
# MA0GCSqGSIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBD
# QSBSMzYwHhcNMjIwNjA3MDAwMDAwWhcNMjUwNjA2MjM1OTU5WjB3MQswCQYDVQQG
# EwJVUzEOMAwGA1UECAwFVGV4YXMxKzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBF
# bnRlcnByaXNlIENvbXBhbnkxKzApBgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRl
# cnByaXNlIENvbXBhbnkwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCi
# DYlhh47xvo+K16MkvHuwo3XZEL+eEWw4MQEoV7qsa3zqMx1kHryPNwVuZ6bAJ5OY
# oNch6usNWr9MZlcgck0OXnRGrxl2FNNKOqb8TAaoxfrhBSG7eZ1FWNqxJAOlzXjg
# 6KEPNdlhmfVvsSDolVDGr6yEXYK9WVhVtEApyLbSZKLED/0OtRp4CtjacOCF/unb
# vfPZ9KyMVKrCN684Q6BpknKH3ooTZHelvfAzUGbHxfKvq5HnIpONKgFhbpdZXKN7
# kynNjRm/wrzfFlp+m9XANlmDnXieTeKEeI3y3cVxvw9HTGm4yIFt8IS/iiZwsKX6
# Y94RkaDzaGB1fZI19FnRo2Fx9ovz187imiMrpDTsj8Kryl4DMtX7a44c8vORYAWO
# B17CKHt52W+ngHBqEGFtce3KbcmIqAH3cJjZUNWrji8nCuqu2iL2Lq4bjcLMdjqU
# +2Uc00ncGfvP2VG2fY+bx78e47m8IQ2xfzPCEBd8iaVKaOS49ZE47/D9Z8sAVjcC
# AwEAAaOCAYkwggGFMB8GA1UdIwQYMBaAFA8qyyCHKLjsb0iuK1SmKaoXpM0MMB0G
# A1UdDgQWBBRtaOAY0ICfJkfK+mJD1LyzN0wLzjAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBKBgNVHSAEQzBBMDUGDCsG
# AQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQ
# UzAIBgZngQwBBAEwSQYDVR0fBEIwQDA+oDygOoY4aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQVIzNi5jcmwweQYIKwYBBQUH
# AQEEbTBrMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNydDAjBggrBgEFBQcwAYYXaHR0cDov
# L29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggGBACPwE9q/9ANM+zGO
# lq4SZg7qDpsDW09bDbdjyzAmxxJk2GhD35Md0IluPppla98zFjnuXWpVqakGk9vM
# KxiooQ9QVDrKYtx9+S8Qui21kT8Ekhrm+GYecVfkgi4ryyDGY/bWTGtX5Nb5G5Gp
# DZbv6wEuu3TXs6o531lN0xJSWpJmMQ/5Vx8C5ZwRgpELpK8kzeV4/RU5H9P07m8s
# W+cmLx085ndID/FN84WmBWYFUvueR5juEfibuX22EqEuuPBORtQsAERoz9jStyza
# gj6QxPG9C4ItZO5LT+EDcHH9ti6CzxexePIMtzkkVV9HXB6OUjgeu6MbNClduKY4
# qFiutdbVC8VPGncuH2xMxDtZ0+ip5swHvPt/cnrGPMcVSEr68cSlUU26Ln2u/03D
# eZ6b0R3IUdwWf4K/1X6NwOuifwL9gnTM0yKuN8cOwS5SliK9M1SWnF2Xf0/lhEfi
# VVeFlH3kZjp9SP7v2I6MPdI7xtep9THwDnNLptqeF79IYoqT3TCCBhowggQCoAMC
# AQICEGIdbQxSAZ47kHkVIIkhHAowDQYJKoZIhvcNAQEMBQAwVjELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAwMFoXDTM2
# MDMyMTIzNTk1OVowVDELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIENBIFIz
# NjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJsrnVP6NT+OYAZDasDP
# 9X/2yFNTGMjO02x+/FgHlRd5ZTMLER4ARkZsQ3hAyAKwktlQqFZOGP/I+rLSJJmF
# eRno+DYDY1UOAWKA4xjMHY4qF2p9YZWhhbeFpPb09JNqFiTCYy/Rv/zedt4QJuIx
# eFI61tqb7/foXT1/LW2wHyN79FXSYiTxcv+18Irpw+5gcTbXnDOsrSHVJYdPE9s+
# 5iRF2Q/TlnCZGZOcA7n9qudjzeN43OE/TpKF2dGq1mVXn37zK/4oiETkgsyqA5lg
# AQ0c1f1IkOb6rGnhWqkHcxX+HnfKXjVodTmmV52L2UIFsf0l4iQ0UgKJUc2RGarh
# OnG3B++OxR53LPys3J9AnL9o6zlviz5pzsgfrQH4lrtNUz4Qq/Va5MbBwuahTcWk
# 4UxuY+PynPjgw9nV/35gRAhC3L81B3/bIaBb659+Vxn9kT2jUztrkmep/aLb+4xJ
# bKZHyvahAEx2XKHafkeKtjiMqcUf/2BG935A591GsllvWwIDAQABo4IBZDCCAWAw
# HwYDVR0jBBgwFoAUMuuSmv81lkgvKEBCcCA2kVwXheYwHQYDVR0OBBYEFA8qyyCH
# KLjsb0iuK1SmKaoXpM0MMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYEVR0gADAIBgZn
# gQwBBAEwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRv
# MG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAG/4Lhd2M2bnuhFSCb
# E/8E/ph1RGHDVpVx0ZE/haHrQECxyNbgcv2FymQ5PPmNS6Dah66dtgCjBsULYAor
# 5wxxcgEPRl05pZOzI3IEGwwsepp+8iGsLKaVpL3z5CmgELIqmk/Q5zFgR1TSGmxq
# oEEhk60FqONzDn7D8p4W89h8sX+V1imaUb693TGqWp3T32IKGfIgy9jkd7GM7YCa
# 2xulWfQ6E1xZtYNEX/ewGnp9ZeHPsNwwviJMBZL4xVd40uPWUnOJUoSiugaz0yWL
# ODRtQxs5qU6E58KKmfHwJotl5WZ7nIQuDT0mWjwEx7zSM7fs9Tx6N+Q/3+49qTtU
# vAQsrEAxwmzOTJ6Jp6uWmHCgrHW4dHM3ITpvG5Ipy62KyqYovk5O6cC+040Si15K
# JpuQ9VJnbPvqYqfMB9nEKX/d2rd1Q3DiuDexMKCCQdJGpOqUsxLuCOuFOoGbO7Uv
# 3RjUpY39jkkp0a+yls6tN85fJe+Y8voTnbPU1knpy24wUFBkfenBa+pRFHwCBB1Q
# tS+vGNRhsceP3kSPNrrfN2sRzFYsNfrFaWz8YOdU254qNZQfd9O/VjxZ2Gjr3xgA
# NHtM3HxfzPYF6/pKK8EE4dj66qKKtm2DTL1KFCg/OYJyfrdLJq1q2/HXntgr2GVw
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG58wghubAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQDuE+1GoJzKcTmBrgyttA5fZZnBaIJrvb+TjVShgzE8pPskY+FCISa16
# zEF87n6HJPV/RQoSsM4TMSFs9eEuVccwDQYJKoZIhvcNAQEBBQAEggGAXn0z9kG2
# 7V+TDEEDzwFyJqfcWawqx2Kqnqf2NdG4jXU1MrygRtnH0MdBY2diG4Rr9zUrjPF/
# 4rq4Qosnj7TCpwRP33U5qpwkcmoxvqlXS8ZvOqvDjVvPPQZp0aihVU7TJ9RGwR/f
# zVdrzlQJP9NZhY3bmNjA1DgA9nR0OBIYrUcbXf9dxxijQcgIn/SV7BIFE++qHJhL
# hYsdMZgvqbJHCnEI3eepU8giz0aF5RFjZYTJCAS5mKOJk5YDB45X2TtkdDGy10+P
# Yw6FisXlZIuW1MLnQ0QJNWswYTinHSfx/HXJ77xggkhDzfMnS/VSgDgVJTIpGoTc
# alFu2ttUya8/JwpK4G2+o7w+BYRmw+15CxJGl/gg04eJMZm0KH9kvD9VYILNrHJm
# j9qMFm2NSqeSsBbG0rxt1+baNLbjRMpOtJ1tHBPTPPVdRXKjnRQ2S3xZOU0HDQ13
# pxg/MLOEp+UJK4YZDYh1aBjvC2mp3QPVNbuTAk6D+1LkuP58BFiF/U9goYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMOAfrdQER7JfhSY2pLTpn2MhnaQuGJeu
# Vq77GqHBJujl5cyWPxyZrSguBhc2wq9KNgIUKdLznV66QQMaxDOIRGu6ELyRmbEY
# DzIwMjUwNTE1MjIzMzUxWqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
# c3QgWW9ya3NoaXJlMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMT
# J1NlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNqCCEwQwggZi
# MIIEyqADAgECAhEApCk7bh7d16c0CIetek63JDANBgkqhkiG9w0BAQwFADBVMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNTAzMjcwMDAw
# MDBaFw0zNjAzMjEyMzU5NTlaMHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5XZXN0
# IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzYwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDThJX0bqRTePI9EEt4Egc83JSBU2dhrJ+w
# Y7JgReuff5KQNhMuzVytzD+iXazATVPMHZpH/kkiMo1/vlAGFrYN2P7g0Q8oPEcR
# 3h0SftFNYxxMh+bj3ZNbbYjwt8f4DsSHPT+xp9zoFuw0HOMdO3sWeA1+F8mhg6uS
# 6BJpPwXQjNSHpVTCgd1gOmKWf12HSfSbnjl3kDm0kP3aIUAhsodBYZsJA1imWqkA
# VqwcGfvs6pbfs/0GE4BJ2aOnciKNiIV1wDRZAh7rS/O+uTQcb6JVzBVmPP63k5xc
# ZNzGo4DOTV+sM1nVrDycWEYS8bSS0lCSeclkTcPjQah9Xs7xbOBoCdmahSfg8Km8
# ffq8PhdoAXYKOI+wlaJj+PbEuwm6rHcm24jhqQfQyYbOUFTKWFe901VdyMC4gRwR
# Aq04FH2VTjBdCkhKts5Py7H73obMGrxN1uGgVyZho4FkqXA8/uk6nkzPH9QyHIED
# 3c9CGIJ098hU4Ig2xRjhTbengoncXUeo/cfpKXDeUcAKcuKUYRNdGDlf8WnwbyqU
# blj4zj1kQZSnZud5EtmjIdPLKce8UhKl5+EEJXQp1Fkc9y5Ivk4AZacGMCVG0e+w
# wGsjcAADRO7Wga89r/jJ56IDK773LdIsL3yANVvJKdeeS6OOEiH6hpq2yT+jJ/lH
# a9zEdqFqMwIDAQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNh
# lxmiMpswHQYDVR0OBBYEFIhhjKEqN2SBKGChmzHQjP0sAs5PMA4GA1UdDwEB/wQE
# AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1Ud
# IARDMEEwNQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8v
# Y3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5j
# cmwwegYIKwYBBQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYB
# BQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IB
# gQACgT6khnJRIfllqS49Uorh5ZvMSxNEk4SNsi7qvu+bNdcuknHgXIaZyqcVmhrV
# 3PHcmtQKt0blv/8t8DE4bL0+H0m2tgKElpUeu6wOH02BjCIYM6HLInbNHLf6R2qH
# C1SUsJ02MWNqRNIT6GQL0Xm3LW7E6hDZmR8jlYzhZcDdkdw0cHhXjbOLsmTeS0Se
# RJ1WJXEzqt25dbSOaaK7vVmkEVkOHsp16ez49Bc+Ayq/Oh2BAkSTFog43ldEKgHE
# DBbCIyba2E8O5lPNan+BQXOLuLMKYS3ikTcp/Qw63dxyDCfgqXYUhxBpXnmeSO/W
# A4NwdwP35lWNhmjIpNVZvhWoxDL+PxDdpph3+M5DroWGTc1ZuDa1iXmOFAK4iwTn
# lWDg3QNRsRa9cnG3FBBpVHnHOEQj4GMkrOHdNDTbonEeGvZ+4nSZXrwCW4Wv2qyG
# DBLlKk3kUW1pIScDCpm/chL6aUbnSsrtbepdtbCLiGanKVR/KC1gsR0tC6Q0RfWO
# I4owggYUMIID/KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUA
# MFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNV
# BAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AM2Y2ENBq26CK+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStS
# VjeYXIjfa3ajoW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQ
# BaCxpectRGhhnOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE
# 9cbY11XxM2AVZn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExS
# Lnh+va8WxTlA+uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OII
# q/fWlwBp6KNL19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGd
# F+z+Gyn9/CRezKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w
# 76kOLIaFVhf5sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4Cllg
# rwIDAQABo4IBXDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUw
# HQYDVR0OBBYEFF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjAS
# BgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28u
# Y29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEF
# BQcBAQRwMG4wRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0O
# NVgMnoEdJVj9TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc
# 6ZvIyHI5UkPCbXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1
# OSkkSivt51UlmJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz
# 2wSKr+nDO+Db8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y
# 4Il6ajTqV2ifikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVM
# CMPY2752LmESsRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBe
# Nh9AQO1gQrnh1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupia
# AeNHe0pWSGH2opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU
# +CCQaL0cJqlmnx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/Sjws
# usWRItFA3DE8MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7
# xpMeYRriWklUPsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs6
# 56Oz3TbLyXVoMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAs
# BgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJ
# BZvMWhUP2ZQQRLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQn
# Oh2qmcxGzjqemIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypo
# GJrruH/drCio28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0p
# KG9ki+PC6VEfzutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13j
# QEV1JnUTCm511n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9
# YrcmXcLgsrAimfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/y
# Vl4jnDcw6ULJsBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVg
# h60KmLmzXiqJc6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/
# OLoanEWP6Y52Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+Nr
# LedIxsE88WzKXqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58N
# Hs57ZPUfECcgJC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9U
# gOHYm8Cd8rIDZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1Ud
# DwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0
# eS5jcmwwNQYIKwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3
# OyWM637ayBeR7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJ
# JlFfym1Doi+4PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0m
# UGQHbRcF57olpfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTw
# bD/zIExAopoe3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i
# 111TW7HV1AtsQa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGe
# zjM6CRpcWed/ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+
# 8aW88WThRpv8lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH
# 29308ZkpKKdpkiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrs
# xrYJD+3f3aKg6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6
# Ii8+CQOYDwXM+yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz
# 7NgAnOgpCdUo4uDyllU9PzGCBJIwggSOAgEBMGowVTELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMg
# VGltZSBTdGFtcGluZyBDQSBSMzYCEQCkKTtuHt3XpzQIh616TrckMA0GCWCGSAFl
# AwQCAgUAoIIB+TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTI1MDUxNTIyMzM1MVowPwYJKoZIhvcNAQkEMTIEMGz3/44WXL01q7bC
# orNLwdacD+ANOC8AQid1+YD/4J4Q5FqfKaUhmoTJShsSlXG+TzCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAhXaaDdb6o/hw5RATgwU3Ou4uaKH0UHsqwC8jKf4UW7v1f6mR0fDGQ2PI
# HnzrOuk7ajX8pbUoItn9ST6zLk2Q/jtdtPyeC77ziikKNDOaOuirFwV9P5w0V+Bb
# xaqxv7a5xObs7KzIE9W2DWKkdVwBh6WrIfSa6nf1fkQOjUjJJodbUbneCOBO7TGA
# YAuujUni/EpZmBqXoZr8pizwodSmmKeKqcQzF+OJDAZmCLTdLvMF6lOPR8uYbFTo
# 2lwJGLF5J2PkYym5x+DI+mqFTPIJUTCc/4lJqWGm29ffcEgCtrn0c//uKkc1NPE1
# aLGj3HHhu/EzydVrvhM7DU2Bvm+JBOuNWFflK/CKH4OP5L0RRspcPscZBquEMDmU
# 2ME87ZhfeI3X5HqwDC/p/K0EFtl0a7LqsCe9ltF11BVMWc6Vx6dYlcolffjRsEY/
# 4u7rFS0xRZ/62KDlchCSo7/I7wY6qIyHcYiUjwxnPifptJZCuwWMchyz9VIsJ0Iz
# HPhINg68ATFuGz5eR+sQ6hr+g2odsm6c7gPMQcCZSsmpN+/R7hnqmS1cGuE526ll
# HUfY8qiFF7NjQR5z+M00nExgxKG0ePijnY2cTP/vQfWa0uh+iULUDJexli+jEG0u
# luKIsgMPJivwjVq/oa+RS1kKCliIdv71uRl2IhFZp2/zOed90J4=
# SIG # End signature block
