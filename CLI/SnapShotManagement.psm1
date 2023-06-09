﻿####################################################################################
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
##	File Name:		SnapShotManagement.psm1
##	Description: 	SnapShot Management cmdlets 
##		
##	Created:		December 2019
##	Last Modified:	December 2019
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

#####################################################################################################################
## FUNCTION New-GroupSnapVolume
#####################################################################################################################

Function New-GroupSnapVolume
{
<#
  .SYNOPSIS
    creates consistent group snapshots
  
  .DESCRIPTION
	creates consistent group snapshots
        
  .EXAMPLE
	New-GroupSnapVolume.

  .EXAMPLE
	New-GroupSnapVolume -vvNames WSDS_compr02F.
	
  .EXAMPLE
	New-GroupSnapVolume -vvNames WSDS_compr02F -exp 2d
 
  .EXAMPLE
	New-GroupSnapVolume -vvNames WSDS_compr02F -retain 2d
  
  .EXAMPLE
	New-GroupSnapVolume -vvNames WSDS_compr02F -Comment Hello
	
  .EXAMPLE
	New-GroupSnapVolume -vvNames WSDS_compr02F -OR
	
  .PARAMETER vvNames 
    Specify the Existing virtual volume with comma(,) seperation ex: vv1,vv2,vv3.

  .PARAMETER OR
	-or
	
  .PARAMETER Comment 	
	 Specifies any additional information up to 511 characters for the volume.
	
  .PARAMETER exp 
	Specifies the relative time from the current time that volume will expire. <time>[d|D|h|H] <time> is a positive integer value and in the range of 1 - 43,800 hours (1,825 days). Time can be optionally specified in days
	or hours providing either d or D for day and h or H for hours following the entered time value.
    
  .PARAMETER retain
	Specifies the amount of time, relative to the current time, that the volume will be retained.-retain <time>[d|D|h|H]
	<time> is a positive integer value and in the range of 1 - 43,800 hours (1,825 days). Time can be
	optionally specified in days or hours providing either d or D for day and h or H for hours following
	the entered time value.
	
  .PARAMETER Match
	By default, all snapshots are created read-write. The -ro option
	instead specifies that all snapshots created will be read-only.
	The -match option specifies that snapshots are created matching
	each parent's read-only or read-write setting. The -ro and -match
	options cannot be combined. Either of these options can be overridden
	for an individual snapshot VV in the colon separated specifiers.
  
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  New-GroupSnapVolume  
    LASTEDIT: December 2019
    KEYWORDS: New-GroupSnapVolume
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
 [CmdletBinding()]
	param(
	
		[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$vvNames,
		
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$OR, 
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$exp,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$retain,
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$Comment,
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Match,
								
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)	
	Write-DebugLog "Start: In New-GroupSnapVolume - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting New-GroupSnapVolume since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet New-GroupSnapVolume since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	if ($vvNames)
	{
		$CreateGSVCmd = "creategroupsv" 

		if($exp)
		{
			$CreateGSVCmd += " -exp $exp "
		}
		if($retain)
		{
			$CreateGSVCmd += " -f -retain $retain "
		}		
		if($Comment)
		{
			$CreateGSVCmd += " -comment $Comment "
		}
		if($OR)
		{
			$CreateGSVCmd += " -ro "
		}
		if($Match)
		{
			$CreateGSVCmd += " -match "
		}
		$vvName1 = $vvNames.Split(',')
		## Check vv Name 
		$limit = $vvName1.Length - 1
		foreach($i in 0..$limit)
		{
			if ( !( Test-CLIObject -objectType 'vv' -objectName $vvName1[$i] -SANConnection $SANConnection))
			{
				write-debuglog " VV $vvName1[$i] does not exist. Please use New-VV to create a VV before creating GroupSnapVolume" "INFO:" 
				return "FAILURE : No vv $vvName1[$i] found"
			}
		}
		
		$CreateGSVCmd += " $vvName1 "	
		$result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $CreateGSVCmd
		write-debuglog " Creating Snapshot Name with the command --> $CreateGSVCmd" "INFO:"
		if($result1 -match "CopyOfVV")
		{
			return "Success : Executing New-GroupSnapVolume `n $result1"
		}
		else
		{
			return "FAILURE : Executing New-GroupSnapVolume `n $result1"
		}		
	}
	else
	{
		write-debugLog "No vvNames specified for new Snapshot volume. Skip creating Group Snapshot volume" "ERR:"
		Get-help New-GroupSnapVolume
		return	
	}
}# END New-GroupSnapVolume	

#####################################################################################################################
## FUNCTION New-GroupVvCopy
######################################################################################################################

Function New-GroupVvCopy
{
<#
  .SYNOPSIS
    Creates consistent group physical copies of a list of virtualvolumes.
  
  .DESCRIPTION
	Creates consistent group physical copies of a list of virtualvolumes.
  
  .EXAMPLE
    New-GroupVvCopy -P -parent_VV ZZZ -destination_VV ZZZ 
	
  .EXAMPLE
    New-GroupVvCopy -P -Online -parent_VV ZZZ -destination_cpg ZZZ -VV_name ZZZ -wwn 123456
	
  .EXAMPLE
    New-GroupVvCopy -R -destination_VV ZZZ
	
  .EXAMPLE
    New-GroupVvCopy -Halt -destination_VV ZZZ
	
  .PARAMETER parent_VV 
    Indicates the parent virtual volume.
	
  .PARAMETER destination_VV
	Indicates the destination virtual volume. 
	
  .PARAMETER destination_cpg
	 Specifies the destination CPG to use for the destination volume if the -online option is specified.
	 
  .PARAMETER VV_name
     Specifies the virtual volume name to use for the destination volume if the -online option is specified.
	 
  .PARAMETER wwn
     Specifies the WWN to use for the destination volume if the -online option is specified.
  
  .PARAMETER P
	Starts a copy operation from the specified parent volume (as indicated
	using the <parent_VV> specifier) to its destination volume (as indicated
	using the <destination_VV> specifier).
		
  .PARAMETER  R
	Resynchronizes the set of destination volumes (as indicated using the
	<destination_VV> specifier) with their respective parents using saved
	snapshots so that only the changes made since the last copy or
	resynchronization are copied. 

  .PARAMETER Halt
	Cancels an ongoing physical copy. 

  .PARAMETER S
	Saves snapshots of the parent volume (as indicated with the <parent_VV>
	specifier) for quick resynchronization and to retain the parent-copy
	relationships between each parent and destination volume. 

  .PARAMETER B
	Use this specifier to block until all the copies are complete. Without
	this option, the command completes before the copy operations are
	completed (use the showvv command to check the status of the copy
	operations).

  .PARAMETER Priority <high|med|low>
	Specifies the priority of the copy operation when it is started. This
	option allows the user to control the overall speed of a particular task.
	If this option is not specified, the creategroupvvcopy operation is
	started with default priority of medium. High priority indicates that
	the operation will complete faster. Low priority indicates that the
	operation will run slower than the default priority task. This option
	cannot be used with -halt option.

  .PARAMETER Online
	Specifies that the copy is to be performed online. 

  .PARAMETER Skip_zero
	When copying from a thin provisioned source, only copy allocated
	portions of the source VV.

  .PARAMETER TPVV
	Indicates that the VV the online copy creates should be a thinly
	provisioned volume. Cannot be used with the -dedup option.

  .PARAMETER TdVV
	This option is deprecated, see -dedup.

  .PARAMETER Dedup
	Indicates that the VV the online copy creates should be a thinly
	deduplicated volume, which is a thinly provisioned volume with inline
	data deduplication. This option can only be used with a CPG that has
	SSD (Solid State Drive) device type. Cannot be used with the -tpvv
	option.

  .PARAMETER Compressed
	Indicates that the VV the online copy creates should be a compressed
	virtual volume.    

  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-PoshSshConnection Or New-CLIConnection
	
  .Notes
    NAME:  New-GroupVvCopy  
    LASTEDIT: December 2019
    KEYWORDS: New-GroupVvCopy
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$parent_VV,
		
		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$destination_VV,
		
		[Parameter(Position=2, Mandatory=$false)]
		[System.String]
		$destination_cpg,
		
		[Parameter(Position=3, Mandatory=$false)]
		[System.String]
		$VV_name,
		
		[Parameter(Position=4, Mandatory=$false)]
		[System.String]
		$wwn,
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$P,
		
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$R,
		
		[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Halt,
		
		[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$S,
		
		[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$B,
		
		[Parameter(Position=10, Mandatory=$false)]
		[System.String]		
		$Priority,
		
		[Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Skip_zero,
		
		[Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Online,
		
		[Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$TPVV,
		
		[Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$TdVV,
		
		[Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Dedup,
		
		[Parameter(Position=16, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Compressed,		
		
		[Parameter(Position=17, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection
	)		
	
	Write-DebugLog "Start: In New-GroupVvCopy - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting New-GroupVvCopy since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet New-GroupVvCopy since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
		
	$groupvvcopycmd = "creategroupvvcopy "		
	
	if($P)
	{
		$groupvvcopycmd += " -p "
	}
	elseif($R)
	{
		$groupvvcopycmd += " -r "
	}
	elseif($Halt)
	{
		$groupvvcopycmd += " -halt "
	}
	else
	{
		return "Select At least One from P R or Halt"
	}
	
	if($S)
	{
		$groupvvcopycmd += " -s "
	}
	if($B)
	{
		$groupvvcopycmd += " -b "
	}
	if($Priority)
	{
		$groupvvcopycmd += " -pri $Priority "
	}
	if($Skip_zero)
	{
		$groupvvcopycmd += " -skip_zero "
	}
	if($Online)
	{
		$groupvvcopycmd += " -online "
		if($TPVV)
		{
			$groupvvcopycmd += " -tpvv "
		}
		if($TdVV)
		{
			$groupvvcopycmd += " -tdvv "
		}
		if($Dedup)
		{
			$groupvvcopycmd += " -dedup "
		}
		if($Compressed)
		{
			$groupvvcopycmd += " -compr "
		}								
	}
	if($parent_VV)
	{
		$groupvvcopycmd += " $parent_VV"
		$groupvvcopycmd += ":"
	}
	if($destination_VV)
	{
		$groupvvcopycmd += "$destination_VV"
	}
	if($destination_cpg)
	{
		$groupvvcopycmd += "$destination_cpg"
		$groupvvcopycmd += ":"
	}
	if($VV_name)
	{
		$groupvvcopycmd += "$VV_name"
	}
	if($wwn)
	{
		$groupvvcopycmd += ":"
		$groupvvcopycmd += "$wwn"
	}	
	$Result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $groupvvcopycmd
	write-debuglog " Creating consistent group fo Virtual copies with the command --> $groupvvcopycmd" "INFO:"
	if ($Result1 -match "TaskID")
	{
		$outmessage += "Success : `n $Result1"
	}
	else
	{
		$outmessage += "FAILURE : `n $Result1"
	}
	return $outmessage
}# END New-GroupVvCopy

####################################################################################################################
## FUNCTION New-SnapVolume
#####################################################################################################################
Function New-SnapVolume
{
<#
  .SYNOPSIS
    creates a point-in-time (snapshot) copy of a virtual volume.
  
  .DESCRIPTION
	creates a point-in-time (snapshot) copy of a virtual volume.
        
  .EXAMPLE
   New-SnapVolume -svName svr0_vv0 -vvName vv0 
   Ceates a read-only snapshot volume "svro_vv0" from volume "vv0" 
   
  .EXAMPLE
   New-SnapVolume  -svName svr0_vv0 -vvName vv0 -ro -exp 25H
   Ceates a read-only snapshot volume "svro_vv0" from volume "vv0" and that will expire after 25 hours
   
  .EXAMPLE
   New-SnapVolume -svName svrw_vv0 -vvName svro_vv0
   creates snapshot volume "svrw_vv0" from the snapshot "svro_vv0"
   
  .EXAMPLE
   New-SnapVolume -ro svName svro-@vvname@ -vvSetName set:vvcopies 
   creates a snapshot volume for each member of the VV set "vvcopies". Each snapshot will be named svro-<name of parent virtual volume>:
  
  .PARAMETER svName 
    Specify  the name of the Snap shot	
	
  .PARAMETER vvName 
    Specifies the parent volume name or volume set name. 

  .PARAMETER vvSetName 
    Specifies the virtual volume set names as set: vvset name example: "set:vvcopies" 
	
  .PARAMETER Comment 
    Specifies any additional information up to 511 characters for the volume. 
	
  .PARAMETER VV_ID 
    Specifies the ID of the copied VV set. This option cannot be used when VV set is specified. 
	
  .PARAMETER Rcopy 
     Specifies that synchronous snapshots be taken of a volume in a remote copy group. 
	
  .PARAMETER exp 
    Specifies the relative time from the current time that volume will expire.-exp <time>[d|D|h|H]
	<time> is a positive integer value and in the range of 1 - 43,800 hours (1,825 days). Time can be optionally specified in days or hours providing either d or D for day and h or H for hours following the entered time value. 
	
  .PARAMETER retain
	Specifies the amount of time, relative to the current time, that the volume will be retained. <time>
	is a positive integer value and in the range of 1 - 43,800 hours (1,825 days). Time can be
	optionally specified in days or hours providing either d or D for day and h or H for hours following
	the entered time value.

  .PARAMETER ro
	Specifies that the copied volume is read-only. If not specified, the
	volume is read/write.	
  
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  New-SnapVolume  
    LASTEDIT: December 2019
    KEYWORDS: New-SnapVolume
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
 [CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$svName,
				
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$vvName,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$VV_ID,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$exp,
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$retain,
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$ro, 
		
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Rcopy,
		
		[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$vvSetName,	

		[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$Comment,
						
		[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)	

	Write-DebugLog "Start: In New-SnapVolume - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting New-SnapVolume since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet New-SnapVolume since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}	
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}	
	if ($svName)
	{
		if ($vvName)
		{
			## Check vv Name 
			if ( !( Test-CLIObject -objectType 'vv' -objectName $vvName -SANConnection $SANConnection))
			{
				write-debuglog " VV $vvName does not exist. Please use New-VV to create a VV before creating SV" "INFO:" 
				return "FAILURE :  No vv $vvName found"
			}
			
			$CreateSVCmd = "createsv" 
			
			if($ro)
			{
				$CreateSVCmd += " -ro "
			}
			if($Rcopy)
			{
				$CreateSVCmd += " -rcopy "
			}
			if($VV_ID)
			{
				$CreateSVCmd += " -i $VV_ID "
			}
			if($exp)
			{
				$CreateSVCmd += " -exp $exp "
			}
			if($retain)
			{
				$CreateSVCmd += " -f -retain $retain  "
			}
			if($Comment)
			{
				$CreateSVCmd += " -comment $Comment  "
			}
			$CreateSVCmd +=" $svName $vvName "

			$result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $CreateSVCmd
			write-debuglog " Creating Snapshot Name $svName with the command --> $CreateSVCmd" "INFO:"
			if([string]::IsNullOrEmpty($result1))
			{
				return  "Success : Created virtual copy $svName"
			}
			else
			{
				return  "FAILURE : While creating virtual copy $svName $result1"
			}		
		}
		# If VolumeSet is specified then add SV to VVset
		elseif ($vvSetName)
		{
			if ( $vvSetName -match "^set:")	
			{
				$objName = $vvSetName.Split(':')[1]
				$objType = "vv set"
				if ( ! (Test-CLIObject -objectType $objType -objectName $objName -SANConnection $SANConnection))
				{
					Write-DebugLog " VV set $vvSetName does not exist. Please use New-VVSet to create a VVSet before creating SV" "INFO:"
					return "FAILURE : No vvset $vvsetName found"
				}
				$CreateSVCmdset = "createsv" 
				
				if($ro)
				{
					$CreateSVCmdset += " -ro "
				}
				if($Rcopy)
				{
					$CreateSVCmdset += " -rcopy "
				}
				if($exp)
				{
					$CreateSVCmdset += " -exp $exp "
				}
				if($retain)
				{
					$CreateSVCmdset += " -f -retain $retain  "
				}
				if($Comment)
				{
					$CreateSVCmdset += " -comment $Comment  "
				}
				$CreateSVCmdset +=" $svName $vvSetName "
				
				$result2 = Invoke-CLICommand -Connection $SANConnection -cmds  $CreateSVCmdset
				write-debuglog " Creating Snapshot Name $svName with the command --> $CreateSVCmdset" "INFO:" 	
				if([string]::IsNullOrEmpty($result2))
				{
					return  "Success : Created virtual copy $svName"
				}
				elseif($result2 -match "use by volume")
				{
					return "FAILURE : While creating virtual copy $result2"
				}
				else
				{
					return  "FAILURE : While creating virtual copy $svName $result2"
				}
			}
			else
			{
				return "VV Set name must contain set:"
			}
		}
		else
		{
			write-debugLog "No VVset or VVName specified to assign snapshot to it" "ERR:" 
			return "FAILURE : No vvset or vvname specified"
		}
		
		
	}
	else
	{
		write-debugLog "No svName specified for new Snapshot volume. Skip creating Snapshot volume" "ERR:"
		Get-help New-SnapVolume
		return	
	}
}#END New-SnapVolume

#####################################################################################################################
## FUNCTION New-VvCopy
#####################################################################################################################
Function New-VvCopy
{
<#
  .SYNOPSIS
    Creates a full physical copy of a Virtual Volume (VV) or a read/write virtual copy on another VV.
  
  .DESCRIPTION
	Creates a full physical copy of a Virtual Volume (VV) or a read/write virtual copy on another VV.
        
  .EXAMPLE
    New-VvCopy -parentName VV1 -vvCopyName VV2
	
  .EXAMPLE		
	New-VvCopy -parentName VV1 -vvCopyName VV2 -online -CPGName ZZZ

  .EXAMPLE
	New-VvCopy -parentName as1 -vvCopyName as3 -online -CPGName asCpg -Tpvv

  .EXAMPLE
	New-VvCopy -parentName as1 -vvCopyName as3  -Tdvv

  .EXAMPLE
	New-VvCopy -parentName as1 -vvCopyName as3  -Dedup

  .EXAMPLE
	New-VvCopy -parentName as1 -vvCopyName as3  -Compr

  .EXAMPLE
	New-VvCopy -parentName as1 -vvCopyName as3  -AddToSet

  .EXAMPLE
	New-VvCopy -parentName as1 -vvCopyName as3 -Priority med
	
  .PARAMETER parentName 
    Specify name of the parent Virtual Volume
	
  .PARAMETER Online 
    Create an online copy of Virtual Volume
	
  .PARAMETER vvCopyName 
    Specify name of the virtual Volume Copy name
	
  .PARAMETER CPGName
    Specify the name of CPG

  .PARAMETER snapcpg
	Specifies the name of the CPG from which the snapshot space will be allocated
 
  .PARAMETER Tpvv
	Indicates that the VV the online copy creates should be a thinly
	provisioned volume. Cannot be used with the -dedup option.

  .PARAMETER Tdvv
	This option is deprecated, see -dedup.

  .PARAMETER Dedup
	Indicates that the VV the online copy creates should be a thinly
	deduplicated volume, which is a thinly provisioned volume with inline
	data deduplication. This option can only be used with a CPG that has
	SSD (Solid State Drive) device type. Cannot be used with the -tpvv
	option.

  .PARAMETER Compr
	Indicates that the VV the online copy creates should be a compressed
	virtual volume.
		
  .PARAMETER AddToSet 
	Adds the VV copies to the specified VV set. The set will be created if
	it does not exist. Can only be used with -online option.
		
  .PARAMETER R
	Specifies that the destination volume be re-synchronized with its parent
	volume using a saved snapshot so that only the changes since the last
	copy or resynchronization need to be copied.

  .PARAMETER Halt
	Specifies that an ongoing physical copy to be stopped. This will cause
	the destination volume to be marked with the 'cpf' status, which will be
	cleared up when a new copy is started.

  .PARAMETER Save
	Saves the snapshot of the source volume after the copy of the volume is
	completed. This enables a fast copy for the next resynchronization. If
	not specified, the snapshot is deleted and the association of the
	destination volume as a copy of the source volume is removed.  The -s
	option is implied when the -r option is used and need not be explicitly
	specified.

  .PARAMETER Blocks
	Specifies that this command blocks until the operation is completed. If
	not specified, the createvvcopy command operation is started as a
	background task.

  .PARAMETER priority
	Specifies the priority of the copy operation when it is started. This
	option allows the user to control the overall speed of a particular
	task.  If this option is not specified, the createvvcopy operation is
	started with default priority of medium. High priority indicates that
	the operation will complete faster. Low priority indicates that the
	operation will run slower than the default priority task. This option
	cannot be used with -halt option.
		
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  New-VvCopy  
    LASTEDIT: December 2019
    KEYWORDS: New-VvCopy
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[System.String]
		$parentName,
		
		[Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$vvCopyName,

		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
        $online,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
        $CPGName,		
	
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
        $snapcpg,
	
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Tpvv,
		
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Tdvv,
		
		[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Dedup,
		
		[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Compr,
		
		[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$AddToSet,

		[Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
        $R,
		
		[Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
        $Halt,
		
		[Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
        $Saves,
		
		[Parameter(Position=13, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
        $Blocks,
		
		[Parameter(Position=14, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
        $Priority,
	
		[Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)
	
	Write-DebugLog "Start: In New-VvCopy - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting New-VvCopy since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet New-VvCopy since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}	
	if(!(($parentName) -and ($vvCopyName)))
	{
		write-debuglog " Please specify values for parentName and vvCopyName " "INFO:" 
		Get-help New-VvCopy
		return "FAILURE : Please specify values for parentName and vvCopyName"	
	}
	if ( $parentName -match "^set:")	
	{
		$objName = $item.Split(':')[1]
		$vvsetName = $objName
		$objType = "vv set"
		#$objMsg  = $objType
		if(!( Test-CLIObject -objectType $objType  -objectName $vvsetName -SANConnection $SANConnection))
		{
			write-debuglog " vvset $vvsetName does not exist. Please use New-VvSet to create a new vvset " "INFO:" 
			return "FAILURE : No vvset $vvSetName found"
		}
	}
	else
	{
		if(!( Test-CLIObject -objectType "vv"  -objectName $parentName -SANConnection $SANConnection))
		{
			write-debuglog " vv $parentName does not exist. Please use New-Vv to create a new vv " "INFO:" 
			return "FAILURE : No parent VV  $parentName found"
		}
	}
	if($online)
	{			
		if(!( Test-CLIObject -objectType 'cpg' -objectName $CPGName -SANConnection $SANConnection))
		{
			write-debuglog " CPG $CPGName does not exist. Please use New-CPG to create a CPG " "INFO:" 
			return "FAILURE : No cpg $CPGName found"
		}		
		if( Test-CLIObject -objectType 'vv' -objectName $vvCopyName -SANConnection $SANConnection)
		{
			write-debuglog " vv $vvCopyName is exist. For online option vv should not be exists..." "INFO:" 
			#return "FAILURE : vv $vvCopyName is exist. For online option vv should not be exists..."
		}		
		$vvcopycmd = "createvvcopy -p $parentName -online "
		if($snapcpg)
		{
			if(!( Test-CLIObject -objectType 'cpg' -objectName $snapcpg -SANConnection $SANConnection))
			{
				write-debuglog " Snapshot CPG $snapcpg does not exist. Please use New-CPG to create a CPG " "INFO:" 
				return "FAILURE : No snapshot cpg $snapcpg found"
			}
			$vvcopycmd += " -snp_cpg $snapcpg"
		}
				
		if($Tpvv)
		{
			$vvcopycmd += " -tpvv "
		}
		if($Tdvv)
		{
			$vvcopycmd += " -tdvv "
		}
		if($Dedup)
		{
			$vvcopycmd += " -dedup "
		}
		if($Compr)
		{
			$vvcopycmd += " -compr "
		}
		if($AddToSet)
		{
			$vvcopycmd += " -addtoset "
		}
		if($Halt)
		{
			$vvcopycmd += " -halt "
		}
		if($Saves)
		{
			$vvcopycmd += " -s "
		}
		if($Blocks)
		{
			$vvcopycmd += " -b "
		}
		if($Priority)
		{
			$a = "high","med","low"
			$l=$Priority
			if($a -eq $l)
			{
				$vvcopycmd += " -pri $Priority "			
			}
			else
			{ 
				Write-DebugLog "Stop: Exiting Since -Priority $Priority in incorrect "
				Return "FAILURE : -Priority :- $Priority is an Incorrect Priority  [high | med | low]  can be used only . "
			}
			
		}
		if($CPGName)
		{
			$vvcopycmd += " $CPGName "
		}
		
		$vvcopycmd += " $vvCopyName"
		
		$Result4 = Invoke-CLICommand -Connection $SANConnection -cmds  $vvcopycmd
		write-debuglog " Creating online vv copy with the command --> $vvcopycmd" "INFO:" 
		if($Result4 -match "Copy was started.")
		{		
			return "Success : $Result4"
		}
		else
		{
			return "FAILURE : $Result4"
		}		
	}
	else
	{
		$vvcopycmd = " createvvcopy "
		if($R)
		{ 
			$vvcopycmd += " -r"
		}
		if($Halt)
		{
			$vvcopycmd += " -halt "
		}
		if($Saves)
		{
			$vvcopycmd += " -s "
		}
		if($Blocks)
		{
			$vvcopycmd += " -b "
		}
		if($Priority)
		{
			$a = "high","med","low"
			$l=$Priority
			if($a -eq $l)
			{
				$vvcopycmd += " -pri $Priority "			
			}
			else
			{ 
				Write-DebugLog "Stop: Exiting Since -Priority $Priority in incorrect "
				Return "FAILURE : -Priority :- $Priority is an Incorrect Priority  [high | med | low]  can be used only . "
			}			
		}
		if( !(Test-CLIObject -objectType 'vv' -objectName $vvCopyName -SANConnection $SANConnection))
		{
			write-debuglog " vv $vvCopyName does not exist.Please speicify existing vv name..." "INFO:" 
			return "FAILURE : No vv $vvCopyName found"
		}
		$vvcopycmd += " -p $parentName $vvCopyName"
		
		$Result3 = Invoke-CLICommand -Connection $SANConnection -cmds  $vvcopycmd
		write-debuglog " Creating Virtual Copy with the command --> $vvcopycmd" "INFO:" 
		write-debuglog " Check the task status using Get-Task command --> Get-Task " "INFO:"
		if($Result3 -match "Copy was started")
		{
			return "Success : $Result3"
		}
		else
		{
			return "FAILURE : $Result3"
		}
	}

}# End New-VvCopy

#####################################################################################################################
## FUNCTION Push-GroupSnapVolume
#####################################################################################################################

Function Push-GroupSnapVolume
{
<#
  .SYNOPSIS
    Copies the differences of snapshots back to their base volumes.
  
  .DESCRIPTION
	Copies the differences of snapshots back to their base volumes.
        
  .EXAMPLE
    Push-GroupSnapVolume
	
  .EXAMPLE
	Push-GroupSnapVolume -VVNames WSDS_compr02F

  .EXAMPLE
	Push-GroupSnapVolume -VVNames "WSDS_compr02F"

  .EXAMPLE
	Push-GroupSnapVolume -VVNames "tesWSDS_compr01t_lun"

  .EXAMPLE
	Push-GroupSnapVolume -VVNames WSDS_compr01 -RCP

  .EXAMPLE
	Push-GroupSnapVolume -VVNames WSDS_compr01 -Halt

  .EXAMPLE
	Push-GroupSnapVolume -VVNames WSDS_compr01 -PRI high

  .EXAMPLE
	Push-GroupSnapVolume -VVNames WSDS_compr01 -Online

  .EXAMPLE
	Push-GroupSnapVolume -VVNames WSDS_compr01 -TargetVV at

  .EXAMPLE
	Push-GroupSnapVolume -VVNames WSDS_compr01 -TargetVV y

  .PARAMETER VVNames 
    Specify virtual copy name of the Snap shot
	
  .PARAMETER TargetVV 
    Target vv Name

  .PARAMETER RCP 
	Allows the promote operation to proceed even if the RW parent volume is
	currently in a Remote Copy volume group, if that group has not been
	started. If the Remote Copy group has been started, this command fails.
	This option cannot be used in conjunction with the -halt option.

  .PARAMETER Halt 
    Cancels ongoing snapshot promotions. Marks the RW parent volumes with
	the "cpf" status that can be cleaned up using the promotevvcopy command
	or by issuing a new instance of the promotesv/promotegroupsv command.
	This option cannot be used in conjunction with any other option.

  .PARAMETER PRI 
    Specifies the priority of the copy operation when it is started. This
	option allows the user to control the overall speed of a particular
	task.  If this option is not specified, the promotegroupsv operation is
	started with default priority of medium. High priority indicates that
	the operation will complete faster. Low priority indicates that the
	operation will run slower than the default priority task. This option
	cannot be used with -halt option.

  .PARAMETER Online 
    Indicates that the promote operation will be executed while the target
	volumes have VLUN exports. The hosts should take the target LUNs offline
	to initiate the promote command, but can be brought online and used
	during the background tasks. Each specified virtual copy and its base
	volume must be the same size. The base volume is the only possible
	target of online promote, and is the default. To halt a promote started
	with the online option, use the canceltask command. The -halt, -target,
	and -pri options cannot be combined with the -online option.	
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Push-GroupSnapVolume
    LASTEDIT: December 2019
    KEYWORDS: Push-GroupSnapVolume
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
 [CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$VVNames,
		
		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$TargetVV,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$RCP,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Halt,
		
		[Parameter(Position=4, Mandatory=$false)]
		[System.String]
		$PRI,
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Online,
						
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)	
	Write-DebugLog "Start: In Push-GroupSnapVolume - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Push-GroupSnapVolume since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Push-GroupSnapVolume since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	$PromoteCmd = "promotegroupsv " 	
	
	if ($RCP)
	{
		$PromoteCmd += " -rcp "
	}
	if ($Halt)
	{
		$PromoteCmd += " -halt "
	}
	if ($PRI)
	{
		$val = "high","med","low"
		$orgVal=$PRI
		if($val -eq $orgVal)
		{
			$PromoteCmd += " -pri $PRI "			
		}
		else
		{ 
			Write-DebugLog "Stop: Push-GroupSnapVolume  since -PRI $PRI in incorrect "
			Return "FAILURE : -PRI :- $PRI is an Incorrect,[ high | med | low]  can be used only . "
		}		
	}
	if ($Online)
	{
		$PromoteCmd += " -online "
	}
	if($VVNames)
	{
		$PromoteCmd += " $VVNames"
	}
	else
	{
		write-debugLog "No VVNames specified to promote " "ERR:" 
		Get-help Push-GroupSnapVolume
		return
	}
	if ($TargetVV)
	{
		$PromoteCmd += ":"
		$PromoteCmd += "$TargetVV "
	}
			
	$result = Invoke-CLICommand -Connection $SANConnection -cmds  $PromoteCmd
	write-debuglog " Promoting Group Snapshot with $VVNames with the command --> $PromoteCmd" "INFO:" 
	if( $result -match "has been started to promote virtual copy")
	{
		return "Success : Execute Push-GroupSnapVolume `n $result"
	}
	elseif($result -match "Error: Base volume may not be promoted")
	{
		return "FAILURE : While Executing Push-GroupSnapVolume `Error: Base volume may not be promoted"
	}
	elseif($result -match "has exports defined")
	{
		return "FAILURE : While Executing Push-GroupSnapVolume `n $result"
	}
	else
	{
		return "FAILURE : While Executing Push-GroupSnapVolume `n $result"
	}
	
}#END Push-GroupSnapVolume

####################################################################################################################
## FUNCTION Push-SnapVolume
#####################################################################################################################
Function Push-SnapVolume
{
<#
  .SYNOPSIS
    This command copies the differences of a snapshot back to its base volume, allowing
	you to revert the base volume to an earlier point in time.
  
  .DESCRIPTION
	This command copies the differences of a snapshot back to its base volume, allowing
	you to revert the base volume to an earlier point in time.
        
  .EXAMPLE
   Push-SnapVolume -name vv1 
	copies the differences of a snapshot back to its base volume "vv1"
	
  .EXAMPLE
   Push-SnapVolume -target vv23 -name vv1 
	copies the differences of a snapshot back to target volume "vv23" of volume "vv1"
	
  .PARAMETER name 
    Specifies the name of the virtual copy volume or set of virtual copy volumes to be promoted 
	
  .PARAMETER target 
    Copy the differences of the virtual copy to the specified RW parent in the same virtual volume
    family tree.
	
  .PARAMETER RCP
	Allows the promote operation to proceed even if the RW parent volume is
	currently in a Remote Copy volume group, if that group has not been
	started. If the Remote Copy group has been started, this command fails.
	This option cannot be used in conjunction with the -halt option.
  
  .PARAMETER Halt
	Cancels an ongoing snapshot promotion. Marks the RW parent volume with
	the "cpf" status that can be cleaned up using the promotevvcopy command
	or by issuing a new instance of the promotesv command. This option
	cannot be used in conjunction with any other option.    
   
  .PARAMETER PRI
	Specifies the priority of the copy operation when it is started. This
	option allows the user to control the overall speed of a particular
	task.  If this option is not specified, the promotesv operation is
	started with default priority of medium. High priority indicates that
	the operation will complete faster. Low priority indicates that the
	operation will run slower than the default priority task. This option
	cannot be used with -halt option.    
  
  .PARAMETER Online
	Indicates that the promote operation will be executed while the target
	volume has VLUN exports. The host should take the target LUN offline to
	initiate the promote command, but can bring it online and use it during
	the background task. The specified virtual copy and its base volume must
	be the same size. The base volume is the only possible target of online
	promote, and is the default. To halt a promote started with the online
	option, use the canceltask command. The -halt, -target, and -pri options
	cannot be combined with the -online option.
		
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Push-SnapVolume 
    LASTEDIT: December 2019
    KEYWORDS: Push-SnapVolume
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
 [CmdletBinding()]
	param(	
		[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String]
		$name,
		
		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$target,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$RCP,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Halt,
		
		[Parameter(Position=4, Mandatory=$false)]
		[System.String]
		$PRI,
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
		[switch]
		$Online,		
							
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)	
	Write-DebugLog "Start: In Push-SnapVolume - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Push-SnapVolume since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Push-SnapVolume since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}	
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	$promoCmd = "promotesv"	
	if($target)
	{
		## Check Target Name 
		if ( !( Test-CLIObject -objectType 'vv' -objectName $target -SANConnection $SANConnection))
		{
			write-debuglog " VV $target does not exist. " "INFO:" 
			$promoCmd += " -target $target "
			return "FAILURE : No vv $target found"
		}
		$promoCmd += " -target $target "	
	}
	if ($RCP)
 	{
		$promoCmd += " -rcp "
	}
	if ($Halt)
 	{
		$promoCmd += " -halt "
	}
	if ($PRI)
 	{
		$promoCmd += " -pri $PRI "
	}
	if ($Online)
 	{
		$promoCmd += " -online "
	}
	if ($name)
 	{	
		
		if ( !( Test-CLIObject -objectType 'vv' -objectName $name -SANConnection $SANConnection))
		{
			write-debuglog " VV $vvName does not exist. Please use New-Vv to create a VV before creating SV" "INFO:" 
			return "FAILURE : No vv $vvName found"
		}								
		$promoCmd += " $name "
		$result = Invoke-CLICommand -Connection $SANConnection -cmds  $promoCmd
		
		write-debuglog " Promoting Snapshot Volume Name $vvName with the command --> $promoCmd" "INFO:" 
		Return $result
	}		
	else
	{
		write-debugLog "No vvName specified to Promote snapshot " "ERR:" 
		Get-help Push-SnapVolume
		return
	}
}#END Push-SnapVolume

#####################################################################################################################
## FUNCTION Push-VvCopy
#####################################################################################################################
Function Push-VvCopy
{
<#
  .SYNOPSIS
    Promotes a physical copy back to a regular base volume
  
  .DESCRIPTION
	Promotes a physical copy back to a regular base volume
        
  .EXAMPLE
    Push-VvCopy –physicalCopyName volume1
		Promotes virtual volume "volume1" to a base volume
	
  .PARAMETER –physicalCopyName 
    Specifies the name of the physical copy to be promoted.

  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Push-VvCopy 
    LASTEDIT: December 2019
    KEYWORDS: Push-VvCopy
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$physicalCopyName,
		
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Push-VvCopy - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Push-VvCopy since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Push-VvCopy since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	if($physicalCopyName)
	{
		if(!( Test-CLIObject -objectType "vv"  -objectName $physicalCopyName -SANConnection $SANConnection))
		{
			write-debuglog " vv $physicalCopyName does not exist. Please use New-Vv to create a new vv" "INFO:" 
			return "FAILURE : No vv $physicalCopyName found"
		}
		$promotevvcopycmd = "promotevvcopy $physicalCopyName"
		$Result3 = Invoke-CLICommand -Connection $SANConnection -cmds  $promotevvcopycmd
		
		write-debuglog " Promoting Physical volume with the command --> $promotevvcopycmd" "INFO:"
		if( $Result3 -match "not a physical copy")
		{
			return "FAILURE : $Result3"
		}
		elseif($Result3 -match "FAILURE")
		{
			return "FAILURE : $Result3"
		}
		else
		{
			return $Result3
		}
	}
	else 
	{
		write-debuglog " Please specify values for physicalCopyName " "INFO:" 
		Get-help Push-VvCopy
		return
	}
}#END Push-VvCopy

####################################################################################################################
## FUNCTION Set-Vv
#####################################################################################################################

Function Set-Vv
{
<#
  .SYNOPSIS
    Updates a snapshot Virtual Volume (VV) with a new snapshot.
  
  .DESCRIPTION
	Updates a snapshot Virtual Volume (VV) with a new snapshot.
        
  .EXAMPLE
    Set-Vv -Name volume1 -Force
	snapshot update of snapshot VV "volume1"
		
  .EXAMPLE
    Set-Vv -Name volume1,volume2 -Force
	snapshot update of snapshot VV's "volume1" and "volume2"
		
  .EXAMPLE
    Set-Vv -Name set:vvset1 -Force
	snapshot update of snapshot VVSet "vvset1"
		
  .EXAMPLE
    Set-Vv -Name set:vvset1,set:vvset2 -Force
	snapshot update of snapshot VVSet's "vvset1" and "vvset2"

  .EXAMPLE	
	Set-Vv -Name as2 -RO
	
  .EXAMPLE	
	Set-Vv -Name as2 -Force -RemoveAndRecreate 
	
  .PARAMETER Name 
    Specifies the name(s) of the snapshot virtual volume(s) or virtual volume set(s) to be updated.

  .PARAMETER RO 
    Specifies that if the specified VV (<VV_name>) is a read/write snapshot the snapshot’s read-only
	parent volume is also updated with a new snapshot if the parent volume is not a member of a
	virtual volume set

  .PARAMETER Force
   Specifies that the command is forced.

  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Set-Vv 
    LASTEDIT: December 2019
    KEYWORDS: Set-Vv
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$Name,
		
		[Parameter(Position=1, Mandatory=$false)]
		[switch]
		$Force,
		
		[Parameter(Position=2, Mandatory=$false)]
		[switch]
		$RemoveAndRecreate,

		[Parameter(Position=3, Mandatory=$false)]
		[switch]
		$RO, 	
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Set-Vv - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Set-Vv since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Set-Vv since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	if(!($Name))
	{
		Get-help Set-Vv
		return
	}
			
	if($Name)
	{			
		$updatevvcmd="updatevv -f "
		
		if($RO)
		{
			$updatevvcmd += " -ro "
		}
		if($RemoveAndRecreate)
		{
			$updatevvcmd += " -removeandrecreate  "
		}
		
		$vvtempnames = $Name.split(",")
		$limit = $vvtempnames.Length - 1
		foreach ($i in 0..$limit)
		{				
			if ( $vvtempnames[$i] -match "^set:")	
			{
				$objName = $vvtempnames[$i].Split(':')[1]
				$vvsetName = $objName
				$objType = "vv set"
				#$objMsg  = $objType
				if(!( Test-CLIObject -objectType $objType  -objectName $vvsetName -SANConnection $SANConnection))
				{
					write-debuglog " vvset $vvsetName does not exist. Please use New-VvSet to create a new vvset " "INFO:" 
					return "FAILURE : No vvset $vvsetName found"
				}
			}				
			else
			{					
				$subcmd = $vvtempnames[$i]
				if(!( Test-CLIObject -objectType "vv"  -objectName $subcmd -SANConnection $SANConnection))
				{
					write-debuglog " vv $vvtempnames[$i] does not exist. Please use New-Vv to create a new vv" "INFO:" 
					return "FAILURE : No vv $subcmd found"
				}
			}
		}		

		$updatevvcmd += " $vvtempnames "
		$Result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $updatevvcmd
		write-debuglog " updating a snapshot Virtual Volume (VV) with a new snapshot using--> $updatevvcmd" "INFO:" 
		return $Result1				
	}
	else
	{
		write-debuglog " Please specify values for vvname parameter " "INFO:" 
		return "FAILURE : Please specify values for vvname parameter"
	}
	
}#END Set-Vv

Export-ModuleMember New-GroupSnapVolume , New-GroupVvCopy , New-SnapVolume , New-VvCopy , Push-GroupSnapVolume , Push-SnapVolume , Push-VvCopy , Set-Vv
# SIG # Begin signature block
# MIIhEQYJKoZIhvcNAQcCoIIhAjCCIP4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAn6/aVuruJygdt
# yP1g7jrczJJePTTj5Um9urNDid7EpaCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPvDCCD7gCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# tB0BG7Aoiph+0PF56MSmsX83Y3WUDfGloMKrSefQRXcwDQYJKoZIhvcNAQEBBQAE
# ggEAmSOt1taQbXFeJb4+nXZdDcOavCqlh9sqo41gNvg/u6PvrdugRGdnmhSfBr7o
# fP10bqy33n1CNvKtem9mp4QIDLTV/+vt+1dIvGmk4AX8FsqTgz9RI/LObaU6pTeL
# 5Cfw4Qea6GDx8pnPXX4NorALzdT7FbL69T/QiAgw27+MpWOKGCRiorAQAAWV3d9x
# nh4raqLkBueVVcUUBrQq3J01Ddlbjhj/H/ZGuQxDlDLAhlpbzimg51TY5J4ZU7Bx
# ndfXTbQcmgrJmGmWsWB9ZMze2R4UD7aHrEMO1kK1jxJjV1VOSg73Rwiq0UuLzzBg
# I/4bsuyACeaDD+79MQMpZY6dZaGCDX4wgg16BgorBgEEAYI3AwMBMYINajCCDWYG
# CSqGSIb3DQEHAqCCDVcwgg1TAgEDMQ8wDQYJYIZIAWUDBAIBBQAweAYLKoZIhvcN
# AQkQAQSgaQRnMGUCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCDLUmbx
# 8nEBr0ZI14fP6rhczKOR6c79WzHDfGZl9C3LiwIRAKDjf0H9W2fr0uDd0IFYXnIY
# DzIwMjEwNjE5MDQyMzE0WqCCCjcwggT+MIID5qADAgECAhANQkrgvjqI/2BAIc4U
# APDdMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERp
# Z2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwHhcNMjEwMTAx
# MDAwMDAwWhcNMzEwMTA2MDAwMDAwWjBIMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIx
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwuZhhGfFivUNCKRFymNr
# Udc6EUK9CnV1TZS0DFC1JhD+HchvkWsMlucaXEjvROW/m2HNFZFiWrj/ZwucY/02
# aoH6KfjdK3CF3gIY83htvH35x20JPb5qdofpir34hF0edsnkxnZ2OlPR0dNaNo/G
# o+EvGzq3YdZz7E5tM4p8XUUtS7FQ5kE6N1aG3JMjjfdQJehk5t3Tjy9XtYcg6w6O
# LNUj2vRNeEbjA4MxKUpcDDGKSoyIxfcwWvkUrxVfbENJCf0mI1P2jWPoGqtbsR0w
# wptpgrTb/FZUvB+hh6u+elsKIC9LCcmVp42y+tZji06lchzun3oBc/gZ1v4NSYS9
# AQIDAQABo4IBuDCCAbQwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwQQYDVR0gBDowODA2BglghkgBhv1sBwEwKTAn
# BggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMB8GA1UdIwQY
# MBaAFPS24SAd/imu0uRhpbKiJbLIFzVuMB0GA1UdDgQWBBQ2RIaOpLqwZr68KC0d
# RDbd42p6vDBxBgNVHR8EajBoMDKgMKAuhixodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vc2hhMi1hc3N1cmVkLXRzLmNybDAyoDCgLoYsaHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmwwgYUGCCsGAQUFBwEBBHkwdzAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME8GCCsGAQUFBzAChkNo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNzdXJlZElE
# VGltZXN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IBAQBIHNy16ZojvOca
# 5yAOjmdG/UJyUXQKI0ejq5LSJcRwWb4UoOUngaVNFBUZB3nw0QTDhtk7vf5EAmZN
# 7WmkD/a4cM9i6PVRSnh5Nnont/PnUp+Tp+1DnnvntN1BIon7h6JGA0789P63ZHdj
# XyNSaYOC+hpT7ZDMjaEXcw3082U5cEvznNZ6e9oMvD0y0BvL9WH8dQgAdryBDvjA
# 4VzPxBFy5xtkSdgimnUVQvUtMjiB2vRgorq0Uvtc4GEkJU+y38kpqHNDUdq9Y9Yf
# W5v3LhtPEx33Sg1xfpe39D+E68Hjo0mh+s6nv1bPull2YYlffqe0jmd4+TaY4cso
# 2luHpoovMIIFMTCCBBmgAwIBAgIQCqEl1tYyG35B5AXaNpfCFTANBgkqhkiG9w0B
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTYwMTA3MTIwMDAwWhcNMzEwMTA3MTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# VGltZXN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# vdAy7kvNj3/dqbqCmcU5VChXtiNKxA4HRTNREH3Q+X1NaH7ntqD0jbOI5Je/YyGQ
# mL8TvFfTw+F+CNZqFAA49y4eO+7MpvYyWf5fZT/gm+vjRkcGGlV+Cyd+wKL1oODe
# Ij8O/36V+/OjuiI+GKwR5PCZA207hXwJ0+5dyJoLVOOoCXFr4M8iEA91z3FyTgqt
# 30A6XLdR4aF5FMZNJCMwXbzsPGBqrC8HzP3w6kfZiFBe/WZuVmEnKYmEUeaC50ZQ
# /ZQqLKfkdT66mA+Ef58xFNat1fJky3seBdCEGXIX8RcG7z3N1k3vBkL9olMqT4Ud
# xB08r8/arBD13ays6Vb/kwIDAQABo4IBzjCCAcowHQYDVR0OBBYEFPS24SAd/imu
# 0uRhpbKiJbLIFzVuMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMBIG
# A1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqg
# OKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMFAGA1UdIARJMEcwOAYKYIZIAYb9bAACBDAq
# MCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAsGCWCG
# SAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAQEAcZUS6VGHVmnN793afKpjerN4zwY3
# QITvS4S/ys8DAv3Fp8MOIEIsr3fzKx8MIVoqtwU0HWqumfgnoma/Capg33akOpMP
# +LLR2HwZYuhegiUexLoceywh4tZbLBQ1QwRostt1AuByx5jWPGTlH0gQGF+JOGFN
# YkYkh2OMkVIsrymJ5Xgf1gsUpYDXEkdws3XVk4WTfraSZ/tTYYmo9WuWwPRYaQ18
# yAGxuSh1t5ljhSKMYcp5lH5Z/IwP42+1ASa2bKXuh1Eh5Fhgm7oMLSttosR+u8Ql
# K0cCCHxJrhO24XxCQijGGFbPQTS2Zl22dHv1VjMiLyI2skuiSpXY9aaOUjGCAoYw
# ggKCAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0ECEA1CSuC+Ooj/YEAhzhQA8N0w
# DQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwG
# CSqGSIb3DQEJBTEPFw0yMTA2MTkwNDIzMTRaMCsGCyqGSIb3DQEJEAIMMRwwGjAY
# MBYEFOHXgqjhkb7va8oWkbWqtJSmJJvzMC8GCSqGSIb3DQEJBDEiBCDa7LZ8MzJl
# zeBAmzbo8hT2okiU1VQZgJIF4iiR6KgrADA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCCzEJAGvArZgweRVyngRANBXIPjKSthTyaWTI01cez1qTANBgkqhkiG9w0BAQEF
# AASCAQBAGcxs+el5dVMZcGQydgJ+Q9ydymgoLb8oEKWMd9MZqGvI8JMPNYaiQbfD
# s9qr7EO15vxfcXus4edH1ovSP0LmQs+5SiEPuG9Tw+fn8c0m7s9iR8eQ5akK21Gb
# rI8Ef7pgMfSZP9o9VEX6Xu4rxU8vbMt/0zTS2449XKAIxoR+lw5fOiTuMGDSA+ZO
# CHvNzeVN2oQGaEgyLhOH5iHXdCS4WL8fobNTTsx6J5dDMe/e5Ep7QsGwmdf/2sZ3
# co8XasX1C6Nwap0HMnlisJdvKVHT8jPqyqOTvv9EgIRVxwvBIc429oyBHRdjQ14U
# aWhRDAG8/5Ue4DX9/KWt+alpVcTg
# SIG # End signature block
