####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9Inventory_CLI
{
<#
.SYNOPSIS
	Get-Inventory - show hardware inventory
.DESCRIPTION
	Shows information about all the hardware components in the system.
.PARAMETER Svc
	Displays inventory information with HPE serial number, spare part number, and so on. It is not supported on HPE 3PAR 10000 systems.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Svc
)
Begin
{	Test-A9CLIConnection
}
Process
{	$Cmd = " showinventory "
	if($Svc) 	{	$Cmd += " -svc "	}
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
} 
}
