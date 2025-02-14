####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9Cert
{
<#
.SYNOPSIS
	Show information about SSL certificates of the Storage System.
.DESCRIPTION
	The command has two forms. The first is a table with a high level overview of the certificates used by the SSL Services. This table is
	customizable with the -showcols option. The second form provides detailed certificate information in either human readable format or in PEM (Privacy
	Enhanced Mail) format. It can also save the certificates in a specified file.
.PARAMETER Listcols
	Displays the valid table columns.
.PARAMETER Showcols
	Changes the columns displayed in the table.
.PARAMETER Service
	Displays only the certificates used by the service(s). Multiple services must be delimited by a comma.  Valid service names are cim, cli, ekm-client, ekm-server, ldap,
	syslog-gen-client, syslog-gen-server, syslog-sec-client, syslog-sec-server, wsapi, vasa, and unified-server.
.PARAMETER Type
	Displays only certificates of the specified type, e.g., only root CA. Multiple types must be delimited by a comma.  Valid types are csr, cert, intca, and rootca.
.PARAMETER Pem
	Displays the certificates in PEM format. When a filename is specified the certificates are exported to the file.
.PARAMETER Text
	Displays the certificates in human readable format. When a filename is specified the certificates are exported to the file.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	PS:> Get-A9Cert -Service unified-server -Pem
.EXAMPLE
	PS:> Get-A9Cert -Service unified-server -Text
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter()]										[switch]	$Listcols,
		[Parameter(ParameterSetName='ShowCols')]			[String]	$Showcols,
		[Parameter()]	
			[ValidateSet('cim','cli','ekm-client','ekm-server','ldap','syslog-gen-client','syslog-gen-server','syslog-sec-client','syslog-sec-server','wsapi','vasa','unified-server')]
															[String]	$Service,
		[Parameter()]
			[ValidateSet('csr','cert','intca','rootca')]	[String]	$Type,
		[Parameter(ParameterSetName='Pem',mandatory)]		[switch]	$Pem,
		[Parameter(ParameterSetName='Text',mandatory)]		[switch]	$Text,
		[Parameter()]										[Switch]	$ShowRaw

)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
	{	$Cmd = " showcert "
		if($Listcols)	{	$Cmd += " -listcols " }
		if($Showcols)	{	$Cmd += " -showcols $Showcols " }
		if($Service)	{	$Cmd += " -service $Service " }
		if($Type)		{	$Cmd += " -type $Type " }
		if($Pem)		{	$Cmd += " -pem " }
		if($Text)		{	$Cmd += " -text " }
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
	}
end
	{	if ($ShowRaw -or $Service -or $pem -or $Text -or $Showcols -or $ListCols) { return $Result }
		elseif($Result.count -gt 1)
			{	$tempFile = [IO.Path]::GetTempFileName()
				$LastItem = $Result.Count 
				foreach ($s in  $Result[0..$LastItem] )
					{	$s= [regex]::Replace($s,"^ ","")			
						$s= [regex]::Replace($s," +",",")	
						$s= [regex]::Replace($s,"-","")
						$s= $s.Trim()			
						$temp1 = $s -replace 'Enddate','Month,Date,Time,Year,Zone'
						$s = $temp1
						$sTemp1=$s				
						$sTemp = $sTemp1.Split(',')	
						if ([string]::IsNullOrEmpty($sTemp[3]))	{	$sTemp[3] = "--,--,--,--,---"	}				
						$newTemp= [regex]::Replace($sTemp,"^ ","")			
						$newTemp= [regex]::Replace($sTemp," ",",")				
						$newTemp= $newTemp.Trim()
						$s=$newTemp
						Add-Content -Path $tempfile -Value $s				
					}
				$returndata = Import-Csv $tempFile 
				Remove-Item  $tempFile
				write-host " Success : Executing Get-Cert" -ForegroundColor Green 
				return $returndata 	
			}
		return 
	}
}

Function Import-A9Cert
{
<#
.SYNOPSIS
	imports a signed certificate and supporting certificate authorities (CAs) for the Storage System SSL services.
.DESCRIPTION
	The Import Cert command allows a user to import certificates for a given service. The user can import a CA bundle containing the intermediate and/or
	root CAs prior to importing the service certificate. The CA bundle can also be imported alongside the service certificate.
.PARAMETER SSL_service
	Valid service names are cim, cli, ekm-client, ekm-server, ldap, syslog-gen-client, syslog-gen-server, syslog-sec-client, syslog-sec-server, wsapi, vasa, and unified-server.
.PARAMETER CA_bundle
	Allows the import of a CA bundle without importing a service certificate. Note the filename "stdin" can be used to paste the CA bundle into the CLI.
.PARAMETER Ca
	Allows the import of a CA bundle without importing a service certificate. Note the filename "stdin" can be used to paste the  CA bundle into the CLI.
.EXAMPLE
	PS:> Import-Cert -SSL_service wsapi -Service_cert  wsapi-service.pem
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory)]	[String]	$SSL_service,	
	[Parameter()]			[String]	$Service_cert, 
	[Parameter()]			[String]	$CA_bundle,
	[Parameter()]			[String]	$Ca
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$Cmd = " importcert "
		if($SSL_service)	{	$Cmd += " $SSL_service -f " }
		if($Service_cert) 	{	$Cmd += " $Service_cert " 	}
		if($CA_bundle) 		{	$Cmd += " $CA_bundle " 		}
		if($Ca) 			{	$Cmd += " -ca $Ca " 		}
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function New-A9Cert
{
<#
.SYNOPSIS
	Create self-signed SSL certificate or a certificate signing request (CSR) for the Storage System SSL services.
.DESCRIPTION
	The New Cert command creates a self-signed certificate or a certificate signing request for a specified service.
.PARAMETER SSL_service
	Valid service names are cim, cli, ekm-client, ekm-server, ldap, syslog-gen-client, syslog-gen-server, syslog-sec-client, syslog-sec-server, wsapi, vasa, and unified-server.
.PARAMETER Csr
	Creates a certificate signing request for the service. No certificates are modified and no services are restarted.
.PARAMETER Selfsigned
	Creates a self-signed certificate for the service. The previous certificate is removed and the service restarted. The intermediate and/or root certificate authorities for a service are not removed.
.PARAMETER Keysize
	Specifies the encryption key size in bits of the self-signed certificate. Valid values are 1024 and 2048. The default value is 2048.
.PARAMETER Days
	Specifies the valid days of the self-signed certificate. Valid values are between 1 and 3650 days (10 years). The default value is 1095 days (3 years).
.PARAMETER Country
	Specifies the value of country (C) attribute of the subject of the certificate.
.PARAMETER State
	Specifies the value of state (ST) attribute of the subject of the certificate.
.PARAMETER Locality
	Specifies the value of locality (L) attribute of the subject of the certificate.
.PARAMETER Organization
	Specifies the value of organization (O) attribute of the subject of the certificate.
.PARAMETER OrganizationalUnit
	Specifies the value of organizational unit (OU) attribute of the subject of the certificate.
.PARAMETER CommonName
	Specifies the value of common name (CN) attribute of the subject of the certificate. Over ssh, -CN must be specified.
.EXAMPLE
	PS:> New-A9Cert -SSL_service unified-server -Selfsigned -Keysize 2048 -Days 365
.EXAMPLE
	PS:> New-A9Cert -SSL_service wsapi -Selfsigned -Keysize 2048 -Days 365
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]
		[ValidateSet('cim','cli','ekm-client','ekm-server','ldap','syslog-gen-client','syslog-gen-server','syslog-sec-client','syslog-sec-server','wsapi','vasa','unified-server')]		
														[String]	$SSL_service,
		[Parameter(ParameterSetName='CSR',Mandatory)]	[switch]	$Csr,
		[Parameter(ParameterSetName='CSR',Mandatory)]	[switch]	$Selfsigned,
		[Parameter()]									[String]	$Keysize,
		[Parameter()]									[String]	$Days,
		[Parameter()]									[String]	$Country,
		[Parameter()]									[String]	$State,
		[Parameter()]									[String]	$Locality,
		[Parameter()]									[String]	$Organization,
		[Parameter()]									[String]	$OrganizationalUnit,
		[Parameter()]									[String]	$CommonName,
		[Parameter()]									[String]	$SAN
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$Cmd = " createcert "
		if($SSL_service)		{	$Cmd += " $SSL_service "			}	
		if($Csr) 				{	$Cmd += " -csr -f" 					}	 
		if($Selfsigned)			{	$Cmd += " -selfsigned -f" 			}
		if($Keysize) 			{	$Cmd += " -keysize $Keysize " 		} 
		if($Days)				{	$Cmd += " -days $Days " 			}
		if($Country)			{	$Cmd += " -C $Country " 			}
		if($State)				{	$Cmd += " -ST $State "				}
		if($Locality)			{	$Cmd += " -L $Locality " 			}
		if($Organization) 		{	$Cmd += " -O $Organization " 		}
		if($OrganizationalUnit)	{	$Cmd += " -OU $OrganizationalUnit " }
		if($CommonName)			{	$Cmd += " -CN $CommonName " 		}
		if($SAN)				{	$Cmd += " -SAN $SAN " 				}
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Remove-A9Cert
{
<#
.SYNOPSIS
	Removes SSL certificates from the Storage System.
.DESCRIPTION
	The Remove Cert command is used to remove certificates that are no longer trusted. In most cases it is better to overwrite the offending certificate
	with importcert. The user specifies which service to have its certificates removed. The removal can be limited to a specific type.
.PARAMETER SSL_Service_Name
	Valid service names are cim, cli, ekm-client, ekm-server, ldap, syslog-gen-client, syslog-gen-server, syslog-sec-client,
	syslog-sec-server, wsapi, vasa, and unified-server. The user may also specify all, which will remove certificates for all services.
.PARAMETER Type
	Allows the user to limit the removal to a specific type. Note that types are cascading. For example, intca will cause the service certificate to
	also be removed. Valid types are csr, cert, intca, and rootca.
.EXAMPLE
	PS:> Remove-A9Cert -SSL_Service_Name "cli" -Type "cert"
.EXAMPLE
	PS:> Remove-A9Cert -SSL_Service_Name "all" -Type "intca"
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)][ValidateSet('cim','cli','dscc','ekm-client','ekm-server','ldap','qw-client','qw-server','syslog-gen-client','syslog-gen-server','syslog-sec-client','syslog-sec-server','wsapi','unified-server','all')]
																	[String]	$SSL_Service_Name,	
		[Parameter()][ValidateSet('csr', 'cert','intca','rootca')]	[String]	$CertType
)
Begin
	{	Test-A9Connection -ClientType SshClient
	}
Process	
	{	$Cmd = " removecert "
		if($SSL_Service_Name)		{	$Cmd += " $SSL_Service_Name " }
		$Cmd += " -f "
		if($CertType) 				{	$Cmd += " -type $Type " }
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	} 
}

