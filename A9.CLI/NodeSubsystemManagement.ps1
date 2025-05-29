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
.PARAMETER Time
	Specifies the number of seconds to illuminate the LEDs. For HPE 3PAR 7000 and HPE 3PAR 8000 storage systems, the default time to illuminate the LEDs is 15
	minutes with a maximum time of one hour. For STR (Safe to Remove) systems, the default time is one hour with a maximum time of one week. For all
	other systems, the default time is 60 seconds with a maximum time of 255 seconds. Issuing "Find-Node -t 0 <nodeid>" will turn off LEDs immediately.
.PARAMETER PowerSupply
	Only the service LED for the specified power supply will blink. Accepted values for <psid> are 0 and 1.
.PARAMETER Pci
	Only the service LED corresponding to the PCI card in the specified slot will blink. Accepted values for <slot> are 0 through 8.
.PARAMETER Fan
	Only the service LED on the specified node fan module will blink. Accepted values for <fanid> are 0 and 1 for HPE 3PAR 10000 systems.
	Accepted values for <fanid> are 0, 1 and 2 for HPE 3PAR 20000 systems.
.PARAMETER Drive
	Only the service LED corresponding to the node's internal drive will blink.
.PARAMETER Battery
	Only the service LED on the battery backup unit will blink.
.PARAMETER NodeID
	Indicates which node the locatenode operation will act on. Accepted
	values are 0 through 7.
.EXAMPLE
	PS:> Fine-A9Node -Time 360 -PowerSupply 0
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Time,
		[Parameter()]	[String]	$PowerSupply,
		[Parameter()]	[String]	$Pci,
		[Parameter()]	[String]	$Fan,
		[Parameter()]	[switch]	$Drive,
		[Parameter()]	[switch]	$Battery,
		[Parameter()]	[String]	$NodeID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " locatenode "
	if($Time)		{	$Cmd += " -t $T " }
	if($PowerSupply){	$Cmd += " -ps $Ps " 	}
	if($Pci) 		{	$Cmd += " -pci $Pci " 	}
	if($Fan)		{	$Cmd += " -fan $Fan " 	}
	if($Drive)		{	$Cmd += " -drive " 		}
	if($Battery)	{	$Cmd += " -bat " 		}
	if($NodeID) 	{	$Cmd += " $NodeID " 	}
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER Time
	Specifies the number of seconds to illuminate or blink the LEDs. default may vary depending on the system model. For example, the default time 
	for HPE 3PAR 7000 and HPE 3PAR 8000 storage systems is 15 minutes, with a maximum time of one hour. The default time for 9000 and 20000 systems 
	is 60 minutes, with a maximum of 604,800 seconds (one week).
.PARAMETER NodeList
	Specifies a comma-separated list of nodes on which to illuminate or blink LEDs. The default is all nodes.
.PARAMETER NoCage
	Specifies that LEDs on the drive cages should not illuminate or blink. The default is to illuminate or blink LEDs for all cages in the system.
.EXAMPLE
	In the following example, a storage system is identified by illuminating or blinking the LEDs on all drive cages in the system for 90 seconds. 
	
	PS:> Find-A9System -Time 90
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Time,
		[Parameter()]	[String]	$NodeList,
		[Parameter()]	[switch]	$NoCage
)
Begin
{	Test-A9Connection -CLientType 'SshClient'
}
process
{	$Cmd = " locatesys "
	if($Time) 		{	$Cmd += " -t $T " }
	if($NodeList) 	{	$Cmd += " -nodes $NodeList " }
	if($NoCage)		{	$Cmd += " -nocage " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Ping-A9RCIPPorts
{
<#
.SYNOPSIS
	Verifying That the Servers Are Connected
.DESCRIPTION
	Verifying That the Servers Are Connected.
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER Serial
	Specifies the serial number of the battery using a limit of 31 alphanumeric characters.
	This option is not supported on HPE 3PAR 10000 and 20000 systems.
.PARAMETER Expiration	
	Specifies the expiration date of the battery (mm/dd/yyyy). The expiration date cannot extend beyond 2037.
.PARAMETER LogReset
	Specifies that the battery test log is reset and all previous test log entries are cleared.
.PARAMETER RechargeReset
	Specifies that the battery recharge time is reset and that 10 hours of charging time are required for the battery to be fully charged. This option is deprecated.
.PARAMETER Node_ID
	Specifies the node number where the battery is installed. Node_ID is an integer from 0 through 7.
.PARAMETER Powersupply_ID
	Specifies the power supply number on the node using either 0 (left side from the rear of the node) or 1 (right side from the rear of the node).
.PARAMETER Battery_ID
	Specifies the battery number on the power supply where 0 is the first battery.
.EXAMPLE
	The following example resets the battery test log and the recharging time
	for a newly installed battery on node 2, power supply 1, and battery 0, with
	an expiration date of July 4, 2006:
	
	PS:> Set-A9Battery -X " 07/04/2006" -Node_ID 2 -Powersupply_ID 1 -Battery_ID 0	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]					[String]	$Serial,
	[Parameter()]					[String]	$Expiration,
	[Parameter()]					[switch]	$LogReset,
	[Parameter()]					[switch]	$RechargeReset,
	[Parameter()]					[String]	$Node_ID,
	[Parameter(Mandatory=$True)]	[String]	$Powersupply_ID,
	[Parameter()]					[String]	$Battery_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{	$Cmd = " setbattery "
	if($Serial)			{	$Cmd += " -s $Serial "}
	if($Expiration)		{	$Cmd += " -x $Expiration " }
	if($LogReset)		{	$Cmd += " -l " }
	if($RechargeReset)	{	$Cmd += " -r " }
	if($Node_ID)		{	$Cmd += " $Node_ID "	}
	if($Powersupply_ID)	{	$Cmd += " $Powersupply_ID "}
	if($Battery_ID)		{	$Cmd += " $Battery_ID "}
	write-verbose "Executing the following SSH command `n`t $cmd"
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
	PS:> Set-A9HostPorts -RCFCConfiguration -NSP 1:2:3
	
	For RCFC port  
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
Param(		[Parameter(ParameterSetName='FCCF',Mandatory)]		[String]	$FCConfigFile,
			[Parameter(ParameterSetName='ICF',Mandatory)]		[String]	$iSCSIConfigFile,		
			[Parameter(ParameterSetName='LDCF',Mandatory)]		[String]	$LDConfigFile,
			[Parameter(ParameterSetName='RCIPFCCF',Mandatory)]	[switch]	$RCIPConfiguration,
			[Parameter(ParameterSetName='RCFCCF',Mandatory)]	[switch]	$RCFCConfiguration,
			[Parameter(ParameterSetName='RCIPFCCF',Mandatory)]
																[String]	$Port_IP,
			[Parameter(ParameterSetName='RCIPFCCF',Mandatory)]	
																[String]	$NetMask,
			[Parameter(ParameterSetName='RCIPFCCF',Mandatory)]	
			[Parameter(ParameterSetName='RCFCCF',Mandatory)]	[String]	$NSP
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	if ($RCIPConfiguration)
		{	$Cmds="controlport rcip addr -f $Port_IP $NetMask $NSP "
			write-verbose "Executing the following SSH command `n`t $cmdS"
			$result = Invoke-A9CLICommand -cmds $Cmds
			return $result
		}
	if ($RCFCConfiguration)
		{	$Cmds="controlport rcfc init -f $NSP "
			write-verbose "Executing the following SSH command `n`t $cmdS"
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
							write-verbose "Executing the following SSH command `n`t $cmdS"
							$Cmds = "controlport offline -f $Port"
							write-verbose "Executing the following SSH command `n`t $cmdS"
							Invoke-A9CLICommand -cmds $Cmds
							Write-Verbose  "Configuring port $Port as host " 
							write-verbose "Executing the following SSH command `n`t $cmdS"
							$Cmds= "controlport config host -ct point -f $Port"
							write-verbose "Executing the following SSH command `n`t $cmdS"
							Invoke-A9CLICommand -cmds $Cmds
							Write-Verbose  "Resetting port $Port " 
							$Cmds="controlport rst -f $Port"
							write-verbose "Executing the following SSH command `n`t $cmdS"
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
									write-verbose "Executing the following SSH command `n`t $cmdS"
									Invoke-A9CLICommand -cmds $Cmds			
								}
							else
								{	Write-Verbose  "Setting IP address and subnet on port $Port " 
									$Cmds = "controliscsiport addr $IPAddr $IPSubnet -f $Port"
									write-verbose "Executing the following SSH command `n`t $cmdS"
									Invoke-A9CLICommand -cmds $Cmds
									Write-Verbose  "Setting gateway on port $Port " 
									$Cmds = "controliscsiport gw $IPgw -f $Port"
									write-verbose "Executing the following SSH command `n`t $cmdS"
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
.PARAMETER Serial
	Specify the serial number. It is up to 8 characters in length.
.PARAMETER PS_ID
	Specifies the power supply ID.
.PARAMETER Node_ID
	Specifies the node ID.
.EXAMPLE
	PS:> Set-A9NodeProperties -PS_ID 1 -S xxx -Node_ID 1
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param( 	[Parameter(Mandatory)]	[String]	$PS_ID,
		[Parameter(Mandatory)]	[String]	$Serial,
		[Parameter()]			[String]	$Node_ID	
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " setnode ps "
	if($PS_ID)		{	$Cmd += " $PS_ID "	}	
	if($Serial) 	{	$Cmd += " -s $S " 	} 
	if($Node_ID) 	{	$Cmd += " $Node_ID "}
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER Tzlist
	Displays a timezone within a group, if a group is specified. If a group is not specified, displays a list of valid groups.
.PARAMETER TzGroup
	Displays a timezone within a group, if a group is specified. it alwase use with -Tzlist.
.EXAMPLE
	The following example displays the timezones with the -tzlist option:
	
	PS:> Set-A9NodesDate -Tzlist
.EXAMPLE
	The following example narrows down the list to the required timezone of Etc:

	PS:> Set-A9NodesDate -Tzlist -TzGroup Etc
.EXAMPLE
	The following example shows the timezone being set:

	PS:> Set-A9NodesDate  -Tzlist -TzGroup "Etc/GMT"
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER Detailed
	Specifies that detailed battery information, including battery test information, serial numbers, and expiration dates, is displayed.
.PARAMETER Log
	Show battery test log information. This option is not supported on HPE 3PAR 7000 nor on HPE 3PAR 8000 series systems.
.PARAMETER Inventory
	Show battery inventory information.
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
	[Parameter()]	[switch]	$Detailed,
	[Parameter()]	[switch]	$Log,
	[Parameter()]	[switch]	$Inventory,
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
	if($Detailed)	{	$Cmd += " -d " 		}
	if($Log)		{	$Cmd += " -log "	}
	if($Inventory)	{	$Cmd += " -i "		}
	if($Svc)		{	$Cmd += " -svc "	}
	if($Node_ID)	{	$Cmd += " $Node_ID "}
	$Cmd
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
}
End
{	if($Result.count -gt 1)
		{	if($Detailed)	
					{	Return  $Result		}
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
						$Result = Import-Csv $tempFile 
						Remove-Item $tempFile
					}
		}
	Return  $Result
}
}

Function Show-A9EEProm
{
<#
.SYNOPSIS
	Show node EEPROM information.
.DESCRIPTION
	The command displays node EEPROM log information.
.PARAMETER Dead
	Specifies that an EEPROM log for a node that has not started or successfully joined the cluster be displayed. If this option is used, it must be followed by a non empty list of nodes.
.PARAMETER Node_ID
	Specifies the node ID for which EEPROM log information is retrieved. Multiple node IDs are separated with a single space (0 1 2). 
	If no specifiers are used, the EEPROM log for all nodes is displayed.
.EXAMPLE
	The following example displays the EEPROM log for all nodes:
	PS:> Show-A9EEProm
.EXAMPLE
	PS:> Show-A9EEProm -Node_ID 0
.EXAMPLE
	PS:> Show-A9EEProm -Dead 
.EXAMPLE
	PS:> Show-A9EEProm -Dead -Node_ID 0
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
param(	[Parameter()]	
		[ValidateSet("d","param","fan","space","vvspace","domainspace","desc","devtype","date")]
						[String]	$Option
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
process
{	$sysinfocmd = "showsys "
	$Option = $Option.toLower()
	if ($Option)
		{	$sysinfocmd+=" -$option "
			if($Option -eq "date")
				{	write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  "showdate"
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
					$Result = Import-Csv $tempFile
					Remove-Item $tempFile
				}	
			else
				{	write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $sysinfocmd
				}
		}
	else
		{	write-verbose "Executing the following SSH command `n`t $cmd"
			$Result = Invoke-A9CLICommand -cmds  $sysinfocmd 
		}
	return $Result		
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
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
.PARAMETER VendorName
	Specifies that the firmware vendor from the SCSI database file is displayed.
.PARAMETER Load
	Reloads the SCSI database file into the system.
.PARAMETER All
	Specifies current and past firmware entries are displayed. If not specified, only current entries are displayed.
.EXAMPLE
	PS:> Show-A9Firmwaredb
.EXAMPLE
	PS:> Show-A9Firmwaredb -VendorName xxx
.EXAMPLE
	PS:> Show-A9Firmwaredb -All
.EXAMPLE
	PS:> Show-A9Firmwaredb -Load
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$VendorName,
		[Parameter()]	[switch]	$Load,
		[Parameter()]	[switch]	$All	
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showfirmwaredb "
	if($VendorName)	{	$Cmd += " -n $VendorName "}
	if($Load)		{	$Cmd += " -l "	}
	if($All)		{	$Cmd += " -all " }
	write-verbose "Executing the following SSH command `n`t $cmd"
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
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
		[Parameter()]	[Switch]	$Begin,
		[parameter()]	[switch]	$ShowRaw
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if ($ShowRaw) { return $Result }
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER Detailed
	Show detailed information.
.EXAMPLE 
	The following example displays the status of the system administration network interfaces:
	PS:> Show-A9NetworkDetail -D
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " shownet "
	if($Detailed)	{	$Cmd += " -d "}
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER Node_ID
	Specifies the ID of the node whose environment status is displayed. Multiple node IDs can be specified as a series of integers separated by
	a space (1 2 3). If no option is used, then the environment status of all nodes is displayed.
.EXAMPLE
	The following example displays the operating environment status for all nodes
	in the system:

	PS:> Show-A9NodeEnvironmentStatus
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER Detailed
    Specifies that more detailed information about the iSCSI session is displayed. If this option is not used, then only summary information
    about the iSCSI session is displayed.
.PARAMETER ConnectionState
    Specifies the connection state of current iSCSI sessions. If this option is not used, then only summary information about the iSCSI session is displayed.
.PARAMETER NSP
	Requests that information for a specified port is displayed.
.EXAMPLE
	PS:> Show-A9iSCSISession
.EXAMPLE
	PS:> Show-A9iSCSISession -NSP 1:2:1
.EXAMPLE
	PS:> Show-A9iSCSISession -Detailed -NSP 1:2:1
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
			write-verbose "Executing the following SSH command `n`t $cmd"
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER NSP
	Specifies the port for which information about devices on that port are displayed.
.EXAMPLE	
	PS:> Show-PortISNS
.EXAMPLE	
	PS:> Show-PortISNS -NSP 1:2:3
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if($Result -match "N:S:P")
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -2 		
			foreach ($s in  $Result[0..$LastItem] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempFile -Value $s				
				}			
			$Result = Import-Csv $tempFile 
			remove-item $tempFile
		}
	if($Result -match "N:S:P")	{	write-host " Success : Executing Show-PortISNS" -ForegroundColor green	}
	return  $Result
}	
} 

Function Get-A9SystemManager
{
<#
.SYNOPSIS
	Show system manager startup state.
.DESCRIPTION
	The displays startup state information about the system manager.
.PARAMETER Detailed
	Shows additional detailed information if available.
.PARAMETER Locks
	Shows field service diagnostics for System Manager specific Config Locks and MCALLs, and system-wide ioctl system calls.
.EXAMPLE 
	PS:> Show-A9SystemManager -Detailed

	System is up and running from 2024-10-28 13:57:01 MDT
.EXAMPLE
	PS:> Show-A9SystemManager -Locks

	Config lock hold PID:        0
	Config lock hold seconds:    0
	System Manager ioctl count:  7
	System ioctl count:          10
	System ioctl detail counts:
		-All ioctl Count- ------------------Barrier ioctl Counts-------------------
	Node             Total Not Defined System Manager TOC Server PD Scrub DAR Server
		0                 3           0              0          0        0          0
		1                 1           0              0          0        0          0
		2                 3           0              0          0        0          0
		3                 3           0              0          0        0          0
	----------------------------------------------------------------------------------
	Totals                10           0              0          0        0          0
	System ioctl detail:
	Node Sec Outstanding     PID Source PID Source Node Type      Number Name
	0               0 8401245         na          na NA      c056141d VVCMD_GET_NEXT_DDS_REQ
	0               0 8399248         na          na NA      c056141e VVCMD_GET_NEXT_DDS_REP
	0               0 8401453       7627           1 Sys Mgr c0561462 SCCMD_GETINFO_IOCTL
	1               0 8390406       7627           1 Sys Mgr c0561462 SCCMD_GETINFO_IOCTL
	2               0 8399235         na          na NA      c056141e VVCMD_GET_NEXT_DDS_REP
	2               0 8389784         na          na NA      c056141d VVCMD_GET_NEXT_DDS_REQ
	2               0 8389780       7627           1 Sys Mgr c0561462 SCCMD_GETINFO_IOCTL
	3               0 8389846         na          na NA      c056141d VVCMD_GET_NEXT_DDS_REQ
	3               0 8401202         na          na NA      c056141e VVCMD_GET_NEXT_DDS_REP
	3               0 8401403       7627           1 Sys Mgr c0561462 SCCMD_GETINFO_IOCTL
	-------------------------------------------------------------------------------------------
	10 Total Count
	System Manager mcall count:  2
	System Manager mcall detail:
		PID mSec Outstanding Name
	2533668                0 MC_LOCKINFO
	------------------------------------
		1 Total Count
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[switch]	$Locks
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showsysmgr "
	if($Detailed)	{	$Cmd += " -d "	}
	if($Locks)		{	$Cmd += " -l "}
	write-verbose "Executing the following SSH command `n`t $cmd"
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
					# $s= [regex]::Replace($s,"N:S:P","Device")
					$s= $s.Trim() 	
					Add-Content -Path $tempFile -Value $s				
				}
			$Result = Import-Csv $tempFile
			remove-item $tempFile
			write-host 'Success : Executing Get-HostPorts' -ForegroundColor green
		}
	return $Result	
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
	and Power Supplies. For the Alletra MP B10000, no options are valid.
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -1  
			$incre = "True"
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")		
					$s= [regex]::Replace($s,"-","")		
					$s= $s.Trim()		
					if($incre -eq "True")
						{	$sTemp1=$s				
							$sTemp = $sTemp1.Split(',')							
							# $sTemp[6] = "Control-Mem(MB)"
							# $sTemp[7] = "Data-Mem(MB)"
							$newTemp= [regex]::Replace($sTemp,"^ ","")			
							$newTemp= [regex]::Replace($sTemp," ",",")				
							$newTemp= $newTemp.Trim()
							$s=$newTemp
						}
					Add-Content -Path $tempfile -Value $s
					$incre = "False"		
				}
			$Result = Import-Csv $tempFile 
			remove-item $tempFile	

		}
	if($Result.count -gt 1)	{	write-host " Success : Executing Get-Node" -ForegroundColor green }
	return  $Result
}
}

Function Get-A9Target
{
<#
.SYNOPSIS
	Show information about unrecognized targets.
.DESCRIPTION
	The command displays information about unrecognized targets.

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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER NSP
	Specifies the port for which information about devices on that port are displayed.
.EXAMPLE
	PS:> Show-A9PortARP
.EXAMPLE
	PS:> Show-A9PortARP -NSP 1:2:3
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
	write-verbose "Executing the following SSH command `n`t $cmd"
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
.PARAMETER Detailed
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
		[Parameter()]	[switch]	$Detailed,
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
	if($Detailed)	{	$Cmd += " -d "}
	if($Force) 		{	$Cmd += " -force " }
	if($VerboseE)	{	$Cmd += " -verbose "}
	if($Rescan)		{	$Cmd += " -rescan "}
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol "}
	if($Node_WWN)	{	$Cmd += " $Node_WWN "}
	if($LUN_WWN)	{	$Cmd += " $LUN_WWN "}
	write-verbose "Executing the following SSH command `n`t $cmd"
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
    write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $cmd
    return 	$Result	
}
}

# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDakkyHwBku
# HsnPz2vSK60wB21MEzYWpBLi8sa7QVNqsOxRb66bUlN2ke7bvKkJ+BkGagiNIOs0
# rI0+36V4G9gKoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG58wghubAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQCZVqJCWobbB89QAOikT50I4B23URhk8UVnAxn8vCIsKlGzPuaYgNsOC
# j/Y7yZ9aisLvhtuaEroLi/SVm3qmanowDQYJKoZIhvcNAQEBBQAEggGAY8rCnlHo
# CkAjW9w+C1m4UrjMxcr0ijXey06V/DBEaMvQX0viImbzczNAVL7HCcrElOsw8FBp
# D3HlcRv1EhVcsxh1PMHktTikzmAwP8Ie8Nw3P/odBUCYIzPS4/nEKBUWudPPVOT5
# AtLlajCCIkaWNwDjza7FyWxqi2m8Z0Coyj9oqpAeLT68qBGqHiTogp3YI/orV3SR
# h4HChgZ0FswYoKaKajd6cecElxuuFONdT3iKlqKs3jUhMSHEAJLyuulDYYxjABww
# AgSI5A6F3Kgge7cE6MclvV45SIx+9LGC9LGEHRX+Gw7cRKCCVBn3OBacqwha+oRI
# PqcnDXoNKEpLpba5kKp/meNkaCFt4YTU/yJo261CztQRyXQX7D/bBoQdh24Vivf5
# 2hXPlmQWZK85UUUXhFXuhQBQ7Cm6GYTs8XggYZbmM4cxBisUdCwFDYDetnBRZR4c
# dV+3UrRklcn92ElEs0tMmJ8mOfQ6gji6pCv4l/lTAlXcWBBieIuIJz1toYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMORbr/24fCT16iAyS1qrga8433dmFKYz
# HIKfSrT90lgnq0aYIsXXJoI5huNAop+bZwIUW4hRO/dbc3UwZNa2rGIuAm5AATIY
# DzIwMjUwNTE1MDIyMDM3WqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
# c3QgWW9ya3NoaXJlMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMT
# J1NlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNqCCEwQwggZi
# MIIEyqADAgECAhEApCk7bh7d16c0CIetek63JDANBgkqhkiG9w0BAQwFADBVMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNTAzMjcwMDAw
# MDBaFw0zNjAzMjEyMzU5NTlaMHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5XZXN0
# IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzYwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDThJX0bqRTePI9EEt4Egc83JSBU2dhrJ+w
# Y7JgReuff5KQNhMuzVytzD+iXazATVPMHZpH/kkiMo1/vlAGFrYN2P7g0Q8oPEcR
# 3h0SftFNYxxMh+bj3ZNbbYjwt8f4DsSHPT+xp9zoFuw0HOMdO3sWeA1+F8mhg6uS
# 6BJpPwXQjNSHpVTCgd1gOmKWf12HSfSbnjl3kDm0kP3aIUAhsodBYZsJA1imWqkA
# VqwcGfvs6pbfs/0GE4BJ2aOnciKNiIV1wDRZAh7rS/O+uTQcb6JVzBVmPP63k5xc
# ZNzGo4DOTV+sM1nVrDycWEYS8bSS0lCSeclkTcPjQah9Xs7xbOBoCdmahSfg8Km8
# ffq8PhdoAXYKOI+wlaJj+PbEuwm6rHcm24jhqQfQyYbOUFTKWFe901VdyMC4gRwR
# Aq04FH2VTjBdCkhKts5Py7H73obMGrxN1uGgVyZho4FkqXA8/uk6nkzPH9QyHIED
# 3c9CGIJ098hU4Ig2xRjhTbengoncXUeo/cfpKXDeUcAKcuKUYRNdGDlf8WnwbyqU
# blj4zj1kQZSnZud5EtmjIdPLKce8UhKl5+EEJXQp1Fkc9y5Ivk4AZacGMCVG0e+w
# wGsjcAADRO7Wga89r/jJ56IDK773LdIsL3yANVvJKdeeS6OOEiH6hpq2yT+jJ/lH
# a9zEdqFqMwIDAQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNh
# lxmiMpswHQYDVR0OBBYEFIhhjKEqN2SBKGChmzHQjP0sAs5PMA4GA1UdDwEB/wQE
# AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1Ud
# IARDMEEwNQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8v
# Y3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5j
# cmwwegYIKwYBBQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYB
# BQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IB
# gQACgT6khnJRIfllqS49Uorh5ZvMSxNEk4SNsi7qvu+bNdcuknHgXIaZyqcVmhrV
# 3PHcmtQKt0blv/8t8DE4bL0+H0m2tgKElpUeu6wOH02BjCIYM6HLInbNHLf6R2qH
# C1SUsJ02MWNqRNIT6GQL0Xm3LW7E6hDZmR8jlYzhZcDdkdw0cHhXjbOLsmTeS0Se
# RJ1WJXEzqt25dbSOaaK7vVmkEVkOHsp16ez49Bc+Ayq/Oh2BAkSTFog43ldEKgHE
# DBbCIyba2E8O5lPNan+BQXOLuLMKYS3ikTcp/Qw63dxyDCfgqXYUhxBpXnmeSO/W
# A4NwdwP35lWNhmjIpNVZvhWoxDL+PxDdpph3+M5DroWGTc1ZuDa1iXmOFAK4iwTn
# lWDg3QNRsRa9cnG3FBBpVHnHOEQj4GMkrOHdNDTbonEeGvZ+4nSZXrwCW4Wv2qyG
# DBLlKk3kUW1pIScDCpm/chL6aUbnSsrtbepdtbCLiGanKVR/KC1gsR0tC6Q0RfWO
# I4owggYUMIID/KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUA
# MFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNV
# BAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AM2Y2ENBq26CK+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStS
# VjeYXIjfa3ajoW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQ
# BaCxpectRGhhnOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE
# 9cbY11XxM2AVZn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExS
# Lnh+va8WxTlA+uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OII
# q/fWlwBp6KNL19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGd
# F+z+Gyn9/CRezKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w
# 76kOLIaFVhf5sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4Cllg
# rwIDAQABo4IBXDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUw
# HQYDVR0OBBYEFF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjAS
# BgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28u
# Y29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEF
# BQcBAQRwMG4wRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0O
# NVgMnoEdJVj9TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc
# 6ZvIyHI5UkPCbXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1
# OSkkSivt51UlmJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz
# 2wSKr+nDO+Db8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y
# 4Il6ajTqV2ifikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVM
# CMPY2752LmESsRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBe
# Nh9AQO1gQrnh1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupia
# AeNHe0pWSGH2opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU
# +CCQaL0cJqlmnx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/Sjws
# usWRItFA3DE8MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7
# xpMeYRriWklUPsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs6
# 56Oz3TbLyXVoMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAs
# BgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJ
# BZvMWhUP2ZQQRLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQn
# Oh2qmcxGzjqemIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypo
# GJrruH/drCio28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0p
# KG9ki+PC6VEfzutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13j
# QEV1JnUTCm511n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9
# YrcmXcLgsrAimfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/y
# Vl4jnDcw6ULJsBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVg
# h60KmLmzXiqJc6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/
# OLoanEWP6Y52Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+Nr
# LedIxsE88WzKXqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58N
# Hs57ZPUfECcgJC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9U
# gOHYm8Cd8rIDZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1Ud
# DwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0
# eS5jcmwwNQYIKwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3
# OyWM637ayBeR7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJ
# JlFfym1Doi+4PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0m
# UGQHbRcF57olpfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTw
# bD/zIExAopoe3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i
# 111TW7HV1AtsQa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGe
# zjM6CRpcWed/ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+
# 8aW88WThRpv8lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH
# 29308ZkpKKdpkiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrs
# xrYJD+3f3aKg6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6
# Ii8+CQOYDwXM+yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz
# 7NgAnOgpCdUo4uDyllU9PzGCBJIwggSOAgEBMGowVTELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMg
# VGltZSBTdGFtcGluZyBDQSBSMzYCEQCkKTtuHt3XpzQIh616TrckMA0GCWCGSAFl
# AwQCAgUAoIIB+TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTI1MDUxNTAyMjAzN1owPwYJKoZIhvcNAQkEMTIEMM3ZY57V1gjjCrMI
# j4xMalgig19UA5SKO/fK6LGZdGOpDxdVZT7AzR0RB55u79XvqTCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAVkgbMBTCgT6D0LP0w0m8J7ULDoxuLVTJaLaYNjp9J/fpdOoeOi2+E7BU
# 8wI1BDE6YPQNhsOKtQRdjGGl2Nqyd7C9D6WyIhaxWfDqLwqDkd4ErYI+aGj+AZUl
# aryuYdyrJFlWGK+92G6GHOVWq6CRJ3It9g03q12jyTlPUuA5s3MnTe5LELbJ5FDP
# E4lI6zNgNVxHxzUW+KcueHVIQwpP3mW+AQAcxf3Q2zPkSMpp4NyotolFIGEdaIgE
# UEFsQzYIpWcHZ1X80Sx6qjVQLBV4aRi9EVsJerx6jdajZDNE49DCn3sORwXcdKhF
# 2EAr+ebKfLacq8Fa/GytFgp7pIpOkOcQ7k+LVpQUXl/yEL+OGR6JJJCII5AiqsH0
# VfjsXJ33aejWfIWwlXadt6WAuxapT35NpNzn2dDi2tCp5CKOWnRZvnnMc0tZH3el
# eNu0AccICc6dUnGnezlIP9EeNCVKKYuYeYXTz/y4LnbFxZLH/FZHSsyYyL0YgIwr
# 7b1L9RmoGiT6QI6TWgnvm8N1XcclDt7KtLbvgiXpY1fN+mGv0Le3+X5wu2bLNtt7
# +0QtHqaaj6fsfqXGX7PPhTQ80tcRBfqR63Ev7f0GcHwFIW5eWMzRz4h6xYOSE7kE
# nQcgMYUexz+bRljyPcHEWhpPvUzdpikjAYJZmV83oAyUWzmFl90=
# SIG # End signature block
