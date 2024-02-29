# AuditLog.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSAuditLog {
<#
.SYNOPSIS
  List a set of audit log entries or a single audit log record.
.DESCRIPTION
  List a set of audit log entries or a single audit log record.
.PARAMETER id
  Identifier for the audit log record. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER object_id
  Identifier of object operated upon. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER object_name
  Name of object operated upon. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER object_type
  Type of the object being operated upon. Possible values: 'active_directory', 'group', 'chapuser', 'initiatorgrp', 'perfpolicy', 'snapshot', 
  'snapcoll', 'vol', 'volcoll', 'partner', 'array', 'pool', 'initiator', 'protsched', 'volacl', 'throttle', 'sshkey', 'user', 'protpol', 'prottmpl', 
  'branch', 'route', 'role', 'privilege', 'netconfig', 'events', 'session', 'subnet', 'array_netconfig', 'nic', 'initiatorgrp_subnet', 'fc_initiator_alias', 
  'fc_port', 'fc_interface_collection', 'fc', 'event_dipatcher', 'fc_target_port_group', 'encrypt_key', 'encrypt_config', 'snapshot_lun', 'syslog', 
  'async_job', 'application_server', 'audit_log', 'ip address', 'disk', 'shelf', 'protocol_endpoint', 'folder', 'pe_acl', 'vvol', 'vvol_acl', 'alarm'.	 
.PARAMETER scope
  Scope within which object exists, for example, name of the array for a NIC. Possible values: array serial number, or '-'. Example: 'AC-109084'.
.PARAMETER status
  Status of the operation -- success or failure. 
  Possible values: 'invalid', 'unknown', 'succeeded', 'failed', 'inprogress'.
.PARAMETER error_code
  If the operation has failed, this indicates the error code corresponding to the failure. 
  Non-negative integer in range [0,9000].
.PARAMETER user_id
  Identifier of the user who performed the operation. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER user_name
  Username of the user who performed the operation. 
  String of up to 32 alphanumeric characters, beginning with a letter. Or
.PARAMETER user_full_name
  Full name of the user who performed the operation. 
  Alphanumeric string of up to 64 chars, starts with letter, can include space, apostrophe('), hyphen(-). Example: 'User-13 Peterson'.
.PARAMETER source_ip
  IP address from where the operation request originated. 
  Four numbers in the range [0,255] separated by periods. Example: '128.0.0.1'.
.PARAMETER ext_user_id
  The user id of an external user. String of up to 255 printable ASCII characters. Example: 'S_aba-123'.
.PARAMETER ext_user_group_id
  The group ID of an external user. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER ext_user_group_name
  The group name of an external user. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER app_name
  Name of application from where the operation request was issued, 
  for example, pam, VSS Agent, etc. String of 0-255 printable ASCII characters. Example: 'GUI'.
.PARAMETER access_type
  Name of access on how the operation request was issued, 
  for example, GUI, CLI or API. Possible values: 'GUI', 'CLI', 'API'.
.PARAMETER category
  Category of the audit log record. 
  Possible values: 'data_provisioning', 'data_protection', 'data_access', 'user_access', 'system_configuration', 'software_update'.
.PARAMETER activity_type
  Type of activity performed, 
  for example, create, update or delete. Possible values: 'create', 'read', 'update', 'delete', 'other'.
.PARAMETER activity
  Description of activity performed and recorded in audit log. 
  String of 1-1476 printable characters. Example: 'Created snapshot % of volume %'.
.EXAMPLE
  C:\> Get-NSAuditLog

  user_name              activity                     category               status      time
  ---------              --------                     --------               ------      ----
  admin                  Login attempt                user_access            succeeded   1513640687
  admin                  Complete setup on group g... system_configuration   succeeded   1513640688
  admin                  Login attempt                user_access            succeeded   1513640721
  admin                  Create volume CHAPI-Testvol1 data_provisioning      succeeded   1513640935
  admin                  Add ACL for volume CHAPI-... data_access            succeeded   1513640935

  This command will retrieves list of audit log entries.
.EXAMPLE
  C:\> Get-NSAuditLog -status failed

  user_name              activity                     category               status      time
  ---------              --------                     --------               ------      ----
  admin                  Validate network configur... system_configuration   failed      1513671364
  admin                  Validate network configur... system_configuration   failed      1513759916
  admin                  Validate network configur... system_configuration   failed      1513845695
  admin                  Validate network configur... system_configuration   failed      1513929821
  admin                  Validate network configur... system_configuration   failed      1514018428

  This command will retrieves list of audit log entries that are marked as failed status.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]                                    [ValidatePattern('([0-9a-f]{42})')]
                                          [string]  $id,
    [Parameter(ParameterSetName='nonId')]                                 [ValidatePattern('([0-9a-f]{42})')]
                                          [string]  $object_id,
    [Parameter(ParameterSetName='nonId')] [string]  $object_name,
    [Parameter(ParameterSetName='nonId')] [ValidateSet( 'array_netconfig', 'user_policy', 'subnet', 'encrypt_key', 'initiator', 'keymanager', 'nic', 'branch', 'fc_target_port_group', 
                                                        'prottmpl', 'protpol', 'sshkey', 'fc_interface_collection', 'volcoll', 'initiatorgrp_subnet', 'pe_acl', 'vvol_acl', 'chapuser', 
                                                        'events', 'application_server', 'group', 'pool', 'vvol', 'active_directory', 'shelf', 'disk', 'route', 'folder', 'ip address', 
                                                        'fc', 'support', 'snapshot', 'throttle', 'role', 'snapcoll', 'session', 'async_job', 'initiatorgrp', 'perfpolicy', 'privilege', 
                                                        'syslog', 'user group', 'protsched', 'netconfig', 'vol', 'fc_initiator_alias', 'array', 'trusted_oauth_issuer', 'alarm', 
                                                        'fc_port', 'protocol_endpoint', 'folset', 'audit_log', 'hc_cluster_config', 'encrypt_config', 'witness', 'partner', 'snapshot_lun', 
                                                        'event_dipatcher', 'volacl', 'user')]
                                          [string]  $object_type,
    [Parameter(ParameterSetName='nonId')] [string]  $scope,
    [Parameter(ParameterSetName='nonId')]                                 [ValidateSet( 'inprogress', 'failed', 'unknown', 'succeeded')]
                                          [string]  $status,
    [Parameter(ParameterSetName='nonId')] [string]  $error_code,
    [Parameter(ParameterSetName='nonId')]                                 [ValidatePattern('([0-9a-f]{42})')] 
                                          [string]  $user_id,
    [Parameter(ParameterSetName='nonId')] [string]  $user_name,
    [Parameter(ParameterSetName='nonId')] [string]  $user_full_name,
    [Parameter(ParameterSetName='nonId')] [string]  $source_ip,
    [Parameter(ParameterSetName='nonId')]                                 [ValidatePattern('([0-9a-f]{42})')] 
                                          [string]  $ext_user_id,
    [Parameter(ParameterSetName='nonId')]                                 [ValidatePattern('([0-9a-f]{42})')] 
                                          [string]  $ext_user_group_id,
    [Parameter(ParameterSetName='nonId')] [string]  $ext_user_group_name,
    [Parameter(ParameterSetName='nonId')] [string]  $app_name,
    [Parameter(ParameterSetName='nonId')] [string]  $access_type,
    [Parameter(ParameterSetName='nonId')]                                 [ValidateSet( 'data_protection', 'system_configuration', 'software_update', 'user_access', 'data_access', 'data_provisioning')]
                                          [string]  $category,
    [Parameter(ParameterSetName='nonId')]                                 [ValidateSet( 'other', 'read', 'create', 'update', 'delete')]
                                          [string]  $activity_type,
    [Parameter(ParameterSetName='nonId')] [string]  $activity
  )
process{ 
    $API = 'audit_log'
    $Param = @{ ObjectName = 'AuditLog'
                APIPath = 'audit_log'
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


