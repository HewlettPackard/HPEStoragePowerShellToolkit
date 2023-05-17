# ReplicationPartner.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSReplicationPartner {
<#
.SYNOPSIS
  List the replication partners available.
.DESCRIPTION
  List the replication partners available.
.PARAMETER name
  Name of replication partner. String of up to 63 alphanumeric and can include hyphens characters but cannot start with hyphen.
.PARAMETER description
  Description of replication partner. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER secret
  Replication partner shared secret, used for mutual authentication of the partners. String of 8 to 255 printable characters excluding ampersand and ;[]`. Example: 'password-91'.
.PARAMETER control_port
  Port number of partner control interface. Positive integer value up to 65535 representing TCP/IP port. Example: 1234.
.PARAMETER hostname
  IP address or hostname of partner interface. This must be the partner's Group Management IP address. String of up to 64 
  alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER repl_hostname 
  IP address or hostname of partner data interface. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER data_port
  Port number of partner data interface. Positive integer value up to 65535 representing TCP/IP port. Example: 1234.
.PARAMETER pool_id
  The pool ID where volumes replicated from this partner will be created. Replica volumes created as clones ignore this parameter and are always created in 
  the same pool as their parent volume. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER folder_id
  The Folder ID within the pool where volumes replicated from this partner will be created. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER match_folder
  Indicates whether to match the upstream volume's folder on the downstream. Possible values: 'true', 'false'.
.PARAMETER subnet_label
  Label of the subnet used to replicate to this partner. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER subnet_type
  Type of the subnet used to replicate to this partner. Possible values: 'invalid', 'unconfigured', 'mgmt', 'data', 'mgmt_data'.
.PARAMETER throttles
  Throttles used while replicating from/to this partner.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]    [string]  $name,
                                      [string]  $description,
    [Parameter(Mandatory = $True)]    [string]  $secret,
                                      [int]     $control_port,
                                      [string]  $hostname,
                                      [string]  $repl_hostname,
                                      [int]     $data_port,
                                      [string]  $pool_id,
                                      [string]  $folder_id,
                                      [bool]    $match_folder,
    [Parameter(Mandatory = $True)]    [string]  $subnet_label,
    [ValidateSet( 'mgmt', 'unconfigured', 'data', 'mgmt_data', 'invalid')]
                                      [string]  $subnet_type
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
            ObjectName = 'ReplicationPartner'
            APIPath = 'replication_partners'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSReplicationPartner {
<#
.SYNOPSIS
  List the replication partners available.
.DESCRIPTION
  List the replication partners available. The most common method is to run this command 
  with no arguments, and it will simply return the collection of replication partners.
.PARAMETER id
  Identifier for a replication partner.
.PARAMETER name
  Name of replication partner.
.PARAMETER full_name
  Fully qualified name of replication partner.
.PARAMETER search_name
  Name of replication partner used for object search.
.PARAMETER description
  Description of replication partner.
.PARAMETER secret
  Replication partner shared secret, used for mutual authentication of the partners.
.PARAMETER control_port
  Port number of partner control interface.
.PARAMETER hostname
  IP address or hostname of partner interface.  This must be the partner's Group Management IP address.
.PARAMETER repl_hostname
  IP address or hostname of partner data interface.
.PARAMETER data_port
  Port number of partner data interface.
.PARAMETER is_alive
  Whether the partner is available, and responding to pings.
.PARAMETER last_keepalive_error
  Most recent error while attempting to ping the partner.
.PARAMETER cfg_sync_status
  Indicates whether all volumes and volume collections have been synced to the partner.
.PARAMETER last_sync_error
  Most recent error seen while attempting to sync objects to the partner.
.PARAMETER pool_id
  The pool ID where volumes replicated from this partner will be created. Replica volumes created as clones ignore this parameter and are always created in the same pool as their parent volume.
.PARAMETER pool_name
  The pool name where volumes replicated from this partner will be created.
.PARAMETER folder_id
  The Folder ID within the pool where volumes replicated from this partner will be created. This is not supported for pool partners.
.PARAMETER folder_name
  The Folder name within the pool where volumes replicated from this partner will be created.
.PARAMETER match_folder
  Indicates whether to match the upstream volume's folder on the downstream.
.PARAMETER paused
  Indicates whether replication traffic from/to this partner has been halted.
.PARAMETER subnet_label
  Label of the subnet used to replicate to this partner.
.PARAMETER subnet_type
  Type of the subnet used to replicate to this partner.
.PARAMETER throttled_bandwidth
  Current bandwidth throttle for this partner, expressed either as megabits per second or as the largest possible 64-bit 
  signed integer (9223372036854775807) to indicate that there is no throttle. This attribute is superseded by throttled_bandwidth_current.
.PARAMETER throttled_bandwidth_kbps
  Current bandwidth throttle for this partner, expressed either as kilobits per second or as the largest possible 64-bit signed 
  integer (9223372036854775807) to indicate that there is no throttle. This attribute is superseded by throttled_bandwidth_current_kbps.
.PARAMETER subnet_network
  Subnet used to replicate to this partner.
.PARAMETER subnet_netmask
  Subnet mask used to replicate to this partner.
.PARAMETER replication_direction
  Direction of replication configured with this partner.
.EXAMPLE
  C:> Get-NSReplicationPartner

  This is the most common way to run this command, with no arguments.
#>
[CmdletBinding()]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]     [string]  $id,
    [Parameter(ParameterSetName='nonId')]   [string]  $name,
    [Parameter(ParameterSetName='nonId')]   [string]  $full_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $search_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $description,
    [Parameter(ParameterSetName='nonId')]   [string]  $secret,
    [Parameter(ParameterSetName='nonId')]   [int]     $control_port,
    [Parameter(ParameterSetName='nonId')]   [string]  $hostname,
    [Parameter(ParameterSetName='nonId')]   [string]  $repl_hostname,
    [Parameter(ParameterSetName='nonId')]   [int]     $data_port,
    [Parameter(ParameterSetName='nonId')]   [bool]    $is_alive,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'N/A', 'No', 'Yes')]      [string]  $cfg_sync_status,
    [Parameter(ParameterSetName='nonId')]   [string]  $array_serial,
    [ValidatePattern('([0-9a-f]{42})')]
    [Parameter(ParameterSetName='nonId')]   [string]  $pool_id,
    [Parameter(ParameterSetName='nonId')]   [string]  $pool_name,
    [ValidatePattern('([0-9a-f]{42})')]
    [Parameter(ParameterSetName='nonId')]   [string]  $folder_id,
    [Parameter(ParameterSetName='nonId')]   [string]  $folder_name,
    [Parameter(ParameterSetName='nonId')]   [bool]    $match_folder,
    [Parameter(ParameterSetName='nonId')]   [bool]    $paused,
    [Parameter(ParameterSetName='nonId')]   [string]  $subnet_label,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'mgmt', 'unconfigured', 'data', 'mgmt_data', 'invalid')]
                                            [string]  $subnet_type,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'upstream', 'downstream', 'none', 'bi_directional')]
                                            [string]  $replication_direction
  )
process{ 
    $API = 'replication_partners'
    $Param = @{ ObjectName = 'ReplicationPartner'
                APIPath = 'replication_partners'
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
        {  if ($key.ToLower() -ne 'fields')
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

function Set-NSReplicationPartner {
<#
.SYNOPSIS
  Modify attributes of a replication partner relationship.
.DESCRIPTION
  Modify attributes of a replication partner relationship.
.PARAMETER id
  Identifier for a replication partner.
.PARAMETER name
  Name of replication partner.
.PARAMETER description
  Description of replication partner.
.PARAMETER secret
  Replication partner shared secret, used for mutual authentication of the partners.
.PARAMETER control_port
  Port number of partner control interface.
.PARAMETER hostname
  IP address or hostname of partner interface.  This must be the partner's Group Management IP address.
.PARAMETER repl_hostname
  IP address or hostname of partner data interface.
.PARAMETER data_port
  Port number of partner data interface.
.PARAMETER pool_id
  The pool ID where volumes replicated from this partner will be created. Replica volumes created as clones ignore this parameter and are always created in the same pool as their parent volume.
.PARAMETER folder_id
  The Folder ID within the pool where volumes replicated from this partner will be created. This is not supported for pool partners.
.PARAMETER match_folder
  Indicates whether to match the upstream volume's folder on the downstream.
.PARAMETER subnet_label
  Label of the subnet used to replicate to this partner.
.PARAMETER subnet_type
  Type of the subnet used to replicate to this partner.
.PARAMETER throttles
  Throttles used while replicating from/to this partner.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]
    [string]  $id,
    [string]  $name,
    [string]  $description,
    [string]  $secret,
    [int]     $control_port,
    [string]  $hostname,
    [string]  $repl_hostname,
    [int]     $data_port,
    [ValidatePattern('([0-9a-f]{42})')]
    [string]  $pool_id,
    [ValidatePattern('([0-9a-f]{42})')]
    [string]  $folder_id,
    [bool]    $match_folder,
    [string]  $subnet_label,
    [ValidateSet( 'mgmt', 'unconfigured', 'data', 'mgmt_data', 'invalid')]
    [string]  $subnet_type,
    [Object[]]$throttles
  )
process{# Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        { if ($key.ToLower() -ne 'id')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                  { $RequestData.Add("$($var.name)", ($var.value))
                  }
            }
        }
        $Params = @{
            ObjectName = 'ReplicationPartner'
            APIPath = 'replication_partners'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSReplicationPartner {
<#
.SYNOPSIS
  Delete a replication partner relationship.
.DESCRIPTION
  Delete a replication partner relationship.
.PARAMETER id
  The replication partner relationship Id.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')] [string]$id
    )
process { $Params = @{  ObjectName = 'ReplicationPartner'
                        APIPath = 'replication_partners'
                        Id = $id
                    }

          Remove-NimbleStorageAPIObject @Params
        }
}

function Suspend-NSReplicationPartner {
<#
.SYNOPSIS
  Pause replication for the specified partner.
.DESCRIPTION
  Pause replication for the specified partner.
.PARAMETER id
  ID of the partner to pause.
#>
[CmdletBinding()]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process{
    $Params = @{
        APIPath = 'replication_partners'
        Action = 'pause'
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

function Resume-NSReplicationPartner {
<#
.SYNOPSIS
  Resume Replication for a specific replication partner relationship identified by the Id.
.DESCRIPTION
  Resume Replication for a specific replication partner relationship identified by the Id.
.PARAMETER id
  The specific ID representing the Replication partner replication relationship which should be resumed.   
#>
[CmdletBinding()]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]$id
  )
process{
    $Params = @{
        APIPath = 'replication_partners'
        Action = 'resume'
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

function Test-NSReplicationPartner {
<#
.SYNOPSIS
  Test connectivity to the specified partner.
.DESCRIPTION
  Test connectivity to the specified partner.
.PARAMETER id
  ID of the replication partner relationship to test.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param(  [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]$id
  )
process{
    $Params = @{
        APIPath = 'replication_partners'
        Action = 'test'
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
