####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9WsApi
{
<#
.SYNOPSIS
  Shows the Web Services API server information.
.DESCRIPTION
  The command displays the WSAPI server service configuration state as either Enabled or Disabled. It displays the server current running
  status as Active, Inactive or Error. It also displays the current status of the HTTP and HTTPS ports and their port numbers. WSAPI server URL is
  also displayed.
.EXAMPLE
    PS:> Get-A9WsApi

    service State                            : Enabled
    HPE GreenLake for Block Storage UI State : Active
    server State                             : Active
    HTTPS Port                               : 443
    Number of Sessions Created               : 0
    System Resource Usage                    : 192
    Number of Sessions Active                : 0
    Version                                  : 1.14.0
    Event Stream State                       : Enabled
    Max Number of SSE Sessions Allowed       : 5
    Number of SSE Sessions Created           : 0
    Number of SSE Sessions Active            : 0
    Session Timeout                          : 15 Minutes
    Policy                                   : no_per_user_limit
    API URL                                  : https://192.168.1.12/api/v1

.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  
)
Begin	
  { Test-A9Connection -ClientType 'SshClient' 
  }
Process
  { $Cmd = " showwsapi -d "
    write-verbose "Executing the following SSH command `n $cmd"
    $Result = Invoke-A9CLICommand -cmds  $Cmd
  }
end
  { $Data = $Result[1..$Result.count]
    $ReturnTable=[ordered]@{}
    foreach( $Line in $Data)
      {   $LabelName = ($Line.split(' : '))[0]
          $LabelName = $LabelName.trim(' ')
          $DataValue = ($Line.split(' : '))[1]
          $DataVAlue = $DataValue.trim(' ')
          $ReturnTable["$LabelName"] = $DataValue
      }
    $Result = $ReturnTable | convertto-json | convertfrom-json
    return $Result
  }
}

Function Get-A9WsapiSession
{
<#
.SYNOPSIS
  Show the Web Services API server sessions information.
.DESCRIPTION
  The command displays the WSAPI server sessions connection information, including the id, node, username, role, hostname,
  and IP Address of the connecting client. It also displays the session creation time and session type.
.EXAMPLE
	PS:> Get-A9WsapiSession
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{ $Cmd = " showwsapisession "
  write-verbose "Executing the following SSH command `n $cmd"
  $Result = Invoke-A9CLICommand -cmds  $Cmd
}
end
{  if($Result.Count -gt 2)
    { $range = $Result.count - 3
      $tempFile = [IO.Path]::GetTempFileName()
      foreach ($s in  $Result[0..$range] )
        { $s= [regex]::Replace($s,"^ +","")
          $s= [regex]::Replace($s," +"," ")
          $s= [regex]::Replace($s," ",",")
          $s= $s.Trim() -replace 'Id,Node,-Name--,-Role-,-Client_IP_Addr-,----Connected_since----,-State-,-Session_Type-','Id,Node,Name,Role,Client_IP_Addr,Connected_since,State,Session_Type'			
          Add-Content -Path $tempFile -Value $s
        }
      $returndata = Import-Csv $tempFile
      Remove-Item  $tempFile
      return $returndata
    }
	else
    {	return $Result
    } 
}
}

Function Remove-A9WsapiSession
{
<#
.SYNOPSIS
  Remove WSAPI user connections.
.DESCRIPTION
  The command removes the WSAPI user connections from the current system.
.EXAMPLE
	PS:> Remove-A9WsapiSession -Id "1537246327049685" -User_name 3parxyz -IP_address "10.10.10.10"
.PARAMETER Pattern
  Specifies that the <id>, <user_name> and <IP_address> specifiers are treated as glob-style (shell-style) patterns and all WSAPI user
  connections matching those patterns are removed. By default, confirmation is required to proceed with removing each connection
  unless the -f option is specified.
.PARAMETER Dr
  Specifies that the operation is a dry run and no connections are removed.
.PARAMETER Close_sse
  Specifies that the Server Sent Event (SSE) connection channel will be closed. WSAPI session credential for SSE will not be removed.
.PARAMETER id
  Specifies the Id of the WSAPI session connection to be removed.
.PARAMETER user_name
  Specifies the name of the WSAPI user to be removed.
.PARAMETER IP_address
  Specifies the IP address of the WSAPI user to be removed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  [Parameter()]           [switch]   $Pattern,
        [Parameter()]           [switch]   $DryRun,
        [Parameter()]           [switch]   $Close_sse,
        [Parameter(Mandatory)]  [String]  $Id,
        [Parameter(Mandatory)]  [String]  $User_name,
        [Parameter(Mandatory)]  [String]  $IP_address
)
Begin	
  {   Test-A9Connection -ClientType 'SshClient' 
  }
Process
  { $Cmd = " removewsapisession -f"
    if($Pattern)    {  $Cmd += " -pat "       }
    if($DryRun)     {  $Cmd += " -dr "        }
    if($Close_sse)  {  $Cmd += " $Close_sse " }
    if($Id)         {  $Cmd += " $Id "        }
    if($User_name)  {  $Cmd += " $User_name " }
    if($IP_address) {  $Cmd += " $IP_address " }
    write-verbose "Executing the following SSH command `n $cmd"
    $Result = Invoke-A9CLICommand -cmds  $Cmd
    Return $Result
  }
}

Function Set-A9Wsapi
{
<#
.SYNOPSIS
  Set the Web Services API server properties.
.DESCRIPTION
  The command sets properties of the Web Services API server, including options to enable or disable the HTTP and HTTPS ports.
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
.EXAMPLE
	PS:> Set-A9Wsapi -Policy tls_strict
.NOTES
	This command requires a SSH type connection.
  Authority: Super, Service
    Any role granted the wsapi_set right
  Usage:
  - Access to all domains is required to run this command.
  - When the Web Services API server is active, a warning message showing the current status of the Web Services API server is displayed and 
    you will be prompted for confirmation before continuing. The -f option forces the action without a warning message and prompt.
  - Setting the session timeout alone is not service affecting and will not restart the WSAPI server. However, if the timeout option 
    is specified along with service affecting options like -pol the WSAPI server will restart.
#>
[CmdletBinding()]
param(  [Parameter()] 	[ValidateSet('tls_strict','no_tls_strict','per_user_limit','no_per_user_limit')]
                        [String]	$Policy,
        [Parameter()] 	[ValidateRange(3,1440)]
                        [String]	$Timeout,
        [Parameter()] 	[ValidateSet('enable','disable')]
                        [String]	$Evtstream
)
Begin	
  {   Test-A9Connection -ClientType 'SshClient' 
  }
Process
  { $Cmd = " setwsapi -f "
    if($Policy)   {	$Cmd += " -pol $Pol " }
    if($Timeout)  {	$Cmd += " -timeout $Timeout " }
    if($Evtstream){	$Cmd += " -evtstream $Evtstream " }
    write-verbose "Executing the following SSH command `n $cmd"
    $Result = Invoke-A9CLICommand -cmds  $Cmd
    Return $Result
  }
}

Function Start-A9Wsapi
{
<#
.SYNOPSIS
  Start the Web Services API server to service HTTP and HTTPS requests.
.DESCRIPTION
  The command starts the Web Services API server to service HTTP and HTTPS requests.
  By default, the Web Services API server is not started until this command is issued.
.EXAMPLE
  PS:> Start-A9Wsapi
.NOTES
	This command requires a SSH type connection.
  Authority:Super, Service
    Any role granted the wsapi_start right
  Usage:
  - This command requires access to all domains.
  - Use the stopwsapi command to stop the Web Services API server and the Alletra UI.
  - The Web Services API server only listens for HTTPS requests.
#>
[CmdletBinding()]
param()
Begin	
  {   Test-A9Connection -ClientType 'SshClient' 
  }
Process
  { $cmd= " startwsapi "
    write-verbose "Executing the following SSH command `n $cmd"
    $Result = Invoke-A9CLICommand -cmds  $cmd 
    return $Result	
  }
}

Function Stop-A9Wsapi
{
<#
.SYNOPSIS
  Stop the Web Services API server. Future HTTP and HTTPS requests will be rejected.
.DESCRIPTION
  The command stops the Web Services API server from servicing HTTP and HTTPS requests.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  [Parameter()] [switch]  $Keep_UI
)
Begin	
  {   Test-A9Connection -ClientType 'SshClient' 
  }
Process
  { $Cmd = " stopwsapi -f "
    if ( $Keep_UI)  { $Cmd+= ' -keep_ui'}
    write-verbose "Executing the following SSH command `n $cmd"
    $Result = Invoke-A9CLICommand -cmds  $Cmd
    Return $Result
  }
}

