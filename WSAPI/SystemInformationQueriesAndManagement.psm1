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
##	File Name:		SystemInformationQueriesAndManagement.psm1
##	Description: 	System information queries and management cmdlets 
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
## FUNCTION Get-System_WSAPI
############################################################################################################################################
Function Get-System_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Retrieve informations about the array.
  
  .DESCRIPTION
	Retrieve informations about the array.
        
  .EXAMPLE
	Get-System_WSAPI
	Retrieve informations about the array.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command	
	
  .Notes
    NAME    : Get-System_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-System_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
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
	
	#Request
	$Result = Invoke-WSAPI -uri '/system' -type 'GET' -WsapiConnection $WsapiConnection 
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = $Result.content | ConvertFrom-Json
	}
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS:successfully Executed" $Info

		return $dataPS
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-System_WSAPI" -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-System_WSAPI" $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-System_WSAPI

############################################################################################################################################
## FUNCTION Update-System_WSAPI
############################################################################################################################################
Function Update-System_WSAPI 
{
  <#
  .SYNOPSIS
	Update storage system parameters
  
  .DESCRIPTION
	Update storage system parameters
	You can set all of the system parameters in one request, but some updates might fail.
        
  .EXAMPLE
	Update-System_WSAPI -RemoteSyslog $true
        
  .EXAMPLE
	Update-System_WSAPI -remoteSyslogHost "0.0.0.0"
        
  .EXAMPLE	
	Update-System_WSAPI -PortFailoverEnabled $true
        
  .EXAMPLE	
	Update-System_WSAPI -DisableDedup $true
        
  .EXAMPLE	
	Update-System_WSAPI -OverProvRatioLimit 3
        
  .EXAMPLE	
	Update-System_WSAPI -AllowR5OnFCDrives $true
	
  .PARAMETER RemoteSyslog
	Enable (true) or disable (false) sending events to a remote system as syslog messages.
	
  .PARAMETER RemoteSyslogHost
	IP address of the systems to which events are sent as syslog messages.
	
  .PARAMETER RemoteSyslogSecurityHost
	Sets the hostname or IP address, and optionally the port, of the remote syslog servers to which security events are sent as syslog messages.

  .PARAMETER PortFailoverEnabled
	Enable (true) or disable (false) the automatic fail over of target ports to their designated partner ports.
	
  .PARAMETER FailoverMatchedSet
	Enable (true) or disable (false) the automatic fail over of matched-set VLUNs during a persistent port fail over. This does not affect host-see VLUNs, which are always failed over.
	
  .PARAMETER DisableDedup
	Enable or disable new write requests to TDVVs serviced by the system to be deduplicated.
	true – Disables deduplication
	false – Enables deduplication
	
  .PARAMETER DisableCompr
	Enable or disable the compression of all new write requests to the compressed VVs serviced by the system.
	True - The new writes are not compressed.
	False - The new writes are compressed.
	
  .PARAMETER OverProvRatioLimit
	The system, device types, and all CPGs are limited to the specified overprovisioning ratio.
	
  .PARAMETER OverProvRatioWarning
	An overprovisioning ratio, which when exceeded by the system, a device type, or a CPG, results in a warning alert.
	
  .PARAMETER AllowR5OnNLDrives
	Enable (true) or disable (false) support for RAID-5 on NL drives.
	
  .PARAMETER AllowR5OnFCDrives
	Enable (true) or disable (false) support for RAID-5 on FC drives.
	
  .PARAMETER ComplianceOfficerApproval
	Enable (true) or disable (false) compliance officer approval mode.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : Update-System_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Update-System_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $RemoteSyslog,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $RemoteSyslogHost,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $RemoteSyslogSecurityHost,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $PortFailoverEnabled,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $FailoverMatchedSet,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $DisableDedup,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $DisableCompr,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $OverProvRatioLimit,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $OverProvRatioWarning,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $AllowR5OnNLDrives,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $AllowR5OnFCDrives,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [boolean]
	  $ComplianceOfficerApproval,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
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
	$ObjMain=@{}	
	
	If ($RemoteSyslog) 
	{
		$Obj=@{}
		$Obj["remoteSyslog"] = $RemoteSyslog
		$ObjMain += $Obj				
    }
	If ($RemoteSyslogHost) 
	{
		$Obj=@{}
		$Obj["remoteSyslogHost"] = "$($RemoteSyslogHost)"
		$ObjMain += $Obj
    }
	If ($RemoteSyslogSecurityHost) 
	{
		$Obj=@{}
		$Obj["remoteSyslogSecurityHost"] = "$($RemoteSyslogSecurityHost)"
		$ObjMain += $Obj		
    }
	If ($PortFailoverEnabled) 
	{
		$Obj=@{}
		$Obj["portFailoverEnabled"] = $PortFailoverEnabled
		$ObjMain += $Obj			
    }
	If ($FailoverMatchedSet) 
	{
		$Obj=@{}
		$Obj["failoverMatchedSet"] = $FailoverMatchedSet
		$ObjMain += $Obj				
    }
	If ($DisableDedup) 
	{
		$Obj=@{}
		$Obj["disableDedup"] = $DisableDedup
		$ObjMain += $Obj				
    }
	If ($DisableCompr) 
	{
		$Obj=@{}
		$Obj["disableCompr"] = $DisableCompr
		$ObjMain += $Obj				
    }
	If ($OverProvRatioLimit) 
	{
		$Obj=@{}
		$Obj["overProvRatioLimit"] = $OverProvRatioLimit
		$ObjMain += $Obj				
    }
	If ($OverProvRatioWarning) 
	{
		$Obj=@{}
		$Obj["overProvRatioWarning"] = $OverProvRatioWarning	
		$ObjMain += $Obj			
    }
	If ($AllowR5OnNLDrives) 
	{
		$Obj=@{}
		$Obj["allowR5OnNLDrives"] = $AllowR5OnNLDrives	
		$ObjMain += $Obj				
    }
	If ($AllowR5OnFCDrives) 
	{
		$Obj=@{}
		$Obj["allowR5OnFCDrives"] = $AllowR5OnFCDrives	
		$ObjMain += $Obj				
    }
	If ($ComplianceOfficerApproval) 
	{
		$Obj=@{}
		$Obj["complianceOfficerApproval"] = $ComplianceOfficerApproval	
		$ObjMain += $Obj				
    }
	
	if($ObjMain.Count -gt 0)
	{
		$body["parameters"] = $ObjMain 
	}	
    
    $Result = $null
    #Request
	Write-DebugLog "Request: Request to Update-System_WSAPI (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri '/system' -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Update storage system parameters." $Info
				
		# Results		
		Get-System_WSAPI		
		Write-DebugLog "End: Update-System_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Updating storage system parameters." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Updating storage system parameters." $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Update-System_WSAPI

############################################################################################################################################
## FUNCTION Get-Version_WSAPI
############################################################################################################################################
Function Get-Version_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get version information.
  
  .DESCRIPTION
	Get version information.
        
  .EXAMPLE
	Get-Version_WSAPI
	Get version information.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-Version_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-Version_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
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
	
	$ip = $WsapiConnection.IPAddress
	$key = $WsapiConnection.Key
	$arrtyp = $global:ArrayType
	
	$APIurl = $Null
	
	if($arrtyp.ToLower() -eq "3par")
	{
		#$APIurl = "https://$($SANIPAddress):8080/api/v1"
		$APIurl = 'https://'+$ip+':8080/api'		
	}
	Elseif(($arrtyp.ToLower() -eq "primera") -or ($arrtyp.ToLower() -eq "alletra9000"))
	{
		#$APIurl = "https://$($SANIPAddress):443/api/v1"
		$APIurl = 'https://'+$ip+':443/api'
	}	
	else
	{
		return "Array type is Null."
	}	
	
    #Construct header
	Write-DebugLog "Running: Constructing header." $Debug
	$headers = @{}
    $headers["Accept"] = "application/json"
    $headers["Accept-Language"] = "en"
    $headers["Content-Type"] = "application/json"
    $headers["X-HP3PAR-WSAPI-SessionKey"] = $key
	
	#Request
	if ($PSEdition -eq 'Core')
	{				
		$Result = Invoke-WebRequest -Uri "$APIurl" -Headers $headers -Method GET -UseBasicParsing -SkipCertificateCheck
	} 
	else 
	{				
		$Result = Invoke-WebRequest -Uri "$APIurl" -Headers $headers -Method GET -UseBasicParsing 
	}
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = $Result.content | ConvertFrom-Json
	}
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS:successfully Executed" $Info

		return $dataPS
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-Version_WSAPI" -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-Version_WSAPI" $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-Version_WSAPI

############################################################################################################################################
## FUNCTION Get-WSAPIConfigInfo
############################################################################################################################################
Function Get-WSAPIConfigInfo 
{
  <#
   
  .SYNOPSIS	
	Get Getting WSAPI configuration information
  
  .DESCRIPTION
	Get Getting WSAPI configuration information
        
  .EXAMPLE
	Get-WSAPIConfigInfo
	Get Getting WSAPI configuration information

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command	

  .Notes
    NAME    : Get-WSAPIConfigInfo   
    LASTEDIT: February 2020
    KEYWORDS: Get-WSAPIConfigInfo
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
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
	
	#Request
	$Result = Invoke-WSAPI -uri '/wsapiconfiguration' -type 'GET' -WsapiConnection $WsapiConnection
	if($Result.StatusCode -eq 200)
	{
		$dataPS = $Result.content | ConvertFrom-Json
	}
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS:successfully Executed" $Info

		return $dataPS
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-WSAPIConfigInfo" -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-WSAPIConfigInfo" $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-WSAPIConfigInfo

############################################################################################################################################
## FUNCTION Get-Task_WSAPI
############################################################################################################################################
Function Get-Task_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get the status of all or given tasks
  
  .DESCRIPTION
	Get the status of all or given tasks
        
  .EXAMPLE
	Get-Task_WSAPI
	Get the status of all tasks
	
  .EXAMPLE
	Get-Task_WSAPI -TaskID 101
	Get the status of given tasks
	
  .PARAMETER TaskID	
    Task ID

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-Task_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-Task_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $TaskID,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
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
	
	#Build uri
	if($TaskID)
	{
		$uri = '/tasks/'+$TaskID
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}
	}
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/tasks' -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}		
	}
		  
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Command Get-Task_WSAPI Successfully Executed" $Info
		
		return $dataPS
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-Task_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-Task_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-Task_WSAPI

############################################################################################################################################
## FUNCTION Stop-OngoingTask_WSAPI
############################################################################################################################################
Function Stop-OngoingTask_WSAPI 
{
  <#
  .SYNOPSIS
	Cancels the ongoing task.
  
  .DESCRIPTION
	Cancels the ongoing task.
        
  .EXAMPLE
	Stop-OngoingTask_WSAPI -TaskID 1
	
  .PARAMETER TaskID
	Task id.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Stop-OngoingTask_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Stop-OngoingTask_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $TaskID,
	  
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
	$body = @{}	
	$body["action"] = 4
	
    $Result = $null	
	$uri = "/tasks/" + $TaskID
	
    #Request
	Write-DebugLog "Request: Request to Stop-OngoingTask_WSAPI : $TaskID (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Cancels the ongoing task : $TaskID ." $Info
				
		# Results		
		return $Result		
		Write-DebugLog "End: Stop-OngoingTask_WSAPI." $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Cancelling the ongoing task : $TaskID " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Cancelling the ongoing task : $TaskID " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Stop-OngoingTask_WSAPI

Export-ModuleMember Get-System_WSAPI , Update-System_WSAPI , Get-Version_WSAPI , Get-WSAPIConfigInfo , Get-Task_WSAPI , Stop-OngoingTask_WSAPI
# SIG # Begin signature block
# MIIhzwYJKoZIhvcNAQcCoIIhwDCCIbwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDfePcEucyrozVl
# nfNopPu8gd29V9tADXq/dTuK4Ap7G6CCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIQejCCEHYCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# GR8EvwHQEMffw8UqKVQYG4YgKm0MaD+e/f/iZ1RmwwEwDQYJKoZIhvcNAQEBBQAE
# ggEAn4gZrCmlltdk/uLNBrXxlI8XFqt/f7AwvJm29zBQb8RH0bR2SaNugrAjGBMQ
# ZLfCy11Djyb82mcDH6VXPVXIF8NSHtKAAwe+pjmVn+fqGGUd58o+N8ZtmGJ6yo41
# CSEZQhC0yxj9nda/bWfMHGsAnlqEGasqjcZjgfXAxKYyuj7C6VsxYUnNwX+D83H0
# FX9TaFF86Lxdto5XftKlLAS1Yxa3EkadOB0NtAEqXJXrdMHYXgUAVOU/1VtRZiHF
# GvpKk4QgF0q0S9y97iuNIZfcJWEFYk5Jyg+y0apaYOOLev/VuClUdKqT4Sjd7XPX
# k/LXBPed9F37Fx6utDTUiRItnKGCDjwwgg44BgorBgEEAYI3AwMBMYIOKDCCDiQG
# CSqGSIb3DQEHAqCCDhUwgg4RAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDgYLKoZIhvcN
# AQkQAQSggf4EgfswgfgCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# IGpy1Dgh7j2faoPHetHFOYnPZpIf3sZgQ6Z7gD9istq2AhRovDWd629GRgGz09x5
# +OwIjlhEFxgPMjAyMTA2MTkwNTI1NTlaMAMCAR6ggYakgYMwgYAxCzAJBgNVBAYT
# AlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3lt
# YW50ZWMgVHJ1c3QgTmV0d29yazExMC8GA1UEAxMoU3ltYW50ZWMgU0hBMjU2IFRp
# bWVTdGFtcGluZyBTaWduZXIgLSBHM6CCCoswggU4MIIEIKADAgECAhB7BbHUSWhR
# RPfJidKcGZ0SMA0GCSqGSIb3DQEBCwUAMIG9MQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdv
# cmsxOjA4BgNVBAsTMShjKSAyMDA4IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhv
# cml6ZWQgdXNlIG9ubHkxODA2BgNVBAMTL1ZlcmlTaWduIFVuaXZlcnNhbCBSb290
# IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE2MDExMjAwMDAwMFoXDTMxMDEx
# MTIzNTk1OVowdzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBv
# cmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMSgwJgYDVQQD
# Ex9TeW1hbnRlYyBTSEEyNTYgVGltZVN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAu1mdWVVPnYxyXRqBoutV87ABrTxxrDKPBWuGmicA
# MpdqTclkFEspu8LZKbku7GOz4c8/C1aQ+GIbfuumB+Lef15tQDjUkQbnQXx5HMvL
# rRu/2JWR8/DubPitljkuf8EnuHg5xYSl7e2vh47Ojcdt6tKYtTofHjmdw/SaqPSE
# 4cTRfHHGBim0P+SDDSbDewg+TfkKtzNJ/8o71PWym0vhiJka9cDpMxTW38eA25Hu
# /rySV3J39M2ozP4J9ZM3vpWIasXc9LFL1M7oCZFftYR5NYp4rBkyjyPBMkEbWQ6p
# PrHM+dYr77fY5NUdbRE6kvaTyZzjSO67Uw7UNpeGeMWhNwIDAQABo4IBdzCCAXMw
# DgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwZgYDVR0gBF8wXTBb
# BgtghkgBhvhFAQcXAzBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Quc3ltY2IuY29t
# L2NwczAlBggrBgEFBQcCAjAZGhdodHRwczovL2Quc3ltY2IuY29tL3JwYTAuBggr
# BgEFBQcBAQQiMCAwHgYIKwYBBQUHMAGGEmh0dHA6Ly9zLnN5bWNkLmNvbTA2BgNV
# HR8ELzAtMCugKaAnhiVodHRwOi8vcy5zeW1jYi5jb20vdW5pdmVyc2FsLXJvb3Qu
# Y3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMIMCgGA1UdEQQhMB+kHTAbMRkwFwYDVQQD
# ExBUaW1lU3RhbXAtMjA0OC0zMB0GA1UdDgQWBBSvY9bKo06FcuCnvEHzKaI4f4B1
# YjAfBgNVHSMEGDAWgBS2d/ppSEefUxLVwuoHMnYH0ZcHGTANBgkqhkiG9w0BAQsF
# AAOCAQEAdeqwLdU0GVwyRf4O4dRPpnjBb9fq3dxP86HIgYj3p48V5kApreZd9KLZ
# VmSEcTAq3R5hF2YgVgaYGY1dcfL4l7wJ/RyRR8ni6I0D+8yQL9YKbE4z7Na0k8hM
# kGNIOUAhxN3WbomYPLWYl+ipBrcJyY9TV0GQL+EeTU7cyhB4bEJu8LbF+GFcUvVO
# 9muN90p6vvPN/QPX2fYDqA/jU/cKdezGdS6qZoUEmbf4Blfhxg726K/a7JsYH6q5
# 4zoAv86KlMsB257HOLsPUqvR45QDYApNoP4nbRQy/D+XQOG/mYnb5DkUvdrk08Pq
# K1qzlVhVBH3HmuwjA42FKtL/rqlhgTCCBUswggQzoAMCAQICEHvU5a+6zAc/oQEj
# BCJBTRIwDQYJKoZIhvcNAQELBQAwdzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5
# bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3
# b3JrMSgwJgYDVQQDEx9TeW1hbnRlYyBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4X
# DTE3MTIyMzAwMDAwMFoXDTI5MDMyMjIzNTk1OVowgYAxCzAJBgNVBAYTAlVTMR0w
# GwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMg
# VHJ1c3QgTmV0d29yazExMC8GA1UEAxMoU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFt
# cGluZyBTaWduZXIgLSBHMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AK8Oiqr43L9pe1QXcUcJvY08gfh0FXdnkJz93k4Cnkt29uU2PmXVJCBtMPndHYPp
# PydKM05tForkjUCNIqq+pwsb0ge2PLUaJCj4G3JRPcgJiCYIOvn6QyN1R3AMs19b
# jwgdckhXZU2vAjxA9/TdMjiTP+UspvNZI8uA3hNN+RDJqgoYbFVhV9HxAizEtavy
# bCPSnw0PGWythWJp/U6FwYpSMatb2Ml0UuNXbCK/VX9vygarP0q3InZl7Ow28paV
# gSYs/buYqgE4068lQJsJU/ApV4VYXuqFSEEhh+XetNMmsntAU1h5jlIxBk2UA0XE
# zjwD7LcA8joixbRv5e+wipsCAwEAAaOCAccwggHDMAwGA1UdEwEB/wQCMAAwZgYD
# VR0gBF8wXTBbBgtghkgBhvhFAQcXAzBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Qu
# c3ltY2IuY29tL2NwczAlBggrBgEFBQcCAjAZGhdodHRwczovL2Quc3ltY2IuY29t
# L3JwYTBABgNVHR8EOTA3MDWgM6Axhi9odHRwOi8vdHMtY3JsLndzLnN5bWFudGVj
# LmNvbS9zaGEyNTYtdHNzLWNhLmNybDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwdwYIKwYBBQUHAQEEazBpMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wOwYIKwYBBQUHMAKGL2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3NoYTI1Ni10c3MtY2EuY2VyMCgGA1UdEQQh
# MB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC02MB0GA1UdDgQWBBSlEwGp
# n4XMG24WHl87Map5NgB7HTAfBgNVHSMEGDAWgBSvY9bKo06FcuCnvEHzKaI4f4B1
# YjANBgkqhkiG9w0BAQsFAAOCAQEARp6v8LiiX6KZSM+oJ0shzbK5pnJwYy/jVSl7
# OUZO535lBliLvFeKkg0I2BC6NiT6Cnv7O9Niv0qUFeaC24pUbf8o/mfPcT/mMwnZ
# olkQ9B5K/mXM3tRr41IpdQBKK6XMy5voqU33tBdZkkHDtz+G5vbAf0Q8RlwXWuOk
# O9VpJtUhfeGAZ35irLdOLhWa5Zwjr1sR6nGpQfkNeTipoQ3PtLHaPpp6xyLFdM3f
# RwmGxPyRJbIblumFCOjd6nRgbmClVnoNyERY3Ob5SBSe5b/eAL13sZgUchQk38cR
# LB8AP8NLFMZnHMweBqOQX1xUiz7jM1uCD8W3hgJOcZ/pZkU/djGCAlowggJWAgEB
# MIGLMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlv
# bjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEoMCYGA1UEAxMfU3lt
# YW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQe9Tlr7rMBz+hASMEIkFNEjAL
# BglghkgBZQMEAgGggaQwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqG
# SIb3DQEJBTEPFw0yMTA2MTkwNTI1NTlaMC8GCSqGSIb3DQEJBDEiBCBUqm9AYr9g
# C2NfhZ2hACQIHRrRbrT8qSHue2MGSEwkIzA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCDEdM52AH0COU4NpeTefBTGgPniggE8/vZT7123H99h+DALBgkqhkiG9w0BAQEE
# ggEAKV+WxX1OtGE8JAMlyWv9g0cgzNjXrPc6hbwuUo9jRkSzQuSQ/63o0CGK3+Q8
# ur+ZR2q/v/lBw5jZFRM9OVqMdtlxzLYoW05OVOW3TLU9L2tUVJaR1bqqUom3RhaQ
# WSU8VygbjSXuJQVaCSZgR51fJegJcy71YcFigK5cC5laQxJGt93D0RtByBYQ8wxU
# SJ4vVSSMfcpMsUz/tybJPXeO02Xnyp1FF9S4cfIKMlkSSMHlztkj1kBaaHmmqxUw
# FqSpzY4b4Sq01PPMbl/ogV967YZR1SYaYxJApjoosH4KMDoKi+QM/OFel44FP6Qe
# A39vjWUm2FOrVLegWW9iD1+rqw==
# SIG # End signature block
