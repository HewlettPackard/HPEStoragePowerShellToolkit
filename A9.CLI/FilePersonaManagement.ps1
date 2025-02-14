####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Start-A9FSNDMP
{
<#
.SYNOPSIS   
	Used to start both NDMP service and ISCSI service. 
.DESCRIPTION  
	The command is used to start both NDMP service and ISCSI service.
.EXAMPLE	
	PS:> Start-A9FSNDMP
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()		
Begin	
	{	Test-A9Connection -ClientType 'SshClient' 
	}
Process
	{	$cmd= "startfsndmp "	
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd
		Return $Result	
	}
}

Function Stop-A9FSNDMP
{
<#
.SYNOPSIS   
	Stop both NDMP service and ISCSI service.
.DESCRIPTION  
	The command is used to stop both NDMP service and ISCSI service.
.EXAMPLE	
	PS:> Stop-A9FSNDMP	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()		
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$cmd= "stopfsndmp "
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd	
		return $Result	
	}
}

Function Get-A9SRStatfsfpg
{
<#
.SYNOPSIS
	Get-SRStatfsfpg - System reporter performance reports for File Persona FPGs.
.DESCRIPTION	
	The Get-SRStatfsfpg command displays historical performance data reports for File Persona file provisioning groups.
.PARAMETER Attime
	Performance is shown at a particular time interval, specified by the etsecs option, with one row per object group described by the
	groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER Btsecs
	Select the begin time in seconds for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent
	sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report.  This is the default.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily
	Select daily samples for the report.
.PARAMETER Summary
	Summarize performance across requested objects and time range. One of these 4 summary keywords must be included:
		min   Display the minimum for each metric
		avg   Display the average for each metric
		max   Display the maximum for each metric
		<N>%  Display percentile for each metric. <N> may be any number from 0 to 100. Multiple percentiles may be specified.
	Other keywords which modify the summary display or computation:
		detail		Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
		per_time	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per time. By default, one summary is computed across all records.
		per_group	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per object grouping. By default, one summary is computed across all records.
		only_compareby	When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries using only that reduced set of object groupings. By default,
				summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items. Each <groupby> must be different and one of the following:
	FPG_NAME  File Provisioning Group name
	FPG_ID    File Provisioning Group ID
	NODE      The controller node
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects can be displayed, up to 32 objects for vstime reports or 128 objects
	for attime reports.  The field used for comparison can be any of the groupby fields or one of the following: Totalblocks, Freeblocks, Numreads, Numbytesread, Numwrites,	
	NumBytesWritten, Creates, Removes, Errors, ReadLatency, WriteLatency
.PARAMETER Node
	Limit the data to that corresponding to one of the specified nodes.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc		Sort in increasing order (default).
		dec		Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted  by values in later columns.
.PARAMETER FpgName
	File provisioning groups matching either the specified name or glob-style pattern are included. This specifier can be repeated to
	display information for multiple FPGs. If not specified, all FPGs are included.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Attime,
		[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs,
		[Parameter()]	[switch]	$Hires,
		[Parameter()]	[switch]	$Hourly,
		[Parameter()]	[switch]	$Daily,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[String]	$Sortcol,
		[Parameter()]	[String]	$FpgName,
		[Parameter()]	[String]	$ShowRaw
		
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " srstatfsfpg "
	if($Attime)		{	$Cmd += " -attime " 			}
	if($Btsecs)		{	$Cmd += " -btsecs $Btsecs " 	}
	if($Etsecs)		{	$Cmd += " -etsecs $Etsecs " 	}
	if($Hires) 		{	$Cmd += " -hires " 				}
	if($Hourly)		{	$Cmd += " -hourly " 			}
	if($Daily)		{	$Cmd += " -daily " 				}
	if($Summary)	{	$Cmd += " -summary $Summary " 	}
	if($Groupby)	{	$Cmd += " -groupby $Groupby "	}
	if($Compareby) 	{	$Cmd += " -compareby $Compareby "}
	if($Node)		{	$Cmd += " -node $Node " 		}
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol "	}
	if($FpgName)	{	$Cmd += " $FpgName " 			}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SystemReporterStatfscpu
{
<#
.SYNOPSIS
	Get-SRStatfscpu - System reporter performance reports for File Persona CPU usage.
.DESCRIPTION
	The Get-SRStatfscpu command displays historical performance data reports for File Persona CPU utilization.
.PARAMETER Attime
	Performance is shown at a particular time interval, specified by the etsecs option, with one row per object group described by the
	groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER Btsecs
	Select the begin time in seconds for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report.
	The value can be specified as either
		- The absolute epoch time (for example 1351263600).
		- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
		- A negative number indicating the number of seconds before the
	current time. Instead of a number representing seconds, <secs> can be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily
	Select daily samples for the report.
.PARAMETER Summary
	Summarize performance across requested objects and time range. One of these 4 summary keywords must be included:
		min   Display the minimum for each metric
		avg   Display the average for each metric
		max   Display the maximum for each metric
		<N>%  Display percentile for each metric. <N> may be any number from 0 to 100. Multiple percentiles may be specified.
	Other keywords which modify the summary display or computation:
	detail
		Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
	per_time
		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per time. By default, one summary is computed across all records.
	per_group
		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per
		object grouping. By default, one summary is computed across all records.
	only_compareby
		When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries using only that reduced set of object groupings. By default,
		summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail"  output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items. Each <groupby> must be different and one of the following:
	NODE   The controller node
	CPU    The CPU within the controller node
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects
	can be displayed, up to 32 objects for vstime reports or 128 objects for attime reports.  The field used for comparison can be any of the
	groupby fields or one of the following: usage_pct, iowait_pct, idle_pct
.PARAMETER Node
	Limit the data to that corresponding to one of the specified nodes.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc		Sort in increasing order (default).
		dec		Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.PARAMETER CpuId
	Only the specified CPU ID numbers are included. This specifier can be repeated to display information for multiple CPUs. If not specified, all CPUs are included.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Attime,
		[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs,
		[Parameter()]	[switch]	$Hires,
		[Parameter()]	[switch]	$Hourly,
		[Parameter()]	[switch]	$Daily,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[String]	$Sortcol,
		[Parameter()]	[String]	$CpuId,
		[Parameter()]	[Switch]	$ShowRaw		
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " srstatfscpu "
	if($Attime)		{	$Cmd += " -attime " }
	if($Btsecs)		{	$Cmd += " -btsecs $Btsecs "}
	if($Etsecs)		{	$Cmd += " -etsecs $Etsecs " }
	if($Hires)		{	$Cmd += " -hires " }
	if($Hourly)		{	$Cmd += " -hourly " }
	if($Daily)		{	$Cmd += " -daily " }
	if($Summary)	{	$Cmd += " -summary $Summary " }
	if($Groupby)	{	$Cmd += " -groupby $Groupby " }
	if($Compareby)	{	$Cmd += " -compareby $Compareby "}
	if($Node)		{	$Cmd += " -node $Node " }
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol " }
	if($CpuId)		{	$Cmd += " $CpuId " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SRStatfsmem
{
<#
.SYNOPSIS
	srstatfsmem - System reporter performance reports for File Persona memory usage
.DESCRIPTION
	The srstatfsmem command displays historical performance data reports for File Persona memory utilization.
.PARAMETER Attime
	Performance is shown at a particular time interval, specified by the etsecs option, with one row per object group described by the
	groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER Btsecs
	Select the begin time in seconds for the report. The value can be specified as either
		- The absolute epoch time (for example 1351263600).
		- The absolute time as a text string in one of the following formats:
			- Full time string including time zone: "2012-10-26 11:00:00 PDT"
			- Full time string excluding time zone: "2012-10-26 11:00:00"
			- Date string: "2012-10-26" or 2012-10-26
			- Time string: "11:00:00" or 11:00:00
		- A negative number indicating the number of seconds before the
	current time. Instead of a number representing seconds, <secs> can be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires. If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report.
	The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily
	Select daily samples for the report.
.PARAMETER Summary
	Summarize performance across requested objects and time range. One of these 4 summary keywords must be included:
		min   Display the minimum for each metric
		avg   Display the average for each metric
		max   Display the maximum for each metric
		<N>%  Display percentile for each metric. <N> may be any number from 0 to 100. Multiple percentiles may be specified.
	Other keywords which modify the summary display or computation:
		detail		Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
		per_time	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per time. By default, one summary is computed across all records.
		per_group	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per object grouping. By default, one summary is computed across all records.
		only_compareby	When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries  using only that reduced set of object groupings. By default,
					summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items. Each <groupby> must be different and one of the following:
	NODE   The controller node
.PARAMETER Compareby
	The compareby option limits output records to only certain objects,	compared by a specified field.  Either the top or bottom X objects can be displayed, up to 32 objects for vstime reports or 128 objects
	for attime reports.  The field used for comparison can be any of the groupby fields or one of the following: usage_pct, swap_pct, free_pct
.PARAMETER Node
	Limit the data to that corresponding to one of the specified nodes.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc		Sort in increasing order (default).
		dec		Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Attime,
		[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs,
		[Parameter()]	[switch]	$Hires,
		[Parameter()]	[switch]	$Hourly,
		[Parameter()]	[switch]	$Daily,
		[Parameter()]	[String]	$Summary,
		[Parameter()] 	[String]	$Groupby,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[String]	$Sortcol
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " srstatfsmem "
	if($Attime)		{	$Cmd += " -attime " }
	if($Btsecs)		{	$Cmd += " -btsecs $Btsecs " }
	if($Etsecs)		{	$Cmd += " -etsecs $Etsecs " }
	if($Hires)		{	$Cmd += " -hires " }
	if($Hourly)		{	$Cmd += " -hourly " }
	if($Daily)		{	$Cmd += " -daily " }
	if($Summary)	{	$Cmd += " -summary $Summary " }
	if($Groupby)	{	$Cmd += " -groupby $Groupby " }
	if($Compareby)	{	$Cmd += " -compareby $Compareby " }
	if($Node)		{	$Cmd += " -node $Node " }
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SystemReporterStatfsblock
{
<#
.SYNOPSIS
	Get-SRStatfsblock - System reporter performance reports for File Persona block devices.
.DESCRIPTION
	The Get-SRStatfsblock command displays historical performance data reports for File Persona block devices.
.PARAMETER Attime
	Performance is shown at a particular time interval, specified by the etsecs option, with one row per object group described by the
	groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER Btsecs
	Select the begin time in seconds for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily
	Select daily samples for the report.
.PARAMETER Summary
	Summarize performance across requested objects and time range. One of these 4 summary keywords must be included:
		min   Display the minimum for each metric
		avg   Display the average for each metric
		max   Display the maximum for each metric
		<N>%  Display percentile for each metric. <N> may be any number from 0 to 100. Multiple percentiles may be specified.
	Other keywords which modify the summary display or computation:
	detail
		Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
	per_time
		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per
		time. By default, one summary is computed across all records.
	per_group
		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per
		object grouping. By default, one summary is computed across all records.
	only_compareby
		When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries using only that reduced set of object groupings. By default,
		summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	NODE            The controller node
	BLOCKDEV_NAME   The block device name
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects can be displayed, up to 32 objects for vstime reports 
	or 128 objects for attime reports.  The field used for comparison can be any of the groupby fields or one of the following: reads, reads_merged, read_sectors, read_time_ms, writes, 
	writes_merged,  write_sectors, write_time_ms, ios_current, io_time_ms, io_time_weighted_ms
.PARAMETER Node
	Limit the data to that corresponding to one of the specified nodes.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc		Sort in increasing order (default).
		dec		Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.PARAMETER BlockdevName  
	Block Devices matching either the specified name or glob-style pattern are included. This specifier can be repeated to display information
	for multiple devices. If not specified, all block devices are included.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Attime,
		[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs,
		[Parameter()]	[switch]	$Hires,
		[Parameter()]	[switch]	$Hourly,
		[Parameter()]	[switch]	$Daily,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[String]	$Sortcol,
		[Parameter()]	[String]	$BlockdevName,
		[Parameter()]	[Switch]	$ShowRaw
		
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = " srstatfsblock "
	if($Attime)		{	$Cmd += " -attime " }
	if($Btsecs) 	{	$Cmd += " -btsecs $Btsecs " }
	if($Etsecs)		{	$Cmd += " -etsecs $Etsecs " }
	if($Hires)		{	$Cmd += " -hires " }
	if($Hourly)		{	$Cmd += " -hourly " }
	if($Daily)		{	$Cmd += " -daily " }
	if($Summary)	{	$Cmd += " -summary $Summary "}
	if($Groupby)	{	$Cmd += " -groupby $Groupby " }
	if($Compareby)	{	$Cmd += " -compareby $Compareby " }
	if($Node)		{	$Cmd += " -node $Node "}
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol " }
	if($BlockdevName){	$Cmd += " $Blockdev_name " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SystemReporterStatfsav
{
<#
.SYNOPSIS
	Get-SRStatfsav - System reporter performance reports for File Persona anti-virus.
.DESCRIPTION
	The Get-SRStatfsav command displays historical performance data reports for File Persona anti-virus activity.
.PARAMETER Attime
	Performance is shown at a particular time interval, specified by the etsecs option, with one row per object group described by the
	groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER Btsecs
	Select the begin time in seconds for the report. The value can be specified as either
		- The absolute epoch time (for example 1351263600).
		- The absolute time as a text string in one of the following formats:
			- Full time string including time zone: "2012-10-26 11:00:00 PDT"
			- Full time string excluding time zone: "2012-10-26 11:00:00"
			- Date string: "2012-10-26" or 2012-10-26
			- Time string: "11:00:00" or 11:00:00
		- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
			be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.

.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report. The value can be specified as either
		- The absolute epoch time (for example 1351263600).
		- The absolute time as a text string in one of the following formats:
			- Full time string including time zone: "2012-10-26 11:00:00 PDT"
			- Full time string excluding time zone: "2012-10-26 11:00:00"
			- Date string: "2012-10-26" or 2012-10-26
			- Time string: "11:00:00" or 11:00:00
		- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
			be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent
	sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily
	Select daily samples for the report.
.PARAMETER Summary
	Summarize performance across requested objects and time range. One of these 4 summary keywords must be included:
		min   Display the minimum for each metric
		avg   Display the average for each metric
		max   Display the maximum for each metric
		<N>%  Display percentile for each metric. <N> may be any number from 0 to 100. Multiple percentiles may be specified.
	Other keywords which modify the summary display or computation:
		detail	 	Display individual performance records in addition to one  or more summaries. By default, -summary output excludes individual records and only displays the summary.
		per_time	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per  time. By default, one summary is computed across all records.
		per_group	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per object grouping. By default, one summary is computed across all records.
	only_compareby	When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries using only that reduced set of object groupings. By default,
		summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and	one of the following:
	NODE      The controller node
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects
	can be displayed, up to 32 objects for vstime reports or 128 objects for attime reports.  The field used for comparison can be any of the
	groupby fields or one of the following: scanengine, maxscanengine, totalscanned, totalinfected, totalquarantined
.PARAMETER Node
	Limit the data to that corresponding to one of the specified nodes.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
	inc		Sort in increasing order (default).
	dec		Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Attime,
		[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs,
		[Parameter()]	[switch]	$Hires,
		[Parameter()]	[switch]	$Hourly,
		[Parameter()]	[switch]	$Daily,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[String]	$Sortcol,	
		[Parameter()]	[String]	$FPGname,
		[Parameter()]	[switch]	$ShowRaw
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = " srstatfsav "
	if($Attime)		{	$Cmd += " -attime " 		}
	if($Btsecs)		{	$Cmd += " -btsecs $Btsecs " }
	if($Etsecs) 	{	$Cmd += " -etsecs $Etsecs " }
	if($Hires)		{	$Cmd += " -hires " 			}
	if($Hourly)		{	$Cmd += " -hourly " 		}
	if($Daily)		{	$Cmd += " -daily " 			}
	if($Summary)	{	$Cmd += " -summary $Summary "}
	if($Groupby)	{	$Cmd += " -groupby $Groupby "}
	if($Compareby)	{	$Cmd += " -compareby $Compareby "}
	if($Node)		{	$Cmd += " -node $Node "		}
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol " }
	if($FPGname)	{	$Cmd += " $FPGname " 		} 
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SRStatfsnet
{
<#
.SYNOPSIS
	Get-SRStatfsnet - System reporter performance reports for File Persona networking.
.DESCRIPTION
	The Get-SRStatfsnet command displays historical performance data reports for File Persona networking devices.
.PARAMETER Attime
	Performance is shown at a particular time interval, specified by the etsecs option, with one row per object group described by the
	groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER Btsecs
	Select the begin time in seconds for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily
	Select daily samples for the report.
.PARAMETER Summary
	Summarize performance across requested objects and time range. One of these 4 summary keywords must be included:
		min   Display the minimum for each metric
		avg   Display the average for each metric
		max   Display the maximum for each metric
		<N>%  Display percentile for each metric. <N> may be any number from 0 to 100. Multiple percentiles may be specified.
	Other keywords which modify the summary display or computation:
		detail			Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
		per_time		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per time. By default, one summary is computed across all records.
		per_group		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per object grouping. By default, one summary is computed across all records.
		only_compareby	When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries using only that reduced set of object groupings. By default,
						summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items. Each <groupby> must be different and one of the following:
	NODE      The controller node
	DEV_NAME  Ethernet interface name
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects can be displayed, up to 32 objects for vstime reports or 128 objects
	for attime reports.  The field used for comparison can be any of the groupby fields or one of the following: rx_bytes, rx_packets, tx_bytes, tx_packets
.PARAMETER Node
	Limit the data to that corresponding to one of the specified nodes.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc		Sort in increasing order (default).
		dec		Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.PARAMETER EthdevName
	Ethernet interface devices matching either the specified name or glob-style pattern are included. This specifier can be repeated to
	display information for multiple devices. If not specified, all devices are included.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[switch]	$Attime,
	[Parameter()]	[String]	$Btsecs,
	[Parameter()]	[String]	$Etsecs,
	[Parameter()]	[switch]	$Hires,
	[Parameter()]	[switch]	$Hourly,
	[Parameter()]	[switch]	$Daily,
	[Parameter()]	[String]	$Summary,
	[Parameter()]	[String]	$Groupby,
	[Parameter()]	[String]	$Compareby,
	[Parameter()]	[String]	$Node,
	[Parameter()]	[String]	$Sortcol,
	[Parameter()]	[String]	$EthdevName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " srstatfsnet "
	if($Attime)		{	$Cmd += " -attime " }
	if($Btsecs)		{	$Cmd += " -btsecs $Btsecs " }
	if($Etsecs)		{	$Cmd += " -etsecs $Etsecs " }
	if($Hires) 		{	$Cmd += " -hires " 	}
	if($Hourly) 	{	$Cmd += " -hourly " }
	if($Daily)		{	$Cmd += " -daily " }
	if($Summary)	{	$Cmd += " -summary $Summary " }
	if($Groupby)	{	$Cmd += " -groupby $Groupby " }
	if($Compareby)	{	$Cmd += " -compareby $Compareby " }
	if($Node)		{	$Cmd += " -node $Node " }
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol " }
	if($EthdevName)	{	$Cmd += " $EthdevName " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SRStatfsnfs
{
<#
.SYNOPSIS
	Get-SRStatfsnfs - System reporter performance reports for File Persona NFS shares.
.DESCRIPTION
	The Get-SRStatfsnfs command displays historical performance data reports for File Persona NFS shares.
.PARAMETER Attime
	Performance is shown at a particular time interval, specified by the etsecs option, with one row per object group described by the
	groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER Btsecs
	Select the begin time in seconds for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time
	the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily
	Select daily samples for the report.
.PARAMETER Summary
	Summarize performance across requested objects and time range. One of these 4 summary keywords must be included:
		min   Display the minimum for each metric
		avg   Display the average for each metric
		max   Display the maximum for each metric
		<N>%  Display percentile for each metric. <N> may be any number from 0 to 100. Multiple percentiles may be specified.
	Other keywords which modify the summary display or computation:
		detail		Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
		per_time	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per time. By default, one summary is computed across all records.
		per_group	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per object grouping. By default, one summary is computed across all records.
		only_compareby	When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries
					using only that reduced set of object groupings. By default, summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items. Each <groupby> must be different and one of the following:
	NODE   The controller node
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects
	can be displayed, up to 32 objects for vstime reports or 128 objects for attime reports.  The field used for comparison can be any of the  groupby fields or one of the following:
	Client_RPC_calls, Client_RPC_retrans, Server_RPC_calls, Server_RPC_badcalls, V3_Null, V3_GetAttr, V3_SetAttr, V3_lookup, V3_access, V3_ReadLink, V3_Read,
	V3_Write, V3_Create, V3_MkDir, V3_Symlink, V3_Mknod, V3_Remove, V3_RmDir, V3_Rename, V3_Link, V3_ReadDir, V3_ReadDirPlus, V3_FsStat, V3_FsInfo,
	V3_PathConf, V3_Commit, V4_op0_unused, V4_op1_unused, V4_op2_future, V4_access, V4_close, V4_commit, V4_create, V4_delegpurge, V4_delegreturn,
	V4_getattr, V4_getfh, V4_link, V4_lock, V4_lockt, V4_locku, V4_lookup, V4_lookup_root, V4_nverify, V4_open, V4_openattr, V4_open_conf, V4_open_dgrd,
	V4_putfh, V4_putpubfh, V4_putrootfh, V4_Read, V4_reddir, V4_readlink, V4_remove, V4_rename, V4_renew, V4_restorefh, V4_savefh, V4_secinfo, V4_setattr, V4_setcltid,
	V4_setcltidconf, V4_verify, V4_Write, V4_rellockowner, V4_bc_ctl, V4_bind_conn, V4_exchange_id, V4_create_ses, V4_destroy_ses, V4_free_stateid, V4_getdirdeleg,	
	V4_getdevinfo, V4_getdevlist, V4_layoutcommit, V4_layoutget, V4_layoutreturn, V4_secinfononam, V4_sequence, V4_set_ssv, V4_test_stateid, V4_want_deleg, V4_destroy_clid, V4_reclaim_comp
.PARAMETER Node
	Limit the data to that corresponding to one of the specified nodes.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc		Sort in increasing order (default).
		dec		Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Attime,
		[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs,
		[Parameter()]	[switch]	$Hires,
		[Parameter()]	[switch]	$Hourly,
		[Parameter()]	[switch]	$Daily,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[String]	$Sortcol
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = " srstatfsnfs "
	if($Attime)			{	$Cmd += " -attime "}
	if($Btsecs)			{	$Cmd += " -btsecs $Btsecs "}
	if($Etsecs)			{	$Cmd += " -etsecs $Etsecs "}
	if($Hires)			{	$Cmd += " -hires " }
	if($Hourly)			{	$Cmd += " -hourly " }
	if($Daily)			{	$Cmd += " -daily " }
	if($Summary)		{	$Cmd += " -summary $Summary " }
	if($Groupby) 		{	$Cmd += " -groupby $Groupby " }
	if($Compareby)		{	$Cmd += " -compareby $Compareby " }
	if($Node)			{	$Cmd += " -node $Node " }
	if($Sortcol)		{	$Cmd += " -sortcol $Sortcol " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SystemReporterStatfssmb
{
<#
.SYNOPSIS
	System reporter performance reports for File Persona SMB shares.
.DESCRIPTION
	The command displays historical performance data reports for File Persona SMB shares.
.PARAMETER Attime
	Performance is shown at a particular time interval, specified by the etsecs option, with one row per object group described by the
	groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER Btsecs
	Select the begin time in seconds for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily
	Select daily samples for the report.
.PARAMETER Summary
	Summarize performance across requested objects and time range. One of these 4 summary keywords must be included:
		min   Display the minimum for each metric
		avg   Display the average for each metric
		max   Display the maximum for each metric
		<N>%  Display percentile for each metric. <N> may be any number	from 0 to 100. Multiple percentiles may be specified.
	Other keywords which modify the summary display or computation:
		detail			Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
		per_time		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per time. By default, one summary is computed across all records.
		per_group		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per object grouping. By default, one summary is computed across all records.
		only_compareby	When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries using only that reduced set of object groupings. By default,
						summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items. Each <groupby> must be different and one of the following:
	NODE   Statistics per node
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects can be displayed, up to 32 objects for vstime reports or 128 objects
	for attime reports.  The field used for comparison can be any of the groupby fields or one of the following: connections, maxConnections, sessions, maxSessions, treeConnects, maxTreeConnects, openFiles, 
	maxOpenFiles, ReadSumRecorded, ReadSampleRecorded, WriteSumRecorded, WriteSampleRecorded
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Attime,
		[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs,
		[Parameter()]	[switch]	$Hires,
		[Parameter()]	[switch]	$Hourly,
		[Parameter()]	[switch]	$Daily,
		[Parameter()]	[String]	$Summary,
		[Parameter()]	[ValidateSet('DOM_NAME','LDID','LD_NAME','CPG_NAME','NODE')]
						[String]	$Groupby,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[switch]	$ShowRaw
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$Cmd = " srstatfssmb "
		if($Attime)		{	$Cmd += " -attime " }
		if($Btsecs)		{	$Cmd += " -btsecs $Btsecs " }
		if($Etsecs)		{	$Cmd += " -etsecs $Etsecs " }
		if($Hires)		{	$Cmd += " -hires " }
		if($Hourly)		{	$Cmd += " -hourly " }
		if($Daily)		{	$Cmd += " -daily " }
		if($Summary)	{	$Cmd += " -summary $Summary " }
		if($Groupby)	{	$Cmd += " -groupby $Groupby " }
		if($Compareby)	{	$Cmd += " -compareby $Compareby " }
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

