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
param(	[Parameter(Mandatory)]				[String]	$ArrayFQDNorIPAddress,
		[Parameter(Mandatory=$true)]				[String]	$SANUserName,
		[Parameter]								[String]	$SANPassword,
		[Parameter(Mandatory)]
		[ValidateSet("3par", "Primera", "Alletra9000", IgnoreCase=$false, ErrorMessage="Value '{0}' is invalid. Try one of: '{1}' and remember it is case sensitive")]
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
	write-verbose "New-Connection: Initiating Get-System_WSAPI call to test the offered key"	
	if 		($ArrayType -eq "3par") 		
			{	$APIurl = 'https://' + $ArrayFQDNorIPAddress + ':8080/api/v1' 
			}
	Elseif (($ArrayType -eq "Primera") -or ($ArrayType -eq "Alletra9000")) 
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
			}
	$global:SANConnection = $SANC
	#-- Obtain more Details by retrieving System Details via a CLI call --
	# $Result3 = Invoke-A9CLICommand -Connection $SANC -cmds "showsys "	
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
	write-host "Attempting to load the HPE 3Par / Primera / Alletra9000 PowerShell Commands that support SSH connectivity. " -ForegroundColor green
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
	of a Alletra9000/Primera/3Par style array the connection command will attempt both an API and a SSH type connection if available. Note that if the command is 
	sucessful for both connection types all commands will be available, however if the array device only supports SSH connections, then on the SSH based commands will be 
	loaded and visiable, and if the array only supports the WSAPI type commands, the API based commnads will be available.
	In the case of the Alletra5000/6000/NimbleStorage type devices, the connection will always be API based.
	In the case of the MSA type devices, the connection will alwasy be API based as well.
.PARAMETER ArrayNameOrIPAddress
	The IP Address or Array name that will resolve via name service to the IP Address of the target device to connect to.
.PARAMETER ArrayType
	This will define which type of array the connection command will attept to connect to. The valid options are 3PAR, Primera, Alletra9K, Alletra6K, Nimble, and MSA.
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
		[ValidateSet('Alletra9000','Primera','3PAR','Nimble','Alletra6000','MSA')]	[String]    $ArrayType,
		[Parameter(Mandatory=$true)]												[System.Management.Automation.PSCredential] $Credential
		)
Process
{	$CurrentModulePath = (Get-Module HPEStorage).path
	[string]$CurrentModulePath = Split-Path $CurrentModulePath -Parent
	$ModPath = $CurrentModulePath	
	if ($ArrayType -eq 'Alletra9000' -or $ArrayType -eq 'Primera' -or $ArrayType -eq '3Par')
			{	write-Verbose "You will be connected to a $ArrayType at the location $ArrayNameOrIPAddress"
				$pass = $Credential.GetNetworkCredential().password 
				$user = $Credential.GetNetworkCredential().username
				write-Verbose "You will be using Username $user and Password $pass"
				connect-A9SSH -ArrayNameOrIPAddress $ArrayNameOrIPAddress -SANUserName $user -SANPassword $pass -AcceptKey
				connect-A9API -ArrayFQDNorIPAddress $ArrayNameOrIPAddress -SANUserName $user -SANPassword $pass -ArrayType $ArrayType
				Write-host "To View the list of commands available to you that utilize the API please use 'Get-Command -module HPEAlletra9000AndPrimeraAnd3Par_API'." -ForegroundColor Green
				Write-host "To View the list of commands available to you that utilize the CLI please use 'Get-Command -module HPEAlletra9000AndPrimeraAnd3Par_CLI'." -ForegroundColor Green
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

