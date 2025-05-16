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
Param(	[Parameter()]	[String]	$NSP,
		[Parameter()]	[String]	$Type
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
			$Result = Invoke-A9API -uri $uri -type 'GET' 
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
			$Result = Invoke-A9API -uri $uri -type 'GET' 
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
		{	$Result = Invoke-A9API -uri '/ports' -type 'GET' 
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
					$Result = Invoke-A9API -uri $uri -type 'GET' 
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
					$Result = Invoke-A9API -uri $uri -type 'GET' 
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
Param(	[Parameter()]	[String] 	$NSP
	)
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null
	$uri = '/portdevices/targetdrivenzones/'
	if($NSP)	{	$uri = $uri+'/'+$NSP}	
	$Result = Invoke-A9API -uri  -type 'GET' 	
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

# SIG # Begin signature block
# MIIsVQYJKoZIhvcNAQcCoIIsRjCCLEICAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABECkc7zMaw0n
# L2fJuTQ54a7sffL13+qdz/5Q0aNRpYRQ/qOOv3bPcxgG0kTld2xr+om/NMpkMn3u
# RHMj9cDQBYrNoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhIwghoOAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQGzILDKmQ7pPBQnFlDST4gHuCiF7VhfF3ihkDyyyV1bS0wHMOeBCpiPO
# g8r1qrTHqFVN6xgw1KbFUqrUtJcvQhMwDQYJKoZIhvcNAQEBBQAEggGAczcWjaga
# QN8cldMbH1UA6TPbW0H3DC3RWpkU9jBBfHLzO43847ZtvCSME/fRyvVcXpXFbLuP
# kTYv+gSydAxza190YX0r4/ms9xuTSDdUCQJZLImaGNBSa5M2uzKtkNaRX1yR6eWc
# 3Gp9tKxEkpWwXsXIBtTukJsNULHjgtxEJS+8jdxBhH8du6wIuu6TkLcdly03j0+o
# NOEgoL8WEXdIOgjG3dcSCDIHukSJ3Qr6xjq2I7H5NTIwmZkUQD6YJUizJwU/avC/
# yDmemY1N7rDAZC7BiK3kbC44OKiajFYKOxr3mWpp3N3a6Ttzrk1GQe9jdC9PMRGY
# 7gkdKskTTCftdzDsDF98bnUXd3eljbgeHmUA6lQafdrI1RciOhWitwt/kp4R2uFJ
# QcICOo/PN3rQdk+hKKXOTW2omeD0EeZaE0A69PpEkcne02GKvthdk61ZeddDamq/
# 2+XJcTPx/2gm8W7Z+/FE75evFuJtaMAMFc8zIY96jQJXvXv+HV78c+15oYIXWzCC
# F1cGCisGAQQBgjcDAwExghdHMIIXQwYJKoZIhvcNAQcCoIIXNDCCFzACAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDBVZ+cKiYv8FBPcWY0BIS5Ln0uwUTZG/zLaKSHi
# BVkvGhIFoDkTwS4rdlf+kNtT6eoCEQDfCD5g+V6En6WAB9XsvfA4GA8yMDI1MDUx
# NTIyNTQ1M1qgghMDMIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVow
# QjELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdp
# Q2VydCBUaW1lc3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL5qc5/2lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L
# 660x5XltSVhhK64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLusl
# xdr9Qq82aKcpA9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7a
# vVnpUVmPvkxT8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl
# 7/r419CvEYVIrH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+N
# BikDO0mlUh902wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVki
# qLq+ISTdEjJKGjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5
# n10jxmGpxoMc6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h
# 6gYldp4FCMgrXdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNe
# REXAu2xUDEW8aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLq
# fY/M/SdV6mwWTyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIB
# hzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggr
# BgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0j
# BBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGal
# Y17uT5IfdqBbMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBp
# bmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tO
# CB3RKE/P09x7gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSX
# gmUrDKNSQqGTdpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPn
# vIWrqVogK0qM8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM
# 2UeUUW/8z3fvjxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlT
# VYzqfLDbe9PpBKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ
# /xll/HjO9JbNVekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef
# 4uaZFORNekUgQHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk91
# 04WQzYuVNsxyoVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7
# ucykW7eaCuWBsBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZD
# BD+XgbF+23/zBjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3K
# eFUCS7tpFk7CrDqkMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkq
# hkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBU
# cnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFV
# xyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8z
# H1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE9
# 8NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iE
# ZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXm
# G6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVV
# JnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz
# +ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8
# ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkr
# qPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKo
# wSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3I
# XjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaA
# FOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4
# oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqG
# SIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQ
# XeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwI
# gqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs
# 5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAn
# gkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnG
# E4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9
# P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt
# +8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Z
# iza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgx
# tGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimH
# CUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCC
# BY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290
# IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE9
# 8orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9S
# H8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g
# 1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RY
# jgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgD
# EI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNA
# vwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDg
# ohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQA
# zH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOk
# GLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHF
# ynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gd
# LfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYE
# FOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# dDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkq
# hkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7
# IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/5
# 9PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0
# POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISf
# b8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhU
# LSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEBMHcwYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QQIQC65mvFq6f5WHxvnpBOMzBDANBglghkgBZQMEAgIFAKCB4TAaBgkqhkiG9w0B
# CQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI1MDUxNTIyNTQ1M1ow
# KwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQU29OF7mLb0j575PZxSFCHJNWGW0UwNwYL
# KoZIhvcNAQkQAi8xKDAmMCQwIgQgdnafqPJjLx9DCzojMK7WVnX+13PbBdZluQWT
# mEOPmtswPwYJKoZIhvcNAQkEMTIEMIiOeKPRbTuGZz8xq8lMP45m97SMIqGj2eA/
# UGJKRzIhhlFwUzAP0CyWzUwgB+eiETANBgkqhkiG9w0BAQEFAASCAgBv3Qfflsat
# MmG0XG6R+mL5AhoaT3nYWSeCdMeUq0kpJeBHcH+WlljkAW0irRiyLmSwqulB/dPp
# MW21zt99Hp5mxu3rwbrUKtBibTsYjWFp1gZ8PILg9Naa63nYGDWC5lOuh+e10sdu
# 2zlfveIYqCnmSc93V9iB6HWkQYWu4bCpJr6Hti331922xVgfb4/ejdlND4yykff7
# ZGFpP9yfZXQIXly5qGc2uFA8sgSPMMlvtJ0KmsefXESZ/B7FxMrO4jC1zq0uE3ug
# TxoMCrLideciO60I1fADpOY1EvyoZyZGVWwh8fY6NHdn6cer4WPr/xcpJ1gidF74
# ic1VrRvJERUkUNmoypbiyzUwBz3fa0/kJEdJd7ZF5OqUAMQUljznKF9LtH58kCG4
# rQ1UHPeRY1k2YbL/Xs3v8pFMIBNixyznqcGwLfLq0Xf/e7ZcNwPRBIcbGuGRPy+P
# mVQaqO9x7VA/YdzWORGunJSRJBC8qSBzOJoau3K/Xx9Tbk3vrI01GgDi7ZQUnr8u
# +2NOLhHngDlTkPrsNLNMK1qWhVRHnmn8Wq765wOol+6fjfrByWY3E+bMIsV2ig/W
# g/t19+L62WcomQWQiALc30cgGfb5+pr/JdyErSes+8vMcbzq+tOMHIODDfJ/pA7u
# BT7unMnfb4vEDDFP/Cu6l1xAdIUuGxkE7g==
# SIG # End signature block
