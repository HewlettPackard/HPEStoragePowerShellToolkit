## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9Port 
{
<#
.SYNOPSIS	
	Get a single or List ports in the storage system.
.DESCRIPTION
	Get a single or List ports in the storage system.
.PARAMETER NSP
	Get a single or List ports in the storage system depanding upon the given type.
.EXAMPLE
	PS:> Get-A9Port

	Get list all ports in the storage system.
.EXAMPLE
	PS:> Get-A9Port -NSP 1:1:1

	Single port or given port in the storage system.
.EXAMPLE
	The command Get-A9FCPort has been removed, its functionality if replicated here
	
	PS:> (Get-A9Port).virtualPorts.portWWN
.EXAMPLE
	The command Get-FCPortToCSV has ben remove, its funcitonality if replicated here

	PS:> (Get-A9Port).virtualPorts.portWWN | convertto-CSV | out-file .\Test.csv
.NOTES
	Since the default formattter gets all ports on a single screen, and new descriptors have been added, you can easily filter out by the type of
	connection, thusly a connect type does not need to be a parameterized input. 

#>
[CmdletBinding(DefaultParameterSetName='Default')]
Param(	[Parameter(Mandatory,ParameterSetName='NSP')]	
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
		[String]	$NSP
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$uri = '/ports'
	if($NSP)	{	$uri = '/ports/'+$NSP	}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members			
		}
	if($dataPS.Count -gt 0)
		{	write-host "Cmdlet executed successfully" -foreground green
			$NewObj = @(    foreach( $Item in $DataPS)	
													{   $NewItem=@{PSTypeName = "HPE.A9Storage.Port"}

														$Enum = $Item.smartSANStatus
															Switch ($Enum)
																{   1	{   $desc = 'ENABLED'       }
																	2	{   $desc = 'DISABLED'  }
																	3	{   $desc = 'UNSUPPORTED'}
																	4	{   $desc = 'UNLICENSED'   }
																	99	{   $desc = 'UNKNOWN'    }
																}
															if ($Desc) 
																{   $NewItem['SmartSANStatusDescription'] = $Desc
																	remove-variable Desc -erroraction SilentlyContinue
																	remove-variable Enum -erroraction SilentlyContinue
																}

														$Enum = $Item.class2
															Switch ($Enum)
																{   1	{   $desc = 'ACK0'      }
																	2	{   $desc = 'ACK1'  	}
																	3	{   $desc = 'DISABLED'	}
																	99	{   $desc = 'UNKNOWN'   }
																}
															if ($Desc) 
																{   $NewItem['Class2Description'] = $Desc
																	remove-variable Desc -erroraction SilentlyContinue
																	remove-variable Enum -erroraction SilentlyContinue
																}

														$Enum = $Item.connectionType
															Switch ($Enum)
																{   1	{   $desc = 'LOOP'      }
																	2	{   $desc = 'POINT'  	}
																	3	{   $desc = 'LOOP-POINT'}
																	99	{   $desc = 'UNKNOWN'   }
																}
															if ($Desc) 
																{   $NewItem['ConnectionTypeDescription'] = $Desc
																	remove-variable Desc -erroraction SilentlyContinue
																	remove-variable Enum -erroraction SilentlyContinue
																}

														$Enum = $Item.ConnectionMode
															Switch ($Enum)
																{   1	{   $desc = 'DISK'      }
																	2	{   $desc = 'HOST'  	}
																	3	{   $desc = 'RCFC'		}
																	4	{   $desc = 'PEER'		}
																	99	{   $desc = 'UNKNOWN'   }
																}
															if ($Desc) 
																{   $NewItem['ConnectionModeDescription'] = $Desc
																	remove-variable Desc -erroraction SilentlyContinue
																	remove-variable Enum -erroraction SilentlyContinue
																}

														$Enum = $Item.Mode
															Switch ($Enum)
																{   1	{   $desc = 'SUSPENDED' }
																	2	{   $desc = 'TARGET'  	}
																	3	{   $desc = 'INITIATOR'	}
																	4	{   $desc = 'PEER'		}
																}
															if ($Desc) 
																{   $NewItem['ModeDescription'] = $Desc
																	remove-variable Desc -erroraction SilentlyContinue
																	remove-variable Enum -erroraction SilentlyContinue
																}
														$Enum = $Item.linkState
															Switch ($Enum)
																{  	1  {    $desc = 'CONFIG_WAIT'	}
																	2  {    $desc = 'ALPA_WAIT'		}
																	3  {    $desc = 'LOGIN_WAIT'	}
																	4  {    $desc = 'READY'			}
																	5  {    $desc = 'LOSS_SYNC'		}
																	6  {    $desc = 'ERROR_STATE'	}
																	7  {    $desc = 'XXX'			}
																	8  {    $desc = 'NONPARTICIPATE'}
																	9  {    $desc = 'COREDUMP'		}
																	10 {    $desc = 'OFFLINE'		}
																	11 {    $desc = 'FWDEAD'		}
																	12 {    $desc = 'IDLE_FOR_RESET'}
																	13 {    $desc = 'DHCP_IN_PROGRESS'}
																	14 {    $desc = 'PENDING_RESET'	}
																	15 {    $desc = 'NEW'			}
																	16 {    $desc = 'DISABLED'		}
																	17 {    $desc = 'DOWN'			}
																	18 {    $desc = 'FAILED'		}
																	19 {    $desc = 'PURGING'		}
																}
															if ($Desc) 
																{   $NewItem['LinkStateDescription'] = $Desc
																	remove-variable Desc -erroraction SilentlyContinue
																	remove-variable Enum -erroraction SilentlyContinue
																}
											
														$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
														$DataSetType = "HPE.A9Storage.Port"
														$NewItem.PSTypeNames.Insert(0,$DataSetType)
														$DataSetType = $DataSetType + ".TypeName"
														$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
														[PSCustomObject]$NewItem
													}
												)
			return $NewObj
		}
	else{	Write-Error "Failure:  While Executing Get-A9Port. " 
			return 
		}
}	
}

Function Get-A9PortDevice
{
<#
.SYNOPSIS	
	Get single or list of port devices in the storage system.
.DESCRIPTION
	Get single or list of port devices in the storage system.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device. If undeclared it will return all valid NSP combination values.
.EXAMPLE
	PS:> Get-A9PortDevices -NSP 1:1:1

	Get a list of port devices in the storage system.
.EXAMPLE
	PS:> Get-A9PortDevices 

	Multiple Port option Get a list of port devices in the storage system.
#>
[CmdletBinding()]
Param(	[Parameter(mandatory)]	
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
									[String]	$NSP	
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	if ( $NSP)	
		{	$Result = $null
			$dataPS = $null	
			$Query="?query=""  """
			$uri = '/portdevices/all/'+$NSP
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			If($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members			
				}	
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					$NewObj = @(    foreach( $Item in $DataPS)	
												{   $NewItem=@{PSTypeName = "HPE.A9Storage.PortDevice"}
													$NewItem['NSP'] = "$NSP"
													$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
													$DataSetType = "HPE.A9Storage.PortDevice"
													$NewItem.PSTypeNames.Insert(0,$DataSetType)
													$DataSetType = $DataSetType + ".TypeName"
													$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
													[PSCustomObject]$NewItem
												}
											)
					return $NewObj
				}
			else{	Write-Error "Failure:  While Executing Get-A9PortDevices. " 
					return 
				}
		}
	else 
		{	$ValidNSPs = @()
			foreach ( $PortItem in $( Get-A9Port | where-object {$_.portWWN} | where-object {$_.ModeDescription -like 'TARGET'} ) )
				{	$Disco= $portitem.portPos 
					[string]$Nodedisco 		= $($disco).node
					[string]$Slotdisco 		= $($disco).slot
					[string]$CardPortdisco 	= $($disco).cardPort
					[string]$NSPdisco 		= $Nodedisco + ":" + $Slotdisco + ":" + $CardPortdisco
					$ValidNSPs += $NSPDisco
				}
			$NewObjB = $(	foreach ( $NSPCombo in $ValidNSPs )
								{	Get-A9PortDevice -NSP $NSPCombo
								}	
						)
			return $NewObjB
		}
}	
}

Function Get-A9PortDeviceTDZ 
{
<#
.SYNOPSIS
	Get Single or list of port device target-driven zones.
.DESCRIPTION
	Get Single or list of port device target-driven zones.
.EXAMPLE
	PS:> Get-A9PortDeviceTDZ
	
	Display a list of port device target-driven zones.
.EXAMPLE
	PS:> Get-A9PortDeviceTDZ -NSP 0:0:0

	Get the information of given port device target-driven zones.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
#>
[CmdletBinding()]
Param(	[Parameter()]
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]		
		[String] 	$NSP
	)
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null
	$uri = '/portdevices/targetdrivenzones/'
	if ( $NSP )	{	$uri = $uri + $NSP }	
	$Result = Invoke-A9API -uri $uri -type 'GET' 	
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members			
			if($dataPS.Count -gt 0)
					{	write-host "Cmdlet executed successfully" -foreground green
						return $dataPS
					}
				else{	Write-Warning "The Command executed successfully but returned no items. " 
						return 
					}
		}
	else{	Write-Error "Failure:  While Executing Get-A9PortDeviceTDZ." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9FcSwitch
{
<#
.SYNOPSIS
	Get a list of all FC switches connected to a specified port.
.DESCRIPTION
	Get a list of all FC switches connected to a specified port.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device. 
	If unset, it will return all the valid NSP combinations
.EXAMPLE
	PS:> Get-A9FcSwitches -NSP 0:0:0
	
	Get a list of all FC switches connected to a specified port.
#>
[CmdletBinding()]
Param(	[Parameter()]	
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
		[String]	$NSP
)
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	if (-not $NSP)
	{	$ValidNSPs = @()
		foreach ( $PortItem in $( Get-A9Port | where-object {$_.portWWN} | where-object {$_.ModeDescription -like 'TARGET'} ) )
					{	$Disco= $portitem.portPos 
						[string]$Nodedisco 		= $($disco).node
						[string]$Slotdisco 		= $($disco).slot
						[string]$CardPortdisco 	= $($disco).cardPort
						[string]$NSPdisco 		= $Nodedisco + ":" + $Slotdisco + ":" + $CardPortdisco
						$ValidNSPs += $NSPDisco
					}
			$NewObjB = $(	foreach ( $NSPCombo in $ValidNSPs )
								{	Get-A9FcSwitch -NSP $NSPCombo 
								}	
						)
			return $NewObjB
	}
	else
	{	$uri = '/portdevices/fcswitch/'+$NSP
		$Result = Invoke-A9API -uri $uri -type 'GET'
		If($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					$NewObj = @(    foreach( $Item in $DataPS)	
													{   $NewItem=@{PSTypeName = "HPE.A9Storage.FCSwitch"}
														$NewItem['NSP'] = "$NSP"
														$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
														$DataSetType = "HPE.A9Storage.FCSwitch"
														$NewItem.PSTypeNames.Insert(0,$DataSetType)
														$DataSetType = $DataSetType + ".TypeName"
														$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
														[PSCustomObject]$NewItem
													}
												)
					return $NewObj
				}
			else{	Write-warning "The command executed successfullu but returned no items using port $NSP. " 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9FcSwitches." 
			return $Result.StatusDescription
		}
	}
}
}


