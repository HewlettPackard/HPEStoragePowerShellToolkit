####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Add-A9Hardware
{
<#
.SYNOPSIS
	Admit new hardware into the system.
.DESCRIPTION
	The command admits new hardware into the system. If new disks are discovered on any two-node HPE StoreServ system, tunesys will be
	started automatically to redistribute existing volumes to use the new capacity. This facility can be disabled using either the -notune
	option or setting the AutoAdmitTune system parameter to "no". On systems with more than two nodes, tunesys must always be run manually after disk installation.
.PARAMETER Checkonly
	Only performs passive checks; does not make any changes.
.PARAMETER F
	If errors are encountered, the Add-Hardware command ignores them and continues. The messages remain displayed.
.PARAMETER Nopatch
	Suppresses the check for drive table update packages for new hardware enablement.
.PARAMETER Tune
	Always run tunesys to rebalance the system after new disks are discovered.
.PARAMETER Notune
	Do not automatically run tunesys to rebalance the system after new disks are discovered.
.NOTES
	Authority:Super, Service
	Usage: 
	- Requires access to all domains.
	- Handles any nodes, disks, or cages added into the system.
	- Verifies the presence of all expected hardware and handles all checks, including valid states, cabling, and firmware revisions.
	- Handles creating system logical disks while adding and rebalancing spare chunklets.
	- Allocates spares according to the algorithm specified by the SparingAlgorithm system parameter.
	- If new disks are discovered, the set size for existing CPGs is recalculated. Changes to the CPG occur prior to any tunesys operation so that the affected LDs are automatically tuned.
	- Checks for drive table patch updates unless you specify the -nopatch option.
	- In addition, discovery of new disks in any combination can cause tunesys to start automatically and rebalance the system after the admithw command has completed.
	- Automatic tunesys occurs under the following conditions:
		- With admithw -tune, rebalancing occurs on all systems regardless of the number of controller nodes.
		- On systems with two controller nodes, tunesys runs automatically. To suppress this behavior, use the system variable AutoAdmitTune with the following command structure: cli% setsys AutoAdmitTune no. AutoAdmitTune defaults to yes.
		- With admithw -notune, rebalancing does not occur after new discovery of new disks. In all circumstances, run tunesys as soon as possible after discovery of new disks.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter(ParameterSetName='CheckOnly', Mandatory)]	[switch]	$Checkonly,
		[Parameter()]												[switch]	$F,
		[Parameter()]												[switch]	$Nopatch,
		[Parameter(ParameterSetName="Tune", Mandatory)]		[switch]	$Tune,
		[Parameter(ParameterSetName="NoTune",Mandatory)]		[switch]	$Notune
)
Begin
{	Test-A9CLIConection
}
Process
{	$Cmd = " admithw "
	if($Checkonly)	{	$Cmd += " -checkonly " 	}
	if($F)			{	$Cmd += " -f " 			}
	if($Nopatch)	{	$Cmd += " -nopatch " 	}
	if($Tune)		{	$Cmd += " -tune " 		}
	if($Notune)		{	$Cmd += " -notune " 	}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SystemPatch
{
<#
.SYNOPSIS
	Show what patches have been applied to the system.
.DESCRIPTION
	This command displays all the patches currently affecting the system if options are not used.
.PARAMETER Hist
	Provides an audit log of all patches and updates that have been applied to the system.
.PARAMETER Detailed
	When used with the -hist option, shows detailed history information including the username who installed each package. If -d is used with a patch specification,
	it shows detailed patch information. Otherwise it shows detailed information on the currently installed patches.

.Example
	The following example shows all patches currently installed on the system, with additional detail:

	PS:> Get-A9SystemPatch -detailed
.EXAMPLE
	The following example shows all updates that have been applied to the system over time, with all detail:

	PS:> Get-A9SystemPatch -hist -detailed
.EXAMPLE
	The showpatchcommand with a specific individual installed patch number displays the fields below when used with the optional -d option:

	PS:> Get-A9SystemPatch P### -detailed
.NOTES
	Patch ID.          Specifies the patch ID. 
	Release Version.   Specifies TPD or UI release affected by the patch. 
	Synopsis.          Specifies the purpose of the patch. 
	Date.              Specifies the build date of the patch. 
	Bugs fixed.        Specifies the bugs fixed. 
	Description.       Specifies a detailed description of the problem or fix. 
	Affected Packages. Specifies the new packages being changed. 
	Obsoletes.         Specifies the patch IDs deleted by this patch. 
	Requires.          Specifies the patch IDs of any other patches required by this patch. 
	Notes.             Specifies any special instructions for the patch. 

#>
[CmdletBinding(DefaultParameterSetName='Default')]
param(	[Parameter(ParameterSetName='ByPatchId', Mandatory)]		[string]	$PatchId,
		[Parameter(ParameterSetName='Default')]						[switch]	$Hist,
		[Parameter()]												[switch]	$Detailed
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showpatch "
	if($PSCmdlet.ParameterSetName -eq 'ByPatchId') { $Cmd = $Cmd + $PatchId + ' '}
	if($Hist)			{	$Cmd += " -hist " }
	if($Detailed) 		{	$Cmd += " -d " 	}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9Version 
{	
<#
.SYNOPSIS
    Get list of Storage system software version information 
.DESCRIPTION
    Get list of Storage system software version information
.PARAMETER All
	Show all component versions
.PARAMETER Build
	Show build levels
.PARAMETER ShowRelease
	Show release version number only (useful for scripting).
.EXAMPLE
    PS:> Get-A9Version

	Get list of Storage system software version information
.EXAMPLE
    PS:> Get-A9Version -ShowVersion	

	Get list of Storage system release version number only
.EXAMPLE
    PS:> Get-A9Version -Build	

	Get list of Storage system versions including build levels
.NOTES
	Usage: When displaying all versions, for certain components multiple versions might be 
	installed. In such cases, multiple lines are displayed.

	If no options are specified, the overall version of the software is displayed.

	Release version 4.0.3
	Patches: None 
	Component Name   Version 
	CLI Server        4.0.3 
	CLI Client        4.0.3
	System Manager    4.0.3 
	Kernel            4.0.0 
	TPD Kernel Code   4.0.3
	Drive Firmware    4.0.1        
	Enclosure Firmware4.0.2        
	Upgrade Tool      21 (190813) 
#>
[CmdletBinding()]
param(	[Parameter()]    [switch]    $All,
        [Parameter()]    [switch]    $Build,
        [Parameter()]    [switch]    $ShowRelease
)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process
{	$Cmd = "showversion"
    if ($All) 			{    $Cmd += " -a"    }
    if ($Build) 		{    $Cmd += " -b"    }
    if ($ShowRelease) 	{    $Cmd += " -s"    }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
    return $Result
}
}

Function Update-A9Cage
{
<#
.SYNOPSIS
	Upgrade firmware for the specified cage.
.DESCRIPTION
	The command downloads new firmware into the specified cage.
.PARAMETER All
	All drive cages are upgraded one at a time.
.PARAMETER Parallel
	All drive cages are upgraded in parallel by interface card domain. If -wait is specified, the command will not return until the upgrades
	are completed. Otherwise, the command returns immediately and completion of the upgrade can be monitored with the -status option.
.PARAMETER Status
	Print status of the current operation in progress or the last executed operation. If any cagenames are specified, 
	result is filtered to only display those cages.
.NOTES
	Authority: Super, Service
	Any role granted the cage_upgrade right
	Usage: Running this command requires access to all domains.
	Before executing the upgradecage command, issue the showcage command to obtain the names of the drive cages in the system.

	When you issue the upgradecage command, the drive cage becomes temporarily degraded as the system upgrades each interface card.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter(ParameterSetName='AllAndSequential',Mandatory)]	[switch]	$All,
		[Parameter(ParameterSetName='Parallel',Mandatory)]			[switch]	$Parallel,
		[Parameter(ParameterSetName='Parallel')]					[switch]	$Wait,
		[Parameter(ParameterSetName='Status',Mandatory)]			[switch]	$Status,
		[Parameter(ParameterSetName='Status')]	
		[Parameter(ParameterSetName='default',Mandatory)]			[String]	$Cagename
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process 
{	$Cmd = " upgradecage "
	if($All) 		{	$Cmd += " -a " }
	if($Parallel)	{	$Cmd += " -parallel "
						if($Wait)		{	$Cmd += " -wait " }
					}
	if($Status)		{	$Cmd += " -status " }
	if($Cagename)	{	$Cmd += " $Cagename " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Status)	
		{	if($Result.count -gt 1)
				{	$tempFile = [IO.Path]::GetTempFileName()
					$LastItem = $Result.Count   
					foreach ($s in  $Result[1..$LastItem] )
					{	$s= [regex]::Replace($s,"^ ","")			
						$s= [regex]::Replace($s,"^ ","")			
						$s= [regex]::Replace($s," +",",")			
						$s= $s.Trim()			
						$temp1 = $s -replace 'StartTime','S-Date,S-Time,S-Zone'
						$temp2 = $temp1 -replace 'StopTime','E-Date,E-Time,E-Zone'
						$s = $temp2					
						Add-Content -Path $tempfile -Value $s				
					}
					Import-Csv $tempFile 
					Remove-Item  $tempFile	
				}
			else{	Return  $Result	}
		}
	else{	Return $Result }
}
}

Function Reset-A9SystemNode
{
<#
.SYNOPSIS
	Halts or reboots a system node.
.DESCRIPTION
	The command shuts down a system node.
.PARAMETER Node_ID
	Specifies the node, identified by its ID, to be shut down.
.PARAMETER Halt
	Specifies that the nodes are halted after shutdown.
.PARAMETER Reboot
	Specifies that the nodes are restarted after shutdown.
.PARAMETER Check
	Checks if multipathing is correctly configured so that it is safe to halt or reboot the specified node. An error will be
	generated if the loss of the specified node would interrupt connectivity to the volume and cause I/O disruption.
.PARAMETER Restart
	Specifies that the storage services should be restarted.
.EXAMPLE
	PS:> Reset-A9SystemNode -Halt -Node_ID 0.
.NOTES
	Authority: Super, Service
		Any role granted the node_shutdown right

	- Usage Requires access to all domains.
	- The system manager executes a set of validation checks before proceeding with the shutdown.
	- Unless indicated otherwise, if any of the following conditions exist, the shutdown operation will not proceed:
	- The system checks for interrupting connectivity to various volumes and returns an error if multipathing is configured incorrectly.
	- System software upgrade is in progress.
	- Target node is not online.
	- If the system is processing tasks, the command returns a warning message to inform the user that tasks are running, and that the shutdown operation can cause some tasks to fail. If the user confirms the shutdown operation, the specified node reboots even if tasks are running.
	- If no tasks are running when the initial checks are performed, and a new task starts afterward, the shutdown fails.
	- Any other node is online but not yet integrated into the cluster.
	- Another shutdown node operation is already in progress.
	- Shutdown node operation will result in the system shutting down due to loss of quorum.
	- One or more orphaned logical disks exist on the system that cannot be preserved.
	- One or more admin logical disks cannot be reset, resulting in the kernel being unable to access meta data from those logical disks.
	- One or more data (user or snap) logical disks cannot be reset, causing their associated VLUNs to become inaccessible to host applications.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Halt',		Mandatory)]	[switch]	$Halt,
		[Parameter(ParameterSetName='Reboot',	Mandatory)]	[switch]	$Reboot,
		[Parameter(ParameterSetName='Check',	Mandatory)]	[switch]	$Check,
		[Parameter(ParameterSetName='Restart',	Mandatory)]	[switch]	$Restart,
		[Parameter(Mandatory)]								[String]	$Node_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " shutdownnode "
	if($Halt)		{	$Cmd += " halt " }
	Elseif($Reboot)	{	$Cmd += " reboot " }
	Elseif($Check)	{	$Cmd += " check " }
	Elseif($Restart){	$Cmd += " restart " }
	$Cmd += " $Node_ID"
	$Stream = (($SanConnection.SessionObj).Session).CreateShellStream("xterm",80,24,800,600,1024)
	$Stream.Read()
	$ReturnData = invoke-sshstreamShellCommand -ShellStream $Stream -Command $Cmd
	start-sleep 3 
	if ( $Verbose )
		{	write-host "Command sent to the system is $Cmd. The response is below"
			$ReturnData | convertto-json | out-string
		}
	if ( $ReturnData -match "Permission denied") 		
		{	write-warning "The Command returned the following error : Permission has been Denied`nYour Account permissions are not capable of executing this command."
			return
		}
	if ( $ReturnData -match "yes or no" )
		{	write-verbose "The command is asking for a confirmation Yes or No, Sending a Yes confirmation now."
			$Stream.writeline('yes')
		}
	return
} 
}

Function Set-A9Magazines
{
<#
.SYNOPSIS
	Take magazines or disks on or off loop.
.DESCRIPTION
	The command takes drive magazines, or disk drives within a magazine, either on-loop or off-loop. Use this command when replacing a
	drive magazine or disk drive within a drive magazine. This command assumes non-interactice, so unlike the SSH comamnd that requires a -F 
	to force the command to run without a prompt, the -F is assumed.
.PARAMETER Offloop
	Specifies that the specified drive magazine or disk drive is either taken off-loop or brought back on-loop.
.PARAMETER Onloop
	Specifies that the specified drive magazine or disk drive is either
	taken off-loop or brought back on-loop.
.PARAMETER Cage_name
	Specifies the name of the drive cage. Drive cage information can be viewed by issuing the showcage command.
.PARAMETER Magazine
	Specifies the drive magazine number within the drive cage. Valid formats are <drive_cage_number>.<drive_magazine> 
	or <drive_magazine> (for example 1.3 or 3, respectively).
.PARAMETER Disk
	Specifies that the operation is performed on the disk as determined by its position within the drive magazine.
	If not specified, the operation is performed on the entire drive magazine.
.PARAMETER Port
	Specifies that the operation is performed on port A, port B, or both A and B. 
	If not specified, the operation is performed on both ports A and B.
.EXAMPLE
	PS:> Set-A9Magazines -Offloop -Cage_name "xxx" -Magazine "xxx"
.EXAMPLE
	PS:> Set-A9Magazines -Offloop -Port "Both" -Cage_name "xxx" -Magazine "xxx"
.NOTES
	Authority:Super, Service
		Any role granted the mag_control right
	- Access to all domains is required to run this command.
	Taking a drive magazine off-loop has the following consequences:
	- Relocation of chunklets.
	- Affected logical disks are put into write-through mode.
	- Momentary dip in throughput, but no loss of connectivity.
#>
[CmdletBinding()]
param( 	[Parameter(ParameterSetName='OffLoop',mandatory)]	[switch]	$Offloop,
		[Parameter(ParameterSetName='onLoop',mandatory)]	[switch]	$Onloop,
		[Parameter(Mandatory)]						[String]	$Cage_name,
		[Parameter(Mandatory)]						[String]	$Magazine,
		[Parameter()]										[String]	$Disk,
		[Parameter()][Validateset('A','B','Both')]
															[String]	$Port
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process 
{	$Cmd = " controlmag "
	if($Offloop)	{	$Cmd += " offloop " }
	if($Onloop) 	{	$Cmd += " onloop " }
	if($Disk)		{	$Cmd += " -disk $Disk " }
	if($Port)		{	$Cmd += " -port $Port.ToLower "	}
	$Cmd += " -f " 
	if($Cage_name)	{	$Cmd += " $Cage_name " }
	if($Magazine)	{	$Cmd += " $Magazine " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Set-A9ServiceCage
{
<#
.SYNOPSIS
	Service a cage.
.DESCRIPTION
	The command is necessary when executing removal and replacement actions for a drive cage interface card or power cooling module. The
	start subcommand is used to initiate service on a cage, and the end subcommand is used to indicate that service is completed.
.PARAMETER Start
	Specifies the start of service on a cage.
.PARAMETER End
	Specifies the end of service on a cage.
.PARAMETER Reset
	Initiates a soft reset of the interface card for DCN5, DCS11, and DCS12 drive cages. This specifies the interface card number of the cage to be reset and van be 0 or 1.
.PARAMETER Hreset
	Initiates a hard reset of the interface card for DCN5, DCS11, and DCS12 drive cages. This specifies the interface card number of the cage to be reset and van be 0 or 1. 
.PARAMETER Remove
	Removes the indicated drive cage (indicated with the <cagename> specifier) from the system. This subcommand fails when the cage has active ports or is in use.
.PARAMETER Pcm
	For DCS11 and DCS12, this specifies that the Power Cooling Module (PCM) will be serviced. For DCN5, this specifies the Power Cooling Battery
	Module (PCBM) will be serviced. The Value for this can either be 0 or 1
.PARAMETER Iom
	Specifies that the I/O module will be serviced. This option is not valid for DCN5 cage. The Value for this can either be 0 or 1
.PARAMETER CageName
	Specifies the name of the cage to be serviced.
.EXAMPLE
	The following example starts the service of interface card module 0 on cage0:

	PS:> Set-A9ServiceCage start -iom 0 cage0
.NOTES
	This command requires a SSH type connection.
	Authority: Super, Service
	Usage:Access to all domains is required to run this command.
	Issuing the servicecage command results in chunklet relocation, causing a dip in throughput.
	After issuing the start subcommand, the end subcommand must be issued to indicate that service is completed and to restore the cage to its normal state.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='StartPCM', Mandatory)]	
		[Parameter(ParameterSetName='StartIOM', Mandatory)]	
																	[switch]	$Start,
		[Parameter(ParameterSetName='EndPCM',   Mandatory)]	
		[Parameter(ParameterSetName='EndIOM',   Mandatory)]	
																	[switch]	$End,
		[Parameter(ParameterSetName='Reset', 	Mandatory)]	
										[ValidateSet('0','1')]		[int]		$Reset,
		[Parameter(ParameterSetName='HReset',	Mandatory)]	
										[ValidateSet('0','1')]		[int]		$HReset,
		[Parameter(ParameterSetName='Remove',	Mandatory)]	
																	[switch]	$Remove,	
		[Parameter(ParameterSetName='StartPCM', Mandatory)]
		[Parameter(ParameterSetName='EndPCM', 	Mandatory)]
										[ValidateSet('0','1')]		[int]		$Pcm,
		[Parameter(ParameterSetName='StartIOM', Mandatory)]
		[Parameter(ParameterSetName='EndIOM', 	Mandatory)]
										[ValidateSet('0','1')]		[int]		$Iom,
		[Parameter(Mandatory)]								[String]	$CageName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " servicecage "
	if($Start)
		{	$Cmd += " start "	
			if($PSBoundParameters.ContainsKey('Iom'))	{	$Cmd += " -iom "	}
			if($PSBoundParameters.ContainsKey('Pcm'))	{	$Cmd += " -pcm "	}	
			$Cmd += $Pcm + $Iom	+ ' ' 
		}
	if($End)
		{	$Cmd += " end "
			if($PSBoundParameters.ContainsKey('Iom'))	{	$Cmd += " -iom "	}
			if($PSBoundParameters.ContainsKey('Pcm'))	{	$Cmd += " -pcm "	}	
			$Cmd += $Pcm + $Iom	+ ' ' 
		}
	if($PSBoundParameters.ContainsKey('Reset'))			{	$Cmd += " reset -f " + $Reset	}
	if($PSBoundParameters.ContainsKey('HReset'))		{	$Cmd += " hreset -f " + $HReset	}
	if($Remove)											{	$Cmd += " remove -f "	}
	$Cmd += " $CageName "
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Set-A9ServiceNodes
{
<#
.SYNOPSIS
	Prepare a node for service.
.DESCRIPTION
	The command informs the system that a certain component will be replaced, and will cause the system to indicate the physical location of that component.
.PARAMETER Start
	Specifies the start of service on a node. If shutting down the node is required to start the service, the command will prompt for confirmation before proceeding further.
.PARAMETER End
	Specifies the end of service on a node. If the node was previously
	halted for the service, this command will boot the node.
.PARAMETER Ps
	Specifies which power supply will be placed into servicing-mode. Accepted values for <psid> are 0 and 1. For HPE 3PAR 600 series
	systems, this option is not supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.PARAMETER Pci
	Only the service LED corresponding to the PCI card in the specified slot will be illuminated. Accepted values for <slot> are 3 through 5 
	for HPE 3PAR 600 series systems.
.PARAMETER Fan
	Specifies which node fan will be placed into servicing-mode. For HPE 3PAR 600 series systems, 
	this option is not supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.PARAMETER Bat
	Specifies that the node's battery backup unit will be placed into servicing-mode. For HPE 3PAR 600 series systems, this option is not
	supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.EXAMPLE
	Set-A9ServiceNodes -Start -Nodeid 0
.EXAMPLE
	Set-A9ServiceNodes -Start -Pci 3 -Nodeid 0
.NOTES
	This command requires a SSH type connection.
	Authority: Super, Service
	Any role granted the node_service right

	Usage: Access to all domains is required to run this command. If a component is found unsafe to remove, the command will return an error.
	If no option is specified, only node LED will be illuminated.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)] 	
		[ValidateSet('0','1','2','3')]	[String] 	$Nodeid,
		[Parameter(ParameterSetName='Start', Mandatory)]	[switch]	$Start,
		[Parameter(ParameterSetName='end',   Mandatory)]	[switch]	$End,
		[Parameter()]					[int]	$Ps,
		[Parameter()]					[int]	$Pci,
		[Parameter()]					[int]	$Fan,
		[Parameter()]					[int]	$Bat
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
Process
{	$Cmd = " servicenode "
	if($Start) 		{	$Cmd += " start " 		}
	Elseif($End) 	{	$Cmd += " end " 		}
	if($Ps) 		{	$Cmd += " -ps $Ps " 	}
	if($Pci)		{	$Cmd += " -pci $Pci " 	}
	if($Fan)		{	$Cmd += " -fan $Fan " 	}
	if($Bat)		{	$Cmd += " -bat $Bat" 	}
	if($Nodeid)		{	$Cmd += " $Nodeid " 	}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9ServiceNodes
{
<#
.SYNOPSIS
	Inquire the status of a node for service.
.DESCRIPTION
	The command informs the system that a certain component will be replaced, and will cause the system to indicate the physical location of that component.
.PARAMETER Ps
	Specifies which power supply will be placed into servicing-mode. Accepted values for <psid> are 0 and 1. For HPE 3PAR 600 series
	systems, this option is not supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.PARAMETER Pci
	Only the service LED corresponding to the PCI card in the specified slot will be illuminated. Accepted values for <slot> are 3 through 5 
	for HPE 3PAR 600 series systems.
.PARAMETER Fan
	Specifies which node fan will be placed into servicing-mode. For HPE 3PAR 600 series systems, 
	this option is not supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.PARAMETER Battery
	Specifies that the node's battery backup unit will be placed into servicing-mode. For HPE 3PAR 600 series systems, this option is not
	supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.EXAMPLE
	Set-A9ServiceNodes -Start -Nodeid 0
.EXAMPLE
	Set-A9ServiceNodes -Start -Pci 3 -Nodeid 0
.NOTES
	This command requires a SSH type connection.
	Authority: Super, Service
	Any role granted the node_service right

	Usage: Access to all domains is required to run this command. If a component is found unsafe to remove, the command will return an error.
	If no option is specified, only node LED will be illuminated.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)] 	
		[ValidateSet('0','1','2','3')]	[String] 	$Nodeid,
		[Parameter()]					[int]	$Ps,
		[Parameter()]					[int]	$Pci,
		[Parameter()]					[int]	$Fan,
		[Parameter()]					[int]	$Battery
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
Process
{	$Cmd = " servicenode status "
	if($Ps) 		{	$Cmd += " -ps $Ps " 	}
	if($Pci)		{	$Cmd += " -pci $Pci " 	}
	if($Fan)		{	$Cmd += " -fan $Fan " 	}
	if($Battery)	{	$Cmd += " -bat $Battery" }
	if($Nodeid)		{	$Cmd += " $Nodeid " 	}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Reset-A9System 
{
<#
.SYNOPSIS
	Halts or reboots the entire system.
.DESCRIPTION
	The command shuts down an entire system.
.PARAMETER Halt
	Specifies that the system should be halted after shutdown. If this subcommand is not specified, the reboot or restart subcommand must be used.
.PARAMETER Reboot
	Specifies that the system should be restarted after shutdown. If this subcommand is not given, the halt or restart subcommand must be used.
.PARAMETER Restart
	Specifies that the storage services should be restarted. If this subcommand is not given, the halt or reboot subcommand must be used.
.EXAMPLE
	PS:> Reset-A9System -Halt
.NOTES
	This command requires a SSH type connection.
	Authority = Super, Service
		Any role granted the sys_shutdown right
	
	Usage: Access to all domains is required to run this command. The execution of shutdownsys command can affect service. Hence, a confirmation is 
	required before proceeding with this command. After the shutdownsys command is issued, there is no indication from the CLI that the shutdown 
	is occurring. You can issue the showsys command to display the current status of the system during the initial stage of the shutdown process 
	and after the system has fully restarted.

	If the node that was running on the system manager fails or if the system manager process exits while executing the shutdownsys command, 
	the shutdown will not complete. The only safe action is to reissue the shutdownsys command.

	Do not issue any commands other than showsys while the system is shutting down.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Halt',   Mandatory)]	[switch]	$Halt,
		[Parameter(ParameterSetName='Reboot', Mandatory)]	[switch]	$Reboot,
		[Parameter(ParameterSetName='Restart',Mandatory)]	[switch]	$Restart
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " shutdownsys "
	if($Halt)	{	$Cmd += " halt " }
	if($Reboot)	{	$Cmd += " reboot " }
	if($Restart){	$Cmd += " restart " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Update-A9PdFirmware
{
<#
.SYNOPSIS
	Upgrade physical disk firmware.
.DESCRIPTION
	The command upgrades the physical disk firmware.
.PARAMETER Skiptest
	Skips the 10 second diagnostic test normally completed after each physical disk upgrade.
.PARAMETER All
	Specifies that all physical disks with valid IDs and whose firmware is not current are upgraded. If this option is not specified, then
	either the -w option or PD_ID specifier must be issued on the command line.
.PARAMETER WWN
	Specifies that the firmware of either one or more physical disks, identified by their WWNs, is upgraded. If this option is not specified,
	then either the -a option or PD_ID specifier must be issued on the command line.
.PARAMETER PD_ID
	Specifies that the firmware of either one or more physical disks identified by their IDs (PD_ID) is upgraded. If this specifier is not
	used, then the -a or -w option must be issued on the command line.
.NOTES
	This command requires a SSH type connection.
	Authority: Super, Service
		Any role granted the sys_shutdown right
	Usage:
	- Access to all domains is required to run this command.
	- The execution of shutdownsys command can affect service.
	- Hence, a confirmation is required before proceeding with this command.
	- After the shutdownsys command is issued, there is no indication from the CLI that the shutdown is occurring. You can issue the showsys command to display the current status of the system during the initial stage of the shutdown process and after the system has fully restarted.
	- If the node that was running on the system manager fails or if the system manager process exits while executing the shutdownsys command, the shutdown will not complete. The only safe action is to reissue the shutdownsys command.
	- Do not issue any commands other than showsys while the system is shutting down.
#>
[CmdletBinding()]
param(	[Parameter()]							[switch]	$Skiptest,
		[Parameter(ParameterSetName='All')]		[switch]	$All,
		[Parameter(ParameterSetName='byWWN')]	[String]	$WwN,
		[Parameter(ParameterSetName='byPdId')]	[String]	$PD_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " upgradepd "
	$Cmd += " -f " 
	if($Skiptest)		{	$Cmd += " -skiptest " } 
	if($All)			{	$Cmd += " -a " } 
	if($WWN)			{	$Cmd += " -w $WWN " } 
	if($PD_ID) 		{	$Cmd += " $PD_ID " } 
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9ResetReason
{
<#
.SYNOPSIS
	The cmdlet displays component reset reason details.
.DESCRIPTION
	The command displays component reset reason details.
.PARAMETER Detailed
	Specifies that more detailed information about the system is displayed.
.PARAMETER SANConnection 
	Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection  
.EXAMPLE
	To display reset reason in table format:

	PS:> Get-A9ResetReason
.EXAMPLE
	To display reset reason in more detail (-d option):
	
	PS:> Get-A9ResetReason -detailed
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showreset "
	if ($Detailed) {    $Cmd += " -d "   }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
    return $Result 
}
}

Function Set-A9Security
{
<#
.SYNOPSIS
	Control security parameters.
.DESCRIPTION
	The cmdlet controls security parameters of the system
.PARAMETER Fips
	Valid parameters for fips are to Enable, disable or restart. 
	Enables the use of FIPS 140-2 validated cryptographic modules on system management interfaces.
	Disables the use of FIPS 140-2 validated cryptographic modules on system management interfaces.
	Restarts all services that are in "Enable failed" status.
.PARAMETER SSHKey
	Valid parameters for SSH-Keys are Generate or SYnc
	Generate = Regenerates the SSH host keys and distributes them to all nodes.
	Sync = Copies the SSH host keys from the current node to all other nodes.
.EXAMPLE
    Enables fips mode

    PS:> Set-A9Security -fips enable

    Warning: Enabling FIPS mode requires restarting all system management interfaces,  which will terminate ALL existing connections including this one.
    When that happens, you must reconnect to continue.
	Continue enabling FIPS mode (yes/no)?
.EXAMPLE
    Disables fips mode

    PS:> Set-A9Security -fips disable

    Warning: Disabling FIPS mode requires restarting all system management interfaces,
    which will terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue disabling FIPS mode (yes/no)?
.EXAMPLE
    Restarts services which are not currently enabled
    
    PS:> Set-A9Security -fips restart
    
    Warning: Will restart all services that are not enabled, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue restarting (yes/no)?
.EXAMPLE
    Regenerates the SSH host keys and distributes them to the other nodes

    PS:> Set-A9Security -sshkey generate

    Warning: This action will restart the ssh service, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue restarting (yes/no)?
.EXAMPLE
    Syncs the SSH host keys from the current node to all other nodes

    PS:> Set-A9Security -sshkey sync

    Warning: This action will restart the ssh service, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue restarting (yes/no)?
.NOTES
	This command requires a SSH type connection.
	Authority: Super
		Any role granted the security_control right.
	Super, Service (for status option only)
	Any role granted the security_status_control right.
	Usage: 
	- The Management Interfaces are CIM, CLI, EKM used for Data at Rest Encryption, LDAP Authentication, QW, RDA, SNMP, Syslog, SSH, and WSAPI.
	- EKM and Syslog interfaces always have FIPS mode enabled.

	WARNING:Enabling FIPS mode will terminate ALL existing management interfaces/connections/services.
	WARNING:Regenerating or syncing the SSH host keys will terminate ALL existing SSH connections.
#>
[CmdletBinding()]
param(  [Parameter(ParameterSetName='FIPS')]	[ValidateSet('enable','disable','restart')]	[string]	$fips,
		[Parameter(ParameterSetName='SSHKeys')]	[ValidateSet('Generate','Sync')]			[string]	$SSHKey
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process 
{	$Cmd = " controlsecurity "
	if ($PSBoundParameters.ContainsKey('fips')	) 		{    $Cmd += " fips $fips "    		}
	if ($PSBoundParameters.ContainsKey('SSHKey')) 		{    $Cmd += " ssh-keys $SSHKey "   }
	$Cmd += " -f "  
    write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SecurityFIPS
{    
<#
.SYNOPSIS
	Show Control security parameters.
.DESCRIPTION
	The cmdlet shows the status of security parameters of system management interfaces.
.PARAMETER FipsStatus
	Shows the status of security parameters of system management interfaces.
.EXAMPLE
    Shows the current mode of FIPS and status of services

    PS:> Get-A9Security -fipsstatus

    FIPS mode: Enabled

    Service Status
    CIM     Disabled
    CLI     Enabled
    EKM     Enabled
    LDAP    Enabled
    QW      Enabled
    RDA     Disabled
    SNMP    Disabled
    SSH     Enabled
    SYSLOG  Enabled
    VASA    Disabled
    WSAPI   Disabled
    -----------------
    11      6 Enabled
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param( 	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " controlsecurity fips status "
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
    Return $Result
}
}


# SIG # Begin signature block
# MIIsVQYJKoZIhvcNAQcCoIIsRjCCLEICAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBzBFAxLuJU
# neGz+r09OBu7lr44fIPZFjDq7xLnEmXyIm4jRpDlqgmoMsBqQeO/QPApCUgs3B72
# 49LnMcbRpW1EoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhIwghoOAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQJRx1oUBbiO7V5gTRDBOsogtJGwPjkt2/mPEwO/am62xHcVW5h+Sfz5a
# vrT9phyaIUYq5UH5V92m2b+XwnmnASEwDQYJKoZIhvcNAQEBBQAEggGATcUxEc0Y
# nntS4qbk1NIRqnOWW3DCOrpfpDxnC0tdc0U12vZCzoN67rFp93kQJR2qrxfU1NU/
# DMXAHZI0PwKnA5YVQlhUGwj/GTJAhJMZAMA9q1k95ncMzel25MB/oSjLvQ24pAeX
# 9ZMWJj6LIFtsI7CHBrIEPC5Qzyny7uwGKAhd8A1ACu9RRyHCF3JZhizJWhT+84N3
# 68deOa77O0WP1OTbrfpGQ0RYsnJ/Yq+OjJFKoJ6Um/o5eYr5LSWp3NWM4YkWuj2X
# c92m/VMBxgeRI25ctFor2QNhEf11RywejICu0iyLAqJVpllH2+3q4NkfTNzi6x37
# GR3kynxVhN0mmb7Vm8rruTg4XILU8Uw+hFoVLyP9dcRDYBvpyzNP5R6rNI5GtO19
# w4mD5tp8MoK7Hrrzf8rcRZtpzvG+25vkX67NCW6+43Mn52JWXb/OzOzo3OcAM1MA
# TmSFAdjPYi1rteoxJ6G5289+jBBZVCDxVV6S6l+GQinqnFYlmRilUslwoYIXWzCC
# F1cGCisGAQQBgjcDAwExghdHMIIXQwYJKoZIhvcNAQcCoIIXNDCCFzACAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDBkImWRke/EFefeDzkBdmmOg0lc65nAwwf+kt8L
# SqLAmaBwl+6diVro8prXHtK0KOMCEQC4lBDNrF/LcJxvQlZKadISGA8yMDI1MDUx
# NTAyMjIyN1qgghMDMIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVow
# QjELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdp
# Q2VydCBUaW1lc3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL5qc5/2lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L
# 660x5XltSVhhK64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLusl
# xdr9Qq82aKcpA9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7a
# vVnpUVmPvkxT8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl
# 7/r419CvEYVIrH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+N
# BikDO0mlUh902wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVki
# qLq+ISTdEjJKGjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5
# n10jxmGpxoMc6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h
# 6gYldp4FCMgrXdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNe
# REXAu2xUDEW8aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLq
# fY/M/SdV6mwWTyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIB
# hzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggr
# BgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0j
# BBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGal
# Y17uT5IfdqBbMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBp
# bmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tO
# CB3RKE/P09x7gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSX
# gmUrDKNSQqGTdpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPn
# vIWrqVogK0qM8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM
# 2UeUUW/8z3fvjxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlT
# VYzqfLDbe9PpBKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ
# /xll/HjO9JbNVekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef
# 4uaZFORNekUgQHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk91
# 04WQzYuVNsxyoVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7
# ucykW7eaCuWBsBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZD
# BD+XgbF+23/zBjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3K
# eFUCS7tpFk7CrDqkMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkq
# hkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBU
# cnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFV
# xyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8z
# H1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE9
# 8NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iE
# ZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXm
# G6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVV
# JnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz
# +ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8
# ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkr
# qPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKo
# wSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3I
# XjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaA
# FOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4
# oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqG
# SIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQ
# XeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwI
# gqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs
# 5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAn
# gkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnG
# E4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9
# P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt
# +8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Z
# iza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgx
# tGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimH
# CUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCC
# BY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290
# IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE9
# 8orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9S
# H8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g
# 1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RY
# jgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgD
# EI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNA
# vwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDg
# ohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQA
# zH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOk
# GLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHF
# ynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gd
# LfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYE
# FOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# dDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkq
# hkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7
# IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/5
# 9PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0
# POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISf
# b8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhU
# LSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEBMHcwYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QQIQC65mvFq6f5WHxvnpBOMzBDANBglghkgBZQMEAgIFAKCB4TAaBgkqhkiG9w0B
# CQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI1MDUxNTAyMjIyN1ow
# KwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQU29OF7mLb0j575PZxSFCHJNWGW0UwNwYL
# KoZIhvcNAQkQAi8xKDAmMCQwIgQgdnafqPJjLx9DCzojMK7WVnX+13PbBdZluQWT
# mEOPmtswPwYJKoZIhvcNAQkEMTIEMB3iU3HRi0uLUcaEshkopS/m0cs3GxQwmAUk
# 5LICnGlKsCCkq6TcUM2uC+6hFDkbqjANBgkqhkiG9w0BAQEFAASCAgCOAch8eIcL
# lXjJntg8p7C6Qh3OuygE7ZIIP56e1uyxp36nw/cb+Z1GH/GM7f67nMUjIvQNmG1E
# +k/jhKIKZkeqQh15rA3f44VHEsWOJHoBJQN0ads7BlKWIlZPvE1VQHPkzJ8Nv/IY
# yllgz9iKkthdsekSrZs9A5+ZuFtViAyrvIKXSs6jqfyTroTO81WKy97BGwCD1BJJ
# IB/CAAspeqnOV1MGe2tuSS3SKVFTmSqgKm5+81VeZgAj0uKJPERyWQZMG4Dbesx9
# sDSqfjzE4ypXmOeXDA8pt6gZ0Ghz35xpEs81sfQQNPobrSIBJN/sNKtnFfS5c/m0
# S41cx2hJWePiHSHBgmoEQPSuaVjhrLLd59LkCK5eFkYl+0uq2CYu7wlr2F6XEr6f
# Q38trJY/KocK+o5dV4fmy3Kv8/Wx2/mmAfjZ1RsXz+sWy/nDnA4+Y0mwc0U0ohVo
# +93febRIFyChLnabRHpe0msFC9GBSrq3Rxb+wlLJUfb3Jx+RCzCHc+wAiYYWSFDN
# tzIZ12xXCWX5unO4hmcowmpVOoUuOAUIPZasHRRBwpBYx48csQaFFJ4uuO9PnyBC
# GQDmvwk8CMq20jEgm4DZrvclqHL6lYZQQODd7w7TwGSlmWxsIJa8RDbwokAtf3NN
# SpplABpaqpDa+/e7AKuRtlM4Vrar8onCKg==
# SIG # End signature block
