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
