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

