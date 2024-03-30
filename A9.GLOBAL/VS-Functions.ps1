####################################################################################
## 	© 2019,2020 Hewlett Packard Enterprise Development LP
##
##	File Name:		VS-Functions.psm1
##	Description: 	Common Module functions.
##		
##	Pre-requisites: Needs POSH SSH Module for New-PoshSshConnection
##					WSAPI uses array based HPE WSAPI service.
##					
##					Starting the WSAPI server    : The WSAPI server does not start automatically.
##					Using SSH, enter startwsapi to manually start the WSAPI server.
## 					Configuring the WSAPI server: To configure WSAPI, enter set-A9wsapi in the SSH command set.
##
##	Created:		June 2015
##	Last Modified:	March 2024
##
##	History:		v1.0 - Created
##					v2.0 - Added support for HP3PAR CLI
##                     v2.1 - Added support for POSH SSH Module
##					v2.2 - Added support for WSAPI
##                  v2.3 - Added Support for all CLI cmdlets
##                     v2.3.1 - Added support for primara array with wsapi
##                  v3.0 - Added Support for wsapi 1.7 
##                  v3.0 - Modularization
##                  v3.0.1 (07/30/2020) - Fixed the Show-RequestException function to show the actual error message
##					v3.5.0 (03/17/2024) - Refactored all commands. Removed CLI access. only uses SSH or WSAPI now.


Function Invoke-A9CLICommand 
{
<#
.SYNOPSIS
	Execute a command against a device using HP3PAR CLI
.DESCRIPTION
	Execute a command against a device using HP3PAR CLI
.PARAMETER Connection
	Pointer to an object that contains passwordfile, HP3parCLI installed path and IP address
.PARAMETER Cmds
	Command to be executed
.EXAMPLE		
	Invoke-A9CLICommand -Connection $global:SANConnection -Cmds "showsysmgr"

	The command queries a array to get the system information
	$global:SANConnection is created wiith the cmdlet New-CLIConnection or New-PoshSshConnection
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]	[string]	$Cmds  
	)
	if ( -not (Test-A9Connection -ClientType 'SshClient' -returnBoolean) ) 
		{	Write-Warning  "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-*Connection and pass it as parameter" 
			Write-Warning  "Stop: Exiting Invoke-A9CLICommand since connection object values are null/empty"
			return
		}
	$Result = Invoke-SSHCommand -Command $Cmds -SessionId $SANConnection.SessionId
	if ($Result.ExitStatus -eq 0) 	
		{	return $Result.Output	}
	else{	$ErrorString = "Error :-" + $Result.Error + $Result.Output			    
			return $ErrorString
		}	
}

function Invoke-A9API 
{
[CmdletBinding()]
Param (	[parameter(Mandatory = $true, HelpMessage = "Enter the resource URI (ex. /volumes)")]
		[ValidateScript( { if ($_.startswith('/')) { $true } else { throw "-URI must begin with a '/' (eg. /volumes) in its value. Correct the value and try again." } })]
		[string]	$uri,
		
		[parameter(Mandatory = $true)][ValidateSet('GET','POST','DELETE')]
		[string]	$type,
		
		[parameter()]
		[array]		$body,
		
		[Parameter()]
		$WsapiConnection = $global:WsapiConnection
	)
	Write-Verbose  "Request: Request Invoke-A9API URL : $uri TYPE : $type " 
	$ip = $WsapiConnection.IPAddress
	$key = $WsapiConnection.Key
	$arrtyp = $global:ArrayType
	if ($arrtyp.ToLower() -eq "3par") {
		$APIurl = 'https://' + $ip + ':8080/api/v1' 	
	}
	Elseif(($arrtyp.ToLower() -eq "primera") -or ($arrtyp.ToLower() -eq "alletra9000")) 
		{	$APIurl = 'https://' + $ip + ':443/api/v1'	
		}
	else{	return "Array type is Null."
		}
	$url = $APIurl + $uri
	Write-Verbose  "Running: Constructing header." 
	$headers = @{}
	$headers["Accept"] = "application/json"
	$headers["Accept-Language"] = "en"
	$headers["Content-Type"] = "application/json"
	$headers["X-HP3PAR-WSAPI-SessionKey"] = $key
	$data = $null
	If ($type -eq 'GET') 
		{	Try 	{	if ($PSEdition -eq 'Core') 
							{	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
							} 
						else{	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
							}
						return $data
					}
			Catch 	{	$_
						return
					}
		}
	If (($type -eq 'POST') -or ($type -eq 'PUT')) 
		{	Try {	Write-Verbose  "Request: Invoke-WebRequest for Data, Request Type : $type" 
					$json = $body | ConvertTo-Json  -Compress -Depth 10	
					if ($PSEdition -eq 'Core') 
						{	$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
						}
					else{	$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing 
						}
					return $data
				}
			Catch 	
				{	$_
					return
				}
		}
	If ($type -eq 'DELETE') 
		{	Try {	if ($PSEdition -eq 'Core') 
						{	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
						} 
					else{    $data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
						}
					return $data
				}
			Catch 
				{	$_
					return
				}
		}
}


