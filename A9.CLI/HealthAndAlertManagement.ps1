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
.NOTES
	This command requires a SSH type connection.
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
.NOTES
	This command requires a SSH type connection.
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
	$Result = Invoke-A9CLICommand -cmds  $Cmd
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
.NOTES
	This command requires a SSH type connection.
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
.PARAMETER F
	Specifies that the command is forced. If this option is not used and there are alerts in the "new" state, the command requires confirmation
	before proceeding with the operation.
.NOTES
	This command requires a SSH type connection.
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
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

# SIG # Begin signature block
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEC5ehi4mqjT
# QEOIo4ZA9WOwr9PoEouUINfaUNlybp3CPSaQs3g3SiVQGSP6L1GXtIKBQspPzm95
# oh1RWf3ta+NZoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5UwghuRAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQM6W9jjBH3PnJwBBBElLwOLtVjtEM8GFFqSJT8CrtxRduSAmoNVQsgn5
# rP64pKmTZIpbXEmIlo2tHhb+TweFCqIwDQYJKoZIhvcNAQEBBQAEggGAbm6b0zDZ
# z5vAYqproGZniE6lP2W8CEnOezomGlM5Ajt/iqhWClCjxziDGpLG8bV3osZOFl9f
# hb1a/XrLJ9xVPfPn6PlFcH+EohTq+oRjUYtB1k8yoCJ6A+dh6/5+Yv4JYJsnXky8
# tTyMr6jXvSC3uDIFINuW7yL1bBgdp4rsOkJ/5sORF1U3FumQdbSqmw5sWyQpg8tR
# J3mhlcJc9yUp3vZ/1B9mi9EZnutdupqF8VBTqJsUAj+qbbedPj3Y+BQs/Yr1HOUd
# HrefSk8+QH0MvvylgxsvJm70zk7Rwvvo4aQkun/BJHgU7ajstWhTgq3cs2uOHXVJ
# 3SnseeI/wJA1Dn4qISr7yzvZc7ZctKRIhVAL2OviVTu+blcefG7Ok5bkbfPPXEe3
# RmVh2788bMkt7xju2kUAYG6O7GH0bgDJSnKtn1gL33n+c3BtmiEToK3RR30nlg7M
# GS+LJbH9ZTRqmVAjOtcsRPYwDOmXCONSC0aci8NIyISAtnJTU8ORBaIGoYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMLy88Zd9Y4+lMnrkTeneFue+GmqRgb/l
# 7ey6AhmC6nGRR1EjzwL9VKBLV/HKdGwhhAIUacVpBsfWRxbPkuGpNSLaaKMG7H4Y
# DzIwMjQwNzMxMTkyMTQxWqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
# bmNoZXN0ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2Vj
# dGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1oIIS/zCCBl0wggTF
# oAMCAQICEDpSaiyEzlXmHWX8zBLY6YkwDQYJKoZIhvcNAQEMBQAwVTELMAkGA1UE
# BhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGln
# byBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjQwMTE1MDAwMDAwWhcN
# MzUwNDE0MjM1OTU5WjBuMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFuY2hlc3Rl
# cjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydTZWN0aWdvIFB1
# YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzUwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN0Wf0wUibvf04STpNYYGbw9jcRaVhBDaNBp7jmJaA9dQZ
# W5ighrXGNMYjK7Dey5RIHMqLIbT9z9if753mYbojJrKWO4ZP0N5dBT2TwZZaPb8E
# +hqaDZ8Vy2c+x1NiEwbEzTrPX4W3QFq/zJvDDbWKL99qLL42GJQzX3n5wWo60Kkl
# fFn+Wb22mOZWYSqkCVGl8aYuE12SqIS4MVO4PUaxXeO+4+48YpQlNqbc/ndTgszR
# QLF4MjxDPjRDD1M9qvpLTZcTGVzxfViyIToRNxPP6DUiZDU6oXARrGwyP9aglPXw
# YbkqI2dLuf9fiIzBugCDciOly8TPDgBkJmjAfILNiGcVEzg+40xUdhxNcaC+6r0j
# uPiR7bzXHh7v/3RnlZuT3ZGstxLfmE7fRMAFwbHdDz5gtHLqjSTXDiNF58IxPtvm
# ZPG2rlc+Yq+2B8+5pY+QZn+1vEifI0MDtiA6BxxQuOnj4PnqDaK7NEKwtD1pzoA3
# jJFuoJiwbatwhDkg1PIjYnMDbDW+wAc9FtRN6pUsO405jaBgigoFZCw9hWjLNqgF
# VTo7lMb5rVjJ9aSBVVL2dcqzyFW2LdWk5Xdp65oeeOALod7YIIMv1pbqC15R7QCY
# LxcK1bCl4/HpBbdE5mjy9JR70BHuYx27n4XNOZbwrXcG3wZf9gEUk7stbPAoBQID
# AQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNhlxmiMpswHQYD
# VR0OBBYEFGjvpDJJabZSOB3qQzks9BRqngyFMA4GA1UdDwEB/wQEAwIGwDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1UdIARDMEEwNQYM
# KwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20v
# Q1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8vY3JsLnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcmwwegYIKwYB
# BQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYBBQUHMAGGF2h0
# dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IBgQCw3C7J+k82
# TIov9slP1e8YTx+fDsa//hJ62Y6SMr2E89rv82y/n8we5W6z5pfBEWozlW7nWp+s
# dPCdUTFw/YQcqvshH6b9Rvs9qZp5Z+V7nHwPTH8yzKwgKzTTG1I1XEXLAK9fHnmX
# paDeVeI8K6Lw3iznWZdLQe3zl+Rejdq5l2jU7iUfMkthfhFmi+VVYPkR/BXpV7Ub
# 1QyyWebqkjSHJHRmv3lBYbQyk08/S7TlIeOr9iQ+UN57fJg4QI0yqdn6PyiehS1n
# SgLwKRs46T8A6hXiSn/pCXaASnds0LsM5OVoKYfbgOOlWCvKfwUySWoSgrhncihS
# BXxH2pAuDV2vr8GOCEaePZc0Dy6O1rYnKjGmqm/IRNkJghSMizr1iIOPN+23futB
# XAhmx8Ji/4NTmyH9K0UvXHiuA2Pa3wZxxR9r9XeIUVb2V8glZay+2ULlc445CzCv
# VSZV01ZB6bgvCuUuBx079gCcepjnZDCcEuIC5Se4F6yFaZ8RvmiJ4hgwggYUMIID
# /KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUAMFcxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEwMzIyMDAwMDAw
# WhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAM2Y2ENBq26C
# K+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStSVjeYXIjfa3aj
# oW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQBaCxpectRGhh
# nOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE9cbY11XxM2AV
# Zn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExSLnh+va8WxTlA
# +uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OIIq/fWlwBp6KNL
# 19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGdF+z+Gyn9/CRe
# zKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w76kOLIaFVhf5
# sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4CllgrwIDAQABo4IB
# XDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUwHQYDVR0OBBYE
# FF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8E
# CDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0g
# ADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEFBQcBAQRwMG4w
# RwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1Ymxp
# Y1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2Nz
# cC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0ONVgMnoEdJVj9
# TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc6ZvIyHI5UkPC
# bXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1OSkkSivt51Ul
# mJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz2wSKr+nDO+Db
# 8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y4Il6ajTqV2if
# ikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVMCMPY2752LmES
# sRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBeNh9AQO1gQrnh
# 1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupiaAeNHe0pWSGH2
# opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU+CCQaL0cJqlm
# nx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/SjwsusWRItFA3DE8
# MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7xpMeYRriWklU
# PsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs656Oz3TbLyXVo
# MA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEpl
# cnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJV
# U1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9u
# IEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMFcxCzAJ
# BgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJBZvMWhUP2ZQQ
# RLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQnOh2qmcxGzjqe
# mIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypoGJrruH/drCio
# 28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0pKG9ki+PC6VEf
# zutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13jQEV1JnUTCm51
# 1n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9YrcmXcLgsrAi
# mfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/yVl4jnDcw6ULJ
# sBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVgh60KmLmzXiqJ
# c6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/OLoanEWP6Y52
# Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+NrLedIxsE88WzK
# XqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58NHs57ZPUfECcg
# JC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rID
# ZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1UdDwEB/wQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVz
# dC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwNQYI
# KwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3Qu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3OyWM637ayBeR
# 7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJJlFfym1Doi+4
# PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0mUGQHbRcF57ol
# pfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTwbD/zIExAopoe
# 3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i111TW7HV1Ats
# Qa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGezjM6CRpcWed/
# ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+8aW88WThRpv8
# lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH29308ZkpKKdp
# kiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrsxrYJD+3f3aKg
# 6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6Ii8+CQOYDwXM
# +yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz7NgAnOgpCdUo
# 4uDyllU9PzGCBJEwggSNAgEBMGkwVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1Nl
# Y3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFt
# cGluZyBDQSBSMzYCEDpSaiyEzlXmHWX8zBLY6YkwDQYJYIZIAWUDBAICBQCgggH5
# MBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQw
# NzMxMTkyMTQxWjA/BgkqhkiG9w0BCQQxMgQwfO9Vr+iNqb2QWqJXqAIZpykoEGF0
# jWGCHWwFbsnIqWAiCoHNXAZ+4wD7JrtR29XMMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgAphcvU
# um4hm+YVlN6SXYZanivKsWVuj0VbnbPoesjzLHWW6wvD9K+DUu5ENR4UDbzZeBFi
# R6XQ3bRshkIyKP9e/AOZwcb0wwpNBbnRKkGzFvsHkKfv+38N4IgIDXFgaQDP7yog
# Av1l+fCz4qy22Unbci3UKhcLQeRdjOKIKlnoxLfUgZ6VidqH+be58eka92mpbpmB
# rqH/0kQUr/WXyTSvc4eXTC/o/EboAR/TGBrO1HuUw90nruq0CaXHTKpDXNOtjKIo
# 6/inqTaXruoIJi6bWUUK1s5lsukVIjvEUJw98pViHbzaXCtbM1UMaMuGJXQUyTrE
# S75PTjMrWOvFaE+E/Jdd+qCF7gHNO9jWLhAMH47yZh10rYs5emtXTOEWJI8CtX2t
# DKcdbJGvNlwkDooUSi3gaIsPxKjxexhOpqYYOnNGkOlW0Mg/3uPZs83dzw8/dWaD
# s8wVbNcbnf73MUb81BiSh+SeiQF0uK5vo0PwKbX2/DwTGBlihmZRUaYSkLdMYN/j
# KmKM/k7t6+HSF1rMDEen+vWbTjINxMcIG4uDqaQY0nGVF89/l94/Itcyv9wbeV2z
# qwQ3Gu9FLzQwYy6CVAWwYx6UY6K5lYjmDyl4AtropwSO+jx69L8Z6KHh2Wy5YBOu
# vXbTCk0QrHewWepcb1tKlFWbXCKUxyrEWm/mKQ==
# SIG # End signature block
