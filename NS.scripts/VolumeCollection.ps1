# VolumeCollection.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSVolumeCollection {
<#
.SYNOPSIS
  Create a volume collection.
.DESCRIPTION
  Create a volume collection.
.PARAMETER prottmpl_id
  Identifier of the protection template whose attributes will be used to create this volume collection. This attribute is only used for input when creating a volume collection and is not outputed.
.PARAMETER name 
  Name of volume collection.
.PARAMETER description
  Text description of volume collection.
.PARAMETER app_sync
  Application Synchronization.
.PARAMETER app_server
  Application server hostname.
.PARAMETER app_id 
  Application ID running on the server. Application ID can only be specified if application synchronization is \\"vss\\".
.PARAMETER app_cluster_name
  If the application is running within a Windows cluster environment, this is the cluster name.
.PARAMETER app_service_name
  If the application is running within a Windows cluster environment then this is the instance name of the service running within the cluster environment.
.PARAMETER vcenter_hostname
  VMware vCenter hostname. Custom port number can be specified with vCenter hostname using \\":\\".
.PARAMETER vcenter_username
  Application VMware vCenter username.
.PARAMETER vcenter_password
  Application VMware vCenter password.
.PARAMETER agent_hostname
  Generic backup agent hostname. Custom port number can be specified with agent hostname using \\":\\".
.PARAMETER agent_username 
  Generic backup agent username.
.PARAMETER agent_password
  Generic backup agent password.
.PARAMETER is_standalone_volcoll
  Indicates whether this is a standalone volume collection.
.PARAMETER metadata
  Key-value pairs that augment a volume collection's attributes.
.EXAMPLE
  C:\> New-NSVolumeCollection -name test4

  Name  creation_time snapcoll_count app_sync id                                         description
  ----  ------------- -------------- -------- --                                         -----------
  test4 1533274233    0              none     0728eada7f8dd99d3b00000000000000000000009d

  This command will create a new volume collections using the minimal number of parameters.
.EXAMPLE
  C:\> new-NSVolumeCollection -name test5 -description "My Test VolCollection" -app_sync vss -app_server MyHost.fqdn.com -app_id hyperv

  Name  creation_time snapcoll_count app_sync id                                         description
  ----  ------------- -------------- -------- --                                         -----------
  test5 1533274233    0              vss      0728eada7f8dd99d3b00000000000000000000009e My Test VolCollection

  This command will create a new Volume Collection for hyper-V based storage that uses VSS enabled Snapshots.
.EXAMPLE
  C:\> new-NSVolumeCollection -name test6 -description "My Test VolCollection" -app_sync vss -app_server MyHost.fqdn.com -app_id hyper-v

  Name  creation_time snapcoll_count app_sync id                                         description
  ----  ------------- -------------- -------- --                                         -----------
  test6 1533274233    0              vmware   0728eada7f8dd99d3b00000000000000000000009f My Test VolCollection

  This command will create a new Volume Collection for VMWare VM based storage that uses vCenter orchestrated Snapshots.
#>
[CmdletBinding()]
param(
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]
    [ValidatePattern('([0-9a-f]{42})')]
    [string] $prottmpl_id,

    [Parameter(ParameterSetName='none', Mandatory = $True)]
    [Parameter(ParameterSetName='vss', Mandatory = $True)]
    [Parameter(ParameterSetName='vmware', Mandatory = $True)]
    [Parameter(ParameterSetName='generic', Mandatory = $True)]  [string] $name,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')] [string] $description,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')] [string] $repl_priority,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')] [string] $replication_type,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]                             [ValidateSet( 'vss', 'vmware', 'none', 'generic')]
                                            [string] $app_sync,

    [Parameter(ParameterSetName='vss')]                                 [ValidateSet( 'exchange_dag', 'sql2012', 'sql2014', 'inval', 'sql2005', 'sql2016', 'exchange', 'sql2017', 'sql2008', 'hyperv')]
                                            [string] $app_id,
    [Parameter(ParameterSetName='vss')]     [string] $app_server,
    [Parameter(ParameterSetName='vss')]     [string] $app_cluster_name,
    [Parameter(ParameterSetName='vss')]     [string] $app_service_name,

    [Parameter(ParameterSetName='vmware')]  [string] $vcenter_hostname,
    [Parameter(ParameterSetName='vmware')]  [string] $vcenter_username,
    [Parameter(ParameterSetName='vmware')]  [string] $vcenter_password,

    [Parameter(ParameterSetName='generic')]  [string] $agent_hostname,
    [Parameter(ParameterSetName='generic')]  [string] $agent_username,
    [Parameter(ParameterSetName='generic')]  [string] $agent_password,

    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]  [bool] $is_standalone_volcoll,

    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]  [Object[]] $metadata
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
            ObjectName = 'VolumeCollection'
            APIPath = 'volume_collections'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSVolumeCollection {
<#
.SYNOPSIS
  Read a set of volume collections or a single volume collection.
.DESCRIPTION
  Read a set of volume collections or a single volume collection.
.PARAMETER id
  Identifier for volume collection.
.PARAMETER prottmpl_id
  Identifier of the protection template whose attributes will be used to create this volume collection.
  This attribute is only used for input when creating a volume collection and is not outputed.
.PARAMETER name
  Name of volume collection.
.PARAMETER full_name
  Fully qualified name of volume collection.
.PARAMETER search_name
  Name of volume collection used for object search.
.PARAMETER description
  Text description of volume collection.
.PARAMETER repl_priority
  Replication priority for the volume collection with the following choices: {normal | high}.
.PARAMETER pol_owner_name
  Owner group.
.PARAMETER app_sync
  Application Synchronization.
.PARAMETER app_server
  Application server hostname.
.PARAMETER app_id
  Application ID running on the server. Application ID can only be specified if 
  application synchronization is \\"vss\\".
.PARAMETER app_cluster_name 
  If the application is running within a Windows cluster environment, this is the cluster name.
.PARAMETER app_service_name 
  If the application is running within a Windows cluster environment then this is the instance name of 
  the service running within the cluster environment.
.PARAMETER vcenter_hostname
  VMware vCenter hostname. Custom port number can be specified with vCenter hostname using \\":\\".
.PARAMETER vcenter_username
  Application VMware vCenter username.
.PARAMETER agent_hostname
  Generic backup agent hostname. Custom port number can be specified with agent hostname using \\":\\".
.PARAMETER agent_username
  Generic backup agent username.
.PARAMETER replication_partner 
  Replication partner for this volume collection.
.PARAMETER protection_type 
  Specifies if volume collection is protected with schedules. If protected, indicated whether replication is setup.
.PARAMETER lag_time
  Replication lag time for volume collection.
.PARAMETER is_standalone_volcoll 
  Indicates whether this is a standalone volume collection.
.PARAMETER is_handing_over
  Indicates whether a handover operation is in progress on this volume collection.
.PARAMETER handover_replication_partner
  Replication partner to which ownership is being transferred as part of handover operation.
.PARAMETER metadata
  Key-value pairs that augment a volume collection's attributes.
.EXAMPLE
  C:\> Get-NSVolumeCollection

  Name     creation_time snapcoll_count app_sync id                                         description
  ----     ------------- -------------- -------- --                                         -----------
  testcol1 1520878446    1              vss      0728eada7f8dd99d3b000000000000000000000005
  volcoll  1526559894    0              none     0728eada7f8dd99d3b000000000000000000000006
  mycol1   1531438403    25             none     0728eada7f8dd99d3b000000000000000000000007

  This command will retrieve the volume collections.
.EXAMPLE
  C:\> Get-NSVolumeCollection -name volcoll

  Name    creation_time snapcoll_count app_sync id                                         description
  ----    ------------- -------------- -------- --                                         -----------
  volcoll 1526559894    0              none     0728eada7f8dd99d3b000000000000000000000006

  This command will retrieve the volume collections specified by name.
#>  
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]                                            [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $id,
    [Parameter(ParameterSetName='nonId')]   [string]  $prottmpl_id,
    [Parameter(ParameterSetName='nonId')]   [string]  $name,
    [Parameter(ParameterSetName='nonId')]   [string]  $full_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $search_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $description,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'normal', 'high')]
                                            [string]  $repl_priority,
    [Parameter(ParameterSetName='nonId')]   [string]  $pol_owner_name,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'synchronous', 'periodic_snapshot')]    
                                            [string]  $replication_type,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'soft_available', 'not_applicable')]
                                            [string]$synchronous_replication_type,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'in_sync', 'not_applicable', 'out_of_sync', 'unknown')]
                                            [string]  $synchronous_replication_state,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'vss', 'vmware', 'none', 'generic')]
                                            [string]  $app_sync,
    [Parameter(ParameterSetName='nonId')]   [string]  $app_server,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'exchange_dag', 'sql2012', 'sql2014', 'inval', 'sql2005', 'sql2016', 'exchange', 'sql2017', 'sql2008', 'hyperv')]
                                            [string]  $app_id,
    [Parameter(ParameterSetName='nonId')]   [string]  $app_cluster_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $app_service_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $vcenter_hostname,
    [Parameter(ParameterSetName='nonId')]   [string]  $vcenter_username,
    [Parameter(ParameterSetName='nonId')]   [string]  $agent_hostname,
    [Parameter(ParameterSetName='nonId')]   [string]  $agent_username,
    [Parameter(ParameterSetName='nonId')]   [string]  $replication_partner,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'unprotected', 'remote', 'local')]
                                            [string]  $protection_type,
    [Parameter(ParameterSetName='nonId')]   [long]    $lag_time,
    [Parameter(ParameterSetName='nonId')]   [bool]    $is_standalone_volcoll,
    [Parameter(ParameterSetName='nonId')]   [bool]    $is_handing_over,
    [Parameter(ParameterSetName='nonId')]   [string]  $handover_replication_partner,
    [Parameter(ParameterSetName='nonId')]   [Object[]]$metadata
  )
process{
    $API = 'volume_collections'
    $Param = @{
      ObjectName = 'VolumeCollection'
      APIPath = 'volume_collections'
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

function Set-NSVolumeCollection {
<#
.SYNOPSIS
  Modify attributes of the specified volume collection.
.DESCRIPTION
  Modify attributes of the specified volume collection.
.PARAMETER id
        Identifier for volume collection.
.PARAMETER name 
        Name of volume collection.
.PARAMETER description
        Text description of volume collection.
.PARAMETER app_sync
        Application Synchronization.
.PARAMETER app_server
        Application server hostname.
.PARAMETER app_id
        Application ID running on the server. Application ID can only be specified if application synchronization is \\"vss\\".
.PARAMETER app_cluster_name
        If the application is running within a Windows cluster environment, this is the cluster name.
.PARAMETER app_service_name
        If the application is running within a Windows cluster environment then this is the instance name of the service running within the cluster environment.
.PARAMETER vcenter_hostname
        VMware vCenter hostname. Custom port number can be specified with vCenter hostname using \\":\\".
.PARAMETER vcenter_username
        Application VMware vCenter username.
.PARAMETER vcenter_password 
        Application VMware vCenter password.
.PARAMETER agent_hostname
        Generic backup agent hostname. Custom port number can be specified with agent hostname using \\":\\".
.PARAMETER agent_username
        Generic backup agent username.
.PARAMETER agent_password
        Generic backup agent password.
.PARAMETER metadata
        Key-value pairs that augment a volume collection's attributes.
.EXAMPLE
  C:\> Set-NSVolumeCollection -id 0728eada7f8dd99d3b00000000000000000000009d -description test

  Name  creation_time snapcoll_count app_sync id                                         description
  ----  ------------- -------------- -------- --                                         -----------
  test4 1533274233    0              none     0728eada7f8dd99d3b00000000000000000000009d test

  This command will change the volume collections description.
#>
[CmdletBinding(DefaultParameterSetName='none')]
param(
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='none')]
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='vss')]
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='vmware')]
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='generic')]
  [ValidatePattern('([0-9a-f]{42})')]       [string]$id,

  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vss')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]   [string] $name,

  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vss')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]   [string] $description,

  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vss')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]
  [ValidateSet( 'vss', 'vmware', 'none', 'generic')]  [string] $app_sync,
  
  [Parameter(ParameterSetName='vss')]       [string] $app_server,
  
  [Parameter(ParameterSetName='vss')]                                   [ValidateSet( 'exchange_dag', 'sql2012', 'sql2014', 'inval', 'sql2005', 'sql2016', 'exchange', 'sql2017', 'sql2008', 'hyperv')]
                                            [string] $app_id,

  [Parameter(ParameterSetName='vss')]       [string] $app_cluster_name,
  [Parameter(ParameterSetName='vss')]       [string] $app_service_name,
  
  [Parameter(ParameterSetName='vmware')]    [string] $vcenter_hostname,
  [Parameter(ParameterSetName='vmware')]    [string] $vcenter_username,
  
  [Parameter(ParameterSetName='generic')]   [string] $agent_hostname,
  [Parameter(ParameterSetName='generic')]   [string] $agent_username,
  
  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vss')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]   [Object[]] $metadata
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
            ObjectName = 'VolumeCollection'
            APIPath = 'volume_collections'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSVolumeCollection {
<#
.SYNOPSIS
  Delete a specified volume collection. A volume collection cannot be deleted if it has associated volumes. 
.DESCRIPTION
  Delete a specified volume collection. A volume collection cannot be deleted if it has associated volumes.
.PARAMETER id
  Identifier for volume collection.
.EXAMPLE
  C:\> Remove-NSVolumeCollection -id 0728eada7f8dd99d3b00000000000000000000009d

  This command will remove the volume collection specified by id.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process {
    $Params = @{
        ObjectName = 'VolumeCollection'
        APIPath = 'volume_collections'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}

function Invoke-NSVolumeCollectionPromote {
<#
.SYNOPSIS
  Take ownership of the specified volume collection. 
.DESCRIPTION
  Take ownership of the specified volume collection. The volumes associated with the volume collection will be set 
  to online and be available for reading and writing. Replication will be disabled on the affected schedules and 
  must be re-configured if desired. Snapshot retention for the affected schedules will be set to the greater of 
  the current local or replica retention values.
.PARAMETER id
  ID of the promoted volume collection. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'promote'
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

function Invoke-NSVolumeCollectionDemote {
<#
.SYNOPSIS
  Release ownership of the specified volume collection. 
.DESCRIPTION
  Release ownership of the specified volume collection. The volumes associated with the volume collection will set 
  to offline and a snapshot will be created, then full control over the volume collection will be transferred to 
  the new owner. This option can be used following a promote to revert the volume collection back to its prior 
  configured state. This operation does not alter the configuration on the new owner itself, but does require the 
  new owner to be running in order to obtain its identity information.
.PARAMETER id
  ID of the demoted volume collection. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER replication_partner_id
  ID of the new owner. If invoke_on_upstream_partner is provided, utilize the ID of the current owner i.e. upstream 
  replication partner. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER invoke_on_upstream_partner
  Invoke demote request on upstream partner. Default: 'false'. Possible values: 'true', 'false'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $replication_partner_id,
                                          [bool]    $invoke_on_upstream_partner
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'demote'
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

function Start-NSVolumeCollectionHandover {
<#
.SYNOPSIS
  Gracefully transfer ownership of the specified volume collection.
.DESCRIPTION
  Gracefully transfer ownership of the specified volume collection. This action can be used to pass control of 
  the volume collection to the downstream replication partner. Ownership and full control over the volume 
  collection will be given to the downstream replication partner. The volumes associated with the volume 
  collection will be set to offline prior to the final snapshot being taken and replicated, thus ensuring 
  full data synchronization as part of the transfer. By default, the new owner will automatically begin 
  replicating the volume collection back to this node when the handover completes.
.PARAMETER id
  ID of the volume collection be handed over to the downstream replication partner. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER replication_partner_id
  ID of the new owner. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER no_reverse
  Do not automatically reverse direction of replication. Using this argument will prevent the new owner from 
  automatically replicating the volume collection to this node when the handover completes. The default 
  behavior is to enable replication back to this node. Default: 'false'. Possible values: 'true', 'false'.
.PARAMETER invoke_on_upstream_partner
  Invoke handover request on upstream partner. Default: 'false'. Possible values: 'true', 'false'.	
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]                 [string]  $id,
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]                 [string]  $replication_partner_id,
    [Parameter(ValueFromPipelineByPropertyName=$True)]  [bool]    $no_reverse,
    [Parameter(ValueFromPipelineByPropertyName=$True)]  [bool]    $invoke_on_upstream_partner,
    [Parameter(ValueFromPipelineByPropertyName=$True)]  [bool]    $override_upstream_down
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'handover'
        ReturnType = 'void'
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

function Stop-NSVolumeCollectionHandover {
<#
.SYNOPSIS
  Abort in-progress handover.
.DESCRIPTION
  Abort in-progress handover. If for some reason a previously invoked handover request is unable to complete, this action can be used to cancel it.
.PARAMETER id
  ID of the volume collection on which to abort handover. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'abort_handover'
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

function Test-NSVolumeCollection {
<#
.SYNOPSIS
  Validate a volume collection with either Microsoft VSS or VMware application synchronization.
.DESCRIPTION
  Validate a volume collection with either Microsoft VSS or VMware application synchronization.
.PARAMETER id
  ID of the volume collection on which to Test. A 42 digit hexadecimal 
  number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'validate'
        ReturnType = 'NsAppServerResp'
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
