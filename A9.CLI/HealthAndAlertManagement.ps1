####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9Alert
{
<#
.SYNOPSIS
	Display system alerts.
.DESCRIPTION
	The command displays the status of system alerts. When issued without options, all new customer alerts are displayed.
.EXAMPLE
	PS:> Get-A9Alert -N
.EXAMPLE
	PS:> Get-A9Alert -F
.EXAMPLE
	PS:> Get-A9Alert -All
.PARAMETER N
	Specifies that only new customer alerts are displayed. This is the default.
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
	Specifies that summary information is displayed in a tabular form with one line per alert. For customer alerts, the message text will be
	truncated if it is too long unless the -wide option is also specified.
.PARAMETER Svc
	Specifies that only service alerts are displayed. This option can only be used with the -d or -oneline formatting options.
.PARAMETER Wide
	Do not truncate the message text. Only valid for customer alerts and if the -oneline option is also specified.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$N,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$A,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$F,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$All,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$D,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Oneline,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Svc,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Wide
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showalert "
	if($N) 		{	$Cmd += " -n " 		}
	if($A) 		{	$Cmd += " -a " 		}
	if($F)		{	$Cmd += " -f " 		}
	if($All)	{	$Cmd += " -all " 	}
	if($D) 		{	$Cmd += " -d " 		}
	if($Svc)	{	$Cmd += " -svc " 	}
	if($Wide)	{	$Cmd += " -wide " 	}
	if($Oneline){	$Cmd += " -oneline "}
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9EventLog_CLI
{
<#
.SYNOPSIS
	Show the system event log.
.DESCRIPTION
	The command displays the current system event log.
.PARAMETER Min
	Specifies that only events occurring within the specified number of minutes are shown. The <number> is an integer from 1 through 2147483647.
.PARAMETER More
	Specifies that you can page through several events at a time.
.PARAMETER Oneline
	Specifies that each event is formatted as one line.
.PARAMETER D
	Specifies that detailed information is displayed.
.PARAMETER Startt
	Specifies that only events after a specified time are to be shown. The time argument can be specified as either <timespec>, <datespec>, or
	both. If you would like to specify both a <timespec> and <datespec>, you must place quotation marks around them; for example, -startt "2012-10-29 00:00".
		<timespec> Specified as the hour (hh), as interpreted on a 24 hour clock, where minutes (mm) and seconds (ss) can be optionally specified. Acceptable formats are hh:mm:ss or hhmm.
		<datespec> Specified as the month (mm or month_name) and day (dd), where the year (yy) can be optionally specified. Acceptable formats are
					mm/dd/yy, month_name dd, dd month_name yy, or yy-mm-dd. If the syntax yy-mm-dd is used, the year must be specified.
.PARAMETER Endt
	Specifies that only events before a specified time are to be shown. The time argument can be specified as either <timespec>, <datespec>, or both.
	See -startt for descriptions of <timespec> and <datespec>.

	The <pattern> argument in the following options is a regular expression pattern that is used to match against the events each option produces. (See help on sub,regexpat.)

	For each option, the pattern argument can be specified multiple times by repeating the option and <pattern>. For example:

	showeventlog -type Disk.* -type <tpdtcl client> -sev Major
	The "-sev Major" displays all events of severity Major and with a type that matches either the regular expression Disk.* or <tpdtcl client>.
.PARAMETER Sev
	Specifies that only events with severities that match the specified pattern(s) are displayed. The supported severities include Fatal Critical, Major, Minor, Degraded, Informational and Debug
.PARAMETER Nsev
	Specifies that only events with severities that do not match the specified pattern(s) are displayed. The supported severities
	include Fatal, Critical, Major, Minor, Degraded, Informational and Debug.
.PARAMETER Class
	Specifies that only events with classes that match the specified pattern(s) are displayed.
.PARAMETER Nclass
	Specifies that only events with classes that do not match the specified pattern(s) are displayed.
.PARAMETER Node
	Specifies that only events from nodes that match the specified pattern(s) are displayed.
.PARAMETER Nnode
	Specifies that only events from nodes that do not match the specified pattern(s) are displayed.
.PARAMETER Type
	Specifies that only events with types that match the specified pattern(s) are displayed.
.PARAMETER Ntype
	Specifies that only events with types that do not match the specified pattern(s) are displayed.
.PARAMETER Msg
	Specifies that only events, whose messages match the specified pattern(s), are displayed.
.PARAMETER Nmsg
	Specifies that only events, whose messages do not match the specified pattern(s), are displayed.
.PARAMETER Comp
	Specifies that only events, whose components match the specified pattern(s), are displayed.
.PARAMETER Ncomp
	Specifies that only events, whose components do not match the specified pattern(s), are displayed.
#>
[CmdletBinding()]
param(
	[Parameter(ValueFromPipeline=$true)]	[String]	$Min,
	[Parameter(ValueFromPipeline=$true)]	[switch]	$More,
	[Parameter(ValueFromPipeline=$true)]	[switch]	$Oneline,
	[Parameter(ValueFromPipeline=$true)]	[switch]	$D,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Startt,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Endt,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Sev,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Nsev,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Class,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Nclass,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Node,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Nnode,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Type,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Ntype,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Msg,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Nmsg,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Comp,
	[Parameter(ValueFromPipeline=$true)]	[String]	$Ncomp
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showeventlog "
	if($Min)	{	$Cmd += " -min $Min " }
	if($More)	{	$Cmd += " -more " }
	if($Oneline){	$Cmd += " -oneline " }
	if($D) 		{	$Cmd += " -d " }
	if($Startt)	{	$Cmd += " -startt $Startt " }
	if($Endt)	{	$Cmd += " -endt $Endt " }
	if($Sev)	{	$Cmd += " -sev $Sev " }
	if($Nsev)	{	$Cmd += " -nsev $Nsev " }
	if($Class)	{	$Cmd += " -class $Class " }
	if($Nclass)	{	$Cmd += " -nclass $Nclass " }
	if($Node)	{	$Cmd += " -node $Node " }
	if($Nnode)	{	$Cmd += " -nnode $Nnode " }
	if($Type)	{	$Cmd += " -type $Type " }
	if($Ntype)	{	$Cmd += " -ntype $Ntype " }
	if($Msg)	{	$Cmd += " -msg $Msg "	}
	if($Nmsg)	{	$Cmd += " -nmsg $Nmsg " }
	if($Comp)	{	$Cmd += " -comp $Comp " }
	if($Ncomp)	{	$Cmd += " -ncomp $Ncomp " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Get-A9Health
{
<#
.SYNOPSIS
	Check the current health of the system.
.DESCRIPTION
	The command checks the status of system hardware and software components, and reports any issues
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
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$Lite,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Svc,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Full,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$List,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Quiet,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$D,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Component
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " checkhealth "
	if($Lite) 	{	$Cmd += " -lite " 	}
	if($Svc)	{	$Cmd += " -svc "	}
	if($Full)	{	$Cmd += " -full " 	}
	if($List)	{	$Cmd += " -list " 	}
	if($Quiet)	{	$Cmd += " -quiet " 	}
	if($D)		{	$Cmd += " -d " 		}
	if($Component){	$Cmd += " $Component "}
	$Result = Invoke-CLICommand -cmds  $Cmd
Return $Result
}
}

Function Remove-A9Alerts
{
<#
.SYNOPSIS
	Remove one or more alerts.
.DESCRIPTION
	The command removes one or more alerts from the system.
.PARAMETER  Alert_ID
	Indicates a specific alert to be removed from the system. This specifier can be repeated to remove multiple alerts. If this specifier is not used, the -a option must be used.
.PARAMETER All
	Specifies all alerts from the system and prompts removal for each alert. If this option is not used, then the <alert_ID> specifier must be used.
.PARAMETER F
	Specifies that the command is forced. If this option is not used and there are alerts in the "new" state, the command requires confirmation
	before proceeding with the operation.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='All', Mandatory=$true, ValueFromPipeline=$true)]	[switch]	$All,
		[Parameter(ValueFromPipeline=$true)]											[switch]	$F,
		[Parameter(ParameterSetName='Id',  Mandatory=$true, ValueFromPipeline=$true)]	[String]	$Alert_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " removealert "
	if($F) 			{	$Cmd += " -f "	}
	if($All)		{	$Cmd += " -a "	}
	if($Alert_ID){	$Cmd += " $Alert_ID "}
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Set-A9Alert
{
<#
.SYNOPSIS
	Set the status of system alerts.
.DESCRIPTION
	The command sets the status of system alerts.
.PARAMETER Alert_ID
	Specifies that the status of a specific alert be set. This specifier can be repeated to indicate multiple specific alerts. Up to 99 alerts
	can be specified in one command. If not specified, the -a option must be specified on the command line.
.PARAMETER All
	Specifies that the status of all alerts be set. If not specified, the Alert_ID specifier must be specified.
.PARAMETER New
	Specifies that the alert(s), as indicated with the <alert_ID> specifier or with option -a, be set as "New"(new), "Acknowledged"(ack), or "Fixed"(fixed).
.PARAMETER Ack
	Specifies that the alert(s), as indicated with the <alert_ID> specifier or with option -a, be set as "New"(new), "Acknowledged"(ack), or "Fixed"(fixed).
.PARAMETER Fixed
	Specifies that the alert(s), as indicated with the <alert_ID> specifier or with option -a, be set as "New"(new), "Acknowledged"(ack), or "Fixed"(fixed).
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='NewAll', Mandatory=$true)]
		[Parameter(ParameterSetName='NewId',  Mandatory=$true)]		[switch]	$New,

		[Parameter(ParameterSetName='AckAll', Mandatory=$true)]
		[Parameter(ParameterSetName='AckId',  Mandatory=$true)]		[switch]	$Ack,

		[Parameter(ParameterSetName='FixAll', Mandatory=$true)]	
		[Parameter(ParameterSetName='FixId',  Mandatory=$true)]		[switch]	$Fixed,

		[Parameter(ParameterSetName='NewAll', Mandatory=$true)]
		[Parameter(ParameterSetName='AckAll', Mandatory=$true)]
		[Parameter(ParameterSetName='FixAll', Mandatory=$true)]		[switch]	$All,

		[Parameter(ParameterSetName='NewId',  Mandatory=$true)]		
		[Parameter(ParameterSetName='AckId',  Mandatory=$true)]		
		[Parameter(ParameterSetName='FixId',  Mandatory=$true)]		[int]		$Alert_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " setalert "
	if($New) 		{	$Cmd += " new " }
	if($Ack) 		{	$Cmd += " ack " }
	if($Fixed)		{	$Cmd += " fixed " }
	if($All)		{	$Cmd += " -a " }
	if($Alert_ID){	$Cmd += " $Alert_ID " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}
