####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Find-A9Node
{
<#
.SYNOPSIS
	Locate a node by blinking its LEDs.
.DESCRIPTION
	The command helps locate a particular node or its components by illuminating LEDs on the node.
.PARAMETER T
	Specifies the number of seconds to illuminate the LEDs. For HPE 3PAR 7000 and HPE 3PAR 8000 storage systems, the default time to illuminate the LEDs is 15
	minutes with a maximum time of one hour. For STR (Safe to Remove) systems, the default time is one hour with a maximum time of one week. For all
	other systems, the default time is 60 seconds with a maximum time of 255 seconds. Issuing "Find-Node -t 0 <nodeid>" will turn off LEDs immediately.
.PARAMETER Ps
	Only the service LED for the specified power supply will blink. Accepted values for <psid> are 0 and 1.
.PARAMETER Pci
	Only the service LED corresponding to the PCI card in the specified slot will blink. Accepted values for <slot> are 0 through 8.
.PARAMETER Fan
	Only the service LED on the specified node fan module will blink. Accepted values for <fanid> are 0 and 1 for HPE 3PAR 10000 systems.
	Accepted values for <fanid> are 0, 1 and 2 for HPE 3PAR 20000 systems.
.PARAMETER Drive
	Only the service LED corresponding to the node's internal drive will blink.
.PARAMETER Bat
	Only the service LED on the battery backup unit will blink.
.PARAMETER NodeID
	Indicates which node the locatenode operation will act on. Accepted
	values are 0 through 7.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$T,
		[Parameter()]	[String]	$Ps,
		[Parameter()]	[String]	$Pci,
		[Parameter()]	[String]	$Fan,
		[Parameter()]	[switch]	$Drive,
		[Parameter()]	[switch]	$Bat,
		[Parameter()]	[String]	$NodeID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " locatenode "
	if($T)	{	$Cmd += " -t $T " }
	if($Ps)		{	$Cmd += " -ps $Ps " 	}
	if($Pci) 	{	$Cmd += " -pci $Pci " 	}
	if($Fan)	{	$Cmd += " -fan $Fan " 	}
	if($Drive)	{	$Cmd += " -drive " 		}
	if($Bat)	{	$Cmd += " -bat " 		}
	if($NodeID) {	$Cmd += " $NodeID " 	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Find-A9System
{
<#
.SYNOPSIS
    Locate a system by illuminating or blinking its LEDs.
.DESCRIPTION
    The command helps locate a storage system by illuminating the blue UID LEDs or by alternating the node status LEDs amber and green on all
    nodes of the storage system. By default, the LEDs in all connected cages will illuminate blue or will oscillate green and amber, depending on the system or cage model.
.PARAMETER T
	Specifies the number of seconds to illuminate or blink the LEDs. default may vary depending on the system model. For example, the default time 
	for HPE 3PAR 7000 and HPE 3PAR 8000 storage systems is 15 minutes, with a maximum time of one hour. The default time for 9000 and 20000 systems 
	is 60 minutes, with a maximum of 604,800 seconds (one week).
.PARAMETER NodeList
	Specifies a comma-separated list of nodes on which to illuminate or blink LEDs. The default is all nodes.
.PARAMETER NoCage
	Specifies that LEDs on the drive cages should not illuminate or blink. The default is to illuminate or blink LEDs for all cages in the system.
.EXAMPLE
	In the following example, a storage system is identified by illuminating or blinking the LEDs on all drive cages in the system for 90 seconds. 
	
	PS:> Find-A9System_CLI -T 90
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$T,
		[Parameter()]	[String]	$NodeList,
		[Parameter()]	[switch]	$NoCage
)
Begin
{	Test-A9Connection -CLientType 'SshClient'
}
process
{	$Cmd = " locatesys "
	if($T) 			{	$Cmd += " -t $T " }
	if($NodeList) 	{	$Cmd += " -nodes $NodeList " }
	if($NoCage)		{	$Cmd += " -nocage " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9System_CLI
{
<#
.SYNOPSIS
    Displays the Storage system information. 
.DESCRIPTION
    Command displays the Storage system information.
.EXAMPLE
    PS:> Get-A9System_CLI 

	Command displays the Storage system information.such as system name, model, serial number, and system capacity information.
.EXAMPLE
    PS:> Get-A9System_CLI -SystemCapacity

	Lists Storage system space information in MB(1024^2 bytes)
.EXAMPLE	
	PS:> Get-A9System_CLI -DevType FC
.PARAMETER Detailed
	Specifies that more detailed information about the system is displayed.
.PARAMETER SystemParameters
	Specifies that the system parameters are displayed.
.PARAMETER Fan
	Displays the system fan information.
.PARAMETER SystemCapacity
	Displays the system capacity information in MiB.
.PARAMETER vvSpace
	Displays the system capacity information in MiB with an emphasis on VVs.
.PARAMETER Domainspace
	Displays the system capacity information broken down by domain in MiB.
.PARAMETER Descriptor
	Displays the system descriptor properties.
.PARAMETER DevType FC|NL|SSD
	Displays the system capacity information where the disks must have a device type string matching the specified device type; either Fast
	Class (FC), Nearline (NL), Solid State Drive (SSD). This option can only be issued with -space or -vvspace.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	
        [Parameter()]	[switch]    $Detailed,
        [Parameter()]   [switch]    $SystemParameters,
        [Parameter()]   [switch]    $Fan,
        [Parameter()]   [switch]    $SystemCapacity,
        [Parameter()]   [switch]    $vvSpace,
        [Parameter()]   [switch]    $DomainSpace,
        [Parameter()]   [switch]    $Descriptor,
        [Parameter()]   [String]    $DevType
    )
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$sysinfocmd = "showsys "
    if ($Detailed) 			{    $sysinfocmd += " -d " 		}
    if ($SystemParameters) 	{    $sysinfocmd += " -param "	}
    if ($Fan) 				{    $sysinfocmd += " -fan "	}
    if ($SystemCapacity) 	{    $sysinfocmd += " -space " 	}
    if ($vvSpace) 			{    $sysinfocmd += " -vvspace "}
    if ($DomainSpace) 		{    $sysinfocmd += " -domainspace "}
    if ($Descriptor) 		{	$sysinfocmd += " -desc "	}
    if ($DevType) 			{    $sysinfocmd += " -devtype $DevType"}
    write-verbose "Get system information " 
    $Result3 = Invoke-A9CLICommand -cmds  $sysinfocmd	
    if ($Fan -or $DomainSpace -or $sysinfocmd -eq "showsys ") 
		{	$incre = "True"
			$FirstCnt = 1
			$rCount = $Result3.Count
			$noOfColumns = 0        
			if ($Fan) {		$FirstCnt = 0 }
			if ($DomainSpace) {    $rCount = $Result3.Count - 3   }
			$tempFile = [IO.Path]::GetTempFileName()
			if ($Result3.Count -gt 1) 
				{	foreach ($s in  $Result3[$FirstCnt..$rCount] ) 
						{	$s = [regex]::Replace($s, "^ +", "")
							if (!$DomainSpace) {    $s = [regex]::Replace($s, "-", "")    }				
							$s = [regex]::Replace($s, " +", ",")
							if ($noOfColumns -eq 0) 
								{    $noOfColumns = $s.Split(",").Count;    }
							else{	$noOfValues = $s.Split(",").Count;
									if ($noOfValues -ge $noOfColumns) 
										{  	[System.Collections.ArrayList]$CharArray1 = $s.Split(",");
											if ($noOfValues -eq 12) 
												{	$CharArray1[2] = $CharArray1[2] + " " + $CharArray1[3];
													$CharArray1.RemoveAt(3);
													$s = $CharArray1 -join ',';
												}
											elseif ($noOfValues -eq 13) 
												{	$CharArray1[2] = $CharArray1[2] + " " + $CharArray1[3] + " " + $CharArray1[4];
													$CharArray1.RemoveAt(4);
													$CharArray1.RemoveAt(3);
													$s = $CharArray1 -join ',';
												}
										}
								}
							if ($DomainSpace) 
								{	if ($incre -eq "True") 
										{	$sTemp = $s.Split(',')											
											$sTemp[1] = "Used_Legacy(MiB)"				
											$sTemp[2] = "Snp_Legacy(MiB)"
											$sTemp[3] = "Base_Private(MiB)"				
											$sTemp[4] = "Snp_Private(MiB)"
											$sTemp[5] = "Shared_CPG(MiB)"				
											$sTemp[6] = "Free_CPG(MiB)"
											$sTemp[7] = "Unmapped(MiB)"	
											$sTemp[8] = "Total(MiB)"
											$sTemp[9] = "Compact_Efficiency"
											$sTemp[10] = "Dedup_Efficiency"
											$sTemp[11] = "Compress_Efficiency"
											$sTemp[12] = "DataReduce_Efficiency"
											$sTemp[13] = "Overprov_Efficiency"
											$newTemp = [regex]::Replace($sTemp, "^ ", "")			
											$newTemp = [regex]::Replace($sTemp, " ", ",")				
											$newTemp = $newTemp.Trim()
											$s = $newTemp							
										}
								}				
							Add-Content -Path $tempFile -Value $s				
							$incre = "False"
						}
					Import-Csv $tempFile			
					Remove-Item $tempFile
				}
			else{	Remove-Item $tempFile
					return	$Result3			
				}
		}		
    else{    return	$Result3    }	
}
}

Function Ping-A9RCIPPorts
{
<#
.SYNOPSIS
	Verifying That the Servers Are Connected
.DESCRIPTION
	Verifying That the Servers Are Connected.
.EXAMPLE	
	PS:> Ping-A9RCIPPorts -IP_address 192.168.245.5 -NSP 0:3:1
.EXAMPLE
	PS:> Ping-A9RCIPPorts -count 2 -IP_address 192.168.245.5 -NSP 0:3:1
.EXAMPLE
	PS:> Ping-A9RCIPPorts -wait 2 -IP_address 192.168.245.5 -NSP 0:3:1
.EXAMPLE
	PS:> Ping-A9RCIPPorts -size 2 -IP_address 192.168.245.5 -NSP 0:3:1
.EXAMPLE
	PS:> Ping-A9RCIPPorts -PF -IP_address 192.168.245.5 -NSP 0:3:1
.PARAMETER IP_address
	IP address on the secondary system to ping
.PARAMETER NSP
	Interface from which to ping, expressed as node:slot:port	
.PARAMETER pf
	Prevents packet fragmentation. This option can only be used with the
	rcip ping subcommand.
.PARAMETER size 
	Specifies the packet size. If no size is specified, the option defaults
	to 64. This option can only be used with the rcip ping subcommand.
.PARAMETER wait
	Specifies the maximum amount of time to wait for replies. The default is
	the number of requested replies plus 5. The maximum value is 30. This
	option can only be used with the rcip ping subcommand.
.PARAMETER count
	Specifies the number of replies accepted by the system before
	terminating the command. The default is 1; the maximum value is 25.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
Param(		[Parameter(Mandatory=$true)]	[System.IPAddress]	$IP_address,
			[Parameter(Mandatory=$true)]	[String]	$NSP,
			[Parameter()]					[String]	$count,
			[Parameter()]					[String]	$wait,
			[Parameter()]					[String]	$size,
			[Parameter()]					[switch]	$PF
	)
Begin
{	Test-A9Connection -ClientType "SshClient"
}	
process
{	$Cmds="controlport rcip ping "
	if($count)	{	$Cmds +=" -c $count "	}
	if($wait)	{	$Cmds +=" -w $wait "	}
	if($size)	{	$Cmds +=" -s $size "	}
	if($PF)		{	$Cmds +=" -pf"	}
	$Cmds +=" $IP_address "	
	$Cmds +=" $NSP "
	$result = Invoke-A9CLICommand  -cmds $Cmds	
	return $result	
}
}

Function Set-A9Battery
{
<#
.SYNOPSIS
	Set a battery's serial number, expiration date, reset test logs or reset recharge time.
.DESCRIPTION
	The command may be used to set battery information such as the battery's expiration date, its recharging 
	time, and its serial number. This information gives the system administrator a record or log of the battery age and battery charge status.
.EXAMPLE
	The following example resets the battery test log and the recharging time
	for a newly installed battery on node 2, power supply 1, and battery 0, with
	an expiration date of July 4, 2006:
	
	PS:> Set-A9Battery -X " 07/04/2006" -Node_ID 2 -Powersupply_ID 1 -Battery_ID 0	
.PARAMETER S
	Specifies the serial number of the battery using a limit of 31 alphanumeric characters.
	This option is not supported on HPE 3PAR 10000 and 20000 systems.
.PARAMETER X	
	Specifies the expiration date of the battery (mm/dd/yyyy). The expiration date cannot extend beyond 2037.
.PARAMETER L
	Specifies that the battery test log is reset and all previous test log entries are cleared.
.PARAMETER R
	Specifies that the battery recharge time is reset and that 10 hours of charging time are required for the battery to be fully charged. This option is deprecated.
.PARAMETER Node_ID
	Specifies the node number where the battery is installed. Node_ID is an integer from 0 through 7.
.PARAMETER Powersupply_ID
	Specifies the power supply number on the node using either 0 (left side from the rear of the node) or 1 (right side from the rear of the node).
.PARAMETER Battery_ID
	Specifies the battery number on the power supply where 0 is the first battery.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]					[String]	$S,
	[Parameter()]					[String]	$X,
	[Parameter()]					[switch]	$L,
	[Parameter()]					[switch]	$R,
	[Parameter()]					[String]	$Node_ID,
	[Parameter(Mandatory=$True)]	[String]	$Powersupply_ID,
	[Parameter()]					[String]	$Battery_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{	$Cmd = " setbattery "
	if($S)				{	$Cmd += " -s $S "}
	if($X)				{	$Cmd += " -x $X " }
	if($L)				{	$Cmd += " -l " }
	if($R)				{	$Cmd += " -r " }
	if($Node_ID)		{	$Cmd += " $Node_ID "	}
	if($Powersupply_ID)	{	$Cmd += " $Powersupply_ID "}
	if($Battery_ID)		{	$Cmd += " $Battery_ID "}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Set-A9FCPorts
{
<#
.SYNOPSIS
	Configure FC ports
.DESCRIPTION
	Configure FC ports
.PARAMETER Port
	Use syntax N:S:P
.PARAMETER DirectConnect
	If present, configure port for a direct connection to a host By default, the port is configured as fabric attached
.EXAMPLE
	PS:> Set-A9FCPorts -Ports 1:2:1
	
	Configure port 1:2:1 as Fibre Channel connected to a fabric
.EXAMPLE
	PS:> Set-A9FCPorts -Ports 1:2:1 -DirectConnect
	
	Configure port 1:2:1 as Fibre Channel connected to host ( no SAN fabric)
.EXAMPLE		
	PS:> Set-A9FCPorts -Ports 1:2:1,1:2:2 
	
	Configure ports 1:2:1 and 1:2:2 as Fibre Channel connected to a fabric 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
Param(	[Parameter()][ValidatePattern("^\d:\d:\d")]	
						[String[]]	$Ports,
		[Parameter()]	[Switch]	$DirectConnect,
		[Parameter()]	[Switch]	$Demo
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	foreach ($P in $Ports)
		{	Write-Verbose  "Set port $p offline " 
			$Cmds = "controlport offline -f $p"
			Invoke-A9CLICommand -cmds $Cmds
			$PortConfig = "point"
			$PortMsg    = "Fabric ( Point mode)"
			if ($DirectConnect)
				{	$PortConfig = "loop"
					$PortMsg    = "Direct connection ( loop mode)"
				}
			Write-Verbose  "Configuring port $p as $PortMsg " 
			$Cmds= "controlport config host -ct $PortConfig -f $p"
			Invoke-A9CLICommand -cmds $Cmds
			Write-Verbose  "Resetting port $p " 
			$Cmds="controlport rst -f $p"
			Invoke-A9CLICommand -cmds $Cmds	
			Write-Verbose  "FC port $P is configured" 
			return 
		}
}
} 

Function Set-A9HostPorts
{
<#
.SYNOPSIS
	Configure settings of the array
.DESCRIPTION
	Configures with settings specified in the text file
.EXAMPLE
	PS:> Set-A9HostPorts -FCConfigFile FC-Nodes.CSV

	Configures all FC host controllers on array
.EXAMPLE	
	PS:> Set-A9HostPorts -iSCSIConfigFile iSCSI-Nodes.CSV

	Configures all iSCSI host controllers on array
.EXAMPLE
	PS:> Set-A9HostPorts -LDConfigFile LogicalDisks.CSV

	Configures logical disks on array
.EXAMPLE	
	PS:> Set-A9HostPorts -FCConfigFile FC-Nodes.CSV -iSCSIConfigFile iSCSI-Nodes.CSV -LDConfigFile LogicalDisks.CSV

	Configures FC, iSCSI host controllers and logical disks on array
.EXAMPLE	
	PS:> Set-A9HostPorts -RCIPConfiguration -Port_IP 0.0.0.0 -NetMask xyz -NSP 1:2:3> for rcip port
.EXAMPLE	
	PS:> Set-A9HostPorts -RCFCConfiguration -NSP 1:2:3>
	
	For RCFC port  
.PARAMETER FCConfigFile
	Specify the config file containing FC host controllers information
.PARAMETER iSCSIConfigFile
	Specify the config file containing iSCSI host controllers information
.PARAMETER LDConfigFile
	Specify the config file containing Logical Disks information
.PARAMETER Demo
	Switch to list the commands to be executed 
.PARAMETER RCIPConfiguration
	Go for  RCIP Configuration
.PARAMETER RCFCConfiguration
	Go for  RCFC Configuration
.PARAMETER Port_IP
	port ip address
.PARAMETER NetMask
	Net Mask Name
.PARAMETER NSP
	NSP Name 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
Param(		[Parameter()]	[String]	$FCConfigFile,
			[Parameter()]	[String]	$iSCSIConfigFile,		
			[Parameter()]	[String]	$LDConfigFile,
			[Parameter()]	[switch]	$RCIPConfiguration,
			[Parameter()]	[switch]	$RCFCConfiguration,
			[Parameter()]	[String]	$Port_IP,
			[Parameter()]	[String]	$NetMask,
			[Parameter()]	[String]	$NSP,
			[Parameter()]	[switch]	$Demo
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	if (!(($FCConfigFile) -or ($iSCSIConfigFile) -or ($LDConfigFile) -or ($RCIPConfiguration) -or ($RCFCConfiguration))) 
		{	return "FAILURE : No config file selected"
		}
	if ($RCIPConfiguration)
		{	$Cmds="controlport rcip addr -f "
			if($Port_IP)	{	$Cmds=" $Port_IP "	}
			else			{	return "port_IP required with RCIPConfiguration Option"	}
			if($NetMask)	{	$Cmds=" $NetMask "	}
			else			{	return "NetMask required with RCIPConfiguration Option"	}
			if($NSP)		{	$Cmds=" $NSP "		}
			else			{	return "NSP required with RCIPConfiguration Option"		}
			$result = Invoke-A9CLICommand -cmds $Cmds
			return $result
		}
	if ($RCFCConfiguration)
		{	$Cmds="controlport rcfc init -f "	
			if($NSP)	{	$Cmds=" $NSP "	}
			else		{	return "NSP required with RCFCConfiguration Option"	}
			$result = Invoke-A9CLICommand -cmds $Cmds
			return $result
		}
	if ($FCConfigFile)
		{	if ( -not (Test-Path -path $FCConfigFile)) 
				{	Write-Verbose  "Configuring FC hosts using configuration file $FCConfigFile" 
					$ListofFCPorts = Import-Csv $FCConfigFile
					foreach ( $p in $ListofFCPorts)
						{	$Port = $p.Controller 
							Write-Verbose  "Set port $Port offline " 
							$Cmds = "controlport offline -f $Port"
							Invoke-A9CLICommand -cmds $Cmds
							Write-Verbose  "Configuring port $Port as host " 
							$Cmds= "controlport config host -ct point -f $Port"
							Invoke-A9CLICommand -cmds $Cmds
							Write-Verbose  "Resetting port $Port " 
							$Cmds="controlport rst -f $Port"
							Invoke-A9CLICommand -cmds $Cmds
						}
				}	
			else
				{	Write-Verbose  "Can't find $FCConfigFile" 
				}	
		}
	# ---------------------------------------------------------------------
	#		iSCSI Config file here
	if ($iSCSIConfigFile)
		{	if ( -not (Test-Path -path $iSCSIConfigFile)) 
				{	Write-Verbose  "Configuring iSCSI hosts using configuration file $iSCSIConfigFile" 
					$ListofiSCSIPorts = Import-Csv $iSCSIConfigFile		
					foreach ( $p in $ListofiSCSIPorts)
						{	$Port 		= $p.Controller
							$bDHCP 		= $p.DHCP
							$IPAddr 	= $p.IPAddress
							$IPSubnet 	= $p.Subnet
							$IPgw 		= $p.Gateway		
							if ( $bDHCP -eq "Yes")	{ $bDHCP = $true }
							else					{ $bDHCP = $false }
							if ($bDHCP)
								{	Write-Verbose  "Enabling DHCP on port $Port " 
									$Cmds = "controliscsiport dhcp on -f $Port"
									Invoke-A9CLICommand -cmds $Cmds			
								}
							else
								{	Write-Verbose  "Setting IP address and subnet on port $Port " 
									$Cmds = "controliscsiport addr $IPAddr $IPSubnet -f $Port"
									Invoke-A9CLICommand -cmds $Cmds
									Write-Verbose  "Setting gateway on port $Port " 
									$Cmds = "controliscsiport gw $IPgw -f $Port"
									Invoke-A9CLICommand -cmds $Cmds
								}				
						}
				}	
			else
				{	return "FAILURE : Can't find $iSCSIConfigFile"
				}	
		}			
} 
}

Function Set-A9NodeProperties
{
<#
.SYNOPSIS
	set the properties of the node components.
.DESCRIPTION
	The command sets properties of the node components such as serial number of the power supply.
.EXAMPLE
	PS:> Set-A9NodeProperties -PS_ID 1 -S xxx -Node_ID 1
.PARAMETER S
	Specify the serial number. It is up to 8 characters in length.
.PARAMETER PS_ID
	Specifies the power supply ID.
.PARAMETER Node_ID
	Specifies the node ID.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param( 	[Parameter(Mandatory=$True)]	[String]	$PS_ID,
		[Parameter(Mandatory=$True)]	[String]	$S,
		[Parameter()]					[String]	$Node_ID	
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " setnode ps "
	if($PS_ID)		{	$Cmd += " $PS_ID "	}	
	if($S) 			{	$Cmd += " -s $S " 	} 
	if($Node_ID) 	{	$Cmd += " $Node_ID "}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Set-A9NodesDate
{
<#
.SYNOPSIS
	Sets date and time information.
.DESCRIPTION
	The command allows you to set the system time and date on all nodes.
.EXAMPLE
	The following example displays the timezones with the -tzlist option:
	
	PS:> Set-A9NodesDate -Tzlist
.EXAMPLE
	The following example narrows down the list to the required timezone of Etc:

	PS:> Set-A9NodesDate -Tzlist -TzGroup Etc
.EXAMPLE
	The following example shows the timezone being set:

	PS:> Set-A9NodesDate  -Tzlist -TzGroup "Etc/GMT"
.PARAMETER Tzlist
	Displays a timezone within a group, if a group is specified. If a group is not specified, displays a list of valid groups.
.PARAMETER TzGroup
	Displays a timezone within a group, if a group is specified. it alwase use with -Tzlist.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Tzlist,
		[Parameter()]	[String]	$TzGroup
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " setdate "
	if($Tzlist)
		{	$Cmd += " -tzlist "
			if($TzGroup) 	{	$Cmd += " $TzGroup " }
		}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Set-A9SysMgr
{
<#
.SYNOPSIS
	Set the system manager startup state.
.DESCRIPTION
	The command sets the system manager startup state.
.PARAMETER Wipe
	Requests that the specified system be started in the new system state. Warning: This option will result in the loss of data and configuration info.
.PARAMETER Tocgen
	Specifies that the system is to be started with the specified table of contents generation number.
.PARAMETER Force_iderecovery
	Specifies that the system starts the recovery process from the IDE disk even if all virtual volumes have not been started.
.PARAMETER Force_idewipe
	Specifies that the system wipes the IDE power fail partition. The system is shutdown and 
	restarted, during which time all logical disks and virtual volumes are checked.
.PARAMETER Export_vluns
	If the AutoExportAfterReboot option has been set to no, after a power failure or uncontrolled shutdown vluns will not be automatically
	exported, and host ports will be in a suspended state. This command will reexport the luns and enable the host ports after this happens.
.PARAMETER System_name
	Specifies the name of the system to be started, using up to 31 characters.
.PARAMETER Toc_gen_number
	Specifies the table of contents generation number for the system to start with.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Wipe,
		[Parameter()]	[switch]	$Tocgen,
		[Parameter()]	[switch]	$Force_iderecovery,
		[Parameter()]	[switch]	$Force_idewipe,
		[Parameter()]	[switch]	$Export_vluns,
		[Parameter()]	[String]	$System_name,
		[Parameter()]	[String]	$Toc_gen_number
)
Begin
{	test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " setsysmgr -f "
	if($Wipe)
		{	$Cmd += " wipe "
			if($System_name)	{	$Cmd += " $System_name " }
			else				{	Return "System_name is require with -Wipe option."	}
		}
	if($Tocgen) 	
		{	$Cmd += " tocgen "
			if($Toc_gen_number)	{	$Cmd += " $Toc_gen_number "	} 
		}
	if($Force_iderecovery) 	{	$Cmd += " force_iderecovery " 	} 
	if($Force_idewipe) 		{	$Cmd += " force_idewipe " 		}
	if($Export_vluns) 		{	$Cmd += " export_vluns " 		}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Show-A9Battery
{
<#
.SYNOPSIS
	Show battery status information.
.DESCRIPTION
	Displays battery status information such as serial number, expiration date and battery life, 
	which could be helpful in determining battery maintenance schedules.
.PARAMETER Listcols
	List the columns available to be shown with the -showcols option described below .
.PARAMETER Showcols
	Explicitly select the columns to be shown using a comma-separated list of column names.  
	For this option, the full column names are shown in the header.
.PARAMETER D
	Specifies that detailed battery information, including battery test information, serial numbers, and expiration dates, is displayed.
.PARAMETER Log
	Show battery test log information. This option is not supported on HPE 3PAR 7000 nor on HPE 3PAR 8000 series systems.
.PARAMETER I
	Show battery inventory information.
.PARAMETER State
	Show detailed battery state information.
.PARAMETER S
	This is the same as -state. This option is deprecated and will be removed in a future release.
.PARAMETER Svc
	Displays inventory information with HPE serial number, spare part etc. This option must be used with -i option and it is not supported on HPE 3PAR 10000 systems.
.PARAMETER Node_ID
	Displays the battery information for the specified node ID(s). This specifier is not required. Node_ID is an integer from 0 through 7.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[switch]	$Listcols,
	[Parameter()]	[String]	$Showcols,
	[Parameter()]	[switch]	$D,
	[Parameter()]	[switch]	$Log,
	[Parameter()]	[switch]	$I,
	[Parameter()]	[switch]	$State,
	[Parameter()]	[switch]	$Svc,
	[Parameter()]	[String]	$Node_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showbattery "
	if($Listcols)
		{	$Cmd += " -listcols "
			$Result = Invoke-A9CLICommand -cmds  $Cmd
			return $Result
		}
	if($Showcols)	{	$Cmd += " -showcols $Showcols "}
	if($D)			{	$Cmd += " -d " 		}
	if($Log)		{	$Cmd += " -log "	}
	if($I)			{	$Cmd += " -i "		}
	if($State)		{	$Cmd += " -state "	}
	if($Svc)		{	$Cmd += " -svc "	}
	if($Node_ID)	{	$Cmd += " $Node_ID "}
	$Cmd
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	if($D)	{	Return  $Result		}
			else	{	$tempFile = [IO.Path]::GetTempFileName()
						$LastItem = $Result.Count   
						foreach ($S in  $Result[0..$LastItem] )
							{	$s= [regex]::Replace($s,"^ ","")			
								$s= [regex]::Replace($s,"^ ","")
								$s= [regex]::Replace($s,"^ ","")			
								$s= [regex]::Replace($s,"^ ","")		
								$s= [regex]::Replace($s," +",",")			
								$s= [regex]::Replace($s,"-","")			
								$s= $s.Trim()
								if($Log)	{	$temp1 = $s -replace 'Time','Date,Time,Zone'			
												$s = $temp1
											}
								Add-Content -Path $tempfile -Value $s				
							}
						Import-Csv $tempFile 
						Remove-Item $tempFile
					}
		}
	else{	Return  $Result}
}
}

Function Show-A9EEProm
{
<#
.SYNOPSIS
	Show node EEPROM information.
.DESCRIPTION
	The command displays node EEPROM log information.
.EXAMPLE
	The following example displays the EEPROM log for all nodes:
	PS:> Show-A9EEProm
.EXAMPLE
	PS:> Show-A9EEProm -Node_ID 0
.EXAMPLE
	PS:> Show-A9EEProm -Dead 
.EXAMPLE
	PS:> Show-A9EEProm -Dead -Node_ID 0
.PARAMETER Dead
	Specifies that an EEPROM log for a node that has not started or successfully joined the cluster be displayed. If this option is used, it must be followed by a non empty list of nodes.
.PARAMETER Node_ID
	Specifies the node ID for which EEPROM log information is retrieved. Multiple node IDs are separated with a single space (0 1 2). 
	If no specifiers are used, the EEPROM log for all nodes is displayed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Dead,
		[Parameter()]	[String]	$Node_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showeeprom "
	if($Dead)	{	$Cmd += " -dead "}
	if($Node_ID)	{	$Cmd += " $Node_ID "}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SystemInformation
{
<#
.SYNOPSIS
    Command displays the Storage system information. 
.DESCRIPTION
    Command displays the Storage system information.
.EXAMPLE
    PS:> Get-A9SystemInformation 

	Command displays the Storage system information.such as system name, model, serial number, and system capacity information.
.EXAMPLE
    PS:> Get-A9SystemInformation -Option space

	Lists Storage system space information in MB(1024^2 bytes).PARAMETER Option
	space 
    Displays the system capacity information in MB (1024^2 bytes)
	
    domainspace 
    Displays the system capacity information broken down by domain in MB(1024^2 bytes)
	
    fan 
    Displays the system fan information.
	
    date	
	command displays the date and time for each system node
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Option
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
process
{	$sysinfocmd = "showsys "
	$Option = $Option.toLower()
	if ($Option)
		{	$a = "d","param","fan","space","vvspace","domainspace","desc","devtype","date"
			$l=$Option
			if($a -eq $l)
				{	$sysinfocmd+=" -$option "
					if($Option -eq "date")
						{	$Result = Invoke-A9CLICommand -cmds  "showdate"
							write-verbose "Get system date information " 
							write-verbose "Get system fan information cmd -> showdate " 
							$tempFile = [IO.Path]::GetTempFileName()
							Add-Content -Path $tempFile -Value "Node,Date"
							foreach ($s in  $Result[1..$Result.Count] )
								{	$splits = $s.split(" ")
									$var1 = $splits[0].trim()
									$var2 = ""
									foreach ($t in $splits[1..$splits.Count])
										{	if(-not $t)	{	continue	}
											$var2 += $t+" "	
										}
									$var3 = $var1+","+$var2
									Add-Content -Path $tempFile -Value $var3
								}
							Import-Csv $tempFile
							Remove-Item $tempFile
							return
						}	
					else
						{	$Result = Invoke-A9CLICommand -cmds  $sysinfocmd
							return $Result
						}
				}
			else
				{	Return "FAILURE : -option :- $option is an Incorrect option  [d,param,fan,space,vvspace,domainspace,desc,devtype]  can be used only . "
				}
		}
	else
		{	$Result = Invoke-A9CLICommand -cmds  $sysinfocmd
			return $Result 
		}		
}
}

Function Show-A9FCOEStatistics
{
<#
.SYNOPSIS
	Show-FCOEStatistics - Display FCoE statistics
.DESCRIPTION
	The Show-FCOEStatistics command displays Fibre Channel over Ethernet statistics.
.PARAMETER D
	Looping delay in seconds <secs>. The default is 2.
.PARAMETER Iter
	The command stops after a user-defined <number> of iterations.
.PARAMETER Nodes
	List of nodes for which the ports are included.
.PARAMETER Slots
	List of PCI slots for which the ports are included.
.PARAMETER Ports
	List of ports which are included. Lists are specified in a comma-separated manner such as: -ports 1,2 or -ports 1.
.PARAMETER Counts
	Shows the counts. The default is to show counts/sec.
.PARAMETER Fullcounts
	Shows the values for the full list of counters instead of the default packets and KBytes for the specified protocols. The values are shown in three columns:
		Current - Counts since the last sample.
		CmdStart - Counts since the start of the command.
		Begin - Counts since the port was reset.
.PARAMETER Prev
	Shows the differences from the previous sample.
.PARAMETER Begin
	Shows the values from when the system was last initiated.
.NOTES
	This command requires a SSH type connection.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]		[String]	$D,
		[Parameter()]		[String]	$Iter,
		[Parameter()]		[String]	$Nodes,
		[Parameter()]		[String]	$Slots,
		[Parameter()]		[String]	$Ports,
		[Parameter()]		[switch]	$Counts,
		[Parameter()]		[switch]	$Fullcounts,
		[Parameter()]		[switch]	$Prev,
		[Parameter()]		[switch]	$Begin
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " statfcoe "
	if($D)			{	$Cmd += " -d $D " }
	if($Iter)		{	$Cmd += " -iter $Iter " }
	if($Nodes)		{	$Cmd += " -nodes $Nodes " }
	if($Slots)		{	$Cmd += " -slots $Slots " }
	if($Ports)		{	$Cmd += " -ports $Ports " }
	if($Counts)		{	$Cmd += " -counts " }
	if($Fullcounts)	{	$Cmd += " -fullcounts " }
	if($Prev)		{	$Cmd += " -prev " }
	if($Begin)		{	$Cmd += " -begin " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Write-Verbose  "Executing function : Show-FCOEStatistics command -->"  
	Return $Result
}
}

Function Show-A9Firmwaredb
{
<#
.SYNOPSIS
	Show database of current firmware levels.
.DESCRIPTION
	Displays the current database of firmware levels for possible upgrade. If issued without any options, the firmware for all vendors is displayed.
.EXAMPLE
	PS:> Show-A9Firmwaredb
.EXAMPLE
	PS:> Show-A9Firmwaredb -VendorName xxx
.EXAMPLE
	PS:> Show-A9Firmwaredb -All
.EXAMPLE
	PS:> Show-A9Firmwaredb -L
.PARAMETER VendorName
	Specifies that the firmware vendor from the SCSI database file is displayed.
.PARAMETER L
	Reloads the SCSI database file into the system.
.PARAMETER All
	Specifies current and past firmware entries are displayed. If not specified, only current entries are displayed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$VendorName,
		[Parameter()]	[switch]	$L,
		[Parameter()]	[switch]	$All	
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showfirmwaredb "
	if($VendorName)	{	$Cmd += " -n $VendorName "}
	if($L)			{	$Cmd += " -l "	}
	if($All)		{	$Cmd += " -all " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Show-A9TOCGen
{
<#
.SYNOPSIS
	Shows system Table of Contents (TOC) generation number.
.DESCRIPTION
	Displays the table of contents generation number.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showtocgen "
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Show-A9iSCSISessionStatistics
{
<#
.SYNOPSIS  
	The Show-iSCSISessionStatistics command displays the iSCSI session statistics.
.DESCRIPTION  
	The Show-iSCSISessionStatistics command displays the iSCSI session statistics.
.EXAMPLE
	PS:> Show-A9iSCSISessionStatistics
.EXAMPLE
	PS:> Show-A9iSCSISessionStatistics -Iterations 1
.EXAMPLE
	PS:> Show-A9iSCSISessionStatistics -Iterations 1 -Delay 2
.EXAMPLE
	PS:> Show-A9iSCSISessionStatistics -Iterations 1 -NodeList 1
.EXAMPLE
	PS:> Show-A9iSCSISessionStatistics -Iterations 1 -SlotList 1
.EXAMPLE
	PS:> Show-A9iSCSISessionStatistics -Iterations 1 -PortList 1
.EXAMPLE
	PS:> Show-A9iSCSISessionStatistics -Iterations 1 -Prev
.PARAMETER Iterations 
	The command stops after a user-defined <number> of iterations.
.PARAMETER Delay
	Looping delay in seconds <secs>. The default is 2.
.PARAMETER NodeList
	List of nodes for which the ports are included.
.PARAMETER SlotList
	List of PCI slots for which the ports are included.
.PARAMETER PortList
	List of ports for which the ports are included. Lists are specified
	in a comma-separated manner such as: -ports 1,2 or -ports 1.
.PARAMETER Previous
	Shows the differences from the previous sample.
.PARAMETER Begin
	Shows the values from when the system was last initiated.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(mandatory=$true)]	[String]	$Iterations,
		[Parameter()]	[String]	$Delay,		
		[Parameter()]	[String]	$NodeList,
		[Parameter()]	[String]	$SlotList,
		[Parameter()]	[String]	$PortList,		
		[Parameter()]	[Switch]	$Previous,	
		[Parameter()]	[Switch]	$Begin
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
process
{	$cmd= "statiscsisession "	
	if($Iterations)	{	$cmd+=" -iter $Iterations "	}
	if($Delay)		{	$cmd+=" -d $Delay "	}	
	if($NodeList)	{	$cmd+=" -nodes $NodeList "	}
	if($SlotList)	{	$cmd+=" -slots $SlotList "	}
	if($PortList)	{	$cmd+=" -ports $PortList "	}	
	if($Previous)	{	$cmd+=" -prev "	}
	if($Begin)		{	$cmd+=" -begin "	}
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if($Result -match "Total" -and $Result.Count -gt 5)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count - 3 
			$Flag = "False"
			$Loop_Cnt = 2	
			foreach ($s in  $Result[$Loop_Cnt..$LastItem] )
				{	if($Flag -eq "true")
						{	if(($s -match "statiscsisession") -or ($s -match "----PDUs/s---- --KBytes/s--- ----Errs/s----") -or ($s -match " port -------------iSCSI_Name-------------- TPGT Cmd Resp Total  Tx  Rx Total Digest TimeOut VLAN") -or ($s -match " port -iSCSI_Name- TPGT Cmd Resp Total  Tx  Rx Total Digest TimeOut VLAN"))
								{	if(($s -match " port -------------iSCSI_Name-------------- TPGT Cmd Resp Total  Tx  Rx Total Digest TimeOut VLAN") -or ($s -match " port -iSCSI_Name- TPGT Cmd Resp Total  Tx  Rx Total Digest TimeOut VLAN"))
										{	$temp="=============================="
											Add-Content -Path $tempFile -Value $temp
										}
								}
							else
								{	$s= [regex]::Replace($s,"^ ","")			
									$s= [regex]::Replace($s," +",",")	
									$s= [regex]::Replace($s,"-","")
									$s= $s.Trim()					
									if($s.length -ne 0)
										{	$sTemp1=$s				
											$sTemp = $sTemp1.Split(',')							
											$cnt = $sTemp.count			
											if($cnt -gt 8)
											{	$sTemp[5]="Total(PDUs/s)"				
												$sTemp[8]="Total(KBytes/s)"
											}
											$newTemp= [regex]::Replace($sTemp,"^ ","")			
											$newTemp= [regex]::Replace($sTemp," ",",")				
											$newTemp= $newTemp.Trim()
											$s=$newTemp
										}					
									Add-Content -Path $tempFile -Value $s	
								}
						}
					else
						{	$s= [regex]::Replace($s,"^ ","")			
							$s= [regex]::Replace($s," +",",")	
							$s= [regex]::Replace($s,"-","")
							$s= $s.Trim()				
							$sTemp1=$s				
							$sTemp = $sTemp1.Split(',')							
							$cnt = $sTemp.count			
							if($cnt -gt 8)
								{	$sTemp[5]="Total(PDUs/s)"				
									$sTemp[8]="Total(KBytes/s)"
								}
							$newTemp= [regex]::Replace($sTemp,"^ ","")			
							$newTemp= [regex]::Replace($sTemp," ",",")				
							$newTemp= $newTemp.Trim()
							$s=$newTemp							
							Add-Content -Path $tempFile -Value $s	
						}
					$Flag = "true"			
				}
			Import-Csv $tempFile 
			remove-item $tempFile
		}
	if($Result -match "Total" -and $Result.Count -gt 5)
		{	return  " Success : Executing Show-iSCSISessionStatistics"
		}
	else
	{	if($Result.Count -lt 5)		{	return  $Result	}
		else						{	return  "No Data Found while Executing Show-iSCSISessionStatistics"	}
	}	
}
}

Function Show-A9iSCSIStatistics
{
<#
.SYNOPSIS  
	The command displays the iSCSI statistics.
.DESCRIPTION  
	The command displays the iSCSI statistics.
.EXAMPLE
	PS:> Show-A9iSCSIStatistics
.EXAMPLE
	PS:> Show-A9iSCSIStatistics -Iterations 1
.EXAMPLE
	PS:> Show-A9iSCSIStatistics -Iterations 1 -Delay 2
.EXAMPLE
	PS:> Show-A9iSCSIStatistics -Iterations 1 -NodeList 1
.EXAMPLE
	PS:> Show-A9iSCSIStatistics -Iterations 1 -SlotList 1
.EXAMPLE
	PS:> Show-A9iSCSIStatistics -Iterations 1 -PortList 1
.EXAMPLE
	PS:> Show-A9iSCSIStatistics -Iterations 1 -Fullcounts
.EXAMPLE
	PS:> Show-A9iSCSIStatistics -Iterations 1 -Prev
.EXAMPLE
	PS:> Show-A9iSCSIStatistics -Iterations 1 -Begin
.PARAMETER Iterations 
	The command stops after a user-defined <number> of iterations.
.PARAMETER Delay
	Looping delay in seconds <secs>. The default is 2.
.PARAMETER NodeList
	List of nodes for which the ports are included.
.PARAMETER SlotList
		List of PCI slots for which the ports are included.
.PARAMETER PortList
		List of ports for which the ports are included. Lists are specified
        in a comma-separated manner such as: -ports 1,2 or -ports 1.
.PARAMETER Fullcounts
		Shows the values for the full list of counters instead of the default
        packets and KBytes for the specified protocols. The values are shown in
        three columns:
		o Current   - Counts since the last sample.
        o CmdStart  - Counts since the start of the command.
        o Begin     - Counts since the port was reset.
        This option cannot be used with the -prot option. If the -fullcounts
        option is not specified, the metrics from the start of the command are
        displayed.
.PARAMETER Prev
	Shows the differences from the previous sample.
.PARAMETER Begin
	Shows the values from when the system was last initiated.
.PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Iterations,
		[Parameter()]	[String]	$Delay,		
		[Parameter()]	[String]	$NodeList,
		[Parameter()]	[String]	$SlotList,
		[Parameter()]	[String]	$PortList,
		[Parameter()]	[Switch]	$Fullcounts,
		[Parameter()]	[Switch]	$Prev,		
		[Parameter()]	[Switch]	$Begin
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}		
process	
{	$cmd= " statiscsi "	
	if($Iterations)	{	$cmd+=" -iter $Iterations "	}
	else			{	return " Iterations is mandatory "	}
	if($Delay)		{	$cmd+=" -d $Delay "	}	
	if($NodeList)	{	$cmd+=" -nodes $NodeList "	}
	if($SlotList)	{	$cmd+=" -slots $SlotList "	}
	if($PortList)	{	$cmd+=" -ports $PortList "	}
	if($Fullcounts)	{	$cmd+=" -fullcounts "	}
	if($Prev)		{	$cmd+=" -prev "	}
	if($Begin)		{	$cmd+=" -begin "	}	
	$Result = Invoke-A9CLICommand -cmds  $cmd
	write-verbose "  Executing  Show-iSCSIStatistics command that displays information iSNS table for iSCSI ports in the system  " 	
	if($Result -match "Total" -or $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count 
			$Flag = "False"
			$Loop_Cnt = 2	
			if($Fullcounts)	{	$Loop_Cnt = 1	}		
			foreach ($s in  $Result[$Loop_Cnt..$LastItem] )
				{	if($Flag -eq "true")
						{	if(($s -match "From start of statiscsi command") -or ($s -match "----Receive---- ---Transmit---- -----Total-----") -or ($s -match "port    Protocol Pkts/s KBytes/s Pkts/s KBytes/s Pkts/s KBytes/s Errs/") -or ($s -match "Counts/sec") -or ($s -match "Port Counter                             Current CmdStart   Begin"))
								{	if(($s -match "port    Protocol Pkts/s KBytes/s Pkts/s KBytes/s Pkts/s KBytes/s Errs/") -or ($s -match "Port Counter                             Current CmdStart   Begin"))
										{	$temp="=============================="
											Add-Content -Path $tempFile -Value $temp
										}
								}
							else
								{	$s= [regex]::Replace($s,"^ ","")			
									$s= [regex]::Replace($s," +",",")	
									$s= [regex]::Replace($s,"-","")
									$s= $s.Trim() -replace 'Pkts/s,KBytes/s,Pkts/s,KBytes/s,Pkts/s,KBytes/s','Pkts/s(Receive),KBytes/s(Receive),Pkts/s(Transmit),KBytes/s(Transmit),Pkts/s(Total),KBytes/s(Total)' 	
									if($s.length -ne 0)
										{	if(-not $Fullcounts)	{	$s=$s.Substring(1)		}
										}				
									Add-Content -Path $tempFile -Value $s	
								}
						}
					else
						{	$s= [regex]::Replace($s,"^ ","")			
							$s= [regex]::Replace($s," +",",")	
							$s= [regex]::Replace($s,"-","")
							$s= $s.Trim() -replace 'Pkts/s,KBytes/s,Pkts/s,KBytes/s,Pkts/s,KBytes/s','Pkts/s(Receive),KBytes/s(Receive),Pkts/s(Transmit),KBytes/s(Transmit),Pkts/s(Total),KBytes/s(Total)' 	
							if($s.length -ne 0)
								{	if(-not $Fullcounts)	{	$s=$s.Substring(1)	}					
								}				
							Add-Content -Path $tempFile -Value $s	
						}
					$Flag = "true"			
				}
			Import-Csv $tempFile 
			remove-item $tempFile
		}
	else	{	return  $Result	}
} 
}

Function Show-A9NetworkDetail
{
<#
.SYNOPSIS
	Show the network configuration and status
.DESCRIPTION
	The command displays the configuration and status of the administration network interfaces, including the configured gateway and network time protocol (NTP) server.
.EXAMPLE 
	The following example displays the status of the system administration network interfaces:
	PS:> Show-A9NetworkDetail -D
.PARAMETER D
	Show detailed information.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$D
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " shownet "
	if($D)	{	$Cmd += " -d "}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Show-A9NodeEnvironmentStatus
{
<#
.SYNOPSIS
	Show node environmental status (voltages, temperatures).
.DESCRIPTION
	The command displays the node operating environment status, including voltages and temperatures.
.EXAMPLE
	The following example displays the operating environment status for all nodes
	in the system:

	PS:> Show-A9NodeEnvironmentStatus
.PARAMETER Node_ID
	Specifies the ID of the node whose environment status is displayed. Multiple node IDs can be specified as a series of integers separated by
	a space (1 2 3). If no option is used, then the environment status of all nodes is displayed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Node_ID
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " shownodeenv "
	if($Node_ID)	{	$Cmd += " -n $Node_ID "} 
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Show-A9iSCSISession
{
<#
.SYNOPSIS
	Shows the iSCSI sessions.
.DESCRIPTION  
	The command shows the iSCSI sessions.
.EXAMPLE
	PS:> Show-A9iSCSISession
.EXAMPLE
	PS:> Show-A9iSCSISession -NSP 1:2:1
.EXAMPLE
	PS:> Show-A9iSCSISession -Detailed -NSP 1:2:1
.PARAMETER Detailed
    Specifies that more detailed information about the iSCSI session is displayed. If this option is not used, then only summary information
    about the iSCSI session is displayed.
.PARAMETER ConnectionState
    Specifies the connection state of current iSCSI sessions. If this option is not used, then only summary information about the iSCSI session is displayed.
.PARAMETER NSP
	Requests that information for a specified port is displayed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[switch]	$ConnectionState,
		[Parameter()]	[String]	$NSP 
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
process	
{	$cmd= "showiscsisession "
	if ($Detailed)	{	$cmd+=" -d "	}
	if ($ConnectionState)	{	$cmd+=" -state "	}
	if ($NSP)	{	$cmd+=" $NSP "	}
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if($Result -match "total")
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -2 		
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim() -replace 'StartTime','Date,Time,Zone' 	
					Add-Content -Path $tempFile -Value $s
				}			
			Import-Csv $tempFile 
			remove-item $tempFile
		}
	if($Result -match "total")	
		{	write-host " Success : Executing Show-iSCSISession"
			return 
		}
	else{	return  $Result	}	
}
}

Function Show-A9NodeProperties
{
<#
.SYNOPSIS
	Show node and its component information.
.DESCRIPTION
	The command displays an overview of the node-specific properties and its component information. Various command options can be used to
	display the properties of PCI cards, CPUs, Physical Memory, IDE drives, and Power Supplies.
.EXAMPLE
	The following example displays the operating environment status for all
	nodes in the system:
	
	PS:> Show-A9NodeProperties
.EXAMPLE
	The following examples display detailed information (-d option) for the nodes including their components in a table format. The shownode -d command
	can be used to display the tail information of the nodes including their components in name and value pairs.

	PS:> Show-A9NodeProperties - Mem
	PS:> Show-A9NodeProperties - Mem -Node_ID 1	
    
	The following options are for node summary and inventory information:
.PARAMETER Listcols
	List the columns available to be shown with the -showcols option described below (see 'clihelp -col Show-NodeProperties' for help on each column).
	By default (if none of the information selection options below are specified) the following columns are shown:
	Node Name State Master InCluster LED Control_Mem Data_Mem Available_Cache To display columns pertaining to a specific node component use
	the -listcols option in conjunction with one of the following options: -pci, -cpu, -mem, -drive, -fan, -ps, -mcu, -uptime.
.PARAMETER Showcols
	Explicitly select the columns to be shown using a comma-separated list of column names.  For this option, the full column names are shown in the header.
	Run 'shownode -listcols' to list Node component columns.
	Run 'shownode -listcols <node_component>' to list columns associated with a specific <node_component>.

	<node_component> can be one of the following options: -pci, -cpu, -mem, -drive, -fan, -ps, -mcu, -uptime.

	If a specific node component option is not provided, then -showcols expects Node columns as input.

	If a column (Node or specific node component) does not match either the Node columns list or a specific node component columns list, then
	'shownode -showcols <cols>' request is denied.

	If an invalid column is provided with -showcols, the request is denied.

	The -showcols option can also be used in conjunction with a list of node IDs.

	Run 'clihelp -col shownode' for a description of each column.
.PARAMETER I
	Shows node inventory information in table format.
.PARAMETER D
	Shows node and its component information in table format.
	The following options are for node component information. These options cannot be used together with options, -i and -d:
.PARAMETER VerboseD
	Displays detailed information in verbose format. It can be used together with the following component options.
.PARAMETER Fan
	Displays the node fan information.
.PARAMETER Pci
	Displays PCI card information
.PARAMETER Cpu
	Displays CPU information
.PARAMETER Mem
	Displays physical memory information.
.PARAMETER Drive
	Displays the disk drive information.
.PARAMETER Ps
	Displays power supply information.
.PARAMETER Mcu
	Displays MicroController Unit information.
.PARAMETER State
	Displays the detailed state information for node or power supply (-ps). This is the same as -s.
.PARAMETER S
	Displays the detailed state information for node or power supply (-ps). This option is deprecated and will be removed in a subsequent release.
.PARAMETER Uptime
	Show the amount of time each node has been running since the last shutdown.
.PARAMETER Svc
	Displays inventory information with HPE serial number, spare part etc. This option must be used with -i option and it is not supported on HPE 3PAR 10000 systems
.PARAMETER Node_ID
	Displays the node information for the specified node ID(s). This specifier is not required. Node_ID is an integer from 0 through 7.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Listcols,
		[Parameter()]	[String]	$Showcols,
		[Parameter()]	[switch]	$I,
		[Parameter()]	[switch]	$D,
		[Parameter()]	[switch]	$VerboseD,
		[Parameter()]	[switch]	$Fan,
		[Parameter()]	[switch]	$Pci,
		[Parameter()]	[switch]	$Cpu,
		[Parameter()]	[switch]	$Mem,
		[Parameter()]	[switch]	$Drive,
		[Parameter()]	[switch]	$Ps,
		[Parameter()]	[switch]	$Mcu,
		[Parameter()]	[switch]	$State,
		[Parameter()]	[switch]	$Uptime,
		[Parameter()]	[switch]	$Svc,
		[Parameter()]	[String]	$Node_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{ 	$Cmd = " shownode "
	if($Listcols)
		{	$Cmd += " -listcols "
			$Result = Invoke-A9CLICommand -cmds  $Cmd
			return $Result
		}
	if($Showcols)	{	$Cmd += " -showcols $Showcols " }
	if($I)			{	$Cmd += " -i " }
	if($D) 			{	$Cmd += " -d " }
	if($VerboseD)	{	$Cmd += " -verbose " }
	if($Fan) 		{	$Cmd += " -fan " }
	if($Pci)		{	$Cmd += " -pci " }
	if($Cpu) 		{	$Cmd += " -cpu " }
	if($Mem)		{	$Cmd += " -mem " }
	if($Drive)		{	$Cmd += " -drive " }
	if($Ps)			{	$Cmd += " -ps " }
	if($Mcu)		{	$Cmd += " -mcu " }
	if($State)		{	$Cmd += " -state " }
	if($Uptime)		{	$Cmd += " -uptime " }
	if($Svc) 		{	$Cmd += " -svc " }
	if($Node_ID)	{	$Cmd += " $Node_ID " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	if($I -Or $D -Or $VerboseD)	{	Return  $Result	}
			else{	$tempFile = [IO.Path]::GetTempFileName()
					$LastItem = $Result.Count
					$FirstCount = 0
					$oneTimeOnly = "True"
					if($Cmd -eq " shownode " -Or $Node_ID)	{	$FirstCount = 1	}
					if($Node_ID -and $Showcols)				{	$FirstCount = 0	}
					if($Showcols -or $Fan -or $Pci -or $Cpu -Or $Drive -Or $Mem -Or $Mcu -Or $Ps -Or $State -Or $Uptime -Or $Svc)
						{	$FirstCount = 0
						}
					foreach ($S in  $Result[$FirstCount..$LastItem] )
						{	$s= [regex]::Replace($s,"^ ","")			
							$s= [regex]::Replace($s,"^ ","")
							$s= [regex]::Replace($s,"^ ","")			
							$s= [regex]::Replace($s,"^ ","")		
							$s= [regex]::Replace($s," +",",")			
							$s= [regex]::Replace($s,"-","")			
							$s= $s.Trim()
							if($Cmd -eq " shownode "  -Or $Node_ID)
								{	if(-not ($Showcols -or $Fan -or $Pci -or $Cpu -Or $Drive -Or $Mem -Or $Mcu -Or $Ps -Or $State -Or $Uptime -Or $Svc) )
										{	if($oneTimeOnly -eq "True")
												{	$sTemp1=$s				
													$sTemp = $sTemp1.Split(',')							
													$sTemp[6] = "Control_Mem(MB)"
													$sTemp[7] = "Data_Mem(MB)"
													$sTemp[8] = "Cache_Available(%)"			
													$newTemp= [regex]::Replace($sTemp,"^ ","")			
													$newTemp= [regex]::Replace($sTemp," ",",")				
													$newTemp= $newTemp.Trim()
													$s=$newTemp			
												}
										}
								}
							Add-Content -Path $tempfile -Value $s
							$oneTimeOnly = "False"				
						}
					Import-Csv $tempFile 
					remove-item $tempFile
				}	
		}
	else{	Return  $Result	}
} 
}

Function Show-A9Portdevices_CLI
{
<#
.SYNOPSIS
	Show detailed information about devices on a port.
.DESCRIPTION
	The command displays detailed information about devices on a specified port.
.PARAMETER Loop
	Specifies that information is returned for arbitrated loop devices that are attached to the specified port. This subcommand is only
	for use with Fibre Channel arbitrated loop ports.
.PARAMETER All
	Specifies that information for all devices attached to the specified port is returned.
.PARAMETER NS
	Specifies that information for the switch name server database is returned. This subcommand is only for use with fabric-attached topologies.
.PARAMETER Fcf
	Specifies that information for all Fibre Channel over Ethernet forwarders (FCFs) known to the specified port is returned. This
	subcommand is for use only with Fibre Channel over Ethernet (FCoE) ports.
.PARAMETER Sas
	Specifies that information for all devices in the SAS topology attached to the specified port is returned.  This subcommand is only for use with SAS ports.
.PARAMETER Fcswitch
	Specifies that a list of all switches in the Fibre Channel fabric is returned.  This subcommand is only for use with fabric-attached Fibre Channel ports.
.PARAMETER Fcfabric
	Specifies that a description of the Fibre Channel fabric is returned.  This subcommand is only for use with fabric-attached Fibre Channel ports.
.PARAMETER Findport
	Searches the Fibre Channel fabric attached to the specified port for information on the supplied WWN.  Supplying the term "this"
	in place of a WWN indicates that the port WWN of the specified  Storage System host port should be used.  This subcommand is only for
	use with fabric-attached Fibre Channel ports.
.PARAMETER Tzone
	Without the <node:slot:port>, this command will return a list of all the current target-driven zones for any port. If the <node:slot:port> is provided, 
	then detailed information about the target-driven zone for this port will be provided. This command is only used with fabric-attached Fibre Channel ports.
.PARAMETER UNS
	Specifies that information for all initiators from the switch unzoned name server database is returned. This subcommand is only for use with
	fabric-attached topologies.
.PARAMETER Lldp
	Specifies available Link Layer Discovery Protocol information for each iSCSI port physically connected is returned. If the <node:slot:port>
	is provided, then only information for this port will be displayed. This subcommand is only used with iSCSI QLogic 83XX series ports.
.PARAMETER Dcbx
	Specifies available Data Center Bridging Exchange Protocol information for each iSCSI port physically connected is returned. If the <node:slot:port> 
	is provided, then only information for this port will be displayed. This subcommand is only used with iSCSI QLogic 83XX series ports.
.PARAMETER Pel
	Includes the SAS Phy Error Log (PEL) data for each phy in the SAS topology.  This option is only valid when using the sas subcommand.
.PARAMETER D
	Includes detailed initiator information: HBA Manufacturer, HBA Model, HBA Firmware Version, HBA OS Name/Version, the HBA port's supported
	and current speeds, HBA port's OS device name, hostname, alias name(s), and whether the Smart SAN QoS and Security features are supported. When
	used with the tzone or uns subcommand. When used with the lldp or dcbx subcommand, this option will return relevant detailed information on the 
	LLDP and DCBX information received from the peer device. This option is only valid when using either the tzone, uns, lldp or dcbx subcommand.
.PARAMETER App
	Includes detailed information provided from the DCBX Application Protocol TLV configured on the peer device.
.PARAMETER Pfc
	Includes detailed information from the DCBX Priority Flow Control TLV configured on the peer device.
.PARAMETER Pg
	Includes detailed information from the DCBX Priority Groups TLV configured on the peer device.
.PARAMETER NSP
	Specifies the port for which information about devices on that port are
	displayed.
	node
		Specifies the node.
	slot
		Specifies the PCI bus slot in the specified node.
	port
		Specifies the Fibre Channel port number of the PCI card in the
		specified PCI bus slot.
.PARAMETER WWN
    Specifies the Fibre Channel worldwide port name of an attached port.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[switch]	$Loop,
	[Parameter()]	[switch]	$All,
	[Parameter()]	[switch]	$NS,
	[Parameter()]	[switch]	$FCF,
	[Parameter()]	[switch]	$SAS,
	[Parameter()]	[switch]	$Fcswitch,
	[Parameter()]	[switch]	$Fcfabric,
	[Parameter()]	[switch]	$Findport,
	[Parameter()]	[switch]	$Tzone,
	[Parameter()]	[switch]	$UNS,
	[Parameter()]	[switch]	$Lldp,
	[Parameter()]	[switch]	$Dcbx,
	[Parameter()]	[switch]	$PEL,
	[Parameter()]	[switch]	$Detail,
	[Parameter()]	[switch]	$App,
	[Parameter()]	[switch]	$PFC,
	[Parameter()]	[switch]	$PG,
	[Parameter()]	[String]	$NSP,	
	[Parameter()]	[String]	$WWN
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showportdev "		
	if($Loop)		{	$Cmd += " loop " }
	elseif($All)	{	$Cmd += " all " }
	elseif($NS) 	{	$Cmd += " ns " }
	elseif($FCF)	{	$Cmd += " fcf " }
	elseif($SAS)	{ 	$Cmd += " sas " }
	elseif($Fcswitch){	$Cmd += " fcswitch " }
	elseif($Fcfabric){	$Cmd += " fcfabric " }
	elseif($Findport)
		{	$Cmd += " findprort "
			if($WWN)	{	$Cmd += " $WWN " 	}
			else		{	Return "WWN name required with Findprort.."}
		}	
	elseif($Tzone)	{	$Cmd += " tzone "}
	elseif($UNS)	{	$Cmd += " uns " }
	elseif($Lldp)	{	$Cmd += " lldp " }
	elseif($Dcbx)	{ 	$Cmd += " dcbx " }
	else			{ 	Return "Select at list one sub command..." }
	if($PEL)		{	$Cmd += " -pel " }
	if($Detail)		{	$Cmd += " -d " }
	if($App)		{	$Cmd += " -app " }
	if($PFC)		{	$Cmd += " -pfc " }
	if($PG)			{	$Cmd += " -pg " }
	if($NSP)		{ 	$Cmd += " $NSP " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Show-A9PortISNS
{
<#
.SYNOPSIS   
	The command shows iSNS host information for iSCSI ports in the system.
.DESCRIPTION 
	The command shows iSNS host information for iSCSI ports in the system.
.EXAMPLE	
	PS:> Show-PortISNS
.EXAMPLE	
	PS:> Show-PortISNS -NSP 1:2:3
.PARAMETER NSP
	Specifies the port for which information about devices on that port are displayed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$NSP 
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$cmd= "showportisns "	
	if ($NSP)	{	$cmd+=" $NSP "	}
	$Result = Invoke-A9CLICommand -cmds  $cmd
	write-verbose "  Executing  Show-PortISNS command that displays information iSNS table for iSCSI ports in the system  " 
	if($Result -match "N:S:P")
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -2 		
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim() 	
					Add-Content -Path $tempFile -Value $s				
				}			
			Import-Csv $tempFile 
			remove-item $tempFile
		}
	if($Result -match "N:S:P")	{	return  " Success : Executing Show-PortISNS"	}
	else	{	return  $Result	}
}	
} 

Function Show-A9SystemManager
{
<#
.SYNOPSIS
	Show system manager startup state.
.DESCRIPTION
	The displays startup state information about the system manager.
.PARAMETER D
	Shows additional detailed information if available.
.PARAMETER L
	Shows field service diagnostics for System Manager specific Config Locks and MCALLs, and system-wide ioctl system calls.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$D,
		[Parameter()]	[switch]	$L
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showsysmgr "
	if($D)	{	$Cmd += " -d "	}
	if($L)	{	$Cmd += " -l "}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Show-A9SystemResourcesSummary
{
<#
.SYNOPSIS
	Show system Table of Contents (TOC) summary.
.DESCRIPTION
	The command displays the system table of contents summary that provides a summary of the system's resources.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showtoc "
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
} 

Function Start-A9NodeRescue
{
<#
.SYNOPSIS
	Starts a node rescue.
.DESCRIPTION
	Initiates a node rescue, which initializes the internal node disk of the specified node to match the contents of the other node disks. Progress is reported as a task.
.EXAMPLE
	Start-A9NodeRescue -Node 0
.PARAMETER Node
	Specifies the node to be rescued.  This node must be physically present in the system and powered on, but not part of the cluster.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$True)]	[String]	$Node
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " startnoderescue "
	if($Node)	{	$Cmd += " -node $Node " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9HostPorts_CLI
{
<#
.SYNOPSIS
	Query to get all ports including targets, disks, and RCIP ports.
.DESCRIPTION
	Get information for Ports
.PARAMETER I
	Shows port hardware inventory information.
.PARAMETER C
	Displays all devices connected to the port. Such devices include cages (for initiator ports), hosts (for target ports) and ports from other
	storage system (for RCFC and peer ports).
.PARAMETER PAR
	Displays a parameter listing such as the configured data rate of a port and the maximum data rate that the card supports. Also shown is the
	type of attachment (Direct Connect or Fabric Attached) and whether the unique_nwwn and VCN capabilities are enabled.
.PARAMETER RC
	Displays information that is specific to the Remote Copy ports.
.PARAMETER RCFC
	Displays information that is specific to the Fibre Channel Remote Copy ports.
.PARAMETER PEER
	Displays information that is specific to the Fibre Channel ports for Data Migration.
.PARAMETER RCIP
	Displays information specific to the Ethernet Remote Copy ports.
.PARAMETER ISCSI
	Displays information about iSCSI ports.
.PARAMETER ISCSINAME
	Displays iSCSI names associated with iSCSI ports.
.PARAMETER ISCSIVLANS
	Displays information about VLANs on iSCSI ports.
.PARAMETER Fcoe
	Displays information that is specific to Fibre Channel over Ethernet
	(FCoE) ports.
.PARAMETER SFP
	Displays information about the SFPs attached to ports.
.PARAMETER DDM
	Displays Digital Diagnostics Monitoring (DDM) readings from the SFPs if they support DDM. This option must be used with the -sfp option.
.PARAMETER D
	Displays detailed information about the SFPs attached to ports. This option is used with the -sfp option.
.PARAMETER FAILED
	Shows only failed ports.
.PARAMETER STATE
	Displays the detailed state information. This is the same as -s.
.PARAMETER Detailed
	Displays the detailed state information. This option is deprecated and will be removed in a subsequent release.
.PARAMETER IDS
	Displays the identities hosted by each physical port.
.PARAMETER FS
	Displays information specific to the Ethernet File Persona ports. To see IP address, netmask and gateway information on File Persona, run "showfs -net".
.PARAMETER NSP
	Nede sloat poart
.EXAMPLE
	PS:> Get-A9HostPorts_CLI
		Lists all ports including targets, disks, and RCIP ports
.EXAMPLE
	PS:> Get-A9HostPorts_CLI  -I
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -I -NSP 0:0:0
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -PAR
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -PAR -NSP 0:0:0
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -RC
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -RC -NSP 0:0:0
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -RCFC
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -RCFC -NSP 0:0:0
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -RCIP
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
Param(		[Parameter()]	[switch]	$I,
			[Parameter()]	[switch]	$PAR,
			[Parameter()]	[switch]	$RC,
			[Parameter()]	[switch]	$RCFC,
			[Parameter()]	[switch]	$RCIP,
			[Parameter()]	[switch]	$PEER,
			[Parameter()]	[switch]	$ISCSI,
			[Parameter()]	[switch]	$ISCSINAME,
			[Parameter()]	[switch]	$ISCSIVLANS,
			[Parameter()]	[switch]	$FCOE,
			[Parameter()]	[switch]	$SFP,
			[Parameter()]	[switch]	$FAILED,
			[Parameter()]	[switch]	$STATE,
			[Parameter()]	[switch]	$Detailed,
			[Parameter()]	[switch]	$IDS,
			[Parameter()]	[switch]	$FS,
			[Parameter()]	[String]	$NSP,
			[Parameter()]	[switch]	$D
		)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmds = "showport"
	if($I)	{	$Cmds+=" -i "		}
	if($C)	{	$Cmds+=" -c "		}
	if($PAR){	$Cmds+=" -par "		}
	if($RC)		{	$Cmds+=" -rc "	}
	if($RCFC)	{	$Cmds+=" -rcfc "}
	if($RCIP)	{	$Cmds+=" -rcip "	}
	if($PEER)	{	$Cmds+=" -peer "}
	if($ISCSI)	{	$Cmds+=" -iscsi "}
	if($ISCSINAME){	$Cmds+=" -iscsiname "	}
	if($ISCSIVLANS)	{	$Cmds+=" -iscsivlans "	}
	if($FCOE)		{	$Cmds+=" -fcoe "	}
	if($SFP)		{	$Cmds+=" -sfp "			}
	if($FAILED)		{	$Cmds+=" -failed "	}
	if($STATE)		{	$Cmds+=" -state "	}
	if($Detailed)	{	$Cmds+=" -s "	}	
	if($IDS)	{	$Cmds+=" -ids "	}
	if($FS)		{	$Cmds+=" -fs "	}	
	if($D)		{	if($SFP)	{	$Cmds+=" -d "	}
					else		{	return " -d can only be used with -sfp"}
				}
	if($NSP)	{	$Cmds+=" $NSP"	}
	$Result=Invoke-A9CLICommand  -cmds $Cmds 	
	$LastItem = $Result.Count -2  
	if($SFP -and $D){	return $Result	}
	if($Result -match "N:S:P")
		{	$tempFile = [IO.Path]::GetTempFileName()
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= [regex]::Replace($s,"-","")
					$s= [regex]::Replace($s,"\s+",",") 		
					$s= [regex]::Replace($s,"/HW_Addr","") 
					$s= [regex]::Replace($s,"N:S:P","Device")
					$s= $s.Trim() 	
					Add-Content -Path $tempFile -Value $s				
				}
			Import-Csv $tempFile
			remove-item $tempFile
		}
	else	{	return  $Result	}
	if($Result -match "N:S:P")
		{	return  " Success : Executing Get-HostPorts"
		}
	else	{	return  $Result	}	
}
}

Function Get-A9Node
{
<#
.SYNOPSIS
	Show node and its component information.
.DESCRIPTION
	The command displays an overview of the node-specific properties
	and its component information. Various command options can be used to
	display the properties of PCI cards, CPUs, Physical Memory, IDE drives,
	and Power Supplies.
.PARAMETER Listcols
	List the columns available to be shown with the -showcols option
	described below (see 'clihelp -col Get-Node' for help on each column).
	By default (if none of the information selection options below are
	specified) the following columns are shown:
	Node Name State Master InCluster LED Control_Mem Data_Mem Available_Cache
	To display columns pertaining to a specific node component use
	the -Listcols option in conjunction with one of the following
	options: -pci, -cpu, -mem, -drive, -fan, -ps, -mcu, -uptime.
.PARAMETER Showcols
	Explicitly select the columns to be shown using a comma-separated list
	of column names.  For this option, the full column names are shown in
	the header.
	Run 'shownode -listcols' to list Node component columns.
	Run 'shownode -listcols <node_component>' to list columns associated
	with a specific <node_component>.

	<node_component> can be one of the following options: -pci, -cpu, -mem,
	-drive, -fan, -ps, -mcu, -uptime.

	If a specific node component option is not provided, then -showcols expects
	Node columns as input.

	If a column (Node or specific node component) does not match either the Node
	columns list or a specific node component columns list, then
	'shownode -showcols <cols>' request is denied.

	If an invalid column is provided with -showcols, the request is denied.

	The -showcols option can also be used in conjunction with a list of node IDs.

	Run 'clihelp -col shownode' for a description of each column.
.PARAMETER I
	Shows node inventory information in table format.
.PARAMETER D
	Shows node and its component information in table format.
	The following options are for node component information. These options
	cannot be used together with options, -i and -d:
.PARAMETER Verbose_D
	Displays detailed information in verbose format. It can be used together
	with the following component options.
.PARAMETER Fan
	Displays the node fan information.
.PARAMETER Pci
	Displays PCI card information
.PARAMETER Cpu
	Displays CPU information
.PARAMETER Mem
	Displays physical memory information.
.PARAMETER Drive
	Displays the disk drive information.
.PARAMETER Ps
	Displays power supply information.
.PARAMETER Mcu
	Displays MicroController Unit information.
.PARAMETER State
	Displays the detailed state information for node or power supply (-ps).
	This is the same as -s.
.PARAMETER S_State
	Displays the detailed state information for node or power supply (-ps).
	This option is deprecated and will be removed in a subsequent release.
.PARAMETER Uptime
	Show the amount of time each node has been running since the last shutdown.
.PARAMETER Svc
	Displays inventory information with HPE serial number, spare part etc.
	This option must be used with -i option and it is not supported on
	HPE 3PAR 10000 systems
.PARAMETER NodeID
	Displays the node information for the specified node ID(s). This
	specifier is not required. Node_ID is an integer from 0 through 7.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Listcols,
		[Parameter()]	[String]	$Showcols,
		[Parameter()]	[switch]	$I,
		[Parameter()]	[switch]	$D,
		[Parameter()]	[switch]	$Verbose_D,
		[Parameter()]	[switch]	$Fan,
		[Parameter()]	[switch]	$Pci,
		[Parameter()]	[switch]	$Cpu,
		[Parameter()]	[switch]	$Mem,
		[Parameter()]	[switch]	$Drive,
		[Parameter()]	[switch]	$Ps,
		[Parameter()]	[switch]	$Mcu,
		[Parameter()]	[switch]	$State,
		[Parameter()]	[switch]	$S_State,
		[Parameter()]	[switch]	$Uptime,
		[Parameter()]	[switch]	$Svc,	
		[Parameter()]	[String]	$NodeID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " shownode "
	if($Listcols)
		{	$Cmd += " -listcols "
			$Result = Invoke-A9CLICommand -cmds  $Cmd
			return $Result
		}
	if($Showcols){	$Cmd += " -showcols $Showcols " }
	if($I)		{	$Cmd += " -i "		}
	if($D)		{	$Cmd += " -d " 		}
	if($Verbose_D){	$Cmd += " -verbose " }
	if($Fan)	{	$Cmd += " -fan " 	}
	if($Pci)	{	$Cmd += " -pci " 	}
	if($Cpu)	{	$Cmd += " -cpu " 	}
	if($Mem)	{	$Cmd += " -mem " 	}
	if($Drive) 	{	$Cmd += " -drive " 	}
	if($Ps) 	{	$Cmd += " -ps " 	}
	if($Mcu)	{	$Cmd += " -mcu " 	}
	if($State)	{	$Cmd += " -state " 	}
	if($S_State){	$Cmd += " -s " 		}
	if($Uptime)	{	$Cmd += " -uptime " }
	if($Svc) 	{	$Cmd += " -svc " 	}
	if($NodeID)	{ 	$Cmd += " $NodeID " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -1  
			$incre = "True"
			foreach ($s in  $Result[1..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")		
					$s= [regex]::Replace($s,"-","")		
					$s= $s.Trim()		
					if($incre -eq "True")
						{	$sTemp1=$s				
							$sTemp = $sTemp1.Split(',')							
							$sTemp[6] = "Control-Mem(MB)"
							$sTemp[7] = "Data-Mem(MB)"
							$newTemp= [regex]::Replace($sTemp,"^ ","")			
							$newTemp= [regex]::Replace($sTemp," ",",")				
							$newTemp= $newTemp.Trim()
							$s=$newTemp
						}
					Add-Content -Path $tempfile -Value $s
					$incre = "False"		
				}
			Import-Csv $tempFile 
			remove-item $tempFile	
		}
	if($Result.count -gt 1)	{	return  " Success : Executing Get-Node"}
	else					{	return  $Result	}
}
}

Function Get-A9Target
{
<#
.SYNOPSIS
	Show information about unrecognized targets.
.DESCRIPTION
	The command displays information about unrecognized targets.
.EXAMPLE
	PS:> Get-A9Target 
.EXAMPLE 
	PS:> Get-A9Target -Lun -Node_WWN 2FF70002AC00001F
.EXAMPLE 
	PS:> Get-A9Target -Lun -All
.EXAMPLE 	
	PS:> Get-A9Target -Inq -Page 0 -LUN_WWN  50002AC00001001F
.EXAMPLE 
	PS:> Get-A9Target -Inq -Page 0 -D -LUN_WWN  50002AC00001001F
.EXAMPLE 	
	PS:> Get-A9Target -Mode -Page 0x3 -D -LUN_WWN  50002AC00001001F 
.PARAMETER Lun
	Displays the exported Logical Unit Numbers (LUNs) from the unknown
	targets. Use the "all" specifier to display the exported LUNs from all
	of the unknown targets.
.PARAMETER Inq
	Display SCSI inquiry page information.
.PARAMETER Mode
	Display SCSI mode page information.
.PARAMETER Page
	Specify the SCSI page number for the inquiry and mode information.	<num> is a hex number. For SCSI inquiry information, the valid <num>
	is 0, 80, 83, and c0. For SCSI mode information, the valid <num> is 3 and 4. This option needs to be used together with -inq or -mode. If
	this option is not specified, the default <num> is 0.
.PARAMETER D
	Display the detail information of SCSI inquiry or mode page information.
.PARAMETER Force
	Specifies that the rescan is forced. If this option is not used, the rescan will be suppressed if the peer ports have already been rescanned within the last 10 seconds.
.PARAMETER Rescan
	Rescan the peer ports to find the unknown targets.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Lun,
		[Parameter()]	[switch]	$Inq,
		[Parameter()]	[switch]	$Mode,
		[Parameter()]	[ValidateSet('0','0x88','0x83','0xc0','0x3','0x4')]	
						[String]	$Page,
		[Parameter()]	[switch]	$D,
		[Parameter()]	[switch]	$Force,
		[Parameter()]	[switch]	$Rescan,
		[Parameter()]	[String] 	$Node_WWN,
		[Parameter()]	[String]	$LUN_WWN,
		[Parameter()]	[switch]	$All
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showtarget "
	if($Lun)	{	$Cmd += " -lun "} 
	if($All)	{	$Cmd += " all " }
	if($Inq)	{	$Cmd += " -inq " }
	if($Mode)	{	$Cmd += " -mode " } 
	if($Page)	{	$Cmd += " -page $Page " } 
	if($D)		{	$Cmd += " -d " }
	if($Force)	{	$Cmd += " -force " }
	if($Rescan)	{	$Cmd += " -rescan " }
	if($Node_WWN){	$Cmd += " $Node_WWN " }
	if($LUN_WWN){	$Cmd += " $LUN_WWN " }
	write-host "$Cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Show-A9PortARP
{
<#
.SYNOPSIS   
	The command shows the ARP table for iSCSI ports in the system.
.DESCRIPTION  
	The command shows the ARP table for iSCSI ports in the system.
.EXAMPLE
	PS:> Show-A9PortARP
.EXAMPLE
	PS:> Show-A9PortARP -NSP 1:2:3
.PARAMETER NSP
	Specifies the port for which information about devices on that port are displayed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[ValidatePattern("^\d:\d:\d")]	[String]	$NSP 			
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
Process	
{	$cmd= "showportarp "	
	if ($NSP)	{	$cmd+=" $NSP "	}
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if($Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count 		
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim() 	
					Add-Content -Path $tempFile -Value $s				
				}			
			Import-Csv $tempFile 
			remove-item $tempFile
		}	
	else{	return $Result	}
	if($Result.Count -gt 1)		{	return  " Success : Executing Show-PortARP"	}
	else						{	return  $Result	}	
} 
}

Function Show-A9UnrecognizedTargetsInfo
{
<#
.SYNOPSIS
	Show information about unrecognized targets.
.DESCRIPTION
	The command displays information about unrecognized targets.
.PARAMETER Lun
	Displays the exported Logical Unit Numbers (LUNs) from the unknown targets. Use the "all" specifier to display the exported LUNs from all of the unknown targets.
.PARAMETER Inq
	Display SCSI inquiry page information.
.PARAMETER Mode
	Display SCSI mode page information.
.PARAMETER Page
	Specify the SCSI page number for the inquiry and mode information. <num> is a hex number. For SCSI inquiry information, the valid <num>
	is 0, 80, 83, and c0. For SCSI mode information, the valid <num> is 3 and 4. This option needs to be used together with -inq or -mode. 
	If this option is not specified, the default <num> is 0.
.PARAMETER D
	Display the detail information of SCSI inquiry or mode page information.
.PARAMETER Force
	Specifies that the rescan is forced. If this option is not used, the rescan will be suppressed if the peer ports have already
	been rescanned within the last 10 seconds.
.PARAMETER VerboseE
	Display any errors during rescan over the peer ports.
.PARAMETER Rescan
	Rescan the peer ports to find the unknown targets.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
	inc
		Sort in increasing order (default).
	dec
		Sort in decreasing order.	
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.PARAMETER Node_WWN
	Indicates the World Wide Name (WWN) of the node.
.PARAMETER LUN_WWN
	Indicates the World Wide Name (WWN) of a LUN exported from an unknown target.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Lun,
		[Parameter()]	[switch]	$Inq,
		[Parameter()]	[switch]	$Mode,
		[Parameter()]	[String]	$Page,
		[Parameter()]	[switch]	$D,
		[Parameter()]	[switch]	$Force,
		[Parameter()]	[switch]	$VerboseE,
		[Parameter()]	[switch]	$Rescan,
		[Parameter()][ValidateSet('inc','dec')]	
						[String]	$Sortcol,
		[Parameter()]	[String]	$Node_WWN,
		[Parameter()]	[String]	$LUN_WWN
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showtarget "	
	if($Lun)		{	$Cmd += " -lun "}
	if($Inq)		{ 	$Cmd += " -inq "}
	if($Mode)		{	$Cmd += " -mode "	}
	if($Page)		{	$Cmd += " -page $Page "	}
	if($D)			{	$Cmd += " -d "}
	if($Force) 		{	$Cmd += " -force " }
	if($VerboseE)	{	$Cmd += " -verbose "}
	if($Rescan)		{	$Cmd += " -rescan "}
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol "}
	if($Node_WWN)	{	$Cmd += " $Node_WWN "}
	if($LUN_WWN)	{	$Cmd += " $LUN_WWN "}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Test-A9FCLoopback
{
<#
.SYNOPSIS
    Perform loopback tests on Fibre Channel ports.
.DESCRIPTION
    The checkport command performs loopback tests on Fibre Channel ports.
.PARAMETER Time <seconds_to_run>
    Specifies the number of seconds for the test to run using an integer from 0 to 300.
.PARAMETER Iter <iterations_to_run>
    Specifies the number of times for the test to run using an integer from 1 to 1000000.     
.PARAMETER PortNSP
    Specifies the port to be tested.
.PARAMETER Node
    Specifies the node using a number from 0 through 7.
.PARAMETER Slot
    Specifies the PCI slot in the specified node. Valid range is 0 - 9.
.PARAMETER Port
    Specifies the port using a number from 1 through 4.
.EXAMPLE
    Test-Port test is performed on port 0:0:1 a total of five times:

    PS:> Test-A9FCLoopback -iter 5 0:0:1

    Starting loopback test on port 0:0:1
    Port 0:0:1 completed 5 loopback frames in 0 seconds Passed
.NOTES
	This command requires a SSH type connection.
    Access to all domains is required to run this command.

    When both the -time and -iter options are specified, the first limit reached terminates the program. If neither are specified, the default is
    1,000 iterations. The total run time is always limited to 300 seconds even when not specified.
    The default loopback is an ELS-ECHO sent to the HBA itself.
#>
[CmdletBinding()]
param(
        [Parameter()]	[ValidateRange(0,300)]    		[int]    	$TimeInSeconds,		
        [Parameter()]   [ValidateRange(1,100000)]		[int]    	$Iter,
        [Parameter()]	[ValidatePatter("^\d:\d:\d")]	[String]    $PortNSP,
        [Parameter()]	[ValidateRange(0,7)]    		[int]    	$Node,		
        [Parameter()]   [ValidateRange(0,9)]			[int]    	$Slot,		
        [Parameter()]   [ValidateRange(1,4)]    		[int]    	$Port
    )	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd = "checkport "	
    if ($TimeInSeconds) {    $cmd += " -time $TimeInSeconds"    }
    if ($Iter) 			{    $cmd += " -iter $Iter"	    }
    if ($PortNSP) 		{    $cmd += "$PortNSP"		   }
    elseif (($Node) -and ($Slot) -and ($Port)) {    $cmd += "$($Node):$($Slot):$($Port)"    }
    else 				{           Return "Node, slot and plot details are required" }
    $Result = Invoke-A9CLICommand -cmds  $cmd
    return 	$Result	
}
}

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEB95Gp1C4zU
# 91Itn6WniAU9qMS1uJI3o0mTx5hxJiIBIcqkezGqyRt20B1qPufGJE5nAVDrFp4y
# D76XwJ04Ki9joIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhgwghoUAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQA+t0nJCKLbjFYX+W0owcns5LwP6gJLg30m4NJTKdeLS4JMAVP3rMGJO
# RBVZEVTjpu5h8ykNNfOqz7pMzvNxKY4wDQYJKoZIhvcNAQEBBQAEggGAExbMyTix
# uKPyBT89NbTMZjn5XVLSxEHjN28gsTAnEcflpeMNNk9VVs+P1CnrymjjmcxgcYMb
# M9UfHX03nV+0YEILOSX3LQFRT1zjRiPYxfBiHlKFbdBltR8/9DvrLjIPlMXRyyUk
# PThXHFE7SHtSDEV4dPzRUFobqTtmMb9ixTRD3BLqzv+yoEB0dOl7zYk2OgHAZEhF
# zi70YESB1ExYyPN6bb/I2GnVaqQz1FGfNuTm2JMwozL3N0XeYdb8fHMzCQYf6TIZ
# PsImptLudJ7/JgR0U+MaeCya68AkDCxrZtb3gUZl82ieEcKGdbgQbKslvyE9tbkC
# jy2W0cboHMudUGiVxLHpIfvuYjJ1Cc21pku7nk5Cg/xhnreGhd1TlkjfaBfrhp3z
# rkkI6MBWfn4/pIpTjqrRdurquiw9Z3Mz0I4uHtkUIA16WtGV1PtfF04pxT+Rogjq
# vLWvXtM68gX4/AErB3H0C5aFErPgxIA2AUiweQ+B79GWyiDd81ghz4O8oYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDBkhIfdKoR549gfEFQQ0GNuwtCWLmxabeLDkhiL
# 2OWKezNpmTVacX7HqIT+xrBmnjACEQDxRI197ZienNKyYzaNhLnwGA8yMDI0MDcz
# MTE5MjM1N1qgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVow
# SDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQD
# ExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVY
# wamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isg
# HMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFe
# xAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gp
# OWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28
# mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkH
# NwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58
# ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXH
# g2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W
# 1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK
# 8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn
# 783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+K
# PGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1I
# jrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP
# 2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ
# 5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON
# 1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S
# 88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbU
# uXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145
# WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6
# F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso
# /zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG
# 70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEM
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zC
# pyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf
# 1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x
# 4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEio
# ZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7ax
# xLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZ
# OjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJ
# l2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz
# 2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH
# 4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb
# 5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ
# 9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0g
# ADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs
# 7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq
# 3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/
# Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9
# /HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWoj
# ayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEB
# MHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgIFAKCB4TAaBgkq
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTE5
# MjM1N1owKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMDlcMOqSxAdmG+uSyzDfzU2AqIV+
# wnUPKtzlmXkL9Yh4poAoIGDxIfe6eL/pgdzwJzANBgkqhkiG9w0BAQEFAASCAgBv
# KmJhjjouVHhGi44CP0GoKl5cxRZcLqBP11aPsWIk8Pr9qApr3z7u8HHds6ZxagYg
# T/qg45q7yn+0nqoNVFwpdooIoNbXlcbka4REkzCCA2FW+Fx1YugnrJOOgvUMpfoZ
# eCNRoq1eeltFZ7v2+KUcPmXKAz3my5up4S2mK7Ik6OY4ABdeRqZ3nYz/aEtXqih1
# Kjp1jsrcsxA/xyCrCWye5ayFHcFxt4kInyRAtOPcmtegHOsyhYLPRi16sweMdBR2
# +/3trOeNijiEWTAjZ6UNahtSIQn20lERcEEkKCbs29/3Nw5Njfbjg+D5rH1X3Rli
# 5acUMqkpR39o8/F9FuOe5cY6UE1JuBzpnOexzMCCk6youEVYA+uEd6mJiwaQD2XT
# +cJ8HrQr2ilwxThRihLAs4S3GsX3oMmX8rEbiE5zhshEPeJgZTgOX8TtOnhuB1qW
# odrd9kZDzaDrh3KnqA0SEPrmwTu14fgB0ul/jgkHJ2bA4yZu+r6XeoQNCBWdDkUw
# bELIpgi6HFWltSPkzgQVMYVtLCilobNItjYe+s70s/2Eagaw6Wzg01Aa+IBXWivu
# NgAmjQGalTT98n81O2fkqdyVQ+ogacrgTWZ1l03uO0gBXItN3hR3BEJ3+HlHMguW
# BP9CGx9wAjs2rXLgjH+J7Wdavs0b3RHKJfD2M/p92Q==
# SIG # End signature block
