﻿####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
##	File Name:		AdaptiveOptimization.psm1
##	Description: 	Adaptive Optimization(AO) cmdlets 
##		
##	Created:		October 2019
##	Last Modified:	October 2019
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
#$global:VSLibraries = $global:VSLibraries.Substring(0,$global:VSLibraries.Length-4)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Import-Module "$global:VSLibraries\Global\Logger.psm1"
#Import-Module "$global:VSLibraries\Global\VS-Functions.psm1"

############################################################################################################################################
## FUNCTION Test-CLIObject
############################################################################################################################################
Function Test-CLIObject 
{
Param( 	
    [string]$ObjectType, 
	[string]$ObjectName ,
	[string]$ObjectMsg = $ObjectType, 
	$SANConnection = $global:SANConnection
	)

	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")
	{
		$IsObjectExisted = $false
	}
	return $IsObjectExisted
	
} # End FUNCTION Test-CLIObject

##########################################################################
######################### FUNCTION Get-AOConfigurations ##############
##########################################################################
Function Get-AOConfigurations()
{
<#
  .SYNOPSIS
   Get-AOConfigurations - Show Adaptive Optimization configurations.

  .DESCRIPTION
   The Get-AOConfigurations command shows Adaptive Optimization (AO) configurations in
   the system.

  .EXAMPLE

  .PARAMETER Domain
   Shows only AO configurations that are in domains with names matching
   one or more of the <domain_name_or_pattern> argument. This option
   does not allow listing objects within a domain of which the user is
   not a member. Patterns are glob-style (shell-style) patterns (see
   help on sub,globpat)

  .PARAMETER AOConfigurationName
   
  .Notes
    NAME: Get-AOConfigurations
    LASTEDIT 17-10-2019 
    KEYWORDS: Get-AOConfigurations
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[System.String]
	$Domain,

	[Parameter(Position=1, Mandatory=$false)]
	[System.String]
	$AOConfigurationName,

	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Get-AOConfigurations - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Get-AOConfigurations since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Get-AOConfigurations since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

	$Cmd = " showaocfg "

 if($Domain)
 {
	$Cmd += " -domain $Domain "
 }
 
 if($AOConfigurationName)
 {
	$Cmd += " $AOConfigurationName "
 }
 
 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : Get-AOConfigurations command -->" INFO:
 
 if($Result.count -gt 1)
 { 
	$tempFile = [IO.Path]::GetTempFileName()
	$LastItem = $Result.Count -2  
	$oneTimeOnly = "True"
	foreach ($s in  $Result[1..$LastItem] )
	{
		$s= [regex]::Replace($s,"^ ","")
		$s= [regex]::Replace($s,"^ ","")
		$s= [regex]::Replace($s,"^ ","")		
		$s= [regex]::Replace($s," +",",")		
		$s= [regex]::Replace($s,"-","")		
		$s= $s.Trim()		
		
		if($oneTimeOnly -eq "True")
		{				
			$sTemp1=$s				
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
	del $tempFile 
 }
 else
 {
	Return $Result
 }
} ##  End-of Get-AOConfigurations

##########################################################################
######################### FUNCTION New-AOConfiguration ###############
##########################################################################
Function New-AOConfiguration()
{
<#
  .SYNOPSIS
   New-AOConfiguration - Create an Adaptive Optimization configuration.

  .DESCRIPTION
   The New-AOConfiguration command creates an Adaptive Optimization configuration.

  .EXAMPLE

  .PARAMETER T0cpg
   Specifies the Tier 0 CPG for this AO config.

  .PARAMETER T1cpg
   Specifies the Tier 1 CPG for this AO config.

  .PARAMETER T2cpg
   Specifies the Tier 2 CPG for this AO config.

  .PARAMETER Mode
   Specifies the optimization bias for the AO config and can
   be one of the following:
	   Performance: Move more regions towards higher performance tier.
	   Balanced:    Balanced between higher performance and lower cost.
	   Cost:        Move more regions towards lower cost tier.
   The default is Balanced.

  .PARAMETER T0min
	Specifies the minimum space utilization of the tier CPG for AO to
	maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T).
	Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.

  .PARAMETER T1min
	Specifies the minimum space utilization of the tier CPG for AO to
	maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T).
	Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.

  .PARAMETER T2min
	Specifies the minimum space utilization of the tier CPG for AO to
	maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T).
	Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.

  .PARAMETER T0max
  	Specifies the maximum space utilization of the tier CPG. AO will
	move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG.
	The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will
	use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.


  .PARAMETER T1max
  	Specifies the maximum space utilization of the tier CPG. AO will
	move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG.
	The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will
	use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.


  .PARAMETER T2max
	Specifies the maximum space utilization of the tier CPG. AO will
	move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG.
	The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will
	use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.

	
  .PARAMETER AOConfigurationName
	 Specifies an AO configuration name up to 31 characters in length.
	
  .Notes
    NAME: New-AOConfiguration
    LASTEDIT 17-10-2019
    KEYWORDS: New-AOConfiguration
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[System.String]
	$T0cpg,

	[Parameter(Position=1, Mandatory=$false)]
	[System.String]
	$T1cpg,

	[Parameter(Position=2, Mandatory=$false)]
	[System.String]
	$T2cpg,

	[Parameter(Position=3, Mandatory=$false)]
	[System.String]
	$Mode,

	[Parameter(Position=4, Mandatory=$false)]
	[System.String]
	$T0min,

	[Parameter(Position=5, Mandatory=$false)]
	[System.String]
	$T1min,

	[Parameter(Position=6, Mandatory=$false)]
	[System.String]
	$T2min,

	[Parameter(Position=7, Mandatory=$false)]
	[System.String]
	$T0max,

	[Parameter(Position=8, Mandatory=$false)]
	[System.String]
	$T1max,

	[Parameter(Position=9, Mandatory=$false)]
	[System.String]
	$T2max,

	[Parameter(Position=10, Mandatory=$True)]
	[System.String]
	$AOConfigurationName,

	[Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In New-AOConfiguration - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting New-AOConfiguration since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet New-AOConfiguration since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

	$Cmd = " createaocfg "

 if($T0cpg)
 {
	$Cmd += " -t0cpg $T0cpg "
 }

 if($T1cpg)
 {
	$Cmd += " -t1cpg $T1cpg "
 }

 if($T2cpg)
 {
	$Cmd += " -t2cpg $T2cpg "
 }

 if($Mode)
 {
  $Cmd += " -mode $Mode "
 }

 if($T0min)
 {
	$Cmd += " -t0min $T0min "
 }

 if($T1min)
 {
	$Cmd += " -t1min $T1min "
 }

 if($T2min)
 {
	$Cmd += " -t2min $T2min "
 }

 if($T0max)
 {
	$Cmd += " -t0max $T0max "
 }

 if($T1max)
 {
	$Cmd += " -t1max $T1max "
 }

 if($T2max)
 {
	$Cmd += " -t2max $T2max "
 }

 if($AOConfigurationName)
 {
	$Cmd += " $AOConfigurationName "
 }
 

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : New-AOConfiguration command -->" INFO: 
 Return $Result
} ##  End-of New-AOConfiguration

##########################################################################
######################### FUNCTION Remove-AOConfiguration ############
##########################################################################
Function Remove-AOConfiguration()
{
<#
  .SYNOPSIS
   Remove-AOConfiguration - Remove an Adaptive Optimization configuration.

  .DESCRIPTION
   The Remove-AOConfiguration command removes specified Adaptive Optimization
   configurations from the system.

  .EXAMPLE

  .PARAMETER Pattern
   Specifies that specified patterns are treated as glob-style patterns and
   that all AO configurations matching the specified pattern are removed.
  
  .PARAMETER AOConfigurationName
   Specifies the name of the AO configuration to be removed
   
  .Notes
    NAME: Remove-AOConfiguration
    LASTEDIT 17-10-2019
    KEYWORDS: Remove-AOConfiguration
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[System.String]
	$Pattern,

	[Parameter(Position=1, Mandatory=$false)]
	[System.String]
	$AOConfigurationName,

	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Remove-AOConfiguration - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Remove-AOConfiguration since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Remove-AOConfiguration since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

 $Cmd = " removeaocfg -f "

 if($Pattern)
 {
	$Cmd += " -pat $Pattern "
	if($AOConfigurationName)
	{
		Return "Either Pattern or AOConfigurationName."
	}
 }

 if($AOConfigurationName)
 {
	$Cmd += " $AOConfigurationName "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : Remove-AOConfiguration command -->" INFO: 
 
 Return $Result
} ##  End-of Remove-AOConfiguration

##########################################################################
################## FUNCTION Start-AO ###################
##########################################################################
Function Start-AO()
{
<#
  .SYNOPSIS
   Start-AO - Start execution of an Adaptive Optimization configuration.

  .DESCRIPTION
   The Start-AO command starts execution of an Adaptive Optimization (AO)
   configuration using data region level performance data collected for the
   specified number of hours.

  .EXAMPLE
	Start-AO -Btsecs 3h -AocfgName prodaocfg
	Start execution of AO config prodaocfg using data for the past 3 hours:

  .EXAMPLE	
	Start-AO -Btsecs 12h -Etsecs 3h -Maxrunh 6 -AocfgName prodaocfg
	Start execution of AO config prodaocfg using data from 12 hours ago until
	3 hours ago, allowing up to 6 hours to complete:
	
  .EXAMPLE
	Start-AO -Btsecs 3h -Vv "set:dbvvset" -AocfgName prodaocfg
	Start execution of AO for the vvset dbvvset in AOCFG prodaocfg using
    data for the past 3 hours:	
	
  .PARAMETER Btsecs
    Select the begin time in seconds for the analysis period.
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
	- A negative number indicating the number of seconds before the
	  current time. Instead of a number representing seconds, <secs> can
	  be specified with a suffix of m, h or d to represent time in minutes
	  (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the analysis ends with the most recent
	sample.

  .PARAMETER Compact
   Specify if and how CPGs should be compacted. Choices for <mode> are
   auto     Automatically select the compactcpg mode (default).
	   This will free up the most space but can potentially take
	   longer because it may cause additional region moves to
	   increase consolidation.  This is the default mode. In this
	   mode, trimonly is run first to trim LDs without performing
	   region moves, and then the full compactcpg is run if space
	   is still needed.
   trimonly Only run compactcpg with the -trimonly option. This will
	   t perform any region moves during compactcpg.
   no       Do not run compactcpg.  This option may be used if
	compactcpg is run or scheduled separately.

  .PARAMETER Dryrun
   Do not execute the region moves, only show which moves would be done.

  .PARAMETER Maxrunh
	Select the approximate maximum run time in hours (default is 6 hours).
	The number should be between 1 and 24 hours.
	The command will attempt to limit the amount of data to be moved so
	the command can complete by the specified number of hours.  If the
	time runs beyond the specified hours, the command will abort at an
	appropriate time.

  .PARAMETER Min_iops
	Do not execute the region moves if the average IOPS during the
	measurement interval is less than <min_iops>.  If the -vv option is not
	specified, the IOPS are for all the LDs in the AOCFG.
	If the -vv option is specified, the IOPS are for all the VLUNs that
	include matching VVs.
	If min_iops is not specified, the default value is 50.

  .PARAMETER Mode
	Override the optimization bias of the AO config, for instance to
	control AO differently for different VVs. Can be one of the
	following:
	Performance: Move more regions towards higher performance tier.
	Balanced:    Balanced between higher performance and lower cost.
	Cost:        Move more regions towards lower cost tier.

  .PARAMETER Vv
	Limit the analysis and data movement to VVs with names that match one
	or more of the specified names or glob-style patterns. VV set names
	must be prefixed by "set:".  Note that snapshot VVs will not be
	considered since only base VVs have region space. Each VV's
	user CPG must be part of the specified AOCFG in order to be
	optimized. Snapshots in a VV's tree will not be optimized.

  .PARAMETER T0min
	Specifies the minimum space utilization of the tier CPG for AO to
	maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T).
	Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.   

  .PARAMETER T1min
	Specifies the minimum space utilization of the tier CPG for AO to
	maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T).
	Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.   

  .PARAMETER T2min
	Specifies the minimum space utilization of the tier CPG for AO to
	maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T).
	Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.

  .PARAMETER T0max
	Specifies the maximum space utilization of the tier CPG. AO will
	move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG.
	The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will
	use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.   

  .PARAMETER T1max
	Specifies the maximum space utilization of the tier CPG. AO will
	move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG.
	The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will
	use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.   

  .PARAMETER T2max
	Specifies the maximum space utilization of the tier CPG. AO will
	move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG.
	The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will
	use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.

  .PARAMETER AocfgName
	The AO configuration name, using up to 31 characters.
	
  .Notes
    NAME: Start-AO
    LASTEDIT 17-10-2019
    KEYWORDS: Start-AO
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[System.String]
	$Btsecs,

	[Parameter(Position=1, Mandatory=$false)]
	[System.String]
	$Etsecs,

	[Parameter(Position=2, Mandatory=$false)]
	[System.String]
	$Compact,

	[Parameter(Position=3, Mandatory=$false)]
	[switch]
	$Dryrun,

	[Parameter(Position=4, Mandatory=$false)]
	[System.String]
	$Maxrunh,

	[Parameter(Position=5, Mandatory=$false)]
	[System.String]
	$Min_iops,

	[Parameter(Position=6, Mandatory=$false)]
	[System.String]
	$Mode,

	[Parameter(Position=7, Mandatory=$false)]
	[System.String]
	$Vv,

	[Parameter(Position=8, Mandatory=$false)]
	[System.String]
	$T0min,

	[Parameter(Position=9, Mandatory=$false)]
	[System.String]
	$T1min,

	[Parameter(Position=10, Mandatory=$false)]
	[System.String]
	$T2min,

	[Parameter(Position=11, Mandatory=$false)]
	[System.String]
	$T0max,

	[Parameter(Position=12, Mandatory=$false)]
	[System.String]
	$T1max,

	[Parameter(Position=13, Mandatory=$false)]
	[System.String]
	$T2max,

	[Parameter(Position=14, Mandatory=$false)]
	[System.String]
	$AocfgName,

	[Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Start-AO - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Start-AO since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Start-AO since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

 $Cmd = " startao "

 if($Btsecs)
 {
	$Cmd += " -btsecs $Btsecs "
 }

 if($Etsecs)
 {
	$Cmd += " -etsecs $Etsecs "
 }

 if($Compact)
 {
	$Cmd += " -compact $Compact "
 }

 if($Dryrun)
 {
	$Cmd += " -dryrun "
 }

 if($Maxrunh)
 {
	$Cmd += " -maxrunh $Maxrunh "
 }

 if($Min_iops)
 {
	$Cmd += " -min_iops $Min_iops "
 }

 if($Mode)
 {
	$Cmd += " -mode $Mode "
 }

 if($Vv)
 {
	$Cmd += " -vv $Vv "
 }

 if($T0min)
 {
	$Cmd += " -t0min $T0min "
 }

 if($T1min)
 {
	$Cmd += " -t1min $T1min "
 }

 if($T2min)
 {
	$Cmd += " -t2min $T2min "
 }

 if($T0max)
 {
	$Cmd += " -t0max $T0max "
 }

 if($T1max)
 {
	$Cmd += " -t1max $T1max "
 }

 if($T2max)
 {
	$Cmd += " -t2max $T2max "
 }

 if($AocfgName)
 {
	$Cmd += " $AocfgName "
 }
 
 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : Start-AO command -->" INFO: 
 
 Return $Result
} ##  End-of Start-AO

##########################################################################
######################### FUNCTION Update-AOConfiguration ############
##########################################################################
Function Update-AOConfiguration()
{
<#
  .SYNOPSIS
   Update-AOConfiguration - Update an Adaptive Optimization configuration.

  .DESCRIPTION
   Update-AOConfiguration - Update an Adaptive Optimization configuration.

  .EXAMPLE

  .PARAMETER T0cpg
   Specifies the Tier 0 CPG for this AO config.

  .PARAMETER T1cpg
   Specifies the Tier 1 CPG for this AO config.

  .PARAMETER T2cpg
   Specifies the Tier 2 CPG for this AO config.

  .PARAMETER Mode
   Specifies the optimization bias for the AO config and can
   be one of the following:
	   Performance: Move more regions towards higher performance tier.
	   Balanced:    Balanced between higher performance and lower cost.
	   Cost:        Move more regions towards lower cost tier.

  .PARAMETER T0min
   Specifies the minimum space utilization of the tier CPG for AO to
   maintain when optimizing regions between tiers. The size can be
   specified in MB (default) or GB (using g or G) or TB (using t or T).
   Setting a minimum to 0 (default) indicates that no minimum space
   utilization will be enforced.

  .PARAMETER T1min
   Specifies the minimum space utilization of the tier CPG for AO to
   maintain when optimizing regions between tiers. The size can be
   specified in MB (default) or GB (using g or G) or TB (using t or T).
   Setting a minimum to 0 (default) indicates that no minimum space
   utilization will be enforced.

  .PARAMETER T2min
   Specifies the minimum space utilization of the tier CPG for AO to
   maintain when optimizing regions between tiers. The size can be
   specified in MB (default) or GB (using g or G) or TB (using t or T).
   Setting a minimum to 0 (default) indicates that no minimum space
   utilization will be enforced.

  .PARAMETER T0max
   Specifies the maximum space utilization of the tier CPG. AO will
   move regions into and out of the CPG based on their relative access
   rate history, but will not exceed this maximum size in the CPG.
   The size can be specified in MB (default) or GB (using g or G) or
   TB (using t or T). Setting a max to 0 (default) indicates that AO will
   use other indicators to decide the maximum CPG space utilization:
   either the CPG sdgl, sdgw, or maximum possible growth size.

  .PARAMETER T1max
   Specifies the maximum space utilization of the tier CPG. AO will
   move regions into and out of the CPG based on their relative access
   rate history, but will not exceed this maximum size in the CPG.
   The size can be specified in MB (default) or GB (using g or G) or
   TB (using t or T). Setting a max to 0 (default) indicates that AO will
   use other indicators to decide the maximum CPG space utilization:
   either the CPG sdgl, sdgw, or maximum possible growth size.

  .PARAMETER T2max
   Specifies the maximum space utilization of the tier CPG. AO will
   move regions into and out of the CPG based on their relative access
   rate history, but will not exceed this maximum size in the CPG.
   The size can be specified in MB (default) or GB (using g or G) or
   TB (using t or T). Setting a max to 0 (default) indicates that AO will
   use other indicators to decide the maximum CPG space utilization:
   either the CPG sdgl, sdgw, or maximum possible growth size.

  .PARAMETER NewName
   Specifies a new name for the AO configuration of up to 31 characters in
   length.

  .PARAMETER AOConfigurationName
   
  .Notes
    NAME: Update-AOConfiguration
    LASTEDIT 17-10-2019
    KEYWORDS: Update-AOConfiguration
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[System.String]
	$T0cpg,

	[Parameter(Position=1, Mandatory=$false)]
	[System.String]
	$T1cpg,

	[Parameter(Position=2, Mandatory=$false)]
	[System.String]
	$T2cpg,

	[Parameter(Position=3, Mandatory=$false)]
	[System.String]
	$Mode,

	[Parameter(Position=4, Mandatory=$false)]
	[System.String]
	$T0min,

	[Parameter(Position=5, Mandatory=$false)]
	[System.String]
	$T1min,

	[Parameter(Position=6, Mandatory=$false)]
	[System.String]
	$T2min,

	[Parameter(Position=7, Mandatory=$false)]
	[System.String]
	$T0max,

	[Parameter(Position=8, Mandatory=$false)]
	[System.String]
	$T1max,

	[Parameter(Position=9, Mandatory=$false)]
	[System.String]
	$T2max,

	[Parameter(Position=10, Mandatory=$false)]
	[System.String]
	$NewName,
	
	[Parameter(Position=11, Mandatory=$True)]
	[System.String]
	$AOConfigurationName,

	[Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Update-AOConfiguration. - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Update-AOConfiguration. since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Update-AOConfiguration since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

	$Cmd = " setaocfg "

 if($T0cpg)
 {
	$Cmd += " -t0cpg $T0cpg "
 }

 if($T1cpg)
 {
	$Cmd += " -t1cpg $T1cpg "
 }

 if($T2cpg)
 {
	$Cmd += " -t2cpg $T2cpg "
 }

 if($Mode)
 {
	$Cmd += " -mode $Mode "
 }

 if($T0min)
 {
	$Cmd += " -t0min $T0min "
 }

 if($T1min)
 {
	$Cmd += " -t1min $T1min "
 }

 if($T2min)
 {
	$Cmd += " -t2min $T2min "
 }

 if($T0max)
 {
	$Cmd += " -t0max $T0max "
 }

 if($T1max)
 {
	$Cmd += " -t1max $T1max "
 }

 if($T2max)
 {
	$Cmd += " -t2max $T2max "
 }

 if($NewName)
 {
	$Cmd += " -name $NewName "
 }
 
 if($AOConfigurationName)
 {
	$Cmd += " $AOConfigurationName "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : Update-AOConfiguration. command -->" INFO: 
 Return $Result
} ##  End-of Update-AOConfiguration.

Export-ModuleMember Get-AOConfigurations , New-AOConfiguration , Remove-AOConfiguration , Start-AO , Update-AOConfiguration
# SIG # Begin signature block
# MIIhEAYJKoZIhvcNAQcCoIIhATCCIP0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCkSYpVb8abI7fq
# HImXUV/pmYm45Jt9QvZcoCbf32pvdqCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPuzCCD7cCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# lyeM0De9oyBlw1X+wc1xB5QX03/K2AnPm6ZsKfBLdUcwDQYJKoZIhvcNAQEBBQAE
# ggEAKQE+bvZAMwBSn4iIRei4gCzxtNJY+qGFFag264yBbsrK5L7j8WG2IzReagOL
# zBk+4HTQLMHhDzi/Hx/z3yGy9O8D+TxmB4rNZBO+bTmmuQ+TavVkiSxl6lcKhifV
# ghu0kB7A/SnD/pTaIfOn65ZbN3xXz6+UHhf/j6Is8HBH34jld6CIDMNxnqqONcCT
# wVb8D2fB0z/e+FIydAfHl1vAoDlBJZQ6thhhaP9DPRvk9qBTPgpg6pERisiWn+0R
# ooYqyoPiYbFEFxWsDyiuZ2tEX31qdZ6xygKnhtJ6C7iYN6eGvDwxWa90wwS/I7Pp
# bixdkNx54ARJPIaLpajKNVjySKGCDX0wgg15BgorBgEEAYI3AwMBMYINaTCCDWUG
# CSqGSIb3DQEHAqCCDVYwgg1SAgEDMQ8wDQYJYIZIAWUDBAIBBQAwdwYLKoZIhvcN
# AQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCAzj3KN
# rvs+FYVYy/75TTTuxbkfoKK5XTV7qc+ANOgcuQIQPwqOOz3NSAC3V6ewFY2XNxgP
# MjAyMTA2MTkwNDAwNTNaoIIKNzCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA
# 8N0wDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAxMDEw
# MDAwMDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjEw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXKY2tR
# 1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj/TZq
# gfop+N0rcIXeAhjzeG28ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj
# 4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDrDo4s
# 1SPa9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDC
# m2mCtNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1JhL0B
# AgMBAAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATApMCcG
# CCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgw
# FoAU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwoLR1E
# Nt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9zaGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdpY2Vy
# dC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURU
# aW1lc3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrn
# IA6OZ0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQCZk3t
# aaQP9rhwz2Lo9VFKeHk2eie38+dSn5On7UOee+e03UEiifuHokYDTvz0/rdkd2Nf
# I1Jpg4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO+MDh
# XM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j1h9b
# m/cuG08THfdKDXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5Npjhyyja
# W4emii8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHkBdo2l8IVMA0GCSqGSIb3DQEB
# CwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQg
# SUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0zMTAxMDcxMjAwMDBaMHIxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBU
# aW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9
# 0DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5fU1ofue2oPSNs4jkl79jIZCY
# vxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb6+NGRwYaVX4LJ37AovWg4N4i
# Pw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU46gJcWvgzyIQD3XPcXJOCq3f
# QDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mIUF79Zm5WYScpiYRR5oLnRlD9
# lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfxFwbvPc3WTe8GQv2iUypPhR3E
# HTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAdBgNVHQ4EFgQU9LbhIB3+Ka7S
# 5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wEgYD
# VR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4
# oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkwRzA4BgpghkgBhv1sAAIEMCow
# KAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJYIZI
# AYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLpUYdWac3v3dp8qmN6s3jPBjdA
# hO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4
# stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC4HLHmNY8ZOUfSBAYX4k4YU1i
# RiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+tpJn+1Nhiaj1a5bA9FhpDXzI
# AbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6HUSHkWGCbugwtK22ixH67xCUr
# RwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIvIjayS6JKldj1po5SMYIChjCC
# AoICAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hB
# MiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TAN
# BglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJ
# KoZIhvcNAQkFMQ8XDTIxMDYxOTA0MDA1M1owKwYLKoZIhvcNAQkQAgwxHDAaMBgw
# FgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJKoZIhvcNAQkEMSIEID5zZ5f2MsVI
# aGXD6MucFupxtBVEcOSU4o4p+njMNLx/MDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIE
# ILMQkAa8CtmDB5FXKeBEA0Fcg+MpK2FPJpZMjTVx7PWpMA0GCSqGSIb3DQEBAQUA
# BIIBAKqJxd158MXTqNhYux6VTiBPCmdRR6bdshoNJiyFwJSw9NIhIteL6gOVAGcU
# kSOXsF5ULPBSmZGYhtd1Dy0Xa8g/ZgJDR0Li2u10so89byv6oz59GxlH1X6q+5kg
# 2tnenQJENlLb4dvmiLStb29qObhRHH2t8y7iR0rarOXlKvTWVMogR0pxO8MPwUCn
# 3gaQkfa0jCNWzemrEu0bqLpXObS+mLM7OybHtQ+svHfQoBv/dbNyJ71Uw3j+qSM4
# pSRkLl5FYwrH186DjHi2uw84VLrFnuQueSN3Z+S25znhGCONmMDtywxe1Fnh8NX3
# L4RY6OY/XU6G954KwJbfZFPwLZA=
# SIG # End signature block
