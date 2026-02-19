## 	©2025 Hewlett Packard Enterprise Development LP

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
		$NewObj = @(    foreach( $Item in $DataPS)
							{   $NewItem=@{PSTypeName = "HPE.A9Storage.Version"}
								$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
								$DataSetType = "HPE.A9Storage.Version"
								$NewItem.PSTypeNames.Insert(0,$DataSetType)
								$DataSetType = $DataSetType + ".TypeName"
								$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
								[PSCustomObject]$NewItem
							}
					)
		return $NewObj 
	}
	else
	{	Write-Error "Failure:  While Executing Get-A9Version" 
		return $Result.StatusDescription
	}
}	
}

Function Get-A9Certificate
{
<#
.SYNOPSIS	
	Get the Array Certificates.
.DESCRIPTION
	Get the Array Certificates.
.EXAMPLE
	S:> Get-A9Certificate
	Cmdlet executed successfully

	service        : dscc
	commonName     : CZ27D
	type           : cert
	endDate        : Mar  7 23:59:59 2031 GMT
	fingerPrint    : 862ba37e0dbe6
	issuer         : C=US,O=HPE Nimble Storage,OU=www.hpe.com,CN=HPE Nimble Storage Intermediate CA
	serial         : 203470032572332585
	signatureType  : ca-signed
	startDate      : Mar  7 00:00:00 2024 GMT
	subject        : C=US,ST=California,L=San Jose,O=Hewlett Packard Enterprise (Nimble Storage Division),CN=CZ2410007D
	subjectAltName : --
	pem            : -----BEGIN CERTIFICATE-----
					MIIFVD...G7GTJBSt
					-----END CERTIFICATE-----


	service        : dscc
	commonName     : HPE Nimble Storage Intermediate CA
	type           : intca
	endDate        : Dec 17 12:00:00 2039 GMT
	fingerPrint    : ec32196ae3c57414f5b
	issuer         : C=US,O=HPE Nimble Storage,OU=www.hpe.com,CN=HPE Nimble Storage Root CA
	serial         : 14523579937717060
	signatureType  : ca-signed
	startDate      : Dec 17 12:00:00 2019 GMT
	subject        : C=US,O=HPE Nimble Storage,OU=www.hpe.com,CN=HPE Nimble Storage Intermediate CA
	subjectAltName : --
	pem            : -----BEGIN CERTIFICATE-----
					MIIE...MqQki3/b/
					-----END CERTIFICATE-----
#>
[CmdletBinding()]
Param()
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
    $Result = Invoke-A9API -uri '/certificates' -type 'GET'  
	if ( $Result.content ) 	
		{ $DataPS= $Result.content }
	else{ $DataPS = $Result}
	$DataPS = $DataPS | ConvertFrom-json
	If ( $DataPS.Members )
		{ $DataPS = $DataPS.members }
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $DataPS
		}
	else
		{	Write-Error "Failure:  Issuing Get-A9Certificate command." 
			return $Result.StatusDescription
		}
}	
}

Function Import-A9Certificate
{
<#      
.SYNOPSIS
	Imports a Certificate to a device
.DESCRIPTION
	Imports a Certificate to a device
.PARAMETER Service
	Specifies the service which the certificates can be imported.
	Valid service names are cim, cli, ekm-client, ekm-server, ldap, qw-client, qw-server, syslog-gen-client, syslog-gen-server, syslog-sec-client, syslog-sec-server, wsapi, vasa, and unified-server.
.PARAMETER Certificate
	Specifies the service certificate in PEM format.
	A Certificate Signing Request must be created before a certificate can be imported. At least one parameter, certificate or authorityChain, is required.
	Note that the unified-server establishes a common certificate among cim, cli, and wsapi. Also, the cim and wsapi services are restarted when a self-signed certificate is generated. This is required field.
	The Certtificate should be a very large object that follows this format; "-----BEGIN CERTIFICATE-----\n...your certificate...\n-----END CERTIFICATE-----"
.PARAMETER AuthorityChain
	Specifies the CA bundle in PEM format.
	At least one parameter, certificate or authorityChain is required.
	The Certtificate should be a very large object that follows this format; "-----BEGIN CERTIFICATE-----\n...your certificate...\n-----END CERTIFICATE-----"
.EXAMPLE    
	PS:> Import-A9Certificate -
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]
		[ValidateSet('cim','cli','ekm-client','ekm-server','ldap','qw-client','qw-server','syslog-gen-client','syslog-gen-server','syslog-sec-client','syslog-sec-server','wsapi','vasa','unified-server')]	
															[String]	$Service,
		[Parameter(Mandatory,ParameterSetName='CertOnly')]
		[Parameter(Mandatory,ParameterSetName='BertOnly')]
															[String]	$Certificate,
		[Parameter(Mandatory,ParameterSetName='AuthOnly')]
		[Parameter(Mandatory,ParameterSetName='BertOnly')]
															[String]	$AuthorityChain
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = [ordered]@{}	
	$body["action"] 		= 1
    $body["parameters"] 	= @{	'service' = $Service 	}
    If ($Certificate) 		{	$body["parameters"] += @{ 'certificate' = $Certificate }	}
	If ($AuthorityChain) 	{	$body["parameters"] += @{ 'authorityChain' = $AuthorityChain }	}

	$Result = $null
    $Result = Invoke-A9API -uri '/volumes' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return
		}
	else
		{	Write-Error "Failure:  While importing Certificate " 
			return $Result.StatusDescription
		}
}
}

Function Get-A9CapacityInfo
{
<#
.SYNOPSIS
	Overall system capacity.
.DESCRIPTION
	Overall system capacity.
.EXAMPLE
  PS:> Get-A9CapacityInfo
  
  totalMiB                      : 36608000
  allocated                     : @{totalAllocatedMiB=22524928; volumes=; system=}
  freeMiB                       : 14083072
  freeInitializedMiB            : 14083072
  freeUninitializedMiB          : 0
  unavailableCapacityMiB        : 0
  failedCapacityMiB             : 0
  overProvisionedVirtualSizeMiB : 87029350
  overProvisionedUsedMiB        : 9055263
  overProvisionedAllocatedMiB   : 4787680
  overProvisionedFreeMiB        : 14083072
#>
[CmdletBinding()]
Param()
Begin
{ Test-A9Connection -ClientType 'API' 
}
Process
{ $Result = Invoke-A9API -uri '/capacity' -type 'GET' 
  if($Result.StatusCode -eq 200)
    { $dataPS = ($Result.content | ConvertFrom-Json)
    }
  else
    { return $Result.StatusDescription
    }
  return $dataPS.allCapacity
}
}
