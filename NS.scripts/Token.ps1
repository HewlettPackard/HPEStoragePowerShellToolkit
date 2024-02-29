# Token.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSToken {
<#
.SYNOPSIS
  List user session tokens.
.DESCRIPTION
  List user session tokens.
.PARAMETER username
  User name for the session.
.PARAMETER password
  Password for the user. A password is required for creating a token.
.PARAMETER app_name
  Application name.
.PARAMETER source_ip
  IP address from which the session originates.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string] $username,
    [string] $password,
    [string] $app_name,
    [string] $source_ip
  )
process{
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
            ObjectName = 'Token'
            APIPath = 'tokens'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSToken {
<#
.SYNOPSIS
  List user session tokens.
.DESCRIPTION
  List user session tokens.
.PARAMETER id
  Object identifier for the session token.
.PARAMETER session_token
  Token used for authentication.
.PARAMETER username
  User name for the session.
.PARAMETER app_name
  Application name.
.PARAMETER source_ip
  IP address from which the session originates.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id', Mandatory=$True)]
    [ValidatePattern('([0-9a-f]{42})')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$session_token,

    [Parameter(ParameterSetName='nonId')]
    [string]$username,

    [Parameter(ParameterSetName='nonId')]
    [string]$app_name,

    [Parameter(ParameterSetName='nonId')]
    [string]$source_ip
  )
process
  {
    $API = 'tokens'
    $Param = @{
      ObjectName = 'Token'
      APIPath = 'tokens'
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

function Remove-NSToken {
<#
.SYNOPSIS
  Remove a Token identified by the given ID
.DESCRIPTION
  Remove a Token identified by the given ID
.PARAMETER id
  Object identifier for the session token. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]
        [string]$id
  )
process{  $Params = @{  ObjectName = 'Token'
                        APIPath = 'tokens'
                        Id = $id
                    }
          Remove-NimbleStorageAPIObject @Params
  }
}

function Get-NSTokenUserDetails {
<#
.SYNOPSIS
  Reports the user details for this token.
.DESCRIPTION
  Reports the user details for this token.
.PARAMETER id
  ID for the session token.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]
    [string]$id
  )
process{
    $Params = @{
        APIPath = 'tokens'
        Action = 'report_user_details'
        ReturnType = 'NsTokenReportUserDetailsReturn'
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

