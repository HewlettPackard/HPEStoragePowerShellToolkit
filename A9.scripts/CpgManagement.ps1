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
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
						[String]	$CPGName,
	[Parameter()]		[String]	$Domain = $null,
	[Parameter()]		[String]	$Template = $null,
	[Parameter()]		[Int]		$GrowthIncrementMiB = $null,
	[Parameter()]    	[int]		$GrowthLimitMiB = $null,
	[Parameter()]    	[int]		$UsedLDWarningAlertMiB = $null,
	[Parameter()][ValidateSet('R0','R1','R5','R6')]    [string]	$RAIDType = $null, 
	[Parameter()]    	[int]		$SetSize = $null,
    [Parameter()][ValidateSet('PORT','CAGE','MAG')]    [string]	$HA = $null,
	[Parameter()][ValidateSet('FIRST','LAST')]    [string]	$Chunklets = $null,
	[Parameter()]		[String]	$NodeList = $null,
	[Parameter()]		[String]	$SlotList = $null,
	[Parameter()]   	[String]	$PortList = $null,
	[Parameter()]    	[String]	$CageList = $null,
	[Parameter()]    	[String]	$MagList = $null,
	[Parameter()]    	[String]	$DiskPosList = $null,
	[Parameter()]    	[String] 	$DiskList = $null,
	[Parameter()]    	[int]	$TotalChunkletsGreaterThan = $null,
	[Parameter()]    	[int]	$TotalChunkletsLessThan = $null,
	[Parameter()]		[int]	$FreeChunkletsGreaterThan = $null,
	[Parameter()]    	[int]	$FreeChunkletsLessThan = $null,
	[Parameter()][ValidateSet('FC','NL','SSD')]	[string]	$DiskType = $null,
	[Parameter()]		[int]	$Rpm = $null
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
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
							[String]	$CPGName,
	[Parameter()]			[String]	$NewName,
	[Parameter()]			[Boolean]	$DisableAutoGrow = $false,
	[Parameter()]			[Boolean]	$RmGrowthLimit = $false,	
	[Parameter()]			[Boolean]	$RmWarningAlert = $false,
	[Parameter()][ValidateSet('R0','R1','R5','R6')]	[string]	$RAIDType = $null, 
	[Parameter()]    		[int]		$SetSize = $null,
    [Parameter()][ValidateSet('CAGE','PORT','MAG')]    		[string]	$HA = $null,
	[Parameter()]		    [string]	$Chunklets = $null,
	[Parameter()]			[String]	$NodeList = $null,	
	[Parameter()]			[String]	$SlotList = $null,
	[Parameter()]			[String]	$PortList = $null,
	[Parameter()]			[String]	$CageList = $null,
	[Parameter()]			[String]	$MagList = $null,
	[Parameter()]			[String]	$DiskPosList = $null,
	[Parameter()]			[String]	$DiskList = $null,
	[Parameter()]			[int]		$TotalChunkletsGreaterThan = $null,
	[Parameter()]			[int]		$TotalChunkletsLessThan = $null,
	[Parameter()]			[int]		$FreeChunkletsGreaterThan = $null,
	[Parameter()]			[int]		$FreeChunkletsLessThan = $null,
	[Parameter()][ValidateSet('FC','NL','SSD')]	[int]	$DiskType = $null,	
	[Parameter()]			[int]		$Rpm = $null
)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}
	If ($NewName) { $body["newName"] ="$($NewName)" } 
	If($DisableAutoGrow) { $body["disableAutoGrow"] =$DisableAutoGrow } #else { $body["disableAutoGrow"] =$DisableAutoGrow}
	If($RmGrowthLimit) { $body["rmGrowthLimit"] = $RmGrowthLimit } #else { $body["rmGrowthLimit"] = $RmGrowthLimit } 
    If($RmWarningAlert) { $body["rmWarningAlert"] = $RmWarningAlert } #else { $body["rmWarningAlert"] = $RmWarningAlert }
	$LDLayoutBody = @{}
	if ($RAIDType)
		{	if($RAIDType -eq "R0")		{	$LDLayoutBody["RAIDType"] = 1	}
			elseif($RAIDType -eq "R1")	{	$LDLayoutBody["RAIDType"] = 2	}
			elseif($RAIDType -eq "R5")	{	$LDLayoutBody["RAIDType"] = 3	}
			else						{	$LDLayoutBody["RAIDType"] = 4	}
		}
    if($SetSize)	{	$LDLayoutBody["setSize"] = $SetSize		}
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
	if($LDLayoutDiskPatternsBody.Count -gt 0)	{$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody	}		
	if($LDLayoutBody.Count -gt 0){$body["LDLayout"] = $LDLayoutBody }
    $Result = $null
    $uri = '/cpgs/'+$CPGName	
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body	
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)
				{	return Get-Cpg_WSAPI -CPGName $NewName
				}
			else
				{	return Get-Cpg_WSAPI -CPGName $CPGName
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
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
		[String]	$CPGName
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
Param(	[Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]	[String]	$CPGName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	if($CPGName)
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

# SIG # Begin signature block
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDjB0VyuNkC
# cpMaYVJ3Ite2lK17KHYVi7QD03GWVmXKetIKH3zaM5PJznZpJf3R5Va/mfWMeIAr
# db9EuC9ZClhRoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5UwghuRAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQE42oURZeuQ8qPuM83JUo/h1nvxYD6zLqfWG7CrXW1FlazAaOCH2+oOJ
# UyUPNjlgb639DCUzv0Hp0Jy71yu2cvMwDQYJKoZIhvcNAQEBBQAEggGALH9LFs0R
# lMg0HTyVLoGXsrUdAvlC/T/juPURIJidvhgSo3XLZfIKoeWt/YnxZxC8Lx16WP/S
# 5O9Nf16xsWBirnkZxQRTO2TNfCPDEHOmcUb0TrhvwMPW8YhYpfZKFBtHUDkFvgHO
# +Gw6uU93TgzJR8pcxVAvzuhD4mA9VKhVWpH1+mbGhrwU9aUP6doYvcMp8UxSvXO0
# ttbDNpcXcxDV++6JB0IIYFJEO6hQYOcbHBeEiyKYSQ3yIgZgfjSopYHgjngzqGbv
# vAdnnLgJe0XlRmxVzl+YtPfvICfjUPFL0w46rXX+FvZF39g6oMDk59VbKtlAvjjA
# jNl8+35cc3mglo9CcP4XDGkimaJtwLlcC7zkXz4Q2NKkQCvE7HBXCN34UVmkl0I4
# e1g/hUIivEwPRtIS6YIlpFh6a6ncGLXw2+00UvzZdKLvWy9cBPEc+56KwySjGOej
# /DbKP63bWR182FikI9+x/riLJBIJtsiJOW8URL5DbzAZvfQyEa7KErWloYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMMjYzoTKMUj+KXBaKsPM32kaQTAWFJjz
# 0o6/tWtib93G4t/sEEkgierK4U5Ou6rO5QIUUGtt8wU3x6xwAN/bxBMZPXMsdGkY
# DzIwMjQwNzMxMjAxODIyWqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
# bmNoZXN0ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2Vj
# dGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1oIIS/zCCBl0wggTF
# oAMCAQICEDpSaiyEzlXmHWX8zBLY6YkwDQYJKoZIhvcNAQEMBQAwVTELMAkGA1UE
# BhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGln
# byBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjQwMTE1MDAwMDAwWhcN
# MzUwNDE0MjM1OTU5WjBuMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFuY2hlc3Rl
# cjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydTZWN0aWdvIFB1
# YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzUwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN0Wf0wUibvf04STpNYYGbw9jcRaVhBDaNBp7jmJaA9dQZ
# W5ighrXGNMYjK7Dey5RIHMqLIbT9z9if753mYbojJrKWO4ZP0N5dBT2TwZZaPb8E
# +hqaDZ8Vy2c+x1NiEwbEzTrPX4W3QFq/zJvDDbWKL99qLL42GJQzX3n5wWo60Kkl
# fFn+Wb22mOZWYSqkCVGl8aYuE12SqIS4MVO4PUaxXeO+4+48YpQlNqbc/ndTgszR
# QLF4MjxDPjRDD1M9qvpLTZcTGVzxfViyIToRNxPP6DUiZDU6oXARrGwyP9aglPXw
# YbkqI2dLuf9fiIzBugCDciOly8TPDgBkJmjAfILNiGcVEzg+40xUdhxNcaC+6r0j
# uPiR7bzXHh7v/3RnlZuT3ZGstxLfmE7fRMAFwbHdDz5gtHLqjSTXDiNF58IxPtvm
# ZPG2rlc+Yq+2B8+5pY+QZn+1vEifI0MDtiA6BxxQuOnj4PnqDaK7NEKwtD1pzoA3
# jJFuoJiwbatwhDkg1PIjYnMDbDW+wAc9FtRN6pUsO405jaBgigoFZCw9hWjLNqgF
# VTo7lMb5rVjJ9aSBVVL2dcqzyFW2LdWk5Xdp65oeeOALod7YIIMv1pbqC15R7QCY
# LxcK1bCl4/HpBbdE5mjy9JR70BHuYx27n4XNOZbwrXcG3wZf9gEUk7stbPAoBQID
# AQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNhlxmiMpswHQYD
# VR0OBBYEFGjvpDJJabZSOB3qQzks9BRqngyFMA4GA1UdDwEB/wQEAwIGwDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1UdIARDMEEwNQYM
# KwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20v
# Q1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8vY3JsLnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcmwwegYIKwYB
# BQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYBBQUHMAGGF2h0
# dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IBgQCw3C7J+k82
# TIov9slP1e8YTx+fDsa//hJ62Y6SMr2E89rv82y/n8we5W6z5pfBEWozlW7nWp+s
# dPCdUTFw/YQcqvshH6b9Rvs9qZp5Z+V7nHwPTH8yzKwgKzTTG1I1XEXLAK9fHnmX
# paDeVeI8K6Lw3iznWZdLQe3zl+Rejdq5l2jU7iUfMkthfhFmi+VVYPkR/BXpV7Ub
# 1QyyWebqkjSHJHRmv3lBYbQyk08/S7TlIeOr9iQ+UN57fJg4QI0yqdn6PyiehS1n
# SgLwKRs46T8A6hXiSn/pCXaASnds0LsM5OVoKYfbgOOlWCvKfwUySWoSgrhncihS
# BXxH2pAuDV2vr8GOCEaePZc0Dy6O1rYnKjGmqm/IRNkJghSMizr1iIOPN+23futB
# XAhmx8Ji/4NTmyH9K0UvXHiuA2Pa3wZxxR9r9XeIUVb2V8glZay+2ULlc445CzCv
# VSZV01ZB6bgvCuUuBx079gCcepjnZDCcEuIC5Se4F6yFaZ8RvmiJ4hgwggYUMIID
# /KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUAMFcxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEwMzIyMDAwMDAw
# WhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAM2Y2ENBq26C
# K+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStSVjeYXIjfa3aj
# oW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQBaCxpectRGhh
# nOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE9cbY11XxM2AV
# Zn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExSLnh+va8WxTlA
# +uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OIIq/fWlwBp6KNL
# 19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGdF+z+Gyn9/CRe
# zKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w76kOLIaFVhf5
# sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4CllgrwIDAQABo4IB
# XDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUwHQYDVR0OBBYE
# FF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8E
# CDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0g
# ADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEFBQcBAQRwMG4w
# RwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1Ymxp
# Y1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2Nz
# cC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0ONVgMnoEdJVj9
# TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc6ZvIyHI5UkPC
# bXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1OSkkSivt51Ul
# mJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz2wSKr+nDO+Db
# 8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y4Il6ajTqV2if
# ikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVMCMPY2752LmES
# sRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBeNh9AQO1gQrnh
# 1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupiaAeNHe0pWSGH2
# opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU+CCQaL0cJqlm
# nx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/SjwsusWRItFA3DE8
# MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7xpMeYRriWklU
# PsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs656Oz3TbLyXVo
# MA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEpl
# cnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJV
# U1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9u
# IEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMFcxCzAJ
# BgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJBZvMWhUP2ZQQ
# RLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQnOh2qmcxGzjqe
# mIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypoGJrruH/drCio
# 28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0pKG9ki+PC6VEf
# zutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13jQEV1JnUTCm51
# 1n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9YrcmXcLgsrAi
# mfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/yVl4jnDcw6ULJ
# sBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVgh60KmLmzXiqJ
# c6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/OLoanEWP6Y52
# Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+NrLedIxsE88WzK
# XqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58NHs57ZPUfECcg
# JC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rID
# ZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1UdDwEB/wQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVz
# dC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwNQYI
# KwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3Qu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3OyWM637ayBeR
# 7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJJlFfym1Doi+4
# PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0mUGQHbRcF57ol
# pfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTwbD/zIExAopoe
# 3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i111TW7HV1Ats
# Qa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGezjM6CRpcWed/
# ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+8aW88WThRpv8
# lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH29308ZkpKKdp
# kiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrsxrYJD+3f3aKg
# 6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6Ii8+CQOYDwXM
# +yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz7NgAnOgpCdUo
# 4uDyllU9PzGCBJEwggSNAgEBMGkwVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1Nl
# Y3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFt
# cGluZyBDQSBSMzYCEDpSaiyEzlXmHWX8zBLY6YkwDQYJYIZIAWUDBAICBQCgggH5
# MBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQw
# NzMxMjAxODIyWjA/BgkqhkiG9w0BCQQxMgQwg2Yc4KKl7cZKMTaSbtNRicR/w7my
# 7meDUzKbGLjVGhpBxzD82fxxJBt1scTPFVPlMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgA1g9/j
# zQKacHBse4q0QzOtxiajN6jSwOgDUQFc/eZBOlWnqoDStgliRf0PdYSxH0q7kVyS
# sMPlbUCgfbhTUCFmBX7eudyOsdRpYVu3zeGglLT6OIFWOlXSLK0yDPNbvYhFydyT
# Gj0roto1WLPhTXtnWBGA+23u9hIfJek5huaFEEmdBWqJzwEfixEJfXPIuo8fbDyt
# PXCdvr4mqEiSuYZ0kXwvm+XpdToOO6ZiGZaFZLSYu92h5jSc4XanxREsnv6oZkl+
# uyvdNiWp5TyGSMJn2uUs38BjXAoJUtAtBJSy3WIxyTiooK1KKkIQtg65gjIPGhQj
# tTFR/z6MksVLXDJkx56X9rcHBcIBlVv/1/uszIYEvWUChA+a/pwYux185sNBp9Vn
# b48njZHqJMKUYv4SlgMR360zB7JmcdZkHP+6p1exoOWilJByYqqGnxhBsyCnJZCb
# ltdnCGwtRKk3lZzdxJni7boGqffzhs5JQBPDVszwNooAxa2kxSvD7CwqthtkXGnI
# LNfKx9PVR95k13lSMyMlqqacpsD5hFrZkiS49VSRlFaQaR6BPQ2RYB40DK+Nyc2y
# yWyVIQEpqkLS+7AapBwnmCGQsu1WQo9AScr+tzn0UQTqx2BkVqW2MO/fsckdiov+
# FQkNgDBHVUR9njPF7+YB4MIMO2flVk3vb9IEtQ==
# SIG # End signature block
