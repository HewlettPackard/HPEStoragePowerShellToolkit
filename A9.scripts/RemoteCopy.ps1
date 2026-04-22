## 	©2025 Hewlett Packard Enterprise Development LP

##### New Commands
Function New-A9RCopyGroup 
{
<#      
.SYNOPSIS	
	Create a Remote Copy group
.DESCRIPTION	
    Create a Remote Copy group
.PARAMETER RcgName
	Specifies the name of the Remote Copy group to create.
.PARAMETER Domain
	Specifies the domain in which to create the Remote Copy group.
.PARAMETER TargetName
	Specifies the target name associated with the Remote Copy group to be created.
.PARAMETER Mode
	Specifies the volume group mode.
	SYNC : Remote Copy group mode is synchronous.
	PERIODIC : Remote Copy group mode is periodic. Although WSAPI 1.5 and later supports PERIODIC 2, Hewlett Packard Enterprise recommends using PERIODIC 3.
	PERIODIC : Remote Copy group mode is periodic.
	ASYNC : Remote Copy group mode is asynchronous.
.PARAMETER UserCPG
	Specifies the user CPG used for autocreated target volumes.(Required if you specify localUserCPG.Otherwise,optional.)
.PARAMETER SnapCPG
	Specifies the snap CPG used for auto-created target volumes.(Required if you specify localSnapCPG.Otherwise,optional.)
.PARAMETER LocalUserCPG
	CPG used for autocreated volumes. (Required if you specify localSnapCPG;Otherwise,optional.)
.PARAMETER LocalSnapCPG
	Specifies the local snap CPG used for autocreated volumes.(Optional field. It is required if localUserCPG is specified.)
.EXAMPLE
	PS:> New-A9RCopyGroup -RcgName xxx -TargetName xxx -Mode SYNC
.EXAMPLE	
	PS:> New-A9RCopyGroup -RcgName xxx -TargetName xxx -Mode PERIODIC -Domain xxx
.EXAMPLE	
	PS:> New-A9RCopyGroup -RcgName xxx -TargetName xxx -Mode ASYNC -UserCPG xxx -LocalUserCPG xxx -SnapCPG xxx -LocalSnapCPG xxx
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory)]			[String]	$RcgName,
	[Parameter()]					[String]	$Domain,
	[Parameter(Mandatory)]			[String]	$TargetName,
	[Parameter(Mandatory)]
	[ValidateSet('SYNC','PERIODIC','ASYNC')]				
									[String]	$Mode,
	[Parameter()]					[String]	$UserCPG,
	[Parameter()]					[String]	$SnapCPG,
	[Parameter()]					[String]	$LocalUserCPG,
	[Parameter()]					[String]	$LocalSnapCPG
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$TargetsObj = @()
	$TargetsBody = @{}
	If ($RcgName)				{	$body["name"] = "$($RcgName)"   }  
	If ($Domain) 				{	$body["domain"] = "$($Domain)"   }
	If ($TargetName) 			{	$TargetsBody["targetName"] = "$($TargetName)"		    }
	if($Mode -eq "SYNC")		{	$TargetsBody["mode"] = 1	}
	if($Mode -eq "PERIODIC")	{	$TargetsBody["mode"] = 3	}
	if($Mode -eq "ASYNC")		{	$TargetsBody["mode"] = 4	}
	If ($UserCPG) 				{	$TargetsBody["userCPG"] = "$($UserCPG)"  }
	If ($SnapCPG) 				{	$TargetsBody["snapCPG"] = "$($SnapCPG)"    }
	If ($LocalUserCPG) 			{	$body["localUserCPG"] = "$($LocalUserCPG)"    }
	If ($LocalSnapCPG) 			{	$body["localSnapCPG"] = "$($LocalSnapCPG)"    }
	if($TargetsBody.Count -gt 0){	$TargetsObj += $TargetsBody 	}
	if($TargetsObj.Count -gt 0)	{	$body["targets"] = $TargetsObj 	}
    $Result = $null	
    $Result = Invoke-A9API -uri '/remotecopygroups' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
	{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
		return $Result
	}
	else
	{	Write-Error "Failure:  While Creating a Remote Copy group : $RcgName " 
		return $Result.StatusDescription
	}
}
}

Function New-A9RCopyTarget 
{
<#      
.SYNOPSIS	
	Creating a Remote Copy target
.DESCRIPTION	
    Creating a Remote Copy target
.EXAMPLE	
	PS:> New-A9RCopyTarget -TargetName xxx -IP
.EXAMPLE	
	PS:> New-A9RCopyTarget -TargetName xxx  -NodeWWN xxx -FC
.PARAMETER TargetName
	Specifies the name of the target definition to create, up to 24 characters.
.PARAMETER IP
	IP : IP Target Type	
.PARAMETER FC
	FC : FC Target Type
.PARAMETER NodeWWN
	WWN of the node on system2.
.PARAMETER PortPos
	Specifies the port information of system1 (n:s:p) for Remote Copy.
.PARAMETER Link
	Specifies the link for system2. If the linkProtocolType , is IP, specify an IP address for the corresponding port on system2. If the linkProtocolType is FC, specify the WWN of the peer port on system2.
.PARAMETER Disabled
	Using this switch will create the target but it will be initially disabled instead of the default behaviour of enabled.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]							[String]	$TargetName,
		[Parameter(Mandatory, ParameterSetName = "IP")]	[Switch]	$IP,
		[Parameter(Mandatory, ParameterSetName = "FC")]	[Switch]	$FC,
		[Parameter(ParameterSetName = "FC")]			[String]	$NodeWWN,
		[Parameter()]									[String]	$PortPos,
		[Parameter()]									[String]	$Link, 
		[Parameter()]									[Switch]	$Disabled
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$PortPosAndLinkBody=@{}	 
    If($TargetName) 	{	$body["name"] = "$($TargetName)" }
	If($IP) 			{	$body["type"] = 1  	}
	ElseIf ($FC) 		{	$body["type"] = 2   }
	If($NodeWWN) 		{	$body["nodeWWN"] = "$($NodeWWN)"}
	If($PortPos) 
		{	$Obj=@{}
			$Obj["portPos"] = "$($PortPos)"
			$PortPosAndLinkBody += $Obj
		}
	If($Link) 
		{	$Obj=@{}
			$Obj["link"] = "$($Link)"
			$PortPosAndLinkBody += $Obj
		}
	If($Disabled) 	{	$body["disabled"] = $true	 }
	if($PortPosAndLinkBody.Count -gt 0)	{	$body["portPosAndLink"] = $PortPosAndLinkBody 	}
    $Result = $null
    $Result = Invoke-A9API -uri '/remotecopytargets' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $Result
		}
	else
		{	Write-Error "Failure:  While creating a Remote Copy target : $TargetName " 
			return $Result.StatusDescription
		}
}
}

Function New-A9SnapRcGroupVv 
{
<#      
.SYNOPSIS	
	Create coordinated snapshots across all Remote Copy group volumes.
.DESCRIPTION	
    Create coordinated snapshots across all Remote Copy group volumes.
.EXAMPLE	
	PS: New-A9SnapRcGroupVv -GroupName xxx -NewVvNmae xxx -Comment "Hello"
.EXAMPLE	
	PS: New-A9SnapRcGroupVv -GroupName xxx -NewVvNmae xxx -VolumeName Test -Comment "Hello"
.EXAMPLE	
	PS: New-A9SnapRcGroupVv -GroupName xxx -NewVvNmae xxx -Comment "Hello" -RetentionHours 1
.EXAMPLE	
	PS: New-A9SnapRcGroupVv -GroupName xxx -NewVvNmae xxx -Comment "Hello" -VolumeName Test -RetentionHours 1
.PARAMETER GroupName
	Group Name
.PARAMETER VolumeName
	The <volume-name> is the name of the volume to be captured (not the name of the new snapshot volume).
.PARAMETER VVNmae
	Specifies a snapshot VV name up to 31 characters in length. 
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the volume.
.PARAMETER ExpirationHous
	Specifies the relative time from the current time when volume expires. Positive integer and in the range of 1 - 43,800 hours (1825 days).
.PARAMETER RetentionHours
	Specifies the amount of time,relative to the current time, that the volume is retained. Positive integer in the range of 1 - 43,800 hours (1825 days).
.PARAMETER SkipBlock
	Enables (true) or disables (false) whether the storage system blocks host i/o to the parent virtual volume during the creation of a readonly snapshot.
	Defaults to false.
#>
[CmdletBinding()]
Param(
		[Parameter(Mandatory)]	[String]	$GroupName,
		[Parameter()]		[String]	$VolumeName,
		[Parameter(Mandatory)]	[String]	$NewVvNmae,
		[Parameter()]					[String]	$Comment,
		[Parameter()]					[int]		$ExpirationHous,
		[Parameter()]					[int]		$RetentionHours,
		[Parameter()]					[Switch]	$SkipBlock
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$ParametersBody=@{}	
	$body["action"] = 1   
	If($NewVvNmae) 		{	$ParametersBody["name"] = "$($NewVvNmae)"	}
	If($Comment) 		{	$ParametersBody["comment"] = "$($Comment)"	}
	If($ExpirationHous) {	$ParametersBody["expirationHous"] = $ExpirationHous	}
	If($RetentionHours) {	$ParametersBody["retentionHours"] = $RetentionHours	}
	If($SkipBlock) 		{	$ParametersBody["skipBlock"] = $true		}
	if($ParametersBody.Count -gt 0)	{	$body["parameters"] = $ParametersBody 	}
    $Result = $null
	if($VolumeName)		{	$uri = "/remotecopygroups/"+$GroupName+"/volumes/"+$VolumeName	}
	else				{	$uri = "/remotecopygroups/"+$GroupName+"/volumes"	}
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body	
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $Result
		}
	else
		{	Write-Error "Failure:  While Creating coordinated snapshots across all Remote Copy group volumes." 
			return $Result.StatusDescription
		}
}
}

######### Add Commands
Function Add-A9VvToRCopyGroup
{
<#      
.SYNOPSIS	
	Admit a volume into a Remote Copy group
.DESCRIPTION	
    Admit a volume into a Remote Copy group
.EXAMPLE	
	PS:> Add-A9VvToRCopyGroup -GroupName xxx -VolumeName xxx -TargetName xxx -SecVolumeName xxx
.PARAMETER GroupName
	Remote Copy group Name.
.PARAMETER VolumeName
	Specifies the name of the existing virtual volume to be admitted to an existing Remote Copy group.
.PARAMETER SnapshotName
	The optional read-only snapshotName is a starting snapshot when the group is started without performing a full resynchronization.
	Instead, for synchronized groups,the volume synchronizes deltas between this snapshotName and the base volume. For periodic groups, the volume synchronizes deltas between this snapshotName and a snapshot of the base.
.PARAMETER VolumeAutoCreation
	If volumeAutoCreation is set to true, the secondary volumes should be created automatically on the target using the CPG associated with the Remote Copy group on that target. This cannot be set to true if the snapshot name is specified.
.PARAMETER SkipInitialSync
	If skipInitialSync is set to true, the volume should skip the initial sync. This is for the admission of volumes that have been presynced with the target volume. This cannot be set to true if the snapshot name is specified.
.PARAMETER DifferentSecondaryWWN
	Setting differentSecondary WWN to true, ensures that the system uses a different WWN on the secondary volume. Defaults to false. Use with volumeAutoCreation
.PARAMETER TargetName
	Specify at least one pair of targetName and secVolumeName.
.PARAMETER SecVolumeName
	Specifies the name of the secondary volume on the target system.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]				[String]	$GroupName,
		[Parameter(Mandatory)]	[String]	$VolumeName,
		[Parameter()]								[String]	$SnapshotName,
		[Parameter()]								[boolean]	$VolumeAutoCreation,
		[Parameter()]								[boolean]	$SkipInitialSync,
		[Parameter()]								[boolean]	$DifferentSecondaryWWN,
		[Parameter(Mandatory)]				[String]	$TargetName,
		[Parameter(Mandatory)]				[String]	$SecVolumeName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$TargetsBody=@{}	
	$body["action"] = 1   
    If ($VolumeName) 			{	$body["volumeName"] = "$($VolumeName)"    }
	If ($SnapshotName) 			{	$body["snapshotName"] = "$($SnapshotName)"    }
	If ($VolumeAutoCreation) 	{	$body["volumeAutoCreation"] = $VolumeAutoCreation    }
	If ($SkipInitialSync) 		{	$body["skipInitialSync"] = $SkipInitialSync }
	If ($DifferentSecondaryWWN) {	$body["differentSecondaryWWN"] = $DifferentSecondaryWWN    }
	If ($TargetName) 
		{	$Obj=@{}
			$Obj["targetName"] = "$($TargetName)"
			$TargetsBody += $Obj
		}	
	If ($SecVolumeName) 
		{	$Obj=@{}
			$Obj["secVolumeName"] = "$($SecVolumeName)"
			$TargetsBody += $Obj		
		}	
	if($TargetsBody.Count -gt 0)	{	$body["targets"] = $TargetsBody 	}
    $Result = $null
	$uri = "/remotecopygroups/"+$GroupName+"/volumes"
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
	{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
		return $Result
	}
	else
	{	Write-Error "Failure:  While Admitting a volume into a Remote Copy group : $VolumeName " 
		return $Result.StatusDescription
	}
}
}

Function Add-A9TargetToRCopyGroup 
{
<#      
.SYNOPSIS	
	Admitting a target into a Remote Copy group
.DESCRIPTION	
    Admitting a target into a Remote Copy group
.EXAMPLE	
	PS:> Add-A9TargetToRCopyGroup -GroupName xxx -TargetName xxx
.EXAMPLE	
	PS:> Add-A9TargetToRCopyGroup -GroupName xxx -TargetName xxx -Mode xxx
.EXAMPLE	
	PS:> Add-A9TargetToRCopyGroup -GroupName xxx -TargetName xxx -Mode xxx -LocalVolumeName xxx -RemoteVolumeName xxx
.PARAMETER GroupName
	Remote Copy group Name.
.PARAMETER TargetName
	Specifies the name of the target to admit to an existing Remote Copy group.
.PARAMETER Mode
	Specifies the mode of the target being added.
	SYNC : Remote Copy group mode is synchronous.
	PERIODIC : Remote Copy group mode is periodic. Although WSAPI 1.5 and later supports PERIODIC 2, Hewlett Packard Enterprise recommends using PERIODIC 3.
	PERIODIC : Remote Copy group mode is periodic.
	ASYNC : Remote Copy group mode is asynchronous.
.PARAMETER LocalVolumeName
	Name of the volume on the primary.
.PARAMETER RemoteVolumeName
	Name of the volume on the target.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$GroupName,
		[Parameter(Mandatory)]	[String]	$TargetName,
		[Parameter()]
		[ValidateSet('SYNC','PERIODIC','ASYNC')]				[String]	$Mode,
		[Parameter()]					[String]	$LocalVolumeName,
		[Parameter()]					[String]	$RemoteVolumeName
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$volumeMappingsObj=@()	
	$volumeMappingsBody=@{}	
    If($TargetName) 		{	$body["targetName"] = "$($TargetName)"    }
	if($Mode -eq "SYNC")	{	$body["mode"] = 1					}
	if($Mode -eq "PERIODIC"){	$body["mode"] = 3			}
	if($Mode -eq "ASYNC")	{	$body["mode"] = 4			}
	If($LocalVolumeName) 	{	$volumeMappingsBody["localVolumeName"] = "$($LocalVolumeName)" 		}
	If($RemoteVolumeName) 	{	$volumeMappingsBody["remoteVolumeName"] = "$($RemoteVolumeName)"    }
	if($volumeMappingsBody.Count -gt 0)	{	$volumeMappingsObj += $volumeMappingsBody 	}
	if($volumeMappingsObj.Count -gt 0)	{	$body["volumeMappings"] = $volumeMappingsObj 	}
    $Result = $null
	$uri = "/remotecopygroups/"+$GroupName+"/targets"
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $Result		
		}
	else
		{	Write-Error "Failure:  While admitting a target into a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName " 
			return $Result.StatusDescription
		}
}
}

######### Update Commands
Function Set-A9RCopyGroup
{
<#
.SYNOPSIS
	Modify a Remote Copy group properties, or issue commands to sync or start a copy group
.DESCRIPTION
	Modify a Remote Copy group.
.PARAMETER GroupName
	Remote Copy group to update. You can choose to reset the LocalUserCPG/LocalSnapCPG/RemoteUserCPG/RemoteSnapCPG, or unset either the Local/RemoteUserCPG, 
	or unset the LocalRemoteSnapCPG, or modofiy a default policy, or change the mode of the replication.
.PARAMETER LocalUserCPG
	Specifies the local user CPG for use by autocreated volumes.
	Specify together with:
	• localSnapCPG
	• remoteUserCPG
	• remoteSnapCPG
.PARAMETER LocalSnapCPG	
	Specifies the local snap CPG for use by autocreated volumes.
	Specify together with:
	• localSnapCPG
	• remoteUserCPG
	• remoteSnapCPG
.PARAMETER RemoteUserCPG
	Specifies the user CPG on the target used by autocreated volumes.
	Specify together with:
	• localSnapCPG
	• LocalUserCPG
	• remoteSnapCPG
.PARAMETER RemoteSnapCPG
	Specifies the snap CPG on the target for use by autocreated volumes.
	Specify together with:
	• localSnapCPG
	• remoteUserCPG
	• LocalSnapCPG
.PARAMETER Mode
	Specifies the volume group mode.
	SYNC : Remote Copy group mode is synchronous.
	PERIODIC : Remote Copy group mode is periodic. Although WSAPI 1.5 and later supports PERIODIC 2, Hewlett Packard Enterprise recommends using PERIODIC 3.
	PERIODIC : Remote Copy group mode is periodic.
	ASYNC : Remote Copy group mode is asynchronous.
.PARAMETER Policies
	You may set any one of the following; 'active_active','no_active_active','auto_failover','no_auto_failover','auto_recover','no_auto_recover','auto_synchronize','no_auto_synchronize','mirror_config',
				 'over_per_alert','no_over_per_alert','path_management','no_path_management','mt_pp'
.PARAMETER RemoveCPG
	You can choose to unset the Local/Remote UserCPG or the Local/Remote SnapCPG.
.PARAMETER NoResyncSnapshot
	Enables (true) or disables (false) saving the resynchronization snapshot. Applicable only to Remote Copy groups in asynchronous periodic mode.
	Defaults to false.
.PARAMETER TargetName
	The target name associated with this group.
.PARAMETER FullSync
	Enables (true) or disables (false)forcing a full synchronization of the Remote Copy group, even if the volumes are already synchronized.
	Applies only to volume groups in synchronous mode, and can be used to resynchronize volumes that have become inconsistent.
	Defaults to false.
.PARAMETER NoResyncSnapshot
	Enables (true) or disables (false) saving the resynchronization snapshot. Applicable only to Remote Copy groups in asynchronous periodic mode.
	Defaults to false.
.PARAMETER TargetName
	The target name associated with this group.
.PARAMETER FullSync
	Enables (true) or disables (false)forcing a full synchronization of the Remote Copy group, even if the volumes are already synchronized.
	Applies only to volume groups in synchronous mode, and can be used to resynchronize volumes that have become inconsistent.
	Defaults to false.
.PARAMETER NoSnapshot
	If true, this option turns off creation of snapshots in synchronous and periodic modes, and deletes the current synchronization snapshots.
	The default setting is false.
.PARAMETER GroupName
	Group Name.
.PARAMETER SkipInitialSync
	If true, the volume should skip the initial synchronization and sets the volumes to a synchronized state.
	The default setting is false.
.PARAMETER VolumeName
	volume name.
.PARAMETER SnapshotName
	Snapshot name.	
	Note : When used, you must specify all the volumes in the group. While specifying the pair, the starting snapshot is optional.
	When not used, the system performs a full resynchronization of the volume.
.PARAMETER SkipStart
	If true, groups are not started after role reversal is completed. Valid for only FAILOVER, RECOVER, and RESTORE operations.
	The default is false.
.PARAMETER SkipSync
	If true, the groups are not synchronized after role reversal is completed. Valid for FAILOVER, RECOVER, and RESTORE operations only.
	The default setting is false.
.PARAMETER DiscardNewData
	If true and the group has multiple targets, don’t check other targets of the group to see if newer data should be pushed from them. Valid for FAILOVER operation only.
	The default setting is false.
.PARAMETER SkipPromote
	If true, the snapshots of the groups that are switched from secondary to primary are not promoted to the base volume. Valid for FAILOVER and REVERSE operations only.
	The default setting is false.
.PARAMETER NoSnapshot
	If true, the snapshots are not taken of the groups that are switched from secondary to primary. Valid for FAILOVER, REVERSE, and RESTOREoperations.
	The default setting is false.
.PARAMETER StopGroups
	If true, the groups are stopped before performing the reverse operation. Valid for REVERSE operation only. 
	The default setting is false.
.PARAMETER LocalGroupsDirection
	If true, the group’s direction is changed only on the system where the operation is run. Valid for REVERSE operation only.
	The default setting is false.
.PARAMETER Sync
	Synchronize a Remote Copy group.
.PARAMETER Stop
	Stop a Remote Copy group.
.PARAMETER Start
	Start a Remote Copy group.
.PARAMETER Restart

#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]							[String]	$GroupName,
		[Parameter(Mandatory,ParameterSetName='CPGs')]	[String]	$LocalUserCPG,
		[Parameter(Mandatory,ParameterSetName='CPGs')]	[String]	$LocalSnapCPG,	  
		[Parameter(Mandatory,ParameterSetName='CPGs')]	[String]	$RemoteUserCPG,
		[Parameter(Mandatory,ParameterSetName='CPGs')]	[String]	$RemoteSnapCPG,
		[Parameter(Mandatory,ParameterSetName='Mode')]
		[ValidateSet('SYNC','ASYNC','PERIODIC')]		[String]	$Mode,
		[Parameter(Mandatory,ParameterSetName='policies')]
		[ValidateSet('active_active','no_active_active','auto_failover','no_auto_failover','auto_recover','no_auto_recover','auto_synchronize','no_auto_synchronize','mirror_config',
					'over_per_alert','no_over_per_alert','path_management','no_path_management','mt_pp')]
														[String]	$Policies,
		[Parameter(Mandatory,ParameterSetName='UnCPG')]	
		[ValidateSet('unsetUserCPG','unsetSnapCPG')]	[String]	$RemoveCPG,
		[Parameter(ParameterSetName='Sync')]			[switch]	$NoResyncSnapshot,
		[Parameter(ParameterSetName='Sync')]
		[Parameter(ParameterSetName='Stop')]
		[Parameter(ParameterSetName='Start')]
		[Parameter(ParameterSetName='Restore')]			[String]	$TargetName,
		[Parameter(ParameterSetName='Sync')]			[switch]	$FullSync,
		[Parameter(ParameterSetName='Restore')]	
		[Parameter(ParameterSetName='Stop')]			[switch]	$NoSnapshot,
		[Parameter(ParameterSetName='Start')]			[switch]	$SkipInitialSync,
		[Parameter(ParameterSetName='Start')]			[String]	$VolumeName,
		[Parameter(ParameterSetName='Start')]			[String]	$SnapshotName,

		[Parameter(ParameterSetName='Restore')]			[Switch]	$SkipStart,
		[Parameter(ParameterSetName='Restore')]			[Switch]	$SkipSync,
		[Parameter(ParameterSetName='Restore')]			[Switch]	$DiscardNewData,
		[Parameter(ParameterSetName='Restore')]			[Switch]	$SkipPromote,
		[Parameter(ParameterSetName='Restore')]			[Switch]	$StopGroups,
		[Parameter(ParameterSetName='Restore')]			[Switch]	$LocalGroupsDirection,

		[Parameter(Mandatory,ParameterSetName='Sync')]	[switch]	$Sync,
		[Parameter(Mandatory,ParameterSetName='Stop')]	[switch]	$Stop,
		[Parameter(Mandatory,ParameterSetName='Start')]	[switch]	$Start,
		[Parameter(Mandatory,Parametersetname='Restore')][switch]	$restore
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$TargetsBody=@()
	switch($PSCmdlet.ParameterSetName)
		{	'CPGs'	{	$body["localUserCPG"] = "$($LocalUserCPG)"
						$body["localSnapCPG"] = "$($LocalSnapCPG)"
						$Obj=@{}
						$Obj["remoteUserCPG"] = "$($RemoteUserCPG)"
						$Obj["remoteSnapCPG"] = "$($RemoteSnapCPG)"
						$TargetsBody += $Obj
						$Obj["targets"] = $TargetBody
					}
			'Mode'	{	$body["mode"] = "$Mode"
					}
			'policies'{	$body["policies"] = "$Policies"
					}
			'UnCPG'	{	if ($RemoveCPG -eq 'unsetUserCPG')	{ $body['unsetUserCPG'] = $true}
						if ($RemoveCPG -eq 'unsetSnapCPG')	{ $body['unsetSnapCPG'] = $true}	
					}
			'Sync'	{	$body["action"] = 5		
						If ($NoResyncSnapshot) 	{	$body["noResyncSnapshot"] = $true    }	
						If ($TargetName) 		{	$body["targetName"] = "$($TargetName)" }
						If ($FullSync) 			{	$body["fullSync"] = $true    }	
					}
			'Stop'	{
						$body = @{}
						$body["action"] = 4			
						If ($NoSnapshot) 	{	$body["noSnapshot"] = $true	    }	
						If ($TargetName) 	{	$body["targetName"] = "$($TargetName)"    }		
					}
			'Start'	{	$ObjStartingSnapshots=@{}
						$body["action"] = 3		
						If ($SkipInitialSync){	$body["skipInitialSync"] = $true	    }	
						If ($TargetName) 	{	$body["targetName"] = "$($TargetName)"}	
						If ($VolumeName)	{	$Obj=@{}
												$Obj["volumeName"] = "$($VolumeName)"
												$ObjStartingSnapshots += $Obj				
											}
						If ($SnapshotName)	{	$Obj=@{}
												$Obj["snapshotName"] = "$($SnapshotName)"
												$ObjStartingSnapshots += $Obj				
											}
						if($ObjStartingSnapshots.Count -gt 0)	{	$body["startingSnapshots"] = $ObjStartingSnapshots 	}
					}
		}
	$uri = '/remotecopygroups/'+ $GroupName
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return Get-A9System				
		}
	else
		{	Write-Error "Failure:  While Updating Remote Copy group." 
			return $Result.StatusDescription
		}
}
}

Function Update-A9RCopyGroupTarget 
{
<#
.SYNOPSIS
	Modifying a Remote Copy group target.
.DESCRIPTION
	Modifying a Remote Copy group target.
.EXAMPLE
	PS:> Update-A9RCopyGroupTarget -GroupName xxx -TargetName xxx -Mode SYNC 
.PARAMETER GroupName
	Remote Copy group Name
.PARAMETER TargetName
	Target Name
.PARAMETER SnapFrequency
	Specifies the interval in seconds at which Remote Copy takes coordinated snapshots. Range is 300–31622400 seconds (1 year).Applicable only for Async mode.
.PARAMETER RmSnapFrequency
	Enables (true) or disables (false) the snapFrequency interval. If false, and the snapFrequency value is positive, then the snapFrequency value is set.
.PARAMETER SyncPeriod
	Specifies that asynchronous periodic mode groups should be periodically synchronized to the<period_value>.Range is 300 –31622400 secs (1yr).
.PARAMETER RmSyncPeriod
	Enables (true) or disables (false) the syncPeriod reset time. If false, and syncPeriod value is positive, then set.
.PARAMETER Mode
	Specifies the volume group mode.
	SYNC : Remote Copy group mode is synchronous.
	PERIODIC : Remote Copy group mode is periodic. Although WSAPI 1.5 and later supports PERIODIC 2, Hewlett Packard Enterprise recommends using PERIODIC 3.
	PERIODIC : Remote Copy group mode is periodic.
	ASYNC : Remote Copy group mode is asynchronous.
.PARAMETER AutoRecover
	If the Remote Copy is stopped as a result of links going down, the Remote Copy group can be automatically restarted after the links come back up.
.PARAMETER OverPeriodAlert
	If synchronization of an asynchronous periodic Remote Copy group takes longer to complete than its synchronization period, an alert is generated.
.PARAMETER AutoFailover
	Automatic failover on a Remote Copy group.
.PARAMETER PathManagement
	Automatic failover on a Remote Copy group.
.PARAMETER MultiTargetPeerPersistence
	Specifies that the group is participating in a Multitarget Peer Persistence configuration. The group must have two targets, one of which must be synchronous. The synchronous group target also requires pathManagement and autoFailover policy settings.
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory)]						[String]	$GroupName,
	[Parameter(Mandatory)]						[String]	$TargetName,
	[Parameter()]								[int]		$SnapFrequency,
	[Parameter()]								[Boolean]	$RmSnapFrequency,
	[Parameter()]								[int]		$SyncPeriod,
	[Parameter()]								[Boolean]	$RmSyncPeriod,
	[Parameter()][ValidateSet('SYNC','PERIODIC')][String]	$Mode,
	[Parameter()]								[int]		$AutoRecover,
	[Parameter()]								[int]		$OverPeriodAlert,
	[Parameter()]								[int]		$AutoFailover,
	[Parameter()]								[int]		$PathManagement,
	[Parameter()]								[int]		$MultiTargetPeerPersistence
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$PoliciesBody=@{}
	If ($SyncPeriod) 		{	$body["syncPeriod"] = $SyncPeriod    }	
	If ($RmSyncPeriod) 		{	$body["rmSyncPeriod"] = $RmSyncPeriod					    }
	If ($SnapFrequency) 	{	$body["snapFrequency"] = $SnapFrequency    }
	If ($RmSnapFrequency) 	{	$body["rmSnapFrequency"] = $RmSnapFrequency    }
	if($Mode -eq "SYNC")	{	$body["mode"] = 1	}
	if($Mode -eq "PERIODIC"){	$body["mode"] = 2	}
	If ($AutoRecover) 		{	$PoliciesBody["autoRecover"] = $AutoRecover    }
	If ($OverPeriodAlert) 	{	$PoliciesBody["overPeriodAlert"] = $OverPeriodAlert    }
	If ($AutoFailover) 		{	$PoliciesBody["autoFailover"] = $AutoFailover    }
	If ($PathManagement) 	{	$PoliciesBody["pathManagement"] = $PathManagement    }
	If ($MultiTargetPeerPersistence){	$PoliciesBody["multiTargetPeerPersistence"] = $MultiTargetPeerPersistence    }	
	if($PoliciesBody.Count -gt 0)	{	$body["policies"] = $PoliciesBody	}
    $Result = $null
	$uri = '/remotecopygroups/'+ $GroupName+'/targets/'+$TargetName
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 	
	if($Result.StatusCode -eq 200)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return Get-A9System		
		}
	else
		{	Write-Error "Failure:  While Updating Remote Copy group target." 
			return $Result.StatusDescription
		}
}
}

Function Set-A9RCopyTarget 
{
<#
.SYNOPSIS
	Modify a Remote Copy Target or Quorum settings on a Target
.DESCRIPTION
	Modify a Remote Copy Target or Quorum settings on a Target
.PARAMETER TargetName
	The <target_name> parameter corresponds to the name of the Remote Copy target you want to modify. It can also be used to manipulate Quorum Witness via creation, removale, starting, stoping, and checking.
.PARAMETER NewTargetName
	A New Name to change the target to.
.PARAMETER MirrorConfig
	Enables (true) or disables (false) the duplication of all configurations involving the specified target.
	Defaults to true. Use false to allow recovery from an unusual error condition only, and only after consulting your Hewlett Packard Enterprise representative.
.PARAMETER CreateQuorumWitness
	When you create a new Quorum Witness you will also need to specify a WitnessIP and optionally if it should use SSL, and if it should use a non-default SSL port or Node.
.PARAMETER RemoveQuorumWitness
	Can be used to remove a quorum witness
.PARAMETER StartQuorumWitness
	Can be used to start a quorum witness 
.PARAMETER StopQuorumWitness
	Can be used to stop a quorum witness
.PARAMETER CheckQuorumWitness
	Can be used to check the Quorum Witness you will also need to specify a WitnessIP and optionally if it should use SSL, and if it should use a non-default SSL port or Node.
.EXAMPLE
	PS:> Set-A9RCopyTarget -TargetName xxx
.EXAMPLE
	PS:> Set-A9RCopyTarget -TargetName xxx -MirrorConfig $true
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]								[String]	$TargetName,
		[Parameter(ParameterSetName='Default')]				[String]	$NewName,
		[Parameter(ParameterSetName='Default')]				[Switch]	$MirrorConfig,
		[Parameter(mandatory, ParameterSetName='Createq')]	[switch]	$CreateQuorumWitness,						
		[Parameter(mandatory, ParameterSetName='Removeq')]	[switch]	$RemoveQuorumWitness,						
		[Parameter(mandatory, ParameterSetName='Startq')]	[switch]	$StartQuorumWitness,						
		[Parameter(mandatory, ParameterSetName='Stopq')]	[switch]	$StopQuorumWitness,						
		[Parameter(mandatory, ParameterSetName='Checkq')]	[switch]	$CheckQuorumWitness,						
		[Parameter(mandatory, ParameterSetName='Createq')]
		[Parameter(mandatory, PArameterSetName='Checkq')]	[string]	$WitnessIP,
		[Parameter(ParameterSetName='Createq')]
		[Parameter(PArameterSetName='Checkq')]				[switch]	$UseSSL,
		[Parameter(ParameterSetName='Createq')]
		[Parameter(PArameterSetName='Checkq')]				[int]		$SSLPort,
		[Parameter(PArameterSetName='Checkq')]
		[ValidateRange(0,7)]								[int]		$NodeId	
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$PoliciesBody = @{}
	$Obj=@{}
	switch($PSCmdlet.ParameterSetName)
	{	'Default'	{	If ($MirrorConfig) 				{	$Obj["mirrorConfig"] = $true 	}
						else							{	$Obj["mirrorConfig"] = $false	}
						if ($NewName)					{	$Obj['name'] = $NewName 		}
						$PoliciesBody += $Obj
						if($PoliciesBody.Count -gt 0)	{	$body["policies"] = $PoliciesBody 	}
					}
		'CreateQ'	{	$Body['action'] = 1
						$Obj['witnessIP'] = $WitnessIP
						$Obj['ssl'] = $true
						if ( $SSLPort ) {	$Obj['port'] = $SSLPort	}
						$PoliciesBody += $Obj
						if($PoliciesBody.Count -gt 0)	{	$body["parameters"] = $PoliciesBody 	}
					}
		'RemoveQ'	{	$Body['action'] = 2
					}
		'StartQ'	{	$Body['action'] = 3
					}
		'StopQ'		{	$Body['action'] = 4
					}
		'CheckQ'	{	$Body['action'] = 5
						$Obj['witnessIP'] = $WitnessIP
						$Obj['ss'] = $true
						if ( $SSLPort ) {	$Obj['port'] = $SSLPort		}
						if ( $NodeId)	{ 	$obj['nodeId'] = $NodeId	}
						$PoliciesBody += $Obj
						if($PoliciesBody.Count -gt 0)	{	$body["parameters"] = $PoliciesBody 	}
					}
	}
    $Result = $null
	$uri = '/remotecopytargets/'+ $TargetName
	Write-Verbose "Request: Request to Update-A9RCopyTarget (Invoke-A9API)." 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
	{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	}
	else
	{	Write-Error "Failure:  While Updating Remote Copy Target / Target Name : $TargetName." 
		return $Result.StatusDescription
	}
}
}


##### Get Commands
Function Get-A9RCopyInfo 
{
<#
.SYNOPSIS	
	Get overall Remote Copy information unless a LINKname or returnlinks is specified.
.DESCRIPTION
	Get overall Remote Copy information unless a LINKname or returnlinks is specified.
.PARAMETER LinkName
	if Specified, the command will return only the Link name given
.PARAMETER ReturnLinks
	If specified, the command will return all links.
.EXAMPLE
	PS:> Get-A9RCopyLink -LinkName xxx
	
	Get Single Remote Copy Link
.EXAMPLE
	PS:> Get-A9RCopyInfo

		mode status asyncEnabled links
		---- ------ ------------ -----
   		2      1        False 		{@{href=https://192.168.16.123/api/v1/remotecopy; rel=self}, @{href=h...}

	Get overall Remote Copy information
#>
[CmdletBinding(DefaultParameterSetName='Info')]
Param(
	[Parameter(ParameterSetName='Link')]	[String]	$LinkName,
	[Parameter(ParameterSetName='Link')]	[switch]	$ReturnLinks
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$uri = '/remotecopy'
	Switch($PSCmdlet.ParameterSetName)
		{	'Info'	{	write-verbose "Running RemoteCopy Info"
					}
			'Link'	{	$uri = $uri + 'links'	
						if($LinkName)	{	$uri = $uri+'/'+$LinkName	}
					}
		}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
			write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $dataPS
		}
	else
		{	Write-Error "Failure:  While Executing Get-A9RCopyInfo." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9RCopyTarget 
{
<#
.SYNOPSIS	
	Get all or single Remote Copy targets
.DESCRIPTION
	Get all or single Remote Copy targets
.EXAMPLE
	PS:> Get-A9RCopyTarget
.EXAMPLE
	PS:> Get-A9RCopyTarget -TargetName xxx		
.PARAMETER TargetName	
    Remote Copy Target Name
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$TargetName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$uri = '/remotecopytargets'
	if($TargetName)	{	$uri = $uri+'/'+$TargetName	}
	$Result = Invoke-A9API -uri $uri -type 'GET' 		  
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $dataPS
		}
	else
		{	Write-Error "Failure:  While Executing Get-A9RCopyTarget." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9RCopyGroup 
{
<#
.SYNOPSIS	
	Get all or single Remote Copy Group, or Remote Copy Group Targets, or Remote Copy Group Volumes
.DESCRIPTION
	Get all or single Remote Copy Group, or Remote Copy Group Targets, or Remote Copy Group Volumes
	If used without any parameters, it will return all the Copy Groups.
.PARAMETER GroupName	
    Remote Copy Group Name
.PARAMETER TargetName	
    Target Name
.PARAMETER VolumeName	
    Remote Copy Volume Name
.PARAMETER ReturnTargets
	A Switch to return all Targets
.PARAMETER ReturnVolumes
	A Switch to return all Volumes	
.EXAMPLE
	PS:> Get-A9RCopyGroup

	Get List of Groups
.EXAMPLE
	PS:> Get-A9RCopyGroup -GroupName XXX

	Get a single Groups of given name
.EXAMPLE
	PS:> Get-A9RCopyGroup -TargetName XXX

	Get a single Target name from the complete list of target names
.EXAMPLE
	PS:> Get-A9RCopyGroup -ReturnTargetNames

	Return all Target names 
.EXAMPLE
	PS:> Get-A9RCopyGroup -VolumeName XXX

	Get a single Volume from the complete list of Volumes
.EXAMPLE
	PS:> Get-A9RCopyGroup -ReturnVolumeNames

	Get All Volume 
#>
[CmdletBinding(DefaultParameterSetName='ByGroupName')]
Param(	[Parameter(ParameterSetName='ByGroupName')]		
		[Parameter(Mandatory,ParameterSetName='ByTargetName')]	
		[Parameter(Mandatory,ParameterSetName='ByVolumeName')]	[String]	$GroupName,

		[Parameter(ParameterSetName='ByTargetName')]			[String]	$TargetName,
		[Parameter(ParameterSetName='ByVolumeName')]			[String]	$VolumeName,
		[Parameter(parameterSetname='ByTargetName')]			[Switch]	$ReturnTargets,
		[Parameter(parameterSetname='ByVolumeName')]			[Switch]	$ReturnVolumes
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$uri = '/remotecopygroups'						
	Switch($PSCmdlet.ParameterSetName)
	{	'ByGroupName'	{	if ($GroupName) { $uri = $uri + '/' + $GroupName } 
						}
		'ByTargetName'	{	$uri = $uri + '/' + $GroupName + '/targets'
							if($TargetName)		{	$uri = $uri + '/' + $TargetName	}
						}
		'ByVolumeName'	{	$uri = $uri + '/' + $GroupName + '/volumes'	
							if($VolumeName)		{	$uri = $uri+'/'+$VolumeName	}
						}
	}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While executing Get-A9RCopyGroup. Expected result not found with given filter option ." 
					return 
				}	
		}
	else
		{	Write-Error "Failure:  While Executing Get-A9RCopyGroupTarget." 
			return $Result.StatusDescription
		}	
}	
}

################ Remove Commands
Function Remove-A9RCopyGroup
{
<#
.SYNOPSIS
	Remove a Remote Copy group.
.DESCRIPTION
	Remove a Remote Copy group.
.PARAMETER GroupName 
	Group Name.
.PARAMETER KeepSnap 
	To remove a Remote Copy group with the option of retaining the local volume resynchronization snapshot
	The parameter uses one of the following, case-sensitive values:
	• keepSnap = $true
	• keepSnap = $false
.EXAMPLE    
	PS:> Remove-A9RCopyGroup -GroupName xxx -KeepSnap $true 
.EXAMPLE    
	PS:> Remove-A9RCopyGroup -GroupName xxx -KeepSnap $false
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$GroupName,		
		[Parameter()]			[boolean]	$KeepSnap	
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$uri = '/remotecopygroups/'+ $GroupName
	if($keepSnap)	{	$uri = $uri + "?keepSnap=true"	}
	if(!$keepSnap)	{	$uri = $uri + "?keepSnap=false"	}
	$Result = $null
	$Result = Invoke-A9API -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 202)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return
		}
	else
		{	Write-Error "Failure:  While Removing a Remote Copy group : $GroupName " 
			return $Result.StatusDescription
		}    
}	
}

Function Remove-A9TargetFromRCopyGroup 
{
<#      
.SYNOPSIS	
	Remove a target from a Remote Copy group
.DESCRIPTION	
    Remove a target from a Remote Copy group
.PARAMETER GroupName
	Remote Copy group Name.
.PARAMETER TargetName
	Target Name to be removed.  
.EXAMPLE	
	PS:> Remove-A9TargetFromRCopyGroup
.NOTES
	This command utilizes the API command '/remotecopygroups/groupname/targets/'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$GroupName,
		[Parameter(Mandatory)]	[String]	$TargetName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$uri = "/remotecopygroups/"+$GroupName+"/targets/"+$TargetName
	$Result = Invoke-A9API -uri $uri -type 'PUT' 
	$status = $Result.StatusCode
	if($status -eq 201)
	{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
		return $Result
	}
	else
	{	Write-Error "Failure:  While removing  a target from a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName " 
		return $Result.StatusDescription
	}
}
}

Function Remove-A9VvFromRCopyGroup
{
<#      
.SYNOPSIS	
	Dismiss a volume from a Remote Copy group
.DESCRIPTION	
    Dismiss a volume from a Remote Copy group
.PARAMETER GroupName
	Remote Copy group Name.
.PARAMETER VolumeName
	Specifies the name of the existing virtual volume to be admitted to an existing Remote Copy group.
.PARAMETER KeepSnap
	Enables (true) or disables (false) retention of the local volume resynchronization snapshot. Defaults to false. Do not use with removeSecondaryVolu me.
.PARAMETER RemoveSecondaryVolume
	Enables (true) or disables (false) deletion of the remote volume on the secondary array from the system. Defaults to false. Do not use with keepSnap.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$GroupName,
		[Parameter(Mandatory)]	[String]	$VolumeName,
		[Parameter()]					[boolean]	$KeepSnap,
		[Parameter()]					[boolean]	$RemoveSecondaryVolume
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$body["action"] = 1   
    If ($VolumeName) 	{	$body["volumeName"] = "$($VolumeName)"  }
	If ($KeepSnap) 		{	$body["keepSnap"] = $KeepSnap		 	}
	If ($RemoveSecondaryVolume) 	{	$body["removeSecondaryVolume"] = $RemoveSecondaryVolume	}
    $Result = $null
	$uri = "/remotecopygroups/"+$GroupName+"/volumes/"+$VolumeName
    $Result = Invoke-A9API -uri $uri -type 'DELETE' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $Result
		}
	else
		{	Write-Error "Failure:  While Dismissing a volume from a Remote Copy group : $VolumeName " 
			return $Result.StatusDescription
		}
}
}
