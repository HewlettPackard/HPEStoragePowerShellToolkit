####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##	Description: 	System information queries and management cmdlets 
##		

Function Update-A9System 
{
<#
.SYNOPSIS
	Update storage system parameters
.DESCRIPTION
	Update storage system parameters
	You can set all of the system parameters in one request, but some updates might fail.
.EXAMPLE
	PS:> Update-A9System -RemoteSyslog $true
.EXAMPLE
	PS:> Update-A9System -remoteSyslogHost "0.0.0.0"
.EXAMPLE	
	PS:> Update-A9System -PortFailoverEnabled $true
.EXAMPLE	
	PS:> Update-A9System -DisableDedup $true
.EXAMPLE	
	PS:> Update-A9System -OverProvRatioLimit 3
.EXAMPLE	
	PS:> Update-A9System -AllowR5OnFCDrives $true
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
#>
[CmdletBinding()]
Param(
	[Parameter()]	[boolean]	$RemoteSyslog,
	[Parameter()]	[String]	$RemoteSyslogHost,
	[Parameter()]	[String]	$RemoteSyslogSecurityHost,
	[Parameter()]	[boolean]	$PortFailoverEnabled,
	[Parameter()]	[boolean]	$FailoverMatchedSet,
	[Parameter()]	[boolean]	$DisableDedup,
	[Parameter()]	[boolean]	$DisableCompr,
	[Parameter()]	[int]		$OverProvRatioLimit,
	[Parameter()]	[int]		$OverProvRatioWarning,
	[Parameter()]	[boolean]	$AllowR5OnNLDrives,
	[Parameter()]	[boolean]	$AllowR5OnFCDrives,
	[Parameter()]	[boolean]	$ComplianceOfficerApproval
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$ObjMain=@{}	
	If ($RemoteSyslog) 
		{	$Obj=@{}
			$Obj["remoteSyslog"] = $RemoteSyslog
			$ObjMain += $Obj				
		}
	If ($RemoteSyslogHost) 
		{	$Obj=@{}
			$Obj["remoteSyslogHost"] = "$($RemoteSyslogHost)"
			$ObjMain += $Obj
		}
	If ($RemoteSyslogSecurityHost) 
		{	$Obj=@{}
			$Obj["remoteSyslogSecurityHost"] = "$($RemoteSyslogSecurityHost)"
			$ObjMain += $Obj		
		}
	If ($PortFailoverEnabled) 
		{	$Obj=@{}
			$Obj["portFailoverEnabled"] = $PortFailoverEnabled
			$ObjMain += $Obj			
		}
	If ($FailoverMatchedSet) 
		{	$Obj=@{}
			$Obj["failoverMatchedSet"] = $FailoverMatchedSet
			$ObjMain += $Obj				
		}
	If ($DisableDedup) 
		{	$Obj=@{}
			$Obj["disableDedup"] = $DisableDedup
			$ObjMain += $Obj				
		}
	If ($DisableCompr) 
		{	$Obj=@{}
			$Obj["disableCompr"] = $DisableCompr
			$ObjMain += $Obj				
		}
	If ($OverProvRatioLimit) 
		{	$Obj=@{}
			$Obj["overProvRatioLimit"] = $OverProvRatioLimit
			$ObjMain += $Obj				
		}
	If ($OverProvRatioWarning) 
		{	$Obj=@{}
			$Obj["overProvRatioWarning"] = $OverProvRatioWarning	
			$ObjMain += $Obj			
		}
	If ($AllowR5OnNLDrives) 
		{	$Obj=@{}
			$Obj["allowR5OnNLDrives"] = $AllowR5OnNLDrives	
			$ObjMain += $Obj				
		}
	If ($AllowR5OnFCDrives) 
		{	$Obj=@{}
			$Obj["allowR5OnFCDrives"] = $AllowR5OnFCDrives	
			$ObjMain += $Obj				
		}
	If ($ComplianceOfficerApproval) 
		{	$Obj=@{}
			$Obj["complianceOfficerApproval"] = $ComplianceOfficerApproval	
			$ObjMain += $Obj				
		}
	if($ObjMain.Count -gt 0)
		{	$body["parameters"] = $ObjMain 
		}	
    $Result = $null
    $Result = Invoke-A9API -uri '/system' -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return Get-A9System		
		}
	else
		{	Write-Error "Failure:  While Updating storage system parameters." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9Version 
{
<#
.SYNOPSIS	
	Get version information.
.DESCRIPTION
	Get version information.
.EXAMPLE
	PS:> Get-A9Version
	
	Get version information.
#>
[CmdletBinding()]
Param()
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null	
	$dataPS = $null	
	$ip = $WsapiConnection.IPAddress
	$key = $WsapiConnection.Key
	$arrtyp = $global:ArrayType
	$APIurl = $Null
	if($arrtyp.ToLower() -eq "3par")
		{	$APIurl = 'https://'+$ip+':8080/api'		
		}
	Elseif(($arrtyp.ToLower() -eq "primera") -or ($arrtyp.ToLower() -eq "alletra9000") -or ($arrtyp.ToLower() -eq "AlletraMP-B10000") )
		{	$APIurl = 'https://'+$ip+':443/api'
		}	
	else
		{	return "Array type is Null."
		}	
	$headers = @{}
    $headers["Accept"] 						= "application/json"
    $headers["Accept-Language"] 			= "en"
    $headers["Content-Type"] 				= "application/json"
    $headers["X-HP3PAR-WSAPI-SessionKey"] 	= $key
	if ($PSEdition -eq 'Core')
		{	$Result = Invoke-WebRequest -Uri "$APIurl" -Headers $headers -Method GET -UseBasicParsing -SkipCertificateCheck
		} 
	else 
		{	$Result = Invoke-WebRequest -Uri "$APIurl" -Headers $headers -Method GET -UseBasicParsing 
		}
	if($Result.StatusCode -eq 200)
	{	$dataPS = $Result.content | ConvertFrom-Json
		write-host "Cmdlet executed successfully" -foreground green
		return $dataPS
	}
	else
	{	Write-Error "Failure:  While Executing Get-Version_WSAPI" 
		return $Result.StatusDescription
	}
}	
}

Function Get-A9WSAPIConfigInfo 
{
<#
.SYNOPSIS	
	Get Getting WSAPI configuration information
.DESCRIPTION
	Get Getting WSAPI configuration information
.EXAMPLE
	PS:> Get-A9WSAPIConfigInfo

	Get Getting WSAPI configuration information
#>
[CmdletBinding()]
Param()
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null	
	$dataPS = $null	
	$Result = Invoke-A9API -uri '/wsapiconfiguration' -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS
		}
	else
		{	Write-Error "Failure:  While Executing Get-WSAPIConfigInfo" 
			return $Result.StatusDescription
		}
}	
}

