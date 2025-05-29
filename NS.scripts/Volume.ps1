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
# MIIsVQYJKoZIhvcNAQcCoIIsRjCCLEICAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABECUFd7n/iFx
# 0Sl622HAc72WmaaU/2OGO8Kx5oCMQCVyulcBOYN4ajT0evl8AomnB75aMJ2UtdJ7
# pcIFqutyexYloIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhIwghoOAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQIiF4ZqTX+01RaEXJ6iqUGU8JD88moAe4yIjx0vLXwnKTz5y9A7xwoOL
# DsCBOuUg+4rigD3YnaF01W1ZVjxRFxAwDQYJKoZIhvcNAQEBBQAEggGAgPCBzsJt
# 0uCUsg9eE+9ACDK2HNLU3+cOmhqjDKkpxcpiNzbAes4JpwsVFMH2gZ9uokkISEUi
# bQXV6hWHKal2G7yxhQJCEcZRpkJS4gVYwJ3SRUgB7TsrtqhNIYYM8HvxlBZ+Sxxx
# T8t2C956WllLsNSp5LObMlrwJIdDBvXjmo3CljKU08SaM+FCxceYstSARIGtDWvS
# QB1GBiI8KmhsDz+usgOiFj42tuxA+Ka5MV4gUafKxe37USPFyy7/8UTAZcS/l64z
# Fql2B8tR8tf8X+rad/Rqfpm6LhrZnS6zA5bE/gi2KAGUf2KxtwedaffP8IAOminX
# UKCfcl/zuTF2AuanJMqSKO4d4FocOEfdci+Bu5Q8o3UhfuxuQNXUFRpLblHMy63j
# ajYQv150khNGu0Tq4Wtrzq/Ti17Ybfk06IQK3MiV+yqHck6og3z3mqdyeTMBWCiz
# +2zYJRFRFxTAusvuKRDhzERqxgRJW1bCtdswS9I7zGV25Emo73tsQ9XToYIXWzCC
# F1cGCisGAQQBgjcDAwExghdHMIIXQwYJKoZIhvcNAQcCoIIXNDCCFzACAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDBNjoke1yoFhRfgT9dYo7JZaCtWf4g/MLPQP/4B
# DReLiNAoIv4m4ijFTm0AHhV90t4CEQDCrBXNjzLzrB3+4gD8DpVhGA8yMDI1MDUx
# NTIyNDMxMFqgghMDMIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVow
# QjELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdp
# Q2VydCBUaW1lc3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL5qc5/2lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L
# 660x5XltSVhhK64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLusl
# xdr9Qq82aKcpA9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7a
# vVnpUVmPvkxT8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl
# 7/r419CvEYVIrH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+N
# BikDO0mlUh902wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVki
# qLq+ISTdEjJKGjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5
# n10jxmGpxoMc6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h
# 6gYldp4FCMgrXdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNe
# REXAu2xUDEW8aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLq
# fY/M/SdV6mwWTyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIB
# hzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggr
# BgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0j
# BBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGal
# Y17uT5IfdqBbMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBp
# bmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tO
# CB3RKE/P09x7gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSX
# gmUrDKNSQqGTdpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPn
# vIWrqVogK0qM8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM
# 2UeUUW/8z3fvjxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlT
# VYzqfLDbe9PpBKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ
# /xll/HjO9JbNVekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef
# 4uaZFORNekUgQHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk91
# 04WQzYuVNsxyoVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7
# ucykW7eaCuWBsBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZD
# BD+XgbF+23/zBjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3K
# eFUCS7tpFk7CrDqkMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkq
# hkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBU
# cnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFV
# xyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8z
# H1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE9
# 8NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iE
# ZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXm
# G6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVV
# JnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz
# +ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8
# ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkr
# qPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKo
# wSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3I
# XjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaA
# FOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4
# oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqG
# SIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQ
# XeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwI
# gqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs
# 5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAn
# gkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnG
# E4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9
# P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt
# +8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Z
# iza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgx
# tGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimH
# CUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCC
# BY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290
# IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE9
# 8orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9S
# H8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g
# 1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RY
# jgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgD
# EI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNA
# vwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDg
# ohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQA
# zH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOk
# GLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHF
# ynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gd
# LfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYE
# FOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# dDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkq
# hkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7
# IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/5
# 9PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0
# POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISf
# b8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhU
# LSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEBMHcwYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QQIQC65mvFq6f5WHxvnpBOMzBDANBglghkgBZQMEAgIFAKCB4TAaBgkqhkiG9w0B
# CQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI1MDUxNTIyNDMxMFow
# KwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQU29OF7mLb0j575PZxSFCHJNWGW0UwNwYL
# KoZIhvcNAQkQAi8xKDAmMCQwIgQgdnafqPJjLx9DCzojMK7WVnX+13PbBdZluQWT
# mEOPmtswPwYJKoZIhvcNAQkEMTIEMHIONM6MOKQf/a/z9B2tYf10dj4wAmbyg4MQ
# 41a66YQfAX5Q4UPGsuf/E25ewH4g0TANBgkqhkiG9w0BAQEFAASCAgAuX0KcbwG3
# yoY33DEK6TinUBud15aiz44kQBYZdW+jYWkGxXMu0vQjIfauAgtX1CsHPkuwXAvY
# VS++YuGggBCspcemIIG5zLdsFM0Ndh30EWMHMMuFrU3LJPYxUwewF7KmyZ7qipse
# 3R20g2rmBdQKVa6eh1MAy684EEiiuu1HJmguH17dV6bjQK1PYE+CK29SnYWCmgoO
# pkn+REd9ewOnpt6Jjz79lD1KLx4xLbzXnq8gH9Nuts4FnWZkR4rPs+z/nUiW63F8
# lfHjF/f6Sj8DHIwsq0VJct5oUab2KoncXnGFLl1L/ha9kkQXXA5lbu+AeNTsFKWA
# EkNrKoQJELincq8LUdTNFxLkcIs1RUQmnvhhguSHxmO4X5YePvNPr9d1doEeuzp5
# ADfirnZkFXnRjBrMECtW0WM7E6SaUvGbz4r9BzBFPJK7nv911UG0RAtqkpPVyffn
# +l0WsziSfNWWblHUDIv93t5Hv+WCVdIa7UsR4PkTsWSNiCNU8RgGoJPZSZA5VLn0
# 86VXRqsATlL4TdwGffVcYALrJNuk4arHzLUWDpSwr8x5eM3Kvo9/6IL9c4YEF+TY
# TPql80KDz00Y0+tV6MAb6//ebuqlC8jR6iPTGxh28TnE68sVJA4VVVdxxW5AFxti
# EM2qc7F3OMitjU2VKWk3tIRjX65updLRkw==
# SIG # End signature block
