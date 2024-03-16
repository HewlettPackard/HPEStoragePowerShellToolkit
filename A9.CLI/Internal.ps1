####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Function Close-A9Connection_CLI
{
<#
.SYNOPSIS   
	Session Management Command to close the connection
.DESCRIPTION
	Session Management Command to close the connection
.EXAMPLE
	PS:> Close-A9Connection_CLI
#>
[CmdletBinding()]
param()
Process	
{	if (($global:WsapiConnection) -or ($global:ConnectionType -eq "WSAPI"))
		{	return "A WSAPI Session is enabled. Use Close-WSAPIConnection cmdlet to close and exit from the current WSAPI session"
		}
	if (!$SANConnection)	{	return "No active CLI/PoshSSH session/connection exists"	}		
	$SANCOB = $SANConnection		
	$clittype = $SANCOB.CliType
	$SecnId =""	
	if($clittype -eq "SshClient")	{	$SecnId = $SANCOB.SessionId	}
	$global:SANConnection = $null
	$SANConnection = $global:SANConnection
	if(!$SANConnection)
		{	$Validate1 = Test-CLIConnection $SANConnection
			if($Validate1 -eq "Failed")
				{	$Validate2 = Test-CLIConnection $global:SANConnection
					if($Validate2 -eq "Failed")
						{	Write-Verbose "Connection object is null/empty or Connection object username, password, IPAaddress are null/empty. Create a valid connection object using New-CLIConnection or New-PoshSshConnection"
							if ($clittype -eq "SshClient")			{	$res = Remove-SSHSession -Index $SecnId 	}
							if ($global:SANConnection -eq $null)	{	$global:ConnectionType = $null				}
							return "Success : Exiting SAN connection session End`n"
						}
				}
		}	
}
}

Function Get-A9FcPorts_CLI
{
<#
.SYNOPSIS
	Query to get FC ports
.DESCRIPTION
	Get information for FC Ports
#>

[CmdletBinding()]
Param()
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
Process
{	Write-Host "--------------------------------------`n"
	Write-host "Controller,WWN"	
	$ListofPorts = Get-HostPorts -SANConnection $SANConnection| where-object { ( $_.Type -eq "host" ) -and ($_.Protocol -eq "FC")}
	$Port_Pattern = "(\d):(\d):(\d)"							# Pattern matches value of port: 1:2:3
	$WWN_Pattern = "([0-9a-f][0-9a-f])" * 8						# Pattern matches value of WWN
	foreach ($Port in $ListofPorts)
		{	$NSP  = $Port.Device
			$NSP = $NSP -replace $Port_Pattern , 'N$1:S$2:P$3'
			$WWN = $Port.Port_WWN
			$WWN = $WWN -replace $WWN_Pattern , '$1:$2:$3:$4:$5:$6:$7:$8'
			Write-Host "$NSP,$WWN"
		}
} 
}

Function Get-A9FcPortsToCsv_CLI
{
<#
.SYNOPSIS
	Query to get FC ports
.DESCRIPTION
	Get information for FC Ports
.PARAMETER ResultFile
	CSV file created that contains all Ports definitions
.PARAMETER Demo
	Switch to list the commands to be executed 
.EXAMPLE
    PS:> Get-A9FcPortsToCsv_CLI -ResultFile C:\3PAR-FC.CSV

	creates C:\3PAR-FC.CSV and stores all FCPorts information
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]$ResultFile	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	if(!($ResultFile))	{	return "FAILURE : Please specify csv file path `n example: -ResultFIle C:\portsfile.csv"	}	
	Set-Content -Path $ResultFile -Value "Controller,WWN,SWNumber"
	$ListofPorts = Get-HostPorts -SANConnection $SANConnection| where { ( $_.Type -eq "host" ) -and ($_.Protocol -eq "FC")}
	if (!($ListofPorts))	{	return "FAILURE : No ports to display"	}
	$Port_Pattern = "(\d):(\d):(\d)"							# Pattern matches value of port: 1:2:3
	$WWN_Pattern = "([0-9a-f][0-9a-f])" * 8						# Pattern matches value of WWN
	foreach ($Port in $ListofPorts)
		{	$NSP  = $Port.Device
			$SW = $NSP.Split(':')[-1]
			# Check whether the number is odd
			if ( [Bool]($SW % 2) )	{	$SwitchNumber = 1	}
			else					{	$SwitchNumber = 2	}
			$NSP = $NSP -replace $Port_Pattern , 'N$1:S$2:P$3'
			$WWN = $Port.Port_WWN
			$WWN = $WWN -replace $WWN_Pattern , '$1:$2:$3:$4:$5:$6:$7:$8'
			Add-Content -Path $ResultFile -Value "$NSP,$WWN,$SwitchNumber"
		}
	Write-Verbose "FC ports are stored in $ResultFile" 
	return "Success: FC ports information stored in $ResultFile"
}
}

Function New-A9SshConnection
{
<#
.SYNOPSIS
    Builds a SAN Connection object using Posh SSH connection
.DESCRIPTION
	Creates a SAN Connection object with the specified parameters. 
    No connection is made by this cmdlet call, it merely builds the connection object. 
        
.EXAMPLE
    New-PoshSshConnection -SANUserName Administrator -SANPassword mypassword -ArrayNameOrIPAddress 10.1.1.1 
	Creates a SAN Connection object with the specified Array Name or Array IP Address
.EXAMPLE
    New-PoshSshConnection -SANUserName Administrator -SANPassword mypassword -ArrayNameOrIPAddress 10.1.1.1 -AcceptKey
	Creates a SAN Connection object with the specified Array Name or Array IP Address
.PARAMETER UserName 
    Specify the SAN Administrator user name.
.PARAMETER Password 
    Specify the SAN Administrator password 
.PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true, HelpMessage="Enter Array Name or IP Address")]
										[String]    $ArrayNameOrIPAddress,
		[Parameter(Mandatory=$true)]	[String]	$SANUserName,
		[Parameter()]					[String]	$SANPassword=$null,		
		[Parameter()]					[switch]	$AcceptKey
	)
Process
{	if (-not (Get-Module -ListAvailable -Name Posh-SSH) ) 
		{	try
				{	# install the module automatically
					[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
					iex (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")
				}
			catch
				{	$msg = "Error occurred while installing POSH SSH Module. `nPlease check if internet is enabled. If internet is enabled and you are getting this error,`n Execute Save-Module -Name Posh-SSH -Path <path Ex D:\xxx> `n Then Install-Module -Name Posh-SSH `n If you are getting error like Save-Module is incorrect then `n Check you Power shell Version and Update to 5.1 for this particular Process  `n Or visit https://www.powershellgallery.com/packages/Posh-SSH/2.0.2 `n"
					return "`n Failure : $msg"
				}			
		}	
		# Authenticate		
	try		{	if(!($SANPassword))
					{	$securePasswordStr = Read-Host "SANPassword" -AsSecureString				
						$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $securePasswordStr)
					}
				else{	$tempstring  = convertto-securestring $SANPassword -asplaintext -force				
						$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $tempstring)									
					}
				try	{	if($AcceptKey) 
							{ 	$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds -AcceptKey
							}
						else{	$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds
							}
					}
				catch 
					{	$msg = "In function New-PoshSshConnection. "
						$msg+= $_.Exception.ToString()	
						# Write-Exception function is used for exception logging so that it creates a separate exception log file.
						Write-Exception $msg -error		
						return "Failure : $msg"
					}
				Write-Verbose "Running: Executed . Check on PS console if there are any errors reported"
				if (!$Session)	{	return "New-PoshSshConnection command failed to connect the array."	}
			}
		catch{	$msg = "In function New-PoshSshConnection. "
				$msg+= $_.Exception.ToString()	
				# Write-Exception function is used for exception logging so that it creates a separate exception log file.
				Write-Exception $msg -error		
				return "Failure : $msg"
			}
		$global:SANObjArr += @()
		$global:SANObjArr1 += @()
		if($global:SANConnection)
			{	$SANC = New-Object "_SANConnection"
				$SANC.SessionId = $Session.SessionId		
				$SANC.IPAddress = $ArrayNameOrIPAddress			
				$SANC.UserName = $SANUserName
				$SANC.epwdFile = "Secure String"			
				$SANC.CLIType = "SshClient"
				$SANC.CLIDir = "Null"			
				$global:SANConnection = $SANC
				$SystemDetails = Get-System
				$SANC.Name = $SystemDetails.Name
				$SANC.SystemVersion = Get-Version -S -B
				$SANC.Model = $SystemDetails.Model
				$SANC.Serial = $SystemDetails.Serial
				$SANC.TotalCapacityMiB = $SystemDetails.TotalCap
				$SANC.AllocatedCapacityMiB = $SystemDetails.AllocCap
				$SANC.FreeCapacityMiB = $SystemDetails.FreeCap
				$global:ArrayName = $SANC.Name
				$global:ConnectionType = "CLI"
				###making multiple object support
				$SANC1 = New-Object "_TempSANConn"
				$SANC1.IPAddress = $ArrayNameOrIPAddress			
				$SANC1.UserName = $SANUserName
				$SANC1.epwdFile = "Secure String"		
				$SANC1.SessionId = $Session.SessionId			
				$SANC1.CLIType = "SshClient"
				$SANC1.CLIDir = "Null"
				$global:SANObjArr += @($SANC)
				$global:SANObjArr1 += @($SANC1)			
			}
		else{	$global:SANObjArr = @()
				$global:SANObjArr1 = @()
				$SANC = New-Object "_SANConnection"
				$SANC.IPAddress = $ArrayNameOrIPAddress			
				$SANC.UserName = $SANUserName			
				$SANC.epwdFile = "Secure String"		
				$SANC.SessionId = $Session.SessionId
				$SANC.CLIType = "SshClient"
				$SANC.CLIDir = "Null"
				$global:SANConnection = $SANC		
				$SystemDetails = Get-System
				$SANC.Name = $SystemDetails.Name
				$SANC.SystemVersion = Get-Version -S -B
				$SANC.Model = $SystemDetails.Model
				$SANC.Serial = $SystemDetails.Serial
				$SANC.TotalCapacityMiB = $SystemDetails.TotalCap
				$SANC.AllocatedCapacityMiB = $SystemDetails.AllocCap
				$SANC.FreeCapacityMiB = $SystemDetails.FreeCap
				$global:ArrayName = $SANC.Name
				$global:ConnectionType = "CLI"
				$SANC1 = New-Object "_TempSANConn"
				$SANC1.IPAddress = $ArrayNameOrIPAddress			
				$SANC1.UserName = $SANUserName
				$SANC1.epwdFile = "Secure String"
				$SANC1.SessionId = $Session.SessionId
				$SANC1.CLIType = "SshClient"
				$SANC1.CLIDir = "Null"		
				$global:SANObjArr += @($SANC)
				$global:SANObjArr1 += @($SANC1)		
			}
		Write-Verbose "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used"				
		return $SANC
}
}

Function Set-A9PoshSshConnectionPasswordFile_CLI
{
<#
.SYNOPSIS
	Creates a encrypted password file on client machine to be used by "Set-PoshSshConnectionUsingPasswordFile"
.DESCRIPTION
	Creates an encrypted password file on client machine
.EXAMPLE
	Set-PoshSshConnectionPasswordFile -ArrayNameOrIPAddress "15.1.1.1" -SANUserName "3parDemoUser"  -$SANPassword "demoPass1"  -epwdFile "C:\hpe3paradmepwd.txt"
	
	This examples stores the encrypted password file hpe3paradmepwd.txt on client machine c:\ drive, subsequent commands uses this encryped password file ,
	This example authenticates the entered credentials if correct creates the password file.
.PARAMETER SANUserName 
    Specify the SAN SANUserName .
.PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
.PARAMETER SANPassword 
    Specify the Password with the Linked IP
.PARAMETER epwdFile 
    Specify the file location to create encrypted password file
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]    $ArrayNameOrIPAddress,
		[Parameter(Mandatory=$true)]	[String]	$SANUserName,
		[Parameter()]					[String]	$SANPassword=$null,
		[Parameter(Mandatory=$true)]	[String]    $epwdFile=$null,
		[Parameter()]					[switch]	$AcceptKey       
	)
Process	
{	## Check IP Address Format
	#if(-not (Test-IPFormat $ArrayNameOrIPAddress))		
	#{	Write-DebugLog "Stop: Invalid IP Address $ArrayNameOrIPAddress"
	#	return "FAILURE : Invalid IP Address $ArrayNameOrIPAddress"
	#}		
	Write-verbose "Running: Authenticating credentials - for user $SANUserName and SANIP= $ArrayNameOrIPAddress"	
	# Authenticate
	try
		{	if(!($SANPassword))
			{	$securePasswordStr = Read-Host "SANPassword" -AsSecureString				
				$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $securePasswordStr)
				$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePasswordStr)
				$tempPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
			}
			else
			{	$tempstring  = convertto-securestring $SANPassword -asplaintext -force				
				$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $tempstring)	
				$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tempstring)
				$tempPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
			}			
			if($AcceptKey) 
			{	#$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential (Get-Credential $SANUserName) -AcceptKey                           
				$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds -AcceptKey
			}
			else 
			{	#$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential (Get-Credential $SANUserName)                        
				$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds
			}
			Write-DebugLog "Running: Executed . Check on PS console if there are any errors reported" $Debug
			if (!$Session)	{	return "FAILURE : In function Set-PoshSshConnectionPasswordFile."	}
			else			{	$RemveResult = Remove-SSHSession -Index $Session.SessionId			}
			$Enc_Pass = Protect-String $tempPwd 
			$Enc_Pass,$ArrayNameOrIPAddress,$SANUserName | Export-CliXml $epwdFile	
		}
	catch 
		{	$msg = "In function Set-PoshSshConnectionPasswordFile. "
			$msg+= $_.Exception.ToString()	
			Write-Exception $msg -error		
			return "FAILURE : $msg `n credentials incorrect"
		}
	return "`n Success : encrypted SANPassword file has been created successfully and the file location : $epwdFile"	
}
}

Function Set-A9PoshSshConnectionUsingPasswordFile_CLI
{
<#
.SYNOPSIS
    Creates a SAN Connection object using Encrypted password file
.DESCRIPTION
	Creates a SAN Connection object using Encrypted password file.
    No connection is made by this cmdlet call, it merely builds the connection object. 
.EXAMPLE
    Set-PoshSshConnectionUsingPasswordFile  -ArrayNameOrIPAddress 10.1.1.1 -SANUserName "3parUser" -epwdFile "C:\HPE3PARepwdlogin.txt"

	Creates a SAN Connection object with the specified the Array Name or Array IP Address and password file
.PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
.PARAMETER SANUserName
	Specify the SAN UserName.
.PARAMETER epwdFile 
    Specify the encrypted password file location , example “c:\hpe3parstoreserv244.txt” To create encrypted password file use “New-3parSSHCONNECTION_PassFile” cmdlet           
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]		[String]    $ArrayNameOrIPAddress,
		[Parameter(Mandatory=$true)]		[String]    $SANUserName,
		[Parameter(Mandatory=$true)]		[String]    $epwdFile        
	) 
Process			
{	try		{	if( -not (Test-Path $epwdFile))
					{	Write-Verbose "Running: Path for encrypted password file  was not found. Now created new epwd file."
						return " Encrypted password file does not exist , create encrypted password file using 'Set-3parSSHConnectionPasswordFile' "
					}			
				Write-Verbose "Running: Patch for encrypted password file ."
				$tempFile=$epwdFile			
				$Temp=import-CliXml $tempFile
				$pass=$temp[0]
				$ip=$temp[1]
				$user=$temp[2]
				if($ip -eq $ArrayNameOrIPAddress)  
				{	if($user -eq $SANUserName)
					{	$Passs = UnProtect-String $pass 
						#New-SSHConnection -SANUserName $SANUserName  -SANPassword $Passs -ArrayNameOrIPAddress $ArrayNameOrIPAddress -SSHDir "C:\plink"
						New-PoshSshConnection -ArrayNameOrIPAddress $ArrayNameOrIPAddress -SANUserName $SANUserName -SANPassword $Passs
					}
					else
					{ 	Return "Password file SANUserName $user and entered SANUserName $SANUserName dose not match  . "
						Write-Verbose "Running: Password file SANUserName $user and entered SANUserName $SANUserName dose not match ."
					}
				}
				else 
				{	Return  "Password file ip $ip and entered ip $ArrayNameOrIPAddress dose not match"
					Write-Verbose "Password file ip $ip and entered ip $ArrayNameOrIPAddress dose not match."
				}
			}
	catch	{	$msg = "In function Set-PoshSshConnectionUsingPasswordFile. "
				$msg+= $_.Exception.ToString()	
				Write-Exception $msg -error		
				return "FAILURE : $msg"
			}
}
}

Function Get-A9UserConnectionTemp_CLI
{
<#
  .SYNOPSIS
    Displays information about users who are currently connected (logged in) to the storage system.
  
  .DESCRIPTION
	Displays information about users who are currently connected (logged in) to the storage system.
        
  .EXAMPLE
    Get-UserConnection  -ArrayNameOrIPAddress 10.1.1.1 -CLIDir "C:\cli.exe" -epwdFile "C:\HPE3parepwdlogin.txt" -Option current
	Shows all information about the current connection only.
  .EXAMPLE
    Get-UserConnection  -ArrayNameOrIPAddress 10.1.1.1 -CLIDir "C:\cli.exe" -epwdFile "C:\HPE3parepwdlogin.txt" 
	Shows information about users who are currently connected (logged in) to the storage system.
	 .PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
    .PARAMETER CLIDir 
    Specify the absolute path of HPE 3PAR cli.exe. Default is "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin"
  .PARAMETER epwdFile 
    Specify the encrypted password file , if file does not exists it will create encrypted file using deviceip,username and password  
.PARAMETER Option
    current
	Shows all information about the current connection only.

  .Notes
    NAME:   Get-UserConnectionTemp
    LASTEDIT: January 2020
    KEYWORDS:  Get-UserConnectionTemp
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #Requires HPE 3PAR cli.exe 
 #>
 
[CmdletBinding()]
	param(
		[Parameter(Position=0,ValueFromPipeline=$true)]
		[System.string]
		$CLIDir="C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter(Position=1,Mandatory=$true, ValueFromPipeline=$true)]
		[System.string]
		$ArrayNameOrIPAddress=$null,
		[Parameter(Position=2,Mandatory=$true, ValueFromPipeline=$true)]
		[System.string]
		$epwdFile ="C:\HPE3parepwdlogin.txt",
		[Parameter(Position=3,ValueFromPipeline=$true)]
		[System.string]
		$Option
	)
	if( Test-Path $epwdFile)
	{
		Write-DebugLog "Running: password file was found , it will use the mentioned file"
	}
	#$passwordFile = $epwdFile
	#$cmd1 = $CLIDir+"\showuserconn.bat"
	$cmd2 = "showuserconn "
	$options1 = "current"
	if(!($options1 -eq $option))
	{
		return "Failure : option should be in ( $options1 )"
	}
	if($option -eq "current")
	{
		$cmd2 += " -current "
	}
	#& $cmd1 -sys $ArrayNameOrIPAddress -file $passwordFile
	$result = Invoke-CLI -DeviceIPAddress $ArrayNameOrIPAddress -CLIDir $CLIDir -epwdFile $epwdFile -cmd $cmd2	
	$count = $result.count - 3
	$tempFile = [IO.Path]::GetTempFileName()	
	Add-Content -Path $tempFile -Value "Id,Name,IP_Addr,Role,Connected_since,Current,Client,ClientName"	
	foreach($s in $result[1..$count])
	{
		$s= [regex]::Replace($s,"^ +","")
		$s= [regex]::Replace($s," +"," ")
		$s= [regex]::Replace($s," ",",")
		$s = $s.trim()
		Add-Content -Path $tempFile -Value $s
	}
	Import-CSV $tempFile	
    del $tempFile
}

Function Test-CLIObject 
{
Param( 	
    [string]$ObjectType, 
	[string]$ObjectName ,
	[string]$ObjectMsg = $ObjectType
)
Process
{	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"
	$Result = Invoke-CLICommand -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")	{	$IsObjectExisted = $false	}
	return $IsObjectExisted
}	
} 

