Function Set-A9IscsivLan 
{
<#
.SYNOPSIS
	Configure VLAN on an iSCSI port
.DESCRIPTION
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
.EXAMPLE    
	PS:> Set-A9IscsivLan -NSP 1:2:3 -IPAdr 1.1.1.1 -Netmask xxx -Gateway xxx -MTU xx -STGT xx 

	Configure VLAN on an iSCSI port
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]	
								[String]	$NSP,
		[Parameter(Mandatory)]	[int]		$VlanTag,	  
		[Parameter()]			[String]	$IPAddr,
		[Parameter()]			[String]	$Netmask,
		[Parameter()]			[String]	$Gateway,
		[Parameter()][ValidateRange(1501,9202)]
								[Int]		$MTU,
		[Parameter()]			[Int]		$STGT
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	If ($IPAddr) 	{	$body["ipAddr"] ="$($IPAddr)" 	}  
	If ($Netmask) 	{ 	$body["netmask"] ="$($Netmask)" }
	If ($Gateway) 	{ 	$body["gateway"] ="$($Gateway)" }
	If ($MTU) 		{ 	$body["mtu"] = $MTU				}
	If ($MTU) 		{ 	$body["stgt"] = $STGT			}

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
Param(	[Parameter()]	
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
								[String]	$NSP,
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

Function Get-A9IscsivLan
{
<#
.SYNOPSIS	
	Querying iSCSI VLANs for an iSCSI port
.DESCRIPTION
	Querying iSCSI VLANs for an iSCSI port
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device. if not given, the command will attempt to run 
	the command on all host target ports. 
.EXAMPLE
	PS:> Get-A9IscsivLans

	Get the VLANs for all NSP port combinations
.EXAMPLE
	PS:> Get-A9IscsivLans -NSP 1:0:1

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
	$Query="?query=""  """
	if ( -not $NSP)
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
								{	Get-A9iSCSIvLan -NSP $NSPCombo 
								}	
						)
			return $NewObjB
		}
	$uri = '/ports/'+$NSP+'/iSCSIVlans/'
	$Result = Invoke-A9API -uri $uri -type 'GET'

	if($Result.StatusCode -eq 200)
		{	if ( $dataPS.members ) 	{	$dataPS = ($Result.content | ConvertFrom-Json).members }
			if ($DataPS -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					$NewObj = @(    foreach( $Item in $DataPS)	
													{   $NewItem=@{PSTypeName = "HPE.A9Storage.iSCSIvLan"}
														$NewItem['NSP'] = $NSP

														$Enum = $Item.smartSANStatus
															Switch ($Enum)
																{   1	{   $desc = 'ENABLED'       }
																	2	{   $desc = 'DISABLED'  	}
																	3	{   $desc = 'UNSUPPORTED'	}
																	4	{   $desc = 'UNLICENSED' 	}
																	99	{   $desc = 'UNKNOWN'    	}
																}
															if ($Desc) 
																{   $NewItem['SmartSANStatusDescription'] = $Desc
																	remove-variable Desc -erroraction SilentlyContinue
																	remove-variable Enum -erroraction SilentlyContinue
																}

															$Enum = $Item.option
															Switch ($Enum)
																{   1	{   $desc = 'ENABLED'   }
																	2	{   $desc = 'DISABLED'  }
																	3	{   $desc = 'NA'		}
																	99	{   $desc = 'UNKNOWN'   }
																}
															if ($Desc) 
																{   $NewItem['OptionDescription'] = $Desc
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

														$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
														$DataSetType = "HPE.A9Storage.iSCSIvLan"
														$NewItem.PSTypeNames.Insert(0,$DataSetType)
														$DataSetType = $DataSetType + ".TypeName"
														$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
														[PSCustomObject]$NewItem
													}
												)
					return $NewObj
				}
			else
				{	Write-Warning "Cmdlet executed successfully however no iSCSVlans were returned using port $NSP" 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9IscsivLans." 
			return $Result.StatusDescription
		}
}	
}

Function Set-A9ISCSIPort 
{
<#
.SYNOPSIS
	Configure or reset an iSCSI port
.DESCRIPTION
	Configure or reset an iSCSI port
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
.PARAMETER Reset
	Will reset the iSCSI Port specified by the NSP value
.EXAMPLE    
	PS:> Set-A9ISCSIPort -NSP 1:2:3 -IPAdr 1.1.1.1 -Netmask xxx -Gateway xxx -MTU xx -ISNSPort xxx -ISNSAddr xxx
	
	Configure iSCSI ports for given NSP
#>
[CmdletBinding()]
Param(	[Parameter(ParameterSetName='set',Mandatory)]
		[Parameter(ParameterSetName='reset',Mandatory)]
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
															[String]	$NSP,

		[Parameter(ParameterSetName='set')]					[String]	$IPAdr,
		[Parameter(ParameterSetName='set')]					[String]	$Netmask,
		[Parameter(ParameterSetName='set')]					[String]	$Gateway,
		[Parameter(ParameterSetName='set')]
		[ValidateRange(1502,9202)]							[Int]		$MTU,
		[Parameter(ParameterSetName='set')]					[Int]		$ISNSPort,
		[Parameter(ParameterSetName='set')]					[String]	$ISNSAddr,
		[Parameter(ParameterSetName='reset',mandatory)]		[switch]	$Reset
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$Result = $null
	$uri = '/ports/'+$NSP
	Switch($PSCmdlet.ParameterSetName)
		{	'set'	{	$iSCSIPortInfobody = @{}
						If ($IPAdr) 		{ 	$iSCSIPortInfobody["ipAddr"] ="$($IPAdr)" 	}  
						If ($Netmask) 		{ 	$iSCSIPortInfobody["netmask"] ="$($Netmask)" 	}
						If ($Gateway) 		{ 	$iSCSIPortInfobody["gateway"] ="$($Gateway)" 	}
						If ($MTU) 			{ 	$iSCSIPortInfobody["mtu"] = $MTU	}
						If ($ISNSPort) 		{ 	$iSCSIPortInfobody["iSNSPort"] =$ISNSPort	}
						If ($ISNSAddr) 		{ 	$iSCSIPortInfobody["iSNSAddr"] ="$($ISNSAddr)" 	}	
						if($iSCSIPortInfobody.Count -gt 0){	$body["iSCSIPortInfo"] = $iSCSIPortInfobody 	}
						$Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
					}
			'reset'	{	$body["action"] = 2
						$Result = Invoke-A9API -uri $uri -type 'POST' -body $body	
					}
		}
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
Param(	[Parameter(Mandatory)]
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]		
								[String]	$NSP,
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
