####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

# General System Rerporter Commands
Function Get-A9SystemReporter
{
<#
.SYNOPSIS
    Displays the amount of space consumed by the various System Reporter databases on the System Reporter volume.
.DESCRIPTION
    Displays the amount of space consumed by the various System Reporter databases on the System Reporter volume.
.PARAMETER ldrg
	Displays which LD region statistic samples are available.  This is used with the -btsecs and -etsecs options.
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
	- A negative number indicating the number of seconds before the	current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
.EXAMPLE
	PS:> Get-A9SystemReporter

	Node Total(MiB) Used(MiB) Used%
	-------------------------------
	2     110302     23312    23

	Filetype info:
					-(MiB)- -Target- --------Retention---------
	FileType   Count   Usage   Period Target Max Estimate Actual EarliestDate        EndEstimate
	----------------------------------------------------------------------------------------------------
	ai             4    1528      30s    10d 31d    1.34y   110d 2024-10-24 17:03:30 356 days from now
	aomoves        0       0      ---    --- ---      ---    --- ---                 ---
	baddb          0       0      ---    --- ---      ---    --- ---                 ---
	daily          1      69       1d     5y ---     10y+   110d 2024-10-25 00:00:00 10+ years from now
	hires         20   19979       5m    10d ---      89d   110d 2024-10-24 17:05:00 12 days from now
	hourly         2    1709       1h    90d ---    2.20y   110d 2024-10-24 18:00:00 1.99 years from now
.EXAMPLE
    Get-A9SystemReporter -Btsecs 10
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$ldrg,
		[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs
	)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$srinfocmd = "showsr "
		if($ldrg)	{	$srinfocmd += "-ldrg "	}
		if($Btsecs)	{	$srinfocmd += "-btsecs $Btsecs "	}
		if($Etsecs)	{	$srinfocmd += "-etsecs $Etsecs "	}
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
		return  $Result	
	}
}

Function Start-A9SystemReporter
{
<#
.SYNOPSIS
    To start System reporter.
.DESCRIPTION
    To start System reporter.
.EXAMPLE
    PS:> Start-A9SystemReporter

	Starts System Reporter
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$srinfocmd = "startsr -f "
		write-verbose "System reporter command => $srinfocmd"
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
		if(-not $Result)	
			{	write-host "Success: Started System Reporter" -ForegroundColor green
			}
		elseif($Result -match "Cannot startsr, already started")	
			{	write-warning "Command Execute Successfully :- Cannot startsr, already started"	
			}
		else{	return $Result	
			}		
	}
}

Function Stop-A9SSystemReporter
{
<#
.SYNOPSIS
    To stop System reporter.
.DESCRIPTION
    To stop System reporter.
.EXAMPLE
    PS:> Stop-A9SSystemReporter

	Stop System Reporter
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$srinfocmd = "stopsr -f "
		write-verbose "System reporter command => $srinfocmd"
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
		if(-not $Result)	
			{	write-host "Success: Stopped System Reporter" -ForegroundColor green 	
			}
		return $Result
	}
}
# Inventory Logical Constructs, Logical Disks, CPG, Host Ports
Function Get-A9SystemReportCpgSpace
{
<#
.SYNOPSIS
    Command displays historical space data reports for common provisioning groups (CPGs).
.DESCRIPTION
    Command displays historical space data reports for common provisioning groups (CPGs).	
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.  
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and  one of the following:
	DOM_NAME  Domain name
	CPGID     Common Provisioning Group ID
	CPG_NAME  Common Provisioning Group name
	DISK_TYPE  The disktype of the PDs used by the CPG
	RAID_TYPE The RAID type of the CPG
.PARAMETER disk_type 
	Limit the data to disks of the types specified. Allowed types are
	FC  - Fast Class
	NL  - Nearline
	SSD - Solid State Drive
.PARAMETER raid_type
	Limit the data to RAID of the specified types. Allowed types are 0, 1, 5 and 6
.PARAMETER CpgName
	CPGs matching either the specified CPG_name or glob-style pattern are included. This specifier can be repeated to display information for multiple CPGs. If not specified, all CPGs are included.
.EXAMPLE
    PS:> Get-A9SystemReportCpgSpace | ft *

	Date       Time     TimeZone Secs       PrivateBase(MB) PrivateSnap(MB) Shared(MB) Free(MB) Total(MB) UsableFree(MB)
	----       ----     -------- ----       --------------- --------------- ---------- -------- --------- --------------
	2025-02-11 04:55:00 MST      1739274900 12667725        1137150         8287650    22092525 47082000  4.14
	2025-02-11 05:00:00 MST      1739275200 12737550        1137150         8217825    22092525 47082000  4.11
	2025-02-11 05:05:00 MST      1739275500 12798450        1137150         8156925    22092525 47082000  4.1
	2025-02-11 05:10:00 MST      1739275800 12843075        1137150         8112300    22092525 47
.EXAMPLE
    PS:> Get-A9SystemReportCpgSpace -Option hourly -btsecs -24h fc*

	example displays aggregate hourly CPG space information for CPGs with names that match the pattern "fc*" beginning 24 hours ago:
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,
		[Parameter()]	[switch]    $Daily ,
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[String]	$groupby,
		[Parameter()][ValidateSet("FC","NL","SSD")]	
						[String]	$DiskType,
		[Parameter()][ValidateSet("0","1","5","6")]	
						[String]	$RaidType,
		[Parameter()]	[String]	$CpgName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = "srcpgspace"
	$tempFile = [IO.Path]::GetTempFileName()
	if($btsecs)		{	$srinfocmd += " -btsecs $btsecs"	}
	if($etsecs)		{	$srinfocmd += " -etsecs $etsecs"	}
	if($groupby)
		{	$commarr = "DOM_NAME","CPGID","CPGID","CPGID","RAID_TYPE"
			$lista = $groupby.split(",")
			foreach($suba in $lista)
				{	if( -not ($commarr -eq $suba.toUpper()) )
						{	Remove-Item  $tempFile
							return "FAILURE: Invalid groupby option it should be in ( $commarr )"
						}
				}
			$srinfocmd += " -groupby $groupby"
		}	
	if($Hourly)		{	$srinfocmd += " -hourly"	}
	if($Daily)		{	$srinfocmd += " -daily"		}
	if($Hires)		{	$srinfocmd += " -hires"		}
	if($RaidType)	{	$srinfocmd += " -raid_type $RaidType"	}
	if($DiskType)	{	$srinfocmd += " -disk_type $DiskType"	}				
	if($CpgName)	{	$srinfocmd += " $CpgName"	}		
	if($attime)
		{	$srinfocmd += " -attime "
			write-verbose "System reporter command => $srinfocmd"
			if($groupby)
				{	$optionname = $groupby.toUpper() }
			else{	$optionname = "CPG_NAME"	}
			Add-Content -Path $tempFile -Value "CPG_NAME,PrivateBase(MB),PrivateSnap(MB),Shared(MB),Free(MB),Total(MB),UsableFree(MB),Dedup_GC(KB/s),Compact,Dedup,Compress,DataReduce,OverProv"
			$rangestart = "3"			
		}	
	else{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,PrivateBase(MB),PrivateSnap(MB),Shared(MB),Free(MB),Total(MB),UsableFree(MB),Dedup_GC(KB/s),Compact,Dedup,Compress,DataReduce,OverProv"
		}
	write-verbose "System reporter command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
{
	if($Result -contains "FAILURE")
		{	Remove-Item  $tempFile
			return "FAILURE : $Result"
		}
	$range1  = $Result.count	
	if($range1 -le "3")
		{	Remove-Item  $tempFile
			return "No data available"
		}
	foreach ($s in  $Result[$rangestart..$range1] )
		{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
			Add-Content -Path $tempFile -Value  $s
		}
	$Result = Import-Csv $tempFile
	Remove-Item  $tempFile
	return $Result
}
}

# Inventory Hardware Components Physical Disks, Nodes, 

# Events and Alerts for System Reporter
Function Get-A9SystemReportAlertCrit
{
<#
.SYNOPSIS
    Shows the criteria that System Reporter evaluates to determine if a performance alert should be generated.
.DESCRIPTION
    Shows the criteria that System Reporter evaluates to determine if a performance alert should be generated.       
.PARAMETER Daily
	This criterion will be evaluated on a daily basis at midnight.
.PARAMETER Hourly
	This criterion will be evaluated on an hourly basis.
.PARAMETER Hires
	This criterion will be evaluated on a high resolution (5 minute) basis. This is the default.
.PARAMETER Major
	This alert should require urgent action.
.PARAMETER Minor
	This alert should require not immediate action.
.PARAMETER Info
	This alert is informational only. This is the default.
.PARAMETER Enabled
	Displays only criteria that are enabled.
.PARAMETER Disabled
	Displays only criteria that are disabled.
.PARAMETER Critical
	Displays only criteria that have critical severity.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SystemReportAlertCrit 

	shows the criteria that System Reporter evaluates to determine if a performance alert should be generated.
.EXAMPLE
    PS:> Get-A9SystemReportAlertCrit -Daily

	Example displays all the criteria evaluated on an hourly basis:
.EXAMPLE
	PS:> Get-A9SystemReportAlertCrit -Hires
.NOTES
	Authority:Any role in the system
	Usage:
	- Both options and conditions are displayed in the Conditions column. The only exception is that frequency options (-daily, -hourly, or -hires) are only displayed under the Freq column.
	- By default, all criteria are shown (all frequencies, enabled, disabled and all severities).
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter(ParameterSetName='Hourly',mandatory)]	[switch]	$Hourly ,
		[Parameter(ParameterSetName='Daily',mandatory)]		[switch]    $Daily ,
		[Parameter(ParameterSetName='Hires',mandatory)]		[switch]    $Hires ,
		[Parameter()]	[switch]    $Major ,
		[Parameter()]	[switch]    $Minor ,
		[Parameter()]	[switch]    $Info ,
		[Parameter()]	[switch]    $Enabled ,
		[Parameter()]	[switch]    $Disabled ,
		[Parameter()]	[switch]    $Critical,
		[Parameter()]	[switch]    $ShowRaw
		
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = 'showsralertcrit '
	if($Hourly)		{	$srinfocmd += ' -hourly '	}
	if($Daily)		{	$srinfocmd += ' -daily '	}
	if($Hires)		{	$srinfocmd += ' -hires '	}
	if($Major)		{	$srinfocmd += ' -major '	}
	if($Minor)		{	$srinfocmd += ' -minor '	}
	if($Info)		{	$srinfocmd += ' -info '		}
	if($Enabled)	{	$srinfocmd += ' -enabled '	}
	if($Disabled)	{	$srinfocmd += ' -disabled '	}
	if($Critical)	{	$srinfocmd += ' -critical '	}
	write-verbose "Get alert criteria command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd	
}
End
{	if ($ShowRaw) { Return $Result }
	if(( $Result -match "Invalid") -or ($Result -match "Error"))	
		{	write-warning "FAILURE :" 
		}
	elseif($Result -match "No criteria listed")	
		{	write-warning "No srcriteria listed"
		}
	else{
			$tempFile = [IO.Path]::GetTempFileName()
			foreach ( $s in  $Result[0..($Result.count-3)] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempFile -Value $s
				}
			$Result = Import-Csv $tempFile
			Remove-Item  $tempFile
		}
	return $Result
}
}

# Performance Histograms


Function Get-A9SystemReportHistogramLogicalDisk
{
<#
.SYNOPSIS
    Displays historical histogram performance data reports for logical disks.
.DESCRIPTION
    Displays historical histogram performance data reports for logical disks.
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time
	the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report.
	The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER rw
    Specifies that the display includes separate read and write data. If notspecified, the total is displayed.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	DOM_NAME  Domain name
	LDID      Logical disk ID
	LD_NAME   Logical disk name
	CPG_NAME  Common Provisioning Group name
	NODE      The node that owns the LD
.PARAMETER cpgName
	Limit the data to LDs in CPGs with names that match one or more of the specified names or glob-style patterns.
.PARAMETER node
	Limit the data to that corresponding to one of the specified nodes.
.PARAMETER LDName
	LDs matching either the specified LD_name or glob-style pattern are included. This specifier can be repeated to display information for multiple LDs. If not specified, all LDs are included.
.PARAMETER Metric both|time|size
	Selects which metric to display. Metrics can be one of the following:
	both - (Default)Display both I/O time and I/O size histograms
	time - Display only the I/O time histogram
	size - Display only the I/O size histogram
.EXAMPLE
    PS:> Get-A9SystemReportHistogramLogicalDisk -LDName tp-0-sd-0.108 | ft *

	Date       Time     TimeZone Secs       0.50(millisec) 1(millisec) 2(millisec) 4(millisec) 8(millisec) 16(millisec) 32(millisec) 64(millisec) 128(millisec) 256(millisec) 4k(bytes) 8k(bytes) 16k(bytes) 32k(bytes)
	----       ----     -------- ----       -------------- ----------- ----------- ----------- ----------- ------------ ------------ ------------ ------------- ------------- --------- --------- ---------- ----------
	2025-02-11 12:45:00 MST      1739303100 3588           5124        7506        4960        6738        3899         3907         1336         394           38            12        172       3          0
	2025-02-11 12:50:00 MST      1739303400 2676           643         595         373         499         79           24           0            2             0             31        501       12         0
	2025-02-11 12:55:00 MST      1739303700 1433           913         624         427         523         113          9            1            0             1             94        296       3          0
	2025-02-11 13:00:00 MST      1739304000 509            113         147         94          203         99           15           5            0             0             32        237       3          0
		...
.EXAMPLE
    PS:> Get-A9SystemReportHistogramLogicalDisk -Hourly -btsecs -24h

	example displays aggregate hourly histogram performance statistics for all logical disks beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SystemReportHistogramLogicalDisk -Metric Both
#>
[CmdletBinding()]
param(	[Parameter()]		[switch]		$attime,
		[Parameter()]		[String]		$btsecs,
		[Parameter()]		[String]		$etsecs,
		[Parameter()]		[switch]        $Hourly ,
		[Parameter()]		[switch]        $Daily ,
		[Parameter()]		[switch]        $Hires ,
		[Parameter()]		[switch]		$rw,
		[Parameter()][ValidateSet('DOM_NAME','LDID','LD_NAME','CPG_NAME','NODE')]		
							[String]		$groupby,
		[Parameter()]		[String]		$cpgName,
		[Parameter()]		[String]		$node,
		[Parameter()]		[String]		$LDName,
		[Parameter()][ValidateSet('both','time','size')]
							[String]		$Metric,
		[Parameter()]		[Switch]		$ShowRaw
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = "srhistld "
	if($btsecs)	{	$srinfocmd += " -btsecs $btsecs"	}
	if($etsecs)	{	$srinfocmd += " -etsecs $etsecs"	}
	if($rw)		{	$srinfocmd +=  " -rw "				}
	if($groupby){	$srinfocmd += " -groupby $groupby"	}		
	if($Hourly)	{	$srinfocmd += " -hourly"			}
	if($Daily)	{	$srinfocmd += " -daily"				}
	if($Hires)	{	$srinfocmd += " -hires"				}
	if($cpgName){	$srinfocmd +=  " -cpg $cpgName "	}
	if($node)	{	$srinfocmd +=  " -node $node "		}
	if($LDName)	{	$srinfocmd += " $LDName "			}
	if($Metric)	{	$srinfocmd += " -metric $Metric"	}
	if($attime)	{	$srinfocmd += " -attime "			}
	write-verbose "System reporter command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd	
}
End
{	
	$tempFile = [IO.Path]::GetTempFileName()
	if($attime)
		{	write-verbose "System reporter command => $srinfocmd"
			if($groupby)	{	$optionname = $groupby.toUpper()	}
			else			{	$optionname = "LD_NAME"				}
			Add-Content -Path $tempFile -Value "$optionname,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
			$rangestart = "3"
		}
	elseif($Metric -eq "time")
		{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec)"
		}
	elseif($Metric -eq "size")
		{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
		}
	else
		{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
		}
	if ($ShowRaw)	{ return $Result }
	if( ($Result.count) -le "3")
		{	Remove-Item  $tempFile
			Write-warning "No data available"
			return
		}
	foreach ($s in  $Result[$rangestart..($Result.count-1)] )
		{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
			Add-Content -Path $tempFile -Value $s
		}
	$Result = Import-Csv $tempFile
	Remove-Item  $tempFile
	return $Result
}
}

Function Get-A9SystemReportRHistogramPhysicalDisk
{
<#
.SYNOPSIS
    Command displays historical histogram performance data reports for physical disks. 
.DESCRIPTION
    Command displays historical histogram performance data reports for physical disks. 
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires. If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER rw
	Specifies that the display includes separate read and write data. If notspecified, the total is displayed.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	PDID      Physical disk ID
	PORT_N    The node number for the primary port for the the PD
	PORT_S    The PCI slot number for the primary port for the the PD
	PORT_P    The port number for the primary port for the the PD
	DISK_TYPE  The disktype of the PD
	SPEED     The speed of the PD
.PARAMETER diskType
	Limit the data to disks of the types specified. Allowed types are
	FC  - Fast Class
	NL  - Nearline
	SSD - Solid State Drive
.PARAMETER rpmSpeed
        Limit the data to disks of the specified RPM. Allowed speeds are 7, 10, 15, 100 and 150
.PARAMETER Metric both|time|size
	Selects which metric to display. Metrics can be one of the following:
	both - (Default)Display both I/O time and I/O size histograms
	time - Display only the I/O time histogram
	size - Display only the I/O size histogram
.PARAMETER PDID
	LDs matching either the specified LD_name or glob-style pattern are included. This specifier can be repeated to display information for multiple LDs. If not specified, all LDs are included.
.EXAMPLE
    PS:> Get-A9SystemReportRHistogramPhysicalDisk

	Command displays historical histogram performance data reports for physical disks. 
.EXAMPLE
    PS:> Get-A9SystemReportRHistogramPhysicalDisk -Hourly -btsecs -24h

	Example displays aggregate hourly histogram performance statistics for all physical disks beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SystemReportRHistogramPhysicalDisk -Groupby SPEED
	
.EXAMPLE
    PS:> Get-A9SystemReportRHistogramPhysicalDisk -Metric both 
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,
		[Parameter()]	[switch]    $Daily ,
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[switch]	$rw,
		[Parameter()]	
			[ValidateSet("PDID","PORT_N","PORT_S","PORT_P","DISK_TYPE","SPEED")]
						[String]	$groupby,
		[Parameter()]	
			[ValidateSet("FC","NL","SSD")]
						[String]	$diskType,
		[Parameter()]
			[ValidateSet("7","10","15","100","150")]	
						[String]	$rpmSpeed,
		[Parameter()]	[String]	$PDID,
		[Parameter()]
			[ValidateSet("both","time","size")]	
						[String]	$Metric,
		[Parameter()]	[switch]	$ShowRaw
)
Begin
{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
}
Process	
{	$srinfocmd = "srhistpd "
	if($btsecs)	{	$srinfocmd += " -btsecs $btsecs"	}
	if($etsecs)	{	$srinfocmd += " -etsecs $etsecs"	}
	if($rw)		{	$srinfocmd +=  " -rw "	}
	if($groupby){	$srinfocmd += " -groupby $groupby"	}		
	if($Hourly)	{	$srinfocmd += " -hourly"	}
	if($Daily)	{	$srinfocmd += " -daily"		}
	if($Hires)	{	$srinfocmd += " -hires"		}
	if($diskType){	$srinfocmd += " -disk_type $diskType "	}
	if($Metric)	{	$srinfocmd += " -metric $Metric"	}					
	if($rpmSpeed)	{	$srinfocmd +=  " -rpm $rpmSpeed "	}
	if($PDID)	{	$srinfocmd += " $PDID "	}
	$tempFile = [IO.Path]::GetTempFileName()
	if($attime)
		{	$srinfocmd += " -attime "
			write-verbose "System reporter command => $srinfocmd"
			if($groupby)	{	$optionname = $groupby.toUpper()	}
			else			{	$optionname = "PDID"				}
			Add-Content -Path $tempFile -Value "$optionname,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
			$rangestart = "3"
		}
	elseif($Metric -eq "time")
		{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec)"
		}
	elseif($Metric -eq "size")
		{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
		}
	else{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
		}
	write-verbose "System reporter command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End{
	if ($ShowRaw) { return $result }
	if(($Result.count) -le "3")
		{	Remove-Item  $tempFile
			return "No data available"
		}
	foreach ($s in  $Result[$rangestart..($Result.count)] )
		{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
			Add-Content -Path $tempFile -Value $s
		}
	$Result = Import-Csv $tempFile	
	Remove-Item  $tempFile
	return $Result
}
}

Function Get-A9SystemReportHistogramPort
{
<#
.SYNOPSIS
    Command displays historical histogram performance data reports for ports.
.DESCRIPTION
    Command displays historical histogram performance data reports for ports. 	
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
        - The absolute epoch time (for example 1351263600).
		- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes
			(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
        If it is not specified then the time at which the report begins depends
        on the sample category (-hires, -hourly, -daily):        
			- For hires, the default begin time is 12 hours ago (-btsecs -12h).
            - For hourly, the default begin time is 7 days ago (-btsecs -7d).
            - For daily, the default begin time is 90 days ago (-btsecs -90d).
        If begin time and sample category are not specified then the time
        the report begins is 12 hours ago and the default sample category is hires.
        If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report.
        The value can be specified as either
        - The absolute epoch time (for example 1351263600).
        - A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
			be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
        If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Metric_Val both|time|size
	Selects which metric to display. Metrics can be one of the following:
		both - (Default)Display both I/O time and I/O size histograms
		time - Display only the I/O time histogram
		size - Display only the I/O size histogram
.PARAMETER rw
	Specifies that the display includes separate read and write data. If notspecified, the total is displayed.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	PORT_N      The node number for the port
	PORT_S      The PCI slot number for the port
	PORT_P      The port number for the port
	PORT_TYPE   The type of the port
	GBITPS      The speed of the port
	TRANS_TYPE  The transaction type - ctl or data
.PARAMETER portType
	Limit the data to port of the types specified. Allowed types are
	disk  -  Disk port
	host  -  Host Fibre channel port
	iscsi -  Host ISCSI port
	free  -  Unused port
	fs    -  File Persona port
	peer  -  Data Migration FC port
	rcip  -  Remote copy IP port
	rcfc  -  Remote copy FC port
.PARAMETER Port	
	Ports with <port_n>:<port_s>:<port_p> that match any of the specified[<npat>:<spat>:<ppat>...] patterns are included, where each of the patterns is a glob-style pattern. If not specified, all ports are included.
.EXAMPLE
    PS:> Get-A9SystemReportHistogramPort 

	Command displays historical histogram performance data reports for ports.	
.EXAMPLE
    PS:> Get-A9SystemReportHistogramPort -Metric_Val size
.EXAMPLE
    PS:> Get-A9SystemReportHistogramPort -Groupby PORT_N	
.EXAMPLE
    PS:> Get-A9SystemReportHistogramPort -Hurly -btsecs -24h -portType "host,disk" -port "0:*:* 1:*:*"
	
	example displays aggregate hourly histogram performance statistics for disk and host ports on nodes 0 and 1 beginning 24 hours ago:
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,
		[Parameter()]	[switch]    $Daily ,
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[switch]	$rw,
		[Parameter()][ValidateSet('PORT_N','PORT_S','PORT_P','PORT_TYPE','GBITPS','TRANS_TYPE')]
						[String[]]	$groupby,
		[Parameter()][ValidateSet('disk','host','iscsi','free','fs','peer','rcip','rcfc')]
						[String[]]	$portType,
		[Parameter()]	[String]	$Port,
		[Parameter()][ValidateSet('both','time','size' )]
						[String]	$Metric_Val,
		[Parameter()]	[switch]	$ShowRaw
	)
Begin
{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
}
Process	
{	$srinfocmd = "srhistport "
	if($btsecs)		{	$srinfocmd += " -btsecs $btsecs"	}
	if($etsecs)		{	$srinfocmd += " -etsecs $etsecs"	}
	if($rw)			{	$srinfocmd +=  " -rw "				}
	if($groupby)	{	$srinfocmd += " -groupby $groupby"	}		
	if($Hourly)		{	$srinfocmd += " -hourly"			}
	if($Daily)		{	$srinfocmd += " -daily"				}
	if($Hires)		{	$srinfocmd += " -hires"				}
	if($portType)	{	$srinfocmd += " -port_type $portType"}		
	if($Port)		{	$srinfocmd += " $Port "				}
	if($Metric_Val)	{	$srinfocmd += " -metric $Metric_Val"}				
	$tempFile = [IO.Path]::GetTempFileName()
	if($attime)
		{	$srinfocmd += " -attime "
			write-verbose "System reporter command => $srinfocmd"
			if($groupby)	{	$optionname = $groupby.toUpper()	}
			else			{	$optionname = "PORT_TYPE"			}
			Add-Content -Path $tempFile -Value "$optionname,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
			$rangestart = "3"
		}
	elseif($Metric_Val -eq "time")
		{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec)"
		}
	elseif($Metric_Val -eq "size")
		{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
		}
	else
		{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
		}
	write-verbose "System reporter command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
	if ($ShowRaw) { return $Result }
	if(($Result.count) -le "3")
		{	Remove-Item  $tempFile
			return "No data available "
		}
	foreach ($s in  $Result[$rangestart..($Result.count)] )
		{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
			Add-Content -Path $tempFile -Value $s
		}
	$Result = Import-Csv $tempFile
	Remove-Item  $tempFile
}
}

Function Get-A9SystemReportHistogramVLun
{
<#
.SYNOPSIS
    Command displays historical histogram performance data reports for VLUNs. 	
.DESCRIPTION
    Command displays historical histogram performance data reports for  VLUNs. 
.EXAMPLE
    PS:> Get-A9SystemReportHistogramVLun

	Command displays historical histogram performance data reports for  VLUNs. 	
.EXAMPLE
    PS:> Get-A9SystemReportHistogramVLun -Hourly -btsecs -24h

	example displays aggregate hourly histogram performance statistics for all VLUNs beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SystemReportHistogramVLun -btsecs -2h -host "set:hostset" -vv "set:vvset*"

	VV or host sets can be specified with patterns:
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes
		(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time
	the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report.
	The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER rw
	Specifies that the display includes separate read and write data. If notspecified, the total is displayed.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of  <groupby> items.  Each <groupby> must be different and one of the following:
	DOM_NAME  Domain name
	VV_NAME   Virtual Volume name
	HOST_NAME Host name
	LUN       The LUN number for the VLUN
	HOST_WWN  The host WWN for the VLUN
	PORT_N    The node number for the VLUN  port
	PORT_S    The PCI slot number for the VLUN port
	PORT_P    The port number for the VLUN port
	VVSET_NAME    Virtual volume set name
	HOSTSET_NAME  Host set name
.PARAMETER hostE
	-host <host_name|host_set|pattern>[,<host_name|host_set|pattern>...]
	Limit the data to hosts with names that match one or more of the
	specified names or glob-style patterns. Host set name must start with
	"set:" and can also include patterns.
.PARAMETER vv		
	-vv <VV_name|VV_set|pattern>[,<VV_name|VV_set|pattern>...]
	Limit the data to VVs with names that match one or more of the specified names or glob-style patterns. 
	VV set name must be prefixed by "set:" and can also include patterns.
.PARAMETER lun
    -lun <LUN|pattern>[,<LUN|pattern>...]
	Limit the data to LUNs that match one or more of the specified LUNs or glob-style patterns.
.PARAMETER Port
    -port <npat>:<spat>:<ppat>[,<npat>:<spat>:<ppat>...]
	Ports with <port_n>:<port_s>:<port_p> that match any of the specified <npat>:<spat>:<ppat> patterns are included, where each of the patterns is a glob-style pattern. If not specified, all ports are included.
.PARAMETER Metric_Val
	Selects which metric to display. Metrics can be one of the following:
	both - (Default)Display both I/O time and I/O size histograms
	time - Display only the I/O time histogram
	size - Display only the I/O size histogram
.PARAMETER ShowRaw
    This option will return the raw SSH output instead of trying to extract a PowerShell Object	
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,
		[Parameter()]	[switch]    $Daily ,
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[switch]	$rw,
		[Parameter()]	[ValidateSet("DOM_NAME","VV_NAME","HOST_NAME","LUN","HOST_WWN","PORT_N","PORT_S","PORT_P","VVSET_NAME","HOSTSET_NAME")]
						[String]	$groupby,
		[Parameter()]	[String]	$hostE,
		[Parameter()]	[String]	$vv,
		[Parameter()]	[String]	$lun,
		[Parameter()]	[String]	$Port,
		[Parameter()]	[ValidateSet("both","time","size")]	
						[String]	$Metric_Val,
		[Parameter()]	[Switch]	$ShowRaw		
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = "srhistvlun "
	if($btsecs)		{	$srinfocmd += " -btsecs $btsecs"	}
	if($etsecs)		{	$srinfocmd += " -etsecs $etsecs"	}
	if($rw)			{	$srinfocmd +=  " -rw "				}
	if($groupby)	{	$srinfocmd += " -groupby $groupby"	}		
	if($Hourly)		{	$srinfocmd += " -hourly"			}	
	if($Daily)		{	$srinfocmd += " -daily"				}
	if($Hires)		{	$srinfocmd += " -hires"				}
	if($hostE)		{	$srinfocmd +=  " -host $hostE "		}
	if($vv)			{	$srinfocmd +=  " -vv $vv "		}
	if($lun)		{	$srinfocmd +=  " -l $lun "		}		
	if($Port)		{	$srinfocmd += " -port $Port "	}
	if($Metric_Val)	{	$srinfocmd += " -metric $Metric_Val"	}
	$tempFile = [IO.Path]::GetTempFileName()
	if($attime)	{	$srinfocmd += " -attime "
					write-verbose "System reporter command => $srinfocmd"
					if($groupby)	{	$optionname = $groupby.toUpper()	}
					else			{	$optionname = "HOST_NAME"			}
					Add-Content -Path $tempFile -Value "$optionname,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
					$rangestart = "3"
				}
	elseif($Metric_Val -eq "time")
				{	$rangestart = "2"
					Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec)"
				}
	elseif($Metric_Val -eq "size")
				{	$rangestart = "2"
					Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
				}
	else{	$rangestart = "2"
					Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
				}
	write-verbose "System reporter command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
{	if(($Result.count) -le "3")	{	write-warning "No data available" }
	elseif( -not $ShowRaw )
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

Function Get-A9SystemReportLogicalDiskSpace
{
<#
.SYNOPSIS
    Command displays historical space data reports for logical disks (LDs).
.DESCRIPTION
    Command displays historical space data reports for logical disks (LDs).
	Example displays aggregate hourly LD space information for all RAID 5 LDs with names that match either "fc*" patterns beginning 24 hours ago:
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	
	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	DOM_NAME  Domain name
	CPG_NAME  Common Provisioning Group name
	LDID      Logical disk ID
	LD_NAME   Logical disk name
	DISK_TYPE  The disktype of the PDs used by the LD
	RAID_TYPE The RAID type of the LD
	SET_SIZE  The RAID set size of the LD
	STEP_SIZE The RAID step size of the LD
	ROW_SIZE  The RAID row size of the LD
	OWNER     The owner node for the LD
.PARAMETER cpgName
	Limit the data to LDs in CPGs with names that match one or more of the specified names or glob-style pattern
.PARAMETER DiskType 
	Limit the data to disks of the types specified. Allowed types are
		FC  - Fast Class
		NL  - Nearline
		SSD - Solid State Drive
.PARAMETER RaidType
	Limit the data to RAID of the specified types. Allowed types are 0, 1, 5 and 6
.PARAMETER Ownernode
	Limit data to LDs owned by the specified nodes.
.PARAMETER LDname
	CPGs matching either the specified CPG_name or glob-style pattern are included. This specifier can be repeated to display information for multiple CPGs. If not specified, all CPGs are included.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SystemReportLogicalDiskSpace
.EXAMPLE
    PS:> Get-A9SystemReportLogicalDiskSpace -groupby OWNER 

	Command displays historical space data reports for logical disks (LDs).
.EXAMPLE
    PS:> Get-A9SystemReportLogicalDiskSpace -DiskType FC

.EXAMPLE
    PS:> Get-A9SystemReportLogicalDiskSpace -raidType 5 -Hourly -btsecs 24h -LDName fc*

.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,
		[Parameter()]	[switch]    $Daily ,
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[ValidateSet("DOM_NAME","CPG_NAME","LDID","LD_NAME","DISK_TYPE","RAID_TYPE","SET_SIZE","STEP_SIZE","ROW_SIZE","OWNER")]
						[String]	$groupby,
		[Parameter()]	[String]	$cpgName,
		[Parameter()]	[ValidateSet("FC","NL","SSD")]
						[String]	$DiskType,
		[Parameter()]	[ValidateSet('0','1','5','6')]
						[String]	$RaidType,
		[Parameter()]	[String]	$ownernode,
		[Parameter()]	[String]	$LDname,
		[Parameter()]	[switch]	$ShowRaw
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = "srldspace"
	if($btsecs)		{	$srinfocmd += " -btsecs $btsecs"		}
	if($etsecs)		{	$srinfocmd += " -etsecs $etsecs"		}
	if($groupby)	{	$srinfocmd += " -groupby $groupby"		}			
	if($Hourly)		{	$srinfocmd += " -hourly"				}
	if($Daily)		{	$srinfocmd += " -daily"					}
	if($Hires)		{	$srinfocmd += " -hires"					}		
	if($RaidType)	{	$srinfocmd += " -raid_type $RaidType"	}
	if($DiskType)	{	$srinfocmd += " -disk_type $DiskType"	}
	if($cpgName)	{	$srinfocmd += " -cpg $cpgName"			}
	if($ownernode)	{	$srinfocmd +=  " -owner $ownernode"		}
	if($LDname)		{	$srinfocmd += " $LDName"				}
	$tempFile = [IO.Path]::GetTempFileName()
	if($attime)
		{	$srinfocmd += " -attime "
			if($groupby)	{	$optionname = $groupby.toUpper()	}
			else			{	$optionname = "LD_NAME"		}
			Add-Content -Path $tempFile -Value "$optionname,Raw(MB),Used(MB),Free(MB),Total(MB)"
			$rangestart = "3"
		}
	else{	Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,Raw(MB),Used(MB),Free(MB),Total(MB)"
			$rangestart = "2"
		}
	write-verbose "System reporter command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
{	if (-not $ShowRaw -or $Result.count -le 3)
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

Function Get-A9SystemReporterPhysicalDiskSpace
{
<#
.SYNOPSIS
    Command displays historical space data reports for physical disks (PDs).
.DESCRIPTION
    Command displays historical space data reports for physical disks (PDs).
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object group described by the -groupby option. 
	Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes
		(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and
	one of the following:
	PDID      Physical disk ID
	CAGEID    Cage ID
	CAGESIDE  Cage Side
	MAG       Disk Magazine number within the cage
	DISK      Disk position within the magazine
	DISK_TYPE The disktype of the PD
	SPEED     The disk speed		
.PARAMETER DiskType 
	Limit the data to disks of the types specified. Allowed types are
		FC  - Fast Class
		NL  - Nearline
		SSD - Solid State Drive
.PARAMETER capacity
	Display disk contributions to the system capacity categories: Allocated, Free, Failed, and Total
.PARAMETER rpmspeed
	Limit the data to disks of the specified RPM. Allowed speeds are  7, 10, 15, 100 and 150
.PARAMETER PDID
	PDs with IDs that match either the specified PDID or glob-style  pattern are included. This specifier can be repeated to include multiple PDIDs or patterns.  If not specified, all PDs are included.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object.  
.EXAMPLE
    PS:> Get-A9SRPhysicalDiskSpace 

	Command displays historical space data reports for physical disks (PDs).
.EXAMPLE
    PS:> Get-A9SRPhysicalDiskSpace -Hourly -btsecs -24h

	Example displays aggregate hourly PD space information for all PDs beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SRPhysicalDiskSpace -capacity -attime -diskType SSD

	Displays current system capacity values of SSD PDs:
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]		[switch]	$attime,
		[Parameter()]		[String]	$btsecs,
		[Parameter()]		[String]	$etsecs,
		[Parameter()]		[switch]    $Hourly ,
		[Parameter()]		[switch]    $Daily ,
		[Parameter()]		[switch]    $Hires ,
		[Parameter()]		[String]	$groupby,
		[Parameter()]
		[ValidateSet("FC","NL","SSD")]				
							[String]	$DiskType,
		[Parameter()]		[switch]	$capacity,
		[Parameter()]
		[ValidateSet("7","10","15","100","150")]	
							[String]	$rpmspeed,
		[Parameter()]		[String]	$PDID,
		[Oarameter()]		[switch]	$ShowRaw
	)
Begin
{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
}
Process	
{	$srinfocmd = "srpdspace"
	if($btsecs)		{	$srinfocmd += " -btsecs $btsecs"	}
			if($etsecs)		{	$srinfocmd += " -etsecs $etsecs"	}
			if($groupby)
				{	$commarr = "PDID","CAGEID","CAGESIDE","MAG","DISK","DISK_TYPE","SPEED"
					$lista = $groupby.split(",")
					foreach($suba in $lista)
						{	if( -not ($commarr -eq $suba.toUpper() ) )	{	return "FAILURE: Invalid groupby option it should be in ( $commarr )"	}
						}
					$srinfocmd += " -groupby $groupby"
				}		
			if($Hourly)		{	$srinfocmd += " -hourly"				}
			if($Daily)		{	$srinfocmd += " -daily"					}
			if($Hires)		{	$srinfocmd += " -hires"					}
			if($capacity)	{	$srinfocmd +=  " -capacity "			}
			if($rpmspeed)	{	$srinfocmd += " -rpm $rpmspeed"			}
			if($DiskType)	{	$srinfocmd += " -disk_type $DiskType"	}
			if($PDID)		{	$srinfocmd += " $PDID "					}
			$tempFile = [IO.Path]::GetTempFileName()
			if($attime)
				{	$srinfocmd += " -attime "
					write-verbose "System reporter command => $srinfocmd"
					#$rangenodata = "3"
					if($groupby)	{	$optionname = $groupby.toUpper()	}
					else			{	$optionname = "PDID"	}
					Add-Content -Path $tempFile -Value "$optionname,Normal(Chunklets)_Used_OK,Normal(Chunklets)_Used_Fail,Normal(Chunklets)_Avail_Clean,Normal(Chunklets)_Avail_Dirty,Normal(Chunklets)_Avail_Fail,Spare(Chunklets)_Used_OK,Spare(Chunklets)_Used_Fail,Spare(Chunklets)_Avail_Clean,Spare(Chunklets)_Avail_Dirty,Spare(Chunklets)_Avail_Fail,LifeLeft%,T(C)"			
					$rangestart = "3"
				}
			else
				{	$rangestart = "2"
					Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,Normal(Chunklets)_Used_OK,Normal(Chunklets)_Used_Fail,Normal(Chunklets)_Avail_Clean,Normal(Chunklets)_Avail_Dirty,Normal(Chunklets)_Avail_Fail,Spare(Chunklets)_Used_OK,Spare(Chunklets)_Used_Fail,Spare(Chunklets)_Avail_Clean,Spare(Chunklets)_Avail_Dirty,Spare(Chunklets)_Avail_Fail,LifeLeft%,T(C)"
				}
			write-verbose "System reporter command => $srinfocmd"
			$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
{	if ($Result.count -le "3" -or -not $ShowRaw )
		{	foreach ($s in  $Result[$rangestart..($Result.count)] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempFile -Value $s
				}
			$Result = Import-Csv $tempFile
		}
	return $Result
	Remove-Item  $tempFile
}
}

Function Get-A9SystemReporterRegionIODensity
{
<#
.SYNOPSIS
	Get-3parSRrgiodensit - System reporter region IO density reports.
.DESCRIPTION
	The Get-3parSRrgiodensit command shows the distribution of IOP/s intensity for Logical Disk (LD) regions for a common provisioning group (CPG) or Adaptive Optimization (AO) configuration. 
	For a single CPG, this can be used to see whether AO can be effectively used.  For an AO configuration the command shows how AO has moved regions between tiers.
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
	If it is not specified then the time at which the report begins is 12 hours ago. If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Cmult
	Select the step between histogram columns of the report.  By default each column's IO density is 4 times the previous column, but a step of 2 or 8 can also be specified.
.PARAMETER Cpg
	Treat the specifiers as CPG names or glob-style patterns.
.PARAMETER Vv
	Limit the analysis to VVs with names that match one or more of the specified names or glob-style patterns. VV set names must be prefixed by "set:". 
	Note that snapshot VVs will not be considered since only base VVs have region space.
.PARAMETER Cumul
	Show data as cumulative including all the columns to the right.
.PARAMETER Pct
	Show data as a percentage per row.
.PARAMETER Totpct
	Show data as a totaled percentage across an AOCFG.
.PARAMETER Withvv
	Show the data for each VV.
.PARAMETER Rw
	Specifies that the display includes separate read and write data. If not specified, the total is displayed.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Btsecs,
		[Parameter()]	[String]	$Etsecs,
		[Parameter()]	[String]	$Cmult,
		[Parameter()]	[String]	$Cpg,
		[Parameter()]	[String]	$Vv,
		[Parameter()]	[switch]	$Cumul,
		[Parameter()]	[switch]	$Pct,
		[Parameter()]	[switch]	$Totpct,
		[Parameter()]	[switch]	$Withvv,
		[Parameter()]	[switch]	$Rw,
		[Parameter()]	[String]	$Aocfg_name,
		[Parameter()]	[swtich]	$ShowRaw
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " srrgiodensity "
	if($Btsecs)	{	$Cmd += " -btsecs $Btsecs " }
	if($Etsecs)	{	$Cmd += " -etsecs $Etsecs "	}
	if($Cmult)	{	$Cmd += " -cmult $Cmult "	}
	if($Cpg)	{	$Cmd += " -cpg $Cpg" 		}
	if($Vv)		{	$Cmd += " -vv $Vv " 		}
	if($Cumul)	{	$Cmd += " -cumul " 			}
	if($Pct)	{	$Cmd += " -pct " 			}
	if($Totpct)	{	$Cmd += " -totpct " 		}
	if($Withvv)	{	$Cmd += " -withvv " 		}
	if($Rw)		{	$Cmd += " -rw " 			}
	if($Aocfg_name){$Cmd += " $Aocfg_name " 	}
}
End
{	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9SystemReporterStatCache
{
<#
.SYNOPSIS
    Command displays historical performance data reports for flash cache and data cache.
.DESCRIPTION
    Command displays historical performance data reports for flash cache and data cache.
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes
		(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER InternalFlashcache
	Lists the IOPS and bandwidth each for both read back and destaged write flash cache activity. May be combined with -fmp_queue and -cmp_queue.
.PARAMETER FmpQueue
	List the FMP queue statistics. May be combined with -cmp_queue and -internal_flashcache.
.PARAMETER CmpQueue
	List the CMP queue statistics. May be combined with -fmp_queue and -internal_flashcache.
.PARAMETER Full
	List all the metrics for each row in a single line.  The output for this option is very wide.
.PARAMETER groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	NODE      The controller node
.PARAMETER Node
	Only the specified node numbers are included, where each node is a number from 0 through 7. If want to display information for multiple nodes specift <nodenumber>,<nodenumber2>,etc. 
	If not specified, all nodes are included. Get-SRStatCache  -Node 0,1,2
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SystemReportStatCache

	Command displays historical performance data reports for flash cache and data cache.
.EXAMPLE
    PS:> Get-A9SystemReportStatCache -Hourly -btsecs -24h
	
	Example displays aggregate hourly performance statistics for flash cache and data cache beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SystemReportStatCache -Daily -attime -groupby node     

	Example displays daily flash cache and data cache performance aggregated by nodes
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,
		[Parameter()]	[switch]    $Daily ,	
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[switch]    $InternalFlashCache ,	
		[Parameter()]	[switch]    $FmpQueue ,	
		[Parameter()]	[switch]    $CmpQueue ,
		[Parameter()]	[switch]    $Full ,	
		[Parameter()]	[String]	$groupby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[swtich]	$ShowRaw
)
Begin
{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
}
Process	
{	$srinfocmd = "srstatcache "
	if($btsecs)	{	$srinfocmd += " -btsecs $btsecs"	}
	if($etsecs)	{	$srinfocmd += " -etsecs $etsecs"	}
	if($groupby)
		{	$commarr = "NODE"
			$lista = $groupby.split(",")
			foreach($suba in $lista)
				{	if(-not ($commarr -eq $suba.toUpper() ) )	{	return "FAILURE: Invalid groupby option it should be in ( $commarr )"	}
				}
			$srinfocmd += " -groupby $groupby"
		}
	if($Hourly)		{	$srinfocmd += " -hourly"		}
	if($Daily)		{	$srinfocmd += " -daily"			}
	if($Hires)		{	$srinfocmd += " -hires"			}
	if($InternalFlashCache)	{	$srinfocmd += " -internal_flashcache"		}
	if($FmpQueue)	{	$srinfocmd += " -fmp_queue"		}
	if($CmpQueue)	{	$srinfocmd += " -cmp_queue"		}
	if($Full)		{	$srinfocmd += " -full"			}
	if($Node)		{	$nodes = $Node.split(",")
						$srinfocmd += " $nodes"
					}
	$tempFile = [IO.Path]::GetTempFileName()
	if($attime)
		{	$srinfocmd += " -attime "
			write-verbose "System reporter command => $srinfocmd"
			if($groupby)	{	$optionname = $groupby.toUpper()	}
			else			{	$optionname = "NODE"	}
			Add-Content -Path $tempFile -Value "$optionname,CMP_r/s,CMP_w/s,CMP_rhit%,CMP_whit%,FMP_rhit%,FMP_whit%,FMP_Used%,Read_Back_IO/s,Read_Back_MB/s,Dstg_Wrt_IO/s,Dstg_Wrt_MB/s"
			$rangestart = "3"			
		}
	elseif($groupby)
		{	$optionname = $groupby.toUpper()
			$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,$optionname,CMP_r/s,CMP_w/s,CMP_rhit%,CMP_whit%,FMP_rhit%,FMP_whit%,FMP_Used%,Read_Back_IO/s,Read_Back_MB/s,Dstg_Wrt_IO/s,Dstg_Wrt_MB/s"
		}
	else{	$rangestart = "2"
			Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,CMP_r/s,CMP_w/s,CMP_rhit%,CMP_whit%,FMP_rhit%,FMP_whit%,FMP_Used%,Read_Back_IO/s,Read_Back_MB/s,Dstg_Wrt_IO/s,Dstg_Wrt_MB/s"
		}
	write-verbose "System reporter command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
{	if ( (-not $ShowRaw) -or ( ($Result.count) -le "3") )	
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

Function Get-A9SystemReporterStatCacheMemoryPages
{
<#
.SYNOPSIS
    Command displays historical performance data reports for cache memory
.DESCRIPTION
    Command displays historical performance data reports for cache memory
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes
		(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires. If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
	.PARAMETER Hourly
	Select hourly samples for the report.
	.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Full
	List all the metrics for each row in a single line.  The output for
	this option is very wide.
.PARAMETER Page
	List the page state information.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and
	one of the following:
	NODE      The controller node
.PARAMETER Node
	Only the specified node numbers are included, where each node is a number from 0 through 7. If want to display information for multiple nodes specift <nodenumber>,<nodenumber2>,etc. 
	If not specified, all nodes are included. Get-SRStatCMP  -Node 0,1,2
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SystemReporterStatCacheMemoryPages

	Command displays historical performance data reports for cache memory
.EXAMPLE
    PS:> Get-A9SystemReporterStatCacheMemoryPages -Hourly -btsecs -24h

	Example displays aggregate hourly performance statisticsfor all node caches beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SystemReporterStatCacheMemoryPages -Daily -attime -groupby node     

	Example displays daily node cache performance aggregated by nodes
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,
		[Parameter()]	[switch]    $Daily ,
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[switch]    $Full ,	
		[Parameter()]	[switch]    $Page ,	
		[Parameter()]	[String]	$groupby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[switch]	$ShowRaw
	)
Begin
{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
}
Process	
{	$srinfocmd = "srstatcmp "
	if($btsecs)		{	$srinfocmd += " -btsecs $btsecs"	}
		if($etsecs)		{	$srinfocmd += " -etsecs $etsecs"	}
		if($groupby)	{	$commarr = "NODE"
							if($commarr -eq $groupby.toUpper())	{	$srinfocmd += " -groupby $groupby"	}
							else				{	return "FAILURE: Invalid groupby option it should be in ( $commarr )"	}
						}		
		if($Hourly)		{	$srinfocmd += " -hourly"	}
		if($Daily)		{	$srinfocmd += " -daily"		}
		if($Hires)		{	$srinfocmd += " -hires"		}
		if($Full)		{	$srinfocmd += " -full"		}
		if($Page)		{	$srinfocmd += " -page"		}		
		if($Node)		{	$nodes = $Node.split(",")
							$srinfocmd += " $nodes"			
						}
		$tempFile = [IO.Path]::GetTempFileName()
		if($attime)		{	$srinfocmd += " -attime "
							write-verbose "System reporter command => $srinfocmd"
							if($groupby)	{	$optionname = $groupby.toUpper()	}
							else			{	$optionname = "NODE"				}
							Add-Content -Path $tempFile -Value "NODE,rhit(count/sec),whit(count/sec),r(count/sec),w(count/sec),r+w(count/sec),lockblk(count/sec),r(hit%),w(hit%),NL(dack/sec),FC(dack/sec),SSD(dack/sec)"
							$rangestart = "3"			
						}
		elseif($groupby)
			{	$optionname = $groupby.toUpper()
				$rangestart = "2"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,$optionname,rhit(count/sec),whit(count/sec),r(count/sec),w(count/sec),r+w(count/sec),lockblk(count/sec),r(hit%),w(hit%),NL(dack/sec),FC(dack/sec),SSD(dack/sec)"						
			}
		elseif($Page)
			{	$rangestart = "2"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,Free,Clean,Write1,Writen,Wrtsched,Writing,Dcowpend,NL(Dirty),FC(Dirty),SSD(Dirty),NL(MaxDirty),FC(MaxDirty),SSD(Max Dirty)"
			}
		elseif($Full)
			{	$rangestart = "2"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,rhit(count/sec),whit(count/sec),r(count/sec),w(count/sec),r+w(count/sec),lockblk(count/sec),r(hit%),w(hit%),NL(dack/sec),FC(dack/sec),SSD(dack/sec),free(PageStates),clean(PageStates),write1(PageStates),writen(PageStates),wrtsched(PageStates),writing(PageStates),dcowpend(PageStates),NL(DirtyPages),FC(DirtyPages),SSD(DirtyPages),NL(MaxDirtyPages),SSD(MaxDirtyPages)"
			}
		else{	$rangestart = "2"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,rhit(count/sec),whit(count/sec),r(count/sec),w(count/sec),r+w(count/sec),lockblk(count/sec),r(hit%),w(hit%),NL(dack/sec),FC(dack/sec),SSD(dack/sec)"			
			}
		write-verbose "System reporter command => $srinfocmd"
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
{		if ( (-not $ShowRaw) -or (($Result.count) -le "3"))
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

Function Get-A9SystemReporterStatCPU
{
<#
.SYNOPSIS
    Command displays historical performance data reports for CPUs.
.DESCRIPTION
    Command displays historical performance data reports for CPUs.
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.	
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report.
	The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of  <groupby> items.  Each <groupby> must be different and one of the following:
	NODE      The controller node
	CPU       The CPU within the controller node
.PARAMETER Node
	Only the specified node numbers are included, where each node is a number from 0 through 7. If want to display information for multiple nodes specift <nodenumber>,<nodenumber2>,etc. If not specified, all nodes are included.
	Get-SRStatCPU  -Node 0,1,2
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SRStatCPU_CLI 

	Command displays historical performance data reports for CPUs.
.EXAMPLE
    PS:> Get-A9SRStatCPU_CLI -Groupby CPU
.EXAMPLE
    PS:> Get-A9SRStatCPU_CLI -btsecs 24h
.EXAMPLE
    PS:> Get-A9SRStatCPU_CLI -Hourly -btsecs 24h
	
	Example displays aggregate hourly performance statistics for all CPUs beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SRStatCPU_CLI -option daily -attime -groupby node     

	Example displays daily node cpu performance aggregated by nodes
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,
		[Parameter()]	[switch]    $Daily ,
		[Parameter()]	[switch]    $Hires ,
		[Parameter()][ValidateSet('CPU','NODE')]	
						[String]	$groupby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[switch]	$ShowRaw
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = "srstatcpu "
	if($btsecs)	{	$srinfocmd += " -btsecs $btsecs"	}
	if($etsecs)	{	$srinfocmd += " -etsecs $etsecs"	}
	if($groupby){	$srinfocmd += " -groupby $groupby"}		
	if($Hourly)	{	$srinfocmd += " -hourly"	}
	if($Daily)	{	$srinfocmd += " -daily"		}
	if($Hires)	{	$srinfocmd += " -hires"		}
	if($Node)	{	$nodes = $Node.split(",")
					$srinfocmd += " $nodes"
				}
	$tempFile = [IO.Path]::GetTempFileName()
	if($attime)	{	$srinfocmd += " -attime "
					if($groupby)	{	$optionname = $groupby.toUpper()	}
					else			{	$optionname = "NODE"	}
					$rangestart = "1"			
				}
	elseif($groupby)
				{	$optionname = $groupby.toUpper()
						$rangestart = "2"
						Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,$optionname,User%,Sys%,Idle%,Intr/s,CtxtSw/s"
				}
		else	{	$rangestart = "1"
					Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,User%,Sys%,Idle%,Intr/s,CtxtSw/s"
				}
		write-verbose "System reporter command => $srinfocmd"
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
{	if ( (-not $ShowRaw ) -or ( ($Result.count) -le "3" ) )
		{	foreach ($s in  $Result[$rangestart..$range1] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempFile -Value $s
				}
			$Result = Import-Csv $tempFile
		}
	Remove-Item  $tempFile
	return $Result
}
}

Function Set-A9SystemReporterAlertCrit
{
<#
.SYNOPSIS
    Command allows users to enable or disable a System Reporter alert criterion
.DESCRIPTION
    Command allows users to enable or disable a System Reporter alert criterion
.PARAMETER Daily
	This criterion will be evaluated on a daily basis at midnight.
.PARAMETER Hourly
	This criterion will be evaluated on an hourly basis.
.PARAMETER Hires
	This criterion will be evaluated on a high resolution (5 minute) basis.
	This is the default.
.PARAMETER Count
	The number of matching objects that must meet the criteria in order for the alert to be generated. Note that only one alert is generated in this case and not one alert per affected object.
.PARAMETER Critical
	This alert has the highest severity.
.PARAMETER Major
	This alert should require urgent action.
.PARAMETER Minor
	This alert should not require immediate action.
.PARAMETER Info
	This alert is informational only. This is the default.
.PARAMETER Enable
	Enables the specified criterion.
.PARAMETER Disable
	Disables the specified criterion.
.PARAMETER NameOfTheCriterionToModify
	Specifies the name of the criterion to modify. 
.PARAMETER Recurrences_Samples 
	The alert will only be generated if the other conditions of the criterion recur repeatedly. <recurrences> is an integer value from
	2 to 10, and <samples> is an integer from 2 to 10 representing the number of previous System Reporter samples in which the recurrences
	will be examined. <samples> must be at least the requested quantity of recurrences. Note that these samples refer to the selected resolution
	of the criterion: hires, hourly, or daily.
.PARAMETER Btsecs
	A negative number indicating the number of seconds before the data sample time used to evaluate conditions which compare against an
	average. Instead of a number representing seconds, btsecs can be specified with a suffix of m, h or d to represent time in minutes
	(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d). The relative time cannot be more than 10 samples ago: 50 minutes for hires, 10 hours
	for hourly, or 10 days for daily. If this option is not present the average is only computed for the most recent data sample. The
	-btsecs option may not be combined with the -recur option.
.PARAMETER PAT
	Specifies that certain patterns are treated as glob-style patterns and that all criteria matching the specified pattern will be modified. This
	option must be used if the pattern specifier is used. This option cannot be combined with -name, -condition, or any of the type-specific filtering options.
.PARAMETER ALL
	Specifies that all criteria will have the designated operation applied to them, changing the state or attributes of all criteria. This option
	cannot be combined with -name, -condition, or any of the type-specific filtering options.
.PARAMETER NewName
	Specifies that the name of the SR alert be changed to <newname>, with a maximum of 31 characters.
.EXAMPLE
    PS:> Set-A9SRAlertCrit -Enable -NameOfTheCriterionToModify write_port_check
.EXAMPLE
	PS:> Set-A9SRAlertCrit -Disable -NameOfTheCriterionToModify write_port_check
.EXAMPLE
	PS:> Set-A9SRAlertCrit -Daily -NameOfTheCriterionToModify write_port_check
.EXAMPLE
	PS:> Set-A9SRAlertCrit -Info -Name write_port_check
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]    $Enable, 
		[Parameter()]	[switch]    $Disable,
		[Parameter()]	[switch]    $Daily,    
		[Parameter()]	[switch]    $Hourly,
		[Parameter()]	[switch]    $Hires,
		[Parameter()]	[String]    $Count,		
		[Parameter()]	[String]    $Recurrences_Samples,
		[Parameter()]	[String]    $BtSecs,
		[Parameter()]	[switch]    $Critical,
		[Parameter()]	[switch]    $Major,
		[Parameter()]	[switch]    $Minor,
		[Parameter()]	[switch]    $Info,
		[Parameter()]	[switch]    $PAT,
		[Parameter()]	[switch]    $ALL,
		[Parameter()]	[String]    $NewName,		
		[Parameter(Mandatory)]	[String]    $NameOfTheCriterionToModify
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = "setsralertcrit "	
	if($Enable)		{	$srinfocmd += " -enable " 	}
	if($Disable)	{	$srinfocmd += " -disable " 	}
	if($Daily)		{	$srinfocmd += " -daily " 	}
	if($Hourly)		{	$srinfocmd += " -hourly " 	}
	if($Hires)		{	$srinfocmd += " -hires " 	}
	if($Count)		{	$srinfocmd += " -count $Count" 	}
	if($Recurrences_Samples){	$srinfocmd += " -recur $Recurrences_Samples " 	}
	if($BtSecs)		{	$srinfocmd += " -btsecs $BtSecs" 	}
	if($Critical)	{	$srinfocmd += " -critical " 	}
	if($Major)		{	$srinfocmd += " -major " 	}
	if($Minor)		{	$srinfocmd += " -minor " 	}
	if($Info)		{	$srinfocmd += " -info " 	}
	if($PAT)		{	$srinfocmd += " -pat "		}
	if($ALL)		{	$srinfocmd += " -all " 		}
	if($NewName)	{	$srinfocmd += " -name $NewName" 	}
	if($NameOfTheCriterionToModify)	{	$srinfocmd += " $NameOfTheCriterionToModify" 	}
	write-verbose "Set alert crit command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
	return $Result
}
}

Function Remove-A9SystemReporterAlertCrit
{
<#
.SYNOPSIS
    Command removes a criterion that System Reporter evaluates to determine if a performance alert should be generated.
.DESCRIPTION
    Command removes a criterion that System Reporter evaluates to determine if a performance alert should be generated.        
.PARAMETER Name
	Specifies the name of the criterion to Remove.  
.EXAMPLE
    PS:> Remove-A9SRAlertCrit -Name write_port_check 

	Example removes the criterion named write_port_check:
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$Name
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = "removesralertcrit "
	if ($Name)	{	$srinfocmd += " -f $Name"	}
	write-verbose "Remove alert crit => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
	if($Result)	{	write-warning "FAILURE :"	}
	else{	write-host "Success : sralert $Name has been removed" -ForegroundColor green}	
	return $Result
}
}

Function New-A9SystemReporterAlertCrit
{
<#
.SYNOPSIS
    Creates a criterion that System Reporter evaluates to determine if a performance alert should be generated.
.DESCRIPTION
    Creates a criterion that System Reporter evaluates to determine if a performance alert should be generated.
.PARAMETER Type
	Type must be one of the following: port, vlun, pd, ld, cmp, cpu, link, qos, rcopy, rcvv, ldspace, pdspace, cpgspace, vvspace, sysspace.
.PARAMETER Condition
	The condition must be of the format <field><comparison><value> where field is one of the fields corresponding to the type (see above),
	comparison is of the format <,<=,>,>=,=,!= and value is a numeric value, or is a numeric value followed by %_average to indicate that the field
	is to be compared against the average across multiple objects as as specified by filtering options and/or across multiple data sample
	times as specified by the -btsecs option. See examples. Note that some characters, such as < and >, are significant in most
	shells and must be escaped or quoted when running this command from another shell. Multiple conditions may be separated by comma (",") to
	indicate a logical AND requirement (conjunction). Conditions may be separated by the character "~" to indicate a logical OR requirement
	(disjunction). AND logic takes precedence over OR logic, and parentheses are not supported to override the natural precedence of the condition terms and logical operators.
.PARAMETER Name
	Specifies the name of the SR alert criterion, with a maximum of 31 characters.
.PARAMETER Daily
	This criterion will be evaluated on a daily basis at midnight.
.PARAMETER Hourly
	This criterion will be evaluated on an hourly basis.
.PARAMETER Hires
	This criterion will be evaluated on a high resolution (5 minute) basis. This is the default.
.PARAMETER Count 
	The number of matching objects that must meet the criteria in order for the alert to be generated. Note that only one alert is generated in this case and not one alert per affected object.
.PARAMETER Recurrences 
	The alert will only be generated if the other conditions of the criterion recur repeatedly. <recurrences> is an integer value from
	2 to 10, and <samples> is an integer from 2 to 10 representing the number of previous System Reporter samples in which the recurrences
	will be examined. <samples> must be at least the requested quantity of recurrences. Note that these samples refer to the selected resolution of the criterion: hires, hourly, or daily.
.PARAMETER Btsecs 
	A negative number indicating the number of seconds before the data sample time used to evaluate conditions which compare against an
	average. Instead of a number representing seconds, btsecs can be specified with a suffix of m, h or d to represent time in minutes
	(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d). The relative time cannot be more than 10 samples ago: 50 minutes for hires, 10 hours
	for hourly, or 10 days for daily. If this option is not present the average is only computed for the most recent data sample. The -btsecs option may not be combined with the -recur option.
.PARAMETER Critical
	This alert has the highest severity.
.PARAMETER Major
	This alert should require urgent action.
.PARAMETER Minor
	This alert should not require immediate action.
.PARAMETER Info
	This alert is informational only. This is the default.
.PARAMETER Comment 
	Specifies comments or additional information for the criterion. The comment can be up to 511 characters long.
.PARAMETER PortType 
	Limit the data to port of the types specified. Allowed types are
	disk  -  Disk port
	host  -  Host Fibre channel port
	iscsi -  Host ISCSI port
	free  -  Unused port
	fs    -  File Persona port
	peer  -  Data Migration FC port
	rcip  -  Remote copy IP port
	rcfc  -  Remote copy FC port
.PARAMETER Port 
	Ports with <port_n>:<port_s>:<port_p> that match any of the specified <npat>:<spat>:<ppat> patterns are included, where each of the patterns is a glob-style pattern. If not specified, all ports are included.
.PARAMETER Both 
	Specifies that both control and data transfers are displayed(-both), only control transfers are displayed (-ctl), or only data transfers are
	displayed (-data). If this option is not specified, only data transfers are displayed.
.PARAMETER CTL
	Specifies that both control and data transfers are displayed(-both), only control transfers are displayed (-ctl), or only data transfers are
	displayed (-data). If this option is not specified, only data transfers are displayed.
.PARAMETER Data
	Specifies that both control and data transfers are displayed(-both), only control transfers are displayed (-ctl), or only data transfers are
	displayed (-data). If this option is not specified, only data transfers are displayed.
.PARAMETER HostE
	Limit the data to hosts with names that match one or more of the specified names or glob-style patterns. Host set name must start with
	"set:" and can also include patterns. To specify the host by WWN, start with "wwn:". A WWN can also include glob-style patterns.
.PARAMETER VV 
	Limit the data to VVs with names that match one or more of the
	specified names or glob-style patterns. VV set name must be prefixed
	by "set:" and can also include patterns.
.PARAMETER vLun 
	Limit the data to VLUNs matching the specified combination of host, VV, lun, and port. Each of these components in this option may be a
	glob-style pattern. The host and VV components may specify a corresponding object set by prefixing "set:" to the component. The
	host component may specify a WWN by prefixing the component with "wwn:". The lun and port components are optional, and if not present,
	data will be filtered to any matching combination of host and VV. This option cannot be combined with -host, -vv, -l, or -port.
.PARAMETER CPG 
	Limit the data to LDs in CPGs with names that match one or more of the specified names or glob-style patterns.
.PARAMETER DiskType 
	Limit the data to disks of the types specified. Allowed types are
	FC  - Fast Class
	NL  - Nearline
	SSD - Solid State Drive
.PARAMETER RPM 
	Limit the data to disks of the specified RPM. Allowed speeds are 7, 10, 15, 100 and 150
.PARAMETER Target 
	Limit the data to TARGET_NAMEs that match one or more of the specified TARGET_NAMEs or glob-style patterns.
.PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
.PARAMETER Duration
	Once an alert is generated, the deferral period prevents the same alert from being repeated for a period of time. The deferral duration
	can be specified in seconds or with a suffix of m, h or d to represent time in minutes (e.g. 30m), hours (e.g. 1.5h), or days (e.g. 7d).
	Note that a single alert criteria can generate multiple alerts if multiple objects exceed the defined threshold. A deferral period
	applies to each unique alert. Acknowledging an alert with "setalert ack <id>" will end its deferral period early.
.EXAMPLE
    PS:> New-SRAlertCrit -Type port  -Condition "write_iops>50" -Name write_port_check

	Example describes a criterion that generates an alert for each port that has more than 50 write IOPS in a high resolution sample:
.EXAMPLE
    PS:> New-A9SRAlertCrit -Type port  -PortType disk -Condition "write_iops>50" -Name write_port_check   
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)][ValidateSet("port","vlun","pd","ld","cmp","cpu","link","qos","rcopy","rcvv")]	
						[String]    $Typed ,
		[Parameter(Mandatory)]	[String]   $Condition ,
		[Parameter(Mandatory)]	[String]    $Name ,
		[Parameter()]	[switch]    $Daily , 
		[Parameter()]	[switch]    $Hourly ,
		[Parameter()]	[switch]	$Hires ,
		[Parameter()]	[String]    $Count ,
		[Parameter()]	[String]    $Recurrences ,
		[Parameter()]	[String]    $Btsecs ,
		[Parameter()]	[switch]    $Critical ,
		[Parameter()]	[switch]    $Major ,
		[Parameter()]	[switch]    $Minor ,
		[Parameter()]	[switch]    $Info ,
		[Parameter()]	[String]    $Comment ,
		[Parameter()]	[ValidateSet("disk","host","iscsi","free","fs","peer","rcip","rcfc")]
						[String]    $PortType ,
		[Parameter()]	[String]    $PortNSP ,
		[Parameter()]	[switch]    $Both ,
		[Parameter()]	[switch]    $CTL ,
		[Parameter()]	[switch]    $Data ,
		[Parameter()]	[String]    $HostE ,
		[Parameter()]	[String]    $VV ,
		[Parameter()]	[String]    $vLun ,
		[Parameter()]	[String]    $Node ,
		[Parameter()]	[String]    $CPG ,
		[Parameter()]	[String]    $DiskType ,
		[Parameter()]	[String]    $RPM ,
		[Parameter()]	[String]    $Target ,
		[Parameter()]	[String]    $Duration     
	)
Begin
{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
}
Process
{	$srinfocmd = "createsralertcrit "	
	$srinfocmd += " $Typed "
	if($Daily)		{	$srinfocmd += " -daily "	}
	if($Hourly)		{	$srinfocmd += " -hourly "	}
	if($Hires)		{	$srinfocmd += " -hires "	}
	if($Count)		{	$srinfocmd += " -count $Count "	}
	if($Recurrences){	$srinfocmd += " -recur $Recurrences "	}
	if($Btsecs)		{	$srinfocmd += " -btsecs $Btsecs "	}
	if($Critical)	{	$srinfocmd += " -critical "	}
	if($Major)		{	$srinfocmd += " -major "	}
	if($Minor)		{	$srinfocmd += " -minor "	}
	if($Info)		{	$srinfocmd += " -info "	}
	if($Comment)	{	$srinfocmd += " -comment $Comment "	}
	if($Duration)	{	$srinfocmd += " defer $Duration "	}
	if($PortType)	{		$srinfocmd += " -port_type $PortType "	}
	if($PortNSP)	{	$srinfocmd += " -port $PortNSP "	}
	if($Both)		{	$srinfocmd += " -both "}
	if($CTL)		{	$srinfocmd += " -ctl "	}
	if($Data)		{	$srinfocmd += " -data "}
	if($HostE)		{	$srinfocmd += " -host $HostE "	}
	if($VV)			{	$srinfocmd += " -vv $VV "	}
	if($vLun)		{	$srinfocmd += " -vlun $vLun "	}
	if($Node)		{	$srinfocmd += " -node $Node "	}
	if($CPG)		{	$srinfocmd += " -cpg $CPG "	}
	if($DiskType)	{	$srinfocmd += " -disk_type $DiskType "	}
	if($RPM)		{	$srinfocmd += " -rpm $RPM "	}
	if($Target)		{	$srinfocmd += " -target $Target "	}
	if($Condition)	{	$srinfocmd += " $Condition "	}
	$srinfocmd += " $Name "
	write-verbose "Create alert criteria command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd
	if([string]::IsNullOrEmpty($Result))	
		{	Write-host "Success : Executing New-SRAlertCrit Command" -ForegroundColor Green 
		}
	else{	Write-warning "FAILURE : While Executing New-SRAlertCrit "	
		}
	return $Result
}
}

Function Get-A9SystemReporterStatPort
{
<#
.SYNOPSIS
	System reporter performance reports for ports.
.DESCRIPTION
	System reporter performance reports for ports.	
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires. If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report.
	The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	PORT_N    The node number for the port
	PORT_S    The PCI slot number for the port
	PORT_P    The port number for the port
	PORT_TYPE The type of the port
	GBITPS    The speed of the port
.PARAMETER portType    
	Limit the data to port of the types specified. Allowed types are
	disk  -  Disk port
	host  -  Host Fibre channel port
	iscsi -  Host ISCSI port
	free  -  Unused port
	fs    -  File Persona port
	peer  -  Data Migration FC port
	rcip  -  Remote copy IP port
	rcfc  -  Remote copy FC port
.PARAMETER port
    <npat>:<spat>:<ppat> Ports with <port_n>:<port_s>:<port_p> that match any of the specified <npat>:<spat>:<ppat> patterns are included, where each of the patterns
	is a glob-style pattern. This specifier can be repeated to include multiple ports or patterns. If not specified, all ports are included.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SRStatPort

	System reporter performance reports for ports.
.EXAMPLE
    PS:> Get-A9SRStatPort -portType "disk,host" -Hourly -btsecs -24h -port "0:*:* 1:*:*"

	Sexample displays aggregate hourly performance statistics for disk and host ports on nodes 0 and 1 beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SRStatPort -Groupby PORT_N
	
.EXAMPLE
    PS:> Get-A9SRStatPort -portType rcip
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,		
		[Parameter()]	[switch]    $Daily ,		
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[ValidateSet("PORT_N","PORT_S","PORT_P","PORT_TYPE","GBITPS")]
						[String]	$groupby,
		[Parameter()]	[VAlidateSet( "disk","host","iscsi","free","fs","peer","rcip","rcfc")]
						[String]	$portType,
		[Parameter()]	[String]	$port,
		[Parameter()]	[Switch]	$ShowRaw		
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process	
{	$srinfocmd = "srstatport "
		if($btsecs)	{	$srinfocmd += " -btsecs $btsecs"	}
		if($etsecs)	{	$srinfocmd += " -etsecs $etsecs"	}
		if($groupby){	$srinfocmd += " -groupby $groupby"	}		
		if($Hourly)	{	$srinfocmd += " -hourly"	}
		if($Daily)	{	$srinfocmd += " -daily"		}
		if($Hires)	{	$srinfocmd += " -hires"		}
		if($portType){	$srinfocmd += " -port_type $portType"	}
		if($port)	{	$srinfocmd += " $port "	}
		$tempFile = [IO.Path]::GetTempFileName()
		if($attime)
				{	$srinfocmd += " -attime "
					if($groupby)	{	$optionname = $groupby.toUpper()	}
					else			{	$optionname = "PORT_TYPE"	}
					Add-Content -Path $tempFile -Value "PORT_TYPE,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
					$rangestart = "3"
					$rangestart = "4"
				}
			elseif($groupby)
				{	$optionname = $groupby.toUpper()
					$rangestart = "2"	
					Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,$optionname,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"			
				}
			else
				{	$rangestart = "2"
					Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"			
				}
			write-verbose "System reporter command => $srinfocmd"
			$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
{	if ( (-not $ShowRaw) -and ($Result.count) -gt "3")		
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

Function Get-A9SystemReporterStatPhysicalDisk
{
<#
.SYNOPSIS
    System reporter performance reports for physical disks (PDs).
.DESCRIPTION
    System reporter performance reports for physical disks (PDs).
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires. If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
	Select the end time in seconds for the report.  If -attime is   specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	PDID      Physical disk ID
	PORT_N    The node number for the primary port for the the PD
	PORT_S    The PCI slot number for the primary port for the the PD
	PORT_P    The port number for the primary port for the the PD
	DISK_TYPE  The disktype of the PD
	SPEED     The speed of the PD
.PARAMETER diskType    
	Limit the data to disks of the types specified. Allowed types are
		FC  - Fast Class
		NL  - Nearline
		SSD - Solid State Drive
.PARAMETER rpmSpeed   
	Limit the data to disks of the specified RPM. Allowed speeds are 7, 10, 15, 100 and 150
.PARAMETER PDID
	PDs with IDs that match either the specified PDID or glob-style pattern are included. This specifier can be repeated to include multiple PDIDs or patterns. If not specified, all PDs are included.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SRStatPD_CLI 

	System reporter performance reports for physical disks (PDs).
.EXAMPLE
    PS:> Get-A9SRStatPD_CLI -Hourly -btsecs -24h

	example displays aggregate hourly performance statistics for all physical disks beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SRStatPD_CLI -Groupby SPEED
.EXAMPLE
    Get-SRStatPD -rpmSpeed 100
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,		
		[Parameter()]	[switch]    $Daily ,		
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[ValidateSet("PDID","PORT_N","PORT_S","PORT_P","DISK_TYPE","SPEED")]
						[String]	$groupby,
		[Parameter()]	[ValidateSet("FC","NL","SSD")]
						[String]	$diskType,
		[Parameter()]	[ValidateSet("7","10","15","100","150")]
						[String]	$rpmSpeed,
		[Parameter()]	[String]	$PDID,
		[Parameter()]	[Switch]	$ShowRaw
)
Begin
	{	Test-A9Connection -ClientType 'SshClient' 
	}
Process	
	{	$srinfocmd = "srstatpd "
		if($btsecs)	{	$srinfocmd += " -btsecs $btsecs"	}
		if($etsecs)	{	$srinfocmd += " -etsecs $etsecs"	}
		if($groupby){	$srinfocmd += " -groupby $groupby"	}		
		if($Hourly)	{	$srinfocmd += " -hourly"	}
		if($Daily)	{	$srinfocmd += " -daily"		}
		if($Hires)	{	$srinfocmd += " -hires"		}
		if($diskType){	$srinfocmd += " -disk_type $diskType"	}
		if($rpmSpeed){	$srinfocmd += " -rpm $rpmSpeed"	}
		if($PDID)	{	$srinfocmd += " $PDID "	}
		$tempFile = [IO.Path]::GetTempFileName()
		if($attime)
			{	$srinfocmd += " -attime "
				if($groupby)	{	$optionname = $groupby.toUpper()	}
				else			{	$optionname = "PDID"	}
				Add-Content -Path $tempFile -Value "PDID,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
				$rangestart = "3"
			}
		elseif($groupby)
			{	$optionname = $groupby.toUpper()
				$rangestart = "2"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,$optionname,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
			}
		else
			{	$rangestart = "2"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
			}
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd		
	}
End
	{	if ( (-not $ShowRaw) -and (-not  ( ($Result.count) -le "4") ))
			{	foreach ($s in  $Result[$rangestart..($Result.count-3)] )
					{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','	
						Add-Content -Path $tempFile -Value $s
					}
				$result = Import-Csv $tempFile	
			}
		Remove-Item  $tempFile
		return $returndata
	}
}

Function Get-A9SystemReporterStatLD
{
<#
.SYNOPSIS
    Command displays historical performance data reports for logical disks.
.DESCRIPTION
    Command displays historical performance data reports for logical disks.
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report.
	The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of  <groupby> items.  Each <groupby> must be different and one of the following:
	DOM_NAME  Domain name
	LDID      Logical disk ID
	LD_NAME   Logical disk name
	CPG_NAME  Common Provisioning Group name
	NODE      The node that owns the LD
.PARAMETER cpgName 	
	Limit the data to LDs in CPGs with names that match one or more of the specified names or glob-style patterns.
.PARAMETER Node  
	Limit the data to that corresponding to one of the specified nodes	
	-Node 0,1,2
.PARAMETER LDName
	LDs matching either the specified LD_name or glob-style pattern are included. This specifier can be repeated to display information for multiple LDs. If not specified, all LDs are included.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SRStatLD

	Command displays historical performance data reports for logical disks.
.EXAMPLE
    PS:> Get-A9SRStatLD -Hourly -btsecs -24h

	example displays aggregate hourly performance statistics for all logical disks beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SRStatLD -Groupby Node
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]    $Hourly ,		
		[Parameter()]	[switch]    $Daily ,		
		[Parameter()]	[switch]    $Hires ,
		[Parameter()]	[Validat3eSet("LDID","DOM_NAME","LD_NAME","CPG_NAME","NODE")]
						[String]	$groupby,
		[Parameter()]	[String]	$cpgName,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[String]	$LDName,
		[Parameter()]	[switch]	$ShowRaw
)
Begin
	{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
	}
Process	
	{	$srinfocmd = "srstatld "
		if($btsecs)	{	$srinfocmd += " -btsecs $btsecs"	}
		if($etsecs)	{	$srinfocmd += " -etsecs $etsecs"	}
		if($groupby){	$srinfocmd += " -groupby $groupby"	}		
		if($Hourly)	{	$srinfocmd += " -hourly"			}
		if($Daily)	{	$srinfocmd += " -daily"				}
		if($Hires)	{	$srinfocmd += " -hires"				}
		if($Node)	{	$nodes = $Node.split(",")
						$srinfocmd += " $nodes"			
					}
		if($cpgName){	$srinfocmd += " -cpg $cpgName "		}
		if($LDName)	{	$srinfocmd += " $LDName "			}
		$tempFile = [IO.Path]::GetTempFileName()
		if($attime)	{	$srinfocmd += " -attime "
						write-verbose "System reporter command => $srinfocmd"
						if($groupby)	{	$optionname = $groupby.toUpper()	}
						else			{	$optionname = "LD_NAME"				}
						Add-Content -Path $tempFile -Value "LD_NAME,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"												
						$rangestart = "3"		
					}
		elseif($groupby)
			{	$optionname = $groupby.toUpper()
				$rangestart = "2"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,$optionname,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
			}
		else{	$rangestart = "2"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
			}
		write-verbose "System reporter command => $srinfocmd"
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
	{	if ( (-not $ShowRaw) -and (-not ($Result.count -le "4")))
			{	foreach ($s in  $Result[$rangestart..($Result.count-3)] )
					{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
						Add-Content -Path $tempFile -Value $s
					}
				$Result = Import-Csv $tempFile		
			}
		Remove-Item  $tempFile
		return $Result
	}
}

Function Get-A9SystemReporterStatfssnapshot
{
<#
.SYNOPSIS
	System reporter performance reports for File Persona snapshots
.DESCRIPTION
	The command displays historical performance data reports for File Persona snapshots.
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
		detail 	Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
		per_time	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per time. By default, one summary is computed across all records.
		per_group	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per object grouping. By default, one summary is computed across all records.
		only_compareby	When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries
				using only that reduced set of object groupings. By default, summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items. Each <groupby> must be different and one of the following:
	NODE   The controller node
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects can be displayed, up to 32 objects for vstime reports or 128 objects
	for attime reports.  The field used for comparison can be any of the groupby fields or one of the following: numredirectonwrite
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
		[Parameter()]	[String]	$Groupby,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[String]	$Node,
		[Parameter()]	[String]	$Sortcol
)
Begin
	{	Test-A9Connection -ClientType SshClient
	}
Process	
	{	$Cmd = " srstatfssnapshot "
		if($Attime)		{	$Cmd += " -attime " 		}
		if($Btsecs)		{	$Cmd += " -btsecs $Btsecs " }
		if($Etsecs)		{	$Cmd += " -etsecs $Etsecs "	}
		if($Hires)		{	$Cmd += " -hires "			}
		if($Hourly)		{	$Cmd += " -hourly "			}
		if($Daily)		{	$Cmd += " -daily "			}
		if($Summary) 	{	$Cmd += " -summary $Summary "}
		if($Groupby)	{	$Cmd += " -groupby $Groupby " }
		if($Compareby)	{	$Cmd += " -compareby $Compareby "}
		if($Node)		{	$Cmd += " -node $Node "		}
		if($Sortcol)	{	$Cmd += " -sortcol $Sortcol "}
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Get-A9SystemReporterStatlink
{
<#
.SYNOPSIS
	System reporter performance reports for links.
.DESCRIPTION
	The command displays historical performance data reports for links (internode, PCI and cache memory).
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
		- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can be specified with a suffix of m, h or d to represent time 
			in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):
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
		detail		Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
		per_time	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per time. By default, one summary is computed across all records.
		per_group	When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per object grouping. By default, one summary is computed across all records.
		only_compareby When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries using only that reduced set of object groupings. By default,
			summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different an one of the following:
		NODE      The source controller node for the link
		QUEUE     The XCB queue
		NODE_TO   The destination controller node for the link
		ASIC_FROM The source ASIC for the link
		ASIC_TO   The destination ASIC for the link
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects can be displayed, up to 32 objects for vstime reports or 128 objects
	for attime reports.  The field used for comparison can be any of the groupby fields or one of the following: xfers_ps, kbps, szkb
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must be specified. 
	In addition, the direction of sorting (<dir>) can be specified as follows:
		inc		Sort in increasing order (default).
		dec		Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.PARAMETER Node
	Only the specified node numbers are included, where each node is a number from 0 through 7. This specifier can be repeated to display information for multiple nodes. If not specified, all nodes are included.
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
		[Parameter()]	[String]	$Sortcol,
		[Parameter()]	[String]	$Node
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process
	{	$Cmd = " srstatlink "
		if($Attime)		{	$Cmd += " -attime "			}
		if($Btsecs)		{	$Cmd += " -btsecs $Btsecs " }
		if($Etsecs)		{	$Cmd += " -etsecs $Etsecs " }
		if($Hires)		{	$Cmd += " -hires " 			}
		if($Hourly)		{	$Cmd += " -hourly " 		}
		if($Daily)		{	$Cmd += " -daily " 			}
		if($Summary)	{	$Cmd += " -summary $Summary " }
		if($Groupby)	{	$Cmd += " -groupby $Groupby " }
		if($Compareby)	{	$Cmd += " -compareby $Compareby " }
		if($Sortcol)	{	$Cmd += " -sortcol $Sortcol " }
		if($Node)		{	$Cmd += " $Node " 			}
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Get-A9SystemReporterStatqos
{
<#
.SYNOPSIS
	System reporter performance reports for QoS rules.
.DESCRIPTION
	The command displays historical performance data reports for QoS rules.
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
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires. If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER Etsecs
	Select the end time in seconds for the report.  If -attime is specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
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
		summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Vvset
	Limit the data to VVSets with names that match one or more of the specified names or glob-style patterns. This option is deprecated and will be removed in a subsequent release.
.PARAMETER AllOthers
	Display statistics for all other I/O not regulated by a QoS rule. This option is deprecated and will be removed in a subsequent release.
.PARAMETER Target
	Limit the data to the specified QoS target rule(s). Include a target type either {vvset|domain}, and a name or glob-style pattern.
	The sys:all_others rule can be selected to display statistics for all other host I/O not regulated by any "on" QoS rule. Multiple targets types can be specified as a comma separated list.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	DOM_NAME        Domain name
	TARGET_TYPE     Type of QoS rule target, i.e. vvset
	TARGET_NAME     Name of QoS rule target
	IOPS_LIMIT      The I/O per second limit
	BW_LIMIT_KBPS   The KB per second bandwidth limit
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects can be displayed, up to 32 objects for vstime reports or 128 objects
	for attime reports.  The field used for comparison can be any of the groupby fields or one of the following: read_iops, write_iops, total_iops, read_kbps, write_kbps, total_kbps, read_svctms, write_svctms, 
	total_svctms, read_ioszkb, write_ioszkb, total_ioszkb, total_qlen, busy_pct read_wait_ms, write_wait_ms, total_wait_ms, total_wqlen, total_io_rej, io_limit, bw_limit, priority, io_guarantee,
	bw_guarantee, latency_target_ms, latency_ms
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must  be specified. 
	In addition, the direction of sorting (<dir>) can be  specified as follows:
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
		[Parameter()]	[String]	$Vvset,
		[Parameter()]	[switch]	$AllOthers,
		[Parameter()]	[String]	$Target,
		[Parameter()][ValidateSet('DOM_NAME','TARGET_TYPE','TARGET_NAME','IOPS_LIMIT','BW_LIMIT_KBPS')]	
						[String]	$Groupby,
		[Parameter()]	[String]	$Compareby,
		[Parameter()]	[String]	$Sortcol
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process
	{	$Cmd = " srstatqos "
		if($Attime)		{	$Cmd += " -attime " }
		if($Btsecs)		{	$Cmd += " -btsecs $Btsecs " }
		if($Etsecs)		{	$Cmd += " -etsecs $Etsecs "}
		if($Hires)		{	$Cmd += " -hires "}
		if($Hourly) 	{	$Cmd += " -hourly "}
		if($Daily) 		{	$Cmd += " -daily "}
		if($Summary)	{	$Cmd += " -summary $Summary "}
		if($Vvset)		{	$Cmd += " -vvset $Vvset "}
		if($AllOthers) 	{	$Cmd += " -all_others " }
		if($Target) 	{	$Cmd += " -target $Target "}
		if($Groupby) 	{	$Cmd += " -groupby $Groupby " }
		if($Compareby) 	{	$Cmd += " -compareby $Compareby " }
		if($Sortcol)	{	$Cmd += " -sortcol $Sortcol "}
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	} 
}

Function Get-A9SystemReporterStatrcvv
{
<#
.SYNOPSIS
    System reporter performance reports for Remote Copy volumes.
.DESCRIPTION
	The command displays historical performance data reports for Remote Copy volumes.
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
	detail
		Display individual performance records in addition to one or more summaries. By default, -summary output excludes individual records and only displays the summary.
	per_time
		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per time. By default, one summary is computed across all records.
	per_group
		When requesting data across multiple points in time (vstime) and multiple object groupings (-groupby) compute summaries per
		object grouping. By default, one summary is computed across all records.
	only_compareby
		When requesting data limited to certain object groupings with the -compareby option, use this keyword to compute summaries using only that reduced set of object groupings. By default,
		summaries are computed from all records and ignore the limitation of the -compareby option, though the "detail" output does conform to the -compareby object limitation.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	VV_NAME      The name of a volume admitted to a Remote Copy volume group with admitrcopyvv
	DOM_NAME     The domain name for a Remote Copy group when group was created with creatercopygroup
	TARGET_NAME  The target name of the Remote Copy target created with creatercopytarget
	TARGET_MODE  The target mode - Per: Periodic, Sync: Synchronous or Async: Asynchronous
	GROUP_NAME   The name of the Remote Copy group created with creatercopygroup
	GROUP_ROLE   The role (primary=1 or secondary=0) of the Remote Copy group
	PORT_TYPE    The port type (IP or FC) of the Remote Copy link(s) created with creatercopytarget
	PORT_N       The node number for the port used by a Remote Copy link
	PORT_S       The PCI slot number for the port used by a Remote Copy link
	PORT_P       The port number for the port used by a Remote Copy link
	VVSET_NAME   The virtual volume set name
.PARAMETER Compareby
	The compareby option limits output records to only certain objects, compared by a specified field.  Either the top or bottom X objects
	can be displayed, up to 32 objects for vstime reports or 128 objects for attime reports.  The field used for comparison can be any of the
	groupby fields or one of the following:
	lcl_read_iops, lcl_write_iops, lcl_total_iops, lcl_read_kbps, lcl_write_kbps, lcl_total_kbps, lcl_read_svctms, lcl_write_svctms, lcl_total_svctms, lcl_read_ioszkb, lcl_write_ioszkb,
	lcl_total_ioszkb, lcl_busy_pct, lcl_total_qlen, rmt_read_iops, rmt_write_iops, rmt_total_iops, rmt_read_kbps, rmt_write_kbps, rmt_total_kbps, rmt_read_ioszkb, rmt_write_ioszkb,
	rmt_total_ioszkb, rmt_busy_pct, rmt_total_qlen, rpo_timeInt
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must 
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc
			Sort in increasing order (default).
		dec
			Sort in decreasing order.	
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.PARAMETER Vv
	Limit the data to VVs with names that match one or more of the specified names or glob-style patterns. VV set name must be prefixed by "set:" and can also include patterns.
.PARAMETER Target
	Limit the data to TARGET_NAMEs that match one or more of the specified TARGET_NAMEs or glob-style patterns.
.PARAMETER Mode
	Limit the data to TARGET_MODEs of the specified mode. Allowed modes are:
		Per      - Periodic
		Sync     - Synchronous
		Async    - Asynchronous
.PARAMETER Group
	Limit the data to GROUP_NAMEs that match one or more of the specified GROUP_NAMEs or glob-style patterns.
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
	[Parameter()]	[String]	$Sortcol,
	[Parameter()]	[String]	$Vv,
	[Parameter()]	[String]	$Target,
	[Parameter()]	[String]	$Mode,
	[Parameter()]	[String]	$Group
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process 
	{	$Cmd = " srstatrcvv "
		if ($Attime) 	{	$Cmd += " -attime "			}
		if ($Btsecs) 	{	$Cmd += " -btsecs $Btsecs "	}
		if ($Etsecs) 	{	$Cmd += " -etsecs $Etsecs "	}
		if ($Hires) 	{	$Cmd += " -hires " 			}
		if ($Hourly) 	{	$Cmd += " -hourly "			}
		if ($Daily) 	{	$Cmd += " -daily "			}
		if ($Summary) 	{	$Cmd += " -summary $Summary "}
		if ($Groupby) 	{	$Cmd += " -groupby $Groupby "}
		if ($Compareby) {	$Cmd += " -compareby $Compareby "}
		if ($Sortcol) 	{	$Cmd += " -sortcol $Sortcol "}
		if ($Vv) 		{	$Cmd += " -vv $Vv "			}
		if ($Target) 	{	$Cmd += " -target $Target "	}
		if ($Mode) 		{	$Cmd += " -mode $Mode "		}
		if ($Group) 	{	$Cmd += " -group $Group "	}
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Get-A9SystemReporterStatVLun
{
<#
.SYNOPSIS
    Command displays historical performance data reports for VLUNs.
.DESCRIPTION
    Command displays historical performance data reports for VLUNs.
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	DOM_NAME        Domain name
	VV_NAME         Virtual Volume name
	HOST_NAME       Host name
	LUN             The LUN number for the VLUN
	HOST_WWN        The host WWN for the VLUN
	PORT_N          The node number for the VLUN  port
	PORT_S          The PCI slot number for the VLUN port
	PORT_P          The port number for the VLUN port
	VVSET_NAME      Virtual volume set name
	HOSTSET_NAME    Host set name
	VM_NAME         Virtual Machine Name for VVol based VMs
	VM_ID           Virtual Machine Identification number for VVol based VMs
	VM_HOST         Virtual Machine host for VVol based VMs
	VVOLSC          Virtual Volume Storage Container for VVol based VMs
.PARAMETER hostE
	Limit the data to hosts with names that match one or more of the specified names or glob-style patterns. Host set name must start with
.PARAMETER vv
	Limit the data to VVs with names that match one or more of thespecified names or glob-style patterns. VV set name must be prefixed by "set:" and can also include patterns.
.PARAMETER lun
	Limit the data to LUNs that match one or more of the specified LUNs or glob-style patterns.
.PARAMETER Port  
	Ports with <port_n>:<port_s>:<port_p> that match any of the specified <npat>:<spat>:<ppat> patterns are included, where each of the patterns is a glob-style pattern. If not specified, all ports are included.	
.PARAMETER vLun
	Limit the data to VLUNs matching the specified combination of host, VV, lun, and port. Each of these components in this option may be a
	glob-style pattern. The host and VV components may specify a corresponding object set by prefixing "set:" to the component. The
	host component may specify a WWN by prefixing the component with "wwn:". The lun and port components are optional, and if not present,
	data will be filtered to any matching combination of host and VV. This option cannot be combined with -host, -vv, -l, or -port.
.PARAMETER vmName 
	Limit the data to VMs that match one or more of the specified VM names or glob-styled patterns for VVol based VMs.
.PARAMETER vmId 
	Limit the data to VMs that match one or more of the specified VM IDs or glob-styled patterns for VVol based VMs.
.PARAMETER vmHost
	Limit the data to VMs that match one or more of the specified VM host names or glob-styled patterns for VVol based VMs.
.PARAMETER vvoLsc
	Limit the data to VVol containers that match one or more of the specified VVol container names or glob-styled patterns.
.PARAMETER Summary 
	Summarize performance across requested objects and time range.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SRStatVLun

	Command displays historical performance data reports for VLUNs.
.EXAMPLE
    PS:> Get-A9SRStatVLun -Hourly -btsecs -24h

	Example displays aggregate hourly performance statistics for all VLUNs beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SRStatVLun -btsecs -2h -host "set:hostset" -vv "set:vvset*"
	
	VV or host sets can be specified with patterns:
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]		[switch]	$attime,
		[Parameter()]		[String]	$Summary,
		[Parameter()]		[String]	$btsecs,
		[Parameter()]		[String]	$etsecs,
		[Parameter()]		[switch]    $Hourly ,		
		[Parameter()]		[switch]    $Daily ,		
		[Parameter()]		[switch]  	$Hires ,
		[Parameter()][ValidateSet("DOM_NAME","VV_NAME","HOST_NAME","LUN","HOST_WWN","PORT_N","PORT_S","PORT_P","VVSET_NAME","HOSTSET_NAME")]
							[String]	$groupby,
		[Parameter()]		[String]	$hostE,
		[Parameter()]		[String]	$vv,
		[Parameter()]		[String]	$lun,
		[Parameter()]		[String]	$port,
		[Parameter()]		[String]	$vLun,
		[Parameter()]		[String]	$vmName,
		[Parameter()]		[String]	$vmHost,
		[Parameter()]		[String]	$vvoLsc,
		[Parameter()]		[String]	$vmId ,
		[Parameter()]		[switch]	$ShowRaw     
	)
Begin
	{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
	}
Process
	{	$tempFile = [IO.Path]::GetTempFileName()	
		$srinfocmd = "srstatvlun "
		if($Summary)	{	$srinfocmd += " -summary $Summary"	}
		if($btsecs)		{	$srinfocmd += " -btsecs $btsecs"	}
		if($etsecs)		{	$srinfocmd += " -etsecs $etsecs"	}				
		if($Hourly)		{	$srinfocmd += " -hourly"			}
		if($Daily)		{	$srinfocmd += " -daily"				}
		if($Hires)		{	$srinfocmd += " -hires"				}
		if($groupby)	{	$srinfocmd += " -groupby $groupby"	}
		if($hostE)		{	$srinfocmd += " -host $hostE"		}
		if($vv)			{	$srinfocmd += " -vv $vv "			}
		if($lun)		{	$srinfocmd += " -l $lun "			}
		if($port)		{	$srinfocmd += " -port $port "		}
		if($vLun)		{	$srinfocmd += " -vlun $vLun "		}	
		if($vmName)		{	$srinfocmd += " -vmname $vmName "	}
		if($vmId)		{	$srinfocmd += " -vmid $vmId "		}		
		if($vmHost)		{	$srinfocmd += " -vmhost $vmHost "	}
		if($vvoLsc)		{	$srinfocmd += " -vvolsc $vvoLsc "	}
		if($attime)
			{	$srinfocmd += " -attime "
				write-verbose "System reporter command => $srinfocmd"
				if($groupby)	{	$optionname = $groupby.toUpper()	}
				else			{	$optionname = "HOST_NAME"			}
				Add-Content -Path $tempFile -Value "Host_Name,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
				$rangestart = "4"
			}
		elseif($groupby)
			{	$optionname = $groupby.toUpper()
				$rangestart = "2"	
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,$optionname,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
			}
		elseif($Summary)
			{	$rangestart = "4"	
				Add-Content -Path $tempFile -Value "Summary,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
			}
		else{	$rangestart = "3"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,IO/s_Rd,IO/s_Wr,IO/s_Tot,KBytes/s_Rd,KBytes/s_Wr,KBytes/s_Tot,Svct/ms_Rd,Svct/ms_Wr,Svct/ms_Tot,IOSz/KBytes_Rd,IOSz/KBytes_Wr,IOSz/KBytes_Tot,QLen,AvgBusy%"
			}
		write-verbose "System reporter command => $srinfocmd"
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
		$rangeend  = $Result.count -3	
		if($Summary)	{ $rangeend = 4 }
		if($rangeend -le "2")
			{ 	Remove-Item  $tempFile 
			}	
		elseif($Result.count -gt 4 -and (-not $ShowRaw))
			{	foreach ($s in  $Result[$rangestart..$rangeend] )
					{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
						Add-Content -Path $tempFile -Value $s
					}
				$Result = Import-Csv $tempFile	
			}
		Remove-Item  $tempFile
		return $Result
	}
}

Function Get-A9SystemReporterVvSpace
{
<#
.SYNOPSIS
    Command displays historical space data reports for virtual volumes (VVs).
.DESCRIPTION
    Command displays historical space data reports for virtual volumes (VVs).
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object 	
	group described by the -groupby option. Without this option, performance is shown versus time with a row per time interval.
.PARAMETER btsecs
    Select the begin time in seconds for the report.The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> canbe specified with a suffix of m, h or d to 
	represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d). If it is not specified then the time at which the report begins depends on the sample category (-hires, -hourly, -daily):        
		- For hires, the default begin time is 12 hours ago (-btsecs -12h).
		- For hourly, the default begin time is 7 days ago (-btsecs -7d).
		- For daily, the default begin time is 90 days ago (-btsecs -90d).
	If begin time and sample category are not specified then the time the report begins is 12 hours ago and the default sample category is hires. If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs
    Select the end time in seconds for the report.  If -attime is   specified, select the time for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report. This is the default setting.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily   
	Select daily samples for the report.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
	DOM_NAME        Domain name
	VVID            Virtual volume ID
	VV_NAME         Virtual volume name
	BSID            Virtual volume ID of the base virtual volume
	WWN             Virtual volume world wide name (WWN)
	SNP_CPG_NAME    Snap space Common Provisioning Group name
	USR_CPG_NAME    User space Common Provisioning Group name
	PROV_TYPE       The virtual volume provisioning type
	VV_TYPE         The type of the virtual volume
	VVSET_NAME      Virtual volume set name
	VM_NAME         Virtual Machine name for VVol based VMs
	VM_ID           Virtual Machine Identification number for VVol based VMs
	VM_HOST         Virtual Machine host for VVol based VMs
	VVOLSC          Virtual Volume Storage Container for VVol based VMs
	VVOL_STATE      Virtual Volume state, either bound or unbound
	COMPR           Whether Compression is enabled, disabled, or NA
.PARAMETER usrcpg 
	Only include VVs whose usr space is mapped to a CPG whose name matches one of the specified CPG_name or glob-style patterns.
.PARAMETER snpcpg
	Only include VVs whose snp space is mapped to a CPG whose name matches one of the specified CPG_name or glob-style patterns.
.PARAMETER provType
	Only include VVs of the specified provisioning type(s). The possible values are: cpvv dds full peer snp tdvv tpsd tpvv
.PARAMETER VVName
	PDs with IDs that match either the specified PDID or glob-style  pattern are included. This specifier can be repeated to include multiple PDIDs or patterns. If not specified, all PDs are included.
.PARAMETER vmName 
	Limit the data to VMs that match one or more of the specified VM names or glob-styled patterns for VVol based VMs.
.PARAMETER vmId 
	Limit the data to VMs that match one or more of the specified VM IDs or glob-styled patterns for VVol based VMs.
.PARAMETER vmHost 
	Limit the data to VMs that match one or more of the specified VM host names or glob-styled patterns for VVol based VMs.
.PARAMETER vvolState
	Limit the data to VVOLs that have states in either the Bound or Unbound state.
.PARAMETER vvoLsc
	Limit the data to VVol containers that match one or more of the specified VVol container names or glob-styled patterns.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SRVvSpace

	Command displays historical space data reports for virtual volumes (VVs).
.EXAMPLE
    PS:> Get-A9SRVvSpace  -Hourly -btsecs -24h -VVName dbvv*
	
	example displays aggregate hourly VV space information for VVs with names matching either "dbvv*"  patterns beginning 24 hours ago:
.EXAMPLE
    PS:> Get-A9SRVvSpace -Daily -attime -groupby vv_name -vvName tp*

	Example displays VV space information for the most recent daily sample aggregated by the VV name for VVs with names that match the pattern "tp*".
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$attime,
		[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]	$Hourly ,		
		[Parameter()]	[switch]    $Daily ,		
		[Parameter()]	[switch]	$Hires ,
		[Parameter()]	[ValidateSet("DOM_NAME","VVID","VV_NAME","BSID","WWN","SNP_CPG_NAME","USR_CPG_NAME","PROV_TYPE","VV_TYPE","VVSET_NAME")]
						[String]	$groupby,
		[Parameter()]	[String]	$usrcpg,		
		[Parameter()]	[String]	$snpcpg,
		[Parameter()]	[ValidateSet("cpvv","dds","full","peer","snp","tdvv","tpsd","tpvv")]
						[String]	$provType,
		[Parameter()]	[String]	$VVName,
		[Parameter()]	[String]	$vmName,
		[Parameter()]	[String]	$vmHost,
		[Parameter()]	[String]	$vvoLsc,
		[Parameter()]	[String]	$vmId,
		[Parameter()]	[String]	$vvolState,
		[Parameter()]	[switch]	$ShowRaw
	)
Begin
	{	Test-A9Connection -ClientType 'SshClient' -MinimumVersion '3.1.2'
	}
Process
	{	$srinfocmd = "srvvspace"
		$tempFile = [IO.Path]::GetTempFileName()
		if($btsecs)	{	$srinfocmd += " -btsecs $btsecs"	}
		if($etsecs)	{	$srinfocmd += " -etsecs $etsecs"	}
		if($Hourly)	{	$srinfocmd += " -hourly"			}
		if($Daily)	{	$srinfocmd += " -daily"				}
		if($Hires)	{	$srinfocmd += " -hires"				}
		if($groupby){	$srinfocmd += " -groupby $groupby"	}		
		if($usrcpg)	{	$srinfocmd += " -usr_cpg $usrcpg "	}
		if($snpcpg)	{	$srinfocmd += " -snp_cpg $snpcpg "	}
		if($provType){	$srinfocmd += " -prov $provType"	}				
		if($VVName)	{	$srinfocmd += " $VVName "	}		
		if($vmName)	{	$srinfocmd += " -vmname $vmName "	}
		if($vmId)	{	$srinfocmd += " -vmid $vmId "	}		
		if($vmHost)	{	$srinfocmd += " -vmhost $vmHost "	}
		if($vvoLsc)	{	$srinfocmd += " -vvolsc $vvoLsc "	}
		if($vvolState){	$srinfocmd += " -vvolstate $vvolState "	}
		if($attime)
			{	$srinfocmd += " -attime "	
				write-verbose "System reporter command => $srinfocmd"
				if($groupby)	{	$optionname = $groupby.toUpper()	}
				else			{	$optionname = "VV_NAME"				}
				$rangestart = "3"
				Add-Content -Path $tempFile -Value "$optionname,RawRsvd(MB)_User,RawRsvd(MB)_Snap,RawRsvd(MB)_Total,User(MB)_Used,User(MB)_Free,User(MB)_Rsvd,Snap(MB)_Used,Snap(MB)_Free,Snap(MB)_Rsvd,Snap(MB)_Vcopy,Total(MB)_Vcopy,Total(MB)_Used,Total(MB)_Rsvd,Total(MB)_HostWr,Total(MB)_VirtualSize,KB/s)_Compr_GC,Efficiency_Compact,Efficiency_Compress"
			}
		elseif($groupby)
			{	$optionname = $groupby.toUpper()
				$rangestart = "2"			
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,$optionname,RawRsvd(MB)_User,RawRsvd(MB)_Snap,RawRsvd(MB)_Total,User(MB)_Used,User(MB)_Free,User(MB)_Rsvd,Snap(MB)_Used,Snap(MB)_Free,Snap(MB)_Rsvd,Snap(MB)_Vcopy,Total(MB)_Vcopy,Total(MB)_Used,Total(MB)_Rsvd,Total(MB)_HostWr,Total(MB)_VirtualSize,KB/s)_Compr_GC,Efficiency_Compact,Efficiency_Compress"
			}
		else
			{	$rangestart = "2"
				Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,RawRsvd(MB)_User,RawRsvd(MB)_Snap,RawRsvd(MB)_Total,User(MB)_Used,User(MB)_Free,User(MB)_Rsvd,Snap(MB)_Used,Snap(MB)_Free,Snap(MB)_Rsvd,Snap(MB)_Vcopy,Total(MB)_Vcopy,Total(MB)_Used,Total(MB)_Rsvd,Total(MB)_HostWr,Total(MB)_VirtualSize,(KB/s)_Compr_GC,Efficiency_Compact,Efficiency_Compress"
			}
		write-verbose "System reporter command => $srinfocmd"
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
}
End
{	if ( (-not $ShowRaw) -and (-not ($Result.count) -le "3"))
		{	foreach ($s in  $Result[$rangestart..($Result.count)] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempFile -Value $s
				}
			$result = Import-Csv $tempFile
		}
	Remove-Item  $tempFile
	return $result
}
}

Function Show-A9SystemReporterStatIscsi
{
<#
.SYNOPSIS   
	The command displays historical performance data reports for iSCSI ports.
.DESCRIPTION  
	The command displays historical performance data reports for iSCSI ports.
.PARAMETER Attime
    Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object group described by the
	-groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER BTsecs
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
.PARAMETER ETsecs
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
    Summarize performance across requested objects and time range. The possible summary types are: "min" (minimum), "avg" (average), "max" (maximum), and "detail"
    The "detail" type causes the individual performance records to be presented along with the summary type(s) requested. One or more of these summary types may be specified.
.PARAMETER Groupby
    For -attime reports, generate a separate row for each combination of <groupby> items.  Each <groupby> must be different and one of the following:
        PORT_N      The node number for the port
        PORT_S      The PCI slot number for the port
        PORT_P      The port number for the port
        PROTOCOL    The protocol type for the port
.PARAMETER NSP
	Dode Sloat Port Value 1:2:3
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE	
	PS:> Show-A9SrStatIscsi
.EXAMPLE
	PS:> Show-A9SrStatIscsi -Attime
.EXAMPLE
	PS:> Show-A9SrStatIscsi -Summary min/max/aug/detail
.EXAMPLE
	PS:> Show-A9SrStatIscsi -BTSecs 1
.EXAMPLE
	PS:> Show-A9SrStatIscsi -ETSecs 1
.EXAMPLE
	PS:> Show-A9SrStatIscsi -Groupby PORT_N
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Attime, 
		[Parameter()]	[switch]	$Hires,
		[Parameter()]	[switch]	$Hourly,
		[Parameter()]	[switch]	$Daily,
		[Parameter()]	[ValidateSet( "min","avg","max","detail")]
						[String]	$Summary ,
		[Parameter()]	[String]	$BTSecs ,
		[Parameter()]	[String]	$ETSecs ,
		[Parameter()]	[ValidateSet("PORT_N","PORT_S","PORT_P","PROTOCOL")]
						[String]	$Groupby ,
		[Parameter()]	[String]	$NSP,
		[Parameter()]	[switch]	$ShowRaw
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd= "srstatiscsi "
	if ($Attime)	{	$cmd+=" -attime "	}
	if ($Summary)	{	$cmd+=" -summary $Summary "	}
	if ($BTSecs)	{	$cmd+=" -btsecs $BTSecs "}
	if ($ETSecs)	{	$cmd+=" -etsecs $ETSecs "	}
	if ($Hires)		{	$cmd+=" -hires "	}
	if ($Hourly)	{	$cmd+=" -hourly "	}
	if ($Daily)		{	$cmd+=" -daily "	}		
	if($Groupby)	{	$cmd+=" -groupby $Groupby"}
	if ($NSP)		{	$cmd+=" $NSP "	}
	write-verbose "  Executing  Show-SrStatIscsi command that displays information iSNS table for iSCSI ports in the system  "	
	$Result = Invoke-A9CLICommand -cmds  $cmd
}
end
{	$Flag="True"
	if ( $ShowRaw ) { return $Result}
	if($Attime -or $Summary)
		{	$Flag="Fals"
			if($Result -match "Time")
				{	if($Result.Count -lt 5){	return "No data found please try with different values."	}
					$count=2
					if($Summary)	{	$count=3	}
					$tempFile = [IO.Path]::GetTempFileName()
					$LastItem = $Result.Count
					$incre = "true" 		
					foreach ($s in  $Result[$count..$LastItem] )
						{	$s= [regex]::Replace($s,"^ ","")						
							$s= [regex]::Replace($s," +",",")			
							$s= [regex]::Replace($s,"-","")			
							$s= $s.Trim()			
							if($incre -eq "true")
								{	$sTemp1=$s				
									$sTemp = $sTemp1.Split(',')							
									$sTemp[1]="Pkts/s(Receive)"				
									$sTemp[2]="KBytes/s(Receive)"
									$sTemp[3]="Pkts/s(Transmit)"				
									$sTemp[4]="Kytes/s(Transmit)"
									$sTemp[5]="Pkts/s(Total)"				
									$sTemp[6]="Kytes/s(Total)"
									$newTemp= [regex]::Replace($sTemp,"^ ","")			
									$newTemp= [regex]::Replace($sTemp," ",",")				
									$newTemp= $newTemp.Trim()
									$s=$newTemp							
								}
							if($incre -eq "false")	{	$s=$s.Substring(1)	}			
							Add-Content -Path $tempFile -Value $s	
							$incre="false"
						}			
					$returndata = Import-Csv $tempFile 
					Remove-Item  $tempFile
					return $returndata
				}
			else{	return $Result	}
		}	
	else{	if($Flag -eq "True")
				{	if($Result -match "Time")
						{	if($Result.Count -lt 4)	{	return "No data found please try with different values."	}
							$tempFile = [IO.Path]::GetTempFileName()
							$LastItem = $Result.Count
							$incre = "true" 		
							foreach ($s in  $Result[1..$LastItem] )
								{	$s= [regex]::Replace($s,"^ ","")						
									$s= [regex]::Replace($s," +",",")			
									$s= [regex]::Replace($s,"-","")			
									$s= $s.Trim() -replace 'Time','Date,Time,Zone' 						
									if($incre -eq "true")
										{	$s=$s.Substring(1)
											$sTemp1=$s				
											$sTemp = $sTemp1.Split(',')							
											$sTemp[4]="Pkts/s(Receive)"				
											$sTemp[5]="KBytes/s(Receive)"
											$sTemp[6]="Pkts/s(Transmit)"				
											$sTemp[7]="Kytes/s(Transmit)"
											$sTemp[8]="Pkts/s(Total)"				
											$sTemp[9]="Kytes/s(Total)"
											$newTemp= [regex]::Replace($sTemp,"^ ","")			
											$newTemp= [regex]::Replace($sTemp," ",",")				
											$newTemp= $newTemp.Trim()
											$s=$newTemp
										}				
									Add-Content -Path $tempFile -Value $s	
									$incre="false"
								}			
							$returndata = Import-Csv $tempFile 
							Remove-Item  $tempFile
							return $returndata
						}
					else{	return $Result	}
				}
		}	
	if($Result -match "Time")	{	return  " Success : Executing Show-SrStatIscsi"	}
	else{	return  $Result	}
}
}

Function Show-A9SystemReporterStatIscsiSession
{
<#
.SYNOPSIS   
	The command displays historical performance data reports for iSCSI sessions.
.DESCRIPTION  
	The command displays historical performance data reports for iSCSI sessions.
.PARAMETER Attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object group described by the
	-groupby option. Without this option performance is shown versus time, with a row per time interval.
.PARAMETER Btsecs
	Select the begin time in seconds for the report.
	The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
	- Full time string including time zone: "2012-10-26 11:00:00 PDT"
	- Full time string excluding time zone: "2012-10-26 11:00:00"
	- Date string: "2012-10-26" or 2012-10-26
	- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the
	current time. Instead of a number representing seconds, <secs> can
	be specified with a suffix of m, h or d to represent time in minutes
	(e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins depends
	on the sample category (-hires, -hourly, -daily):
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
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
	be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the report ends with the most recent sample.
.PARAMETER Hires
	Select high resolution samples (5 minute intervals) for the report.
	This is the default.
.PARAMETER Hourly
	Select hourly samples for the report.
.PARAMETER Daily
	Select daily samples for the report.
.PARAMETER Summary
	Summarize performance across requested objects and time range.
	The possible summary types are:
		"min" (minimum), "avg" (average), "max" (maximum), and "detail"
	The "detail" type causes the individual performance records to be
	presented along with the summary type(s) requested. One or more of these
	summary types may be specified.
.PARAMETER Groupby
	For -attime reports, generate a separate row for each combination of
	<groupby> items.  Each <groupby> must be different and
	one of the following:
	PORT_N      The node number for the session
	PORT_S      The PCI slot number for the session
	PORT_P      The port number for the session
	ISCSI_NAME  The iSCSI name for the session
	TPGT        The TPGT ID for the session
.PARAMETER NSP
	Node Sloat Poart Value 1:2:3
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE	
	Show-SrStatIscsiSession
.EXAMPLE
	PS:> Show-A9SrStatIscsiSession -Attime
.EXAMPLE
	PS:> Show-A9SrStatIscsiSession -Attime -NSP 0:2:1
.EXAMPLE
	PS:> Show-A9SrStatIscsiSession -Summary min -NSP 0:2:1
.EXAMPLE
	PS:> Show-A9SrStatIscsiSession -Btsecs 1 -NSP 0:2:1
.EXAMPLE
	PS:> Show-A9SrStatIscsiSession -Hourly -NSP 0:2:1
.EXAMPLE
	PS:> Show-A9SrStatIscsiSession -Daily
.EXAMPLE
	PS:> Show-A9SrStatIscsiSession -Groupby PORT_N
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Attime, 
		[Parameter()]	[switch]	$Hires,
		[Parameter()]	[switch]	$Hourly,
		[Parameter()]	[switch]	$Daily,
		[Parameter()][ValidateSet("min","avg","max","detail")]	
						[String]	$Summary ,
		[Parameter()]	[String]	$BTSecs ,
		[Parameter()]	[String]	$ETSecs ,
		[Parameter()][ValidateSet("PORT_N","PORT_S","PORT_P","ISCSI_NAME","TPGT")]	
						[String]	$Groupby ,
		[Parameter()]	[String]	$NSP,
		[Parameter()]	[switch]	$ShowRaw
	)	
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process
	{	$cmd= "srstatiscsisession "	
		if ($Attime)	{	$cmd+=" -attime "	}
		if ($Summary)	{	$cmd+=" -summary $Summary "	}
		if ($BTSecs)	{	$cmd+=" -btsecs $BTSecs "	}
		if ($ETSecs)	{	$cmd+=" -etsecs $ETSecs "	}
		if ($Hires)		{	$cmd+=" -hires "	}
		if ($Hourly)	{	$cmd+=" -hourly "	}
		if ($Daily)		{	$cmd+=" -daily "	}	
		if ($Groupby)	{	$cmd+=" -groupby $Groupby"	}
		if ($NSP)	{	$cmd+=" $NSP "	}
		write-verbose "  Executing  Show-SrStatIscsiSession command that displays information iSNS table for iSCSI ports in the system  "
		$Result = Invoke-A9CLICommand -cmds  $cmd
	}
End
	{	if ($ShowRaw) { return $Results}
		if($Attime)
			{	if($Result -match "Time")
					{	if($Result.Count -lt 5)	{	return "No data found please try with different values."	}
						$tempFile = [IO.Path]::GetTempFileName()
						$LastItem = $Result.Count
						$incre = "true" 		
						foreach ($s in  $Result[2..$LastItem] )
							{	$s= [regex]::Replace($s,"^ ","")						
								$s= [regex]::Replace($s," +",",")			
								$s= [regex]::Replace($s,"-","")			
								$s= $s.Trim()			
								if($incre -eq "true")
									{	$sTemp1=$s				
										$sTemp = $sTemp1.Split(',')					
										$sTemp[3]="Total(PDUs/s)"				
										$sTemp[6]="Total(KBytes/s)"
										$newTemp= [regex]::Replace($sTemp,"^ ","")			
										$newTemp= [regex]::Replace($sTemp," ",",")				
										$newTemp= $newTemp.Trim()
										$s=$newTemp							
									}
								if($incre -eq "false")	{	$s=$s.Substring(1)	}			
								Add-Content -Path $tempFile -Value $s	
								$incre="false"
							}			
						Import-Csv $tempFile 
						Remove-Item  $tempFile
					}
				else{	return $Result	}
			}
		elseif($Summary)
			{	if($Result -match "Time")
					{	if($Result.Count -lt 5)	{	return "No data found please try with different values."	}
						$tempFile = [IO.Path]::GetTempFileName()
						$LastItem = $Result.Count
						$incre = "true" 		
						foreach ($s in  $Result[3..$LastItem] )
							{	$s= [regex]::Replace($s,"^ ","")						
								$s= [regex]::Replace($s," +",",")			
								$s= [regex]::Replace($s,"-","")			
								$s= $s.Trim()			
								if($incre -eq "true")
									{	$sTemp1=$s				
										$sTemp = $sTemp1.Split(',')					
										$sTemp[3]="Total(PDUs/s)"				
										$sTemp[6]="Total(KBytes/s)"
										$newTemp= [regex]::Replace($sTemp,"^ ","")			
										$newTemp= [regex]::Replace($sTemp," ",",")				
										$newTemp= $newTemp.Trim()
										$s=$newTemp							
									}
								if($incre -eq "false")	{	$s=$s.Substring(1)	}			
								Add-Content -Path $tempFile -Value $s	
								$incre="false"
							}			
						Import-Csv $tempFile 
						Remove-Item  $tempFile
					}
				else{	return $Result	}
			}
		elseif($Groupby)
			{	if($Result -match "Time")
					{	if($Result.Count -lt 5)	{	return "No data found please try with different values."	}
						$tempFile = [IO.Path]::GetTempFileName()
						$LastItem = $Result.Count
						$incre = "true" 		
						foreach ($s in  $Result[1..$LastItem] )
							{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','		
								$s= $s.Trim() -replace 'Time','Date,Time,Zone'				
								if($incre -eq "true")
									{	$sTemp1=$s.Substring(1)					
										$sTemp2=$sTemp1.Substring(0,$sTemp1.Length - 17)
										$sTemp2 +="TimeOut"					
										$sTemp = $sTemp2.Split(',')					
										$sTemp[7]="Total(PDUs/s)"				
										$sTemp[10]="Total(KBytes/s)"
										$newTemp= [regex]::Replace($sTemp,"^ ","")			
										$newTemp= [regex]::Replace($sTemp," ",",")				
										$newTemp= $newTemp.Trim()
										$s=$newTemp							
									}							
								Add-Content -Path $tempFile -Value $s	
								$incre="false"
							}			
						Import-Csv $tempFile 
						Remove-Item  $tempFile
					}
				else{	return $Result	}
			}
		else{	if($Result -match "Time")
				{	if($Result.Count -lt 5)	{	return "No data found please try with different values."	}
					$tempFile = [IO.Path]::GetTempFileName()
					$LastItem = $Result.Count
					$incre = "true" 		
					foreach ($s in  $Result[1..$LastItem] )
						{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','		
							$s= $s.Trim()					
							if($incre -eq "true")
								{	$s=$s.Substring(1)								
									$sTemp1=$s				
									$sTemp = $sTemp1.Split(',')							
									$sTemp[4]="Total(PDUs/s)"				
									$sTemp[7]="Total(KBytes/s)"
									$newTemp= [regex]::Replace($sTemp,"^ ","")			
									$newTemp= [regex]::Replace($sTemp," ",",")				
									$newTemp= $newTemp.Trim()
									$s=$newTemp							
								}
							if($incre -eq "false")
								{	$sTemp1=$s
									$sTemp = $sTemp1.Split(',')	
									$sTemp2=$sTemp[0]+"-"+$sTemp[1]+"-"+$sTemp[2]
									$sTemp[0]=$sTemp2				
									$sTemp[1]=$sTemp[3]
									$sTemp[2]=$sTemp[4]
									$sTemp[3]=$sTemp[5]
									$sTemp[4]=$sTemp[6]
									$sTemp[5]=$sTemp[7]
									$sTemp[6]=$sTemp[8]
									$sTemp[7]=$sTemp[9]
									$sTemp[8]=$sTemp[10]
									$sTemp[9]=$sTemp[11]
									$sTemp[10]=""
									$sTemp[11]=""				
									$newTemp= [regex]::Replace($sTemp," ",",")	
									$newTemp= $newTemp.Trim()
									$s=$newTemp				
								}
							Add-Content -Path $tempFile -Value $s	
							$incre="false"
						}			
					Import-Csv $tempFile 
					Remove-Item  $tempFile
				}
				else{	return $Result}
			}	
		if($Result -match "Time"){	return  " Success : Executing Show-SrStatIscsiSession"	}
		else	{	return  $Result	}
	}
}


# SIG # Begin signature block
# MIIt4wYJKoZIhvcNAQcCoIIt1DCCLdACAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAwV699K+Rf
# xNffmu11CtjugITPzLvmjJrAjNtkFnjKH2YwIdN8b6TW4mI1xYp2fa2zPD0NKM1G
# vK1HlzmQqulnoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG6AwghucAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQEQ3E3myQ72mwVmnLW47vAwGqTQKGZ2wLkDifm+5vvfjii/sJDuHwH+c
# YLDg+C1BUyqYVZjvfaqaognTHFXzKmQwDQYJKoZIhvcNAQEBBQAEggGATZW4E7bv
# kHLlTnTYmiA3ay+yWvAvfSIfQ1O2Fynf1K0BAh5rkw4UkLOWHMxKJXhWLiY0l+PT
# Up2vm3JPFQoCAwKF2GHeYUlODsQlsrrfGXNaAOLrULWuJeiluKQvS+pDrIZEf04p
# 1pEB3OktP1RvjjQI4ofQU1F8qUEIVDKIaGR0B+MIKlhFm9tQ7nTNkPv/UzY+gjBX
# l+98IBFAsgd6sHkq5HBNxKZwjnDOoSFdtTzzrNnx+Du7s45ypPrB+hLzV7nOIaMP
# JM3RLaUBjy4+ZpeiBEzJTCI8X07Aj3Sce+58GQfMdiMxgU5BSegImL8XRf9H/L4W
# s3T8yI3i6znqOdtCKNtMdmyYRJj+clvCrEt7wZCzUXYyRM1C0tNWr0OUfa0IPcc7
# bJEOAcxGF4jk5slTkyVMiYNlKh0necAd+wdcjiPBsD9KJhZCGbyCi2Qh8bheHMqv
# OgvWjWKT+4EvoJvbghUiLqZo07zmO+Ruaq9mMUpYiBjNeJWjW/V8FETSoYIY6TCC
# GOUGCisGAQQBgjcDAwExghjVMIIY0QYJKoZIhvcNAQcCoIIYwjCCGL4CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQgGCyqGSIb3DQEJEAEEoIH4BIH1MIHyAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMK0WJ7WbxmlZqai7z+6qYYJDXDGTgJ/8
# FD6x+u04vdT9ziTRgFG1mOvOu6vDnSVFoQIVANJj/+6/MClbTu2vnTEwKCO//o/i
# GA8yMDI1MDUxNTAyMjQyMFqgdqR0MHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5X
# ZXN0IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQD
# EydTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzagghMEMIIG
# YjCCBMqgAwIBAgIRAKQpO24e3denNAiHrXpOtyQwDQYJKoZIhvcNAQEMBQAwVTEL
# MAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMj
# U2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjUwMzI3MDAw
# MDAwWhcNMzYwMzIxMjM1OTU5WjByMQswCQYDVQQGEwJHQjEXMBUGA1UECBMOV2Vz
# dCBZb3Jrc2hpcmUxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMn
# U2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM2MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA04SV9G6kU3jyPRBLeBIHPNyUgVNnYayf
# sGOyYEXrn3+SkDYTLs1crcw/ol2swE1TzB2aR/5JIjKNf75QBha2Ddj+4NEPKDxH
# Ed4dEn7RTWMcTIfm492TW22I8LfH+A7Ehz0/safc6BbsNBzjHTt7FngNfhfJoYOr
# kugSaT8F0IzUh6VUwoHdYDpiln9dh0n0m545d5A5tJD92iFAIbKHQWGbCQNYplqp
# AFasHBn77OqW37P9BhOASdmjp3IijYiFdcA0WQIe60vzvrk0HG+iVcwVZjz+t5Oc
# XGTcxqOAzk1frDNZ1aw8nFhGEvG0ktJQknnJZE3D40GofV7O8WzgaAnZmoUn4PCp
# vH36vD4XaAF2CjiPsJWiY/j2xLsJuqx3JtuI4akH0MmGzlBUylhXvdNVXcjAuIEc
# EQKtOBR9lU4wXQpISrbOT8ux+96GzBq8TdbhoFcmYaOBZKlwPP7pOp5Mzx/UMhyB
# A93PQhiCdPfIVOCINsUY4U23p4KJ3F1HqP3H6Slw3lHACnLilGETXRg5X/Fp8G8q
# lG5Y+M49ZEGUp2bneRLZoyHTyynHvFISpefhBCV0KdRZHPcuSL5OAGWnBjAlRtHv
# sMBrI3AAA0Tu1oGvPa/4yeeiAyu+9y3SLC98gDVbySnXnkujjhIh+oaatsk/oyf5
# R2vcxHahajMCAwEAAaOCAY4wggGKMB8GA1UdIwQYMBaAFF9Y7UwxeqJhQo1SgLqz
# YZcZojKbMB0GA1UdDgQWBBSIYYyhKjdkgShgoZsx0Iz9LALOTzAOBgNVHQ8BAf8E
# BAMCBsAwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBKBgNV
# HSAEQzBBMDUGDCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRwczovL3Nl
# Y3RpZ28uY29tL0NQUzAIBgZngQwBBAIwSgYDVR0fBEMwQTA/oD2gO4Y5aHR0cDov
# L2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYu
# Y3JsMHoGCCsGAQUFBwEBBG4wbDBFBggrBgEFBQcwAoY5aHR0cDovL2NydC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3J0MCMGCCsG
# AQUFBzABhhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOC
# AYEAAoE+pIZyUSH5ZakuPVKK4eWbzEsTRJOEjbIu6r7vmzXXLpJx4FyGmcqnFZoa
# 1dzx3JrUCrdG5b//LfAxOGy9Ph9JtrYChJaVHrusDh9NgYwiGDOhyyJ2zRy3+kdq
# hwtUlLCdNjFjakTSE+hkC9F5ty1uxOoQ2ZkfI5WM4WXA3ZHcNHB4V42zi7Jk3ktE
# nkSdViVxM6rduXW0jmmiu71ZpBFZDh7Kdens+PQXPgMqvzodgQJEkxaION5XRCoB
# xAwWwiMm2thPDuZTzWp/gUFzi7izCmEt4pE3Kf0MOt3ccgwn4Kl2FIcQaV55nkjv
# 1gODcHcD9+ZVjYZoyKTVWb4VqMQy/j8Q3aaYd/jOQ66Fhk3NWbg2tYl5jhQCuIsE
# 55Vg4N0DUbEWvXJxtxQQaVR5xzhEI+BjJKzh3TQ026JxHhr2fuJ0mV68AluFr9qs
# hgwS5SpN5FFtaSEnAwqZv3IS+mlG50rK7W3qXbWwi4hmpylUfygtYLEdLQukNEX1
# jiOKMIIGFDCCA/ygAwIBAgIQeiOu2lNplg+RyD5c9MfjPzANBgkqhkiG9w0BAQwF
# ADBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYD
# VQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MB4XDTIx
# MDMyMjAwMDAwMFoXDTM2MDMyMTIzNTk1OVowVTELMAkGA1UEBhMCR0IxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGlt
# ZSBTdGFtcGluZyBDQSBSMzYwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIB
# gQDNmNhDQatugivs9jN+JjTkiYzT7yISgFQ+7yavjA6Bg+OiIjPm/N/t3nC7wYUr
# UlY3mFyI32t2o6Ft3EtxJXCc5MmZQZ8AxCbh5c6WzeJDB9qkQVa46xiYEpc81KnB
# kAWgsaXnLURoYZzksHIzzCNxtIXnb9njZholGw9djnjkTdAA83abEOHQ4ujOGIaB
# hPXG2NdV8TNgFWZ9BojlAvflxNMCOwkCnzlH4oCw5+4v1nssWeN1y4+RlaOywwRM
# Ui54fr2vFsU5QPrgb6tSjvEUh1EC4M29YGy/SIYM8ZpHadmVjbi3Pl8hJiTWw9ji
# CKv31pcAaeijS9fc6R7DgyyLIGflmdQMwrNRxCulVq8ZpysiSYNi79tw5RHWZUEh
# nRfs/hsp/fwkXsynu1jcsUX+HuG8FLa2BNheUPtOcgw+vHJcJ8HnJCrcUWhdFczf
# 8O+pDiyGhVYX+bDDP3GhGS7TmKmGnbZ9N+MpEhWmbiAVPbgkqykSkzyYVr15OApZ
# YK8CAwEAAaOCAVwwggFYMB8GA1UdIwQYMBaAFPZ3at0//QET/xahbIICL9AKPRQl
# MB0GA1UdDgQWBBRfWO1MMXqiYUKNUoC6s2GXGaIymzAOBgNVHQ8BAf8EBAMCAYYw
# EgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAE
# CjAIMAYGBFUdIAAwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nUm9vdFI0Ni5jcmwwfAYIKwYB
# BQUHAQEEcDBuMEcGCCsGAQUFBzAChjtodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LnA3YzAjBggrBgEFBQcwAYYX
# aHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBABLXeyCt
# DjVYDJ6BHSVY/UwtZ3Svx2ImIfZVVGnGoUaGdltoX4hDskBMZx5NY5L6SCcwDMZh
# HOmbyMhyOVJDwm1yrKYqGDHWzpwVkFJ+996jKKAXyIIaUf5JVKjccev3w16mNIUl
# NTkpJEor7edVJZiRJVCAmWAaHcw9zP0hY3gj+fWp8MbOocI9Zn78xvm9XKGBp6rE
# s9sEiq/pwzvg2/KjXE2yWUQIkms6+yslCRqNXPjEnBnxuUB1fm6bPAV+Tsr/Qrd+
# mOCJemo06ldon4pJFbQd0TQVIMLv5koklInHvyaf6vATJP4DfPtKzSBPkKlOtyaF
# TAjD2Nu+di5hErEVVaMqSVbfPzd6kNXOhYm23EWm6N2s2ZHCHVhlUgHaC4ACMRCg
# XjYfQEDtYEK54dUwPJXV7icz0rgCzs9VI29DwsjVZFpO4ZIVR33LwXyPDbYFkLqY
# mgHjR3tKVkhh9qKV2WCmBuC27pIOx6TYvyqiYbntinmpOqh/QPAnhDgexKG9GX/n
# 1PggkGi9HCapZp8fRwg8RftwS21Ln61euBG0yONM6noD2XQPrFwpm3GcuqJMf0o8
# LLrFkSLRQNwxPDDkWXhW+gZswbaiie5fd/W2ygcto78XCSPfFWveUOSZ5SqK95tB
# O8aTHmEa4lpJVD7HrTEn9jb1EGvxOb1cnn0CMIIGgjCCBGqgAwIBAgIQNsKwvXwb
# Ouejs902y8l1aDANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVU
# aGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2Vy
# dGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMjEwMzIyMDAwMDAwWhcNMzgwMTE4MjM1
# OTU5WjBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4w
# LAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAiJ3YuUVnnR3d6LkmgZpUVMB8
# SQWbzFoVD9mUEES0QUCBdxSZqdTkdizICFNeINCSJS+lV1ipnW5ihkQyC0cRLWXU
# JzodqpnMRs46npiJPHrfLBOifjfhpdXJ2aHHsPHggGsCi7uE0awqKggE/LkYw3sq
# aBia67h/3awoqNvGqiFRJ+OTWYmUCO2GAXsePHi+/JUNAax3kpqstbl3vcTdOGht
# KShvZIvjwulRH87rbukNyHGWX5tNK/WABKf+Gnoi4cmisS7oSimgHUI0Wn/4elNd
# 40BFdSZ1EwpuddZ+Wr7+Dfo0lcHflm/FDDrOJ3rWqauUP8hsokDoI7D/yUVI9DAE
# /WK3Jl3C4LKwIpn1mNzMyptRwsXKrop06m7NUNHdlTDEMovXAIDGAvYynPt5lutv
# 8lZeI5w3MOlCybAZDpK3Dy1MKo+6aEtE9vtiTMzz/o2dYfdP0KWZwZIXbYsTIlg1
# YIetCpi5s14qiXOpRsKqFKqav9R1R5vj3NgevsAsvxsAnI8Oa5s2oy25qhsoBIGo
# /zi6GpxFj+mOdh35Xn91y72J4RGOJEoqzEIbW3q0b2iPuWLA911cRxgY5SJYubvj
# ay3nSMbBPPFsyl6mY4/WYucmyS9lo3l7jk27MAe145GWxK4O3m3gEFEIkv7kRmef
# DR7Oe2T1HxAnICQvr9sCAwEAAaOCARYwggESMB8GA1UdIwQYMBaAFFN5v1qqK0rP
# VIDh2JvAnfKyA2bLMB0GA1UdDgQWBBT2d2rdP/0BE/8WoWyCAi/QCj0UJTAOBgNV
# HQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEFBQcD
# CDARBgNVHSAECjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2Ny
# bC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3Jp
# dHkuY3JsMDUGCCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3Au
# dXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEADr5lQe1oRLjlocXUEYfk
# tzsljOt+2sgXke3Y8UPEooU5y39rAARaAdAxUeiX1ktLJ3+lgxtoLQhn5cFb3GF2
# SSZRX8ptQ6IvuD3wz/LNHKpQ5nX8hjsDLRhsyeIiJsms9yAWnvdYOdEMq1W61KE9
# JlBkB20XBee6JaXx4UBErc+YuoSb1SxVf7nkNtUjPfcxuFtrQdRMRi/fInV/AobE
# 8Gw/8yBMQKKaHt5eia8ybT8Y/Ffa6HAJyz9gvEOcF1VWXG8OMeM7Vy7Bs6mSIkYe
# YtddU1ux1dQLbEGur18ut97wgGwDiGinCwKPyFO7ApcmVJOtlw9FVJxw/mL1TbyB
# ns4zOgkaXFnnfzg4qbSvnrwyj1NiurMp4pmAWjR+Pb/SIduPnmFzbSN/G8reZCL4
# fvGlvPFk4Uab/JVCSmj59+/mB2Gn6G/UYOy8k60mKcmaAZsEVkhOFuoj4we8CYya
# R9vd9PGZKSinaZIkvVjbH/3nlLb0a7SBIkiRzfPfS9T+JesylbHa1LtRV9U/7m0q
# 7Ma2CQ/t392ioOssXW7oKLdOmMBl14suVFBmbzrt5V5cQPnwtd3UOTpS9oCG+ZZh
# eiIvPgkDmA8FzPsnfXW5qHELB43ET7HHFHeRPRYrMBKjkb8/IN7Po0d0hQoF4TeM
# M+zYAJzoKQnVKOLg8pZVPT8xggSSMIIEjgIBATBqMFUxCzAJBgNVBAYTAkdCMRgw
# FgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3RpZ28gUHVibGlj
# IFRpbWUgU3RhbXBpbmcgQ0EgUjM2AhEApCk7bh7d16c0CIetek63JDANBglghkgB
# ZQMEAgIFAKCCAfkwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3
# DQEJBTEPFw0yNTA1MTUwMjI0MjBaMD8GCSqGSIb3DQEJBDEyBDC07GKeon6vBbDK
# T/QHSxDCGSQkXBumVxVfhxiozZzmkGqTz/JDzZMlZFvD2irbhVQwggF6BgsqhkiG
# 9w0BCRACDDGCAWkwggFlMIIBYTAWBBQ4yRSBEES03GY+k9R0S4FBhqm1sTCBhwQU
# xq5U5HiG8Xw9VRJIjGnDSnr5wt0wbzBbpFkwVzELMAkGA1UEBhMCR0IxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEuMCwGA1UEAxMlU2VjdGlnbyBQdWJsaWMgVGlt
# ZSBTdGFtcGluZyBSb290IFI0NgIQeiOu2lNplg+RyD5c9MfjPzCBvAQUhT1jLZOC
# gmF80JA1xJHeksFC2scwgaMwgY6kgYswgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhl
# IFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRp
# ZmljYXRpb24gQXV0aG9yaXR5AhA2wrC9fBs656Oz3TbLyXVoMA0GCSqGSIb3DQEB
# AQUABIICAL2K9mM3wbZgWmgXuUVZlpc1HeTKc8uUerA8WT9bv73hBGRuQQTNIk8M
# M+ltVtiLJcL6UbKJjeE0vWdVycaQ8SviS6vH1ohFSE/iw6SYDeHIzz7zXDpFQf6R
# ql/Z9i2JrctcdaVzomUTCWwFY7kH5rgQr+Oh22lLHIFAkPFU6JiB5jp9HPNUe26o
# U1ItukYMfOes5Yzl6llGmegzbdIv4VAKKzykKeVoTYOtx2hmRqxBQ0Jk3xBlzKZD
# DPykGAZ3CA69UukoJaytLh3DqfmRF6Zk6lvLxy0X1xBj6Ih9eD5dVcSiX5owTkhO
# oEE23M0aP4DJFqY48Y5UzDYRdu4w8QlhCYhlc4yVcOcNoR25bFotp21ag8TqaWNf
# zdtFp3l+9iSXbZVhqJJff6Owuv1SWdcxTB4wcynFDNNYOD7LAKMid2iCAQXQDAKr
# 1qX0PKX2NjOLHImnNMdWKDg4AWgn7iolE7BplIHoPlYy4XDR4pYOhPmZ/JPuuGL+
# 7TDBSWfT9miiJtX2pEOWtylr1sj6DVW9nQHu+dVAn1SNT5CMaIDo74gNye1sxtej
# mnKYsKbSMmQVVPp8PX4iF8WVdttZD7+tOOO7qs5HochT/FHztBRofPxL2LnWADI2
# vp+ikkwpBCIzVvkHfUnssqQhK3w9ZYhq2YhIap2iDwmCGMlxx1Oe
# SIG # End signature block
