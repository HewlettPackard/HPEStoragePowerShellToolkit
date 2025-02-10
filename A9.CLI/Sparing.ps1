####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9Spare
{
<#
.SYNOPSIS
    Displays information about chunklets in the system that are reserved for spares
.DESCRIPTION
    Displays information about chunklets in the system that are reserved for spares and previously free chunklets selected for spares by the system. 
.EXAMPLE
    PS:> Get-A9Spare 
	
	PdId Chnk LdName  LdCh State Usage Media Sp Cl From To
	4   53 ronnie     0 normal   ld valid  N  N 2:37 ---
	4   54 james     28 normal   ld valid  N  N 0:29 ---
	4   55 dio       28 normal   ld valid  N  N 0:32 ---
	4   56 rocks      0 normal   ld valid  N  N 0:38 ---  
	
	Displays information about chunklets in the system that are reserved for spares
.EXAMPLE
    PS:> Get-A9Spare -used
	
	Displays information about chunklets in the system that are reserved for spares
.PARAMETER used 
    Shows only used spare chunklets. By default all spare chunklets are shown.
.NOTES
	This command requires a SSH type connection.
	Authority: Any role in the system
	Usage: The showpdch command is a more general and versatile command that can be used instead of showspare
#>
[CmdletBinding()]
param(	[Parameter()]	[Switch]	$used	
	)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}	
process
	{	$spareinfocmd = "showspare "
		if($used)	{	$spareinfocmd+= " -used "	}
		write-verbose "Get list of spare information cmd is => $spareinfocmd "
		$Result = Invoke-A9CLICommand -cmds  $spareinfocmd
	}
end
	{	$tempFile = [IO.Path]::GetTempFileName()
		$range1 = $Result.count - 3 	
		if($Result.count -eq 3)
			{	remove-item $tempFile
				write-warning "No data available"
				return			
			}	
		foreach ($s in  $Result[0..$range1] )
			{	if (-not $s)
					{	remove-item $tempFile
						write-warning "No data available"
						return
					}
				$s= [regex]::Replace($s,"^ +","")
				$s= [regex]::Replace($s," +"," ")
				$s= [regex]::Replace($s," ",",")
				Add-Content -Path $tempFile -Value $s
			}
		$returnresult = Import-Csv $tempFile
		remove-item $tempFile
		return $returnresult
	}
}

Function New-A9Spare
{
<#
.SYNOPSIS
    Allocates chunklet resources as spares. Chunklets marked as spare are not used for logical disk creation and are reserved explicitly for spares, thereby guaranteeing a minimum amount of spare space.
.DESCRIPTION
    Allocates chunklet resources as spares. Chunklets marked as spare are not used for logical disk creation and are reserved explicitly for spares, thereby guaranteeing a minimum amount of spare space. 
.PARAMETER Pdid_chunkNumber
    Specifies the identification of the physical disk and the chunklet number on the disk.
.PARAMETER pos
    Specifies the position of a specific chunklet identified by its position in a drive cage, drive magazine, physical disk, and chunklet number.
.PARAMETER Partial
	Specifies that partial completion of the command is acceptable.
.EXAMPLE
    PS:> New-A9Spare -Pdid_chunkNumber "15:1"
	
	This example marks chunklet 1 as spare for physical disk 15
.EXAMPLE
	PS:> New-A9Spare –pos "1:0.2:3:121"
	
	This example specifies the position in a drive cage, drive magazine, physical disk,and chunklet number. –pos 1:0.2:3:121, 
	where 1 is the drive cage, 0.2 is the drive magazine, 3 is the physical disk, and 121 is the chunklet number.
.NOTES
	This command requires a SSH type connection.
	Authority: Super, Service
		Any role granted the spare_create right
	Usage:
	- Access to all domains is required to run this command.
	= To verify the creation of a spare chunklet, issue the showspare command.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Pdid',mandatory)]		[String]	$Pdid_chunkNumber,
		[Parameter(ParameterSetName='POS', mandatory)]		[String]	$pos,
		[Parameter()]										[Switch]	$Partial
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process	
	{	$newsparecmd = " createspare -f "
		if($Partial)	
			{	$newsparecmd +=" -p "	
			}
		if($Pdid_chunkNumber)
			{	$newsparecmd += " $Pdid_chunkNumber"
			}
		if($pos)
			{	$newsparecmd += " -pos $pos"
			}
		write-verbose "Spare  cmd -> $newsparecmd "
		$Result = Invoke-A9CLICommand -cmds  $newsparecmd
	}
end
	{	if(-not $Result){	write-host "Success : Create spare chunklet "	}
		else			{	return "$Result"	}
	}
}

Function Move-A9Chunklet
{
<#
.SYNOPSIS
	Moves a list of chunklets from one physical disk to another.
.DESCRIPTION
	Moves a list of chunklets from one physical disk to another.
.EXAMPLE
    PS:> Move-A9Chunklet -SourcePD_Id 24 -SourceChunk_Position 0  -TargetPD_Id 64 -TargetChunk_Position 50 

	This example moves the chunklet in position 0 on disk 24, to position 50 on disk 64 and chunklet in position 0 on disk 25, to position 1 on disk 27
.PARAMETER SourcePD_Id
    Specifies that the chunklet located at the specified PD. This is a required parameter.
.PARAMETER SourceChunk_Position
    Specifies that the the chunklet’s position on that disk. This is a required parameter.
.PARAMETER TargetPD_Id	
	specified target destination disk. Usage of this parameter also requires the use of TagetChunk_Position
.PARAMETER TargetChunk_Position	
	Specify target chunklet position. Usage of this parameter also requires the use of TagetPD_Id
.PARAMETER nowait
	Specifies that the command returns before the operation is completed.
.PARAMETER Devtype
	Permits the moves to happen to different device types.
.PARAMETER Perm
	Specifies that chunklets are permanently moved and the chunklets'
	original locations are not remembered.
.PARAMETER Ovrd
	Permits the moves to happen to a destination even when there will be a loss of quality because of the move. 
.PARAMETER DryRun
	Specifies that the operation is a dry run
.NOTES
	This command requires a SSH type connection.
	Authority: Super, Service, Edit
	Any role granted the ch_move right
	Usage:
	- Access to all domains is required to run this command.
	- Chunklets moved through the movech command are only moved temporarily.
	- Issuing either the moverelocpd or servicemag resume command (see the servicemag command) can move the chunklet back to its original position.
	- The -dr option can be used to see if the specified moves succeed and what the results (quality) of the moves are.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(
		[Parameter(mandatory)]									[String]	$SourcePD_Id,
		[Parameter(mandatory)]									[String]	$SourceChunk_Position,	
		[Parameter(parametersetname='targ',mandatory)]			[String]	$TargetPD_Id,
		[Parameter(parametersetname='targ',mandatory)]			[String]	$TargetChunk_Position,
		[Parameter()]											[Switch]	$DryRun,
		[Parameter()]											[Switch]	$NoWait,		
		[Parameter()]											[Switch]	$Devtype,
		[Parameter()]											[Switch]	$Perm,
		[Parameter(parametersetname='default')]					[Switch]	$Ovrd
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$movechcmd = "movech -f "
	if($DryRun)		{	$movechcmd += " -dr "		}
	elseif($Perm)	{	$movechcmd += " -perm "		}
	if($NoWait)		{	$movechcmd += " -nowait "	}
	if($Devtype)	{	$movechcmd += " -devtype "	}
	if($Ovrd)		{	$movechcmd += " -ovrd "		}
	$movechcmd += $SourcePD_Id+":"+$SourceChunk_Position
	if(($TargetPD_Id) -and ($TargetChunk_Position))	
		{	$movechcmd += "-"+$TargetPD_Id+":"+$TargetChunk_Position	
		}
	write-verbose "move chunklet cmd -> $movechcmd "	
	$Result = Invoke-A9CLICommand -cmds  $movechcmd	
}
end
{	if([string]::IsNullOrEmpty($Result))	
		{	write-warning "FAILURE : Disk $SourcePD_Id chunklet $SourceChunk_Position is not in use. "
			return 	
		}
	if($Result -match "Move")
		{	$range = $Result.count
			$tempFile = [IO.Path]::GetTempFileName()
			foreach ($s in  $Result[0..$range] )
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +"," ")
					$s= [regex]::Replace($s," ",",")
					$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'			
					Add-Content -Path $tempFile -Value $s
				}
			$returnresult = Import-Csv $tempFile
			remove-item $tempFile
			return $returnresult
		}
	else	
		{	return $Result	
		}
}
}

Function Move-A9ChunkletToSpare
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
	PS:> Move-A9ChunkletToSpare -SourcePD_Id 3 -SourceChunk_Position 0
.EXAMPLE	
	PS:> Move-A9ChunkletToSpare -SourcePD_Id 4 -SourceChunk_Position 0 -nowait
.EXAMPLE
    PS:> Move-A9ChunkletToSpare -SourcePD_Id 5 -SourceChunk_Position 0 -Devtype
.PARAMETER SourcePD_Id
    Indicates that the move takes place from the specified PD
.PARAMETER SourceChunk_Position
    Indicates that the move takes place from  chunklet position
.PARAMETER nowait
	Specifies that the command returns before the operation is completed.
.PARAMETER Devtype
	Permits the moves to happen to different device types.
.PARAMETER DryRun
	Specifies that the operation is a dry run
.NOTES
	This command requires a SSH type connection.
	Authority:Super, Service, Edit
		Any role granted the ch_movetospare right
	Usage:
	- Access to all domains is required to run this command.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$SourcePD_Id,
		[Parameter(Mandatory)]	[String]	$SourceChunk_Position,
		[Parameter()]			[Switch]	$DryRun,
		[Parameter()]			[Switch]	$nowait,
		[Parameter()]			[Switch]	$Devtype
	)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process
	{	$movechcmd = "movechtospare -f "
		if($DryRun)		{	$movechcmd += " -dr "	}
		if($nowait)		{	$movechcmd += " -nowait "	}
		if($Devtype)	{	$movechcmd += " -devtype "	}
		$movechcmd += $SourcePD_Id+":"+$SourceChunk_Position
		write-verbose "cmd is -> $movechcmd " 
		$Result = Invoke-A9CLICommand -cmds  $movechcmd		
	}
end
	{	if([string]::IsNullOrEmpty($Result))	
			{	write-warning "FAILURE : " 
				return 	
			}
		elseif($Result -match "does not exist")	
			{	return $Result		
			}
		elseif($Result.count -gt 1)
			{	$range = $Result.count
				$tempFile = [IO.Path]::GetTempFileName()
				foreach ($s in  $Result[0..$range] )
					{	$s= [regex]::Replace($s,"^ +","")
						$s= [regex]::Replace($s," +"," ")
						$s= [regex]::Replace($s," ",",")
						$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'
						Add-Content -Path $tempFile -Value $s
					}
				$returnresult = Import-Csv $tempFile
				remove-item $tempFile
				return $returnresult
			}
		else{	return $Result	
			}
	}
}

Function Move-A9PhyscialDisk
{
<#
.SYNOPSIS
	Moves data from specified Physical Disks (PDs) to a temporary location selected by the system
.DESCRIPTION
	Moves data from specified Physical Disks (PDs) to a temporary location selected by the system
.EXAMPLE
    PS:> Move-A9PhyscialDisk -PD_Id 0

	Example shows moves data from Physical Disks 0  to a temporary location
.EXAMPLE	
	PS:> Move-A9PhyscialDisk -PD_Id 0  

	Example displays a dry run of moving the data on physical disk 0 to free or sparespace
.PARAMETER PD_Id
    Specifies the physical disk ID. This specifier can be repeated to move multiple physical disks.
.PARAMETER DryRun
	Specifies that the operation is a dry run, and no physical disks are actually moved.
.PARAMETER Nowait
	Specifies that the command returns before the operation is completed.
.PARAMETER Devtype
	Permits the moves to happen to different device types.
.PARAMETER Perm
	Makes the moves permanent, removes source tags after relocation
.NOTES
	This command requires a SSH type connection.
	Authority:Super, Service, Edit
		Any role granted the pd_move right
	Usage:
	- Access to all domains is required to run this command.
	- The destination physical disks do not need to be specified as the system automatically determines the spare locations.
	- Specifying the -dr option can be used to see if the specified moves succeed and the results (quality) of the moves.
#>
[CmdletBinding()]
param(	[Parameter()]			[Switch]	$DryRun,
		[Parameter()]			[Switch]	$nowait,
		[Parameter()]			[Switch]	$Devtype,
		[Parameter(Mandatory)]	[String]	$PD_Id
	)
Begin
	{	Test-A9Connection -Clienttype 'SshClient'
	}
process	
	{	$movechcmd = "movepd -f"
		if($DryRun)	{	$movechcmd += " -dr "	}
		if($nowait)	{	$movechcmd += " -nowait "	}
		if($Devtype){	$movechcmd += " -devtype "	}
		$params = $PD_Id
		$movechcmd += " $params"
		write-verbose "Push physical disk command => $movechcmd " 
		$Result = Invoke-A9CLICommand -cmds  $movechcmd
	}
end
	{	if( ([string]::IsNullOrEmpty($Result)) -or ($Result -match "FAILURE") )	
			{	write-warning "Failure: $Result"
				return 	
			}
		if($Result -match "-Detailed_State-")
			{	$range = $Result.count
				$tempFile = [IO.Path]::GetTempFileName()
				foreach ($s in  $Result[0..$range] )
					{	$s= [regex]::Replace($s,"^ +","")
						$s= [regex]::Replace($s," +"," ")
						$s= [regex]::Replace($s," ",",")
						$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'
						Add-Content -Path $tempFile -Value $s
					}
				$returnresult = Import-Csv $tempFile
				remove-item $tempFile
				return $returnresult
			}
		else	
			{	return $Result	
			}
	}
}

Function Move-A9PhysicalDiskToSpare
{
<#
.SYNOPSIS
	Moves data from specified Physical Disks (PDs) to a temporary location selected by the system.
.DESCRIPTION
	Moves data from specified Physical Disks (PDs) to a temporary location selected by the system.
.EXAMPLE
    PS:> Move-A9PhysicalDiskToSpare -PD_Id 0 

	Displays a dry run of moving the data on PD 0 to free or spare space
.EXAMPLE
    PS:> Move-A9PhysicalDiskToSpare -PD_Id 0 -DryRun
.EXAMPLE
    PS:> Move-A9PhysicalDiskToSpare -PD_Id 0 -Vacate
.EXAMPLE
    PS:> Move-A9PhysicalDiskToSpare -PD_Id 0 -Permanent
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
.NOTES
	This command requires a SSH type connection.
	Authority:Super, Service, Edit
		Any role granted the pd_movetospare right
	Usage:
	- Access to all domains is required to run this command.
	- The destination physical disks do not need to be specified as the system automatically determines the spare locations.
	- Specifying the -dr option can be used to see if the specified moves succeed and the results (quality) of the moves.
#>
[CmdletBinding()]
param(	[Parameter(mandatory)]	[String]	$PD_Id,
		[Parameter()]			[Switch]	$DryRun,
		[Parameter()]			[Switch]	$nowait,
		[Parameter()]			[Switch]	$DevType,
		[Parameter()]			[Switch]	$Vacate,
		[Parameter()]			[Switch]	$Perm, 
		[Parameter()]			[Switch]	$Ovrd
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$movechcmd = "movepdtospare -f"
	if($DryRun)		{	$movechcmd += " -dr "		}	
	if($nowait)		{	$movechcmd += " -nowait "	}
	if($DevType)	{	$movechcmd += " -devtype "	}
	if($Vacate)		{	$movechcmd += " -vacate "	}
	if($Perm)		{	$movechcmd += " -perm "		}
	if($Ovrd)		{	$movechcmd += " -ovrd "		}
	$movechcmd += " $PD_Id"
	write-verbose "push physical disk to spare cmd is  => $movechcmd "
	$Result = Invoke-A9CLICommand -cmds  $movechcmd
}
end
{	if([string]::IsNullOrEmpty($Result)){	return "FAILURE : "	}
	if($Result -match "Error:")			{	return $Result	}
	if($Result -match "Move")
		{	$range = $Result.count
			$tempFile = [IO.Path]::GetTempFileName()
			foreach ($s in  $Result[0..$range] )
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +"," ")
					$s= [regex]::Replace($s," ",",")
					$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'
					Add-Content -Path $tempFile -Value $s
				}
			$returnresults = Import-Csv $tempFile
			remove-item $tempFile
			return $returnresults
		}
	else{	return $Result	}
}
}

Function Move-A9RelocPhysicalDisk
{
<#
.SYNOPSIS
	Command moves chunklets that were on a physical disk to the target of relocation.
.DESCRIPTION
	Command moves chunklets that were on a physical disk to the target of relocation.
.EXAMPLE
    PS:> Move-A9RelocPhysicalDisk -diskID 8 -DryRun
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]							[String]	$diskID,
		[Parameter()]							[Switch]	$DryRun,
		[Parameter()]							[Switch]	$nowait,
		[Parameter()]							[Switch]	$partial
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{	if ( -not $(Test-A9CLI) ) 	{	return }
	$movechcmd = "moverelocpd -f "
	if($DryRun)		{	$movechcmd += " -dr "	}	
	if($nowait)		{	$movechcmd += " -nowait "	}
	if($partial)	{	$movechcmd += " -partial "	}
	if($diskID)		{	$movechcmd += " $diskID"	}
	else			{	return "FAILURE : No parameters specified"	}
	write-verbose "move relocation pd cmd is => $movechcmd " 
	$Result = Invoke-A9CLICommand -cmds  $movechcmd
	if([string]::IsNullOrEmpty($Result))	{	return "FAILURE : "	}
	if($Result -match "Error:")				{	return $Result		}	
	if($Result -match "There are no chunklets to move")	{	return "There are no chunklets to move"	}	
	if($Result -match " Move -State- -Detailed_State-")
		{	$range = $Result.count
			$tempFile = [IO.Path]::GetTempFileName()
			foreach ($s in  $Result[0..$range] )
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +"," ")
					$s= [regex]::Replace($s," ",",")
					$s= $s.Trim() -replace 'Move,-State-,-Detailed_State-','Move,State,Detailed_State'
					Add-Content -Path $tempFile -Value $s			
				}
			Import-Csv $tempFile
			remove-item $tempFile
		}
	else	{	return $Result	}
}
}

Function Remove-A9Spare
{
<#
.SYNOPSIS
    Command removes chunklets from the spare chunklet list.
.DESCRIPTION
    Command removes chunklets from the spare chunklet list.
.EXAMPLE
    PS:> Remove-A9Spare_CLI -Pdid_chunkNumber "1:3"
	
	Example removes a spare chunklet from position 3 on physical disk 1:
.EXAMPLE
	PS:> Remove-A9Spare –pos "1:0.2:3:121"
	
	Example removes a spare chuklet from  the position in a drive cage, drive magazine, physical disk,and chunklet number. –pos 1:0.2:3:121, where 1 is the drive cage, 0.2 is the drive magazine, 3 is the physical disk, and 121 is the chunklet number. 	
.PARAMETER Pdid_chunkNumber
    Specifies the identification of the physical disk and the chunklet number on the disk.
.PARAMETER pos
    Specifies the position of a specific chunklet identified by its position in a drive cage, drive magazine, physical disk, and chunklet number.
.NOTES
	This command requires a SSH type connection.
	Authority:Super, Service
	Any role granted the spare_remove right
	Usage:
	- Access to all domains is required to run this command.
	- Verify the removal of spare chunklets by issuing the showspare command.
	- If a wildcard ("a") is used or the -p flag is specified, prints the number of spares removed. Otherwise, if all the explicitly specified spares could not be removed, prints an error message.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='pdid', mandatory)]		[String]	$Pdid_chunkNumber,	
		[Parameter(parametersetname='pos',  mandatory)]		[String]	$pos,
		[Parameter()]										[Switch]	$Partial	
	)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process	
	{ 	$newsparecmd = "removespare -f "
		if($Partial)			{ 	$newsparecmd += " -p "				}
		if($Pdid_chunkNumber)	{	$newsparecmd += " $Pdid_chunkNumber"}
		if($pos)				{	$newsparecmd += " -pos $pos"		}
		$Result = Invoke-A9CLICommand -cmds  $newsparecmd
	}
end
	{	if($Result -match "removed")	{	write-host "Success : Removed spare chunklet "  -ForegroundColor green	}
		return $Result
	}
}
