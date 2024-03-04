####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9CapacityInfo
{
<#
.SYNOPSIS
	Overall system capacity.
.DESCRIPTION
	Overall system capacity.
.EXAMPLE
  PS:> Get-A9CapacityInfo
  
  totalMiB                      : 36608000
  allocated                     : @{totalAllocatedMiB=22524928; volumes=; system=}
  freeMiB                       : 14083072
  freeInitializedMiB            : 14083072
  freeUninitializedMiB          : 0
  unavailableCapacityMiB        : 0
  failedCapacityMiB             : 0
  overProvisionedVirtualSizeMiB : 87029350
  overProvisionedUsedMiB        : 9055263
  overProvisionedAllocatedMiB   : 4787680
  overProvisionedFreeMiB        : 14083072
#>
[CmdletBinding()]
Param()
Begin
{ Test-WSAPIConnection 
}
Process
{ $Result = Invoke-WSAPI -uri '/capacity' -type 'GET' 
  if($Result.StatusCode -eq 200)
    { $dataPS = ($Result.content | ConvertFrom-Json)
    }
  else
    { return $Result.StatusDescription
    }
  return $dataPS.allCapacity
}
}
