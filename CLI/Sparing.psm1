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
##	File Name:		Sparing.psm1
##	Description: 	Sparing cmdlets 
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

####################################################################
############################# FUNCTION Get-Spare ###################
####################################################################
Function Get-Spare
{
<#
  .SYNOPSIS
    Displays information about chunklets in the system that are reserved for spares
  
  .DESCRIPTION
    Displays information about chunklets in the system that are reserved for spares and previously free chunklets selected for spares by the system. 
        
  .EXAMPLE
    Get-Spare 
	Displays information about chunklets in the system that are reserved for spares
 	
  .PARAMETER used 
    Display only used spare chunklets
	
  .PARAMETER count
	Number of loop iteration
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Get-Spare
    LASTEDIT: December 2019
    KEYWORDS: Get-Spare
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$used,
		
		[Parameter(Position=1, Mandatory=$false)]
		[Switch]
		$count,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)
	Write-DebugLog "Start: In Get-Spare - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Get-Spare since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Get-Spare since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$cliresult1 = Test-PARCli -SANConnection $SANConnection
	if(($cliresult1 -match "FAILURE :"))
	{
		write-debuglog "$cliresult1" "ERR:" 
		return $cliresult1
	}
	$spareinfocmd = "showspare "
	if($used)
	{
		$spareinfocmd+= " -used "
	}
	write-debuglog "Get list of spare information cmd is => $spareinfocmd " "INFO:"
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $spareinfocmd
	$tempFile = [IO.Path]::GetTempFileName()
	$range1 = $Result.count - 3 
	$range = $Result.count	
	if($count)
	{		
		foreach ($s in  $Result[0..$range] )
		{
			if ($s -match "Total chunklets")
			{
				del $tempFile
				return $s
			}
		}
	}	
	if($Result.count -eq 3)
	{
		del $tempFile
		return "No data available"			
	}	
	foreach ($s in  $Result[0..$range1] )
	{
		if (-not $s)
		{
			write-host "No data available"
			write-debuglog "No data available" "INFO:"\
			del $tempFile
			return
		}
		$s= [regex]::Replace($s,"^ +","")
		$s= [regex]::Replace($s," +"," ")
		$s= [regex]::Replace($s," ",",")
		#write-host "s is $s="
		Add-Content -Path $tempFile -Value $s
	}
	Import-Csv $tempFile
	del $tempFile
}
### End Get-Spare

#####################################################
################### FUNCTION New-Spare ##############
#####################################################
Function New-Spare
{
<#
  .SYNOPSIS
    Allocates chunklet resources as spares. Chunklets marked as spare are not used for logical disk creation and are reserved explicitly for spares, thereby guaranteeing a minimum amount of spare space.
  
  .DESCRIPTION
    Allocates chunklet resources as spares. Chunklets marked as spare are not used for logical disk creation and are reserved explicitly for spares, thereby guaranteeing a minimum amount of spare space. 
        
  .EXAMPLE
    New-Spare -Pdid_chunkNumber "15:1"
	This example marks chunklet 1 as spare for physical disk 15
	
  .EXAMPLE
	New-Spare –pos "1:0.2:3:121"
	This example specifies the position in a drive cage, drive magazine, physical disk,and chunklet number. –pos 1:0.2:3:121, where 1 is the drive cage, 0.2 is the drive magazine, 3 is the physical disk, and 121 is the chunklet number.
 	
  .PARAMETER Pdid_chunkNumber
    Specifies the identification of the physical disk and the chunklet number on the disk.
	
  .PARAMETER pos
    Specifies the position of a specific chunklet identified by its position in a drive cage, drive magazine, physical disk, and chunklet number.
  
  .PARAMETER Partial
   Specifies that partial completion of the command is acceptable.
        
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  New-Spare
    LASTEDIT: December 2019
    KEYWORDS: New-Spare
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$Pdid_chunkNumber,
		
		[Parameter(Position=1, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$pos,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Partial,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)
	Write-DebugLog "Start: In New-Spare - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting New-Spare since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet New-Spare since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$cliresult1 = Test-PARCli -SANConnection $SANConnection
	if(($cliresult1 -match "FAILURE :"))
	{
		write-debuglog "$cliresult1" "ERR:" 
		return $cliresult1
	}
	
	$newsparecmd = "createspare "
	
	if($Partial)
	{
		$newsparecmd +=" -p "
	}
	if(!(($pos) -or ($Pdid_chunkNumber)))
	{
		return "FAILURE : Please specify any one of the params , specify either -PDID_chunknumber or -pos"
	}
	if($Pdid_chunkNumber)
	{
		$newsparecmd += " -f $Pdid_chunkNumber"
		if($pos)
		{
			return "FAILURE : Do not specify both the params , specify either -PDID_chunknumber or -pos"
		}
	}
	if($pos)
	{
		$newsparecmd += " -f -pos $pos"
		if($Pdid_chunkNumber)
		{
			return "FAILURE : Do not specify both the params , specify either -PDID_chunknumber or -pos"
		}
	}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $newsparecmd
	write-debuglog "Spare  cmd -> $newsparecmd " "INFO:"
	#write-host "Result = $Result"
	if(-not $Result)
	{
		write-host "Success : Create spare chunklet "
	}
	else
	{
		return "$Result"
	}
}
## End New-Spare

##########################################################################
########################### FUNCTION Move-Chunklet #######################
##########################################################################
Function Move-Chunklet
{
<#
  .SYNOPSIS
   Moves a list of chunklets from one physical disk to another.
  
  .DESCRIPTION
   Moves a list of chunklets from one physical disk to another.
        
  .EXAMPLE
    Move-Chunklet -SourcePD_Id 24 -SourceChunk_Position 0  -TargetPD_Id	64 -TargetChunk_Position 50 
	This example moves the chunklet in position 0 on disk 24, to position 50 on disk 64 and chunklet in position 0 on disk 25, to position 1 on disk 27
	
  .PARAMETER SourcePD_Id
    Specifies that the chunklet located at the specified PD
	
  .PARAMETER SourceChunk_Position
    Specifies that the the chunklet’s position on that disk
	
  .PARAMETER TargetPD_Id	
	specified target destination disk
	
  .PARAMETER TargetChunk_Position	
	Specify target chunklet position
	
  .PARAMETER nowait
   Specifies that the command returns before the operation is completed.
   
  .PARAMETER Devtype
	Permits the moves to happen to different device types.

  .PARAMETER Perm
	Specifies that chunklets are permanently moved and the chunklets'
	original locations are not remembered.
		
  .PARAMETER Ovrd
	Permits the moves to happen to a destination even when there will be
	a loss of quality because of the move. 
	
  .PARAMETER DryRun
	Specifies that the operation is a dry run
   
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Move-Chunklet
    LASTEDIT: December 2019
    KEYWORDS: Move-Chunklet
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true,ValueFromPipeline=$true)]
		[System.String]
		$SourcePD_Id,
		
		[Parameter(Position=1, Mandatory=$true,ValueFromPipeline=$true)]
		[System.String]
		$SourceChunk_Position,
		
		[Parameter(Position=2, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$TargetPD_Id,
		
		[Parameter(Position=3, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$TargetChunk_Position,
		
		[Parameter(Position=5, Mandatory=$false)]
		[Switch]
		$DryRun,
		
		[Parameter(Position=6, Mandatory=$false)]
		[Switch]
		$NoWait,
		
		[Parameter(Position=7, Mandatory=$false)]
		[Switch]
		$Devtype,
		
		[Parameter(Position=8, Mandatory=$false)]
		[Switch]
		$Perm,
		
		[Parameter(Position=9, Mandatory=$false)]
		[Switch]
		$Ovrd,
		
		[Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)
	Write-DebugLog "Start: In Move-Chunklet - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Move-Chunklet since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Move-Chunklet since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$cliresult1 = Test-PARCli -SANConnection $SANConnection
	if(($cliresult1 -match "FAILURE :"))
	{
		write-debuglog "$cliresult1" "ERR:" 
		return $cliresult1
	}
	$movechcmd = "movech -f"
		
	if($DryRun)
	{
		$movechcmd += " -dr "
	}
	if($NoWait)
	{
		$movechcmd += " -nowait "
	}
	if($Devtype)
	{
		$movechcmd += " -devtype "
	}
	if($Perm)
	{
		$movechcmd += " -perm "
	}
	if($Ovrd)
	{
		$movechcmd += " -ovrd "
	}
	if(($SourcePD_Id)-and ($SourceChunk_Position))
	{
		$params = $SourcePD_Id+":"+$SourceChunk_Position
		$movechcmd += " $params"
		if(($TargetPD_Id) -and ($TargetChunk_Position))
		{
			$movechcmd += "-"+$TargetPD_Id+":"+$TargetChunk_Position
		}
	}
	else
	{
		return "FAILURE :  No parameters specified "
	}
	
	write-debuglog "move chunklet cmd -> $movechcmd " "INFO:"	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $movechcmd	
	if([string]::IsNullOrEmpty($Result))
	{
		return "FAILURE : Disk $SourcePD_Id chunklet $SourceChunk_Position is not in use. "
	}
	if($Result -match "Move")
	{
		$range = $Result.count
		$tempFile = [IO.Path]::GetTempFileName()
		foreach ($s in  $Result[0..$range] )
		{			
			$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'			
			Add-Content -Path $tempFile -Value $s
		}
		Import-Csv $tempFile
		del $tempFile
	}
	else
	{
		return $Result
	}
}
## End Move-Chunklet

##########################################################################
######################## FUNCTION Move-ChunkletToSpare ###################
##########################################################################

Function Move-ChunkletToSpare
{
<#
  .SYNOPSIS
   Moves data from specified Physical Disks (PDs) to a temporary location selected by the system
  
  .DESCRIPTION
   Moves data from specified Physical Disks (PDs) to a temporary location selected by the system
        
  .EXAMPLE
    Move-ChunkletToSpare -SourcePD_Id 66 -SourceChunk_Position 0  -force 
	Examples shows chunklet 0 from physical disk 66 is moved to spare

  .EXAMPLE	
	Move-ChunkletToSpare -SourcePD_Id 3 -SourceChunk_Position 0

  .EXAMPLE	
	Move-ChunkletToSpare -SourcePD_Id 4 -SourceChunk_Position 0 -nowait
	
  .EXAMPLE
    Move-ChunkletToSpare -SourcePD_Id 5 -SourceChunk_Position 0 -Devtype
	
  .PARAMETER SourcePD_Id
    Indicates that the move takes place from the specified PD
	
  .PARAMETER SourceChunk_Position
    Indicates that the move takes place from  chunklet position
	
  .PARAMETER force
    Specifies that the command is forced. If this option is not used,it will do dry run,No chunklets are actually moved.
	
  .PARAMETER nowait
   Specifies that the command returns before the operation is completed.
   
   .PARAMETER Devtype
	Permits the moves to happen to different device types.
	
  .PARAMETER DryRun
	Specifies that the operation is a dry run
   
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Move-ChunkletToSpare
    LASTEDIT: December 2019
    KEYWORDS: Move-ChunkletToSpare
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$SourcePD_Id,
		
		[Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$SourceChunk_Position,

		[Parameter(Position=2, Mandatory=$false)]
		[Switch]
		$DryRun,
		
		[Parameter(Position=3, Mandatory=$false)]
		[Switch]
		$nowait,
		
		[Parameter(Position=4, Mandatory=$false)]
		[Switch]
		$Devtype,
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)
	Write-DebugLog "Start: In Move-ChunkletToSpare - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Move-ChunkletToSpare since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Move-ChunkletToSpare since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$cliresult1 = Test-PARCli -SANConnection $SANConnection
	if(($cliresult1 -match "FAILURE :"))
	{
		write-debuglog "$cliresult1" "ERR:" 
		return $cliresult1
	}
	
	$movechcmd = "movechtospare -f"
	
	if($DryRun)
	{
		$movechcmd += " -dr "
	}
	
	if($nowait)
	{
		$movechcmd += " -nowait "
	}
	if($Devtype)
	{
		$movechcmd += " -devtype "
	}
	if(($SourcePD_Id) -and ($SourceChunk_Position))
	{
		$params = $SourcePD_Id+":"+$SourceChunk_Position
		$movechcmd += " $params"
	}
	else
	{
		return "FAILURE : No parameters specified"
	}
	
	write-debuglog "cmd is -> $movechcmd " "INFO:"
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $movechcmd
	
	if([string]::IsNullOrEmpty($Result))
	{		
		return "FAILURE : "
	}
	elseif($Result -match "does not exist")
	{		
		return $Result
	}
	elseif($Result.count -gt 1)
	{
		$range = $Result.count
		$tempFile = [IO.Path]::GetTempFileName()
		foreach ($s in  $Result[0..$range] )
		{
			#write-host "s = $s"
			$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'
			
			Add-Content -Path $tempFile -Value $s
		}
		Import-Csv $tempFile
		del $tempFile
	}
	else
	{
		return $Result
	}
}
## End Move-ChunkletToSpare

################################################################################
################################### FUNCTION Move-PD ###########################
################################################################################
Function Move-PD
{
<#
  .SYNOPSIS
   Moves data from specified Physical Disks (PDs) to a temporary location selected by the system
  
  .DESCRIPTION
   Moves data from specified Physical Disks (PDs) to a temporary location selected by the system
        
  .EXAMPLE
    Move-PD -PD_Id 0 -force
	Example shows moves data from Physical Disks 0  to a temporary location
	
  .EXAMPLE	
	Move-PD -PD_Id 0  
	Example displays a dry run of moving the data on physical disk 0 to free or sparespace
	
  .PARAMETER PD_Id
    Specifies the physical disk ID. This specifier can be repeated to move multiple physical disks.

  .PARAMETER force
    Specifies that the command is forced. If this option is not used,it will do dry run,No chunklets are actually moved.
	
  .PARAMETER DryRun
	Specifies that the operation is a dry run, and no physical disks are
	actually moved.

  .PARAMETER Nowait
	Specifies that the command returns before the operation is completed.

  .PARAMETER Devtype
	Permits the moves to happen to different device types.

  .PARAMETER Perm
	Makes the moves permanent, removes source tags after relocation
   
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Move-PD
    LASTEDIT: December 2019
    KEYWORDS: Move-PD
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(		
		[Parameter(Position=1, Mandatory=$false)]
		[Switch]
		$DryRun,
				
		[Parameter(Position=2, Mandatory=$false)]
		[Switch]
		$nowait,
		
		[Parameter(Position=3, Mandatory=$false)]
		[Switch]
		$Devtype,
		
		[Parameter(Position=4, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$PD_Id,		
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)
	Write-DebugLog "Start: In Move-PD - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Move-PD since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Move-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$cliresult1 = Test-PARCli -SANConnection $SANConnection
	if(($cliresult1 -match "FAILURE :"))
	{
		write-debuglog "$cliresult1" "ERR:" 
		return $cliresult1
	}
	$movechcmd = "movepd -f"
	
	if($DryRun)
	{
		$movechcmd += " -dr "
	}
	if($nowait)
	{
		$movechcmd += " -nowait "
	}
	if($Devtype)
	{
		$movechcmd += " -devtype "
	}
	if($PD_Id)
	{
		$params = $PD_Id
		$movechcmd += " $params"
	}
	else
	{
		return "FAILURE : No parameters specified"		
	}
	write-debuglog "Push physical disk command => $movechcmd " "INFO:"
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $movechcmd
	
	if([string]::IsNullOrEmpty($Result))
	{
		return "FAILURE : $Result"
	}
	if($Result -match "FAILURE")
	{
		return $Result
	}
	if($Result -match "-Detailed_State-")
	{		
		$range = $Result.count
		$tempFile = [IO.Path]::GetTempFileName()
		foreach ($s in  $Result[0..$range] )
		{			
			$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			
			$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'
			Add-Content -Path $tempFile -Value $s
		}
		Import-Csv $tempFile
		del $tempFile
	}
	else
	{		
		return $Result
	}
}
## End Move-PD 

################################################################################
############################ FUNCTION Move-PDToSpare ###########################
################################################################################
Function Move-PDToSpare
{
<#
  .SYNOPSIS
   Moves data from specified Physical Disks (PDs) to a temporary location selected by the system.
  
  .DESCRIPTION
   Moves data from specified Physical Disks (PDs) to a temporary location selected by the system.
        
  .EXAMPLE
    Move-PDToSpare -PD_Id 0 -force  
	Displays  moving the data on PD 0 to free or spare space
	
  .EXAMPLE
    Move-PDToSpare -PD_Id 0 
	Displays a dry run of moving the data on PD 0 to free or spare space

  .EXAMPLE
    Move-PDToSpare -PD_Id 0 -DryRun
	
  .EXAMPLE
    Move-PDToSpare -PD_Id 0 -Vacate
	
  .EXAMPLE
    Move-PDToSpare -PD_Id 0 -Permanent
	
  .PARAMETER PD_Id
    Specifies the physical disk ID.

  .PARAMETER force
    Specifies that the command is forced. If this option is not used,it will do dry run,No chunklets are actually moved.
	
  .PARAMETER nowait
   Specifies that the command returns before the operation is completed.
   
   .PARAMETER Devtype
	Permits the moves to happen to different device types.

   .PARAMETER DryRun	
	Specifies that the operation is a dry run. No physical disks are actually moved.

   .PARAMETER Vacate
    Deprecated, use -perm instead.
	
   .PARAMETER Permanent
	 Makes the moves permanent, removes source tags after relocation.

   .PARAMETER Ovrd
	Permits the moves to happen to a destination even when there will be
	a loss of quality because of the move. This option is only necessary
	when the target of the move is not specified and the -perm flag is
	used.
	 
   .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
   .Notes
    NAME:  Move-PDToSpare
    LASTEDIT: December 2019
    KEYWORDS: Move-PDToSpare
   
   .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
		[System.String]
		$PD_Id,
		
		[Parameter(Position=1, Mandatory=$false)]
		[Switch]
		$DryRun,
		
		[Parameter(Position=2, Mandatory=$false)]
		[Switch]
		$nowait,
		
		[Parameter(Position=3, Mandatory=$false)]
		[Switch]
		$DevType,
		
		[Parameter(Position=4, Mandatory=$false)]
		[Switch]
		$Vacate,
		
		[Parameter(Position=5, Mandatory=$false)]
		[Switch]
		$Permanent, 
		
		[Parameter(Position=6, Mandatory=$false)]
		[Switch]
		$Ovrd,
		
		[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)
	Write-DebugLog "Start: In Move-PDToSpare - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Move-PDToSpare since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Move-PDToSpare since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$cliresult1 = Test-PARCli -SANConnection $SANConnection
	if(($cliresult1 -match "FAILURE :"))
	{
		write-debuglog "$cliresult1" "ERR:" 
		return $cliresult1
	}
	
	$movechcmd = "movepdtospare -f"
	
	if($DryRun)
	{
		$movechcmd += " -dr "
	}	
	if($nowait)
	{
		$movechcmd += " -nowait "
	}
	if($DevType)
	{
		$movechcmd += " -devtype "
	}
	if($Vacate)
	{
		$movechcmd += " -vacate "
	}
	if($Permanent)
	{
		$movechcmd += " -perm "
	}
	if($Ovrd)
	{
		$movechcmd += " -ovrd "
	}
	if($PD_Id)
	{
		$params = $PD_Id
		$movechcmd += " $params"
	}
	else
	{
		return "FAILURE : No parameters specified"		
	}
	
	write-debuglog "push physical disk to spare cmd is  => $movechcmd " "INFO:"
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $movechcmd
	if([string]::IsNullOrEmpty($Result))
	{
		return "FAILURE : "
	}
	if($Result -match "Error:")
	{
		return $Result
	}
	if($Result -match "Move")
	{
		$range = $Result.count
		$tempFile = [IO.Path]::GetTempFileName()
		foreach ($s in  $Result[0..$range] )
		{
			#write-host "s = $s"
			$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'
			Add-Content -Path $tempFile -Value $s
		}
		Import-Csv $tempFile
		del $tempFile
	}
	else
	{
		return $Result
	}
}
## End Move-PDToSpare

################################################################################
############################ FUNCTION Move-RelocPD #############################
################################################################################
Function Move-RelocPD
{
<#
  .SYNOPSIS
   Command moves chunklets that were on a physical disk to the target of relocation.
  
  .DESCRIPTION
   Command moves chunklets that were on a physical disk to the target of relocation.
        
  .EXAMPLE
    Move-RelocPD -diskID 8 -DryRun
	moves chunklets that were on physical disk 8 that were relocated to another position, back to physical disk 8
	
  .PARAMETER diskID    
	Specifies that the chunklets that were relocated from specified disk (<fd>), are moved to the specified destination disk (<td>). If destination disk (<td>) is not specified then the chunklets are moved back
    to original disk (<fd>). The <fd> specifier is not needed if -p option is used, otherwise it must be used at least once on the command line. If this specifier is repeated then the operation is performed on multiple disks.

  .PARAMETER DryRun	
	Specifies that the operation is a dry run. No physical disks are actually moved.  
	
  .PARAMETER nowait
   Specifies that the command returns before the operation is completed.
   
  .PARAMETER partial
    Move as many chunklets as possible. If this option is not specified, the command fails if not all specified chunklets can be moved.
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Move-RelocPD
    LASTEDIT: December 2019
    KEYWORDS: Move-RelocPD
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true,ValueFromPipeline=$true)]
		[System.String]
		$diskID,
		
		[Parameter(Position=1, Mandatory=$false)]
		[Switch]
		$DryRun,
		
		[Parameter(Position=2, Mandatory=$false)]
		[Switch]
		$nowait,
		
		[Parameter(Position=3, Mandatory=$false)]
		[Switch]
		$partial,
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)
	Write-DebugLog "Start: In Move-RelocPD - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Move-RelocPD since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Move-RelocPD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$cliresult1 = Test-PARCli -SANConnection $SANConnection
	if(($cliresult1 -match "FAILURE :"))
	{
		write-debuglog "$cliresult1" "ERR:" 
		return $cliresult1
	}
	$movechcmd = "moverelocpd -f "
	if($DryRun)
	{
		$movechcmd += " -dr "
	}	
	if($nowait)
	{
		$movechcmd += " -nowait "
	}
	if($partial)
	{
		$movechcmd += " -partial "
	}
	if($diskID)
	{
		$movechcmd += " $diskID"
	}
	else
	{
		return "FAILURE : No parameters specified"		
	}
	
	write-debuglog "move relocation pd cmd is => $movechcmd " "INFO:"
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $movechcmd
	if([string]::IsNullOrEmpty($Result))
	{
		return "FAILURE : "
	}
	if($Result -match "Error:")
	{
		return $Result
	}	
	if($Result -match "There are no chunklets to move")
	{
		return "There are no chunklets to move"
	}	
	if($Result -match " Move -State- -Detailed_State-")
	{
		$range = $Result.count
		$tempFile = [IO.Path]::GetTempFileName()
		foreach ($s in  $Result[0..$range] )
		{			
			$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'
			Add-Content -Path $tempFile -Value $s			
		}
		Import-Csv $tempFile
		del $tempFile
	}
	else
	{
		return $Result
	}
}
## End Move-RelocPD

################################################################################
############################ FUNCTION Remove-Spare #############################
################################################################################
Function Remove-Spare
{
<#
  .SYNOPSIS
    Command removes chunklets from the spare chunklet list.
  
  .DESCRIPTION
    Command removes chunklets from the spare chunklet list.
	
  .EXAMPLE
    Remove-Spare -Pdid_chunkNumber "1:3"
	Example removes a spare chunklet from position 3 on physical disk 1:
	
  .EXAMPLE
	Remove-Spare –pos "1:0.2:3:121"
	Example removes a spare chuklet from  the position in a drive cage, drive magazine, physical disk,and chunklet number. –pos 1:0.2:3:121, where 1 is the drive cage, 0.2 is the drive magazine, 3 is the physical disk, and 121 is the chunklet number. 	
	
  .PARAMETER Pdid_chunkNumber
    Specifies the identification of the physical disk and the chunklet number on the disk.
	
  .PARAMETER pos
    Specifies the position of a specific chunklet identified by its position in a drive cage, drive magazine, physical disk, and chunklet number.
 
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Remove-Spare
    LASTEDIT: December 2019
    KEYWORDS: Remove-Spare
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$Pdid_chunkNumber,
		
		[Parameter(Position=1, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$pos,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)
	Write-DebugLog "Start: In Remove-Spare - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Remove-Spare since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Remove-Spare since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	
	$cliresult1 = Test-PARCli -SANConnection $SANConnection
	if(($cliresult1 -match "FAILURE :"))
	{
		write-debuglog "$cliresult1" "ERR:" 
		return $cliresult1
	}
	
	$newsparecmd = "removespare "
	
	if(!(($Pdid_chunkNumber) -or ($pos)))
	{
		return "FAILURE: No parameters specified"
	}
	if($Pdid_chunkNumber)
	{
		$newsparecmd += " -f $Pdid_chunkNumber"
		if($pos)
		{
			return "FAILURE: Please select only one params, either -Pdid_chunkNumber or -pos "
		}
	}
	if($pos)
	{
		$newsparecmd += " -f -pos $pos"
	}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $newsparecmd
	write-debuglog "Remove spare command -> newsparecmd " "INFO:"
	
	if($Result -match "removed")
	{
		write-debuglog "Success : Removed spare chunklet "  "INFO:"
		return "Success : $Result"
	}
	else
	{
		return "$Result"
	}
}
## End Remove-Spare

Export-ModuleMember Get-Spare , New-Spare , Move-Chunklet , Move-ChunkletToSpare , Move-PD , Move-PDToSpare , Move-RelocPD , Remove-Spare
# SIG # Begin signature block
# MIIh0AYJKoZIhvcNAQcCoIIhwTCCIb0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAa2qit1vOJbH9c
# js7DaUS/X0zZoy2439Ol3htv/Swu8aCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIQezCCEHcCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# OjcP8wUiXlN35g0dIVvp6A5dXu1Sake5NegcSgC0DakwDQYJKoZIhvcNAQEBBQAE
# ggEAq2O/lOfNzQWbK2llx8w+o+SvZkb2Xr+FjFGKge4aiIUUONsq1b/K7HCqCNCS
# f0zEBh5fNWFdqpTfTvycxVBBsOp5SDXi5O65CKPK/J2zHxhFfD0AfaP0qqpaoVK2
# V8tWHwnZQYedasRdUb6TDfZF6aVvCoQZLyafUfJwNFflepThHydn5R1iozxzmdFd
# 4Ro/l7ntoEWfRfZBUCPzq81dVqia69/T9263j9ZfIutq2wHOUXymgrHTUKbmxGUG
# JgDZY/icvVSBThHz7Bmt4IKbQwI2cfxQ0C8wSe8JOxkLJWUY24QSxoPoX8ubogbH
# E5fbh+63Z6A5oOVnh3Kl3iuMR6GCDj0wgg45BgorBgEEAYI3AwMBMYIOKTCCDiUG
# CSqGSIb3DQEHAqCCDhYwgg4SAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDwYLKoZIhvcN
# AQkQAQSggf8EgfwwgfkCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# IF3WE1rVzuSGniY2mXoRXYYFy51FFQ1yTk+/NC1UCbJqAhUA9G3tiOS4OCOW8Jfl
# /WzKj735DckYDzIwMjEwNjE5MDQyNDA0WjADAgEeoIGGpIGDMIGAMQswCQYDVQQG
# EwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5
# bWFudGVjIFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBU
# aW1lU3RhbXBpbmcgU2lnbmVyIC0gRzOgggqLMIIFODCCBCCgAwIBAgIQewWx1Elo
# UUT3yYnSnBmdEjANBgkqhkiG9w0BAQsFADCBvTELMAkGA1UEBhMCVVMxFzAVBgNV
# BAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3
# b3JrMTowOAYDVQQLEzEoYykgMjAwOCBWZXJpU2lnbiwgSW5jLiAtIEZvciBhdXRo
# b3JpemVkIHVzZSBvbmx5MTgwNgYDVQQDEy9WZXJpU2lnbiBVbml2ZXJzYWwgUm9v
# dCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xNjAxMTIwMDAwMDBaFw0zMTAx
# MTEyMzU5NTlaMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jw
# b3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEoMCYGA1UE
# AxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALtZnVlVT52Mcl0agaLrVfOwAa08cawyjwVrhpon
# ADKXak3JZBRLKbvC2Sm5Luxjs+HPPwtWkPhiG37rpgfi3n9ebUA41JEG50F8eRzL
# y60bv9iVkfPw7mz4rZY5Ln/BJ7h4OcWEpe3tr4eOzo3HberSmLU6Hx45ncP0mqj0
# hOHE0XxxxgYptD/kgw0mw3sIPk35CrczSf/KO9T1sptL4YiZGvXA6TMU1t/HgNuR
# 7v68kldyd/TNqMz+CfWTN76ViGrF3PSxS9TO6AmRX7WEeTWKeKwZMo8jwTJBG1kO
# qT6xzPnWK++32OTVHW0ROpL2k8mc40juu1MO1DaXhnjFoTcCAwEAAaOCAXcwggFz
# MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMGYGA1UdIARfMF0w
# WwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNvbS9ycGEwLgYI
# KwYBBQUHAQEEIjAgMB4GCCsGAQUFBzABhhJodHRwOi8vcy5zeW1jZC5jb20wNgYD
# VR0fBC8wLTAroCmgJ4YlaHR0cDovL3Muc3ltY2IuY29tL3VuaXZlcnNhbC1yb290
# LmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAoBgNVHREEITAfpB0wGzEZMBcGA1UE
# AxMQVGltZVN0YW1wLTIwNDgtMzAdBgNVHQ4EFgQUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwHwYDVR0jBBgwFoAUtnf6aUhHn1MS1cLqBzJ2B9GXBxkwDQYJKoZIhvcNAQEL
# BQADggEBAHXqsC3VNBlcMkX+DuHUT6Z4wW/X6t3cT/OhyIGI96ePFeZAKa3mXfSi
# 2VZkhHEwKt0eYRdmIFYGmBmNXXHy+Je8Cf0ckUfJ4uiNA/vMkC/WCmxOM+zWtJPI
# TJBjSDlAIcTd1m6JmDy1mJfoqQa3CcmPU1dBkC/hHk1O3MoQeGxCbvC2xfhhXFL1
# TvZrjfdKer7zzf0D19n2A6gP41P3CnXsxnUuqmaFBJm3+AZX4cYO9uiv2uybGB+q
# ueM6AL/OipTLAduexzi7D1Kr0eOUA2AKTaD+J20UMvw/l0Dhv5mJ2+Q5FL3a5NPD
# 6itas5VYVQR9x5rsIwONhSrS/66pYYEwggVLMIIEM6ADAgECAhB71OWvuswHP6EB
# IwQiQU0SMA0GCSqGSIb3DQEBCwUAMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRT
# eW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0
# d29yazEoMCYGA1UEAxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAe
# Fw0xNzEyMjMwMDAwMDBaFw0yOTAzMjIyMzU5NTlaMIGAMQswCQYDVQQGEwJVUzEd
# MBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVj
# IFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgU2lnbmVyIC0gRzMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCvDoqq+Ny/aXtUF3FHCb2NPIH4dBV3Z5Cc/d5OAp5LdvblNj5l1SQgbTD53R2D
# 6T8nSjNObRaK5I1AjSKqvqcLG9IHtjy1GiQo+BtyUT3ICYgmCDr5+kMjdUdwDLNf
# W48IHXJIV2VNrwI8QPf03TI4kz/lLKbzWSPLgN4TTfkQyaoKGGxVYVfR8QIsxLWr
# 8mwj0p8NDxlsrYViaf1OhcGKUjGrW9jJdFLjV2wiv1V/b8oGqz9KtyJ2ZezsNvKW
# lYEmLP27mKoBONOvJUCbCVPwKVeFWF7qhUhBIYfl3rTTJrJ7QFNYeY5SMQZNlANF
# xM48A+y3API6IsW0b+XvsIqbAgMBAAGjggHHMIIBwzAMBgNVHRMBAf8EAjAAMGYG
# A1UdIARfMF0wWwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9k
# LnN5bWNiLmNvbS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9ycGEwQAYDVR0fBDkwNzA1oDOgMYYvaHR0cDovL3RzLWNybC53cy5zeW1hbnRl
# Yy5jb20vc2hhMjU2LXRzcy1jYS5jcmwwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# DgYDVR0PAQH/BAQDAgeAMHcGCCsGAQUFBwEBBGswaTAqBggrBgEFBQcwAYYeaHR0
# cDovL3RzLW9jc3Aud3Muc3ltYW50ZWMuY29tMDsGCCsGAQUFBzAChi9odHRwOi8v
# dHMtYWlhLndzLnN5bWFudGVjLmNvbS9zaGEyNTYtdHNzLWNhLmNlcjAoBgNVHREE
# ITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtNjAdBgNVHQ4EFgQUpRMB
# qZ+FzBtuFh5fOzGqeTYAex0wHwYDVR0jBBgwFoAUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwDQYJKoZIhvcNAQELBQADggEBAEaer/C4ol+imUjPqCdLIc2yuaZycGMv41Up
# ezlGTud+ZQZYi7xXipINCNgQujYk+gp7+zvTYr9KlBXmgtuKVG3/KP5nz3E/5jMJ
# 2aJZEPQeSv5lzN7Ua+NSKXUASiulzMub6KlN97QXWZJBw7c/hub2wH9EPEZcF1rj
# pDvVaSbVIX3hgGd+Yqy3Ti4VmuWcI69bEepxqUH5DXk4qaENz7Sx2j6aescixXTN
# 30cJhsT8kSWyG5bphQjo3ep0YG5gpVZ6DchEWNzm+UgUnuW/3gC9d7GYFHIUJN/H
# ESwfAD/DSxTGZxzMHgajkF9cVIs+4zNbgg/Ft4YCTnGf6WZFP3YxggJaMIICVgIB
# ATCBizB3MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRp
# b24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxKDAmBgNVBAMTH1N5
# bWFudGVjIFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEHvU5a+6zAc/oQEjBCJBTRIw
# CwYJYIZIAWUDBAIBoIGkMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkq
# hkiG9w0BCQUxDxcNMjEwNjE5MDQyNDA0WjAvBgkqhkiG9w0BCQQxIgQgYen0DqnM
# JW6xJRP9PtCpEnkKaMhWD8gcKEPMEFPDjjYwNwYLKoZIhvcNAQkQAi8xKDAmMCQw
# IgQgxHTOdgB9AjlODaXk3nwUxoD54oIBPP72U+9dtx/fYfgwCwYJKoZIhvcNAQEB
# BIIBAD61QaQMsMgQbUpZhq9tcmnsITueLAEIhoOi0KFi/Vu8Hi4NNC386oLhQm/U
# zmT9XZKbTKxU5QzqnIZTPrOMiCHnxE3C8xL2RKijacay5hP+Duv3rviRroZD+ViB
# Fm6rbLQXroFMWjxTCbYxAWz6mDnEtMOTJS8rxE3xmzBCdmwDvyccZZXdVV5Fmh8c
# iCX2AY7791WfF+w9xTuNUCGRDwVEG75MsASh7332ia+aVc1Ft0apmn60AzF/3LO6
# Jqgmd6owRryeSm3LbhSIf4RgcKdfukifybRAHhcV+G0I65K0XLg3WtRKNunJEnrq
# d4bRyhS/iop8xtB7bSFR+rfdOgI=
# SIG # End signature block
