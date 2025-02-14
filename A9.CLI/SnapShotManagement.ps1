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
param(	[Parameter(Mandatory=$true)]	[String]	$vvNames,
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
    Specifies the parent volume name or volume set name. 
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
[CmdletBinding()]
param(	[Parameter(ParameterSetName="set",Mandatory)]	[String]	$svName,			
		[Parameter(ParameterSetName="vv", Mandatory)]	[String]	$vvName,
		[Parameter()]	[String]	$VV_ID,
		[Parameter()]	[String]	$exp,
		[Parameter()]	[String]	$retain,
		[Parameter()]	[switch]	$ro, 
		[Parameter()]	[switch]	$Rcopy,
		[Parameter()]	[String]	$vvSetName,	
		[Parameter()]	[String]	$Comment
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

