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
	
	Displays information about chunklets in the system that are reserved for spares
.PARAMETER used 
    Display only used spare chunklets
.PARAMETER count
	Number of loop iteration
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[Switch]	$used,	
		[Parameter()]							[Switch]	$count
)
process
{	if ( -not $(Test-A9CLI) ) 	{	return }
	$spareinfocmd = "showspare "
	if($used)	{	$spareinfocmd+= " -used "	}
	write-verbose "Get list of spare information cmd is => $spareinfocmd "
	$Result = Invoke-A9CLICommand -cmds  $spareinfocmd
	$tempFile = [IO.Path]::GetTempFileName()
	$range1 = $Result.count - 3 
	$range = $Result.count	
	if($count)	{	foreach ($s in  $Result[0..$range] )
						{	if ($s -match "Total chunklets")
								{	remove-item $tempFile
									return $s
								}
						}
				}	
	if($Result.count -eq 3)
		{	remove-item $tempFile
			return "No data available"			
		}	
	foreach ($s in  $Result[0..$range1] )
		{	if (-not $s)
				{	write-host "No data available"
					remove-item $tempFile
					return
				}
			$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			Add-Content -Path $tempFile -Value $s
		}
	Import-Csv $tempFile
	remove-item $tempFile
}
}

Function New-A9Spare
{
<#
.SYNOPSIS
    Allocates chunklet resources as spares. Chunklets marked as spare are not used for logical disk creation and are reserved explicitly for spares, thereby guaranteeing a minimum amount of spare space.
.DESCRIPTION
    Allocates chunklet resources as spares. Chunklets marked as spare are not used for logical disk creation and are reserved explicitly for spares, thereby guaranteeing a minimum amount of spare space. 
.EXAMPLE
    PS:> New-A9Spare -Pdid_chunkNumber "15:1"
	This example marks chunklet 1 as spare for physical disk 15
.EXAMPLE
	PS:> New-A9Spare –pos "1:0.2:3:121"
	
	This example specifies the position in a drive cage, drive magazine, physical disk,and chunklet number. –pos 1:0.2:3:121, where 1 is the drive cage, 0.2 is the drive magazine, 3 is the physical disk, and 121 is the chunklet number.
.PARAMETER Pdid_chunkNumber
    Specifies the identification of the physical disk and the chunklet number on the disk.
.PARAMETER pos
    Specifies the position of a specific chunklet identified by its position in a drive cage, drive magazine, physical disk, and chunklet number.
.PARAMETER Partial
	Specifies that partial completion of the command is acceptable.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Pdid_chunkNumber,
		[Parameter(ValueFromPipeline=$true)]	[String]	$pos,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Partial
)
process	
{	if ( -not $(Test-A9CLI) ) 	{	return }
	$newsparecmd = "createspare "
	if($Partial)	{	$newsparecmd +=" -p "	}
	if(!(($pos) -or ($Pdid_chunkNumber)))	{	return "FAILURE : Please specify any one of the params , specify either -PDID_chunknumber or -pos"	}
	if($Pdid_chunkNumber)
		{	$newsparecmd += " -f $Pdid_chunkNumber"
			if($pos)	{	return "FAILURE : Do not specify both the params , specify either -PDID_chunknumber or -pos"	}
		}
	if($pos){	$newsparecmd += " -f -pos $pos"
				if($Pdid_chunkNumber)	{	return "FAILURE : Do not specify both the params , specify either -PDID_chunknumber or -pos"	}
			}
	$Result = Invoke-A9CLICommand -cmds  $newsparecmd
	write-verbose "Spare  cmd -> $newsparecmd "
	if(-not $Result){	write-host "Success : Create spare chunklet "	}
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
    PS:> Move-A9Chunklet -SourcePD_Id 24 -SourceChunk_Position 0  -TargetPD_Id	64 -TargetChunk_Position 50 

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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]	[String]	$SourcePD_Id,
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]	[String]	$SourceChunk_Position,	
		[Parameter(ValueFromPipeline=$true)]					[String]	$TargetPD_Id,
		[Parameter(ValueFromPipeline=$true)]					[String]		$TargetChunk_Position,
		[Parameter()]											[Switch]	$DryRun,
		[Parameter()]											[Switch]	$NoWait,		
		[Parameter()]											[Switch]	$Devtype,
		[Parameter()]											[Switch]	$Perm,
		[Parameter()]											[Switch]	$Ovrd
)
process
{	if ( -not $(Test-A9CLI) ) 	{	return }
	$movechcmd = "movech -f"
	if($DryRun)	{	$movechcmd += " -dr "	}
	if($NoWait)	{	$movechcmd += " -nowait "	}
	if($Devtype){	$movechcmd += " -devtype "	}
	if($Perm)	{	$movechcmd += " -perm "	}
	if($Ovrd)	{	$movechcmd += " -ovrd "	}
	if(($SourcePD_Id)-and ($SourceChunk_Position))
		{	$params = $SourcePD_Id+":"+$SourceChunk_Position
			$movechcmd += " $params"
			if(($TargetPD_Id) -and ($TargetChunk_Position))	{	$movechcmd += "-"+$TargetPD_Id+":"+$TargetChunk_Position	}
		}
	else	{	return "FAILURE :  No parameters specified "	}
	write-verbose "move chunklet cmd -> $movechcmd "	
	$Result = Invoke-A9CLICommand -cmds  $movechcmd	
	if([string]::IsNullOrEmpty($Result))	{	return "FAILURE : Disk $SourcePD_Id chunklet $SourceChunk_Position is not in use. "	}
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
			Import-Csv $tempFile
			remove-item $tempFile
		}
	else	{	return $Result	}
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
.PARAMETER force
    Specifies that the command is forced. If this option is not used,it will do dry run,No chunklets are actually moved.
.PARAMETER nowait
	Specifies that the command returns before the operation is completed.
.PARAMETER Devtype
	Permits the moves to happen to different device types.
.PARAMETER DryRun
	Specifies that the operation is a dry run
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SourcePD_Id,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SourceChunk_Position,
		[Parameter()]											[Switch]	$DryRun,
		[Parameter()]											[Switch]	$nowait,
		[Parameter()]											[Switch]	$Devtype
	)
process
{	if ( -not $(Test-A9CLI) ) 	{	return }
	$movechcmd = "movechtospare -f"
	if($DryRun)		{	$movechcmd += " -dr "	}
	if($nowait)		{	$movechcmd += " -nowait "	}
	if($Devtype)	{	$movechcmd += " -devtype "	}
	if(($SourcePD_Id) -and ($SourceChunk_Position))
		{	$params = $SourcePD_Id+":"+$SourceChunk_Position
			$movechcmd += " $params"
		}
	else{	return "FAILURE : No parameters specified"	}
	write-verbose "cmd is -> $movechcmd " 
	$Result = Invoke-A9CLICommand -cmds  $movechcmd
	if([string]::IsNullOrEmpty($Result))	{	return "FAILURE : "	}
	elseif($Result -match "does not exist")	{	return $Result		}
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
			Import-Csv $tempFile
			remove-item $tempFile
		}
	else	{	return $Result	}
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
    PS:> Move-A9PhyscialDisk -PD_Id 0 -force
	Example shows moves data from Physical Disks 0  to a temporary location
.EXAMPLE	
	PS:> Move-A9PhyscialDisk -PD_Id 0  
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[Switch]	$DryRun,
		[Parameter()]	[Switch]	$nowait,
		[Parameter()]	[Switch]	$Devtype,
		[Parameter(Mandatory=$true)]	[String]	$PD_Id
	)
Begin
{	Test-A9Connection -Clienttype 'SshClient'
}
process	
{	$movechcmd = "movepd -f"
	if($DryRun)	{	$movechcmd += " -dr "	}
	if($nowait)	{	$movechcmd += " -nowait "	}
	if($Devtype){	$movechcmd += " -devtype "	}
	if($PD_Id)	{	$params = $PD_Id
					$movechcmd += " $params"
				}
	else		{	return "FAILURE : No parameters specified"	}
	write-verbose "Push physical disk command => $movechcmd " 
	$Result = Invoke-A9CLICommand -cmds  $movechcmd
	if([string]::IsNullOrEmpty($Result))	{	return "FAILURE : $Result"	}
	if($Result -match "FAILURE")			{	return $Result	}
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
			Import-Csv $tempFile
			remove-item $tempFile
		}
	else	{	return $Result	}
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
    PS:> Move-A9PhysicalDiskToSpare -PD_Id 0 -force  

	Displays  moving the data on PD 0 to free or spare space
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
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$PD_Id,
		[Parameter()]	[Switch]	$DryRun,
		[Parameter()]	[Switch]	$nowait,
		[Parameter()]	[Switch]	$DevType,
		[Parameter()]	[Switch]	$Vacate,
		[Parameter()]	[Switch]	$Permanent, 
		[Parameter()]	[Switch]	$Ovrd
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
	if($Permanent)	{	$movechcmd += " -perm "		}
	if($Ovrd)		{	$movechcmd += " -ovrd "		}
	if($PD_Id)		{	$params = $PD_Id
						$movechcmd += " $params"
					}
	else			{	return "FAILURE : No parameters specified"			}	
	write-verbose "push physical disk to spare cmd is  => $movechcmd "
	$Result = Invoke-A9CLICommand -cmds  $movechcmd
	if([string]::IsNullOrEmpty($Result)){	return "FAILURE : "	}
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
			Import-Csv $tempFile
			remove-item $tempFile
		}
	else	{	return $Result	}
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
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$diskID,
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
#>
[CmdletBinding()]
param(
		[Parameter(ValueFromPipeline=$true)]	[String]	$Pdid_chunkNumber,	
		[Parameter(ValueFromPipeline=$true)]	[String]	$pos
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{ 	$newsparecmd = "removespare "
	if(!(($Pdid_chunkNumber) -or ($pos)))
		{	return "FAILURE: No parameters specified"
		}
	if($Pdid_chunkNumber)
		{	$newsparecmd += " -f $Pdid_chunkNumber"
			if($pos)	{	return "FAILURE: Please select only one params, either -Pdid_chunkNumber or -pos "	}
		}
	if($pos)	{	$newsparecmd += " -f -pos $pos"	}
	$Result = Invoke-A9CLICommand -cmds  $newsparecmd
	if($Result -match "removed")	{	write-host "Success : Removed spare chunklet "  -ForegroundColor green	}
	return "$Result"
}
}

# SIG # Begin signature block
# MIIt2QYJKoZIhvcNAQcCoIItyjCCLcYCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBoYGxxP4ei
# 0JSsNuDkjnkXcy4OPFRReQloQ3pMASEYoie3HVSDijRwlI6cKPTc8s3fn4xdxQqO
# YNB6ElJJP2xxoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5YwghuSAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQJOP6gKDKHWz7QNYUdm+j66KY9jqDqmFX59jaO0V/aprclFCHQXMrprM
# 0X7yWIh+Wi6Qn2nwJcZVVwb9WeHIL2gwDQYJKoZIhvcNAQEBBQAEggGATHZisFc/
# y07Dam0t8L+qPLE5RQVUhoO23+Lc1XW9CAc4n7A3cFSnD8Pcg4MdwLAJAil770TF
# 7bCYQg3gGB+f+CgL+f9gYCKtLom9+p1xNBFfPIca7ERxeOWdFvkbymY5B2129Arq
# GTL/9CQ3ERcPb9ciDsOYNMmVFAVkDCJIKUWmEFXTgK4YDxs0x8eZN6jbRGbDoqzS
# fW3eaNs6cJ5UpKC2gvZAfD8+H1SswDxGzfxHM7mXUGnLS1cFto7nKpXHxzAErvdh
# dxdMzmCMesoCGrJkEdahzm7qh/8xO2XCiKJciTD4YcG8n+0FaI5KtKLGkhX54Dis
# yonjNTdl2p7lm7zSIRtxcSUzKsojaa5yX8mnMgXYnxmGWSp/Vo+NOlt6msGHGTE5
# 5lCY8FC3SAcVEXKQVlPiH8NzqxguWLuHsQLFHaR/XA6p6lZBKzYM5CLiD6UpDv+T
# gpygnTuhb+8/VUUifLIjKPwlB5eGFy/jJm1PyYYmHr3MlOVyF73Vc4EcoYIY3zCC
# GNsGCisGAQQBgjcDAwExghjLMIIYxwYJKoZIhvcNAQcCoIIYuDCCGLQCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQQGCyqGSIb3DQEJEAEEoIH0BIHxMIHuAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEME3kl5O2vFomup87HpzoRS0YQbGz7yYO
# xyGiOejT7MMgLRL1cqYTI08KCr0wqTZ6EQIVAOd7VFEgbeogGV0UIbmuEbVIXLyP
# GA8yMDI0MDczMTE5MjYxMlqgcqRwMG4xCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpN
# YW5jaGVzdGVyMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMTJ1Nl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNaCCEv8wggZdMIIE
# xaADAgECAhA6UmoshM5V5h1l/MwS2OmJMA0GCSqGSIb3DQEBDAUAMFUxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgQ0EgUjM2MB4XDTI0MDExNTAwMDAwMFoX
# DTM1MDQxNDIzNTk1OVowbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1hbmNoZXN0
# ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2VjdGlnbyBQ
# dWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1MIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAjdFn9MFIm739OEk6TWGBm8PY3EWlYQQ2jQae45iWgPXU
# GVuYoIa1xjTGIyuw3suUSBzKiyG0/c/Yn++d5mG6IyayljuGT9DeXQU9k8GWWj2/
# BPoamg2fFctnPsdTYhMGxM06z1+Ft0Bav8ybww21ii/faiy+NhiUM195+cFqOtCp
# JXxZ/lm9tpjmVmEqpAlRpfGmLhNdkqiEuDFTuD1GsV3jvuPuPGKUJTam3P53U4LM
# 0UCxeDI8Qz40Qw9TPar6S02XExlc8X1YsiE6ETcTz+g1ImQ1OqFwEaxsMj/WoJT1
# 8GG5KiNnS7n/X4iMwboAg3IjpcvEzw4AZCZowHyCzYhnFRM4PuNMVHYcTXGgvuq9
# I7j4ke281x4e7/90Z5Wbk92RrLcS35hO30TABcGx3Q8+YLRy6o0k1w4jRefCMT7b
# 5mTxtq5XPmKvtgfPuaWPkGZ/tbxInyNDA7YgOgccULjp4+D56g2iuzRCsLQ9ac6A
# N4yRbqCYsG2rcIQ5INTyI2JzA2w1vsAHPRbUTeqVLDuNOY2gYIoKBWQsPYVoyzao
# BVU6O5TG+a1YyfWkgVVS9nXKs8hVti3VpOV3aeuaHnjgC6He2CCDL9aW6gteUe0A
# mC8XCtWwpePx6QW3ROZo8vSUe9AR7mMdu5+FzTmW8K13Bt8GX/YBFJO7LWzwKAUC
# AwEAAaOCAY4wggGKMB8GA1UdIwQYMBaAFF9Y7UwxeqJhQo1SgLqzYZcZojKbMB0G
# A1UdDgQWBBRo76QySWm2Ujgd6kM5LPQUap4MhTAOBgNVHQ8BAf8EBAMCBsAwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBKBgNVHSAEQzBBMDUG
# DCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29t
# L0NQUzAIBgZngQwBBAIwSgYDVR0fBEMwQTA/oD2gO4Y5aHR0cDovL2NybC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3JsMHoGCCsG
# AQUFBwEBBG4wbDBFBggrBgEFBQcwAoY5aHR0cDovL2NydC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3J0MCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAYEAsNwuyfpP
# NkyKL/bJT9XvGE8fnw7Gv/4SetmOkjK9hPPa7/Nsv5/MHuVus+aXwRFqM5Vu51qf
# rHTwnVExcP2EHKr7IR+m/Ub7PamaeWfle5x8D0x/MsysICs00xtSNVxFywCvXx55
# l6Wg3lXiPCui8N4s51mXS0Ht85fkXo3auZdo1O4lHzJLYX4RZovlVWD5EfwV6Ve1
# G9UMslnm6pI0hyR0Zr95QWG0MpNPP0u05SHjq/YkPlDee3yYOECNMqnZ+j8onoUt
# Z0oC8CkbOOk/AOoV4kp/6Ql2gEp3bNC7DOTlaCmH24DjpVgryn8FMklqEoK4Z3Io
# UgV8R9qQLg1dr6/BjghGnj2XNA8ujta2JyoxpqpvyETZCYIUjIs69YiDjzftt37r
# QVwIZsfCYv+DU5sh/StFL1x4rgNj2t8GccUfa/V3iFFW9lfIJWWsvtlC5XOOOQsw
# r1UmVdNWQem4LwrlLgcdO/YAnHqY52QwnBLiAuUnuBeshWmfEb5oieIYMIIGFDCC
# A/ygAwIBAgIQeiOu2lNplg+RyD5c9MfjPzANBgkqhkiG9w0BAQwFADBXMQswCQYD
# VQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0
# aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAw
# MFoXDTM2MDMyMTIzNTk1OVowVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3Rp
# Z28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGlu
# ZyBDQSBSMzYwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQDNmNhDQatu
# givs9jN+JjTkiYzT7yISgFQ+7yavjA6Bg+OiIjPm/N/t3nC7wYUrUlY3mFyI32t2
# o6Ft3EtxJXCc5MmZQZ8AxCbh5c6WzeJDB9qkQVa46xiYEpc81KnBkAWgsaXnLURo
# YZzksHIzzCNxtIXnb9njZholGw9djnjkTdAA83abEOHQ4ujOGIaBhPXG2NdV8TNg
# FWZ9BojlAvflxNMCOwkCnzlH4oCw5+4v1nssWeN1y4+RlaOywwRMUi54fr2vFsU5
# QPrgb6tSjvEUh1EC4M29YGy/SIYM8ZpHadmVjbi3Pl8hJiTWw9jiCKv31pcAaeij
# S9fc6R7DgyyLIGflmdQMwrNRxCulVq8ZpysiSYNi79tw5RHWZUEhnRfs/hsp/fwk
# Xsynu1jcsUX+HuG8FLa2BNheUPtOcgw+vHJcJ8HnJCrcUWhdFczf8O+pDiyGhVYX
# +bDDP3GhGS7TmKmGnbZ9N+MpEhWmbiAVPbgkqykSkzyYVr15OApZYK8CAwEAAaOC
# AVwwggFYMB8GA1UdIwQYMBaAFPZ3at0//QET/xahbIICL9AKPRQlMB0GA1UdDgQW
# BBRfWO1MMXqiYUKNUoC6s2GXGaIymzAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/
# BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAECjAIMAYGBFUd
# IAAwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0
# aWdvUHVibGljVGltZVN0YW1waW5nUm9vdFI0Ni5jcmwwfAYIKwYBBQUHAQEEcDBu
# MEcGCCsGAQUFBzAChjtodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJs
# aWNUaW1lU3RhbXBpbmdSb290UjQ2LnA3YzAjBggrBgEFBQcwAYYXaHR0cDovL29j
# c3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBABLXeyCtDjVYDJ6BHSVY
# /UwtZ3Svx2ImIfZVVGnGoUaGdltoX4hDskBMZx5NY5L6SCcwDMZhHOmbyMhyOVJD
# wm1yrKYqGDHWzpwVkFJ+996jKKAXyIIaUf5JVKjccev3w16mNIUlNTkpJEor7edV
# JZiRJVCAmWAaHcw9zP0hY3gj+fWp8MbOocI9Zn78xvm9XKGBp6rEs9sEiq/pwzvg
# 2/KjXE2yWUQIkms6+yslCRqNXPjEnBnxuUB1fm6bPAV+Tsr/Qrd+mOCJemo06ldo
# n4pJFbQd0TQVIMLv5koklInHvyaf6vATJP4DfPtKzSBPkKlOtyaFTAjD2Nu+di5h
# ErEVVaMqSVbfPzd6kNXOhYm23EWm6N2s2ZHCHVhlUgHaC4ACMRCgXjYfQEDtYEK5
# 4dUwPJXV7icz0rgCzs9VI29DwsjVZFpO4ZIVR33LwXyPDbYFkLqYmgHjR3tKVkhh
# 9qKV2WCmBuC27pIOx6TYvyqiYbntinmpOqh/QPAnhDgexKG9GX/n1PggkGi9HCap
# Zp8fRwg8RftwS21Ln61euBG0yONM6noD2XQPrFwpm3GcuqJMf0o8LLrFkSLRQNwx
# PDDkWXhW+gZswbaiie5fd/W2ygcto78XCSPfFWveUOSZ5SqK95tBO8aTHmEa4lpJ
# VD7HrTEn9jb1EGvxOb1cnn0CMIIGgjCCBGqgAwIBAgIQNsKwvXwbOuejs902y8l1
# aDANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBK
# ZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRS
# VVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlv
# biBBdXRob3JpdHkwHhcNMjEwMzIyMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjBXMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAiJ3YuUVnnR3d6LkmgZpUVMB8SQWbzFoVD9mU
# EES0QUCBdxSZqdTkdizICFNeINCSJS+lV1ipnW5ihkQyC0cRLWXUJzodqpnMRs46
# npiJPHrfLBOifjfhpdXJ2aHHsPHggGsCi7uE0awqKggE/LkYw3sqaBia67h/3awo
# qNvGqiFRJ+OTWYmUCO2GAXsePHi+/JUNAax3kpqstbl3vcTdOGhtKShvZIvjwulR
# H87rbukNyHGWX5tNK/WABKf+Gnoi4cmisS7oSimgHUI0Wn/4elNd40BFdSZ1Ewpu
# ddZ+Wr7+Dfo0lcHflm/FDDrOJ3rWqauUP8hsokDoI7D/yUVI9DAE/WK3Jl3C4LKw
# Ipn1mNzMyptRwsXKrop06m7NUNHdlTDEMovXAIDGAvYynPt5lutv8lZeI5w3MOlC
# ybAZDpK3Dy1MKo+6aEtE9vtiTMzz/o2dYfdP0KWZwZIXbYsTIlg1YIetCpi5s14q
# iXOpRsKqFKqav9R1R5vj3NgevsAsvxsAnI8Oa5s2oy25qhsoBIGo/zi6GpxFj+mO
# dh35Xn91y72J4RGOJEoqzEIbW3q0b2iPuWLA911cRxgY5SJYubvjay3nSMbBPPFs
# yl6mY4/WYucmyS9lo3l7jk27MAe145GWxK4O3m3gEFEIkv7kRmefDR7Oe2T1HxAn
# ICQvr9sCAwEAAaOCARYwggESMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKy
# A2bLMB0GA1UdDgQWBBT2d2rdP/0BE/8WoWyCAi/QCj0UJTAOBgNVHQ8BAf8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAE
# CjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1
# c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMDUG
# CCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEADr5lQe1oRLjlocXUEYfktzsljOt+2sgX
# ke3Y8UPEooU5y39rAARaAdAxUeiX1ktLJ3+lgxtoLQhn5cFb3GF2SSZRX8ptQ6Iv
# uD3wz/LNHKpQ5nX8hjsDLRhsyeIiJsms9yAWnvdYOdEMq1W61KE9JlBkB20XBee6
# JaXx4UBErc+YuoSb1SxVf7nkNtUjPfcxuFtrQdRMRi/fInV/AobE8Gw/8yBMQKKa
# Ht5eia8ybT8Y/Ffa6HAJyz9gvEOcF1VWXG8OMeM7Vy7Bs6mSIkYeYtddU1ux1dQL
# bEGur18ut97wgGwDiGinCwKPyFO7ApcmVJOtlw9FVJxw/mL1TbyBns4zOgkaXFnn
# fzg4qbSvnrwyj1NiurMp4pmAWjR+Pb/SIduPnmFzbSN/G8reZCL4fvGlvPFk4Uab
# /JVCSmj59+/mB2Gn6G/UYOy8k60mKcmaAZsEVkhOFuoj4we8CYyaR9vd9PGZKSin
# aZIkvVjbH/3nlLb0a7SBIkiRzfPfS9T+JesylbHa1LtRV9U/7m0q7Ma2CQ/t392i
# oOssXW7oKLdOmMBl14suVFBmbzrt5V5cQPnwtd3UOTpS9oCG+ZZheiIvPgkDmA8F
# zPsnfXW5qHELB43ET7HHFHeRPRYrMBKjkb8/IN7Po0d0hQoF4TeMM+zYAJzoKQnV
# KOLg8pZVPT8xggSRMIIEjQIBATBpMFUxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9T
# ZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3RpZ28gUHVibGljIFRpbWUgU3Rh
# bXBpbmcgQ0EgUjM2AhA6UmoshM5V5h1l/MwS2OmJMA0GCWCGSAFlAwQCAgUAoIIB
# +TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0
# MDczMTE5MjYxMlowPwYJKoZIhvcNAQkEMTIEMFaM2bpAPdapYlwZ7qYQJhBIKqT/
# u7Sxj1VttK8/V8fyiKpXSDLWyRuEMCpphb19aDCCAXoGCyqGSIb3DQEJEAIMMYIB
# aTCCAWUwggFhMBYEFPhgmBmm+4gs9+hSl/KhGVIaFndfMIGHBBTGrlTkeIbxfD1V
# EkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KCYXzQkDXEkd6S
# wULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJz
# ZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNU
# IE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEBBQAEggIAZG6l
# przVEES36rQHAcNKYtE0/xdOqPlg/k8XL6bRAN2VXDNqFKQ6AG1EwulMh1JLWMac
# 4t+me5pOwxxxBtVeGsuoxU/Wj8R/120tbHbYsEoqfmxxgfa+4m80hsmc4WI1hYoJ
# 10LRWcBWKkDZC3MZwNGYS7GG/XGNgtMMkc+457s8OzzrBFwP6eVJsrkNOArYGSbQ
# mWTtUUBAsh4dOSBYk2tYiHRAf/Bl8On5YbThsULQ/hR6Bh5KQer2eEPIGfKk3d7m
# gF8Dumy/EA1ire6f1lJEYZQ5Fnwdl4+0W6x5tw40KTXiuY/HNNZapggJcyja2Cru
# S0QTk346rGdMuHU78l9WMWNaH/doHFvSjuGf82gwS9YtVVMj3eu6LcchsUQOyDBY
# jI3zvoLbkP2sbKYJ8AOuB12mOi+b52632Ozulj6cXdc/Q9jB4HAsUEgVgQjIBDYQ
# f3TV9Pp6XDXXCIxSmW2w8om6VS0laVT+/uhZpWoDVaPh5MjHNAoxjqHPqRleB582
# wiDd89otbhIR3aLsTaZzaRwDhy2GFnwdbCmARQGcvv4OwPbXVnMLCq8veJqMrjAg
# NeJjMi2rYqNW4wZMsQ52uHU4quvnqFEFrov0Ibqmgaq3ZuSHxA3rd1vy8zRBe0aJ
# JegoXMngwF3Br5LLS7XSajSdjztpoVGbmS9M2vg=
# SIG # End signature block
