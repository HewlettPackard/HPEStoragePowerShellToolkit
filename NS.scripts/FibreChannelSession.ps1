# FibreChannelSession.ps1:  This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSFibreChannelSession {
<#
.SYNOPSIS
  Retrieve information on a set of Fibre Channel sessions or a single Fibre Channel session.
.DESCRIPTION
  Retrieve information on a set of Fibre Channel sessions or a single Fibre Channel session.
.PARAMETER id
  Unique identifier of the Fibre Channel session. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param( [ValidatePattern('([0-9a-f]{42})')]  [string] $id
  )
process
  { $API = 'fibre_channel_sessions'
    $Param = @{
      ObjectName = 'FibreChannelSession'
      APIPath = 'fibre_channel_sessions'
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
