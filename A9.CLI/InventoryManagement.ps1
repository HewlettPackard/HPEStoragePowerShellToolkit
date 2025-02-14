####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

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

