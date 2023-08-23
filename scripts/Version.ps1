# Version.ps1: This is an autogenerated file. Part of Nimble Group Management SDK. All edits to this file will be lost!
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.


function Get-NSVersion 
{
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='nonId')]    [string]$name,
    [Parameter(ParameterSetName='nonId')]    [string]$software_version
  )
process
{
    $API = 'versions'
    $Param = @{
      ObjectName = 'Version'
      APIPath = 'versions'
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

