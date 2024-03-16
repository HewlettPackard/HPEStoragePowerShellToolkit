####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9Wsapi_CLI
{
<#
  .SYNOPSIS
  Shows the Web Services API server information.
.DESCRIPTION
  The command displays the WSAPI server service configuration state as either Enabled or Disabled. It displays the server current running
  status as Active, Inactive or Error. It also displays the current status of the HTTP and HTTPS ports and their port numbers. WSAPI server URL is
  also displayed.
.EXAMPLE
    Get-A9Wsapi_CLI -D
.PARAMETER D
    Shows WSAPI information in table format.
#>
[CmdletBinding()]
param(  [Parameter()] [switch]	$D
)
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{ $Cmd = " showwsapi "
  if($D)  {	$Cmd += " -d " }
  $Result = Invoke-CLICommand -cmds  $Cmd
  if($Result -match "-Service-")
    {	$range = $Result.count
      $tempFile = [IO.Path]::GetTempFileName()
      foreach ($s in  $Result[0..$range] )
        { $s= [regex]::Replace($s,"^ +","")
          $s= [regex]::Replace($s," +"," ")
          $s= [regex]::Replace($s," ",",")
          $s= $s.Trim() -replace '-Service-,-State-,-HTTP_State-,HTTP_Port,-HTTPS_State-,HTTPS_Port,-Version-,-------------API_URL--------------','Service,State,HTTP_State,HTTP_Port,HTTPS_State,HTTPS_Port,ersion,API_URL'			
          Add-Content -Path $tempFile -Value $s
        }
      Import-Csv $tempFile
      Remove-Item  $tempFile
    }
  else{  return $Result  }
}
}

Function Get-A9WsapiSession_CLI
{
<#
.SYNOPSIS
  Get-A9WsapiSession_CLI - Show the Web Services API server sessions information.
.DESCRIPTION
  The Get-WsapiSession command displays the WSAPI server sessions connection information, including the id, node, username, role, hostname,
  and IP Address of the connecting client. It also displays the session creation time and session type.
.EXAMPLE
	Get-A9WsapiSession_CLI
#>
[CmdletBinding()]
param()
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{ $Cmd = " showwsapisession "
  $Result = Invoke-CLICommand -cmds  $Cmd
	if($Result.Count -gt 2)
    { $range = $Result.count - 3
      $tempFile = [IO.Path]::GetTempFileName()
      foreach ($s in  $Result[0..$range] )
        { $s= [regex]::Replace($s,"^ +","")
          $s= [regex]::Replace($s," +"," ")
          $s= [regex]::Replace($s," ",",")
          $s= $s.Trim() -replace 'Id,Node,-Name--,-Role-,-Client_IP_Addr-,----Connected_since----,-State-,-Session_Type-','Id,Node,Name,Role,Client_IP_Addr,Connected_since,State,Session_Type'			
          Add-Content -Path $tempFile -Value $s
        }
      Import-Csv $tempFile
      Remove-Item  $tempFile
    }
	else
    {	return $Result
    } 
}
}

Function Remove-A9WsapiSession_CLI
{
<#
.SYNOPSIS
  Remove WSAPI user connections.
.DESCRIPTION
  The command removes the WSAPI user connections from the current system.
.EXAMPLE
	Remove-A9WsapiSession_CLI -Id "1537246327049685" -User_name 3parxyz -IP_address "10.10.10.10"
.PARAMETER Pat
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
#>
[CmdletBinding()]
param(  [Parameter()]   [switch]   $Pat,
        [Parameter()]   [switch]   $Dr,
        [Parameter()]   [switch]   $Close_sse,
        [Parameter(Mandatory=$true)]  [String]  $Id,
        [Parameter(Mandatory=$true)]  [String]  $User_name,
        [Parameter(Mandatory=$true)]  [String]  $IP_address
)
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{ $Cmd = " removewsapisession -f"
  if($Pat)        {  $Cmd += " -pat "       }
  if($Dr)         {  $Cmd += " -dr "        }
  if($Close_sse)  {  $Cmd += " $Close_sse " }
  if($Id)         {  $Cmd += " $Id "        }
  if($User_name)  {  $Cmd += " $User_name " }
  if($IP_address) {  $Cmd += " IP_address " }
  $Result = Invoke-CLICommand -cmds  $Cmd
  Return $Result
}
}


Function Set-A9Wsapi_CLI
{
<#
.SYNOPSIS
  Set the Web Services API server properties.
.DESCRIPTION
  The command sets properties of the Web Services API server, including options to enable or disable the HTTP and HTTPS ports.
.EXAMPLE
	Set-A9Wsapi_CLI -Force -Enable_Http
.PARAMETER Force
  Forces the operation of the setwsapi command, bypassing the typical confirmation message. At least one of the following options are required:
.PARAMETER Pol
  Sets the WSAPI server policy:
    tls_strict       - only TLS connections using TLS 1.2 with secure ciphers will be accepted if HTTPS is enabled. This is the default policy setting.
    no_tls_strict    - TLS connections using TLS 1.0 - 1.2 will be accepted if HTTPS is enabled.
.PARAMETER Timeout
  Specifies the value that can be set for the idle session timeout for a WSAPI session. <value> is a positive integer and in the range
  of 3-1440 minutes or (3 minutes to 24 hours). Changing the session timeout takes effect immediately and will affect already opened and
  subsequent WSAPI sessions. The default timeout value is 15 minutes.
.PARAMETER Evtstream
  Enables or disables the event stream feature. This supports Server Sent Event (SSE) protocol. The default value is enable.
#>
[CmdletBinding()]
param(  [Parameter()]   [switch]	$Force,
        [Parameter()] 	[String]	$Pol,
        [Parameter()] 	[String]	$Timeout,
        [Parameter()] 	[String]	$Evtstream
)
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{ $Cmd = " setwsapi "
  if($Force)    {	$Cmd += " -f "}
  if($Pol)      {	$Cmd += " -pol $Pol " }
  if($Timeout)  {	$Cmd += " -timeout $Timeout " }
  if($Evtstream){	$Cmd += " -evtstream $Evtstream " }
  $Result = Invoke-CLICommand -cmds  $Cmd
  Return $Result
}
}

Function Start-A9Wsapi_CLI
{
<#
.SYNOPSIS
  Start the Web Services API server to service HTTP and HTTPS requests.
.DESCRIPTION
  The command starts the Web Services API server to service HTTP and HTTPS requests.
  By default, the Web Services API server is not started until this command is issued.
.EXAMPLE
  Start-A9Wsapi_CLI
#>
[CmdletBinding()]
param()
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{ $cmd= " startwsapi "
  $Result = Invoke-CLICommand -cmds  $cmd 
  return $Result	
}
}

Function Stop-A9Wsapi_CLI
{
<#
.SYNOPSIS
  Stop the Web Services API server. Future HTTP and HTTPS requests will be rejected.
.DESCRIPTION
  The command stops the Web Services API server from servicing HTTP and HTTPS requests.
#>
[CmdletBinding()]
param()
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{ $Cmd = " stopwsapi -f "
  $Result = Invoke-CLICommand -cmds  $Cmd
  Return $Result
}
}

