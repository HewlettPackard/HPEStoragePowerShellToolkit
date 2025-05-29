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
.PARAMETER used 
    Shows only used spare chunklets. By default all spare chunklets are shown.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
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
.NOTES
	This command requires a SSH type connection.
	Authority: Any role in the system
	Usage: The showpdch command is a more general and versatile command that can be used instead of showspare
#>
[CmdletBinding()]
param(	[Parameter()]	[Switch]	$used,
		[Parameter()]	[switch]	$ShowRaw
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
		if($Result.count -lt 3)	{	write-warning "No data available"		}	
		elseif (-not $showraw -and ($Result.count -gt 3) )	
			{ 	foreach ($s in $Result[0..($Result.count - 3)] )
					{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
						Add-Content -Path $tempFile -Value $s
					}
				$result = Import-Csv $tempFile
			}
		remove-item $tempFile
		return $result
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
.EXAMPLE
    PS:> Move-A9Chunklet -SourcePD_Id 24 -SourceChunk_Position 0  -TargetPD_Id 64 -TargetChunk_Position 50 

	This example moves the chunklet in position 0 on disk 24, to position 50 on disk 64 and chunklet in position 0 on disk 25, to position 1 on disk 27
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
.EXAMPLE
    Move-ChunkletToSpare -SourcePD_Id 66 -SourceChunk_Position 0  -force 
	Examples shows chunklet 0 from physical disk 66 is moved to spare
.EXAMPLE	
	PS:> Move-A9ChunkletToSpare -SourcePD_Id 3 -SourceChunk_Position 0
.EXAMPLE	
	PS:> Move-A9ChunkletToSpare -SourcePD_Id 4 -SourceChunk_Position 0 -nowait
.EXAMPLE
    PS:> Move-A9ChunkletToSpare -SourcePD_Id 5 -SourceChunk_Position 0 -Devtype
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
.EXAMPLE
    PS:> Move-A9PhyscialDisk -PD_Id 0

	Example shows moves data from Physical Disks 0  to a temporary location
.EXAMPLE	
	PS:> Move-A9PhyscialDisk -PD_Id 0  

	Example displays a dry run of moving the data on physical disk 0 to free or sparespace
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
.EXAMPLE
    PS:> Move-A9PhysicalDiskToSpare -PD_Id 0 

	Displays a dry run of moving the data on PD 0 to free or spare space
.EXAMPLE
    PS:> Move-A9PhysicalDiskToSpare -PD_Id 0 -DryRun
.EXAMPLE
    PS:> Move-A9PhysicalDiskToSpare -PD_Id 0 -Vacate
.EXAMPLE
    PS:> Move-A9PhysicalDiskToSpare -PD_Id 0 -Permanent
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
.PARAMETER diskID    
	Specifies that the chunklets that were relocated from specified disk (<fd>), are moved to the specified destination disk (<td>). If destination disk (<td>) is not specified then the chunklets are moved back
    to original disk (<fd>). The <fd> specifier is not needed if -p option is used, otherwise it must be used at least once on the command line. If this specifier is repeated then the operation is performed on multiple disks.
.PARAMETER DryRun	
	Specifies that the operation is a dry run. No physical disks are actually moved.  
.PARAMETER nowait
	Specifies that the command returns before the operation is completed.
.PARAMETER partial
    Move as many chunklets as possible. If this option is not specified, the command fails if not all specified chunklets can be moved.
.EXAMPLE
    PS:> Move-A9RelocPhysicalDisk -diskID 8 -DryRun
	moves chunklets that were on physical disk 8 that were relocated to another position, back to physical disk 8
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$diskID,
		[Parameter()]	[Switch]	$DryRun,
		[Parameter()]	[Switch]	$nowait,
		[Parameter()]	[Switch]	$partial
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
.PARAMETER Pdid_chunkNumber
    Specifies the identification of the physical disk and the chunklet number on the disk.
.PARAMETER pos
    Specifies the position of a specific chunklet identified by its position in a drive cage, drive magazine, physical disk, and chunklet number.
.EXAMPLE
    PS:> Remove-A9Spare_CLI -Pdid_chunkNumber "1:3"
	
	Example removes a spare chunklet from position 3 on physical disk 1:
.EXAMPLE
	PS:> Remove-A9Spare –pos "1:0.2:3:121"
	
	Example removes a spare chuklet from  the position in a drive cage, drive magazine, physical disk,and chunklet number. –pos 1:0.2:3:121, where 1 is the drive cage, 0.2 is the drive magazine, 3 is the physical disk, and 121 is the chunklet number. 	
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

# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABECfaH3TxSif
# h2iZx0wz0EbVRP4kJ8ioKcYnWDVjQQcBMyP3fKaQk7eO/Vg2xy6X5yaKladBa30j
# TUc0ifFitYjWoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
# KoZIhvcNAQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExp
# bWl0ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0yMTA1
# MjUwMDAwMDBaFw0yODEyMzEyMzU5NTlaMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AI3nlBIiBCR0Lv8WIwKSirauNoWsR9QjkSs+3H3iMaBRb6yEkeNSirXilt7Qh2Mk
# iYr/7xKTO327toq9vQV/J5trZdOlDGmxvEk5mvFtbqrkoIMn2poNK1DpS1uzuGQ2
# pH5KPalxq2Gzc7M8Cwzv2zNX5b40N+OXG139HxI9ggN25vs/ZtKUMWn6bbM0rMF6
# eNySUPJkx6otBKvDaurgL6en3G7X6P/aIatAv7nuDZ7G2Z6Z78beH6kMdrMnIKHW
# uv2A5wHS7+uCKZVwjf+7Fc/+0Q82oi5PMpB0RmtHNRN3BTNPYy64LeG/ZacEaxjY
# cfrMCPJtiZkQsa3bPizkqhiwxgcBdWfebeljYx42f2mJvqpFPm5aX4+hW8udMIYw
# 6AOzQMYNDzjNZ6hTiPq4MGX6b8fnHbGDdGk+rMRoO7HmZzOatgjggAVIQO72gmRG
# qPVzsAaV8mxln79VWxycVxrHeEZ8cKqUG4IXrIfptskOgRxA1hYXKfxcnBgr6kX1
# 773VZ08oXgXukEx658b00Pz6zT4yRhMgNooE6reqB0acDZM6CWaZWFwpo7kMpjA4
# PNBGNjV8nLruw9X5Cnb6fgUbQMqSNenVetG1fwCuqZCqxX8BnBCxFvzMbhjcb2L+
# plCnuHu4nRU//iAMdcgiWhOVGZAA6RrVwobx447sX/TlAgMBAAGjggESMIIBDjAf
# BgNVHSMEGDAWgBSgEQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUMuuSmv81
# lkgvKEBCcCA2kVwXheYwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEE
# ATBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFD
# ZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAQEA
# Er+h74t0mphEuGlGtaskCgykime4OoG/RYp9UgeojR9OIYU5o2teLSCGvxC4rnk7
# U820+9hEvgbZXGNn1EAWh0SGcirWMhX1EoPC+eFdEUBn9kIncsUj4gI4Gkwg4tsB
# 981GTyaifGbAUTa2iQJUx/xY+2wA7v6Ypi6VoQxTKR9v2BmmT573rAnqXYLGi6+A
# p72BSFKEMdoy7BXkpkw9bDlz1AuFOSDghRpo4adIOKnRNiV3wY0ZFsWITGZ9L2PO
# mOhp36w8qF2dyRxbrtjzL3TPuH7214OdEZZimq5FE9p/3Ef738NSn+YGVemdjPI6
# YlG87CQPKdRYgITkRXta2DCCBeEwggRJoAMCAQICEQCZcNC3tMFYljiPBfASsES3
# MA0GCSqGSIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBD
# QSBSMzYwHhcNMjIwNjA3MDAwMDAwWhcNMjUwNjA2MjM1OTU5WjB3MQswCQYDVQQG
# EwJVUzEOMAwGA1UECAwFVGV4YXMxKzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBF
# bnRlcnByaXNlIENvbXBhbnkxKzApBgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRl
# cnByaXNlIENvbXBhbnkwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCi
# DYlhh47xvo+K16MkvHuwo3XZEL+eEWw4MQEoV7qsa3zqMx1kHryPNwVuZ6bAJ5OY
# oNch6usNWr9MZlcgck0OXnRGrxl2FNNKOqb8TAaoxfrhBSG7eZ1FWNqxJAOlzXjg
# 6KEPNdlhmfVvsSDolVDGr6yEXYK9WVhVtEApyLbSZKLED/0OtRp4CtjacOCF/unb
# vfPZ9KyMVKrCN684Q6BpknKH3ooTZHelvfAzUGbHxfKvq5HnIpONKgFhbpdZXKN7
# kynNjRm/wrzfFlp+m9XANlmDnXieTeKEeI3y3cVxvw9HTGm4yIFt8IS/iiZwsKX6
# Y94RkaDzaGB1fZI19FnRo2Fx9ovz187imiMrpDTsj8Kryl4DMtX7a44c8vORYAWO
# B17CKHt52W+ngHBqEGFtce3KbcmIqAH3cJjZUNWrji8nCuqu2iL2Lq4bjcLMdjqU
# +2Uc00ncGfvP2VG2fY+bx78e47m8IQ2xfzPCEBd8iaVKaOS49ZE47/D9Z8sAVjcC
# AwEAAaOCAYkwggGFMB8GA1UdIwQYMBaAFA8qyyCHKLjsb0iuK1SmKaoXpM0MMB0G
# A1UdDgQWBBRtaOAY0ICfJkfK+mJD1LyzN0wLzjAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBKBgNVHSAEQzBBMDUGDCsG
# AQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQ
# UzAIBgZngQwBBAEwSQYDVR0fBEIwQDA+oDygOoY4aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQVIzNi5jcmwweQYIKwYBBQUH
# AQEEbTBrMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNydDAjBggrBgEFBQcwAYYXaHR0cDov
# L29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggGBACPwE9q/9ANM+zGO
# lq4SZg7qDpsDW09bDbdjyzAmxxJk2GhD35Md0IluPppla98zFjnuXWpVqakGk9vM
# KxiooQ9QVDrKYtx9+S8Qui21kT8Ekhrm+GYecVfkgi4ryyDGY/bWTGtX5Nb5G5Gp
# DZbv6wEuu3TXs6o531lN0xJSWpJmMQ/5Vx8C5ZwRgpELpK8kzeV4/RU5H9P07m8s
# W+cmLx085ndID/FN84WmBWYFUvueR5juEfibuX22EqEuuPBORtQsAERoz9jStyza
# gj6QxPG9C4ItZO5LT+EDcHH9ti6CzxexePIMtzkkVV9HXB6OUjgeu6MbNClduKY4
# qFiutdbVC8VPGncuH2xMxDtZ0+ip5swHvPt/cnrGPMcVSEr68cSlUU26Ln2u/03D
# eZ6b0R3IUdwWf4K/1X6NwOuifwL9gnTM0yKuN8cOwS5SliK9M1SWnF2Xf0/lhEfi
# VVeFlH3kZjp9SP7v2I6MPdI7xtep9THwDnNLptqeF79IYoqT3TCCBhowggQCoAMC
# AQICEGIdbQxSAZ47kHkVIIkhHAowDQYJKoZIhvcNAQEMBQAwVjELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAwMFoXDTM2
# MDMyMTIzNTk1OVowVDELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIENBIFIz
# NjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJsrnVP6NT+OYAZDasDP
# 9X/2yFNTGMjO02x+/FgHlRd5ZTMLER4ARkZsQ3hAyAKwktlQqFZOGP/I+rLSJJmF
# eRno+DYDY1UOAWKA4xjMHY4qF2p9YZWhhbeFpPb09JNqFiTCYy/Rv/zedt4QJuIx
# eFI61tqb7/foXT1/LW2wHyN79FXSYiTxcv+18Irpw+5gcTbXnDOsrSHVJYdPE9s+
# 5iRF2Q/TlnCZGZOcA7n9qudjzeN43OE/TpKF2dGq1mVXn37zK/4oiETkgsyqA5lg
# AQ0c1f1IkOb6rGnhWqkHcxX+HnfKXjVodTmmV52L2UIFsf0l4iQ0UgKJUc2RGarh
# OnG3B++OxR53LPys3J9AnL9o6zlviz5pzsgfrQH4lrtNUz4Qq/Va5MbBwuahTcWk
# 4UxuY+PynPjgw9nV/35gRAhC3L81B3/bIaBb659+Vxn9kT2jUztrkmep/aLb+4xJ
# bKZHyvahAEx2XKHafkeKtjiMqcUf/2BG935A591GsllvWwIDAQABo4IBZDCCAWAw
# HwYDVR0jBBgwFoAUMuuSmv81lkgvKEBCcCA2kVwXheYwHQYDVR0OBBYEFA8qyyCH
# KLjsb0iuK1SmKaoXpM0MMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYEVR0gADAIBgZn
# gQwBBAEwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRv
# MG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAG/4Lhd2M2bnuhFSCb
# E/8E/ph1RGHDVpVx0ZE/haHrQECxyNbgcv2FymQ5PPmNS6Dah66dtgCjBsULYAor
# 5wxxcgEPRl05pZOzI3IEGwwsepp+8iGsLKaVpL3z5CmgELIqmk/Q5zFgR1TSGmxq
# oEEhk60FqONzDn7D8p4W89h8sX+V1imaUb693TGqWp3T32IKGfIgy9jkd7GM7YCa
# 2xulWfQ6E1xZtYNEX/ewGnp9ZeHPsNwwviJMBZL4xVd40uPWUnOJUoSiugaz0yWL
# ODRtQxs5qU6E58KKmfHwJotl5WZ7nIQuDT0mWjwEx7zSM7fs9Tx6N+Q/3+49qTtU
# vAQsrEAxwmzOTJ6Jp6uWmHCgrHW4dHM3ITpvG5Ipy62KyqYovk5O6cC+040Si15K
# JpuQ9VJnbPvqYqfMB9nEKX/d2rd1Q3DiuDexMKCCQdJGpOqUsxLuCOuFOoGbO7Uv
# 3RjUpY39jkkp0a+yls6tN85fJe+Y8voTnbPU1knpy24wUFBkfenBa+pRFHwCBB1Q
# tS+vGNRhsceP3kSPNrrfN2sRzFYsNfrFaWz8YOdU254qNZQfd9O/VjxZ2Gjr3xgA
# NHtM3HxfzPYF6/pKK8EE4dj66qKKtm2DTL1KFCg/OYJyfrdLJq1q2/HXntgr2GVw
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG58wghubAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQAqgJu4VDgsA46sM5lCWjke57zum1Ox/5fghTNpmwRqtjGGaST0lWcwp
# 1BT88ezHAla6YS6Y76Qopf6sbT4VTM4wDQYJKoZIhvcNAQEBBQAEggGAmL8sC4wf
# hDHgr0/2BZGX9NEWeWT0iWK0qxcaALoJifIVEsZyOTkkqx+c+PhjndS1XzDznedQ
# 3y5efUf0+nCiZmnEv4Het8FiG/DStUbwfSSk8Jj0hzvLkrVda9WpOP8q8XE07b0J
# WaWKthw5G04ullB0V2SsneY7cOmbV2OJ0O8SU4s6kRT79+NtaE80vk6uG5MuOq80
# vUzsxSIOAAeylJFSRizpulQHztrm1Ch12BXviMp3nhnSPaR9JQxsmz36jsMHrkxj
# iYq1Y8sZGrJ/pnscBiS7LMEqET16OJeZ80QuNdhYAfQs+5XLe06cUr3TbH8iBxC0
# d8ARd6JnYdSZmnt2dxD0HR9j2LKPp09STEN8dUTBUvmAiqHIwuPaXqNKzAenjSb+
# X4oKWDJGPY9ST64t0GSpofqL8cAr2JznG7QctQTL5NINKzjgLQRnlEy5Afq2X+e9
# OWP7ozlMM0nKfFxLQlSirn6/CnCpEK1MA0FBMBPHF0ggEZxDjlGWKBOQoYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMNioI6rQqSXccTInuS7ZRO1IYJOMXDwD
# 5E/vw4pGZ0bMZKa7e7OMz3Iupw+idJ85BQIUSwW4+q9hDKTmOCKUQ6hGI+san0sY
# DzIwMjUwNTE1MDIyMzAzWqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
# c3QgWW9ya3NoaXJlMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMT
# J1NlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNqCCEwQwggZi
# MIIEyqADAgECAhEApCk7bh7d16c0CIetek63JDANBgkqhkiG9w0BAQwFADBVMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNTAzMjcwMDAw
# MDBaFw0zNjAzMjEyMzU5NTlaMHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5XZXN0
# IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzYwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDThJX0bqRTePI9EEt4Egc83JSBU2dhrJ+w
# Y7JgReuff5KQNhMuzVytzD+iXazATVPMHZpH/kkiMo1/vlAGFrYN2P7g0Q8oPEcR
# 3h0SftFNYxxMh+bj3ZNbbYjwt8f4DsSHPT+xp9zoFuw0HOMdO3sWeA1+F8mhg6uS
# 6BJpPwXQjNSHpVTCgd1gOmKWf12HSfSbnjl3kDm0kP3aIUAhsodBYZsJA1imWqkA
# VqwcGfvs6pbfs/0GE4BJ2aOnciKNiIV1wDRZAh7rS/O+uTQcb6JVzBVmPP63k5xc
# ZNzGo4DOTV+sM1nVrDycWEYS8bSS0lCSeclkTcPjQah9Xs7xbOBoCdmahSfg8Km8
# ffq8PhdoAXYKOI+wlaJj+PbEuwm6rHcm24jhqQfQyYbOUFTKWFe901VdyMC4gRwR
# Aq04FH2VTjBdCkhKts5Py7H73obMGrxN1uGgVyZho4FkqXA8/uk6nkzPH9QyHIED
# 3c9CGIJ098hU4Ig2xRjhTbengoncXUeo/cfpKXDeUcAKcuKUYRNdGDlf8WnwbyqU
# blj4zj1kQZSnZud5EtmjIdPLKce8UhKl5+EEJXQp1Fkc9y5Ivk4AZacGMCVG0e+w
# wGsjcAADRO7Wga89r/jJ56IDK773LdIsL3yANVvJKdeeS6OOEiH6hpq2yT+jJ/lH
# a9zEdqFqMwIDAQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNh
# lxmiMpswHQYDVR0OBBYEFIhhjKEqN2SBKGChmzHQjP0sAs5PMA4GA1UdDwEB/wQE
# AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1Ud
# IARDMEEwNQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8v
# Y3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5j
# cmwwegYIKwYBBQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYB
# BQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IB
# gQACgT6khnJRIfllqS49Uorh5ZvMSxNEk4SNsi7qvu+bNdcuknHgXIaZyqcVmhrV
# 3PHcmtQKt0blv/8t8DE4bL0+H0m2tgKElpUeu6wOH02BjCIYM6HLInbNHLf6R2qH
# C1SUsJ02MWNqRNIT6GQL0Xm3LW7E6hDZmR8jlYzhZcDdkdw0cHhXjbOLsmTeS0Se
# RJ1WJXEzqt25dbSOaaK7vVmkEVkOHsp16ez49Bc+Ayq/Oh2BAkSTFog43ldEKgHE
# DBbCIyba2E8O5lPNan+BQXOLuLMKYS3ikTcp/Qw63dxyDCfgqXYUhxBpXnmeSO/W
# A4NwdwP35lWNhmjIpNVZvhWoxDL+PxDdpph3+M5DroWGTc1ZuDa1iXmOFAK4iwTn
# lWDg3QNRsRa9cnG3FBBpVHnHOEQj4GMkrOHdNDTbonEeGvZ+4nSZXrwCW4Wv2qyG
# DBLlKk3kUW1pIScDCpm/chL6aUbnSsrtbepdtbCLiGanKVR/KC1gsR0tC6Q0RfWO
# I4owggYUMIID/KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUA
# MFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNV
# BAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AM2Y2ENBq26CK+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStS
# VjeYXIjfa3ajoW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQ
# BaCxpectRGhhnOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE
# 9cbY11XxM2AVZn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExS
# Lnh+va8WxTlA+uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OII
# q/fWlwBp6KNL19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGd
# F+z+Gyn9/CRezKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w
# 76kOLIaFVhf5sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4Cllg
# rwIDAQABo4IBXDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUw
# HQYDVR0OBBYEFF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjAS
# BgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28u
# Y29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEF
# BQcBAQRwMG4wRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0O
# NVgMnoEdJVj9TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc
# 6ZvIyHI5UkPCbXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1
# OSkkSivt51UlmJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz
# 2wSKr+nDO+Db8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y
# 4Il6ajTqV2ifikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVM
# CMPY2752LmESsRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBe
# Nh9AQO1gQrnh1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupia
# AeNHe0pWSGH2opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU
# +CCQaL0cJqlmnx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/Sjws
# usWRItFA3DE8MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7
# xpMeYRriWklUPsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs6
# 56Oz3TbLyXVoMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAs
# BgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJ
# BZvMWhUP2ZQQRLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQn
# Oh2qmcxGzjqemIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypo
# GJrruH/drCio28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0p
# KG9ki+PC6VEfzutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13j
# QEV1JnUTCm511n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9
# YrcmXcLgsrAimfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/y
# Vl4jnDcw6ULJsBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVg
# h60KmLmzXiqJc6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/
# OLoanEWP6Y52Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+Nr
# LedIxsE88WzKXqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58N
# Hs57ZPUfECcgJC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9U
# gOHYm8Cd8rIDZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1Ud
# DwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0
# eS5jcmwwNQYIKwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3
# OyWM637ayBeR7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJ
# JlFfym1Doi+4PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0m
# UGQHbRcF57olpfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTw
# bD/zIExAopoe3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i
# 111TW7HV1AtsQa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGe
# zjM6CRpcWed/ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+
# 8aW88WThRpv8lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH
# 29308ZkpKKdpkiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrs
# xrYJD+3f3aKg6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6
# Ii8+CQOYDwXM+yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz
# 7NgAnOgpCdUo4uDyllU9PzGCBJIwggSOAgEBMGowVTELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMg
# VGltZSBTdGFtcGluZyBDQSBSMzYCEQCkKTtuHt3XpzQIh616TrckMA0GCWCGSAFl
# AwQCAgUAoIIB+TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTI1MDUxNTAyMjMwM1owPwYJKoZIhvcNAQkEMTIEMFHt71OeWjZ0IZz7
# 6qTsVhq9Umh/FYoimz8/zOef7qWp80ynl47+esI8C7HS7XsLZjCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAVcivqIaFiMZd46I1GbSqZVDBRKMb+ihc2SNoLUhWddk42OCWKtMqoB9S
# lxDrxp7kb2DEUxyU6XEF3jB5olO3748kIbE8MekEUN8pIXwPqT6PJN0tPgWl8yJy
# HiTEOTTNvW4ldlDzZK6KfIA16x1hrtZ+DLam/91+T8WCSzvme+8Mn99xugDPvy/C
# Zh/FM9jpc7gZ4DBr0F5y8Ie9xznKdEFnuIHJ/s4wtWwqbj/Ta6Q9j5cWt30sf6YP
# zl4pKSRncyAUaAH5v99Bic8AAqOUW5ZrvrRuum3jcNEsyqS5BTPUgCHE2DfZZVqz
# GuQkxE0aRgIIw2gZvhf0kfgXtDg+YPHinoNskN00imQfjcIHBgX1SvYIQy4pKPUt
# Tknwn68WQkwpnJlsVBqVeiRKC2BrHngsQx9NhoZTwxeTpNIQpVx7tH7tclFOome2
# FEQ4O09s3mTxvucA7wT/jRpcQMPqyn/c02GGhNMqE/Ue7kcnjLSSLRLop3XeXBNw
# CXYIb9fViTNNWFhvSTSJh1VlAQ4it39wA/PTTG0SaOkZRwNdH0WJ50jcob1yWg64
# tpWXo5fg7GCAlCOrHTl6BvNgy+DDgBdG99JSk3eH+GwL0VBW9T8nhXoTOB4FZLol
# iymPqSmLoDIhj2Zur7cgMmQscLCjFn1IRSXagPg+nlAAp8Ozm7A=
# SIG # End signature block
