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
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[switch]	$ShowRaw
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$Cmd = " showencryption "
		$LastItem = $Fcnt = 0
		if($Detailed)	{	$Cmd += " -d "
							$Fcnt = 4
							$LastItem = $Result.Count -2 
						}
		$Result = Invoke-A9CLICommand -cmds  $Cmd
	}
End
	{	if ($ShowRaw -or $Result.count -lt 2) { Return $Result }
		$tempFile = [IO.Path]::GetTempFileName	
		foreach ($s in  $Result[$Fcnt..$LastItem] )
			{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
				$s = $s -replace 'AdmissionTime','Date,Time,Zone'
				Add-Content -Path $tempfile -Value $s				
			}
		$returndata = Import-Csv $tempFile 
		Remove-Item  $tempFile
		write-host " Success : Executing Get-Encryption" -ForegroundColor green 
		return $returndata	
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
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Getresults
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$Cmd = " checkupgrade "
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
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Svc
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showinventory "
	if($Service) 	{	$Cmd += " -svc "	}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

