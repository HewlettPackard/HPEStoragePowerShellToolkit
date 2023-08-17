function Get-NSHostVolume
{ 
[cmdletbinding()]  
param ()
begin 
{   $ReturnObjColl = @()
}
Process
{   # Process Cluster Physical Disks.
    $MyClusterDisks = Get-ClusterResource | where-object { $_.ResourceType -eq 'Physical Disk'}
    foreach ( $ClusDisk in $MyClusterDisks )
    {   $RegLocation = "HKLM:\Cluster\Resources\"+($ClusDisk.Id)+"\Parameters"
        write-verbose "Location to look for details = $RegLocation"
        $DiskGuid = get-ItemPropertyValue -Path $RegLocation -name DiskGuid
        # Need to trim the starting { and ending } from the string
        $DiskGuid = ($DiskGuid.trimstart('{')).trimend('}')
        Write-verbose "DiskGuid is $DiskGuid"
        # Now we need to find the WinDisk number that matches the given Guid
        # Clear the variable first so if we dont find one we can test later
        clear-variable FoundWinDisk -ErrorAction SilentlyContinue
        foreach ( $MyDisk in Get-Disk)
            {   $TestGuid = ($MyDisk).Path
                # Need to trim the start and end to expose just the Guid
                $UnTrimmedGuid = $TestGuid
                $TestGuid = ( $TestGuid.trimstart('\\?\Disk{') ).trimend('}')
                # write-host "Test Guid is $TestGuid"
                if ( $TestGuid -eq $DiskGuid)
                    {   write-verbose "Found the correct Disk"
                        $FoundWinDisk = $MyDisk
                    }
            }
        if ( $FoundWinDisk )
            {   #$FoundWinDisk | Out-string
                # This will return as valid only if a drive letter is assigned
                $MyDiskGUID = $FoundWinDisk.Path
                write-verbose "My Path is $MyDiskGuid"
                $FoundPartition = Get-Partition -DiskId $MyDiskGuid
                $MyPartitionAccessPaths = (Get-Partition -DiskId $MyDiskGuid).AccessPaths  
                Write-verbose "The Access Paths are below"
                # Extract the access paths to get to each drive. if they exist
                foreach ( $APath in $MyPartitionAccessPaths )
                    {   if ( $APath -like '*:\' )
                            {   $FoundPath = $APath
                                write-verbose "The Path for this volume is $FoundPath"
                            }
                        }
                # Obtain the drive letter from the Path variable:
                $FoundVol = ( Get-Volume ($FoundPath.trimend(':\')) )
                $NimVol = ( Get-NSVolume | where-object {$_.serial_number -like $FoundWinDisk.SerialNumber })
                $FoundClusterDiskObject = [ordered]@{
                                    ClusterDiskName     =   $ClusDisk.Name;
                                    ClusterDiskOwnerNode=   $ClusDisk.OwnerNode;
                                    ClusterResourceId   =   $ClusDisk.Id;
                                    ClusterResourceState=   $ClusDisk.State;
                                    ClusterResourceType =   'Physical Disk';
                                    DiskGuid            =   $DiskGuid;  
                                    WinDiskNumber       =   $FoundWinDisk.DiskNumber;
                                    WinDiskSerialNumber =   $FoundWinDisk.SerialNumber;
                                    WinDiskPath         =   $FoundWinDisk.Path;
                                    WinDiskFriendlyName =   $FoundWinDisk.FriendlyName;
                                    WinDiskIsClustered  =   $FoundWinDisk.IsClustered;
                                    WinDiskIsHighlyAvailable = $FoundWinDisk.IsHighlyAvailable; 
                                    WinDiskSize         =   $FoundWinDisk.Size;
                                    WinDiskPartitionStyle = $FoundWinDisk.PartitionStyle;
                                    WinDiskProvisioningType=$FoundWinDisk.ProvisioningType;
                                    PartitionDriveLetter=   $FoundPath;
                                    VolumeFileSystem    =   $FoundVol.FileSystemType;
                                    VolumeFileSystemLabel=  $FoundVol.FileSystemLabel;
                                    VolumeSize          =   $FoundVol.Size
                                    VolumeSizeRemaining =   $FoundVol.SizeRemaining;
                                    VolumeAllocationUnit=   $FoundVol.AllocationUnitSize;                                   
                                    NimbleVolumeName    =   $NimVol.name;
                                    NimbleVolumeId      =   $NimVol.id;
                                    NimbleVolumeDeDupe  =   $NimVol.dedupe_enabled;
                                    NimbleVolumeThin    =   $NimVol.thinly_provisioned                                   
                                }
                $ReturnObjColl += ( $FoundClusterDiskObject | convertto-json | convertfrom-json )        
            }
    }

    # Now to Obtain the CSVs and Create their Objects
    $MyCSVs = Get-ClusterSharedVolume
    $CSVSharedRoot = (Get-Cluster).SharedVolumesRoot
    foreach ( $CSV in $MyCSVs )
    {   clear-variable FoundWinDisk         -ErrorAction SilentlyContinue
        clear-variable FoundUnTrimmedGuid   -ErrorAction SilentlyContinue
        $RegLocation = "HKLM:\Cluster\Resources\"+($CSV.Id)+"\Parameters"
        #write-host "Location to look for details = $RegLocation"
        $DiskGuid = get-ItemPropertyValue -Path $RegLocation -name DiskGuid
        # Need to trim the starting { and ending } from the string
        $DiskGuid = ($DiskGuid.trimstart('{')).trimend('}')
        # Write-host "DiskGuid is $DiskGuid"
        # Now we need to find the WinDisk number that matches the given Guid
        # Clear the variable first so if we dont find one we can test later
        foreach ( $MyDisk in Get-Disk)
            {   $TestGuid = ($MyDisk).Path
                # Need to trim the start and end to expose just the Guid
                $UnTrimmedGuid = $TestGuid
                $TestGuid = ( $TestGuid.trimstart('\\?\Disk{') ).trimend('}')
                # write-host "Test Guid is $TestGuid"
                if ( $TestGuid -eq $DiskGuid)
                    {   $FoundWinDisk = $MyDisk
                        $WindiskNum = $FoundWinDisk.number
                        # write-host "Found the correct Disk $WindiskNum"                         
                        $FoundUnTrimmedGUID = $UnTrimmedGuid
                    }
            }

        if ( $FoundWinDisk )
            {   #$FoundWinDisk | Out-string
                # This will return as valid only if a drive letter is assigned
                $MyDiskGUID = $FoundWinDisk.Path
                # write-verbose "My Path is $MyDiskGuid"
                $FoundPartition = Get-Partition -DiskId $MyDiskGUID
                $MyPartitionAccessPaths = (Get-Partition -DiskId $FoundUnTrimmedGuid).AccessPaths  
                # Write-host "The Access Paths are below"
                #$MyPartitionAccessPaths | out-string
                # Extract the access paths to get to each drive. if they exist

                foreach ( $APath in $MyPartitionAccessPaths )
                    {   #  write-host "Testing $APath against $CSVSharedRoot"
                        if ( $APath.length -ge $CSVSharedRoot.length )
                        {   # write-host "Length is equal or greater" 
                            $ShortAPath = $APath.substring(0,$CSVSharedRoot.length)
                            # write-host "Testing $ShortAPath against $CSVSharedRoot"
                            if ( $ShortAPath -like $CSVSharedRoot )
                                {   $FoundPath = $APath
                                    # write-host "The Path for this volume is $FoundPath"                                
                                } 
                            else 
                                {   $RawVolId = $APath
                                    # Write-host "The raw VolId is $APath"
                                }
                        }
                    }
                # write-host "RawVolId = $RawVolId"
                # Obtain the drive letter from the Path variable:
                # write-host "The CSV Name is $($CSV.name)"
                # $CSV 
                $AllVol = ( Get-Volume | where-object { $_.FileSystem -like 'CSVFS' } )
                $FoundVol = $AllVol | where { $_.UniqueId -like $RawVolId }

                # write-host "The Volume info is as follows"
                # $FoundVol | out-string
                # Lets find the Nimble Volume that matches this Windows Volume
                $NimVol = ( Get-NSVolume | where-object {$_.serial_number -like $FoundWinDisk.SerialNumber })

                $FoundClusterDiskObject = [ordered]@{
                                    ClusterDiskName     =   $CSV.Name;
                                    ClusterDiskOwnerNode=   $CSV.OwnerNode;
                                    ClusterResourceId   =   $CSV.Id;
                                    ClusterResourceState=   $CSV.State;
                                    ClusterResourceType =   'Cluster Shared Volume';
                                    DiskGuid            =   $DiskGuid;  
                                    WinDiskNumber       =   $FoundWinDisk.DiskNumber;
                                    WinDiskSerialNumber =   $FoundWinDisk.SerialNumber;
                                    WinDiskPath         =   $FoundWinDisk.Path;
                                    WinDiskFriendlyName =   $FoundWinDisk.FriendlyName;
                                    WinDiskIsClustered  =   $FoundWinDisk.IsClustered;
                                    WinDiskIsHighlyAvailable = $FoundWinDisk.IsHighlyAvailable; 
                                    WinDiskSize         =   $FoundWinDisk.Size;
                                    WinDiskPartitionStyle = $FoundWinDisk.PartitionStyle;
                                    WinDiskProvisioningType=$FoundWinDisk.ProvisioningType;
                                    PartitionDriveLetter=   $FoundPath;
                                    VolumeFileSystem    =   $FoundVol.FileSystem;
                                    VolumeFileSystemLabel=  $FoundVol.FileSystemLabel;
                                    VolumeSize          =   $FoundVol.Size
                                    VolumeSizeRemaining =   $FoundVol.SizeRemaining;
                                    VolumeAllocationUnit=   $FoundVol.AllocationUnitSize;                                   
                                    NimbleVolumeName    =   $NimVol.name;
                                    NimbleVolumeId      =   $NimVol.id;
                                    NimbleVolumeDeDupe  =   $NimVol.dedupe_enabled;
                                    NimbleVolumeThin    =   $NimVol.thinly_provisioned
                        }  
                $ReturnObjColl += ( $FoundClusterDiskObject | convertto-json | convertfrom-json )
                        
            }
        #write-host
        #write-host "End of looop"
        #write-host
    }
 
    # Now lets look for Disks that are not Clustered
    foreach ( $WinVol in (Get-Partition | where-object {$_.DriveLetter} ) )
        {   $DiskNum = $WinVol.DiskNumber
            $AlreadyExists = $False
            foreach ( $FoundVol in $ReturnObjColl )
                {   # This will clear the drive letter if it already exists in the collection as a clusterdisk
                    if ( $DiskNum -like $FoundVol.WinDiskNumber )
                        {   if ( $FoundVol.IsClustered )
                                {   #Assumes that if two partitions exists, can only be a Local not clustered disk
                                    $AlreadyExists = $True
                                }
                        }
                }
            if ( -not $AlreadyExists )
                {   # This drive must be a non-clustered drive. Lets find its disk \\?\Volume{f99872de-15ce-4a58-8362-d12fd31e0ed1}\        
                    $FoundWinDisk = Get-Disk -Number $DiskNum
                    # write-host "The Volume info is as follows"
                    # Lets find the Nimble Volume that matches this Windows Volume
                    $NimVol = ( Get-NSVolume | where-object {$_.serial_number -like $FoundWinDisk.SerialNumber })
                    $MyPartitionAccessPaths = $WinVol.AccessPaths  
                    Write-verbose "The Access Paths are below"
    #                $MyPartitionAccessPaths | out-string
                    # Extract the access paths to get to each drive. if they exist
                    foreach ( $APath in $MyPartitionAccessPaths )
                        {   if ( $APath -like '*:\' )
                                {   $FoundPath = $APath
                                    write-verbose "The Path for this volume is $FoundPath"
                                }
                            }
                    $FoundVol = ( Get-Volume ($FoundPath.trimend(':\')) )
                    $FoundClusterDiskObject = [ordered]@{
                                    DiskGuid                =   $FoundWinDisk.Guid;  
                                    WinDiskNumber           =   $FoundWinDisk.DiskNumber;
                                    WinDiskSerialNumber     =   $FoundWinDisk.SerialNumber;
                                    WinDiskPath             =   $FoundWinDisk.Path;
                                    WinDiskFriendlyName     =   $FoundWinDisk.FriendlyName;
                                    WinDiskIsClustered      =   $FoundWinDisk.IsClustered;
                                    WinDiskIsHighlyAvailable=   $FoundWinDisk.IsHighlyAvailable; 
                                    WinDiskSize             =   $FoundWinDisk.Size;
                                    WinDiskPartitionStyle   =   $FoundWinDisk.PartitionStyle;
                                    WinDiskProvisioningType =   $FoundWinDisk.ProvisioningType;
                                    PartitionDriveLetter    =   $FoundPath;
                                    VolumeFileSystem        =   $FoundVol.FileSystem;
                                    VolumeFileSystemLabel   =   $FoundVol.FileSystemLabel;
                                    VolumeSize              =   $FoundVol.Size
                                    VolumeSizeRemaining     =   $FoundVol.SizeRemaining;
                                    VolumeAllocationUnit    =   $FoundVol.AllocationUnitSize;                                   
                                    NimbleVolumeName        =   $NimVol.name;
                                    NimbleVolumeId          =   $NimVol.id;
                                    NimbleVolumeDeDupe      =   $NimVol.dedupe_enabled;
                                    NimbleVolumeThin        =   $NimVol.thinly_provisioned
                        } 
                    $AlreadyExists = $False
                    foreach ($AlreadyFoundDisks in $ReturnObjColl)
                        {   if ($FoundClusterDiskObject.PartitionDriveLetter -like $AlreadyFoundDisks.PartitionDriveLetter)
                                { $AlreadyExists = $True
                                }
                        }
                    if ( -not $AlreadyExists )
                        {   $ReturnObjColl += ( $FoundClusterDiskObject | convertto-json | convertfrom-json )
                        }
                }
        }

}
end
{    return $ReturnObjColl
}
}

function Get-NSHostHyperVStorage
{
[cmdletbinding()]  
param ()
begin
{   $ReturnObjColl = @()
    # Lets make sure that a NimbleStorage Connection exists so that we can obtain more drive information.
    # First we must make sure that the failovercluster Powershell commands exist and are loaded.
    if ( Get-module hyper-v )
        {   # The module is found and loaded
        }
    else{   # Lets try and load it
            import-module hyper-v
            if ( get-module hyper-v)
                {   # It was successfully loaded
                }
            else{   write-warning "The Hyper-V Module could not be loaded. exiting"
                    exit                
            }
        }   
}
process 
{   $MyListofVMs = @()
    $MyNSListOfDrives = Get-NSHostVolume
    foreach ( $VM in Get-vm )
        {   $MyVHDx = @()
            $MyFilePaths = @()
            foreach ( $VHDx in (Get-VMHardDiskDrive -VMName $VM.name) )
                {   $MyVHDx += $VHDx.Path  
                    $TempVHDx = $VHDx.Path
                    $MyFilePaths += $TempVHDx.Substring(0,$TempVHDx.LastIndexOf('\')+1)
                } 
            $VariousConfigFiles= @(     $VM.CheckpointFileLocation,   $VM.ConfigurationLocation,
                                        $VM.SmartPagingFileLocation,  $VM.SnapshotFileLocation,
                                        $VM.Path     
                                    )
            $VariousConfigFiles = $VariousConfigFiles | select-object -unique
            $MyDisks = @()
            $WDSNs = @()
            $NimbleVolumeNames = @()
            $NimbleVolumeIds = @()
            foreach ( $CFileType in $VariousConfigFiles )
                {   if ( -not $CFileType.EndsWith('\') )
                        {   $CFileType = $CFileType + '\'
                        }
                    foreach ( $MyNSListSingleDrive in $MyNSListOfDrives )
                        {   if ( $CFileType.StartsWith('C:\ClusterStorage'))
                                {   if ( $MyNSListSingleDrive.VolumeFileSystem -eq 'CSVFS' )
                                        {   if ( $CFileType.StartsWith($MyNSListSingleDrive.PartitionDriveLetter) )
                                                {   $MyDisks += $MyNSListSingleDrive.PartitionDriveLetter
                                                    $SN = $MyNSListSingleDrive.WinDiskSerialNumber
                                                    $WDSNs += $SN
                                                    if ( $MyNSListSingleDrive.NimbleVolumeId )  
                                                        {   $NimbleVolumeNames += $MyNSListSingleDrive.NimbleVolumeName
                                                            $NimbleVolumeIds += $MyNSListSingleDrive.NimbleVolumeId
                                                        }
                                                }
                                        }         
                                }
                            else
                                {   if ( $CFileType.StartsWith($MyNSListSingleDrive.PartitionDriveLetter) )
                                        {   $MyDisks += $MyNSListSingleDrive.PartitionDriveLetter
                                            $SN = $MyNSListSingleDrive.WinDiskSerialNumber
                                            $WDSNs += $SN
                                            if ( $MyNSListSingleDrive.NimbleVolumeId )  
                                                {   $NimbleVolumeNames += $MyNSListSingleDrive.NimbleVolumeName
                                                    $NimbleVolumeIds += $MyNSListSingleDrive.NimbleVolumeId
                                                }
                                        }

                                }
                        }
                }
            ### Lets find out if the complete VM lives on the Nimble Array
            $NimbleVolumes = (Get-NSVolume).serial_number
            $AllVolumesAreNimble = $True
            foreach( $Serials in $WDSNs )
                {   $FoundNimbleVolume = $False
                    foreach ( $NimVolSerial in $NimbleVolumes )
                        {   If ( $NimVolSerial -like $Serials )
                                {   $FoundNimbleVolume = $True
                                } 
                        }
                    if ( -not $FoundNimbleVolume )
                        {   $AllVolumesAreNimble = $False
                        }    
                }
            ### Lets find out if the VM is a Clustered VM
            $VMIsClustered = [boolean](Get-ClusterResource | where {$_.ResourceType -like 'Virtual Machine' } | where { $_.OwnerGroup -like $VM.Name })
            ### Lets make sure that ALL of the VMs disks are Cluster Disks
            $AllDisksAreClustered = $True
            foreach( $Serials in $WDSNs )
                {   foreach ( $HostVol in $MyNSListOfDrives)
                    {   if ( $Serials -like $HostVol.WinDiskSerialNumber )
                            {   if ( -not $HostVol.WinDiskIsClustered ) 
                                    {   $AllDisksAreClustered = $False
                                    }
                            }
                    }
                }
            $MyVMObject = [ordered]@{   Name                        = $VM.Name;
                                        VMCheckpointFileLocation    = $VM.CheckpointFileLocation;
                                        VMConfigurationLocation     = $VM.ConfigurationLocation;
                                        VMSnapshotFileLocation      = $VM.SnapshotFileLocation;
                                        VMPath                      = $VM.Path;
                                        VHDList                     = $MyVHDx;
                                        VHDPaths                    = $MyFilePaths | select-object -unique;
                                        VMDisks                     = $MyDisks;
                                        WinDiskSerialNumbers        = $WDSNs;
                                        AllDisksAreNimbleBased      = $AllVolumesAreNimble
                                        VMIsClustered               = $VMIsClustered;
                                        AllDisksAreClusterDisks     = $AllDisksAreClustered
                                        }
            if ( $VM.SmartPagingFileInUse )
                {   $MyVMObject += @{   VMSmartPagingFileLocation   = $VM.SmartPagingFileLocation }
                }
            if ( $NimbleVolumeNames )
                {   $MyVMObject += @{   NimbleVolumeNames           = $NimbleVolumeNames;
                                        NimbleVolumeIds             = $NimbleVolumeIds
                                    }
                }
            
            $MyListOfVMs += $MyVMObject
        }
}
end
{   return ( $MyListofVMs | convertto-json -depth 5 | convertfrom-json )
}
}

