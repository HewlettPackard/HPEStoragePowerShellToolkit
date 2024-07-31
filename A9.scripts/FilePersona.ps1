####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Get-A9FileServices 
{
<#
.SYNOPSIS
	Get the File Services information.
.DESCRIPTION
	Get the File Services information.
.EXAMPLE
    PS:> Get-A9FileServices
#>
[CmdletBinding()]
Param()
Begin
{	Test-A9Connection -ClientType 'API' 
}
Process
{	$Result = Invoke-A9API -uri '/fileservices' -type 'GET'
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json)
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS
		}
	else
		{	write-error "FAILURE : While Executing Get-A9FileServices."
			return $Result.StatusDescription
		}  
}
}

Function New-A9FPG 
{
<#
.SYNOPSIS
	Creates a new File Provisioning Group(FPG).
.DESCRIPTION
	Creates a new File Provisioning Group(FPG).
.EXAMPLE
	PS:> New-A9FPG -PFGName "MyFPG" -CPGName "MyCPG"	-SizeTiB 12

	Creates a new File Provisioning Group(FPG), size must be in Terabytes
.EXAMPLE	
	PS:> New-A9FPG -FPGName asFPG -CPGName cpg_test -SizeTiB 1 -FPVV $true
.EXAMPLE	
	PS:> New-A9FPG -FPGName asFPG -CPGName cpg_test -SizeTiB 1 -TDVV $true
.EXAMPLE	
	PS:> New-A9FPG -FPGName asFPG -CPGName cpg_test -SizeTiB 1 -NodeId 1
.PARAMETER FPGName
	Name of the FPG, maximum 22 chars.
.PARAMETER CPGName
	Name of the CPG on which to create the FPG.
.PARAMETER SizeTiB
	Size of the FPG in terabytes.
.PARAMETER FPVV
	Enables (true) or disables (false) FPG volume creation with the FPVV volume. Defaults to false, creating the FPG with the TPVV volume.
.PARAMETER TDVV
	Enables (true) or disables (false) FPG volume creation with the TDVV volume. Defaults to false, creating the FPG with the TPVV volume.
.PARAMETER NodeId
	Bind the created FPG to the specified node.
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the FPG.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]		$FPGName,	  
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]		$CPGName,	
		[Parameter(ValueFromPipeline=$true)]					[int]			$SizeTiB, 
		[Parameter(ValueFromPipeline=$true)]		[Boolean]		$FPVV,
		[Parameter(ValueFromPipeline=$true)]		[Boolean]		$TDVV,
		[Parameter(ValueFromPipeline=$true)]		[int]			$NodeId,
		[Parameter(ValueFromPipeline=$true)]		[String]		$Comment
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["name"] = "$($FPGName)"
	$body["cpg"] = "$($CPGName)"
	$body["sizeTiB"] = $SizeTiB
	If ($FPVV)  	{	$body["fpvv"] 	= $FPVV 		}  
	If ($TDVV) 		{	$body["tdvv"] 	= $TDVV   		} 
	If ($NodeId) 	{	$body["nodeId"] = $NodeId   	}
	If ($Comment) 	{	$body["comment"] = "$($Comment)"}
    $Result = $null
	$Result = Invoke-A9API -uri '/fpgs' -type 'POST' -body $body
	$status = $Result.StatusCode	
	if($status -eq 202)
		{	write-host "Cmdlet executed successfully" -foreground green
			return Get-FPG_WSAPI -FPG $FPGName
		}
	else
		{	write-error "FAILURE : While creating File Provisioning Groups:$FPGName" 
			return $Result.StatusDescription
		}	
}
}

Function Remove-A9FPG
{
<#
.SYNOPSIS
	Remove a File Provisioning Group.
.DESCRIPTION
	Remove a File Provisioning Group.
.PARAMETER FPGId 
	Specify the File Provisioning Group uuid to be removed.
.EXAMPLE    
	PS:> Remove-A9FPG -FPGId 123 
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
		[String]	$FPGId
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$uri = '/fpgs/'+$FPGId
	$Result = $null
	$Result = Invoke-A9API -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 202)
		{	write-host "Cmdlet executed successfully" -foreground green
			return 
		}
	else
		{	write-error "FAILURE : While Removing File Provisioning Group : $FPGId "
			return $Result.StatusDescription
		}    
}
}

Function Get-A9FPG 
{
<#
.SYNOPSIS
	Get Single or list of File Provisioning Group.
.DESCRIPTION
	Get Single or list of File Provisioning Group.
.PARAMETER FPG
	Name of File Provisioning Group.
.EXAMPLE
	PS:> Get-A9FPG

	Display a list of File Provisioning Group.
.EXAMPLE
	PS:> Get-A9FPG -FPG MyFPG

	Display a Given File Provisioning Group.
.EXAMPLE
	PS:> Get-A9FPG -FPG "MyFPG,MyFPG1,MyFPG2,MyFPG3"

	Display Multiple File Provisioning Group.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$FPG
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($FPG)
		{	$count = 1
			$lista = $FPG.split(",")
			if($lista.Count -gt 1)
				{	foreach($sub in $lista)
						{	$Query = $Query.Insert($Query.Length-3," name EQ $sub")			
							if($lista.Count -gt 1)
								{	if($lista.Count -ne $count)
										{	$Query = $Query.Insert($Query.Length-3," OR ")
											$count = $count + 1
										}				
								}
						}
					$uri = '/fpgs/'+$Query
					$Result = Invoke-A9API -uri $uri -type 'GET' 		
					If($Result.StatusCode -eq 200)
						{	$dataPS = ($Result.content | ConvertFrom-Json).members				
						}
				}
			else
				{	$uri = '/fpgs/'+$FPG
					$Result = Invoke-A9API -uri $uri -type 'GET' 		
					If($Result.StatusCode -eq 200)
						{	$dataPS = $Result.content | ConvertFrom-Json				
						}		
				}				
		}
	else
		{	$Result = Invoke-A9API -uri '/fpgs' -type 'GET' 
			If($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members			
				}		
		}
	If($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure : While Executing Get-FPG_WSAPI. Expected Result Not Found with Given Filter Option." 
					return 
				}
		}
	else
		{	Write-Error "Failure : While Executing Get-FPG_WSAPI. " 
			return $Result.StatusDescription
		}
}

}

Function Get-A9FPGReclamationTasks 
{
<#
.SYNOPSIS
	Get the reclamation tasks for the FPG.
.DESCRIPTION
	Get the reclamation tasks for the FPG.
.EXAMPLE
    PS:> Get-A9FPGReclamationTasks

	Get the reclamation tasks for the FPG.
#>
[CmdletBinding()]
Param()
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process
{	$Result = Invoke-A9API -uri '/fpgs/reclaimtasks' -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure : While Executing Get-FPGReclamationTasks_WSAPI." 
					return 
				}
		}
	else
		{	Write-Error "Failure : While Executing Get-FPGReclamationTasks_WSAPI. " 
			return $Result.StatusDescription
		}
}  
}

Function New-A9VFS 
{
<#      
.SYNOPSIS	
	Create Virtual File Servers.
.DESCRIPTION	
    Create Virtual File Servers.
.PARAMETER VFSName
	Name of the VFS to be created.
.PARAMETER PolicyId
	Policy ID associated with the network configuration.
.PARAMETER FPG_IPInfo
	FPG to which VFS belongs.
.PARAMETER VFS
	VFS where the network is configured.
.PARAMETER IPAddr
	IP address.
.PARAMETER Netmask
	Subnet mask.
.PARAMETER NetworkName
	Network configuration name.
.PARAMETER VlanTag
	VFS network configuration VLAN ID.
.PARAMETER CPG
	CPG in which to create the FPG.
.PARAMETER FPG
	Name of an existing FPG in which to create the VFS.
.PARAMETER SizeTiB
	Specifies the size of the FPG you want to create. Required when using the cpg option.
.PARAMETER TDVV
	Enables (true) or disables false creation of the FPG with tdvv volumes. Defaults to false which creates the FPG with the default volume type (tpvv).
.PARAMETER FPVV
	Enables (true) or disables false creation of the FPG with fpvv volumes. Defaults to false which creates the FPG with the default volume type (tpvv).
.PARAMETER NodeId
	Node ID to which to assign the FPG. Always use with cpg member.
.PARAMETER Comment
	Specifies any additional comments while creating the VFS.
.PARAMETER BlockGraceTimeSec
	Block grace time in seconds for quotas within the VFS.
.PARAMETER InodeGraceTimeSec
	The inode grace time in seconds for quotas within the VFS.
.PARAMETER NoCertificate
	true – Does not create a selfsigned certificate associated with the VFS. false – (default) Creates a selfsigned certificate associated with the VFS.
.PARAMETER SnapshotQuotaEnabled
	Enables (true) or disables (false) the quota accounting flag for snapshots at VFS level.
.EXAMPLE	
	PS:> New-A9VFS
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VFSName,
	[Parameter(ValueFromPipeline=$true)]					[String]	$PolicyId,
    [Parameter(ValueFromPipeline=$true)]					[String]	$FPG_IPInfo,
    [Parameter(ValueFromPipeline=$true)]					[String]	$VFS,
	[Parameter(ValueFromPipeline=$true)]					[String]	$IPAddr,
	[Parameter(ValueFromPipeline=$true)]					[String]	$Netmask,
	[Parameter(ValueFromPipeline=$true)]					[String]	$NetworkName,
	[Parameter(ValueFromPipeline=$true)]					[int]		$VlanTag,
	[Parameter(ValueFromPipeline=$true)]					[String]	$CPG,
	[Parameter(ValueFromPipeline=$true)]					[String]	$FPG,
	[Parameter(ValueFromPipeline=$true)]					[int]		$SizeTiB,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$TDVV,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$FPVV,
	[Parameter(ValueFromPipeline=$true)]					[int]		$NodeId, 
	[Parameter(ValueFromPipeline=$true)]					[String]	$Comment,
	[Parameter(ValueFromPipeline=$true)]					[int]		$BlockGraceTimeSec,
	[Parameter(ValueFromPipeline=$true)]					[int]		$InodeGraceTimeSec,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$NoCertificate,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$SnapshotQuotaEnabled
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}
	$IPInfoBody=@{}
	If($VFSName) 		{	$body["name"] 			= "$($VFSName)"		}
	If($PolicyId) 		{	$IPInfoBody["policyId"] = "$($PolicyId)"	}
	If($FPG_IPInfo) 	{	$IPInfoBody["fpg"] 		= "$($FPG_IPInfo)"  }
	If($VFS) 			{	$IPInfoBody["vfs"] 		= "$($VFS)"    		}
	If($IPAddr) 		{	$IPInfoBody["IPAddr"] 	= "$($IPAddr)"    	}
	If($Netmask) 		{	$IPInfoBody["netmask"] 	= $Netmask    		}
	If($NetworkName) 	{	$IPInfoBody["networkName"] = "$($NetworkName)"}
	If($VlanTag) 		{	$IPInfoBody["vlanTag"] 	= $VlanTag    		}
	If($CPG) 			{	$body["cpg"] 			= "$($CPG)"     	}
	If($FPG) 			{	$body["fpg"] 			= "$($FPG)"     	}
	If($SizeTiB) 		{	$body["sizeTiB"] 		= $SizeTiB    		}
	If($TDVV) 			{	$body["tdvv"] 			= $true 			}
	If($FPVV) 			{	$body["fpvv"] 			= $true    			}
	If($NodeId) 		{	$body["nodeId"] 		= $NodeId   	 	}
	If($Comment) 		{	$body["comment"] 		= "$($Comment)"    	}
	If($BlockGraceTimeSec) {	$body["blockGraceTimeSec"] = $BlockGraceTimeSec    }
	If($InodeGraceTimeSec) {	$body["inodeGraceTimeSec"] = $InodeGraceTimeSec    }
	If($NoCertificate) 	{	$body["noCertificate"] 	= $true				}
	If($SnapshotQuotaEnabled) {	$body["snapshotQuotaEnabled"] = $true   }
	if($IPInfoBody.Count -gt 0) {	$body["IPInfo"] = $IPInfoBody 		}
    $Result = $null
    $Result = Invoke-A9API -uri '/virtualfileservers/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 202)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Creating Virtual File Servers VFS Name : $VFSName." 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9VFS 
{
<#      
.SYNOPSIS	
	Removing a Virtual File Servers.
.DESCRIPTION	
    Removing a Virtual File Servers.
.EXAMPLE	
	PS:> Remove-A9VFS -VFSID 1
.PARAMETER VFSID
	Virtual File Servers id.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]		[int]	$VFSID
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$uri = "/virtualfileservers/"+$VFSID
    $Result = Invoke-A9API -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Dismissing a Virtual File Servers : $VFSID " 
			return $Result.StatusDescription
		}
}
}

Function Get-A9VFS 
{
<#
.SYNOPSIS	
	Get all or single Virtual File Servers
.DESCRIPTION
	Get all or single Virtual File Servers
.PARAMETER VFSID	
    Virtual File Servers id.
.PARAMETER VFSName	
    Virtual File Servers Name.
.PARAMETER FPGName	
    File Provisioning Groups Name.
.EXAMPLE
	PS:> Get-A9VFS

	Get List Virtual File Servers
.EXAMPLE
	PS:> Get-A9VFS -VFSID xxx
	
	Get Single Virtual File Servers
#>
[CmdletBinding(DefaultParameterSetName='None')]
Param(
	[Parameter(ParameterSetName='ById', ValueFromPipeline=$true)]		[int]		$VFSID,
	[Parameter(ParameterSetName='ByOther', ValueFromPipeline=$true)]	[String]	$VFSName,
	[Parameter(ParameterSetName='ByOther', ValueFromPipeline=$true)]	[String]	$FPGName
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$dataPS = $null	
	$flg = "Yes"	
	$Query="?query=""  """
	if($VFSID)
		{	$uri = '/virtualfileservers/'+$VFSID
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}		
		}	
	elseif($VFSName)
		{	$Query = $Query.Insert($Query.Length-3," name EQ $VFSName")			
			if($FPGName)
				{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
					$flg = "No"
				}
			$uri = '/virtualfileservers/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}
	elseif($FPGName)
		{	if($flg -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPGName")
				}
			$uri = '/virtualfileservers/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}		
		}
	else
		{	$Result = Invoke-A9API -uri '/virtualfileservers' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}	
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	write-verbose "No data Found." 
					return 
				}
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	Write-Error "Failure : While Executing Get-VFS_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function New-A9FileStore 
{
<#      
.SYNOPSIS	
	Create File Store.
.DESCRIPTION	
    Create Create File Store.
.PARAMETER FSName
	Name of the File Store you want to create (max 255 characters).
.PARAMETER VFS
	Name of the VFS under which to create the File Store. If it does not exist, the system creates it.
.PARAMETER FPG
	Name of the FPG in which to create the File Store.
.PARAMETER NTFS
	File Store security mode is NTFS.
.PARAMETER LEGACY
	File Store security mode is legacy.
.PARAMETER SupressSecOpErr 
	Enables or disables the security operations error suppression for File Stores in NTFS security mode. Defaults to false. Cannot be used in LEGACY security mode.
.PARAMETER Comment
	Specifies any additional information about the File Store.
.EXAMPLE	
	PS:> New-A9FileStore
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$FSName,
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VFS,
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$FPG,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$SecurityMode,
	[Parameter(ValueFromPipeline=$true)]					[Switch]	$SupressSecOpErr,
	[Parameter(ValueFromPipeline=$true)]					[String]	$Comment
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}	
	If($FSName) 					{	$body["name"] = "$($FSName)"	}
	If($VFS) 						{	$body["vfs"] = "$($VFS)"   }
	If($FPG) 						{	$body["fpg"] = "$($FPG)"     }
	if($SecurityMode -eq 'LEGACY')	{	$body["securityMode"] = 2	}
	if($SecurityMode -eq 'NTFS')	{	$body["securityMode"] = 1	}
	If($SupressSecOpErr)			{	$body["supressSecOpErr"] = $true    }
	If($Comment) 					{	$body["comment"] = "$($Comment)"    }
    $Result = $null
    $Result = Invoke-A9API -uri '/filestores/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Creating File Store, Name: $FSName." 
			return $Result.StatusDescription
		}
}
}

Function Update-A9FileStore
{
<#      
.SYNOPSIS	
	Update File Store.
.DESCRIPTION	
    Updating File Store.
.PARAMETER FStoreID
	File Stores ID.
.PARAMETER SecurityMode
	File Store security mode is NTFS or LEGACY.
.PARAMETER LEGACY
	File Store security mode is legacy.
.PARAMETER SupressSecOpErr 
	Enables or disables the security operations error suppression for File Stores in NTFS security mode. Defaults to false. Cannot be used in LEGACY security mode.
.PARAMETER Comment
	Specifies any additional information about the File Store.
.EXAMPLE	
	PS:> Update-A9FileStore
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$FStoreID,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('NTFS','LEGACY')]							[Switch]	$SecurityMode,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$SupressSecOpErr
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}		
	If($Comment) 					{	$body["comment"] 		= "$($Comment)"	}
	If($SecurityMode -eq 'NTFS') 	{	$body["securityMode"] 	= 1				}
	If($SecurityMode -eq 'LEGACY')	{	$body["securityMode"] 	= 2				}
	If($SupressSecOpErr) 			{	$body["supressSecOpErr"]= $true    		}		
    $Result = $null
	$uri = '/filestores/'+$FStoreID
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Updating File Store, File Store ID: $FStoreID." 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9FileStore
{
<#      
.SYNOPSIS	
	Remove File Store.
.DESCRIPTION	
    Remove File Store.
.EXAMPLE	
	PS:> Remove-A9FileStore
.PARAMETER FStoreID
	File Stores ID.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$FStoreID
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$uri = '/filestores/'+$FStoreID
	$Result = Invoke-A9API -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Removing File Store, File Store ID: $FStoreID." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9FileStore 
{
<#
.SYNOPSIS	
	Get all or single File Stores.
.DESCRIPTION
	Get all or single File Stores.
.PARAMETER FStoreID
	File Stores ID.
.PARAMETER FileStoreName
	File Store Name.
.PARAMETER VFSName
	Virtual File Servers Name.
.PARAMETER FPGName
    File Provisioning Groups Name.	
.EXAMPLE
	PS:> Get-A9FileStore
	
	Get List of File Stores.
.EXAMPLE
	PS:> Get-A9FileStore -FStoreID xxx

	Get Single File Stores.
#>
[CmdletBinding(DefaultParameterSetName='None')]
Param(	[Parameter(ParameterSetName='ById',	ValueFromPipeline=$true)]		[int]		$FStoreID,
		[Parameter(ParameterSetName='ByOther',	ValueFromPipeline=$true)]	[String]	$FileStoreName,	  
		[Parameter(ParameterSetName='ByOther',ValueFromPipeline=$true)]		[String]	$VFSName,
		[Parameter(ParameterSetName='ByOther',ValueFromPipeline=$true)]		[String]	$FPGName
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$dataPS = $null	
	$flgVFS = "Yes"
	$flgFPG = "Yes"
	$Query="?query=""  """
	if($FStoreID)
		{	$uri = '/filestores/'+$FStoreID
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}
	elseif($FileStoreName)
		{	$Query = $Query.Insert($Query.Length-3," name EQ $FileStoreName")			
			if($VFSName)
				{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFSName")
					$flgVFS = "No"
				}
			if($FPGName)
				{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
					$flgFPG = "No"
				}
			$uri = '/filestores/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}	
	elseif($VFSName)
		{	if($flgVFS -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," vfs EQ $VFSName")
				}
			if($FPGName)
				{	if($flgFPG -eq "Yes")
						{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
							$flgFPG = "No"
						}
				}
			$uri = '/filestores/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}
	elseif($FPGName)
		{	if($flgFPG -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPGName")
					$flgFPG = "No"
				}
			$uri = '/filestores/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}		
		}
	else
		{	$Result = Invoke-A9API -uri '/filestores' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}			  
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	Write-Verbose "No data Found." 
					return 
				}
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	Write-Error "Failure : While Executing Get-FileStore_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function New-A9FileStoreSnapshot 
{
<#      
.SYNOPSIS	
	Create File Store snapshot.
.DESCRIPTION	
    Create Create File Store snapshot.
.PARAMETER TAG
	The suffix appended to the timestamp of a snapshot creation to form the snapshot name (<timestamp>_< tag>), using ISO8601 date and time format. Truncates tags in excess of 255 characters.
.PARAMETER FStore
	The name of the File Store for which you are creating a snapshot.
.PARAMETER VFS
	The name of the VFS to which the File Store belongs.
.PARAMETER RetainCount
	In the range of 1 to 1024, specifies the number of snapshots to retain for the File Store.
	Snapshots in excess of the count are deleted beginning with the oldest snapshot.
	If the tag for the specified retainCount exceeds the count value, the oldest snapshot is deleted before the new snapshot is created. 
	If the creation of the new snapshot fails, the deleted snapshot will not be restored.
.PARAMETER FPG
	The name of the FPG to which the VFS belongs.
.EXAMPLE	
	PS:> New-A9FileStoreSnapshot
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$TAG,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$FStore, 
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VFS,
		[Parameter(ValueFromPipeline=$true)]					[int]		$RetainCount,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$FPG
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}	
	If($TAG) 		{	$body["tag"] 	= "$($TAG)"    	}
	If($FStore) 	{	$body["fstore"] = "$($FStore)"	}
	If($VFS) 		{	$body["vfs"] 	= "$($VFS)"    	}
	If($RetainCount){	$body["retainCount"] = $RetainCount }
	If($FPG) 		{	$body["fpg"] 	= "$($FPG)"     }
    $Result = $null
    $Result = Invoke-A9API -uri '/filestoresnapshots/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Creating File Store snapshot." 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9FileStoreSnapshot 
{
<#      
.SYNOPSIS	
	Remove File Store snapshot.
.DESCRIPTION	
    Remove File Store snapshot.
.PARAMETER ID
	File Store snapshot ID.
.EXAMPLE	
	PS:> Remove-A9FileStoreSnapshot
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$ID
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$uri = '/filestoresnapshots/'+$ID
	$Result = Invoke-A9API -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Removing File Store snapshot, File Store snapshot ID: $ID." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9FileStoreSnapshot
{
<#
.SYNOPSIS	
	Get all or single File Stores snapshot.
.DESCRIPTION
	Get all or single File Stores snapshot.
.PARAMETER ID	
    File Store snapshot ID.
.PARAMETER FileStoreSnapshotName
	File Store snapshot name — exact match and pattern match.
.PARAMETER FileStoreName
	File Store name.
.PARAMETER VFSName
	The name of the VFS to which the File Store snapshot belongs.
.PARAMETER FPGName
	The name of the FPG to which the VFS belongs.
.EXAMPLE
	PS:> Get-A9FileStoreSnapshot

	Get List of File Stores snapshot.
.EXAMPLE
	PS:> Get-A9FileStoreSnapshot -ID xxx

	Get Single File Stores snapshot.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$ID,
		[Parameter(ValueFromPipeline=$true)]	[String] 	$FileStoreSnapshotName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$FileStoreName,	  
		[Parameter(ValueFromPipeline=$true)]	[String] 	$VFSName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$FPGName
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$dataPS = $null
	$flgFSN = "Yes"	
	$flgVFS = "Yes"
	$flgFPG = "Yes"
	$Query="?query=""  """	
	if($ID)
		{	if($FileStoreSnapshotName -Or $VFSName -Or $FPGName -Or $FileStoreName)
				{	Return "we cannot use FileStoreSnapshotName,VFSName,FileStoreName and FPGName with ID as FileStoreSnapshotName,VFSName,FileStoreName and FPGName is use for filtering."
				}
			$uri = '/filestoresnapshots/'+$ID
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}
	elseif($FileStoreSnapshotName)
		{	$Query = $Query.Insert($Query.Length-3," name EQ $FileStoreSnapshotName")			
			if($FileStoreName)
				{	$Query = $Query.Insert($Query.Length-3," AND fstore EQ $FileStoreName")
					$flgFSN = "No"
				}
			if($VFSName)
				{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFSName")
					$flgVFS = "No"
				}
			if($FPGName)
				{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
					$flgFPG = "No"
				}
			$uri = '/filestoresnapshots/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}	
	elseif($FileStoreName)
		{	if($flgFSN -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," fstore EQ $FileStoreName")	
				}		
			if($VFSName)
				{	if($flgVFS -eq "Yes")
						{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFSName")
							$flgVFS = "No"
						}
				}
			if($FPGName)
				{	if($flgFPG -eq "Yes")
						{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
							$flgFPG = "No"
						}
				}
			$uri = '/filestoresnapshots/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}	
	elseif($VFSName)
		{	if($flgVFS -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," vfs EQ $VFSName")
				}
			if($FPGName)
				{	if($flgFPG -eq "Yes")
						{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
							$flgFPG = "No"
						}
				}
			$uri = '/filestoresnapshots/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}
	elseif($FPGName)
		{	if($flgFPG -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPGName")
					$flgFPG = "No"
				}
			$uri = '/filestoresnapshots/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}		
		}	
	else
		{	$Result = Invoke-A9API -uri '/filestoresnapshots' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}	
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	write-verbose "No data Found." 
					return 
				}
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	Write-Error "Failure : While Executing Get-FileStoreSnapshot_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function New-A9FileShare 
{
<#      
.SYNOPSIS	
	Create File Share.
.DESCRIPTION	
    Create Create File Share.
.PARAMETER FSName	
	Name of the File Share you want to create.
.PARAMETER FSType
	File Share of type NFS or SMB.
.PARAMETER VFS
	Name of the VFS under which to create the File Share. If it does not exist, the system creates it.
.PARAMETER ShareDirectory
	Directory path to the File Share. Requires fstore.
.PARAMETER FStore
	Name of the File Store in which to create the File Share.
.PARAMETER FPG
	Name of FPG in which to create the File Share.
.PARAMETER Comment
	Specifies any additional information about the File Share.
.PARAMETER Enables_SSL
	Can be set to $true or $false to ether Enable or disable SSL. Valid for OBJ and FTP File Share types only.
.PARAMETER ObjurlPath
	URL that clients will use to access the share. Valid for OBJ File Share type only.
.PARAMETER NFSOptions
	Valid for NFS File Share type only. Specifies options to use when creating the share. Supports standard NFS export options except no_subtree_check.
	With no options specified, automatically sets the default options.
.PARAMETER NFSClientlist
	Valid for NFS File Share type only. Specifies the clients that can access the share.
	Specify the NFS client using any of the following:
	• Full name (sys1.hpe.com)
	• Name with a wildcard (*.hpe.com)
	• IP address (usea comma to separate IPaddresses)
	With no list specified, defaults to match everything.
.PARAMETER SmbABE
	Valid for SMB File Share only.
	Enables (true) or disables (false) Access Based Enumeration (ABE). ABE specifies that users can see only the files and directories to which they have been allowed access on the shares. 
	Defaults to false.
.PARAMETER SmbAllowedIPs
	List of client IP addresses that are allowed access to the share. Valid for SMB File Share type only.
.PARAMETER SmbDeniedIPs
	List of client IP addresses that are not allowed access to the share. Valid for SMB File Share type only.
.PARAMETER SmbContinuosAvailability
	Enables (true) or disables (false) SMB3 continuous availability features for the share. Defaults to true. Valid for SMB File Share type only. 
.PARAMETER SmbCache
	Specifies clientside caching for offline files.Valid for SMB File Share type only.
.PARAMETER FtpShareIPs
	Lists the IP addresses assigned to the FTP share. Valid only for FTP File Share type.
.PARAMETER FtpOptions
	Specifies the configuration options for the FTP share. Use the format:
.EXAMPLE	
	PS:> New-A9FileShare
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$FSName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateSet('SMB','NFS')]								[String]	$FSType,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VFS,
		[Parameter(ValueFromPipeline=$true)]					[String]	$ShareDirectory,
		[Parameter(ValueFromPipeline=$true)]					[String]	$FStore,
		[Parameter(ValueFromPipeline=$true)]					[String]	$FPG,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]					[Boolean]	$Enables_SSL,
		[Parameter(ValueFromPipeline=$true)]					[String]	$ObjurlPath,
		[Parameter(ValueFromPipeline=$true)]					[String]	$NFSOptions,
		[Parameter(ValueFromPipeline=$true)]					[String[]]	$NFSClientlist,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$SmbABE,
		[Parameter(ValueFromPipeline=$true)]					[String[]]	$SmbAllowedIPs,
		[Parameter(ValueFromPipeline=$true)]					[String[]]	$SmbDeniedIPs,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$SmbContinuosAvailability,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet("OFF","OPTIMIZED","MANUAL","AUTO")]		[String]	$SmbCache,
		[Parameter(ValueFromPipeline=$true)]					[String[]]	$FtpShareIPs,
		[Parameter(ValueFromPipeline=$true)]					[String]	$FtpOptions
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}	
	If($FSName) 	{	$body["name"] = "$($FSName)"    }
	if($FSType)		
		{	If($FSType -eq 'NFS') 		{	$body["type"] = 1    }
			elseIf($FSType -eq 'SMB') 	{	$body["type"] = 2    }
		}
	If($VFS) 		{	$body["vfs"] 				= "$($VFS)"    			}	
	If($ShareDirectory){$body["shareDirectory"] 	= "$($ShareDirectory)"  }
	If($FStore) 	{	$body["fstore"] 			= "$($FStore)"     		}
	If($FPG) 		{	$body["fpg"] 				= "$($FPG)"     		}
	If($Comment) 	{	$body["comment"] 			= "$($Comment)"    		}
	If($Enables_SSL) {	$body["ssl"] 				= $Enables_SSL    		}	
	If($ObjurlPath) {	$body["objurlPath"] 		= "$($ObjurlPath)"    	}
	If($NFSOptions) {	$body["nfsOptions"] 		= "$($NFSOptions)"    	}
	If($NFSClientlist){	$body["nfsClientlist"] 		= "$($NFSClientlist)"   }
	If($SmbABE) 	{	$body["smbABE"] 			= $true    				}
	If($SmbAllowedIPs){	$body["smbAllowedIPs"] 		= "$($SmbAllowedIPs)"	}
	If($SmbDeniedIPs) {	$body["smbDeniedIPs"] 		= "$($SmbDeniedIPs)"    }
	If($SmbContinuosAvailability) {	$body["smbContinuosAvailability"] = $true    }
	If($SmbCache) 
		{	if($SmbCache -Eq "OFF")			{	$body["smbCache"] = 1	}
			elseif($SmbCache -Eq "MANUAL")	{	$body["smbCache"] = 2	}
			elseif($SmbCache -Eq "OPTIMIZED"){	$body["smbCache"] = 3	}
			elseif($SmbCache -Eq "AUTO")	{	$body["smbCache"] = 4	}
			else							{}		
		}
	If($FtpShareIPs){	$body["ftpShareIPs"] = "$($FtpShareIPs)"}
	If($FtpOptions) {	$body["ftpOptions"] = "$($FtpOptions)"	}
    $Result = $null
    $Result = Invoke-A9API -uri '/fileshares/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Creating File Share, Name: $FSName." 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9FileShare 
{
<#      
.SYNOPSIS	
	Remove File Share.
.DESCRIPTION	
    Remove File Share.
.EXAMPLE	
	PS:> Remove-A9FileShare
.PARAMETER ID
	File Share ID contains the unique identifier of the File Share you want to remove.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$ID
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$uri = '/fileshares/'+$ID
    $Result = Invoke-A9API -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Removing File Share, File Share ID: $ID." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9FileShare 
{
<#
.SYNOPSIS	
	Get all or single File Shares.
.DESCRIPTION
	Get all or single File Shares.
.EXAMPLE
	PS:> Get-A9FileShare

	Get List of File Shares.
.EXAMPLE
	PS:> Get-A9FileShare -ID xxx

	Get Single File Shares.
.PARAMETER ID	
    File Share ID contains the unique identifier of the File Share you want to Query.
.PARAMETER FSName
	File Share name.
.PARAMETER FSType
	File Share type, ie, smb/nfs/obj
.PARAMETER VFS
	Name of the Virtual File Servers.
.PARAMETER FPG
	Name of the File Provisioning Groups.
.PARAMETER FStore
	Name of the File Stores.
#>
[CmdletBinding(DefaultParameterSetName='None')]
Param(	[Parameter(ParameterSetName='ByID', ValueFromPipeline=$true)]		[int]		$ID,
		[Parameter(ParameterSetName='ByOther',ValueFromPipeline=$true)]	[String]	$FSName,
		[Parameter(ParameterSetName='ByOther',ValueFromPipeline=$true)]
									[ValidateSet("SMB','NFS','OBJ'")]		[String]	$FSType,
		[Parameter(ParameterSetName='ByOther',ValueFromPipeline=$true)]		[String]	$VFS,
		[Parameter(ParameterSetName='ByOther',ValueFromPipeline=$true)]		[String]	$FPG,
		[Parameter(ParameterSetName='ByOther',ValueFromPipeline=$true)]	[String]	$FStore
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	$flg = "NO"
	if($ID)
		{	$uri = '/fileshares/'+$ID
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}
	elseif($FSName -Or $FSType -Or $VFS -Or $FPG -Or $FStore)	
		{	if($FSName)
				{	$Query = $Query.Insert($Query.Length-3," name EQ $FSName")			
					$flg = "YES"
				}
			if($FSType)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," type EQ $FSType")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND type EQ $FSType")	}
					$flg = "YES"
				}
			if($VFS)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," vfs EQ $VFS")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFS")	}
					$flg = "YES"
				}
			if($FPG)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPG")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPG")	}
					$flg = "YES"
				}
			if($FStore)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," fstore EQ $FStore")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND fstore EQ $FStore")	}
					$flg = "YES"
				}
			$uri = '/fileshares/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}
	else 
		{	$Result = Invoke-A9API -uri '/fileshares' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}	
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	write-verbose "No data Found."
					return 
				}
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	Write-Error "Failure : While Executing Get-FileShare_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9DirPermission 
{
<#
.SYNOPSIS	
	Get directory permission properties.
.DESCRIPTION
	Get directory permission properties.
.EXAMPLE
	PS:> Get-DirPermission -ID 12
.PARAMETER ID	
    File Share ID contains the unique identifier of the File Share you want to Query.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[int]	$ID
	)

Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$dataPS = $null	
	$uri = '/fileshares/'+$ID+'/dirperms'
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
		}
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
					{	write-verbose "No data Found."
						return 
					}
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	Write-Error "Failure : While Executing Get-DirPermission_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function New-A9FilePersonaQuota 
{
<#      
.SYNOPSIS	
	Create File Persona quota.
.DESCRIPTION	
    Create File Persona quota.
.EXAMPLE	
	PS:> New-A9FilePersonaQuota
.PARAMETER Name
	The name of the object that the File Persona quotas to be created for.
.PARAMETER Type
	The type of File Persona quota to be created.
	1) user    :user quota type.
	2) group   :group quota type.
	3) fstore  :fstore quota type.
.PARAMETER VFS
	VFS name associated with the File Persona quota.
.PARAMETER FPG
	Name of the FPG hosting the VFS.
.PARAMETER SoftBlockMiB
	Soft capacity storage quota.
.PARAMETER HardBlockMiB
	Hard capacity storage quota.
.PARAMETER SoftFileLimit
	Specifies the soft limit for the number of stored files.
.PARAMETER HardFileLimit
	Specifies the hard limit for the number of stored files.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$Name,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateSet("user","group","fstore")]					[String]	$Type,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VFS,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$FPG,
		[Parameter(ValueFromPipeline=$true)]					[int]		$SoftBlockMiB,	
		[Parameter(ValueFromPipeline=$true)]					[int]		$HardBlockMiB,
		[Parameter(ValueFromPipeline=$true)]					[int]		$SoftFileLimit,
		[Parameter(ValueFromPipeline=$true)]					[int]		$HardFileLimit
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}	
	If($Name) 		{	$body["name"] = "$($Name)"	}
	if($Type)	
		{	if($Type -eq "user")	{	$body["type"] = 1	}
			if($Type -eq "group")	{	$body["type"] = 2	}
			if($Type -eq "fstore")	{	$body["type"] = 3	}						
		}
	If($VFS) 			{	$body["vfs"] = "$($VFS)"   }
	If($FPG) 			{	$body["fpg"] = "$($FPG)"     }
	If($SoftBlockMiB) 	{	$body["softBlockMiB"] = $SoftBlockMiB    }
	If($HardBlockMiB) 	{	$body["hardBlockMiB"] = $HardBlockMiB    }
	If($SoftFileLimit) 	{	$body["softFileLimit"] = $SoftFileLimit}
	If($HardFileLimit) 	{	$body["hardFileLimit"] = $HardFileLimit	}
    $Result = $null
    $Result = Invoke-A9API -uri '/filepersonaquotas/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Creating File Persona quota." 
			return $Result.StatusDescription
		}
}
}

Function Update-A9FilePersonaQuota
{
<#      
.SYNOPSIS	
	Update File Persona quota information.
.DESCRIPTION	
    Updating File Persona quota information.
.EXAMPLE	
	PS:> Update-A9FilePersonaQuota
.PARAMETER ID
	The <id> variable contains the unique ID of the File Persona you want to modify.
.PARAMETER SoftFileLimit
	Specifies the soft limit for the number of stored files.
.PARAMETER RMSoftFileLimit
	Resets softFileLimit:
	• true —resets to 0
	• false — ignored if false and softFileLimit is set to 0. Set to limit if false and softFileLimit is a positive value.
.PARAMETER HardFileLimit
	Specifies the hard limit for the number of stored files.
.PARAMETER RMHardFileLimit
	Resets hardFileLimit:
	• true —resets to 0 
	• If false , and hardFileLimit is set to 0, ignores. 
	• If false , and hardFileLimit is a positive value, then set to that limit.	
.PARAMETER SoftBlockMiB
	Soft capacity storage quota.
.PARAMETER RMSoftBlockMiB
	Resets softBlockMiB: 
	• true —resets to 0 
	• If false , and softBlockMiB is set to 0, ignores.
	• If false , and softBlockMiB is a positive value, then set to that limit.
.PARAMETER HardBlockMiB
	Hard capacity storage quota.
.PARAMETER RMHardBlockMiB
	Resets hardBlockMiB: 
	• true —resets to 0 
	• If false , and hardBlockMiB is set to 0, ignores.
	• If false , and hardBlockMiB is a positive value, then set to that limit.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$ID,
		[Parameter(ValueFromPipeline=$true)]	[Int]	$SoftFileLimit,
		[Parameter(ValueFromPipeline=$true)]	[Int]	$RMSoftFileLimit,	
		[Parameter(ValueFromPipeline=$true)]	[Int]	$HardFileLimit,
		[Parameter(ValueFromPipeline=$true)]	[Int]	$RMHardFileLimit,
		[Parameter(ValueFromPipeline=$true)]	[Int]	$SoftBlockMiB,
		[Parameter(ValueFromPipeline=$true)]	[Int]	$RMSoftBlockMiB,
		[Parameter(ValueFromPipeline=$true)]	[Int]	$HardBlockMiB,
		[Parameter(ValueFromPipeline=$true)]	[Int]	$RMHardBlockMiB
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}
		
	If($SoftFileLimit) 	{	$body["softFileLimit"] = $SoftFileLimit     }	
	If($RMSoftFileLimit) {	$body["rmSoftFileLimit"] = $RMSoftFileLimit    }
	If($HardFileLimit) {	$body["hardFileLimit"] = $HardFileLimit     }
	If($RMHardFileLimit) {	$body["rmHardFileLimit"] = $RMHardFileLimit    }
	If($SoftBlockMiB) 	{	$body["softBlockMiB"] = $SoftBlockMiB     }
	If($RMSoftBlockMiB) {	$body["rmSoftBlockMiB"] = $RMSoftBlockMiB     }
	If($HardBlockMiB) 	{	$body["hardBlockMiB"] = $HardBlockMiB }	
	If($RMHardBlockMiB) {	$body["rmHardBlockMiB"] = $RMHardBlockMiB     }
    $Result = $null
	$uri = '/filepersonaquotas/'+$ID
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Updating File Persona quota information, ID: $ID." 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9FilePersonaQuota
{
<#      
.SYNOPSIS	
	Remove File Persona quota.
.DESCRIPTION	
    Remove File Persona quota.
.EXAMPLE	
	ps:> Remove-A9FilePersonaQuota
.PARAMETER ID
	The <id> variable contains the unique ID of the File Persona you want to Remove.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$ID
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$uri = '/filepersonaquotas/'+$ID
	$Result = Invoke-A9API -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Removing File Persona quota, File Persona quota ID: $ID." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9FilePersonaQuota
{
<#
.SYNOPSIS	
	Get all or single File Persona quota.
.DESCRIPTION
	Get all or single File Persona quota.
.EXAMPLE
	PS:> Get-A9FilePersonaQuota

	Get List of File Persona quota.
.EXAMPLE
	PS:> Get-A9FilePersonaQuota -ID xxx

	Get Single File Persona quota.
.PARAMETER ID	
    The <id> variable contains the unique ID of the File Persona.
.PARAMETER Name
	user, group, or fstore name.
.PARAMETER Key
	user, group, or fstore id.
.PARAMETER QType
	Quota type.
.PARAMETER VFS
	Virtual File Servers name.
.PARAMETER FPG
	File Provisioning Groups name.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[int]		$ID,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Name,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Key,
		[Parameter(ValueFromPipeline=$true)]	[String]	$QType,
		[Parameter(ValueFromPipeline=$true)]	[String]	$VFS,
		[Parameter(ValueFromPipeline=$true)]	[String]	$FPG
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$dataPS = $null
	$Query="?query=""  """
	$flg = "NO"	
	if($ID)
		{	$uri = '/filepersonaquota/'+$ID
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}
	elseif($Name -Or $Key -Or $QType -Or $VFS -Or $FPG)
		{	if($Name)
				{	$Query = $Query.Insert($Query.Length-3," name EQ $Name")			
					$flg = "YES"
				}
			if($Key)
				{	if($flg -eq "NO")
						{	$Query = $Query.Insert($Query.Length-3," key EQ $Key")
						}
					else
						{	$Query = $Query.Insert($Query.Length-3," AND key EQ $Key")
						}
					$flg = "YES"
				}
			if($QType)
				{	if($flg -eq "NO")
						{	$Query = $Query.Insert($Query.Length-3," type EQ $QType")
						}
					else
						{	$Query = $Query.Insert($Query.Length-3," AND type EQ $QType")
						}
					$flg = "YES"
				}
			if($VFS)
				{	if($flg -eq "NO")
						{	$Query = $Query.Insert($Query.Length-3," vfs EQ $VFS")
						}
					else
						{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFS")
						}
					$flg = "YES"
				}
			if($FPG)
				{	if($flg -eq "NO")
						{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPG")
						}
					else
						{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPG")
						}
					$flg = "YES"
				}
			$uri = '/filepersonaquota/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}	
	else
		{	$Result = Invoke-A9API -uri '/filepersonaquota' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}	
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	write-verbose "No data Found." 
					return 
				}
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	Write-Error "Failure : While Executing Get-FilePersonaQuota_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Restore-A9FilePersonaQuota 
{
<#      
.SYNOPSIS	
	Restore a File Persona quota.
.DESCRIPTION	
    Restore a File Persona quota.
.EXAMPLE	
	PS:> Restore-A9FilePersonaQuota
.PARAMETER VFSUUID
	VFS UUID.
.PARAMETER ArchivedPath
	The path to the archived file from which the file persona quotas are to be restored.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VFSUUID,
		[Parameter(ValueFromPipeline=$true)]					[String]	$ArchivedPath
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}
	$body["action"] = 2 
	If($VFSUUID) 		{	$body["vfsUUID"] = "$($VFSUUID)"	}	
	If($ArchivedPath) 	{	$body["archivedPath"] = "$($ArchivedPath)"	}
    $Result = $null
    $Result = Invoke-A9API -uri '/filepersonaquotas/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	Write-Error "Failure : While Restoring a File Persona quota, VFSUUID: $VFSUUID." 
			return $Result.StatusDescription
		}
}
}

Function Group-A9FilePersonaQuota 
{
<#      
.SYNOPSIS	
	Archive a File Persona quota.	
.DESCRIPTION	
    Archive a File Persona quota.
.EXAMPLE	
	PS:> Group-A9FilePersonaQuota
.PARAMETER QuotaArchiveParameter
	VFS UUID.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$QuotaArchiveParameter
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}
	$body["action"] = 1 
	If($QuotaArchiveParameter) 
		{	$body["quotaArchiveParameter"] = "$($QuotaArchiveParameter)"
		}
    $Result = $null
    $Result = Invoke-A9API -uri '/filepersonaquotas/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else
		{	Write-Error "Failure : While Restoring a File Persona quota, VFSUUID: $VFSUUID." 
			return $Result.StatusDescription
		}
}
}

# SIG # Begin signature block
# MIIt2QYJKoZIhvcNAQcCoIItyjCCLcYCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAvOAx10vzu
# ElKOooYffBm57GyJW1f59YEmrPOVW3LyYiJCD5H/FiXeuBeHMsAOa9HC2z0tnP+c
# Ja4vsN4Rv/wUoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQB6EXT7PdNWGCRWcfB/GBzXHQRQ7hymJeTpLdGfPl2jGwp8ElKlkXozm
# vcZjYNweAiBPtu7vYlMX11xsb9M/KP8wDQYJKoZIhvcNAQEBBQAEggGAiLDYsJNc
# ir3nfJI0gksqMHR+bGcpI4341NeOqNOpiLbH8Joe9lX8Fk9Brj/56fW5vsAZWjEV
# XqLhJLUpBwNSTDg1O2aydCL9ncrgpywQQmTyzPfi7TFuAE8HtqKiUeCdNAZ9we9o
# B2cIxnp+vcvOdY1LsSqysgv4hc6CNjmGH+rkuUykKUbtSkL7m0oMUZYrtddvR6pn
# Q2V8G5X+EpygCveAe1huqQ42cHDZfU0nDDzCFeeGnvxN9JIlsIS7xGJWAiFpHkfM
# MyRU0/bADYwCh5lB7XCaup59eCO1rqXjmqCKoGvKHQjuL4Ev/J3vQgtXN3yqVPHP
# Gv4cbWkTLgbgeCy34nGN9w140O3vgiNEKBk5PpeSuPCJCW29kYtlzX1IMCI0FQ55
# QLaTD4KP8zlcEPKz2ECj3BUvpc0zbGcvb1Mkw+EWs3xSYIBqLKEEfc+hLPit/5S5
# v3FOnjEsfPlw+QR3hA5kswUfZwXXbi55MgdOFXVpQHq8/v8gSQf6iUQWoYIY3zCC
# GNsGCisGAQQBgjcDAwExghjLMIIYxwYJKoZIhvcNAQcCoIIYuDCCGLQCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQQGCyqGSIb3DQEJEAEEoIH0BIHxMIHuAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMP76AWyvDmqxzdhwVPyqKJys4StgT6Jk
# d13I/cpN/Gdda/0LQxZVRP4Ajf/9jJENNgIVAPYnQuCb0qSn3PBj73BgQm4dDyAz
# GA8yMDI0MDczMTIwMTg0M1qgcqRwMG4xCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpN
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
# MDczMTIwMTg0M1owPwYJKoZIhvcNAQkEMTIEMCgZgBodUg3fzMTSfWqOOR09qZYa
# 9gqQcjOZzOMFmncYFczslxMHFPmaAidSx27FrDCCAXoGCyqGSIb3DQEJEAIMMYIB
# aTCCAWUwggFhMBYEFPhgmBmm+4gs9+hSl/KhGVIaFndfMIGHBBTGrlTkeIbxfD1V
# EkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KCYXzQkDXEkd6S
# wULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJz
# ZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNU
# IE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEBBQAEggIAbc+m
# v3H6+r2VLHJBiBzgvKNkyhpCV1rECiTJzjN36iWydbCH0WDPxoib7P0eQbk4fXpx
# s5Sq+EQ21qTbDtjLfenMnI1WMg1rndbJXcxCjblI/c+auT+H73UYZyhpXhgf2kV0
# 8r5byz3fhwlVRjzC19ArUF726iOwS4xG79vEeZsrp51uH/i+39ebfm13mHU2eww3
# qkH96Fap5jc4cGvTkKE8D6I9HkmW6TcPBHW9yeFUOc6VyvWxfTkP4sEUgpK251D+
# kBTfy5foWNhGvj2yMqPUot+dg0g3f6ibm5ro/+Bj4+Mp5jHvyQ5A43C9P/E3KsWG
# uvbanWvVhYKp0W18VUSwLmiXpffyx8Se68j5cgaOFYR5cKrujDo1wjyAVSqtLJEP
# k1S9Age6i/2ZWZfhYIoN3yZKyMFCmnlP4FTTOpXDUnlMKmR9VVlsTh7+JdYUYGtl
# mUxBMDC9fU7+wC2kYoJsPre/lfKFMuEiK8y3FYqLKlHFvEiwSTogZz3Mj2ilXIIF
# +hysmy9bv6JwEgXmLZYgK4ncfhkrOs4k9u3nHI5+/CtYFBuwpWjiWix/QFC11Glc
# fJVzL5XiyjTJqT8s3ROLSP9FD4VctR0V87FomZPCh1t2eU7UtetOBGXVS6WMETre
# TmukDpJ7fG27cUIZky546adlnJSTidyJXR171KQ=
# SIG # End signature block
