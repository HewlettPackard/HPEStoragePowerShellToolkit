####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## These commands are only used by classic 3Par devices. 


Function New-A9AdaptiveOptimizationConfig
{
<#
.SYNOPSIS
	Create an Adaptive Optimization configuration.
.DESCRIPTION
	This command creates an Adaptive Optimization configuration.
.PARAMETER T0cpg
	Specifies the Tier 0 CPG for this AO config.
.PARAMETER T1cpg
	Specifies the Tier 1 CPG for this AO config.
.PARAMETER T2cpg
	Specifies the Tier 2 CPG for this AO config.
.PARAMETER Mode
	Specifies the optimization bias for the AO config and can be one of the following:
		Performance: Move more regions towards higher performance tier.
		Balanced:    Balanced between higher performance and lower cost.
		Cost:        Move more regions towards lower cost tier.
	The default is Balanced.
.PARAMETER T0min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T1min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T2min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T0max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER T1max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER T2max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER AOConfigurationName
	Specifies an AO configuration name up to 31 characters in length.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$T0cpg,
		[Parameter()]	[String]	$T1cpg,
		[Parameter()]	[String]	$T2cpg,
		[Parameter()]	[ValidateSet('Performance','Balanced','Cost')]
						[String]	$Mode,
		[Parameter()]	[String]	$T0min,
		[Parameter()]	[String]	$T1min,
		[Parameter()]	[String]	$T2min,
		[Parameter()]	[String]	$T0max,
		[Parameter()]	[String]	$T1max,
		[Parameter()]	[String]	$T2max,
		[Parameter(Mandatory=$True)]	[String]	$AOConfigurationName
)
begin
	{	Test-A9Connection -ClientType 'SshClient' 
	}
process
	{	$Cmd = " createaocfg "
		if($T0cpg)					{	$Cmd += " -t0cpg $T0cpg " }
		if($T1cpg)					{	$Cmd += " -t1cpg $T1cpg " }
		if($T2cpg)					{	$Cmd += " -t2cpg $T2cpg "}
		if($Mode)					{	$Cmd += " -mode $Mode "}
		if($T0min)					{	$Cmd += " -t0min $T0min "}
		if($T1min)					{	$Cmd += " -t1min $T1min "}
		if($T2min)					{	$Cmd += " -t2min $T2min "}
		if($T0max)					{	$Cmd += " -t0max $T0max "	}
		if($T1max)					{	$Cmd += " -t1max $T1max "}
		if($T2max)					{	$Cmd += " -t2max $T2max "}
		if($AOConfigurationName) 	{	$Cmd += " $AOConfigurationName "}
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	} 
}

Function Remove-A9AdaptiveOptimizationConfig
{
<#
.SYNOPSIS
	Remove an Adaptive Optimization configuration.
.DESCRIPTION
	This command removes specified Adaptive Optimization configurations from the system.
.PARAMETER Pattern
	Specifies that specified patterns are treated as glob-style patterns and that all AO configurations matching the specified pattern are removed.
.PARAMETER AOConfigurationName
	Specifies the name of the AO configuration to be removed
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Pattern,
		[Parameter()]	[String]	$AOConfigurationName
)
begin
	{	Test-A9Connection -ClientType 'SshClient' 
	} 
process
	{	$Cmd = " removeaocfg -f "
		if($Pattern)
			{	$Cmd += " -pat $Pattern "
				if($AOConfigurationName)	{	Return "Either Pattern or AOConfigurationName."	}
			}
		if($AOConfigurationName)
			{	$Cmd += " $AOConfigurationName "
			}
			write-verbose "Executing the following SSH command `n`t $cmd"
			$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	} 
}

Function Start-A9AdaptiveOptimizationConfig
{
<#
.SYNOPSIS
	Start execution of an Adaptive Optimization configuration.
.DESCRIPTION
	This command starts execution of an Adaptive Optimization (AO) configuration using data region level performance data collected for the
	specified number of hours.
.PARAMETER Btsecs
    Select the begin time in seconds for the analysis period. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the analysis begins 12 hours ago.
.PARAMETER Etsecs
	Select the end time in seconds for the analysis period.
	The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the	current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the analysis ends with the most recent sample.
.PARAMETER Compact
	Specify if and how CPGs should be compacted. Choices for <mode> are
		auto    Automatically select the compactcpg mode (default).  This will free up the most space but can potentially take
				longer because it may cause additional region moves to increase consolidation.  This is the default mode. In this
				mode, trimonly is run first to trim LDs without performing region moves, and then the full compactcpg is run if space
				is still needed.
		trimonly Only run compactcpg with the -trimonly option. This will perform any region moves during compactcpg.
		no       Do not run compactcpg.  This option may be used if compactcpg is run or scheduled separately.
.PARAMETER Dryrun
	Do not execute the region moves, only show which moves would be done.
.PARAMETER Maxrunh
	Select the approximate maximum run time in hours (default is 6 hours). The number should be between 1 and 24 hours.
	The command will attempt to limit the amount of data to be moved so the command can complete by the specified number of hours.  If the
	time runs beyond the specified hours, the command will abort at an appropriate time.
.PARAMETER Min_iops
	Do not execute the region moves if the average IOPS during the measurement interval is less than <min_iops>.  If the -vv option is not
	specified, the IOPS are for all the LDs in the AOCFG. If the -vv option is specified, the IOPS are for all the VLUNs that
	include matching VVs. If min_iops is not specified, the default value is 50.
.PARAMETER Mode
	Override the optimization bias of the AO config, for instance to control AO differently for different VVs. Can be one of the
	following:
		Performance: Move more regions towards higher performance tier.
		Balanced:    Balanced between higher performance and lower cost.
		Cost:        Move more regions towards lower cost tier.
.PARAMETER Vv
	Limit the analysis and data movement to VVs with names that match one or more of the specified names or glob-style patterns. VV set names
	must be prefixed by "set:".  Note that snapshot VVs will not beconsidered since only base VVs have region space. Each VV's
	user CPG must be part of the specified AOCFG in order to be optimized. Snapshots in a VV's tree will not be optimized.
.PARAMETER T0min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.   
.PARAMETER T1min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.   
.PARAMETER T2min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T0max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.   
.PARAMETER T1max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.   
.PARAMETER T2max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER AocfgName
	The AO configuration name, using up to 31 characters.
.EXAMPLE
	PS:> Start-A9AdaptiveOptimizationConfig -Btsecs 3h -AocfgName prodaocfg
	
	Start execution of AO config prodaocfg using data for the past 3 hours:
.EXAMPLE	
	PS:> Start-A9AdaptiveOptimizationConfig -Btsecs 12h -Etsecs 3h -Maxrunh 6 -AocfgName prodaocfg

	Start execution of AO config prodaocfg using data from 12 hours ago until 3 hours ago, allowing up to 6 hours to complete:
.EXAMPLE
	PS:> Start-A9AdaptiveOptimizationConfig -Btsecs 3h -Vv "set:dbvvset" -AocfgName prodaocfg

	Start execution of AO for the vvset dbvvset in AOCFG prodaocfg using data for the past 3 hours:	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[String]	$Btsecs,
	[Parameter()]	[String]	$Etsecs,
	[Parameter()]	[ValidateSet('auto','trimonly','no')]
					[String]	$Compact,
	[Parameter()]	[switch]	$Dryrun,
	[Parameter()]	[String]	$Maxrunh,
	[Parameter()]	[String]	$Min_iops,
	[Parameter()]	[ValidateSet('Performance','Balanced','Cost')]
					[String]	$Mode,
	[Parameter()]	[String]	$Vv,
	[Parameter()]	[String]	$T0min,
	[Parameter()]	[String]	$T1min,
	[Parameter()]	[String]	$T2min,
	[Parameter()]	[String]	$T0max,
	[Parameter()]	[String]	$T1max,
	[Parameter()]	[String]	$T2max,
	[Parameter()]	[String]	$AocfgName
)
begin 
	{	Test-A9Connection -ClientType 'SshClient' 
	}
process
	{	$Cmd = " startao "
		if($Btsecs)		{	$Cmd += " -btsecs $Btsecs " }
		if($Etsecs)		{	$Cmd += " -etsecs $Etsecs " }
		if($Compact)	{	$Cmd += " -compact $Compact " }
		if($Dryrun)		{	$Cmd += " -dryrun " }
		if($Maxrunh)	{	$Cmd += " -maxrunh $Maxrunh " }
		if($Min_iops)	{	$Cmd += " -min_iops $Min_iops " }
		if($Mode)		{	$Cmd += " -mode $Mode " }
		if($Vv)			{	$Cmd += " -vv $Vv " }
		if($T0min)		{	$Cmd += " -t0min $T0min " }
		if($T1min)		{	$Cmd += " -t1min $T1min " }
		if($T2min)		{	$Cmd += " -t2min $T2min " }
		if($T0max)		{	$Cmd += " -t0max $T0max " }
		if($T1max)		{	$Cmd += " -t1max $T1max " }
		if($T2max)		{	$Cmd += " -t2max $T2max " }
		if($AocfgName) 	{	$Cmd += " $AocfgName " }
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	} 
}

Function Update-A9AdaptiveOptimizationConfig
{
<#
.SYNOPSIS
	Update an Adaptive Optimization configuration.
.DESCRIPTION
	Update an Adaptive Optimization configuration.
.PARAMETER T0cpg
	Specifies the Tier 0 CPG for this AO config.
.PARAMETER T1cpg
	Specifies the Tier 1 CPG for this AO config.
.PARAMETER T2cpg
	Specifies the Tier 2 CPG for this AO config.
.PARAMETER Mode
	Specifies the optimization bias for the AO config and can be one of the following:
		Performance: Move more regions towards higher performance tier.
		Balanced:    Balanced between higher performance and lower cost.
		Cost:        Move more regions towards lower cost tier.
.PARAMETER T0min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T1min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T2min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T0max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER T1max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER T2max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER NewName
	Specifies a new name for the AO configuration of up to 31 characters in length.
.PARAMETER AOConfigurationName
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[String]	$T0cpg,
	[Parameter()]	[String]	$T1cpg,
	[Parameter()]	[String]	$T2cpg,
	[Parameter()]	[ValidateSet('Performance','Balanced','Cost')]
					[String]	$Mode,
	[Parameter()]	[String]	$T0min,
	[Parameter()]	[String]	$T1min,
	[Parameter()]	[String]	$T2min,
	[Parameter()]	[String]	$T0max,
	[Parameter()]	[String]	$T1max,
	[Parameter()]	[String]	$T2max,
	[Parameter()]	[String]	$NewName,
	[Parameter(Mandatory=$True)][String]	$AOConfigurationName
)
begin
	{	Test-A9Connection -ClientType 'SshClient' 
	}
process 
	{	$Cmd = " setaocfg "
		if($T0cpg)	{	$Cmd += " -t0cpg $T0cpg " 	}
		if($T1cpg) 	{	$Cmd += " -t1cpg $T1cpg " 	}
		if($T2cpg) 	{	$Cmd += " -t2cpg $T2cpg " 	}
		if($Mode) 	{	$Cmd += " -mode $Mode " 	} 
		if($T0min)	{	$Cmd += " -t0min $T0min " 	}
		if($T1min) 	{	$Cmd += " -t1min $T1min " 	}
		if($T2min) 	{	$Cmd += " -t2min $T2min " 	}
		if($T0max) 	{	$Cmd += " -t0max $T0max " 	}
		if($T1max) 	{	$Cmd += " -t1max $T1max " 	}
		if($T2max) 	{	$Cmd += " -t2max $T2max " 	}
		if($NewName){	$Cmd += " -name $NewName " 	} 
		if($AOConfigurationName) {	$Cmd += " $AOConfigurationName " }
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	} 
}

Function Get-A9SystemReportAOMoves
{
<#
.SYNOPSIS
    The command shows the space that AO has moved between tiers.	
.DESCRIPTION
    The command shows the space that AO has moved between tiers.
.EXAMPLE
	PS:> Get-A9SystemReportAOMoves -btsecs 7200
.EXAMPLE
	PS:> Get-A9SystemReportAOMoves -etsecs 7200
.EXAMPLE
	PS:> Get-A9SystemReportAOMoves -oneline 
.EXAMPLE
	PS:> Get-A9SystemReportAOMoves -withvv 
.EXAMPLE
	PS:> Get-A9SystemReportAOMoves -VV_name XYZ
.PARAMETER btsecs 
	Select the begin time in seconds for the report. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the time at which the report begins is 12 ho                                                          urs ago.
	If -btsecs 0 is specified then the report begins at the earliest sample.
.PARAMETER etsecs 
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
.PARAMETER oneline
	Show data in simplified format with one line per AOCFG.
.PARAMETER VV_name
	Limit the analysis to VVs with names that match one or more of the specified names or glob-style patterns. VV set names must be
	prefixed by "set:".  Note that snapshot VVs will not be considered since only base VVs have region space.
.PARAMETER withvv
	Show the data for each VV.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$btsecs,
		[Parameter()]	[String]	$etsecs,
		[Parameter()]	[switch]	$oneline,
		[Parameter()]	[String]	$VV_name,
		[Parameter()]	[switch]	$withvv		
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd= "sraomoves "
	if ($btsecs)	{	$cmd+=" -btsecs $btsecs "		}	
	if ($etsecs)	{	$cmd+=" -etsecs $etsecs "		}
	if ($oneline)	{	$cmd+=" -oneline "		}
	if ($VV_name)	{	$cmd+=" -vv $VV_name "		}
	if ($withvv)	{	$cmd+=" -withvv "		}	
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	return 	$Result	
} 
}
