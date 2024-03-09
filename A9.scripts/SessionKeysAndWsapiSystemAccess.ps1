####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
## 
Function New-A9WSAPIConnection 
{	
<#	
.SYNOPSIS
	Create a WSAPI session key
.DESCRIPTION
	To use Web Services, you must create a session key. Use the same username and password that you use to
	access the storage system through the 3PAR CLI or the 3PAR MC. Creating this authorization allows
	you to complete the same operations using WSAPI as you would the CLI or MC.
.EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType 3par
	create a session key with array.
.EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType primera
	create a session key with Primera array.
.EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType alletra9000
	create a session key with Alletra 9000 array.
.PARAMETER ArrayFQDNorIPAddress 
    Specify the Array FQDN or Array IP address.
.PARAMETER UserName 
    Specify the user name
.PARAMETER Password 
    Specify the password 
.PARAMETER ArrayType
	Specify the array type ie. 3Par, Primera or Alletra9000
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$ArrayFQDNorIPAddress,

		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$SANUserName,

		[Parameter(ValueFromPipeline=$true)]
		[String]	$SANPassword=$null ,

		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateSet("3par", "Primera", "Alletra9000")]
		[String]	$ArrayType
)
if ($PSEdition -eq 'Core')	{} 
else 
{
add-type @" 
using System.Net; 
using System.Security.Cryptography.X509Certificates; 
public class TrustAllCertsPolicy : ICertificatePolicy { 
	public bool CheckValidationResult( 
		ServicePoint srvPoint, X509Certificate certificate, 
		WebRequest request, int certificateProblem) { 
		return true; 
	} 
} 
"@  
	[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}
#END of (self-signed) certificate,
	if(!($SANPassword))
		{	$SANPassword1 = Read-host "SANPassword" -assecurestring
			#$globalpwd = $SANPassword1
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SANPassword1)
			$SANPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		}
		$APIurl = $null
		if($ArrayType.ToLower() -eq "3par")
			{	$global:ArrayType = "3par" 
				$APIurl = "https://$($ArrayFQDNorIPAddress):8080/api/v1" 	
			}
		elseif($ArrayType.ToLower() -eq "primera")
			{	$global:ArrayType = "Primera" 
				$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	
			}	
		elseif($ArrayType.ToLower() -eq "alletra9000")
			{	$global:ArrayType = "Alletra9000" 
				$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	
			}
		#connect to WSAPI
		$postParams = @{user=$SANUserName;password=$SANPassword} | ConvertTo-Json 
		$headers = @{}  
		$headers["Accept"] = "application/json" 		
		Try
			{	Write-verbose "Running: Invoke-WebRequest for credential data." 
				if ($PSEdition -eq 'Core')
				{	$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing -SkipCertificateCheck
				} 
				else 
				{	$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing 
				}
			}
		catch
			{	Show-RequestException -Exception $_
				Write-Error "Failure:  While establishing the connection " 
				throw
			}
		$key = ($credentialdata.Content | ConvertFrom-Json).key
		if(!$key)
			{	Write-Error "Stop: No key Generated"
				return 
			}
		$SANC1 = New-Object "WSAPIconObject"		
		$SANC1.IPAddress = $ArrayFQDNorIPAddress					
		$SANC1.Key = $key
		$Result = Get-System_WSAPI -WsapiConnection $SANC1
		$SANC = New-Object "WSAPIconObject"		
		$SANC.Id = $Result.id
		$SANC.Name = $Result.name
		$SANC.SystemVersion = $Result.systemVersion
		$SANC.Patches = $Result.patches
		$SANC.IPAddress = $ArrayFQDNorIPAddress
		$SANC.Model = $Result.model
		$SANC.SerialNumber = $Result.serialNumber
		$SANC.TotalCapacityMiB = $Result.totalCapacityMiB
		$SANC.AllocatedCapacityMiB = $Result.allocatedCapacityMiB
		$SANC.FreeCapacityMiB = $Result.freeCapacityMiB					
		$SANC.Key = $key		
		$global:WsapiConnection = $SANC
		$global:ArrayName = $Result.name
		Write-verbose "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used" 		
		Write-Verbose -Message 'You are now connected to the HPE Storage system'
		Write-Verbose -Message 'Show array informations:'	
		
		return $SANC
}

Function Close-A9Connection
{
<#
.SYNOPSIS
	Delete a WSAPI session key.
.DESCRIPTION
	When finishes making requests to the server it should delete the session keys it created .
	Unused session keys expire automatically after the configured session times out.
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
.EXAMPLE
    PS:> Close-A9Connection

	Delete a WSAPI session key.
#>
[CmdletBinding()]
Param()
Begin 
{	Test-WSAPIConnection
}
Process 
{	$key = $WsapiConnection.Key
	$uri = '/credentials/'+$key
	$data = $null
	Write-Verbose "Request: Request to close wsapi connection (Invoke-WSAPI)." 
	$data = Invoke-WSAPI -uri $uri -type 'DELETE' 
	$global:WsapiConnection = $null
	return $data
	If ($global:3parkey) 			
		{	Write-Verbose -Message "Delete key session: $global:3parkey"
			Remove-Variable -name 3parKey -scope global
		}
	If ($global:3parArray) 
		{	Write-Verbose -Message "Delete Array: $global:3parArray"
			Remove-Variable -name 3parArray -scope global
		}
}
}
