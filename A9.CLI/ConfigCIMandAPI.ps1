## 	©2025 Hewlett Packard Enterprise Development LP

Function Remove-A9WsapiSession
{
<#
.SYNOPSIS
  Remove WSAPI user connections.
.DESCRIPTION
  The command removes the WSAPI user connections from the current system.
.PARAMETER Close_sse
  Specifies that the Server Sent Event (SSE) connection channel will be closed. WSAPI session credential for SSE will not be removed.
.PARAMETER id
  Specifies the Id of the WSAPI session connection to be removed.
.PARAMETER user_name
  Specifies the name of the WSAPI user to be removed.
.PARAMETER IP_address
  Specifies the IP address of the WSAPI user to be removed.
.EXAMPLE
	PS:> Remove-A9WsapiSession -Id "1537246327049685" -User_name 3parxyz -IP_address "10.10.10.10"
.NOTES
  This command utilizes the SSH command 'RemoveWSAPISession'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  [Parameter()]           [switch]    $Close_sse,
        [Parameter(Mandatory)]  [String]    $Id,
        [Parameter(Mandatory)]  [String]    $User_name,
        [Parameter(Mandatory)]  [String]    $IP_address
)
Begin	
  {   Test-A9Connection -ClientType 'SshClient' 
  }
Process
  { $Cmd = " removewsapisession -f"
    if($Close_sse)  {  $Cmd += " $Close_sse" }
    $Cmd += " $Id $User_name $IP_address "
    write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
    Return $Result
  }
}

Function Set-A9Wsapi
{
<#
.SYNOPSIS
  Set the Web Services API server properties, or starts or stops the service.
.DESCRIPTION
  The command sets properties of the Web Services API server, including options to enable or disable the HTTP and HTTPS ports.
  This also allows you to start and stop the service.
.PARAMETER Policy
  Sets the WSAPI server policy:
    tls_strict       - only TLS connections using TLS 1.2 with secure ciphers will be accepted if HTTPS is enabled. This is the default policy setting.
    no_tls_strict    - TLS connections using TLS 1.0 - 1.2 will be accepted if HTTPS is enabled.
    per_user_limit   - The maximum number of sessions allowed per user is 80% of the system resource usage.
    no_per_user_limit- The maximum number of sessions allowed per user is the system resource usage. This is the default setting.
.PARAMETER Timeout
  Specifies the value that can be set for the idle session timeout for a WSAPI session. <value> is a positive integer and in the range
  of 3-1440 minutes or (3 minutes to 24 hours). Changing the session timeout takes effect immediately and will affect already opened and
  subsequent WSAPI sessions. The default timeout value is 15 minutes.
.PARAMETER Evtstream
  Enables or disables the event stream feature. This supports Server Sent Event (SSE) protocol. The default value is enable.
.PARAMETER Start
  Will start the WSAPI Service.
.PARAMETER Stop
  Will start the WSAPI Service.
.PARAMETER KeepUI
  When used in conjunction with the Stop option, it will allow a UI to continue operating as the WSAPI is shutdown.
.EXAMPLE
	PS:> Set-A9Wsapi -Policy tls_strict
.EXAMPLE
  PS:> Start-A9Wsapi
.EXAMPLE
  PS:> Stop-A9Wsapi
.NOTES
	This command utilizes the SSH commands 'SetWSAPI, StartWSAPI, and StopWSAPI'
  This command requires a SSH type connection.
  Usage:
  - Access to all domains is required to run this command.
  - When the Web Services API server is active, a warning message showing the current status of the Web Services API server is displayed and 
    you will be prompted for confirmation before continuing. The -f option forces the action without a warning message and prompt.
  - Setting the session timeout alone is not service affecting and will not restart the WSAPI server. However, if the timeout option 
    is specified along with service affecting options like -pol the WSAPI server will restart.
#>
[CmdletBinding(DefaultParameterSetName='Set')]
param(  [Parameter(ParameterSetName='Set')] 	[ValidateSet('tls_strict','no_tls_strict','per_user_limit','no_per_user_limit')]
                        [String]	$Policy,
        [Parameter(ParameterSetName='Set')] 	[ValidateRange(3,1440)]
                        [String]	$Timeout,
        [Parameter(ParameterSetName='Set')] 	[ValidateSet('enable','disable')]
                        [String]	$Evtstream,
        [Parameter(Mandatory, ParameterSetName='Start')] 
                        [Switch]  $Start,
        [Parameter(Mandatory, ParameterSetName='Stop')] 
                        [Switch]  $Stop,
        [Parameter(Mandatory, ParameterSetName='Stop')] 
                        [Switch]  $KeepUI
)
Begin	
  {   Test-A9Connection -ClientType 'SshClient' 
  }
Process
  { switch($PSCmdlet.ParameterSetName)
    { 'Set'   { $Cmd = " setwsapi -f"
                if($Policy)   {	$Cmd += " -pol $Pol"            }
                if($Timeout)  {	$Cmd += " -timeout $Timeout"    }
                if($Evtstream){	$Cmd += " -evtstream $Evtstream"}
              }
      'Start' { $cmd= " startwsapi"
              }
      'Stop'  { $Cmd = " stopwsapi -f"
                if ( $Keep_UI)  { $Cmd+= ' -keep_ui'}
              }
    }
    write-verbose "Executing the following SSH command `n`t $cmd"
    $Result = Invoke-A9CLICommand -cmds  $Cmd
    Return $Result
  }
}

Function Get-A9CIM
{
<#
.SYNOPSIS
    Show the CIM server information including policy
.DESCRIPTION
    This cmdlet displays the CIM server service state being configured, either enabled or disabled. It also displays the server current running
    status, either active or inactive. It displays the current status of the HTTP and HTTPS ports and their port numbers. In addition, it shows the
    current status of the SLP port, that is either enabled or disabled.
.EXAMPLE
    The following example shows the current CIM status:
        PS:> Get-A9Cim

        CIMVer    : 10.4.2
        PGVer     : 2.14.1
        SLP       : Disabled
        SLPPort   : 427
        HTTPS     : Disabled
        Service   : Disabled
        Policy    : {replica_entity, one_hwid_per_view, use_pegasus_interop_namespace, tls_strict}
        HTTPSPort : 5989
        State     : Inactive
.NOTES
	This command utilizes the SSH command 'ShowCIM'
  This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  [Parameter()]   [Switch]    $Policy,
        [Parameter()]   [switch]    $ShowRaw
)		
Begin 
    { Test-A9Connection -ClientType 'SshClient' 
    }
process
    {   $cmd = "showcim "
        write-verbose "Executing the following SSH command `n`t $cmd"
        $Result1 = Invoke-A9CLICommand -cmds $cmd
        $cmd += " -pol " 	
        write-verbose "Executing the following SSH command `n`t $cmd"
		$Result2 = Invoke-A9CLICommand -cmds $cmd
        $Result3 = $Result1 + $Result2
        if ($ShowRaw)   { return $Result3 }
        if ( $Result1.count -gt 1)
            {   $Result2 = @{Policy = @($Result2[1].split(',')) }                 
                $tempFile = [IO.Path]::GetTempFileName()
                        $Head = (($Result1[0].split(' ') | where-object {$_ -ne ''}).trim('-')) -join ","
                        $Data = (($Result1[1].split(' ') | where-object {$_ -ne ''}).trim(' ')) -join ","
                        $tempFile = [IO.Path]::GetTempFileName()
                        Add-Content -Path $tempFile -Value $Head
                        Add-Content -Path $tempFile -Value $Data
                        $Result1 = Import-Csv $tempFile
                        Remove-Item  $tempFile
                        # Must force import as a Hashtable instead of a PSCustom Object or else I cant add them together
                        $Result3 = ($result1 | convertto-json | convertfrom-json -asHashTable) + ($result2 | convertto-json | convertfrom-json -asHashTable)
                        $Result3 = $Result3 | convertto-json | convertfrom-json
                return 	$Result3
            }
        else 
            {  Write-Warning "The Command did not complete properly"
            }
    }
}

Function Set-A9CIM
{
<#
.SYNOPSIS
    Set the CIM server properties
.DESCRIPTION
    The cmdlet sets properties of the CIM server, including options to enable/disable the HTTP and HTTPS ports for the CIM server. setcim allows
    a user to enable/disable the SLP port. The command also sets the CIM server policy. You cannot disable both of the HTTP and HTTPS ports.

.PARAMETER Slp
    Enables or disables the SLP port 427.
.PARAMETER Http
    Enables or disables the HTTP port 5988
.PARAMETER Https
    Enables or disables the HTTPS port 5989
.PARAMETER Policy
    Sets the cim server policy:
        replica_entity   - complies with SMI-S standard for usage of Replication Entity objects in associations. This is the default policy setting.
        no_replica_entity- does not comply with SMI-S standard for Replication Entity usage. Use only as directed by HPE support personnel or Release Notes.
        one_hwid_per_view - calling exposePaths with multiple initiatorPortIDs to create new view will result in the creation of multiple
                            SCSCIProtocolControllers (SPC), one StorageHardwareID per SPC. Multiple hosts will be created each containing one FC WWN or
                            iscsiname. This is the default policy setting. This is the default policy setting.
        no_one_hwid_per_view - calling exposePaths with multiple initiatorPortIDs to create new view will result in the creation of only one
                            SCSCIProtocolController (SPC) that contains all the StorageHardwareIDs. One host will be created that contains all the FC WWNs or iscsinames.
        use_pegasus_interop_namespace - use the pegasus defined interop namespace root/PG_interop.  This is the default policy setting.
        no_use_pegasus_interop_namespace - use the SMI-S conformant interop namespace root/interop.
        tls_strict       - Only TLS connections using TLS 1.2 with secure ciphers will be accepted if HTTPS is enabled.
        no_tls_strict    - TLS connections using TLS 1.0 - 1.2 will be accepted if HTTPS is enabled. This is the default policy setting.
.PARAMETER Start
    The cmdlet starts the CIM server allowing it to servicing CIM requests.
.PARAMETER Stop
    The cmdlet stops the CIM server from servicing CIM requests.
.PARAMETER Immediate
    Specifies that the operation terminates the server immediately without graceful shutdown notice.
.EXAMPLE
    To disable the HTTPS ports:

    PS:> Set-A9CIM -Https Disable
.EXAMPLE
    To enable the HTTPS port:

    PS:> Set-A9CIM -Https Enable
.EXAMPLE
    To disable the HTTP port and enable the HTTPS port:

    PS:> Set-A9CIM -Http Disable -Https Enable
.EXAMPLE
    To set the no_use_pegasus_interop_namespace policy:

    PS:> Set-A9CIM -Pol no_use_pegasus_interop_namespace
.EXAMPLE
    To set the replica_entity policy:

    PS:> Set-A9CIM -Pol replica_entity
.NOTES
  This command utilizes the SSH command 'SetCIM'    
  This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  [Parameter(parametersetname='SLP',mandatory)]       
            [ValidateSet("enable", "disable")]          [String]    $Slp,
        [Parameter(parametersetname='HTTP',mandatory)]
            [ValidateSet("enable", "disable")]          [String]    $Http,
        [Parameter(parametersetname='HTTPS',mandatory)]   
            [ValidateSet("enable", "disable")]          [String]    $Https,
        [Parameter(parametersetname='Policy',mandatory)]   
            [ValidateSet("replica_entity", "no_replica_entity", "one_hwid_per_view", "no_one_hwid_per_view", "use_pegasus_interop_namespace", "no_use_pegasus_interop_namespace", "tls_strict", "no_tls_strict")]
                                                        [String]    $Policy,
        [Parameter(parametersetname='Start',mandatory)] [switch]    $Start,   
        [Parameter(parametersetname='Stop',mandatory)]  [Switch]    $Stop,
        [Parameter(parametersetname='Stop')]            [Switch]    $Immediate
    
)	
Begin	
    {   Test-A9Connection -ClientType 'SshClient'
    }
Process
    {   $cmd = "setcim -f "
        switch($PSCmdlet.ParameterSetName)
            {   'SLP'   {   $cmd += " -slp $Slp"    }
                'HTTP'  {   $cmd += " -http $Http"  }
                'HTTPS' {   $cmd += " -https $Https"}
                'Policy'{   $cmd += " -pol $Pol"    }
                'Start' {   $cmd = "startcim "      }
                'Stop'  {   $cmd = "stopcim "
                            if ($Immediate) {    $cmd += " -x "}
                        }
            }
        write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd
        return 	$Result	
    }
}


