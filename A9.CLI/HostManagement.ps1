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
# SIG # Begin signature block
# MIIt2QYJKoZIhvcNAQcCoIItyjCCLcYCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBpSXzSnRjX
# a9SKV0GuFfezQp0k2KJheoeS87/CjpGulYhDeS++bh0dtUWF95S3gTIFk/RL6SPK
# kkeOUO/Ulo1PoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQJ7a9PqgvOLxcd1lI3TKUCjMGcYGOuEPDangSfOZFYyARAfA8xB9Vw2O
# Um4ga71JvjTBW2C6WgiYkcvIYG+8LU0wDQYJKoZIhvcNAQEBBQAEggGAcq8cURCG
# 3Pz4vOh/CbVWmeTjHiBzWmBYXcxpTr+VcEhZRkwNwQi6iMHva0WqBwYccaAv61zW
# 286Jze4a268fFu+QsCGS289vWRgY/fOWDc/eHeS8q7mQBvH87p0/ZAJmm1K5mGIS
# P7okq0m4jbNa/Q+2SlgsH3msQEl2QTrZ/5LWHnSDGqSJ2MqXwf6YHPvxPqiiFWi2
# +O+Aa/pZIMuQqEg7hlesDibMUYW2C2IfMleQoZr31B3i0IQjPGMDptdkTlNSHGy8
# K+jMYzs3oo1hdUFkTT2W7RmxOlBdhb01q0PXeODiIUkuNmUgcSjVU3l1RZd/DquH
# Pk3Ywb7EF1Ckm6V8ejUtF8CBvDvKc4851viVj5n/8zEs595KyAzruD7W54iPuZri
# OsiV2ofPsK/uIGO7WDXfz8WAUVVj6dDxyV64Nv1m5ZoT/8k+0T84oF1gfqpDIjol
# zYltahbH6yJ2mgiFuYeRi85Y0xP/U3cbW/r3eWQGJhCP2JFjHQ1bfWdSoYIY3zCC
# GNsGCisGAQQBgjcDAwExghjLMIIYxwYJKoZIhvcNAQcCoIIYuDCCGLQCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQQGCyqGSIb3DQEJEAEEoIH0BIHxMIHuAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMBBkr1uxkgudDXjzmh6xs1PoBlsQNmDE
# LQXGTt50hNzudY3rPvTh+9PKKQYCijlNNgIVAL7f/8gAbm26TLDiZLc2XHMOJzAI
# GA8yMDI0MDczMTE5MjIxN1qgcqRwMG4xCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpN
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
# MDczMTE5MjIxN1owPwYJKoZIhvcNAQkEMTIEMLRdAwE7OrzSNfzVFVtu/a03MYbH
# iJ/03SEgqZl6iz7ubSliKhrklbTH+S700F4RijCCAXoGCyqGSIb3DQEJEAIMMYIB
# aTCCAWUwggFhMBYEFPhgmBmm+4gs9+hSl/KhGVIaFndfMIGHBBTGrlTkeIbxfD1V
# EkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KCYXzQkDXEkd6S
# wULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJz
# ZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNU
# IE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEBBQAEggIAZrF4
# AhKX7bjA6LjgccbQ6CA9GrBdyDqpGPt1hYct5YSEnNcPLqWtUvT0uTQZOjGMXVEX
# xDcF7fXbfOl5efZommXxJIj88eS8IV/h+DqcZtV5hPE9EvPr0SEKJkiLYmk//0y6
# SWv1FUY2gAVe5KDS5VkKFH6ZzTttP2gJFrj+bNrszsHbbmfL3WgZVrs6yEOVyIDQ
# tU0YajsLqYIOBdi4dPPalto5kDe9uDullGAImQmKOCsyLVjoqI8klHHmbW5qbM4F
# PuL0LZw3Vrx62pwGyxyKP6cv8OKAO31v/bbPhHpqTm0R5P4JgYJaFU+Qs7G0JSHp
# RkGm0tmbX8/sE2YGgqScghGpkablQNlQoY/tRu/EF4q0jswBabpD9aoGiI7m5nwl
# +sM7sXyVdsNdHv58G8YUFDNSgYydH1MNpP5Lt7kCu9wLtrCAku8rIQ/27iqZDAHO
# /dMMV/9G2EX/i02sm+QbtBpks8pTOMi5JdzQALxi+dFPF9I9P6WFBAp1Rc8sjnKG
# +e4x+I3t/LjSrVSQlS6qYobm9G58X5gZSA7pbMH5qPW9pwX0LW0ZTF7oiSLCb8Qg
# qxalElffkDcSIX2+vU7OzWoQnj6lu71TC0F3Lb2G+MW0I3qRNjesHEmZMQ9xEPVv
# TkQ4lqX4dCdm5MMiyvpzSlpEcjBXA6mkb3qnpC0=
# SIG # End signature block
