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

# SIG # Begin signature block
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDS1hmJ43RK
# ACpjS/huTeK7TNANJuURt/Y7mOmxC+Gkx/pMFKnIUf7n9OjKct/B59h3RxQIZZGj
# ni6B6V7JBCIxoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5UwghuRAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQMI/uIBgb+LN1AThcAUYVhBCdmz2FqVJSoKTEuAMsFlKHSasDY0izCs4
# 3vsqgZ0nQavVikND10YhnZxyYrx62yowDQYJKoZIhvcNAQEBBQAEggGAKg4KpOsY
# XPUiO3piW3GR6t2ItJ65XziWg55fsNbxrXxcqgUDMJqqA/VM7Fsw85RRL8jd63R4
# 0csuZzsZWmeb0BwD0qLb3S7cIZYba/uTq0GmtKKJx+DygFyjtkzJW8HM7T3GRuqa
# 1yXjwMyaOUNvPDeZmqL7gOfaTzZFG1LMXayPb3w2NFpegSlKw28psswE09UYhhn0
# R8U6l15C/8J4V4Y0mzdn/4auGWnLokIXbPX3ZrAPGRbY574eweGRXGfAqSD7M7kM
# TBBKaSpk3mMBDxuMQrPdRxKED1j+SaUXtyl/9dEpDhdxRdwXHD0M2z7B6RDwqlol
# vYgOWsZTLH/r8C0yDnc59crpPFIzZp37SbvxvCl+0utoks3cboNQ4XabgCuC7Rn1
# I9zRhYKGAnqpRIYXXS58j1xKUeL60NVJaCQGZxp0tB22yUjp1hRHpBOPiUshWvk5
# UhdUA9u0NPGgC40dRba+o1uzTpyLrDXPkaFb+rUduP6JeiztiFLRNATpoYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMG+W4tm1FK/wuRElSUPcqR7ktk2YnCBY
# XlY/EQqp0XGDaJ6JgnlaUXLkxAtfxdceDQIUa3HGcLjz9ePKhLZftbYEDdMceRsY
# DzIwMjQwNzMxMjAzNTQ5WqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
# bmNoZXN0ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2Vj
# dGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1oIIS/zCCBl0wggTF
# oAMCAQICEDpSaiyEzlXmHWX8zBLY6YkwDQYJKoZIhvcNAQEMBQAwVTELMAkGA1UE
# BhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGln
# byBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjQwMTE1MDAwMDAwWhcN
# MzUwNDE0MjM1OTU5WjBuMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFuY2hlc3Rl
# cjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydTZWN0aWdvIFB1
# YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzUwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN0Wf0wUibvf04STpNYYGbw9jcRaVhBDaNBp7jmJaA9dQZ
# W5ighrXGNMYjK7Dey5RIHMqLIbT9z9if753mYbojJrKWO4ZP0N5dBT2TwZZaPb8E
# +hqaDZ8Vy2c+x1NiEwbEzTrPX4W3QFq/zJvDDbWKL99qLL42GJQzX3n5wWo60Kkl
# fFn+Wb22mOZWYSqkCVGl8aYuE12SqIS4MVO4PUaxXeO+4+48YpQlNqbc/ndTgszR
# QLF4MjxDPjRDD1M9qvpLTZcTGVzxfViyIToRNxPP6DUiZDU6oXARrGwyP9aglPXw
# YbkqI2dLuf9fiIzBugCDciOly8TPDgBkJmjAfILNiGcVEzg+40xUdhxNcaC+6r0j
# uPiR7bzXHh7v/3RnlZuT3ZGstxLfmE7fRMAFwbHdDz5gtHLqjSTXDiNF58IxPtvm
# ZPG2rlc+Yq+2B8+5pY+QZn+1vEifI0MDtiA6BxxQuOnj4PnqDaK7NEKwtD1pzoA3
# jJFuoJiwbatwhDkg1PIjYnMDbDW+wAc9FtRN6pUsO405jaBgigoFZCw9hWjLNqgF
# VTo7lMb5rVjJ9aSBVVL2dcqzyFW2LdWk5Xdp65oeeOALod7YIIMv1pbqC15R7QCY
# LxcK1bCl4/HpBbdE5mjy9JR70BHuYx27n4XNOZbwrXcG3wZf9gEUk7stbPAoBQID
# AQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNhlxmiMpswHQYD
# VR0OBBYEFGjvpDJJabZSOB3qQzks9BRqngyFMA4GA1UdDwEB/wQEAwIGwDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1UdIARDMEEwNQYM
# KwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20v
# Q1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8vY3JsLnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcmwwegYIKwYB
# BQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYBBQUHMAGGF2h0
# dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IBgQCw3C7J+k82
# TIov9slP1e8YTx+fDsa//hJ62Y6SMr2E89rv82y/n8we5W6z5pfBEWozlW7nWp+s
# dPCdUTFw/YQcqvshH6b9Rvs9qZp5Z+V7nHwPTH8yzKwgKzTTG1I1XEXLAK9fHnmX
# paDeVeI8K6Lw3iznWZdLQe3zl+Rejdq5l2jU7iUfMkthfhFmi+VVYPkR/BXpV7Ub
# 1QyyWebqkjSHJHRmv3lBYbQyk08/S7TlIeOr9iQ+UN57fJg4QI0yqdn6PyiehS1n
# SgLwKRs46T8A6hXiSn/pCXaASnds0LsM5OVoKYfbgOOlWCvKfwUySWoSgrhncihS
# BXxH2pAuDV2vr8GOCEaePZc0Dy6O1rYnKjGmqm/IRNkJghSMizr1iIOPN+23futB
# XAhmx8Ji/4NTmyH9K0UvXHiuA2Pa3wZxxR9r9XeIUVb2V8glZay+2ULlc445CzCv
# VSZV01ZB6bgvCuUuBx079gCcepjnZDCcEuIC5Se4F6yFaZ8RvmiJ4hgwggYUMIID
# /KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUAMFcxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEwMzIyMDAwMDAw
# WhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAM2Y2ENBq26C
# K+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStSVjeYXIjfa3aj
# oW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQBaCxpectRGhh
# nOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE9cbY11XxM2AV
# Zn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExSLnh+va8WxTlA
# +uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OIIq/fWlwBp6KNL
# 19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGdF+z+Gyn9/CRe
# zKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w76kOLIaFVhf5
# sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4CllgrwIDAQABo4IB
# XDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUwHQYDVR0OBBYE
# FF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8E
# CDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0g
# ADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEFBQcBAQRwMG4w
# RwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1Ymxp
# Y1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2Nz
# cC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0ONVgMnoEdJVj9
# TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc6ZvIyHI5UkPC
# bXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1OSkkSivt51Ul
# mJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz2wSKr+nDO+Db
# 8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y4Il6ajTqV2if
# ikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVMCMPY2752LmES
# sRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBeNh9AQO1gQrnh
# 1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupiaAeNHe0pWSGH2
# opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU+CCQaL0cJqlm
# nx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/SjwsusWRItFA3DE8
# MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7xpMeYRriWklU
# PsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs656Oz3TbLyXVo
# MA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEpl
# cnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJV
# U1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9u
# IEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMFcxCzAJ
# BgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJBZvMWhUP2ZQQ
# RLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQnOh2qmcxGzjqe
# mIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypoGJrruH/drCio
# 28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0pKG9ki+PC6VEf
# zutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13jQEV1JnUTCm51
# 1n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9YrcmXcLgsrAi
# mfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/yVl4jnDcw6ULJ
# sBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVgh60KmLmzXiqJ
# c6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/OLoanEWP6Y52
# Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+NrLedIxsE88WzK
# XqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58NHs57ZPUfECcg
# JC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rID
# ZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1UdDwEB/wQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVz
# dC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwNQYI
# KwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3Qu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3OyWM637ayBeR
# 7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJJlFfym1Doi+4
# PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0mUGQHbRcF57ol
# pfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTwbD/zIExAopoe
# 3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i111TW7HV1Ats
# Qa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGezjM6CRpcWed/
# ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+8aW88WThRpv8
# lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH29308ZkpKKdp
# kiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrsxrYJD+3f3aKg
# 6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6Ii8+CQOYDwXM
# +yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz7NgAnOgpCdUo
# 4uDyllU9PzGCBJEwggSNAgEBMGkwVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1Nl
# Y3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFt
# cGluZyBDQSBSMzYCEDpSaiyEzlXmHWX8zBLY6YkwDQYJYIZIAWUDBAICBQCgggH5
# MBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQw
# NzMxMjAzNTQ5WjA/BgkqhkiG9w0BCQQxMgQwWgUe1T3jMQTWaKfrb5pPOMefstfc
# ZLNm50YAc0y/5eFFcKy+hEd5145cnUzdgaHXMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgBOR5s9
# eC3azHxaIg1gI/vbUeWAxW+z8pIEjxnsJeEZZtkRrAIiTknjJpWDZ+F9LnXTZ7hJ
# JSoI9D4NgKHa68dmWtfApSfOVWA4JGVNoQit6xOm9y9ggxIbSNLOklUjmZ1JHTMe
# cnEEqHyhS135BiSfek2R5/E6xEbIlY6QagmzepKp+sjofTTRbUEH8fDrGfguXg3r
# +xbz4kFS/sBwYiXgrR5kTSbwK1kmHqH7iddviZEKmkuoYaG15N0uXMJsSzR1dw3w
# vayvzTpXD7F7d1ZyrOqKBGuQVETYqmHhb71OT6yXKFmUrEoL5+mhd3XvOmXB19vO
# HlJtink/aKYxiQfYoRMGExFRONoWfaIN7AZWDQVgZ4IY6OmopsZecb0Aut34VPuQ
# Y+zjmmMXyQ9cx/bZopDtxPkTDScnpmgqcQrX3IfKd6ri6RyHXtNTA1H/0PePaoZP
# FPbn1lHlcPya5LDPkJUMKJL/877RYKiZqanAZdSKtIMQMBcdUdYvKKXEAKoIWlI/
# 7cmkFw1EOwVYN2fd/eAN4h1oxt84qzxHqmyYbsRAdNT+1LUFlOlizqsn9luIfduq
# leP0rzP+lTD/P8+72Of1AyACYMWYi74waz7yXcYUi5nF9RDClFmOSf1IVFnaSLdN
# fQqmasZ/hboMPKCdb6lX1RyFWXBZIMVIslkQ3w==
# SIG # End signature block
