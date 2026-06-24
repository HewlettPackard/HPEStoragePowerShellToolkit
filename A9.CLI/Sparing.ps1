## 	©2025 Hewlett Packard Enterprise Development LP
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
	This command utilizes the SSH command 'showspare' 
	This command requires a SSH type connection.
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
		$spinner = @('|','\','-','/')
		$Current=0
		if($Result.count -lt 3)	{	write-warning "No data available"		}	
		elseif (-not $showraw -and ($Result.count -gt 3) )	
			{ 	Write-host "Spare List is Processing [ . ]" -nonewline
				foreach ($s in $Result[0..($Result.count - 3)] )
					{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
						write-host "`b`b`b$($spinner[$current%4]) ]" -nonewline
						$Current+=1
						Add-Content -Path $tempFile -Value $s
					}
				$result = Import-Csv $tempFile
			}
		remove-item $tempFile
		$NewObj = @(    foreach( $Item in $result)
                            {   $NewItem=@{PSTypeName = "HPE.A9Storage.Spare"}
                                $Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
                                $DataSetType = "HPE.A9Storage.Spare"
                                $NewItem.PSTypeNames.Insert(0,$DataSetType)
                                $DataSetType = $DataSetType + ".TypeName"
								$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
                    	        [PSCustomObject]$NewItem
            		         }
                    )
        return $NewObj
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
.PARAMETER AllowPartial
	Specifies that partial completion of the command is acceptable.
.EXAMPLE
    PS:> New-A9Spare -Pdid_chunkNumber "15:1"
	
	This example marks chunklet 1 as spare for physical disk 15
.EXAMPLE
	PS:> New-A9Spare –pos "1:0.2:3:121"
	
	This example specifies the position in a drive cage, drive magazine, physical disk,and chunklet number. –pos 1:0.2:3:121, 
	where 1 is the drive cage, 0.2 is the drive magazine, 3 is the physical disk, and 121 is the chunklet number.
.NOTES
	This command utilizes the SSH command 'createspare' 
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Pdid',mandatory)]		[String]	$Pdid_chunkNumber,
		[Parameter(ParameterSetName='POS', mandatory)]		[String]	$pos,
		[Parameter()]										[Switch]	$AllowPartial
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process	
	{	$newsparecmd = " createspare -f "
		if($AllowPartial)	
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
	Moves a list of chunklets (or a complete physical disk) from one physical disk to another or to the spare pool.
.DESCRIPTION
	Moves a list of chunklets (or a complete physical disk) from one physical disk to another or to the spare pool.
	- Chunklets moved through the movech command are only moved temporarily.
	- Issuing either the moverelocpd or servicemag resume command (see the servicemag command) can move the chunklet back to its original position.
.PARAMETER SourcePD_Id
    Specifies that the chunklet located at the specified PD. This is a required parameter.
	If this is presented with a souce chunklet posistion it will moves data from specified Physical Disks (PDs) to a temporary location selected by the system
.PARAMETER SourceChunk_Position
    Specifies that the the chunklet’s position on that disk. If this is not provided, the command will clear the entire physical disk of all chunklets to the spare pool
.PARAMETER TargetPD_Id	
	specified target destination disk. Usage of this parameter also requires the use of TagetChunk_Position
	If this is not specified, it will move the chunklet (or complete disk) to the spare pool
.PARAMETER TargetChunk_Position	
	Specify target chunklet position. Usage of this parameter also requires the use of TagetPD_Id.
	If this is not specified, it will move the chunklet or complete disk to the spare pool
.PARAMETER NoWait
	Specifies that the command returns before the operation is completed.
.PARAMETER Devtype
	Permits the moves to happen to different device types. 
.PARAMETER Permanent
	Specifies that chunklets are permanently moved and the chunklets'
	original locations are not remembered.
	Only valid when the destination is specified using the Tarrget locations
.PARAMETER Overide
	Permits the moves to happen to a destination even when there will be a loss of quality because of the move. 
	Only valid for a movement to Spare pool
.PARAMETER PhysicalDeviceToSpare
	This switch will force powershell to allow the use parameters compatible with the goal of allocating specified Chunklets on the drive to the spare pool.
.PARAMETER ClearPhysicalDevice
	This switch will force powershell to allow the use parameters compatible with the goal of clearing all used chunklets on a physical device to alternate locations in the array.
.PARAMETER ChunkletToSpare,
	This switch will force powershell to allow the use parameters compatible with the goal of moving Chunklets to the spare pool.
.PARAMETER RelocateChunklet
	This switch will force powershell to allow the use parameters compatible with the goal of moving Chunklets from one physical location to another physical location.
.EXAMPLE
    PS:> Move-A9Chunklet -SourcePD_Id 24 -SourceChunk_Position 0  -TargetPD_Id 64 -TargetChunk_Position 50 

	This example moves the chunklet in position 0 on disk 24, to position 50 on disk 64 and chunklet in position 0 on disk 25, to position 1 on disk 27
.EXAMPLE	
	PS:> Move-A9ChunkletToSpare -SourcePD_Id 3 -SourceChunk_Position 0

	Since no TargetPD is specified, the device will move this chunklet to the spare pool
.NOTES
	This command utilizes the SSH command 'movech' ,'movechtospare', 'movepd', 'movepdtospare'
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='ClearPD')]
param(
		[Parameter(mandatory,parametersetname='ClearPD')]
		[Parameter(mandatory,parametersetname='targ')]
		[Parameter(mandatory,parametersetname='ToSpare')]
		[Parameter(mandatory,parametersetname='PDToSparePerm')]
		[Parameter(mandatory,parametersetname='PDToSpareOvrd')]	[String]	$SourcePD_Id,
		[Parameter(mandatory,parametersetname='targ')]
		[Parameter(mandatory,parametersetname='ToSpare')]		[String]	$SourceChunk_Position,	
		[Parameter(mandatory,parametersetname='targ')]			[String]	$TargetPD_Id,
		[Parameter(mandatory,parametersetname='targ')]			[String]	$TargetChunk_Position,
		[Parameter(parametersetname='PDToSparePerm')]
		[Parameter(parametersetname='targ')]					[Switch]	$Permanent,
		[Parameter(parametersetname='PDToSpareOvrd')]
		[Parameter(parametersetname='targ')]					[Switch]	$Overide,
		[Parameter(parametersetname='PDToSparePerm')]
		[Parameter(parametersetname='PDToSpareOvrd')]
		[Parameter(parametersetname='ClearPD')]
		[Parameter(parametersetname='ToSpare')]					[Switch]	$nowait,
		[Parameter(parametersetname='PDToSparePerm')]
		[Parameter(parametersetname='PDToSpareOvrd')]
		[Parameter(parametersetname='ClearPD')]
		[Parameter(parametersetname='ToSpare')]					[Switch]	$Devtype,
		[Parameter(parametersetname='PDToSparePerm')]			[switch]	$PhysicalDeviceToSpare,
		[Parameter(parametersetname='ClearPD')]					[switch]	$ClearPhysicalDevice,
		[Parameter(parametersetname='PDToSpareOvrd')]			[switch]	$ChunkletToSpare,
		[Parameter(parametersetname='ToSpare')]					[switch]	$RelocateChunklet
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	switch -Wildcard ($PSCmdlet.ParameterSetName)
		{	'targ'		{	$cmd = "movech -f "
							elseif($Perm)	{	$cmd += " -perm "	}
							if($NoWait)		{	$cmd += " -nowait "	}
							if($Devtype)	{	$cmd += " -devtype "}
							if($Overide)	{	$cmd += " -ovrd "	}
							$cmd += $SourcePD_Id+":"+$SourceChunk_Position
							if(($TargetPD_Id) -and ($TargetChunk_Position))	
								{	$cmd += "-"+$TargetPD_Id+":"+$TargetChunk_Position	
								}
						}
			'ToSpare'	{	$cmd = "movechtospare -f "
							if($NoWait)		{	$cmd += " -nowait "		}
							if($Devtype)	{	$cmd += " -devtype "	}
							$cmd += $SourcePD_Id+":"+$SourceChunk_Position
						}
			'ClearPD'	{	$cmd = "movepd -f"
							if($NoWait)	{	$cmd += " -nowait "		}
							if($Devtype){	$cmd += " -devtype "	}
							$cmd += " $SourcePD_Id"
						}
			"PDToSpar*"	{	$cmd = "movepdtospare -f"	
							if($NoWait)		{	$cmd += " -nowait "		}
							if($DevType)	{	$cmd += " -devtype "	}
							if($Permanent)	{	$cmd += " -perm "		}
							if($Overide)	{	$cmd += " -ovrd "		}
							if($SourcePD_Id){	$cmd += " $SourcePD_Id"		}
						}
		}
	write-verbose "move chunklet cmd -> $cmd "	
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	if([string]::IsNullOrEmpty($Result))	
		{	write-warning "FAILURE : Disk $SourcePD_Id chunklet $SourceChunk_Position is not in use. "
			return 	
		}
	if($Result -match "Move" -or $Result -match "-Detailed_State-" )
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
			$DataPS = $returnresult
		}
	else{	$DataPS = $Result	
		}
	$DataPS = $DataPS | convertto-json | ConvertTo-Json
	return $DataPS
}
}

Function Restore-A9RelocatedChunklets 
{
<#
.SYNOPSIS
	Command moves chunklets that were on a physical disk to the target of relocation.
.DESCRIPTION
	Command moves chunklets that were on a physical disk to the target of relocation.
.PARAMETER diskID    
	Specifies that the chunklets that were relocated from specified disk (<fd>), are moved to the specified destination disk (<td>). If destination disk (<td>) is not specified then the chunklets are moved back
    to original disk (<fd>). The <fd> specifier is not needed if -p option is used, otherwise it must be used at least once on the command line. If this specifier is repeated then the operation is performed on multiple disks.
.PARAMETER NoWait
	Specifies that the command returns before the operation is completed.
.PARAMETER AllowPartial
    Move as many chunklets as possible. If this option is not specified, the command fails if not all specified chunklets can be moved.
.EXAMPLE
    PS:>  Restore-A9RelocatedChunklets -diskID 8 

	moves chunklets that were on physical disk 8 that were relocated to another position, back to physical disk 8
.NOTES
	This command utilizes the SSH command 'moverelocpd'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(mandatory)]	[String]	$diskID,
		[Parameter()]			[Switch]	$NoWait,
		[Parameter()]			[Switch]	$AllowPartial
	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{	if ( -not $(Test-A9CLI) ) 	{	return }
	$cmd = "moverelocpd -f "
	if($nowait)		{	$movechcmd += " -nowait "	}
	if($AllowPartial){	$movechcmd += " -partial "	}
	$movechcmd += " $diskID"	
	write-verbose "move relocation pd cmd is => $cmd " 
	$Result = Invoke-A9CLICommand -cmds  $cmd
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
			$DataPS = Import-Csv $tempFile
			remove-item $tempFile
		}
	else	
		{	$DataPS = $Result	
		}
	$DataPS = $DataPS | Convertto-json | COnvertFrom-json
	$NewObj = @(    foreach( $Item in $dataPS)	
						{   $NewItem=@{PSTypeName = "HPE.A9Storage.Sparing"}
							$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
							$DataSetType = "HPE.A9Storage.Sparing"
							$NewItem.PSTypeNames.Insert(0,$DataSetType)
							$DataSetType = $DataSetType + ".TypeName"
							$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
							[PSCustomObject]$NewItem
						}
				)
	return $NewObj
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
.PARAMETER AllowPartial
	Specifies that partial completion of the command is acceptable.
.EXAMPLE
    PS:> Remove-A9Spare_CLI -Pdid_chunkNumber "1:3"
	
	Example removes a spare chunklet from position 3 on physical disk 1:
.EXAMPLE
	PS:> Remove-A9Spare –pos "1:0.2:3:121"
	
	Example removes a spare chuklet from  the position in a drive cage, drive magazine, physical disk,and chunklet number. –pos 1:0.2:3:121, where 1 is the drive cage, 0.2 is the drive magazine, 3 is the physical disk, and 121 is the chunklet number. 	
.NOTES
	This command utilizes the SSH command 'removespare'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='pdid', mandatory)]		[String]	$Pdid_chunkNumber,	
		[Parameter(parametersetname='pos',  mandatory)]		[String]	$Position,
		[Parameter()]										[Switch]	$AllowPartial	
	)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process	
	{ 	$newsparecmd = "removespare -f "
		if($AllowPartial)		{ 	$newsparecmd += " -p "				}
		if($Pdid_chunkNumber)	{	$newsparecmd += " $Pdid_chunkNumber"}
		if($position)			{	$newsparecmd += " -pos $position"		}
		$Result = Invoke-A9CLICommand -cmds  $newsparecmd
	}
end	{	if($Result -match "removed")	{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green	}
		return $Result
	}
}
