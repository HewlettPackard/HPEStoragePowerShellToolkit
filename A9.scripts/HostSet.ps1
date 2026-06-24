## 	©2025 Hewlett Packard Enterprise Development LP


Function Set-A9HostTargetZoneingWWN
{
<#
.SYNOPSIS
	Add or remove a host WWN from target-driven zoning
.DESCRIPTION    
	Add a host WWN from target-driven zoning. 
.PARAMETER HostName
	Host Name.
.PARAMETER FCWWNs
	WWNs of the host.
.PARAMETER Port
	Specifies the ports for target-driven zoning. Use this option when the Smart SAN license is installed only.
	This field is NOT supported for the following actions:ADD_WWN_TO_HOST REMOVE_WWN_FROM_H OST, It is a required field for the following actions:ADD_WWN_TO_TZONE REMOVE_WWN_FROM_T ZONE.
.PARAMETER AddWwnToHost
	its a action to be performed. Recommended method for adding WWN to host. Operates the same as using a PUT method with the pathOperation specified as ADD.
.PARAMETER RemoveWwnFromHost
	Recommended method for removing WWN from host. Operates the same as using the PUT method with the pathOperation specified as REMOVE.
.PARAMETER AddWwnToTZone   
	Adds WWN to target driven zone. Creates the target driven zone if it does not exist, and adds the WWN to the host if it does not exist.
.PARAMETER RemoveWwnFromTZone
	Removes WWN from the targetzone. Removes the target driven zone unless it is the last WWN. Does not remove the last WWN from the host.
.EXAMPLE
	PS:> Add-A9RemoveHostWWN -HostName MyHost -FCWWNs "$wwn" -AddWwnToHost
.EXAMPLE	
	PS:> Add-A9RemoveHostWWN -HostName MyHost -FCWWNs "$wwn" -RemoveWwnFromHost
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true)]				[String]	$HostName,
		[Parameter(Mandatory=$true)]				[String[]]	$FCWWNs,
		[Parameter(ParameterSetName='AddZone')]
		[Parameter(ParameterSetName='RemZone')]		[String[]]	$Port,
		[Parameter(ParameterSetName='AddHost', Mandatory=$true)]	[switch]	$AddWwnToHost,
		[Parameter(ParameterSetName='RemHost', Mandatory=$true)]	[switch]	$RemoveWwnFromHost,
		[Parameter(ParameterSetName='AddZone', Mandatory=$true)]	[switch]	$AddWwnToTZone,
		[Parameter(ParameterSetName='RemZone', Mandatory=$true)]	[switch]	$RemoveWwnFromTZone
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
    If($AddWwnToHost) 			{	$body["action"] = 1    }
	elseif($RemoveWwnFromHost)	{	$body["action"] = 2	}
	elseIf($AddWwnToTZone)     	{	$body["action"] = 3    }
	elseif($RemoveWwnFromTZone)	{	$body["action"] = 4	}
	$ParametersBody = @{} 
    If($FCWWNs) 			    {	$ParametersBody["FCWWNs"] = $FCWWNs }
	If($Port)					{	$ParametersBody["port"] = $Port    }
	if($ParametersBody.Count -gt 0){$body["parameters"] = $ParametersBody 	}
    $Result = $null
	$uri = '/hosts/'+$HostName
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			Get-A9Host -HostName $HostName
		}
	else
		{	Write-Error "Failure:  Cmdlet Execution failed with Host : $HostName." 
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
	Get Single or list of Hotes Set.  the command will attempt to use the API to accomplish the task, 
    if the API is unavalable or other parameters are used, the command will attempt to fail back to a SSH type connection to accomplish the goal.  
.PARAMETER HostSet
	Specify name of the Hotes Set. This Parameter is valid for API and SSH type connections.
.EXAMPLE
    PS:> Get-A9HostSet | format-table
    
    Cmdlet executed successfully
    id uuid                                 name             setmembers
    -- ----                                 ----             ----------
    0  a6751a4a-35f0-4641-a20c-6ab79f644c9a test             {bm9}
    25 9377a9b4-e1c3-445f-a34d-c6d571ba5c82 tmaas_cluster1   {ftc-tmaas-cl1-esx1, ftc-tmaas-cl1-esx2, ftc-tmaas-cl1-esx3, ftc-tmaas-cl1-esx4…}
    28 9a8fc3dc-30c6-4c95-a8b0-bc3437217a6c Veeambkpsrv      {veeam12bkpsrv}
.EXAMPLE
	PS:> Get-A9HostSet -HostSet MyHostSet

	Get the information of given Hotes Set.
.EXAMPLE
	PS:> Get-A9HostSet | where {$_.setmembers -contains 'MyServer' }

	This replicates the old feature of -members so that the command can be simplified. This allows you to only return HostSets that contains a specific server.
.EXAMPLE
	PS:> Get-A9HostSet | where {$_.id -like '16'}

	The following replicates using an ID Filter to retreive only a known ID HostSet
.EXAMPLE
	PS:> Get-A9HostSet | where {$_.uuid -like '4eee167a-1a69-4620-9c0e-86a2c9b5772f'}

	The following replicates using an ID Filter to retreive only a known ID HostSet
.NOTES
    CLI Options such as -D or Members can be derived directly from the returned objects, as such they are not valid parameteres to include in the command.
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	[Parameter(ParameterSetName='API')]	    [String]	$HostSet
    )
Begin 
    {	Test-A9Connection -CLientType 'API'
    }
Process 
    {	$uri = '/hostsets'
       $Result = Invoke-A9API -uri $uri -type 'GET'
        If ($Result.StatusCode -eq 200)
            {	$dataPS1 = ($Result.content | ConvertFrom-Json)
                if ($dataPS1.members) { $dataPS = $dataPS1.members }
                if ($dataPS.Count -gt 0)
                    {	write-host "Cmdlet executed successfully" -foreground green
                        $NewObj = @(    foreach( $Item in $DataPS)	
                                            {   $NewItem=@{PSTypeName = "HPE.A9Storage.HostSet"}
                                                $Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
                                                $DataSetType = "HPE.A9Storage.HostSet"
                                                $NewItem.PSTypeNames.Insert(0,$DataSetType)
                                                $DataSetType = $DataSetType + ".TypeName"
                                                $NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
                                                [PSCustomObject]$NewItem
                                            }
                                    )
						write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                        if ( $HostSetName ) 
                            {   return ($NewObj | where-object {$_.name -like $HostSet } )
                            }
                        else
                            {   return $NewObj
                            }
                    }
                else
                    {	Write-Error "Failure:  While Executing Get-A9HostSet. Expected Result Not Found." 
                        return 
                    }		
            }
        else
            {	Write-Error "Failure:  While Executing Get-A9HostSet." 
                return $Result.StatusDescription
            }
    }
}

Function New-A9HostSet 
{
<#
.SYNOPSIS
	Creates a new host Set.
.DESCRIPTION
	Creates a new host Set record. This HostSet record will contain properties of the host set as well as the hosts that are its members.   
.PARAMETER HostSet
	Name of the host set to be created.
.PARAMETER Comment
	Comment for the host set.
.PARAMETER Domain
	The domain in which the host set will be created.
.PARAMETER Members
	The host to be added to the set. 
.EXAMPLE
	PS:> New-A9HostSet -HostSet MyHostSet

	Creates a new host Set with name MyHostSet.
.EXAMPLE
	PS:> New-A9HostSet -HostSet MyHostSet -Comment "this Is Test Set" -Domain MyDomain

	Creates a new host Set with name MyHostSet.
.EXAMPLE
	PS:> New-A9HostSet -HostSet MyHostSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers MyHost

	Creates a new host Set with name MyHostSet with Set Members MyHost.	
.EXAMPLE	
	PS:> New-A9HostSet -HostSet MyHostSet -SetMembers AzureLocalNode1A, AzureLocalNode1B, AzureLocalNode2A, AzureLocalNode2B
	Cmdlet executed successfully

	 id uuid                                 name              setmembers
 	-- ----                                 ----              ----------
	102 f78a33cc-e60d-4465-910c-28ba9e85d767 AzureLocalCluster {AzureLocalNode1A, AzureLocalNode1B, AzureLocalNode2A,…
	
	Creates a new host Set with name MyHostSet with Set Members AzureLocalNode**.	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$HostSet,	  
		[Parameter()]			[String]	$Comment,	
		[Parameter()]			[String]	$Domain, 
		[Parameter()]			[String[]]	$Members
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["name"] = "$($HostSet)"
	If ($Comment) 	{	$body["comment"] = "$($Comment)"}  
	If ($Domain) 	{	$body["domain"] = "$($Domain)"    }	
	If ($SetMembers){	$body["setmembers"] = $Members    }
    $Result = $null
    $Result = Invoke-A9API -uri '/hostsets' -type 'POST' -body $body 
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
		return Get-A9HostSet -HostSetName $HostSet
	}
	else
	{	Write-Error "Failure:  While creating Host Set:$HostSet " 
		return $Result.StatusDescription
	}	
}
}

Function Set-A9HostSet 
{
<#
.SYNOPSIS
	Update an existing Host Set.
.DESCRIPTION
	Update an existing Host Set. by adding or removing members, or altering its name or comment.
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
.EXAMPLE    
	PS:> Set-A9HostSet -HostSetName xxx -NewName yyy
.EXAMPLE    
	PS:> Set-A9HostSet -HostSetName xxx -RemoveMember -Members as-Host4
.EXAMPLE
	PS:> Set-A9HostSet -HostSetName xxx -AddMember -Members as-Host4
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
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
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
Param(	[Parameter(Mandatory)]	[String]	$HostSetName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$uri = '/hostsets/'+$HostSetName
	$Result = Invoke-A9API -uri $uri -type 'DELETE'
	if ( $Result.StatusCode -ne 200 )
		{	Write-Error "Failure:  While Removing Host Set:$HostSetName " 
			return $Result.StatusDescription
		}   
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	return 
}
}
