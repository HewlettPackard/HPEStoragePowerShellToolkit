####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Add-A9RCopyTarget_CLI
{
<#
.SYNOPSIS
    The command adds a target to a remote-copy volume group.
.DESCRIPTION
    The command adds a target to a remote-copy volume group.
.EXAMPLE
	PS:> Add-A9RCopyTarget_CLI -Target_name XYZ -Mode sync -Group_name test

	This example admits physical disks.
.PARAMETER Target_name 
	Specifies the name of the target that was previously created with the creatercopytarget command.
.PARAMETER Mode 
	Specifies the mode of the target as either synchronous (sync), asynchronous periodic (periodic), or asynchronous streaming (async).
.PARAMETER Group_name 
    Specifies the name of the existing remote copy volume group created with the creatercopygroup command to which the target will be added.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$Target_name,
		[Parameter(Mandatory=$true)][ValidateSet('sync','periodic','asymc')]
										[String]	$Mode,
		[Parameter(Mandatory=$true)]	[String]	$Group_name
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "admitrcopytarget "
	if ($Target_name)	{	$cmd+=" $Target_name "	}
	if ($Mode)			{	$cmd+=" $Mode "			}
	if ($Group_name)	{	$cmd+=" $Group_name "	}
	$Result = Invoke-CLICommand -cmds  $cmd	
	return 	$Result	
} 
}

Function Add-A9RCopyVv_CLI
{
<#
.SYNOPSIS
    The command adds an existing virtual volume to an existing remote copy volume group.
.DESCRIPTION
	The command adds an existing virtual volume to an existing remote copy volume group.
.EXAMPLE	
    PS:> Add-A9RCopyVv_CLI -SourceVolumeName XXXX -Group_name ZZZZ -Target_name TestTarget -TargetVolumeName YYYY
.EXAMPLE
    PS:> Add-A9RCopyVv_CLI -SourceVolumeName XXXX -Snapname snp -Group_name ZZZZ -Target_name TestTarget -TargetVolumeName YYYY
.EXAMPLE
    PS:> Add-A9RCopyVv_CLI -SourceVolumeName XXXX -Snapname snp -Group_name AS_TEST -Target_name CHIMERA03 -TargetVolumeName YYYY
.EXAMPLE
    PS:> Add-A9RCopyVv_CLI -Pat -SourceVolumeName XXXX -Group_name ZZZZ -Target_name TestTarget -TargetVolumeName YYYY
.EXAMPLE	
	PS:> Add-A9RCopyVv_CLI -CreateVV -SourceVolumeName XXXX -Group_name ZZZZ -Target_name TestTarget -TargetVolumeName YYYY
.EXAMPLE
	PS:> Add-A9RCopyVv_CLI -NoWWN -SourceVolumeName XXXX -Group_name ZZZZ -Target_name TestTarget -TargetVolumeName YYYY
.PARAMETER Pat
	Specifies that the <VV_name> is treated as a glob-style pattern and that all remote copy volumes matching the specified pattern are admitted to the
	remote copy group. When this option is used the <sec_VV_name> and <snapname> (if specified) are also treated as patterns. It is required
	that the secondary volume names and snapshot names can be derived from the local volume name by adding a prefix, suffix or both. <snapname> and
	<sec_VV_name> should take the form prefix@vvname@suffix, where @vvname@ resolves to the name of each volume that matches the <VV_name> pattern.
.PARAMETER CreateVV
	Specifies that the secondary volumes should be created automatically. This specifier cannot be used when starting snapshots (<VV_name>:<snapname>) are specified.
.PARAMETER NoWWN
	When used with -createvv, it ensures a different WWN is	used on the secondary volume. Without this option -createvv will use the same WWN for both primary and secondary volumes.
.PARAMETER NoSync
	Specifies that the volume should skip the initial sync. This is for the admission of volumes that have been pre-synced with the target volume.
	This specifier cannot be used when starting snapshots (<VV_name>:<snapname>) are specified.
.PARAMETER SourceVolumeName
	Specifies the name of the existing virtual volume to be admitted to an existing remote copy volume group that was created with the creatercopygroup command.
.PARAMETER Snapname
	An optional read-only snapshot <snapname> can be specified along with the virtual volume name <VV_name>.
.PARAMETER Group_name
	Specifies the name of the existing remote copy volume group created with the creatercopygroup command, to which the volume will be added.
.PARAMETER Target_name
	The target name associated with this group, as set with the creatercopygroup command. The target is created with the creatercopytarget command.
.PARAMETER TargetVolumeName
	The target name associated with this group, as set with the creatercopygroup command. The target is created with the creatercopytarget command. 
	<sec_VV_name> specifies the name of the secondary volume on the target system.  One <target_name>:<sec_VV_name> must be specified for each target of the group.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Pat,
		[Parameter()]	[switch]	$CreateVV,
		[Parameter()]	[switch]	$NoWWN,
		[Parameter()]	[switch]	$NoSync,
		[Parameter(Mandatory=$true)]	[String]	$SourceVolumeName,
		[Parameter()]					[String]	$Snapname,
		[Parameter(Mandatory=$true)]	[String]	$Group_name,
		[Parameter(Mandatory=$true)]	[String]	$Target_name,
		[Parameter(Mandatory=$true)]	[String]	$TargetVolumeName
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "admitrcopyvv "
	if ($Pat)			{	$cmd+=" -pat "}
	if ($CreateVV)		{	$cmd+=" -createvv "	}
	if ($NoWWN)			{	$cmd+=" -nowwn "}
	if ($NoSync)		{	$cmd+=" -nosync "}
	$cmd+=" $SourceVolumeName"	
	if ($Snapname)		{	$cmd+=":$Snapname "	}
	$cmd+=" $Group_name "		
	$cmd+=" $Target_name"		
	$cmd+=":$TargetVolumeName "		
	$Result = Invoke-CLICommand -cmds  $cmd
	write-verbose " The Add-RCopyVv command creates and admits physical disk definitions to enable the use of those disks  " 
	return 	$Result	
}
}

Function Add-A9RCopyLink_CLI
{
<#
.SYNOPSIS
    The command adds one or more links (connections) to a remote-copy target system.
.DESCRIPTION
    The command adds one or more links (connections) to a remote-copy target system.  
.EXAMPLE
	PS:> Add-A9RCopyLink_CLI  -TargetName demo1 -N_S_P_IP 1:2:1:193.1.2.11
	
	This Example adds a link on System2 using the node, slot, and port information of node 1, slot 2, port 1 of the Ethernet port on the primary system. The IP address 193.1.2.11 specifies the address on the target system:
.EXAMPLE
	PS:> Add-A9RCopyLink_CLI -TargetName System2 -N_S_P_WWN 5:3:2:1122112211221122
	
	This Example WWN creates an RCFC link to target System2, which connects to the local 5:3:2 (N:S:P) in the target system.
.PARAMETER TargetName 
    Specify name of the TargetName to be updated.
.PARAMETER N_S_P_IP
	Node number:Slot number:Port Number:IP Address of the Target to be created.
.PARAMETER N_S_P_WWN
	Node number:Slot number:Port Number:World Wide Name (WWN) address on the target system.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]						[String]	$TargetName,
		[Parameter(ParameterSetName='ip', Mandatory=$true)]	[String]	$N_S_P_IP,
		[Parameter(ParameterSetName='wwn',Mandatory=$true)]	[String]	$N_S_P_WWN
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = "admitrcopylink "
	if ($TargetName)	{	$cmd += "$TargetName "	}
	if ($N_S_P_IP)		{	$s = $N_S_P_IP			}
	if ($N_S_P_WWN)		{	$s = $N_S_P_WWN			}
	$s= [regex]::Replace($s,","," ")
	$cmd+="$s"
	$Result = Invoke-CLICommand -cmds  $cmd
	return $Result	
}
}

Function Disable-A9RCopylink_CLI
{
<#
.SYNOPSIS
    The Disable-RCopylink command removes one or more links (connections) created with the admitrcopylink command to a target system.
.DESCRIPTION
    The Disable-RCopylink command removes one or more links (connections) created with the admitrcopylink command to a target system.
.EXAMPLE
	Disable-RCopylink -RCIP -Target_name test -NSP_IP_address 1.1.1.1
.EXAMPLE
	Disable-RCopylink -RCFC -Target_name test -NSP_WWN 1245
.PARAMETER RCIP  
	Syntax for remote copy over IP (RCIP)
.PARAMETER RCFC
	Syntax for remote copy over FC (RCFC)
.PARAMETER Target_name	
	The target name, as specified with the creatercopytarget command.
.PARAMETER NSP_IP_address		
	Specifies the node, slot, and port of the Ethernet port on the local system and an IP address of the peer port on the target system.
.PARAMETER NSP_WWN
	Specifies the node, slot, and port of the Fibre Channel port on the local system and World Wide Name (WWN) of the peer port on the target system.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[Switch]	$RCIP,
		[Parameter()]	[Switch]	$RCFC,
		[Parameter()]	[String]	$Target_name,
		[Parameter()]	[String]	$NSP_IP_address,
		[Parameter()]	[String]	$NSP_WWN
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "dismissrcopylink "
	if($RCFC -or $RCIP)
		{	if($RCFC)
				{	if($RCIP)	{	return "Please select only one RCFC -or RCIP"	}
					else
						{	if ($Target_name)		{	$cmd+=" $Target_name "		}	
							else					{	return " FAILURE :  Target_name is mandatory to execute  "	}
							if ($NSP_IP_address)	{	$cmd+=" $NSP_IP_address "	}	
							else					{	return " FAILURE :  NSP_IP_address is mandatory to execute  "	}
						}
				}
			if($RCIP)
				{	if($RCFC)	{	return "Please select only one RCFC -or RCIP"	}
					else
						{	if ($Target_name)	{	$cmd+=" $Target_name "	}	
							else				{	return " FAILURE :  Target_name is mandatory for to execute  "	}
							if ($NSP_WWN)		{	$cmd+=" $NSP_WWN "		}	
							else				{	return " FAILURE :  NSP_WWN is mandatory for to execute  "	}
						}
				}
		}
	else
		{	return "Please Select at-list any one from RCFC -or RCIP to execute this command"
		}
	$Result = Invoke-CLICommand -cmds  $cmd
	write-verbose " The command creates and admits physical disk definitions to enable the use of those disks  " 
	return 	$Result	
}
}

Function Disable-A9RCopyTarget_CLI
{
<#
.SYNOPSIS
    The Disable-RCopyTarget command removes a remote copy target from a remote copy volume group.
.DESCRIPTION
    The Disable-RCopyTarget command removes a remote copy target from a remote copy volume group.
.EXAMPLE
	PS:> Disable-A9RCopyTarget_CLI -Target_name Test -Group_name Test2
.PARAMETER Target_name	
	The name of the target to be removed.
.PARAMETER Group_name		
	The name of the group that currently includes the target.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Target_name,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Group_name
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "dismissrcopytarget -f "
	if ($Target_name)	{	$cmd+=" $Target_name "	}	
	else				{	return " FAILURE :  Target_name is mandatory for to execute  "	}
	if ($Group_name)	{	$cmd+=" $Group_name "		}	
	else				{	return " FAILURE :  Group_name is mandatory for to execute  "	}
	$Result = Invoke-CLICommand -cmds  $cmd
	write-verbose " The command creates and admits physical disk definitions to enable the use of those disks  " 
	return 	$Result	
}
}

Function Disable-A9RCopyVv_CLI
{
<#
.SYNOPSIS
    The Disable-RCopyVv command removes a virtual volume from a remote copy volume group.
.DESCRIPTION
    The Disable-RCopyVv command removes a virtual volume from a remote copy volume group.
.EXAMPLE
	PS:> Disable-A9RCopyVv_CLI -VV_name XYZ -Group_name XYZ
.EXAMPLE
	PS:> Disable-A9RCopyVv_CLI -Pat -VV_name XYZ -Group_name XYZ
.EXAMPLE
	PS:> Disable-A9RCopyVv_CLI -KeepSnap -VV_name XYZ -Group_name XYZ
.EXAMPLE
	PS:> Disable-A9RCopyVv_CLI -RemoveVV -VV_name XYZ -Group_name XYZ
.PARAMETER Pat
	Specifies that specified patterns are treated as glob-style patterns and all remote copy volumes matching the specified pattern will be
	dismissed from the remote copy group. This option must be used if the <pattern> specifier is used.
.PARAMETER KeepSnap
	Specifies that the local volume's resync snapshot should be retained. The retained snapshot will reflect the state of the secondary volume
	and might be used as the starting snapshot if the volume is readmitted to a remote copy group. The snapshot name will begin with "sv.rcpy"
.PARAMETER RemoveVV
	Remove remote sides' volumes.
.PARAMETER VV_name	
	The name of the volume to be removed. Volumes are added to a group with the admitrcopyvv command.
.PARAMETER Group_name		
	The name of the group that currently includes the target.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Pat,
		[Parameter()]	[switch]	$KeepSnap,
		[Parameter()]	[switch]	$RemoveVV,
		[Parameter(Mandatory=$true)]	[String]	$VV_name,
		[Parameter(Mandatory=$true)]	[String]	$Group_name
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "dismissrcopyvv -f "
	if($Pat)		{	$cmd+=" -pat "	}
	if($KeepSnap)	{	$cmd+=" -keepsnap "	}
	if($RemoveVV)	{	$cmd+=" -removevv "	}
	$cmd+=" $VV_name "	
	$cmd+=" $Group_name "	
	$Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
}	
}

Function Get-A9RCopy_CLI
{
<#
.SYNOPSIS
	The command displays details of the remote-copy configuration.
.DESCRIPTION
    The command displays details of the remote-copy configuration.
.EXAMPLE
	PS:> Get-A9RCopy_CLI -Detailed -Links

	This Example displays details of the remote-copy configuration and Specifies all remote-copy links.   
.EXAMPLE  	
	PS:> Get-A9RCopy_CLI -Detailed -Domain PSTest -Targets Demovv1

	This Example displays details of the remote-copy configuration which Specifies either all target definitions
.PARAMETER Detailed
	Displays more detailed configuration information.
.PARAMETER QW
	Displays additional target specific automatic transparent failover-related configuration, where applicable.
.PARAMETER Domain
	Shows only remote-copy links whose virtual volumes are in domains with names that match one or more of the specified domain name or pattern.
.PARAMETER Links
	Specifies all remote-copy links.
.PARAMETER Groups 
	Specifies either all remote-copy volume groups or a specific remote-copy volume group by name or by glob-style pattern.
.PARAMETER Targets
	Specifies either all target definitions or a specific target definition by name or by glob-style pattern.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$Detailed,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$QW,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Domain,
		[Parameter()]							[switch]	$Links,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groups,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Targets
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "showrcopy "	
	if ($Detailed)	{	$cmd += " -d "				}
	if ($QW)		{	$cmd += " -qw "				}
	if ($Domain)	{	$cmd += " -domain $Domain "	}
	if ($Links)		{	$cmd += " links "			}		
	if ($Groups)	{	$cmd+="groups $Groups "		}	
	if ($Targets)	{	$cmd+="targets $Targets "	}
	$Result = Invoke-CLICommand -cmds  $cmd
	return $Result
}
}

Function Get-A9StatRCopy_CLI
{
<#
.SYNOPSIS
	The command displays statistics for remote-copy volume groups.
.DESCRIPTION
    The command displays statistics for remote-copy volume groups.
.EXAMPLE
	PS:> Get-A9StatRCopy_CLI -HeartBeat -Iteration 1

	This example shows statistics for sending links ,Specifies that the heartbeat round-trip time.
.EXAMPLE  
	PS:> Get-A9StatRCopy_CLI -Iteration 1

	This example shows statistics for sending links link0 and link1.
.EXAMPLE  
	PS:> Get-A9StatRCopy_CLI -HeartBeat -Unit k -Iteration 1

	This example shows statistics for sending links ,Specifies that the heartbeat round-trip time & displays statistics as kilobytes	
.PARAMETER HeartBeat  
	Specifies that the heartbeat round-trip time of the links should be displayed in addition to the link throughput.
.PARAMETER Unit
	Displays statistics as kilobytes (k), megabytes (m), or gigabytes (g). If no unit is specified, the default is kilobytes.
.PARAMETER Iteration 
	Specifies that I/O statistics are displayed a specified number of times as indicated by the num argument using an integer from 1 through 2147483647.
.PARAMETER Interval
	Specifies the interval, in seconds, that statistics are sampled using an integer from 1 through 2147483647. If no interval is specified, the option
	defaults to an interval of two seconds.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()][ValidateRange(1,2147483647)]	[Int]		$Interval,
		[Parameter()]								[switch]	$HeartBeat,
		[Parameter()][ValidateSet('k','m','g')]		[String]	$Unit,
		[Parameter()][ValidateRange(1,2147483647)]	[Int]		$Iteration
)	
Begin
{	Test-A9Connection -ClientType SshClient
}
Process
{	$cmd= "statrcopy "	
	if ($Iteration)	{	$cmd += " -iter $Iteration "	}	
	else			{	return "Error :  -Iteration is mandatory. "		}
	if ($Interval )	{	$cmd+= "-d $Interval "	}
	if ($HeartBeat ){	$cmd+= "-hb "	}
	if ($Unit)		{	$cmd+=" -u $Unit  "	}
	$Result = Invoke-CLICommand -cmds  $cmd	
	return  $Result
}
}

Function Remove-A9RCopyGroup_CLI
{
<#
.SYNOPSIS
	The command removes a remote-copy volume group or multiple remote-copy groups that match a given pattern.
.DESCRIPTION
    The command removes a remote-copy volume group or multiple remote-copy groups that match a given pattern.	
.EXAMPLE  
	PS:> Remove-A9RCopyGroup_CLI -Pat -GroupName testgroup*	

	This example Removes remote-copy groups that start with the name testgroup	
.EXAMPLE  
	PS:> Remove-A9RCopyGroup_CLI -KeepSnap -GroupName group1	

	This example Removes the remote-copy group (group1) and retains the resync snapshots associated with each volume
.PARAMETER Pat
	Specifies that specified patterns are treated as glob-style patterns and that all remote-copy groups matching the specified pattern will be removed.
.PARAMETER KeepSnap
	Specifies that the local volume's resync snapshot should be retained.
.PARAMETER RemoveVV
	Remove remote sides' volumes.	
.PARAMETER GroupName      
	The name of the group that currently includes the target.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]					[switch]	$RemoveVV,
		[Parameter()]					[switch]	$KeepSnap,
		[Parameter()]					[switch]	$Pat,
		[Parameter(Mandatory=$true)]	[String]	$GroupName		
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "removercopygroup -f "	
	if ($RemoveVV)	{	$cmd+=" -removevv "	}	
	if ($KeepSnap)	{	$cmd+=" -keepsnap "	}
	if ($Pat)		{	$cmd+=" -pat "	}
	if ($GroupName)
		{	$cmd1= "showrcopy"
			$Result1 = Invoke-CLICommand -cmds  $cmd1
			if ($Result1 -match $GroupName ){	$cmd+=" $GroupName "	}
			else							{	Return "FAILURE : -GroupName $GroupName  is Unavailable . "	}		
		}		
	$Result = Invoke-CLICommand -cmds  $cmd	
	if($Result -match "deleted")	{	return  "Success : Command `n $Result  "	}
	else							{	return  "FAILURE : While Executing $Result "	} 	
}
}

Function Remove-A9RCopyTarget_CLI
{
<#
.SYNOPSIS
	The command command removes target designation from a remote-copy system and removes all links affiliated with that target definition.   
.DESCRIPTION
	The command command removes target designation from a remote-copy system and removes all links affiliated with that target definition.   
.EXAMPLE  
	PS:> Remove-A9RCopyTarget_CLI -ClearGroups -TargetName demovv1

	This Example removes target designation from a remote-copy system & Remove all groups.
.PARAMETER ClearGroups
	Remove all groups that have no other targets or dismiss this target from groups with additional targets.
.PARAMETER TargetName      
	The name of the group that currently includes the target.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$ClearGroups,
		[Parameter(ValueFromPipeline=$true)]	[String]	$TargetName
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "removercopytarget -f "
	if ($ClearGroups)	{	$cmd+=" -cleargroups "	}		
	if ($TargetName)	{	$cmd+=" $TargetName "		}
	else				{	return "Error :  -TargetName is mandatory. "	}	
	$Result = Invoke-CLICommand -cmds  $cmd
	if([string]::IsNullOrEmpty($Result))	{	return  "Success :  "}
	else									{	return  "FAILURE : While Executing  $Result  "} 
}
}

Function Remove-A9RCopyTargetFromGroup_CLI
{
<#
.SYNOPSIS
	Removes a remote-copy target from a remote-copy volume group.
.DESCRIPTION
	Removes a remote-copy target from a remote-copy volume group.
.EXAMPLE
	PS:> Remove-A9RCopyTargetFromGroup_CLI -TargetName target1 -GroupName group1

	The following example removes target Target1 from Group1.
.PARAMETER TargetName     
	The name of the target to be removed.
.PARAMETER GroupName      
	The name of the group that currently includes the target.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$TargetName,
		[Parameter(Mandatory=$true)]	[String]	$GroupName
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "dismissrcopytarget -f "	
	$cmd+=" $TargetName "	
	$cmd1= "showrcopy"
	$Result1 = Invoke-CLICommand -cmds  $cmd1
	if ($Result1 -match $GroupName )	{	$cmd+=" $GroupName "	}
	else		{	Return "FAILURE : -GroupName $GroupName is Unavailable to execute. "	}
	$Result = Invoke-CLICommand -cmds  $cmd
	return  "$Result"
}
}

Function Set-A9RCopyGroupPeriod_CLI
{
<#
.SYNOPSIS
	Sets a resynchronization period for volume groups in asynchronous periodic mode.
.DESCRIPTION
	Sets a resynchronization period for volume groups in asynchronous periodic mode.   
.EXAMPLE
	PS:> Set-A9RCopyGroupPeriod_CLI -Period 10m -TargetName CHIMERA03 -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPeriod_CLI -Period 10m -Force -TargetName CHIMERA03 -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPeriod_CLI -Period 10m -T 1 -TargetName CHIMERA03 -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPeriod_CLI -Period 10m -Stopgroups -TargetName CHIMERA03 -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPeriod_CLI -Period 10m -Local -TargetName CHIMERA03 -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPeriod_CLI -Period 10m -Natural -TargetName CHIMERA03 -GroupName AS_TEST	
.PARAMETER PeriodValue
	Specifies the time period in units of seconds (s), minutes (m), hours (h), or days (d), for automatic resynchronization (for example, 14h for 14 hours).
.PARAMETER TargetName
	Specifies the target name for the target definition
.PARAMETER GroupName
	Specifies the name of the volume group whose policy is set, or whose target direction is switched.
.PARAMETER T
	When used with <dr_operation> subcommands, specifies the target to which the <dr_operation> command applies to.  This is optional for single
	target groups, but is required for multi-target groups. If no groups are specified, it applies to all relevant groups. When used with the pol subcommand,
	specified for a group with multiple targets then the command only applies to that target, otherwise it will be applied to all targets.

	NOTE: The -t option without the groups listed in the command, will only work in a unidirectional configuration. For bidirectional configurations, the -t
	option must be used along with the groups listed in the command.
.PARAMETER Force
	Does not ask for confirmation for disaster recovery commands.
.PARAMETER Nostart
	Specifies that groups are not started after role reversal is completed. This option can be used for failover, recover and restore subcommands.
.PARAMETER Nosync
	Specifies that groups are not synced after role reversal is completed through the recover, restore and failover specifiers.
.PARAMETER Discard
	Specifies not to check a group's other targets to see if newer data should be pushed from them if the group has multiple targets. The use
	of this option can result in the loss of the most recent changes to the group's volumes and should be used carefully. This option is only valid for the failover specifier.
.PARAMETER Nopromote
	This option is only valid for the failover and reverse specifiers.  When used with the reverse specifier, specifies that the synchronized snapshots
	of groups that are switched from primary to secondary not be promoted to the base volume. When used with the failover specifier, it indicates that
	snapshots of groups that are switched from secondary to primary should not be promoted to the base volume in the case where all volumes of the group
	were not synchronized to the same time point. The incorrect use of this option can lead to the primary secondary volumes not being consistent.
.PARAMETER Nosnap
	Specifies that snapshots are not taken of groups that are switched from secondary to primary. Additionally, existing snapshots are deleted
	if groups are switched from primary to secondary. The use of this option may result in a full synchronization of the secondary volumes. This
	option can be used for failover, restore, and reverse subcommands.
.PARAMETER Stopgroups
	Specifies that groups are stopped before running the reverse subcommand.
.PARAMETER Local
	The -local option only applies to the "reverse" operation and then only when the -natural or -current options to the "reverse" operation
	are specified. Specifying -local with the "reverse" operation and an associated -natural or -current option will only affect the array
	where the command is issued and will not be mirrored to any other arrays in the Remote Copy configuration.
.PARAMETER Natural
	Specifying the -natural option with the "reverse" operation changes the role of the groups but not the direction of data flow between the
	groups on the arrays. For example, if the role of the groups are "primary" and "secondary", issuing the -natural option with the
	"reverse" operation will result in the role of the groups becoming "primary-rev" and "secondary-rev" respectively. The direction of data
	flow between the groups is not affected only the roles. Since the -natural option does not change the direction of data flow between
	groups it does not require the groups be stopped.
.PARAMETER Current
	Specifying the -current option with the "reverse" operation changes both the role and the direction of data flow between the groups. For
	example, if the roles of the groups are "primary" and "secondary", issuing the -current option to the "reverse" operation will result in
	the roles of the group becoming "secondary-rev" and "primary-rev" respectively and the direction data flow between the groups is
	reversed. Since the -current option actually reverses the direction of data replication it requires the group be stopped.

	Both the -natural and -current options must be used with care to ensure the Remote Copy groups do not end up in a non-deterministic
	state (like "secondary", "secondary-rev" for example) and to ensure data loss does not occur by inadvertently changing the direction of
	data flow and re-syncing old data on top of newer data.
.PARAMETER Waittask
	Wait for all tasks created by this command to complete before returning. This option applies to the failover, recover, restore, and reverse subcommands.
.PARAMETER Pat
	Specifies that specified patterns are treated as glob-style patterns and all remote copy groups matching the specified pattern will be
	set. The -pat option can specify a list of patterns. This option must be used if <pattern> specifier is used.
.PARAMETER Usr_cpg 
	Specifies the local user CPG and target user CPG that will be used for volumes that are auto-created. The local CPG will only be used after failover and recover.
.PARAMETER Snp_cpg 
	Specifies the local snap CPG and target snap CPG that will be used for volumes that are auto-created. The local CPG will only be used after failover and recover.
.PARAMETER Usr_cpg_unset
	Unset all user CPGs that are associated with this group..PARAMETER Snp_cpg_unset Unset all snap CPGs that are associated with this group.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)][ValidateSet('s','m','h','d')]	
						[String]	$PeriodValue,
		[Parameter()]	[Switch]	$Force,
		[Parameter()]	[String]	$T,	
		[Parameter()]	[Switch]	$Nostart,
		[Parameter()]	[Switch]	$Nosync,
		[Parameter()]	[Switch]	$Discard,
		[Parameter()]	[Switch]	$Nopromote,
		[Parameter()]	[Switch]	$Nosnap,
		[Parameter()]	[Switch]	$Stopgroups,
		[Parameter()]	[Switch]	$Local,
		[Parameter()]	[Switch]	$Natural,
		[Parameter()]	[Switch]	$Current,
		[Parameter()]	[Switch]	$Waittask,
		[Parameter()]	[Switch]	$Pat,
		[Parameter()]	[String]	$Usr_cpg,
		[Parameter()]	[String]	$Snp_cpg,
		[Parameter()]	[Switch]	$Usr_cpg_unset,
		[Parameter()]	[Switch]	$Snp_cpg_unset,
		[Parameter(Mandatory=$true)]	[String]	$TargetName,
		[Parameter(Mandatory=$true)]	[String]	$GroupName
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd= "setrcopygroup period "
	if($Force)		{	$cmd+= " -f "	}
	if($T)			{	$cmd+= " -t $T "	}
	if($Nostart)	{	$cmd+= " -nostart "	}
	if($Nosync)		{	$cmd+= " -nosync "	}
	if($Discard)	{	$cmd+= " -discard "	}
	if($Nopromote)	{	$cmd+= " -nopromote "	}
	if($Nosnap)		{	$cmd+= " -nosnap "	}
	if($Stopgroups)	{	$cmd+= " -stopgroups "	}
	if($Local)		{	$cmd+= " -local "	}
	if($Natural)	{	$cmd+= " -natural "	}
	if($Current)	{	$cmd+= " -current "	}	
	if($Waittask)	{	$cmd+= " -waittask "}	
	if($Pat)		{	$cmd+= " -pat "	}
	if($Usr_cpg)	{	$cmd+= " -usr_cpg $Usr_cpg "}
	if($Snp_cpg)	{	$cmd+= " -snp_cpg $Snp_cpg "}	
	if($Usr_cpg_unset){	$cmd+= " -usr_cpg_unset "}
	if($Snp_cpg_unset){	$cmd+= " -snp_cpg_unset "}	
	if ($PeriodValue){	$cmd+=" $PeriodValue "	}
	$cmd+= " $TargetName "
	$cmd+= " $GroupName "
	$Result = Invoke-CLICommand -cmds  $cmd	
	write-verbose "  Executing Set-RCopyGroupPeriod using cmd   " 
	if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing Command "	}
	else									{	return  "FAILURE : While Executing   $Result"} 
}
}

Function Set-A9RCopyGroupPol_CLI
{
<#
.SYNOPSIS
    Sets the policy of the remote-copy volume group for dealing with I/O failure and error handling.
.DESCRIPTION
	Sets the policy of the remote-copy volume group for dealing with I/O failure and error handling.
.EXAMPLE	
	PS:> Set-A9RCopyGroupPol_CLI -policy test -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPol_CLI -policy auto_failover -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPol_CLI -Force -policy auto_failover -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPol_CLI -T 1 -policy auto_failover -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPol_CLI -Stopgroups -policy auto_failover -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPol_CLI -Local -policy auto_failover -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPol_CLI -Natural -policy auto_failover -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPol_CLI -policy no_auto_failover -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPol_CLI -Force -policy no_auto_failover -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroupPol_CLI -T 1 -policy no_auto_failover -GroupName AS_TEST
.PARAMETER T
	When used with <dr_operation> subcommands, specifies the target to which the <dr_operation> command applies to.  This is optional for single
	target groups, but is required for multi-target groups. If no groups are specified, it applies to all relevant groups. When used with the pol subcommand,
	specified for a group with multiple targets then the command only applies to that target, otherwise it will be applied to all targets.

	NOTE: The -t option without the groups listed in the command, will only work in a unidirectional configuration. For bidirectional configurations, the -t
	option must be used along with the groups listed in the command.
.PARAMETER Force
	Does not ask for confirmation for disaster recovery commands.
.PARAMETER Nostart
	Specifies that groups are not started after role reversal is completed. This option can be used for failover, recover and restore subcommands.
.PARAMETER Nosync
	Specifies that groups are not synced after role reversal is completed through the recover, restore and failover specifiers.
.PARAMETER Discard
	Specifies not to check a group's other targets to see if newer data should be pushed from them if the group has multiple targets. The use
	of this option can result in the loss of the most recent changes to the group's volumes and should be used carefully. This option is only
	valid for the failover specifier.
.PARAMETER Nopromote
	This option is only valid for the failover and reverse specifiers.  When used with the reverse specifier, specifies that the synchronized snapshots
	of groups that are switched from primary to secondary not be promoted to the base volume. When used with the failover specifier, it indicates that
	snapshots of groups that are switched from secondary to primary should not be promoted to the base volume in the case where all volumes of the group
	were not synchronized to the same time point. The incorrect use of this option can lead to the primary secondary volumes not being consistent.
.PARAMETER Nosnap
	Specifies that snapshots are not taken of groups that are switched from secondary to primary. Additionally, existing snapshots are deleted
	if groups are switched from primary to secondary. The use of this option may result in a full synchronization of the secondary volumes. This
	option can be used for failover, restore, and reverse subcommands.
.PARAMETER Stopgroups
	Specifies that groups are stopped before running the reverse subcommand.
.PARAMETER Local
	The -local option only applies to the "reverse" operation and then only when the -natural or -current options to the "reverse" operation
	are specified. Specifying -local with the "reverse" operation and an associated -natural or -current option will only affect the array
	where the command is issued and will not be mirrored to any other arrays in the Remote Copy configuration.
.PARAMETER Natural
	Specifying the -natural option with the "reverse" operation changes the role of the groups but not the direction of data flow between the
	groups on the arrays. For example, if the role of the groups are "primary" and "secondary", issuing the -natural option with the
	"reverse" operation will result in the role of the groups becoming "primary-rev" and "secondary-rev" respectively. The direction of data
	flow between the groups is not affected only the roles. Since the -natural option does not change the direction of data flow between
	groups it does not require the groups be stopped.
.PARAMETER Current
	Specifying the -current option with the "reverse" operation changes both the role and the direction of data flow between the groups. For
	example, if the roles of the groups are "primary" and "secondary", issuing the -current option to the "reverse" operation will result in
	the roles of the group becoming "secondary-rev" and "primary-rev" respectively and the direction data flow between the groups is
	reversed. Since the -current option actually reverses the direction of data replication it requires the group be stopped.

	Both the -natural and -current options must be used with care to ensure the Remote Copy groups do not end up in a non-deterministic
	state (like "secondary", "secondary-rev" for example) and to ensure data loss does not occur by inadvertently changing the direction of
	data flow and re-syncing old data on top of newer data.
.PARAMETER Waittask
	Wait for all tasks created by this command to complete before returning. This option applies to the failover, recover, restore, and reverse subcommands.
.PARAMETER Pat
	Specifies that specified patterns are treated as glob-style patterns and all remote copy groups matching the specified pattern will be
	set. The -pat option can specify a list of patterns. This option must be used if <pattern> specifier is used.
.PARAMETER Usr_cpg 
	Specifies the local user CPG and target user CPG that will be used for volumes that are auto-created. The local CPG will only be used after failover and recover.
.PARAMETER Snp_cpg 
	Specifies the local snap CPG and target snap CPG that will be used for volumes that are auto-created. The local CPG will only be used after failover and recover.
.PARAMETER Usr_cpg_unset
	Unset all user CPGs that are associated with this group.
.PARAMETER Snp_cpg_unset
	Unset all snap CPGs that are associated with this group.
.PARAMETER policy 
	auto_failover	:	Configure automatic failover on a remote-copy group.	
	no_auto_failover	:	Remote-copy groups will not be subject to automatic fail-over (default).
	auto_recover	:	Specifies that if the remote copy is stopped as a result of the remote-copy links going down,	the group is restarted automatically after the links come back up.
	no_auto_recover	:	Specifies that if the remote copy is stopped as a result of the remote-copy links going down, the group must be restarted manually after the links come back up (default).
	over_per_alert	:	If a synchronization of a periodic remote-copy group takes longer to complete than its synchronization period then an alert will be generated.
	no_over_per_alert 	:	If a synchronization of a periodic remote-copy group takes longer to complete than its synchronization period then an alert will not be generated.
	path_management	:	Volumes in the specified group will be enabled to support ALUA.
	no_path_management	:	ALUA behaviour will be disabled for volumes in the group.	
.PARAMETER GroupName
	Specifies the name of the volume group whose policy is set, or whose target direction is switched.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[Switch]	$Force,
		[Parameter()]	[String]	$T,	
		[Parameter()]	[Switch]	$Nostart,
		[Parameter()]	[Switch]	$Nosync,
		[Parameter()]	[Switch]	$Discard,
		[Parameter()]	[Switch]	$Nopromote,
		[Parameter()]	[Switch]	$Nosnap,
		[Parameter()]	[Switch]	$Stopgroups,
		[Parameter()]	[Switch]	$Local,
		[Parameter()]	[Switch]	$Natural,
		[Parameter()]	[Switch]	$Current,
		[Parameter()]	[Switch]	$Waittask,
		[Parameter()]	[Switch]	$Pat,
		[Parameter()]	[String]	$Usr_cpg,
		[Parameter()]	[String]	$Snp_cpg,
		[Parameter()]	[Switch]	$Usr_cpg_unset,
		[Parameter()]	[Switch]	$Snp_cpg_unset,
		[Parameter(Mandatory=$true)]	[ValidateSet('auto_failover','no_auto_failover','auto_recover','no_auto_recover','over_per_alert','no_over_per_alert','path_management','no_path_management')]	
						[String]	$policy,
		[Parameter(Mandatory=$true)]	[String]	$GroupName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "setrcopygroup pol "
	if($Force)		{	$cmd+= " -f "		}
	if($T)			{	$cmd+= " -t $T "	}
	if($Nostart)	{	$cmd+= " -nostart "	}
	if($Nosync)		{	$cmd+= " -nosync "	}
	if($Discard)	{	$cmd+= " -discard "	}
	if($Nopromote)	{	$cmd+= " -nopromote "}
	if($Nosnap)		{	$cmd+= " -nosnap "	}
	if($Stopgroups)	{	$cmd+= " -stopgroups "}
	if($Local)		{	$cmd+= " -local "	}
	if($Natural)	{	$cmd+= " -natural "	}
	if($Current)	{	$cmd+= " -current "	}	
	if($Waittask)	{	$cmd+= " -waittask "}	
	if($Pat)		{	$cmd+= " -pat "		}
	if($Usr_cpg)	{	$cmd+= " -usr_cpg $Usr_cpg "	}
	if($Snp_cpg)	{	$cmd+= " -snp_cpg $Snp_cpg "}	
	if($Usr_cpg_unset){	$cmd+= " -usr_cpg_unset "	}
	if($Snp_cpg_unset){	$cmd+= " -snp_cpg_unset "}
	$cmd+=" $policy "
	$cmd+="$GroupName "			
	$Result = Invoke-CLICommand -cmds  $cmd	
	write-verbose "  Executing Set-RCopyGroupPol using cmd    "	
	if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing Command "	}
	else									{	return  "FAILURE : While Executing  $Result " } 	
}
}

Function Set-A9RCopyTarget_CLI
{
<#
.SYNOPSIS
	The Changes the name of the indicated target using the <NewName> specifier.
.DESCRIPTION
	The Changes the name of the indicated target using the <NewName> specifier.  
.EXAMPLE
	Set-A9RCopyTarget_CLI -Enable -TargetName Demo1

	This Example Enables  the targetname Demo1.
.EXAMPLE
	Set-A9RCopyTarget_CLI -Disable -TargetName Demo1

	This Example disables  the targetname Demo1.  
.PARAMETER Enables/Disable 
	specify enable or disable 
.PARAMETER TargetName  
	Specifies the target name 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true, ParameterSetName='Enable')]		[switch]	$Enable ,
		[Parameter(Mandatory=$true, ParameterSetName='Disable')]	[switch]	$Disable ,
		[Parameter(Mandatory=$true)]								[String]	$TargetName
)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process
{	$cmd= "setrcopytarget "
	if ($Enable)		{	$cmd += " enable "	}
	elseif ($Disable)	{	$cmd += " disable "	}
	$cmd+=" $TargetName "	
	$Result = Invoke-CLICommand -cmds  $cmd	
	write-verbose "  Executing Changes the name of the indicated target   " 
	if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing $Result"	}
	else									{	return  "FAILURE : While Executing  $Result "} 	
}
}

Function Set-A9RCopyTargetName_CLI
{
<#
.SYNOPSIS
	The Changes the name of the indicated target using the <NewName> specifier.
.DESCRIPTION
	The Changes the name of the indicated target using the <NewName> specifier.
.EXAMPLE
	Set-A9RCopyTargetName_CLI -NewName DemoNew1  -TargetName Demo1

	This Example Changes the name of the indicated target using the -NewName demoNew1.   
.PARAMETER NewName 
	The new name for the indicated target. 
.PARAMETER TargetName  
	Specifies the target name for the target definition.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$NewName,
		[Parameter(Mandatory=$true)]	[String]	$TargetName
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "setrcopytarget name "
	$cmd+="$NewName "	
	$cmd+="$TargetName "	
	$Result = Invoke-CLICommand -cmds  $cmd	
	if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing $Result"	}
	else									{	return  "FAILURE : While Executing  $Result "} 	
}
}

Function Set-A9RCopyTargetPol_CLI
{
<#
.SYNOPSIS
	he command Sets the policy for the specified target using the <policy> specifier
.DESCRIPTION
	The command Sets the policy for the specified target using the <policy> specifier
.EXAMPLE
	Set-A9RCopyTargetPol_CLI -Mmirror_Config -Target vv3

	This Example sets the policy that all configuration commands,involving the specified target are duplicated for the target named vv3.   	
.PARAMETER Mirror_Config
	Specifies that all configuration commands,involving the specified target are duplicated.
.PARAMETER No_Mirror_Config
	If not specified, all configuration commands are duplicated.	
.PARAMETER Target
	Specifies the target name for the target definition.
.NOTES
	That the no_mirror_config specifier should only be used to allow recovery from an unusual error condition and only used after consulting your HPE representative.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
		[Parameter(ParameterSetName='Mirror',   Mandatory=$true)]	[switch]	$Mirror_Config,
		[Parameter(ParameterSetName='NoMirror', Mandatory=$true)]	[switch]	$No_Mirror_Config,
		[Parameter(Mandatory=$true)]								[String]	$Target
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "setrcopytarget pol "
	if ($Mirror_Config)			{	$cmd+=" mirror_config "	}
	elseif($No_Mirror_Config)	{	$cmd+=" no_mirror_config "	}
	$cmd+="$Target "
	$Result = Invoke-CLICommand -cmds  $cmd	
	if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing Command "	}
	else									{	return  "FAILURE : While Executing $result "	} 
}
}


Function Set-A9RCopyTargetWitness_CLI
{
<#
.SYNOPSIS
	The Changes the name of the indicated target using the <NewName> specifier.
.DESCRIPTION
	The Changes the name of the indicated target using the <NewName> specifier.
.EXAMPLE
	PS:> Set-A9RCopyTargetWitness_CLI -SubCommand create -Witness_ip 1.2.3.4 -Target TEST

	This Example Changes the name of the indicated target using the -NewName demoNew1.
.EXAMPLE	
	PS:> Set-A9RCopyTargetWitness_CLI -SubCommand create -Remote -Witness_ip 1.2.3.4 -Target TEST
.EXAMPLE
	PS:> Set-A9RCopyTargetWitness_CLI -SubCommand start -Target TEST
.EXAMPLE
	PS:> Set-A9RCopyTargetWitness_CLI -SubCommand stop  -Target TEST
.EXAMPLE  
	PS:> Set-A9RCopyTargetWitness_CLI -SubCommand remove -Remote -Target TEST
.EXAMPLE  
	PS:> Set-A9RCopyTargetWitness_CLI -SubCommand check  -Node_id 1 -Witness_ip 1.2.3.4
.PARAMETER SubCommand 
	Sub Command like create, Start, Stop, Remove and check.				
	create - Create an association between a synchronous target and a Quorum Witness (QW) as part of a Peer Persistence configuration.
	start|stop|remove -Activate, deactivate and remove the ATF configuration.
	check = Check connectivity to Quorum Witness.
.PARAMETER Remote
	Used to forward a witness subcommand to the be executed on the remote Storage System. When used in conjunction with the
	"witness check" subcommand the target must be specified - when executing on the local storage system target specification is not required to check
	connectivity with the Quorum Witness.
.PARAMETER Witness_ip
	The IP address of the Quorum Witness (QW) application, to which the Storage System will connect to update its status periodically.
.PARAMETER Target			
	Specifies the target name for the target definition previously created with the creatercopytarget command.
.PARAMETER Node_id	
	Node id with node option
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]			[ValidateSet('witness','create','start','stop','remove','check')]	
												[String]	$SubCommand,		
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Remote,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Witness_ip,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Target,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Node_id
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	if($SubCommand -eq "create")
		{	if($Witness_ip -And $Target)
				{	$cmd= "setrcopytarget witness $SubCommand"	
					if ($Remote)	{	$cmd += " -remote "	}
					$cmd +=" $Witness_ip $Target"
					$Result = Invoke-CLICommand -cmds  $cmd	
					write-verbose "  Executing Set-RCopyTargetWitness Changes the name of the indicated target   " 
					if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing Set-RCopyTargetWitness Command`n$result "	}
					else	{	return  "FAILURE : While Executing Set-RCopyTargetWitness`n$result "	} 
				}		
			else{	return "FAILURE : witness_ip, target missing or anyone of them are missing."	}
		}
	elseif($SubCommand -eq "start" -Or $SubCommand -eq "stop" -Or $SubCommand -eq "remove")
		{	if($Target)
				{	$cmd= "setrcopytarget witness $SubCommand"	
					if ($Remote)	{	$cmd += " -remote "	}
					$cmd +=" $Target"
					$Result = Invoke-CLICommand -cmds  $cmd	
					write-verbose "  Executing Changes the name of the indicated target   " 
					if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing Command`n$result "	}
					else	{	return  "FAILURE : While Executing `n$result "} 
				}		
			else{	return "FAILURE : Target is missing."	}
		}
	elseif($SubCommand -eq "check")
		{	if($Witness_ip)
				{	$cmd= "setrcopytarget witness $SubCommand"	
					if ($Remote)	{	$cmd += " -remote "	}
					if ($Node_Id)	{	$cmd += " -node $Node_Id "	}
					$cmd +=" $Witness_ip $Target"
					#write-host "$cmd"
					$Result = Invoke-CLICommand -cmds  $cmd	
					write-verbose "  Executing Changes the name of the indicated target   " 
					if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing Command`n$result "	}
					else	{	return  "FAILURE : While Executing`n$result "	} 
				}		
			else{	return "FAILURE : Witness_ip is missing."	}
		}
}
}

Function Show-A9RCopyTransport_CLI
{
<#
.SYNOPSIS
    The command shows status and information about end-to-end transport for Remote Copy in the system.
.DESCRIPTION
    The command shows status and information about end-to-end transport for Remote Copy in the system.
.EXAMPLE
	PS:> Show-A9RCopyTransport_CLI -RCIP
.EXAMPLE
	PS:> Show-A9RCopyTransport_CLI -RCFC
.PARAMETER RCIP
	Show information about Ethernet end-to-end transport.
.PARAMETER RCFC
	Show information about Fibre Channel end-to-end transport.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$RCIP,
		[Parameter()]	[switch]	$RCFC
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "showrctransport "
	if($RCIP)	{	$cmd+=" -rcip "	}
	if($RCFC)	{	$cmd+=" -rcfc "	}
	$Result = Invoke-CLICommand -cmds  $cmd
	$LastItem = $Result.Count 
	write-host "result Count = $LastItem"
	if($LastItem -lt 2)	{	return $Result	}
	$tempFile = [IO.Path]::GetTempFileName()		
	foreach ($s in  $Result[0..$LastItem] )
		{	$s= [regex]::Replace($s,"^ ","")			
			$s= [regex]::Replace($s," +",",")	
			$s= [regex]::Replace($s,"-","")
			$s= $s.Trim() 	
			Add-Content -Path $tempFile -Value $s
		}
	Import-Csv $tempFile 
	Remove-Item  $tempFile			
	if($Result -match "N:S:P")	{	return  " Success : Executing "	}
	else						{	return  $Result	}
}
}

Function Start-A9RCopy_CLI
{
<#
.SYNOPSIS
	The command starts the Remote Copy Service.
.DESCRIPTION
    The command starts the Remote Copy Service.
.EXAMPLE  
	PS:> Start-A9RCopy_CLI 
    
	command starts the Remote Copy Service.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "startrcopy "	
	$Result = Invoke-CLICommand -cmds  $cmd
	if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing  Command `n $Result "	}
	else									{	return  "FAILURE : Executing  `n $Result "	}
}
}

Function Start-A9RCopyGroup_CLI
{
<#
.SYNOPSIS
	The command enables remote copy for the specified remote-copy volume group.
.DESCRIPTION
    The command enables remote copy for the specified remote-copy volume group.
.EXAMPLE
	PS:> Start-A9RCopyGroup_CLI -NoSync -GroupName Group1

	This example starts remote copy for Group1.   
.EXAMPLE  	
	PS:> Start-A9RCopyGroup_CLI -NoSync -GroupName Group2 -Volumes_Snapshots "vv1:sv1 vv2:sv2 vv3:sv3"

	This Example  starts Group2, which contains 4 virtual volumes, and specify starting snapshots, with vv4 starting from a full resynchronization.
.PARAMETER NoSync
	Prevents the initial synchronization and sets the virtual volumes to a synchronized state.
.PARAMETER Wait
	Specifies that the command blocks until the initial synchronization is complete. The system generates an event when the synchronization is complete.
.PARAMETER Pat
	Specifies that specified patterns are treated as glob-style patterns and that all remote-copy groups matching the specified pattern will be started.
.PARAMETER Target
	Indicates that only the group on the specified target is started. If this option is not used, by default,  	the New-RCopyGroup command will affect all of a group’s targets.
.PARAMETER GroupName 
	The name of the remote-copy volume group.
.PARAMETER Volumes_Snapshots 
	Member volumes and snapshots can be specified by vv:sv syntax, where vv is the base volume name and sv is the snapshot volume name. To indicate a full
	resync, specify the starting, read-only snapshot with "-".
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$NoSync,
		[Parameter()]	[switch]	$Wait,
		[Parameter()]	[switch]	$Pat,
		[Parameter()]	[String]	$TargetName,
		[Parameter(Mandatory=$true)]	[String]	$GroupName,
		[Parameter()]	[String]	$Volumes_Snapshots		
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "startrcopygroup "
	if ($NoSync)	{	$cmd+= "-nosync "	}
	if ($Wait)		{	$cmd+= "-wait "		}
	if ($Pat)		{	$cmd+= "-pat "		}
	if ($TargetName){	$cmd+="-t $TargetName  "}			
	$cmd+="$GroupName "
	if ($Volumes_Snapshots){	$cmd+="$Volumes_Snapshots "	}
	$Result = Invoke-CLICommand -cmds  $cmd	
	return $Result	
}
}

Function Stop-A9RCopy_CLI
{
<#
.SYNOPSIS
	The Stop-RCopy command disables the remote-copy functionality for any started remote-copy
.DESCRIPTION
    The Stop-RCopy command disables the remote-copy functionality for any started remote-copy
.EXAMPLE  
	PS:> Stop-A9RCopy_CLI -StopGroups
	
	This example disables the remote-copy functionality of all primary remote-copy volume groups
.PARAMETER StopGroups
	Specifies that any started remote-copy volume groups are stopped.
.PARAMETER Clear
	Specifies that configuration entries affiliated with the stopped mode are deleted.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$StopGroups,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Clear
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "stoprcopy -f "	
	if ($StopGroups)	{	$cmd+=" -stopgroups "	}
	if ($Clear)			{	$cmd+=" -clear "		}
	$Result = Invoke-CLICommand -cmds  $cmd
	if($Result -match "Remote Copy config is not started")	{	Return "Command Execute Successfully :- Remote Copy config is not started"	}
	else													{	return $Result	}
}
}

Function Stop-A9RCopyGroup_CLI
{
<#
.SYNOPSIS
	The command stops the remote-copy functionality for the specified remote-copy volume group.
.DESCRIPTION
    The command stops the remote-copy functionality for the specified remote-copy volume group.
.EXAMPLE  
	PS:> Stop-A9RCopyGroup_CLI -NoSnap -GroupName RCFromRMC 	  
.EXAMPLE  
	PS:> Stop-A9RCopyGroup_CLI -TargetName RCFC_Romulus_1 -GroupName RCFromRMC 	
.PARAMETER NoSnap
	In synchronous mode, this option turns off the creation of snapshots.
.PARAMETER TargetName
	Indicates that only the group on the specified target is started. If this option is not used, by default,  	the New-RCopyGroup command will affect all of a group’s targets.
.PARAMETER GroupName 
	The name of the remote-copy volume group.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]					[switch]	$NoSnap,
		[Parameter()]					[String]	$TargetName,
		[Parameter(Mandatory=$true)]	[String]	$GroupName		
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "stoprcopygroup -f "
	if ($NoSnap)		{	$cmd+= " -nosnap "}	
	if ($TargetName)	{	$cmd+=" -t $TargetName  "	}
	$cmd1= "showrcopy"
	$Result1 = Invoke-CLICommand -cmds  $cmd1
	if ($Result1 -match $GroupName )	{	$cmd+="$GroupName "	}
	else								{	Return "FAILURE : -GroupName $GroupName  is Not Available Try with a new Name. "	}		
	$Result = Invoke-CLICommand -cmds  $cmd
	if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing  Command $Result"	}
	else									{	return 	$Result	}
}
}

Function Sync-A9RCopy_CLI
{
<#
.SYNOPSIS
	The command manually synchronizes remote-copy volume groups.
.DESCRIPTION
    The command manually synchronizes remote-copy volume groups.
.EXAMPLE
	PS:> Sync-A9RCopy_CLI -Wait -TargetName RCFC_Romulus_1 -GroupName AS_TEST1	   
.EXAMPLE  
	PS:> Sync-A9RCopy_CLI -N -TargetName RCFC_Romulus_1 -GroupName AS_TEST1	
.PARAMETER Wait
	Wait for synchronization to complete before returning to a command prompt.
.PARAMETER N
	Do not save resynchronization snapshot. This option is only relevant for asynchronous periodic mode volume groups.
.PARAMETER Ovrd
	Force synchronization without prompting for confirmation, even if volumes are already synchronized.
.PARAMETER TargetName
	Indicates that only the group on the specified target is started. If this option is not used, by default,  	the New-RCopyGroup command will affect all of a group’s targets.
.PARAMETER GroupName 
	Specifies the name of the remote-copy volume group to be synchronized.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Wait,
		[Parameter()]	[switch]	$N,
		[Parameter()]	[switch]	$Ovrd,
		[Parameter()]	[String]	$TargetName,
		[Parameter(Mandatory=$true)]	[String]	$GroupName
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "syncrcopy "
	if ($Wait)		{	$cmd+= " -w "	}
	if ($N)			{	$cmd+= " -n "	}
	if ($Ovrd)		{	$cmd+= " -ovrd "	}
	if ($TargetName){	$cmd+=" -t $TargetName  "	}			
	$cmd+="$GroupName "	
	$Result = Invoke-CLICommand -cmds  $cmd	
	return $Result	
}
}

Function Test-A9RCopyLink_CLI
{
<#checkrclink
.SYNOPSIS
    The command performs a connectivity, latency, and throughput test between two connected storage systems.
.DESCRIPTION
    The command performs a connectivity, latency, and throughput test between two connected storage systems.
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StartClient -NSP 0:5:4 -Dest_IP_Addr 1.1.1.1 -Time 20 -Port 1
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StartClient -TimeInSeconds 30 -NSP 0:5:4 -Dest_IP_Addr 1.1.1.1 -Time 20 -Port 1 
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StartClient -FCIP -NSP 0:5:4 -Dest_IP_Addr 1.1.1.1 -Time 20 -Port 1
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StopClient -NSP 0:5:4
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StartServer -NSP 0:5:4 
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StartServer -TimeInSeconds 30 -NSP 0:5:4 -Dest_IP_Addr 1.1.1.2 -Port 1
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StartServer -FCIP -NSP 0:5:4 -Dest_IP_Addr 1.1.1.2 -Port 1
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StopServer -NSP 0:5:4
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -PortConn -NSP 0:5:4 
.PARAMETER StartClient
	start the link test
.PARAMETER StopClient
	stop the link test
.PARAMETER StartServer
	start the server
.PARAMETER StopServer
	stop the server
.PARAMETER PortConn
    Uses the Cisco Discovery Protocol Reporter to show display information about devices that are connected to network ports.
.PARAMETER NSP
	Specifies the interface from which to check the link, expressed as node:slot:port.
.PARAMETER TimeInSeconds
    Specifies the number of seconds for the test to run using an integer from 300 to 172800.  If not specified this defaults to 172800 seconds (48 hours).
.PARAMETER FCIP
    Specifies if the link is running over fcip. Should only be supplied for FC interfaces.
.PARAMETER Dest_IP_Addr
	Specifies the address of the target system (for example, the IP address).
.PARAMETER Time
	Specifies the test duration in seconds. Specifies the number of seconds for the test to run using an integer from 300 to 172800.
.PARAMETER Port
	Specifies the port on which to run the test. If this specifier is not used, the test automatically runs on port 3492.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='StartC',Mandatory=$true)]	[switch]	$StartClient,
		[Parameter(ParameterSetName='StopC', Mandatory=$true )]	[switch]	$StopClient,
		[Parameter(ParameterSetName='StartS',Mandatory=$true)]	[switch]	$StartServer,
		[Parameter(ParameterSetName='StopS', Mandatory=$true )]	[switch]	$StopServer,
		[Parameter(ParameterSetName='PortC', Mandatory=$true )]	[switch]	$PortConn,
		[Parameter()]											[String]	$TimeInSeconds,	
		[Parameter()]											[switch]	$FCIP,
		[Parameter(Mandatory=$true)][ValidatePattern("^\d:\d:\d")]		
																[String]	$NSP,
		[Parameter()]											[String]	$Dest_IP_Addr,
		[Parameter(ParameterSetName='StartC',Mandatory=$true)]	[String]	$Time,
		[Parameter()]											[String]	$Port
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "checkrclink "	
	if($StartClient)	{	$cmd += " startclient "	}
	elseif($StopClient)	{	$cmd += " stopclient "	}
	elseif($StartServer){	$cmd += " startserver "	}
	elseif($StopServer)	{	$cmd += " stopserver "	}
	elseif($PortConn)	{	$cmd += " portconn "	}
	if($TimeInSeconds)	{	$cmd += " -time $TimeInSeconds "	}
	if($FCIP)			{	$cmd += " -fcip "	}
	if($NSP)			{	$cmd += " $NSP "	}
	if($Dest_IP_Addr)	{	$cmd += " $Dest_IP_Addr "	}
	else				{	if($StartClient)	{	return " Specifies the address of the target system Destination Address(for example, the IP address)"	}
						}
	if($StartClient)	{	$cmd += " $Time "	}
	if($Port)			{	$cmd += " $Port "	}	
	$Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
} 
}

Function Remove-A9RCopyVvFromGroup
{
<#
.SYNOPSIS
	The command removes a virtual volume from a remote-copy volume group.
.DESCRIPTION
	The command removes a virtual volume from a remote-copy volume group.
.EXAMPLE
	ps:> Remove-a9RCopyVvFromGroup -VV_name vv1 -group_name Group1

	dismisses virtual volume vv1 from Group1:
.EXAMPLE  
	ps:> Remove-a9RCopyVvFromGroup -Pat -VV_name testvv* -group_name Group1

	dismisses all virtual volumes that start with the name testvv from Group1:
.EXAMPLE  
	ps:> Remove-a9RCopyVvFromGroup -KeepSnap -VV_name vv1 -group_name Group1

	dismisses volume vv1 from Group1 and removes the corresponding volumes of vv1 on all the target systems of Group1.
.EXAMPLE 
	ps:> Remove-a9RCopyVvFromGroup -RemoveVV -VV_name vv2 -group_name Group1

	dismisses volume vv2 from Group2 and retains the resync snapshot associated with vv2 for this group.
.PARAMETER Pat
	Specifies that specified patterns are treated as glob-style patterns and that all remote-copy volumes matching the specified pattern will be dismissed from the remote-copy group.
.PARAMETER KeepSnap
	Specifies that the local volume's resync snapshot should be retained.
.PARAMETER RemoveVV
	Remove remote sides' volumes.	
.PARAMETER VVname
	The name of the volume to be removed. Volumes are added to a group with the admitrcopyvv command.	
.PARAMETER GroupName      
	The name of the group that currently includes the target.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]					[switch]	$Pat,
		[Parameter()]					[switch]	$KeepSnap,
		[Parameter()]					[switch]	$RemoveVV,
		[Parameter(Mandatory=$true)]	[String]	$VVname,
		[Parameter(Mandatory=$true)]	[String]	$GroupName
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "dismissrcopyvv -f "	
	if ($Pat)	{	$cmd+=" -pat "}
	if ($KeepSnap)	{	$cmd+=" -keepsnap "	}
	if ($RemoveVV)	{	$cmd+=" -removevv "	}
	if ($VVname)	{	$cmd+=" $VVname "	}
	$cmd1= "showrcopy"
	$Result1 = Invoke-CLICommand -cmds  $cmd1
	if ($Result1 -match $GroupName )	{	$cmd+=" $GroupName "	}
	else								{	Return "FAILURE : -GroupName $GroupName  is Unavailable to execute. "	}	
	$Result = Invoke-CLICommand -cmds  $cmd
	return $Result
}	
}

Function Sync-A9RecoverDRRcopyGroup
{
<#
.SYNOPSIS
    The command performs the following actions:
    Performs data synchronization from primary remote copy volume groups to secondary remote copy volume groups.
    Performs the complete recovery operation (synchronization and storage failover operation which performs role reversal to make secondary volumes as primary which becomes read-write) for the remote copy volume group in both planned migration and disaster scenarios.
.DESCRIPTION
    The command performs the following actions:
    Performs data synchronization from primary remote copy volume groups to secondary remote copy volume groups.
    Performs the complete recovery operation (synchronization and storage failover operation which performs role reversal to make secondary volumes as primary which becomes read-write) for the remote copy volume group in both planned migration and disaster scenarios.
.EXAMPLE
	PS:> Sync-A9RecoverDRRcopyGroup -Subcommand sync -Target_name test -Group_name Grp1
.EXAMPLE
	PS:> Sync-A9RecoverDRRcopyGroup -Subcommand recovery -Target_name test -Group_name Grp1
.EXAMPLE
	PS:> Sync-A9RecoverDRRcopyGroup -Subcommand sync -Force -Group_name Grp1
.EXAMPLE
	PS:> Sync-A9RecoverDRRcopyGroup -Subcommand sync -Nowaitonsync -Group_name Grp1
.EXAMPLE
	PS:> Sync-A9RecoverDRRcopyGroup -Subcommand sync -Nosyncbeforerecovery -Group_name Grp1
.EXAMPLE
	PS:> Sync-A9RecoverDRRcopyGroup -Subcommand sync -Nofailoveronlinkdown -Group_name Grp1
.EXAMPLE
	PS:> Sync-A9RecoverDRRcopyGroup -Subcommand sync -Forceassecondary -Group_name Grp1
.EXAMPLE
	PS:> Sync-A9RecoverDRRcopyGroup -Subcommand sync -Waittime 60 -Group_name Grp1
.PARAMETER Subcommand
	sync
	Performs the data synchronization from primary remote copy volume group to secondary remote copy volume group.
	
	recovery
	Performs complete recovery operation for the remote copy volume group in both planned migration and disaster scenarios.
.PARAMETER Target_name 
	Specifies the target for the subcommand. This is optional for single target groups but is required for multi-target groups.
.PARAMETER Force
	Does not ask for confirmation for this command.
.PARAMETER Nowaitonsync
	Specifies that this command should not wait for data synchronization from primary remote copy volume groups to secondary remote copy
	volume groups. This option is valid only for the sync subcommand.
.PARAMETER Nosyncbeforerecovery
	Specifies that this command should not perform data synchronization before the storage failover operation (performing role reversal to
	make secondary volumes as primary which becomes read-write). This option can be used if data synchronization is already done outside
	of this command and it is required to do only storage failover operation (performing role reversal to make secondary volumes as
	primary which becomes read-write). This option is valid only for the recovery subcommand.
.PARAMETER Nofailoveronlinkdown
	Specifies that this command should not perform storage failover operation (performing role reversal to make secondary volumes as
	primary which becomes read-write) when the remote copy link is down. This option is valid only for the recovery subcommand.
.PARAMETER Forceasprimary
	Specifies that this command does the storage failover operation (performing role reversal to make secondary volumes as primary
	which becomes read-write) and forces secondary role as primary irrespective of whether the data is current or not.
	This option is valid only for the recovery subcommand. The successful execution of this command must be immediately
	followed by the execution of the recovery subcommand with forceassecondary option on the other array. The incorrect use
	of this option can lead to the primary secondary volumes not being consistent. see the notes section for additional details.
.PARAMETER Forceassecondary
	This option must be used after successful execution of recovery subcommand with forceasprimary option on the other array.
	Specifies that this changes the primary volume groups to secondary volume groups. The incorrect use of this option can lead to the
	primary secondary volumes not being consistent. This option is valid only for the recovery subcommand.
.PARAMETER Nostart
	Specifies that this command does not start the group after storage failover operation is complete. This option is valid only for the recovery subcommand.
.PARAMETER Waittime <timeout_value>
	Specifies the timeout value for this command. Specify the time in the format <time>{s|S|m|M}. Value is a positive
	integer with a range of 1 to 720 minutes (12 Hours). Default time is 720 minutes. 
.PARAMETER Group_name
	Name of the Group
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[ValidateSet('sync','recovery')]	
						[String]	$Subcommand,
		[Parameter()]	[String]	$Target_name,
		[Parameter()]	[Switch]	$Nowaitonsync,
		[Parameter()]	[Switch]	$Nosyncbeforerecovery,
		[Parameter()]	[Switch]	$Nofailoveronlinkdown,
		[Parameter()]	[Switch]	$Forceasprimary,
		[Parameter()]	[Switch]	$Nostart,
		[Parameter()]	[String]	$Waittime,
		[Parameter(Mandatory=$true)]	[String]	$Group_name
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "controldrrcopygroup "
	if ($Subcommand)		{	$cmd+=" $Subcommand -f"			}	
	if ($Target_name)		{	$cmd+=" -target $Target_name "	}	
	if ($Nowaitonsync)		{	$cmd+=" -nowaitonsync "			}
	if ($Nosyncbeforerecovery){	$cmd+=" -nosyncbeforerecovery "	}
	if ($Nofailoveronlinkdown){	$cmd+=" -nofailoveronlinkdown "	}
	if ($Forceasprimary)	{	$cmd+=" -forceasprimary "		}
	if ($Nostart)			{	$cmd+=" -nostart "				}
	if ($Waittime)			{	$cmd+=" -waittime $Waittime "	}	
	if ($Group_name)		{	$cmd+=" $Group_name "			}	
	$Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
}
}

Function Set-A9AdmitRCopyHost
{
<#
.SYNOPSIS
    Add hosts to a remote copy group.
.DESCRIPTION
    The Set-AdmitRCopyHost command adds hosts to a remote copy group.
.PARAMETER Proximity
    Valid values are:
        primary:   Hosts with Active/Optimized I/O paths to the local primary storage device
        secondary: Hosts with Active/Optimized I/O paths to the local secondary storage device
        all:       Hosts with Active/Optimized I/O paths to both storage devices
.PARAMETER GroupName
    The group name, as specified with New-RCopyGroup cmdlet.
.PARAMETER HostName
    The host name, as specified with New-Host cmldet.
.EXAMPLE
    The following example adds host1 to group1 with Proximity primary:
    PS:> Get-A9HostSet -proximity primary group1 host1

    The following example shows the Active/Active groups with different proximities set:
    PS:> Get-A9HostSet_CLI -summary

        Id Name             HOST_Cnt VVOLSC Flashcache QoS RC_host
        552 RH2_Group0_1            1 NO     NO         NO  All
        555 RH0_Group0_0            1 NO     NO         NO  Pri
        556 RH1_Group0_2            1 NO     NO         NO  Sec
.NOTES
	This command requires a SSH type connection.
	SUPPORTED ARRAY VERSIONS: HPE Primera OS 4.3 onwards, HPE Alletra OS 9.3 onwards
    This command is only supported for groups for which the active_active policy is set.
    The policy value can be seen in Get-HostSet -summary under the RC_host column.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline = $true)]
        [ValidateSet("primary", "secondary", "all")]    [String]    $Proximity,		
        [Parameter(ValueFromPipeline = $true)]			[String]    $GroupName,
        [Parameter(ValueFromPipeline = $true)]			[String]    $HostName	
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = "admitrcopyhost  "
    if ($Proximity) {	$cmd += " -proximity $Proximity "	}	
    if ($GroupName) {	$cmd += " $GroupName "				}
    if ($HostName)	{	$cmd += " $HostName "				}
    $Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
}
}

Function Remove-A9RCopyHost
{
<#
.SYNOPSIS
    Dismiss/Remove hosts from a remote copy group.
.DESCRIPTION
    The Remove-RCopyHost command removes hosts from a remote copy group
.PARAMETER F
    Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
.PARAMETER GroupName
    The group name, as specified with New-RCopyGroup cmdlet.
.PARAMETER HostName
    The host name, as specified with New-Host cmldet.
.EXAMPLE
    The following example removes host1 from group1:

	PS:> Remove-A9RCopyHost group1 host1
.NOTES
	This command requires a SSH type connection.
	SUPPORTED ARRAY VERSIONS HPE Primera OS 4.3 onwards, HPE Alletra OS 9.3 onwards
    This command is only supported for groups for which the active_active policy is set.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline = $true)]    [String]	$F,
        [Parameter(ValueFromPipeline = $true)]    [String]	$GroupName,
        [Parameter(ValueFromPipeline = $true)]    [String]	$HostName
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = "dismissrcopyhost  "
    if ($F) 		{	$cmd += " -f "			}
    if ($GroupName) {	$cmd += " $GroupName "	}
    if ($HostName) 	{	$cmd += " $HostName "	}
    $Result = Invoke-CLICommand -cmds  $cmd
    write-verbose " The command removes hosts from a remote copy group" 
    return 	$Result	
}
} 

# SIG # Begin signature block
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBaLaDO3ld7
# b3B7BU1QFG/8nL9IszcCTmZo72ssZC+SjQZG8/Yh6SfjywAQq8yY5fxNQjmRFgve
# WnMlohEe4X8AoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQBW0vFMUGBj4mQh7b47eY3T4soPeCtyb4miW5Kg7mrF0spaigDc/Oh+j
# kcr+3TqQu1i3apmOs8uQ7WGK2GVcfFEwDQYJKoZIhvcNAQEBBQAEggGAj8XbCHGP
# /LZI+dQgaopsZWNG/y3qnP7AOYmUVAqF+aDAE1/7sTjUSuZK9V+jJtDFoX0FcMHs
# P9vYBoJQjZqIMQ8DRXiaVfiS6kdYX9dp2UN/LWfT+Tg240Lq5gsyxCw62UaWqlaq
# aahLMKMN5v8UBKi1GX/NmIfQSp8iK+dW6xeAvH0k8N/bc4dkcfQ+w3N9ppxk1iO4
# WViWuz45Hhl9OQt/yqg3I7nRuAFQyku9JhVGWi7VL1mndgQn4hJS7f9fI7NDbPAH
# rJwcG/b5PuK2rHKHJEn5aRQiciqEuxeTJSoYnce/CjUnOM+WuEd8Shlu1Z6n0zo2
# qPLf6TWsFKru3Wmc/8xtnQ15lnnGoRl4+FhAfPt4OhQExz0cZhzIWyqee7PVn+Sc
# Trdzqt+xmwkoNlMOSD6tEZDZP803T5RA8BRg5JyjrAY7N2yTOB6+huLXNqhFgtei
# 7O3Fn0NCHK1TwsIrTxyHZ0dvXK0nOG8HcpZdg4ZV7xMsC8xweHvgtmXKoYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMBlhVn5Ct2d1oSmVweRuT2myNipL84JH
# b9wWWVQ60kSkCc7LDSqg5pDxIZIaHi2ezQIUCYq95OtEBbd51p/Aq3I9VuOknj4Y
# DzIwMjQwNzMxMTkyNDU1WqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
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
# NzMxMTkyNDU1WjA/BgkqhkiG9w0BCQQxMgQwKGoisfAiADXAHgSVSMUNiKTbzLts
# ms182+QlWRpO/PMIOdM7n7o4V3O+JYAEVu1tMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgBZNFW2
# vmWoQKkQJ2bE9cDc85dR7M3TKue53nXkHv8h1lOEAvjHrWAGWCZNh+8dgTEL6DlG
# 1VCqp4Xwpl3gH+KaTtDN8D2da0/tGjsYraWv8MEQq+VL9f9BfY+tNmzvi6qIpSyV
# phI87R5OdHAt0i7D384R61EP2yPRJI41iIX6rxMnlT0CRNZnxy3VCO9p4EcIHXRY
# TsL+lP1qQKA+AdwayS88IfFIlpSJM3KNqvMv6+A3Is0jWnVUNJal9u3XewQzkTIo
# 1pQQ/DmtRjhqWKPLnuZPaKposfOkrsRJ+jhhavmsP+5jv25dcfUjaGoKohwtFahF
# B9CjWWD0Gse3ykUk98uNXRbUtrMnrKqXetFKfWtMnceiUG9VMXD2zTrQFi9wlSXR
# NbXm4BY0ZpTZeE4M5bsq53uhOyIs1W2teV1+YGKJnMjUl1DEXMVUHwBMamnm9uO6
# KhGJX0TXqTTlwZ5r77B4CG+fi65yO0iZSuZQrNQ8jTZZQ/OzVWX0bTDn6tIgpWgL
# /xx6rzJWKcFyB74bjtd5oJz60oJaD25eqGIIvFsIGN2aqw6ttHEOXoNqovzSIUvs
# B3lEAB0Zz3uuadq3AdoDNBd+686gfAbLWOqZgj0b33Y4APjbr6iisGQWU4Um+4aM
# gcy6AnjdmVLRZBUyz/6DXHXc7re7nPwyzD0xjg==
# SIG # End signature block
