Function Show-A9EEProm
{
<#
.SYNOPSIS
	Show node EEPROM information.
.DESCRIPTION
	The command displays node EEPROM log information.
.PARAMETER Dead
	Specifies that an EEPROM log for a node that has not started or successfully joined the cluster be displayed. If this option is used, it must be followed by a non empty list of nodes.
.PARAMETER Node_ID
	Specifies the node ID for which EEPROM log information is retrieved. Multiple node IDs are separated with a single space (0 1 2). 
	If no specifiers are used, the EEPROM log for all nodes is displayed.
.EXAMPLE
	The following example displays the EEPROM log for all nodes:
	PS:> Show-A9EEProm
.EXAMPLE
	PS:> Show-A9EEProm -Node_ID 0
.EXAMPLE
	PS:> Show-A9EEProm -Dead 
.EXAMPLE
	PS:> Show-A9EEProm -Dead -Node_ID 0
.NOTES
	This command utilizes the SSH command 'ShowEeprom'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Dead,
		[Parameter()]	[String]	$Node_ID
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showeeprom "
	if($Dead)	{	$Cmd += " -dead "}
	if($Node_ID)	{	$Cmd += " $Node_ID "}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}
