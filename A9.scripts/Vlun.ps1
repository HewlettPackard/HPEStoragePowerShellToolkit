## 	©2025 Hewlett Packard Enterprise Development LP


Function Get-A9vLun 
{
<#
.SYNOPSIS
	Get Single or list of VLun.
.DESCRIPTION
	Get Single or list of VLun.  This command incorporates both the API method as well as the CLI method of removing a Vv. 
	If the only argument used is the VVName, the command will attempt to use the API to accomplish the task, if the API is unavalable or other parameters 
	are used, the command will attempt to fail back to a SSH type connection to accomplish the goal. 
.PARAMETER Volume
	Name of the volume to filter the results. may be prefixed with 'set:', the name is a volume set name. Displays only VLUNs of virtual volumes that match <VV_name> or 
	glob-style patterns, or to the vv sets that match <VV-set> or glob-style patterns (see help on sub,globpat). The VV set name must start with "set:". Multiple volume names, vv sets or patterns can be
	repeated using a comma-separated list (for example -v <VV_name>, <VV_name>...).
.PARAMETER LUNID
	The LUN ID of the volume to filter the results, since a LUN number is seen by a host, you must specify the Hostname parameter also.
.PARAMETER HostName
	Name of the host to which the volume is to be exported.  The host set name must start with "set:". 
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE	
	PS:> Get-A9vLun_CLI -volume XYZ 

	List vlun details for all hosts connected to volume XYZ
.EXAMPLE	
	PS:> Get-A9vLun_CLI -volume XYZ -hostname abc

	List vlun details for the specific host connected to a specific lun
.EXAMPLE	
	PS:> Get-A9vLun -volume MyTestVol | where-object {$.serial -like "123456" }
	
	This is an example of how to replicate the functionality of the serial cli option. This command will return only vLuns that match that serial number
.EXAMPLE	
	PS:> Get-A9vLun -volume MyTestVol | where-object {$.active -like "True" }
	
	This is an example of how to replicate the functionality of the active cli option. This command will return only vLuns that are active
.EXAMPLE	
	PS:> Get-A9vLun -volume MyTestVol | where-object {$.portPos.node -like 3 }
	
	This is an example of how to replicate the functionality of the ports cli option. This command will return all vLuns that match the other parameters as well as match the port posistion of 3
.EXAMPLE	
	PS:> Get-A9vLun -volume MyTestVol | where-object {$.portPos.slot -like 4 }
	
	This is an example of how to replicate the functionality of the slots cli option. This command will return all vLuns that match the other parameters as well as match the slot posistion of 4
.EXAMPLE	
	PS:> Get-A9vLun -volume MyTestVol | where-object {$.portPos.card -like 0 }
	
	This is an example of how to replicate the functionality of the card cli option. This command will return all vLuns that match the other parameters as well as match the node value of 0
.NOTES 
	This command only uses the WSAPI connection method. 

#>
[CmdletBinding(DefaultParameterSetName='None')]
Param(	
		[Parameter(Mandatory, ParameterSetName='ByVolume')]
		[Parameter(Mandatory, ParameterSetName='ByBoth')]			[String]	$Volume,
		
		[Parameter(ParameterSetName='ByBoth')]	
		[Parameter(ParameterSetName='ByHostName')]					[int]		$LUNID,
		
		[Parameter(Mandatory, ParameterSetName='ByBoth')]	
		[Parameter(Mandatory, ParameterSetName='ByHostName')]		[String]	$HostName,
		[Parameter()]												[Switch]	$ShowAPI
	)
Begin 
{	Test-A9Connection -CLientType 'API' 
}
Process 
{	$dataPS = $null		
	write-verbose "Making URL call to /vluns"
	if ( $ShowAPI )
		{	$Result = Invoke-A9API -uri '/vluns' -type 'GET' -whatif
			return
		}
	$Result = Invoke-A9API -uri '/vluns' -type 'GET' 
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members			
		}		
	If($Result.StatusCode -eq 200)
		{	if ( $Volume )		{	$dataPS = $dataPS | where-object {$_.volumeName -like $Volume }		}
			if ( $LUNID )		{	$dataPS = $dataPS | where-object {$_.lun -like $LUNID }					}
			if ( $HostName )	{	$dataPS = $dataPS | where-object {$_.hostname -like $HostName }			}
			if($dataPS.Count -gt 0)
				{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
					$NewObj = @(    foreach( $Item in $dataPS)	
																{   $NewItem=@{PSTypeName = "HPE.A9Storage.vLun"}
																	$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
																			$Enum = $Item.'type'
																				Switch ($Enum)
																					{   1   {   $Desc = 'EMPTY'   }
																						2   {   $Desc = 'PORT' }
																						3   {   $Desc = 'HOST'      }
																						4   {   $Desc = 'MATCHED_SET'   }
																						99  {   $Desc = 'HOST_SET'  }
																					}
																				if ($Desc) 
																					{   $NewItem['typeDescription'] = $Desc
																						remove-variable $Desc -erroraction SilentlyContinue
																						remove-variable $Enum -erroraction SilentlyContinue
																					}
																			$Enum = $Item.'multipathing'
																				Switch ($Enum)
																					{   1   {   $Desc = 'UNKNOWN' }
																						2   {   $Desc = 'Round Robin'  }
																						3   {   $Desc = 'Failover' }
																					}
																				if ($Desc) 
																					{   $NewItem['multipathingDescription'] = $Desc
																						remove-variable $Desc -erroraction SilentlyContinue
																						remove-variable $Enum -erroraction SilentlyContinue
																					}
																			$Enum = $Item.'failedPathPol'
																				Switch ($Enum)
																					{   1   {   $Desc = 'UNKNOWN' }
																						2   {   $Desc = 'SCSI_TEST_UNIT_READY'  }
																						3   {   $Desc = 'INQUIRY' }
																						4   {   $Desc = 'READ_SECTOR0'  }
																					}
																				if ($Desc) 
																					{   $NewItem['failedPathPolDescription'] = $Desc
																						remove-variable $Desc -erroraction SilentlyContinue
																						remove-variable $Enum -erroraction SilentlyContinue
																					}
																	$DataSetType = "HPE.A9Storage.vLun"
																	$NewItem.PSTypeNames.Insert(0,$DataSetType)
																	$DataSetType = $DataSetType + ".TypeName"
																	$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
																	[PSCustomObject]$NewItem
																}
								)
					return $NewObj
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
.PARAMETER Volume
	Name of the volume which is exported which will be removed.
.PARAMETER VolumeSetName
	Name of the volumeset is be exported which will be removed.
	The VV set should be in set:<volumeset_name> format.
.PARAMETER LUNID
	Lun Id that is used for the mapping operation. If no LUN Is given, the command will try and detect the missing LUN by 
	searching the Array for the Volume(set) and Hostname(set). 
.PARAMETER HostName
	Name of the host record to which the volume (or VolumeSet) is exported that should be removed.
.PARAMETER HostSetName
	Name of the hostset record to which the volume (or VolumeSet) is exported that should be removed.
.PARAMETER NSP
	Specifies the system port of the VLUN export in format #.#.# . It includes the system node number, PCI bus slot number, and card port number on the PCI
	card in the format:<node>.<slot>.<port> 
.PARAMETER Novcn
	Specifies that a VLUN Change Notification (VCN) not be issued after removal of the VLUN.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE    
	Remove-A9vLun -Volume xxx -LUNID xx -HostName xxx
.EXAMPLE    
	Remove-A9vLun -VolumeSetName xxx -HostName xxx
.EXAMPLE    
	Remove-A9vLun -Volume xxx -LUNID xx -HostName xxx -NSP x.x.x	
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
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
															[String]	$NSP,

		[Parameter(ParameterSetName='APIvh')]
		[Parameter(ParameterSetName='APIvhs')]
		[Parameter(ParameterSetName='APIvsh')]
		[Parameter(ParameterSetName='APIvshs')]				[boolean]	$NoVcn,
		[Parameter()]										[Switch]	$ShowAPI
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{   
	Write-Verbose "Running: Building uri to Remove-A9vLun  ."
	$uri = "/vluns/"
	if ($Volume)		{ $uri = $uri + $Volume 			}
	if ($VolumeSet)		{ $uri = $uri + "set:"+$VolumeSet 	}
	if ($LUNID)			{ $uri = $uri + ","+$LUNID 			}
	else 	{	# we need to detect the LUN ID given the Hostname and Volume
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
	if ( $ShowAPI )
		{	$Result = Invoke-A9API -uri $uri -type 'DELETE' -whatif
			return
		}
	$Result = Invoke-A9API -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			Write-verbose "SUCCESS: VLUN Successfully removed with Given Values [ Volume : $Volume $VolumeSet | LUNID : $LUNID | HostName : $HostName $HostSetName | NSP : $NSP ]." 
			return $Result		
		}
	else
		{	write-error "While Removing VLUN with Given Values [ Volume : $Volume $VolumeSet | LUNID : $LUNID | HostName : $HostName $HostSetName | NSP : $NSP ]. "
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
.PARAMETER Volume
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
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE
	PS:> New-A9vLun -Volume MyVolume1 -LUN 2 -HostName MyServer1 -NSP 1:3:1

	This command will connect the host record with the name MyServer to the MyVolume1 voolume using the array port 1:3:1, and will assign the LUN number 2
.EXAMPLE
	PS:> New-A9vLun -Volume MyVolume2 -HostSet MyServerCluster -NSP 1:3:1

	This command will connect the hostset with the record with the name MyServerCluster to the MyVolume2 voolume using the array port 1:3:1, and will assign the next available LUN
.NOTES
	This command requires that the WSAPI is available as it will not use SSH. 
#>
[CmdletBinding(DefaultParameterSetName='APIvvName_HostSet')]

Param(	[Parameter(Mandatory, ParameterSetName='APIvvName_NSP')		]
		[Parameter(Mandatory, ParameterSetName='APIvvName_HostSet')	]
		[Parameter(Mandatory, ParameterSetName='APIvvName_HostName')]		[String]	$Volume,

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
		[Parameter(           ParameterSetName='APIvvSet_HostName')	]	
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
																			[String]	$NSP,

		[Parameter()]														[Boolean]	$NoVcn,
		[Parameter()]														[int]		$LUN,
		[Parameter()]														[Switch]	$ShowAPI
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
	if ( $Volume)	{	$body["volumeName"] ="$($Volume)"}
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
	if ( $ShowAPI )
		{	$Result = Invoke-A9API -uri '/vluns' -type 'POST' -body $body -whatif
			return
		}
	$Result = Invoke-A9API -uri '/vluns' -type 'POST' -body $body
	$status = $Result.StatusCode	
	if($status -eq 201)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return Get-A9vLun -Volume $Volume -LUNID $LUNID -HostName $HostName
		}
	else
		{	write-error "FAILURE : While Creating a VLUN" 
			return $Result.StatusDescription
		}	
}
}

