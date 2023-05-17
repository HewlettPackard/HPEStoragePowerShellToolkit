# LdapDomain.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSLdapDomain {
<#
.SYNOPSIS
  Given a unique domain name, create an LDAP domain for the group.
.DESCRIPTION
  Given a unique domain name, create an LDAP domain for the group.
.PARAMETER id
  Identifier for the LDAP Domain.
.PARAMETER domain_name
  Domain name.
.PARAMETER domain_description
  Description of the domain.
.PARAMETER domain_enabled
  Indicates whether the LDAP domain is currently active or not.
.PARAMETER server_uri_list
  A set of up to 3 LDAP URIs.
.PARAMETER bind_user
  Full Distinguished Name of LDAP admin user. If empty, attempt to bind anonymously.
.PARAMETER bind_password
  Password for the Full Distinguished Name of LDAP admin user.  This parameter is mandatory if the bind_user is given.
.PARAMETER base_dn
  The Distinguished Name of the base object from which to start all searches.
.PARAMETER user_search_filter
  Limit the results returned based on specific search criteria.
.PARAMETER user_search_base_list
  A set of upto 10 Relative Distinguished Names, relative to the Base DN, from which to search for User objects.
.PARAMETER group_search_filter
  Limit the results returned based on specific search criteria.
.PARAMETER group_search_base_list
  A set of upto 10 Relative Distinguished Names, relative to the Base DN, from which to search for Group objects.
.PARAMETER schema_type
  Enum values are OpenLDAP or AD.
#>
[CmdletBinding()]
param(  [Parameter(Mandatory = $True)]
        [string] $domain_name,

        [string] $domain_description,

        [Parameter(Mandatory = $True)]
        [Object[]] $server_uri_list,

        [string] $bind_user,

        [string] $bind_password,

        [string] $base_dn,

        [string] $user_search_filter,

        [Object[]] $user_search_base_list,

        [string] $group_search_filter,

        [Object[]] $group_search_base_list,

        [Parameter(Mandatory = $True)]
        [ValidateSet( 'OpenLDAP', 'AD')]
        [string] $schema_type
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
            ObjectName = 'LdapDomain'
            APIPath = 'ldap_domains'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSLdapDomain {
<#
.SYNOPSIS
  List the LDAP Information.
.DESCRIPTION
  List the LDAP Information.
.PARAMETER id
  Identifier for the LDAP Domain.
.PARAMETER domain_name
  Domain name.
.PARAMETER domain_description
  Description of the domain.
.PARAMETER domain_enabled
  Indicates whether the LDAP domain is currently active or not.
.PARAMETER server_uri_list
  A set of up to 3 LDAP URIs.
.PARAMETER bind_user
  Full Distinguished Name of LDAP admin user. If empty, attempt to bind anonymously.
.PARAMETER bind_password
  Password for the Full Distinguished Name of LDAP admin user.  This parameter is mandatory if the bind_user is given.
.PARAMETER base_dn
  The Distinguished Name of the base object from which to start all searches.
.PARAMETER user_search_filter
  Limit the results returned based on specific search criteria.
.PARAMETER user_search_base_list
  A set of upto 10 Relative Distinguished Names, relative to the Base DN, from which to search for User objects.
.PARAMETER group_search_filter
  Limit the results returned based on specific search criteria.
.PARAMETER group_search_base_list
  A set of upto 10 Relative Distinguished Names, relative to the Base DN, from which to search for Group objects.
.PARAMETER schema_type
  Enum values are OpenLDAP or AD.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{2})([0-9a-f]{16})([0-9a-f]{16})([0-9a-f]{8})')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$domain_name,

    [Parameter(ParameterSetName='nonId')]
    [string]$domain_description,

    [Parameter(ParameterSetName='nonId')]
    [bool]$domain_enabled,

    [Parameter(ParameterSetName='nonId')]
    [Object[]]$server_uri_list,

    [Parameter(ParameterSetName='nonId')]
    [string]$bind_user,

    [Parameter(ParameterSetName='nonId')]
    [string]$bind_password,

    [Parameter(ParameterSetName='nonId')]
    [string]$base_dn,

    [Parameter(ParameterSetName='nonId')]
    [string]$user_search_filter,

    [Parameter(ParameterSetName='nonId')]
    [Object[]]$user_search_base_list,

    [Parameter(ParameterSetName='nonId')]
    [string]$group_search_filter,

    [Parameter(ParameterSetName='nonId')]
    [Object[]]$group_search_base_list,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'OpenLDAP', 'AD')]
    [string]$schema_type
  )
process
  {
    $API = 'ldap_domains'
    $Param = @{
      ObjectName = 'LdapDomain'
      APIPath = 'ldap_domains'
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

function Set-NSLdapDomain {
<#
.SYNOPSIS
    Updates the LDAP configuration.
.DESCRIPTION
    Updates the LDAP configuration.
.PARAMETER 
.PARAMETER id <string>
  Identifier for the LDAP Domain.
.PARAMETER domain_name [<string>]
  Domain name.
.PARAMETER domain_description [<string>]
  Description of the domain.
.PARAMETER domain_enabled [<Nullable`1[Boolean]>]
  Indicates whether the LDAP domain is currently active or not.
.PARAMETER server_uri_list [<Object[]>]
  A set of up to 3 LDAP URIs.
.PARAMETER bind_user [<string>]
  Full Distinguished Name of LDAP admin user. If empty, attempt to bind anonymously.
.PARAMETER bind_password [<string>]
  Password for the Full Distinguished Name of LDAP admin user.  This parameter is mandatory if the bind_user is given.
.PARAMETER base_dn [<string>]
  The Distinguished Name of the base object from which to start all searches.
.PARAMETER user_search_filter [<string>]
  Limit the results returned based on specific search criteria.
.PARAMETER user_search_base_list [<Object[]>]
  A set of upto 10 Relative Distinguished Names, relative to the Base DN, from which to search for User objects.
.PARAMETER group_search_filter [<string>]
  Limit the results returned based on specific search criteria.
.PARAMETER group_search_base_list [<Object[]>]
  A set of upto 10 Relative Distinguished Names, relative to the Base DN, from which to search for Group objects.
.PARAMETER schema_type [<string>]
  Enum values are OpenLDAP or AD.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [string] $domain_description,

    [bool] $domain_enabled,

    [string] $bind_user,

    [string] $bind_password,

    [string] $base_dn,

    [string] $user_search_filter,

    [Object[]] $user_search_base_list,

    [string] $group_search_filter,

    [Object[]] $group_search_base_list
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
            ObjectName = 'LdapDomain'
            APIPath = 'ldap_domains'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSLdapDomain {
<#
.SYNOPSIS
    Delete the LDAP configuration.
.DESCRIPTION
    Delete the LDAP configuration.
PARAMETERS
    -id [<string>]
        Identifier for the LDAP Domain.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [string]$id
  )
process { $Params = @{  ObjectName = 'LdapDomain'
                        APIPath = 'ldap_domains'
                        Id = $id
                    }
          Remove-NimbleStorageAPIObject @Params
        }
}

function Test-NSLdapDomainUser {
<#
.SYNOPSIS
  Reports the LDAP connectivity status of the given LDAP ID and user ID.
.DESCRIPTION
  Reports the LDAP connectivity status of the given LDAP ID and user ID.
.PARAMETER id
  Unique identifier for the LDAP Domain.
.PARAMETER user
  Unique identifier for the LDAP User.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$user
  )
process{
    $Params = @{
        APIPath = 'ldap_domains'
        Action = 'test_user'
        ReturnType = 'NsLdapUser'
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
function Test-NSLdapDomainGroup {
<#
.SYNOPSIS
    Tests whether the user group exist in the given LDAP Domain.
.DESCRIPTION
    Tests whether the user group exist in the given LDAP Domain.
.PARAMETER id
  Unique identifier for the LDAP Domain.
.PARAMETER group
  Name of the group.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$group
  )
process{
    $Params = @{
        APIPath = 'ldap_domains'
        Action = 'test_group'
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
function Test-NSLdapDomain {
<#
.SYNOPSIS
  Reports the LDAP connectivity status of the given LDAP ID.
.DESCRIPTION
  Reports the LDAP connectivity status of the given LDAP ID.
.PARAMETER id
  Unique identifier for the LDAP Domain.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [string]$id
  )
process{  $Params = @{  APIPath = 'ldap_domains'
                        Action = 'report_status'
                        ReturnType = 'NsLdapReportStatusReturn'
                    }
          $Params.Arguments = @{}
          $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
          foreach ($key in $ParameterList.keys)
          {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
              if($var -and ($PSBoundParameters.ContainsKey($key)))
                {   $Params.Arguments.Add("$($var.name)", ($var.value))
                }
          }
          $ResponseObject = Invoke-NimbleStorageAPIAction @Params
          return $ResponseObject
  }
}
