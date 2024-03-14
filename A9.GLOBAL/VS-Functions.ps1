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

$global:LogInfo = $true
$global:DisplayInfo = $true

$global:SANConnection = $null #set in HPE3PARPSToolkit.psm1 
$global:WsapiConnection = $null
$global:ArrayType = $null
$global:ArrayName = $null
$global:ConnectionType = $null

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (!$global:VSVersion) {
	$global:VSVersion = "v3.0"
}

if (!$global:ConfigDir) {
	$global:ConfigDir = $null 
}


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
	$Validate1 = Test-A9CLIConnection
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

Function Set-DebugLog 
{
<#
.SYNOPSIS
    Enables creating debug logs.
.DESCRIPTION
	Creates Log folder and debug log files in the directory structure where the current modules are running.
.EXAMPLE
    Set-DebugLog -LogDebugInfo $true -Display $true
	Set-DEbugLog -LogDebugInfo $true -Display $false
.PARAMETER LogDebugInfo 
    Specify the LogDebugInfo value to $true to see the debug log files to be created or $false if no debug log files are needed.
.PARAMETER Display 
    Specify the value to $true. This will enable seeing messages on the PS console. This switch is set to true by default. Turn it off by setting it to $false. Look at examples.
.Notes
    NAME:  Set-DebugLog
    LASTEDIT: 04/18/2012
    KEYWORDS: DebugLog
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Boolean]
		$LogDebugInfo = $false,		
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Boolean]
		$Display = $true
	)

	$global:LogInfo = $LogDebugInfo
	$global:DisplayInfo = $Display	
	Write-Verbose  "Exiting function call Set-DebugLog. The value of logging debug information is set to $global:LogInfo and the value of Display on console is $global:DisplayInfo" 
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
			Write-Exception $msg -error
			Throw $msg
		}	
	Write-Verbose  "End:Invoke-CLI called. If no errors reported on the console, the HP3par cli with the cmd = $cmd for user $username completed Successfully"
}
}

Function Test-WSAPIConnection 
{
[CmdletBinding()]
Param(	[Parameter()]	$WsapiConnection = $global:WsapiConnection
	)
	if (($null -eq $WsapiConnection) -or (-not ($WsapiConnection.IPAddress)) -or (-not ($WsapiConnection.Key))) 
		{	Write-warning "Stop: No active WSAPI connection to an HPE Alletra 9000 or Primera or 3PAR storage system or the current session key is expired. Use New-WSAPIConnection cmdlet to connect back." -foreground yellow
			throw 
		}
	$Validate = "Success"	
	return
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
			Catch 	{	Show-RequestException -Exception $_
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
				{	Show-RequestException -Exception $_
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
				{	Show-RequestException -Exception $_
					return
				}
		}
}


Function Show-RequestException 
{
[CmdletBinding()]
Param(	[parameter(Mandatory = $true)]	$Exception
	)
process
{	If ($Exception.Exception.InnerException) 
		{	Write-warning "Please verify the connectivity with the array. Retry with the parameter -Verbose for more informations"
			Write-warning "Status: $($Exception.Exception.Status)" 
			Write-warning "Error code: $($Exception.Exception.Response.StatusCode.value__)"
			Write-warning "Message: $($Exception.Exception.InnerException.Message)"
			Return $Exception.Exception.Status
		}
	If ($_.Exception.Response) 
		{	$result = ConvertFrom-Json -InputObject $Exception.ErrorDetails.Message
			Write-warning "The array sends an error message: $($result.desc)." 
			Write-warning "Status: $($Exception.Exception.Status)"
			Write-warning "Error code: $($result.code)"
			Write-warning "HTTP Error code: $($Exception.Exception.Response.StatusCode.value__)"
			Write-warning "Message: $($result.desc)"
			Return $result.code
		}
}
}

Function Test-FilePath
{
<#
.SYNOPSIS
    Validate an array of file paths. For Internal Use only.
.DESCRIPTION
	Validates if a path specified in the array is valid.
.EXAMPLE
    Test-FilePath -ConfigFiles
.PARAMETER -ConfigFiles 
    Specify an array of config files which need to be validated.
.Notes
    NAME:  Test-FilePath
    LASTEDIT: 05/30/2012
    KEYWORDS: Test-FilePath
#>
Param([String[]]$ConfigFiles)
process 
{	Write-Verbose  "Start: Entering function Test-FilePath." 
	$Validate = @()	
	if (-not ($global:ConfigDir)) 
		{	Write-warning  "STOP: Configuration Directory path is not set. Run scripts Init-PS-Session.ps1 OR import module VS-Functions.psm1 and run cmdlet Set-ConfigDirectory" 
			$Validate = @("Configuration Directory path is not set. Run scripts Init-PS-Session.ps1 OR import module VS-Functions.psm1 and run cmdlet Set-ConfigDirectory.")
			return $Validate
		}
	foreach ($argConfigFile in $ConfigFiles) 
		{	if (-not (Test-Path -Path $argConfigFile )) 
				{	$FullPathConfigFile = $global:ConfigDir + $argConfigFile
					if (-not (Test-Path -Path $FullPathConfigFile)) 
						{	$Validate = $Validate + @(, "Path $FullPathConfigFile not found.")					
						}				
				}
		}	
	return $Validate
}
}

Function Test-A9CLi 
{
<#
.SYNOPSIS
    Test-PARCli object path
.EXAMPLE
    Test-PARCli
#> 
[CmdletBinding()]
param ()
process
{	if 		($SANConnection.CliType -eq "3parcli") 		{	Test-PARCliTest	}
	elseif 	($SANConnection.CliType -eq "SshClient") 	{	Test-SSHSession	}
	else 												{	write-warning "Unable to execute the cmdlet since no active storage connection session exists. `nUse Connect-A9SSH to start a new storage connection session." 
															return $false	
														}	
	return $true
}
}


Function Test-PARCLi 
{
<#
.SYNOPSIS
    Test-PARCli object path
.EXAMPLE
    Test-PARCli
#> 
[CmdletBinding()]
param ()
	$SANCOB = $SANConnection 
	$clittype = $SANCOB.CliType
	Write-Verbose  "Start : in Test-PARCli function " 
	if 		($clittype -eq "3parcli") 		{	Test-PARCliTest	}
	elseif 	($clittype -eq "SshClient") 	{	Test-SSHSession	}
	else 									{	return "FAILURE : Invalid cli type"	}	

}

Function Test-SSHSession 
{
<#
.SYNOPSIS
    Test-SSHSession   
.PARAMETER pathFolder
    Test-SSHSession
.EXAMPLE
    Test-SSHSession 
#> 
[CmdletBinding()]
param()
process
{	$Result = Get-SSHSession | format-list
	if (-not ($Result.count -gt 1 ) ) 	{	return "`nFAILURE : FATAL ERROR : Please check your connection and try again"	}
	RETURN
}	
}

Function Test-PARCliTest 
{
<#
.SYNOPSIS
    Test-PARCli pathFolder
.PARAMETER pathFolder
    Specify the names of the HP3par cli path
.EXAMPLE
    Test-PARCli path -pathFolder c:\test
#> 
[CmdletBinding()]
param (	[Parameter()]	[String]
		$pathFolder = "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter(ValueFromPipeline = $true)]
		$SANConnection = $global:SANConnection 
	)
	$SANCOB = $SANConnection 
	$DeviceIPAddress = $SANCOB.IPAddress
	Write-Verbose  "Start : in Test-PARCli function " 
	$CLIDir = $pathFolder
	if (Test-Path -Path $CLIDir) {
		$clitestfile = $CLIDir + "\cli.exe"
		if ( -not (Test-Path $clitestfile)) {					
			return "FAILURE : HP3PAR cli.exe file was not found. Make sure you have cli.exe file under $CLIDir "
		}
		$pwfile = $SANCOB.epwdFile
		$cmd2 = "help.bat"
		& $cmd2 -sys $DeviceIPAddress -pwf $pwfile
		if (!($?)) {
			return "`nFAILURE : FATAL ERROR"
		}
	}
	else {
		$SANCObj = $SANConnection
		$CLIDir = $SANCObj.CLIDir	
		$clitestfile = $CLIDir + "\cli.exe"
		if (-not (Test-Path $clitestfile )) {					
			return "FAILURE : HP3PAR cli.exe was not found. Make sure you have cli.exe file under $CLIDir "
		}
		$pwfile = $SANCObj.epwdFile
		$cmd2 = "help.bat"
		& $cmd2 -sys $DeviceIPAddress -pwf $pwfile
		if (!($?)) {
			return "`nFAILURE : FATAL ERROR"
		}
	}
}

Function Test-CLIConnection  
{
<#
.SYNOPSIS
    Validate CLI connection object. For Internal Use only.
.DESCRIPTION
	Validates if CLI connection object for VC and OA are null/empty
.EXAMPLE
    Test-CLIConnection -SANConnection
.PARAMETER -SANConnection 
    Specify the VC or OA connection object. Ideally VC or Oa connection object is obtained by executing New-VCConnection or New-OAConnection.
#>
param(	[Parameter()]	$sanconnection = $Global:sanConnection )
process	
{	$Validate = "Success"
	if (($null -eq $SANConnection) -or (-not ($SANConnection.AdminName)) -or (-not ($SANConnection.Password)) -or (-not ($SANConnection.IPAddress)) -or (-not ($SANConnection.SSHDir))) 
		{	Write-Verbose "Connection object is null/empty or username, password,IP address are null/empty. Create a valid connection object and retry"
			$Validate = "Failed"		
		}
	return $Validate
}
}
