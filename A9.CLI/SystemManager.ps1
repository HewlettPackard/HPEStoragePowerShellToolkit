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
.EXAMPLE
	PS:> Get-A9Cert -Service unified-server -Pem
.EXAMPLE
	PS:> Get-A9Cert -Service unified-server -Text
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
.PARAMETER File
	Specifies the export file of the -pem or -text option.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Listcols,
		[Parameter()]	[String]	$Showcols,
		[Parameter()]	[String]	$Service,
		[Parameter()]	[String]	$Type,
		[Parameter()]	[switch]	$Pem,
		[Parameter()]	[switch]	$Text,
		[Parameter()]	[String]	$File
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
	if($File)		{	$Cmd += " -file $File " }
	if($Listcols -Or $Pem -Or $Text)
		{	$Result = Invoke-A9CLICommand -cmds  $Cmd
			Return $Result
		}
	else
		{	$Result = Invoke-A9CLICommand -cmds  $Cmd
			Write-Verbose "Executing Function : Get-Cert Command -->" 
			if($Result.count -gt 1)
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
					Import-Csv $tempFile 
					Remove-Item  $tempFile 	
				}
			else{	return  $Result}
			if($Result.count -gt 1)	{	return  " Success : Executing Get-Cert"	}
			else					{		return  $Result	} 
		}
}
}

Function Get-A9Encryption
{
<#
.SYNOPSIS
	Show Data Encryption information.
.DESCRIPTION
	The Get-Encryption command shows Data Encryption information.
.PARAMETER D
	Provides details on the encryption status.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$D
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = " showencryption "
	if($D)	{	$Cmd += " -d " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	$LastItem = 0
			$Fcnt = 0
			if($D)	{	$Fcnt = 4
						$LastItem = $Result.Count -2
					}
			else		{	$LastItem = $Result.Count -0	}		
			$tempFile = [IO.Path]::GetTempFileName	
			foreach ($s in  $Result[$Fcnt..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim() 
					$temp1 = $s -replace 'AdmissionTime','Date,Time,Zone'
					$s = $temp1		
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item  $tempFile 	
		}
	if($Result.count -gt 1) {	return  " Success : Executing Get-Encryption" 	}
	else					{	return  $Result	} 
}
}

Function Get-A9SystemReporter
{
<#
.SYNOPSIS
    Displays the amount of space consumed by the various System Reporter databases on the System Reporter volume.
.DESCRIPTION
    Displays the amount of space consumed by the various System Reporter databases on the System Reporter volume.
.EXAMPLE
    Get-A9SR_CLI 
	shows how to display the System Reporter status:
.EXAMPLE
    Get-A9SR_CLI -Btsecs 10
.PARAMETER ldrg
	Displays which LD region statistic samples are available.  This is used with the -btsecs and -etsecs options.
.PARAMETER Btsecs
	Select the begin time in seconds for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the	current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$ldrg,
		[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = "showsr "
	if($ldrg)	{	$srinfocmd += "-ldrg "	}
	if($Btsecs)	{	$srinfocmd += "-btsecs $Btsecs "	}
	if($Etsecs)	{	$srinfocmd += "-etsecs $Etsecs "	}
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
	return  $Result	
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
.EXAMPLE
	PS:> Import-Cert -SSL_service wsapi -Service_cert  wsapi-service.pem
.PARAMETER SSL_service
	Valid service names are cim, cli, ekm-client, ekm-server, ldap, syslog-gen-client, syslog-gen-server, syslog-sec-client, syslog-sec-server, wsapi, vasa, and unified-server.
.PARAMETER CA_bundle
	Allows the import of a CA bundle without importing a service certificate. Note the filename "stdin" can be used to paste the CA bundle into the CLI.
.PARAMETER Ca
	Allows the import of a CA bundle without importing a service certificate. Note the filename "stdin" can be used to paste the  CA bundle into the CLI.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)]	[String]	$SSL_service,	
	[Parameter()]					[String]	$Service_cert, 
	[Parameter()]					[String]	$CA_bundle,
	[Parameter()]					[String]	$Ca
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
.EXAMPLE
	PS:> New-A9Cert -SSL_service unified-server -Selfsigned -Keysize 2048 -Days 365
.EXAMPLE
	PS:> New-A9Cert -SSL_service wsapi -Selfsigned -Keysize 2048 -Days 365
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
.PARAMETER C
	Specifies the value of country (C) attribute of the subject of the certificate.
.PARAMETER ST
	Specifies the value of state (ST) attribute of the subject of the certificate.
.PARAMETER L
	Specifies the value of locality (L) attribute of the subject of the certificate.
.PARAMETER O
	Specifies the value of organization (O) attribute of the subject of the certificate.
.PARAMETER OU
	Specifies the value of organizational unit (OU) attribute of the subject of the certificate.
.PARAMETER CN
	Specifies the value of common name (CN) attribute of the subject of the certificate. Over ssh, -CN must be specified.
.PARAMETER SAN
	Subject alternative name is a X509 extension that allows other pieces of information to be associated with the certificate. Multiple SANs may delimited with a comma.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]						[String]	$SSL_service,
		[Parameter(ParameterSetName='CSR',Mandatory=$true)]	[switch]	$Csr,
		[Parameter(ParameterSetName='CSR',Mandatory=$true)]	[switch]	$Selfsigned,
		[Parameter()]	[String]	$Keysize,
		[Parameter()]	[String]	$Days,
		[Parameter()]	[String]	$C,
		[Parameter()]	[String]	$ST,
		[Parameter()]	[String]	$L,
		[Parameter()]	[String]	$O,
		[Parameter()]	[String]	$OU,
		[Parameter()]	[String]	$CN,
		[Parameter()]	[String]	$SAN
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = " createcert "
	if($SSL_service)	{	$Cmd += " $SSL_service "}	
	if($Csr) 			{	$Cmd += " -csr -f" 		}	 
	if($Selfsigned)		{	$Cmd += " -selfsigned -f" }
	if($Keysize) 		{	$Cmd += " -keysize $Keysize " } 
	if($Days)			{	$Cmd += " -days $Days " }
	if($C)				{	$Cmd += " -C $C " 		}
	if($ST)				{	$Cmd += " -ST $ST "		}
	if($L)				{	$Cmd += " -L $L " 		}
	if($O) 				{	$Cmd += " -O $O " 		}
	if($OU)				{	$Cmd += " -OU $OU " 	}
	if($CN)				{	$Cmd += " -CN $CN " 	}
	if($SAN)			{	$Cmd += " -SAN $SAN " 	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function New-A9RCopyGroup_CLI
{
<#
.SYNOPSIS
	The New RCopyGroup command creates a remote-copy volume group.
.DESCRIPTION
    The New RCopyGroup command creates a remote-copy volume group.   
.EXAMPLE	
	PS:> New-A9RCopyGroup_CLI -GroupName AS_TEST -TargetName CHIMERA03 -Mode sync
.EXAMPLE
	PS:> New-A9RCopyGroup_CLI -GroupName AS_TEST1 -TargetName CHIMERA03 -Mode async
.EXAMPLE
	PS:> New-A9RCopyGroup_CLI -GroupName AS_TEST2 -TargetName CHIMERA03 -Mode periodic
.EXAMPLE
	PS:> New-A9RCopyGroup_CLI -domain DEMO -GroupName AS_TEST3 -TargetName CHIMERA03 -Mode periodic     
.PARAMETER domain
	Creates the remote-copy group in the specified domain.
.PARAMETER Usr_Cpg_Name
	Specify the local user CPG and target user CPG that will be used for volumes that are auto-created.
.PARAMETER Target_TargetCPG
	Specify the local user CPG and target user CPG that will be used for volumes that are auto-created.
.PARAMETER Snp_Cpg_Name
	Specify the local snap CPG and target snap CPG that will be used for volumes that are auto-created.
.PARAMETER Target_TargetSNP
	Specify the local snap CPG and target snap CPG that will be used for volumes that are auto-created.
.PARAMETER GroupName
	Specifies the name of the volume group, using up to 22 characters if the mirror_config policy is set, or up to 31 characters otherwise. This name is assigned with this command.	
.PARAMETER TargetName	
	Specifies the target name associated with this group.
.PARAMETER Mode 	
	sync—synchronous replication
	async—asynchronous streaming replication
	periodic—periodic asynchronous replication
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$GroupName,
		[Parameter(Mandatory=$true)]	[String]	$TargetName,	
		[Parameter()][ValidateSet("sync","async","periodic")]
						[String]	$Mode,
		[Parameter()]	[String]	$domain,
		[Parameter()]	[String]	$Usr_Cpg_Name,
		[Parameter()]	[String]	$Target_TargetCPG,
		[Parameter()]	[String]	$Snp_Cpg_Name,		
		[Parameter()]	[String]	$Target_TargetSNP
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd= "creatercopygroup"	
	if ($domain)	{	$cmd+=" -domain $domain"	}
	if ($Usr_Cpg_Name)	
		{	$cmd+=" -usr_cpg $Usr_Cpg_Name "
			if($Target_TargetCPG)
				{	$cmd+= " $TargetName"
					$cmd+= ":$Target_TargetCPG "			
				}
			else{	return "Target_TargetCPG is required with Usr CPG option"	}
		}
	if ($Snp_Cpg_Name)	
		{	$cmd+=" -snp_cpg $Snp_Cpg_Name "
			if($Target_TargetSNP)
				{	$cmd+= " $TargetName"
					$cmd+= ":$Target_TargetSNP "			
				}
			else
				{	return "Target_TargetSNP is required with Usr CPG option"
				}
		}
	if ($GroupName)	{	$cmd+=" $GroupName"	}
	if ($TargetName){	$cmd+=" $TargetName"}
	if ($Mode)		{	$cmd+=":$Mode "	}
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	write-verbose "  The command creates a remote-copy volume group..   " 	
	if([string]::IsNullOrEmpty($Result))
		{	return  "Success : Executing  New-RCopyGroup Command $Result"
		}
	else
		{	return  "FAILURE : While Executing  New-RCopyGroup 	$Result "
		} 	
}
}

Function New-A9RCopyGroupCPG_CLI
{
<#
.SYNOPSIS
	The New-RCopyGroupCPG command creates a remote-copy volume group.
.DESCRIPTION
    The New-RCopyGroupCPG command creates a remote-copy volume group.   
.EXAMPLE
	New-A9RCopyGroupCPG_CLI -GroupName ABC -TargetName XYZ -Mode Sync	
.EXAMPLE  
	New-A9RCopyGroupCPG_CLI -UsrCpg -LocalUserCPG BB -UsrTargetName XYZ -TargetUserCPG CC -GroupName ABC -TargetName XYZ -Mode Sync
.PARAMETER UsrCpg
.PARAMETER SnpCpg
.PARAMETER UsrTargetName
.PARAMETER SnpTargetName
.PARAMETER LocalUserCPG
	Specifies the local user CPG and target user CPG that will be used for volumes that are auto-created.
.PARAMETER TargetUserCPG
	-TargetUserCPG target:Targetcpg The local CPG will only be used after fail-over and recovery.
.PARAMETER LocalSnapCPG
	Specifies the local snap CPG and target snap CPG that will be used for volumes that are auto-created. 
.PARAMETER TargetSnapCPG
	-LocalSnapCPG  target:Targetcpg
	.PARAMETER domain
	Creates the remote-copy group in the specified domain.
.PARAMETER GroupName
	Specifies the name of the volume group, using up to 22 characters if the mirror_config policy is set, or up to 31 characters otherwise. This name is assigned with this command.	
.PARAMETER TargetName
	Specifies the target name associated with this group.
.PARAMETER Mode 	
	sync—synchronous replication
	async—asynchronous streaming replication
	periodic—periodic asynchronous replication
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$GroupName,
		[Parameter(Mandatory=$true)]	[String]	$TargetName,
		[Parameter(Mandatory=$true)][ValidateSet("sync","async","periodic")]
										[String]	$Mode,
		[Parameter()]	[String]	$domain,
		[Parameter()]	[Switch]	$UsrCpg,
		[Parameter()]	[String]	$LocalUserCPG,
		[Parameter()]	[String]	$TargetUserCPG,
		[Parameter()]	[String]	$UsrTargetName,
		[Parameter()]	[Switch]	$SnpCpg,
		[Parameter()]	[String]	$LocalSnapCPG,
		[Parameter()]	[String]	$TargetSnapCPG,
		[Parameter()]	[String]	$SnpTargetName
	)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd= "creatercopygroup"
	if ($domain)	{	$cmd+=" -domain $domain"	}	
	if($UsrCpg)
		{	$cmd+=" -usr_cpg"
			if ($LocalUserCPG)	{	$cmd+=" $LocalUserCPG"	}
			if ($UsrTargetName)	{	$cmd+=" $UsrTargetName"	}
			if ($TargetUserCPG)	{	$cmd+=":$TargetUserCPG "}
		}
	if($SnpCpg)
		{	$cmd+=" -snp_cpg"
			if ($LocalSnapCPG)	{	$cmd+=" $LocalSnapCPG"	}
			if ($SnpTargetName)	{	$cmd+=" $SnpTargetName"	}
			if ($TargetSnapCPG)	{	$cmd+=":$TargetSnapCPG "}
		}
	$cmd+=" $GroupName"	
	$cmd+=" $TargetName"
	$cmd+=":$Mode "
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	write-verbose "  The command creates a remote-copy volume group..   " 	
	if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing  New-RCopyGroupCPG Command $Result"	}
	else									{	return  "FAILURE : While Executing  New-RCopyGroupCPG 	$Result "	} 	
}
}

Function New-A9RCopyTarge_CLI
{
<#
.SYNOPSIS
	The New RCopyTarget command creates a remote-copy target definition.
.DESCRIPTION
    The New RCopyTarget command creates a remote-copy target definition.
.EXAMPLE  
	PS:> New-A9RCopyTarget_CLI -TargetName demo1 -RCIP -NSP_IP 1:2:3:10.1.1.1

	This Example creates a remote-copy target, with option N_S_P_IP Node ,Slot ,Port and IP address. as 1:2:3:10.1.1.1 for Target Name demo1
.EXAMPLE
	PS:> New-A9RCopyTarget_CLI -TargetName demo1 -RCIP -NSP_IP "1:2:3:10.1.1.1,1:2:3:10.20.30.40"

	This Example creates a remote-copy with multiple targets
.EXAMPLE 
	PS:> New-A9RCopyTarget_CLI -TargetName demo1 -RCFC -Node_WWN 1122112211221122 -NSP_WWN 1:2:3:1122112211221122

	This Example creates a remote-copy target, with option NSP_WWN Node ,Slot ,Port and WWN as 1:2:3:1122112211221122 for Target Name demo1
.EXAMPLE 
	PS:> New-A9RCopyTarget_CLI -TargetName demo1 -RCFC -Node_WWN 1122112211221122 -NSP_WWN "1:2:3:1122112211221122,1:2:3:2244224422442244"

	This Example creates a remote-copy of FC with multiple targets
.PARAMETER TargetName
	The name of the target definition to be created, specified by using up to 23 characters.
.PARAMETER RCIP
	remote copy over IP (RCIP).
.PARAMETER RCFC
	remote copy over Fibre Channel (RCFC).
.PARAMETER Node_WWN
	The node's World Wide Name (WWN) on the target system (Fibre Channel target only).
.PARAMETER NSP_IP
	Node number:Slot number:Port Number:IP Address of the Target to be created.
.PARAMETER NSP_WWN
	Node number:Slot number:Port Number:World Wide Name (WWN) address on the target system.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='IP', Mandatory=$true)]	[switch]	$RCIP,
		[Parameter(ParameterSetName='FC', Mandatory=$true)]	[switch]	$RCFC,
		[Parameter()]	[switch]	$Disabled,
		[Parameter()]	[String]	$TargetName,
		[Parameter(ParameterSetName='FC', Mandatory=$true)]	[String]	$Node_WWN,
		[Parameter(ParameterSetName='IP', Mandatory=$true)]	[String]	$NSP_IP,
		[Parameter(ParameterSetName='FC', Mandatory=$true)]	[String]	$NSP_WWN
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd= "creatercopytarget"
	if ($Disabled)		{		$cmd+=" -disabled "	}
	$cmd+=" $TargetName "
	if ($RCIP)		{	$s = $NSP_IP
						$s= [regex]::Replace($s,","," ")	
						$cmd+=" IP $s"	
					}
	if ($RCFC)		{	$s = $NSP_WWN
						$s= [regex]::Replace($s,","," ")	
						$cmd+=" FC $Node_WWN $s"
					}		
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	if([string]::IsNullOrEmpty($Result))	{	return  "Success : Executing New-RCopyTarget Command "	}
	else									{	return  "FAILURE : While Executing New-RCopyTarget $Result "	} 	
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
.EXAMPLE
	PS:> Remove-A9Cert -SSL_Service_Name "xyz" -Type "xyz"
.EXAMPLE
	PS:> Remove-A9Cert -SSL_Service_Name "all" -Type "xyz"
.PARAMETER SSL_Service_Name
	Valid service names are cim, cli, ekm-client, ekm-server, ldap, syslog-gen-client, syslog-gen-server, syslog-sec-client,
	syslog-sec-server, wsapi, vasa, and unified-server. The user may also specify all, which will remove certificates for all services.
.PARAMETER F
	Skips the prompt warning the user of which certificates will be removed and which services will be restarted.  
.PARAMETER Type
	Allows the user to limit the removal to a specific type. Note that types are cascading. For example, intca will cause the service certificate to
	also be removed. Valid types are csr, cert, intca, and rootca.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$SSL_Service_Name,	
		[Parameter()]	[switch]	$F,
		[Parameter()][ValidateSet('csr', 'cert','intca','rootca')]	[String]	$Type
)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$Cmd = " removecert "
	if($SSL_Service_Name)	{	$Cmd += " $SSL_Service_Name " }
	if($F)					{	$Cmd += " -f "}
	if($Type) 				{	$Cmd += " -type $Type " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Measure-A9Upgrade
{
<#
.SYNOPSIS
	Determine if a system can do an online upgrade. (HIDDEN)
.PARAMETER Allow_singlepathhost
	Overrides the default behavior of preventing an online upgrade if a host is at risk of losing connectivity to the array due to only having a
	single access path to the StoreServ. Use of this option will result in a loss of connectivity for the host when the path to the array disconnects
	as the node reboots to the new version. This option should be used with extreme caution.
.PARAMETER Debug
	Display debug level information from check scripts.
.PARAMETER Extraverbose
	Display test output, even for passing or not applicable scripts.
.PARAMETER Getpostabortresults
	Displays results of the latest set of postabort scripts.
.PARAMETER Getresults
	Displays results of the latest set of scripts that have been run (except
	postabort scripts).
.PARAMETER Getworkarounds
	Displays information about workarounds that apply to an upgrade.
.PARAMETER Nopatch
	Do not check for any checkupgrade update packages.
.PARAMETER Offline
	Checks that apply only to online upgrades will be skipped.
.PARAMETER Phase <phasename>
	Set of scripts to run. phasename can be any one of the following:
	postabort, postcheck, postchecklist, postunpack, preboot, precheck,
	prechecklist, preswitch, preupgrade, preupgradelist
.PARAMETER Revertnode
	Used to check when reverting nodes as part of aborting an upgrade.
.PARAMETER Verbose
	Display output from the checkupgrade update package check.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Allow_singlepathhost,
		[Parameter()]	[switch]	$Extraverbose,
		[Parameter()]	[switch]	$Getpostabortresults,
		[Parameter()]	[switch]	$Getresults,	
		[Parameter()]	[switch]	$Getworkarounds,
		[Parameter()]	[switch]	$Nopatch,	
		[Parameter()]	[switch]	$Offline,	
		[Parameter()][ValidateSet('postabort', 'postcheck', 'postchecklist', 'postunpack', 'preboot', 'precheck', 'prechecklist', 'preswitch', 'preupgrade', 'preupgradelist')]	
						[String]	$Phase,	
		[Parameter()]	[switch]	$Revertnode
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = " checkupgrade "
	if($Allow_singlepathhost)	{	$Cmd += " -allow_singlepathhost " }
	if($Debug)					{	$Cmd += " -debug " }
	if($Extraverbose)			{	$Cmd += " -extraverbose " }
	if($Getpostabortresults)	{	$Cmd += " -getpostabortresults " }
	if($Getresults) 			{	$Cmd += " -getresults " }
	if($Getworkarounds)			{	$Cmd += " -getworkarounds " }
	if($Nopatch)				{	$Cmd += " -nopatch " }
	if($Offline)				{	$Cmd += " -offline " }
	if($Phase)					{	$Cmd += " -phase $Phase " }
	if($Revertnode)				{	$Cmd += " -revertnode " }
	if($Verbose)				{	$Cmd += " -verbose " }
$Result = Invoke-A9CLICommand -cmds  $Cmd
Return $Result
}
}

Function Optimize-A9LogicalDisk
{
<#
.SYNOPSIS
	Change the layout of a logical disk. 
.DESCRIPTION
	The Optimize command is used to make changes to a logical disk (LD) by creating a new LD and moving regions from the original LD to the new LD.
	The new LD will always have the same space type (SA, SD, USR) as the original LD.

    If the original LD belongs to a CPG, the new LD inherits the characteristics of that CPG. SA and SD space LDs have
    growth and allocations blocked so the original LD can be completely emptied during the tune.

    If the original LD does not belong to a CPG, a new LD will be created, inheriting the characteristics of the original LD.

    When a new LD is created it will spread to whatever PDs are available as determined by availability and pattern rules.

    The options detailed below can be used to control some aspects of the new LD.
.PARAMETER LD_name
	Name of the LD to tune.
.PARAMETER Waittask
	Wait for the command to complete before returning.
.PARAMETER DR
	Specifies that the command is a dry run and that the logical disk will not be tuned. The command will return
	any error messages that would be displayed or a summary of the actions that would be performed.
.PARAMETER Shared
	Where possible, share the destination LDs and do not create new LDs.
.PARAMETER Regions 
	Number of regions to move at a time. Range is 1-1024, default is 1024.
.PARAMETER Tunesys
	Only to be used when called from tunesys. When present, tuneld will update task information in the calling tunesys
	task with progress information. Also, when present tuneld will exit the CLI if certain errors occur, otherwise only an error will be displayed.
.PARAMETER Tunenodech
	Only to be used when called from tunenodech. When present tuneld will exit the CLI if certain errors occur, otherwise only an error will be displayed.
.PARAMETER Preserved
	Only to be used when source LD is in a preserved state. This option will move all good regions from the source LD to a new LD.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$Waittask,	
		[Parameter(ValueFromPipeline=$true)]	[switch]	$DR,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Shared,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Regions,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Tunesys,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Tunenodech,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Preserved,
		[Parameter(Mandatory=$true)]			[String]	$LD_name
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = " tuneld -f "
	if($Waittask)	{	$Cmd += " -waittask "}
	if($DR)			{	$Cmd += " -dr " }
	if($Shared) 	{	$Cmd += " -shared " }
	if($Regions)	{	$Cmd += " -regions $Regions " }
	if($Tunesys)	{	$Cmd += " -tunesys " }
	if($Tunenodech) {	$Cmd += " -tunenodech " }
	if($Preserved)	{	$Cmd += " -preserved " }
	if($LD_name)	{	$Cmd += " $LD_name " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
Return $Result
}
}

Function Optimize-A9Node
{
<#
.SYNOPSIS
	Rebalance PD utilization on a node after upgrades. (HIDDEN)
.DESCRIPTION 
    The command is used to analyze and detect poor layout and disk utilization across PDs with a specified node owner.
    Rebalancing is achieved using a combination of chunklet movement and re-laying out LDs associated with the node.
.PARAMETER Node
	The ID of the node to be tuned. <number> must be in the range 0-7. This parameter must be supplied.
.PARAMETER Chunkpct 
	Controls the detection of underutilized PDs associated with a node. The average utilization of all PDs of a devtype is calculated and
	any PD with a utilization of (average - <percentage>) will trigger node tuning for that devtype. For example, if the average is 70%
	and <percentage> is 10%, then the threshold will be 60%. <percentage> must be between 1 and 100. The default value is 10.
.PARAMETER Maxchunk 
	Controls how many chunklets are moved from each PD per move
	operation. <number> must be between 1 and 8. The default value
	is 8.
.PARAMETER Fulldiskpct 
	If a PD has more than <percentage> of its capacity utilized, chunklet movement is used to reduce its usage to <percentage> before LD tuning
	is used to complete the rebalance. e.g. if a PD is 98% utilized and <percentage> is 90, chunklets will be redistributed to other PDs until the
	utilization is less than 90%. If <percentage> is less than the devtype average then the calculated average will be used instead.
	<percentage> must be between 1 and 100. The default value is 90.
.PARAMETER Devtype 
	Specifies a comma separated list of one or more devtypes to be tuned. <devtype> can be one of SSD, FC or NL. Default is all devtypes. All named devtypes must be present on the node being tuned.
.PARAMETER DR
	Perform a dry-run analysis of the system and report details on what tuning would be performed with the supplied settings.  
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter(ValueFromPipeline=$true)]	[String]	$Node,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Chunkpct,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Maxchunk,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Fulldiskpct,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Devtype,
	[Parameter(ValueFromPipeline=$true)]	[switch]	$DR
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = " tunenodech -f "
	if($Node)		{	$Cmd += " -node $Node " }
	if($Chunkpct) 	{	$Cmd += " -chunkpct $Chunkpct " }
	if($Maxchunk)	{	$Cmd += " -maxchunk $Maxchunk " }
	if($Fulldiskpct){	$Cmd += " -fulldiskpct $Fulldiskpct " }
	if($Devtype)	{	$Cmd += " -devtype $Devtype " }
	if($DR) 		{	$Cmd += " -dr " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Start-A9SystemTeporter
{
<#
.SYNOPSIS
    To start System reporter.
.DESCRIPTION
    To start System reporter.
.EXAMPLE
    PS:> Start-A9SystemTeporter

	Starts System Reporter
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()
Begin
{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
}
Process	
{	$srinfocmd = "startsr -f "
	write-verbose "System reporter command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
	if(-not $Result)	{	return "Success: Started System Reporter $Result"	}
	elseif($Result -match "Cannot startsr, already started")	{	Return "Command Execute Successfully :- Cannot startsr, already started"	}
	else	{	return $Result	}		
}
}

Function Stop-A9SSystemReporter
{
<#
.SYNOPSIS
    To stop System reporter.
.DESCRIPTION
    To stop System reporter.
.EXAMPLE
    PS:> Stop-A9SSystemReporter

	Stop System Reporter
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()
Begin
{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
}
Process	
{	$srinfocmd = "stopsr -f "
	write-verbose "System reporter command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
	if(-not $Result)	{	return "Success: Stopped System Reporter $Result"	}
	else				{	return $Result	}
}
}
# SIG # Begin signature block
# MIIt2QYJKoZIhvcNAQcCoIItyjCCLcYCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAEtgYewGIt
# fGVtirygyO+qVjNiDVN5C1bFtD6K7ZHDkbkv7lUz5jQG04U5cukguAO4u6ipTNw4
# NwKauwDI7rU7oIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5YwghuSAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQBy8Mucc5GjCRXTIJW743fU0qJsvi1uqsfn9MS9jtXGUmIetSoQW0ODt
# DQql6j9Nb4ero8XdaGvq/Jg7u7MOWIEwDQYJKoZIhvcNAQEBBQAEggGAI20m/SdC
# Xm7lLy4kB5o969yYfskkdni638G9yXuOQYf1zteytpQIwdT8CBrXbpGaIdPZMuju
# wp4q64f8/KpilZi+uZSJua/5D1CewfvaqicMX+Qsfl7noslkgTtPT+LPekTpix3p
# ihCYo/+Glwg4UBpZlZtA2wbKp/0yQuBQ6Ip0KYxkEv/jVPBaL7qsLCpR6U973u8h
# dKqUqJRNcT9Q5dPCzRRGZ175+tr0NVZELbYyzomF4xB1vT8JRO0kBjY4LhjumBdc
# Yr4NLw5z3WDhrFsb4RPjfQeIKkT1Z1GWrNpploMsrpyTrBt2YBRgzj+6RxUUgcuc
# CISUnDtTmVuGkfX3S9Hcb32cdE7w8uD5vwR28I/6jnPyuv0ur23A/yZa9tVmwE/b
# 6BTx5WBFg2qcz8uVPKdxEB+sWfqYZQ/Qyu44IEwJB7sqjMyggRjK10cCHXTXwkGI
# 1nHXr5NBGj6H0bGDf8jee6xAnkzun8D9E6i/q3NOrj+TUvVb9jVJiz+OoYIY3zCC
# GNsGCisGAQQBgjcDAwExghjLMIIYxwYJKoZIhvcNAQcCoIIYuDCCGLQCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQQGCyqGSIb3DQEJEAEEoIH0BIHxMIHuAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMOkiDVstmgcrgN+D9Il8dlUv+299UUt2
# R8IJpgUl34jNtYplecR/IoZYXzgEI7AZFwIVAPBtDAuteX2l2lsHrlZ306UL+Mum
# GA8yMDI0MDczMTE5MjcwOFqgcqRwMG4xCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpN
# YW5jaGVzdGVyMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMTJ1Nl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNaCCEv8wggZdMIIE
# xaADAgECAhA6UmoshM5V5h1l/MwS2OmJMA0GCSqGSIb3DQEBDAUAMFUxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgQ0EgUjM2MB4XDTI0MDExNTAwMDAwMFoX
# DTM1MDQxNDIzNTk1OVowbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1hbmNoZXN0
# ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2VjdGlnbyBQ
# dWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1MIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAjdFn9MFIm739OEk6TWGBm8PY3EWlYQQ2jQae45iWgPXU
# GVuYoIa1xjTGIyuw3suUSBzKiyG0/c/Yn++d5mG6IyayljuGT9DeXQU9k8GWWj2/
# BPoamg2fFctnPsdTYhMGxM06z1+Ft0Bav8ybww21ii/faiy+NhiUM195+cFqOtCp
# JXxZ/lm9tpjmVmEqpAlRpfGmLhNdkqiEuDFTuD1GsV3jvuPuPGKUJTam3P53U4LM
# 0UCxeDI8Qz40Qw9TPar6S02XExlc8X1YsiE6ETcTz+g1ImQ1OqFwEaxsMj/WoJT1
# 8GG5KiNnS7n/X4iMwboAg3IjpcvEzw4AZCZowHyCzYhnFRM4PuNMVHYcTXGgvuq9
# I7j4ke281x4e7/90Z5Wbk92RrLcS35hO30TABcGx3Q8+YLRy6o0k1w4jRefCMT7b
# 5mTxtq5XPmKvtgfPuaWPkGZ/tbxInyNDA7YgOgccULjp4+D56g2iuzRCsLQ9ac6A
# N4yRbqCYsG2rcIQ5INTyI2JzA2w1vsAHPRbUTeqVLDuNOY2gYIoKBWQsPYVoyzao
# BVU6O5TG+a1YyfWkgVVS9nXKs8hVti3VpOV3aeuaHnjgC6He2CCDL9aW6gteUe0A
# mC8XCtWwpePx6QW3ROZo8vSUe9AR7mMdu5+FzTmW8K13Bt8GX/YBFJO7LWzwKAUC
# AwEAAaOCAY4wggGKMB8GA1UdIwQYMBaAFF9Y7UwxeqJhQo1SgLqzYZcZojKbMB0G
# A1UdDgQWBBRo76QySWm2Ujgd6kM5LPQUap4MhTAOBgNVHQ8BAf8EBAMCBsAwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBKBgNVHSAEQzBBMDUG
# DCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29t
# L0NQUzAIBgZngQwBBAIwSgYDVR0fBEMwQTA/oD2gO4Y5aHR0cDovL2NybC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3JsMHoGCCsG
# AQUFBwEBBG4wbDBFBggrBgEFBQcwAoY5aHR0cDovL2NydC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3J0MCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAYEAsNwuyfpP
# NkyKL/bJT9XvGE8fnw7Gv/4SetmOkjK9hPPa7/Nsv5/MHuVus+aXwRFqM5Vu51qf
# rHTwnVExcP2EHKr7IR+m/Ub7PamaeWfle5x8D0x/MsysICs00xtSNVxFywCvXx55
# l6Wg3lXiPCui8N4s51mXS0Ht85fkXo3auZdo1O4lHzJLYX4RZovlVWD5EfwV6Ve1
# G9UMslnm6pI0hyR0Zr95QWG0MpNPP0u05SHjq/YkPlDee3yYOECNMqnZ+j8onoUt
# Z0oC8CkbOOk/AOoV4kp/6Ql2gEp3bNC7DOTlaCmH24DjpVgryn8FMklqEoK4Z3Io
# UgV8R9qQLg1dr6/BjghGnj2XNA8ujta2JyoxpqpvyETZCYIUjIs69YiDjzftt37r
# QVwIZsfCYv+DU5sh/StFL1x4rgNj2t8GccUfa/V3iFFW9lfIJWWsvtlC5XOOOQsw
# r1UmVdNWQem4LwrlLgcdO/YAnHqY52QwnBLiAuUnuBeshWmfEb5oieIYMIIGFDCC
# A/ygAwIBAgIQeiOu2lNplg+RyD5c9MfjPzANBgkqhkiG9w0BAQwFADBXMQswCQYD
# VQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0
# aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAw
# MFoXDTM2MDMyMTIzNTk1OVowVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3Rp
# Z28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGlu
# ZyBDQSBSMzYwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQDNmNhDQatu
# givs9jN+JjTkiYzT7yISgFQ+7yavjA6Bg+OiIjPm/N/t3nC7wYUrUlY3mFyI32t2
# o6Ft3EtxJXCc5MmZQZ8AxCbh5c6WzeJDB9qkQVa46xiYEpc81KnBkAWgsaXnLURo
# YZzksHIzzCNxtIXnb9njZholGw9djnjkTdAA83abEOHQ4ujOGIaBhPXG2NdV8TNg
# FWZ9BojlAvflxNMCOwkCnzlH4oCw5+4v1nssWeN1y4+RlaOywwRMUi54fr2vFsU5
# QPrgb6tSjvEUh1EC4M29YGy/SIYM8ZpHadmVjbi3Pl8hJiTWw9jiCKv31pcAaeij
# S9fc6R7DgyyLIGflmdQMwrNRxCulVq8ZpysiSYNi79tw5RHWZUEhnRfs/hsp/fwk
# Xsynu1jcsUX+HuG8FLa2BNheUPtOcgw+vHJcJ8HnJCrcUWhdFczf8O+pDiyGhVYX
# +bDDP3GhGS7TmKmGnbZ9N+MpEhWmbiAVPbgkqykSkzyYVr15OApZYK8CAwEAAaOC
# AVwwggFYMB8GA1UdIwQYMBaAFPZ3at0//QET/xahbIICL9AKPRQlMB0GA1UdDgQW
# BBRfWO1MMXqiYUKNUoC6s2GXGaIymzAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/
# BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAECjAIMAYGBFUd
# IAAwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0
# aWdvUHVibGljVGltZVN0YW1waW5nUm9vdFI0Ni5jcmwwfAYIKwYBBQUHAQEEcDBu
# MEcGCCsGAQUFBzAChjtodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJs
# aWNUaW1lU3RhbXBpbmdSb290UjQ2LnA3YzAjBggrBgEFBQcwAYYXaHR0cDovL29j
# c3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBABLXeyCtDjVYDJ6BHSVY
# /UwtZ3Svx2ImIfZVVGnGoUaGdltoX4hDskBMZx5NY5L6SCcwDMZhHOmbyMhyOVJD
# wm1yrKYqGDHWzpwVkFJ+996jKKAXyIIaUf5JVKjccev3w16mNIUlNTkpJEor7edV
# JZiRJVCAmWAaHcw9zP0hY3gj+fWp8MbOocI9Zn78xvm9XKGBp6rEs9sEiq/pwzvg
# 2/KjXE2yWUQIkms6+yslCRqNXPjEnBnxuUB1fm6bPAV+Tsr/Qrd+mOCJemo06ldo
# n4pJFbQd0TQVIMLv5koklInHvyaf6vATJP4DfPtKzSBPkKlOtyaFTAjD2Nu+di5h
# ErEVVaMqSVbfPzd6kNXOhYm23EWm6N2s2ZHCHVhlUgHaC4ACMRCgXjYfQEDtYEK5
# 4dUwPJXV7icz0rgCzs9VI29DwsjVZFpO4ZIVR33LwXyPDbYFkLqYmgHjR3tKVkhh
# 9qKV2WCmBuC27pIOx6TYvyqiYbntinmpOqh/QPAnhDgexKG9GX/n1PggkGi9HCap
# Zp8fRwg8RftwS21Ln61euBG0yONM6noD2XQPrFwpm3GcuqJMf0o8LLrFkSLRQNwx
# PDDkWXhW+gZswbaiie5fd/W2ygcto78XCSPfFWveUOSZ5SqK95tBO8aTHmEa4lpJ
# VD7HrTEn9jb1EGvxOb1cnn0CMIIGgjCCBGqgAwIBAgIQNsKwvXwbOuejs902y8l1
# aDANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBK
# ZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRS
# VVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlv
# biBBdXRob3JpdHkwHhcNMjEwMzIyMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjBXMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAiJ3YuUVnnR3d6LkmgZpUVMB8SQWbzFoVD9mU
# EES0QUCBdxSZqdTkdizICFNeINCSJS+lV1ipnW5ihkQyC0cRLWXUJzodqpnMRs46
# npiJPHrfLBOifjfhpdXJ2aHHsPHggGsCi7uE0awqKggE/LkYw3sqaBia67h/3awo
# qNvGqiFRJ+OTWYmUCO2GAXsePHi+/JUNAax3kpqstbl3vcTdOGhtKShvZIvjwulR
# H87rbukNyHGWX5tNK/WABKf+Gnoi4cmisS7oSimgHUI0Wn/4elNd40BFdSZ1Ewpu
# ddZ+Wr7+Dfo0lcHflm/FDDrOJ3rWqauUP8hsokDoI7D/yUVI9DAE/WK3Jl3C4LKw
# Ipn1mNzMyptRwsXKrop06m7NUNHdlTDEMovXAIDGAvYynPt5lutv8lZeI5w3MOlC
# ybAZDpK3Dy1MKo+6aEtE9vtiTMzz/o2dYfdP0KWZwZIXbYsTIlg1YIetCpi5s14q
# iXOpRsKqFKqav9R1R5vj3NgevsAsvxsAnI8Oa5s2oy25qhsoBIGo/zi6GpxFj+mO
# dh35Xn91y72J4RGOJEoqzEIbW3q0b2iPuWLA911cRxgY5SJYubvjay3nSMbBPPFs
# yl6mY4/WYucmyS9lo3l7jk27MAe145GWxK4O3m3gEFEIkv7kRmefDR7Oe2T1HxAn
# ICQvr9sCAwEAAaOCARYwggESMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKy
# A2bLMB0GA1UdDgQWBBT2d2rdP/0BE/8WoWyCAi/QCj0UJTAOBgNVHQ8BAf8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAE
# CjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1
# c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMDUG
# CCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEADr5lQe1oRLjlocXUEYfktzsljOt+2sgX
# ke3Y8UPEooU5y39rAARaAdAxUeiX1ktLJ3+lgxtoLQhn5cFb3GF2SSZRX8ptQ6Iv
# uD3wz/LNHKpQ5nX8hjsDLRhsyeIiJsms9yAWnvdYOdEMq1W61KE9JlBkB20XBee6
# JaXx4UBErc+YuoSb1SxVf7nkNtUjPfcxuFtrQdRMRi/fInV/AobE8Gw/8yBMQKKa
# Ht5eia8ybT8Y/Ffa6HAJyz9gvEOcF1VWXG8OMeM7Vy7Bs6mSIkYeYtddU1ux1dQL
# bEGur18ut97wgGwDiGinCwKPyFO7ApcmVJOtlw9FVJxw/mL1TbyBns4zOgkaXFnn
# fzg4qbSvnrwyj1NiurMp4pmAWjR+Pb/SIduPnmFzbSN/G8reZCL4fvGlvPFk4Uab
# /JVCSmj59+/mB2Gn6G/UYOy8k60mKcmaAZsEVkhOFuoj4we8CYyaR9vd9PGZKSin
# aZIkvVjbH/3nlLb0a7SBIkiRzfPfS9T+JesylbHa1LtRV9U/7m0q7Ma2CQ/t392i
# oOssXW7oKLdOmMBl14suVFBmbzrt5V5cQPnwtd3UOTpS9oCG+ZZheiIvPgkDmA8F
# zPsnfXW5qHELB43ET7HHFHeRPRYrMBKjkb8/IN7Po0d0hQoF4TeMM+zYAJzoKQnV
# KOLg8pZVPT8xggSRMIIEjQIBATBpMFUxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9T
# ZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3RpZ28gUHVibGljIFRpbWUgU3Rh
# bXBpbmcgQ0EgUjM2AhA6UmoshM5V5h1l/MwS2OmJMA0GCWCGSAFlAwQCAgUAoIIB
# +TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0
# MDczMTE5MjcwOFowPwYJKoZIhvcNAQkEMTIEMHsDEqyAmig1/+yZ1OOeK7YXRniM
# erPAElwNkPdf8ZYN4Lq38u0ZaK9yfLeppDwLKjCCAXoGCyqGSIb3DQEJEAIMMYIB
# aTCCAWUwggFhMBYEFPhgmBmm+4gs9+hSl/KhGVIaFndfMIGHBBTGrlTkeIbxfD1V
# EkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KCYXzQkDXEkd6S
# wULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJz
# ZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNU
# IE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEBBQAEggIALgtw
# nr8YX//UdjcSLvm4HVplgfk8f0Tm0yUyUzrmjBz6F8TCkt9sKCFtn02eAEdqr0t9
# 3gd30SQBqNsk97wtDYFivGkmBWkYZaRfXm6jtaVPg9iRKVRTfNDOA13GQ7IKCbBi
# pFKddHruDC1SRCzW7Kb6xg/mOe8f/lepUd/D/Ge83oY3ACKdKwXkggjEe5/zswCs
# I1jAQbfEFXFlFW2rA+CPxuCx7/Cxn1U66c0KvgxY12cFwMERhH1dEbZyGlsnXFH2
# WQMRVZwwZnlAyKedo5+kItkLJUnKYFwCHh0Cn/ymvQi+0HjG3btQTgfgSGVVAt0D
# uC2vs3EH42N+VXFTR+g9aiU6UAuDwHC/5t989EfqV5wFyQy5GYSkgjSKkBAxYlr6
# Nectb36AbV9tPpe1vsLYnsKFhoSnuQ1J/6nO1elfMB0FuMifCiFMYvqQh7Doud4A
# aKJvpBmn9hONEeqnodgg9bc5W2KFPXQkQh2iNcuj1ee4XYFB57oeSf3ge9RoUy1U
# +pluLUZcZ4PpngW/iqk2g9G4z1A/cpSlZIbMCJ0JxmMbMHWakpkRwPThw+WkOinB
# hqrjZ4igxFnWYjVaU9jHkiFZmWgqRUgpR039aZ5AssmKnqWKEKFw5JCbi9G0RFD6
# Y+e/JYarYbRu2a9rgmotP8kx+kIgxh/b9/UeLyE=
# SIG # End signature block
