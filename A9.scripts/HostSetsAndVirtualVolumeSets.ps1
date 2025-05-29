####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function New-A9HostSet 
{
<#
.SYNOPSIS
	Creates a new host Set.
.DESCRIPTION
	Creates a new host Set.
    Any user with the Super or Edit role can create a host set. Any role granted hostset_set permission can add hosts to a host set.
	You can add hosts to a host set using a glob-style pattern. A glob-style pattern is not supported when removing hosts from sets.
	For additional information about glob-style patterns, see “Glob-Style Patterns” in the HPE 3PAR Command Line Interface Reference.
.PARAMETER HostSetName
	Name of the host set to be created.
.PARAMETER Comment
	Comment for the host set.
.PARAMETER Domain
	The domain in which the host set will be created.
.PARAMETER SetMembers
	The host to be added to the set. The existence of the hist will not be checked.
.EXAMPLE
	PS:> New-A9HostSet -HostSetName MyHostSet

	Creates a new host Set with name MyHostSet.
.EXAMPLE
	PS:> New-A9HostSet -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain

	Creates a new host Set with name MyHostSet.
.EXAMPLE
	PS:> New-A9HostSet -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers MyHost

	Creates a new host Set with name MyHostSet with Set Members MyHost.	
.EXAMPLE	
	PS:> New-A9HostSet -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers "MyHost,MyHost1,MyHost2"

	Creates a new host Set with name MyHostSet with Set Members MyHost.	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$HostSetName,	  
		[Parameter()]					[String]	$Comment,	
		[Parameter()]					[String]	$Domain, 
		[Parameter()]					[String[]]	$SetMembers
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["name"] = "$($HostSetName)"
	If ($Comment) 	{	$body["comment"] = "$($Comment)"}  
	If ($Domain) 	{	$body["domain"] = "$($Domain)"    }	
	If ($SetMembers){	$body["setmembers"] = $SetMembers    }
    $Result = $null
    $Result = Invoke-A9API -uri '/hostsets' -type 'POST' -body $body
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "Cmdlet executed successfully" -foreground green
		return Get-A9HostSet -HostSetName $HostSetName
	}
	else
	{	Write-Error "Failure:  While creating Host Set:$HostSetName " 
		return $Result.StatusDescription
	}	
}
}

Function Update-A9HostSet 
{
<#
.SYNOPSIS
	Update an existing Host Set.
.DESCRIPTION
	Update an existing Host Set.
    Any user with the Super or Edit role can modify a host set. Any role granted hostset_set permission can add a host to the host set or remove a host from the host set.   
.EXAMPLE    
	PS:> Update-A9HostSet -HostSetName xxx -RemoveMember -Members as-Host4
.EXAMPLE
	PS:> Update-A9HostSet -HostSetName xxx -AddMember -Members as-Host4
.EXAMPLE	
	PS:> Update-A9HostSet -HostSetName xxx -ResyncPhysicalCopy
.EXAMPLE	
	PS:> Update-A9HostSet -HostSetName xxx -StopPhysicalCopy 
.EXAMPLE
	PS:> Update-A9HostSet -HostSetName xxx -PromoteVirtualCopy
.EXAMPLE
	PS:> Update-A9HostSet -HostSetName xxx -StopPromoteVirtualCopy
.EXAMPLE
	PS:> Update-A9HostSet -HostSetName xxx -ResyncPhysicalCopy -Priority high
.PARAMETER HostSetName
	Existing Host Name
.PARAMETER AddMember
	Adds a member to the VV set.
.PARAMETER RemoveMember
	Removes a member from the VV set.
.PARAMETER ResyncPhysicalCopy
	Resynchronize the physical copy to its VV set.
.PARAMETER StopPhysicalCopy
	Stops the physical copy.
.PARAMETER PromoteVirtualCopy
	Promote virtual copies in a VV set.
.PARAMETER StopPromoteVirtualCopy
	Stops the promote virtual copy operations in a VV set.
.PARAMETER NewName
	New name of the set.
.PARAMETER Comment
	New comment for the VV set or host set.
	To remove the comment, use “”.
.PARAMETER Members
	The volume or host to be added to or removed from the set.
.PARAMETER Priority
	1: high
	2: medium
	3: low
#>
[CmdletBinding(DefaultParameterSetName="default")]
Param(	[Parameter(Mandatory)]					[String]	$HostSetName,
		[Parameter(ParameterSetName='AddMember', ValueFromPipeline=$true)]		[switch]	$AddMember,	
		[Parameter(ParameterSetName='RemoveMember', ValueFromPipeline=$true)]	[switch]	$RemoveMember,
		[Parameter(ParameterSetName='Resync', ValueFromPipeline=$true)]			[switch]	$ResyncPhysicalCopy,
		[Parameter(ParameterSetName='Stop', ValueFromPipeline=$true)]			[switch]	$StopPhysicalCopy,
		[Parameter(ParameterSetName='Promote', ValueFromPipeline=$true)]		[switch]	$PromoteVirtualCopy,
		[Parameter(ParameterSetName='StopPromote', ValueFromPipeline=$true)]	[switch]	$StopPromoteVirtualCopy,
		[Parameter()]									[String]	$NewName,
		[Parameter()]									[String]	$Comment,
		[Parameter()]									[String[]]	$Members,
		[Parameter()]	
		[ValidateSet('high','medium','low')]									[String]	$Priority
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$counter
	If ($AddMember)			{	 $body["action"] = 1
								$counter = $counter + 1
							}
	If ($RemoveMember) 		{	 $body["action"] = 2
								$counter = $counter + 1
							}
	If ($ResyncPhysicalCopy){	$body["action"] = 3
								$counter = $counter + 1
							}
	If ($StopPhysicalCopy) 	{	$body["action"] = 4
								$counter = $counter + 1
							}
	If ($PromoteVirtualCopy){	$body["action"] = 5
								$counter = $counter + 1
							}
	If ($StopPromoteVirtualCopy){	$body["action"] = 6
									$counter = $counter + 1
								}
	if($counter -gt 1)
		{	return "Please Select Only One from [ AddMember | RemoveMember | ResyncPhysicalCopy | StopPhysicalCopy | PromoteVirtualCopy | StopPromoteVirtualCopy]. "
		}
	If ($NewName) 	{	$body["newName"] = "$($NewName)"	}
	If ($Comment) 	{	$body["comment"] = "$($Comment)"    }	
	If ($Members) 	{	$body["setmembers"] = $Members    }
	If ($Priority) 
		{	if($Priority -eq "high")	{	$body["priority"] = 1	}	
			if($Priority -eq "medium")	{	$body["priority"] = 2	}
			if($Priority -eq "low")		{	$body["priority"] = 3	}
		}
	
    $Result = $null	
	$uri = '/hostsets/'+$HostSetName 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)	{	Get-HostSet_WSAPI -HostSetName $NewName	}	
			else			{	Get-HostSet_WSAPI -HostSetName $HostSetName	}
		}
	else
		{	Write-Error "Failure:  While Updating Host Set: $HostSetName " 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9HostSet
{
<#
.SYNOPSIS
	Remove a Host Set.
.DESCRIPTION
	Remove a Host Set.
	Any user with Super or Edit role, or any role granted host_remove permission, can perform this operation. Requires access to all domains.
.EXAMPLE    
	PS:> Remove-A9HostSet -HostSetName MyHostSet
.PARAMETER HostSetName 
	Specify the name of Host Set to be removed.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specifies the name of Host Set.')]
		[String]$HostSetName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$uri = '/hostsets/'+$HostSetName
	$Result = $null
	$Result = Invoke-A9API -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return
	}
	else
	{	Write-Error "Failure:  While Removing Host Set:$HostSetName " 
		return $Result.StatusDescription
	}    
}
}

Function New-A9VvSet
{
<#
.SYNOPSIS
	Creates a new virtual volume Set.
.DESCRIPTION
	Creates a new virtual volume Set.
    Any user with the Super or Edit role can create a host set. Any role granted hostset_set permission can add hosts to a host set.
	You can add hosts to a host set using a glob-style pattern. A glob-style pattern is not supported when removing hosts from sets.
	For additional information about glob-style patterns, see “Glob-Style Patterns” in the HPE 3PAR Command Line Interface Reference.
.EXAMPLE
	PS:> New-A9VvSet -VVSetName MyVVSet

	Creates a new virtual volume Set with name MyVVSet.
.EXAMPLE
	PS:> New-A9VvSet -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain

	Creates a new virtual volume Set with name MyVVSet.
.EXAMPLE
	PS:> New-A9VvSet -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers xxx
	
	Creates a new virtual volume Set with name MyVVSet with Set Members xxx.
.EXAMPLE	
	PS:> New-A9VvSet -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers "xxx1,xxx2,xxx3"

	Creates a new virtual volume Set with name MyVVSet with Set Members xxx.
.PARAMETER VVSetName
	Name of the virtual volume set to be created.
.PARAMETER Comment
	Comment for the virtual volume set.
.PARAMETER Domain
	The domain in which the virtual volume set will be created.
.PARAMETER SetMembers
	The virtual volume to be added to the set. The existence of the hist will not be checked.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]		[String]	$VVSetName,	  
		[Parameter()]			[String]	$Comment,	
		[Parameter()]						[String]	$Domain, 
		[Parameter()]						[String[]]	$SetMembers
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["name"] = "$($VVSetName)"
	If ($Comment) 	{	$body["comment"] = "$($Comment)"    }  
	If ($Domain)    {	$body["domain"] = "$($Domain)"	 	}
	If ($SetMembers){	$body["setmembers"] = $SetMembers   }
    $Result = $null
    $Result = Invoke-A9API -uri '/volumesets' -type 'POST' -body $body 
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "Cmdlet executed successfully" -foreground green
		return Get-VvSet_WSAPI -VVSetName $VVSetName
	}
	else
	{	Write-Error "Failure:  While creating virtual volume Set:$VVSetName " 
		return $Result.StatusDescription
	}	
}
}

Function Update-A9VvSet 
{
<#
.SYNOPSIS
	Update an existing virtual volume Set.
.DESCRIPTION
	Update an existing virtual volume Set.
    Any user with the Super or Edit role can modify a host set. Any role granted hostset_set permission can add a host to the host set or remove a host from the host set.   
.EXAMPLE
	PS:> Update-A9VvSet -VVSetName xxx -RemoveMember -Members testvv3.0
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -AddMember -Members testvv3.0
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -ResyncPhysicalCopy 
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -StopPhysicalCopy 
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -PromoteVirtualCopy
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -StopPromoteVirtualCopy
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -Priority xyz
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -ResyncPhysicalCopy -Priority high
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -ResyncPhysicalCopy -Priority medium
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -ResyncPhysicalCopy -Priority low
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -NewName as-vvSet1 -Comment "Updateing new name"
.PARAMETER VVSetName
	Existing virtual volume Name
.PARAMETER AddMember
	Adds a member to the virtual volume set.
.PARAMETER RemoveMember
	Removes a member from the virtual volume set.
.PARAMETER ResyncPhysicalCopy
	Resynchronize the physical copy to its virtual volume set.
.PARAMETER StopPhysicalCopy
	Stops the physical copy.
.PARAMETER PromoteVirtualCopy
	Promote virtual copies in a virtual volume set.
.PARAMETER StopPromoteVirtualCopy
	Stops the promote virtual copy operations in a virtual volume set.
.PARAMETER NewName
	New name of the virtual volume set.
.PARAMETER Comment
	New comment for the virtual volume set or host set.
	To remove the comment, use “”.
.PARAMETER Members
	The volume to be added to or removed from the virtual volume set.
.PARAMETER Priority
	1: high
	2: medium
	3: low
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory)]	[String]	$VVSetName,
	[Parameter()]	[switch]	$AddMember,	
	[Parameter()]	[switch]	$RemoveMember,	
	[Parameter()]	[switch]	$ResyncPhysicalCopy,	
	[Parameter()]	[switch]	$StopPhysicalCopy,	
	[Parameter()]	[switch]	$PromoteVirtualCopy,
	[Parameter()]	[switch]	$StopPromoteVirtualCopy,	
	[Parameter()]	[String]	$NewName,	
	[Parameter()]	[String]	$Comment,
	[Parameter()]	[String[]]	$Members,
	[Parameter()]
	[ValidateSet('high','medium','low')]	[String]	$Priority
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$counter
	If ($AddMember)			{	$body["action"] = 1
								$counter = $counter + 1
							}
	If ($RemoveMember) 		{	$body["action"] = 2
								$counter = $counter + 1
							}
	If ($ResyncPhysicalCopy){	$body["action"] = 3
								$counter = $counter + 1
							}
	If ($StopPhysicalCopy) 	{	$body["action"] = 4
								$counter = $counter + 1
							}
	If ($PromoteVirtualCopy){	$body["action"] = 5
								$counter = $counter + 1
							}
	If ($StopPromoteVirtualCopy) 
							{	$body["action"] = 6
								$counter = $counter + 1
							}
	if($counter -gt 1)		{	return "Please Select Only One from [ AddMember | RemoveMember | ResyncPhysicalCopy | StopPhysicalCopy | PromoteVirtualCopy | StopPromoteVirtualCopy]. "	}
	If ($NewName) 			{	$body["newName"] = "$($NewName)" }
	If ($Comment) 			{	$body["comment"] = "$($Comment)" }
	If ($Members) 			{	$body["setmembers"] = $Members    }
	if($Priority -eq "high"){	$body["priority"] = 1	}	
	if($Priority -eq "medium"){	$body["priority"] = 2	}
	if($Priority -eq "low")	{	$body["priority"] = 3	}
    $Result = $null	
	$uri = '/volumesets/'+$VVSetName 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)
				{	return Get-A9VvSet -VVSetName $NewName
				}
			else
				{	return Get-A9VvSet -VVSetName $VVSetName
				}
			Write-Verbose "End: Update-A9VvSet"
		}
	else
	{	Write-Error "Failure:  While Updating virtual volume Set: $VVSetName " 
		return $Result.StatusDescription
	}
}
}

Function Get-A9VvSet 
{
<#
.SYNOPSIS
	Get Single or list of virtual volume Set.
.DESCRIPTION
	Get Single or list of virtual volume Set.
.EXAMPLE
	PS:> Get-A9VvSet
	Display a list of virtual volume Set.
.EXAMPLE
	PS:> Get-A9VvSet -VVSetName MyvvSet

	Get the information of given virtual volume Set.
.EXAMPLE
	PS:> Get-A9VvSet -Members Myvv

	Get the information of virtual volume Set that contain MyHost as Member.
.EXAMPLE
	PS:> Get-A9VvSet -Members "Myvv,Myvv1,Myvv2"

	Multiple Members.
.EXAMPLE
	PS:> Get-A9VvSet -Id 10

	Filter virtual volume Set with Id
.EXAMPLE
	PS:> Get-A9VvSet -Uuid 10

	Filter virtual volume Set with uuid
.EXAMPLE
	PS:> Get-A9VvSet -Members "Myvv,Myvv1,Myvv2" -Id 10 -Uuid 10

	Multiple Filter
.PARAMETER VVSetName
	Specify name of the virtual volume Set.
.PARAMETER Members
	Specify name of the virtual volume.
.PARAMETER Id
	Specify id of the virtual volume Set.
.PARAMETER Uuid
	Specify uuid of the virtual volume Set.
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$VVSetName,
		[Parameter()]	[String]	$Members,
		[Parameter()]	[String]	$Id,
		[Parameter()]	[String]	$Uuid
)
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($VVSetName)
		{	$uri = '/volumesets/'+$VVSetName
			$Result = Invoke-A9API -uri $uri -type 'GET'		 
			If($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
					write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-VvSet_WSAPI." 
					return $Result.StatusDescription
				}
		}
	if($Members)
		{	$count = 1
			$lista = $Members.split(",")
			foreach($sub in $lista)
				{	$Query = $Query.Insert($Query.Length-3," setmembers EQ $sub")			
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$Query = $Query.Insert($Query.Length-3," OR ")
									$count = $count + 1
								}				
						}
				}		
		}
	if($Id)	{	if($Members)	{	$Query = $Query.Insert($Query.Length-3," OR id EQ $Id")	}
				else			{	$Query = $Query.Insert($Query.Length-3," id EQ $Id")	}
			}
	if($Uuid)	{	if($Members -or $Id)	{	$Query = $Query.Insert($Query.Length-3," OR uuid EQ $Uuid")}
					else					{	$Query = $Query.Insert($Query.Length-3," uuid EQ $Uuid")	}
				}
	if($Members -Or $Id -Or $Uuid)
		{	$uri = '/volumesets/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET'	
		}	
	else{	$Result = Invoke-A9API -uri '/volumesets' -type 'GET' 
		}
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-VvSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-VvSet_WSAPI." 
			return $Result.StatusDescription
		}
}
}



# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBhcezIBN//
# SRg0i77El2QkayOU+QXmsbWhzfoaM5PMFixbWFSz87EIZB+0jURQP0VG824yMBJ6
# tAovfW+HdCNLoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG58wghubAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQLiXhTaPOmGZK4oVfd9H24+GK/lkinpLPEvmeRHVWn0uhRn88IWN+DZo
# gWp7Ng7ZF9JRh9lDOKRhmlLyjsmWeCMwDQYJKoZIhvcNAQEBBQAEggGATgMpq7Tg
# 2xWlRoV7FHrvAAR7MSu1vAg0ldxIiaZQmi/+At0sLyKoLiHPh4Tw/mznvgaQo9wu
# rI7k33YMvh2SQ2VCKWFtCltgXWzFKsXnTv85zJ6Xo6fUvk2QDqvpR/4Df7AdeZ2y
# bS2rfMIF6N8eKxkxEJjd3eahWawt5gtxvhOayZaqZb/0/3nldo3J+ZE9njcj0Izx
# k2tepb7Et8A46xLLI/fS6fy1GISRUvyaHfEeVkuy2231qwEdnlgFeTmgzNd1suER
# SNUTTgbfEk2KniuT9+GZz8gczL6SkH2/cSFsGK2nnJ8qQ27YkzTOvb8/00UlDndy
# KZAQnAVwb/gHpjp9va9aUmRY/jV1OWFGulN3HiXpLC/tMcQowWxZGs8+k+bcMDkF
# 5ZRkSsVNj2S5ZxOx/yisgFPRv5O/ZQRVdK1VXRB1J7zJSSayEH2Hr9iKCE59RfdP
# xoR/YzoqWdy4sY3QQKaUStSLRvXHVa+Yaf6TdhfnKhEd1CrKLOgavH/2oYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMImETyz5ndzomyHV7y1X8Y6bFif0r5Pv
# UlDsfQ6+iDEXBOyGpFJXjv61iw4fyYSyswIUXXv4lw0Rpuxx349pMWWkl1poamUY
# DzIwMjUwNTE1MjI1NDIwWqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
# c3QgWW9ya3NoaXJlMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMT
# J1NlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNqCCEwQwggZi
# MIIEyqADAgECAhEApCk7bh7d16c0CIetek63JDANBgkqhkiG9w0BAQwFADBVMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNTAzMjcwMDAw
# MDBaFw0zNjAzMjEyMzU5NTlaMHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5XZXN0
# IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzYwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDThJX0bqRTePI9EEt4Egc83JSBU2dhrJ+w
# Y7JgReuff5KQNhMuzVytzD+iXazATVPMHZpH/kkiMo1/vlAGFrYN2P7g0Q8oPEcR
# 3h0SftFNYxxMh+bj3ZNbbYjwt8f4DsSHPT+xp9zoFuw0HOMdO3sWeA1+F8mhg6uS
# 6BJpPwXQjNSHpVTCgd1gOmKWf12HSfSbnjl3kDm0kP3aIUAhsodBYZsJA1imWqkA
# VqwcGfvs6pbfs/0GE4BJ2aOnciKNiIV1wDRZAh7rS/O+uTQcb6JVzBVmPP63k5xc
# ZNzGo4DOTV+sM1nVrDycWEYS8bSS0lCSeclkTcPjQah9Xs7xbOBoCdmahSfg8Km8
# ffq8PhdoAXYKOI+wlaJj+PbEuwm6rHcm24jhqQfQyYbOUFTKWFe901VdyMC4gRwR
# Aq04FH2VTjBdCkhKts5Py7H73obMGrxN1uGgVyZho4FkqXA8/uk6nkzPH9QyHIED
# 3c9CGIJ098hU4Ig2xRjhTbengoncXUeo/cfpKXDeUcAKcuKUYRNdGDlf8WnwbyqU
# blj4zj1kQZSnZud5EtmjIdPLKce8UhKl5+EEJXQp1Fkc9y5Ivk4AZacGMCVG0e+w
# wGsjcAADRO7Wga89r/jJ56IDK773LdIsL3yANVvJKdeeS6OOEiH6hpq2yT+jJ/lH
# a9zEdqFqMwIDAQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNh
# lxmiMpswHQYDVR0OBBYEFIhhjKEqN2SBKGChmzHQjP0sAs5PMA4GA1UdDwEB/wQE
# AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1Ud
# IARDMEEwNQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8v
# Y3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5j
# cmwwegYIKwYBBQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYB
# BQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IB
# gQACgT6khnJRIfllqS49Uorh5ZvMSxNEk4SNsi7qvu+bNdcuknHgXIaZyqcVmhrV
# 3PHcmtQKt0blv/8t8DE4bL0+H0m2tgKElpUeu6wOH02BjCIYM6HLInbNHLf6R2qH
# C1SUsJ02MWNqRNIT6GQL0Xm3LW7E6hDZmR8jlYzhZcDdkdw0cHhXjbOLsmTeS0Se
# RJ1WJXEzqt25dbSOaaK7vVmkEVkOHsp16ez49Bc+Ayq/Oh2BAkSTFog43ldEKgHE
# DBbCIyba2E8O5lPNan+BQXOLuLMKYS3ikTcp/Qw63dxyDCfgqXYUhxBpXnmeSO/W
# A4NwdwP35lWNhmjIpNVZvhWoxDL+PxDdpph3+M5DroWGTc1ZuDa1iXmOFAK4iwTn
# lWDg3QNRsRa9cnG3FBBpVHnHOEQj4GMkrOHdNDTbonEeGvZ+4nSZXrwCW4Wv2qyG
# DBLlKk3kUW1pIScDCpm/chL6aUbnSsrtbepdtbCLiGanKVR/KC1gsR0tC6Q0RfWO
# I4owggYUMIID/KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUA
# MFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNV
# BAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AM2Y2ENBq26CK+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStS
# VjeYXIjfa3ajoW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQ
# BaCxpectRGhhnOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE
# 9cbY11XxM2AVZn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExS
# Lnh+va8WxTlA+uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OII
# q/fWlwBp6KNL19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGd
# F+z+Gyn9/CRezKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w
# 76kOLIaFVhf5sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4Cllg
# rwIDAQABo4IBXDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUw
# HQYDVR0OBBYEFF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjAS
# BgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28u
# Y29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEF
# BQcBAQRwMG4wRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0O
# NVgMnoEdJVj9TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc
# 6ZvIyHI5UkPCbXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1
# OSkkSivt51UlmJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz
# 2wSKr+nDO+Db8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y
# 4Il6ajTqV2ifikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVM
# CMPY2752LmESsRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBe
# Nh9AQO1gQrnh1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupia
# AeNHe0pWSGH2opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU
# +CCQaL0cJqlmnx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/Sjws
# usWRItFA3DE8MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7
# xpMeYRriWklUPsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs6
# 56Oz3TbLyXVoMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAs
# BgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJ
# BZvMWhUP2ZQQRLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQn
# Oh2qmcxGzjqemIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypo
# GJrruH/drCio28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0p
# KG9ki+PC6VEfzutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13j
# QEV1JnUTCm511n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9
# YrcmXcLgsrAimfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/y
# Vl4jnDcw6ULJsBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVg
# h60KmLmzXiqJc6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/
# OLoanEWP6Y52Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+Nr
# LedIxsE88WzKXqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58N
# Hs57ZPUfECcgJC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9U
# gOHYm8Cd8rIDZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1Ud
# DwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0
# eS5jcmwwNQYIKwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3
# OyWM637ayBeR7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJ
# JlFfym1Doi+4PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0m
# UGQHbRcF57olpfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTw
# bD/zIExAopoe3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i
# 111TW7HV1AtsQa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGe
# zjM6CRpcWed/ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+
# 8aW88WThRpv8lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH
# 29308ZkpKKdpkiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrs
# xrYJD+3f3aKg6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6
# Ii8+CQOYDwXM+yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz
# 7NgAnOgpCdUo4uDyllU9PzGCBJIwggSOAgEBMGowVTELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMg
# VGltZSBTdGFtcGluZyBDQSBSMzYCEQCkKTtuHt3XpzQIh616TrckMA0GCWCGSAFl
# AwQCAgUAoIIB+TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTI1MDUxNTIyNTQyMFowPwYJKoZIhvcNAQkEMTIEMAWf+L6pcIUK7Rql
# 2PmMsbaUuBIuKWUJlhzLlgu2XpD9/GJX+crQKozr9Oe5SvhA0DCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAPT//3ZPjJ6SeioEiOrWJovsReuwc4XweM5PylKQ81zRCKS2iJBo13SoV
# 3xr6YD2OebQgvJfO4lbmct185/lDbbApVVVUIv0wEFhZFoo/HM/oEGQERZLxXAVh
# qvcOOPKCaiXwsvCUPgee/ObY81lp/C/algy8PQT0NlZVnNsKjXNOvPjhvWepaD/c
# 6HS1cPw0jSdm84BAq6OufwbUljaaLhrRl/mOBcM4IF/kS/Jur0TdGpJLHk3zwk+L
# aJTXL0hHtSF+P4ViY6vFGZLcIssx/xlh28g8ZgaDg14iEJC8PRnjYnbHO/Ex7jSZ
# qohZ1yDk4h4s58Nzvh1OXXzJ+yAamRFjHW+fkLsIjat9nZfEtnm2ilHFzUr7+01Q
# qS24WHcBBJRaUbC/UNZJnEc25lKOmQhPudwkofqKnbcaTK+7E9TlIIN1PkdTWqcP
# PmHPpg3BHwk/YcmwgQLUq66e/U4IDGhFWR3dyNjKD0A56vvvNx9CVaIw9+z9P5WD
# dpUtE2OHk7odgbLCkIp2IZ01oYdsh8slupvQClz/lsYVsLMP0xrAGzhgyY7RHCVa
# tfA4JaYdTqVQem4PPla1wiy4qqRJCB7FrMmQkC8QxnQzfPnBOx31p678eJq4Ctfc
# sRzQPnCYPc9ELs5EgEdH6mgYGk3KPzM7hYXWsbULdVBFD540lso=
# SIG # End signature block
