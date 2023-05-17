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
##	File Name:		VirtualLUNs.psm1
##	Description: 	Virtual LUNs cmdlets 
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
## FUNCTION New-vLun_WSAPI
############################################################################################################################################
Function New-vLun_WSAPI 
{
  <#
  
  .SYNOPSIS
	Creating a VLUN
	
  .DESCRIPTION
	Creating a VLUN
	Any user with Super or Edit role, or any role granted vlun_create permission, can perform this operation.
	
  .EXAMPLE
	New-vLun_WSAPI -VolumeName xxx -LUNID x -HostName xxx

  .EXAMPLE
	New-vLun_WSAPI -VolumeName xxx -LUNID x -HostName xxx -NSP 1:1:1
	
  .PARAMETER VolumeName
	Name of the volume or VV set to export.

  .PARAMETER LUNID
	LUN ID.
	
  .PARAMETER HostName  
	Name of the host or host set to which the volume or VV set is to be exported.
	The host set should be in set:hostset_name format.
	
  .PARAMETER NSP
	System port of VLUN exported to. It includes node number, slot number, and card port number.

  .PARAMETER NoVcn
	Specifies that a VCN not be issued after export (-novcn). Default: false.
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : New-vLun_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: New-vLun_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>
  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [int]
	  $LUNID,
	  
	  [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $HostName,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Boolean]
	  $NoVcn = $false,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
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
    
	If ($VolumeName) 
	{ 
		$body["volumeName"] ="$($VolumeName)" 
	}  
	If ($LUNID) 
	{ 
		$body["lun"] =$LUNID
	}
	If ($HostName) 
	{ 
		$body["hostname"] ="$($HostName)" 
	}
	If ($NSP) 
	{
		$NSPbody = @{} 
		
		$list = $NSP.split(":")
		
		$NSPbody["node"] = [int]$list[0]		
		$NSPbody["slot"] = [int]$list[1]
		$NSPbody["cardPort"] = [int]$list[2]		
		
		$body["portPos"] = $NSPbody		
	}
	If ($NoVcn) 
	{ 
		$body["noVcn"] = $NoVcn
	}
	
    
    $Result = $null
	
    #Request	
    $Result = Invoke-WSAPI -uri '/vluns' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode	
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		#write-host "SUCCESS: Status Code : $Result.StatusCode ." -foreground green
		#write-host "SUCCESS: Status Description : $Result.StatusDescription." -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Created a VLUN" $Info	
		Get-vLun_WSAPI -VolumeName $VolumeName -LUNID $LUNID -HostName $HostName
		
		Write-DebugLog "End: New-vLun_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Creating a VLUN" -foreground red
		write-host ""
		Write-DebugLog "FAILURE : Creating a VLUN" $Info
		Write-DebugLog "End: New-vLun_WSAPI" $Debug
		
		return $Result.StatusDescription
	}	
  }
  End 
  {
  }  
}
#ENG New-vLun_WSAPI

############################################################################################################################################
## FUNCTION Remove-vLun_WSAPI
############################################################################################################################################
Function Remove-vLun_WSAPI
 {
  <#
	
  .SYNOPSIS
	Removing a VLUN.
  
  .DESCRIPTION
	Removing a VLUN
    Any user with the Super or Edit role, or any role granted with the vlun_remove right, can perform this operation.    
	
  .EXAMPLE    
	Remove-vLun_WSAPI -VolumeName xxx -LUNID xx -HostName xxx

  .EXAMPLE    
	Remove-vLun_WSAPI -VolumeName xxx -LUNID xx -HostName xxx -NSP x:x:x
	
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
	required if volume is exported to port, or to both host and port .Notes NAME : Remove-vLun_WSAPI 
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Remove-vLun_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Remove-vLun_WSAPI 
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
	
  #>
  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
      [int]
	  $LUNID,
	  
	  [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $HostName,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,

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
	#Build uri
	Write-DebugLog "Running: Building uri to Remove-vLun_WSAPI  ." $Debug
	$uri = "/vluns/"+$VolumeName+","+$LUNID+","+$HostName
	
	if($NSP)
	{
		$uri = $uri+","+$NSP
	}	

	#init the response var
	$Result = $null

	#Request
	Write-DebugLog "Request: Request to Remove-vLun_WSAPI : $CPGName (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: VLUN Successfully removed with Given Values [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP ]." $Info
		Write-DebugLog "End: Remove-vLun_WSAPI" $Debug
		return $Result		
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Removing VLUN with Given Values [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP ]. " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Removing VLUN with Given Values [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP ]." $Info
		Write-DebugLog "End: Remove-vLun_WSAPI" $Debug
		
		return $Result.StatusDescription
	}    
	
  }
  End {}  
}
#END Remove-vLun_WSAPI

############################################################################################################################################
## FUNCTION Get-vLun_WSAPI
############################################################################################################################################
Function Get-vLun_WSAPI 
{
  <#
  .SYNOPSIS
	Get Single or list of VLun.
  
  .DESCRIPTION
	Get Single or list of VLun
        
  .EXAMPLE
	Get-vLun_WSAPI
	Display a list of VLun.
	
  .EXAMPLE
	Get-vLun_WSAPI -VolumeName xxx -LUNID x -HostName xxx 
	Display a list of VLun.

  .PARAMETER VolumeName
	Name of the volume to be exported.	
  
  .PARAMETER LUNID
   Lun
   
  .PARAMETER HostName
	Name of the host to which the volume is to be exported. For VLUN of port type, the value is empty.
		
  .PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-vLun_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Get-vLun_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Vlun_id,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $LUNID,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $HostName,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection	 
  }

  Process 
  {
	Write-DebugLog "Request: Request to Get-vLun_WSAPI [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP] (Invoke-WSAPI)." $Debug
    #Request
    
	$Result = $null
	$dataPS = $null		
	$uri = "/vluns/"+$Vlun_id+"/"
	# Results
	if($VolumeName)
	{
		#Build uri
		$uri = $uri+$VolumeName			
	}
	if($LUNID)
	{
		if($VolumeName)
		{
			#Build uri
			$uri = $uri+","+$LUNID			
		}
		else
		{
			$uri = $uri+$LUNID
		}
		
	}
	if($HostName)
	{
		if($VolumeName -Or $LUNID)
		{
			#Build uri
			$uri = $uri+","+$HostName			
		}
		else
		{
			$uri = $uri+$HostName
		}
	}
	if($NSP)
	{
		if($VolumeName -Or $LUNID -Or $HostName)
		{
			#Build uri
			$uri = $uri+","+$NSP			
		}
		else
		{
			$uri = $uri+$NSP
		}
	}
	if($Vlun_id -Or $VolumeName -Or $LUNID -Or $HostName -Or $NSP)
	{
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}
	}
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/vluns' -type 'GET' -WsapiConnection $WsapiConnection
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
				Write-DebugLog "SUCCESS: Get-vLun_WSAPI successfully Executed." $Info
				
				return $dataPS
			}
			else
			{
				write-host ""
				write-host "FAILURE : While Executing Get-vLun_WSAPI. Expected Result Not Found [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP]." -foreground red
				write-host ""
				Write-DebugLog "FAILURE : While Executing Get-vLun_WSAPI. Expected Result Not Found [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP]" $Info
				
				return 
			}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-vLun_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-vLun_WSAPI. " $Info
		
		return $Result.StatusDescription
	}
  }
	End {}
}#END Get-vLun_WSAPI


############################################################################################################################################
## FUNCTION Get-vLunUsingFilters_WSAPI
############################################################################################################################################
Function Get-vLunUsingFilters_WSAPI 
{
  <#
  .SYNOPSIS
	Get VLUNs using filters.
  
  .DESCRIPTION
	Get VLUNs using filters.
	Available filters for VLUN queries
	Use the following filters to query VLUNs:
	• volumeWWN
	• remoteName
	• volumeName
	• hostname
	• serial
        
  .EXAMPLE
	Get-vLunUsingFilters_WSAPI -VolumeWWN "xxx"

  .EXAMPLE
	Get-vLunUsingFilters_WSAPI -VolumeWWN "xxx,yyy,zzz"
	
  .EXAMPLE
	Get-vLunUsingFilters_WSAPI -RemoteName "xxx"
	
  .EXAMPLE
	Get-vLunUsingFilters_WSAPI -RemoteName "xxx,yyy,zzz"
	
  .EXAMPLE
	Get-vLunUsingFilters_WSAPI -RemoteName "xxx" -VolumeWWN "xxx"
	Supporting single or multipule values using ","

  .EXAMPLE
	Get-vLunUsingFilters_WSAPI -RemoteName "xxx" -VolumeWWN "xxx" -VolumeName "xxx"
	Supporting single or multipule values using ","
	
  .EXAMPLE
	Get-vLunUsingFilters_WSAPI -RemoteName "xxx" -VolumeWWN "xxx" -VolumeName "xxx" -HostName "xxx"
	Supporting single or multipule values using ","
	
  .EXAMPLE
	Get-vLunUsingFilters_WSAPI -RemoteName "xxx" -VolumeWWN "xxx" -VolumeName "xxx" -HostName "xxx" -Serial "xxx"
	Supporting single or multipule values using ","
	
  .PARAMETER VolumeWWN
	The value of <VolumeWWN> is the WWN of the exported volume
	
  .PARAMETER RemoteName
	the <RemoteName> value is the host WWN or an iSCSI pathname.
	
  .PARAMETER VolumeName
	Volume Name
	
  .PARAMETER HostName
	Host Name
	
  .PARAMETER Serial
	To Get volumes using a serial number
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Get-vLunUsingFilters_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Get-vLunUsingFilters_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeWWN,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $RemoteName,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VolumeName,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $HostName,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Serial,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection	 
  }

  Process 
  {
	Write-DebugLog "Request: Request to Get-vLunUsingFilters_WSAPI VVSetName : $VVSetName (Invoke-WSAPI)." $Debug
    #Request
    
	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	
	# Results	
	if($VolumeWWN)
	{		
		$Query = LoopingFunction -Value $VolumeWWN -condition "volumeWWN" -flg $false -Query $Query		
	}
	if($RemoteName)
	{
		if($VolumeWWN)
		{
			$Query = LoopingFunction -Value $RemoteName -condition "remoteName" -flg $true -Query $Query
		}
		else
		{
			$Query = LoopingFunction -Value $RemoteName -condition "remoteName" -flg $false -Query $Query
		}
	}
	if($VolumeName)
	{
		if($VolumeWWN -or $RemoteName)
		{
			$Query = LoopingFunction -Value $VolumeName -condition "volumeName" -flg $true -Query $Query
		}
		else
		{
			$Query = LoopingFunction -Value $VolumeName -condition "volumeName" -flg $false -Query $Query
		}
	}
	if($HostName)
	{
		if($VolumeWWN -or $RemoteName -or $VolumeName)
		{
			$Query = LoopingFunction -Value $HostName -condition "hostname" -flg $true -Query $Query
		}
		else
		{
			$Query = LoopingFunction -Value $HostName -condition "hostname" -flg $false -Query $Query
		}
	}
	if($Serial)
	{
		if($VolumeWWN -or $RemoteName -or $VolumeName -or $HostName)
		{
			$Query = LoopingFunction -Value $Serial -condition "serial" -flg $true -Query $Query
		}
		else
		{
			$Query = LoopingFunction -Value $Serial -condition "serial" -flg $false -Query $Query
		}
	}
	
	if($VolumeWWN -or $RemoteName -or $VolumeName -or $HostName -or $Serial)
	{
		#Build uri
		$uri = '/vluns/'+$Query
		
		#write-host "uri = $uri"
		
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection		
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
			Write-DebugLog "SUCCESS: Get-vLunUsingFilters_WSAPI successfully Executed." $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-vLunUsingFilters_WSAPI. Expected Result Not Found with Given Filter Option : VolumeWWN/$VolumeWWN RemoteName/$RemoteName VolumeName/$VolumeName HostName/$HostName Serial/$Serial." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-vLunUsingFilters_WSAPI. Expected Result Not Found with Given Filter Option : VolumeWWN/$VolumeWWN RemoteName/$RemoteName VolumeName/$VolumeName HostName/$HostName Serial/$Serial." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-vLunUsingFilters_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-vLunUsingFilters_WSAPI. " $Info
		
		return $Result.StatusDescription
	}
  }
	End {}
}#END Get-vLunUsingFilters_WSAPI


Export-ModuleMember New-vLun_WSAPI , Remove-vLun_WSAPI , Get-vLun_WSAPI , Get-vLunUsingFilters_WSAPI
# SIG # Begin signature block
# MIIhEAYJKoZIhvcNAQcCoIIhATCCIP0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCv65TELQmvu5E8
# Z9ciadBWsICPpaqxOsA7HtNUVeaiE6CCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# 4kbRY17dgQgOV3Yp4KCnXyB3VCaAIwXpncxbNsof61swDQYJKoZIhvcNAQEBBQAE
# ggEAdPAm+z9RMSt19rGwIkXNqxQmgi/l8LMG0znSIQfRaHrYOwozaaY7Rtwz1GwP
# 0tEkJ1qXtyYO5rkno1GceiLDQmVXIz9PYUA1cjzeDIrpygX0s7pOZLqAL4kf4znD
# U7MfsdGeTOnOtTdiXi+vAdBYmJa8JQ98f7KwabO2lRv/cfpLrcm71ZFmdwB1+Mlx
# joZi1bW0sSJ7SDbeKS95ucEwpGZvVBRYjIaQSJQ8E1lqdf0U812zODId9PbZabu8
# utZp827321o6sYvwuW7jBJ35y08GYkzVqzVUC0fGq7jaMdHdcWMmay+ySGCvfFQk
# 98ZxwtLyKYI7uxlgzfIE40wM7qGCDX0wgg15BgorBgEEAYI3AwMBMYINaTCCDWUG
# CSqGSIb3DQEHAqCCDVYwgg1SAgEDMQ8wDQYJYIZIAWUDBAIBBQAwdwYLKoZIhvcN
# AQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCBrUgwd
# Pzqd1cOe6Jib/rFMozMUVh+KRiUbhhywGPouAAIQKnyDGSaU6qmgkIkHBuRjwRgP
# MjAyMTA2MTkwNTI5MzFaoIIKNzCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA
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
# KoZIhvcNAQkFMQ8XDTIxMDYxOTA1MjkzMVowKwYLKoZIhvcNAQkQAgwxHDAaMBgw
# FgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJKoZIhvcNAQkEMSIEID33gKFhnnSf
# IjdRK2MYqKKPDvJIekHYrBG/hn8aacxXMDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIE
# ILMQkAa8CtmDB5FXKeBEA0Fcg+MpK2FPJpZMjTVx7PWpMA0GCSqGSIb3DQEBAQUA
# BIIBACvDTAsZ9W6PC0yiiOkNEZnugGgUnm0TAOUulSr4DMFO3GcjKPE8A9T4MrGF
# eltXOBZ+59ENljqDvpn8XenhT0wzaov2BJh4hhGJBwP9WcmoKl93X6ocQeE07rJ0
# M7aZ695lwopf4nOHceYbzbgQXm9Z4MirlJvU3r6q1kBhQ1wECC3q9zQZVgxRXsRx
# L0B49ebaiiIwzXsTDXh3DLzsvDZbnvPM/FwvSYR9o5I7fCmopoNpW/J/gP9cftMD
# tudspni/0GxUpoTB58BS405SExwPiZADNHwLPU5StNVkOmScIfeIm71tw+udpOac
# TABlWaMnjHW17cpZXuTHhDqnm+Y=
# SIG # End signature block
