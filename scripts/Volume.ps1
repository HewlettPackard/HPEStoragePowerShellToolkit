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

