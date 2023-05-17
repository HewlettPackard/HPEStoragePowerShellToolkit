####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
##	File Name:		CpgManagement.psm1
##	Description: 	CPG Management cmdlets 
##		
##	Created:		February 2020
##	Last Modified:	February 2020
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## FUNCTION New-Cpg_WSAPI
############################################################################################################################################
Function New-Cpg_WSAPI 
{
  <#
  
  .SYNOPSIS
	The New-Cpg_WSAPI command creates a Common Provisioning Group (CPG).
  
  .DESCRIPTION
	The New-Cpg_WSAPI command creates a Common Provisioning Group (CPG).
        
  .EXAMPLE    
	New-Cpg_WSAPI -CPGName XYZ 
        
  .EXAMPLE	
	New-Cpg_WSAPI -CPGName "MyCPG" -Domain Chef_Test
        
  .EXAMPLE	
	New-Cpg_WSAPI -CPGName "MyCPG" -Domain Chef_Test -Template Test_Temp
        
  .EXAMPLE	
	New-Cpg_WSAPI -CPGName "MyCPG" -Domain Chef_Test -Template Test_Temp -GrowthIncrementMiB 100
        
  .EXAMPLE	
	New-Cpg_WSAPI -CPGName "MyCPG" -Domain Chef_Test -RAIDType R0

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
	Specifies that physical disks must have the specified device type.
	FC Fibre Channel
	NL Near Line
	SSD SSD
	  
  .PARAMETER Rpm
	Disks must be of the specified speed.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : New-Cpg_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: New-Cpg_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specifies the name of the CPG.')]
      [String]
	  $CPGName,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Specifies the name of the domain in which the object will reside.')]
      [String]
	  $Domain = $null,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Specifies the name of the template from which the CPG is created')]
      [String]
	  $Template = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the growth increment, in MiB, the amount of logical disk storage created on each auto-grow operation')]
      [Int]
	  $GrowthIncrementMiB = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies that the autogrow operation is limited to the specified storage amount, in MiB, that sets the growth limit')]
      [int]
	  $GrowthLimitMiB = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies that the threshold of used logical disk space, in MiB, when exceeded results in a warning alert')]
      [int]
	  $UsedLDWarningAlertMiB = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'RAIDType R0,R1,R5 and R6 only.')]
      [string]
	  $RAIDType = $null, 
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the set size in the number of chunklets.')]
      [int]
	  $SetSize = $null,
	  
      [Parameter(Mandatory = $false,HelpMessage = 'Specifies that the layout must support the failure of one port pair, one cage, or one magazine.')]
      [string]
	  $HA = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies the chunklet location preference characteristics.')]
      [string]
	  $Chunklets = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more nodes. Nodes are identified by one or more integers.')]
      [String]
	  $NodeList = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more nodes. Nodes are identified by one or more integers.')]
      [String]
	  $SlotList = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more ports. Ports are identified by one or more integers..')]
      [String]
	  $PortList = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more drive cages. Drive cages are identified by one or more integers.')]
      [String]
	  $CageList = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more drive magazines. Drive magazines are identified by one or more integers..')]
      [String]
	  $MagList = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers.')]
      [String]
	  $DiskPosList = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more physical disks. Disks are identified by one or more integers.')]
      [String]
	  $DiskList = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks with total chunklets greater than the number specified be selected.')]
      [int]
	  $TotalChunkletsGreaterThan = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks with total chunklets less than the number specified be selected.')]
      [int]
	  $TotalChunkletsLessThan = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks with free chunklets less than the number specified be selected.')]
      [int]
	  $FreeChunkletsGreaterThan = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks with free chunklets greater than the number specified be selected.')]
      [int]
	  $FreeChunkletsLessThan = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks must have the specified device type, FC (Fibre Channel) 2 is for NL (Near Line) 3 is for SSD .')]
      [string]
	  $DiskType = $null,
	  
	  [Parameter(Mandatory = $false,HelpMessage = 'Disks must be of the specified speed')]
      [int]
	  $Rpm = $null,
	  
	  [Parameter(Mandatory=$false, HelpMessage = 'Connection Paramater' ,ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection 
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    # Creation of the body hash
	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}	
		
    # Name parameter
    $body["name"] = "$($CPGName)"

    # Domain parameter
    If ($Domain) 
    {
		$body["domain"] = "$($Domain)"
    }

    # Template parameter
    If ($Template) 
    {
		$body["template"] = "$($Template)"
    } 

	# Template parameter
    If ($GrowthIncrementMiB) 
    {
		$body["growthIncrementMiB"] = $GrowthIncrementMiB
    } 
	
	# Template parameter
    If ($GrowthLimitMiB) 
    {
		$body["growthLimitMiB"] = $GrowthLimitMiB
    } 
	
	# Template parameter
    If ($UsedLDWarningAlertMiB) 
    {
		$body["usedLDWarningAlertMiB"] = $UsedLDWarningAlertMiB
    } 
	
	$LDLayoutBody = @{}
	# LDLayout
	#Specifies the RAID type for the logical disk
	if ($RAIDType)
	{		
		if($RAIDType -eq "R0")
		{
			$LDLayoutBody["RAIDType"] = 1
		}
		elseif($RAIDType -eq "R1")
		{
			$LDLayoutBody["RAIDType"] = 2
		}
		elseif($RAIDType -eq "R5")
		{
			$LDLayoutBody["RAIDType"] = 3
		}
		elseif($RAIDType -eq "R6")
		{
			$LDLayoutBody["RAIDType"] = 4
		}
		else
		{
			Write-DebugLog "Stop: Exiting  New-Cpg_WSAPI   since RAIDType $RAIDType in incorrect "
			Return "FAILURE : RAIDType :- $RAIDType is an Incorrect Please Use RAIDType R0,R1,R5 and R6 only. "
		}		
	}
	#Specifies the set size in the number of chunklets.
    if ($SetSize)
	{	
		$LDLayoutBody["setSize"] = $SetSize				
	}
	#Specifies that the layout must support the failure of one port pair, one cage, or one magazine.
	if ($HA)
	{
		if($HA -eq "PORT")
		{
			$LDLayoutBody["HA"] = 1					
		}
		elseif($HA -eq "CAGE")
		{
			$LDLayoutBody["HA"] = 2					
		}
		elseif($HA -eq "MAG")
		{
			$LDLayoutBody["HA"] = 3					
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting  New-Cpg_WSAPI since HA $HA in incorrect "
			Return "FAILURE : HA :- $HA is an Incorrect Please Use [ PORT | CAGE | MAG ] only "
		}
	}
	#Specifies the chunklet location preference characteristics
	if ($Chunklets)
	{		
		if($Chunklets -eq "FIRST")
		{
			$LDLayoutBody["chunkletPosPref"] = 1					
		}
		elseif($Chunklets -eq "LAST")
		{
			$LDLayoutBody["chunkletPosPref"] = 2					
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting  New-Cpg_WSAPI since Chunklets $Chunklets in incorrect "
			Return "FAILURE : Chunklets :- $Chunklets is an Incorrect Please Use Chunklets FIRST and LAST only. "
		}
	}
	
	$LDLayoutDiskPatternsBody=@()	
	
	if ($NodeList)
	{
		$nodList=@{}
		$nodList["nodeList"] = "$($NodeList)"	
		$LDLayoutDiskPatternsBody += $nodList 			
	}
	
	if ($SlotList)
	{
		$sList=@{}
		$sList["slotList"] = "$($SlotList)"	
		$LDLayoutDiskPatternsBody += $sList 		
	}
	
	if ($PortList)
	{
		$pList=@{}
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
	{
		$mList=@{}
		$mList["magList"] = "$($MagList)"	
		$LDLayoutDiskPatternsBody += $mList 		
	}
	
	if ($DiskPosList)
	{
		$dpList=@{}
		$dpList["diskPosList"] = "$($DiskPosList)"	
		$LDLayoutDiskPatternsBody += $dpList 		
	}

	if ($DiskList)
	{
		$dskList=@{}
		$dskList["diskList"] = "$($DiskList)"	
		$LDLayoutDiskPatternsBody += $dskList 		
	}
	
	if ($TotalChunkletsGreaterThan)
	{
		$tcgList=@{}
		$tcgList["totalChunkletsGreaterThan"] = $TotalChunkletsGreaterThan	
		$LDLayoutDiskPatternsBody += $tcgList 		
	}
	
	if ($TotalChunkletsLessThan)
	{
		$tclList=@{}
		$tclList["totalChunkletsLessThan"] = $TotalChunkletsLessThan	
		$LDLayoutDiskPatternsBody += $tclList 		
	}
	
	if ($FreeChunkletsGreaterThan)
	{
		$fcgList=@{}
		$fcgList["freeChunkletsGreaterThan"] = $FreeChunkletsGreaterThan	
		$LDLayoutDiskPatternsBody += $fcgList 		
	}
	
	if ($FreeChunkletsLessThan)
	{
		$fclList=@{}
		$fclList["freeChunkletsLessThan"] = $FreeChunkletsLessThan	
		$LDLayoutDiskPatternsBody += $fclList 		
	}
	
	if ($DiskType)
	{		
		if($DiskType -eq "FC")
		{			
			$dtList=@{}
			$dtList["diskType"] = 1	
			$LDLayoutDiskPatternsBody += $dtList						
		}
		elseif($DiskType -eq "NL")
		{			
			$dtList=@{}
			$dtList["diskType"] = 2	
			$LDLayoutDiskPatternsBody += $dtList						
		}
		elseif($DiskType -eq "SSD")
		{			
			$dtList=@{}
			$dtList["diskType"] = 3	
			$LDLayoutDiskPatternsBody += $dtList						
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting  New-Cpg_WSAPI   since DiskType $DiskType in incorrect "
			Return "FAILURE : DiskType :- $DiskType is an Incorrect Please Use FC (Fibre Channel), NL (Near Line) and SSD only"
		}
	}
	
	if ($Rpm)
	{
		$rpmList=@{}
		$rpmList["RPM"] = $Rpm	
		$LDLayoutDiskPatternsBody += $rpmList
	}	
		
	
	if($LDLayoutDiskPatternsBody.Count -gt 0)
	{
		$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody	
	}		
	if($LDLayoutBody.Count -gt 0)
	{
		$body["LDLayout"] = $LDLayoutBody 
	}	
	
    #init the response var
    $Result = $null	
	
	#$json = $body | ConvertTo-Json  -Compress -Depth 10
	#write-host " Body = $json"
	
    #Request
    $Result = Invoke-WSAPI -uri '/cpgs' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: CPG:$CPGName created successfully" $Info
		
		#write-host " StatusCode = $status"
		# Results
		Get-Cpg_WSAPI -CPGName $CPGName
		Write-DebugLog "End: New-Cpg_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating CPG:$CPGName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating CPG:$CPGName " $Info
		return $Result.StatusDescription
	}	
  }
  End 
  {
  }  
}
#ENG New-Cpg_WSAPI

############################################################################################################################################
## FUNCTION Update-Cpg_WSAPI
############################################################################################################################################
Function Update-Cpg_WSAPI 
{
  <#
  
  .SYNOPSIS
	The Update-Cpg_WSAPI command Update a Common Provisioning Group (CPG).
  
  .DESCRIPTION
	The Update-Cpg_WSAPI command Update a Common Provisioning Group (CPG).
	This operation requires access to all domains, as well as Super, Service, or Edit roles, or any role granted cpg_set permission.
    
  .EXAMPLE   
	Update-Cpg_WSAPI -CPGName ascpg -NewName as_cpg
    
  .EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -RAIDType R1
    
  .EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -DisableAutoGrow $true
    
  .EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -RmGrowthLimit $true
    
  .EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -RmWarningAlert $true
	    
  .EXAMPLE 
	Update-Cpg_WSAPI -CPGName xxx -SetSize 10
    
  .EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -HA PORT
    
  .EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -Chunklets FIRST
    
  .EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -NodeList 0
		
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
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Update-Cpg_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Update-Cpg_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>

  [CmdletBinding()]
	Param(
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specifies the name of Existing CPG.')]
	[String]$CPGName,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies the name of CPG to Update.')]
	[String]
	$NewName,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Enables (false) or disables (true) CPG auto grow. Defaults to false.')]
	[Boolean]
	$DisableAutoGrow = $false,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Enables (false) or disables (true) auto grow limit enforcement. Defaults to false.')]
	[Boolean]
	$RmGrowthLimit = $false,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Enables (false) or disables (true) warning limit enforcement. Defaults to false.')]
	[Boolean]
	$RmWarningAlert = $false,
	
	[Parameter(Mandatory = $false,HelpMessage = 'RAIDType enumeration 1 is for R0, 2 is for R1,3 is for R5, 4 is for R6')]
    [string]
	$RAIDType = $null, 
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies the set size in the number of chunklets.')]
    [int]
	$SetSize = $null,
	
    [Parameter(Mandatory = $false,HelpMessage = 'Specifies that the layout must support the failure of one port pair, one cage, or one magazine.')]
    [string]
	$HA = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies the chunklet location preference characteristics.')]
    [string]
	$Chunklets = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more nodes. Nodes are identified by one or more integers.')]
	[String]
	$NodeList = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more nodes. Nodes are identified by one or more integers.')]
	[String]
	$SlotList = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more ports. Ports are identified by one or more integers..')]
	[String]
	$PortList = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more drive cages. Drive cages are identified by one or more integers.')]
	[String]
	$CageList = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more drive magazines. Drive magazines are identified by one or more integers..')]
	[String]
	$MagList = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers.')]
	[String]
	$DiskPosList = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies one or more physical disks. Disks are identified by one or more integers.')]
	[String]
	$DiskList = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks with total chunklets greater than the number specified be selected.')]
	[int]
	$TotalChunkletsGreaterThan = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks with total chunklets less than the number specified be selected.')]
	[int]
	$TotalChunkletsLessThan = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks with free chunklets less than the number specified be selected.')]
	[int]
	$FreeChunkletsGreaterThan = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks with free chunklets greater than the number specified be selected.')]
	[int]
	$FreeChunkletsLessThan = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Specifies that physical disks must have the specified device type .')]
	[int]
	$DiskType = $null,
	
	[Parameter(Mandatory = $false,HelpMessage = 'Disks must be of the specified speed 1 is for FC (Fibre Channel) 2 is for NL (Near Line) 3 is for SSD.')]
	[int]
	$Rpm = $null,
	
	[Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
	$WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    # Creation of the body hash
	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}

    # New Name parameter
	If ($NewName) { $body["newName"] ="$($NewName)" } 
	
	<#
	switch($DisableAutoGrow) 
	{
	 {$_ -eq $true} {$body["disableAutoGrow"] =$DisableAutoGrow ;break;}
	 {$_ -eq $false} {$body["disableAutoGrow"] =$DisableAutoGrow ;break;}
	}
	#>
	
	# Disable Auto Growth
    If($DisableAutoGrow) { $body["disableAutoGrow"] =$DisableAutoGrow } #else { $body["disableAutoGrow"] =$DisableAutoGrow}

    # rm Growth Limit
    If($RmGrowthLimit) { $body["rmGrowthLimit"] = $RmGrowthLimit } #else { $body["rmGrowthLimit"] = $RmGrowthLimit } 

	# rm Warning Alert
    If($RmWarningAlert) { $body["rmWarningAlert"] = $RmWarningAlert } #else { $body["rmWarningAlert"] = $RmWarningAlert }
	
	$LDLayoutBody = @{}
	# LDLayout
	#Specifies the RAID type for the logical disk
	if($RAIDType)
	{	
		if($RAIDType -eq "R0")
		{
			$LDLayoutBody["RAIDType"] = 1
		}
		elseif($RAIDType -eq "R1")
		{
			$LDLayoutBody["RAIDType"] = 2
		}
		elseif($RAIDType -eq "R5")
		{
			$LDLayoutBody["RAIDType"] = 3
		}
		elseif($RAIDType -eq "R6")
		{
			$LDLayoutBody["RAIDType"] = 4
		}
		else
		{
			Write-DebugLog "Stop: Exiting  Update-Cpg_WSAPI   since RAIDType $RAIDType in incorrect "
			Return "FAILURE : RAIDType :- $RAIDType is an Incorrect Please Use RAIDType R0,R1,R5 and R6 only. "
		}
	}
	#Specifies the set size in the number of chunklets.
    if($SetSize)
	{	
		$LDLayoutBody["setSize"] = $SetSize				
	}
	#Specifies that the layout must support the failure of one port pair, one cage, or one magazine.
	if($HA)
	{
		if($HA -eq "PORT")
		{
			$LDLayoutBody["HA"] = 1					
		}
		elseif($HA -eq "CAGE")
		{
			$LDLayoutBody["HA"] = 2					
		}
		elseif($HA -eq "MAG")
		{
			$LDLayoutBody["HA"] = 3					
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting  Update-Cpg_WSAPI since HA $HA in incorrect "
			Return "FAILURE : HA :- $HA is an Incorrect Please Use PORT,CAGE and MAG only "
		}
	}
	#Specifies the chunklet location preference characteristics
	if ($Chunklets)
	{		
		if($Chunklets -eq "FIRST")
		{
			$LDLayoutBody["chunkletPosPref"] = 1					
		}
		elseif($Chunklets -eq "LAST")
		{
			$LDLayoutBody["chunkletPosPref"] = 2					
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting  Update-Cpg_WSAPI since Chunklets $Chunklets in incorrect "
			Return "FAILURE : Chunklets :- $Chunklets is an Incorrect Please Use Chunklets FIRST and LAST only. "
		}
	}	
		
	$LDLayoutDiskPatternsBody=@()	
	
	if ($NodeList)
	{
		$nodList=@{}
		$nodList["nodeList"] = "$($NodeList)"	
		$LDLayoutDiskPatternsBody += $nodList 			
	}
	
	if ($SlotList)
	{
		$sList=@{}
		$sList["slotList"] = "$($SlotList)"	
		$LDLayoutDiskPatternsBody += $sList 		
	}
	
	if ($PortList)
	{
		$pList=@{}
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
	{
		$mList=@{}
		$mList["magList"] = "$($MagList)"	
		$LDLayoutDiskPatternsBody += $mList 		
	}
	
	if ($DiskPosList)
	{
		$dpList=@{}
		$dpList["diskPosList"] = "$($DiskPosList)"	
		$LDLayoutDiskPatternsBody += $dpList 		
	}

	if ($DiskList)
	{
		$dskList=@{}
		$dskList["diskList"] = "$($DiskList)"	
		$LDLayoutDiskPatternsBody += $dskList 		
	}
	
	if ($TotalChunkletsGreaterThan)
	{
		$tcgList=@{}
		$tcgList["totalChunkletsGreaterThan"] = $TotalChunkletsGreaterThan	
		$LDLayoutDiskPatternsBody += $tcgList 		
	}
	
	if ($TotalChunkletsLessThan)
	{
		$tclList=@{}
		$tclList["totalChunkletsLessThan"] = $TotalChunkletsLessThan	
		$LDLayoutDiskPatternsBody += $tclList 		
	}
	
	if ($FreeChunkletsGreaterThan)
	{
		$fcgList=@{}
		$fcgList["freeChunkletsGreaterThan"] = $FreeChunkletsGreaterThan	
		$LDLayoutDiskPatternsBody += $fcgList 		
	}
	
	if ($FreeChunkletsLessThan)
	{
		$fclList=@{}
		$fclList["freeChunkletsLessThan"] = $FreeChunkletsLessThan	
		$LDLayoutDiskPatternsBody += $fclList 		
	}
	
	if ($DiskType)
	{		
		if($DiskType -eq "FC")
		{			
			$dtList=@{}
			$dtList["diskType"] = 1	
			$LDLayoutDiskPatternsBody += $dtList						
		}
		elseif($DiskType -eq "NL")
		{			
			$dtList=@{}
			$dtList["diskType"] = 2	
			$LDLayoutDiskPatternsBody += $dtList						
		}
		elseif($DiskType -eq "SSD")
		{			
			$dtList=@{}
			$dtList["diskType"] = 3	
			$LDLayoutDiskPatternsBody += $dtList						
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting  Update-Cpg_WSAPI   since DiskType $DiskType in incorrect "
			Return "FAILURE : DiskType :- $DiskType is an Incorrect Please Use FC (Fibre Channel), NL (Near Line) and SSD only"
		}
	}
	
	if ($Rpm)
	{
		$rpmList=@{}
		$rpmList["RPM"] = $Rpm	
		$LDLayoutDiskPatternsBody += $rpmList
	}	
		
	
	if($LDLayoutDiskPatternsBody.Count -gt 0)	{$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody	}		
	if($LDLayoutBody.Count -gt 0){$body["LDLayout"] = $LDLayoutBody }
	
	#$json = $body | ConvertTo-Json  -Compress -Depth 10
	#write-host " Body = $json"
	
	Write-DebugLog "Info:Body : $body" $Info    
    $Result = $null
	
	#Build uri
    $uri = '/cpgs/'+$CPGName	
    #Request
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{	
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: CPG:$CPGName successfully Updated" $Info
		# Results
		if($NewName)
		{
			Get-Cpg_WSAPI -CPGName $NewName
		}
		else
		{
			Get-Cpg_WSAPI -CPGName $CPGName
		}
		Write-DebugLog "End: Update-Cpg_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Updating CPG:$CPGName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating CPG:$CPGName " $Info
		
		return $Result.StatusDescription
	}
  }
  End 
  {
  }
}
#END Update-Cpg_WSAPI


############################################################################################################################################
## FUNCTION Remove-Cpg_WSAPI
############################################################################################################################################
Function Remove-Cpg_WSAPI
 {
  <#
	
  .SYNOPSIS
	Removes a Common Provision Group(CPG).
  
  .DESCRIPTION
	Removes a CommonProvisionGroup(CPG)
    This operation requires access to all domains, as well as Super, or Edit roles, or any role granted cpg_remove permission.    
	
  .EXAMPLE    
	Remove-Cpg_WSAPI -CPGName MyCPG
	Removes a Common Provision Group(CPG) "MyCPG".
	
  .PARAMETER CPGName 
    Specify name of the CPG.
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Remove-Cpg_WSAPI     
    LASTEDIT: February 2020
    KEYWORDS: Remove-Cpg_WSAPI 
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
	
  #>
  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specifies the name of CPG.')]
	[String]$CPGName,
	
	[Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
	$WsapiConnection = $global:WsapiConnection
	)
	
  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {    
	#Build uri
	Write-DebugLog "Running: Building uri to Remove-Cpg_WSAPI  ." $Debug
	$uri = '/cpgs/'+$CPGName

	#init the response var
	$Result = $null

	#Request
	Write-DebugLog "Request: Request to Remove-Cpg_WSAPI : $CPGName (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: CPG:$CPGName successfully remove" $Info
		Write-DebugLog "End: Remove-Cpg_WSAPI" $Debug
		return ""		
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Removing CPG:$CPGName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating CPG:$CPGName " $Info
		Write-DebugLog "End: Remove-Cpg_WSAPI" $Debug
		
		return $Result.StatusDescription
	}    
	
  }
  End {}  
}
#END Remove-Cpg_WSAPI

############################################################################################################################################
## FUNCTION Get-Cpg_WSAPI
############################################################################################################################################
Function Get-Cpg_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Get list or single common provisioning groups (CPGs) all CPGs in the storage system.
  
  .DESCRIPTION
	Get list or single common provisioning groups (CPGs) all CPGs in the storage system.
        
  .EXAMPLE
	Get-Cpg_WSAPI
	List all/specified common provisioning groups (CPGs) in the system.
	
  .EXAMPLE
	Get-Cpg_WSAPI -CPGName "MyCPG" 
	List Specified CPG name "MyCPG"
	
  .PARAMETER CPGName
	Specify name of the cpg to be listed
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
              
  .Notes
    NAME    : Get-Cpg_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-Cpg_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'CPG Name')]
      [String]
	  $CPGName,
	  
	  [Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null	
	
	#Build uri
	if($CPGName)
	{
		$uri = '/cpgs/'+$CPGName
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}
	}
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/cpgs' -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}		
	}
		  
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: CPG:$CPGName Successfully Executed" $Info

		# Add custom type to the resulting oject for formating purpose
		Write-DebugLog "Running: Add custom type to the resulting object for formatting purpose" $Debug
		
		#[array]$AlldataPS = Format-Result -dataPS $dataPS -TypeName '3PAR.Cpgs'		
		#return $AlldataPS
		return $dataPS
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-Cpg_WSAPI CPG:$CPGName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-Cpg_WSAPI CPG:$CPGName " $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-Cpg_WSAPI

Export-ModuleMember New-Cpg_WSAPI , Update-Cpg_WSAPI , Remove-Cpg_WSAPI , Get-Cpg_WSAPI
# SIG # Begin signature block
# MIIhEQYJKoZIhvcNAQcCoIIhAjCCIP4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC/wCNGtvjY985i
# oL08iHnre6Aj3yFqZCpGNfpoKkTi5aCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPvDCCD7gCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# Z5Y5B49YkiHlGrxTVggpVkibviN0LP731La35ml/17swDQYJKoZIhvcNAQEBBQAE
# ggEAjp9gyDJsbv7IWN6m1YrRrQIgqBAF9Yeudj0l0Cdy6Hj1axMrO6xyTbyCB4BN
# 8P3EHJ3uf2L7ERB37nDwuchDSMYQxu2/l0OKbNbKSsp8X3VRPSzOjZJILtna/cLP
# NISETtkrHapa4JtaEA8+5wIvktbV3B+wlIf53DqnzB4h5/1n59QWbqW9ZsrOAfdM
# gElL9NODAdWR8RGO6RD+9i/qoTO0mLBMTRDri758M+vF7BtAjiF6b6TZ5oes3jxX
# g/3o/icUS1HwE+r4t7zhwJQW7faSEYvLzFem1T6iZT90pkfyB2w0yMq2J/gfjWSF
# Nkx2RpBjBhmAwsU4GciLCqdYp6GCDX4wgg16BgorBgEEAYI3AwMBMYINajCCDWYG
# CSqGSIb3DQEHAqCCDVcwgg1TAgEDMQ8wDQYJYIZIAWUDBAIBBQAweAYLKoZIhvcN
# AQkQAQSgaQRnMGUCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCBlB439
# DwjxScy817p9KczRrCwz4xwwCCdfYboA1SRozQIRAIhxUnRdlBAtw9V255IZUZkY
# DzIwMjEwNjE5MDUxNDE5WqCCCjcwggT+MIID5qADAgECAhANQkrgvjqI/2BAIc4U
# APDdMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERp
# Z2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwHhcNMjEwMTAx
# MDAwMDAwWhcNMzEwMTA2MDAwMDAwWjBIMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIx
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwuZhhGfFivUNCKRFymNr
# Udc6EUK9CnV1TZS0DFC1JhD+HchvkWsMlucaXEjvROW/m2HNFZFiWrj/ZwucY/02
# aoH6KfjdK3CF3gIY83htvH35x20JPb5qdofpir34hF0edsnkxnZ2OlPR0dNaNo/G
# o+EvGzq3YdZz7E5tM4p8XUUtS7FQ5kE6N1aG3JMjjfdQJehk5t3Tjy9XtYcg6w6O
# LNUj2vRNeEbjA4MxKUpcDDGKSoyIxfcwWvkUrxVfbENJCf0mI1P2jWPoGqtbsR0w
# wptpgrTb/FZUvB+hh6u+elsKIC9LCcmVp42y+tZji06lchzun3oBc/gZ1v4NSYS9
# AQIDAQABo4IBuDCCAbQwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwQQYDVR0gBDowODA2BglghkgBhv1sBwEwKTAn
# BggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMB8GA1UdIwQY
# MBaAFPS24SAd/imu0uRhpbKiJbLIFzVuMB0GA1UdDgQWBBQ2RIaOpLqwZr68KC0d
# RDbd42p6vDBxBgNVHR8EajBoMDKgMKAuhixodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vc2hhMi1hc3N1cmVkLXRzLmNybDAyoDCgLoYsaHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmwwgYUGCCsGAQUFBwEBBHkwdzAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME8GCCsGAQUFBzAChkNo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNzdXJlZElE
# VGltZXN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IBAQBIHNy16ZojvOca
# 5yAOjmdG/UJyUXQKI0ejq5LSJcRwWb4UoOUngaVNFBUZB3nw0QTDhtk7vf5EAmZN
# 7WmkD/a4cM9i6PVRSnh5Nnont/PnUp+Tp+1DnnvntN1BIon7h6JGA0789P63ZHdj
# XyNSaYOC+hpT7ZDMjaEXcw3082U5cEvznNZ6e9oMvD0y0BvL9WH8dQgAdryBDvjA
# 4VzPxBFy5xtkSdgimnUVQvUtMjiB2vRgorq0Uvtc4GEkJU+y38kpqHNDUdq9Y9Yf
# W5v3LhtPEx33Sg1xfpe39D+E68Hjo0mh+s6nv1bPull2YYlffqe0jmd4+TaY4cso
# 2luHpoovMIIFMTCCBBmgAwIBAgIQCqEl1tYyG35B5AXaNpfCFTANBgkqhkiG9w0B
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTYwMTA3MTIwMDAwWhcNMzEwMTA3MTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# VGltZXN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# vdAy7kvNj3/dqbqCmcU5VChXtiNKxA4HRTNREH3Q+X1NaH7ntqD0jbOI5Je/YyGQ
# mL8TvFfTw+F+CNZqFAA49y4eO+7MpvYyWf5fZT/gm+vjRkcGGlV+Cyd+wKL1oODe
# Ij8O/36V+/OjuiI+GKwR5PCZA207hXwJ0+5dyJoLVOOoCXFr4M8iEA91z3FyTgqt
# 30A6XLdR4aF5FMZNJCMwXbzsPGBqrC8HzP3w6kfZiFBe/WZuVmEnKYmEUeaC50ZQ
# /ZQqLKfkdT66mA+Ef58xFNat1fJky3seBdCEGXIX8RcG7z3N1k3vBkL9olMqT4Ud
# xB08r8/arBD13ays6Vb/kwIDAQABo4IBzjCCAcowHQYDVR0OBBYEFPS24SAd/imu
# 0uRhpbKiJbLIFzVuMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMBIG
# A1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqg
# OKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMFAGA1UdIARJMEcwOAYKYIZIAYb9bAACBDAq
# MCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAsGCWCG
# SAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAQEAcZUS6VGHVmnN793afKpjerN4zwY3
# QITvS4S/ys8DAv3Fp8MOIEIsr3fzKx8MIVoqtwU0HWqumfgnoma/Capg33akOpMP
# +LLR2HwZYuhegiUexLoceywh4tZbLBQ1QwRostt1AuByx5jWPGTlH0gQGF+JOGFN
# YkYkh2OMkVIsrymJ5Xgf1gsUpYDXEkdws3XVk4WTfraSZ/tTYYmo9WuWwPRYaQ18
# yAGxuSh1t5ljhSKMYcp5lH5Z/IwP42+1ASa2bKXuh1Eh5Fhgm7oMLSttosR+u8Ql
# K0cCCHxJrhO24XxCQijGGFbPQTS2Zl22dHv1VjMiLyI2skuiSpXY9aaOUjGCAoYw
# ggKCAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0ECEA1CSuC+Ooj/YEAhzhQA8N0w
# DQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwG
# CSqGSIb3DQEJBTEPFw0yMTA2MTkwNTE0MTlaMCsGCyqGSIb3DQEJEAIMMRwwGjAY
# MBYEFOHXgqjhkb7va8oWkbWqtJSmJJvzMC8GCSqGSIb3DQEJBDEiBCC7HjBdUNmQ
# nM9ZBgrs0erScivpOIckm/pFnkf+7+McmjA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCCzEJAGvArZgweRVyngRANBXIPjKSthTyaWTI01cez1qTANBgkqhkiG9w0BAQEF
# AASCAQAcPPGRdmmj/S4+Pw9DxFbMi13Zg3mNFtlSPzQTY/UI97lC4UmU091o6a+1
# dC8wurXSWefyD2SiaMVVfpyB/DEGPHWB6MATTiL987kCEgNwytoDpM4doxkSqspl
# hN4iAPMW430Sy9YVow4vNntSIuFDNNKiJhgnkc88Y7YQcA2VNFhx3h/AS5jzc5aV
# 9G9CJqiuV4IiVunz/2yzIPZ1xcloJVabn8rv5f/E780yCYsj4z794pHST9eS6hO4
# kV2qAynSuCH3tF62ggf0K6FKOE0RtO7eyDrZ3iqe658jrLJbVT5TiQBpO3qRqwQJ
# YJW/YhxPeaRVqHcoFupRUqaOzAi+
# SIG # End signature block
