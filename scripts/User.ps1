# User.ps1:  This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSUser {
<#
.SYNOPSIS
  Create a user.
.DESCRIPTION
  Create a user.
.PARAMETER name
  Name of the user.
.PARAMETER description
  Description of the user.
.PARAMETER role
  Role of the user.
.PARAMETER password 
  User's login password.
.PARAMETER inactivity_timeout
  The amount of time that the user session is inactive before timing out. A value of 0 indicates that the timeout is taken from the group setting.
.PARAMETER full_name
  Fully qualified name of the user.
.PARAMETER email_addr
  Email address of the user.
.PARAMETER disabled
  User is currently disabled.
.EXAMPLE
  C:\> New-NSUser -name testuser1 -password "testpassword"

  name               id                                            role               full_name            logged_in  disabled   description
  ----               --                                            ----               ---------            ---------  --------   -----------
  testuser1          1028eada7f8dd99d3b000000000000000000000029    guest                                   False      False

  This command will create a new volume using the minimal number of parameters.
.EXAMPLE
  C:\> New-NSUser -name testuser1 -password "testpassword" -description "My Test User" -role administrator

  name               id                                            role               full_name            logged_in  disabled   description
  ----               --                                            ----               ---------            ---------  --------   -----------
  testuser1          1028eada7f8dd99d3b00000000000000000000002a    administrator                           False      False      My Test User

  This command will create a new volume using thea common number of parameters.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string]  $name,
    [string]  $description,

    [ValidateSet( 'administrator', 'guest', 'operator', 'poweruser')]
    [string]  $role,

    [Parameter(Mandatory = $True)]
    [string]  $password,
    [long]    $inactivity_timeout,
    [string]  $full_name,
    [string]  $email_addr,
    [bool]    $disabled
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
            ObjectName = 'User'
            APIPath = 'users'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSUser {
<#
.SYNOPSIS
  List one or more users.
.DESCRIPTION
  List one or more users.
.PARAMETER id
  Identifier for the user.
.PARAMETER name 
  Name of the user.
.PARAMETER search_name
  Name of the user used for object search.
.PARAMETER description
  Description of the user.
.PARAMETER role_id
  Identifier for the user's role.
.PARAMETER role
  Role of the user.
.PARAMETER inactivity_timeout
  The amount of time that the user session is inactive before timing out. A value of 0 indicates that the timeout is taken from the group setting.
.PARAMETER full_name
  Fully qualified name of the user.
.PARAMETER email_addr
  Email address of the user.
.PARAMETER disabled
  User is currently disabled.
.EXAMPLE
  C:\> Get-NSUSer

  name               id                                            role               full_name            logged_in  disabled   description
  ----               --                                            ----               ---------            ---------  --------   -----------
  admin2             1028eada7f8dd99d3b000000000000000000000008    administrator      roy thomas           False      False
  admin              1028eada7f8dd99d3b000000000000000000000001    administrator      Administrator        True       False      Administrator

  This command will retrieve the list of users.
.EXAMPLE
  C:\> Get-NSUser -name admin

  name               id                                            role               full_name            logged_in  disabled   description
  ----               --                                            ----               ---------            ---------  --------   -----------
  admin              1028eada7f8dd99d3b000000000000000000000001    administrator      Administrator        True       False      Administrator

  This command will retrieve the user specified by name.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]  [ValidatePattern('([0-9a-f]{42})')]   [string] $id,
    [Parameter(ParameterSetName='nonId')]                                     [string]$name,
    [Parameter(ParameterSetName='nonId')]                                     [string]$search_name,
    [Parameter(ParameterSetName='nonId')]                                     [string]$description,
    [Parameter(ParameterSetName='nonId')] [ValidatePattern('([0-9a-f]{42})')] [string]$role_id,
    [Parameter(ParameterSetName='nonId')] [ValidateSet( 'administrator', 'guest', 'operator', 'poweruser')]
                                                                              [string]$role,
    [Parameter(ParameterSetName='nonId')]                                     [long]  $inactivity_timeout,
    [Parameter(ParameterSetName='nonId')]                                     [string]$full_name,
    [Parameter(ParameterSetName='nonId')]                                     [string]$email_addr,
    [Parameter(ParameterSetName='nonId')]                                     [bool]  $disabled,
    [Parameter(ParameterSetName='nonId')]                                     [bool]  $logged_in
  )
process{
    $API = 'users'
    $Param = @{
      ObjectName = 'User'
      APIPath = 'users'
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

function Set-NSUser {
<#
.SYNOPSIS
  Modify information about a user.
.DESCRIPTION
  Modify information about a user.
.PARAMETER id
  Identifier for the user.
.PARAMETER name
  Name of the user.
.PARAMETER description
  Description of the user.
.PARAMETER role
  Role of the user.
.PARAMETER password
  User's login password.
.PARAMETER auth_password
  Authorization password for changing password.
.PARAMETER inactivity_timeout
  The amount of time that the user session is inactive before timing out. A value of 0 indicates that the timeout is taken from the group setting.
.PARAMETER full_name
  Fully qualified name of the user.
.PARAMETER email_addr
  Email address of the user.
.PARAMETER disabled
  User is currently disabled.
.EXAMPLE
  C:\> Set-NSuser -id  1028eada7f8dd99d3b00000000000000000000002a -description "A New Description"

  name               id                                            role               full_name            logged_in  disabled   description
  ----               --                                            ----               ---------            ---------  --------   -----------
  testuser1          1028eada7f8dd99d3b00000000000000000000002a    administrator                           False      False      A New Description

  This command will set the description for the user specified by id.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='all')]
                                          [string]  $id,
    [Parameter(ParameterSetName='all')]   [string]  $name,
    [Parameter(ParameterSetName='all')]   [string]  $description,
    [Parameter(ParameterSetName='all')]                       [ValidateSet( 'administrator', 'guest', 'operator', 'poweruser')]
                                          [string]  $role,
    [Parameter(ParameterSetName='all')]   [string]  $password,
    [Parameter(ParameterSetName='all')]   [string]  $auth_password,
    [Parameter(ParameterSetName='all')]   [int]     $inactivity_timeout,
    [Parameter(ParameterSetName='all')]   [string]  $full_name,
    [Parameter(ParameterSetName='all')]   [string]  $email_addr,
    [Parameter(ParameterSetName='all')]   [string]  $tenant_id,
    [Parameter(ParameterSetName='all')]   [bool]    $disabled
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
            ObjectName = 'User'
            APIPath = 'users'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSUser {
<#
.SYNOPSIS
  Delete a user.
.DESCRIPTION
  Delete a user.
.PARAMETER id
  Identifier for the user.
.EXAMPLE
  C:\> Remove-NSuser -id  1028eada7f8dd99d3b00000000000000000000002a

  This command will remove the user specified by id.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process {
    $Params = @{
        ObjectName = 'User'
        APIPath = 'users'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}

function Unlock-NSUser {
<#
.SYNOPSIS
    Unlocks user account locked due to failed logins.
.DESCRIPTION
    Unlocks user account locked due to failed logins.
.PARAMETER id
  ID for the user.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process{
    $Params = @{
        APIPath = 'users'
        Action = 'unlock'
        ReturnType = 'NsUserLockStatus'
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
