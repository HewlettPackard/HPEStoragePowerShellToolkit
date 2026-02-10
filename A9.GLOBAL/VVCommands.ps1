####################################################################################
## 	© 2024 Hewlett Packard Enterprise Development LP
##

Function Get-A9Vv 
{
<#
.SYNOPSIS
	Get Single or list of virtual volumes.
.DESCRIPTION
	Get Single or list of virtual volumes. 
.PARAMETER VVName
	Specify name of the volume. This option an be used with either API or SSH connections
.PARAMETER ProvisioningType
	Querying volume with Provisioning Type.  This option can only be used with a API type connection.
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
.EXAMPLE
	PS:> Get-A9Vv 

	Get the list of virtual volumes using a SSH methof
.EXAMPLE
	PS:> Get-A9Vv -VolumeName MyVV

	Get the detail of given VV	
.EXAMPLE
	PS:> Get-A9Vv | where-object {$_.wwn -like '60002AC00000000000001EBE0007EB2E' }

	Querying volumes and filter the results to a single WWN
.EXAMPLE
	PS:> Get-A9Vv | where-object {$_.userCPG -like 'ABC' } 

	Querying volumes with a specific CPG only
.EXAMPLE
	PS:> Get-A9Vv | where-object {$_.snapCPG -like 'ABC'} | where-object {$_.userCPG -like 'CDE' }
	 
	Querying volumes with multiple filters can be done by chaining more piles
.EXAMPLE
	PS:> Get-A9Vv | where-object {$_.copyOf -like 'Test'} 

	Querying volumes with multiple filters
.EXAMPLE
	PS:> Get-A9Vv -ProvisioningType FULL  

	Querying volumes with Provisioning Type FULL
.NOTES
	This command only uses the WSAPI mode of communication.
	In the output, the value of compressionState is <1=enabled, 2=disabled,3=off,4=Not avaiable,5=CompressionVersion1,6=CompressionVersion2>
	In the output, The value of deduplicationState is <1=Yes, 2=Disabled, 3=Not Available, 4=Off>
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	[Parameter(ParameterSetName='API')]		[String]	$VolumeName,
		[Parameter(ParameterSetName='API')]	
		[ValidateSet('FULL','TPW','SNP','PEER','UNKNOWN','TDVV','DDS')]
												[String]	$ProvisioningType
	)
Begin 
	{	Test-A9Connection -CLientType 'API' 
    }
Process 
{	$Result = $null
	$dataPS = $null	
	$uri = '/volumes'
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
					if ($VolumeName) 
						{	return ($dataPS | where-object {$_.name -like $VolumeName })
						}
					else{ 	return $dataPS
						}
				}
			else
				{	Write-warning "While Executing Get-A9Vv, No Expected Results Found." 
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
	Delete virtual volumes. This command incorporates both the API method as well as the CLI method of removing a Vv. If the only argument used is the VVName, the command will attempt to use the API
	to accomplish the task, if the API is unavalable or other parameters are used, the command will attempt to fail back to a SSH type connection to accomplish the goal.          
.PARAMETER VolumeName
    Specify name of the volume to be removed. This parrameter is the only allowed parameter if using the API. All other variables require the usage of a SSH type connection
.PARAMETER Stale
	Specifies that all stale VVs can be removed. Only valid for SSH type connections	     
.PARAMETER Expired
	Remove specified expired volumes. Only valid for SSH type connections	
.PARAMETER Snaponly
	Remove the snapshot copies only. Only valid for SSH type connections	
.PARAMETER Cascade
	Remove specified volumes and their descendent volumes as long as none has an active VLUN. 
.EXAMPLE	
	PS:> Remove-A9Vv -VolumeName PassThru-Disk

	Delete operation on Volume named PassThru-Disk
.EXAMPLE	
	PS:> Remove-A9Vv -VolumeName VV1 -Snaponly
.EXAMPLE	
	PS:> Remove-A9Vv -Expired	
#>
[CmdletBinding(DefaultParameterSetName='API')]
	param(
		[Parameter(Mandatory, ParameterSetName='API')]
		[Parameter(Mandatory, ParameterSetName='SSHV')]			[String]	$VolumeName,

		[Parameter(ParameterSetName='SSHV')]					[Switch]	$Stale, 

		[Parameter(ParameterSetName='SSHE')]					[Switch]	$Expired, 

		[Parameter(ParameterSetName='SSHV')]
		[Parameter(ParameterSetName='SSHE')]					[Switch]	$Snaponly,

		[Parameter(ParameterSetName='API')]		
		[Parameter(ParameterSetName='SSHV')]
		[Parameter(ParameterSetName='SSHE')]					[Switch]	$Cascade
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
		{	'API'		{	$uri = '/volumes/'+$VolumeName
							$Result = $null
							if ($cascade) { $uri = $uri + "?cascade=true"}
							$Result = Invoke-A9API -uri $uri -type 'DELETE' 
							$status = $Result.StatusCode
							if($status -eq 200)
								{	write-host "Cmdlet executed successfully" -foreground green
									return
								}
							else
								{	Write-Error "Failure:  While Removing Volume:$VolumeName " 
									return $Result.StatusDescription
								}    	
						}
			"SSH*"		{	$ActionCmd = "removevv "
							if ($Expired)	{	$ActionCmd += "-expired "	}
							if ($Cascade)	{	$ActionCmd += "-cascade "	}
							if ($Snaponly)	{	$ActionCmd += "-snaponly "	}
							if ($Stale)		{	$ActionCmd += "-stale "		}
							$ActionCmd += $Volumename + " -f"
							$Result1 = Invoke-A9CLICommand -cmds $ActionCmd
							write-verbose "The command to be run is : $ActionCmd"			
							if([string]::IsNullOrEmpty($Result1))
								{	if($vvName)	{	return  "Success : Removed Volume $VolumeName "	}
									return  "Success : Removed Volume "
								}
							else
								{	return "FAILURE : While removing Volume Result1"
								}
						}
		}
}
}

Function Remove-A9VvSet
{
<#
.SYNOPSIS
    Remove a Virtual Volume set
.DESCRIPTION
	Removes a VV set. If you need to remove a single (or multiple) Volumes from a VolumeSet, use the Set-A9VvSet command.
.PARAMETER VolumeSetName 
    Specify name of the VolumesetName..
.EXAMPLE
    PS:> Remove-A9VvSet -VolumeSetName "MyVVSet"

	Remove a VV set "MyVVSet"
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	[Parameter(ParameterSetName='API', Mandatory=$true)]	[String]	$VolumeSetName
	)	
Begin	
{	Test-A9Connection -CLientType 'API' 
}
process
{	$uri = '/volumesets/'+$VolumeSetName
	$Result = $null
	$Result = Invoke-A9API -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return
		}
	else
		{	Write-Error "Failure:  While Removing virtual volume Set:$VolumeSetName " 
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
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -NewName zzz
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -ExpirationHours 2
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -OneHost $true
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -SnapCPG xxx
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(
	[Parameter(Mandatory, ParameterSetName='API')]	
	[Parameter(Mandatory, ParameterSetName='Grow')]	
												[String]	$VolumeName ,		
	[Parameter(ParameterSetName='Grow')]	
		[ValidateRange(256,[int]::MaxValue)]	[int]		$SizeMiB ,
	[Parameter(ParameterSetName='API')]			[String]	$NewName,
	[Parameter(ParameterSetName='API')]			[String]	$Comment,
	[Parameter(ParameterSetName='API')]			[String]	$WWN,
	[Parameter(ParameterSetName='API')]
		[ValidateRange(256,[int]::MaxValue)]	[int]		$ExpirationHours,
	[Parameter(ParameterSetName='API')]	
		[ValidateRange(256,[int]::MaxValue)]	[int]		$RetentionHours,
	[Parameter(ParameterSetName='API')]			[boolean]	$StaleSS ,
	[Parameter(ParameterSetName='API')]			[boolean]	$OneHost,
	[Parameter(ParameterSetName='API')]			[boolean]	$ZeroDetect,
	[Parameter(ParameterSetName='API')]			[boolean]	$System ,
	[Parameter(ParameterSetName='API')]			[boolean]	$Caching ,
	[Parameter(ParameterSetName='API')]			[boolean]	$Fsvc ,
	[Parameter(ParameterSetName='API')]	
		[ValidateSet('3PAR_HOST_DIF','STD_HOST_DIF','NO_HOST_DIF')]
												[string]	$HostDIF ,
	[Parameter(ParameterSetName='API')]			[String]	$SnapCPG,
	[Parameter(ParameterSetName='API')]
		[ValidateRange(0,100)]					[int]		$SsSpcAllocWarningPct ,
	[Parameter(ParameterSetName='API')]
		[ValidateRange(0,100)]					[int]		$SsSpcAllocLimitPct ,
	[Parameter(ParameterSetName='API')]			[String]	$UserCPG,
	[Parameter(ParameterSetName='API')]
		[ValidateRange(0,100)]					[int]		$UsrSpcAllocWarningPct,
	[Parameter(ParameterSetName='API')]	
		[ValidateRange(0,100)]					[int]		$UsrSpcAllocLimitPct,
	[Parameter(ParameterSetName='API')]			[Boolean]	$RmSsSpcAllocWarning ,
	[Parameter(ParameterSetName='API')]			[Boolean]	$RmUsrSpcAllocWarning ,
	[Parameter(ParameterSetName='API')]			[Boolean]	$RmExpTime,
	[Parameter(ParameterSetName='API')]			[Boolean]	$RmSsSpcAllocLimit,
	[Parameter(ParameterSetName='API')]			[Boolean]	$RmUsrSpcAllocLimit
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}
	if ($SizeMiB)			{	$BodySize = @{ 'action' = 3; 'SizeMiB' = $SizeMiB } }
	If ($NewName) 			{ 	$body["newName"] 	= "$NewName" 			}
	If ($Comment) 			{  	$body["comment"] 	= "$Comment" 			}
	If ($WWN) 				{ 	$body["WWN"] 		= "$WWN"				}
	If ($ExpirationHours) 	{ 	$body["expirationHours"] = $ExpirationHours	}
	If ($RetentionHours) 	{	$body["retentionHours"] = $RetentionHours	}
	$VvPolicies = @{}
	If (test-path Variable:$StaleSS) 				{	$VvPolicies["staleSS"] 	= $StaleSS		}
	If (test-path Variable:$OneHost) 				{	$VvPolicies["oneHost"] 	= $OneHost    	}
	If (test-path Variable:$ZeroDetect) 			{	$VvPolicies["zeroDetect"]=$ZeroDetect	}	
	If (test-path Variable:$System) 				{	$VvPolicies["system"] 	= $System    	} 
	If (test-path Variable:$Caching) 				{	$VvPolicies["caching"] 	= $Caching    	}	
	If (test-path Variable:$Fsvc) 					{	$VvPolicies["fsvc"] 	= $Fsvc    		}
	If (test-path Variable:$HostDIF) 
		{	if($HostDIF -eq "3PAR_HOST_DIF")		{	$VvPolicies["hostDIF"] = 1	}
			elseif($HostDIF -eq "STD_HOST_DIF")		{	$VvPolicies["hostDIF"] = 2	}
			elseif($HostDIF -eq "NO_HOST_DIF")		{	$VvPolicies["hostDIF"] = 3	}
		} 	   
	If (test-path Variable:$SnapCPG) 				{ 	$body["snapCPG"] 				= $SnapCPG 				}
	If (test-path Variable:$SsSpcAllocWarningPct) 	{ 	$body["ssSpcAllocWarningPct"] 	= $SsSpcAllocWarningPct }
	If (test-path Variable:$SsSpcAllocLimitPct) 	{  	$body["ssSpcAllocLimitPct"] 	= $SsSpcAllocLimitPct 	}	
	If (test-path Variable:$UserCPG) 				{	$body["userCPG"] 				= $UserCPG				}
	If (test-path Variable:$UsrSpcAllocWarningPct) 	{	$body["usrSpcAllocWarningPct"] 	= $UsrSpcAllocWarningPct}
	If (test-path Variable:$UsrSpcAllocLimitPct) 	{	$body["usrSpcAllocLimitPct"] 	= $UsrSpcAllocLimitPct	}	
	If (test-path Variable:$RmSsSpcAllocWarning) 	{	$body["rmSsSpcAllocWarning"] 	= $RmSsSpcAllocWarning  }
	If (test-path Variable:$RmUsrSpcAllocWarning) 	{	$body["rmUsrSpcAllocWarning"] 	= $RmUsrSpcAllocWarning	} 
	If (test-path Variable:$RmExpTime) 				{	$body["rmExpTime"] 				= $RmExpTime			} 
	If (test-path Variable:$RmSsSpcAllocLimit) 		{	$body["rmSsSpcAllocLimit"] 		= $RmSsSpcAllocLimit 	}
	If (test-path Variable:$RmUsrSpcAllocLimit) 	{	$body["rmUsrSpcAllocLimit"] 	= $RmUsrSpcAllocLimit 	}
	if($VvPolicies.Count -gt 0)						{	$body["policies"] 				= $VvPolicies 			}
	$Result = $null
	$uri = '/volumes/'+$VolumeName 
	if (-not $SizeMB )	{	$Result = Invoke-A9API -uri $uri -type 'PUT' -body $Body		}
	else 				{	$Result = Invoke-A9API -uri $uri -type 'PUT' -body $BodySize	} 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)	{	return Get-A9Vv -VVName $NewName	}
			else			{	return Get-A9Vv -VVName $VolumeName		}
		}
	else
		{	Write-Error "Failure:  While Updating Volumes: $VolumeName " 
			return $Result.StatusDescription
		}
}
}

Function Get-A9vLun 
{
<#
.SYNOPSIS
	Get Single or list of VLun.
.DESCRIPTION
	Get Single or list of VLun.  This command incorporates both the API method as well as the CLI method of removing a Vv. 
	If the only argument used is the VVName, the command will attempt to use the API to accomplish the task, if the API is unavalable or other parameters 
	are used, the command will attempt to fail back to a SSH type connection to accomplish the goal. 
.PARAMETER VolumeName
	Name of the volume to filter the results. if used with the -UseSSH option, may be prefixed with 'set:', the name is a volume set name. Displays only VLUNs of virtual volumes that match <VV_name> or 
	glob-style patterns, or to the vv sets that match <VV-set> or glob-style patterns (see help on sub,globpat). The VV set name must start with "set:". Multiple volume names, vv sets or patterns can be
	repeated using a comma-separated list (for example -v <VV_name>, <VV_name>...).
.PARAMETER LUNID
	The LUN ID of the volume to filter the results
.PARAMETER HostName
	Name of the host to which the volume is to be exported. If used with the -UseSSH option, Displays only VLUNs exported to hosts that match <hostname> or glob-style patterns, or to the host sets that match <hostset> or
	glob-style patterns(see help on sub,globpat). The host set name must start with "set:". Multiple host names, host sets or patterns can
	be repeated using a comma-separated list.
.EXAMPLE	
	PS:> Show-A9vLun_CLI -volumeName XYZ 

	List vlun details for all hosts connected to volumename XYZ
.EXAMPLE	
	PS:> Show-A9vLun_CLI -volumeName XYZ -hostname abc

	List vlun details for the specific host connected to a specific lun
.EXAMPLE	
	PS:> Show-A9vLun -volumename MyTestVol | where-object {$.serial -like "123456" }
	
	This is an example of how to replicate the functionality of the serial cli option. This command will return only vLuns that match that serial number
.EXAMPLE	
	PS:> Show-A9vLun -volumename MyTestVol | where-object {$.active -like "True" }
	
	This is an example of how to replicate the functionality of the active cli option. This command will return only vLuns that are active
.EXAMPLE	
	PS:> Show-A9vLun -volumename MyTestVol | where-object {$.portPos.node -like 3 }
	
	This is an example of how to replicate the functionality of the ports cli option. This command will return all vLuns that match the other parameters as well as match the port posistion of 3
.EXAMPLE	
	PS:> Show-A9vLun -volumename MyTestVol | where-object {$.portPos.slot -like 4 }
	
	This is an example of how to replicate the functionality of the slots cli option. This command will return all vLuns that match the other parameters as well as match the slot posistion of 4
.EXAMPLE	
	PS:> Show-A9vLun -volumename MyTestVol | where-object {$.portPos.nodes -like 0 }
	
	This is an example of how to replicate the functionality of the nodes cli option. This command will return all vLuns that match the other parameters as well as match the node value of 0
.NOTES 
	This command only uses the WSAPI connection method. 

#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	
		[Parameter(ParameterSetName='API')]	[String]	$VolumeName,
		[Parameter(ParameterSetName='API')]	[int]		$LUNID,
		[Parameter(ParameterSetName='API')]	[String]	$HostName
	)
Begin 
{	Test-A9Connection -CLientType 'API' 
}
Process 
{	
	Write-Verbose "Request: Request to Get-vLun_WSAPI [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName ] (Invoke-A9API)."
	$Result = $null
	$dataPS = $null		
	write-verbose "Making URL call to /vluns"
	$Result = Invoke-A9API -uri '/vluns' -type 'GET' 
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members			
		}		
	If($Result.StatusCode -eq 200)
		{	if ( $VolumeName )	{	$dataPS = $dataPS | where-object {$_.volumeName -like $VolumeName }		}
			if ( $LUNID )		{	$dataPS = $dataPS | where-object {$_.lun -like $LUNID }					}
			if ( $HostName )	{	$dataPS = $dataPS | where-object {$_.hostname -like $HostName }			}
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	write-verbose "No data Found."
					return 
				}
		}
	else
		{	write-error "While Executing Get-A9vLun."
			return $Result.StatusDescription
		}
}
}

Function Remove-A9vLun
{
<#
.SYNOPSIS
	Removing a VLUN (mapping between a Host/HostSet and a Volume/VolumeSet).
.DESCRIPTION
	Removing a VLUN mapping for a Volume (or VolumeSet) to connect to a Host (or HostSet).
.PARAMETER VolumeName
	Name of the volume which is exported which will be removed.
.PARAMETER VolumeSetName
	Name of the volumeset is be exported which will be removed.
	The VV set should be in set:<volumeset_name> format.
.PARAMETER LUNID
	Lun Id that is used for the mapping operation. If no LUN Is given, the command will try and detect the missing LUN by 
	searching the Array for the Volumename(set) and Hostname(set). 
.PARAMETER HostName
	Name of the host record to which the volume (or VolumeSet) is exported that should be removed.
.PARAMETER HostSetName
	Name of the hostset record to which the volume (or VolumeSet) is exported that should be removed.
.PARAMETER NSP
	Specifies the system port of the VLUN export in format #.#.# . It includes the system node number, PCI bus slot number, and card port number on the PCI
	card in the format:<node>.<slot>.<port> 
.PARAMETER Novcn
	Specifies that a VLUN Change Notification (VCN) not be issued after removal of the VLUN.
.EXAMPLE    
	Remove-A9vLun -VolumeName xxx -LUNID xx -HostName xxx
.EXAMPLE    
	Remove-A9vLun -VolumeSetName xxx -HostName xxx
.EXAMPLE    
	Remove-A9vLun -VolumeName xxx -LUNID xx -HostName xxx -NSP x.x.x	
.NOTES
	This command only uses WSAPI as the SSH version offers no extra options.
.
#>
[CmdletBinding(DefaultParameterSetName='APIvh')]

Param(	[Parameter(Mandatory, ParameterSetName='APIvh')]
		[Parameter(Mandatory, ParameterSetName='APIvhs')]	[String]	$Volume,
		
		[Parameter(Mandatory, ParameterSetName='APIvsh')]
		[Parameter(Mandatory, ParameterSetName='APIvshs')]	[String]	$VolumeSet,
		
		[Parameter(ParameterSetName='APIvh')]
		[Parameter(ParameterSetName='APIvhs')]
		[Parameter(ParameterSetName='APIvsh')]
		[Parameter(ParameterSetName='APIvshs')]				[int]		$LUNID,
		
		[Parameter(Mandatory, ParameterSetName='APIvh')]
		[Parameter(Mandatory, ParameterSetName='APIvsh')]	[String]	$HostName,

		[Parameter(Mandatory, ParameterSetName='APIvhs')]
		[Parameter(Mandatory, ParameterSetName='APIvshs')]	[String]	$HostSetName,

		[Parameter(ParameterSetName='APIvh')]
		[Parameter(ParameterSetName='APIvhs')]
		[Parameter(ParameterSetName='APIvsh')]
		[Parameter(ParameterSetName='APIvshs')]
		[ValidatePattern('\d+\.\d+\.\d+')]					[String]	$NSP,

		[Parameter(ParameterSetName='APIvh')]
		[Parameter(ParameterSetName='APIvhs')]
		[Parameter(ParameterSetName='APIvsh')]
		[Parameter(ParameterSetName='APIvshs')]				[boolean]	$NoVcn
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{   
	Write-Verbose "Running: Building uri to Remove-vLun_WSAPI  ."
	$uri = "/vluns/"
	if ($Volume)		{ $uri = $uri + $Volume 			}
	if ($VolumeSet)		{ $uri = $uri + "set:"+$VolumeSet 	}
	if ($LUNID)			{ $uri = $uri + ","+$LUNID 			}
	else 	{	# we need to detect the LUN ID given the Hostname and Volumename
				if ($Volume) 	{ $VX = $Volume  } else { $VX = 'set:'+$VolumeSet }
				if ($Hostname)	{ $HX = $Hostname} else { $HX = 'set:'+$HostSetName }
				write-verbose "No LUN ID Given, detected the LUN ID from the array."
				$LUNSet = (Get-A9vLun | Where-object {$_.volumename -like $VX } | where-object {$_.hostname -like $HX} | get-unique).lun
				write-verbose "THe retrieved LUN found was $LunSet"
				if ( -not $LUNSet ) 
					{  	write-error "The array could find no volume(set) and host(set) record that returns a valid LUN to use. Please check you parameters"
						return 
					} 
				 $uri = $uri + ","+$LUNSet
			}
	if ($Hostname)		{ $uri = $uri + ","+$HostName 		}
	if ($HostSetName)	{ $uri = $uri + ",set:"+$HostSetName}
	if ($NSP)			{ $uri = $uri + ","+$NSP			}	
	if ($NoVcn)			{ $uri = $uri + "?noVcn=$NoVCN"}
	$Result = $null
	Write-verbose "Request: Request to Remove-vLun_WSAPI : $CPGName (Invoke-A9API)." 
	$Result = Invoke-A9API -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			Write-verbose "SUCCESS: VLUN Successfully removed with Given Values [ VolumeName : $VolumeName $VolumeSetName | LUNID : $LUNID | HostName : $HostName $HostSetName | NSP : $NSP ]." 
			return $Result		
		}
	else
		{	write-error "While Removing VLUN with Given Values [ VolumeName : $VolumeName $VolumeSetName | LUNID : $LUNID | HostName : $HostName $HostSetName | NSP : $NSP ]. "
			return $Result.StatusDescription
		}    	
}		
}

Function New-A9vLun 
{
<#
.SYNOPSIS
	Creating a VLUN
.DESCRIPTION
	Creating a VLUN. Any user with Super or Edit role, or any role granted vlun_create permission, can perform this operation. 
	The command will only use the API to accomplish the task, if the API is unavalable this command will fail. 
.PARAMETER VolumeName
	Name of the volume or VV set to export.
.PARAMETER LUN
	Will assign the LUN ID number specified, however if LUN is not specified, then Autolun is assumed.	
.PARAMETER HostName  
	Name of the host or host set to which the volume or VV set is to be exported.
	You may either select a Host or a HostSet but not both. 
.PARAMETER HostSet
	Specifies the host set where the LUN is exported, using up to 31 characters in length. 
	You may either select a Host or a HostSet but not both. 
.PARAMETER NSP
	System port of VLUN exported to. It includes node number, slot number, and card port number. Specifies the system port of the virtual LUN export.
	node:  Specifies the system node, where the node is a number from 0 through 7.
	slot: Specifies the PCI bus slot in the node, where the slot is a number from 0 through 5.
	port: Specifies the port number on the FC card, where the port number is 1 through 4.
	If no host or hostname is specified, the exported LUN will be visible to all devices on those ports
.PARAMETER NoVcn
	Specifies that a VCN not be issued after export (-novcn). Default: false.
.PARAMETER volumeName 
	Specifies the virtual volume or virtual volume set name, using up to 31 characters in length. 
	The volume name is provided in the syntax of basename. Ether a Volume or Volume Set can be specified but not both.
.PARAMETER volumeSet 
	Specifies the virtual volume or virtual volume set name, using up to 31 characters in length. The volume name is provided in the syntax of basename.
	Ether a Volume or Volume Set can be specified but not both.
.PARAMETER LUN
	Specifies the LUN as an integer from 0 through 16383. Alternatively n+ can be used to indicate a LUN should be auto assigned, but be
	a minimum of n, or m-n to indicate that a LUN should be chosen in the range m to n. In addition the keyword auto may be used and is treated as 0+.
.PARAMETER NoVcn
	Specifies that a VLUN Change Notification (VCN) not be issued after export. For direct connect or loop configurations, a VCN consists of a
	Fibre Channel Loop Initialization Primitive (LIP). For fabric configurations, a VCN consists of a Registered State Change
	Notification (RSCN) that is sent to the fabric controller.
.PARAMETER OverRide
	Specifies that existing lower priority VLUNs will be overridden, if necessary. Can only be used when exporting to a specific host.
.EXAMPLE
	PS:> New-A9vLun -VolumeName MyVolume1 -LUN 2 -HostName MyServer1 -NSP 1:3:1

	This command will connect the host record with the name MyServer to the MyVolume1 voolume using the array port 1:3:1, and will assign the LUN number 2
.EXAMPLE
	PS:> New-A9vLun -VolumeName MyVolume2 -HostSet MyServerCluster -NSP 1:3:1

	This command will connect the hostset with the record with the name MyServerCluster to the MyVolume2 voolume using the array port 1:3:1, and will assign the next available LUN
.NOTES
	This command requires that the WSAPI is available as it will not use SSH. 
#>
[CmdletBinding(DefaultParameterSetName='APIvvName_HostSet')]

Param(	[Parameter(Mandatory, ParameterSetName='APIvvName_NSP')		]
		[Parameter(Mandatory, ParameterSetName='APIvvName_HostSet')	]
		[Parameter(Mandatory, ParameterSetName='APIvvName_HostName')]		[String]	$VolumeName,

		[Parameter(Mandatory, ParameterSetName='APIvvSet_NSP')		]
		[Parameter(Mandatory, ParameterSetName='APIvvSet_HostSet')	]
		[Parameter(Mandatory, ParameterSetName='APIvvSet_HostName')	]		[String]	$VolumeSet,		

		[Parameter(Mandatory, ParameterSetName='APIvvName_HostName')]
		[Parameter(Mandatory, ParameterSetName='APIvvSet_HostName')	]		[String]	$HostName,

		[Parameter(Mandatory, ParameterSetName='APIvvName_HostSet')]
		[Parameter(Mandatory, ParameterSetName='APIvvSet_HostSet')]			[String]	$HostSet,
		
		[Parameter(Mandatory, ParameterSetName='APIvvName_NSP')		]
		[Parameter(           ParameterSetName='APIvvName_HostSet')	]
		[Parameter(           ParameterSetName='APIvvName_HostName')]
		[Parameter(Mandatory, ParameterSetName='APIvvSet_NSP')		]
		[Parameter(           ParameterSetName='APIvvSet_HostSet')	]
		[Parameter(           ParameterSetName='APIvvSet_HostName')	]		[String]	$NSP,

		[Parameter()]														[Boolean]	$NoVcn,
		[Parameter()]														[int]		$LUN
		)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	write-verbose "Executing New-a9VVLun using $PSetName"
	if( $HostSet   -match "^set:") 	{ 	$HostSet   = $HostSet.substring(4)}
	if( $VolumeSet -match "^set:") 	{ 	$VolumeSet = $VolumeSet.substring(4)}
	write-verbose "API operational State Detected"
	$body = [ordered]@{}    
	if ( $VolumeName){	$body["volumeName"] ="$($VolumeName)"}
	if ( $VolumeSet){	$body["volumeName"] ="set:$($VolumeSet)"} 
	if ( $LUN ) 	{	$body["lun"] = $LUN 				}
	if ($HostName)	{ 	$body["hostname"] = "$($HostName)" 	}
	if ($HostSet)	{ 	$body["hostname"] = "set:$HostSet" 	}
					
	If ($NSP)		{	$NSPbody = @{} 
						$list = $NSP.split(":")
						$NSPbody["node"] = [int]$list[0]		
						$NSPbody["slot"] = [int]$list[1]
						$NSPbody["cardPort"] = [int]$list[2]		
						$body["portPos"] = $NSPbody		
					}
	If ($NoVcn) 	{	$body["noVcn"] = $NoVcn	}
	if (-not $LUN)	{	$body["lun"] = 0
						$body['autoLun'] = $true
						$body['maxAutoLun'] = 0	
					}
	$Result = $null
	$x = $body
	$x = $x | ConvertTo-Json
	write-verbose "The Body of the command will be `n $x"
	$Result = Invoke-A9API -uri '/vluns' -type 'POST' -body $body -verbose
	$status = $Result.StatusCode	
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return Get-A9vLun -VolumeName $VolumeName -LUNID $LUNID -HostName $HostName
		}
	else
		{	write-error "FAILURE : While Creating a VLUN" 
			return $Result.StatusDescription
		}	
}
}

