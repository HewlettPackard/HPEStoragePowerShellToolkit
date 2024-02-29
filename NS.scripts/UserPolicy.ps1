# UserPolicy.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.


function Get-NSUserPolicy {
<#array
.SYNOPSIS
  Read the password policies configured.
.DESCRIPTION
  Read the password policies configured.
.PARAMETER id
  Identifier for the security policy.
.PARAMETER allowed_attempts
  Number of authentication attempts allowed before the user account is locked. Allowed range is [1, 10] inclusive. '0' indicates no limit.
.PARAMETER min_length
  Minimum length for user passwords. Allowed range is [8, 255] inclusive.
.PARAMETER upper
  Number of uppercase characters required in user passwords. Allowed range is [0, 255] inclusive.
.PARAMETER lower
  Number of lowercase characters required in user passwords. Allowed range is [0, 255] inclusive.
.PARAMETER digit
  Number of numerical characters required in user passwords. Allowed range is [0, 255] inclusive.
.PARAMETER special
  Number of special characters required in user passwords. Allowed range is [0, 255] inclusive.
.PARAMETER previous_diff
  Number of characters that must be different from the previous password. Allowed range is [1, 255] inclusive.
.PARAMETER no_reuse
  Number of times that a password must change before you can reuse a previous password. Allowed range is [1,20] inclusive.
.PARAMETER max_sessions
  Maximum number of sessions allowed for a group. Allowed range is [10, 1000] inclusive. '0' indicates no limit.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(0,10)]                 [long]    $allowed_attempts,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(0,255)]                [long]    $min_length,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(0,255)]                [long]    $upper,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(0,255)]                [long]    $lower,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(0,255)]                [long]    $digit,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(0,255)]                [long]    $special,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(1,255)]                [long]    $previous_diff,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(1,20)]                 [long]    $no_reuse,
    [Parameter(ParameterSetName='nonId')] [ValidateRange(0,1000)]               [long]    $max_sessions
  )
process{
    $API = 'user_policies'
    $Param = @{
      ObjectName = 'UserPolicy'
      APIPath = 'user_policies'
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

function Set-NSUserPolicy {
<#
.SYNOPSIS
  Updates the Password policies configuration.
.DESCRIPTION
  Updates the Password policies configuration.
.PARAMETER id
  Identifier for the security policy.
.PARAMETER allowed_attempts
  Number of authentication attempts allowed before the user account is locked. Allowed range is [1, 10] inclusive. '0' indicates no limit.
.PARAMETER min_length
  Minimum length for user passwords. Allowed range is [8, 255] inclusive.
.PARAMETER upper
  Number of uppercase characters required in user passwords. Allowed range is [0, 255] inclusive.
.PARAMETER lower
    Number of lowercase characters required in user passwords. Allowed range is [0, 255] inclusive.
.PARAMETER digit
  Number of numerical characters required in user passwords. Allowed range is [0, 255] inclusive.
.PARAMETER special
  Number of special characters required in user passwords. Allowed range is [0, 255] inclusive.
.PARAMETER previous_diff
  Number of characters that must be different from the previous password. Allowed range is [1, 255] inclusive.
.PARAMETER no_reuse
  Number of times that a password must change before you can reuse a previous password. Allowed range is [1,20] inclusive.
.PARAMETER max_sessions
  Maximum number of sessions allowed for a group. Allowed range is [10, 1000] inclusive. '0' indicates no limit.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [ValidateRange(0,10)]                 [long]    $allowed_attempts,
    [ValidateRange(0,255)]                [long]    $min_length,
    [ValidateRange(0,255)]                [long]    $upper,
    [ValidateRange(0,255)]                [long]    $lower,
    [ValidateRange(0,255)]                [long]    $digit,
    [ValidateRange(0,255)]                [long]    $special,
    [ValidateRange(1,255)]                [long]    $previous_diff,
    [ValidateRange(1,20)]                 [long]    $no_reuse,
    [ValidateRange(0,1000)]               [long]    $max_sessions
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
            ObjectName = 'UserPolicy'
            APIPath = 'user_policies'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}
