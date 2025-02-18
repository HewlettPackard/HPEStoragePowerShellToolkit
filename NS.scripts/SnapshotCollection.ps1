# SnapshotCollection.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2017 Hewlett Packard Enterprise Development LP.

function New-NSSnapshotCollection {
<#
.SYNOPSIS
    Create a snapshot collection. VSS application-synchronized snapshot collection must specify the 'allow_writes' parameter ans set it to 'true'.
.DESCRIPTION
    Create a snapshot collection. VSS application-synchronized snapshot collection must specify the 'allow_writes' parameter ans set it to 'true'.
.PARAMETER name
  Name of snapshot collection. String of up to 215 alphanumeric, hyphenated, colon, or period-separated characters; but cannot begin with hyphen, 
  colon or period. This type is used for object sets containing volumes, snapshots, snapshot collections and protocol endpoints.	
.PARAMETER description
  Text description of snapshot collection.
.PARAMETER volcoll_id
  Parent volume collection ID.
.PARAMETER is_external_trigger
  Is externally triggered.
.PARAMETER vol_snap_attr_list
  List of snapshot attributes for snapshots being created as part of snapshot collection creation.
.PARAMETER replicate
  True if this snapshot collection has been marked for replication. This attribute cannot be updated for synchronous replication.
.PARAMETER start_online
  Start with snapshot set online.
.PARAMETER allow_writes
  Allow applications to write to created snapshot(s). Mandatory and must be set to 'true' for VSS application synchronized snapshots.
.PARAMETER disable_appsync
  Do not perform application synchronization for this snapshot, create a crash-consistent snapshot instead.
.PARAMETER snap_verify
  Run verification tool on this snapshot. This option can only be used with a volume collection that has application synchronization.
.PARAMETER skip_db_consistency_check
  Skip consistency check for database files on this snapshot. This option only applies to volume collections with application 
  synchronization set to VSS, application ID set to MS Exchange 2010 or later with
  Database Availability Group (DAG), snap_verify option set to true, and disable_appsync option set to false.
.PARAMETER invoke_on_upstream_partner
  Invoke snapshot request on upstream partner. This operation is not supported for synchronous replication volume vollections.
.PARAMETER agent_type
  External management agent type for snapshots being created as part of snapshot collection.
.PARAMETER metadata
  Key-value pairs that augment a snapshot collection's attributes.
.EXAMPLE
  C:\> PS:> New-nsSnapshotcollection -name TestSnapcol-819 -volcoll_id 0728eada7f8dd99d3b000000000000000000000007

  name                                id                                            volcoll_name  sched_name    online        description
  ----                                --                                            ------------  ----------    ------        -----------
  TestSnapcol-819                     0528eada7f8dd99d3b0000000000000000000000b9    mycol1

  This command will create a new Snapshot collection using the minimal number of parameters.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]    [string]  $name,
                                      [string]  $description,
    [Parameter(Mandatory = $True)]                                      [ValidatePattern('([0-9a-f]{42})')]
                                      [string]  $volcoll_id,
                                      [bool]    $is_external_trigger,
                                      [Object[]]$vol_snap_attr_list,
                                      [bool]    $replicate,
                                      [string]  $replicate_to,
                                      [bool]    $start_online,
                                      [bool]    $allow_writes,
                                      [bool]    $disable_appsync,
                                      [bool]    $snap_verify,
                                      [bool]    $skip_db_consistency_check,
                                      [bool]    $invoke_on_upstream_partner,
    [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]
                                      [string]  $agent_type,
                                      [Object[]]$metadata
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
            ObjectName = 'SnapshotCollection'
            APIPath = 'snapshot_collections'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSSnapshotCollection {
<#
.SYNOPSIS
  Read information about specified snapshot collection.
.DESCRIPTION
  Read information about specified snapshot collection.
.PARAMETER id
  Identifier for snapshot collection.
.PARAMETER name
  Name of snapshot collection.
.PARAMETER description
  Text description of snapshot collection.
.PARAMETER volcoll_name
  Volume collection name.
.PARAMETER volcoll_id
  Parent volume collection ID.
.PARAMETER origin_name
  Origination group name/ID.
.PARAMETER is_replica
  Indicates if snapshot collection was created as a replica.
.PARAMETER is_complete
  Is complete.
.PARAMETER is_manual
  Is manual.
.PARAMETER is_external_trigger
  Is externally triggered.
.PARAMETER is_unmanaged
  Indicates whether a snapshot collection is unmanaged. This is based on the state of individual snapshots.
.PARAMETER repl_status
  Replication status.
.PARAMETER online_status
  Online status of snapcoll. This is based on the online status of the individual snapshots.
.PARAMETER replicate
  True if this snapshot collection has been marked for replication. This attribute cannot be updated for synchronous replication.
.PARAMETER start_online
  Start with snapshot set online.
.PARAMETER allow_writes
  Allow applications to write to created snapshot(s). Mandatory and must be set to 'true' for VSS application synchronized snapshots.
.PARAMETER disable_appsync
  Do not perform application synchronization for this snapshot, create a crash-consistent snapshot instead.
.PARAMETER snap_verify
  Run verification tool on this snapshot. This option can only be used with a volume collection that has application synchronization.
.PARAMETER skip_db_consistency_check
  Skip consistency check for database files on this snapshot. This option only applies to volume collections with application 
  synchronization set to VSS, application ID set to MS Exchange 2010 or later with Database Availability Group (DAG), snap_verify
  option set to true, and disable_appsync option set to false.
.PARAMETER sched_id
  ID of protection schedule of snapshot collection.
.PARAMETER sched_name
  Name of protection schedule of snapshot collection.
.PARAMETER invoke_on_upstream_partner
  Invoke snapshot request on upstream partner. This operation is not supported for synchronous replication volume vollections.
.PARAMETER agent_type
  External management agent type for snapshots being created as part of snapshot collection.
.EXAMPLE
    C:\> Get-NSSnapshotCollection

    name                                id                                            volcoll_name  sched_name    online        description
    ----                                --                                            ------------  ----------    ------        -----------
    Testsnap1                           0528eada7f8dd99d3b000000000000000000000005    testcol1
    mycol1-mydailybackup-2018-07-13:... 0528eada7f8dd99d3b000000000000000000000007    mycol1        mydailybackup               Created by protection policy mycol1 schedule my...
    mycol1-mydailybackup-2018-07-16:... 0528eada7f8dd99d3b000000000000000000000008    mycol1        mydailybackup               Created by protection policy mycol1 schedule my...
    mycol1-mydailybackup-2018-07-17:... 0528eada7f8dd99d3b000000000000000000000009    mycol1        mydailybackup               Created by protection policy mycol1 schedule my...

    This command will retrieve the Snapshot Collection from the array.

    -------------------- Example 2 --------------------

    C:\> Get-NSSnapshotCollection -name Testsnap1

    name                                id                                            volcoll_name  sched_name    online        description
    ----                                --                                            ------------  ----------    ------        -----------
    Testsnap1                           0528eada7f8dd99d3b000000000000000000000005    testcol1

    This command will retrieve a specific Snapshot Collection from the array by name.    
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]      [string] $id,
    [Parameter(ParameterSetName='nonId')]    [string]$name,
    [Parameter(ParameterSetName='nonId')]    [string]$description,
    [Parameter(ParameterSetName='nonId')]    [string]$volcoll_name,
    [Parameter(ParameterSetName='nonId')]
    [ValidatePattern('([0-9a-f]{42})')]      [string]$volcoll_id,
    [Parameter(ParameterSetName='nonId')]    [string]$origin_name,
    [Parameter(ParameterSetName='nonId')]    [bool]$is_replica,
    [Parameter(ParameterSetName='nonId')]    [string]$srep_owner_name,
    [Parameter(ParameterSetName='nonId')]
    [ValidatePattern('([0-9a-f]{42})')]      [string]$srep_owner_id,
    [Parameter(ParameterSetName='nonId')]    [string]$peer_snapcoll_id,
    [Parameter(ParameterSetName='nonId')]    [long]$num_snaps,
    [Parameter(ParameterSetName='nonId')]    [bool]$is_complete,
    [Parameter(ParameterSetName='nonId')]    [bool]$is_manual,
    [Parameter(ParameterSetName='nonId')]    [bool]$is_external_trigger,
    [Parameter(ParameterSetName='nonId')]    [bool]$is_unmanaged,
    [Parameter(ParameterSetName='nonId')]    [bool]$is_manually_managed,
    [Parameter(ParameterSetName='nonId')]                                      [ValidateSet( 'fail', 'in_progress', 'pending', 'complete')]
                                            [string]$repl_status,
    [Parameter(ParameterSetName='nonId')]                                       [ValidateSet( 'offline', 'online', 'partial')]
                                            [string]$online_status,
    [Parameter(ParameterSetName='nonId')]    [Object[]]$vol_snap_attr_list,
    [Parameter(ParameterSetName='nonId')]    [Object[]]$snapshots_list,
    [Parameter(ParameterSetName='nonId')]    [bool]$replicate,
    [Parameter(ParameterSetName='nonId')]    [string]$replicate_to,
    [Parameter(ParameterSetName='nonId')]    [bool]$start_online,
    [Parameter(ParameterSetName='nonId')]    [bool]$allow_writes,
    [Parameter(ParameterSetName='nonId')]    [bool]$disable_appsync,
    [Parameter(ParameterSetName='nonId')]    [bool]$snap_verify,
    [Parameter(ParameterSetName='nonId')]    [bool]$skip_db_consistency_check,
    [Parameter(ParameterSetName='nonId')]
    [ValidatePattern('([0-9a-f]{42})')]      [string]$sched_id,
    [Parameter(ParameterSetName='nonId')]    [string]$sched_name,
    [Parameter(ParameterSetName='nonId')]    [bool]$invoke_on_upstream_partner,
    [Parameter(ParameterSetName='nonId')]                                     [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]
                                            [string]$agent_type,
    [Parameter(ParameterSetName='nonId')]    [long]$expiry_after,
    [Parameter(ParameterSetName='nonId')]    [Object[]]$metadata
  )
process{
    $API = 'snapshot_collections'
    $Param = @{
      ObjectName = 'SnapshotCollection'
      APIPath = 'snapshot_collections'
    }
    if ($id)
    {
        # Get a single object for given Id.
        $Param.Id = $id
        $ResponseObject = Get-NimbleStorageAPIObject @Param
        return $ResponseObject
    }
    else
    {
        # Get list of objects matching the given filter.
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

function Set-NSSnapshotCollection {
<#
.SYNOPSIS
  Update a snapshot collection.
.DESCRIPTION
  Update a snapshot collection.
.PARAMETER id
  Identifier for snapshot collection.
.PARAMETER name
  Name of snapshot collection.
.PARAMETER description
  Text description of snapshot collection.
.PARAMETER replicate
  True if this snapshot collection has been marked for replication. This attribute cannot be updated for synchronous replication.
.PARAMETER metadata
  Key-value pairs that augment a snapshot collection's attributes.
.EXAMPLE
  C:\> Set-NSSnapshotcollection -id 0528eada7f8dd99d3b0000000000000000000000ba -description Test

  name                                id                                            volcoll_name  sched_name    online        description
  ----                                --                                            ------------  ----------    ------        -----------
  TestSnapColl-784                    0528eada7f8dd99d3b0000000000000000000000ba    mycol1                                    Test

  This command will set the value of offline for the Snapshotcollection specified by id.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]$id,
    [string] $name,
    [string] $description,
    [bool] $replicate,
    [string] $replicate_to,
    [long] $expiry_after,
    [Object[]] $metadata,
    [bool] $force
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
            ObjectName = 'SnapshotCollection'
            APIPath = 'snapshot_collections'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSSnapshotCollection {
<#
.SYNOPSIS
  Delete a snapshot collection
.DESCRIPTION
  Delete a snapshot collection
.PARAMETER id
  The ID of the Snapshot Collection to remove
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]$id
  )
process {
    $Params = @{
        ObjectName = 'SnapshotCollection'
        APIPath = 'snapshot_collections'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}
