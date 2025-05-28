
. $PSScriptRoot\A9.GLOBAL\VS-Functions.ps1
. $PSScriptRoot\A9.GLOBAL\Logger.ps1
. $PSScriptRoot\A9.GLOBAL\CpgManagement.ps1 
if  ( -not ($HPEStorageModuleConnected)  -or $HPEStorageA9CLIEnable  )
    {   # Detected that I am being loaded via the HPEStorageModlue, so only load if I was able to successfully connect via CLI
        Write-Host "HPE Alletra MP-B10000, 9000, Primara, And 3Par Module will load all CLI based commands"
        . $PSScriptRoot\A9.CLI\AdaptiveOptimization.ps1
        . $PSScriptRoot\A9.CLI\ConfigWebServicesAPI.ps1
        . $PSScriptRoot\A9.CLI\Disk.ps1
        . $PSScriptRoot\A9.CLI\DomainManagement.ps1
        . $PSScriptRoot\A9.CLI\FilePersonaManagement.ps1
        . $PSScriptRoot\A9.CLI\Flashcache.ps1
        . $PSScriptRoot\A9.CLI\HealthAndAlertManagement.ps1
        . $PSScriptRoot\A9.CLI\HostManagement.ps1
        . $PSScriptRoot\A9.CLI\Internal.ps1
        . $PSScriptRoot\A9.CLI\InventoryManagement.ps1
        . $PSScriptRoot\A9.CLI\MaintenanceMode.ps1
        . $PSScriptRoot\A9.CLI\NodeSubsystemManagement.ps1
        . $PSScriptRoot\A9.CLI\PerformanceManagement.ps1
        . $PSScriptRoot\A9.CLI\Replication.ps1
        . $PSScriptRoot\A9.CLI\ServiceCommands.ps1
        . $PSScriptRoot\A9.CLI\SnapShotManagement.ps1
        . $PSScriptRoot\A9.CLI\Sparing.ps1
        . $PSScriptRoot\A9.CLI\SystemManager.ps1
        . $PSScriptRoot\A9.CLI\SystemReporter.ps1
        . $PSScriptRoot\A9.CLI\TaskManagement.ps1
        . $PSScriptRoot\A9.CLI\CimManagement.ps1
        . $PSScriptRoot\A9.CLI\UserManagement.ps1
        . $PSScriptRoot\A9.CLI\Vasa.ps1
        . $PSScriptRoot\A9.CLI\StorageFederation.ps1
        . $PSScriptRoot\A9.CLI\VirtualVolumeManagement.ps1
    }
else{   Write-warning "The HPE Alletra MP-B10000, 9000, Primera, And 3Par Module is loaded and read, but CLI Based commands are unavailable."
    }
if  ( -not ($HPEStorageModuleConnected) -or $HPEStorageA9APIEnable )
    {   . $PSScriptRoot\A9.scripts\AvailableSpace.ps1 
        . $PSScriptRoot\A9.scripts\CopyOperations.ps1 
        . $PSScriptRoot\A9.scripts\FilePersona.ps1
        . $PSScriptRoot\A9.scripts\FlashCacheOperations.ps1 
        . $PSScriptRoot\A9.scripts\HostManagement.ps1
        . $PSScriptRoot\A9.scripts\HostSetsAndVirtualVolumeSets.ps1 
        . $PSScriptRoot\A9.scripts\PortsAndSwitches.ps1 
        . $PSScriptRoot\A9.scripts\RemoteCopy.ps1
        . $PSScriptRoot\A9.scripts\SessionKeysAndWsapiSystemAccess.ps1
        . $PSScriptRoot\A9.scripts\StorageVolumes.ps1 
        . $PSScriptRoot\A9.scripts\SystemEvents.ps1
        . $PSScriptRoot\A9.scripts\SystemInformationQueriesAndManagement.ps1 
        . $PSScriptRoot\A9.scripts\SystemReporter.ps1 
        . $PSScriptRoot\A9.scripts\VirtualLUNs.ps1
        . $PSScriptRoot\A9.scripts\WsapiUserAndRoleInformation.ps1
        
    }
else{   Write-warning "The HPE Alletra MP-B10000, 9000, Primera, And3Par Module is loaded and read, but WSAPI Based commands are unavailable."
    }

Export-ModuleMember -Function *  
