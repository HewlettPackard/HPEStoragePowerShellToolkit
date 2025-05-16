####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function New-A9RCopyGroup 
{
<#      
.SYNOPSIS	
	Create a Remote Copy group
.DESCRIPTION	
    Create a Remote Copy group
.EXAMPLE
	PS:> New-A9RCopyGroup -RcgName xxx -TargetName xxx -Mode SYNC
.EXAMPLE	
	PS:> New-A9RCopyGroup -RcgName xxx -TargetName xxx -Mode PERIODIC -Domain xxx
.EXAMPLE	
	PS:> New-A9RCopyGroup -RcgName xxx -TargetName xxx -Mode ASYNC -UserCPG xxx -LocalUserCPG xxx -SnapCPG xxx -LocalSnapCPG xxx
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
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory)]	[String]	$RcgName,
	[Parameter()]		[String]	$Domain,
	[Parameter(Mandatory)]	[String]	$TargetName,
	[Parameter(Mandatory)]
	[ValidateSet('SYNC','PERIODIC','ASYNC')]				[String]	$Mode,
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
	{	write-host "Cmdlet executed successfully" -foreground green
		return $Result
	}
	else
	{	Write-Error "Failure:  While Creating a Remote Copy group : $RcgName " 
		return $Result.StatusDescription
	}
}
}

Function Start-A9RCopyGroup 
{
<#
.SYNOPSIS
	Starting a Remote Copy group.
.DESCRIPTION
	Starting a Remote Copy group.
.EXAMPLE
	PS:> Start-A9RCopyGroup -GroupName xxx

	Starting a Remote Copy group.
.EXAMPLE	
	PS:> Start-A9RCopyGroup -GroupName xxx -TargetName xxx
.EXAMPLE	
	PS:> Start-A9RCopyGroup -GroupName xxx -SkipInitialSync
.PARAMETER GroupName
	Group Name.
.PARAMETER SkipInitialSync
	If true, the volume should skip the initial synchronization and sets the volumes to a synchronized state.
	The default setting is false.
.PARAMETER TargetName
	The target name associated with this group.
.PARAMETER VolumeName
	volume name.
.PARAMETER SnapshotName
	Snapshot name.	
	Note : When used, you must specify all the volumes in the group. While specifying the pair, the starting snapshot is optional.
	When not used, the system performs a full resynchronization of the volume.
#>
[CmdletBinding()]
Param(
		[Parameter(Mandatory)]	[String]	$GroupName,	  
		[Parameter()]					[switch]	$SkipInitialSync,
		[Parameter()]					[String]	$TargetName,
		[Parameter()]					[String]	$VolumeName,
		[Parameter()]					[String]	$SnapshotName
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$ObjStartingSnapshots=@{}
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
    $Result = $null	
	$uri = "/remotecopygroups/" + $GroupName
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	Write-Error "Failure:  While Starting a Remote Copy group." 
			return $Result.StatusDescription
		}
}
}

Function Stop-A9RCopyGroup
{
<#
.SYNOPSIS
	Stop a Remote Copy group.
.DESCRIPTION
	Stop a Remote Copy group.
.EXAMPLE
	Stop-RCopyGroup_WSAPI -GroupName xxx
	Stop a Remote Copy group.
.EXAMPLE	
	PS:> Stop-A9RCopyGroup -GroupName xxx -TargetName xxx 
.EXAMPLE	
	Stop-A9RCopyGroup -GroupName xxx -NoSnapshot
.PARAMETER GroupName
	Group Name.
.PARAMETER NoSnapshot
	If true, this option turns off creation of snapshots in synchronous and periodic modes, and deletes the current synchronization snapshots.
	The default setting is false.
.PARAMETER TargetName
	The target name associated with this group.
#>
[CmdletBinding()]
Param(
		[Parameter(Mandatory)]	[String]	$GroupName,	  
		[Parameter()]					[switch]	$NoSnapshot,
		[Parameter()]					[String]	$TargetName
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$body["action"] = 4			
	If ($NoSnapshot) 	{	$body["noSnapshot"] = $true	    }	
	If ($TargetName) 	{	$body["targetName"] = "$($TargetName)"    }		
    $Result = $null	
	$uri = "/remotecopygroups/" + $GroupName
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return $Result				
	}
	else
	{	Write-Error "Failure:  While Stopping a Remote Copy group." 
		return $Result.StatusDescription
	}
}
}

Function Sync-A9RCopyGroup 
{
<#
.SYNOPSIS
	Synchronize a Remote Copy group.
.DESCRIPTION
	Synchronize a Remote Copy group.
.EXAMPLE
	PS:> Sync-A9RCopyGroup -GroupName xxx
	
	Synchronize a Remote Copy group.
.EXAMPLE	
	PS:> Sync-A9RCopyGroup -GroupName xxx -NoResyncSnapshot
.EXAMPLE
	PS:> Sync-A9RCopyGroup -GroupName xxx -TargetName xxx
.EXAMPLE
	PS:> Sync-A9RCopyGroup -GroupName xxx -TargetName xxx -NoResyncSnapshot
.EXAMPLE
	PS:> Sync-A9RCopyGroup -GroupName xxx -FullSync
.EXAMPLE
	PS:> Sync-A9RCopyGroup -GroupName xxx -TargetName xxx -NoResyncSnapshot -FullSync
.PARAMETER GroupName
	Group Name.
.PARAMETER NoResyncSnapshot
	Enables (true) or disables (false) saving the resynchronization snapshot. Applicable only to Remote Copy groups in asynchronous periodic mode.
	Defaults to false.
.PARAMETER TargetName
	The target name associated with this group.
.PARAMETER FullSync
	Enables (true) or disables (false)forcing a full synchronization of the Remote Copy group, even if the volumes are already synchronized.
	Applies only to volume groups in synchronous mode, and can be used to resynchronize volumes that have become inconsistent.
	Defaults to false.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$GroupName,	  
		[Parameter()]		[switch]	$NoResyncSnapshot,
		[Parameter()]					[String]	$TargetName,
		[Parameter()]					[switch]	$FullSync
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$body["action"] = 5		
	If ($NoResyncSnapshot) 	{	$body["noResyncSnapshot"] = $true    }	
	If ($TargetName) 		{	$body["targetName"] = "$($TargetName)" }
	If ($FullSync) 			{	$body["fullSync"] = $true    }	
	$Result = $null	
	$uri = "/remotecopygroups/" + $GroupName
	$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return $Result		
	}
	else
	{	Write-Error "Failure:  While Synchronizing a Remote Copy group." 
		return $Result.StatusDescription
	}
}
}

Function Remove-A9RCopyGroup
{
<#
.SYNOPSIS
	Remove a Remote Copy group.
.DESCRIPTION
	Remove a Remote Copy group.
.EXAMPLE    
	PS:> Remove-A9RCopyGroup -GroupName xxx
.PARAMETER GroupName 
	Group Name.
.PARAMETER KeepSnap 
	To remove a Remote Copy group with the option of retaining the local volume resynchronization snapshot
	The parameter uses one of the following, case-sensitive values:
	• keepSnap=true
	• keepSnap=false
.EXAMPLE    
	PS:> Remove-A9RCopyGroup -GroupName xxx -KeepSnap $true 
.EXAMPLE    
	PS:> Remove-A9RCopyGroup -GroupName xxx -KeepSnap $false
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$GroupName,		
		[Parameter()]		[boolean]	$KeepSnap	
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
		{	write-host "Cmdlet executed successfully" -foreground green
			return
		}
	else
		{	Write-Error "Failure:  While Removing a Remote Copy group : $GroupName " 
			return $Result.StatusDescription
		}    
}	
}

Function Update-A9RCopyGroup
{
<#
.SYNOPSIS
	Modify a Remote Copy group
.DESCRIPTION
	Modify a Remote Copy group.
.EXAMPLE
	PS:> Update-A9RCopyGroup -GroupName xxx -SyncPeriod 301 -Mode ASYNC
.PARAMETER GroupName
	Remote Copy group to update.
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
.PARAMETER TargetName 
	Specifies the target name associated with the created Remote Copy group.
.PARAMETER RemoteUserCPG
	Specifies the user CPG on the target used by autocreated volumes.
.PARAMETER RemoteSnapCPG
	Specifies the snap CPG on the target for use by autocreated volumes.
.PARAMETER SyncPeriod
	Specifies periodic synchronization of asynchronous periodic Remote Copy groups to the<period_value>. Range is 300–31622400 seconds (1year).
.PARAMETER RmSyncPeriod
	Enables (true) or disables (false)resetting the syncPeriod time to 0 (zero).If false, and the syncPeriod value is positive, the synchronizaiton period is set.
.PARAMETER Mode
	Specifies the volume group mode.
	SYNC : Remote Copy group mode is synchronous.
	PERIODIC : Remote Copy group mode is periodic. Although WSAPI 1.5 and later supports PERIODIC 2, Hewlett Packard Enterprise recommends using PERIODIC 3.
	PERIODIC : Remote Copy group mode is periodic.
	ASYNC : Remote Copy group mode is asynchronous.
.PARAMETER SnapFrequency
	Async mode only.
	Specifies the interval in seconds at which Remote Copy takes coordinated snapshots. Range is 300–31622400 seconds (1 year).
.PARAMETER RmSnapFrequency
	Enables (true) or disables (false) resetting the snapFrequency time to 0 (zero). If false , and the snapFrequency value is positive, sets the snapFrequency value.
.PARAMETER AutoRecover
	If the Remote Copy is stopped as a result of links going down, the Remote Copy group can be automatically restarted after the links come back up.
.PARAMETER OverPeriodAlert
	If synchronization of an asynchronous periodic Remote Copy group takes longer to complete than its synchronization period, an alert is generated.	
.PARAMETER AutoFailover
	Automatic failover on a Remote Copy group.
.PARAMETER PathManagement
	Automatic failover on a Remote Copy group.
.PARAMETER MultiTargetPeerPersistence
	Specifies that the group is participating in a Multitarget Peer Persistence configuration. The group must have two targets, one of which must be synchronous.
	The synchronous group target also requires pathManagement and autoFailover policy settings.
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory)]	[String]	$GroupName,
	[Parameter()]	[String]	$LocalUserCPG,
	[Parameter()]	[String]	$LocalSnapCPG,	  
	[Parameter()]	[String]	$TargetName,
	[Parameter()]	[String]	$RemoteUserCPG,
	[Parameter()]	[String]	$RemoteSnapCPG,
	[Parameter()]	[int]		$SyncPeriod,
	[Parameter()]	[int]		$RmSyncPeriod,
	[Parameter()]
	[ValidateSet('SYNC','ASYNC','PERIODIC')][String]	$Mode,
	[Parameter()]	[int]		$SnapFrequency,
	[Parameter()]	[int]		$RmSnapFrequency,
	[Parameter()]	[int]		$AutoRecover,
	[Parameter()]	[int]		$OverPeriodAlert,
	[Parameter()]	[int]		$AutoFailover,
	[Parameter()]	[int]		$PathManagement,
	[Parameter()]	[int]		$MultiTargetPeerPersistence
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$TargetsBody=@()
	$PoliciesBody=@{}
	if($LocalUserCPG)	{	$body["localUserCPG"] = "$($LocalUserCPG)"	}
	if($LocalSnapCPG)	{	$body["localSnapCPG"] = "$($LocalSnapCPG)"	}
	If ($TargetName) 	{	$Obj=@{}
							$Obj["targetName"] = $TargetName
							$TargetsBody += $Obj				
						}
	If ($RemoteUserCPG) {	$Obj=@{}
							$Obj["remoteUserCPG"] = "$($RemoteUserCPG)"
							$TargetsBody += $Obj
						}	
	If ($RemoteSnapCPG) {	$Obj=@{}
							$Obj["remoteSnapCPG"] = "$($RemoteSnapCPG)"
							$TargetsBody += $Obj		
						}	
	If ($SyncPeriod)	{	$Obj=@{}
							$Obj["syncPeriod"] = $SyncPeriod
							$TargetsBody += $Obj			
						}	
	If ($RmSyncPeriod) 	{	$Obj=@{}
							$Obj["rmSyncPeriod"] = $RmSyncPeriod
							$TargetsBody += $Obj				
						}
	If ($Mode) 			{	$MOD=@{}
							if($Mode -eq "SYNC")		{	$MOD["mode"] = 1	}
							if($Mode -eq "PERIODIC")	{	$MOD["mode"] = 3	}	
							if($Mode -eq "ASYNC")		{	$MOD["mode"] = 4	}
							$TargetsBody += $MOD
						}	
	If ($SnapFrequency)		{	$Obj=@{}
								$Obj["snapFrequency"] = $SnapFrequency
								$TargetsBody += $Obj				
							}
	If ($RmSnapFrequency)	{	$Obj=@{}
								$Obj["rmSnapFrequency"] = $RmSnapFrequency
								$TargetsBody += $Obj				
							}
	If ($AutoRecover) 		{	$PoliciesBody["autoRecover"] = $AutoRecover }
	If ($OverPeriodAlert) 	{	$PoliciesBody["overPeriodAlert"] = $OverPeriodAlert    }
	If ($AutoFailover) 		{	$PoliciesBody["autoFailover"] = $AutoFailover 	}
	If ($PathManagement) 	{	$PoliciesBody["pathManagement"] = $PathManagement   }
	If ($MultiTargetPeerPersistence) 	{	$PoliciesBody["multiTargetPeerPersistence"] = $MultiTargetPeerPersistence    }
	if($PoliciesBody.Count -gt 0)	{	$TargetsBody += $PoliciesBody 	}	
	if($TargetsBody.Count -gt 0)	{	$body["targets"] = $TargetsBody 	}	    
    $Result = $null
	$uri = '/remotecopygroups/'+ $GroupName
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
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
	[Parameter(Mandatory)]				[String]	$GroupName,
	[Parameter(Mandatory)]	[String]	$TargetName,
	[Parameter()]								[int]		$SnapFrequency,
	[Parameter()]								[Boolean]	$RmSnapFrequency,
	[Parameter()]								[int]		$SyncPeriod,
	[Parameter()]								[Boolean]	$RmSyncPeriod,
	[Parameter()][ValidateSet('SYNC','PERIODIC')][String]	$Mode,
	[Parameter()]								[int]		$AutoRecover,
	[Parameter()]								[int]		$OverPeriodAlert,
	[Parameter()]								[int]		$AutoFailover,
	[Parameter()]							[int]		$PathManagement,
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
		{	write-host "Cmdlet executed successfully" -foreground green
			return Get-A9System		
		}
	else
		{	Write-Error "Failure:  While Updating Remote Copy group target." 
			return $Result.StatusDescription
		}
}
}

Function Restore-A9RCopyGroup 
{
<#      
.SYNOPSIS	
	Recovering a Remote Copy group
.DESCRIPTION	
    Recovering a Remote Copy group
.EXAMPLE
	Recovering a Remote Copy group
.PARAMETER GroupName
	Remote Copy group Name.
.PARAMETER TargetName
	The target name associated with this group on which you want to perform the disaster recovery operation. If the group has multiple targets, the target must be specified.
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
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory)]	[String]	$GroupName,
	[Parameter()]		[String]	$TargetName,
	[Parameter()]					[Switch]	$SkipStart,
	[Parameter()]					[Switch]	$SkipSync,
	[Parameter()]					[Switch]	$DiscardNewData,
	[Parameter()]					[Switch]	$SkipPromote,
	[Parameter()]					[Switch]	$NoSnapshot,
	[Parameter()]					[Switch]	$StopGroups,
	[Parameter()]					[Switch]	$LocalGroupsDirection
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$body["action"] = 6   
	If ($TargetName) 	{	$body["targetName"] = "$($TargetName)"    }
	If ($SkipStart) 	{	$body["skipStart"] = $true    }
	If ($SkipSync) 		{	$body["skipSync"] = $true    }
	If ($DiscardNewData){	$body["discardNewData"] = $true    }
	If ($SkipPromote) 	{	$body["skipPromote"] = $true    }
	If ($NoSnapshot) 	{	$body["noSnapshot"] = $true    }
	If ($StopGroups) 	{	$body["stopGroups"] = $true    }
	If ($LocalGroupsDirection) 	{	$body["localGroupsDirection"] = $true    }		
    $Result = $null
	$uri = "/remotecopygroups/"+$GroupName
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure:  While Recovering a Remote Copy group : $GroupName " 
			return $Result.StatusDescription
		}
}
}

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
	{	write-host "Cmdlet executed successfully" -foreground green
		return $Result
	}
	else
	{	Write-Error "Failure:  While Admitting a volume into a Remote Copy group : $VolumeName " 
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
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure:  While Dismissing a volume from a Remote Copy group : $VolumeName " 
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
	Enable (true) or disable (false) the creation of the target in disabled mode.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]							[String]	$TargetName,
		[Parameter(Mandatory=$true, ParameterSetName = "IP", ValueFromPipeline=$true)]	[Switch]	$IP,
		[Parameter(Mandatory=$true, ParameterSetName = "FC", ValueFromPipeline=$true)]	[Switch]	$FC,
		[Parameter(ParameterSetName = "FC", ValueFromPipeline=$true)]					[String]	$NodeWWN,
		[Parameter()]											[String]	$PortPos,
		[Parameter()]											[String]	$Link, 
		[Parameter()]											[Switch]	$Disabled
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$PortPosAndLinkBody=@{}	 
    If($TargetName) 	{	$body["name"] = "$($TargetName)" }
	If($IP) 		{	$body["type"] = 1  	}
	ElseIf ($FC) 	{	$body["type"] = 2   }
	If($NodeWWN) 	{	$body["nodeWWN"] = "$($NodeWWN)"}
	If($DifferentSecondaryWWN) 	{	$body["differentSecondaryWWN"] = $DifferentSecondaryWWN    }
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
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure:  While creating a Remote Copy target : $TargetName " 
			return $Result.StatusDescription
		}
}
}

Function Update-A9RCopyTarget 
{
<#
.SYNOPSIS
	Modify a Remote Copy Target
.DESCRIPTION
	Modify a Remote Copy Target.
.EXAMPLE
	PS:> Update-A9RCopyTarget -TargetName xxx
.EXAMPLE
	PS:> Update-A9RCopyTarget -TargetName xxx -MirrorConfig $true
.PARAMETER TargetName
	The <target_name> parameter corresponds to the name of the Remote Copy target you want to modify
.PARAMETER MirrorConfig
	Enables (true) or disables (false) the duplication of all configurations involving the specified target.
	Defaults to true.
	Use false to allow recovery from an unusual error condition only, and only after consulting your Hewlett Packard Enterprise representative.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$TargetName,
		[Parameter()]					[Switch]	$MirrorConfig
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$PoliciesBody = @{}
	$Obj=@{}
	If ($MirrorConfig) 	{	$Obj["mirrorConfig"] = $true }
	else				{	$Obj["mirrorConfig"] = $false}
	$PoliciesBody += $Obj
	if($PoliciesBody.Count -gt 0)	{	$body["policies"] = $PoliciesBody 	}
    $Result = $null
	$uri = '/remotecopytargets/'+ $TargetName
	Write-Verbose "Request: Request to Update-RCopyTarget_WSAPI (Invoke-A9API)." 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
	}
	else
	{	Write-Error "Failure:  While Updating Remote Copy Target / Target Name : $TargetName." 
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
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	Write-Error "Failure:  While admitting a target into a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName " 
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
.EXAMPLE	
	PS:> Remove-A9TargetFromRCopyGroup
.PARAMETER GroupName
	Remote Copy group Name.
.PARAMETER TargetName
	Target Name to be removed.  
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
	{	write-host "Cmdlet executed successfully" -foreground green
		return $Result
	}
	else
	{	Write-Error "Failure:  While removing  a target from a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName " 
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
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure:  While Creating coordinated snapshots across all Remote Copy group volumes." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9RCopyInfo 
{
<#
.SYNOPSIS	
	Get overall Remote Copy information
.DESCRIPTION
	Get overall Remote Copy information
.EXAMPLE
	PS:> Get-A9RCopyInfo

	Get overall Remote Copy information
#>
[CmdletBinding()]
Param()
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Result = Invoke-A9API -uri '/remotecopy' -type 'GET'
	if($Result.StatusCode -eq 200)
	{	$dataPS = $Result.content | ConvertFrom-Json
		write-host "Cmdlet executed successfully" -foreground green
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
			write-host "Cmdlet executed successfully" -foreground green
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
	Get all or single Remote Copy Group
.DESCRIPTION
	Get all or single Remote Copy Group
.EXAMPLE
	PS:> Get-A9RCopyGroup

	Get List of Groups
.EXAMPLE
	PS:> Get-A9RCopyGroup -GroupName XXX

	Get a single Groups of given name
.EXAMPLE
	PS:> Get-A9RCopyGroup -GroupName XXX*

	Get a single or list of Groups of given name like or match the words
.EXAMPLE
	PS:> Get-A9RCopyGroup -GroupName "XXX,YYY,ZZZ"

	For multiple Group name 
.PARAMETER GroupName	
    Remote Copy Group Name
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$GroupName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	$uri = '/remotecopygroups'
	if($GroupName)
		{	$lista = $GroupName.split(",")
			$count = 1
			foreach($sub in $lista)
				{	$Query = $Query.Insert($Query.Length-3," name LIKE $sub")			
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$Query = $Query.Insert($Query.Length-3," OR ")
									$count = $count + 1
								}				
						}				
				}
			$uri = $uri+'/'+$Query
		}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While executing Get-RCopyGroup_WSAPI. Expected result not found with given filter option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-RCopyGroup_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9RCopyGroupTarget 
{
<#
.SYNOPSIS	
	Get all or single Remote Copy Group target
.DESCRIPTION
	Get all or single Remote Copy Group target
.EXAMPLE
	PS:> Get-A9RCopyGroupTarget

	Get List of Groups target
.EXAMPLE
	PS:> Get-A9RCopyGroupTarget -TargetName xxx	

	Get Single Target
.PARAMETER GroupName	
    Remote Copy Group Name
.PARAMETER TargetName	
    Target Name
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]
		[String]	$GroupName,
		
		[Parameter()]
		[String]	$TargetName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$uri = '/remotecopygroups/'+$GroupName+'/targets'
	if($TargetName)
		{	$uri = $uri+'/'+$TargetName
		}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	Write-Error "Failure:  While Executing Get-RCopyGroupTarget_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9RCopyGroupVv 
{
<#
.SYNOPSIS	
	Get all or single Remote Copy Group volume
.DESCRIPTION
	Get all or single Remote Copy Group volume
.EXAMPLE
	PS:> Get-RCopyGroupVv_WSAPI -GroupName asRCgroup
.EXAMPLE
	PS:> Get-A9RCopyGroupVv_WSAPI -GroupName asRCgroup -VolumeName Test
.PARAMETER GroupName	
    Remote Copy Group Name
.PARAMETER VolumeName	
    Remote Copy Volume Name
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$GroupName,
		[Parameter()]					[String]	$VolumeName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$uri = '/remotecopygroups/'+$GroupName+'/volumes'	
	if($VolumeName)		{	$uri = $uri+'/'+$VolumeName	}
	$Result = Invoke-A9API -uri $uri -type 'GET'	
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	Write-Error "Failure:  While Executing Get-RCopyGroupVv_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9RCopyLink 
{
<#
.SYNOPSIS	
	Get all or single Remote Copy Link
.DESCRIPTION
	Get all or single Remote Copy Link
.EXAMPLE
	PS:> Get-A9RCopyLink

	Get List Remote Copy Link
.EXAMPLE
	PS:> Get-A9RCopyLink -LinkName xxx
	
	Get Single Remote Copy Link
.PARAMETER LinkName	
    Remote Copy Link Name
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$LinkName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$uri = '/remotecopylinks'	
	if($LinkName)	{	$uri = $uri+'/'+$LinkName	}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
	{	$dataPS = $Result.content | ConvertFrom-Json
		write-host "Cmdlet executed successfully" -foreground green
		return $dataPS		
	}
	else
	{	Write-Error "Failure:  While Executing Get-RCopyLink_WSAPI." 
		return $Result.StatusDescription
	}
}	
}

# SIG # Begin signature block
# MIIsVAYJKoZIhvcNAQcCoIIsRTCCLEECAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABED0s6SLohg5
# 4gVZfSFtjl0Ab6lo/dYz/ACsmTCTbTFx+DZkLRsALddqX9W+gCIgX5WnjhRDjdZl
# Fcy1YhB1SaFHoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhEwghoNAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQB/Cv491PQb+HdNKZMHegB2701KWhzSVWSTI9x5u6gjlk1ChgvRncwNU
# +1xFogG1vjtPIbXkkJzvMxMaRAMg/D0wDQYJKoZIhvcNAQEBBQAEggGAIAjedFih
# Saogz9wuiHaW4fxj5EVWzqMtKHgfBJ5exnHTHp16Kv06K2dKygWozGfoDRvL1ziB
# 9YG2PZBn6GqAfxP6HuA/qduHB1GVRGaMMma0x4OB2hUftegKXF7xx/f4b0168+84
# j4z32pJKrg+i1wYaA5d0XJ22iudWvB7uByvDhGlFbahRTCAjzSlNlIJBGjm6QwzQ
# N2CIfF8C/oo+sgLt/wYDb+iMif5Nhsb2QwhqGIrcVhSv8bH+xZNYRff2MBo+53oi
# PTPACTwixRp3zYxcLv9kc3xjHrqPQSaBe/ktfyji7TXs/xRzhjYRulsf7I9phEZN
# HEC+7Niy1njGI6lVC6vCz8EyyqF2fhwnzDnaQ3IvCjfPyqlE+xqazvJiHpUbYV2M
# IxW3+mPyT8t4p+gb5lDRZoI/JdReG9TMQQDO9t6gSnm3DTaWNyPJrnyxACH95fLw
# b39wRhmdEgAQlrttnX0VYElEgCTjTAguAr+HbHv5BGBk4tPmOrONwJFRoYIXWjCC
# F1YGCisGAQQBgjcDAwExghdGMIIXQgYJKoZIhvcNAQcCoIIXMzCCFy8CAQMxDzAN
# BglghkgBZQMEAgIFADCBhwYLKoZIhvcNAQkQAQSgeAR2MHQCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDC3aVSCMch8Yji1dqy9e/qdtw68XguMV0tQ9owH
# d25m7kcDFDoSskeZNCUhcZILr04CEHg5wZIC4BFH8+R08kBfsMQYDzIwMjUwNTE1
# MjI1NTI3WqCCEwMwgga8MIIEpKADAgECAhALrma8Wrp/lYfG+ekE4zMEMA0GCSqG
# SIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwHhcNMjQwOTI2MDAwMDAwWhcNMzUxMTI1MjM1OTU5WjBC
# MQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxIDAeBgNVBAMTF0RpZ2lD
# ZXJ0IFRpbWVzdGFtcCAyMDI0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAvmpzn/aVIauWMLpbbeZZo7Xo/ZEfGMSIO2qZ46XB/QowIEMSvgjEdEZ3v4vr
# rTHleW1JWGErrjOL0J4L0HqVR1czSzvUQ5xF7z4IQmn7dHY7yijvoQ7ujm0u6yXF
# 2v1CrzZopykD07/9fpAT4BxpT9vJoJqAsP8YuhRvflJ9YeHjes4fduksTHulntq9
# WelRWY++TFPxzZrbILRYynyEy7rS1lHQKFpXvo2GePfsMRhNf1F41nyEg5h7iOXv
# +vjX0K8RhUisfqw3TTLHj1uhS66YX2LZPxS4oaf33rp9HlfqSBePejlYeEdU740G
# KQM7SaVSH3TbBL8R6HwX9QVpGnXPlKdE4fBIn5BBFnV+KwPxRNUNK6lYk2y1WSKo
# ur4hJN0SMkoaNV8hyyADiX1xuTxKaXN12HgR+8WulU2d6zhzXomJ2PleI9V2yfmf
# XSPGYanGgxzqI+ShoOGLomMd3mJt92nm7Mheng/TBeSA2z4I78JpwGpTRHiT7yHq
# BiV2ngUIyCtd0pZ8zg3S7bk4QC4RrcnKJ3FbjyPAGogmoiZ33c1HG93Vp6lJ415E
# RcC7bFQMRbxqrMVANiav1k425zYyFMyLNyE1QulQSgDpW9rtvVcIH7WvG9sqYup9
# j8z9J1XqbBZPJ5XLln8mS8wWmdDLnBHXgYly/p1DhoQo5fkCAwEAAaOCAYswggGH
# MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSME
# GDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUn1csA3cOKBWQZqVj
# Xu5Pkh92oFswWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NB
# LmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGlu
# Z0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAPa0eH3aZW+M4hBJH2UOR9hHbm04I
# HdEoT8/T3HuBSyZeq3jSi5GXeWP7xCKhVireKCnCs+8GZl2uVYFvQe+pPTScVJeC
# ZSsMo1JCoZN2mMew/L4tpqVNbSpWO9QGFwfMEy60HofN6V51sMLMXNTLfhVqs+e8
# haupWiArSozyAmGH/6oMQAh078qRh6wvJNU6gnh5OruCP1QUAvVSu4kqVOcJVozZ
# R5RRb/zPd++PGE3qF1P3xWvYViUJLsxtvge/mzA75oBfFZSbdakHJe2BVDGIGVNV
# jOp8sNt70+kEoMF+T6tptMUNlehSR7vM+C13v9+9ZOUKzfRUAYSyyEmYtsnpltD/
# GWX8eM70ls1V6QG/ZOB6b6Yum1HvIiulqJ1Elesj5TMHq8CWT/xrW7twipXTJ5/i
# 5pkU5E16RSBAdOp12aw8IQhhA/vEbFkEiF2abhuFixUDobZaA0VhqAsMHOmaT3XT
# hZDNi5U2zHKhUs5uHHdG6BoQau75KiNbh0c+hatSF+02kULkftARjsyEpHKsF7u5
# zKRbt5oK5YGwFvgc4pEVUNytmB3BpIiowOIIuDgP5M9WArHYSAR16gc0dP2XdkME
# P5eBsX7bf/MGN4K3HP50v/01ZHo/Z5lGLvNwQ7XHBx1yomzLP8lx4Q1zZKDyHcp4
# VQJLu2kWTsKsOqQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMy
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcg
# Q0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
# JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMf
# UBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w
# 1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRk
# tFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYb
# qMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUm
# cJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP6
# 5x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzK
# QtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo
# 80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjB
# Jgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXche
# MBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd
# 4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiC
# qBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl
# /Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
# RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYT
# gAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/
# a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37
# xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmL
# NriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0
# YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJ
# RyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIF
# jTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3y
# ithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1If
# xp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDV
# ySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiO
# DCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQ
# jdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/
# CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCi
# EhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADM
# fRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QY
# uKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXK
# chYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t
# 9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6ch
# nfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0
# MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqG
# SIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi
# +IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n0
# 96wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ8
# 7PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9v
# ytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQt
# J37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDhjCCA4ICAQEwdzBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# AhALrma8Wrp/lYfG+ekE4zMEMA0GCWCGSAFlAwQCAgUAoIHhMBoGCSqGSIb3DQEJ
# AzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjUwNTE1MjI1NTI3WjAr
# BgsqhkiG9w0BCRACDDEcMBowGDAWBBTb04XuYtvSPnvk9nFIUIck1YZbRTA3Bgsq
# hkiG9w0BCRACLzEoMCYwJDAiBCB2dp+o8mMvH0MLOiMwrtZWdf7Xc9sF1mW5BZOY
# Q4+a2zA/BgkqhkiG9w0BCQQxMgQw9W5AtbU35+KVsuO2tIBSKPU/m/0QZofDK1Wn
# a7fFfgcbL1jjlre3VuH9IpzDV/7XMA0GCSqGSIb3DQEBAQUABIICAGdpCwKJKseo
# fYb6A8Zk/ZVkDsciEX399tIzOhCbkCCA76bmanBVzOQxShFSzPy3US/m3NNIYD4G
# ungeM5rK0VGib/wSxMx050a84mR1zgF1Msw4iDm+QPSgUUcFtpIyXfbUUWgdHuzb
# w691YN5tsuAQEPGJTCk0y9CNJ7epWczPVjybyuf9BbRA4BHyHS3wUgANFFn6Vqbu
# GY3CflOnKzNpSws9c4Xt1POxv3mnv0eReoXgVSGVn36SFueIbvaoywUgQMuCcUtN
# kvADxhXW8F2DVxl/Yc7OPyFXRvGD+eEuwZB/6o9Lb4JfgG6Z1oOmz0L1MFgoiwp4
# tg5LT5Nim3KWRgklaBeoeZtz7EcTQ8M+2R2U20ZnZ52cukRafMFzu1YwuTicql5Q
# lvx7okaxm4ugLgK4LtNHBY2dFQJThUZups5JDnzTUDYZIw+9CO0wao6z14Pq5qrP
# NY2yDTpUkBBzJnKYzCh5xukSr0zvR9KtHDhLhLrWbZ11egf9oSjWf6sUgm9+WBj+
# CpIkDNleEIF+FR8+ayhU0268/V6xhvH5HwBuHzp8istXf0zB3Mc8t7G4WCI7InSO
# 5Q3j48NkYokwdfeqa0fGiGNULLBj3Kpn3EIxMupzXoJaTZUoWTFJ5y2+VqK+92K8
# O2AAAHKwAfRlwSFDt+rA+3ARqz5FiCmw
# SIG # End signature block
