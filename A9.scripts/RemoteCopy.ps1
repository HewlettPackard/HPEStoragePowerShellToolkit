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
    $Result = Invoke-WSAPI -uri '/remotecopygroups' -type 'POST' -body $body 
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
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
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
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
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
	$Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
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
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' 
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
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
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
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 	
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
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body 
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
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body 
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
    $Result = Invoke-WSAPI -uri $uri -type 'DELETE' -body $body 
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
    $Result = Invoke-WSAPI -uri '/remotecopytargets' -type 'POST' -body $body 
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
	Write-Verbose "Request: Request to Update-RCopyTarget_WSAPI (Invoke-WSAPI)." 
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
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
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
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
	$Result = Invoke-WSAPI -uri $uri -type 'PUT' 
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
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body	
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
	$Result = Invoke-WSAPI -uri '/remotecopy' -type 'GET'
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
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 		  
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
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
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
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
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
	$Result = Invoke-WSAPI -uri $uri -type 'GET'	
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
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
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
