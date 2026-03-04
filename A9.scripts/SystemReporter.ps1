## 	©2025 Hewlett Packard Enterprise Development LP


Function Get-A9CacheReport
{
<#
.SYNOPSIS	
	Cache memory statistics data reports
.DESCRIPTION
	Cache memory statistics data reports.Request cache memory statistics data using either Versus Time or At Time reports.
.PARAMETER VersusTime
	Request cache memory statistics data using Versus Time reports.
.PARAMETER AtTime
	Request cache memory statistics data using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values. If left unset, it will assume the 'hires' option.
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
.PARAMETER NodeId
	<nodeid> – Provides cache memory data for the specified nodes, in the range of 0 to 7. With no nodeid specified, the system calculates cache memory data for all nodes in the system.
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE	
	PS:> Get-A9CacheReport -VersusTime -Frequency hires 

	Cmdlet executed successfully

	sampleTime    : 2/26/2026 5:05:00 AM
	sampleTimeSec : 1772107500
	hitIO         : @{read=5944.8; write=334.1}
	missIO        : @{read=24751.1; write=39023.1}
	accessIO      : @{read=30696; write=39357.2}
	hitPct        : @{read=19.4; write=0.8}
	totalAccessIO : 70053.2
	lockBulkIO    : 0
	pageStatistic : @{pageStates=; dirtyPages=; maxDirtyPages=; delayAckPages=}

	This is the sample output of a single record, this command would return many of these results. 
.EXAMPLE	
	PS:> Get-A9CacheReport -VersusTime -Frequency hires -NodeId 1

.EXAMPLE
	PS:> Get-A9CacheReport -AtTime -Frequency hires -NodeId 1
.EXAMPLE
	PS:> Get-A9CacheReport -AtTime -Frequency hires -Groupby node
.EXAMPLE
	PS:> Get-A9CacheReport -VersusTime -Frequency hires -Summary min
.EXAMPLE
	PS:> Get-A9CacheReport -VersusTime -Frequency hires -Compareby top -NoOfRecords 2 -ComparebyField hitIORead
.EXAMPLE	
	PS:> Get-A9CacheReport -VersusTime -Frequency hires -GETime 2018-07-18T13:20:00+05:30 -LETime 2018-07-18T13:25:00+05:30  
.EXAMPLE
	PS:> Get-A9CacheReport -VersusTime -Frequency hires -LETime 2018-07-18T13:25:00+05:30  

#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency='hires',
		[Parameter(ParameterSetName='vs')]
		[Validaterange(0,7)]							[String]	$NodeId,
		[Parameter()]									[String]	$Groupby,
		[Parameter(ParameterSetName='vs')]				[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()]	
		[ValidateSet('hitIORead','hitIOWrite','missIORead','missIOWrite','accessIORead','accessIOWrite','hitPctRead','hitPctWrite','totalAccessIO','lockBulkIO','pageStatisticDelayAckPagesNL_7','pageStatisticDelayAckPagesFC',
					'pageStatisticDelayAckPagesSSD','pageStatisticPageStatesFree','pageStatisticPageStatesClean','pageStatisticPageStatesWriteOnce','pageStatisticPageStatesWriteMultiple','pageStatisticPageStatesWriteScheduled',
					'pageStatisticPageStatesWriteing','pageStatisticPageStatesDcowpend','pageStatisticDirtyPagesNL','pageStatisticDirtyPagesFC','pageStatisticDirtyPagesSSD','pageStatisticMaxDirtyPagesNL_7',
					'pageStatisticMaxDirtyPagesFC','pageStatisticMaxDirtyPagesSSD')]
														[String]	$ComparebyField,		
		[Parameter(ParameterSetName='at')]				[String]	$GETime,
		[Parameter(ParameterSetName='at')]				[String]	$LETime
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime )			{	$uri = "/systemreporter/vstime/cachememorystatistics/"+$Frequency	}	
	if ( $AtTime )				{	$uri = "/systemreporter/attime/cachememorystatistics/"+$Frequency	}	
	if ( $NodeId) 				{ 	$uri = $uri+";node:$NodeId"		}
	if ( $Groupby) 				{ 	$uri = $uri+";groupby:$Groupby"	}
	if ( $Summary) 				{ 	$uri = $uri+";summary:$Summary"	}
	if ( $Compareby)			{ 	$uri = $uri+";compareby:$Compareby,"	
									if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
									else				{	return "NoOfRecords is mandatory with Compareby. "	}
									if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
									else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
								}	
	if ( $GETime)				{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
									if ( $LETime)	{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
														$flg = "No"
													}
									$addQuery = "Yes"
								}
	if ( $LETime)				{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
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
			else{	Write-Error "Failure:  While Executing PS:> Get-A9CacheMemoryStatisticsDataReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9CacheMemoryStatisticsDataReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9CPGSpaceReport
{
<#
.SYNOPSIS	
	CPG space data using either Versus Time or At Time reports.
.DESCRIPTION
	CPG space data using either Versus Time or At Time reports..
.PARAMETER VersusTime
	Request CPG space data using  Versus Time reports.
.PARAMETER AtTime
	Request CPG space data using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values. If unset, it will assume the 'hires' option
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
.PARAMETER DiskType
	The CPG space sample data is for the specified disk types. With no disk type specified, the system calculates the CPG space sample data is for all the disk types in the system.
	FC : Fibre Channel
	NL : Near Line
	SSD : SSD
	SCM : SCM Disk type
	QLC : QLC Disk type	
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE
	PS:> Get-A9CPGSpaceReport -VersusTime -Frequency hires
	Cmdlet executed successfully

	sampleTime         : 2/26/2026 5:30:00 AM
	sampleTimeSec      : 1772109000
	usedSpace          : @{userMiB=39524100}
	freeSpace          : @{userMiB=37079700}
	totalSpace         : @{userMiB=84766500}
	sharedSpaceMiB     : 8162700
	freeSpaceMiB       : 37079700
	totalSpaceMiB      : 84766500
	growthMiB          : 190085698
	capacityEfficiency : @{compaction=5.39; deduplication=1.26; overProvisioning=1.13; compression=1.67; dataReduction=2.03}

	The above is the output of one of the many records that will be returned.
.EXAMPLE
	PS:> Get-A9CPGSpaceReport -VersusTime -Frequency hires -GETime 2018-07-18T13:20:00+05:30 -LETime 2018-07-18T13:25:00+05:30  
.EXAMPLE
	PS:> Get-A9CPGSpaceReport -VersusTime -Frequency hires -LETime 2018-07-18T13:25:00+05:30
#>
[CmdletBinding()]
Param(	[Parameter(mandatory, ParameterSetName='Vs')]	[Switch]	$VersusTime,
		[Parameter(mandatory, ParameterSetName='At')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('Hires','Hourly','Daily')]			[String]	$Frequency='hires',
		[Parameter(ParameterSetName='Vs')]				[String]	$CpgName,
		[Parameter(ParameterSetName='Vs')]
		[ValidateSet('FC','NL','SSD','SCM','QLC')]		[String]	$DiskType,
		[Parameter()]
		[ValidateSet('domain','id','name','diskType')]	[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()]	
		[ValidateSet('totalSpaceMiB','freeSpaceMiB','usedSpaceMiB','compaction','compression','deduplication','dataReduction')]	
														[String]	$ComparebyField,	
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ($VersusTime)			{	$uri = '/systemreporter/vstime/cpgspacedata/'+$Frequency	}
	if ($AtTime)				{	$uri = '/systemreporter/attime/cpgspacedata/'+$Frequency	}
	if ($CpgName) 				{ 	$uri = $uri+";name:$CpgName"	}
	if ($DiskType -eq 'FC')		{	$uri = $uri+";diskType:1" 		}
	if ($DiskType -eq 'NL')		{	$uri = $uri+";diskType:2" 		}
	if ($DiskType -eq 'SSD')	{	$uri = $uri+";diskType:3" 		}
	if ($DiskType -eq 'SCM')	{	$uri = $uri+";diskType:4" 		}
	if ($DiskType -eq 'QLC')	{	$uri = $uri+";diskType:5" 		}
	if ($Groupby) 				{  	$uri = $uri+";groupby:$Groupby"	}
	if ($Summary) 				{ 	$uri = $uri+";summary:$Summary"	}
	if ($Compareby)				{	$uri = $uri+";compareby:$Compareby,"	
									if($NoOfRecords)								{	$uri = $uri+$NoOfRecords+","	}
									else											{	return "NoOfRecords is mandatory with Compareby. "	}
									if($ComparebyField)								{	$uri = $uri+$ComparebyField	}
									else											{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
								}
	if ($GETime)				{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
									if($LETime)
										{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
											$flg = "No"
										}
									$addQuery = "Yes"
								}
	if ($LETime)				{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
									$addQuery = "Yes"		
								}
	if ( $addQuery -eq "Yes" )	{	$uri = $uri+$Query	}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members	
		}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-A9CPGSpaceDataReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9CPGSpaceDataReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9CPGIOPsReport 
{	
<#
.SYNOPSIS	
	CPG statistical data using either Versus Time or At Time reports.
.DESCRIPTION
	CPG statistical data using either Versus Time or At Time reports.
.PARAMETER VersusTime
	Request CPG space data using  Versus Time reports.
.PARAMETER AtTime
	Request CPG space data using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values. If unset it will assume 'hires'
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE
	PS:> Get-A9CPGIOPsReport -VersusTime -Frequency hourly

	Cmdlet executed successfully

	sampleTime    : 2/26/2026 5:40:00 AM
	sampleTimeSec : 1772109600
	IO            : @{read=9422.3; write=14626.2; total=24048.6}
	KBytes        : @{read=234465.5; write=677795.7; total=912261.2}
	serviceTimeMS : @{read=0.097; write=0.08; total=0.086}
	IOSizeKB      : @{read=24.9; write=46.3; total=37.9}
	queueLength   : 2
	busyPct       : 0.2

	This is an example of the output record, this command would return many of these records.
.EXAMPLE	
	PS:> Get-A9CPGIOPsReport -VersusTime -Frequency hires -CpgName $cpg
.EXAMPLE
	PS:> Get-A9CPGIOPsReport -AtTime -Frequency hourly
.EXAMPLE
	PS:> Get-A9CPGIOPsReport -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPGIOPsReport -VersusTime -Frequency hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPGIOPsReport -AtTime -Frequency hires -Summary max
.EXAMPLE
	PS:> Get-A9CPGIOPsReport -VersusTime -Frequency daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9CPGIOPsReport -AtTime -Frequency hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency='hires',
		[Parameter(ParameterSetName='vs')]				[String]	$CpgName,
		[Parameter()]									[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()][ValidateSet('totalIOPs')]			[String]	$ComparebyField,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime)		{	$uri = "/systemreporter/vstime/cpgstatistics/"+$Frequency	}	
	if ( $AtTime)			{	$uri = "/systemreporter/attime/cpgstatistics/"+$Frequency	}	
	if ( $CpgName) 			{ 	$uri = $uri+";name:$CpgName"	}	
	if ( $Groupby) 			{  	$uri = $uri+";groupby:$Groupby"	}
	if ( $Summary) 			{ 	$uri = $uri+";summary:$Summary"	}
    if ( $Compareby)		{ 	$uri = $uri+";compareby:$Compareby,"	
								if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
								else				{	return "NoOfRecords is mandatory with Compareby. "	}
								if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
								else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
							}
	if ( $GETime)			{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
								if($LETime)
									{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
										$flg = "No"
									}
								$addQuery = "Yes"
							}
	if ( $LETime)			{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
								$addQuery = "Yes"		
							}
	if ( $addQuery -eq "Yes"){	$uri = $uri+$Query	}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-A9CPGStatisticalDataReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9CPGStatisticalDataReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9CPUReport
{
<#
.SYNOPSIS	
	CPU statistical data reports.
.DESCRIPTION
	CPU statistical data reports.
.PARAMETER VersusTime
	Request CPU statistics data using Versus Time reports.
.PARAMETER AtTime
	Request CPU statistics data using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values.
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE 
	PS:> Get-A9CPUReport -AtTime -Frequency hires
.EXAMPLE  
	PS:> Get-A9CPUReport -VersusTime -Frequency hires | format-table
	Cmdlet executed successfully

	node cpu 	userPct 	systemPct 	idlePct interruptsPerSec contextSwitchesPerSec
	---- --- 	------- 	--------- 	------- ---------------- ---------------------
	0    0   	42.20      	3.00   		54.80         31789.50              77353.40
	0    1   	37.20      	2.70   		60.10             0.00                  0.00
	0    10    	8.60      	1.00   		90.50             0.00                  0.00
	0    11    	6.50      	1.10   		92.40             0.00                  0.00
.EXAMPLE  
	PS:> Get-A9CPUReport -VersusTime -Frequency hires -NodeId 1
.EXAMPLE  
	PS:> Get-A9CPUReport -VersusTime -Frequency hires -Groupby cpu
.EXAMPLE
	PS:> Get-A9CPUReport -VersusTime -Frequency daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9CPUReport -AtTime -Frequency hires -LETime "2018-04-09T12:20:00+05:30"
.EXAMPLE
	PS:> Get-A9CPUReport -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency='hires',
		[Parameter()][ValidateRange(0,7)]				[String]	$NodeId,
		[Parameter()][ValidateSet('cpu','node')]		[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()][ValidateSet('userPct','systemPct','idlePct','interruptsPerSec','contextSwitchesPerSec')]
														[String]	$ComparebyField,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime)		{	$uri = '/systemreporter/vstime/cpustatistics/'+$Frequency	}	
	if ( $AtTime)			{	$uri = '/systemreporter/attime/cpustatistics/'+$Frequency	}	
	if ( $NodeId) 			{ 	$uri = $uri+";node:$NodeId"	}
	if ( $Groupby) 			{ 	$uri = $uri+";groupby:$Groupby"}
	if ( $Summary) 			{ 	$uri = $uri+";summary:$Summary"}
    if ( $Compareby	)		{	$uri = $uri+";compareby:$Compareby,"	
								if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
								else				{	return "NoOfRecords is mandatory with Compareby. "	}
								if($ComparebyField)	{	$uri = $uri+$ComparebyField }
								else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
							}
	if ( $GETime)			{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
								if ( $LETime)	{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
													$flg = "No"
												}
								$addQuery = "Yes"
							}
	if ( $LETime)			{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
								$addQuery = "Yes"		
							}
	if ( $addQuery -eq "Yes")	{	$uri = $uri+$Query	}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members	
		}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-A9CPUStatisticalDataReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9CPUStatisticalDataReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9PDSpaceReport
{
<#
.SYNOPSIS	
	Physical disk capacity reports.
.DESCRIPTION
	Physical disk capacity reports.
.PARAMETER VersusTime
	Request Physical disk capacity using Versus Time reports.
.PARAMETER AtTime
	Request Physical disk capacity using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values. If not set, it will assume the hires option
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
.PARAMETER Id
	Requests disk capacity data for the specified disks only. For example, specify id:1,3,2. With no id specified, the system calculates physical disk capacity for all disks in the system.
.PARAMETER DiskType
	The CPG space sample data is for the specified disk types. With no disk type specified, the system calculates the CPG space sample data is for all the disk types in the system.
	FC : Fibre Channel
	NL : Near Line
	SSD : SSD
	SCM : SCM Disk type
	QLC : QLC Disk type	
.PARAMETER RPM
	Specifies the RPM speeds to query for physical disk capacity data. With no speed indicated, the system calculates physical disk capacity data for all speeds in the system. 
	Valid RPM values are: 7,10,15,100,150.
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE  
	PS:> Get-A9PDSpaceReport -VersusTime | format-table
	Cmdlet executed successfully

	sampleTime            sampleTimeSec allocatedMiB   freeMiB failedMiB  totalMiB
	----------            ------------- ------------   ------- ---------  --------
	2/26/2026 6:20:00 AM     1772112000    136807424 126770176         0 263577600
	2/26/2026 6:25:00 AM     1772112300    136807424 126770176         0 263577600
	2/26/2026 6:30:00 AM     1772112600    136807424 126770176         0 263577600
.EXAMPLE 
	PS:> Get-A9PDSpaceReport -VersusTime -Frequency hires -Id 1
.EXAMPLE 
	PS:> Get-A9PDSpaceReport -VersusTime -Frequency hires -Groupby id
.EXAMPLE
	PS:> Get-A9PDSpaceReport -VersusTime -Frequency hourly -Summary max
.EXAMPLE
	PS:> Get-A9PDSpaceReport -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency='hires',
		[Parameter(ParameterSetName='vs')]				[String]	$Id,
		[Parameter(ParameterSetName='vs')]	
		[ValidateSet('FC','NL','SSD','SCM','QLC')]		[String]	$DiskType,
		[Parameter(ParameterSetName='vs')]			
		[ValidateSet(7,10,15,100,150)]					[String]	$RPM,
		[Parameter()][ValidateSet('id','cageID','cageSide','mag','diskPos','type','RPM')]	
														[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime )			{	$uri = '/systemreporter/vstime/physicaldiskcapacity/'+$Frequency	}	
	if ( $AtTime )				{	$uri = '/systemreporter/attime/physicaldiskcapacity/'+$Frequency	}	
	if($Id) 					{ 	$uri = $uri+";id:$Id"	}
	if($DiskType -eq 'FC') 		{	$uri = $uri+";type:1"	}	
	if($DiskType -eq 'NL') 		{	$uri = $uri+";type:2"	}	
	if($DiskType -eq 'SSD') 	{	$uri = $uri+";type:3"	}	
	if($DiskType -eq 'SCM') 	{	$uri = $uri+";type:4"	}	
	if($DiskType -eq 'QLC') 	{	$uri = $uri+";type:5"	}	
	if($RPM) 					{ 	$uri = $uri+";RPM:$RPM"	}
	if($Groupby)			 	{  	$uri = $uri+";groupby:$Groupby"}
	if($Summary) 				{ 	$uri = $uri+";summary:$Summary"}	
	if($GETime)					{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")
									if($LETime)
										{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
											$flg = "No"
										}
									$addQuery = "Yes"
								}
	if($LETime)					{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
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
			else{	Write-Error "Failure:  While Executing Get-A9PDCapacityReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9PDSpaceReport." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9PDIOPsReport
{
<#
.SYNOPSIS	
	physical disk statistics reports using either Versus Time or At Time reports.
.DESCRIPTION
	physical disk statistics reports using either Versus Time or At Time reports.
.PARAMETER VersusTime
	Request Physical disk capacity using Versus Time reports.
.PARAMETER AtTime
	Request Physical disk capacity using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values.
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE 
	PS:> Get-A9PDIOPsReport -AtTime -Frequency hires
.EXAMPLE 
	PS:> Get-A9PDIOPsReport -AtTime  -VersusTime -Frequency hires -DiskType FC
.EXAMPLE	
	PS:> Get-A9PDIOPsReport -AtTime  -VersusTime -Frequency hires -RPM 7
.EXAMPLE 
	PS:> Get-A9PDIOPsReport -AtTime  -VersusTime -Frequency hires -Groupby id
.EXAMPLE
	PS:> Get-A9PDIOPsReport -AtTime  -VersusTime -Frequency daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PDIOPsReport  -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter(Mandatory)]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency,
		[Parameter(ParameterSetName='vs')]				[String]	$Id,
		[Parameter(ParameterSetName='vs')]
		[ValidateSet('FC','NL','SSD','SCM','QLC')]		[String]	$DiskType,
		[Parameter(ParameterSetName='vs')]
		[ValidateSet(7,10,15,100,150)]					[String]	$RPM,
		[Parameter()]									[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()]									[String]	$ComparebyField,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime)			{	$uri = '/systemreporter/vstime/physicaldiskstatistics/'+$Frequency	}	
	if ( $AtTime)				{	$uri = '/systemreporter/attime/physicaldiskstatistics/'+$Frequency	}	
	if ( $Id) 					{ 	$uri = $uri+";id:$Id"	}
	if ( $DiskType -eq 'FC') 	{	$uri = $uri+";type:1"	}	
	if ( $DiskType -eq 'NL') 	{	$uri = $uri+";type:2"	}	
	if ( $DiskType -eq 'SSD') 	{	$uri = $uri+";type:3"	}	
	if ( $DiskType -eq 'SCM') 	{	$uri = $uri+";type:4"	}	
	if ( $DiskType -eq 'QLC') 	{	$uri = $uri+";type:5"	}	
	if ( $RPM) 					{ 	$uri = $uri+";RPM:$RPM"			}
	if ( $Groupby) 				{  $uri = $uri+";groupby:$Groupby"	}
	if ( $Summary) 				{ $uri = $uri+";summary:$Summary"	}
	if ( $Compareby)			{ 	$uri = $uri+";compareby:$Compareby,"	
									if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
									else				{	return "NoOfRecords is mandatory with Compareby. "}
									if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
									else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
								}	
	if($GETime)					{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
									if ( $LETime)	{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
														$flg = "No"
													}
									$addQuery = "Yes"
								}
	if($LETime)					{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
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
			else{	Write-Error "Failure:  While Executing Get-A9PDStatisticsReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9PDStatisticsReports." 
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
.PARAMETER VersusTime
	Request Physical disk capacity using Versus Time reports.
.PARAMETER AtTime
	Request Physical disk capacity using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values. If not set, it will default to 'hires'
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -AtTime -Frequency hires
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency hires -Id 1
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency hires -DiskType FC
.EXAMPLE	
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency hires -RPM 7
.EXAMPLE 
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency hires -Groupby id
.EXAMPLE
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency hourly -Summary max
.EXAMPLE
	PS:> Get-A9PDSpaceReports -VersusTime -Frequency daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PDSpaceReports -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency='hires',
		[Parameter(ParameterSetName='vs')]				[String]	$Id,
		[Parameter(ParameterSetName='vs')]
		[ValidateSet('FC','NL','SSD','SCM','QLC')]		[String]	$DiskType,
		[Parameter(ParameterSetName='vs')]	
		[ValidateSet(7,10,15,100,150)]					[String]	$RPM,	
		[Parameter()]									[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()][ValidateSet('totalIOPs','normalChunkletsUsedOK','normalChunkletsUsedFailed','normalChunkletsAvailClean','normalChunkletsAvailDirty','normalChunkletsAvailFailed',
					'spareChunkletsUsedOK','spareChunkletsUsedFailed','spareChunkletsAvailClean','spareChunkletsAvailDirty','spareChunkletsAvailFailed','lifeLeftPct','temperatureC')]	
														[String]	$ComparebyField,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if($VersusTime)			{	$uri = '/systemreporter/vstime/physicaldiskspacedata/'+$Frequency	}	
	if($AtTime)				{	$uri = '/systemreporter/attime/physicaldiskspacedata/'+$Frequency	}	
	if($Id) 				{ 	$uri = $uri+";id:$Id"	}	
	if ( $DiskType -eq 'FC') 	{	$uri = $uri+";type:1"	}	
	if ( $DiskType -eq 'NL') 	{	$uri = $uri+";type:2"	}	
	if ( $DiskType -eq 'SSD') 	{	$uri = $uri+";type:3"	}	
	if ( $DiskType -eq 'SCM') 	{	$uri = $uri+";type:4"	}	
	if ( $DiskType -eq 'QLC') 	{	$uri = $uri+";type:5"	}	
	if($RPM) 				{	$uri = $uri+";RPM:$RPM"}
	if($Groupby) 			{  	$uri = $uri+";groupby:$Groupby"}
	if($Summary) 			{	$uri = $uri+";summary:$Summary"}
    if($Compareby)			{ 	$uri = $uri+";compareby:$Compareby,"	
								if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
								else				{	return "NoOfRecords is mandatory with Compareby. "	}
								if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
								else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
							}	
	if($GETime)				{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
								if ( $LETime)	{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
													$flg = "No"
												}
								$addQuery = "Yes"
							}
	if($LETime)				{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
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
				{	Write-Error "Failure:  While Executing Get-A9PDSpaceReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-A9PDSpaceReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9PortIOPsReport
{
<#
.SYNOPSIS	
	Request a port statistics report using either Versus Time or At Time reports.
.DESCRIPTION
	Request a port statistics report using either Versus Time or At Time reports.
.PARAMETER VersusTime
	Request port statistics report using Versus Time reports.
.PARAMETER AtTime
	Request port statistics report using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values.
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
.PARAMETER NSP
	Requests sample data for the specified ports only using n:s:p. For example, specify port:1:0:1,2:1:3,6:2:1. With no portPos specified, the system calculates performance data for all ports in the system.
.PARAMETER PortType
	Requests sample data for the specified port type (see, portConnType enumeration) . With no type specified, the system calculates performance data for all port types in the system. You can specify one or more port types by separating them with a comma (,). For example, specify type: 1,2,8.
	Symbol Value Description
	HOST : FC port connected to hosts or fabric.	
	DISK : FC port connected to disks.	
	FREE : Port is not connected to hosts or disks.	
	IPORT : Port is in iport mode.	
	RCFC : FC port used for Remote Copy.	
	PEER : FC port used for data migration.	
	RCIP : IP (Ethernet) port used for Remote Copy.	
	ISCSI : iSCSI (Ethernet) port connected to hosts.	
	CNA : CNA port, which can be FCoE or iSCSI.	
	FS : Ethernet File Persona ports.
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE 
	PS:> Get-A9PortIOPsReport -VersusTime
	Cmdlet executed successfully

	sampleTime    : 2/26/2026 6:55:00 AM
	sampleTimeSec : 1772114100
	IO            : @{read=35328.3; write=27968.7; total=63297}
	KBytes        : @{read=654047.8; write=1275912.6; total=1929960.4}
	serviceTimeMS : @{read=0.115; write=0.081; total=0.1}
	IOSizeKB      : @{read=18.5; write=45.6; total=30.5}
	queueLength   : 2
	busyPct       : 34.2

	This is an example of the output of a single record, while this command will return many records.
.EXAMPLE
	PS:> Get-A9PortIOPsReport -VersusTime -Frequency hires -NSP "1:0:1"
.EXAMPLE
	PS:> Get-A9PortIOPsReport -AtTime -Frequency hires -PortType 1
.EXAMPLE
	PS:> Get-A9PortIOPsReport -AtTime -Frequency hourly -Groupby "slot,type"
.EXAMPLE
	PS:> Get-A9PortIOPsReport -VersusTime -Frequency hourly -Summary max
.EXAMPLE
	PS:> Get-A9PortIOPsReport -VersusTime -Frequency daily -Compareby top -NoOfRecords 10 -ComparebyField totalIOPs
.EXAMPLE
	PS:> Get-A9PortIOPsReport -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency='hires',
		[Parameter(ParameterSetName='vs')]
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
														[String]	$NSP,
		[Parameter(ParameterSetName='vs')]	
		[ValidateSet('HOST','DISK','IPORT','FREE','RCFC','PEER','RCIP','ISCSI','CNA','FS')]			
														[String]	$PortType,
		[Parameter()]									[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()][VAlidateSet('totalIOPs')]			[String]	$ComparebyField,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime )			{	$uri = '/systemreporter/vstime/portstatistics/'+$Frequency	}	
	if ( $AtTime )				{	$uri = '/systemreporter/attime/portstatistics/'+$Frequency	}	
	if ( $NSP) 					{ 	$uri = $uri+";portPos:$NSP"	}
	if ( $PortType -eq 'HOST')	{ 	$uri = $uri+";type:1"	}	
	if ( $PortType -eq 'DISK')	{ 	$uri = $uri+";type:2"	}	
	if ( $PortType -eq 'FREE')	{ 	$uri = $uri+";type:3"	}	
	if ( $PortType -eq 'IPORT')	{ 	$uri = $uri+";type:4"	}	
	if ( $PortType -eq 'RCFC')	{ 	$uri = $uri+";type:5"	}	
	if ( $PortType -eq 'PEER')	{ 	$uri = $uri+";type:6"	}	
	if ( $PortType -eq 'RCIP')	{ 	$uri = $uri+";type:7"	}	
	if ( $PortType -eq 'ISCSI')	{ 	$uri = $uri+";type:8"	}	
	if ( $PortType -eq 'CNA')	{ 	$uri = $uri+";type:9"	}	
	if ( $PortType -eq 'FS')	{ 	$uri = $uri+";type:10"	}	
	if ( $Groupby) 	{  $uri = $uri+";groupby:$Groupby"}
	if ( $Summary) 	{ $uri = $uri+";summary:$Summary"}
    if ( $Compareby){ 	$uri = $uri+";compareby:$Compareby,"	
						if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
						else		{	return "NoOfRecords is mandatory with Compareby. "	}
						if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
						else		{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
					}		
	if ( $GETime)	{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
						if ( $LETime)	{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
											$flg = "No"
										}
						$addQuery = "Yes"
					}
	if ( $LETime )	{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
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
				{	Write-Error "Failure:  While Executing Get-A9PortStatisticsReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else
		{	Write-Error "Failure:  While Executing Get-A9PortStatisticsReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9QoSIOPsReport
{
<#
.SYNOPSIS	
	Request Quality of Service (QoS) statistical data using either Versus Time or At Time reports.
.DESCRIPTION
	Request Quality of Service (QoS) statistical data using either Versus Time or At Time reports.
.PARAMETER VersusTime
	Request port statistics report using Versus Time reports.
.PARAMETER AtTime
	Request port statistics report using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values.
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE	
	PS:> Get-A9QoSIOPsReport -VersusTime -Frequency hires
	Cmdlet executed successfully

	sampleTime      : 2/26/2026 6:50:00 PM
	sampleTimeSec   : 1772157000
	IO              : @{min=300; max=10000; read=0; write=0; total=0}
	KBytes          : @{min=3000; max=30000; read=0; write=0; total=0}
	serviceTimeMS   : @{goal=300; latency=0; read=0; write=0; total=0}
	IOSizeKB        : @{read=0; write=0; total=0}
	waitTimeMS      : @{read=0; write=0; total=0}
	totalRejection  : 0
	queueLength     : 0
	waitQueueLength : 0

	This is the example output of a single record, while this command will return many records of this type.
.EXAMPLE	
	PS:> Get-A9QoSIOPsReport -VersusTime -Frequency hires -VvSetName "asvvset2"
.EXAMPLE 
	PS:> Get-A9QoSIOPsReport -AtTime -Frequency hires
.EXAMPLE
	PS:> Get-A9QoSIOPsReportt -AtTime -Frequency hires -Summary max
.EXAMPLE
	PS:> Get-A9QoSIOPsReport -VersusTime -Frequency daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9QoSIOPsReport -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency='hires',
		[Parameter(ParameterSetName='vs')]				[String]	$VvSetName,
		[Parameter(ParameterSetName='vs')]				[String]	$Domain,
		[Parameter(ParameterSetName='vs')]				[Switch]	$All_Others,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()]
		[ValidateSet('readIOPS','writeIOPS','totalIOPS','readKBytes', 'writeKBytes','totalKBytes','readServiceTimeMS','writeServiceTimeMS','totalServiceTimeMS','readIOSizeKB','writeIOSizeKB','totalIOSizeKB',
		'readWaitTimeMS','writeWaitTimeMS','totalWaitTimeMS','IOLimit','BWLimit','IOGuarantee','BWGuarantee','busyPct','queueLength','waitQueueLength','IORejection','latencyMS','latencyTargetMS')]	
														[String]	$ComparebyField,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime )	{	$uri = '/systemreporter/vstime/qosstatistics/'+$Frequency	}	
	if ( $AtTime )		{	$uri = '/systemreporter/attime/qosstatistics/'+$Frequency	}	
	if ( $VvSetName)	{	$lista = $VvSetName.split(",")		
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
	if($Domain) 		{	$lista = $Domain.split(",")		
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
	if ( $All_Others ) 	{	$uri = $uri+";sys:all_others"	}	
	if ( $Groupby ) 	{  	$uri = $uri+";groupby:$Groupby"	}
	if ( $Summary )  	{ 	$uri = $uri+";summary:$Summary"	}
    if ( $Compareby )	{	$uri = $uri+";compareby:$Compareby,"	
							if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
							else				{	return "NoOfRecords is mandatory with Compareby. "	}
							if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
							else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
						}		
	if($GETime)			{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
							if ( $LETime)	{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
												$flg = "No"
											}
							$addQuery = "Yes"
						}
	if($LETime)			{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
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
			else{	Write-Error "Failure:  While Executing Get-A9QoSStatisticalReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9QoSStatisticalReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9RCopyIOPsReport
{
<#
.SYNOPSIS	
	Request Remote Copy statistical data using either Versus Time or At Time reports.
.DESCRIPTION
	Request Remote Copy statistical data using either Versus Time or At Time reports.
.PARAMETER VersusTime
	Request port statistics report using Versus Time reports.
.PARAMETER AtTime
	Request port statistics report using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values.
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE 
	PS:> Get-A9RCopyIOPsReport -AtTime -Frequency hires
.EXAMPLE 
	PS:> Get-A9RCopyIOPsReport -AtTime -Frequency hires -NSP x:x:x
.EXAMPLE
	PS:> Get-A9RCopyIOPsReport -VersusTime -Frequency daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9RCopyIOPsReport -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency='hires',
		[Parameter(ParameterSetName='vs')]				[String]	$TargetName,
		[Parameter(ParameterSetName='vs')]
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
														[String]	$NSP,
		[Parameter()]									[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()][ValidateSet('kbs','kbps','hbrttms','targetName','linkId','linkAddr','node','slotPort','cardPort')]	
														[String]	$ComparebyField,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime )		{	$uri = '/systemreporter/vstime/remotecopystatistics/'+$Frequency	}	
	if ( $AtTime )			{	$uri = '/systemreporter/attime/remotecopystatistics/'+$Frequency	}	
	if ( $TargetName )		{ 	$uri = $uri+";targetName:$TargetName" 	}
	if ( $NSP )				{ 	$uri = $uri+";portPos:$NSP" 	}
	if ( $Groupby ) 		{  	$uri = $uri+";groupby:$Groupby"}
	if ( $Summary ) 		{ 	$uri = $uri+";summary:$Summary"}
    if ( $Compareby )		{	$uri = $uri+";compareby:$Compareby,"	
								if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
								else	{	return "NoOfRecords is mandatory with Compareby. "	}
								if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
								else	{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
							}		
	if($GETime)				{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
								if($LETime)
									{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
										$flg = "No"
									}
								$addQuery = "Yes"
							}
	if($LETime)				{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
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
			else{	Write-Error "Failure:  While Executing Get-A9RCopyStatisticalReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9RCopyStatisticalReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9RCopyVolumeIOPsReport
{
<#
.SYNOPSIS	
	Request statistical data related to Remote Copy volumes using either Versus Time or At Time reports.
.DESCRIPTION
	Request statistical data related to Remote Copy volumes using either Versus Time or At Time reports.
.PARAMETER VersusTime
	Request port statistics report using Versus Time reports.
.PARAMETER AtTime
	Request port statistics report using At Time reports.	
.PARAMETER Frequency
	Must be set to one of three values.
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE 
	PS:> Get-A9RCopyVolumeIOPsReport -AtTime -Frequency hires
.EXAMPLE
	PS:> Get-A9RCopyVolumeIOPsReport -VersusTime -Frequency hires -vvName xxx
.EXAMPLE
	PS:> Get-A9RCopyVolumeIOPsReport -VersusTime -Frequency hires -TargetName xxx
.EXAMPLE
	PS:> Get-A9RCopyVolumeIOPsReport -VersusTime -Frequency hires -Mode SYNC
.EXAMPLE
	PS:> Get-A9RCopyVolumeIOPsReport -VersusTime -Frequency hires -RCopyGroup xxx
.EXAMPLE
	PS:> Get-A9RCopyVolumeIOPsReport -VersusTime -Frequency hourly -Summary max
.EXAMPLE
	PS:> Get-A9RCopyVolumeIOPsReport -AtTime -Frequency hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9RCopyVolumeIOPsReport -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	

#>
[CmdletBinding()]
Param(
		[Parameter(Mandatory, ParameterSetName='vs')]		[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]		[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]				[String]	$Frequency='hires',
		[Parameter(ParameterSetName='vs')]					[String]	$vvName,
		[Parameter(ParameterSetName='vs')]					[String]	$TargetName,
		[Parameter(ParameterSetName='vs')]		
		[ValidateSet('SYNC','PERIODIC','ASYNC')]			[String]	$Mode,
		[Parameter(ParameterSetName='vs')]					[String]	$RCopyGroup,
		[Parameter()]										[String]	$Groupby,
		[Parameter()]										[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]			[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]					[int]		$NoOfRecords,
		[Parameter()]										[String]	$ComparebyField,
		[Parameter()]										[String]	$GETime,
		[Parameter()]										[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime )			{	$uri = '/systemreporter/vstime/remotecopyvolumestatistics/'+$Frequency	}	
	if ( $AtTime )				{	$uri = '/systemreporter/attime/remotecopyvolumestatistics/'+$Frequency	}	
	if ( $vvName )				{ 	$uri = $uri+";volumeName:$vvName" 	}
	if ( $TargetName )			{ 	$uri = $uri+";targetName:$TargetName" }
	If ( $Mode -eq "SYNC" ) 	{ 	$uri = $uri+";mode:1" }
	If ( $Mode -eq "PERIODIC" ) { 	$uri = $uri+";mode:3" }
	If ( $Mode -eq "ASYNC" ) 	{ 	$uri = $uri+";mode:4" }						
	if ( $RCopyGroup )			{	$uri = $uri+";remoteCopyGroup:$RCopyGroup" 	}		
	if ( $Groupby ) 			{  	$uri = $uri+";groupby:$Groupby"}
	if ( $Summary ) 			{ 	$uri = $uri+";summary:$Summary"}
    if ( $Compareby )			{ 	$uri = $uri+";compareby:$Compareby,"
									if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
									else				{	return "NoOfRecords is mandatory with Compareby. "	}
									if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
									else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
								}		
	if ( $GETime)				{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
									if ( $LETime)	{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
														$flg = "No"
													}
									$addQuery = "Yes"
								}
	if ( $LETime)				{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
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
			else{	Write-Error "Failure:  While Executing Get-A9RCopyVolumeStatisticalReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9RCopyVolumeStatisticalReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9vLunIOPsReport
{
<#
.SYNOPSIS	
	Request VLUN statistics data using either Versus Time or At Time reports.
.DESCRIPTION
	Request VLUN statistics data using either Versus Time or At Time reports.
.PARAMETER VersusTime
	Request VLUNstatistics data using Versus Time reports.
.PARAMETER AtTime
	Request VLUN statistics data using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values.
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE 
	PS:> Get-A9vLunIOPsReport -AtTime -Frequency hires
.EXAMPLE
	PS:> Get-A9vLunIOPsReport -VersusTime -Frequency hires -VlunId 1
.EXAMPLE
	PS:> Get-A9vLunIOPsReport -VersusTime -Frequency hires -VvName Test
.EXAMPLE
	PS:> Get-A9vLunIOPsReport -AtTime -Frequency hourly -VvSetName asvvset
.EXAMPLE
	PS:> Get-A9vLunIOPsReport -VersusTime -Frequency hourly -NSP "1:0:1"
.EXAMPLE
	PS:> Get-A9vLunIOPsReport -VersusTime -Frequency daily -HostName asHost
.EXAMPLE
	PS:> Get-A9vLunIOPsReport -VersusTime -Frequency daily -HostSetName asHostSet
.EXAMPLE
	PS:> Get-A9vLunIOPsReport -VersusTime -Frequency daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9vLunIOPsReport -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency='hires',
		[Parameter(ParameterSetName='vs')]				[int]		$VlunId,
		[Parameter(ParameterSetName='vs')]				[String]	$VvName,
		[Parameter(ParameterSetName='vs')]				[String]	$HostName,
		[Parameter(ParameterSetName='vs')]				[String]	$VvSetName,
		[Parameter(ParameterSetName='vs')]				[String]	$HostSetName,
		[Parameter(ParameterSetName='vs')]
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
														[String]	$NSP,
		[Parameter()][ValidateSet('domain','volumeName','hostname','lun','hostWWN','node','slot','vvsetName','hostsetName','cardPort')]
														[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()][ValidateSet('totalIOPs')]			[String]	$ComparebyField,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime )				{	$uri = '/systemreporter/vstime/vlunstatistics/'+$Frequency	}	
	if ( $AtTime )					{	$uri = '/systemreporter/attime/vlunstatistics/'+$Frequency	}	
	if ( $VlunId ) 					{ 	$uri = $uri+";lun:$VlunId"	}
	if ( $VvName ) 					{ 	$uri = $uri+";volumeName:$VvName"	}
	if ( $HostName ) 				{ 	$uri = $uri+";hostname:$HostName"	}
	if ( $VvSetName ) 				{ 	$uri = $uri+";volumeName:set:$VvSetName"	}
	if ( $HostSetName ) 			{ 	$uri = $uri+";hostname:set:$HostSetName"	}
	if ( $NSP )						{ 	$uri = $uri+";portPos:$NSP"	}	
	if ( $Groupby ) 				{  	$uri = $uri+";groupby:$Groupby"}
	if ( $Summary ) 				{ 	$uri = $uri+";summary:$Summary"}
    if ( $Compareby )				{	$uri = $uri+";compareby:$Compareby,"	
										if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
										else				{	return "NoOfRecords is mandatory with Compareby. "	}
										if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
										else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"	}		
									}		
	if ( $GETime )					{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
										if($LETime)
											{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
												$flg = "No"
											}
										$addQuery = "Yes"
									}
	if ( $LETime )					{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
										$addQuery = "Yes"		
									}	
	if($addQuery -eq "Yes")			{	$uri = $uri+$Query	}
	$Result = Invoke-A9API -uri $uri -type 'GET'
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members	
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-A9vLunStatisticsReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9vLunStatisticsReports." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9VvSpaceReport
{
<#
.SYNOPSIS	
	Request volume space data using either Versus Time or At Time reports.
.DESCRIPTION
	Request volume space data using either Versus Time or At Time reports.
.PARAMETER VersusTime
	Request  volume space data using Versus Time reports.
.PARAMETER AtTime
	Request  volume space data using At Time reports.
.PARAMETER Frequency
	Must be set to one of three values. if unselected, the parameter will default to 'hires'
	hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
	hourly = As part of the report identifier.
	daily = As part of the report identifier
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
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE 
	PS:> Get-A9VvSpaceReports -AtTime -Frequency hires
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency hires -VvName xxx
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency hires -UserCPG ascpg
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency hires -ProvType 1
.EXAMPLE
	PS:> Get-A9VvSpaceReports -VersusTime -Frequency hires -Groupby id
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency hires -VvName xxx
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency hires -VvSetName asVVSet
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency hires -SnapCPG assnpcpg
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency hires -Groupby id
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency hires -Summary max
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency hires -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9VvSpaceReports -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='vs')]	[Switch]	$VersusTime,
		[Parameter(Mandatory, ParameterSetName='at')]	[Switch]	$AtTime,
		[Parameter(Mandatory)]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency,
		[Parameter(ParameterSetName='vs')]				[String]	$VvName,
		[Parameter(ParameterSetName='vs')]				[String]	$VvSetName,
		[Parameter(ParameterSetName='vs')]				[String]	$UserCPG,
		[Parameter(ParameterSetName='vs')]				[String]	$SnapCPG,
		[Parameter(ParameterSetName='vs')]				[String]	$ProvType,
		[Parameter()][ValidateSet('id','name','baseId','wwn','snapCPG','userCPG')]
														[String]	$Groupby,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()][ValidateSet('totalSpaceUsedMiB','userSpaceUsedMiB','snapshotSpaceUsedMiB','userSpaceFreeMiB','snapshotSpaceFreeMiB','compaction','compression')]	
														[String]	$ComparebyField,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$flg = "Yes"
	$addQuery = "No"
	$Query="?query=""  """
	if ( $VersusTime)		{	$uri = '/systemreporter/vstime/volumespacedata/'+$Frequency		}	
	if ( $AtTime)			{	$uri = '/systemreporter/attime/volumespacedata/'+$Frequency		}	
	if ( $VvName) 			{ 	$uri = $uri+";name:$VvName"			}
	if ( $VvSetName) 		{ 	$uri = $uri+";name:set:$VvSetName"	}
	if ( $UserCPG) 			{ 	$uri = $uri+";userCPG:$UserCPG"		}
	if ( $SnapCPG) 			{ 	$uri = $uri+";snapCPG:$SnapCPG"		}
	if ( $ProvType) 		{ 	$uri = $uri+";provType:$ProvType"	}		
	if ( $Groupby) 			{ 	$uri = $uri+";groupby:$Groupby"		}
	if ( $Summary) 			{ 	$uri = $uri+";summary:$Summary"		}
    if ( $Compareby)		{	$uri = $uri+";compareby:$Compareby,"	
								if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","	}
								else				{	return "NoOfRecords is mandatory with Compareby. "	}
								if($ComparebyField)	{	$uri = $uri+$ComparebyField	}
								else				{	return "ComparebyField is mandatory with Compareby.please see the parameter help for this"		}		
							}
	if ( $GETime)			{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
								if($LETime)
									{	$Query = $Query.Insert($Query.Length-3," AND sampleTime LE $LETime")
										$flg = "No"
									}
								$addQuery = "Yes"
							}
	if ( $LETime)			{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
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
			else{	Write-Error "Failure:  While Executing Get-A9VvSpaceReports. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9VvSpaceReports." 
			return $Result.StatusDescription
		}
}	
}

