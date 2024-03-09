####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function New-a9Vv 
{
<#      
.SYNOPSIS
	Creates a vitual volume
.DESCRIPTION
    This cmdlet (New-Vv_WSAPI) will be deprecated in a later version of PowerShell Toolkit. Consider using the cmdlet  (New-Vv_WSAPI) instead.
	Creates a vitual volume
.EXAMPLE    
	PS:> New-a9Vv -VVName xxx -CpgName xxx -SizeMiB 1
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -Id 1010
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -Comment "This is test vv"
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -OneHost $true
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -Caching $true
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -HostDIF NO_HOST_DIF
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
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
										[String]	$VVName,
		[Parameter(Mandatory = $true)]	[String]	$CpgName,
		[Parameter(Mandatory = $true)]	[int]		$SizeMiB,
		[Parameter()]					[int]		$Id,
		[Parameter()]					[String]	$Comment,
		[Parameter()]					[Boolean]	$StaleSS ,
		[Parameter()]					[Boolean]	$OneHost,
		[Parameter()]					[Boolean]	$ZeroDetect,
		[Parameter()]					[Boolean]	$System ,
		[Parameter()]					[Boolean]	$Caching ,
		[Parameter()]					[Boolean]	$Fsvc ,
		[Parameter()]	[ValidateSet('3PAR_HOST_DIF','STD+HOST_DIF','NO_HOST_DIF')]
										[string]	$HostDIF ,
		[Parameter()]					[String]	$SnapCPG,
		[Parameter()]					[int]		$SsSpcAllocWarningPct ,
		[Parameter()]					[int]		$SsSpcAllocLimitPct ,
		[Parameter()]					[Boolean]	$TPVV = $false,
		[Parameter()]					[Boolean]	$TDVV = $false,
		[Parameter()]					[Boolean]	$Reduce = $false,
		[Parameter()]					[int]		$UsrSpcAllocWarningPct,
		[Parameter()]					[int]		$UsrSpcAllocLimitPct,
		[Parameter()]					[int]		$ExpirationHours,
		[Parameter()]					[int]		$RetentionHours,
		[Parameter()]					[Boolean]	$Compression = $false
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$body["name"] = "$($VVName)"
	If ($CpgName) 	{	$body["cpg"] = "$($CpgName)" }
    If ($SizeMiB) 	{	$body["sizeMiB"] = $SizeMiB  }
    If ($Id) 		{	$body["id"] = $Id }
	$VvPolicies = @{}
	If ($StaleSS) 	{	$VvPolicies["staleSS"] = $true	}	
	If ($OneHost) 	{	$VvPolicies["oneHost"] = $true    } 
	If ($ZeroDetect){	$VvPolicies["zeroDetect"] = $true    }	
	If ($System) 	{	$VvPolicies["system"] = $true    }
	If ($Caching) 	{	$VvPolicies["caching"] = $true    }	
	If ($Fsvc) 		{	$VvPolicies["fsvc"] = $true    }	
	If ($HostDIF) 	
		{	if($HostDIF -eq "3PAR_HOST_DIF")	{	$VvPolicies["hostDIF"] = 1	}
			elseif($HostDIF -eq "STD_HOST_DIF")	{	$VvPolicies["hostDIF"] = 2	}
			elseif($HostDIF -eq "NO_HOST_DIF")	{	$VvPolicies["hostDIF"] = 3	}
		} 	
    If ($Comment) 	{	$body["comment"] = "$($Comment)"}
	If ($SnapCPG) 	{	$body["snapCPG"] = "$($SnapCPG)" }
	If ($SsSpcAllocWarningPct) 	{	$body["ssSpcAllocWarningPct"] = $SsSpcAllocWarningPct }
	If ($SsSpcAllocLimitPct) {	$body["ssSpcAllocLimitPct"] = $SsSpcAllocLimitPct }
    If ($TPVV) 		{	$body["tpvv"] = $true	}
	If ($TDVV) 		{	$body["tdvv"] = $true	}
	If($Reduce) 	{	$body["reduce"] = $true }
    If ($UsrSpcAllocWarningPct) {	$body["usrSpcAllocWarningPct"] = $UsrSpcAllocWarningPct }
	If ($UsrSpcAllocLimitPct) 	{	$body["usrSpcAllocLimitPct"] = $UsrSpcAllocLimitPct } 
	If ($ExpirationHours) 		{ 	$body["expirationHours"] = $ExpirationHours	}
	If ($RetentionHours) 		{	$body["retentionHours"] = $RetentionHours	}
	If ($Compression) 			{ 	$body["compression"] = $true }
	if($VvPolicies.Count -gt 0){$body["policies"] = $VvPolicies }
	$Result = $null
    $Result = Invoke-WSAPI -uri '/volumes' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return Get-A9Vv -VVName $VVName
		}
	else
		{	Write-Error "Failure:  While creating Volumes: $VVName " 
			return $Result.StatusDescription
		}
}
}

Function Update-A9Vv
{
<#
.SYNOPSIS
	Update a vitual volume.
.DESCRIPTION
	Update an existing vitual volume.
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -NewName zzz
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -ExpirationHours 2
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -OneHost $true
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -SnapCPG xxx
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
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
					[String]	$VVName,
	[Parameter()]	[String]	$NewName,
	[Parameter()]	[String]	$Comment,
	[Parameter()]	[String]	$WWN,
	[Parameter()]	[int]		$ExpirationHours,
	[Parameter()]	[int]		$RetentionHours,
	[Parameter()]	[boolean]	$StaleSS ,
	[Parameter()]	[boolean]	$OneHost,
	[Parameter()]	[boolean]	$ZeroDetect,
	[Parameter()]	[boolean]	$System ,
	[Parameter()]	[boolean]	$Caching ,
	[Parameter()]	[boolean]	$Fsvc ,
	[Parameter()]	[ValidateSet('3PAR_HOST_DIF','STD_HOST_DIF','NO_HOST_DIF')]
					[string]	$HostDIF ,
	[Parameter()]	[String]	$SnapCPG,
	[Parameter()]	[int]		$SsSpcAllocWarningPct ,
	[Parameter()]	[int]		$SsSpcAllocLimitPct ,
	[Parameter()]	[String]	$UserCPG,
	[Parameter()]	[int]		$UsrSpcAllocWarningPct,
	[Parameter()]	[int]		$UsrSpcAllocLimitPct,
	[Parameter()]	[Boolean]	$RmSsSpcAllocWarning ,
	[Parameter()]	[Boolean]	$RmUsrSpcAllocWarning ,
	[Parameter()]	[Boolean]	$RmExpTime,
	[Parameter()]	[Boolean]	$RmSsSpcAllocLimit,
	[Parameter()]	[Boolean]	$RmUsrSpcAllocLimit
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}
    If ($NewName) 			{ 	$body["newName"] 	= "$($NewName)" }
    If ($Comment) 			{  	$body["comment"] 	= "$($Comment)" }
	If ($WWN) 				{ 	$body["WWN"] 		= "$($WWN)"		}
	If ($ExpirationHours) 	{ 	$body["expirationHours"] = $ExpirationHours}
	If ($RetentionHours) 	{	$body["retentionHours"] = $RetentionHours}
	$VvPolicies = @{}
	If ($StaleSS) 			{	$VvPolicies["staleSS"] 	= $true		}
	If ($StaleSS -eq $false){	$VvPolicies["staleSS"] 	= $false    }	
	If ($OneHost) 			{	$VvPolicies["oneHost"] 	= $true    	}
	If ($OneHost -eq $false){	$VvPolicies["oneHost"] 	= $false   	}
	If ($ZeroDetect) 		{	$VvPolicies["zeroDetect"]=$true		}	
	If ($ZeroDetect -eq $false){$VvPolicies["zeroDetect"]=$false 	}
	If ($System) 			{	$VvPolicies["system"] 	= $true    	} 
	If ($System -eq $false) {	$VvPolicies["system"] 	= $false    }
	If ($Caching) 			{	$VvPolicies["caching"] 	= $true    	}	
	If ($Caching -eq $false){	$VvPolicies["caching"] 	= $false    }
	If ($Fsvc) 				{	$VvPolicies["fsvc"] 	= $true    	}
	If ($Fsvc -eq $false) 	{	$VvPolicies["fsvc"] 	= $false	}
	If ($HostDIF) 
		{	if($HostDIF -eq "3PAR_HOST_DIF")	{	$VvPolicies["hostDIF"] = 1	}
			elseif($HostDIF -eq "STD_HOST_DIF")	{	$VvPolicies["hostDIF"] = 2	}
			elseif($HostDIF -eq "NO_HOST_DIF")	{	$VvPolicies["hostDIF"] = 3	}
		} 	   
	If ($SnapCPG) 				{ 	$body["snapCPG"] 				= "$($SnapCPG)" 		}
	If ($SsSpcAllocWarningPct) 	{ 	$body["ssSpcAllocWarningPct"] 	= $SsSpcAllocWarningPct }
	If ($SsSpcAllocLimitPct) 	{  	$body["ssSpcAllocLimitPct"] 	= $SsSpcAllocLimitPct 	}	
    If ($UserCPG) 				{	$body["userCPG"] 				= "$($UserCPG)"			}
    If ($UsrSpcAllocWarningPct) {	$body["usrSpcAllocWarningPct"] 	= $UsrSpcAllocWarningPct }
    If ($UsrSpcAllocLimitPct) 	{	$body["usrSpcAllocLimitPct"] 	= $UsrSpcAllocLimitPct	}	
	If ($RmSsSpcAllocWarning) 	{	$body["rmSsSpcAllocWarning"] 	= $true    				}
	If ($RmUsrSpcAllocWarning) 	{	$body["rmUsrSpcAllocWarning"] 	= $true					} 
	If ($RmExpTime) 			{	$body["rmExpTime"] 				= $true 				} 
	If ($RmSsSpcAllocLimit) 	{	$body["rmSsSpcAllocLimit"] 		= $true 				}
	If ($RmUsrSpcAllocLimit) 	{	$body["rmUsrSpcAllocLimit"] 	= $true 				}
	if($VvPolicies.Count -gt 0)	{	$body["policies"] 				= $VvPolicies 			}
	$Result = $null
	$uri = '/volumes/'+$VVName 
	$Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)	{	return Get-Vv_WSAPI -VVName $NewName	}
			else			{	return Get-Vv_WSAPI -VVName $VVName		}
		}
	else
		{	Write-Error "Failure:  While Updating Volumes: $VVName " 
			return $Result.StatusDescription
		}
}
}

Function Get-A9VvSpaceDistribution
{
<#
.SYNOPSIS
	Display volume space distribution for all and for a specific virtual volumes among CPGs.
.DESCRIPTION
	Display volume space distribution for all and for a specific virtual volumes among CPGs.
.EXAMPLE    
	Get-A9VvSpaceDistribution
	Display volume space distribution for all virtual volumes among CPGs.
.EXAMPLE    
	PS:> Get-A9VvSpaceDistribution	-VVName XYZ
	Display space distribution for a specific virtual volume or a volume set.
.PARAMETER VVName 
	Either a single virtual volume name or a volume set name (start with set: to use a 	volume set name o, for example set:vvset1). 
	If you use a volume set name, the system displays the space distribution for all volumes in that volume set.
#>
[CmdletBinding()]
Param(
	[Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [String]$VVName
)
Begin 
{	Test-WSAPIConnection	
}
Process 
{	$Result = $null
	$dataPS = $null			
	if($VVName)
	{	$uri = '/volumespacedistribution/'+$VVName
		$Result = Invoke-WSAPI -uri $uri -type 'GET' 
		if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
		}
	}
	else
	{	$Result = Invoke-WSAPI -uri '/volumespacedistribution' -type 'GET' 
		if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members 
		}			
	}
	If($Result.StatusCode -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return $dataPS
	}
	else
	{	Write-Error "Failure:  While Executing Get-A9VvSpaceDistribution." 
		return $Result.StatusDescription
	}
    
}
}

Function Resize-a9Vv 
{
<#
.SYNOPSIS
	Increase the size of a virtual volume.
.DESCRIPTION
	Increase the size of a virtual volume.
.EXAMPLE    
	PS:> Resize-A9Vv -VVName xxx -SizeMiB xx

	Increase the size of a virtual volume xxx to xx.
.PARAMETER VVName 
	Name of the volume to be grown.
.PARAMETER SizeMiB
    Specifies the size (in MiB) to add to the volume user space. Rounded up to the next multiple of chunklet size (256 MiB or 1,000 MiB).
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]	[String]	$VVName,
		[Parameter(Mandatory = $true)]	[int]		$SizeMiB
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}
	$body["action"] = 3 # GROW_VOLUME 3 Increase the size of a virtual volume. refer Volume custom action enumeration
	If ($SizeMiB)	{	$body["sizeMiB"] = $SizeMiB }
    $Result = $null	
	$uri = '/volumes/'+$VVName 
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return Get-Vv_WSAPI -VVName $VVName		
	}
	else
	{	Write-Error "Failure:  While Growing Volumes: $VVName " 
		return $Result.StatusDescription
	}
}
}

Function Compress-A9Vv
{
<#
.SYNOPSIS
	Tune a volume.
.DESCRIPTION
    This cmdlet (Compress-Vv_WSAPI) will be deprecated in a later version of PowerShell Toolkit. Consider using the cmdlet  (Compress-Vv_WSAPI) instead.
	Tune a volume.
.EXAMPLE    
	PS:> Compress-A9Vv -VVName xxx -TuneOperation USR_CPG -KeepVV xxx
.EXAMPLE	
	PS:> Compress-A9Vv -VVName xxx -TuneOperation USR_CPG -UserCPG xxx -KeepVV xxx
.EXAMPLE
	PS:> Compress-A9Vv -VVName xxx -TuneOperation SNP_CPG -SnapCPG xxx -KeepVV xxx
.EXAMPLE	
	PS:> Compress-A9Vv -VVName xxx -TuneOperation USR_CPG -UserCPG xxx -ConversionOperation xxx -KeepVV xxx
.EXAMPLE	
	PS:> Compress-A9Vv -VVName xxx -TuneOperation USR_CPG -UserCPG xxx -Compression $true -KeepVV xxx
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
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]	[String]$VVName,
		[Parameter(Mandatory = $true)]	[string]	$TuneOperation,
		[Parameter()]					[String]	$UserCPG,
		[Parameter()]					[String]	$SnapCPG,
		[Parameter()]					[string]	$ConversionOperation,
		[Parameter(Mandatory = $true)]	[String]	$KeepVV,
		[Parameter()]					[Boolean]	$Compression
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{} 	
	$body["action"] = 6	
	If ($TuneOperation) 
		{	if($TuneOperation -eq "USR_CPG")	{	$body["tuneOperation"] = 1	}
			elseif($TuneOperation -eq "SNP_CPG"){	$body["tuneOperation"] = 2	}
			else{ 	write-error "FAILURE : -TuneOperation :- $TuneOperation is an Incorrect used USR_CPG and SNP_CPG only. "
					Return  
				}          
		}
	If ($UserCPG) 	{	$body["userCPG"] = "$($UserCPG)" }
	else	{	If ($TuneOperation -eq "USR_CPG") 	
					{	write-error "Stop Executing Compress-A9Vv, UserCPG is Required with TuneOperation 1" 
						return 
					}
			}
	If ($SnapCPG) {	$body["snapCPG"] = "$($SnapCPG)" }
	else{	If ($TuneOperation -eq "SNP_CPG") 
				{	return "Stop Executing Compress-Vv_WSAPI, SnapCPG is Required with TuneOperation 1"
				}
		}
	If ($ConversionOperation) 
		{	if($ConversionOperation -eq "TPVV")		{	$body["conversionOperation"] = 1	}
			elseif($ConversionOperation -eq "FPVV")	{	$body["conversionOperation"] = 2	}
			elseif($ConversionOperation -eq "TDVV")	{	$body["conversionOperation"] = 3	}
			elseif($ConversionOperation -eq "CONVERT_TO_DECO")	{	$body["conversionOperation"] = 4	}
			else	{	Return "FAILURE : -ConversionOperation :- $ConversionOperation is an Incorrect used TPVV,FPVV,TDVV or CONVERT_TO_DECO only. "	}          
		}
	If ($KeepVV) 		{	$body["keepVV"] = "$($KeepVV)"    }
	If ($Compression) 	{	$body["compression"] = $false    } 
    $Result = $null	
	$uri = '/volumes/'+$VVName 
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			Get-Vv_WSAPI -VVName $VVName		
		}
	else
		{	Write-Error "Failure:  While Tuning Volumes: $VVName " 
			return $Result.StatusDescription
		}
}
}

Function Get-A9Vv 
{
<#
.SYNOPSIS
	Get Single or list of virtual volumes.
.DESCRIPTION
	Get Single or list of virtual volumes.
.EXAMPLE
	PS:> Get-A9Vv
	Get the list of virtual volumes
.EXAMPLE
	PS:> Get-A9Vv -VVName MyVV
	Get the detail of given VV	
.EXAMPLE
	PS:> Get-A9Vv -WWN XYZ
	Querying volumes with single WWN
.EXAMPLE
	PS:> Get-A9Vv -WWN "XYZ,XYZ1,XYZ2,XYZ3"
	Querying volumes with multiple WWNs
.EXAMPLE
	PS:> Get-A9Vv -WWN "XYZ,XYZ1,XYZ2,XYZ3" -UserCPG ABC 
	Querying volumes with multiple filters
.EXAMPLE
	PS:> Get-A9Vv -WWN "XYZ" -SnapCPG ABC 
	Querying volumes with multiple filters
.EXAMPLE
	PS:> Get-A9Vv -WWN "XYZ" -CopyOf MyVV 
	Querying volumes with multiple filters
.EXAMPLE
	PS:> Get-A9Vv -ProvisioningType FULL  
	Querying volumes with Provisioning Type FULL
.EXAMPLE
	PS:> Get-A9Vv -ProvisioningType TPVV  
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$VVName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$WWN,
		[Parameter(ValueFromPipeline=$true)]	[String]	$UserCPG,
		[Parameter(ValueFromPipeline=$true)]	[String]	$SnapCPG,
		[Parameter(ValueFromPipeline=$true)]	[String]	$CopyOf,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ProvisioningType
)
Begin 
{	Test-WSAPIConnection	 
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """	
	if($VVName)
		{	$uri = '/volumes/'+$VVName
			$Result = Invoke-WSAPI -uri $uri -type 'GET' 
			If($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}		
			If($Result.StatusCode -eq 200)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-A9Vv." 
					return $Result.StatusDescription
				}
		}	
	if($WWN)
		{	$count = 1
			$lista = $WWN.split(",")
			foreach($sub in $lista)
				{	$Query = $Query.Insert($Query.Length-3," wwn EQ $sub")			
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$Query = $Query.Insert($Query.Length-3," OR ")
									$count = $count + 1
								}				
						}
				}		
		}
	if($UserCPG)
		{	if($WWN)	{	$Query = $Query.Insert($Query.Length-3," OR userCPG EQ $UserCPG")	}
			else		{	$Query = $Query.Insert($Query.Length-3," userCPG EQ $UserCPG")		}
		}
	if($SnapCPG)
		{	if($WWN -or $UserCPG)	{	$Query = $Query.Insert($Query.Length-3," OR snapCPG EQ $SnapCPG")	}
			else					{	$Query = $Query.Insert($Query.Length-3," snapCPG EQ $SnapCPG")		}
		}
	if($CopyOf)
		{	if($WWN -Or $UserCPG -Or $SnapCPG)	{	$Query = $Query.Insert($Query.Length-3," OR copyOf EQ $CopyOf")	}
			else								{	$Query = $Query.Insert($Query.Length-3," copyOf EQ $CopyOf")	}
		}
	if($ProvisioningType)
		{	$PEnum
			$a = "FULL","TPVV","SNP","PEER","UNKNOWN","TDVV","DDS"
			$l=$ProvisioningType.ToUpper()
			if($a -eq $l)
				{	if($ProvisioningType -eq "FULL")	{	$PEnum = 1	}
					if($ProvisioningType -eq "TPVV")	{	$PEnum = 2	}
					if($ProvisioningType -eq "SNP")		{	$PEnum = 3	}
					if($ProvisioningType -eq "PEER")	{	$PEnum = 4	}
					if($ProvisioningType -eq "UNKNOWN")	{	$PEnum = 5	}
					if($ProvisioningType -eq "TDVV")	{	$PEnum = 6	}
					if($ProvisioningType -eq "DDS")		{	$PEnum = 7	}
				}
			else
				{ 	write-error "FAILURE : -ProvisioningType :- $ProvisioningType is an Incorrect Provisioning Type [FULL | TPVV | SNP | PEER | UNKNOWN | TDVV | DDS]  can be used only . " 
					Return 
				}			
			if($WWN -Or $UserCPG -Or $SnapCPG -Or $CopyOf)	{	$Query = $Query.Insert($Query.Length-3," OR provisioningType EQ $PEnum")	}
			else											{	$Query = $Query.Insert($Query.Length-3," provisioningType EQ $PEnum")	}
		}
	$uri = '/volumes'
	if($WWN -Or $UserCPG -Or $SnapCPG -Or $CopyOf -Or $ProvisioningType)	{	$uri = $uri+'/'+$Query }
	$Result = Invoke-WSAPI -uri '/volumes' -type 'GET' 
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-A9Vv. Expected Result Not Found with Given Filter Option : UserCPG/$UserCPG | WWN/$WWN | SnapCPG/$SnapCPG | CopyOf/$CopyOf | ProvisioningType/$ProvisioningType." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-A9Vv." 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9Vv
{
<#
.SYNOPSIS
	Delete virtual volumes
.DESCRIPTION
	Delete virtual volumes
.EXAMPLE    
	PS:> Remove-A9Vv -VVName MyVV
.PARAMETER VVName 
	Specify name of the volume to be removed
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
	[String]	$VVName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$uri = '/volumes/'+$VVName
	$Result = $null
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return
		}
	else
		{	Write-Error "Failure:  While Removing Volume:$VVName " 
			return $Result.StatusDescription
		}    	
}
}
