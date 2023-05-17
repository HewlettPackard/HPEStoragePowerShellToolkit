####################################################################################
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
##	File Name:		HealthandAlertManagement.psm1
##	Description: 	Health and Alert Management cmdlets 
##		
##	Created:		November 2019
##	Last Modified:	November 2019
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
######################### FUNCTION Get-Alert #########################
##########################################################################
Function Get-Alert()
{
<#
  .SYNOPSIS
   Get-Alert - Display system alerts.

  .DESCRIPTION
   The Get-Alert command displays the status of system alerts. When issued
   without options, all new customer alerts are displayed.

  .EXAMPLE
   Get-Alert -N
   
  .EXAMPLE
   Get-Alert -F
   
  .EXAMPLE
   Get-Alert -All
   
  .PARAMETER N
   Specifies that only new customer alerts are displayed.
   This is the default.

  .PARAMETER A
   Specifies that only acknowledged alerts are displayed.

  .PARAMETER F
   Specifies that only fixed alerts are displayed.

  .PARAMETER All
   Specifies that all customer alerts are displayed.
   
   
   The format of the alert display is controlled by the following options:

  .PARAMETER D
   Specifies that detailed information is displayed. Cannot be specified
   with the -oneline option.

  .PARAMETER Oneline
   Specifies that summary information is displayed in a tabular form with
   one line per alert. For customer alerts, the message text will be
   truncated if it is too long unless the -wide option is also specified.

  .PARAMETER Svc
   Specifies that only service alerts are displayed. This option can only be
   used with the -d or -oneline formatting options.

  .PARAMETER Wide
   Do not truncate the message text. Only valid for customer alerts and if the -oneline option is also specified.

  .Notes
    NAME: Get-Alert
    LASTEDIT 19/11/2019
    KEYWORDS: Get-Alert
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$N,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$A,

	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$F,

	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$All,

	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$D,

	[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Oneline,

	[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Svc,

	[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Wide,

	[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Get-Alert - validating input values" $Debug 
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
			Write-DebugLog "Stop: Exiting Get-Alert since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Get-Alert since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

	$Cmd = " showalert "

 if($N)
 {
	$Cmd += " -n "
 }

 if($A)
 {
	$Cmd += " -a "
 }

 if($F)
 {
	$Cmd += " -f "
 }

 if($All)
 {
	$Cmd += " -all "
 }

 if($D)
 {
	$Cmd += " -d "
 }

 if($Svc)
 {
	$Cmd += " -svc "
 }

 if($Wide)
 {
	$Cmd += " -wide "
 }

 if($Oneline)
 {
	$Cmd += " -oneline "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Get-Alert Command -->" INFO: 
 
 Return $Result
} ##  End-of Get-Alert

##########################################################################
######################### FUNCTION Get-EventLog ##########################
##########################################################################
Function Get-EventLog()
{
<#
  .SYNOPSIS
   Get-EventLog - Show the system event log.

  .DESCRIPTION
   The Get-EventLog command displays the current system event log.

  .EXAMPLE

  .PARAMETER Min
   Specifies that only events occurring within the specified number of
   minutes are shown. The <number> is an integer from 1 through 2147483647.

  .PARAMETER More
   Specifies that you can page through several events at a time.

  .PARAMETER Oneline
   Specifies that each event is formatted as one line.

  .PARAMETER D
   Specifies that detailed information is displayed.

  .PARAMETER Startt
   Specifies that only events after a specified time are to be shown. The
   time argument can be specified as either <timespec>, <datespec>, or
   both. If you would like to specify both a <timespec> and <datespec>, you must
   place quotation marks around them; for example, -startt "2012-10-29 00:00".
	   <timespec>
	   Specified as the hour (hh), as interpreted on a 24 hour clock, where
	   minutes (mm) and seconds (ss) can be optionally specified.
	   Acceptable formats are hh:mm:ss or hhmm.
	   <datespec>
	   Specified as the month (mm or month_name) and day (dd), where the
	   year (yy) can be optionally specified. Acceptable formats are
	   mm/dd/yy, month_name dd, dd month_name yy, or yy-mm-dd. If the
	   syntax yy-mm-dd is used, the year must be specified.

  .PARAMETER Endt
   Specifies that only events before a specified time are to be shown. The
   time argument can be specified as either <timespec>, <datespec>, or both.
   See -startt for descriptions of <timespec> and <datespec>.
   
   
   The <pattern> argument in the following options is a regular expression pattern that is used
   to match against the events each option produces.
   (See help on sub,regexpat.)
   
   For each option, the pattern argument can be specified multiple times by repeating the option
   and <pattern>. For example:
   
   showeventlog -type Disk.* -type <tpdtcl client> -sev Major
   The "-sev Major" displays all events of severity Major and with a type that matches either
   the regular expression Disk.* or <tpdtcl client>.

  .PARAMETER Sev
   Specifies that only events with severities that match the specified
   pattern(s) are displayed. The supported severities include Fatal,
   Critical, Major, Minor, Degraded, Informational and Debug

  .PARAMETER Nsev
   Specifies that only events with severities that do not match the
   specified pattern(s) are displayed. The supported severities
   include Fatal, Critical, Major, Minor, Degraded, Informational and
   Debug.

  .PARAMETER Class
   Specifies that only events with classes that match the specified
   pattern(s) are displayed.

  .PARAMETER Nclass
   Specifies that only events with classes that do not match the specified
   pattern(s) are displayed.

  .PARAMETER Node
   Specifies that only events from nodes that match the specified
   pattern(s) are displayed.

  .PARAMETER Nnode
   Specifies that only events from nodes that do not match the specified
   pattern(s) are displayed.

  .PARAMETER Type
   Specifies that only events with types that match the specified
   pattern(s) are displayed.

  .PARAMETER Ntype
   Specifies that only events with types that do not match the specified
   pattern(s) are displayed.

  .PARAMETER Msg
   Specifies that only events, whose messages match the specified
   pattern(s), are displayed.

  .PARAMETER Nmsg
   Specifies that only events, whose messages do not match the specified
   pattern(s), are displayed.

  .PARAMETER Comp
   Specifies that only events, whose components match the specified
   pattern(s), are displayed.

  .PARAMETER Ncomp
   Specifies that only events, whose components do not match the specified
   pattern(s), are displayed.

  .Notes
    NAME: Get-EventLog
    LASTEDIT 19/11/2019
    KEYWORDS: Get-EventLog
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Min,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$More,

	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Oneline,

	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$D,

	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Startt,

	[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Endt,

	[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Sev,

	[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Nsev,

	[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Class,

	[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Nclass,

	[Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Node,

	[Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Nnode,

	[Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Type,

	[Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Ntype,

	[Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Msg,

	[Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Nmsg,

	[Parameter(Position=16, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Comp,

	[Parameter(Position=17, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Ncomp,

	[Parameter(Position=18, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Get-EventLog - validating input values" $Debug 
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
			Write-DebugLog "Stop: Exiting Get-EventLog since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Get-EventLog since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " showeventlog "

 if($Min)
 {
	$Cmd += " -min $Min "
 }

 if($More)
 {
	$Cmd += " -more "
 }

 if($Oneline)
 {
	$Cmd += " -oneline "
 }

 if($D)
 {
	$Cmd += " -d "
 }

 if($Startt)
 {
	$Cmd += " -startt $Startt "
 }

 if($Endt)
 {
	$Cmd += " -endt $Endt "
 }

 if($Sev)
 {
	$Cmd += " -sev $Sev "
 }

 if($Nsev)
 {
	$Cmd += " -nsev $Nsev "
 }

 if($Class)
 {
	$Cmd += " -class $Class "
 }

 if($Nclass)
 {
	$Cmd += " -nclass $Nclass "
 }

 if($Node)
 {
	$Cmd += " -node $Node "
 }

 if($Nnode)
 {
	$Cmd += " -nnode $Nnode "
 }

 if($Type)
 {
	$Cmd += " -type $Type "
 }

 if($Ntype)
 {
	$Cmd += " -ntype $Ntype "
 }

 if($Msg)
 {
	$Cmd += " -msg $Msg "
 }

 if($Nmsg)
 {
	$Cmd += " -nmsg $Nmsg "
 }

 if($Comp)
 {
	$Cmd += " -comp $Comp "
 }

 if($Ncomp)
 {
	$Cmd += " -ncomp $Ncomp "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Get-EventLog Command -->" INFO: 
 
 Return $Result
} ##  End-of Get-EventLog

##########################################################################
############################ FUNCTION Get-Health #########################
##########################################################################
Function Get-Health()
{
<#
  .SYNOPSIS
   Get-Health - Check the current health of the system.

  .DESCRIPTION
   The Get-Health command checks the status of system hardware and software components, and reports any issues

  .EXAMPLE
  
  .PARAMETER Component
	Indicates the component to check. Use -list option to get the list of components.
	
  .PARAMETER Lite
   Perform a minimal health check.

  .PARAMETER Svc
   Perform a thorough health check. This is the default option.

  .PARAMETER Full
   Perform the maximum health check. This option cannot be used with the -lite option.

  .PARAMETER List
   List all components that will be checked.

  .PARAMETER Quiet
   Do not display which component is currently being checked. Do not display the footnote with the -list option.

  .PARAMETER D
   Display detailed information regarding the status of the system.

  .Notes
    NAME: Get-Health
    LASTEDIT 19/11/2019
    KEYWORDS: Get-Health
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Lite,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Svc,

	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Full,

	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$List,

	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Quiet,

	[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$D,

	[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Component,

	[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Get-Health - validating input values" $Debug 
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
			Write-DebugLog "Stop: Exiting Get-Health since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Get-Health since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

	$Cmd = " checkhealth "

 if($Lite)
 {
	$Cmd += " -lite "
 }

 if($Svc)
 {
	$Cmd += " -svc "
 }

 if($Full)
 {
	$Cmd += " -full "
 }

 if($List)
 {
	$Cmd += " -list "
 }

 if($Quiet)
 {
	$Cmd += " -quiet "
 }

 if($D)
 {
	$Cmd += " -d "
 }

 if($Component)
 {
	$Cmd += " $Component "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Get-Health Command -->" INFO: 
 
 Return $Result
} ##  End-of Get-Health

##########################################################################
######################### FUNCTION Remove-Alerts #########################
##########################################################################
Function Remove-Alerts()
{
<#
  .SYNOPSIS
   Remove-Alerts - Remove one or more alerts.

  .DESCRIPTION
   The Remove-Alerts command removes one or more alerts from the system.

  .EXAMPLE

  .PARAMETER  Alert_ID
	Indicates a specific alert to be removed from the system. This specifier can be repeated to remove multiple alerts. If this specifier is not used, the -a option must be used.
  
  .PARAMETER All
   Specifies all alerts from the system and prompts removal for each alert.
   If this option is not used, then the <alert_ID> specifier must be used.

  .PARAMETER F
   Specifies that the command is forced. If this option is not used and
   there are alerts in the "new" state, the command requires confirmation
   before proceeding with the operation.

  .Notes
    NAME: Remove-Alerts
    LASTEDIT 19/11/2019
    KEYWORDS: Remove-Alerts
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$All,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$F,

	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Alert_ID,

	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Remove-Alerts - validating input values" $Debug 
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
			Write-DebugLog "Stop: Exiting Remove-Alerts since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Remove-Alerts since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

	$Cmd = " removealert "

 if($F)
 {
	$Cmd += " -f "
 }
 
 if($All)
 {
	$Cmd += " -a "
 }
 elseif($Alert_ID)
 {
	$Cmd += " $Alert_ID "
 }
 else
 {
	Return "Please Select At-least One from [ All | Alert_ID ]..."
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Remove-Alerts Command -->" INFO: 
 
 Return $Result
 
} ##  End-of Remove-Alerts

##########################################################################
######################### FUNCTION Set-Alert #########################
##########################################################################
Function Set-Alert()
{
<#
  .SYNOPSIS
   Set-Alert - Set the status of system alerts.

  .DESCRIPTION
   The Set-Alert command sets the status of system alerts.

  .EXAMPLE

  .PARAMETER Alert_ID
	Specifies that the status of a specific alert be set. This specifier
	can be repeated to indicate multiple specific alerts. Up to 99 alerts
	can be specified in one command. If not specified, the -a option must
	be specified on the command line.
  
  .PARAMETER All
   Specifies that the status of all alerts be set. If not specified, the Alert_ID specifier must be specified.

  .PARAMETER New
	Specifies that the alert(s), as indicated with the <alert_ID> specifier
	or with option -a, be set as "New"(new), "Acknowledged"(ack), or
	"Fixed"(fixed).

  .PARAMETER Ack
	Specifies that the alert(s), as indicated with the <alert_ID> specifier
	or with option -a, be set as "New"(new), "Acknowledged"(ack), or
	"Fixed"(fixed).

  .PARAMETER Fixed
	Specifies that the alert(s), as indicated with the <alert_ID> specifier
	or with option -a, be set as "New"(new), "Acknowledged"(ack), or
	"Fixed"(fixed).

   
  .Notes
    NAME: Set-Alert
    LASTEDIT 19/11/2019
    KEYWORDS: Set-Alert
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
 
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$New,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Ack,

	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Fixed,

	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$All,

	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Alert_ID,

	[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Set-Alert - validating input values" $Debug 
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
			Write-DebugLog "Stop: Exiting Set-Alert since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Set-Alert since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

	$Cmd = " setalert "

 if($New)
 {
	$Cmd += " new "
 }
 elseif($Ack)
 {
	$Cmd += " ack "
 }
 elseif($Fixed)
 {
	$Cmd += " fixed "
 }
 else
 {
	Return "Please Select At-least One from [ New | Ack | Fixed ]..." 
 }

 if($All)
 {
	$Cmd += " -a "
 }
 elseif($Alert_ID)
 {
	$Cmd += " $Alert_ID "
 }
 else
 {
	Return "Please Select At-least One from [ All | Alert_ID ]..." 
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Set-Alert Command -->" INFO: 
 
 Return $Result
} ##  End-of Set-Alert

Export-ModuleMember Get-Alert , Get-EventLog , Get-Health , Remove-Alerts , Set-Alert
# SIG # Begin signature block
# MIIhzwYJKoZIhvcNAQcCoIIhwDCCIbwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAmwAnT2lGgd4w3
# rvMoPtyE3mtvg8eHhD5hToJWG8tcUKCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIQejCCEHYCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# YBMJHDcnOr8ubLF50k3TUb+pbYHvUDAIkHQL0LENnsMwDQYJKoZIhvcNAQEBBQAE
# ggEAMKHH0LwsdZvREu3Oz9zy6xFC/KLSRiV7pJUsNE0dkE2v3Hl4HuCj45VuoAbz
# +WU3SUNRMQxeZxLUVFntAaj4AMwTPZGP8RQVZ2qvCI/ulmoY5hbSu0hqFJMG3so+
# vP1uABdtwxNvo0fzE6z5fbxNdp35s9ptv7N/ljUzbgO9aTpeSJ/h5WWQJ0KI4th3
# 6rRuzSbdI0vEyZTzFBmADRokJo8xNDV+oV0JUHoJX6wPsNtnqQM0y592VQmrC5+R
# jSzjvgmYqXsDo1d6F8UUriauJ1orxbosIErEQUx1LpqLQCxTwnQL58dwWJtLS+iN
# 1wRag+f3kIJS+mWxwOZC/4Z05aGCDjwwgg44BgorBgEEAYI3AwMBMYIOKDCCDiQG
# CSqGSIb3DQEHAqCCDhUwgg4RAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDgYLKoZIhvcN
# AQkQAQSggf4EgfswgfgCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# ILRa0Vapw6SYc2HQTPHQAU+zaQTrSZMqBw92Zk2M7V7VAhRMk3TG/tbqJKIVtpIc
# Ljgklzx7mBgPMjAyMTA2MTkwNDA5MzBaMAMCAR6ggYakgYMwgYAxCzAJBgNVBAYT
# AlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3lt
# YW50ZWMgVHJ1c3QgTmV0d29yazExMC8GA1UEAxMoU3ltYW50ZWMgU0hBMjU2IFRp
# bWVTdGFtcGluZyBTaWduZXIgLSBHM6CCCoswggU4MIIEIKADAgECAhB7BbHUSWhR
# RPfJidKcGZ0SMA0GCSqGSIb3DQEBCwUAMIG9MQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdv
# cmsxOjA4BgNVBAsTMShjKSAyMDA4IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhv
# cml6ZWQgdXNlIG9ubHkxODA2BgNVBAMTL1ZlcmlTaWduIFVuaXZlcnNhbCBSb290
# IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE2MDExMjAwMDAwMFoXDTMxMDEx
# MTIzNTk1OVowdzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBv
# cmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMSgwJgYDVQQD
# Ex9TeW1hbnRlYyBTSEEyNTYgVGltZVN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAu1mdWVVPnYxyXRqBoutV87ABrTxxrDKPBWuGmicA
# MpdqTclkFEspu8LZKbku7GOz4c8/C1aQ+GIbfuumB+Lef15tQDjUkQbnQXx5HMvL
# rRu/2JWR8/DubPitljkuf8EnuHg5xYSl7e2vh47Ojcdt6tKYtTofHjmdw/SaqPSE
# 4cTRfHHGBim0P+SDDSbDewg+TfkKtzNJ/8o71PWym0vhiJka9cDpMxTW38eA25Hu
# /rySV3J39M2ozP4J9ZM3vpWIasXc9LFL1M7oCZFftYR5NYp4rBkyjyPBMkEbWQ6p
# PrHM+dYr77fY5NUdbRE6kvaTyZzjSO67Uw7UNpeGeMWhNwIDAQABo4IBdzCCAXMw
# DgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwZgYDVR0gBF8wXTBb
# BgtghkgBhvhFAQcXAzBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Quc3ltY2IuY29t
# L2NwczAlBggrBgEFBQcCAjAZGhdodHRwczovL2Quc3ltY2IuY29tL3JwYTAuBggr
# BgEFBQcBAQQiMCAwHgYIKwYBBQUHMAGGEmh0dHA6Ly9zLnN5bWNkLmNvbTA2BgNV
# HR8ELzAtMCugKaAnhiVodHRwOi8vcy5zeW1jYi5jb20vdW5pdmVyc2FsLXJvb3Qu
# Y3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMIMCgGA1UdEQQhMB+kHTAbMRkwFwYDVQQD
# ExBUaW1lU3RhbXAtMjA0OC0zMB0GA1UdDgQWBBSvY9bKo06FcuCnvEHzKaI4f4B1
# YjAfBgNVHSMEGDAWgBS2d/ppSEefUxLVwuoHMnYH0ZcHGTANBgkqhkiG9w0BAQsF
# AAOCAQEAdeqwLdU0GVwyRf4O4dRPpnjBb9fq3dxP86HIgYj3p48V5kApreZd9KLZ
# VmSEcTAq3R5hF2YgVgaYGY1dcfL4l7wJ/RyRR8ni6I0D+8yQL9YKbE4z7Na0k8hM
# kGNIOUAhxN3WbomYPLWYl+ipBrcJyY9TV0GQL+EeTU7cyhB4bEJu8LbF+GFcUvVO
# 9muN90p6vvPN/QPX2fYDqA/jU/cKdezGdS6qZoUEmbf4Blfhxg726K/a7JsYH6q5
# 4zoAv86KlMsB257HOLsPUqvR45QDYApNoP4nbRQy/D+XQOG/mYnb5DkUvdrk08Pq
# K1qzlVhVBH3HmuwjA42FKtL/rqlhgTCCBUswggQzoAMCAQICEHvU5a+6zAc/oQEj
# BCJBTRIwDQYJKoZIhvcNAQELBQAwdzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5
# bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3
# b3JrMSgwJgYDVQQDEx9TeW1hbnRlYyBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4X
# DTE3MTIyMzAwMDAwMFoXDTI5MDMyMjIzNTk1OVowgYAxCzAJBgNVBAYTAlVTMR0w
# GwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMg
# VHJ1c3QgTmV0d29yazExMC8GA1UEAxMoU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFt
# cGluZyBTaWduZXIgLSBHMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AK8Oiqr43L9pe1QXcUcJvY08gfh0FXdnkJz93k4Cnkt29uU2PmXVJCBtMPndHYPp
# PydKM05tForkjUCNIqq+pwsb0ge2PLUaJCj4G3JRPcgJiCYIOvn6QyN1R3AMs19b
# jwgdckhXZU2vAjxA9/TdMjiTP+UspvNZI8uA3hNN+RDJqgoYbFVhV9HxAizEtavy
# bCPSnw0PGWythWJp/U6FwYpSMatb2Ml0UuNXbCK/VX9vygarP0q3InZl7Ow28paV
# gSYs/buYqgE4068lQJsJU/ApV4VYXuqFSEEhh+XetNMmsntAU1h5jlIxBk2UA0XE
# zjwD7LcA8joixbRv5e+wipsCAwEAAaOCAccwggHDMAwGA1UdEwEB/wQCMAAwZgYD
# VR0gBF8wXTBbBgtghkgBhvhFAQcXAzBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Qu
# c3ltY2IuY29tL2NwczAlBggrBgEFBQcCAjAZGhdodHRwczovL2Quc3ltY2IuY29t
# L3JwYTBABgNVHR8EOTA3MDWgM6Axhi9odHRwOi8vdHMtY3JsLndzLnN5bWFudGVj
# LmNvbS9zaGEyNTYtdHNzLWNhLmNybDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwdwYIKwYBBQUHAQEEazBpMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wOwYIKwYBBQUHMAKGL2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3NoYTI1Ni10c3MtY2EuY2VyMCgGA1UdEQQh
# MB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC02MB0GA1UdDgQWBBSlEwGp
# n4XMG24WHl87Map5NgB7HTAfBgNVHSMEGDAWgBSvY9bKo06FcuCnvEHzKaI4f4B1
# YjANBgkqhkiG9w0BAQsFAAOCAQEARp6v8LiiX6KZSM+oJ0shzbK5pnJwYy/jVSl7
# OUZO535lBliLvFeKkg0I2BC6NiT6Cnv7O9Niv0qUFeaC24pUbf8o/mfPcT/mMwnZ
# olkQ9B5K/mXM3tRr41IpdQBKK6XMy5voqU33tBdZkkHDtz+G5vbAf0Q8RlwXWuOk
# O9VpJtUhfeGAZ35irLdOLhWa5Zwjr1sR6nGpQfkNeTipoQ3PtLHaPpp6xyLFdM3f
# RwmGxPyRJbIblumFCOjd6nRgbmClVnoNyERY3Ob5SBSe5b/eAL13sZgUchQk38cR
# LB8AP8NLFMZnHMweBqOQX1xUiz7jM1uCD8W3hgJOcZ/pZkU/djGCAlowggJWAgEB
# MIGLMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlv
# bjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEoMCYGA1UEAxMfU3lt
# YW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQe9Tlr7rMBz+hASMEIkFNEjAL
# BglghkgBZQMEAgGggaQwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqG
# SIb3DQEJBTEPFw0yMTA2MTkwNDA5MzBaMC8GCSqGSIb3DQEJBDEiBCAHxs8KALwW
# ecr7szgDxfQ4orJGpHsdSSUjHM9h0eJGSTA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCDEdM52AH0COU4NpeTefBTGgPniggE8/vZT7123H99h+DALBgkqhkiG9w0BAQEE
# ggEARpw4wvZprZNHTi+M6T7k3HqU9WGmzypw/TG0XxVZgMq6I7uA65zCmVwaM0Oe
# 7Jumu6U51tZbnDGjFsQ8smKHU3t6zgClWxFp7QkcreHP+EljKcUfLko27q6LBVzC
# kSXB9v2CONLzxhPIj9DWtbU/ebIzW5LPiNFeecrmi3FaFTfHhUmGGjDi+869ITai
# ESyt1iNSXCSzojnGrCC1EuE7HT5/8v9Bw7ZSi6zZaHKaKZYt2xS8xf+SJSaGHkpg
# dChnctZU/5MRZ4NnCFBILz7MrqVopK6+yghB/N2H0OorbWIgesx47CYm8XgJzhL2
# IO0p7xfxUmCBsPPJDSMdFRq3jQ==
# SIG # End signature block
