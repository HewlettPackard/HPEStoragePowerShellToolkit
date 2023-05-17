# Subnet.ps1: This is part of Nimble Group Management SDK. lost!
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.


function Get-NSSubnet {
<#
.SYNOPSIS
    Lists subnets.
.DESCRIPTION
    Lists subnets.
.PARAMETER id 
  Identifier for the initiator group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name 
  Name of subnet configuration. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER network 
  Subnet network address. Four numbers in the range [0,255] separated by periods. Example: '128.0.0.1'.
.PARAMETER netmask
  Subnet netmask address. A netmask expressed as a 32 bit binary value must have the highest bit set (2^31) and the lowest bit 
  clear (2^0) with the first zero followed by only zeros. Example: '255.255.255.0'.
.PARAMETER type 
  Subnet type. Options include 'mgmt', 'data', and 'mgmt,data'. Possible values: 'invalid', 'unconfigured', 'mgmt', 'data', 'mgmt_data'.
.PARAMETER allow_iscsi
  Possible values: 'true', 'false'.
.PARAMETER allow_group 
  Possible values: 'true', 'false'.
.PARAMETER discovery_ip 
  Subnet network address. Four numbers in the range [0,255] separated by periods. Example: '128.0.0.1'.
.PARAMETER mtu 
  MTU for specified subnet. Valid MTU's are in the 512-16000 range. Positive integer in range [576,16000].
.PARAMETER netzone_type 
  Specify Network Affinity Zone type for iSCSI enabled subnets. Valid types are Single, Bisect, and EvenOdd for iSCSI subnets. Possible values: 'none', 'evenodd', 'bisect', 'single'.
.PARAMETER vlan_id
  VLAN ID for specified subnet. Valid ID's are in the 1-4094 range. Positive integer in range [0,4096].
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$name,

    [Parameter(ParameterSetName='nonId')]
    [string]$network,

    [Parameter(ParameterSetName='nonId')]
    [string]$netmask,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'mgmt', 'unconfigured', 'data', 'mgmt_data', 'invalid')]
    [string]$type,

    [Parameter(ParameterSetName='nonId')]
    [bool]$allow_iscsi,

    [Parameter(ParameterSetName='nonId')]
    [bool]$allow_group,

    [Parameter(ParameterSetName='nonId')]
    [string]$discovery_ip,

    [Parameter(ParameterSetName='nonId')]
    [long]  $mtu,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'single', 'evenodd', 'bisect', 'none')]
    [string]$netzone_type,

    [Parameter(ParameterSetName='nonId')]
    [long]  $vlan_id
  )
process{
    $API = 'subnets'
    $Param = @{
      ObjectName = 'Subnet'
      APIPath = 'subnets'
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

