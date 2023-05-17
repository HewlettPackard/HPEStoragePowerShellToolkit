####################################################################################
## 	© 2019,2020 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
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

############################################################################################################################################
## FUNCTION Invoke-CLICommand
############################################################################################################################################

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
   
  .Link
     http://www.hpe.com
 
 #Requires HP3PAR CLI -Version 3.2.2
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

############################################################################################################################################
## FUNCTION SET-DEBUGLOG
############################################################################################################################################

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
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 
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

############################################################################################################################################
## FUNCTION Invoke-CLI
############################################################################################################################################

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
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 
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

############################################################################################################################################
## FUNCTION TEST-NETWORK
############################################################################################################################################

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
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 
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

############################################################################################################################################
## FUNCTION TEST-IPFORMAT
############################################################################################################################################

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
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 
 #>

	param([string]$Address = $(throw "Missing IP address parameter"))
	trap { $false; continue; }
	[bool][System.Net.IPAddress]::Parse($Address);
}


############################################################################################################################################
## FUNCTION Test-WSAPIConnection
############################################################################################################################################
Function Test-WSAPIConnection {
	[CmdletBinding()]
	Param(
  [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
  $WsapiConnection = $global:WsapiConnection
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

#END Test-WSAPIConnection

############################################################################################################################################
## FUNCTION Invoke-WSAPI
############################################################################################################################################
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
#END Invoke-WSAPI

############################################################################################################################################
## FUNCTION Format-Result
############################################################################################################################################
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
#END Format-Result

############################################################################################################################################
## FUNCTION Show-RequestException 
############################################################################################################################################
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

############################################################################################################################################
## FUNCTION TEST-FILEPATH
############################################################################################################################################

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
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 
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
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 
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
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 
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
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 
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

############################################################################################################################################
## FUNCTION Test-CLIConnection
############################################################################################################################################

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
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 
 #>
	$Validate = "Success"
	if (($SANConnection -eq $null) -or (-not ($SANConnection.AdminName)) -or (-not ($SANConnection.Password)) -or (-not ($SANConnection.IPAddress)) -or (-not ($SANConnection.SSHDir))) {
		#Write-DebugLog "Connection object is null/empty or username, password,IP address are null/empty. Create a valid connection object and retry" "ERR:"
		$Validate = "Failed"		
	}
	return $Validate
}

Export-ModuleMember Test-IPFormat , Test-WSAPIConnection , Invoke-WSAPI , Format-Result , Show-RequestException , Test-SSHSession , Set-DebugLog , Test-Network , Invoke-CLI , Invoke-CLICommand , Test-FilePath , Test-PARCli , Test-PARCliTest, Test-CLIConnection

# SIG # Begin signature block
# MIIh0AYJKoZIhvcNAQcCoIIhwTCCIb0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDxBbZvOwfZzVVJ
# 4YFlp6bz8II4cllVPj4U+bi7MIsD2aCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIQezCCEHcCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# BOcsdRja+DFqTg9y7xixCOHZG1153m6oTjxFAA/x6SwwDQYJKoZIhvcNAQEBBQAE
# ggEAVaud2N2ZXMr8gjbZxK2Xw2GVNgpCX+Ob1vkeOQ/Ar+U4UKARYBVpq/YT0SKA
# F81xizfabGSXd4M96OeAjU2shyU1L4hiv3GYHpeLJoLi0osxivvLQeQyF4tpIsP4
# J5aJ7+O7dmR9mnk7mdFLJv9/YrYNTlliZ3EvWVk77TuN0+/kkde1H4feWmPF3EHw
# F+g1Ex6VUTBK+oNQeBmAgs2WEqorTA87+hBfoP6fB8em6y8JmUtT8Eam+zK/ZdB3
# 8YCeUIUWUcAJcFjfm2AybGMGtA6yeZyN3cU8VyX/vjoR7T9kcoiHaD9kx5vVfnEE
# uOrHPBwGhQuFbFC58m1gdexGMKGCDj0wgg45BgorBgEEAYI3AwMBMYIOKTCCDiUG
# CSqGSIb3DQEHAqCCDhYwgg4SAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDwYLKoZIhvcN
# AQkQAQSggf8EgfwwgfkCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# IJ6ezFucObY0Mm6hxHnQXxdGGVBAr45eMEsXPIG1bGB7AhUArvtaOKe0Tq0XI1pS
# 5prKEC5Ib4UYDzIwMjEwNjE5MDQ1OTE2WjADAgEeoIGGpIGDMIGAMQswCQYDVQQG
# EwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5
# bWFudGVjIFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBU
# aW1lU3RhbXBpbmcgU2lnbmVyIC0gRzOgggqLMIIFODCCBCCgAwIBAgIQewWx1Elo
# UUT3yYnSnBmdEjANBgkqhkiG9w0BAQsFADCBvTELMAkGA1UEBhMCVVMxFzAVBgNV
# BAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3
# b3JrMTowOAYDVQQLEzEoYykgMjAwOCBWZXJpU2lnbiwgSW5jLiAtIEZvciBhdXRo
# b3JpemVkIHVzZSBvbmx5MTgwNgYDVQQDEy9WZXJpU2lnbiBVbml2ZXJzYWwgUm9v
# dCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xNjAxMTIwMDAwMDBaFw0zMTAx
# MTEyMzU5NTlaMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jw
# b3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEoMCYGA1UE
# AxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALtZnVlVT52Mcl0agaLrVfOwAa08cawyjwVrhpon
# ADKXak3JZBRLKbvC2Sm5Luxjs+HPPwtWkPhiG37rpgfi3n9ebUA41JEG50F8eRzL
# y60bv9iVkfPw7mz4rZY5Ln/BJ7h4OcWEpe3tr4eOzo3HberSmLU6Hx45ncP0mqj0
# hOHE0XxxxgYptD/kgw0mw3sIPk35CrczSf/KO9T1sptL4YiZGvXA6TMU1t/HgNuR
# 7v68kldyd/TNqMz+CfWTN76ViGrF3PSxS9TO6AmRX7WEeTWKeKwZMo8jwTJBG1kO
# qT6xzPnWK++32OTVHW0ROpL2k8mc40juu1MO1DaXhnjFoTcCAwEAAaOCAXcwggFz
# MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMGYGA1UdIARfMF0w
# WwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNvbS9ycGEwLgYI
# KwYBBQUHAQEEIjAgMB4GCCsGAQUFBzABhhJodHRwOi8vcy5zeW1jZC5jb20wNgYD
# VR0fBC8wLTAroCmgJ4YlaHR0cDovL3Muc3ltY2IuY29tL3VuaXZlcnNhbC1yb290
# LmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAoBgNVHREEITAfpB0wGzEZMBcGA1UE
# AxMQVGltZVN0YW1wLTIwNDgtMzAdBgNVHQ4EFgQUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwHwYDVR0jBBgwFoAUtnf6aUhHn1MS1cLqBzJ2B9GXBxkwDQYJKoZIhvcNAQEL
# BQADggEBAHXqsC3VNBlcMkX+DuHUT6Z4wW/X6t3cT/OhyIGI96ePFeZAKa3mXfSi
# 2VZkhHEwKt0eYRdmIFYGmBmNXXHy+Je8Cf0ckUfJ4uiNA/vMkC/WCmxOM+zWtJPI
# TJBjSDlAIcTd1m6JmDy1mJfoqQa3CcmPU1dBkC/hHk1O3MoQeGxCbvC2xfhhXFL1
# TvZrjfdKer7zzf0D19n2A6gP41P3CnXsxnUuqmaFBJm3+AZX4cYO9uiv2uybGB+q
# ueM6AL/OipTLAduexzi7D1Kr0eOUA2AKTaD+J20UMvw/l0Dhv5mJ2+Q5FL3a5NPD
# 6itas5VYVQR9x5rsIwONhSrS/66pYYEwggVLMIIEM6ADAgECAhB71OWvuswHP6EB
# IwQiQU0SMA0GCSqGSIb3DQEBCwUAMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRT
# eW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0
# d29yazEoMCYGA1UEAxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAe
# Fw0xNzEyMjMwMDAwMDBaFw0yOTAzMjIyMzU5NTlaMIGAMQswCQYDVQQGEwJVUzEd
# MBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVj
# IFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgU2lnbmVyIC0gRzMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCvDoqq+Ny/aXtUF3FHCb2NPIH4dBV3Z5Cc/d5OAp5LdvblNj5l1SQgbTD53R2D
# 6T8nSjNObRaK5I1AjSKqvqcLG9IHtjy1GiQo+BtyUT3ICYgmCDr5+kMjdUdwDLNf
# W48IHXJIV2VNrwI8QPf03TI4kz/lLKbzWSPLgN4TTfkQyaoKGGxVYVfR8QIsxLWr
# 8mwj0p8NDxlsrYViaf1OhcGKUjGrW9jJdFLjV2wiv1V/b8oGqz9KtyJ2ZezsNvKW
# lYEmLP27mKoBONOvJUCbCVPwKVeFWF7qhUhBIYfl3rTTJrJ7QFNYeY5SMQZNlANF
# xM48A+y3API6IsW0b+XvsIqbAgMBAAGjggHHMIIBwzAMBgNVHRMBAf8EAjAAMGYG
# A1UdIARfMF0wWwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9k
# LnN5bWNiLmNvbS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9ycGEwQAYDVR0fBDkwNzA1oDOgMYYvaHR0cDovL3RzLWNybC53cy5zeW1hbnRl
# Yy5jb20vc2hhMjU2LXRzcy1jYS5jcmwwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# DgYDVR0PAQH/BAQDAgeAMHcGCCsGAQUFBwEBBGswaTAqBggrBgEFBQcwAYYeaHR0
# cDovL3RzLW9jc3Aud3Muc3ltYW50ZWMuY29tMDsGCCsGAQUFBzAChi9odHRwOi8v
# dHMtYWlhLndzLnN5bWFudGVjLmNvbS9zaGEyNTYtdHNzLWNhLmNlcjAoBgNVHREE
# ITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtNjAdBgNVHQ4EFgQUpRMB
# qZ+FzBtuFh5fOzGqeTYAex0wHwYDVR0jBBgwFoAUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwDQYJKoZIhvcNAQELBQADggEBAEaer/C4ol+imUjPqCdLIc2yuaZycGMv41Up
# ezlGTud+ZQZYi7xXipINCNgQujYk+gp7+zvTYr9KlBXmgtuKVG3/KP5nz3E/5jMJ
# 2aJZEPQeSv5lzN7Ua+NSKXUASiulzMub6KlN97QXWZJBw7c/hub2wH9EPEZcF1rj
# pDvVaSbVIX3hgGd+Yqy3Ti4VmuWcI69bEepxqUH5DXk4qaENz7Sx2j6aescixXTN
# 30cJhsT8kSWyG5bphQjo3ep0YG5gpVZ6DchEWNzm+UgUnuW/3gC9d7GYFHIUJN/H
# ESwfAD/DSxTGZxzMHgajkF9cVIs+4zNbgg/Ft4YCTnGf6WZFP3YxggJaMIICVgIB
# ATCBizB3MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRp
# b24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxKDAmBgNVBAMTH1N5
# bWFudGVjIFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEHvU5a+6zAc/oQEjBCJBTRIw
# CwYJYIZIAWUDBAIBoIGkMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkq
# hkiG9w0BCQUxDxcNMjEwNjE5MDQ1OTE2WjAvBgkqhkiG9w0BCQQxIgQgVRG9QPs1
# 1gdfxsMcrzC7x+EoZavCHzMuIGtDyMgTeMQwNwYLKoZIhvcNAQkQAi8xKDAmMCQw
# IgQgxHTOdgB9AjlODaXk3nwUxoD54oIBPP72U+9dtx/fYfgwCwYJKoZIhvcNAQEB
# BIIBADXr4w5FBbTo+INYs4kFT/CyLAwcjVqS0Yv6zHWPojQud+b7VsoUuGccRg55
# aVifDof7tgeYyNc6vh0Njq5xj2QUi6ahhWkrGa3XxvuMAsPaQxSMHWyZ+hP3gIsI
# ahw+o319JwCKFb/giJcWHzTk2cocAN45Wg6b+ynJifpZltJccn28CQ9FMoO2CL86
# O9PkluI0cO8vOCv55aclOFCOWfuEbp2NAGe5xDZqg/4ASdELIBRR14aWNQeTNdih
# Q32k+Y0wnt2KtlflEq6yILIeEMAdGl3RACp5EEaF+kT1PbzSrLVzQSGoEKtjEMDE
# WphFXZ8L/Kqi4jXsnVSNWRpGqP0=
# SIG # End signature block
