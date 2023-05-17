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
##	File Name:		StorageVolumes.psm1
##	Description: 	Storage volumes cmdlets 
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
## FUNCTION New-Vv_WSAPI
############################################################################################################################################
Function New-Vv_WSAPI 
{
  <#      
  .SYNOPSIS
	Creates a vitual volume
  
  .DESCRIPTION
    This cmdlet (New-Vv_WSAPI) will be deprecated in a later version of PowerShell Toolkit. Consider using the cmdlet  (New-Vv_WSAPI) instead.
  
	Creates a vitual volume
        
  .EXAMPLE    
	New-Vv_WSAPI -VVName xxx -CpgName xxx -SizeMiB 1
	        
  .EXAMPLE                         
	New-Vv_WSAPI -VVName xxx -CpgName xxx -SizeMiB 1 -Id 1010
	        
  .EXAMPLE                         
	New-Vv_WSAPI -VVName xxx -CpgName xxx -SizeMiB 1 -Comment "This is test vv"
	        
  .EXAMPLE                         
	New-Vv_WSAPI -VVName xxx -CpgName xxx -SizeMiB 1 -OneHost $true
	        
  .EXAMPLE                         
	New-Vv_WSAPI -VVName xxx -CpgName xxx -SizeMiB 1 -Caching $true
	        
  .EXAMPLE                         
	New-Vv_WSAPI -VVName xxx -CpgName xxx -SizeMiB 1 -HostDIF NO_HOST_DIF
	
  .PARAMETER VVName
	Volume Name.
	
  .PARAMETER CpgName
	Volume CPG.
	
  .PARAMETER SizeMiB
	Volume size.
	
  .PARAMETER Id
	Specifies the ID of the volume. If not specified, the next available ID is chosen.
	
  .PARAMETER Comment
	Additional informations about the volume.
	
  .PARAMETER StaleSS
	True—Stale snapshots. If there is no space for a copyon- write operation, the snapshot can go stale but the host write proceeds without an error. 
	false—No stale snapshots. If there is no space for a copy-on-write operation, the host write fails.
	
  .PARAMETER OneHost
	True—Indicates a volume is constrained to export to one host or one host cluster. 
	false—Indicates a volume exported to multiple hosts for use by a cluster-aware application, or when port presents VLUNs are used.
	
  .PARAMETER ZeroDetect
	True—Indicates that the storage system scans for zeros in the incoming write data. 
	false—Indicates that the storage system does not scan for zeros in the incoming write data.
	
  .PARAMETER System
	True— Special volume used by the system. false—Normal user volume.
	
  .PARAMETER Caching
	This is a read-only policy and cannot be set. true—Indicates that the storage system is enabled for write caching, read caching, and read ahead for the volume. 
	false—Indicates that the storage system is disabled for write caching, read caching, and read ahead for the volume.
	
  .PARAMETER Fsvc
	This is a read-only policy and cannot be set. true —Indicates that File Services uses this volume. false —Indicates that File Services does not use this volume.
	
  .PARAMETER HostDIF
	Type of host-based DIF policy, 3PAR_HOST_DIF is for 3PAR host-based DIF supported, 
	STD_HOST_DIF is for Standard SCSI host-based DIF supported and NO_HOST_DIF is for Volume does not support host-based DIF.
	
  .PARAMETER SnapCPG
	Specifies the name of the CPG from which the snapshot space will be allocated.
	
  .PARAMETER SsSpcAllocWarningPct
	Enables a snapshot space allocation warning. A warning alert is generated when the reserved snapshot space of the volume exceeds 
	the indicated percentage of the volume size.
	
  .PARAMETER SsSpcAllocLimitPct
	Sets a snapshot space allocation limit. The snapshot space of the volume is prevented from growing beyond the indicated percentage of the volume size.
	
  .PARAMETER tpvv
	Create thin volume.
	
  .PARAMETER tdvv
	Enables (true) or disables (false) TDVV creation. Defaults to false.
	With both tpvv and tdvv set to FALSE or unspecified, defaults to FPVV .
			
  .PARAMETER Reduce
	Enables (true) or disables (false) a thinly deduplicated and compressed volume.

  .PARAMETER UsrSpcAllocWarningPct
	Create fully provisionned volume.
	
  .PARAMETER UsrSpcAllocLimitPct
	Space allocation limit.
	
  .PARAMETER ExpirationHours
	Specifies the relative time (from the current time) that the volume expires. Value is a positive integer with a range of 1–43,800 hours (1825 days).
	
  .PARAMETER RetentionHours
	Specifies the amount of time relative to the current time that the volume is retained. Value is a positive integer with a range of 1– 43,800 hours (1825 days).
	
  .PARAMETER Compression   
	Enables (true) or disables (false) creating thin provisioned volumes with compression. Defaults to false (create volume without compression).
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : New-Vv_WSAPI    
    LASTEDIT: 02/08/2018
    KEYWORDS: New-Vv_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Volume Name')]
      [String]
	  $VVName,
	  
      [Parameter(Mandatory = $true,HelpMessage = 'Volume CPG')]
      [String]
	  $CpgName,
	  
      [Parameter(Mandatory = $true,HelpMessage = 'Volume size')]
      [int]
	  $SizeMiB,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the ID of the volume. If not specified, the next available ID is chosen')]
      [int]
	  $Id,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Additional informations about the volume')]
      [String]
	  $Comment,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'true—Stale snapshots. If there is no space for a copyon- write operation, the snapshot can go stale but the host write proceeds without an error. false—No stale snapshots. If there is no space for a copy-on-write operation, the host write fails')]
      [Boolean]
	  $StaleSS ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'true—Indicates a volume is constrained to export to one host or one host cluster. false—Indicates a volume exported to multiple hosts for use by a cluster-aware application, or when port presents VLUNs are used')]
      [Boolean]
	  $OneHost,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'true—Indicates that the storage system scans for zeros in the incoming write data. false—Indicates that the storage system does not scan for zeros in the incoming write data.')]
      [Boolean]
	  $ZeroDetect,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'true— Special volume used by the system. false—Normal user volume')]
      [Boolean]
	  $System ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'This is a read-only policy and cannot be set. true—Indicates that the storage system is enabled for write caching, read caching, and read ahead for the volume. false—Indicates that the storage system is disabled for write caching, read caching, and read ahead for the volume.')]
      [Boolean]
	  $Caching ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'This is a read-only policy and cannot be set. true —Indicates that File Services uses this volume. false —Indicates that File Services does not use this volume.')]
      [Boolean]
	  $Fsvc ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Type of host-based DIF policy, 3PAR_HOST_DIF is for 3PAR host-based DIF supported, STD_HOST_DIF is for Standard SCSI host-based DIF supported and NO_HOST_DIF is for Volume does not support host-based DIF.')]
      [string]
	  $HostDIF ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the name of the CPG from which the snapshot space will be allocated.')]
      [String]
	  $SnapCPG,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Enables a snapshot space allocation warning. A warning alert is generated when the reserved snapshot space of the volume exceeds the indicated percentage of the volume size')]
      [int]
	  $SsSpcAllocWarningPct ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Sets a snapshot space allocation limit. The snapshot space of the volume is prevented from growing beyond the indicated percentage of the volume size.')]
      [int]
	  $SsSpcAllocLimitPct ,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Create thin volume')]
      [Boolean]
	  $TPVV = $false,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Create fully provisionned volume')]
      [Boolean]
	  $TDVV = $false,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Reduce')]
      [Boolean]
	  $Reduce = $false,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Space allocation warning')]
      [int]
	  $UsrSpcAllocWarningPct,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Space allocation limit')]
      [int]
	  $UsrSpcAllocLimitPct,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the relative time (from the current time) that the volume expires. Value is a positive integer with a range of 1–43,800 hours (1825 days).')]
      [int]
	  $ExpirationHours,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the amount of time relative to the current time that the volume is retained. Value is a positive integer with a range of 1– 43,800 hours (1825 days).')]
      [int]
	  $RetentionHours,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Enables (true) or disables (false) creating thin provisioned volumes with compression. Defaults to false (create volume without compression).')]
      [Boolean]
	  $Compression = $false,
	  
	  [Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
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

    # Name parameter
    $body["name"] = "$($VVName)"

    # cpg parameter
    If ($CpgName) {
          $body["cpg"] = "$($CpgName)"
    }

    # sizeMiB parameter
    If ($SizeMiB) {
          $body["sizeMiB"] = $SizeMiB
    }
	
	# id
    If ($Id) {
          $body["id"] = $Id
    }
	
	$VvPolicies = @{}
	
	If ($StaleSS) 
	{
		$VvPolicies["staleSS"] = $true
    }	
	
	If ($OneHost) 
	{
		$VvPolicies["oneHost"] = $true
    } 
	
	If ($ZeroDetect) 
	{
		$VvPolicies["zeroDetect"] = $true
    }	
	
	If ($System) 
	{
		$VvPolicies["system"] = $true
    } 
	
	If ($Caching) 
	{
		$VvPolicies["caching"] = $true
    }	
	
	If ($Fsvc) 
	{
		$VvPolicies["fsvc"] = $true
    }	
	
	If ($HostDIF) 
	{
		if($HostDIF -eq "3PAR_HOST_DIF")
		{
			$VvPolicies["hostDIF"] = 1
		}
		elseif($HostDIF -eq "STD_HOST_DIF")
		{
			$VvPolicies["hostDIF"] = 2
		}
		elseif($HostDIF -eq "NO_HOST_DIF")
		{
			$VvPolicies["hostDIF"] = 3
		}
		else
		{
			Write-DebugLog "Stop: Exiting  New-Vv_WSAPI since HostDIF $HostDIF in incorrect "
			Return "FAILURE : HostDIF :- $HostDIF is an Incorrect Please Use 3PAR_HOST_DIF is for 3PAR host-based DIF supported, STD_HOST_DIF is for Standard SCSI host-based DIF supported and NO_HOST_DIF is for Volume does not support host-based DIF."
		}
    } 	
	
    # comment parameter
    If ($Comment) {
      $body["comment"] = "$($Comment)"
    }
	
	If ($SnapCPG) {
      $body["snapCPG"] = "$($SnapCPG)"
    }
	
	If ($SsSpcAllocWarningPct) {
          $body["ssSpcAllocWarningPct"] = $SsSpcAllocWarningPct
    }
	
	If ($SsSpcAllocLimitPct) {
          $body["ssSpcAllocLimitPct"] = $SsSpcAllocLimitPct
    }

    # tpvv parameter
    If ($TPVV) {
      $body["tpvv"] = $true
    }

    # tdvv parameter
    If ($TDVV) {
      $body["tdvv"] = $true
    }
	
	If($Reduce) 
	{
      $body["reduce"] = $true
    }
	

    # usrSpcAllocWarningPct parameter
    If ($UsrSpcAllocWarningPct) {
          $body["usrSpcAllocWarningPct"] = $UsrSpcAllocWarningPct
    }

    # usrSpcAllocLimitPct parameter
    If ($UsrSpcAllocLimitPct) {
          $body["usrSpcAllocLimitPct"] = $UsrSpcAllocLimitPct
    } 
	
	If ($ExpirationHours) {
          $body["expirationHours"] = $ExpirationHours
    }
	
	If ($RetentionHours) {
          $body["retentionHours"] = $RetentionHours
    }
	
	If ($Compression) {
      $body["compression"] = $true
    }
	
	if($VvPolicies.Count -gt 0){$body["policies"] = $VvPolicies }
	
	#$json = $body | ConvertTo-Json  -Compress -Depth 10
	#write-host " Body = $json"
	
    #init the response var
    $Result = $null

    #Request
	Write-DebugLog "Request: Request to New-Vv_WSAPI : $VVName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri '/volumes' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Volumes:$VVName created successfully" $Info
				
		# Results
		Get-Vv_WSAPI -VVName $VVName
		Write-DebugLog "End: New-Vv_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating Volumes: $VVName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating Volumes: $VVName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END New-Vv_WSAPI

############################################################################################################################################
## FUNCTION Update-Vv_WSAPI
############################################################################################################################################
Function Update-Vv_WSAPI 
{
  <#
  .SYNOPSIS
	Update a vitual volume.
  
  .DESCRIPTION
	Update an existing vitual volume.
        
  .EXAMPLE 
	Update-Vv_WSAPI -VVName xxx -NewName zzz
	        
  .EXAMPLE 
	Update-Vv_WSAPI -VVName xxx -ExpirationHours 2
	        
  .EXAMPLE 
	Update-Vv_WSAPI -VVName xxx -OneHost $true
	        
  .EXAMPLE 
	Update-Vv_WSAPI -VVName xxx -SnapCPG xxx
	
  .PARAMETER VVName
	Name of the volume being modified.

  .PARAMETER NewName
	New Volume Name.
	
  .PARAMETER Comment
	Additional informations about the volume.
	
  .PARAMETER WWN
	Specifies changing the WWN of the virtual volume a new WWN.
	If the value of WWN is auto, the system automatically chooses the WWN based on the system serial number, the volume ID, and the wrap counter.
	
  .PARAMETER UserCPG
	User CPG Name.
	
  .PARAMETER StaleSS
	True—Stale snapshots. If there is no space for a copyon- write operation, the snapshot can go stale but the host write proceeds without an error. 
	false—No stale snapshots. If there is no space for a copy-on-write operation, the host write fails.
	
  .PARAMETER OneHost
	True—Indicates a volume is constrained to export to one host or one host cluster. 
	false—Indicates a volume exported to multiple hosts for use by a cluster-aware application, or when port presents VLUNs are used.
	
  .PARAMETER ZeroDetect
	True—Indicates that the storage system scans for zeros in the incoming write data. 
	false—Indicates that the storage system does not scan for zeros in the incoming write data.
	
  .PARAMETER System
	True— Special volume used by the system. false—Normal user volume.
	
  .PARAMETER Caching
	This is a read-only policy and cannot be set. true—Indicates that the storage system is enabled for write caching, read caching, and read ahead for the volume. 
	false—Indicates that the storage system is disabled for write caching, read caching, and read ahead for the volume.
	
  .PARAMETER Fsvc
	This is a read-only policy and cannot be set. true —Indicates that File Services uses this volume. false —Indicates that File Services does not use this volume.
	
  .PARAMETER HostDIF
	Type of host-based DIF policy, 3PAR_HOST_DIF is for 3PAR host-based DIF supported, 
	STD_HOST_DIF is for Standard SCSI host-based DIF supported and NO_HOST_DIF is for Volume does not support host-based DIF.
	
  .PARAMETER SnapCPG
	Specifies the name of the CPG from which the snapshot space will be allocated.
	
  .PARAMETER SsSpcAllocWarningPct
	Enables a snapshot space allocation warning. A warning alert is generated when the reserved snapshot space of the volume exceeds 
	the indicated percentage of the volume size.
	
  .PARAMETER SsSpcAllocLimitPct
	Sets a snapshot space allocation limit. The snapshot space of the volume is prevented from growing beyond the indicated percentage of the volume size.
	
  .PARAMETER tpvv
	Create thin volume.
	
  .PARAMETER tdvv

  .PARAMETER UsrSpcAllocWarningPct
	Create fully provisionned volume.
	
  .PARAMETER UsrSpcAllocLimitPct
	Space allocation limit.
	
  .PARAMETER ExpirationHours
	Specifies the relative time (from the current time) that the volume expires. Value is a positive integer with a range of 1–43,800 hours (1825 days).
	
  .PARAMETER RetentionHours
	Specifies the amount of time relative to the current time that the volume is retained. Value is a positive integer with a range of 1– 43,800 hours (1825 days).
	
  .PARAMETER Compression   
	Enables (true) or disables (false) creating thin provisioned volumes with compression. Defaults to false (create volume without compression).
	
  .PARAMETER RmSsSpcAllocWarning
	Enables (false) or disables (true) removing the snapshot space allocation warning. 
	If false, and warning value is a positive number, then set.

  .PARAMETER RmUsrSpcAllocWarning
	Enables (false) or disables (true) removing the user space allocation warning. If false, and warning value is a posi'

  .PARAMETER RmExpTime
	Enables (false) or disables (true) resetting the expiration time. If false, and expiration time value is a positive number, then set.

  .PARAMETER RmSsSpcAllocLimit
	Enables (false) or disables (true) removing the snapshot space allocation limit. If false, and limit value is 0, setting ignored. If false, and limit value is a positive number, then set
 
  .PARAMETER RmUsrSpcAllocLimit
	Enables (false) or disables (true)false) the allocation limit. If false, and limit value is a positive number, then set
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Update-Vv_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Update-Vv_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0      
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Volume Name')]
      [String]
	  $VVName,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Volume size')]
      [String]
	  $NewName,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Additional informations about the volume')]
      [String]
	  $Comment,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies changing the WWN of the virtual volume a new WWN.')]
      [String]
	  $WWN,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the relative time (from the current time) that the volume expires. Value is a positive integer with a range of 1–43,800 hours (1825 days).')]
      [int]
	  $ExpirationHours,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the amount of time relative to the current time that the volume is retained. Value is a positive integer with a range of 1– 43,800 hours (1825 days).')]
      [int]
	  $RetentionHours,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'true—Stale snapshots. If there is no space for a copyon- write operation, the snapshot can go stale but the host write proceeds without an error. false—No stale snapshots. If there is no space for a copy-on-write operation, the host write fails')]
      [Nullable[boolean]]
	  $StaleSS ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'true—Indicates a volume is constrained to export to one host or one host cluster. false—Indicates a volume exported to multiple hosts for use by a cluster-aware application, or when port presents VLUNs are used')]
      [Nullable[boolean]]
	  $OneHost,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'true—Indicates that the storage system scans for zeros in the incoming write data. false—Indicates that the storage system does not scan for zeros in the incoming write data.')]
      [Nullable[boolean]]
	  $ZeroDetect,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'true— Special volume used by the system. false—Normal user volume')]
      [Nullable[boolean]]
	  $System ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'This is a read-only policy and cannot be set. true—Indicates that the storage system is enabled for write caching, read caching, and read ahead for the volume. false—Indicates that the storage system is disabled for write caching, read caching, and read ahead for the volume.')]
      [Nullable[boolean]]
	  $Caching ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'This is a read-only policy and cannot be set. true —Indicates that File Services uses this volume. false —Indicates that File Services does not use this volume.')]
      [Nullable[boolean]]
	  $Fsvc ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Type of host-based DIF policy, 3PAR_HOST_DIF is for 3PAR host-based DIF supported, STD_HOST_DIF is for Standard SCSI host-based DIF supported and NO_HOST_DIF is for Volume does not support host-based DIF.')]
      [string]$HostDIF ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the name of the CPG from which the snapshot space will be allocated.')]
      [String]
	  $SnapCPG,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Enables a snapshot space allocation warning. A warning alert is generated when the reserved snapshot space of the volume exceeds the indicated percentage of the volume size')]
      [int]
	  $SsSpcAllocWarningPct ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Sets a snapshot space allocation limit. The snapshot space of the volume is prevented from growing beyond the indicated percentage of the volume size.')]
      [int]
	  $SsSpcAllocLimitPct ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'User CPG name')]
      [String]$UserCPG,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Space allocation warning')]
      [int]
	  $UsrSpcAllocWarningPct,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Space allocation limit')]
      [int]
	  $UsrSpcAllocLimitPct,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Enables (false) or disables (true) removing the snapshot space allocation warning. If false, and warning value is a positive number, then set.')]
      [Boolean]
	  $RmSsSpcAllocWarning ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Enables (false) or disables (true) removing the user space allocation warning. If false, and warning value is a posi')]
      [Boolean]
	  $RmUsrSpcAllocWarning ,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Enables (false) or disables (true) resetting the expiration time. If false, and expiration time value is a positive number, then set.')]
      [Boolean]
	  $RmExpTime,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Enables (false) or disables (true) removing the snapshot space allocation limit. If false, and limit value is 0, setting ignored. If false, and limit value is a positive number, then set')]
      [Boolean]
	  $RmSsSpcAllocLimit,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Enables (false) or disables (true)false) the allocation limit. If false, and limit value is a positive number, then set')]
      [Boolean]
	  $RmUsrSpcAllocLimit,
	  
	  [Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}
    
	# New Name parameter
    If ($NewName) {
          $body["newName"] = "$($NewName)"
    }
	
	# comment parameter
    If ($Comment) {
      $body["comment"] = "$($Comment)"
    }
	
	If ($WWN) {
      $body["WWN"] = "$($WWN)"
    }
	
	If ($ExpirationHours) {
          $body["expirationHours"] = $ExpirationHours
    }
	
	If ($RetentionHours) {
          $body["retentionHours"] = $RetentionHours
    }
	
	$VvPolicies = @{}
	
	If ($StaleSS) 
	{
		$VvPolicies["staleSS"] = $true
    }
	If ($StaleSS -eq $false) 
	{
		$VvPolicies["staleSS"] = $false
    }	
	
	If ($OneHost) 
	{
		$VvPolicies["oneHost"] = $true
    }
	If ($OneHost -eq $false) 
	{
		$VvPolicies["oneHost"] = $false
    }
	
	If ($ZeroDetect) 
	{
		$VvPolicies["zeroDetect"] = $true
    }	
	If ($ZeroDetect -eq $false) 
	{
		$VvPolicies["zeroDetect"] = $false
    }
	
	If ($System) 
	{
		$VvPolicies["system"] = $true
    } 
	If ($System -eq $false) 
	{
		$VvPolicies["system"] = $false
    }
	
	If ($Caching) 
	{
		$VvPolicies["caching"] = $true
    }	
	If ($Caching -eq $false) 
	{
		$VvPolicies["caching"] = $false
    }
	
	If ($Fsvc) 
	{
		$VvPolicies["fsvc"] = $true
    }
	If ($Fsvc -eq $false) 
	{
		$VvPolicies["fsvc"] = $false
    }
	
	If ($HostDIF) 
	{
		if($HostDIF -eq "3PAR_HOST_DIF")
		{
			$VvPolicies["hostDIF"] = 1
		}
		elseif($HostDIF -eq "STD_HOST_DIF")
		{
			$VvPolicies["hostDIF"] = 2
		}
		elseif($HostDIF -eq "NO_HOST_DIF")
		{
			$VvPolicies["hostDIF"] = 3
		}
		else
		{
			Write-DebugLog "Stop: Exiting  Update-Vv_WSAPI since HostDIF $HostDIF in incorrect "
			Return "FAILURE : HostDIF :- $HostDIF is an Incorrect Please Use 3PAR_HOST_DIF is for 3PAR host-based DIF supported, STD_HOST_DIF is for Standard SCSI host-based DIF supported and NO_HOST_DIF is for Volume does not support host-based DIF."
		}
    } 	   
	
	If ($SnapCPG) {
      $body["snapCPG"] = "$($SnapCPG)"
    }
	
	If ($SsSpcAllocWarningPct) {
          $body["ssSpcAllocWarningPct"] = $SsSpcAllocWarningPct
    }
	
	If ($SsSpcAllocLimitPct) {
          $body["ssSpcAllocLimitPct"] = $SsSpcAllocLimitPct
    }	
	
    # User CPG parameter
    If ($UserCPG) {
          $body["userCPG"] = "$($UserCPG)"
    }
	    

    # usrSpcAllocWarningPct parameter
    If ($UsrSpcAllocWarningPct) {
          $body["usrSpcAllocWarningPct"] = $UsrSpcAllocWarningPct
    }

    # usrSpcAllocLimitPct parameter
    If ($UsrSpcAllocLimitPct) {
          $body["usrSpcAllocLimitPct"] = $UsrSpcAllocLimitPct
    }	
	
	If ($RmSsSpcAllocWarning) {
      $body["rmSsSpcAllocWarning"] = $true
    }
	
	If ($RmUsrSpcAllocWarning) {
      $body["rmUsrSpcAllocWarning"] = $true
    } 
	
	If ($RmExpTime) {
      $body["rmExpTime"] = $true
    } 
	
	If ($RmSsSpcAllocLimit) {
      $body["rmSsSpcAllocLimit"] = $true
    }
	
	If ($RmUsrSpcAllocLimit) {
      $body["rmUsrSpcAllocLimit"] = $true
    }
	
	if($VvPolicies.Count -gt 0){$body["policies"] = $VvPolicies }
	
	#$json = $body | ConvertTo-Json  -Compress -Depth 10
	#write-host " Body = $json"
	
    #init the response var
    $Result = $null
	
	$uri = '/volumes/'+$VVName 
	
    #Request
	Write-DebugLog "Request: Request to Update-Vv_WSAPI : $VVName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Volumes:$VVName successfully Updated" $Info
				
		# Results
		if($NewName)
		{
			Get-Vv_WSAPI -VVName $NewName
		}
		else
		{
			Get-Vv_WSAPI -VVName $VVName
		}
		Write-DebugLog "End: Update-Vv_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Updating Volumes: $VVName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Updating Volumes: $VVName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Update-Vv_WSAPI

############################################################################################################################################
## FUNCTION Get-VvSpaceDistribution_WSAPI
############################################################################################################################################
Function Get-VvSpaceDistribution_WSAPI 
{
  <#
  .SYNOPSIS
	Display volume space distribution for all and for a specific virtual volumes among CPGs.
  
  .DESCRIPTION
	Display volume space distribution for all and for a specific virtual volumes among CPGs.
        
  .EXAMPLE    
	Get-VvSpaceDistribution_WSAPI
	Display volume space distribution for all virtual volumes among CPGs.
	
  .EXAMPLE    
	Get-VvSpaceDistribution_WSAPI	-VVName XYZ
	Display space distribution for a specific virtual volume or a volume set.
	
  .PARAMETER VVName 
	Either a single virtual volume name or a volume set name (start with set: to use a 	volume set name o, for example set:vvset1). 
	If you use a volume set name, the system displays the space distribution for all volumes in that volume set.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-VvSpaceDistribution_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Get-VvSpaceDistribution_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>

  [CmdletBinding()]
  Param(
	[Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Volume Name')]
    [String]$VVName,
	
	[Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
	$WsapiConnection = $global:WsapiConnection
  )
  Begin {  
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection	
  }

  Process 
  { 	
	Write-DebugLog "Request: Request fo vv Space Distributation (Invoke-WSAPI)." $Debug
    #Request    
	$Result = $null
	$dataPS = $null			
	
	#Build uri
	
	#Request
	if($VVName)
	{
		#Build uri
		$uri = '/volumespacedistribution/'+$VVName
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
		$Result = Invoke-WSAPI -uri '/volumespacedistribution' -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members 
		}			
	}
	
	If($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Get-VvSpaceDistribution_WSAPI successfully Executed." $Info
		
		return $dataPS
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-VvSpaceDistribution_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-VvSpaceDistribution_WSAPI. " $Info
		
		return $Result.StatusDescription
	}
    
  }
End {  }
}#END Get-VvSpaceDistribution_WSAPI

############################################################################################################################################
## FUNCTION Resize-Vv_WSAPI
############################################################################################################################################
Function Resize-Vv_WSAPI 
{
  <#
  .SYNOPSIS
	Increase the size of a virtual volume.
  
  .DESCRIPTION
	Increase the size of a virtual volume.
        
  .EXAMPLE    
	Resize-Vv_WSAPI -VVName xxx -SizeMiB xx
	Increase the size of a virtual volume xxx to xx.
	
  .PARAMETER VVName 
	Name of the volume to be grown.
	
  .PARAMETER SizeMiB
    Specifies the size (in MiB) to add to the volume user space. Rounded up to the next multiple of chunklet size (256 MiB or 1,000 MiB).
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Resize-Vv_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Resize-Vv_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Mandatory = $true,HelpMessage = 'Volume Name')]
      [String]$VVName,
	  
	  [Parameter(Mandatory = $true,HelpMessage = 'Specifies the size in MiB to be added to the volume user space. The size is rounded up to the next multiple of chunklet size')]
      [int]$SizeMiB,
	  
	  [Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
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
	$body["action"] = 3 # GROW_VOLUME 3 Increase the size of a virtual volume. refer Volume custom action enumeration
		
	If ($SizeMiB) 
	{
          $body["sizeMiB"] = $SizeMiB
    }
	
	#$json = $body | ConvertTo-Json  -Compress -Depth 10
	#write-host " Body = $json"
	
    #init the response var
    $Result = $null	
	$uri = '/volumes/'+$VVName 
	
    #Request
	Write-DebugLog "Request: Request to Resize-Vv_WSAPI : $VVName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Volumes:$VVName successfully Updated" $Info
				
		# Results		
		Get-Vv_WSAPI -VVName $VVName		
		Write-DebugLog "End: Resize-Vv_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Growing Volumes: $VVName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Growing Volumes: $VVName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Resize-Vv_WSAPI

############################################################################################################################################
## FUNCTION Compress-Vv_WSAPI
############################################################################################################################################
Function Compress-Vv_WSAPI 
{
  <#
  .SYNOPSIS
	Tune a volume.
  
  .DESCRIPTION
    This cmdlet (Compress-Vv_WSAPI) will be deprecated in a later version of PowerShell Toolkit. Consider using the cmdlet  (Compress-Vv_WSAPI) instead.
  
	Tune a volume.
        
  .EXAMPLE    
	Compress-Vv_WSAPI -VVName xxx -TuneOperation USR_CPG -KeepVV xxx
        
  .EXAMPLE	
	Compress-Vv_WSAPI -VVName xxx -TuneOperation USR_CPG -UserCPG xxx -KeepVV xxx
	        
  .EXAMPLE
	Compress-Vv_WSAPI -VVName xxx -TuneOperation SNP_CPG -SnapCPG xxx -KeepVV xxx
        
  .EXAMPLE	
	Compress-Vv_WSAPI -VVName xxx -TuneOperation USR_CPG -UserCPG xxx -ConversionOperation xxx -KeepVV xxx
        
  .EXAMPLE	
	Compress-Vv_WSAPI -VVName xxx -TuneOperation USR_CPG -UserCPG xxx -Compression $true -KeepVV xxx
	
  .PARAMETER VVName 
	Name of the volume to be tune.
	
  .PARAMETER TuneOperation
	Tune operation
	USR_CPG Change the user CPG of the volume.
	SNP_CPG Change the snap CPG of the volume.

  .PARAMETER UserCPG
	Specifies the new user CPG to which the volume will be tuned.
	
  .PARAMETER SnapCPG
	Specifies the snap CPG to which the volume will be tuned.
	
  .PARAMETER ConversionOperation
	TPVV  :Convert the volume to a TPVV.
	FPVV : Convert the volume to an FPVV.
	TDVV : Convert the volume to a TDVV.
	CONVERT_TO_DECO : Convert the volume to deduplicated and compressed.
	
  .PARAMETER KeepVV
	Name of the new volume where the original logical disks are saved.
	
  .PARAMETER Compression
	Enables (true) or disables (false) compression. You cannot compress a fully provisioned volume.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Compress-Vv_WSAPI   
    LASTEDIT: 17/01/2018
    KEYWORDS: Compress-Vv_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0      
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Mandatory = $true,HelpMessage = 'Volume Name')]
      [String]$VVName,
	  
	  [Parameter(Mandatory = $true,HelpMessage = 'USR_CPG is to Change the user CPG of the volume, SNP_CPG is to Change the snap CPG of the volume')]
      [string]$TuneOperation,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the new user CPG to which the volume will be tuned.')]
      [String]$UserCPG,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the snap CPG to which the volume will be tuned..')]
      [String]$SnapCPG,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'TPVV is to Convert the volume to a TPVV , FPVV is to Convert the volume to an FPVV, TDVV is to Convert the volume to a TDVV, CONVERT_TO_DECO Convert the volume to deduplicated and compressed..')]
      [string]$ConversionOperation,
	  
	  [Parameter(Mandatory = $true,HelpMessage = 'Name of the new volume where the original logical disks are saved.')]
      [String]$KeepVV,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Enables (true) or disables (false) compression')]
      [Boolean]$Compression,
	  
	  [Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
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
	
	If ($TuneOperation) 
	{	
		if($TuneOperation -eq "USR_CPG")
		{
			$body["tuneOperation"] = 1			
		}
		elseif($TuneOperation -eq "SNP_CPG")
		{
			$body["tuneOperation"] = 2			
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting  Compress-Vv_WSAPI  since -TuneOperation $TuneOperation in incorrect "
			Return "FAILURE : -TuneOperation :- $TuneOperation is an Incorrect used USR_CPG and SNP_CPG only. " 
		}          
    }
	
	If ($UserCPG) 
	{
		$body["userCPG"] = "$($UserCPG)"
    }
	else
	{
		If ($TuneOperation -eq "USR_CPG") 
		{
			return "Stop Executing Compress-Vv_WSAPI, UserCPG is Required with TuneOperation 1"
		}
	}
	If ($SnapCPG) 
	{
		$body["snapCPG"] = "$($SnapCPG)"
    }
	else
	{
		If ($TuneOperation -eq "SNP_CPG") 
		{
			return "Stop Executing Compress-Vv_WSAPI, SnapCPG is Required with TuneOperation 1"
		}
	}
	If ($ConversionOperation) 
	{	
		if($ConversionOperation -eq "TPVV")
		{
			$body["conversionOperation"] = 1			
		}
		elseif($ConversionOperation -eq "FPVV")
		{
			$body["conversionOperation"] = 2			
		}
		elseif($ConversionOperation -eq "TDVV")
		{
			$body["conversionOperation"] = 3			
		}
		elseif($ConversionOperation -eq "CONVERT_TO_DECO")
		{
			$body["conversionOperation"] = 4			
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting  Compress-Vv_WSAPI   since -ConversionOperation $ConversionOperation in incorrect "
			Return "FAILURE : -ConversionOperation :- $ConversionOperation is an Incorrect used TPVV,FPVV,TDVV or CONVERT_TO_DECO only. "
		}          
    }
	If ($KeepVV) 
	{
		$body["keepVV"] = "$($KeepVV)"
    }
	If ($Compression) 
	{
		$body["compression"] = $false
    } 
	
	#$json = $body | ConvertTo-Json  -Compress -Depth 10
	#write-host " Body = $json"
	
    #init the response var
    $Result = $null	
	$uri = '/volumes/'+$VVName 
	
    #Request
	Write-DebugLog "Request: Request to Compress-Vv_WSAPI : $VVName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Volumes:$VVName successfully Tune" $Info
				
		# Results		
		Get-Vv_WSAPI -VVName $VVName		
		Write-DebugLog "End: Compress-Vv_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Tuning Volumes: $VVName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Tuning Volumes: $VVName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Compress-Vv_WSAPI

############################################################################################################################################
## FUNCTION Get-Vv_WSAPI
############################################################################################################################################
Function Get-Vv_WSAPI 
{
  <#
  .SYNOPSIS
	Get Single or list of virtual volumes.
  
  .DESCRIPTION
	Get Single or list of virtual volumes.
        
  .EXAMPLE
	Get-Vv_WSAPI
	Get the list of virtual volumes
	
  .EXAMPLE
	Get-Vv_WSAPI -VVName MyVV
	Get the detail of given VV	
	
  .EXAMPLE
	Get-Vv_WSAPI -WWN XYZ
	Querying volumes with single WWN
	
  .EXAMPLE
	Get-Vv_WSAPI -WWN "XYZ,XYZ1,XYZ2,XYZ3"
	Querying volumes with multiple WWNs
	
  .EXAMPLE
	Get-Vv_WSAPI -WWN "XYZ,XYZ1,XYZ2,XYZ3" -UserCPG ABC 
	Querying volumes with multiple filters
	
  .EXAMPLE
	Get-Vv_WSAPI -WWN "XYZ" -SnapCPG ABC 
	Querying volumes with multiple filters
	
  .EXAMPLE
	Get-Vv_WSAPI -WWN "XYZ" -CopyOf MyVV 
	Querying volumes with multiple filters
	
  .EXAMPLE
	Get-Vv_WSAPI -ProvisioningType FULL  
	Querying volumes with Provisioning Type FULL
	
  .EXAMPLE
	Get-Vv_WSAPI -ProvisioningType TPVV  
	Querying volumes with Provisioning Type TPVV
	
  .PARAMETER VVName
	Specify name of the volume.
	
  .PARAMETER WWN
	Querying volumes with Single or multiple WWNs
	
  .PARAMETER UserCPG
	User CPG Name
	
  .PARAMETER SnapCPG
	Snp CPG Name 
	
  .PARAMETER CopyOf
	Querying volume copies it required name of the vv to copy
	
  .PARAMETER ProvisioningType
	Querying volume with Provisioning Type
	FULL : 	• FPVV, with no snapshot space or with statically allocated snapshot space.
			• A commonly provisioned VV with fully provisioned user space and snapshot space associated with the snapCPG property.
	TPVV : 	• TPVV, with base volume space allocated from the user space associated with the userCPG property.
			• Old-style, thinly provisioned VV (created on a 2.2.4 release or earlier).
			Both the base VV and snapshot data are allocated from the snapshot space associated with userCPG.
	SNP : 	The VV is a snapshot (Type vcopy) with space provisioned from the base volume snapshot space.
	PEER : 	Remote volume admitted into the local storage system.
	UNKNOWN : Unknown. 
	TDVV : 	The volume is a deduplicated volume.
	DDS : 	A system maintained deduplication storage volume shared by TDVV volumes in a CPG.
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Get-Vv_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Get-Vv_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VVName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $WWN,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $UserCPG,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $SnapCPG,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $CopyOf,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	  [System.String]
	  $ProvisioningType,

	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection	 
  }

  Process 
  {
	Write-DebugLog "Request: Request to Get-Vv_WSAPI VVName : $VVName (Invoke-WSAPI)." $Debug
    #Request
    
	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """	
	
	# Results
	if($VVName)
	{
		#Build uri
		$uri = '/volumes/'+$VVName
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}		
		If($Result.StatusCode -eq 200)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-Vv_WSAPI successfully Executed." $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-Vv_WSAPI." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-Vv_WSAPI. " $Info
			
			return $Result.StatusDescription
		}
	}	
	if($WWN)
	{		
		$count = 1
		$lista = $WWN.split(",")
		foreach($sub in $lista)
		{			
			$Query = $Query.Insert($Query.Length-3," wwn EQ $sub")			
			if($lista.Count -gt 1)
			{
				if($lista.Count -ne $count)
				{
					$Query = $Query.Insert($Query.Length-3," OR ")
					$count = $count + 1
				}				
			}
		}		
	}
	if($UserCPG)
	{
		if($WWN)
		{
			$Query = $Query.Insert($Query.Length-3," OR userCPG EQ $UserCPG")
		}
		else
		{
			$Query = $Query.Insert($Query.Length-3," userCPG EQ $UserCPG")
		}
	}
	if($SnapCPG)
	{
		if($WWN -or $UserCPG)
		{
			$Query = $Query.Insert($Query.Length-3," OR snapCPG EQ $SnapCPG")
		}
		else
		{
			$Query = $Query.Insert($Query.Length-3," snapCPG EQ $SnapCPG")
		}
	}
	if($CopyOf)
	{
		if($WWN -Or $UserCPG -Or $SnapCPG)
		{
			$Query = $Query.Insert($Query.Length-3," OR copyOf EQ $CopyOf")
		}
		else
		{
			$Query = $Query.Insert($Query.Length-3," copyOf EQ $CopyOf")
		}
	}
	
	if($ProvisioningType)
	{
		$PEnum
		
		$a = "FULL","TPVV","SNP","PEER","UNKNOWN","TDVV","DDS"
		$l=$ProvisioningType.ToUpper()
		if($a -eq $l)
		{
			if($ProvisioningType -eq "FULL")
			{
				$PEnum = 1
			}
			if($ProvisioningType -eq "TPVV")
			{
				$PEnum = 2
			}
			if($ProvisioningType -eq "SNP")
			{
				$PEnum = 3
			}
			if($ProvisioningType -eq "PEER")
			{
				$PEnum = 4
			}
			if($ProvisioningType -eq "UNKNOWN")
			{
				$PEnum = 5
			}
			if($ProvisioningType -eq "TDVV")
			{
				$PEnum = 6
			}
			if($ProvisioningType -eq "DDS")
			{
				$PEnum = 7
			}
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Get-Vv_WSAPI Since -ProvisioningType $ProvisioningType in incorrect "
			Return "FAILURE : -ProvisioningType :- $ProvisioningType is an Incorrect Provisioning Type [FULL | TPVV | SNP | PEER | UNKNOWN | TDVV | DDS]  can be used only . "
		}			
		
		if($WWN -Or $UserCPG -Or $SnapCPG -Or $CopyOf)
		{
			$Query = $Query.Insert($Query.Length-3," OR provisioningType EQ $PEnum")
		}
		else
		{
			$Query = $Query.Insert($Query.Length-3," provisioningType EQ $PEnum")
		}
	}
	
	if($WWN -Or $UserCPG -Or $SnapCPG -Or $CopyOf -Or $ProvisioningType)
	{
		#Build uri
		$uri = '/volumes/'+$Query		
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{			
			$dataPS = ($Result.content | ConvertFrom-Json).members			
		}
	}
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/volumes' -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{			
			$dataPS = ($Result.content | ConvertFrom-Json).members			
		}		
	}

	If($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-Vv_WSAPI successfully Executed." $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-Vv_WSAPI. Expected Result Not Found with Given Filter Option : UserCPG/$UserCPG | WWN/$WWN | SnapCPG/$SnapCPG | CopyOf/$CopyOf | ProvisioningType/$ProvisioningType." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-Vv_WSAPI. Expected Result Not Found with Given Filter Option : UserCPG/$UserCPG | WWN/$WWN | SnapCPG/$SnapCPG | CopyOf/$CopyOf | ProvisioningType/$ProvisioningType." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-Vv_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-Vv_WSAPI. " $Info
		
		return $Result.StatusDescription
	}
  }
	End {}
}#END Get-Vv_WSAPI

############################################################################################################################################
## FUNCTION Remove-Vv_WSAPI
############################################################################################################################################
Function Remove-Vv_WSAPI
 {
  <#
  .SYNOPSIS
	Delete virtual volumes
  
  .DESCRIPTION
	Delete virtual volumes
        
  .EXAMPLE    
	Remove-Vv_WSAPI -VVName MyVV
	
  .PARAMETER VVName 
	Specify name of the volume to be removed

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Remove-Vv_WSAPI     
    LASTEDIT: February 2020 
    KEYWORDS: Remove-Vv_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0	
  #>
  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specifies the name of Volume.')]
	[String]$VVName,
	
	[Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
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
	Write-DebugLog "Running: Building uri to Remove-Vv_WSAPI." $Debug
	$uri = '/volumes/'+$VVName

	#init the response var
	$Result = $null

	#Request
	Write-DebugLog "Request: Request to Remove-Vv_WSAPI : $VVName (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Volumes:$VVName successfully remove" $Info
		Write-DebugLog "End: Remove-Vv_WSAPI" $Debug
		
		return ""
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Removing Volume:$VVName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating Volume:$VVName " $Info
		Write-DebugLog "End: Remove-Vv_WSAPI" $Debug
		
		return $Result.StatusDescription
	}    
	
  }
  End {}  
}
#END Remove-Vv_WSAPI

Export-ModuleMember New-Vv_WSAPI , Update-Vv_WSAPI , Get-VvSpaceDistribution_WSAPI , Resize-Vv_WSAPI , Compress-Vv_WSAPI , Remove-Vv_WSAPI , Get-Vv_WSAPI
# SIG # Begin signature block
# MIIhEQYJKoZIhvcNAQcCoIIhAjCCIP4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAzED5DDIiNY/pE
# R9REGrDDvuircMEuCYDxEBj8Y6uJYqCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPvDCCD7gCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# vgRobNgv6N94CzHVwCqaGRkbyGZXcpj+jzztr7l6v5QwDQYJKoZIhvcNAQEBBQAE
# ggEAvWA5u/8YchaLuhtTcxJ9hKEjT8L9VDfREE6aIEf5nDU8l+MemAKoKohTinyX
# CaQL2blieMpI2RVPFI4wt92qTpCUDNvKnCHpy0jjeCNB7BcBHdBI2I/yluXjW4ck
# +93rZe5Q5cUMpRXY+qXbaCHXSDNnfm+0lDiAhNK8TgYnlWW1BOWNZz3mo3NqxCM+
# 64ZiCWGNIxFVaRgzHs7s+xvD8M9P+CUFaW7BlyRiGya/QWTWllVx3iPZ4BAncE9C
# gnF+HxAMTQfiz3MGK9ADS/0eKkh5vBJOAac5xnRqgUaS+F/7dc0VDYWw4JSStpcF
# KF1ybos1it57qOIitBjQw2zmw6GCDX4wgg16BgorBgEEAYI3AwMBMYINajCCDWYG
# CSqGSIb3DQEHAqCCDVcwgg1TAgEDMQ8wDQYJYIZIAWUDBAIBBQAweAYLKoZIhvcN
# AQkQAQSgaQRnMGUCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCAQVL1J
# uL8sG5tAc1zeWABjrJXuKcdEWUADi3GOwHtjrgIRAN72H5nbU9hycVdC8luCa20Y
# DzIwMjEwNjE5MDUyMzI5WqCCCjcwggT+MIID5qADAgECAhANQkrgvjqI/2BAIc4U
# APDdMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERp
# Z2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwHhcNMjEwMTAx
# MDAwMDAwWhcNMzEwMTA2MDAwMDAwWjBIMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIx
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwuZhhGfFivUNCKRFymNr
# Udc6EUK9CnV1TZS0DFC1JhD+HchvkWsMlucaXEjvROW/m2HNFZFiWrj/ZwucY/02
# aoH6KfjdK3CF3gIY83htvH35x20JPb5qdofpir34hF0edsnkxnZ2OlPR0dNaNo/G
# o+EvGzq3YdZz7E5tM4p8XUUtS7FQ5kE6N1aG3JMjjfdQJehk5t3Tjy9XtYcg6w6O
# LNUj2vRNeEbjA4MxKUpcDDGKSoyIxfcwWvkUrxVfbENJCf0mI1P2jWPoGqtbsR0w
# wptpgrTb/FZUvB+hh6u+elsKIC9LCcmVp42y+tZji06lchzun3oBc/gZ1v4NSYS9
# AQIDAQABo4IBuDCCAbQwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwQQYDVR0gBDowODA2BglghkgBhv1sBwEwKTAn
# BggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMB8GA1UdIwQY
# MBaAFPS24SAd/imu0uRhpbKiJbLIFzVuMB0GA1UdDgQWBBQ2RIaOpLqwZr68KC0d
# RDbd42p6vDBxBgNVHR8EajBoMDKgMKAuhixodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vc2hhMi1hc3N1cmVkLXRzLmNybDAyoDCgLoYsaHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmwwgYUGCCsGAQUFBwEBBHkwdzAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME8GCCsGAQUFBzAChkNo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNzdXJlZElE
# VGltZXN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IBAQBIHNy16ZojvOca
# 5yAOjmdG/UJyUXQKI0ejq5LSJcRwWb4UoOUngaVNFBUZB3nw0QTDhtk7vf5EAmZN
# 7WmkD/a4cM9i6PVRSnh5Nnont/PnUp+Tp+1DnnvntN1BIon7h6JGA0789P63ZHdj
# XyNSaYOC+hpT7ZDMjaEXcw3082U5cEvznNZ6e9oMvD0y0BvL9WH8dQgAdryBDvjA
# 4VzPxBFy5xtkSdgimnUVQvUtMjiB2vRgorq0Uvtc4GEkJU+y38kpqHNDUdq9Y9Yf
# W5v3LhtPEx33Sg1xfpe39D+E68Hjo0mh+s6nv1bPull2YYlffqe0jmd4+TaY4cso
# 2luHpoovMIIFMTCCBBmgAwIBAgIQCqEl1tYyG35B5AXaNpfCFTANBgkqhkiG9w0B
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTYwMTA3MTIwMDAwWhcNMzEwMTA3MTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# VGltZXN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# vdAy7kvNj3/dqbqCmcU5VChXtiNKxA4HRTNREH3Q+X1NaH7ntqD0jbOI5Je/YyGQ
# mL8TvFfTw+F+CNZqFAA49y4eO+7MpvYyWf5fZT/gm+vjRkcGGlV+Cyd+wKL1oODe
# Ij8O/36V+/OjuiI+GKwR5PCZA207hXwJ0+5dyJoLVOOoCXFr4M8iEA91z3FyTgqt
# 30A6XLdR4aF5FMZNJCMwXbzsPGBqrC8HzP3w6kfZiFBe/WZuVmEnKYmEUeaC50ZQ
# /ZQqLKfkdT66mA+Ef58xFNat1fJky3seBdCEGXIX8RcG7z3N1k3vBkL9olMqT4Ud
# xB08r8/arBD13ays6Vb/kwIDAQABo4IBzjCCAcowHQYDVR0OBBYEFPS24SAd/imu
# 0uRhpbKiJbLIFzVuMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMBIG
# A1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqg
# OKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMFAGA1UdIARJMEcwOAYKYIZIAYb9bAACBDAq
# MCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAsGCWCG
# SAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAQEAcZUS6VGHVmnN793afKpjerN4zwY3
# QITvS4S/ys8DAv3Fp8MOIEIsr3fzKx8MIVoqtwU0HWqumfgnoma/Capg33akOpMP
# +LLR2HwZYuhegiUexLoceywh4tZbLBQ1QwRostt1AuByx5jWPGTlH0gQGF+JOGFN
# YkYkh2OMkVIsrymJ5Xgf1gsUpYDXEkdws3XVk4WTfraSZ/tTYYmo9WuWwPRYaQ18
# yAGxuSh1t5ljhSKMYcp5lH5Z/IwP42+1ASa2bKXuh1Eh5Fhgm7oMLSttosR+u8Ql
# K0cCCHxJrhO24XxCQijGGFbPQTS2Zl22dHv1VjMiLyI2skuiSpXY9aaOUjGCAoYw
# ggKCAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0ECEA1CSuC+Ooj/YEAhzhQA8N0w
# DQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwG
# CSqGSIb3DQEJBTEPFw0yMTA2MTkwNTIzMjlaMCsGCyqGSIb3DQEJEAIMMRwwGjAY
# MBYEFOHXgqjhkb7va8oWkbWqtJSmJJvzMC8GCSqGSIb3DQEJBDEiBCAYDKrd5Yeg
# BNty7dMjO+nObVKdGAPimDU8vk5d+z7WPTA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCCzEJAGvArZgweRVyngRANBXIPjKSthTyaWTI01cez1qTANBgkqhkiG9w0BAQEF
# AASCAQCsMtb9/MDff2uAkS+apopb+ifCosLiWjVaJWHj726i438oFIx2C/smP/uu
# XopuecVP6OLSnkuBFVohXQWukNm73RPQV/jP7DwYLoNYETwXWspySCAPN1IAroqN
# SVHB/iAdswNrPs6yXN6E4BKZn6uyuvQK0FRTnH1O9KvpJ9Qwfje2V7YQJgvop9Zn
# dSta67fN2ehQ8DKkB1TPR57mfzyrTgNKetZX4l3XmBX2QAgUJN4YaoM2Azkj5W+M
# aLiMNLaB7QicH6Rf+Y4/2KdcMjPr1xCswdGqPDdXogqLVFMEhyIgNVqhC43nRoFF
# jjXTHeZ8vsfKhalL9CsuDvBeQFU9
# SIG # End signature block
