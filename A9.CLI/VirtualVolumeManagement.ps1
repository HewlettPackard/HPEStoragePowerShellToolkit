## 	©2025 Hewlett Packard Enterprise Development LP

Function Add-A9Vv
{
<#
.SYNOPSIS
	The command creates and admits remotely exported virtual volume definitions to enable the migration of these volumes. The newly created
	volume will have the WWN of the underlying remote volume.
.DESCRIPTION
	The command creates and admits remotely exported virtual volume definitions to enable the migration of these volumes. The newly created
	volume will have the WWN of the underlying remote volume.
.PARAMETER DomainName
	Create the admitted volume in the specified domain   
.PARAMETER VV_WWN
	Specifies the World Wide Name (WWN) of the remote volumes to be admitted.
.PARAMETER VV_WWN_NewWWN 
	Specifies the World Wide Name (WWN) for the local copy of the remote volume. If the keyword "auto" is specified the system automatically generates a WWN for the virtual volume
.EXAMPLE
	PS:> Add-Vv -VV_WWN  migvv.0:50002AC00037001A

	Specifies the local name that should be given to the volume being admitted and Specifies the World Wide Name (WWN) of the remote volumes to be admitted.
.EXAMPLE
	PS:> Add-A9Vv -VV_WWN  "migvv.0:50002AC00037001A migvv.1:50002AC00047001A"
.EXAMPLE
	PS:> Add-A9Vv -DomainName XYZ -VV_WWN X:Y

	Create the admitted volume in the specified domain. The default is to create it in the current domain, or no domain if the current domain is not set.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName="wwn")]							
		[Parameter(ParameterSetName="wwn")]				[String]	$DomainName ,
		[Parameter(Mandatory, ParameterSetName="WWN")]	[String]	$VV_WWN ,
		[Parameter(Mandatory, ParameterSetName="New")]	[String] 	$VV_WWN_NewWWN
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
process	
{	$cmd = "admitvv"
	if($DomainName)		{	$Cmd+= " -domain $DomainName"	}		
	if($VV_WWN)			{	$cmd += " $VV_WWN"				}
	if($VV_WWN_NewWWN)	{	$cmd += " $VV_WWN_NewWWN"		}	
	$Result = Invoke-A9CLICommand -cmds  $cmd
	return  $Result	
} 
}

Function Compress-A9LogicalDisk
{
<#
.SYNOPSIS
	Consolidate space in logical disks (LD).
.DESCRIPTION
	The command consolidates space on the LDs.
.PARAMETER Consolidate
	This option consolidates regions into the fewest possible LDs. When this option is not specified, the regions of each LD will be compacted within the same LD.
.PARAMETER Taskname
	Specifies a name for the task. When not specified, a default name is chosen.
.PARAMETER Trimonly
	Only unused LD space is removed. Regions are not moved.
.PARAMETER LD_Name
	Specifies the name of the LD to be compacted. Multiple LDs can be specified.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter(ParameterSetName='con',mandatory)]		[switch]	$Consolidate,
		[Parameter()]										[String]	$Taskname,
		[Parameter(parametersetname='trim',mandatory)]		[switch]	$Trimonly,
		[Parameter(Mandatory)]								[String]	$LD_Name
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
PROCESS
{	$Cmd = " compactld -f "
	if($Taskname)	{	$Cmd += " -taskname $Taskname " }					
	switch($PSCmdlet.ParameterSetName)
		{	'con'	{	$Cmd += " -cons " 		}
			'trim'	{	$Cmd += " -trimonly " 	}
		}
	$Cmd += " $LD_Name "
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Confirm-A9LogicalDisk
{
<#
.SYNOPSIS
	Perform validity checks of data on logical disks (LD).
.DESCRIPTION
	The command executes consistency checks of data on Logical Disks in the event of an uncontrolled 
	system shutdown and optionally repairs inconsistent Logical Disks.
.PARAMETER FixError
	Specifies that if errors are found they are fixed instead of the default behaviour which is to only report.
.PARAMETER Progress
	Poll the system manager to get ldck report.
.PARAMETER Recover
	Attempt to recover the chunklet specified by giving physical disk (<pdid>) and the chunklet's position on 
	that disk (<pdch>). The format will look like PhysicalDiskID:PhysicalDiskChunklet i.e. 1032:10
.PARAMETER RAIDSet
	Check only the specified RAID set. You must supply the RAID set number
.PARAMETER LD_Name
	Requests that the integrity of a specified LD is checked.
.NOTES
	Usage:
	- Using the -recover option allows one LD only
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(
	[Parameter(mandatory,parameterset='fix')]		[switch]	$FixError,
	[Parameter(mandatory,parameterset='report')]	[switch]	$Progress,
	[Parameter(mandatory,parameterset='recover')]	[String]	$Recover,
	[Parameter()]						[String]	$RAIDSet,
	[Parameter(Mandatory)]				[String]	$LD_Name
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
PROCESS
	{	$Cmd = " checkld "
		if($FixError) 		{	$Cmd += " -y " }
		else				{	$Cmd += " -n " }
		if($Progress)		{	$Cmd += " -progress " }
		if($Recover)		{	$Cmd += " -y -recover $Recover " }
		if($RAIDSet)		{	$Cmd += " -rs $Rs " }
		if($LD_Name)		{	$Cmd += " $LD_Name "}
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Get-A9LogicalDisk
{
<#
.SYNOPSIS
	Show information about logical disks (LDs) in the system.
.DESCRIPTION
	The Get-LD command displays configuration information about the system's LDs.
.PARAMETER Cpg
	Requests that only LDs in common provisioning groups (CPGs) that match the specified CPG names or patterns be displayed. Multiple CPG names or
	patterns can be repeated using a comma-separated list .
.PARAMETER Vv	
	Requests that only LDs mapped to virtual volumes that match and of the specified names or patterns be displayed. Multiple volume names or
	patterns can be repeated using a comma-separated list .
.PARAMETER Degraded
	Only shows LDs with degraded availability.
.PARAMETER Detailed
	Requests that more detailed layout information is displayed.
.PARAMETER CheckLD
	Requests that checkld information is displayed.
.PARAMETER Policy
	Requests that policy information about the LD is displayed.
.PARAMETER State
	Requests that the detailed state information is displayed.	This is the same as s.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object.  
.EXAMPLE
	PS:> Get-A9LogicalDisk

	id   Name               RAID Detailed_State Own   SizeMB   UsedMB   Use    WThru MapV
	--   ----               ---- -------------- ---   ------   ------   ---    ----- ----
	3    .mgmtdata.usr.0    1    normal       1/0   259072   259072   V      Y     Y
	0    admin.usr.0        1    normal       0/1   10240    10240    V      Y     Y
	6    tp-0-sa-0.0        1    normal       0/1   16384    11264    C,SA   Y     Y
	8    tp-0-sa-0.1        1    normal       1/0   5120     5120     C,SA   Y     Y
.EXAMPLE
	PS:> Get-A9LogicalDisk -Cpg SSD_r6

	id   Name               RAID Detailed_State Own   SizeMB   UsedMB   Use    WThru MapV
	--   ----               ---- -------------- ---   ------   ------   ---    ----- ----
	6    tp-0-sa-0.0        1                 0/1   16384    11264    C,SA   Y     Y
	10   tp-0-sa-0.2        1                 1/0   12288    7168     C,SA   Y     Y
	14   tp-0-sa-0.5        1                 1/0   5120     5120     C,SD   Y     Y
.EXAMPLE
	PS:> Get-A9LogicalDisk -Vv AzureLocalPool2

	id   Name               RAID Detailed_State Own   SizeMB   UsedMB   Use    WThru MapV
	--   ----               ---- -------------- ---   ------   ------   ---    ----- ----
	138  tp-0-sa-0.62       1    normal       0/1   12288    8192     C,SA   Y     Y
	372  tp-0-sd-0.209      6    normal       0/1   245700   188475   C,SD   Y     Y
.EXAMPLE
	PS:> Get-A9LogicalDisk -CheckLD

	id   Name               Detailed_State   Total    Checked  Invalid  Last_Date_Checked
	--   ----               --------------   -----    -------  -------  -----------------
	3    .mgmtdata.usr.0    normal           253      253      0        2025-01-06
	1    .srdata.usr.0      normal           84       84       0        2025-01-06
	0    admin.usr.0        normal           10       10       0        2025-01-06
	6    tp-0-sa-0.0        normal           16       16       0        2025-01-06
.EXAMPLE
	PS:> Get-A9LogicalDisk -Detailed 

	id   Name               CPG        RAID Own   SizeMB   RSizeMB    RowSz StepKB     SetSz  Refcnt Avail  CAvail   CreationDate     Dev_Type
	--   ----               ---        ---- ---   ------   -------    ----- ------     -----  ------ -----  ------   ------------     --------
	4    .mgmtdata.usr.1    ---        1    1/0   117760   353280     23    256        3      0      cage   cage     2024-03-28       SSD
	5    .mgmtdata.usr.2    ---        1    1/0   147456   442368     24    256        3      0      cage   cage     2024-03-28       SSD
	1    .srdata.usr.0      ---        1    1/0   86016    258048     21    256        3      0      cage   cage     2024-03-28       SSD
	2    .srdata.usr.1      ---        1    1/0   67584    202752     22    256        3      0      cage   cage     2024-03-28       SSD
	0    admin.usr.0        ---        1    0/1   10240    30720      10    256        3      0      cage   cage     2024-03-28       SSD
	6    tp-0-sa-0.0        SSD_r6     1    0/1   16384    49152      4     256        3      0      cage   cage     2024-07-10       SSD
	8    tp-0-sa-0.1        SSD_r6     1    1/0   5120     15360      5     256        3      0      cage   cage     2024-07-10       SSD
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Cpg,
		[Parameter()]	[String]	$Vv,
		[Parameter()]	[switch]	$Degraded,
		[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[switch]	$CheckLD,
		[Parameter()]	[switch]	$Policy,
		[Parameter()]	[switch]	$State,
		[Parameter()]	[String]	$LD_Name,
		[Parameter()]	[switch]	$ShowRaw
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process
	{	$Cmd = " showld "
		if($Cpg)	{	$Cmd += " -cpg $Cpg "}
		if($Vv)		{	$Cmd += " -vv $Vv "}
		if($Domain)	{	$Cmd += " -domain $Domain "}
		if($Degraded){	$Cmd += " -degraded " }
		if($Detailed){	$Cmd += " -d " }
		if($CheckLD){	$Cmd += " -ck " }
		if($Policy)	{	$Cmd += " -p "	}
		if($LD_Name){ 	$Cmd += " $LD_Name " }
		$Result = Invoke-A9CLICommand -cmds  $Cmd
	}
end
	{	if($ShowRaw -or $Policy) {	Return $Result }
		if($Result.count -gt 1)
			{	if ( $Cpg )	
					{	#	Need to split the dataset into two collections
						$EndOfFirstDataSet = ($Result | Select-String 'total').linenumber[0]
						$Result1 = $Result[0..$EndOfFirstDataSet]	
						$Result2 = $Result[($EndOfFirstDataSet+1)..($Result.count-1)]
						$tempFile = [IO.Path]::GetTempFileName()
						$ResultHeader = (($Result1[1].split(' ')).trim() | where-object { $_ -ne '' } ) -join 'Z'
						Add-Content -Path $tempfile -Value $ResultHeader				
						foreach ($S in  $Result1[2..($Result1.Count - 4)] )
								{	$s = (($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join 'Z'
									Add-Content -Path $tempfile -Value $s				
								}
						$Result1 = Import-Csv -Delimiter 'Z'  $tempFile 
						Remove-Item $tempFile
						$tempFile = [IO.Path]::GetTempFileName()
						Add-Content -Path $tempfile -Value $ResultHeader				
						foreach ($S in  $Result2[2..($Result2.Count - 4)] )
								{	$s = (($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join 'Z'
									Add-Content -Path $tempfile -Value $s				
								}
						$Result2 = Import-Csv -Delimiter 'Z'  $tempFile 
						Remove-Item $tempFile
						$ResultFinal = $( @{LDForSA = $Result1}, @{LDforSD = $Result2} )
						# Now to rejoin the datasets.
						$NewObj = @(    foreach( $Item in ($ResultFinal).LDforSA)	
																{   $NewItem=@{PSTypeName = "HPE.A9Storage.LogicalDisk"}
																	$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
																	$DataSetType = "HPE.A9Storage.LogicalDisk"
																	$NewItem.PSTypeNames.Insert(0,$DataSetType)
																	$DataSetType = $DataSetType + ".TypeName"
																	$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
																	[PSCustomObject]$NewItem
																}
										foreach( $Item in ($ResultFinal).LDforSD)	
																{   $NewItem=@{PSTypeName = "HPE.A9Storage.LogicalDisk"}
																	$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
																	$DataSetType = "HPE.A9Storage.LogicalDisk"
																	$NewItem.PSTypeNames.Insert(0,$DataSetType)
																	$DataSetType = $DataSetType + ".TypeName"
																	$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
																	[PSCustomObject]$NewItem
																}
								)
						return $NewObj
					}
				if($Detailed)
					{	$tempFile = [IO.Path]::GetTempFileName()
						$ResultHeader = 'IdZNameZCPGZRAIDZOwnZSizeMBZRSizeMBZRowSzZStepKBZSetSzZRefcntZAvailZCAvailZCreationDateZCreationTimeZCreationzoneZDev_Type'
						Add-Content -Path $tempfile -Value $ResultHeader				
						foreach ($S in  $Result[1..($Result.Count - 3)] )
							{	$s = (($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join 'Z'
								Add-Content -Path $tempfile -Value $s				
							}
						$Result = Import-Csv -Delimiter 'Z'  $tempFile 
						Remove-Item $tempFile
						$NewObj = @(    foreach( $Item in $Result)	
																{   $NewItem=@{PSTypeName = "HPE.A9Storage.LogicalDiskDetailed"}
																	$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
																	$DataSetType = "HPE.A9Storage.LogicalDiskDetailed"
																	$NewItem.PSTypeNames.Insert(0,$DataSetType)
																	$DataSetType = $DataSetType + ".TypeName"
																	$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
																	[PSCustomObject]$NewItem
																}
								)
						return $NewObj
					}	
				if($CheckLD)
					{	$tempFile = [IO.Path]::GetTempFileName()
						$ResultHeader = 'Id,Name,Detailed_State,Total,Checked,Invalid,Last_Date_Checked,Last_Time_Checked,Last_TimeZone_Checked'
						Add-Content -Path $tempfile -Value $ResultHeader				
						foreach ($S in  $Result[1..($Result.Count - 3)] )
							{	$s = (($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
								Add-Content -Path $tempfile -Value $s				
							}
						$Result = Import-Csv  $tempFile 
						Remove-Item $tempFile
						$NewObj = @(    foreach( $Item in $Result)	
																{   $NewItem=@{PSTypeName = "HPE.A9Storage.LogicalDiskCheckLD"}
																	$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
																	$DataSetType = "HPE.A9Storage.LogicalDiskCheckLD"
																	$NewItem.PSTypeNames.Insert(0,$DataSetType)
																	$DataSetType = $DataSetType + ".TypeName"
																	$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
																	[PSCustomObject]$NewItem
																}
								)
						return $NewObj
					}	
				else
					{	$tempFile = [IO.Path]::GetTempFileName()
						$ResultHeader = ((($Result[0].split(' ')).trim()).trim('-') | where-object { $_ -ne '' } ) -join 'Z'
						Add-Content -Path $tempfile -Value $ResultHeader				
						foreach ($S in  $Result[1..($Result.Count - 3)] )
							{	$s = (($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join 'Z'
								Add-Content -Path $tempfile -Value $s				
							}
						$Result = Import-Csv -Delimiter 'Z'  $tempFile 
						Remove-Item $tempFile
						$NewObj = @(    foreach( $Item in $Result)	
																{   $NewItem=@{PSTypeName = "HPE.A9Storage.LogicalDisk"}
																	$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
																	$DataSetType = "HPE.A9Storage.LogicalDisk"
																	$NewItem.PSTypeNames.Insert(0,$DataSetType)
																	$DataSetType = $DataSetType + ".TypeName"
																	$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
																	[PSCustomObject]$NewItem
																}
								)
						return $NewObj
					}
			}
		Return  $Result
	}
} 

Function Get-A9LogicalDiskChunklet
{
<#
.SYNOPSIS
	Show chunklet mapping for a logical disk.
.DESCRIPTION
	The command displays configuration information about the chunklet mapping for one logical disk (LD).
.PARAMETER Degraded
	Shows only the chunklets in sets that cause the logical disk availability to be degraded. For example, if the logical disk normally
	has cage level availability, but one set has two chunklets in the same cage, then the chunklets in that set are shown. This option cannot be
	specified with option -lformat or -linfo.
.PARAMETER Lformat
	Shows the logical disk's row and set layout on the physical disk, where	the line format <form> is one of:
	row - One line per logical disk row.
	set - One line per logical disk set.
.PARAMETER Linfo
	Specifies the information shown for each logical disk chunklet, where <info> can be one of:		
		pdpos - Shows the physical disk position (default).		
		pdid  - Shows the physical disk ID.
		pdch  - Shows the physical disk chunklet.
	If multiple <info> fields are specified, each corresponding field will be shown separately by a dash (-).
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object.  
.Example
	PS:> Get-A9LogicalDiskChunklet -LD_Name 'log0.0'  | format-table

	Ldch Row Set PdPos Pdid Pdch State  Usage Media Sp From To
	---- --- --- ----- ---- ---- -----  ----- ----- -- ---- --
	0    0   0   0:6:0 6    3467 normal ld    valid N  ---  ---
	1    0   0   0:7:0 7    3467 normal ld    valid N  ---  ---
	2    0   0   0:2:0 2    3466 normal ld    valid N  ---  ---
	3    0   1   0:4:0 4    3466 normal ld    valid N  ---  ---
	4    0   1   0:0:0 0    3466 normal ld    valid N  ---  ---
	5    0   1   0:3:0 3    3466 normal ld    valid N  ---  ---
	6    1   0   0:5:0 5    3466 normal ld    valid N  ---  ---
	7    1   0   0:1:0 1    3466 normal ld    valid N  ---  ---
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]										[switch]	$Degraded,
		[Parameter()][ValidateSet('row','set')]				[String]	$Lformat,
		[Parameter()][ValidateSet('pdpos','pdid','pdch')]	[String]	$Linfo,
		[Parameter()]										[String]	$LD_Name,
		[Parameter()]										[Switch]	$ShowRaw
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process
	{	$Cmd = " showldch "
		if($Degraded)	{	$Cmd += " -degraded " }
		if($Lformat)	{	$Cmd += " -lformat $Lformat " }
		if($Linfo)		{	$Cmd += " -linfo $Linfo " }
		if($LD_Name)	{	$Cmd += " $LD_Name " }
		write-host "Command to be sent via CLI;`n`t $Cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
	}
end
	{	if($Result.count -gt 1 -and -not $ShowRaw)
			{	$tempFile = [IO.Path]::GetTempFileName()
				$LastItem = $Result.Count - 3 
				$FristCount = 0
				if($Lformat -Or $Linfo)	{	$FristCount = 1	}
				foreach ($S in  $Result[$FristCount..$LastItem] )
					{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','					
						Add-Content -Path $tempfile -Value $s				
					}
				$Result = Import-Csv $tempFile 
				Remove-Item $tempFile	
			}
		Return $Result 
	}
}

Function Import-A9Vv
{
<#
.SYNOPSIS
	The Import Vv command starts migrating the data from a remote LUN to the local Storage System. The remote LUN should have been prepared using the admitvv command.
.DESCRIPTION  
	The Import Vv command starts migrating the data from a remote LUN to the local Storage System. The remote LUN should have been prepared using the admitvv command.
.PARAMETER NoCons
	Any VV sets specified will not be imported as consistent groups. Allows multiple VV sets to be specified.
	If the VV set contains any VV members that in a previous import attempt were imported consistently, they will continue to get imported consistently.
.PARAMETER Priority 
	Specifies the priority of migration of a volume or a volume set. If this option is not specified, the default priority will be medium.
	The volumes with priority set to high will migrate faster than other volumes with medium and low priority.
.PARAMETER Job_ID
	Specifies the Job ID up to 511 characters for the volume. The Job ID will be tagged in the events that are posted during volume migration.
	Use -jobid "" to remove the Job ID.
.PARAMETER NoTask
	Performs import related pre-processing which results in transitioning the volume to exclusive state and setting up of the "consistent" flag
	on the volume if importing consistently. The import task will not be created, and hence volume migration will not happen. The "importvv"
	command should be rerun on the volume at a later point of time without specifying the -notask option to initiate the actual migration of the
	volume. With the -notask option, other options namely -tpvv, -dedup, -compr, -snp_cpg, -snap, -clrsrc, -jobid and -pri cannot be specified.
.PARAMETER Cleanup
	Performs cleanup on source array after successful migration of the volume. As part of the cleanup, any exports of the source volume will be
	removed, the source volume will be removed from all of the VV sets it is member of, the VV sets will be removed if the source volume is their
	only member, all of the snapshots of source volume will be removed, and finally the source volume itself will be removed. The -clrsrc
	option is valid only when the source array is running HPE 3PAR OS release 3.2.2 or higher. The cleanup will not be performed if the source volume
	has any snapshots that have VLUN exports.
.PARAMETER TpVV
	Import the VV into a thinly provisioned space in the CPG specified in the command line. The import will enable zero detect for the duration
	of import so that the data blocks containing zero do not occupy space on the new array.
.PARAMETER TdVV
	This option is deprecated, see -dedup.
.PARAMETER DeDup
	Import the VV into a thinly provisioned space in the CPG specified in the command line. This volume will share logical disk space with other
	instances of this volume type created from the same CPG to store identical data blocks for space saving.
.PARAMETER Compr
	Import the VV into a compressed virtual volume in the CPG specified in the command line.
.PARAMETER MinAlloc
	This option specifies the default allocation size (in MB) to be set for TPVVs and TDVVs.
.PARAMETER Snapname
	Create a snapshot of the volume at the end of the import phase
.PARAMETER Snp_cpg
	Specifies the name of the CPG from which the snapshot space will be allocated.
.PARAMETER Usrcpg
	Specifies the name of the CPG from which the volume user space will be allocated.
.PARAMETER VVName
	Specifies the VVs with the specified name 
.EXAMPLE
	PS:> Import-A9Vv -Usrcpg asCpg
.EXAMPLE
	PS:> Import-A9Vv -Usrcpg asCpg -VVName as4
.EXAMPLE
	PS:> Import-A9Vv -Usrcpg asCpg -Snapname asTest -VVName as4
.EXAMPLE
	PS:> Import-A9Vv -Usrcpg asCpg -Snp_cpg asCpg -VVName as4
.EXAMPLE
	PS:> Import-A9Vv -Usrcpg asCpg -Priority high -VVName as4
.EXAMPLE
	PS:> Import-A9Vv -Usrcpg asCpg -NoTask -VVName as4
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$Usrcpg ,
		[Parameter()]	[String]	$Snapname ,		
		[Parameter()]	[String]	$Snp_cpg ,		
		[Parameter()]	[switch]	$NoCons ,
		[Parameter()]	[ValidateSet('high','med','low')]
						[String]	$Priority ,
		[Parameter()]	[String]	$Job_ID ,		
		[Parameter()]	[switch]	$NoTask ,		
		[Parameter()]	[switch]	$Cleanup ,
		[Parameter()]	[switch]	$TpVV ,
		[Parameter()]	[switch]	$TdVV ,
		[Parameter()]	[switch]	$DeDup ,
		[Parameter()]	[switch]	$Compr ,
		[Parameter()]	[String]	$MinAlloc ,
		[Parameter()]	[String]	$VVName 
	)		
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process	
	{	$Cmd = "importvv -f"			
		if($Snapname)	{	$Cmd+= " -snap $Snapname"	}
		if($Snp_cpg)	{	$Cmd+= " -snp_cpg $Snp_cpg"	}
		if($NoCons)		{	$Cmd+= " -nocons "	}
		if($Priority)	{	$Cmd+= " -pri $Priority"	}
		if ($Job_ID)	{	$Cmd+= " -jobid $Job_ID"}
		if($NoTask)		{	$Cmd+= " -notask "}
		if($Cleanup)	{	$Cmd+= " -clrsrc "	}
		if($TpVV)		{	$Cmd+= " -tpvv "	}
		if($TdVV)		{	$Cmd+= " -tdvv "	}
		if($DeDup)		{	$Cmd+= " -dedup "	}
		if($Compr)		{	$Cmd+= " -compr "	}
		if($MinAlloc)	{	$Cmd+= " -minalloc $MinAlloc"	}
		if($Usrcpg)		{	$Cmd += " $Usrcpg "	}
		if($VVName)		{	$Cmd += " $VVName"	}	
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		return  $Result
	}
} 


Function Remove-A9LogicalDisk
{
<#
.SYNOPSIS
	Remove-LD - Remove logical disks (LD).
.DESCRIPTION
	The Remove-LD command removes a specified LD from the system service group.
.PARAMETER Pat
	Specifies glob-style patterns. All LDs matching the specified pattern are removed. By default, confirmation is required to proceed
	with the command unless the -f option is specified. This option must be	used if the pattern specifier is used.
.PARAMETER DryRun
	Specifies that the operation is a dry run and no LDs are removed.
.PARAMETER LD_Name
	Specifies the LD name, using up to 31 characters. Multiple LDs can be specified.
.PARAMETER Rmsys
	Specifies that system resource LDs such as logging LDs and preserved data LDs are removed.
.PARAMETER Unused
	Specifies the command to remove non-system LDs. This option cannot be used with the  -rmsys option.
.EXAMPLE
	PS:> Remove-A9LogicalDisk -LD_Name xxx
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Pat,
		[Parameter()]	[switch]	$DryRun,
		[Parameter()]	[switch]	$Rmsys,
		[Parameter()]	[switch]	$Unused,
		[Parameter(Mandatory)][String]	$LD_Name
		)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " removeld -f "
	if($Pat) 	{	$Cmd += " -pat " }
	if($DryRun) {	$Cmd += " -dr " }
	if($Rmsys) 	{	$Cmd += " -rmsys " }
	if($Unused) {	$Cmd += " -unused " }
	if($LD_Name){	$Cmd += " $LD_Name " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Remove-A9VvLogicalDiskCpgTemplates
{
<#
.SYNOPSIS
	Remove-Vv_Ld_Cpg_Templates - Remove one or more templates from the system
.DESCRIPTION
	The Remove-Vv_Ld_Cpg_Templates command removes one or more virtual volume (VV), logical disk (LD), and common provisioning group (CPG) templates.
.PARAMETER Template_Name
	Specifies the name of the template to be deleted, using up to 31 characters. This specifier can be repeated to remove multiple templates
.PARAMETER Pattern
	The specified patterns are treated as glob-style patterns and that all templates matching the specified pattern are removed. By default,
	confirmation is required to proceed with the command unless the -f option is specified. This option must be used if the pattern specifier is used.
.EXAMPLE
	PS:> Remove-A9Vv_Ld_Cpg_Templates_CLI -Template_Name xxx
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Template_Name,
		[Parameter()]	[switch]	$Pattern
)
Begin
{	Test-A9Connection -Clienttype 'SshClient'
}
process
{	$Cmd = " removetemplate -f "
	if($Pattern)	{	$Cmd += " -pat "	}
	if($Template_Name)	{	$Cmd += " $Template_Name "	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}


Function Set-A9VvSpace_CLI
{
<#
.SYNOPSIS
	Free SA and SD space from a VV if they are not in use.
.DESCRIPTION
	The command frees snapshot administration and snapshot data spaces from a Virtual Volume (VV) if they are not in use.
.PARAMETER VolumeName
	Specifies the Volume name.
.EXAMPLE
	PS:> Set-A9VvSpace_CLI -VolumeName xxx
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$VolumeName
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " freespace -f $VolumeName "
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Show-A9LdMappingToVvs_CLI
{
<#
.SYNOPSIS
	Show mapping from a logical disk to virtual volumes.
.DESCRIPTION
	The command displays the mapping from a logical (LD) disk to virtual volumes (VVs).
.PARAMETER LD_Name
	Specifies the logical disk name. To obtain a list of valid logical disks, issue the Get-A9LogicalDisk
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	The following example displays the region of logical disk v0.usr.0 that is used for a virtual volume: 
	
	PS:> Show-A9LdMappingToVvs_CLI -LD_Name v0.usr.0
.EXAMPLE
	PS:> Show-A9LdMappingToVvs_CLI -LD_Name tp-0-sd-0.230 | format-table

	Area Start(MB) Length(MB) VVId Name                                        VVSp VVOff(MB)
	---- --------- ---------- ---- ----                                        ---- ---------
	0    0         525        7893 HPE_VM_b9ac6dd2-52eb-4816-8cc6-d246f92f5406 data 0
	1    525       525        7763 HPE_VM_89c1943b-fa8d-4717-8c5f-f537cab6b9fe data 0
	2    1050      525        7763 HPE_VM_89c1943b-fa8d-4717-8c5f-f537cab6b9fe data 525
	3    1575      525        7763 HPE_VM_89c1943b-fa8d-4717-8c5f-f537cab6b9fe data 1050
	4    2100      525        7763 HPE_VM_89c1943b-fa8d-4717-8c5f-f537cab6b9fe data 1575
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(		[Parameter(Mandatory)]	[String]	$LD_Name,
			[Parameter()]			[switch]	$ShowRaw
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showldmap "
	if($LD_Name)	{	$Cmd += " $LD_Name " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1 -and (-not $ShowRaw))
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count  
			foreach ($S in  $Result[0..$LastItem] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','					
					Add-Content -Path $tempfile -Value $s				
				}
			$Result = Import-Csv $tempFile 
			Remove-Item $tempFile	
		}
	Return  $Result
}
}

Function Show-A9VvScsiReservations
{
<#
.SYNOPSIS
	Show information about scsi reservations of virtual volumes (VVs).
.DESCRIPTION
	The command displays SCSI reservation and registration information for Virtual Logical Unit Numbers (VLUNs) bound for a specified port.
.PARAMETER VV_Name
	Specifies the virtual volume name, using up to 31 characters.
.PARAMETER SCSI3
	Specifies that either SCSI-3 persistent reservation or SCSI-2 reservation information is displayed. If this option is not specified,
	information about both scsi2 and scsi3 reservations will be shown.
.PARAMETER SCSI2
	Specifies that either SCSI-3 persistent reservation or SCSI-2 reservation information is displayed. If this option is not specified,
	information about both scsi2 and scsi3 reservations will be shown.
.PARAMETER Hostname
	Displays reservation and registration information only for virtual volumes that are visible to the specified host.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	PS:> Show-A9RSV_CLI -Hostname virt-r-node1

	no reservations found
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$SCSI3,
		[Parameter()]	[switch]	$SCSI2,
		[Parameter()]	[String]	$Hostname,
		[Parameter()]	[String]	$VV_Name,
		[Parameter()]	[switch]	$ShowRaw
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showrsv "
	if($SCSI3)		{	$Cmd += " -l scsi3 "}
	if($SCSI2)		{	$Cmd += " -l scsi2 " }
	if($HostInfo)	{	$Cmd += " -host $Hostname " }
	if($VV_Name)	{	$Cmd += " $VV_Name " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1 -and (-not $ShowRaw))
		{	if($Result -match "SYNTAX" )	{	Return $Result	}
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count		
			foreach ($S in  $Result[0..$LastItem] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','			
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item $tempFile	
		}
	else{		Return  $Result }
}
}


Function Show-A9VvMappedToPD
{
<#
.SYNOPSIS
	Show which virtual volumes are mapped to a physical disk (or a chunklet in that physical disk).
.DESCRIPTION
	The command displays the virtual volumes that are mapped to a particular physical disk.
.PARAMETER PD_ID
	Specifies the physical disk ID using an integer. This specifier is not required if -p option is used, otherwise it must be used at least once on the command line.
.PARAMETER Sum
	Shows number of chunklets used by virtual volumes for different space types for each physical disk.
.EXAMPLE
	PS:> Show-A9VvMappedToPD_CLI -PD_ID 4
.EXAMPLE
	PS:> Show-A9VvMappedToPD -PD_ID 10 -sum
                                                                        --Chunklets---
	PDId CagePos Type RPM VVId VVName                                       Adm Data Total
  	10 1:11    SSD  N/A    1 .srdata                                        0    6     6
  	10 1:11    SSD  N/A    2 .mgmtdata                                      0   21    21
  	10 1:11    SSD  N/A  669 .shared.SSD_r6_0                               1    5     6
  	10 1:11    SSD  N/A  670 .shared.SSD_r6_1                               0   10    10
  	10 1:11    SSD  N/A 2963 pe_dmlvcenter8.2                               0    1     1
  	10 1:11    SSD  N/A 5009 NOEXPORT-BM87-Vol2                             0   17    17
  	10 1:11    SSD  N/A 5075 OLD-ARCHIVE-nfs-WL-templatelibrary             1    1     2
  	10 1:11    SSD  N/A 5077 BM88-Vol1                                      0   71    71
  	10 1:11    SSD  N/A 5080 BM88-Vol2                                      0   98    98
  	10 1:11    SSD  N/A 5341 gfs2-2                                         1    4     5
  	10 1:11    SSD  N/A 7684 OTAD-cluster1.1                                1    0     1
  	10 1:11    SSD  N/A 8468 TestVolx                                       0    1     1
  	10 1:11    SSD  N/A 8469 HPE_VM_22023a20-6fa5-4067-aae8-6bbef4e18ea1    1   27    28	
  	10 1:11    SSD  N/A 8503 pvc-d92b3c64-0aa2-4e7e-bb4a-ece                0    1     1
	--------------------------------------------------------------------------------------
	xxx total                                                                5   97   203
PS C:\Users\clionetti\Desktop\HPEStorage4.2>
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory)]	[String]	$PD_ID,
	[Parameter()]			[switch]	$Sum
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{ 	$Cmd = " showpdvv $PD_ID "
	if($Sum) {	$Cmd += "-sum "	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return  $Result 
}
}

Function Show-A9VvMapping
{
<#
.SYNOPSIS
	Show mapping from the virtual volume to logical disks.
.DESCRIPTION
	The command displays information about how virtual volume regions are mapped to logical disks.
.PARAMETER VolumeName
	The Volume name with the specified name (31 character maximum) or matches the glob-style pattern for which information is displayed. 
	If not specified, configuration information for all virtual volumes in the system is displayed.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$VolumeName
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showvvmap "
	if($VolumeName)	{	$Cmd += " $VolumeName "}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Write-Verbose "Executing function : Show-VvMapping command -->" 
	if($Result.count -gt 1 -and (-not $ShowRaw) -and (-not ($Result -match "SYNTAX" )))
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			foreach ($S in  $Result[0..$LastItem] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','		
					Add-Content -Path $tempfile -Value $s				
				}
			$Result = Import-Csv $tempFile 
			Remove-Item $tempFile	
		}
	Return  $Result
}
}

Function Show-A9VvpDistribution
{
<#
.SYNOPSIS
	Show virtual volume distribution across physical disks.
.DESCRIPTION
	The command displays virtual volume (VV) distribution across physical disks (PD). Use Get-A9Vv to obtain the name which is the VolumeName
.PARAMETER VolumeName
	Specifies the virtual volume with the specified name (31 character maximum) or matches the glob-style pattern for which information is
	displayed. This specifier can be repeated to display configuration information about multiple virtual volumes. 
.EXAMPLE
	PS:> Show-A9VvpDistribution -VolumeName Zertobm9 | format-table

	Id                          Cage_Pos SA SD usr total
	--                          -------- -- -- --- -----
	0                           0:0:0    1  0  2   3
	1                           0:1:0    0  0  2   2
	2                           0:2:0    1  0  2   3
	---------------------------
	10                          total    6  0  20  26
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]		[String]	$VolumeName
	)
Begin	
	{	Test-A9Connection -ClientType 'SshClient'
	}
process
	{	$Cmd = " showvvpd $VolumeName"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return  $Result
	}
} 

Function Start-A9LD_CLI
{	
<#
.SYNOPSIS
	Start a logical disk (LD).  
.DESCRIPTION
	The command starts data services on a LD that has not yet been started.
.PARAMETER LD_Name
	Specifies the LD name, using up to 31 characters.
.PARAMETER Override
	Specifies that the LD is forced to start, even if some underlying data is missing.
.EXAMPLE
	Start-A9LD_CLI -LD_Name xxx
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]			[switch]	$Override,
		[Parameter(Mandatory)]	[String]	$LD_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{ 	$Cmd = " startld "
	if($Override)	{	$Cmd += " -ovrd " }
	$Cmd += " $LD_Name "
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Start-A9Vv_CLI
{
<#
.SYNOPSIS
	Start a virtual volume.
.DESCRIPTION
	The command starts data services on a Virtual Volume (VV) that has not yet been started.
.PARAMETER VV_Name
	Specifies the VV name, using up to 31 characters.
.PARAMETER Ovrd
	Specifies that the logical disk is forced to start, even if some underlying data is missing.
.EXAMPLE
	Start-A9Vv_CLI
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]				[switch]	$Override,
		[Parameter(Mandatory)]		[String]	$VolumeName
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " startvv "
	if($Override)	{	$Cmd += " -ovrd "	}
	$Cmd += " $VolumeName "	
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Test-A9Vv_CLI
{
<#
.SYNOPSIS
	The command executes validity checks of VV administration information in the event of an uncontrolled system shutdown and optionally repairs corrupted virtual volumes.   
.DESCRIPTION
	The command executes validity checks of VV administration information in the event of an uncontrolled system shutdown and optionally repairs corrupted virtual volumes.
.PARAMETER Yes
	Specifies that if errors are found they are either modified so they are valid (-y) or left unmodified (-n). If not specified, errors are left unmodified (-n).
.PARAMETER No
	Specifies that if errors are found they are either modified so they are valid (-y) or left unmodified (-n). If not specified, errors are left unmodified (-n)
.PARAMETER Offline
	Specifies that VVs specified by <VV_name> be offlined before validating the VV administration information. The entire VV tree will be offlined if this option is specified.
.PARAMETER Dedup_Dryrun
	Launches a dedup ratio calculation task in the background that analyzes the potential space savings with Deduplication technology if the
	VVs specified were in a same deduplication group. The VVs specified can be TPVVs, compressed VVs and fully provisioned volumes.
.PARAMETER Compr_Dryrun
	Launches a compression ratio calculation task in the background that analyzes the potential space savings with Compression technology of specified
	VVs. Specified volumes can be TPVVs, TDVVs, fully provisioned volumes and snapshots.
.PARAMETER Fixsd
	Specifies that VVs specified by <VV_name> be checked for compressed data consistency. The entire tree will not be checked; only those VVs
	specified in the list will be checked.
.PARAMETER Dedup_Compr_Dryrun
	Launches background space estimation task that analyzes the overall savings of converting the specified VVs into a compressed TDVVs.
	Specified volumes can be TPVVs, TDVVs, compressed TPVVs, fully provisioned volumes, and snapshots.

	This task will display compression and total savings ratios on a per-VV basis, and the dedup ratio will be calculated on a group basis of input VVs. 	
.PARAMETER VVName       
	Requests that the integrity of the specified VV is checked. This specifier can be repeated to execute validity checks on multiple VVs. Only base VVs are allowed.
.EXAMPLE
	PS:> Test-A9Vv_CLI -VVName XYZ
.EXAMPLE
	PS:> Test-A9Vv_CLI -Yes -VVName XYZ
.EXAMPLE
	PS:> Test-A9Vv_CLI -Offline -VVName XYZ
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]				[switch]	$Yes,	
		[Parameter()]				[switch]	$No,
		[Parameter()]				[switch]	$Offline,
		[Parameter(Mandatory=$true)][String]	$VVName,
		[Parameter()]				[switch]	$Fixsd,
		[Parameter()]				[switch]	$Dedup_Dryrun,
		[Parameter()]				[switch]	$Compr_Dryrun,
		[Parameter()]				[switch]	$Dedup_Compr_Dryrun
	)	
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}	
process
{	$cmd = "checkvv -f "	
	if($Yes)				{	$cmd += " -y "	}
	if($No)					{	$cmd += " -n "	}
	if($Offline)			{	$cmd += " -offline "}
	if($Fixsd)				{	$cmd += " -fixsd "}
	if($Dedup_Dryrun)		{	$cmd += " -dedup_dryrun "}
	if($Compr_Dryrun)		{	$cmd += " -compr_dryrun "}
	if($Dedup_Compr_Dryrun)	{	$cmd += " -dedup_compr_dryrun "}
	$cmd += " $VVName"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	write-verbose "  Executing Test-Vv Command.-->  " 
	return  "$Result"
}
}

Function Update-A9SnapSpace_CLI
{
<#
.SYNOPSIS
	Update the snapshot space usage accounting.
.DESCRIPTION
	The command starts a non-cancelable task to update the snapshot space usage accounting. The snapshot space usage displayed by
	"showvv -hist" is not necessarily the current usage and the SpaceCalcTime column will show when it was last calculated.  This command causes the
	system to start calculating current snapshot space usage.  If one or more VV names or patterns are specified, only the specified VVs will be updated.
.PARAMETER VolumeName
	Specifies the virtual volume name to update. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$VolumeName
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " updatesnapspace $VolumeName " 
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Update-A9VvProperties_CLI
{
<#
.SYNOPSIS
	Change the properties associated with a virtual volume.
.DESCRIPTION
	The command changes the properties associated with a virtual volume. Use the Update-VvProperties to modify volume 
	names, volume policies, allocation warning and limit levels, and the volume's controlling common provisioning group (CPG).
.PARAMETER Vvname  
	Specifies the virtual volume name or all virtual volumes that match the pattern specified, using up to 31 characters. The patterns are glob-
	style patterns (see help on sub, globpat). Valid characters include alphanumeric characters, periods, dashes, and underscores.
.PARAMETER Wwn
	Specifies that the WWN of the virtual volume be changed to a new WWN as indicated by the <new_wwn> specifier. If <new_wwn> is set to "auto", the
	system will automatically choose the WWN based on the system serial number, the volume ID, and the wrap counter. This option is not allowed
	for the admitted volume before it is imported, or while the import process is taking place.
	Only one of the following three options can be specified:
.PARAMETER Udid
	Specifies the user defined identifier for VVs for OpenVMS hosts. Udid value should be between 0 to 65535 and can be identical for several VVs.
.PARAMETER Clrrsv
	Specifies that all reservation keys (i.e. registrations) and all persistent reservations on the virtual volume are cleared.
.PARAMETER Clralua
	Restores ALUA state of the virtual volume to ACTIVE/OPTIMIZED state. In ACTIVE/OPTIMIZED state hosts will have complete access to the volume.
.PARAMETER Spt
	Defines the virtual volume geometry sectors per track value that is reported to the hosts through the SCSI mode pages. The valid range is
	between 4 to 8192 and the default value is 304.
.PARAMETER Hpc
	Allows you to define the virtual volume geometry heads per cylinder value that is reported to the hosts though the SCSI mode pages. 
	The valid range is between 1 to 255 and the default value is 8.
.EXAMPLE  
	The following example sets the policy of virtual volume vv1 to no_stale_ss.
	
	PS:> Update-A9VvProperties_CLI -Pol "no_stale_ss" -Vvname vv1
.EXAMPLE
	The following example modifies the WWN of virtual volume vv1

	PS:> Update-VvProperties_CLI -Wwn "50002AC0001A0024" -Vvname vv1
.EXAMPLE
	The following example modifies the udid value for virtual volume vv1.

	PS:> Update-VvProperties_CLI -Udid "1715" -Vvname vv1
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(mandatory)]	[String]	$VolumeName,
		[Parameter()]	[String]	$Wwn,
		[Parameter()]	[String]	$Udid,
		[Parameter()]	[switch]	$Clrrsv,
		[Parameter()]	[switch]	$Clralua,
		[Parameter()]	[String]	$Spt,
		[Parameter()]	[String]	$Hpc,
		[Parameter(Mandatory=$True)]	[String]	$Vvname
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " setvv -f "
	if($Wwn)		{	$Cmd += " -wwn $Wwn " 		}
	if($Udid)		{	$Cmd += " -udid $Udid " 	}
	if($Clrrsv)		{	$Cmd += " -clrrsv " 		}
	if($Clralua)	{	$Cmd += " -clralua " 		}
	if($Spt)		{	$Cmd += " -spt $Spt " 		}
	if($Hpc)		{	$Cmd += " -hpc $Hpc " 		}
	if($VolumeName) {	$Cmd += " $VolumeName " 	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Write-verbose "Executing function : Update-VvProperties command -->"
	Return $Result
}
}

Function Update-A9VvSetProperties_CLI
{
<#
.SYNOPSIS
	Update-VvSetProperties - set parameters for a Virtual Volume set
.DESCRIPTION
	The Update-VvSetProperties command sets the parameters and modifies the properties of a Virtual Volume(VV) set.
.PARAMETER Setname
	Specifies the name of the vv set to modify.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.

.PARAMETER Name
	Specifies a new name for the VV set using up to 27 characters.
.EXAMPLE
	Update-VvSetProperties
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]					[String]	$Comment,
		[Parameter()]					[String]	$Name,
		[Parameter(Mandatory=$True)]	[String]	$Setname
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " setvvset "
	if($Comment)	{	$Cmd += " -comment $Comment "}
	if($Name)		{	$Cmd += " -name $Name "}
	$Cmd += " Setname " 
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}


Function Show-A9Peer_CLI
{
<#
.SYNOPSIS   
	The command displays the arrays connected through the host ports or peer ports over the same fabric.
.DESCRIPTION  
	The command displays the arrays connected through the host ports or peer ports over the same fabric. The Type field
    specifies the connectivity type with the array. The Type value of Slave means the array is acting as a source, the Type value
    of Master means the array is acting as a destination, the type value of Peer means the array is acting as both source and destination.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE	
	PS:> Show-A9Peer_CLI
#>
[CmdletBinding()]
param(	[Parameter()] 	[switch]	$ShowRaw 
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}	
process	
{	$cmd = " showpeer"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if(-not ( ($Result -match "No peers") -or $ShowRaw ))
		{	$tempFile = [IO.Path]::GetTempFileName()
			foreach ($s in  $Result[0..($Result.count)] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','	
					Add-Content -Path $tempFile -Value $s
				}
			$Result = Import-Csv $tempFile 
			remove-item $tempFile
		}
	return $Result
}
} 

