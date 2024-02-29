# FibreChannelPort.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSFibreChannelPort {
<#
.SYNOPSIS
  List a set of Fibre Channel ports for all reachable arrays or a set of Fibre Channel ports for a single array.
.DESCRIPTION
  List a set of Fibre Channel ports for all reachable arrays or a set of Fibre Channel ports for a single array.
.PARAMETER id
  Identifier for the Fibre Channel Port. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER array_name_or_serial
  Name or serial number of the array. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]  [ValidatePattern('([0-9a-f]{42})')] [string] $id,
    [Parameter(ParameterSetName='nonId')]                                   [string] $array_name_or_serial
  )
process{ 
    $API = 'fibre_channel_ports'
    $Param = @{
      ObjectName = 'FibreChannelPort'
      APIPath = 'fibre_channel_ports'
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
