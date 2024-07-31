﻿####################################################################################
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
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]				[String]	$ArrayFQDNorIPAddress,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]				[String]	$SANUserName,
		[Parameter(ValueFromPipeline=$true)]								[String]	$SANPassword,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
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
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]    $ArrayNameOrIPAddress,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SANUserName,	
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SANPassword,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$AcceptKey
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
	
# SIG # Begin signature block
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBL0YG6ZXDn
# VVK3Z6ZlQurAp/fn2ZcNYPOyqPn28eq0Za/+trpdTacXUydJade3MXTKKdXh5kby
# oXgrgDQS/ABToIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5UwghuRAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQGU5TGRWWV0LKY/PJ6Deu08F4WgyjVTleRbi87izyyLi7pOa4tt37/GW
# GLu9seUvkq6pp/hGzC1npWnVyRvi3HwwDQYJKoZIhvcNAQEBBQAEggGAjkbhG/6v
# KErNtHPnuRWlhjx5LtBNGJ0j4ImRFI2KTH2YerCQf96DihCCj8H/J3DZRhPNaNdd
# T/5cmaAZ1SpNCYfLPp2DgTODCisttf42uz1FyYJflAgk5LgYbUPlOYPdObJdkLEU
# MfEE9eQPLHAvtzB5hltgoR5mpX4qKWLWknbQNn5gpbb8C09+m/ZDTwBAyc+ljpTW
# nAkgqBYNzgwXZ1PpNTKB96ShBzKim9XiPc9l8jPNsNErp7I/MdULnDYqVrJEMqni
# fcFlfrH+v6TvC8zh37aWXLSZJM70fM8/ItWdJUY8SyXDlQlDb+inmXZJ2qFv6XAy
# 5P2f4MW1OBb51CrWR4YixtAoQVbW4U/Ttl3RlveEEA0AENp2hFtE7W3C3vz+IfN2
# 3LY4IwO1ZYTvFOQ50n5BfYnpD23inbjn5a7KkNnz8ptUhlUyQ13Y2CT20CoqSjr/
# +CEdDESOozznZhB9qZBEEQLovqGGCLm2SQkqLqGoQQo/7bIL3DQHqckUoYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMPAlXIguemhmTN0BKbdWtS2dspsPDnqK
# xTc6b0CAQ7FvmcumF51vUFsZoa1WTPVeGgIUUp5eLxACHp7PmV/PHziJvLbdhHIY
# DzIwMjQwNzMxMTgxNTM4WqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
# bmNoZXN0ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2Vj
# dGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1oIIS/zCCBl0wggTF
# oAMCAQICEDpSaiyEzlXmHWX8zBLY6YkwDQYJKoZIhvcNAQEMBQAwVTELMAkGA1UE
# BhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGln
# byBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjQwMTE1MDAwMDAwWhcN
# MzUwNDE0MjM1OTU5WjBuMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFuY2hlc3Rl
# cjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydTZWN0aWdvIFB1
# YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzUwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN0Wf0wUibvf04STpNYYGbw9jcRaVhBDaNBp7jmJaA9dQZ
# W5ighrXGNMYjK7Dey5RIHMqLIbT9z9if753mYbojJrKWO4ZP0N5dBT2TwZZaPb8E
# +hqaDZ8Vy2c+x1NiEwbEzTrPX4W3QFq/zJvDDbWKL99qLL42GJQzX3n5wWo60Kkl
# fFn+Wb22mOZWYSqkCVGl8aYuE12SqIS4MVO4PUaxXeO+4+48YpQlNqbc/ndTgszR
# QLF4MjxDPjRDD1M9qvpLTZcTGVzxfViyIToRNxPP6DUiZDU6oXARrGwyP9aglPXw
# YbkqI2dLuf9fiIzBugCDciOly8TPDgBkJmjAfILNiGcVEzg+40xUdhxNcaC+6r0j
# uPiR7bzXHh7v/3RnlZuT3ZGstxLfmE7fRMAFwbHdDz5gtHLqjSTXDiNF58IxPtvm
# ZPG2rlc+Yq+2B8+5pY+QZn+1vEifI0MDtiA6BxxQuOnj4PnqDaK7NEKwtD1pzoA3
# jJFuoJiwbatwhDkg1PIjYnMDbDW+wAc9FtRN6pUsO405jaBgigoFZCw9hWjLNqgF
# VTo7lMb5rVjJ9aSBVVL2dcqzyFW2LdWk5Xdp65oeeOALod7YIIMv1pbqC15R7QCY
# LxcK1bCl4/HpBbdE5mjy9JR70BHuYx27n4XNOZbwrXcG3wZf9gEUk7stbPAoBQID
# AQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNhlxmiMpswHQYD
# VR0OBBYEFGjvpDJJabZSOB3qQzks9BRqngyFMA4GA1UdDwEB/wQEAwIGwDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1UdIARDMEEwNQYM
# KwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20v
# Q1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8vY3JsLnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcmwwegYIKwYB
# BQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYBBQUHMAGGF2h0
# dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IBgQCw3C7J+k82
# TIov9slP1e8YTx+fDsa//hJ62Y6SMr2E89rv82y/n8we5W6z5pfBEWozlW7nWp+s
# dPCdUTFw/YQcqvshH6b9Rvs9qZp5Z+V7nHwPTH8yzKwgKzTTG1I1XEXLAK9fHnmX
# paDeVeI8K6Lw3iznWZdLQe3zl+Rejdq5l2jU7iUfMkthfhFmi+VVYPkR/BXpV7Ub
# 1QyyWebqkjSHJHRmv3lBYbQyk08/S7TlIeOr9iQ+UN57fJg4QI0yqdn6PyiehS1n
# SgLwKRs46T8A6hXiSn/pCXaASnds0LsM5OVoKYfbgOOlWCvKfwUySWoSgrhncihS
# BXxH2pAuDV2vr8GOCEaePZc0Dy6O1rYnKjGmqm/IRNkJghSMizr1iIOPN+23futB
# XAhmx8Ji/4NTmyH9K0UvXHiuA2Pa3wZxxR9r9XeIUVb2V8glZay+2ULlc445CzCv
# VSZV01ZB6bgvCuUuBx079gCcepjnZDCcEuIC5Se4F6yFaZ8RvmiJ4hgwggYUMIID
# /KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUAMFcxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEwMzIyMDAwMDAw
# WhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAM2Y2ENBq26C
# K+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStSVjeYXIjfa3aj
# oW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQBaCxpectRGhh
# nOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE9cbY11XxM2AV
# Zn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExSLnh+va8WxTlA
# +uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OIIq/fWlwBp6KNL
# 19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGdF+z+Gyn9/CRe
# zKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w76kOLIaFVhf5
# sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4CllgrwIDAQABo4IB
# XDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUwHQYDVR0OBBYE
# FF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8E
# CDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0g
# ADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEFBQcBAQRwMG4w
# RwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1Ymxp
# Y1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2Nz
# cC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0ONVgMnoEdJVj9
# TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc6ZvIyHI5UkPC
# bXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1OSkkSivt51Ul
# mJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz2wSKr+nDO+Db
# 8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y4Il6ajTqV2if
# ikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVMCMPY2752LmES
# sRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBeNh9AQO1gQrnh
# 1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupiaAeNHe0pWSGH2
# opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU+CCQaL0cJqlm
# nx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/SjwsusWRItFA3DE8
# MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7xpMeYRriWklU
# PsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs656Oz3TbLyXVo
# MA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEpl
# cnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJV
# U1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9u
# IEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMFcxCzAJ
# BgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJBZvMWhUP2ZQQ
# RLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQnOh2qmcxGzjqe
# mIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypoGJrruH/drCio
# 28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0pKG9ki+PC6VEf
# zutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13jQEV1JnUTCm51
# 1n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9YrcmXcLgsrAi
# mfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/yVl4jnDcw6ULJ
# sBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVgh60KmLmzXiqJ
# c6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/OLoanEWP6Y52
# Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+NrLedIxsE88WzK
# XqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58NHs57ZPUfECcg
# JC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rID
# ZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1UdDwEB/wQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVz
# dC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwNQYI
# KwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3Qu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3OyWM637ayBeR
# 7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJJlFfym1Doi+4
# PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0mUGQHbRcF57ol
# pfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTwbD/zIExAopoe
# 3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i111TW7HV1Ats
# Qa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGezjM6CRpcWed/
# ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+8aW88WThRpv8
# lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH29308ZkpKKdp
# kiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrsxrYJD+3f3aKg
# 6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6Ii8+CQOYDwXM
# +yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz7NgAnOgpCdUo
# 4uDyllU9PzGCBJEwggSNAgEBMGkwVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1Nl
# Y3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFt
# cGluZyBDQSBSMzYCEDpSaiyEzlXmHWX8zBLY6YkwDQYJYIZIAWUDBAICBQCgggH5
# MBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQw
# NzMxMTgxNTM4WjA/BgkqhkiG9w0BCQQxMgQwg1tE6Ngrm1hHDDSMt6qwEC+wdzRl
# GI//hZaH79wzZXV97TvY/ohTrTOQE28/WWHBMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgAtiWTD
# Yv9xkgs+dp3Bh4rzMIblADy2x0ifJd1nW2d9PIB1xFSY8FAJ/4PMn91nM3Mf18rt
# KhX9c8Iikm5oAGkj3VL5VUUXwrM8IBR/hqeXWTw6SqOX13zRAVDkxsWligczPw2t
# VJbtgKe1mniP/F/5mfit9msXmmoeJS9HDtD+mPVLDqz3kXeH2nUgCzKgwvfUbBbb
# /0lxHWLCyoORSU6oLGdx8OckTsn9uRWlNnDSBsDFvLkSmmKWLbnzXxO3aTlWiU4e
# xEkV+7WIchTSjyyRqwLH4nD1uVhuB3qaezy3LNEGvFeX3R15N/qfXh1qRdHIvHzj
# xFuJWAC0KCil6QJ9QP4hO13kfFMMFFP8kJEeuIGi3PpcVQvmrrhfR2yR9VrH/rNA
# mBK3UEFtk6rCsR2tIEMK9MiTDE5pHa2az9AqI4Dmm1ZDewqov5KHcJE+4+lC0gEq
# IjSP8uDswrspxUbAn2dkFF77+CfJWcRWFlmwLbt2MkDkVzR6BPs5253M1RwkSeoj
# C7k0WEjxW+o/cntA2oyEi+dm0+9DtL1eGXhJ5lgI+6Fk/MsaZzG7xnNchPJrSdkK
# W38jC+d0LOyAQojEBvvwVBQTRpCDEf+4ZY/jHnGar0lx/5nq48Vj4cDoSVza52i4
# TLDSVb9xf9PccMd+lBQUisJclmoppNVxOkEYDQ==
# SIG # End signature block
