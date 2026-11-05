# FibreChannelConfig.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSFibreChannelConfig {
<#
.SYNOPSIS
    List the Fibre Channel configuration.
.DESCRIPTION
    List the Fibre Channel configuration.
.PARAMETER id
  Identifier for Fibre Channel configuration.
.PARAMETER group_leader_array
  Name of the group leader array. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$group_leader_array
  )
process{
    $API = 'fibre_channel_configs'
    $Param = @{
      ObjectName = 'FibreChannelConfig'
      APIPath = 'fibre_channel_configs'
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

function Update-NSFibreChannelConfigRegenerate {
<#
.SYNOPSIS
  Update (regenerate) Fibre Channel configuration after hardware changes.
.DESCRIPTION
  Update (regenerate) Fibre Channel configuration after hardware changes.
.PARAMETER id
  ID of the Fibre Channel configuration. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER wwnn_base_str
  Base World Wide Node Name(WWNN). Six bytes expressed in hex separated by colons. Example: 'af:32:f1'.
.PARAMETER precheck
  Check if the interfaces are offline before regenerating the WWNN (World Wide Node Name). Possible values: 'true', 'false'.
.EXAMPLE 
  C:\ Update-NSFibreChannelConfigRegenerate -id 2c28eada7f8dd99d3b0001000000000b0000000100 -wwnn_base_str 'af:32:f1' -precheck $True

  This command is used to regenerate World Wide Node Names for a new or replaced array
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)] 
    [ValidatePattern('([0-9a-f]{42})')]                                   [string]  $id,
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)] [string]  $wwnn_base_str,
    [Parameter(ValueFromPipelineByPropertyName=$True)]                    [bool]    $precheck
  )
process{
    $Params = @{
        APIPath = 'fibre_channel_configs'
        Action = 'regenerate'
        ReturnType = 'NsFcConfigRegenerateReturn'
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

function Update-NSFibreChannelConfigHardware {
<#
.SYNOPSIS
  Update Fibre Channel configuration after hardware changes. This is a triggered Action to run once you wish to commit a new hardware change
.DESCRIPTION
  Update Fibre Channel configuration after hardware changes. This is a triggered Action to run once you wish to commit a new hardware change
.PARAMETER id
  ID of the Fibre Channel configuration.
.EXAMPLE
  C:\ Update-NSFibreChannelConfigHardware -id 2c28eada7f8dd99d3b0001000000000b0000000100 
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process{
    $Params = @{
        APIPath = 'fibre_channel_configs'
        Action = 'hw_upgrade'
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
