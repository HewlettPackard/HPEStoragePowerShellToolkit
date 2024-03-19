####################################################################################
## 	© 2024 Hewlett Packard Enterprise Development LP
##	Description: 	Common Module functions.
##		
##	Pre-requisites: Needs HPE 3PAR cli.exe for New-CLIConnection
##					Needs POSH SSH Module for New-PoshSshConnection
##					WSAPI uses HPE 3PAR CLI commands to start, configure, and modify the WSAPI server.
##					For more information about using the CLI, see:
##					• HPE 3PAR Command Line Interface Administrator Guide
##					• HPE 3PAR Command Line Interface Reference
##
##					Starting the WSAPI server    : The WSAPI server does not start automatically.
##					Using the CLI, enter startwsapi to manually start the WSAPI server.
## 					Configuring the WSAPI server: To configure WSAPI, enter setwsapi in the CLI.
##

$global:SANConnection = $null 
$global:WsapiConnection = $null
$global:ArrayType = $null
$global:ArrayName = $null
$global:ConnectionType = $null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if (!$global:VSVersion) {	$global:VSVersion = "v3.5"	}
if (!$global:ConfigDir) {	$global:ConfigDir = $null }

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
		Invoke-CLICommand -Connection $global:SANConnection -Cmds "showsysmgr"
		The command queries a array to get the system information
		$global:SANConnection is created wiith the cmdlet New-CLIConnection or New-PoshSshConnection
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]			$Connection,
		[Parameter(Mandatory = $true)]	[string]$Cmds  
	)

Process{
	Write-verbose "Start: In Invoke-CLICommand - validating input values" 
	#check if connection object contents are null/empty
	if (!$Connection) 
		{	$connection = [_Connection]$Connection	
			#check if connection object contents are null/empty
			$Validate1 = Test-CLIConnection $Connection
			if ($Validate1 -eq "Failed") 
				{	Write-verbose "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-*Connection and pass it as parameter"
					Write-error "Stop: Exiting Invoke-CLICommand since connection object values are null/empty" 
					return
				}
		}
	#check if cmd is null/empty
	if (!$Cmds) 
		{	Write-verbose "No command is passed to the Invoke-CLICommand." 
			Write-error "Stop: Exiting Invoke-CLICommand since command parameter is null/empty null/empty" 
			return
		}
	$clittype = $Connection.cliType
	if ($clittype -eq "3parcli") 
		{	write-warning "In Invoke-CLICommand -> entered in clitype $clittype"
			Invoke-CLI  -DeviceIPAddress  $Connection.IPAddress -epwdFile $Connection.epwdFile -CLIDir $Connection.CLIDir -cmd $Cmds
		}
	elseif ($clittype -eq "SshClient") 
		{	$Result = Invoke-SSHCommand -Command $Cmds -SessionId $Connection.SessionId
			if ($Result.ExitStatus -eq 0) 
				{	return $Result.Output
				}
			else 
				{	$ErrorString = "Error :-" + $Result.Error + $Result.Output			    
					return $ErrorString
				}		
		}
	else 
		{	return "FAILURE : Invalid cliType option selected/chosen"
		}
}
}

Function Invoke-CLI 
{
<#
.SYNOPSIS
    This is private method not to be used. For internal use only.
.DESCRIPTION
    Executes 3par cli command with the specified paramaeters to get data from the specified virtual Connect IP Address 
.EXAMPLE
    Invoke-CLI -DeviceIPAddress "DeviceIPAddress" -CLIDir "Full Installed Path of cli.exe" -epwdFile "C:\loginencryptddetails.txt"  -cmd "show server $serverID"
.PARAMETER DeviceIPAddress 
    Specify the IP address for Virtual Connect(VC) or Onboard Administrator(OA) or Storage or any other device
.PARAMETER CLIDir 
    Specify the absolute path of HP3PAR CLI's cli.exe
.PARAMETER epwdFIle 
    Specify the encrypted password file location
.PARAMETER cmd 
    Specify the command to be run for Virtual Connect
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline = $true)]	[String]	$DeviceIPAddress = $null,
		[Parameter(Position = 1)]								[String]	$CLIDir = "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter(Position = 2)]								[String]	$epwdFile = "C:\HP3PARepwdlogin.txt",
		[Parameter(Position = 3)]								[String]	$cmd = "show -help"
	)
process
{	#write-host  "Password in Invoke-CLI = ",$password	
	if (Test-Path -Path $CLIDir) 
		{	$clifile = $CLIDir + "\cli.exe"
			if ( -not (Test-Path $clifile)) 
				{	Write-error "Stop: HP3PAR cli.exe file not found. Make sure the cli.exe file present in $CLIDir." 			
					return 
				}
		}
	else 
		{	$SANCObj = $global:SANConnection
			$CLIDir = $SANCObj.CLIDir
		}
	if (-not (Test-Path -Path $CLIDir )) 
		{	Write-error "Stop: HP3PAR cli.exe not found. Make sure the HP3PAR CLI installed" 			
			return 
		}	
	Write-Verbose "Running: Calling function Invoke-CLI. Calling Test Network with IP Address $DeviceIPAddress" 
	try 	{	$Ping = new-object System.Net.NetworkInformation.Ping
				$result = $ping.Send($DeviceIPAddress)
				$Status = $result.Status.ToString()
			}
	catch [Exception] {	$Status = "Failed"	}           
	if ($null -eq $Status) 
		{	Write-error "Stop: Calling function Invoke-CLI. Invalid IP Address"  
			Throw "Invalid IP Address"	
		}
	if ($Status -eq "Failed") 
		{	Write-error "Stop:Calling function Invoke-CLI. Unable to ping the device with IP $DeviceIPAddress. Check the IP address and try again."
			Throw "Unable to ping the device with IP $DeviceIPAddress. Check the IP address and try again."
		}
	Write-warning "Running: Calling function Invoke-CLI. Check the Test Network with IP Address = $DeviceIPAddress. Invoking the HP3par cli...." 
	try {	$pwfile = $epwdFile
			$test = $cmd.split(" ")
			$fcmd = $test[0].trim()
			$count = $test.count
			$fcmd1 = $test[1..$count]
			$CLIDir = "$CLIDir\cli.exe"
			$path = "$CLIDir\$fcmd"
			& $CLIDir -sys $DeviceIPAddress -pwf $pwfile $fcmd $fcmd1
			if (!($?	)) 
				{	write-error "FAILURE : FATAL ERROR"
					return 
				}			
		}
	catch 
		{	$msg = "Calling function Invoke-CLI -->Exception Occured. "
			$msg += $_.Exception.ToString()			
			Write-Error $msg 
			Throw $msg
		}	
}
}



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
											[Version]	$MinimumVersion
	)
Process
{	If ( $ClientType -eq 'SshClient')
		{	if ( $null -eq $SANConnection 		 )			{	Throw "Connection object is null/empty. Create a valid connection object and retry"				}
			if ( -not ($SANConnection.UserName)  ) 			{	Throw "Connection object usernameis null or empty. Create a valid connection object and retry"	}
			if ( -not ($SANConnection.IPAddress) ) 			{	Throw "Connection IP address is null/empty. Create a valid connection object and retry"			}
			if ( $SANConnection.CLIType -ne 'SshClient' ) 	{	Throw "Connection Client Type is wrong. Create a valid SSH connection object and retry"			}
			If ( $ClientType -eq 'SshClient'	)			
				{ 	if ($MinimumVersion)	
						{	[Version]$DetectedVersion = ( Get-A9Version_CLI -S ) 
							if ( -not ($DetectedVersion -ge $MinimumVersion) )
								{	Throw "The Detecte Array Version OS is less than the required version need to run this command. `nThe detected version is $DetectedVersion but the required version is $MinimumVersion."
								}
						}
				}
			return
		}
	elseif ($ClientType -eq 'API')
		{	if ( $null -eq $WsapiConnection)				{	Throw "Connection object is null/empty. Create a valid connection object and retry"				}
			if (-not ($WsapiConnection.IPAddress) )			{	Throw "Connection IP address is null/empty. Create a valid connection object and retry"			}
			if (-not ($WsapiConnection.Key))				{	Throw "Connection object Key null or empty. Create a valid connection object and retry"			}	
			return
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
	import-module .\HPEAlletra9000andPrimeraand3Par_API.psd1 -scope global -force
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
			Write-Verbose "Request: Request to close wsapi connection (Invoke-WSAPI)." 
			$data = Invoke-WSAPI -uri $uri -type 'DELETE' 
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
{	if ( -not (Get-Module -ListAvailable -Name Posh-SSH) -and -not(Get-Module -Name Posh-SSH) ) 
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
	import-module .\HPEAlletra9000andPrimeraand3Par_CLI.psd1 -scope global -force
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
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]												[String]    $ArrayNameOrIPAddress,
		[Parameter(Mandatory=$true)]
		[ValidateSet('Alletra9000','Primera',',3PAR','Nimble','Alletra6000','MSA')]	[String]    $ArrayType,
		[Parameter(Mandatory=$true)]												[System.Management.Automation.PSCredential] $Credential
		)
Process
{	if ($ArrayType -eq 'Alletra9000' -or $ArrayType -eq 'Primera' -or $ArrayType -eq '3Par')
			{	write-Verbose "You will be connected to a $ArrayType at the location $ArrayNameOrIPAddress"
				$pass = $Credential.GetNetworkCredential().password 
				$user = $Credential.GetNetworkCredential().username
				write-Verbose "You will be using Username $user and Password $pass"
				connect-A9SSH -ArrayNameOrIPAddress $ArrayNameOrIPAddress -SANUserName $user -SANPassword $pass -AcceptKey
				connect-A9API -ArrayFQDNorIPAddress $ArrayNameOrIPAddress -SANUserName $user -SANPassword $pass -ArrayType $ArrayType
			}	
	elseif ( $ArrayType -eq 'Nimble' -or $ArrayType -eq'Alletra6000')	
			{	write-host 'Nimble'	}
	elseif	($ArrayType -eq 'MSA')	
			{	write-host "msa"	}
	}
}