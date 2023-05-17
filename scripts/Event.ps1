# Event.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSEvent {
<#
.SYNOPSIS
  List a set of event records or a single event record.
.DESCRIPTION
  List a set of event records or a single event record. A special note that this command can take an exceptionally long time to complete as 
  the number of log events can be very large and no output will occur until the last record is retrieved.
.PARAMETER id
  Identifier for the event record. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER scope
  The array name for array level event. Possible values: array serial number, or '-'. Example: 'AC-109084'.
.PARAMETER target
  Name of object upon which the event occurred. String of up to 400 alphanumeric characters, - and . and : and " " are allowed 
  after first character. Example: 'volumes in performance policy default'.
.PARAMETER target_type
  Target type of the event record. Possible values: 'anon', 'array', 'controller', 'disk', 'nic', 'temperature', 'service', 'volume', 
  'protection_set', 'nvram', 'fan', 'power_supply', 'partner', 'raid', 'test', 'iscsi', 'pool', 'group', 'shelf', 'ntb', 'fc', 'initiator_group'.
.PARAMETER category
  Category of the event record. Possible values: 'unknown', 'hardware', 'service', 'replication', 'volume', 'update', 'configuration', 'test', 'security'.
.PARAMETER severity
  Severity level of the event. Possible values: 'info', 'notice', 'warning', 'critical'.
.PARAMETER alarm_id
  The alarm ID if the event is related to an alarm. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')][ValidatePattern('([0-9a-f]{42})')]                         [string] $id,
    [Parameter(ParameterSetName='nonId')]                                                         [string]$scope,
    [Parameter(ParameterSetName='nonId')]                                                         [string]$target,
    [Parameter(ParameterSetName='nonId')][ValidateSet('anon','controller','test','protection_set','pool','nic','shelf','volume','disk','fan','iscsi','nvram', 
                  'power_supply','partner','array','service','temperature','ntb','fc','initiator_group','raid','group')]
                                                                                                  [string]$target_type,
    [Parameter(ParameterSetName='nonId')][ValidateSet('replication','volume','security','test','cloud_console','configuration','service','update','array_upgrade','unknown', 'hardware')]
                                                                                                  [string]$category,
    [Parameter(ParameterSetName='nonId')][ValidateSet( 'critical', 'warning', 'info', 'notice')]  [string]$severity,
    [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{42})')]                      [string]$alarm_id
  )
process{ 
    $API = 'events'
    $Param = @{ ObjectName =  'Event'
                APIPath =     'events'
              }
    if ($id)
        { # Get a single object for given Id.
          $Param.Id = $id
          $ResponseObject = Get-NimbleStorageAPIObject @Param
          return $ResponseObject
        }
      else
        { # Get list of objects matching the given filter.
          $Param.Filter = @{}
          $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
          foreach ($key in $ParameterList.keys)
            { if ($key.ToLower() -ne 'fields')
                { $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                  if($var -and ($PSBoundParameters.ContainsKey($key)))
                    { $Param.Filter.Add("$($var.name)", ($var.value))
                    }
                }
            }
          $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
          return $ResponseObjectList
        }
  }
}