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
##	File Name:		vLunManagement.psm1
##	Description: 	vLUN Management cmdlets 
##		
##	Created:		January 2020
##	Last Modified:	May 2021
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## FUNCTION Test-CLIObject
############################################################################################################################################
Function Test-CLIObject 
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

############################################################################################################################################
## FUNCTION Get-vLun
############################################################################################################################################
Function Get-vLun
{
<#
  .SYNOPSIS
    Get list of LUNs that are exported/ presented to hosts
  
  .DESCRIPTION
    Get list of LUNs that are exported/ presented to hosts
        
  .EXAMPLE
    Get-vLun 
	List all exported volumes

  .EXAMPLE	
	Get-vLun -vvName PassThru-Disk 
	List LUN number and hosts/host sets of LUN PassThru-Disk
	
  .PARAMETER vvName 
    Specify name of the volume to be exported. 
	If prefixed with 'set:', the name is a volume set name.
	

  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Get-vLun  
    LASTEDIT: January 2020
    KEYWORDS: Get-vLun
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$vvName,
		
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$PresentTo, 	
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)		
	
	Write-DebugLog "Start: In Get-vLun - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{			
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Get-vLun since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Get-vLun since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}	
	
	$ListofvLUNs = @()
	
	$GetvLUNCmd = "showvlun -t -showcols VVName,Lun,HostName,VV_WWN "
	if ($vvName)
	{
		$GetvLUNCmd += " -v $vvName"
	}
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $GetvLUNCmd
	write-debuglog "Get list of vLUN" "INFO:" 
	if($Result -match "Invalid vv name:")
	{
		return "FAILURE : No vv $vvName found"
	}
	
	$Result = $Result | where { ($_ -notlike '*total*') -and ($_ -notlike '*------*')} ## Eliminate summary lines
	if ($Result.Count -gt 1)
	{
		foreach ($s in  $Result[1..$Result.Count] )
		{
			
			$s= $s.Trim()
			$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
			$sTemp = $s.Split(',')
			
			$vLUN = New-Object -TypeName _vLUN
			$vLUN.Name = $sTemp[0]
			$vLUN.LunID = $sTemp[1]
			$vLUN.PresentTo = $sTemp[2]
			$vLUN.vvWWN = $sTemp[3]
			
			$ListofvLUNs += $vLUN			
		}
	}
	else
	{
		write-debuglog "LUN $vvName does not exist. Simply return" "INFO:"
		return "FAILURE : No vLUN $vvName found Error : $Result"
	}
	

	if ($PresentTo)
		{ $ListofVLUNs | where  {$_.PresentTo -like $PresentTo} }
	else
		{ $ListofVLUNs  }
	
} # End Get-vLun

##############################################################################
########################### FUNCTION Show-vLun ###############################
##############################################################################
Function Show-vLun
{
<#
  .SYNOPSIS
    Get list of LUNs that are exported/ presented to hosts
  
  .DESCRIPTION
    Get list of LUNs that are exported/ presented to hosts
        
  .EXAMPLE
    Show-vLun 
	List all exported volumes

  .EXAMPLE	
	Show-vLun -vvName XYZ 
	List LUN number and hosts/host sets of LUN XYZ
	
  .EXAMPLE	
	Show-vLun -Listcols
	
  .EXAMPLE	
	Show-vLun -Nodelist 1
	
  .EXAMPLE	
	Show-vLun -DomainName Aslam_D	
	
  .PARAMETER vvName 
    Specify name of the volume to be exported. 
	If prefixed with 'set:', the name is a volume set name.
	
  .PARAMETER Listcols
	List the columns available to be shown in the -showcols option
	described below (see 'clihelp -col showvlun' for help on each column).

  .PARAMETER Showcols <column>[,<column>...]
	Explicitly select the columns to be shown using a comma-separated list
	of column names.  For this option the full column names are shown in
	the header.
	Run 'showvlun -listcols' to list the available columns.
	Run 'clihelp -col showvlun' for a description of each column.

  .PARAMETER ShowWWN
	Shows the WWN of the virtual volume associated with the VLUN.

  .PARAMETER ShowsPathSummary
	Shows path summary information for active VLUNs

  .PARAMETER Hostsum
	Shows mount point, Bytes per cluster, capacity information from Host Explorer
	and user reserved space, VV size from showvv.

  .PARAMETER ShowsActiveVLUNs
	Shows only active VLUNs.

  .PARAMETER ShowsVLUNTemplates
	Shows only VLUN templates.

  .PARAMETER Hostname {<hostname>|<pattern>|<hostset>}...
	Displays only VLUNs exported to hosts that match <hostname> or
	glob-style patterns, or to the host sets that match <hostset> or
	glob-style patterns(see help on sub,globpat). The host set name must
	start with "set:". Multiple host names, host sets or patterns can
	be repeated using a comma-separated list.

  .PARAMETER VV_name {<VV_name>|<pattern>|<VV_set>}...
	Displays only VLUNs of virtual volumes that match <VV_name> or
	glob-style patterns, or to the vv sets that match <VV-set> or glob-style
	patterns (see help on sub,globpat). The VV set name must start
	with "set:". Multiple volume names, vv sets or patterns can be
	repeated using a comma-separated list (for example -v <VV_name>,
	<VV_name>...).

  .PARAMETER LUN
	Specifies that only exports to the specified LUN are displayed. This
	specifier can be repeated to display information for multiple LUNs.

  .PARAMETER Nodelist
	Requests that only VLUNs for specific nodes are displayed. The node list
	is specified as a series of integers separated by commas (for example
	0,1,2). The list can also consist of a single integer (for example 1).
	
  .PARAMETER Slotlist
	Requests that only VLUNs for specific slots are displayed. The slot list
	is specified as a series of integers separated by commas (for example
	0,1,2). The list can also consist of a single integer (for example 1).

  .PARAMETER Portlist
	Requests that only VLUNs for specific ports are displayed. The port list
	is specified as a series of integers separated by commas ((for example
	1,2). The list can also consist of a single integer (for example 1).

  .PARAMETER Domain_name  
	Shows only the VLUNs whose virtual volumes are in domains with names
	that match one or more of the <domainname_or_pattern> options. This
	option does not allow listing objects within a domain of which the user
	is not a member. Multiple domain names or patterns can be repeated using
	a comma-separated list.

  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Show-vLun  
    LASTEDIT: January 2020
    KEYWORDS: Show-vLun
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[switch]
		$Listcols,
		
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$Showcols, 
		
		[Parameter(Position=2, Mandatory=$false)]
		[switch]
		$ShowsWWN,
		
		[Parameter(Position=3, Mandatory=$false)]
		[switch]
		$ShowsPathSummary,
		
		[Parameter(Position=4, Mandatory=$false)]
		[switch]
		$Hostsum,
		
		[Parameter(Position=5, Mandatory=$false)]
		[switch]
		$ShowsActiveVLUNs,
		
		[Parameter(Position=6, Mandatory=$false)]
		[switch]
		$ShowsVLUNTemplates,
		
		[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$Hostname,
		
		[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$VV_name,
		
		[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$LUN,
		
		[Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$Nodelist,
		
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$Slotlist,
		
		[Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$Portlist,
		
		[Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$DomainName,
		
		[Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Show-vLun - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{			
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Show-vLun since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Show-vLun since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}	
	
	$cmd = "showvlun "
	
	if($Listcols)
	{
		$cmd += " -listcols " 
	}
	if($Showcols)
	{
		$cmd += " -showcols $Showcols" 
	}
	if($ShowsWWN)
	{
		$cmd += " -lvw " 
	}
	if($ShowsPathSummary)
	{
		$cmd += " -pathsum " 
	}
	if($Hostsum)
	{
		$cmd += " -hostsum " 
	}
	if($ShowsActiveVLUNs)
	{
		$cmd += " -a " 
	}
	if($ShowsVLUNTemplates)
	{
		$cmd += " -t " 
	}
	if($Hostname)
	{
		$cmd += " -host $Hostname" 
	}
	if($VV_name)
	{
		$cmd += " -v $VV_name" 
	}
	if($LUN)
	{
		$cmd += " -l $LUN" 
	}
	if($Nodelist)
	{
		$cmd += " -nodes $Nodelist" 
	}
	if($Slotlist)
	{
		$cmd += " -slots $Slotlist" 
	}
	if($Portlist)
	{
		$cmd += " -ports $Portlist" 
	}
	if($DomainName)
	{
		$cmd += " -domain $DomainName" 
	}
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog "Get list of vLUN" "INFO:" 
	
	write-host ""
	return $Result
	
} # End Show-vLun

################################################################################
########################### FUNCTION New-vLun ##################################
################################################################################

Function New-vLun
{
<#
  .SYNOPSIS
    The New-vLun command creates a VLUN template that enables export of a
    Virtual Volume as a SCSI VLUN to a host or hosts. A SCSI VLUN is created when the
    current system state matches the rule established by the VLUN template
  
  .DESCRIPTION
	The New-vLun command creates a VLUN template that enables export of a
    Virtual Volume as a SCSI VLUN to a host or hosts. A SCSI VLUN is created when the
    current system state matches the rule established by the VLUN template.

    There are four types of VLUN templates:
        Port presents - created when only the node:slot:port are specified. The
        VLUN is visible to any initiator on the specified port.

        Host set - created when a host set is specified. The VLUN is visible to
        the initiators of any host that is a member of the set.

        Host sees - created when the hostname is specified. The VLUN is visible
        to the initiators with any of the host's WWNs.

        Matched set - created when both hostname and node:slot:port are
        specified. The VLUN is visible to initiators with the host's WWNs only
        on the specified port.

    Conflicts between overlapping VLUN templates are resolved using
    prioritization, with port presents templates having the lowest priority and
    matched set templates having the highest.
        
  .EXAMPLE
    New-vLun -vvName xyz -LUN 1 -HostName xyz

  .EXAMPLE
    New-vLun -vvSet set:xyz -NoVcn -LUN 2 -HostSet set:xyz
	
  .PARAMETER vvName 
	Specifies the virtual volume or virtual volume set name, using up to 31 characters in length.
	The volume name is provided in the syntax of basename.int.  The VV set
	name must start with "set:".
	
  .PARAMETER vvSet 
	Specifies the virtual volume or virtual volume set name, using up to 31 characters in length.
	The volume name is provided in the syntax of basename.int.  The VV set
	name must start with "set:".
	
  .PARAMETER LUN
	Specifies the LUN as an integer from 0 through 16383. Alternatively
	n+ can be used to indicate a LUN should be auto assigned, but be
	a minimum of n, or m-n to indicate that a LUN should be chosen in the
	range m to n. In addition the keyword auto may be used and is treated
	as 0+.

  .PARAMETER HostName
	Specifies the host where the LUN is exported, using up to 31 characters.

  .PARAMETER HostSet
	Specifies the host set where the LUN is exported, using up to 31
	characters in length. The set name must start with "set:".

  .PARAMETER NSP
	Specifies the system port of the virtual LUN export.
	node
		Specifies the system node, where the node is a number from 0
		through 7.
	slot
		Specifies the PCI bus slot in the node, where the slot is a
		number from 0 through 5.
	port
		Specifies the port number on the FC card, where the port number
		is 1 through 4.

  .PARAMETER Cnt
	Specifies that a sequence of VLUNs, as specified by the num argument,
	are exported to the same system port and host that is created. The num
	argument can be specified as any integer. For each VLUN created, the
	.int suffix of the VV_name specifier and LUN are incremented by one.

  .PARAMETER NoVcn
	Specifies that a VLUN Change Notification (VCN) not be issued after
	export. For direct connect or loop configurations, a VCN consists of a
	Fibre Channel Loop Initialization Primitive (LIP). For fabric
	configurations, a VCN consists of a Registered State Change
	Notification (RSCN) that is sent to the fabric controller.

  .PARAMETER Ovrd
	Specifies that existing lower priority VLUNs will be overridden, if
	necessary. Can only be used when exporting to a specific host.

	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  	  New-vLun  
    LASTEDIT: January 2020
    KEYWORDS: New-vLun
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$vvName,
		
		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$vvSet,
		
		[Parameter(Position=2, Mandatory=$false)]
		[System.String]
		$LUN,
		
		[Parameter(Position=3, Mandatory=$false)]
		[System.String]
		$NSP,
		
		[Parameter(Position=4, Mandatory=$false)]
		[System.String]
		$HostSet,
		
		[Parameter(Position=5, Mandatory=$false)]
		[System.String]
		$HostName,
		
		[Parameter(Position=6, Mandatory=$false)]
		[System.String]
		$Cnt,
		
		[Parameter(Position=7, Mandatory=$false)]
		[switch]
		$NoVcn,
		
		[Parameter(Position=8, Mandatory=$false)]
		[switch]
		$Ovrd,
		
		[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)		
	
	Write-DebugLog "Start: In New-vLun - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting New-vLun since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet New-vLun since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	$cmdVlun = " createvlun -f"
	
	if($Cnt)
	{
		$cmdVlun += " -cnt $Cnt "
	}
	if($NoVcn)
	{
		$cmdVlun += " -novcn "
	}
	if($Ovrd)
	{
		$cmdVlun += " -ovrd "
	}	
	
	###Added v2.1 : checking the parameter values if vvName or present to empty simply return
	if ($vvName -Or $vvSet)
	{
		if($vvName)
		{
			$cmdVlun += " $vvName "
		}
		else
		{
			if ($vvSet -match "^set:")	
			{
				$cmdVlun += " $vvSet "
			}
			else
			{
				return "Please make sure The VV set name must start with set: Ex:- set:xyz"
			}
		}
		
	}
	else
	{
		Write-DebugLog "No values specified for the parameters vvname. so simply exiting " "INFO:"
		Get-help New-vLun
		return
	}
	
	if($LUN)
	{
		$cmdVlun += " $LUN "
	}
	else
	{
		return " Specifies the LUN as an integer from 0 through 16383."
	}
	
	if($NSP)
	{
		$cmdVlun += " $NSP "
	}
	elseif($HostSet)
	{
		if ($HostSet -match "^set:")	
		{
			$cmdVlun += " $HostSet "
		}
		else
		{
			return "Please make sure The set name must start with set: Ex:- set:xyz"
		}
	}
	elseif($HostName)
	{
		$cmdVlun += " $HostName "
	}
	else
	{
		return "Please select atlist any one from NSP | HostSet | HostName"
	}
	
	$Result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $cmdVlun
	write-debuglog "Presenting $vvName to server $item with the command --> $cmdVlun" "INFO:" 
	if($Result1 -match "no active paths")
	{
		$successmsg += $Result1
	}
	elseif([string]::IsNullOrEmpty($Result1))
	{
		$successmsg += "Success : $vvName exported to host $objName`n"
	}
	else
	{
		$successmsg += "FAILURE : While exporting vv $vvName to host $objName Error : $Result1`n"
	}		
	
	return $successmsg
	
} # End New-vLun

############################################################################
########################### FUNCTION Remove-vLun ###########################
############################################################################

Function Remove-vLun
{
<#
  .SYNOPSIS
    Unpresent virtual volumes 
  
  .DESCRIPTION
    Unpresent  virtual volumes 
        
  .EXAMPLE
	Remove-vLun -vvName PassThru-Disk -force
	Unpresent the virtual volume PassThru-Disk to all hosts
	
  .EXAMPLE	
	Remove-vLun -vvName PassThru-Disk -whatif 
	Dry-run of deleted operation on vVolume named PassThru-Disk
	
  .EXAMPLE		
	Remove-vLun -vvName PassThru-Disk -PresentTo INF01  -force
	Unpresent the virtual volume PassThru-Disk only to host INF01.
	all other presentations of PassThru-Disk remain intact.
	
  .EXAMPLE	
	Remove-vLun -PresentTo INF01 -force
	Remove all LUNS presented to host INF01
	
  .EXAMPLE	
	Remove-vLun -vvName CSV* -PresentTo INF01 -force
	Remove all LUNS started with CSV* and presented to host INF01
	
  .EXAMPLE
	Remove-vLun -vvName vol2 -force -Novcn
   
  .EXAMPLE
	Remove-vLun -vvName vol2 -force -Pat
   
  .EXAMPLE
	Remove-vLun -vvName vol2 -force -Remove_All   
	It removes all vluns associated with a VVOL Container.
	
  .PARAMETER whatif
    If present, perform a dry run of the operation and no VLUN is removed	

  .PARAMETER force
	If present, perform forcible delete operation
	
  .PARAMETER vvName 
    Specify name of the volume to be exported. 
	
  .PARAMETER PresentTo 
    Specify name of the hosts where vLUns are presented to.
	
  .PARAMETER Novcn
	Specifies that a VLUN Change Notification (VCN) not be issued after removal of the VLUN.
		
  .PARAMETER Pat
	Specifies that the <VV_name>, <LUN>, <node:slot:port>, and <host_name> specifiers are treated as glob-style patterns and that all VLUNs matching the specified pattern are removed.
	
  .PARAMETER Remove_All
	It removes all vluns associated with a VVOL Container.
		
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Remove-vLun  
    LASTEDIT: January 2020
    KEYWORDS: Remove-vLun
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$force, 
		
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$whatif, 		
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$vvName,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$PresentTo, 		
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Novcn,
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Pat,
		
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Remove_All,
		
		[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Remove-vLun - validating input values" $Debug 
	 
	if (!(($vvName) -or ($PresentTo)))
	{
		Write-DebugLog "Action required: no vv or no host mentioned - simply exiting " $Debug
		Get-help Remove-vLun
		return
	}
	if(!(($force) -or ($whatif)))
	{
		write-debuglog "no -force or -whatif option selected to remove/dry run of VLUN, Exiting...." "INFO:"
		Get-help Remove-vLun
		return "FAILURE : no -force or -whatif option selected to remove/dry run of VLUN"
	}
	
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{	
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Remove-vLun since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Remove-vLun since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	if($PresentTo)
	{
		$ListofvLuns = Get-vLun -vvName $vvName -PresentTo $PresentTo -SANConnection $SANConnection
	}
	else
	{
		$ListofvLuns = Get-vLun -vvName $vvName -SANConnection $SANConnection
	}
	if($ListofvLuns -match "FAILURE")
	{
		return "FAILURE : No vLUN $vvName found"
	}
	$ActionCmd = "removevlun "
	if ($whatif)
	{
		$ActionCmd += "-dr "
	}
	else
	{
		if($force)
		{
			$ActionCmd += "-f "
		}		
	}	
	if ($Novcn)
	{
		$ActionCmd += "-novcn "
	}
	if ($Pat)
	{
		$ActionCmd += "-pat "
	}
	if($Remove_All)
	{
		$ActionCmd += " -set "
	}
	if ($ListofvLuns)
	{
		foreach ($vLUN in $ListofvLuns)
		{
			$vName = $vLUN.Name
			if ($vName)
			{
				$RemoveCmds = $ActionCmd + " $vName $($vLun.LunID) $($vLun.PresentTo)"
				$Result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $RemoveCmds
				write-debuglog "Removing Virtual LUN's with command $RemoveCmds" "INFO:" 
				if ($Result1 -match "Issuing removevlun")
				{
					$successmsg += "Success: Unexported vLUN $vName from $($vLun.PresentTo)"
				}
				elseif($Result1 -match "Dry run:")
				{
					$successmsg += $Result1
				}
				else
				{
					$successmsg += "FAILURE : While unexporting vLUN $vName from $($vLun.PresentTo) "
				}				
			}
		}
		return $successmsg
	}
	
	else
	{
		Write-DebugLog "no vLUN found for $vvName presented to host $PresentTo." $Info
		return "FAILURE : no vLUN found for $vvName presented to host $PresentTo"
	}
	

} # END Remove-vLun

Export-ModuleMember Get-vLun , Show-vLun , New-vLun , Remove-vLun
# SIG # Begin signature block
# MIIhEAYJKoZIhvcNAQcCoIIhATCCIP0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCHlAIz0eJyi219
# SdU8m6ClvLNUC25c3w2eb61bLNVgUqCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPuzCCD7cCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# YSXa7u2E/CUTa2l7w0ST5dITivmkHES2tkdOzPjfFVgwDQYJKoZIhvcNAQEBBQAE
# ggEACWwBi1diXElMWhzO5nHEVKGg2IV+UBfcYfcBPBLteat1f09S9Y5fR5ST0RqF
# O3t7+gczVW/T++30sz109kB8WvZTyEqCs4dfTIo+P43aGGy0le13+9SXzYBBkw4l
# uutHR+ceYwL9g2/R5aRq3LmA47Vr5/kkBxY1WqvN1RiDsLn6LEJK5J5jFdrq+q9f
# 8D/MJhffy6GvaNYuhG0BzHntLSMQhoJZ5SfGXJn9NLpIIx7DnUZLkbhg5/4+weLK
# VmEhbx4vIGWv0FP+gkQq4cXQUT7Q91at3xpD/QPt9trCsGBjNJboA7CknuD8O4pj
# WPHfoInOhc/U7xLKGR7UYF8sUKGCDX0wgg15BgorBgEEAYI3AwMBMYINaTCCDWUG
# CSqGSIb3DQEHAqCCDVYwgg1SAgEDMQ8wDQYJYIZIAWUDBAIBBQAwdwYLKoZIhvcN
# AQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCA+YBep
# 3gK9P2yi7NHSUx3+5vAt1pKbRPSPdL+RITp2yQIQeSw8nnG7nOaF0z+RtNvHoxgP
# MjAyMTA2MTkwNDM3MzRaoIIKNzCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA
# 8N0wDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAxMDEw
# MDAwMDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjEw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXKY2tR
# 1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj/TZq
# gfop+N0rcIXeAhjzeG28ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj
# 4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDrDo4s
# 1SPa9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDC
# m2mCtNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1JhL0B
# AgMBAAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATApMCcG
# CCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgw
# FoAU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwoLR1E
# Nt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9zaGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdpY2Vy
# dC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURU
# aW1lc3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrn
# IA6OZ0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQCZk3t
# aaQP9rhwz2Lo9VFKeHk2eie38+dSn5On7UOee+e03UEiifuHokYDTvz0/rdkd2Nf
# I1Jpg4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO+MDh
# XM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j1h9b
# m/cuG08THfdKDXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5Npjhyyja
# W4emii8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHkBdo2l8IVMA0GCSqGSIb3DQEB
# CwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQg
# SUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0zMTAxMDcxMjAwMDBaMHIxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBU
# aW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9
# 0DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5fU1ofue2oPSNs4jkl79jIZCY
# vxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb6+NGRwYaVX4LJ37AovWg4N4i
# Pw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU46gJcWvgzyIQD3XPcXJOCq3f
# QDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mIUF79Zm5WYScpiYRR5oLnRlD9
# lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfxFwbvPc3WTe8GQv2iUypPhR3E
# HTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAdBgNVHQ4EFgQU9LbhIB3+Ka7S
# 5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wEgYD
# VR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4
# oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkwRzA4BgpghkgBhv1sAAIEMCow
# KAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJYIZI
# AYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLpUYdWac3v3dp8qmN6s3jPBjdA
# hO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4
# stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC4HLHmNY8ZOUfSBAYX4k4YU1i
# RiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+tpJn+1Nhiaj1a5bA9FhpDXzI
# AbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6HUSHkWGCbugwtK22ixH67xCUr
# RwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIvIjayS6JKldj1po5SMYIChjCC
# AoICAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hB
# MiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TAN
# BglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJ
# KoZIhvcNAQkFMQ8XDTIxMDYxOTA0MzczNFowKwYLKoZIhvcNAQkQAgwxHDAaMBgw
# FgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJKoZIhvcNAQkEMSIEICp6+iSc3tuA
# thu6+fSzKmDSPIOZARb0QXyFEyq3unDCMDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIE
# ILMQkAa8CtmDB5FXKeBEA0Fcg+MpK2FPJpZMjTVx7PWpMA0GCSqGSIb3DQEBAQUA
# BIIBABVIP9WkFSScQkZsRm5W0Z9YOd+pTxjpntI/fV9amJFpu+VoLm9dODg0iZx8
# 2Hv2ZfFacI0A5YqxxbpS0KD2wqcAJTB+D78x8ItpfSl4z42GQi54qswAlREKWrid
# uhc5pLGY4HYtJr7dV0TJgR4ge36mBMb+Oxv4aMPh3ZSdf6yhPp8CZcbz4eG0TZ45
# 8/mZBSSFGmfC013KPlTZFjLFhiN+m1O8/BbICMAGVrlZ6pZQoC4MRSAYk503jGV2
# v7dw+RjZPG8E6KKOBVRwPW/lq/dCExxq5dVtWEG5FbpwzcZ7y6GTDf4HcP/4szQq
# 4BQPlsy3M03+uufcHnbnXumghjY=
# SIG # End signature block
