####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function New-A9FlashCache_CLI
{
<#
.SYNOPSIS
	Creates flash cache for the cluster.
.DESCRIPTION
	The command creates flash cache of <size> for each node pair. The flash cache will be created from SSD drives.
.PARAMETER Simulate
	Specifies that the Adaptive Flash Cache will be run in simulator mode. The simulator mode does not require the use of SSD drives.
.PARAMETER NoCheck_SCM_Size
	Overrides the size comparison check to allow the creation of Adaptive Flash Cache when SCM devices size are mismatched.
.PARAMETER RAIDType
	Specifies the RAID type of the logical disks for Flash Cache; r0 for RAID-0 or r1 for RAID-1. If no RAID type is specified, the default is chosen by the storage system.
.PARAMETER Size
	Specifies the size for the flash cache in MiB for each node pair. The flashcache size should be a multiple of 16384 (16GiB), and be an integer. 
	The minimum size of the flash cache is 64GiB. The maximum size of the flash cache is based on the node types, ranging from 768GiB up to 12288GiB (12TiB).
    An optional suffix (with no whitespace before the suffix) will modify the units to GiB (g or G suffix) or TiB (t or T suffix).
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]									[switch]	$Sim,
		[Parameter()]									[switch]	$NoCheck_SCM_Size,
		[Parameter()][ValidateSet('Raid-0','RAID-1')]	[String]	$RAIDType,
		[Parameter()]									[String]	$Size
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process 
	{	$Cmd = " createflashcache "
		if($Simulate) 			{	$Cmd += " -sim " }
		if($NoCheck_SCM_Size) 	{	$Cmd += " -nocheck_scm_size " }
		IF($RAIDtype.ToLower() -eq 'raid-0') 	{$Cmd += " -t r0 " }
		IF($RAIDtype.ToLower() -eq 'raid-1') 	{$Cmd += " -t r1 " }
		if($Size)				{	$Cmd += " $Size " }
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	} 
}

Function Set-A9FlashCache_CLI
{
<#
.SYNOPSIS
	Sets the flash cache policy for virtual volumes
.DESCRIPTION
	The command allows you to set the policy of the flash cache for virtual volumes. The policy is set by using virtual volume sets(vvset). 
	The sys:all is used to enable the policy on all virtual volumes in the system.
.PARAMETER Enable
	Will turn on the flash cache policy for the target object.
.PARAMETER Disable
	Will turn off flash cache policy for the target object.
.PARAMETER Clear
	Will turn off policy and can only be issued against the sys:all target.
.PARAMETER vvSet
	vvSet refers to the target object name as listed in the showvvset command. Pattern is glob-style (shell-style) patterns (see help on sub,globpat).
	Note(set Name Should de is the same formate Ex:  vvset:vvset1 )
.PARAMETER All
	The policy is applied to all virtual volumes.
.EXAMPLE
	PS:> Set-A9FlashCache_CLI -Enable -All
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='EnableV', Mandatory)]
		[Parameter(ParameterSetName='EnableA', Mandatory)]	[switch]	$Enable,
		[Parameter(ParameterSetName='DisableV',Mandatory)]
		[Parameter(ParameterSetName='DisableA',Mandatory)]	[switch]	$Disable,
		[Parameter(ParameterSetName='ClearA',  Mandatory)]	[switch]	$Clear,
		[Parameter(ParameterSetName='EnableV', Mandatory)]
		[Parameter(ParameterSetName='ClearV', Mandatory)]	[String]	$vvSet,
		[Parameter(ParameterSetName='EnableV', Mandatory)]
		[Parameter(ParameterSetName='EnableA', Mandatory)]
		[Parameter(ParameterSetName='ClearA', Mandatory)]	[switch]	$All
)
Begin 
	{	Test-A9Connection -ClientType 'SshClient' 
	}
Process
	{	$Cmd = " setflashcache "
		if($Enable) 	{	$Cmd += " enable " }
		if($Disable){	$Cmd += " disable " }
		if($Clear)	{	$Cmd += " clear " }
		if($vvSet)		{	$Cmd += " $vvSet " }
		if($All) 		{	$Cmd += " sys:all " }
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Remove-A9FlashCache_CLI
{
<#
.SYNOPSIS
	Removes flash cache from the cluster.
.DESCRIPTION
	The command removes the flash cache from the cluster and will stop use of the extended cache.
.EXAMPLE
	PS:> Remove-A9FlashCache_CLI
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process
	{	$Cmd = " removeflashcache -f "
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

