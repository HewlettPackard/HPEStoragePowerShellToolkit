function Get-MSADNS
{
<#
.SYNOPSIS
    Shows configured DNS settings for each controller module.
.DESCRIPTION
    Shows configured DNS settings for each controller module.
.EXAMPLE
    PS:> Get-MSADNS

    object-name    name-servers                        search-domains
    -----------    ------------                        --------------
    controller-a   192.168.1.70,192.168.1.1            lionetti.lab
    controller-b   192.168.1.70,192.168.1.1            lionetti.lab
#>
    $result = Invoke-MSAStorageRestAPI -noun 'dns-parameters' -verb show
    $objResult = Register-MSAObjectType $result -subobjectname 'dns-parameters' -objecttypename 'dns-parameters'
    return $objResult
}

function Get-MSAEmail
{
<#
.SYNOPSIS
    Shows email (SMTP) notification parameters for events and managed logs.
.DESCRIPTION
    Shows email (SMTP) notification parameters for events and managed logs.
.EXAMPLE
    PS:> Get-MSAEmail

    object-name                       : email-parameters
    meta                              : /meta/email-parameters
    email-notification                : Disabled
    email-notification-numeric        : 0
    email-notification-filter         : none
    email-notification-filter-numeric : 5
    email-notify-address-1            :
    email-notify-address-2            :
    email-notify-address-3            :
    email-notify-address-4            :
    email-security-protocol           : None
    email-security-protocol-numeric   : 0
    email-smtp-port                   :
    email-server                      :
    email-domain                      :
    email-sender                      :
    email-sender-password             : Not Configured
    alert-notification                : all
    alert-notification-numeric        : 6
    event-notification                : none
    event-notification-numeric        : 5
    persistent-alerts                 : Enabled
    persistent-alerts-numeric         : 1
    email-include-logs                : Disabled
    email-include-logs-numeric        : 0

#>
    $result = Invoke-MSAStorageRestAPI -noun 'email-parameters' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSASession
{
<#
.SYNOPSIS
    Shows information about user sessions on the storage system.
.DESCRIPTION
    Shows information about user sessions on the storage system.
    When an active session reaches its timeout (1800 seconds by default), the session will be marked as expired, 
    and will be removed 30 seconds later. If you reset the system, all sessions will be removed.
    This information is for reference as a security measure.
.EXAMPLE
    PS:> Get-MSASession

    It is common for no current tasks to be running on the array in which nothing is returned.

#>
    $result = Invoke-MSAStorageRestAPI -noun sessions -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAIPv6
{
<#
.SYNOPSIS
    Shows static IPv6 addresses assigned to each controller's network port.
.DESCRIPTION
    Shows static IPv6 addresses assigned to each controller's network port.
.EXAMPLE
    PS:> Get-MSAIPv6

    This command will return nothing is no IPv6 addresses are configured.
#>
    $result = Invoke-MSAStorageRestAPI -noun 'ipv6-addresses' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAIPv6Network
{
<#
.SYNOPSIS
    Shows the IPv6 settings and health of each controller module's network port.
.DESCRIPTION
    Shows the IPv6 settings and health of each controller module's network port.
.EXAMPLE
    PS:> Get-MSAIPv6Network

    object-name        : controller-a
    meta               : /meta/ipv6-network-parameters
    controller         : A
    controller-numeric : 1
    autoconfig         : Enabled
    autoconfig-numeric : 1
    gateway            : ::
    link-local-address : fe80::2c0:ffff:fe50:437d
    autoconfig-ip      : ::
    dhcpv6             : ::
    slaac-ip           : ::
    ip6-address-1      : ::
    ip6-label-1        :
    ip6-address-2      : ::
    ip6-label-2        :
    ip6-address-3      : ::
    ip6-label-3        :
    ip6-address-4      : ::
    ip6-label-4        :

    object-name        : controller-b
    meta               : /meta/ipv6-network-parameters
    controller         : B
    controller-numeric : 0
    autoconfig         : Enabled
    autoconfig-numeric : 1
    gateway            : ::
    link-local-address : fe80::2c0:ffff:fe50:4392
    autoconfig-ip      : ::
    dhcpv6             : ::
    slaac-ip           : ::
    ip6-address-1      : ::
    ip6-label-1        :
    ip6-address-2      : ::
    ip6-label-2        :
    ip6-address-3      : ::
    ip6-label-3        :
    ip6-address-4      : ::
    ip6-label-4        :
#>
    $result = Invoke-MSAStorageRestAPI -noun 'ipv6-network-parameters' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSALDAP
{
<#
.SYNOPSIS
    Shows LDAP settings.
.DESCRIPTION
    Shows LDAP settings.
.EXAMPLE
    PS:> Get-MSALDAP

    object-name           : ldap-parameters
    meta                  : /meta/ldap-parameters
    ldap-protocol         : Disabled
    ldap-protocol-numeric : 0
    user-search-base      :
    ldap-server           :
    ldap-port             : 636
    alternate-ldap-server :
    alternate-ldap-port   : 636

#>
    $result = Invoke-MSAStorageRestAPI -noun 'ldap-parameters' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSANetwork
{
<#
.SYNOPSIS
    Shows the settings and health of each controller module’s network port.
.DESCRIPTION
    Shows the settings and health of each controller module’s network port.
.EXAMPLE
    PS:> Get-MSANetwork

    object-name              : controller-a
    meta                     : /meta/network-parameters
    durable-id               : mgmtport_a
    active-version           : 4
    ip-address               : 192.168.100.98
    gateway                  : 192.168.100.1
    subnet-mask              : 255.255.255.0
    mac-address              : 00:c0:ff:50:43:7d
    addressing-mode          : Manual
    addressing-mode-numeric  : 1
    link-speed               : 1000mbps
    link-speed-numeric       : 2
    duplex-mode              : full
    duplex-mode-numeric      : 0
    auto-negotiation         : Enabled
    auto-negotiation-numeric : 1
    health                   : OK
    health-numeric           : 0
    health-reason            :
    health-recommendation    :
    ping-broadcast           : Enabled
    ping-broadcast-numeric   : 1

    object-name              : controller-b
    meta                     : /meta/network-parameters
    durable-id               : mgmtport_b
    active-version           : 4
    ip-address               : 192.168.100.99
    gateway                  : 192.168.100.1
    subnet-mask              : 255.255.255.0
    mac-address              : 00:c0:ff:50:43:92
    addressing-mode          : Manual
    addressing-mode-numeric  : 1
    link-speed               : 1000mbps
    link-speed-numeric       : 2
    duplex-mode              : full
    duplex-mode-numeric      : 0
    auto-negotiation         : Enabled
    auto-negotiation-numeric : 1
    health                   : OK
    health-numeric           : 0
    health-reason            :
    health-recommendation    :
    ping-broadcast           : Enabled
    ping-broadcast-numeric   : 1


#>
    $result = Invoke-MSAStorageRestAPI -noun 'network-parameters' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSANetwork
{
<#
.SYNOPSIS
    Shows the status of the use of Network Time Protocol (NTP) in the system.
.DESCRIPTION
    Shows the status of the use of Network Time Protocol (NTP) in the system.
.EXAMPLE
    PS:> Get-MSANTP

    object-name        : ntp-status
    meta               : /meta/ntp-status
    ntp-status         : activated
    ntp-server-address : 192.168.1.70
    ntp-contact-time   : none
#>
    $result = Invoke-MSAStorageRestAPI -noun 'ntp-status' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
