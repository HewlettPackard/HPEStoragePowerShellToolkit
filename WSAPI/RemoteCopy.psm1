﻿####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
##	File Name:		RemoteCopy.psm1
##	Description: 	Remote Copy cmdlets 
##		
##	Created:		February 2020
##	Last Modified:	February 2020
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## FUNCTION New-RCopyGroup_WSAPI
############################################################################################################################################
Function New-RCopyGroup_WSAPI 
{
  <#      
  .SYNOPSIS	
	Create a Remote Copy group
	
  .DESCRIPTION	
    Create a Remote Copy group
	
  .EXAMPLE
	New-RCopyGroup_WSAPI -RcgName xxx -TargetName xxx -Mode SYNC
	
  .EXAMPLE	
	New-RCopyGroup_WSAPI -RcgName xxx -TargetName xxx -Mode PERIODIC -Domain xxx
	
  .EXAMPLE	
	New-RCopyGroup_WSAPI -RcgName xxx -TargetName xxx -Mode ASYNC -UserCPG xxx -LocalUserCPG xxx -SnapCPG xxx -LocalSnapCPG xxx
	
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : New-RCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: New-RCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $RcgName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Domain,
	  
	  [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=3, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $Mode,

	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $UserCPG,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $SnapCPG,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LocalUserCPG,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LocalSnapCPG,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	  
	  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}	
	$TargetsObj = @()
	$TargetsBody = @{}

   
    If ($RcgName) 
	{
		$body["name"] = "$($RcgName)"
    }  
	If ($Domain) 
	{
		$body["domain"] = "$($Domain)"  
    }
	If ($TargetName) 
	{
		$TargetsBody["targetName"] = "$($TargetName)"		
    }
	If ($Mode) 
	{		
		if($Mode.ToUpper() -eq "SYNC")
		{
			$TargetsBody["mode"] = 1			
		}
		elseif($Mode.ToUpper() -eq "PERIODIC")
		{
			$TargetsBody["mode"] = 3	
		}
		elseif($Mode.ToUpper() -eq "ASYNC")
		{
			$TargetsBody["mode"] = 4	
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Mode $Mode in incorrect "
			Return "FAILURE : -Mode :- $Mode is an Incorrect Mode  [SYNC | PERIODIC | ASYNC] can be used only . "
		}
    }
	If ($UserCPG) 
	{
		$TargetsBody["userCPG"] = "$($UserCPG)"
    }
	If ($SnapCPG) 
	{
		$TargetsBody["snapCPG"] = "$($SnapCPG)"
    }
	If ($LocalUserCPG) 
	{
		$body["localUserCPG"] = "$($LocalUserCPG)"
    }
	If ($LocalSnapCPG) 
	{
		$body["localSnapCPG"] = "$($LocalSnapCPG)"
    }
	
	if($TargetsBody.Count -gt 0)
	{
		$TargetsObj += $TargetsBody 
	}
	if($TargetsObj.Count -gt 0)
	{
		$body["targets"] = $TargetsObj 
	}
	
    $Result = $null	
    #Request
	Write-DebugLog "Request: Request to New-RCopyGroup_WSAPI : $RcgName (Invoke-WSAPI)." $Debug	
	
    $Result = Invoke-WSAPI -uri '/remotecopygroups' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Remote Copy group : $RcgName created successfully." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: New-RCopyGroup_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Creating a Remote Copy group : $RcgName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Creating a Remote Copy group : $RcgName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END New-RCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Start-RCopyGroup_WSAPI
############################################################################################################################################
Function Start-RCopyGroup_WSAPI 
{
  <#
  .SYNOPSIS
	Starting a Remote Copy group.
  
  .DESCRIPTION
	Starting a Remote Copy group.
        
  .EXAMPLE
	Start-RCopyGroup_WSAPI -GroupName xxx
	Starting a Remote Copy group.
        
  .EXAMPLE	
	Start-RCopyGroup_WSAPI -GroupName xxx -TargetName xxx
        
  .EXAMPLE	
	Start-RCopyGroup_WSAPI -GroupName xxx -SkipInitialSync
	
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Start-RCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Start-RCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
  
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,	  
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $SkipInitialSync,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $SnapshotName,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection	  
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {  
	$body = @{}
	$ObjStartingSnapshots=@{}
	$body["action"] = 3		
	
	If ($SkipInitialSync) 
	{
		$body["skipInitialSync"] = $true	
    }	
	If ($TargetName) 
	{
		$body["targetName"] = "$($TargetName)"
    }	
	If ($VolumeName) 
	{
		$Obj=@{}
		$Obj["volumeName"] = "$($VolumeName)"
		$ObjStartingSnapshots += $Obj				
    }
	If ($SnapshotName) 
	{
		$Obj=@{}
		$Obj["snapshotName"] = "$($SnapshotName)"
		$ObjStartingSnapshots += $Obj				
    }
	
	if($ObjStartingSnapshots.Count -gt 0)
	{
		$body["startingSnapshots"] = $ObjStartingSnapshots 
	}
	
    $Result = $null	
	$uri = "/remotecopygroups/" + $GroupName
	
    #Request
	Write-DebugLog "Request: Request to Start-RCopyGroup_WSAPI (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Start a Remote Copy group." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Start-RCopyGroup_WSAPI." $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Starting a Remote Copy group." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Starting a Remote Copy group." $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Start-RCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Stop-RCopyGroup_WSAPI
############################################################################################################################################
Function Stop-RCopyGroup_WSAPI 
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
	Stop-RCopyGroup_WSAPI -GroupName xxx -TargetName xxx 
        
  .EXAMPLE	
	Stop-RCopyGroup_WSAPI -GroupName xxx -NoSnapshot
	
  .PARAMETER GroupName
	Group Name.
	
  .PARAMETER NoSnapshot
	If true, this option turns off creation of snapshots in synchronous and periodic modes, and deletes the current synchronization snapshots.
	The default setting is false.
  
  .PARAMETER TargetName
	The target name associated with this group.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Stop-RCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Stop-RCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
  
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,	  
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $NoSnapshot,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {  
	$body = @{}
	#$ObjStartingSnapshots=@{}
	$body["action"] = 4		
	
	If ($NoSnapshot) 
	{
		$body["noSnapshot"] = $true	
    }	
	If ($TargetName) 
	{
		$body["targetName"] = "$($TargetName)"
    }	
	
    $Result = $null	
	$uri = "/remotecopygroups/" + $GroupName
	
    #Request
	Write-DebugLog "Request: Request to Stop-RCopyGroup_WSAPI (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Stop a Remote Copy group." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Stop-RCopyGroup_WSAPI." $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Stopping a Remote Copy group." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Stopping a Remote Copy group." $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Stop-RCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Sync-RCopyGroup_WSAPI
############################################################################################################################################
Function Sync-RCopyGroup_WSAPI 
{
  <#
  .SYNOPSIS
	Synchronize a Remote Copy group.
  
  .DESCRIPTION
	Synchronize a Remote Copy group.
        
  .EXAMPLE
	Sync-RCopyGroup_WSAPI -GroupName xxx
	Synchronize a Remote Copy group.
        
  .EXAMPLE	
	Sync-RCopyGroup_WSAPI -GroupName xxx -NoResyncSnapshot
	        
  .EXAMPLE
	Sync-RCopyGroup_WSAPI -GroupName xxx -TargetName xxx
	        
  .EXAMPLE
	Sync-RCopyGroup_WSAPI -GroupName xxx -TargetName xxx -NoResyncSnapshot
	        
  .EXAMPLE
	Sync-RCopyGroup_WSAPI -GroupName xxx -FullSync
	        
  .EXAMPLE
	Sync-RCopyGroup_WSAPI -GroupName xxx -TargetName xxx -NoResyncSnapshot -FullSync
	
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Sync-RCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Sync-RCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
  
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,	  
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $NoResyncSnapshot,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $FullSync,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {  
	$body = @{}
	#$ObjStartingSnapshots=@{}
	$body["action"] = 5		
	
	If ($NoResyncSnapshot) 
	{
		$body["noResyncSnapshot"] = $true	
    }	
	If ($TargetName) 
	{
		$body["targetName"] = "$($TargetName)"
    }
	If ($FullSync) 
	{
		$body["fullSync"] = $true	
    }	
	
    $Result = $null	
	$uri = "/remotecopygroups/" + $GroupName
	
    #Request
	Write-DebugLog "Request: Request to Sync-RCopyGroup_WSAPI (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Synchronize a Remote Copy groupp." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Sync-RCopyGroup_WSAPI." $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Synchronizing a Remote Copy group." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Synchronizing a Remote Copy group." $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Sync-RCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Remove-RCopyGroup_WSAPI
############################################################################################################################################
Function Remove-RCopyGroup_WSAPI
 {
  <#
  .SYNOPSIS
	Remove a Remote Copy group.
  
  .DESCRIPTION
	Remove a Remote Copy group.
        
  .EXAMPLE    
	Remove-RCopyGroup_WSAPI -GroupName xxx
	
  .PARAMETER GroupName 
	Group Name.
	
  .PARAMETER KeepSnap 
	To remove a Remote Copy group with the option of retaining the local volume resynchronization snapshot
	The parameter uses one of the following, case-sensitive values:
	• keepSnap=true
	• keepSnap=false

  .EXAMPLE    
	Remove-RCopyGroup_WSAPI -GroupName xxx -KeepSnap $true 

  .EXAMPLE    
	Remove-RCopyGroup_WSAPI -GroupName xxx -KeepSnap $false

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Remove-RCopyGroup_WSAPI     
    LASTEDIT: February 2020
    KEYWORDS: Remove-RCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0	
  #>
  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$GroupName,
		
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		[boolean]
		$KeepSnap,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	    $WsapiConnection = $global:WsapiConnection
	)
  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {    
	#Build uri
	Write-DebugLog "Running: Building uri to Remove-RCopyGroup_WSAPI." $Debug
	$uri = '/remotecopygroups/'+ $GroupName
	
	if($keepSnap)
	{
		$uri = $uri + "?keepSnap=true"
	}
	if(!$keepSnap)
	{
		$uri = $uri + "?keepSnap=false"
	}
	
	$Result = $null

	#Request
	Write-DebugLog "Request: Request to Remove-RCopyGroup_WSAPI : $GroupName (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 202)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Remove a Remote Copy group:$GroupName successfully remove" $Info
		Write-DebugLog "End: Remove-RCopyGroup_WSAPI" $Debug
		
		return ""
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Removing a Remote Copy group : $GroupName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : Removing a Remote Copy group : $GroupName " $Info
		Write-DebugLog "End: Remove-RCopyGroup_WSAPI" $Debug
		
		return $Result.StatusDescription
	}    
	
  }
  End {}  
}
#END Remove-RCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Update-RCopyGroup_WSAPI
############################################################################################################################################
Function Update-RCopyGroup_WSAPI 
{
  <#
  .SYNOPSIS
	Modify a Remote Copy group
  
  .DESCRIPTION
	Modify a Remote Copy group.
        
  .EXAMPLE
	Update-RCopyGroup_WSAPI -GroupName xxx -SyncPeriod 301 -Mode ASYNC
	
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : Update-RCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Update-RCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
	  [System.String]
	  $GroupName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $LocalUserCPG,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $LocalSnapCPG,	  
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $TargetName,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $RemoteUserCPG,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $RemoteSnapCPG,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $SyncPeriod,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $RmSyncPeriod,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Mode,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $SnapFrequency,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $RmSnapFrequency,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $AutoRecover,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $OverPeriodAlert,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $AutoFailover,
	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $PathManagement,
	  
	  [Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $MultiTargetPeerPersistence,

	  [Parameter(Position=16, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection	  
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {  
	$body = @{}	
	$TargetsBody=@()
	$PoliciesBody=@{}

	if($LocalUserCPG)
	{
		$body["localUserCPG"] = "$($LocalUserCPG)"
	}
	if($LocalSnapCPG)
	{
		$body["localSnapCPG"] = "$($LocalSnapCPG)"
	}
	If ($TargetName) 
	{
		$Obj=@{}
		$Obj["targetName"] = $TargetName
		$TargetsBody += $Obj				
    }
	If ($RemoteUserCPG) 
	{
		$Obj=@{}
		$Obj["remoteUserCPG"] = "$($RemoteUserCPG)"
		$TargetsBody += $Obj
    }	
	If ($RemoteSnapCPG) 
	{
		$Obj=@{}
		$Obj["remoteSnapCPG"] = "$($RemoteSnapCPG)"
		$TargetsBody += $Obj		
    }	
	If ($SyncPeriod) 
	{
		$Obj=@{}
		$Obj["syncPeriod"] = $SyncPeriod
		$TargetsBody += $Obj			
    }	
	If ($RmSyncPeriod) 
	{
		$Obj=@{}
		$Obj["rmSyncPeriod"] = $RmSyncPeriod
		$TargetsBody += $Obj				
    }
	If ($Mode) 
	{		
		if($Mode -eq "SYNC")
		{
			$MOD=@{}
			$MOD["mode"] = 1
			$TargetsBody += $MOD				
		}
		elseif($Mode -eq "PERIODIC")
		{
			$MOD=@{}
			$MOD["mode"] = 3
			$TargetsBody += $MOD		
		}
		elseif($Mode -eq "ASYNC")
		{
			$MOD=@{}
			$MOD["mode"] = 4
			$TargetsBody += $MOD		
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Mode $Mode in incorrect "
			Return "FAILURE : -Mode :- $Mode is an Incorrect Mode  [SYNC | PERIODIC | ASYNC] can be used only . "
		}
    }	
	If ($SnapFrequency) 
	{
		$Obj=@{}
		$Obj["snapFrequency"] = $SnapFrequency
		$TargetsBody += $Obj				
    }
	If ($RmSnapFrequency) 
	{
		$Obj=@{}
		$Obj["rmSnapFrequency"] = $RmSnapFrequency
		$TargetsBody += $Obj				
    }
	If ($AutoRecover) 
	{		
		$PoliciesBody["autoRecover"] = $AutoRecover
    }
	If ($OverPeriodAlert) 
	{		
		$PoliciesBody["overPeriodAlert"] = $OverPeriodAlert
    }
	If ($AutoFailover) 
	{		
		$PoliciesBody["autoFailover"] = $AutoFailover
    }
	If ($PathManagement) 
	{		
		$PoliciesBody["pathManagement"] = $PathManagement
    }
	If ($MultiTargetPeerPersistence) 
	{		
		$PoliciesBody["multiTargetPeerPersistence"] = $MultiTargetPeerPersistence
    }
	
	if($PoliciesBody.Count -gt 0)
	{
		$TargetsBody += $PoliciesBody 
	}	
	if($TargetsBody.Count -gt 0)
	{
		$body["targets"] = $TargetsBody 
	}	
    
    $Result = $null
	$uri = '/remotecopygroups/'+ $GroupName
	
	
    #Request
	Write-DebugLog "Request: Request to Update-RCopyGroup_WSAPI (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Update Remote Copy group." $Info
				
		# Results		
		Get-System_WSAPI		
		Write-DebugLog "End: Update-RCopyGroup_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Updating Remote Copy group." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Updating Remote Copy group." $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Update-RCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Update-RCopyGroupTarget_WSAPI
############################################################################################################################################
Function Update-RCopyGroupTarget_WSAPI 
{
  <#
  .SYNOPSIS
	Modifying a Remote Copy group target.
  
  .DESCRIPTION
	Modifying a Remote Copy group target.
        
  .EXAMPLE
	Update-RCopyGroupTarget_WSAPI -GroupName xxx -TargetName xxx -Mode SYNC 
	
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : Update-RCopyGroupTarget_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Update-RCopyGroupTarget_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
	  [System.String]
	  $GroupName,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
	  [System.String]
	  $TargetName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $SnapFrequency,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	  [Boolean]
	  $RmSnapFrequency,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $SyncPeriod,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	  [Boolean]
	  $RmSyncPeriod,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Mode,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $AutoRecover,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $OverPeriodAlert,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $AutoFailover,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $PathManagement,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
	  [int]
	  $MultiTargetPeerPersistence,

	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection	  
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {  
	$body = @{}	
	#$TargetsBody=@()
	$PoliciesBody=@{}
	
	If ($SyncPeriod) 
	{
		$body["syncPeriod"] = $SyncPeriod
    }	
	If ($RmSyncPeriod) 
	{
		$body["rmSyncPeriod"] = $RmSyncPeriod					
    }
	If ($SnapFrequency) 
	{
		$body["snapFrequency"] = $SnapFrequency
    }
	If ($RmSnapFrequency) 
	{
		$body["rmSnapFrequency"] = $RmSnapFrequency
    }
	If ($Mode) 
	{		
		if($Mode.ToUpper() -eq "SYNC")
		{
			$body["mode"] = 1			
		}
		elseif($Mode.ToUpper() -eq "PERIODIC")
		{
			$body["mode"] = 2		
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Mode $Mode in incorrect "
			Return "FAILURE : -Mode :- $Mode is an Incorrect Mode  [SYNC | PERIODIC] can be used only . "
		}
    }	
	
	If ($AutoRecover) 
	{		
		$PoliciesBody["autoRecover"] = $AutoRecover
    }
	If ($OverPeriodAlert) 
	{		
		$PoliciesBody["overPeriodAlert"] = $OverPeriodAlert
    }
	If ($AutoFailover) 
	{		
		$PoliciesBody["autoFailover"] = $AutoFailover
    }
	If ($PathManagement) 
	{		
		$PoliciesBody["pathManagement"] = $PathManagement
    }
	If ($MultiTargetPeerPersistence) 
	{		
		$PoliciesBody["multiTargetPeerPersistence"] = $MultiTargetPeerPersistence
    }
	
	if($PoliciesBody.Count -gt 0)
	{
		$body["policies"] = $PoliciesBody
	}
    
    $Result = $null
	$uri = '/remotecopygroups/'+ $GroupName+'/targets/'+$TargetName
	
	
    #Request
	Write-DebugLog "Request: Request to Update-RCopyGroupTarget_WSAPI (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Update Remote Copy group target." $Info
				
		# Results		
		Get-System_WSAPI		
		Write-DebugLog "End: Update-RCopyGroupTarget_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Updating Remote Copy group target." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Updating Remote Copy group target." $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Update-RCopyGroupTarget_WSAPI

############################################################################################################################################
## FUNCTION Restore-RCopyGroup_WSAPI
############################################################################################################################################
Function Restore-RCopyGroup_WSAPI 
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Restore-RCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Restore-RCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $SkipStart,

	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $SkipSync,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $DiscardNewData,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $SkipPromote,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $NoSnapshot,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $StopGroups,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $LocalGroupsDirection,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	  
	  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}	
	$body["action"] = 6   
    
	If ($TargetName) 
	{
		$body["targetName"] = "$($TargetName)"
    }
	If ($SkipStart) 
	{
		$body["skipStart"] = $true
    }
	If ($SkipSync) 
	{
		$body["skipSync"] = $true
    }
	If ($DiscardNewData) 
	{
		$body["discardNewData"] = $true
    }
	If ($SkipPromote) 
	{
		$body["skipPromote"] = $true
    }
	If ($NoSnapshot) 
	{
		$body["noSnapshot"] = $true
    }
	If ($StopGroups) 
	{
		$body["stopGroups"] = $true
    }
	If ($LocalGroupsDirection) 
	{
		$body["localGroupsDirection"] = $true
    }	
	
    $Result = $null
	$uri = "/remotecopygroups/"+$GroupName
    #Request
	Write-DebugLog "Request: Request to Restore-RCopyGroup_WSAPI : $GroupName (Invoke-WSAPI)." $Debug	
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Remote Copy group : $GroupName successfully Recover." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: Restore-RCopyGroup_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Recovering a Remote Copy group : $GroupName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Recovering a Remote Copy group : $GroupName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Restore-RCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Add-VvToRCopyGroup_WSAPI
############################################################################################################################################
Function Add-VvToRCopyGroup_WSAPI 
{
  <#      
  .SYNOPSIS	
	Admit a volume into a Remote Copy group
	
  .DESCRIPTION	
    Admit a volume into a Remote Copy group
	
  .EXAMPLE	
	Add-VvToRCopyGroup_WSAPI -GroupName xxx -VolumeName xxx -TargetName xxx -SecVolumeName xxx
	
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : Add-VvToRCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Add-VvToRCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $SnapshotName,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $VolumeAutoCreation,

	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $SkipInitialSync,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $DifferentSecondaryWWN,
	  
	  [Parameter(Position=6, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=7, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $SecVolumeName,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	  
	  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}
	$TargetsBody=@{}	
	$body["action"] = 1   
    
	If ($VolumeName) 
	{
		$body["volumeName"] = "$($VolumeName)"
    }
	If ($SnapshotName) 
	{
		$body["snapshotName"] = "$($SnapshotName)"
    }
	If ($VolumeAutoCreation) 
	{
		$body["volumeAutoCreation"] = $VolumeAutoCreation
    }
	If ($SkipInitialSync) 
	{
		$body["skipInitialSync"] = $SkipInitialSync
    }
	If ($DifferentSecondaryWWN) 
	{
		$body["differentSecondaryWWN"] = $DifferentSecondaryWWN
    }
	If ($TargetName) 
	{
		$Obj=@{}
		$Obj["targetName"] = "$($TargetName)"
		$TargetsBody += $Obj
    }	
	If ($SecVolumeName) 
	{
		$Obj=@{}
		$Obj["secVolumeName"] = "$($SecVolumeName)"
		$TargetsBody += $Obj		
    }	
	if($TargetsBody.Count -gt 0)
	{
		$body["targets"] = $TargetsBody 
	}
	
    $Result = $null
	$uri = "/remotecopygroups/"+$GroupName+"/volumes"
    #Request
	Write-DebugLog "Request: Request to Add-VvToRCopyGroup_WSAPI : $VolumeName (Invoke-WSAPI)." $Debug	
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Volume into a Remote Copy group : $VolumeName successfully Admitted." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: Add-VvToRCopyGroup_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Admitting a volume into a Remote Copy group : $VolumeName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Admitting a volume into a Remote Copy group : $VolumeName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Add-VvToRCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Remove-VvFromRCopyGroup_WSAPI
############################################################################################################################################
Function Remove-VvFromRCopyGroup_WSAPI 
{
  <#      
  .SYNOPSIS	
	Dismiss a volume from a Remote Copy group
	
  .DESCRIPTION	
    Dismiss a volume from a Remote Copy group
	
  .EXAMPLE	
	
  .PARAMETER GroupName
	Remote Copy group Name.
	
  .PARAMETER VolumeName
	Specifies the name of the existing virtual volume to be admitted to an existing Remote Copy group.
  
  .PARAMETER KeepSnap
	Enables (true) or disables (false) retention of the local volume resynchronization snapshot. Defaults to false. Do not use with removeSecondaryVolu me.
  
  .PARAMETER RemoveSecondaryVolume
	Enables (true) or disables (false) deletion of the remote volume on the secondary array from the system. Defaults to false. Do not use with keepSnap.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : Remove-VvFromRCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Remove-VvFromRCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $KeepSnap,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $RemoveSecondaryVolume,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	  
	  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}
	#$TargetsBody=@()	
	$body["action"] = 1   
    
	If ($VolumeName) 
	{
		$body["volumeName"] = "$($VolumeName)"
    }
	If ($KeepSnap) 
	{
		$body["keepSnap"] = $KeepSnap
    }
	If ($RemoveSecondaryVolume) 
	{
		$body["removeSecondaryVolume"] = $RemoveSecondaryVolume
    }
	
    $Result = $null
	$uri = "/remotecopygroups/"+$GroupName+"/volumes/"+$VolumeName
    #Request
	Write-DebugLog "Request: Request to Remove-VvFromRCopyGroup_WSAPI : $VolumeName (Invoke-WSAPI)." $Debug	
	
    $Result = Invoke-WSAPI -uri $uri -type 'DELETE' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Volume from a Remote Copy group : $VolumeName successfully Remove." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: Remove-VvFromRCopyGroup_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Dismissing a volume from a Remote Copy group : $VolumeName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Dismissing a volume from a Remote Copy group : $VolumeName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Remove-VvFromRCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION New-RCopyTarget_WSAPI
############################################################################################################################################
Function New-RCopyTarget_WSAPI 
{
  <#      
  .SYNOPSIS	
	Creating a Remote Copy target
	
  .DESCRIPTION	
    Creating a Remote Copy target
	
  .EXAMPLE	
	New-RCopyTarget_WSAPI -TargetName xxx -IP
	
  .EXAMPLE	
	New-RCopyTarget_WSAPI -TargetName xxx  -NodeWWN xxx -FC
	
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
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : New-RCopyTarget_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: New-RCopyTarget_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $IP,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $FC,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NodeWWN,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $PortPos,

	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $Link, 
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Disabled,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	  
	  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}
	$PortPosAndLinkBody=@{}	 
    
	If($TargetName) 
	{
		$body["name"] = "$($TargetName)"
    }
	If($IP) 
	{
		$body["type"] = 1
    }
	ElseIf ($FC) 
	{
		$body["type"] = 2
    }
	else
	{
		return "Please select at-list any one from IP or FC Type."
	}
	If($NodeWWN) 
	{
		$body["nodeWWN"] = "$($NodeWWN)"
    }
	If($DifferentSecondaryWWN) 
	{
		$body["differentSecondaryWWN"] = $DifferentSecondaryWWN
    }
	If($PortPos) 
	{
		$Obj=@{}
		$Obj["portPos"] = "$($PortPos)"
		$PortPosAndLinkBody += $Obj
    }
	If($Link) 
	{
		$Obj=@{}
		$Obj["link"] = "$($Link)"
		$PortPosAndLinkBody += $Obj
    }
	If($Disabled) 
	{
		$body["disabled"] = $true
    }
	if($PortPosAndLinkBody.Count -gt 0)
	{
		$body["portPosAndLink"] = $PortPosAndLinkBody 
	}
	
    $Result = $null
	
    #Request
	Write-DebugLog "Request: Request to New-RCopyTarget_WSAPI : $TargetName (Invoke-WSAPI)." $Debug	
	
    $Result = Invoke-WSAPI -uri '/remotecopytargets' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Remote Copy Target : $TargetName created successfully." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: New-RCopyTarget_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating a Remote Copy target : $TargetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : Creating a Remote Copy target : $TargetName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END New-RCopyTarget_WSAPI

############################################################################################################################################
## FUNCTION Update-RCopyTarget_WSAPI
############################################################################################################################################
Function Update-RCopyTarget_WSAPI 
{
  <#
  .SYNOPSIS
	Modify a Remote Copy Target
  
  .DESCRIPTION
	Modify a Remote Copy Target.
        
  .EXAMPLE
	Update-RCopyTarget_WSAPI -TargetName xxx
        
  .EXAMPLE
	Update-RCopyTarget_WSAPI -TargetName xxx -MirrorConfig $true
	
  .PARAMETER TargetName
	The <target_name> parameter corresponds to the name of the Remote Copy target you want to modify

  .PARAMETER MirrorConfig
	Enables (true) or disables (false) the duplication of all configurations involving the specified target.
	Defaults to true.
	Use false to allow recovery from an unusual error condition only, and only after consulting your Hewlett Packard Enterprise representative.
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Update-RCopyTarget_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Update-RCopyTarget_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  	  
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
	  [System.String]
	  $TargetName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  [Switch]
	  $MirrorConfig,

	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection	  
  )

	Begin 
	{
		# Test if connection exist
		Test-WSAPIConnection -WsapiConnection $WsapiConnection
	}

  Process 
  {  
	$body = @{}
	$PoliciesBody = @{}
	
	If ($MirrorConfig) 
	{
		$Obj=@{}
		$Obj["mirrorConfig"] = $true		
		$PoliciesBody += $Obj
    }
	else
	{
		$Obj=@{}
		$Obj["mirrorConfig"] = $false		
		$PoliciesBody += $Obj
	}
	
	if($PoliciesBody.Count -gt 0)
	{
		$body["policies"] = $PoliciesBody 
	}
    
    $Result = $null
	$uri = '/remotecopytargets/'+ $TargetName
	
	
    #Request
	Write-DebugLog "Request: Request to Update-RCopyTarget_WSAPI (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Update Remote Copy Target / Target Name : $TargetName." $Info
				
		# Results			
		Write-DebugLog "End: Update-RCopyTarget_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Updating Remote Copy Target / Target Name : $TargetName." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Updating Remote Copy Target / Target Name : $TargetName." $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Update-RCopyTarget_WSAPI

############################################################################################################################################
## FUNCTION Add-TargetToRCopyGroup_WSAPI
############################################################################################################################################
Function Add-TargetToRCopyGroup_WSAPI 
{
  <#      
  .SYNOPSIS	
	Admitting a target into a Remote Copy group
	
  .DESCRIPTION	
    Admitting a target into a Remote Copy group
	
  .EXAMPLE	
	Add-TargetToRCopyGroup_WSAPI -GroupName xxx -TargetName xxx
	
  .EXAMPLE	
	Add-TargetToRCopyGroup_WSAPI -GroupName xxx -TargetName xxx -Mode xxx
	
  .EXAMPLE	
	Add-TargetToRCopyGroup_WSAPI -GroupName xxx -TargetName xxx -Mode xxx -LocalVolumeName xxx -RemoteVolumeName xxx
		
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
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Add-TargetToRCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Add-TargetToRCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,
	   
      [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Mode,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LocalVolumeName,

	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $RemoteVolumeName,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	  
	  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}
	$volumeMappingsObj=@()	
	$volumeMappingsBody=@{}	
    
	If($TargetName) 
	{
		$body["targetName"] = "$($TargetName)"
    }
	If ($Mode) 
	{		
		if($Mode -eq "SYNC")
		{
			$body["mode"] = 1						
		}
		elseif($Mode -eq "PERIODIC")
		{
			$body["mode"] = 3		
		}
		elseif($Mode -eq "ASYNC")
		{
			$body["mode"] = 4		
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Mode $Mode in incorrect "
			Return "FAILURE : -Mode :- $Mode is an Incorrect Mode  [SYNC | PERIODIC | ASYNC] can be used only . "
		}
    }
	If($LocalVolumeName) 
	{
		$volumeMappingsBody["localVolumeName"] = "$($LocalVolumeName)"
    }
	If($RemoteVolumeName) 
	{
		$volumeMappingsBody["remoteVolumeName"] = "$($RemoteVolumeName)"
    }
	
	if($volumeMappingsBody.Count -gt 0)
	{
		$volumeMappingsObj += $volumeMappingsBody 
	}
	if($volumeMappingsObj.Count -gt 0)
	{
		$body["volumeMappings"] = $volumeMappingsObj 
	}
	
    $Result = $null
	$uri = "/remotecopygroups/"+$GroupName+"/targets"
	
    #Request
	Write-DebugLog "Request: Request to Add-TargetToRCopyGroup_WSAPI : TargetName = $TargetName / GroupName = $GroupName(Invoke-WSAPI)." $Debug	
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Admitted a target into a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: Add-TargetToRCopyGroup_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While admitting a target into a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : Admitting a target into a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Add-TargetToRCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Remove-TargetFromRCopyGroup_WSAPI
############################################################################################################################################
Function Remove-TargetFromRCopyGroup_WSAPI 
{
  <#      
  .SYNOPSIS	
	Remove a target from a Remote Copy group
	
  .DESCRIPTION	
    Remove a target from a Remote Copy group
	
  .EXAMPLE	
	Remove-TargetFromRCopyGroup_WSAPI
	
  .PARAMETER GroupName
	Remote Copy group Name.
  
  .PARAMETER TargetName
	Target Name to be removed.  

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : Remove-TargetFromRCopyGroup_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Remove-TargetFromRCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,
	   
      [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	  
	  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {    
    $Result = $null
	$uri = "/remotecopygroups/"+$GroupName+"/targets/"+$TargetName
	
    #Request
	Write-DebugLog "Request: Request to Remove-TargetFromRCopyGroup_WSAPI : TargetName = $TargetName / GroupName = $GroupName(Invoke-WSAPI)." $Debug	
	
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Remove a target from a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: Remove-TargetFromRCopyGroup_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While removing  a target from a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : Removing a target from a Remote Copy group : TargetName = $TargetName / GroupName = $GroupName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Remove-TargetFromRCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION New-SnapRcGroupVv_WSAPI
############################################################################################################################################
Function New-SnapRcGroupVv_WSAPI 
{
  <#      
  .SYNOPSIS	
	Create coordinated snapshots across all Remote Copy group volumes.
	
  .DESCRIPTION	
    Create coordinated snapshots across all Remote Copy group volumes.
	
  .EXAMPLE	
	New-SnapRcGroupVv_WSAPI -GroupName xxx -NewVvNmae xxx -Comment "Hello"
	
  .EXAMPLE	
	New-SnapRcGroupVv_WSAPI -GroupName xxx -NewVvNmae xxx -VolumeName Test -Comment "Hello"
	
  .EXAMPLE	
	New-SnapRcGroupVv_WSAPI -GroupName xxx -NewVvNmae xxx -Comment "Hello" -RetentionHours 1
	
  .EXAMPLE	
	New-SnapRcGroupVv_WSAPI -GroupName xxx -NewVvNmae xxx -Comment "Hello" -VolumeName Test -RetentionHours 1
	
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : New-SnapRcGroupVv_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: New-SnapRcGroupVv_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
      [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $NewVvNmae,
	   
      [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Comment,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $ExpirationHous,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $RetentionHours,

	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
	  [Switch]
	  $SkipBlock,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	  
	  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}
	$ParametersBody=@{}	
    
	$body["action"] = 1   
	
	If($NewVvNmae) 
	{
		$ParametersBody["name"] = "$($NewVvNmae)"
    }
	If($Comment) 
	{
		$ParametersBody["comment"] = "$($Comment)"
    }
	If($ExpirationHous) 
	{
		$ParametersBody["expirationHous"] = $ExpirationHous
    }
	If($RetentionHours) 
	{
		$ParametersBody["retentionHours"] = $RetentionHours
    }
	If($SkipBlock) 
	{
		$ParametersBody["skipBlock"] = $true
    }
	
	if($ParametersBody.Count -gt 0)
	{
		$body["parameters"] = $ParametersBody 
	}
	
    $Result = $null
	if($VolumeName)
	{
		$uri = "/remotecopygroups/"+$GroupName+"/volumes/"+$VolumeName
	}
	else
	{
		$uri = "/remotecopygroups/"+$GroupName+"/volumes"
	}
	
	
    #Request
	Write-DebugLog "Request: Request to New-SnapRcGroupVv_WSAPI(Invoke-WSAPI)." $Debug	
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Create coordinated snapshots across all Remote Copy group volumes." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: New-SnapRcGroupVv_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Creating coordinated snapshots across all Remote Copy group volumes." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Creating coordinated snapshots across all Remote Copy group volumes." $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END New-SnapRcGroupVv_WSAPI

############################################################################################################################################
## FUNCTION Get-RCopyInfo_WSAPI
############################################################################################################################################
Function Get-RCopyInfo_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get overall Remote Copy information
  
  .DESCRIPTION
	Get overall Remote Copy information
        
  .EXAMPLE
	Get-RCopyInfo_WSAPI
	Get overall Remote Copy information

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-RCopyInfo_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-RCopyInfo_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null
	
	#Request
	$Result = Invoke-WSAPI -uri '/remotecopy' -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = $Result.content | ConvertFrom-Json
	
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Command Get-RCopyInfo_WSAPI Successfully Executed" $Info
		
		return $dataPS
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-RCopyInfo_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-RCopyInfo_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-RCopyInfo_WSAPI

############################################################################################################################################
## FUNCTION Get-RCopyTarget_WSAPI
############################################################################################################################################
Function Get-RCopyTarget_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get all or single Remote Copy targets
  
  .DESCRIPTION
	Get all or single Remote Copy targets
        
  .EXAMPLE
	Get-RCopyTarget_WSAPI

  .EXAMPLE
	Get-RCopyTarget_WSAPI -TargetName xxx	
	
  .PARAMETER TargetName	
    Remote Copy Target Name

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-RCopyTarget_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-RCopyTarget_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null	
	
	#Build uri
	if($TargetName)
	{
		$uri = '/remotecopytargets/'+$TargetName
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}
	}
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/remotecopytargets' -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}		
	}
		  
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Command Get-RCopyTarget_WSAPI Successfully Executed" $Info
		
		return $dataPS
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-RCopyTarget_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-RCopyTarget_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-RCopyTarget_WSAPI

############################################################################################################################################
## FUNCTION Get-RCopyGroup_WSAPI
############################################################################################################################################
Function Get-RCopyGroup_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get all or single Remote Copy Group
  
  .DESCRIPTION
	Get all or single Remote Copy Group
        
  .EXAMPLE
	Get-RCopyGroup_WSAPI
	Get List of Groups
	
  .EXAMPLE
	Get-RCopyGroup_WSAPI -GroupName XXX
	Get a single Groups of given name

  .EXAMPLE
	Get-RCopyGroup_WSAPI -GroupName XXX*
	Get a single or list of Groups of given name like or match the words
	
  .EXAMPLE
	Get-RCopyGroup_WSAPI -GroupName "XXX,YYY,ZZZ"
	For multiple Group name 
	
  .PARAMETER GroupName	
    Remote Copy Group Name

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-RCopyGroup_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-RCopyGroup_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	
	#Build uri
	if($GroupName)
	{
		$lista = $GroupName.split(",")
		
		$count = 1
		foreach($sub in $lista)
		{	
			$Query = $Query.Insert($Query.Length-3," name LIKE $sub")			
			if($lista.Count -gt 1)
			{
				if($lista.Count -ne $count)
				{
					$Query = $Query.Insert($Query.Length-3," OR ")
					$count = $count + 1
				}				
			}				
		}
		
		#Build uri
		$uri = '/remotecopygroups/'+$Query
		
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members	
		}
	}
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/remotecopygroups' -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}		
	}
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-RCopyGroup_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While executing Get-RCopyGroup_WSAPI. Expected result not found with given filter option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-RCopyGroup_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-RCopyGroup_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-RCopyGroup_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-RCopyGroup_WSAPI

############################################################################################################################################
## FUNCTION Get-RCopyGroupTarget_WSAPI
############################################################################################################################################
Function Get-RCopyGroupTarget_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get all or single Remote Copy Group target
  
  .DESCRIPTION
	Get all or single Remote Copy Group target
        
  .EXAMPLE
	Get-RCopyGroupTarget_WSAPI
	Get List of Groups target
	
  .EXAMPLE
	Get-RCopyGroupTarget_WSAPI -TargetName xxx	
	Get Single Target
	
  .PARAMETER GroupName	
    Remote Copy Group Name
	
  .PARAMETER TargetName	
    Target Name

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-RCopyGroupTarget_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-RCopyGroupTarget_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,
	  
	  [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null	
	
	if($TargetName)
	{
		#Request
		$uri = '/remotecopygroups/'+$GroupName+'/targets/'+$TargetName
		
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}
	}
	else
	{
		#Request
		$uri = '/remotecopygroups/'+$GroupName+'/targets'
		
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}
	}	
	
		  
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Command Get-RCopyGroupTarget_WSAPI Successfully Executed" $Info
		
		return $dataPS		
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-RCopyGroupTarget_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-RCopyGroupTarget_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-RCopyGroupTarget_WSAPI

############################################################################################################################################
## FUNCTION Get-RCopyGroupVv_WSAPI
############################################################################################################################################
Function Get-RCopyGroupVv_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get all or single Remote Copy Group volume
  
  .DESCRIPTION
	Get all or single Remote Copy Group volume
        
  .EXAMPLE
	Get-RCopyGroupVv_WSAPI -GroupName asRCgroup
	
  .EXAMPLE
	Get-RCopyGroupVv_WSAPI -GroupName asRCgroup -VolumeName Test
	
  .PARAMETER GroupName	
    Remote Copy Group Name
	
  .PARAMETER VolumeName	
    Remote Copy Volume Name

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-RCopyGroupVv_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-RCopyGroupVv_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $GroupName,
	  
	  [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null	
	
	if($VolumeName)
	{
		#Request
		$uri = '/remotecopygroups/'+$GroupName+'/volumes/'+$VolumeName
		
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}
	}
	else
	{
		#Request
		$uri = '/remotecopygroups/'+$GroupName+'/volumes'
		
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}	
	}	
		  
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Command Get-RCopyGroupVv_WSAPI Successfully Executed" $Info
		
		return $dataPS		
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-RCopyGroupVv_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-RCopyGroupVv_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-RCopyGroupVv_WSAPI

############################################################################################################################################
## FUNCTION Get-RCopyLink_WSAPI
############################################################################################################################################
Function Get-RCopyLink_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get all or single Remote Copy Link
  
  .DESCRIPTION
	Get all or single Remote Copy Link
        
  .EXAMPLE
	Get-RCopyLink_WSAPI
	Get List Remote Copy Link
	
  .EXAMPLE
	Get-RCopyLink_WSAPI -LinkName xxx
	Get Single Remote Copy Link
	
  .PARAMETER LinkName	
    Remote Copy Link Name

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-RCopyLink_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-RCopyLink_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LinkName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null	
	
	if($LinkName)
	{
		#Request
		$uri = '/remotecopylinks/'+$LinkName
		
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}
	}
	else
	{
		#Request
		
		$Result = Invoke-WSAPI -uri '/remotecopylinks' -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}	
	}	
		  
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Command Get-RCopyLink_WSAPI Successfully Executed" $Info
		
		return $dataPS		
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-RCopyLink_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-RCopyLink_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-RCopyLink_WSAPI


Export-ModuleMember New-RCopyGroup_WSAPI , Start-RCopyGroup_WSAPI , Stop-RCopyGroup_WSAPI , Sync-RCopyGroup_WSAPI , Remove-RCopyGroup_WSAPI , Update-RCopyGroup_WSAPI ,
Restore-RCopyGroup_WSAPI , Add-VvToRCopyGroup_WSAPI , Remove-VvFromRCopyGroup_WSAPI , New-RCopyTarget_WSAPI , Update-RCopyTarget_WSAPI , Update-RCopyGroupTarget_WSAPI ,
Add-TargetToRCopyGroup_WSAPI , Remove-TargetFromRCopyGroup_WSAPI , New-SnapRcGroupVv_WSAPI , Get-RCopyInfo_WSAPI , Get-RCopyTarget_WSAPI , Get-RCopyGroup_WSAPI ,
Get-RCopyGroupTarget_WSAPI , Get-RCopyGroupVv_WSAPI , Get-RCopyLink_WSAPI
# SIG # Begin signature block
# MIIhEAYJKoZIhvcNAQcCoIIhATCCIP0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDs2czZfHTUjKVR
# 0GRmMzSr7+g2xveFsz5w5iiNI7XXyKCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPuzCCD7cCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# nbggjkosTREHVqfBAL//xdFtuIoBfnoa7hM5FQ9B98IwDQYJKoZIhvcNAQEBBQAE
# ggEABZDeXsqKypF9Fu0+cuzUARvAdF73M574lWExurAVH0tfYznENOwVmjF1asE0
# E60pRxIPJwvgTCVYzBdagZ4nuFOlFsqaEVOnCAcQFJtPec2/V1FoJkHUCWg6VqSl
# XV6p0Dzcx2lTrdequf+CqO1X1JJUrg1PheDLhEoRpCh64xXWfk8MiFEcqMBPcXwK
# rUxRU8K2YC3K3CsGOnj3AW3QHcO785ntxBXcFahv6fYWyQVE0dycvS1iLoGrJUor
# t6qUNuC46sLHeiM5xTjQgELiYGNkVvWDin+oau2TqmaHv65ePC/pGM9daSL9L8iK
# KaPSYgl+F5ChF261V6sPCRsY0KGCDX0wgg15BgorBgEEAYI3AwMBMYINaTCCDWUG
# CSqGSIb3DQEHAqCCDVYwgg1SAgEDMQ8wDQYJYIZIAWUDBAIBBQAwdwYLKoZIhvcN
# AQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCDfU2LA
# u6g7Y3tXrvrL9Fvf0CX1pq7Eg3Meb+ZdEsXiswIQIq83HH2+/uNiyY6AXQL6RRgP
# MjAyMTA2MTkwNTIxMThaoIIKNzCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA
# 8N0wDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAxMDEw
# MDAwMDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjEw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXKY2tR
# 1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj/TZq
# gfop+N0rcIXeAhjzeG28ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj
# 4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDrDo4s
# 1SPa9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDC
# m2mCtNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1JhL0B
# AgMBAAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATApMCcG
# CCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgw
# FoAU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwoLR1E
# Nt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9zaGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdpY2Vy
# dC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURU
# aW1lc3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrn
# IA6OZ0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQCZk3t
# aaQP9rhwz2Lo9VFKeHk2eie38+dSn5On7UOee+e03UEiifuHokYDTvz0/rdkd2Nf
# I1Jpg4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO+MDh
# XM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j1h9b
# m/cuG08THfdKDXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5Npjhyyja
# W4emii8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHkBdo2l8IVMA0GCSqGSIb3DQEB
# CwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQg
# SUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0zMTAxMDcxMjAwMDBaMHIxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBU
# aW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9
# 0DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5fU1ofue2oPSNs4jkl79jIZCY
# vxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb6+NGRwYaVX4LJ37AovWg4N4i
# Pw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU46gJcWvgzyIQD3XPcXJOCq3f
# QDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mIUF79Zm5WYScpiYRR5oLnRlD9
# lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfxFwbvPc3WTe8GQv2iUypPhR3E
# HTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAdBgNVHQ4EFgQU9LbhIB3+Ka7S
# 5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wEgYD
# VR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4
# oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkwRzA4BgpghkgBhv1sAAIEMCow
# KAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJYIZI
# AYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLpUYdWac3v3dp8qmN6s3jPBjdA
# hO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4
# stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC4HLHmNY8ZOUfSBAYX4k4YU1i
# RiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+tpJn+1Nhiaj1a5bA9FhpDXzI
# AbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6HUSHkWGCbugwtK22ixH67xCUr
# RwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIvIjayS6JKldj1po5SMYIChjCC
# AoICAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hB
# MiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TAN
# BglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJ
# KoZIhvcNAQkFMQ8XDTIxMDYxOTA1MjExOFowKwYLKoZIhvcNAQkQAgwxHDAaMBgw
# FgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJKoZIhvcNAQkEMSIEINaVDF9B32d9
# rQHf8CI6zMCpfqdOxzTWo8jgnEjKpfLSMDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIE
# ILMQkAa8CtmDB5FXKeBEA0Fcg+MpK2FPJpZMjTVx7PWpMA0GCSqGSIb3DQEBAQUA
# BIIBAGySJ2+cnJQYHEb7t6uNVKa2w6YLSj4+5fQTVntubrwQYftWO8cmw1bn0Kr0
# kiVtfUKWvBwFk4tWwf2+NvIGE3SO0nntmeYNvMvUi314Rskfq15zgLtMmcZowm+l
# m37HjBUKXdwzFQ7x4bXPpfgK/J9/Rs0Jta8CnGuN/NlsniiEV77g2qyWOgCn2MvG
# RT0mfzvgXnkhEHOxkrMVZXzl1dH3FriOklUDPdzSTjCttmmkympviUlQevr5SrS1
# 5UzIqBEIhm8o93UEPpKBKHPcQ9ryVqKfgvYHzHpJxzsNgWA+SSxZVwNnkw4kx5cW
# n+MaOc7hKCg6dcjTQyLsq3iC+JI=
# SIG # End signature block
