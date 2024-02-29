# Shelf.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.


function Get-NSShelf {
<#
.SYNOPSIS
  Retrieve information about a shelf or a list of shelves.
.DESCRIPTION
  Retrieve information about a shelf or a list of shelves.
.PARAMETER id
  ID of the specific shelf to gather information on.
.PARAMETER array_id
  ID of array controlling the shelf.
#>
[CmdletBinding()]
param(  [ValidatePattern('([0-9a-f]{42})')] [string]$id,
        [ValidatePattern('([0-9a-f]{42})')] [string]$array_id
  )
process{
    $API = 'shelves'
    $Param = @{
      ObjectName = 'Shelf'
      APIPath = 'shelves'
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

function Set-NSShelf {
<#
.SYNOPSIS
  Activate a shelf.
.DESCRIPTION
  Activate a shelf. Use 'accept_foreign=true' with 'activated=true' to force a foreign shelf to activate.  
  Use 'accept_dedupe_impact' with 'activated=true' to force activation of a shelf even if it reduces or
  eliminates the deduplication capabilities of the array.  The force option is being deprecated.
.PARAMETER id
  ID of shelf. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER activated
  Activated state for shelf or disk set means it is available to store date on. An activated shelf may not be deactivated. Possible values: 'true', 'false'.
.PARAMETER driveset
  Driveset to activate. Unsigned 32-bit integer. Example: 1234.
.PARAMETER force
  Forcibly activate shelf. Possible values: 'true', 'false'.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]
    [string]  $id,
    [Parameter(Mandatory = $True)]
    [bool]    $activated,
    [int]     $driveset,
    [bool]    $force
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
            ObjectName = 'Shelf'
            APIPath = 'shelves'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}
