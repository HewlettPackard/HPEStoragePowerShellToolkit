﻿####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9Vv 
{
<#
.SYNOPSIS
	Get Single or list of virtual volumes.
.DESCRIPTION
	Get Single or list of virtual volumes.
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
	PS:> Get-A9Vv -useAPI 

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
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	[Parameter(ParameterSetName='API')]		
		[Parameter(ParameterSetName='SSH')]	[String]	$VVName,

		[Parameter(ParameterSetName='API',Mandatory=$true)]	[Switch]	$UseAPI,
		[Parameter(ParameterSetName='SSH',Mandatory=$true)]	[Switch]	$UseSSH,
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
{	if ( $UseAPI ) { Test-A9Connection -ClientType 'API'} 	 
	if ( $UseSSH ) { Test-A9Connection -ClientType 'SshClient'} 	 
}
Process 
{	switch($PSCmdlet.ParameterSetName)
	{	'API'	
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
		'SSH'
				{	$GetvVolumeCmd = "showvvcpg"
					if ($DomainName)	{	$GetvVolumeCmd += " -domain $DomainName"	}	
					if ($vvName)		{	$GetvVolumeCmd += " $vvName"	}
					$Result = Invoke-CLICommand -cmds $GetvVolumeCmd
					if($Result -match "no vv listed")	{	return "FAILURE: No vv $vvName found"	}
					$Result = $Result | where-object 	{ ($_ -notlike '*total*') -and ($_ -notlike '*---*')} ## Eliminate summary lines
					if ( $Result.Count -gt 1)
						{	$tempFile = [IO.Path]::GetTempFileName()
							$LastItem = $Result.Count -2  
							foreach ($s in  $Result[0..$LastItem] )
								{	$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
									$s= $s.Trim() -replace ',Adm,Snp,Usr,Adm,Snp,Usr',',Adm(MB),Snp(MB),Usr(MB),New_Adm(MB),New_Snp(MB),New_Usr(MB)' 	
									Add-Content -Path $tempFile -Value $s
								}
							if($CPGName){ Import-Csv $tempFile | where-object {$_.CPG -like $CPGName} }
							else 		{ Import-Csv $tempFile }
							Remove-Item $tempFile
						}	
					else{	return "FAILURE: No vv $vvName found error:$result "	}	
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
.PARAMETER force
	If present, perform forcible delete operation. Only valid for SSH type connections	
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
		[Parameter(Mandatory=$true, ParameterSetName='API')]
		[Parameter(Mandatory=$true, ParameterSetName='SSH')]	[String]	$vvName,
		[Parameter(ParameterSetName='SSH')]						[Switch]	$whatif, 
		[Parameter(ParameterSetName='SSH')]						[Switch]	$force, 
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
process	
{	switch ($PSetName )
		{	'API'		{	$uri = '/volumes/'+$VVName
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
			'SSH'		{	if (!(($force) -or ($whatif)))
								{	return "FAILURE : Specify -force or -whatif options to delete or delete dryrun of a virtual volume"
								}
							$ListofLuns = Get-VvList -vvName $vvName -SANConnection $SANConnection
							if($ListofLuns -match "FAILURE")	{	return "FAILURE : No vv $vvName found"	}
							$ActionCmd = "removevv "
							if ($Nowait)	{	$ActionCmd += "-nowait "	}
							if ($Cascade)	{	$ActionCmd += "-cascade "	}
							if ($Snaponly)	{	$ActionCmd += "-snaponly "	}
							if ($Expired)	{	$ActionCmd += "-expired "	}
							if ($Stale)		{	$ActionCmd += "-stale "		}
							if ($Pat)		{	$ActionCmd += "-pat "		}
							if ($whatif)	{	$ActionCmd += "-dr "		}
							else			{	$ActionCmd += "-f "			}
							$successmsglist = @()
							if ($ListofLuns)
								{	foreach ($vVolume in $ListofLuns)
										{	$vName = $vVolume.Name
											if ($vName)
												{	$RemoveCmds = $ActionCmd + " $vName $($vVolume.Lun)"
													$Result1 = Invoke-CLICommand -cmds  $removeCmds
													if( ! (Test-CLIObject -objectType "vv" -objectName $vName -SANConnection $SANConnection))
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
					$Result = Invoke-WSAPI -uri $uri -type 'DELETE'
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
					if ( -not ( Test-CLIObject -objectType $objType -objectName $vvsetName -objectMsg $objMsg -SANConnection $SANConnection)) 
						{	return "FAILURE : No vvset $vvSetName found"
						}
					else
						{	$RemovevvsetCmd ="removevvset "					
							if($force)	{	$RemovevvsetCmd += " -f "	}
							if($Pat)	{	$RemovevvsetCmd += " -pat "	}
							$RemovevvsetCmd += " $vvsetName "
							if($vvName)	{	$RemovevvsetCmd +=" $vvName"	}		
							$Result1 = Invoke-CLICommand -cmds  $RemovevvsetCmd
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

