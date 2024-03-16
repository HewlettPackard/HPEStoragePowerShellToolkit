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
.EXAMPLE
	PS:> Get-A9Port

	Get list all ports in the storage system.
.EXAMPLE
	PS:> Get-A9Port -NSP 1:1:1

	Single port or given port in the storage system.
.EXAMPLE
	PS:> Get-A9Port -Type HOST

	Single port or given port in the storage system.
.EXAMPLE	
	PS:> Get-A9Port -Type "HOST,DISK"
.PARAMETER NSP
	Get a single or List ports in the storage system depanding upon the given type.
.PARAMETER Type	
	Port connection type.
	HOST FC port connected to hosts or fabric.	
	DISK FC port connected to disks.	
	FREE Port is not connected to hosts or disks.	
	IPORT Port is in iport mode.
	RCFC FC port used for Remote Copy.	
	PEER FC port used for data migration.	
	RCIP IP (Ethernet) port used for Remote Copy.	
	ISCSI iSCSI (Ethernet) port connected to hosts.	
	CNA CNA port, which can be FCoE or iSCSI.	
	FS Ethernet File Persona ports.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Type
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	if($NSP)
		{	if($Type)
				{	write-error "FAILURE : While Executing Get-Port_WSAPI. Select only one from NSP : $NSP or Type : $Type" 
					return 
				}
			$uri = '/ports/'+$NSP
			$Result = Invoke-WSAPI -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
					write-host "Cmdlet executed successfully" -foreground green
					return $dataPS		
				}
			else{	Write-Error "Failure:  While Executing Get-Port_WSAPI." 
					return $Result.StatusDescription
				}
		}
	elseif($Type)
		{	$dict = @{}
			$dict.Add('HOST','1')
			$dict.Add('DISK','2')
			$dict.Add('FREE','3')
			$dict.Add('IPORT','4')
			$dict.Add('RCFC','5')
			$dict.Add('PEER','6')
			$dict.Add('RCIP','7')
			$dict.Add('ISCSI','8')
			$dict.Add('CNA','9')
			$dict.Add('FS','10')
			$count = 1
			$subEnum = 0
			$lista = $Type.split(",")
			foreach($sub in $lista)
				{	$subEnum = $dict.Get_Item("$sub")
					if($subEnum)
						{	$Query = $Query.Insert($Query.Length-3," type EQ $subEnum")			
							if($lista.Count -gt 1)
								{	if($lista.Count -ne $count)
										{	$Query = $Query.Insert($Query.Length-3," OR ")
											$count = $count + 1
										}				
								}
						}
				}
			$uri = '/ports/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET' 
			If($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members			
				}
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-Port_WSAPI. " 
					return 
				}
		}
	else
		{	$Result = Invoke-WSAPI -uri '/ports' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members	
					write-host "Cmdlet executed successfully" -foreground green
					return $dataPS		
				}
			else{	Write-Error "Failure:  While Executing Get-Port_WSAPI." 
					return $Result.StatusDescription
				} 
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
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Type,
		[Parameter(ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(ValueFromPipeline=$true)]	[String]	$VLANtag
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
	$Result = Invoke-WSAPI -uri $uri -type 'GET'

	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS
		}
	else{	Write-Error "Failure:  While Executing Get-IscsivLans_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9PortDevices 
{
<#
.SYNOPSIS	
	Get single or list of port devices in the storage system.
.DESCRIPTION
	Get single or list of port devices in the storage system.
.EXAMPLE
	PS:> Get-A9PortDevices -NSP 1:1:1

	Get a list of port devices in the storage system.
.EXAMPLE
	PS:> Get-A9PortDevices -NSP "1:1:1,0:0:0"
	Multiple Port option Get a list of port devices in the storage system.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True)]	[String]	$NSP
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	if($NSP)
		{	$lista = $NSP.split(",")
			if($lista.Count -gt 1)
				{	$count = 1
					foreach($sub in $lista)
						{	$Query = $Query.Insert($Query.Length-3," portPos EQ $sub")			
							if($lista.Count -gt 1)
								{	if($lista.Count -ne $count)
										{	$Query = $Query.Insert($Query.Length-3," OR ")
											$count = $count + 1
										}				
								}				
						}
					$uri = '/portdevices'+$Query
					$Result = Invoke-WSAPI -uri $uri -type 'GET' 
					If($Result.StatusCode -eq 200)
						{	$dataPS = ($Result.content | ConvertFrom-Json).members			
						}
					if($dataPS.Count -gt 0)
						{	write-host "Cmdlet executed successfully" -foreground green
							return $dataPS
						}
					else{	Write-Error "Failure:  While Executing Get-A9PortDevices." 
							return 
						}
				}
			else{	$uri = '/portdevices/all/'+$NSP
					$Result = Invoke-WSAPI -uri $uri -type 'GET' 
					If($Result.StatusCode -eq 200)
						{	$dataPS = ($Result.content | ConvertFrom-Json).members			
						}	
					if($dataPS.Count -gt 0)
						{	write-host "Cmdlet executed successfully" -foreground green
							return $dataPS
						}
					else{	Write-Error "Failure:  While Executing Get-A9PortDevices. " 
							return 
						}
				}
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
Param(	[Parameter(ValueFromPipeline=$true)]	[String] 	$NSP
	)
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null
	$uri = '/portdevices/targetdrivenzones/'
	if($NSP)	{	$uri = $uri+'/'+$NSP}	
	$Result = Invoke-WSAPI -uri  -type 'GET' 	
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$NSP
)
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	if($NSP)
		{	$uri = '/portdevices/fcswitch/'+$NSP
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
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
	Set-A9ISCSIPort -NSP 1:2:3 -IPAdr 1.1.1.1 -Netmask xxx -Gateway xxx -MTU xx -ISNSPort xxx -ISNSAddr xxx
	
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(ValueFromPipeline=$true)]					[String]	$IPAdr,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Netmask,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Gateway,
		[Parameter(ValueFromPipeline=$true)]					[Int]		$MTU,
		[Parameter(ValueFromPipeline=$true)]					[Int]		$ISNSPort,
		[Parameter(ValueFromPipeline=$true)]					[String]	$ISNSAddr
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
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$IPAddress,	  
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$Netmask,	
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[int]		$VlanTag
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
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$IPAddress,	  
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$Netmask,	
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[int]		$VlanTag
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
	$Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body 
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[int]		$VlanTag,	  
		[Parameter(ValueFromPipeline=$true)]					[String]	$IPAdr,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Netmask,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Gateway,
		[Parameter(ValueFromPipeline=$true)]					[Int]		$MTU,
		[Parameter(ValueFromPipeline=$true)]					[Int]		$STGT,
		[Parameter(ValueFromPipeline=$true)]					[Int]		$ISNSPort,
		[Parameter(ValueFromPipeline=$true)]					[String]	$ISNSAddr
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
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$NSP
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["action"] = 2
    $Result = $null
	$uri = '/ports/'+$NSP 
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
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
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[int]		$VlanTag
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$uri = "/ports/"+$NSP+"/iSCSIVlans/"+$VlanTag 
	$Result = $null
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE'
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
