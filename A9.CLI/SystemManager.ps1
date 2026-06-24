## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9Encryption
{
<#
.SYNOPSIS
	Show Data Encryption information.
.DESCRIPTION
	The Get-Encryption command shows Data Encryption information.
.PARAMETER Detailed
	Provides details on the encryption status.
.NOTES
	This command utilizes the SSH command 'showencryption'
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='showencryption')]
param(	[Parameter(ParameterSetName='showencryption')]	[switch]	$Detailed,
		[Parameter(ParameterSetName='showencryption')]	[switch]	$ShowRaw
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$cmd = 'showencryption -d'
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		if ($ShowRaw) { Return $Result }
		# if ($ShowRaw -or $Result.count -lt 2) { Return $Result }
		$Title=$False
		$VData=$False
		$tempFile = [IO.Path]::GetTempFileName	
		foreach ($s in  $Result )
			{	if ( -not $Title )
					{	$t=$s.split(' ') | where-object { $_ -ne ' '} | where-object {$_ -ne '' }
						$Title = $true
					}
				else{	$v=$s.split(' ') | where-object { $_ -ne ' ' } | where-object {$_ -ne ''}	
					}
			}
		$vx=@()
		$c1=0
		$c2=$T.count
		while ( $c1 -lt $c2)
			{	write-host " $($T[$c1]) = $($v[$c1])"
				$h1+= @{ $($T[$c1]) = $($v[$c1]) }
				$C1+=1
			}
		$Vx += ,$h1
		# $vx | out-string
		#$returndata = Import-Csv $tempFile 
		#Remove-Item  $tempFile
		write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
		$result = $Vx | convertto-json | convertfrom-json
		return $vx	
	}
}

Function Measure-A9Upgrade
{
<#
.SYNOPSIS
	Determine if a system can do an online upgrade.
.DESCRIPTION
	The checkupgrade command determines whether or not the system can safely proceed with an OS update. 
	By default, it checks the ability of the system to start an OS update, unless one is already in progress, 
	in which case it checks if it is safe to reboot another node.
.PARAMETER Getresults
	Displays results of the latest set of scripts that have been run (except
	postabort scripts).
.NOTES
	This command utilizes the SSH command 'checkupgrade'
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='checkupgrade')]
param(	[Parameter(ParameterSetName='checkupgrade')]	[switch]	$Getresults
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$cmd = $PSCmdlet.ParameterSetName + ' '
		if($Getresults) 			{	$Cmd += " -getresults " }
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Get-A9Inventory
{
<#
.SYNOPSIS
	show hardware inventory
.DESCRIPTION
	Shows information about all the hardware components in the system.
.PARAMETER Service
	Displays inventory information with HPE serial number, spare part number, and so on. It is not supported on HPE 3PAR 10000 systems.
.NOTES
	This command utilizes the SSH command 'showinventory'
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='showinventory')]
param(	[Parameter(ParameterSetName='showinventory')]	[switch]	$Svc
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = $PSCmdlet.ParameterSetName + ' '
	if($Service) 	{	$Cmd += " -svc "	}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Find-A9Command
{
<#
.SYNOPSIS
	This command will find which PowerShell command Maps to a CLI based Command. 
.DESCRIPTION
	If no arguments are given it will return all CLI based command and the CLI based commands that they utilize.
	The command can also be used to return a single value of what command maps to a CLI command, or what PowerShell command maps to which CLI operation.
.PARAMETER CLIBasedCommand
	This is the command as illustrated in the HPE Alletra MP B10K, or Alletra9000 CLI guide. 
	Valid values can be gathered from the CLI guide online and look like the following examples;
		addvv, showld, showpeer, ...

.PARAMETER PowerShellBasedCommand
	If you input the name of a CLI based PowerShell command it will return the single or multiple CLI operations that command uses.
	Examples of the values that are accepted are as follows;
		Get-A9Volume_CLI, Show-A9Peer_CLI
	If the command utilizes no CLI operations and instead uses only API calls, it will return a warning that the command is not a CLI based command.
.EXAMPLE
	PS:> Find-A9Command

	Name                           Value
	----                           -----
	Add-A9Hardware                 {admithw}
	Add-A9RCopyLink_CLI            {admitrcopylink}
	Add-A9Vv                       {admitvv}
	Compress-A9VV_CLI              {tunevv}
	Disable-A9RCopylink_CLI        {dismissrcopylink}
	Find-A9Cage                    {LocateCage}
	Find-A9Node                    {LocateNode}
		...
.EXAMPLE
	PS:> Find-A9Command -CLIBasedCommand showpeer

	Name                           Value
	----                           -----
	Show-A9Peer_CLI                {showpeer}

.EXAMPLE
	PS:> Find-A9Command -PowerShellCommand Set-A9PhysicalDisk

	Name                           Value
	----                           -----
	Set-A9PhysicalDisk             {AdmitPD, SetPD, ControlPD, CheckPD…}

	Note that it will give the command asked for, but it also shows the other CLI operations that the command may utilize based on what options are selected.
.EXAMPLE
	PS:> Find-A9Command -PowerShellCommand new-a9host

	WARNING: The command given appears not be be a CLI based command. new-a9host

.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='PWSH')]
param(	[Parameter(parametersetname='CLI')]		[String]	$CLIBasedCommand,
		[Parameter(parametersetname='PWSH')]	[string]	$PowerShellCommand
	)

Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	switch($PSCmdlet.ParameterSetName)
	{	'PWSH'
				{	if ( $PowerShellCommand) 
						{	$TrimHelp = $null
							$FullHelp = Get-Help $PowerShellCommand -Full | Out-String
							$FindString = 'This command utilizes the SSH command'
							$First = $FullHelp.IndexOf($FindString)
							write-verbose "Testing command $PowerShellCommand"
							if ( $first -and $first -gt 0 )	
								{ 	write-verbose "The index location of the string $FindString is at location $first" }
							else{	if ( $PowerShellCommand ) 
										{ 	write-verbose "The command given appears not be be a CLI based command. $PowerShellCommand" 	
											return 
										}
								}
							$Second = $FullHelp.IndexOf('This command requires a SSH type connection.')
							if ( $second -and $second -gt 0 )	{	write-verbose "The index of the location of the string $FindString is at location $Second" }
							else 			{	write-warning "No CLI based command found. $PowerShellCommand"		; return }
							if ( -not ( $first -and $second )) 	{ 	write-warning "No CLI based command found. $PowerShellCommand"	; return }
							$ValueLength = $Second-($First+$FindString.Length+1)
							$ValueStart = $First+$FindString.Length
							if ( -not ($ValueLength -lt 1) )	{ $TrimHelp = $FullHelp.Substring( ( $ValueStart ) , ( $ValueLength ) ) }
							else	{	write-warning "The valuelen is $ValueLength on command $PowerShellCommand" }
							$Resulto = @{}
							if ( $TrimHelp ) 
								{	$Result = @()
									Write-Verbose "The extraced Trimed list of commands = $TrimHelp"
									$Thelp2 = $trimhelp.split(',')
									foreach ($sshcmd in $Thelp2)
										{	$sshcmd2 = $sshcmd -replace "`r?`n", " "
											$sshcmd3 = $sshcmd2 -replace "`t", " "
											$sshcmd4 = $sshcmd3.trim(" ")
											$sshcmd5 = $sshcmd4.trim("'")
											$sshcmd6 = $sshcmd5.trim(" ")
											Write-Verbose "The $PowerShellCommand command uses the $sshcmd6 SSH based CLI command."
											$Result+=$sshcmd6
										}
									$Resulto["$PowerShellCommand"] =  $Result 
									return ( $Resulto  )
								}	
							write-warning "No CLI based command found. $PowerShellCommand"
							return			
						}
					else{	$BigResult=@()
							foreach ($res in (get-command -Module HPEStorage).name ) 
								{ $BigResult+= $( Find-A9Command -PowerShellCommand $res ) } 
							$FinalResult = $BigResult 
							return $FinalResult
						}
				}
		'CLI'
				{	$MyHash = Find-A9Command
					foreach( $comm in $MyHash)
						{	$commandpwsh = $comm.Keys
							$commandcli = $MyHash."$commandpwsh"
							write-verbose "testing $commandpwsh against $commandcli"
							if ( $commandcli -contains $CLIBasedCommand )
								{	return ( Find-A9Command -PowerShellCommand $commandpwsh )
								}
						}

				}
	}
}
}