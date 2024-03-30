####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##




Function New-A9Host_CLI
{
<#
.SYNOPSIS
    Creates a new host.
.DESCRIPTION
	Creates a new host.
.EXAMPLE
    PS:> New-A9Host_CLI -HostName HV01A -Persona 2 -WWN 10000000C97B142E

	Creates a host entry named HV01A with WWN equals to 10000000C97B142E
.EXAMPLE	
	PS:> New-A9Host_CLI -HostName HV01B -Persona 2 -iSCSI

	Creates a host entry named HV01B with iSCSI equals to iqn.1991-06.com.microsoft:dt-391-xp.hq.3par.com
.EXAMPLE
    PS:> New-A9Host_CLI -HostName HV01A -Persona 2 

.EXAMPLE 
	PS:> New-A9Host_CLI -HostName Host3 -iSCSI
.EXAMPLE 
	PS:> New-A9Host_CLI -HostName Host4 -iSCSI -Domain ZZZ
.PARAMETER HostName
    Specify new name of the host
.PARAMETER Add
	Add the specified WWN(s) or iscsi_name(s) to an existing host (at least one WWN or iscsi_name must be specified).  Do not specify host persona.
.PARAMETER Domain
	Create the host in the specified domain or domain set. The default is to create it in the current domain, or no domain if the current domain is
	not set. The domain set name must start with "set:".
.PARAMETER Forces
	Forces the tear down of lower priority VLUN exports if necessary.
.PARAMETER Persona
	Sets the host persona that specifies the personality for all ports which are part of the host set.  This selects certain variations in
	scsi command behavior which certain operating systems expect. <hostpersonaval> is the host persona id number with the desired
	capabilities.  These can be seen with showhost -listpersona.
.PARAMETER Location
	Specifies the host's location.
.PARAMETER IPAddress
	Specifies the host's IP address.
.PARAMETER OS
	Specifies the operating system running on the host.
.PARAMETER Model
	Specifies the host's model.
.PARAMETER Contact
	Specifies the host's owner and contact information.
.PARAMETER Comment
	Specifies any additional information for the host.
.PARAMETER NSP
	Specifies the desired relationship between the array port(s) and host for target-driven zoning. Multiple array ports can be specified by
	either using a pattern or a comma-separated list.  This option is used only when the Smart SAN license is installed.  At least one WWN needs
	to be specified with this option.
.PARAMETER WWN
	Specifies the World Wide Name(WWN) to be assigned or added to an existing host. This specifier can be repeated to specify multiple WWNs. This specifier is optional.
.PARAMETER IscsiName
	Host iSCSI name to be assigned or added to a host. This specifier is optional.
.PARAMETER iSCSI
    when specified, it means that the address is an iSCSI address
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$HostName,	
		[Parameter()]	[switch]	$Iscsi,
		[Parameter()]	[switch]	$Add,	
		[Parameter()]	[String]	$Domain,
		[Parameter()]	[switch]	$Forces, 
		[Parameter()]	[String]	$Persona = 2,
		[Parameter()]	[String]	$Location,
		[Parameter()]	[String]	$IPAddress,
		[Parameter()]	[String]	$OS,
		[Parameter()]	[String]	$Model,
		[Parameter()]	[String]	$Contact,
		[Parameter()]	[String]	$Comment,
		[Parameter()]	[String]	$NSP,
		[Parameter()]	[String]	$WWN,
		[Parameter()]	[String]	$IscsiName
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd ="createhost "
	if($Iscsi)		{	$cmd +="-iscsi "			}
	if($Add)		{	$cmd +="-add "				}
	if($Domain)		{	$cmd +="-domain $Domain "	}
	if($Forces)		{	$cmd +="-f "				}
	if($Persona)	{	$cmd +="-persona $Persona "	}
	if($Location)	{	$cmd +="-loc $Location "	}
	if($IPAddress)	{	$cmd +="-ip $IPAddress "	}
	if($OS)			{	$cmd +="-os $OS "			}
	if($Model)		{	$cmd +="-model $Model "		}
	if($Contact)	{	$cmd +="-contact $Contact "	}
	if($Comment)	{	$cmd +="-comment $Comment "	}
	if($NSP)		{	$cmd +="-port $NSP "		}
	if ($HostName)	{	$cmd +="$HostName "			}
	if ($WWN)		{	$cmd +="$WWN "				}
	if ($IscsiName)	{	$cmd +="$IscsiName "		}
	$Result = Invoke-A9CLICommand -cmds $cmd	
	if([string]::IsNullOrEmpty($Result))
		{	return "Success : New-Host command executed Host Name : $HostName is created."
		}
	else{	return $Result
		}	   
}
}

Function New-A9HostSet_CLI
{
<#
.SYNOPSIS
    Creates a new host set.
.DESCRIPTION
	Creates a new host set.
.EXAMPLE
    PS:> New-A9HostSet_CLI -HostSetName xyz
	
	Creates an empty host set named "xyz"
.EXAMPLE
	To create an empty hostset:

	PS:> New-A9HostSet_CLI hostset
.EXAMPLE
    To add a host to the set:

	PS:> New-A9HostSet_CLI -Add -HostSetName hostset -HostName hosta
.EXAMPLE
    To create a host set with hosts in it:

	PS:> New-A9HostSet_CLI -HostSetName hostset -HostName "host1 host2"
    or
    PS:> New-A9HostSet_CLI -HostSetName set:hostset -HostName "host1 host2" 
.EXAMPLE
    To create a host set with a comment and a host in it:

	PS:> New-A9HostSet_CLI -Comment "A host set" -HostSetName hostset -HostName hosta
.EXAMPLE
	PS:> New-A9HostSet_CLI -HostSetName xyz -Domain xyz

	Create the host set in the specified domain
.EXAMPLE
    PS:> New-A9HostSet_CLI -hostSetName HV01C-HostSet -hostName "MyHost" 
	
	Creates an empty host set and  named "HV01C-HostSet" and adds host "MyHost" to hostset
			(or)
	Adds host "MyHost" to hostset "HV01C-HostSet" if hostset already exists
.PARAMETER HostSetName
    Specify new name of the host set
.PARAMETER hostName
    Specify new name of the host
.PARAMETER Add
	Specifies that the hosts listed should be added to an existing set. At least one host must be specified.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
.PARAMETER Domain
	Create the host set in the specified domain. For an empty set the default is to create it in the current domain, or no domain if the
	current domain is not set. A host set must be in the same domain as its members; if hosts are specified as part of the creation then
	the set will be created in their domain. The -domain option should still be used to specify which domain to use for the set when the
	hosts are members of domain sets. A domain cannot be specified when adding a host to an existing set with the -add option.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$HostSetName,
		[Parameter()]	[String]	$hostName,
		[Parameter()]	[switch]	$Add,
		[Parameter()]	[String]	$Comment,
		[Parameter()]	[String]	$Domain
)		
Begin	
{	Test-A9Connection -ClientType 'SshClient' 	
}
Process
{	$cmdCrtHostSet =" createhostset "	
	if($Add)			{	$cmdCrtHostSet +="-add "	}
	if($Comment)		{	$cmdCrtHostSet +="-comment $Comment "	}
	if($Domain)			{	$cmdCrtHostSet +="-domain $Domain "	}	
	if ($HostSetName)	{	$cmdCrtHostSet +=" $HostSetName "	}
	else	{	write-verbose "No name specified for new host set. Skip creating host set"
				Get-help New-HostSet
				return	
			}
	if($hostName)	{	$cmdCrtHostSet +=" $hostName "	}	
	$Result = Invoke-A9CLICommand -cmds  $cmdCrtHostSet
	if($Add)
		{	if([string]::IsNullOrEmpty($Result))
				{	return "Success : New-HostSet command executed Host Name : $hostName is added to Host Set : $HostSetName"
				}
			else{	return $Result
				}
		}	
	else
		{	if([string]::IsNullOrEmpty($Result))
				{	return "Success : New-HostSet command executed Host Set : $HostSetName is created with Host : $hostName"
				}
			else{	return $Result
				}			
		}	
}
}

Function Remove-A9Host_CLI
{
<#
.SYNOPSIS
    Removes a host.
.DESCRIPTION
	Removes a host.
.EXAMPLE
    PS:> Remove-A9Host_CLI -hostName HV01A 

	Remove the host named HV01A
.EXAMPLE
    PS:> Remove-A9Host_CLI -hostName HV01A -address 10000000C97B142E

	Remove the WWN address of the host named HV01A
.EXAMPLE	
	PS:> Remove-A9Host_CLI -hostName HV01B -iSCSI -Address  iqn.1991-06.com.microsoft:dt-391-xp.hq.3par.com

	Remove the iSCSI address of the host named HV01B
.PARAMETER hostName
    Specify name of the host.
.PARAMETER Address
    Specify the list of addresses to be removed.
.PARAMETER Rvl
    Remove WWN(s) or iSCSI name(s) even if there are VLUNs exported to the host.
.PARAMETER iSCSI
    Specify twhether the address is WWN or iSCSI
.PARAMETER Pat
	Specifies that host name will be treated as a glob-style pattern and that all hosts matching the specified pattern are removed. T
.PARAMETER  Port 
	Specifies the NSP(s) for the zones, from which the specified WWN will be removed in the target driven zoning. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]			[String]	$hostName,
		[Parameter(ValueFromPipeline=$true)]	[switch] 	$Rvl,
		[Parameter(ValueFromPipeline=$true)]	[switch] 	$ISCSI = $false,
		[Parameter(ValueFromPipeline=$true)]	[switch] 	$Pat = $false,
		[Parameter()]	[String]	$Port,		
		[Parameter(ValueFromPipeline=$true)]	[System.String[]]	$Address
	)		
Begin	
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$objType = "host"
	$objMsg  = "hosts"
	$RemoveCmd = "removehost "			
	if ($address)
		{	if($Rvl)	{	$RemoveCmd += " -rvl "	}	
			if($ISCSI)	{	$RemoveCmd += " -iscsi "	}
			if($Pat)	{	$RemoveCmd += " -pat "	}
			if($Port)	{	$RemoveCmd += " -port $Port "	}
		}			
	if ( -not ( Test-A9CLIObject -objectType $objType -objectName $hostName -objectMsg $objMsg )) 
		{	write-verbose " Host $hostName does not exist. Nothing to remove"   
			return "FAILURE : No host $hostName found"
		}
	else
		{	$Addr = [string]$address 
			$RemoveCmd += " $hostName $Addr"
			$Result1 = Get-HostSet -hostName $hostName 			
			if(($Result1 -match "No host set listed"))
				{	$Result2 = Invoke-A9CLICommand -cmds  $RemoveCmd
					write-verbose "Removing host  with the command --> $RemoveCmd" 
					if([string]::IsNullOrEmpty($Result2))
						{	return "Success : Removed host $hostName"
						}
					else
						{	return "FAILURE : While removing host $hostName"
						}				
				}
			else
				{	$Result3 = Invoke-A9CLICommand -cmds $RemoveCmd
					return "FAILURE : Host $hostName is still a member of set $Result3"
				}			
		}				
		
}
}

Function Remove-A9HostSet_CLI
{
<#
.SYNOPSIS
    Remove a host set or remove hosts from an existing set
.DESCRIPTION
	Remove a host set or remove hosts from an existing set
.EXAMPLE
    PS:> Remove-A9HostSet_CLI -hostsetName "MyHostSet"  -force 

	Remove a hostset  "MyHostSet"
.EXAMPLE
	PS:> Remove-A9HostSet_CLI -hostsetName "MyHostSet" -hostName "MyHost" -force

	Remove a single host "MyHost" from a hostset "MyHostSet"
.PARAMETER hostsetName 
    Specify name of the hostsetName
.PARAMETER hostName 
    Specify name of  a host to remove from hostset
.PARAMETER force
	If present, perform forcible delete operation
.PARAMETER Pat
	Specifies that both the set name and hosts will be treated as glob-style patterns.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$hostsetName,
		[Parameter()]					[String]	$hostName,
		[Parameter()]					[switch]	$force,
		[Parameter()]					[switch]	$Pat
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$RemovehostsetCmd = "removehostset "
	if ($hostsetName)
		{	if (!($force))
				{	write-verbose "no force option selected to remove hostset, Exiting...."
					return "FAILURE : no -force option selected to remove hostset"
				}
			$objType = "hostset"
			$objMsg  = "host set"
			if ( -not ( Test-A9CLIObject -objectType $objType -objectName $hostsetName -objectMsg $objMsg )) 
				{	write-verbose " hostset $hostsetName does not exist. Nothing to remove"   
					return "FAILURE : No hostset $hostsetName found"
				}
			else
				{	if($force)		{	$RemovehostsetCmd += " -f "	}
					if($Pat)		{	$RemovehostsetCmd += " -pat "	}
					$RemovehostsetCmd += " $hostsetName "
					if($hostName)	{	$RemovehostsetCmd +=" $hostName"	}
					$Result2 = Invoke-A9CLICommand -cmds  $RemovehostsetCmd
					if([string]::IsNullOrEmpty($Result2))
						{	if($hostName)
								{	return "Success : Removed host $hostName from hostset $hostsetName "
								}
							else{	return "Success : Removed hostset $hostsetName "
								}
						}
					else{	return "FAILURE : While removing hostset $hostsetName"
						}			
				}
		}
	else
		{	write-verbose  "No hostset name mentioned to remove"
			Get-help Remove-HostSet
		}
}
} 

Function Update-A9HostSet_CLI
{
<#
.SYNOPSIS
	Update-HostSet - set parameters for a host set
.DESCRIPTION
	The Update-HostSet command sets the parameters and modifies the properties of a host set.
.PARAMETER Setname
	Specifies the name of the host set to modify.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
.PARAMETER NewName
	Specifies a new name for the host set, using up to 27 characters in length.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Comment,
		[Parameter()]	[String]	$NewName,
		[Parameter(Mandatory=$true)]	[String]    $Setname
)
Begin
{	Test-A9Connection -ClientType 'SshClient'  
}
Process
{	$Cmd = " sethostset "
	if($Comment)	{	$Cmd += " -comment $Comment " }
	if($NewName)	{	$Cmd += " -name $NewName " 	} 
	if($Setname)	{	$Cmd += " $Setname " } 
	else			{	return "Setname is mandatory Please enter..."	} 
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if ([string]::IsNullOrEmpty($Result))	{    Get-HostSet -hostSetName $NewName }
	else	{ 	Return $Result }
}
}