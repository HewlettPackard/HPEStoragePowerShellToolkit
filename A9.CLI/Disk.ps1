####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Approve-A9Disk
{
<#
.SYNOPSIS
    The command creates and admits physical disk definitions to enable the use of those disks.
.DESCRIPTION
    The command creates and admits physical disk definitions to enable the use of those disks.
.PARAMETER Nold
	Do not use the PD (as identified by the <world_wide_name> specifier) for logical disk allocation.
.PARAMETER Nopatch
	Suppresses the check for drive table update packages for new hardware enablement.
.PARAMETER wwn
	Indicates the World-Wide Name (WWN) of the physical disk to be admitted. If WWNs are specified, only the specified physical disk(s) are admitted.	
.EXAMPLE
	PS:> Approve-A9Diskk
	
	This example admits physical disks.
.EXAMPLE
	PS:> Approve-A9Diskisk -Nold
	
	Do not use the PD (as identified by the <world_wide_name> specifier) For logical disk allocation.
.EXAMPLE
	PS:> Approve-A9Disk -NoPatch
	
	Suppresses the check for drive table update packages for new hardware enablement.
.EXAMPLE  	
	PS:> Approve-A9Disk -Nold -wwn xyz

	Do not use the PD (as identified by the <world_wide_name> specifier) For logical disk allocation.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Nold,
		[Parameter()]	[switch]	$NoPatch,
		[Parameter()]	[String]	$wwn	
)	
Begin	
	{   Test-A9Connection -ClientType 'SshClient' 
	}
Process
	{	$cmd= "admitpd -f  "
		if ($Nold)		{	$cmd+=" -nold "	}
		if ($NoPatch)	{	$cmd+=" -nopatch " }
		if($wwn)		{	$cmd += " $wwn"	}
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd
		return 	$Result	
	} 
}

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
	Authority:Super, Service
		Any role granted the pd_dismiss right
	Usage:
	- Access to all domains is required to run this command.
	- A PD that is in use cannot be removed.
	- Verify the removal of a PD by issuing the Get-A9Disk command.
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
.PARAMETER ldalloc 
	Specifies that the PD, as indicated with the PD_ID specifier, is either allocatable (on) or nonallocatable for LDs (off)..PARAMETER PD_ID 
	Specifies the PD identification using an integer.	
.EXAMPLE
	PS:> Set-A9Disk -Ldalloc off -PD_ID 20	
	
	displays PD 20 marked as non allocatable for LDs.
.EXAMPLE  
	PS:> Set-A9Disk -Ldalloc on -PD_ID 25	

	displays PD 25 marked as allocatable for LDs.
.NOTES
	This command requires a SSH type connection.
	Authority:Super, Service
		Any role granted the pd_set right
	Usage:
	- Access to all domains is required to run this command.
	- This command can be used when the system has disks that are not to be used until a later time.
	- Verify the status of PDs by issuing the Get-A9Disk -state command (see the Get-A9Disk command).
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)][ValidateSet('on','off')]		[String]	$Ldalloc,	
		[Parameter(Mandatory)][ValidateRange(0,4096)]		[String]	$PD_ID
	)		
Begin	
	{   Test-A9Connection -ClientType 'SshClient' 
	}
Process
	{	$cmd= "setpd ldalloc $Ldalloc $PD_ID "
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd
			
	} 
end
	{	if([string]::IsNullOrEmpty($Result))
		{	Write-host "Success : Executing Set-PD" -ForegroundColor green 
			return $Result
		}
	else{	write-warning "FAILURE : While Executing Set-PD"
			return $Result 
		} 
	}
}

Function Switch-A9Disk
{
<#
.SYNOPSIS
	Spin up or down a physical disk (PD).
.DESCRIPTION
	The command spins a PD up or down. This command is used when replacing a PD in a drive magazine.
.PARAMETER Spinup
	Specifies that the PD is to spin up. If this subcommand is not used, then the spindown subcommand must be used.
.PARAMETER Spindown
	Specifies that the PD is to spin down. If this subcommand is not used, then the spinup subcommand must be used.
.PARAMETER Force
	Specifies that the operation is forced (override), even if the PD is in use.
.PARAMETER WWN
	Specifies the World Wide Name of the PD. This specifier can be repeated to identify multiple PDs.
.NOTES
	This command requires a SSH type connection.
	Authority:Super, Service
		Any role granted the pd_control right
	Usage:
	- Access to all domains is required to run this command.
	- The spin down operation cannot be performed on a PD that is in use unless the -force option is used.
	- Issuing the controlpd command puts the specified disk drive in a not ready state. Further, if this command is issued with the spindown subcommand, data on the specified drive becomes inaccessible.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='up',  Mandatory)]	[switch]	$Spinup,
		[Parameter(ParameterSetName='down',Mandatory)]	[switch]	$Spindown, 
		[Parameter(ParameterSetName='down')]			[switch]	$Force,	
		[Parameter(ParameterSetName='down')]
		[Parameter(ParameterSetName='up')]				[String]	$WWN
)
Begin	
	{   Test-A9Connection -ClientType 'SshClient' 
	}
Process
	{	$Cmd = " controlpd "
		if($Spinup)			{	$Cmd += " spinup " }
		elseif($Spindown)	{	$Cmd += " spindown " 
								if($Force)	{	$Cmd += " -ovrd " }
							}
		if($WWN)			{	$Cmd += " $WWN " }
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

