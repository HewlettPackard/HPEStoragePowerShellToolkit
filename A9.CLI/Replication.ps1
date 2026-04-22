## 	©2025 Hewlett Packard Enterprise Development LP

######## Add/New Commands
Function New-A9RCopyGroupCPG_CLI
{
<#
.SYNOPSIS
	The New-RCopyGroupCPG command creates a remote-copy volume group.
.DESCRIPTION
    The New-RCopyGroupCPG command creates a remote-copy volume group.   
.PARAMETER UsrCpg
	The type of new Copy group will be a UserCPG and will require the LocalUserCPG, the TargetUserCPG:TargetUserCPG. 
.PARAMETER SnpCpg
	The type of new Copy group will be a SnapCPG and will require the LocalSnapCPG, the TargetSnapCPG:TargetSnapCPG. 
.PARAMETER UsrTargetName
	A required paremeter whe doing a UserCpg type replication. Points to the targets location
.PARAMETER SnpTargetName
	A required paremeter whe doing a SnapCpg type replication. Points to the targets location
.PARAMETER LocalUserCPG
	Specifies the local user CPG and target user CPG that will be used for volumes that are auto-created.
.PARAMETER TargetUserCPG
	-TargetUserCPG target:Targetcpg The local CPG will only be used after fail-over and recovery.
.PARAMETER LocalSnapCPG
	Specifies the local snap CPG and target snap CPG that will be used for volumes that are auto-created. 
.PARAMETER TargetSnapCPG
	-LocalSnapCPG  target:Targetcpg
	.PARAMETER domain
	Creates the remote-copy group in the specified domain.
.PARAMETER GroupName
	Specifies the name of the volume group, using up to 22 characters if the mirror_config policy is set, or up to 31 characters otherwise. This name is assigned with this command.	
.PARAMETER TargetName
	Specifies the target name associated with this group.
.PARAMETER Mode 	
	sync—synchronous replication
	async—asynchronous streaming replication
	periodic—periodic asynchronous replication
.EXAMPLE
	New-A9RCopyGroupCPG_CLI -GroupName ABC -TargetName XYZ -Mode Sync	
.EXAMPLE  
	New-A9RCopyGroupCPG_CLI -UsrCpg -LocalUserCPG BB -UsrTargetName XYZ -TargetUserCPG CC -GroupName ABC -TargetName XYZ -Mode Sync
.NOTES
	This command utilizes the SSH command 'CreateRCopyGroup'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]					[String]	$GroupName,
		[Parameter(Mandatory=$true)]					[String]	$TargetName,
		[Parameter(Mandatory=$true)][ValidateSet("sync","async","periodic")]
														[String]	$Mode,
		[Parameter(ParameterSetName='Dom',mandatory)]	[String]	$domain,
		[Parameter(parametersetname='usr',mandatory)]	[Switch]	$UsrCpg,
		[Parameter(parametersetname='usr',mandatory)]	[String]	$LocalUserCPG,
		[Parameter(parametersetname='usr',mandatory)]	[String]	$TargetUserCPG,
		[Parameter(parametersetname='usr',mandatory)]	[String]	$UsrTargetName,
		[Parameter(parametersetname='snp',mandatory)]	[Switch]	$SnpCpg,
		[Parameter(parametersetname='snp',mandatory)]	[String]	$LocalSnapCPG,
		[Parameter(parametersetname='snp',mandatory)]	[String]	$TargetSnapCPG,
		[Parameter(parametersetname='snp',mandatory)]	[String]	$SnpTargetName
	)		
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$cmd= "creatercopygroup"
		if ($domain)	
			{	$cmd+=" -domain $domain"	
		}	
		if($UsrCpg)
			{	$cmd+=" -usr_cpg $LocalUserCPG $UsrTargetName"
				$cmd+=":$TargetUserCPG "
			}
		if($SnpCpg)
			{	$cmd+=" -snp_cpg $LocalSnapCPG $SnpTargetName"	
				$cmd+=":$TargetSnapCPG "
			}
		$cmd+=" $GroupName $TargetName"
		$cmd+=":$Mode "
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd	
	}
end
	{	if([string]::IsNullOrEmpty($Result))	
				{	write-host "Success : Executing  New-RCopyGroupCPG Command" -ForegroundColor green
				} 
		return $Result
	}
}

Function Add-A9RCopyLink_CLI
{
<#
.SYNOPSIS
    The command adds one or more links (connections) to a remote-copy target system.
.DESCRIPTION
    The command adds one or more links (connections) to a remote-copy target system.  
.PARAMETER TargetName 
    Specify name of the TargetName to be updated.
.PARAMETER N_S_P_IP
	Node number:Slot number:Port Number:IP Address of the Target to be created.
.PARAMETER N_S_P_WWN
	Node number:Slot number:Port Number:World Wide Name (WWN) address on the target system.
.EXAMPLE
	PS:> Add-A9RCopyLink_CLI  -TargetName demo1 -N_S_P_IP 1:2:1:193.1.2.11
	
	This Example adds a link on System2 using the node, slot, and port information of node 1, slot 2, port 1 of the Ethernet port on the primary system. The IP address 193.1.2.11 specifies the address on the target system:
.EXAMPLE
	PS:> Add-A9RCopyLink_CLI -TargetName System2 -N_S_P_WWN 5:3:2:1122112211221122
	
	This Example WWN creates an RCFC link to target System2, which connects to the local 5:3:2 (N:S:P) in the target system.
.NOTES
	This command utilizes the SSH command 'admitrcopylink'
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-CLICommand -cmds  $cmd
	return $Result	
}
}

############ Get Commands

Function Get-A9StatRCopy_CLI
{
<#
.SYNOPSIS
	The command displays statistics for remote-copy volume groups.
.DESCRIPTION
    The command displays statistics for remote-copy volume groups.
.PARAMETER HeartBeat  
	Specifies that the heartbeat round-trip time of the links should be displayed in addition to the link throughput.
.PARAMETER Unit
	Displays statistics as kilobytes (k), megabytes (m), or gigabytes (g). If no unit is specified, the default is kilobytes.
.PARAMETER Iteration 
	Specifies that I/O statistics are displayed a specified number of times as indicated by the num argument using an integer from 1 through 2147483647.
.PARAMETER Interval
	Specifies the interval, in seconds, that statistics are sampled using an integer from 1 through 2147483647. If no interval is specified, the option
	defaults to an interval of two seconds.
.EXAMPLE
	PS:> Get-A9StatRCopy_CLI -HeartBeat -Iteration 1

	This example shows statistics for sending links ,Specifies that the heartbeat round-trip time.
.EXAMPLE  
	PS:> Get-A9StatRCopy_CLI -Iteration 1

	This example shows statistics for sending links link0 and link1.
.EXAMPLE  
	PS:> Get-A9StatRCopy_CLI -HeartBeat -Unit k -Iteration 1

	This example shows statistics for sending links ,Specifies that the heartbeat round-trip time & displays statistics as kilobytes	
.NOTES
	This command utilizes the SSH command 'statrcopy'
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-CLICommand -cmds  $cmd	
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	return  $Result
}
}

####### Set Commands
Function Set-A9RCopyGroupPeriod_CLI
{
<#
.SYNOPSIS
	Sets a resynchronization period for volume groups in asynchronous periodic mode.
.DESCRIPTION
	Sets a resynchronization period for volume groups in asynchronous periodic mode.   
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
.NOTES
	This command utilizes the SSH command 'setrcopygroup'
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-CLICommand -cmds  $cmd	
	write-verbose "  Executing Set-RCopyGroupPeriod using cmd   " 
	if([string]::IsNullOrEmpty($Result))	{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green }
	else									{	write-warning "FAILURE : While Executing"}
	return $result 
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
	This command utilizes the SSH command 'admitrcopyhost'
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
    write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
}
}

Function Test-A9RCopyLink_CLI
{
<#checkrclink
.SYNOPSIS
    The command performs a connectivity, latency, and throughput test between two connected storage systems.
.DESCRIPTION
    The command performs a connectivity, latency, and throughput test between two connected storage systems.
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
.NOTES
	This command utilizes the SSH command 'checkrclink'
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
		[Parameter(Mandatory=$true)][ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]	
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
} 
}


##### Disable/Remove Commands
Function Disable-A9RCopylink_CLI
{
<#
.SYNOPSIS
    The Disable-RCopylink command removes one or more links (connections) created with the admitrcopylink command to a target system.
.DESCRIPTION
    The Disable-RCopylink command removes one or more links (connections) created with the admitrcopylink command to a target system.
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
.EXAMPLE
	Disable-RCopylink -RCIP -Target_name test -NSP_IP_address 1.1.1.1
.EXAMPLE
	Disable-RCopylink -RCFC -Target_name test -NSP_WWN 1245
.NOTES
	This command utilizes the SSH command 'dismissrcopylink'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='RCIP',Mandatory)]	[Switch]	$RCIP,
		[Parameter(ParameterSetName='RCFC',Mandatory)]	[Switch]	$RCFC,
		[Parameter(ParameterSetName='RCIP',Mandatory)]
		[Parameter(ParameterSetName='RCFC',Mandatory)]	[String]	$Target_name,
		[Parameter(ParameterSetName='RCFC',Mandatory)]	[String]	$NSP_IP_address,
		[Parameter(ParameterSetName='RCIP',Mandatory)]	[String]	$NSP_WWN
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "dismissrcopylink "
	if($RCFC)	{	$cmd+=" $Target_name $NSP_IP_address "	}	
	if($RCIP)	{	$cmd+=" $Target_name $NSP_WWN "			}	
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-CLICommand -cmds  $cmd
	write-verbose " The command creates and admits physical disk definitions to enable the use of those disks  " 
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
	SUPPORTED ARRAY VERSIONS HPE Primera OS 4.3 onwards, HPE Alletra OS 9.3 onwards
    This command is only supported for groups for which the active_active policy is set.
.PARAMETER Force
    Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
.PARAMETER GroupName
    The group name, as specified with New-RCopyGroup cmdlet.
.PARAMETER HostName
    The host name, as specified with New-Host cmldet.
.EXAMPLE
    The following example removes host1 from group1:

	PS:> Remove-A9RCopyHost group1 host1
.NOTES
	This command utilizes the SSH command 'dismissrcopyhost'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]    [String]	$Force,
        [Parameter()]    [String]	$GroupName,
        [Parameter()]    [String]	$HostName
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = "dismissrcopyhost  "
    if ($Force) 	{	$cmd += " -f "			}
    if ($GroupName) {	$cmd += " $GroupName "	}
    if ($HostName) 	{	$cmd += " $HostName "	}
    write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-CLICommand -cmds  $cmd
    write-verbose " The command removes hosts from a remote copy group" 
    return 	$Result	
}
} 

