## 	©2025 Hewlett Packard Enterprise Development LP

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
Param(	[Parameter(Mandatory)]	[string]	$Cmds  
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
<# 
.SYNOPSIS
	This is an internal command that is used to actually issue an API call. 
.DESCRIPTION
	This is an internal command that is used to actually issue an API call. This command acts as a wrapper for the Invoke-RestAPI command but adds all the needed logic and headers to make connections successful.
.PARAMETER uri
	The command automatically adds the appropriate HTTPS: to the front as well as the IP Address currently connected to and the port number as dictated by the array type.
	So the 'HTTPS://IPAddress:Port/api/v1' is prefixed to each URI, so a command might only have to send a '/volumes/vol1' to complete a call.
.PARAMETER type
	This allow a call to prescribe what type of call is being made, either a Get, Put, Delete or Post which match the restAPI CRUD (Create Update Read and Delete)
.PARAMETER body
	If a body needs to be sent, this is included in this parameter.
.PARAMETER WsapiConnection
	By default this uses the currently open connected object. 
#>
[CmdletBinding()]
Param (	[parameter(Mandatory, HelpMessage = "Enter the resource URI (ex. /volumes)")]
		[ValidateScript( { if ($_.startswith('/')) { $true } else { throw "-URI must begin with a '/' (eg. /volumes) in its value. Correct the value and try again." } })]
		[string]	$uri,
		
		[parameter(Mandatory)][ValidateSet('GET','POST','DELETE','PUT')]
		[string]	$type,
		
		[parameter()]
		[array]		$body,
		
		[Parameter()]
		$WsapiConnection = $global:WsapiConnection,

		[parameter()]
		[switch]	$WhatIf
	)
	 
	$ip = $WsapiConnection.IPAddress
	$key = $WsapiConnection.Key
	$arrtype = $global:ArrayType
	write-verbose "Arraytype = $ArrayType"
	$APIurl='https://'
	if ($arrtype -like "3Par") 
		{	$APIurl = $APIurl + $ip + ':8080/api/v1' 
			write-verbose "Arraytpe detected 3PAR"	
		}
	Elseif(($arrtype -like "Primera") -or ($arrtype -like "Alletra9000") -or ($arrtype -like "AlletraMP-B10000")) 
		{	$APIurl = $APIurl + $ip + ':443/api/v1'	
			write-verbose "arraytype is primera or alletra9k or AlletraB10000"
		}
	else{	return "Array type is Null."
		}
	$url = $APIurl + $uri
	Write-Verbose  "Request: Request Invoke-A9API URL : $url TYPE : $type "
	Write-Verbose  "Running: Constructing header." 
	$headers = @{}
	$headers["Accept"] = "application/json"
	$headers["Accept-Language"] = "en"
	$headers["Content-Type"] = "application/json"
	$headers["X-HP3PAR-WSAPI-SessionKey"] = $key
	$data = $null
	if ( $WhatIf )
		{	Write-host "The What-IF option was used, so instead of running this API command, I will simply display the API command that would have been used instead." -ForegroundColor green
			write-host "The URL that the command was going to be sent to was;`n`t " -ForegroundColor green -nonewline
			write-host $url -ForegroundColor yellow
			$OutHeader = $headers | convertto-json -depth 5 
			write-host "The Header of attached to the RestAPI call was going to be; `n`t" -nonewline -foregroundcolor green 
			write-host $OutHeader -foregroundcolor yellow
			write-host "The type of operation being sent was going to be a " -nonewline -foregroundcolor green 
			write-host $type -foregroundcolor yellow -nonewline 
			write-host " Operation;" -foregroundcolor green
			$OutBody = $Body | convertto-json -depth 5 | out-string
			write-host "The BODY of the RestAPI call was going to be; `n`t " -nonewline -foregroundcolor green 
			write-host $OutBody -foregroundcolor yellow
			return
		}
	write-verbose "Request: URL Header is as follows $headers"
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
		{	Write-Verbose  "Request: Invoke-WebRequest for Data, Request Type : $type" 
			$json = $body | ConvertTo-Json  -Compress -Depth 10
			write-verbose "This is the Body `n $json"			
			Try {	if ($PSEdition -eq 'Core') 
						{	$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
						}
					else{	$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing 
						}
					return $data
				}
			Catch 	
				{	write-error $_
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

