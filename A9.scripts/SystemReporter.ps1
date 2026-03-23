## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9SystemReportStats
{
<#
.SYNOPSIS	
	Cache memory or CPU statistics data reports
.DESCRIPTION
	Cache memory or CPU statistics data reports.Request cache memory statistics data using either Versus Time or At Time reports.
.PARAMETER CacheReport
	Show the values for a Cache Report
.PARAMETER CPUReport
	Show the values for a CPU Report
.PARAMETER AtTime
	Request cache memory statistics data using At Time reports. If this is unset, the default behaviour will be to use VersusTime instead of AT Time. 
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
	Valid values are 'top' or 'bottom', Specifies whether to display the top records or the bottom records. 
	If a Comparebyfield is selected, and this is left unselected, the code will assume the default of 'top'.
.PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
	If a Comparebyfield is selected, and this is left unselected, the code will assume the default of 1.
.PARAMETER CacheComparebyField
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
.PARAMETER CPUComparebyField
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
	PS:> Get-A9SystemReport -AtTime -Frequency hires -CPUReport
.EXAMPLE  
	PS:> Get-A9SystemReport -VersusTime -Frequency hires -CPUReport | format-table
	Cmdlet executed successfully

	node cpu 	userPct 	systemPct 	idlePct interruptsPerSec contextSwitchesPerSec
	---- --- 	------- 	--------- 	------- ---------------- ---------------------
	0    0   	42.20      	3.00   		54.80         31789.50              77353.40
	0    1   	37.20      	2.70   		60.10             0.00                  0.00
	0    10    	8.60      	1.00   		90.50             0.00                  0.00
	0    11    	6.50      	1.10   		92.40             0.00                  0.00
.EXAMPLE  
	PS:> Get-A9SystemReport -VersusTime -Frequency hires -NodeId 1 -CPUReport
.EXAMPLE  
	PS:> Get-A9SystemReport -VersusTime -Frequency hires -Groupby cpu -CPUReport
.EXAMPLE	
	PS:> Get-A9SystemReport -VersusTime -Frequency hires 

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
	PS:> Get-A9SystemReportStats -Frequency hires -NodeId 1 -CPUReport

.EXAMPLE
	PS:> Get-A9SystemReportStats -AtTime -Frequency hires -NodeId 1 -CacheReport
.EXAMPLE
	PS:> Get-A9SystemReportStats -AtTime -Frequency hires -Groupby node -CacheReport
.EXAMPLE
	PS:> Get-A9SystemReportStats -Frequency hires -Summary min -CacheReport
.EXAMPLE
	PS:> Get-A9SystemReportStats -Compareby bottom -NoOfRecords 2 -ComparebyField hitIORead -CacheReport
.EXAMPLE	
	PS:> Get-A9SystemReportStats -Frequency hires -GETime 2018-07-18T13:20:00+05:30 -LETime 2018-07-18T13:25:00+05:30  -CacheReport
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='Cache')]	[switch]	$CacheReport,
		[Parameter(Mandatory, ParameterSetName='CPU')]		[switch]	$CPUReport,
		[Parameter()]										[Switch]	$AtTime,
		[Parameter()][ValidateSet('hires','hourly','daily')][String]	$Frequency='hires',
		[Parameter()][Validaterange(0,7)]					[String]	$NodeId,
		[Parameter()]										[String]	$Groupby,
		[Parameter()]										[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]			[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]					[int]		$NoOfRecords,	
		[Parameter(ParameterSetName='Cache')]	
		[ValidateSet('hitIORead','hitIOWrite','missIORead','missIOWrite','accessIORead','accessIOWrite','hitPctRead','hitPctWrite','totalAccessIO','lockBulkIO','pageStatisticDelayAckPagesNL_7','pageStatisticDelayAckPagesFC',
					'pageStatisticDelayAckPagesSSD','pageStatisticPageStatesFree','pageStatisticPageStatesClean','pageStatisticPageStatesWriteOnce','pageStatisticPageStatesWriteMultiple','pageStatisticPageStatesWriteScheduled',
					'pageStatisticPageStatesWriteing','pageStatisticPageStatesDcowpend','pageStatisticDirtyPagesNL','pageStatisticDirtyPagesFC','pageStatisticDirtyPagesSSD','pageStatisticMaxDirtyPagesNL_7',
					'pageStatisticMaxDirtyPagesFC','pageStatisticMaxDirtyPagesSSD')]
															[String]	$CacheComparebyField,		
		[Parameter(ParameterSetName='CPU')]
		[ValidateSet('userPct','systemPct','idlePct','interruptsPerSec','contextSwitchesPerSec')]
															[String]	$CPUComparebyField,
		[Parameter()]										[String]	$GETime,
		[Parameter()]										[String]	$LETime					
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	if ( $AtTime )				{	$uri = "/systemreporter/attime/" 
									$Query="?query=""  """	
									if ( $GETime)	{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
														if ( $LETime)	{	$Query = $Query.Insert($Query.Length-3," AND")	}
													}
									if ( $LETime)	{	if($flg -eq "Yes")	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}	
													}
								}
	else 						{	$uri = "/systemreporter/vstime/"	
									if ( $NodeId) 	{ 	$uri = $uri+";node:$NodeId"		}
									if ( $LETime -or $GETime ) { 	Write-warning "When using AtTime, the DiskType or LETime or GETime are not used" }
								}
	$CompareByField=$null
	Switch -wildcard ($PSCmdlet.ParameterSetName)
		{	"Cache*"	{	$uri = $uri + 'cachememorystatistics/' + $Frequency		
							$CompareByField = $CacheCompareByField 
						}
			"CPU*"		{	$uri = $uri + 'cpustatistics/' + $Frequency
							$CompareByField = $CacheCompareByField	
						}
		}
	if ( $Groupby) 				{ 	$uri = $uri+";groupby:$Groupby"	}
	if ( $Summary) 				{ 	$uri = $uri+";summary:$Summary"	}
	if ( $ComparebyField)		{ 	if ( $CompareBy ) 	{	$uri = $uri+";compareby:$Compareby,"	}
									else				{	$uri = $uri+";compareby:top,"			}	
									if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","			}
									else				{	$uri = $uri+"1,"						}
									$uri = $uri+$ComparebyField			
								}			
	if ( ( $LETime -or $GETime) -and $ATTime )		{	$uri = $uri+$Query	}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)	{	write-host "Cmdlet executed successfully" -foreground green
										return $dataPS
									}
			else					{	Write-Error "Failure:  While Executing PS:> Get-A9SystemReport. Expected Result Not Found with Given Filter Option ." 
										return 
									}
		}
	else{	Write-Error "Failure:  While Executing Get-A9SystemReport." 
			return $Result.StatusDescription
		}
}	
}

Function Get-A9SpaceReport
{
<#
.SYNOPSIS	
	CPG, Volume, or PhysicalDisk, or LogicalDisk space data using either Versus Time or At Time reports.
.DESCRIPTION
	CPG, Volume, or PhysicalDisk, or LogicalDisk space data using either Versus Time or At Time reports.
.PARAMETER CPGSpaceReport
	WIll return a Space report specifically against CPG Space usage.
.PARAMETER VolumeSpaceReport
	WIll return a Space report specifically against Volume Space usage.
.PARAMETER PhysicalDiskSpaceReport
	WIll return a Space report specifically against Physical Disk Space usage.
.PARAMETER LogicalDiskSpaceReport
	WIll return a Space report specifically against Logical Disk Space usage.
.PARAMETER AtTime
	Request CPG, Volume, or PhysicalDisk, or LogicalDisk space data using At Time reports. If not specified, the command will use VersusTime
.PARAMETER Frequency
	Must be set to one of three values. If unset, it will assume the 'hires' option
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
.PARAMETER RPM
	Specifies the RPM speeds to query for physical disk capacity data. With no speed indicated, the system calculates physical disk capacity data for all speeds in the system. 
	Valid RPM values are: 7,10,15,100,150.
.PARAMETER Id
	Requests disk capacity data for the specified disks only. For example, specify id:1,3,2. With no id specified, the system calculates physical disk capacity for all disks in the system.
.PARAMETER DiskType
	The CPG, Volume, or PhysicalDisk space sample data is for the specified disk types. With no disk type specified, the system calculates the CPG space sample data is for all the disk types in the system.
	FC : Fibre Channel
	NL : Near Line
	SSD : SSD
	SCM : SCM Disk type
	QLC : QLC Disk type	
.PARAMETER CpgName
	Indicates that the CPG, Volume, or PhysicalDisk space sample data is only for the specified CPG names. With no name specified, the system calculates the CPG space sample data for all CPGs.
.PARAMETER Summary
	Provide at least one of the mandatory field names, and use a comma (,) to separate multiple fields.
	Mandatory 
	min : Display the minimum for each metric.
	max : Display the maximum for each metric.
	avg : Display the average for each metric.
	pct : Displays the percentile for each metric where pct is any floating number from 0 to 100. Separate multiple	pct with a comma (,).
.PARAMETER Compareby
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. Choose one.
.PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
.PARAMETER CPGComparebyField
	please select any one from
	totalSpaceMiB : Total space in MiB.
	freeSpaceMiB : Free space in MiB.
	usedSpaceMiB : Used space in MiB
	compaction : Compaction ratio.
	compression : Compression ratio.
	deduplication : Deduplication ratio.
	dataReduction : Data reduction ratio.
.PARAMETER VolumeComparebyField
	please select any one from
		totalSpaceUsedMiB : Total used space in MiB.
		userSpaceUsedMiB : Used user space in MiB.
		snapshotSpaceUsedMiB : Used snapshot space in MiB
		userSpaceFreeMiB : Free user space in MiB.
		snapshotSpaceFreeMiB : Free snapshot space in MiB.
		compaction : Compaction ratio.
		compression : Compression ratio.
.PARAMETER PhysicalDiskCompareByField
	Please select any one from 
		'totalIOPs','normalChunkletsUsedOK','normalChunkletsUsedFailed','normalChunkletsAvailClean','normalChunkletsAvailDirty','normalChunkletsAvailFailed','spareChunkletsUsedOK',
		'spareChunkletsUsedFailed','spareChunkletsAvailClean','spareChunkletsAvailDirty','spareChunkletsAvailFailed','lifeLeftPct','temperatureC'
.PARAMETER CPGGroupby  
	Group the sample data into categories. With no category specified, the system groups data into all
	categories. Separate multiple groupby categories using a comma (,) and no spaces. Use the structure,
	groupby:domain,id,name,diskType,RAIDType.
.PARAMETER VolumeGroupby
	id | name | baseId | wwn | snapCPG | userCPG
	Optional parameter that groups sample data into specified categories. With no category specified, the system groups data into all categories. To specify multiple groupby categories, separate them using a comma (,). For example: domain,id,name,baseId,WWN.
.PARAMETER PhysicalDiskGroupby
	id | cageID | cageSide | mag | diskPos | type | RPM
	Groups the sample data into specified categories. With no category specified, the system groups data into all categories. To specify multiple groupby categories, separate them using a comma (,). For example, id,type,RPM.
.PARAMETER BeginTimeSecs
	Selects the begin time in seconds for the report. The value can be specified as either:
		The absolute epoch time (for example 1351263600).

		The absolute time as a text string in one of the following formats:
			Full time string including time zone: "2012-10-26 11:00:00 PDT"

			Full time string excluding time zone: "2012-10-26 11:00:00"

			Date string: "2012-10-26" or 2012-10-26

			Time string: "11:00:00" or 11:00:00

		A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).

		If it is not specified then the time at which the report begins is 12 hours ago.

		If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER EndTimeSecs
	Selects the end time in seconds for the report. The value can be specified as either
	The absolute epoch time (for example 1351263600).

		The absolute time as a text string in one of the following formats:
			Full time string including time zone: "2012-10-26 11:00:00 PDT"

			Full time string excluding time zone: "2012-10-26 11:00:00"

			Date string: "2012-10-26" or 2012-10-26

			Time string: "11:00:00" or 11:00:00

		A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).

		If it is not specified then the report ends with the most recent sample.

		Specifying an etsecs value in the future, prefixed by "+", will provide a forecast of the space statistics. Either absolute or relative time may be specified, such as "+2017-03-24" or "+2d".
.PARAMETER LogicalDiskGroupBy
	For -attime reports, generate a separate row for each combination of <groupby> items. Each <groupby> must be different and one of the following:
		DOM_NAME—Domain name
		CPG_NAME—Common Provisioning Group name
		LDID—Logical disk ID
		LD_NAME—Logical disk name
		SET_SIZE—The RAID set size of the LD
		STEP_SIZE—The RAID step size of the LD
		ROW_SIZE—The RAID row size of the LD
		OWNER—The owner node for the LD
.PARAMETER LogicalDiskName
	LDs matching either the specified LD_name or glob-style pattern are included. This specifier can be repeated to display information for multiple LDs. If not specified, all LDs are included.
.PARAMETER LogicalDiskCompareByField
	The field used for comparison can be any of the groupby fields or one of the following: Raw_MB, Used_MB, Free_MB, Total_MB
.PARAMETER GETime
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30
.EXAMPLE
	PS:> Get-A9SpaceReport -VersusTime -Frequency hires -cpgSpaceReport
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
	PS:> Get-A9SpaceReport -VersusTime -Frequency hires -GETime 2018-07-18T13:20:00+05:30 -LETime 2018-07-18T13:25:00+05:30  
.EXAMPLE
	PS:> Get-A9SpaceReport -VersusTime -Frequency hires -LETime 2018-07-18T13:25:00+05:30
#>
[CmdletBinding()]
Param(	
		[Parameter(Mandatory,ParameterSetName='CPG')]		[switch]	$CPGSpaceReport,
		[Parameter(Mandatory,ParameterSetName='Volume')]	[switch]	$VolumeSpaceReport,
		[Parameter(Mandatory,ParameterSetName='PD')]		[switch]	$PhysicalDiskSpaceReport,
		[Parameter(Mandatory,ParameterSetName='LD')]		[switch]	$LogicalDiskSpaceReport,
		
		[Parameter()]										[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('Hires','Hourly','Daily')]				[String]	$Frequency='hires',
		[Parameter(ParameterSetName='CPG')]
		[Parameter(ParameterSetName='LD')]					[String]	$CpgName,
		[Parameter(ParameterSetName='PD')]
		[Parameter(ParameterSetName='CPG')]
		[ValidateSet('FC','NL','SSD','SCM','QLC')]			[String]	$DiskType,
		[Parameter(ParameterSetName='CPG')]
		[ValidateSet('domain','id','name','diskType')]		[String]	$CPGGroupby,
		[Parameter()][ValidateSet('min','max','avg','pct')]	[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]			[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]					[int]		$NoOfRecords,
		[Parameter(ParameterSetName='CPG')]	
		[ValidateSet('totalSpaceMiB','freeSpaceMiB','usedSpaceMiB','compaction','compression','deduplication','dataReduction')]	
															[String]	$CPGComparebyField,	
		[Parameter(ParameterSetName='PD')]					[String]	$Id,
		[Parameter(ParameterSetName='PD')]			
		[ValidateSet(7,10,15,100,150)]						[String]	$RPM,
		[Parameter(ParameterSetName='PD')]
		[ValidateSet('id','cageID','cageSide','mag','diskPos','type','RPM')]	
															[String]	$PhysicalDiskGroupby,
		[Parameter(ParameterSetName='PD')]
		[ValidateSet('totalIOPs','normalChunkletsUsedOK','normalChunkletsUsedFailed','normalChunkletsAvailClean','normalChunkletsAvailDirty','normalChunkletsAvailFailed','spareChunkletsUsedOK','spareChunkletsUsedFailed','spareChunkletsAvailClean','spareChunkletsAvailDirty','spareChunkletsAvailFailed','lifeLeftPct','temperatureC')]	
															[String]	$PhysicalDiskCompareByField,				
		[Parameter(ParameterSetName='Volume')]				[String]	$VvName,
		[Parameter(ParameterSetName='Volume')]				[String]	$VvSetName,
		[Parameter(ParameterSetName='Volume')]				[String]	$UserCPG,
		[Parameter(ParameterSetName='Volume')]				[String]	$SnapCPG,
		[Parameter(ParameterSetName='Volume')]				[String]	$ProvType,
		[Parameter(ParameterSetName='Volume')][ValidateSet('id','name','baseId','wwn','snapCPG','userCPG')]
															[String]	$VolumeGroupby,
		[Parameter(ParameterSetName='Volume')][ValidateSet('totalSpaceUsedMiB','userSpaceUsedMiB','snapshotSpaceUsedMiB','userSpaceFreeMiB','snapshotSpaceFreeMiB','compaction','compression')]	
															[String]	$VolumeComparebyField,

		[Parameter(ParameterSetName='LD')]					[String]	$BeginTimeSecs,
		[Parameter(ParameterSetName='LD')]					[String]	$EndTimeSecs,
		[Parameter(ParameterSetName='LD')]
		[ValidateSet("DOM_NAME","CPG_NAME","LDID","LD_NAME","DISK_TYPE","RAID_TYPE","SET_SIZE","STEP_SIZE","ROW_SIZE","OWNER")]
															[String]	$LogicalDiskGroupBy,
		[Parameter(ParameterSetName='LD')]					
		[ValidateSet('Raw_MB', 'Used_MB', 'Free_MB', 'Total_MB')]
															[String]	$LogicalDiskCompareByField,
		[Parameter(ParameterSetName='LD')]					[String]	$LogicalDiskName,
		[Parameter(ParameterSetName='LD')][ValidateRange(0,7)][String]	$OwnerNode,
		[Parameter(ParameterSetName='LD')]					[switch]	$ShowRaw													
	)
Begin 
{	Test-A9Connection -ClientType 'API'
	IF ( -not ( Test-A9Connection -ClientType SSHClient -returnBoolean) -and $LogicalDiskSpaceReport ) 
		{	write-warning "This Option Requires a SSH type connnection and one was not detected. "
			Test-A9Connection -ClientType SSHClient
		}	
}
Process 
{	if ( $AtTime)	{	$uri = '/systemreporter/attime/' 	
						$Query="?query=""  """
						if ( $GETime )	{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
											if($LETime)	{	$Query = $Query.Insert( $Query.Length-3," AND" )	}
										}
						if ( $LETime )	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")		
										}
					}
	else			{	$uri = '/systemreporter/vstime/'	
						if ( $LETime -or $GETime ) 	{ 	Write-warning "When using AtTime, the DiskType or LETime or GETime are not used" }	
					}
	$CompareByField = $null
	$DiskTypeEnum = @{'FC'=1; 'NL'=2; 'SSD'=3; 'SCM'=4; 'QLC'=5}
	Switch -wildcard ($PSCmdlet.ParameterSetName)
		{	"CPG*"	
				{	$uri = $uri + 'cpgspacedata/'+$Frequency
					if ( $AtTime ) 			{ 	if ($DiskType -or $CPGName)	{ 	Write-warning "When using AtTime, the DiskType or CPGName are not used" }
											}
					else					{ 	if ( $CpgName )				{	$uri = $uri+';name:'+$cpgname	}
												if ( $DiskType )			{	$uri = $uri+";diskType:"+$DiskTypeEnum[$DiskType] }
											}
					if ( $CPGGroupby ) 		{  	$uri = $uri+";groupby:$CPGGroupby"			}
					if ( $CPGCompareByField){	$CompareByField = $CPGCompareByField 	}	
				}
			"PD"
				{	$uri = $uri + 'physicaldiskcapacity/'+$Frequency
					if ( $AtTime )		{	if ($Disktype -or $RPM -or $id) {	Write-warning "When using AtTime, the DiskType or RPM or ID Are not used" 	}
										}	
					else 				{	if ( $Id) 					{ 	$uri = $uri+";id:$Id"	}
											if ( $DiskType )			{	$uri = $uri+";diskType:"+$DiskTypeEnum[$DiskType] }	
											if ( $RPM) 					{ 	$uri = $uri+";RPM:$RPM"	}
										}
					if ( $PhyscialDiskGroupby )		{  	$uri = $uri+";groupby:$PhysicalDiskGroupby"}	
					if ( $PhysicalDiskComparebyField ){	$CompareByField = $PhysicalDiskCompareByField }	
				}
			"Volume"
				{	$uri = $Uri + 'volumespacedata/'+$Frequency
					if ( -not $AtTime )		{	if ( $VvName ) 			{ 	$uri = $uri+";name:$VvName"			}
												if ( $VvSetName ) 		{ 	$uri = $uri+";name:set:$VvSetName"	}
												if ( $UserCPG ) 		{ 	$uri = $uri+";userCPG:$UserCPG"		}
												if ( $SnapCPG ) 		{ 	$uri = $uri+";snapCPG:$SnapCPG"		}
												if ( $ProvType ) 		{ 	$uri = $uri+";provType:$ProvType"	}
											}
					else 					{	if ( $VVName -or $VVSetName -or $UserCPG -or $SnapCPG -or $ProvType)	{	write-host "The Values VolumeName, VolumeSet, UserCPG, SnapCPG, or ProvisingType are not used when using AT Time and will be ignored."	}
											}	
					if ( $VolumeGroupby ) 		{ 	$uri = $uri+";groupby:$VolumeGroupby"	}
					if ( $VolumeComparebyField ){	$CompareByField = $VolumeCompareByField }							
				}
			'LD'
				{	$tempFile = [IO.Path]::GetTempFileName()
					$cmd = "srldspace"
					if ( $BeginTimeSecs )				{	$cmd += " -btsecs $BeginTimeSecs"		}
					if ( $EndTimeSecs )					{	$cmd += " -etsecs $EndTimeSecs"		}
					if ( $LogicalDiskGroupBy )			{	$cmd += " -groupby $LogicalDiskGroupBy"		}			
					if ( $Frequency )					{	$cmd += " -" + $Frequency.ToLower()	}
					if ( $CpgName )						{	$cmd += " -cpg $cpgName"				}
					if ( $OwnerNode )					{	$cmd +=  " -owner $ownernode"			}
					if ( $LogicalDiskName )				{	$cmd += " $LDName"					}
					if ( $LogicalDiskCompareByField )	{	if ( $CompareBy ) 	{ 	$cmd += " -compareby $CompareBy," 	}
															else 				{	$cmd += " -compareby top," 			}
															if ( $NoOfRecords )	{	$cmd += $NoOfRecords+','			}
															else 				{	$cmd += '1,'						}
															$cmd += $LogicalDiskCompareByField
														}
					if($attime)	{	$srinfocmd += " -attime "
									if($LogicalDiskGroupBy)	{	$optionname = $LogicalDiskGroupBy }
									Add-Content -Path $tempFile -Value "$optionname,Raw(MB),Used(MB),Free(MB),Total(MB)"
									$rangestart = "3"
								}
					else		{	Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,Raw(MB),Used(MB),Free(MB),Total(MB)"
									$rangestart = "2"
								}
					write-verbose "System reporter command => $srinfocmd"
					$Result = Invoke-A9CLICommand -cmds  $srinfocmd
					if (-not $ShowRaw -or $Result.count -le 3)
						{	foreach ($s in  $Result[$rangestart..($Result.count)] )
								{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
									Add-Content -Path $tempFile -Value $s
								}
							$Result = Import-Csv $tempFile
						}
					Remove-Item  $tempFile
					return $Result
				}	
		}
	if ( $Summary ) 		{ 	$uri = $uri+";summary:$Summary"			}
	If ( $CompareByField )	{	If ( $CompareBy )	{	$uri = $uri+";compareby:$Compareby," 	}
								else 				{	$uri = $uri+";compareby:top,"			}
								if($NoOfRecords)	{	$uri = $uri+$NoOfRecords+","			}
								else 				{	$uri = $uri+"1,"						}
								$uri = $uri+$ComparebyField	
							}
	if ( ($LETime -or $GETime) -and $AtTime )	{	$uri = $uri+$Query	}
	$Result = Invoke-A9API -uri $uri -type 'GET' 
	if ( $Result.StatusCode -eq 200 )
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if ( $dataPS.Count -gt 0 )
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-A9*SpaceReport. Expected Result Not Found with Given Filter Option ." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-A9*SpaceReports." 
			return $Result.StatusDescription
		}
}	
}


Function Get-A9IOPsReport
{
<#
.SYNOPSIS	
	physical disk, vLun, QoS, Port, RCopy statistics reports using either Versus Time or At Time reports.
.DESCRIPTION
	physical disk statistics reports using either Versus Time or At Time reports.
.PARAMETER AtTime
	Request Physical disk capacity using At Time reports. If this value is NOT selected, it will assume you want to use VsTime. 
.PARAMETER Frequency
	Must be set to one of three values. If left inset, will assume hires.
		hires = As part of the report identifier,  hires—based on 5 minutes (high resolution)
		hourly = As part of the report identifier.
		daily = As part of the report identifier
.PARAMETER Id
	Requests disk capacity data for the specified disks only. For example, specify id:1,3,2. With no id specified, the system calculates physical disk capacity for all disks in the system.
.PARAMETER DiskType
	Specifies the disk types to query for physical disk capacity sample data. With no disktype specified, the system calculates physical disk capacity for all disk types in the system.
		FC : Fibre Channel
		NL : Near Line
		SSD : Solid State Disk
		SCM : Storage Class Memory
		QLC : QLC type Flash Storage
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
	It should be either top or bottom, Specifies whether to display the top records or the bottom records. If unseelected, and a CompairByField is used, it will assume Top.
.PARAMETER NoOfRecords
	Specifies the number of records to return in the range of 1 to 32 (Versus TIme) and 1 to 128 (At Time).
.PARAMETER vLunComparebyField
	please select any one from
	totalIOPs : Total IOPs.
.PARAMETER VlunId
	Requests data for the specified VLUNs only. For example, specify lun:1,2,4. With no lun specified, the system calculates performance data for all VLUNs in the system
.PARAMETER Volume
	Retrieves data for the specified volume or volumeset only. Specify the volumeset as volumeName:set:<vvset_name>. With no volumeName specified, the system calculates VLUN performance data for all the VLUNs in the system.
.PARAMETER HostName
	Retrieves data for the specified host or hostset only. Specify the hostset as hostname:set:<hostset_name>. With no hostname specified, the system calculates VLUN performance data for all the hosts in the system.
.PARAMETER VolumeSet
	Specify the VV set name.
.PARAMETER HostSetName
	Specify the Host Set Name.
.PARAMETER NSP
	Retrieves data for the specified ports. For example, specify portPos: 1:0:1,2:1:3,6:2:1. With no portPos specified, the system calculates VLUN performance data for all ports in the system.
.PARAMETER vLunGroupby
	domain | volumeName | hostname| lun | hostWWN | node | slot | vvsetName | hostsetName | cardPort
	Groups sample data into specified categories. With no category specified, the system groups data into all categories. 
.PARAMETER CPGGroupBy
	Specifies the grouping; valid values are by {name,domain}.
.PARAMETER CPGComparebyField
	please select any one from
	totalIOPs : Total number of IOPs
.PARAMETER vLunComparebyField
	please select any one from
		totalIOPs : Total IOPs.
.PARAMETER TargetName
	Specify the target from which to gather Remote Copy statistics. Separate multiple target names using a comma (,). 
	With no target specified, the request calculates Remote Copy statistics for all targets in the system. Use the structure, targetName:<target1>,<target2> . . .
.PARAMETER NSP
	Specify the port from which to gather Remote Copy statistics. Separate multiple port positions with a
	comma (,) Use the structure, <n:s:p>,<n:s:p> . . .. With no port specified, the request
	calculates Remote Copy statistics for all ports in the system.
.PARAMETER RCopyGroupby
	Group Remote Copy statistical data into categories. With no groupby parameter specified, the system groups the data into all categories. 
	{ targetName | linkId | linkAddr | node | slotPort | cardPort } .  
.PARAMETER RCopyComparebyField
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
.PARAMETER Domain
	Retrieve QoS statistics for the specified domain. Use the structure, domain:<domain_name>, or specify multiple domains using domain_name1,domain_name2...
.PARAMETER All_Others
	Specify all host I/Os not regulated by any active QoS rule. Use the structure, all_others
.PARAMETER QoSGroupby
	Group QoS statistical data into categories. With no groupby parameter specified, the system groups the
	data into all categories. You can specify one or more groupby categories by separating them with a
	comma. Use the structure, groupby:domain,type,name,ioLimit.
.PARAMETER QoSComparebyField
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
.PARAMETER PortGroupby
	node | slot | cardPort | type | speed
	Groups the sample data into specified categories. With no category specified, the system groups data into all categories. To specify multiple groupby categories, separate them using a comma (,). For example, slot,cardPort,type. 
.PARAMETER PortComparebyField
	please select any one from
	totalIOPs : Total IOPs.
.PARAMETER GETime
	Gerater than time For At Time query expressions, you can use the sampleTime parameter.
	Time format should be like this: 2018-07-18T13:25:00+05:30  
.PARAMETER LETime
	Lase than time For At Time query expressions, you can use the sampleTime parameter
	Time format should be like this: 2018-07-18T13:25:00+05:30

	PS:> Get-A9PDIOPsReport -CPGIOPsReport -AtTime -Frequency daily -Compareby top -NoOfRecords 10 -ComparebyField totalSpaceMiB
.EXAMPLE
	PS:> Get-A9PDIOPsReport -CPGIOPsReport -AtTime -Frequency hires -GETime "2018-04-09T09:20:00+05:30" -LETime "2018-04-09T12:20:00+05:30"	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory, ParameterSetName='Disk')]	[switch]	$DiskIOPsReport,
		[Parameter(Mandatory, ParameterSetName='Port')]	[switch]	$PortIOPsReport,
		[Parameter(Mandatory, ParameterSetName='CPG')]	[switch]	$CPGIOPsReport,
		[Parameter(Mandatory, ParameterSetName='vLun')]	[switch]	$vLunIOPsReport,
		[Parameter(Mandatory, ParameterSetName='QoS')]	[switch]	$QoSIOPsReport,
		[Parameter(Mandatory, ParameterSetName='RCopy')]	[switch]	$RCopyIOPsReport,
		[Parameter(Mandatory, ParameterSetName='RCopyVol')]	[switch]	$RCopyVolumeIOPsReport,
		
		[Parameter()]									[Switch]	$AtTime,
		[Parameter()]
		[ValidateSet('hires','hourly','daily')]			[String]	$Frequency,
		[Parameter()]									[String]	$Summary,
		[Parameter()][ValidateSet('top','bottom')]		[String]	$Compareby,
		[Parameter()][ValidateRange(1,128)]				[int]		$NoOfRecords,
		[Parameter()]									[String]	$GETime,
		[Parameter()]									[String]	$LETime,
		[Parameter(ParameterSetName='Disk')]			[String]	$Id,
		[Parameter(ParameterSetName='Disk')]
		[ValidateSet('FC','NL','SSD','SCM','QLC')]		[String]	$DiskType,
		[Parameter(ParameterSetName='Disk')]
		[ValidateSet(7,10,15,100,150)]					[String]	$RPM,
		[Parameter(ParameterSetName='Disk')][ValidateSet('id','node','slot','cardPort','type','RPM')]									
														[String]	$DiskGroupby,
		[Parameter(ParameterSetName='Disk')]
		[ValidateSet('totalIOPs')]						[String]	$DiskComparebyField,
		[Parameter(ParameterSetName='Port')]
		[Parameter(ParameterSetName='QoS')]
		[Parameter(ParameterSetName='RCopy')]
		[ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]
														[String]	$NSP,
		[Parameter(ParameterSetName='Port')]	
		[ValidateSet('HOST','DISK','IPORT','FREE','RCFC','PEER','RCIP','ISCSI','CNA','FS')]			
														[String]	$PortType,
		[Parameter(ParameterSetName='Port')][ValidateSet('node','slot','cardPort','type','speed')]			
														[String]	$PortGroupby,
		[Parameter(ParameterSetName='Port')][ValidateSet('totalIOPs')]
														[String]	$PortComparebyField,
		[Parameter(ParameterSetName='QoS')]				[String[]]	$VolumeName,
		[Parameter(ParameterSetName='QoS')]				[String[]]	$VolumeSetName,
		[Parameter(ParameterSetName='QoS')]				[String]	$Domain,
		[Parameter(ParameterSetName='QoS')]				[Switch]	$All_Others,
		[Parameter(ParameterSetName='QoS')]	
		[ValidateSet('domain','type','name','ioLimit')]	[String]	$QosGroupby,
		[Parameter(ParameterSetName='QoS')]
		[ValidateSet('readIOPS','writeIOPS','totalIOPS','readKBytes', 'writeKBytes','totalKBytes','readServiceTimeMS','writeServiceTimeMS','totalServiceTimeMS','readIOSizeKB','writeIOSizeKB','totalIOSizeKB',
		'readWaitTimeMS','writeWaitTimeMS','totalWaitTimeMS','IOLimit','BWLimit','IOGuarantee','BWGuarantee','busyPct','queueLength','waitQueueLength','IORejection','latencyMS','latencyTargetMS')]	
														[String]	$QoSComparebyField,
		[Parameter(ParameterSetName='vLun')]			[int]		$VlunId,
		[Parameter(ParameterSetName='RCopyVol')]
		[Parameter(ParameterSetName='vLun')]			[String]	$Volume,
		[Parameter(ParameterSetName='vLun')]			[String]	$HostName,
		[Parameter(ParameterSetName='vLun')]			[String]	$VolumeSet,
		[Parameter(ParameterSetName='vLun')]			[String]	$HostSetName,
		[Parameter(ParameterSetName='vLun')][ValidateSet('domain','volumeName','hostname','lun','hostWWN','node','slot','vvsetName','hostsetName','cardPort')]
														[String]	$vLunGroupby,
		[Parameter(ParameterSetName='vLun')][ValidateSet('totalIOPs')]			
														[String]	$vLunComparebyField,
		[Parameter(ParameterSetName='RCopyVol')]	
		[Parameter(ParameterSetName='RCopy')]			[String]	$TargetName,
		[Parameter(ParameterSetName='RCopy')][ValidateSet('targetName','linkId','linkAddr','node','slotPort','cardPort')]
														[String]	$RCopyGroupby,
		[Parameter(ParameterSetName='RCopy')][ValidateSet('kbs','kbps','hbrttms','targetName','linkId','linkAddr','node','slotPort','cardPort')]	
														[String]	$RCopyComparebyField,
		[Parameter(ParameterSetName='CPG')]				[String]	$CpgName,
		[Parameter(ParameterSetName='CPG')][ValidateSet('name','domain')]		
														[String]	$CPGGroupby,
		[Parameter(ParameterSetName='CPG')][ValidateSet('totalIOPs')]
														[String]	$CPGComparebyField,
		[Parameter(ParameterSetName='RCopyVol')]		
		[ValidateSet('SYNC','PERIODIC','ASYNC')]		[String]	$Mode,
		[Parameter(ParameterSetName='RCopyVol')]		[String]	$RCopyGroup,
		[Parameter(ParameterSetName='RCopyVol')][ValidateSet('volumeName','volumeSetName','domain','targetName','mode','remoteCopyGroup','remoteCopyGroupRole','node','slot','cardPort','portType')]
														[String]	$RCopyVolGroupby,
		[Parameter(ParameterSetName='RCopyVol')][ValidateSet('readIOLocal','writeIOLocal','IOLocal','readKBytesLocal','writeKBytesLocal','KBytesLocal','readServiceTimeMSLocal','writeServiceTimeMSLocal','ServiceTimeMSLocal','readIOSizeKBLocal','writeIOSizeKBLocal','IOSizeKBLocal','busyPctLocal','queueLengthLocal','readIORemote','wirteIORemote','IORemote','readKBytesRemote','writeKBytesRemote','KBytesRemote','readServiceTimeMSRemote','writeServiceTimeMSRemote','ServiceTimeMSRemote','readIOSizeKBRemote','writeIOSizeKBRemote','IOSizeKBRemote','busyPctRemote','queueLengthRemote','RPO')]
														[String]	$RCopyVolComparebyField
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	if ( $AtTime)	{	$uri = '/systemreporter/attime/' 
						$Query="?query=""  """
						if($GETime)	{	$Query = $Query.Insert($Query.Length-3," sampleTime GE $GETime")			
										if ( $LETime)	{	$Query = $Query.Insert($Query.Length-3," AND")	}
									}
						if($LETime)	{	$Query = $Query.Insert($Query.Length-3," sampleTime LE $LETime")	}
					}
	else 			{	$uri = '/systemreporter/vstime/'
						if ( $LETime -or $GETime )	{	write-warning "The value LETime and GETime are ignored when running in VsTime."	}
					}
	$CompareByField = $null
	if ( -not $Frequency )	{	$Frequency = 'hires'	}
	Switch($PSCmdlet.ParameterSetName)
		{	'Disk'	
					{	$uri = $uri + 'physicaldiskstatistics/'+$Frequency	
						if ( -not $AtTime )			{	if ( $Id) 					{ 	$uri = $uri+";id:$Id"	}
														if ( $DiskType -eq 'FC') 	{	$uri = $uri+";type:1"	}	
														if ( $DiskType -eq 'NL') 	{	$uri = $uri+";type:2"	}	
														if ( $DiskType -eq 'SSD') 	{	$uri = $uri+";type:3"	}	
														if ( $DiskType -eq 'SCM') 	{	$uri = $uri+";type:4"	}	
														if ( $DiskType -eq 'QLC') 	{	$uri = $uri+";type:5"	}	
														if ( $RPM) 					{ 	$uri = $uri+";RPM:$RPM"	}
													}
						if ( $DiskGroupby) 			{  	$uri = $uri+";groupby:$DiskGroupby"		}
						if ( $Summary) 				{ 	$uri = $uri+";summary:$Summary"			}
						if ( $DiskComparebyField )	{	$CompareByField = $DiskComparebyField	}
					}
			'Port'	
					{	$uri = $uri + 'portstatistics/'+$Frequency
						if ( -not $AtTime )			{	if ( $NSP) 					{ 	$uri = $uri+";portPos:$NSP"	}
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
													}	
						if ( $PortGroupby) 			{  $uri = $uri+";groupby:$PortGroupby"		}
						if ( $Summary) 				{ 	$uri = $uri+";summary:$Summary"			}
						if ( $PortCompareByField)	{	$ComparebyField = $PortComparebyField	}		
					}
			'QoS'	
					{	$uri = $uri + 'qosstatistics/'+$Frequency
						if ( -not $AtTime )			{	if ( $Volume)		{	$uri = $uri+";vv:$Volume"			}
														if ( $VolumeSet)	{	$uri = $uri+";vvset:$VolumeSet"		}
														if ( $Domain ) 		{	$uri = $uri+";domain:$Domain"		}
														if ( $All_Others ) 	{	$uri = $uri+";sys:all_others"		}	
													}
						if ( $QoSGroupby ) 			{  	$uri = $uri+";groupby:$QoSGroupby"		}
						if ( $Summary )  			{ 	$uri = $uri+";summary:$Summary"			}
						if ( $QoSCompareByField)	{	$CompareByField = $QosComparebyField	}		
					}
			'vLun'	
					{	$uri = $uri + 'vlunstatistics/'+$Frequency
						if ( -not $AtTime )			{	if ( $VlunId ) 		{ 	$uri = $uri+";lun:$VlunId"				}
														if ( $VvName ) 		{ 	$uri = $uri+";volumeName:$VvName"		}
														if ( $HostName ) 	{ 	$uri = $uri+";hostname:$HostName"		}
														if ( $VvSetName ) 	{ 	$uri = $uri+";volumeName:set:$VvSetName"}
														if ( $HostSetName ) { 	$uri = $uri+";hostname:set:$HostSetName"}
														if ( $NSP )			{ 	$uri = $uri+";portPos:$NSP"				}									
													}
						if ( $vLunGroupby ) 		{  	$uri = $uri+";groupby:$vLunGroupby"		}
						if ( $Summary ) 			{ 	$uri = $uri+";summary:$Summary"			}
						if ( $vLunComparebyField )	{	$CompareByField = $vLunComparebyField	}		
						
					}	
			'Rcopy'	
					{	$uri = $uri + 'remotecopystatistics/'+$Frequency
						if ( -not $AtTime )			{	if ( $TargetName )		{ 	$uri = $uri+";targetName:$TargetName"	}
														if ( $NSP )				{ 	$uri = $uri+";portPos:$NSP" 			}
													}		
						if ( $RCopyGroupby ) 		{  	$uri = $uri+";groupby:$RCopyGroupby"		}
						if ( $Summary ) 			{ 	$uri = $uri+";summary:$Summary"				}
						if ( $RCopyCompareByField )	{	$CompareByField = $RCopyCompareByField 		}
					}
			'CPG'	
					{	$uri = $uri + 'cpgstatistics/'+$Frequency
						if ( -not $AtTime )			{	if ( $CpgName) 		{ 	$uri = $uri+";name:$CpgName"	}	
													}	
						if ( $CPGGroupby) 			{  	$uri = $uri+";groupby:$CPGGroupby"	}
						if ( $Summary) 				{ 	$uri = $uri+";summary:$Summary"	}
						if ( $CPGCompareByField )	{	$CompareByField = $CPGCompareByField } 
					}
			'RCopyVol'
					{	$uri = $uri + 'remotecopyvolumestatistics/'+$Frequency
						if ( -not $AtTime )			{	if ( $Volume )				{ 	$uri = $uri+";volumeName:"+$Volume 			}
														if ( $TargetName )			{ 	$uri = $uri+";targetName:"+$TargetName 		}
														If ( $Mode -eq "SYNC" ) 	{ 	$uri = $uri+";mode:1" 						}
														If ( $Mode -eq "PERIODIC" ) { 	$uri = $uri+";mode:3" 						}
														If ( $Mode -eq "ASYNC" ) 	{ 	$uri = $uri+";mode:4" 						}						
														if ( $RCopyGroup )			{	$uri = $uri+";remoteCopyGroup:"+$RCopyGroup	}
													}		
						if ( $Groupby ) 			{  	$uri = $uri+";groupby:$Groupby"				}
						if ( $Summary ) 			{ 	$uri = $uri+";summary:$Summary"				}
						if ( $RCopyVolCompareby )	{ 	$CompareByField = $RCopyVolComparebyField	}
					}
		}	
	if ( $CompareByField ) 	{	if ( $Compareby )	{	$uri = $uri+";compareby:$Compareby,"				}
								else 				{	$uri = $uri+";compareby:top,"						}	
								if ( $NoOfRecords )	{	$uri = $uri+$NoOfRecords+","+$ComparebyField		}
								else				{	$uri = $uri+"1,"+$ComparebyField					}
							}	
	if($LETime -or $GETime)		{	$uri = $uri+$Query	}
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
