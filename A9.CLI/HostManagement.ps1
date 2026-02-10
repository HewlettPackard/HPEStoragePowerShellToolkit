####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##


Function New-A9HostSet_CLI
{
<#
.SYNOPSIS
    Creates a new host set.
.DESCRIPTION
	Creates a new host set.
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$HostSetName,
		[Parameter()]			[String]	$hostName,
		[Parameter()]			[switch]	$Add,
		[Parameter()]			[String]	$Comment,
		[Parameter()]			[String]	$Domain
)		
Begin	
{	Test-A9Connection -ClientType 'SshClient' 	
}
Process
{	$cmdCrtHostSet =" createhostset "	
	if($Add)			{	$cmdCrtHostSet +="-add "				}
	if($Comment)		{	$cmdCrtHostSet +="-comment $Comment "	}
	if($Domain)			{	$cmdCrtHostSet +="-domain $Domain "		}	
	$cmdCrtHostSet +=" $HostSetName "
	if($hostName)		{	$cmdCrtHostSet +=" $hostName "			}	
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $cmdCrtHostSet
	if($Add)
		{	if([string]::IsNullOrEmpty($Result))
				{	write-host "Success : New-HostSet command executed Host Name : $hostName is added to Host Set : $HostSetName" -ForegroundColor green
				}			
		}	
	else
		{	if([string]::IsNullOrEmpty($Result))
				{	Write-host "Success : New-HostSet command executed Host Set : $HostSetName is created with Host : $hostName" -ForegroundColor green
				}			
		}	
	return $Result
}
}

Function Set-A9Host_CLI
{
<#
.SYNOPSIS
    Add WWN or iSCSI name to an existing host.
.DESCRIPTION
	Add WWN or iSCSI name to an existing host.
.PARAMETER hostName
    Name of an existing host
.PARAMETER Address
    Specify the list of WWNs for the new host
.PARAMETER iSCSI
    If present, the address provided is an iSCSI address instead of WWN
.PARAMETER Add
	Add the specified WWN(s) or iscsi_name(s) to an existing host (at least one WWN or iscsi_name must be specified).  Do not specify host persona.
.PARAMETER Domain <domain | domain_set>
	Create the host in the specified domain or domain set.
.PARAMETER Loc <location>
	Specifies the host's location.
.PARAMETER  IP <IP address>
	Specifies the host's IP address.
.PARAMETER  OS <OS>
	Specifies the operating system running on the host.
.PARAMETER Model <model>
	Specifies the host's model.
.PARAMETER  Contact <contact>
	Specifies the host's owner and contact information.
.PARAMETER  Comment <comment>
	Specifies any additional information for the host.
.PARAMETER  Persona <hostpersonaval>
	Sets the host persona that specifies the personality for all ports which are part of the host set.  
.EXAMPLE
    PS:> Set-A9Host_CLI -hostName HV01A -Address  10000000C97B142E, 10000000C97B142F
	Adds WWN 10000000C97B142E, 0000000C97B142F to host HV01A
.EXAMPLE	
	PS:> Set-A9Host_CLI -hostName HV01B  -iSCSI:$true -Address  iqn.1991-06.com.microsoft:dt-391-xp.hq.3par.com
	Adds iSCSI  iqn.1991-06.com.microsoft:dt-391-xp.hq.3par.com to host HV01B
.EXAMPLE
    PS:> Set-A9Host_CLI -hostName HV01A  -Domain D_Aslam
.EXAMPLE
    PS:> Set-A9Host_CLI -hostName HV01A  -Add
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]		[String]	$hostName,		
		[Parameter()][String[]]	$Address,
		[Parameter()][Switch]    $iSCSI=$false,
		[Parameter()][Switch]    $Add,
		[Parameter()][String[]]  $Domain,
		[Parameter()][String[]]	$Loc,
		[Parameter()][String[]]	$IP,
		[Parameter()][String[]]	$OS,
		[Parameter()][String[]]	$Model,
		[Parameter()][String[]]	$Contact,
		[Parameter()][String[]]	$Comment,
		[Parameter()][String[]]	$Persona		
)		
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
process
{	$SetHostCmd = "createhost -f "			 
	if ($iSCSI)			{ 	$SetHostCmd +=" -iscsi "	}
	if($Add)			{	$SetHostCmd +=" -add "		}
	if($Domain)			{	$SetHostCmd +=" -domain $Domain"}
	if($Loc)			{	$SetHostCmd +=" -loc $Loc"	}
	if($Persona)		{	$SetHostCmd +=" -persona $Persona"	}
	if($IP)				{	$SetHostCmd +=" -ip $IP"}
	if($OS)				{	$SetHostCmd +=" -os $OS"	}
	if($Model)			{	$SetHostCmd +=" -model $Model"	}
	if($Contact)		{	$SetHostCmd +=" -contact $Contact"	}
	if($Comment)		{	$SetHostCmd +=" -comment $Comment"	}	
	$Addr = [string]$Address
	$SetHostCmd +=" $hostName $Addr"
	$Result1 = Invoke-A9CLICommand -cmds  $SetHostCmd
	write-verbose " Setting  Host with the command --> $SetHostCmd" 
	if([string]::IsNullOrEmpty($Result1))
		{	return "Success : Set host $hostName with Optn_Iscsi $Optn_Iscsi $Addr "
		}
	else
		{	return $Result1
		}			
} 
}

