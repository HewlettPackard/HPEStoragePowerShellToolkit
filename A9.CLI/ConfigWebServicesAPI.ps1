####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

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

