function Get-MSALicense
{
<#
.SYNOPSIS
    Shows the status of licensed features in the storage system.
.DESCRIPTION
    Shows the status of licensed features in the storage system.
.OUTPUTS
    License Key: The license key if a license is installed and valid, or blank if a license is not installed.
    Licensing Serial Number: The serial number to use when requesting a license.
    Maximum Licensable Snapshots: Number of snapshots that the highest-level license allows.
    Base Maximum Snapshots: Number of snapshots allowed without an installed license.
    Licensed Snapshots: Number of snapshots allowed by the installed license.
    In-Use Snapshots: Number of existing licensed snapshots.
    Snapshots Expire: Never. License doesn’t expire.
    Virtualization: Shows whether the capability to create and manage pools is enabled or disabled.
    Virtualization Expires: Never. License doesn’t expire.
    Performance Tier: Shows whether the capability to create a Performance tier comprised of SSDs is enabled or disabled.
    Performance Tier Expires: Never. License doesn’t expire.
    Volume Copy: Shows whether the capability to copy volumes is enabled or disabled.
    Volume Copy Expires: Never. Always enabled and doesn’t expire.
    Replication: Shows whether the capability to replicate volumes to a peer system is enabled or disabled.
    Replication Expires: Never. License doesn’t expire.
    VSS:    Shows whether the VSS (Volume Shadow Copy Service) Hardware Provider is enabled or disabled.
    VSS Expires: Never. Always enabled and doesn’t expire.
.EXAMPLE
    PS:> Get-MSALicense

    object-name                                : license
    meta                                       : /meta/license
    license-key                                :
    license-serial-number                      : 5038E8
    platform-max-snapshots                     : 1024
    base-max-snapshots                         : 64
    max-snapshots                              : 64
    in-use-snapshots                           : 0
    max-snapshots-expiry                       : Never
    max-snapshots-expiry-numeric               : 0
    virtualization                             : Enabled
    virtualization-numeric                     : 1
    virtualization-expiry                      : Never
    virtualization-expiry-numeric              : 0
    performance-tier                           : Disabled
    performance-tier-numeric                   : 0
    performance-tier-expiry                    : Never
    performance-tier-expiry-numeric            : 0
    volume-copy                                : Enabled
    volume-copy-numeric                        : 1
    volume-copy-expiry                         : Never
    volume-copy-expiry-numeric                 : 0
    remote-snapshot-replication                : Disabled
    remote-snapshot-replication-numeric        : 0
    remote-snapshot-replication-expiry         : Never
    remote-snapshot-replication-expiry-numeric : 0
    vds                                        : Enabled
    vds-numeric                                : 1
    vds-expiry                                 : Never
    vds-expiry-numeric                         : 0
    vss                                        : Enabled
    vss-numeric                                : 1
    vss-expiry                                 : Never
    vss-expiry-numeric                         : 0
    dsd                                        : Disabled
    dsd-numeric                                : 0
    dsd-expiry                                 : Never
    dsd-expiry-numeric                         : 0
    sra                                        : Enabled
    sra-numeric                                : 1
    sra-expiry                                 : Never
    sra-expiry-numeric                         : 0
#>
    $result = Invoke-MSAStorageRestAPI -noun license -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAFirmware
{
<#
.SYNOPSIS
    Displays the active firmware bundle and an available firmware bundle stored in the system's controller modules.
.DESCRIPTION
    Displays the active firmware bundle and an available firmware bundle stored in the system's controller modules.
    The available bundle is either the previous active bundle or a bundle loaded by a user.
    The active and available firmware bundles will be synchronized between partner controller modules.
.EXAMPLE
    PS:> Get-MSAFirmware

    object-name           : firmware-bundle
    meta                  : /meta/firmware-bundles
    bundle-version        : IN100R003
    build-date            : Fri Jun 19 21:15:17 UTC
    status                : Active
    status-numeric        : 2
    health                : OK
    health-numeric        : 0
    health-reason         :
    health-recommendation :
#>
    $result = Invoke-MSAStorageRestAPI -noun 'firmware-bundles' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAFirmwareUpdate
{
<#
.SYNOPSIS
    Displays the current status of any firmware update on the system.
.DESCRIPTION
    Displays the current status of any firmware update on the system.
    Summary information including the type of activity, start time, completion time, estimated time to completion, percent
    completed, completion status, bundle version, and details about each process step.
.EXAMPLE
    PS:> Get-MSAFirmwareUpdate

    object-name                  : update-status-summary
    meta                         : /meta/update-status-summary
    controller-id                : A
    controller-id-numeric        : 1
    activity                     : Controller update
    activity-numeric             : 2
    start-time                   : 2022-05-09 02:41:26
    completion-time              : 2022-05-09 02:41:57
    estimated-time-to-completion : 20
    percentage-completed         : 83%
    completion-status            : Success
    completion-status-numeric    : 0
    bundle-version               : -null-
    update-status-process-step   : {@{object-name=update-status-process-step; meta=/meta/update-status-process-step; process-step=Check Bundle Integrity; process-step-numeric=1; status=Pending;
                                status-numeric=0; message=Pending; message-numeric=0}, @{object-name=update-status-process-step; meta=/meta/update-status-process-step; process-step=Local update controller;
                                process-step-numeric=9; status=OK; status-numeric=1; message=Success; message-numeric=1}, @{object-name=update-status-process-step; meta=/meta/update-status-process-step;
                                process-step=Local update expander; process-step-numeric=10; status=N/A; status-numeric=4; message=N/A; message-numeric=4}, @{object-name=update-status-process-step;
                                meta=/meta/update-status-process-step; process-step=Local update CPLD; process-step-numeric=11; status=N/A; status-numeric=4; message=N/A; message-numeric=4}…}
#>
    $result = Invoke-MSAStorageRestAPI -noun 'firmware-update-status' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
