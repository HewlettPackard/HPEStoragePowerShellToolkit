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
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$RcgName,
	[Parameter(ValueFromPipeline=$true)]		[String]	$Domain,
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$TargetName,
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
	[ValidateSet('SYNC','PERIODIC','ASYNC')]				[String]	$Mode,
	[Parameter(ValueFromPipeline=$true)]					[String]	$UserCPG,
	[Parameter(ValueFromPipeline=$true)]					[String]	$SnapCPG,
	[Parameter(ValueFromPipeline=$true)]					[String]	$LocalUserCPG,
	[Parameter(ValueFromPipeline=$true)]					[String]	$LocalSnapCPG
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
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,	  
		[Parameter(ValueFromPipeline=$true)]					[switch]	$SkipInitialSync,
		[Parameter(ValueFromPipeline=$true)]					[String]	$TargetName,
		[Parameter(ValueFromPipeline=$true)]					[String]	$VolumeName,
		[Parameter(ValueFromPipeline=$true)]					[String]	$SnapshotName
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
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,	  
		[Parameter(ValueFromPipeline=$true)]					[switch]	$NoSnapshot,
		[Parameter(ValueFromPipeline=$true)]					[String]	$TargetName
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,	  
		[Parameter(ValueFromPipeline=$true)]		[switch]	$NoResyncSnapshot,
		[Parameter(ValueFromPipeline=$true)]					[String]	$TargetName,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$FullSync
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,		
		[Parameter(ValueFromPipeline=$true)]		[boolean]	$KeepSnap	
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
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,
	[Parameter(ValueFromPipeline=$true)]	[String]	$LocalUserCPG,
	[Parameter(ValueFromPipeline=$true)]	[String]	$LocalSnapCPG,	  
	[Parameter(ValueFromPipeline=$true)]	[String]	$TargetName,
	[Parameter(ValueFromPipeline=$true)]	[String]	$RemoteUserCPG,
	[Parameter(ValueFromPipeline=$true)]	[String]	$RemoteSnapCPG,
	[Parameter(ValueFromPipeline=$true)]	[int]		$SyncPeriod,
	[Parameter(ValueFromPipeline=$true)]	[int]		$RmSyncPeriod,
	[Parameter(ValueFromPipeline=$true)]
	[ValidateSet('SYNC','ASYNC','PERIODIC')][String]	$Mode,
	[Parameter(ValueFromPipeline=$true)]	[int]		$SnapFrequency,
	[Parameter(ValueFromPipeline=$true)]	[int]		$RmSnapFrequency,
	[Parameter(ValueFromPipeline=$true)]	[int]		$AutoRecover,
	[Parameter(ValueFromPipeline=$true)]	[int]		$OverPeriodAlert,
	[Parameter(ValueFromPipeline=$true)]	[int]		$AutoFailover,
	[Parameter(ValueFromPipeline=$true)]	[int]		$PathManagement,
	[Parameter(ValueFromPipeline=$true)]	[int]		$MultiTargetPeerPersistence
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
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]				[String]	$GroupName,
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$TargetName,
	[Parameter(ValueFromPipeline=$true)]								[int]		$SnapFrequency,
	[Parameter(ValueFromPipeline=$true)]								[Boolean]	$RmSnapFrequency,
	[Parameter(ValueFromPipeline=$true)]								[int]		$SyncPeriod,
	[Parameter(ValueFromPipeline=$true)]								[Boolean]	$RmSyncPeriod,
	[Parameter(ValueFromPipeline=$true)][ValidateSet('SYNC','PERIODIC')][String]	$Mode,
	[Parameter(ValueFromPipeline=$true)]								[int]		$AutoRecover,
	[Parameter(ValueFromPipeline=$true)]								[int]		$OverPeriodAlert,
	[Parameter(ValueFromPipeline=$true)]								[int]		$AutoFailover,
	[Parameter(ValueFromPipeline=$true)]							[int]		$PathManagement,
	[Parameter(ValueFromPipeline=$true)]								[int]		$MultiTargetPeerPersistence
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
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,
	[Parameter(ValueFromPipeline=$true)]		[String]	$TargetName,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$SkipStart,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$SkipSync,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$DiscardNewData,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$SkipPromote,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$NoSnapshot,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$StopGroups,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$LocalGroupsDirection
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]				[String]	$GroupName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeName,
		[Parameter(ValueFromPipeline=$true)]								[String]	$SnapshotName,
		[Parameter(ValueFromPipeline=$true)]								[boolean]	$VolumeAutoCreation,
		[Parameter(ValueFromPipeline=$true)]								[boolean]	$SkipInitialSync,
		[Parameter(ValueFromPipeline=$true)]								[boolean]	$DifferentSecondaryWWN,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]				[String]	$TargetName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]				[String]	$SecVolumeName
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeName,
		[Parameter(ValueFromPipeline=$true)]					[boolean]	$KeepSnap,
		[Parameter(ValueFromPipeline=$true)]					[boolean]	$RemoveSecondaryVolume
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]							[String]	$TargetName,
		[Parameter(Mandatory=$true, ParameterSetName = "IP", ValueFromPipeline=$true)]	[Switch]	$IP,
		[Parameter(Mandatory=$true, ParameterSetName = "FC", ValueFromPipeline=$true)]	[Switch]	$FC,
		[Parameter(ParameterSetName = "FC", ValueFromPipeline=$true)]					[String]	$NodeWWN,
		[Parameter(ValueFromPipeline=$true)]											[String]	$PortPos,
		[Parameter(ValueFromPipeline=$true)]											[String]	$Link, 
		[Parameter(ValueFromPipeline=$true)]											[Switch]	$Disabled
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$TargetName,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$MirrorConfig
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$TargetName,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('SYNC','PERIODIC','ASYNC')]				[String]	$Mode,
		[Parameter(ValueFromPipeline=$true)]					[String]	$LocalVolumeName,
		[Parameter(ValueFromPipeline=$true)]					[String]	$RemoteVolumeName
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$TargetName
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
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,
		[Parameter(ValueFromPipeline=$true)]		[String]	$VolumeName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$NewVvNmae,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]					[int]		$ExpirationHous,
		[Parameter(ValueFromPipeline=$true)]					[int]		$RetentionHours,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$SkipBlock
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
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$TargetName
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
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$GroupName
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$GroupName,
		
		[Parameter(ValueFromPipeline=$true)]
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$GroupName,
		[Parameter(ValueFromPipeline=$true)]					[String]	$VolumeName
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
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$LinkName
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
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDEXk+yLlv5
# g7beGJcaWilRrAvCW4zKqD+BL4UympAE5oF8OGV3/c0kF7UlJ90RROLgbzCSBIb/
# yqSB57am0IJJoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5UwghuRAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQMvfoS05+IJY920midCZl+xkqC5RWDLs+22TSzyy3iw4pjPYt76o72sl
# gLsuH0/LsF69qV5DcL3zWNak62VX3X4wDQYJKoZIhvcNAQEBBQAEggGAiKhYWoxw
# orJuaBjZ9Aq5ofm2NCA1ycjwTXxhIknuMiZs1qgHgnFljoCp/M5NLxVHvYTahJXO
# 8netHRVMEdbblqRErNgwQQatDa0ROqWysiijCUnA9BgYW8oq0MO384RqprBKSXmq
# z92OBZOK7TCvAF45uXso3hhhK0TxN4cblEpjmeKsUJq95rdiR4G97e55ybkKk+VG
# 1M4cEOEZxwYXOc0smvQF2d0BIUCE8c4a/qYKxeEBI0ne6hLjXCihCqLEmOrpUOQS
# Us6Xndr8z1KKR/Qap8nfXWh9TbYb9AyR/MxjKeTsOP/DOdigLfWydFoj2LhOX2i1
# KFDZCkitzHMfW1CY+Suo4ViLvI+58uhR0kmNojo4oZC/KhRQIo7+WgAJT0g//KKl
# JmYk0SyhKiIVBXWPtNPb0qmDmpSetBaTe3B4HLJbsvVpax8Bj7ntb7iGupuzwaMN
# FPF+LFfn/vStuYozR/xjc+XhbKLk2JpLlIxnWz9scUGbLwaKrr+HkXDtoYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMIw5/wD7EpnoiI4TZNADxJFHCJwoYP8j
# mnPRC+WIngpGJQezcvYaK08E5zkFOifvgwIUQ+QsolOH8OXlgR5CyfWypZylSksY
# DzIwMjQwNzMxMjAyMDU4WqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
# bmNoZXN0ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2Vj
# dGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1oIIS/zCCBl0wggTF
# oAMCAQICEDpSaiyEzlXmHWX8zBLY6YkwDQYJKoZIhvcNAQEMBQAwVTELMAkGA1UE
# BhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGln
# byBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjQwMTE1MDAwMDAwWhcN
# MzUwNDE0MjM1OTU5WjBuMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFuY2hlc3Rl
# cjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydTZWN0aWdvIFB1
# YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzUwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN0Wf0wUibvf04STpNYYGbw9jcRaVhBDaNBp7jmJaA9dQZ
# W5ighrXGNMYjK7Dey5RIHMqLIbT9z9if753mYbojJrKWO4ZP0N5dBT2TwZZaPb8E
# +hqaDZ8Vy2c+x1NiEwbEzTrPX4W3QFq/zJvDDbWKL99qLL42GJQzX3n5wWo60Kkl
# fFn+Wb22mOZWYSqkCVGl8aYuE12SqIS4MVO4PUaxXeO+4+48YpQlNqbc/ndTgszR
# QLF4MjxDPjRDD1M9qvpLTZcTGVzxfViyIToRNxPP6DUiZDU6oXARrGwyP9aglPXw
# YbkqI2dLuf9fiIzBugCDciOly8TPDgBkJmjAfILNiGcVEzg+40xUdhxNcaC+6r0j
# uPiR7bzXHh7v/3RnlZuT3ZGstxLfmE7fRMAFwbHdDz5gtHLqjSTXDiNF58IxPtvm
# ZPG2rlc+Yq+2B8+5pY+QZn+1vEifI0MDtiA6BxxQuOnj4PnqDaK7NEKwtD1pzoA3
# jJFuoJiwbatwhDkg1PIjYnMDbDW+wAc9FtRN6pUsO405jaBgigoFZCw9hWjLNqgF
# VTo7lMb5rVjJ9aSBVVL2dcqzyFW2LdWk5Xdp65oeeOALod7YIIMv1pbqC15R7QCY
# LxcK1bCl4/HpBbdE5mjy9JR70BHuYx27n4XNOZbwrXcG3wZf9gEUk7stbPAoBQID
# AQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNhlxmiMpswHQYD
# VR0OBBYEFGjvpDJJabZSOB3qQzks9BRqngyFMA4GA1UdDwEB/wQEAwIGwDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1UdIARDMEEwNQYM
# KwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20v
# Q1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8vY3JsLnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcmwwegYIKwYB
# BQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYBBQUHMAGGF2h0
# dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IBgQCw3C7J+k82
# TIov9slP1e8YTx+fDsa//hJ62Y6SMr2E89rv82y/n8we5W6z5pfBEWozlW7nWp+s
# dPCdUTFw/YQcqvshH6b9Rvs9qZp5Z+V7nHwPTH8yzKwgKzTTG1I1XEXLAK9fHnmX
# paDeVeI8K6Lw3iznWZdLQe3zl+Rejdq5l2jU7iUfMkthfhFmi+VVYPkR/BXpV7Ub
# 1QyyWebqkjSHJHRmv3lBYbQyk08/S7TlIeOr9iQ+UN57fJg4QI0yqdn6PyiehS1n
# SgLwKRs46T8A6hXiSn/pCXaASnds0LsM5OVoKYfbgOOlWCvKfwUySWoSgrhncihS
# BXxH2pAuDV2vr8GOCEaePZc0Dy6O1rYnKjGmqm/IRNkJghSMizr1iIOPN+23futB
# XAhmx8Ji/4NTmyH9K0UvXHiuA2Pa3wZxxR9r9XeIUVb2V8glZay+2ULlc445CzCv
# VSZV01ZB6bgvCuUuBx079gCcepjnZDCcEuIC5Se4F6yFaZ8RvmiJ4hgwggYUMIID
# /KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUAMFcxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEwMzIyMDAwMDAw
# WhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAM2Y2ENBq26C
# K+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStSVjeYXIjfa3aj
# oW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQBaCxpectRGhh
# nOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE9cbY11XxM2AV
# Zn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExSLnh+va8WxTlA
# +uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OIIq/fWlwBp6KNL
# 19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGdF+z+Gyn9/CRe
# zKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w76kOLIaFVhf5
# sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4CllgrwIDAQABo4IB
# XDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUwHQYDVR0OBBYE
# FF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8E
# CDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0g
# ADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEFBQcBAQRwMG4w
# RwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1Ymxp
# Y1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2Nz
# cC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0ONVgMnoEdJVj9
# TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc6ZvIyHI5UkPC
# bXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1OSkkSivt51Ul
# mJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz2wSKr+nDO+Db
# 8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y4Il6ajTqV2if
# ikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVMCMPY2752LmES
# sRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBeNh9AQO1gQrnh
# 1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupiaAeNHe0pWSGH2
# opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU+CCQaL0cJqlm
# nx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/SjwsusWRItFA3DE8
# MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7xpMeYRriWklU
# PsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs656Oz3TbLyXVo
# MA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEpl
# cnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJV
# U1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9u
# IEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMFcxCzAJ
# BgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJBZvMWhUP2ZQQ
# RLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQnOh2qmcxGzjqe
# mIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypoGJrruH/drCio
# 28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0pKG9ki+PC6VEf
# zutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13jQEV1JnUTCm51
# 1n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9YrcmXcLgsrAi
# mfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/yVl4jnDcw6ULJ
# sBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVgh60KmLmzXiqJ
# c6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/OLoanEWP6Y52
# Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+NrLedIxsE88WzK
# XqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58NHs57ZPUfECcg
# JC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rID
# ZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1UdDwEB/wQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVz
# dC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwNQYI
# KwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3Qu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3OyWM637ayBeR
# 7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJJlFfym1Doi+4
# PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0mUGQHbRcF57ol
# pfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTwbD/zIExAopoe
# 3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i111TW7HV1Ats
# Qa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGezjM6CRpcWed/
# ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+8aW88WThRpv8
# lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH29308ZkpKKdp
# kiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrsxrYJD+3f3aKg
# 6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6Ii8+CQOYDwXM
# +yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz7NgAnOgpCdUo
# 4uDyllU9PzGCBJEwggSNAgEBMGkwVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1Nl
# Y3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFt
# cGluZyBDQSBSMzYCEDpSaiyEzlXmHWX8zBLY6YkwDQYJYIZIAWUDBAICBQCgggH5
# MBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQw
# NzMxMjAyMDU4WjA/BgkqhkiG9w0BCQQxMgQwr6XtSAoj/ikosfFwv3vmYktkzeKQ
# ++gSICOEYvrbCn/1LTsXdiuKdZXjRYv6DkAHMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgAmxsUC
# lrvPVADAo/F3I4jx5ZbHabnkM2SESyFKLQlP0sJn0pbKYEUYBTFaszKeAkqVGQcU
# gU2fIarRQj/2I9mHtxnIussXDy9/R8aMaqhgDkQpjUTNcpKCP7P4QudLUgOgCDPN
# NFbyCXEOvaPVnMWi1g1xio5Pn4QGYgtfdKA9yr66pIDi8Gv2pnuqfHZo9ojj/ASv
# FQKzr7LnM/FMu3WslAgSbi1/G0bK0LtgYZBVGWSuvDEjhhM934gBYLomClzsPvJr
# daI8i/7gzcgFnHqw8DBQVYiFo85wIubj0fB6bNECq4LEQ8+x918q2qIR1TL4P48o
# 7Kfza9QO4Z4/01L4hwPdCmtE6WZig0ckquYrRAdbj3mtOOCAMgSXhrw5MclJtZA5
# XWsufpUd7wpczOs01eAyBNTTBtYy3O5ktzPKBUEOzNVkG2FDjQo8KFgIpMHTS04J
# prenaRraA4cB13ijdZCikLeipUzEY3wwjJXiyAPhVOGrFTKsUO0du89/2Hp3L/JR
# Zj//z9ZqwQDioITchjL6otExIOOuEBItbeWyE4Ts9Y6XA2TcQpeDRp1fvoInoWT/
# 3fGpgGy539dkW9drRRpKgyr4qIkkBfufPGl/JYBin+7FM2YK97cMCxAkjSaTUwqE
# 3yjixKByAw1BF2ja8tjWZtGxosRc43hUp1KnBQ==
# SIG # End signature block
