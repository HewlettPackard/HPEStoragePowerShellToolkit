####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function New-A9Cpg 
{
<#
.SYNOPSIS
	The New-A9Cpg command creates a Common Provisioning Group (CPG).
.DESCRIPTION
	The New-A9Cpg command creates a Common Provisioning Group (CPG).
.PARAMETER CPGName
	Specifies the name of the CPG.  
.PARAMETER Domain
	Specifies the name of the domain in which the object will reside.  
.PARAMETER Template
	Specifies the name of the template from which the CPG is created.
.PARAMETER GrowthIncrementMiB
	Specifies the growth increment, in MiB, the amount of logical disk storage created on each auto-grow operation.  
.PARAMETER GrowthLimitMiB
	Specifies that the autogrow operation is limited to the specified storage amount, in MiB, that sets the growth limit.
.PARAMETER UsedLDWarningAlertMiB
	Specifies that the threshold of used logical disk space, in MiB, when exceeded results in a warning alert.
.PARAMETER RAIDType
	RAID type for the logical disk
	R0 RAID level 0
	R1 RAID level 1
	R5 RAID level 5
	R6 RAID level 6
.PARAMETER SetSize
	Specifies the set size in the number of chunklets.
.PARAMETER HA
	Specifies that the layout must support the failure of one port pair, one cage, or one magazine.
	PORT Support failure of a port.
	CAGE Support failure of a drive cage.
	MAG Support failure of a drive magazine.
.PARAMETER Chunklets
	FIRST Lowest numbered available chunklets, where transfer rate is the fastest.
	LAST  Highest numbered available chunklets, where transfer rate is the slowest.
.PARAMETER NodeList
	Specifies one or more nodes. Nodes are identified by one or more integers. Multiple nodes are separated with a single comma (1,2,3). 
	A range of nodes is separated with a hyphen (0–7). The primary path of the disks must be on the specified node number.
.PARAMETER SlotList
	Specifies one or more PCI slots. Slots are identified by one or more integers. Multiple slots are separated with a single comma (1,2,3). 
	A range of slots is separated with a hyphen (0–7). The primary path of the disks must be on the specified PCI slot number(s).
.PARAMETER PortList
	Specifies one or more ports. Ports are identified by one or more integers. Multiple ports are separated with a single comma (1,2,3). 
	A range of ports is separated with a hyphen (0–4). The primary path of the disks must be on the specified port number(s).
.PARAMETER CageList
	Specifies one or more drive cages. Drive cages are identified by one or more integers. Multiple drive cages are separated with a single comma (1,2,3). 
	A range of drive cages is separated with a hyphen (0– 3). The specified drive cage(s) must contain disks.
.PARAMETER MagList 
	Specifies one or more drive magazines. Drive magazines are identified by one or more integers. Multiple drive magazines are separated with a single comma (1,2,3). 
	A range of drive magazines is separated with a hyphen (0–7). The specified magazine(s) must contain disks.  
.PARAMETER DiskPosList
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers. Multiple disk positions are separated with a single comma (1,2,3). 
	A range of disk positions is separated with a hyphen (0–3). The specified portion(s) must contain disks.
.PARAMETER DiskList
	Specifies one or more physical disks. Disks are identified by one or more integers. Multiple disks are separated with a single comma (1,2,3). 
	A range of disks is separated with a hyphen (0–3). Disks must match the specified ID(s). 
.PARAMETER TotalChunkletsGreaterThan
	Specifies that physical disks with total chunklets greater than the number specified be selected.  
.PARAMETER TotalChunkletsLessThan
	Specifies that physical disks with total chunklets less than the number specified be selected. 
.PARAMETER FreeChunkletsGreaterThan
	Specifies that physical disks with free chunklets less than the number specified be selected.  
.PARAMETER FreeChunkletsLessThan
	Specifies that physical disks with free chunklets greater than the number specified be selected. 
.PARAMETER DiskType
	Specifies that physical disks must have the specified device type, which can only be FC (Fibre Channel), NL (NearLine), or SSD (SSD).
.PARAMETER Rpm
	Disks must be of the specified speed.
.EXAMPLE    
	PS:> New-A9Cpg -CPGName XYZ 
.EXAMPLE	
	PS:> New-A9Cpg -CPGName "MyCPG" -Domain Chef_Test
.EXAMPLE	
	PS:> New-A9Cpg -CPGName "MyCPG" -Domain Chef_Test -Template Test_Temp
.EXAMPLE	
	PS:> New-A9Cpg -CPGName "MyCPG" -Domain Chef_Test -Template Test_Temp -GrowthIncrementMiB 100
.EXAMPLE	
	PS:> New-A9Cpg -CPGName "MyCPG" -Domain Chef_Test -RAIDType R0
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory = $true)]
						[String]	$CPGName,
	[Parameter()]		[String]	$Domain,
	[Parameter()]		[String]	$Template,
	[Parameter()]		[Int]		$GrowthIncrementMiB,
	[Parameter()]    	[int]		$GrowthLimitMiB,
	[Parameter()]    	[int]		$UsedLDWarningAlertMiB,
	[Parameter()][ValidateSet('R0','R1','R5','R6')]   
						[string]	$RAIDType, 
	[Parameter()]    	[int]		$SetSize,
    [Parameter()][ValidateSet('PORT','CAGE','MAG')]    
						[string]	$HA,
	[Parameter()][ValidateSet('FIRST','LAST')]    
						[string]	$Chunklets,
	[Parameter()]		[String]	$NodeList,
	[Parameter()]		[String]	$SlotList,
	[Parameter()]   	[String]	$PortList,
	[Parameter()]    	[String]	$CageList,
	[Parameter()]    	[String]	$MagList,
	[Parameter()]    	[String]	$DiskPosList,
	[Parameter()]    	[String] 	$DiskList,
	[Parameter()]    	[int]		$TotalChunkletsGreaterThan,
	[Parameter()]    	[int]		$TotalChunkletsLessThan,
	[Parameter()]		[int]		$FreeChunkletsGreaterThan,
	[Parameter()]    	[int]		$FreeChunkletsLessThan,
	[Parameter()][ValidateSet('FC','NL','SSD')]	
						[string]	$DiskType,
	[Parameter()]		[int]		$Rpm
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$body["name"] = "$($CPGName)"
	If ($Domain) 			{	$body["domain"] = "$($Domain)"	}
    If ($Template)			{	$body["template"] = "$($Template)"	} 
    If ($GrowthIncrementMiB){	$body["growthIncrementMiB"] = $GrowthIncrementMiB	} 
    If ($GrowthLimitMiB)    {	$body["growthLimitMiB"] = $GrowthLimitMiB    } 
    If ($UsedLDWarningAlertMiB){$body["usedLDWarningAlertMiB"] = $UsedLDWarningAlertMiB} 
	$LDLayoutBody = @{}
	if ($RAIDType)
		{	if($RAIDType -eq "R0")		{	$LDLayoutBody["RAIDType"] = 1	}
			elseif($RAIDType -eq "R1")	{	$LDLayoutBody["RAIDType"] = 2	}
			elseif($RAIDType -eq "R5")	{	$LDLayoutBody["RAIDType"] = 3	}
			else						{	$LDLayoutBody["RAIDType"] = 4	}
		}
    if ($SetSize)			{	$LDLayoutBody["setSize"] = $SetSize			}
	if ($HA)
		{	if($HA -eq "PORT")			{	$LDLayoutBody["HA"] = 1			}
			elseif($HA -eq "CAGE")		{	$LDLayoutBody["HA"] = 2			}
			else						{	$LDLayoutBody["HA"] = 3			}
		}
	if ($Chunklets)
		{	if($Chunklets -eq "FIRST")	{	$LDLayoutBody["chunkletPosPref"] = 1	}
			else 						{	$LDLayoutBody["chunkletPosPref"] = 2	}
		}
	$LDLayoutDiskPatternsBody=@()	
	if ($NodeList)
		{	$nodList=@{}
			$nodList["nodeList"] = "$($NodeList)"	
			$LDLayoutDiskPatternsBody += $nodList 			
		}
	if ($SlotList)
		{	$sList=@{}
			$sList["slotList"] = "$($SlotList)"	
			$LDLayoutDiskPatternsBody += $sList 		
		}
	if ($PortList)
		{	$pList=@{}
			$pList["portList"] = "$($PortList)"	
			$LDLayoutDiskPatternsBody += $pList 		
		}	
	if ($CageList)
		{
			$cagList=@{}
			$cagList["cageList"] = "$($CageList)"	
			$LDLayoutDiskPatternsBody += $cagList 		
		}
	if ($MagList)
		{	$mList=@{}
			$mList["magList"] = "$($MagList)"	
			$LDLayoutDiskPatternsBody += $mList 		
		}
	if ($DiskPosList)
		{	$dpList=@{}
			$dpList["diskPosList"] = "$($DiskPosList)"	
			$LDLayoutDiskPatternsBody += $dpList 		
		}
	if ($DiskList)
		{	$dskList=@{}
			$dskList["diskList"] = "$($DiskList)"	
			$LDLayoutDiskPatternsBody += $dskList 		
		}
	if ($TotalChunkletsGreaterThan)
		{	$tcgList=@{}
			$tcgList["totalChunkletsGreaterThan"] = $TotalChunkletsGreaterThan	
			$LDLayoutDiskPatternsBody += $tcgList 		
		}	
	if ($TotalChunkletsLessThan)
		{	$tclList=@{}
			$tclList["totalChunkletsLessThan"] = $TotalChunkletsLessThan	
			$LDLayoutDiskPatternsBody += $tclList 		
		}
	if ($FreeChunkletsGreaterThan)
		{	$fcgList=@{}
			$fcgList["freeChunkletsGreaterThan"] = $FreeChunkletsGreaterThan	
			$LDLayoutDiskPatternsBody += $fcgList 		
		}
	if ($FreeChunkletsLessThan)
		{	$fclList=@{}
			$fclList["freeChunkletsLessThan"] = $FreeChunkletsLessThan	
			$LDLayoutDiskPatternsBody += $fclList 		
		}
	if ($DiskType)
		{	$dtList=@{}
			if		($DiskType -eq "FC")		{	$dtList["diskType"] = 1		}
			elseif	($DiskType -eq "NL")		{	$dtList["diskType"] = 2		}
			elseif	($DiskType -eq "SSD")		{	$dtList["diskType"] = 3		}
			$LDLayoutDiskPatternsBody += $dtList
		}	
	if ($Rpm)
		{	$rpmList=@{}
			$rpmList["RPM"] = $Rpm	
			$LDLayoutDiskPatternsBody += $rpmList
		}	
	if($LDLayoutDiskPatternsBody.Count -gt 0)	{	$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody		}		
	if($LDLayoutBody.Count -gt 0)				{	$body["LDLayout"] = $LDLayoutBody 	}	
    $Result = $null	
    $Result = Invoke-A9API -uri '/cpgs' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
	{	write-host "Cmdlet executed successfully" -foreground green
		return Get-A9Cpg -CPGName $CPGName
	}
	else
	{	write-error "FAILURE : While creating CPG:$CPGName "
		return $Result.StatusDescription
	}	
}
}

Function Update-A9Cpg 
{
<#
.SYNOPSIS
	The Update-A9Cpg command Update a Common Provisioning Group (CPG).
.DESCRIPTION
	The Update-A9Cpg command Update a Common Provisioning Group (CPG).
	This operation requires access to all domains, as well as Super, Service, or Edit roles, or any role granted cpg_set permission.
.EXAMPLE   
	PS:> Update-A9Cpg -CPGName ascpg -NewName as_cpg
.EXAMPLE 	
	PS:> Update-A9Cpg  -CPGName xxx -RAIDType R1
.EXAMPLE 	
	PS:> Update-A9Cpg  -CPGName xxx -DisableAutoGrow $true
.EXAMPLE 	
	PS:> Update-A9Cpg  -CPGName xxx -RmGrowthLimit $true
.EXAMPLE 	
	PS:> Update-A9Cpg  -CPGName xxx -RmWarningAlert $true
.EXAMPLE 
	PS:> Update-A9Cpg  -CPGName xxx -SetSize 10
.EXAMPLE 	
	PS:> Update-A9Cpg  -CPGName xxx -HA PORT
.EXAMPLE 	
	PS:> Update-A9Cpg  -CPGName xxx -Chunklets FIRST
.EXAMPLE 	
	PS:> Update-A9Cpg  -CPGName xxx -NodeList 0
.PARAMETER CPGName,
	pecifies the name of Existing CPG.  
.PARAMETER NewName,
	Specifies the name of CPG to Update.
.PARAMETER RmGrowthLimit
	Enables (false) or disables (true) auto grow limit enforcement. Defaults to false.  
.PARAMETER DisableAutoGrow
	Enables (false) or disables (true) CPG auto grow. Defaults to false..
.PARAMETER RmWarningAlert
	Enables (false) or disables (true) warning limit enforcement. Defaults to false..
.PARAMETER RAIDType
	RAID type for the logical disk
	R0 RAID level 0
	R1 RAID level 1
	R5 RAID level 5
	R6 RAID level 6
.PARAMETER SetSize
	Specifies the set size in the number of chunklets.
.PARAMETER HA
	Specifies that the layout must support the failure of one port pair, one cage, or one magazine.
	PORT Support failure of a port.
	CAGE Support failure of a drive cage.
	MAG Support failure of a drive magazine.
.PARAMETER Chunklets
	FIRST Lowest numbered available chunklets, where transfer rate is the fastest.
	LAST  Highest numbered available chunklets, where transfer rate is the slowest.
.PARAMETER NodeList
	Specifies one or more nodes. Nodes are identified by one or more integers. Multiple nodes are separated with a single comma (1,2,3). 
	A range of nodes is separated with a hyphen (0–7). The primary path of the disks must be on the specified node number.
.PARAMETER SlotList
	Specifies one or more PCI slots. Slots are identified by one or more integers. Multiple slots are separated with a single comma (1,2,3). 
	A range of slots is separated with a hyphen (0–7). The primary path of the disks must be on the specified PCI slot number(s).
.PARAMETER PortList
	Specifies one or more ports. Ports are identified by one or more integers. Multiple ports are separated with a single comma (1,2,3). 
	A range of ports is separated with a hyphen (0–4). The primary path of the disks must be on the specified port number(s).
.PARAMETER CageList
	Specifies one or more drive cages. Drive cages are identified by one or more integers. Multiple drive cages are separated with a single comma (1,2,3). 
	A range of drive cages is separated with a hyphen (0– 3). The specified drive cage(s) must contain disks.
.PARAMETER MagList 
	Specifies one or more drive magazines. Drive magazines are identified by one or more integers. Multiple drive magazines are separated with a single comma (1,2,3). 
	A range of drive magazines is separated with a hyphen (0–7). The specified magazine(s) must contain disks.  
.PARAMETER DiskPosList
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers. Multiple disk positions are separated with a single comma (1,2,3). 
	A range of disk positions is separated with a hyphen (0–3). The specified portion(s) must contain disks.
.PARAMETER DiskList
	Specifies one or more physical disks. Disks are identified by one or more integers. Multiple disks are separated with a single comma (1,2,3). 
	A range of disks is separated with a hyphen (0–3). Disks must match the specified ID(s). 
.PARAMETER TotalChunkletsGreaterThan
	Specifies that physical disks with total chunklets greater than the number specified be selected.  
.PARAMETER TotalChunkletsLessThan
	Specifies that physical disks with total chunklets less than the number specified be selected. 
.PARAMETER FreeChunkletsGreaterThan
	Specifies that physical disks with free chunklets less than the number specified be selected.  
.PARAMETER FreeChunkletsLessThan
	Specifies that physical disks with free chunklets greater than the number specified be selected. 
.PARAMETER DiskType
	Specifies that physical disks must have the specified device type.
	FC Fibre Channel
	NL Near Line
	SSD SSD
.PARAMETER Rpm
	Disks must be of the specified speed.
#>
[CmdletBinding()]
	Param(
	[Parameter(Mandatory)]
							[String]	$CPGName,
	[Parameter()]			[String]	$NewName,
	[Parameter()]			[Boolean]	$DisableAutoGrow,		
	[Parameter()]			[Boolean]	$RmGrowthLimit,			
	[Parameter()]			[Boolean]	$RmWarningAlert,		
	[Parameter()][ValidateSet('R0','R1','R5','R6')]	
							[string]	$RAIDType, 				
	[Parameter()]    		[int]		$SetSize,
    [Parameter()][ValidateSet('CAGE','PORT','MAG')]
							[string]	$HA,					
	[Parameter()]		    [string]	$Chunklets,				
	[Parameter()]			[String]	$NodeList,				
	[Parameter()]			[String]	$SlotList,				
	[Parameter()]			[String]	$PortList,				
	[Parameter()]			[String]	$CageList,				
	[Parameter()]			[String]	$MagList,				
	[Parameter()]			[String]	$DiskPosList,			
	[Parameter()]			[String]	$DiskList,				
	[Parameter()]			[int]		$TotalChunkletsGreaterThan,
	[Parameter()]			[int]		$TotalChunkletsLessThan,
	[Parameter()]			[int]		$FreeChunkletsGreaterThan,
	[Parameter()]			[int]		$FreeChunkletsLessThan,
	[Parameter()][ValidateSet('FC','NL','SSD')]	
							[int]		$DiskType,	
	[Parameter()]			[int]		$Rpm	
)
Begin 
	{	Test-A9Connection -ClientType 'API' 
	}
Process 
{	$body = @{}
	If ($NewName) 							{ $body["newName"] ="$($NewName)" } 
	If (-not($null -eq $DisableAutoGrow))	{ $body["disableAutoGrow"] =$DisableAutoGrow } 
	If (-not($null -eq $RmGrowthLimit)) 	{ $body["rmGrowthLimit"] = $RmGrowthLimit } 
    If (-not($null -eq $RmWarningAlert)) 	{ $body["rmWarningAlert"] = $RmWarningAlert } 
	$LDLayoutBody = @{}
	if ($RAIDType)
		{	if($RAIDType -eq "R0")		{	$LDLayoutBody["RAIDType"] = 1	}
			elseif($RAIDType -eq "R1")	{	$LDLayoutBody["RAIDType"] = 2	}
			elseif($RAIDType -eq "R5")	{	$LDLayoutBody["RAIDType"] = 3	}
			else						{	$LDLayoutBody["RAIDType"] = 4	}
		}
    if ($SetSize)			{	$LDLayoutBody["setSize"] = $SetSize		}
	if ($HA)
		{	if($HA -eq "PORT")			{	$LDLayoutBody["HA"] = 1			}
			elseif($HA -eq "CAGE")		{	$LDLayoutBody["HA"] = 2			}
			else						{	$LDLayoutBody["HA"] = 3			}
		}
	if ($Chunklets)
		{	if($Chunklets -eq "FIRST")	{	$LDLayoutBody["chunkletPosPref"] = 1	}
			else 						{	$LDLayoutBody["chunkletPosPref"] = 2	}
		}
	$LDLayoutDiskPatternsBody=@()	
	if ($NodeList)
		{	$nodList=@{}
			$nodList["nodeList"] = "$($NodeList)"	
			$LDLayoutDiskPatternsBody += $nodList 			
		}
	if ($SlotList)
		{	$sList=@{}
			$sList["slotList"] = "$($SlotList)"	
			$LDLayoutDiskPatternsBody += $sList 		
		}
	if ($PortList)
		{	$pList=@{}
			$pList["portList"] = "$($PortList)"	
			$LDLayoutDiskPatternsBody += $pList 		
		}	
	if ($CageList)
		{	$cagList=@{}
			$cagList["cageList"] = "$($CageList)"	
			$LDLayoutDiskPatternsBody += $cagList 		
		}
	if ($MagList)
		{	$mList=@{}
			$mList["magList"] = "$($MagList)"	
			$LDLayoutDiskPatternsBody += $mList 		
		}
	if ($DiskPosList)
		{	$dpList=@{}
			$dpList["diskPosList"] = "$($DiskPosList)"	
			$LDLayoutDiskPatternsBody += $dpList 		
		}
	if ($DiskList)
		{	$dskList=@{}
			$dskList["diskList"] = "$($DiskList)"	
			$LDLayoutDiskPatternsBody += $dskList 		
		}
	if ($TotalChunkletsGreaterThan)
		{	$tcgList=@{}
			$tcgList["totalChunkletsGreaterThan"] = $TotalChunkletsGreaterThan	
			$LDLayoutDiskPatternsBody += $tcgList 		
		}
	if ($TotalChunkletsLessThan)
		{	$tclList=@{}
			$tclList["totalChunkletsLessThan"] = $TotalChunkletsLessThan	
			$LDLayoutDiskPatternsBody += $tclList 		
		}
	if ($FreeChunkletsGreaterThan)
		{	$fcgList=@{}
			$fcgList["freeChunkletsGreaterThan"] = $FreeChunkletsGreaterThan	
			$LDLayoutDiskPatternsBody += $fcgList 		
		}
	if ($FreeChunkletsLessThan)
		{	$fclList=@{}
			$fclList["freeChunkletsLessThan"] = $FreeChunkletsLessThan	
			$LDLayoutDiskPatternsBody += $fclList 		
		}	
	if ($DiskType)
		{	$dtList=@{}
			if		($DiskType -eq "FC")		{	$dtList["diskType"] = 1		}
			elseif	($DiskType -eq "NL")		{	$dtList["diskType"] = 2		}
			elseif	($DiskType -eq "SSD")		{	$dtList["diskType"] = 3		}
			$LDLayoutDiskPatternsBody += $dtList
		}	
	if ($Rpm)
		{	$rpmList=@{}
			$rpmList["RPM"] = $Rpm	
			$LDLayoutDiskPatternsBody += $rpmList
		}	
	if($LDLayoutDiskPatternsBody.Count -gt 0)	{	$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody	}		
	if($LDLayoutBody.Count -gt 0)				{	$body["LDLayout"] = $LDLayoutBody }
    $Result = $null
    $uri = '/cpgs/'+$CPGName	
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body	
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)
				{	return Get-A9Cpg -CPGName $NewName
				}
			else
				{	return Get-A9Cpg -CPGName $CPGName
				}
		}
	else
		{	write-error "FAILURE : While Updating CPG:$CPGName " 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9Cpg
{
<#
.SYNOPSIS
	Removes a Common Provision Group(CPG).
.DESCRIPTION
	Removes a CommonProvisionGroup(CPG)
    This operation requires access to all domains, as well as Super, or Edit roles, or any role granted cpg_remove permission.    
.EXAMPLE    
	PS:> Remove-A9Cpg -CPGName MyCPG
	
	Removes a Common Provision Group(CPG) "MyCPG".
.PARAMETER CPGName 
    Specify name of the CPG.
.NOTES
	This operation requires access to all domains, as well as Super, or Edit roles, or any role granted cpg_remove permission. 
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]		[String]	$CPGName
	)
Begin 
	{	Test-A9Connection -ClientType 'API'
	}
Process 
	{  	$uri = '/cpgs/'+$CPGName
		$Result = $null
		$Result = Invoke-A9API -uri $uri -type 'DELETE'
		$status = $Result.StatusCode
		if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return		
		}
		else
		{	write-error "FAILURE : While Removing CPG:$CPGName " 
			return $Result.StatusDescription
		}    
	}
}

Function Get-A9Cpg 
{
<#
.SYNOPSIS	
	Get list or single common provisioning groups (CPGs) all CPGs in the storage system.
.DESCRIPTION
	Get list or single common provisioning groups (CPGs) all CPGs in the storage system.
.EXAMPLE
	PS:> Get-A9Cpg

	List all/specified common provisioning groups (CPGs) in the system.
.EXAMPLE
	PS:> Get-A9Cpg -CPGName "MyCPG" 

	List Specified CPG name "MyCPG"	
.PARAMETER CPGName
	Specify name of the cpg to be listed
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$CPGName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	if($CPGName)
		{	$uri = '/cpgs/'+$CPGName
			$Result = Invoke-A9API -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}
	else
		{	$Result = Invoke-A9API -uri '/cpgs' -type 'GET'
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}		
		}
	if($Result.StatusCode -eq 200)
		{	write-host "Executed successfully" -foreground green
			return $dataPS
		}
	else
		{	write-error "FAILURE : While Executing Get-Cpg_WSAPI CPG:$CPGName "
			return $Result.StatusDescription
	}
}	
}
