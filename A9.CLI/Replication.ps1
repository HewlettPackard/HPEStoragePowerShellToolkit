## 	©2025 Hewlett Packard Enterprise Development LP

######## Add/New Commands
Function New-A9RCopyGroup_CLI
{
<#
.SYNOPSIS
	The New-RCopyGroupCPG command creates a remote-copy volume group.
.DESCRIPTION
    The New-RCopyGroupCPG command creates a remote-copy volume group.   
.PARAMETER LocalCPG
	Specifies the local user CPG and target user CPG that will be used for volumes that are auto-created. The local CPG will only be used after failover and recovery.
.PARAMETER TargetCPG
	Specifies the local user CPG and target user CPG that will be used for volumes that are auto-created. The local CPG will only be used after failover and recovery.
.PARAMETER domain
	Creates the Remote Copy group in the specified domain. The volume group must be created by a member of a particular domain with Super or Edit privileges.
.PARAMETER GroupName
	Specifies the name of the volume group, using up to 22 characters if the mirror_config policy is set, or up to 31 characters otherwise. This name is assigned with this command.
.PARAMETER TargetName
	Specifies the target name associated with this group. This name should already have been assigned using the creatercopytarget command. The <target_name>:<mode> pair can be repeated to specify multiple targets.
.PARAMETER Mode 	
	Specifies that the mode of the created group, the available modes are:
		sync—synchronous replication
		periodic—periodic asynchronous replication
	The <target_name>:<mode> pair can be repeated to specify multiple targets
.EXAMPLE
	New-A9RCopyGroupCPG_CLI -GroupName ABC -TargetName XYZ -Mode Sync	
.EXAMPLE  
	New-A9RCopyGroupCPG_CLI -LocalCpg RaidSet1 -TargetCPG RAIDSet2 -GroupName MyReplGroup -TargetName BellevueArray -Mode Sync
.NOTES
	This command utilizes the SSH command 'CreateRCopyGroup'
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='simple')]
param(	[Parameter(Mandatory)]							[String]	$GroupName,
		[Parameter(Mandatory)]							[String]	$TargetName,
		[Parameter(Mandatory)][ValidateSet("sync","periodic")]
														[String]	$Mode,
		[Parameter()]									[String]	$domain,
		[Parameter(parametersetname='usr',mandatory)]	[String]	$LocalCPG,
		[Parameter(parametersetname='usr',mandatory)]	[String]	$TargetCPG
	)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{		$cmd= "creatercopygroup"
		if ($domain )	{	$cmd+=" -domain $domain "		}	
		if($UsrCpg)		{	$cmd+=" -usr_cpg " + $LocalCPG + ' ' + $TargetName + ':' + $TargetCPG	}
		$cmd+= $GroupName + ' ' + $TargetName + ':' + $Mode
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd	
		if([string]::IsNullOrEmpty($Result))	
			{	Write-warning "While Executing  $($PSCmdlet.MyInvocation.MyCommand.Name), No Expected Results Found."	} 	
		else{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green }
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
.PARAMETER Target
    Specify name of the Target Name to be updated.
.PARAMETER IP
	The IP Address on the Target System to connect the local NSP to. The format should be in the format of ##.##.##.## such as 192.168.50.2
.PARAMETER WWN
	The Port Number:World Wide Name (WWN) address on the target system. The format should be 16 hexidecimal charactors without seperating colons, like 1122112211221122
.PARAMETER NSP
	The Node, Slot, and Port to use to connect the remote rcopy target. The format should be in the format of #:#:#, such as 1:2:3
.EXAMPLE
	PS:> Add-A9RCopyLink_CLI -Target demo1 -NSP 1:2:2 -IP 1:2:1:193.1.2.11
	
	This Example adds a link on System2 using the node, slot, and port information of node 1, slot 2, port 1 of the Ethernet port on the primary system. The IP address 193.1.2.11 specifies the address on the target system:
.EXAMPLE
	PS:> Add-A9RCopyLink_CLI -Target System2 -NSP 5:3:2 -WWN 1122112211221122
	
	This Example WWN creates an RCFC link to target System2, which connects to the local 5:3:2 (N:S:P) in the target system.
.NOTES
	This command utilizes the SSH command 'admitrcopylink'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]							[String]	$Target,
		[Parameter(Mandatory)]	[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]	
														[String]	$NSP,
		[Parameter(ParameterSetName='ip', Mandatory)]	[String]	$IP,
		[Parameter(ParameterSetName='wwn',Mandatory)]	[String]	$WWN
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = "admitrcopylink " + $Tarrget + ' ' + $NSP + ':' 
	if ($IP)		{	$cmd+= $IP			}
	if ($WWN)		{	$cmd+= $WWN			}
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
Function Set-A9RCopyGroup_CLI
{
<#
.SYNOPSIS
	Sets a resynchronization period for volume groups in asynchronous periodic mode.
.DESCRIPTION
	Sets a resynchronization period for volume groups in asynchronous periodic mode.   
.PARAMETER PeriodInterval
	Specifies the increment of the time period in units, can be seconds (s), minutes (m), hours (h), or days (d).
.PARAMETER PeriodValue
	Specifies the time period in units specified by the Periodic interval, such as 14 which could be either 14 minutes or 14hours for automatic resynchronization.
.PARAMETER Target
	Specifies the target name for the target definition created with the New-A9RCopyGroup command.
.PARAMETER Group
	Specifies the name of the RCopy group whose policy is set, or whose target direction is switched.
.PARAMETER NoStart
	Specifies that groups are not started after role reversal is completed. This option can be used for failover, recover and restore subcommands.
.PARAMETER NoSync
	Specifies that groups are not synced after role reversal is completed through the recover, restore and failover specifiers.
.PARAMETER Discard
	Specifies not to check a group's other targets to see if newer data should be pushed from them if the group has multiple targets. The use
	of this option can result in the loss of the most recent changes to the group's volumes and should be used carefully. This option is only valid for the failover specifier.
.PARAMETER NoPromote
	This option is only valid for the failover and reverse specifiers.  When used with the reverse specifier, specifies that the synchronized snapshots
	of groups that are switched from primary to secondary not be promoted to the base volume. When used with the failover specifier, it indicates that
	snapshots of groups that are switched from secondary to primary should not be promoted to the base volume in the case where all volumes of the group
	were not synchronized to the same time point. The incorrect use of this option can lead to the primary secondary volumes not being consistent.
.PARAMETER NoSnap
	Specifies that snapshots are not taken of groups that are switched from secondary to primary. Additionally, existing snapshots are deleted
	if groups are switched from primary to secondary. The use of this option may result in a full synchronization of the secondary volumes. This
	option can be used for failover, restore, and reverse subcommands.
.PARAMETER StopGroups
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
.PARAMETER LocalCPG 
	Specifies the local user CPG and target user CPG that will be used for volumes that are auto-created. The local CPG will only be used after failover and recover.
.PARAMETER TargetCPG
	Specifies the local snap CPG and target snap CPG that will be used for volumes that are auto-created. The local CPG will only be used after failover and recover.
.PARAMETER Usr_cpg_unset
	Unset all user CPGs that are associated with this group..PARAMETER Snp_cpg_unset Unset all snap CPGs that are associated with this group.
.EXAMPLE
	PS:> Set-A9RCopyGroup_CLI -PeriodInterval m -PeriodValue 10 -TargetName CHIMERA03 -GroupName AS_TEST
.EXAMPLE
	PS:> Set-A9RCopyGroup_CLI -PeriodInterval m -PeriodValue 10 -Force -Target CHIMERA03 -Group AS_TEST
.EXAMPLE
.EXAMPLE
	PS:> Set-A9RCopyGroup_CLI -PeriodInterval m -PeriodValue 10 -Natural -Target CHIMERA03 -Group AS_TEST	
.NOTES
	This command utilizes the SSH command 'setrcopygroup'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='RTest',mandatory)]			[switch]	$RemoveTest,

		[Parameter(ParameterSetName='Policy',mandatory)]				
			[ValidateSet('auto_failover','no_auto_failover','auto_failover_ext','no_auto_failover_ext','auto_recover','no_auto_recover','auto_synchronize','no_auto_synchronize','over_per_alert','no_over_per_alert','path_management','no_path_management','mt_pp','no_mt_pp','active-active','no_active_active')]	
																[string]	$Policy,
		[Parameter(ParameterSetName='Period',mandatory)]
			[ValidateSet('s','m','h','d')]						[string]	$PeriodInterval,
		[Parameter(ParameterSetName='Period',mandatory)]		[int]		$PeriodValue,

		[Parameter(ParameterSetName='Mode',mandatory)]
			[ValidateSet('sync','periodic')]					[string]	$ModeValue,

		[Parameter(ParameterSetName='CPGUn',mandatory)]			[switch]	$UnsetCPG,

		[Parameter(ParameterSetName='CPG',mandatory)]			[string]	$LocalCPG,
		[Parameter(ParameterSetName='CPG',mandatory)]			[string]	$TargetCPG,

		[Parameter(ParameterSetName='DrOp',Mandatory)]			
		[Parameter(ParameterSetName='DrOpG',Mandatory)]			
			[ValidateSet('failover','reverse','switchover','recover','restore','override')]
																[string]	$DROperation,
		[Parameter(ParameterSetName='DrOp')]			
		[Parameter(ParameterSetName='DrOpG')]					[switch]	$NoStart,
		[Parameter(ParameterSetName='DrOp')]			
		[Parameter(ParameterSetName='DrOpG')]					[switch]	$NoSync,
		[Parameter(ParameterSetName='DrOp')]			
		[Parameter(ParameterSetName='DrOpG')]					[switch]	$NoPromote,
		[Parameter(ParameterSetName='DrOp')]			
		[Parameter(ParameterSetName='DrOpG')]					[switch]	$NoSnap,
		[Parameter(ParameterSetName='DrOp')]			
		[Parameter(ParameterSetName='DrOpG')]					[switch]	$StopGroups,
		[Parameter(ParameterSetName='DrOp')]			
		[Parameter(ParameterSetName='DrOpG')]					[switch]	$Natural,
		[Parameter(ParameterSetName='DrOp')]			
		[Parameter(ParameterSetName='DrOpG')]					[switch]	$Current,
		[Parameter(ParameterSetName='DrOp')]			
		[Parameter(ParameterSetName='DrOpG')]					[switch]	$Local,
		[Parameter(ParameterSetName='DrOp')]			
		[Parameter(ParameterSetName='DrOpG')]					[switch]	$ForceAppFailover,
		
		[Parameter(ParameterSetName='DrOp',Mandatory)]
		[Parameter(ParameterSetName='Period',mandatory)]
		[Parameter(ParameterSetName='Mode',mandatory)]
		[Parameter(ParameterSetName='CPG',mandatory)]			[string]	$Target,
		
		[Parameter(ParameterSetName='Policy')]	
		[Parameter(ParameterSetName='Period')]	
		[Parameter(ParameterSetName='CPGUn',mandatory)]	
		[Parameter(ParameterSetName='Mode')]	
		[Parameter(ParameterSetName='CPG',mandatory)]				
		[Parameter(ParameterSetName='RTest',mandatory)]											
		[Parameter(ParameterSetName='DrOpG',mandatory)]
		[Parameter(ParameterSetName='DrOp')]					[string]	$Group
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd= "setrcopygroup "
	switch -wildcard ($PSCmdlet.ParameterSetName)
		{
			'Policy'	{	$cmd+=' pol ' + $Policy
						}
			'Period'	{	$cmd+=' period ' + $PeriodValue + $PeriodInterval + ' ' + $Target
						}
			'Mode'		{	$cmd+=' mode ' + $ModeValue + ' ' + $Target
						}
			'CPG'		{ 	$cmd+=' cpg -usr_cpg ' + $LocalCPG + ' ' + $Target + ':' + $TargetCPG + ' ' + $Group
						}
			'CPGun'		{	$cmd+=' cpg -usr_cpg_unset ' + $Group 
						}
			'RTest'		{	$cmd+= ' vvol -removetest ' + $Group
						}
			"DrO*"		{	$cmd+= $DROperation + ' '
							if ($NoStart)	
								{	if ( ( 'failover','recover','restore' ) -contains $DROperation )
										{	$cmd+='-nostart' 
										}
									else{	write-warning 'NoStart value not used unless operation type is Failover, Recover, or Restore'
										}
								}
							if ($NoSync)	
								{	if ( ( 'failover','recover','restore' ) -contains $DROperation )
										{	$cmd+='-nosync' 
										}
									else{	write-warning 'NoSync value not used unless operation type is Failover, Recover, or Restore'
										}
								}
							if ($Discard)	
								{	if ( ( 'failover' ) -contains $DROperation )
										{	$cmd+='-discard' 
										}
									else{	write-warning 'Discard value not used unless operation type is Failover'
										}
								}
							if ($NoPromote)	
								{	if ( ( 'failover','reverse' ) -contains $DROperation )
										{	$cmd+='-discard' 
										}
									else{	write-warning 'discard value not used unless operation type is Failover, Reverse'
										}
								}
							if ($NoSnap)	
								{	if ( ( 'failover','restore','reverse','switchover' ) -contains $DROperation )
										{	$cmd+='-nosnap' 
										}
									else{	write-warning 'NoSnap value not used unless operation type is Failover, Reverse, or Restore or Switchover'
										}
								}
							if ($StopGroups)	
								{	if ( ( 'reverse' ) -contains $DROperation )
										{	$cmd+='-nosnap' 
										}
									else{	write-warning 'NoSnap value not used unless operation type is Failover, Reverse, or Restore or Switchover'
										}
								}
							if ($Local)	
								{	if ( ( 'reverse' ) -contains $DROperation -and ( $natural -or $current) )
										{	$cmd+='-nosnap' 
										}
									else{	write-warning 'Local value not used unless operation type is Reverse and either Natural or Current are set'
										}
								}
							if ($Current)	
								{	if ( ( 'reverse' ) -contains $DROperation -and ( $natural -or $current) )
										{	$cmd+='-nosnap' 
										}
									else{	write-warning 'Current value not used unless operation type is Reverse'
										}
								}
						}
		}
	if ( $Target )	{	$cmd+=' ' + $Target 	}
	if ( $Group )	{	$cmd+=' ' + $Group 		}
	$cmd+= ' -f'
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
	The command StartServer should be run on one array first with a long TimeInSeconds as that window must be open when the local system starts its client.
	The command StartClient should be run on the other array with a time that allows for it to complete before the server side timeframe as elapsed.  
.PARAMETER StartClient
	start the link test, this requires another array to have been configured with a target port and the startserver command
.PARAMETER StopClient
	stop the link test
.PARAMETER StartServer
	start the server command with the timeframe to allow a client to be started and run tests against this port
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
.PARAMETER Port
	Will let you define the TCPIP port to use to run the tests, will default to 5001 is not specified. 
.PARAMETER PortConn
	Uses the Cisco Discovery Protocol Reporter to show display information about devices that are connected to network ports. Requires CDP to be enabled on the router.
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
	PS:> Test-A9RCopyLink_CLI -StartServer -TimeInSeconds 30 -NSP 0:5:4 -Dest_IP_Addr 1.1.1.2 -Port 1000
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StartServer -FCIP -NSP 0:5:4 -Dest_IP_Addr 1.1.1.2 -Port 1000
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -StopServer -NSP 0:5:4
.EXAMPLE
	PS:> Test-A9RCopyLink_CLI -PortConn -NSP 0:5:4 
.NOTES
	This command utilizes the SSH command 'checkrclink'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='startclient',Mandatory)]	[switch]	$StartClient,
		[Parameter(ParameterSetName='stopclient', Mandatory)]	[switch]	$StopClient,
		[Parameter(ParameterSetName='startserver',Mandatory)]	[switch]	$StartServer,
		[Parameter(ParameterSetName='stopserver', Mandatory)]	[switch]	$StopServer,
		[Parameter(ParameterSetName='portconn', Mandatory)]		[switch]	$PortConn,

		[Parameter(ParameterSetName='startclient',Mandatory)]
		[Parameter(ParameterSetName='startserver',Mandatory)]
		[ValidateRange(300,172800)]								[String]	$TimeInSeconds,	

		[Parameter(ParameterSetName='startclient',Mandatory)]	[switch]	$FCIP,

		[Parameter(Mandatory)][ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]	
																[String]	$NSP,
		[Parameter(ParameterSetName='startclient',Mandatory)]
		[Parameter(ParameterSetName='startserver',Mandatory)]	[String]	$Dest_IP_Addr,

		[Parameter(ParameterSetName='startclient')]
		[Parameter(ParameterSetName='startserver')]				[String]	$Port
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd= "checkrclink " + $PSCmdlet.ParameterSetName + ' '
	
	if($Time -and -not ($startclient))	{	$cmd += " -time $TimeInSeconds "	}
	if($FCIP)							{	$cmd += " -fcip "					}
	if($NSP)							{	$cmd += " $NSP "					}
	if($Dest_IP_Addr)					{	$cmd += " $Dest_IP_Addr "			}
	if($StartClient -and $time)			{	$cmd += " $Time "					}
	if($Port)							{	$cmd += " $Port "					}	
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

Function Set-A9RCopyService_CLI
{
<#
.SYNOPSIS
    Allows the Starting or Stopping of the Remote Coopy Service.
.DESCRIPTION
    Can either Start or Stop the Remote Copy service and optionally stops any started Remote Copy volume groups.
.PARAMETER StopGroups
    Specifies that any started Remote Copy volume groups are stopped.
.PARAMETER GroupName
    The group name, as specified with New-RCopyGroup cmdlet.
.PARAMETER Clear
    Specifies that configuration entries affiliated with the stopped mode are deleted.
.PARAMETER KeepALUA
	Keeps the ALUA state of the local volume from changing. Used only with the -clear option. Required for use during Peer Motion migrations of Remote Copy Groups. See, Volume migration in a Remote Copy Primary group in the Peer Motion User Guide for details.
.EXAMPLE
    PS:> Set-A9RCopyService -Start
.NOTES
	This command utilizes the SSH command 'startrcopy', 'stoprcopy'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Start', Mandatory)]    	[switch]	$Start,
        [Parameter(ParameterSetName='Stop', Mandatory)]  		[switch]	
        
		[Parameter(ParameterSetName='StopClear', Mandatory)]  	[switch]	$Stop,
        
		[Parameter(ParameterSetName='Stop')] 			 		[switch]	
        [Parameter(ParameterSetName='StopClear')] 		 		[switch]	$StopGroups,
		
		[Parameter(ParameterSetName='StopClear', Mandatory)]  	[switch]	$Clear,

        [Parameter(ParameterSetName='StopClear')]  				[switch]	$KeepALUA	
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = "dismissrcopyhost  "
    if ($Start) 	{	$cmd = " startrcopy "	}
    if ($Stop) 		{	$cmd = " stoprcopy "	}
    if ($StopGroups){	$cmd += " -stopgroups "	}
    if ($Clear)		{	$cmd += " -clear "		}
    if ($KeepALUA)	{	$cmd += " -stopgroups "	}
	$cmd += " -f "
    write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-CLICommand -cmds  $cmd
    write-verbose " The command removes hosts from a remote copy group" 
    return 	$Result	
}
} 
