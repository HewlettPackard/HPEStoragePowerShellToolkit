## 	©2025 Hewlett Packard Enterprise Development LP

Function New-A9Snapshot 
{
<#      
.SYNOPSIS	
	Creating a volume snapshot, or a group of volume snapshots, or a Volume Set snapshot
.DESCRIPTION	
	Creating a volume snapshot, or a group of volume snapshots, or a Volume Set snapshot
.PARAMETER Volume
	The parameter specifies the name of the volume from which you want to create a snapshot for. 
	This must be a single volume or you may use volume1,volume2,volume3 style seperation be sure that no spaces exist between the , and the values.
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
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. This can be used for debugging as well as a method to learn how the
    RestAPI functions.
.EXAMPLE    
	ps:> New-A9Snapshot -Volume $val -snpVVName snpvv1

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-A9Snapshot -Volume Vol1,Vol2,Vol3 -snpVVName snpvv1 

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-A9Snapshot -VolumeSet VVSet5 -snpVVName snpvv1 -Comment hello

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-A9Snapshot -Volume $val -snpVVName snpvv1 -Comment hello -ReadOnly -ExpirationHours 10

	SUCCESS: volume snapshot:$snpVVName created successfully
.EXAMPLE	
	ps:> New-A9Snapshot -Volume $val -snpVVName snpvv1 -AddToSet asvvset

	SUCCESS: volume snapshot:$snpVVName created successfully
#>
[CmdletBinding(DefaultParameterSetName='SingleVVs')]
Param(	[Parameter(Mandatory,ParameterSetName='SingleVVs')]		[String[]]	$Volume,
		[Parameter(Mandatory,ParameterSetName='VVSet')]			[String]	$VolumeSet,
		[Parameter()]											[String]	$snpVVName,
		[Parameter()]											[String]	$Comment,
		[Parameter()]											[Switch]	$syncSnapRCopy,
		[Parameter()]											[switch]	$readOnly,
		[Parameter()][ValidateRange(1,43800)]					[int]		$ExpirationHours,
		[Parameter()][ValidateRange(1,43800)]					[int]		$RetentionHours,
		[Parameter()]											[String]	$AddToSet,
		[Parameter(ParameterSetName='SingleVVs')]				[switch]	$Match,
        [Parameter()]         									[switch]    $ShowAPI
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
	if ( ($Volume).count -gt 1 )		{	$uri = '/volumes/'
											$body["action"] = 8
											$VolumeGroup=@()
											foreach ($Vname in $Volume)
												{	$VItem = @{	$VItem = @{ 'volumeName' = $Vname}	}
													$VolumeGroup += $VItem
												}
										}
	elseif( $Volume )					{	$uri = '/volumes/'+$Volume
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
	if ( $Volume )					{	$ParameterBody["volumeGroup"] 		= "$($VolumeGroup)"	} 	   	
	if ( $ParameterBody.Count -gt 0 )	{	$body["parameters"] = $ParameterBody 					}
	if ( $ShowAPI )
		{   $Result = Invoke-A9API -uri $uri -type 'POST' -body $body -whatif
			return 
		}
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body
	if ( $Result.StatusCode -eq 201 )
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
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
.PARAMETER Volume
	Specifies the name of the volume to copy.
.PARAMETER DestVolume
	Specifies the destination volume.
.PARAMETER DestCPG
	Specifies the destination CPG for an online copy.
.PARAMETER Online
	Enables (true) or disables (false) whether to perform the physical copy online. Defaults to false.
.PARAMETER WWN
	Specifies the WWN of the online copy virtual volume.
.PARAMETER Reduce
	Enables (true) or disables (false) a thinly deduplicated and compressed volume, cannot be used with TPVV.
.PARAMETER TPVV
	Enables (true) or disables (false) whether the online copy is a TPVV. Defaults to false. tpvv and reduce cannot be set to true at the same time.
.PARAMETER SnapCPG
	Specifies the snapshot CPG for an online copy.
.PARAMETER SkipZero
	Enables (true) or disables (false) copying only allocated portions of the source VV from a thin provisioned source. Use only on a newly created destination, 
	or if the destination was re-initialized to zero. Does not overwrite preexisting data on the destination VV to match the source VV unless the same offset is allocated in the source.
.PARAMETER SaveSnapshot
	Enables (true) or disables (false) saving the the snapshot of the source volume after completing the copy of the volume. Defaults to false
.PARAMETER Priority
	Does not apply to online copy.
	HIGH : High priority.
	MED : Medium priority.
	LOW : Low priority.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. This can be used for debugging as well as a method to learn how the
    RestAPI functions.
.EXAMPLE    
	PS:> New-A9VolumeCopy -Volume xyz -DestVolume Test1
.EXAMPLE
    PS:> New-A9VolumeCopy -Volume xyz -DestVolume Test -DestCPG as_cpg
.EXAMPLE
	PS:> New-A9VolumeCopy -Volume xyz -DestVolume Test -Online
.EXAMPLE
	PS:> New-A9VolumeCopy -Volume xyz -DestVolume Test -WWN "60002AC0000000000101142300018F8D"    
.EXAMPLE
	PS:> New-A9VolumeCopy -Volume xyz -DestVolume Test -TPVV
.EXAMPLE
	PS:> New-A9VolumeCopy -Volume xyz -DestVolume Test -SnapCPG as_cpg
.EXAMPLE
	PS:> New-A9VolumeCopy -Volume xyz -DestVolume Test -SkipZero
.EXAMPLE
	PS:> New-A9VolumeCopy -Volume xyz -DestVolume Test -Compression
.EXAMPLE
	PS:> New-A9VolumeCopy -Volume xyz -DestVolume Test -SaveSnapshot
.EXAMPLE
	PS:> New-A9VolumeCopy -Volume $val -DestVolume Test -Priority high
#>
[CmdletBinding(defaultparametersetname='offline')]
Param(	[Parameter(Mandatory)]									[String]	$Volume,
		[Parameter(parametersetname='online',mandatory)]	
		[Parameter(parametersetname='onlineTPVV',mandatory)]
		[Parameter(parametersetname='onlineREDUCE',mandatory)]	[String]	$DestVolume,
		[Parameter(parametersetname='online',mandatory)]	
		[Parameter(parametersetname='onlineTPVV',mandatory)]
		[Parameter(parametersetname='onlineREDUCE',mandatory)]	[String]	$DestCPG,
		[Parameter(parametersetname='online',mandatory)]	
		[Parameter(parametersetname='onlineTPVV',mandatory)]	
		[Parameter(parametersetname='onlineREDUCE',mandatory)]	[switch]	$Online,
		[Parameter(parametersetname='online')]	
		[Parameter(parametersetname='onlineTPVV')]				
		[Parameter(parametersetname='onlineREDUCE')]			[String]	$WWN,
		[Parameter(parametersetname='onlineTPVV',mandatory)]	[switch]	$TPVV,
		[Parameter(parametersetname='onlineREDUCE',mandatory)]	[switch]	$Reduce,
		[Parameter(parametersetname='online')]	
		[Parameter(parametersetname='onlineTPVV')]
		[Parameter(parametersetname='onlineREDUCE')]			[String]	$SnapCPG,
		[Parameter()]											[switch]	$SkipZero,
		[Parameter()]											[switch]	$SaveSnapshot,
		[Parameter(parametersetname='offline')]	[ValidateSet('HIGH','MED','LOW')]						
																[String]	$Priority,
        [Parameter()]          								 	[switch]    $ShowAPI
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
	$uri = '/volumes/'+$Volume
	if ( $ShowAPI )
		{   $Result = Invoke-A9API -uri $uri -type 'POST' -body $body -whatif
			return 
		}
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body
	if( $Result.StatusCode -eq 201)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $Result
		}
	else
		{	Write-error "FAILURE : Executing $($PSCmdlet.MyInvocation.MyCommand.Name) creating Physical copy of a volume : $Volume " 
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
.PARAMETER Volume
	Specifies the name of the destination volume you want to resynchronize.
.PARAMETER Online	
	Enables (true) or disables (false) executing the promote operation on an online volume. The default setting for this switch is off (false).
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.PARAMETER AllowRemoteCopyParent
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been started. If the Remote Copy group has been started, this command fails.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. This can be used for debugging as well as a method to learn how the
    RestAPI functions.
.EXAMPLE    
	PS:> Set-A9VolumeCopy -Volume xxx -resync

	Resynchronizing a physical copy to its parent volume	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory,ParameterSetName='Resync')]
		[Parameter(Mandatory,ParameterSetName='Stop')]
		[Parameter(Mandatory,ParameterSetName='Promote')]
		[Parameter(Mandatory,ParameterSetName='StopPromote')]	[String]	$Volume,

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
		[Parameter(Mandatory,ParameterSetName='StopPromote')]	[Switch]	$StopPromote,
        [Parameter()]          									[switch]    $ShowAPI
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$uri = "/volumes/" + $Volume
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
	if ( $ShowAPI )
		{   $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body -whatif
			return 
		}
	$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body
	if ( $Result.StatusCode -eq 200 )
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $Result		
		}
	else
		{	write-error "FAILURE : While stopping a physical copy : $Volume "
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
.PARAMETER VolumeSet
	Specifies the name of the VV set to copy.
.PARAMETER DestVolume
	Specifies the destination volume set.
.PARAMETER SaveSnapshot
	Enables (true) or disables (false) whether to save the source volume snapshot after completing VV set copy.
.PARAMETER Priority
	Task priority which can be set to HIGH (High priority), MED (Medium priority), LOW (Low priority) or left unset.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. This can be used for debugging as well as a method to learn how the
    RestAPI functions.
.EXAMPLE    
	PS:> New-A9VvSetPhysicalCopy -VolumeSetName Test_delete -DestVolume PERF_AIX38 	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$VolumeSet,
		[Parameter(Mandatory)]	[String]	$DestVolume,
		[Parameter()]			[boolean]	$SaveSnapshot,
		[Parameter()]
		[ValidateSet('HIGH','MED','LOW')][String]	$Priority,
        [Parameter()]           [switch]    $ShowAPI
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
	$uri = '/volumesets/'+$VolumeSet
	if ( $ShowAPI )
		{   $Result = Invoke-A9API -uri $uri -type 'POST' -body $body -whatif
			return 
		}
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body	
	if ( $Result.StatusCode -ne 201 )
		{	write-error "FAILURE : While creating Physical copy of a VV set : $VolumeSet "
			return $Result.StatusDescription
		}
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	return $Result
}
}

Function Set-A9VolumeSetCopy 
{
<#
.SYNOPSIS
	Modify a VV set physical copy either via a Reset (Resync), a Stop, a Move(Promote), or an Update
.DESCRIPTION
	Modify a VV set physical copy either via a Reset (Resync), a Stop, a Move(Promote), or an Update
.PARAMETER VolumeSet
	Specifies the name of the destination VV set to initiate action upon.
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
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. This can be used for debugging as well as a method to learn how the
    RestAPI functions.
.EXAMPLE 
	PS:> Set-A9VolumeSetCopy -VolumeSet xxx -Priority HIGH -reset
.EXAMPLE	
	PS:> Set-A9VolumeSetCopy -VolumeSet xyz
.EXAMPLE	
	PS:> Set-A9VolumeSetCopy -VolumeSet xyz -Online -move
.EXAMPLE	
	PS:> Set-A9VolumeSetCopy -VolumeSet xyz -Priority HIGH -stop
.EXAMPLE	
	PS:> Set-A9VolumeSetCopy -VolumeSet xyz -AllowRemoteCopyParent -move
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory,ParameterSetName='Reset')]
		[Parameter(Mandatory,ParameterSetName='Stop')]
		[Parameter(Mandatory,ParameterSetname='Move')]     	[String]  	$VolumeSet,

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
		[Parameter(Mandatory,ParameterSetName='Update')]	[Switch]	$Update,
        [Parameter()]         								[switch]    $ShowAPI
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$Result = $NULL
	$Meth = 'PUT'
	$uri = "/volumesets/" + $VolumeSet
	$PriVal = @{'HIGH'=1;'MED'=2;'LOW'=3}
	Switch ( $PSCmdlet.ParameterSetName )
	{	'Reset'	{	$body["action"] = 3
					if($Priority)					{	$body["priority"] = $PriVal[$Priority]	}
				}
		'Move'	{	$body["action"] = 5
					if($Online)						{	$body["online"] = $true	}	
					if($Priority)					{	$body["priority"] = $PriVal[$Priority]	}
					if($AllowRemoteCopyParent)		{	$body["allowRemoteCopyParent"] = $true	}
				}
		'Stop'	{	$body["action"] = 4
					if($Priority)					{	$body["priority"] = $PriVal[$Priority]	}
				}
		'Update'{	$ParameterBody = @{}
					$body["action"] = 6   
					If ($VolumeSnapshotList) 		{	$ParameterBody["volumeSnapshotList"] = $VolumeSnapshotList    }    
					If ($ReadOnly) 					{	$ParameterBody["readOnly"] = $ReadOnly		 }
					if($ParameterBody.Count -gt 0)	{	$body["parameters"] = $ParameterBody 	}
					$Meth = 'POST'
					$uri = '/volumes/' 
				}
	}
	if ( $ShowAPI )
		{   $Result = Invoke-A9API -uri $uri -type $Meth -body $body -whatif
			return 
		}
	$Result = Invoke-A9API -uri $uri -type $Meth -body $body 
	if ( $Result.StatusCode -eq 200 )
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $Result			
		}
	else
		{	write-error "FAILURE : While Executing $($PSCmdlet.MyInvocation.MyCommand.Name) Updating virtual copies or VV-sets : $VolumeSnapshotList " 
			return $Result.StatusDescription
		}
}
}
