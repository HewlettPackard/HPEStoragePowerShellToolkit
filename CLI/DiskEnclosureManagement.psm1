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
##	File Name:		DiskEnclosureManagement.psm1
##	Description: 	Disk Enclosure Management cmdlets 
##		
##	Created:		October 2019
##	Last Modified:	October 2019
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

####################################################################################################################
## FUNCTION Set-AdmitsPD
####################################################################################################################
Function Set-AdmitsPD
{
<#
  .SYNOPSIS
    The Set-AdmitsPD command creates and admits physical disk definitions to enable the use of those disks.
	
  .DESCRIPTION
    The Set-AdmitsPD command creates and admits physical disk definitions to enable the use of those disks.
	
  .EXAMPLE
   Set-AdmitsPD 
   This example admits physical disks.
   
  .EXAMPLE
   Set-AdmitsPD -Nold
   Do not use the PD (as identified by the <world_wide_name> specifier) For logical disk allocation.
   
  .EXAMPLE
   Set-AdmitsPD -NoPatch
   Suppresses the check for drive table update packages for new hardware enablement.

  .EXAMPLE  	
	Set-AdmitsPD -Nold -wwn xyz
	Do not use the PD (as identified by the <world_wide_name> specifier) For logical disk allocation.
		
  .PARAMETER Nold
	Do not use the PD (as identified by the <world_wide_name> specifier)
	for logical disk allocation.

  .PARAMETER Nopatch
	Suppresses the check for drive table update packages for new
	hardware enablement.

  .PARAMETER wwn
	Indicates the World-Wide Name (WWN) of the physical disk to be admitted. If WWNs are
	specified, only the specified physical disk(s) are admitted.	
	 
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Set-AdmitsPD
    LASTEDIT: 25/10/2019
    KEYWORDS: Set-AdmitsPD
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[switch]
		$Nold,
		
		[Parameter(Position=1, Mandatory=$false)]
		[switch]
		$NoPatch,
				
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$wwn,		
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)	
	
	Write-DebugLog "Start: In Set-AdmitsPD   - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Set-AdmitsPD since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Set-AdmitsPD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}		
	$cmd= "admitpd -f  "
	
	
	if ($Nold)
	{	
		$cmd+=" -nold "		
	}	
	if ($NoPatch)
	{	
		$cmd+=" -nopatch "		
	}
	if($wwn)
	{
		$cmd += " $wwn"		
	}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog " The Set-AdmitsPD command creates and admits physical disk definitions to enable the use of those disks  " "INFO:" 
	return 	$Result	
} # End Set-AdmitsPD

####################################################################################################################
## FUNCTION Find-Cage
####################################################################################################################
Function Find-Cage
{
<#
  .SYNOPSIS
   The Find-Cage command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs.
 
 .DESCRIPTION
   The Find-Cage command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs. 
	
  .EXAMPLE
	Find-Cage -Time 30 -CageName cage0	
	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds.
   
  .EXAMPLE  
	Find-Cage -Time 30 -CageName cage0 -mag 3	
	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds,Indicates the drive magazine by number 3.
   
  .EXAMPLE  
	Find-Cage -Time 30 -CageName cage0 -PortName demo1	
	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds, If a port is specified, the port LED will oscillate between green and off.
	
  .EXAMPLE  	
	Find-Cage -CageName cage1 -Mag 2	
	This example causes the Fibre Channel LEDs on the drive CageName cage1 to blink, Indicates the drive magazine by number 2.	
		
  .PARAMETER Time 
	Specifies the number of seconds, from 0 through 255 seconds, to blink the LED. 
	If the argument is not specified, the option defaults to 60 seconds.
  
  .PARAMETER CageName 
	Specifies the drive cage name as shown in the Name column of Get-Cage command output.
	
  .PARAMETER ModuleName
	Indicates the module name to locate. Accepted values are
	pcm|iom|drive. The iom specifier is not supported for node enclosures.

  .PARAMETER ModuleNumber
	Indicates the module number to locate. The cage and module number can be found
	by issuing showcage -d <cage_name>.
	
  .PARAMETER Mag 
	Indicates the drive magazine by number.
	• For DC1 drive cages, accepted values are 0 through 4.
	• For DC2 and DC4 drive cages, accepted values are 0 through 9.
	• For DC3 drive cages, accepted values are 0 through 15.
		
  .PARAMETER PortName  
	Indicates the port specifiers. Accepted values are A0|B0|A1|B1|A2|B2|A3|B3. 
	If a port is specified, the port LED will oscillate between green and off.
    
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
	NAME:  Find-Cage
    LASTEDIT: 25/10/2019
    KEYWORDS: Find-Cage
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$Time,
		
		[Parameter(Position=1, Mandatory=$true,ValueFromPipeline=$true)]
		[System.String]
		$CageName,
		
		[Parameter(Position=2, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$ModuleName,
		
		[Parameter(Position=3, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$ModuleNumber,
		
		[Parameter(Position=4, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$Mag,
		
		[Parameter(Position=5, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$PortName,
				
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Find-Cage   - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{			
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Find-Cage since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Find-Cage since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	$cmd= "locatecage "	
	
	if ($time)
	{
		$s = 0..255
		$demo = $time
		if($s -match $demo)
		{
			$str="time"
			$cmd+=" -t $time"
		}
		else
		{
			return " Error : -time $time is Not valid use seconds, from 0 through 255 Only "
		}
	}
	if ($CageName)
	{
		$cmd2="showcage "
		$Result2 = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd2
		if($Result2 -match $CageName)
		{
			$cmd+=" $CageName"
		}
		else
		{
		Write-DebugLog "Stop: Exiting Find-Cage $CageName Not available "
		return "FAILURE : -CageName $CageName  is Unavailable `n Try using [Get-Cage] Command "
		}
	}
	else
	{
		Write-DebugLog "Stop: CageName is mandatory" $Debug
		return "Error :  -CageName is mandatory. "
	}
	if ($ModuleName)
	{		
		$cmd+=" $ModuleName"		
	}	
	if ($ModuleNumber)
	{		
		$cmd+=" $ModuleNumber"		
	}
	if ($Mag)
	{
		$a = 0..15
		$demo = $Mag
		if($a -match $demo)
		{
		$str="mag"
		$cmd +=" $Mag"
		}
		else
		{
			return "Error : -Mag $Mag is Not valid use seconds,from 0 through 15 Only"		
		}
	}	
	if ($PortName)
	{
		$s=$str
		if ($s -match "mag" )
		{
			return "FAILURE : -Mag $Mag cannot be used along with  -PortName $PortName "
		}
		else
		{	
			$a = $PortName
			$b = "A0","B0","A1","B1","A2","B2","A3","B3"
			if($b -eq $a)
			{
				$cmd +=" $PortName"
			}
			else
			{
				return "Error : -PortName $PortName is invalid use [ A0| B0 | A1 | B1 | A2 | B2 | A3 | B3 ] only  "
			}
		}	
	}	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd	
	write-debuglog "  Executing Find-Cage Command , surface scans or diagnostics on physical disks with the command   " "INFO:" 	
	if([string]::IsNullOrEmpty($Result))
	{
		return  "Success : Find-Cage Command Executed Successfully $Result"
	}
	else
	{
		return  "FAILURE : While Executing Find-Cage `n $Result"
	} 		
}
# End Find-Cage

###################################################################################################################
############################################ FUNCTION Get-Cage ################################################
###################################################################################################################

Function Get-Cage
{
<#
  .SYNOPSIS
   The Get-Cage command displays information about drive cages.
   
  .DESCRIPTION
   The Get-Cage command displays information about drive cages.    
	
  .EXAMPLE
	Get-Cage
	This examples display information for a single system’s drive cages.
   
  .EXAMPLE  
	Get-Cage -D -CageName cage2
	Specifies that more detailed information about the drive cage is displayed
	
  .EXAMPLE  
	Get-Cage -I -CageName cage2
	Specifies that inventory information about the drive cage is displayed. 
   		 
  .PARAMETER D
	Specifies that more detailed information about the drive cage is displayed. If this option is not
	used, then only summary information about the drive cages is displayed. 
		
  .PARAMETER E  
	Displays error information.
	
  .PARAMETER C  
	Specifies to use cached information. This option displays information faster because the cage does
	not need to be probed, however, some information might not be up-to-date without that probe.

  .PARAMETER SFP  
	Specifies information about the SFP(s) attached to a cage. Currently, additional SFP information
	can only be displayed for DC2 and DC4 cages.
			
  .PARAMETER I	
	Specifies that inventory information about the drive cage is displayed. If this option is not used,
	then only summary information about the drive cages is displayed.

  .PARAMETER DDm
	Specifies the SFP DDM information. This option can only be used with the
	-sfp option and cannot be used with the -d option.

	
  .PARAMETER SVC
  Displays inventory information with HPE serial number, spare part number, and so on. it is supported only on HPE 3PAR Storage 7000 Storagesystems and  HPE 3PAR 8000 series systems"
  
  .PARAMETER CageName  
	Specifies a drive cage name for which information is displayed. This specifier can be repeated to display information for multiple cages
      
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME: Get-Cage
    LASTEDIT: 25/10/2019
    KEYWORDS: Get-Cage
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[Switch]
		$D,
		
		[Parameter(Position=1, Mandatory=$false)]
		[Switch]
		$E,
		
		[Parameter(Position=2, Mandatory=$false)]
		[Switch]
		$C,
		
		[Parameter(Position=3, Mandatory=$false)]
		[Switch]
		$SFP,
		
		[Parameter(Position=4, Mandatory=$false)]
		[Switch]
		$DDM,
		
		[Parameter(Position=5, Mandatory=$false)]
		[Switch]
		$I,
		
		[Parameter(Position=6, Mandatory=$false)]
		[Switch]
		$SVC,
		
		[Parameter(Position=7, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$CageName,
			
		[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)		
	Write-DebugLog "Start: In Get-Cage   - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{			
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Get-Cage since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Get-Cage since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}	
	$cmd= "showcage "
	$testCmd= "showcage "
	
	if($D)
	{ 
		$cmd +=" -d " 
	}
	if($E) 
	{ 
		$cmd +=" -e "
	}
	if($C) 
	{ 
		$cmd +=" -c "
	}
	if($SFP) 
	{ 
		$cmd +=" -sfp " 
	}
	if($DDM) 
	{ 
		$cmd +=" -ddm " 
	}
	if($I) 
	{ 
		$cmd +=" -i " 
	}
	if($SVC) 
	{ 
		$cmd +=" -svc -i" 
	}
	if ($CageName) 
	{ 
		$cmd+=" $CageName "
		$testCmd+=" $CageName "
	}
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog "  Executing  Get-Cage command that displays information about drive cages. with the command   " "INFO:" 
	
	if($cmd -eq "showcage " -or ($cmd -eq $testCmd))
	{
		if($Result.Count -gt 1)
		{	
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count 
			#Write-Host " Result Count =" $Result.Count
			foreach ($s in  $Result[0..$LastItem] )
			{		
				$s= [regex]::Replace($s,"^ ","")			
				$s= [regex]::Replace($s," +",",")	
				#$s= [regex]::Replace($s,"-","")
				$s= $s.Trim() 	
				Add-Content -Path $tempFile -Value $s
				#Write-Host	" First if statement $s"		
			}
			Import-Csv $tempFile 
			del $tempFile
			Return  " Success : Executing Get-Cage"
		}
		else
		{
			Return  " FAILURE : While Executing Get-Cage `n $Result"		
		}		
	}
	
	if($Result -match "Cage" )
	{
		$result	
		Return  " Success : Executing Get-Cage"
	} 
	else
	{
		Return  " FAILURE : While Executing Get-Cage `n $Result"
	} 
 } # End Get-Cage
 
 ####################################################################################################################
## FUNCTION Show-PD
####################################################################################################################
Function Show-PD
{
<#
  .SYNOPSIS
	The Show-PD command displays configuration information about the physical disks (PDs) on a system. 

  .DESCRIPTION
	The Show-PD command displays configuration information about the physical disks (PDs) on a system. 
   
  .EXAMPLE  
	Show-PD
	This example displays configuration information about all the physical disks (PDs) on a system. 
	
  .EXAMPLE  
	Show-PD -PD_ID 5
	This example displays configuration information about specific or given physical disks (PDs) on a system. 
	
  .EXAMPLE  
	Show-PD -C 
	This example displays chunklet use information for all disks. 
	
  .EXAMPLE  
	Show-PD -C -PD_ID 5
	This example will display chunklet use information for all disks with the physical disk ID. 

  .EXAMPLE  
	Show-PD -Node 0 -PD_ID 5
	
  .EXAMPLE  
	Show-PD -I -Pattern -ND 1 -PD_ID 5

  .EXAMPLE
	Show-PD -C -Pattern -Devtype FC  	

  .EXAMPLE  
	Show-PD -option p -pattern mg -patternValue 0
	TThis example will display all the FC disks in magazine 0 of all cages.
 
  .PARAMETER Listcols
	List the columns available to be shown in the -showcols option
	described below (see 'clihelp -col showpd' for help on each column).

  .PARAMETER I
	Show disk inventory (inquiry) data.

	The following columns are shown:
	Id CagePos State Node_WWN MFR Model Serial FW_Rev Protocol MediaType AdmissionTime.

  .PARAMETER E
	Show disk environment and error information. Note that reading this
	information places a significant load on each disk.

	The following columns are shown:
	Id CagePos Type State Rd_CErr Rd_UErr Wr_CErr Wr_UErr Temp_DegC
	LifeLeft_PCT.

  .PARAMETER C
	Show chunklet usage information. Any chunklet in a failed disk will be
	shown as "Fail".

	The following columns are shown:
	Id CagePos Type State Total_Chunk Nrm_Used_OK Nrm_Used_Fail
	Nrm_Unused_Free Nrm_Unused_Uninit Nrm_Unused_Unavail Nrm_Unused_Fail
	Spr_Used_OK Spr_Used_Fail Spr_Unused_Free Spr_Unused_Uninit Spr_Unused_Fail.

  .PARAMETER S
	Show detailed state information.
	This option is deprecated and will be removed in a subsequent release.

  .PARAMETER State
	Show detailed state information. This is the same as -s.

	The following columns are shown:
	Id CagePos Type State Detailed_State SedState.

  .PARAMETER Path
	Show current and saved path information for disks.

	The following columns are shown:
	Id CagePos Type State Path_A0 Path_A1 Path_B0 Path_B1 Order.

  .PARAMETER Space
	Show disk capacity usage information (in MB).

	The following columns are shown:
	Id CagePos Type State Size_MB Volume_MB Spare_MB Free_MB Unavail_MB
	Failed_MB.

  .PARAMETER Failed
	Specifies that only failed physical disks are displayed.

  .PARAMETER Degraded
	Specifies that only degraded physical disks are displayed. If both
	-failed and -degraded are specified, the command shows failed disks and
	degraded disks.

  .PARAMETER Pattern
	Physical disks matching the specified pattern are displayed.

  .PARAMETER ND
	Specifies one or more nodes. Nodes are identified by one or more
	integers (item). Multiple nodes are separated with a single comma
	(e.g. 1,2,3). A range of nodes is separated with a hyphen (e.g. 0-
	7). The primary path of the disks must be on the specified node(s).
			
  .PARAMETER ST
	Specifies one or more PCI slots. Slots are identified by one or more
	integers (item). Multiple slots are separated with a single comma
	(e.g. 1,2,3). A range of slots is separated with a hyphen (e.g. 0-
	7). The primary path of the disks must be on the specified PCI
	slot(s).
			
  .PARAMETER PT
	Specifies one or more ports. Ports are identified by one or more
	integers (item). Multiple ports are separated with a single comma
	(e.g. 1,2,3). A range of ports is separated with a hyphen (e.g. 0-
	4). The primary path of the disks must be on the specified port(s).
			
  .PARAMETER CG
	Specifies one or more drive cages. Drive cages are identified by one
	or more integers (item). Multiple drive cages are separated with a
	single comma (e.g. 1,2,3). A range of drive cages is separated with
	a hyphen (e.g. 0-3). The specified drive cage(s) must contain disks.
	
  .PARAMETER MG
	Specifies one or more drive magazines. The "1." or "0." displayed
	in the CagePos column of showpd output indicating the side of the
	cage is omitted when using the -mg option. Drive magazines are
	identified by one or more integers (item). Multiple drive magazines
	are separated with a single comma (e.g. 1,2,3). A range of drive
	magazines is separated with a hyphen(e.g. 0-7). The specified drive
	magazine(s) must contain disks.
			
  .PARAMETER PN
	Specifies one or more disk positions within a drive magazine. Disk
	positions are identified by one or more integers (item). Multiple
	disk positions are separated with a single comma(e.g. 1,2,3). A
	range of disk positions is separated with a hyphen(e.g. 0-3). The
	specified position(s) must contain disks.
			
  .PARAMETER DK
	Specifies one or more physical disks. Disks are identified by one or
	more integers(item). Multiple disks are separated with a single
	comma (e.g. 1,2,3). A range of disks is separated with a hyphen(e.g.
	0-3).  Disks must match the specified ID(s).
			
  .PARAMETER Devtype
	Specifies that physical disks must have the specified device type
	(FC for Fast Class, NL for Nearline, SSD for Solid State Drive)
	to be used. Device types can be displayed by issuing the "showpd"
	command.
			
  .PARAMETER RPM
	Drives must be of the specified relative performance metric, as
	shown in the "RPM" column of the "showpd" command.
	The number does not represent a rotational speed for the drives
	without spinning media (SSD). It is meant as a rough estimation of
	the performance difference between the drive and the other drives
	in the system.  For FC and NL drives, the number corresponds to
	both a performance measure and actual rotational speed. For SSD
	drives, the number is to be treated as a relative performance
	benchmark that takes into account I/O's per second, bandwidth and
	access time.

  .PARAMETER Node
	Specifies that the display is limited to specified nodes and physical
	disks connected to those nodes. The node list is specified as a series
	of integers separated by commas (e.g. 1,2,3). The list can also consist
	of a single integer. If the node list is not specified, all disks on all
	nodes are displayed.

  .PARAMETER Slots
	Specifies that the display is limited to specified PCI slots and
	physical disks connected to those PCI slots. The slot list is specified
	as a series of integers separated by commas (e.g. 1,2,3). The list can
	also consist of a single integer. If the slot list is not specified, all
	disks on all slots are displayed.

  .PARAMETER Ports
	Specifies that the display is limited to specified ports and
	physical disks connected to those ports. The port list is specified
	as a series of integers separated by commas (e.g. 1,2,3). The list can
	also consist of a single integer. If the port list is not specified, all
	disks on all ports are displayed.

  .PARAMETER WWN
	Specifies the WWN of the physical disk. This option and argument can be
	specified if the <PD_ID> specifier is not used. This option should be
	the last option in the command line.

 
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME: Show-PD
    LASTEDIT: 30/10/2019
    KEYWORDS: Show-PD
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[switch]
		$I,
		
		[Parameter(Position=1, Mandatory=$false)]
		[switch]
		$E,
		
		[Parameter(Position=2, Mandatory=$false)]
		[switch]
		$C,
		
		[Parameter(Position=3, Mandatory=$false)]
		[switch]
		$StateInfo,
		
		[Parameter(Position=4, Mandatory=$false)]
		[switch]
		$State,
		
		[Parameter(Position=5, Mandatory=$false)]
		[switch]
		$Path,
		
		[Parameter(Position=6, Mandatory=$false)]
		[switch]
		$Space,
		
		[Parameter(Position=7, Mandatory=$false)]
		[switch]
		$Failed,
		
		[Parameter(Position=8, Mandatory=$false)]
		[switch]
		$Degraded,
		
		[Parameter(Position=9, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$Node ,
		
		[Parameter(Position=10, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$Slots ,
		
		[Parameter(Position=11, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$Ports ,
		
		[Parameter(Position=12, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$WWN ,
		
		[Parameter(Position=13, Mandatory=$false)]
		[switch]
		$Pattern,
		
		[Parameter(Position=14, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$ND ,
		
		[Parameter(Position=15, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$ST ,
		
		[Parameter(Position=16, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$PT ,
		
		[Parameter(Position=17, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$CG ,
		
		[Parameter(Position=18, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$MG ,
		
		[Parameter(Position=19, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$PN ,
		
		[Parameter(Position=20, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$DK ,
		
		[Parameter(Position=21, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$Devtype ,
		
		[Parameter(Position=22, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$RPM ,
		
		[Parameter(Position=23, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$PD_ID ,

		[Parameter(Position=23, Mandatory=$false,ValueFromPipeline=$true)]
		[switch]
		$Listcols ,
			
		[Parameter(Position=24, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	Write-DebugLog "Start: In Show-PD   - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Show-PD since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Show-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	$cmd= "showpd "	
	
	if($Listcols)
	{
		$cmd+=" -listcols "
		$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
		return $Result
	}
	if($I)
	{
		$cmd+=" -i "		
	}
	if($E)
	{
		$cmd+=" -e "		
	}
	if($C)
	{
		$cmd+=" -c "		
	}
	if($StateInfo)
	{
		$cmd+=" -s "		
	}
	if($State)
	{
		$cmd+=" -state "		
	}
	if($Path)
	{
		$cmd+=" -path "		
	}
	if($Space)
	{
		$cmd+=" -space "		
	}
	if($Failed)
	{
		$cmd+=" -failed "		
	}
	if($Degraded)
	{
		$cmd+=" -degraded "		
	}
	if($Node)
	{
		$cmd+=" -nodes $Node "		
	}
	if($Slots)
	{
		$cmd+=" -slots $Slots "		
	}
	if($Ports)
	{
		$cmd+=" -ports $Ports "		
	}
	if($WWN)
	{
		$cmd+=" -w $WWN "		
	}
	if($Pattern)
	{
		if($ND)
		{
			$cmd+=" -p -nd $ND "
		}
		if($ST)
		{
			$cmd+=" -p -st $ST "
		}
		if($PT)
		{
			$cmd+=" -p -pt $PT "
		}
		if($CG)
		{
			$cmd+=" -p -cg $CG "
		}
		if($MG)
		{
			$cmd+=" -p -mg $MG "
		}
		if($PN)
		{
			$cmd+=" -p -pn $PN "
		}
		if($DK)
		{
			$cmd+=" -p -dk $DK "
		}
		if($Devtype)
		{
			$cmd+=" -p -devtype $Devtype "
		}
		if($RPM)
		{
			$cmd+=" -p -rpm $RPM "
		}
	}		
	if ($PD_ID)
	{		
		$PD=$PD_ID		
		$pdd="showpd $PD"
		$Result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $pdd	
		if($Result1 -match "No PDs listed" )
		{
			Write-DebugLog "Stop: Exiting Show-PD  since  -PD_ID $PD_ID is not available "
			return " FAILURE : $PD_ID is not available id pLease try using only [Show-PD] to get the list of PD_ID Available. "			
		}
		else 	
		{
			$cmd+=" $PD_ID "
		}
	}
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	if($Result -match "Invalid device type")
	{
		write-host""
		return $Result
	}
	if($Result.Count -lt 2)
	{	
		write-host""
		return $Result
	}
	#write-debuglog "  Executing  Get-Cage command that displays information about drive cages. with the command  " "INFO:" 
	
	#this is for option i
	if($I -Or $State -Or $StateInfo)
	{
		$flag = "True"
		$tempFile = [IO.Path]::GetTempFileName()
		$LastItem = $Result.Count -3  
		#Write-Host " Result Count =" $Result.Count
		foreach ($s in  $Result[0..$LastItem] )
		{		
			$s= [regex]::Replace($s,"^ ","")			
			$s= [regex]::Replace($s," +",",")	
			$s= [regex]::Replace($s,"-","")
			$s= $s.Trim()
			if($I)
			{
				if($flag -eq "True")
				{
					$sTemp1=$s
					$sTemp = $sTemp1.Split(',')
					$sTemp[10]="AdmissionDate,AdmissionTime,AdmissionZone" 				
					$newTemp= [regex]::Replace($sTemp," ",",")	
					$newTemp= $newTemp.Trim()
					$s=$newTemp
				}	
			}			
			Add-Content -Path $tempFile -Value $s
			$flag="false"		
		}				
		Import-Csv $tempFile 
		del $tempFile
	}
	ElseIf($C)
	{			
		$tempFile = [IO.Path]::GetTempFileName()
		$LastItem = $Result.Count -3  
		$incre = "true"			
		foreach ($s in  $Result[2..$LastItem] )
		{	
			$s= [regex]::Replace($s,"^ ","")			
			$s= [regex]::Replace($s," +",",")
			$s= [regex]::Replace($s,"-","")
			$s= $s.Trim()				
			if($incre -eq "true")
			{
				$sTemp1=$s
				$sTemp = $sTemp1.Split(',')
				$sTemp[5]="OK(NormalChunklets)" 
				$sTemp[6]="Fail(NormalChunklets/Used)" 
				$sTemp[7]="Free(NormalChunklets)"
				$sTemp[8]="Uninit(NormalChunklets)"
				$sTemp[10]="Fail(NormalChunklets/UnUsed)"
				$sTemp[11]="OK(SpareChunklets)" 
				$sTemp[12]="Fail(SpareChunklets/Used)" 
				$sTemp[13]="Free(SpareChunklets)"
				$sTemp[14]="Uninit(SpareChunklets)"
				$sTemp[15]="Fail(SpareChunklets/UnUsed)"
				$newTemp= [regex]::Replace($sTemp," ",",")	
				$newTemp= $newTemp.Trim()
				$s=$newTemp
			}				
			Add-Content -Path $tempFile -Value $s
			#Write-Host	"$s"
			$incre="false"				
		}			
		Import-Csv $tempFile 
		del $tempFile
	}
	ElseIf($E)
	{			
		$tempFile = [IO.Path]::GetTempFileName()
		$LastItem = $Result.Count -3  
		$incre = "true"			
		foreach ($s in  $Result[1..$LastItem] )
		{	
			$s= [regex]::Replace($s,"^ ","")			
			$s= [regex]::Replace($s," +",",")
			$s= [regex]::Replace($s,"-","")
			$s= $s.Trim()				
			if($incre -eq "true")
			{
				$sTemp1=$s
				$sTemp = $sTemp1.Split(',')
				$sTemp[4]="Corr(ReadError)" 
				$sTemp[5]="UnCorr(ReadError)" 
				$sTemp[6]="Corr(WriteError)"
				$sTemp[7]="UnCorr(WriteError)"
				$newTemp= [regex]::Replace($sTemp," ",",")	
				$newTemp= $newTemp.Trim()
				$s=$newTemp
			}				
			Add-Content -Path $tempFile -Value $s
			#Write-Host	"$s"
			$incre="false"				
		}
			
		Import-Csv $tempFile 
		del $tempFile
	}
	else
	{
		if($Result -match "Id")
		{
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -3  
			#Write-Host " Result Count =" $Result.Count
			foreach ($s in  $Result[1..$LastItem] )
			{		
				$s= [regex]::Replace($s,"^ ","")			
				$s= [regex]::Replace($s," +",",")
				$s= [regex]::Replace($s,"-","")
				$s= $s.Trim() 	
				Add-Content -Path $tempFile -Value $s
				#Write-Host	" only else statement"		
			}
			write-host ""
			if($Space)
			{
				write-host "Size | Volume | Spare | Free | Unavail & Failed values are in (MiB)."
			}
			else
			{
				write-host "Total and Free values are in (MiB)."
			}				
			Import-Csv $tempFile 
			del $tempFile
		}
	}		
	if($Result.Count -gt 1)
	{	
		return "Success : Command Show-PD execute Successfully."
	}
	else
	{
		return $Result		
	} 	
} # End Show-PD

##########################################################################
############################ FUNCTION Remove-PD ##########################
##########################################################################
Function Remove-PD()
{
<#
  .SYNOPSIS
   Remove-PD - Remove a physical disk (PD) from system use.

  .DESCRIPTION
   The Remove-PD command removes PD definitions from system use.

  .EXAMPLE
	The following example removes a PD with ID 1:
	Remove-PD -PDID 1
   
  .PARAMETER PDID
	Specifies the PD(s), identified by integers, to be removed from system use.

  .Notes
    NAME: Remove-PD
    LASTEDIT 30/10/2019
    KEYWORDS: Remove-PD
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$True)]
	[System.String]
	$PDID,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Remove-PD - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Remove-PD since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Remove-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

	$Cmd = " dismisspd "

 if($PDID)
 {
	$Cmd += " $PDID "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : Remove-PD command -->" INFO: 
 
 Return $Result
} ##  End-of Remove-PD

####################################################################################################################
################################################# FUNCTION Set-Cage ################################################
####################################################################################################################
Function Set-Cage
{
<#
  .SYNOPSIS
   The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
   
 .DESCRIPTION
  The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
  	
  .EXAMPLE
	Set-Cage -Position left -CageName cage1
	This example demonstrates how to assign cage1 a position description of Side Left.

  .EXAMPLE
	Set-Cage -Position left -PSModel 1 -CageName cage1
    This  example demonstrates how to assign model names to the power supplies in cage1. Inthisexample, cage1 hastwopowersupplies(0 and 1).
				
  .PARAMETER Position  
	Sets a description for the position of the cage in the cabinet, where <position> is a description to be assigned by service personnel (for example, left-top)
  
  .PARAMETER PSModel	  
	Sets the model of a cage power supply, where <model> is a model name to be assigned to the power supply by service personnel.
	get information regarding PSModel try using  [ Get-Cage -option d ]
	
  
  .PARAMETER CageName	 
	Indicates the name of the drive cage that is the object of the setcage operation.	
	
  .Notes
    NAME:  Set-Cage
    LASTEDIT: 30/10/2019
    KEYWORDS: Set-Cage
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$Position,
		
		[Parameter(Position=1, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$PSModel,
		
		[Parameter(Position=2, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$CageName,
			
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)	
	Write-DebugLog "Start: In Set-Cage  - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Set-Cage since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Set-Cage since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}		
	$cmd= "setcage "
	if ($Position )
	{
		$cmd+="position $Position "
	}		
	if ($PSModel)
	{
		$cmd2="showcage -d"
		$Result2 = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd2
		if($Result2 -match $PSModel)
		{
			$cmd+=" ps $PSModel "
		}	
		else
		{
			Write-DebugLog "Stop: Exiting  Set-Cage -PSModel $PSModel is Not available "
			return "Failure: -PSModel $PSModel is Not available. To Find Available Model `n Try  [Get-Cage -option d ] Command"
		}
	}		
	if ($CageName)
	{
		$cmd1="showcage"
		$Result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd1
		if($Result1 -match $CageName)
		{
			$cmd +="$CageName "
		}
		else
		{
			Write-DebugLog "Stop: Exiting  Set-Cage -CageName $CageName is Not available "
			return "Failure:  -CageName $CageName is Not available `n Try using [ Get-Cage ] Command to get list of Cage Name "
		}	
	}	
	else
	{
		Write-DebugLog "Stop: Exiting  Set-Cage NO parameters is passed CageName is mandatory "
		return "ERROR: -CageName is a required parameter"
	}		
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog " The Set-Cage command enables service personnel to set or modify parameters for a drive cage  " "INFO:" 		
	if([string]::IsNullOrEmpty($Result))
	{
		return  "Success : Executing Set-Cage Command $Result "
	}
	else
	{
		return  "FAILURE : While Executing Set-Cage $Result"
	} 		
} # End Set-Cage

####################################################################################################################
#################################################### FUNCTION Set-PD ###############################################
####################################################################################################################

Function Set-PD
{
<#
  .SYNOPSIS
   The Set-PD command marks a Physical Disk (PD) as allocatable or non allocatable for Logical   Disks (LDs).
   
  .DESCRIPTION
   The Set-PD command marks a Physical Disk (PD) as allocatable or non allocatable for Logical   Disks (LDs).   
	
  .EXAMPLE
	Set-PD -Ldalloc off -PD_ID 20	
	displays PD 20 marked as non allocatable for LDs.
   
  .EXAMPLE  
	Set-PD -Ldalloc on -PD_ID 25	
	displays PD 25 marked as allocatable for LDs.
   		
  .PARAMETER ldalloc 
	Specifies that the PD, as indicated with the PD_ID specifier, is either allocatable (on) or nonallocatable for LDs (off).
  	
  .PARAMETER PD_ID 
	Specifies the PD identification using an integer.	
     
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Set-PD
    LASTEDIT: 30/10/2019
    KEYWORDS: Set-PD
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$Ldalloc,
		
		[Parameter(Position=1, Mandatory=$true,ValueFromPipeline=$true)]
		[System.String]
		$PD_ID,
			
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Set-PD   - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{				
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Set-PD since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Set-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}		
	$cmd= "setpd "	
	if ($Ldalloc)
	{
		$a = "on","off"
		$l=$Ldalloc
		if($a -eq $l)
		{
			$cmd+=" ldalloc $Ldalloc "	
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Set-PD  since -Ldalloc in incorrect "
			return "FAILURE : -Ldalloc $Ldalloc cannot be used only [on|off] can be used . "
		}
	}
	else
	{
		Write-DebugLog "Stop: Ldalloc is mandatory" $Debug
		return "Error :  -Ldalloc is mandatory. "		
	}		
	if ($PD_ID)
	{
		$PD=$PD_ID
		if($PD -gt 4095)
		{ 
			Write-DebugLog "Stop: Exiting Set-PD  since  -PD_ID $PD_ID Illegal integer argument "
			return "FAILURE : -PD_ID $PD_ID Illegal integer argument . Expected range [0-4095].  "
		}
		$cmd+=" $PD_ID "
	}
	else
	{
		Write-DebugLog "Stop: PD_ID is mandatory" $Debug
		return "Error :  -PD_ID is mandatory. "		
	}		
	if ($cmd -eq "setpd ")
	{
		Write-DebugLog "FAILURE : Set-PD Should be used with Parameters, No parameters passed."
		return get-help  Set-PD 
	}	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	
	write-debuglog "  Executing Set-PD Physical Disk (PD) as allocatable or non allocatable for Logical Disks (LDs). with the command  " "INFO:" 
	if([string]::IsNullOrEmpty($Result))
	{
		return  "Success : Executing Set-PD  $Result"
	}
	else
	{
		return  "FAILURE : While Executing Set-PD $Result "
	} 	
} # End Set-PD	

##########################################################################
######################### FUNCTION Switch-PD #########################
##########################################################################
Function Switch-PD()
{
<#
  .SYNOPSIS
   Switch-PD - Spin up or down a physical disk (PD).

  .DESCRIPTION
   The Switch-PD command spins a PD up or down. This command is used when
   replacing a PD in a drive magazine.

  .EXAMPLE
	The following example instigates the spin up of a PD identified by its
	WWN of 2000000087002078:
	Switch-PD -Spinup -WWN 2000000087002078
  
  .PARAMETER Spinup
	Specifies that the PD is to spin up. If this subcommand is not used,
	then the spindown subcommand must be used.
  
  .PARAMETER Spindown
	Specifies that the PD is to spin down. If this subcommand is not used,
	then the spinup subcommand must be used.

  .PARAMETER Ovrd
   Specifies that the operation is forced, even if the PD is in use.

   
  .PARAMETER WWN
	Specifies the World Wide Name of the PD. This specifier can be repeated
	to identify multiple PDs.
   
  .Notes
    NAME: Switch-PD
    LASTEDIT 30/10/2019
    KEYWORDS: Switch-PD
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[switch]
	$Spinup,

	[Parameter(Position=1, Mandatory=$false)]
	[switch]
	$Spindown,
 
	[Parameter(Position=2, Mandatory=$false)]
	[switch]
	$Ovrd,	

	[Parameter(Position=3, Mandatory=$True)]
	[System.String]
	$WWN,

	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Switch-PD - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Switch-PD since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Switch-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " controlpd "

 if($Spinup)
 {
	$Cmd += " spinup "
 }
 elseif($Spindown)
 {
	$Cmd += " spindown "
 }
 else
 {
	Return "Select at least one from [ Spinup | Spindown ]"
 }

 if($Ovrd)
 {
	$Cmd += " -ovrd "
 }

 if($WWN)
 {
	$Cmd += " $WWN "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : Switch-PD command -->" INFO: 
 
 Return $Result
} ##  End-of Switch-PD
	
####################################################################################################################
################################################ FUNCTION Test-PD ##################################################
####################################################################################################################

Function Test-PD
{
<#
  .SYNOPSIS
    The Test-PD command executes surface scans or diagnostics on physical disks.
	
  .DESCRIPTION
    The Test-PD command executes surface scans or diagnostics on physical disks.	
	
  .EXAMPLE
	Test-PD -specifier scrub -ch 500 -pd_ID 1
	This example Test-PD chunklet 500 on physical disk 1 is scanned for media defects.
   
  .EXAMPLE  
	Test-PD -specifier scrub -count 150 -pd_ID 1
	This example scans a number of chunklets starting from -ch 150 on physical disk 1.
   
  .EXAMPLE  
	Test-PD -specifier diag -path a -pd_ID 5
	This example Specifies a physical disk path as a,physical disk 5 is scanned for media defects.
		
  .EXAMPLE  	
	Test-PD -specifier diag -iosize 1s -pd_ID 3
	This example Specifies I/O size 1s, physical disk 3 is scanned for media defects.
	
  .EXAMPLE  	
	Test-PD -specifier diag -range 5m  -pd_ID 3
	This example Limits diagnostic to range 5m [mb] physical disk 3 is scanned for media defects.
		
  .PARAMETER specifier	
	scrub - Scans one or more chunklets for media defects.
	diag - Performs read, write, or verifies test diagnostics.
  
  .PARAMETER ch
	To scan a specific chunklet rather than the entire disk.
  
  .PARAMETER count
	To scan a number of chunklets starting from -ch.
  
  .PARAMETER path
	Specifies a physical disk path as [a|b|both|system].
  
  .PARAMETER test
	Specifies [read|write|verify] test diagnostics. If no type is specified, the default is read .

  .PARAMETER iosize
	Specifies I/O size, valid ranges are from 1s to 1m. If no size is specified, the default is 128k .
	 
  .PARAMETER range
	Limits diagnostic regions to a specified size, from 2m to 2g.
	
  .PARAMETER pd_ID
	The ID of the physical disk to be checked. Only one pd_ID can be specified for the “scrub” test.
	
  .PARAMETER threads
	Specifies number of I/O threads, valid ranges are from 1 to 4. If the number of threads is not specified, the default is 1.
	
  .PARAMETER time
	Indicates the number of seconds to run, from 1 to 36000.
	
  .PARAMETER total
	Indicates total bytes to transfer per disk. If a size is not specified, the default size is 1g.
	
  .PARAMETER retry
	 Specifies the total number of retries on an I/O error.
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Test-PD
    LASTEDIT: 30/10/2019
    KEYWORDS: Test-PD
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$specifier,
		
		[Parameter(Position=1, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$ch,
		
		[Parameter(Position=2, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$count,
		
		[Parameter(Position=3, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$path,
		
		[Parameter(Position=4, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$test,
		
		[Parameter(Position=5, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$iosize,
		
		[Parameter(Position=6, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$range,
		
		[Parameter(Position=7, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$threads,
		
		[Parameter(Position=8, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$time,
		
		[Parameter(Position=9, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$total,
		
		[Parameter(Position=10, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$retry,
		
		[Parameter(Position=11, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$pd_ID,
		
		[Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)		
	
	Write-DebugLog "Start: In Test-PD   - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{				
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Test-PD since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Test-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}		
	$cmd= "checkpd "	
	if ($specifier)
	{
		$spe = $specifier
		$demo = "scrub" , "diag"
		if($demo -eq $spe)
		{
			$cmd+=" $spe "
		}
		else
		{
			return " FAILURE : $spe is not a Valid specifier please use [scrub | diag] only.  "
		}
	}
	else
	{
		return " FAILURE :  -specifier is mandatory for Test-PD to execute  "
	}		
	if ($ch)
	{
		$a=$ch
		[int]$b=$a
		if($a -eq $b)
		{
			if($cmd -match "scrub")
			{
				$cmd +=" -ch $ch "
			}
			else
			{
				return "FAILURE : -ch $ch cannot be used with -Specification diag "
			}
		}	
		else
		{
			Return "Error :  -ch $ch Only Integers are Accepted "
	
		}
	}	
	if ($count)
	{
		$a=$count
		[int]$b=$a
		if($a -eq $b)
		{	
			if($cmd -match "scrub")
			{
				$cmd +=" -count $count "
			}
			else
			{
				return "FAILURE : -count $count cannot be used with -Specification diag "
			}
		}
		else
		{
			Return "Error :  -count $count Only Integers are Accepted "	
		}
	}		
	if ($path)
	{
		if($cmd -match "diag")
		{
			$a = $path
			$b = "a","b","both","system"
			if($b -match $a)
			{
				$cmd +=" -path $path "
			}
			else
			{
				return "FAILURE : -path $path is invalid use [a | b | both | system ] only  "
			}
		}
		else
		{
			return " FAILURE : -path $path cannot be used with -Specification scrub "
		}
	}		
	if ($test)
	{
		if($cmd -match "diag")
		{
			$a = $test 
			$b = "read","write","verify"
			if($b -eq $a)
			{
				$cmd +=" -test $test "
			}
			else
			{
				return "FAILURE : -test $test is invalid use [ read | write | verify ] only  "
			}
		}
		else
		{
			return " FAILURE : -test $test cannot be used with -Specification scrub "
		}
	}			
	if ($iosize)
	{	
		if($cmd -match "diag")
		{
			$cmd +=" -iosize $iosize "
		}
		else
		{
			return "FAILURE : -test $test cannot be used with -Specification scrub "
		}
	}			 
	if ($range )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -range $range "
		}
		else
		{
			return "FAILURE : -range $range cannot be used with -Specification scrub "
		}
	}	
	if ($threads )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -threads $threads "
		}
		else
		{
			return "FAILURE : -threads $threads cannot be used with -Specification scrub "
		}
	}
	if ($time )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -time $time "
		}
		else
		{
			return "FAILURE : -time $time cannot be used with -Specification scrub "
		}
	}
	if ($total )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -total $total "
		}
		else
		{
			return "FAILURE : -total $total cannot be used with -Specification scrub "
		}
	}
	if ($retry )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -retry $retry "
		}
		else
		{
			return "FAILURE : -retry $retry cannot be used with -Specification scrub "
		}
	}
	if($pd_ID)
	{	
		$cmd += " $pd_ID "
	}
	else
	{
		return " FAILURE :  pd_ID is mandatory for Test-PD to execute  "
	}	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd	
	write-debuglog "  Executing surface scans or diagnostics on physical disks with the command  " "INFO:" 
	return $Result	
} # End Test-PD

Export-ModuleMember Set-AdmitsPD , Find-Cage , Get-Cage , Show-PD , Remove-PD , Set-Cage , Set-PD , Switch-PD , Test-PD
# SIG # Begin signature block
# MIIh0AYJKoZIhvcNAQcCoIIhwTCCIb0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDpM81qnx1Qq+4P
# Rh9FsAp/XolnKUU/S+cJQCwhEDHX3qCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# vK2U5xL1spoKPhbOxByZWmFmy8s9yfKl+P/01M1HLwYwDQYJKoZIhvcNAQEBBQAE
# ggEAOzw6bCpJSVbQd7ePhEgvnUCAJR2gMqSCBb7Lh8I7QLEwkH3DUFYcLdjfli9M
# ympAZAg9CH2PXpQ8GQu8s2WMlZ57F5DpFvnxWrhmBLkVKwoO+TeZLBJJ9RZrt0fv
# nlL3wnXdZTb2ELTL+tP1Wri6QDt1a2MMmLaoJkfEcOxK+vX+RH27uATVe/eodYIT
# QpFwaOom578MNn5yo4o/dhBWhlozsbCg2z+k2WG/5ocPPvmeF2JImt3KfDxJD7JJ
# bvkBrvEn7iqKOWro8evlbXDp2DGPb1zEjRLmNtZizs0leV8musMBJAibDhqI0xHx
# ZYwLiawRkGBMwnzaTb+ucpIVnqGCDj0wgg45BgorBgEEAYI3AwMBMYIOKTCCDiUG
# CSqGSIb3DQEHAqCCDhYwgg4SAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDwYLKoZIhvcN
# AQkQAQSggf8EgfwwgfkCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# IA/PD3E/VPsB+A/IS3n5LBGMY8uwQoEqkxmcMzDiSi7VAhUAyFX8kSeptgKkSU7D
# lV/VdUobaAkYDzIwMjEwNjE5MDQwNDU1WjADAgEeoIGGpIGDMIGAMQswCQYDVQQG
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
# hkiG9w0BCQUxDxcNMjEwNjE5MDQwNDU1WjAvBgkqhkiG9w0BCQQxIgQglERKIyOe
# cBA0izYZludrZzLxU2W6JzbRfXW6wZUQ61UwNwYLKoZIhvcNAQkQAi8xKDAmMCQw
# IgQgxHTOdgB9AjlODaXk3nwUxoD54oIBPP72U+9dtx/fYfgwCwYJKoZIhvcNAQEB
# BIIBAEHzvlcHUiCgFnSCUoeyim6PiRmgAJzi+JyopQOQoXo0wfTgjC0WV3ma9vHf
# uNSNz4cvsV1u15BraZfTtUA4EE19Vvz4xuzn0ZpIHjWa255Z5XQLEoDDLctb4ruk
# Zlz8TmSypIY4+onkPo+5F/dA1GouDrX8uPR4x7e8VsHZzYbEUZJ0Mhk83dTOSFyp
# gYfxJVObVEstQh1Rt4hSTEL9Iniwj4DPzByxbBfrBGi9UqRZDj1GXXRR4TJPOdJV
# sfSAx0+Dw7OQdkEAImZVWgiV+P6U0KU5OVrJ6IioAxSZN7CD6Fa3MkH5f3icFpmg
# vAm9Oo8I5UpQVbKYWosmsxZXKaA=
# SIG # End signature block
