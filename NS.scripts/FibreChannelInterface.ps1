# FibreChannelInterface.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSFibreChannelInterface {
<#
.SYNOPSIS
  Retrieve information on a set of Fibre Channel initiator aliases or a single Fibre Channel initiator alias.
.DESCRIPTION
  Retrieve information on a set of Fibre Channel initiator aliases or a single Fibre Channel initiator alias.
.PARAMETER id
  Identifier for the Fibre Channel interface. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER array_name_or_serial
  Name or serial number of array where the interface is hosted. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.	 
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(  [Parameter(ParameterSetName='id')]    [ValidatePattern('([0-9a-f]{42})')] [string] $id,
        [Parameter(ParameterSetName='nonId')]                                     [string]$array_name_or_serial
  )
process{
    $API = 'fibre_channel_interfaces'
    $Param = @{
      ObjectName = 'FibreChannelInterface'
      APIPath = 'fibre_channel_interfaces'
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

function Set-NSFibreChannelInterface {
<#
.SYNOPSIS
  Modify the online attribute (i.e., the administrative state) of the Fibre Channel interface.
.DESCRIPTION
  Modify the online attribute (i.e., the administrative state) of the Fibre Channel interface.
.PARAMETER id
  Identifier for the Fibre Channel interface. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER online
  Identify whether the Fibre Channel interface is online. Possible values: 'true', 'false'.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]   [string]$id,
        [Parameter(Mandatory = $True)]        [bool] $online
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
            ObjectName = 'FibreChannelInterface'
            APIPath = 'fibre_channel_interfaces'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}
