####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function New-a9VvSnapshot 
{
<#      
.SYNOPSIS	
	Creating a volume snapshot
.DESCRIPTION	
	Creating a volume snapshot
.PARAMETER VolumeName
	The <VolumeName> parameter specifies the name of the volume from which you want to copy.
.PARAMETER snpVVName
	Specifies a snapshot volume name up to 31 characters in length.	For a snapshot of a volume set, use	name patterns that are used to form	the snapshot volume name. 
	See, VV	Name Patterns in the HPE 3PAR Command Line Interface Reference,available from the HPE Storage Information Library.
.PARAMETER ID
	Specifies the ID of the snapshot. If not specified, the system chooses the next available ID.
	Not applicable for VV-set snapshot creation.
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the volume.
.PARAMETER ReadOnly
	true—Specifies that the copied volume is read-only.
	false—(default) The volume is read/write.
.PARAMETER ExpirationHours
	Specifies the relative time from the current time that the volume expires. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER RetentionHours
	Specifies the relative time from the current time that the volume will expire. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER AddToSet
	The name of the volume set to which the system adds your created snapshots. If the volume set does not exist, it will be created.
.EXAMPLE    
	ps:> New-a9VvSnapshot -VolumeName $val -snpVVName snpvv1

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-a9VvSnapshot -VolumeName $val -snpVVName snpvv1 -ID 11

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-a9VvSnapshot -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-a9VvSnapshot -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello -ReadOnly $true

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-a9VvSnapshot -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello -ReadOnly $true -ExpirationHours 10

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-a9VvSnapshot -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello -ReadOnly $true -ExpirationHours 10 -RetentionHours 10

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-a9VvSnapshot -VolumeName $val -snpVVName snpvv1 -AddToSet asvvset

	SUCCESS: volume snapshot:$snpVVName created successfully
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$snpVVName,
		[Parameter(ValueFromPipeline=$true)]					[int]		$ID,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]					[boolean]	$ReadOnly,
		[Parameter(ValueFromPipeline=$true)]					[int]		$ExpirationHours,
		[Parameter(ValueFromPipeline=$true)]					[int]		$RetentionHours,
		[Parameter(ValueFromPipeline=$true)]					[String]	$AddToSet
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
	$body["action"] = "createSnapshot"
	If($snpVVName) 				{	$ParameterBody["name"] 			= "$($snpVVName)"	}
    If($ID) 					{	$ParameterBody["id"] 			= $ID				}
	If($Comment) 				{	$ParameterBody["comment"] 		= "$($Comment)"		}
    If($ReadOnly) 				{	$ParameterBody["readOnly"] 		= $ReadOnly			}
	If($ExpirationHours) 		{	$ParameterBody["expirationHours"] = $ExpirationHours}
	If($RetentionHours) 		{	$ParameterBody["retentionHours"] = $RetentionHours	}
	If($AddToSet) 				{	$ParameterBody["addToSet"] 		= "$($AddToSet)"	}
	if($ParameterBody.Count -gt 0){	$body["parameters"] 			= $ParameterBody 	}
    $Result = $null
	$uri = '/volumes/'+$VolumeName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	Write-HOST "SUCCESS: volume snapshot:$snpVVName created successfully" -ForegroundColor green 
			return $Result
		}
	else
		{	Write-error "FAILURE : While creating volume snapshot: $snpVVName "
			return $Result.StatusDescription
		}
}
}

Function New-A9VvListGroupSnapshot 
{
<#      
.SYNOPSIS	
	Creating group snapshots of a virtual volumes list
.DESCRIPTION
	Creating group snapshots of a virtual volumes list
.PARAMETER VolumeName 
	Name of the volume being copied. Required.
.PARAMETER SnapshotName
	If not specified, the system generates the snapshot name.
.PARAMETER SnapshotId
	ID of the snapShot volume. If not specified, the system chooses an ID.
.PARAMETER SnapshotWWN
	WWN of the snapshot Virtual Volume. With no snapshotWWNspecified, a WWN is chosen automatically.
.PARAMETER ReadWrite
	Optional.
	A True setting applies read-write status to the snapshot.
	A False setting applies read-only status to the snapshot.
	Overrides the readOnly and match settings for the snapshot.
.PARAMETER Comment
	Specifies any additional information for the volume.
.PARAMETER ReadOnly
	Specifies that the copied volumes are read-only. Do not combine with the match member.
.PARAMETER Match
	By default, all snapshots are created read-write. Specifies the creation of snapshots that match the read-only or read-write setting of parent. Do not combine the readOnly and match options.
.PARAMETER ExpirationHours
	Specifies the time relative to the current time that the copied volumes expire. Value is a positive integer with a range of 1–43,800 hours (1825 days).
.PARAMETER RetentionHours
	Specifies the time relative to the current time that the copied volumes are retained. Value is a positive integer with a range of 1–43,800 hours (1825 days).
.PARAMETER SkipBlock
	Occurs if the host IO is blocked while the snapshot is being created.
.PARAMETER AddToSet
	The name of the volume set to which the system adds your created snapshots. If the volume set does not exist, it will be created.
.EXAMPLE    
	PS:> New-A9VvListGroupSnapshot -VolumeName xyz -SnapshotName asSnpvv -SnapshotId 10 -SnapshotWWN 60002AC0000000000101142300018F8D -ReadWrite $true -Comment Hello -ReadOnly $true -Match $true -ExpirationHours 10 -RetentionHours 10 -SkipBlock $true
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SnapshotName,
		[Parameter(ValueFromPipeline=$true)]					[int]		$SnapshotId,
		[Parameter(ValueFromPipeline=$true)]					[String]	$SnapshotWWN,
		[Parameter(ValueFromPipeline=$true)]					[boolean]	$ReadWrite,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]					[boolean]	$ReadOnly,
		[Parameter(ValueFromPipeline=$true)]					[boolean]	$Match,
		[Parameter(ValueFromPipeline=$true)]					[int]		$ExpirationHours,
		[Parameter(ValueFromPipeline=$true)]					[int]		$RetentionHours,
		[Parameter(ValueFromPipeline=$true)]					[boolean]	$SkipBlock,
		[Parameter(ValueFromPipeline=$true)]					[String]	$AddToSet
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$VolumeGroupBody = @()
	$ParameterBody = @{}
	$body["action"] = 8	
    If ($VolumeName) 
		{	$VName=@{}
			$VName["volumeName"] = "$($VolumeName)"	
			$VolumeGroupBody += $VName		
		}
	If ($SnapshotName) 
		{	$snpName=@{}
			$snpName["snapshotName"] = "$($SnapshotName)"	
			$VolumeGroupBody += $snpName
		}
    If ($SnapshotId) 
		{	$snpId=@{}
			$snpId["snapshotId"] = $SnapshotId	
			$VolumeGroupBody += $snpId
		}
	If ($SnapshotWWN) 
		{	$snpwwn=@{}
			$snpwwn["SnapshotWWN"] = "$($SnapshotWWN)"	
			$VolumeGroupBody += $snpwwn
		}
    If ($ReadWrite) 
		{	$rw=@{}
			$rw["readWrite"] = $ReadWrite	
			$VolumeGroupBody += $rw
		}
	if($VolumeGroupBody.Count -gt 0)
		{	$ParameterBody["volumeGroup"] = $VolumeGroupBody 
		}
	If ($Comment) 			{	$ParameterBody["comment"] = "$($Comment)"	}	
	If ($ReadOnly) 			{	$ParameterBody["readOnly"] = $ReadOnly		}	
	If ($Match) 			{	$ParameterBody["match"] = $Match			}	
	If ($ExpirationHours) 	{	$ParameterBody["expirationHours"] = $ExpirationHours	}
	If ($RetentionHours) 	{	$ParameterBody["retentionHours"] = $RetentionHours	}
	If ($SkipBlock) 		{	$ParameterBody["skipBlock"] = $SkipBlock	}
	If ($AddToSet) 			{	$ParameterBody["addToSet"] = "$($AddToSet)"	}	
	if($ParameterBody.Count -gt 0)	{	$body["parameters"] = $ParameterBody 	}
    $Result = $null
	Write-verbose "Request: Request to New-VvListGroupSnapshot_WSAPI : $SnapshotName (Invoke-WSAPI)." 
    $Result = Invoke-WSAPI -uri '/volumes' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 300)
		{	Write-host "SUCCESS: Group snapshots of a virtual volumes list : $SnapshotName created successfully" -ForegroundColor green
			return $Result
		}
	else
		{	write-error "FAILURE : While creating group snapshots of a virtual volumes list : $SnapshotName " 
			return $Result.StatusDescription
		}
}
}

Function New-A9VvPhysicalCopy 
{
<#      
.SYNOPSIS	
	Create a physical copy of a volume.
.DESCRIPTION
    Create a physical copy of a volume.
.PARAMETER VolumeName
	The <VolumeName> parameter specifies the name of the volume to copy.
.PARAMETER DestVolume
	Specifies the destination volume.
.PARAMETER DestCPG
	Specifies the destination CPG for an online copy.
.PARAMETER Online
	Enables (true) or disables (false) whether to perform the physical copy online. Defaults to false.
.PARAMETER WWN
	Specifies the WWN of the online copy virtual volume.
.PARAMETER TDVV
	Enables (true) or disables (false) whether the online copy is a TDVV. Defaults to false. tpvv and tdvv cannot be set to true at the same time.
.PARAMETER Reduce
	Enables (true) or disables (false) a thinly deduplicated and compressed volume.
.PARAMETER TPVV
	Enables (true) or disables (false) whether the online copy is a TPVV. Defaults to false. tpvv and tdvv cannot be set to true at the same time.
.PARAMETER SnapCPG
	Specifies the snapshot CPG for an online copy.
.PARAMETER SkipZero
	Enables (true) or disables (false) copying only allocated portions of the source VV from a thin provisioned source. Use only on a newly created destination, or if the destination was re-initialized to zero. Does not overwrite preexisting data on the destination VV to match the source VV unless the same offset is allocated in the source.
.PARAMETER Compression
	For online copy only:
	Enables (true) or disables (false) compression of the created volume. Only tpvv or tdvv are compressed. Defaults to false.
.PARAMETER SaveSnapshot
	Enables (true) or disables (false) saving the the snapshot of the source volume after completing the copy of the volume. Defaults to false
.PARAMETER Priority
	Does not apply to online copy.
	HIGH : High priority.
	MED : Medium priority.
	LOW : Low priority.
.EXAMPLE    
	PS:> New-A9VvPhysicalCopy -VolumeName xyz -DestVolume Test1
.EXAMPLE
    PS:> New-A9VvPhysicalCopy -VolumeName xyz -DestVolume Test -DestCPG as_cpg
.EXAMPLE
	PS:> New-A9VvPhysicalCopy -VolumeName xyz -DestVolume Test -Online
.EXAMPLE
	PS:> New-A9VvPhysicalCopy -VolumeName xyz -DestVolume Test -WWN "60002AC0000000000101142300018F8D"    
.EXAMPLE
	PS:> New-A9VvPhysicalCopy -VolumeName xyz -DestVolume Test -TPVV
.EXAMPLE
	PS:> New-A9VvPhysicalCopy -VolumeName xyz -DestVolume Test -SnapCPG as_cpg
.EXAMPLE
	PS:> New-A9VvPhysicalCopy -VolumeName xyz -DestVolume Test -SkipZero
.EXAMPLE
	PS:> New-A9VvPhysicalCopy -VolumeName xyz -DestVolume Test -Compression
.EXAMPLE
	PS:> New-A9VvPhysicalCopy -VolumeName xyz -DestVolume Test -SaveSnapshot
.EXAMPLE
	PS:> New-A9VvPhysicalCopy -VolumeName $val -DestVolume Test -Priority high
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$DestVolume,
		[Parameter(ValueFromPipeline=$true)]					[String]	$DestCPG,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$Online,
		[Parameter(ValueFromPipeline=$true)]					[String]	$WWN,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$TPVV,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$TDVV,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$Reduce,
		[Parameter(ValueFromPipeline=$true)]					[String]	$SnapCPG,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$SkipZero,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$Compression,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$SaveSnapshot,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')]						[String]	$Priority
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
	$body["action"] = "createPhysicalCopy"
	If ($DestVolume) 	{	$ParameterBody["destVolume"] = "$($DestVolume)"	}    
	If ($Online) 
		{	$ParameterBody["online"] = $true
			If ($DestCPG) 
				{	$ParameterBody["destCPG"] = $DestCPG
				}
			else
				{	write-error "Choice to specify Online was made, but DestCPG was not defined. Must define DestCPG if you choose online option."
					return 
				}
		}
    If ($WWN) 		{	$ParameterBody["WWN"] = "$($WWN)"			}
	If ($TPVV) 		{	$ParameterBody["tpvv"] = $true				}
	If ($TDVV) 		{	$ParameterBody["tdvv"] = $true				}
	If ($Reduce) 	{	$ParameterBody["reduce"] = $true			}	
	If ($SnapCPG) 	{	$ParameterBody["snapCPG"] = "$($SnapCPG)"	}
	If ($SkipZero) 	{	$ParameterBody["skipZero"] = $true			}
	If ($Compression) {	$ParameterBody["compression"] = $true		}
	If ($SaveSnapshot){	$ParameterBody["saveSnapshot"] = $SaveSnapshot}
	If ($Priority) 
		{	if($Priority -eq "HIGH")	{	$ParameterBody["priority"] = 1	}
			elseif($Priority -eq "MED")	{	$ParameterBody["priority"] = 2	}
			else						{	$ParameterBody["priority"] = 3	}
		}
	if($ParameterBody.Count -gt 0)
		{	$body["parameters"] = $ParameterBody 
		}
    $Result = $null
	Write-Verbose "Request: Request to New-VvPhysicalCopy_WSAPI : $VolumeName (Invoke-WSAPI)." 
	$uri = '/volumes/'+$VolumeName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	Write-host "SUCCESS: Physical copy of a volume: $VolumeName created successfully" -ForegroundColor green
			return $Result
		}
	else
		{	Write-error "FAILURE : While creating Physical copy of a volume : $VolumeName " 
			return $Result.StatusDescription
		}
}
}

Function Reset-A9PhysicalCopy 
{
<#
.SYNOPSIS
	Resynchronizing a physical copy to its parent volume
.DESCRIPTION
	Resynchronizing a physical copy to its parent volume
.EXAMPLE    
	PS:> Reset-A9PhysicalCopy -VolumeName xxx

	Resynchronizing a physical copy to its parent volume	
.PARAMETER VolumeName 
	The <VolumeName> parameter specifies the name of the destination volume you want to resynchronize.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$body["action"] = 2	
    $Result = $null	
	$uri = "/volumes/" + $VolumeName
	Write-verbose "Request: Request to Reset-PhysicalCopy_WSAPI : $VolumeName (Invoke-WSAPI)." 
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	Write-error "FAILURE : While Resynchronizing a physical copy to its parent volume : $VolumeName " 		
			return $Result.StatusDescription
		}
}
}

Function Stop-A9PhysicalCopy
{
<#
.SYNOPSIS
	Stop a physical copy of given Volume
.DESCRIPTION
	Stop a physical copy of given Volume
.PARAMETER VolumeName 
	The <VolumeName> parameter specifies the name of the destination volume you want to resynchronize.
.EXAMPLE    
	PS:> Stop-A9PhysicalCopy -VolumeName xxx

	Stop a physical copy of given Volume 
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]		[String]	$VolumeName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$body["action"] = 1	
    $Result = $null	
	$uri = "/volumes/" + $VolumeName
	Write-verbose "Request: Request to Stop-A9PhysicalCopy : $VolumeName (Invoke-WSAPI)."
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
		return $Result		
		}
	else
		{	write-error "FAILURE : While stopping a physical copy : $VolumeName "
			return $Result.StatusDescription
		}
}
}

Function Move-A9VirtualCopy
{
<#
.SYNOPSIS
	To promote the changes from a virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
.DESCRIPTION
	To promote the changes from a virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
.EXAMPLE
	Move-VirtualCopy_WSAPI -VirtualCopyName xyz
.EXAMPLE	
	Move-VirtualCopy_WSAPI -VirtualCopyName xyz -Online
.EXAMPLE	
	Move-VirtualCopy_WSAPI -VirtualCopyName xyz -Priority HIGH
.EXAMPLE	
	Move-VirtualCopy_WSAPI -VirtualCopyName xyz -AllowRemoteCopyParent
.PARAMETER VirtualCopyName 
	The <virtual_copy_name> parameter specifies the name of the virtual copy to be promoted.
.PARAMETER Online	
	Enables (true) or disables (false) executing the promote operation on an online volume. The default setting for this switch is off (false).
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.PARAMETER AllowRemoteCopyParent
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been started. If the Remote Copy group has been started, this command fails.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VirtualCopyName,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$Online,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')]						[String]	$Priority,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$AllowRemoteCopyParent
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$body["action"] = 4
	if($Online)			{	$body["online"] = $true	}	
	if($Priority)	
		{	if($Priority -eq "HIGH")	{	$body["priority"] = 1	}
			elseif($Priority -eq "MED")	{	$body["priority"] = 2	}
			else						{	$body["priority"] = 3	}
		}
	if($AllowRemoteCopyParent)	{	$body["allowRemoteCopyParent"] = $true	}    
    $Result = $null	
	$uri = "/volumes/" + $VirtualCopyName	
	$Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	write-ERROR "FAILURE : While Promoting a virtual copy : $VirtualCopyName " 
			return $Result.StatusDescription
		}
}
}

Function Move-A9VvSetVirtualCopy 
{
<#
.SYNOPSIS
	To promote the changes from a vv set virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
.DESCRIPTION
	To promote the changes from a vv set virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
.PARAMETER VirtualCopyName 
	The <virtual_copy_name> parameter specifies the name of the virtual copy to be promoted.
.PARAMETER Online	
	Enables (true) or disables (false) executing the promote operation on an online volume. The default setting is false.
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.PARAMETER AllowRemoteCopyParent
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been started. If the Remote Copy group has been started, this command fails.
.EXAMPLE
	PS:> Move-A9VvSetVirtualCopy
.EXAMPLE	
	PS:> Move-A9VvSetVirtualCopy -VVSetName xyz
.EXAMPLE	
	PS:> Move-A9VvSetVirtualCopy -VVSetName xyz -Online
.EXAMPLE	
	PS:> Move-A9VvSetVirtualCopy -VVSetName xyz -Priority HIGH
.EXAMPLE	
	PS:> Move-A9VvSetVirtualCopy -VVSetName xyz -AllowRemoteCopyParent
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VVSetName,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$Online,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')]						[String]	$Priority,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$AllowRemoteCopyParent
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$body["action"] = 4
	if($Online)					{	$body["online"] = $true	}	
		if($Priority)	
		{	if($Priority -eq "HIGH")	{	$body["priority"] = 1	}
			elseif($Priority -eq "MED")	{	$body["priority"] = 2	}
			else						{	$body["priority"] = 3	}
		}
	if($AllowRemoteCopyParent)	{	$body["allowRemoteCopyParent"] = $true	}
    $Result = $null	
	$uri = "/volumesets/" + $VVSetName
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	write-error "FAILURE : While Promoting a VV-Set virtual copy : $VVSetName " 
			return $Result.StatusDescription
		}
}
}

Function New-A9VvSetSnapshot 
{
<#      
.SYNOPSIS	
	Create a VV-set snapshot.
.DESCRIPTION	
    Create a VV-set snapshot.
	Any user with the Super or Edit role or any role granted sv_create permission (for snapshots) can create a VV-set snapshot.
.PARAMETER VolumeSetName
	The <VolumeSetName> parameter specifies the name of the VV set to copy.
.PARAMETER SnpVVName
	Specifies a snapshot volume name up to 31 characters in length.
	For a snapshot of a volume set, use name patterns that are used to form the snapshot volume name. See, VV Name Patterns in the HPE 3PAR Command Line Interface Reference,available from the HPE Storage Information Library.
.PARAMETER ID
	Specifies the ID of the snapshot. If not specified, the system chooses the next available ID.
	Not applicable for VV-set snapshot creation.
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the volume.
.PARAMETER readOnly
	true—Specifies that the copied volume is read-only. false—(default) The volume is read/write.
.PARAMETER ExpirationHours
	Specifies the relative time from the current time that the volume expires. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER RetentionHours
	Specifies the relative time from the current time that the volume will expire. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER AddToSet 
	The name of the volume set to which the system adds your created snapshots. If the volume set does not exist, it will be created.
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
.EXAMPLE    
	PS:> New-A9VvSetSnapshot -VolumeSetName Test_delete -SnpVVName PERF_AIX38 -ID 110 -Comment Hello -readOnly -ExpirationHours 1 -RetentionHours 1
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeSetName,
		[Parameter(ValueFromPipeline=$true)]					[String]	$SnpVVName,
		[Parameter(ValueFromPipeline=$true)]					[int]		$ID,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$readOnly,
		[Parameter(ValueFromPipeline=$true)]					[int]		$ExpirationHours,
		[Parameter(ValueFromPipeline=$true)]					[int]		$RetentionHours,
		[Parameter(ValueFromPipeline=$true)]					[String]	$AddToSet
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
	$body["action"] = "createSnapshot"
    If ($SnpVVName) 				{	$ParameterBody["name"] = "$($SnpVVName)"    }    
	If ($ID) 						{	$ParameterBody["id"] = $ID	}	
    If ($Comment) 					{	$ParameterBody["comment"] = "$($Comment)"    }
	If ($ReadOnly) 					{	$ParameterBody["readOnly"] = $true }
	If ($ExpirationHours) 			{	$ParameterBody["expirationHours"] = $ExpirationHours }
	If ($RetentionHours) 			{	$ParameterBody["retentionHours"] = "$($RetentionHours)"	}
	If ($AddToSet) 					{	$ParameterBody["addToSet"] = "$($AddToSet)" }
	if($ParameterBody.Count -gt 0)	{	$body["parameters"] = $ParameterBody 	}
    $Result = $null	
	$uri = '/volumesets/'+$VolumeSetName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	write-error "FAILURE : While creating VV-set snapshot : $SnpVVName "
			return $Result.StatusDescription
		}
}
}

Function New-A9VvSetPhysicalCopy
{
<#      
.SYNOPSIS	
	Create a VV-set snapshot.
.DESCRIPTION	
    Create a VV-set snapshot. Any user with the Super or Edit role or any role granted sv_create permission (for snapshots) can create a VV-set snapshot.
.PARAMETER VolumeSetName
	The <VolumeSetName> parameter specifies the name of the VV set to copy.
.PARAMETER DestVolume
	Specifies the destination volume set.
.PARAMETER SaveSnapshot
	Enables (true) or disables (false) whether to save the source volume snapshot after completing VV set copy.
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.EXAMPLE    
	PS:> New-A9VvSetPhysicalCopy -VolumeSetName Test_delete -DestVolume PERF_AIX38 	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeSetName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$DestVolume,
		[Parameter(ValueFromPipeline=$true)]					[boolean]	$SaveSnapshot,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')]						[String]	$Priority
)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
    $body["action"] = "createPhysicalCopy"
    If ($DestVolume) 	{	$ParameterBody["destVolume"] = "$($DestVolume)" 	}    
	If ($SaveSnapshot) 	{	$ParameterBody["saveSnapshot"] = $SaveSnapshot		}
	if($Priority)	
		{	if($Priority -eq "HIGH")	{	$body["priority"] = 1	}
			elseif($Priority -eq "MED")	{	$body["priority"] = 2	}
			else						{	$body["priority"] = 3	}
		}
	if($ParameterBody.Count -gt 0)
		{	$body["parameters"] = $ParameterBody 
		}
    $Result = $null	
	$uri = '/volumesets/'+$VolumeSetName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body	
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	write-error "FAILURE : While creating Physical copy of a VV set : $VolumeSetName "
			return $Result.StatusDescription
		}
}
}

Function Reset-A9VvSetPhysicalCopy 
{
<#
.SYNOPSIS
	Resynchronizing a VV set physical copy
.DESCRIPTION
	Resynchronizing a VV set physical copy
.PARAMETER VolumeSetName 
	The <VolumeSetName> specifies the name of the destination VV set to resynchronize.
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.EXAMPLE
    PS:> Reset-A9VvSetPhysicalCopy -VolumeSetName xyz
.EXAMPLE 
	Reset-A9VvSetPhysicalCopy -VolumeSetName xxx -Priority HIGH
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]     	[String]  	$VolumeSetName,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')]							[String]	$Priority
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$body["action"] = 3
	if($Priority)	
		{	if($Priority -eq "HIGH")	{	$body["priority"] = 1	}
			elseif($Priority -eq "MED")	{	$body["priority"] = 2	}
			else						{	$body["priority"] = 3	}
		}
    $Result = $null	
	$uri = "/volumesets/" + $VolumeSetName
	$Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return $Result		
	}
	else
	{	write-error "FAILURE : While Resynchronizing a VV set physical copy : $VolumeSetName " 
		return $Result.StatusDescription
	}
}
}

Function Stop-A9VvSetPhysicalCopy
{
<#
.SYNOPSIS
	Stop a VV set physical copy
.DESCRIPTION
	Stop a VV set physical copy
.PARAMETER VolumeSetName 
	The <VolumeSetName> specifies the name of the destination VV set to resynchronize.
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.EXAMPLE
    PS:> Stop-A9VvSetPhysicalCopy -VolumeSetName xxx
.EXAMPLE 
	PS:> Stop-A9VvSetPhysicalCopy -VolumeSetName xxx -Priority HIGH
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeSetName,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')]						[String]	$Priority
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$body["action"] = 4
	if($Priority)	
		{	if($Priority -eq "HIGH")	{	$body["priority"] = 1	}
			elseif($Priority -eq "MED")	{	$body["priority"] = 2	}
			else						{	$body["priority"] = 3	}
		}
    $Result = $null	
	$uri = "/volumesets/" + $VolumeSetName
	$Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	write-error "FAILURE : While Stopping a VV set physical copy : $VolumeSetName " 
			return $Result.StatusDescription
		}
}
}

Function Update-A9VvOrVvSets 
{
<#      
.SYNOPSIS	
	Update virtual copies or VV-sets
.DESCRIPTION	
    Update virtual copies or VV-sets
.PARAMETER VolumeSnapshotList
	List one or more volume snapshots to update. If specifying a vvset, use the	following format
	set:vvset_name.
.PARAMETER VolumeSnapshotList
	Specifies that if the virtual copy is read-write, the command updates the read-only parent volume also.
.EXAMPLE
	PS:> Update-A9VvOrVvSets -VolumeSnapshotList "xxx,yyy,zzz" 
	
	Update virtual copies or VV-sets
.EXAMPLE
	PS:> Update-A9VvOrVvSets -VolumeSnapshotList "xxx,yyy,zzz" -ReadOnly $true/$false
	
	Update virtual copies or VV-sets
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String[]]	$VolumeSnapshotList,
		[Parameter(ValueFromPipeline=$true)]					[boolean]	$ReadOnly
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
    $body["action"] = 7   
    If ($VolumeSnapshotList) 		{	$ParameterBody["volumeSnapshotList"] = $VolumeSnapshotList    }    
	If ($ReadOnly) 					{	$ParameterBody["readOnly"] = $ReadOnly		 }
	if($ParameterBody.Count -gt 0)	{	$body["parameters"] = $ParameterBody 	}
    $Result = $null	
    $Result = Invoke-WSAPI -uri '/volumes/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result			
		}
	else
		{	write-error "FAILURE : While Updating virtual copies or VV-sets : $VolumeSnapshotList " 
			return $Result.StatusDescription
		}
}
}
