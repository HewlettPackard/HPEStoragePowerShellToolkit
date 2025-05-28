####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function New-A9GroupSnapVolume_CLI
{
<#
.SYNOPSIS
    creates consistent group snapshots
.DESCRIPTION
	creates consistent group snapshots
.PARAMETER vvNames 
    Specify the Existing virtual volume with comma(,) seperation ex: vv1,vv2,vv3.
.PARAMETER OR
	-or
.PARAMETER Comment 	
	Specifies any additional information up to 511 characters for the volume.
.PARAMETER exp 
	Specifies the relative time from the current time that volume will expire. <time>[d|D|h|H] <time> is a positive integer value and in the range of 1 - 43,800 hours (1,825 days).
	Time can be optionally specified in days or hours providing either d or D for day and h or H for hours following the entered time value.
.PARAMETER retain
	Specifies the amount of time, relative to the current time, that the volume will be retained.-retain <time>[d|D|h|H] <time> is a positive integer value and in the range of 1 - 43,800 hours (1,825 days). 
	Time can be optionally specified in days or hours providing either d or D for day and h or H for hours following the entered time value.
.PARAMETER Match
	By default, all snapshots are created read-write. The -ro option instead specifies that all snapshots created will be read-only.
	The -match option specifies that snapshots are created matching each parent's read-only or read-write setting. The -ro and -match
	options cannot be combined. Either of these options can be overridden for an individual snapshot VV in the colon separated specifiers.
.EXAMPLE
	PS:> New-A9GroupSnapVolume_CLI
.EXAMPLE
	PS:> New-A9GroupSnapVolume_CLI -vvNames WSDS_compr02F
.EXAMPLE
	PS:> New-A9GroupSnapVolume_CLI -vvNames WSDS_compr02F -exp 2d
.EXAMPLE
	PS:> New-A9GroupSnapVolume_CLI -vvNames WSDS_compr02F -retain 2d
.EXAMPLE
	PS:> New-A9GroupSnapVolume_CLI -vvNames WSDS_compr02F -Comment Hello
.EXAMPLE
	PS:> New-A9GroupSnapVolume_CLI -vvNames WSDS_compr02F -OR
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$vvNames,
		[Parameter()]	[switch]	$OR, 
		[Parameter()]	[String]	$exp,
		[Parameter()]	[String]	$retain,
		[Parameter()]	[String]	$Comment,
		[Parameter()]	[switch]	$Match
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
Process
{	$CreateGSVCmd = "creategroupsv" 
	if($exp)		{	$CreateGSVCmd += " -exp $exp "}
	if($retain)		{	$CreateGSVCmd += " -f -retain $retain "}		
	if($Comment)	{	$CreateGSVCmd += " -comment $Comment "	}
	if($OR)			{	$CreateGSVCmd += " -ro "}
	if($Match)		{	$CreateGSVCmd += " -match "	}
	$vvName1 = $vvNames.Split(',')
	$limit = $vvName1.Length - 1
	foreach($i in 0..$limit)
		{	if ( !( Test-A9CLIObject -objectType 'vv' -objectName $vvName1[$i] ))
				{	write-verbose " VV $vvName1[$i] does not exist. Please use New-VV to create a VV before creating GroupSnapVolume" 
					return "FAILURE : No vv $vvName1[$i] found"
				}
		}
	$CreateGSVCmd += " $vvName1 "	
	write-verbose "Executing the following SSH command `n`t $cmd"
	$result1 = Invoke-A9CLICommand -cmds  $CreateGSVCmd
	write-verbose " Creating Snapshot Name with the command --> $CreateGSVCmd"
	if($result1 -match "CopyOfVV")
		{	return "Success : Executing  `n $result1"
		}
	else
		{	return "FAILURE : Executing  `n $result1"
		}		
}
}

Function New-A9GroupVvCopy_CLI
{
<#
.SYNOPSIS
    Creates consistent group physical copies of a list of virtualvolumes.
.DESCRIPTION
	Creates consistent group physical copies of a list of virtualvolumes.
.PARAMETER parent_VV 
    Indicates the parent virtual volume.
.PARAMETER destination_VV
	Indicates the destination virtual volume. 
.PARAMETER destination_cpg
	Specifies the destination CPG to use for the destination volume if the -online option is specified.
.PARAMETER VV_name
    Specifies the virtual volume name to use for the destination volume if the -online option is specified.
.PARAMETER wwn
    Specifies the WWN to use for the destination volume if the -online option is specified.
.PARAMETER P
	Starts a copy operation from the specified parent volume (as indicated using the <parent_VV> specifier) to its destination volume (as indicated
	using the <destination_VV> specifier).
.PARAMETER  R
	Resynchronizes the set of destination volumes (as indicated using the <destination_VV> specifier) with their respective parents using saved
	snapshots so that only the changes made since the last copy or resynchronization are copied. 
.PARAMETER Halt
	Cancels an ongoing physical copy. 
.PARAMETER S
	Saves snapshots of the parent volume (as indicated with the <parent_VV> specifier) for quick resynchronization and to retain the parent-copy
	relationships between each parent and destination volume. 
.PARAMETER B
	Use this specifier to block until all the copies are complete. Without this option, the command completes before the copy operations are
	completed (use the showvv command to check the status of the copy operations).
.PARAMETER Priority <high|med|low>
	Specifies the priority of the copy operation when it is started. This option allows the user to control the overall speed of a particular task.
	If this option is not specified, the creategroupvvcopy operation is started with default priority of medium. High priority indicates that
	the operation will complete faster. Low priority indicates that the operation will run slower than the default priority task. This option
	cannot be used with -halt option.
.PARAMETER Online
	Specifies that the copy is to be performed online. 
.PARAMETER Skip_zero
	When copying from a thin provisioned source, only copy allocated portions of the source VV.
.PARAMETER TPVV
	Indicates that the VV the online copy creates should be a thinly provisioned volume. Cannot be used with the -dedup option.
.PARAMETER TdVV
	This option is deprecated, see -dedup.
.PARAMETER Dedup
	Indicates that the VV the online copy creates should be a thinly deduplicated volume, which is a thinly provisioned volume with inline data deduplication. 
	This option can only be used with a CPG that has SSD (Solid State Drive) device type. Cannot be used with the -tpvv option.
.PARAMETER Compressed
	Indicates that the VV the online copy creates should be a compressed virtual volume.    
.EXAMPLE
    PS:> New-A9GroupVvCopy_CLI -P -parent_VV ZZZ -destination_VV ZZZ 
.EXAMPLE
    PS:> New-A9GroupVvCopy_CLI -P -Online -parent_VV ZZZ -destination_cpg ZZZ -VV_name ZZZ -wwn 123456
.EXAMPLE
    PS:> New-A9GroupVvCopy_CLI -R -destination_VV ZZZ
.EXAMPLE
    PS:> New-A9GroupVvCopy_CLI -Halt -destination_VV ZZZ
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]		[String]		$parent_VV,
		[Parameter()]		[String]		$destination_VV,
		[Parameter()]		[String]		$destination_cpg,
		[Parameter()]		[String]		$VV_name,
		[Parameter()]		[String]		$wwn,
		[Parameter()]		[Switch]		$P,
		[Parameter()]		[Switch]		$R,
		[Parameter()]		[Switch]		$Halt,
		[Parameter()]		[Switch]		$S,
		[Parameter()]		[Switch]		$B,
		[Parameter()]		[String]		$Priority,
		[Parameter()]		[Switch]		$Skip_zero,
		[Parameter()]		[Switch]		$Online,
		[Parameter()]		[Switch]		$TPVV,
		[Parameter()]		[Switch]		$TdVV,
		[Parameter()]		[Switch]		$Dedup,
		[Parameter()]		[Switch]		$Compressed
)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$groupvvcopycmd = "creategroupvvcopy "		
	if($P)			{	$groupvvcopycmd += " -p "				}
	elseif($R)		{	$groupvvcopycmd += " -r "				}
	elseif($Halt)	{	$groupvvcopycmd += " -halt "			}
	else			{	return "Select At least One from P R or Halt"	}	
	if($S)			{	$groupvvcopycmd += " -s "				}
	if($B)			{	$groupvvcopycmd += " -b "				}
	if($Priority)	{	$groupvvcopycmd += " -pri $Priority "	}
	if($Skip_zero)	{	$groupvvcopycmd += " -skip_zero "		}
	if($Online)		{	$groupvvcopycmd += " -online "
						if($TPVV)	{	$groupvvcopycmd += " -tpvv "	}
						if($TdVV)	{	$groupvvcopycmd += " -tdvv "	}
						if($Dedup)	{	$groupvvcopycmd += " -dedup "	}
						if($Compressed){$groupvvcopycmd += " -compr "	}								
					}
	if($parent_VV)	{	$groupvvcopycmd += " $parent_VV"
						$groupvvcopycmd += ":"
					}
	if($destination_VV){$groupvvcopycmd += "$destination_VV"}
	if($destination_cpg)
					{	$groupvvcopycmd += "$destination_cpg"
						$groupvvcopycmd += ":"
					}
	if($VV_name)	{	$groupvvcopycmd += "$VV_name"		}
	if($wwn)		{	$groupvvcopycmd += ":"
						$groupvvcopycmd += "$wwn"
					}	
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result1 = Invoke-A9CLICommand -cmds  $groupvvcopycmd
	write-verbose " Creating consistent group fo Virtual copies with the command --> $groupvvcopycmd"
	if ($Result1 -match "TaskID")	{	$outmessage += "Success : `n $Result1"	}
	else							{	$outmessage += "FAILURE : `n $Result1"	}
	return $outmessage
}
}

Function New-A9SnapVolume_CLI
{
<#
.SYNOPSIS
    creates a point-in-time (snapshot) copy of a virtual volume.
.DESCRIPTION
	creates a point-in-time (snapshot) copy of a virtual volume.
.PARAMETER svName 
    Specify  the name of the Snap shot	
.PARAMETER vvName 
    Specifies the parent volume name. Either a Volume Set (vvSetName) or a volume name (vvName) must be specified. 
.PARAMETER vvSetName 
    Specifies the virtual volume set names as set: vvset name example: "set:vvcopies" 
.PARAMETER Comment 
    Specifies any additional information up to 511 characters for the volume. 
.PARAMETER VV_ID 
    Specifies the ID of the copied VV set. This option cannot be used when VV set is specified. 
.PARAMETER Rcopy 
    Specifies that synchronous snapshots be taken of a volume in a remote copy group. 
.PARAMETER exp 
    Specifies the relative time from the current time that volume will expire.-exp <time>[d|D|h|H] <time> is a positive integer value and in the range of 1 - 43,800 hours (1,825 days). 
	Time can be optionally specified in days or hours providing either d or D for day and h or H for hours following the entered time value. 
.PARAMETER retain
	Specifies the amount of time, relative to the current time, that the volume will be retained. <time> is a positive integer value and in the range of 1 - 43,800 hours (1,825 days). 
	Time can be optionally specified in days or hours providing either d or D for day and h or H for hours following the entered time value.
.PARAMETER ro
	Specifies that the copied volume is read-only. If not specified, the volume is read/write.	
.EXAMPLE
	PS:> New-A9SnapVolume_CLI -svName svr0_vv0 -vvName vv0 
	
	Ceates a read-only snapshot volume "svro_vv0" from volume "vv0" 
.EXAMPLE
	PS:> New-A9SnapVolume_CLI -svName svr0_vv0 -vvName vv0 -ro -exp 25H

	Ceates a read-only snapshot volume "svro_vv0" from volume "vv0" and that will expire after 25 hours
.EXAMPLE
	PS:> New-A9SnapVolume_CLI -svName svrw_vv0 -vvName svro_vv0
	
	creates snapshot volume "svrw_vv0" from the snapshot "svro_vv0"
.EXAMPLE
	PS:> New-A9SnapVolume_CLI -ro svName svro-@vvname@ -vvSetName set:vvcopies 
	
	creates a snapshot volume for each member of the VV set "vvcopies". Each snapshot will be named svro-<name of parent virtual volume>:
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='vv')]
param(	[Parameter(Mandatory)]							[String]	$svName,			
		[Parameter(ParameterSetName="vv", Mandatory)]	[String]	$vvName,
		[Parameter(ParameterSetName="vvId",Mandatory)]	[String]	$VV_ID,
		[Parameter()]									[String]	$exp,
		[Parameter()]									[String]	$retain,
		[Parameter()]									[switch]	$ro, 
		[Parameter()]									[switch]	$Rcopy,
		[Parameter(ParameterSetName="set",Mandatory)]	[String]	$vvSetName,	
		[Parameter()]									[String]	$Comment
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	if ($vvName)
		{	if ( !( Test-A9CLIObject -objectType 'vv' -objectName $vvName ))
				{	write-verbose " VV $vvName does not exist. Please use New-VV to create a VV before creating SV" 
					return "FAILURE :  No vv $vvName found"
				}
			$CreateSVCmd = "createsv" 
			if($ro)		{	$CreateSVCmd += " -ro "	}
			if($Rcopy)	{	$CreateSVCmd += " -rcopy "	}
			if($VV_ID)	{	$CreateSVCmd += " -i $VV_ID "	}
			if($exp)	{	$CreateSVCmd += " -exp $exp "	}
			if($retain)	{	$CreateSVCmd += " -f -retain $retain  "	}
			if($Comment){	$CreateSVCmd += " -comment $Comment  "	}
			$CreateSVCmd +=" $svName $vvName "
			write-verbose "Executing the following SSH command `n`t $CreateSVcmd"
			$result1 = Invoke-A9CLICommand -cmds  $CreateSVCmd
			write-verbose " Creating Snapshot Name $svName with the command --> $CreateSVCmd"
			if([string]::IsNullOrEmpty($result1))
				{	return  "Success : Created virtual copy $svName"
				}
			else
				{	return  "FAILURE : While creating virtual copy $svName $result1"
				}		
		}
	elseif ($vvSetName)
		{	if ( $vvSetName -match "^set:")	
				{	$objName = $vvSetName.Split(':')[1]
					$objType = "vv set"
					if ( ! (Test-A9CLIObject -objectType $objType -objectName $objName ))
						{	Write-Verboose " VV set $vvSetName does not exist. Please use New-VVSet to create a VVSet before creating SV"
							return "FAILURE : No vvset $vvsetName found"
						}
					$CreateSVCmdset = "createsv" 
					if($ro)		{	$CreateSVCmdset += " -ro "	}
					if($Rcopy)	{	$CreateSVCmdset += " -rcopy "}
					if($exp)	{	$CreateSVCmdset += " -exp $exp "}
					if($retain)	{	$CreateSVCmdset += " -f -retain $retain  "	}
					if($Comment){	$CreateSVCmdset += " -comment $Comment  "	}
					$CreateSVCmdset +=" $svName $vvSetName "
					$result2 = Invoke-A9CLICommand -cmds  $CreateSVCmdset
					write-verbose " Creating Snapshot Name $svName with the command --> $CreateSVCmdset" 	
					if([string]::IsNullOrEmpty($result2))	{	return  "Success : Created virtual copy $svName"	}
					elseif($result2 -match "use by volume")	{	return "FAILURE : While creating virtual copy $result2"	}
					else									{	return  "FAILURE : While creating virtual copy $svName $result2"	}
				}
			else	{	return "VV Set name must contain set:"	}
		}
}
}

Function New-A9VvCopy_CLI
{
<#
.SYNOPSIS
    Creates a full physical copy of a Virtual Volume (VV) or a read/write virtual copy on another VV.
.DESCRIPTION
	Creates a full physical copy of a Virtual Volume (VV) or a read/write virtual copy on another VV.
.PARAMETER parentName 
    Specify name of the parent Virtual Volume
.PARAMETER Online 
    Create an online copy of Virtual Volume
.PARAMETER vvCopyName 
    Specify name of the virtual Volume Copy name
.PARAMETER CPGName
    Specify the name of CPG
.PARAMETER snapcpg
	Specifies the name of the CPG from which the snapshot space will be allocated
.PARAMETER Tpvv
	Indicates that the VV the online copy creates should be a thinly provisioned volume. Cannot be used with the -dedup option.
.PARAMETER Tdvv
	This option is deprecated, see -dedup.
.PARAMETER Dedup
	Indicates that the VV the online copy creates should be a thinly deduplicated volume, which is a thinly provisioned volume with inline
	data deduplication. This option can only be used with a CPG that has SSD (Solid State Drive) device type. Cannot be used with the -tpvv option.
.PARAMETER Compr
	Indicates that the VV the online copy creates should be a compressed virtual volume.
.PARAMETER AddToSet 
	Adds the VV copies to the specified VV set. The set will be created if it does not exist. Can only be used with -online option.
.PARAMETER R
	Specifies that the destination volume be re-synchronized with its parent volume using a saved snapshot so that only the changes since the last
	copy or resynchronization need to be copied.
.PARAMETER Halt
	Specifies that an ongoing physical copy to be stopped. This will cause the destination volume to be marked with the 'cpf' status, which will be
	cleared up when a new copy is started.
.PARAMETER Save
	Saves the snapshot of the source volume after the copy of the volume is completed. This enables a fast copy for the next resynchronization. If
	not specified, the snapshot is deleted and the association of the destination volume as a copy of the source volume is removed.  The -s
	option is implied when the -r option is used and need not be explicitly specified.
.PARAMETER Blocks
	Specifies that this command blocks until the operation is completed. If not specified, the createvvcopy command operation is started as a
	background task.
.PARAMETER priority
	Specifies the priority of the copy operation when it is started. This option allows the user to control the overall speed of a particular
	task.  If this option is not specified, the createvvcopy operation is started with default priority of medium. High priority indicates that
	the operation will complete faster. Low priority indicates that the operation will run slower than the default priority task. This option
	cannot be used with -halt option.
.EXAMPLE
    PS:> New-A9VvCopy_CLI -parentName VV1 -vvCopyName VV2
.EXAMPLE		
	PS:> New-A9VvCopy_CLI -parentName VV1 -vvCopyName VV2 -online -CPGName ZZZ
.EXAMPLE
	PS:> New-A9VvCopy_CLI -parentName as1 -vvCopyName as3 -online -CPGName asCpg -Tpvv
.EXAMPLE
	PS:> New-A9VvCopy_CLI -parentName as1 -vvCopyName as3  -Tdvv
.EXAMPLE
	PS:> New-A9VvCopy_CLI -parentName as1 -vvCopyName as3  -Dedup
.EXAMPLE
	PS:> New-A9VvCopy_CLI -parentName as1 -vvCopyName as3  -Compr
.EXAMPLE
	PS:> New-A9VvCopy_CLI -parentName as1 -vvCopyName as3  -AddToSet
.EXAMPLE
	PS:> New-A9VvCopy_CLI -parentName as1 -vvCopyName as3 -Priority med
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$parentName,		
		[Parameter(Mandatory)]	[String]	$vvCopyName,
		[Parameter()]	[switch]    $online,
		[Parameter()]	[String]    $CPGName,		
		[Parameter()]	[String]    $snapcpg,
		[Parameter()]	[switch]	$Tpvv,
		[Parameter()]	[switch]	$Tdvv,
		[Parameter()]	[switch]	$Dedup,
		[Parameter()]	[switch]	$Compr,
		[Parameter()]	[switch]	$AddToSet,
		[Parameter()]	[switch]    $R,
		[Parameter()]	[switch]    $Halt,
		[Parameter()]	[switch]    $Saves,
		[Parameter()]	[switch]    $Blocks,
		[Parameter()]
		[ValidateSet('high','med','low')]	[String]    $Priority
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	if ( $parentName -match "^set:")	
		{	$objName = $item.Split(':')[1]
			$vvsetName = $objName
			$objType = "vv set"
			#$objMsg  = $objType
			if(!( Test-A9CLIObject -objectType $objType  -objectName $vvsetName ))
				{	write-verbose " vvset $vvsetName does not exist. Please use New-VvSet to create a new vvset " 
					return "FAILURE : No vvset $vvSetName found"
				}
		}
	else
		{	if(!( Test-A9CLIObject -objectType "vv"  -objectName $parentName ))
				{	write-verbose " vv $parentName does not exist. Please use New-Vv to create a new vv " 
					return "FAILURE : No parent VV  $parentName found"
				}
		}
	if($online)
		{	if(!( Test-A9CLIObject -objectType 'cpg' -objectName $CPGName ))
				{	write-verbose " CPG $CPGName does not exist. Please use New-CPG to create a CPG " 
					return "FAILURE : No cpg $CPGName found"
				}		
			if( Test-A9CLIObject -objectType 'vv' -objectName $vvCopyName )
				{	write-verbose " vv $vvCopyName is exist. For online option vv should not be exists..." 
				}		
			$vvcopycmd = "createvvcopy -p $parentName -online "
			if($snapcpg)
				{	if(!( Test-A9CLIObject -objectType 'cpg' -objectName $snapcpg ))
						{	write-verbose " Snapshot CPG $snapcpg does not exist. Please use New-CPG to create a CPG " 
							return "FAILURE : No snapshot cpg $snapcpg found"
						}
					$vvcopycmd += " -snp_cpg $snapcpg"
				}
			if($Tpvv)	{	$vvcopycmd += " -tpvv "	}
			if($Tdvv)	{	$vvcopycmd += " -tdvv "	}
			if($Dedup)	{	$vvcopycmd += " -dedup "}
			if($Compr)	{	$vvcopycmd += " -compr "}
			if($AddToSet){	$vvcopycmd += " -addtoset "	}
			if($Halt)	{	$vvcopycmd += " -halt "	}
			if($Saves)	{	$vvcopycmd += " -s "	}
			if($Blocks)	{	$vvcopycmd += " -b "	}
			if($Priority){	$vvcopycmd += " -pri $Priority "}
			if($CPGName){	$vvcopycmd += " $CPGName "}
			$vvcopycmd += " $vvCopyName"
			$Result4 = Invoke-A9CLICommand -cmds  $vvcopycmd
			write-verbose " Creating online vv copy with the command --> $vvcopycmd" 
			if($Result4 -match "Copy was started.")	{	return "Success : $Result4"	}
			else									{	return "FAILURE : $Result4"	}		
		}
	else
		{	$vvcopycmd = " createvvcopy "
			if($R)		{	$vvcopycmd += " -r"		}
			if($Halt)	{	$vvcopycmd += " -halt "	}
			if($Saves)	{	$vvcopycmd += " -s "	}
			if($Blocks)	{	$vvcopycmd += " -b "	}
			if($Priority){	$vvcopycmd += " -pri $Priority "}
			if( !(Test-A9CLIObject -objectType 'vv' -objectName $vvCopyName))
				{	write-verbose " vv $vvCopyName does not exist.Please speicify existing vv name..." 
					return "FAILURE : No vv $vvCopyName found"
				}
			$vvcopycmd += " -p $parentName $vvCopyName"
			$Result3 = Invoke-A9CLICommand -cmds  $vvcopycmd
			write-verbose " Creating Virtual Copy with the command --> $vvcopycmd" 
			write-verbose " Check the task status using Get-Task command --> Get-Task "
			if($Result3 -match "Copy was started")	{	return "Success : $Result3"	}
			else									{	return "FAILURE : $Result3"	}
		}
}
}

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
		{	if ( !( Test-A9CLIObject -objectType 'vv' -objectName $target -SANConnection $SANConnection))
				{	write-verbose " VV $target does not exist. " 
					$promoCmd += " -target $target "
					return "FAILURE : No vv $target found"
				}
			$promoCmd += " -target $target "		
		}
	if ($RCP)	{	$promoCmd += " -rcp "	}
	if ($Halt) 	{	$promoCmd += " -halt "	}
	if ($PRI) 	{	$promoCmd += " -pri $PRI "	}
	if ($Online){	$promoCmd += " -online "	}
	if ($name) 	
		{	if ( !( Test-A9CLIObject -objectType 'vv' -objectName $name -SANConnection $SANConnection))
				{	write-verbose " VV $vvName does not exist. Please use New-Vv to create a VV before creating SV" 
					return "FAILURE : No vv $vvName found"
				}								
			$promoCmd += " $name "
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
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$physicalCopyName
	)		
Begin
{	Test-A9Connection -ClientType 'SshClient' 	
}
Process
{	if(!( Test-A9CLIObject -objectType "vv"  -objectName $physicalCopyName))
		{	write-verbose " vv $physicalCopyName does not exist. Please use New-Vv to create a new vv" 
			return "FAILURE : No vv $physicalCopyName found"
		}
	$promotevvcopycmd = "promotevvcopy $physicalCopyName"
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
					if(!( Test-A9CLIObject -objectType $objType  -objectName $vvsetName -SANConnection $SANConnection))
						{	write-verbose " vvset $vvsetName does not exist. Please use New-VvSet to create a new vvset " 
							return "FAILURE : No vvset $vvsetName found"
						}
				}				
			else{	$subcmd = $vvtempnames[$i]
					if(!( Test-A9CLIObject -objectType "vv"  -objectName $subcmd -SANConnection $SANConnection))
						{	write-verbose " vv $vvtempnames[$i] does not exist. Please use New-Vv to create a new vv" 
							return "FAILURE : No vv $subcmd found"
						}
				}
		}		
	$updatevvcmd += " $vvtempnames "
	$Result1 = Invoke-A9CLICommand -cmds  $updatevvcmd
	write-verbose " updating a snapshot Virtual Volume (VV) with a new snapshot using--> $updatevvcmd" 
	return $Result1						
}
}


# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDLpHLsAZIG
# FFBzg2CbTKyMlzT9nzvVatrDzl9/DAhPEIqUystCgyC0PHJgtljqRVSTANyceWv1
# 13sHKcjAYhuRoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG58wghubAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQJlMRQJP0i7muHGt5QV5uWNRy7q0qrv8248YKd1XoZCqGW3DcY9Cp/h5
# BTKjvL0KvO2uG9p1G9ph/8lQKhA76XIwDQYJKoZIhvcNAQEBBQAEggGAPpzLvRj8
# 0IJW4YjA7mtiV0+dEJIGOQ8EDeEFcbGmrNsfcT9IrZDKc8aPDloXaWDSAXSztUML
# tz1qX8OWAugAvs66+OPRZiZ+FBa+p69bkpFAkFfL/X/ijZcWHYhE3zqlTHTMH1Ry
# IaAEUAZIk5RxyJJOp5EJduILrN347C0dJBPj4ay+ePFbU70Mr1LNjanKDDKZO3hY
# U5zGncOjLhH22/n4gxm9rFWaGOQUymA5R4d9kz1a5szYLzLifz55WZ8fgc+LKA5c
# 6wSK7BKfLAn+w5lTAwVtPK7yZk8zMZ9wK0hkYLUfAxvWEmSS1z7lrZ5p5D+tqK6a
# M3nZHZ3bOcVTkkxgdHU1RtiEwOLyD+znVziKbsypXN1yAA8U1nsF2tg/u97RESqb
# AL/t1MnUHf8QZr+m8bSOnp/nd5yevkXmU+qG1NvYM5IULJGlrLyfnGKZptW4Tbng
# QWNjB6qhLBjyHVRchYRZ0A9G48kqADTiWjGd7Lutt/y1j/yLu4lq+/1YoYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMDS2Jvzde5klHT8ucmQDgZ3BnA2mda/I
# /Fb8klNj8M9WBxlnZWVlP/Mc/+CUPY8cWwIUQNMubKOawXn9d/xaDD1F1Bim+boY
# DzIwMjUwNTE1MDIyMjQwWqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
# c3QgWW9ya3NoaXJlMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMT
# J1NlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNqCCEwQwggZi
# MIIEyqADAgECAhEApCk7bh7d16c0CIetek63JDANBgkqhkiG9w0BAQwFADBVMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNTAzMjcwMDAw
# MDBaFw0zNjAzMjEyMzU5NTlaMHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5XZXN0
# IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzYwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDThJX0bqRTePI9EEt4Egc83JSBU2dhrJ+w
# Y7JgReuff5KQNhMuzVytzD+iXazATVPMHZpH/kkiMo1/vlAGFrYN2P7g0Q8oPEcR
# 3h0SftFNYxxMh+bj3ZNbbYjwt8f4DsSHPT+xp9zoFuw0HOMdO3sWeA1+F8mhg6uS
# 6BJpPwXQjNSHpVTCgd1gOmKWf12HSfSbnjl3kDm0kP3aIUAhsodBYZsJA1imWqkA
# VqwcGfvs6pbfs/0GE4BJ2aOnciKNiIV1wDRZAh7rS/O+uTQcb6JVzBVmPP63k5xc
# ZNzGo4DOTV+sM1nVrDycWEYS8bSS0lCSeclkTcPjQah9Xs7xbOBoCdmahSfg8Km8
# ffq8PhdoAXYKOI+wlaJj+PbEuwm6rHcm24jhqQfQyYbOUFTKWFe901VdyMC4gRwR
# Aq04FH2VTjBdCkhKts5Py7H73obMGrxN1uGgVyZho4FkqXA8/uk6nkzPH9QyHIED
# 3c9CGIJ098hU4Ig2xRjhTbengoncXUeo/cfpKXDeUcAKcuKUYRNdGDlf8WnwbyqU
# blj4zj1kQZSnZud5EtmjIdPLKce8UhKl5+EEJXQp1Fkc9y5Ivk4AZacGMCVG0e+w
# wGsjcAADRO7Wga89r/jJ56IDK773LdIsL3yANVvJKdeeS6OOEiH6hpq2yT+jJ/lH
# a9zEdqFqMwIDAQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNh
# lxmiMpswHQYDVR0OBBYEFIhhjKEqN2SBKGChmzHQjP0sAs5PMA4GA1UdDwEB/wQE
# AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1Ud
# IARDMEEwNQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8v
# Y3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5j
# cmwwegYIKwYBBQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYB
# BQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IB
# gQACgT6khnJRIfllqS49Uorh5ZvMSxNEk4SNsi7qvu+bNdcuknHgXIaZyqcVmhrV
# 3PHcmtQKt0blv/8t8DE4bL0+H0m2tgKElpUeu6wOH02BjCIYM6HLInbNHLf6R2qH
# C1SUsJ02MWNqRNIT6GQL0Xm3LW7E6hDZmR8jlYzhZcDdkdw0cHhXjbOLsmTeS0Se
# RJ1WJXEzqt25dbSOaaK7vVmkEVkOHsp16ez49Bc+Ayq/Oh2BAkSTFog43ldEKgHE
# DBbCIyba2E8O5lPNan+BQXOLuLMKYS3ikTcp/Qw63dxyDCfgqXYUhxBpXnmeSO/W
# A4NwdwP35lWNhmjIpNVZvhWoxDL+PxDdpph3+M5DroWGTc1ZuDa1iXmOFAK4iwTn
# lWDg3QNRsRa9cnG3FBBpVHnHOEQj4GMkrOHdNDTbonEeGvZ+4nSZXrwCW4Wv2qyG
# DBLlKk3kUW1pIScDCpm/chL6aUbnSsrtbepdtbCLiGanKVR/KC1gsR0tC6Q0RfWO
# I4owggYUMIID/KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUA
# MFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNV
# BAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AM2Y2ENBq26CK+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStS
# VjeYXIjfa3ajoW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQ
# BaCxpectRGhhnOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE
# 9cbY11XxM2AVZn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExS
# Lnh+va8WxTlA+uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OII
# q/fWlwBp6KNL19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGd
# F+z+Gyn9/CRezKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w
# 76kOLIaFVhf5sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4Cllg
# rwIDAQABo4IBXDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUw
# HQYDVR0OBBYEFF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjAS
# BgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28u
# Y29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEF
# BQcBAQRwMG4wRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0O
# NVgMnoEdJVj9TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc
# 6ZvIyHI5UkPCbXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1
# OSkkSivt51UlmJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz
# 2wSKr+nDO+Db8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y
# 4Il6ajTqV2ifikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVM
# CMPY2752LmESsRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBe
# Nh9AQO1gQrnh1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupia
# AeNHe0pWSGH2opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU
# +CCQaL0cJqlmnx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/Sjws
# usWRItFA3DE8MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7
# xpMeYRriWklUPsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs6
# 56Oz3TbLyXVoMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAs
# BgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJ
# BZvMWhUP2ZQQRLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQn
# Oh2qmcxGzjqemIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypo
# GJrruH/drCio28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0p
# KG9ki+PC6VEfzutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13j
# QEV1JnUTCm511n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9
# YrcmXcLgsrAimfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/y
# Vl4jnDcw6ULJsBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVg
# h60KmLmzXiqJc6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/
# OLoanEWP6Y52Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+Nr
# LedIxsE88WzKXqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58N
# Hs57ZPUfECcgJC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9U
# gOHYm8Cd8rIDZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1Ud
# DwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0
# eS5jcmwwNQYIKwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3
# OyWM637ayBeR7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJ
# JlFfym1Doi+4PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0m
# UGQHbRcF57olpfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTw
# bD/zIExAopoe3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i
# 111TW7HV1AtsQa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGe
# zjM6CRpcWed/ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+
# 8aW88WThRpv8lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH
# 29308ZkpKKdpkiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrs
# xrYJD+3f3aKg6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6
# Ii8+CQOYDwXM+yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz
# 7NgAnOgpCdUo4uDyllU9PzGCBJIwggSOAgEBMGowVTELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMg
# VGltZSBTdGFtcGluZyBDQSBSMzYCEQCkKTtuHt3XpzQIh616TrckMA0GCWCGSAFl
# AwQCAgUAoIIB+TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTI1MDUxNTAyMjI0MFowPwYJKoZIhvcNAQkEMTIEMJo8cC+HIxiONlAu
# AoY7pu+70V28groOPVKyM+Q4/O+qhS1Ikl33fEkzsF35Wq0mDjCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAXfDu+3o1ueMllT8OZZe4bLLFFxpv/Px5UwgXgE2IL7Fgmx6VehRni5x4
# t2xDNnavDXT1LKQLLWQzdumnMkd3FlzE50JlIhkmsSr5GwKJsJIQTYi+2z92Q8cp
# vT1BS/0PLP9fLwARjPx4KLv3PqgzKYM/Dq+DAGhAJ00TRgv9vxV93eG3MCzjcpIL
# 5ODuVMwLOY/vb92wAEC0Ws40CG2eMjomp5qDPiKZlccr6zQqb3Mk6dYaYzxJDvxm
# Cz+svC/GXpJYnwkXvW1xxuR1YRMRzmQTsvLqV58pe7w8vv6NqI4s96HpLdVluTeW
# 4CF5S7xKazQmt2o5XwylPZFshyOoeLjYq6Jmg1ohKwQLKPXhg15h1FzECkZlbaYn
# BFZIiyQsa+W5pP63xgrBAqmLrEyqQpMiUP44+xC/MT8rYUD9UpKo8O4aXZTPDu6u
# JLHZJBDU/yGw0xfdRdxS0KsVXgjXLMjgJlYEJA+7yGHars5m6L9OqFK9tYjoDqCU
# tSZFSgtMpQsU4YqazYitJgvfaPY9wS308onntzowL+R8fSz0m7sFJBODpdYSZ9Ez
# 7akedU2ZqgDiv8tUnMXmZKCk5+JZFKTZb1IiBC6JJgxu4YTu+wgha/pI+OAV4n4H
# csuTFgXgRL7ERylsHE54UpcA4ngdI4JCFsGfgOccTu8c6fmQGeA=
# SIG # End signature block
