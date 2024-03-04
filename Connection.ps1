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

# _Connection Type Defined
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

# _SANConnection Type Defined
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

# _TempSANConn Type Defined
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

# _vHost Type Defined
add-type @" 
public struct _vHost {
	public string Id;
	public string Name;
	public string Persona;
	public string Address;
	public string Port;
}

"@

# _VLUN Type Defined
add-type @" 
public struct _vLUN {
		public string Name;
		public string LunID;
		public string PresentTo;
		public string vvWWN;
}

"@

# _Version Type Defined
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

# _vHostSet Type Defined
add-type @" 
public struct _vHostSet {
		public string ID;
		public string Name;
		public string Members;		
}

"@

# _vHostSetSummary Type Defined
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

#  _WSAPIconObject Type Defined
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
 = "INFO:"
$Debug = "DEBUG:"

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
} # End Invoke-CLICommand

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
#>
[CmdletBinding()]
param(	[Parameter(Position = 0, ValueFromPipeline = $true)]	[Boolean]	$LogDebugInfo = $false,		
		[parameter(Position = 2, ValueFromPipeline = $true)]	[Boolean]	$Display = $true
	)
process
	{	$global:LogInfo = $LogDebugInfo
		$global:DisplayInfo = $Display	
		Write-verbose "Exiting function call Set-DebugLog. The value of logging debug information is set to $global:LogInfo and the value of Display on console is $global:DisplayInfo" 
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
param(	[Parameter(Position = 0, ValueFromPipeline = $true)]	[String]	$DeviceIPAddress = $null,
		[Parameter(Position = 1)]								[String]	$CLIDir = "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
																			#$CLIDir="C:\Program Files (x86)\Hewlett-Packard\HP 3PAR CLI\bin",
		[Parameter(Position = 2)]								[String]	$epwdFile = "C:\HP3PARepwdlogin.txt",
		[Parameter(Position = 3)]								[String]	$cmd = "show -help"
	)
process
{	#write-host  "Password in Invoke-CLI = ",$password	
	Write-DebugLog "start:In function Invoke-CLI. Validating PUTTY path." $Debug
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
	Write-DebugLog "Running: Calling function Invoke-CLI. Calling Test Network with IP Address $DeviceIPAddress" $Debug	
	$Status = Test-Network $DeviceIPAddress
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
	Write-DebugLog "End:Invoke-CLI called. If no errors reported on the console, the HP3par cli with the cmd = $cmd for user $username completed Successfully" $Debug
}
}

Function Test-Network
{
<#
.SYNOPSIS
    Pings the given IP Adress.
.DESCRIPTION
	Pings the IP address to test for connectivity.
.EXAMPLE
    Test-Network -IPAddress 10.1.1.3
.PARAMETER IPAddress 
    Specify the IP address which needs to be pinged.
#>
param(	[parameter(Mandatory=$true)]	[system.net.ipaddress]	$IPAddress
	)
	try {
		$Ping = new-object System.Net.NetworkInformation.Ping
		$result = $ping.Send($IPAddress)
		$Status = $result.Status.ToString()
	}
	catch [Exception] {
		## Server does not exist - skip it
		$Status = "Failed"
	}                
	return $Status				
}

<# 
Function Test-IPFormat 
{
<#
.SYNOPSIS
    Validate IP address format
.DESCRIPTION
	Validates the given value is in a valid IP address format.
.EXAMPLE
    Test-IPFormat -Address
.PARAMETER Address 
    Specify the Address which will be validated to check if its a valid IP format.

param([string]$Address = $(throw "Missing IP address parameter"))

trap { $false; continue; }
[bool][System.Net.IPAddress]::Parse($Address);
}
#>

Function Test-WSAPIConnection 
{
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline = $true)]	$WsapiConnection = $global:WsapiConnection
	)
process{	
	Write-verbose "Test-WSAPIConnection: Validating the session key"   
	$Validate = "Success"
	if (($null -eq $WsapiConnection) -or (-not ($WsapiConnection.IPAddress)) -or (-not ($WsapiConnection.Key))) 
		{	Write-error "Test-WSAPIConnection: Stop: No active WSAPI connection to an HPE Alletra 9000 or Primera or 3PAR storage system or the current session key is expired. Use New-WSAPIConnection cmdlet to connect back."
			throw 
		}
	else 
		{	Write-verbose "Test-WSAPIConnection: Connected"
		}
}
}

function Invoke-WSAPI 
{
[CmdletBinding()]
Param (
		[parameter(Mandatory = $true, HelpMessage = "Enter the resource URI (ex. /volumes)")]
		[ValidateScript( { if ($_.startswith('/')) { $true } else { throw "-URI must begin with a '/' (eg. /volumes) in its value. Correct the value and try again." } })]
		[string]	$uri,
		
		[parameter(Mandatory = $true, HelpMessage = "Enter request type (GET POST DELETE)")]
		[string]	$type,
		
		[parameter(Mandatory = $false, HelpMessage = "Body of the message")]
		[array]		$body,
		
		[Parameter(ValueFromPipeline = $true)]
					$WsapiConnection = $global:WsapiConnection
	)
    
	Write-verbose "Invoke-WSAPI: Request: Request Invoke-WSAPI URL : $uri TYPE : $type "   
	
	$ip = $WsapiConnection.IPAddress
	$key = $WsapiConnection.Key
	$arrtyp = $global:ArrayType
	
	if ($arrtyp.ToLower() -eq "3par") {
		$APIurl = 'https://' + $ip + ':8080/api/v1' 	
	}
	Elseif (($arrtyp.ToLower() -eq "primera") -or ($arrtyp.ToLower() -eq "alletra9000")) {
		$APIurl = 'https://' + $ip + ':443/api/v1'	
	}
	else {
		return "Invoke-WSAPI: Array type is Null."
	}
	
	$url = $APIurl + $uri
	
	#Construct header
	Write-verbose "Running: Constructing header." 
	$headers = @{}
	$headers["Accept"] = "application/json"
	$headers["Accept-Language"] = "en"
	$headers["Content-Type"] = "application/json"
	$headers["X-HP3PAR-WSAPI-SessionKey"] = $key

	$data = $null

	#write-host "url = $url"
	
	# Request
	If ($type -eq 'GET') {
		Try {
			Write-verbose "Invoke-WSAPI: Request: Invoke-WebRequest for Data, Request Type : $type" 
          
			if ($PSEdition -eq 'Core') {    
				$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
			} 
			else {    
				$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
			}
			return $data
		}
		Catch {
			Write-verbose "Invoke-WSAPI: Stop: Exception Occurs" 
#			Show-RequestException -Exception $_
			return
		}
	}
	If (($type -eq 'POST') -or ($type -eq 'PUT')) {
		Try {
		
			Write-verbose "Invoke-WSAPI: Request: Invoke-WebRequest for Data, Request Type : $type" 
			$json = $body | ConvertTo-Json  -Compress -Depth 10	
		
			#write-host "Invoke json = $json"		       
			if ($PSEdition -eq 'Core') {    
				$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
			} 
			else {    
				$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing 
			}
			return $data
		}
		Catch {
			Write-error "Invoke-WSAPI: Stop: Exception Occurs" 
			Show-RequestException -Exception $_
			return
		}
	}
	If ($type -eq 'DELETE') {
		Try {
			Write-verbose "Invoke-WSAPI: Request: Invoke-WebRequest for Data, Request Type : $type" 
        
			if ($PSEdition -eq 'Core') {    
				$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
			} 
			else {    
				$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
			}
			return $data
		}
		Catch {
			Write-error "Invoke-WSAPI: Stop: Exception Occurs" 
			Show-RequestException -Exception $_
			return
		}
	}
	Write-verbose "End: Invoke-WSAPI" 
}

function Format-Result 
{
[CmdletBinding()]
Param (
		[parameter(Mandatory = $true)]	$dataPS,
		[parameter(Mandatory = $true)]	[string]$TypeName
	)
Begin 
{	$AlldataPS = @() 
}
Process 
{	# Add custom type to the resulting oject for formating purpose	 
	Foreach ($data in $dataPS) 
		{	 If ($data) 
				{	$data.PSObject.TypeNames.Insert(0, $TypeName)
				}		
			$AlldataPS += $data
		}
}
End 
{ 	return $AlldataPS 
}
}

Function Show-RequestException 
{
	[CmdletBinding()]
	Param(
		[parameter(Mandatory = $true)]
		$Exception
	)

	#Exception catch when there's a connectivity problem with the array
	If ($Exception.Exception.InnerException) {
		Write-Host "Please verify the connectivity with the array. Retry with the parameter -Verbose for more informations" -foreground yellow
		Write-Host
		Write-Host "Status: $($Exception.Exception.Status)" -foreground yellow
		Write-Host "Error code: $($Exception.Exception.Response.StatusCode.value__)" -foreground yellow
		Write-Host "Message: $($Exception.Exception.InnerException.Message)" -foreground yellow
		Write-Host
	
		Write-DebugLog "Stop: Please verify the connectivity with the array. Retry with the parameter -Verbose for more informations." $Debug
		Write-DebugLog "Stop: Status: $($Exception.Exception.Status)" $Debug
		Write-DebugLog "Stop: Error code: $($Exception.Exception.Response.StatusCode.value__)" $Debug
		Write-DebugLog "Stop: Message: $($Exception.Exception.InnerException.Message)" $Debug

		Return $Exception.Exception.Status
	}

	#Exception catch when the rest request return an error
	If ($_.Exception.Response) {		
		$result = ConvertFrom-Json -InputObject $Exception.ErrorDetails.Message
		
		Write-Host "The array sends an error message: $($result.desc)." -foreground yellow 
		Write-Host
		Write-Host "Status: $($Exception.Exception.Status)" -foreground yellow
		Write-Host "Error code: $($result.code)" -foreground yellow
		Write-Host "HTTP Error code: $($Exception.Exception.Response.StatusCode.value__)" -foreground yellow
		Write-Host "Message: $($result.desc)" -foreground yellow
		Write-Host
	
		Write-DebugLog "Stop:The array sends an error message: $($Exception.Exception.Message)." $Debug
		Write-DebugLog "Stop: Status: $($Exception.Exception.Status)" $Debug
		Write-DebugLog "Stop: Error code: $($result.code)" $Debug
		Write-DebugLog "Stop: HTTP Error code: $($Exception.Exception.Response.StatusCode.value__)" $Debug
		Write-DebugLog "Stop: Message: $($result.desc)" $Debug

		Return $result.code
	}
	Write-DebugLog "End: Show-RequestException" $Debug
}

Function Test-FilePath ([String[]]$ConfigFiles) 
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
#>

	Write-DebugLog "Start: Entering function Test-FilePath." $Debug
	$Validate = @()	
	if (-not ($global:ConfigDir)) {
		Write-error "STOP: Configuration Directory path is not set. Run scripts Init-PS-Session.ps1 OR import module VS-Functions.psm1 and run cmdlet Set-ConfigDirectory"
		return
	}
	foreach ($argConfigFile in $ConfigFiles) {			
		if (-not (Test-Path -Path $argConfigFile )) {
				
			$FullPathConfigFile = $global:ConfigDir + $argConfigFile
			if (-not (Test-Path -Path $FullPathConfigFile)) {
				$Validate = $Validate + @(, "Path $FullPathConfigFile not found.")					
			}				
		}
	}	
	
	Write-DebugLog "End: Leaving function Test-FilePath." $Debug
	return $Validate
}

Function Test-PARCLi {
<#
.SYNOPSIS
    Test-PARCli object path
.EXAMPLE
    Test-PARCli t
#> 
[CmdletBinding()]
	param 
	(
		[Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
		$SANConnection = $global:SANConnection 
	)
	$SANCOB = $SANConnection 
	$clittype = $SANCOB.CliType
	Write-DebugLog "Start : in Test-PARCli function " "INFO:"
	if ($clittype -eq "3parcli") {
		Test-PARCliTest -SANConnection $SANConnection
	}
	elseif ($clittype -eq "SshClient") {
		Test-SSHSession -SANConnection $SANConnection
	}
	else {
		return "FAILURE : Invalid cli type"
	}	

}

Function Test-SSHSession 
{
<#
.SYNOPSIS
    Test-SSHSession   
.PARAMETER pathFolder
    Test-SSHSession
.EXAMPLE
    Test-SSHSession -SANConnection $SANConnection
#> 
[CmdletBinding()]
param 
	(	[Parameter(ValueFromPipeline = $true)]
		$SANConnection = $global:SANConnection 
	)
	$Result = Get-SSHSession | format-list	
	if ($Result.count -gt 1) 
		{
		}
	else 
		{	write-error	"`nFAILURE : FATAL ERROR : Please check your connection and try again"
			return 
		}
}

Function Test-PARCliTest {
<#
.SYNOPSIS
    Test-PARCli pathFolder
.PARAMETER pathFolder
    Specify the names of the HP3par cli path
.EXAMPLE
    Test-PARCli path -pathFolder c:\test
.Notes
    NAME:  Test-PARCliTest
    LASTEDIT: 06/16/2015
    KEYWORDS: Test-PARCliTest
#> 
[CmdletBinding()]
	param 
	(
		[Parameter(Position = 0, Mandatory = $false)]
		[System.String]
		#$pathFolder = "C:\Program Files (x86)\Hewlett-Packard\HP 3PAR CLI\bin\",
		$pathFolder = "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
		$SANConnection = $global:SANConnection 
	)
	$SANCOB = $SANConnection 
	$DeviceIPAddress = $SANCOB.IPAddress
	Write-DebugLog "Start : in Test-PARCli function " "INFO:"
	#Write-host "Start : in Test-PARCli function "
	$CLIDir = $pathFolder
	if (Test-Path -Path $CLIDir) {
		$clitestfile = $CLIDir + "\cli.exe"
		if ( -not (Test-Path $clitestfile)) {					
			return "FAILURE : HP3PAR cli.exe file was not found. Make sure you have cli.exe file under $CLIDir "
		}
		$pwfile = $SANCOB.epwdFile
		$cmd2 = "help.bat"
		#$cmdFinal = "$cmd2 -sys $DeviceIPAddress -pwf $pwfile"
		& $cmd2 -sys $DeviceIPAddress -pwf $pwfile
		#Invoke-Expression $cmdFinal
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
		#$cmdFinal = "$cmd2 -sys $DeviceIPAddress -pwf $pwfile"
		#Invoke-Expression $cmdFinal
		& $cmd2 -sys $DeviceIPAddress -pwf $pwfile
		if (!($?)) {
			return "`nFAILURE : FATAL ERROR"
		}
	}
	Write-DebugLog "Stop : in Test-PARCli function " "INFO:"
}

Function Test-CLIConnection ($SANConnection) 
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
.Notes
#>
	$Validate = "Success"
	if (($SANConnection -eq $null) -or (-not ($SANConnection.AdminName)) -or (-not ($SANConnection.Password)) -or (-not ($SANConnection.IPAddress)) -or (-not ($SANConnection.SSHDir))) {
		Write-verbose "Connection object is null/empty or username, password,IP address are null/empty. Create a valid connection object and retry"
		$Validate = "Failed"		
	}
	return $Validate
}

Function New-WSAPIConnection 
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
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$ArrayFQDNorIPAddress,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SANUserName=$null,
		[Parameter(ValueFromPipeline=$true)]					[String]	$SANPassword=$null,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateSet("3par", "primera", "alletra9000")]			[String]	$ArrayType
	)
process
{	# This section if required for Self-Signed Certs
	if ($PSEdition -eq 'Core')
		{
		} 
	else 
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
	$SANC1 = New-Object "WSAPIconObject"
	$SANC1.IPAddress = $ArrayFQDNorIPAddress					
	$SANC1.Key = $key
	write-verbose "New-Connection: Initiating Get-System_WSAPI call to test the offered key"		
	$Result = Get-System_WSAPI -WsapiConnection $SANC1
	write-verbose "New-Connection: The result of the Get-System_WSAPI call is as follows"
	write-verbose "$result"	
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

	# Set to the prompt as "Array Name:Connection Type (WSAPI|CLI)>"		
	Write-verbose "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used" 
	#Write-Verbose -Message "Acquired token: $global:3parKey"
	Write-Verbose -Message 'You are now connected to the HPE Storage system'
	Write-Verbose -Message 'Show array informations:'	
	
	return $SANC
}
}

Function Close-WSAPIConnection
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
    Close-WSAPIConnection
#>
[CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
Param(	[Parameter(ValueFromPipeline=$true)]	$WsapiConnection = $global:WsapiConnection 
	)
Begin 
{	# Test if connection exist
    Test-WSAPIConnection
}
Process 
{	if ($pscmdlet.ShouldProcess($h.name,"Disconnect from array")) 
		{	#Build uri
			$key = $WsapiConnection.Key
			Write-verbose "Running: Building uri to close wsapi connection cmdlet." 
			$uri = '/credentials/'+$key
			$data = $null
			Write-verbose "Request: Request to close wsapi connection (Invoke-WSAPI)."
			$data = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
			$global:WsapiConnection = $null
			return $data
		}
	Write-DebugLog "End: Close-WSAPIConnection" $Debug
}
}

Function Get-System_WSAPI 
{
<#
.SYNOPSIS	
	Retrieve informations about the array.
.DESCRIPTION
	Retrieve informations about the array.
.EXAMPLE
	Get-System_WSAPI
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command	
#>
[CmdletBinding()]
Param(
	[Parameter(ValueFromPipeline=$true)]	$WsapiConnection = $global:WsapiConnection 
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null	
	$dataPS = $null	
	$Result = Invoke-WSAPI -uri '/system' -type 'GET' -WsapiConnection $WsapiConnection 	
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
		}	
	if($Result.StatusCode -eq 200)
		{	write-host "Get-System_WSAPI: Cmdlet executed successfully"
			return $dataPS
		}
	else
		{	write-error "Get-System_WSAPI: FAILURE While Executing Get-System_WSAPI" 
			return $Result.StatusDescription
		}
}	
}
