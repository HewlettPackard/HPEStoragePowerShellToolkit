## 	©2025 Hewlett Packard Enterprise Development LP

Function New-A9Snapshot 
{
<#      
.SYNOPSIS	
	Creating a volume snapshot, or a group of volume snapshots, or a Volume Set snapshot
.DESCRIPTION	
	Creating a volume snapshot, or a group of volume snapshots, or a Volume Set snapshot
.PARAMETER VolumeName
	The parameter specifies the name of the volume from which you want to create a snapshot for. 
	This must be a single volumename or you may use volume1,volume2,volume3 style seperation be sure that no spaces exist between the , and the values.
.PARAMETER VolumeSet
	The parameter specified the name of the volume set to snapshot together. 
.PARAMETER snpVVName
	Specifies a snapshot volume name up to 31 characters in length.	For a group or set of snapshots the array will select names automatically.
	For Volume Sets, it the array will prefix or postfix the snpVVName.
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the volume.
.PARAMETER ReadOnly
	The volume is read/write unless this switch is specifid.
.PARAMETER ExpirationHours
	Specifies the relative time from the current time that the volume expires. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER RetentionHours
	Specifies the relative time from the current time that the volume will expire. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER AddToSet
	The name of the volume set to which the system adds your created group of snapshots will be added, if the volume set does not exist, it will be created. 
.PARAMETER Match
	If taking a snapshots of multiple Volumes, the Read-Only or Read-Write value will match the value of the parent volume.
.EXAMPLE    
	ps:> New-A9Snapshot -VolumeName $val -snpVVName snpvv1

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-A9Snapshot -VolumeName Vol1,Vol2,Vol3 -snpVVName snpvv1 

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-A9Snapshot -VolumeSet VVSet5 -snpVVName snpvv1 -Comment hello

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-A9Snapshot -VolumeName $val -snpVVName snpvv1 -Comment hello -ReadOnly -ExpirationHours 10

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-A9Snapshot -VolumeName $val -snpVVName snpvv1 -AddToSet asvvset

	SUCCESS: volume snapshot:$snpVVName created successfully
#>
[CmdletBinding(DefaultParameterSetName='SingleVVs')]
Param(	[Parameter(Mandatory,ParameterSetName='SingleVVs')]		[String[]]	$VolumeName,
		[Parameter(Mandatory,ParameterSetName='VVSet')]			[String]	$VolumeSet,
		[Parameter()]											[String]	$snpVVName,
		[Parameter()]											[String]	$Comment,
		[Parameter()]											[Switch]	$syncSnapRCopy,
		[Parameter()]											[switch]	$readOnly,
		[Parameter()][ValidateRange(1,43800)]					[int]		$ExpirationHours,
		[Parameter()][ValidateRange(1,43800)]					[int]		$RetentionHours,
		[Parameter()]											[String]	$AddToSet,
		[Parameter(ParameterSetName='SingleVVs')]				[switch]	$Match
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
	if ( ($VolumeName).count -gt 1 )	{	$uri = '/volumes/'
											$body["action"] = 8
											$VolumeGroup=@()
											foreach ($Vname in $VolumeName)
												{	$VItem = @{	$VItem = @{ 'volumeName' = $Vname}	}
													$VolumeGroup += $VItem
												}
										}
	elseif( $VolumeName )				{	$uri = '/volumes/'+$VolumeName
											$body["action"] = "createSnapshot"						}
	elseIf ( $VolumeSet)				{	$uri = '/volumesets/'+$VolumeSet
											$body["action"] = "createSnapshot"						}
	If ( $snpVVName ) 					{	$ParameterBody["name"] 				= "$($snpVVName)"	}
	If ( $syncSnapRCopy )				{	$ParameterBody["syncSnapCopy"] 		= $true				}
	If ( $Comment ) 					{	$ParameterBody["comment"] 			= "$($Comment)"		}
    If ( $ReadOnly ) 					{	$ParameterBody["readOnly"] 			= $true				}
	elseif ( $Match )					{	$ParameterBody["match"] 			= $true				} 
	If ( $ExpirationHours ) 			{	$ParameterBody["expirationHours"] 	= $ExpirationHours	}
	If ( $RetentionHours ) 				{	$ParameterBody["retentionHours"]	= $RetentionHours	}
	If ( $AddToSet ) 					{	$ParameterBody["addToSet"] 			= "$($AddToSet)"	}
	if ( $ParameterBody.Count -gt 0 )	{	$body["parameters"] 				= $ParameterBody 	}
	if ( $VolumeNames )					{	$ParameterBody["volumeGroup"] 		= "$($VolumeGroup)"	} 	   	
	if ( $ParameterBody.Count -gt 0 )	{	$body["parameters"] = $ParameterBody 					}
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	Write-HOST "SUCCESS: volume snapshot:$snpVVName created successfully" -ForegroundColor green 
			return $Result
		}
	else
		{	Write-error "FAILURE : While creating volume snapshot "
			return $Result.StatusDescription
		}
}
}

Function New-A9VolumeCopy 
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
	PS:> New-A9VvCopy -VolumeName xyz -DestVolume Test1
.EXAMPLE
    PS:> New-A9VvCopy -VolumeName xyz -DestVolume Test -DestCPG as_cpg
.EXAMPLE
	PS:> New-A9VvCopy -VolumeName xyz -DestVolume Test -Online
.EXAMPLE
	PS:> New-A9VvCopy -VolumeName xyz -DestVolume Test -WWN "60002AC0000000000101142300018F8D"    
.EXAMPLE
	PS:> New-A9VvCopy -VolumeName xyz -DestVolume Test -TPVV
.EXAMPLE
	PS:> New-A9VvCopy -VolumeName xyz -DestVolume Test -SnapCPG as_cpg
.EXAMPLE
	PS:> New-A9VvCopy -VolumeName xyz -DestVolume Test -SkipZero
.EXAMPLE
	PS:> New-A9VvCopy -VolumeName xyz -DestVolume Test -Compression
.EXAMPLE
	PS:> New-A9VvCopy -VolumeName xyz -DestVolume Test -SaveSnapshot
.EXAMPLE
	PS:> New-A9VvCopy -VolumeName $val -DestVolume Test -Priority high
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$VolumeName,
		[Parameter(Mandatory)]	[String]	$DestVolume,
		[Parameter()]			[String]	$DestCPG,
		[Parameter()]			[switch]	$Online,
		[Parameter()]			[String]	$WWN,
		[Parameter()]			[switch]	$TPVV,
		[Parameter()]			[switch]	$TDVV,
		[Parameter()]			[switch]	$Reduce,
		[Parameter()]			[String]	$SnapCPG,
		[Parameter()]			[switch]	$SkipZero,
		[Parameter()]			[switch]	$Compression,
		[Parameter()]			[switch]	$SaveSnapshot,
		[Parameter()]	[ValidateSet('HIGH','MED','LOW')]						
								[String]	$Priority
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
	Write-Verbose "Request: Request to New-A9VvCopy : $VolumeName (Invoke-A9API)." 
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

Function Set-A9VolumeCopy 
{
<#
.SYNOPSIS
	Allows you to Reset(Resynchronizing), Stop, Move(Promote) a Volume copy to its parent volume
.DESCRIPTION
	Allows you to Reset(Resynchronizing), Stop, Move(Promote) a Volume copy to its parent volume
.PARAMETER VolumeName 
	The <VolumeName> parameter specifies the name of the destination volume you want to resynchronize.
.PARAMETER Online	
	Enables (true) or disables (false) executing the promote operation on an online volume. The default setting for this switch is off (false).
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.PARAMETER AllowRemoteCopyParent
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been started. If the Remote Copy group has been started, this command fails.
.EXAMPLE    
	PS:> Set-A9VolumeCopy -VolumeName xxx -resync

	Resynchronizing a physical copy to its parent volume	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory,ParameterSetName='Resync')]
		[Parameter(Mandatory,ParameterSetName='Stop')]
		[Parameter(Mandatory,ParameterSetName='Promote')]
		[Parameter(Mandatory,ParameterSetName='StopPromote')]	[String]	$VolumeName,

		[Parameter(ParameterSetName='Promote')]
		[Parameter(ParameterSetName='StopPromote')]				[Switch]	$Online,
	
		[Parameter(ParameterSetName='Promote')]
		[Parameter(ParameterSetName='StopPromote')]
		[ValidateSet('HIGH','MED','LOW')]						[String]	$Priority,

		[Parameter(ParameterSetName='Promote')]
		[Parameter(ParameterSetName='StopPromote')]				[Switch]	$AllowRemoteCopyParent,

		[Parameter(Mandatory,ParameterSetName='Resync')]		[Switch]	$ResyncCopy,
		[Parameter(Mandatory,ParameterSetName='Stop')]			[Switch]	$StopCopy,
		[Parameter(Mandatory,ParameterSetName='Promote')]		[Switch]	$Promote,
		[Parameter(Mandatory,ParameterSetName='StopPromote')]	[Switch]	$StopPromote
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$uri = "/volumes/" + $VolumeName
	$Result = $null			
	if ( $Online )			{	$body["online"] = $true	}	
	elseif ( $Priority )	{	if($Priority -eq "HIGH")	{	$body["priority"] = 1	}
								if($Priority -eq "MED")		{	$body["priority"] = 2	}
								if($Priority -eq "LOW")		{	$body["priority"] = 3	}
							}
	if ( $AllowRemoteCopyParent )	{	$body["allowRemoteCopyParent"] = $true	}   				
	Switch($PSCmdlet.ParameterSetName)	
		{	'Resync'	{	$body["action"] = 2	}
			'Stop'		{	$body["action"] = 1	}
			'Promote'	{	$body["action"] = 4	}
			'StopPromote'{	$body["action"] = 5	}
		}
	Write-Verbose "The Command Executed was an HTTP Put to $uri with a body of $body"
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

Function New-A9VolumeSetCopy
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
Param(	[Parameter(Mandatory)]	[String]	$VolumeSetName,
		[Parameter(Mandatory)]	[String]	$DestVolume,
		[Parameter()]			[boolean]	$SaveSnapshot,
		[Parameter()]
		[ValidateSet('HIGH','MED','LOW')][String]	$Priority
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

Function Set-A9VolumeSetCopy 
{
<#
.SYNOPSIS
	Modify a VV set physical copy either via a Reset (Resync), a Stop, a Move(Promote), or an Update
.DESCRIPTION
	Modify a VV set physical copy either via a Reset (Resync), a Stop, a Move(Promote), or an Update
.PARAMETER VolumeSetName 
	The <VolumeSetName> specifies the name of the destination VV set to initiate action upon.
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.PARAMETER Online	
	Enables (true) or disables (false) executing the Move (promote) operation on an online volume. The default setting is false.
.PARAMETER AllowRemoteCopyParent
	Allows the move(promote) operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been started. If the Remote Copy group has been started, this command fails.
.PARAMETER Reset
	This will make the command issue the command that resynchronizing a VV set physical copy
.PARAMETER Move
	To promote the changes from a vv set virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.EXAMPLE 
	PS:> Set-A9VolumeSetCopy -VolumeSetName xxx -Priority HIGH -reset
.EXAMPLE	
	PS:> Set-A9VolumeSetCopy -VVSetName xyz
.EXAMPLE	
	PS:> Set-A9VolumeSetCopy -VVSetName xyz -Online -move
.EXAMPLE	
	PS:> Set-A9VolumeSetCopy -VVSetName xyz -Priority HIGH -stop
.EXAMPLE	
	PS:> Set-A9VolumeSetCopy -VVSetName xyz -AllowRemoteCopyParent -move
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory,ParameterSetName='Reset')]
		[Parameter(Mandatory,ParameterSetName='Stop')]
		[Parameter(Mandatory,ParameterSetname='Move')]     	[String]  	$VolumeSetName,

		[Parameter(Mandatory,ParameterSetName='Update')]	[String[]]	$VolumeSnapshotList,

		[Parameter(ParameterSetName='Reset')]
		[Parameter(ParameterSetName='Stop')]
		[Parameter(Mandatory,ParameterSetname='Move')]
		[ValidateSet('HIGH','MED','LOW')]					[String]	$Priority,

		[Parameter(ParameterSetname='Move')]				[Switch]	$Online,
		[Parameter(ParameterSetname='Move')]				[Switch]	$AllowRemoteCopyParent,

		[Parameter(Mandatory,ParameterSetName='Reset')]		[Switch]	$Reset,
		[Parameter(Mandatory,ParameterSetName='Stop')]		[Switch]	$Stop,
		[Parameter(Mandatory,ParameterSetName='Move')]		[Switch]	$Move,
		[Parameter(Mandatory,ParameterSetName='Update')]	[Switch]	$Update
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	Switch($PSCmdlet.ParameterSetName)
	{	'Reset'	
				{	$body["action"] = 3
					if($Priority)	
						{	if		($Priority -eq "HIGH")	{	$body["priority"] = 1	}
							elseif	($Priority -eq "MED")	{	$body["priority"] = 2	}
							elseif	($Priority -eq "LOW")	{	$body["priority"] = 3	}
						}
					$Result = $null	
					$uri = "/volumesets/" + $VolumeSetName
					$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
				}
		'Move'
				{	$body["action"] = 4
					if($Online)					{	$body["online"] = $true	}	
					if($Priority)	
						{	if		($Priority -eq "HIGH")	{	$body["priority"] = 1	}
							elseif	($Priority -eq "MED")	{	$body["priority"] = 2	}
							elseif	($Priority -eq "LOW")	{	$body["priority"] = 3	}
						}
					if($AllowRemoteCopyParent)	{	$body["allowRemoteCopyParent"] = $true	}
					$Result = $null	
					$uri = "/volumesets/" + $VolumeSetName
					$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body
				}
		'Stop'	
				{	$body["action"] = 4
					if($Priority)	
						{	if		($Priority -eq "HIGH")	{	$body["priority"] = 1	}
							elseif	($Priority -eq "MED")	{	$body["priority"] = 2	}
							if		($Priority -eq "LOW")	{	$body["priority"] = 3	}
						}
					$Result = $null	
					$uri = "/volumesets/" + $VolumeSetName
					$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
				}
		'Update'
				{	$ParameterBody = @{}
					$body["action"] = 7   
					If ($VolumeSnapshotList) 		{	$ParameterBody["volumeSnapshotList"] = $VolumeSnapshotList    }    
					If ($ReadOnly) 					{	$ParameterBody["readOnly"] = $ReadOnly		 }
					if($ParameterBody.Count -gt 0)	{	$body["parameters"] = $ParameterBody 	}
					$Result = $null	
					$Result = Invoke-A9API -uri '/volumes/' -type 'POST' -body $body 
				}
	}
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
