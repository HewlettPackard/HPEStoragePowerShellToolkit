# Volume.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSVolume {
<#
.SYNOPSIS
  Create operation is used to create or clone a volume. Creating volumes requires name and size attributes. Cloning 
  volumes requires clone, name and base_snap_id attributes where clone is set to true. Newly created volume will not 
  have any access control records, they can be added to the volume by create operation on access_control_records 
  object set. Cloned volume inherits access control records from the parent volume.
.DESCRIPTION
  Create operation is used to create or clone a volume. Creating volumes requires name and size attributes. Cloning 
  volumes requires clone, name and base_snap_id attributes where clone is set to true. Newly created volume will not 
  have any access control records, they can be added to the volume by create operation on access_control_records 
  object set. Cloned volume inherits access control records from the parent volume.
.PARAMETER name
  Name of the volume.
.PARAMETER size
  Volume size in mebibytes. Size is required for creating a volume but not for cloning an existing volume.
.PARAMETER description
  Text description of volume.
.PARAMETER perfpolicy_id
  Identifier of the performance policy. After creating a volume, performance policy for the volume can only be
  changed to another performance policy with same block size.
.PARAMETER reserve
  Amount of space to reserve for this volume as a percentage of volume size.
.PARAMETER warn_level [<Nullable`1[Int64]>]
  This attribute is deprecated. Alert threshold for the volume's mapped usage, expressed as a percentage of the 
  volume's size. When the volume's mapped usage exceeds warn_level, the array issues an alert. If this option is 
  not specified, array default volume warn level setting is used to decide the warning level for this volume.
.PARAMETER limit
  Limit on the volume's mapped usage, expressed as a percentage of the volume's size. When the volume's mapped 
  usage exceeds limit, the volume will be offlined or made non-writable. If this option is not specified, array 
  default volume limit setting is used to decide the limit for this volume.
.PARAMETER snap_reserve
  Amount of space to reserve for snapshots of this volume as a percentage of volume size.
.PARAMETER snap_warn_level
  Threshold for available space as a percentage of volume size below which an alert is raised.
.PARAMETER snap_limit
  This attribute is deprecated. The array does not limit a volume's snapshot space usage. 
  The attribute is ignored on input and returns max int64 on output.
.PARAMETER snap_limit_percent
  This attribute is deprecated. The array does not limit a volume's snapshot space usage. 
  The attribute is ignored on input and returns -1 on output.
.PARAMETER online
  Online state of volume, available for host initiators to establish connections.
.PARAMETER owned_by_group_id 
  ID of group that currently owns the volume.
.PARAMETER multi_initiator
  For iSCSI Volume Target, this flag indicates whether the volume and its snapshots can be accessed from multiple 
  initiators at the same time. The default is false. For iSCSI Group Target or FC access protocol, the attribute 
  cannot be modified and always reads as false.
.PARAMETER pool_id
  Identifier associated with the pool in the storage pool table.
.PARAMETER read_only
  Volume is read-only.
.PARAMETER block_size
  Size in bytes of blocks in the volume.
.PARAMETER clone
  Whether this volume is a clone. Use this attribute in combination with 
  name and base_snap_id to create a clone by setting clone = true.
.PARAMETER base_snap_id
  Base snapshot ID. This attribute is required together with name and clone when cloning a volume with the create operation.
.PARAMETER agent_type
  External management agent type.
.PARAMETER dest_pool_id
  ID of the destination pool where the volume is moving to.
.PARAMETER cache_pinned
  If set to true, all the contents of this volume are kept in flash cache. This provides for consistent performance 
  guarantees for all types of workloads. The amount of flash needed to pin the volume is equal to the limit for the volume.
.PARAMETER encryption_cipher
  The encryption cipher of the volume.
.PARAMETER app_uuid
  Application identifier of volume.
.PARAMETER folder_id
  ID of the folder holding this volume.
.PARAMETER metadata
  Key-value pairs that augment an volume's attributes.
.PARAMETER dedupe_enabled
  Indicate whether dedupe is enabled.
.PARAMETER limit_iops
  IOPS limit for this volume. If limit_iops is not specified when a volume is created, or if limit_iops is set to -1, then the 
  volume has no IOPS limit. If limit_iops is not specified while creating a clone, IOPS limit of parent volume will be used as 
  limit. IOPS limit should be in range [256, 4294967294] or -1 for unlimited. If both limit_iops and limit_mbps are specified, 
  limit_mbps must not be hit before limit_iops. In other words, IOPS and MBPS limits should 
  honor limit_iops <= ((limit_mbps MB/s * 2^20 B/MB) / block_size B).
.PARAMETER limit_mbps
  Throughput limit for this volume in MB/s. If limit_mbps is not specified when a volume is created, or if limit_mbps is set 
  to -1, then the volume has no MBPS limit. MBPS limit should be in range [1,4294967294] or -1 for unlimited. If both 
  limit_iops and limit_mbps are specified, limit_mbps must not be hit before limit_iops. In other words, IOPS and MBPS limits 
  should honor limit_iops <= ((limit_mbps MB/s * 2^20 B/MB) / block_size B).
.EXAMPLE
  C:\> PS:> New-NSVolume -name test4

  Name  id                                         Size  vol_state perfpolicy_name thinly_provisioned block_size description
  ----  --                                         ----  --------- --------------- ------------------ ---------- -----------
  test4 0628eada7f8dd99d3b0000000000000000000000d2 10240 online    default         True               4096

  This command will create a new volume using the minimal number of parameters.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]        [string]  $name,
                                          [long]    $size,
                                          [string]  $description,
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $perfpolicy_id,
                                          [long]    $reserve,
                                          [long]    $warn_level,
                                          [long]    $limit,
                                          [long]    $snap_reserve,
                                          [long]    $snap_warn_level,
                                          [long]    $snap_limit,
                                          [long]    $snap_limit_percent,
                                          [bool]    $online,
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $owned_by_group_id,
                                          [bool]    $multi_initiator,
    [ValidateSet( 'volume', 'group')]     [string]  $iscsi_target_scope,
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $pool_id,
                                          [bool]    $read_only,
                                          [long]    $block_size,
                                          [bool]    $clone,
                                          [string]  $base_snap_id,
    [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]
                                          [string]  $agent_type,
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $dest_pool_id,
                                          [bool]    $cache_pinned,
                                          [bool]    $thinly_provisioned,
                                          [bool]    $inherit_acl,
    [ValidateSet( 'aes_256_xts', 'none')] [string]  $encryption_cipher,
                                          [string]  $app_uuid,
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $folder_id,
                                          [Object[]]$metadata,
                                          [bool]    $dedupe_enabled,
                                          [long]    $limit_iops,
                                          [long]    $limit_mbps,
                                          [bool]    $needs_content_repl
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
            ObjectName = 'Volume'
            APIPath = 'volumes'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSVolume {
<#
.SYNOPSIS
  Retrieve information on a set of volumes or a single volume.
.DESCRIPTION
  Retrieve information on a set of volumes or a single volume.
.PARAMETER id
  Identifier for the volume.
.PARAMETER name
  Name of the volume.
.PARAMETER full_name
  Fully qualified name of volume.
.PARAMETER search_name
  Name of volume used for object search.
.PARAMETER size
  Volume size in mebibytes. Size is required for creating a volume but not for cloning an existing volume.
.PARAMETER description
  Text description of volume.
.PARAMETER perfpolicy_name
  Name of performance policy.
.PARAMETER perfpolicy_id
  Identifier of the performance policy. After creating a volume, performance policy for the volume 
  can only be changed to another performance policy with same block size.
.PARAMETER reserve
  Amount of space to reserve for this volume as a percentage of volume size.
.PARAMETER limit
  Limit on the volume's mapped usage, expressed as a percentage of the volume's size. When the volume's 
  mapped usage exceeds limit, the volume will be offlined or made non-writable. If this option is not
  specified, array default volume limit setting is used to decide the limit for this volume.
.PARAMETER snap_reserve
  Amount of space to reserve for snapshots of this volume as a percentage of volume size.
.PARAMETER snap_warn_level
  Threshold for available space as a percentage of volume size below which an alert is raised.
.PARAMETER online
  Online state of volume, available for host initiators to establish connections.
.PARAMETER owned_by_group
  Name of group that currently owns the volume.
.PARAMETER owned_by_group_id
  ID of group that currently owns the volume.
.PARAMETER multi_initiator
  For iSCSI Volume Target, this flag indicates whether the volume and its snapshots can be accessed from 
  multiple initiators at the same time. The default is false. For iSCSI Group Target or FC access
  protocol, the attribute cannot be modified and always reads as false.
.PARAMETER iscsi_target_scope
  This indicates whether volume is exported under iSCSI Group Target or iSCSI Volume Target. This attribute
  is only meaningful to iSCSI system. On FC system, all volumes are exported under the FC Group Target.
  In create operation, the volume's target type will be set by this attribute. If not specified, it will be
  set as the group-setting. In clone operation, the clone's target type will inherit from the parent' setting.
.PARAMETER pool_name
  Name of the pool where the volume resides. Volume data will be distributed across arrays over which specified 
  pool is defined. If pool option is not specified, volume is assigned to the default pool.
.PARAMETER pool_id
  Identifier associated with the pool in the storage pool table.
.PARAMETER read_only
  Volume is read-only.
.PARAMETER serial_number
  Identifier associated with the volume for the SCSI protocol.
.PARAMETER secondary_serial_number
  Secondary identifier associated with the volume for the SCSI protocol.
.PARAMETER target_name
  The iSCSI Qualified Name (IQN) or the Fibre Channel World Wide Node Name (WWNN) of the target volume.
.PARAMETER block_size
  Size in bytes of blocks in the volume.
.PARAMETER offline_reason 
  Volume offline reason.
.PARAMETER clone
  Whether this volume is a clone. Use this attribute in combination with name and base_snap_id 
  to create a clone by setting clone = true.
.PARAMETER parent_vol_name
  Name of parent volume.
.PARAMETER parent_vol_id
  Parent volume ID.
.PARAMETER base_snap_name
  Name of base snapshot.
.PARAMETER base_snap_id
  Base snapshot ID. This attribute is required together with 
  name and clone when cloning a volume with the create operation.
.PARAMETER replication_role
  Replication role that this volume performs.
.PARAMETER volcoll_name
  Name of volume collection of which this volume is a member.
.PARAMETER volcoll_id
  ID of volume collection of which this volume is a member. Use this attribute in update operation to associate 
  or dissociate volumes with or from volume collections. When associating, set this attribute to
  the ID of the volume collection. When dissociating, set this attribute to empty string.
.PARAMETER agent_type
  External management agent type.
.PARAMETER force
  Forcibly offline, reduce size or change read-only status a volume.
.PARAMETER protection_type
  Specifies if volume is protected with schedules. If protected, indicate whether replication is setup.
.PARAMETER last_snap
  Last snapshot for this volume.
.PARAMETER last_replicated_snap
  Last replicated snapshot for this volume.
.PARAMETER dest_pool_name
  Name of the destination pool where the volume is moving to.
.PARAMETER dest_pool_id
  ID of the destination pool where the volume is moving to.
.PARAMETER move_aborting
  This indicates whether the move of the volume is aborting or not.
.PARAMETER usage_valid
  This indicates whether usage information of volume and snapshots are valid or not.
.PARAMETER space_usage_level
  Indicates space usage level based on warning level.
.PARAMETER cache_pinned 
  If set to true, all the contents of this volume are kept in flash cache. This provides for consistent
  performance guarantees for all types of workloads. The amount of flash needed to pin the volume is equal
  to the limit for the volume.
.PARAMETER upstream_cache_pinned 
  This indicates whether the upstream volume is cache pinned or not.
.PARAMETER cache_policy 
  Cache policy applied to the volume.
.PARAMETER thinly_provisioned 
  Set volume's provisioning level to thin.  Also advertises volume as thinly provisioned to initiators 
  supporting thin provisioning. For such volumes, soft limit notification is set to initiators when the
  volume space usage crosses its volume_warn_level. Default is yes. The volume's space is provisioned 
  immediately, but for advertising status, this change takes effect only for new connections to 
  the volume. Initiators must disconnect and reconnect for the new setting to be take 
  effect at the initiator level consistently.
.PARAMETER vol_state
  Status of the volume.
.PARAMETER online_snaps
  The list of online snapshots of this volume.
.PARAMETER access_control_records
  List of access control records that apply to this volume.
.PARAMETER inherit_acl 
  In a volume clone operation, if both the parent and the clone have no external management agent (their 
  agent_type property is "none"), then inherit_acl controls whether the clone will inherit a copy of the
  parent's access control list. If either the parent or the clone have an external management 
  agent, then the clone will not inherit the parent's access control list.
.PARAMETER encryption_cipher
  The encryption cipher of the volume.
.PARAMETER app_uuid
  Application identifier of volume.
.PARAMETER folder_id
  ID of the folder holding this volume.
.PARAMETER folder_name
  Name of the folder holding this volume. It can be empty.
.PARAMETER metadata
  Key-value pairs that augment an volume's attributes.
.PARAMETER iscsi_sessions
  List of iSCSI sessions connected to this volume.
.PARAMETER fc_sessions
  List of Fibre Channel sessions connected to this volume.
.PARAMETER caching_enabled
  Indicate caching the volume is enabled.
.PARAMETER previously_deduped
  Indicate whether dedupe has ever been enabled on this volume.
.PARAMETER dedupe_enabled
  Indicate whether dedupe is enabled.
.PARAMETER vpd_t10 
  The volume's T10 Vendor ID-based identifier.
.PARAMETER vpd_ieee0
  The first 64 bits of the volume's EUI-64 identifier, encoded as a hexadecimal string.
.PARAMETER vpd_ieee1
  The last 64 bits of the volume's EUI-64 identifier, encoded as a hexadecimal string.
.PARAMETER app_category
  Application category that the volume belongs to.
.PARAMETER limit_iops
  IOPS limit for this volume. If limit_iops is not specified when a volume is created, or 
  if limit_iops is set to -1, then the volume has no IOPS limit. If limit_iops is not specified 
  while creating a clone, IOPS limit of parent volume will be used as limit. IOPS limit should
  be in range [256, 4294967294] or -1 for unlimited. If both limit_iops and limit_mbps are specified, 
  limit_mbps must not be hit before limit_iops. In other words, IOPS and MBPS limits should 
  honor limit_iops <= ((limit_mbps MB/s * 2^20 B/MB) / block_size B).
.PARAMETER limit_mbps
  Throughput limit for this volume in MB/s. If limit_mbps is not specified when a volume is created, 
  or if limit_mbps is set to -1, then the volume has no MBPS limit. MBPS limit should be in range [1,
  4294967294] or -1 for unlimited. If both limit_iops and limit_mbps are specified, limit_mbps must 
  not be hit before limit_iops. In other words, IOPS and MBPS limits should 
  honor limit_iops <= ((limit_mbps MB/s * 2^20 B/MB) / block_size B).
.PARAMETER needs_content_repl
  Indicates whether the volume needs content based replication.
.EXAMPLE
  C:\> Get-NSVolume

  Name           id                                         Size vol_state perfpolicy_name thinly_provisioned block_size description
  ----           --                                         ---- --------- --------------- ------------------ ---------- -----------
  CHAPI-Testvol1 0628eada7f8dd99d3b000000000000000000000001 5120 online    default         True               4096
  CHAPI-Testvol2 0628eada7f8dd99d3b000000000000000000000002 1024 online    default         True               4096
  testvol1       0628eada7f8dd99d3b000000000000000000000003 1024 online    default         True               4096
  testvol2       0628eada7f8dd99d3b000000000000000000000004 1024 online    default         True               4096
  testvol3       0628eada7f8dd99d3b000000000000000000000005 1024 online    default         True               4096

  This command will retrieve the volumes.
.EXAMPLE
  C:\> Get-NSVolume -name CHAPI-Testvol2

  Name           id                                         Size vol_state perfpolicy_name thinly_provisioned block_size description
  ----           --                                         ---- --------- --------------- ------------------ ---------- -----------
  CHAPI-Testvol2 0628eada7f8dd99d3b000000000000000000000002 1024 online    default         True               4096

  This command will retrieve the volume specified by name.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]                                      [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $id,
    [Parameter(ParameterSetName='nonId')]   [string]  $name,
    [Parameter(ParameterSetName='nonId')]   [string]  $full_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $search_name,
    [Parameter(ParameterSetName='nonId')]   [long]    $size,
    [Parameter(ParameterSetName='nonId')]   [string]  $description,
    [Parameter(ParameterSetName='nonId')]   [string]  $perfpolicy_name,
    [Parameter(ParameterSetName='nonId')]                                   [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $perfpolicy_id,
    [Parameter(ParameterSetName='nonId')]   [long]    $reserve,
    [Parameter(ParameterSetName='nonId')]   [long]    $warn_level,
    [Parameter(ParameterSetName='nonId')]   [long]    $limit,
    [Parameter(ParameterSetName='nonId')]   [long]    $snap_reserve,
    [Parameter(ParameterSetName='nonId')]   [long]    $snap_warn_level,
    [Parameter(ParameterSetName='nonId')]   [long]    $snap_limit,
    [Parameter(ParameterSetName='nonId')]   [long]    $snap_limit_percent,
    [Parameter(ParameterSetName='nonId')]   [bool]    $online,
    [Parameter(ParameterSetName='nonId')]   [string]  $owned_by_group,
    [Parameter(ParameterSetName='nonId')]                                     [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $owned_by_group_id,
    [Parameter(ParameterSetName='nonId')]   [bool]    $multi_initiator,
    [Parameter(ParameterSetName='nonId')]                                     [ValidateSet( 'volume', 'group')]       
                                            [string]  $iscsi_target_scope,
    [Parameter(ParameterSetName='nonId')]   [string]  $pool_name,
    [Parameter(ParameterSetName='nonId')]                                     [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $pool_id,
    [Parameter(ParameterSetName='nonId')]   [bool]    $read_only,
    [Parameter(ParameterSetName='nonId')]   [string]  $serial_number,
    [Parameter(ParameterSetName='nonId')]   [string]  $secondary_serial_number,
    [Parameter(ParameterSetName='nonId')]   [string]  $target_name,
    [Parameter(ParameterSetName='nonId')]   [long]    $block_size,
    [Parameter(ParameterSetName='nonId')]                                     [ValidateSet('replica','recovery','nvram_loss_recovery','serial_number_collision','encryption_key_deleted','over_volume_usage_limit',
                                                                              'over_folder_overdraft_limit','cache_unpin_in_progress', 'vvol_unbind', 'over_volume_limit','over_snapshot_limit', 'encryption_inactive', 
                                                                              'pool_free_space_exhausted', 'srep_unconfigured', 'user', 'over_volume_reserve', 'over_snapshot_reserve')]
                                            [string]  $offline_reason,
    [Parameter(ParameterSetName='nonId')]   [bool]    $clone,
    [Parameter(ParameterSetName='nonId')]   [string]  $parent_vol_name,
    [Parameter(ParameterSetName='nonId')]                                       [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $parent_vol_id,
    [Parameter(ParameterSetName='nonId')]   [string]  $base_snap_name,
    [Parameter(ParameterSetName='nonId')]                                       [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $base_snap_id,
    [Parameter(ParameterSetName='nonId')]                                       [ValidateSet('periodic_snapshot_downstream','synchronous_upstream','synchronous_downstream','no_replication','periodic_snapshot_upstream')]
                                            [string]  $replication_role,
    [Parameter(ParameterSetName='nonId')]   [string]  $volcoll_name,
    [Parameter(ParameterSetName='nonId')]                                       [ValidatePattern('([0-9a-f]{42})')]     
                                            [string]  $volcoll_id,
    [Parameter(ParameterSetName='nonId')]                                       [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]
                                            [string]  $agent_type,
    [Parameter(ParameterSetName='nonId')]   [bool]    $force,
    [Parameter(ParameterSetName='nonId')]                                       [ValidateSet( 'unprotected', 'remote', 'local')]
                                            [string]  $protection_type,
    [Parameter(ParameterSetName='nonId')]   [string]  $dest_pool_name,
    [Parameter(ParameterSetName='nonId')]                                       [ValidatePattern('([0-9a-f]{42})')]     
                                            [string]  $dest_pool_id,
    [Parameter(ParameterSetName='nonId')]   [bool]    $move_aborting,
    [Parameter(ParameterSetName='nonId')]   [bool]    $usage_valid,
    [Parameter(ParameterSetName='nonId')]                                        [ValidateSet( 'normal', 'critical', 'warning')]
                                            [string]  $space_usage_level,
    [Parameter(ParameterSetName='nonId')]   [bool]    $cache_pinned,
    [Parameter(ParameterSetName='nonId')]   [bool]    $upstream_cache_pinned,
    [Parameter(ParameterSetName='nonId')]                                        [ValidateSet( 'normal', 'no_write', 'aggressive_read_no_write', 'disabled', 'aggressive')]
                                            [string]  $cache_policy,
    [Parameter(ParameterSetName='nonId')]   [bool]    $thinly_provisioned,
    [Parameter(ParameterSetName='nonId')]                                        [ValidateSet( 'offline', 'login_only', 'non_writable', 'read_only', 'online')]
                                            [string]  $vol_state,
    [Parameter(ParameterSetName='nonId')]   [Object[]]$online_snaps,
    [Parameter(ParameterSetName='nonId')]   [long]    $num_connections,
    [Parameter(ParameterSetName='nonId')]   [long]    $num_iscsi_connections,
    [Parameter(ParameterSetName='nonId')]   [long]    $num_fc_connections,
    [Parameter(ParameterSetName='nonId')]   [Object[]]$access_control_records,
    [Parameter(ParameterSetName='nonId')]   [bool]    $inherit_acl,
    [Parameter(ParameterSetName='nonId')]                                         [ValidateSet( 'aes_256_xts', 'none')]
                                            [string]  $encryption_cipher,
    [Parameter(ParameterSetName='nonId')]   [string]  $app_uuid,
    [Parameter(ParameterSetName='nonId')]                                         [ValidatePattern('([0-9a-f]{42})')]     
                                            [string]  $folder_id,
    [Parameter(ParameterSetName='nonId')]   [string]  $folder_name,
    [Parameter(ParameterSetName='nonId')]   [Object[]]$metadata,
    [Parameter(ParameterSetName='nonId')]   [Object[]]$iscsi_sessions,
    [Parameter(ParameterSetName='nonId')]   [Object[]]$fc_sessions,
    [Parameter(ParameterSetName='nonId')]   [bool]    $caching_enabled,
    [Parameter(ParameterSetName='nonId')]   [bool]    $previously_deduped,
    [Parameter(ParameterSetName='nonId')]   [bool]    $dedupe_enabled,
    [Parameter(ParameterSetName='nonId')]   [string]  $vpd_t10,
    [Parameter(ParameterSetName='nonId')]   [string]  $vpd_ieee0,
    [Parameter(ParameterSetName='nonId')]   [string]  $vpd_ieee1,
    [Parameter(ParameterSetName='nonId')]   [string]  $app_category,
    [Parameter(ParameterSetName='nonId')]   [long]    $limit_iops,
    [Parameter(ParameterSetName='nonId')]   [long]    $limit_mbps,
    [Parameter(ParameterSetName='nonId')]   [bool]    $needs_content_repl,
    [Parameter(ParameterSetName='nonId')]   [bool]    $content_repl_errors_found,
    [Parameter(ParameterSetName='nonId')]   [string]  $pre_filter,
    [Parameter(ParameterSetName='nonId')]   [Object]  $avg_stats_last_5mins
  )
process
  {
    $API = 'volumes'
    $Param = @{
      ObjectName = 'Volume'
      APIPath = 'volumes'
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

function Set-NSVolume {
<#
.SYNOPSIS
  Modify volume attributes. 
.DESCRIPTION
  Modify volume attributes. Use 'force=true' with readonly=true to force the volume with active connections to become read-only.
.PARAMETER id 
  Identifier for the volume.
.PARAMETER name
  Name of the volume.
.PARAMETER size
  Volume size in mebibytes. Size is required for creating a volume but not for cloning an existing volume.
.PARAMETER description
  Text description of volume.
.PARAMETER perfpolicy_id
  Identifier of the performance policy. After creating a volume, performance policy for the 
  volume can only be changed to another performance policy with same block size.
.PARAMETER reserve
  Amount of space to reserve for this volume as a percentage of volume size.
.PARAMETER warn_level
  This attribute is deprecated. Alert threshold for the volume's mapped usage, expressed as a 
  percentage of the volume's size. When the volume's mapped usage exceeds warn_level, the array issues an alert. If
  this option is not specified, array default volume warn level setting is used to decide the warning level for this volume.
.PARAMETER limit
  Limit on the volume's mapped usage, expressed as a percentage of the volume's size. When the volume's mapped 
  usage exceeds limit, the volume will be offlined or made non-writable. If this option is not
  specified, array default volume limit setting is used to decide the limit for this volume.
.PARAMETER snap_reserve
  Amount of space to reserve for snapshots of this volume as a percentage of volume size.
.PARAMETER snap_warn_level
  Threshold for available space as a percentage of volume size below which an alert is raised.
.PARAMETER snap_limit
  This attribute is deprecated. The array does not limit a volume's snapshot space usage. 
  The attribute is ignored on input and returns max int64 on output.
.PARAMETER snap_limit_percent
  This attribute is deprecated. The array does not limit a volume's snapshot space usage. 
  The attribute is ignored on input and returns -1 on output.
.PARAMETER online 
  Online state of volume, available for host initiators to establish connections.
.PARAMETER owned_by_group_id
  ID of group that currently owns the volume.
.PARAMETER multi_initiator
  For iSCSI Volume Target, this flag indicates whether the volume and its snapshots can be accessed 
  from multiple initiators at the same time. The default is false. For iSCSI Group Target or FC access
  protocol, the attribute cannot be modified and always reads as false.
.PARAMETER read_only
  Volume is read-only.
.PARAMETER block_size
  Size in bytes of blocks in the volume.
.PARAMETER volcoll_id
  ID of volume collection of which this volume is a member. Use this attribute in update operation 
  to associate or dissociate volumes with or from volume collections. When associating, set this 
  attribute to the ID of the volume collection. When dissociating, set this attribute to empty string.
.PARAMETER agent_type
  External management agent type.
.PARAMETER force 
  Forcibly offline, reduce size or change read-only status a volume.
.PARAMETER cache_pinned
  If set to true, all the contents of this volume are kept in flash cache. This provides for consistent 
  performance guarantees for all types of workloads. The amount of flash needed to pin the volume is equal
  to the limit for the volume.
.PARAMETER -app_uuid
  Application identifier of volume.
.PARAMETER folder_id
  ID of the folder holding this volume.
.PARAMETER metadata
  Key-value pairs that augment an volume's attributes.
.PARAMETER caching_enabled
  Indicate caching the volume is enabled.
.PARAMETER dedupe_enabled
  Indicate whether dedupe is enabled.
.PARAMETER limit_iops 
  IOPS limit for this volume. If limit_iops is not specified when a volume is created, or if limit_iops is set 
  to -1, then the volume has no IOPS limit. If limit_iops is not specified while creating a clone, IOPS limit 
  of parent volume will be used as limit. IOPS limit should be in range [256, 4294967294] or -1 for unlimited.
  If both limit_iops and limit_mbps are specified, limit_mbps must not be hit before limit_iops. In other
  words, IOPS and MBPS limits should honor limit_iops <= ((limit_mbps MB/s * 2^20 B/MB) / block_size B).
.PARAMETER limit_mbps
  Throughput limit for this volume in MB/s. If limit_mbps is not specified when a volume is created, or if 
  limit_mbps is set to -1, then the volume has no MBPS limit. MBPS limit should be in range [1,4294967294] 
  or -1 for unlimited. If both limit_iops and limit_mbps are specified, limit_mbps must not be hit before 
  limit_iops. In other words, IOPS and MBPS limits should honor limit_iops <= ((limit_mbps MB/s * 2^20 B/MB) / block_size B).
.EXAMPLE
  C:\> Set-NSVolume -id  0628eada7f8dd99d3b0000000000000000000000d2 -online $False

  Name  id                                         Size  vol_state perfpolicy_name thinly_provisioned block_size description
  ----  --                                         ----  --------- --------------- ------------------ ---------- -----------
  test4 0628eada7f8dd99d3b0000000000000000000000d2 10240 offline   default         True               4096

  This command will set the value of offline for the volume specified by id.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
                                          [string]  $name,
                                          [long]    $size,
                                          [string]  $description,
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $perfpolicy_id,
    [ValidateRange(0,100)]                [int]     $reserve,
    [ValidateRange(0,100)]                [int]     $warn_level,
    [ValidateRange(0,100)]                [int]     $limit,
                                          [long]    $snap_reserve,
    [ValidateRange(0,100)]                [int]     $snap_warn_level,
    [ValidateRange(0,100)]                [int]     $snap_limit_percent,
                                          [bool]    $online,
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $owned_by_group_id,
                                          [bool]    $multi_initiator,
    [ValidateSet( 'volume', 'group')]     [string]  $iscsi_target_scope,
                                          [bool]    $read_only,
                                
    [ValidatePattern(4096,8192,16384,32768)][int]   $block_size,
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $volcoll_id,
    [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]
                                          [string]  $agent_type,
                                          [bool]    $force,
                                          [bool]    $cache_pinned,
                                          [string]  $app_uuid,
  [ValidatePattern('([0-9a-f]{42})')]     [string]  $folder_id,
                                          [Object[]] $metadata,
                                          [bool]    $caching_enabled,
                                          [bool]    $dedupe_enabled,
  [ValidateRange(-1,4294967294)]          [long]    $limit_iops,
  [ValidateRange(-1,4294967294)]          [long]    $limit_mbps
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
            ObjectName = 'Volume'
            APIPath = 'volumes'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSVolume {
<#
.SYNOPSIS
  Remove the Volume identified by the given ID.
.DESCRIPTION  
  Remove the Volume identified by the given ID.
.PARAMETER id
  Identifier for the volume. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]$id
  )

  process {
    $Params = @{
        ObjectName = 'Volume'
        APIPath = 'volumes'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}

function Restore-NSVolume {
<#
.SYNOPSIS
  Retstore a Volume to a previously created snapshot.
.DESCRIPTION
  Retstore a Volume to a previously created snapshot.
.PARAMETER id
  Identifier for the volume. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER base_snap_id
  Identifier for the base snapshot ID to restore from. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]$base_snap_id
  )
process{
    $Params = @{
        APIPath = 'volumes'
        Action = 'restore'
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
    return $ResponseObject
  }
}

function Move-NSVolume {
<#
.SYNOPSIS
    Move a volume and its related volumes to another pool. To change a single volume's folder assignment 
    (while remaining in the same pool), use a volume update operation to change the folder_id attribute.
.DESCRIPTION
    Move a volume and its related volumes to another pool. To change a single volume's folder assignment 
    (while remaining in the same pool), use a volume update operation to change the folder_id attribute.
.PARAMETER id
  ID of the volume to move.
.PARAMETER dest_pool_id
  ID of the destination pool or folder. Specify a pool ID when the volumes should not be in a folder; 
  otherwise, specify a folder ID and the pool will be derived from the folder.
.PARAMETER force_vvol
  Forcibly move a Virtual Volume. Moving Virtual Volume is disruptive to the vCenter, hence it should only 
  be done by the VASA Provider (VP). This flag should only be set by the VP when it calls this API.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]$dest_pool_id,

    [bool]$force_vvol
  )
process{
    $Params = @{
        APIPath = 'volumes'
        Action = 'move'
        ReturnType = 'NsVolumeListReturn'
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
    return $ResponseObject
  }
}
function Move-NSVolumeBulk {
<#
.SYNOPSIS
  Move volumes and their related volumes to another pool. To change a single volume's folder assignment 
  (while remaining in the same pool), use a volume update operation to change the folder_id attribute.
.DESCRIPTION
  Move volumes and their related volumes to another pool. To change a single volume's folder assignment 
  (while remaining in the same pool), use a volume update operation to change the folder_id attribute.
.PARAMETER vol_ids 
  IDs of the volumes to move.
.PARAMETER dest_pool_id
  ID of the destination pool or folder. Specify a pool ID when the volumes should not be in a folder; otherwise, specify a folder ID and the pool will be derived from the folder.
.PARAMETER force_vvol
  Forcibly move a Virtual Volume. Moving Virtual Volume is disruptive to the vCenter, hence it should only be done by the VASA Provider (VP). This flag should only be set by the VP when it calls this API.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [Object[]]  $vol_ids,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]    $dest_pool_id,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [bool]      $force_vvol
  )
process{
    $Params = @{
        APIPath = 'volumes'
        Action = 'bulk_move'
        ReturnType = 'NsVolumeListReturn'
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
    return $ResponseObject
  }
}

function Stop-NSVolumeMove {
<#
.SYNOPSIS
  Abort the in-progress move of the specified volume to another pool.
.DESCRIPTION
  Abort the in-progress move of the specified volume to another pool.
.PARAMETER id
  ID of the volume to stop moving to a different pool.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]$id
  )
process{
    $Params = @{
        APIPath = 'volumes'
        Action = 'abort_move'
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
    return $ResponseObject
  }
}
function Set-NSVolumeBulkDeDupe {
<#
.SYNOPSIS
    Enable or disable dedupe on a list of volumes. If the volumes are not dedupe capable, the operation will fail for the specified volume.
.DESCRIPTION
    Enable or disable dedupe on a list of volumes. If the volumes are not dedupe capable, the operation will fail for the specified volume.
.PARAMETER vol_ids
  IDs of the volumes to enable/disable dedupe.
.PARAMETER dedupe_enabled
  Dedupe property to be applied to the list of volumes.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [Object[]]  $vol_ids,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]    
    [bool]      $dedupe_enabled
  )
process{
    $Params = @{
        APIPath = 'volumes'
        Action = 'bulk_set_dedupe'
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
    return $ResponseObject
  }
}
function Set-NSVolumeBulkOnline {
<#
.SYNOPSIS
  Bring a list of volumes online or offline.
.DESCRIPTION
  Bring a list of volumes online or offline.
.PARAMETER vol_ids
  IDs of the volumes to set online or offline.
.PARAMETER online
  Desired state of the volumes. "true" for online, "false" for offline.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [Object[]]  $vol_ids,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [bool]      $online
  )
process{
    $Params = @{
        APIPath = 'volumes'
        Action = 'bulk_set_online_and_offline'
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
    return $ResponseObject
  }
}


# SIG # Begin signature block
# MIIsWgYJKoZIhvcNAQcCoIIsSzCCLEcCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDp3PsKi9T/
# kB61GKKITkSHeHfC2Cyi+sPo+aD5q0Fv6eXDBZyPeVHEXGuniHAF2lvD589o5jn0
# 03RVNxe84RDfoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhcwghoTAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQDbwrXtiIA9T0TNqH41qPnQT1ZBqUq+VQQrlJ0+4RSrTesEeIO9+pogu
# mFqmQq1sNbi6kM1EfYI6SkbhYF0kU+kwDQYJKoZIhvcNAQEBBQAEggGAZGjtEh6D
# KCJLv+I4IcaMhbZGaZkfPhz4O09xG27MNOH6Ls2ElzDtPZbAt9Ik6UDsHCqTmHUG
# vZt+A+VIqCbA33JL7Ya5c0p5yFX2iZisOBQdUMeoYExTwMnlLa4O04IcpzHijRyi
# 939hniQHDWamdCfzWYLStWOXQP7Mv/P4afDg/sgWNfxE1m/dcZ+lCZBySpMXCzcE
# f6gxlgavDeslDBbvbbvZnb7MoZLaK1DF0rJGZ7x1g6YBZMUNMT1FZT9wSKG8agdx
# mG9u1vmu+UaO8ptqbU0dyGPFDnHnDxzhkQa5a6xC8GgjHne5WRLcJmV2vJxv0vBl
# cKPHktkzu2yyzKitT/u6onm3pWSqfYHgGi+sEseOuDSTevwZrJo9f5vgieDlhBum
# PQMAkpRQirS2VUbLxpnhB520VRmErhsAANQ/iB5Qu/q4PjO4zXVPqhQe98C1FfV8
# aUdBv+GiWLOCkSSl0Rg1T1bN0j761WCKVM4Adi4Ba/rTqQmezzWFcc/xoYIXYDCC
# F1wGCisGAQQBgjcDAwExghdMMIIXSAYJKoZIhvcNAQcCoIIXOTCCFzUCAQMxDzAN
# BglghkgBZQMEAgIFADCBhwYLKoZIhvcNAQkQAQSgeAR2MHQCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDB+l4aRoTyYeF6c7psaMmM7ZVRmxHMDTkFCORoE
# rNuK519g2e9r0tkCw5HibQ/bBo4CEBofC2/TeUWUmeIhxP1njygYDzIwMjQwNzMx
# MjEwNjA0WqCCEwkwggbCMIIEqqADAgECAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCSqG
# SIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwHhcNMjMwNzE0MDAwMDAwWhcNMzQxMDEzMjM1OTU5WjBI
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xIDAeBgNVBAMT
# F0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIzMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAo1NFhx2DjlusPlSzI+DPn9fl0uddoQ4J3C9Io5d6OyqcZ9xiFVjB
# qZMRp82qsmrdECmKHmJjadNYnDVxvzqX65RQjxwg6seaOy+WZuNp52n+W8PWKyAc
# wZeUtKVQgfLPywemMGjKg0La/H8JJJSkghraarrYO8pd3hkYhftF6g1hbJ3+cV7E
# Bpo88MUueQ8bZlLjyNY+X9pD04T10Mf2SC1eRXWWdf7dEKEbg8G45lKVtUfXeCk5
# a+B4WZfjRCtK1ZXO7wgX6oJkTf8j48qG7rSkIWRw69XloNpjsy7pBe6q9iT1Hbyb
# HLK3X9/w7nZ9MZllR1WdSiQvrCuXvp/k/XtzPjLuUjT71Lvr1KAsNJvj3m5kGQc3
# AZEPHLVRzapMZoOIaGK7vEEbeBlt5NkP4FhB+9ixLOFRr7StFQYU6mIIE9NpHnxk
# TZ0P387RXoyqq1AVybPKvNfEO2hEo6U7Qv1zfe7dCv95NBB+plwKWEwAPoVpdceD
# ZNZ1zY8SdlalJPrXxGshuugfNJgvOuprAbD3+yqG7HtSOKmYCaFxsmxxrz64b5bV
# 4RAT/mFHCoz+8LbH1cfebCTwv0KCyqBxPZySkwS0aXAnDU+3tTbRyV8IpHCj7Arx
# ES5k4MsiK8rxKBMhSVF+BmbTO77665E42FEHypS34lCh8zrTioPLQHsCAwEAAaOC
# AYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAf
# BgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUpbbvE+fv
# zdBkodVWqWUxo97V40kwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFt
# cGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVT
# dGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAgRrW3qCptZgXvHCNT4o8
# aJzYJf/LLOTN6l0ikuyMIgKpuM+AqNnn48XtJoKKcS8Y3U623mzX4WCcK+3tPUiO
# uGu6fF29wmE3aEl3o+uQqhLXJ4Xzjh6S2sJAOJ9dyKAuJXglnSoFeoQpmLZXeY/b
# JlYrsPOnvTcM2Jh2T1a5UsK2nTipgedtQVyMadG5K8TGe8+c+njikxp2oml101Dk
# RBK+IA2eqUTQ+OVJdwhaIcW0z5iVGlS6ubzBaRm6zxbygzc0brBBJt3eWpdPM43U
# jXd9dUWhpVgmagNF3tlQtVCMr1a9TMXhRsUo063nQwBw3syYnhmJA+rUkTfvTVLz
# yWAhxFZH7doRS4wyw4jmWOK22z75X7BC1o/jF5HRqsBV44a/rCcsQdCaM0qoNtS5
# cpZ+l3k4SF/Kwtw9Mt911jZnWon49qfH5U81PAC9vpwqbHkB3NpE5jreODsHXjlY
# 9HxzMVWggBHLFAx+rrz+pOt5Zapo1iLKO+uagjVXKBbLafIymrLS2Dq4sUaGa7oX
# /cR3bBVsrquvczroSUa31X/MtjjA2Owc9bahuEMs305MfR5ocMB3CtQC4Fxguyj/
# OOVSWtasFyIjTvTs0xf7UGv/B3cfcZdEQcm4RtNsMnxYL2dHZeUbc7aZ+WssBkbv
# QR7w8F/g29mtkIBEr4AQQYowggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5b
# MA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5
# NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPB
# PXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/
# nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLc
# Z47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mf
# XazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3N
# Ng1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yem
# j052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g
# 3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD
# 4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDS
# LFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwM
# O1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU
# 7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0j
# BBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8E
# PDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# DQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPO
# vxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQ
# TGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWae
# LJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPBy
# oyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfB
# wWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8l
# Y5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/
# O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbb
# bxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3
# OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBl
# dkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt
# 1nz8MIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwF
# ADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElE
# IFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKn
# JS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/W
# BTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHi
# LQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhm
# V1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHE
# tWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6
# MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mX
# aXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZ
# xd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfh
# vbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvl
# EFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn1
# 5GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNV
# HQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4Ix
# LVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAA
# MA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzs
# hV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre
# +i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8v
# C6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38
# dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNr
# Iv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDhjCCA4ICAQEw
# dzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCWCGSAFlAwQCAgUAoIHhMBoGCSqG
# SIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQwNzMxMjEw
# NjA0WjArBgsqhkiG9w0BCRACDDEcMBowGDAWBBRm8CsywsLJD4JdzqqKycZPGZzP
# QDA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCDS9uRt7XQizNHUQFdoQTZvgoraVZqu
# MxavTRqa1Ax4KDA/BgkqhkiG9w0BCQQxMgQwLohVKq9CK05izUN8UXhvvrRMB3eB
# 8PrONBN1VNSK8VK6396oaY3pbdHObW144g3TMA0GCSqGSIb3DQEBAQUABIICADgh
# VlCkEz1ZvXAK5cwqQuqXmGtI+Cvf2mC9nSP1KEwKCOAl/nVMbWQJzU3v2apuHTqs
# eflIHpncfVUnHPOkZ6MNa3L1VibmBcyPOhgnl0vCVNxehj27FQAGNhyi09gVs4rf
# 7FpGBAsy6sNj0wApPOt1OhrgK2ICQhbZzHVla8q+ZWJxgH8bAJbM4FhYrGySQMBc
# Ww1wExg84xl11/VDzrMV6hudmBx9dluwb9kR9IPi6p2pqm6bRJd2HMmEQkPrilJz
# 91V8A6vfXWx9HAuRQlGF5nK2uBQRA7FLpeBWm0yH9RIOxc3U600sT/glMibTYB6S
# JO5z3wchvcn/zbFeeCxvxhq8twLFXdv7+ilZ38U6e7o5JM4GA1G1anIzdwUT/tBj
# IFE+89LQYZ9m4nqSwr1D7mqhMhWX9Ec02ofnwVrxR19UwUvf+NwOziZ6ilylIN2v
# 1Co42/nbhOhnBpuD/7hLLeS48gtfOckIaX0Dcbx5yWzic5uqOcC20q5u6CtBfK6P
# FY3yODGHrKIFjsi8tS3Sb6aK8reKTklG8Tyroe1YJ2zMxuKBHDzDe7U/blsDUPW1
# bPGztHYPn0cPZWqRWs05ZReV03dchiAMIHKLc+O7/cj7GpOo3qGH5vJA99zuE0P3
# M/15kdxKqTj5h38ZxFD/bn6/hGL3Res19DdEZx3t
# SIG # End signature block
