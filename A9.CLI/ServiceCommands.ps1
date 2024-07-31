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
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Checkonly,
		[Parameter()]	[switch]	$F,
		[Parameter()]	[switch]	$Nopatch,
		[Parameter()]	[switch]	$Tune,
		[Parameter()]	[switch]	$Notune
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
	The command displays patches applied to a system.
.EXAMPLE
	PS:> Get-A9SystemPatch
.EXAMPLE
	PS:> Get-A9SystemPatch -Hist
.PARAMETER Hist
	Provides an audit log of all patches and updates that have been applied to the system.
.PARAMETER D
	When used with the -hist option, shows detailed history information including the username who installed each package. If -d is used with a patch specification,
	it shows detailed patch information. Otherwise it shows detailed information on the currently installed patches.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Hist,
		[Parameter()]	[switch]	$D
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showpatch "
	if($Hist)	{	$Cmd += " -hist " }
	if($D) 		{	$Cmd += " -d " 	}
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
.EXAMPLE
    PS:> Get-A9Version

	Get list of Storage system software version information
.EXAMPLE
    PS:> Get-A9Version -S	

	Get list of Storage system release version number only
.EXAMPLE
    PS:> Get-A9Version -B	

	Get list of Storage system build levels
.PARAMETER A
	Show all component versions
.PARAMETER B
	Show build levels
.PARAMETER S
	Show release version number only (useful for scripting).
#>
[CmdletBinding()]
param(	[Parameter()]    [switch]    $A,
        [Parameter()]    [switch]    $B,
        [Parameter()]    [switch]    $S
)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process
{	$Cmd = "showversion"
    if ($A) {    $Cmd += " -a"    }
    if ($B) {    $Cmd += " -b"    }
    if ($S) {    $Cmd += " -s"    }
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
.PARAMETER A
	All drive cages are upgraded one at a time.
.PARAMETER Parallel
	All drive cages are upgraded in parallel by interface card domain. If -wait is specified, the command will not return until the upgrades
	are completed. Otherwise, the command returns immediately and completion of the upgrade can be monitored with the -status option.
.PARAMETER Status
	Print status of the current operation in progress or the last executed operation. If any cagenames are specified, result
is filtered to only display those cages.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$A,
		[Parameter()]	[switch]	$Parallel,
		[Parameter()]	[switch]	$Wait,
		[Parameter()]	[switch]	$Status,
		[Parameter()]	[String]	$Cagename
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process 
{	$Cmd = " upgradecage "
	if($A) 			{	$Cmd += " -a " }
	if($Parallel)	{	$Cmd += " -parallel "
						if($Wait)		{	$Cmd += " -wait " }
					}
	if($Status)		{	$Cmd += " -status " }
	if($Cagename)	{	$Cmd += " $Cagename " }
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
.EXAMPLE
	PS:> Reset-A9SystemNode -Halt -Node_ID 0.
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
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Halt',Mandatory=$true)]	[switch]	$Halt,
		[Parameter(ParameterSetName='Reboot',Mandatory=$true)]	[switch]	$Reboot,
		[Parameter(ParameterSetName='Check',Mandatory=$true)]	[switch]	$Check,
		[Parameter(ParameterSetName='Restart',Mandatory=$true)]	[switch]	$Restart,
		[Parameter(Mandatory=$True)]							[String]	$Node_ID
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
	if($Node_ID)	{	$Cmd += " Node_ID " }
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
	drive magazine or disk drive within a drive magazine.
.EXAMPLE
	PS:> Set-A9Magazines -Offloop -Cage_name "xxx" -Magazine "xxx"
.EXAMPLE
	PS:> Set-A9Magazines -Offloop -Port "Both" -Cage_name "xxx" -Magazine "xxx"
.PARAMETER Offloop
	Specifies that the specified drive magazine or disk drive is either taken off-loop or brought back on-loop.
.PARAMETER Onloop
	Specifies that the specified drive magazine or disk drive is either
	taken off-loop or brought back on-loop.
.PARAMETER Cage_name
	Specifies the name of the drive cage. Drive cage information can be viewed by issuing the showcage command.
.PARAMETER Magazine
	Specifies the drive magazine number within the drive cage. Valid formats are <drive_cage_number>.<drive_magazine> or <drive_magazine> (for example 1.3 or 3, respectively).
.PARAMETER Disk
	Specifies that the operation is performed on the disk as determined by its position within the drive magazine.
	If not specified, the operation is performed on the entire drive magazine.
.PARAMETER Port
	Specifies that the operation is performed on port A, port B, or both A and B. If not specified, the operation is performed on both ports A and B.
.PARAMETER F
	Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
#>
[CmdletBinding()]
param( 	[Parameter()]					[switch]	$Offloop,
		[Parameter()]					[switch]	$Onloop,
		[Parameter(Mandatory=$True)]	[String]	$Cage_name,
		[Parameter(Mandatory=$True)]	[String]	$Magazine,
		[Parameter()]					[String]	$Disk,
		[Parameter()]					[String]	$Port,
		[Parameter()]					[switch]	$F
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process 
{	$Cmd = " controlmag "
	if($Offloop)	{	$Cmd += " offloop " }
	Elseif($Onloop) {	$Cmd += " onloop " }
	else			{	Return "Select at least one from [ Offloop | Onloop ] " }
	if($Disk)		{	$Cmd += " -disk $Disk " }
	if($Port)		
		{	$Val = "A","B" ,"BOTH"
			if($Val -eq $T.ToLower())	{	$Cmd += " -port $Port.ToLower "	}
			else						{	return " Illegal Port value, must be either A,B or Both "	}
		}
	if($F) 			{	$Cmd += " -f " }
	if($Cage_name)	{	$Cmd += " $Cage_name " }
	if($Magazine)	{	$Cmd += " $Magazine " }
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
	Initiates a soft reset of the interface card for DCN5, DCS11, and DCS12 drive cages.
.PARAMETER Hreset
	Initiates a hard reset of the interface card for DCN5, DCS11, and DCS12 drive cages.
.PARAMETER Remove
	Removes the indicated drive cage (indicated with the <cagename> specifier) from the system. This subcommand fails when the cage has active ports or is in use.
.PARAMETER Pcm
	For DCS11 and DCS12, this specifies that the Power Cooling Module (PCM) will be serviced. For DCN5, this specifies the Power Cooling Battery
	Module (PCBM) will be serviced.
.PARAMETER Iom
	Specifies that the I/O module will be serviced. This option is not valid for DCN5 cage.
.PARAMETER Zero
	For subcommands reset and hreset, this specifies the interface card	number of the cage to be reset. For subcommands start and end, this
	specifies the number of the module indicated by -pcm or -iom to be serviced.
.PARAMETER One
	For subcommands reset and hreset, this specifies the interface card	number of the cage to be reset. For subcommands start and end, this
	specifies the number of the module indicated by -pcm or -iom to be serviced.
.PARAMETER CageName
	Specifies the name of the cage to be serviced.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Start', Mandatory=$true)]	[switch]	$Start,
		[Parameter(ParameterSetName='End',   Mandatory=$true)]	[switch]	$End,
		[Parameter(ParameterSetName='Reset', Mandatory=$true)]	[switch]	$Reset,
		[Parameter(ParameterSetName='HReset',Mandatory=$true)]	[switch]	$Hreset,
		[Parameter(ParameterSetName='Remove',Mandatory=$true)]	[switch]	$Remove,
		[Parameter()]	[switch]	$F,	
		[Parameter()]	[switch]	$Force,	
		[Parameter()]	[switch]	$Pcm,
		[Parameter()]	[switch]	$Iom,
		[Parameter()]	[switch]	$Zero,
		[Parameter()]	[switch]	$One,
		[Parameter(Mandatory=$true)]	[String]	$CageName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " servicecage "
	if($Start)
		{	$Cmd += " start "	
			if($Iom)		{	$Cmd += " -iom "	}
			elseif($Pcm)	{	$Cmd += " -pcm "	}
			else			{	Return "Select at least one from [ Iom | Pcm]..."	}		
			if($Zero)		{	$Cmd += " 0 "	}
			elseif($One)	{	$Cmd += " 1 "	}
			else			{	Return "Select at least one from [ Zero | One]..."	}
		}
	elseif($End)
		{	$Cmd += " end "
			if($Iom)	{	$Cmd += " -iom "	}
			elseif($Pcm){	$Cmd += " -pcm "	}
			else		{	Return "Select at least one from [ Iom | Pcm]..."	}
			if($Zero)	{	$Cmd += " 0 "	}
			elseif($One){	$Cmd += " 1 "	}
			else		{	Return "Select at least one from [ Zero | One]..."	}
		}
	elseif($Reset)
		{	$Cmd += " reset -f "
			if($Zero)	{	$Cmd += " 0 "	}
			elseif($One){	$Cmd += " 1 "	}
			else		{	Return "Select at least one from [ Zero | One]..."	}
		}
	elseif($Hreset)
		{	$Cmd += " hreset -f "
			if($Zero)	{	$Cmd += " 0 "	}
			elseif($One){	$Cmd += " 1 "	}
			else		{	Return "Select at least one from [ Zero | One]..."	}
		}
	elseif($Remove)		{	$Cmd += " remove -f "	}
	$Cmd += " $CageName "
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
.EXAMPLE
	Set-A9ServiceNodes -Start -Nodeid 0
.EXAMPLE
	Set-A9ServiceNodes -Start -Pci 3 -Nodeid 0
.PARAMETER Start
	Specifies the start of service on a node. If shutting down the node is required to start the service, the command will prompt for confirmation before proceeding further.
.PARAMETER Status
	Displays the state of any active servicenode operations.
.PARAMETER End
	Specifies the end of service on a node. If the node was previously
	halted for the service, this command will boot the node.
.PARAMETER Ps
	Specifies which power supply will be placed into servicing-mode. Accepted values for <psid> are 0 and 1. For HPE 3PAR 600 series
	systems, this option is not supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.PARAMETER Pci
	Only the service LED corresponding to the PCI card in the specified slot will be illuminated. Accepted values for <slot> are 3 through 5 for HPE 3PAR 600 series systems.
.PARAMETER Fan
	Specifies which node fan will be placed into servicing-mode. For HPE 3PAR 600 series systems, 
	this option is not supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.PARAMETER Bat
	Specifies that the node's battery backup unit will be placed into servicing-mode. For HPE 3PAR 600 series systems, this option is not
	supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$True)] 	[String] 	$Nodeid,
		[Parameter(ParameterSetName='Start', Mandatory=$true)]	[switch]	$Start,
		[Parameter(ParameterSetName='Status', Mandatory=$true)]	[switch]	$Status,
		[Parameter(ParameterSetName='end',   Mandatory=$true)]	[switch]	$End,
		[Parameter()]					[String]	$Ps,
		[Parameter()]					[String]	$Pci,
		[Parameter()]					[String]	$Fan,
		[Parameter()]					[switch]	$Bat
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
Process
{	$Cmd = " servicenode "
	if($Start) 		{	$Cmd += " start " }
	Elseif($Status)	{	$Cmd += " status " }
	Elseif($End) 	{	$Cmd += " end " }
	if($Ps) 		{	$Cmd += " -ps $Ps " }
	if($Pci)		{	$Cmd += " -pci $Pci " }
	if($Fan)		{	$Cmd += " -fan $Fan " }
	if($Bat)		{	$Cmd += " -bat " }
	if($Nodeid)		{	$Cmd += " Nodeid " }
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
.EXAMPLE
	PS:> Reset-A9System -Halt
.PARAMETER Halt
	Specifies that the system should be halted after shutdown. If this subcommand is not specified, the reboot or restart subcommand must be used.
.PARAMETER Reboot
	Specifies that the system should be restarted after shutdown. If this subcommand is not given, the halt or restart subcommand must be used.
.PARAMETER Restart
	Specifies that the storage services should be restarted. If this subcommand is not given, the halt or reboot subcommand must be used.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Halt',   Mandatory=$true)]	[switch]	$Halt,
		[Parameter(ParameterSetName='Reboot', Mandatory=$true)]	[switch]	$Reboot,
		[Parameter(ParameterSetName='Restart',Mandatory=$true)]	[switch]	$Restart
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " shutdownsys "
	if($Halt)	{	$Cmd += " halt " }
	if($Reboot)	{	$Cmd += " reboot " }
	if($Restart){	$Cmd += " restart " }
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
.PARAMETER F
	Upgrades the physical disk firmware without requiring confirmation.
.PARAMETER Skiptest
	Skips the 10 second diagnostic test normally completed after each physical disk upgrade.
.PARAMETER A
	Specifies that all physical disks with valid IDs and whose firmware is not current are upgraded. If this option is not specified, then
	either the -w option or PD_ID specifier must be issued on the command line.
.PARAMETER W
	Specifies that the firmware of either one or more physical disks, identified by their WWNs, is upgraded. If this option is not specified,
	then either the -a option or PD_ID specifier must be issued on the command line.
.PARAMETER PD_ID
	Specifies that the firmware of either one or more physical disks identified by their IDs (PD_ID) is upgraded. If this specifier is not
	used, then the -a or -w option must be issued on the command line.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$F,
		[Parameter()]	[switch]	$Skiptest,
		[Parameter()]	[switch]	$A,
		[Parameter()]	[String]	$W,
		[Parameter()]	[String]	$PD_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " upgradepd "
	if($F)			{	$Cmd += " -f " } 
	if($Skiptest)	{	$Cmd += " -skiptest " } 
	if($A)			{	$Cmd += " -a " } 
	if($W)			{	$Cmd += " -w $W " } 
	if($PD_ID) 		{	$Cmd += " $PD_ID " } 
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Search-A9ServiceNode
{
<#
.SYNOPSIS
	Prepare a node for service.
.DESCRIPTION
	The command informs the system that a certain component will be replaced, and will cause the system to indicate the physical location of that component.
.PARAMETER Start
	Specifies the start of service on a node. If shutting down the node	is required to start the service, the command will prompt for confirmation before proceeding further.
.PARAMETER Status
	Displays the state of any active servicenode operations.
.PARAMETER End
	Specifies the end of service on a node. If the node was previously halted for the service, this command will boot the node.
.PARAMETER Ps
	Specifies which power supply will be placed into servicing-mode. Accepted values for <psid> are 0 and 1. For HPE 3PAR 600 series
	systems, this option is not supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.PARAMETER Pci
	Only the service LED corresponding to the PCI card in the specified slot will be illuminated. Accepted values for <slot> are 3 through 5 for HPE 3PAR 600 series systems.
.PARAMETER Fan
	Specifies which node fan will be placed into servicing-mode. For HPE 3PAR 600 series systems, this option is not supported,
	use servicecage for servicing the Power Cooling Battery Module (PCBM).
.PARAMETER Bat
	Specifies that the node's battery backup unit will be placed into servicing-mode. For HPE 3PAR 600 series systems, this option is not
	supported, use servicecage for servicing the Power Cooling Battery Module (PCBM).
.PARAMETER NodeId  
	Indicates which node the servicenode operation will act on. Accepted values are 0 through 3 for HPE 3PAR 600 series systems.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Start,
		[Parameter()]	[switch]	$Status,
		[Parameter()]	[switch]	$End,
		[Parameter()]	[String]	$Ps,
		[Parameter()]	[String]	$Pci,
		[Parameter()]	[String]	$Fan,
		[Parameter()]	[switch]	$Bat,
		[Parameter(Mandatory=$true)]	[String]	$NodeId
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " servicenode "
	if($Start)		{	$Cmd += " start "}
	elseif($Status)	{	$Cmd += " status " }
	elseif($End)	{	$Cmd += " end " }
	else			{	Return "Select at least one from [Start | Status | End]..."} 
	if($Ps)			{	$Cmd += " -ps $Ps "}
	if($Pci)		{	$Cmd += " -pci $Pci "}
	if($Fan) 		{	$Cmd += " -fan $Fan "}
	if($Bat)		{	$Cmd += " -bat "}
	if($NodeId)		{	$Cmd += " $NodeId "	}
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
.PARAMETER D
	Specifies that more detailed information about the system is displayed.
.PARAMETER SANConnection 
	Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection  
.EXAMPLE
	To display reset reason in table format:

	PS:> Get-A9ResetReason
.EXAMPLE
	To display reset reason in more detail (-d option):
	
	PS:> Get-A9ResetReason -d
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$D
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showreset "
	if ($D) {    $Cmd += " -d "   }
    $Result = Invoke-A9CLICommand -cmds  $Cmd
    $Result 
}
}

Function Set-A9Security
{
<#
.SYNOPSIS
	Control security parameters.
.DESCRIPTION
	The cmdlet controls security parameters of the system
.PARAMETER FipsEnable
	Enables the use of FIPS 140-2 validated cryptographic modules on system management interfaces.
.PARAMETER FipsDisable
	Disables the use of FIPS 140-2 validated cryptographic modules on system management interfaces.
.PARAMETER FipsRestart
	Restarts all services that are in "Enable failed" status.
.PARAMETER SSHKeysGenerate
	Regenerates the SSH host keys and distributes them to all nodes.
.PARAMETER SSHKeysSync
	Copies the SSH host keys from the current node to all other nodes.
.PARAMETER F
	Specifies that the operation is forced. If this option is not used, the command requires confirmation before proceeding with its operation.Valid for fips and ssh-keys
.EXAMPLE
    Enables fips mode

    PS:> Set-A9Security -fipsenable

    Warning: Enabling FIPS mode requires restarting all system management interfaces,  which will terminate ALL existing connections including this one.
    When that happens, you must reconnect to continue.
	Continue enabling FIPS mode (yes/no)?
.EXAMPLE
    Disables fips mode

    PS:> Set-A9Security -fipsdisable

    Warning: Disabling FIPS mode requires restarting all system management interfaces,
    which will terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue disabling FIPS mode (yes/no)?
.EXAMPLE
    Restarts services which are not currently enabled
    
    PS:> Set-A9Security -fipsrestart
    
    Warning: Will restart all services that are not enabled, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue restarting (yes/no)?
.EXAMPLE
    Regenerates the SSH host keys and distributes them to the other nodes

    PS:> Set-A9Security -ssh-keysgenerate

    Warning: This action will restart the ssh service, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue restarting (yes/no)?
.EXAMPLE
    Syncs the SSH host keys from the current node to all other nodes

    PS:> Set-A9Security -ssh-keyssync

    Warning: This action will restart the ssh service, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue restarting (yes/no)?
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  [Parameter(ParameterSetName='FE', Mandatory=$true)]	[switch]    $FipsEnable,
        [Parameter(ParameterSetName='FD', Mandatory=$true)]	[switch]    $FipsDisable,
        [Parameter(ParameterSetName='FR', Mandatory=$true)]	[switch]    $FipsRestart,
        [Parameter(ParameterSetName='SG', Mandatory=$true)]	[switch]    $SSHKeysGenerate,
        [Parameter(ParameterSetName='SS', Mandatory=$true)]	[switch]    $SSHKeysSync,
        [Parameter()]   			 						[switch]    $F
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process 
{	$Cmd = " controlsecurity "
    if ($FipsEnable) {    $Cmd += " fips enable "    }
    if ($FipsDisable) {    $Cmd += " fips disable "    }
    if ($FipsRestart) {    $Cmd += " fips restart "    }
    if ($SSHKeysGenerate) {    $Cmd += " ssh-keys generate "    }
    if ($SSHKeysSync) {    $Cmd += " ssh-keys sync "    } 
	if ($F) {    $Cmd += " -f "    } 
    $Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9Security
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
param( 	[Parameter(Mandatory=$true)]   [switch]    $FipsStatus
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " controlsecurity "
    if ($FipsStatus) {    $Cmd += " fips status "    } 
    $Result = Invoke-A9CLICommand -cmds  $Cmd
    Return $Result
}
}

# SIG # Begin signature block
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBh0pNNUGjA
# sp9mOeFFQHwM8bgHz2ab1+yiCZg+QnbYBTj4Lg1jj4t7m9vVrpR7QpnUqmyJsArQ
# rFmmMey++dwioIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQLnC1SLMdTj31DIKq8wKgInQa3k9wZPkQtFEpcCeHSxYyBZD7iqOoXhX
# JcB2uiihaI3/o91hl4SNmGedjBo+SgYwDQYJKoZIhvcNAQEBBQAEggGAHVnRpP5U
# AwXCYe3mStayo+PsFDRhvgHnS3R1vZZrkOC71cNgIWNGSKmJ7yLCJqyfas2I/iQz
# 5Ae7iAsBu6OQrsdthVJ2A7uHz3jR2PP5gNG6TVmxRtlu0LCLKebbDT3dyeayTrVP
# yrYk2oh6gu8bIIu8zdvPHgJZMHASRIVHIL8EBPusTOdYZYkT/F6Qjw0yBCYc10kc
# JLScOEm+PPAfBENsq9s3q4yZZhooTJYqXpBHKHj5+vjoPzmQIkjgzY12yftzdeT6
# nIAAFBhXndA6VkNQtfB2igaXr0GUrzDYOfiBySDIne2QyXE9KjQ1ZptycFF/AcUO
# CyhDs4IM0d2Mdfd5szSmmk+sJ4GS1jaJhcQnXwuP+oOJm9FlUMshbin4ulOoZALZ
# 7DkSJxKB3hj78P/gExlkcuIUTHgE5PWz5fpHMmcgH9naAsgUMYzyzd4SJnYCGkea
# /qqh9Z+xPE2bnS8KNxwtmJCaJFlni7hg5HQ2nQVMgxYt60enas5bZaBPoYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMIBZCf5UhK0pqYRX0iKAo7wE1KTMBNmo
# NDdbxmG+D0ZKPxwXgq1gQKZZX678HvHVOgIUdQMRTq268SAeMsRKhOZ9ATaBttMY
# DzIwMjQwNzMxMTkyNTMwWqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
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
# NzMxMTkyNTMwWjA/BgkqhkiG9w0BCQQxMgQwjUFkU7zmL4Uj5lH5IFxHufMWjg6x
# rc4DXDNcwAPtZl01vFYo9Qib1eSm9/+P4z8DMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgB5B8u4
# tXZd7gsgA/iD0/1LycFwW1v4PDcjQLgh2E+LJESC76coSLyPDRdPoc8dr3istqEl
# 0Z0VHkSyjA0qljKVpBrHEJRVK9oOXj4aGoClk1LTxQq7xnAeTwlCxf69RPWqKBXT
# VvpJYbEaVmKjhrJOrx31T/OkEuPiFnoYsOaT3IQtSrZo1LwWt+doIBs4GjpWP9Zg
# xAjN4rLDSL0UFrzyGStg5DaNxd57Z4LxRZZJvDZThXL/PfDeXticN17+UuKvZbtg
# HdBOrtf6qnEzuIZz/F0sJu6vHM44NtI5M2/PmMTBxNG3Jx3Vpda4sTjWtN0gEYcH
# vSkcKu2UFm11pKicmuQ1DEGkzZqC3T6VNf5ob/0hQD+nZK1p5Xzz0GgnesCHZK+3
# kF7mQyLWDA/71v8TwjDZ3orBup42KOoSUKQdE+zRFsd1WuMY329VnSjlZSgvtyr0
# 6x/Xi8cW0ntZ8lyfR3THOXVlTNDISsRlds9LCk2/3+442qv95QZHWIBeB7PBIs2B
# ctFks4vp1YmEoTZhHwFrpxDqcqEO4JV7FIyniDs6iXvvhC4gc3GhGygfFOS7aeu5
# JLqtiGYPvb9LfWiKVKd55VW/T2MM1gwI+iNxULN5TOP46FU0/IFYH/D7mfLBDTXj
# 6hfJNNKvEOlub9Eok1bIbstuiIn54F2SqvWVGw==
# SIG # End signature block
