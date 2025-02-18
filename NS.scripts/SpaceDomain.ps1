# SpaceDomain.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSSpaceDomain {
<#
.SYNOPSIS
        List a set of space domains.
.DESCRIPTION
        List a set of space domains.
.PARAMETER id
        Identifier for the space domain.
.PARAMETER pool_id 
        Identifier associated with the pool in the storage pool table.
.PARAMETER pool_name 
        Name of the pool containing the space domain.
.PARAMETER app_category_id
        Identifier of the application category associated with the space domain.
.PARAMETER app_category_name
        Name of the application category associated with the space domain.
.PARAMETER perf_policy_names
        Name of the performance policies associated with the space domain.
.PARAMETER sample_rate
        Sample rate value.
.PARAMETER volumes
        Volumes belonging to the space domain.
.PARAMETER block_size
        Block size in bytes of volumes belonging to the space domain.
.PARAMETER deduped
        Volumes in space domain are deduplicated by default.
.PARAMETER encrypted
        Volumes in space domain are encrypted.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
        [Parameter(ParameterSetName='id')]    [ValidatePattern('([0-9a-f]{42})')]       [string]    $id,
        [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')]       [string]    $pool_id,
        [Parameter(ParameterSetName='nonId')]                                           [string]    $pool_name,
        [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')]       [string]    $app_category_id,
        [Parameter(ParameterSetName='nonId')]                                           [string]    $app_category_name,
        [Parameter(ParameterSetName='nonId')]                                           [Object[]]  $perf_policy_names,
        [Parameter(ParameterSetName='nonId')]                                           [long]      $sample_rate,
        [Parameter(ParameterSetName='nonId')]                                           [Object[]]  $volumes,
        [Parameter(ParameterSetName='nonId')]                                           [long]      $block_size,
        [Parameter(ParameterSetName='nonId')]                                           [bool]      $deduped,
        [Parameter(ParameterSetName='nonId')]                                           [bool]      $encrypted
)
process{
        $API = 'space_domains'
        $Param = @{
                ObjectName = 'SpaceDomain'
                APIPath = 'space_domains'
        }
        if ($id)
        {       # Get a single object for given Id.
                $Param.Id = $id
                $ResponseObject = Get-NimbleStorageAPIObject @Param
                return $ResponseObject
        }
        else
        {       # Get list of objects matching the given filter.
                $Param.Filter = @{}
                $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
                foreach ($key in $ParameterList.keys)
                {       if ($key.ToLower() -ne 'fields')
                        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
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
