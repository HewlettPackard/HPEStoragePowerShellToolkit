function Get-MSAVolume
{
<#
.SYNOPSIS
    Shows information about volumes.
.DESCRIPTION
    The command will show information for all volumes by default, or you can use parameters to filter the output.
.EXAMPLE
    PS:> Get-MSADisk
    
    durable-id storage-p volume-name  size     owner  serial-number                     volume-group         raidtype  health
               ool-name
    ---------- --------- -----------  ----     -----  -------------                     ------------         --------  ------
    V0         A         Vol1         99.9GB   A      00c0ff50437d0000d9c73e5f01000000  UNGROUPEDVOLUMES     RAID0     OK
    V1         A         Crush50      49.9GB   A      00c0ff50437d000052ab465f01000000  UNGROUPEDVOLUMES     RAID0     OK
    V2         A         MyVol1       32.9GB   A      00c0ff50437d00004e7e096001000000  UNGROUPEDVOLUMES     RAID0     OK
#>
    $result = Invoke-MSAStorageRestAPI -noun volumes -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
