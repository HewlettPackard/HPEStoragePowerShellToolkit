# SoftwareVersion.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSSoftwareVersion {
<#  
.SYNOPSIS
  Read software versions.
.DESCRIPTION
  Read software versions.
.EXAMPLE
  PS:> Get-NSSoftwareVersion

  name            version
  ----            -------
  available       6.0.0.500-1005…
  available       6.1.1.100-1013…
  installed       6.0.0.300-9562…
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
  )
process{
    $API = 'software_versions'
    $Param = @{ ObjectName = 'SoftwareVersion'
                APIPath = 'software_versions'
              }
    $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
    $CustomerReturnObj = $ResponseObjectList[0]
    $x11 = 0
    while ($x11 -lt $CustomerReturnObj.count)
      { $DataSetType = "NimbleStorage.SoftwareVersion"
        $CustomerReturnObj[$x11].PSTypeNames.Insert(0,$DataSetType)
        $DataSetType = $DataSetType + ".TypeName"
        $CustomerReturnObj[$x11].PSObject.TypeNames.Insert(0,$DataSetType)
        $x11 = $x11 + 1
      }

    return $CustomerReturnObj
  }
}



