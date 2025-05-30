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
.PARAMETER WWN
	Querying volumes with Single or multiple WWNs. This option can only be used with a API type connection.
.PARAMETER UserCPG
	User CPG Name.  This option can only be used with a API type connection.
.PARAMETER SnapCPG
	Snp CPG Name 
.PARAMETER CopyOf
	Querying volume copies it required name of the vv to copy.  This option can only be used with a API type connection.
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
.PARAMETER DomainName 
    Queries volumes in the domain specified DomainName. The option can only be used with a SSH type connection
.PARAMETER CPGName
    Queries volumes that belongs to a given CPG. The option can only be used with a SSH type connection
.EXAMPLE
	PS:> Get-A9Vv | format-table

	Name                            CPG          Adm(MB) Snp(MB) Usr(MB) New_Adm(MB) New_Snp(MB) New_Usr(MB)
	----                            ---          ------- ------- ------- ----------- ----------- -----------
	dscc-test                       SSD_r6       256     1024    1024    0           0           0
	MySQLData                       SSD_r6       256     1024    1024    0           0           0
	Zertobm8                        SSD_r6       256     0       1024    0           0           0
	Zertobm9                        SSD_r6       256     0       1024    0           0           0
	HANA_data                       SSD_r6       256     1024    8192    0           0           0
	HANA_log                        SSD_r6       256     1024    8192    0           0           0
	HANA_shared                     SSD_r6       256     1024    8192    0           0           0
	pvc-ecf8054c-2c39-4e8d-afab-0ab mongok8s-dml 256     1024    25600   0           0           0
	pvc-a6b7fc1f-a7ff-4db8-8ee0-6cd mongok8s-dml 256     1024    23552   0           0           0
	pvc-5dab55d8-2e62-4579-bb74-c82 mongok8s-dml 256     1024    1024    0           0           0
	pvc-96e135f0-3736-447d-988a-75b mongok8s-dml 256     1024    1024    0           0           0
	pvc-e3c5a4f0-e58b-400c-81a9-6b5 mongok8s-dml 256     1024    1024    0
.EXAMPLE
	PS:> Get-A9Vv 

	Get the list of virtual volumes using a SSH methof
.EXAMPLE
	PS:> Get-A9Vv -useAPI -VVName MyVV

	Get the detail of given VV	
.EXAMPLE
	PS:> Get-A9Vv -useAPI -WWN XYZ

	Querying volumes with single WWN
.EXAMPLE
	PS:> Get-A9Vv -useAPI -WWN "XYZ,XYZ1,XYZ2,XYZ3"

	Querying volumes with multiple WWNs
.EXAMPLE
	PS:> Get-A9Vv -useAPI -WWN "XYZ,XYZ1,XYZ2,XYZ3" -UserCPG ABC 

	Querying volumes with multiple filters
.EXAMPLE
	PS:> Get-A9Vv -useAPI -WWN "XYZ" -SnapCPG ABC 

	Querying volumes with multiple filters
.EXAMPLE
	PS:> Get-A9Vv -useAPI -WWN "XYZ" -CopyOf MyVV 

	Querying volumes with multiple filters
.EXAMPLE
	PS:> Get-A9Vv -useAPI -ProvisioningType FULL  

	Querying volumes with Provisioning Type FULL
.EXAMPLE
	PS:> Get-A9Vv -useAPI -ProvisioningType TPVV  

	Querying volumes with Provisioning Type TPVV
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	[Parameter(ParameterSetName='API')]		
		[Parameter(ParameterSetName='SSH')]	[String]	$VVName,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$UseSSH,
		[Parameter(ParameterSetName='API')]	[String]	$WWN,
		[Parameter(ParameterSetName='API')]	[String]	$UserCPG,
		[Parameter(ParameterSetName='API')]	[String]	$SnapCPG,
		[Parameter(ParameterSetName='API')]	[String]	$CopyOf,
		[Parameter(ParameterSetName='API')]	
		[ValidateSet('FULL','TPW','SNP','PEER','UNKNOWN','TDVV','DDS')]
											[String]	$ProvisioningType,

		[Parameter(ParameterSetName='SSH')]	[String[]]	$DomainName,	
		[Parameter(ParameterSetName='SSH')]	[String[]]	$CPGName
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
            elseif ($PSCmdlet.ParameterSetName -eq 'ssh' )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process 
{	switch($PSetName)
	{	'API'	
				{	$Result = $null
					$dataPS = $null	
					$Query="?query=""  """	
					if($VVName)
						{	$uri = '/volumes/'+$VVName
							$Result = Invoke-A9API -uri $uri -type 'GET' 
							If($Result.StatusCode -eq 200)
								{	$dataPS = $Result.content | ConvertFrom-Json
									write-host "Cmdlet executed successfully" -foreground green
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
						{	if($ProvisioningType -eq "FULL")	{	$PEnum = 1	}
									if($ProvisioningType -eq "TPVV")	{	$PEnum = 2	}
									if($ProvisioningType -eq "SNP")		{	$PEnum = 3	}
									if($ProvisioningType -eq "PEER")	{	$PEnum = 4	}
									if($ProvisioningType -eq "UNKNOWN")	{	$PEnum = 5	}
									if($ProvisioningType -eq "TDVV")	{	$PEnum = 6	}
									if($ProvisioningType -eq "DDS")		{	$PEnum = 7	}	
							if($WWN -Or $UserCPG -Or $SnapCPG -Or $CopyOf)	{	$Query = $Query.Insert($Query.Length-3," OR provisioningType EQ $PEnum")	}
							else											{	$Query = $Query.Insert($Query.Length-3," provisioningType EQ $PEnum")	}
						}
					$uri = '/volumes'
					if($WWN -Or $UserCPG -Or $SnapCPG -Or $CopyOf -Or $ProvisioningType)	{	$uri = $uri+'/'+$Query }
					$Result = Invoke-A9API -uri '/volumes' -type 'GET' 
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
		'SSH'
				{	$GetvVolumeCmd = "showvvcpg"
					if ($DomainName)	{	$GetvVolumeCmd += " -domain $DomainName"	}	
					if ($vvName)		{	$GetvVolumeCmd += " $vvName"	}
					$Result = Invoke-A9CLICommand -cmds $GetvVolumeCmd
					write-verbose "The Raw output is `n$Result"
					# $Result = $Result | where-object 	{ ($_ -notlike '*total*') -and ($_ -notlike '*---*')} ## Eliminate summary lines
					if ( $Result.Count -gt 1)
						{	$tempFile = [IO.Path]::GetTempFileName()
							$s = 'Name,CPG,Adm(MiB),Data(MiB),New_Adm(Mib),New_Data(MiB)'
							Add-Content -Path $tempFile -Value $s
							foreach ($s in  $Result[2..($Result.count -3)] )
								{	$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
									$s= $s.Trim()	
									Add-Content -Path $tempFile -Value $s
								}
							$Result=Import-Csv $tempFile
							Remove-Item $tempFile
							if($CPGName){ $Result = $Result | where-object {$_.CPG -like $CPGName} }
						}	
					return $Result	
				}
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
.EXAMPLE	
	PS:> Remove-A9Vv_CLI -vvName PassThru-Disk -whatif

	Dry-run of deleted operation on vVolume named PassThru-Disk
.EXAMPLE	
	PS:> Remove-A9Vv_CLI -vvName VV1 -force -Snaponly
.EXAMPLE	
	PS:> Remove-A9Vv_CLI -vvName VV1 -force -Expired
.EXAMPLE		
	PS:> Remove-A9Vv_CLI -vvName PassThru-Disk -force

	Forcibly deletes vVolume named PassThru-Disk 
.PARAMETER vvName 
    Specify name of the volume to be removed. This parrameter is the only allowed parameter if using the API. All other variables require the usage of a SSH type connection
.PARAMETER whatif
    If present, perform a dry run of the operation and no VLUN is removed. Only valid for SSH type connections	
.PARAMETER Pat
    Specifies that specified patterns are treated as glob-style patterns and that all VVs matching the specified pattern are removed. Only valid for SSH type connections	
.PARAMETER Stale
	Specifies that all stale VVs can be removed. Only valid for SSH type connections	     
.PARAMETER  Expired
	Remove specified expired volumes. Only valid for SSH type connections	
.PARAMETER  Snaponly
	Remove the snapshot copies only. Only valid for SSH type connections	
.PARAMETER Cascade
	Remove specified volumes and their descendent volumes as long as none has an active VLUN. Only valid for SSH type connections	
.PARAMETER Nowait
	Prevents command blocking that is normally in effect until the vv is removed. Only valid for SSH type connections	
#>
[CmdletBinding(DefaultParameterSetName='API')]
	param(
		[Parameter(Mandatory, ParameterSetName='API')]
		[Parameter(Mandatory, ParameterSetName='SSH')]			[String]	$vvName,
		[Parameter(ParameterSetName='SSH')]						[Switch]	$whatif, 
		[Parameter(ParameterSetName='SSH')]						[Switch]	$Pat, 
		[Parameter(ParameterSetName='SSH')]						[Switch]	$Stale, 
		[Parameter(ParameterSetName='SSH')]						[Switch]	$Expired, 
		[Parameter(ParameterSetName='SSH')]						[Switch]	$Snaponly, 
		[Parameter(ParameterSetName='SSH')]						[Switch]	$Cascade, 
		[Parameter(ParameterSetName='SSH')]						[Switch]	$Nowait
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
{	switch ($PSetName )
		{	'API'		{	$uri = '/volumes/'+$VVName
							$Result = $null
							$Result = Invoke-A9API -uri $uri -type 'DELETE' 
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
			'SSH'		{	$ActionCmd = "removevv "
							if ($Nowait)	{	$ActionCmd += "-nowait "	}
							if ($Cascade)	{	$ActionCmd += "-cascade "	}
							if ($Snaponly)	{	$ActionCmd += "-snaponly "	}
							if ($Expired)	{	$ActionCmd += "-expired "	}
							if ($Stale)		{	$ActionCmd += "-stale "		}
							if ($Pat)		{	$ActionCmd += "-pat "		}
							if ($whatif)	{	$ActionCmd += "-dr "		}
							else			{	$ActionCmd += "-f "			}
							$successmsglist = @()
							$ListofLuns = Get-VvList -vvName $vvName
							if ($ListofLuns)
								{	foreach ($vVolume in $ListofLuns)
										{	$vName = $vVolume.Name
											if ($vName)
												{	$RemoveCmds = $ActionCmd + " $vName $($vVolume.Lun)"
													$Result1 = Invoke-A9CLICommand -cmds  $removeCmds
													if( ! (Test-A9CLIObject -objectType "vv" -objectName $vName -SANConnection $SANConnection))
														{	$successmsglist += "Success : Removing vv $vName"
														}
													else
														{	$successmsglist += "FAILURE : $Result1"
														}
													write-verbose "Removing Virtual Volumes with command $removeCmds" 
												}
										}
									return $successmsglist		
								}	
							else{	return "FAILURE : No vv $vvName found"	}
						}
		}
}
}

Function Remove-A9VvSet
{
<#
.SYNOPSIS
    Remove a Virtual Volume set or remove VVs from an existing set
.DESCRIPTION
	Removes a VV set or removes VVs from an existing set. This command incorporates both the API method as well as the CLI method of removing a Vv. If the only argument used is the VVName, the command will attempt to use the API
	to accomplish the task, if the API is unavalable or other parameters are used, the command will attempt to fail back to a SSH type connection to accomplish the goal.    
.EXAMPLE
    PS:> Remove-A9VvSet_CLI -vvsetName "MyVVSet"

	Remove a VV set "MyVVSet"
.EXAMPLE
    PS:> Remove-A9VvSet_CLI -vvsetName "MyVVSet"  -force

	Remove a VV set "MyVVSet"
.EXAMPLE
	PS:> Remove-A9VvSet_CLI -vvsetName "MyVVSet" -vvName "MyVV" -force

	Remove a single VV "MyVV" from a vvset "MyVVSet"
.PARAMETER vvsetName 
    Specify name of the vvsetName. This option must be set and is used for both API and SSH connections.
.PARAMETER vvName 
    Specify name of  a vv to remove from vvset. This option is only valid for SSH type connections.
.PARAMETER force
	If present, perform forcible delete operation. This option is only valid for SSH type connections.	
.PARAMETER pat
	Specifies that both the set name and VVs will be treated as glob-style patterns. This option is only valid for SSH type connections.
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	[Parameter(ParameterSetName='API', Mandatory=$true)]
		[Parameter(ParameterSetName='SSH', Mandatory=$true)]	[String]	$vvsetName,
		[Parameter(ParameterSetName='SSH')]						[String]	$vvName,
		[Parameter(ParameterSetName='SSH')]						[switch]	$force,
		[Parameter(ParameterSetName='SSH')]						[switch]	$Pat
	)	
Begin	
{	if ( $PSCmdlet.ParameterSetName -eq 'API' )
		{	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
				{	$PSetName = 'API'
				}
			else{	if ( Test-A9COnnection -ClientType 'SshCLient' -returnBoolean )
						{	$PSetName = 'SSH'
						}
				}
		}
		elseif ( $PSCmdlet.ParameterSetName -eq 'SSH' )	
		{	if ( Test-A9COnnection -ClientType 'SshCLient' -returnBoolean )
				{	$PSetName = 'SSH'
				}
			else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
					return
				}
		}
}
process
{	switch ( $PSetName )
	{	'API'	{
					$uri = '/volumesets/'+$VVSetName
					$Result = $null
					$Result = Invoke-A9API -uri $uri -type 'DELETE'
					$status = $Result.StatusCode
					if($status -eq 200)
					{	write-host "Cmdlet executed successfully" -foreground green
						return
					}
					else
					{	Write-Error "Failure:  While Removing virtual volume Set:$VVSetName " 
						return $Result.StatusDescription
					} 
				}
		'SSH'	{	if (!($force))
						{	return "FAILURE : no -force option is selected to remove vvset"		}
					$objType = "vvset"
					$objMsg  = "vv set"
					if ( -not ( Test-A9CLIObject -objectType $objType -objectName $vvsetName -objectMsg $objMsg -SANConnection $SANConnection)) 
						{	return "FAILURE : No vvset $vvSetName found"
						}
					else
						{	$RemovevvsetCmd ="removevvset "					
							if($force)	{	$RemovevvsetCmd += " -f "	}
							if($Pat)	{	$RemovevvsetCmd += " -pat "	}
							$RemovevvsetCmd += " $vvsetName "
							if($vvName)	{	$RemovevvsetCmd +=" $vvName"	}		
							$Result1 = Invoke-A9CLICommand -cmds  $RemovevvsetCmd
							if([string]::IsNullOrEmpty($Result1))
								{	if($vvName)	{	return  "Success : Removed vv $vvName from vvset $vvSetName"	}
									return  "Success : Removed vvset $vvSetName"
								}
							else
								{	return "FAILURE : While removing vvset $vvSetName $Result1"
								}
						}
			}
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
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -NewName zzz
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -ExpirationHours 2
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -OneHost $true
.EXAMPLE 
	PS:> Update-A9Vv -VVName xxx -SnapCPG xxx
.PARAMETER VVName
	Name of the volume being modified. The VVName is required and used in both the API version and SSH version of this command.
.PARAMETER Size
	Specifies the size in MB to be added to the volume user space. The size must be an integer in the range from 1 to 16T. This option uses the API, and no other options do.
.PARAMETER NewName
	New Volume Name. This parameter requires the use of the SSH type connection.
.PARAMETER Comment
	Additional informations about the volume. This parameter requires the use of the SSH type connection.
.PARAMETER WWN
	Specifies changing the WWN of the virtual volume a new WWN. This parameter requires the use of the SSH type connection.
	If the value of WWN is auto, the system automatically chooses the WWN based on the system serial number, the volume ID, and the wrap counter.
.PARAMETER UserCPG
	User CPG Name. This parameter requires the use of the SSH type connection.
.PARAMETER StaleSS
	True—Stale snapshots. If there is no space for a copyon- write operation, the snapshot can go stale but the host write proceeds without an error. 
	false—No stale snapshots. If there is no space for a copy-on-write operation, the host write fails. This parameter requires the use of the SSH type connection.
.PARAMETER OneHost
	True—Indicates a volume is constrained to export to one host or one host cluster. 
	false—Indicates a volume exported to multiple hosts for use by a cluster-aware application, or when port presents VLUNs are used. This parameter requires the use of the SSH type connection.
.PARAMETER ZeroDetect
	True—Indicates that the storage system scans for zeros in the incoming write data. 
	false—Indicates that the storage system does not scan for zeros in the incoming write data. This parameter requires the use of the SSH type connection.
.PARAMETER System
	True— Special volume used by the system. false—Normal user volume. This parameter requires the use of the SSH type connection.
.PARAMETER Caching
	This is a read-only policy and cannot be set. true—Indicates that the storage system is enabled for write caching, read caching, and read ahead for the volume. 
	false—Indicates that the storage system is disabled for write caching, read caching, and read ahead for the volume. This parameter requires the use of the SSH type connection.
.PARAMETER Fsvc
	This is a read-only policy and cannot be set. true —Indicates that File Services uses this volume. false —Indicates that File Services does not use this volume. This parameter requires the use of the SSH type connection.
.PARAMETER HostDIF
	Type of host-based DIF policy, 3PAR_HOST_DIF is for 3PAR host-based DIF supported, 
	STD_HOST_DIF is for Standard SCSI host-based DIF supported and NO_HOST_DIF is for Volume does not support host-based DIF. This parameter requires the use of the SSH type connection.
.PARAMETER SnapCPG
	Specifies the name of the CPG from which the snapshot space will be allocated. This parameter requires the use of the SSH type connection.
.PARAMETER SsSpcAllocWarningPct
	Enables a snapshot space allocation warning. A warning alert is generated when the reserved snapshot space of the volume exceeds 
	the indicated percentage of the volume size. This parameter requires the use of the SSH type connection.
.PARAMETER SsSpcAllocLimitPct
	Sets a snapshot space allocation limit. The snapshot space of the volume is prevented from growing beyond the indicated percentage of the volume size. This parameter requires the use of the SSH type connection.
.PARAMETER tpvv
	Create thin volume. This parameter requires the use of the SSH type connection.
.PARAMETER tdvv
.PARAMETER UsrSpcAllocWarningPct
	Create fully provisionned volume. This parameter requires the use of the SSH type connection.
.PARAMETER UsrSpcAllocLimitPct
	Space allocation limit. This parameter requires the use of the SSH type connection.
.PARAMETER ExpirationHours
	Specifies the relative time (from the current time) that the volume expires. Value is a positive integer with a range of 1–43,800 hours (1825 days). This parameter requires the use of the SSH type connection.
.PARAMETER RetentionHours
	Specifies the amount of time relative to the current time that the volume is retained. Value is a positive integer with a range of 1– 43,800 hours (1825 days). This parameter requires the use of the SSH type connection.
.PARAMETER Compression   
	Enables (true) or disables (false) creating thin provisioned volumes with compression. Defaults to false (create volume without compression). This parameter requires the use of the SSH type connection.
.PARAMETER RmSsSpcAllocWarning
	Enables (false) or disables (true) removing the snapshot space allocation warning. 
	If false, and warning value is a positive number, then set. This parameter requires the use of the SSH type connection.
.PARAMETER RmUsrSpcAllocWarning
	Enables (false) or disables (true) removing the user space allocation warning. If false, and warning value is a posi' This parameter requires the use of the SSH type connection.
.PARAMETER RmExpTime
	Enables (false) or disables (true) resetting the expiration time. If false, and expiration time value is a positive number, then set. This parameter requires the use of the SSH type connection.
.PARAMETER RmSsSpcAllocLimit
	Enables (false) or disables (true) removing the snapshot space allocation limit. If false, and limit value is 0, setting ignored. If false, and limit value is a positive number, then set. This parameter requires the use of the SSH type connection. 
.PARAMETER RmUsrSpcAllocLimit
	Enables (false) or disables (true)false) the allocation limit. If false, and limit value is a positive number, then set. This parameter requires the use of the SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(
	[Parameter(Mandatory=$true, ParameterSetName='API')]
	[Parameter(Mandatory=$true, ParameterSetName='SSH')]
															[String]	$VVname ,		
	[Parameter(Mandatory=$true, ParameterSetName='API')]		
										[String]	$Size ,
	[Parameter(ParameterSetName='SSH')]	[String]	$NewName,
	[Parameter(ParameterSetName='SSH')]	[String]	$Comment,
	[Parameter(ParameterSetName='SSH')]	[String]	$WWN,
	[Parameter(ParameterSetName='SSH')]	[int]		$ExpirationHours,
	[Parameter(ParameterSetName='SSH')]	[int]		$RetentionHours,
	[Parameter(ParameterSetName='SSH')]	[boolean]	$StaleSS ,
	[Parameter(ParameterSetName='SSH')]	[boolean]	$OneHost,
	[Parameter(ParameterSetName='SSH')]	[boolean]	$ZeroDetect,
	[Parameter(ParameterSetName='SSH')]	[boolean]	$System ,
	[Parameter(ParameterSetName='SSH')]	[boolean]	$Caching ,
	[Parameter(ParameterSetName='SSH')]	[boolean]	$Fsvc ,
	[Parameter(ParameterSetName='SSH')]	[ValidateSet('3PAR_HOST_DIF','STD_HOST_DIF','NO_HOST_DIF')]
										[string]	$HostDIF ,
	[Parameter(ParameterSetName='SSH')]	[String]	$SnapCPG,
	[Parameter(ParameterSetName='SSH')]	[int]		$SsSpcAllocWarningPct ,
	[Parameter(ParameterSetName='SSH')]	[int]		$SsSpcAllocLimitPct ,
	[Parameter(ParameterSetName='SSH')]	[String]	$UserCPG,
	[Parameter(ParameterSetName='SSH')]	[int]		$UsrSpcAllocWarningPct,
	[Parameter(ParameterSetName='SSH')]	[int]		$UsrSpcAllocLimitPct,
	[Parameter(ParameterSetName='SSH')]	[Boolean]	$RmSsSpcAllocWarning ,
	[Parameter(ParameterSetName='SSH')]	[Boolean]	$RmUsrSpcAllocWarning ,
	[Parameter(ParameterSetName='SSH')]	[Boolean]	$RmExpTime,
	[Parameter(ParameterSetName='SSH')]	[Boolean]	$RmSsSpcAllocLimit,
	[Parameter(ParameterSetName='SSH')]	[Boolean]	$RmUsrSpcAllocLimit
)
Begin 
{	if ( $PSCmdlet.ParameterSetName -eq 'API')
		{	if (	Test-A9Connection -ClientType 'API' -returnBoolean) 
				{	$PSSetName='API'	}
			else{	Test-A9COnnection -ClientType 'SshClient'
					$PSSetName='SSH'	
				}
		}
	else{	Test-A9COnnection -ClientType 'SshClient'
			$PSSetName = 'SSH'
		}
}
Process 
{	Switch($PSSetName)
	{	'API'	{	$cmd= "growvv -f "
					if ($VVname)	{	$cmd+=" $VVname "	}
					if ($Size)		{	$demo=$Size[-1]
										$de=" g | G | t | T "
										if($de -match $demo)	{	$cmd+=" $Size "	}
										else					{	return "Error: -Size $Size is Invalid Try eg: 2G  "	}
									}
					$Result = Invoke-A9CLICommand -cmds  $cmd
					return  $Result
				}
		'SSH'	
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
					$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
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
.PARAMETER VolumeWWN
	The Volume WWN of the volume to filter the results
.PARAMETER RemoteName
	The RemoteName of the volume to filter the results
.PARAMETER Serial
	The Serial of the volume to filter the results
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device. The format of this should be a three numbers seperated by colons. i.e. '1:3:4'
.PARAMETER Listcols
	List the columns available to be shown in the -showcols option described below (see 'clihelp -col showvlun' for help on each column).
.PARAMETER Showcols
	Explicitly select the columns to be shown using a comma-separated list of column names.  For this option the full column names are shown in
	the header. Run 'showvlun -listcols' to list the available columns. Run 'clihelp -col showvlun' for a description of each column.
.PARAMETER ShowWWN
	Shows the WWN of the virtual volume associated with the VLUN.
.PARAMETER ShowsPathSummary
	Shows path summary information for active VLUNs
.PARAMETER Hostsum
	Shows mount point, Bytes per cluster, capacity information from Host Explorer and user reserved space, VV size from showvv.
.PARAMETER ShowsActiveVLUNs
	Shows only active VLUNs.
.PARAMETER ShowsVLUNTemplates
	Shows only VLUN templates.
.PARAMETER LUN
	Specifies that only exports to the specified LUN are displayed. This specifier can be repeated to display information for multiple LUNs.
.PARAMETER Nodelist
	Requests that only VLUNs for specific nodes are displayed. The node list is specified as a series of integers separated by commas (for example
	0,1,2). The list can also consist of a single integer (for example 1).
.PARAMETER Slotlist
	Requests that only VLUNs for specific slots are displayed. The slot list is specified as a series of integers separated by commas (for example
	0,1,2). The list can also consist of a single integer (for example 1).
.PARAMETER Portlist
	Requests that only VLUNs for specific ports are displayed. The port list is specified as a series of integers separated by commas ((for example
	1,2). The list can also consist of a single integer (for example 1).
.PARAMETER Domain_name  
	Shows only the VLUNs whose virtual volumes are in domains with names that match one or more of the <domainname_or_pattern> options. This
	option does not allow listing objects within a domain of which the user is not a member. Multiple domain names or patterns can be repeated using
	a comma-separated list.
.EXAMPLE
	PS:> Get-A9vLun | format-table
	Cmdlet executed successfully

	lun volumeName     hostname remoteName       portPos                       type volumeWWN                        multipathing failedPathPol failedPathInterval active Subsystem_NQN
	--- ----------     -------- ----------       -------                       ---- ---------                        ------------ ------------- ------------------ ------ -------------
	1 dpesxicluvol.1 dpesxi03 51402EC001C82752 @{node=0; slot=3; cardPort=4}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
	1 dpesxicluvol.1 dpesxi03 51402EC001C82750 @{node=0; slot=3; cardPort=1}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
	1 dpesxicluvol.1 dpesxi03 51402EC001C82752 @{node=1; slot=3; cardPort=4}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
.EXAMPLE 
	PS:> Get-A9vLun -LUNID 1 -VolumeName dpesxicluvol.1 -nsp '1:3:4'-HostName dpesxi03 | format-table
	Cmdlet executed successfully

	lun volumeName     hostname remoteName       portPos                       type volumeWWN                        multipathing failedPathPol failedPathInterval active Subsystem_NQN
	--- ----------     -------- ----------       -------                       ---- ---------                        ------------ ------------- ------------------ ------ -------------
	1 dpesxicluvol.1 dpesxi03 51402EC001C82752 @{node=1; slot=3; cardPort=4}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
.EXAMPLE	
	PS:> Show-A9vLun_CLI -vvName XYZ 

	List LUN number and hosts/host sets of LUN XYZ
.EXAMPLE	
	PS:> Show-A9vLun_CLI -Listcols
.EXAMPLE	
	PS:> Show-A9vLun_CLI -Nodelist 1
.EXAMPLE	
	PS:> Show-A9vLun_CLI -DomainName Aslam_D	

#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	
		[Parameter(ParameterSetName='API')]
		[Parameter(ParameterSetName='SSH')]	[String]	$VolumeName,
		[Parameter(ParameterSetName='API')]	[int]		$LUNID,
		[Parameter(ParameterSetName='SSH')]
		[Parameter(ParameterSetName='API')]	[String]	$HostName,
		[Parameter(ParameterSetName='API')]	[String]	$RemoteName,
		[Parameter(ParameterSetName='API')]	[String]	$VolumeWWN,
		[Parameter(ParameterSetName='API')]	[String]	$Serial,		
		[Parameter(ParameterSetName='API')]	
		[ValidatePattern("[0-9]:[0-9]:[0-9]")][String]	$NSP,

		[Parameter(ParameterSetName='SSH')]	[switch]	$Listcols,
		[Parameter(ParameterSetName='SSH')]	[String]	$Showcols, 
		[Parameter(ParameterSetName='SSH')]	[switch]	$ShowsWWN,
		[Parameter(ParameterSetName='SSH')]	[switch]	$ShowsPathSummary,
		[Parameter(ParameterSetName='SSH')]	[switch]	$Hostsum,
		[Parameter(ParameterSetName='SSH')]	[switch]	$ShowsActiveVLUNs,
		[Parameter(ParameterSetName='SSH')]	[switch]	$ShowsVLUNTemplates,
		[Parameter(ParameterSetName='SSH')]	[String]	$LUN,
		[Parameter(ParameterSetName='SSH')]	[String]	$Nodelist,
		[Parameter(ParameterSetName='SSH')]	[String]	$Slotlist,
		[Parameter(ParameterSetName='SSH')]	[String]	$Portlist,
		[Parameter(ParameterSetName='SSH')]	[String]	$DomainName,
		[Parameter(ParameterSetName='SSH')] [switch]	$UseSSH	
	)
Begin 
{	if ( $PSCmdlet.ParameterSetName -eq 'API' )
		{	if ( (Test-A9Connection -CLientType 'API' -returnBoolean ) -and -not $UseSSH )
				{	$PSetName = 'API'
				}
			else{	if ( Test-A9Connection -ClientType 'SSH' -returnBoolean )
						{	$PSetName = 'SSH'
						}
				}
		}
		elseif ( $PSCmdlet.ParameterSetName -eq 'SSH' )	
		{	if ( Test-A9COnnection -ClientType 'SSH' -returnBoolean )
				{	$PSetName = 'SSH'
				}
			else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
					return
				}
		}
}
Process 
{	switch( $PsetName )
	{	
		'API'	{
					Write-Verbose "Request: Request to Get-vLun_WSAPI [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP] (Invoke-A9API)."
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
							if ( $RemoteName )	{	$dataPS = $dataPS | where-object {$_.remoteName -like $RemoteName }		}
							if ( $VolumeWWN )	{	$dataPS = $dataPS | where-object {$_.volumeWWN -like $VolumeWWN }		}
							if ( $Serial )		{	$dataPS = $dataPS | where-object {$_.serial -like $Serial }				}
							if ( $HostName )	{	$dataPS = $dataPS | where-object {$_.hostname -like $HostName }			}
							if ( $NSP )			{	$dataPS = $dataPS | where-object {($_.portPos).node 	-like $NSP.split(':')[0] }
													$dataPS = $dataPS | where-object {($_.portPos).slot 	-like $NSP.split(':')[1] }
													$dataPS = $dataPS | where-object {($_.portPos).cardPort -like $NSP.split(':')[2] }
												}
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
		'SSH'	{
					$cmd = "showvlun "
					if($Listcols)		{	$cmd += " -listcols " 	}
					if($Showcols)		{	$cmd += " -showcols $Showcols" }
					if($ShowsWWN)		{	$cmd += " -lvw " 	}
					if($ShowsPathSummary){	$cmd += " -pathsum " 	}
					if($Hostsum)		{	$cmd += " -hostsum " 	}
					if($ShowsActiveVLUNs){	$cmd += " -a " 	}
					if($ShowsVLUNTemplates){$cmd += " -t " 	}
					if($Hostname)		{	$cmd += " -host $Hostname" 	}
					if($VolumeName)		{	$cmd += " -v $VolumeName" 	}
					if($LUN)			{	$cmd += " -l $LUN" 	}
					if($Nodelist)		{	$cmd += " -nodes $Nodelist" 	}
					if($Slotlist)		{	$cmd += " -slots $Slotlist" 	}
					if($Portlist)		{	$cmd += " -ports $Portlist" 	}
					if($DomainName)		{	$cmd += " -domain $DomainName" 	}
					$Result = Invoke-A9CLICommand -cmds  $cmd
					return $Result
				}
	}
}
}

Function Remove-A9vLun
{
<#
.SYNOPSIS
	Removing a VLUN.
.DESCRIPTION
	Removing a VLUN. Any user with the Super or Edit role, or any role granted with the vlun_remove right, can perform this operation. The command will attempt to use the API to accomplish the task, if the API is unavalable or other parameters 
	are used, the command will attempt to fail back to a SSH type connection to accomplish the goal. You can force  the command to use the SSH type connection using the -UseSSH as a parameter.
.PARAMETER VolumeName
	Name of the volume or VV set to be exported.
	The VV set should be in set:<volumeset_name> format.
.PARAMETER LUNID
	Lun Id
.PARAMETER HostName
	Name of the host or host set to which the volume or VV set is to be exported. For VLUN of port type, the value is empty.
	The host set should be in set:<hostset_name> format.required if volume is exported to host or host set,or to both the host or host set and port
.PARAMETER NSP
	Specifies the system port of the VLUN export. It includes the system node number, PCI bus slot number, and card port number on the FC card in the format:<node>:<slot>:<port>
	required if volume is exported to port, or to both host and port .Notes NAME : Remove-A9vLun 
.PARAMETER whatif
    If present, perform a dry run of the operation and no VLUN is removed. You must select either WhatIf or Force. 
.PARAMETER force
	If present, perform forcible delete operation. This option is required unless you are running the WhatIf Option
.PARAMETER Novcn
	Specifies that a VLUN Change Notification (VCN) not be issued after removal of the VLUN.
	.PARAMETER Pat
	Specifies that the <VV_name>, <LUN>, <node:slot:port>, and <host_name> specifiers are treated as glob-style patterns and that all VLUNs matching the specified pattern are removed.
.PARAMETER Remove_All
	It removes all vluns associated with a VVOL Container.
.EXAMPLE    
	Remove-vLun_WSAPI -VolumeName xxx -LUNID xx -HostName xxx
.EXAMPLE    
	Remove-vLun_WSAPI -VolumeName xxx -LUNID xx -HostName xxx -NSP x:x:x	
.EXAMPLE
	PS:> Remove-A9vLun_CLI -volumeName PassThru-Disk -force

	Unpresent the virtual volume PassThru-Disk to all hosts
.EXAMPLE	
	PS:> Remove-A9vLun_CLI -volumeName PassThru-Disk -whatif 

	Dry-run of deleted operation on vVolume named PassThru-Disk
.EXAMPLE		
	PS:> Remove-A9vLun_CLI -volumeName PassThru-Disk -PresentTo INF01  -force

	Unpresent the virtual volume PassThru-Disk only to host INF01.	all other presentations of PassThru-Disk remain intact.
.EXAMPLE	
	PS:> Remove-A9vLun_CLI -hostname INF01 -force

	Remove all LUNS presented to host INF01
.EXAMPLE	
	PS:> Remove-A9vLun_CLI -volumeName CSV* -hostname INF01 -force

	Remove all LUNS started with CSV* and presented to host INF01
.EXAMPLE
	PS:> Remove-A9vLun_CLI -volumeName vol2 -force -Novcn
.EXAMPLE
	PS:> Remove-A9vLun_CLI -volumeName vol2 -force -Pat
.EXAMPLE
	PS:> Remove-A9vLun_CLI -volumeName vol2 -force -Remove_All   

	It removes all vluns associated with a VVOL Container.

#>
[CmdletBinding(DefaultParameterSetName='API')]

Param(	[Parameter(Mandatory=$true, ParameterSetName='SSHF')]
		[Parameter(Mandatory=$true, ParameterSetName='SSHW')]
		[Parameter(Mandatory=$true, ParameterSetName='API')]	[String]	$VolumeName,
		[Parameter(Mandatory=$true, ParameterSetName='API')]	[int]		$LUNID,
		[Parameter(Mandatory=$true, ParameterSetName='API')]
		[Parameter(Mandatory=$true, ParameterSetName='SSHF')]
		[Parameter(Mandatory=$true, ParameterSetName='SSHW')]	[String]	$HostName,
		[Parameter(ParameterSetName='API')]						[String]	$NSP,

		[Parameter(ParameterSetName='SSHF',Mandatory=$true)]	[Switch]	$force, 
		[Parameter(ParameterSetName='SSHW',Mandatory=$true)]	[Switch]	$whatif, 		

																[String]	$vvName,		
		[Parameter(ParameterSetName='SSHF')]
		[Parameter(ParameterSetName='SSHW')]					[Switch]	$Novcn,
		[Parameter(ParameterSetName='SSHF')]
		[Parameter(ParameterSetName='SSHW')]					[Switch]	$Pat,
		[Parameter(ParameterSetName='SSHF')]
		[Parameter(ParameterSetName='SSHW')]					[Switch]	$Remove_All,	
		[Parameter(ParameterSetName='SSHF')]
		[Parameter(ParameterSetName='SSHW')]					[switch]	$UseSSH
	)
Begin 
{	if ( $PSCmdlet.ParameterSetName -eq 'API' )
		{	if ( (Test-A9Connection -ClientType 'API' -returnBoolean) -and -not $UseSSH )
				{	$PSetName = 'API'
				}
			else{	if ( Test-A9Connection -ClientType 'SSHClient' -returnBoolean )
						{	$PSetName = 'SSH'
						}
				}
		}
		elseif ( $PSCmdlet.ParameterSetName -like "SSH*" )	
		{	if ( Test-A9COnnection -ClientType 'SSHClient' -returnBoolean )
				{	$PSetName = 'SSH'
				}
			else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
					return
				}
		}
}
Process 
{   switch ( $PSetName )
	{	'API'	{
					Write-Verbose "Running: Building uri to Remove-vLun_WSAPI  ."
					$uri = "/vluns/"+$VolumeName+","+$LUNID+","+$HostName
					if($NSP)
						{	$uri = $uri+","+$NSP
						}	
					$Result = $null
					Write-verbose "Request: Request to Remove-vLun_WSAPI : $CPGName (Invoke-A9API)." 
					$Result = Invoke-A9API -uri $uri -type 'DELETE'
					$status = $Result.StatusCode
					if($status -eq 200)
						{	write-host "Cmdlet executed successfully" -foreground green
							Write-verbose "SUCCESS: VLUN Successfully removed with Given Values [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP ]." 
							return $Result		
						}
					else
						{	write-error "While Removing VLUN with Given Values [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP ]. "
							return $Result.StatusDescription
						}    	
				}
		'SSH'	{
					if($HostName)	{	$ListofvLuns = Get-A9vLun -vvName $VolumeName -Hostname $HostName }
					else			{	$ListofvLuns = Get-A9vLun -vvName $VolumeName 	}
					if($ListofvLuns -match "FAILURE")	{	return "FAILURE : No vLUN $VolumeName found"	}
					$ActionCmd = "removevlun "
					if ($whatif)	{	$ActionCmd += "-dr "	}
					if($force)		{	$ActionCmd += "-f "		} 
					if ($Novcn)		{	$ActionCmd += "-novcn "	}
					if ($Pat)		{	$ActionCmd += "-pat "	}
					if($Remove_All)	{	$ActionCmd += " -set "	}
					if ($ListofvLuns)
						{	foreach ($vLUN in $ListofvLuns)
								{	$vName = $vLUN.Name
									if ($vName)
										{	$RemoveCmds = $ActionCmd + " $vName $($vLun.LunID) $($vLun.PresentTo)"
											$Result1 = Invoke-A9CLICommand -cmds  $RemoveCmds
											write-verbose "Removing Virtual LUN's with command $RemoveCmds" 
											if ($Result1 -match "Issuing removevlun")
												{	$successmsg += "Success: Unexported vLUN $vName from $($vLun.PresentTo)"
												}
											elseif($Result1 -match "Dry run:")
												{	$successmsg += $Result1
												}
											else
												{	$successmsg += "FAILURE : While unexporting vLUN $vName from $($vLun.PresentTo) "
												}				
										}
								}
							return $successmsg
						}
					else
						{	return "FAILURE : no vLUN found for $vvName presented to host $PresentTo"
						}	
				}		
	}
}
}

Function New-A9vLun 
{
<#
.SYNOPSIS
	Creating a VLUN
.DESCRIPTION
	Creating a VLUN. Any user with Super or Edit role, or any role granted vlun_create permission, can perform this operation. The command will attempt to use the API to accomplish the task, if the API is unavalable or other parameters 
	are used, the command will attempt to fail back to a SSH type connection to accomplish the goal. You can force  the command to use the SSH type connection using the -UseSSH as a parameter.
.PARAMETER VolumeName
	Name of the volume or VV set to export.
.PARAMETER LUNID
	LUN ID.	
.PARAMETER HostName  
	Name of the host or host set to which the volume or VV set is to be exported.
	The host set should be in set:hostset_name format.
.PARAMETER NSP
	System port of VLUN exported to. It includes node number, slot number, and card port number. Specifies the system port of the virtual LUN export.
	node:  Specifies the system node, where the node is a number from 0 through 7.
	slot: Specifies the PCI bus slot in the node, where the slot is a number from 0 through 5.
	port: Specifies the port number on the FC card, where the port number is 1 through 4.
.PARAMETER NoVcn
	Specifies that a VCN not be issued after export (-novcn). Default: false.
.PARAMETER vvName 
	Specifies the virtual volume or virtual volume set name, using up to 31 characters in length. 
	The volume name is provided in the syntax of basename.int.  The VV set name must start with "set:".
.PARAMETER vvSet 
	Specifies the virtual volume or virtual volume set name, using up to 31 characters in length. The volume name is provided in the syntax of basename.int.  
	The VV set name must start with "set:".
.PARAMETER LUN
	Specifies the LUN as an integer from 0 through 16383. Alternatively n+ can be used to indicate a LUN should be auto assigned, but be
	a minimum of n, or m-n to indicate that a LUN should be chosen in the range m to n. In addition the keyword auto may be used and is treated as 0+.
.PARAMETER HostSet
	Specifies the host set where the LUN is exported, using up to 31 characters in length. The set name must start with "set:".
.PARAMETER Cnt
	Specifies that a sequence of VLUNs, as specified by the num argument, are exported to the same system port and host that is created. The num
	argument can be specified as any integer. For each VLUN created, the .int suffix of the VV_name specifier and LUN are incremented by one.
.PARAMETER NoVcn
	Specifies that a VLUN Change Notification (VCN) not be issued after export. For direct connect or loop configurations, a VCN consists of a
	Fibre Channel Loop Initialization Primitive (LIP). For fabric configurations, a VCN consists of a Registered State Change
	Notification (RSCN) that is sent to the fabric controller.
.PARAMETER Ovrd
	Specifies that existing lower priority VLUNs will be overridden, if necessary. Can only be used when exporting to a specific host.

.EXAMPLE
	PS:> New-A9vLun -VolumeName xxx -LUNID x -HostName xxx

.EXAMPLE
	PS:> New-A9vLun -VolumeName xxx -LUNID x -HostName xxx -NSP 1:1:1
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	[Parameter(Mandatory=$true, ParameterSetName='API')]					[String]	$VolumeName,
		[Parameter(Mandatory=$true, ParameterSetName='API')]					[int]		$LUNID,

		[Parameter(ParameterSetName='SSHvvName_HostName', 	Mandatory=$true)]
		[Parameter(ParameterSetName='SSHvvSet_HostSet', 	Mandatory=$true)]
		[Parameter(ParameterSetName='API', 					Mandatory=$true)]	[String]	$HostName,

		[Parameter(ParameterSetName='SSHvvSet_NSP', 	 	Mandatory=$true)]
		[Parameter(ParameterSetName='SSHvvName_NSP', 		Mandatory=$true)]
		[Parameter(ParameterSetName='API')]										[String]	$NSP,

		[Parameter(ParameterSetName='SSHvvName_NSP')]										
		[Parameter(ParameterSetName='SSHvvName_HostSet')]										
		[Parameter(ParameterSetName='SSHvvName_HostName')]										
		[Parameter(ParameterSetName='SSHvvSet_NSP')]										
		[Parameter(ParameterSetName='SSHvvSet_HostSet')]										
		[Parameter(ParameterSetName='SSHvvSet_HostName')]	
		[Parameter(ParameterSetName='API')]										[Boolean]	$NoVcn = $false,

		[Parameter(ParameterSetName='SSHvvName_NSP', 			Mandatory=$true)]
		[Parameter(ParameterSetName='SSHvvName_HostSet', 		Mandatory=$true)]
		[Parameter(ParameterSetName='SSHvvName_HostName', 		Mandatory=$true)]	[String]	$vvName,

		[Parameter(ParameterSetName='SSHvvSet_NSP',  			Mandatory=$true)]	
		[Parameter(ParameterSetName='SSHvvSet_HostSet',  		Mandatory=$true)]	
		[Parameter(ParameterSetName='SSHvvSet_HostName', 		Mandatory=$true)]
		[ValidateScript({	if( $_ -match "^set:") { $true } else { throw "Valid vvSet Parameter must start with 'Set:'"} } )]	
																				[String]	$vvSet,

		[Parameter(ParameterSetName='SSHvvName_NSP',			Mandatory=$true)]										
		[Parameter(ParameterSetName='SSHvvName_HostSet', 	Mandatory=$true)]										
		[Parameter(ParameterSetName='SSHvvName_HostName', 	Mandatory=$true)]										
		[Parameter(ParameterSetName='SSHvvSet_NSP',  		Mandatory=$true)]										
		[Parameter(ParameterSetName='SSHvvSet_HostSet',  	Mandatory=$true)]										
		[Parameter(ParameterSetName='SSHvvSet_HostName', 	Mandatory=$true)]												
																				[String]	$LUN,

		[Parameter(ParameterSetName='SSHvvName_HostSet', 	Mandatory=$true)]
		[Parameter(ParameterSetName='SSHvvSet_HostSet',  	Mandatory=$true)]
		[ValidateScript({	if( $_ -match "^set:") { $true } else { throw "Valid vvSet Parameter must start with 'Set:'"} } )]	
																				[String]	$HostSet,

		[Parameter(ParameterSetName='SSHvvName_NSP')]										
		[Parameter(ParameterSetName='SSHvvName_HostSet')]										
		[Parameter(ParameterSetName='SSHvvName_HostName')]										
		[Parameter(ParameterSetName='SSHvvSet_NSP')]										
		[Parameter(ParameterSetName='SSHvvSet_HostSet')]										
		[Parameter(ParameterSetName='SSHvvSet_HostName')]	
																				[String]	$Cnt,

		[Parameter(ParameterSetName='SSHvvName_NSP')]										
		[Parameter(ParameterSetName='SSHvvName_HostSet')]										
		[Parameter(ParameterSetName='SSHvvName_HostName')]										
		[Parameter(ParameterSetName='SSHvvSet_NSP')]										
		[Parameter(ParameterSetName='SSHvvSet_HostSet')]										
		[Parameter(ParameterSetName='SSHvvSet_HostName')]	
																				[switch]	$Ovrd,
		[Parameter(ParameterSetName='SSHvvName_NSP')]										
		[Parameter(ParameterSetName='SSHvvName_HostSet')]										
		[Parameter(ParameterSetName='SSHvvName_HostName')]										
		[Parameter(ParameterSetName='SSHvvSet_NSP')]										
		[Parameter(ParameterSetName='SSHvvSet_HostSet')]										
		[Parameter(ParameterSetName='SSHvvSet_HostName')]
																				[Switch]	$UseSSH
		)
Begin 
{	if ( $PSCmdlet.ParameterSetName -eq 'API' )
		{	if ( (Test-A9Connection -ClientType 'API' -returnBoolean) -and -not $UseSSH )
				{	$PSetName = 'API'
				}
			else{	if ( Test-A9Connection -ClientType 'SSHClient' -returnBoolean )
						{	$PSetName = 'SSH'
						}
				}
		}
		elseif ( $PSCmdlet.ParameterSetName -like "SSH*" )	
		{	if ( Test-A9COnnection -ClientType 'SSHClient' -returnBoolean )
				{	$PSetName = 'SSH'
				}
			else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
					return
				}
		}
}
Process 
{	switch ( $PSetName)
	{	
		'API'	{	
					$body = @{}    
					$body["volumeName"] ="$($VolumeName)" 
					$body["lun"] =$LUNID
					$body["hostname"] ="$($HostName)" 
					If ($NSP) 
						{	$NSPbody = @{} 
							$list = $NSP.split(":")
							$NSPbody["node"] = [int]$list[0]		
							$NSPbody["slot"] = [int]$list[1]
							$NSPbody["cardPort"] = [int]$list[2]		
							$body["portPos"] = $NSPbody		
						}
					If ($NoVcn) 
						{	$body["noVcn"] = $NoVcn
						}
					$Result = $null
					$Result = Invoke-A9API -uri '/vluns' -type 'POST' -body $body 
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
		'SSH'	{
					$cmdVlun = " createvlun -f"
					if($Cnt)			{	$cmdVlun += " -cnt $Cnt "	}
					if($NoVcn)			{	$cmdVlun += " -novcn "	}
					if($Ovrd)			{	$cmdVlun += " -ovrd "	}	
					if($vvName)			{	$cmdVlun += " $vvName "	}
					if($vvSet)			{	$cmdVlun += " $vvSet "	}
					if($LUN)			{	$cmdVlun += " $LUN "	}
					if($NSP)			{	$cmdVlun += " $NSP "	}
					elseif($HostSet)	{	$cmdVlun += " $HostSet "	}
					elseif($HostName)	{	$cmdVlun += " $HostName "	}
					$Result1 = Invoke-A9CLICommand -cmds  $cmdVlun
					write-verbose "Presenting $vvName to server $item with the command --> $cmdVlun" 
					if($Result1 -match "no active paths")		{	$successmsg += $Result1	}
					elseif([string]::IsNullOrEmpty($Result1))	{	$successmsg += "Success : $vvName exported to host $objName`n"	}
					else										{	$successmsg += "FAILURE : While exporting vv $vvName to host $objName Error : $Result1`n"	}		
					return $successmsg
				}
	}
}
}

# SIG # Begin signature block
# MIIsVAYJKoZIhvcNAQcCoIIsRTCCLEECAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEClohhdorlO
# SV5B5nx+kko2GfV60baR2m4FhriOMKx/TZVw7F5zRS5N6c6NZ+TuoArrpSVVfD2Y
# uLh0ZjtrKtT6oIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQIw1oHXaLBDO2/3CVwjj0ULxnh5ui/vlw7coW/bnrE7K5TQ7N0KP/qUY
# IXliMUwhDveZaQJEWC9AdgOqZLbnJF0wDQYJKoZIhvcNAQEBBQAEggGAXRf6knIn
# oIodAfAvywaNkk1cvymFDaCaS9fUEH7acXntZvAS3DNfiQfGNuZXCfl1q8kcfVkU
# Z+bymNjbdmWieNvRAWh7yP8hXLDQ9GCJf0L68nbpvPifki1MuHYaH0Ws43I2sVDp
# qOC4OIpKDZJJhClt44xyQcAIc33RtoUzXh/bIHgAQwD2+B7JhB1LssNRaYepiYLQ
# XQ57wR8kjUv08DaoAs0tWWLfcDaO5NhQzUSoa1xMZqCYWpPK9M2LwRb69MhEv1Vf
# ofZSG6tNEAWrpn+X8J9otPhRdynCSOklz9yUnxDfnBqeP/u5i0JYb9eOmF+OSv23
# Lw/653VkkzzqfxV6jbtKSZUwC5hQKvZ40oT9fqA/SA0cMvxc44mgW6iDY1hd7HUG
# BfvKyEOZA6Djlo4hXrVFNGYuWdhq0l+IiH7Z4lCCFv8ey7G+AWmDDnSxIT5eGJ6c
# 4tGI0QbSRhzEpYiZU2OsvO306itZvGoXuResqmlu31JV2KSm8md7YvnmoYIXWjCC
# F1YGCisGAQQBgjcDAwExghdGMIIXQgYJKoZIhvcNAQcCoIIXMzCCFy8CAQMxDzAN
# BglghkgBZQMEAgIFADCBhwYLKoZIhvcNAQkQAQSgeAR2MHQCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDDAvZOEA9D5ZEfV8VIueGVwM18a1kBh00f/ZhvW
# JHy2T3ZTn1PHZ0P35KBS3W3t2GECEESjPl1d4c7pHQgXPiUcRuIYDzIwMjUwNTMw
# MDExNzMxWqCCEwMwgga8MIIEpKADAgECAhALrma8Wrp/lYfG+ekE4zMEMA0GCSqG
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
# AzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjUwNTMwMDExNzMxWjAr
# BgsqhkiG9w0BCRACDDEcMBowGDAWBBTb04XuYtvSPnvk9nFIUIck1YZbRTA3Bgsq
# hkiG9w0BCRACLzEoMCYwJDAiBCB2dp+o8mMvH0MLOiMwrtZWdf7Xc9sF1mW5BZOY
# Q4+a2zA/BgkqhkiG9w0BCQQxMgQw8/4ATzrVfB4kOUFqlZkIOMZUmiSdWnolYV0Q
# u4rI67umXWQmjjB4a1LRFcSo+NWUMA0GCSqGSIb3DQEBAQUABIICAC6t312LGtVY
# O7Fa9xR0mBDoezJPMr8R3klW0WyPgvi8Qqyh7ex2MgxNP98vOtzURaCpYVvZ093b
# zbh35V5QGdWJf2J0rU86KBAiVdxQOVgP4e8UNYqbDfC83jXQNmyoRXed7zx5hoFy
# FY3ymEieS+GaZacTgu2kq20GKuB51hDxlP5ibshtdUKVgPS3zz9/jOjjMaJ7cVAl
# orCXc8gVz53veGqxGmadoh8UuYISNmawmZ3JsPa73EF4B/pxZ12FSxWBjKw89xRp
# mKX7uelOCk85Mc2GqkZGZbuj+OtoaH2mJQzzi0JYTlX3/vAZxR4kfygFlYMLxdrY
# 6X8wpZdw2WxMbxO1BZVaLUb2lAH3vPoSw0k9ipmbvLxMZM5RrGWJQDGh371yoX2I
# +sq4MuwT4TV0+PEmUS6QGMYtpqSWxaTMmirp2G0RKMaHxQKLY5F1/74L2Joik4Z8
# Gsc7ZgFKurLWRu5kdn/GbidMccG/VUwGa/OFht12WvhcY7Iz2ouGrFkLNDTgQJXX
# hpk0fWWVmli680DED0vDceV94ETS5VxojSNcCbEX6mG7HFtjfr5lHWjNxSYYfa4f
# 2i631UqXqe0yXPDlrmS5F08pxNtl704UIqgteH9gSb4EcaQWnxuAvbB6ONLpj9hn
# qX98U21cLV5BXeuw/TxVfmwgnfXI9Dha
# SIG # End signature block
