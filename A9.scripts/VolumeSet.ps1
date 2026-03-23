## 	©2025 Hewlett Packard Enterprise Development LP


Function New-A9VvSet
{
<#
.SYNOPSIS
	Creates a new Volume Set.
.DESCRIPTION
	Creates a new Volume Set.
	The Volume set may contain any number of Volumes, but can be create empty as well. 
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
.EXAMPLE
	PS:> New-A9VvSet -VolumeSetName MyVVSet

	Creates a new empty Volume Set with name MyVVSet.
.EXAMPLE
	PS:> New-A9VvSet -VolumeSetName MyVVSet -SetMembers vol1,vol2,vol3

	Creates a new Volume Set with name MyVVSet.
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
	If ($Comment) 			{	$body["comment"] 		= $Comment  		}  
	If ($Domain)    		{	$body["domain"] 		= $Domain	 		}
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

Function Set-A9VvSet 
{
<#
.SYNOPSIS
	Update an existing virtual volume Set.
.DESCRIPTION
	Update an existing virtual volume Set.
    You may alter the properties of the Volume set such as the name, the comment, or you may add/remove volumes from the volume set, you may also issue commands to stop/resync/promote a volume set as well.  
.PARAMETER VolumeSetName,
	Existing virtual volume Set Name
.PARAMETER NewName
	New name of the virtual volume set.
.PARAMETER Comment
	New comment for the virtual volume set or host set.
	To remove the comment, use “”.
.PARAMETER AddMember
	Adds a member to a volume set. You must also specific the members to add.
.PARAMETER RemoveMember
	Removes a member from a volume set. You must specific the members to remove.
.PARAMETER Members
	The volume(s) to be added to or removed from the virtual volume set. 
.PARAMETER ResyncPhysicalCopy
	Resynchronize the physical copy to its virtual volume set.
.PARAMETER StopPhysicalCopy
	Stops the physical copy.
.PARAMETER PromoteVirtualCopy
	Promote virtual copies in a virtual volume set.
.PARAMETER StopPromoteVirtualCopy
	Stops the promote virtual copy operations in a virtual volume set.
.PARAMETER Priority
	May be high, medium or low, and only used when resyncing a volume set. The default value of medium is used if not specified.
.EXAMPLE
	PS:> Set-A9VvSet -VolumeSetName, xxx -RemoveMember -Members testvv3.0
.EXAMPLE 
	PS:> SetA9VvSet -VolumeSetName, xxx -AddMember -Members testvv3.0
.EXAMPLE 
	PS:> Set-A9VvSet -VolumeSetName, xxx -ResyncPhysicalCopy -Priority high
.EXAMPLE 
	PS:> Set-A9VvSet -VolumeSetName, xxx -StopPhysicalCopy 
.EXAMPLE 
	PS:> Set-A9VvSet -VolumeSetName, xxx -PromoteVirtualCopy
.EXAMPLE 
	PS:> Set-A9VvSet -VolumeSetName, xxx -StopPromoteVirtualCopy
.EXAMPLE 
	PS:> Set-A9VvSet -VolumeSetName, xxx -NewName as-vvSet1 -Comment "Updateing new name"#>
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
	$Result = Invoke-A9API -uri $uri -type 'GET'		 
	If($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
			if ( $dataPS.members ) {	$dataps = $dataPS.members }
			write-host "Cmdlet executed successfully" -foreground green
			$NewObj = @(    foreach( $Item in $DataPS)	{   $NewItem=@{PSTypeName = "HPE.A9Storage.VolumeSet"}
															$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
															$DataSetType = "HPE.A9Storage.VolumeSet"
															$NewItem.PSTypeNames.Insert(0,$DataSetType)
															$DataSetType = $DataSetType + ".TypeName"
															$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
															[PSCustomObject]$NewItem
														}
						)
			
			
			if ( $VolumeSetName )
				{	$MySet = $NewObj | where-object {$_.name -like $VolumeSetName }
					return $MySet
				}
			return $NewObj
		}
	else{	Write-Error "Failure:  While Executing Get-VvSet." 
		return $Result.StatusDescription
		}
}
}

Function Remove-A9VvSet
{
<#
.SYNOPSIS
    Remove a Virtual Volume set
.DESCRIPTION
	Removes a VV set. If you need to remove a single (or multiple) Volumes from a VolumeSet, use the Set-A9VvSet command.
.PARAMETER VolumeSetName 
    Specify name of the VolumesetName..
.EXAMPLE
    PS:> Remove-A9VvSet -VolumeSetName "MyVVSet"

	Remove a VV set "MyVVSet"
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	[Parameter(ParameterSetName='API', Mandatory=$true)]	[String]	$VolumeSetName
	)	
Begin	
{	Test-A9Connection -CLientType 'API' 
}
process
{	$uri = '/volumesets/'+$VolumeSetName
	$Result = $null
	$Result = Invoke-A9API -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return
		}
	else
		{	Write-Error "Failure:  While Removing virtual volume Set:$VolumeSetName " 
			return $Result.StatusDescription
		} 
}
}