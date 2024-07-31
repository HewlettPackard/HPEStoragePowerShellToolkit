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
{	Test-A9Connection -ClientType 'API'
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
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body
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
{	Test-A9Connection -ClientType 'API'
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
	Write-verbose "Request: Request to New-VvListGroupSnapshot_WSAPI : $SnapshotName (Invoke-A9API)." 
    $Result = Invoke-A9API -uri '/volumes' -type 'POST' -body $body 
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
{	Test-A9Connection -ClientType 'API'
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
	Write-Verbose "Request: Request to New-VvPhysicalCopy_WSAPI : $VolumeName (Invoke-A9API)." 
	$uri = '/volumes/'+$VolumeName
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body
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
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$body["action"] = 2	
    $Result = $null	
	$uri = "/volumes/" + $VolumeName
	Write-verbose "Request: Request to Reset-PhysicalCopy_WSAPI : $VolumeName (Invoke-A9API)." 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body
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
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$body["action"] = 1	
    $Result = $null	
	$uri = "/volumes/" + $VolumeName
	Write-verbose "Request: Request to Stop-A9PhysicalCopy : $VolumeName (Invoke-A9API)."
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body
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
	PS:> Move-A9VirtualCopy -VirtualCopyName xyz
.EXAMPLE	
	PS:> Move-A9VirtualCopy -VirtualCopyName xyz -Online
.EXAMPLE	
	PS:> Move-A9VirtualCopy -VirtualCopyName xyz -Priority HIGH
.EXAMPLE	
	PS:> Move-A9VirtualCopy -VirtualCopyName xyz -AllowRemoteCopyParent
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
{	Test-A9Connection -ClientType 'API'
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
	$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
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
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$body["action"] = 4
	if($Online)					{	$body["online"] = $true	}	
	if($Priority)	
		{	if		($Priority -eq "HIGH")	{	$body["priority"] = 1	}
			elseif	($Priority -eq "MED")	{	$body["priority"] = 2	}
			elseif	($Priority -eq "LOW")	{	$body["priority"] = 3	}
		}
	if($AllowRemoteCopyParent)	{	$body["allowRemoteCopyParent"] = $true	}
    $Result = $null	
	$uri = "/volumesets/" + $VVSetName
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body
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
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
	$body["action"] = "createSnapshot"
    If ($SnpVVName) 				{	$ParameterBody["name"] 				= "$($SnpVVName)"	}    
	If ($ID) 						{	$ParameterBody["id"] 				= $ID				}	
    If ($Comment) 					{	$ParameterBody["comment"] 			= "$($Comment)"    	}
	If ($ReadOnly) 					{	$ParameterBody["readOnly"] 			= $true 			}
	If ($ExpirationHours) 			{	$ParameterBody["expirationHours"] 	= $ExpirationHours 	}
	If ($RetentionHours) 			{	$ParameterBody["retentionHours"] 	= "$($RetentionHours)"}
	If ($AddToSet) 					{	$ParameterBody["addToSet"] 			= "$($AddToSet)" 	}
	if($ParameterBody.Count -gt 0)	{	$body["parameters"] = $ParameterBody 					}
    $Result = $null	
	$uri = '/volumesets/'+$VolumeSetName
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body 
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
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
    $body["action"] = "createPhysicalCopy"
    If ($DestVolume) 	{	$ParameterBody["destVolume"] = "$($DestVolume)" 	}    
	If ($SaveSnapshot) 	{	$ParameterBody["saveSnapshot"] = $SaveSnapshot		}
	if ($Priority)		{	if		($Priority -eq "HIGH")	{	$body["priority"] = 1	}
							elseif	($Priority -eq "MED")	{	$body["priority"] = 2	}
							elseif	($Priority -eq "LOW")	{	$body["priority"] = 3	}
						}
	if($ParameterBody.Count -gt 0)
		{	$body["parameters"] = $ParameterBody 
		}
    $Result = $null	
	$uri = '/volumesets/'+$VolumeSetName
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body	
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
	PS:> Reset-A9VvSetPhysicalCopy -VolumeSetName xxx -Priority HIGH
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]     	[String]  	$VolumeSetName,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')]							[String]	$Priority
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$body["action"] = 3
	if($Priority)	
		{	if		($Priority -eq "HIGH")	{	$body["priority"] = 1	}
			elseif	($Priority -eq "MED")	{	$body["priority"] = 2	}
			elseif	($Priority -eq "LOW")	{	$body["priority"] = 3	}
		}
    $Result = $null	
	$uri = "/volumesets/" + $VolumeSetName
	$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
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
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$body["action"] = 4
	if($Priority)	
		{	if		($Priority -eq "HIGH")	{	$body["priority"] = 1	}
			elseif	($Priority -eq "MED")	{	$body["priority"] = 2	}
			if		($Priority -eq "LOW")	{	$body["priority"] = 3	}
		}
    $Result = $null	
	$uri = "/volumesets/" + $VolumeSetName
	$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
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
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
    $body["action"] = 7   
    If ($VolumeSnapshotList) 		{	$ParameterBody["volumeSnapshotList"] = $VolumeSnapshotList    }    
	If ($ReadOnly) 					{	$ParameterBody["readOnly"] = $ReadOnly		 }
	if($ParameterBody.Count -gt 0)	{	$body["parameters"] = $ParameterBody 	}
    $Result = $null	
    $Result = Invoke-A9API -uri '/volumes/' -type 'POST' -body $body 
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

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBqXgwjfCLL
# KHs47jmIa5ycGgciOXLZbAiUvZHgZwrHuy8M37BTEk13ZXbIGUXw8G0t0pJOk6ZL
# 9LmClem9hiVmoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhgwghoUAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQFwCaV8Sph5HTSZtPCIt4fRJiUjDDotn7Ewu24vRGBvIAebm+wcgx92y
# QO15dDSqORTJWg6NKDiogLyOlyIOU9EwDQYJKoZIhvcNAQEBBQAEggGASuBM0ody
# Q13D03Zn2hiiG7kuwJcmGaKhnxUaIdhoJgz22ekO8wUMVL1fCdSLVPFyh2PQzVy8
# L3MHqgO8GMeFS+7RL3P5QiRqMaocv3MfcGF/JvE6C+H8/fyFfAxyhepxQYWBrhA0
# 23fZG806lC+tx1PuQHGBfg7CymF587NZhZx2btD6MvPRF5N9wGXmI75wLU30K5GF
# 6SidAb/eTiQz7fMUd4ljtDM2fxkH7PAyfgarT/qpxVei03Dif1Fp7oB0ht1ElJ3Q
# qrO4pW2l/fiq22dYFFlFU1bAWKp8VEjc3EfXtgL2vXvdHG6MPMduBkfCype38IHz
# QdPjZ+g+pzQtQ6miXp4mXHAI7ZSkIe9bYVhYdWbFHqQi4sVa5rqeWL4FnT8SG6KW
# 4Qf1hXO4BZu5R0IAYHej2w90Zzq5kJf1/vic3Nc/xTQnIvRpZMFl7aYhCt9K92JJ
# KWLssMOizROB4ayWu9RfPfT9RUZvOObjONAodfzeZK/zRj2bx37jlZP/oYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDC7h+j765tNRwTEtvitBSptERfmamHpiJeR9Uxo
# QYXK9Ryfe0473Nd2EJwqBWzO+rUCEQDdMsEsLB83abVlKiyfWf0pGA8yMDI0MDcz
# MTIwMTc0OFqgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVow
# SDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQD
# ExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVY
# wamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isg
# HMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFe
# xAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gp
# OWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28
# mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkH
# NwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58
# ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXH
# g2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W
# 1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK
# 8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn
# 783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+K
# PGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1I
# jrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP
# 2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ
# 5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON
# 1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S
# 88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbU
# uXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145
# WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6
# F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso
# /zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG
# 70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEM
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zC
# pyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf
# 1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x
# 4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEio
# ZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7ax
# xLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZ
# OjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJ
# l2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz
# 2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH
# 4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb
# 5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ
# 9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0g
# ADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs
# 7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq
# 3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/
# Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9
# /HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWoj
# ayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEB
# MHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgIFAKCB4TAaBgkq
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTIw
# MTc0OFowKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMLL2YbB7OBpAv9UixpFO19hbULgU
# 3XB3QV/FfNT3xxMAYHzjKZkjA++T7QGqvqOavjANBgkqhkiG9w0BAQEFAASCAgBk
# Nh5nD63eoHq8He5FY64CMop+KnC1RqAtDnlbWkzNYCv8rKiOKBkLX2OJ9B1ufO8j
# EFnQdxlLgrx0pErSAciL71OpOLXmDe1n0Pz02qxodccGhBgLJ98TkIqh3ywJDtdi
# DIQYERYdqZQ5QGMjFf0Ui72jYerRtOtiU6Tm/B2ENvXCBOstThGQxmhGJEws9txW
# ZwBt2bzRjEzTP0OVLj1E7O3zyVVpyQbwoXeiGmr3NfNrvp2/acehJE+x8KjFLkvi
# EIzAd4qy0XdlIpg6ubauxubmPYOr91USR4Yga0nNXJVHx/72Z3ylJ10RquFq2jJW
# 8BXLk1SQNrAy9X7FiPzCISAZLO2XYK5gJDXJN63clKL6v1LkAhxvsXrlIcVRbmWl
# 9BsQpCAxbu7c1sDOZBOpakYeISZOqzeGpIAG9AxNMMtxciXifIOp4plv/08jwgod
# nxvBl0mDut76C/5qjTflYnF4TYlUW/HdzKzAQ1ownJJ21CV89Ho5SCXnqafRVhiu
# 6q095fk0AJ2kdgtnLar0XpStWsqni7M3kBcKeln3NUQ6cV6VlEg+SMHHRSGXxbQv
# El1IMMB0SpMy2KJUMOHgC93s9rXYenwOZFygUTm0n2lpV2LPVPTXipSrVtnyhDp7
# YVstNqE/siV3MiY++3/nS25bjRMJK3e74G4A1mSRLw==
# SIG # End signature block
