####################################################################################
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	$Result = Invoke-A9API -uri $uri -type 'GET'
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAkSM1ViqXx
# y3HaSSKlihSDMlSeuRl5YSnoUqdZ4L0br3QmQETfHn1pkgUM1w3bcTpQ3ctw37kO
# IG20enLg8RfioIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhgwghoUAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQMWpwUGDysb1POD/4lBWTwB5GXwrRWXXuleyfxJSX9hOi1pvuKkxQnEf
# b7agqKmko0qLjfcdSd7nqrtN1BMmvOUwDQYJKoZIhvcNAQEBBQAEggGAUZeASjWX
# b6WTPVmO4XH3FEQN3TWY/gQbtw0pZ/8RvZtD5S9C0Y3P6GaE36N97urK72zv5Ik0
# 3PpMV9ASMsEWT3vNxEVtiCEwfkWX4zaM7JwaCroV1/I3YnN8whIQ6uhVXMYMsclK
# lg66CynYr6hQebQ1hieAsD1AvP/eGB3ALFA+yH3cZ9J5vniBunjpF7gjv9aea30J
# TcCQ7c0Wgw4HQ1lYgLsWfCoP0pjU0M6uXMcA5zthWRzN3H8Ctogn1hZm30dMxCZr
# sAPRioF1JRqyjB5FLeswxyUxabAwxzyf0hlcyhzre17EKwwJL3eqF+GT+kS5PKo2
# tJSGKM6On77MyFquuOcqqc8k9jo26ZtshFYFfGcRkwCDR1jQH4X/BTNmJwE6EFQf
# e1/bqamFKR1RLE0ZB1jZlAfUL0GiS2k67Eg97tXzmA3zQNM6G9DafIefdP4eft8t
# 4D3ydG0UNj3wzjuNpb85jDLaPudt0tnaFJaHmsqiFUDwYKkH+p8SFnDyoYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDCLwjlgi/IsQto/mc40J3c60rTf/Doj4Lj4L6Jj
# vPEKRPD9xcZXihvma51FHr5brHwCEQDJ5dyvxS2ZjLu2k1B6V9auGA8yMDI0MDcz
# MTIwMjMzM1qgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVow
# SDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQD
# ExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVY
# wamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isg
# HMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFe
# xAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gp
# OWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28
# mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkH
# NwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58
# ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXH
# g2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W
# 1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK
# 8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn
# 783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+K
# PGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1I
# jrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP
# 2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ
# 5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON
# 1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S
# 88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbU
# uXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145
# WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6
# F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso
# /zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG
# 70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEM
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zC
# pyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf
# 1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x
# 4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEio
# ZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7ax
# xLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZ
# OjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJ
# l2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz
# 2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH
# 4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb
# 5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ
# 9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0g
# ADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs
# 7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq
# 3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/
# Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9
# /HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWoj
# ayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEB
# MHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgIFAKCB4TAaBgkq
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTIw
# MjMzM1owKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMJpFK0ByAHWR0L6qAy3zGfELSmFH
# hQMo0O3M7JAUaliCYMiWLISkd3xgzOxlviRmYDANBgkqhkiG9w0BAQEFAASCAgA2
# QPRvC/4jn9+rq2xhanS3CPpQjJKWAezaZIZxZLUEEE6CgK7ns/yPPwbOR0jHmSkR
# aYIIUcb9gmLKEtkgLjD3JXuy0M20kDYLH2c510Re0ZyaWGPMds1gfXgqT7N1GiL7
# 1+SAVHh4ULeILfTB1birEGk0CKEoqMbQl3247KfF3aaRiCHgNmWu+arkcbHy9Ov5
# yUkxPJRsLWKqjEt1vLrlK3tcpPgNVvjIR3fo7UMTYlIbC3DxesAWYkSy8BIQ6O+T
# 7ns35fKx4C+TqeKsIXgzHQTf9hF92S0wyHfnbGq5tnApW0FDHGVBSPU7BWqG70+V
# VlOx7Qff6nJg8is/rny/DpMOaLg0a1ENipcTMP5+WzCbJ5+KacWmowY8AdznXi5U
# B0T4YfGOWi26YoawSj0932BoAp62PjnjUweR5obFehCt8uEyH44oy56JcYXDN92A
# 8vWbG80TDL8TdZu9fX3l8pxKDV9z99LNoVQCihHVz4Qbv7o5umTpOwCxH9yywNDa
# lwWj9gHzF/me8etqt3r2/GZYSmfdWqoyBw8la9F51BVQ1loh13397//irlDueDvi
# T37ZzphCI8ssM+WwOfja/Z28Y0qqwZxNHv4uD6JXAWCvovX1kkekTVtODEtEYYKD
# 0nS/a0OEq9h3rGSB8QbHDe0M5/wP/MGEZEqTss3TQQ==
# SIG # End signature block
