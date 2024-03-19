####################################################################################
## 	© 2019,2020 Hewlett Packard Enterprise Development LP
##
##	File Name:		VS-Functions.psm1
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
##	Created:		June 2015
##	Last Modified:	July 2020
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
##	
#####################################################################################

# Generic connection object 
<#
add-type @" 

public struct _Connection{
public string SessionId;
public string Name;
public string IPAddress;
public string SystemVersion;
public string Model;
public string Serial;
public string TotalCapacityMiB;
public string AllocatedCapacityMiB;
public string FreeCapacityMiB;     
public string UserName;
public string epwdFile;
public string CLIDir;
public string CLIType;
}

"@

add-type @" 

public struct _SANConnection{
public string SessionId;
public string Name;
public string IPAddress;
public string SystemVersion;
public string Model;
public string Serial;
public string TotalCapacityMiB;
public string AllocatedCapacityMiB;
public string FreeCapacityMiB;     
public string UserName;
public string epwdFile;
public string CLIDir;
public string CLIType;
}

"@ 

add-type @" 

public struct _TempSANConn{
public string SessionId;
public string Name;
public string IPAddress;
public string SystemVersion;
public string Model;
public string Serial;
public string TotalCapacityMiB;
public string AllocatedCapacityMiB;
public string FreeCapacityMiB;     
public string UserName;
public string epwdFile;
public string CLIDir;
public string CLIType;
}

"@ 

add-type @" 
public struct _vHost {
	public string Id;
	public string Name;
	public string Persona;
	public string Address;
	public string Port;
}

"@

add-type @" 
public struct _vLUN {
		public string Name;
		public string LunID;
		public string PresentTo;
		public string vvWWN;
}

"@

add-type @"
public struct _Version{
		public string ReleaseVersionName;
		public string Patches;
		public string CliServer;
		public string CliClient;
		public string SystemManager;
		public string Kernel;
		public string TPDKernelCode;
		
}
"@

add-type @" 
public struct _vHostSet {
		public string ID;
		public string Name;
		public string Members;		
}

"@

add-type @" 
public struct _vHostSetSummary {
		public string ID;
		public string Name;
		public string HOST_Cnt;
		public string VVOLSC;
		public string Flashcache;
		public string QoS;
		public string RC_host;
}

"@

add-type @" 

public struct WSAPIconObject{
public string Id;
public string Name;
public string SystemVersion;
public string Patches;
public string IPAddress;
public string Model;
public string SerialNumber;
public string TotalCapacityMiB;
public string AllocatedCapacityMiB;
public string FreeCapacityMiB;
public string Key;
}

"@

#>

Function Invoke-CLICommand 
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
Param(	# [Parameter(Mandatory = $true)]	$Connection,
		[Parameter(Mandatory = $true)]	[string]	$Cmds  
	)
	$connection = $SANConnection	
	$Validate1 = Test-A9Connection -ClientType 'SshClient' 
	if ($Validate1 -eq "Failed") {
		Write-Verbose  "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-*Connection and pass it as parameter" 
		Write-Verbose  "Stop: Exiting Invoke-CLICommand since connection object values are null/empty"
		return
	}
	$clittype = $Connection.cliType	
	if ($clittype -eq "SshClient") 
		{	$Result = Invoke-SSHCommand -Command $Cmds -SessionId $Connection.SessionId
			if ($Result.ExitStatus -eq 0) 	{	return $Result.Output	}
			else{	$ErrorString = "Error :-" + $Result.Error + $Result.Output			    
					return $ErrorString
				}		
		}
	else{	return "FAILURE : Invalid cliType option selected/chosen"	}

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
param(
		[Parameter(Mandatory = $true)]	[String]	$DeviceIPAddress,
		[Parameter()]					[String]	$CLIDir = "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter()]					[String]	$epwdFile = "C:\HP3PARepwdlogin.txt",
		[Parameter()]					[String]	$cmd = "show -help"
	)
process	
{	Write-Verbose  "start:In function Invoke-CLI. Validating PUTTY path." 
	if (Test-Path -Path $CLIDir) 
		{	$clifile = $CLIDir + "\cli.exe"
			if ( -not (Test-Path $clifile)) 
				{	Write-Verbose  "Stop: HP3PAR cli.exe file not found. Make sure the cli.exe file present in $CLIDir." 		
					return "HP3PAR cli.exe file not found. Make sure the cli.exe file present in $CLIDir. "
				}
		}
	else{	$SANCObj = $global:SANConnection
			$CLIDir = $SANCObj.CLIDir
		}
	if (-not (Test-Path -Path $CLIDir )) 
		{	Write-Verbose  "Stop: HP3PAR cli.exe not found. Make sure the HP3PAR CLI installed" 		
			return "FAILURE : HP3PAR cli.exe not found. Make sure the HP3PAR CLI installed"
		}	
	Write-Verbose  "Running: Calling function Invoke-CLI. Calling Test Network with IP Address $DeviceIPAddress" 
	$Ping = new-object System.Net.NetworkInformation.Ping
	$result = $ping.Send($DeviceIPAddress)
	$Status = $result.Status.ToString()
	if ($null -eq $Status) 
		{	Write-Verbose  "Stop: Calling function Invoke-CLI. Invalid IP Address" 
			Throw "Invalid IP Address"
		}
	if ($Status -eq "Failed") 
		{	Write-Verbose  "Stop:Calling function Invoke-CLI. Unable to ping the device with IP $DeviceIPAddress. Check the IP address and try again." 
			Throw "Unable to ping the device with IP $DeviceIPAddress. Check the IP address and try again."
		}
	Write-Verbose  "Running: Calling function Invoke-CLI. Check the Test Network with IP Address = $DeviceIPAddress. Invoking the HP3par cli...." 
	try {	$pwfile = $epwdFile
			$test 	= $cmd.split(" ")
			$fcmd 	= $test[0].trim()
			$count 	= $test.count
			$fcmd1 	= $test[1..$count]
			$CLIDir = "$CLIDir\cli.exe"
			$path 	= "$CLIDir\$fcmd"
			& $CLIDir -sys $DeviceIPAddress -pwf $pwfile $fcmd $fcmd1
			if (!($?	)) {	return "FAILURE : FATAL ERROR"	}	
		}
	catch{	$msg = "Calling function Invoke-CLI -->Exception Occured. "
			$msg += $_.Exception.ToString()			
			Throw $msg
		}	
	Write-Verbose  "End:Invoke-CLI called. If no errors reported on the console, the HP3par cli with the cmd = $cmd for user $username completed Successfully"
}
}


function Invoke-WSAPI 
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
	Write-Verbose  "Request: Request Invoke-WSAPI URL : $uri TYPE : $type " 
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


