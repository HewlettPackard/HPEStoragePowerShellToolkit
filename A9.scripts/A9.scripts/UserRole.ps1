## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9User
{
<#   
.SYNOPSIS	
	Get all or single WSAPI users information.
.DESCRIPTION
	Get all or single WSAPI users information.
.PARAMETER UserName
	Name Of The User.
.EXAMPLE
	PS:> Get-A9User

	Cmdlet executed successfully.

	username         ($_.privileges).domain ($_.privileges).role
	--------         ---------------------- --------------------
	adminsvc         all                    super
	hpesupport       all                    service
	telemetry        all                    service
	BlockCreate      all                    create
	BlockEdit        all                    edit
.EXAMPLE
	PS:> Get-A9Users -UserName adminsvc

	Cmdlet executed successfully.

	username         ($_.privileges).domain ($_.privileges).role
	--------         ---------------------- --------------------
	adminsvc         all                    super
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$UserName		
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$uri = '/users'	
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if ( $Result.StatusCode -ne 200 )
		{	write-error "FAILURE : While Executing Get-A9Users." 
			return $Result.StatusDescription
		}
	$dataPS = ( $Result.content | ConvertFrom-Json )
	if ( $dataPS.members ) 	{	$DataPS = $DataPS.members	} 
	if ( $dataPS.Count -eq 0 )
		{	write-warning "Cmdlet executed successfully however No Data was returned."
			return
		}
	$NewObj = @(    foreach( $Item in $DataPS )	
						{   $NewItem=@{PSTypeName = "HPE.A9Storage.User"}
							$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
							$DataSetType = "HPE.A9Storage.User"
							$NewItem.PSTypeNames.Insert(0,$DataSetType)
							$DataSetType = $DataSetType + ".TypeName"
							$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
							[PSCustomObject]$NewItem
						}
				)
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	return $NewObj				
}	
}

Function Get-A9Role
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
	PS:> Get-A9Role -RoleName audit

	Cmdlet executed successfully

	role           comments                                                                                                                               rightsInfo
	----           --------                                                                                                                               ----------
	audit          For security scanners to perform a scan of the OS file system. An audit user has no access to the CLI.                                 {@{right=audit_chroot; rightDescription=Secu…
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$RoleName
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$uri = '/roles'
	if($RoleName)	{	$uri = '/roles/'+$RoleName	}	
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -ne 200)
		{	write-error "FAILURE : While Executing Get-A9Roles."
			return $Result.StatusDescription
		}
	$dataPS = ( $Result.content | ConvertFrom-Json )
	if ( $dataPS.members )	{ $DataPS = $DataPS.members }
	if ( $dataPS.Count -eq 0 )
		{	write-warning "Cmdlet executed successfully however No data was returned."
			return 
		}
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	$NewObj = @(    foreach( $Item in $DataPS )	
						{   $NewItem=@{ PSTypeName = "HPE.A9Storage.Role" }
							$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
							$DataSetType = "HPE.A9Storage.Role"
							$NewItem.PSTypeNames.Insert(0,$DataSetType)
							$DataSetType = $DataSetType + ".TypeName"
							$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
							[PSCustomObject]$NewItem
						}
				)
	return $NewObj			
}	
}

