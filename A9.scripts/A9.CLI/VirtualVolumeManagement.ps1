## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9Mapping
{
<#
.SYNOPSIS
	Show mapping from a Logical Disks to Volumes, Volumes to Logical Disks, Volumes to Physical Disks, and Physical Disks to Volumes.
.DESCRIPTION
	Show mapping from a Logical Disks to Volumes, Volumes to Logical Disks, Volumes to Physical Disks, and Physical Disks to Volumes.
.PARAMETER Volume
	Specifies the Volume with the specified name. You can use Get-A9Volume to list the avaialble Volumes
.PARAMETER LogicalDisk
	Specifies the Logical Disk name. To obtain a list of valid Logical Disks, issue the Get-A9LogicalDisk
.PARAMETER PhysicalDiskID
	Specifies the Physical Disk ID using an integer. This specifier is not required if -p option is used, otherwise it must be used at least once on the command line.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.PARAMETER Sum
	Shows number of chunklets used by virtual volumes for different space types for each physical disk.
.EXAMPLE
	PS:> Show-A9Mapping -LogicalDiskId tp-0-sd-0.230 

	Area Start(MB) Length(MB) VVId Name                                        VVSp VVOff(MB)
	---- --------- ---------- ---- ----                                        ---- ---------
	0    0         525        7893 HPE_VM_b9ac6dd2-52eb-4816-8cc6-d246f92f5406 data 0
	1    525       525        7763 HPE_VM_89c1943b-fa8d-4717-8c5f-f537cab6b9fe data 0
	2    1050      525        7763 HPE_VM_89c1943b-fa8d-4717-8c5f-f537cab6b9fe data 525
	3    1575      525        7763 HPE_VM_89c1943b-fa8d-4717-8c5f-f537cab6b9fe data 1050
	4    2100      525        7763 HPE_VM_89c1943b-fa8d-4717-8c5f-f537cab6b9fe data 1575
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
.EXAMPLE
	PS:> Show-A9VvMappedToPD_CLI -PD_ID 4
.EXAMPLE
	PS:> Show-A9Mapping -PhysicalDisk 10 -sum
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
.EXAMPLE
	PS:> Show-A9VvpDistribution -VolumeName Zertobm9 -ShowVolumeToPhysicalDiskMap

	Id                          Cage_Pos SA SD usr total
	--                          -------- -- -- --- -----
	0                           0:0:0    1  0  2   3
	1                           0:1:0    0  0  2   2
	2                           0:2:0    1  0  2   3
	---------------------------
	10                          total    6  0  20  26
.NOTES
	This command utilizes the SSH command 'showldmap', 'showpdvv', 'showvvmap', 'showvvpd'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(		[Parameter(Mandatory, ParameterSetName='showldmap')]	[String]	$LogicalDisk,
			[Parameter(Mandatory, ParameterSetName='showpdvv')]		[String]	$PhysicalDiskId,
			[Parameter(ParameterSetName='showpdvv')]				[String]	$Sum,
			[Parameter(Mandatory, ParameterSetName='showvvpd')]		
			[Parameter(Mandatory, ParameterSetName='showvvmap')]	[String]	$Volume,
			[Parameter(Mandatory, ParameterSetName='showvvpd')]		[Switch]	$ShowVolumeToPhysicalDiskMap,
			[Parameter(Mandatory, ParameterSetName='showvvmap')]	[Switch]	$ShowVolumeToLogicalDiskMap,
			[Parameter()]											[switch]	$ShowRaw
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = $PSCmdlet.ParameterSetName 
	$tempFile = [IO.Path]::GetTempFileName()
	Switch ($PSCmdlet.ParameterSetName)
		{	'showldmap'	
						{	$Cmd += " $LogicalDisk " 
							$Result = Invoke-A9CLICommand -cmds  $Cmd
							if($Result.count -gt 1 -and (-not $ShowRaw))
								{	$LastItem = $Result.Count  
									foreach ($S in  $Result[0..$LastItem] )
										{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','					
											Add-Content -Path $tempfile -Value $s				
										}
									$Result = Import-Csv $tempFile 
								}
						}
			'showpdvv'	
						{	$Cmd += " $PhysicalDiskId"
							if ( $Sum ) 	{	$Cmd += " -sum "	}
							$Result = Invoke-A9CLICommand -cmds  $Cmd
						}
			'showvvpd'			
						{	$Cmd += " $Volume"
							$Result = Invoke-A9CLICommand -cmds  $Cmd
						}
			'showvvmap'
						{	$Cmd += " $Volume"
							$Result = Invoke-A9CLICommand -cmds $Cmd
							if ( $Result.count -gt 1 -and (-not $ShowRaw) -and (-not ($Result -match "SYNTAX" )) )
								{	$LastItem = $Result.Count
									foreach ($S in  $Result[0..$LastItem] )
										{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','		
											Add-Content -Path $tempfile -Value $s				
										}
									$Result = Import-Csv $tempFile 
								}
						}
		}
	Write-Verbose "Executing function : Get-VvMapping command --> $Cmd" 
	Remove-Item $tempFile
	Return  $Result
}
}

Function Get-A9VvScsiReservations
{
<#
.SYNOPSIS
	Show information about scsi reservations of virtual volumes (VVs).
.DESCRIPTION
	The command displays SCSI reservation and registration information for Virtual Logical Unit Numbers (VLUNs) bound for a specified port.
.PARAMETER Volume
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
	PS:> Get-A9VvScsiReservations -Hostname virt-r-node1

	no reservations found
.NOTES
	This command utilizes the SSH command 'showrsv'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$SCSI3,
		[Parameter()]	[switch]	$SCSI2,
		[Parameter()]	[String]	$Hostname,
		[Parameter()]	[String]	$Volume,
		[Parameter()]	[switch]	$ShowRaw
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showrsv "
	if ( $SCSI3 )		{	$Cmd += " -l scsi3 "}
	if ( $SCSI2 )		{	$Cmd += " -l scsi2 " }
	if ( $HostInfo )	{	$Cmd += " -host $Hostname " }
	if ( $Volume )		{	$Cmd += " $Volume " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if ( $Result.count -gt 1 -and (-not $ShowRaw) )
		{	if($Result -match "SYNTAX" )	{	Return $Result	}
			$tempFile = [IO.Path]::GetTempFileName()
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
	This command utilizes the SSH command 'updatesnapspace'
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

Function Set-A9Volume_CLI
{
<#
.SYNOPSIS
	Change the properties associated with a virtual volume.
.DESCRIPTION
	The command changes the properties associated with a virtual volume. Use the Update-VvProperties to modify volume 
	names, volume policies, allocation warning and limit levels, and the volume's controlling common provisioning group (CPG).
.PARAMETER VolumeName  
	Specifies the virtual volume name or all virtual volumes that match the pattern specified, using up to 31 characters. The patterns are glob-
	style patterns (see help on sub, globpat). Valid characters include alphanumeric characters, periods, dashes, and underscores.
.PARAMETER Wwn
	Specifies that the WWN of the virtual volume be changed to a new WWN as indicated by the <new_wwn> specifier. If <new_wwn> is set to "auto", the
	system will automatically choose the WWN based on the system serial number, the volume ID, and the wrap counter. This option is not allowed
	for the admitted volume before it is imported, or while the import process is taking place.
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
.PARAMETER Start
	The command starts data services on a Virtual Volume (VV) that has not yet been started.
.PARAMETER Override
	Specifies that the VV is forced to start, even if some underlying data is missing.
.PARAMETER Modify
	Only Valid if testing a VV. Specifies that if errors are found they are either modified so they are valid (-y) or left unmodified (-n). If not specified, errors are left unmodified (-n).
	Valid Options are 'yes' and 'no'
.PARAMETER Offline
	Only Valid if testing a VV. Specifies that VVs specified by <VV_name> be offlined before validating the VV administration information. The entire VV tree will be offlined if this option is specified.
.PARAMETER FixSD
	Only Valid if testing a VV. Specifies that VVs specified by <VolumeName> be checked for compressed data consistency. The entire tree will not be checked; only those VVs
	specified in the list will be checked.
.PARAMETER FreeSpace
	Will try and free unused SA (Administrative) and SS (Snapshot) space from a Volume.
.PARAMETER Test
	Will Test a VV and its RAID space for consistency, if errors are detected it can either fix or only report those errors based on the value of the modify parameter.
.PARAMETER SUBCommand
	usr_cpg <cpg>
		Moves the logical disks being used for user space to the specified CPG.
		
	snp_cpg <cpg>
		Moves the logical disks being used for snapshot space to the specified CPG.
		
	restart
		Restarts a tunevv command call that was previously interrupted because of component failure, or because of user initiated cancellation. This
		cannot be used on TPVVs or TDVVs.
		
	rollback
		Returns to a previously issued tunevv operation call that was interrupted. The canceltask command needs to run before the rollback.
		This cannot be used on TPVVs or TDVVs.
.PARAMETER CPGName
	Indicates that only regions of the VV which are part of the the specified CPG should be tuned to the destination USR or SNP CPG.
.PARAMETER Count
	Specifies the number of identical virtual volumes to tune using an integer from 1 through 999. If not specified, one virtual volume
	is tuned. If the '-cnt' option is specified, then the subcommands, "restart" and "rollback" are not permitted.
.PARAMETER TPVV
	Indicates that the VV should be converted to a thin provision virtual volume.  Cannot be used with the -dedup or -full options.
.PARAMETER TDVV
	This option is deprecated, see -dedup.
.PARAMETER DeDup
	Indicates that the VV should be converted to a thin provision virtual volume that shares logical disk space with other instances of this volume type.  Cannot be used with the -tpvv or -full options.
.PARAMETER Full
	Indicates that the VV should be converted to a fully provisioned virtual volume.  Cannot be used with the -tpvv, -dedup, or -compr options.
.PARAMETER Compr
	Indicates that the VV should be converted to a compressed virtual volume.  Cannot be used with the -full option.
.PARAMETER KeepVV
	Indicates that the original logical disks should be saved under a new virtual volume with the given name.  Can only be used with the -tpvv, -dedup, -full, or -compr options.
.PARAMETER Src_Cpg 
	Indicates that only regions of the VV which are part of the the specified CPG should be tuned to the destination USR or SNP CPG. This option is
	recommended when a VV belongs to an AO configuration and will avoid disrupting any optimizations already performed.
.PARAMETER Threshold 
	Slice threshold. Volumes above this size will be tuned in slices. <threshold> must be in multiples of 128GiB. Minimum is 128GiB. Default is 16TiB. Maximum is 16TiB.
.PARAMETER SliceSize
	Slice size. Size of slice to use when volume size is greater than <threshold>. <size> must be in multiples of 128GiB. Minimum is 128GiB. Default is 2TiB. Maximum is 16TiB.
.PARAMETER VV_WWN
	Specifies the World Wide Name (WWN) of the remote volumes to be admitted.
.PARAMETER NewWWN 
	Specifies the World Wide Name (WWN) for the local copy of the remote volume. If the keyword "auto" is specified the system automatically generates a WWN for the virtual volume
.PARAMETER Admit
	The command creates and admits remotely exported virtual volume definitions to enable the migration of these volumes. The newly created
	volume will have the WWN of the underlying remote volume.
.PARAMETER CompressVolume
	Will issue the compression tuning option
.PARAMETER Freespace
	Will force the array to free space in the free pool, i.e. garbage collection.
.PARAMETER Import
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
.EXAMPLE
	PS:> Add-Vv -VV_WWN  migvv.0:50002AC00037001A

	Specifies the local name that should be given to the volume being admitted and Specifies the World Wide Name (WWN) of the remote volumes to be admitted.
.EXAMPLE
	PS:> Set-A9Volume_CLI -admit -VV_WWN  "migvv.0:50002AC00037001A migvv.1:50002AC00047001A"
.EXAMPLE  
	The following example sets the policy of virtual volume vv1 to no_stale_ss.
	
	PS:> Update-A9VvProperties_CLI -Pol "no_stale_ss" -Vvname vv1
.EXAMPLE
	The following example modifies the WWN of virtual volume vv1

	PS:> Update-VvProperties_CLI -Wwn "50002AC0001A0024" -Vvname vv1
.EXAMPLE
	The following example modifies the udid value for virtual volume vv1.

	PS:> Update-VvProperties_CLI -Udid "1715" -Vvname vv1
.EXAMPLE
	The following example frees administration and snapshot space from a volume if that space is no longer being used.

	PS:> Set-A9Volume_CLI -VolumeName vv1
.EXAMPLE	
	PS:> Set-A9Volume_CLI -CompressVolume -SUBCommand usr_cpg -CPGName XYZ
.EXAMPLE
	PS:> Set-A9Volume_CLI -CompressVolume -SUBCommand usr_cpg -CPGName XYZ -Option keepvv -KeepVVName XYZ -VVName XYZ
.EXAMPLE
	PS:> Set-A9Volume_CLI -CompressVolume -SUBCommand snp_cpg -CPGName XYZ -VVName XYZ	
.NOTES
	This command utilizes the SSH command 'startvv', 'setvv','checkvv', 'freespace', 'tunevv', 'admitvv', 'importvv'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory, ParameterSetName='Start')]	[switch]	$Start,
		[Parameter(Mandatory,ParameterSetName='Test')]		[Switch]	$Test,
		[Parameter(Mandatory,ParameterSetName='Freespace')]	[switch]	$FreeSpace,
		[Parameter(Mandatory,ParameterSetName='Compress')]	[Switch]	$CompressVolume,
		[Parameter(Mandatory,ParameterSetName="admit")]		[switch]	$Admit,
		[Parameter(Mandatory,ParameterSetName="import")]	[switch]	$Import,
		[Parameter(mandatory, ParameterSetName='Set')]	
		[Parameter(mandatory, ParameterSetName='Start')]
		[Parameter(mandatory, ParameterSetName='Test')]
		[Parameter(mandatory, ParameterSetName='Cpompress')]
		[Parameter(Mandatory,ParameterSetName="admit")]
		[Parameter(ParameterSetName='import')]				[String]	$VolumeName,
		[Parameter(ParameterSetName='Set')]			
		[Parameter(Mandatory,ParameterSetName="admit")]	[String]	$Wwn,
		[Parameter(ParameterSetName='Set')]				[String]	$Udid,
		[Parameter(ParameterSetName='Set')]				[switch]	$Clrrsv,
		[Parameter(ParameterSetName='Set')]				[switch]	$Clralua,
		[Parameter(ParameterSetName='Set')]				[String]	$Spt,
		[Parameter(ParameterSetName='Set')]				[String]	$Hpc,
		[Parameter(ParameterSetName='Start')]			[switch] 	$Override,
		[Parameter(ParameterSetName='Test')]
		[ValidateSet('Yes','No')]						[switch]	$Modify,
		[Parameter(ParameterSetName='Test')]			[switch]	$No,
		[Parameter(ParameterSetName='Test')]			[switch]	$Offline,
		[Parameter(ParameterSetName='Test')]			[switch]	$FixSD,
		# compress
		[Parameter(Mandatory,ParameterSetName='Compress')][ValidateSet('usr_cpg','snp_cpg','restart','rollback')]
														[String]	$SUBCommand ,
		[Parameter(ParameterSetName='Compress')]		[String]	$CPGName ,	
		[Parameter(ParameterSetName='Compress')]		[String]	$Count ,
		[Parameter(ParameterSetName='Compress')]
		[Parameter(ParameterSetName='import')]			[switch]	$TPVV ,
		[Parameter(ParameterSetName='Compress')]
		[Parameter(ParameterSetName='import')]			[switch]	$TDVV ,
		[Parameter(ParameterSetName='Compress')]
		[Parameter(ParameterSetName='import')]			[switch]	$DeDup ,
		[Parameter(ParameterSetName='Compress')]		[switch]	$Full ,
		[Parameter(ParameterSetName='Compress')]	
		[Parameter(ParameterSetName='import')]			[switch]	$Compr ,
		[Parameter(ParameterSetName='Compress')]		[String]	$KeepVV ,		
		[Parameter(ParameterSetName='Compress')]		[String]	$Threshold , 
		[Parameter(ParameterSetName='Compress')]		[String]	$SliceSize , 		
		[Parameter(ParameterSetName='Compress')]		[String]	$Src_Cpg,
		# admit
		[Parameter(ParameterSetName="admin")]			[String]	$Domain ,						
		[Parameter(ParameterSetName="admit")]			[String] 	$NewWWN,
		# import
		[Parameter(Mandatory,ParameterSetName='import')][String]	$Usrcpg ,
		[Parameter(ParameterSetName='import')]			[String]	$Snapname ,		
		[Parameter(ParameterSetName='import')]			[String]	$Snp_cpg ,		
		[Parameter(ParameterSetName='import')]			[switch]	$NoCons ,
		[Parameter(ParameterSetName='import')]	
		[ValidateSet('high','med','low')]				[String]	$Job_ID ,		
		[Parameter(ParameterSetName='import')]			[switch]	$NoTask ,		
		[Parameter(ParameterSetName='import')]			[switch]	$Cleanup ,
		[Parameter(ParameterSetName='import')]			[String]	$MinAlloc 
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	Switch ($PSCmdlet.ParameterSetName)
		{	'Start'	
					{	$Cmd = " startvv "
						if($Override)	{	$Cmd += " -ovrd "	}
						$Cmd += " $VolumeName "	
					}
			'Set'	
					{	$Cmd = " setvv -f "
						if($Wwn)		{	$Cmd += " -wwn $Wwn " 		}
						if($Udid)		{	$Cmd += " -udid $Udid " 	}
						if($Clrrsv)		{	$Cmd += " -clrrsv " 		}
						if($Clralua)	{	$Cmd += " -clralua " 		}
						if($Spt)		{	$Cmd += " -spt $Spt " 		}
						if($Hpc)		{	$Cmd += " -hpc $Hpc " 		}
						$Cmd += " $VolumeName "
					}
			'Test'	
					{	$cmd = "checkvv -f "	
						if($Modify -eq 'Yes')	{	$cmd += " -y "	}
						if($Modify -eq 'No')	{	$cmd += " -n "	}
						if($Offline)			{	$cmd += " -offline "}
						if($FixsSD)				{	$cmd += " -fixsd "}
						$cmd += " $VolumeName"
					}
			'freespace'
					{	$Cmd = " freespace -f $VolumeName "
					}
			'compress'
					{	$Cmd = " tunevv "
						if($SUBCommand)
							{	$Cmd += " $SUBCommand"
								if($SUBCommand -eq "usr_cpg" -Or $SUBCommand -eq "snp_cpg")
									{	if($CPGName)	{	$Cmd += " $CPGName"	}
										else			{	return "SubCommand : $SUBCommand,Must Require CPG Name."	}
									}
							}
						$Cmd += " -f "	
						if($Count)		{	$Cmd += " -cnt $Count"	}
						if($TPVV)		{	$Cmd += " -tpvv "	}
						if($TDVV)		{	$Cmd += " -tdvv "	}
						if($DeDup)		{	$Cmd += " -dedup "	}
						if($Full)		{	$Cmd += " -full "	}
						if($Compr)		{	$Cmd += " -compr "	}
						if($KeepVV)		{	$Cmd += " -keepvv $KeepVV"	}
						if($Src_Cpg)	{	$Cmd += " -src_cpg $Src_Cpg"	}
						if($Threshold)	{	$Cmd += " -slth $Threshold"	}
						if($SliceSize)	{	$Cmd += " -slsz $SliceSize"	}
						if($VolumeName)	{	$Cmd += " $VolumeName"	}
					}
			"admit"
					{	$cmd = "admitvv"
						if ( $DomainName ) 	{	$Cmd+= " -domain $DomainName"	}
						$cmd += $VolumeName + ":" + $WWN
						if ( $NewWWN )		{	$cmd += ":" + $VV_WWN_NewWWN	}	
					}
			'import'
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
						if($VolumeName)		{	$Cmd += " $VolumeName"	}	
					}
		}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Write-verbose "Executing function : Set-A9Volume command --> $Cmd"
	Return $Result
}
}

Function Get-A9Peer_CLI
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
	This command utilizes the SSH command 'showpeer'
	This command requires a SSH type connection.
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
