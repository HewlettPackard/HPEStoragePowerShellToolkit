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
param(	[Parameter(ParameterSetName='CheckOnly', Mandatory=$true)]	[switch]	$Checkonly,
		[Parameter()]												[switch]	$F,
		[Parameter()]												[switch]	$Nopatch,
		[Parameter(ParameterSetName="Tune", Mandatory=$true)]		[switch]	$Tune,
		[Parameter(ParameterSetName="NoTune",Mandatory=$true)]		[switch]	$Notune
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
	$Cmd += " $Node_ID "
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
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
		[Parameter(Mandatory=$True)]						[String]	$Cage_name,
		[Parameter(Mandatory=$True)]						[String]	$Magazine,
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
param(	[Parameter(ParameterSetName='StartPCM', Mandatory=$true)]	
		[Parameter(ParameterSetName='StartIOM', Mandatory=$true)]	
																	[switch]	$Start,
		[Parameter(ParameterSetName='EndPCM',   Mandatory=$true)]	
		[Parameter(ParameterSetName='EndIOM',   Mandatory=$true)]	
																	[switch]	$End,
		[Parameter(ParameterSetName='Reset', 	Mandatory=$true)]	
										[ValidateSet('0','1')]		[int]		$Reset,
		[Parameter(ParameterSetName='HReset',	Mandatory=$true)]	
										[ValidateSet('0','1')]		[int]		$HReset,
		[Parameter(ParameterSetName='Remove',	Mandatory=$true)]	
																	[switch]	$Remove,	
		[Parameter(ParameterSetName='StartPCM', Mandatory=$true)]
		[Parameter(ParameterSetName='EndPCM', 	Mandatory=$true)]
										[ValidateSet('0','1')]		[int]		$Pcm,
		[Parameter(ParameterSetName='StartIOM', Mandatory=$true)]
		[Parameter(ParameterSetName='EndIOM', 	Mandatory=$true)]
										[ValidateSet('0','1')]		[int]		$Iom,
		[Parameter(Mandatory=$true)]								[String]	$CageName
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
param(	[Parameter(Mandatory=$True)] 	
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
param(	[Parameter(Mandatory=$True)] 	
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

