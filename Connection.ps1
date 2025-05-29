####################################################################################
## 	© 2024 Hewlett Packard Enterprise Development LP
##	Description: 	Common Module functions.
##		

$global:SANConnection = $null 
$global:WsapiConnection = $null
$global:ArrayType = $null
$global:ArrayName = $null
$global:ConnectionType = $null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Function Test-A9Connection 
{
<#
.SYNOPSIS
    Validate CLI connection object. For Internal Use only.
.DESCRIPTION
	Validates if CLI connection object for VC and OA are null/empty
.EXAMPLE
    Test-Connection -ClientType SshClient -MinimumVersion 3.2.1
.EXAMPLE
    Test-Connection -ClientType SshClient 
.EXAMPLE
    Test-Connection -ClientType API
	
.Notes
#>
[CmdletBinding()]
Param(	[ValidateSet('SshClient','API')]	[String]	$ClientType,
											[Version]	$MinimumVersion,
											[switch]	$ReturnBoolean
	)
Process
{	If ( $ClientType -eq 'SshClient')
		{	if ( $null -eq $SANConnection 		 )			{	if ($ReturnBoolean) { return $false} else { Throw "Connection object is null/empty. Create a valid connection object and retry"				}}
			if ( -not ($SANConnection.UserName)  ) 			{	if ($ReturnBoolean) { return $false} else { Throw "Connection object usernameis null or empty. Create a valid connection object and retry"	}}
			if ( -not ($SANConnection.IPAddress) ) 			{ 	if ($ReturnBoolean) { return $false} else { Throw "Connection IP address is null/empty. Create a valid connection object and retry"			}}
			if ( $SANConnection.CLIType -ne 'SshClient' ) 	{	if ($ReturnBoolean) { return $false} else { Throw "Connection Client Type is wrong. Create a valid SSH connection object and retry"			}}
			If ( $ClientType -eq 'SshClient'	)			
				{ 	if ($MinimumVersion)	
						{	[Version]$DetectedVersion = ( Get-A9Version_CLI -S ) 
							if ( -not ($DetectedVersion -ge $MinimumVersion) )
								{	if ($ReturnBoolean) { return $false} 
									else { Throw "The Detecte Array Version OS is less than the required version need to run this command. `nThe detected version is $DetectedVersion but the required version is $MinimumVersion."}
								}
						}
				}
			if ($ReturnBoolean) { return $true} else { return }
		}
	elseif ($ClientType -eq 'API')
		{	if ( $null -eq $WsapiConnection)				{	if ($ReturnBoolean) { return $false} else { Throw "Connection object is null/empty. Create a valid connection object and retry"				}}
			if (-not ($WsapiConnection.IPAddress) )			{	if ($ReturnBoolean) { return $false} else { Throw "Connection IP address is null/empty. Create a valid connection object and retry"			}}
			if (-not ($WsapiConnection.Key))				{	if ($ReturnBoolean) { return $false} else { Throw "Connection object Key null or empty. Create a valid connection object and retry"			}}	
			if ($ReturnBoolean) { return $true } else { return }
		}
}
}

Function Connect-A9API
{
<#	
.SYNOPSIS
	Create a WSAPI session key to a 3Par, Primera, Alletra9000 or AlletraMP-B10000 type array.
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
.EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType 'alletraMP-B10000'
	create a session key with Alletra 9000 array.
.PARAMETER ArrayFQDNorIPAddress 
    Specify the Array FQDN or Array IP address.
.PARAMETER UserName 
    Specify the user name
.PARAMETER Password 
    Specify the password 
.PARAMETER ArrayType
	Specify the array type ie. 3Par, Primera Alletra9000, or AlletraMP-B10000
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]				[String]	$ArrayFQDNorIPAddress,
		[Parameter(Mandatory)]				[String]	$SANUserName,
		[Parameter()]						[String]	$SANPassword,
		[Parameter(Mandatory)]
		[ValidateSet("3par", "Primera", "Alletra9000", "AlletraMP-B10000", IgnoreCase=$false, ErrorMessage="Value '{0}' is invalid. Try one of: '{1}' and remember it is case sensitive")]
																			[String]	$ArrayType
	)
process
{	# This section if required for Self-Signed Certs
	if ($PSEdition -ne 'Core')
		{	add-type @" 
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
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SANPassword1)
			$SANPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		}
	$APIurl = $null
	$Global:ArrayType = $ArrayType
	if($ArrayType.ToLower() -eq "3par")
		{	$APIurl = "https://$($ArrayFQDNorIPAddress):8080/api/v1" 	
		}
	elseif($ArrayType.ToLower() -eq "primera")
		{	$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	
		}
	elseif($ArrayType.ToLower() -eq "alletra9000")
		{	$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	
		}
	elseif($ArrayType.ToLower() -eq "alletramp-b10000")
		{	$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	
		}
	else
		{	write-error " You have entered an unsupported Array type : $ArrayType. Please enter the array type as 3par, Primera or Alletra 9000." 
			Return
		}
	#connect to WSAPI
	$postParams = @{user=$SANUserName;password=$SANPassword} | ConvertTo-Json 
	$headers = @{}  
	$headers["Accept"] = "application/json" 
	Try
		{	Write-verbose "Running: Invoke-WebRequest for credential data."
			write-verbose "URL = $APIurl/credentials"
			write-verbose "Body = $postParams"
			write-verbose "ContentType = application/json"
			write-verbose "headers = $headers"
			if ($PSEdition -eq 'Core')
				{	write-verbose "Executing invoke-WebRequest for Core"
					$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing -SkipCertificateCheck
				} 
			else 
				{	write-verbose "Executing invoke-WebRequest for non-core"
					$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing 
				}
		}
	catch
		{	Write-error "FAILURE : While establishing the connection "
			throw
		}
	write-verbose "New-Connection: Raw CredentialData Returned"
	Write-Verbose  "$( $Credentialdata | out-string )"
	$key = ($credentialdata.Content | ConvertFrom-Json).key
	write-verbose "The Returned Key = $key"
	if(!$key)
		{	Write-error "Stop: No key Generated"
			return 		
		}
	write-verbose "New-Connection: Initiating Get-System call to test the offered key"	
	if 		($ArrayType -eq "3par") 		
			{	$APIurl = 'https://' + $ArrayFQDNorIPAddress + ':8080/api/v1' 
			}
	Elseif (($ArrayType -eq "Primera") -or ($ArrayType -eq "Alletra9000") ) 
			{	$APIurl = 'https://' + $ArrayFQDNorIPAddress + ':443/api/v1'
			}
	Elseif (($ArrayType -eq "AlletraMP-B10000")) 
			{	$APIurl = 'https://' + $ArrayFQDNorIPAddress + ':443/api/v1'
			}
	$url = $APIurl + '/system'
	Write-verbose "Running: Constructing header." 
	$headers = @{}
	$headers["Accept"] = "application/json"
	$headers["Accept-Language"] = "en"
	$headers["Content-Type"] = "application/json"
	$headers["X-HP3PAR-WSAPI-SessionKey"] = $key
	Try 	{	Write-verbose "Obtaining the Key from the Array: Request Type : Get" 
				if ($PSEdition -eq 'Core') 	{	$Result = Invoke-WebRequest -Uri "$url" -Headers $headers -Method 'GET' -UseBasicParsing -SkipCertificateCheck } 
				else 						{  	$Result = Invoke-WebRequest -Uri "$url" -Headers $headers -Method 'GET' -UseBasicParsing 	}
			}
	Catch 	{	Write-error "Error occured trying to make the API call to retrieve array details witht the new key." 	
			}
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
		}	
	$Result=$dataPS
	write-verbose "New-Connection: The result of the Get-System_WSAPI call is as follows"
	write-verbose "$result"	
	$SANX = @{	Id = $Result.id
				Name = $Result.name
				SystemVersion = $Result.systemVersion
				Patches = $Result.patches
				IPAddress = $ArrayFQDNorIPAddress
				Model = $Result.model
				SerialNumber = $Result.serialNumber
				TotalCapacityMiB = $Result.totalCapacityMiB
				AllocatedCapacityMiB = $Result.allocatedCapacityMiB
				FreeCapacityMiB = $Result.freeCapacityMiB					
				Key = $key		
			}
	$SANZ = $SANX | Convertto-json | ConvertFrom-JSON
    $DataSetType = "WSAPIconObject"
    $SANZ.PSTypeNames.Insert(0,$DataSetType)
    $DataSetType = $DataSetType
    $SANZ.PSObject.TypeNames.Insert(0,$DataSetType)
	$global:WsapiConnection = $SANZ	
	$global:ArrayName = $Result.name
	Write-verbose "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used" 
	Write-Host "You are now connected to the HPE Storage system $ArrayName" -ForegroundColor green
	write-host "Attempting to load the HPE 3Par / Primera / Alletra9000 PowerShell Commands that support the WSAPI. " -ForegroundColor green
	$CurrentModulePath = (Get-Module HPEStorage).path
	[string]$CurrentModulePath = Split-Path $CurrentModulePath -Parent
	$ModPath = $CurrentModulePath + '\HPEAlletra9000andPrimeraand3Par_API.psd1'	
	write-host "The path to the module is $ModPath" -ForegroundColor green
	import-module $ModPath -scope global -force
	if($ArrayType.ToLower() -eq "3par")
		{	$ModPath = $CurrentModulePath + '\HPE3ParFilePersona.psd1'	
			write-host "The path to the module is $ModPath" -ForegroundColor green
			import-module $ModPath -scope global -force
		}
	return $SANZ
}
}

Function Close-A9Connection
{
<#
.SYNOPSIS
	Delete a CLI SSH Connection and WSAPI session key if they exist.
.DESCRIPTION
	When finishes making requests to the server it should delete the session keys it created .
	Unused session keys expire automatically after the configured session times out.
.EXAMPLE
    PS:> Close-A9Connection

	Delete a WSAPI session key and a CLI Connection if one exists.
#>
[CmdletBinding()]
Param()
Begin 
{
}
Process 
{	# Close any CLI Connection 
	if ($SANConnection)	
		{	$global:SANConnection = $null
		}
	# Close any WSAPI connection
	if (($global:WsapiConnection) -or ($global:ConnectionType -eq "WSAPI"))
		{	$key = $WsapiConnection.Key
			$uri = '/credentials/'+$key
			$data = $null
			Write-Verbose "Request: Request to close wsapi connection (Invoke-A9API)." 
			$data = Invoke-A9API -uri $uri -type 'DELETE' 
			$global:WsapiConnection = $null
			If ($3parkey) 	{	Remove-Variable -name 3parKey -scope global	}
			If ($3parArray)	{	Remove-Variable -name 3parArray -scope global }
			return $data
		}
}
}

Function Connect-A9SSH
{
<#
.SYNOPSIS
    Builds a SAN Connection object using Posh SSH connection
.DESCRIPTION
	Creates a SAN Connection object with the specified parameters.  No connection is made by this cmdlet call, it merely builds the connection object. 
.EXAMPLE
    PS:> Connect-A9SSH -SANUserName Administrator -SANPassword mypassword -ArrayNameOrIPAddress 10.1.1.1 

	Creates a SAN Connection object with the specified Array Name or Array IP Address
.EXAMPLE
    PS:> Connect-A9SSH -SANUserName Administrator -SANPassword mypassword -ArrayNameOrIPAddress 10.1.1.1 -AcceptKey

	Creates a SAN Connection object with the specified Array Name or Array IP Address
.PARAMETER UserName 
    Specify the SAN Administrator user name.
.PARAMETER Password 
    Specify the SAN Administrator password 
.PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]    $ArrayNameOrIPAddress,
		[Parameter(Mandatory)]	[String]	$SANUserName,	
		[Parameter(Mandatory)]	[String]	$SANPassword,
		[Parameter()]			[switch]	$AcceptKey
		)
Process
{	$CurrentModulePath = (Get-Module HPEStorage).path
	$Global:CurrentModulePath = Split-Path $CurrentModulePath -Parent	
	if ( -not (Get-Module -ListAvailable -Name Posh-SSH) -and -not(Get-Module -Name Posh-SSH) ) 
		{	Write-Warning "The Neccessary PowerShell SSH Module was not found, To use this command you must install this module"
			Write-Warning "This SSH Module can be found at the following location"
			write-warning "https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev"
			return
		}
	try		{	$tempstring  = convertto-securestring $SANPassword -asplaintext -force				
				$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $tempstring)									
				try		{	if($AcceptKey) 	{	$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds -AcceptKey	}
							else 			{	$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds }
						}
				catch 	{	$msg = "In function New-PoshSshConnection. "
							$msg+= $_.Exception.ToString()	
							Write-warning $msg	
							return 
						}
				Write-Verbose "Running: Executed . Check on PS console if there are any errors reported" 
				if (!$Session)	{	return "New-PoshSshConnection command failed to connect the array."	}
			}
	catch 	{	$msg = "In function New-PoshSshConnection. "
				$msg+= $_.Exception.ToString()	
				Write-warning $msg 	
				return 
			}					
	$global:SANObjArr += @()
	$global:SANObjArr1 += @()
	$SANC = @{ 	SessionId 	= $Session.SessionId		
				IPAddress 	= $ArrayNameOrIPAddress			
				UserName 	= $SANUserName
				epwdFile 	= "Secure String"			
				CLIType 	= "SshClient"
				CLIDir 		= "Null"	
				SessionObj  = $Session		
			}
	$global:SANConnection = $SANC
	#-- Obtain more Details by retrieving System Details via a CLI call --
	write-verbose 'Invoke-A9CLICommand -Connection $SANC -cmds "showsys "'	

	$R1 = Invoke-SSHCommand -Command "showsys " -SessionId $SANC.SessionId
	if ($R1.ExitStatus -eq 0) 	{	$Result3 = $R1.Output	}
	$FirstCnt = 1
	$rCount = $Result3.Count
	$noOfColumns = 0        
	$tempFile = [IO.Path]::GetTempFileName()
	if ($Result3.Count -gt 1) 
		{	foreach ($s in  $Result3[$FirstCnt..$rCount] ) 
				{	$s = [regex]::Replace($s, "^ +", "")
					$s = [regex]::Replace($s, "-", "")				
					$s = [regex]::Replace($s, " +", ",")
					if ($noOfColumns -eq 0) {	$noOfColumns = $s.Split(",").Count;	}
					else{	$noOfValues = $s.Split(",").Count;
							if ($noOfValues -ge $noOfColumns) 
								{	[System.Collections.ArrayList]$CharArray1 = $s.Split(",");								
									if ($noOfValues -eq 12) 
										{	$CharArray1[2] = $CharArray1[2] + " " + $CharArray1[3];
											$CharArray1.RemoveAt(3);
											$s = $CharArray1 -join ',';
										}
											elseif ($noOfValues -eq 13) 
												{	$CharArray1[2] = $CharArray1[2] + " " + $CharArray1[3] + " " + $CharArray1[4];
													$CharArray1.RemoveAt(4);
													$CharArray1.RemoveAt(3);
													$s = $CharArray1 -join ',';
												}
								}
						}				
					Add-Content -Path $tempFile -Value $s				
				}
			$SystemDetails = Import-Csv $tempFile
		}	
	$SANC.Name = $SystemDetails.Name
	# $SANC.SystemVersion = Get-Version -S -B
	$SANC.Model = $SystemDetails.Model
	$SANC.Serial = $SystemDetails.Serial
	$SANC.TotalCapacityMiB = $SystemDetails.TotalCap
	$SANC.AllocatedCapacityMiB = $SystemDetails.AllocCap
	$SANC.FreeCapacityMiB = $SystemDetails.FreeCap
	$global:ArrayName = $SANC.Name
	$global:ConnectionType = "CLI"
	Write-verbose "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used. $ArrayName and $Connectiontype"		
	$global:SANConnection = $SANC
	write-host "Attempting to load the HPE 3Par / Primera / Alletra9000 / AlletraMP-B10000 PowerShell Commands that support SSH connectivity. " -ForegroundColor green
	$CurrentModulePath = (Get-Module HPEStorage).path
	[string]$CurrentModulePath = Split-Path $CurrentModulePath -Parent
	$ModPath = $CurrentModulePath + '\HPEAlletra9000andPrimeraand3Par_CLI.psd1'	
	write-host "The path to the module is $ModPath" -ForegroundColor green
	import-module $ModPath -scope global -force
	return $SANConnection
}
}

Function Connect-HPESAN
{	
<#
.SYNOPSIS
	Connect to a HPE SAN Device
.DESCRIPTION
	Connect to a HPE SAN Device. Once you connect to the appropriate array type, the correct comamnds will be loaded to manage that specific array type. In the case
	of a AlletraMP-B10000/Alletra9000/Primera/3Par style array the connection command will attempt both an API and a SSH type connection if available. Note that if the command is 
	sucessful for both connection types all commands will be available, however if the array device only supports SSH connections, then on the SSH based commands will be 
	loaded and visiable, and if the array only supports the WSAPI type commands, the API based commnads will be available.
	In the case of the Alletra5000/6000/NimbleStorage type devices, the connection will always be API based.
	In the case of the MSA type devices, the connection will alwasy be API based as well.
.PARAMETER ArrayNameOrIPAddress
	The IP Address or Array name that will resolve via name service to the IP Address of the target device to connect to.
.PARAMETER ArrayType
	This will define which type of array the connection command will attept to connect to. The valid options are 3PAR, Primera, Alletra9K, AlletraMP-B10K, Alletra6K, Nimble, and MSA.
.PARAMETER Credential
	This is a standard PowerShell Credential type, you can use the value (Get-Credential) as a value here if you want a popup to appear that lets you insert you username
	and passsowrd. If you do not fill in this value, the command will ask you for your credentials.
.EXAMPLE
	PS:> Connect-HPESAN -ArrayNameOrIPAddress 192.168.1.50 -ArrayType Nimble

	cmdlet Connect-HPESAN at command pipeline position 1
	Supply values for the following parameters:
	Credential
	User: admin
	Password for user admin: *****

	Successfully connected to array 192.168.1.50
	To View the list of commands available to you please use 'Get-Command -module HPEAlletra6000AndNimbleStorage'.
.EXAMPLE
	PS:> Connect-HPESAN -ArrayNameOrIPAddress 192.168.100.98 -ArrayType MSA

	cmdlet Connect-HPESAN at command pipeline position 1
	Supply values for the following parameters:
	Credential
	User: chris
	Password for user chris: *********

		object-name           : status
		meta                  : https://192.168.100.98/rest/v1/meta/status
		response-type         : Success
		response-type-numeric : 0
		response              : 9f8b16cbceb5c90927dbc8da465cb9ed
		return-code           : 1
		component-id          :
		time-stamp            : 2022-11-14 23:50:58
		time-stamp-numeric    : 1668469858

		To View the list of commands available to you please use 'Get-Command -module HPEMSA'.
.EXAMPLE
	PS:> connect-hpesan -ArrayNameOrIPAddress 192.168.20.19 -ArrayType Primera

	cmdlet Connect-HPESAN at command pipeline position 1
	Supply values for the following parameters:
	Credential
	User: dev-team
	Password for user dev-team: ************

		Attempting to load the HPE 3Par / Primera / Alletra9000 PowerShell Commands that support SSH connectivity.
		The path to the module is C:\Users\clionetti\Desktop\Powershell\HPEStoragePowerShellToolkit\HPEAlletra9000andPrimeraand3Par_CLI.psd1

		Name                           Value
		----                           -----
		Model                          HPE Alletra 9060
		TotalCapacityMiB               36608000
		UserName                       dev-team
		Serial                         4UW0003299
		SessionId                      0
		epwdFile                       Secure String
		Name                           4UW0003299_Alletra660
		AllocatedCapacityMiB           22524928
		IPAddress                      192.168.20.19
		CLIType                        SshClient
		CLIDir                         Null
		FreeCapacityMiB                14083072
		You are now connected to the HPE Storage system 4UW0003299_Alletra660

		Attempting to load the HPE 3Par / Primera / Alletra9000 PowerShell Commands that support the WSAPI.

		IPAddress            : 192.168.20.19
		SerialNumber         : 4UW0003299
		FreeCapacityMiB      : 14083072
		Model                : HPE Alletra 9060
		Patches              :
		Id                   : 518958
		Name                 : 4UW0003299_Alletra660
		Key                  : 0-3dcd5a5cedf5bcf79b2953f60bd3ed0b-5faa5866
		AllocatedCapacityMiB : 22524928
		TotalCapacityMiB     : 36608000
		SystemVersion        : 9.5.4.2

		To View the list of commands available to you that utilize the API please use 'Get-Command -module HPEAlletra9000AndPrimeraAnd3Par_API'.
		To View the list of commands available to you that utilize the CLI please use 'Get-Command -module HPEAlletra9000AndPrimeraAnd3Par_CLI'.

#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]												[String]    $ArrayNameOrIPAddress,
		[Parameter(Mandatory=$true)]
		[ValidateSet('AlletraMP-B10000', 'Alletra9000','Primera','3PAR','Nimble','Alletra6000','MSA')]	[String]    $ArrayType,
		[Parameter(Mandatory=$true)]												[System.Management.Automation.PSCredential] $Credential
		)
Process
{	$CurrentModulePath = (Get-Module HPEStorage).path
	[string]$CurrentModulePath = Split-Path $CurrentModulePath -Parent
	$ModPath = $CurrentModulePath	
	if ($ArrayType -eq 'Alletra9000' -or $ArrayType -eq 'Primera' -or $ArrayType -eq '3Par' -or $ArrayType -eq 'AlletraMP-B10000')
			{	write-Verbose "You will be connected to a $ArrayType at the location $ArrayNameOrIPAddress"
				$pass = $Credential.GetNetworkCredential().password 
				$user = $Credential.GetNetworkCredential().username
				write-Verbose "You will be using Username $user and Password $pass"
				connect-A9SSH -ArrayNameOrIPAddress $ArrayNameOrIPAddress -SANUserName $user -SANPassword $pass -AcceptKey
				connect-A9API -ArrayFQDNorIPAddress $ArrayNameOrIPAddress -SANUserName $user -SANPassword $pass -ArrayType $ArrayType
				Write-host "To View the list of commands available to you that utilize the API please use 'Get-Command -module HPEAlletra9000AndPrimeraAnd3Par_API'." -ForegroundColor Green
				Write-host "To View the list of commands available to you that utilize the CLI please use 'Get-Command -module HPEAlletra9000AndPrimeraAnd3Par_CLI'." -ForegroundColor Green
				if ( $ArrayType -eq '3Par')
				{	Write-host "Since the array is of type 3Par, the optional File Persona Commands will be loaded. To view a list of these commands use 'Get-Command -module HPE3ParFilePersona " -ForegroundColor Green
				}
				write-verbose 'Removing non-used modules'
				if ( [boolean](get-module -name HPEAlletra6000andNimbleStorage) )	{ remove-module -name HPEAlletra6000andNimbleStorage }
				if ( [boolean](get-module -name HPEMSA ) 						)	{ remove-module -name HPEMSA }
			}	
	elseif ( $ArrayType -eq 'Nimble' -or $ArrayType -eq'Alletra6000')	
			{	$ModPath = $ModPath + '\HPEAlletra6000andNimbleStorage.psd1'
				Import-Module $ModPath -force -scope Global
				Connect-NSGroup -group $ArrayNameOrIPAddress -credential $Credential 
				Write-host "To View the list of commands available to you please use 'Get-Command -module HPEAlletra6000AndNimbleStorage'." -ForegroundColor Green
				write-verbose 'Removing non-used modules'
				if ( [boolean](get-module -name HPEAlletra9000andPrimeraand3Par_API ) )	{ remove-module -name HPEAlletra9000andPrimeraand3Par_API }
				if ( [boolean](get-module -name HPEAlletra9000andPrimeraand3Par_CLI ) )	{ remove-module -name HPEAlletra9000andPrimeraand3Par_API }
				if ( [boolean](get-module -name HPEMSA )  							)	{ remove-module -name HPEMSA }				
			}
	elseif	($ArrayType -eq 'MSA')	
			{	$ModPath = $ModPath + '\HPEMSA.psd1'
				Import-Module $ModPath -force -scope Global
				$pass = $Credential.GetNetworkCredential().password 
				$user = $Credential.GetNetworkCredential().username
				write-Verbose "You will be using Username $user and Password $pass"
				Connect-MSAGroup -FQDNorIP $ArrayNameOrIPAddress -Username $user -Password $pass
				Write-host "To View the list of commands available to you please use 'Get-Command -module HPEMSA'." -ForegroundColor Green
				write-verbose 'Removing non-used modules'
				if ( [boolean](get-module -name HPEAlletra9000andPrimeraand3Par_API ) )	{ remove-module -name HPEAlletra9000andPrimeraand3Par_API }
				if ( [boolean](get-module -name HPEAlletra9000andPrimeraand3Par_CLI ) )	{ remove-module -name HPEAlletra9000andPrimeraand3Par_API }
				if ( [boolean](get-module -name HPEAlletra6000andNimbleStorage ) 	  )	{ remove-module -name HPEAlletra6000andNimbleStorage }				
	}
}
}

function Import-HPESANCertificate 
{
	<#
.SYNOPSIS
	Connect to a HPE SAN Device
.DESCRIPTION
	Connect to a HPE SAN Device for the purpose of retrieving the Array Certificate. If the Certificate does not exist on the Cert:\LocalMachine\Root store, it will add it.
	If the Certificate already exists, it will warn you of this. To run this command you must execute this command with and Administrative PowerShell prompt. 
.PARAMETER ArrayNameOrIPAddress
	The IP Address or Array name that will resolve via name service to the IP Address of the target device to connect to.
.EXAMPLE
	PS C:\Users\chris\Desktop\PowerShell\HPEStoragePowerShellToolkit> Import-HPESANCertificate -ArrayNameOrIPAddress 192.168.1.50
	Successfully imported the server certificate


	Thumbprint                               Subject
	----------                               -------
	069A1B7D854C84718FDE234F894B277C29661FB8 CN=pegasus.lionetti.lab, O=Nimble Storage, OU=Lab, L=San Jose, S=CA, C=US
.EXAMPLE
	PS C:\Users\chris\Desktop\PowerShell\HPEStoragePowerShellToolkit> Import-HPESANCertificate -ArrayNameOrIPAddress 192.168.1.50

	WARNING: The Certificate Already exists, no need to re-import it.
#>
param(  [Parameter(Mandatory,Position=0)]   [string]$ArrayNameOrIPAddress
)

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ( -not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) )
	{ 	write-warning "This command can ONLY be run in Administrator Mode, Please run an Administrator PowerShell Prompt and try this command againt."
		return
	}
$Code = @'
			using System;
			using System.Collections.Generic;
			using System.Net.Http;
			using System.Net.Security;
			using System.Security.Cryptography.X509Certificates;
	
			namespace CertificateCapture
			{	public class Utility
					{	public static Func<HttpRequestMessage,X509Certificate2,X509Chain,SslPolicyErrors,Boolean> ValidationCallback = 
							(message, cert, chain, errors) => {	var newCert = new X509Certificate2(cert);
																var newChain = new X509Chain();
																newChain.Build(newCert);
																CapturedCertificates.Add(new CapturedCertificate(){
																		Certificate =  newCert,
																		CertificateChain = newChain,
																		PolicyErrors = errors,
																		URI = message.RequestUri
																	});
																return true; 
															};
						public static List<CapturedCertificate> CapturedCertificates = new List<CapturedCertificate>();
					}
				public class CapturedCertificate 
					{	public X509Certificate2 Certificate { get; set; }
						public X509Chain CertificateChain { get; set; }
						public SslPolicyErrors PolicyErrors { get; set; }
						public Uri URI { get; set; }
					}
			}
'@

if ($PSEdition -ne 'Core')
	{   write-verbose "Running Codebase for Not Core PowerShell."
		$webrequest=[net.webrequest]::Create("https://$ArrayNameOrIPAddress")
		try 	{ $response = $webrequest.getresponse() } 
		catch 	{}
		$cert=$webrequest.servicepoint.certificate
		if($cert -ne $null)
			{   $Thumbprint = $webrequest.ServicePoint.Certificate.GetCertHashString()
				$bytes=$cert.export([security.cryptography.x509certificates.x509contenttype]::cert)
				$tfile=[system.io.path]::getTempFileName()
				set-content -value $bytes -encoding byte -path $tfile
				$certdetails = $cert | select-object * | format-table -AutoSize | Out-String
				$AlreadyExists = [boolean](get-childitem -path cert:\localmachine\root | select-object Thumbprint | where-object { $_.Thumbprint -eq $Certthumb } ) 
				if (-not $AlreadyExists)  
					{   try	{   $output =import-certificate -filepath $tfile -certStoreLocation 'Cert:\localmachine\Root'
								$certdetails = $output | select-object -Property Thumbprint,subject | format-table -AutoSize | Out-String
							}
						catch{  Write-Error "Failed to import the server certificate `n`n $_.Exception.Message"  -ErrorAction Stop
							}
						Write-Host "Successfully imported the server certificate `n $certdetails"
					}
				else{   write-warning "The Certificate Already exists, no need to re-import it."
					}
			}
		else{   Write-Error "Failed to import the server certificate `n"
			}  
	}
else{   write-verbose "Running Codebase for PowerShell Core."
		try 	{ 	Add-Type $Code -IgnoreWarnings
					Write-verbose "The Add-Type command ran without error."
				}
		catch 	{	write-warning $_.Exception
					Write-Verbose "The Add-Type command failed, likely already loaded."
				}
		$Certs = [CertificateCapture.Utility]::CapturedCertificates
		$Handler = [System.Net.Http.HttpClientHandler]::new()
		$Handler.ServerCertificateCustomValidationCallback = [CertificateCapture.Utility]::ValidationCallback
		$Client = [System.Net.Http.HttpClient]::new($Handler)
		$Url = "https://$ArrayNameOrIPAddress"
		$Result = $Client.GetAsync($Url).Result
		$cert= $Certs[-1].Certificate
		$certthumb = $cert.Thumbprint
		write-verbose "The Thumbprint = $Certthumb "
		write-verbose "The Certs will be tested against Null"
		if($null -ne $certs)
			{   write-verbose "The Certs were not NULL"
				$certdetails = $cert | select-object -Property Thumbprint,subject | format-table -AutoSize | Out-String
				$AlreadyExists = [boolean](get-childitem -path cert:\localmachine\root | select-object Thumbprint | where-object { $_.Thumbprint -eq $Certthumb } ) 
				if (-not $AlreadyExists)  
					{   write-verbose "The Certificate Does not already exist."
						$bytes=$cert.export([security.cryptography.x509certificates.x509contenttype]::cert)
						$OpenFlags = [System.Security.Cryptography.X509Certificates.OpenFlags]
						$store = new-object system.security.cryptography.X509Certificates.X509Store -argumentlist "Root","LocalMachine"
						try	{   $Store.Open($OpenFlags::ReadWrite)
								$Store.Add($Cert)
								$Store.Close()
								Write-Host "Successfully imported the server certificate `n" 
								return $CertDetails
							}
						catch{  write-error $_
								Write-Error "Failed to import the server certificate `n`n $_.Exception.Message"  -ErrorAction Stop
							}
					}
				else{   write-warning "The Certificate Already exists, no need to re-import it."
					}
			}
		else{   Write-Error "Failed to import the server certificate `n`n"  -ErrorAction Stop
			}
}
}
	

# SIG # Begin signature block
# MIIsVAYJKoZIhvcNAQcCoIIsRTCCLEECAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDoCn5gX+wJ
# H5owRkczyNexhPLlrD67LQgJVXQPawR/GPHB8JSfY4Qu0X5n9WuNqX+k6UHf4Rr3
# yeGQxok4GbqCoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
# KoZIhvcNAQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExp
# bWl0ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0yMTA1
# MjUwMDAwMDBaFw0yODEyMzEyMzU5NTlaMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AI3nlBIiBCR0Lv8WIwKSirauNoWsR9QjkSs+3H3iMaBRb6yEkeNSirXilt7Qh2Mk
# iYr/7xKTO327toq9vQV/J5trZdOlDGmxvEk5mvFtbqrkoIMn2poNK1DpS1uzuGQ2
# pH5KPalxq2Gzc7M8Cwzv2zNX5b40N+OXG139HxI9ggN25vs/ZtKUMWn6bbM0rMF6
# eNySUPJkx6otBKvDaurgL6en3G7X6P/aIatAv7nuDZ7G2Z6Z78beH6kMdrMnIKHW
# uv2A5wHS7+uCKZVwjf+7Fc/+0Q82oi5PMpB0RmtHNRN3BTNPYy64LeG/ZacEaxjY
# cfrMCPJtiZkQsa3bPizkqhiwxgcBdWfebeljYx42f2mJvqpFPm5aX4+hW8udMIYw
# 6AOzQMYNDzjNZ6hTiPq4MGX6b8fnHbGDdGk+rMRoO7HmZzOatgjggAVIQO72gmRG
# qPVzsAaV8mxln79VWxycVxrHeEZ8cKqUG4IXrIfptskOgRxA1hYXKfxcnBgr6kX1
# 773VZ08oXgXukEx658b00Pz6zT4yRhMgNooE6reqB0acDZM6CWaZWFwpo7kMpjA4
# PNBGNjV8nLruw9X5Cnb6fgUbQMqSNenVetG1fwCuqZCqxX8BnBCxFvzMbhjcb2L+
# plCnuHu4nRU//iAMdcgiWhOVGZAA6RrVwobx447sX/TlAgMBAAGjggESMIIBDjAf
# BgNVHSMEGDAWgBSgEQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUMuuSmv81
# lkgvKEBCcCA2kVwXheYwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEE
# ATBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFD
# ZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAQEA
# Er+h74t0mphEuGlGtaskCgykime4OoG/RYp9UgeojR9OIYU5o2teLSCGvxC4rnk7
# U820+9hEvgbZXGNn1EAWh0SGcirWMhX1EoPC+eFdEUBn9kIncsUj4gI4Gkwg4tsB
# 981GTyaifGbAUTa2iQJUx/xY+2wA7v6Ypi6VoQxTKR9v2BmmT573rAnqXYLGi6+A
# p72BSFKEMdoy7BXkpkw9bDlz1AuFOSDghRpo4adIOKnRNiV3wY0ZFsWITGZ9L2PO
# mOhp36w8qF2dyRxbrtjzL3TPuH7214OdEZZimq5FE9p/3Ef738NSn+YGVemdjPI6
# YlG87CQPKdRYgITkRXta2DCCBeEwggRJoAMCAQICEQCZcNC3tMFYljiPBfASsES3
# MA0GCSqGSIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBD
# QSBSMzYwHhcNMjIwNjA3MDAwMDAwWhcNMjUwNjA2MjM1OTU5WjB3MQswCQYDVQQG
# EwJVUzEOMAwGA1UECAwFVGV4YXMxKzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBF
# bnRlcnByaXNlIENvbXBhbnkxKzApBgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRl
# cnByaXNlIENvbXBhbnkwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCi
# DYlhh47xvo+K16MkvHuwo3XZEL+eEWw4MQEoV7qsa3zqMx1kHryPNwVuZ6bAJ5OY
# oNch6usNWr9MZlcgck0OXnRGrxl2FNNKOqb8TAaoxfrhBSG7eZ1FWNqxJAOlzXjg
# 6KEPNdlhmfVvsSDolVDGr6yEXYK9WVhVtEApyLbSZKLED/0OtRp4CtjacOCF/unb
# vfPZ9KyMVKrCN684Q6BpknKH3ooTZHelvfAzUGbHxfKvq5HnIpONKgFhbpdZXKN7
# kynNjRm/wrzfFlp+m9XANlmDnXieTeKEeI3y3cVxvw9HTGm4yIFt8IS/iiZwsKX6
# Y94RkaDzaGB1fZI19FnRo2Fx9ovz187imiMrpDTsj8Kryl4DMtX7a44c8vORYAWO
# B17CKHt52W+ngHBqEGFtce3KbcmIqAH3cJjZUNWrji8nCuqu2iL2Lq4bjcLMdjqU
# +2Uc00ncGfvP2VG2fY+bx78e47m8IQ2xfzPCEBd8iaVKaOS49ZE47/D9Z8sAVjcC
# AwEAAaOCAYkwggGFMB8GA1UdIwQYMBaAFA8qyyCHKLjsb0iuK1SmKaoXpM0MMB0G
# A1UdDgQWBBRtaOAY0ICfJkfK+mJD1LyzN0wLzjAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBKBgNVHSAEQzBBMDUGDCsG
# AQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQ
# UzAIBgZngQwBBAEwSQYDVR0fBEIwQDA+oDygOoY4aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQVIzNi5jcmwweQYIKwYBBQUH
# AQEEbTBrMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNydDAjBggrBgEFBQcwAYYXaHR0cDov
# L29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggGBACPwE9q/9ANM+zGO
# lq4SZg7qDpsDW09bDbdjyzAmxxJk2GhD35Md0IluPppla98zFjnuXWpVqakGk9vM
# KxiooQ9QVDrKYtx9+S8Qui21kT8Ekhrm+GYecVfkgi4ryyDGY/bWTGtX5Nb5G5Gp
# DZbv6wEuu3TXs6o531lN0xJSWpJmMQ/5Vx8C5ZwRgpELpK8kzeV4/RU5H9P07m8s
# W+cmLx085ndID/FN84WmBWYFUvueR5juEfibuX22EqEuuPBORtQsAERoz9jStyza
# gj6QxPG9C4ItZO5LT+EDcHH9ti6CzxexePIMtzkkVV9HXB6OUjgeu6MbNClduKY4
# qFiutdbVC8VPGncuH2xMxDtZ0+ip5swHvPt/cnrGPMcVSEr68cSlUU26Ln2u/03D
# eZ6b0R3IUdwWf4K/1X6NwOuifwL9gnTM0yKuN8cOwS5SliK9M1SWnF2Xf0/lhEfi
# VVeFlH3kZjp9SP7v2I6MPdI7xtep9THwDnNLptqeF79IYoqT3TCCBhowggQCoAMC
# AQICEGIdbQxSAZ47kHkVIIkhHAowDQYJKoZIhvcNAQEMBQAwVjELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAwMFoXDTM2
# MDMyMTIzNTk1OVowVDELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIENBIFIz
# NjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJsrnVP6NT+OYAZDasDP
# 9X/2yFNTGMjO02x+/FgHlRd5ZTMLER4ARkZsQ3hAyAKwktlQqFZOGP/I+rLSJJmF
# eRno+DYDY1UOAWKA4xjMHY4qF2p9YZWhhbeFpPb09JNqFiTCYy/Rv/zedt4QJuIx
# eFI61tqb7/foXT1/LW2wHyN79FXSYiTxcv+18Irpw+5gcTbXnDOsrSHVJYdPE9s+
# 5iRF2Q/TlnCZGZOcA7n9qudjzeN43OE/TpKF2dGq1mVXn37zK/4oiETkgsyqA5lg
# AQ0c1f1IkOb6rGnhWqkHcxX+HnfKXjVodTmmV52L2UIFsf0l4iQ0UgKJUc2RGarh
# OnG3B++OxR53LPys3J9AnL9o6zlviz5pzsgfrQH4lrtNUz4Qq/Va5MbBwuahTcWk
# 4UxuY+PynPjgw9nV/35gRAhC3L81B3/bIaBb659+Vxn9kT2jUztrkmep/aLb+4xJ
# bKZHyvahAEx2XKHafkeKtjiMqcUf/2BG935A591GsllvWwIDAQABo4IBZDCCAWAw
# HwYDVR0jBBgwFoAUMuuSmv81lkgvKEBCcCA2kVwXheYwHQYDVR0OBBYEFA8qyyCH
# KLjsb0iuK1SmKaoXpM0MMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYEVR0gADAIBgZn
# gQwBBAEwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRv
# MG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAG/4Lhd2M2bnuhFSCb
# E/8E/ph1RGHDVpVx0ZE/haHrQECxyNbgcv2FymQ5PPmNS6Dah66dtgCjBsULYAor
# 5wxxcgEPRl05pZOzI3IEGwwsepp+8iGsLKaVpL3z5CmgELIqmk/Q5zFgR1TSGmxq
# oEEhk60FqONzDn7D8p4W89h8sX+V1imaUb693TGqWp3T32IKGfIgy9jkd7GM7YCa
# 2xulWfQ6E1xZtYNEX/ewGnp9ZeHPsNwwviJMBZL4xVd40uPWUnOJUoSiugaz0yWL
# ODRtQxs5qU6E58KKmfHwJotl5WZ7nIQuDT0mWjwEx7zSM7fs9Tx6N+Q/3+49qTtU
# vAQsrEAxwmzOTJ6Jp6uWmHCgrHW4dHM3ITpvG5Ipy62KyqYovk5O6cC+040Si15K
# JpuQ9VJnbPvqYqfMB9nEKX/d2rd1Q3DiuDexMKCCQdJGpOqUsxLuCOuFOoGbO7Uv
# 3RjUpY39jkkp0a+yls6tN85fJe+Y8voTnbPU1knpy24wUFBkfenBa+pRFHwCBB1Q
# tS+vGNRhsceP3kSPNrrfN2sRzFYsNfrFaWz8YOdU254qNZQfd9O/VjxZ2Gjr3xgA
# NHtM3HxfzPYF6/pKK8EE4dj66qKKtm2DTL1KFCg/OYJyfrdLJq1q2/HXntgr2GVw
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhEwghoNAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQNpwOU0kvEwqbIBr0M/Hch+v4QQTuCT1FG+7jDCI7xE5L0aN3a8XSVRC
# K4w6VVzUjN55SAB5IdApj8heJSt9IUEwDQYJKoZIhvcNAQEBBQAEggGAl/zlkwEl
# Gc+CTMZTjFhOTMbNOO6iDEU+JD7CzUclP6V0Du9izieLFrCAmTYQA14WWMUCM70F
# WQUopiR7rgM57IgMHRIcSbpHfmuEu6S4ksxtRlwpTWEGwZK5jDbRNZj7pu6LwwBh
# co3YKXkwJYpJej2pM0wDaYBPhJe287UNwJfWTbWDEgRed+bpsn66H2nj6wpDW92f
# z4Q0ApGV5qMhYD2AepP5dofxqItkMQAVD8xF3c4LbXH3/ZJJGyEBfyUeqceoYqE/
# NeIzg5dV6Qatcb1uVFMgctxi/jdgHlmybxPcPbGoFcFr/grqWmdF8nrMmfh97Bop
# HCgD3UpEd4tDlhJfpS3IZZCd+4tFvVxhiETna7LvEprVOmDwZvefAxGKvbGNqImi
# PYlfyF45ZcoExyMA3DH/+DZF7/+xqTseYz8rZm9CI+W+KwrO1cdJXAKxVQ2jBE+o
# jH2b/mG9+Iv0EPoLRdVwq+Y36sNAVe9OjLTnb93FkZjK4NI3W0bmpQItoYIXWjCC
# F1YGCisGAQQBgjcDAwExghdGMIIXQgYJKoZIhvcNAQcCoIIXMzCCFy8CAQMxDzAN
# BglghkgBZQMEAgIFADCBhwYLKoZIhvcNAQkQAQSgeAR2MHQCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDDQSTJxWL++9f3b4LyHc6A1Q/nSFVGy2CFRnORs
# 1/7QPScUKOJg1ZEEx0nJlHqJTP4CEF66hg0lgAPHjjHG3yb+jhgYDzIwMjUwNTE1
# MjMzNjM3WqCCEwMwgga8MIIEpKADAgECAhALrma8Wrp/lYfG+ekE4zMEMA0GCSqG
# SIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwHhcNMjQwOTI2MDAwMDAwWhcNMzUxMTI1MjM1OTU5WjBC
# MQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxIDAeBgNVBAMTF0RpZ2lD
# ZXJ0IFRpbWVzdGFtcCAyMDI0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAvmpzn/aVIauWMLpbbeZZo7Xo/ZEfGMSIO2qZ46XB/QowIEMSvgjEdEZ3v4vr
# rTHleW1JWGErrjOL0J4L0HqVR1czSzvUQ5xF7z4IQmn7dHY7yijvoQ7ujm0u6yXF
# 2v1CrzZopykD07/9fpAT4BxpT9vJoJqAsP8YuhRvflJ9YeHjes4fduksTHulntq9
# WelRWY++TFPxzZrbILRYynyEy7rS1lHQKFpXvo2GePfsMRhNf1F41nyEg5h7iOXv
# +vjX0K8RhUisfqw3TTLHj1uhS66YX2LZPxS4oaf33rp9HlfqSBePejlYeEdU740G
# KQM7SaVSH3TbBL8R6HwX9QVpGnXPlKdE4fBIn5BBFnV+KwPxRNUNK6lYk2y1WSKo
# ur4hJN0SMkoaNV8hyyADiX1xuTxKaXN12HgR+8WulU2d6zhzXomJ2PleI9V2yfmf
# XSPGYanGgxzqI+ShoOGLomMd3mJt92nm7Mheng/TBeSA2z4I78JpwGpTRHiT7yHq
# BiV2ngUIyCtd0pZ8zg3S7bk4QC4RrcnKJ3FbjyPAGogmoiZ33c1HG93Vp6lJ415E
# RcC7bFQMRbxqrMVANiav1k425zYyFMyLNyE1QulQSgDpW9rtvVcIH7WvG9sqYup9
# j8z9J1XqbBZPJ5XLln8mS8wWmdDLnBHXgYly/p1DhoQo5fkCAwEAAaOCAYswggGH
# MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSME
# GDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUn1csA3cOKBWQZqVj
# Xu5Pkh92oFswWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NB
# LmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGlu
# Z0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAPa0eH3aZW+M4hBJH2UOR9hHbm04I
# HdEoT8/T3HuBSyZeq3jSi5GXeWP7xCKhVireKCnCs+8GZl2uVYFvQe+pPTScVJeC
# ZSsMo1JCoZN2mMew/L4tpqVNbSpWO9QGFwfMEy60HofN6V51sMLMXNTLfhVqs+e8
# haupWiArSozyAmGH/6oMQAh078qRh6wvJNU6gnh5OruCP1QUAvVSu4kqVOcJVozZ
# R5RRb/zPd++PGE3qF1P3xWvYViUJLsxtvge/mzA75oBfFZSbdakHJe2BVDGIGVNV
# jOp8sNt70+kEoMF+T6tptMUNlehSR7vM+C13v9+9ZOUKzfRUAYSyyEmYtsnpltD/
# GWX8eM70ls1V6QG/ZOB6b6Yum1HvIiulqJ1Elesj5TMHq8CWT/xrW7twipXTJ5/i
# 5pkU5E16RSBAdOp12aw8IQhhA/vEbFkEiF2abhuFixUDobZaA0VhqAsMHOmaT3XT
# hZDNi5U2zHKhUs5uHHdG6BoQau75KiNbh0c+hatSF+02kULkftARjsyEpHKsF7u5
# zKRbt5oK5YGwFvgc4pEVUNytmB3BpIiowOIIuDgP5M9WArHYSAR16gc0dP2XdkME
# P5eBsX7bf/MGN4K3HP50v/01ZHo/Z5lGLvNwQ7XHBx1yomzLP8lx4Q1zZKDyHcp4
# VQJLu2kWTsKsOqQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMy
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcg
# Q0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
# JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMf
# UBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w
# 1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRk
# tFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYb
# qMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUm
# cJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP6
# 5x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzK
# QtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo
# 80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjB
# Jgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXche
# MBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd
# 4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiC
# qBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl
# /Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
# RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYT
# gAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/
# a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37
# xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmL
# NriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0
# YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJ
# RyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIF
# jTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3y
# ithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1If
# xp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDV
# ySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiO
# DCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQ
# jdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/
# CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCi
# EhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADM
# fRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QY
# uKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXK
# chYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t
# 9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6ch
# nfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0
# MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqG
# SIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi
# +IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n0
# 96wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ8
# 7PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9v
# ytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQt
# J37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDhjCCA4ICAQEwdzBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# AhALrma8Wrp/lYfG+ekE4zMEMA0GCWCGSAFlAwQCAgUAoIHhMBoGCSqGSIb3DQEJ
# AzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjUwNTE1MjMzNjM3WjAr
# BgsqhkiG9w0BCRACDDEcMBowGDAWBBTb04XuYtvSPnvk9nFIUIck1YZbRTA3Bgsq
# hkiG9w0BCRACLzEoMCYwJDAiBCB2dp+o8mMvH0MLOiMwrtZWdf7Xc9sF1mW5BZOY
# Q4+a2zA/BgkqhkiG9w0BCQQxMgQwRKCtKcARXqZNc90cBxpwaukWi3neih9qWhUT
# hWW3BzAn0SBj1ulMME8I8FDa6ovaMA0GCSqGSIb3DQEBAQUABIICAFvXkR05VJwX
# u7BJuooebwrBizNRHkruX158eliFJveJL1ruetbueI2/Dfap7m+TrKSIjxOVhRb/
# HHMwNAnt3yeov6VTJc9bxYZNKG0rp+fmeXnRzrld7P0sILA3E7I8oUywZ4Aiu3Jk
# pBo8aVrXJsZD+uBTQgjsCEAjD0xE9RH807gSbTLEEPyF8pgIkJeMJQS/DtU1sF14
# uBlcE06All3yc3RE+1s+p/c7GBAJqk7AZeyjpWZmHSX4wuj0rmJsjT2UNVoDMrmJ
# 5c2ZMhWXxDNU+2fBkGTtrYaQyAgtO9262fGsA7CA3K0tXv/5KqmPtWeswULkI8rH
# MQDebpLHJzwECdj+9/JQxfwEgSWBHB4drkl1S6nfkvGtyqfX6dydO+x+4E2IeQJ2
# 3/5Vcd4RyjlUz86hKjqDV5jxfmKmR8Esjrrb8vNtPHvhDowClvvH0inc+KzHtcKu
# RZ6sTWKhWr2EoM7Xp7urnbJK+zrIE03n/qBdj3405gWHk53P+21lRJvfixTf8NUF
# GG1OhlW7nHDvvfM4IG3jAq9OP20CDi4qi6e9FFJ69/sDIiQtfELE2FGf2jui4RWF
# p6qPj9pmsG7l1apyY6+DMqCy6cLXiKV7CvYHyGdfkSW/bH2riHmxPQHICBwFNbZT
# 8HiSrKJCaNY6cmD7B820sPkfeYEh0Mdi
# SIG # End signature block
