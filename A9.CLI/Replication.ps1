## 	©2025 Hewlett Packard Enterprise Development LP

######## Add/New Commands

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

Function Get-A9Peer_CLI
{
<#
.SYNOPSIS   
	The command displays the arrays connected through the host ports or peer ports over the same fabric.
.DESCRIPTION  
	The command displays the arrays connected through the host ports or peer ports over the same fabric. The Type field
    specifies the connectivity type with the array. The Type value of Slave means the array is acting as a source, the Type value
    of Master means the array is acting as a destination, the type value of Peer means the array is acting as both source and destination.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE	
	This command utilizes the SSH command 'showpeer'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()] 	[switch]	$ShowRaw 
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}	
process	
{	$cmd = " showpeer"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if(-not ( ($Result -match "No peers") -or $ShowRaw ))
		{	$tempFile = [IO.Path]::GetTempFileName()
			foreach ($s in  $Result[0..($Result.count)] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','	
					Add-Content -Path $tempFile -Value $s
				}
			$Result = Import-Csv $tempFile 
			remove-item $tempFile
		}
	return $Result
}
} 

####### Set Commands

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
