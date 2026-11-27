## 	©2025 Hewlett Packard Enterprise Development LP

Function New-a9Volume
{
<#      
.SYNOPSIS
	Creates a vitual volume
.DESCRIPTION
	Creates a vitual volume
.PARAMETER Volume
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
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE    
	PS:> New-a9Volume -Volume xxx -CpgName xxx -SizeMiB 1024 -SpaceSaving DeduplicateionCompression
.EXAMPLE                         
	PS:> New-A9Volume -Volume xxx -CpgName xxx -SizeMiB 1024 -SpaceSaving DeduplicateionCompression -Comment "This is test vv"
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$Volume,
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
		[ValidateRange(1,43800)][int]		$RetentionHours,
        [Parameter()]           [switch]    $ShowAPI
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = [ordered]@{}	
	$body["name"] 		= "$($Volume)"
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
	if ( $ShowAPI ) 
        {   $Result = Invoke-A9API -uri '/volumes' -type 'POST' -body $body -WhatIf 
            return 
        }
    $Result = Invoke-A9API -uri '/volumes' -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return ( Get-A9Volume | where-object { $_.name -like $Volume} ) 
		}
	else
		{	Write-Error "Failure:  While creating Volumes: $Volume " 
			return $Result.StatusDescription
		}
}
}

Function Set-A9Volume
{
<#
.SYNOPSIS
	Update a vitual volume.
.DESCRIPTION
	Update an existing vitual volume. This command incorporates both the API method as well as the CLI method of removing a Vv. If the only argument used is the VVName, the command will attempt to use the API
	to accomplish the task, if the API is unavalable or other parameters are used, the command will attempt to fail back to a SSH type connection to accomplish the goal.
.PARAMETER VVName
	Name of the volume being modified. The VVName is required and used in both the API version and SSH version of this command.
.PARAMETER Size
	Specifies the size in MB to be added to the volume user space. The size must be an integer in the range from 1 to 16T. This option uses the API, and no other options do.
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
	Enables (false) or disables (true) removing the snapshot space allocation limit. If false, and limit value is 0, setting ignored. If false, and limit value is a positive number, then set. 
.PARAMETER RmUsrSpcAllocLimit
	Enables (false) or disables (true)false) the allocation limit. If false, and limit value is a positive number, then set. 
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE 
	PS:> Update-A9Volume -Volume xxx -NewName zzz
.EXAMPLE 
	PS:> Update-A9Volume -Volume xxx -ExpirationHours 2
.EXAMPLE 
	PS:> Update-A9Volume -Volume xxx -OneHost $true
.EXAMPLE 
	PS:> Update-A9Volume -Volume xxx -SnapCPG xxx
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(
	[Parameter(Mandatory,parameterSetName='API')]	
	[Parameter(Mandatory,parameterSetName='CompressDECO')]	
	[Parameter(Mandatory,parameterSetName='CompressTPVV')]
	[Parameter(Mandatory,parameterSetName='CompressFPVV')]
	[Parameter(Mandatory,parameterSetName='CompressTDVV')]
	[Parameter(Mandatory,parameterSetName='Grow')]			[String]	$Volume ,		
	[Parameter(ParameterSetName='Grow',mandatory)]	
		[ValidateRange(256,[int]::MaxValue)]				[int]		$SizeMiB ,
	[Parameter(ParameterSetName='API')]						[String]	$NewName,
	[Parameter(ParameterSetName='API')]						[String]	$Comment,
	[Parameter(ParameterSetName='API')]						[String]	$WWN,
	[Parameter(ParameterSetName='API')]		
		[ValidateRange(256,[int]::MaxValue)]				[int]		$ExpirationHours,
	[Parameter(ParameterSetName='API')]	
		[ValidateRange(256,[int]::MaxValue)]				[int]		$RetentionHours,
	[Parameter(ParameterSetName='API')]						[boolean]	$StaleSS ,
	[Parameter(ParameterSetName='API')]						[boolean]	$OneHost,
	[Parameter(ParameterSetName='API')]						[boolean]	$ZeroDetect,
	[Parameter(ParameterSetName='API')]						[boolean]	$System ,
	[Parameter(ParameterSetName='API')]						[boolean]	$Caching ,
	[Parameter(ParameterSetName='API')]						[boolean]	$Fsvc ,
	[Parameter(ParameterSetName='API')]	
		[ValidateSet('3PAR_HOST_DIF','STD_HOST_DIF','NO_HOST_DIF')]
															[string]	$HostDIF ,
	[Parameter(          parameterSetName='CompressDECO')]	
	[Parameter(			 parameterSetName='CompressTPVV')]
	[Parameter(			 parameterSetName='CompressFPVV')]
	[Parameter(	 		 parameterSetName='CompressTDVV')]
	[Parameter(ParameterSetName='API')]						[String]	$SnapCPG,
	[Parameter(ParameterSetName='API')]
		[ValidateRange(0,100)]								[int]		$SsSpcAllocWarningPct ,
	[Parameter(ParameterSetName='API')]	
		[ValidateRange(0,100)]								[int]		$SsSpcAllocLimitPct ,

	[Parameter(          parameterSetName='CompressDECO')]	
	[Parameter(Mandatory,parameterSetName='CompressTPVV')]
	[Parameter(Mandatory,parameterSetName='CompressFPVV')]
	[Parameter(Mandatory,parameterSetName='CompressTDVV')]	
	[Parameter(ParameterSetName='API')]						[String]	$UserCPG,
	[Parameter(ParameterSetName='API')]
		[ValidateRange(0,100)]								[int]		$UsrSpcAllocWarningPct,
	[Parameter(ParameterSetName='API')]	
		[ValidateRange(0,100)]								[int]		$UsrSpcAllocLimitPct,
	[Parameter(ParameterSetName='API')]						[Boolean]	$RmSsSpcAllocWarning ,
	[Parameter(ParameterSetName='API')]						[Boolean]	$RmUsrSpcAllocWarning ,
	[Parameter(ParameterSetName='API')]						[Boolean]	$RmExpTime,
	[Parameter(ParameterSetName='API')]						[Boolean]	$RmSsSpcAllocLimit,
	[Parameter(ParameterSetName='API')]						[Boolean]	$RmUsrSpcAllocLimit,
	[Parameter(ParameterSetName='Grow',mandatory)]	
															[switch]	$ResizeMB,
	[Parameter(Mandatory,parameterSetName='CompressTPVV')]	[Switch]	$ThinProvision,

	[Parameter(Mandatory,parameterSetName='CompressFPVV')]	[Switch]	$FullProvision,
	[Parameter(Mandatory,parameterSetName='CompressTDVV')]	[Switch]	$ThinAndDedupe,
	[Parameter(Mandatory,parameterSetName='CompressDECO')]	[Switch]	$DeDupeAndCompress,
		
	[Parameter(			 parameterSetName='CompressTDVV')]
	[Parameter(			 parameterSetName='CompressFPVV')]
	[Parameter(			 ParameterSetName='CompressTPVV')]	[String]	$KeepVV,
    [Parameter()]                                          	[switch]    $ShowAPI
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}
	switch -wildcard ($PSCmdlet.ParameterSetName)
		{	'Grow'	{	if ($SizeMiB)			{	$Body = @{ 'action' = 3; 'SizeMiB' = $SizeMiB } }
					}
			'API'	{	If ($NewName) 			{ 	$body["newName"] 	= "$NewName" 			}
						If ($Comment) 			{  	$body["comment"] 	= "$Comment" 			}
						If ($WWN) 				{ 	$body["WWN"] 		= "$WWN"				}
						If ($ExpirationHours) 	{ 	$body["expirationHours"] = $ExpirationHours	}
						If ($RetentionHours) 	{	$body["retentionHours"] = $RetentionHours	}
						$VvPolicies = @{}
						If ($PSBoundParameters.ContainsKey('StaleSS') )				{	$VvPolicies["staleSS"] 	= $StaleSS		}
						If ($PSBoundParameters.ContainsKey('OneHost')) 				{	$VvPolicies["oneHost"] 	= $OneHost    	}
						If ($PSBoundParameters.ContainsKey('ZeroDetect')) 			{	$VvPolicies["zeroDetect"]=$ZeroDetect	}	
						If ($PSBoundParameters.ContainsKey('System')) 				{	$VvPolicies["system"] 	= $System    	} 
						If ($PSBoundParameters.ContainsKey('Caching')) 				{	$VvPolicies["caching"] 	= $Caching    	}	
						If ($PSBoundParameters.ContainsKey('Fsvc')) 				{	$VvPolicies["fsvc"] 	= $Fsvc    		}
						If ($PSBoundParameters.ContainsKey('HostDIF')) 
							{	if($HostDIF -eq "3PAR_HOST_DIF")					{	$VvPolicies["hostDIF"] = 1	}
								elseif($HostDIF -eq "STD_HOST_DIF")					{	$VvPolicies["hostDIF"] = 2	}
								elseif($HostDIF -eq "NO_HOST_DIF")					{	$VvPolicies["hostDIF"] = 3	}
							} 	   
						If ($PSBoundParameters.ContainsKey('SnapCPG')) 					{ 	$body["snapCPG"] 				= $SnapCPG 				}
						If ($PSBoundParameters.ContainsKey('SsSpcAllocWarningPct')) 	{ 	$body["ssSpcAllocWarningPct"] 	= $SsSpcAllocWarningPct }
						If ($PSBoundParameters.ContainsKey('SsSpcAllocLimitPct')) 		{  	$body["ssSpcAllocLimitPct"] 	= $SsSpcAllocLimitPct 	}	
						If ($PSBoundParameters.ContainsKey('UserCPG')) 					{	$body["userCPG"] 				= $UserCPG				}
						If ($PSBoundParameters.ContainsKey('UsrSpcAllocWarningPct')) 	{	$body["usrSpcAllocWarningPct"] 	= $UsrSpcAllocWarningPct}
						If ($PSBoundParameters.ContainsKey('UsrSpcAllocLimitPct')) 		{	$body["usrSpcAllocLimitPct"] 	= $UsrSpcAllocLimitPct	}	
						If ($PSBoundParameters.ContainsKey('RmSsSpcAllocWarning')) 		{	$body["rmSsSpcAllocWarning"] 	= $RmSsSpcAllocWarning  }
						If ($PSBoundParameters.ContainsKey('RmUsrSpcAllocWarning')) 	{	$body["rmUsrSpcAllocWarning"] 	= $RmUsrSpcAllocWarning	} 
						If ($PSBoundParameters.ContainsKey('RmExpTime')) 				{	$body["rmExpTime"] 				= $RmExpTime			} 
						If ($PSBoundParameters.ContainsKey('RmSsSpcAllocLimit')) 		{	$body["rmSsSpcAllocLimit"] 		= $RmSsSpcAllocLimit 	}
						If ($PSBoundParameters.ContainsKey('RmUsrSpcAllocLimit')) 		{	$body["rmUsrSpcAllocLimit"] 	= $RmUsrSpcAllocLimit 	}
						if($VvPolicies.Count -gt 0)										{	$body["policies"] 				= $VvPolicies 			}
					}
			"Comp*"	{	$body = @{} 	
						$body["action"] = 6	
						if ( $UserCPG )			{	$body['tuneOperation'] = 1
													$body['userCPG'] = $UserCPG		}
						else					{	$body['tuneOperation'] = 2		}
						if ( $SnapCPG)			{	$body['snapCPG'] = $SnapCPG		}	
						if ( $ThinProvisioning ){	$body['conversionOperation'] = 1}
						if ( $FullProvisioning ){	$body['conversionOperation'] = 2}
						if ( $ThinAndDeduupe ) 	{	$body['conversionOperation'] = 3}
						if ( $DeDupeAndCompress ){	$body['conversionOperation'] = 4}
						if ( $KeepVV ) 			{	$body['keepVV'] = $KeepVV		}
					}
		}	
	$Result = $null
	$uri = '/volumes/'+$Volume 
	if ( $ShowAPI ) 
        {   $Result = Invoke-A9API -uri $uri -type 'PUT' -body $Body -WhatIf 
            return 
        }
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $Body
	if($Result.StatusCode -eq 200)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			if($NewName)	{	return Get-A9Volume -Volume $NewName	}
			else			{	return Get-A9Volume -Volume $Volume		}
		}
	else
		{	Write-Error "Failure:  While Updating Volumes: $Volume " 
			return $Result.StatusDescription
		}
}
}

Function Get-A9Volume 
{
<#
.SYNOPSIS
	Get Single or list of virtual volumes, or get the Statistics or Space Disribution for a single or all volumes.
.DESCRIPTION
	Get Single or list of virtual volumes, or get the Statistics or Space Disribution for a single or all volumes.
.PARAMETER Volume
	Specify name of the volume.
.PARAMETER SpaceDistribution
	Display volume space distribution for all virtual volumes or for a single Volume defined by the volume parameter.
.PARAMETER Statistics
	Display volume space distribution for all virtual volumes or for a single Volume defined by the volume parameter.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE
	PS:> Get-A9Volume

	Get the list of virtual volumes using a SSH methof
.EXAMPLE
	PS:> Get-A9Volume -Volume MyVV

	Get the detail of given VV	
.EXAMPLE
	PS:> Get-A9Volume | where-object {$_.wwn -like '60002AC00000000000001EBE0007EB2E' }

	Querying volumes and filter the results to a single WWN
.EXAMPLE
	PS:> Get-A9Volume | where-object {$_.userCPG -like 'ABC' } 

	Querying volumes with a specific CPG only
.EXAMPLE
	PS:> Get-A9Volume | where-object {$_.snapCPG -like 'ABC'} | where-object {$_.userCPG -like 'CDE' }
	 
	Querying volumes with multiple filters can be done by chaining more piles
.EXAMPLE
	PS:> Get-A9Volume | where-object {$_.copyOf -like 'Test'} 

	Querying volumes with multiple filters
.EXAMPLE
	PS:> Get-A9Volume -Statistics
.EXAMPLE
	PS:> Get-A9Volume -SpaceDistribution
.EXAMPLE
	PS:> Get-A9Volume -SpaceDistribution -Volume XYZ
.NOTES
	This command only uses the WSAPI mode of communication.
#>
[CmdletBinding(DefaultParameterSetName='Base')]
Param(	[Parameter(ParameterSetName='Base')]
		[Parameter(ParameterSetName='Stats')]
		[Parameter(ParameterSetName='SpaceDistro')]					[String]	$Volume,
		[Parameter(Mandatory, ParameterSetName='Stats')]			[Switch]	$Statistics,
		[Parameter(Mandatory, ParameterSetName='SpaceDistro')]		[Switch]	$SpaceDistribution,
        [Parameter()]                                               [switch]    $ShowAPI
	)
Begin 
	{	Test-A9Connection -CLientType 'API' 
    }
Process 
{	Switch ($PSCmdlet.ParameterSetName)
	{	'Base'	
				{	$uri = '/volumes'
					if ( $ShowAPI ) 
        				{   $Result = Invoke-A9API -uri $uri -type 'GET'  -WhatIf 
            				return 
        				}
				    $Result = Invoke-A9API -uri $uri -type 'GET'
					If($Result.StatusCode -eq 200)
						{	$dataPS = ($Result.content | ConvertFrom-Json).members
							if ($ProvisioningType)
								{	$PT = @{Full=1; TPVV=2; SNP=3; PEER=4; UNKNOWN=5;TDVV=6;DDS=7}
									$PEnum = $PT."$ProvisioningType"
									$dataPS = $dataPS | where-object { $_.provisioningType -like $PEnum }
								}
							if($dataPS.Count -gt 0)
								{	write-host "Cmdlet executed successfully" -foreground green
									# The following code will decorate the returned objects with desciptions for codified enums. 
									# The following code will also add the formatting information as well.
									$NewObj = @(    foreach( $Item in $DataPS)	{   $NewItem=@{PSTypeName = "HPE.A9Storage.Volume"}
																					$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
																							$Enum = $Item.State
																								Switch ($Enum)
																									{   1   {   $Desc = 'Normal'   }
																										2   {   $Desc = 'Degraded' }
																										3   {   $Desc = 'New'      }
																										4   {   $Desc = 'Failed'   }
																										99  {   $Desc = 'Unknown'  }
																									}
																								if ($Desc) 
																									{   $NewItem['StateDescription'] = $Desc
																										remove-variable $Desc -erroraction SilentlyContinue
																										remove-variable $Enum -erroraction SilentlyContinue
																									}
																							$Enum = $Item.'compressionState'
																								Switch ($Enum)
																									{   1   {   $Desc = 'Yes' }
																										2   {   $Desc = 'No'  }
																										3   {   $Desc = 'Off' }
																										4   {   $Desc = 'NA'  }
																										5   {   $Desc = 'V1'  }
																										6   {   $Desc = 'V2'  }
																									}
																								if ($Desc) 
																									{   $NewItem['compressionDescription'] = $Desc
																										remove-variable $Desc -erroraction SilentlyContinue
																										remove-variable $Enum -erroraction SilentlyContinue
																									}
																							$Enum = $Item.'provisioningType'
																								Switch ($Enum)
																									{   1   {   $Desc = 'Full' }
																										2   {   $Desc = 'TPVV(Thin Provisioned Virtual Volume)'  }
																										3   {   $Desc = 'SNP(Snapshot)' }
																										4   {   $Desc = 'PEER'  }
																										5   {   $Desc = 'UNKNOWN'  }
																										6   {   $Desc = 'TDVV(Thin Provision And Deduplicated Virtual Volume)'  }
																										7   {   $Desc = 'DDS(System Maintained Dedupe Volume)'  }
																									}
																								if ($Desc) 
																									{   $NewItem['provisioningDescription'] = $Desc
																										remove-variable $Desc -erroraction SilentlyContinue
																										remove-variable $Enum -erroraction SilentlyContinue
																									}
																							$Enum = $Item.'deduplicationState'
																								Switch ($Enum)
																									{   1   {   $Desc = 'Yes' }
																										2   {   $Desc = 'No'  }
																										3   {   $Desc = 'NA'  }
																										4   {   $Desc = 'OFF' }
																									}
																								if ($Desc) 
																									{   $NewItem['deduplicationStateDescription'] = $Desc
																										remove-variable $Desc -erroraction SilentlyContinue
																										remove-variable $Enum -erroraction SilentlyContinue
																									}
																							$Enum = $Item.'copyType'
																								Switch ($Enum)
																									{   1   {   $Desc = 'BASE' }
																										2   {   $Desc = 'PHYSICAL_COPY'  }
																										3   {   $Desc = 'VIRTUAL_COPY'  }
																									}
																								if ($Desc) 
																									{   $NewItem['copyTypeDescription'] = $Desc
																										remove-variable $Desc -erroraction SilentlyContinue
																										remove-variable $Enum -erroraction SilentlyContinue
																									}
																					$DataSetType = "HPE.A9Storage.Volume"
																					$NewItem.PSTypeNames.Insert(0,$DataSetType)
																					$DataSetType = $DataSetType + ".TypeName"
																					$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
																					[PSCustomObject]$NewItem
																				}
												)
									if ($Volume) 	{	return ($NewObj | where-object {$_.name -like $Volume })	}
									else			{ 	return $NewObj	}
								}
							else{	Write-warning "While Executing Get-A9Vv, No Expected Results Found." 
									return 
								}
						}
					else{	Write-Error "Failure:  While Executing Get-A9Vv." 
							return $Result.StatusDescription
						}
				}
		'Stats'	
				{	$uri = '/statistics/volumes'
					if ( $ShowAPI ) 
        				{   $Result = Invoke-A9API -uri $uri -type 'GET'  -WhatIf 
            				return 
        				}
				    $Result = Invoke-A9API -uri $uri -type 'GET'
					If($Result.StatusCode -eq 200)
						{	$dataPS = ($Result.content | ConvertFrom-Json).members
							if ($ProvisioningType)
								{	$PT = @{Full=1; TPVV=2; SNP=3; PEER=4; UNKNOWN=5;TDVV=6;DDS=7}
									$PEnum = $PT."$ProvisioningType"
									$dataPS = $dataPS | where-object { $_.provisioningType -like $PEnum }
								}
							if($dataPS.Count -gt 0)
								{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
									$NewObj = @(    foreach( $Item in $DataPS)	{   $NewItem=@{PSTypeName = "HPE.A9Storage.VVStat"}
																					$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
																					$DataSetType = "HPE.A9Storage.VVStat"
																					$NewItem.PSTypeNames.Insert(0,$DataSetType)
																					$DataSetType = $DataSetType + ".TypeName"
																					$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
																					[PSCustomObject]$NewItem
																				}
												)
									if ($Volume) 	{	return ($NewObj | where-object {$_.name -like $Volume })	}
									else			{ 	return $NewObj		}
								}
							else{	Write-warning "While Executing $($PSCmdlet.MyInvocation.MyCommand.Name), No Expected Results Found." 
									return 
								}
						}
					else{	Write-Error "Failure:  While Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" 
							return $Result.StatusDescription
						}
				}
		'SpaceDistro'
				{	$uri =  '/volumespacedistribution'
					if($Volume)	{	$uri = '/volumespacedistribution/'+$Volume	}	
					if ( $ShowAPI ) 
		        		{   $Result = Invoke-A9API -uri $uri -type 'GET' -WhatIf 
    		        		return 
        				}
					$Result = Invoke-A9API -uri $uri -type 'GET'
					if($Result.StatusCode -eq 200)	
						{	$dataPS = ($Result.content | ConvertFrom-Json).members 	
							write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
							return $dataPS
						}
					else
						{	Write-Error "Failure:  While Executing $($PSCmdlet.MyInvocation.MyCommand.Name)." 
							return $Result.StatusDescription
						}
				}
	}
}
}

Function Remove-A9Volume
{
<#
.SYNOPSIS
    Delete virtual volumes 
.DESCRIPTION
	Delete virtual volumes. This command incorporates both the API method as well as the CLI method of removing a Vv. If the only argument used is the VVName, the command will attempt to use the API
	to accomplish the task, if the API is unavalable or other parameters are used, the command will attempt to fail back to a SSH type connection to accomplish the goal.          
.PARAMETER Volume
    Specify name of the volume to be removed. This parrameter is the only allowed parameter if using the API. All other variables require the usage of a SSH type connection
.PARAMETER Stale
	Specifies that all stale Volumes can be removed. Only valid for SSH type connections	     
.PARAMETER Expired
	Remove specified expired volumes. Only valid for SSH type connections	
.PARAMETER Snaponly
	Remove the snapshot copies only. Only valid for SSH type connections	
.PARAMETER Cascade
	Remove specified volumes and their descendent volumes as long as none has an active VLUN. 
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE	
	PS:> Remove-A9Volume -Volume PassThru-Disk

	Delete operation on Volume named PassThru-Disk
.EXAMPLE	
	PS:> Remove-A9Volume -Volume VV1 -Snaponly
.EXAMPLE	
	PS:> Remove-A9Volume -Expired	
#>
[CmdletBinding(DefaultParameterSetName='API')]
	param(
		[Parameter(Mandatory, ParameterSetName='API')]
		[Parameter(Mandatory, ParameterSetName='SSHV')]			[String]	$Volume,

		[Parameter(ParameterSetName='SSHV')]					[Switch]	$Stale, 

		[Parameter(ParameterSetName='SSHE')]					[Switch]	$Expired, 

		[Parameter(ParameterSetName='SSHV')]
		[Parameter(ParameterSetName='SSHE')]					[Switch]	$Snaponly,

		[Parameter(ParameterSetName='API')]		
		[Parameter(ParameterSetName='SSHV')]
		[Parameter(ParameterSetName='SSHE')]					[Switch]	$Cascade,
        [Parameter(ParameterSetName='API')]                     [switch]    $ShowAPI
	)		
Begin
{	if ( $PSCmdlet.ParameterSetName -eq 'API' )
		{	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
				{	$PSetName = 'API'
				}
			else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
						{	$PSetName = 'SSH'
						}
				}
		}
	elseif ( $PSCmdlet.ParameterSetName -eq 'SSH' )	
		{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
				{	$PSetName = 'SSH'
				}
			else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
					return
				}
		}
}	
process	
{	switch -wildcard ($PSetName )
		{	'API'		{	$uri = '/volumes/'+$Volume
							$Result = $null
							if ($cascade) { $uri = $uri + "?cascade=true"}
							if ( $ShowAPI ) 
								{   $Result = Invoke-A9API -uri $uri -type 'DELETE' -WhatIf 
									return 
								}
						    $Result = Invoke-A9API -uri $uri -type 'DELETE'
							$status = $Result.StatusCode
							if($status -eq 200)
								{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
									return
								}
							else
								{	Write-Error "Failure:  While Removing Volume:$Volume " 
									return $Result.StatusDescription
								}    	
						}
			"SSH*"		{	$ActionCmd = "removevv "
							if ($Expired)	{	$ActionCmd += "-expired "	}
							if ($Cascade)	{	$ActionCmd += "-cascade "	}
							if ($Snaponly)	{	$ActionCmd += "-snaponly "	}
							if ($Stale)		{	$ActionCmd += "-stale "		}
							$ActionCmd += $Volume + " -f"
							$Result1 = Invoke-A9CLICommand -cmds $ActionCmd
							write-verbose "The command to be run is : $ActionCmd"			
							if([string]::IsNullOrEmpty($Result1))
								{	if($Volume)	{	return  "Success : Removed Volume $Volume "	}
									write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
									return  "Success : Removed Volume "
								}
							else
								{	return "FAILURE : While removing Volume"
								}
						}
		}
}
}

