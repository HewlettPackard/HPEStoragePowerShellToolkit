## 	©2025 Hewlett Packard Enterprise Development LP

Function New-a9Vv 
{
<#      
.SYNOPSIS
	Creates a vitual volume
.DESCRIPTION
	Creates a vitual volume
.PARAMETER VolumeName
	Specifies a volume name up to 31 characters in length.
.PARAMETER CpgName
	Specifies the name of the CPG from which the volume user space will be allocated.
.PARAMETER SizeMiB
	Volume size. Specifies the size for the volume in MiB. Rounds the volume size to the next multiple of 256 MiB. Minimum value of 256
.PARAMETER SpaceSavings
	Can either be set to 'Thin-Provisioned' or a thinly 'deduplicated and compressed' volume. This replaces the CLI option called TPVV (thin provision virtual volume) and Reduce (compression+deduplicate).
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
.EXAMPLE    
	PS:> New-a9Vv -VolumeName xxx -CpgName xxx -SizeMiB 1024 -SpaceSaving DeduplicateionCompression
.EXAMPLE                         
	PS:> New-A9Vv -VolumeName xxx -CpgName xxx -SizeMiB 1024 -SpaceSaving DeduplicateionCompression -Comment "This is test vv"
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$VolumeName,
		[Parameter(Mandatory)]	[String]	$CpgName,
		[Parameter(Mandatory)]
		[ValidateRange(256,[int]::MaxValue)]	
								[int]		$SizeMiB,
		[Parameter(Mandatory)]
		[ValidateSet('ThinProvision','DeduplicateionCompression')]	
								[String]	$SpaceSaving,
		[Parameter()]			[int]		$Id,
		[Parameter()]			[String]	$Comment,
		[Parameter()]			[Boolean]	$StaleSS,
		[Parameter()]			[Boolean]	$OneHost,
		[Parameter()]			[Boolean]	$ZeroDetect,
		[Parameter()]			[Boolean]	$System,
		[Parameter()]			[Boolean]	$Caching,
		[Parameter()]			[Boolean]	$Fsvc,
		[Parameter()]	[ValidateSet('3PAR_HOST_DIF','STD+HOST_DIF','NO_HOST_DIF')]
								[string]	$HostDIF,
		[Parameter()]			[String]	$SnapCPG,
		[Parameter()]
		[ValidateRange(0,100)]	[int]		$SsSpcAllocWarningPct,
		[Parameter()]
		[ValidateRange(0,100)]	[int]		$SsSpcAllocLimitPct,
		[Parameter()]			
		[ValidateRange(0,100)]	[int]		$UsrSpcAllocWarningPct,
		[Parameter()]
		[ValidateRange(0,100)]	[int]		$UsrSpcAllocLimitPct,
		[Parameter()]
		[ValidateRange(1,43800)][int]		$ExpirationHours,
		[Parameter()]
		[ValidateRange(1,43800)][int]		$RetentionHours
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = [ordered]@{}	
	$body["name"] 		= "$($VolumeName)"
	$body["cpg"] 		= "$($CpgName)"
    $body["sizeMiB"] 	= $SizeMiB
    If ($Id) 		{	$body["id"] = $Id }
	$VvPolicies = @{}
	If ($StaleSS) 	{	$VvPolicies["staleSS"] = $true		}	
	If ($OneHost) 	{	$VvPolicies["oneHost"] = $true    	} 
	If ($System) 	{	$VvPolicies["system"]  = $true    	}
	If ($Caching) 	{	$VvPolicies["caching"] = $true    	}	
	If ($Fsvc) 		{	$VvPolicies["fsvc"]    = $true    	}	
	if($VvPolicies.Count -gt 0){$body["policies"] = $VvPolicies }
	If ($HostDIF) 	
		{	if($HostDIF -eq "3PAR_HOST_DIF")	{	$VvPolicies["hostDIF"] = 1	}
			elseif($HostDIF -eq "STD_HOST_DIF")	{	$VvPolicies["hostDIF"] = 2	}
			elseif($HostDIF -eq "NO_HOST_DIF")	{	$VvPolicies["hostDIF"] = 3	}
		} 	
    If ($Comment) 				{	$body["comment"] = "$($Comment)"}
	If ($SnapCPG) 				{	$body["snapCPG"] = "$($SnapCPG)" }
	If ($SsSpcAllocWarningPct) 	{	$body["ssSpcAllocWarningPct"] 	= $SsSpcAllocWarningPct }
	If ($SsSpcAllocLimitPct) 	{	$body["ssSpcAllocLimitPct"] 	= $SsSpcAllocLimitPct }
    if ($SpaceSaving -eq 'ThinProvision') 						
								{ 	$body["tpvv"] = $true	}
	elseIf ($SpaceSaving -eq 'DeduplicateionCompression') 	
								{	$body["reduce"] = $true }
    If ($UsrSpcAllocWarningPct) {	$body["usrSpcAllocWarningPct"]	= $UsrSpcAllocWarningPct }
	If ($UsrSpcAllocLimitPct) 	{	$body["usrSpcAllocLimitPct"] 	= $UsrSpcAllocLimitPct } 
	If ($ExpirationHours) 		{ 	$body["expirationHours"] 		= $ExpirationHours	}
	If ($RetentionHours) 		{	$body["retentionHours"] 		= $RetentionHours	}
	$Result = $null
	# write-verbose "The call will be made to /volumes and contain the body;"
	#$body | convertto-json
    $Result = Invoke-A9API -uri '/volumes' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return ( Get-A9Vv | where-object { $_.name -like $VolumeName} ) 
		}
	else
		{	Write-Error "Failure:  While creating Volumes: $VolumeName " 
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
{	Test-A9Connection -ClientType 'API'	
}
Process 
{	$Result = $null
	$dataPS = $null			
	if($VVName)
	{	$uri = '/volumespacedistribution/'+$VVName
		$Result = Invoke-A9API -uri $uri -type 'GET' 
		if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
		}
	}
	else
	{	$Result = Invoke-A9API -uri '/volumespacedistribution' -type 'GET' 
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


