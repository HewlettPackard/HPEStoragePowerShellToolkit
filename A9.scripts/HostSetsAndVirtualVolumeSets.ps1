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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$HostSetName,	  
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment,	
		[Parameter(ValueFromPipeline=$true)]					[String]	$Domain, 
		[Parameter(ValueFromPipeline=$true)]					[String[]]	$SetMembers
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
    $Result = Invoke-WSAPI -uri '/hostsets' -type 'POST' -body $body
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]					[String]	$HostSetName,
		[Parameter(ParameterSetName='AddMember', ValueFromPipeline=$true)]		[switch]	$AddMember,	
		[Parameter(ParameterSetName='RemoveMember', ValueFromPipeline=$true)]	[switch]	$RemoveMember,
		[Parameter(ParameterSetName='Resync', ValueFromPipeline=$true)]			[switch]	$ResyncPhysicalCopy,
		[Parameter(ParameterSetName='Stop', ValueFromPipeline=$true)]			[switch]	$StopPhysicalCopy,
		[Parameter(ParameterSetName='Promote', ValueFromPipeline=$true)]		[switch]	$PromoteVirtualCopy,
		[Parameter(ParameterSetName='StopPromote', ValueFromPipeline=$true)]	[switch]	$StopPromoteVirtualCopy,
		[Parameter(ValueFromPipeline=$true)]									[String]	$NewName,
		[Parameter(ValueFromPipeline=$true)]									[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]									[String[]]	$Members,
		[Parameter(ValueFromPipeline=$true)]	
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
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
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
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE'
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

Function Get-A9HostSet 
{
<#
.SYNOPSIS
	Get Single or list of Hotes Set.
.DESCRIPTION
	Get Single or list of Hotes Set.
.EXAMPLE
	PS:> Get-A9HostSet

	Display a list of Hotes Set.
.EXAMPLE
	PS:> Get-A9HostSet -HostSetName MyHostSet

	Get the information of given Hotes Set.
.EXAMPLE
	PS:> Get-A9HostSet -Members MyHost

	Get the information of Hotes Set that contain MyHost as Member.
.EXAMPLE
	PS:> Get-A9HostSet -Members "MyHost,MyHost1,MyHost2"

	Multiple Members.
.EXAMPLE
	PS:> Get-A9HostSet -Id 10

	Filter Host Set with Id
.EXAMPLE
	PS:> Get-A9HostSet -Uuid 10

	Filter Host Set with uuid
.EXAMPLE
	PS:> Get-A9HostSet -Members "MyHost,MyHost1,MyHost2" -Id 10 -Uuid 10

	Multiple Filter
.PARAMETER HostSetName
	Specify name of the Hotes Set.
.PARAMETER Members
	Specify name of the Hotes.
.PARAMETER Id
	Specify id of the Hotes Set.
.PARAMETER Uuid
	Specify uuid of the Hotes Set.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$HostSetName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Members,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Id,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Uuid
)
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($HostSetName)
		{	$uri = '/hostsets/'+$HostSetName
			$Result = Invoke-WSAPI -uri $uri -type 'GET' 
			If($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
					write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-HostSet_WSAPI." 
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
	if($Id)
		{	if($Members)	{	$Query = $Query.Insert($Query.Length-3," OR id EQ $Id")	}
			else			{	$Query = $Query.Insert($Query.Length-3," id EQ $Id")	}
		}
	if($Uuid)
		{	if($Members -or $Id)	{	$Query = $Query.Insert($Query.Length-3," OR uuid EQ $Uuid")	}
			else					{	$Query = $Query.Insert($Query.Length-3," uuid EQ $Uuid")	}
		}	
	$uri = '/hostsets'
	if($Members -Or $Id -Or $Uuid)
		{	$uri = $uri+'/'+$Query
		}	
	$Result = Invoke-WSAPI -uri $uri -type 'GET'	
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-HostSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid." 
					return 
				}		
		}
	else
		{	Write-Error "Failure:  While Executing Get-HostSet_WSAPI." 
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
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]		[String]	$VVSetName,	  
		[Parameter(ValueFromPipeline=$true)]			[String]	$Comment,	
		[Parameter(ValueFromPipeline=$true)]						[String]	$Domain, 
		[Parameter(ValueFromPipeline=$true)]						[String[]]	$SetMembers
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
    $Result = Invoke-WSAPI -uri '/volumesets' -type 'POST' -body $body 
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
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VVSetName,
	[Parameter(ValueFromPipeline=$true)]	[switch]	$AddMember,	
	[Parameter(ValueFromPipeline=$true)]	[switch]	$RemoveMember,	
	[Parameter(ValueFromPipeline=$true)]	[switch]	$ResyncPhysicalCopy,	
	[Parameter(ValueFromPipeline=$true)]	[switch]	$StopPhysicalCopy,	
	[Parameter(ValueFromPipeline=$true)]	[switch]	$PromoteVirtualCopy,
	[Parameter(ValueFromPipeline=$true)]	[switch]	$StopPromoteVirtualCopy,	
	[Parameter(ValueFromPipeline=$true)]	[String]	$NewName,	
	[Parameter(ValueFromPipeline=$true)]	[String]	$Comment,
	[Parameter(ValueFromPipeline=$true)]	[String[]]	$Members,
	[Parameter(ValueFromPipeline=$true)]
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
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
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
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$VVSetName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Members,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Id,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Uuid
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
			$Result = Invoke-WSAPI -uri $uri -type 'GET'		 
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
			$Result = Invoke-WSAPI -uri $uri -type 'GET'	
		}	
	else{	$Result = Invoke-WSAPI -uri '/volumesets' -type 'GET' 
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

Function Set-A9VvSetFlashCachePolicy
{
<#      
.SYNOPSIS	
	Setting a VV-set Flash Cache policy.
.DESCRIPTION	
    Setting a VV-set Flash Cache policy.
.EXAMPLE	
	PS:> Set-A9VvSetFlashCachePolicy
.PARAMETER VvSet
	Name Of the VV-set to Set Flash Cache policy.
.PARAMETER Enable
	To Enable VV-set Flash Cache policy
.PARAMETER Disable
	To Disable VV-set Flash Cache policy
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VvSet,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$Enable,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$Disable
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}		
	If($Enable) 		{	$body["flashCachePolicy"] = 1	}		
	elseIf($Disable) 	{	$body["flashCachePolicy"] = 2 	}
	else				{	$body["flashCachePolicy"] = 2 	}		
    $Result = $null
	$uri = '/volumesets/'+$VvSet
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else{	Write-Error "Failure:  While Setting Flash Cache policy (1 = enable, 2 = disable) $body to vv-set $VvSet." 
			return $Result.StatusDescription
		}
}
}

