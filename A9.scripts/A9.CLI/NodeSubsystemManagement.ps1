## 	©2025 Hewlett Packard Enterprise Development LP

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
	This option is not valid for B10K series devices.
.PARAMETER Pci
	Only the service LED corresponding to the PCI card in the specified slot will blink. Accepted values for <slot> are 0 through 8.
	This option is not valid for B10K series devices.
.PARAMETER Fan
	Only the service LED on the specified node fan module will blink. Accepted values for <fanid> are 0 and 1 for HPE 3PAR 10000 systems.
	Accepted values for <fanid> are 0, 1 and 2 for HPE 3PAR 20000 systems.
	This option is not valid for B10K series devices.
.PARAMETER Drive
	Only the service LED corresponding to the node's internal drive will blink.
	This option is not valid for B10K series devices.
.PARAMETER Battery
	Only the service LED on the battery backup unit will blink. This option is not valid for B10K series devices.
.PARAMETER EnclosureBay
	This will allow the array to light the indicater LED on a specific enclosure, format should look like 0:3 (number:number)
.PARAMETER NodeID
	Indicates which node the locatenode operation will act on. Accepted
	values are 0 through 7.
.EXAMPLE
	PS:> Fine-A9Node -Time 360 -PowerSupply 0
.NOTES
	This command utilizes the SSH command 'LocateNode'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]
		[ValidateRange(0,255)]							[int]		$Time,
		[Parameter(ParameterSetName="PS",mandatory)]	
		[ValidateRange(0,1)]							[int]		$PowerSupply,
		[Parameter(ParameterSetName="PCI",mandatory)]	
		[ValidateRange(3,5)]							[int]		$Pci,
		[Parameter(ParameterSetName="FAN",mandatory)]	[String]	$Fan,
		[Parameter(ParameterSetName="Drive",mandatory)]	[switch]	$Drive,
		[Parameter(ParameterSetName="Batt",mandatory)]	[switch]	$Battery,
		[Parameter(ParameterSetName="EB",mandatory)]
		[ValidatePattern('^\d{1}:\d{1}')]				[switch]	$EnclosureBay,
		[Parameter(mandatory)]							[String]	$NodeID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " locatenode "
	if($Time)		{	$Cmd += " -t $Time " 	}
	if($PowerSupply){	$Cmd += " -ps $PowerSupply " }
	if($Pci) 		{	$Cmd += " -pci $Pci " 	}
	if($Fan)		{	$Cmd += " -fan $Fan " 	}
	if($Drive)		{	$Cmd += " -drive " 		}
	if($Battery)	{	$Cmd += " -bat " 		}
	$Cmd += " $NodeID "
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
	This command utilizes the SSH command 'LocateSys'
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
	This command utilizes the SSH command 'ControlPort', 'RcIP', 'Ping'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
Param(		[Parameter(Mandatory)]			[string]	$IP_address,
			[Parameter(Mandatory)]	
			[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
											[String]	$NSP,
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
.PARAMETER NodeID
	Specifies the node number where the battery is installed. Node_ID is an integer from 0 through 7.
.PARAMETER PowersupplyID
	Specifies the power supply number on the node using either 0 (left side from the rear of the node) or 1 (right side from the rear of the node).
.PARAMETER BatteryID
	Specifies the battery number on the power supply where 0 is the first battery.
.EXAMPLE
	The following example resets the battery test log and the recharging time
	for a newly installed battery on node 2, power supply 1, and battery 0, with
	an expiration date of July 4, 20027:
	
	PS:> Set-A9Battery -Expiration "07/04/2027" -Node_ID 2 -Powersupply_ID 1 -Battery_ID 0	
.EXAMPLE
	The following set resets the logs associated with this batter
	
	PS:> Set-A9Battery -LogReset -NodeId 2 -PowersupplyId 1 -BatteryId 0	
.NOTES
	This command utilizes the SSH command 'SetBattery'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter(ParameterSetName='Expire',Mandatory)]
	[ValidatePattern("^\d{2}/\/d{2}/\d{4}")]			[String]	$Expiration,
	[Parameter(ParameterSetName='LogReset',Mandatory)]	[switch]	$LogReset,
	[Parameter(ParameterSetName='LogReset',Mandatory)]
	[Parameter(ParameterSetName='Expire',Mandatory)]
	[ValidateRange(0,7)]								[int]		$NodeID,
	[Parameter(ParameterSetName='LogReset',Mandatory)]
	[Parameter(ParameterSetName='Expire',Mandatory)]
	[ValidateRange(0,1)]								[int]		$PowersupplyID,
	[Parameter(ParameterSetName='LogReset',Mandatory)]
	[Parameter(ParameterSetName='Expire',Mandatory)]	
	[ValidateRange(0,7)]								[int]		$BatteryID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{	$Cmd = " setbattery "
	if($Expiration)		{	$Cmd += " -x $Expiration " }
	if($LogReset)		{	$Cmd += " -l " }
	if($NodeID)			{	$Cmd += " $NodeID "	}
	if($PowersupplyID)	{	$Cmd += " $PowersupplyID "}
	if($BatteryID)		{	$Cmd += " $BatteryID "}
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
	This command utilizes the SSH command 'ControlPort'
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
	This command utilizes the SSH command 'ControlPort'
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
			[Parameter(ParameterSetName='RCFCCF',Mandatory)]
			[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
																[String]	$NSP
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

Function Set-A9NodePowerSupplyId
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
	This command utilizes the SSH command 'SetNode'
	This command requires a SSH type connection. Does not exist on the Alletra B10000
#>
[CmdletBinding()]
param( 	[Parameter(Mandatory)]	[String]	$PowerSupplyID,
		[Parameter(Mandatory)]	[String]	$SerialNumber,
		[Parameter(Mandatory)]	[String]	$NodeID	
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " setnode ps "
	if($PowerSupplyID)		{	$Cmd += " $PowerSupplyID "	}	
	if($SerialNumber) 		{	$Cmd += " -s $SerialNumber " 	} 
	if($NodeID) 			{	$Cmd += " $NodeID "}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Set-A9Date
{
<#
.SYNOPSIS
	Sets date and time information.
.DESCRIPTION
	The command allows you to set the system time and date on all nodes.
.PARAMETER GetTimeZoneList
	Displays the valid timezones.
.PARAMETER Timezone	
	Allows you to set the timezone.
.PARAMETER MMDDhhmm
	Allows you to set the Month (MM), Day (DD), hour (HH) using a 24 hour clock, and Minute (MM) in a valid string of 8 digits
.PARAMETER UseLocalTime
	Will use the time reported on the local client (via the powershell Get-Date command) and uses it instead of a predefined MMDDhhmm type string
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
	This command utilizes the SSH command 'SetDate'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName="GetTZ",mandatory)]		[switch]	$GetTimeZoneList,
		[Parameter(ParameterSetName="SetTZ",mandatory)]		[String]	$TimeZone,
		[Parameter(ParameterSetName="SetTime",mandatory)]
		[ValidatePattern('^\d{8}$')]						[String]	$MMDDhhmm,
		[Parameter(ParameterSetName="SetTime",mandatory)]
		[ValidateRange(2000,2030)]							[String]	$YYYY,
		[Parameter(parameterSetName='LocalTime',Mandatory)]	[switch]	$UseLocalTime
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " setdate "
	switch($PSCmdlet.ParameterSetName)
		{	'GetTZ'			{	$Cmd += " -tzlist "
							}
			'SetTZ'			{	$Cmd += " -tz $TimeZone "
							}
			'SetTime'		{	$Cmd += $MMDDhhmm
							}
			'UseLocalTime'	{	[string]$Timestring = get-date -format "MMddhhmm"
								$Cmd += $MMDDhhmm
							}
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
	This command utilizes the SSH command 'SetSysMgr'
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

Function Get-A9SystemInfo
{
<#
.SYNOPSIS
    Command displays the Storage system information, Battery information, or Firmware Database Information, or Enviornmental inforation, Network info, or system Table of Contents (TOC) summary or Node info.
.DESCRIPTION
    Without options the Command displays the Storage system information.
	The ShowBatteryInfo option displays battery status information such as serial number, expiration date and battery life, which could be helpful in determining battery maintenance schedules.
	The ShowFirmwareDBInfo parameter Displays the current database of firmware levels if issued without any options, the firmware for all vendors is displayed.
	The ShowEnviornmentalInfo parameter displays the node operating environment status, including voltages and temperatures.
	The ShowNetworkInfo parameter displays the configuration and status of the administration network interfaces, including the configured gateway and network time protocol (NTP) server.
	The ShowResourceInfo will return the system Table of Contents (TOC) summary.
	The Node info will return details about the nodes.
.PARAMETER Option
	Can be any of the following; "d","param","fan","space","vvspace","domainspace","desc","devtype","date"
.DESCRIPTION
	Displays battery status information such as serial number, expiration date and battery life, 
	which could be helpful in determining battery maintenance schedules.
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
.PARAMETER ShowBatteryInfo
	Show Battery specific information
.PARAMETER ShowFirmwareDBInfo
	Show Firmware Database specific information
.PARAMETER ShowEnviornmentalInfo
	The ShowEnviornmentalInfo parameter displays the node operating environment status, including voltages and temperatures.
.PARAMETER ShowSysMgrInfo
	Show System Manager Information, specifically Locks
.PARAMETER ShowSystemResourceInfo
	Show the effects of the System Resource info
.PARAMETER ShowNetworkInfo
	The ShowNetworkInfo parameter displays the configuration and status of the administration network interfaces, including the configured gateway and network time protocol (NTP) server.
.PARAMETER ShowResourceInfo
	The ShowResourceInfo will return the system Table of Contents (TOC) summary.
.PARAMETER ShowNodeInfo
.EXAMPLE
    PS:> Get-A9SystemInformation 

	Command displays the Storage system information.such as system name, model, serial number, and system capacity information.
.EXAMPLE
    PS:> Get-A9SystemInfo -Option space

	Lists Storage system space information in MB(1024^2 bytes).PARAMETER Option
	space 
    Displays the system capacity information in MB (1024^2 bytes)
	
    domainspace 
    Displays the system capacity information broken down by domain in MB(1024^2 bytes)
	
    fan 
    Displays the system fan information.
	
    date	
	command displays the date and time for each system node
.EXAMPLE
	PS:> Get-A9SystemInfo -showFirmwareDBInfo
.EXAMPLE
	PS:> Get-A9SystemInfo -showBatteryInfo
.NOTES
	This command utilizes the SSH command 'ShowSys', 'ShowBattery', 'ShowFirmwareDB', 'ShowNodeEV', 'ShowNet', 'ShowToC', 'ShowNode'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory, ParameterSetName='Battery')]		[Switch]	$ShowBatteryInfo,
		[Parameter(Mandatory, ParameterSetName='Firmware')]		[switch]	$ShowFirmwareDBInfo,
		[Parameter(Mandatory, ParameterSetName='Enviromental')]	[Switch]	$ShowEnviornmentalInfo,
		[Parameter(Mandatory, ParameterSetName='Locks')]		[Switch]	$ShowSysMgrInfo,
		[Parameter(Mandatory, ParameterSetName='Network')]		[Switch]	$ShowNetworkInfo,
		[Parameter(Mandatory, ParameterSetName='Resource')]		[Switch]	$ShowResourceInfo,
		[Parameter(Mandatory, ParameterSetName='Node')]			[Switch]	$ShowNodeInfo,
		[Parameter(ParameterSetName='Info')]	
		[ValidateSet("d","param","fan","space","vvspace","domainspace","desc","devtype","date")]
																[String]	$Option,
		[Parameter(ParameterSetName='Network')]											
		[Parameter(ParameterSetName='Battery')]					[switch]	$Detailed,
		[Parameter(ParameterSetName='Battery')]					[switch]	$Log,
		[Parameter(ParameterSetName='Battery')]					[switch]	$Inventory,
		[Parameter(ParameterSetName='Battery')]					[switch]	$Svc,
		[Parameter(ParameterSetName='Enviromental')]
		[Parameter(ParameterSetName='Battery')]					[String]	$Node_ID,
		[Parameter(ParameterSetName='Firmware')]				[String]	$VendorName,
		[Parameter(ParameterSetName='Firmware')]				[switch]	$All
		
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
process
{	$tempFile = [IO.Path]::GetTempFileName()
	switch($PSCmdlet.ParameterSetName)
		{	"Info"	
					{	$sysinfocmd = "showsys "
						if ($Option)
							{	$sysinfocmd+=" -$option "
								if($Option -eq "date")
									{	$Result = Invoke-A9CLICommand -cmds "showdate"
										write-verbose "Get system date information " 
										write-verbose "Get system fan information cmd -> showdate " 
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
									}	
								else{	$Result = Invoke-A9CLICommand -cmds  $sysinfocmd
									}
							}
						else{	$Result = Invoke-A9CLICommand -cmds  $sysinfocmd 
							}	
					}
			"Battery"
					{	$Cmd = " showbattery "
						if ( $Detailed )	{	$Cmd += " -d "		}
						if ( $log )			{	$Cmd += " -log " 	}
						if ( $inventory )	{	$Cmd += " -i " 		}
						if ( $svc )			{	$Cmd += " -svc " 	}
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $Cmd
						if($Result.count -gt 1)
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
										}
							}
					}
			"Firmware"
					{	$Cmd = " showfirmwaredb "
						if($VendorName)	{	$Cmd += " -n $VendorName "}
						if($All)		{	$Cmd += " -all " }
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $Cmd
					}
			'Enviormental'
					{	$Cmd = " shownodeenv "
						if ( $PersistArrayType -eq 'AlletraMP-B10000')
							{	write-warning "This command is not supported on the HPE Alletra MP B10000 type array"	
								return
							}
						if($Node_ID)	{	$Cmd += " -n $Node_ID "} 
						$Result = Invoke-A9CLICommand -cmds  $Cmd	
					}
			'Locks'	
					{	$Cmd = " showsysmgr "
						$Cmd1 += " -d "	
						$Cmd2 += " -l "
						$Cmd = $Cmd1 + ' ; ' + $Cmd2
						$Result1 = Invoke-A9CLICommand -cmds  $Cmd1
						$Result2 = Invoke-A9CLICommand -cmds  $Cmd2
						$Result=$Result1 + $Result2
						Return $Result
					}
			'Network'
					{	$Cmd = " shownet "
						if($Detailed)	{	$Cmd += " -d "}
						$Result = Invoke-A9CLICommand -cmds  $Cmd
					}
			'Resource'
					{	$Cmd = " showtoc "
						$Result = Invoke-A9CLICommand -cmds  $Cmd
					}
			'Node'	
					{	$Cmd = " shownode "
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $Cmd
						if($Result.count -gt 1)
							{	$LastItem = $Result.Count -1  
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
												$newTemp= [regex]::Replace($sTemp,"^ ","")			
												$newTemp= [regex]::Replace($sTemp," ",",")				
												$newTemp= $newTemp.Trim()
												$s=$newTemp
											}
										Add-Content -Path $tempfile -Value $s
										$incre = "False"		
									}
								$Result = Import-Csv $tempFile 
							}
					}
		}
	Remove-Item $tempFile
	write-verbose "Executing the following SSH command `n`t $cmd"
	if ( $Result.count -gt 1 )	
		{ 	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
		}
	return $Result		
}
}

Function Get-A9iSCSISession
{
<#
.SYNOPSIS
	Shows the iSCSI sessions.
.DESCRIPTION  
	The command shows the iSCSI sessions.
.PARAMETER Detailed
    Specifies that more detailed information about the iSCSI session is displayed. If this option is not used, then only summary information
    about the iSCSI session is displayed.
.PARAMETER NSP
	Requests that information for a specified port is displayed.
.EXAMPLE
	PS:> Show-A9iSCSISession
.EXAMPLE
	PS:> Show-A9iSCSISession -NSP 1:2:1
.EXAMPLE
	PS:> Show-A9iSCSISession -Detailed -NSP 1:2:1
.NOTES
	This command utilizes the SSH command 'ShowiSCSISession'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed,
		[Parameter()]	
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
						[String]	$NSP ,
		[Parameter()]	[switch]	$ShowRaw
		
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
process	
{	$cmd= "showiscsisession "
	if ($Detailed)	{	$cmd+=" -d "	}
	if ($NSP)	{	$cmd+=" $NSP "	}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if ($ShowRaw) {	return $result }
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
			$dataPS = Import-Csv $tempFile 
			remove-item $tempFile
		}
	$NewObj = @(    foreach( $Item in $DataPS)	
												{   $NewItem=@{PSTypeName = "HPE.A9Storage.iSCSISession"}
													$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
													$DataSetType = "HPE.A9Storage.iSCSISession"
													$NewItem.PSTypeNames.Insert(0,$DataSetType)
													$DataSetType = $DataSetType + ".TypeName"
													$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
													[PSCustomObject]$NewItem
												}
					)
	if($Result -match "total")	
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $NewObj 
		}
	else{	return  $Result	}	
}
}

Function Get-A9Portdevice_CLI
{
<#
.SYNOPSIS
	Show detailed information about devices on a port.
.DESCRIPTION
	The command displays detailed information about devices on a specified port.
.PARAMETER Loop
	Specifies that information is returned for arbitrated loop devices that are attached to the specified port. This subcommand is only
	for use with Fibre Channel arbitrated loop ports.
.PARAMETER DeviceType 
	This can be one of thee: Loop, All, FCSwitch, FCFAbric, NS or SAS, and will present different information depending on which device type is selected.
	All = Specifies that information for all devices attached to the specified port is returned.
	Loop = Specifies that information is returned for arbitrated loop devices that are attached to the specified port. This subcommand is only for use with Fibre Channel arbitrated loop ports.
	NS = Specifies that information for the switch name server database is returned. This subcommand is only for use with fabric-attached topologies.
	SAS = Specifies that information for all devices in the SAS topology attached to the specified port is returned. This subcommand is only for use with SAS ports.
	FCSwitch = Specifies that a list of all switches in the Fibre Channel fabric is returned. This subcommand is only for use with fabric-attached Fibre Channel ports.
	FCFabric = Specifies that a description of the Fibre Channel fabric is returned. This subcommand is only for use with fabric-attached Fibre Channel ports.

.PARAMETER Findport
	Searches the Fibre Channel fabric attached to the specified port for information on the supplied WWN.  Supplying the term "this"
	in place of a WWN indicates that the port WWN of the specified  Storage System host port should be used.  This subcommand is only for
	use with fabric-attached Fibre Channel ports.
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
.PARAMETER Details
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
	This command utilizes the SSH command 'ShowPortDev'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter(ParameterSetName='ByDevice')]
	[ValidateSet('loop','all','ns','sas','fcswitch','fcfabric')]	
											[string]	$DeviceType,
	[Parameter(Mandatory,ParameterSetName='FindWWN')]	
											[switch]	$Findport,
	[Parameter(ParameterSetName='ByUns')]	[switch]	$UNS,
	[Parameter(ParameterSetName='LLDP')]	[switch]	$Lldp,
	[Parameter(ParameterSetName='DCBX')]	[switch]	$Dcbx,
	[Parameter(ParameterSetName='SAS')]		[switch]	$SAS,

	[Parameter(ParameterSetName='SAS')]		[switch]	$PEL,

	[Parameter(ParameterSetName='ByUns')]
	[Parameter(ParameterSetName='LLDP')]
	[Parameter(ParameterSetName='DCBX')]	[switch]	$Detail,

	[Parameter(ParameterSetName='DCBX')]	[switch]	$App,

	[Parameter(ParameterSetName='DCBX')]	[switch]	$PFC,
	[Parameter(ParameterSetName='DCBX')]	[switch]	$PG,

	[Parameter(ParameterSetName='ByDevice')]
	[Parameter(ParameterSetName='FindWWN')]
	[Parameter(ParameterSetName='ByUns')]
	[Parameter(ParameterSetName='LLDP')]
	[Parameter(ParameterSetName='DCBX')]
	[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
					[String]	$NSP,	
	[Parameter(ParameterSetName='FindWWN')]	[String]	$WWN
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showportdev "		
	if ( $DeviceType )	
		{
			switch($DeviceType)
				{	'loop'		{	$Cmd += " loop "	}
					'all'		{	$Cmd += " all " 	}
					'fcfabric'	{	$Cmd += " fcfabric "}
					'ns'		{	$Cmd += " ns "		}
					'sas'		{ 	$Cmd += " sas " 	}
					'fcswitch'	{	$Cmd += " fcswitch "}
				}
		}
	if($Findport)	{	if ( $WWN )	{ $Cmd += " findprort $WWN " 	}
						else 		{ $Cmd += " findprort this "	}
					}
	if($UNS)		{	$Cmd += " uns " }
	if($Lldp)		{	$Cmd += " lldp " }
	if($Dcbx)		{ 	$Cmd += " dcbx " }
	if($PEL)		{	$Cmd += " -pel " }
	if($Detail)		{	$Cmd += " -d " }
	if($App)		{	$Cmd += " -app " }
	if($PFC)		{	$Cmd += " -pfc " }
	if($PG)			{	$Cmd += " -pg " }
	if($NSP)		{ 	$Cmd += " $NSP " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
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
	This command utilizes the SSH command 'StartNodeRescue'
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

Function Get-A9Port_CLI
{
<#
.SYNOPSIS
	Query to get all ports including targets, disks, and RCIP ports.
.DESCRIPTION
	Get information for Ports
.PARAMETER Inventory
	Shows port hardware inventory information.
.PARAMETER Connected
	Displays all devices connected to the port. Such devices include cages (for initiator ports), hosts (for target ports) and ports from other
	storage system (for RCFC and peer ports).
.PARAMETER Parameters
	Displays a parameter listing such as the configured data rate of a port and the maximum data rate that the card supports. Also shown is the
	type of attachment (Direct Connect or Fabric Attached) and whether the unique_nwwn and VCN capabilities are enabled.
.PARAMETER PortType
	Can be one of four settings
	RC = Displays information that is specific to the Remote Copy ports.
	RCFC = Displays information that is specific to the Fibre Channel Remote Copy ports.
	PEER = Displays information that is specific to the Fibre Channel ports for Data Migration.
	RCIP = Displays information specific to the Ethernet Remote Copy ports.
.PARAMETER ISCSIInfo
	Can be one of three settings.
	iSCSI = Displays information about iSCSI ports.
	ISCSINAME = Displays iSCSI names associated with iSCSI ports.
	ISCSIVLANS = Displays information about VLANs on iSCSI ports.
.PARAMETER SFPInfo
	Can be one of three settings.
	Basic = Displays information about the SFPs attached to ports.
	Diagnostics = Displays Digital Diagnostics Monitoring (DDM) readings from the SFPs if they support DDM. This option must be used with the -sfp option.
	Detailed = More detailed examination of each SFP
.PARAMETER Identity
	Displays the identities hosted by each physical port.
.PARAMETER NSP
	Nede slot port
.PARAMETER ShowISNS
	The command shows iSNS host information for iSCSI ports in the system.
.PARAMETER ShowArp
	The command shows the ARP table for iSCSI ports in the system.
.EXAMPLE
	PS:> Get-A9HostPorts_CLI
		Lists all ports including targets, disks, and RCIP ports
.EXAMPLE
	PS:> Get-A9HostPorts_CLI  -Iventory
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -Parameters
.EXAMPLE
	PS:> Get-A9HostPorts_CLI -PortType RC
.EXAMPLE
	PS:> Get-A9HostPorts_CLI | where { $_.State -eq 'offline'}

	The replaces the 'failed'
.EXAMPLE
	PS:> Get-A9HostPorts_CLI | format-table N:S:P,state

	This replaces the -state option
.NOTES
	This command utilizes the SSH command 'ShowPort', 'ShowPortiSNS'
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='default')]
Param(		[Parameter(ParameterSetName='inven')]			[switch]	$Inventory,
			[Parameter(ParameterSetName='Params')]			[switch]	$Parameters,
			[Parameter(ParameterSetName='Ports')]
			[ValidateSet('RC','RCFC','RCIP','PEER')]		[string]	$PortType,
			[Parameter(ParameterSetName='Connected')]		[switch]	$Connected,
			[Parameter(ParameterSetName='iscsi')]		
			[ValidateSet('ISCSI','ISCSINAME','ISCSIVLANS')]	[String]	$iSCSIInfo,
			[Parameter(ParameterSetName='SFP')]
			[ValidateSet('Basic','Detailed','Diagnostic')]	[String]	$SFPInfo,
			[Parameter(ParameterSetName='IDS')]				[switch]	$Identity,
			[Parameter()]	
			[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
															[String]	$NSP,
			[Parameter(ParameterSetName='isns')]			[switch]	$ShowISNS,
			[Parameter(ParameterSetName='arp')]				[switch]	$ShowArp
			
		)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$tempFile = [IO.Path]::GetTempFileName()
	switch ( $PSCmdlet.ParameterSetName )
		{	'default'	
				{	$Cmds = "showport"
					if($Inventory)	{	$Cmds+=" -i "			}
					if($Connected)	{	$Cmds+=" -c "			}
					if($Parameters)	{	$Cmds+=" -par "			}
					if($PortType)	{	$Cmds+=" -$($PortType.toLower() ) "	}
					if($ISCSIInfo)	{	$Cmds+=" -$($iSCSIInfo.toLower() ) "}
					if($SFPInfo -eq 'Basic')	{	$Cmds+=" -sfp "		}
					if($SFPInfo -eq 'Detail')	{	$Cmds+=" -sfp -d "	}
					if($SFPInfo -eq 'Diagnostic'){	$Cmds+=" -sfp -ddm "}
					if($Identity)	{	$Cmds+=" -ids "			}
					if($NSP)		{	$Cmds+=" $NSP"			}
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result=Invoke-A9CLICommand  -cmds $Cmds 	
					$LastItem = $Result.Count -2  
					if($Result -match "N:S:P")
						{	foreach ($s in  $Result[0..$LastItem] )
								{	$s= [regex]::Replace($s,"^ ","")			
									$s= [regex]::Replace($s," +",",")	
									$s= [regex]::Replace($s,"-","")
									$s= [regex]::Replace($s,"\s+",",") 		
									$s= [regex]::Replace($s,"/HW_Addr","") 
									# $s= [regex]::Replace($s,"N:S:P","Device")
									$s= $s.Trim() 	
									Add-Content -Path $tempFile -Value $s				
								}
							write-host 'Success : Executing Get-HostPorts' -ForegroundColor green
						}
				}
			'isns'
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
						}
					if($Result -match "N:S:P")	{	write-host " Success : Executing Show-PortISNS" -ForegroundColor green	}
					return  $Result	
				}
			'arp'
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
							$Result = Import-Csv $tempFile 
						}	
					return $Result	
				}
		}
	remove-item $tempFile
	return $Result			
}
}


Function Get-A9Target
{
<#
.SYNOPSIS
	Show information about all targets.
.DESCRIPTION
	The command displays information about all targets.
.PARAMETER Lun
	Displays the exported Logical Unit Numbers (LUNs) from the unknown targets. Use the "all" specifier to display the exported LUNs from all of the unknown targets.
.PARAMETER SCSIIquiryPageInfo
	Display SCSI inquiry page information.
.PARAMETER SCSIModePageInfo
	Display SCSI mode page information.
.PARAMETER SCSIModePageInfo
	Display iSCSI information.
.PARAMETER Page
	Specify the SCSI page number for the inquiry and mode information. <num> is a hex number. For SCSI inquiry information, the valid <num>
	is 0, 80, 83, and c0. For SCSI mode information, the valid <num> is 3 and 4. This option needs to be used together with -inq or -mode. 
	If this option is not specified, the default <num> is 0.
.PARAMETER Detailed
	Display the detail information of SCSI inquiry or mode page information.
.PARAMETER Rescan
	Rescan the peer ports to find the unknown targets. This defaults to force mode as well as verbose mode.
.PARAMETER Node_WWN
	Indicates the World Wide Name (WWN) of the node.
.PARAMETER LUN_WWN
	Indicates the World Wide Name (WWN) of a LUN exported from an unknown target.
.NOTES
	This command utilizes the SSH command 'ShowTarget'
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='none')]
param(	[Parameter(ParameterSetName='iscsi')]			[string]	$Lun,
		[Parameter(ParameterSetName='Inq',mandatory)]	[switch]	$SCSIIquiryPageInfo,
		[Parameter(ParameterSetName='mode',mandatory)]	[switch]	$SCSIModePageInfo,
		[Parameter(ParameterSetName='Inq')]
		[Parameter(ParameterSetName='mode')]
		[ValidateSet('0','80','83','c0')]				[String]	$SpecificSCSIModePage,
		[Parameter(ParameterSetName='iscsi',Mandatory)]	[switch]	$iSCSI,
		[Parameter(ParameterSetName='Inq')]				
		[Parameter(ParameterSetName='Mode')]			[switch]	$Detailed,
		[Parameter(mandatory,ParameterSetName='rescan')][switch]	$Rescan,
		[Parameter(ParameterSetName='inq')]				
		[Parameter(ParameterSetName='mode')]			[String]	$LUN_WWN,		
		[Parameter(ParameterSetName='iscsi')]			[String]	$Node_WWN,
		[Parameter(ParameterSetName='iscsi')]			[String]	$iSCSIQualifiedName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showtarget "	
	if($Lun)		{	$Cmd += " -lun $Lun "}
	if($SCSIIquiryPageInfo)		{ 	$Cmd += " -inq "}
	if($SCSIModePageInfo)		{	$Cmd += " -mode "	}
	if($Page)		{	$Cmd += " -page $Page "	}
	if($Page)		{	$Cmd += " -iscsi "	}
	if($Detailed)	{	$Cmd += " -d "}
	if($Rescan)		{	$Cmd += " -rescan -force -verbose "}
	if($Node_WWN)	{	$Cmd += " $Node_WWN "}
	if($LUN_WWN)	{	$Cmd += " $LUN_WWN "}
	if($ISCSIQualifiedName){	$Cmd += " $ISCSIQualifiedName "}
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
    When both the -time and -iter options are specified, the first limit reached terminates the program. If neither are specified, the default is
    1,000 iterations. The total run time is always limited to 300 seconds even when not specified.
    The default loopback is an ELS-ECHO sent to the HBA itself.
.PARAMETER Time <seconds_to_run>
    Specifies the number of seconds for the test to run using an integer from 0 to 300.
.PARAMETER Iter <iterations_to_run>
    Specifies the number of times for the test to run using an integer from 1 to 1000000.     
.PARAMETER PortNSP
    Specifies the port to be tested.
.EXAMPLE
    Test-Port test is performed on port 0:0:1 a total of five times:

    PS:> Test-A9FCLoopback -iter 5 0:0:1

    Starting loopback test on port 0:0:1
    Port 0:0:1 completed 5 loopback frames in 0 seconds Passed
.NOTES
	This command utilizes the SSH command 'CheckPort'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
        [Parameter()]	[ValidateRange(0,300)]    		[int]    	$TimeInSeconds,		
        [Parameter()]   [ValidateRange(1,100000)]		[int]    	$Iter,
        [Parameter(Mandatory)]	
						[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
														[String]    $PortNSP
    )	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd = "checkport "	
    if ($TimeInSeconds) {    $cmd += " -time $TimeInSeconds"    }
    if ($Iter) 			{    $cmd += " -iter $Iter"	    }
    if ($PortNSP) 		{    $cmd += "$PortNSP"		   }
    write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $cmd
    return 	$Result	
}
}
