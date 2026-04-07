# These commands get loaded no matter what.
. $PSScriptRoot\Connection.ps1

Export-ModuleMember -Function       Show-HPESANArrayCommandSet, Connect-A9SSH,
        Disconnect-HPESAN,          Connect-HPESAN,             Import-HPESANCertificate,
        Connect-A9API,              Close-A9Connection,         Test-A9Connection     

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
    {   if ( $LoadA9CLI -or $LoadA9API )
        {   # Load the Global scripts (API + CLI)
            write-verbose "--------------Loaded All CLI and Rest function from Global set"
            . $PSScriptRoot\A9.scripts\VS-Functions.ps1
            Export-ModuleMember -Function   Invoke-A9CLICommand ,     Invoke-A9API
            . $PSScriptRoot\A9.scripts\CPGDisk.ps1
            Export-ModuleMember -Function   Get-A9CPG,              New-A9Cpg,          Set-A9Cpg,          Remove-A9CPG,       Get-A9PhysicalDisk
            . $PSScriptRoot\A9.scripts\CopyOperations.ps1 
            Export-ModuleMember -Function   New-A9Snapshot,         
                                            New-A9VolumeCopy,       Set-A9VolumeCopy,
                                            New-A9VolumeSetCopy,    Set-A9VolumeSetCopy
            . $PSScriptRoot\A9.scripts\Host.ps1
            Export-ModuleMember -Function   Get-A9Host,             Set-A9Host,         New-A9Host,         Remove-A9Host,     Set-A9HostTargetZoneingWWN                             
            . $PSScriptRoot\A9.scripts\HostSet.ps1
            Export-ModuleMember -Function   Get-A9HostSet,          New-A9HostSet ,     Set-A9HostSet ,     Remove-A9HostSet 
            . $PSScriptRoot\A9.scripts\PortSwitch.ps1 
            Export-ModuleMember -Function   Get-A9Port ,            Get-A9PortDevice ,  Get-A9PortDeviceTDZ ,   Get-A9FcSwitch        
            . $PSScriptRoot\A9.scripts\iSCSI.ps1 
            Export-ModuleMember -Function   Get-A9IscsivLan,        Set-A9IscsivLan,    New-A9IscsivLan ,       Remove-A9IscsivLan,    Set-A9ISCSIPort
            . $PSScriptRoot\A9.scripts\RemoteCopy.ps1
            Export-ModuleMember -Function   Get-A9RCopyGroup,       New-A9RCopyGroup,   Set-A9RCopyGroup,      Remove-A9RCopyGroup,
                                            Get-A9RCopyTarget,      New-A9RCopyTarget,  Update-A9RCopyTarget,       
                                            Get-A9RCopyInfo,
                                            Add-A9VvToRCopyGroup,   Remove-A9VvFromRCopyGroup,  Add-A9TargetToRCopyGroup,   Remove-A9TargetFromRCopyGroup,
                                            New-A9SnapRcGroupVv,    Update-A9RCopyGroupTarget  
            . $PSScriptRoot\A9.scripts\System.ps1 
            Export-ModuleMember -Function   Get-A9System,           Set-A9System,           Get-A9WSAPI,          
                                            Get-A9Version,          Get-A9CapacityInfo,     Open-A9SSE,     Get-A9EventLog,
                                            Get-A9Certificate,      Import-A9Certificate      
            . $PSScriptRoot\A9.scripts\SystemReporter.ps1 
            Export-ModuleMember -Function   Get-A9SystemReporterIOPs,   Get-A9SystemReporterSpace,  Get-A9SystemReporterStats
            . $PSScriptRoot\A9.Scripts\Task.ps1
            Export-ModuleMember -Function   Get-A9Task,         Stop-A9Task      
            . $PSScriptRoot\A9.scripts\UserRole.ps1
            Export-ModuleMember -Function   Get-A9User,         Get-A9Role
            . $PSScriptRoot\A9.scripts\Volume.ps1 
            Export-ModuleMember -Function   Get-A9Volume,       New-A9Volume,       Set-A9Volume,       Remove-A9Volume          
            . $PSScriptRoot\A9.scripts\VolumeSet.ps1 
            Export-ModuleMember -Function   Get-A9VolumeSet,    New-A9VolumeSet,    Set-A9VolumeSet,    Remove-A9VolumeSet
            . $PSScriptRoot\A9.scripts\Vlun.ps1
            Export-ModuleMember -Function   Get-A9vLun,         New-A9vLun,         Remove-A9vLun
        }
        if ( $LoadA9CLI )
        {   # Load the CLI specific Commnands
            write-verbose "--------------Loaded All CLI and Rest function from CLI set"
            . $PSScriptRoot\A9.CLI\Cage.ps1
            Export-ModuleMember -Function   Find-A9Cage,    Get-A9Cage,         Set-A9Cage
            . $PSScriptRoot\A9.CLI\Certificate.ps1
            Export-ModuleMember -Function   New-A9Cert,     Remove-A9Cert
            . $PSScriptRoot\A9.CLI\ConfigCIMandAPI.ps1
            Export-ModuleMember -Function   Set-A9Wsapi,    Get-A9CIM,          Set-A9CIM,              Remove-A9WsapiSession
            . $PSScriptRoot\A9.CLI\Disk.ps1 
            Export-ModuleMember -Function   Set-A9PhysicalDisk,         Remove-A9PhysicalDisk,          Get-A9LogicalDisk,      Set-A9LogicalDisk,          Remove-A9LogicalDisk
            . $PSScriptRoot\A9.CLI\DomainManagement.ps1
            Export-ModuleMember -Function   Get-A9Domain,       New-A9Domain,       Set-A9Domain,       Remove-A9Domain,  
                                            Get-A9DomainSet,    New-A9DomainSet,    Set-A9DomainSet,    Remove-A9DomainSet,    Move-A9DomainObject      
            . $PSScriptRoot\A9.CLI\HealthAndAlertManagement.ps1
            Export-ModuleMember -Function   Get-A9Alert,        Set-A9Alert,        Remove-A9Alerts,    Get-A9Health   
            . $PSScriptRoot\A9.CLI\MaintenanceMode.ps1
            Export-ModuleMember -Function   Get-A9Maintenance, New-A9Maintenance,   Set-A9Maintenance
            . $PSScriptRoot\A9.CLI\NodeSubsystemManagement.ps1
            Export-ModuleMember -Function   Find-A9Node,        Get-A9Node,         Start-A9NodeRescue, Set-A9Battery,      Set-A9NodePowerSupplyId,     Test-A9FCLoopback,
                    Find-A9System,          Get-A9SystemInfo,   Set-A9SysMgr,       Set-A9Date,         Get-A9iSCSISession,  
                    Ping-A9RCIPPorts,       Get-A9Target,       Set-A9FCPorts,      Set-A9HostPorts,    Get-A9Portdevice_CLI                   
            . $PSScriptRoot\A9.CLI\PerformanceManagement.ps1
            Export-ModuleMember -Function   Get-A9Histogram_CLI,    Measure-A9System_CLI,   Get-A9Statistics_CLI,   Set-A9StatisticsChunklets_CLI
            . $PSScriptRoot\A9.CLI\Replication.ps1
            Export-ModuleMember -Function           New-A9RCopyGroupCPG_CLI,        Add-A9RCopyLink_CLI,    Get-A9StatRCopy_CLI, 
                    Disable-A9RCopylink_CLI,        Disable-A9RCopyVv_CLI,          Remove-A9RCopyHost,     Test-A9RCopyLink_CLI,
                    Set-A9RCopyGroupPeriod_CLI,     Set-A9RCopyTargetName_CLI,      Set-A9AdmitRCopyHost       
            . $PSScriptRoot\A9.CLI\ServiceCommands.ps1
            Export-ModuleMember -Function           Add-A9Hardware,             Get-A9SystemPatch,          Get-A9Version ,         Reset-A9SystemNode,     Set-A9Magazines,            
                    Invoke-A9CageService,           Set-A9ServiceNodes,         Get-A9ServiceNodes,         Reset-A9System ,        Update-A9PdFirmware,    Get-A9ResetReason,      
                    Set-A9Security,                 Get-A9SecurityFIPS
            . $PSScriptRoot\A9.CLI\SnapShotManagement.ps1
            Export-ModuleMember -Function           Set-A9VolumeCopy,           Set-A9VolumeSnapshot
            . $PSScriptRoot\A9.CLI\Sparing.ps1
            Export-ModuleMember -Function           Get-A9Spare,                New-A9Spare,                Move-A9Chunklet,        Remove-A9Spare,         Restore-A9RelocatedChunklets
            . $PSScriptRoot\A9.CLI\SystemManager.ps1
            Export-ModuleMember -Function           Get-A9Encryption,           Measure-A9Upgrade,          Get-A9Inventory,        Find-A9Command
            . $PSScriptRoot\A9.CLI\SystemReporter.ps1
            Export-ModuleMember -Function           Get-A9SystemReporterDB_CLI,         Get-A9SystemReporterHistogram_CLI,          Get-A9SystemReporterStats_CLI ,    
                    Set-A9SystemReporter_CLI,       Get-A9SystemReporterAlertCrit_CLI,  Set-A9SystemReporterAlertCrit_CLI,          Remove-A9SystemReporterAlertCrit_CLI,           New-A9SystemReporterAlertCrit_CLI
            . $PSScriptRoot\A9.CLI\TaskManagement.ps1
            Export-ModuleMember -Function   Remove-A9Task,                  Set-A9Task
            . $PSScriptRoot\A9.CLI\UserManagement.ps1
            Export-ModuleMember -Function   Get-A9UserConnection,           Remove-A9UserConnection
            . $PSScriptRoot\A9.CLI\Vasa.ps1
            Export-ModuleMember -Function   Set-A9VASAStorageContainer,     Get-A9VASAStorageContainer
            . $PSScriptRoot\A9.CLI\VirtualVolumeManagement.ps1
            Export-ModuleMember -Function   Set-A9Volume_CLI,               Get-A9Mapping,          Get-A9Peer_CLI,    Get-A9VvScsiReservations,    Update-A9SnapSpace_CLI
        }
        if ( ($PersistArrayType -like '3Par') )
            {   # Load the 3PAR specific Commands
                    . $PSScriptRoot\3PAR.CLI\AdaptiveOptimization.ps1
                        Export-ModuleMember -Function   Get-A9AdaptiveOptimizationConfig,   New-A9AdaptiveOptimizationConfig,       Remove-A9AdaptiveOptimizationConfig, 
                                                        Start-A9AdaptiveOptimizationConfig, update-A9AdaptiveOptimizationConfig,    Get-A9SystemReportAOMoves,              
                                                        Get-A9AdaptiveOptimizationConfig ,  Get-A9SystemReporterRegionIODensity    
                    . $PSScriptRoot\3PAR.CLI\FilePersona.ps1
                        Export-ModuleMember -Function  Get-A9FileServices,          New-A9FPG,                  Remove-A9FPG, 
                            Get-A9FPG,                  Get-A9FPGReclamationTask,   New-A9VFS,                  Remove-A9VFS,               Get-A9VFS , 
                            New-A9FileStore,            Update-A9FileStore,         Remove-A9FileStore,         Get-A9FileStore ,           New-A9FileStoreSnapshot, 
                            Remove-A9FileStoreSnapshot, Get-A9FileStoreSnapshot,    New-A9FileShare,            Remove-A9FileShare ,        Get-A9FileShare, 
                            Get-A9DirPermission ,       New-A9FilePersonaQuota,     Update-A9FilePersonaQuota,  Remove-A9FilePersonaQuota,  Get-A9FilePersonaQuota, 
                            Restore-A9FilePersonaQuota, Group-A9FilePersonaQuota 
                    . $PSScriptRoot\3PAR.CLI\FlashCacheOperations.ps1 
                        Export-ModuleMember -Function   Set-A9FlashCache,           New-A9FlashCache,           Remove-A9FlashCache,
                                                        Get-FlashCache,             Set-A9VvSetFlashCachePolicy
                    . $PSScriptRoot\3PAR.CLI\FilePersonaManagement.ps1
                        Export-ModuleMember -Function   New-A9AdaptiveOptimizationConfig,   Remove-A9AdaptiveOptimizationConfig,    Start-A9AdaptiveOptimizationConfig, Update-A9AdaptiveOptimizationConfig, 
                            Get-A9SystemReportAOMoves,  Start-A9FSNDMP,                     Stop-A9FSNDMP,                          Get-A9SRStatfsfpg,                  Get-A9SystemReporterStatfscpu,
                            Get-A9SRStatfsmem,          Get-A9SystemReporterStatfsblock,    Get-A9SystemReporterStatfsav,           Get-A9SRStatfsnet, 
                            Get-A9SRStatfsnfs,          Get-A9SystemReporterStatfssmb,      Get-A9SystemReporterStatfssnapshot
                    . $PSScriptRoot\3PAR.CLI\StorageFederation.ps1
                        Export-ModuleMember -Function   Join-A9Federation,                  New-A9Federation,                       Set-A9Federation, 
                                                        Remove-A9Federation,                Show-A9Federation
                    . $PSScriptRoot\3PAR.CLI\Flashcache.ps1
                        Export-ModuleMember -Function   New-A9FlashCache_CLI,               Set-A9FlashCache_CLI,                   Remove-A9FlashCache_CLI,
                    . $PSScriptRoot\3PAR.CLI\SystemCommands.pd1
                        Export-ModuleMember -Function   Show-A9EEProm
            }
    }
