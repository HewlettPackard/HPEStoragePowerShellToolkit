## 	©2025 Hewlett Packard Enterprise Development LP


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
	This command utilizes the SSH command 'CreateCert' 
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]
		[ValidateSet('cim','cli','ekm-client','ekm-server','ldap','syslog-gen-client','syslog-gen-server','syslog-sec-client','syslog-sec-server','wsapi','vasa','unified-server')]		
														[String]	$SSL_service,
		[Parameter(ParameterSetName='CSR',Mandatory)]	[switch]	$Csr,
		[Parameter(ParameterSetName='Self',Mandatory)]	[switch]	$Selfsigned,
		[Parameter()][ValidateSet(2048,3072,4096)]		[int]		$Keysize,
		[Parameter()][ValidateRange(1,3650)]			[int]		$Days,
		[Parameter()]									[String]	$Country,
		[Parameter()]									[String]	$State,
		[Parameter()]									[String]	$Locality,
		[Parameter()]									[String]	$Organization,
		[Parameter()]									[String]	$OrganizationalUnit,
		[Parameter()]									[String]	$CommonName,
		[Parameter()]									[String]	$SubjectAlternateName
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
		if($SubjectAlternateName){	$Cmd += " -SAN $SubjectAlternateName " 				}
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green 
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
	This command utilizes the SSH command 'RemoveCert'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)][ValidateSet('cim','cli','dscc','ekm-client','ekm-server','ldap','qw-client','qw-server','syslog-gen-client','syslog-gen-server','syslog-sec-client','syslog-sec-server','wsapi','unified-server','all')]
																	[String]	$SSL_Service_Name,	
		[Parameter()][ValidateSet('csr', 'cert','intca','rootca')]	[String]	$CertType
)
Begin
	{	Test-A9Connection -ClientType SshClient
	}
Process	
	{	$Cmd = " removecert $SSL_Service_Name -f "
		if($CertType) 				{	$Cmd += " -type $Type " }
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green 
		Return $Result
	} 
}

