# Snapshot.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSSnapshot {
<#
.SYNOPSIS
  Create a snapshot with the given attributes. 
.DESCRIPTION
  Create a snapshot with the given attributes. VSS application-synchronized snapshot must specify the 'writable' parameter and set it to 'true'.
.PARAMETER name 
  Name of snapshot.
.PARAMETER description
  Text description of snapshot.
.PARAMETER vol_id
  Name of the parent volume in which the snapshot will be created
.PARAMETER online
  Online state for a snapshot means it could be mounted for data restore.
.PARAMETER writable
  Allow snapshot to be writable. Mandatory and must be set to 'true' for VSS application synchronized snapshots.
.PARAMETER app_uuid
  Application identifier of snapshots.
.PARAMETER metadata
  Key-value pairs that augment a snapshot's attributes.
.PARAMETER agent_type
  External management agent type. Possible values: 'none', 'smis', 'vvol', 'openstack', 'openstackv2'.
.EXAMPLE
    C:\> PS:> New-nsSnapshot -name TestSnap-896 -vol_id 0628eada7f8dd99d3b000000000000000000000006

    name                                id                                            vol_name      schedule_name online        description
    ----                                --                                            --------      ------------- ------        -----------
    TestSnap-896                        0428eada7f8dd99d3b0000000000000007000000b6    TestVol4                    False

    This command will create a new Snapshot using the minimal number of parameters.
#>
[CmdletBinding()]
param(  [Parameter(Mandatory = $True)]  [string]  $name,
                                        [string]  $description,
        [Parameter(Mandatory = $True)]  [ValidatePattern('([0-9a-f]{42})')]
                                        [string]  $vol_id,
                                        [bool]    $online,
                                        [bool]    $writable,
                                        [string]  $app_uuid,
                                        [Object[]]$metadata,
    [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]
                                        [string]  $agent_type
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
            ObjectName = 'Snapshot'
            APIPath = 'snapshots'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSSnapshot {
<#
.SYNOPSIS
  Retrieve snapshot attributes.
.DESCRIPTION
  Retreive snapshot attributes.
.PARAMETER id
  Identifier for the snapshot.
.PARAMETER name
  Name of snapshot.
.PARAMETER description
  Text description of snapshot.
.PARAMETER size
  Size of volume at time of snapshot (in bytes).
.PARAMETER vol_name
        Name of the parent volume in which the snapshot belongs to.
.PARAMETER vol_id
        Parent volume ID.
.PARAMETER snap_collection_name
        Name of snapshot collection.
.PARAMETER snap_collection_id
        Identifier of snapshot collection.
.PARAMETER online
        Online state for a snapshot means it could be mounted for data restore.
.PARAMETER writable
        Allow snapshot to be writable. Mandatory and must be set to 'true' for VSS application synchronized snapshots.
.PARAMETER offline_reason
        Snapshot offline reason - possible entries: one of 'user', 'recovery', 'replica', 'over_volume_limit', 'over_snapshot_limit', 'over_volume_reserve', 'nvram_loss_recovery', 'pool_free_space_exhausted' .
.PARAMETER origin_name
        Origination group name.
.PARAMETER is_replica 
        Snapshot is a replica from upstream replication partner.
.PARAMETER is_unmanaged 
        Indicates whether the snapshot is unmanaged. The snapshot will not be deleted automatically unless the unmanaged cleanup feature is enabled.
.PARAMETER replication_status 
        Replication status.
.PARAMETER serial_number
        Identifier for the SCSI protocol.
.PARAMETER target_name 
        The iSCSI Qualified Name (IQN) or the Fibre Channel World Wide Node Name (WWNN) of the target snapshot.
.PARAMETER creation_time 
        Time when this snapshot was created.
.PARAMETER schedule_name 
        Name of protection schedule.
.PARAMETER schedule_id 
        Identifier of protection schedule.
.PARAMETER app_uuid 
        Application identifier of snapshots.
.PARAMETER new_data_valid
        Indicate the usage infomation is valid.
.PARAMETER agent_type
        External management agent type.
.PARAMETER vpd_t10
        The snapshot's T10 Vendor ID-based identifier.
.PARAMETER vpd_ieee0 
        The first 64 bits of the snapshots's EUI-64 identifier, encoded as a hexadecimal string.
.PARAMETER vpd_ieee1
        The last 64 bits of the snapshots's EUI-64 identifier, encoded as a hexadecimal string.
.EXAMPLE
    C:\> Set-NSSnapshot -id  0428eada7f8dd99d3b0000000000000007000000b7 -online $False

    name                                id                                            vol_name      schedule_name online        description
    ----                                --                                            --------      ------------- ------        -----------
    TestSnap-491                        0428eada7f8dd99d3b0000000000000007000000b7    TestVol4                    False

    This command will set the value of offline for the Snapshot specified by id.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [Parameter(ParameterSetName='nonId')] [string]  $name,
    [Parameter(ParameterSetName='nonId')] [string]  $description,
    [Parameter(ParameterSetName='nonId')] [long]    $size,
    [Parameter(ParameterSetName='nonId')] [string]  $vol_name,
    [Parameter(ParameterSetName='nonId')] 
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $vol_id,
    [Parameter(ParameterSetName='nonId')] [string]  $snap_collection_name,
    [Parameter(ParameterSetName='nonId')] 
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $snap_collection_id,
    [Parameter(ParameterSetName='nonId')] [bool]    $online,
    [Parameter(ParameterSetName='nonId')] [bool]    $writable,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'replica', 'recovery', 'nvram_loss_recovery', 'serial_number_collision', 'encryption_key_deleted', 'over_volume_usage_limit', 'over_folder_overdraft_limit', 'cache_unpin_in_progress', 'vvol_unbind', 'over_volume_limit', 'over_snapshot_limit', 'encryption_inactive', 'pool_free_space_exhausted', 'srep_unconfigured', 'user', 'over_volume_reserve', 'over_snapshot_reserve')]
                                          [string]  $offline_reason,

    [Parameter(ParameterSetName='nonId')] [string]  $origin_name,
    [Parameter(ParameterSetName='nonId')] [bool]    $is_replica,
    [Parameter(ParameterSetName='nonId')] [bool]    $is_unmanaged,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'fail', 'in_progress', 'pending', 'complete')]
                                          [string]  $replication_status,
    [Parameter(ParameterSetName='nonId')] [string]  $serial_number,
    [Parameter(ParameterSetName='nonId')] [string]  $target_name,
    [Parameter(ParameterSetName='nonId')] [long]    $creation_time,
    [Parameter(ParameterSetName='nonId')] [string]  $schedule_name,
    [Parameter(ParameterSetName='nonId')] 
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $schedule_id,
    [Parameter(ParameterSetName='nonId')] [string]  $app_uuid,
    [Parameter(ParameterSetName='nonId')] [bool]    $new_data_valid,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]
                                          [string]  $agent_type,
    [Parameter(ParameterSetName='nonId')] [string]  $vpd_t10,
    [Parameter(ParameterSetName='nonId')] [string]  $vpd_ieee0,
    [Parameter(ParameterSetName='nonId')] [string]  $vpd_ieee1
  )
process{
    $API = 'snapshots'
    $Param = @{
      ObjectName = 'Snapshot'
      APIPath = 'snapshots'
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

function Set-NSSnapshot {
<#
.SYNOPSIS
  Modify snapshot attributes.
.DESCRIPTION
  Modify snapshot attributes.
.PARAMETER name
  Name of snapshot. String of up to 215 alphanumeric, hyphenated, colon, or period-separated characters; but 
  cannot begin with hyphen, colon or period. This type is used for object sets containing volumes, 
  snapshots, snapshot collections and protocol endpoints.
.PARAMETER description
  Text description of snapshot. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER vol_id
  Parent volume ID. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER online
  Online state for a snapshot means it could be mounted for data restore. Possible values: 'true', 'false'.
.PARAMETER writable
  Allow snapshot to be writable. Mandatory and must be set to 'true' for VSS application synchronized snapshots. Possible values: 'true', 'false'.
.PARAMETER app_uuid
  Application identifier of snapshots. String of up to 255 alphanumeric characters, hyphen, colon, dot and
  underscore are allowed. Example: 'rfc4122.943f7dc1-5853-497c-b530-f689ccf1bf18'.
.PARAMETER metadata
  Key-value pairs that augment a snapshot's attributes. List of key-value pairs. Keys must be unique and non-empty. 
  When creating an object, values must be non-empty. When updating an object, an empty value causes the corresponding key to be removed.
.PARAMETER agent_type
  External management agent type. Possible values: 'none', 'smis', 'vvol', 'openstack', 'openstackv2'.
.EXAMPLE
  C:\> Set-NSSnapshot -id  0428eada7f8dd99d3b0000000000000007000000b7 -online $False

  name                                id                                            vol_name      schedule_name online        description
  ----                                --                                            --------      ------------- ------        -----------
  TestSnap-491                        0428eada7f8dd99d3b0000000000000007000000b7    TestVol4                    False

  This command will set the value of offline for the Snapshot specified by id.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]
    [string]  $id,
    [string]  $name,
    [string]  $description,
    [ValidatePattern('([0-9a-f]{42})')]
    [string]  $vol_id,
    [bool]    $online,
    [bool]    $writable,
    [string]  $app_uuid,
    [Object[]]$metadata,
    [ValidateSet('none', 'smis', 'vvol', 'openstack', 'openstackv2')]
    [string]  $agent_type
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        { if ($key.ToLower() -ne 'id')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                  {   $RequestData.Add("$($var.name)", ($var.value))
                  }
            }
        }
        $Params = @{
            ObjectName = 'Snapshot'
            APIPath = 'snapshots'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSSnapshot {
<#
.SYNOPSIS
  Remove a Snapshot from the system.
.DESCRIPTION
  Delete a snapshot with the given name or identifier.Snapshots cannot be deleted if they are in use by replication 
  on the affected volume. Replication must be paused or unconfigured in order for the deletion to proceed.
.PARAMETER id
  The ID of the snapshot to be removed.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process { $Params = @{  ObjectName = 'Snapshot'
                        APIPath = 'snapshots'
                        Id = $id
                    }
          Remove-NimbleStorageAPIObject @Params
  }
}

function New-NSSnapshotBulk {
<#
.SYNOPSIS
  Create a set of snapshots together
.DESCRIPTION
  Create a set of snapshots together. The snapvollit is an object that will contain details on each snapshot to create.
.PARAMETER snap_vol_list
  You will need to provide an object that contains all of the values of each individual snapshot. An example of this object might
  look like '@( @{ vol_id = "06004d300000000000007"; snap_name = 'vol1'; online = $false}, @{ vol_id = "06004d300000000000008"; 
  snap_name = 'vol2'; snap_description = 'vol2 snap'} )' . The valid subitems in each snapshot request are 'snap_name', 'snap_description', 
  'cookie', 'online', and 'writable'
.PARAMETER replicate
  Allow snapshot to be replicated. Possible values: 'true', 'false'.
.PARAMETER vss_snap
  VSS app-synchronized snapshot; we don't support creation of non app-synchronized sanpshots through this 
  interface; must be set to true. Possible values: 'true', 'false'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [Object[]]$snap_vol_list,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [bool]$replicate,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]    
    [bool]$vss_snap
  )
process{
    $Params = @{  APIPath     = 'snapshots'
                  Action      = 'bulk_create'
                  ReturnType  = 'NsSnapVolListReturn'
              }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
          {   $Params.Arguments.Add("$($var.name)", ($var.value))
          }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

