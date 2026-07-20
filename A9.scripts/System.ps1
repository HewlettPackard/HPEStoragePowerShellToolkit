## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9System
{
<#
.SYNOPSIS	
	Retrieve informations about the array.
.DESCRIPTION
	Retrieve informations about the array.
.PARAMETER Detailed
	Specifies that more detailed information about the system is displayed. THe use of this option will force the connection type to be SSH
.PARAMETER SystemParameters
	Specifies that the system parameters are displayed. THe use of this option will force the connection type to be SSH
.PARAMETER Fan
	Displays the system fan information. THe use of this option will force the connection type to be SSH
.PARAMETER SystemCapacity
	Displays the system capacity information in MiB. THe use of this option will force the connection type to be SSH
.PARAMETER vvSpace
	Displays the system capacity information in MiB with an emphasis on VVs. THe use of this option will force the connection type to be SSH
.PARAMETER Domainspace
	Displays the system capacity information broken down by domain in MiB. THe use of this option will force the connection type to be SSH
.PARAMETER Descriptor
	Displays the system descriptor properties. THe use of this option will force the connection type to be SSH
.PARAMETER DevType FC|NL|SSD
	Displays the system capacity information where the disks must have a device type string matching the specified device type; either Fast
	Class (FC), Nearline (NL), Solid State Drive (SSD). This option can only be issued with -space or -vvspace. THe use of this option will force the connection type to be SSH
.PARAMETER ShowRaw
    This parameter will force the SSH type command to return the raw data instead of the proper PowerShell object
.PARAMETER UseSSL
    This option will force the command to use an SSH connection type even if no other paramters are selected.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE
    PS:> Get-A9System_CLI 

	Command displays the Storage system information.such as system name, model, serial number, and system capacity information.
.EXAMPLE
    PS:> Get-A9System -useSSL

    ID        : 0x7F4DC
    Name      : ST10-DedicatedArcus
    Model     : HPE
    Serial    : Alletra
    Nodes     : Storage
    Master    : MP
    TotalCap  : 4UW0005393
    AllocCap  : 4
    FreeCap   : 1
    FailedCap : 87834624
.EXAMPLE
    PS:> Get-A9System

    Cmdlet executed successfully

    id                   : 521436
    name                 : ST10-DedicatedArcus
    systemVersion        : 10.4.2.9
    IPv4Addr             : 192.168.1.2
    model                : HPE Alletra Storage MP
    serialNumber         : 4UW0005393
    totalNodes           : 4
    masterNode           : 1
    onlineNodes          : {0, 1, 2, 3}
    clusterNodes         : {0, 1, 2, 3}
    chunkletSizeMiB      : 1024
    totalCapacityMiB     : 87834624
    ...
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(
        [Parameter(ParameterSetName='SSH')]	  [switch]    $Detailed,
        [Parameter(ParameterSetName='SSH')]   [switch]    $SystemParameters,
        [Parameter(ParameterSetName='SSH')]   [switch]    $Fan,
        [Parameter(ParameterSetName='SSH')]   [switch]    $SystemCapacity,
        [Parameter(ParameterSetName='SSH')]   [switch]    $vvSpace,
        [Parameter(ParameterSetName='SSH')]   [switch]    $DomainSpace,
        [Parameter(ParameterSetName='SSH')]   [switch]    $Descriptor,
        [Parameter(ParameterSetName='SSH')]   [String]    $DevType,
        [Parameter(ParameterSetName='SSH')]   [Switch]    $ShowRaw,
        [Parameter(ParameterSetName='SSH')]   [Switch]    $UseSSL,
		[Parameter(ParameterSetName='API')]	  [switch]	  $ShowAPI
)
Begin 
    {	if ( $PSCmdlet.ParameterSetName -eq 'API' )
            {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                    {	$PSetName = 'API'
                    }
                else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                            {	$PSetName = 'SSH'
                            }
                    }
            }
            elseif ( $PSCmdlet.ParameterSetName -eq 'SSH' )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process 
    {	switch ($PSetName)
        {   'API' 
                    {   $Result = Invoke-A9API -uri '/system' -type 'GET' 
                        if($Result.StatusCode -eq 200)
                            {	$dataPS = $Result.content | ConvertFrom-Json
                                write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                                return $dataPS
                            }
                        else
                            {	Write-Error "Failure:  While Executing Get-System" 
                                return $Result.StatusDescription
                            }
                    }
            'SSH'
                    {
                        $sysinfocmd = "showsys "
                        if ($Detailed) 			{    $sysinfocmd += " -d " 		}
                        if ($SystemParameters) 	{    $sysinfocmd += " -param "	}
                        if ($Fan) 				{    $sysinfocmd += " -fan "	}
                        if ($SystemCapacity) 	{    $sysinfocmd += " -space " 	}
                        if ($vvSpace) 			{    $sysinfocmd += " -vvspace "}
                        if ($DomainSpace) 		{    $sysinfocmd += " -domainspace "}
                        if ($Descriptor) 		{	 $sysinfocmd += " -desc "	}
                        if ($DevType) 			{    $sysinfocmd += " -devtype $DevType"}
                        write-verbose "The following command will be sent `n $Cmd"
                        $Result = Invoke-A9CLICommand -cmds  $sysinfocmd	
                        if ($ShowRaw -or $Detailed -or $VVSpace -or $Devtype -or $SystemCapacity) { Return $Result }
                        if($Result.Count -gt 1)
                            {	if ( (-not ( $Detailed -or $SystemParameters -or $Fan -or $SystemCapacity -or $VVSpace -or $DomainSpace -or $Descriptor -or $DevType)) )
                                            { 	$HeaderLine = 1
                                                $StartIndex=2
                                                $EndIndex=$Result.count-1
                                            }
                                        elseif ($DomainSpace)
                                            {	$tempFile = [IO.Path]::GetTempFileName()
                                                $HeaderLine = 'Domain,Legacy_Used,CPG_Used,CPG_Shared,CPG_Free,Unmapped,Total,Compact,Dedup,Compress,DataReduce,Overprov'
                                                Add-Content -Path $tempFile -Value $HeaderLine 
                                                $StartIndex=2
                                                $EndIndex=$Result.count-3
                                                foreach ($s in $Result[$StartIndex..$EndIndex])
                                                    {	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
                                                        Add-Content -Path $tempFile -Value $s
                                                    }
                                                $returndata = Import-Csv $tempFile
                                                Remove-Item $tempFile
												write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                                                return $returndata	
                                            }
                                        elseif($SystemParameters -or $Descriptor)
                                            {	$ReturnData=@{}
                                                if ($Descriptor) { $StartIndex = 1} else {StartIndex = 4}
                                                foreach ($s in $Result[$StartIndex..($Result.count-1)])
                                                        {	$s = ($s.split(':')).trim() 
                                                            if ($s.count -gt 2) 
                                                                {	$s[1] = $s[1..($s.count-1)] -join ":"
                                                                    write-host $s[1]
                                                                }
                                                            if ( $s[0] ) 
                                                                { $ReturnData.add($s[0], $s[1]) 
                                                                }
                                                        }	
                                                write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
												return $returndata	
                                            }
                            }
                        else{	write-warning "FAILURE"
                                Return $Result
                            }	
                        $tempFile = [IO.Path]::GetTempFileName()	
                        if ($Result)    {   $ResultHeader = ((($Result[$HeaderLine].split(' ')).trim()).trim('-') | where-object { $_ -ne '' } ) -join ','
                                            Add-Content -Path $tempFile -Value $ResultHeader
                                            foreach ($s in $Result[$StartIndex..$EndIndex])
                                                    {	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
                                                        Add-Content -Path $tempFile -Value $s
                                                    }	
                                            $Result = Import-Csv $tempFile
                                            Remove-Item $tempFile
                                        }
                        write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
						return $Result
                    }
        }
    }
}

Function Set-A9System 
{
<#
.SYNOPSIS
	Update storage system parameters
.DESCRIPTION
	Update storage system parameters
	You can set all of the system parameters in one request, but some updates might fail.
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
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE
	PS:> Set-A9System -RemoteSyslog $true
.EXAMPLE
	PS:> Set-A9System -remoteSyslogHost "0.0.0.0"
.EXAMPLE	
	PS:> Set-A9System -PortFailoverEnabled $true
.EXAMPLE	
	PS:> Set-A9System -DisableDedup $true
.EXAMPLE	
	PS:> Set-A9System -OverProvRatioLimit 3
.EXAMPLE	
	PS:> Set-A9System -AllowR5OnFCDrives $true
#>
[CmdletBinding()]
Param(	[Parameter()]	[boolean]	$RemoteSyslog,
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
		[Parameter()]	[boolean]	$ComplianceOfficerApproval,
		[Parameter()]	[switch]	$ShowAPI
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	if ($PSBoundParameters.Count -eq 0) 
		{ 	Write-warning "This command requires some setting that should be changed." 
			return
		}
	$body = @{}	
	$ObjMain=@{}	
	$Obj=@{}
	If ( $RemoteSyslog ) 				{	$Obj["remoteSyslog"] 			= $RemoteSyslog				}
	If ( $RemoteSyslogHost ) 			{	$Obj["remoteSyslogHost"] 		= "$($RemoteSyslogHost)"	}
	If ( $RemoteSyslogSecurityHost ) 	{	$Obj["remoteSyslogSecurityHost"]= "$($RemoteSyslogSecurityHost)"}
	If ( $PortFailoverEnabled ) 		{	$Obj["portFailoverEnabled"] 	= $PortFailoverEnabled		}
	If ( $FailoverMatchedSet ) 			{	$Obj["failoverMatchedSet"] 		= $FailoverMatchedSet		}
	If ( $DisableDedup ) 				{	$Obj["disableDedup"] 			= $DisableDedup				}
	If ( $DisableCompr ) 				{	$Obj["disableCompr"] 			= $DisableCompr				}
	If ( $OverProvRatioLimit ) 			{	$Obj["overProvRatioLimit"] 		= $OverProvRatioLimit		}
	If ( $OverProvRatioWarning ) 		{	$Obj["overProvRatioWarning"] 	= $OverProvRatioWarning		}
	If ( $AllowR5OnNLDrives ) 			{	$Obj["allowR5OnNLDrives"] 		= $AllowR5OnNLDrives		}
	If ( $AllowR5OnFCDrives ) 			{	$Obj["allowR5OnFCDrives"] 		= $AllowR5OnFCDrives		}
	If ( $ComplianceOfficerApproval ) 	{	$Obj["complianceOfficerApproval"]= $ComplianceOfficerApproval }
	if ( $ObjMain.Count -gt 0 )			{	$body["parameters"] 			= $ObjMain 					}	
	$ObjMain += $Obj
	if ( $ShowAPI)
		{    $Result = Invoke-A9API -uri '/system' -type 'PUT' -body $body -whatif
			return
		}
    $Result = Invoke-A9API -uri '/system' -type 'PUT' -body $body 
	if ( $Result.StatusCode -eq 200 )
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
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
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
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
		write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
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
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
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
Param(	[Parameter()]	  [switch]	  $ShowAPI)
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
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
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
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
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
															[String]	$AuthorityChain,
		[Parameter()]	 								 	[switch]	$ShowAPI
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
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
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
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
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
Param( 
		[Parameter()]	  [switch]	  $ShowAPI)
Begin
{ Test-A9Connection -ClientType 'API' 
}
Process
{ 	$Result = Invoke-A9API -uri '/capacity' -type 'GET' 
  	if($Result.StatusCode -ne 200)
		{ 	return $Result.StatusDescription
		}
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	$dataPS = ($Result.content | ConvertFrom-Json)
  	return $dataPS.allCapacity
}
}

Function Open-A9SSE 
{
<#   
.SYNOPSIS	
	Establishing a communication channel for Server-Sent Event (SSE).
.DESCRIPTION
	Establishing a communication channel for Server-Sent Event (SSE) 
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE
	PS:> Open-A9SSE
#>
[CmdletBinding()]
Param( 	[Parameter()]	  [switch]	  $ShowAPI	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	if ( $ShowAPI )
		{	$Result = Invoke-A9API -uri '/eventstream' -type 'GET' -whatif
			return
		}	
	$Result = Invoke-A9API -uri '/eventstream' -type 'GET' 
	if($Result.StatusCode -ne 200)
		{	write-error "FAILURE : While Executing Open-A9SSE."
			return $Result.StatusDescription
		}
	$dataPS = ($Result.content | ConvertFrom-Json).members
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	return $dataPS		
}	
}

Function Get-A9EventLog
{
<#
.SYNOPSIS	
	Get all past events from system event logs or a logged event information for the available resources. 
.DESCRIPTION
	Get all past events from system event logs or a logged event information for the available resources.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions. 
.EXAMPLE
	PS:> Get-A9EventLogs
#>
[CmdletBinding()]
Param(	[Parameter()]	  [switch]	  $ShowAPI )
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	Write-Progress -Activity "Invoke RestAPI Call (May take 30 seconds)" -status "10% Complete" -PercentComplete 10
	if ( $ShowAPI )
		{	$Result = Invoke-A9API -uri '/eventlog' -type 'GET' -whatif
			return
		}
	$Result = Invoke-A9API -uri '/eventlog' -type 'GET'	
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			$ItemCount = $dataPS.count
			Write-Progress -Activity "Processing $ItemCount Items..." -status "40% Complete" -PercentComplete 40
			$Current=1
			$NewObj = @(    foreach( $Item in $DataPS)	
                                        {   $NewItem=@{PSTypeName = "HPE.A9Storage.EventLog"}

                                            $Enum = $Item.class
												Switch ($Enum)
													{   1	{   $desc = 'ALERT'       	}
                                                        2	{   $desc = 'CREATION'  	}
                                                        3	{   $desc = 'REMOVAL'		}
                                                        4	{   $desc = 'MODIFICATION'  }
                                                        5	{   $desc = 'STATUS_CHANGE' }
                                                        99	{   $desc = 'UNKNOWN'       }
													}
												if ($Desc) 
													{   $NewItem['ClassDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}

												$Enum = $Item.category
												Switch ($Enum)
													{   1	{   $desc = 'LIFECYCE'      }
                                                        2	{   $desc = 'ALERT'  		}
													}
												if ($Desc) 
													{   $NewItem['CategoryDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}
												$Enum = $Item.severity
												Switch ($Enum)
													{   1	{   $desc = 'FATAL'     	}
                                                        2	{   $desc = 'CRITICAL'  	}
                                                        3	{   $desc = 'MAJOR'  		}
                                                        4	{   $desc = 'MINOR'  		}
                                                        5	{   $desc = 'DEGRADED'  	}
                                                        6	{   $desc = 'INFORMATIONAL'	}
                                                        7	{   $desc = 'DEBUG'  		}
                                                        99	{   $desc = 'UNKNOWN'  		}
													}
												if ($Desc) 
													{   $NewItem['SeverityDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}

												$Enum = $Item.component
												Switch ($Enum)
													{   2	{   $desc = 'VLUN'     	}
                                                        3	{   $desc = 'PORT'  	}
                                                        4	{   $desc = 'VOLUME'  	}
                                                        41	{   $desc = 'SFP'  		}
													}
												if ($Desc) 
													{   $NewItem['ComponentDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}
			
												$Enum = $Item.resource
												Switch ($Enum)
													{   2	{   $desc = 'VLUN'     	}
                                                        3	{   $desc = 'PORT'  	}
                                                        4	{   $desc = 'VOLUME'  	}
                                                    }
												if ($Desc) 
													{   $NewItem['ResourceDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}
											$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
											$DataSetType = "HPE.A9Storage.EventLog"
											$NewItem.PSTypeNames.Insert(0,$DataSetType)
											$DataSetType = $DataSetType + ".TypeName"
											$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
											[PSCustomObject]$NewItem
											
											[int]$Perc = ( ($Current / $ItemCount * 100) / 2 )  + 45
											if ( $Perc -ge ($LastPercCount + 5) )
													{	$LastPercCount += 5
														if ($Perc -le 100)
															{	Write-Progress -Activity "Processing $ItemCount Items..." -status "$($Perc)% Complete" -PercentComplete $Perc
																
															}
													}
											$Current += 1
										}
						            )
			Write-Progress -Activity "Processing $ItemCount Items..." -status "100% Complete" -PercentComplete 100
			start-sleep 3
			Write-Progress -Activity "Processing $ItemCount Items..." -Completed
			write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			return $NewObj		
		}
	else
		{	write-error "FAILURE : While Executing Get-A9EventLog."
			return $Result.StatusDescription
		}
}	
}

Function Get-A9WSAPI
{
<#
.SYNOPSIS	
	Get Getting WSAPI configuration information
.DESCRIPTION
	Get Getting WSAPI configuration information. The three types of information you may gather are the running 
    state (configinfo), the service status (via CLI), and the existing outstanding sessions (sessions via CLI).
.PARAMETER ServiceStatus
    Will return all of the service information regarding WSAPI from a CLI interrogation
.PARAMETER ConfigurationInformation
    Will return the WSAPI status of the current running WSAPI service.
.PARAMETER Session
    Will return the list of all outstanding WSAPI sessions from a CLI interrogation.
.PARAMETER ShowRaw
    This outputs the returned data without any formatting. Only available with CLI options of ServiceStatus and Sessions.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE
	PS:> Get-A9WSAPI -ConfigurationInformation

	Get Getting WSAPI configuration information
.EXAMPLE
    PS:> Get-A9WsApi -ServiceStatus

    service State                            : Enabled
    HPE GreenLake for Block Storage UI State : Active
    server State                             : Active
    HTTPS Port                               : 443
    Number of Sessions Created               : 0
    System Resource Usage                    : 192
    Number of Sessions Active                : 0
    Version                                  : 1.14.0
    Event Stream State                       : Enabled
    Max Number of SSE Sessions Allowed       : 5
    Number of SSE Sessions Created           : 0
    Number of SSE Sessions Active            : 0
    Session Timeout                          : 15 Minutes
    Policy                                   : no_per_user_limit
    API URL                                  : https://192.168.1.12/api/v1

    This command option REQUIREs an SSH type connection
.EXAMPLE
    PS:> Get-A9WsApi -Session

    This command option REQUIREs an SSH type connection
#>
[CmdletBinding()]
Param(  [Parameter(Mandatory, ParameterSetName='default')]      [switch]    $ServiceStatus,
        [Parameter(Mandatory, ParameterSetName='Session')]      [switch]    $Session,
        [Parameter(Mandatory, ParameterSetName='Config')]       [switch]    $ConfigurationInformation,
        [Parameter(ParameterSetname='default')]
        [Parameter(ParameterSetname='Session')]                 [switch]    $ShowRaw,
		[Parameter(ParameterSetName='Config')]	  				[switch]	$ShowAPI
     )

Process 
{	$Result = $null	
	$dataPS = $null	
    switch($PSCmdlet.ParameterSetName)
        {   'Config'    {   Test-A9Connection -ClientType 'API'
                            if ( $ShowAPI)
								{	$Result = Invoke-A9API -uri '/wsapiconfiguration' -type 'GET' -whatif 	
									return
								}
							$Result = Invoke-A9API -uri '/wsapiconfiguration' -type 'GET' 
                            if($Result.StatusCode -eq 200)
                                {	$dataPS = $Result.content | ConvertFrom-Json
                                    write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                                    return $dataPS
                                }
                            else
                                {	Write-Error "Failure:  While Executing Get-WSAPIConfigInfo" 
                                    return $Result.StatusDescription
                                }
                        }
            'default'   {   Test-A9Connection -ClientType 'SshClient' 
                            $Cmd = " showwsapi -d "
                            write-verbose "Executing the following SSH command `n`t $cmd"
                            $Result = Invoke-A9CLICommand -cmds  $Cmd
                            if ($ReturnRaw) { return $Result }
                            $ReturnTable=[ordered]@{}
                            foreach( $Line in $Result[1..$Result.count])
                            {   $LabelName = (($Line.split(' : '))[0]).trim(' ')
                                $DataValue = (($Line.split(' : '))[1]).trim(' ')
                                $ReturnTable["$LabelName"] = $DataValue
                            }
                            $Result = $ReturnTable | convertto-json | convertfrom-json
                            return $Result
                        }
            'Session'   {   Test-A9Connection -ClientType 'SshClient'
                            $Cmd = " showwsapisession "
                            write-verbose "Executing the following SSH command `n`t $cmd"
                            $Result = Invoke-A9CLICommand -cmds  $Cmd
                            if ($ShowRaw)   {   return $Result }
                            if($Result.Count -gt 2)
                                {   $tempFile = [IO.Path]::GetTempFileName()
                                    $ResultHeader = 'Id,Node,Name,Role,Client_IP_Addr,Connected_since,State,Session_Type'
                                    Add-Content -Path $tempFile -Value $ResultHeader
                                    foreach ($s in  $Result[1..($Result.count-1)] )
                                        {   $s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
                                            if ( -not ( $s.contains('-----') -or $s.contains('total') ) )
                                                {   Add-Content -Path $tempFile -Value $s
                                                }
                                        }
                                    $returndata = Import-Csv $tempFile
                                    Remove-Item  $tempFile
                                    $NewObj = @(    foreach( $Item in $returndata)	
														{   $NewItem=@{PSTypeName = "HPE.A9Storage.APISession"}
															$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
															$DataSetType = "HPE.A9Storage.APISession"
															$NewItem.PSTypeNames.Insert(0,$DataSetType)
															$DataSetType = $DataSetType + ".TypeName"
															$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
															[PSCustomObject]$NewItem
														}
												)
                                    write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
									return $NewObj
                                }
                                else
                                    {	return $Result
                                    } 
                        }	
        }
}
}