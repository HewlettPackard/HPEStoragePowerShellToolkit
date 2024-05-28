# KeyManager.ps1: 
# Part of Nimble Group Management SDK. 
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSKeyManager 
{
<#
.SYNOPSIS
  Add External Key Manager for encryption keys.
.DESCRIPTION
  Add External Key Manager for encryption keys.
.PARAMETER id
  Identifier for External Key Manager.
.PARAMETER name 
  Name of external key manager.
.PARAMETER description
  Description of external key manager.
.PARAMETER hostname 
  Hostname or IP Address for the External Key Manager.
.PARAMETER port
  Port number for the External Key Manager.
.PARAMETER protocol 
  KMIP protocol supported by External Key Manager.
.PARAMETER username 
  External Key Manager username. String up to 255 printable characters.
.PARAMETER password 
  External Key Manager user password. String up to 255 printable characters.
.PARAMETER active 
  Whether the given key manager is active or not.
.PARAMETER status 
  Connection status of a given external key manager.
.PARAMETER vendor 
  KMIP vendor name.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]  [string] $name,
                                    [string] $description,
    [Parameter(Mandatory = $True)]  [string] $hostname,
    [Parameter(Mandatory = $True)]  [long] $port,
    [Parameter(Mandatory = $True)]
    [ValidateSet( 'KMIP1_1', 'KMIP1_2', 'KMIP1_0', 'KMIP1_3')]
                                    [string] $protocol,
                                    [string] $username,
                                    [string] $password
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
            ObjectName = 'KeyManager'
            APIPath = 'key_managers'
            Properties = $RequestData
        }
        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
  }
}

function Get-NSKeyManager 
{
<#
.SYNOPSIS 
  List External Key Manager Information.
.DESCRIPTION
  List External Key Manager Information.
.PARAMETER id 
  Identifier for External Key Manager.
.PARAMETER name
  Name of external key manager.
.PARAMETER description
  Description of external key manager.
.PARAMETER hostname
  Hostname or IP Address for the External Key Manager.
.PARAMETER port
  Port number for the External Key Manager.
.PARAMETER protocol
  KMIP protocol supported by External Key Manager.
.PARAMETER username
  External Key Manager username. String up to 255 printable characters.
.PARAMETER password
  External Key Manager user password. String up to 255 printable characters.
.PARAMETER active
  Whether the given key manager is active or not.
.PARAMETER status
  Connection status of a given external key manager.
.PARAMETER vendor
  KMIP vendor name.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]   [string] $id,
    [Parameter(ParameterSetName='nonId')] [string]$name,
    [Parameter(ParameterSetName='nonId')] [string]$description,
    [Parameter(ParameterSetName='nonId')] [string]$hostname,
    [Parameter(ParameterSetName='nonId')] [long]$port,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'KMIP1_1', 'KMIP1_2', 'KMIP1_0', 'KMIP1_3')]
                                          [string]$protocol,
    [Parameter(ParameterSetName='nonId')] [string]$username,
    [Parameter(ParameterSetName='nonId')] [string]$password,
    [Parameter(ParameterSetName='nonId')] [boolean]$active,
    [Parameter(ParameterSetName='nonId')] [string]$status,
    [Parameter(ParameterSetName='nonId')] [string]$vendor
  )
process
  {
    $API = 'key_managers'
    $Param = @{
      ObjectName = 'KeyManager'
      APIPath = 'key_managers'
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

function Set-NSKeyManager 
{
<#
.SYNOPSIS
  Updates External Key Manager configuration.
.DESCRIPTION
  Updates External Key Manager configuration.
.PARAMETER id
  Identifier for External Key Manager.
.PARAMETER name
  Name of external key manager.
.PARAMETER description
  Description of external key manager.
.PARAMETER hostname
  Hostname or IP Address for the External Key Manager.
.PARAMETER port
  Port number for the External Key Manager.
.PARAMETER protocol
  KMIP protocol supported by External Key Manager.
.PARAMETER username
  External Key Manager username. String up to 255 printable characters.
.PARAMETER password
  External Key Manager user password. String up to 255 printable characters.
.PARAMETER active
  Whether the given key manager is active or not.
.PARAMETER status
  Connection status of a given external key manager.
.PARAMETER vendor
  KMIP vendor name.
#>
[CmdletBinding()]
param(
      [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
      [string] $id,
      [string] $name,
      [string] $description,
      [string] $hostname,
      [long] $port,
      [ValidateSet( 'KMIP1_1', 'KMIP1_2', 'KMIP1_0', 'KMIP1_3')]
      [string] $protocol,
      [string] $username,
      [string] $password
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
            if ($key.ToLower() -ne 'id')
            {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {
                    $RequestData.Add("$($var.name)", ($var.value))
                }
            }
        }
        $Params = @{
            ObjectName = 'KeyManager'
            APIPath = 'key_managers'
            Id = $id
            Properties = $RequestData
        }
        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}


function Remove-NSKeyManager 
{
<# 
.SYNOPSIS 
  Remove external key manager.
.DESCRIPTION
  Remove external key manager. You must migrate the keys to an inactive external key manager before removing the active key manager. If you remove the active external key manager the passphrase is used to enable the internal key manager.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [string]$passphrase
  )
process{
    $Params = @{
        APIPath = 'key_managers'
        Action = 'remove'
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

function Move-NSKeyManager 
{
<#
.SYNOPSIS
  Migrate volume encryption keys from the active key manager to the destination id given in the input. 
.DESCRIPTION
  Migrate volume encryption keys from the active key manager to the destination id given in the input. After successfully migrating the encryption keys, the destination key manager is made the active key manager.
.PARAMETER id
  ID of the destination external key manager.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id
  )
process{
    $Params = @{
        APIPath = 'key_managers'
        Action = 'migrate_keys'
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

