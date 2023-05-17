####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
##	File Name:		ConfigWebServicesAPI.psm1
##	Description: 	Configure Web Services API cmdlets 
##		
##	Created:		January 2020
##	Last Modified:	January 2020
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## FUNCTION Test-CLIObject
############################################################################################################################################
Function Test-CLIObject 
{
Param( 	
    [string]$ObjectType, 
	[string]$ObjectName ,
	[string]$ObjectMsg = $ObjectType, 
	$SANConnection = $global:SANConnection
	)

	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")
	{
		$IsObjectExisted = $false
	}
	return $IsObjectExisted
	
} # End FUNCTION Test-CLIObject

##########################################################################
#########################FUNCTION Get-Wsapi#########################
##########################################################################
Function Get-Wsapi()
{
<#
  .SYNOPSIS
   Get-Wsapi - Show the Web Services API server information.

  .DESCRIPTION
   The Get-Wsapi command displays the WSAPI server service configuration state
   as either Enabled or Disabled. It displays the server current running
   status as Active, Inactive or Error. It also displays the current status
   of the HTTP and HTTPS ports and their port numbers. WSAPI server URL is
   also displayed.

  .EXAMPLE
   Get-Wsapi -D

  .PARAMETER D
   Shows WSAPI information in table format.

  .PARAMETER SANConnection 
   Specify the SAN Connection object created with new-SANConnection  
   
  .Notes
    NAME: Get-Wsapi
    LASTEDIT January 2020
    KEYWORDS: Get-Wsapi
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[switch]
	$D,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Get-Wsapi - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-SANConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Get-Wsapi since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Get-Wsapi since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

 $Cmd = " showwsapi "

 if($D)
 {
	$Cmd += " -d "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Get-Wsapi Command -->" INFO: 
 
 if($Result -match "-Service-")
	{
		$range = $Result.count
		$tempFile = [IO.Path]::GetTempFileName()
		foreach ($s in  $Result[0..$range] )
		{			
			$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			$s= $s.Trim() -replace '-Service-,-State-,-HTTP_State-,HTTP_Port,-HTTPS_State-,HTTPS_Port,-Version-,-------------API_URL--------------','Service,State,HTTP_State,HTTP_Port,HTTPS_State,HTTPS_Port,ersion,API_URL'			
			Add-Content -Path $tempFile -Value $s
		}
		Import-Csv $tempFile
		del $tempFile
	}
	else
	{
		return $Result
	}
 
} ##  End-of Get-Wsapi

##########################################################################
#########################FUNCTION Get-WsapiSession#########################
##########################################################################
Function Get-WsapiSession()
{
<#
  .SYNOPSIS
   Get-WsapiSession - Show the Web Services API server sessions information.

  .DESCRIPTION
   The Get-WsapiSession command displays the WSAPI server sessions
   connection information, including the id, node, username, role, hostname,
   and IP Address of the connecting client. It also displays the session
   creation time and session type.

  .EXAMPLE
	Get-WsapiSession
  
  .PARAMETER SANConnection 
   Specify the SAN Connection object created with new-SANConnection
   
  .Notes
    NAME: Get-WsapiSession
    LASTEDIT January 2020
    KEYWORDS: Get-WsapiSession
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
 [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
 $SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Get-WsapiSession - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
  #check if connection object contents are null/empty
  $Validate1 = Test-CLIConnection $SANConnection
  if($Validate1 -eq "Failed")
  {
    #check if global connection object contents are null/empty
    $Validate2 = Test-CLIConnection $global:SANConnection
    if($Validate2 -eq "Failed")
    {
        Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-SANConnection" " ERR: "
        Write-DebugLog "Stop: Exiting Get-WsapiSession since SAN connection object values are null/empty" $Debug 
        Return "Unable to execute the cmdlet Get-WsapiSession since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
    }
  }
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " showwsapisession "

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Get-WsapiSession Command" INFO: 
	if($Result.Count -gt 2)
	{
		$range = $Result.count - 3
		$tempFile = [IO.Path]::GetTempFileName()
		foreach ($s in  $Result[0..$range] )
		{			
			$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			$s= $s.Trim() -replace 'Id,Node,-Name--,-Role-,-Client_IP_Addr-,----Connected_since----,-State-,-Session_Type-','Id,Node,Name,Role,Client_IP_Addr,Connected_since,State,Session_Type'			
			Add-Content -Path $tempFile -Value $s
		}
		Import-Csv $tempFile
		del $tempFile
	}
	else
	{
		return $Result
	} 
 
} ##  End-of Get-WsapiSession

##########################################################################
#########################FUNCTION Remove-WsapiSession#########################
##########################################################################
Function Remove-WsapiSession()
{
<#
  .SYNOPSIS
   Remove-WsapiSession - Remove WSAPI user connections.

  .DESCRIPTION
   The Remove-WsapiSession command removes the WSAPI user connections from the
   current system.

  .EXAMPLE
	Remove-WsapiSession -Id "1537246327049685" -User_name 3parxyz -IP_address "10.10.10.10"
	
  .PARAMETER Pat
   Specifies that the <id>, <user_name> and <IP_address> specifiers
   are treated as glob-style (shell-style) patterns and all WSAPI user
   connections matching those patterns are removed. By default,
   confirmation is required to proceed with removing each connection
   unless the -f option is specified.

  .PARAMETER Dr
   Specifies that the operation is a dry run and no connections are
   removed.

  .PARAMETER Close_sse
   Specifies that the Server Sent Event (SSE) connection channel will be
   closed. WSAPI session credential for SSE will not be removed.

  .PARAMETER id
   Specifies the Id of the WSAPI session connection to be removed.

  .PARAMETER user_name
   Specifies the name of the WSAPI user to be removed.

  .PARAMETER IP_address
   Specifies the IP address of the WSAPI user to be removed.
   
  .PARAMETER SANConnection 
   Specify the SAN Connection object created with new-SANConnection
   
  .Notes
    NAME: Remove-WsapiSession
    LASTEDIT January 2020
    KEYWORDS: Remove-WsapiSession
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
 [Parameter(Position=0, Mandatory=$false)]
 [switch]
 $Pat,

 [Parameter(Position=1, Mandatory=$false)]
 [switch]
 $Dr,

 [Parameter(Position=3, Mandatory=$false)]
 [switch]
 $Close_sse,

 [Parameter(Position=4, Mandatory=$true)]
 [System.String]
 $Id,

 [Parameter(Position=5, Mandatory=$true)]
 [System.String]
 $User_name,

 [Parameter(Position=6, Mandatory=$true)]
 [System.String]
 $IP_address,

 [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
 $SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Remove-WsapiSession - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
  #check if connection object contents are null/empty
  $Validate1 = Test-CLIConnection $SANConnection
  if($Validate1 -eq "Failed")
  {
    #check if global connection object contents are null/empty
    $Validate2 = Test-CLIConnection $global:SANConnection
    if($Validate2 -eq "Failed")
    {
        Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-SANConnection" " ERR: "
        Write-DebugLog "Stop: Exiting Remove-WsapiSession since SAN connection object values are null/empty" $Debug 
        Return "Unable to execute the cmdlet Remove-WsapiSession since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
    }
  }
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " removewsapisession -f"

 if($Pat)
 {
  $Cmd += " -pat "
 }

 if($Dr)
 {
  $Cmd += " -dr "
 }
 if($Close_sse)
 {
  $Cmd += " $Close_sse "
 }

 if($Id)
 {
  $Cmd += " $Id "
 }

 if($User_name)
 {
  $Cmd += " $User_name "
 }

 if($IP_address)
 {
  $Cmd += " IP_address "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Remove-WsapiSession Command --> " INFO: 
 Return $Result
} ##  End-of Remove-WsapiSession

##########################################################################
#########################FUNCTION Set-Wsapi#########################
##########################################################################
Function Set-Wsapi()
{
<#
  .SYNOPSIS
   Set-Wsapi - Set the Web Services API server properties.

  .DESCRIPTION
   The Set-Wsapi command sets properties of the Web Services API server,
   including options to enable or disable the HTTP and HTTPS ports.

  .EXAMPLE
	Set-Wsapi -Force -Enable_Http

  .PARAMETER Force
   Forces the operation of the setwsapi command, bypassing the typical
   confirmation message.
   At least one of the following options are required:

  .PARAMETER Pol
   Sets the WSAPI server policy:
   tls_strict       - only TLS connections using TLS 1.2 with
   secure ciphers will be accepted if HTTPS is
   enabled. This is the default policy setting.
   no_tls_strict    - TLS connections using TLS 1.0 - 1.2 will be
   accepted if HTTPS is enabled.

  .PARAMETER Timeout
   Specifies the value that can be set for the idle session timeout for
   a WSAPI session. <value> is a positive integer and in the range
   of 3-1440 minutes or (3 minutes to 24 hours). Changing the session
   timeout takes effect immediately and will affect already opened and
   subsequent WSAPI sessions.
   The default timeout value is 15 minutes.

  .PARAMETER Evtstream
   Enables or disables the event stream feature. This supports Server
   Sent Event (SSE) protocol.
   The default value is enable.
   
  .PARAMETER SANConnection 
   Specify the SAN Connection object created with new-SANConnection
   
  .Notes
    NAME: Set-Wsapi
    LASTEDIT January 2020
    KEYWORDS: Set-Wsapi
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[switch]
	$Force,

	[Parameter(Position=1, Mandatory=$false)]
	[System.String]
	$Pol,

	[Parameter(Position=2, Mandatory=$false)]
	[System.String]
	$Timeout,

	[Parameter(Position=3, Mandatory=$false)]
	[System.String]
	$Evtstream,

	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Set-Wsapi - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-SANConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Set-Wsapi since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Set-Wsapi since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

	$Cmd = " setwsapi "

 if($Force)
 {
	$Cmd += " -f "
 }

 if($Pol)
 {
	$Cmd += " -pol $Pol "
 }

 if($Timeout)
 {
	$Cmd += " -timeout $Timeout "
 }

 if($Evtstream)
 {
	$Cmd += " -evtstream $Evtstream "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Set-Wsapi Command --> " INFO: 
 
 Return $Result
} ##  End-of Set-Wsapi

##########################################################################
#########################FUNCTION Start-Wsapi#########################
##########################################################################
Function Start-Wsapi()
{
<#
  .SYNOPSIS
   Start-Wsapi - Start the Web Services API server to service HTTP and HTTPS requests.

  .DESCRIPTION
   The Start-Wsapi command starts the Web Services API server to service
   HTTP and HTTPS requests.
   By default, the Web Services API server is not started until this
   command is issued.

  .EXAMPLE
   Start-Wsapi

  .Notes
    NAME: Start-Wsapi
    LASTEDIT January 2020
    KEYWORDS: Start-Wsapi
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	 [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	 $SANConnection = $global:SANConnection
 )
 
 Write-DebugLog "Start: In Start-Wsapi - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-SANConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Start-Wsapi since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Start-Wsapi since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }
 
	$cmd= " startwsapi "
 
 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd 
 
	return $Result	
 
}
#End Of Start-Wsapi

##########################################################################
#########################FUNCTION Stop-Wsapi#########################
##########################################################################
Function Stop-Wsapi()
{
<#
  .SYNOPSIS
   Stop-Wsapi - Stop the Web Services API server. Future HTTP and HTTPS requests
   will be rejected.

  .DESCRIPTION
   The Stop-Wsapi command stops the Web Services API server from servicing
   HTTP and HTTPS requests.

  .EXAMPLE
	Stop-Wsapi

  .Notes
    NAME: Stop-Wsapi
    LASTEDIT January 2020
    KEYWORDS: Stop-Wsapi
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Stop-Wsapi - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-SANConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Stop-Wsapi since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Stop-Wsapi since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

 $Cmd = " stopwsapi -f "

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Stop-Wsapi Command -->" INFO: 
 
 Return $Result
} ##  End-of Stop-Wsapi

Export-ModuleMember Get-Wsapi , Get-WsapiSession , Remove-WsapiSession , Set-Wsapi , Start-Wsapi , Stop-Wsapi
# SIG # Begin signature block
# MIIhzwYJKoZIhvcNAQcCoIIhwDCCIbwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDdjChUUFPwoDsU
# /B/y5BA1MHJim+fB+EnTRvT+QxbsZ6CCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIQejCCEHYCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# J9BCtt3AEdzGTlagmNwB5RQCofu7f1jwRz58J2okUP0wDQYJKoZIhvcNAQEBBQAE
# ggEA5VsZE2m43VZ1IOFg4m4F2cONt9JRLuIg/5Mxu8LpS/1s0De74KrmrSGARvH0
# dsF851cobiOJ+SFMMeeWluNs7wV991uFScU4kamYhHHlrsAuffuxi2jq3WIuYncv
# At6wiOl8v8oZnnsHYx+R7cJt8Jads6J9DrraehG13U2pRtO7LU/bdaQwJMt1WtU9
# 0YRblLcAGzjOWdn2YPJT/fcZIKCPP7576lzsS1xxjjTBNCw4bqeJytZOR6EGqbZg
# ov1DbiT5IGcIc7liJwN/armPk0xaoiw4KDWo0+5SOLi7yBCht0p/sRAx4lt6/Zan
# 3P3uhtSzFDgU3CZnFfASCDo+I6GCDjwwgg44BgorBgEEAYI3AwMBMYIOKDCCDiQG
# CSqGSIb3DQEHAqCCDhUwgg4RAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDgYLKoZIhvcN
# AQkQAQSggf4EgfswgfgCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# IKsixDcMssM/wU9Y5LVv5m8UV4SSbE9lte4+9G8qmdH8AhRLWQYqFtLhW4QQ612U
# jDDsAaIuERgPMjAyMTA2MTkwNDAyNDNaMAMCAR6ggYakgYMwgYAxCzAJBgNVBAYT
# AlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3lt
# YW50ZWMgVHJ1c3QgTmV0d29yazExMC8GA1UEAxMoU3ltYW50ZWMgU0hBMjU2IFRp
# bWVTdGFtcGluZyBTaWduZXIgLSBHM6CCCoswggU4MIIEIKADAgECAhB7BbHUSWhR
# RPfJidKcGZ0SMA0GCSqGSIb3DQEBCwUAMIG9MQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdv
# cmsxOjA4BgNVBAsTMShjKSAyMDA4IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhv
# cml6ZWQgdXNlIG9ubHkxODA2BgNVBAMTL1ZlcmlTaWduIFVuaXZlcnNhbCBSb290
# IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE2MDExMjAwMDAwMFoXDTMxMDEx
# MTIzNTk1OVowdzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBv
# cmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMSgwJgYDVQQD
# Ex9TeW1hbnRlYyBTSEEyNTYgVGltZVN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAu1mdWVVPnYxyXRqBoutV87ABrTxxrDKPBWuGmicA
# MpdqTclkFEspu8LZKbku7GOz4c8/C1aQ+GIbfuumB+Lef15tQDjUkQbnQXx5HMvL
# rRu/2JWR8/DubPitljkuf8EnuHg5xYSl7e2vh47Ojcdt6tKYtTofHjmdw/SaqPSE
# 4cTRfHHGBim0P+SDDSbDewg+TfkKtzNJ/8o71PWym0vhiJka9cDpMxTW38eA25Hu
# /rySV3J39M2ozP4J9ZM3vpWIasXc9LFL1M7oCZFftYR5NYp4rBkyjyPBMkEbWQ6p
# PrHM+dYr77fY5NUdbRE6kvaTyZzjSO67Uw7UNpeGeMWhNwIDAQABo4IBdzCCAXMw
# DgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwZgYDVR0gBF8wXTBb
# BgtghkgBhvhFAQcXAzBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Quc3ltY2IuY29t
# L2NwczAlBggrBgEFBQcCAjAZGhdodHRwczovL2Quc3ltY2IuY29tL3JwYTAuBggr
# BgEFBQcBAQQiMCAwHgYIKwYBBQUHMAGGEmh0dHA6Ly9zLnN5bWNkLmNvbTA2BgNV
# HR8ELzAtMCugKaAnhiVodHRwOi8vcy5zeW1jYi5jb20vdW5pdmVyc2FsLXJvb3Qu
# Y3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMIMCgGA1UdEQQhMB+kHTAbMRkwFwYDVQQD
# ExBUaW1lU3RhbXAtMjA0OC0zMB0GA1UdDgQWBBSvY9bKo06FcuCnvEHzKaI4f4B1
# YjAfBgNVHSMEGDAWgBS2d/ppSEefUxLVwuoHMnYH0ZcHGTANBgkqhkiG9w0BAQsF
# AAOCAQEAdeqwLdU0GVwyRf4O4dRPpnjBb9fq3dxP86HIgYj3p48V5kApreZd9KLZ
# VmSEcTAq3R5hF2YgVgaYGY1dcfL4l7wJ/RyRR8ni6I0D+8yQL9YKbE4z7Na0k8hM
# kGNIOUAhxN3WbomYPLWYl+ipBrcJyY9TV0GQL+EeTU7cyhB4bEJu8LbF+GFcUvVO
# 9muN90p6vvPN/QPX2fYDqA/jU/cKdezGdS6qZoUEmbf4Blfhxg726K/a7JsYH6q5
# 4zoAv86KlMsB257HOLsPUqvR45QDYApNoP4nbRQy/D+XQOG/mYnb5DkUvdrk08Pq
# K1qzlVhVBH3HmuwjA42FKtL/rqlhgTCCBUswggQzoAMCAQICEHvU5a+6zAc/oQEj
# BCJBTRIwDQYJKoZIhvcNAQELBQAwdzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5
# bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3
# b3JrMSgwJgYDVQQDEx9TeW1hbnRlYyBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4X
# DTE3MTIyMzAwMDAwMFoXDTI5MDMyMjIzNTk1OVowgYAxCzAJBgNVBAYTAlVTMR0w
# GwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMg
# VHJ1c3QgTmV0d29yazExMC8GA1UEAxMoU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFt
# cGluZyBTaWduZXIgLSBHMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AK8Oiqr43L9pe1QXcUcJvY08gfh0FXdnkJz93k4Cnkt29uU2PmXVJCBtMPndHYPp
# PydKM05tForkjUCNIqq+pwsb0ge2PLUaJCj4G3JRPcgJiCYIOvn6QyN1R3AMs19b
# jwgdckhXZU2vAjxA9/TdMjiTP+UspvNZI8uA3hNN+RDJqgoYbFVhV9HxAizEtavy
# bCPSnw0PGWythWJp/U6FwYpSMatb2Ml0UuNXbCK/VX9vygarP0q3InZl7Ow28paV
# gSYs/buYqgE4068lQJsJU/ApV4VYXuqFSEEhh+XetNMmsntAU1h5jlIxBk2UA0XE
# zjwD7LcA8joixbRv5e+wipsCAwEAAaOCAccwggHDMAwGA1UdEwEB/wQCMAAwZgYD
# VR0gBF8wXTBbBgtghkgBhvhFAQcXAzBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Qu
# c3ltY2IuY29tL2NwczAlBggrBgEFBQcCAjAZGhdodHRwczovL2Quc3ltY2IuY29t
# L3JwYTBABgNVHR8EOTA3MDWgM6Axhi9odHRwOi8vdHMtY3JsLndzLnN5bWFudGVj
# LmNvbS9zaGEyNTYtdHNzLWNhLmNybDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwdwYIKwYBBQUHAQEEazBpMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wOwYIKwYBBQUHMAKGL2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3NoYTI1Ni10c3MtY2EuY2VyMCgGA1UdEQQh
# MB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC02MB0GA1UdDgQWBBSlEwGp
# n4XMG24WHl87Map5NgB7HTAfBgNVHSMEGDAWgBSvY9bKo06FcuCnvEHzKaI4f4B1
# YjANBgkqhkiG9w0BAQsFAAOCAQEARp6v8LiiX6KZSM+oJ0shzbK5pnJwYy/jVSl7
# OUZO535lBliLvFeKkg0I2BC6NiT6Cnv7O9Niv0qUFeaC24pUbf8o/mfPcT/mMwnZ
# olkQ9B5K/mXM3tRr41IpdQBKK6XMy5voqU33tBdZkkHDtz+G5vbAf0Q8RlwXWuOk
# O9VpJtUhfeGAZ35irLdOLhWa5Zwjr1sR6nGpQfkNeTipoQ3PtLHaPpp6xyLFdM3f
# RwmGxPyRJbIblumFCOjd6nRgbmClVnoNyERY3Ob5SBSe5b/eAL13sZgUchQk38cR
# LB8AP8NLFMZnHMweBqOQX1xUiz7jM1uCD8W3hgJOcZ/pZkU/djGCAlowggJWAgEB
# MIGLMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlv
# bjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEoMCYGA1UEAxMfU3lt
# YW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQe9Tlr7rMBz+hASMEIkFNEjAL
# BglghkgBZQMEAgGggaQwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqG
# SIb3DQEJBTEPFw0yMTA2MTkwNDAyNDNaMC8GCSqGSIb3DQEJBDEiBCCiJcKHhxWF
# 6ASkVYLi4GaaacS/PcPQnoCjX6cdnPNRLTA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCDEdM52AH0COU4NpeTefBTGgPniggE8/vZT7123H99h+DALBgkqhkiG9w0BAQEE
# ggEAAYCvXOc8YWwfzuBWF3QqX+4FwDnGxHQfSVPikftQMixtJ/C7/ibAjParIc1M
# NymfZXNJHm4LTDeEXXlrSYE/DcQNhNoGtdDcyUJ3uNUIcWTkv8sVQA4/0Tc5DWFc
# 2+hDCeCw2hAFbCKxbDFTZD9U26tH7Gowfq0q/WSUGgRCOs/kkVvu54BszJlSbUBo
# 5ueqLnFqU7S24nYj8bh1E/2d1Yf4wlq8ycJ7q6r27rDwPpzQDiJl5dbSVgY+Y8U2
# GTg7Xa4T8BZJjGzT5ypFjpHbCCIRWajiImbpJ2L+wfD/P/c4MZZ09f5AJEhti2V6
# sya/zn4rANLlnjhQklYsYr9BQw==
# SIG # End signature block
