function Get-NSHostVolume
{
<# 
.SYNOPSIS
    Will return a list of Volumes on the Windows Host, and details of those volumes
.DESCRIPTION
    Will return a list of Volumes on the Windows Host, and details of those volumes. This will return all host volumes; both SAN 
    based and DAS based. Each Volume is represented by either a Drive Letter or a Mount Point; and Windows Partition that has no 
    access (via no Drive Letter or Mount Point is ignored.)
    This command will return the Mount Point or Drive Letter; as well as the Serial Number, if the Volume is Clustered and how, 
    and if the Volume is a Nimble Storage or Alletra9K volume will return the Nimble Volume Name as well as the Nimble Volume ID 
    of the backing Nimble Volume.
    This command is also compatible with Windows Failover Clustering and can be used to interogate Cluster Nodes or Standalon
    servers equally. 
.NOTES
    This command only works on Windows Server, as Linux machines use an alternate logical disk manager.
.EXAMPLE
    PS:> Get-NSHostVolume | format-table WinDiskNumber, PartitionDriveLetter, NimbleVolumeName, WinDiskIsClustered, WinDiskFriendlyName

    WinDiskNumber PartitionDriveLetter       NimbleVolumeName           WinDiskIsClustered WinDiskFriendlyName
    ------------- --------------------       ----------------           ------------------ -------------------
                4 G:\                        ZClusStandAloneSharedDisk2               True Nimble Server
                3 O:\                        ZClusClusterDiskNotShared                True Nimble Server
                5 C:\ClusterStorage\Volume1\ ZClusVM1OnlyCSVOnly1                     True Nimble Server
                6 C:\ClusterStorage\Volume2\ ZClusVM23CSVOnly1                        True Nimble Server
                0 C:\                                                                False HP LOGICAL VOLUME
                1 D:\                                                                False HP LOGICAL VOLUME
                2 E:\                                                                False HP LOGICAL VOLUME
                2 F:\                                                                False HP LOGICAL VOLUME
.EXAMPLE
    PS:> Get-NSHostVolume | where {$_.WinDiskNumber -eq 5}

    ClusterDiskName          : ZClusVM1OnlyCSVOnly
    ClusterDiskOwnerNode     : Zeus
    ClusterResourceId        : e0038a5f-e4bf-49d5-b955-162a4c833a6e
    ClusterResourceState     : Online
    ClusterResourceType      : Cluster Shared Volume
    DiskGuid                 : d978a1e4-d0a5-a8ac-f916-bfeded4ee00c
    WinDiskNumber            : 5
    WinDiskSerialNumber      : 974d41e0824d9bc56c9ce900efcbab72
    WinDiskPath              : \\?\Disk{d978a1e4-d0a5-a8ac-f916-bfeded4ee00c}
    WinDiskFriendlyName      : Nimble Server
    WinDiskIsClustered       : True
    WinDiskIsHighlyAvailable : True
    WinDiskSize              : 1099511627776
    WinDiskPartitionStyle    : GPT
    WinDiskProvisioningType  : Thin
    PartitionDriveLetter     : C:\ClusterStorage\Volume1\
    VolumeFileSystem         : CSVFS
    VolumeFileSystemLabel    : ZVM1CSV1
    VolumeSize               : 1099492749312
    VolumeSizeRemaining      : 987256393728
    VolumeAllocationUnit     : 4096
    NimbleVolumeName         : ZClusVM1OnlyCSVOnly1
    NimbleVolumeId           : 062afce87958572396000000000000000000000087
    NimbleVolumeDeDupe       : True
    NimbleVolumeThin         : True
#>
[cmdletbinding()]  
param ()
begin 
{   $ReturnObjColl = @()
}
Process
{   # Process Cluster Physical Disks.
    if ( (Get-WindowsFeature Failover-Clustering).installed -and (get-cluster -erroraction silentlycontinue -warningaction silentlycontinue) )
        {    $MyClusterDisks = Get-ClusterResource | where-object { $_.ResourceType -eq 'Physical Disk'}
        }
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
    if ( (Get-WindowsFeature Failover-Clustering).installed -and (get-cluster -erroraction silentlycontinue -warningaction silentlycontinue))  
        {   $MyCSVs = Get-ClusterSharedVolume
            $CSVSharedRoot = (Get-Cluster).SharedVolumesRoot 
        }
    foreach ( $CSV in $MyCSVs )
    {   clear-variable FoundWinDisk         -ErrorAction SilentlyContinue
        clear-variable FoundUnTrimmedGuid   -ErrorAction SilentlyContinue
        $RegLocation = "HKLM:\Cluster\Resources\"+($CSV.Id)+"\Parameters"
        $DiskGuid = get-ItemPropertyValue -Path $RegLocation -name DiskGuid
        # Need to trim the starting { and ending } from the string
        $DiskGuid = ($DiskGuid.trimstart('{')).trimend('}')
        # Now we need to find the WinDisk number that matches the given Guid
        # Clear the variable first so if we dont find one we can test later
        foreach ( $MyDisk in Get-Disk)
            {   $TestGuid = ($MyDisk).Path
                # Need to trim the start and end to expose just the Guid
                $UnTrimmedGuid = $TestGuid
                $TestGuid = ( ( $TestGuid.trimstart('\\?\Disk') ).trimend('}').trimstart('{') )
                if ( $TestGuid -eq $DiskGuid)
                    {   $FoundWinDisk = $MyDisk
                        # $WindiskNum = $FoundWinDisk.number
                        $FoundUnTrimmedGUID = $UnTrimmedGuid
                    }
            }
        if ( $FoundWinDisk )
            {   # This will return as valid only if a drive letter is assigned
                $MyDiskGUID = $FoundWinDisk.Path
                $FoundPartition = Get-Partition -DiskId $MyDiskGUID
                $MyPartitionAccessPaths = (Get-Partition -DiskId $FoundUnTrimmedGuid).AccessPaths  
                # Extract the access paths to get to each drive. if they exist
                foreach ( $APath in $MyPartitionAccessPaths )
                    {   if ( $APath.length -ge $CSVSharedRoot.length )
                        {   $ShortAPath = $APath.substring(0,$CSVSharedRoot.length)
                            if ( $ShortAPath -like $CSVSharedRoot )
                                {   $FoundPath = $APath
                                } 
                            else 
                                {   $RawVolId = $APath
                                }
                        }
                    }
                $AllVol = ( Get-Volume | where-object { $_.FileSystem -like 'CSVFS' } )
                $FoundVol = $AllVol | where-object { $_.UniqueId -like $RawVolId }
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
                    # Lets find the Nimble Volume that matches this Windows Volume
                    $NimVol = ( Get-NSVolume | where-object {$_.serial_number -like $FoundWinDisk.SerialNumber })
                    $MyPartitionAccessPaths = $WinVol.AccessPaths  
                    Write-verbose "The Access Paths are below"
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
{   # Repackage the object and Add the type
    $FinalObject = @()
    foreach ( $Item in $ReturnObjColl)
        {   $TypedItem = $Item
            $DataSetType = "NimbleStorage.HostVolume"
            $TypedItem.PSTypeNames.Insert(0,$DataSetType)
            $DataSetType = $DataSetType + ".TypeName"
            $TypedItem.PSObject.TypeNames.Insert(0,$DataSetType) 
            $FinalObject += $TypedItem
        }
    return $FinalObject
}
}

function Get-NSHostHyperVStorage
{
<#
.SYNOPSIS
    This commnad will gather the list of VMs and return the Backing Volume Information.
.DESCRIPTION
    This commnad will gather the list of VMs and return the Backing Volume Information. The list of VMs is 
    gathered from both the Local installation of Hyper-V as well as the List of Clustered VMs if Windows 
    Failover Clustering is installed. Each VM may have multiple locations for the various aspects of that VM
    which include the VM Paths, the VMConfigFiles, The VMSnapshot/Checkpoints, and the VM attached VHDs.
    These Locations are presented as both the PartitionDriveLetters, the Serial Numbers, and the collections
    of the backing Volumes, incuding a collection of the Nimble Volume IDs that represent these volumes.  
.EXAMPLE
Name            VMPath                            AllDisksAre NimbleVolumeNames
                                                  NimbleBased
----            ------                            ----------- -----------------
Oracle12c       D:\Oracle12c                      False
PiAlert         C:\ClusterStorage\Volume1         True        {ZClusVM1OnlyCSVOnly1, …
SCOM2022        C:\ClusterStorage\Volume2         True        {ZClusVM23CSVOnly1, ZCl…
SCVMM2022       C:\ClusterStorage\Volume2         True        {ZClusVM23CSVOnly1}
W2016CNode1     C:\ClusterStorage\Volume1\Cluste… True        {ZClusVM1OnlyCSVOnly1}
W2016CNode2     C:\ClusterStorage\Volume2\W2016C… True        {ZClusVM23CSVOnly1, ZCl…
W2022CNode1Core D:\W2022CNode1Core                False
W2022CNode2     C:\ClusterStorage\Volume1\Cluste… True        {ZClusVM1OnlyCSVOnly1}
W2022CNode2Core D:\W2022CNode2Core                False
W22DPM19        D:\                               False
W22SQL19        D:\W22SQL19                       False
ZoneMinderUbun… D:\ZoneMinderUbuntu1804           False

PS C:\Users\chris\Desktop\PowerShell\HPEStoragePowerShellToolkit>
#>
[cmdletbinding()]  
param ()
begin
{   # Lets make sure that a NimbleStorage Connection exists so that we can obtain more drive information.
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
                    return              
            }
        }   
}
process 
{   $MyListofVMs = @()
    $MyNSListOfDrives = Get-NSHostVolume
    foreach ( $VM in Get-vm )
        {   $MyVHDx = @()
            $MyFilePaths = @()
            $VariousConfigFiles= @(     $VM.CheckpointFileLocation,   $VM.ConfigurationLocation,
                                        $VM.SmartPagingFileLocation,  $VM.SnapshotFileLocation,
                                        $VM.Path     
                                    )
            foreach ( $VHDx in (Get-VMHardDiskDrive -VMName $VM.name) )
                {   $MyVHDx += $VHDx.Path  
                    $TempVHDx = $VHDx.Path
                    $CleanName = $TempVHDx.Substring(0,$TempVHDx.LastIndexOf('\'))
                    if ( $CleanName.endswith(':') )
                        { $CleanName += '\' 
                        }
                    $MyFilePaths += $CleanName
                    $VariousConfigFiles += $CleanName
                } 
            $VariousConfigFiles = $VariousConfigFiles | select-object -unique
            $MyDisks = @()
            $WDSNs = @()
            $NimbleVolumeNames = @()
            $NimbleVolumeIds = @()
            write-verbose "Contents of VariousConfigFiles"
            # $VariousConfigFiles | out-string
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
            $VMIsClustered = [boolean](Get-ClusterResource | where-object {$_.ResourceType -like 'Virtual Machine' } | where-object { $_.OwnerGroup -like $VM.Name })
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
{   $FinalObject = @()
    $MyListOfVMs = ( $MyListofVMs | convertto-json -depth 5 | convertfrom-json )
    foreach ( $Item in $MyListOfVMs)
        {   $TypedItem = $Item
            $DataSetType = "NimbleStorage.HostHyperVStorage"
            $TypedItem.PSTypeNames.Insert(0,$DataSetType)
            $DataSetType = $DataSetType + ".TypeName"
            $TypedItem.PSObject.TypeNames.Insert(0,$DataSetType) 
            $FinalObject += $TypedItem
        }
    return $FinalObject 
    #    return ( $MyListofVMs | convertto-json -depth 5 | convertfrom-json )
}
}


function Get-NSHostInitiator
{
begin
{    $ReturnObjColl = @()
}
process
{   # First lets get a list of local HBAs or iSCSI initiators
    $iSCSIPort =    ( Get-InitiatorPort | where-object {$_.ConnectionType -like 'iSCSI' } ).NodeAddress + `
                    ( Get-InitiatorPort | where-object {$_.ConnectionType -like '2' }).NodeAddress
    $FCPorts = @()
    $wwpns = ( get-initiatorport | where-object { $_.ConnectionType -like 'Fibre Channel'} ).portaddress 
    foreach ( $wwpn in $wwpns )
        {   $FCPorts += $wwpn -replace '(..)(?=.)','$1:' 
        }
    $ArrayInitiators = Get-NSInitiator
    # Lets look for this initiator iSCSI
    if ( (Get-NSGroup).iscsi_enabled )
            {   # This section only gets executed if the array is an iSCSI based array
                foreach( $IQN in $ArrayInitiators.IQN )
                    {   if ( $IQN -like $iSCSIPort )
                            {   $ReturnObjColl += (Get-NSInitiator | where-object { $_.IQN -like $iSCSIPort } )                
                            }
                    }
            }
        else 
            {   # This section only gets executed if the array is a FC based array
                foreach ( $WWPN in $ArrayInitiators.wwpn )
                    {   write-host "These are the WWPNs: $WWPN"
                        foreach ($MyWwpn in $FCPorts)
                            {   if ( $WWPN -like $MyWwpn )
                                {   write-host "This WWPN has been found $WWPN vs $MyWwpn"
                                    $ReturnObjColl += ( Get-NSInitiator | where-object { $_.wwpn -like $MyWwpn} )
                                }
                            }
                    }
            }
    $ReturnObjColl = ($ReturnObjColl | select-object -unique)
    if ( -not $ReturnObjColl )
            {   write-warning "This IQN is not registered with the Storage Array."
            }
    if ( $ReturnObjColl.count -gt 1 )
        {   write-warning "This Initiator appears in multiple Initiator Groups."
        }
}
end
{   return $ReturnObjColl
}
}

Function New-NSHostInitiatorGroup 
{   

begin
{
}
process
{   # First lets make sure that the Initiator group doesnt already exist
    if ( (Get-NSHostInitiator).count -eq 0 )
        {   # This Initiator is not present one the array, so I can build a new one.
            $iSCSIPort =    ( Get-InitiatorPort | where-object {$_.ConnectionType -like 'iSCSI' } ).NodeAddress + `
                            ( Get-InitiatorPort | where-object {$_.ConnectionType -like '2' } ).NodeAddress
            $FCPorts = @()
            $wwpns = ( get-initiatorport | where-object { $_.ConnectionType -like 'Fibre Channel'} ).portaddress 
            foreach ( $wwpn in $wwpns )
                {   $FCPorts += $wwpn -replace '(..)(?=.)','$1:' 
                }
            $ArrayInitiators = Get-NSInitiator
            # Lets look for this initiator
            if ( (Get-NSInitiatorGroup).Name -contains (hostname) )
                    {   write-warning "An InitiatorGroup already exists with the prescribed Name of : $(hostname)"
                        return
                    }
            [string]$MyIGName = (hostname)
            [string]$MyIGLabel = (hostname) + '-iqn' 
            [string]$MyIGLabel = (hostname) + '-wwpn'                                                
            if ( (Get-NSGroup).iscsi_enabled )
                    {   # This section only gets executed if the array is an iSCSI based array
                        # First lets make sure that an Label Doesnt exist with this hostname and the suffix IQN
                        if ( (Get-NSInitiator).Label -contains (hostname + '-iqn') )
                                {   write-warning "An Initiator Label already exists with the prescribed IQN Label of : $(hostname)-iqn')"
                                    return
                                }
                            else
                                {   $MyIG = (New-NSInitiatorGroup -name $MyIGName  -access_protocol iscsi )
                                    New-NSInitiator -label $MyIGLabel -initiator_group_id ($MyIG.id) -access_protocol iscsi -iqn $iSCSIPort
                                    return $MyIG    
                                }
                    }
                else 
                    {   # This section only gets executed if the array is a FC based array
                        foreach ( $WWPN in $ArrayInitiators.wwpn )
                            {   write-host "These are the WWPNs: $WWPN"
                                foreach ($MyWwpn in $FCPorts)
                                    {   if ( $WWPN -like $MyWwpn )
                                        {   write-host "This WWPN has been found $WWPN vs $MyWwpn"
                                            $ReturnObjColl += ( Get-NSInitiator | where-object { $_.wwpn -like $MyWwpn} )
                                        }
                                    }
                            }
                    }
        }
}
end 
{
}
}

# SIG # Begin signature block
# MIIt4wYJKoZIhvcNAQcCoIIt1DCCLdACAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBcugZ+vrf3
# h3EvKHS9z3TF1ddbHCTHH8scW4PANoQM/icOp6uoNfm4GLetmd0Fw0/scXWE2T5G
# vfE0+Ei207THoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
# KoZIhvcNAQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExp
# bWl0ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0yMTA1
# MjUwMDAwMDBaFw0yODEyMzEyMzU5NTlaMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AI3nlBIiBCR0Lv8WIwKSirauNoWsR9QjkSs+3H3iMaBRb6yEkeNSirXilt7Qh2Mk
# iYr/7xKTO327toq9vQV/J5trZdOlDGmxvEk5mvFtbqrkoIMn2poNK1DpS1uzuGQ2
# pH5KPalxq2Gzc7M8Cwzv2zNX5b40N+OXG139HxI9ggN25vs/ZtKUMWn6bbM0rMF6
# eNySUPJkx6otBKvDaurgL6en3G7X6P/aIatAv7nuDZ7G2Z6Z78beH6kMdrMnIKHW
# uv2A5wHS7+uCKZVwjf+7Fc/+0Q82oi5PMpB0RmtHNRN3BTNPYy64LeG/ZacEaxjY
# cfrMCPJtiZkQsa3bPizkqhiwxgcBdWfebeljYx42f2mJvqpFPm5aX4+hW8udMIYw
# 6AOzQMYNDzjNZ6hTiPq4MGX6b8fnHbGDdGk+rMRoO7HmZzOatgjggAVIQO72gmRG
# qPVzsAaV8mxln79VWxycVxrHeEZ8cKqUG4IXrIfptskOgRxA1hYXKfxcnBgr6kX1
# 773VZ08oXgXukEx658b00Pz6zT4yRhMgNooE6reqB0acDZM6CWaZWFwpo7kMpjA4
# PNBGNjV8nLruw9X5Cnb6fgUbQMqSNenVetG1fwCuqZCqxX8BnBCxFvzMbhjcb2L+
# plCnuHu4nRU//iAMdcgiWhOVGZAA6RrVwobx447sX/TlAgMBAAGjggESMIIBDjAf
# BgNVHSMEGDAWgBSgEQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUMuuSmv81
# lkgvKEBCcCA2kVwXheYwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEE
# ATBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFD
# ZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAQEA
# Er+h74t0mphEuGlGtaskCgykime4OoG/RYp9UgeojR9OIYU5o2teLSCGvxC4rnk7
# U820+9hEvgbZXGNn1EAWh0SGcirWMhX1EoPC+eFdEUBn9kIncsUj4gI4Gkwg4tsB
# 981GTyaifGbAUTa2iQJUx/xY+2wA7v6Ypi6VoQxTKR9v2BmmT573rAnqXYLGi6+A
# p72BSFKEMdoy7BXkpkw9bDlz1AuFOSDghRpo4adIOKnRNiV3wY0ZFsWITGZ9L2PO
# mOhp36w8qF2dyRxbrtjzL3TPuH7214OdEZZimq5FE9p/3Ef738NSn+YGVemdjPI6
# YlG87CQPKdRYgITkRXta2DCCBeEwggRJoAMCAQICEQCZcNC3tMFYljiPBfASsES3
# MA0GCSqGSIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBD
# QSBSMzYwHhcNMjIwNjA3MDAwMDAwWhcNMjUwNjA2MjM1OTU5WjB3MQswCQYDVQQG
# EwJVUzEOMAwGA1UECAwFVGV4YXMxKzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBF
# bnRlcnByaXNlIENvbXBhbnkxKzApBgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRl
# cnByaXNlIENvbXBhbnkwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCi
# DYlhh47xvo+K16MkvHuwo3XZEL+eEWw4MQEoV7qsa3zqMx1kHryPNwVuZ6bAJ5OY
# oNch6usNWr9MZlcgck0OXnRGrxl2FNNKOqb8TAaoxfrhBSG7eZ1FWNqxJAOlzXjg
# 6KEPNdlhmfVvsSDolVDGr6yEXYK9WVhVtEApyLbSZKLED/0OtRp4CtjacOCF/unb
# vfPZ9KyMVKrCN684Q6BpknKH3ooTZHelvfAzUGbHxfKvq5HnIpONKgFhbpdZXKN7
# kynNjRm/wrzfFlp+m9XANlmDnXieTeKEeI3y3cVxvw9HTGm4yIFt8IS/iiZwsKX6
# Y94RkaDzaGB1fZI19FnRo2Fx9ovz187imiMrpDTsj8Kryl4DMtX7a44c8vORYAWO
# B17CKHt52W+ngHBqEGFtce3KbcmIqAH3cJjZUNWrji8nCuqu2iL2Lq4bjcLMdjqU
# +2Uc00ncGfvP2VG2fY+bx78e47m8IQ2xfzPCEBd8iaVKaOS49ZE47/D9Z8sAVjcC
# AwEAAaOCAYkwggGFMB8GA1UdIwQYMBaAFA8qyyCHKLjsb0iuK1SmKaoXpM0MMB0G
# A1UdDgQWBBRtaOAY0ICfJkfK+mJD1LyzN0wLzjAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBKBgNVHSAEQzBBMDUGDCsG
# AQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQ
# UzAIBgZngQwBBAEwSQYDVR0fBEIwQDA+oDygOoY4aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQVIzNi5jcmwweQYIKwYBBQUH
# AQEEbTBrMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNydDAjBggrBgEFBQcwAYYXaHR0cDov
# L29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggGBACPwE9q/9ANM+zGO
# lq4SZg7qDpsDW09bDbdjyzAmxxJk2GhD35Md0IluPppla98zFjnuXWpVqakGk9vM
# KxiooQ9QVDrKYtx9+S8Qui21kT8Ekhrm+GYecVfkgi4ryyDGY/bWTGtX5Nb5G5Gp
# DZbv6wEuu3TXs6o531lN0xJSWpJmMQ/5Vx8C5ZwRgpELpK8kzeV4/RU5H9P07m8s
# W+cmLx085ndID/FN84WmBWYFUvueR5juEfibuX22EqEuuPBORtQsAERoz9jStyza
# gj6QxPG9C4ItZO5LT+EDcHH9ti6CzxexePIMtzkkVV9HXB6OUjgeu6MbNClduKY4
# qFiutdbVC8VPGncuH2xMxDtZ0+ip5swHvPt/cnrGPMcVSEr68cSlUU26Ln2u/03D
# eZ6b0R3IUdwWf4K/1X6NwOuifwL9gnTM0yKuN8cOwS5SliK9M1SWnF2Xf0/lhEfi
# VVeFlH3kZjp9SP7v2I6MPdI7xtep9THwDnNLptqeF79IYoqT3TCCBhowggQCoAMC
# AQICEGIdbQxSAZ47kHkVIIkhHAowDQYJKoZIhvcNAQEMBQAwVjELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAwMFoXDTM2
# MDMyMTIzNTk1OVowVDELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIENBIFIz
# NjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJsrnVP6NT+OYAZDasDP
# 9X/2yFNTGMjO02x+/FgHlRd5ZTMLER4ARkZsQ3hAyAKwktlQqFZOGP/I+rLSJJmF
# eRno+DYDY1UOAWKA4xjMHY4qF2p9YZWhhbeFpPb09JNqFiTCYy/Rv/zedt4QJuIx
# eFI61tqb7/foXT1/LW2wHyN79FXSYiTxcv+18Irpw+5gcTbXnDOsrSHVJYdPE9s+
# 5iRF2Q/TlnCZGZOcA7n9qudjzeN43OE/TpKF2dGq1mVXn37zK/4oiETkgsyqA5lg
# AQ0c1f1IkOb6rGnhWqkHcxX+HnfKXjVodTmmV52L2UIFsf0l4iQ0UgKJUc2RGarh
# OnG3B++OxR53LPys3J9AnL9o6zlviz5pzsgfrQH4lrtNUz4Qq/Va5MbBwuahTcWk
# 4UxuY+PynPjgw9nV/35gRAhC3L81B3/bIaBb659+Vxn9kT2jUztrkmep/aLb+4xJ
# bKZHyvahAEx2XKHafkeKtjiMqcUf/2BG935A591GsllvWwIDAQABo4IBZDCCAWAw
# HwYDVR0jBBgwFoAUMuuSmv81lkgvKEBCcCA2kVwXheYwHQYDVR0OBBYEFA8qyyCH
# KLjsb0iuK1SmKaoXpM0MMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYEVR0gADAIBgZn
# gQwBBAEwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRv
# MG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAG/4Lhd2M2bnuhFSCb
# E/8E/ph1RGHDVpVx0ZE/haHrQECxyNbgcv2FymQ5PPmNS6Dah66dtgCjBsULYAor
# 5wxxcgEPRl05pZOzI3IEGwwsepp+8iGsLKaVpL3z5CmgELIqmk/Q5zFgR1TSGmxq
# oEEhk60FqONzDn7D8p4W89h8sX+V1imaUb693TGqWp3T32IKGfIgy9jkd7GM7YCa
# 2xulWfQ6E1xZtYNEX/ewGnp9ZeHPsNwwviJMBZL4xVd40uPWUnOJUoSiugaz0yWL
# ODRtQxs5qU6E58KKmfHwJotl5WZ7nIQuDT0mWjwEx7zSM7fs9Tx6N+Q/3+49qTtU
# vAQsrEAxwmzOTJ6Jp6uWmHCgrHW4dHM3ITpvG5Ipy62KyqYovk5O6cC+040Si15K
# JpuQ9VJnbPvqYqfMB9nEKX/d2rd1Q3DiuDexMKCCQdJGpOqUsxLuCOuFOoGbO7Uv
# 3RjUpY39jkkp0a+yls6tN85fJe+Y8voTnbPU1knpy24wUFBkfenBa+pRFHwCBB1Q
# tS+vGNRhsceP3kSPNrrfN2sRzFYsNfrFaWz8YOdU254qNZQfd9O/VjxZ2Gjr3xgA
# NHtM3HxfzPYF6/pKK8EE4dj66qKKtm2DTL1KFCg/OYJyfrdLJq1q2/HXntgr2GVw
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG6AwghucAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQNNx9NUvr3/upE1qpMKnFzQjGikKACarrzlMjzEIeYAJy45iBWNRWVI5
# QyEvmaHrLWjz/McYTcA/CpyzKYvSGDcwDQYJKoZIhvcNAQEBBQAEggGAaIgVb48i
# wwlDu+0jK0z8A10bxrMeyUkmI1vcsVyteCWiZfCBZqbUJwulig1dPANzkh68XD+U
# JQvwEd52VYdBiJBn0s94lFUk6Fsl1fwX+0szzCKWN+ujae5VoUXvAkGfmhdu1Fa9
# 0m2QEoNbCI2RyBiwx43L1yD285VGwp/i55NikFoKbZI6XVBuqQYQXlhpPWYpjV4P
# FuDvhB+6ine7/K95uzrWNFgJLnwX7XluATWrCmR8ZdWi6W0x1IgioCDoIKD9XTfZ
# C5SNj6BoDx3oMJPvaCtOJ/fEdRqLvgsNjjVf931sed7fgHbFITW8Kx09ljjxV/7P
# GSqRUGRHFiGjc/adQgvz8flVDB9zCq4RYXdMJidXJBHW9E0oaQpAr4rLDpuuks0b
# p08k55qvP8Qa5MMzaJ8EMMR9MjtEbiWRE+ui9cydysxtoXub+e2S+UOAscjTmpkX
# /QF9COGWksJZEd1OcVjUSyETsXQJXBrJ44j3r7gKJH50TAhvYUI9460voYIY6TCC
# GOUGCisGAQQBgjcDAwExghjVMIIY0QYJKoZIhvcNAQcCoIIYwjCCGL4CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQgGCyqGSIb3DQEJEAEEoIH4BIH1MIHyAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMJIp5HBgvGCpAayxH2oJrBPc0RkRW74Y
# Uwpx+AhqvG6wi6e2G/eRjHDJF0zonhSbrgIVALyOCVwapu8FwjXgDtnF1StvfqoG
# GA8yMDI1MDUxNTIyMjkzNFqgdqR0MHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5X
# ZXN0IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQD
# EydTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzagghMEMIIG
# YjCCBMqgAwIBAgIRAKQpO24e3denNAiHrXpOtyQwDQYJKoZIhvcNAQEMBQAwVTEL
# MAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMj
# U2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjUwMzI3MDAw
# MDAwWhcNMzYwMzIxMjM1OTU5WjByMQswCQYDVQQGEwJHQjEXMBUGA1UECBMOV2Vz
# dCBZb3Jrc2hpcmUxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMn
# U2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM2MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA04SV9G6kU3jyPRBLeBIHPNyUgVNnYayf
# sGOyYEXrn3+SkDYTLs1crcw/ol2swE1TzB2aR/5JIjKNf75QBha2Ddj+4NEPKDxH
# Ed4dEn7RTWMcTIfm492TW22I8LfH+A7Ehz0/safc6BbsNBzjHTt7FngNfhfJoYOr
# kugSaT8F0IzUh6VUwoHdYDpiln9dh0n0m545d5A5tJD92iFAIbKHQWGbCQNYplqp
# AFasHBn77OqW37P9BhOASdmjp3IijYiFdcA0WQIe60vzvrk0HG+iVcwVZjz+t5Oc
# XGTcxqOAzk1frDNZ1aw8nFhGEvG0ktJQknnJZE3D40GofV7O8WzgaAnZmoUn4PCp
# vH36vD4XaAF2CjiPsJWiY/j2xLsJuqx3JtuI4akH0MmGzlBUylhXvdNVXcjAuIEc
# EQKtOBR9lU4wXQpISrbOT8ux+96GzBq8TdbhoFcmYaOBZKlwPP7pOp5Mzx/UMhyB
# A93PQhiCdPfIVOCINsUY4U23p4KJ3F1HqP3H6Slw3lHACnLilGETXRg5X/Fp8G8q
# lG5Y+M49ZEGUp2bneRLZoyHTyynHvFISpefhBCV0KdRZHPcuSL5OAGWnBjAlRtHv
# sMBrI3AAA0Tu1oGvPa/4yeeiAyu+9y3SLC98gDVbySnXnkujjhIh+oaatsk/oyf5
# R2vcxHahajMCAwEAAaOCAY4wggGKMB8GA1UdIwQYMBaAFF9Y7UwxeqJhQo1SgLqz
# YZcZojKbMB0GA1UdDgQWBBSIYYyhKjdkgShgoZsx0Iz9LALOTzAOBgNVHQ8BAf8E
# BAMCBsAwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBKBgNV
# HSAEQzBBMDUGDCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRwczovL3Nl
# Y3RpZ28uY29tL0NQUzAIBgZngQwBBAIwSgYDVR0fBEMwQTA/oD2gO4Y5aHR0cDov
# L2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYu
# Y3JsMHoGCCsGAQUFBwEBBG4wbDBFBggrBgEFBQcwAoY5aHR0cDovL2NydC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3J0MCMGCCsG
# AQUFBzABhhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOC
# AYEAAoE+pIZyUSH5ZakuPVKK4eWbzEsTRJOEjbIu6r7vmzXXLpJx4FyGmcqnFZoa
# 1dzx3JrUCrdG5b//LfAxOGy9Ph9JtrYChJaVHrusDh9NgYwiGDOhyyJ2zRy3+kdq
# hwtUlLCdNjFjakTSE+hkC9F5ty1uxOoQ2ZkfI5WM4WXA3ZHcNHB4V42zi7Jk3ktE
# nkSdViVxM6rduXW0jmmiu71ZpBFZDh7Kdens+PQXPgMqvzodgQJEkxaION5XRCoB
# xAwWwiMm2thPDuZTzWp/gUFzi7izCmEt4pE3Kf0MOt3ccgwn4Kl2FIcQaV55nkjv
# 1gODcHcD9+ZVjYZoyKTVWb4VqMQy/j8Q3aaYd/jOQ66Fhk3NWbg2tYl5jhQCuIsE
# 55Vg4N0DUbEWvXJxtxQQaVR5xzhEI+BjJKzh3TQ026JxHhr2fuJ0mV68AluFr9qs
# hgwS5SpN5FFtaSEnAwqZv3IS+mlG50rK7W3qXbWwi4hmpylUfygtYLEdLQukNEX1
# jiOKMIIGFDCCA/ygAwIBAgIQeiOu2lNplg+RyD5c9MfjPzANBgkqhkiG9w0BAQwF
# ADBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYD
# VQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MB4XDTIx
# MDMyMjAwMDAwMFoXDTM2MDMyMTIzNTk1OVowVTELMAkGA1UEBhMCR0IxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGlt
# ZSBTdGFtcGluZyBDQSBSMzYwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIB
# gQDNmNhDQatugivs9jN+JjTkiYzT7yISgFQ+7yavjA6Bg+OiIjPm/N/t3nC7wYUr
# UlY3mFyI32t2o6Ft3EtxJXCc5MmZQZ8AxCbh5c6WzeJDB9qkQVa46xiYEpc81KnB
# kAWgsaXnLURoYZzksHIzzCNxtIXnb9njZholGw9djnjkTdAA83abEOHQ4ujOGIaB
# hPXG2NdV8TNgFWZ9BojlAvflxNMCOwkCnzlH4oCw5+4v1nssWeN1y4+RlaOywwRM
# Ui54fr2vFsU5QPrgb6tSjvEUh1EC4M29YGy/SIYM8ZpHadmVjbi3Pl8hJiTWw9ji
# CKv31pcAaeijS9fc6R7DgyyLIGflmdQMwrNRxCulVq8ZpysiSYNi79tw5RHWZUEh
# nRfs/hsp/fwkXsynu1jcsUX+HuG8FLa2BNheUPtOcgw+vHJcJ8HnJCrcUWhdFczf
# 8O+pDiyGhVYX+bDDP3GhGS7TmKmGnbZ9N+MpEhWmbiAVPbgkqykSkzyYVr15OApZ
# YK8CAwEAAaOCAVwwggFYMB8GA1UdIwQYMBaAFPZ3at0//QET/xahbIICL9AKPRQl
# MB0GA1UdDgQWBBRfWO1MMXqiYUKNUoC6s2GXGaIymzAOBgNVHQ8BAf8EBAMCAYYw
# EgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAE
# CjAIMAYGBFUdIAAwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nUm9vdFI0Ni5jcmwwfAYIKwYB
# BQUHAQEEcDBuMEcGCCsGAQUFBzAChjtodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LnA3YzAjBggrBgEFBQcwAYYX
# aHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBABLXeyCt
# DjVYDJ6BHSVY/UwtZ3Svx2ImIfZVVGnGoUaGdltoX4hDskBMZx5NY5L6SCcwDMZh
# HOmbyMhyOVJDwm1yrKYqGDHWzpwVkFJ+996jKKAXyIIaUf5JVKjccev3w16mNIUl
# NTkpJEor7edVJZiRJVCAmWAaHcw9zP0hY3gj+fWp8MbOocI9Zn78xvm9XKGBp6rE
# s9sEiq/pwzvg2/KjXE2yWUQIkms6+yslCRqNXPjEnBnxuUB1fm6bPAV+Tsr/Qrd+
# mOCJemo06ldon4pJFbQd0TQVIMLv5koklInHvyaf6vATJP4DfPtKzSBPkKlOtyaF
# TAjD2Nu+di5hErEVVaMqSVbfPzd6kNXOhYm23EWm6N2s2ZHCHVhlUgHaC4ACMRCg
# XjYfQEDtYEK54dUwPJXV7icz0rgCzs9VI29DwsjVZFpO4ZIVR33LwXyPDbYFkLqY
# mgHjR3tKVkhh9qKV2WCmBuC27pIOx6TYvyqiYbntinmpOqh/QPAnhDgexKG9GX/n
# 1PggkGi9HCapZp8fRwg8RftwS21Ln61euBG0yONM6noD2XQPrFwpm3GcuqJMf0o8
# LLrFkSLRQNwxPDDkWXhW+gZswbaiie5fd/W2ygcto78XCSPfFWveUOSZ5SqK95tB
# O8aTHmEa4lpJVD7HrTEn9jb1EGvxOb1cnn0CMIIGgjCCBGqgAwIBAgIQNsKwvXwb
# Ouejs902y8l1aDANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVU
# aGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2Vy
# dGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMjEwMzIyMDAwMDAwWhcNMzgwMTE4MjM1
# OTU5WjBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4w
# LAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAiJ3YuUVnnR3d6LkmgZpUVMB8
# SQWbzFoVD9mUEES0QUCBdxSZqdTkdizICFNeINCSJS+lV1ipnW5ihkQyC0cRLWXU
# JzodqpnMRs46npiJPHrfLBOifjfhpdXJ2aHHsPHggGsCi7uE0awqKggE/LkYw3sq
# aBia67h/3awoqNvGqiFRJ+OTWYmUCO2GAXsePHi+/JUNAax3kpqstbl3vcTdOGht
# KShvZIvjwulRH87rbukNyHGWX5tNK/WABKf+Gnoi4cmisS7oSimgHUI0Wn/4elNd
# 40BFdSZ1EwpuddZ+Wr7+Dfo0lcHflm/FDDrOJ3rWqauUP8hsokDoI7D/yUVI9DAE
# /WK3Jl3C4LKwIpn1mNzMyptRwsXKrop06m7NUNHdlTDEMovXAIDGAvYynPt5lutv
# 8lZeI5w3MOlCybAZDpK3Dy1MKo+6aEtE9vtiTMzz/o2dYfdP0KWZwZIXbYsTIlg1
# YIetCpi5s14qiXOpRsKqFKqav9R1R5vj3NgevsAsvxsAnI8Oa5s2oy25qhsoBIGo
# /zi6GpxFj+mOdh35Xn91y72J4RGOJEoqzEIbW3q0b2iPuWLA911cRxgY5SJYubvj
# ay3nSMbBPPFsyl6mY4/WYucmyS9lo3l7jk27MAe145GWxK4O3m3gEFEIkv7kRmef
# DR7Oe2T1HxAnICQvr9sCAwEAAaOCARYwggESMB8GA1UdIwQYMBaAFFN5v1qqK0rP
# VIDh2JvAnfKyA2bLMB0GA1UdDgQWBBT2d2rdP/0BE/8WoWyCAi/QCj0UJTAOBgNV
# HQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEFBQcD
# CDARBgNVHSAECjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2Ny
# bC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3Jp
# dHkuY3JsMDUGCCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3Au
# dXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEADr5lQe1oRLjlocXUEYfk
# tzsljOt+2sgXke3Y8UPEooU5y39rAARaAdAxUeiX1ktLJ3+lgxtoLQhn5cFb3GF2
# SSZRX8ptQ6IvuD3wz/LNHKpQ5nX8hjsDLRhsyeIiJsms9yAWnvdYOdEMq1W61KE9
# JlBkB20XBee6JaXx4UBErc+YuoSb1SxVf7nkNtUjPfcxuFtrQdRMRi/fInV/AobE
# 8Gw/8yBMQKKaHt5eia8ybT8Y/Ffa6HAJyz9gvEOcF1VWXG8OMeM7Vy7Bs6mSIkYe
# YtddU1ux1dQLbEGur18ut97wgGwDiGinCwKPyFO7ApcmVJOtlw9FVJxw/mL1TbyB
# ns4zOgkaXFnnfzg4qbSvnrwyj1NiurMp4pmAWjR+Pb/SIduPnmFzbSN/G8reZCL4
# fvGlvPFk4Uab/JVCSmj59+/mB2Gn6G/UYOy8k60mKcmaAZsEVkhOFuoj4we8CYya
# R9vd9PGZKSinaZIkvVjbH/3nlLb0a7SBIkiRzfPfS9T+JesylbHa1LtRV9U/7m0q
# 7Ma2CQ/t392ioOssXW7oKLdOmMBl14suVFBmbzrt5V5cQPnwtd3UOTpS9oCG+ZZh
# eiIvPgkDmA8FzPsnfXW5qHELB43ET7HHFHeRPRYrMBKjkb8/IN7Po0d0hQoF4TeM
# M+zYAJzoKQnVKOLg8pZVPT8xggSSMIIEjgIBATBqMFUxCzAJBgNVBAYTAkdCMRgw
# FgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3RpZ28gUHVibGlj
# IFRpbWUgU3RhbXBpbmcgQ0EgUjM2AhEApCk7bh7d16c0CIetek63JDANBglghkgB
# ZQMEAgIFAKCCAfkwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3
# DQEJBTEPFw0yNTA1MTUyMjI5MzRaMD8GCSqGSIb3DQEJBDEyBDBfJ0xR9wsFjbto
# piWAu+t2vXmoPNyxtmQ99LYe4iFM/cI6os2L2s8GQiFN021o08UwggF6BgsqhkiG
# 9w0BCRACDDGCAWkwggFlMIIBYTAWBBQ4yRSBEES03GY+k9R0S4FBhqm1sTCBhwQU
# xq5U5HiG8Xw9VRJIjGnDSnr5wt0wbzBbpFkwVzELMAkGA1UEBhMCR0IxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEuMCwGA1UEAxMlU2VjdGlnbyBQdWJsaWMgVGlt
# ZSBTdGFtcGluZyBSb290IFI0NgIQeiOu2lNplg+RyD5c9MfjPzCBvAQUhT1jLZOC
# gmF80JA1xJHeksFC2scwgaMwgY6kgYswgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhl
# IFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRp
# ZmljYXRpb24gQXV0aG9yaXR5AhA2wrC9fBs656Oz3TbLyXVoMA0GCSqGSIb3DQEB
# AQUABIICAI7bu6362O5Hut95LQfb4ps+W96FkVcx8jW5lVs3+B3YKLDWDDy6Doz9
# 7TfcS/T/6Kkop8iwKD9oL1g7sURlhnTtgpR0fra4eq/UE2AcS26ovxfrFM9cG5h4
# 88+8/n7JJxXrKn9NzX2j/a8d+LVK+Sr078ABrgK/K1zLSrcwzBarw7Ijigr0JCzU
# 9pHSRsVBIYhPl7wO97XlOwAATMYm4mWHtpFjrrXVNOu2hn8GNdbxmIBkM7zsGsTf
# nNGG8iT2qhTMxqN1mkhTVCuWkkHi9eRf8lsyi481ScyAP3mbvAszxehQaw+NwoQc
# Ovd1V4U6Am0SxSAi5JkZv7vIFjaRtKEmK2pl4p9sjSWdsLAUg6P34GdhmjtP23iw
# 6he04llFyZnHM234i4TGzNJjGgdeiH4rQwPq+q9gmjn+Zq09M17CZYWoNip84omz
# Yc2mdDgwGMG9QXoQLQ/GMcahlYGTtvbbl+4Dt6AaJbElKboy4gbzy5ULyDI8xBAt
# pSuEpI48xduqB/8Kgo2coYr4Nx8DqGwIwjEPmKBGc3TYbkNbbmVfQtUokHkBmrIE
# 8nbjrVHU9mPgwkEWyXbjTSYtSIZf8HmGGspXPN4J/4CENpdZ3Di+dimGm/PyjhHV
# A0mfWjBI5EfB9dZqm3BEWapDAeS6jJPDnE9vLHAnYI2sz3oe+PEF
# SIG # End signature block
