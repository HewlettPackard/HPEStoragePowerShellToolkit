# ProtocolEndpoint.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSProtocolEndpoint {
<#
.SYNOPSIS
  Retrieve information on a set of protocol endpoints or a single protocol endpoint.
.DESCRIPTION
  Retrieve information on a set of protocol endpoints or a single protocol endpoint.
.PARAMETER id
  Identifier for the protocol endpoint.
.PARAMETER name
  Name of the protocol endpoint.
.PARAMETER description
  Text description of the protocol endpoint.
.PARAMETER pool_name
  Name of the pool where the protocol endpoint resides. If pool option is not specified, protocol endpoint is assigned to the default pool.
.PARAMETER pool_id
  Identifier associated with the pool in the storage pool table.
.PARAMETER state
  Operational state of protocol endpoint.
.PARAMETER serial_number
  Identifier associated with the protocol endpoint for the SCSI protocol.
.PARAMETER target_name
  The iSCSI Qualified Name (IQN) or the Fibre Channel World Wide Node Name (WWNN) of the target protocol endpoint.
.PARAMETER group_specific_ids
  External UID is used to compute the serial number and IQN which never change even if the running group changes (e.g. after group merge). 
  Group-specific IDs determine whether external UID is used for computing serial number and IQN.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [Parameter(ParameterSetName='nonId')]                                       [string]  $name,
    [Parameter(ParameterSetName='nonId')]                                       [string]  $description,
    [Parameter(ParameterSetName='nonId')]                                       [string]  $pool_name,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')]   [string]  $pool_id,
    [Parameter(ParameterSetName='nonId')] [ValidateSet('normal','deprecated')]  [string]  $state,
    [Parameter(ParameterSetName='nonId')]                                       [string]  $serial_number,
    [Parameter(ParameterSetName='nonId')]                                       [string]  $target_name,
    [Parameter(ParameterSetName='nonId')]                                       [bool]    $group_specific_ids
  )
process{ 
    $API = 'protocol_endpoints'
    $Param = @{ ObjectName = 'ProtocolEndpoint'
                APIPath = 'protocol_endpoints'
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
                {   $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}
