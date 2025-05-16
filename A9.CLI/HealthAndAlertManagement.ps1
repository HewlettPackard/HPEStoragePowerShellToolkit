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

# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBAu2teAL1c
# qVsYyFPvj5DwgFMzNHWwcVuSdrVZALwQ6IfAsITfdtb4foTLktTZXr6uDFhnJQ7M
# fOp1uEp5QCFKoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG58wghubAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQB9L/33TPK5gp2K2Aoc8wdGMHBhYylB7oV8Uhe9UgGKmMqj5VzkRqlKP
# kfSdWsMJznwmX96ALo4pt0vCXy1inJAwDQYJKoZIhvcNAQEBBQAEggGALS7j61dW
# RCjbWdTA8l9GSDweJb9DZZ3N4UuG0HQi3Sj0MluodlMyBOr3duFGTzJkZI76aUU3
# +HKpSA/7vzrZfF6sdHQNy1QrBOHxhMjJ3fkl+tT/BVmLCKItsYCGKVgje/SLaKFb
# +DPBHYg8+VqCh8bmDlD2Ujq7zqFApsYIWMEKHiuDYl3uar8qJR49l9voKYQfCbpS
# TlTFwvFVLopVPJuLPLNGE7Gd6/ls4hcI2fAkAnVZhm54bF3tKJ996encluKWQMNs
# 7lh/4Zb17oWb5GjGH3HCUjj1H1jr3Q2HBUU16+3zosMRGR0vjJkhxuHN8/Hj+p0G
# +9kHBhXPpEkheEI5wbc6ysyfp+Vcv0bpW9Wlb/4w15vZ1NPLdxLuAGU8L3Zd6TQB
# uPrIoSquMXkALoFH4stFiKN73zLMVXDD8MqOpwro3MAtHDJrYoxR43N3Oho9JwJR
# 8g+7TLynISmckHjecjCyoMWk/TVxkz/QP8vomVgvKebRTQNUgn08P1OroYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMJJ8AW61Dt9YF/jCWPcm9g0AJIUIUQPs
# EVGMRw3P5ZdxFPnk2nEc3OWkiL01jJQljwIUReCzKTinPJweQlmhpd734NedHHsY
# DzIwMjUwNTE1MDIxODI3WqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
# c3QgWW9ya3NoaXJlMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMT
# J1NlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNqCCEwQwggZi
# MIIEyqADAgECAhEApCk7bh7d16c0CIetek63JDANBgkqhkiG9w0BAQwFADBVMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNTAzMjcwMDAw
# MDBaFw0zNjAzMjEyMzU5NTlaMHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5XZXN0
# IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzYwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDThJX0bqRTePI9EEt4Egc83JSBU2dhrJ+w
# Y7JgReuff5KQNhMuzVytzD+iXazATVPMHZpH/kkiMo1/vlAGFrYN2P7g0Q8oPEcR
# 3h0SftFNYxxMh+bj3ZNbbYjwt8f4DsSHPT+xp9zoFuw0HOMdO3sWeA1+F8mhg6uS
# 6BJpPwXQjNSHpVTCgd1gOmKWf12HSfSbnjl3kDm0kP3aIUAhsodBYZsJA1imWqkA
# VqwcGfvs6pbfs/0GE4BJ2aOnciKNiIV1wDRZAh7rS/O+uTQcb6JVzBVmPP63k5xc
# ZNzGo4DOTV+sM1nVrDycWEYS8bSS0lCSeclkTcPjQah9Xs7xbOBoCdmahSfg8Km8
# ffq8PhdoAXYKOI+wlaJj+PbEuwm6rHcm24jhqQfQyYbOUFTKWFe901VdyMC4gRwR
# Aq04FH2VTjBdCkhKts5Py7H73obMGrxN1uGgVyZho4FkqXA8/uk6nkzPH9QyHIED
# 3c9CGIJ098hU4Ig2xRjhTbengoncXUeo/cfpKXDeUcAKcuKUYRNdGDlf8WnwbyqU
# blj4zj1kQZSnZud5EtmjIdPLKce8UhKl5+EEJXQp1Fkc9y5Ivk4AZacGMCVG0e+w
# wGsjcAADRO7Wga89r/jJ56IDK773LdIsL3yANVvJKdeeS6OOEiH6hpq2yT+jJ/lH
# a9zEdqFqMwIDAQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNh
# lxmiMpswHQYDVR0OBBYEFIhhjKEqN2SBKGChmzHQjP0sAs5PMA4GA1UdDwEB/wQE
# AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1Ud
# IARDMEEwNQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8v
# Y3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5j
# cmwwegYIKwYBBQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYB
# BQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IB
# gQACgT6khnJRIfllqS49Uorh5ZvMSxNEk4SNsi7qvu+bNdcuknHgXIaZyqcVmhrV
# 3PHcmtQKt0blv/8t8DE4bL0+H0m2tgKElpUeu6wOH02BjCIYM6HLInbNHLf6R2qH
# C1SUsJ02MWNqRNIT6GQL0Xm3LW7E6hDZmR8jlYzhZcDdkdw0cHhXjbOLsmTeS0Se
# RJ1WJXEzqt25dbSOaaK7vVmkEVkOHsp16ez49Bc+Ayq/Oh2BAkSTFog43ldEKgHE
# DBbCIyba2E8O5lPNan+BQXOLuLMKYS3ikTcp/Qw63dxyDCfgqXYUhxBpXnmeSO/W
# A4NwdwP35lWNhmjIpNVZvhWoxDL+PxDdpph3+M5DroWGTc1ZuDa1iXmOFAK4iwTn
# lWDg3QNRsRa9cnG3FBBpVHnHOEQj4GMkrOHdNDTbonEeGvZ+4nSZXrwCW4Wv2qyG
# DBLlKk3kUW1pIScDCpm/chL6aUbnSsrtbepdtbCLiGanKVR/KC1gsR0tC6Q0RfWO
# I4owggYUMIID/KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUA
# MFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNV
# BAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AM2Y2ENBq26CK+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStS
# VjeYXIjfa3ajoW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQ
# BaCxpectRGhhnOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE
# 9cbY11XxM2AVZn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExS
# Lnh+va8WxTlA+uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OII
# q/fWlwBp6KNL19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGd
# F+z+Gyn9/CRezKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w
# 76kOLIaFVhf5sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4Cllg
# rwIDAQABo4IBXDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUw
# HQYDVR0OBBYEFF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjAS
# BgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28u
# Y29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEF
# BQcBAQRwMG4wRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0O
# NVgMnoEdJVj9TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc
# 6ZvIyHI5UkPCbXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1
# OSkkSivt51UlmJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz
# 2wSKr+nDO+Db8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y
# 4Il6ajTqV2ifikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVM
# CMPY2752LmESsRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBe
# Nh9AQO1gQrnh1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupia
# AeNHe0pWSGH2opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU
# +CCQaL0cJqlmnx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/Sjws
# usWRItFA3DE8MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7
# xpMeYRriWklUPsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs6
# 56Oz3TbLyXVoMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAs
# BgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJ
# BZvMWhUP2ZQQRLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQn
# Oh2qmcxGzjqemIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypo
# GJrruH/drCio28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0p
# KG9ki+PC6VEfzutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13j
# QEV1JnUTCm511n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9
# YrcmXcLgsrAimfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/y
# Vl4jnDcw6ULJsBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVg
# h60KmLmzXiqJc6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/
# OLoanEWP6Y52Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+Nr
# LedIxsE88WzKXqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58N
# Hs57ZPUfECcgJC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9U
# gOHYm8Cd8rIDZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1Ud
# DwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0
# eS5jcmwwNQYIKwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3
# OyWM637ayBeR7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJ
# JlFfym1Doi+4PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0m
# UGQHbRcF57olpfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTw
# bD/zIExAopoe3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i
# 111TW7HV1AtsQa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGe
# zjM6CRpcWed/ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+
# 8aW88WThRpv8lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH
# 29308ZkpKKdpkiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrs
# xrYJD+3f3aKg6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6
# Ii8+CQOYDwXM+yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz
# 7NgAnOgpCdUo4uDyllU9PzGCBJIwggSOAgEBMGowVTELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMg
# VGltZSBTdGFtcGluZyBDQSBSMzYCEQCkKTtuHt3XpzQIh616TrckMA0GCWCGSAFl
# AwQCAgUAoIIB+TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTI1MDUxNTAyMTgyN1owPwYJKoZIhvcNAQkEMTIEMLyiojVYBy4XjDKg
# 8JYNp+IMWeVFL6QGizG2UEbPmj++CBqxOrD+hOzVQImYYoWPeDCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAPl6zvJesTFGst1HuGT8VGXeYeDHfW/ffXe+oN6Jb7B7Rz1dhJKe27Ygm
# FVjt4qtByA0Gk9SklpbIp/gvB/L7HPQQPvizI5RhQjSCP4RuWLJVH4r7M8xfdQ7p
# gPGoBkMiHUVvo+rASDhkKvGVlRj0zQzsF3YeVhZeP6E5JnpNLYnY0S7qKUvY7Vza
# 2Dd373FwpiQQVYn+EfLGNDswdZFmZCPuou2L11bqQb8DfNO3UhvbpbRh1IuPRq/e
# d6CL9qpcxRCRhSN/o9NbVWIWeOjBWYhWFVmXE7Ss83Ww7Ekjnlm25Nv55/g56Ava
# hJ3cWcCIOoRATV8m66dGA0qaZZ2/d6Y9gqk+IygLQjQ9clPvTCwsQjh4z/hTSPNk
# PENKPDQ6/W8gumJC+uo6ffkrSXMVewrz74Xo9OBcWdMvD9uKfmkjX+PJGt+TSSPz
# 09z5muaYDeh9DIEG4HRoVo/NBRr0Ptg35DAk9wPmb8cG7SwfmW5v4ErvXlWRBvfB
# epzOK2dUlYpk0DgzyBi9gQHVKxoc2E1XyrVzXS1MzSkEdA+j2Cj1U/owroFmXYhc
# MdhbVvxAuaSugkXTEAQ5Oo/b2lCx2HTGA8pAbOfvffX5bmn+r2lzFFwNQcLFeHS0
# Yj717OUUl4bT6nN76LzYsRUFFaYXLAxgIhyIQF9tyHPhYaOC6gE=
# SIG # End signature block
