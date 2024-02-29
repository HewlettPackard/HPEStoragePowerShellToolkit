# ApplicationCategory.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSApplicationCategory {
<#
.SYNOPSIS
  Lists application categories.
.DESCRIPTION
  Lists application categories.
.PARAMETER id
  Identifier for the application category. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
  Name of application category. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.EXAMPLE
  C:\> Get-NSApplicatinCategory

  name            id
  ----            --
  Exchange        390000000000000000000000000000000000000001
  Oracle          390000000000000000000000000000000000000002
  SQL Server      390000000000000000000000000000000000000003
  DB2             390000000000000000000000000000000000000004
  SharePoint      390000000000000000000000000000000000000005
  Virtual Server  390000000000000000000000000000000000000006
  Virtual Desktop 390000000000000000000000000000000000000007
  File Server     390000000000000000000000000000000000000008
  Other           390000000000000000000000000000000000000009
  Unassigned      39000000000000000000000000000000000000000a
  Backup          39000000000000000000000000000000000000000b

  This command will retrieves list of current Application Categories.
.EXAMPLE
  C:\> Get-NSApplicatinCategory -name Exchange

  name            id
  ----            --
  Exchange        390000000000000000000000000000000000000001

  This command will retrieve a specific Application Category specified by name.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id', Mandatory=$True)]   [ValidatePattern('([0-9a-f]{42})')]   [string] $id,
                                                          [Parameter(ParameterSetName='nonId')] [string]$name
  )
process{ 
    $API = 'application_categories'
    $Param = @{   ObjectName = 'ApplicationCategory'
                  APIPath = 'application_categories'
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