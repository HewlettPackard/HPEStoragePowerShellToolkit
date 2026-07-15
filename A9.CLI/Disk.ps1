## 	©2025 Hewlett Packard Enterprise Development LP

Function Remove-A9PhysicalDisk
{
<#
.SYNOPSIS
	Remove a physical disk (PD) from system use.
.DESCRIPTION
	The command removes PD definitions from system use.
	- A PD that is in use cannot be removed.
.PARAMETER PDID
	Specifies the physical disk ID, identified by integers, to be removed from system use.
.EXAMPLE
	The following example removes a PD with ID 1:

	PS:> Remove-A9PhysicalDisk -PDID 1
.NOTES
	This command utilizes the SSH command 'DismissPD' 
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$PDID
)
Begin	
	{   Test-A9Connection -ClientType 'SshClient'
	}
Process
	{	$Cmd = " dismisspd $PDID"
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Set-A9PhysicalDisk
{
<#
.SYNOPSIS
	Sets or Activates processes on a Physical Disk (PD).
.DESCRIPTION
	Marks a Physical Disk (PD) as allocatable or non allocatable for Logical Disks (LDs). 
	Verify the status of PDs by issuing the Get-A9Disk -state command (see the Get-A9Disk command). 
	You can also test a physical disk using the Scrub or Diag options. 
	The command using Optmize option can also identifies physical disks with high service times and optionally executes load balancing.
.PARAMETER ldalloc 
	Specifies that the PD, as indicated with the PD_ID specifier, is either allocatable (on) or nonallocatable for LDs (off)..PARAMETER PD_ID 
	Specifies the PD identification using an integer.	
	The LDAlloc option command can be used when the system has disks that are not to be used until a later time.
.PARAMETER Spinup
	Allows a Controller to send a Spinup command to the drive with the given required WWN 
.PARAMETER Spindown
	Allows a controller to send a spindown command to the drive witht the given required WWN, will fail if the disk is in used unless a force option is used.
.PARAMETER Force
	Only valid for a spindown operation, will allow the spindown to occur even if the given drive has logical disks on it.
.PARAMETER WWN	
	must be specified when spining up or spinning down a disk, and is optional when approving a disk. If unset when using the approve process, it will approve all available disks.
.PARAMETER Approve
	PDs cannot be used for storage until they are approved to the system.
.PARAMETER NoLD
	To replace a failed disk that has had chunklets moved to spare space, use the -nold option when adding the replacement physical disk. 
	Specifying -nold prevents the allocation of the newly added physical disk, allowing you to move the chunklets back to the new disk. 
	After moving the chunklets back to the new disk, use the setpd command to enable logical disk allocation.
.PARAMETER SkipPatch
	The approve command checks for drive table patch updates unless you specify the -nopatch option.
.PARAMETER Diag	
	diag - Performs read, write, or verifies test diagnostics.
.PARAMETER Scrub
	scrub - Scans one or more chunklets for media defects. 
.PARAMETER ch
	To scan a specific chunklet rather than the entire disk.
.PARAMETER count
	To scan a number of chunklets starting from -ch.
.PARAMETER path
	Specifies a physical disk path as [a|b|both|system].
.PARAMETER test
	Specifies [read|write|verify] test diagnostics. If no type is specified, the default is read .
.PARAMETER iosize
	Specifies I/O size, valid ranges are from 1s to 1m. If no size is specified, the default is 128k .
.PARAMETER range
	Limits diagnostic regions to a specified size, from 2m to 2g.
.PARAMETER pd_ID
	The ID of the physical disk to be checked. Only one pd_ID can be specified for the “scrub” test.
.PARAMETER threads
	Specifies number of I/O threads, valid ranges are from 1 to 4. If the number of threads is not specified, the default is 1.
.PARAMETER time
	Indicates the number of seconds to run, from 1 to 36000.
.PARAMETER total
	Indicates total bytes to transfer per disk. If a size is not specified, the default size is 1g.
.PARAMETER retry
	Specifies the total number of retries on an I/O error.
.PARAMETER MaxSvct
	Specifies that either the maximum service time threshold (<msecs>) that is used to discover over-utilized physical disks, or the physical disks
	that have the highest maximum service times (highest). If a threshold is specified, then any disk whose maximum service time exceeds the
	specified threshold is considered a candidate for load balancing.
.PARAMETER AvgSvct
	Specifies that either the average service time threshold (<msecs>) that is used to discover over-utilized physical disks, or the physical disks
	that have the highest average service time (highest). If a threshold is specified, any disk whose average service time exceeds the specified
	threshold is considered a candidate for load balancing.
.PARAMETER Nodes
	Specifies that the display is limited to specified nodes and physical disks connected to those nodes. The node list is specified as a series
	of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the node list is not specified, all disks on all
	nodes are displayed.
.PARAMETER Slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified
	as a series of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all
	disks on all slots are displayed.
.PARAMETER Ports
	Specifies that the display is limited to specified ports and physical disks connected to those ports. The port list is specified as a series of 
	integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the port list is not specified, all disks on all ports are displayed.
.PARAMETER Volume
	Specifies that the physical disks used by the indicated virtual volume name are included for statistic sampling.
.PARAMETER Seconds
	Specifies the interval, in seconds, that statistics are sampled using an integer from 1 through 2147483. If no interval is specified, the option defaults to 30 seconds.
.PARAMETER Iterations
	Specifies that I/O statistics are sampled a specified number of times as indicated by the number argument using an integer greater than 0. If 0
	is specified, I/O statistics are looped indefinitely. If this option is not specified, the command defaults to 1 iteration.
.PARAMETER Frequency
	Specifies the interval, in minutes, that the command enters standby mode between iterations using an integer greater than 0. If this option is
	not specified, the number of iterations is looped indefinitely.
.PARAMETER Volumelayout
	Specifies that the layout of the virtual volume is displayed. If this option is not specified, the layout of the virtual volume is not displayed.
.PARAMETER Portstat
	Specifies that statistics for all disk ports in the system are displayed. If this option is not specified, statistics for ports are not displayed.
.PARAMETER Pdstat
	Specifies that statistics for all physical disk, rather than only those with high service times, are displayed. If this option is not specified,
	statistics for all disks are not displayed.
.PARAMETER Chstat
	Specifies that chunklet statistics are displayed. If not specified, chunklet statistics are not displayed. If this option is used with the
.PARAMETER Maxpd
	Specifies that only the indicated number of physical disks with high service times are displayed. If this option is not specified, 10
	physical disks are displayed.
.PARAMETER Movech
	Specifies that if any disks with unbalanced loads are detected that chunklets are moved from those disks for load balancing.
	auto: 	Specifies that the system chooses source and destination chunklets. 
	manual: Specifies that the source and destination chunklets are manually entered.
	If not specified, you are prompted for selecting the source and destination chunklets.  
.EXAMPLE
	PS:> Set-A9PhysicalDisk -Ldalloc off -PD_ID 20	
	
	displays PD 20 marked as non allocatable for LDs.
.EXAMPLE  
	PS:> Set-A9PhysicalDisk -spinup -wwn 201524a1aabbcc3345	

	Will spinup a drive this the given WWN, you may then wish to rerun the command and make it allocatable.
.EXAMPLE  
	PS:> Set-A9PhysicalDisk -spindown -wwn 201524a1aabbcc3345 -force

	Will spindown a drive this the given WWN, since the force was used, it will spin down the drive regardless if the drive is in use.
.EXAMPLE  
	PS:> Set-A9PhysicalDisk -Ldalloc on -PD_ID 25	

	displays PD 25 marked as allocatable for LDs.
.NOTES
	This command utilizes the SSH command 'AdmitPD', 'SetPD', 'ControlPD', 'CheckPD', 'TunePD'	
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory, ParameterSetName='Allocate')]
		[ValidateSet('on','off')]							[String]	$Ldalloc,	
		[Parameter(Mandatory, ParameterSetName='Diag')]
		[Parameter(Mandatory, ParameterSetName='Scrub')]
		[Parameter(Mandatory, ParameterSetName='Allocate')]	[String]	$PD_ID,
		[Parameter(ParameterSetName='Spinup',  Mandatory)]	[switch]	$Spinup,
		[Parameter(ParameterSetName='Spindown',Mandatory)]	[switch]	$Spindown, 
		[Parameter(ParameterSetName='Spindown')]			[switch]	$Force,	
		[Parameter(ParameterSetName='Spindown',mandatory)]
		[Parameter(ParameterSetName='Spinup',mandatory)]	
		[Parameter(ParameterSetName='Approve',mandatory)]	[switch]	$Approve,
		[Parameter(ParameterSetName='Approve')]				[String]	$WWN,
		[Parameter(ParameterSetName='Approve')]				[switch]	$Nold,
		[Parameter(ParameterSetName='Approve')]				[switch]	$SkipPatch,

		[Parameter(ParameterSetName='diag', Mandatory)]		[switch]	$Diag,		
		[Parameter(ParameterSetName='scrub',Mandatory)]		[switch]	$Scrub,		
		[Parameter(ParameterSetName='Scrub')]				[int]		$ch,		
		[Parameter(ParameterSetName='Scrub')]				[int]		$count,
		[Parameter(ParameterSetName='diag')]
		[ValidateSet('a','b','system','both')]				[String]	$path,		
		[Parameter(ParameterSetName='diag')]
		[ValidateSet('read','write','verify')]				[String]	$test,	
		[Parameter(ParameterSetName='diag')]				[String]	$iosize,	
		[Parameter(ParameterSetName='diag')]				[String]	$range,		
		[Parameter(ParameterSetName='diag')]
		[ValidateRange(1,4)]								[int]		$threads,	
		[Parameter(ParameterSetName='diag')]	
		[ValidateRange(1,36000)]							[int]		$time,		
		[Parameter(ParameterSetName='diag')]				[String]	$total,		
		[Parameter(ParameterSetName='diag')]				[String]	$retry,
		[Parameter(Mandatory, ParameterSetName='OptimizeM')]
		[Parameter(Mandatory, ParameterSetName='OptimizeA')][Switch]	$Optimize,
		[Parameter(ParameterSetName='OptimizeM')]
		[Parameter(ParameterSetName='OptimizeA')]
					[String]	$Nodes,
		[Parameter(ParameterSetName='OptimizeM')]
		[Parameter(ParameterSetName='OptimizeA')]			[String]	$Slots,
		[Parameter(ParameterSetName='OptimizeM')]
		[Parameter(ParameterSetName='OptimizeA')]			[String]	$Ports,
		[Parameter(ParameterSetName='OptimizeM')]
		[Parameter(ParameterSetName='OptimizeA')]			[String]	$Volume,
		[Parameter(ParameterSetName='OptimizeM')]
		[Parameter(ParameterSetName='OptimizeA')]
		[ValidateRange(1,2147483)]							[int]		$Seconds,
		[Parameter(ParameterSetName='OptimizeM')]
		[Parameter(ParameterSetName='OptimizeA')]
		[ValidateRange(0,500)]								[int]		$Itererations,
		[Parameter(ParameterSetName='OptimizeM')]
		[Parameter(ParameterSetName='OptimizeA')]
		[ValidateRange(1,6000)]								[int]		$Frequency,
		[Parameter(ParameterSetName='OptimizeA')]
		[Parameter(ParameterSetName='OptimizeM')]			[switch]	$Volumelayout,
		[Parameter(ParameterSetName='OptimizeA')]
		[Parameter(ParameterSetName='OptimizeM')]			[switch]	$Portstat,
		[Parameter(ParameterSetName='OptimizeA')]
		[Parameter(ParameterSetName='OptimizeM')]			[switch]	$Pdstat,
		[Parameter(ParameterSetName='OptimizeA')]
		[Parameter(ParameterSetName='OptimizeM')]			[switch]	$Chstat,
		[Parameter(ParameterSetName='OptimizeA')]
		[Parameter(ParameterSetName='OptimizeM')]			[String]	$Maxpd,
		[Parameter(Mandatory)]
		[ValidateSet('auto','manual')]						[switch]	$Movech,
		[Parameter(Mandatory, ParameterSetName='OptimizeM')][String]	$MaxSvct,
		[Parameter(Mandatory, ParameterSetName='OptimizeA')][String]	$AvgSvct
)	
Begin	
	{   Test-A9Connection -ClientType 'SshClient' 
	}
Process
	{	switch($PSCmdlet.ParameterSetName)
			{	'Allocate'	{	$cmd = "setpd ldalloc $Ldalloc $PD_ID " 
							}
				'Spinup'	{	$Cmd = "controlpd spinup $wwn"
							}
				'Spindown'	{	$Cmd = "controlpd spindown"
								if( $Force )		{	$Cmd += " -ovrd " }
								$Cmd += " $WWN "
							}
				'Approve'	{	$cmd = "admitpd -f  "
								if ( $Nold )		{	$cmd+=" -nold "	}
								if ( $SkipPatch )	{	$cmd+=" -nopatch " }
								if ( $wwn )			{	$cmd += " $wwn"	}
							}
				'Scrub'		{	$cmd = "checkpd scrub "
								if ( $ch )			{	$cmd +=" -ch $ch "		}
								if ( $count )		{	$cmd +=" -count $count "}		
							}	
				'Diag'		{	$cmd = "checkpd diag "
								if ( $path )		{	$cmd +=" -path $path "		}		
								if ( $test )		{	$cmd +=" -test $test "		}
								if ( $iosize )		{	$cmd +=" -iosize $iosize "	}
								if ( $range )		{	$cmd +=" -range $range "	}
								if ( $threads )		{	$cmd +=" -threads $threads "}
								if ( $time )		{	$cmd +=" -time $time "		}
								if ( $total )		{	$cmd +=" -total $total "	}
								if ( $retry )		{	$cmd +=" -retry $retry "	}
							}	
				'OptimizeM'	{	$Cmd = " tunepd "
								if($Nodes)			{	$Cmd += " -nodes $Nodes "		}
								if($Slots)			{	$Cmd += " -slots $Slots "		}
								if($Ports)			{	$Cmd += " -ports $Ports "		}
								if($Volume)			{	$Cmd += " -vv $Volume "		} 
								if($Seconds)		{	$Cmd += " -d $Seconds "			}
								if($Iterations)		{	$Cmd += " -iter $Itererations "	} 
								if($Frequency)		{	$Cmd += " -freq $Frequency "	}
								if($Volumelayout)	{	$Cmd += " -vvlayout "			}		
								if($Portstat)		{	$Cmd += " -portstat"			}
								if($Pdstat)			{	$Cmd += " -pdstat" 				}
								if($Chstat)			{	$Cmd += " -chstat" 				}
								if($Maxpd)			{	$Cmd += " -maxpd $Maxpd " 		}
								if($Movech)			{	$Cmd += " -movech $Movech " 	}
								$Cmd += " maxSvct $MaxSvct "
							}
				'OptimizeA'	{	$Cmd = " tunepd "
								if($Nodes)			{	$Cmd += " -nodes $Nodes "		}
								if($Slots)			{	$Cmd += " -slots $Slots "		}
								if($Ports)			{	$Cmd += " -ports $Ports "		}
								if($Volume)			{	$Cmd += " -vv $Volume "		} 
								if($Seconds)		{	$Cmd += " -d $Seconds "			}
								if($Iterations)		{	$Cmd += " -iter $Itererations "	} 
								if($Frequency)		{	$Cmd += " -freq $Frequency "	}
								if($Volumelayout)	{	$Cmd += " -vvlayout "			}		
								if($Portstat)		{	$Cmd += " -portstat"			}
								if($Pdstat)			{	$Cmd += " -pdstat" 				}
								if($Chstat)			{	$Cmd += " -chstat" 				}
								if($Maxpd)			{	$Cmd += " -maxpd $Maxpd " 		}
								if($Movech)			{	$Cmd += " -movech $Movech " 	}
								$Cmd += " avgsvct $AvgSvct "
							}
			}
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}

Function Set-A9LogicalDisk
{
<#
.SYNOPSIS
	Perform validity checks of data on logical disks (LD), or The command consolidates space on the LDs.
.DESCRIPTION
	The command executes consistency checks of data on Logical Disks in the event of an uncontrolled 
	system shutdown and optionally repairs inconsistent Logical Disks.
	The command can also be used to start data services on a Logical DIsk that has not yet been started.
	Alternativly it can consolidates space on the LDs.
.PARAMETER FixError
	Specifies that if errors are found they are fixed instead of the default behaviour which is to only report.
.PARAMETER Progress
	Poll the system manager to get ldck report.
.PARAMETER Recover
	Attempt to recover the chunklet specified by giving physical disk (<pdid>) and the chunklet's position on 
	that disk (<pdch>). The format will look like PhysicalDiskID:PhysicalDiskChunklet i.e. 1032:10
.PARAMETER RAIDSet
	Check only the specified RAID set. You must supply the RAID set number
.PARAMETER Consolidate
	This option consolidates regions into the fewest possible LDs. When this option is not specified, the regions of each LD will be compacted within the same LD.
.PARAMETER Taskname
	Specifies a name for the task. When not specified, a default name is chosen.
.PARAMETER Trimonly
	Only unused LD space is removed. Regions are not moved.
.PARAMETER LogicalDiskName
	Requests that the integrity of a specified LD is checked.
	Using the -recover option allows one LD only
.PARAMETER StartLogicalDisk
	used to start data services on a Logical DIsk that has not yet been started.
.PARAMETER Override
	Specifies that the Logical is forced to start, even if some underlying data is missing.
.NOTES
	This command utilizes the SSH command 'CheckLd', 'StartLD', 'CompactPD'	
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]										[String]	$LogicalDiskName,
		# Confirm	
		[Parameter(mandatory,parametersetname='Confirmfix')]		[switch]	$FixError,
		[Parameter(mandatory,parametersetname='Confirmreport')]		[switch]	$Progress,
		[Parameter(mandatory,parametersetname='Confirmrecover')]	[String]	$Recover,
		[Parameter(parametersetname='Confirmfix')]
		[Parameter(parametersetname='Confirmreport')]
		[Parameter(parametersetname='Confirmrecover')]				[String]	$RAIDSet,
		#compress
		[Parameter(ParameterSetName='Compactcons',mandatory)]		[switch]	$Consolidate,
		[Parameter(ParameterSetName='Compactcons')]
		[Parameter(ParameterSetName='Compacttrim')]					[String]	$Taskname,
		[Parameter(parametersetname='Compacttrim',mandatory)]		[switch]	$Trimonly,
		# Start
		[Parameter(ParameterSetName='Start')]						[switch]	$Override,
		[Parameter(mandatory, ParameterSetName='Start')]			[switch]	$StartLogicalDisk
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
PROCESS
{	switch -wildcard ($PSCmdlet.ParameterSetName)
		{	"Confirm*"
						{	$Cmd = " checkld "
							if($FixError) 		{	$Cmd += " -y " }
							else				{	$Cmd += " -n " }
							if($Progress)		{	$Cmd += " -progress " }
							if($Recover)		{	$Cmd += " -y -recover $Recover " }
							if($RAIDSet)		{	$Cmd += " -rs $Rs " }
							if($LogicalDiskName)		{	$Cmd += " $LogicalDiskName "}
							$Result = Invoke-A9CLICommand -cmds  $Cmd
							Return $Result
						}
			"Compact*"	
						{	$Cmd = " compactld -f "
							if ( $Taskname )	{	$Cmd += " -taskname $Taskname " }					
							if ( $Consolidate )	{	$Cmd += " -cons " 				}
							if ( $TrimOnly )	{	$Cmd += " -trimonly " 	}
							$Cmd += " $LD_Name "
							

						}
			"Start*"	{	$Cmd = " startld "
							if($Override)	{	$Cmd += " -ovrd " }
							$Cmd += " $LD_Name "
							$Result = Invoke-A9CLICommand -cmds  $Cmd
							Return $Result
						}
		}
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
.PARAMETER LogicalDiskName
	Requests that information for a specified LD is displayed. This specifier can be repeated to display configuration information about multiple LDs. 
	If not specified, configuration information for all LDs in the system is displayed.
.PARAMETER Cpg
	Requests that only LDs in common provisioning groups (CPGs) that match the specified CPG names or patterns be displayed. Multiple CPG names or
	patterns can be repeated using a comma-separated list .
.PARAMETER Volume	
	Requests that only LDs mapped to virtual volumes that match and of the specified names or patterns be displayed. Multiple volume names or
	patterns can be repeated using a comma-separated list .
.PARAMETER Degraded
	Only shows LDs with degraded availability.
.PARAMETER Detailed
	Requests that more detailed layout information is displayed.
.PARAMETER CheckLogicalDisk
	Requests that checkld information is displayed.
.PARAMETER Policy
	Requests that policy information about the LD is displayed.
.PARAMETER State
	Requests that the detailed state information is displayed.
.PARAMETER LogicalDiskFormat
	Shows the logical disk's row and set layout on the physical disk, where the line format <form> is one of:
		row—One line per logical disk row.
		set—One line per logical disk set.
.PARAMETER LogicalDiskInfo
	Specifies the information shown for each logical disk chunklet, where <info> can be one of:
		pdpos—Shows the physical disk position (default).
		pdid—Shows the physical disk ID.
		pdch—Shows the physical disk chunklet.
	If multiple <info> fields are specified, each corresponding field will be shown separately by a dash (-).
.PARAMETER LogicalDiskChunklet
	Will force the command to return chunklet usage information instead of basic Logical Disk informatoin
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
	PS:> Get-A9LogicalDisk -Volume AzureLocalPool2

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
	This command utilizes the SSH command 'ShowLD', 'ShowLDChk'	
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='showld')]
param(	[Parameter(ParameterSetName='showld')]	[String]	$Cpg,
		[Parameter(ParameterSetName='showld')]	[String]	$Volume,
		[Parameter()]							[switch]	$Degraded,
		[Parameter(ParameterSetName='showld')]	[switch]	$Detailed,
		[Parameter(ParameterSetName='showld')]	[switch]	$CheckLogicalDisk,
		[Parameter(ParameterSetName='showld')]	[switch]	$Policy,
		[Parameter(ParameterSetName='showld')]	[switch]	$State,
		[Parameter()]							[String]	$LogicalDiskName,
		[Parameter()]							[switch]	$ShowRaw,
		[Parameter(ParameterSetName='showldch')][ValidateSet('row','set')]				
												[String]	$LogicalDiskFormat,
		[Parameter(ParameterSetName='showldch')][ValidateSet('pdpos','pdid','pdch')]	
												[String]	$LogicalDiskInfo,
		[Parameter(Mandatory, ParameterSetName='showldch')]
												[Switch]	$LogicalDiskChunklet		
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process
{	$Cmd = $PSCmdlet.ParameterSetName + ' ' 
	switch ($PSCmdlet.ParameterSetName)
		{	'showld'
				{	if ( $Cpg )					{	$Cmd += " -cpg $Cpg "		}
					if ( $Volume )				{	$Cmd += " -vv $Volume "	}
					if ( $Domain )				{	$Cmd += " -domain $Domain "	}
					if ( $Degraded )			{	$Cmd += " -degraded " 		}
					if ( $Detailed )			{	$Cmd += " -d " 				}
					if ( $CheckLogicalDisk )	{	$Cmd += " -ck " 			}
					if ( $Policy )				{	$Cmd += " -p "				}
					if ( $LogicalDiskName )		{ 	$Cmd += " $LogicalDiskName "}
					
					
				}
			'showldch'
				{	if($Degraded)			{	$Cmd += " -degraded " 					}
					if($LogicalDiskFormat)	{	$Cmd += " -lformat $LogicalDiskFormat " }
					if($LogicalDiskInfo)	{	$Cmd += " -linfo $LogicalDiskInfo " 	}
					if($LogicalDiskName)	{	$Cmd += " $LogicalDiskName " 			}
					write-host "Command to be sent via CLI;`n`t $Cmd"
					$Result = Invoke-A9CLICommand -cmds  $Cmd
				} 
		}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if ( ($Result.count -gt 1) -and -not ($ShowRaw -or $Policy) )
		{	if ( $PSCmdlet.ParameterSetName -eq 'showld')
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
					if($Detailed )
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
			else			
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
				}
		}
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	Return $Result
} 
}

Function Remove-A9LogicalDisk
{
<#
.SYNOPSIS
	Remove logical disks .
.DESCRIPTION
	The Remove-LogicalDisk command removes a specified Logical Disks from the system service group.
.PARAMETER LogicalDiskName
	Specifies the Logical Disk name, using up to 31 characters. Multiple Logical Disks can be specified.
.PARAMETER Rmsys
	Specifies that system resource Logical Disk such as logging Logical Disks and preserved data Logical Disks are removed.
.PARAMETER Unused
	Specifies the command to remove non-system Logical Disks. This option cannot be used with the  -rmsys option.
.EXAMPLE
	PS:> Remove-A9LogicalDisk -LD_Name xxx
.NOTES
	This command utilizes the SSH command 'RemoveLD'	
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Resys')]	[switch]	$Rmsys,
		[Parameter(ParameterSetName='unused')]	[switch]	$Unused,
		[Parameter(Mandatory)]					[String]	$LogicalDiskName
		)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " removeld -f "
	if($Rmsys) 	{	$Cmd += " -rmsys " }
	if($Unused) {	$Cmd += " -unused " }
	if($LogicalDiskName){	$Cmd += " $LogicalDiskName " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}
