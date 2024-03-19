####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Get-A9Maintenance
{
<#
.SYNOPSIS
	Show maintenance window records.
.DESCRIPTION
	The command displays maintenance window records.
.EXAMPLE
	PS:> Get-A9Maintenance
.EXAMPLE
	PS:> Get-A9Maintenance -All 
.PARAMETER All
	Display all maintenance window records, including active and expired ones. If this option is not specified, only active window records will be displayed.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc: Sort in increasing order (default).
		dec: Sort in decreasing order.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$All,
		[Parameter()]	[String]	$Sortcol
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " showmaint "
	if($All)	{	$Cmd += " -all " }
	if($Sortcol){	$Cmd += " -sortcol $Sortcol "}
	$Result = Invoke-CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -2  
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")		
					$s= [regex]::Replace($s,"-","")		
					$s= $s.Trim()	
					$temp1 = $s -replace 'StartTime','S-Date,S-Time,S-Zone'
					$temp2 = $temp1 -replace 'EndTime','E-Date,E-Time,E-Zone'
					$s = $temp2
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item  ve-Item  $tempFile	
		}
	if($Result.count -gt 1)	{	return  " Success : Executing Get-Maint"	}
	else					{	return  $Result								}
} 
}

Function New-A9Maintenance
{
<#
.SYNOPSIS
	Create a maintenance window record.
.DESCRIPTION
	The command creates a maintenance window record with the specified options and maintenance type.
.EXAMPLE
	PS:> New-A9Maintenance -Duration 1m -MaintType Node
.PARAMETER Comment
	Specifies any comment or additional information for the maintenance window record. The comment can be up to 255 characters long. Unprintable
	characters are not allowed.
.PARAMETER Duration
	Sets the duration of the maintenance window record. May be specified in minutes (e.g. 20m) or hours (e.g. 6h). Value is not to exceed 24 hours. The default is 4 hours.
.PARAMETER MaintType
	Specify the maintenance type. Maintenance type can be Other, Node, Restart, Disk, Cage, Cabling, Upgrade, DiskFirmware, or CageFirmware.
#>
[CmdletBinding()]
param(	[Parameter()]					[String]	$Comment,
		[Parameter()]					[String]	$Duration,
		[Parameter(Mandatory=$true)]	[String]	$MaintType
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
Process
{	$Cmd = " createmaint -f "
	if($Comment)	{	$Cmd += " -comment $Comment " }
	if($Duration)	{	$Cmd += " -duration $Duration " }
	if($MaintType) 	{	$Cmd += " $MaintType " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Set-A9Maintenance
{
<#
.SYNOPSIS
	Modify a maintenance window record with the specified options for the maintenance type.
.DESCRIPTION
	Allows modification of the Maintenance window record with the specified options for the maintenance type.
.PARAMETER Comment
	Specifies any comment or additional information for the maintenance window record. The comment can be up to 255 characters long. 
	Unprintable characters are not allowed.
.PARAMETER Duration
	Extends the duration of the maintenance window record by the specified time. May be specified in minutes (e.g. 20m) or hours (e.g. 6h). If
	unspecified, the window duration is unchanged. This option cannot be specified with the -end option.
.PARAMETER End
	Ends the window record for the specified maintenance type. If the maintenance window record has been created more than once with
	"createmaint", this option reduces its reference count by 1 without ending the window record. This option cannot be specified with the Duration Option.
.PARAMETER MaintType
	The maintenance type for the maintenance window record to be modified. Maintenance type can be Other, Node, Restart, Disk, Cage, Cabling,
	Upgrade, DiskFirmware, CageFirmware, or all. "all" can only be specified with option -end, which ends all maintenance window records,
	regardless of their reference counts.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Comment,
		[Parameter()]	[String]	$Duration,
		[Parameter()]	[switch]	$End,
		[Parameter(Mandatory=$true)]	[String]	$MaintType
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " setmaint "
	if($Comment)	{	$Cmd += " -comment $Comment " }
	if($Duration)	{	$Cmd += " -duration $Duration " }
	if($End)		{	$Cmd += " -end " }
	if($MaintType)	{	$Cmd += " $MaintType " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
} 
}
