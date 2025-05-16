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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$NodeId,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[int]		$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,		
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$CpgName,
		[Parameter()]	[String]	$DiskType,
		[Parameter()]	[String]	$RAIDType,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[int]		$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,	
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$CpgName,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[int]		$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$NodeId,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[int]		$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$Id,
		[Parameter()]	[String]	$DiskType,
		[Parameter()]	[String]	$RPM,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$Id,
		[Parameter()]	[String]	$DiskType,
		[Parameter()]	[String]	$RPM,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter(mPipeline=$true)]			[int]		$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$Id,
		[Parameter()]	[String]	$DiskType,
		[Parameter()]	[String]	$RPM,	
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[int]		$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$NSP,
		[Parameter()]	[String]	$PortType,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[int]		$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$VvSetName,
		[Parameter()]	[String]	$Domain,
		[Parameter()]	[Switch]	$All_Others,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[int]	$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$TargetName,
		[Parameter()]	[String]	$NSP,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[int]		$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
	[Parameter()]	[Switch]	$VersusTime,
	[Parameter()]	[Switch]	$AtTime,
	[Parameter()]	[Switch]	$Frequency_Hires,
	[Parameter()]	[Switch]	$Frequency_Hourly,
	[Parameter()]	[Switch]	$Frequency_Daily,
	[Parameter()]	[String]	$vvName,
	[Parameter()]	[String]	$TargetName,
	[Parameter()]	[String]	$Mode,
	[Parameter()]	[String]	$RCopyGroup,
	[Parameter()]	[String]	$Groupby,
	[Parameter()]	[String]	$Summary,
	[Parameter()]	[String]	$Compareby,
	[Parameter()]	[int]		$NoOfRecords,
	[Parameter()]	[String]	$ComparebyField,
	[Parameter()]	[String]	$GETime,
	[Parameter()]	[String]	$LETime
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
Param(	[Parameter()]	[Switch]	$VersusTime,
		[Parameter()]	[Switch]	$AtTime,
		[Parameter()]	[Switch]	$Frequency_Hires,
		[Parameter()]	[Switch]	$Frequency_Hourly,
		[Parameter()]	[Switch]	$Frequency_Daily,
		[Parameter()]	[String]	$VlunId,
		[Parameter()]	[String]	$VvName,
		[Parameter()]	[String]	$HostName,
		[Parameter()]	[String]	$VvSetName,
		[Parameter()]	[String]	$HostSetName,
		[Parameter()]	[String]	$NSP,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[int]		$NoOfRecords,
		[Parameter()]	[String]	$ComparebyField,
		[Parameter()]	[String]	$GETime,
		[Parameter()]	[String]	$LETime
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
	[Parameter()]	[Switch]	$VersusTime,
	[Parameter()]	[Switch]	$AtTime,
	[Parameter()]	[Switch]	$Frequency_Hires,
	[Parameter()]	[Switch]	$Frequency_Hourly,
	[Parameter()]	[Switch]	$Frequency_Daily,
	[Parameter()]	[String]	$VvName,
	[Parameter()]	[String]	$VvSetName,
	[Parameter()]	[String]	$UserCPG,
	[Parameter()]	[String]	$SnapCPG,
	[Parameter()]	[String]	$ProvType,
	[Parameter()]	[String]	$Groupby,
	[Parameter()]	[String]	$Summary,
	[Parameter()]	[String]	$Compareby,
	[Parameter()]	[int]		$NoOfRecords,
	[Parameter()]	[String]	$ComparebyField,
	[Parameter()]	[String]	$GETime,
	[Parameter()]	[String]	$LETime
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



# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDspa8a3yv2
# Zqp/CD2+U99pR9nVOpZ7J2OZjTT0dWMwz3gp0g1jpMjNcf0dDhjuui9mMrIANAFY
# DagocGbsghGJoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG58wghubAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQEttgYSrvV32wtFa3SGtxGIpDfpaE3tjiqqwyEgDrrWnFncB1SDKH0p4
# Isvt+siADu4npTUm2elM9JERtsQwoWUwDQYJKoZIhvcNAQEBBQAEggGAWRXjMKgr
# Nx+f6JN2/Z0g7NGLvk89GcSd1kAf2GE31GmOJdbhtB1YAbAa49bs6g6lxTgB8RaH
# YVL0TWi65KlNB9T1dVrtYHu3IZVwFpnsOfWsur5NFlTWAvXgEEi8y1UqZJeUGoei
# BOb6RVn7IALp2btRuO8/s3CxinkzZLFfNffVFimjWcqhCbvnokFBTOzxaac8mAzD
# aaNilwOMJWrZ4tJZwcAS6H3WrgKigMH52wMdAzSAvwXAj2l0L3rebE7jPlbFu64W
# nqmL1kFPN6emaQUoH2cxTuzO5WseXPzBOi1JWj5JORRDVJbo5P1jWUPFsVjni/Vu
# 0iOtwri2PzzD/egDONTAeVWscIDt0xOBvRWWLsqrzPTDl7P67rMYVurvPDvo3x21
# cAIN5uhi9WbT3NJoQVSh7WlCix0vaMQaOsogTkOsZAJz12vrgcz2Sus8jpHTR8RP
# gFe8qTZLHmnQXlw55XdJE9N+cnql5/TA+jUm3LHheunCpKdoj7/e7DL8oYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMBWv7oIPld139A1cPF0NoubAg5RZk6cR
# /hx4VImr7ZwdiFTjuUJa9giQ8VBm+ouocAIUQXtZ5YeS27p7SkaoEYoBKL6Qfd0Y
# DzIwMjUwNTE1MjI1NzUyWqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
# c3QgWW9ya3NoaXJlMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMT
# J1NlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNqCCEwQwggZi
# MIIEyqADAgECAhEApCk7bh7d16c0CIetek63JDANBgkqhkiG9w0BAQwFADBVMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNTAzMjcwMDAw
# MDBaFw0zNjAzMjEyMzU5NTlaMHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5XZXN0
# IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzYwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDThJX0bqRTePI9EEt4Egc83JSBU2dhrJ+w
# Y7JgReuff5KQNhMuzVytzD+iXazATVPMHZpH/kkiMo1/vlAGFrYN2P7g0Q8oPEcR
# 3h0SftFNYxxMh+bj3ZNbbYjwt8f4DsSHPT+xp9zoFuw0HOMdO3sWeA1+F8mhg6uS
# 6BJpPwXQjNSHpVTCgd1gOmKWf12HSfSbnjl3kDm0kP3aIUAhsodBYZsJA1imWqkA
# VqwcGfvs6pbfs/0GE4BJ2aOnciKNiIV1wDRZAh7rS/O+uTQcb6JVzBVmPP63k5xc
# ZNzGo4DOTV+sM1nVrDycWEYS8bSS0lCSeclkTcPjQah9Xs7xbOBoCdmahSfg8Km8
# ffq8PhdoAXYKOI+wlaJj+PbEuwm6rHcm24jhqQfQyYbOUFTKWFe901VdyMC4gRwR
# Aq04FH2VTjBdCkhKts5Py7H73obMGrxN1uGgVyZho4FkqXA8/uk6nkzPH9QyHIED
# 3c9CGIJ098hU4Ig2xRjhTbengoncXUeo/cfpKXDeUcAKcuKUYRNdGDlf8WnwbyqU
# blj4zj1kQZSnZud5EtmjIdPLKce8UhKl5+EEJXQp1Fkc9y5Ivk4AZacGMCVG0e+w
# wGsjcAADRO7Wga89r/jJ56IDK773LdIsL3yANVvJKdeeS6OOEiH6hpq2yT+jJ/lH
# a9zEdqFqMwIDAQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNh
# lxmiMpswHQYDVR0OBBYEFIhhjKEqN2SBKGChmzHQjP0sAs5PMA4GA1UdDwEB/wQE
# AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1Ud
# IARDMEEwNQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8v
# Y3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5j
# cmwwegYIKwYBBQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYB
# BQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IB
# gQACgT6khnJRIfllqS49Uorh5ZvMSxNEk4SNsi7qvu+bNdcuknHgXIaZyqcVmhrV
# 3PHcmtQKt0blv/8t8DE4bL0+H0m2tgKElpUeu6wOH02BjCIYM6HLInbNHLf6R2qH
# C1SUsJ02MWNqRNIT6GQL0Xm3LW7E6hDZmR8jlYzhZcDdkdw0cHhXjbOLsmTeS0Se
# RJ1WJXEzqt25dbSOaaK7vVmkEVkOHsp16ez49Bc+Ayq/Oh2BAkSTFog43ldEKgHE
# DBbCIyba2E8O5lPNan+BQXOLuLMKYS3ikTcp/Qw63dxyDCfgqXYUhxBpXnmeSO/W
# A4NwdwP35lWNhmjIpNVZvhWoxDL+PxDdpph3+M5DroWGTc1ZuDa1iXmOFAK4iwTn
# lWDg3QNRsRa9cnG3FBBpVHnHOEQj4GMkrOHdNDTbonEeGvZ+4nSZXrwCW4Wv2qyG
# DBLlKk3kUW1pIScDCpm/chL6aUbnSsrtbepdtbCLiGanKVR/KC1gsR0tC6Q0RfWO
# I4owggYUMIID/KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUA
# MFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNV
# BAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AM2Y2ENBq26CK+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStS
# VjeYXIjfa3ajoW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQ
# BaCxpectRGhhnOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE
# 9cbY11XxM2AVZn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExS
# Lnh+va8WxTlA+uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OII
# q/fWlwBp6KNL19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGd
# F+z+Gyn9/CRezKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w
# 76kOLIaFVhf5sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4Cllg
# rwIDAQABo4IBXDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUw
# HQYDVR0OBBYEFF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjAS
# BgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28u
# Y29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEF
# BQcBAQRwMG4wRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0O
# NVgMnoEdJVj9TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc
# 6ZvIyHI5UkPCbXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1
# OSkkSivt51UlmJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz
# 2wSKr+nDO+Db8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y
# 4Il6ajTqV2ifikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVM
# CMPY2752LmESsRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBe
# Nh9AQO1gQrnh1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupia
# AeNHe0pWSGH2opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU
# +CCQaL0cJqlmnx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/Sjws
# usWRItFA3DE8MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7
# xpMeYRriWklUPsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs6
# 56Oz3TbLyXVoMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAs
# BgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJ
# BZvMWhUP2ZQQRLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQn
# Oh2qmcxGzjqemIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypo
# GJrruH/drCio28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0p
# KG9ki+PC6VEfzutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13j
# QEV1JnUTCm511n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9
# YrcmXcLgsrAimfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/y
# Vl4jnDcw6ULJsBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVg
# h60KmLmzXiqJc6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/
# OLoanEWP6Y52Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+Nr
# LedIxsE88WzKXqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58N
# Hs57ZPUfECcgJC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9U
# gOHYm8Cd8rIDZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1Ud
# DwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0
# eS5jcmwwNQYIKwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3
# OyWM637ayBeR7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJ
# JlFfym1Doi+4PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0m
# UGQHbRcF57olpfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTw
# bD/zIExAopoe3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i
# 111TW7HV1AtsQa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGe
# zjM6CRpcWed/ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+
# 8aW88WThRpv8lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH
# 29308ZkpKKdpkiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrs
# xrYJD+3f3aKg6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6
# Ii8+CQOYDwXM+yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz
# 7NgAnOgpCdUo4uDyllU9PzGCBJIwggSOAgEBMGowVTELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMg
# VGltZSBTdGFtcGluZyBDQSBSMzYCEQCkKTtuHt3XpzQIh616TrckMA0GCWCGSAFl
# AwQCAgUAoIIB+TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTI1MDUxNTIyNTc1MlowPwYJKoZIhvcNAQkEMTIEMHhDwzHODd3QFrSV
# SAwdSJW6cYT4EcZwl+NUS5yOknAhWlpj+uavRKfJHwa9HTwS0TCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAwvHAebTPGRMw1abvpbn0bofjWvlfojXhQIeau8JcHUK3yvvJ7wx7n09V
# 9ryXLrrUo9XToArceke+PrbmygYbB5jY+Y4VSglbU1c15ZfLQr6hCr4B746pKtFm
# 5GnfeVFYPOEIh5rMrsaD7hPdZORZss6rUEBlGulZkh/0J7deYDHXHyURaVE3lz2o
# Ch9HoXrpGCD16Tn640P+uIvURoTrK6j2+0VLUg995ciQR8XVJYa7LOdnEwvHge9i
# RhsIFKn55VEpXOYApKFLYjYiBq0qTF9OR62PCNl/4zinBVLFdFdXqaDvzatThZfD
# U/86zW1cljJst1dl4iRbCdto1obWZToOG0Ytw9rzQAtLJ+092wIS45nEYijJkXO3
# YOCo69qhQ6xNI0fwXHw2y9Cid2OVWw4BHhJxScjr06rs325vQfNeyt5409PoNECm
# yhHIAW+ZgNY+QNCPaumM1R+bcmQeua8dZOiJO7Y8n2wTzwXa+3CUQDolp3GoPotR
# Hmc2n7fpUJIvFrDOAZ87XnMQ1cYt5dWA7idlGuB4QAm6uDMXYo/Vm2aZZoqtcRaX
# BV1Y2C1NZ52l4Eo3VYE4IAwxl4UKu7hJYHgBC5PG2+Jeegc0ncFnbKdSXYKI2vqS
# vq4ivFuOmxnhqB8DCOEaQ12zTyncLvIP079N8RmVG4a3kfVH35A=
# SIG # End signature block
