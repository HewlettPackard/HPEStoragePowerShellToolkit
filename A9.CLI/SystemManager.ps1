####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

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
.PARAMETER Allow_singlepathhost
	Overrides the default behavior of preventing an online upgrade if a host is at risk of losing connectivity to the array due to only having a
	single access path to the StoreServ. Use of this option will result in a loss of connectivity for the host when the path to the array disconnects
	as the node reboots to the new version. This option should be used with extreme caution.
.PARAMETER Debug
	Display debug level information from check scripts.
.PARAMETER Extraverbose
	Display test output, even for passing or not applicable scripts.
.PARAMETER Getpostabortresults
	Displays results of the latest set of postabort scripts.
.PARAMETER Getresults
	Displays results of the latest set of scripts that have been run (except
	postabort scripts).
.PARAMETER Getworkarounds
	Displays information about workarounds that apply to an upgrade.
.PARAMETER Nopatch
	Do not check for any checkupgrade update packages.
.PARAMETER Offline
	Checks that apply only to online upgrades will be skipped.
.PARAMETER Phase <phasename>
	Set of scripts to run. phasename can be any one of the following:
	postabort, postcheck, postchecklist, postunpack, preboot, precheck,
	prechecklist, preswitch, preupgrade, preupgradelist
.PARAMETER Revertnode
	Used to check when reverting nodes as part of aborting an upgrade.
.PARAMETER Verbose
	Display output from the checkupgrade update package check.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Allow_singlepathhost,
		[Parameter()]	[switch]	$Extraverbose,
		[Parameter()]	[switch]	$Getpostabortresults,
		[Parameter()]	[switch]	$Getresults,	
		[Parameter()]	[switch]	$Getworkarounds,
		[Parameter()]	[switch]	$Nopatch,	
		[Parameter()]	[switch]	$Offline,	
		[Parameter()][ValidateSet('postabort', 'postcheck', 'postchecklist', 'postunpack', 'preboot', 'precheck', 'prechecklist', 'preswitch', 'preupgrade', 'preupgradelist')]	
						[String]	$Phase,	
		[Parameter()]	[switch]	$Revertnode
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$Cmd = " checkupgrade "
		if($Allow_singlepathhost)	{	$Cmd += " -allow_singlepathhost " }
		if($Debug)					{	$Cmd += " -debug " }
		if($Extraverbose)			{	$Cmd += " -extraverbose " }
		if($Getpostabortresults)	{	$Cmd += " -getpostabortresults " }
		if($Getresults) 			{	$Cmd += " -getresults " }
		if($Getworkarounds)			{	$Cmd += " -getworkarounds " }
		if($Nopatch)				{	$Cmd += " -nopatch " }
		if($Offline)				{	$Cmd += " -offline " }
		if($Phase)					{	$Cmd += " -phase $Phase " }
		if($Revertnode)				{	$Cmd += " -revertnode " }
		if($Verbose)				{	$Cmd += " -verbose " }
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Optimize-A9LogicalDisk
{
<#
.SYNOPSIS
	Change the layout of a logical disk. 
.DESCRIPTION
	The Optimize command is used to make changes to a logical disk (LD) by creating a new LD and moving regions from the original LD to the new LD.
	The new LD will always have the same space type (SA, SD, USR) as the original LD.

    If the original LD belongs to a CPG, the new LD inherits the characteristics of that CPG. SA and SD space LDs have
    growth and allocations blocked so the original LD can be completely emptied during the tune.

    If the original LD does not belong to a CPG, a new LD will be created, inheriting the characteristics of the original LD.

    When a new LD is created it will spread to whatever PDs are available as determined by availability and pattern rules.

    The options detailed below can be used to control some aspects of the new LD.
.PARAMETER LD_name
	Name of the LD to tune.
.PARAMETER Waittask
	Wait for the command to complete before returning.
.PARAMETER DR
	Specifies that the command is a dry run and that the logical disk will not be tuned. The command will return
	any error messages that would be displayed or a summary of the actions that would be performed.
.PARAMETER Shared
	Where possible, share the destination LDs and do not create new LDs.
.PARAMETER Regions 
	Number of regions to move at a time. Range is 1-1024, default is 1024.
.PARAMETER Tunesys
	Only to be used when called from tunesys. When present, tuneld will update task information in the calling tunesys
	task with progress information. Also, when present tuneld will exit the CLI if certain errors occur, otherwise only an error will be displayed.
.PARAMETER Tunenodech
	Only to be used when called from tunenodech. When present tuneld will exit the CLI if certain errors occur, otherwise only an error will be displayed.
.PARAMETER Preserved
	Only to be used when source LD is in a preserved state. This option will move all good regions from the source LD to a new LD.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Waittask,	
		[Parameter()]	[switch]	$DR,
		[Parameter()]	[switch]	$Shared,
		[Parameter()]	[String]	$Regions,
		[Parameter()]	[switch]	$Tunesys,
		[Parameter()]	[switch]	$Tunenodech,
		[Parameter()]	[switch]	$Preserved,
		[Parameter(Mandatory)]	[String]	$LD_name
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$Cmd = " tuneld -f "
		if($Waittask)	{	$Cmd += " -waittask "}
		if($DR)			{	$Cmd += " -dr " }
		if($Shared) 	{	$Cmd += " -shared " }
		if($Regions)	{	$Cmd += " -regions $Regions " }
		if($Tunesys)	{	$Cmd += " -tunesys " }
		if($Tunenodech) {	$Cmd += " -tunenodech " }
		if($Preserved)	{	$Cmd += " -preserved " }
		if($LD_name)	{	$Cmd += " $LD_name " }
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Optimize-A9Node
{
<#
.SYNOPSIS
	Rebalance PD utilization on a node after upgrades. (HIDDEN)
.DESCRIPTION 
    The command is used to analyze and detect poor layout and disk utilization across PDs with a specified node owner.
    Rebalancing is achieved using a combination of chunklet movement and re-laying out LDs associated with the node.
.PARAMETER Node
	The ID of the node to be tuned. <number> must be in the range 0-7. This parameter must be supplied.
.PARAMETER Chunkpct 
	Controls the detection of underutilized PDs associated with a node. The average utilization of all PDs of a devtype is calculated and
	any PD with a utilization of (average - <percentage>) will trigger node tuning for that devtype. For example, if the average is 70%
	and <percentage> is 10%, then the threshold will be 60%. <percentage> must be between 1 and 100. The default value is 10.
.PARAMETER Maxchunk 
	Controls how many chunklets are moved from each PD per move
	operation. <number> must be between 1 and 8. The default value is 8.
.PARAMETER Fulldiskpct 
	If a PD has more than <percentage> of its capacity utilized, chunklet movement is used to reduce its usage to <percentage> before LD tuning
	is used to complete the rebalance. e.g. if a PD is 98% utilized and <percentage> is 90, chunklets will be redistributed to other PDs until the
	utilization is less than 90%. If <percentage> is less than the devtype average then the calculated average will be used instead.
	<percentage> must be between 1 and 100. The default value is 90.
.PARAMETER Devtype 
	Specifies a comma separated list of one or more devtypes to be tuned. <devtype> can be one of SSD, FC or NL. Default is all devtypes. All named devtypes must be present on the node being tuned.
.PARAMETER DR
	Perform a dry-run analysis of the system and report details on what tuning would be performed with the supplied settings.  
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()][ValidateRange(0,7)]					[String]	$Node,
	[Parameter()][ValidateRange(0,100)]					[String]	$Chunkpct,
	[Parameter()][ValidateRange(1,8)]					[String]	$Maxchunk,
	[Parameter()][ValidateRange(0,100)]					[String]	$Fulldiskpct,
	[Parameter()][ValidateSet('SSD','FC','NL','SCM')]	[String]	$Devtype,
	[Parameter()]										[switch]	$DryRun
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
Process	
	{	$Cmd = " tunenodech -f "
		if($Node)		{	$Cmd += " -node $Node " }
		if($Chunkpct) 	{	$Cmd += " -chunkpct $Chunkpct " }
		if($Maxchunk)	{	$Cmd += " -maxchunk $Maxchunk " }
		if($Fulldiskpct){	$Cmd += " -fulldiskpct $Fulldiskpct " }
		if($Devtype)	{	$Cmd += " -devtype $Devtype " }
		if($DryRun) 	{	$Cmd += " -dr " }
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}


