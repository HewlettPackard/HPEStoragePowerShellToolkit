# Alarm.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSAlarm {
<#
.SYNOPSIS
  List a set of alarms or a single alarm.
.DESCRIPTION
  List a set of alarms or a single alarm.
.PARAMETER id 
  Identifier for the alarm. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER type
  Identifier for type of alarm. 
  Non-negative integer in range [0,2147483647].
.PARAMETER array
  The array name where the alarm is generated. Possible values: array serial number, or '-'. Example: 'AC-109084'.
.PARAMETER curr_onset_event_id
  Identifier for the current onset event. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER object_id
  Identifier of object operated upon. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER object_name
  Name of object operated upon. 
  String of up to 400 alphanumeric characters, - and . and : and " " are allowed after first character. Example: 'volumes in performance policy default'.	
.PARAMETER object_type
  Type of the object being operated upon. Possible values: 'active_directory', 'group', 'chapuser', 'initiatorgrp', 'perfpolicy', 'snapshot', 'snapcoll', 
  'vol', 'volcoll', 'partner', 'array', 'pool', 'initiator', 'protsched', 'volacl', 'throttle', 'sshkey', 'user', 'protpol', 'prottmpl', 'branch', 'route', 
  'role', 'privilege', 'netconfig', 'events', 'session', 'subnet', 'array_netconfig', 'nic', 'initiatorgrp_subnet', 'fc_initiator_alias', 'fc_port', 
  'fc_interface_collection', 'fc', 'event_dipatcher', 'fc_target_port_group', 'encrypt_key', 'encrypt_config', 'snapshot_lun', 'syslog', 'async_job', 
  'application_server', 'audit_log', 'ip address', 'disk', 'shelf', 'protocol_endpoint', 'folder', 'pe_acl', 'vvol', 'vvol_acl', 'alarm'.
.PARAMETER status
  Status of the operation -- open or acknowledged. Possible values: 'open', 'acknowledged'.	 
.PARAMETER user_id
  Identifier of the user who acknowledged the alarm. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER user_name
  Username of the user who acknowledged the alarm. String of up to 80 alphanumeric characters, beginning with a letter. 
  For Active Directory users, it can include backslash (\), dash (-), period (.), underscore (_) and space. Example: 'user1', 'companydomain\user1'.	 
.PARAMETER user_full_name
  Full name of the user who acknowledged the alarm. Alphanumeric string of up to 64 chars, 
  starts with letter, can include space, apostrophe('), hyphen(-). Example: 'User-13 Peterson'.
.PARAMETER category
  Category of the alarm. Possible values: 'unknown', 'hardware', 'service', 'replication', 'volume', 'update', 'configuration', 'test', 'security'.
.PARAMETER severity
  Severity level of the event. Possible values: 'warning', 'critical'.
.PARAMETER remind_every
  Frequency of notification. This number and the remind_every_unit define how frequent one alarm notification is sent. 
  For example, a value of 1 with the 'remind_every_unit' of 'days' results in one notification every day. Frequency of alarm notification.
.PARAMETER remind_every_unit
  Time unit over which to send the number of notification specified in 'remind_every'. For example, a value of 'days' with 
  a 'remind_every' of '1' results in one notification every day. Possible values: 'minutes', 'hours', 'days', 'weeks'.
.PARAMETER activity
  Description of activity performed and recorded in alarm. String of 1-1476 printable characters. Example: 'Created snapshot % of volume %'.
.EXAMPLE
  C:\> Get-NSAlarm

  id                                         remind_every remind_every_unit severity status category activity
  --                                         ------------ ----------------- -------- ------ -------- --------
  3c1bde905fd66eed40000000000000000000000001 1            days              warning  open   volume   Volume vol1.striped space usage at 4% is above its reserve at 2%. It will be t...

  This command will retrieves list of current alarms.
.EXAMPLE
  C:\> Get-NSAlarm -severity warning

  id                                         remind_every remind_every_unit severity status category activity
  --                                         ------------ ----------------- -------- ------ -------- --------
  3c1bde905fd66eed40000000000000000000000001 1            days              warning  open   volume   Volume vol1.striped space usage at 4% is above its reserve at 2%. It will be t...

  This command will retrieves list of current alarms of a given severity.
.EXAMPLE
  C:\> Get-NSAlarm -status open

  id                                         remind_every remind_every_unit severity status category activity
  --                                         ------------ ----------------- -------- ------ -------- --------
  3c1bde905fd66eed40000000000000000000000001 1            days              warning  open   volume   Volume vol1.striped space usage at 4% is above its reserve at 2%. It will be t...

  This command will retrieves list of current alarms that are open.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')] [ValidatePattern('([0-9a-f]{42})')]    [string]  $id,
    [Parameter(ParameterSetName='nonId')]                                     [int]     $type,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $array,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')] [string]  $curr_onset_event_id,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')] [string]  $object_id,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $object_name,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'array_netconfig', 'user_policy', 'subnet', 'encrypt_key', 'initiator', 'keymanager', 'nic', 'branch', 'fc_target_port_group', 'prottmpl', 'protpol', 'sshkey', 
                  'fc_interface_collection', 'volcoll', 'initiatorgrp_subnet', 'pe_acl', 'vvol_acl', 'chapuser', 'events', 'application_server', 'group', 'pool', 'vvol', 
                  'active_directory', 'shelf', 'disk', 'route', 'folder', 'ip address', 'fc', 'support', 'snapshot', 'throttle', 'role', 'snapcoll', 'session', 'async_job', 
                  'initiatorgrp', 'perfpolicy', 'privilege', 'syslog', 'user group', 'protsched', 'netconfig', 'vol', 'fc_initiator_alias', 'array', 'trusted_oauth_issuer', 
                  'alarm', 'fc_port', 'protocol_endpoint', 'folset', 'audit_log', 'hc_cluster_config', 'encrypt_config', 'witness', 'partner', 'snapshot_lun', 'event_dipatcher', 
                  'volacl', 'user')]                                          [string]  $object_type,
    [Parameter(ParameterSetName='nonId')] [ValidateSet('acknowledged','open')][string]  $status,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')] [string]  $user_id,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $user_name,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $user_full_name,
    [Parameter(ParameterSetName='nonId')] [ValidateSet( 'replication', 'volume', 'security', 'test', 'cloud_console', 'configuration', 'service', 'update', 
    'array_upgrade', 'unknown', 'hardware')]                                  [string]  $category,
    [Parameter(ParameterSetName='nonId')] [ValidateSet('critical','warning')] [string]  $severity,
    [Parameter(ParameterSetName='nonId')]                                     [int]     $remind_every,
    [Parameter(ParameterSetName='nonId')] [ValidateSet('hours','weeks','minutes','days')]
                                                                              [string]  $remind_every_unit,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $activity
  )
process{ 
    $API = 'alarms'
    $Param = @{ ObjectName = 'Alarm'
                APIPath = 'alarms'
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
        {
            if ($key.ToLower() -ne 'fields')
            {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {
                    $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Set-NSAlarm {
<#
.SYNOPSIS
  Update an alarm.
.DESCRIPTION
  Update an alarm.
.PARAMETER id
  Identifier for the alarm. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER remind_every
  Frequency of notification. This number and the remind_every_unit define how frequent one alarm 
  notification is sent. For example, a value of 1 with the 'remind_every_unit' of 'days' results 
  in one notification every day.
.PARAMETER remind_every_unit
  Time unit over which to send the number of notification specified in 'remind_every'. For example, 
  a value of 'days' with a 'remind_every' of '1' results in one notification every day.
.EXAMPLE
  C:\> Set-nsAlarm -id 3c1bde905fd66eed40000000000000000000000001 -remind_every 1 -remind_every_unit days

  id                                         remind_every remind_every_unit severity status       category activity
  --                                         ------------ ----------------- -------- ------       -------- --------
  3c1bde905fd66eed40000000000000000000000001 1            days              warning  acknowledged volume   Volume vol1.striped space usage at 4% is above its reserve at 2%. It wil...

  This command will update the given alarm to be reminded every 1 day.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]                 [string]$id,
    [Parameter(Mandatory = $True)]                      [long] $remind_every,
    [ValidateSet( 'hours', 'weeks', 'minutes', 'days')] [string] $remind_every_unit
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
            ObjectName = 'Alarm'
            APIPath = 'alarms'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSAlarm {
<#
.SYNOPSIS
  Delete an alarm with the given ID.
.DESCRIPTION
  Delete an alarm with the given ID.
.PARAMETER id
  Identifier for the alarm. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE
C:\> Remove-NSAlarm -id 0d28eada7f8dd99d3b000000000000000000000053

  This command will remove an existing alarm.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]$id
  )
process {
    $Params = @{
        ObjectName = 'Alarm'
        APIPath = 'alarms'
        Id = $id
    }
    Remove-NimbleStorageAPIObject @Params
  }
}

function Clear-NSAlarm {
<#
.SYNOPSIS
  Acknowledge an alarm.
.DESCRIPTION
  Acknowledge an alarm.
.PARAMETER id
  ID of the acknowledged alarm. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER remind_every
  Notification frequency unit. Frequency of alarm notification.
.PARAMETER remind_every_unit
  Period unit. Possible values: 'minutes', 'hours', 'days', 'weeks'.
.EXAMPLE 
  C:\> Clear-nsAlarm -id 3c1bde905fd66eed40000000000000000000000001

  data
  ----
  @{ack_time=1533274094; activity=Volume vol1.striped space usage at 4% is above its reserve at 2%. It will be taken offline once the free space has been exhausted.; array=-; cate...

  This command clears (or acknowledges) a current alarm.
.EXAMPLE
  C:\> Clear-nsAlarm -id 3c1bde905fd66eed40000000000000000000000001 -remind_every 1 -remind_every_unit hours

  data
  ----
  @{ack_time=1533274095; activity=Volume vol1.striped space usage at 4% is above its reserve at 2%. It will be taken offline once the free space has been exhausted.; array=-; cate...

  This command clears (or acknowledges) a current alarm, however will only silence the alarm for the designated timeframe of 1 hour.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]                 [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True)]  [long]$remind_every,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [ValidateSet( 'hours', 'weeks', 'minutes', 'days')] [string]$remind_every_unit
  )
process{
    $Params = @{
        APIPath = 'alarms'
        Action = 'acknowledge'
        ReturnType = 'void'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    if ( $ResponseObject.data )
    {   return $ResponseObject.data 
    }
  else 
    {   return $ResponseObject
    }
  }
}

function Undo-NSAlarm {
<#
.SYNOPSIS
  Unacknowledge an alarm.
.DESCRIPTION
  Unacknowledge an alarm.
.PARAMETER id
  ID of the acknowledged alarm. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE
  C:\> Undo-nsAlarm -id 3c1bde905fd66eed40000000000000000000000001

  data
  ----
  @{ack_time=0; activity=Volume vol1.striped space usage at 4% is above its reserve at 2%. It will be taken offline once the free space has been exhausted.; array=-; category=volu...

  This command will reset the acknowledgement status current alarm back to an unacknowledged state.
#>  
[CmdletBinding()]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]
        [string]$id
    )
process{
    $Params = @{
        APIPath = 'alarms'
        Action = 'unacknowledge'
        ReturnType = 'void'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }
    
    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    if ( $ResponseObject.data )
      {   return $ResponseObject.data 
      }
    else 
      {   return $ResponseObject
      }
}
}