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
$Info = "INFO:"
$Debug = "DEBUG:"

Function Invoke-CLICommand {
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
.Notes
    NAME:  Invoke-CLICommand
    LASTEDIT: June 2012
    KEYWORDS: Invoke-CLICommand
#>
[CmdletBinding()]
	Param(	
		[Parameter(Mandatory = $true)]
		$Connection,
			
		[Parameter(Mandatory = $true)]
		[string]$Cmds  

	)

	Write-DebugLog "Start: In Invoke-CLICommand - validating input values" $Debug 

	#check if connection object contents are null/empty
	if (!$Connection) {	
		$connection = [_Connection]$Connection	
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $Connection
		if ($Validate1 -eq "Failed") {
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-*Connection and pass it as parameter" "ERR:"
			Write-DebugLog "Stop: Exiting Invoke-CLICommand since connection object values are null/empty" "ERR:"
			return
		}
	}
	#check if cmd is null/empty
	if (!$Cmds) {
		Write-DebugLog "No command is passed to the Invoke-CLICommand." "ERR:"
		Write-DebugLog "Stop: Exiting Invoke-CLICommand since command parameter is null/empty null/empty" "ERR:"
		return
	}
	$clittype = $Connection.cliType
	
	if ($clittype -eq "3parcli") {
		#write-host "In Invoke-CLICommand -> entered in clitype $clittype"
		Invoke-CLI  -DeviceIPAddress  $Connection.IPAddress -epwdFile $Connection.epwdFile -CLIDir $Connection.CLIDir -cmd $Cmds
	}
	elseif ($clittype -eq "SshClient") {		
		$Result = Invoke-SSHCommand -Command $Cmds -SessionId $Connection.SessionId
		if ($Result.ExitStatus -eq 0) {
			return $Result.Output
		}
		else {
			$ErrorString = "Error :-" + $Result.Error + $Result.Output			    
			return $ErrorString
		}		
	}
	else {
		return "FAILURE : Invalid cliType option selected/chosen"
	}

}# End Invoke-CLICommand

Function Set-DebugLog {
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
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
		[System.Boolean]
		$LogDebugInfo = $false,		
		[parameter(Position = 2, Mandatory = $true, ValueFromPipeline = $true)]
		[System.Boolean]
		$Display = $true
	)

	$global:LogInfo = $LogDebugInfo
	$global:DisplayInfo = $Display	
	Write-DebugLog "Exiting function call Set-DebugLog. The value of logging debug information is set to $global:LogInfo and the value of Display on console is $global:DisplayInfo" $Debug
}

Function Invoke-CLI {
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
.Notes
    NAME:  Invoke-CLI    
    LASTEDIT: 04/04/2012
    KEYWORDS: 3parCLI
#>
[CmdletBinding()]
	param(
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
		[System.String]
		$DeviceIPAddress = $null,
		[Parameter(Position = 1)]
		[System.String]
		#$CLIDir="C:\Program Files (x86)\Hewlett-Packard\HP 3PAR CLI\bin",
		$CLIDir = "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter(Position = 2)]
		[System.String]
		$epwdFile = "C:\HP3PARepwdlogin.txt",
		[Parameter(Position = 3)]
		[System.String]
		$cmd = "show -help"
	)
	#write-host  "Password in Invoke-CLI = ",$password	
	Write-DebugLog "start:In function Invoke-CLI. Validating PUTTY path." $Debug
	if (Test-Path -Path $CLIDir) {
		$clifile = $CLIDir + "\cli.exe"
		if ( -not (Test-Path $clifile)) {
			
			Write-DebugLog "Stop: HP3PAR cli.exe file not found. Make sure the cli.exe file present in $CLIDir." "ERR:"			
			return "HP3PAR cli.exe file not found. Make sure the cli.exe file present in $CLIDir. "
		}
	}
	else {
		$SANCObj = $global:SANConnection
		$CLIDir = $SANCObj.CLIDir
	}
	if (-not (Test-Path -Path $CLIDir )) {
		Write-DebugLog "Stop: HP3PAR cli.exe not found. Make sure the HP3PAR CLI installed" "ERR:"			
		return "FAILURE : HP3PAR cli.exe not found. Make sure the HP3PAR CLI installed"
	}	
	Write-DebugLog "Running: Calling function Invoke-CLI. Calling Test Network with IP Address $DeviceIPAddress" $Debug	
	$Status = Test-Network $DeviceIPAddress

	if ($null -eq $Status) {
		Write-DebugLog "Stop: Calling function Invoke-CLI. Invalid IP Address"  "ERR:"
		Throw "Invalid IP Address"
		
	}
	if ($Status -eq "Failed") {
		Write-DebugLog "Stop:Calling function Invoke-CLI. Unable to ping the device with IP $DeviceIPAddress. Check the IP address and try again."  "ERR:"
		Throw "Unable to ping the device with IP $DeviceIPAddress. Check the IP address and try again."
	}
	
	Write-DebugLog "Running: Calling function Invoke-CLI. Check the Test Network with IP Address = $DeviceIPAddress. Invoking the HP3par cli...." $Debug
	
	try {

		#if(!($global:epwdFile)){
		#	Write-DebugLog "Stop:Please create encrpted password file first using New-CLIConnection"  "ERR:"
		#	return "`nFAILURE : Please create encrpted password file first using New-CLIConnection"
		#}	
		#write-host "encrypted password file is $epwdFile"
		$pwfile = $epwdFile
		$test = $cmd.split(" ")
		#$test = [regex]::split($cmd," ")
		$fcmd = $test[0].trim()
		$count = $test.count
		$fcmd1 = $test[1..$count]
		#$cmdtemp= [regex]::Replace($fcmd1,"\n"," ")
		#$cmd2 = $fcmd+".bat"
		#$cmdFinal = " $cmd2 -sys $DeviceIPAddress -pwf $pwfile $fcmd1"
		#write-host "Command is  : $cmdFinal"
		#Invoke-Expression $cmdFinal	
		$CLIDir = "$CLIDir\cli.exe"
		$path = "$CLIDir\$fcmd"
		#write-host "command is 1:  $cmd2  $fcmd1 -sys $DeviceIPAddress -pwf $pwfile"
		& $CLIDir -sys $DeviceIPAddress -pwf $pwfile $fcmd $fcmd1
		if (!($?	)) {
			return "FAILURE : FATAL ERROR"
		}	
	}
	catch {
		$msg = "Calling function Invoke-CLI -->Exception Occured. "
		$msg += $_.Exception.ToString()			
		Write-Exception $msg -error
		Throw $msg
	}	
	Write-DebugLog "End:Invoke-CLI called. If no errors reported on the console, the HP3par cli with the cmd = $cmd for user $username completed Successfully" $Debug
}

Function Test-Network ([string]$IPAddress) {
<#
.SYNOPSIS
    Pings the given IP Adress.
.DESCRIPTION
	Pings the IP address to test for connectivity.
.EXAMPLE
    Test-Network -IPAddress 10.1.1.
.PARAMETER IPAddress 
    Specify the IP address which needs to be pinged.
.Notes
    NAME:  Test-Network 
	LASTEDITED: May 9 2012
    KEYWORDS: Test-Network
#>
	$Status = Test-IPFormat $IPAddress
	if ($Status -eq $null) {
		return $Status 
	}

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

Function Test-IPFormat {
<#
.SYNOPSIS
    Validate IP address format
.DESCRIPTION
	Validates the given value is in a valid IP address format.
.EXAMPLE
    Test-IPFormat -Address
.PARAMETER Address 
    Specify the Address which will be validated to check if its a valid IP format.
.Notes
    NAME:  Test-IPFormat
    LASTEDIT: 05/09/2012
    KEYWORDS: Test-IPFormat
#>

	param([string]$Address = $(throw "Missing IP address parameter"))
	trap { $false; continue; }
	[bool][System.Net.IPAddress]::Parse($Address);
}


Function Test-WSAPIConnection 
{
[CmdletBinding()]
Param(	[Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]	$WsapiConnection = $global:WsapiConnection
	)
	
	Write-DebugLog "Request: Test-WSAPIConnection to Test if the session key exists." $Debug  
	Write-DebugLog "Running: Validate the session key" $Debug  
	$Validate = "Success"
	
	if (($null -eq $WsapiConnection) -or (-not ($WsapiConnection.IPAddress)) -or (-not ($WsapiConnection.Key))) {
		Write-DebugLog "Stop: No active WSAPI connection to an HPE Alletra 9000 or Primera or 3PAR storage system or the current session key is expired. Use New-WSAPIConnection cmdlet to connect back."
      
		Write-Host
		Write-Host "Stop: No active WSAPI connection to an HPE Alletra 9000 or Primera or 3PAR storage system or the current session key is expired. Use New-WSAPIConnection cmdlet to connect back." -foreground yellow
		Write-Host
	  
		throw 
	}
	else {
		Write-DebugLog " End: Connected" $Info
	}
	Write-DebugLog "End: Test-WSAPIConnection" $Debug  
}

function Invoke-WSAPI {
	[CmdletBinding()]
	Param (
		[parameter(Position = 0, Mandatory = $true, HelpMessage = "Enter the resource URI (ex. /volumes)")]
		[ValidateScript( { if ($_.startswith('/')) { $true } else { throw "-URI must begin with a '/' (eg. /volumes) in its value. Correct the value and try again." } })]
		[string]
		$uri,
		
		[parameter(Position = 1, Mandatory = $true, HelpMessage = "Enter request type (GET POST DELETE)")]
		[string]
		$type,
		
		[parameter(Position = 2, Mandatory = $false, HelpMessage = "Body of the message")]
		[array]
		$body,
		
		[Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
		$WsapiConnection = $global:WsapiConnection
	)
    
	Write-DebugLog "Request: Request Invoke-WSAPI URL : $uri TYPE : $type " $Debug  
	
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
		return "Array type is Null."
	}
	
	$url = $APIurl + $uri
	
	#Construct header
	Write-DebugLog "Running: Constructing header." $Debug
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
			Write-DebugLog "Request: Invoke-WebRequest for Data, Request Type : $type" $Debug
          
			if ($PSEdition -eq 'Core') {    
				$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
			} 
			else {    
				$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
			}
			return $data
		}
		Catch {
			Write-DebugLog "Stop: Exception Occurs" $Debug
			Show-RequestException -Exception $_
			return
		}
	}
	If (($type -eq 'POST') -or ($type -eq 'PUT')) {
		Try {
		
			Write-DebugLog "Request: Invoke-WebRequest for Data, Request Type : $type" $Debug
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
			Write-DebugLog "Stop: Exception Occurs" $Debug
			Show-RequestException -Exception $_
			return
		}
	}
	If ($type -eq 'DELETE') {
		Try {
			Write-DebugLog "Request: Invoke-WebRequest for Data, Request Type : $type" $Debug
        
			if ($PSEdition -eq 'Core') {    
				$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
			} 
			else {    
				$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
			}
			return $data
		}
		Catch {
			Write-DebugLog "Stop: Exception Occurs" $Debug
			Show-RequestException -Exception $_
			return
		}
	}
	Write-DebugLog "End: Invoke-WSAPI" $Debug
}

function Format-Result {
	[CmdletBinding()]
	Param (
		[parameter(Mandatory = $true)]
		$dataPS,
		[parameter(Mandatory = $true)]
		[string]$TypeName
	)

	Begin { $AlldataPS = @() }

	Process {
		# Add custom type to the resulting oject for formating purpose	 
		Foreach ($data in $dataPS) {	  
			If ($data) {		  
				$data.PSObject.TypeNames.Insert(0, $TypeName)
			}		
			$AlldataPS += $data
		}
	}

	End { return $AlldataPS }
}

Function Show-RequestException {
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
#END Show-RequestException 

Function Test-FilePath ([String[]]$ConfigFiles) {
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

	Write-DebugLog "Start: Entering function Test-FilePath." $Debug
	$Validate = @()	
	if (-not ($global:ConfigDir)) {
		Write-DebugLog "STOP: Configuration Directory path is not set. Run scripts Init-PS-Session.ps1 OR import module VS-Functions.psm1 and run cmdlet Set-ConfigDirectory" "ERR:"
		$Validate = @("Configuration Directory path is not set. Run scripts Init-PS-Session.ps1 OR import module VS-Functions.psm1 and run cmdlet Set-ConfigDirectory.")
		return $Validate
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
.Notes
    NAME:  Test-PARCli
    LASTEDIT: 06/16/2015
    KEYWORDS: Test-PARCli
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

Function Test-SSHSession {
<#
.SYNOPSIS
    Test-SSHSession   
.PARAMETER pathFolder
    Test-SSHSession
.EXAMPLE
    Test-SSHSession -SANConnection $SANConnection
.Notes
    NAME:  Test-SSHSession
    LASTEDIT: 14/03/2017
    KEYWORDS: Test-SSHSession
#> 
[CmdletBinding()]
	param 
	(	
		[Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
		$SANConnection = $global:SANConnection 
	)
	
	$Result = Get-SSHSession | fl
	
	if ($Result.count -gt 1) {
	}
	else {
		return "`nFAILURE : FATAL ERROR : Please check your connection and try again"
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

Function Test-CLIConnection ($SANConnection) {
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
    NAME:  Test-CLIConnection
    LASTEDIT: 05/09/2012
    KEYWORDS: Test-CLIConnection
#>
	$Validate = "Success"
	if (($SANConnection -eq $null) -or (-not ($SANConnection.AdminName)) -or (-not ($SANConnection.Password)) -or (-not ($SANConnection.IPAddress)) -or (-not ($SANConnection.SSHDir))) {
		#Write-DebugLog "Connection object is null/empty or username, password,IP address are null/empty. Create a valid connection object and retry" "ERR:"
		$Validate = "Failed"		
	}
	return $Validate
}

Export-ModuleMember Test-IPFormat , Test-WSAPIConnection , Invoke-WSAPI , Format-Result , Show-RequestException , Test-SSHSession , Set-DebugLog , Test-Network , Invoke-CLI , Invoke-CLICommand , Test-FilePath , Test-PARCli , Test-PARCliTest, Test-CLIConnection

