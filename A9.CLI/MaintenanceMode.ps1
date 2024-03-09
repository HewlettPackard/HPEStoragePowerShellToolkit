####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
##	File Name:		MaintenanceMode.psm1
##	Description: 	Maintenance Mode cmdlets 
##		
##	Created:		January 2020
##	Last Modified:	January 2020
##	History:		v3.0- Created	
#####################################################################################


$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

########################## FUNCTION Test-CLIObject
########################Function Test-CLIObject 
{
Param( 	
    [string]$ObjectType, 
	[string]$ObjectName ,
	[string]$ObjectMsg = $ObjectType, 
	$SANConnection = $global:SANConnection
	)

	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")
	{
		$IsObjectExisted = $false
	}
	return $IsObjectExisted
	
} # End FUNCTION Test-CLIObject

##########################################################################
########################### FUNCTION Get-Maint ###########################
##########################################################################
Function Get-Maint()
{
<#
  .SYNOPSIS
   Get-Maint - Show maintenance window records.

  .DESCRIPTION
   The Get-Maint command displays maintenance window records.

  .EXAMPLE
	Get-Maint
.EXAMPLE
	Get-Maint -All 
.PARAMETER All
   Display all maintenance window records, including active and expired
   ones. If this option is not specified, only active window records will
   be displayed.
.PARAMETER Sortcol
   Sorts command output based on column number (<col>). Columns are
   numbered from left to right, beginning with 0. At least one column must
   be specified. In addition, the direction of sorting (<dir>) can be
   specified as follows:
	   inc
	   Sort in increasing order (default).
	   dec
	   Sort in decreasing order.

  .Notes
    NAME: Get-Maint
    LASTEDIT January 2020
    KEYWORDS: Get-Maint
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	 [Parameter()]
	 [switch]
	 $All,

	 [Parameter()]
	 [String]
	 $Sortcol,

	 [Parameter(ValueFromPipeline=$true)]
	 $SANConnection = $global:SANConnection
 )
 if ( -not $(Test-A9CLI) ) 	{	return }

	$Cmd = " showmaint "

 if($All)
 {
	$Cmd += " -all "
 }

 if($Sortcol)
 {
	$Cmd += " -sortcol $Sortcol "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Get-Maint Command -->" INFO: 

 if($Result.count -gt 1)
 {	
	$Cnt = $Result.count
		
 	$tempFile = [IO.Path]::GetTempFileName()
	$LastItem = $Result.Count -2  
	
	foreach ($s in  $Result[0..$LastItem] )
	{
		$s= [regex]::Replace($s,"^ ","")
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
 
 if($Result.count -gt 1)
 {
	return  " Success : Executing Get-Maint"
 }
 else
 {			
	return  $Result
 }
 
} ##  End-of Get-Maint

##########################################################################
######################### FUNCTION New-Maint #########################
##########################################################################
Function New-Maint()
{
<#
  .SYNOPSIS
   New-Maint - Create a maintenance window record.

  .DESCRIPTION
   The New-Maint command creates a maintenance window record with the
   specified options and maintenance type.

  .EXAMPLE
	New-Maint -Duration 1m -MaintType Node
.PARAMETER Comment
   Specifies any comment or additional information for the maintenance
   window record. The comment can be up to 255 characters long. Unprintable
   characters are not allowed.
.PARAMETER Duration
   Sets the duration of the maintenance window record. May be specified in
   minutes (e.g. 20m) or hours (e.g. 6h). Value is not to exceed
   24 hours. The default is 4 hours.
   .PARAMETER MaintType
	Specify the maintenance type.
	Maintenance type can be Other, Node, Restart, Disk, Cage, Cabling, Upgrade, DiskFirmware, or CageFirmware.

  .Notes
    NAME: New-Maint
    LASTEDIT January 2020
    KEYWORDS: New-Maint
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
 
	[Parameter()]
	[String]
	$Comment,

	[Parameter()]
	[String]
	$Duration,

	[Parameter(Mandatory=$true)]
	[String]
	$MaintType,

	[Parameter(ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )
 if ( -not $(Test-A9CLI) ) 	{	return }

 $Cmd = " createmaint -f "

 if($Comment)
 {
	$Cmd += " -comment $Comment "
 }

 if($Duration)
 {
	$Cmd += " -duration $Duration "
 }

 if($MaintType)
 {
  $Cmd += " $MaintType "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : New-Maint command -->" INFO: 
 
 Return $Result
} ##  End-of New-Maint

##########################################################################
######################### FUNCTION Set-Maint #########################
##########################################################################
Function Set-Maint()
{
<#
  .SYNOPSIS
   Set-Maint - Modify a maintenance window record with the specified options for
   the maintenance type.

  .DESCRIPTION
   Allows modification of the Maintenance window record with the specified
   options for the maintenance type.

  .EXAMPLE
.PARAMETER Comment
   Specifies any comment or additional information for the maintenance
   window record. The comment can be up to 255 characters long. Unprintable
   characters are not allowed.
.PARAMETER Duration
   Extends the duration of the maintenance window record by the specified
   time. May be specified in minutes (e.g. 20m) or hours (e.g. 6h). If
   unspecified, the window duration is unchanged. This option cannot be
   specified with the -end option.
.PARAMETER End
   Ends the window record for the specified maintenance type. If the
   maintenance window record has been created more than once with
   "createmaint", this option reduces its reference count by 1 without
   ending the window record. This option cannot be specified with the
   Duration Option.
   .PARAMETER MaintType
	The maintenance type for the maintenance window record to be modified.
	Maintenance type can be Other, Node, Restart, Disk, Cage, Cabling,
	Upgrade, DiskFirmware, CageFirmware, or all. "all" can only be
	specified with option -end, which ends all maintenance window records,
	regardless of their reference counts.

  .Notes
    NAME: Set-Maint
    LASTEDIT January 2020
    KEYWORDS: Set-Maint
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter()]
	[String]
	$Comment,

	[Parameter()]
	[String]
	$Duration,

	[Parameter()]
	[switch]
	$End,

	[Parameter(Mandatory=$true)]
	[String]
	$MaintType,

	[Parameter(ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )
 if ( -not $(Test-A9CLI) ) 	{	return }

	$Cmd = " setmaint "

 if($Comment)
 {
	$Cmd += " -comment $Comment "
 }

 if($Duration)
 {
	$Cmd += " -duration $Duration "
 }

 if($End)
 {
	$Cmd += " -end "
 }

 if($MaintType)
 {
	$Cmd += " $MaintType "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Set-Maint Command -->" INFO:
 
 Return $Result
} ##  End-of Set-Maint

Export-ModuleMember Get-Maint , New-Maint , Set-Maint
