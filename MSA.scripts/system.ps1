function Get-MSASystem
{
<#
.SYNOPSIS
    Shows information about the storage system.
.DESCRIPTION
    Shows information about the storage system.
    If the system’s health is not OK, each unhealthy component is listed with information to help you resolve the health problem.
.EXAMPLE
    PS:> Get-MSASystem

    object-name                 : system-information
    meta                        : /meta/system
    system-name                 : Uninitialized Name
    system-contact              : Uninitialized Contact
    system-location             : Uninitialized Location
    system-information          : Uninitialized Info
    midplane-serial-number      : 00C0FF5038E8
    url                         : /system/
    vendor-name                 : HPE
    product-id                  : MSA 2060 iSCSI
    product-brand               : MSA Storage
    scsi-vendor-id              : HPE
    scsi-product-id             : MSA 2060 iSCSI
    enclosure-count             : 1
    health                      : OK
    health-numeric              : 0
    health-reason               :
    other-MC-status             : Operational
    other-MC-status-numeric     : 3
    pfuStatus                   : Idle
    pfuStatus-numeric           : 0
    supported-locales           : English (English), Spanish (espaÃ±ol), French (franÃ§ais), German (Deutsch), Italian (italiano), Japanese
                                (æ¥æ¬èª), Korean (íêµì´), Dutch (Nederlands), Chinese-Simplified (ç®ä½ä¸æ), Chinese-Traditional (ç¹é«ä¸-æ)
    current-node-wwn            : 208000c0ff5038e8
    fde-security-status         : Unsecured
    fde-security-status-numeric : 1
    platform-type               : Indium
    platform-type-numeric       : 6
    platform-brand              : HPE
    platform-brand-numeric      : 15
    redundancy                  : {@{object-name=system-redundancy; meta=/meta/redundancy; redundancy-mode=Active-Active ULP;
                                redundancy-mode-numeric=8; redundancy-status=Redundant; redundancy-status-numeric=2;
                                controller-a-status=Operational; controller-a-status-numeric=0; controller-a-serial-number=7CE935R053;
                                controller-b-status=Operational; controller-b-status-numeric=0; controller-b-serial-number=7CE935R039;
                                other-MC-status=Operational; other-MC-status-numeric=3}}
#>
    $result = Invoke-MSAStorageRestAPI -noun system -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAInquiry
{
<#
.SYNOPSIS
    Shows inquiry data for each controller module.
.DESCRIPTION
    Shows inquiry data for each controller module.
.EXAMPLE
    PS:> Get-MSAInquiry

    object-name     : product-info
    meta            : /meta/product-info
    vendor-name     : HPE
    product-id      : MSA 2060 iSCSI
    scsi-vendor-id  : HPE
    scsi-product-id : MSA 2060 iSCSI
#>
    $result = Invoke-MSAStorageRestAPI -noun inquiry -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAAdvancedSetting
{
<#
.SYNOPSIS
    Shows the settings for advanced system-configuration parameters.
.DESCRIPTION
    Shows the settings for advanced system-configuration parameters.
.EXAMPLE
    PS:> Get-MSAAdvancedSetting

    object-name                                : advanced-settings-table
    meta                                       : /meta/advanced-settings-table
    background-scrub                           : Enabled
    background-scrub-numeric                   : 1
    background-scrub-interval                  : 24
    partner-firmware-upgrade                   : Enabled
    partner-firmware-upgrade-numeric           : 1
    utility-priority                           : High
    utility-priority-numeric                   : 0
    smart                                      : Enabled
    smart-numeric                              : 1
    dynamic-spares                             : Enabled
    emp-poll-rate                              : 5
    host-cache-control                         : Disabled
    host-cache-control-numeric                 : 0
    sync-cache-mode                            : Immediate
    sync-cache-mode-numeric                    : 0
    independent-cache                          : Disabled
    independent-cache-numeric                  : 0
    missing-lun-response                       : Illegal Request
    missing-lun-response-numeric               : 1
    controller-failure                         : Disabled
    controller-failure-numeric                 : 0
    super-cap-failure                          : Enabled
    super-cap-failure-numeric                  : 1
    memory-card-failure                        : Enabled
    memory-card-failure-numeric                : 1
    power-supply-failure                       : Disabled
    power-supply-failure-numeric               : 0
    fan-failure                                : Disabled
    fan-failure-numeric                        : 0
    temperature-exceeded                       : Disabled
    temperature-exceeded-numeric               : 0
    partner-notify                             : Disabled
    partner-notify-numeric                     : 0
    auto-write-back                            : Enabled
    auto-write-back-numeric                    : 1
    disk-dsd-enable                            : Disabled
    disk-dsd-enable-numeric                    : 0
    disk-dsd-delay                             : 15
    background-disk-scrub                      : Enabled
    background-disk-scrub-numeric              : 1
    managed-logs                               : Disabled
    managed-logs-numeric                       : 0
    single-controller                          : Disabled
    single-controller-numeric                  : 0
    disk-protection-info                       : Disabled
    disk-protection-info-numeric               : 0
    auto-stall-recovery                        : Enabled
    auto-stall-recovery-numeric                : 1
    delete-override                            : Disabled
    delete-override-numeric                    : 0
    restart-on-capi-fail                       : Enabled
    restart-on-capi-fail-numeric               : 1
    large-pools                                : Disabled
    large-pools-numeric                        : 0
    ssd-concurrent-access                      : Disabled
    ssd-concurrent-access-numeric              : 0
    slot-affinity                              : Disabled
    slot-affinity-numeric                      : 0
    random-io-performance-optimization         : Disabled
    random-io-performance-optimization-numeric : 0
    cache-flush-timeout                        : Enabled
    cache-flush-timeout-numeric                : 1
    remanufacture                              : Enabled
    remanufacture-numeric                      : 1
#>
    $result = Invoke-MSAStorageRestAPI -noun 'advanced-settings' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSATask
{
<#
.SYNOPSIS
    Shows information about tasks.
.DESCRIPTION
    Shows information about tasks.
.EXAMPLE
    PS:> Get-MSATask

    It is common for no current tasks to be running on the array in which nothing is returned.

#>
    $result = Invoke-MSAStorageRestAPI -noun tasks -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}


function Get-MSAExpander
{
<#
.SYNOPSIS
    Shows diagnostic information relating to SAS Expander Controller physical channels, known as PHY lanes.
.DESCRIPTION
    Shows diagnostic information relating to SAS Expander Controller physical channels, known as PHY lanes.
    For each enclosure, this command shows status information for PHYs in I/O module A and then I/O module B.
.NOTES
    This command is for use by or with direction from technical support
.EXAMPLE
    PS:> Get-MSAExpander

    enclos contr wide-por phy-i wide-port-role       wide-po status               elem-sta elem-dis change-c code-vio disparit crc-erro conn-crc lost-dwo invalid- reset-er flag-bit
    ure-id oller t-index  ndex                       rt-num                       tus      abled    ounter   lations  y-errors rs       -errors  rds      dwords   ror-coun s
                                                                                                                                                                ter
    ------ ----- -------- ----- --------------       ------- ------               -------- -------- -------- -------- -------- -------- -------- -------- -------- -------- --------
    1      A     0        0     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     1        1     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     2        2     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     3        3     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     4        4     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     5        5     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     6        6     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     7        7     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     8        8     Drive                7       Enabled - Healthy    OK       Enabled  00000007 00000000 00000047 00000000 00000000 00000001 0000004d 00000000 80000025
    1      A     9        9     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     10       10    Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     11       11    Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     12       12    Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     13       13    Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     14       14    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     15       15    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     16       16    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     17       17    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     18       18    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     19       19    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     20       20    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     21       21    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     22       22    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     23       23    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     0        24    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     1        25    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     2        26    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     3        27    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     4        28    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     5        29    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      A     0        30    SC Alternate         0       Enabled - Healthy    OK       Enabled  00000007 00000000 00000001 00000000 00000000 00000001 00000005 00000000 80000025
    1      A     1        31    SC Alternate         0       Enabled - Healthy    OK       Enabled  00000007 00000000 00000001 00000000 00000000 00000001 00000005 00000000 80000025
    1      A     0        32    Expansion Universal  0       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     1        33    Expansion Universal  0       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     2        34    Expansion Universal  0       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      A     3        35    Expansion Universal  0       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     0        0     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     1        1     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     2        2     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     3        3     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     4        4     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     5        5     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     6        6     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     7        7     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     8        8     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     9        9     Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     10       10    Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     11       11    Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     12       12    Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     13       13    Drive                7       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     14       14    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     15       15    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     16       16    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     17       17    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     18       18    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     19       19    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     20       20    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     21       21    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     22       22    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     23       23    Drive                7       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     0        24    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     1        25    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     2        26    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     3        27    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     4        28    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     5        29    SC Primary           0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     0        30    SC Alternate         0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     1        31    SC Alternate         0       Enabled - Healthy    OK       Enabled  00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000 80000025
    1      B     0        32    Expansion Universal  0       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     1        33    Expansion Universal  0       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     2        34    Expansion Universal  0       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    1      B     3        35    Expansion Universal  0       Enabled - Degraded   Not Used Enabled  00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

#>
    $result = Invoke-MSAStorageRestAPI -noun 'expander-status' -verb show
    $objResult = Register-MSAObjectType $result -objecttypename 'expander'
    return $objResult
}
