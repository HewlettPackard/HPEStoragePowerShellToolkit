## 	©2025 Hewlett Packard Enterprise Development LP

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
.EXAMPLE
	PS:> get-a9alert

	id   Severity         Type                     State        Tier                 Spare_PN     Time                   Message
	--   --------         ----                     -----        ----                 --------     ----                   -------
	146  Informational    Ethernet Monitor Event   New          Hardware check       P60758-001   2025-09-30 14:55:50 M…
	149  Degraded         Component state change   New          Hardware check       P60775-001   2025-10-04 23:36:46 M… Port 1:4:2 Degraded (Target Mode Port Went Offline)
	147  Degraded         Component state change   New          Hardware check       P60775-001   2025-10-05 03:19:44 M… Port 1:4:1 Degraded (Target Mode Port Went Offline)
.EXAMPLE
	PS:> get-a9alert -EventTypes All | convertto-json
	
	{
		"Time": "2025-04-07 12:14:57 MDT",
		"Message": "Cage cage41 (0x51402EC018DE6E46) I/O Module 1 firmware is outdated.",
		"State": "Resolved by System",
		"Type": "Cage I/O Module firmware outdated",
		"Component": "hw_cage:41,hw_cage_ifc:1",
		"Maintenance": "Upgrade",
		"Severity": "Informational",
		"Message Code": "0x02d0003",
		"Id": "120",
		"Tier": "Software check"
		"Resolved": {
			"Severity": "Informational",
			"Message": "enclmgmt process restarted, clearing any alert previously emitted by it.",
			"Component": "sw_enclmgmt",
			"Time": "2025-04-07 12:14:53 MDT",
			"Tier": "General",
			"Type": "Enclmgmt restarted"
	},

	Note that the extra details presented are under a subhash called 'Resolved' to see this you must exposed the alert via either Format-list of Convertto-json
.NOTES
	This command utilizes the SSH command 'ShowAlert
	This command requires a SSH type connection. 
	The option is only to request Detailed information. 
#>
[CmdletBinding()]
param(	[Parameter()]							
			[ValidateSet('New','Acknowledged','Fixed','All','Service')]
												[string]	$EventTypes,
		[Parameter()]							[switch]	$ShowRaw
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
	$Cmd += " -d " 
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if ( $ShowRaw ) { return $Result } 
	$DataPS = @()
	foreach ( $Line in $Result)
		{	$sub=$false
			if ( $Line.contains(']') -and $NewItem ) 
				{	# we must be at end of file, lets save the current object
					$DataPS += $NewItem
				}
			elseif ( $Line.Contains("Id") -and $NewItem)
				{	# We must be in a middle object
					$DataPS += $NewItem
					$NewItem = @{}
					$splitline = $line.split(": ")
					$Keyname = $SplitLine[0]
					$Keyname = $Keyname.replace(' "','')
					$KeyName = $Keyname.trim()	
					$ValueName = $SplitLine[1]
					if ($ValueName)
						{	$ValueName = $ValueName.replace('",','')
							$ValueName = $ValueName.trim()
							$NewItem += @{ $KeyName = $ValueName }
						}
				}
			elseif ( (-not $Line.contains('alerts')) -and (-not $Line.contains('"",')) -and (-not $Line.contains('[')) ) 
				{	# Must be middle data for existing item
					$splitline = $line.split(": ")
					$Keyname = $SplitLine[0]
					$Keyname = $Keyname.replace(' "','')
					if ($Keyname[0] -eq ' ')
						{	$Sub=$true
						}
					$KeyName = $Keyname.trim()
					$ValueName = $SplitLine[1]
					if ($ValueName)
						{	$ValueName = $ValueName.replace('",','')
							$ValueName = $ValueName.trim()
							if (-not $Sub)
								{	$NewItem += @{ $KeyName = $ValueName }
								}
							else{	if ( -not $NewItem.Resolved )	
										{	$NewItem += @{ 'Resolved' = @{} } 
										}
									$NewItem.Resolved += @{ $KeyName = $ValueName }	
								}

						}
				}
			elseif ( $Line.contains(']') -and -not $NewItem )
				{	# Must Be first item
					$NewItem = @{}
					$splitline = $line.split(": ")
					$Keyname = $SplitLine[0]
					$Keyname = $Keyname.replace(' "','')
					$KeyName = $Keyname.trim()	
					$ValueName = $SplitLine[1]
					if ($ValueName)
						{	$ValueName = $ValueName.replace('",','')
							$ValueName = $ValueName.trim()
							$NewItem += @{ $KeyName = $ValueName }
						}
				}
		}
	$DataPS = $DataPS | ConvertTo-JSON | ConvertFrom-JSON
	$NewObj = @(    foreach( $Item in $DataPS)	
											{   $NewItem=@{PSTypeName = "HPE.A9Storage.Alert"}
												$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
												$DataSetType = "HPE.A9Storage.Alert"
												$NewItem.PSTypeNames.Insert(0,$DataSetType)
												$DataSetType = $DataSetType + ".TypeName"
												$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
												[PSCustomObject]$NewItem
											}
				)
	Return $NewObj
}
}

Function Get-A9Health
{
<#
.SYNOPSIS
	Check the current health of the system.
.DESCRIPTION
	The command checks the status of system hardware and software components, and reports any issues
.PARAMETER showraw
	This will output the raw SSH streamed data instead of the processed object that is normally returned.
.NOTES
	This command utilizes the SSH command 'CheckHealth -full'	
	Since this command returns an object, the default behaviour is to get detailed reports, if you want to filter by component you can more easily use powershell filtering.
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]		[switch]	$ShowRaw
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " checkhealth -full -quiet -d " 
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if ($ShowRaw)	{return $result }
	# Need to objectivize it
	$NewObj=@()
	$FoundHeaderLine = $false
	$joinnext=$false
	foreach( $Line in $Result)
		{	$StartIndex = 0
			if ($Line.contains('Component') -and $Line.contains('Identifier') ) 
				{	$FoundHeaderLine = $true
					$Headline = $Line.split(' ')
					$headhash=[ordered]@{}
					foreach( $split in $Headline )
					{	if ( $Split )
							{	# this ignores blanks
								$headlineTrimmed = $Split.trim('-')
								$headlineRaw = $split
								$headlineLength = $HeadlineRaw.length
								if ( $HeadlineTrimmed -eq 'Detailed' )
									{	$joinnext = $true
										$HeadlineTrimmed = 'Detailed Description'
										$HeadHash['Detailed Description'] = $headlineLength
									}
								if ( $HeadlineTrimmed -eq 'Description' )
									{	$HeadHash['Detailed Description']+=$headlineLength
									}
								else 
									{	$HeadHash[$HeadlineTrimmed]=$HeadlineLength
									}
							}
					}
				}
			elseif ( $foundHeaderLine )
				{	# $HeadHash | convertto-json
					foreach ($Head in $HeadHash.getenumerator())
						{	if ( $StartIndex -eq 0 )
								{	$NewItem = @{}	
								}
							$Data = $($Line.Substring($StartIndex, $head.value) ).trim(' ')
							$data = $Data.trim('-')
							$data = $data.trim(' ')
							$NewItem += @{ $Head.key = $data }
							$StartIndex += $Head.value +1
						}
					if ( -not ( $NewItem['Identifier'] -eq '' -or $NewItem['Identifier'] -eq 'total') )
						{	$NewObj+=$NewItem
						}
				}
		}
	Return ($NewObj | convertto-json | convertfrom-json)
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
	Indicates a specific alert to be removed from the system. If this specifier is not used, the -a option must be used.
.NOTES
	This command utilizes the SSH command 'RemoveAlert'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Id',  Mandatory)]	[String]	$AlertID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " removealert -f  $Alert_ID "
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
.PARAMETER AlertID
	Specifies that the status of a specific alert be set. This specifier can be repeated to indicate multiple specific alerts. Up to 99 alerts
	can be specified in one command. If not specified, the -a option must be specified on the command line.
.PARAMETER NewStatus
	Specifies that the status of all alerts be set as "New"(new), "Acknowledged"(ack), or "Fixed"(fixed).
.NOTES
	This command utilizes the SSH command 'SetAlert'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	
		[ValidateSet('New','Acknowledged','Fixed')]	[switch]	$NewStatus,
		[Parameter(Mandatory)]						[int]		$AlertID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " setalert "
	Switch($NewStatus)	
		{	'New'			{	$Cmd += " new " 	}
			'Acknowledged' 	{	$Cmd += " ack " 	}
			'Fixed'			{	$Cmd += " fixed " 	}
		}
	$Cmd += " $AlertID "
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}
