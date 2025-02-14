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
.PARAMETER EventTypes
	Dispays only the eventypes that are specified from the following selections; 'New','Acknowledged','Fixed','All','Service'
	The Default selection is new, but this allows you to override this default behaviour.
.PARAMETER Detailed
	Specifies that detailed information is displayed. Cannot be specified
	with the -oneline option.
.PARAMETER Oneline
	Specifies that summary information is displayed in a tabular form with one line per alert. For customer alerts, the message text will be
	truncated if it is too long unless the -wide option is also specified.
.PARAMETER Wide
	Do not truncate the message text. Only valid for customer alerts and if the -oneline option is also specified.
.EXAMPLE
	PS:> Get-A9Alert -EventTypes New
.EXAMPLE
	PS:> Get-A9Alert -EventTypes Acknowledged
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]							
			[ValidateSet('New','Acknowledged','Fixed','All','Service')]
												[string]	$EventTypes,
		[Parameter()]							[switch]	$Detailed,
		[Parameter()]							[switch]	$Oneline,
		[Parameter()]							[switch]	$Wide
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showalert "
	switch($EventTypes)
		{	'New'			{	$Cmd += " -n " 		}
			'Acknowledged'	{	$Cmd += " -a " 		}
			'Fixed'			{	$Cmd += " -f " 		}
			'All'			{	$Cmd += " -all " 	}
			'Service'		{	$Cmd += " -svc " 	}
		}
	if($Detailed) 		{	$Cmd += " -d " 		}
	if($Wide)			{	$Cmd += " -wide " 	}
	if($Oneline)		{	$Cmd += " -oneline "}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
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
.PARAMETER Minutes
	Specifies that only events occurring within the specified number of minutes are shown. The <number> is an integer from 1 through 2147483647.
.PARAMETER Detailed
	Specifies that detailed information is displayed.
.PARAMETER StartTime
	Specifies that only events after a specified time are to be shown. The time argument can be specified as either <timespec>, <datespec>, or
	both. If you would like to specify both a <timespec> and <datespec>, you must place quotation marks around them; for example, -startt "2012-10-29 00:00".
		<timespec> Specified as the hour (hh), as interpreted on a 24 hour clock, where minutes (mm) and seconds (ss) can be optionally specified. Acceptable formats are hh:mm:ss or hhmm.
		<datespec> Specified as the month (mm or month_name) and day (dd), where the year (yy) can be optionally specified. Acceptable formats are
					mm/dd/yy, month_name dd, dd month_name yy, or yy-mm-dd. If the syntax yy-mm-dd is used, the year must be specified.
.PARAMETER EndTime
	Specifies that only events before a specified time are to be shown. The time argument can be specified as either <timespec>, <datespec>, or both.
	See -startt for descriptions of <timespec> and <datespec>.

	The <pattern> argument in the following options is a regular expression pattern that is used to match against the events each option produces. (See help on sub,regexpat.)

	For each option, the pattern argument can be specified multiple times by repeating the option and <pattern>. For example:

	showeventlog -type Disk.* -type <tpdtcl client> -sev Major
	The "-sev Major" displays all events of severity Major and with a type that matches either the regular expression Disk.* or <tpdtcl client>.
.PARAMETER Severity
	Specifies that only events with severities that match the specified pattern(s) are displayed. The supported severities include Fatal Critical, Major, Minor, Degraded, Informational and Debug
.PARAMETER NoSevevrity
	Specifies that only events with severities that do not match the specified pattern(s) are displayed. The supported severities
	include Fatal, Critical, Major, Minor, Degraded, Informational and Debug.
.PARAMETER Class
	Specifies that only events with classes that match the specified pattern(s) are displayed.
.PARAMETER NoClass
	Specifies that only events with classes that do not match the specified pattern(s) are displayed.
.PARAMETER Node
	Specifies that only events from nodes that match the specified pattern(s) are displayed.
.PARAMETER NoNode
	Specifies that only events from nodes that do not match the specified pattern(s) are displayed.
.PARAMETER Typed
	Specifies that only events with types that match the specified pattern(s) are displayed.
.PARAMETER NoTyped
	Specifies that only events with types that do not match the specified pattern(s) are displayed.
.PARAMETER Message
	Specifies that only events, whose messages match the specified pattern(s), are displayed.
.PARAMETER NoMessage
	Specifies that only events, whose messages do not match the specified pattern(s), are displayed.
.PARAMETER Component
	Specifies that only events, whose components match the specified pattern(s), are displayed.
.PARAMETER NoComponent
	Specifies that only events, whose components do not match the specified pattern(s), are displayed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[String]	$Min,
	[Parameter()]	[switch]	$Detailed,
	[Parameter()]	[String]	$StartTime,
	[Parameter()]	[String]	$EndTime,
	[Parameter()]
		[ValidateSet('Fatal','Critical','Major','Minor','Degraded','Informational','Debug')]	
											[String]	$Severity,
	[Parameter()]	
	[ValidateSet('Fatal','Critical','Major','Minor','Degraded','Informational','Debug')]	
											[String]	$NoSevevrity,
	[Parameter()]	[String]	$Class,
	[Parameter()]	[String]	$NoClass,
	[Parameter()]	[String]	$Node,
	[Parameter()]	[String]	$NoNode,
	[Parameter()]	[String]	$Typed,
	[Parameter()]	[String]	$Notyped,
	[Parameter()]	[String]	$Message,
	[Parameter()]	[String]	$NoMessage,
	[Parameter()]	[String]	$Component,
	[Parameter()]	[String]	$NoComponent,
	[Parameter()]	[switch]	$ShowRaw
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showeventlog "
	if($Minutes)		{	$Cmd += " -min $Minutes " }
	if($Detailed)		{	$Cmd += " -d " }
	if($StartTime)		{	$Cmd += " -startt $Starttime " }
	if($EndTime)		{	$Cmd += " -endt $Endtime " }
	if($Sevevrity)		{	$Cmd += " -sev $Severity " }
	if($NoSevevrity)	{	$Cmd += " -nsev $Noseverity " }
	if($Class)			{	$Cmd += " -class $Class " }
	if($NoClass)		{	$Cmd += " -nclass $Nclass " }
	if($Node)			{	$Cmd += " -node $Node " }
	if($NoNode)			{	$Cmd += " -nnode $NoNode " }
	if($Typed)			{	$Cmd += " -type $Typed " }
	if($NoTyped)		{	$Cmd += " -ntype $NoTyped " }
	if($Message)		{	$Cmd += " -msg $Message "	}
	if($NoMessage)		{	$Cmd += " -nmsg $NoMessage " }
	if($Component)		{	$Cmd += " -comp $Component " }
	if($NoComponent)	{	$Cmd += " -ncomp $NoComponent " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
}
end
{	$RunningIndex = 0
	if ($ShowRaw) { return $Result }
	$EventList = @()
	$SingleEvent = @{}
	write-verbose "The number of lines to process = $($Result.count)"
	while($RunningIndex -lt $Result.count)
	{	if( $Result[$RunningIndex].StartsWith('Time:'))
			{	$result[$RunningIndex]
				$V = $Result[$RunningIndex].split(":")
				$SingleEvent[$V[0].trim()] = $V[1] 
			}
		elseif( $Result[$RunningIndex].trim() -ne '')
			{	$V = $Result[$RunningIndex].split(":")
				$SingleEvent[$V[0].trim()] = $V[1] 
			}
		else 
			{ 	$EventList+=$SingleEvent
				$SingleEvent=@{}
				
			}
		$RunningIndex += 1
	}
	$Result = ( $EventList | Convertto-json | convertfrom-json )
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
.PARAMETER Service
	Perform a thorough health check. This is the default option.
.PARAMETER Full
	Perform the maximum health check. This option cannot be used with the -lite option.
.PARAMETER List
	List all components that will be checked.
.PARAMETER Quiet
	Do not display which component is currently being checked. Do not display the footnote with the -list option.
.PARAMETER Detailed
	Display detailed information regarding the status of the system.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Lite')]		[switch]	$Lite,
		[Parameter(ParameterSetName='Service')]		[switch]	$Service,
		[Parameter(ParameterSetName='Full')]		[switch]	$Full,
		[Parameter()]								[switch]	$List,
		[Parameter()]								[switch]	$Quiet,
		[Parameter()]								[switch]	$Detailed,
		[Parameter(ParameterSetName='Component')]	[String]	$Component
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " checkhealth "
	if($Lite) 		{	$Cmd += " -lite " 	}
	if($Service)	{	$Cmd += " -svc "	}
	if($Full)		{	$Cmd += " -full " 	}
	if($List)		{	$Cmd += " -list " 	}
	if($Quiet)		{	$Cmd += " -quiet " 	}
	if($Detailed)	{	$Cmd += " -d " 		}
	if($Component)	{	$Cmd += " $Component "}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='All', Mandatory)]	[switch]	$All,
		[Parameter(ParameterSetName='Id',  Mandatory)]	[String]	$Alert_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " removealert "
	$Cmd += " -f "
	if($All)		{	$Cmd += " -a "	}
	if($Alert_ID)	{	$Cmd += " $Alert_ID "}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
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
.NOTES
	This command requires a SSH type connection.
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}
