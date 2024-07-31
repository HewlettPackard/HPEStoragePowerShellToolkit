# Group.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSGroup {
<#
.SYNOPSIS
        List group configurations. 
.DESCRIPTION
        List group configurations. No Parameters are neccessary.
.EXAMPLE
        PS:> Get-NSGroup

        name     id                                         fc_enabled  iscsi_enabled usable_capacity   savings_ratio snmp_sys_contact snmp_sys_location
                                                                                        bytes                                         
        ----     --                                         ----------  ------------- ----------------  ------------- ---------------- ----------------
        Firefly  002b4bd8361b856bbc000000000000000000000001 False       True          24716521871770    1.65433       Chris Lionetti   Lionetti Rack
#>
[CmdletBinding()]
param()
process{ 
        $API = 'groups'
        $Param = @{     ObjectName = 'Group'
                        APIPath = 'groups'
                }
        # Get list of objects matching the given filter.

        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
}
}

function Set-NSGroup {
<#
.SYNOPSIS
        Modify attributes of the group.
.DESCRIPTION
        Modify attributes of the group.
.PARAMETER id 
        Identifier of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
        Name of the group. String of up to 64 alphanumeric characters, - and . and : are 
        allowed after first character. Example: 'myobject-5'.
.PARAMETER smtp_server 
        Hostname or IP Address of SMTP Server. String of alphanumeric characters, valid range is from 2 to 255; 
        Each label must be between 1 and 63 characters long; - and . are allowed after the first 
        and before the last character. Example: 'example-1.com'.
.PARAMETER smtp_port 
        Port number of SMTP Server. Positive integer value up to 65535 representing TCP/IP port. Example: 1234.
.PARAMETER smtp_auth_enabled 
        Whether SMTP Server requires authentication. Possible values: 'true', 'false'.
.PARAMETER smtp_auth_username 
        Username to authenticate with SMTP Server. String of up to 80 alphanumeric characters, 
        beginning with a letter. For Active Directory users, it can include backslash (\), dash (-), 
        period (.), underscore (_) and space. Example: 'user1', 'companydomain\user1'.
.PARAMETER smtp_auth_password 
        Password to authenticate with SMTP Server. String of 8 to 255 printable characters 
        excluding ampersand and ;[]`. Example: 'password-91'.
.PARAMETER smtp_encrypt_type 
        Level of encryption for SMTP. Requires use of SMTP Authentication if encryption is enabled. 
        Possible values: 'none', 'starttls', 'ssl'.
.PARAMETER autosupport_enabled 
        Whether to send autosupport. Possible values: 'true', 'false'.
.PARAMETER allow_support_tunnel 
        Whether to allow support tunnel. Possible values: 'true', 'false'.
.PARAMETER proxy_server 
        Hostname or IP Address of HTTP Proxy Server. Setting this attribute to an empty string will unset all 
        proxy settings. String of alphanumeric characters, can be an empty string, or valid range must be 
        from 2 to 255; Each label must be between 1 and 63 characters long; - and . are allowed after the 
        first and before the last character. Example: 'example-1.com'.
.PARAMETER proxy_port 
        Proxy Port of HTTP Proxy Server. Integer value between 0-65535 representing TCP/IP port. Example: 1234.
.PARAMETER proxy_username 
        Username to authenticate with HTTP Proxy Server. HTTP proxy server username, string up to 255 characters, 
        special characters ([, ], `, ;, ampersand, tab, space, newline) are not allowed.
.PARAMETER proxy_password 
        Password to authenticate with HTTP Proxy Server. HTTP proxy server password, string up to 255 characters, 
        special characters ([, ], `, ;, ampersand, tab, space, newline) are not allowed.
.PARAMETER alert_to_email_addrs 
        Comma-separated list of email addresss to receive emails. Comma separated email list. 
        Example: bob@wikipedia.com,jason@wiki.com.
.PARAMETER send_alert_to_support 
        Whether to send alert to Support. Possible values: 'true', 'false'.
.PARAMETER alert_from_email_addr 
        From email address to use while sending emails. Case insensitive email address. Example: bob@wikipedia.com.
.PARAMETER alert_min_level 
        Minimum level of alert to be notified. Possible values: 'info', 'notice', 'warning', 'critical'.
.PARAMETER isns_enabled 
        Whether iSNS is enabled. Possible values: 'true', 'false'.
.PARAMETER isns_server 
        Hostname or IP Address of iSNS Server. String of alphanumeric characters, valid range is from 2 to 255; 
        Each label must be between 1 and 63 characters long; - and . are allowed after 
        the first and before the last character. Example: 'example-1.com'.
.PARAMETER isns_port 
        Port number for iSNS Server. Positive integer value up to 65535 representing TCP/IP port. Example: 1234.
.PARAMETER snmp_trap_enabled 
        Whether to enable SNMP traps. Possible values: 'true', 'false'.
.PARAMETER snmp_trap_host 
        Hostname or IP Address to send SNMP traps. 
        String of alphanumeric characters, valid range is from 2 to 255; Each label must be between 1 and 63 characters 
        long; - and . are allowed after the first and before the last character. Example: 'example-1.com'.
.PARAMETER snmp_trap_port 
        Port number of SNMP trap host. 
        Positive integer value up to 65535 representing TCP/IP port. Example: 1234.
.PARAMETER snmp_get_enabled 
        Whether to accept SNMP get commands. Possible values: 'true', 'false'.	
.PARAMETER snmp_community 
        Community string to be used with SNMP. 
        String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER snmp_get_port 
        Port number to which SNMP get requests should be sent. 
        Positive integer value up to 65535 representing TCP/IP port. Example: 1234.
.PARAMETER snmp_sys_contact 
        Name of the SNMP administrator. Plain string.
.PARAMETER snmp_sys_location 
        Location of the group. Plain string.
.PARAMETER domain_name 
        Domain name for this group. String of alphanumeric characters, valid range is from 2 to 255; 
        Each label must be between 1 and 63 characters long; - and . are allowed after the first and 
        before the last character. Example: 'example-1.com'.
.PARAMETER dns_servers
        IP addresses for this group's dns servers. List of IP Addresses.
.PARAMETER ntp_server 
        Either IP address or hostname of the NTP server for this group. Plain string.
.PARAMETER timezone 
        Timezone in which this group is located. Plain string.
.PARAMETER user_inactivity_timeout 
        The amount of time in seconds that the user session is inactive before timing out. 
        User inactivity timeout in second, valid range is from 1 to 43200 (720 minutes).
.PARAMETER syslogd_enabled 
        Is syslogd enabled on this system. Possible values: 'true', 'false'.
.PARAMETER syslogd_server 
        Hostname of the syslogd server. String of alphanumeric characters, valid range is from 2 to 255; Each label must 
        be between 1 and 63 characters long; - and . are allowed after the first and before the last character. Example: 'example-1.com'.
.PARAMETER syslogd_port 
        Port number for syslogd server.
.PARAMETER syslogd_servers
        Hostname and/or port of the syslogd servers.
.PARAMETER vvol_enabled 
        Are vvols enabled on this group.
.PARAMETER iscsi_enabled 
        Whether iSCSI is enabled on this group.
.PARAMETER fc_enabled 
        Whether FC is enabled on this group.
.PARAMETER unique_name_enabled 
        Are new volume and volume collection names transformed on this group.
.PARAMETER access_protocol_list
        Protocol used to access this group.
.PARAMETER group_target_enabled 
        Is group_target enabled on this group.
.PARAMETER default_iscsi_target_scope 
        Newly created volumes are exported under iSCSI Group Target or iSCSI Volume Target.
.PARAMETER group_target_name 
        Is group_target enabled on this group. Possible values: 'true', 'false'.
.PARAMETER default_volume_reserve 
        Amount of space to reserve for a volume as a percentage of volume size. Percentage as integer from 0 to 100.
.PARAMETER default_volume_warn_level 
        Default threshold for volume space usage as a percentage of volume size above which an alert is raised. Percentage as integer from 0 to 100.	f
.PARAMETER default_volume_limit 
        Default limit for a volume space usage as a percentage of volume size. 
        Volume will be taken offline/made non-writable on exceeding its limit. Percentage as integer from 0 to 100.
.PARAMETER default_snap_reserve 
        Amount of space to reserve for snapshots of a volume as a percentage of volume size. Unsigned 64-bit integer. Example: 1234.
.PARAMETER default_snap_warn_level 
        Default threshold for snapshot space usage of a volume as a percentage of volume size above which an alert is raised.
.PARAMETER alarms_enabled 
        Whether alarm feature is enabled.
.PARAMETER vss_validation_timeout 
        The amount of time in seconds to validate Microsoft VSS application synchronization before timing out. 
        VSS validation timeout in second, valid range is from 1 to 3600 (60 minutes).
.PARAMETER auto_switchover_enabled 
        Whether automatic switchover of Group management services feature is enabled.
.PARAMETER repl_throttle_list 
        All the replication bandwidth limits on the system.
.PARAMETER encryption_config 
        How encryption is configured for this group. Group encryption settings.
.PARAMETER date 
        Unix epoch time local to the group. Seconds since last epoch i.e. 00:00 January 1, 1970. Example: '3400'.
.PARAMETER login_banner_message 
        The message for the login banner that is displayed during user login activity. String upto 2048 characters.
.PARAMETER login_banner_after_auth 
        Should the banner be displayed before the user credentials are prompted or after prompting the user credentials. Possible values: 'true', 'false'.
.PARAMETER login_banner_reset 
        This will reset the banner to the version of the installed NOS. 
        When login_banner_after_auth is specified, login_banner_reset can not be set to true. Possible values: 'true', 'false'.
.EXAMPLE
        C:\> set-NSGroup -id 0028eada7f8dd99d3b000000000000000000000001 -snmp_sys_contact "bob the Admin" -snmp_sys_location "Datacenter Row 3 Rack 4 RU 12"

        name               id                                         fc_enabled iscsi_enabled usable_capacity_bytes savings_ratio snmp_sys_contact snmp_sys_location
        ----               --                                         ---------- ------------- --------------------- ------------- ---------------- -----------------
        group-chapi-afa-a1 0028eada7f8dd99d3b000000000000000000000001 False      True          23478977434           224.771       Bob The Admin    Datacenter Row 3 Rack 4 RU 12

        This command will update the group properties.
#>
[CmdletBinding()]
param(
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]     [string]        $id,
                                                [string]        $name,
                                                [string]        $smtp_server,
        [ValidateRange(1,65535)]                [int]           $smtp_port,
                                                [bool]          $smtp_auth_enabled,
                                                [string]        $smtp_auth_username,
                                                [string]        $smtp_auth_password,
        [ValidateSet( 'starttls', 'none', 'ssl')][string]       $smtp_encrypt_type,
                                                [bool]          $autosupport_enabled,
                                                [bool]          $allow_support_tunnel,
                                                [string]        $proxy_server,
        [ValidateRange(1,65535)]                [int]           $proxy_port,
                                                [string]        $proxy_username,
                                                [string]        $proxy_password,
                                                [string]        $alert_to_email_addrs,
                                                [bool]          $send_alert_to_support,
                                                [string]        $alert_from_email_addr,
        [ValidateSet( 'critical', 'warning', 'info', 'notice')][string]$alert_min_level,
                                                [bool]          $isns_enabled,
                                                [string]        $isns_server,
        [ValidateRange(1,65535)]                [int]           $isns_port,
                                                [bool]          $snmp_trap_enabled,
                                                [string]        $snmp_trap_host,
        [ValidateRange(1,65535)]                [int]           $snmp_trap_port,
                                                [bool]          $snmp_get_enabled,
                                                [string]        $snmp_community,
        [ValidateRange(1,65535)]                [int]           $snmp_get_port,
                                                [string]        $snmp_sys_contact,
                                                [string]        $snmp_sys_location,
                                                [string]        $domain_name,
                                                [Object[]]      $dns_servers,
                                                [string]        $ntp_server,
                                                [string]        $timezone,
        [ValidateRange(1,43200)]                [long]          $user_inactivity_timeout,
                                                [bool]          $syslogd_enabled,
                                                [string]        $syslogd_server,
        [ValidateRange(1,65535)]                [int]           $syslogd_port,
                                                [bool]          $vvol_enabled,
                                                [bool]          $iscsi_enabled,
                                                [bool]          $fc_enabled,
                                                [bool]          $group_target_enabled,
                                                [long]          $default_volume_reserve,
                                                [long]          $default_volume_warn_level,
                                                [long]          $default_volume_limit,
                                                [long]          $default_snap_reserve,
                                                [long]          $default_snap_warn_level,
                                                [long]          $default_snap_limit,
                                                [long]          $default_snap_limit_percent,
                                                [bool]          $alarms_enabled,
        [ValidateRange(1,3600)]                 [int]          $vss_validation_timeout,
                                                [Object[]]      $repl_throttle_list,
                                                [Object]        $encryption_config,
                                                [long]          $date,
                                                [string]        $login_banner_message,
                                                [bool]          $login_banner_after_auth,
                                                [bool]          $login_banner_reset
        )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       if ($key.ToLower() -ne 'id')
                {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                        if($var -and ($PSBoundParameters.ContainsKey($key)))
                        {       $RequestData.Add("$($var.name)", ($var.value))
                        }
                }
        }
        $Params = @{    ObjectName = 'Group'
                        APIPath = 'groups'
                        Id = $id
                        Properties = $RequestData
                }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
}
}

function Reset-NSGroup {
<#
.SYNOPSIS
        Reboot all arrays in the group.
.DESCRIPTION
        Reboot all arrays in the group.
.PARAMETER id
        Identifier of the group. 
        A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER force
        Reboot remaining arrays when one or more is unreachable.
.EXAMPLE
        C:\> Reset-NSGroup -id 0028eada7f8dd99d3b000000000000000000000001 -force $True

        This command will Stop the Group. The Force option must be used
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]     [string]        $id,
                                                [bool]          $force
)
process{
        $Params = @{
        APIPath = 'groups'
        Action = 'reboot'
        ReturnType = 'void'
        }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {       $Params.Arguments.Add("$($var.name)", ($var.value))
                }
        }
        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}

function Stop-NSGroup {
<#
.SYNOPSIS
        Halt all arrays in the group.
.DESCRIPTION
        Halt all arrays in the group.
.PARAMETER id
        Identifier of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER force
        Halt remaining arrays when one or more is unreachable.
.EXAMPLE
        C:\> stop-NSGroup -id 0028eada7f8dd99d3b000000000000000000000001 -force True

        This command will Stop the Group. The Force option must be used
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]                     [string]        $id,
        [Parameter(ValueFromPipelineByPropertyName=$True)]      [bool]          $force
)
process{
        $Params = @{
                APIPath = 'groups'
                Action = 'halt'
                ReturnType = 'void'
        }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {       $Params.Arguments.Add("$($var.name)", ($var.value))
                }
        }

        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}
function Test-NSGroupAlert {
<#
.SYNOPSIS
        Generate a test alert.
.DESCRIPTION
        Generate a test alert.
.PARAMETER id
        Identifier of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER level
        Level of the test alert. Possible values: 'info', 'notice', 'warning', 'critical'.
.EXAMPLE
        C:\> Test-NSGroupAlert -id 0028eada7f8dd99d3b000000000000000000000001 -level info

        messages
        --------
        {@{code=SM_no_action; severity=info; text=Operation does not effect a change.}}

        This command will create an alert for the group. The level of the alert can be critical, warning, info or notice but is required.
#>
[CmdletBinding()]
param (
        [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]
        [string]$id,

        [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidateSet( 'critical', 'warning', 'info', 'notice')]
        [string]$level
)
process{
        $Params = @{    APIPath = 'groups'
                        Action = 'test_alert'
                        ReturnType = 'void'
                }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {       $Params.Arguments.Add("$($var.name)", ($var.value))
                }
        }

        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}

function Test-NSGroupSoftwareUpdate {
<#
.SYNOPSIS
        Run software update precheck.
.DESCRIPTION
        Run software update precheck.
.PARAMETER id
        Identifier of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER skip_precheck_mask
        Flag to allow skipping certain types of prechecks.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param (
        [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]$id,

        [Parameter(ValueFromPipelineByPropertyName=$True)]    
        [long]$skip_precheck_mask
)
process{
        $Params = @{    APIPath = 'groups'
                        Action = 'software_update_precheck'
                        ReturnType = 'NsSoftwareUpdateReturn'
                }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                { $Params.Arguments.Add("$($var.name)", ($var.value))
                }
        }

        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}

function Start-NSGroupSoftwareUpdate {
<#
.SYNOPSIS
        Update the group software to the downloaded version.
.DESCRIPTION
        Update the group software to the downloaded version.
.PARAMETER id
        ID of the group.
.PARAMETER skip_start_check_mask
        Flag to allow skipping certain types of checks.
#>
[CmdletBinding()]
param (
        [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]$id,

        [Parameter(ValueFromPipelineByPropertyName=$True)]    
        [long]$skip_start_check_mask
)
process{
        $Params = @{
        APIPath = 'groups'
        Action = 'software_update_start'
        ReturnType = 'NsSoftwareUpdateReturn'
        }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {
                        $Params.Arguments.Add("$($var.name)", ($var.value))
                }
        }

        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}

function Start-NSGroupSoftwareDownload {
<#
.SYNOPSIS
        Start the Software Download process which is one of the steps in upgrading an Array to a newer version of code.
.DESCRIPTION
        Start the Software Download process which is one of the steps in upgrading an Array to a newer version of code.
.PARAMETER id
        ID of the group.
.PARAMETER version
        Version string to download.
.PARAMETER force
        Flag to force download.
#>  
[CmdletBinding()]
param (
        [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]  $id,

        [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [string]  $version,

        [Parameter(ValueFromPipelineByPropertyName=$True)]    
        [bool]    $force
        )
process{
        $Params = @{
        APIPath = 'groups'
        Action = 'software_download'
        ReturnType = 'void'
        }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {
                        $Params.Arguments.Add("$($var.name)", ($var.value))
                }
        }

        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
        }
}

function Stop-NSGroupSoftwareDownload {
<#
.SYNOPSIS
  Command to abort the downloading a new version of software for an array.
.DESCRIPTION
  Command to abort the downloading a new version of software for an array.
.PARAMETER id
  ID of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]  $id
)
process{  $Params = @{  APIPath = 'groups'
                        Action = 'software_cancel_download'
                        ReturnType = 'void'
                        }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {       $Params.Arguments.Add("$($var.name)", ($var.value))
                }
        }
        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}

function Resume-NSGroupSoftwareUpdate {
<#
.SYNOPSIS
  Resume stopped software update.
.DESCRIPTION
  Resume stopped software update.
.PARAMETER id 
  ID of the group.
#>
[CmdletBinding(DefaultParameterSetName='allArgs')]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]  $id
      )
process{  $Params = @{  APIPath = 'groups'
                        Action = 'software_update_resume'
                        ReturnType = 'void'
                    }
          $Params.Arguments = @{}
          $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
          foreach ($key in $ParameterList.keys)
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                  {   $Params.Arguments.Add("$($var.name)", ($var.value))
                  }
            }
    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

function Get-NSGroupDiscoveredList {
<#
.SYNOPSIS
  Obtain the list of discovered group member and their details. 
.DESCRIPTION
  Obtain the list of discovered group member and their details. 
.PARAMETER id
  ID of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param (
        [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]$id
  )
process{
    $Params = @{
        APIPath = 'groups'
        Action = 'get_group_discovered_list'
        ReturnType = 'NsDiscoveredGroupListReturn'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

function Test-NSGroupMerge {
<#
.SYNOPSIS
  Performa group merge validation.
.DESCRIPTION
  Performa group merge validation.
.PARAMETER id
  ID of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER src_group_name
  Name of the source group. String of up to 64 alphanumeric characters, - is allowed after first character. Example: 'g1-exchange'.
.PARAMETER src_group_id
  IP address of the source group. Four numbers in the range [0,255] separated by periods. Example: '128.0.0.1'.
.PARAMETER src_username
  Username of the source group. String of up to 80 alphanumeric characters, beginning with a letter. For Active Directory 
  users, it can include backslash (\), dash (-), period (.), underscore (_) and space. Example: 'user1', 'companydomain\user1'.
.PARAMETER src_password
  Password of the source group. String of 8 to 255 printable characters excluding ampersand and ;[]`. Example: 'password-91'.
.PARAMETER src_passphrase
  Source group encryption passphrase. Encryption passphrase. String with size from 8 to 64 printable characters. Example: 'passphrase-91'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]  $id,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]  $src_group_name,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]  $src_group_ip,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]  $src_username,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]  $src_password,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [string]  $src_passphrase,

    [Parameter(ValueFromPipelineByPropertyName=$True)]    
    [bool]    $skip_secondary_mgmt_ip
  )
process{
    $Params = @{
        APIPath = 'groups'
        Action = 'validate_merge'
        ReturnType = 'NsGroupMergeReturn'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

function Merge-NSGroup {
<#
.SYNOPSIS
  Performa group merge.
.DESCRIPTION
  Performa group merge.
.PARAMETER id
  ID of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER src_group_name
  Name of the source group. String of up to 64 alphanumeric characters, - is allowed after first character. Example: 'g1-exchange'.
.PARAMETER src_group_id
  IP address of the source group. Four numbers in the range [0,255] separated by periods. Example: '128.0.0.1'.
.PARAMETER src_username
  Username of the source group. String of up to 80 alphanumeric characters, beginning with a letter. For Active Directory 
  users, it can include backslash (\), dash (-), period (.), underscore (_) and space. Example: 'user1', 'companydomain\user1'.
.PARAMETER src_password
  Password of the source group. String of 8 to 255 printable characters excluding ampersand and ;[]`. Example: 'password-91'.
.PARAMETER src_passphrase
  Source group encryption passphrase. Encryption passphrase. String with size from 8 to 64 printable characters. Example: 'passphrase-91'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')][string]  $id,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]  $src_group_name,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]  $src_group_ip,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]  $src_username,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]  $src_password,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [string]  $src_passphrase,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [bool]    $force,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [bool]    $skip_secondary_mgmt_ip
  )
process{
    $Params = @{
        APIPath = 'groups'
        Action = 'merge'
        ReturnType = 'NsGroupMergeReturn'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

function Get-NSGroupgetEULA {
<#
.SYNOPSIS
        Get URL to download EULA contents.
.DESCRIPTION
        Get URL to download EULA contents.
.PARAMETER id
        Identifier of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER locale
        Locale of EULA contents. Default is en.
.PARAMETER format
        Format of EULA contents. Default is HTML.
.PARAMETER phase
        Phase of EULA contents. Default is setup.
.PARAMETER force
        Flag to force EULA.
#>
[CmdletBinding()]
param (
        [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]     [string]  $id,
        [ValidateSet( 'en')]                    [string]  $locale,
        [ValidateSet( 'html', 'text')]          [string]  $format,
        [ValidateSet( 'software', 'setup')]     [string]  $phase,
                                                [bool]    $force
)
process{
        $Params = @{    APIPath = 'groups'
                        Action = 'get_eula'
                        ReturnType = 'NsEulaReturn'
                }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                        {       $Params.Arguments.Add("$($var.name)", ($var.value))
                        }
        }

        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}
function Test-NSGroupMigrate {
<#
.SYNOPSIS
        Check if the group Management Service can be migrated to the group Management Service backup array.
.DESCRIPTION
        Check if the group Management Service can be migrated to the group Management Service backup array.
.PARAMETER id 
        Identifier of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]  $id
)
process{  
        $Params = @{    APIPath = 'groups'
                        Action = 'check_migrate'
                        ReturnType = 'void'
                }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {   $Params.Arguments.Add("$($var.name)", ($var.value))
                }
        }
        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}

function Move-NSGroup {
<#
.SYNOPSIS
        Migrate the group Management Service to the current group Management Service backup array.
.DESCRIPTION
        Migrate the group Management Service to the current group Management Service backup array.
.PARAMETER id
        Identifier of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]  $id
)
process{ 
        $Params = @{    APIPath = 'groups'
                        Action = 'migrate'
                        ReturnType = 'void'
                }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                        {       $Params.Arguments.Add("$($var.name)", ($var.value))
                        }
        }
        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}

function Get-NSGroupTimeZoneList {
<#
.SYNOPSIS
        Get list of group timezones.
.DESCRIPTION
        Get list of group timezones.
.PARAMETER id
        Identifier of the group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]  $id
)
process{
        $Params = @{
                APIPath = 'groups'
                Action = 'get_timezone_list'
                ReturnType = 'NsTimezonesReturn'
                }
        $Params.Arguments = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {       $Params.Arguments.Add("$($var.name)", ($var.value))
                }
        }

        $ResponseObject = Invoke-NimbleStorageAPIAction @Params
        return $ResponseObject
}
}

# SIG # Begin signature block
# MIIsWgYJKoZIhvcNAQcCoIIsSzCCLEcCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEA6ixvIvQgY
# NeBbKp+AvjSqeEitoaTqCW2u6OVcLC2iq4/a5dn1O+TQDXdYFee9GWMPwAapumSo
# D6cQ8k++ava9oIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhcwghoTAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQOh94Y+dDSNDqwh1Z3lPusnf+dOsxrBf4hA6AKQUpBfH0woDyAEnpLHz
# BDyq+VnDtccl47PYhfWxUJ67MK8lvkkwDQYJKoZIhvcNAQEBBQAEggGACixPP/Cd
# K383teRgY8rDnt5JBuMokoLcaKjmxZG47Z1rcnwwTSw/0fgmwLreOFm5iUcDeMMk
# yKeKr8uUodmBdoXSDQ7eAMTLiLmg/n7NjyzeGEP8REp7v+E1AG0niDBHXGXIRlw3
# 3F2tw2S3oYKJCJU1GjSBhuWxiZGukBIYBdAreBw5ZfPFmZBAqp0CDjjnkdbVv1la
# ePkuBaDvurGCwHBrFwUWhiKNIIeVX8m4nHcWy1TJ0U7WhkIvBoQECXqQAbUFVJsR
# stWQaFdxIfah6iWG1xhKJvUxFZZWPPUFQvsifXplm/x+1PKaanj394lYGseEN3fA
# p7ubZ8M6c2eZcZZauG2c3S0+MaulDKcvn6CpbL8JJbBOHXMeXgdVinrQ/msX8bqq
# FFmJEbUwy0CEbbonPg8KdDAQT9HOSet4ogchLIk1BUa2uoVLNL7btsjR+GgK9wCP
# 0RzbAuZiqN6pYvxEuIXvKGUm5XKzd6gcKeEfHTauaUJ8rrfJw8EsIslroYIXYDCC
# F1wGCisGAQQBgjcDAwExghdMMIIXSAYJKoZIhvcNAQcCoIIXOTCCFzUCAQMxDzAN
# BglghkgBZQMEAgIFADCBhwYLKoZIhvcNAQkQAQSgeAR2MHQCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDCtqzOPk+kNjbcMLmZzAp6z+DsdE2+O5S7PyrLJ
# 3ehFd6vlnPD/DGJFzIO6qDx2dKUCEGyStfMOMWF5OgJnClQcO2kYDzIwMjQwNzMx
# MjA1MTAwWqCCEwkwggbCMIIEqqADAgECAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCSqG
# SIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwHhcNMjMwNzE0MDAwMDAwWhcNMzQxMDEzMjM1OTU5WjBI
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xIDAeBgNVBAMT
# F0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIzMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAo1NFhx2DjlusPlSzI+DPn9fl0uddoQ4J3C9Io5d6OyqcZ9xiFVjB
# qZMRp82qsmrdECmKHmJjadNYnDVxvzqX65RQjxwg6seaOy+WZuNp52n+W8PWKyAc
# wZeUtKVQgfLPywemMGjKg0La/H8JJJSkghraarrYO8pd3hkYhftF6g1hbJ3+cV7E
# Bpo88MUueQ8bZlLjyNY+X9pD04T10Mf2SC1eRXWWdf7dEKEbg8G45lKVtUfXeCk5
# a+B4WZfjRCtK1ZXO7wgX6oJkTf8j48qG7rSkIWRw69XloNpjsy7pBe6q9iT1Hbyb
# HLK3X9/w7nZ9MZllR1WdSiQvrCuXvp/k/XtzPjLuUjT71Lvr1KAsNJvj3m5kGQc3
# AZEPHLVRzapMZoOIaGK7vEEbeBlt5NkP4FhB+9ixLOFRr7StFQYU6mIIE9NpHnxk
# TZ0P387RXoyqq1AVybPKvNfEO2hEo6U7Qv1zfe7dCv95NBB+plwKWEwAPoVpdceD
# ZNZ1zY8SdlalJPrXxGshuugfNJgvOuprAbD3+yqG7HtSOKmYCaFxsmxxrz64b5bV
# 4RAT/mFHCoz+8LbH1cfebCTwv0KCyqBxPZySkwS0aXAnDU+3tTbRyV8IpHCj7Arx
# ES5k4MsiK8rxKBMhSVF+BmbTO77665E42FEHypS34lCh8zrTioPLQHsCAwEAAaOC
# AYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAf
# BgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUpbbvE+fv
# zdBkodVWqWUxo97V40kwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFt
# cGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVT
# dGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAgRrW3qCptZgXvHCNT4o8
# aJzYJf/LLOTN6l0ikuyMIgKpuM+AqNnn48XtJoKKcS8Y3U623mzX4WCcK+3tPUiO
# uGu6fF29wmE3aEl3o+uQqhLXJ4Xzjh6S2sJAOJ9dyKAuJXglnSoFeoQpmLZXeY/b
# JlYrsPOnvTcM2Jh2T1a5UsK2nTipgedtQVyMadG5K8TGe8+c+njikxp2oml101Dk
# RBK+IA2eqUTQ+OVJdwhaIcW0z5iVGlS6ubzBaRm6zxbygzc0brBBJt3eWpdPM43U
# jXd9dUWhpVgmagNF3tlQtVCMr1a9TMXhRsUo063nQwBw3syYnhmJA+rUkTfvTVLz
# yWAhxFZH7doRS4wyw4jmWOK22z75X7BC1o/jF5HRqsBV44a/rCcsQdCaM0qoNtS5
# cpZ+l3k4SF/Kwtw9Mt911jZnWon49qfH5U81PAC9vpwqbHkB3NpE5jreODsHXjlY
# 9HxzMVWggBHLFAx+rrz+pOt5Zapo1iLKO+uagjVXKBbLafIymrLS2Dq4sUaGa7oX
# /cR3bBVsrquvczroSUa31X/MtjjA2Owc9bahuEMs305MfR5ocMB3CtQC4Fxguyj/
# OOVSWtasFyIjTvTs0xf7UGv/B3cfcZdEQcm4RtNsMnxYL2dHZeUbc7aZ+WssBkbv
# QR7w8F/g29mtkIBEr4AQQYowggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5b
# MA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5
# NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPB
# PXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/
# nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLc
# Z47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mf
# XazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3N
# Ng1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yem
# j052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g
# 3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD
# 4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDS
# LFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwM
# O1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU
# 7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0j
# BBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8E
# PDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# DQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPO
# vxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQ
# TGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWae
# LJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPBy
# oyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfB
# wWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8l
# Y5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/
# O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbb
# bxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3
# OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBl
# dkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt
# 1nz8MIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwF
# ADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElE
# IFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKn
# JS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/W
# BTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHi
# LQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhm
# V1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHE
# tWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6
# MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mX
# aXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZ
# xd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfh
# vbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvl
# EFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn1
# 5GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNV
# HQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4Ix
# LVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAA
# MA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzs
# hV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre
# +i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8v
# C6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38
# dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNr
# Iv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDhjCCA4ICAQEw
# dzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCWCGSAFlAwQCAgUAoIHhMBoGCSqG
# SIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQwNzMxMjA1
# MTAwWjArBgsqhkiG9w0BCRACDDEcMBowGDAWBBRm8CsywsLJD4JdzqqKycZPGZzP
# QDA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCDS9uRt7XQizNHUQFdoQTZvgoraVZqu
# MxavTRqa1Ax4KDA/BgkqhkiG9w0BCQQxMgQwvAYqhAJG0ofys8PDC2Uxjz9usWBW
# pjTyGLgrik8fMBHbigboCqKtFcAcAtyKWkNBMA0GCSqGSIb3DQEBAQUABIICAJlz
# RyfqwhZ6fLJe20HczBUUjdj+XT7818mZWgkVki5oTYvg6lX+th15tL20epiEwbOj
# b160YBEtQxioMwnLb0lUMSY1/mSZUCS2es7AYQc8wLq5bWRKEjR0LD2VAXVA33Fw
# VL6WHGohqFzAvvmlDERrlyQupZvXjhls1D5IIJ3t6SBFdO2Bw93opYDmvTijyATG
# G9vfuf5zpn2nLupcPGXzdXXB67Iw2+SuW1eH89RARa7W5DCcrZFc1GAWWu5mSqqE
# UIJlq2clOKhgZFRolgWIlErDbAjwAaYaH8KLXvSzwSO58ZGffLs1b1VYWU/mTPnH
# P6IZ3o8tEUJZlRlpboja1HG9df4zo7VPQW9Q2SwfU+v+2Ocd3vUKflPWOEfKsjOG
# QETTGe1QwlehWOl46yLxiv5s0u4wI0Wkk/ODJdwyjfj4s/KOK0p3rJVDlPzbN3zY
# tcmVZmjDBrILFbILiv8SyuZuRklKjkOCJaSSp0v8wDTUMiJK22KxdY4a66V4DCiq
# t/0Z75Y6HCyQg+Hq02bDa8vK6qs5/RX3N/EqCs8LQE6Np0QgCplBVwGnQoxEg3J7
# Cn7hbxoLKLBUzgyqIbL0FF2G8T3H2VZiCf2ZVgvOLKU5Xw9p7pZmWjBPZJ+U2f3a
# CJ/MPXi9fMJgLnVUWJW2J508CWiqTIo2iilhc5J/
# SIG # End signature block
