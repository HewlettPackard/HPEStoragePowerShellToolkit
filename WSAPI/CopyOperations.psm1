####################################################################################
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
##	File Name:		CopyOperations.psm1
##	Description: 	Copy Operations cmdlets 
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
## FUNCTION New-VvSnapshot_WSAPI
############################################################################################################################################
Function New-VvSnapshot_WSAPI 
{
  <#      
  .SYNOPSIS	
	Creating a volume snapshot
  
  .DESCRIPTION	
     Creating a volume snapshot
	 
  .EXAMPLE    
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1
        
  .EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11
        
  .EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello
        
  .EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello -ReadOnly $true
        
  .EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello -ReadOnly $true -ExpirationHours 10
        
  .EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello -ReadOnly $true -ExpirationHours 10 -RetentionHours 10
        
  .EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -AddToSet asvvset
	
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
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : New-VvSnapshot_WSAPI    
    LASTEDIT: 13/01/2018
    KEYWORDS: New-VvSnapshot_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $snpVVName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $ID,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Comment,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $ReadOnly,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $ExpirationHours,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $RetentionHours,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $AddToSet,
	  
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
	$ParameterBody = @{}

    # Name parameter
    $body["action"] = "createSnapshot"

   
    If($snpVVName) 
	{
          $ParameterBody["name"] = "$($snpVVName)"
    }
    If($ID) 
	{
          $ParameterBody["id"] = $ID
    }
	If($Comment) 
	{
          $ParameterBody["comment"] = "$($Comment)"
    }
    If($ReadOnly) 
	{
          $ParameterBody["readOnly"] = $ReadOnly
    }
	If($ExpirationHours) 
	{
          $ParameterBody["expirationHours"] = $ExpirationHours
    }
	If($RetentionHours) 
	{
          $ParameterBody["retentionHours"] = $RetentionHours
    }
	If($AddToSet) 
	{
          $ParameterBody["addToSet"] = "$($AddToSet)"
    }
	
	if($ParameterBody.Count -gt 0)
	{
		$body["parameters"] = $ParameterBody 
	}

    $Result = $null
	
    #Request
	Write-DebugLog "Request: Request to New-VvSnapshot_WSAPI : $snpVVName (Invoke-WSAPI)." $Debug
	
	$uri = '/volumes/'+$VolumeName
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: volume snapshot:$snpVVName created successfully" $Info
				
		# Results
		return $Result
		Write-DebugLog "End: New-VvSnapshot_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating volume snapshot: $snpVVName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating volume snapshot: $snpVVName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END New-VvSnapshot_WSAPI

############################################################################################################################################
## FUNCTION New-VvListGroupSnapshot_WSAPI
############################################################################################################################################
Function New-VvListGroupSnapshot_WSAPI 
{
  <#      
  .SYNOPSIS	
	Creating group snapshots of a virtual volumes list
  
  .DESCRIPTION
	Creating group snapshots of a virtual volumes list
        
  .EXAMPLE    
	New-VvListGroupSnapshot_WSAPI -VolumeName xyz -SnapshotName asSnpvv -SnapshotId 10 -SnapshotWWN 60002AC0000000000101142300018F8D -ReadWrite $true -Comment Hello -ReadOnly $true -Match $true -ExpirationHours 10 -RetentionHours 10 -SkipBlock $true
	
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
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : New-VvListGroupSnapshot_WSAPI    
    LASTEDIT: 01/02/2018
    KEYWORDS: New-VvListGroupSnapshot_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $SnapshotName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $SnapshotId,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $SnapshotWWN,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $ReadWrite,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Comment,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $ReadOnly,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $Match,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $ExpirationHours,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $RetentionHours,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $SkipBlock,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $AddToSet,
	  
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
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}	
	$VolumeGroupBody = @()
	$ParameterBody = @{}

    # Name parameter
    $body["action"] = 8	
   
    If ($VolumeName) 
	{
		$VName=@{}
		$VName["volumeName"] = "$($VolumeName)"	
		$VolumeGroupBody += $VName		
    }
	If ($SnapshotName) 
	{
		$snpName=@{}
		$snpName["snapshotName"] = "$($SnapshotName)"	
		$VolumeGroupBody += $snpName
    }
    If ($SnapshotId) 
	{
		$snpId=@{}
		$snpId["snapshotId"] = $SnapshotId	
		$VolumeGroupBody += $snpId
    }
	If ($SnapshotWWN) 
	{
		$snpwwn=@{}
		$snpwwn["SnapshotWWN"] = "$($SnapshotWWN)"	
		$VolumeGroupBody += $snpwwn
    }
    If ($ReadWrite) 
	{
		$rw=@{}
		$rw["readWrite"] = $ReadWrite	
		$VolumeGroupBody += $rw
    }
	
	if($VolumeGroupBody.Count -gt 0)
	{
		$ParameterBody["volumeGroup"] = $VolumeGroupBody 
	}
	
	If ($Comment) 
	{
          $ParameterBody["comment"] = "$($Comment)"
    }	
	If ($ReadOnly) 
	{
          $ParameterBody["readOnly"] = $ReadOnly
    }	
	If ($Match) 
	{
          $ParameterBody["match"] = $Match
    }	
	If ($ExpirationHours) 
	{
          $ParameterBody["expirationHours"] = $ExpirationHours
    }
	If ($RetentionHours) 
	{
          $ParameterBody["retentionHours"] = $RetentionHours
    }
	If ($SkipBlock) 
	{
          $ParameterBody["skipBlock"] = $SkipBlock
    }
	If ($AddToSet) 
	{
          $ParameterBody["addToSet"] = "$($AddToSet)"
    }
	
	if($ParameterBody.Count -gt 0)
	{
		$body["parameters"] = $ParameterBody 
	}
	
    $Result = $null
	
    #Request
	Write-DebugLog "Request: Request to New-VvListGroupSnapshot_WSAPI : $SnapshotName (Invoke-WSAPI)." $Debug
		
    $Result = Invoke-WSAPI -uri '/volumes' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 300)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Group snapshots of a virtual volumes list : $SnapshotName created successfully" $Info
				
		# Results
		return $Result
		Write-DebugLog "End: New-VvListGroupSnapshot_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating group snapshots of a virtual volumes list : $SnapshotName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating group snapshots of a virtual volumes list : $SnapshotName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END New-VvListGroupSnapshot_WSAPI

############################################################################################################################################
## FUNCTION New-VvPhysicalCopy_WSAPI
############################################################################################################################################
Function New-VvPhysicalCopy_WSAPI 
{
  <#      
  .SYNOPSIS	
	Create a physical copy of a volume.
	
  .DESCRIPTION
    Create a physical copy of a volume.
    
  .EXAMPLE    
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test1
    
  .EXAMPLE
    New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -DestCPG as_cpg
    
  .EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -Online
    
  .EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -WWN "60002AC0000000000101142300018F8D"
    
  .EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -TPVV
    
  .EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -SnapCPG as_cpg
    
  .EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -SkipZero
    
  .EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -Compression
    
  .EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -SaveSnapshot
    
  .EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName $val -DestVolume Test -Priority high
	
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
  
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : New-VvPhysicalCopy_WSAPI    
    LASTEDIT: 02/02/2018
    KEYWORDS: New-VvPhysicalCopy_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $DestVolume,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $DestCPG,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $Online,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $WWN,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $TPVV,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $TDVV,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $Reduce,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $SnapCPG,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $SkipZero,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $Compression,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $SaveSnapshot,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Priority,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
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
	$ParameterBody = @{}

    # Name parameter
    $body["action"] = "createPhysicalCopy"

   
    If ($DestVolume) 
	{
          $ParameterBody["destVolume"] = "$($DestVolume)"
    }    
	If ($Online) 
	{
		$ParameterBody["online"] = $true
		If ($DestCPG) 
		{
		  $ParameterBody["destCPG"] = $DestCPG
		}
		else
		{
			return "Specifies the destination CPG for an online copy."
		}
    }
	
    If ($WWN) 
	{
          $ParameterBody["WWN"] = "$($WWN)"
    }
	If ($TPVV) 
	{
          $ParameterBody["tpvv"] = $true
    }
	If ($TDVV) 
	{
          $ParameterBody["tdvv"] = $true
    }
	If ($Reduce) 
	{
          $ParameterBody["reduce"] = $true
    }	
	If ($SnapCPG) 
	{
          $ParameterBody["snapCPG"] = "$($SnapCPG)"
    }
	If ($SkipZero) 
	{
          $ParameterBody["skipZero"] = $true
    }
	If ($Compression) 
	{
          $ParameterBody["compression"] = $true
    }
	If ($SaveSnapshot) 
	{
          $ParameterBody["saveSnapshot"] = $SaveSnapshot
    }
	If ($Priority) 
	{
		if($Priority.ToUpper() -eq "HIGH")
		{
			$ParameterBody["priority"] = 1
		}
		elseif($Priority.ToUpper() -eq "MED")
		{
			$ParameterBody["priority"] = 2
		}
		elseif($Priority.ToUpper() -eq "LOW")
		{
			$ParameterBody["priority"] = 3
		}
		else
		{
			return "Priority value is wrong : $Priority , value should be [HIGH | MED | LOW ]."
		}
          
    }
	
	if($ParameterBody.Count -gt 0)
	{
		$body["parameters"] = $ParameterBody 
	}

    $Result = $null
	
    #Request
	Write-DebugLog "Request: Request to New-VvPhysicalCopy_WSAPI : $VolumeName (Invoke-WSAPI)." $Debug
	
	$uri = '/volumes/'+$VolumeName
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Physical copy of a volume: $VolumeName created successfully" $Info
				
		# Results
		return $Result
		Write-DebugLog "End: New-VvPhysicalCopy_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating Physical copy of a volume : $VolumeName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating Physical copy of a volume : $VolumeName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END New-VvPhysicalCopy_WSAPI

############################################################################################################################################
## FUNCTION Reset-PhysicalCopy_WSAPI
############################################################################################################################################
Function Reset-PhysicalCopy_WSAPI 
{
  <#
  .SYNOPSIS
	Resynchronizing a physical copy to its parent volume
  
  .DESCRIPTION
	Resynchronizing a physical copy to its parent volume
        
  .EXAMPLE    
	Reset-PhysicalCopy_WSAPI -VolumeName xxx
	Resynchronizing a physical copy to its parent volume
	
  .PARAMETER VolumeName 
	The <VolumeName> parameter specifies the name of the destination volume you want to resynchronize.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Reset-PhysicalCopy_WSAPI    
    LASTEDIT: 02/02/2018
    KEYWORDS: Reset-PhysicalCopy_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
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
	
	$body["action"] = 2	
    
    $Result = $null	
	$uri = "/volumes/" + $VolumeName
	
    #Request
	Write-DebugLog "Request: Request to Reset-PhysicalCopy_WSAPI : $VolumeName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Resynchronize a physical copy to its parent volume : $VolumeName ." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Reset-PhysicalCopy_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Resynchronizing a physical copy to its parent volume : $VolumeName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Resynchronizing a physical copy to its parent volume : $VolumeName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Reset-PhysicalCopy_WSAPI

############################################################################################################################################
## FUNCTION Stop-PhysicalCopy_WSAPI
############################################################################################################################################
Function Stop-PhysicalCopy_WSAPI 
{
  <#
  .SYNOPSIS
	Stop a physical copy of given Volume
  
  .DESCRIPTION
	Stop a physical copy of given Volume
        
  .EXAMPLE    
	Stop-PhysicalCopy_WSAPI -VolumeName xxx
	Stop a physical copy of given Volume 
	
  .PARAMETER VolumeName 
	The <VolumeName> parameter specifies the name of the destination volume you want to resynchronize.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Stop-PhysicalCopy_WSAPI    
    LASTEDIT: 02/02/2018
    KEYWORDS: Stop-PhysicalCopy_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
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
	
	$body["action"] = 1	
    
    $Result = $null	
	$uri = "/volumes/" + $VolumeName
	
    #Request
	Write-DebugLog "Request: Request to Stop-PhysicalCopy_WSAPI : $VolumeName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Stop a physical copy of : $VolumeName ." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Stop-PhysicalCopy_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While stopping a physical copy : $VolumeName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While stopping a physical copy : $VolumeName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Stop-PhysicalCopy_WSAPI

############################################################################################################################################
## FUNCTION Move-VirtualCopy_WSAPI
############################################################################################################################################
Function Move-VirtualCopy_WSAPI 
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
	Enables (true) or disables (false) executing the promote operation on an online volume. The default setting is false.
  
  .PARAMETER Priority
	Task priority.
	HIGH : High priority.
	MED : Medium priority.
	LOW : Low priority.
	
  .PARAMETER AllowRemoteCopyParent
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been started. If the Remote Copy group has been started, this command fails.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Move-VirtualCopy_WSAPI    
    LASTEDIT: 02/02/2018
    KEYWORDS: Move-VirtualCopy_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VirtualCopyName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Online,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Priority,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AllowRemoteCopyParent,
	  
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
	
	$body["action"] = 4
	
	if($Online)
	{
		$body["online"] = $true	
	}	
	if($Priority)
	{		
		if($Priority.ToUpper() -eq "HIGH")
		{
			$body["priority"] = 1		
		}
		elseif($Priority.ToUpper() -eq "MED")
		{
			$body["priority"] = 2		
		}
		elseif($Priority.ToUpper() -eq "LOW")
		{
			$body["priority"] = 3		
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Priority $Priority in incorrect "
			Return "FAILURE : -Priority :- $Priority is an Incorrect Priority  [high | med | low]  can be used only . "
		}
		
	}
	if($AllowRemoteCopyParent)
	{
		$body["allowRemoteCopyParent"] = $true	
	}
    
    $Result = $null	
	$uri = "/volumes/" + $VirtualCopyName
	
    #Request
	Write-DebugLog "Request: Request to Move-VirtualCopy_WSAPI : $VirtualCopyName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	 
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Promoted a virtual copy : $VirtualCopyName ." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Move-VirtualCopy_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Promoting a virtual copy : $VirtualCopyName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Promoting a virtual copy : $VirtualCopyName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Move-VirtualCopy_WSAPI

############################################################################################################################################
## FUNCTION Move-VvSetVirtualCopy_WSAPI
############################################################################################################################################
Function Move-VvSetVirtualCopy_WSAPI 
{
  <#
  .SYNOPSIS
	To promote the changes from a vv set virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
  
  .DESCRIPTION
	To promote the changes from a vv set virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
        
  .EXAMPLE
	Move-VvSetVirtualCopy_WSAPI
        
  .EXAMPLE	
	Move-VvSetVirtualCopy_WSAPI -VVSetName xyz
        
  .EXAMPLE	
	Move-VvSetVirtualCopy_WSAPI -VVSetName xyz -Online
        
  .EXAMPLE	
	Move-VvSetVirtualCopy_WSAPI -VVSetName xyz -Priority HIGH
        
  .EXAMPLE	
	Move-VvSetVirtualCopy_WSAPI -VVSetName xyz -AllowRemoteCopyParent
	
  .PARAMETER VirtualCopyName 
	The <virtual_copy_name> parameter specifies the name of the virtual copy to be promoted.
  
  .PARAMETER Online	
	Enables (true) or disables (false) executing the promote operation on an online volume. The default setting is false.
  
  .PARAMETER Priority
	Task priority.
	HIGH : High priority.
	MED : Medium priority.
	LOW : Low priority.
	
  .PARAMETER AllowRemoteCopyParent
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been started. If the Remote Copy group has been started, this command fails.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Move-VvSetVirtualCopy_WSAPI    
    LASTEDIT: 02/02/2018
    KEYWORDS: Move-VvSetVirtualCopy_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VVSetName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Online,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Priority,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AllowRemoteCopyParent,
	  
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
	
	$body["action"] = 4
	
	if($Online)
	{
		$body["online"] = $true	
	}	
	if($Priority)
	{		
		if($Priority.ToUpper() -eq "HIGH")
		{
			$body["priority"] = 1		
		}
		elseif($Priority.ToUpper() -eq "MED")
		{
			$body["priority"] = 2		
		}
		elseif($Priority.ToUpper() -eq "LOW")
		{
			$body["priority"] = 3		
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Priority $Priority in incorrect "
			Return "FAILURE : -Priority :- $Priority is an Incorrect Priority  [high | med | low]  can be used only . "
		}
		
	}
	if($AllowRemoteCopyParent)
	{
		$body["allowRemoteCopyParent"] = $true	
	}
    
    $Result = $null	
	$uri = "/volumesets/" + $VVSetName
	
    #Request
	Write-DebugLog "Request: Request to Move-VvSetVirtualCopy_WSAPI : $VVSetName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	 
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Promoted a VV-Set virtual copy : $VVSetName ." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Move-VvSetVirtualCopy_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Promoting a VV-Set virtual copy : $VVSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Promoting a VV-Set virtual copy : $VVSetName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Move-VvSetVirtualCopy_WSAPI

############################################################################################################################################
## FUNCTION New-VvSetSnapshot_WSAPI
############################################################################################################################################
Function New-VvSetSnapshot_WSAPI 
{
  <#      
  .SYNOPSIS	
	Create a VV-set snapshot.
	
  .DESCRIPTION	
    Create a VV-set snapshot.
	Any user with the Super or Edit role or any role granted sv_create permission (for snapshots) can create a VV-set snapshot.
    
  .EXAMPLE    
	New-VvSetSnapshot_WSAPI -VolumeSetName Test_delete -SnpVVName PERF_AIX38 -ID 110 -Comment Hello -readOnly -ExpirationHours 1 -RetentionHours 1
	
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
	
  .Notes
    NAME    : New-VvSetSnapshot_WSAPI    
    LASTEDIT: 05/02/2018
    KEYWORDS: New-VvSetSnapshot_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeSetName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $SnpVVName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $ID,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Comment,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [switch]
	  $readOnly,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $ExpirationHours,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $RetentionHours,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $AddToSet,

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
	$ParameterBody = @{}

    # Name parameter
    $body["action"] = "createSnapshot"

   
    If ($SnpVVName) 
	{
		$ParameterBody["name"] = "$($SnpVVName)"
    }    
	If ($ID) 
	{
		$ParameterBody["id"] = $ID		
    }	
    If ($Comment) 
	{
		$ParameterBody["comment"] = "$($Comment)"
    }
	If ($ReadOnly) 
	{
		$ParameterBody["readOnly"] = $true
    }
	If ($ExpirationHours) 
	{
		$ParameterBody["expirationHours"] = $ExpirationHours
    }
	If ($RetentionHours) 
	{
		$ParameterBody["retentionHours"] = "$($RetentionHours)"
    }
	If ($AddToSet) 
	{
		$ParameterBody["addToSet"] = "$($AddToSet)"
    }
	if($ParameterBody.Count -gt 0)
	{
		$body["parameters"] = $ParameterBody 
	}
	
    $Result = $null	
    #Request
	Write-DebugLog "Request: Request to New-VvSetSnapshot_WSAPI : $SnpVVName (Invoke-WSAPI)." $Debug	
	$uri = '/volumesets/'+$VolumeSetName
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: VV-set snapshot : $SnpVVName created successfully" $Info
				
		# Results
		return $Result
		Write-DebugLog "End: New-VvSetSnapshot_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating VV-set snapshot : $SnpVVName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating VV-set snapshot : $SnpVVName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END New-VvSetSnapshot_WSAPI

############################################################################################################################################
## FUNCTION New-VvSetPhysicalCopy_WSAPI
############################################################################################################################################
Function New-VvSetPhysicalCopy_WSAPI 
{
  <#      
  .SYNOPSIS	
	Create a VV-set snapshot.
	
  .DESCRIPTION	
    Create a VV-set snapshot.
	Any user with the Super or Edit role or any role granted sv_create permission (for snapshots) can create a VV-set snapshot.
    
  .EXAMPLE    
	New-VvSetPhysicalCopy_WSAPI -VolumeSetName Test_delete -DestVolume PERF_AIX38 
	
  .PARAMETER VolumeSetName
	The <VolumeSetName> parameter specifies the name of the VV set to copy.
	
  .PARAMETER DestVolume
	Specifies the destination volume set.
  
  .PARAMETER SaveSnapshot
	Enables (true) or disables (false) whether to save the source volume snapshot after completing VV set copy.
  
  .PARAMETER Priority
	Task priority.
	HIGH High priority.
	MED Medium priority.
	LOW Low priority.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : New-VvSetPhysicalCopy_WSAPI    
    LASTEDIT: 05/02/2018
    KEYWORDS: New-VvSetPhysicalCopy_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeSetName,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $DestVolume,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $SaveSnapshot,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Priority,
	  
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
	$ParameterBody = @{}

    # Name parameter
    $body["action"] = "createPhysicalCopy"

   
    If ($DestVolume) 
	{
		$ParameterBody["destVolume"] = "$($DestVolume)"
    }    
	If ($SaveSnapshot) 
	{
		$ParameterBody["saveSnapshot"] = $SaveSnapshot		
    }
	if($Priority)
	{		
		if($Priority -eq "HIGH")
		{
			$ParameterBody["priority"] = 1		
		}
		elseif($Priority -eq "MED")
		{
			$ParameterBody["priority"] = 2		
		}
		elseif($Priority -eq "LOW")
		{
			$ParameterBody["priority"] = 3		
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Priority $Priority in incorrect "
			Return "FAILURE : -Priority :- $Priority is an Incorrect Priority  [high | med | low]  can be used only . "
		}
		
	}
	if($ParameterBody.Count -gt 0)
	{
		$body["parameters"] = $ParameterBody 
	}
	
    $Result = $null	
    #Request
	Write-DebugLog "Request: Request to New-VvSetPhysicalCopy_WSAPI : $VolumeSetName (Invoke-WSAPI)." $Debug	
	$uri = '/volumesets/'+$VolumeSetName
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Physical copy of a VV set : $VolumeSetName created successfully" $Info
				
		# Results
		return $Result
		Write-DebugLog "End: New-VvSetPhysicalCopy_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating Physical copy of a VV set : $VolumeSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating Physical copy of a VV set : $VolumeSetName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END New-VvSetPhysicalCopy_WSAPI

############################################################################################################################################
## FUNCTION Reset-VvSetPhysicalCopy_WSAPI
############################################################################################################################################
Function Reset-VvSetPhysicalCopy_WSAPI 
{
  <#
  .SYNOPSIS
	Resynchronizing a VV set physical copy
  
  .DESCRIPTION
	Resynchronizing a VV set physical copy
        
  .EXAMPLE
    Reset-VvSetPhysicalCopy_WSAPI -VolumeSetName xyz
         
  .EXAMPLE 
	Reset-VvSetPhysicalCopy_WSAPI -VolumeSetName xxx -Priority HIGH
		
  .PARAMETER VolumeSetName 
	The <VolumeSetName> specifies the name of the destination VV set to resynchronize.
	
  .PARAMETER Priority
	Task priority.
	HIGH High priority.
	MED Medium priority.
	LOW Low priority.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Reset-VvSetPhysicalCopy_WSAPI    
    LASTEDIT: 02/02/2018
    KEYWORDS: Reset-VvSetPhysicalCopy_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeSetName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Priority,
	  
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
	
	$body["action"] = 3
	
	if($Priority)
	{		
		if($Priority -eq "HIGH")
		{
			$body["priority"] = 1		
		}
		elseif($Priority -eq "MED")
		{
			$body["priority"] = 2		
		}
		elseif($Priority -eq "LOW")
		{
			$body["priority"] = 3		
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Priority $Priority in incorrect "
			Return "FAILURE : -Priority :- $Priority is an Incorrect Priority  [high | med | low]  can be used only . "
		}
		
	}
    
    $Result = $null	
	$uri = "/volumesets/" + $VolumeSetName
	
    #Request
	Write-DebugLog "Request: Request to Reset-VvSetPhysicalCopy_WSAPI : $VolumeSetName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Resynchronize a VV set physical copy : $VolumeSetName ." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Reset-VvSetPhysicalCopy_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Resynchronizing a VV set physical copy : $VolumeSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Resynchronizing a VV set physical copy : $VolumeSetName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Reset-VvSetPhysicalCopy_WSAPI

############################################################################################################################################
## FUNCTION Stop-VvSetPhysicalCopy_WSAPI
############################################################################################################################################
Function Stop-VvSetPhysicalCopy_WSAPI 
{
  <#
  .SYNOPSIS
	Stop a VV set physical copy
  
  .DESCRIPTION
	Stop a VV set physical copy
        
  .EXAMPLE
    Stop-VvSetPhysicalCopy_WSAPI -VolumeSetName xxx
         
  .EXAMPLE 
	Stop-VvSetPhysicalCopy_WSAPI -VolumeSetName xxx -Priority HIGH
	
  .PARAMETER VolumeSetName 
	The <VolumeSetName> specifies the name of the destination VV set to resynchronize.
	
  .PARAMETER Priority
	Task priority.
	HIGH High priority.
	MED Medium priority.
	LOW Low priority.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Stop-VvSetPhysicalCopy_WSAPI    
    LASTEDIT: 02/02/2018
    KEYWORDS: Stop-VvSetPhysicalCopy_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeSetName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Priority,
	  
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
	
	$body["action"] = 4
	
	if($Priority)
	{		
		if($Priority -eq "HIGH")
		{
			$body["priority"] = 1		
		}
		elseif($Priority -eq "MED")
		{
			$body["priority"] = 2		
		}
		elseif($Priority -eq "LOW")
		{
			$body["priority"] = 3		
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Priority $Priority in incorrect "
			Return "FAILURE : -Priority :- $Priority is an Incorrect Priority  [high | med | low]  can be used only . "
		}
		
	}
    
    $Result = $null	
	$uri = "/volumesets/" + $VolumeSetName
	
    #Request
	Write-DebugLog "Request: Request to Stop-VvSetPhysicalCopy_WSAPI : $VolumeSetName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	 
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Stop a VV set physical copy : $VolumeSetName ." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Stop-VvSetPhysicalCopy_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Stopping a VV set physical copy : $VolumeSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Stopping a VV set physical copy : $VolumeSetName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Stop-VvSetPhysicalCopy_WSAPI

############################################################################################################################################
## FUNCTION Update-VvOrVvSets_WSAPI
############################################################################################################################################
Function Update-VvOrVvSets_WSAPI 
{
  <#      
  .SYNOPSIS	
	Update virtual copies or VV-sets
	
  .DESCRIPTION	
    Update virtual copies or VV-sets
	
  .EXAMPLE
	Update-VvOrVvSets_WSAPI -VolumeSnapshotList "xxx,yyy,zzz" 
	Update virtual copies or VV-sets
	
  .EXAMPLE
	Update-VvOrVvSets_WSAPI -VolumeSnapshotList "xxx,yyy,zzz" -ReadOnly $true/$false
	Update virtual copies or VV-sets
	
  .PARAMETER VolumeSnapshotList
	List one or more volume snapshots to update. If specifying a vvset, use the	following format
	set:vvset_name.
	
  .PARAMETER VolumeSnapshotList
	Specifies that if the virtual copy is read-write, the command updates the read-only parent volume also.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Update-VvOrVvSets_WSAPI    
    LASTEDIT: 06/02/2018
    KEYWORDS: Update-VvOrVvSets_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [String[]]
	  $VolumeSnapshotList,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $ReadOnly,
	  
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
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}	
	$ParameterBody = @{}

    # Name parameter
    $body["action"] = 7

   
    If ($VolumeSnapshotList) 
	{
		$ParameterBody["volumeSnapshotList"] = $VolumeSnapshotList
    }    
	If ($ReadOnly) 
	{
		$ParameterBody["readOnly"] = $ReadOnly		
    }
	
	if($ParameterBody.Count -gt 0)
	{
		$body["parameters"] = $ParameterBody 
	}
	
    $Result = $null	
    #Request
	Write-DebugLog "Request: Request to Update-VvOrVvSets_WSAPI : $VolumeSnapshotList (Invoke-WSAPI)." $Debug	
	
    $Result = Invoke-WSAPI -uri '/volumes/' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Virtual copies or VV-sets : $VolumeSnapshotList successfully Updated." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: Update-VvOrVvSets_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Updating virtual copies or VV-sets : $VolumeSnapshotList " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Updating virtual copies or VV-sets : $VolumeSnapshotList " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Update-VvOrVvSets_WSAPI


Export-ModuleMember Move-VirtualCopy_WSAPI , Stop-PhysicalCopy_WSAPI , Reset-PhysicalCopy_WSAPI , New-VvPhysicalCopy_WSAPI ,
New-VvListGroupSnapshot_WSAPI , New-VvSnapshot_WSAPI ,  Update-VvOrVvSets_WSAPI , Stop-VvSetPhysicalCopy_WSAPI , Reset-VvSetPhysicalCopy_WSAPI ,
New-VvSetPhysicalCopy_WSAPI , New-VvSetSnapshot_WSAPI , Move-VvSetVirtualCopy_WSAPI
# SIG # Begin signature block
# MIIhEAYJKoZIhvcNAQcCoIIhATCCIP0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDuV+xfKoYjcYeL
# DEiPLREyZ87FxuGv4QSzQQfze8JPGqCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# K2hcLYIRXFMEV59Kgmg0k7cXxfXdEdZz5ATOtxghn7kwDQYJKoZIhvcNAQEBBQAE
# ggEAT4y3jEZGGxMLU3jFbVrd3KkaxkUmAaHkZVzeBu8dbbe/pHA2Lo9iRczgJ1T/
# 14DyVkdG1TKwrhH2Oe7EkZroSyrX6rPJyYC63m37R5Xlg+PMt4bZ5vm02cEW8VO1
# P76jz5hwAUpACqBpShfbjd1P3aADq2jTCEXrLVY6AuEmN4e9zQ10k1eyK/FupRyQ
# hYZTbbpPkrXt1xBd91e0pAc29KpOTJBpQNOrhXFpfWELe/AKXincNLye/uGhPzyj
# JnxwZ/Jq5JMbdaLLytC8ymCEbxORYeCxooclcMPx3nDy3uvtFyjuRtZKajWt/0Xj
# tIr+dH0wQjPuX6luiKUcM8fQRaGCDX0wgg15BgorBgEEAYI3AwMBMYINaTCCDWUG
# CSqGSIb3DQEHAqCCDVYwgg1SAgEDMQ8wDQYJYIZIAWUDBAIBBQAwdwYLKoZIhvcN
# AQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCCHFxgb
# ugO4u6raOxhu0YbgLMZ2SKkhFR5tlcHUAamWAwIQFweRd7XzdCUJCzub+Nyy1hgP
# MjAyMTA2MTkwNTEzNDNaoIIKNzCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA
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
# KoZIhvcNAQkFMQ8XDTIxMDYxOTA1MTM0M1owKwYLKoZIhvcNAQkQAgwxHDAaMBgw
# FgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJKoZIhvcNAQkEMSIEIIC2GSOULf4X
# b9l5u+2Ngii68vs2901Hb+CEcK4AKzhBMDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIE
# ILMQkAa8CtmDB5FXKeBEA0Fcg+MpK2FPJpZMjTVx7PWpMA0GCSqGSIb3DQEBAQUA
# BIIBAKGMMd3Nqr7elNRrdzRUEfadxoQjdJPueG1C0rHtxvf2PbkSPXUyQqxN2gIy
# QQkszaxcGVCm/b68TqFZlyz+HDcHJJjf0NP/Qg+Nwd1eBw3pZ6j6r8UwlDcCuF0M
# IFriykMMfT8LUYxwKrRRrlcyRlib8jT8mqg6UlUMZHyhpyzALQi9qEYGAV5Vkcoc
# Z0uoAcXYz058egRnMv1LR5bNOfIKhzrH7Sdqt/h0qZjEVqZAU5NNhXC8DgZWqr66
# Ym2uagatPst/+WW7e68AcRT5U+6FyFhBYf9SdJuusFfilWUpgb1n5ihf6/cbO/2Y
# IBad2+67GswkvLtiO0lcJ3SzSr4=
# SIG # End signature block
