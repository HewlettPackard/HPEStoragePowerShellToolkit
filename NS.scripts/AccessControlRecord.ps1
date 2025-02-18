# AccessControlRecord.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSAccessControlRecord 
{
<#
.SYNOPSIS
    Add an access control record to the specified volume.
.DESCRIPTION
    Add an access control record to the specified volume. An access control record is used to connect a 
    host (via a host group or host record) to a Volume (storage lun). 
.PARAMETER apply_to
  Type of object this access control record applies to. 
  Possible values: 'volume', 'snapshot', 'both', 'pe', 'vvol_volume', 'vvol_snapshot'.
.PARAMETER chap_user_id
  Identifier for the CHAP user. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER initiator_group_id
  Identifier for the initiator group. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER lun
  If this access control record applies to a regular volume, this attribute is the volume's LUN (Logical Unit Number). 
  If the access protocol is iSCSI, the LUN will be 0. However, if the access protocol is Fibre Channel, the LUN will 
  be in the range from 0 to 2047. If this record applies to a Virtual Volume, this attribute is the volume's secondary 
  LUN in the range from 0 to 199999, for both iSCSI and Fibre Channel. If the record applies to a OpenstackV2 volume, 
  the LUN will be in the range from 0 to 2047, for both iSCSI and Fibre Channel. If this record applies to a protocol 
  endpoint or only a snapshot, this attribute is not meaningful and is set to null.
.PARAMETER vol_id
  Identifier for the volume this access control record applies to. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER pe_id
  Identifier for the protocol endpoint this access control record applies to. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
  (ID of the protocol endpoint. If this record applies to a protocol endpoint or a Virtual Volume, 
  this attribute is required. Otherwise, this attribute is not meaningful and should not be specified.)
.PARAMETER snap_id
  Identifier for the snapshot this access control record applies to. A 42 digit hexadecimal number. 
  Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER pe_ids
  List of candidate protocol endpoints that may be used to access the Virtual Volume. One of them will be selected for the access control record. 
  This field is required only when creating an access control record for a Virtual Volume. A list of object ids.
.EXAMPLE
  C:\> New-NSAccessControlRecord -initiator_group_id 0228eada7f8dd99d3b000000000000000000000056 -vol_id 0628eada7f8dd99d3b0000000000000000000000ca

  vol_name    Initiator_group_name Apply_to Lun snap_name id
  --------    -------------------- -------- --- --------- --
  TestVol-184 TestInit-158         both     0             0d28eada7f8dd99d3b000000000000000000000054

  This command will create a new access control record.
#>
[CmdletBinding(DefaultParameterSetName='Volume')]
param(
    [Parameter(ParameterSetName='Volume')]
    [Parameter(ParameterSetName='vVol')]
    [ValidateSet( 'volume', 'pe', 'vvol_volume', 'vvol_snapshot', 'snapshot', 'both')]
                                            [string]    $apply_to,
    [Parameter(ParameterSetName='Volume')]
    [Parameter(ParameterSetName='vVol')]
    [ValidatePattern('([0-9a-f]{42})')]     [string]    $chap_user_id,
    [Parameter(ParameterSetName='Volume')]
    [Parameter(ParameterSetName='vVol')]
    [ValidatePattern('([0-9a-f]{42})')]     [string]    $initiator_group_id,
    [Parameter(ParameterSetName='Volume')]
    [Parameter(ParameterSetName='vVol')]    [int]       $lun,
    [Parameter(ParameterSetName='Volume')]
    [Parameter(ParameterSetName='vVol')]
    [ValidatePattern('([0-9a-f]{42})')]     [string]    $vol_id,
    [Parameter(ParameterSetName='vVol')]
    [ValidatePattern('([0-9a-f]{42})')]     [string]    $pe_id,
    [Parameter(ParameterSetName='Volume')]
    [Parameter(ParameterSetName='vVol')]    [string]    $snap_id,
    [Parameter(ParameterSetName='vVol')]    [Object[]]  $pe_ids
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
            if($var -and ($PSBoundParameters.ContainsKey($key)))
            {   $RequestData.Add("$($var.name)", ($var.value))
            }
        }
        $Params = @{
            ObjectName = 'AccessControlRecord'
            APIPath = 'access_control_records'
            Properties = $RequestData
        }
        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
  }
}

function Get-NSAccessControlRecord {
<#
.SYNOPSIS
  List one or more access control records.
.DESCRIPTION
  List one or more access control records.
.PARAMETER id
  Identifier for the access control record. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER apply_to
  Type of object this access control record applies to. 
  Possible values: 'volume', 'snapshot', 'both', 'pe', 'vvol_volume', 'vvol_snapshot'.
.PARAMETER chap_user_id
  Identifier for the CHAP user. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER chap_user_name
  Name of the CHAP user. String of up to 64 alphanumeric characters or standalone wildcard 
  character '*' to represent any object name, - and . and : are allowed after first character. Examples: 'myobject-5', '*'.
.PARAMETER initiator_group_id 
  Identifier for the initiator group.
.PARAMETER initiator_group_name
  Name of the initiator group. String of up to 64 alphanumeric characters or standalone wildcard character '*' to represent any object 
  name, - and . and : are allowed after first character. Examples: 'myobject-5', '*'.
.PARAMETER lun
  If this access control record applies to a regular volume, this attribute is the volume's LUN (Logical Unit Number). If the access protocol is iSCSI, the LUN will be 0. However, if the access protocol is
  Fibre Channel, the LUN will be in the range from 0 to 2047. If this record applies to a Virtual Volume, this attribute is the volume's secondary LUN in the range from 0 to 399999, for both iSCSI and Fibre
  Channel. If the record applies to a OpenstackV2 volume, the LUN will be in the range from 0 to 2047, for both iSCSI and Fibre Channel. If this record applies to a protocol endpoint or only a snapshot, this
  attribute is not meaningful and is set to null.
.PARAMETER vol_id
  Identifier for the volume this access control record applies to. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER vol_name
  Name of the volume this access control record applies to. String of up to 215 alphanumeric, hyphenated, colon, 
  or period-separated characters; but cannot begin with hyphen, colon or period. 
  This type is used for object sets containing volumes, snapshots, snapshot collections and protocol endpoints.
.PARAMETER vol_agent_type
  External management agent type. Possible values: 'none', 'smis', 'vvol', 'openstack', 'openstackv2'.
.PARAMETER pe_id
  Identifier for the protocol endpoint this access control record applies to. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER pe_name
  Name of the protocol endpoint this access control record applies to. String of up to 215 alphanumeric, 
  hyphenated, colon, or period-separated characters; but cannot begin with hyphen, colon or period. 
  This type is used for object sets containing volumes, snapshots, snapshot collections and protocol endpoints.
.PARAMETER pe_lun
  LUN (Logical Unit Number) to associate with this protocol endpoint. Valid LUNs are in the 0-2047 range. Unsigned 64-bit integer. Example: 1234.
.PARAMETER snap_id
  Identifier for the snapshot this access control record applies to. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER snap_name
  Name of the snapshot this access control record applies to. String of up to 215 alphanumeric, hyphenated, colon, or period-separated characters; 
  but cannot begin with hyphen, colon or period. This type is used for object sets containing volumes, snapshots, snapshot collections and protocol endpoints.
.PARAMETER access_protocol
  Access protocol of the volume. Possible values: 'iscsi', 'fc'.
.EXAMPLE
  C:\> Get-NSAccessControlRecord

  vol_name             Initiator_group_name Apply_to  Lun  snap_name       id
  --------             -------------------- --------  ---  ---------       --
  starter-vol-29484... *                    volume    0                    0d28eada7f8dd99d3b000000000000000000000014
  starter-vol-29484... *                    volume    0                    0d28eada7f8dd99d3b000000000000000000000019
  starter-vol-29484... *                    volume    0                    0d28eada7f8dd99d3b00000000000000000000001a
  starter-vol-29484... *                    volume    0                    0d28eada7f8dd99d3b00000000000000000000001b
  starter-vol-29484... *                    volume    0                    0d28eada7f8dd99d3b000000000000000000000040

  This command will retrieves list of access control records.
.EXAMPLE
  C:\> Get-NSAccessControlRecord -id 0d28eada7f8dd99d3b000000000000000000000014

  vol_name                           Initiator_group_name Apply_to Lun snap_name id
  --------                           -------------------- -------- --- --------- --
  starter-vol-2948409147442961723-57 *                    volume   0             0d28eada7f8dd99d3b000000000000000000000014

  This command will retrieve a single Access control Record based on an id.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]  [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [Parameter(ParameterSetName='nonId')] [ValidateSet( 'volume', 'pe', 'vvol_volume', 'vvol_snapshot', 'snapshot', 'both')]
                                                                              [string]  $apply_to,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')] [string]  $chap_user_id,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $chap_user_name,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')] [string]  $initiator_group_id,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $initiator_group_name,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(0,2047)]             [string]  $lun,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')] [string]  $vol_id,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $vol_name,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]        [string]  $vol_agent_type,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')] [string]  $pe_id,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $pe_name,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(0,2047)]             [long]    $pe_lun,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')] [string]  $snap_id,
    [Parameter(ParameterSetName='nonId')]                                     [string]  $snap_name,
    [Parameter(ParameterSetName='nonId')] [ValidateSet( 'iscsi', 'fc')]       [string]  $access_protocol
  )
process{
    $API = 'access_control_records'
    $Param = @{   ObjectName = 'AccessControlRecord'
                  APIPath = 'access_control_records'
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

function Remove-NSAccessControlRecord {
<#
.SYNOPSIS
  Delete an access control record from the specified volume.
.DESCRIPTION
  Delete an access control record from the specified volume.
.PARAMETER id
  Identifier for the access control record. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE
  C:\> Remove-NSAccessControlRecord -id 0d28eada7f8dd99d3b000000000000000000000053

  This command will remove an existing access control record.
#> 
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]   [string]  $id
  )
process{  $Params = @{  ObjectName = 'AccessControlRecord'
                        APIPath = 'access_control_records'
                        Id = $id
                    }
    Remove-NimbleStorageAPIObject @Params
  }
}

