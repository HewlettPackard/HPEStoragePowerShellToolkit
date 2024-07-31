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
.EXAMPLE
    PS:> New-A9GroupVvCopy_CLI -P -parent_VV ZZZ -destination_VV ZZZ 
.EXAMPLE
    PS:> New-A9GroupVvCopy_CLI -P -Online -parent_VV ZZZ -destination_cpg ZZZ -VV_name ZZZ -wwn 123456
.EXAMPLE
    PS:> New-A9GroupVvCopy_CLI -R -destination_VV ZZZ
.EXAMPLE
    PS:> New-A9GroupVvCopy_CLI -Halt -destination_VV ZZZ
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName="set",Mandatory=$true)]	[String]	$svName,			
		[Parameter(ParameterSetName="vv", Mandatory=$true)]	[String]	$vvName,
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$parentName,		
		[Parameter(Mandatory=$true)]	[String]	$vvCopyName,
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
.EXAMPLE
	PS:> Push-A9SnapVolume -name vv1 
	
	copies the differences of a snapshot back to its base volume "vv1"
.EXAMPLE
	PS:> Push-A9SnapVolume -target vv23 -name vv1 
	
	copies the differences of a snapshot back to target volume "vv23" of volume "vv1"
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
.EXAMPLE
    PS:> Push-A9VvCopy –physicalCopyName volume1
	
	Promotes virtual volume "volume1" to a base volume
.PARAMETER physicalCopyName 
    Specifies the name of the physical copy to be promoted.
.PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
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
.EXAMPLE
    PS:> Set-A9VvSnapshot -Name volume1 -Force
	snapshot update of snapshot VV "volume1"
.EXAMPLE
    PS:> Set-A9VvSnapshot -Name volume1,volume2 -Force
	snapshot update of snapshot VV's "volume1" and "volume2"
.EXAMPLE
    PS:> Set-A9VvSnapshot -Name set:vvset1 -Force
	snapshot update of snapshot VVSet "vvset1"
.EXAMPLE
    PS:> Set-A9VvSnapshot -Name set:vvset1,set:vvset2 -Force
	snapshot update of snapshot VVSet's "vvset1" and "vvset2"
.EXAMPLE	
	PS:> Set-A9VvSnapshot -Name as2 -RO
.EXAMPLE	
	PS:> Set-A9VvSnapshot -Name as2 -Force -RemoveAndRecreate 
.PARAMETER Name 
    Specifies the name(s) of the snapshot virtual volume(s) or virtual volume set(s) to be updated.
.PARAMETER RO 
    Specifies that if the specified VV (<VV_name>) is a read/write snapshot the snapshot’s read-only
	parent volume is also updated with a new snapshot if the parent volume is not a member of a
	virtual volume set
.PARAMETER Force
	Specifies that the command is forced.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$Name,		
		[Parameter()]	[switch]	$Force,		
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
# MIIsWgYJKoZIhvcNAQcCoIIsSzCCLEcCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEC64g5rTRRJ
# ar/bTMcvEyaZih+lTouJ0A2NLOHDtyMDnPTbQ96gqX0sH/7LPEeLPURXh9bEoIHx
# G7CXGZMeKazioIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhcwghoTAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQKUYT5O0WaYa5OQ2YCbIlczyK4zZPVqFgCBKF5ZmlUUSMZ7lVnby/FqR
# cpZ+3xyGB4gcyUaAyZYRpiJALoIsyU4wDQYJKoZIhvcNAQEBBQAEggGAOVMxZc4M
# rH9tgwMOaQspRxfX5sPrAo5O1No1is1/yIJ9TkLIDTiIFYVovevAKBQAldmyNkdL
# uWEDCn/F8L7YHEdK/ucxEFYsgTIL0nk+u1QnwhnvPFw5w32VkByutHs2BJzPD5d7
# jBSxVn0PojkdYVBKfuzhvGS0v7+ooqIsfeFeIC0OgaL8KiZpLZ2TmOcbBWt2eFk7
# LSLlUBIVE0GnJVwiRx/dfw+e6ov9lWZfWAUtS3Qq6AGTQFy0SFRGl5RRv71ALqp7
# VCZ5lwclNsfimz2xnMeZnEUv/L16vuVV/Tcw0mDf8ASFpgeN0b22knOl0ApoR5mw
# 1HGpp3A7RFbz+EhK6Z5we8irPzqydMijy9wqwTAoN4NYkVW+5aIGHsdF2qagz1p+
# BRZzhsv7+cDekrFh1EGe6bGvIJsZhZiCUpFnlEc3z7jANccvsciuS0H/7IMbFx02
# bf5AXDnC7Xv7dsfSExI26kfe+Hs3cJLrtacfyqYcETLn+xdCGMzsJlwHoYIXYDCC
# F1wGCisGAQQBgjcDAwExghdMMIIXSAYJKoZIhvcNAQcCoIIXOTCCFzUCAQMxDzAN
# BglghkgBZQMEAgIFADCBhwYLKoZIhvcNAQkQAQSgeAR2MHQCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDDxAAinS376F+BF9FpjKL7eReHxseO+9S1+sodV
# 8KSwZvFX6wIs0yzpmhJ5jI4jTzkCEHeL50tRWUeouW0XrLCi7XwYDzIwMjQwNzMx
# MTkyNTUxWqCCEwkwggbCMIIEqqADAgECAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCSqG
# SIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwHhcNMjMwNzE0MDAwMDAwWhcNMzQxMDEzMjM1OTU5WjBI
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xIDAeBgNVBAMT
# F0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIzMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAo1NFhx2DjlusPlSzI+DPn9fl0uddoQ4J3C9Io5d6OyqcZ9xiFVjB
# qZMRp82qsmrdECmKHmJjadNYnDVxvzqX65RQjxwg6seaOy+WZuNp52n+W8PWKyAc
# wZeUtKVQgfLPywemMGjKg0La/H8JJJSkghraarrYO8pd3hkYhftF6g1hbJ3+cV7E
# Bpo88MUueQ8bZlLjyNY+X9pD04T10Mf2SC1eRXWWdf7dEKEbg8G45lKVtUfXeCk5
# a+B4WZfjRCtK1ZXO7wgX6oJkTf8j48qG7rSkIWRw69XloNpjsy7pBe6q9iT1Hbyb
# HLK3X9/w7nZ9MZllR1WdSiQvrCuXvp/k/XtzPjLuUjT71Lvr1KAsNJvj3m5kGQc3
# AZEPHLVRzapMZoOIaGK7vEEbeBlt5NkP4FhB+9ixLOFRr7StFQYU6mIIE9NpHnxk
# TZ0P387RXoyqq1AVybPKvNfEO2hEo6U7Qv1zfe7dCv95NBB+plwKWEwAPoVpdceD
# ZNZ1zY8SdlalJPrXxGshuugfNJgvOuprAbD3+yqG7HtSOKmYCaFxsmxxrz64b5bV
# 4RAT/mFHCoz+8LbH1cfebCTwv0KCyqBxPZySkwS0aXAnDU+3tTbRyV8IpHCj7Arx
# ES5k4MsiK8rxKBMhSVF+BmbTO77665E42FEHypS34lCh8zrTioPLQHsCAwEAAaOC
# AYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAf
# BgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUpbbvE+fv
# zdBkodVWqWUxo97V40kwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFt
# cGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVT
# dGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAgRrW3qCptZgXvHCNT4o8
# aJzYJf/LLOTN6l0ikuyMIgKpuM+AqNnn48XtJoKKcS8Y3U623mzX4WCcK+3tPUiO
# uGu6fF29wmE3aEl3o+uQqhLXJ4Xzjh6S2sJAOJ9dyKAuJXglnSoFeoQpmLZXeY/b
# JlYrsPOnvTcM2Jh2T1a5UsK2nTipgedtQVyMadG5K8TGe8+c+njikxp2oml101Dk
# RBK+IA2eqUTQ+OVJdwhaIcW0z5iVGlS6ubzBaRm6zxbygzc0brBBJt3eWpdPM43U
# jXd9dUWhpVgmagNF3tlQtVCMr1a9TMXhRsUo063nQwBw3syYnhmJA+rUkTfvTVLz
# yWAhxFZH7doRS4wyw4jmWOK22z75X7BC1o/jF5HRqsBV44a/rCcsQdCaM0qoNtS5
# cpZ+l3k4SF/Kwtw9Mt911jZnWon49qfH5U81PAC9vpwqbHkB3NpE5jreODsHXjlY
# 9HxzMVWggBHLFAx+rrz+pOt5Zapo1iLKO+uagjVXKBbLafIymrLS2Dq4sUaGa7oX
# /cR3bBVsrquvczroSUa31X/MtjjA2Owc9bahuEMs305MfR5ocMB3CtQC4Fxguyj/
# OOVSWtasFyIjTvTs0xf7UGv/B3cfcZdEQcm4RtNsMnxYL2dHZeUbc7aZ+WssBkbv
# QR7w8F/g29mtkIBEr4AQQYowggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5b
# MA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5
# NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPB
# PXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/
# nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLc
# Z47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mf
# XazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3N
# Ng1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yem
# j052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g
# 3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD
# 4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDS
# LFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwM
# O1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU
# 7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0j
# BBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8E
# PDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# DQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPO
# vxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQ
# TGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWae
# LJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPBy
# oyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfB
# wWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8l
# Y5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/
# O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbb
# bxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3
# OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBl
# dkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt
# 1nz8MIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwF
# ADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElE
# IFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKn
# JS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/W
# BTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHi
# LQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhm
# V1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHE
# tWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6
# MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mX
# aXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZ
# xd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfh
# vbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvl
# EFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn1
# 5GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNV
# HQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4Ix
# LVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAA
# MA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzs
# hV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre
# +i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8v
# C6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38
# dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNr
# Iv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDhjCCA4ICAQEw
# dzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCWCGSAFlAwQCAgUAoIHhMBoGCSqG
# SIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQwNzMxMTky
# NTUxWjArBgsqhkiG9w0BCRACDDEcMBowGDAWBBRm8CsywsLJD4JdzqqKycZPGZzP
# QDA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCDS9uRt7XQizNHUQFdoQTZvgoraVZqu
# MxavTRqa1Ax4KDA/BgkqhkiG9w0BCQQxMgQw7S+2JKgJa+IBENs/zM8CfTwyOTI5
# d5Mbz6b4cfKKFgaVzqDelhOU8vde9p9cgItoMA0GCSqGSIb3DQEBAQUABIICAAQ0
# 1XrRqUKxdpKDUq2MQgAQTLCmb7ZsK66MmUrDSOb3Qil26WidrZAVjKOiff3OnUYO
# Dhnv8Rj2FIz4gzhYX77oxtBgzuYNLzu6OcbVMpYzjbM0/MVl5j4l27ov4UphIqIL
# /vP/iNfxspevLt2wOIKVzob0F63pMSJkFiaBw5BAnXXGqyYxCA1HINdE9SWvMYKa
# nTw0xdtg2TuG/J0E2LW8T5gee8/iMmKRrSqyC9FwJtDrH4NnxrYotr4K+aLpP0GQ
# oOr33PT7+fenzJgniiabmhlDMkHX39/k8AYm1INy5rQq5N+iyizgMiTgLv5HM2d8
# JR/c/IudoUle2AhGxLcqV8Y+371gHt0ubHUKliTnovMS6RZD5lk3rf5W9SOzqHkO
# h3dUlrqqvcLVGdXM6B3gRo471pG74+R5G29xy9F0CUJuch5dFpxPztRlTaaEDP3P
# IO0h5nsKIl8gBeWH8ImDrukEBGBvlZDrpH9LkzkkeYsWqsYl2CYhwkhc8U04yUsC
# WwNpv56XsumNCxjAXmADjK4Q0pfk/AHWFTCf8MZJ4PQVS0bL31oI4s0pZZy/0wiI
# M7HQ5WE+/7X3jkZ6JP7+i8T/JkbgKZAih/CaU9iqAwwnLqgyAxhE4OFP4zv3wmyj
# nu93DqOu2kWaRA7aChSBjm4LzoyTPmp9ktRQyKpq
# SIG # End signature block
