# NetworkInterface.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSNetworkInterface {
<#
.SYNOPSIS
  List a set of network interfaces or a single network interface.
.DESCRIPTION
  List a set of network interfaces or a single network interface.
.PARAMETER id
  Identifier for the interface.
.PARAMETER array_name_or_serial
  Name or serial of the array where the interface is hosted.
.EXAMPLE
  C:\> Get-NSNetworkInterface

  id                                  name            array_id                            array_name_or_serial     controller_id
  --                                  ----            --------                            --------------------     -------------
  1c28eada7f8dd99d3b00000001000000... eth1            0928eada7f8dd99d3b00000000000000... chapi-afa-a1             c328eada7f8dd99d3b000...
  1c28eada7f8dd99d3b00000001000000... eth2            0928eada7f8dd99d3b00000000000000... chapi-afa-a1             c328eada7f8dd99d3b000...
  1c28eada7f8dd99d3b00000001000000... eth3            0928eada7f8dd99d3b00000000000000... chapi-afa-a1             c328eada7f8dd99d3b000...

  This command will retrieve the NetworkInterface from the array.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$array_name_or_serial
)
process
  { $API = 'network_interfaces'
    $Param = @{ ObjectName = 'NetworkInterface'
                APIPath = 'network_interfaces'
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
