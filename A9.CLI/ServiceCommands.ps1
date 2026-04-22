## 	©2025 Hewlett Packard Enterprise Development LP
Function Add-A9Hardware
{
<#
.SYNOPSIS
	Admit new hardware into the system.
.DESCRIPTION
	The command admits new hardware into the system. If new disks are discovered on any two-node HPE StoreServ system, tunesys will be
	started automatically to redistribute existing volumes to use the new capacity. This facility can be disabled using either the -notune
	option or setting the AutoAdmitTune system parameter to "no". On systems with more than two nodes, tunesys must always be run manually after disk installation.
	- Handles any nodes, disks, or cages added into the system.
	- Verifies the presence of all expected hardware and handles all checks, including valid states, cabling, and firmware revisions.
	- Handles creating system logical disks while adding and rebalancing spare chunklets.
	- Allocates spares according to the algorithm specified by the SparingAlgorithm system parameter.
	- If new disks are discovered, the set size for existing CPGs is recalculated. Changes to the CPG occur prior to any tunesys operation so that the affected LDs are automatically tuned.
	- Checks for drive table patch updates unless you specify the -nopatch option.
	- In addition, discovery of new disks in any combination can cause tunesys to start automatically and rebalance the system after the admithw command has completed.
.PARAMETER Checkonly
	Only performs passive checks; does not make any changes.
.PARAMETER SkipDrivePatch
	Suppresses the check for drive table update packages for new hardware enablement.
.PARAMETER SupressAutotune
	Do not automatically run tunesys to rebalance the system after new disks are discovered.
.NOTES
	This command utilizes the SSH command 'admithw' 
	This command requires a SSH type connection. 
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Checkonly,
		[Parameter()]	[switch]	$SkipDrivePatch,
		[Parameter()]	[switch]	$SupressAutotune
)
Begin
{	Test-A9CLIConection
}
Process
{	$Cmd = " admithw "
	if($Checkonly)			{	$Cmd += " -checkonly " 	}
	else					{	$Cmd += " -f " 			}
	if($SkipDrivePatch)		{	$Cmd += " -nopatch " 	}
	if($SupressAutoTune)	{	$Cmd += " -tune " 		}
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
.OUTPUTS
	Patch ID.          Specifies the patch ID. 
	Release Version.   Specifies TPD or UI release affected by the patch. 
	Synopsis.          Specifies the purpose of the patch. 
	Date.              Specifies the build date of the patch. 
	Bugs fixed.        Specifies the bugs fixed. 
	Description.       Specifies a detailed description of the problem or fix. 
	Affected Packages. Specifies the new packages being changed. 
	Obsoletes.         Specifies the patch IDs deleted by this patch. 
	Requires.          Specifies the patch IDs of any other patches required by this patch. 
	Note-s.             Specifies any special instructions for the patch. 
.NOTES
	This command utilizes the SSH command 'showpatch' 
	This command requires a SSH type connection. 
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
{	if ( $PersistArrayType -eq 'AlletraMP-B10000' )
		{	write-warning "This command only works on HPE Alletra9000 and older type arrays."
			return
		}
	$Cmd = " showpatch "
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
	
	Get list of Storage system release version number only
.EXAMPLE
    PS:> Get-A9Version -Build	

	Get list of Storage system versions including build levels
.NOTES
	This command utilizes the SSH command 'showversion' 
	This command requires a SSH type connection. 
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
	This command utilizes the SSH command 'shutdownnode' 
	This command requires a SSH type connection.
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
	This command utilizes the SSH command 'controlmag' 
	This command requires a SSH type connection.
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

Function Invoke-A9CageService
{
<#
.SYNOPSIS
	Cam be used to start or stop a service window on a cage or upgrade the cage firmware on one or many cages
.DESCRIPTION
	The command is necessary when executing removal and replacement actions for a drive cage interface card or power cooling module. The
	start subcommand is used to initiate service on a cage, and the end subcommand is used to indicate that service is completed.
	Alternately you ccan use the upgrade command options to upgrade the firmware on cages. 
	Issuing the Invoke-A9CageService command results in chunklet relocation, causing a dip in throughput.
	After issuing the start subcommand, the end subcommand must be issued to indicate that service is completed and to restore the cage to its normal state.
	When you issue the upgradecage command, the drive cage becomes temporarily degraded as the system upgrades each interface card.
.PARAMETER StartServiceWindow
	Specifies the start of service on a cage.
.PARAMETER EndServiceWindow
	Specifies the end of service on a cage.
.PARAMETER Reset
	Initiates a soft reset of the interface card for DCN5, DCS11, and DCS12 drive cages. This specifies the interface card number of the cage to be reset and van be 0 or 1.
.PARAMETER HardReset
	Initiates a hard reset of the interface card for DCN5, DCS11, and DCS12 drive cages. This specifies the interface card number of the cage to be reset and van be 0 or 1. 
.PARAMETER Remove
	Removes the indicated drive cage (indicated with the <cagename> specifier) from the system. This subcommand fails when the cage has active ports or is in use.
.PARAMETER Pcm
	For DCS11 and DCS12, this specifies that the Power Cooling Module (PCM) will be serviced. For DCN5, this specifies the Power Cooling Battery
	Module (PCBM) will be serviced. The Value for this can either be 0 or 1
.PARAMETER Iom
	Specifies that the I/O module will be serviced. This option is not valid for DCN5 cage. The Value for this can either be 0 or 1
.PARAMETER CageName
	Specifies the name of the cage to be serviced or upgraded
.PARAMETER UpgradeAllCages
	All drive cages are upgraded one at a time.
.PARAMETER UpgradeAllCagesInParallel
	All drive cages are upgraded in parallel by interface card domain. If -wait is specified, the command will not return until the upgrades
	are completed. Otherwise, the command returns immediately and completion of the upgrade can be monitored with the -status option.
.PARAMETER UpgradeStatus
	Print status of the current operation in progress or the last executed operation. If any cagenames are specified, 
	result is filtered to only display those cages.
.EXAMPLE
	The following example starts the service of interface card module 0 on cage0:

	PS:> invoke-A9CageService start -iom 0 cage0
.NOTES
	This command utilizes the SSH command 'servicecage', 'upgradecage' 
	This command requires a SSH type connection.
	
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='StartPCM', Mandatory)]	
		[Parameter(ParameterSetName='StartIOM', Mandatory)]	
																	[switch]	$StartServiceWindow,
		[Parameter(ParameterSetName='EndPCM',   Mandatory)]	
		[Parameter(ParameterSetName='EndIOM',   Mandatory)]	
																	[switch]	$EndServiceWindow,
		[Parameter(ParameterSetName='Reset', 	Mandatory)]	
										[ValidateSet('0','1')]		[int]		$Reset,
		[Parameter(ParameterSetName='HReset',	Mandatory)]	
										[ValidateSet('0','1')]		[int]		$HardReset,
		[Parameter(ParameterSetName='Remove',	Mandatory)]	
																	[switch]	$Remove,	
		[Parameter(ParameterSetName='StartPCM', Mandatory)]
		[Parameter(ParameterSetName='EndPCM', 	Mandatory)]
										[ValidateSet('0','1')]		[int]		$Pcm,
		[Parameter(ParameterSetName='StartIOM', Mandatory)]
		[Parameter(ParameterSetName='EndIOM', 	Mandatory)]
										[ValidateSet('0','1')]		[int]		$Iom,
		
		[Parameter(ParameterSetName='StartIOM', Mandatory)]
		[Parameter(ParameterSetName='EndIOM', Mandatory)]
		[Parameter(ParameterSetName='StartPCM', Mandatory)]
		[Parameter(ParameterSetName='EndPCM', Mandatory)]
		[Parameter(ParameterSetName='Reset', Mandatory)]
		[Parameter(ParameterSetName='HReset', Mandatory)]
		[Parameter(ParameterSetName='Remove', Mandatory)]
		[Parameter(ParameterSetName='UpgradeSingle', Mandatory)]
		[Parameter(ParameterSetName='Status', Mandatory)]			[String]	$CageName,

		[Parameter(ParameterSetName='AllAndSequential',Mandatory)]	[switch]	$UpgradeAllCages,
		[Parameter(ParameterSetName='Parallel',Mandatory)]			[switch]	$UpgradeAllCagesInParallel,
		[Parameter(ParameterSetName='Parallel')]					[switch]	$WaitUpgradeComplete,
		[Parameter(ParameterSetName='Status',Mandatory)]			[switch]	$UpgradeStatus
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$ArrayOfServiceCommands = @('StartPCM','EndPCM','StartIOM','EndIOM','Reset','HReset','Remove')
	$ArrayOfUpgradeCommands = @('UpgradeSingle','Status','AllAndSequential','Parallel')
	if ($ArrayOfServiceCommands -contains $PSCmdlet.ParameterSetName  )
		{	$Cmd = " servicecage "
			if($StartServiceWindow)
				{	$Cmd += " start "	
					if($PSBoundParameters.ContainsKey('Iom'))	{	$Cmd += " -iom "	}
					if($PSBoundParameters.ContainsKey('Pcm'))	{	$Cmd += " -pcm "	}	
					$Cmd += $Pcm + $Iom	+ ' ' 
				}
			if($EndServiceWindow)
				{	$Cmd += " end "
					if($PSBoundParameters.ContainsKey('Iom'))	{	$Cmd += " -iom "	}
					if($PSBoundParameters.ContainsKey('Pcm'))	{	$Cmd += " -pcm "	}	
					$Cmd += $Pcm + $Iom	+ ' ' 
				}
			if($PSBoundParameters.ContainsKey('Reset'))			{	$Cmd += " reset -f "  + $Reset		}
			if($PSBoundParameters.ContainsKey('HardReset'))		{	$Cmd += " hreset -f " + $HardReset	}
			if($Remove)											{	$Cmd += " remove -f "				}
			$Cmd += " $CageName "
			write-verbose "Executing the following SSH command `n`t $cmd"
			$Result = Invoke-A9CLICommand -cmds  $Cmd
			Return $Result
		}
	elseif ($ArrayOfUpgradeCommands -contains $PSCmdlet.ParameterSetName)
		{	$Cmd = " upgradecage "
			if($UpgradeAllCages) 		
							{	$Cmd += " -a " }
			if($UpgradeAllCagesInParallel)	
							{	$Cmd += " -parallel "
								if($WaitUpgradeComplete)
									{	$Cmd += " -wait " }
							}
			if($UpgradeStatus)		
							{	$Cmd += " -status " }
			if($Cagename)	{	$Cmd += " $Cagename " }
			write-verbose "Executing the following SSH command `n`t $cmd"
			$Result = Invoke-A9CLICommand -cmds  $Cmd
			if($UpgradeStatus)	
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
							$DataPS = Import-Csv $tempFile 
							Remove-Item  $tempFile	
							return $DataPS
						}
					else{	Return  $Result	}
				}
			else{	Return $Result }
		}
} 
}

Function Set-A9ServiceNodes
{
<#
.SYNOPSIS
	Prepare a node for service.
.DESCRIPTION
	The command informs the system that a certain component will be replaced, and will cause the system to indicate the physical location of that component.
	Usage: Access to all domains is required to run this command. If a component is found unsafe to remove, the command will return an error.
	If no option is specified, only node LED will be illuminated.
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
	This command utilizes the SSH command 'servicenode'
	This command requires a SSH type connection.

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
		This command utilizes the SSH command 'servicenode'
	This command requires a SSH type connection.
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
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
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
	This command utilizes the SSH command 'shutdownsys'
	This command requires a SSH type connection.
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
	This command utilizes the SSH command 'upgradepd'
	This command requires a SSH type connection.
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
	This command utilizes the SSH command 'showreset'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$ShowRaw
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showreset -d"
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if ( $showraw ) 	{	return $Result }
	$DataPS = @()
	$NewItem = $null
	$NewItemCount=1
	$NewItem=@{ "ItemIndex" = $NewItemCount }
	foreach ($line in $Result)
		{	if ( $line.trim() )
				{	# The line is another datapoint 
					$datapoint = $line.split(':')	
					$datakey = $datapoint[0].trim()
					if ($datakey -eq 'Time')
						{	$dataval = $datapoint[1] +":" + $datapoint[2] + ':' + $datapoint[3] 
						}
					else{ $dataVal = $datapoint[1]
						}
					$NewItem[$datakey] = $dataval.trim()				
				}
			else{	$DataPS += $NewItem
					$NewItem=@{}
					$NewItemcount+=1
				}	
		}
	$DataPS += $NewItem
	$DataPS = $DataPS | convertto-json | convertfrom-json
	$NewObj = @(    foreach( $Item in $DataPS)
                                                    {   $NewItem=@{PSTypeName = "HPE.A9Storage.Reset"}
                                                        $Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
                                                        $DataSetType = "HPE.A9Storage.Reset"
                                                        $NewItem.PSTypeNames.Insert(0,$DataSetType)
                                                        $DataSetType = $DataSetType + ".TypeName"
                                                        $NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
                                                        [PSCustomObject]$NewItem
                                                    }
                                        )
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
    return $NewObj
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
.EXAMPLE
    Disables fips mode

    PS:> Set-A9Security -fips disable

    Warning: Disabling FIPS mode requires restarting all system management interfaces,
    which will terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
.EXAMPLE
    Restarts services which are not currently enabled
    
    PS:> Set-A9Security -fips restart
    
    Warning: Will restart all services that are not enabled, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
.EXAMPLE
    Regenerates the SSH host keys and distributes them to the other nodes

    PS:> Set-A9Security -sshkey generate

    Warning: This action will restart the ssh service, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
.EXAMPLE
    Syncs the SSH host keys from the current node to all other nodes

    PS:> Set-A9Security -sshkey sync

    Warning: This action will restart the ssh service, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
.NOTES
	This command utilizes the SSH command 'controlsecurity'
	This command requires a SSH type connection.

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
	This command utilizes the SSH command 'controlsecurity'
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
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
    Return $Result
}
}

