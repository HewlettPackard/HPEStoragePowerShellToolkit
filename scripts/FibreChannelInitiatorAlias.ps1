# FibreChannelInitiatorAlias.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.


function Get-NSFibreChannelInitiatorAlias {
<#
.SYNOPSIS
    Retrieve information on a set of Fibre Channel initiator aliases or a single Fibre Channel initiator alias.
.DESCRIPTION
  Retrieve information on a set of Fibre Channel initiator aliases or a single Fibre Channel initiator alias.
.PARAMETER id
  Unique identifier for the Fibre Channel initiator alias. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER alias
  Alias of the Fibre Channel initiator. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER wwpn
  WWPN (World Wide Port Name) of the Fibre Channel initiator. 
  Eight bytes expressed in hex separated by colons. Example: 'af:32:f1:20:bc:ba:43:1a'.
.PARAMETER source
  Source of the Fibre Channel initiator alias. Possible values: 'invalid', 'user', 'fabric'.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')][ValidatePattern('([0-9a-f]{42})')]                   [string] $id,

    [Parameter(ParameterSetName='nonId')]                                                   [string]$alias,

    [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{2}:){7}[0-9a-f]{2})')] [string]$wwpn,

    [Parameter(ParameterSetName='nonId')][ValidateSet( 'fabric', 'invalid', 'user')]        [string]$source
  )
process{
    $API = 'fibre_channel_initiator_aliases'
    $Param = @{
      ObjectName = 'FibreChannelInitiatorAlias'
      APIPath = 'fibre_channel_initiator_aliases'
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

