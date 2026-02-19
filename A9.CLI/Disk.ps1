## 	©2025 Hewlett Packard Enterprise Development LP

Function Remove-A9Disk
{
<#
.SYNOPSIS
	Remove a physical disk (PD) from system use.
.DESCRIPTION
	The command removes PD definitions from system use.
.PARAMETER PDID
	Specifies the physical disk ID, identified by integers, to be removed from system use.
.EXAMPLE
	The following example removes a PD with ID 1:

	PS:> Remove-A9Disk -PDID 1
.NOTES
	This command requires a SSH type connection.
	- A PD that is in use cannot be removed.
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

Function Set-A9Disk
{
<#
.SYNOPSIS
	Marks a Physical Disk (PD) as allocatable or non allocatable for Logical Disks (LDs).
.DESCRIPTION
	Marks a Physical Disk (PD) as allocatable or non allocatable for Logical Disks (LDs). 
	Verify the status of PDs by issuing the Get-A9Disk -state command (see the Get-A9Disk command).  
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
.EXAMPLE
	PS:> Set-A9Disk -Ldalloc off -PD_ID 20	
	
	displays PD 20 marked as non allocatable for LDs.
.EXAMPLE  
	PS:> Set-A9Disk -spinup -wwn 201524a1aabbcc3345	

	Will spinup a drive this the given WWN, you may then wish to rerun the command and make it allocatable.
.EXAMPLE  
	PS:> Set-A9Disk -spindown -wwn 201524a1aabbcc3345 -force

	Will spindown a drive this the given WWN, since the force was used, it will spin down the drive regardless if the drive is in use.
.EXAMPLE  
	PS:> Set-A9Disk -Ldalloc on -PD_ID 25	

	displays PD 25 marked as allocatable for LDs.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory, ParameterSetName='Allocate')]
		[ValidateSet('on','off')]							[String]	$Ldalloc,	
		[Parameter(Mandatory, ParameterSetName='Allocate')]	[String]	$PD_ID,
		[Parameter(ParameterSetName='Spinup',  Mandatory)]	[switch]	$Spinup,
		[Parameter(ParameterSetName='Spindown',Mandatory)]	[switch]	$Spindown, 
		[Parameter(ParameterSetName='Spindown')]			[switch]	$Force,	
		[Parameter(ParameterSetName='Spindown',mandatory)]
		[Parameter(ParameterSetName='Spinup',mandatory)]	
		[Parameter(ParameterSetName='Approve',mandatory)]	[switch]	$Approve,
		[Parameter(ParameterSetName='Approve')]				[String]	$WWN,
		[Parameter(ParameterSetName='Approve')]				[switch]	$Nold,
		[Parameter(ParameterSetName='Approve')]				[switch]	$SkipPatch
	)		
Begin	
	{   Test-A9Connection -ClientType 'SshClient' 
	}
Process
	{	switch($PSCmdlet.ParameterSetName)
			{	'Allocate'	{	$cmd= "setpd ldalloc $Ldalloc $PD_ID " 
							}
				'Spinup'	{	$Cmd = " controlpd spinup $wwn"
							}
				'Spindown'	{	$Cmd = " controlpd spindown"
								if($Force)	{	$Cmd += " -ovrd " }
								$Cmd += " $WWN "
							}
				'Approve'	{	$cmd= "admitpd -f  "
								if ($Nold)		{	$cmd+=" -nold "	}
								if ($SkipPatch)	{	$cmd+=" -nopatch " }
								if ($wwn)		{	$cmd += " $wwn"	}
							}		
			}
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result
	}
}


Function Test-A9Disk
{
<#
.SYNOPSIS
	Executes surface scans or diagnostics on physical disks.
.DESCRIPTION
    Executes surface scans or diagnostics on physical disks.	
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
.EXAMPLE
	PS:> Test-A9Disk -scrub -ch 500 -pd_ID 1

	This example Test-PD chunklet 500 on physical disk 1 is scanned for media defects.
.EXAMPLE  
	PS:> Test-A9Disk -scrub -count 150 -pd_ID 1

	This example scans a number of chunklets starting from -ch 150 on physical disk 1.
.EXAMPLE  
	PS:> Test-A9Disk -diag -path a -pd_ID 5

	This example Specifies a physical disk path as a,physical disk 5 is scanned for media defects.
.EXAMPLE  	
	PS:> Test-A9Disk -diag -iosize 1s -pd_ID 3

	This example Specifies I/O size 1s, physical disk 3 is scanned for media defects.
.EXAMPLE  	
	PS:> Test-A9Disk -diag -range 5m  -pd_ID 3

	This example Limits diagnostic to range 5m [mb] physical disk 3 is scanned for media defects.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='diag', Mandatory)]	[switch]	$Diag,		
		[Parameter(ParameterSetName='scrub',Mandatory)]	[switch]	$Scrub,		
		[Parameter(ParameterSetName='Scrub')]			[int]		$ch,		
		[Parameter(ParameterSetName='Scrub')]			[int]		$count,
		[Parameter(ParameterSetName='diag')]
		[ValidateSet('a','b','system','both')]			[String]	$path,		
		[Parameter(ParameterSetName='diag')]
		[ValidateSet('read','write','validate')]		[String]	$test,	
		[Parameter(ParameterSetName='diag')]			[String]	$iosize,	
		[Parameter(ParameterSetName='diag')]			[String]	$range,		
		[Parameter(ParameterSetName='diag')]			[String]	$threads,	
		[Parameter(ParameterSetName='diag')]			[String]	$time,		
		[Parameter(ParameterSetName='diag')]			[String]	$total,		
		[Parameter(ParameterSetName='diag')]			[String]	$retry,		
		[Parameter(ParameterSetName='diag',Mandatory)]	[String]	$pd_ID
	)		
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	if ( $scrub)
		{	$cmd="checkpd scrub "
			if ($ch)		{	$cmd +=" -ch $ch "		}
			if ($count)		{	$cmd +=" -count $count "}		
		}
	elseif( $diag)
		{	$cmd="checkpd diag "
			if ($path)		{	$cmd +=" -path $path "		}		
			if ($test)		{	$cmd +=" -test $test "		}
			if ($iosize)	{	$cmd +=" -iosize $iosize "	}
			if ($range )	{	$cmd +=" -range $range "	}
			if ($threads)	{	$cmd +=" -threads $threads "}
			if ($time )		{	$cmd +=" -time $time "		}
			if ($total )	{	$cmd +=" -total $total "	}
			if ($retry )	{	$cmd +=" -retry $retry "	}
		}	
	$cmd += " $pd_ID "
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	return $Result	
} 
}

