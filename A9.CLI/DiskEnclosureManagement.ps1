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
.NOTES
	This command requires a SSH type connection.
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
	$Result = Invoke-A9CLICommand -cmds  $cmd
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
.NOTES
	This command requires a SSH type connection.
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
			$Result2 = Invoke-A9CLICommand -cmds  $cmd2
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
	$Result = Invoke-A9CLICommand -cmds  $cmd	
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
.NOTES
	This command requires a SSH type connection.
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
	$Result = Invoke-A9CLICommand -cmds  $cmd
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
.NOTES
	This command requires a SSH type connection.
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
			$Result = Invoke-A9CLICommand -cmds  $cmd
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
			$Result1 = Invoke-A9CLICommand -cmds  $pdd	
			if($Result1 -match "No PDs listed" )
				{	return " FAILURE : $PD_ID is not available id pLease try using only [Show-PD] to get the list of PD_ID Available. "			
				}
			else{	$cmd+=" $PD_ID "
				}
		}	
	$Result = Invoke-A9CLICommand -cmds  $cmd
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
.NOTES
	This command requires a SSH type connection.
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
	$Result = Invoke-A9CLICommand -cmds  $Cmd
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
.NOTES
	This command requires a SSH type connection.
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
			$Result2 = Invoke-A9CLICommand -cmds  $cmd2
			if($Result2 -match $PSModel)	{	$cmd+=" ps $PSModel "	}	
			else{	return "Failure: -PSModel $PSModel is Not available. To Find Available Model `n Try  [Get-Cage -option d ] Command"
				}
		}		
	if ($CageName)
		{	$cmd1="showcage"
			$Result1 = Invoke-A9CLICommand -cmds  $cmd1
			if($Result1 -match $CageName)	{	$cmd +="$CageName "	}
			else{	return "Failure:  -CageName $CageName is Not available `n Try using [ Get-Cage ] Command to get list of Cage Name "
				}	
		}	
	else
		{	return "ERROR: -CageName is a required parameter"
		}		
	$Result = Invoke-A9CLICommand -cmds  $cmd
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
.NOTES
	This command requires a SSH type connection.
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
	$Result = Invoke-A9CLICommand -cmds  $cmd
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
.NOTES
	This command requires a SSH type connection.
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
	$Result = Invoke-A9CLICommand -cmds  $Cmd
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
.NOTES
	This command requires a SSH type connection.
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
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	return $Result	
} 
}

# SIG # Begin signature block
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAogIEJ5S2Q
# Kff8uT9lWcHvegc0Z7VVu7f33WC9FImDAJXPfsphSZPo3GeI3+JEK9GOjxbw6w8c
# sIcv2+FAFU5voIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
# KoZIhvcNAQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExp
# bWl0ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0yMTA1
# MjUwMDAwMDBaFw0yODEyMzEyMzU5NTlaMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AI3nlBIiBCR0Lv8WIwKSirauNoWsR9QjkSs+3H3iMaBRb6yEkeNSirXilt7Qh2Mk
# iYr/7xKTO327toq9vQV/J5trZdOlDGmxvEk5mvFtbqrkoIMn2poNK1DpS1uzuGQ2
# pH5KPalxq2Gzc7M8Cwzv2zNX5b40N+OXG139HxI9ggN25vs/ZtKUMWn6bbM0rMF6
# eNySUPJkx6otBKvDaurgL6en3G7X6P/aIatAv7nuDZ7G2Z6Z78beH6kMdrMnIKHW
# uv2A5wHS7+uCKZVwjf+7Fc/+0Q82oi5PMpB0RmtHNRN3BTNPYy64LeG/ZacEaxjY
# cfrMCPJtiZkQsa3bPizkqhiwxgcBdWfebeljYx42f2mJvqpFPm5aX4+hW8udMIYw
# 6AOzQMYNDzjNZ6hTiPq4MGX6b8fnHbGDdGk+rMRoO7HmZzOatgjggAVIQO72gmRG
# qPVzsAaV8mxln79VWxycVxrHeEZ8cKqUG4IXrIfptskOgRxA1hYXKfxcnBgr6kX1
# 773VZ08oXgXukEx658b00Pz6zT4yRhMgNooE6reqB0acDZM6CWaZWFwpo7kMpjA4
# PNBGNjV8nLruw9X5Cnb6fgUbQMqSNenVetG1fwCuqZCqxX8BnBCxFvzMbhjcb2L+
# plCnuHu4nRU//iAMdcgiWhOVGZAA6RrVwobx447sX/TlAgMBAAGjggESMIIBDjAf
# BgNVHSMEGDAWgBSgEQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUMuuSmv81
# lkgvKEBCcCA2kVwXheYwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEE
# ATBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFD
# ZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAQEA
# Er+h74t0mphEuGlGtaskCgykime4OoG/RYp9UgeojR9OIYU5o2teLSCGvxC4rnk7
# U820+9hEvgbZXGNn1EAWh0SGcirWMhX1EoPC+eFdEUBn9kIncsUj4gI4Gkwg4tsB
# 981GTyaifGbAUTa2iQJUx/xY+2wA7v6Ypi6VoQxTKR9v2BmmT573rAnqXYLGi6+A
# p72BSFKEMdoy7BXkpkw9bDlz1AuFOSDghRpo4adIOKnRNiV3wY0ZFsWITGZ9L2PO
# mOhp36w8qF2dyRxbrtjzL3TPuH7214OdEZZimq5FE9p/3Ef738NSn+YGVemdjPI6
# YlG87CQPKdRYgITkRXta2DCCBeEwggRJoAMCAQICEQCZcNC3tMFYljiPBfASsES3
# MA0GCSqGSIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBD
# QSBSMzYwHhcNMjIwNjA3MDAwMDAwWhcNMjUwNjA2MjM1OTU5WjB3MQswCQYDVQQG
# EwJVUzEOMAwGA1UECAwFVGV4YXMxKzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBF
# bnRlcnByaXNlIENvbXBhbnkxKzApBgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRl
# cnByaXNlIENvbXBhbnkwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCi
# DYlhh47xvo+K16MkvHuwo3XZEL+eEWw4MQEoV7qsa3zqMx1kHryPNwVuZ6bAJ5OY
# oNch6usNWr9MZlcgck0OXnRGrxl2FNNKOqb8TAaoxfrhBSG7eZ1FWNqxJAOlzXjg
# 6KEPNdlhmfVvsSDolVDGr6yEXYK9WVhVtEApyLbSZKLED/0OtRp4CtjacOCF/unb
# vfPZ9KyMVKrCN684Q6BpknKH3ooTZHelvfAzUGbHxfKvq5HnIpONKgFhbpdZXKN7
# kynNjRm/wrzfFlp+m9XANlmDnXieTeKEeI3y3cVxvw9HTGm4yIFt8IS/iiZwsKX6
# Y94RkaDzaGB1fZI19FnRo2Fx9ovz187imiMrpDTsj8Kryl4DMtX7a44c8vORYAWO
# B17CKHt52W+ngHBqEGFtce3KbcmIqAH3cJjZUNWrji8nCuqu2iL2Lq4bjcLMdjqU
# +2Uc00ncGfvP2VG2fY+bx78e47m8IQ2xfzPCEBd8iaVKaOS49ZE47/D9Z8sAVjcC
# AwEAAaOCAYkwggGFMB8GA1UdIwQYMBaAFA8qyyCHKLjsb0iuK1SmKaoXpM0MMB0G
# A1UdDgQWBBRtaOAY0ICfJkfK+mJD1LyzN0wLzjAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBKBgNVHSAEQzBBMDUGDCsG
# AQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQ
# UzAIBgZngQwBBAEwSQYDVR0fBEIwQDA+oDygOoY4aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQVIzNi5jcmwweQYIKwYBBQUH
# AQEEbTBrMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNydDAjBggrBgEFBQcwAYYXaHR0cDov
# L29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggGBACPwE9q/9ANM+zGO
# lq4SZg7qDpsDW09bDbdjyzAmxxJk2GhD35Md0IluPppla98zFjnuXWpVqakGk9vM
# KxiooQ9QVDrKYtx9+S8Qui21kT8Ekhrm+GYecVfkgi4ryyDGY/bWTGtX5Nb5G5Gp
# DZbv6wEuu3TXs6o531lN0xJSWpJmMQ/5Vx8C5ZwRgpELpK8kzeV4/RU5H9P07m8s
# W+cmLx085ndID/FN84WmBWYFUvueR5juEfibuX22EqEuuPBORtQsAERoz9jStyza
# gj6QxPG9C4ItZO5LT+EDcHH9ti6CzxexePIMtzkkVV9HXB6OUjgeu6MbNClduKY4
# qFiutdbVC8VPGncuH2xMxDtZ0+ip5swHvPt/cnrGPMcVSEr68cSlUU26Ln2u/03D
# eZ6b0R3IUdwWf4K/1X6NwOuifwL9gnTM0yKuN8cOwS5SliK9M1SWnF2Xf0/lhEfi
# VVeFlH3kZjp9SP7v2I6MPdI7xtep9THwDnNLptqeF79IYoqT3TCCBhowggQCoAMC
# AQICEGIdbQxSAZ47kHkVIIkhHAowDQYJKoZIhvcNAQEMBQAwVjELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAwMFoXDTM2
# MDMyMTIzNTk1OVowVDELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIENBIFIz
# NjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJsrnVP6NT+OYAZDasDP
# 9X/2yFNTGMjO02x+/FgHlRd5ZTMLER4ARkZsQ3hAyAKwktlQqFZOGP/I+rLSJJmF
# eRno+DYDY1UOAWKA4xjMHY4qF2p9YZWhhbeFpPb09JNqFiTCYy/Rv/zedt4QJuIx
# eFI61tqb7/foXT1/LW2wHyN79FXSYiTxcv+18Irpw+5gcTbXnDOsrSHVJYdPE9s+
# 5iRF2Q/TlnCZGZOcA7n9qudjzeN43OE/TpKF2dGq1mVXn37zK/4oiETkgsyqA5lg
# AQ0c1f1IkOb6rGnhWqkHcxX+HnfKXjVodTmmV52L2UIFsf0l4iQ0UgKJUc2RGarh
# OnG3B++OxR53LPys3J9AnL9o6zlviz5pzsgfrQH4lrtNUz4Qq/Va5MbBwuahTcWk
# 4UxuY+PynPjgw9nV/35gRAhC3L81B3/bIaBb659+Vxn9kT2jUztrkmep/aLb+4xJ
# bKZHyvahAEx2XKHafkeKtjiMqcUf/2BG935A591GsllvWwIDAQABo4IBZDCCAWAw
# HwYDVR0jBBgwFoAUMuuSmv81lkgvKEBCcCA2kVwXheYwHQYDVR0OBBYEFA8qyyCH
# KLjsb0iuK1SmKaoXpM0MMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYEVR0gADAIBgZn
# gQwBBAEwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRv
# MG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAG/4Lhd2M2bnuhFSCb
# E/8E/ph1RGHDVpVx0ZE/haHrQECxyNbgcv2FymQ5PPmNS6Dah66dtgCjBsULYAor
# 5wxxcgEPRl05pZOzI3IEGwwsepp+8iGsLKaVpL3z5CmgELIqmk/Q5zFgR1TSGmxq
# oEEhk60FqONzDn7D8p4W89h8sX+V1imaUb693TGqWp3T32IKGfIgy9jkd7GM7YCa
# 2xulWfQ6E1xZtYNEX/ewGnp9ZeHPsNwwviJMBZL4xVd40uPWUnOJUoSiugaz0yWL
# ODRtQxs5qU6E58KKmfHwJotl5WZ7nIQuDT0mWjwEx7zSM7fs9Tx6N+Q/3+49qTtU
# vAQsrEAxwmzOTJ6Jp6uWmHCgrHW4dHM3ITpvG5Ipy62KyqYovk5O6cC+040Si15K
# JpuQ9VJnbPvqYqfMB9nEKX/d2rd1Q3DiuDexMKCCQdJGpOqUsxLuCOuFOoGbO7Uv
# 3RjUpY39jkkp0a+yls6tN85fJe+Y8voTnbPU1knpy24wUFBkfenBa+pRFHwCBB1Q
# tS+vGNRhsceP3kSPNrrfN2sRzFYsNfrFaWz8YOdU254qNZQfd9O/VjxZ2Gjr3xgA
# NHtM3HxfzPYF6/pKK8EE4dj66qKKtm2DTL1KFCg/OYJyfrdLJq1q2/HXntgr2GVw
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5UwghuRAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQJiskjAd+Mnxvwu5Mh/LE0FDmzv76gpfBE6uwpEoqKpq9BEslmkRT9cc
# T3etr0V+OMUVx+HmPu031XtY8raaKWUwDQYJKoZIhvcNAQEBBQAEggGAUYofxsFX
# WSoYlzf5zb9/xHxuYrm/BYAaxAVKUhl+zu6aPFblRqDsSNKKVj6m3GBo7FH+8JZH
# PQG4fpfhNuGP8pvBsQ52KGfcaRUZwrxWWne0EXj1xQ1Vqjo2hHly5VsyhviRQCF/
# itE+FTA9p+IekE3oaJMk9S4wEj61sz4GJ5seBpJq8BvdtTgQaH7aBJkwIugnNy+l
# xPtfl9oS0Z6FWEXVp+i+G3tfTItyODKbXlpuMWHgVXouFsBEcOWegVZ8KXdbZ/0T
# ax9wnxXqo7320nHRCNWOcqwRMESau7Gx2wMTh4EXey4FM0ghVvW71SyIv1Apx33m
# yItwOx6Hblil+yMm3iAhtJCaOtO9vjqCyEgyqV02sYuNoHuJ7CnLUjPELlQBFAh1
# /kQmdEqyhS7wqfTeYo+OWNtRSiCaPXZqizjvsZOLJ4LfzIBW8vvUrtF1PX9FehWO
# H44ygbto6RbCUCjYgx5pLozJZCAUPLtf4k0aDz7enZLJn2nqVc9VzaZdoYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMPkLKEMn4MH+K+7nm0JD1Idd+RhPQkxQ
# T+IOJaAV/ehWnf9wyDa8dfUNuoTd2LD8lAIUDs+E4eX8gwg32N0HdwUi927arHMY
# DzIwMjQwNzMxMTkxOTQyWqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
# bmNoZXN0ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2Vj
# dGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1oIIS/zCCBl0wggTF
# oAMCAQICEDpSaiyEzlXmHWX8zBLY6YkwDQYJKoZIhvcNAQEMBQAwVTELMAkGA1UE
# BhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGln
# byBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjQwMTE1MDAwMDAwWhcN
# MzUwNDE0MjM1OTU5WjBuMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFuY2hlc3Rl
# cjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydTZWN0aWdvIFB1
# YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzUwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN0Wf0wUibvf04STpNYYGbw9jcRaVhBDaNBp7jmJaA9dQZ
# W5ighrXGNMYjK7Dey5RIHMqLIbT9z9if753mYbojJrKWO4ZP0N5dBT2TwZZaPb8E
# +hqaDZ8Vy2c+x1NiEwbEzTrPX4W3QFq/zJvDDbWKL99qLL42GJQzX3n5wWo60Kkl
# fFn+Wb22mOZWYSqkCVGl8aYuE12SqIS4MVO4PUaxXeO+4+48YpQlNqbc/ndTgszR
# QLF4MjxDPjRDD1M9qvpLTZcTGVzxfViyIToRNxPP6DUiZDU6oXARrGwyP9aglPXw
# YbkqI2dLuf9fiIzBugCDciOly8TPDgBkJmjAfILNiGcVEzg+40xUdhxNcaC+6r0j
# uPiR7bzXHh7v/3RnlZuT3ZGstxLfmE7fRMAFwbHdDz5gtHLqjSTXDiNF58IxPtvm
# ZPG2rlc+Yq+2B8+5pY+QZn+1vEifI0MDtiA6BxxQuOnj4PnqDaK7NEKwtD1pzoA3
# jJFuoJiwbatwhDkg1PIjYnMDbDW+wAc9FtRN6pUsO405jaBgigoFZCw9hWjLNqgF
# VTo7lMb5rVjJ9aSBVVL2dcqzyFW2LdWk5Xdp65oeeOALod7YIIMv1pbqC15R7QCY
# LxcK1bCl4/HpBbdE5mjy9JR70BHuYx27n4XNOZbwrXcG3wZf9gEUk7stbPAoBQID
# AQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNhlxmiMpswHQYD
# VR0OBBYEFGjvpDJJabZSOB3qQzks9BRqngyFMA4GA1UdDwEB/wQEAwIGwDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1UdIARDMEEwNQYM
# KwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20v
# Q1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8vY3JsLnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcmwwegYIKwYB
# BQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYBBQUHMAGGF2h0
# dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IBgQCw3C7J+k82
# TIov9slP1e8YTx+fDsa//hJ62Y6SMr2E89rv82y/n8we5W6z5pfBEWozlW7nWp+s
# dPCdUTFw/YQcqvshH6b9Rvs9qZp5Z+V7nHwPTH8yzKwgKzTTG1I1XEXLAK9fHnmX
# paDeVeI8K6Lw3iznWZdLQe3zl+Rejdq5l2jU7iUfMkthfhFmi+VVYPkR/BXpV7Ub
# 1QyyWebqkjSHJHRmv3lBYbQyk08/S7TlIeOr9iQ+UN57fJg4QI0yqdn6PyiehS1n
# SgLwKRs46T8A6hXiSn/pCXaASnds0LsM5OVoKYfbgOOlWCvKfwUySWoSgrhncihS
# BXxH2pAuDV2vr8GOCEaePZc0Dy6O1rYnKjGmqm/IRNkJghSMizr1iIOPN+23futB
# XAhmx8Ji/4NTmyH9K0UvXHiuA2Pa3wZxxR9r9XeIUVb2V8glZay+2ULlc445CzCv
# VSZV01ZB6bgvCuUuBx079gCcepjnZDCcEuIC5Se4F6yFaZ8RvmiJ4hgwggYUMIID
# /KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUAMFcxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEwMzIyMDAwMDAw
# WhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAM2Y2ENBq26C
# K+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStSVjeYXIjfa3aj
# oW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQBaCxpectRGhh
# nOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE9cbY11XxM2AV
# Zn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExSLnh+va8WxTlA
# +uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OIIq/fWlwBp6KNL
# 19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGdF+z+Gyn9/CRe
# zKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w76kOLIaFVhf5
# sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4CllgrwIDAQABo4IB
# XDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUwHQYDVR0OBBYE
# FF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8E
# CDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0g
# ADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEFBQcBAQRwMG4w
# RwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1Ymxp
# Y1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2Nz
# cC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0ONVgMnoEdJVj9
# TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc6ZvIyHI5UkPC
# bXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1OSkkSivt51Ul
# mJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz2wSKr+nDO+Db
# 8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y4Il6ajTqV2if
# ikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVMCMPY2752LmES
# sRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBeNh9AQO1gQrnh
# 1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupiaAeNHe0pWSGH2
# opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU+CCQaL0cJqlm
# nx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/SjwsusWRItFA3DE8
# MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7xpMeYRriWklU
# PsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs656Oz3TbLyXVo
# MA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEpl
# cnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJV
# U1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9u
# IEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMFcxCzAJ
# BgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJBZvMWhUP2ZQQ
# RLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQnOh2qmcxGzjqe
# mIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypoGJrruH/drCio
# 28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0pKG9ki+PC6VEf
# zutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13jQEV1JnUTCm51
# 1n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9YrcmXcLgsrAi
# mfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/yVl4jnDcw6ULJ
# sBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVgh60KmLmzXiqJ
# c6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/OLoanEWP6Y52
# Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+NrLedIxsE88WzK
# XqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58NHs57ZPUfECcg
# JC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rID
# ZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1UdDwEB/wQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVz
# dC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwNQYI
# KwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3Qu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3OyWM637ayBeR
# 7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJJlFfym1Doi+4
# PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0mUGQHbRcF57ol
# pfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTwbD/zIExAopoe
# 3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i111TW7HV1Ats
# Qa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGezjM6CRpcWed/
# ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+8aW88WThRpv8
# lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH29308ZkpKKdp
# kiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrsxrYJD+3f3aKg
# 6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6Ii8+CQOYDwXM
# +yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz7NgAnOgpCdUo
# 4uDyllU9PzGCBJEwggSNAgEBMGkwVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1Nl
# Y3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFt
# cGluZyBDQSBSMzYCEDpSaiyEzlXmHWX8zBLY6YkwDQYJYIZIAWUDBAICBQCgggH5
# MBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQw
# NzMxMTkxOTQyWjA/BgkqhkiG9w0BCQQxMgQwW1TnP+IE7fN1nbpiSoJGgljNJv+Y
# zQLto8iQIQzEB5SJhIyFW3d5oRQeKSeyQskGMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgBiiYHS
# PUOAUt2BHCkELdVLPLATBG1HZaFAS3Y5pdev1zABiPfC7lmVavWGBt2gwgwRKvx/
# Rb7DrvfgXtwGFfeNjrdY+MQterJqXMhjXcKjT8RoRh4f0wMckihMtB7R3xVAOaqs
# pKSYkArfP0NVZz90YXTXI0WJ4750oEGNJOUzlTHwI8kiSXsTUjEI0pRmXixtpLmA
# oK+BeY/dm9qkNJ3cDiArPUDaPhwZjJBmbq3NERqUdGcVlWE3ZTGJYfji//Fg3YRN
# i9St96n9s4kgL6earCs/iRSTh5k7KqMh/g3ZDRa83yuUB6AM9xVf108mYC3qKAlD
# IZlndnYUhus5qFlQfjtDSQyRRzuFKrG6Qt3IGwWjxYxHaroBdgFzoqCels5W/GFH
# VF5ts7N1f0FirA2GlJ7QUb8c7ifV8Y7xlmRDDNbtkH823lmZCcu56DaBza5aFa+4
# Q9LvxtNs30o8hE1Fsn9O9X7ED3gOofxu7l3LNnO6QcjopbRSprgWPzMzvwFbsfOC
# FzUPkFvbh22m1Z/2bCtlwYf33uDY3hJ2k+n7GH86EhVECFpue5+99gpTOtRul0lo
# sX7CaM9NCi6bpsx12c1zzxRjkALNvaoCT0kx3nl7fB4q8R2sE3nr74W+B57P3eN3
# sOW6xH+FCkUs2JIDD6nnffQs+/1VMWGGa/8JWg==
# SIG # End signature block
