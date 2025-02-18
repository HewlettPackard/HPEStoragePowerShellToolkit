####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##		

Function Get-A9Users 
{
<#   
.SYNOPSIS	
	Get all or single WSAPI users information.
.DESCRIPTION
	Get all or single WSAPI users information.
.PARAMETER UserName
	Name Of The User.
.EXAMPLE
	Get-A9Users

	Cmdlet executed successfully

	username         privileges
	--------         ----------
	telemetry        {@{domain=all; role=service}}
	consoleservice.1 {@{domain=all; role=service}}
	adminsvc         {@{domain=all; role=super}}
	hpesupport       {@{domain=all; role=service}}
	3paradm          {@{domain=all; role=super}}
	aas-user1        {@{domain=all; role=edit}}
	dev-team         {@{domain=all; role=edit}}
	aaSAdmin         {@{domain=all; role=super}}
.EXAMPLE
	PS:> Get-A9Users -UserName XYZ

	Cmdlet executed successfully

	username privileges                  links
	-------- ----------                  -----
	3paradm  {@{domain=all; role=super}} {@{href=https://192.168.20.19/api/v1/users/3paradm; rel=self}}
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$UserName		
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$dataPS = $null
	if($UserName)
		{	$uri = '/users/'+$UserName	
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}	
	else
		{	$Result = Invoke-A9API -uri '/users' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	write-verbose "No Data Found."
					return
				}
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	write-error "FAILURE : While Executing Get-Users_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9Roles 
{
<#   
.SYNOPSIS	
	Get all or single WSAPI role information.
.DESCRIPTION
	Get all or single WSAPI role information.
.PARAMETER RoleName 
	Name of the Role.
.EXAMPLE
	PS:> Get-A9Roles

	Cmdlet executed successfully

	role           comments                                                                                                                               rightsInfo
	----           --------                                                                                                                               ----------
	create         Rights are limited to creation of objects such as volumes, CPGs, hosts, remote copy groups, remote copy targets and schedules.         {@{right=vvset_annotate; rightDescription=An…
	basic_edit     Rights are similar to Edit role, but more restricted, specifically in the ability to remove objects such as volumes, VLUNs, and hosts. {@{right=cpg_compact; rightDescription=Conso…
	3PAR_RM        Used internally by HPE for operations required by Recovery Manager.                                                                    {@{right=groupsv_create; rightDescription=Cr…
	audit          For security scanners to perform a scan of the OS file system. An audit user has no access to the CLI.                                 {@{right=audit_chroot; rightDescription=Secu…
	co             Rights to approve the Compliance WORM changes.                                                                                         {@{right=password_checkown; rightDescription…
	security_admin Rights are granted to create and remove users except super users.                                                                      {@{right=password_checkown; rightDescription…
	super          Rights are granted to all operations.                                                                                                  {@{right=pd_admit; rightDescription=Admit a …
	edit           Rights are granted to most operations, such as for creating, editing, and removing virtual volumes.                                    {@{right=vv_admit; rightDescription=Admit re…
	browse         Rights are limited to read-only access.                                                                                                {@{right=vv_update; rightDescription=Remove …
	service        Rights are limited to operations required to service the storage server.                                                               {@{right=pd_admit; rightDescription=Admit a …
.EXAMPLE
	PS:> Get-A9Roles -RoleName audit

	Cmdlet executed successfully

	role  comments                                                                                               rightsInfo
	----  --------                                                                                               ----------
	audit For security scanners to perform a scan of the OS file system. An audit user has no access to the CLI. {@{right=audit_chroot; rightDescription=Secure access to a read only chroot of the OS…
	#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$RoleName
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$dataPS = $null
	if($RoleName)
		{	$uri = '/roles/'+$RoleName
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}	
	else
		{	$Result = Invoke-A9API -uri '/roles' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	write-host "No data Found."
					return 
				}
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	write-error "FAILURE : While Executing Get-Roles_WSAPI."
			return $Result.StatusDescription
		}
}	
}
