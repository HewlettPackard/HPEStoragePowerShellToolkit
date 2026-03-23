## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9SystemReportDB
{
<#
.SYNOPSIS
    Displays the amount of space consumed by the various System Reporter databases on the System Reporter volume.
.DESCRIPTION
    Displays the amount of space consumed by the various System Reporter databases on the System Reporter volume.
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
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
		return  $Result	
	}
}

Function Set-A9SystemReport
{
<#
.SYNOPSIS
    Is used to start or Stop the System reporter.
.DESCRIPTION
    Is used to start or Stop the System reporter.
.EXAMPLE
    PS:> Set-A9SystemReporter -Start

	Starts System Reporter
.EXAMPLE
    PS:> Set-A9SystemReporter -Stop

	Stops System Reporter
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[parameter(Mandatory, parameterSetname='start')]	[switch]	$Start,
		[parameter(Mandatory, parameterSetname='stop')]		[switch]	$Stop
	)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	if ($Start)		{ 	$srinfocmd = "startsr -f "	}
		elseif ($Stop)	{	$srinfocmd = "stopsr -f "	}
		write-verbose "System reporter command => $srinfocmd"
		$Result = Invoke-A9CLICommand -cmds  $srinfocmd
		if(-not $Result)	
			{	write-host "Success: System Reporter" -ForegroundColor green
			}
		else{	return $Result	
			}		
	}
}
Function Get-A9SystemReportAlertCrit
{
<#
.SYNOPSIS
    Shows the criteria that System Reporter evaluates to determine if a performance alert should be generated.
.DESCRIPTION
    Shows the criteria that System Reporter evaluates to determine if a performance alert should be generated.       
.PARAMETER Frequency
	This command wil return all frequencies if unset, if set can be one of the following three settings;
	Daily = This criterion will be evaluated on a daily basis at midnight.
	Hourly = This criterion will be evaluated on an hourly basis.
	Hires = This criterion will be evaluated on a high resolution (5 minute) basis. This is the default.
.PARAMETER Severity
	If unset, it will return all severities, or if set can be filtered to only those with one of the following four severity levels.
	Major = This alert should require urgent action.
	Minor = This alert should require not immediate action.
	Info = This alert is informational only. This is the default.
	Critical = 	Displays only criteria that have critical severity.
.PARAMETER Status
	If unset, will return all values, but if set can only return those that match this filter of the two following options.
	Enabled = Displays only criteria that are enabled.
 	Disabled = Displays only criteria that are disabled.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9SystemReportAlertCrit 

	shows the criteria that System Reporter evaluates to determine if a performance alert should be generated.
.EXAMPLE
    PS:> Get-A9SystemReportAlertCrit -Frequency Daily -status Enabled

	Example displays all the criteria evaluated on an hourly basis which are also enabled.:
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter()][ValidateSet('Hourly','Daily','HiRes')]			[String]	$Frequency,
		[Parameter()][ValidateSet('Major','Minor','Info','Critical')]	[string]	$Severity,
		[Parameter()][ValidateSet('Enabled','Disabled')]				[switch]    $Status,
		[Parameter()]													[switch]    $ShowRaw
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$srinfocmd = 'showsralertcrit '
	if ( $Frequency -eq 'Hourly' )		{	$srinfocmd += ' -hourly '	}
	if ( $Frequency -eq 'Daily' )		{	$srinfocmd += ' -daily '	}
	if ( $Frequency -eq 'HiRes' )		{	$srinfocmd += ' -hires '	}
	if ( $Severity -eq 'Major' )		{	$srinfocmd += ' -major '	}
	if ( $Severity -eq 'Minor' )		{	$srinfocmd += ' -minor '	}
	if ( $Severity -eq 'Info' )			{	$srinfocmd += ' -info '		}
	if ( $Severity -eq 'Critical' )		{	$srinfocmd += ' -critical '	}
	if ( $Status -eq 'Enabled' )		{	$srinfocmd += ' -enabled '	}
	if ( $Status -eq 'Disabled' )		{	$srinfocmd += ' -disabled '	}
	write-verbose "Get alert criteria command => $srinfocmd"
	$Result = Invoke-A9CLICommand -cmds  $srinfocmd	
	if ($ShowRaw) { Return $Result }
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

Function Get-A9SystemReportHistogram
{
<#
.SYNOPSIS
    Displays historical histogram performance data reports for logical disks, Physical Disks, VLuns, or Ports
.DESCRIPTION
    Displays historical histogram performance data reports for logical disks.
.PARAMETER attime
	Performance is shown at a particular time interval, specified by the -etsecs option, with one row per object group described by the -groupby option. 
	Without this option, performance is shown versus time with a row per time interval.
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
.PARAMETER PhysicalDiskGroupby
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
	LDs matching either the specified LD_name or glob-style pattern are included. This specifier can be repeated to display information for multiple LDs. If not specified, all LDs are included.
.PARAMETER PortGroupby
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
.PARAMETER vLunGroupBy
	For -attime reports, Groupby must be different and one of the following:
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
.EXAMPLE
    PS:> Get-A9SystemReportHistogram -LogicalDiskHistogram -LDName tp-0-sd-0.108 | ft *

	Date       Time     TimeZone Secs       0.50(millisec) 1(millisec) 2(millisec) 4(millisec) 8(millisec) 16(millisec) 32(millisec) 64(millisec) 128(millisec) 256(millisec) 4k(bytes) 8k(bytes) 16k(bytes) 32k(bytes)
	----       ----     -------- ----       -------------- ----------- ----------- ----------- ----------- ------------ ------------ ------------ ------------- ------------- --------- --------- ---------- ----------
	2025-02-11 12:45:00 MST      1739303100 3588           5124        7506        4960        6738        3899         3907         1336         394           38            12        172       3          0
	2025-02-11 12:50:00 MST      1739303400 2676           643         595         373         499         79           24           0            2             0             31        501       12         0
	2025-02-11 12:55:00 MST      1739303700 1433           913         624         427         523         113          9            1            0             1             94        296       3          0
	2025-02-11 13:00:00 MST      1739304000 509            113         147         94          203         99           15           5            0             0             32        237       3          0
		...
.EXAMPLE
    PS(HPEStorageV4.2):> Get-A9SystemReportHistogram -PortHistogram -Port '0:3:2' -Frequency HiRes -showraw

									-----------------Time (millisec)----------------- ----------------Size (bytes)---------------- Overall
					Time       Secs  0.50 0.75    1 1.5    2   3    4   6   8  12  16    4k   8k  16k  32k 64k 128k 256k 512k   1m   Count
	2026-03-19 00:05:00 MDT 1773900300 48460  324  336 233 1182 407 2154 757 171   3   6 37634 3572 1587 5184 551  205  255  541 4504   54033
	2026-03-19 00:10:00 MDT 1773900600 48814  319  348 281 1205 424 2140 773 155   5   7 37363 3766 1510 5374 503  195  581  595 4584   54471
	2026-03-19 00:15:00 MDT 1773900900 49733  269  285 255 1269 438 2214 827 148   4   6 37869 4257 1611 5502 464  213  242  530 4760   55448
	2026-03-19 00:20:00 MDT 1773901200 49240  322  351 276 1292 463 2146 807 157  12  42 38211 3957 1581 5201 484  185  218  584 4687   55108
.EXAMPLE
	PS(HPEStorageV4.2):> Get-A9SystemReportHistogram -PhysicalDiskHistogram -Frequency HiRes -PDID 71

	Date           : 2026-03-19
	Time           : 00:35:00
	TimeZone       : MDT
	Secs           : 1773902100
	0.50(millisec) : 326447
	1(millisec)    : 70
	2(millisec)    : 40
	4(millisec)    : 16
	8(millisec)    : 11
	16(millisec)   : 0
	32(millisec)   : 0
	64(millisec)   : 0
	128(millisec)  : 12
	256(millisec)  : 0
	4k(bytes)      : 0
	8k(bytes)      : 210037
	16k(bytes)     : 19056
	32k(bytes)     : 69151
	64k(bytes)     : 4165
	128k(bytes)    : 1959
	256k(bytes)    : 2417
	512k(bytes)    : 19811
	1m(bytes)      : 0
.EXAMPLE 
	PS(HPEStorageV4.2):> Get-A9SystemReportHistogram -LogicalDiskHistogram -Frequency HiRes -attime -LDName 14 -cpgName SSD_r6

	LD_NAME        : LD_NAME
	0.50(millisec) : 0.50
	1(millisec)    : 0.75
	2(millisec)    : 1
	4(millisec)    : 1.5
	8(millisec)    : 2
	16(millisec)   : 3
	32(millisec)   : 4
	64(millisec)   : 6
	128(millisec)  : 8
	256(millisec)  : 12
	4k(bytes)      : 16
	8k(bytes)      : 4k
	16k(bytes)     : 8k
	32k(bytes)     : 16k
	64k(bytes)     : 32k
	128k(bytes)    : 64k
	256k(bytes)    : 128k
	512k(bytes)    : 256k
	1m(bytes)      : 512k
.EXAMPLE 
	PS(HPEStorageV4.2):> Get-A9SystemReportHistogram -vLunHistogram -Frequency HiRes -vv AzureLocalPool2 | ft *

	Date       Time     TimeZone Secs       0.50(millisec) 1(millisec) 2(millisec) 4(millisec) 8(millisec) 16(millisec) 32(millisec) 64(millisec) 128(millisec) 256(millisec)
	----       ----     -------- ----       -------------- ----------- ----------- ----------- ----------- ------------ ------------ ------------ ------------- ---------
	2026-03-18 23:55:00 MDT      1773899700 1172           2           1           0           0           0            0            0            4             1
	2026-03-19 00:00:00 MDT      1773900000 1093           2           1           1           0           0            0            0            0             1
	2026-03-19 00:05:00 MDT      1773900300 1166           1           1           0           0           0            0            0            0             0
#>
[CmdletBinding()]
param(	[Parameter()]									[switch]		$attime,
		[Parameter()]									[String]		$BeginTimeSecs,
		[Parameter()]									[String]		$EndTimeSecs,
		[Parameter()][ValidateSet('Hourly','Daily','HiRes')]	
														[sTRING]    	$Frequency,
		[Parameter()]									[switch]		$rw,
		[Parameter()][ValidateSet('both','time','size')][String]		$Metric,
		[Parameter(ParameterSetName='LogicalDisk')]
		[ValidateSet('DOM_NAME','LDID','LD_NAME','CPG_NAME','NODE')]		
														[String]		$LogicalDiskGroupBy,
		[Parameter(ParameterSetName='LogicalDisk')]		[String]		$cpgName,
		[Parameter(ParameterSetName='LogicalDisk')]		[String]		$node,
		[Parameter(ParameterSetName='LogicalDisk')]		[String]		$LDName,
		[Parameter(ParameterSetName='PhysicalDisk')]	
		[ValidateSet("PDID","PORT_N","PORT_S","PORT_P","DISK_TYPE","SPEED")]
														[String]		$PhysicalDiskGroupBy,
		[Parameter(ParameterSetName='PhysicalDisk')]	
		[ValidateSet("FC","NL","SSD")]					[String]		$diskType,
		[Parameter(ParameterSetName='PhysicalDisk')]
		[ValidateSet("7","10","15","100","150")]		[String]		$rpmSpeed,
		[Parameter(ParameterSetName='PhysicalDisk')]	[String]		$PDID,
		[Parameter(ParameterSetName='Port')]
		[ValidateSet('PORT_N','PORT_S','PORT_P','PORT_TYPE','GBITPS','TRANS_TYPE')]
														[String[]]		$PortGroupBy,
		[Parameter(ParameterSetName='Port')]
		[ValidateSet('disk','host','iscsi','free','fs','peer','rcip','rcfc')]
														[String[]]		$portType,
		[Parameter(ParameterSetName='vLun')]	
		[ValidateSet("DOM_NAME","VV_NAME","HOST_NAME","LUN","HOST_WWN","PORT_N","PORT_S","PORT_P","VVSET_NAME","HOSTSET_NAME")]
														[String]		$vLunGroupBy,
		[Parameter(ParameterSetName='vLun')]			[String]		$hostE,
		[Parameter(ParameterSetName='vLun')]			[String]		$vv,
		[Parameter(ParameterSetName='vLun')]			[String]		$lun,
		[Parameter(ParameterSetName='Port')]
		[Parameter(ParameterSetName='vLun')]			[String]		$Port,
		[Parameter()]									[Switch]		$ShowRaw,
		[Parameter(Mandatory, ParameterSetName='LogicalDisk')][switch]	$LogicalDiskHistogram,
		[Parameter(Mandatory, ParameterSetName='PhysicalDisk')][switch]	$PhysicalDiskHistogram,
		[Parameter(Mandatory, ParameterSetName='vLun')]	[switch]		$vLunHistogram,
		[Parameter(Mandatory, ParameterSetName='Port')]	[switch]		$PortHistogram
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	Switch($PSCmdlet.ParameterSetName)
		{	'LogicalDisk'
						{	$srinfocmd = "srhistld "
							if ( $BeginTimeSecs )			{	$srinfocmd += " -btsecs $BeginTimeSecs"	}
							if ( $EndTimeSecs )				{	$srinfocmd += " -etsecs $EndTimeSecs"	}
							if ( $rw )						{	$srinfocmd +=  " -rw "				}
							if ( $LogicalDiskGroupBy )		{	$srinfocmd += " -groupby $LogicalDiskGroupBy"	}		
							if ( $Frequency -eq 'Hourly' )	{	$srinfocmd += " -hourly"			}
							if ( $Frequency -eq '$Daily' )	{	$srinfocmd += " -daily"				}
							if ( $Frequency -eq 'Hires' )	{	$srinfocmd += " -hires"				}
							if ( $cpgName )					{	$srinfocmd +=  " -cpg $cpgName "	}
							if ( $node )					{	$srinfocmd +=  " -node $node "		}
							if ( $LDName )					{	$srinfocmd += " $LDName "			}
							if ( $Metric )					{	$srinfocmd += " -metric $Metric"	}
							if ( $attime )					{	$srinfocmd += " -attime "			}
							write-verbose "System reporter command => $srinfocmd"
							$Result = Invoke-A9CLICommand -cmds  $srinfocmd	
							if ( $ShowRaw )	{ return $Result }
							$tempFile = [IO.Path]::GetTempFileName()
							if ( $attime )
								{	if($LogicalDiskGroupBy)	{	$optionname = $LogicalDiskGroupBy.toUpper()	}
									else			{	$optionname = "LD_NAME"				}
									Add-Content -Path $tempFile -Value "$optionname,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
									$rangestart = "3"
								}
							elseif ( $Metric -eq "time" )
								{	$rangestart = "2"
									Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec)"
								}
							elseif ( $Metric -eq "size" )
								{	$rangestart = "2"
									Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
								}
							else{	$rangestart = "2"
									Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
								}
							if ( ($Result.count) -le "2" )
								{	Remove-Item  $tempFile
									Write-warning "No data available"
									return
								}
							foreach ( $s in  $Result[$rangestart..($Result.count-1)] )
								{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
									Add-Content -Path $tempFile -Value $s
								}

						}
			'PhysicalDisk'
						{	$srinfocmd = "srhistpd "
							if ( $BeginTimeSecs )			{	$srinfocmd += " -btsecs $BeginTimeSecs"	}
							if ( $EndTimeSecs )				{	$srinfocmd += " -etsecs $EndTimeSecs"	}
							if ( $rw )						{	$srinfocmd +=  " -rw "	}
							if ( $PhysicalDiskGroupBy )		{	$srinfocmd += " -groupby $PhysicalDiskGroupBy"	}		
							if ( $Frequency -eq 'Hourly' )	{	$srinfocmd += " -hourly"	}
							if ( $Frequency -eq 'Daily' )	{	$srinfocmd += " -daily"		}
							if ( $Frequency -eq 'Hires' )	{	$srinfocmd += " -hires"		}
							if ( $diskType )				{	$srinfocmd += " -disk_type $diskType "	}
							if ( $Metric )					{	$srinfocmd += " -metric $Metric"	}					
							if ( $rpmSpeed )				{	$srinfocmd +=  " -rpm $rpmSpeed "	}
							if ( $PDID )					{	$srinfocmd += " $PDID "	}
							$tempFile = [IO.Path]::GetTempFileName()
							if ( $attime )
								{	$srinfocmd += " -attime "
									write-verbose "System reporter command => $srinfocmd"
									if($PhysicalDiskGroupBy)	{	$optionname = $PhysicalDiskGroupBy.toUpper()	}
									else			{	$optionname = "PDID"				}
									Add-Content -Path $tempFile -Value "$optionname,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
									$rangestart = "3"
								}
							elseif( $Metric -eq "time" )
								{	$rangestart = "2"
									Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec)"
								}
							elseif( $Metric -eq "size" )
								{	$rangestart = "2"
									Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
								}
							else{	$rangestart = "2"
									Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
								}
							write-verbose "System reporter command => $srinfocmd"
							$Result = Invoke-A9CLICommand -cmds  $srinfocmd
							if ( $ShowRaw ) { return $result }
							if ( ( $Result.count ) -le "3" )
								{	Remove-Item  $tempFile
									return "No data available"
								}
							foreach ($s in  $Result[$rangestart..($Result.count)] )
								{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
									Add-Content -Path $tempFile -Value $s
								}
						}
			'Port'		
						{	$srinfocmd = "srhistport "
							if ( $BeginTimeSecs )			{	$srinfocmd += " -btsecs $BeginTimeSecs"	}
							if ( $EndTimeSecs )				{	$srinfocmd += " -etsecs $EndTimeSecs"	}
							if ( $rw )						{	$srinfocmd +=  " -rw "					}
							if ( $PortGroupBy )				{	$srinfocmd += " -groupby $PortGroupBy"	}		
							if ( $Frequency -eq 'Hourly' )	{	$srinfocmd += " -hourly"				}
							if ( $Frequency -eq 'Daily' )	{	$srinfocmd += " -daily"					}
							if ( $Frequency -eq 'Hires' )	{	$srinfocmd += " -hires"					}
							if ( $portType )				{	$srinfocmd += " -port_type $portType"	}		
							if ( $Port )					{	$srinfocmd += " $Port "					}
							if ( $Metric )					{	$srinfocmd += " -metric $Metric"	}				
							$tempFile = [IO.Path]::GetTempFileName()
							if ( $attime )
								{	$srinfocmd += " -attime "
									write-verbose "System reporter command => $srinfocmd"
									if($PortGroupBy)	{	$optionname = $PortGroupBy.toUpper()	}
									else			{	$optionname = "PORT_TYPE"			}
									Add-Content -Path $tempFile -Value "$optionname,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
									$rangestart = "3"
								}
							elseif ( $Metric -eq "time" )
								{	$rangestart = "2"
									Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec)"
								}
							elseif ( $Metric -eq "size" )
								{	$rangestart = "2"
									Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
								}
							else
								{	$rangestart = "2"
									Add-Content -Path $tempFile -Value "Date,Time,TimeZone,Secs,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes)"
								}
							write-verbose "System reporter command => $srinfocmd"
							$Result = Invoke-A9CLICommand -cmds  $srinfocmd
							if ( $ShowRaw ) { return $Result }
							if ( ($Result.count) -le "3" )
								{	Remove-Item  $tempFile
									return "No data available "
								}
							foreach ( $s in  $Result[$rangestart..($Result.count)] )
								{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
									Add-Content -Path $tempFile -Value $s
								}
						}
			'vLun'		
						{	$srinfocmd = "srhistvlun "
							if ( $BeginTimeSecs )			{	$srinfocmd += " -btsecs $BeginTimeSecs"	}
							if ( $EndTimeSecs )				{	$srinfocmd += " -etsecs $EndTimeSecs"	}
							if ( $rw )						{	$srinfocmd += " -rw "					}
							if ( $vLunGroupBy )				{	$srinfocmd += " -groupby $vLunGroupBy"	}		
							if ( $Frequency -eq 'Hourly' )	{	$srinfocmd += " -hourly"				}	
							if ( $Frequency -eq 'Daily' )	{	$srinfocmd += " -daily"					}
							if ( $Frequency -eq 'Hires' )	{	$srinfocmd += " -hires"					}
							if ( $hostE )					{	$srinfocmd += " -host $hostE "			}
							if ( $vv )						{	$srinfocmd += " -vv $vv "				}
							if ( $lun )						{	$srinfocmd += " -l $lun "				}		
							if ( $Port )					{	$srinfocmd += " -port $Port "			}
							if ( $Metric )					{	$srinfocmd += " -metric $Metric"		}
							$tempFile = [IO.Path]::GetTempFileName()
							if($attime)	{	$srinfocmd += " -attime "
											write-verbose "System reporter command => $srinfocmd"
											if($vLunGroupBy)	{	$optionname = $vLunGroupBy.toUpper()	}
											else			{	$optionname = "HOST_NAME"			}
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
							if ($ShowRaw)	{	return $Result }
							if(($Result.count) -le "3")	
								{	write-warning "No data available" 
									return	
								}
							foreach ($s in  $Result[$rangestart..($Result.count)] )
								{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
									Add-Content -Path $tempFile -Value $s
								}
						}
		}	
	$Result = Import-Csv $tempFile
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
		[Parameter()][ValidateScript({ 	if ( $_ -match '^[0-7]:[0-9]:[1-4]') 	{ $true } 	else{ throw "You must use the Node:Slot:Port format, where Node can be a number from 0 to 7, Slot can be a number from 0 to 9, and Port can be a number from 1 to 4."} })]	
						[String]	$NSP,
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

