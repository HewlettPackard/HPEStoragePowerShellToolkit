## 	©2025 Hewlett Packard Enterprise Development LP

Function Set-A9VolumeCopy
{
<#
.SYNOPSIS
    Updates a snapshot Virtual Volume (VV) with a new snapshot -or -
	Promotes a physical copy back to a regular base volume -or- 
.DESCRIPTION
	Updates a snapshot Virtual Volume (VV) with a new snapshot.
.PARAMETER Name 
    Specifies the name(s) of the snapshot virtual volume(s) or virtual volume set(s) to be updated.
.PARAMETER RO 
    Specifies that if the specified VV (<VV_name>) is a read/write snapshot the snapshot’s read-only
	parent volume is also updated with a new snapshot if the parent volume is not a member of a
	virtual volume set
.PARAMETER physicalCopyName 
    Specifies the name of the physical copy to be promoted.
.PARAMETER UpdateVolume	
	This will ensure that the underlying UpdateVV SSL commnad is used and will update a snapshot virtual volume with a new snapshot
.PARAMETER PromoteVolume
	This will ensure that the underlying PromoteGroupSV SSL command is used and will copy
.EXAMPLE
    PS:> Set-A9VolumeSnapshot -updatevolume -volume volume1 
	snapshot update of snapshot VV "volume1"
.NOTES
	This command utilizes the SSH command 'updatevv', 'promotevv' 
	This command requires a SSH type connection. 
#>
[CmdletBinding()]
param(	[Parameter(Mandatory, ParameterSetName='updatevv')]			[switch]	$UpdateVolume,
		[Parameter(Mandatory, ParameterSetName='promotevv')]		[switch]	$PromoteVolume,
		[Parameter(Mandatory, ParameterSetName='updatevv')]	
		[Parameter(Mandatory, ParameterSetName='promotevsv')]		[String]	$Volume,
		[Parameter(ParameterSetName='updatevv')]					[switch]	$RemoveAndRecreate,
		[Parameter(ParameterSetName='updatevv')]					[switch]	$RO	,  
		[Parameter(ParameterSetName='promotevv')]					[string]	$PhysicalCopyName
	)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	switch ($PSCmdlet.ParameterSetName)
		{	'updatevv'
				{	$updatevvcmd="updatevv -f "
					if($RO)	{	$updatevvcmd += " -ro "	}
					if($RemoveAndRecreate)	{	$updatevvcmd += " -removeandrecreate  "	}
					$vvtempnames = $Volume.split(",")
					$limit = $vvtempnames.Length - 1
					foreach ( $i in 0..$limit )
						{	if ( $vvtempnames[$i] -match "^set:")	
								{	$objName = $vvtempnames[$i].Split(':')[1]
									$vvsetName = $objName
									$objType = "vv set"
								}				
							else{	$subcmd = $vvtempnames[$i]
								}
						}		
					$updatevvcmd += " $vvtempnames "
					$Result = Invoke-A9CLICommand -cmds  $updatevvcmd
					write-verbose " updating a snapshot Virtual Volume (VV) with a new snapshot using--> $updatevvcmd" 
				}
			'promotevv'
				{	$promotevvcopycmd = "promotevvcopy $physicalCopyName"
					$Result = Invoke-A9CLICommand -cmds  $promotevvcopycmd		
					write-verbose " Promoting Physical volume with the command --> $promotevvcopycmd"
					if( $Result -match "not a physical copy")
						{	return "FAILURE : $Result"
						}
					elseif($Result -match "FAILURE")
						{	return "FAILURE : $Result"
						}
				}
		}	
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	Return $result				
}
}

Function Set-A9VolumeSnapshot
{
<#
.SYNOPSIS
    Updates a snapshot Virtual Volume (VV) with a new snapshot -or -
	Copies the differences of snapshots back to their base volumes.
.DESCRIPTION
	Updates a snapshot Virtual Volume (VV) with a new snapshot.
.PARAMETER Volume 
    Specifies the name(s) of the snapshot virtual volume(s) or virtual volume set(s) to be updated.
.PARAMETER Target
    Target Volume Name
.PARAMETER RCP 
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been
	started. If the Remote Copy group has been started, this command fails. This option cannot be used in conjunction with the -halt option.
.PARAMETER Halt 
    Cancels ongoing snapshot promotions. Marks the RW parent volumes with the "cpf" status that can be cleaned up using the promotevvcopy command
	or by issuing a new instance of the promotesv/promotegroupsv command. This option cannot be used in conjunction with any other option.
.PARAMETER Priority 
    Specifies the priority of the copy operation when it is started. This option allows the user to control the overall speed of a particular
	task.  If this option is not specified, the promotegroupsv operation is started with default priority of medium. High priority indicates that
	the operation will complete faster. Low priority indicates that the operation will run slower than the default priority task. This option
	cannot be used with -halt option.
.PARAMETER Online 
    Indicates that the promote operation will be executed while the target volumes have VLUN exports. The hosts should take the target LUNs offline
	to initiate the promote command, but can be brought online and used during the background tasks. Each specified virtual copy and its base
	volume must be the same size. The base volume is the only possible target of online promote, and is the default. To halt a promote started
	with the online option, use the canceltask command. The -halt, -target, and -pri options cannot be combined with the -online option.
.PARAMETER PromoteSnapVolume
	This will ensure that the underlying PromoteSV SSL command is used and will copy the differences of a snapshot back to its base volume, 
	allowing you to revert the base volume to an earlier point in time.
.PARAMETER PromoteGroupSnapVolume
	This will ensure that the underlying PromoteGroupSV SSL command is used and will copy the differences of snapshots back to their base volumes, 
	allowing you to revert the base volumes to an earlier point in time.
.EXAMPLE
    PS:> Set-A9VolumeSnapshot -updatevolume -volume volume1 
	snapshot update of snapshot VV "volume1"
.NOTES
	This command utilizes the SSH command 'promotegroupsv', ''promotesv' 
	This command requires a SSH type connection. 
#>
[CmdletBinding()]
param(	[Parameter(Mandatory, ParameterSetName='promotesv')]		[switch]	$PromoteSnapVolume,
		[Parameter(Mandatory, ParameterSetName='promotegroupsv')]	[switch]	$PromoteGroupSnapVolume,
		[Parameter(Mandatory, ParameterSetName='promotesv')]
		[Parameter(Mandatory, ParameterSetName='promotegroupsv')]	[String]	$Volume,
		[Parameter(ParameterSetName='promotegroupsv')]	
		[Parameter(ParameterSetName='promotesv')]					[String]	$Target,
		[Parameter(ParameterSetName='promotegroupsv')]	
		[Parameter(ParameterSetName='promotesv')]					[switch]	$RCP,
		[Parameter(ParameterSetName='promotegroupsv')]	
		[Parameter(ParameterSetName='promotesv')]					[switch]	$Halt,
		[Parameter(ParameterSetName='promotegroupsv')]			
		[Parameter(ParameterSetName='promotesv')]
		[ValidateSet('high','med','low')]							[String]	$Priority,
		[Parameter(ParameterSetName='promotegroupsv')]	
		[Parameter(ParameterSetName='promotevsv')]					[switch]	$Online
	)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	switch ($PSCmdlet.ParameterSetName)
		{	'promotesv'
				{	$promoCmd = "promotesv"	
					if ( $target )	{	$promoCmd += " -target $target"		}
					if ( $RCP )		{	$promoCmd += " -rcp"				}
					if ( $Halt ) 	{	$promoCmd += " -halt"				}
					if ( $Priority ){	$promoCmd += " -pri $Priority"		}
					if ( $Online )	{	$promoCmd += " -online "			}
					$promoCmd += " $Volume "
					$result = Invoke-A9CLICommand -cmds $promoCmd
					write-verbose " Promoting Snapshot Volume Name $Volume with the command --> $promoCmd" 
				}
			'promotegroupsv'
				{	$PromoteCmd = "promotegroupsv " 	
					if ( $RCP )			{	$PromoteCmd += " -rcp"				}
					if ( $Halt )		{	$PromoteCmd += " -halt"				}
					if ( $Priority )	{	$PromoteCmd += " -pri $Priority"	}
					if ( $Online )		{	$PromoteCmd += " -online"			}
					if ( $Volume )		{	$PromoteCmd += " $Volume"			}
					if ( $Target )		{	$PromoteCmd += ":" + "$Target "		}
					$result = Invoke-A9CLICommand -cmds  $PromoteCmd
					if( -not ($result -match "has been started to promote virtual copy") )
						{	if($result -match "Error: Base volume may not be promoted")
								{	return "FAILURE : While Executing  `Error: Base volume may not be promoted"
								}
							elseif($result -match "has exports defined")
								{	return "FAILURE : While Executing  `n $result"
								}
							else{	return "FAILURE : While Executing  `n $result"
								}
						}	
				}
		}	
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	Return $result				
}
}
