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
param(	[Parameter(ParameterSetName='Pattern',Mandatory)]	[String]	$Pattern,
		[Parameter(ParameterSetName='AOCfg',Mandatory)]		[String]	$AOConfigurationName
)
begin
	{	Test-A9Connection -ClientType 'SshClient' 
	} 
process
	{	$Cmd = " removeaocfg -f "
		if($Pattern)
			{	$Cmd += " -pat $Pattern "
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
# SIG # Begin signature block
# MIIsVQYJKoZIhvcNAQcCoIIsRjCCLEICAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABECmt0+/3Tz5
# oTKTT2j+VvCMIzlfKuCQ5FMusKG4cB+bvPZsWaQTKcPPZ7o55L0DVnEgKe0kCCMo
# 3phUmFwpUYrYoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhIwghoOAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQC489pAyE88jDNv7LisZlk2lagtIgpxyDiMhZnnYYaEn/tdnWqRAPqBA
# SgWZzmej7GKspVfUtB5x//tRhhqp2VcwDQYJKoZIhvcNAQEBBQAEggGAXQ1sgz8Q
# UNq+/ak+JM2TrkI0zmbHMoeOPRp8rOlBhNgGTnm9Ix34iqXEW+bfKsyA5VGDxurf
# Fwb9yezE+PdMH23FWJ8/rIx3O2e7tYy/x12SItWbR875n34Gf1nKycMf1VwrQlxB
# 5HBvh1xKZaJVO7Zc258jJxYMztbrR9AWvzf9hm64yZNqY8+fc2FFD/2UWP5v24S+
# zIaEBJgV3QveM0F9V7iwppo3B4DzzOguZ9d0k8DnqQf7z10QshUZJ//V4vPr7J9B
# 8yKK9rRFaoqzKWdw+bCilMMppfykDkG7XepXxGWhkpJYdzLnoNrYgujbv4vyaosH
# yZ86TiXMW1r6jvkDhUP/o7fCwbmJIWrU8USx2VDPnvJv9dG8cJR3+SQADmlmrqpb
# IqCcSLMvVX9O6SlTDQRMXI3cPM6AdJUARAcYDlEMyJHwbGiWfqZ+dJ9MxCHaM8WH
# xn5xpbVdnGjU7ypr8mvG79ctONc1LbAZVwxGMtsmBZi7uAcrxxbnmijJoYIXWzCC
# F1cGCisGAQQBgjcDAwExghdHMIIXQwYJKoZIhvcNAQcCoIIXNDCCFzACAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDCgU6nTQhC/IMraBUYvIkfY/r1mC6DLl3g3Rhre
# 9btkp1B1cMPOtUD+djFxcagWG0cCEQD9zJc0pyzGqu3z1aEDo1ebGA8yMDI1MDUx
# NjAxMTI1NlqgghMDMIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVow
# QjELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdp
# Q2VydCBUaW1lc3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL5qc5/2lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L
# 660x5XltSVhhK64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLusl
# xdr9Qq82aKcpA9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7a
# vVnpUVmPvkxT8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl
# 7/r419CvEYVIrH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+N
# BikDO0mlUh902wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVki
# qLq+ISTdEjJKGjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5
# n10jxmGpxoMc6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h
# 6gYldp4FCMgrXdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNe
# REXAu2xUDEW8aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLq
# fY/M/SdV6mwWTyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIB
# hzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggr
# BgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0j
# BBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGal
# Y17uT5IfdqBbMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBp
# bmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tO
# CB3RKE/P09x7gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSX
# gmUrDKNSQqGTdpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPn
# vIWrqVogK0qM8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM
# 2UeUUW/8z3fvjxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlT
# VYzqfLDbe9PpBKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ
# /xll/HjO9JbNVekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef
# 4uaZFORNekUgQHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk91
# 04WQzYuVNsxyoVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7
# ucykW7eaCuWBsBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZD
# BD+XgbF+23/zBjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3K
# eFUCS7tpFk7CrDqkMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkq
# hkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBU
# cnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFV
# xyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8z
# H1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE9
# 8NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iE
# ZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXm
# G6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVV
# JnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz
# +ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8
# ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkr
# qPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKo
# wSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3I
# XjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaA
# FOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4
# oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqG
# SIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQ
# XeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwI
# gqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs
# 5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAn
# gkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnG
# E4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9
# P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt
# +8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Z
# iza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgx
# tGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimH
# CUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCC
# BY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290
# IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE9
# 8orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9S
# H8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g
# 1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RY
# jgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgD
# EI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNA
# vwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDg
# ohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQA
# zH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOk
# GLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHF
# ynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gd
# LfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYE
# FOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# dDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkq
# hkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7
# IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/5
# 9PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0
# POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISf
# b8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhU
# LSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEBMHcwYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QQIQC65mvFq6f5WHxvnpBOMzBDANBglghkgBZQMEAgIFAKCB4TAaBgkqhkiG9w0B
# CQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI1MDUxNjAxMTI1Nlow
# KwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQU29OF7mLb0j575PZxSFCHJNWGW0UwNwYL
# KoZIhvcNAQkQAi8xKDAmMCQwIgQgdnafqPJjLx9DCzojMK7WVnX+13PbBdZluQWT
# mEOPmtswPwYJKoZIhvcNAQkEMTIEMPIFMDvmNjyHXJCyZ7PDJD0phcZgMBojyseZ
# vBF1Kig5UsjSA63ZmZJ6H8uLwKD3AzANBgkqhkiG9w0BAQEFAASCAgBObXxdLHJn
# YmS5wO9kqHYhDrExBtV9CBrNHkQlh5YB5MxYe5X4WfAJUp0OOUyX/tQKKkBfhFoe
# EGWaDyNM1fvQAwMl8uXejzBHMRlfI/oi2VJWsN3wkvwpNqqYX4QKq43s+p8Gxjod
# OmmEDjCqn7l3lwBcJPBbN59+XB7fXy2Tx3sJI5e5Qod0Hmk+a+5Ri6c/7SVDa1S1
# r69QEj9lOnvlBgLkbOoCeXT81o5VWLDr1c9wb9isAtc9cyRJNERge05UZGenAmy3
# NCHHz17cIkFcPqtmth3EMXW1F8hBs5kSZt8gbuWpvuCafzP6UlOtCvNyznQphlhL
# NKhy6dBwdDFhWFoICMgfbCC9znM17dZ6rzd2DaxrWebK05hxnquFXVDB5mzdGslH
# INpVv4YL2C54jDWGpJOYAOM1KRTuEIumrIs43ecbCjYZVIZG8EtrhtGz2MSFgKKg
# Fexh41FispO2i6/SsAzZdwWEl6Y7+WY5wSCk+5TXCzr/PAbu0SlvS51Sg4HrLlwH
# uLJpquXpqT9kdXHToNgMRGwnOuMP9kXBodoIF5qLKAaZs57qCXBTna7xsYbYrUdI
# Wwx90J2MYav+RZbT/5rUmvW4OgcdAfCDMCFIJ/zLDrm58PSOaNkiik3mAUHh3CFr
# rHRVIjHc6h64CKVlyhUks13nLIVc+JQbnw==
# SIG # End signature block
