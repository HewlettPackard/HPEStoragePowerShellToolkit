﻿####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##	Description: 	System Reporter cmdlets 

Function Get-A9CacheMemoryStatisticsDataReports 
{
<#
.SYNOPSIS	
	Cache memory statistics data reports
.DESCRIPTION
	Cache memory statistics data reports.Request cache memory statistics data using either Versus Time or At Time reports.
.EXAMPLE	
	PS:> Get-A9CacheMemoryStatisticsDataReports -VersusTime -Frequency_Hires
.EXAMPLE	
	PS:> Get-A9CacheMemoryStatisticsDataReports -AtTime -Frequency_Hires
.EXAMPLE	
	PS:> Get-A9CacheMemoryStatisticsDataReports -VersusTime -Frequency_Hires -NodeId 1
.EXAMPLE	
	PS:> Get-A9CacheMemoryStatisticsDataReports -VersusTime -Frequency_Hires -NodeId "1,2,3"
.EXAMPLE
	PS:> Get-A9CacheMemoryStatisticsDataReports -VersusTime -Frequency_Hires -Groupby node
.EXAMPLE
	PS:> Get-A9CacheMemoryStatisticsDataReports -AtTime -Frequency_Hires -NodeId 1
.EXAMPLE
	PS:> Get-A9CacheMemoryStatisticsDataReports -AtTime -Frequency_Hires -NodeId "1,2,3"
.EXAMPLE
	PS:> Get-A9CacheMemoryStatisticsDataReports -AtTime -Frequency_Hires -Groupby node
.EXAMPLE
	PS:> Get-A9CacheMemoryStatisticsDataReports -VersusTime -Frequency_Hires -Summary min
.EXAMPLE
	PS:> Get-A9CacheMemoryStatisticsDataReports -VersusTime -Frequency_Hires -Compareby top -NoOfRecords 2 -ComparebyField hitIORead
.EXAMPLE	
	PS:> Get-A9CacheMemoryStatisticsDataReports -VersusTime -Frequency_Hires -GETime 2018-07-18T13:20:00+05:30 -LETime 2018-07-18T13:25:00+05:30  
.EXAMPLE
	PS:> Get-A9CacheMemoryStatisticsDataReports -VersusTime -Frequency_Hires -GETime 2018-07-18T13:20:00+05:30 
.EXAMPLE
	PS:> Get-A9CacheMemoryStatisticsDataReports -VersusTime -Frequency_Hires -LETime 2018-07-18T13:25:00+05:30  
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$NodeId,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,		
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)				{	$Action = "vstime"	}	
	elseif($AtTime)				{	$Action = "attime"	}	
	else						{	Return "Please Select atlist any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires)		{	$Frequency = "hires"	}	
	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} 
	elseif($Frequency_Daily)	{	$Frequency = "daily"	}	
	else						{ Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/cachememorystatistics/'+$Frequency
	if($NodeId) 			
		{ 	if($AtTime) 		{ return "We cannot pass node values in At Time report." } 
			$uri = $uri+";node:$NodeId"
		}
	if($Groupby) 				{ $uri = $uri+";groupby:$Groupby"}
	if($Summary) 				{ $uri = $uri+";summary:$Summary"}
	if($Compareby)
		{ 	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else				{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
			else				{	return "NoOfRecords is mandatory with Compareby. "	}
			if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
			else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}	
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
			{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
				$flg = "No"
			}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")		{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members	
		}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing PS:> Get-A9CacheMemoryStatisticsDataReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-A9CacheMemoryStatisticsDataReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9CPGSpaceDataReports
{
<#
.SYNOPSIS	
	CPG space data using either Versus Time or At Time reports.
.DESCRIPTION
	CPG space data using either Versus Time or At Time reports..
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires -CpgName xxx
.EXAMPLE	
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires -DiskType FC
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires -DiskType "FC,LN,SSD"
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires -RAIDType R1
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires -RAIDType "R1,R2"
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires -Groupby "id,diskType,RAIDType"
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -AtTime -Frequency_Hires -CpgName xxx
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -AtTime -Frequency_Hires -DiskType FC
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -AtTime -Frequency_Hires -DiskType "FC,NL"
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -AtTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE	
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires -GETime 2018-07-18T13:20:00+05:30 -LETime 2018-07-18T13:25:00+05:30  
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires -GETime 2018-07-18T13:20:00+05:30 
.EXAMPLE
	PS:> Get-A9CPGSpaceDataReports -VersusTime -Frequency_Hires -LETime 2018-07-18T13:25:00+05:30
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$CpgName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$DiskType,
		[Parameter(ValueFromPipeline=$true)]	[String]	$RAIDType,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,	
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)			{	$Action = "vstime"	}	
	elseif($AtTime)			{	$Action = "attime"	}	
	else					{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires)	{	$Frequency = "hires"	}	
	elseif($Frequency_Hourly){	$Frequency = "hourly"	} 
	elseif($Frequency_Daily){	$Frequency = "daily"	}	
	else					{ Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/cpgspacedata/'+$Frequency
	if($CpgName) 
		{ 	if($AtTime) { 	return "We cannot pass CpgName in At Time report." } 
			$uri = $uri+";name:$CpgName"
		}
	if($DiskType) 
		{	if($AtTime)	{ return "We cannot pass DiskType in At Time report." }
			[String]$DislTV = ""
			$DislTV = Add-DiskType -DT $DiskType		
			$uri = $uri+";diskType:"+$DislTV.Trim()
		}
	if($RAIDType) 
		{	if($AtTime) { return "We cannot pass RAIDType in At Time report." }
			[String]$RedTV = ""
			$RedTV = Add-RedType -RT $RAIDType		
			$uri = $uri+";RAIDType:"+$RedTV.Trim()	
		}
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
	if($Compareby)
		{	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else											{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)								{	$uri = $uri+$NoOfRecords+","	}
			else											{	return "NoOfRecords is mandatory with Compareby. "	}
			if($ComparebyField)								{	$uri = $uri+$ComparebyField	}
			else											{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")	{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members	
		}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-CPGSpaceDataReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-CPGSpaceDataReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9CPGStatisticalDataReports 
{	
<#
.SYNOPSIS	
	CPG statistical data using either Versus Time or At Time reports.
.DESCRIPTION
	CPG statistical data using either Versus Time or At Time reports.
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -VersusTime -Frequency_Hourly
.EXAMPLE	
	PS:> Get-A9CPGStatisticalDataReports -VersusTime -Frequency_Hires -CpgName $cpg
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -VersusTime -Frequency_Hires -Groupby name
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -AtTime -Frequency_Hourly
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -AtTime -Frequency_Hires -CpgName $cpg
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -AtTime -Frequency_Hires -Groupby name
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -VersusTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -VersusTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -VersusTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9CPGStatisticalDataReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$CpgName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)				{	$Action = "vstime"	}	
	elseif($AtTime)				{	$Action = "attime"	}	
	else						{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires)		{	$Frequency = "hires"	}	
	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} 
	elseif($Frequency_Daily)	{	$Frequency = "daily"	}	
	else						{ Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/cpgstatistics/'+$Frequency
	if($CpgName) 
		{ 	if($AtTime) 	{ 	return "We cannot pass CpgName in At Time report." 	}
			$uri = $uri+";name:$CpgName"}	
	if($Groupby) 	{  $uri = $uri+";groupby:$Groupby"}
	if($Summary) 	{ 	$uri = $uri+";summary:$Summary"}
    if($Compareby)	
		{ 	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else											{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
			else				{	return "NoOfRecords is mandatory with Compareby. "	}
			if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
			else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")		{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-CPGStatisticalDataReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-CPGStatisticalDataReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9CPUStatisticalDataReports 
{
<#
.SYNOPSIS	
	CPU statistical data reports.
.DESCRIPTION
	CPU statistical data reports.
.EXAMPLE 
	PS:> Get-A9CPUStatisticalDataReports -AtTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9CPUStatisticalDataReports -VersusTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9CPUStatisticalDataReports -VersusTime -Frequency_Hires -NodeId 1
.EXAMPLE  
	PS:> Get-A9CPUStatisticalDataReports -VersusTime -Frequency_Hires -Groupby cpu
.EXAMPLE
	PS:> Get-A9CPUStatisticalDataReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9CPUStatisticalDataReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9CPUStatisticalDataReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9CPUStatisticalDataReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9CPUStatisticalDataReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPUStatisticalDataReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPUStatisticalDataReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$NodeId,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)				{	$Action = "vstime"	}	
	elseif($AtTime)				{	$Action = "attime"	}	
	else						{	Return "Please Select atlist any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires)		{	$Frequency = "hires"	}	
	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} 
	elseif($Frequency_Daily)	{	$Frequency = "daily"	}	
	else						{ Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/cpustatistics/'+$Frequency
	if($NodeId) 	
		{ 	if($AtTime) { return "We cannot pass node values in At Time report." } 
			$uri = $uri+";node:$NodeId"
		}
	if($Groupby) 	{ $uri = $uri+";groupby:$Groupby"}
	if($Summary) 	{ $uri = $uri+";summary:$Summary"}
    if($Compareby)
		{	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else	{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
			else				{	return "NoOfRecords is mandatory with Compareby. "	}
			if($ComparebyField)	{	$uri = $uri+$ComparebyField }
			else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
				}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")
		{	$uri = $uri+$Query
		}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members	
		}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-CPUStatisticalDataReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-CPUStatisticalDataReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9PDCapacityReports 
{
<#
.SYNOPSIS	
	Physical disk capacity reports.
.DESCRIPTION
	Physical disk capacity reports.
.EXAMPLE 
	PS:> Get-A9PDCapacityReports -AtTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9PDCapacityReports -VersusTime -Frequency_Hires
.EXAMPLE 
	PS:> Get-A9PDCapacityReports -VersusTime -Frequency_Hires -Id 1
.EXAMPLE 
	PS:> Get-A9PDCapacityReports -VersusTime -Frequency_Hires -DiskType FC
.EXAMPLE 
	PS:> Get-A9PDCapacityReports -AtTime -Frequency_Hires -DiskType "FC,SSD"
.EXAMPLE 
	PS:> Get-A9PDCapacityReports -VersusTime -Frequency_Hires -Groupby id
.EXAMPLE 
	PS:> Get-A9PDCapacityReports -AtTime -Frequency_Hires -Groupby "id,type"
.EXAMPLE
	PS:> Get-A9PDCapacityReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9PDCapacityReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9PDCapacityReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PDCapacityReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PDCapacityReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PDCapacityReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PDCapacityReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Id,
		[Parameter(ValueFromPipeline=$true)]	[String]	$DiskType,
		[Parameter(ValueFromPipeline=$true)]	[String]	$RPM,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)				{	$Action = "vstime"	}	
	elseif($AtTime)				{	$Action = "attime"	}	
	else						{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires)		{	$Frequency = "hires"	}	
	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} 
	elseif($Frequency_Daily)	{	$Frequency = "daily"	}	
	else						{ Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/physicaldiskcapacity/'+$Frequency
	if($Id) 
		{ 	if($AtTime) 	{ 	return "We cannot pass Id in At Time report." } 
			$uri = $uri+";id:$Id"
		}
	if($DiskType) 
		{	if($AtTime)	{ return "We cannot pass DiskType in At Time report." }
			[String]$DislTV = ""
			$DislTV = Add-DiskType -DT $DiskType		
			$uri = $uri+";type:"+$DislTV.Trim()
		}	
	if($RPM) 
		{ 	if($AtTime) 	{ return "We cannot pass RPM in At Time report." } 
			$uri = $uri+";RPM:$RPM"
		}
	if($Groupby) 	{  	$uri = $uri+";groupby:$Groupby"}
	if($Summary) 	{ 	$uri = $uri+";summary:$Summary"}	
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")
				}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")		{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-PDCapacityReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-PDCapacityReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9PDStatisticsReports 
{
<#
.SYNOPSIS	
	physical disk statistics reports using either Versus Time or At Time reports.
.DESCRIPTION
	physical disk statistics reports using either Versus Time or At Time reports.
.EXAMPLE 
	PS:> Get-A9PDStatisticsReports -AtTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9PDStatisticsReports -AtTime  -VersusTime -Frequency_Hires
.EXAMPLE 
	PS:> Get-A9PDStatisticsReports -AtTime  -VersusTime -Frequency_Hires -Id 1
.EXAMPLE 
	PS:> Get-A9PDStatisticsReports -AtTime  -VersusTime -Frequency_Hires -DiskType FC
.EXAMPLE 
	PS:> Get-A9PDStatisticsReports -AtTime  -AtTime -Frequency_Hires -DiskType "FC,SSD"
.EXAMPLE	
	PS:> Get-A9PDStatisticsReports -AtTime  -VersusTime -Frequency_Hires -RPM 7
.EXAMPLE
	PS:> Get-A9PDStatisticsReports -AtTime  -AtTime -Frequency_Hires -RPM "7,10"
.EXAMPLE 
	PS:> Get-A9PDStatisticsReports -AtTime  -VersusTime -Frequency_Hires -Groupby id
.EXAMPLE 
	PS:> Get-A9PDStatisticsReports -AtTime  -AtTime -Frequency_Hires -Groupby "id,type"
.EXAMPLE
	PS:> Get-A9PDStatisticsReports -AtTime  -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9PDStatisticsReports -AtTime  -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9PDStatisticsReports -AtTime  -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PDStatisticsReports -AtTime  -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PDStatisticsReports -AtTime  -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PDStatisticsReports -AtTime  -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PDStatisticsReports -AtTime  -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Id,
		[Parameter(ValueFromPipeline=$true)]	[String]	$DiskType,
		[Parameter(ValueFromPipeline=$true)]	[String]	$RPM,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(mPipeline=$true)]			[int]		$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)			{	$Action = "vstime"	}	
	elseif($AtTime)			{	$Action = "attime"	}	
	else					{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }	
	if($Frequency_Hires)	{	$Frequency = "hires"	}	
	elseif($Frequency_Hourly){	$Frequency = "hourly"	} 
	elseif($Frequency_Daily){	$Frequency = "daily"	}	
	else					{ Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/physicaldiskstatistics/'+$Frequency
	if($Id) 
		{ 	if($AtTime) { return "We cannot pass Id in At Time report." } 
			$uri = $uri+";id:$Id"
		}
	if($DiskType) 
		{ 	if($AtTime) { return "We cannot pass DiskType in At Time report." } 
			$uri = $uri+";type:$DiskType"
		}
	if($RPM) 
		{ 	if($AtTime) { return "We cannot pass RPM in At Time report." } 
			$uri = $uri+";RPM:$RPM"
		}
	if($Groupby) 	{  $uri = $uri+";groupby:$Groupby"}
	if($Summary) 	{ $uri = $uri+";summary:$Summary"}
    if($Compareby)
		{ 	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else				{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
			else				{	return "NoOfRecords is mandatory with Compareby. "}
			if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
			else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}	
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")		{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
			{	write-host "Cmdlet executed successfully" -foreground green
				return $dataPS
			}
			else
			{	Write-Error "Failure:  While Executing Get-PDStatisticsReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
				return 
			}
		}
	else
		{	Write-Error "Failure:  While Executing Get-PDStatisticsReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9PDSpaceReports 
{
<#
.SYNOPSIS	
	Request physical disk space data reports using either Versus Time or At Time reports.
.DESCRIPTION
	Request physical disk space data reports using either Versus Time or At Time reports.
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -AtTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency_Hires
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency_Hires -Id 1
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency_Hires -DiskType FC
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -AtTime -Frequency_Hires -DiskType "FC,SSD"
.EXAMPLE	
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency_Hires -RPM 7
.EXAMPLE
	PS:> Get-A9PDSpaceReports -AtTime -Frequency_Hires -RPM "7,10"
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency_Hires -Groupby id
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -AtTime -Frequency_Hires -Groupby "id,cageID"
.EXAMPLE
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9PDSpaceReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PDSpaceReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PDSpaceReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PDSpaceReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PDSpaceReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Id,
		[Parameter(ValueFromPipeline=$true)]	[String]	$DiskType,
		[Parameter(ValueFromPipeline=$true)]	[String]	$RPM,	
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)			{	$Action = "vstime"	}	
	elseif($AtTime)			{	$Action = "attime"	}	
	else					{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires)	{	$Frequency = "hires"	}		
	elseif($Frequency_Hourly){	$Frequency = "hourly"	} 
	elseif($Frequency_Daily){	$Frequency = "daily"	}	
	else					{ 	Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/physicaldiskspacedata/'+$Frequency
	if($Id) 
		{ 	if($AtTime) { return "We cannot pass Id in At Time report." } 
			$uri = $uri+";id:$Id"
		}	
	if($DiskType) 
		{	if($AtTime)		{ return "We cannot pass DiskType in At Time report." }
			[String]$DislTV = ""
			$DislTV = Add-DiskType -DT $DiskType		
			$uri = $uri+";type:"+$DislTV.Trim()
		}
	if($RPM) { if($AtTime) { return "We cannot pass RPM in At Time report." } $uri = $uri+";RPM:$RPM"}
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
		{ 	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else				{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
			else				{	return "NoOfRecords is mandatory with Compareby. "	}
			if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
			else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}	
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")	{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members		}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-PDSpaceReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-PDSpaceReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9PortStatisticsReports
{
<#
.SYNOPSIS	
	Request a port statistics report using either Versus Time or At Time reports.
.DESCRIPTION
	Request a port statistics report using either Versus Time or At Time reports.
.EXAMPLE 
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hires
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hires -NSP "1:0:1"
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -PortType 1
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hires -PortType :1,2"
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hourly -Groupby slot
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hourly -Groupby "slot,type"
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(ValueFromPipeline=$true)]	[String]	$PortType,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)		{	$Action = "vstime"	}	
	elseif($AtTime)		{	$Action = "attime"	}	
	else				{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires){	$Frequency = "hires"	}	
	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} 
	elseif($Frequency_Daily)	{	$Frequency = "daily"	}	
	else				{	Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/portstatistics/'+$Frequency
	if($NSP) 			
		{ 	if($AtTime) { return "We cannot pass NSP in At Time report." } 
			$uri = $uri+";portPos:$NSP"
		}
	if($PortType)
		{ 	if($AtTime) { return "We cannot pass PortType in At Time report." } 
			$uri = $uri+";type:$PortType"
		}	
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
		{ 	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else		{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
			else		{	return "NoOfRecords is mandatory with Compareby. "	}
			if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
			else		{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}		
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
			{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
				$flg = "No"
			}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}	
	if($addQuery -eq "Yes")	{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members		}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-PortStatisticsReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-PortStatisticsReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9QoSStatisticalReports
{
<#
.SYNOPSIS	
	Request Quality of Service (QoS) statistical data using either Versus Time or At Time reports.
.DESCRIPTION
	Request Quality of Service (QoS) statistical data using either Versus Time or At Time reports.
.EXAMPLE	
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hires
.EXAMPLE	
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hires -VvSetName "asvvset2"
.EXAMPLE	
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hires -VvSetName "asvvset,asvvset2"
.EXAMPLE		
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Daily -All_Others
.EXAMPLE		
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Daily -Domain asdomain
.EXAMPLE 
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hires
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9PortStatisticsReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$VvSetName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Domain,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$All_Others,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(ValueFromPipeline=$true)]	[int]	$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)	{	$Action = "vstime"	}	
	elseif($AtTime)	{	$Action = "attime"	}	
	else			{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires)		{	$Frequency = "hires"	}	
	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} 
	elseif($Frequency_Daily)	{	$Frequency = "daily"	}	
	else						{ 	Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/qosstatistics/'+$Frequency
	if($VvSetName) 
		{	if($AtTime) { return "We cannot pass VvSetName in At Time report." }
			$lista = $VvSetName.split(",")		
			$count = 1
			$set =""
			foreach($sub in $lista)
				{	$prfx ="vvset:"+$sub
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$prfx = $prfx + ","
									$count = $count + 1
								}				
						}
					$set = $prfx
				}
			$uri = $uri+";$set"
		}
	if($Domain) 
		{	if($AtTime) { return "We cannot pass Domain in At Time report." }
			$lista = $Domain.split(",")		
			$count = 1
			$dom =""
			foreach($sub in $lista)
				{	$prfx ="domain:"+$sub
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$prfx = $prfx + ","
									$count = $count + 1
								}				
						}
					$dom = $prfx
				}
			$uri = $uri+";$dom"
		}
	if($All_Others) 
		{	if($AtTime) { return "We cannot pass All_Others in At Time report." }			
			$uri = $uri+";sys:all_others"
		}	
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
		{	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else				{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
			else				{	return "NoOfRecords is mandatory with Compareby. "	}
			if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
			else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}		
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")	{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
			{	write-host "Cmdlet executed successfully" -foreground green
				return $dataPS
			}
			else
			{	Write-Error "Failure:  While Executing Get-QoSStatisticalReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
				return 
			}
		}
	else
		{	Write-Error "Failure:  While Executing Get-QoSStatisticalReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9RCopyStatisticalReports
{
<#
.SYNOPSIS	
	Request Remote Copy statistical data using either Versus Time or At Time reports.
.DESCRIPTION
	Request Remote Copy statistical data using either Versus Time or At Time reports.
.EXAMPLE 
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires
.EXAMPLE 	
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires -TargetName xxx
.EXAMPLE 
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires -NSP x:x:x
.EXAMPLE 
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires -NSP "x:x:x,x:x:x:
.EXAMPLE 
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires -Groupby "targetName,linkId"
.EXAMPLE  
	PS:> Get-A9RCopyStatisticalReports -VersusTime -Frequency_Hires
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$TargetName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)			{	$Action = "vstime"	}	
	elseif($AtTime)			{	$Action = "attime"	}	
	else					{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires)	{	$Frequency = "hires"	}	
	elseif($Frequency_Hourly){	$Frequency = "hourly"	} 
	elseif($Frequency_Daily){	$Frequency = "daily"	}	
	else					{ Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/remotecopystatistics/'+$Frequency
	if($TargetName)	
		{ 	if($AtTime) { return "We cannot pass TargetName in At Time report." } 
			$uri = $uri+";targetName:$TargetName" 
		}
	if($NSP)	
		{ 	if($AtTime) { return "We cannot pass NSP in At Time report." } 
			$uri = $uri+";portPos:$NSP" 
		}
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
		{	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else	{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
			else	{	return "NoOfRecords is mandatory with Compareby. "	}
			if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
			else	{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}		
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")		{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-RCopyStatisticalReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-RCopyStatisticalReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9RCopyVolumeStatisticalReports
{
<#
.SYNOPSIS	
	Request statistical data related to Remote Copy volumes using either Versus Time or At Time reports.
.DESCRIPTION
	Request statistical data related to Remote Copy volumes using either Versus Time or At Time reports.
.EXAMPLE 
	PS:> Get-A9RCopyVolumeStatisticalReports -AtTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hires
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hires -vvName xxx
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hires -vvName "xxx,xxx"
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hires -TargetName xxx
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hires -TargetName "xxx,xxx"
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hires -Mode SYNC
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hires -RCopyGroup xxx
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hires -Groupby domain
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hires -Groupby "domain,targetNamex"
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9RCopyVolumeStatisticalReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
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
#>
[CmdletBinding()]
Param(
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
	[Parameter(ValueFromPipeline=$true)]	[String]	$vvName,
	[Parameter(ValueFromPipeline=$true)]	[String]	$TargetName,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Mode,
	[Parameter(ValueFromPipeline=$true)]	[String]	$RCopyGroup,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
	[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
	[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
	[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
	[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)	{	$Action = "vstime"	}	
	elseif($AtTime)	{	$Action = "attime"	}	
	else{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires){	$Frequency = "hires"	}	
	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} 
	elseif($Frequency_Daily)	{	$Frequency = "daily"	}	
	else{ Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/remotecopyvolumestatistics/'+$Frequency
	if($vvName)	
		{ 	if($AtTime) { return "We cannot pass vvName in At Time report." } 
			$uri = $uri+";volumeName:$vvName" 
		}
	if($TargetName)	
		{ 	if($AtTime) { return "We cannot pass TargetName in At Time report." } 
			$uri = $uri+";targetName:$TargetName" 
		}
	If ($Mode) 
		{	if($AtTime) { return "We cannot pass Mode in At Time report." }
			if($Mode.ToUpper() -eq "SYNC") { $uri = $uri+";mode:1" }
			elseif($Mode.ToUpper() -eq "PERIODIC"){	$uri = $uri+";mode:3" }
			elseif($Mode.ToUpper() -eq "ASYNC") { $uri = $uri+";mode:4" }
			else 	{	 Return "FAILURE : -Mode :- $Mode is an Incorrect Mode  [ SYNC | PERIODIC | ASYNC ] can be used only . "	}
		}
	if($RCopyGroup)	
		{ 	if($AtTime) { return "We cannot pass RCopyGroup in At Time report." } 
			$uri = $uri+";remoteCopyGroup:$RCopyGroup" 
		}		
	if($Groupby) 	{  	$uri = $uri+";groupby:$Groupby"}
	if($Summary) 	{ 	$uri = $uri+";summary:$Summary"}
    if($Compareby)
		{ 	$cmpVal = $Compareby.ToLower()
			if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
			else				{	return "Compareby should be either top or bottom"	}
			if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
			else				{	return "NoOfRecords is mandatory with Compareby. "	}
			if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
			else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
		}		
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}
	if($addQuery -eq "Yes")		{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-RCopyVolumeStatisticalReports_WSAPI. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-RCopyVolumeStatisticalReports_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9vLunStatisticsReports 
{
<#
.SYNOPSIS	
	Request VLUN statistics data using either Versus Time or At Time reports.
.DESCRIPTION
	Request VLUN statistics data using either Versus Time or At Time reports.
.EXAMPLE 
	PS:> Get-A9vLunStatisticsReports -AtTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9vLunStatisticsReports -VersusTime -Frequency_Hires
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -VersusTime -Frequency_Hires -VlunId 1
.EXAMPLE
	PS:> Get-vLunStatisticsReports -AtTime -Frequency_Hires -VlunId "1,2"
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -VersusTime -Frequency_Hires -VvName Test
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -AtTime -Frequency_Hourly -VvSetName asvvset
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -VersusTime -Frequency_Hourly -NSP "1:0:1"
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -VersusTime -Frequency_Daily -HostName asHost
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -VersusTime -Frequency_Daily -HostSetName asHostSet
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -VersusTime -Frequency_Daily -Groupby "domain,volumeName"
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
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
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
		[Parameter(ValueFromPipeline=$true)]	[String]	$VlunId,
		[Parameter(ValueFromPipeline=$true)]	[String]	$VvName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$HostName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$VvSetName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$HostSetName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
		[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
		[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
		[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
		[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)				{	$Action = "vstime"	}	
	elseif($AtTime)				{	$Action = "attime"	}	
	else						{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires)		{	$Frequency = "hires"	}	
	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} 
	elseif($Frequency_Daily)	{	$Frequency = "daily"	}	
	else						{ Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/vlunstatistics/'+$Frequency
	if($VlunId) 
		{ 	if($AtTime) 	{ 	return "We cannot pass VlunId in At Time report." } 
			$uri = $uri+";lun:$VlunId"
		}
	if($VvName) 	
		{ 	if($AtTime) 	{ 	return "We cannot pass VvName in At Time report." } 
			$uri = $uri+";volumeName:$VvName"
		}
	if($HostName) 
		{ 	if($AtTime) 	{	return "We cannot pass HostName in At Time report." } 
			$uri = $uri+";hostname:$HostName"
		}
	if($VvSetName) 
		{ 	if($AtTime) 	{ 	return "We cannot pass VvSetName in At Time report." } 
			$uri = $uri+";volumeName:set:$VvSetName"
		}
	if($HostSetName) 
		{ 	if($AtTime) 	{	return "We cannot pass HostSetName in At Time report." } 
			$uri = $uri+";hostname:set:$HostSetName"
		}
	if($NSP) 
		{ 	if($AtTime) 	{ 	return "We cannot pass NSP in At Time report." } 
			$uri = $uri+";portPos:$NSP"
		}	
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{	$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
		else				{	return "Compareby should be either top or bottom"	}
		if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
		else				{	return "NoOfRecords is mandatory with Compareby. "	}
		if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
		else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
	}		
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}	
	if($addQuery -eq "Yes")	{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET'
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members	
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-A9vLunStatisticsReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-A9vLunStatisticsReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9VvSpaceReports
{
<#
.SYNOPSIS	
	Request volume space data using either Versus Time or At Time reports.
.DESCRIPTION
	Request volume space data using either Versus Time or At Time reports.
.EXAMPLE 
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires
.EXAMPLE  
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Hires
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Hires -VvName xxx
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Hires -VvSetName asVVSet
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Hires -UserCPG ascpg
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Hires -SnapCPG assnpcpg
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Hires -ProvType 1
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Hires -Groupby id
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Hires -Groupby "id,name"
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -VvName xxx
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -VvSetName asVVSet
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -UserCPG ascpg
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -SnapCPG assnpcpg
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -ProvType 1
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -Groupby id
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -Groupby "id,name"
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Hourly -Summary max
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -Summary max
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency_Daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30"
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency_Hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
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
#>
[CmdletBinding()]
Param(
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$VersusTime,
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$AtTime,
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hires,
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Hourly,
	[Parameter(ValueFromPipeline=$true)]	[Switch]	$Frequency_Daily,
	[Parameter(ValueFromPipeline=$true)]	[String]	$VvName,
	[Parameter(ValueFromPipeline=$true)]	[String]	$VvSetName,
	[Parameter(ValueFromPipeline=$true)]	[String]	$UserCPG,
	[Parameter(ValueFromPipeline=$true)]	[String]	$SnapCPG,
	[Parameter(ValueFromPipeline=$true)]	[String]	$ProvType,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Groupby,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Summary,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Compareby,
	[Parameter(ValueFromPipeline=$true)]	[int]		$NoOfRecords,
	[Parameter(ValueFromPipeline=$true)]	[String]	$ComparebyField,
	[Parameter(ValueFromPipeline=$true)]	[String]	$GETime,
	[Parameter(ValueFromPipeline=$true)]	[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null
	$Action = $null
	$Frequency = $null
	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)	{	$Action = "vstime"	}	
	elseif($AtTime)	{	$Action = "attime"	}	
	else			{	Return "Please Select at-list any one from Versus Time or At Time for statistics report." }
	if($Frequency_Hires){	$Frequency = "hires"	}	
	elseif($Frequency_Hourly)	{	$Frequency = "hourly"	} 
	elseif($Frequency_Daily)	{	$Frequency = "daily"	}	
	else						{ 	Return "Please select Frequency it is mandatory" }
	$uri = '/systemreporter/'+$Action+'/volumespacedata/'+$Frequency
	if($VvName) { if($AtTime) { return "We cannot pass VvName in At Time report." } $uri = $uri+";name:$VvName"}
	if($VvSetName) { if($AtTime) { return "We cannot pass VvSetName in At Time report." } $uri = $uri+";name:set:$VvSetName"}
	if($UserCPG) { if($AtTime) { return "We cannot pass UserCPG in At Time report." } $uri = $uri+";userCPG:$UserCPG"}
	if($SnapCPG) { if($AtTime) { return "We cannot pass SnapCPG in At Time report." } $uri = $uri+";snapCPG:$SnapCPG"}
	if($ProvType) { if($AtTime) { return "We cannot pass ProvType in At Time report." } $uri = $uri+";provType:$ProvType"}		
	if($Groupby) {  $uri = $uri+";groupby:$Groupby"}
	if($Summary) { $uri = $uri+";summary:$Summary"}
    if($Compareby)
	{	$cmpVal = $Compareby.ToLower()
		if($cmpVal -eq "top" -OR $cmpVal -eq "bottom")	{	$uri = $uri+";compareby:$cmpVal,"	}
		else				{	return "Compareby should be either top or bottom"	}
		if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
		else				{	return "NoOfRecords is mandatory with Compareby. "	}
		if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
		else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"		}		
	}
	if($GETime)
		{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
			if($LETime)
				{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
					$flg = "No"
				}
			$addQuery = "Yes"
		}
	if($LETime)
		{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
			$addQuery = "Yes"		
		}	
	if($addQuery -eq "Yes")	{	$uri = $uri+$Query	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)	{			}	
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-A9VvSpaceReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-A9VvSpaceReports." 
			return $Result.StatusDescription
		}
}	
}

Function Add-A9DiskType
{
<#
.SYNOPSIS
    find and add disk type to temp variable.
.DESCRIPTION
    find and add disk type to temp variable. 
.EXAMPLE
    Add-A9DiskType -Dt $td

#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$DT
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$lista = $DT.split(",")		
	$count = 1
	[string]$DTyp
	foreach($sub in $lista)
		{	$val_Fix = "FC","NL","SSD","SCM"
			$val_Input =$sub
			if($val_Fix -eq $val_Input)
				{	if($val_Input.ToUpper() -eq "FC")	{	$DTyp = $DTyp + "1"	}
					if($val_Input.ToUpper() -eq "NL")	{	$DTyp = $DTyp + "2"	}
					if($val_Input.ToUpper() -eq "SSD")	{	$DTyp = $DTyp + "3"	}
					if($val_Input.ToUpper() -eq "SCM")	{	$DTyp = $DTyp + "4"	}
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$DTyp = $DTyp + ","
									$count = $count + 1
								}				
						}
				}
			else
				{ 	write-error "FAILURE : -DiskType :- $DT is an Incorrect, Please Use [ FC | NL | SSD | SCM] only ."
					Return 
				}						
		}
	return $DTyp.Trim()		
}
}

Function Add-A9RedType
{
<#
.SYNOPSIS
    find and add Red type to temp variable.
.DESCRIPTION
    find and add Red type to temp variable. 
.EXAMPLE
    Add-A9RedType -RT $td
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$RT
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$lista = $RT.split(",")		
	$count = 1
	[string]$RType
	foreach($sub in $lista)
		{	$val_Fix = "R0","R1","R5","R6"
			$val_Input =$sub
			if($val_Fix -eq $val_Input)
				{	if($val_Input.ToUpper() -eq "R0")	{	$RType = $RType + "1"	}
					if($val_Input.ToUpper() -eq "R1")	{	$RType = $RType + "2"	}
					if($val_Input.ToUpper() -eq "R5")	{	$RType = $RType + "3"	}
					if($val_Input.ToUpper() -eq "R6")	{	$RType = $RType + "4"	}
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$RType = $RType + ","
									$count = $count + 1
								}				
						}
				}
			else
			{ 	write-error "FAILURE : -RedType :- $RT is an Incorrect, Please Use [ R0 | R1 | R5 | R6 ] only ."
				Return 
			}						
		}
	return $RType.Trim()		
}
}
