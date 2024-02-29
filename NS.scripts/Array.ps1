# Array.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSArray {
<#
.SYNOPSIS
  Creates an array with given attributes.
.DESCRIPTION
  Creates an array with given attributes.
.PARAMETER name
  The user provided name of the array. It is also the array's hostname.
.PARAMETER pool_name
  Name of pool to which this is a member.
.PARAMETER serial
  Serial number of the array.
.PARAMETER dedupe_disabled
  Is data deduplication disabled for this array.
.PARAMETER create_pool
  Whether to create associated pool during array create.
.PARAMETER pool_description
  Text description of the pool to be created during array creation.
.PARAMETER allow_lower_limits
  A True setting will allow you to add an array with lower limits to a pool with higher limits.
.PARAMETER ctrlr_a_support_ip
  Controller A Support IP Address.
.PARAMETER ctrlr_b_support_ip
  Controller B Support IP Address.
.PARAMETER nic_list
  List NICs information. Used when creating an array.
.PARAMETER secondary_mgmt_ip
  Secondary management IP address for the Group.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string] $name,

    [Parameter(Mandatory = $True)]
    [string] $pool_name,

    [Parameter(Mandatory = $True)]
    [string] $serial,

    [Nullable[bool]] $dedupe_disabled,
    
    [Nullable[bool]] $create_pool,

    [string] $pool_description,

    [Nullable[bool]] $allow_lower_limits,

    [Parameter(Mandatory = $True)]
    [string] $ctrlr_a_support_ip,

    [Parameter(Mandatory = $True)]
    [string] $ctrlr_b_support_ip,

    [Parameter(Mandatory = $True)]
    [Object[]] $nic_list,

    [string] $secondary_mgmt_ip
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
            ObjectName = 'Array'
            APIPath = 'arrays'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSArray {
<#
.SYNOPSIS
  Read one or more arrays.
.DESCRIPTION
  Read one or more arrays.
.PARAMETER id
  Identifier for array. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
  The user provided name of the array. It is also the array's hostname. String of up to 63 alphanumeric and can include hyphens characters but cannot start with hyphen.
.PARAMETER full_name
  The array's fully qualified name. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER status
  Reachability status of the array in the group. Reachability status of the array in the group, possible values: 'unreachable', 'reachable'.
.PARAMETER role
  Role of the array in the group. Array's role in the group, possible values: 'invalid', 'leader', 'backup_leader', 'member', 'non_member', 'failed'.
.PARAMETER pool_name
  Name of pool to which this is a member. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.	 
.PARAMETER pool_id
  ID of pool to which this is a member. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER model
  Array model. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER serial
  Serial number of the array. Example: 'AC-109084'.
.PARAMETER version
  Software version of the array. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER usage_valid
  Indicates whether the usage of array is valid. Possible values: 'true', 'false'.	
.PARAMETER all_flash
  Whether it is an all-flash array. Possible values: 'true', 'false'.
.PARAMETER extended_model
  Extended model of the array. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER is_supported_hw_config
  Whether it is a supported hardware config. Possible values: 'true', 'false'.
.PARAMETER ctrlr_a_support_ip
  Controller A Support IP Address.
.PARAMETER ctrlr_b_support_ip
  Controller B Support IP Address.
.EXAMPLE
  C:\> Get-NSArray

  name            id                                            model           serial          role            version
  ----            --                                            -----           ------          ----            -------
  sjc-arnab2-arr  091bde905fd66eed40000000000000000000000006    vmware          sjc-arnab2-arr  backup_leader   5.0.3.100-57...
  sjc-arnab-arr   091bde905fd66eed40000000000000000000000001    vmware          sjc-arnab-arr   leader          5.0.3.100-57...

  This command will retrieves list of currently connected Array.
.EXAMPLE
  C:\> Get-nsArray -role leader

  name            id                                            model           serial          role            version
  ----            --                                            -----           ------          ----            -------
  sjc-arnab-arr   091bde905fd66eed40000000000000000000000001    vmware          sjc-arnab-arr   leader          5.0.3.100-57...

  This command will retrieve a specific Application Server specified by role.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]    [ValidatePattern('([0-9a-f]{42})')]         [string]  $id,
    [Parameter(ParameterSetName='nonId')]                                             [string]  $name,
    [Parameter(ParameterSetName='nonId')]                                             [string]  $full_name,
    [Parameter(ParameterSetName='nonId')] [ValidateSet( 'unreachable', 'reachable')]  [string]  $status,
    [Parameter(ParameterSetName='nonId')] [ValidateSet( 'leader', 'non_member', 'invalid', 'backup_leader', 'member', 'failed')]
                                                                                      [string]  $role,
    [Parameter(ParameterSetName='nonId')]                                             [string]  $pool_name,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')]         [string]  $pool_id,
    [Parameter(ParameterSetName='nonId')]                                             [string]  $model,
    [Parameter(ParameterSetName='nonId')]                                             [string]  $serial,
    [Parameter(ParameterSetName='nonId')]                                             [string]  $version,
    [Parameter(ParameterSetName='nonId')]                                             [bool]    $usage_valid,
    [Parameter(ParameterSetName='nonId')]                                             [bool]    $all_flash,
    [Parameter(ParameterSetName='nonId')]                                             [bool]    $is_fully_dedupe_capable,
    [Parameter(ParameterSetName='nonId')]                                             [bool]    $dedupe_disabled,
    [Parameter(ParameterSetName='nonId')]                                             [bool]    $is_supported_hw_config,
    [Parameter(ParameterSetName='nonId')]                                             [bool]    $allow_lower_limits,
    [Parameter(ParameterSetName='nonId')]                                             [string]  $ctrlr_a_support_ip,
    [Parameter(ParameterSetName='nonId')]                                             [string]  $ctrlr_b_support_ip
)
process{
    $API = 'arrays'
    $Param = @{
      ObjectName = 'Array'
      APIPath = 'arrays'
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
        { if ($key.ToLower() -ne 'fields')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
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

function Set-NSArray {
<#
.SYNOPSIS
  Modify the settings for the array.
.DESCRIPTION
  Modify the settings for the array.
.PARAMETER id 
  Identifier for array. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'
.PARAMETER name
  The user provided name of the array. It is also the array's hostname. String of up to 63 alphanumeric and can include hyphens characters but cannot start with hyphen.
.PARAMETER force
  Forcibly change the name of the specified array.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
                                          [string]  $name,
                                          [bool]    $force
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
            ObjectName = 'Array'
            APIPath = 'arrays'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSArray {
<#
.SYNOPSIS
  Removes an array with the given ID. The force option is being deprecated.
.DESCRIPTION
  Removes an array with the given ID. The force option is being deprecated.
.PARAMETER id
  Identifier for array. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'
.EXAMPLE
  C:\> Remove-NSArray -id 0928eada7f8dd99d3b000000000000000000000001

  This command will remove the currently connected Array from the group.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]
    [string]$id
  )
process {
    $Params = @{
        ObjectName = 'Array'
        APIPath = 'arrays'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}

function Invoke-NSArrayFailover {
<#
.SYNOPSIS
  Perform a failover on the specified array.
.DESCRIPTION
  Perform a failover on the specified array.
.PARAMETER id
  ID of the array to perform failover on. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER force 
  Initiate failover without performing any precheck. Possible values: 'true', 'false'.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]  $id,

                                        [bool]    $force
  )
process{
    $Params = @{
        APIPath = 'arrays'
        Action = 'failover'
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

function Stop-NSArray {
<#
.SYNOPSIS
  Halt the specified array. Restarting the array will require physically powering it back on.
.DESCRIPTION
  Halt the specified array. Restarting the array will require physically powering it back on.
.PARAMETER id
  g	ID of the array to halt. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE
  C:\> Stop-NSArray -id 0928eada7f8dd99d3b000000000000000000000001

  This command will halt the Array. The Array will need to be physically powered off and on to restore.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]$id
  )
process{
    $Params = @{
        APIPath = 'arrays'
        Action = 'halt'
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

function Reset-NSArray {
<#
.SYNOPSIS
  Reboot the specified array.
.DESCRIPTION
  Reboot the specified array.
.PARAMETER id
  ID of the array to halt. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE
  C:\> Reset-NSArray -id 0928eada7f8dd99d3b000000000000000000000001

  This command will reset (reboot) the currently connected Array.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]$id
  )
process{
    $Params = @{
        APIPath = 'arrays'
        Action = 'reboot'
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
