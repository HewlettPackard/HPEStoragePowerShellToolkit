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
##	File Name:		SystemReporter.psm1
##	Description: 	System Reporter cmdlets 
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
## FUNCTION Get-CacheMemoryStatisticsDataReports_WSAPI
############################################################################################################################################
Function Get-CacheMemoryStatisticsDataReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Cache memory statistics data reports
  
  .DESCRIPTION
	Cache memory statistics data reports.Request cache memory statistics data using either Versus Time or At Time reports.

	
  .EXAMPLE	
	Get-CacheMemoryStatisticsDataReports_WSAPI -VersusTime -Frequency_Hires
	
  .EXAMPLE	
	Get-CacheMemoryStatisticsDataReports_WSAPI -AtTime -Frequency_Hires
	
  .EXAMPLE	
	Get-CacheMemoryStatisticsDataReports_WSAPI -VersusTime -Frequency_Hires -NodeId 1
	
  .EXAMPLE	
	Get-CacheMemoryStatisticsDataReports_WSAPI -VersusTime -Frequency_Hires -NodeId "1,2,3"
		
  .EXAMPLE
	Get-CacheMemoryStatisticsDataReports_WSAPI -VersusTime -Frequency_Hires -Groupby node
		
  .EXAMPLE
	Get-CacheMemoryStatisticsDataReports_WSAPI -AtTime -Frequency_Hires -NodeId 1
	
  .EXAMPLE
	Get-CacheMemoryStatisticsDataReports_WSAPI -AtTime -Frequency_Hires -NodeId "1,2,3"
		
  .EXAMPLE
	Get-CacheMemoryStatisticsDataReports_WSAPI -AtTime -Frequency_Hires -Groupby node
	
  .EXAMPLE
	Get-CacheMemoryStatisticsDataReports_WSAPI -VersusTime -Frequency_Hires -Summary min
	
  .EXAMPLE
	Get-CacheMemoryStatisticsDataReports_WSAPI -VersusTime -Frequency_Hires -Compareby top -NoOfRecords 2 -ComparebyField hitIORead
	
  .EXAMPLE	
	Get-CacheMemoryStatisticsDataReports_WSAPI -VersusTime -Frequency_Hires -GETime 2018-07-18T13:20:00+05:30 -LETime 2018-07-18T13:25:00+05:30  
	        
  .EXAMPLE
	Get-CacheMemoryStatisticsDataReports_WSAPI -VersusTime -Frequency_Hires -GETime 2018-07-18T13:20:00+05:30 
	        
  .EXAMPLE
	Get-CacheMemoryStatisticsDataReports_WSAPI -VersusTime -Frequency_Hires -LETime 2018-07-18T13:25:00+05:30  
	
  .PARAMETER VersusTime
	Request cache memory statistics data using Versus Time reports.
	
  .PARAMETER AtTime
	Request cache memory statistics data using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily
	
  .PARAMETER NodeId
	<nodeid> – Provides cache memory data for the specified nodes, in the range of 0 to 7. For example specify node:1,3,2. With no nodeid specified, the system calculates cache memory data for all nodes in the system.
	
  .PARAMETER Groupby
	Group the sample data into the node category.
	
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	hitIORead : Number of read I/Os per second while data was in cache
	hitIOWrite : Number of write I/Os per second while data was in cache
	missIORead : Number of read I/Os per second while data was not in cache
	missIOWrite : Number of write I/Os per second while data was not in cache
	accessIORead : Number of read I/Os per second
	accessIOWrite : Number of write I/Os per second
	hitPctRead : Hits divided by accesses in percentage for read I/Os
	hitPctWrite : Hits divided by accesses in percentage for write I/Os
	totalAccessIO : Number of total read and write I/Os per second
	lockBulkIO : Number of pages modified per second by host I/O and written to disk by the flusher
	pageStatisticDelayAckPagesNL_7 : Delayed acknowledgment pages associated with NL 7
	pageStatisticDelayAckPagesFC : Delayed acknowledgment pages associated with FC
	pageStatisticDelayAckPagesSSD : Delayed acknowledgment pages associated with SSD
	pageStatisticPageStatesFree : Number of cache pages without valid data on them
	pageStatisticPageStatesClean : Number of clean cache pages
	pageStatisticPageStatesWriteOnce : Number of dirty pages modified exactly 1 time
	pageStatisticPageStatesWriteMultiple : Number of dirty pages modified more than 1 time
	pageStatisticPageStatesWriteScheduled : Number of pages scheduled to be written to disk
	pageStatisticPageStatesWriteing : Number of pages being written to disk
	pageStatisticPageStatesDcowpend : Number of pages waiting for delayed copy on write resolution
	pageStatisticDirtyPagesNL : Dirty cluster memory pages associated with NL 7
	pageStatisticDirtyPagesFC : Dirty cluster memory pages associated with FC
	pageStatisticDirtyPagesSSD : Dirty cluster memory pages associated with SSD
	pageStatisticMaxDirtyPagesNL_7 : Maximum allowed number of dirty cluster memory pages associated with NL 7
	pageStatisticMaxDirtyPagesFC : Maximum allowed number of dirty cluster memory pages associated with FC
	pageStatisticMaxDirtyPagesSSD : Maximum allowed number of dirty cluster memory pages associated with SSD

  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-CacheMemoryStatisticsDataReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-CacheMemoryStatisticsDataReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NodeId,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,		
		
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select atlist any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/cachememorystatistics/'+$Frequency
	
	if($NodeId) { if($AtTime) { return "We cannot pass node values in At Time report." } $uri = $uri+";node:$NodeId"}
	if($Groupby) { $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
	if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}
	
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	write-host "URL = $uri"
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-CacheMemoryStatisticsDataReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-CacheMemoryStatisticsDataReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-CacheMemoryStatisticsDataReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-CacheMemoryStatisticsDataReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-CacheMemoryStatisticsDataReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-CacheMemoryStatisticsDataReports_WSAPI


############################################################################################################################################
## FUNCTION Get-CPGSpaceDataReports_WSAPI
############################################################################################################################################
Function Get-CPGSpaceDataReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	CPG space data using either Versus Time or At Time reports.
  
  .DESCRIPTION
	CPG space data using either Versus Time or At Time reports..
        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires -CpgName xxx
	        
  .EXAMPLE	
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires -DiskType FC
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires -DiskType "FC,LN,SSD"
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires -RAIDType R1
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires -RAIDType "R1,R2"
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires -Groupby "id,diskType,RAIDType"
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
		        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -AtTime -Frequency_Hires -CpgName xxx
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -AtTime -Frequency_Hires -DiskType FC
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -AtTime -Frequency_Hires -DiskType "FC,NL"
	
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -AtTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
 .EXAMPLE	
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires -GETime 2018-07-18T13:20:00+05:30 -LETime 2018-07-18T13:25:00+05:30  
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires -GETime 2018-07-18T13:20:00+05:30 
	        
  .EXAMPLE
	Get-CPGSpaceDataReports_WSAPI -VersusTime -Frequency_Hires -LETime 2018-07-18T13:25:00+05:30
		
  .PARAMETER VersusTime
	Request CPG space data using  Versus Time reports.
	
  .PARAMETER AtTime
	Request CPG space data using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily
	
  .PARAMETER DiskType
	The CPG space sample data is for the specified disk types. With no disk type specified, the system calculates the CPG space sample data is for all the disk types in the system.
	1 is for :- FC : Fibre Channel
	2 is for :- NL : Near Line
	3 is for :- SSD : SSD
	4 is for :- SCM : SCM Disk type
	
  .PARAMETER CpgName
	Indicates that the CPG space sample data is only for the specified CPG names. With no name specified, the system calculates the CPG space sample data for all CPGs.
		
  .PARAMETER RAIDType
	Indicates that the CPG space sample data is for the specified raid types. With no type specified, the system calculates the CPG space sample data for all the raid types in the system.
	R0 : RAID level 0
	R1 : RAID level 1
	R5 : RAID level 5
	R6 : RAID level 6

  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	totalSpaceMiB : Total space in MiB.
	freeSpaceMiB : Free space in MiB.
	usedSpaceMiB : Used space in MiB
	compaction : Compaction ratio.
	compression : Compression ratio.
	deduplication : Deduplication ratio.
	dataReduction : Data reduction ratio.
	
  .PARAMETER Groupby  
	Group the sample data into categories. With no category specified, the system groups data into all
	categories. Separate multiple groupby categories using a comma (,) and no spaces. Use the structure,
	groupby:domain,id,name,diskType,RAIDType.
  
  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter
  
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-CPGSpaceDataReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-CPGSpaceDataReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $CpgName,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $DiskType,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $RAIDType,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,	
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/cpgspacedata/'+$Frequency
		
	if($CpgName) { if($AtTime) { return "We cannot pass CpgName in At Time report." } $uri = $uri+";name:$CpgName"}
	if($DiskType) 
	{
		if($AtTime)	{ return "We cannot pass DiskType in At Time report." }
		[System.String]$DislTV = ""
		$DislTV = Add-DiskType -DT $DiskType		
		$uri = $uri+";diskType:"+$DislTV.Trim()
	}
	if($RAIDType) 
	{ 
		if($AtTime) { return "We cannot pass RAIDType in At Time report." }
		[System.String]$RedTV = ""
		$RedTV = Add-RedType -RT $RAIDType		
		$uri = $uri+";RAIDType:"+$RedTV.Trim()	
	}
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
	if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}
	
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-CPGSpaceDataReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-CPGSpaceDataReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-CPGSpaceDataReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-CPGSpaceDataReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-CPGSpaceDataReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-CPGSpaceDataReports_WSAPI

############################################################################################################################################
## FUNCTION Get-CPGStatisticalDataReports_WSAPI
############################################################################################################################################
Function Get-CPGStatisticalDataReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	CPG statistical data using either Versus Time or At Time reports.
  
  .DESCRIPTION
	CPG statistical data using either Versus Time or At Time reports.
        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -VersusTime -Frequency_Hourly
        
  .EXAMPLE	
	Get-CPGStatisticalDataReports_WSAPI -VersusTime -Frequency_Hires -CpgName $cpg
	        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -VersusTime -Frequency_Hires -Groupby name
	        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -AtTime -Frequency_Hourly
	        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -CpgName $cpg
	        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -Groupby name
	        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"
	        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -VersusTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -VersusTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -VersusTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"
	
   .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-CPGStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .PARAMETER VersusTime
	Request CPG space data using  Versus Time reports.
	
  .PARAMETER AtTime
	Request CPG space data using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily
	
  .PARAMETER CpgName
	Indicates that the CPG space sample data is only for the specified CPG names. With no name specified, the system calculates the CPG space sample data for all CPGs.
 
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	totalIOPs : Total number of IOPs

  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter.
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-CPGStatisticalDataReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-CPGStatisticalDataReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $CpgName,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/cpgstatistics/'+$Frequency
		
	if($CpgName) { if($AtTime) { return "We cannot pass CpgName in At Time report." } $uri = $uri+";name:$CpgName"}	
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	#write-host "URL = $uri"
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-CPGStatisticalDataReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-CPGStatisticalDataReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-CPGStatisticalDataReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-CPGStatisticalDataReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-CPGStatisticalDataReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-CPGStatisticalDataReports_WSAPI

############################################################################################################################################
## FUNCTION Get-CPUStatisticalDataReports_WSAPI
############################################################################################################################################
Function Get-CPUStatisticalDataReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	CPU statistical data reports.
  
  .DESCRIPTION
	CPU statistical data reports.
	
  .EXAMPLE 
	Get-CPUStatisticalDataReports_WSAPI -AtTime -Frequency_Hires
  
  .EXAMPLE  
	Get-CPUStatisticalDataReports_WSAPI -VersusTime -Frequency_Hires
	
  .EXAMPLE  
	Get-CPUStatisticalDataReports_WSAPI -VersusTime -Frequency_Hires -NodeId 1
	
  .EXAMPLE  
	Get-CPUStatisticalDataReports_WSAPI -VersusTime -Frequency_Hires -Groupby cpu
  
  .EXAMPLE
	Get-CPUStatisticalDataReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-CPUStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-CPUStatisticalDataReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-CPUStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-CPUStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-CPUStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-CPUStatisticalDataReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"
			
  .PARAMETER VersusTime
	Request CPU statistics data using Versus Time reports.
	
  .PARAMETER AtTime
	Request CPU statistics data using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily
	
  .PARAMETER NodeId
	Indicates that the CPU statistics sample data is only for the specified nodes. The valid range of node IDs is 0 - 7. For example, specify node:1,3,2. With no node ID specified, the system calculates CPU statistics sample data for all nodes in the system.
  
  .PARAMETER Groupby
	You can group the CPU statistical data into categories. With no groupby parameter specified, the system groups the data into all categories.
		    
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	userPct : Percent of CPU time in user-mode
	systemPct : Percent of CPU time in system-mode
	idlePct : Percent of CPU time in idle
	interruptsPerSec : Number of interrupts per second
	contextSwitchesPerSec : Number of context switches per second
	
  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-CPUStatisticalDataReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-CPUStatisticalDataReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NodeId,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select atlist any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/cpustatistics/'+$Frequency
	
	if($NodeId) { if($AtTime) { return "We cannot pass node values in At Time report." } $uri = $uri+";node:$NodeId"}
	if($Groupby) { $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-CPUStatisticalDataReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-CPUStatisticalDataReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-CPUStatisticalDataReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-CPUStatisticalDataReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-CPUStatisticalDataReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-CPUStatisticalDataReports_WSAPI


############################################################################################################################################
## FUNCTION Get-PDCapacityReports_WSAPI
############################################################################################################################################
Function Get-PDCapacityReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Physical disk capacity reports.
  
  .DESCRIPTION
	Physical disk capacity reports.
        
  .EXAMPLE 
	Get-PDCapacityReports_WSAPI -AtTime -Frequency_Hires
  
  .EXAMPLE  
	Get-PDCapacityReports_WSAPI -VersusTime -Frequency_Hires
	  
  .EXAMPLE 
	Get-PDCapacityReports_WSAPI -VersusTime -Frequency_Hires -Id 1
	  
  .EXAMPLE 
	Get-PDCapacityReports_WSAPI -VersusTime -Frequency_Hires -DiskType FC
	  
  .EXAMPLE 
	Get-PDCapacityReports_WSAPI -AtTime -Frequency_Hires -DiskType "FC,SSD"
	  
  .EXAMPLE 
	Get-PDCapacityReports_WSAPI -VersusTime -Frequency_Hires -Groupby id
	  
  .EXAMPLE 
	Get-PDCapacityReports_WSAPI -AtTime -Frequency_Hires -Groupby "id,type"
  
  .EXAMPLE
	Get-PDCapacityReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-PDCapacityReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-PDCapacityReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-PDCapacityReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-PDCapacityReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-PDCapacityReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-PDCapacityReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
		
  .PARAMETER VersusTime
	Request Physical disk capacity using Versus Time reports.
	
  .PARAMETER AtTime
	Request Physical disk capacity using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily
	
  .PARAMETER Id
	Requests disk capacity data for the specified disks only. For example, specify id:1,3,2. With no id specified, the system calculates physical disk capacity for all disks in the system.
  
  .PARAMETER DiskType
	Specifies the disk types to query for physical disk capacity sample data. With no disktype specified, the system calculates physical disk capacity for all disk types in the system.
	FC : Fibre Channel
	NL : Near Line
	SSD : SSD
	
  .PARAMETER RPM
	Specifies the RPM speeds to query for physical disk capacity data. With no speed indicated, the system calculates physical disk capacity data for all speeds in the system. You can specify one or more disk RPM speeds by separating them with a comma (,). For example, specify RPM:7,15,150. Valid RPM values are: 7,10,15,100,150.
  
  .PARAMETER Groupby
	id | cageID | cageSide | mag | diskPos | type | RPM
	Groups the sample data into specified categories. With no category specified, the system groups data into all categories. To specify multiple groupby categories, separate them using a comma (,). For example, id,type,RPM.
	    
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-PDCapacityReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-PDCapacityReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Id,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $DiskType,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $RPM,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/physicaldiskcapacity/'+$Frequency
		
	if($Id) { if($AtTime) { return "We cannot pass Id in At Time report." } $uri = $uri+";id:$Id"}
	#if($DiskType) { if($AtTime) { return "We cannot pass DiskType in At Time report." } $uri = $uri+";type:$DiskType"}
	if($DiskType) 
	{
		if($AtTime)	{ return "We cannot pass DiskType in At Time report." }
		[System.String]$DislTV = ""
		$DislTV = Add-DiskType -DT $DiskType		
		$uri = $uri+";type:"+$DislTV.Trim()
	}	
	if($RPM) { if($AtTime) { return "We cannot pass RPM in At Time report." } $uri = $uri+";RPM:$RPM"}
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}	
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	#write-host "URL = $uri"
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-PDCapacityReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-PDCapacityReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-PDCapacityReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-PDCapacityReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-PDCapacityReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-PDCapacityReports_WSAPI

############################################################################################################################################
## FUNCTION Get-PDStatisticsReports_WSAPI
############################################################################################################################################
Function Get-PDStatisticsReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	physical disk statistics reports using either Versus Time or At Time reports.
  
  .DESCRIPTION
	physical disk statistics reports using either Versus Time or At Time reports.
        
  .EXAMPLE 
	Get-PDStatisticsReports_WSAPI -AtTime -Frequency_Hires
  
  .EXAMPLE  
	Get-PDStatisticsReports_WSAPI -VersusTime -Frequency_Hires
	  
  .EXAMPLE 
	Get-PDStatisticsReports_WSAPI -VersusTime -Frequency_Hires -Id 1
	  
  .EXAMPLE 
	Get-PDStatisticsReports_WSAPI -VersusTime -Frequency_Hires -DiskType FC
	  
  .EXAMPLE 
	Get-PDStatisticsReports_WSAPI -AtTime -Frequency_Hires -DiskType "FC,SSD"
	  
  .EXAMPLE	
	Get-PDStatisticsReports_WSAPI -VersusTime -Frequency_Hires -RPM 7
	  
  .EXAMPLE
	Get-PDStatisticsReports_WSAPI -AtTime -Frequency_Hires -RPM "7,10"
	
  .EXAMPLE 
	Get-PDStatisticsReports_WSAPI -VersusTime -Frequency_Hires -Groupby id
	  
  .EXAMPLE 
	Get-PDStatisticsReports_WSAPI -AtTime -Frequency_Hires -Groupby "id,type"
  
  .EXAMPLE
	Get-PDStatisticsReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-PDStatisticsReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-PDStatisticsReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-PDStatisticsReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-PDStatisticsReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-PDStatisticsReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-PDStatisticsReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
		
  .PARAMETER VersusTime
	Request Physical disk capacity using Versus Time reports.
	
  .PARAMETER AtTime
	Request Physical disk capacity using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily
	
  .PARAMETER Id
	Requests disk capacity data for the specified disks only. For example, specify id:1,3,2. With no id specified, the system calculates physical disk capacity for all disks in the system.
  
  .PARAMETER DiskType
	Specifies the disk types to query for physical disk capacity sample data. With no disktype specified, the system calculates physical disk capacity for all disk types in the system.
	FC : Fibre Channel
	NL : Near Line
	SSD : SSD
	
  .PARAMETER RPM
	Specifies the RPM speeds to query for physical disk capacity data. With no speed indicated, the system calculates physical disk capacity data for all speeds in the system. You can specify one or more disk RPM speeds by separating them with a comma (,). For example, specify RPM:7,15,150. Valid RPM values are: 7,10,15,100,150.
  
  .PARAMETER Groupby
	id | cageID | cageSide | mag | diskPos | type | RPM
	Groups the sample data into specified categories. With no category specified, the system groups data into all categories. To specify multiple groupby categories, separate them using a comma (,). For example, id,type,RPM.
     
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	totalIOPs : Total IOPs.

  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-PDStatisticsReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-PDStatisticsReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Id,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $DiskType,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $RPM,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/physicaldiskstatistics/'+$Frequency
		
	if($Id) { if($AtTime) { return "We cannot pass Id in At Time report." } $uri = $uri+";id:$Id"}
	if($DiskType) { if($AtTime) { return "We cannot pass DiskType in At Time report." } $uri = $uri+";type:$DiskType"}
	if($RPM) { if($AtTime) { return "We cannot pass RPM in At Time report." } $uri = $uri+";RPM:$RPM"}
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}	
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	#write-host "URL = $uri"
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-PDStatisticsReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-PDStatisticsReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-PDStatisticsReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-PDStatisticsReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-PDStatisticsReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-PDStatisticsReports_WSAPI

############################################################################################################################################
## FUNCTION Get-PDSpaceReports_WSAPI
############################################################################################################################################
Function Get-PDSpaceReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Request physical disk space data reports using either Versus Time or At Time reports.
  
  .DESCRIPTION
	Request physical disk space data reports using either Versus Time or At Time reports.
        
  .EXAMPLE 
	Get-PDSpaceReports_WSAPI -AtTime -Frequency_Hires
  
  .EXAMPLE  
	Get-PDSpaceReports_WSAPI -VersusTime -Frequency_Hires
	  
  .EXAMPLE 
	Get-PDSpaceReports_WSAPI -VersusTime -Frequency_Hires -Id 1
	  
  .EXAMPLE 
	Get-PDSpaceReports_WSAPI -VersusTime -Frequency_Hires -DiskType FC
	  
  .EXAMPLE 
	Get-PDSpaceReports_WSAPI -AtTime -Frequency_Hires -DiskType "FC,SSD"
	  
  .EXAMPLE	
	Get-PDSpaceReports_WSAPI -VersusTime -Frequency_Hires -RPM 7
	  
  .EXAMPLE
	Get-PDSpaceReports_WSAPI -AtTime -Frequency_Hires -RPM "7,10"
	
  .EXAMPLE 
	Get-PDSpaceReports_WSAPI -VersusTime -Frequency_Hires -Groupby id
	  
  .EXAMPLE 
	Get-PDSpaceReports_WSAPI -AtTime -Frequency_Hires -Groupby "id,cageID"
  
  .EXAMPLE
	Get-PDSpaceReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-PDSpaceReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-PDSpaceReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-PDSpaceReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-PDSpaceReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-PDSpaceReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-PDSpaceReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
		
  .PARAMETER VersusTime
	Request Physical disk capacity using Versus Time reports.
	
  .PARAMETER AtTime
	Request Physical disk capacity using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily
	
  .PARAMETER Id
	Requests disk capacity data for the specified disks only. For example, specify id:1,3,2. With no id specified, the system calculates physical disk capacity for all disks in the system.
  
  .PARAMETER DiskType
	Specifies the disk types to query for physical disk capacity sample data. With no disktype specified, the system calculates physical disk capacity for all disk types in the system.
	FC : Fibre Channel
	NL : Near Line
	SSD : SSD
	
  .PARAMETER RPM
	Specify the RPM speed to query for physical disk capacity data. With no speed indicated, the system
	calculates physical disk capacity data for all speeds in the system. Specify one or more disk RPM speeds
	by separating them with a comma (,). Use the structure, RPM:7,15,150. Valid RPM values are:7,10,15,100,150.
  
  .PARAMETER Groupby
	id | cageID | cageSide | mag | diskPos | type | RPM
	Groups the sample data into specified categories. With no category specified, the system groups data into all categories. To specify multiple groupby categories, separate them using a comma (,). For example, id,type,RPM.
	    
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	totalIOPs : Total number of IOPs
	normalChunkletsUsedOK : Normal used good chunklets
	normalChunkletsUsedFailed : Normal used failed chunklets
	normalChunkletsAvailClean : Normal available clean chunklets
	normalChunkletsAvailDirty : Normal available dirty chunklets
	normalChunkletsAvailFailed : Normal available failed chunklets
	spareChunkletsUsedOK : Spare used good chunklets
	spareChunkletsUsedFailed : Spare used failed chunklets
	spareChunkletsAvailClean : Spare available clean chunklets
	spareChunkletsAvailDirty : Spare available dirty chunklets
	spareChunkletsAvailFailed : Spare available failed chunklets
	lifeLeftPct : Percentage of life left
	temperatureC : Temperature in Celsius
	
  .PARAMETER Compareby
	top|bottom,noOfRecords,comparebyField
	Optional parameter provided in comma-separated format, and in the specific order shown above. Requires simultaneous use of the groupby parameter. The following table describes the parameter values.
	
  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter


  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-PDSpaceReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-PDSpaceReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Id,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $DiskType,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $RPM,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [System.String]
	  $Summary,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/physicaldiskspacedata/'+$Frequency
		
	if($Id) { if($AtTime) { return "We cannot pass Id in At Time report." } $uri = $uri+";id:$Id"}	
	if($DiskType) 
	{
		if($AtTime)	{ return "We cannot pass DiskType in At Time report." }
		[System.String]$DislTV = ""
		$DislTV = Add-DiskType -DT $DiskType		
		$uri = $uri+";type:"+$DislTV.Trim()
	}
	if($RPM) { if($AtTime) { return "We cannot pass RPM in At Time report." } $uri = $uri+";RPM:$RPM"}
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}	
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	#write-host "URL = $uri"
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-PDSpaceReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-PDSpaceReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-PDSpaceReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-PDSpaceReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-PDSpaceReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-PDSpaceReports_WSAPI


############################################################################################################################################
## FUNCTION Get-PortStatisticsReports_WSAPI
############################################################################################################################################
Function Get-PortStatisticsReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Request a port statistics report using either Versus Time or At Time reports.
  
  .DESCRIPTION
	Request a port statistics report using either Versus Time or At Time reports.
        
  .EXAMPLE 
	Get-PortStatisticsReports_WSAPI -AtTime -Frequency_Hires
  
  .EXAMPLE  
	Get-PortStatisticsReports_WSAPI -VersusTime -Frequency_Hires
	  
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -VersusTime -Frequency_Hires -NSP "1:0:1"
	  
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -AtTime -Frequency_Hires -PortType 1
	  
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -VersusTime -Frequency_Hires -PortType :1,2"
	  
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -VersusTime -Frequency_Hourly -Groupby slot
	  
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -AtTime -Frequency_Hourly -Groupby "slot,type"
	
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-PortStatisticsReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
		
  .PARAMETER VersusTime
	Request port statistics report using Versus Time reports.
	
  .PARAMETER AtTime
	Request port statistics report using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily

  .PARAMETER NSP
	Requests sample data for the specified ports only using n:s:p. For example, specify port:1:0:1,2:1:3,6:2:1. With no portPos specified, the system calculates performance data for all ports in the system.
  
  .PARAMETER PortType
	Requests sample data for the specified port type (see, portConnType enumeration) . With no type specified, the system calculates performance data for all port types in the system. You can specify one or more port types by separating them with a comma (,). For example, specify type: 1,2,8.
	Symbol Value Description
	1 for :- HOST : FC port connected to hosts or fabric.	
	2 for :- DISK : FC port connected to disks.	
	3 for :- FREE : Port is not connected to hosts or disks.	
	4 for :- IPORT : Port is in iport mode.	
	5 for :- RCFC : FC port used for Remote Copy.	
	6 for :- PEER : FC port used for data migration.	
	7 for :- RCIP : IP (Ethernet) port used for Remote Copy.	
	8 for :- ISCSI : iSCSI (Ethernet) port connected to hosts.	
	9 for :- CNA : CNA port, which can be FCoE or iSCSI.	
	10 for :- FS : Ethernet File Persona ports.
	
  .PARAMETER Groupby
	node | slot | cardPort | type | speed
	Groups the sample data into specified categories. With no category specified, the system groups data into all categories. To specify multiple groupby categories, separate them using a comma (,). For example, slot,cardPort,type. 
	      
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	totalIOPs : Total IOPs.

  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-PortStatisticsReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-PortStatisticsReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $PortType,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/portstatistics/'+$Frequency
		
	if($NSP) { if($AtTime) { return "We cannot pass NSP in At Time report." } $uri = $uri+";portPos:$NSP"}
	if($PortType) { if($AtTime) { return "We cannot pass PortType in At Time report." } $uri = $uri+";type:$PortType"}	
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}		
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-PortStatisticsReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-PortStatisticsReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-PortStatisticsReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-PortStatisticsReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-PortStatisticsReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-PortStatisticsReports_WSAPI


############################################################################################################################################
## FUNCTION Get-QoSStatisticalReports_WSAPI
############################################################################################################################################
Function Get-QoSStatisticalReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Request Quality of Service (QoS) statistical data using either Versus Time or At Time reports.
  
  .DESCRIPTION
	Request Quality of Service (QoS) statistical data using either Versus Time or At Time reports.

  .EXAMPLE	
	Get-QoSStatisticalReports_WSAPI -VersusTime -Frequency_Hires
	
  .EXAMPLE	
	Get-QoSStatisticalReports_WSAPI -VersusTime -Frequency_Hires -VvSetName "asvvset2"

  .EXAMPLE	
	Get-QoSStatisticalReports_WSAPI -VersusTime -Frequency_Hires -VvSetName "asvvset,asvvset2"

  .EXAMPLE		
	Get-QoSStatisticalReports_WSAPI -VersusTime -Frequency_Daily -All_Others

  .EXAMPLE		
	Get-QoSStatisticalReports_WSAPI -VersusTime -Frequency_Daily -Domain asdomain
	
  .EXAMPLE 
	Get-QoSStatisticalReports_WSAPI -AtTime -Frequency_Hires
  
  .EXAMPLE  
	Get-QoSStatisticalReports_WSAPI -VersusTime -Frequency_Hires
	
  .EXAMPLE
	Get-QoSStatisticalReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-QoSStatisticalReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-QoSStatisticalReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-QoSStatisticalReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-QoSStatisticalReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-QoSStatisticalReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-QoSStatisticalReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
	
  .PARAMETER VersusTime
	Request port statistics report using Versus Time reports.
	
  .PARAMETER AtTime
	Request port statistics report using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily

  .PARAMETER VvSetName
	Retrieve QoS statistics for the specified vvset. Specify multiple vvsets using vvset_name1,vvset_name2...
  
  .PARAMETER Domain
	Retrieve QoS statistics for the specified domain. Use the structure, domain:<domain_name>, or specify multiple domains using domain_name1,domain_name2...

  .PARAMETER All_Others
	Specify all host I/Os not regulated by any active QoS rule. Use the structure, all_others
	
  .PARAMETER Groupby
	Group QoS statistical data into categories. With no groupby parameter specified, the system groups the
	data into all categories. You can specify one or more groupby categories by separating them with a
	comma. Use the structure, groupby:domain,type,name,ioLimit.
      
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	readIOPS : Read input/output operations per second.
	writeIOPS : Write input/output operations per second.
	totalIOPS : Total input/output operations per second.
	readKBytes : Read kilobytes.
	writeKBytes : Write kilobytes.
	totalKBytes : Total kilobytes.
	readServiceTimeMS : Read service time in milliseconds.
	writeServiceTimeMS : Write service time in milliseconds.
	totalServiceTimeMS : Total service time in milliseconds.
	readIOSizeKB : Read input/output size in kilobytes
	writeIOSizeKB : Write input/output size in kilobytes
	totalIOSizeKB : Total input/output size in kilobytes
	readWaitTimeMS : Read wait time in milliseconds.
	writeWaitTimeMS : Write wait time in milliseconds.
	totalWaitTimeMS : Total wait time in milliseconds.
	IOLimit : IO limit.
	BWLimit : Bandwidth limit.
	IOGuarantee : Input/output guarantee.
	BWGuarantee : Bandwidth guarantee.
	busyPct : Busy Percentage.
	queueLength : Total queue length.
	waitQueueLength : Total wait queue length.
	IORejection : Total input/output rejection.
	latencyMS : Latency in milliseconds.
	latencyTargetMS : Latency target in milliseconds.

  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-QoSStatisticalReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-QoSStatisticalReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VvSetName,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Domain,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $All_Others,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/qosstatistics/'+$Frequency
		
	if($VvSetName) 
	{ 
		if($AtTime) { return "We cannot pass VvSetName in At Time report." }
		$lista = $VvSetName.split(",")		
		$count = 1
		$set =""
		foreach($sub in $lista)
		{
			$prfx ="vvset:"+$sub
			if($lista.Count -gt 1)
			{
				if($lista.Count -ne $count)
				{					
					$prfx = $prfx + ","
					$count = $count + 1
				}				
			}
			$set = $prfx
		}
		
		$uri = $uri+";$set"
	}
	if($Domain) 
	{ 
		if($AtTime) { return "We cannot pass Domain in At Time report." }
		$lista = $Domain.split(",")		
		$count = 1
		$dom =""
		foreach($sub in $lista)
		{
			$prfx ="domain:"+$sub
			if($lista.Count -gt 1)
			{
				if($lista.Count -ne $count)
				{					
					$prfx = $prfx + ","
					$count = $count + 1
				}				
			}
			$dom = $prfx
		}
		
		$uri = $uri+";$dom"
	}
	if($All_Others) 
	{ 
		if($AtTime) { return "We cannot pass All_Others in At Time report." }			
		$uri = $uri+";sys:all_others"
	}	
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}		
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	write-host " uri = $uri"
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-QoSStatisticalReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-QoSStatisticalReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-QoSStatisticalReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-QoSStatisticalReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-QoSStatisticalReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-QoSStatisticalReports_WSAPI

############################################################################################################################################
## FUNCTION Get-RCopyStatisticalReports_WSAPI
############################################################################################################################################
Function Get-RCopyStatisticalReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Request Remote Copy statistical data using either Versus Time or At Time reports.
  
  .DESCRIPTION
	Request Remote Copy statistical data using either Versus Time or At Time reports.
        
  .EXAMPLE 
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires
        
  .EXAMPLE 	
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires -TargetName xxx
	        
  .EXAMPLE 
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires -NSP x:x:x
	        
  .EXAMPLE 
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires -NSP "x:x:x,x:x:x:
	        
  .EXAMPLE 
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires -Groupby "targetName,linkId"
  
  .EXAMPLE  
	Get-RCopyStatisticalReports_WSAPI -VersusTime -Frequency_Hires
	
  .EXAMPLE
	Get-RCopyStatisticalReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-RCopyStatisticalReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-RCopyStatisticalReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
		
  .PARAMETER VersusTime
	Request port statistics report using Versus Time reports.
	
  .PARAMETER AtTime
	Request port statistics report using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily

  .PARAMETER TargetName
	Specify the target from which to gather Remote Copy statistics. Separate multiple target names using a comma (,). 
	With no target specified, the request calculates Remote Copy statistics for all targets in the system. Use the structure, targetName:<target1>,<target2> . . .

  .PARAMETER NSP
	Specify the port from which to gather Remote Copy statistics. Separate multiple port positions with a
	comma (,) Use the structure, <n:s:p>,<n:s:p> . . .. With no port specified, the request
	calculates Remote Copy statistics for all ports in the system.
	
  .PARAMETER Groupby
	Group Remote Copy statistical data into categories. With no groupby parameter specified, the system groups the data into all categories. 
	Separate multiple groups with a comma (,). Use the structure,
	groupby:targetName,linkId,linkAddr,node,slotPort,cardPort.  
	
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from 
	kbs : Kilobytes.
	kbps : Kilobytes per second.
	hbrttms : Round trip time for a heartbeat message on the link.
	targetName : Name of the Remote Copy target created with creatercopytarget.
	linkId : ID of the Remote Copy target created with creatercopytarget.
	linkAddr : Address (IP or FC) of the Remote Copy target created with creatercopytarget.
	node : Node number for the port used by a Remote Copy link.
	slotPort : PCI slot number for the port used by a Remote Copy link.
	cardPort : Port number for the port used by a Remote Copy link.

  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-RCopyStatisticalReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-RCopyStatisticalReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/remotecopystatistics/'+$Frequency
	
	if($TargetName)	{ if($AtTime) { return "We cannot pass TargetName in At Time report." } $uri = $uri+";targetName:$TargetName" }
	if($NSP)	{ if($AtTime) { return "We cannot pass NSP in At Time report." } $uri = $uri+";portPos:$NSP" }
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}		
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-RCopyStatisticalReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-RCopyStatisticalReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-RCopyStatisticalReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-RCopyStatisticalReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-RCopyStatisticalReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-RCopyStatisticalReports_WSAPI


############################################################################################################################################
## FUNCTION Get-RCopyVolumeStatisticalReports_WSAPI
############################################################################################################################################
Function Get-RCopyVolumeStatisticalReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Request statistical data related to Remote Copy volumes using either Versus Time or At Time reports.
  
  .DESCRIPTION
	Request statistical data related to Remote Copy volumes using either Versus Time or At Time reports.
        
  .EXAMPLE 
	Get-RCopyVolumeStatisticalReports_WSAPI -AtTime -Frequency_Hires
  
  .EXAMPLE  
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hires
	  
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hires -vvName xxx
	  
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hires -vvName "xxx,xxx"
	  
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hires -TargetName xxx
	  
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hires -TargetName "xxx,xxx"
	  
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hires -Mode SYNC
	  
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hires -RCopyGroup xxx
	  
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hires -Groupby domain
	  
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hires -Groupby "domain,targetNamex"
	
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-RCopyVolumeStatisticalReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
		
  .PARAMETER VersusTime
	Request port statistics report using Versus Time reports.
	
  .PARAMETER AtTime
	Request port statistics report using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily

  .PARAMETER vvName
	Specify the name of the volume from which to gather Remote Copy volume statistics. Separate multiple
	names with a comma (,) Use <vvname1>,<vvname2> . . .. To specify the name of a set of volumes, use set:<vvsetname>.
  
  .PARAMETER TargetName
	Specify the target from which to gather Remote Copy volume statistics. Separate multiple target names using a comma (,). 
	With no target specified, the request calculates Remote Copy volume statistics for all targets in the system.

  .PARAMETER Mode
	Specify the mode of the target from which to gather Remote Copy volume statistics.
	SYNC : Remote Copy group mode is synchronous.
	PERIODIC : Remote Copy group mode is periodic. Although WSAPI 1.5 and later supports PERIODIC 2, Hewlett Packard Enterprise	recommends using PERIODIC 3.
	PERIODIC : Remote Copy group mode is periodic.
	ASYNC : Remote Copy group mode is asynchronous.
	
  .PARAMETER RCopyGroup	
	Specify the remote copy group from which to gather Remote Copy volume statistics. Separate multiple group names using a comma (,).
	With no remote copy group specified, the request calculates remote copy volume statistics for all remote copy groups in the system.
	
  .PARAMETER Groupby
	Group the Remote Copy volume statistical data into categories. With no groupby parameter specified,the system groups the data into all categories. 
	Separate multiple groups with a comma (,). Use the structure,groupby:volumeName,volumeSetName,domain,targetName,mode,remoteCopyGroup,remote CopyGroupRole,node,slot,cardPort,portType.
      
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from 
	readIOLocal : Local read input/output operations per second.
	writeIOLocal : Local write input/output operations per second.
	IOLocal : Local total input/output operations per second.
	readKBytesLocal : Local read kilobytes.
	writeKBytesLocal : Local write kilobytes.
	KBytesLocal : Local total kilobytes.
	readServiceTimeMSLocal : Local read service time in milliseconds.
	writeServiceTimeMSLocal : Local write service time in milliseconds.
	ServiceTimeMSLocal : Local total service time in milliseconds.
	readIOSizeKBLocal : Local read IO size in kilobytes.
	writeIOSizeKBLocal : Local write IO size in kilobytes.
	IOSizeKBLocal : Local total IO size in kilobytes.
	busyPctLocal : Local busy Percentage.
	queueLengthLocal : Local queue length.
	readIORemote : Remote read input/output operations per second.
	wirteIORemote : Remote write input/output operations per second.
	IORemote : Remote total input/output operations per second.
	readKBytesRemote : Remote read kilobytes.
	writeKBytesRemote : Remote write kilobytes.
	KBytesRemote : Remote total kilobytes.
	readServiceTimeMSRemote : Remote read service time in milliseconds.
	writeServiceTimeMSRemote : Remote write service time in milliseconds.
	ServiceTimeMSRemote : Remote total service time in milliseconds.
	readIOSizeKBRemote : Remote read IO size in kilobytes.
	writeIOSizeKBRemote : Remote write IO size in kilobytes.
	IOSizeKBRemote : Remote total IO size in kilobytes.
	busyPctRemote : Remote busy Percentage.
	queueLengthRemote : Remote queue length.
	RPO : Recovery point objective.	
	
  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-RCopyVolumeStatisticalReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-RCopyVolumeStatisticalReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $vvName,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $TargetName,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Mode,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $RCopyGroup,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=16, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
	
	#Build uri
	$uri = '/systemreporter/'+$Action+'/remotecopyvolumestatistics/'+$Frequency
		
	if($vvName)	{ if($AtTime) { return "We cannot pass vvName in At Time report." } $uri = $uri+";volumeName:$vvName" }
	if($TargetName)	{ if($AtTime) { return "We cannot pass TargetName in At Time report." } $uri = $uri+";targetName:$TargetName" }
	If ($Mode) 
	{
		if($AtTime) { return "We cannot pass Mode in At Time report." }
		if($Mode.ToUpper() -eq "SYNC") { $uri = $uri+";mode:1" }
		elseif($Mode.ToUpper() -eq "PERIODIC"){	$uri = $uri+";mode:3" }
		elseif($Mode.ToUpper() -eq "ASYNC") { $uri = $uri+";mode:4" }
		else 
		{ 
			Write-DebugLog "Stop: Exiting Since -Mode $Mode in incorrect "
			Return "FAILURE : -Mode :- $Mode is an Incorrect Mode  [ SYNC | PERIODIC | ASYNC ] can be used only . "
		}
    }
	if($RCopyGroup)	{ if($AtTime) { return "We cannot pass RCopyGroup in At Time report." } $uri = $uri+";remoteCopyGroup:$RCopyGroup" }		
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}		
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-RCopyVolumeStatisticalReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-RCopyVolumeStatisticalReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-RCopyVolumeStatisticalReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-RCopyVolumeStatisticalReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-RCopyVolumeStatisticalReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-RCopyVolumeStatisticalReports_WSAPI

############################################################################################################################################
## FUNCTION Get-vLunStatisticsReports_WSAPI
############################################################################################################################################
Function Get-vLunStatisticsReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Request VLUN statistics data using either Versus Time or At Time reports.
  
  .DESCRIPTION
	Request VLUN statistics data using either Versus Time or At Time reports.
        
  .EXAMPLE 
	Get-vLunStatisticsReports_WSAPI -AtTime -Frequency_Hires
  
  .EXAMPLE  
	Get-vLunStatisticsReports_WSAPI -VersusTime -Frequency_Hires
	  
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -VersusTime -Frequency_Hires -VlunId 1
	  
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -AtTime -Frequency_Hires -VlunId "1,2"
	  
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -VersusTime -Frequency_Hires -VvName Test
	  
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -AtTime -Frequency_Hourly -VvSetName asvvset
	  
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -VersusTime -Frequency_Hourly -NSP "1:0:1"
	  
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -VersusTime -Frequency_Daily -HostName asHost
	  
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -VersusTime -Frequency_Daily -HostSetName asHostSet
	  
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -VersusTime -Frequency_Daily -Groupby "domain,volumeName"
	
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-vLunStatisticsReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
		
  .PARAMETER VersusTime
	Request VLUNstatistics data using Versus Time reports.
	
  .PARAMETER AtTime
	Request VLUN statistics data using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily

  .PARAMETER VlunId
	Requests data for the specified VLUNs only. For example, specify lun:1,2,4. With no lun specified, the system calculates performance data for all VLUNs in the system
  
  .PARAMETER VvName
	Retrieves data for the specified volume or volumeset only. Specify the volumeset as volumeName:set:<vvset_name>. With no volumeName specified, the system calculates VLUN performance data for all the VLUNs in the system.
  
  .PARAMETER HostName
	Retrieves data for the specified host or hostset only. Specify the hostset as hostname:set:<hostset_name>. With no hostname specified, the system calculates VLUN performance data for all the hosts in the system.

  .PARAMETER VvSetName
	Specify the VV set name.
  
  .PARAMETER HostSetName
	Specify the Host Set Name.
  
  .PARAMETER NSP
	Retrieves data for the specified ports. For example, specify portPos: 1:0:1,2:1:3,6:2:1. With no portPos specified, the system calculates VLUN performance data for all ports in the system.
  
  .PARAMETER Groupby
	domain | volumeName | hostname| lun | hostWWN | node | slot | vvsetName | hostsetName | cardPort
	Groups sample data into specified categories. With no category specified, the system groups data into all categories. To specify multiple groupby categories, separate them using a comma (,). For example, slot,cardPort,type.
    
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	totalIOPs : Total IOPs.
  
  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-vLunStatisticsReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-vLunStatisticsReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VlunId,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VvName,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $HostName,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VvSetName,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $HostSetName,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $NSP,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  	  
	  [Parameter(Position=16, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=17, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=18, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
		
	#Build uri
	$uri = '/systemreporter/'+$Action+'/vlunstatistics/'+$Frequency
		
	if($VlunId) { if($AtTime) { return "We cannot pass VlunId in At Time report." } $uri = $uri+";lun:$VlunId"}
	if($VvName) { if($AtTime) { return "We cannot pass VvName in At Time report." } $uri = $uri+";volumeName:$VvName"}
	if($HostName) { if($AtTime) { return "We cannot pass HostName in At Time report." } $uri = $uri+";hostname:$HostName"}
	if($VvSetName) { if($AtTime) { return "We cannot pass VvSetName in At Time report." } $uri = $uri+";volumeName:set:$VvSetName"}
	if($HostSetName) { if($AtTime) { return "We cannot pass HostSetName in At Time report." } $uri = $uri+";hostname:set:$HostSetName"}
	if($NSP) { if($AtTime) { return "We cannot pass NSP in At Time report." } $uri = $uri+";portPos:$NSP"}	
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}
		
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	#write-host "URL = $uri"
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-vLunStatisticsReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-vLunStatisticsReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-vLunStatisticsReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-vLunStatisticsReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-vLunStatisticsReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-vLunStatisticsReports_WSAPI

############################################################################################################################################
## FUNCTION Get-VvSpaceReports_WSAPI
############################################################################################################################################
Function Get-VvSpaceReports_WSAPI 
{
  <#
   
  .SYNOPSIS	
	Request volume space data using either Versus Time or At Time reports.
  
  .DESCRIPTION
	Request volume space data using either Versus Time or At Time reports.
        
  .EXAMPLE 
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires
  
  .EXAMPLE  
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Hires
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Hires -VvName xxx
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Hires -VvSetName asVVSet
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Hires -UserCPG ascpg
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Hires -SnapCPG assnpcpg
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Hires -ProvType 1
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Hires -Groupby id
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Hires -Groupby "id,name"
	
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -VvName xxx
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -VvSetName asVVSet
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -UserCPG ascpg
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -SnapCPG assnpcpg
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -ProvType 1
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -Groupby id
	        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -Groupby "id,name"
	
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Hourly -Summary max
	
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -Summary max
  
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
	
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
        
  .EXAMPLE
	Get-VvSpaceReports_WSAPI -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
		
  .PARAMETER VersusTime
	Request  volume space data using Versus Time reports.
	
  .PARAMETER AtTime
	Request  volume space data using At Time reports.
	
  .PARAMETER Frequency_Hires
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• hires—based on 5 minutes (high resolution)
		
  .PARAMETER Frequency_Hourly
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:	
	• hourly
	
  .PARAMETER Frequency_Daily
	As part of the report identifier, you must specify one <samplefreq> parameter. The <samplefreq> parameter indicates how often to generate the performance sample data. You may specify only one.
	Options are:
	• daily

  .PARAMETER VvName
	Requests volume space sample data for the specified volume (vv_name) or volume set (vvset_name) only. Specify vvset as name:set:<vvset_name>. With no name specified, the system calculates volume space data for all volumes in the system.
  
  .PARAMETER VvSetName
	Requests volume space sample data for the specified volume (vv_name) or volume set (vvset_name) only.
  
  .PARAMETER UserCPG
	Retrieves volume space data for the specified userCPG volumes only. With no userCPG specified, the system calculates space data for all volumes in the system.
  
  .PARAMETER SnapCPG
	Retrieves space data for the specified snapCPG volumes only. With no snapCPG specified, the system calculates space data for all volumes in the system.
  
  .PARAMETER ProvType
	Retrieves space data for volumes that match the specified . With no provtype specified, the system calculates space data for all volumes in the system.
  
  .PARAMETER Groupby
	id | name | baseId | wwn | snapCPG | userCPG
	Optional parameter that groups sample data into specified categories. With no category specified, the system groups data into all categories. To specify multiple groupby categories, separate them using a comma (,). For example: domain,id,name,baseId,WWN.
      
  .PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
	
	Optional
	perTime : When requesting data across multiple points in time(vstime) using multiple object groupings (groupby), use the perTime field name to compute 	summaries. Defaults to one summary computed across all records. Use this with the groupby field only.
	perGroup : When requesting data across multiple points in time,(vstime) using multiple object groupings (groupby),use the perGroup field name to compute summaries per object grouping. Defaults to one summary computed across all records.
	onlyCompareby : When using the compareby field to request data limited to certain object groupings, use this field name to compute summaries using only that reduced set of object groupings. Defaults to computing summaries from all records and ignores the limitation of the compareby option.
	
  .PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.

  .PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	
  .PARAMETER ComparebyField
	please select any one from
	totalSpaceUsedMiB : Total used space in MiB.
	userSpaceUsedMiB : Used user space in MiB.
	snapshotSpaceUsedMiB : Used snapshot space in MiB
	userSpaceFreeMiB : Free user space in MiB.
	snapshotSpaceFreeMiB : Free snapshot space in MiB.
	compaction : Compaction ratio.
	compression : Compression ratio.

  .PARAMETER GETime
	Gerater thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER LETime
	Lase thane time For At Time query expressions, you can use the sampleTime parameter
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-VvSpaceReports_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-VvSpaceReports_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $VersusTime,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $AtTime,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hires,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Hourly,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Frequency_Daily,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VvName,
	  
	  [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VvSetName,
	  
	  [Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $UserCPG,
	  
	  [Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $SnapCPG,
	  
	  [Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ProvType,
	  
	  [Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Groupby,
	  
	  [Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Summary,
	  
	  [Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Compareby,
	  
	  [Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
      [int]
	  $NoOfRecords,
	  
	  [Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $ComparebyField,
	  	  
	  [Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $GETime,
	  
	  [Parameter(Position=16, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $LETime,
	  
	  [Parameter(Position=17, Mandatory=$false, ValueFromPipeline=$true)]
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
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	
	if($VersusTime)	{	$Action = "vstime"	}	elseif($AtTime)	{	$Action = "attime"	}	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	
	if($Frequency_Hires){	$Frequency = "hires"	}	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} elseif($Frequency_Daily)	{	$Frequency = "daily"	}	else{ Return "Please select Frequency it is mandatory" }
		
	#Build uri
	$uri = '/systemreporter/'+$Action+'/volumespacedata/'+$Frequency
		
	if($VvName) { if($AtTime) { return "We cannot pass VvName in At Time report." } $uri = $uri+";name:$VvName"}
	if($VvSetName) { if($AtTime) { return "We cannot pass VvSetName in At Time report." } $uri = $uri+";name:set:$VvSetName"}
	if($UserCPG) { if($AtTime) { return "We cannot pass UserCPG in At Time report." } $uri = $uri+";userCPG:$UserCPG"}
	if($SnapCPG) { if($AtTime) { return "We cannot pass SnapCPG in At Time report." } $uri = $uri+";snapCPG:$SnapCPG"}
	if($ProvType) { if($AtTime) { return "We cannot pass ProvType in At Time report." } $uri = $uri+";provType:$ProvType"}		
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{ 
		$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")
		{
			$uri = $uri+";compareby:$cmpVal,"
		}
		else
		{
			return "Compareby should be either top or bottom"
		}
		if($NoOfRecords)
		{
			$uri = $uri+$NoOfRecords+","
		}
		else
		{
			return "NoOfRecords is mandatory with Compareby. "
		}
		if($ComparebyField)
		{
			$uri = $uri+$ComparebyField
		}
		else
		{
			return "ComparebyField is mandatory with Compareby.please see the parameter help for this"
		}		
	}
		
	if($GETime)
	{		
		$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
		
		if($LETime)
		{
			$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
			$flg = "No"
		}
		$addQuery = "Yes"
	}
	if($LETime)
	{
		if($flg -eq "Yes")
		{
			$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
		}
		$addQuery = "Yes"		
	}
	
	if($addQuery -eq "Yes")
	{
		$uri = $uri+$Query
	}
	
	#write-host "URL = $uri"
	
	#Request
	$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		$dataPS = ($Result.content | ConvertFrom-Json).members	
	}		
		  
	if($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-VvSpaceReports_WSAPI Successfully Executed" $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-VvSpaceReports_WSAPI. Expected Result Not Found with Given Filter Option ." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-VvSpaceReports_WSAPI. Expected Result Not Found with Given Filter Option." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-VvSpaceReports_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-VvSpaceReports_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}
#END Get-VvSpaceReports_WSAPI


############################################################################################################################################
## FUNCTION Add-DiskType
############################################################################################################################################
Function Add-DiskType
{
<#
  .SYNOPSIS
    find and add disk type to temp variable.
  
  .DESCRIPTION
    find and add disk type to temp variable. 
        
  .EXAMPLE
    Add-DiskType -Dt $td

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME:  Add-DiskType  
    LASTEDIT: 25/09/2018
    KEYWORDS: CmdList
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
 [CmdletBinding()]
	param
	(
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$DT,

		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		$WsapiConnection = $global:WsapiConnection
	)
	Begin 
	{
		# Test if connection exist
		Test-WSAPIConnection -WsapiConnection $WsapiConnection
	}
	Process 
	{
		$lista = $DT.split(",")		
		$count = 1
		[string]$DTyp
		foreach($sub in $lista)
		{
			$val_Fix = "FC","NL","SSD","SCM"
			$val_Input =$sub
			if($val_Fix -eq $val_Input)
			{
				if($val_Input.ToUpper() -eq "FC")
				{
					$DTyp = $DTyp + "1"
				}
				if($val_Input.ToUpper() -eq "NL")
				{
					$DTyp = $DTyp + "2"
				}
				if($val_Input.ToUpper() -eq "SSD")
				{
					$DTyp = $DTyp + "3"
				}
				if($val_Input.ToUpper() -eq "SCM")
				{
					$DTyp = $DTyp + "4"
				}
				if($lista.Count -gt 1)
				{
					if($lista.Count -ne $count)
					{					
						$DTyp = $DTyp + ","
						$count = $count + 1
					}				
				}
			}
			else
			{ 
				Write-DebugLog "Stop: Exiting Since -DiskType $DT in incorrect "
				Return "FAILURE : -DiskType :- $DT is an Incorrect, Please Use [ FC | NL | SSD | SCM] only ."
			}						
		}
		return $DTyp.Trim()		
	}
	End {  }
 }# Ended Add-DiskType
 
############################################################################################################################################
## FUNCTION Add-RedType
############################################################################################################################################
Function Add-RedType
{
<#
  .SYNOPSIS
    find and add Red type to temp variable.
  
  .DESCRIPTION
    find and add Red type to temp variable. 
        
  .EXAMPLE
    Add-RedType -RT $td

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME:  Add-RedType  
    LASTEDIT: 25/09/2018
    KEYWORDS: CmdList
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
 [CmdletBinding()]
	param
	(
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$RT,

		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		$WsapiConnection = $global:WsapiConnection
	)
	Begin 
	{
		# Test if connection exist
		Test-WSAPIConnection -WsapiConnection $WsapiConnection
	}
	Process 
	{
		$lista = $RT.split(",")		
		$count = 1
		[string]$RType
		foreach($sub in $lista)
		{
			$val_Fix = "R0","R1","R5","R6"
			$val_Input =$sub
			if($val_Fix -eq $val_Input)
			{
				if($val_Input.ToUpper() -eq "R0")
				{
					$RType = $RType + "1"
				}
				if($val_Input.ToUpper() -eq "R1")
				{
					$RType = $RType + "2"
				}
				if($val_Input.ToUpper() -eq "R5")
				{
					$RType = $RType + "3"
				}
				if($val_Input.ToUpper() -eq "R6")
				{
					$RType = $RType + "4"
				}
				if($lista.Count -gt 1)
				{
					if($lista.Count -ne $count)
					{					
						$RType = $RType + ","
						$count = $count + 1
					}				
				}
			}
			else
			{ 
				Write-DebugLog "Stop: Exiting Since -RedType $RT in incorrect "
				Return "FAILURE : -RedType :- $RT is an Incorrect, Please Use [ R0 | R1 | R5 | R6 ] only ."
			}						
		}
		return $RType.Trim()		
	}
	End {  }
 }# Ended Add-RedType

Export-ModuleMember Get-CacheMemoryStatisticsDataReports_WSAPI , Get-CPGSpaceDataReports_WSAPI , Get-CPGStatisticalDataReports_WSAPI , Get-CPUStatisticalDataReports_WSAPI ,
Get-PDCapacityReports_WSAPI , Get-PDStatisticsReports_WSAPI , Get-PDSpaceReports_WSAPI , Get-PortStatisticsReports_WSAPI , Get-QoSStatisticalReports_WSAPI ,
Get-RCopyStatisticalReports_WSAPI , Get-VvSpaceReports_WSAPI , Get-vLunStatisticsReports_WSAPI , Get-RCopyVolumeStatisticalReports_WSAPI
# SIG # Begin signature block
# MIIhEAYJKoZIhvcNAQcCoIIhATCCIP0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCALuoa1btsH/McR
# hUAxd3ja7B6cIYwWvV7JURz7EIm8AKCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPuzCCD7cCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# 3iaXI7OX6rXblle3Kr3WBu7H75cc3wdPdedLrvUCG+AwDQYJKoZIhvcNAQEBBQAE
# ggEANC21/jhWhtnRg8Ukc99JMU1F9NIpddiLhwO3YffkHiltwRblZGByA540hbzp
# aopEgwy4JCPOnOTerQsFxxPDQfvYqDZPgbGMwhdvV4RLf/QgkE4lqwv9YiXJlCeu
# 8LzQSBPA3Uz1gLYQSDj9v7l7UTDYWwAxKJltFgytj5stfp6OdkN5mDpxxSd+7XNV
# XSje8kVZteHRnU3fPZ0BHukq7eve2mRa1vB+FJurIZ/6B3w4+2YhPw4Ev0hPplE/
# ErCIDSSk1llye34U9D1y1IGR8X5WODPrgnPY8mLB8qWxSX/3p8OE1iFPR6uxC9vh
# zI166yYCWuYPueF/pwxm1LvN1KGCDX0wgg15BgorBgEEAYI3AwMBMYINaTCCDWUG
# CSqGSIb3DQEHAqCCDVYwgg1SAgEDMQ8wDQYJYIZIAWUDBAIBBQAwdwYLKoZIhvcN
# AQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCCeH1i6
# TOzZOcQuHCkBGINPEyNCEv2+VsbJZgqOt5N5PwIQdVxNsvMAOQ3my7fha63nXhgP
# MjAyMTA2MTkwNTI3MDhaoIIKNzCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA
# 8N0wDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAxMDEw
# MDAwMDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjEw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXKY2tR
# 1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj/TZq
# gfop+N0rcIXeAhjzeG28ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj
# 4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDrDo4s
# 1SPa9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDC
# m2mCtNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1JhL0B
# AgMBAAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATApMCcG
# CCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgw
# FoAU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwoLR1E
# Nt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9zaGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdpY2Vy
# dC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURU
# aW1lc3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrn
# IA6OZ0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQCZk3t
# aaQP9rhwz2Lo9VFKeHk2eie38+dSn5On7UOee+e03UEiifuHokYDTvz0/rdkd2Nf
# I1Jpg4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO+MDh
# XM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j1h9b
# m/cuG08THfdKDXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5Npjhyyja
# W4emii8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHkBdo2l8IVMA0GCSqGSIb3DQEB
# CwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQg
# SUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0zMTAxMDcxMjAwMDBaMHIxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBU
# aW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9
# 0DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5fU1ofue2oPSNs4jkl79jIZCY
# vxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb6+NGRwYaVX4LJ37AovWg4N4i
# Pw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU46gJcWvgzyIQD3XPcXJOCq3f
# QDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mIUF79Zm5WYScpiYRR5oLnRlD9
# lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfxFwbvPc3WTe8GQv2iUypPhR3E
# HTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAdBgNVHQ4EFgQU9LbhIB3+Ka7S
# 5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wEgYD
# VR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4
# oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkwRzA4BgpghkgBhv1sAAIEMCow
# KAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJYIZI
# AYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLpUYdWac3v3dp8qmN6s3jPBjdA
# hO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4
# stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC4HLHmNY8ZOUfSBAYX4k4YU1i
# RiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+tpJn+1Nhiaj1a5bA9FhpDXzI
# AbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6HUSHkWGCbugwtK22ixH67xCUr
# RwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIvIjayS6JKldj1po5SMYIChjCC
# AoICAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hB
# MiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TAN
# BglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJ
# KoZIhvcNAQkFMQ8XDTIxMDYxOTA1MjcwOFowKwYLKoZIhvcNAQkQAgwxHDAaMBgw
# FgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJKoZIhvcNAQkEMSIEINXp1cfZlinG
# ynTD597fTnRy8kiAsjGofTwWR36gy8PgMDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIE
# ILMQkAa8CtmDB5FXKeBEA0Fcg+MpK2FPJpZMjTVx7PWpMA0GCSqGSIb3DQEBAQUA
# BIIBAHpG2PiKBo0TAYsHm9pkm7vRDa0FkOeP6IUAB8TUOyaz8iUl6eiRV/1RtKal
# AOfilbdPt8BwHbkQ1ZPg7OG4XZycpRL78H2QKXJEvjVap702JhZEu/bvObsZ6NQP
# 7vX16j06KKw5c6b9A878D7wdNk2bwLK/YcyBPIQ4gH+DCQmtN5g+ZL1Na8nUYOzq
# JZJUcPjtPKatGxtL2t5vgQurvlawd5YUSWatPPgqX5rXeNUk5AHupTWhCdY6hgSz
# UhJNuhN0g5ZaRABiWL5MykBc8hs2JiE4bclMUkbbyN9r0tswva7PTOR1PZTsPgqE
# oXoFBfviEveIom58TdRi6gc+oQI=
# SIG # End signature block
