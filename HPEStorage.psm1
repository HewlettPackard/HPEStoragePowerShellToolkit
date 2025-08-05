# These commands get loaded no matter what.
. $PSScriptRoot\Connection.ps1

Export-ModuleMember -Function       Show-HPESANArrayCommandSet,
        Disconnect-HPESAN,          Connect-HPESAN,         Import-HPESANCertificate
#       Connect-A9API,              Close-A9Connection,      Test-A9Connection,       01 Connect-A9SSH,

if ( $PersistArrayType -like 'MSA' )
    {   write-host "Loading MSA Type Commands"
        . $PSScriptRoot\MSA.scripts\helpers.ps1
        . $PSScriptRoot\MSA.scripts\disk.ps1
        . $PSScriptRoot\MSA.scripts\disk-group.ps1
        . $PSScriptRoot\MSA.scripts\volume.ps1
        . $PSScriptRoot\MSA.scripts\initiator.ps1
        . $PSScriptRoot\MSA.scripts\map.ps1
        . $PSScriptRoot\MSA.scripts\license.ps1     # license, firmware
        . $PSScriptRoot\MSA.scripts\system.ps1      # Contains System, Task, Session,  inquiry
        . $PSScriptRoot\MSA.scripts\alert.ps1       # Contains Alert, Event, Protocols, Audit
        . $PSScriptRoot\MSA.scripts\cache.ps1
        . $PSScriptRoot\MSA.scripts\certificate.ps1 # Contains Certificate, Cipher
        . $PSScriptRoot\MSA.scripts\chap.ps1
        . $PSScriptRoot\MSA.scripts\pool.ps1
        . $PSScriptRoot\MSA.scripts\port.ps1
        . $PSScriptRoot\MSA.scripts\controller.ps1 
        . $PSScriptRoot\MSA.scripts\network.ps1     # DNS, EMAIL, Session, IPv6
        . $PSScriptRoot\MSA.scripts\host.ps1 
        . $PSScriptRoot\MSA.scripts\hardware.ps1    # Contains  Enclosure, Fan, Power-Supply, Fru
        . $PSScriptRoot\MSA.scripts\iscsi.ps1 

        Export-ModuleMember -Function Connect-MSAGroup, Invoke-MSAStorageRestAPI,
            Get-MSADisk,        Get-MSADiskParameter,   Get-MSADiskStatistic,
            Get-MSADiskGroup,   Get-MSADiskGroupStatistic,
            Get-MSAVolume, 
            Get-MSAInitiator,
            Get-MSAMap,
            Get-MSALicense,     Get-MSAFirmware,    Get-MSAFirmwareUpdate,
            Get-MSASystem,      Get-MSATask,    Get-MSAEnclosure,   Get-MSAExpander, Get-MSAFan,  Get-MSAPowerSupply, Get-MSAFru, Get-MSAAdvancedSetting, Get-MSAInquiry,
            Get-MSAController,  Get-MSAControllerDate, Get-MSAControllerStatistic, 
            Get-MSAAlert,       Get-MSAEvent,   Get-MSAAuditLog,    Get-MSAProtocol,    Get-MSAAlertConditionHistory, Get-MSAMetric,
            Get-MSACache,
            Get-MSACertificate, Get-MSACipher,
            Get-MSAChap,
            Get-MSAPool,        Get-MSAPoolStatistics,
            Get-MSAPort,
            Get-MSANetwork,     Get-MSADNS,         Get-MSAEmail,   Get-MSASession,     Get-MSAIPv6,    Get-MSAIPv6Network, Get-MSALDAP, Get-MSANTP,
            Get-MSAHost,        Get-MSAHostGroup,   Get-MSAHostPhyStatistic, Get-MSAHostPortStatistic,
            Get-MSAiSCSI
    }

if ( $PersistArrayType -like 'Nimble' -or $PersistArrayType -like 'Alletra6000' )
    {   write-host "Loading Nimble or Alletra6000 or Alletra5000 Type Commands"
        . $PSScriptRoot\NS.scripts\helpers.ps1
        . $PSScriptRoot\NS.scripts\AccessControlRecord.ps1
        . $PSScriptRoot\NS.scripts\ChapUser.ps1
        . $PSScriptRoot\NS.scripts\Pool.ps1
        . $PSScriptRoot\NS.scripts\ProtectionTemplate.ps1
        . $PSScriptRoot\NS.scripts\Volume.ps1
        . $PSScriptRoot\NS.scripts\SpaceDomain.ps1
        . $PSScriptRoot\NS.scripts\Group.ps1
        . $PSScriptRoot\NS.scripts\Host.ps1
        . $PSScriptRoot\NS.scripts\ReplicationPartner.ps1
        . $PSScriptRoot\NS.scripts\TrustedOauthIssuer.ps1
        . $PSScriptRoot\NS.scripts\MasterKey.ps1
        . $PSScriptRoot\NS.scripts\Event.ps1
        . $PSScriptRoot\NS.scripts\ApplicationServer.ps1
        . $PSScriptRoot\NS.scripts\FibreChannelPort.ps1
        . $PSScriptRoot\NS.scripts\LdapDomain.ps1
        . $PSScriptRoot\NS.scripts\Initiator.ps1
        . $PSScriptRoot\NS.scripts\PerformancePolicy.ps1
        . $PSScriptRoot\NS.scripts\UserPolicy.ps1
        . $PSScriptRoot\NS.scripts\SnapshotCollection.ps1
        . $PSScriptRoot\NS.scripts\Shelf.ps1
        . $PSScriptRoot\NS.scripts\ProtocolEndpoint.ps1
        . $PSScriptRoot\NS.scripts\FibreChannelInterface.ps1
        . $PSScriptRoot\NS.scripts\FibreChannelSession.ps1
        . $PSScriptRoot\NS.scripts\VolumeCollection.ps1
        . $PSScriptRoot\NS.scripts\Token.ps1
        . $PSScriptRoot\NS.scripts\UserGroup.ps1
        . $PSScriptRoot\NS.scripts\FibreChannelInitiatorAlias.ps1
        . $PSScriptRoot\NS.scripts\InitiatorGroup.ps1
        . $PSScriptRoot\NS.scripts\Snapshot.ps1
        . $PSScriptRoot\NS.scripts\ActiveDirectoryMembership.ps1
        . $PSScriptRoot\NS.scripts\Subnet.ps1
        . $PSScriptRoot\NS.scripts\Folder.ps1
        . $PSScriptRoot\NS.scripts\NetworkConfig.ps1
        . $PSScriptRoot\NS.scripts\Controller.ps1
        . $PSScriptRoot\NS.scripts\ProtectionSchedule.ps1
        . $PSScriptRoot\NS.scripts\ApplicationCategory.ps1
        . $PSScriptRoot\NS.scripts\AuditLog.ps1
        . $PSScriptRoot\NS.scripts\Job.ps1
        . $PSScriptRoot\NS.scripts\Disk.ps1
        . $PSScriptRoot\NS.scripts\NetworkInterface.ps1
        . $PSScriptRoot\NS.scripts\SoftwareVersion.ps1
        . $PSScriptRoot\NS.scripts\FibreChannelConfig.ps1
        . $PSScriptRoot\NS.scripts\User.ps1
        . $PSScriptRoot\NS.scripts\Array.ps1
        . $PSScriptRoot\NS.scripts\Alarm.ps1

        Export-ModuleMember -Function   Test-NS2PasswordFormat,     Test-Ns2Type,      Test-NS2ID,     Connect-NSGroup,    Disconnect-NSGroup,     
            Get-NSAccessControlRecord,  New-NSAccessControlRecord,                              Remove-NSAccessControlRecord,   
            Get-NSChapUser,             New-NSChapUser,             Set-NSChapUser,             Remove-NSChapUser,    
            Get-NSPool,                 New-NSPool,                 Set-NSPool,                 Remove-NSPool,              Merge-NSPool,       Invoke-NSPoolDeDupe,    
            Get-NSProtectionTemplate,   New-NSProtectionTemplate,   Set-NSProtectionTemplate,   Remove-NSProtectionTemplate,    
            Get-NSVolume,               New-NSVolume,               Set-NSVolume,               Remove-NSVolume,            Restore-NSVolume,    
            Move-NSVolume,              Stop-NSVolumeMove,          Move-NSVolumeBulk,          Set-NSVolumeBulkDeDupe,     Set-NSVolumeBulkOnline,    
            Get-NSSpaceDomain,   
            Get-NSGroup,                Set-NSGroup,                Reset-NSGroup,              Stop-NSGroup,               Test-NSGroupAlert,    
            Test-NSGroupSoftwareUpdate, Start-NSGroupSoftwareUpdate,Start-NSGroupSoftwareDownload,Stop-NSGroupSoftwareDownload,Resume-NSGroupSoftwareUpdate,    
            Get-NSGroupDiscoveredList,    Test-NSGroupMerge,   Merge-NSGroup,    Get-NSGroupgetEULA,    Test-NSGroupMigrate,    Move-NSGroup,   
            Get-NSGroupTimeZoneList,    
            Get-NSReplicationPartner,   New-NSReplicationPartner,   Set-NSReplicationPartner,   Remove-NSReplicationPartner,    Suspend-NSReplicationPartner,    Resume-NSReplicationPartner,    Test-NSReplicationPartner,   
            Get-NSTrustedOauthIssuer,   New-NSTrustedOauthIssuer,   New-NSMasterKey,            Get-NSMasterKey,                Set-NSMasterKey,    
            Remove-NSMasterKey,         Clear-NSMasterKeyInactive,  Get-NSEvent,   
            New-NSApplicationServer,    Get-NSApplicationServer,    Set-NSApplicationServer,    Remove-NSApplicationServer,   
            Get-NSFibreChannelPort,     New-NSLdapDomain,           Get-NSLdapDomain,           Set-NSLdapDomain,   
            Remove-NSLdapDomain,        Test-NSLdapDomainUser,      Test-NSLdapDomainGroup,     Test-NSLdapDomain,   New-NSInitiator,    Get-NSInitiator,    Remove-NSInitiator,   
            New-NSPerformancePolicy,    Get-NSPerformancePolicy,    Set-NSPerformancePolicy,    Remove-NSPerformancePolicy,   
            Get-NSUserPolicy,           Set-NSUserPolicy,           New-NSSnapshotCollection,   
            Get-NSSnapshotCollection,   Set-NSSnapshotCollection,   Remove-NSSnapshotCollection,Get-NSShelf,   
            Set-NSShelf,                Show-NSShelf,               Remove-NSShelf,             Get-NSProtocolEndpoint,   
            Get-NSFibreChannelInterface,Set-NSFibreChannelInterface,
            Get-NSFibreChannelSession,  New-NSVolumeCollection,   
            Get-NSVolumeCollection,     Set-NSVolumeCollection,     Remove-NSVolumeCollection,  Invoke-NSVolumeCollectionPromote,   
            Invoke-NSVolumeCollectionDemote,                        Start-NSVolumeCollectionHandover,    Stop-NSVolumeCollectionHandover,    Test-NSVolumeCollection,   
            Get-NSToken,                New-NSToken,                Remove-NSToken,             
            Get-NSTokenUserDetails,   
            New-NSUserGroup,            Get-NSUserGroup,    Set-NSUserGroup,    Remove-NSUserGroup,   
            New-NSSubscription,         Get-NSSubscription,    Set-NSSubscription,    Remove-NSSubscription,   
            Get-NSFibreChannelInitiatorAlias,        
            Get-NSInitiatorGroup,       Set-NSInitiatorGroup,       New-NSInitiatorGroup,       Remove-NSInitiatorGroup,    
            Get-NSSnapshot,             Set-NSSnapshot,             New-NSSnapshotBulk,         Remove-NSSnapshot, 
            Get-NSActiveDirectoryMembership,Set-NSActiveDirectoryMembership,New-NSActiveDirectoryMembership,Remove-NSActiveDirectoryMembership,   
            Get-NSFolder,               New-NSFolder,               Set-NSFolder,               Remove-NSFolder,   
            Resolve-NSInitiatorGroupMerge,    Test-NSInitiatorGroupLunAvailability,    New-NSSnapshot,   
            Test-NSActiveDirectoryMembership,                       Test-NSActiveDirectoryMembershipUser,   Test-NSActiveDirectoryMembershipGroup,    
            Get-NSSubnet,                              
            Invoke-NSFolderDeDupe,      New-NSNetworkConfig,        Get-NSNetworkConfig,        Set-NSNetworkConfig,   
            Remove-NSNetworkConfig,     Initialize-NSNetworkConfig, Test-NSNetworkConfig,       Get-NSController,   
            Stop-NSController,          Reset-NSController,         New-NSProtectionSchedule,   Get-NSProtectionSchedule,   
            Set-NSProtectionSchedule,   Remove-NSProtectionSchedule,Get-NSApplicationCategory,  Get-NSAuditLog,   
            Get-NSJob,                  Get-NSDisk,   Set-NSDisk,   Get-NSNetworkInterface,   
            Get-NSSoftwareVersion,      
            Get-NSFibreChannelConfig,   Update-NSFibreChannelConfig,Update-NSFibreChannelConfig,   
            New-NSUser,                 Get-NSUser,                 Set-NSUser,                 Remove-NSUser,   
            Unlock-NSUser,                              
            Get-NSArray,                Set-NSArray,                New-NSArray,                Remove-NSArray,             Invoke-NSArrayFailover,     Stop-NSArray,      Reset-NSArray,   
            Get-NSAlarm,                Set-NSAlarm,                                            Remove-NSAlarm,             Clear-NSAlarm,              Undo-NSAlarm,
            Get-NSHostHyperVStorage,    Get-NSHostVolume,           Get-NSHostInitiator,        New-NSHostInitiatorGroup,
            Invoke-NSHostVMFailoverSetPreMigration
    }

if ( ($PersistArrayType -like 'Primera') -or ($PersistArrayType -like 'Alletra9000') -or ($PersistArrayType -like 'AlletraMP-B10000') -or ($PersistArrayType -like '3Par') )
    {   if ( $LoadA9CLI -or $LoadA9SSH )
        {   # Load the Global scripts (API + CLI)
            . $PSScriptRoot\A9.GLOBAL\VS-Functions.ps1
            Export-ModuleMember -Function Invoke-A9CLICommand , Invoke-A9API
            . $PSScriptRoot\A9.GLOBAL\VVCommands.ps1
            Export-ModuleMember -Function Get-A9Vv, Remove-A9Vv, Remove-A9VvSet, Update-A9Vv, Get-A9vLun, Remove-A9vLun, New-A9vLun
            . $PSScriptRoot\A9.GLOBAL\Host.ps1
            Export-ModuleMember -Function Get-A9HostSet, Get-A9Host
            . $PSScriptRoot\A9.GLOBAL\Task.ps1
            Export-ModuleMember -Function  Get-A9Task, Stop-A9Task 
            . $PSScriptRoot\A9.GLOBAL\Disk.ps1
            Export-ModuleMember -Function Get-A9Disk
            . $PSScriptRoot\A9.GLOBAL\CPGManagement.ps1
            Export-ModuleMember -Function Remove-A9CPG, Get-A9CPG, New-A9Cpg, Set-A9Cpg , Compress-A9CPG 
            . $PSScriptRoot\A9.GLOBAL\System.ps1
            Export-ModuleMember -Function Get-A9System
        }
        if ( $LoadA9CLI )
        {   # Load the CLI specific Commnands
            . $PSScriptRoot\A9.CLI\Cage.ps1
            Export-ModuleMember -Function Find-A9Cage, Get-A9Cage, Set-A9Cage
            . $PSScriptRoot\A9.CLI\Certificate.ps1
            Export-ModuleMember -Function Get-A9Cert, Import-A9Cert, New-A9Cert, Remove-A9Cert
            . $PSScriptRoot\A9.CLI\ConfigWebServicesAPI.ps1
            Export-ModuleMember -Function Get-A9WsApi, Get-A9WsapiSession, Remove-A9WsapiSession, Set-A9Wsapi, Start-A9Wsapi, Stop-A9Wsapi
            . $PSScriptRoot\A9.CLI\CimManagement.ps1
            Export-ModuleMember -Function Get-A9CIM, Start-A9CIM, Set-A9CIM, Stop-A9CIM
            . $PSScriptRoot\A9.CLI\Disk.ps1 
            Export-ModuleMember -Function Approve-A9Disk, Remove-A9Disk, Set-A9Disk, Switch-A9Disk, Test-A9Disk
            . $PSScriptRoot\A9.CLI\DomainManagement.ps1
            Export-ModuleMember -Function Get-A9Domain, Get-A9DomainSet, Move-A9Domain, New-A9Domain, New-A9DomainSet, Remove-A9Domain, Remove-A9DomainSet, Set-A9Domain, Update-A9Domain, Update-A9DomainSet
            . $PSScriptRoot\A9.CLI\Flashcache.ps1
            Export-ModuleMember -Function New-A9FlashCache_CLI,  Set-A9FlashCache_CLI, Remove-A9FlashCache_CLI
            . $PSScriptRoot\A9.CLI\HealthAndAlertManagement.ps1
            Export-ModuleMember -Function Get-A9Alert, Get-A9EventLog_CLI, Get-A9Health, Remove-A9Alerts, Set-A9Alert
            . $PSScriptRoot\A9.CLI\HostManagement.ps1
            Export-ModuleMember -Function New-A9Host, Set-A9HostTargetZoneingWWN, Update-A9Host , Remove-A9Host, Get-A9HostWithFilter ,  Get-A9HostPersona 
            . $PSScriptRoot\A9.CLI\Internal.ps1
            Export-ModuleMember -Function Get-A9FcPorts, Get-A9FcPortsToCsv, Test-A9CLIObject 
            . $PSScriptRoot\A9.CLI\InventoryManagement.ps1
            Export-ModuleMember -Function Get-A9Inventory
            . $PSScriptRoot\A9.CLI\MaintenanceMode.ps1
            Export-ModuleMember -Function Get-A9Maintenance, New-A9Maintenance, Set-A9Maintenance
            . $PSScriptRoot\A9.CLI\NodeSubsystemManagement.ps1
            Export-ModuleMember -Function Find-A9Node,  Find-A9System, Ping-A9RCIPPorts, Set-A9Battery, Set-A9FCPorts, Set-A9HostPorts, Set-A9NodeProperties, Set-A9NodesDate, Set-A9SysMgr, Show-A9Battery, Show-A9EEProm,
                Get-A9SystemInformation, Show-A9FCOEStatistics, Show-A9Firmwaredb, Show-A9TOCGen, Show-A9iSCSISessionStatistics, Show-A9iSCSIStatistics, Show-A9NetworkDetail, Show-A9NodeEnvironmentStatus, Show-A9iSCSISession,
                Show-A9iSCSISession, Show-A9NodeProperties, Show-A9Portdevices_CLI, Show-A9PortISNS, Get-A9SystemManager, Show-A9SystemResourcesSummary, Start-A9NodeRescue, Get-A9HostPorts_CLI, Get-A9Node, Get-A9Target,
                Show-A9PortARP, Show-A9UnrecognizedTargetsInfo, Test-A9FCLoopback         
            . $PSScriptRoot\A9.CLI\PerformanceManagement.ps1
            Export-ModuleMember -Function Compress-A9VV_CLI, Get-A9HistogramChunklet, Get-A9HistogramLogicalDisk, Get-A9HistogramPhysicalDisk,Get-A9HistogramPort,Get-A9HistogramRemoteCopyVv,Get-A9HistogramVLun,
                Get-A9HistogramVv,Get-A9StatisticsChunklet,Get-A9StatCacheMemoryPages,Get-A9CPUStatisticalDataReports_CLI, Get-A9LogicalDiskStatisticsReports_CLI,Get-A9StatisticLinkUtilization,Get-APhysicalDiskStatisticsReports_CLI,
                Get-A9PortStatisticsReports_CLI,Get-A9RCopyStatisticalReports_CLI, Get-A9vLunStatisticsReports_CLI, Get-A9VvStatisticsReports,Set-A9StatisticsInUseChunklets,Set-A9StatisticsCollectionPhysicalDiskChunklets,
                Measure-A9System,Optimize-A9PhysicalDisk
            . $PSScriptRoot\A9.CLI\Replication.ps1
            Export-ModuleMember -Function New-A9RCopyGroup_CLI,New-A9RCopyGroupCPG_CLI,New-A9RCopyTarge_CLI,Add-A9RCopyTarget_CLI,
                Add-A9RCopyVv_CLI,Add-A9RCopyLink_CLI,Disable-A9RCopylink_CLI,Disable-A9RCopyTarget_CLI,Disable-A9RCopyVv_CLI,Get-A9RCopy_CLI,
                Get-A9StatRCopy_CLI,Remove-A9RCopyGroup_CLI,Remove-A9RCopyTarget_CLI,Remove-A9RCopyTargetFromGroup_CLI,Set-A9RCopyGroupPeriod_CLI,
                Set-A9RCopyGroupPol_CLI,Set-A9RCopyTarget_CLI,Set-A9RCopyTargetName_CLI,Set-A9RCopyTargetPol_CLI,Set-A9RCopyTargetWitness_CLI,
                Show-A9RCopyTransport_CLI,Start-A9RCopy_CLI,Start-A9RCopyGroup_CLI,Stop-A9RCopy_CLI,Stop-A9RCopyGroup_CLI,Sync-A9RCopy_CLI,Test-A9RCopyLink_CLI,
                Remove-A9RCopyVvFromGroup,Sync-A9RecoverDRRcopyGroup,Set-A9AdmitRCopyHost,Remove-A9RCopyHost
            . $PSScriptRoot\A9.CLI\ServiceCommands.ps1
            Export-ModuleMember -Function Add-A9Hardware,Get-A9SystemPatch,Get-A9Version ,Update-A9Cage,Reset-A9SystemNode,Set-A9Magazines,
            Set-A9ServiceCage, Set-A9ServiceNodes,Get-A9ServiceNodes, Reset-A9System ,Update-A9PdFirmware,Get-A9ResetReason,Set-A9Security,Get-A9SecurityFIPS
            . $PSScriptRoot\A9.CLI\SnapShotManagement.ps1
            Export-ModuleMember -Function New-A9GroupSnapVolume_CLI,New-A9GroupVvCopy_CLI,New-A9SnapVolume_CLI,New-A9VvCopy_CLI,Push-A9GroupSnapVolume,
            Push-A9SnapVolume,Push-A9VvCopy,Set-A9VvSnapshot
            . $PSScriptRoot\A9.CLI\Sparing.ps1
            Export-ModuleMember -Function Get-A9Spare,New-A9Spare,Move-A9Chunklet,Move-A9ChunkletToSpare,Move-A9PhyscialDisk,Move-A9PhysicalDiskToSpare,
            Move-A9RelocPhysicalDisk, Remove-A9Spare
            . $PSScriptRoot\A9.CLI\StorageFederation.ps1
            Export-ModuleMember -Function  Join-A9Federation,New-A9Federation,Set-A9Federation, Remove-A9Federation,Show-A9Federation
            . $PSScriptRoot\A9.CLI\SystemManager.ps1
            Export-ModuleMember -Function Get-A9Encryption,Measure-A9Upgrade,Optimize-A9LogicalDisk,Optimize-A9Node
            . $PSScriptRoot\A9.CLI\SystemReporter.ps1
            Export-ModuleMember -Function Get-A9SystemReporter,Start-A9SystemReporter,Stop-A9SSystemReporter,Get-A9SystemReportCpgSpace,
                Get-A9SystemReportAlertCrit,Get-A9SystemReportHistogramLogicalDisk,Get-A9SystemReportRHistogramPhysicalDisk,Get-A9SystemReportHistogramPort,
                Get-A9SystemReportHistogramVLun,Get-A9SystemReportLogicalDiskSpace,Get-A9SystemReporterPhysicalDiskSpace,Get-A9SystemReporterRegionIODensity,
                Get-A9SystemReporterStatCache,Get-A9SystemReporterStatCacheMemoryPages,Get-A9SystemReporterStatCPU, Set-A9SystemReporterAlertCrit,
                Remove-A9SystemReporterAlertCrit,New-A9SystemReporterAlertCrit, Get-A9SystemReporterStatPort,Get-A9SystemReporterStatPhysicalDisk,
                Get-A9SystemReporterStatLD,Get-A9SystemReporterStatfssnapshot, Get-A9SystemReporterStatlink,Get-A9SystemReporterStatqos,
                Get-A9SystemReporterStatrcvv,Get-A9SystemReporterStatVLun,Get-A9SystemReporterVvSpace,Show-A9SystemReporterStatIscsi,Show-A9SystemReporterStatIscsiSession
            . $PSScriptRoot\A9.CLI\TaskManagement.ps1
            Export-ModuleMember -Function Remove-A9Task, Wait-A9Task, Set-A9Task
            . $PSScriptRoot\A9.CLI\UserManagement.ps1
            Export-ModuleMember -Function Get-A9UserConnection
            . $PSScriptRoot\A9.CLI\Vasa.ps1
            Export-ModuleMember -Function Show-A9VVolStorageContainerVM_CLI, Get-A9VolStorageContainer_CLI, Set-A9VVolStorageContainer
            . $PSScriptRoot\A9.CLI\VirtualVolumeManagement.ps1
            Export-ModuleMember -Function Add-A9Vv, Compress-A9LogicalDisk,Confirm-A9LogicalDisk,Get-A9LogicalDisk, Get-A9LogicalDiskChunklet,
            Get-A9Space,Get-A9VvList,Get-A9VvSet,Import-A9Vv,New-A9Vv_CLI,New-A9VvSet_CLI,Remove-A9LogicalDisk,Remove-A9VvLogicalDiskCpgTemplates,
            Set-A9Template_CLI,Set-A9VvSpace_CLI,Show-A9LdMappingToVvs_CLI,Show-A9VvScsiReservations,Show-A9Template,Show-A9VvMappedToPD,Show-A9VvMapping,
            Show-A9VvpDistribution, Start-A9LD_CLI,Start-A9Vv_CLI,Test-A9Vv_CLI, Update-A9SnapSpace_CLI,Update-A9VvProperties_CLI,Update-A9VvSetProperties_CLI,
            Set-A9Host_CLI,Show-A9Peer_CLI,Resize-A9Vv
        }
        if ( $LoadA9API )
        {   # Load the API specific Commands
            . $PSScriptRoot\A9.scripts\AvailableSpace.ps1 
            Export-ModuleMember -Function Get-A9CapacityInfo
            . $PSScriptRoot\A9.scripts\CopyOperations.ps1 
            Export-ModuleMember -Function New-a9VvSnapshot,New-A9VvListGroupSnapshot,New-A9VvPhysicalCopy,Reset-A9PhysicalCopy,Stop-A9PhysicalCopy,Move-A9VirtualCopy,
            Move-A9VvSetVirtualCopy,New-A9VvSetSnapshot,New-A9VvSetPhysicalCopy,Reset-A9VvSetPhysicalCopy ,Stop-A9VvSetPhysicalCopy,Update-A9VvOrVvSets 
            . $PSScriptRoot\A9.scripts\FlashCacheOperations.ps1 
            Export-ModuleMember -Function Set-A9FlashCache,New-A9FlashCache,Remove-A9FlashCache,Get-FlashCache,Set-A9VvSetFlashCachePolicy
            . $PSScriptRoot\A9.scripts\HostManagement.ps1
            Export-ModuleMember -Function New-A9Host,Set-A9HostTargetZoneingWWN,Update-A9Host ,Remove-A9Host,Get-A9HostWithFilter,Get-A9HostPersona 
            . $PSScriptRoot\A9.scripts\HostSetsAndVirtualVolumeSets.ps1 
            Export-ModuleMember -Function New-A9HostSet ,Update-A9HostSet , Remove-A9HostSet,New-A9VvSet,Update-A9VvSet ,Get-A9VvSet 
            . $PSScriptRoot\A9.scripts\PortsAndSwitches.ps1 
            Export-ModuleMember -Function Get-A9Port ,Get-A9IscsivLans ,Get-A9PortDevices ,Get-A9PortDeviceTDZ ,Get-A9FcSwitches ,Set-A9ISCSIPort ,New-A9IscsivLan ,
                New-A9IscsivLun ,Set-A9IscsivLan,Reset-A9IscsiPort,Remove-A9IscsivLan
            . $PSScriptRoot\A9.scripts\RemoteCopy.ps1
            Export-ModuleMember -Function New-A9RCopyGroup,Start-A9RCopyGroup ,Stop-A9RCopyGroup,Sync-A9RCopyGroup,Remove-A9RCopyGroup,Update-A9RCopyGroup,Update-A9RCopyGroupTarget,
            Restore-A9RCopyGroup,Add-A9VvToRCopyGroup,Remove-A9VvFromRCopyGroup,New-A9RCopyTarget,Update-A9RCopyTarget,Add-A9TargetToRCopyGroup, Remove-A9TargetFromRCopyGroup,
            New-A9SnapRcGroupVv,Get-A9RCopyInfo,Get-A9RCopyTarget,Get-A9RCopyGroup,Get-A9RCopyGroupTarget,Get-A9RCopyGroupVv,Get-A9RCopyLink
            . $PSScriptRoot\A9.scripts\SessionKeysAndWsapiSystemAccess.ps1
            Export-ModuleMember -Function Invoke-A9API 
            . $PSScriptRoot\A9.scripts\StorageVolumes.ps1 
            Export-ModuleMember -Function New-a9Vv,Get-A9VvSpaceDistribution,Resize-a9Vv,Compress-A9Vv
            . $PSScriptRoot\A9.scripts\SystemEvents.ps1
            Export-ModuleMember -Function Open-A9SSE,Get-A9EventLogs
            . $PSScriptRoot\A9.scripts\SystemInformationQueriesAndManagement.ps1 
            Export-ModuleMember -Function Update-A9System,Get-A9Version,Get-A9WSAPIConfigInfo
            . $PSScriptRoot\A9.scripts\SystemReporter.ps1 
            Export-ModuleMember -Function Get-A9CacheMemoryStatisticsDataReports,Get-A9CPGSpaceDataReports,Get-A9CPGStatisticalDataReports,Get-A9CPUStatisticalDataReports,
            Get-A9PDCapacityReports,Get-A9PDStatisticsReports, Get-A9PDSpaceReports,Get-A9PortStatisticsReports, Get-A9QoSStatisticalReports, Get-A9RCopyStatisticalReports,
            Get-A9RCopyVolumeStatisticalReports,Get-A9vLunStatisticsReports ,Get-A9VvSpaceReports
            . $PSScriptRoot\A9.scripts\WsapiUserAndRoleInformation.ps1
            Export-ModuleMember -Function Get-A9Users,Get-A9Roles 
            
        }
        if ( $Load3Par )
            {   # Load the 3PAR specific Commands
                . $PSScriptRoot\A9.GLOBAL\AdaptiveOptimization.ps1
                Export-ModuleMember -Function  Get-A9AdaptiveOptimizationConfig
                if ( $LoadA9API )
                    {   . $PSScriptRoot\A9.scripts\FilePersona.ps1
                        Export-ModuleMember -Function  Get-A9FileServices,                     New-A9FPG,                          Remove-A9FPG, 
                            Get-A9FPG,                  Get-A9FPGReclamationTask,           New-A9VFS,                              Remove-A9VFS,                       Get-A9VFS , 
                            New-A9FileStore,            Update-A9FileStore,                 Remove-A9FileStore,                     Get-A9FileStore ,                   New-A9FileStoreSnapshot, 
                            Remove-A9FileStoreSnapshot, Get-A9FileStoreSnapshot,            New-A9FileShare,                        Remove-A9FileShare ,                Get-A9FileShare, 
                            Get-A9DirPermission ,       New-A9FilePersonaQuota,             Update-A9FilePersonaQuota,              Remove-A9FilePersonaQuota,          Get-A9FilePersonaQuota, 
                            Restore-A9FilePersonaQuota, Group-A9FilePersonaQuota 
                    }
                if ( $LoadA9CLI )
                    {   . $PSScriptRoot\A9.CLI\AdaptiveOptimization.ps1
                        . $PSScriptRoot\A9.CLI\FilePersonaManagement.ps1
                        Export-ModuleMember -Function   New-A9AdaptiveOptimizationConfig,   Remove-A9AdaptiveOptimizationConfig,    Start-A9AdaptiveOptimizationConfig, Update-A9AdaptiveOptimizationConfig, 
                            Get-A9SystemReportAOMoves,  Start-A9FSNDMP,                     Stop-A9FSNDMP,                          Get-A9SRStatfsfpg,                  Get-A9SystemReporterStatfscpu,
                            Get-A9SRStatfsmem,          Get-A9SystemReporterStatfsblock,    Get-A9SystemReporterStatfsav,           Get-A9SRStatfsnet, 
                            Get-A9SRStatfsnfs,          Get-A9SystemReporterStatfssmb
                    }
            }
        

    }
