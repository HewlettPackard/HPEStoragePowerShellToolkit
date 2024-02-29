# TrustedOauthIssuer.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSTrustedOauthIssuer {
<#
.SYNOPSIS
    Creates a trusted issuer with its public key.
.DESCRIPTION
    Creates a trusted issuer with its public key.
.PARAMETER name
    Issuer ID string.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string] $name
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
            ObjectName = 'TrustedOauthIssuer'
            APIPath = 'trusted_oauth_issuers'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
}
}

function Get-NSTrustedOauthIssuer {
<#
.SYNOPSIS
    List the set of trusted oauth issuers or a details about a particular trusted oauth issuer.
.DESCRIPTION
    List the set of trusted oauth issuers or a details about a particular trusted oauth issuer.
.PARAMETER id [<string>]
        Identifier for the trusted oauth issuer record.
.PARAMETER name [<string>]
        Issuer ID string.
.PARAMETER jwks_url [<string>]
        The URL from which the device will download the public key set for signature verification.
.PARAMETER key_set [<Object[]>]
        List of public keys for verifying signatures.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{2})([0-9a-f]{16})([0-9a-f]{16})([0-9a-f]{8})')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$name,

    [Parameter(ParameterSetName='nonId')]
    [string]$jwks_url,

    [Parameter(ParameterSetName='nonId')]
    [Object[]]$key_set

)
process{
    $API = 'trusted_oauth_issuers'
    $Param = @{
        ObjectName = 'TrustedOauthIssuer'
        APIPath = 'trusted_oauth_issuers'
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
