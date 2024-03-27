####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##


Function New-A9vLun_CLI
{
<#
.SYNOPSIS
    The command creates a VLUN template that enables export of a Virtual Volume as a SCSI VLUN to a host or hosts. A SCSI VLUN is created when the
    current system state matches the rule established by the VLUN template
.DESCRIPTION
	The command creates a VLUN template that enables export of a Virtual Volume as a SCSI VLUN to a host or hosts. A SCSI VLUN is created when the
    current system state matches the rule established by the VLUN template.
    There are four types of VLUN templates:
        Port presents - created when only the node:slot:port are specified. The VLUN is visible to any initiator on the specified port.

        Host set - created when a host set is specified. The VLUN is visible to the initiators of any host that is a member of the set.

        Host sees - created when the hostname is specified. The VLUN is visible to the initiators with any of the host's WWNs.

        Matched set - created when both hostname and node:slot:port are specified. The VLUN is visible to initiators with the host's WWNs only on the specified port.

    Conflicts between overlapping VLUN templates are resolved using prioritization, with port presents templates having the lowest priority and
    matched set templates having the highest.
.EXAMPLE
    PS:> New-A9vLun_CLI -vvName xyz -LUN 1 -HostName xyz
.EXAMPLE
    PS:> New-A9vLun_CLI -vvSet set:xyz -NoVcn -LUN 2 -HostSet set:xyz
.PARAMETER vvName 
	Specifies the virtual volume or virtual volume set name, using up to 31 characters in length. 
	The volume name is provided in the syntax of basename.int.  The VV set name must start with "set:".
.PARAMETER vvSet 
	Specifies the virtual volume or virtual volume set name, using up to 31 characters in length. The volume name is provided in the syntax of basename.int.  
	The VV set name must start with "set:".
.PARAMETER LUN
	Specifies the LUN as an integer from 0 through 16383. Alternatively n+ can be used to indicate a LUN should be auto assigned, but be
	a minimum of n, or m-n to indicate that a LUN should be chosen in the range m to n. In addition the keyword auto may be used and is treated as 0+.
.PARAMETER HostName
	Specifies the host where the LUN is exported, using up to 31 characters.
.PARAMETER HostSet
	Specifies the host set where the LUN is exported, using up to 31 characters in length. The set name must start with "set:".
.PARAMETER NSP
	Specifies the system port of the virtual LUN export.
	node:  Specifies the system node, where the node is a number from 0 through 7.
	slot: Specifies the PCI bus slot in the node, where the slot is a number from 0 through 5.
	port: Specifies the port number on the FC card, where the port number is 1 through 4.
.PARAMETER Cnt
	Specifies that a sequence of VLUNs, as specified by the num argument, are exported to the same system port and host that is created. The num
	argument can be specified as any integer. For each VLUN created, the .int suffix of the VV_name specifier and LUN are incremented by one.
.PARAMETER NoVcn
	Specifies that a VLUN Change Notification (VCN) not be issued after export. For direct connect or loop configurations, a VCN consists of a
	Fibre Channel Loop Initialization Primitive (LIP). For fabric configurations, a VCN consists of a Registered State Change
	Notification (RSCN) that is sent to the fabric controller.
.PARAMETER Ovrd
	Specifies that existing lower priority VLUNs will be overridden, if necessary. Can only be used when exporting to a specific host.
#>
[CmdletBinding()]
param(	
		[Parameter(ParameterSetName='vvName_NSP', 		Mandatory=$true)]
		[Parameter(ParameterSetName='vvName_HostSet', 	Mandatory=$true)]
		[Parameter(ParameterSetName='vvName_HostName', 	Mandatory=$true)]	[String]	$vvName,

		[Parameter(ParameterSetName='vvSet_NSP',  		Mandatory=$true)]	
		[Parameter(ParameterSetName='vvSet_HostSet',  	Mandatory=$true)]	
		[Parameter(ParameterSetName='vvSet_HostName', 	Mandatory=$true)]
		[ValidateScript({	if( $_ -match "^set:") { $true } else { throw "Valid vvSet Parameter must start with 'Set:'"} } )]	
																			[String]	$vvSet,

		[Parameter(Mandatory=$true)]										[String]	$LUN,
		
		[Parameter(ParameterSetName='vvSet_NSP',  		Mandatory=$true)]
		[Parameter(ParameterSetName='vvName_NSP', 		Mandatory=$true)]	[String]	$NSP,

		[Parameter(ParameterSetName='vvName_HostSet', 	Mandatory=$true)]
		[Parameter(ParameterSetName='vvSet_HostSet',  	Mandatory=$true)]
		[ValidateScript({	if( $_ -match "^set:") { $true } else { throw "Valid vvSet Parameter must start with 'Set:'"} } )]	
																			[String]	$HostSet,

		[Parameter(ParameterSetName='vvName_HostName', 	Mandatory=$true)]
		[Parameter(ParameterSetName='vvSet_HostSet', 	Mandatory=$true)]	[String]	$HostName,

		[Parameter()]	[String]	$Cnt,
		[Parameter()]	[switch]	$NoVcn,
		[Parameter()]	[switch]	$Ovrd
	)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$cmdVlun = " createvlun -f"
	if($Cnt)			{	$cmdVlun += " -cnt $Cnt "	}
	if($NoVcn)			{	$cmdVlun += " -novcn "	}
	if($Ovrd)			{	$cmdVlun += " -ovrd "	}	
	if($vvName)			{	$cmdVlun += " $vvName "	}
	if($vvSet)			{	$cmdVlun += " $vvSet "	}
	if($LUN)			{	$cmdVlun += " $LUN "	}
	if($NSP)			{	$cmdVlun += " $NSP "	}
	elseif($HostSet)	{	$cmdVlun += " $HostSet "	}
	elseif($HostName)	{	$cmdVlun += " $HostName "	}
	$Result1 = Invoke-CLICommand -cmds  $cmdVlun
	write-verbose "Presenting $vvName to server $item with the command --> $cmdVlun" 
	if($Result1 -match "no active paths")		{	$successmsg += $Result1	}
	elseif([string]::IsNullOrEmpty($Result1))	{	$successmsg += "Success : $vvName exported to host $objName`n"	}
	else										{	$successmsg += "FAILURE : While exporting vv $vvName to host $objName Error : $Result1`n"	}		
	return $successmsg
} 
}


