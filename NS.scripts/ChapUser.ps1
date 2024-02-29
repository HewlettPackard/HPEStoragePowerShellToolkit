# ChapUser.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSChapUser {
<#
.SYNOPSIS
  Create a new CHAP user, which is then assigned to an access control record for a volume. 
  CHAP user authentication requires a CHAP secret that agrees as the challenge response.
.DESCRIPTION
  Create a new CHAP user, which is then assigned to an access control record for a volume. 
  CHAP user authentication requires a CHAP secret that agrees as the challenge response.
.PARAMETER name
  Name of CHAP user. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER description
  Text description of CHAP user. 
  String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER password
  CHAP secret.The CHAP secret should be between 12-16 characters and cannot contain spaces or most punctuation. 
  String of 12 to 16 printable ASCII characters excluding ampersand and ^[];`. Example: 'password_25-24'.
.EXAMPLE
  C:\> New-NSChapUser -name TestUser1 -description "My Chap User" -password 12to16charsValid

  creation_time : 1533274153
  description   : My Chap User
  full_name     :
  id            : 0128eada7f8dd99d3b000000000000000000000033
  last_modified : 1533274153
  name          : TestUser1
  search_name   : TestUser1
  vol_count     : 0
  vol_list      :

  This command will create a new Chap User using the supplied values.
#>
[CmdletBinding()]
param(  [Parameter(Mandatory = $True)]  [string] $name,
                                        [string] $description,
        [Parameter(Mandatory = $True)]  [string] $password
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
            if($var -and ($PSBoundParameters.ContainsKey($key)))
              {   $RequestData.Add("$($var.name)", ($var.value))
              }
        }
        $Params = @{  ObjectName = 'ChapUser'
                      APIPath = 'chap_users'
                      Properties = $RequestData
                  }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSChapUser {
<#
.SYNOPSIS
  List a set of CHAP users or a single CHAP user.
.DESCRIPTION
  List a set of CHAP users or a single CHAP user.
.PARAMETER id
  Identifier for the CHAP user. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
  Name of CHAP user. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER full_name
  CHAP user's fully qualified name. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER search_name
  CHAP user name used for object search. 
  Alphanumeric string, up to 64 characters including hyphen, period, colon. Example: 'vol:1'.
.PARAMETER description
  Text description of CHAP user. 
  String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.EXAMPLE
  C:\> Get-NSChapUser

  creation_time : 1532859878
  description   : My Chap User1
  full_name     :
  id            : 0128eada7f8dd99d3b00000000000000000000000b
  last_modified : 1532859878
  name          : TestUser2
  search_name   : TestUser2
  vol_count     : 0
  vol_list      :

  creation_time : 1533274153
  description   : My Chap User
  full_name     :
  id            : 0128eada7f8dd99d3b000000000000000000000033
  last_modified : 1533274153
  name          : TestUser1
  search_name   : TestUser1
  vol_count     : 0
  vol_list      :

  This command will list all Chap Users.
.EXAMPLE
  C:\> Get-NSChapUser -name TestUser1

  creation_time : 1533274153
  description   : My Chap User
  full_name     :
  id            : 0128eada7f8dd99d3b000000000000000000000033
  last_modified : 1533274153
  name          : TestUser1
  search_name   : TestUser1
  vol_count     : 0
  vol_list      :

  This command will retrieve only a specific Chap User using the supplied values.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [Parameter(ParameterSetName='nonId')] [string]  $name,
    [Parameter(ParameterSetName='nonId')] [string]  $full_name,
    [Parameter(ParameterSetName='nonId')] [string]  $search_name,
    [Parameter(ParameterSetName='nonId')] [string]  $description
  )
process{
    $API = 'chap_users'
    $Param = @{
      ObjectName = 'ChapUser'
      APIPath = 'chap_users'
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
                { $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Set-NSChapUser {
<#
.SYNOPSIS
  Modify attributes of specified CHAP user.
.DESCRIPTION
  Modify attributes of specified CHAP user.
.PARAMETER id
  Identifier for the CHAP user. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
  Name of CHAP user. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER description
  Text description of CHAP user. 
  String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER password
  CHAP secret.The CHAP secret should be between 12-16 characters and cannot contain spaces or most punctuation. 
  String of 12 to 16 printable ASCII characters excluding ampersand and ^[];`. Example: 'password_25-24'.
.EXAMPLE
  C:\> Set-NSChapUser -id 0128eada7f8dd99d3b000000000000000000000033 -description "My New Description"

  creation_time : 1533274153
  description   : My New Description
  full_name     :
  id            : 0128eada7f8dd99d3b000000000000000000000033
  last_modified : 1533274155
  name          : TestUser1
  search_name   : TestUser1
  vol_count     : 0
  vol_list      :

  This command will modify the description for a specific Chap Users.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string] $id,
                                          [string] $name,
                                          [string] $description,
                                          [string] $password
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        { if ($key.ToLower() -ne 'id')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                  {   $RequestData.Add("$($var.name)", ($var.value))
                  }
            }
        }
        $Params = @{  ObjectName = 'ChapUser'
                      APIPath = 'chap_users'
                      Id = $id
                      Properties = $RequestData
                  }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSChapUser {
<#
.DESCRIPTION
  Delete specified CHAP user.
.PARAMETER id
  Identifier for the CHAP user. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE 
  C:\> Remove-NSChapUser -id 0128eada7f8dd99d3b000000000000000000000033

  This command will Remove a specific Chap User.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]   [string]$id
    )
process {
    $Params = @{
        ObjectName = 'ChapUser'
        APIPath = 'chap_users'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}


