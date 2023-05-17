# Initiator.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSInitiator {
<#
.SYNOPSIS
  Create an initiator used for authentication.
.DESCRIPTION
  reate an initiator used for authentication.
.PARAMETER id
  Identifier for initiator. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER access_protocol
  Access protocol used by the initiator. Valid values are 'iscsi' and 'fc'.
.PARAMETER initiator_group_id
  Identifier of the initiator group that this initiator is assigned to.
.PARAMETER initiator_group_name
  Name of the initiator group that this initiator is assigned to.
.PARAMETER label
  Unique Identifier of the iSCSI initiator. Label is required when creating iSCSI initiator.
.PARAMETER iqn
  IQN name of the iSCSI initiator. Each initiator IQN name must have an associated IP address specified 
  using the 'ip_address' attribute. You can choose not to enter the IP address for an initiator if you
  prefer not to authenticate using both name and IP address, in this case the IP address will be returned as '*'.
.PARAMETER ip_address
  IP address of the iSCSI initiator. Each initiator IP address must have an associated name specified 
  using 'name' attribute. You can choose not to enter the name for an initiator if you prefer not to
  authenticate using both name and IP address, in this case the IQN name will be returned as '*'.
.PARAMETER alias
  Alias of the Fibre Channel initiator. Maximum alias length is 32 characters. Each initiator alias must have an 
  associated WWPN specified using the 'wwpn' attribute. You can choose not to enter the WWPN for
  an initiator when using previously saved initiator alias.
.PARAMETER chapuser_id
  Identifier for the CHAP user.
.PARAMETER wwpn
  WWPN (World Wide Port Name) of the Fibre Channel initiator. WWPN is required when creating a Fibre Channel initiator. 
  Each initiator WWPN can have an associated alias specified using the 'alias' attribute.
  You can choose not to enter the alias for an initiator if you prefer not to assign an initiator alias.
.PARAMETER vp_override
  Flag to allow modifying VP created initiator groups. When set to true, user can add this initiator to a VP created initiator group.
.PARAMETER creation_time
  Time when this initiator group was created.
.PARAMETER last_modified
  Time when this initiator group was last modified.
.PARAMETER override_existing_alias
  Forcibly add Fibre Channel initiator to initiator group by updating or removing conflicting Fibre Channel initiator aliases.
.EXAMPLE
  C:\> New-NSInitiator -label TestInitiator-134 -initiator_group_id 0228eada7f8dd99d3b000000000000000000000057 -access_protocol iscsi -iqn "iqn.2007-11.com.storage:TEST3"

  Label             IQN                           WWPN
  -----             ---                           ----
  TestInitiator-134 iqn.2007-11.com.storage:TEST3

  This command create a new initiator group.
#>
[CmdletBinding()]
param(
    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [ValidateSet( 'iscsi', 'fc')]
    [string] $access_protocol,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [string] $initiator_group_id,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [string] $label,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [string] $iqn,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [string] $ip_address,

    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [string] $alias,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [string] $chapuser_id,

    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [string] $wwpn,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [Nullable[bool]] $vp_override,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [bool]  $override_existing_alias
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
            ObjectName = 'Initiator'
            APIPath = 'initiators'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSInitiator {
<#
.SYNOPSIS
  List a set of initiators used for authentication.
.DESCRIPTION
  List a set of initiators used for authentication.
.PARAMETER id
  Identifier for initiator. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER access_protocol
  Access protocol used by the initiator. Valid values are 'iscsi' and 'fc'.
.PARAMETER initiator_group_id
  Identifier of the initiator group that this initiator is assigned to.
.PARAMETER initiator_group_name
  Name of the initiator group that this initiator is assigned to.
.PARAMETER label
  Unique Identifier of the iSCSI initiator. Label is required when creating iSCSI initiator.
.PARAMETER iqn
  IQN name of the iSCSI initiator. Each initiator IQN name must have an associated IP address specified using the 'ip_address' 
  attribute. You can choose not to enter the IP address for an initiator if you prefer not to authenticate using both name and 
  IP address, in this case the IP address will be returned as '*'.
.PARAMETER ip_address
  IP address of the iSCSI initiator. Each initiator IP address must have an associated name specified using 'name' attribute. 
  You can choose not to enter the name for an initiator if you prefer not to authenticate using both name and IP address, 
  in this case the IQN name will be returned as '*'.
.PARAMETER alias
  Alias of the Fibre Channel initiator. Maximum alias length is 32 characters. Each initiator alias must have an associated 
  WWPN specified using the 'wwpn' attribute. You can choose not to enter the WWPN for an initiator when using previously 
  saved initiator alias.
.PARAMETER wwpn
  WWPN (World Wide Port Name) of the Fibre Channel initiator. WWPN is required when creating a Fibre Channel initiator. 
  Each initiator WWPN can have an associated alias specified using the 'alias' attribute.
  You can choose not to enter the alias for an initiator if you prefer not to assign an initiator alias.
.EXAMPLE
  PS:> Get-NSInitiator

  Label                          IQN                                                     WWPN
  -----                          ---                                                     ----
  Crypt                          iqn.1991-05.com.microsoft:crypt
  NSSQL-Autocreated              iqn.1991-05.com.microsoft:nssql.lionetti.lab
  NSSCVMM-Autocreated            iqn.1991-05.com.microsoft:nsscvmm.lionetti.lab
  NSSCOM-Autocreated             iqn.1991-05.com.microsoft:nsscom.lionetti.lab
  NSSCORCH-Autocreated           iqn.1991-05.com.microsoft:nsscorch.lionetti.lab
  NSSCDPM-Autocreated            iqn.1991-05.com.microsoft:nsscdpm.lionetti.lab
  DaxIQN                         iqn.1991-05.com.microsoft:dax.lionetti.lab
  DFSR1IQN                       iqn.1991-05.com.microsoft:dfsr1.lionetti.lab
  TardisIQN                      iqn.1991-05.com.microsoft:tardis.lionetti.lab
  Hera-iqn                       iqn.1991-05.com.microsoft:hera.lionetti.lab
.EXAMPLE
  PS:> Get-NSInitiator -label 'Crypt'

  Label                          IQN                                                     WWPN
  -----                          ---                                                     ----
  Crypt                          iqn.1991-05.com.microsoft:crypt
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]   [string]    $id,
    [Parameter(ParameterSetName='iscsi')]
    [Parameter(ParameterSetName='fc')]
    [ValidateSet( 'iscsi', 'fc')]         [string]    $access_protocol,
    [Parameter(ParameterSetName='iscsi')]
    [Parameter(ParameterSetName='fc')]
    [ValidatePattern('([0-9a-f]{42})')]   [string]    $initiator_group_id,
    [Parameter(ParameterSetName='iscsi')]
    [Parameter(ParameterSetName='fc')]    [string]    $initiator_group_name,
    [Parameter(ParameterSetName='iscsi')] [string]    $label,
    [Parameter(ParameterSetName='iscsi')] [string]    $iqn,
    [Parameter(ParameterSetName='iscsi')] [string]    $ip_address,
    [Parameter(ParameterSetName='fc')]    [string]    $alias,
    [Parameter(ParameterSetName='fc')]    [string]    $wwpn
  )
process{
    $API = 'initiators'
    $Param = @{
      ObjectName = 'Initiator'
      APIPath = 'initiators'
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
                { $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Remove-NSInitiator {
<#
.SYNOPSIS
  Delete the specified initiator.
.DESCRIPTION
  Delete the specified initiator.
.PARAMETER id
  Identifier for initiator. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
[ValidatePattern('([0-9a-f]{42})')] [string]$id
    )
process { 
      $Params = @{  ObjectName = 'Initiator'
                    APIPath = 'initiators'
                    Id = $id
                }
      Remove-NimbleStorageAPIObject @Params
}
}
