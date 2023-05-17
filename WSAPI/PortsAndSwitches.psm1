####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
##	File Name:		PortsAndSwitches.psm1
##	Description: 	Ports and switches cmdlets 
##		
##	Created:		February 2020
##	Last Modified:	February 2020
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## FUNCTION Get-Port_WSAPI
############################################################################################################################################
Function Get-Port_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get a single or List ports in the storage system.
  
  .DESCRIPTION
	Get a single or List ports in the storage system.
        
  .EXAMPLE
	Get-Port_WSAPI
	Get list all ports in the storage system.
	
  .EXAMPLE
	Get-Port_WSAPI -NSP 1:1:1
	Single port or given port in the storage system.
	
  .EXAMPLE
	Get-Port_WSAPI -Type HOST
	Single port or given port in the storage system.
	
  .EXAMPLE	
	Get-Port_WSAPI -Type "HOST,DISK"
	
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-Port_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-Port_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Type,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	
	#Build uri
	if($NSP)
	{
		if($Type)
		{
			return "FAILURE : While Executing Get-Port_WSAPI. Select only one from NSP : $NSP or Type : $Type"
		}
		$uri = '/ports/'+$NSP
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		
		if($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-Port_WSAPI successfully Executed." $Info

			return $dataPS		
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-Port_WSAPI." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-Port_WSAPI. " $Info

			return $Result.StatusDescription
		}
	}
	elseif($Type)
	{
		$dict = @{}
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
		{	
			$subEnum = $dict.Get_Item("$sub")
			if($subEnum)
			{
				$Query = $Query.Insert($Query.Length-3," type EQ $subEnum")			
				if($lista.Count -gt 1)
				{
					if($lista.Count -ne $count)
					{
						$Query = $Query.Insert($Query.Length-3," OR ")
						$count = $count + 1
					}				
				}
			}
		}

		#Build uri
		$uri = '/ports/'+$Query
		
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{			
			$dataPS = ($Result.content | ConvertFrom-Json).members			
		}
		
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-Port_WSAPI successfully Executed." $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-Port_WSAPI. " -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-Port_WSAPI." $Info
			
			return 
		}
	}
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/ports' -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}	
			
		if($Result.StatusCode -eq 200)
		{		
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-Port_WSAPI successfully Executed." $Info

			return $dataPS		
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-Port_WSAPI." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-Port_WSAPI. " $Info

			return $Result.StatusDescription
		} 
	}
  }	
}
#END Get-Port_WSAPI

############################################################################################################################################
## FUNCTION Get-IscsivLans_WSAPI
############################################################################################################################################
Function Get-IscsivLans_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Querying iSCSI VLANs for an iSCSI port
  
  .DESCRIPTION
	Querying iSCSI VLANs for an iSCSI port
        
  .EXAMPLE
	Get-IscsivLans_WSAPI
	Get the status of all tasks
	
  .EXAMPLE
	Get-IscsivLans_WSAPI -Type FS
	
  .EXAMPLE
	Get-IscsivLans_WSAPI -NSP 1:0:1
	
  .EXAMPLE	
	Get-IscsivLans_WSAPI -VLANtag xyz -NSP 1:0:1
	
  .PARAMETER Type
	Port connection type.
  
  .PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
  
  .PARAMETER VLANtag
	VLAN ID.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : Get-IscsivLans_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-IscsivLans_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Type,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VLANtag,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	#Build uri
	if($Type)
	{
		$count = 1
		$lista = $Type.split(",")
		foreach($sub in $lista)
		{			
			$Query = $Query.Insert($Query.Length-3," type EQ $sub")			
			if($lista.Count -gt 1)
			{
				if($lista.Count -ne $count)
				{
					$Query = $Query.Insert($Query.Length-3," OR ")
					$count = $count + 1
				}				
			}
		}	
		
		$uri = '/ports/'+$Query
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}
	}
	else
	{
		if($VLANtag)
		{
			#Request
			if(-not $NSP)
			{
				Return "N S P required with VLANtag."
			}
			$uri = '/ports/'+$NSP+'/iSCSIVlans/'+$VLANtag
			
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)
			{
				$dataPS = $Result.content | ConvertFrom-Json
			}
		}
		else
		{
			if(-not $NSP)
			{
				Return "N S P required with VLANtag."
			}
			$uri = '/ports/'+$NSP+'/iSCSIVlans/'
			#Request
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)
			{
				$dataPS = ($Result.content | ConvertFrom-Json).members
			}
		}		
	}
		  
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Command Get-IscsivLans_WSAPI Successfully Executed" $Info
		
		return $dataPS
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-IscsivLans_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-IscsivLans_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-IscsivLans_WSAPI

############################################################################################################################################
## FUNCTION Get-PortDevices_WSAPI
############################################################################################################################################
Function Get-PortDevices_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get single or list of port devices in the storage system.
  
  .DESCRIPTION
	Get single or list of port devices in the storage system.
        
  .EXAMPLE
	Get-PortDevices_WSAPI -NSP 1:1:1
	Get a list of port devices in the storage system.
	
  .EXAMPLE
	Get-PortDevices_WSAPI -NSP "1:1:1,0:0:0"
	Multiple Port option Get a list of port devices in the storage system.
	
  .PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-PortDevices_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-PortDevices_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
      [String]
	  $NSP,
	  
	  [Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
		
	#Build uri
	if($NSP)
	{
		$lista = $NSP.split(",")
		
		if($lista.Count -gt 1)
		{
			$count = 1
			foreach($sub in $lista)
			{	
				$Query = $Query.Insert($Query.Length-3," portPos EQ $sub")			
				if($lista.Count -gt 1)
				{
					if($lista.Count -ne $count)
					{
						$Query = $Query.Insert($Query.Length-3," OR ")
						$count = $count + 1
					}				
				}				
			}
			
			#Build uri
			$uri = '/portdevices'+$Query
			
			#Request
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			If($Result.StatusCode -eq 200)
			{			
				$dataPS = ($Result.content | ConvertFrom-Json).members			
			}
			
			if($dataPS.Count -gt 0)
			{
				write-host ""
				write-host "Cmdlet executed successfully" -foreground green
				write-host ""
				Write-DebugLog "SUCCESS: Get-PortDevices_WSAPI successfully Executed." $Info
				
				return $dataPS
			}
			else
			{
				write-host ""
				write-host "FAILURE : While Executing Get-PortDevices_WSAPI." -foreground red
				write-host ""
				Write-DebugLog "FAILURE : While Executing Get-PortDevices_WSAPI." $Info
				
				return 
			}
		}
		else
		{		
			#Build uri
			$uri = '/portdevices/all/'+$NSP
			
			#Request
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			If($Result.StatusCode -eq 200)
			{			
				$dataPS = ($Result.content | ConvertFrom-Json).members			
			}	

			if($dataPS.Count -gt 0)
			{
				write-host ""
				write-host "Cmdlet executed successfully" -foreground green
				write-host ""
				Write-DebugLog "SUCCESS: Get-PortDevices_WSAPI successfully Executed." $Info
				
				return $dataPS
			}
			else
			{
				write-host ""
				write-host "FAILURE : While Executing Get-PortDevices_WSAPI. " -foreground red
				write-host ""
				Write-DebugLog "FAILURE : While Executing Get-PortDevices_WSAPI." $Info
				
				return 
			}
		}
	}	
  }	
}
#END Get-PortDevices_WSAPI

############################################################################################################################################
## FUNCTION Get-PortDeviceTDZ_WSAPI
############################################################################################################################################
Function Get-PortDeviceTDZ_WSAPI 
{
  <#
  .SYNOPSIS
	Get Single or list of port device target-driven zones.
  
  .DESCRIPTION
	Get Single or list of port device target-driven zones.
        
  .EXAMPLE
	Get-PortDeviceTDZ_WSAPI
	Display a list of port device target-driven zones.
	
  .EXAMPLE
	Get-PortDeviceTDZ_WSAPI -NSP 0:0:0
	Get the information of given port device target-driven zones.
	
  .PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Get-PortDeviceTDZ_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Get-PortDeviceTDZ_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection	 
  }

  Process 
  {
	Write-DebugLog "Request: Request to Get-PortDeviceTDZ_WSAPI NSP : $NSP (Invoke-WSAPI)." $Debug
    #Request
    
	$Result = $null
	$dataPS = $null		
	
	# Results
	if($NSP)
	{
		#Build uri
		$uri = '/portdevices/targetdrivenzones/'+$NSP
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}	
	}	
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/portdevices/targetdrivenzones/' -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{			
			$dataPS = ($Result.content | ConvertFrom-Json).members			
		}		
	}

	If($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
			{
				write-host ""
				write-host "Cmdlet executed successfully" -foreground green
				write-host ""
				Write-DebugLog "SUCCESS: Get-PortDeviceTDZ_WSAPI successfully Executed." $Info
				
				return $dataPS
			}
			else
			{
				write-host ""
				write-host "FAILURE : While Executing Get-PortDeviceTDZ_WSAPI. " -foreground red
				write-host ""
				Write-DebugLog "FAILURE : While Executing Get-PortDeviceTDZ_WSAPI." $Info
				
				return 
			}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-PortDeviceTDZ_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-PortDeviceTDZ_WSAPI. " $Info
		
		return $Result.StatusDescription
	}
  }
	End {}
}#END Get-PortDeviceTDZ_WSAPI

############################################################################################################################################
## FUNCTION Get-FcSwitches_WSAPI
############################################################################################################################################
Function Get-FcSwitches_WSAPI 
{
  <#
  .SYNOPSIS
	Get a list of all FC switches connected to a specified port.
  
  .DESCRIPTION
	Get a list of all FC switches connected to a specified port.
	
  .EXAMPLE
	Get-FcSwitches_WSAPI -NSP 0:0:0
	Get a list of all FC switches connected to a specified port.
	
  .PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Get-FcSwitches_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Get-FcSwitches_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection	 
  }

  Process 
  {
	Write-DebugLog "Request: Request to Get-FcSwitches_WSAPI NSP : $NSP (Invoke-WSAPI)." $Debug
    #Request
    
	$Result = $null
	$dataPS = $null		
	
	# Results
	if($NSP)
	{
		#Build uri
		$uri = '/portdevices/fcswitch/'+$NSP
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{
			#FC switches			
		}	
	}

	If($Result.StatusCode -eq 200)
	{		
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-FcSwitches_WSAPI successfully Executed." $Info
			
			return $dataPS
		}
		else
		{			
			write-host ""
			write-host "FAILURE : While Executing Get-FcSwitches_WSAPI. " -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-FcSwitches_WSAPI." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-FcSwitches_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-FcSwitches_WSAPI. " $Info
		
		return $Result.StatusDescription
	}
  }
	End {}
}#END Get-FcSwitches_WSAPI

############################################################################################################################################
## FUNCTION Set-ISCSIPort_WSAPI
############################################################################################################################################
Function Set-ISCSIPort_WSAPI 
{
  <#
  .SYNOPSIS
	Configure iSCSI ports
  
  .DESCRIPTION
	Configure iSCSI ports
        
  .EXAMPLE    
	Set-ISCSIPort_WSAPI -NSP 1:2:3 -IPAdr 1.1.1.1 -Netmask xxx -Gateway xxx -MTU xx -ISNSPort xxx -ISNSAddr xxx
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Set-ISCSIPort_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Set-ISCSIPort_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $IPAdr,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Netmask,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Gateway,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Int]
	  $MTU,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [Int]
	  $ISNSPort,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ISNSAddr,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
  
	$body = @{}
	$iSCSIPortInfobody = @{}
		
	If ($IPAdr) 
	{ 
		$iSCSIPortInfobody["ipAddr"] ="$($IPAdr)" 
	}  
	If ($Netmask) 
	{ 
		$iSCSIPortInfobody["netmask"] ="$($Netmask)" 
	}
	If ($Gateway) 
	{ 
		$iSCSIPortInfobody["gateway"] ="$($Gateway)" 
	}
	If ($MTU) 
	{ 
		$iSCSIPortInfobody["mtu"] = $MTU
	}
	If ($ISNSPort) 
	{ 
		$iSCSIPortInfobody["iSNSPort"] =$ISNSPort
	}
	If ($ISNSAddr) 
	{ 
		$iSCSIPortInfobody["iSNSAddr"] ="$($ISNSAddr)" 
	}
	
	if($iSCSIPortInfobody.Count -gt 0)
	{
		$body["iSCSIPortInfo"] = $iSCSIPortInfobody 
	}
    
    $Result = $null	
	$uri = '/ports/'+$NSP 
	
    #Request
	Write-DebugLog "Request: Request to Set-ISCSIPort_WSAPI : $NSP (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: iSCSI ports : $NSP successfully configure." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Set-ISCSIPort_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Configuring iSCSI ports: $NSP " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Configuring iSCSI ports: $NSP " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Set-ISCSIPort_WSAPI

############################################################################################################################################
## FUNCTION New-IscsivLan_WSAPI
############################################################################################################################################
Function New-IscsivLan_WSAPI 
{
  <#
  
  .SYNOPSIS
	Creates a VLAN on an iSCSI port.
	
  .DESCRIPTION
	Creates a VLAN on an iSCSI port.
	
  .EXAMPLE
	New-IscsivLan_WSAPI -NSP 1:1:1 -IPAddress x.x.x.x -Netmask xx -VlanTag xx
	a VLAN on an iSCSI port
	
  .PARAMETER NSP
	The <n:s:p> parameter identifies the port you want to configure.
  
  .PARAMETER IPAddress
	iSCSI port IPaddress
	
  .PARAMETER Netmask
	Netmask for Ethernet
	
  .PARAMETER VlanTag
	VLAN tag

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : New-IscsivLan_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: New-IscsivLan_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>
  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
      [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $IPAddress,	  
	  
	  [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $Netmask,	
	  
	  [Parameter(Position=3, Mandatory=$true, ValueFromPipeline=$true)]
      [int]
	  $VlanTag,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    # Creation of the body hash
	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}    
    $body["ipAddr"] = "$($IPAddress)"
	$body["netmask"] = "$($Netmask)"
	$body["vlanTag"] = $VlanTag   
    
    $Result = $null
	
    #Request
	$uri = "/ports/"+$NSP+"/iSCSIVlans/"
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode	
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: VLAN on an iSCSI port :$NSP created successfully" $Info		
		Write-DebugLog "End: New-IscsivLan_WSAPI" $Debug
		
		return $Result
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating VLAN on an iSCSI port : $NSP" -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While VLAN on an iSCSI port : $NSP" $Info
		Write-DebugLog "End: New-IscsivLan_WSAPI" $Debug
		
		return $Result.StatusDescription
	}	
  }
  End 
  {
  }  
}
#ENG New-IscsivLan_WSAPI

############################################################################################################################################
## FUNCTION New-IscsivLun_WSAPI
############################################################################################################################################
Function New-IscsivLun_WSAPI 
{
  <#
  
  .SYNOPSIS
	Creates a VLAN on an iSCSI port.
	
  .DESCRIPTION    
  	Creates a VLAN on an iSCSI port.
	
  .EXAMPLE
	New-IscsivLun_WSAPI -NSP 1:1:1 -IPAddress x.x.x.x -Netmask xx -VlanTag xx
	a VLAN on an iSCSI port
	
  .PARAMETER NSP
	The <n:s:p> parameter identifies the port you want to configure.
  
  .PARAMETER IPAddress
	iSCSI port IPaddress
	
  .PARAMETER Netmask
	Netmask for Ethernet
	
  .PARAMETER VlanTag
	VLAN tag

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : New-IscsivLun_WSAPI    
    LASTEDIT: 328/05/2020
    KEYWORDS: New-IscsivLun_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>
  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
      [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $IPAddress,	  
	  
	  [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $Netmask,	
	  
	  [Parameter(Position=3, Mandatory=$true, ValueFromPipeline=$true)]
      [int]
	  $VlanTag,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    # Creation of the body hash
	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}    
    $body["ipAddr"] = "$($IPAddress)"
	$body["netmask"] = "$($Netmask)"
	$body["vlanTag"] = $VlanTag   
    
    $Result = $null
	
    #Request
	$uri = "/ports/"+$NSP+"/iSCSIVlans/"
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode	
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: VLAN on an iSCSI port :$NSP created successfully" $Info		
		Write-DebugLog "End: New-IscsivLun_WSAPI" $Debug
		
		return $Result
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating VLAN on an iSCSI port : $NSP" -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While VLAN on an iSCSI port : $NSP" $Info
		Write-DebugLog "End: New-IscsivLun_WSAPI" $Debug
		
		return $Result.StatusDescription
	}	
  }
  End 
  {
  }  
}
#ENG New-IscsivLun_WSAPI

############################################################################################################################################
## FUNCTION Set-IscsivLan_WSAPI
############################################################################################################################################
Function Set-IscsivLan_WSAPI 
{
  <#
  .SYNOPSIS
	Configure VLAN on an iSCSI port
  
  .DESCRIPTION
	Configure VLAN on an iSCSI port
        
  .EXAMPLE    
	Set-IscsivLan_WSAPI -NSP 1:2:3 -IPAdr 1.1.1.1 -Netmask xxx -Gateway xxx -MTU xx -STGT xx -ISNSPort xxx -ISNSAddr xxx
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

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Set-IscsivLan_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Set-IscsivLan_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [int]
	  $VlanTag,	  
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $IPAdr,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Netmask,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Gateway,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [Int]
	  $MTU,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [Int]
	  $STGT,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [Int]
	  $ISNSPort,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ISNSAddr,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
  
	$body = @{}	
		
	If ($IPAdr) 
	{ 
		$body["ipAddr"] ="$($IPAdr)" 
	}  
	If ($Netmask) 
	{ 
		$body["netmask"] ="$($Netmask)" 
	}
	If ($Gateway) 
	{ 
		$body["gateway"] ="$($Gateway)" 
	}
	If ($MTU) 
	{ 
		$body["mtu"] = $MTU
	}
	If ($MTU) 
	{ 
		$body["stgt"] = $STGT
	}
	If ($ISNSPort) 
	{ 
		$body["iSNSPort"] =$ISNSPort
	}
	If ($ISNSAddr) 
	{ 
		$body["iSNSAddr"] ="$($ISNSAddr)" 
	}
    
    $Result = $null	
	$uri = "/ports/" + $NSP + "/iSCSIVlans/" + $VlanTag 
	
    #Request
	Write-DebugLog "Request: Request to Set-IscsivLan_WSAPI : $NSP (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully configure VLAN on an iSCSI port : $NSP ." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Set-IscsivLan_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Configuring VLAN on an iSCSI port : $NSP " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Configuring VLAN on an iSCSI port : $NSP " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Set-IscsivLan_WSAPI

############################################################################################################################################
## FUNCTION Reset-IscsiPort_WSAPI
############################################################################################################################################
Function Reset-IscsiPort_WSAPI 
{
  <#
  
  .SYNOPSIS
	Resetting an iSCSI port configuration
	
  .DESCRIPTION
	Resetting an iSCSI port configuration
	
  .EXAMPLE
	Reset-IscsiPort_WSAPI -NSP 1:1:1 
	
  .PARAMETER NSP
	The <n:s:p> parameter identifies the port you want to configure.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Reset-IscsiPort_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Reset-IscsiPort_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>
  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    # Creation of the body hash
	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}    
    $body["action"] = 2
    
    $Result = $null
	
    #Request
	$uri = '/ports/'+$NSP 
	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode	
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Reset an iSCSI port configuration $NSP" $Info		
		Write-DebugLog "End: Reset-IscsiPort_WSAPI" $Debug
		
		return $Result
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Resetting an iSCSI port configuration : $NSP" -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Resetting an iSCSI port configuration : $NSP" $Info
		Write-DebugLog "End: Reset-IscsiPort_WSAPI" $Debug
		
		return $Result.StatusDescription
	}	
  }
  End 
  {
  }  
}
#ENG Reset-IscsiPort_WSAPI

############################################################################################################################################
## FUNCTION Remove-IscsivLan_WSAPI
############################################################################################################################################
Function Remove-IscsivLan_WSAPI
 {
  <#
  .SYNOPSIS
	Removing an iSCSI port VLAN.
  
  .DESCRIPTION
	Remove a File Provisioning Group.
        
  .EXAMPLE    
	Remove-IscsivLan_WSAPI -NSP 1:1:1 -VlanTag 1 
	Removing an iSCSI port VLAN
	
  .PARAMETER NSP 
	The <n:s:p> parameter identifies the port you want to configure.

  .PARAMETER VlanTag 
	VLAN tag.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Remove-IscsivLan_WSAPI     
    LASTEDIT: February 2020
    KEYWORDS: Remove-IscsivLan_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0	
  #>
  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [int]
	  $VlanTag,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)
  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {    
	#Build uri
	Write-DebugLog "Running: Building uri to Remove-IscsivLan_WSAPI." $Debug
	
	$uri = "/ports/"+$NSP+"/iSCSIVlans/"+$VlanTag 
	
	$Result = $null

	#Request
	Write-DebugLog "Request: Request to Remove-IscsivLan_WSAPI : $NSP (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 202)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully remove an iSCSI port VLAN : $NSP" $Info
		Write-DebugLog "End: Remove-IscsivLan_WSAPI" $Debug
		
		return ""
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Removing an iSCSI port VLAN : $NSP " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Removing an iSCSI port VLAN : $NSP " $Info
		Write-DebugLog "End: Remove-IscsivLan_WSAPI" $Debug
		
		return $Result.StatusDescription
	}    
	
  }
  End {}  
}
#END Remove-IscsivLan_WSAPI


Export-ModuleMember Get-Port_WSAPI , Get-IscsivLans_WSAPI , Get-PortDevices_WSAPI , Get-PortDeviceTDZ_WSAPI , 
Get-FcSwitches_WSAPI , Get-IscsivLans_WSAPI , Set-ISCSIPort_WSAPI, Set-IscsivLan_WSAPI , New-IscsivLun_WSAPI , Reset-IscsiPort_WSAPI , Remove-IscsivLan_WSAPI
# SIG # Begin signature block
# MIIhEAYJKoZIhvcNAQcCoIIhATCCIP0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCxniVRRPgwTQMJ
# WEyFXhVsy68lPcXP0FiGFVPVSDVRmaCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPuzCCD7cCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# dLp+dAb20QjkI/GOhiUnpgxhGKd6YHdNEbqbs1tjNIcwDQYJKoZIhvcNAQEBBQAE
# ggEAYc1V4bwOz1fobvtKxWR30d+nov9YwYu5eIGGr9LO/uTXouTSt+ne8w0Gx0Ez
# XVkDvpdRe6D3rDAq6/91WHokP/6MdCM5fsQISAKOEeJY2Uo6AD2AQtUKTyePuWV5
# vSufSfTU+KUWEEUuHCNwEL0siIzfqcj4ExpF0h+hFlk5iy+wuYNWuJbACYOAlyaa
# 8A1OGd/p3OW7a4KOhCNP3eHsNVM6pNFKCERcesq70NVJVF63UFYhxxAfyU3nZ81X
# HkhgbW39mKF9YVfAnNtEfkFUONjBWhe5EutVghJ6caOCzUjOy75JT3CYHXhhaGkq
# 2WL0wffjaQHxA/iUk85Nkm6Qe6GCDX0wgg15BgorBgEEAYI3AwMBMYINaTCCDWUG
# CSqGSIb3DQEHAqCCDVYwgg1SAgEDMQ8wDQYJYIZIAWUDBAIBBQAwdwYLKoZIhvcN
# AQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCBEcfLL
# MoNsKLcK6pFUC2H9Ii+1QmPPNilyxXJ/wLZGPgIQejhNMApyf04iGRVi1VsrlRgP
# MjAyMTA2MTkwNTIwMDJaoIIKNzCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA
# 8N0wDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAxMDEw
# MDAwMDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjEw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXKY2tR
# 1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj/TZq
# gfop+N0rcIXeAhjzeG28ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj
# 4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDrDo4s
# 1SPa9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDC
# m2mCtNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1JhL0B
# AgMBAAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATApMCcG
# CCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgw
# FoAU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwoLR1E
# Nt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9zaGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdpY2Vy
# dC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURU
# aW1lc3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrn
# IA6OZ0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQCZk3t
# aaQP9rhwz2Lo9VFKeHk2eie38+dSn5On7UOee+e03UEiifuHokYDTvz0/rdkd2Nf
# I1Jpg4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO+MDh
# XM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j1h9b
# m/cuG08THfdKDXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5Npjhyyja
# W4emii8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHkBdo2l8IVMA0GCSqGSIb3DQEB
# CwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQg
# SUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0zMTAxMDcxMjAwMDBaMHIxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBU
# aW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9
# 0DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5fU1ofue2oPSNs4jkl79jIZCY
# vxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb6+NGRwYaVX4LJ37AovWg4N4i
# Pw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU46gJcWvgzyIQD3XPcXJOCq3f
# QDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mIUF79Zm5WYScpiYRR5oLnRlD9
# lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfxFwbvPc3WTe8GQv2iUypPhR3E
# HTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAdBgNVHQ4EFgQU9LbhIB3+Ka7S
# 5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wEgYD
# VR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4
# oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkwRzA4BgpghkgBhv1sAAIEMCow
# KAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJYIZI
# AYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLpUYdWac3v3dp8qmN6s3jPBjdA
# hO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4
# stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC4HLHmNY8ZOUfSBAYX4k4YU1i
# RiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+tpJn+1Nhiaj1a5bA9FhpDXzI
# AbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6HUSHkWGCbugwtK22ixH67xCUr
# RwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIvIjayS6JKldj1po5SMYIChjCC
# AoICAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hB
# MiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TAN
# BglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJ
# KoZIhvcNAQkFMQ8XDTIxMDYxOTA1MjAwMlowKwYLKoZIhvcNAQkQAgwxHDAaMBgw
# FgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJKoZIhvcNAQkEMSIEIDhj+VOaxVIC
# D/Al0tL1RoMWiwYaQmfOuvgnMps8yZ01MDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIE
# ILMQkAa8CtmDB5FXKeBEA0Fcg+MpK2FPJpZMjTVx7PWpMA0GCSqGSIb3DQEBAQUA
# BIIBAFSLxby4jv6ZvBx2jWuHeWHZ9Ts9AP+ShtMFnf8Zm1/TjLNRN6jg6Zl48dpP
# JVfCTZ0lJHGw1r/QVeQh6/6Nqhbjr1kA1BtgTEBuwqk9GWQHGDmYfCwk3FtFzge8
# 0oIThhkHfUpN2I1yVX+mYJ1mKvmFCsbov+UCnKFggW6hMIpwwW3SIgaEF5M9YuZ6
# oAuJ74Wvg2mqFZUTbyYNcq+9HVgGOUJihNEGL5sUta8vNLYdFIQmo+uWFYVC8rGK
# DQX1RKgxBLOEcIaVTKBUYdjConUbUcUAg1EB+UvZJ42YRLUcUKcn5UASRE7vNo3N
# iq+jH3lUIl+U6rkLfkcznHF+qsM=
# SIG # End signature block
