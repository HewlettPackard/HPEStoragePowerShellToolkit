####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
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
.NOTES
	Since the default formattter gets all ports on a single screen, and new descriptors have been added, you can easily filter out by the type of
	connection, thusly a connect type does not need to be a parameterized input. 

#>
[CmdletBinding(DefaultParameterSetName='Default')]
Param(	[Parameter(Mandatory,ParameterSetName='NSP')]	[String]	$NSP
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
	else{	Write-Error "Failure:  While Executing Get-Port_WSAPI. " 
			return 
		}
}	
}

Function Get-A9IscsivLans 
{
<#
.SYNOPSIS	
	Querying iSCSI VLANs for an iSCSI port
.DESCRIPTION
	Querying iSCSI VLANs for an iSCSI port
.EXAMPLE
	PS:> Get-A9IscsivLans

	Get the status of all tasks
.EXAMPLE
	PS:> Get-A9IscsivLans -Type FS
.EXAMPLE
	PS:> Get-A9IscsivLans -NSP 1:0:1
.EXAMPLE	
	PS:> Get-A9IscsivLans -VLANtag xyz -NSP 1:0:1
.PARAMETER Type
	Port connection type.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
.PARAMETER VLANtag
	VLAN ID.
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$Type,
		[Parameter()]	[String]	$NSP,
		[Parameter()]	[String]	$VLANtag
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	if($Type)
		{	$count = 1
			$lista = $Type.split(",")
			foreach($sub in $lista)
				{	$Query = $Query.Insert($Query.Length-3," type EQ $sub")			
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$Query = $Query.Insert($Query.Length-3," OR ")
									$count = $count + 1
								}				
						}
				}	
			$uri = '/ports/'+$Query
		}
	else
		{	if($VLANtag)
				{	if(-not $NSP)	{	Return "N S P required with VLANtag."	}
					$uri = '/ports/'+$NSP+'/iSCSIVlans/'+$VLANtag
				}
			else{	if(-not $NSP)	{	Return "N S P required with VLANtag."	}
					$uri = '/ports/'+$NSP+'/iSCSIVlans/'
				}		
		}
	$Result = Invoke-A9API -uri $uri -type 'GET'

	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS
		}
	else{	Write-Error "Failure:  While Executing Get-A9IscsivLans." 
			return $Result.StatusDescription
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
[CmdletBinding(DefaultParameterSetName='none')]
Param(	[Parameter(mandatory, ParameterSetName='NSP')]	
		[ValidatePattern('\d{1}:\d{1}:\d{1}')] 			[String]	$NSP	
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
Param(	[Parameter()]	[String] 	$NSP
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
				else{	Write-Error "Failure:  While Executing Get-A9PortDeviceTDZ. " 
						return 
					}
		}
	else{	Write-Error "Failure:  While Executing Get-A9PortDeviceTDZ." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9FcSwitches 
{
<#
.SYNOPSIS
	Get a list of all FC switches connected to a specified port.
.DESCRIPTION
	Get a list of all FC switches connected to a specified port.
.EXAMPLE
	PS:> Get-A9FcSwitches -NSP 0:0:0
	
	Get a list of all FC switches connected to a specified port.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$NSP
)
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	if($NSP)
		{	$uri = '/portdevices/fcswitch/'+$NSP
			$Result = Invoke-A9API -uri $uri -type 'GET'
		}
	If($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-A9FcSwitches. " 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9FcSwitches." 
			return $Result.StatusDescription
		}
}
}

Function Set-A9ISCSIPort 
{
<#
.SYNOPSIS
	Configure iSCSI ports
.DESCRIPTION
	Configure iSCSI ports
.EXAMPLE    
	PS:> Set-A9ISCSIPort -NSP 1:2:3 -IPAdr 1.1.1.1 -Netmask xxx -Gateway xxx -MTU xx -ISNSPort xxx -ISNSAddr xxx
	
	Configure iSCSI ports for given NSP
.PARAMETER NSP 
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER IPAdr
	Port IP address
.PARAMETER Netmask
	Netmask for Ethernet
.PARAMETER Gateway
	Gateway IP address
.PARAMETER MTU
	MTU size in bytes
.PARAMETER ISNSPort
	TCP port number for the iSNS server
.PARAMETER ISNSAddr
	iSNS server IP address
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$NSP,
		[Parameter()]					[String]	$IPAdr,
		[Parameter()]					[String]	$Netmask,
		[Parameter()]					[String]	$Gateway,
		[Parameter()]					[Int]		$MTU,
		[Parameter()]					[Int]		$ISNSPort,
		[Parameter()]					[String]	$ISNSAddr
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$iSCSIPortInfobody = @{}
	If ($IPAdr) 		{ 	$iSCSIPortInfobody["ipAddr"] ="$($IPAdr)" 	}  
	If ($Netmask) 		{ 	$iSCSIPortInfobody["netmask"] ="$($Netmask)" 	}
	If ($Gateway) 		{ 	$iSCSIPortInfobody["gateway"] ="$($Gateway)" 	}
	If ($MTU) 			{ 	$iSCSIPortInfobody["mtu"] = $MTU	}
	If ($ISNSPort) 		{ 	$iSCSIPortInfobody["iSNSPort"] =$ISNSPort	}
	If ($ISNSAddr) 		{ 	$iSCSIPortInfobody["iSNSAddr"] ="$($ISNSAddr)" 	}	
	if($iSCSIPortInfobody.Count -gt 0){	$body["iSCSIPortInfo"] = $iSCSIPortInfobody 	}
    $Result = $null	
	$uri = '/ports/'+$NSP 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	Write-Error "Failure:  While Configuring iSCSI ports: $NSP " 
			return $Result.StatusDescription
		}
}
}

Function New-A9IscsivLan 
{
<#
.SYNOPSIS
	Creates a VLAN on an iSCSI port.
.DESCRIPTION
	Creates a VLAN on an iSCSI port.
.EXAMPLE
	PS:> New-A9IscsivLan -NSP 1:1:1 -IPAddress x.x.x.x -Netmask xx -VlanTag xx

	a VLAN on an iSCSI port
.PARAMETER NSP
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER IPAddress
	iSCSI port IPaddress
.PARAMETER Netmask
	Netmask for Ethernet
.PARAMETER VlanTag
	VLAN tag
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$NSP,
		[Parameter(Mandatory)]	[String]	$IPAddress,	  
		[Parameter(Mandatory)]	[String]	$Netmask,	
		[Parameter(Mandatory)]	[int]		$VlanTag
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["ipAddr"] = "$($IPAddress)"
	$body["netmask"] = "$($Netmask)"
	$body["vlanTag"] = $VlanTag   
    $Result = $null
	$uri = "/ports/"+$NSP+"/iSCSIVlans/"
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode	
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure:  While creating VLAN on an iSCSI port : $NSP" 
			return $Result.StatusDescription
		}	
}
}

Function New-A9IscsivLun 
{
<#
.SYNOPSIS
	Creates a VLAN on an iSCSI port.
.DESCRIPTION    
	Creates a VLAN on an iSCSI port.
.EXAMPLE
	PS:> New-A9IscsivLun -NSP 1:1:1 -IPAddress x.x.x.x -Netmask xx -VlanTag xx

	a VLAN on an iSCSI port	
.PARAMETER NSP
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER IPAddress
	iSCSI port IPaddress
.PARAMETER Netmask
	Netmask for Ethernet
.PARAMETER VlanTag
	VLAN tag
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$NSP,
		[Parameter(Mandatory)]	[String]	$IPAddress,	  
		[Parameter(Mandatory)]	[String]	$Netmask,	
		[Parameter(Mandatory)]	[int]		$VlanTag
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["ipAddr"] = "$($IPAddress)"
	$body["netmask"] = "$($Netmask)"
	$body["vlanTag"] = $VlanTag   
    $Result = $null
	$uri = "/ports/"+$NSP+"/iSCSIVlans/"
	$Result = Invoke-A9API -uri $uri -type 'POST' -body $body 
	$status = $Result.StatusCode	
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure:  While creating VLAN on an iSCSI port : $NSP" 
			return $Result.StatusDescription
		}	
}
}

Function Set-A9IscsivLan 
{
<#
.SYNOPSIS
	Configure VLAN on an iSCSI port
.DESCRIPTION
	Configure VLAN on an iSCSI port
.EXAMPLE    
	PS:> Set-A9IscsivLan -NSP 1:2:3 -IPAdr 1.1.1.1 -Netmask xxx -Gateway xxx -MTU xx -STGT xx -ISNSPort xxx -ISNSAddr xxx

	Configure VLAN on an iSCSI port
.PARAMETER NSP 
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER VlanTag 
	VLAN tag.
.PARAMETER IPAdr
	Port IP address
.PARAMETER Netmask
	Netmask for Ethernet
.PARAMETER Gateway
	Gateway IP address
.PARAMETER MTU
	MTU size in bytes
.PARAMETER STGT
	Send targets group tag of the iSCSI target.
.PARAMETER ISNSPort
	TCP port number for the iSNS server
.PARAMETER ISNSAddr
	iSNS server IP address
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$NSP,
		[Parameter(Mandatory)]	[int]		$VlanTag,	  
		[Parameter()]					[String]	$IPAdr,
		[Parameter()]					[String]	$Netmask,
		[Parameter()]					[String]	$Gateway,
		[Parameter()]					[Int]		$MTU,
		[Parameter()]					[Int]		$STGT,
		[Parameter()]					[Int]		$ISNSPort,
		[Parameter()]					[String]	$ISNSAddr
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	If ($IPAdr) 	{	$body["ipAddr"] ="$($IPAdr)" 	}  
	If ($Netmask) 	{ 	$body["netmask"] ="$($Netmask)" }
	If ($Gateway) 	{ 	$body["gateway"] ="$($Gateway)" }
	If ($MTU) 		{ 	$body["mtu"] = $MTU				}
	If ($MTU) 		{ 	$body["stgt"] = $STGT			}
	If ($ISNSPort) 	{ 	$body["iSNSPort"] =$ISNSPort	}
	If ($ISNSAddr) 	{ 	$body["iSNSAddr"] ="$($ISNSAddr)"}
    $Result = $null	
	$uri = "/ports/" + $NSP + "/iSCSIVlans/" + $VlanTag 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	Write-Error "Failure:  While Configuring VLAN on an iSCSI port : $NSP " 
			return $Result.StatusDescription
		}
}
}

Function Reset-A9IscsiPort 
{
<#
.SYNOPSIS
	Resetting an iSCSI port configuration
.DESCRIPTION
	Resetting an iSCSI port configuration
.EXAMPLE
	PS:> Reset-A9IscsiPort -NSP 1:1:1 
.PARAMETER NSP
	The <n:s:p> parameter identifies the port you want to configure.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$NSP
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["action"] = 2
    $Result = $null
	$uri = '/ports/'+$NSP 
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode	
	if($status -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return $Result
	}
	else
	{	Write-Error "Failure:  While Resetting an iSCSI port configuration : $NSP" 
		return $Result.StatusDescription
	}	
}
}

Function Remove-A9IscsivLan
{
<#
.SYNOPSIS
	Removing an iSCSI port VLAN.
.DESCRIPTION
	Remove a File Provisioning Group.
.EXAMPLE    
	PS:> Remove-A9IscsivLan -NSP 1:1:1 -VlanTag 1 

	Removing an iSCSI port VLAN
.PARAMETER NSP 
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER VlanTag 
	VLAN tag.
#>
[CmdletBinding()]
Param(	[Parameter(omPipeline=$true)]							[String]	$NSP,
		[Parameter(Mandatory)]	[int]		$VlanTag
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$uri = "/ports/"+$NSP+"/iSCSIVlans/"+$VlanTag 
	$Result = $null
	$Result = Invoke-A9API -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 202)
		{	write-host "Cmdlet executed successfully" -foreground green
			return 
		}
	else
	{	Write-Error "Failure:  While Removing an iSCSI port VLAN : $NSP " 
		return $Result.StatusDescription
	}    
}
}
