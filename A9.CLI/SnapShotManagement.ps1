## 	©2025 Hewlett Packard Enterprise Development LP

Function Push-A9GroupSnapVolume
{
<#
.SYNOPSIS
    Copies the differences of snapshots back to their base volumes.
.DESCRIPTION
	Copies the differences of snapshots back to their base volumes.
.PARAMETER VVNames 
    Specify virtual copy name of the Snap shot
.PARAMETER TargetVV 
    Target vv Name
.PARAMETER RCP 
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been
	started. If the Remote Copy group has been started, this command fails. This option cannot be used in conjunction with the -halt option.
.PARAMETER Halt 
    Cancels ongoing snapshot promotions. Marks the RW parent volumes with the "cpf" status that can be cleaned up using the promotevvcopy command
	or by issuing a new instance of the promotesv/promotegroupsv command. This option cannot be used in conjunction with any other option.
.PARAMETER PRI 
    Specifies the priority of the copy operation when it is started. This option allows the user to control the overall speed of a particular
	task.  If this option is not specified, the promotegroupsv operation is started with default priority of medium. High priority indicates that
	the operation will complete faster. Low priority indicates that the operation will run slower than the default priority task. This option
	cannot be used with -halt option.
.PARAMETER Online 
    Indicates that the promote operation will be executed while the target volumes have VLUN exports. The hosts should take the target LUNs offline
	to initiate the promote command, but can be brought online and used during the background tasks. Each specified virtual copy and its base
	volume must be the same size. The base volume is the only possible target of online promote, and is the default. To halt a promote started
	with the online option, use the canceltask command. The -halt, -target, and -pri options cannot be combined with the -online option.	
.EXAMPLE
    PS:> Push-A9GroupSnapVolume
.EXAMPLE
	PS:> Push-A9GroupSnapVolume -VVNames WSDS_compr02F
.EXAMPLE
	PS:> Push-A9GroupSnapVolume -VVNames "WSDS_compr02F"
.EXAMPLE
	PS:> Push-A9GroupSnapVolume -VVNames "tesWSDS_compr01t_lun"
.EXAMPLE
	PS:> Push-A9GroupSnapVolume -VVNames WSDS_compr01 -RCP
.EXAMPLE
	PS:> Push-A9GroupSnapVolume -VVNames WSDS_compr01 -Halt
.EXAMPLE
	PS:> Push-A9GroupSnapVolume -VVNames WSDS_compr01 -PRI high
.EXAMPLE
	PS:> Push-A9GroupSnapVolume -VVNames WSDS_compr01 -Online
.EXAMPLE
	PS:> Push-A9GroupSnapVolume -VVNames WSDS_compr01 -TargetVV at
.EXAMPLE
	PS:> Push-A9GroupSnapVolume -VVNames WSDS_compr01 -TargetVV y
.NOTES
	This command utilizes the SSH command 'promotegroupsv' 
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$VVNames,
		[Parameter()]					[String]	$TargetVV,
		[Parameter()]					[switch]	$RCP,
		[Parameter()]					[switch]	$Halt,
		[Parameter()]			
		[ValidateSet('high','med','low')][String]	$PRI,	
		[Parameter()]					[switch]	$Online
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$PromoteCmd = "promotegroupsv " 	
	if ($RCP)	{	$PromoteCmd += " -rcp "		}
	if ($Halt)	{	$PromoteCmd += " -halt "	}
	if ($PRI)	{	$PromoteCmd += " -pri $PRI "}
	if ($Online){	$PromoteCmd += " -online "	}
	if($VVNames){	$PromoteCmd += " $VVNames"	}
	if ($TargetVV){	$PromoteCmd += ":"
					$PromoteCmd += "$TargetVV "
				}
			
	$result = Invoke-A9CLICommand -cmds  $PromoteCmd
	if( $result -match "has been started to promote virtual copy")
		{	return "Success : Execute  `n $result"
		}
	elseif($result -match "Error: Base volume may not be promoted")
		{	return "FAILURE : While Executing  `Error: Base volume may not be promoted"
		}
	elseif($result -match "has exports defined")
		{	return "FAILURE : While Executing  `n $result"
		}
	else{	return "FAILURE : While Executing  `n $result"
		}
}	
}

Function Push-A9SnapVolume
{
<#
.SYNOPSIS
    This command copies the differences of a snapshot back to its base volume, allowing you to revert the base volume to an earlier point in time.
.DESCRIPTION
	This command copies the differences of a snapshot back to its base volume, allowing you to revert the base volume to an earlier point in time.
.PARAMETER name 
    Specifies the name of the virtual copy volume or set of virtual copy volumes to be promoted 
.PARAMETER target 
    Copy the differences of the virtual copy to the specified RW parent in the same virtual volume family tree.
.PARAMETER RCP
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been
	started. If the Remote Copy group has been started, this command fails. This option cannot be used in conjunction with the -halt option.
.PARAMETER Halt
	Cancels an ongoing snapshot promotion. Marks the RW parent volume with the "cpf" status that can be cleaned up using the promotevvcopy command
	or by issuing a new instance of the promotesv command. This option cannot be used in conjunction with any other option.    
.PARAMETER PRI
	Specifies the priority of the copy operation when it is started. This option allows the user to control the overall speed of a particular task.  
	If this option is not specified, the promotesv operation is started with default priority of medium. High priority indicates that the operation 
	will complete faster. Low priority indicates that the operation will run slower than the default priority task. This option cannot be used with -halt option.    
.PARAMETER Online
	Indicates that the promote operation will be executed while the target volume has VLUN exports. The host should take the target LUN offline to
	initiate the promote command, but can bring it online and use it during the background task. The specified virtual copy and its base volume must
	be the same size. The base volume is the only possible target of online promote, and is the default. To halt a promote started with the online
	option, use the canceltask command. The -halt, -target, and -pri options cannot be combined with the -online option.
.EXAMPLE
	PS:> Push-A9SnapVolume -name vv1 
	
	copies the differences of a snapshot back to its base volume "vv1"
.EXAMPLE
	PS:> Push-A9SnapVolume -target vv23 -name vv1 
	
	copies the differences of a snapshot back to target volume "vv23" of volume "vv1"
.NOTES
	This command utilizes the SSH command 'promotesv' 
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$name,
		[Parameter()]	[String]	$target,
		[Parameter()]	[switch]	$RCP,
		[Parameter()]	[switch]	$Halt,
		[Parameter()]	[String]	$PRI,
		[Parameter()]	[switch]	$Online
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$promoCmd = "promotesv"	
	if($target)
		{	$promoCmd += " -target $target "		
		}
	if ($RCP)	{	$promoCmd += " -rcp "	}
	if ($Halt) 	{	$promoCmd += " -halt "	}
	if ($PRI) 	{	$promoCmd += " -pri $PRI "	}
	if ($Online){	$promoCmd += " -online "	}
	if ($name) 	
		{	$promoCmd += " $name "
			$result = Invoke-A9CLICommand -cmds  $promoCmd
			write-verbose " Promoting Snapshot Volume Name $vvName with the command --> $promoCmd" 
			Return $result
		}		
	else{	write-Verbose "No vvName specified to Promote snapshot " 
			return
		}
}
}

Function Push-A9VvCopy
{
<#
.SYNOPSIS
    Promotes a physical copy back to a regular base volume
.DESCRIPTION
	Promotes a physical copy back to a regular base volume
.PARAMETER physicalCopyName 
    Specifies the name of the physical copy to be promoted.
.EXAMPLE
    PS:> Push-A9VvCopy –physicalCopyName volume1
	
	Promotes virtual volume "volume1" to a base volume
.NOTES
	This command utilizes the SSH command 'promotevvcopy' 
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$physicalCopyName
	)		
Begin
{	Test-A9Connection -ClientType 'SshClient' 	
}
Process
{	$promotevvcopycmd = "promotevvcopy $physicalCopyName"
	$Result3 = Invoke-A9CLICommand -cmds  $promotevvcopycmd		
	write-verbose " Promoting Physical volume with the command --> $promotevvcopycmd"
	if( $Result3 -match "not a physical copy")
		{	return "FAILURE : $Result3"
		}
	elseif($Result3 -match "FAILURE")
		{	return "FAILURE : $Result3"
		}
	else
		{	return $Result3
		}
}
}

Function Set-A9VvSnapshot
{
<#
.SYNOPSIS
    Updates a snapshot Virtual Volume (VV) with a new snapshot.
.DESCRIPTION
	Updates a snapshot Virtual Volume (VV) with a new snapshot.
.PARAMETER Name 
    Specifies the name(s) of the snapshot virtual volume(s) or virtual volume set(s) to be updated.
.PARAMETER RO 
    Specifies that if the specified VV (<VV_name>) is a read/write snapshot the snapshot’s read-only
	parent volume is also updated with a new snapshot if the parent volume is not a member of a
	virtual volume set
.EXAMPLE
    PS:> Set-A9VvSnapshot -Name volume1 
	snapshot update of snapshot VV "volume1"
.EXAMPLE
    PS:> Set-A9VvSnapshot -Name volume1,volume2 -
	snapshot update of snapshot VV's "volume1" and "volume2"
.EXAMPLE
    PS:> Set-A9VvSnapshot -Name set:vvset1 
	snapshot update of snapshot VVSet "vvset1"
.EXAMPLE
    PS:> Set-A9VvSnapshot -Name set:vvset1,set:vvset2 
	snapshot update of snapshot VVSet's "vvset1" and "vvset2"
.EXAMPLE	
	PS:> Set-A9VvSnapshot -Name as2 -RO
.EXAMPLE	
	PS:> Set-A9VvSnapshot -Name as2 -RemoveAndRecreate 
.NOTES
	This command utilizes the SSH command 'updatevv' 
	This command requires a SSH type connection. 
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$Name,		
		[Parameter()]	[switch]	$RemoveAndRecreate,
		[Parameter()]	[switch]	$RO	        
	)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$updatevvcmd="updatevv -f "
	if($RO)	{	$updatevvcmd += " -ro "	}
	if($RemoveAndRecreate)	{	$updatevvcmd += " -removeandrecreate  "	}
	$vvtempnames = $Name.split(",")
	$limit = $vvtempnames.Length - 1
	foreach ($i in 0..$limit)
		{	if ( $vvtempnames[$i] -match "^set:")	
				{	$objName = $vvtempnames[$i].Split(':')[1]
					$vvsetName = $objName
					$objType = "vv set"
				}				
			else{	$subcmd = $vvtempnames[$i]
				}
		}		
	$updatevvcmd += " $vvtempnames "
	$Result1 = Invoke-A9CLICommand -cmds  $updatevvcmd
	write-verbose " updating a snapshot Virtual Volume (VV) with a new snapshot using--> $updatevvcmd" 
	return $Result1						
}
}
