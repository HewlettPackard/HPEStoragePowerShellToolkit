# Disk.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSDisk {
<#
.SYNOPSIS
  A Commnd to retrieve either a single disk specified by a disk ID, or the complete list of disks present in the system.
.DESCRIPTION
  A Commnd to retrieve either a single disk specified by a disk ID, or the complete list of disks present in the system.
.PARAMETER id
  ID of disk. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE
  C:\> Get-NSDisk

  model        id                                         serial   shelf_serial slot size
  -----        --                                         ------   ------------ ---- ----
  Virtual disk 2c28eada7f8dd99d3b0001000000000b0000000100 /dev/sdb chapi-afa-a1 1    21474836480
  Virtual disk 2c28eada7f8dd99d3b0001000000000b0000000200 /dev/sdc chapi-afa-a1 2    21474836480
  Virtual disk 2c28eada7f8dd99d3b0001000000000b0000000300 /dev/sdd chapi-afa-a1 3    21474836480
  Virtual disk 2c28eada7f8dd99d3b0001000000000b0000000400 /dev/sde chapi-afa-a1 4    21474836480
  Virtual disk 2c28eada7f8dd99d3b0001000000000b0000000500 /dev/sdf chapi-afa-a1 5    21474836480
#>
[CmdletBinding()]
param(  [ValidatePattern('([0-9a-f]{42})')] [string] $id
  )
process{
    $API = 'disks'
    $Param = @{   ObjectName = 'Disk'
                  APIPath = 'disks'
              }
    if ($id)
    {   # Get a single object for given Id.
        $Param.Id = $id
        $ResponseObject = Get-NimbleStorageAPIObject @Param
        return $ResponseObject
    }
    else
    {   # Get list of objects matching the given filter.
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Set-NSDisk {
<#
.SYNOPSIS
  Add or remove a disk.
.DESCRIPTION
  Add or remove a disk.
.PARAMETER id
  ID of disk. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER disk_op
  The intended operation to be performed on the specified disk. Disk operation. Possible values: 'add', 'remove'.
.PARAMETER force
  Forcibly add a disk. Possible values: 'true', 'false'.
.EXAMPLE
  C:\> Set-NSdisk -id 2c28eada7f8dd99d3b0001000000000b0000000200 -disk_op remove

  model        id                                         serial   shelf_serial slot size
  -----        --                                         ------   ------------ ---- ----
  Virtual disk 2c28eada7f8dd99d3b0001000000000b0000000200 /dev/sdc chapi-afa-a1 2    21474836480

  This command will prepair a disk for removal from the array.
.EXAMPLE
  C:\> Set-NSdisk -id 2c28eada7f8dd99d3b0001000000000b0000000200 -disk_op add

  model        id                                         serial   shelf_serial slot size
  -----        --                                         ------   ------------ ---- ----
  Virtual disk 2c28eada7f8dd99d3b0001000000000b0000000200 /dev/sdc chapi-afa-a1 2    21474836480

  This command will add a previously removed disk to the array.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')] [string]  $id,
        [Parameter(Mandatory = $True)]
        [ValidateSet( 'add', 'remove')]     [string]  $disk_op,
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
            ObjectName = 'Disk'
            APIPath = 'disks'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}
