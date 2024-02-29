# PerformancePolicy.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSPerformancePolicy {
<#
.SYNOPSIS
  Create performance policy.
.DESCRIPTION
  Create performance policy.
.PARAMETER name
  Name of the Performance Policy.
.PARAMETER description
  Description of a performance policy.
.PARAMETER block_size
  Block Size in bytes to be used by the volumes created with this specific performance policy. Supported block sizes 
  are 4096 bytes (4 KB), 8192 bytes (8 KB), 16384 bytes(16 KB), and 32768 bytes (32 KB). Block size of a performance 
  policy cannot be changed once the performance policy is created.
.PARAMETER compress
  Flag denoting if data in the associated volume should be compressed.
.PARAMETER cache
  Flag denoting if data in the associated volume should be cached.
.PARAMETER cache_policy
  Specifies how data of associated volume should be cached. Supports two policies, 'normal' and 'aggressive'. 'normal' 
  policy caches data but skips in certain conditions such as sequential I/O. 'aggressive' policy will accelerate caching 
  of all data belonging to this volume, regardless of sequentiality.
.PARAMETER space_policy
  Specifies the state of the volume upon space constraint violation such as volume limit violation or volumes above 
  their volume reserve, if the pool free space is exhausted. Supports two policies, 'offline' and 'non_writable'.
.PARAMETER app_category
  Specifies the application category of the associated volume.
.PARAMETER dedupe_enabled
  Specifies if dedupe is enabled for volumes created with this performance policy.
.EXAMPLE
  C:\> New-NSPerformancePolicy -name MyTestPolicy1

  name          id                                         app_category block_size description cache_policy compress dedupe_enabled predefined space_policy
  ----          --                                         ------------ ---------- ----------- ------------ -------- -------------- ---------- ------------
  MyTestPolicy1 0328eada7f8dd99d3b000000000000000000000061 Unassigned   4096                   normal       True     False          False      offline

  This command will create a new minimal performance policy from the array. Most settings such as block size will use the default 4K.
.EXAMPLE
  C:\> New-NSPerformancePolicy -name MyTestPolicy2 -description "My Test Perf Policy" -block_size 8192 -compress True

  name          id                                         app_category block_size description         cache_policy compress dedupe_enabled predefined space_policy
  ----          --                                         ------------ ---------- -----------         ------------ -------- -------------- ---------- ------------
  MyTestPolicy2 0328eada7f8dd99d3b000000000000000000000062 Unassigned   8192       My Test Perf Policy normal       True     False          False      offline

  This command will create a common performance policy from the array.
#>
[CmdletBinding()]
param(
    [Parameter(ParameterSetName='allButId', Mandatory = $True)]
    [AllowEmptyString()]
    [string] $name,

    [Parameter(ParameterSetName='allButId')]
    [AllowEmptyString()]
    [string] $description,

    [long] $block_size,

    [bool] $compress,

    [bool] $cache,

    [ValidateSet( 'normal', 'no_write', 'aggressive_read_no_write', 'disabled', 'aggressive')]
    [string] $cache_policy,

    [ValidateSet( 'offline', 'login_only', 'non_writable', 'read_only', 'invalid')]
    [string] $space_policy,

    [string] $app_category,

    [bool] $dedupe_enabled
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
            ObjectName = 'PerformancePolicy'
            APIPath = 'performance_policies'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSPerformancePolicy {
<#
.SYNOPSIS
  List all the performance policies.
.DESCRIPTION
  List all the performance policies.
.PARAMETER id
  Unique Identifier for the Performance Policy.
.PARAMETER name
  Name of the Performance Policy.
.PARAMETER full_name
  Fully qualified name of the Performance Policy.
.PARAMETER search_name
  Name of the Performance Policy used for object search.
.PARAMETER description
  Description of a performance policy.
.PARAMETER block_size
  Block Size in bytes to be used by the volumes created with this specific performance policy. Supported block sizes are 4096 bytes 
  (4 KB), 8192 bytes (8 KB), 16384 bytes(16 KB), and 32768 bytes (32 KB). Block size of a performance policy cannot be changed 
  once the performance policy is created.
.PARAMETER compress
  Flag denoting if data in the associated volume should be compressed.
.PARAMETER cache
  Flag denoting if data in the associated volume should be cached.
.PARAMETER cache_policy
  Specifies how data of associated volume should be cached. Supports two policies, 'normal' and 'aggressive'. 'normal' policy 
  caches data but skips in certain conditions such as sequential I/O. 'aggressive' policy will accelerate caching of all data 
  belonging to this volume, regardless of sequentiality.
.PARAMETER space_policy
  Specifies the state of the volume upon space constraint violation such as volume limit violation or volumes above their volume 
  reserve, if the pool free space is exhausted. Supports two policies, 'offline' and 'non_writable'.
.PARAMETER app_category
  Specifies the application category of the associated volume.
.PARAMETER dedupe_enabled
  Specifies if dedupe is enabled for volumes created with this performance policy.
.PARAMETER deprecated
  Specifies if this performance policy is deprecated.
.PARAMETER predefined
  Specifies if this performance policy is predefined (read-only).
.EXAMPLE
  C:\> Get-NSPerformancePolicy

  name                     id                                         app_category block_size description                                                                 cache_policy
  ----                     --                                         ------------ ---------- -----------                                                                 ------------
  default                  0328eada7f8dd99d3b000000000000000000000001 Other        4096       Default performance policy                                                  normal
  Exchange 2003 data store 0328eada7f8dd99d3b000000000000000000000002 Exchange     4096       Performance policy suitable for use with Microsoft Exchange 2003 data store normal
  Exchange 2007 data store 0328eada7f8dd99d3b000000000000000000000003 Exchange     8192       Performance policy suitable for use with Microsoft Exchange 2007 data store normal
  Exchange log             0328eada7f8dd99d3b000000000000000000000004 Exchange     16384      Performance policy suitable for use with Microsoft Exchange log             normal

  This command will retrieve the initiator groups from the array.
.EXAMPLE
  C:\> PS:> Get-NSPerformancePolicy -name 'SQL Server'

  name       id                                         app_category block_size description                                                   cache_policy compress dedupe_enabled pre

  ----       --                                         ------------ ---------- -----------                                                   ------------ -------- -------------- ---
  SQL Server 0328eada7f8dd99d3b000000000000000000000005 SQL Server   8192       Performance policy suitable for use with Microsoft SQL Server normal       True     False          Tru

  This command will retrieve a specific Performance Policy from the array by name.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{2})([0-9a-f]{16})([0-9a-f]{16})([0-9a-f]{8})')]
    [string]  $id,

    [Parameter(ParameterSetName='nonId')]
    [string]  $name,

    [Parameter(ParameterSetName='nonId')]
    [string]  $full_name,

    [Parameter(ParameterSetName='nonId')]
    [string]  $search_name,

    [Parameter(ParameterSetName='nonId')]
    [string]  $description,

    [Parameter(ParameterSetName='nonId')]
    [long]  $block_size,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $compress,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $cache,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'normal', 'no_write', 'aggressive_read_no_write', 'disabled', 'aggressive')]
    [string]  $cache_policy,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'offline', 'login_only', 'non_writable', 'read_only', 'invalid')]
    [string]  $space_policy,

    [Parameter(ParameterSetName='nonId')]
    [string]  $app_category,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $dedupe_enabled,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $deprecated,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $predefined
  )
  process
  {
    $API = 'performance_policies'
    $Param = @{
      ObjectName = 'PerformancePolicy'
      APIPath = 'performance_policies'
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

function Set-NSPerformancePolicy {
<#
.SYNOPSIS
  Update attributes of a performance policy. Block size of a performance policy cannot be changed once the perfomance policy is created.
.DESCRIPTION
  Update attributes of a performance policy. Block size of a performance policy cannot be changed once the perfomance policy is created.
.PARAMETER id
  Unique Identifier for the Performance Policy.
.PARAMETER name
  Name of the Performance Policy.
.PARAMETER description
  Description of a performance policy.
.PARAMETER compress
  Flag denoting if data in the associated volume should be compressed.
.PARAMETER cache
  Flag denoting if data in the associated volume should be cached.
.PARAMETER cache_policy
  Specifies how data of associated volume should be cached. Supports two policies, 'normal' and 'aggressive'. 'normal' policy 
  caches data but skips in certain conditions such as sequential I/O. 'aggressive' policy will accelerate caching of all data 
  belonging to this volume, regardless of sequentiality.
.PARAMETER space_policy
  Specifies the state of the volume upon space constraint violation such as volume limit violation or volumes above their 
  volume reserve, if the pool free space is exhausted. Supports two policies, 'offline' and 'non_writable'.
.PARAMETER app_category
  Specifies the application category of the associated volume.
.PARAMETER dedupe_enabled
  Specifies if dedupe is enabled for volumes created with this performance policy.
.EXAMPLE
  C:\> Set-NSPerformancePolicy -id 0328eada7f8dd99d3b000000000000000000000061 -description "My New Description"

  name          id                                         app_category block_size description        cache_policy compress dedupe_enabled predefined space_policy
  ----          --                                         ------------ ---------- -----------        ------------ -------- -------------- ---------- ------------
  MyTestPolicy1 0328eada7f8dd99d3b000000000000000000000061 Unassigned   4096       My New Description normal       True     False          False      offline

  This command will Modify a setting of the specified Performance Policy.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [string] $name,

    [string] $description,

    [bool] $compress,

    [Nullable[bool]] $cache,

    [ValidateSet( 'normal', 'no_write', 'aggressive_read_no_write', 'disabled', 'aggressive')]
    [string] $cache_policy,

    [ValidateSet( 'offline', 'login_only', 'non_writable', 'read_only', 'invalid')]
    [string] $space_policy,

    [string] $app_category,

    [Nullable[bool]] $dedupe_enabled
  )
process {   # Gather request params based on user input.
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
        $Params = @{  ObjectName = 'PerformancePolicy'
                      APIPath = 'performance_policies'
                      Id = $id
                      Properties = $RequestData
                  }
        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSPerformancePolicy {
<#
.SYNOPSIS
  Delete a performance policy.
.DESCRIPTION
  Delete a performance policy.
.PARAMETER id
  Unique Identifier for the Performance Policy.
.EXAMPLE
  C:\> Remove-NSPerformancePolicy -id 0328eada7f8dd99d3b000000000000000000000061

  This command will remove the specified Performance Policy.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [string]$id
    )
process { $Params = @{  ObjectName = 'PerformancePolicy'
                        APIPath = 'performance_policies'
                        Id = $id
                    }
          Remove-NimbleStorageAPIObject @Params
        }
}
