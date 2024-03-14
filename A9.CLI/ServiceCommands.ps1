####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Add-A9Hardware_CLI
{
<#
.SYNOPSIS
	Add-Hardware - Admit new hardware into the system.
.DESCRIPTION
	The Add-Hardware command admits new hardware into the system. If new disks are discovered on any two-node HPE StoreServ system, tunesys will be
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
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SystemPatch_CLI
{
<#
.SYNOPSIS
	Get-SystemPatch - Show what patches have been applied to the system.
.DESCRIPTION
	The Get-SystemPatch command displays patches applied to a system.
.EXAMPLE
	Get-SystemPatch
.EXAMPLE
	Get-SystemPatch -Hist
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
{	Test-A9CLIConnection
}
Process
{	$Cmd = " showpatch "
	if($Hist)	{	$Cmd += " -hist " }
	if($D) 		{	$Cmd += " -d " 	}
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9Version__CLI 
{	
<#
.SYNOPSIS
    Get list of Storage system software version information 
.DESCRIPTION
    Get list of Storage system software version information
.EXAMPLE
    Get-A9Version_CLI	

	Get list of Storage system software version information
.EXAMPLE
    Get-Version -S	

	Get list of Storage system release version number only
.EXAMPLE
    Get-Version -B	

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
{	Test-A9CLIConnection
}
Process
{	$Cmd = "showversion"
    if ($A) {    $Cmd += " -a"    }
    if ($B) {    $Cmd += " -b"    }
    if ($S) {    $Cmd += " -s"    }
	$Result = Invoke-CLICommand -cmds  $Cmd
    return $Result
}
}

Function Update-A9Cage_CLI
{
<#
.SYNOPSIS
	Update-Cage - Upgrade firmware for the specified cage.
.DESCRIPTION
	The Update-Cage command downloads new firmware into the specified cage.
.PARAMETER A
	All drive cages are upgraded one at a time.
.PARAMETER Parallel
	All drive cages are upgraded in parallel by interface card domain. If -wait is specified, the command will not return until the upgrades
	are completed. Otherwise, the command returns immediately and completion of the upgrade can be monitored with the -status option.
.PARAMETER Status
	Print status of the current Update-Cage operation in progress or the last executed Update-Cage operation. If any cagenames are specified, result
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
{	Test-A9CLIConnection
}
Process 
{	$Cmd = " upgradecage "
	if($A) 			{	$Cmd += " -a " }
	if($Parallel)	{	$Cmd += " -parallel "
						if($Wait)		{	$Cmd += " -wait " }
					}
	if($Status)		{	$Cmd += " -status " }
	if($Cagename)	{	$Cmd += " $Cagename " }
	$Result = Invoke-CLICommand -cmds  $Cmd
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

Function Reset-A9SystemNode_CLI
{
<#
.SYNOPSIS
	Reset-SystemNode - Halts or reboots a system node.
.DESCRIPTION
	The Reset-SystemNode command shuts down a system node.
.EXAMPLE
	Reset-SystemNode -Halt -Node_ID 0.
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
{	Test-A9CLIConnection
}
Process
{	$Cmd = " shutdownnode "
	if($Halt)		{	$Cmd += " halt " }
	Elseif($Reboot)	{	$Cmd += " reboot " }
	Elseif($Check)	{	$Cmd += " check " }
	Elseif($Restart){	$Cmd += " restart " }
	if($Node_ID)	{	$Cmd += " Node_ID " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Set-A9Magazines_CLI
{
<#
.SYNOPSIS
	Set-Magazines - Take magazines or disks on or off loop.
.DESCRIPTION
	The Set-Magazines command takes drive magazines, or disk drives within a magazine, either on-loop or off-loop. Use this command when replacing a
	drive magazine or disk drive within a drive magazine.
.EXAMPLE
	Set-Magazines -Offloop -Cage_name "xxx" -Magazine "xxx"
.EXAMPLE
	Set-Magazines -Offloop -Port "Both" -Cage_name "xxx" -Magazine "xxx"
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
{	Test-A9CLIConnection
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
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Set-A9ServiceCage_CLI
{
<#
.SYNOPSIS
	Set-ServiceCage - Service a cage.
.DESCRIPTION
	The Set-ServiceCage command is necessary when executing removal and replacement actions for a drive cage interface card or power cooling module. The
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
{	Test-A9CLIConnection
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
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Set-A9ServiceNodes_CLI
{
<#
.SYNOPSIS
	Set-ServiceNodes - Prepare a node for service.
.DESCRIPTION
	The Set-ServiceNodes command informs the system that a certain component will be replaced, and will cause the system to indicate the physical location of that component.
.EXAMPLE
	Set-ServiceNodes -Start -Nodeid 0
.EXAMPLE
	Set-ServiceNodes -Start -Pci 3 -Nodeid 0
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
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$True)] 	[String] 	$Nodeid,
		[Parameter(ParameterSetName='Start', Mandatory=$true)]	[switch]	$Start,
		[Parameter(ParameterSetName='Satus', Mandatory=$true)]	[switch]	$Status,
		[Parameter(ParameterSetName='end',   Mandatory=$true)]	[switch]	$End,
		[Parameter()]					[String]	$Ps,
		[Parameter()]					[String]	$Pci,
		[Parameter()]					[String]	$Fan,
		[Parameter()]					[switch]	$Bat
)
Begin
{	Test-A9CLIConnection
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
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Reset-A9System_CLI
{
<#
.SYNOPSIS
	Reset-System - Halts or reboots the entire system.
.DESCRIPTION
	The Reset-System command shuts down an entire system.
.EXAMPLE
	Reset-System -Halt.
.PARAMETER Halt
	Specifies that the system should be halted after shutdown. If this subcommand is not specified, the reboot or restart subcommand must be used.
.PARAMETER Reboot
	Specifies that the system should be restarted after shutdown. If this subcommand is not given, the halt or restart subcommand must be used.
.PARAMETER Restart
	Specifies that the storage services should be restarted. If this subcommand is not given, the halt or reboot subcommand must be used.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Halt',   Mandatory=$true)]	[switch]	$Halt,
		[Parameter(ParameterSetName='Reboot', Mandatory=$true)]	[switch]	$Reboot,
		[Parameter(ParameterSetName='Restart',Mandatory=$true)]	[switch]	$Restart
)
Begin
{	Test-A9CLIConnection
}
Process
{	$Cmd = " shutdownsys "
	if($Halt)		{	$Cmd += " halt " }
	Elseif($Reboot)	{	$Cmd += " reboot " }
	Elseif($Restart){	$Cmd += " restart " }
	else			{	Return "Select at least one from [Halt | Reboot | Restart ]" }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Update-A9PdFirmware_CLI
{
<#
.SYNOPSIS
	Update-PdFirmware - Upgrade physical disk firmware.
.DESCRIPTION
	The Update-PdFirmware command upgrades the physical disk firmware.
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
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$F,
		[Parameter()]	[switch]	$Skiptest,
		[Parameter()]	[switch]	$A,
		[Parameter()]	[String]	$W,
		[Parameter()]	[String]	$PD_ID
)
Begin
{	Test-A9CLIConnection
}
Process
{	$Cmd = " upgradepd "
	if($F)			{	$Cmd += " -f " } 
	if($Skiptest)	{	$Cmd += " -skiptest " } 
	if($A)			{	$Cmd += " -a " } 
	if($W)			{	$Cmd += " -w $W " } 
	if($PD_ID) 		{	$Cmd += " $PD_ID " } 
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Search-A9ServiceNode_CLI
{
<#
.SYNOPSIS
	Search-ServiceNode - Prepare a node for service.
.DESCRIPTION
	The Search-ServiceNode command informs the system that a certain component will be replaced, and will cause the system to indicate the physical location of that component.
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
{	Test-A9CLIConnection
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
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9ResetReason_CLI 
{
<#
.SYNOPSIS
	The Get-ResetReason cmdlet displays component reset reason details.
.DESCRIPTION
	The showreset command displays component reset reason details.
.PARAMETER D
	Specifies that more detailed information about the system is displayed.
.PARAMETER SANConnection 
	Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection  
.EXAMPLE
	To display reset reason in table format:

	Get-ResetReason
.EXAMPLE
	To display reset reason in more detail (-d option):
	
	Get-ResetReason -d
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$D
)
Begin
{	Test-A9CLIConnection
}
Process
{	$Cmd = " showreset "
	if ($D) {    $Cmd += " -d "   }
    $Result = Invoke-CLICommand -cmds  $Cmd
    $Result 
}
}

Function Set-A9Security_CLI
{
<#
.SYNOPSIS
	Set-Security - Control security parameters.
.DESCRIPTION
	The Set-Security cmdlet controls security parameters of the system
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

    Set-Security fips enable

    Warning: Enabling FIPS mode requires restarting all system management interfaces,  which will terminate ALL existing connections including this one.
    When that happens, you must reconnect to continue.
	Continue enabling FIPS mode (yes/no)?
.EXAMPLE
    Disables fips mode

    Set-Security fips disable

    Warning: Disabling FIPS mode requires restarting all system management interfaces,
    which will terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue disabling FIPS mode (yes/no)?
.EXAMPLE
    Restarts services which are not currently enabled
    
    Set-Security fips restart
    
    Warning: Will restart all services that are not enabled, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue restarting (yes/no)?
.EXAMPLE
    Regenerates the SSH host keys and distributes them to the other nodes

    Set-Security ssh-keys generate

    Warning: This action will restart the ssh service, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue restarting (yes/no)?
.EXAMPLE
    Syncs the SSH host keys from the current node to all other nodes

    Set-Security ssh-keys sync

    Warning: This action will restart the ssh service, which may terminate ALL existing connections including this one. When that happens, you must reconnect to continue.
    Continue restarting (yes/no)?
#>
[CmdletBinding()]
param(  [Parameter()]    [switch]    $FipsEnable,
        [Parameter()]    [switch]    $FipsDisable,
        [Parameter()]    [switch]    $FipsRestart,
        [Parameter()]    [switch]    $SSHKeysGenerate,
        [Parameter()]    [switch]    $SSHKeysSync,
        [Parameter()]    [switch]    $F
)
Begin
{	Test-A9CLIConnection
}
Process 
{	$Cmd = " controlsecurity "
    if ($FipsEnable) {    $Cmd += " fips enable "    }
    Elseif ($FipsDisable) {    $Cmd += " fips disable "    }
    Elseif ($FipsRestart) {    $Cmd += " fips restart "    }
    Elseif ($SSHKeysGenerate) {    $Cmd += " ssh-keys generate "    }
    Elseif ($SSHKeysSync) {    $Cmd += " ssh-keys sync "    } 
    else {    Return "Select one option from [ Fips Enable | Fips Disable | Fips Restart | SSHKeys Generate | SSHKeys Sync ] and proceed."    }
	if ($F) {    $Cmd += " -f "    } 
    $Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9Security_CLI
{    
<#
.SYNOPSIS
	Get-Security - Show Control security parameters.
.DESCRIPTION
	The Get-Security cmdlet shows the status of security parameters of system management interfaces.
.PARAMETER FipsStatus
	Shows the status of security parameters of system management interfaces.
.EXAMPLE
    Shows the current mode of FIPS and status of services

    Get-Security fips status

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
#>
[CmdletBinding()]
param( 	[Parameter()]   [switch]    $FipsStatus
)
Begin
{	Test-A9CLIConnection
}
Process
{	$Cmd = " controlsecurity "
    if ($FipsStatus) {    $Cmd += " fips status "    } 
    else {    Return "Select Fips Status and proceed."    }
	$Result = Invoke-CLICommand -cmds  $Cmd
    Return $Result
}
}
