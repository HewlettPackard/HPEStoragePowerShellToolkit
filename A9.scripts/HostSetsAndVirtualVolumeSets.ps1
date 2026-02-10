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
	PS:> New-A9HostSet -HostSetName MyHostSet -SetMembers AzureLocalNode1A, AzureLocalNode1B, AzureLocalNode2A, AzureLocalNode2B
	Cmdlet executed successfully

	 id uuid                                 name              setmembers
 	-- ----                                 ----              ----------
	102 f78a33cc-e60d-4465-910c-28ba9e85d767 AzureLocalCluster {AzureLocalNode1A, AzureLocalNode1B, AzureLocalNode2A,…
	
	Creates a new host Set with name MyHostSet with Set Members AzureLocalNode**.	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$HostSetName,	  
		[Parameter()]			[String]	$Comment,	
		[Parameter()]			[String]	$Domain, 
		[Parameter()]			[String[]]	$SetMembers
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
	Update an existing Host Set. by adding or removing members, or altering its name or comment.
.EXAMPLE    
	PS:> Update-A9HostSet -HostSetName xxx -NewName yyy
.EXAMPLE    
	PS:> Update-A9HostSet -HostSetName xxx -RemoveMember -Members as-Host4
.EXAMPLE
	PS:> Update-A9HostSet -HostSetName xxx -AddMember -Members as-Host4
.PARAMETER HostSetName
	Existing Host Name
.PARAMETER AddMember
	Adds a member to the VV set.
.PARAMETER RemoveMember
	Removes a member from the VV set.
.PARAMETER NewName
	New name of the set.
.PARAMETER Comment
	New comment for the VV set or host set.
	To remove the comment, use “”.
.PARAMETER Members
	The volume or host to be added to or removed from the set.
#>
[CmdletBinding(DefaultParameterSetName="default")]
Param(
		[Parameter(Mandatory, ParameterSetName='Default')]	
		[Parameter(Mandatory, ParameterSetName='AddMember')]
		[Parameter(Mandatory, ParameterSetName='RemoveMember')]
																[String]	$HostSetName,
		[Parameter(Mandatory, ParameterSetName='AddMember')]	[switch]	$AddMember,	
		[Parameter(Mandatory, ParameterSetName='RemoveMember')]	[switch]	$RemoveMember,
		[Parameter(Mandatory, ParameterSetName='Default')]		[String]	$NewName,
		[Parameter(Mandatory, ParameterSetName='Default')]		[String]	$Comment,
		[Parameter(Mandatory, ParameterSetName='AddMember')]	
		[Parameter(Mandatory, ParameterSetName='RemoveMember')] [String[]]	$Members
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	Switch($PSCmdlet.ParameterSetName)
			{	'AddMember'		{	$body['action'] = 1 }
				'RemoveMember'	{	$body['action'] = 2 }
			}
	If ($NewName) 	{	$body["newName"] = "$($NewName)"	}
	If ($Comment) 	{	$body["comment"] = "$($Comment)"    }	
	If ($Members) 	{	$body["setmembers"] = $Members  	}
	if ( $Body = @{} )
			{	write-warning "No Changable Options have been selected. You must choose to change something"
				return
			}
	$Result = $null	
	$uri = '/hostsets/'+$HostSetName 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)	{	Get-A9HostSet -HostSetName $NewName	}	
			else			{	Get-A9HostSet -HostSetName $HostSetName	}
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
.PARAMETER HostSetName 
	Specify the name of Host Set to be removed.
.EXAMPLE    
	PS:> Remove-A9HostSet -HostSetName MyHostSet
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]$HostSetName
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
	Creates a new Volume Set.
.DESCRIPTION
	Creates a new Volume Set.
	The Volume set may contain any number of Volumes, but can be create empty as well. 
.EXAMPLE
	PS:> New-A9VvSet -VolumeSetName MyVVSet

	Creates a new empty Volume Set with name MyVVSet.
.EXAMPLE
	PS:> New-A9VvSet -VolumeSetName MyVVSet -SetMembers vol1,vol2,vol3

	Creates a new Volume Set with name MyVVSet.
.PARAMETER VolumeSetName
	Name of the Volume set to be created.
.PARAMETER SetMembers
	Contains a list of volumes to add as members, the list is comma deliminated with no whitespace.
.PARAMETER Comment
	Comment for the virtual volume set.
.PARAMETER Domain
	Domain for the virtual volume set.
.PARAMETER apptype
	The appyType for which the volume set will be created.
.PARAMETER businessUnit
	The business unit to which the volume iwll be used.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$VolumeSetName,	  
		[Parameter()]			[String[]]	$SetMembers,
		[Parameter()]			[String]	$Comment,	
		[Parameter()]			[String]	$Domain, 
		[Parameter()]			[String]	$appType,
		[Parameter()]			[String]	$buisnessUnit
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = [ordered]@{}    
    $body["name"] = "$($VolumeSetName)"
	If ($Comment) 			{	$body["comment"] 		= "$($Comment)"   	}  
	If ($Domain)    		{	$body["domain"] 		= "$($Domain)"	 	}
	If ($SetMembers)		{	$body["setmembers"] 	= $SetMembers   	}
	If ($appType)			{	$body["appType"] 		= $appType   		}
	If ($businessUnit)		{	$body["businessUnit"] 	= $businessUnit   	}
    $Result = $null
    $Result = Invoke-A9API -uri '/volumesets' -type 'POST' -body $body 
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "Cmdlet executed successfully" -foreground green
		return ( Get-a9VvSet | where-object {$_.name -like $VolumeSetName})
	}
	else
	{	Write-Error "Failure:  While creating virtual volume Set:$VolumeSetName " 
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
[CmdletBinding(DefaultParameterSetName='Default')]
Param(
	[Parameter(Mandatory)]									[String]	$VolumeSetName,
	[Parameter(Mandatory, ParameterSetName='AddMember')]	[switch]	$AddMember,	
	[Parameter(Mandatory, ParameterSetName='RemoveMember')]	[switch]	$RemoveMember,	
	[Parameter(Mandatory, ParameterSetName='Resync')]		[switch]	$ResyncPhysicalCopy,	
	[Parameter(Mandatory, ParameterSetName='StopCopy')]		[switch]	$StopPhysicalCopy,	
	[Parameter(Mandatory, ParameterSetName='Promote')]		[switch]	$PromoteVirtualCopy,
	[Parameter(Mandatory, ParameterSetName='StopPromote')]	[switch]	$StopPromoteVirtualCopy,	
	[Parameter()]											[String]	$NewName,	
	[Parameter()]											[String]	$Comment,
	[Parameter(Mandatory, ParameterSetName='AddMember')]
	[Parameter(Mandatory, ParameterSetName='RemoveMember')]	[String[]]	$Members,
	[Parameter(ParameterSetName='Resync')]
	[ValidateSet('high','medium','low')]					[String]	$Priority
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	Switch($PSCmdlet.ParameterSetName)
			{	'AddMember'		{	$body['action'] = 1 }
				'RemoveMember'	{	$body['action'] = 2 }
				'Resync'		{	$body['action'] = 3 }
				'StopCopy'		{	$body['action'] = 4 }
				'Promote'		{	$body['action'] = 5 }
				'StopPromote'	{	$body['action'] = 6	}
			}
	If ($NewName) 				{	$body["newName"] = "$($NewName)" }
	If ($Comment) 				{	$body["comment"] = "$($Comment)" }
	If ($Members) 				{	$body["setmembers"] = $Members   }
	if ($Priority -eq "high")	{	$body["priority"] = 1			 }	
	if ($Priority -eq "medium")	{	$body["priority"] = 2			 }
	if ($Priority -eq "low")	{	$body["priority"] = 3			 }
	
    $Result = $null	
	$uri = '/volumesets/'+$VolumeSetName 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)
				{	return Get-A9VvSet -VolumeSetName $NewName
				}
			else
				{	return Get-A9VvSet -VolumeSetName $VolumeSetName
				}
			Write-Verbose "End: Update-A9VvSet"
		}
	else
	{	Write-Error "Failure:  While Updating virtual volume Set: $VolumeSetName " 
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
.PARAMETER VVSetName
	Specify name of the virtual volume Set.
.EXAMPLE
	PS:> Get-A9VvSet

	Display a list of virtual volume Set.
.EXAMPLE
	PS:> Get-A9VvSet -VolumeSetName MyVolSet1

	Display a only the Volume Set named MyVolSet1.
.EXAMPLE
	PS:> Get-A9VvSet -VVSetName MyvvSet | where-object { $_.setmembers -contains "VolumeXYZ" }
	
	This command will gather all of the VolumeSets and filter to only show those where the volume named VolumeXYZ is present
.EXAMPLE
	PS:> Get-A9VvSet -VVSetName MyvvSet | where-object { $_.id -like 853 }
	
	This command will gather all of the VolumeSets and filter to only show the volumeset with the ID of 853
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$VolumeSetName
	 )
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	$uri = '/volumesets/'
	if($VVSetName)	{	$uri += $VolumeSetName	}	
	$Result = Invoke-A9API -uri $uri -type 'GET'		 
	If($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
			write-host "Cmdlet executed successfully" -foreground green
			if ( $VolumeSetName )
				{	$MySet = $dataPS.members | where-object {$_.name -like $VolumeSetName }
					return $MySet
				}
			return $dataPS.members
		}
	else{	Write-Error "Failure:  While Executing Get-VvSet_WSAPI." 
		return $Result.StatusDescription
		}
}
}
