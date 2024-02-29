# MasterKey.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSMasterKey {
<#
.SYNOPSIS
  Create master key.
.DESCRIPTION
    Create master key.
.PARAMETER id
  Identifier of the master key.
.PARAMETER name
  Name of the master key. The only allowed value is "default".
.PARAMETER passphrase
  Passphrase used to protect the master key, required during creation, enabling/disabling the key and change the passphrase to a new value.
.PARAMETER halfkey
  When changing the passphrase, this authenticates the change operation, for support use only.
.PARAMETER new_passphrase
  When changing the passphrase, this attribute specifies the new value of the passphrase.
.PARAMETER active
  Whether the master key is active or not.
.PARAMETER purge_age 
  Default minimum age (in hours) of inactive encryption keys to be purged. '0' indicates to purge keys immediately.
#>
[CmdletBinding()]
param(
    [string] $name,

    [Parameter(Mandatory = $True)]
    [string] $passphrase
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
            ObjectName = 'MasterKey'
            APIPath = 'master_key'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSMasterKey {
<#
.SYNOPSIS 
  Obtain information about the System Master Key
.Description
  Obtain information about the System Master Key
.PARAMETER id
  Identifier of the master key. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
  Name of the master key. The only allowed value is "default". Plain string.
.PARAMETER active
  Whether the master key is active or not. Possible values: 'true', 'false'.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$name,

    [Parameter(ParameterSetName='nonId')]
    [bool]$active
  )
process
  {
    $API = 'master_key'
    $Param = @{
      ObjectName = 'MasterKey'
      APIPath = 'master_key'
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

function Set-NSMasterKey {
<#
.SYNOPSIS
    Enable/disable the master key or change the passphrase to a new value, 'passphrase' attribute is always required. Updating 'active' attribute to enable or disable the master key. Updating 'new_passphrase'
    attribute to change the passphrase to a new value. Changing the activeness and the passphrase of the key are not allowed in the same update.
.DESCRIPTION
    Enable/disable the master key or change the passphrase to a new value, 'passphrase' attribute is always required. Updating 'active' attribute to enable or disable the master key. Updating 'new_passphrase'
    attribute to change the passphrase to a new value. Changing the activeness and the passphrase of the key are not allowed in the same update.
.PARAMETER id
  Identifier of the master key.
.PARAMETER name [<string>]
  Name of the master key. The only allowed value is "default".
.PARAMETER passphrase <string>
  Passphrase used to protect the master key, required during creation, enabling/disabling the key and change the passphrase to a new value.
.PARAMETER halfkey [<string>]
  When changing the passphrase, this authenticates the change operation, for support use only.
.PARAMETER new_passphrase [<string>]
  When changing the passphrase, this attribute specifies the new value of the passphrase.
.PARAMETER active [<Nullable`1[Boolean]>]
  Whether the master key is active or not.
.PARAMETER purge_age [<Nullable`1[Int64]>]
    Default minimum age (in hours) of inactive encryption keys to be purged. '0' indicates to purge keys immediately.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [string] $name,

    [Parameter(Mandatory = $True)]
    [string] $passphrase,

    [string] $halfkey,

    [string] $new_passphrase,

    [bool] $active
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
            ObjectName = 'MasterKey'
            APIPath = 'master_key'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSMasterKey {
<#
.SYNOPSIS
  Delete master key.
.DESCRIPTION
  Delete master key.
.PARAMETER id
  Identifier of the master key.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id
  )
process {
    $Params = @{
        ObjectName = 'MasterKey'
        APIPath = 'master_key'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}

function Clear-NSMasterKeyInactive {
<#
.SYNOPSIS
    Purges encryption keys that have been inactive for the age or longer. If you do not specify an age, the keys will be purged immediately.
.DESCRIPTION
    Purges encryption keys that have been inactive for the age or longer. If you do not specify an age, the keys will be purged immediately.
.PARAMETER id
  Identifier for the master key.
.PARAMETER age
  Minimum age (in hours) of inactive encryption keys to be purged. '0' indicates to purge the keys immediately.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [long]$age
  )
process{
    $Params = @{
        APIPath = 'master_key'
        Action = 'purge_inactive'
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

