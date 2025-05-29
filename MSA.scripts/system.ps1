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
# MIIsVAYJKoZIhvcNAQcCoIIsRTCCLEECAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABECQYOXDC29T
# +YxHxFY9yn7jtfERoWcGMxij8IKTQU8OGq2OfusBXHkOFYJfzuskNiTmggWjjG5f
# yW57uT4JmUnPoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhEwghoNAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQG4U1LjNdpi1qxmchY9JjPNWOWphxzgUqNkbQjXjgG4vuJ+kiqw/GR0D
# e2koFSm++D+Lit96lWG2Uw8yCZEXPI8wDQYJKoZIhvcNAQEBBQAEggGAZs9cpyGF
# It+KsGfmBJxaiaJ0EV8P/gtqCxygCO01LWpxPX4e2hV7TlGiXfKX4r6oHiC7ByOd
# Ua21jbOUFcjR6MNsmIezl+wROyHCq8gQGkyhWaDeMNotoBDs4eBORjiWdn5NBsHg
# Ehyu668i0l8SA7AOWILAUS0uyZIfssLfAEs/s8sIYw4CgpnhEE4qSolz7CZ4tWEG
# HDpNTaoC1Dkhi+ZIOfvcfaNpSs/N1+JqfKyQ6ou08vFsZbkqbyGd1tHnrN3RAf6J
# 9oZ+YN55vrYp6ZUjYGUQtq8ZVVVaIHS07osqwhO1ju3y2gw4YQqYD19cIeuEeiRN
# orn8bw01G1C/74LOl3hjCkI9MYrVq+N5FJwzJWQaS6WfMvXixSiwTY2ijWslX/zz
# 8gPgaZiKrNwrQRwnI37U9quiE95RCx2YqEy4Q1qgb9GjAM3GYRfjyxcCZO1PqPlW
# y7oM+Epyx7s8TAv95p2Efmr8GpbYR3kw4fKQedgbjUAz1JW+CMFihwYMoYIXWjCC
# F1YGCisGAQQBgjcDAwExghdGMIIXQgYJKoZIhvcNAQcCoIIXMzCCFy8CAQMxDzAN
# BglghkgBZQMEAgIFADCBhwYLKoZIhvcNAQkQAQSgeAR2MHQCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDBke+RCvdqHQngfIr7caUpd/q36KQ/p1GRkxI2u
# 52CjE0s9B81c16jSWYwxPDGpwVICEBCR0FKlPLcP2NbcDkx3qBQYDzIwMjUwNTE1
# MDMzODIyWqCCEwMwgga8MIIEpKADAgECAhALrma8Wrp/lYfG+ekE4zMEMA0GCSqG
# SIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwHhcNMjQwOTI2MDAwMDAwWhcNMzUxMTI1MjM1OTU5WjBC
# MQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxIDAeBgNVBAMTF0RpZ2lD
# ZXJ0IFRpbWVzdGFtcCAyMDI0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAvmpzn/aVIauWMLpbbeZZo7Xo/ZEfGMSIO2qZ46XB/QowIEMSvgjEdEZ3v4vr
# rTHleW1JWGErrjOL0J4L0HqVR1czSzvUQ5xF7z4IQmn7dHY7yijvoQ7ujm0u6yXF
# 2v1CrzZopykD07/9fpAT4BxpT9vJoJqAsP8YuhRvflJ9YeHjes4fduksTHulntq9
# WelRWY++TFPxzZrbILRYynyEy7rS1lHQKFpXvo2GePfsMRhNf1F41nyEg5h7iOXv
# +vjX0K8RhUisfqw3TTLHj1uhS66YX2LZPxS4oaf33rp9HlfqSBePejlYeEdU740G
# KQM7SaVSH3TbBL8R6HwX9QVpGnXPlKdE4fBIn5BBFnV+KwPxRNUNK6lYk2y1WSKo
# ur4hJN0SMkoaNV8hyyADiX1xuTxKaXN12HgR+8WulU2d6zhzXomJ2PleI9V2yfmf
# XSPGYanGgxzqI+ShoOGLomMd3mJt92nm7Mheng/TBeSA2z4I78JpwGpTRHiT7yHq
# BiV2ngUIyCtd0pZ8zg3S7bk4QC4RrcnKJ3FbjyPAGogmoiZ33c1HG93Vp6lJ415E
# RcC7bFQMRbxqrMVANiav1k425zYyFMyLNyE1QulQSgDpW9rtvVcIH7WvG9sqYup9
# j8z9J1XqbBZPJ5XLln8mS8wWmdDLnBHXgYly/p1DhoQo5fkCAwEAAaOCAYswggGH
# MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSME
# GDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUn1csA3cOKBWQZqVj
# Xu5Pkh92oFswWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NB
# LmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGlu
# Z0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAPa0eH3aZW+M4hBJH2UOR9hHbm04I
# HdEoT8/T3HuBSyZeq3jSi5GXeWP7xCKhVireKCnCs+8GZl2uVYFvQe+pPTScVJeC
# ZSsMo1JCoZN2mMew/L4tpqVNbSpWO9QGFwfMEy60HofN6V51sMLMXNTLfhVqs+e8
# haupWiArSozyAmGH/6oMQAh078qRh6wvJNU6gnh5OruCP1QUAvVSu4kqVOcJVozZ
# R5RRb/zPd++PGE3qF1P3xWvYViUJLsxtvge/mzA75oBfFZSbdakHJe2BVDGIGVNV
# jOp8sNt70+kEoMF+T6tptMUNlehSR7vM+C13v9+9ZOUKzfRUAYSyyEmYtsnpltD/
# GWX8eM70ls1V6QG/ZOB6b6Yum1HvIiulqJ1Elesj5TMHq8CWT/xrW7twipXTJ5/i
# 5pkU5E16RSBAdOp12aw8IQhhA/vEbFkEiF2abhuFixUDobZaA0VhqAsMHOmaT3XT
# hZDNi5U2zHKhUs5uHHdG6BoQau75KiNbh0c+hatSF+02kULkftARjsyEpHKsF7u5
# zKRbt5oK5YGwFvgc4pEVUNytmB3BpIiowOIIuDgP5M9WArHYSAR16gc0dP2XdkME
# P5eBsX7bf/MGN4K3HP50v/01ZHo/Z5lGLvNwQ7XHBx1yomzLP8lx4Q1zZKDyHcp4
# VQJLu2kWTsKsOqQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMy
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcg
# Q0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
# JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMf
# UBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w
# 1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRk
# tFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYb
# qMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUm
# cJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP6
# 5x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzK
# QtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo
# 80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjB
# Jgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXche
# MBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd
# 4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiC
# qBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl
# /Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
# RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYT
# gAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/
# a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37
# xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmL
# NriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0
# YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJ
# RyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIF
# jTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3y
# ithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1If
# xp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDV
# ySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiO
# DCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQ
# jdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/
# CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCi
# EhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADM
# fRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QY
# uKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXK
# chYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t
# 9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6ch
# nfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0
# MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqG
# SIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi
# +IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n0
# 96wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ8
# 7PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9v
# ytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQt
# J37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDhjCCA4ICAQEwdzBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# AhALrma8Wrp/lYfG+ekE4zMEMA0GCWCGSAFlAwQCAgUAoIHhMBoGCSqGSIb3DQEJ
# AzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjUwNTE1MDMzODIyWjAr
# BgsqhkiG9w0BCRACDDEcMBowGDAWBBTb04XuYtvSPnvk9nFIUIck1YZbRTA3Bgsq
# hkiG9w0BCRACLzEoMCYwJDAiBCB2dp+o8mMvH0MLOiMwrtZWdf7Xc9sF1mW5BZOY
# Q4+a2zA/BgkqhkiG9w0BCQQxMgQwqYXn86fQlM9sZHgjlNlQxgj2noinzuChOB14
# 5jpruhBaob7HZk/E8dhiSSRmmOgfMA0GCSqGSIb3DQEBAQUABIICALQ+TTdD1Tsh
# M8/yNRXfi/wHUzwR3/ShyPJ2zm/4h7BBLBxDpmcN+maQfhwbgXEzxlItT7Mk6VN8
# KLUwS3NxMIJ9IfNo0zC9H/WNhThTgFMr0WJAObqyAqK+ZfR8lcv4Ah/hpZYKKdP+
# BZrfNkwZ0GlMGTcdkCMZylmRjhWK8HjlZ0W9lWHMMqK4kR5FwBijhmohYQiOM9uA
# 1D0SBALLOsKxTTdo9x7E5yRidvIjf59pb1H4cwGhOFauH3LLqdpcFgwh4cO2wFcC
# jYG2V69KeazUvvRoaxLgXjSoFABkTMB5/kEwgoUnFLxzcJa+SY70h31TbnL4wz6Q
# lycHKf+rXyTHCzHjvoqbtFwnT6pveAo1QibPFyBxynCzPTZCGdR7kUNtovQVUkIY
# 3QGNs7+0etA0JINUC9ddUF8ECDdxY5mOs6KgiqpTbXLzYNXvWThIJOuf+7UCU+gZ
# vfhQRD5J28Lz7mA1sqJjl4NdLTJQiRhudLR9Tlo4JRlFBHUoFiWtJxZvBm1DBH4g
# WUc3iC1wiye8s8Od+ryGycxwP6+shASbO7J8eXf0fZvtjGpIRUt+N7D5g+S45wMf
# t8DZTG65f8BsF605W69k+PUKWtmrsbw9bx8glWMLzX2zP522FmEKjMDYh1+mm7Bm
# 1lOzy5LYi+f5zXFJVWUaw+r5RZZkOgEI
# SIG # End signature block
