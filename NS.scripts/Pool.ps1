# Pool.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSPool {
<#
.SYNOPSIS
  Create a new pool.
.DESCRIPTION
  Create a pool on the array referenced.
.PARAMETER name
  Name of pool. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER description
  Text description of pool. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER array_list
  List of arrays in the pool with detailed information. When create/update array list, only arrays' id is required. List of arrays' detailed information.
  The object that needs to exist here will look like this '@{id = '"0900000000000004d3000000000000000000000003'; array_id = '0900000000000004d3000000000000000000000003'}'
.PARAMETER dedupe_all_volumes
  Indicates if dedupe is enabled by default for new volumes on this pool. Possible values: 'true', 'false'.
.EXAMPLE
    C:\> New-NSPool -name 'MyPool' -array_list '@{id = "0900000000000004d3000000000000000000000003"; array_id ="'0900000000000004d3000000000000000000000003"}'

    name    id                                         capacity    free_space  cache_capacity snap_count vol_count description
    ----    --                                         --------    ----------  -------------- ---------- --------- -----------
    default 0a1bde905fd66eed40000000000000000000000001 22875399783 19387926256 13432258560    2          2         Default pool
    MyPool1 0a1bde905fd66eed40000000000000000000000003 22875399783 22875399783 13432258560    0          0         My New Description no.529

    This command will retrieve the array pool(s).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string] $name,

    [string] $description,

    [Parameter(Mandatory = $True)]
    [Object[]] $array_list,

    [bool] $dedupe_all_volumes
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
            ObjectName = 'Pool'
            APIPath = 'pools'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSPool {
<#
.SYNOPSIS
    Read a set of pools or a single pool.
.DESCRIPTION
  Read a set of pools or a single pool.
.PARAMETER id
  Identifier for the pool.
.PARAMETER name
  Name of pool.
.PARAMETER full_name
  Fully qualified name of pool.
.PARAMETER usage_valid
  Indicates whether the usage of pool is valid.
.PARAMETER all_flash
  Indicate whether the pool is an all_flash pool.
.PARAMETER dedupe_capable
  Indicates whether the pool is capable of hosting deduped volumes.
.PARAMETER dedupe_all_volumes_capable
  Indicates whether the pool can enable dedupe by default.
.PARAMETER dedupe_all_volumes
  Indicates if dedupe is enabled by default for new volumes on this pool.
.PARAMETER is_default
  Indicates if this is the default pool.
.EXAMPLE
    C:\> Get-NSPool

    name    id                                         capacity    free_space  cache_capacity snap_count vol_count description
    ----    --                                         --------    ----------  -------------- ---------- --------- -----------
    default 0a1bde905fd66eed40000000000000000000000001 22875399783 19387926256 13432258560    2          2         Default pool
    MyPool1 0a1bde905fd66eed40000000000000000000000003 22875399783 22875399783 13432258560    0          0         My New Description no.529

    This command will retrieve the array pool(s).
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$name,

    [Parameter(ParameterSetName='nonId')]
    [string]$full_name,

    [Parameter(ParameterSetName='nonId')]
    [bool]$usage_valid,

    [Parameter(ParameterSetName='nonId')]
    [bool]$all_flash,

    [Parameter(ParameterSetName='nonId')]
    [bool]$dedupe_capable,

    [Parameter(ParameterSetName='nonId')]
    [bool]$dedupe_all_volumes_capable,

    [Parameter(ParameterSetName='nonId')]
    [bool]$dedupe_all_volumes,

    [Parameter(ParameterSetName='nonId')]
    [bool]$is_default
  )
process
  {
    $API = 'pools'
    $Param = @{
      ObjectName = 'Pool'
      APIPath = 'pools'
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

function Set-NSPool {
<#
.SYNOPSIS
  Modify pool attributes.
.DESCRIPTION
  Modify pool attributes.
.PARAMETER id
  Identifier for the pool.
.PARAMETER name
  Name of pool.
.PARAMETER description
  Text description of pool.
.PARAMETER array_list
  List of arrays in the pool with detailed information. When create/update array list, only arrays' ID is required.
.PARAMETER force
  Forcibly remove an array from array_list via an update operation even if the array is not reachable.
  There should no volumes currently in the pool for the forced update operation to succeed.
.PARAMETER dedupe_all_volumes
  Indicates if dedupe is enabled by default for new volumes on this pool.
.EXAMPLE
    C:\> Set-NSPool -id 0a1bde905fd66eed40000000000000000000000003 -description My New Description no.499

    name    id                                         capacity    free_space  cache_capacity snap_count vol_count description
    ----    --                                         --------    ----------  -------------- ---------- --------- -----------
    MyPool1 0a1bde905fd66eed40000000000000000000000003 22875399783 22875399783 13432258560    0          0         My New Description no.499

    This command will modify the description for the pool specified by id.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]  $id,

    [string]  $name,

    [string]  $description,

    [Object[]] $array_list,

    [bool]    $force,

    [bool]    $dedupe_all_volumes
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
            ObjectName = 'Pool'
            APIPath = 'pools'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSPool {
<#
.SYNOPSIS
  Will delete the pool identified by the given Pool Id.
.DESCRIPTION
  Will delete the pool identified by the given Pool Id.
.PARAMETER id
  Identifier for the pool. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE
  C:> Remove-NSPool -id 2a0df0fe6f7dc7bb16000000000000000000004817
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id
  )
process {
    $Params = @{
        ObjectName = 'Pool'
        APIPath = 'pools'
        Id = $id
      }

    Remove-NimbleStorageAPIObject @Params
  }
}

function Merge-NSPool {
<#
.SYNOPSIS
  Merge the specified pool into the target pool. All volumes on the specified pool are moved to the target pool and the specified pool is then deleted. All the arrays in the pool are assigned to the target pool.
.DESCRIPTION
  Merge the specified pool into the target pool. All volumes on the specified pool are moved to the target pool and the specified pool is then deleted. All the arrays in the pool are assigned to the target pool.
.PARAMETER id
  ID of the specified pool.
.PARAMETER target_pool_id
  ID of the target pool.
.PARAMETER force
  Forcibly merge the specified pool into target pool.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$target_pool_id,

    [Nullable[bool]]$force
)
process{
    $Params = @{
        APIPath = 'pools'
        Action = 'merge'
        ReturnType = 'NsPoolMergeReturn'
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
