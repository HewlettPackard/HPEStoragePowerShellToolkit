####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Set-A9AdmitPhysicalDisk
{
<#
.SYNOPSIS
    The command creates and admits physical disk definitions to enable the use of those disks.
.DESCRIPTION
    The command creates and admits physical disk definitions to enable the use of those disks.
.EXAMPLE
	PS:> Set-A9AdmitPhysicalDisk
	
	This example admits physical disks.
.EXAMPLE
	PS:> Set-A9AdmitPhysicalDisk -Nold
	
	Do not use the PD (as identified by the <world_wide_name> specifier) For logical disk allocation.
.EXAMPLE
	PS:> Set-A9AdmitPhysicalDisk -NoPatch
	
	Suppresses the check for drive table update packages for new hardware enablement.
.EXAMPLE  	
	PS:> Set-A9AdmitPhysicalDisk -Nold -wwn xyz

	Do not use the PD (as identified by the <world_wide_name> specifier) For logical disk allocation.
.PARAMETER Nold
	Do not use the PD (as identified by the <world_wide_name> specifier) for logical disk allocation.
.PARAMETER Nopatch
	Suppresses the check for drive table update packages for new
	hardware enablement.
.PARAMETER wwn
	Indicates the World-Wide Name (WWN) of the physical disk to be admitted. If WWNs are specified, only the specified physical disk(s) are admitted.	
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Nold,
		[Parameter()]	[switch]	$NoPatch,
		[Parameter()]	[String]	$wwn	)	
	Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "admitpd -f  "
	if ($Nold)		{	$cmd+=" -nold "	}
	if ($NoPatch)	{	$cmd+=" -nopatch " }
	if($wwn)		{	$cmd += " $wwn"	}
	$Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
} 
}

Function Find-A9Cage
{
<#
.SYNOPSIS
	The command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs.
.DESCRIPTION
	The command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs. 
.EXAMPLE
	PS:> Find-A9Cage -Time 30 -CageName cage0	
	
	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds.
.EXAMPLE  
	PS:> Find-A9Cage -Time 30 -CageName cage0 -mag 3	

	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds,Indicates the drive magazine by number 3.
.EXAMPLE  
	PS:> Find-A9Cage -Time 30 -CageName cage0 -PortName demo1

	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds, If a port is specified, the port LED will oscillate between green and off.
.EXAMPLE  	
	PS:> Find-A9Cage -CageName cage1 -Mag 2	

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
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]				[String]	$Time,
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]	$CageName,
		[Parameter(ValueFromPipeline=$true)]				[String]	$ModuleName,
		[Parameter(alse,ValueFromPipeline=$true)]			[String]	$ModuleNumber,
		[Parameter(ValueFromPipeline=$true)]				[String]	$Mag,
		[Parameter(ValueFromPipeline=$true)]				[String]	$PortName
)		
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "locatecage "	
	if ($time)
		{	$s = 0..255
			$demo = $time
			if($s -match $demo)
				{	$str="time"
					$cmd+=" -t $time"
				}
			else{	return " Error : -time $time is Not valid use seconds, from 0 through 255 Only "
				}
		}
	if ($CageName)
		{	$cmd2="showcage "
			$Result2 = Invoke-CLICommand -cmds  $cmd2
			if($Result2 -match $CageName)
				{	$cmd+=" $CageName"
				}
			else{return "FAILURE : -CageName $CageName  is Unavailable `n Try using [Get-Cage] Command "
				}
		}
	else{	return "Error :  -CageName is mandatory. "
		}
	if ($ModuleName)	{	$cmd+=" $ModuleName"  }	
	if ($ModuleNumber)	{	$cmd+=" $ModuleNumber"}
	if ($Mag)
		{	$a = 0..15
			$demo = $Mag
			if($a -match $demo)
				{	$str="mag"
					$cmd +=" $Mag"
				}
			else{	return "Error : -Mag $Mag is Not valid use seconds,from 0 through 15 Only"		
				}
		}	
	if ($PortName)
		{	$s=$str
			if ($s -match "mag" )	{	return "FAILURE : -Mag $Mag cannot be used along with  -PortName $PortName "	}
			else
				{	$a = $PortName
					$b = "A0","B0","A1","B1","A2","B2","A3","B3"
					if($b -eq $a)	{	$cmd +=" $PortName"	}
					else			{	return "Error : -PortName $PortName is invalid use [ A0| B0 | A1 | B1 | A2 | B2 | A3 | B3 ] only  "	}
				}	
		}	
	$Result = Invoke-CLICommand -cmds  $cmd	
	write-verbose "  Executing Find-Cage Command , surface scans or diagnostics on physical disks with the command   " 	
	if([string]::IsNullOrEmpty($Result))
		{	return  "Success : Find-Cage Command Executed Successfully $Result"
		}
	else{	return  "FAILURE : While Executing Find-Cage `n $Result"
		} 		
}
}

Function Get-A9Cage
{
<#
.SYNOPSIS
	The command displays information about drive cages.
.DESCRIPTION
	The command displays information about drive cages.    
.EXAMPLE
	PS:> Get-A9Cage
	
	This examples display information for a single system’s drive cages.
.EXAMPLE  
	PS:> Get-A9Cage -D -CageName cage2	
	
	Specifies that more detailed information about the drive cage is displayed
.EXAMPLE  
	PS:> Get-A9Cage -I -CageName cage2
	
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
#>
[CmdletBinding()]
param(	[Parameter()]	[Switch]	$D,
		[Parameter()]	[Switch]	$E,
		[Parameter()]	[Switch]	$C,
		[Parameter()]	[Switch]	$SFP,
		[Parameter()]	[Switch]	$DDM,
		[Parameter()]	[Switch]	$I,
		[Parameter()]	[Switch]	$SVC,
		[Parameter()]	[String]	$CageName
	)		
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "showcage "
	$testCmd= "showcage "
	if($D)	{ 	$cmd +=" -d "}
	if($E) 	{ 	$cmd +=" -e "}
	if($C) 	{ 	$cmd +=" -c "}
	if($SFP){ 	$cmd +=" -sfp " }
	if($DDM){ 	$cmd +=" -ddm " }
	if($I) 	{ 	$cmd +=" -i " }
	if($SVC){ 	$cmd +=" -svc -i"}
	if ($CageName) 
		{	$cmd+=" $CageName "
			$testCmd+=" $CageName "
		}
	$Result = Invoke-CLICommand -cmds  $cmd
	write-verbose "  Executing  Get-Cage command that displays information about drive cages. with the command   " 
	if($cmd -eq "showcage " -or ($cmd -eq $testCmd))
		{	if($Result.Count -gt 1)
				{	$tempFile = [IO.Path]::GetTempFileName()
					$LastItem = $Result.Count 
					#Write-Host " Result Count =" $Result.Count
					foreach ($s in  $Result[0..$LastItem] )
						{	$s= [regex]::Replace($s,"^ ","")			
							$s= [regex]::Replace($s," +",",")	
							$s= $s.Trim() 	
							Add-Content -Path $tempFile -Value $s
						}
					Import-Csv $tempFile 
					Remove-Item  $tempFile
					Return  " Success : Executing Get-Cage"
				}
			else{	Return  " FAILURE : While Executing Get-Cage `n $Result"		
				}		
		}
	if($Result -match "Cage" )
		{	$result	
			Return  " Success : Executing Get-Cage"
		} 
	else{	Return  " FAILURE : While Executing Get-Cage `n $Result"
		} 
}
}

Function Show-A9PhysicalDisk
{
<#
.SYNOPSIS
	Displays configuration information about the physical disks (PDs) on a system. 
.DESCRIPTION
	Displays configuration information about the physical disks (PDs) on a system. 
.EXAMPLE  
	PS:> Show-A9PhysicalDisk

	This example displays configuration information about all the physical disks (PDs) on a system. 
.EXAMPLE  
	PS:> Show-A9PhysicalDisk -PD_ID 5

	This example displays configuration information about specific or given physical disks (PDs) on a system. 
.EXAMPLE  
	PS:> Show-A9PhysicalDisk -C 

	This example displays chunklet use information for all disks. 
.EXAMPLE  
	PS:> Show-A9PhysicalDisk -C -PD_ID 5

	This example will display chunklet use information for all disks with the physical disk ID. 
.EXAMPLE  
	PS:> Show-A9PhysicalDisk -Node 0 -PD_ID 5
.EXAMPLE  
	PS:> Show-A9PhysicalDisk -I -Pattern -ND 1 -PD_ID 5
.EXAMPLE
	PS:> Show-A9PhysicalDisk -C -Pattern -Devtype FC  	
.EXAMPLE  
	PS:> Show-A9PhysicalDisk -option p -pattern mg -patternValue 0

	TThis example will display all the FC disks in magazine 0 of all cages.
.PARAMETER Listcols
	List the columns available to be shown in the -showcols option
	described below (see 'clihelp -col showpd' for help on each column).
.PARAMETER I
	Show disk inventory (inquiry) data.

	The following columns are shown:
	Id CagePos State Node_WWN MFR Model Serial FW_Rev Protocol MediaType AdmissionTime.
.PARAMETER E
	Show disk environment and error information. Note that reading this information places a significant load on each disk.
	The following columns are shown:
	Id CagePos Type State Rd_CErr Rd_UErr Wr_CErr Wr_UErr Temp_DegC LifeLeft_PCT.
.PARAMETER C
	Show chunklet usage information. Any chunklet in a failed disk will be shown as "Fail".

	The following columns are shown:
	Id CagePos Type State Total_Chunk Nrm_Used_OK Nrm_Used_Fail
	Nrm_Unused_Free Nrm_Unused_Uninit Nrm_Unused_Unavail Nrm_Unused_Fail
	Spr_Used_OK Spr_Used_Fail Spr_Unused_Free Spr_Unused_Uninit Spr_Unused_Fail.
.PARAMETER S
	Show detailed state information. This option is deprecated and will be removed in a subsequent release.
.PARAMETER State
	Show detailed state information. This is the same as -s.

	The following columns are shown:	Id CagePos Type State Detailed_State SedState.
.PARAMETER Path
	Show current and saved path information for disks.

	The following columns are shown: Id CagePos Type State Path_A0 Path_A1 Path_B0 Path_B1 Order.
.PARAMETER Space
	Show disk capacity usage information (in MB).

	The following columns are shown: Id CagePos Type State Size_MB Volume_MB Spare_MB Free_MB Unavail_MB Failed_MB.
.PARAMETER Failed
	Specifies that only failed physical disks are displayed.
.PARAMETER Degraded
	Specifies that only degraded physical disks are displayed. If both -failed and -degraded are specified, the command shows failed disks and degraded disks.
.PARAMETER Pattern
	Physical disks matching the specified pattern are displayed.
.PARAMETER ND
	Specifies one or more nodes. Nodes are identified by one or more integers (item). Multiple nodes are separated with a single comma
	(e.g. 1,2,3). A range of nodes is separated with a hyphen (e.g. 0-7). The primary path of the disks must be on the specified node(s).
.PARAMETER ST
	Specifies one or more PCI slots. Slots are identified by one or more integers (item). Multiple slots are separated with a single comma
	(e.g. 1,2,3). A range of slots is separated with a hyphen (e.g. 0-7). The primary path of the disks must be on the specified PCI slot(s).
.PARAMETER PT
	Specifies one or more ports. Ports are identified by one or more integers (item). Multiple ports are separated with a single comma
	(e.g. 1,2,3). A range of ports is separated with a hyphen (e.g. 0-4). The primary path of the disks must be on the specified port(s).
.PARAMETER CG
	Specifies one or more drive cages. Drive cages are identified by one or more integers (item). Multiple drive cages are separated with a
	single comma (e.g. 1,2,3). A range of drive cages is separated with a hyphen (e.g. 0-3). The specified drive cage(s) must contain disks.
.PARAMETER MG
	Specifies one or more drive magazines. The "1." or "0." displayed in the CagePos column of showpd output indicating the side of the cage is omitted when 
	using the -mg option. Drive magazines are identified by one or more integers (item). Multiple drive magazines are separated with a single comma (e.g. 1,2,3). 
	A range of drive magazines is separated with a hyphen(e.g. 0-7). The specified drive magazine(s) must contain disks.
.PARAMETER PN
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers (item). Multiple disk positions 
	are separated with a single comma(e.g. 1,2,3). A range of disk positions is separated with a hyphen(e.g. 0-3). The specified position(s) must contain disks.
.PARAMETER DK
	Specifies one or more physical disks. Disks are identified by one or more integers(item). Multiple disks are separated with a single
	comma (e.g. 1,2,3). A range of disks is separated with a hyphen(e.g. 0-3).  Disks must match the specified ID(s).
.PARAMETER Devtype
	Specifies that physical disks must have the specified device type (FC for Fast Class, NL for Nearline, SSD for Solid State Drive)
	to be used. Device types can be displayed by issuing the "showpd" command.
.PARAMETER RPM
	Drives must be of the specified relative performance metric, as shown in the "RPM" column of the "showpd" command. The number does not represent a rotational 
	speed for the drives without spinning media (SSD). It is meant as a rough estimation of the performance difference between the drive and the other drives
	in the system.  For FC and NL drives, the number corresponds to both a performance measure and actual rotational speed. For SSD drives, the number is to be 
	treated as a relative performance benchmark that takes into account I/O's per second, bandwidth and access time.
.PARAMETER Node
	Specifies that the display is limited to specified nodes and physical disks connected to those nodes. The node list is specified as a series
	of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the node list is not specified, all disks on all nodes are displayed.
.PARAMETER Slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified as a series of 
	integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all disks on all slots are displayed.
.PARAMETER Ports
	Specifies that the display is limited to specified ports and physical disks connected to those ports. The port list is specified as a series of integers separated 
	by commas (e.g. 1,2,3). The list can also consist of a single integer. If the port list is not specified, all disks on all ports are displayed.
.PARAMETER WWN
	Specifies the WWN of the physical disk. This option and argument can be specified if the <PD_ID> specifier is not used. This option should be the last option in the command line.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$I,
		[Parameter()]	[switch]	$E,
		[Parameter()]	[switch]	$C,
		[Parameter()]	[switch]	$StateInfo,
		[Parameter()]	[switch]	$State,
		[Parameter()]	[switch]	$Path,
		[Parameter()]	[switch]	$Space,
		[Parameter()]	[switch]	$Failed,
		[Parameter()]	[switch]	$Degraded,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Node ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Slots ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Ports ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$WWN ,
		[Parameter()]	[switch]	$Pattern,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ND ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ST ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$PT ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$CG ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$MG ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$PN ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$DK ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Devtype ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$RPM ,
		[Parameter(ValueFromPipeline=$true)]	[String]	$PD_ID ,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Listcols 
)		
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "showpd "	
	if($Listcols)
		{	$cmd+=" -listcols "
			$Result = Invoke-CLICommand -cmds  $cmd
			return $Result
		}
	if($I)	{	$cmd+=" -i "	}
	if($E)	{	$cmd+=" -e "	}
	if($C)	{	$cmd+=" -c "	}
	if($StateInfo)	{	$cmd+=" -s "}
	if($State)	{	$cmd+=" -state "}
	if($Path){	$cmd+=" -path "	}
	if($Space){	$cmd+=" -space "}
	if($Failed){	$cmd+=" -failed "}
	if($Degraded){	$cmd+=" -degraded "	}
	if($Node){	$cmd+=" -nodes $Node "	}
	if($Slots){	$cmd+=" -slots $Slots "	}
	if($Ports){	$cmd+=" -ports $Ports "	}
	if($WWN){	$cmd+=" -w $WWN "	}
	if($Pattern)
		{	if($ND)	{	$cmd+=" -p -nd $ND "	}
			if($ST)	{	$cmd+=" -p -st $ST "	}
			if($PT)	{	$cmd+=" -p -pt $PT "	}
			if($CG)	{	$cmd+=" -p -cg $CG "	}
			if($MG)	{	$cmd+=" -p -mg $MG "	}
			if($PN)	{	$cmd+=" -p -pn $PN "	}
			if($DK)	{	$cmd+=" -p -dk $DK "	}
			if($Devtype){	$cmd+=" -p -devtype $Devtype "	}
			if($RPM)	{	$cmd+=" -p -rpm $RPM "}
		}		
	if ($PD_ID)
		{	$PD=$PD_ID		
			$pdd="showpd $PD"
			$Result1 = Invoke-CLICommand -cmds  $pdd	
			if($Result1 -match "No PDs listed" )
				{	return " FAILURE : $PD_ID is not available id pLease try using only [Show-PD] to get the list of PD_ID Available. "			
				}
			else{	$cmd+=" $PD_ID "
				}
		}	
	$Result = Invoke-CLICommand -cmds  $cmd
	if($Result -match "Invalid device type")	{	return $Result	}
	if($Result.Count -lt 2)	{	return $Result	}
	if($I -Or $State -Or $StateInfo)
		{	$flag = "True"
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -3  
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim()
					if($I)
						{	if($flag -eq "True")
								{	$sTemp1=$s
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
			Remove-Item  $tempFile
		}
	ElseIf($C)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -3  
			$incre = "true"			
			foreach ($s in  $Result[2..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim()				
					if($incre -eq "true")
						{	$sTemp1=$s
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
					$incre="false"				
				}			
			Import-Csv $tempFile 
			Remove-Item  $tempFile
		}
	ElseIf($E)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -3  
			$incre = "true"			
			foreach ($s in  $Result[1..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim()				
					if($incre -eq "true")
						{	$sTemp1=$s
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
					$incre="false"				
				}
			Import-Csv $tempFile 
			Remove-Item  $tempFile
		}
	else
		{	if($Result -match "Id")
				{	$tempFile = [IO.Path]::GetTempFileName()
					$LastItem = $Result.Count -3  
					foreach ($s in  $Result[1..$LastItem] )
					{	$s= [regex]::Replace($s,"^ ","")			
						$s= [regex]::Replace($s," +",",")
						$s= [regex]::Replace($s,"-","")
						$s= $s.Trim() 	
						Add-Content -Path $tempFile -Value $s
					}
					if($Space)
						{	write-host "Size | Volume | Spare | Free | Unavail & Failed values are in (MiB)."
						}
					else
						{	write-host "Total and Free values are in (MiB)."
						}				
					Import-Csv $tempFile 
					Remove-Item  $tempFile
				}
		}		
	if($Result.Count -gt 1)
		{	return "Success : Command Show-PD execute Successfully."
		}
	else{	return $Result		
		} 	
}
}

Function Remove-A9PhysicalDisk
{
<#
.SYNOPSIS
	Remove a physical disk (PD) from system use.
.DESCRIPTION
	The command removes PD definitions from system use.
.EXAMPLE
	The following example removes a PD with ID 1:

	PS:> Remove-A9PhysicalDisk -PDID 1
.PARAMETER PDID
	Specifies the PD(s), identified by integers, to be removed from system use.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$True)]	[String]	$PDID
)
Begin	
{   Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " dismisspd "
	if($PDID)	{	$Cmd += " $PDID " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Set-A9Cage
{
<#
.SYNOPSIS
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.DESCRIPTION
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.EXAMPLE
	PS:> Set-A9Cage -Position left -CageName cage1

	This example demonstrates how to assign cage1 a position description of Side Left.
.EXAMPLE
	PS:> Set-A9Cage -Position left -PSModel 1 -CageName cage1

	This  example demonstrates how to assign model names to the power supplies in cage1. Inthisexample, cage1 hastwopowersupplies(0 and 1).
.PARAMETER Position  
	Sets a description for the position of the cage in the cabinet, where <position> is a description to be assigned by service personnel (for example, left-top)
.PARAMETER PSModel	  
	Sets the model of a cage power supply, where <model> is a model name to be assigned to the power supply by service personnel. get information regarding PSModel try using  [ Get-Cage -option d ]
.PARAMETER CageName	 
	Indicates the name of the drive cage that is the object of the setcage operation.	
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Position,
		[Parameter(ValueFromPipeline=$true)]	[String]	$PSModel,
		[Parameter(ValueFromPipeline=$true)]	[String]	$CageName
)	
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "setcage "
	if ($Position ){	$cmd+="position $Position "}		
	if ($PSModel)
		{	$cmd2="showcage -d"
			$Result2 = Invoke-CLICommand -cmds  $cmd2
			if($Result2 -match $PSModel)	{	$cmd+=" ps $PSModel "	}	
			else{	return "Failure: -PSModel $PSModel is Not available. To Find Available Model `n Try  [Get-Cage -option d ] Command"
				}
		}		
	if ($CageName)
		{	$cmd1="showcage"
			$Result1 = Invoke-CLICommand -cmds  $cmd1
			if($Result1 -match $CageName)	{	$cmd +="$CageName "	}
			else{	return "Failure:  -CageName $CageName is Not available `n Try using [ Get-Cage ] Command to get list of Cage Name "
				}	
		}	
	else
		{	return "ERROR: -CageName is a required parameter"
		}		
	$Result = Invoke-CLICommand -cmds  $cmd
	write-verbose " The Set-Cage command enables service personnel to set or modify parameters for a drive cage  " 		
	if([string]::IsNullOrEmpty($Result))
		{	return  "Success : Executing Set-Cage Command $Result "
		}
	else
		{	return  "FAILURE : While Executing Set-Cage $Result"
		} 		
}
}

Function Set-A9PhysicalDisk
{
<#
.SYNOPSIS
	Marks a Physical Disk (PD) as allocatable or non allocatable for Logical   Disks (LDs).
.DESCRIPTION
	Marks a Physical Disk (PD) as allocatable or non allocatable for Logical   Disks (LDs).   
.EXAMPLE
	PS:> Set-A9PhysicalDisk -Ldalloc off -PD_ID 20	
	
	displays PD 20 marked as non allocatable for LDs.
.EXAMPLE  
	PS:> Set-A9PhysicalDisk -Ldalloc on -PD_ID 25	

	displays PD 25 marked as allocatable for LDs.
.PARAMETER ldalloc 
	Specifies that the PD, as indicated with the PD_ID specifier, is either allocatable (on) or nonallocatable for LDs (off)..PARAMETER PD_ID 
	Specifies the PD identification using an integer.	
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)][ValidateSet('on','off')]	[String]	$Ldalloc,	
		[Parameter(Mandatory=$true)][ValidateRange(0,4096)]		[String]	$PD_ID
)		
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "setpd "	
	$cmd+=" ldalloc $Ldalloc "				
	$cmd+=" $PD_ID "
	$Result = Invoke-CLICommand -cmds  $cmd
	if([string]::IsNullOrEmpty($Result))
		{	return  "Success : Executing Set-PD  $Result"
		}
	else{	return  "FAILURE : While Executing Set-PD $Result "
		} 	
} 
}

Function Switch-A9PhysicalDisk
{
<#
.SYNOPSIS
	Spin up or down a physical disk (PD).
.DESCRIPTION
	The command spins a PD up or down. This command is used when replacing a PD in a drive magazine.
.PARAMETER Spinup
	Specifies that the PD is to spin up. If this subcommand is not used, then the spindown subcommand must be used.
.PARAMETER Spindown
	Specifies that the PD is to spin down. If this subcommand is not used, then the spinup subcommand must be used.
.PARAMETER Ovrd
	Specifies that the operation is forced, even if the PD is in use.
.PARAMETER WWN
	Specifies the World Wide Name of the PD. This specifier can be repeated to identify multiple PDs.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='up',  Mandatory=$true)]	[switch]	$Spinup,
		[Parameter(ParameterSetName='down',Mandatory=$true)]	[switch]	$Spindown, 
		[Parameter()]	[switch]	$Ovrd,	
		[Parameter()]	[String]	$WWN
)
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " controlpd "
	if($Spinup)			{	$Cmd += " spinup " }
	elseif($Spindown)	{	$Cmd += " spindown " }
	if($Ovrd)			{	$Cmd += " -ovrd " }
	if($WWN)			{	$Cmd += " $WWN " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
} 
}	

Function Test-A9PhysicalDisk
{
<#
.SYNOPSIS
	Executes surface scans or diagnostics on physical disks.
.DESCRIPTION
    Executes surface scans or diagnostics on physical disks.	
.EXAMPLE
	PS:> Test-A9PhysicalDisk -scrub -ch 500 -pd_ID 1

	This example Test-PD chunklet 500 on physical disk 1 is scanned for media defects.
.EXAMPLE  
	PS:> Test-A9PhysicalDisk -scrub -count 150 -pd_ID 1

	This example scans a number of chunklets starting from -ch 150 on physical disk 1.
.EXAMPLE  
	PS:> Test-A9PhysicalDisk -diag -path a -pd_ID 5

	This example Specifies a physical disk path as a,physical disk 5 is scanned for media defects.
.EXAMPLE  	
	PS:> Test-A9PhysicalDisk -diag -iosize 1s -pd_ID 3

	This example Specifies I/O size 1s, physical disk 3 is scanned for media defects.
.EXAMPLE  	
	PS:> Test-A9PhysicalDisk -diag -range 5m  -pd_ID 3

	This example Limits diagnostic to range 5m [mb] physical disk 3 is scanned for media defects.
.PARAMETER Diag	
	diag - Performs read, write, or verifies test diagnostics.
.PARAMETER Scrub
	scrub - Scans one or more chunklets for media defects. 
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
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='diag', Mandatory=$true, ValueFromPipeline=$true)]	[switch]	$Diag,		
		[Parameter(ParameterSetName='scrub', Mandatory=$true, ValueFromPipeline=$true)]	[switch]	$Scrub,		
		[Parameter(ParameterSetName='Scrub',ValueFromPipeline=$true)]					[int]		$ch,		
		[Parameter(ParameterSetName='Scrub',ValueFromPipeline=$true)]					[int]		$count,
		[Parameter(ParameterSetName='diag', ValueFromPipeline=$true)]
		[ValidateSet('a','b','system','both')]											[String]	$path,		
		[Parameter(ParameterSetName='diag', ValueFromPipeline=$true)]
		[ValidateSet('read','write','validate')]										[String]	$test,	
		[Parameter(ParameterSetName='diag', ValueFromPipeline=$true)]					[String]	$iosize,	
		[Parameter(ParameterSetName='diag', ValueFromPipeline=$true)]					[String]	$range,		
		[Parameter(ParameterSetName='diag', ValueFromPipeline=$true)]					[String]	$threads,	
		[Parameter(ParameterSetName='diag', ValueFromPipeline=$true)]					[String]	$time,		
		[Parameter(ParameterSetName='diag', ValueFromPipeline=$true)]					[String]	$total,		
		[Parameter(ParameterSetName='diag', ValueFromPipeline=$true)]					[String]	$retry,		
		[Parameter(ParameterSetName='diag', ValueFromPipeline=$true,Mandatory=$true)]	[String]	$pd_ID
	)		
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	if ( $scrub)
		{	$cmd="checkpd scrub "
			if ($ch)		{	$cmd +=" -ch $ch "		}
			if ($count)		{	$cmd +=" -count $count "}		
		}
	elseif( $diag)
		{	$cmd="checkpd diag "
			if ($path)		{	$cmd +=" -path $path "		}		
			if ($test)		{	$cmd +=" -test $test "		}
			if ($iosize)	{	$cmd +=" -iosize $iosize "	}
			if ($range )	{	$cmd +=" -range $range "	}
			if ($threads)	{	$cmd +=" -threads $threads "}
			if ($time )		{	$cmd +=" -time $time "		}
			if ($total )	{	$cmd +=" -total $total "	}
			if ($retry )	{	$cmd +=" -retry $retry "	}
		}	
	$cmd += " $pd_ID "
	$Result = Invoke-CLICommand -cmds  $cmd	
	return $Result	
} 
}
