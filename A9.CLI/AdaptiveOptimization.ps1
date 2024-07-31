####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9AdaptiveOptimizationConfig
{
<#
.SYNOPSIS
	Show Adaptive Optimization configurations.
.DESCRIPTION
	This command shows Adaptive Optimization configurations in the system.
.PARAMETER Domain
	Shows only AO configurations that are in domains with names matching one or more of the <domain_name_or_pattern> argument. This option
	does not allow listing objects within a domain of which the user is not a member. Patterns are glob-style (shell-style) patterns (see help on sub,globpat)
.PARAMETER AOConfigurationName
.NOTES
	This command requires a SSH type connection.

#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Domain,
		[Parameter()]	[String]	$ConfigName
)
begin
{	Test-A9Connection -ClientType 'SshClient' 
}
process
{	$Cmd = " showaocfg "
	if($Domain)	{	$Cmd += " -domain $Domain "	}
	if($ConfigName)	{	$Cmd += " $ConfigName " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -2  
			$oneTimeOnly = "True"
			foreach ($s in  $Result[1..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")		
					$s= [regex]::Replace($s,"-","")		
					$s= $s.Trim()		
					if($oneTimeOnly -eq "True")
						{	$sTemp1=$s				
							$sTemp = $sTemp1.Split(',')							
							$sTemp[2] = "T0(CPG)"
							$sTemp[3] = "T1(CPG)"
							$sTemp[4] = "T2(CPG)"
							$sTemp[5] = "T0Min(MB)"
							$sTemp[6] = "T1Min(MB)"
							$sTemp[7] = "T2Min(MB)"
							$sTemp[8] = "T0Max(MB)"
							$sTemp[9] = "T1Max(MB)"
							$sTemp[10] = "T2Max(MB)"
							$sTemp[11] = "T0Warn(MB)"
							$sTemp[12] = "T1Warn(MB)"
							$sTemp[13] = "T2Warn(MB)"
							$sTemp[14] = "T0Limit(MB)"
							$sTemp[15] = "T1Limit(MB)"
							$sTemp[16] = "T2Limit(MB)"
							$newTemp= [regex]::Replace($sTemp,"^ ","")			
							$newTemp= [regex]::Replace($sTemp," ",",")				
							$newTemp= $newTemp.Trim()
							$s=$newTemp			
						}
					Add-Content -Path $tempfile -Value $s
					$oneTimeOnly = "False"		
				}
			Import-Csv $tempFile 
			Remove-Item  $tempFile 
		}
	else{	Return $Result	}
}
}

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
.EXAMPLE
	PS:> Start-A9AdaptiveOptimizationConfig -Btsecs 3h -AocfgName prodaocfg
	
	Start execution of AO config prodaocfg using data for the past 3 hours:
.EXAMPLE	
	PS:> Start-A9AdaptiveOptimizationConfig -Btsecs 12h -Etsecs 3h -Maxrunh 6 -AocfgName prodaocfg

	Start execution of AO config prodaocfg using data from 12 hours ago until 3 hours ago, allowing up to 6 hours to complete:
.EXAMPLE
	PS:> Start-A9AdaptiveOptimizationConfig -Btsecs 3h -Vv "set:dbvvset" -AocfgName prodaocfg

	Start execution of AO for the vvset dbvvset in AOCFG prodaocfg using data for the past 3 hours:	
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
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAw9Z5Xlp81
# Gm442Y4w55llpsiaNxsfnZiJtmRnxrNiiCo/GxSHj02oaYNk9ke+Xl4KdSHQz1pB
# A47kECOaZvMioIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQJOq3C2QuN3AYkn35lWbuwyNF349VnZGlCjdJF/OcU3ryaMoBoL1sc++
# ABdnrW2g+KEJCxNCPIlccTSfhBtkEgEwDQYJKoZIhvcNAQEBBQAEggGAahbteucy
# D3looDWJvCiVLQHcBYe52CFA+46PXnUE63y3hJjBctzxHw5Agq/9CAeYm4h8czF0
# QQ5BWTNPsjj0saiSiD8K/jbiGeMVOCL8Y6emYXp+JyBu9OfR6cV1WQF3YVeocGDL
# Univ4ThM3ZyG33ElYASTX+XGyJsV09SzyMB/aEmMyXWyn9xLeW8wO8ydgtZKPC2D
# NmCQKefQlb4oPfvI9PXM7DN8MfhuH/J6uWFmsl2Sg7koNlbta3WcWCnfRgrwGuYN
# 6iVEOwzTi5VRUI9X/tCM/oqPrgJjCEenKNH8bK71r/doq1X9RJJVucAUkCN4SleU
# umT5duIUdF+jMpJzYcPcmtN84Dc+uAvF+URvUJDxcoQGkmGI4GK/VoAS2x4+zSXd
# +YQ3paWjtrKMHVFUqjiNitXXxZ6yyZl1RDvpw277MZWurwfB95aU35tiAjGdVrfr
# gSd5VmXMBZb/cW+nihBJGMks/rzy8yjOO2dtlESD0SBPH9XHpxvPEZUToYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDA7f+ebBQUJygy4LvcsQreDVI54EqD0PURZhoqj
# EeG/auBdp6CN6lGujGlbJv9St20CEQD5SNPknz7clyRTuV8I91ECGA8yMDI0MDcz
# MTE5MTczM1qgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
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
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTE5
# MTczM1owKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMFQFnknhibICmlU4H6lbSGnKFR/O
# LW/KOZBWBkys7rwC6zxTAHthYFFqdtTOWUf2ozANBgkqhkiG9w0BAQEFAASCAgA9
# Y938B3XgBRRXwG8ZFa3S1MrpPNpcesu8acQOg7YnaRGMGR1PVtWVLi1tgr1LgEO2
# UiI8JpsJEmQRVOB/SRmSiOoX7bMPAHLWdGRyysWLrw9gHzd38zA4MCILi70KNjaj
# TMqWQXHZHEq3pYrW/Uq5YTVRS0SqyO4s87Mtb7my0UG8wgu0GPNInlHKfePtzlMD
# 9vvOlLCorzmq/MAHJ1TqtrN/iymIGscURQw3cMUKLZ6HKhyMyIfObcJWvCXSIUZq
# 7E7rvmOzkcZbw5uUn3q48iCNnoNO51uwB4QBbuj12lf9AhC9jN0V5edsVw8J4FP0
# bgOi2++Yr8f36RlB6od2C10oWavmvKLCnnxkQgpf9xdHXFwwBlltgfGuDZLhuu5q
# caR8HeG+8ggrrJMRgKedgJNorgnu/0yyBzAxNiM0uWleLpfNbNkMeaNBsUwTb9lS
# MAZIAz5hiCTuSNBn3i5TUyxoky7C+Bu6aAsQhMrFTvEi+nEwYst6q7NsDebwVvQy
# uHs5R4hyH04HBKpmUI0y4n+zmDxPS2Tm1G8qFNBBI87orh3o9B3/9h/v/maX3Z8t
# VzGDvTYDI/sNeZWJenAccdK5UKPTsvVQLbJHR3xWrA5qxNyOqI9g2ELP1ZSVGGyx
# CB+90g/y7JncC5h44W3mqXUIPFKtcp+E9tWIUbOvKQ==
# SIG # End signature block
