####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
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
##	File Name:		Internal.psm1
##	Description: 	Internal cmdlets
##		
##	Created:		January 2020
##	Last Modified:	May 2021
##	History:		v3.0 - Created
##                  v3.1 - Modified to add HPE Alletra 9000
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

######################################################################################################################
## FUNCTION Close-Connection
######################################################################################################################
Function Close-Connection
{
<#
  .SYNOPSIS   
   Session Management Command to close the connection
   
  .DESCRIPTION
   Session Management Command to close the connection
   
  .EXAMPLE
	Close-Connection
		
  .Notes
    NAME: Close-Connection  
    LASTEDIT: January 2020
    KEYWORDS: Close-Connection 
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
 [CmdletBinding()]
	param(
				
		[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection       
	)
	
	Write-DebugLog "Start : in Close-Connection function " "INFO:"
	
	if (($global:WsapiConnection) -or ($global:ConnectionType -eq "WSAPI")){
		return "A WSAPI Session is enabled. Use Close-WSAPIConnection cmdlet to close and exit from the current WSAPI session"
	}
	
	if (!$SANConnection){
		return "No active CLI/PoshSSH session/connection exists"
	}	
	
	$SANCOB = $SANConnection		
	$clittype = $SANCOB.CliType
	$SecnId =""
	
	if($clittype -eq "SshClient")
	{
		$SecnId = $SANCOB.SessionId
	}
	
	$global:SANConnection = $null
	#write-host "$global:SANConnection"
	$SANConnection = $global:SANConnection
	
	#write-host "$SANConnection"
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		#write-host "$Validate1"
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			#write-host "$Validate2"
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or Connection object username, password, IPAaddress are null/empty. Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting GGet-UserConnection since SAN connection object values are null/empty" $Debug
				if($clittype -eq "SshClient")
				{
					$res = Remove-SSHSession -Index $SecnId 
				}
				
				write-host ""				
				# Set to the default prompt as current path
				if ($global:SANConnection -eq $null)
				{
					$global:ConnectionType = $null
					Function global:prompt {(Get-Location).Path + ">"}
				}
				return "Success : Exiting SAN connection session End`n"
			}
		}
	}	
} # End Function Close-Connection

########################################
##### FUNCTION Get-CmdList   ###########
########################################
Function Get-CmdList{
<#
  .SYNOPSIS
    Get list of  all HPE Alletra 9000, Primera and 3PAR PowerShell cmdlets
  
  .DESCRIPTION
    Note : This cmdlet (Get-CmdList) is deprecated and will be removed in a 
	subsequent release of PowerShell Toolkit. Consider using the cmdlet (Get-CmdList) instead.
  
    Get list of  all HPE Alletra 9000, Primera and 3PAR PowerShell cmdlets 
        
  .EXAMPLE
    Get-CmdList	
	List all available HPE Alletra 9000, Primera and 3PAR PowerShell cmdlets.
	
  .EXAMPLE
    Get-CmdList -WSAPI
	List all available HPE Alletra 9000, Primera and 3PAR PowerShell WSAPI cmdlets only.
	
  .EXAMPLE
    Get-CmdList -CLI
	List all available HPE Alletra 9000, Primera and 3PAR PowerShell CLI cmdlets only.
	
  .Notes
    NAME:  Get-CmdList
    CREATED: 05/14/2015
    LASTEDIT: 05/26/2020
    KEYWORDS: Get-CmdList
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
 [CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[Switch]
		$CLI, 
		
		[Parameter(Position=1, Mandatory=$false)]
		[Switch]
		$WSAPI
	)
 
    $Array = @()
    
    #$psToolKitModule = (Get-Module PowerShellToolkitForHPEPrimeraAnd3PAR);
	$psToolKitModule = (Get-Module HPEStoragePowerShellToolkit);
    $nestedModules = $psToolKitModule.NestedModules;
    $noOfNestedModules = $nestedModules.Count;
    
    $totalCmdlets = 0;
    $totalCLICmdlets = 0;
    $totalWSAPICmdlets = 0;
    $totalDeprecatedCmdlets = 0;

    # If chosen to select all WSAPI cmdlets
    if($WSAPI)
    {
        foreach ($nestedModule in $nestedModules[0..$noOfNestedModules])
        {        
            $ExpCmdlets = $nestedModule.ExportedCommands;

            if ($nestedModule.Path.Contains("\WSAPI\"))
            {    
                foreach ($h in $ExpCmdlets.GetEnumerator()) 
                {            
                    $Result1 = "" | Select CmdletName, CmdletType, ModuleVersion, SubModule, Module, Remarks
                    $Result1.CmdletName = $($h.Key);            
                    $Result1.ModuleVersion = $psToolKitModule.Version;
                    $Result1.CmdletType = "WSAPI";
                    $Result1.SubModule = $nestedModule.Name;
                    $Result1.Module = $psToolKitModule.Name;
                    
                    If ($nestedModule.Name -eq "HPE3PARPSToolkit-WSAPI")
                    {
                        $Result1.Remarks = "Deprecated";
                        $totalDeprecatedCmdlets += 1;
                    }
                    $totalCmdlets += 1;
                    $totalWSAPICmdlets += 1;
                
                    $Array += $Result1
                }
            }
        }
    }
    # If chosen to select all CLI cmdlets
    elseif($CLI)
    {
        foreach ($nestedModule in $nestedModules[0..$noOfNestedModules])
        {        
            $ExpCmdlets = $nestedModule.ExportedCommands;    
                
            if ($nestedModule.Path.Contains("\CLI\"))
            {    
                foreach ($h in $ExpCmdlets.GetEnumerator()) 
                {            
                    $Result1 = "" | Select CmdletName, CmdletType, ModuleVersion, SubModule, Module, Remarks
                    $Result1.CmdletName = $($h.Key);            
                    $Result1.ModuleVersion = $psToolKitModule.Version;
                    $Result1.CmdletType = "CLI";
                    $Result1.SubModule = $nestedModule.Name;
                    $Result1.Module = $psToolKitModule.Name;
                    
                    If ($nestedModule.Name -eq "HPE3PARPSToolkit-CLI")
                    {
                        $Result1.Remarks = "Deprecated";
                        $totalDeprecatedCmdlets += 1;
                    }

                    $totalCmdlets += 1;
                    $totalCLICmdlets += 1;
                
                    $Array += $Result1
                }
            }
        }
    }
    # If chosen to select all cmdlets
    else
    {    
        foreach ($nestedModule in $nestedModules[0..$noOfNestedModules])
        {        
            if ($nestedModule.Path.Contains("\CLI\") -or $nestedModule.Path.Contains("\WSAPI\"))        
            {
                $ExpCmdlets = $nestedModule.ExportedCommands;    
                
                foreach ($h in $ExpCmdlets.GetEnumerator()) 
                {            
                    $Result1 = "" | Select CmdletName, CmdletType, ModuleVersion, SubModule, Module, Remarks
                    $Result1.CmdletName = $($h.Key);            
                    $Result1.ModuleVersion = $psToolKitModule.Version;                
                    $Result1.SubModule = $nestedModule.Name;
                    $Result1.Module = $psToolKitModule.Name;                
                    $Result1.CmdletType = if ($nestedModule.Path.Contains("\CLI\")) {"CLI"} else {"WSAPI"}

                    If ($nestedModule.Name -eq "HPE3PARPSToolkit-WSAPI" -or $nestedModule.Name -eq "HPE3PARPSToolkit-CLI")
                    {
                        $Result1.Remarks = "Deprecated";
                        $totalDeprecatedCmdlets += 1;
                    }

                    $totalCmdlets += 1;                            
                    $Array += $Result1
                }            
            }        
        }
    }

    $Array | Format-Table
    $Array = $null;
    Write-Host "$totalCmdlets Cmdlets listed. ($totalDeprecatedCmdlets are deprecated)";

 }# Ended Get-CmdList
 
 #########################################################################
################### FUNCTION Get-FcPorts ################################
#########################################################################
Function Get-FcPorts
{
<#
   .SYNOPSIS
	Query to get FC ports

   .DESCRIPTION
	Get information for FC Ports
 
   .PARAMETER SANConnection
	Connection String to the array
  	
   .EXAMPLE
	Get-FcPorts 
			
  .Notes
    NAME:  Get-FcPorts
    LASTEDIT: January 2020
    KEYWORDS: Get-FcPorts
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #Requires HPE 3PAR cli.exe
 #>
 
[CmdletBinding()]
	Param(	
			[Parameter()]
			[_SANConnection]
			$SANConnection=$Global:SANConnection
		)
	$plinkresult = Test-PARCli -SANConnection $SANConnection 
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
			
	Write-Host "--------------------------------------`n"
	Write-host "Controller,WWN"	

	$ListofPorts = Get-HostPorts -SANConnection $SANConnection| where { ( $_.Type -eq "host" ) -and ($_.Protocol -eq "FC")}

	$Port_Pattern = "(\d):(\d):(\d)"							# Pattern matches value of port: 1:2:3
	$WWN_Pattern = "([0-9a-f][0-9a-f])" * 8						# Pattern matches value of WWN

	foreach ($Port in $ListofPorts)
	{
		$NSP  = $Port.Device
		#$SW = $NSP.Split(':')[-1]	
		
		$NSP = $NSP -replace $Port_Pattern , 'N$1:S$2:P$3'
		
		$WWN = $Port.Port_WWN
		$WWN = $WWN -replace $WWN_Pattern , '$1:$2:$3:$4:$5:$6:$7:$8'

		Write-Host "$NSP,$WWN"
		Write-host ""
	}
} # END FUNCTION Get-FcPorts

###########################################################################
####################### FUNCTION Get-FcPortsToCsv #########################
###########################################################################

Function Get-FcPortsToCsv
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
    	Get-FcPortsToCsv -ResultFile C:\3PAR-FC.CSV
			creates C:\3PAR-FC.CSV and stores all FCPorts information
			
  .Notes
    NAME:  Get-FcPortsToCsv
    LASTEDIT: January 2020
    KEYWORDS: Get-FcPortsToCsv
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #Requires HPE 3PAR cli.exe
 #>
 
[CmdletBinding()]
	Param(	
			[Parameter()]
			[_SANConnection]
			$SANConnection = $global:SANConnection,
			
			[Parameter()]
			[String]$ResultFile
		)

	$plinkresult = Test-PARCli -SANConnection $SANConnection 
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	if(!($ResultFile)){
		return "FAILURE : Please specify csv file path `n example: -ResultFIle C:\portsfile.csv"
	}	
	Set-Content -Path $ResultFile -Value "Controller,WWN,SWNumber"

	$ListofPorts = Get-HostPorts -SANConnection $SANConnection| where { ( $_.Type -eq "host" ) -and ($_.Protocol -eq "FC")}
	if (!($ListofPorts)){
		return "FAILURE : No ports to display"
	}

	$Port_Pattern = "(\d):(\d):(\d)"							# Pattern matches value of port: 1:2:3
	$WWN_Pattern = "([0-9a-f][0-9a-f])" * 8						# Pattern matches value of WWN

	foreach ($Port in $ListofPorts)
	{
		$NSP  = $Port.Device
		$SW = $NSP.Split(':')[-1]
		if ( [Bool]($SW % 2) )			# Check whether the number is odd
		{
			$SwitchNumber = 1
		}
		else
		{
			$SwitchNumber = 2
		}
		
		
		$NSP = $NSP -replace $Port_Pattern , 'N$1:S$2:P$3'
		
		$WWN = $Port.Port_WWN
		$WWN = $WWN -replace $WWN_Pattern , '$1:$2:$3:$4:$5:$6:$7:$8'

		Add-Content -Path $ResultFile -Value "$NSP,$WWN,$SwitchNumber"
	}
	Write-DebugLog "FC ports are stored in $ResultFile" $Info
	return "Success: FC ports information stored in $ResultFile"
} # END FUNCTION Get-FcPortsToCsv

##################################################################
############# FUNCTION Get-ConnectedSession ######################
##################################################################
function Get-ConnectedSession 
{
<#
  .SYNOPSIS
    Command Get-ConnectedSession display connected session detail
	
  .DESCRIPTION
	Command Get-ConnectedSession display connected session detail 
        
  .EXAMPLE
    Get-ConnectedSession
	
  .Notes
    NAME:  Get-ConnectedSession    
    LASTEDIT: January 2020
    KEYWORDS: Get-ConnectedSession 
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>

    Begin{}
    Process
    {       
		return $global:SANConnection		 
    }
    End{}
} # END FUNCTION Get-ConnectedSession

############################################################################################################################################
## FUNCTION New-CLIConnection
############################################################################################################################################
Function New-CLIConnection
{
<#
  .SYNOPSIS
    Builds a SAN Connection object using HPE 3PAR CLI.
  
  .DESCRIPTION
	Creates a SAN Connection object with the specified parameters. 
    No connection is made by this cmdlet call, it merely builds the connection object. 
        
  .EXAMPLE
    New-CLIConnection  -ArrayNameOrIPAddress 10.1.1.1 -CLIDir "C:\cli.exe" -epwdFile "C:\HPE3parepwdlogin.txt"
	Creates a SAN Connection object with the specified Array Name or Array IP Address
	
  .PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
    
  .PARAMETER CLIDir 
    Specify the absolute path of HPE 3PAR cli.exe. Default is "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin"
  
  .PARAMETER epwdFile 
    Specify the encrypted password file location , example “c:\HPE3parstoreserv244.txt” To create encrypted password file use “Set-Password” cmdlet           
	
  .Notes
    NAME:  New-CLIConnection    
    LASTEDIT: January 2020
    KEYWORDS: New-CLIConnection
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #Requires HPE 3PAR cli.exe 
 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
        $ArrayNameOrIPAddress=$null,
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
        #$CLIDir="C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		$CLIDir="C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
        $epwdFile="C:\HPE3parepwdlogin.txt"       
	) 
		#Write-DebugLog "start: Entering function New-CLIConnection. Validating IP Address format." $Debug
		## Check IP Address Format
		#if(-not (Test-IPFormat $ArrayNameOrIPAddress))		
		#{
		#	Write-DebugLog "Stop: Invalid IP Address $ArrayNameOrIPAddress" "ERR:"
		#	return "Failure : Invalid IP Address $ArrayNameOrIPAddress"
		#}				
		#Write-DebugLog "Running: Completed validating IP address format." $Debug	
		
		# -------- Check any active CLI/PoshSSH session exists ------------ starts
		$check = Test-CLIConnection $global:SANConnection
		if($check -eq "Success"){
			$confirm = Read-Host "An active CLI/PoshSSH session exists.`nDo you want to close the current CLI/PoshSSH session and start a new CLI session (Enter y=yes n=no)"
			if ($confirm.tolower() -eq 'y') {
				Close-Connection
			}
			elseif ($confirm.tolower() -eq 'n') {
				return
			}
		}
		# -------- Check any active CLI/PoshSSH session exists ------------ ends
		
		# -------- Check any active WSAPI session exists ------------------ starts
		if($global:WsapiConnection){
			$confirm = Read-Host "An active WSAPI session exists.`nDo you want to close the current WSAPI session and start a new CLI session (Enter y=yes n=no)"
			if ($confirm.tolower() -eq 'y') {
				Close-WSAPIConnection
			}
			elseif ($confirm.tolower() -eq 'n') {
				return
			}
		}
		# -------- Check any active WSAPI session exists ------------------ ends
		
		Write-DebugLog "Running: Authenticating credentials - Invoke-CLI for user $SANUserName and SANIP= $ArrayNameOrIPAddress" $Debug
		$test = $env:Path		
		$test1 = $test.split(";")		
		if ($test1 -eq $CLIDir)
		{
			Write-DebugLog "Running: Environment variable path for $CLIDir already exists" "INFO:"			
		}
		else
		{
			Write-DebugLog "Running: Environment variable path for $CLIDir does not exists, so added $CLIDir to environment" "INFO:"
			$env:Path += ";$CLIDir"
		}
		if (-not (Test-Path -Path $CLIDir )) 
		{		
			Write-DebugLog "Stop: Path for HPE 3PAR cli was not found. Make sure you have installed HPE 3PAR CLI." "ERR:"			
			return "Failure : Path for HPE 3PAR cli was not found. Make sure you have cli.exe file under $CLIDir"
		}
		$clifile = $CLIDir + "\cli.exe"		
		if( -not (Test-Path $clifile))
		{
			Write-DebugLog "Stop: Path for HPE 3PAR cli was not found.Please enter only directory path with out cli.exe & Make sure you have installed HPE 3PAR CLI." "ERR:"			
			return "Failure : Path for HPE 3PAR cli was not found,Make sure you have cli.exe file under $CLIDir"
		}
		#write-host "Set HPE 3PAR CLI path if not"
		# Authenticate		
		try
		{
			if( -not (Test-Path $epwdFile))
			{
				write-host "Encrypted password file does not exist , creating encrypted password file"				
				Set-Password -CLIDir $CLIDir -ArrayNameOrIPAddress $ArrayNameOrIPAddress -epwdFile $epwdFile
				Write-DebugLog "Running: Path for encrypted password file  was not found. Now created new epwd file." "INFO:"
			}
			#write-host "pwd file : $epwdFile"
			Write-DebugLog "Running: Path for encrypted password file  was already exists." "INFO:"
			$global:epwdFile = $epwdFile	
			$Result9 = Invoke-CLI -DeviceIPAddress $ArrayNameOrIPAddress -CLIDir $CLIDir -epwdFile $epwdFile -cmd "showversion" 
			Write-DebugLog "Running: Executed Invoke-CLI. Check on PS console if there are any errors reported" $Debug
			if ($Result9 -match "FAILURE")
			{
				return $Result9
			}
		}
		catch 
		{	
			$msg = "In function New-CLIConnection. "
			$msg+= $_.Exception.ToString()	
			# Write-Exception function is used for exception logging so that it creates a separate exception log file.
			Write-Exception $msg -error		
			return "Failure : $msg"
		}
		
		$global:SANObjArr += @()
		#write-host "objarray",$global:SANObjArr

		if($global:SANConnection)
		{			
			#write-host "In IF loop"
			$SANC = New-Object "_SANConnection"  
			# Get the username
			$connUserName = Get-UserConnectionTemp -ArrayNameOrIPAddress $ArrayNameOrIPAddress -CLIDir $CLIDir -epwdFile $epwdFile -Option current
			$SANC.UserName = $connUserName.Name
			$SANC.IPAddress = $ArrayNameOrIPAddress
			$SANC.CLIDir = $CLIDir	
			$SANC.epwdFile = $epwdFile		
			$SANC.CLIType = "3parcli"
			$SANC.SessionId = "NULL"
			$global:SANConnection = $SANC
			$global:SANObjArr += @($SANC)
			
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
		}
		else
		{		
			$global:SANObjArr = @()
			#write-host "In Else loop"			
			
			$SANC = New-Object "_SANConnection"       
			$connUserName = Get-UserConnectionTemp -ArrayNameOrIPAddress $ArrayNameOrIPAddress -CLIDir $CLIDir -epwdFile $epwdFile -Option current
			$SANC.UserName = $connUserName.Name
			$SANC.IPAddress = $ArrayNameOrIPAddress
			$SANC.CLIDir = $CLIDir
			$SANC.epwdFile = $epwdFile
			$SANC.CLIType = "3parcli"
			$SANC.SessionId = "NULL"
						
			#making this object as global
			$global:SANConnection = $SANC				
			$global:SANObjArr += @($SANC)	

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
		}
		
		Write-DebugLog "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used" $Info
		
		# Set to the prompt as "Array Name:Connection Type (WSAPI|CLI)\>"
		Function global:prompt {
			if ($global:SANConnection -ne $null){				
				$global:ArrayName + ":" + $global:ConnectionType + "\>"
			} else{
				(Get-Location).Path + "\>"
			}
		}
		return $SANC
} # End Function New-CLIConnection

################################################################################
######################### FUNCTION New-PoshSshConnection #######################
################################################################################
Function New-PoshSshConnection
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
              
  .Notes
    NAME:  New-PoshSshConnection    
    LASTEDIT: January 2020
    KEYWORDS: New-PoshSshConnection
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
[CmdletBinding()]
	param(
		
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Enter Array Name or IP Address")]
		[System.String]
        $ArrayNameOrIPAddress=$null,
		
		[Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$SANUserName=$null,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$SANPassword=$null,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$AcceptKey
		)
		
		$Session
		
		# Check if our module loaded properly
		if (Get-Module -ListAvailable -Name Posh-SSH) 
		{ <# do nothing #> }
		else 
		{ 
			try
			{
				# install the module automatically
				[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
				iex (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")
			}
			catch
			{
				#$msg = "Error occurred while installing POSH SSH Module. `nPlease check the internet connection.`nOr Install POSH SSH Module using given Link. `nhttp://www.powershellmagazine.com/2014/07/03/posh-ssh-open-source-ssh-powershell-module/  `n "
				$msg = "Error occurred while installing POSH SSH Module. `nPlease check if internet is enabled. If internet is enabled and you are getting this error,`n Execute Save-Module -Name Posh-SSH -Path <path Ex D:\xxx> `n Then Install-Module -Name Posh-SSH `n If you are getting error like Save-Module is incorrect then `n Check you Power shell Version and Update to 5.1 for this particular Process  `n Or visit https://www.powershellgallery.com/packages/Posh-SSH/2.0.2 `n"
				 
				return "`n Failure : $msg"
			}			
		}	
		
		#####
		#Write-DebugLog "start: Entering function New-PoshSshConnection. Validating IP Address format." $Debug		
		## Check IP Address Format
		#if(-not (Test-IPFormat $ArrayNameOrIPAddress))		
		#{
		#	Write-DebugLog "Stop: Invalid IP Address $ArrayNameOrIPAddress" "ERR:"
		#	return "Failure : Invalid IP Address $ArrayNameOrIPAddress"
		#}
		
		<#
		# -------- Check any active CLI/PoshSSH session exists ------------ starts		
		if($global:SANConnection){
			$confirm = Read-Host "`nAn active CLI/PoshSSH session exists.`nDo you want to close the current CLI/PoshSSH session and start a new PoshSSH session (Enter y=yes n=no)"
			if ($confirm.tolower() -eq 'y'){
				write-host "`nClosing the current CLI/PoshSSH connection."
				Close-Connection
			}
			elseif ($confirm.tolower() -eq 'n'){
				return
			}
		}
		# -------- Check any active CLI/PoshSSH session exists ------------ ends
		
		# -------- Check any active WSAPI session exists ------------------ starts
		if($global:WsapiConnection){
			$confirm = Read-Host "`nAn active WSAPI session exists.`nDo you want to close the current WSAPI session and start a new PoshSSH session (Enter y=yes n=no)"
			if ($confirm.tolower() -eq 'y'){
				write-host "`nClosing the current WSAPI connection."
				Close-WSAPIConnection
			}
			elseif ($confirm.tolower() -eq 'n'){
				return
			}
		}
		# -------- Check any active WSAPI session exists ------------------ ends
		#>
		
		# Authenticate		
		try
		{
			if(!($SANPassword))
			{				
				$securePasswordStr = Read-Host "SANPassword" -AsSecureString				
				$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $securePasswordStr)
			}
			else
			{				
				$tempstring  = convertto-securestring $SANPassword -asplaintext -force				
				$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $tempstring)									
			}
			try
			{
				if($AcceptKey) 
				{
				   #$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential (Get-Credential $SANUserName) -AcceptKey                      
				   $Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds -AcceptKey
			    }
			    else 
				{
				   #$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential (Get-Credential $SANUserName)                          
				    $Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds
			    }
			}
			catch 
			{	
				$msg = "In function New-PoshSshConnection. "
				$msg+= $_.Exception.ToString()	
				# Write-Exception function is used for exception logging so that it creates a separate exception log file.
				Write-Exception $msg -error		
				return "Failure : $msg"
			}
			Write-DebugLog "Running: Executed . Check on PS console if there are any errors reported" $Debug
			if (!$Session)
			{
				return "New-PoshSshConnection command failed to connect the array."
			}
		}
		catch 
		{	
			$msg = "In function New-PoshSshConnection. "
			$msg+= $_.Exception.ToString()	
			# Write-Exception function is used for exception logging so that it creates a separate exception log file.
			Write-Exception $msg -error		
			return "Failure : $msg"
		}					
		
		$global:SANObjArr += @()
		$global:SANObjArr1 += @()
		#write-host "objarray",$global:SANObjArr
		#write-host "objarray1",$global:SANObjArr1
		if($global:SANConnection)
		{			
			#write-host "In IF loop"
			$SANC = New-Object "_SANConnection"
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
		else
		{
			$global:SANObjArr = @()
			$global:SANObjArr1 = @()
			#write-host "In Else loop"
						
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
		Write-DebugLog "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used" $Info		
		
		# Set to the prompt as "Array Name:Connection Type (WSAPI|CLI)\>"
		Function global:prompt {
			if ($global:SANConnection -ne $null){				
				$global:ArrayName + ":" + $global:ConnectionType + "\>"
			} else{
				(Get-Location).Path + "\>"
			}
		}
		return $SANC
 }# End Function New-PoshSshConnection

######################################################################################################################
## FUNCTION Set-PoshSshConnectionPasswordFile
######################################################################################################################
Function Set-PoshSshConnectionPasswordFile
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
	
  .Notes
    NAME:   Set-PoshSshConnectionPasswordFile
	LASTEDIT: January 2020
    KEYWORDS:  Set-PoshSshConnectionPasswordFile
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 2.0
 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
        $ArrayNameOrIPAddress=$null,
		
		[Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$SANUserName=$null,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$SANPassword=$null,
		
		[Parameter(Position=3, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
        $epwdFile=$null,
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$AcceptKey       
	)
	
	## Check IP Address Format
	#if(-not (Test-IPFormat $ArrayNameOrIPAddress))		
	#{
	#	Write-DebugLog "Stop: Invalid IP Address $ArrayNameOrIPAddress" "ERR:"
	#	return "FAILURE : Invalid IP Address $ArrayNameOrIPAddress"
	#}		
	
	#Write-DebugLog "Running: Completed validating IP address format." $Debug		
	Write-DebugLog "Running: Authenticating credentials - for user $SANUserName and SANIP= $ArrayNameOrIPAddress" $Debug
	
	# Authenticate
	try
	{
		if(!($SANPassword))
		{				
			$securePasswordStr = Read-Host "SANPassword" -AsSecureString				
			$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $securePasswordStr)
			
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePasswordStr)
			$tempPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		}
		else
		{				
			$tempstring  = convertto-securestring $SANPassword -asplaintext -force				
			$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $tempstring)	

			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tempstring)
			$tempPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		}			
		
		if($AcceptKey) 
		{
			#$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential (Get-Credential $SANUserName) -AcceptKey                           
			$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds -AcceptKey
		}
		else 
		{
			#$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential (Get-Credential $SANUserName)                        
			$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds
		}
		
		Write-DebugLog "Running: Executed . Check on PS console if there are any errors reported" $Debug
		if (!$Session)
		{
			return "FAILURE : In function Set-PoshSshConnectionPasswordFile."
		}
		else
		{
			$RemveResult = Remove-SSHSession -Index $Session.SessionId
		}
		
		$Enc_Pass = Protect-String $tempPwd 
		$Enc_Pass,$ArrayNameOrIPAddress,$SANUserName | Export-CliXml $epwdFile	
	}
	catch 
	{	
		$msg = "In function Set-PoshSshConnectionPasswordFile. "
		$msg+= $_.Exception.ToString()	
		
		Write-Exception $msg -error		
		return "FAILURE : $msg `n credentials incorrect"
	}

	Write-DebugLog "Running: encrypted password file has been created successfully and the file location is $epwdFile " "INFO:"
	return "`n Success : encrypted SANPassword file has been created successfully and the file location : $epwdFile"	

} #  End-of  Set-PoshSshConnectionPasswordFile
 
#####################################################################################
#   Function   Set-PoshSshConnectionUsingPasswordFile
#####################################################################################
Function Set-PoshSshConnectionUsingPasswordFile
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
	
  .Notes
    NAME:  Set-PoshSshConnectionUsingPasswordFile
	LASTEDIT: January 2020
    KEYWORDS: Set-PoshSshConnectionUsingPasswordFile
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #Requires HPE 3PAR cli.exe 
 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
        $ArrayNameOrIPAddress=$null,
		[Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
        $SANUserName,
		[Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
        $epwdFile        
	) 
					
	try{			
		if( -not (Test-Path $epwdFile))
		{
			Write-DebugLog "Running: Path for encrypted password file  was not found. Now created new epwd file." "INFO:"
			return " Encrypted password file does not exist , create encrypted password file using 'Set-3parSSHConnectionPasswordFile' "
		}	
		
		Write-DebugLog "Running: Patch for encrypted password file ." "INFO:"
		
		$tempFile=$epwdFile			
		$Temp=import-CliXml $tempFile
		$pass=$temp[0]
		$ip=$temp[1]
		$user=$temp[2]
		if($ip -eq $ArrayNameOrIPAddress)  
		{
			if($user -eq $SANUserName)
			{
				$Passs = UnProtect-String $pass 
				#New-SSHConnection -SANUserName $SANUserName  -SANPassword $Passs -ArrayNameOrIPAddress $ArrayNameOrIPAddress -SSHDir "C:\plink"
				New-PoshSshConnection -ArrayNameOrIPAddress $ArrayNameOrIPAddress -SANUserName $SANUserName -SANPassword $Passs

			}
			else
			{ 
				Return "Password file SANUserName $user and entered SANUserName $SANUserName dose not match  . "
				Write-DebugLog "Running: Password file SANUserName $user and entered SANUserName $SANUserName dose not match ." "INFO:"
			}
		}
		else 
		{
			Return  "Password file ip $ip and entered ip $ArrayNameOrIPAddress dose not match"
			Write-DebugLog "Password file ip $ip and entered ip $ArrayNameOrIPAddress dose not match." "INFO:"
		}
	}
	catch 
	{	
		$msg = "In function Set-PoshSshConnectionUsingPasswordFile. "
		$msg+= $_.Exception.ToString()	
		# Write-Exception function is used for exception logging so that it creates a separate exception log file.
		Write-Exception $msg -error		
		return "FAILURE : $msg"
	}
} #End Function Set-PoshSshConnectionUsingPasswordFile

######################################################################################################################
## FUNCTION Get-UserConnectionTemp
######################################################################################################################
Function Get-UserConnectionTemp
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
		[Parameter(Position=0,Mandatory=$false, ValueFromPipeline=$true)]
		[System.string]
		$CLIDir="C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter(Position=1,Mandatory=$true, ValueFromPipeline=$true)]
		[System.string]
		$ArrayNameOrIPAddress=$null,
		[Parameter(Position=2,Mandatory=$true, ValueFromPipeline=$true)]
		[System.string]
		$epwdFile ="C:\HPE3parepwdlogin.txt",
		[Parameter(Position=3,Mandatory=$false, ValueFromPipeline=$true)]
		[System.string]
		$Option
	)
	if( Test-Path $epwdFile)
	{
		Write-DebugLog "Running: password file was found , it will use the mentioned file" "INFO:"
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

############################################################################################################################################
## FUNCTION Test-CLIObject
############################################################################################################################################
Function Test-CLIObject 
{
Param( 	
    [string]$ObjectType, 
	[string]$ObjectName ,
	[string]$ObjectMsg = $ObjectType, 
	$SANConnection = $global:SANConnection
	)

	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")
	{
		$IsObjectExisted = $false
	}
	return $IsObjectExisted
	
} # End FUNCTION Test-CLIObject

 
Export-ModuleMember Close-Connection , Get-CmdList , Get-FcPorts , Get-FcPortsToCsv , Get-ConnectedSession , New-CLIConnection , New-PoshSshConnection ,
Set-PoshSshConnectionPasswordFile , Set-PoshSshConnectionUsingPasswordFile
# SIG # Begin signature block
# MIIh0AYJKoZIhvcNAQcCoIIhwTCCIb0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCDcDtbtYcyfVNG
# ixiR0MJDDrd8VAbbVRDq1Dr6ZkXcZ6CCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# qQOCRp2FbX2dyWfFHoaenIevp5gyGw5GJn74zDiv9sowDQYJKoZIhvcNAQEBBQAE
# ggEAMyYH5+s1eTVlv4/Ng+rlrFeNXkR/qGqpVDMtoHXMhi85dWwADA9UBP1nqhhx
# WdAYoxp+IzVxp8IiBtg3SKzvBpZU4IVIIGy2Od99K8RFr7eqBjlILeocS58EUwFb
# nKlIQAkt7jLv9ZpyIocu9j38WpSdms9eHHw10O2fZz6osXQEqnkAqFufCCwEBZNo
# 13/ueoO8DhUD2MKMVLxpcrLDMTNgEnby+EtFBQaYh96uxWlUOKX1cSoMV8eDahxP
# 0RXY18erYoMIQgDT0LKCPJEuY9bRm1M8kPhxUUo3vyPYFliuVaNY2CaU8TBFnkZs
# kB1xwwPHIUvX83jvbou2/vL11qGCDj0wgg45BgorBgEEAYI3AwMBMYIOKTCCDiUG
# CSqGSIb3DQEHAqCCDhYwgg4SAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDwYLKoZIhvcN
# AQkQAQSggf8EgfwwgfkCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# IK0F9WNEyXBo9jASz2vcdomkVA7EgiTifrqmFu8xDM5aAhUAhm7JXVTfRgHfNt8u
# SYxttl++o+0YDzIwMjEwNjE5MDQxMjQyWjADAgEeoIGGpIGDMIGAMQswCQYDVQQG
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
# hkiG9w0BCQUxDxcNMjEwNjE5MDQxMjQyWjAvBgkqhkiG9w0BCQQxIgQgn1nCXi8x
# S3t8UUG3g07/UEN4SgWR7rHva2mSFrI0vZEwNwYLKoZIhvcNAQkQAi8xKDAmMCQw
# IgQgxHTOdgB9AjlODaXk3nwUxoD54oIBPP72U+9dtx/fYfgwCwYJKoZIhvcNAQEB
# BIIBAAVIAKdxPnbWNziq0tQ93CTlfxq2Yv1/fRsB1Pd0SEdvOiY8o47i6IQG3FrE
# y712LDSxn5bHg/0Qgmg9O8zPiHRRa7QIpyBi37S9fGb4446GHlG/znpdhnLB5YN8
# 8UaB24ZhmsQhG5cjwVNCdkvAbC45myGVyALvH3xToudET9VR+64BPt+b/6EUHKZ4
# G0UL7PCf6WlehSYGz+smhxiKlbtv5FLpRfnsGnhgPSrVBnAPWF+fisGMfZNtddsb
# ZWYHCht3YNkT1lGJDLrRaTmlcDkI8ML2WnWPh0+uoMdS7C8FqZWPsv4D3hnytdxp
# 09t9mj24Xr1oho6W9oGJTK7xUvA=
# SIG # End signature block
