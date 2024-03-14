####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##


Function Get-A9vLun_CLI
{
<#
.SYNOPSIS
    Get list of LUNs that are exported/ presented to hosts
.DESCRIPTION
    Get list of LUNs that are exported/ presented to hosts
.EXAMPLE
    Get-vLun 

	List all exported volumes
.EXAMPLE	
	Get-vLun -vvName PassThru-Disk 

	List LUN number and hosts/host sets of LUN PassThru-Disk
.PARAMETER vvName 
    Specify name of the volume to be exported.  If prefixed with 'set:', the name is a volume set name.
#>
[CmdletBinding()]
param(	[Parameter()]							[String]	$vvName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$PresentTo
	)
Begin
{	Test-A9CLIConnection
}		
process	
{	$ListofvLUNs = @()	
	$GetvLUNCmd = "showvlun -t -showcols VVName,Lun,HostName,VV_WWN "
	if ($vvName)	{	$GetvLUNCmd += " -v $vvName"	}	
	$Result = Invoke-CLICommand -cmds  $GetvLUNCmd
	write-verbose "Get list of vLUN" 
	if($Result -match "Invalid vv name:")	{	return "FAILURE : No vv $vvName found"	}	
	$Result = $Result | where-object { ($_ -notlike '*total*') -and ($_ -notlike '*------*')} ## Eliminate summary lines
	if ($Result.Count -gt 1)
		{	foreach ($s in  $Result[1..$Result.Count] )
			{	$s= $s.Trim()
				$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
				$sTemp = $s.Split(',')
				$vLUN = New-Object -TypeName _vLUN
				$vLUN.Name = $sTemp[0]
				$vLUN.LunID = $sTemp[1]
				$vLUN.PresentTo = $sTemp[2]
				$vLUN.vvWWN = $sTemp[3]
				$ListofvLUNs += $vLUN			
			}
		}
	else{	return "FAILURE : No vLUN $vvName found Error : $Result"	}
	if ($PresentTo)	{ $ListofVLUNs | where-object {$_.PresentTo -like $PresentTo} }
	else			{ $ListofVLUNs  }
}
} 

Function Show-A9vLun_CLI
{
<#
.SYNOPSIS
    Get list of LUNs that are exported/ presented to hosts
.DESCRIPTION
    Get list of LUNs that are exported/ presented to hosts
.EXAMPLE
    Show-vLun 

	List all exported volumes
.EXAMPLE	
	Show-vLun -vvName XYZ 

	List LUN number and hosts/host sets of LUN XYZ
.EXAMPLE	
	Show-vLun -Listcols
.EXAMPLE	
	Show-vLun -Nodelist 1
.EXAMPLE	
	Show-vLun -DomainName Aslam_D	
.PARAMETER vvName 
    Specify name of the volume to be exported.  If prefixed with 'set:', the name is a volume set name.
.PARAMETER Listcols
	List the columns available to be shown in the -showcols option described below (see 'clihelp -col showvlun' for help on each column).
.PARAMETER Showcols <column>[,<column>...]
	Explicitly select the columns to be shown using a comma-separated list of column names.  For this option the full column names are shown in
	the header. Run 'showvlun -listcols' to list the available columns. Run 'clihelp -col showvlun' for a description of each column.
.PARAMETER ShowWWN
	Shows the WWN of the virtual volume associated with the VLUN.
.PARAMETER ShowsPathSummary
	Shows path summary information for active VLUNs
.PARAMETER Hostsum
	Shows mount point, Bytes per cluster, capacity information from Host Explorer and user reserved space, VV size from showvv.
.PARAMETER ShowsActiveVLUNs
	Shows only active VLUNs.
.PARAMETER ShowsVLUNTemplates
	Shows only VLUN templates.
.PARAMETER Hostname 
	{<hostname>|<pattern>|<hostset>}...
	Displays only VLUNs exported to hosts that match <hostname> or glob-style patterns, or to the host sets that match <hostset> or
	glob-style patterns(see help on sub,globpat). The host set name must start with "set:". Multiple host names, host sets or patterns can
	be repeated using a comma-separated list.
.PARAMETER VV_name 
	{<VV_name>|<pattern>|<VV_set>}...
	Displays only VLUNs of virtual volumes that match <VV_name> or glob-style patterns, or to the vv sets that match <VV-set> or glob-style
	patterns (see help on sub,globpat). The VV set name must start with "set:". Multiple volume names, vv sets or patterns can be
	repeated using a comma-separated list (for example -v <VV_name>, <VV_name>...).
.PARAMETER LUN
	Specifies that only exports to the specified LUN are displayed. This specifier can be repeated to display information for multiple LUNs.
.PARAMETER Nodelist
	Requests that only VLUNs for specific nodes are displayed. The node list is specified as a series of integers separated by commas (for example
	0,1,2). The list can also consist of a single integer (for example 1).
.PARAMETER Slotlist
	Requests that only VLUNs for specific slots are displayed. The slot list is specified as a series of integers separated by commas (for example
	0,1,2). The list can also consist of a single integer (for example 1).
.PARAMETER Portlist
	Requests that only VLUNs for specific ports are displayed. The port list is specified as a series of integers separated by commas ((for example
	1,2). The list can also consist of a single integer (for example 1).
.PARAMETER Domain_name  
	Shows only the VLUNs whose virtual volumes are in domains with names that match one or more of the <domainname_or_pattern> options. This
	option does not allow listing objects within a domain of which the user is not a member. Multiple domain names or patterns can be repeated using
	a comma-separated list.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Listcols,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Showcols, 
		[Parameter()]	[switch]	$ShowsWWN,
		[Parameter()]	[switch]	$ShowsPathSummary,
		[Parameter()]	[switch]	$Hostsum,
		[Parameter()]	[switch]	$ShowsActiveVLUNs,
		[Parameter()]	[switch]	$ShowsVLUNTemplates,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Hostname,
		[Parameter(ValueFromPipeline=$true)]	[String]	$VV_name,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LUN,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Nodelist,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Slotlist,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Portlist,
		[Parameter(ValueFromPipeline=$true)]	[String]	$DomainName
	)	
Begin
{	Test-A9CLIConnection
}	
process	
{	$cmd = "showvlun "
	if($Listcols)		{	$cmd += " -listcols " 	}
	if($Showcols)		{	$cmd += " -showcols $Showcols" }
	if($ShowsWWN)		{	$cmd += " -lvw " 	}
	if($ShowsPathSummary){	$cmd += " -pathsum " 	}
	if($Hostsum)		{	$cmd += " -hostsum " 	}
	if($ShowsActiveVLUNs){	$cmd += " -a " 	}
	if($ShowsVLUNTemplates){$cmd += " -t " 	}
	if($Hostname)		{	$cmd += " -host $Hostname" 	}
	if($VV_name)		{	$cmd += " -v $VV_name" 	}
	if($LUN)			{	$cmd += " -l $LUN" 	}
	if($Nodelist)		{	$cmd += " -nodes $Nodelist" 	}
	if($Slotlist)		{	$cmd += " -slots $Slotlist" 	}
	if($Portlist)		{	$cmd += " -ports $Portlist" 	}
	if($DomainName)		{	$cmd += " -domain $DomainName" 	}
	$Result = Invoke-CLICommand -cmds  $cmd
	return $Result
}
}

Function New-A9vLun_CLI
{
<#
.SYNOPSIS
    The New-vLun command creates a VLUN template that enables export of a Virtual Volume as a SCSI VLUN to a host or hosts. A SCSI VLUN is created when the
    current system state matches the rule established by the VLUN template
.DESCRIPTION
	The New-vLun command creates a VLUN template that enables export of a Virtual Volume as a SCSI VLUN to a host or hosts. A SCSI VLUN is created when the
    current system state matches the rule established by the VLUN template.
    There are four types of VLUN templates:
        Port presents - created when only the node:slot:port are specified. The VLUN is visible to any initiator on the specified port.

        Host set - created when a host set is specified. The VLUN is visible to the initiators of any host that is a member of the set.

        Host sees - created when the hostname is specified. The VLUN is visible to the initiators with any of the host's WWNs.

        Matched set - created when both hostname and node:slot:port are specified. The VLUN is visible to initiators with the host's WWNs only on the specified port.

    Conflicts between overlapping VLUN templates are resolved using prioritization, with port presents templates having the lowest priority and
    matched set templates having the highest.
.EXAMPLE
    New-vLun -vvName xyz -LUN 1 -HostName xyz
.EXAMPLE
    New-vLun -vvSet set:xyz -NoVcn -LUN 2 -HostSet set:xyz
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
param(	[Parameter()]	[String]	$vvName,
		[Parameter()]	[String]	$vvSet,
		[Parameter()]	[String]	$LUN,
		[Parameter()]	[String]	$NSP,
		[Parameter()]	[String]	$HostSet,
		[Parameter()]	[String]	$HostName,
		[Parameter()]	[String]	$Cnt,
		[Parameter()]	[switch]	$NoVcn,
		[Parameter()]	[switch]	$Ovrd
	)		
Begin
{	Test-A9CLIConnection
}
process
{	$cmdVlun = " createvlun -f"
	if($Cnt)	{	$cmdVlun += " -cnt $Cnt "	}
	if($NoVcn)	{	$cmdVlun += " -novcn "	}
	if($Ovrd)	{	$cmdVlun += " -ovrd "	}	
	###Added v2.1 : checking the parameter values if vvName or present to empty simply return
	if ($vvName -Or $vvSet)
	{	if($vvName)	{	$cmdVlun += " $vvName "	}
		else		{	if ($vvSet -match "^set:")	{	$cmdVlun += " $vvSet "	}
						else						{	return "Please make sure The VV set name must start with set: Ex:- set:xyz"	}
					}		
	}
	else
		{	Write-DebugLog "No values specified for the parameters vvname. so simply exiting "
			Get-help New-vLun
			return
		}
	if($LUN)			{	$cmdVlun += " $LUN "	}
	else				{	return " Specifies the LUN as an integer from 0 through 16383."	}	
	if($NSP)			{	$cmdVlun += " $NSP "	}
	elseif($HostSet)
		{	if ($HostSet -match "^set:")	{	$cmdVlun += " $HostSet "	}
			else							{	return "Please make sure The set name must start with set: Ex:- set:xyz"	}
		}
	elseif($HostName)	{	$cmdVlun += " $HostName "	}
	else				{	return "Please select atlist any one from NSP | HostSet | HostName"	}
	
	$Result1 = Invoke-CLICommand -cmds  $cmdVlun
	write-verbose "Presenting $vvName to server $item with the command --> $cmdVlun" 
	if($Result1 -match "no active paths")		{	$successmsg += $Result1	}
	elseif([string]::IsNullOrEmpty($Result1))	{	$successmsg += "Success : $vvName exported to host $objName`n"	}
	else										{	$successmsg += "FAILURE : While exporting vv $vvName to host $objName Error : $Result1`n"	}		
	return $successmsg
} 
}

Function Remove-A9vLun_CLI
{
<#
.SYNOPSIS
    Unpresent virtual volumes 
.DESCRIPTION
    Unpresent  virtual volumes 
.EXAMPLE
	Remove-vLun -vvName PassThru-Disk -force

	Unpresent the virtual volume PassThru-Disk to all hosts
.EXAMPLE	
	Remove-vLun -vvName PassThru-Disk -whatif 

	Dry-run of deleted operation on vVolume named PassThru-Disk
.EXAMPLE		
	Remove-vLun -vvName PassThru-Disk -PresentTo INF01  -force

	Unpresent the virtual volume PassThru-Disk only to host INF01.	all other presentations of PassThru-Disk remain intact.
.EXAMPLE	
	Remove-vLun -PresentTo INF01 -force

	Remove all LUNS presented to host INF01
.EXAMPLE	
	Remove-vLun -vvName CSV* -PresentTo INF01 -force

	Remove all LUNS started with CSV* and presented to host INF01
.EXAMPLE
	Remove-vLun -vvName vol2 -force -Novcn
.EXAMPLE
	Remove-vLun -vvName vol2 -force -Pat
.EXAMPLE
	Remove-vLun -vvName vol2 -force -Remove_All   

	It removes all vluns associated with a VVOL Container.
.PARAMETER whatif
    If present, perform a dry run of the operation and no VLUN is removed	
.PARAMETER force
	If present, perform forcible delete operation
.PARAMETER vvName 
    Specify name of the volume to be exported. 
.PARAMETER PresentTo 
    Specify name of the hosts where vLUns are presented to.
.PARAMETER Novcn
	Specifies that a VLUN Change Notification (VCN) not be issued after removal of the VLUN.
	.PARAMETER Pat
	Specifies that the <VV_name>, <LUN>, <node:slot:port>, and <host_name> specifiers are treated as glob-style patterns and that all VLUNs matching the specified pattern are removed.
.PARAMETER Remove_All
	It removes all vluns associated with a VVOL Container.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='F',Mandatory=$true)]		[Switch]	$force, 
		[Parameter(ParameterSetName='W',Mandatory=$true)]		[Switch]	$whatif, 		
		[Parameter(Mandatory=$true)]							[String]	$vvName,
		[Parameter(,Mandatory=$true)]							[String]	$PresentTo, 		
		[Parameter()]											[Switch]	$Novcn,
		[Parameter()]											[Switch]	$Pat,
		[Parameter()]											[Switch]	$Remove_All	
	)
Begin
{	Test-A9CLIConnection
}		
process	
{	if(!(($force) -or ($whatif)))
	{	write-verbose "no -force or -whatif option selected to remove/dry run of VLUN, Exiting...."
		Get-help Remove-vLun
		return "FAILURE : no -force or -whatif option selected to remove/dry run of VLUN"
	}
	if($PresentTo)	{	$ListofvLuns = Get-vLun -vvName $vvName -PresentTo $PresentTo }
	else			{	$ListofvLuns = Get-vLun -vvName $vvName 	}
	if($ListofvLuns -match "FAILURE")	{	return "FAILURE : No vLUN $vvName found"	}
	$ActionCmd = "removevlun "
	if ($whatif)	{	$ActionCmd += "-dr "	}
	else			{	if($force)	{	$ActionCmd += "-f "	} }	
	if ($Novcn)		{	$ActionCmd += "-novcn "	}
	if ($Pat)		{	$ActionCmd += "-pat "	}
	if($Remove_All)	{	$ActionCmd += " -set "	}
	if ($ListofvLuns)
		{	foreach ($vLUN in $ListofvLuns)
				{	$vName = $vLUN.Name
					if ($vName)
						{	$RemoveCmds = $ActionCmd + " $vName $($vLun.LunID) $($vLun.PresentTo)"
							$Result1 = Invoke-CLICommand -cmds  $RemoveCmds
							write-verbose "Removing Virtual LUN's with command $RemoveCmds" 
							if ($Result1 -match "Issuing removevlun")
								{	$successmsg += "Success: Unexported vLUN $vName from $($vLun.PresentTo)"
								}
							elseif($Result1 -match "Dry run:")
								{	$successmsg += $Result1
								}
							else
								{	$successmsg += "FAILURE : While unexporting vLUN $vName from $($vLun.PresentTo) "
								}				
						}
				}
			return $successmsg
		}
	else
		{	return "FAILURE : no vLUN found for $vvName presented to host $PresentTo"
		}	
}
}
