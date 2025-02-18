# UserGroup.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSUserGroup {
<#
.SYNOPSIS
  Associate the ActiveDirectory group to a role on the storage array.
.DESCRIPTION
  Associate the ActiveDirectory group to a role on the storage array.
.PARAMETER name
  Name of the user group.
.PARAMETER description
  Description of the user group.
.PARAMETER role
  Role of the user.
.PARAMETER inactivity_timeout
  The amount of time that the user session is inactive before timing out. A value of 0 indicates that the timeout is taken from the group setting.
.PARAMETER disabled
  User is currently disabled.
.PARAMETER domain_id
  Identifier of the domain this user group belongs to.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string] $name,

    [string] $description,

    [ValidateSet( 'administrator', 'guest', 'operator', 'poweruser')]
    [string] $role,

    [long] $inactivity_timeout,

    [bool] $disabled,

    [Parameter(Mandatory = $True)]
    [string] $domain_id
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
            ObjectName = 'UserGroup'
            APIPath = 'user_groups'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSUserGroup {
<#
.SYNOPSIS
  List one or more user groups.
.DESCRIPTION
  List one or more user groups.
.PARAMETER id
  Identifier for the user group.
.PARAMETER name
  Name of the user group.
.PARAMETER description 
  Description of the user group.
.PARAMETER role_id 
  Identifier for the user group's role.
.PARAMETER role
  Role of the user.
.PARAMETER inactivity_timeout 
  The amount of time that the user session is inactive before timing out. A value of 0 indicates that the timeout is taken from the group setting.
.PARAMETER disabled
  User is currently disabled.
.PARAMETER external_id 
  External ID of the user group. In Active Directory, it is the group's SID (Security Identifier).
.PARAMETER domain_id
  Identifier of the domain this user group belongs to.
.PARAMETER domain_name
  Role of the user.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]                            [ValidatePattern('([0-9a-f]{42})')]
                                              [string]  $id,
    [Parameter(ParameterSetName='nonId')]     [string]  $name,
    [Parameter(ParameterSetName='nonId')]     [string]  $description,
    [Parameter(ParameterSetName='nonId')]     [string]  $role_id,
    [Parameter(ParameterSetName='nonId')]                         [ValidateSet( 'administrator', 'guest', 'operator', 'poweruser')]
                                              [string]  $role,
    [Parameter(ParameterSetName='nonId')]     [long]    $inactivity_timeout,
    [Parameter(ParameterSetName='nonId')]     [bool]    $disabled,
    [Parameter(ParameterSetName='nonId')]     [string]  $external_id,
    [Parameter(ParameterSetName='nonId')]     [string]  $domain_id,
    [Parameter(ParameterSetName='nonId')]     [string]  $domain_name
  )
process{
    $API = 'user_groups'
    $Param = @{
      ObjectName = 'UserGroup'
      APIPath = 'user_groups'
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

function Set-NSUserGroup {
<#
.SYNOPSIS
  Modify information about a user group.
.DESCRIPTION
  Modify information about a user group.
.PARAMETER id
  Identifier for the user group.
.PARAMETER description
  Description of the user group.
.PARAMETER role
  Role of the user.
.PARAMETER inactivity_timeout
  The amount of time that the user session is inactive before timing out. A value of 0 indicates that the timeout is taken from the group setting.
.PARAMETER disabled
  User is currently disabled.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [string] $description,

    [ValidateSet( 'administrator', 'guest', 'operator', 'poweruser')]
    [string] $role,

    [long] $inactivity_timeout,

    [bool] $disabled
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
            ObjectName = 'UserGroup'
            APIPath = 'user_groups'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSUserGroup {
<#
.SYNOPSIS
  Delete a user group.
.DESCRIPTION
  Delete a user group.
.PARAMETER id
  Identifier for the user group.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id
  )
process {
    $Params = @{
        ObjectName = 'UserGroup'
        APIPath = 'user_groups'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}
