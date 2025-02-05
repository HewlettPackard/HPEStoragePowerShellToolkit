####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
## 

function Invoke-A9API 
{
[CmdletBinding()]
Param (	[parameter(Mandatory = $true, HelpMessage = "Enter the resource URI (ex. /volumes)")]
		[ValidateScript( { if ($_.startswith('/')) { $true } else { throw "-URI must begin with a '/' (eg. /volumes) in its value. Correct the value and try again." } })]
		[string]	$uri,
		
		[parameter(Mandatory = $true, HelpMessage = "Enter request type (GET POST DELETE)")]
		[string]	$type,
		
		[parameter(HelpMessage = "Body of the message")]
		[array]		$body,
		
		[Parameter(ValueFromPipeline = $true)]
					$WsapiConnection = $global:WsapiConnection
	)
Process
{	Write-verbose "Invoke-A9API: Request: Request Invoke-A9API URL : $uri TYPE : $type "   
	$ip = $WsapiConnection.IPAddress
	$key = $WsapiConnection.Key
	if 		($ArrayType -eq "3par") 		{	$APIurl = 'https://' + $ip + ':8080/api/v1' }
	Elseif (($ArrayType -eq "Primera") -or ($ArrayType -eq "Alletra9000") -or ($ArrayType -eq 'AlletraMP-B10000')) 
			{	$APIurl = 'https://' + $ip + ':443/api/v1'
			}
	else {	return "Invoke-A9API: Array type is Null."	}
	$url = $APIurl + $uri
	Write-verbose "Running: Constructing header." 
	$headers = @{}
	$headers["Accept"] = "application/json"
	$headers["Accept-Language"] = "en"
	$headers["Content-Type"] = "application/json"
	$headers["X-HP3PAR-WSAPI-SessionKey"] = $key
	$data = $null
	If ($type -eq 'GET') 
		{	Try 	{	Write-verbose "Invoke-A9API: Request: Invoke-WebRequest for Data, Request Type : $type" 
						if ($PSEdition -eq 'Core') 	{	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck } 
						else 						{  	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 	}
						return $data
					}
			Catch 	{	Write-verbose "Invoke-A9API: Stop: Exception Occurs" 
						return
					}
		}
	If (($type -eq 'POST') -or ($type -eq 'PUT')) 
		{	Try		{	Write-verbose "Invoke-A9API: Request: Invoke-WebRequest for Data, Request Type : $type" 
						$json = $body | ConvertTo-Json  -Compress -Depth 10	
						if ($PSEdition -eq 'Core') 	{	$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck } 
						else 						{	$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing }
						return $data
					}
			Catch 	{	Write-error "Invoke-A9API: Stop: Exception Occurs" 
						return $_
					}
		}
	If ($type -eq 'DELETE') 
		{	Try {	Write-verbose "Invoke-A9API: Request: Invoke-WebRequest for Data, Request Type : $type" 
					if 	($PSEdition -eq 'Core') {	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck } 
					else 						{  	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 	}
					return $data
				}
			Catch 
				{	Write-error "Invoke-A9API: Stop: Exception Occurs" 
					return $_
				}
		}
	Write-verbose "End: Invoke-A9API" 
}
}
