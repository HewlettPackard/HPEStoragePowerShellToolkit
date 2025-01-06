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
