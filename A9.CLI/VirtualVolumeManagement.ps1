####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

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
.PARAMETER Pattern
	Compacts the LDs that match any of the specified patterns.
.PARAMETER Consolidate
	This option consolidates regions into the fewest possible LDs. When this option is not specified, the regions of each LD will be compacted within the same LD.
.PARAMETER Waittask
	Waits for any created tasks to complete.
.PARAMETER Taskname
	Specifies a name for the task. When not specified, a default name is chosen.
.PARAMETER DryRun
	Specifies that the operation is a dry run, and the tasks will not actually be performed.
.PARAMETER Trimonly
	Only unused LD space is removed. Regions are not moved.
.PARAMETER LD_Name
	Specifies the name of the LD to be compacted. Multiple LDs can be specified.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Pattern')]	[switch]	$Pattern,
		[Parameter()]	[switch]	$Consolidate,
		[Parameter()]	[switch]	$Waittask,
		[Parameter()]	[String]	$Taskname,
		[Parameter()]	[switch]	$DryRun,
		[Parameter()]	[switch]	$Trimonly,
		[Parameter(ParameterSetName='Name',Mandatory)]	[String]	$LD_Name
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
PROCESS
{	$Cmd = " compactld -f "
	if($Consolidate) 		{	$Cmd += " -cons " }
	if($Waittask) 	{	$Cmd += " -waittask "}
	if($Taskname)	{	$Cmd += " -taskname $Taskname " }	
	if($DryRun) 	{	$Cmd += " -dr "}
	if($Trimonly) 	{	$Cmd += " -trimonly " }
	if($Pattern)	{	$Cmd += " -pat $pat" }
	if($LD_Name)	{ 	$Cmd += " $LD_Name " }
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
	The command executes consistency checks of data on LDs in the event of an uncontrolled 
	system shutdown and optionally repairs inconsistent LDs.
.PARAMETER ModifyError
	Specifies that if errors are found they are either modified so they are valid ($true) or left 
	unmodified ($false). If not specified, errors are left unmodified ($false).
.PARAMETER Progress
	Poll sysmgr to get ldck report.
.PARAMETER Recover
	Attempt to recover the chunklet specified by giving physical disk (<pdid>) and the chunklet's position on 
	that disk (<pdch>). If this options is specified, the ModifyError option must be specified as well.
.PARAMETER RAIDSet
	Check only the specified RAID set. You must supply the RAID set number
.PARAMETER LD_Name
	Requests that the integrity of a specified LD is checked. This specifier can be repeated to execute validity checks on multiple LDs.
.NOTES
	Authority: Super, Service	
		Any role granted the ld_check right
	Usage:
	- Requires access to all domains.
	- Repairing LDs refers to making LDs consistent.
	- Defines consistency for RAID-6 as: parity is consistent with the data in the set.
	- Using the -recover option allows one LD only and requires use of the-y option.
	- Enter the checkld command on any LD, whether started or not.

	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[Boolean]	$ModifyError,
	[Parameter()]	[switch]	$Progress,
	[Parameter()]	[String]	$Recover,
	[Parameter()]	[String]	$RAIDSet,
	[Parameter(Mandatory=$True)]	[String]	$LD_Name
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
PROCESS
	{	$Cmd = " checkld "
		if($ModifyError) {	$Cmd += " -y " }
		else			{	$Cmd += " -n " }
		if($Progress)	{	$Cmd += " -progress " }
		if($Recover -and $ModifyError)	
						{	$Cmd += " -recover $Recover " }
		if($RAIDSet)	{	$Cmd += " -rs $Rs " }
		if($LD_Name)	{	$Cmd += " $LD_Name "}
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
.PARAMETER Domain
	Only shows LDs that are in domains with names that match any of the names or specified patterns. Multiple domain names or patterns can be
	repeated using a comma separated list .
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
	PS:> Get-A9LogicalDisk | format-table *

	Id  Name            RAID Detailed_State Own SizeMB UsedMB Use Lgct LgId WThru MapV
	--  ----            ---- -------------- --- ------ ------ --- ---- ---- ----- ----
	4   .mgmtdata.usr.0 6    normal         0/1 264192 262144 V   0         N     Y
	5   .mgmtdata.usr.1 6    normal         1/0 264192 262144 V   0         N     Y
	2   .srdata.usr.0   6    normal         0/1 55296  51200  V   0         N     Y
	3   .srdata.usr.1   6    normal         1/0 55296  51200  V   0         N     Y
	0   admin.usr.0     1    normal         0/1 5120   5120   V   0         N     Y
	1   admin.usr.1     1    normal         1/0 5120   5120   V   0         N     Y
	6   log0.0          1    normal         0/  20480  0      log 0         Y     N
	7   log1.0          1    normal         1/  20480  0      log 0         Y     N
	8   pdsld0.0        1    normal         0/1 1024   0      P   F    0          Y
	9   pdsld0.1        6    normal         0/1 57216  0      P   0         Y     N
	10  pdsld0.2        6    normal         1/0 53120  0      P   0         Y     N
	163 tp0sa0.3        1    normal         1/0 5120   4224   C   SA   0          N
	158 tp0sa0.5        1    normal         0/1 16384  13056  C   SA   0          N
.EXAMPLE
	PS:> (Get-A9logicalDisk -Cpg SSD_r6 ).LDForSD| ft *

	Id  Name          RAID -Detailed_State- Own     SizeMB UsedMB Use  WThru MapV
	--  ----          ---- ---------------- ---     ------ ------ ---  ----- ----
	8   tp-0-sd-0.1   6    normal           1/2/3/0 102375 8925   C,SD Y     Y
	11  tp-0-sd-0.2   6    normal           2/3/0/1 102375 7350   C,SD Y     Y
	14  tp-0-sd-0.3   6    normal           3/0/1/2 102375 5775   C,SD Y     Y
	17  tp-0-sd-0.4   6    normal           0/2/1/3 102375 8400   C,SD Y     Y
	20  tp-0-sd-0.5   6    normal           1/3/2/0 102375 8925   C,SD Y     Y
	23  tp-0-sd-0.6   6    normal           2/0/3/1 102375 8925   C,SD Y     Y
	26  tp-0-sd-0.7   6    normal           3/1/0/2 102375 6300   C,SD Y     Y
.EXAMPLE
	PS:> Get-A9logicalDisk -Cpg SSD_r6

	Name                           Value
	----                           -----
	LDForSA                        {@{Id=5; Name=tp-0-sa-0.0; RAID=1; -Detailed_State-=normal; Own=0/1/2/3; SizeMB=8192; UsedMB=5120; Use=C,SA; WThru=Y; MapV=Y}, @{Id=7; Name=tp-0-sa-0.1; RAID=1; -Detailed_State-=normal; Own=1/2/3/0; SizeMB=5120; UsedMB=5…
	LDforSD                        {@{Id=8; Name=tp-0-sd-0.1; RAID=6; -Detailed_State-=normal; Own=1/2/3/0; SizeMB=102375; UsedMB=8925; Use=C,SD; WThru=Y; MapV=Y}, @{Id=11; Name=tp-0-sd-0.2; RAID=6; -Detailed_State-=normal; Own=2/3/0/1; SizeMB=102375; Use…
.EXAMPLE
	PS:> Get-A9logicalDisk -LD_Name tp-0-sd-0.97

	Id             : 490
	Name           : tp-0-sd-0.97
	RAID           : 6
	Detailed_State : normal
	Own            : 0/1/2/3
	SizeMB         : 245700
	UsedMB         : 1575
	Use            : C,SD
	WThru          : Y
	MapV           : Y
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Cpg,
		[Parameter()]	[String]	$Vv,
		[Parameter()]	[String]	$Domain,
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
		if($State) 	{	$Cmd += " -state " }
		if($LD_Name){ 	$Cmd += " $LD_Name " }
		$Result = Invoke-A9CLICommand -cmds  $Cmd
	}
end
	{	if($ShowRaw) {	Return $Result }
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
						return $ResultFinal
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
						return $Result
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
						return $Result
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
						return $Result
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

Function Get-A9Space
{
<#
.SYNOPSIS
    Displays estimated free space for logical disk creation.
.DESCRIPTION
    Displays estimated free space for logical disk creation.
.EXAMPLE
    PS:> Get-A9Space

	Displays estimated free space for logical disk creation.
.EXAMPLE
    PS:> Get-A9Space -RaidType r1
		
	Example displays the estimated free space for a RAID-1 logical disk:
.PARAMETER cpgName
    Specifies that logical disk creation parameters are taken from CPGs that match the specified CPG
	name or pattern,Multiple CPG names or patterns can be specified using a comma separated list, for
	example cpg1,cpg2,cpg3.
.PARAMETER RaidType
	Specifies the RAID type of the logical disk: r0 for RAID-0, r1 for RAID-1, r5 for RAID-5, or r6 for
	RAID-6. If no RAID type is specified, the default is r1 for FC and SSD device types and r6 is for
	the NL device types
.PARAMETER History
	Specifies that free space history over time for CPGs specified.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	PS:> Get-A9Space -cpgName 'rancher2023'

	Name         : rancher2023
	RawFree(MiB) : 13759040
	LDFree(MiB)  : 11007232
	OPFree(MiB)  : -
	Base(MiB)    : 374784
	Snp(MiB)     : 5120
	Free(MiB)    : 13056
	Total(MiB)   : 392960
	Compact      : 7.64
	Dedup        : -
	Compress     : -
	DataReduce   : -
	Overprov     : 0.23
.EXAMPLE
	PS:> get-a9space

	RawFree  UsableFree
	-------  ----------
	55307064 43016610
.EXAMPLE
	PS:> get-a9space -cpg SSD_r6 -History | format-table *

	TimeMonth TimeDay TimeHMS  HrsAgo EstFree_RawFree EstFree_LDFree EstFree_OPFree RawFree_ReduceRatePerHour LDFree_ReduceRatePerHour Used     Free     Total    Compact Dedup Compress DataReduce Overprov
	--------- ------- -------  ------ --------------- -------------- -------------- ------------------------- ------------------------ ----     ----     -----    ------- ----- -------- ---------- --------
	Feb       08      18:39:52 0      55307064        43016610       -              -                         -                        3782100  19293225 23075325 15.63   1.01  0.04     1.18       0.62
	Feb       08      03:37:07 15     66350964        51606310       -              734017                    570902                   8864625  5017425  13882050 6.50    1.01  0.04     1.18       0.62
.EXAMPLE
	PS:> get-a9space -cpg SSD_r6 | format-table *

	CPGName EstFree_RawFree(MiB) EstFree_LDFree(MiB) EstFree_OPFree(MiB) Used(MiB) Free(MiB) Total(MiB) Compact DeDup Compress DataReduce OverProv
	------- -------------------- ------------------- ------------------- --------- --------- ---------- ------- ----- -------- ---------- --------
	SSD_r6  55307064             43016610            -                   3792600   19282725  23075325   15.53   1.01  0.04     1.18       0.62
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter(parametersetname='CPGName',Mandatory)]	[String]	$cpgName,
		[Parameter(parametersetname='CPGName')]				[Switch]	$History,
		[Parameter()]										[switch]	$ShowRaw
)
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}
process	
	{	$sysspacecmd = "showspace "
		$tempFile = [IO.Path]::GetTempFileName()
		if($cpgName)		{	$sysspacecmd += " -cpg $cpgName"	}		
		if($History)		{	$sysspacecmd += " -hist "		}
		write-Verbose "The following command will be sent via SSH `n`t$sysspacecmd"
		$Result = Invoke-A9CLICommand -cmds  $sysspacecmd
	}
end{	$tempFile = [IO.Path]::GetTempFileName()
		if ($ShowRaw) {	return $result }
		if ($Result -match "FAILURE :" -or $Result -match "ERROR :")	
			{	write-warning "FAILURE : The command reported a failure. Use the -showraw option if you wish to see the return data."	
				return
			}	
		if($History)
			{	$ResultHeader = 'TimeMonth,TimeDay,TimeHMS,HrsAgo,EstFree_RawFree,EstFree_LDFree,EstFree_OPFree,RawFree_ReduceRatePerHour,LDFree_ReduceRatePerHour,Used,Free,Total,Compact,Dedup,Compress,DataReduce,Overprov'
				$StartIndex=3
				$EndIndex=$Result.count-2	
			}		
		elseif($cpgName)
			{	if( $Result.Count -lt 4 )		{	return "$Result"	}
				$ResultHeader = 'CPGName,EstFree_RawFree(MiB),EstFree_LDFree(MiB),EstFree_OPFree(MiB),Used(MiB),Free(MiB),Total(MiB),Compact,DeDup,Compress,DataReduce,OverProv'
				$StartIndex=3
				$EndIndex=$Result.count-1		
			}		
		else
			{	$ResultHeader = (($Result[1].split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
				$StartIndex=2
				$EndIndex=$Result.count-1	
			}
		Add-Content -Path $tempFile -Value $ResultHeader
		foreach ($s in $Result[$StartIndex..$EndIndex])
			{	$s = (($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
				Add-Content -Path $tempFile -Value $s
			}
		$returndata = Import-Csv $tempFile
		Remove-Item $tempFile
		return $returndata
		
	}
}

Function Get-A9VvList
{
<#
.SYNOPSIS
    The Get-VvList command displays information about all Virtual Volumes (VVs) or a specific VV in a system. 
.DESCRIPTION
    The Get-VvList command displays information about all Virtual Volumes (VVs) or a specific VV in a system.
.PARAMETER Listcols
	List the columns available to be shown in the -showcols option described below
.PARAMETER D
	Displays detailed information about the VVs.  The following columns are shown:
	Id Name Rd Mstr Prnt Roch Rwch PPrnt PBlkRemain VV_WWN CreationTime Udid
.PARAMETER Pol
	Displays policy information about the VVs. The following columns
	are shown: Id Name Policies
.PARAMETER Space
	Displays Logical Disk (LD) space use by the VVs.  The following columns are shown:
	Id Name Prov Compr Dedup Type Adm_Rsvd_MB Adm_Used_MB Snp_Rsvd_MB Snp_Used_MB Snp_Used_Perc Warn_Snp_Perc Limit_Snp_Perc Usr_Rsvd_MB
	Usr_Used_MB Usr_Used_Perc Warn_Usr_Perc Limit_Usr_Perc Tot_Rsvd_MB Tot_Used_MB VSize_MB Host_Wrt_MB Compaction Compression

	Note: For snapshot (vcopy) VVs, the Adm_Used_MB, Snp_Used_MB, Usr_Used_MB and the corresponding _Perc columns have a '*' before
	the number for two reasons: to indicate that the number is an estimate that must be updated using the updatesnapspace command, and to indicate
	that the number is not included in the total for the column since the corresponding number for the snapshot's base VV already includes that number.
.PARAMETER RawSpace
	Displays raw space use by the VVs.  The following columns are shown: Id Name Prov Compr Dedup Type Adm_RawRsvd_MB Adm_Rsvd_MB Snp_RawRsvd_MB
	Snp_Rsvd_MB Usr_RawRsvd_MB Usr_Rsvd_MB Tot_RawRsvd_MB Tot_Rsvd_MB VSize_MB
.PARAMETER Zone
	Displays mapping zone information for VVs. The following columns are shown:
	Id Name Prov Compr Dedup Type VSize_MB Adm_Zn Adm_Free_Zn Snp_Zn Snp_Free_Zn Usr_Zn Usr_Free_Zn
.PARAMETER G
	Displays the SCSI geometry settings for the VVs.  The following columns are shown: Id Name SPT HPC SctSz
.PARAMETER Alert
	Indicates whether alerts are posted on behalf of the VVs. The following columns are shown:
	Id Name Prov Compr Dedup Type VSize_MB Snp_Used_Perc Warn_Snp_Perc Limit_Snp_Perc Usr_Used_Perc Warn_Usr_Perc Limit_Usr_Perc
	Alert_Adm_Fail_Y Alert_Snp_Fail_Y Alert_Snp_Wrn_Y Alert_Snp_Lim_Y Alert_Usr_Fail_Y Alert_Usr_Wrn_Y Alert_Usr_Lim_Y
.PARAMETER AlertTime
	Shows times when alerts were posted (when applicable). The following columns are shown:
	Id Name Alert_Adm_Fail Alert_Snp_Fail Alert_Snp_Wrn Alert_Snp_Lim Alert_Usr_Fail Alert_Usr_Wrn Alert_Usr_Lim
.PARAMETER CPProg
	Shows the physical copy and promote progress. The following columns are shown:
	Id Name Prov Compr Dedup Type CopyOf VSize_MB Copied_MB Copied_Perc
.PARAMETER CpgAlloc
	Shows CPGs associated with each VV.  The following columns are shown: Id Name Prov Compr Dedup Type UsrCPG SnpCPG
.PARAMETER State
	Shows the detailed state information for the VVs.  The following columns are shown: Id Name Prov Compr Dedup Type State Detailed_State SedState
.PARAMETER Hist
	Shows the history information of the VVs. The following columns are shown:
	Id Name Prov Compr Dedup Type CreationTime RetentionEndTime ExpirationTime SpaceCalcTime Comment
.PARAMETER RCopy
	This option appends two columns, RcopyStatus and RcopyGroup, to any of the display options above.
.PARAMETER NoTree
	Do not display VV names in tree format. Unless either the -notree or the -sortcol option described below
	are specified, the VVs are ordered and the  names are indented in tree format to indicate the virtual copy snapshot hierarchy.
.PARAMETER Expired
	Show only VVs that have expired.
.PARAMETER Retained
	Shows only VVs that have a retention time.
.PARAMETER Failed
	Shows only failed VVs.
.PARAMETER Domain
    Shows only VVs that are in domains with names matching one or more of the specified domain_name or patterns. This option does not allow
	listing objects within a domain of which the user is not a member.
.PARAMETER ShowCols 
    Explicitly select the columns to be shown using a comma-separated list of column names.  For this option the full column names are shown in the header.
    Run 'showvv -listcols' to list the available columns.
    Run 'clihelp -col showvv' for a description of each column.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	PS:> Get-A9VvList | format-table *

	Id   Name             Prov Compr Dedup Type CopyOf BsId Rd Detailed_State
	--   ----             ---- ----- ----- ---- ------ ---- -- --------------
	2    .mgmtdata        full NA    NA    base ---    2    RW normal
	2047 .shared.SSD_r6_0 dds  v2    NA    base ---    2047 RW normal
	2048 .shared.SSD_r6_1 dds  v2    NA    base ---    2048 RW normal
	2049 .shared.SSD_r6_2 dds  v2    NA    base ---    2049 RW normal

.EXAMPLE	
	PS:> Get-A9VvList -space | format-table *

	Id   Name             Prov Compr DeDupe Type Used(MiB) Rsvd(MiB) HostWr VSize
	--   ----             ---- ----- ------ ---- --------- --------- ------ -----
	2047 .shared.SSD_r6_0 dds  v2    NA     base 314       6300      --     4194304
	2048 .shared.SSD_r6_1 dds  v2    NA     base 310       8400      --     4194304
	2049 .shared.SSD_r6_2 dds  v2    NA     base 310       8400      --     4194304
.EXAMPLE	
	PS:> Get-A9VvList_CLI -showcols 'Type,Name,Dedup' | ft *

	Type Name             Dedup
	---- ----             -----
	base .mgmtdata        --
	base .shared.SSD_r6_0 --
	base .shared.SSD_r6_1 --
	base elastic-07       1.08
	base elastic-12       1.02
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='default')]
	param(
		[Parameter(parametersetname='listcols',mandatory)]	[switch]	$Listcols,
		[Parameter(parametersetname='Details')]				[switch]	$Details,
		[Parameter(parametersetname='Policy')]				[switch]	$Pol,
		[Parameter(parametersetname='Space')]				[switch]	$Space,
		[Parameter(parametersetname='RawSpace')]			[switch]	$RawSpace,
		[Parameter(parametersetname='Zone')]				[switch]	$Zone,
		[Parameter(parametersetname='Geometry')]			[switch]	$Geometry,
		[Parameter(parametersetname='Alert')]				[switch]	$Alert,
		[Parameter(parametersetname='AlertTime')]			[switch]	$AlertTime,
		[Parameter(parametersetname='CPProg')]				[switch]	$CPProg,	
		[Parameter(parametersetname='CPGAlloc')]			[switch]	$CpgAlloc,	
		[Parameter(parametersetname='State')]				[switch]	$State,	
		[Parameter(parametersetname='Hist')]				[switch]	$Hist,	
		[Parameter(parametersetname='RCopy')]				[switch]	$RCopy,	
		[Parameter(parametersetname='NoTree')]				[switch]	$NoTree,	
		[Parameter(parametersetname='default')]				[String]	$Domain,	
		[Parameter(parametersetname='default')]				[String]	$vvName,
		[Parameter()]										[String]	$ShowCols,
		[Parameter()]										[switch]	$ShowRaw
	)	
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}	
process	
	{	$GetvVolumeCmd = "showvv "
		if ($Listcols)	{	$GetvVolumeCmd += "-listcols "
							$Result = Invoke-A9CLICommand -cmds  $GetvVolumeCmd
							return $Result				
						}
		if($Details)	{	$GetvVolumeCmd += "-d "	}	
		if($Pol)		{	$GetvVolumeCmd += "-pol "	}
		if($Space)		{	$GetvVolumeCmd += "-space "	}	
		if($RawSpace)	{	$GetvVolumeCmd += "-r "	}
		if($Zone)		{	$GetvVolumeCmd += "-zone "	}
		if($Geometry)	{	$GetvVolumeCmd += "-g "	}
		if($Alert)		{	$GetvVolumeCmd += "-alert "	}
		if($AlertTime)	{	$GetvVolumeCmd += "-alerttime "	}
		if($CPProg)		{	$GetvVolumeCmd += "-cpprog "	}
		if($CpgAlloc)	{	$GetvVolumeCmd += "-cpgalloc "	}
		if($State)		{	$GetvVolumeCmd += "-state "	}
		if($Hist)		{	$GetvVolumeCmd += "-hist "	}
		if($RCopy)		{	$GetvVolumeCmd += "-rcopy "	}
		if($NoTree)		{	$GetvVolumeCmd += "-notree "	}
		if($Domain)		{	$GetvVolumeCmd += "-domain $Domain "	}
		if($ShowCols)	{	$GetvVolumeCmd += "-showcols $ShowCols "	}	
		if ($vvName)	{	$GetvVolumeCmd += " $vvName"	}
		$Result = Invoke-A9CLICommand -cmds  $GetvVolumeCmd
	}
end
	{	if ( $ShowRaw ) { return $Result }
		if($Result -match "no vv listed")	
			{	write-warning "FAILURE : No Results found. To see details choose the ShowRaw Option."
				return
			}
		if ( $Result.Count -gt 1)
			{	if ( $hist ) { return $result }
				$tempFile = [IO.Path]::GetTempFileName()
				if ($Pol )
					{	$CustomHeader = (($Result[0].split(' ')).trim()).trim('-') | where-object { $_ -ne '' }
						foreach ($s in  $Result[1..($Result.count-3)] )
							{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join 'Z'
								Add-Content -Path $tempFile -Value $s
							}
						$returndata = Import-Csv -Delimiter "Z" -header $CustomHeader $tempFile
						Remove-Item $tempFile
						return $returndata
					}
				if ($PSBoundParameters.count -lt 1 -or $Geometry -or $CPProg -or $CPGAlloc -or $state -or $rcopy -or $NoTree -or $vvName -or $ShowCols)
					{	$s = ( (($Result[0].split(' ')).trim() ).trim('-') | where-object { $_ -ne '' } ) -join ','
						$StartIndex=1
						$EndIndex=$Result.count-3
					}
				if ($Details)
					{	$s = 'Id,Name,Rd,Mstr,Prnt,Roch,Rwch,PPrnt,SPrnt,PBlkRemain,VV_WWN,CreationMonth,CreationDat,CreationTime,Udid'
						$StartIndex=1
						$EndIndex=$Result.count-3
					}
				if ($Zone)
					{	$s = 'Id,Prov,Compr,DeDupe,Type,VVSize(MiB),Zn(adm),Free_Zn(Adm),Zn(Data),Free_Zn(Data)'
						$StartIndex=2
						$EndIndex=$Result.count-3
					}
				if ($Alert)
					{	$s = @('Id,Name,Prov,Compr,DeDupe,Type,VVSize(MiB),Rsvd(%VSize),Wrn(%VSize),Lim(VSize),Fail(Adm(Alerts)),Fail(Data(Alerts)),Wrn(Data(Alerts)),Lim(Data(Alerts))')
						$StartIndex=3
						$EndIndex=$Result.count-3
					}
				if ($AlertTime)
					{	$s = ( @('Id','Name','Fasl(adm(AlertTime)','Fail(Data(AlertTime))','Wrn(Data(AlertTIme))','Lim(Data(AlertTime))') ) -join ','
						$StartIndex=3
						$EndIndex=$Result.count-3
					}
				if ($Space)
					{	$s = 'Id,Name,Prov,Compr,DeDupe,Type,Used(MiB),Rsvd(MiB),HostWr,VSize,Used(%VSize),Wrn(%VSize),Lim(%VSize),Used(MiB(Branch)),VSize(MiB(Branch)),Used(%VSize(Branch)),Compact(Efficiency),Compress(Efficiency)'
						$StartIndex=4
						$EndIndex=$Result.count-3
					}
				if ($RawSpace)
					{	$s = ((($Result[1].split(' ')).trim()).trim('-') | where-object { $_ -ne '' } ) -join ','
						$StartIndex=2
						$EndIndex=$Result.count-3
					}
				Add-Content -Path $tempFile -Value $s
				foreach ($s in  $Result[$StartIndex..$EndIndex] )
					{	$s = (($s.split(' ')).trim() | where-object { $_ -ne '' }) -join ','
						Add-Content -Path $tempFile -Value $s
					}
				$returndata = Import-Csv $tempFile
				Remove-Item $tempFile
				return $returndata
			}	
		else{	write-warning "FAILURE : No Results found"
				return $result	
			}	
	}
}

Function Get-A9VvSet
{
<#
.SYNOPSIS
    Get list of Virtual Volume(VV) sets defined on the storage system and their members
.DESCRIPTION
    Get lists of Virtual Volume(VV) sets defined on the storage system and their members
.PARAMETER vvSetName 
    Specify name of the vvset to be listed.
.PARAMETER Detailed
	Show a more detailed listing of each set.
.PARAMETER VV
	Show VV sets that contain the supplied vvnames or patterns
.PARAMETER Summary
	Shows VV sets with summarized output with VV sets names and number of VVs in those sets
.PARAMETER vvName 
    Specifies that the sets containing virtual volumes.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 	
.EXAMPLE
	PS:> Get-A9VvSet | format-table
	Cmdlet executed successfully

	id uuid                                 name              setmembers                                          count vvolStorageContainerEnabled qosEnabled
	-- ----                                 ----              ----------                                          ----- --------------------------- ----------
	1 51d61280-2ef2-4fdc-88a5-9e1b4b0d97a7 vvset_dscc-test    {dscc-test}                                          1                       False      False
	5 2f00cefc-b14d-4098-a9c9-d4cd6cbcb044 vvset_Oradata1     {MySQLData}                                          1                       False      False
	7 b8f1a3e6-81ff-47da-887f-5fd529427789 AppSet_SAP_HANA    {HANA_data, HANA_log, HANA_shared, Veeam_datastore}  4                       False      False
.EXAMPLE
	PS:> Get-A9VvSet_CLI -vvname vvsnodes

	Id Name     Members
	-- ----     -------
	27 vvsnodes elastic-01
	27 vvsnodes elastic-02
	27 vvsnodes elastic-03
	27 vvsnodes elastic-04
.NOTES
	This command requires a SSH type connection
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[switch]	$VV,
		[Parameter()]	[switch]	$Summary,
		[Parameter(parametersetname='vvset',mandatory)]	[String]	$vvSetName,
		[Parameter(parametersetname='vvname',mandatory)]	[String]	$vvName,
		[Parameter()]	[Switch]	$ShowRaw
	)	
Begin
	{	Test-A9Connection -ClientType 'SshClient'
	}	
process
	{	$GetVVSetCmd = "showvvset "
		if ($Detailed)	{	$GetVVSetCmd += " -d "	}
		if ($VV)		{	$GetVVSetCmd += " -vv "	}
		if ($Summary)	{	$GetVVSetCmd += " -summary "	}	
		if ($vvSetName)	{	$GetVVSetCmd += " $vvSetName"	}
		elseif($vvName)	{	$GetVVSetCmd += " $vvName"	}
		else			{	write-verbose "VVSet parameter $vvSetName is empty. Simply return all existing vvset " 			}	
		$Result = Invoke-A9CLICommand -cmds  $GetVVSetCmd
	}
end
	{	if($ShowRaw)	{	Return $Result }
		if($Result -match "No vv set listed")	{	return "FAILURE : No vv set listed"	}
		if($Result -match "total" -and $Detailed )
			{	$tempFile = [IO.Path]::GetTempFileName()
				$s = ( (($Result[0].split(' ')).trim() ).trim('-') | where-object { $_ -ne '' } ) -join ','
				Add-Content -Path $tempFile -Value $s
				$LastItem = $Result.Count -3
				foreach ($s in  $Result[1..$LastItem] )
					{	$s = ( ($s.split(' ')).trim()  | where-object { $_ -ne '' } ) 
						if ($s.count -eq 1)	
							{	$TempFullLine = $FullLine
								$TempFullLine[2] = $s
								$s = $TempFullLine -join ',' 
							}
						else{	$FullLine = $s
								$s = $s -join ','
							}
						Add-Content -Path $tempFile -Value $s
					}
				$returndata = Import-Csv $tempFile 
				Remove-Item $tempFile
				return $returndata
			}
		
		elseif($Result -match "total" )
			{	$tempFile = [IO.Path]::GetTempFileName()
				$s = ( (($Result[0].split(' ')).trim() ).trim('-') | where-object { $_ -ne '' } ) -join ','
				Add-Content -Path $tempFile -Value $s
				$LastItem = $Result.Count -3
				foreach ($s in  $Result[1..$LastItem] )
					{	$s = ( ($s.split(' ')).trim() )| where-object { $_ -ne '' } 
						if ($s.count -eq 1)	
							{	$s=$FullLine[0]+','+$FullLine[1]+','+$s 
							}
						else{	$FullLine = $s
								$s = $s -join ','
							}
						Add-Content -Path $tempFile -Value $s
					}
				$returndata = Import-Csv $tempFile 
				Remove-Item $tempFile
				return $returndata
			}
		else{	return $Result	}		
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

Function New-A9Vv_CLI
{
<#
.SYNOPSIS
    Creates a vitual volume.
.DESCRIPTION
	Creates a vitual volume. `e[3mThis text is italic`e[0m

.PARAMETER vvName 
    Specify new name of the virtual volume
.PARAMETER Size 
    Specify the size of the new virtual volume. Valid input is: 1 for 1 MB , 1g or 1G for 1GB , 1t or 1T for 1TB
.PARAMETER CPGName
    Specify the name of CPG
.PARAMETER Template
	Use the options defined in template <tname>.  
.PARAMETER Volume_ID
	Specifies the ID of the volume. By default, the next available ID is chosen.
.PARAMETER Count
	Specifies the number of identical VVs to create. 
.PARAMETER Shared
	Specifies that the system will try to share the logical disks among the VVs. 
.PARAMETER Wait
	If the command would fail due to the lack of clean space, the -wait
.PARAMETER vvSetName
    Specify the name of a volume set. If it does not exist, the command will also create new volume set.
.PARAMETER minalloc	
	This option specifies the default allocation size (in MB) to be set
.PARAMETER Snp_aw
	Enables a snapshot space allocation warning. A warning alert is generated when the reserved snapshot space of the VV exceeds the indicated percentage of the VV size.
.PARAMETER Snp_al
	Sets a snapshot space allocation limit. The snapshot space of the VV is prevented from growing beyond the indicated percentage of the virtual volume size.
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the volume.
.PARAMETER tdvv
	Deprecated. Should use -dedup.
.PARAMETER tpvv
	Specifies that the volume should be a thinly provisioned volume.
.PARAMETER snp_cpg 
	Specifies the name of the CPG from which the snapshot space will be allocated.
.PARAMETER sectors_per_track
	Defines the virtual volume geometry sectors per track value that is reported to the hosts through the SCSI mode pages. The valid range is
	between 4 to 8192 and the default value is 304.
.PARAMETER minalloc 
	This option specifies the default allocation size (in MB) to be set. Allocation size specified should be at least (number-of-nodes * 256) and
	less than the CPG grow size.
.PARAMETER heads_per_cylinder
	Allows you to define the virtual volume geometry heads per cylinder value that is reported to the hosts though the SCSI mode pages. The
	valid range is between 1 to 255 and the default value is 8.
.PARAMETER snp_aw
	Enables a snapshot space allocation warning. A warning alert is generated when the reserved snapshot space of the VV exceeds the indicated percentage of the VV size.
.PARAMETER snp_al
	Sets a snapshot space allocation limit. The snapshot space of the VV is prevented from growing beyond the indicated
	percentage of the virtual volume size.
.EXAMPLE	
	PS:> New-A9Vv_CLI
.EXAMPLE
	PS:> New-A9Vv_CLI -vvName AVV
.EXAMPLE
	PS:> New-A9Vv_CLI -vvName AVV -CPGName ACPG
.EXAMPLE
	PS:> New-A9Vv_CLI -vvName XX -CPGName ZZ
.EXAMPLE
	PS:> New-A9Vv_CLI -vvName AVV -CPGName ZZ
.EXAMPLE
	PS:> New-A9Vv_CLI -vvName AVV1 -CPGName ZZ -Force
.EXAMPLE
	PS:> New-A9Vv_CLI -vvName AVV -CPGName ZZ -Force -tpvv
.EXAMPLE
	PS:> New-A9Vv_CLI -vvName AVV -CPGName ZZ -Force -Template Test_Template
.EXAMPLE
    PS:> New-A9Vv_CLI -vvName PassThru-Disk -Size 100g -CPGName HV -vvSetName MyVolumeSet

	The command creates a new volume named PassThru-disk of size 100GB.
	The volume is created under the HV CPG group and will be contained inside the MyvolumeSet volume set.
	If MyvolumeSet does not exist, the command creates a new volume set.	
.EXAMPLE
    PS:> New-A9Vv_CLI -vvName PassThru-Disk1 -Size 100g -CPGName MyCPG -tpvv -minalloc 2048 -vvSetName MyVolumeSet 
	
	The command creates a new thin provision volume named PassThru-disk1 of size 100GB.
	The volume is created under the MyCPG CPG group and will be contained inside the MyvolumeSet volume set. If MyvolumeSet does not exist, the command creates a new volume set and allocates minimum 2048MB.
.NOTES
	This command requires a SSH type connection.
	`e[3m This is italicized
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]			[String]	$vvName,
		[Parameter()]	[String]	$Size="1G", 	# Default is 1GB
		[Parameter(Mandatory)]	[String]    $CPGName,		
		[Parameter()]	[String]    $vvSetName,
		[Parameter()]	[String]    $Template,
		[Parameter()]	[String]    $Volume_ID,
		[Parameter()]	[String]    $Count,
		[Parameter()]	[String]    $Wait,
		[Parameter()]	[String]    $Comment,
		[Parameter()]	[Switch]	$Shared,
		[Parameter()]	[Switch]	$tpvv,
		[Parameter()]	[Switch]	$tdvv,
		[Parameter()]	[Switch]	$Snp_Cpg,
		[Parameter()]	[String]    $Sectors_per_track,
		[Parameter()]	[String]    $Heads_per_cylinder,
		[Parameter()]	[String]    $minAlloc,
		[Parameter()]	[String]    $Snp_aw,
		[Parameter()]	[String]    $Snp_al
	)	
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{	if ( !( Test-A9CLIObject -objectType 'cpg' -objectName $CPGName -SANConnection $SANConnection))
		{	write-verbose " CPG $CPGName does not exist. Please use New-CPG to create a CPG before creating vv"  
			return "FAILURE : No cpg $cpgName found"
		}		
	## Check vv Name . Create if necessary
	if (Test-A9CLIObject -objectType 'vv' -objectName $vvName -SANConnection $SANConnection)
		{	write-verbose " virtual Volume $vvName already exists. No action is required"
			return "FAILURE : vv $vvName already exists"
		}			
	$CreateVVCmd = "createvv -f "
	if ($minAlloc)
		{	if(!($tpvv))	{	return "FAILURE : -minalloc optiong should not use without -tpvv"	}
		}					
	if ($tpvv)
		{	$CreateVVCmd += " -tpvv "
			if ($minAlloc)
				{	$ps3parbuild = Get-Version -S -SANConnection $SANConnection
					if($ps3parbuild -ge "3.2.1" -Or $ps3parbuild -ge "3.1.1")
						{	$CreateVVCmd += " -minalloc $minAlloc"
						}
					else
						{	return "FAILURE : -minalloc option not supported in the OS version: $ps3parbuild"
						}
				}
		}
	if($tdvv)	{	$CreateVVCmd +=" -tdvv "	}
	if($Template){	$CreateVVCmd +=" -templ $Template "	}
	if($Volume_ID){	$CreateVVCmd +=" -i $Volume_ID "	}
	if($Count)
		{	$CreateVVCmd +=" -cnt $Count "
			if($Shared)
				{	if(!($tpvv))	{	$CreateVVCmd +=" -shared "	}
				}
		}
	if($Wait)
		{	if(!($tpvv))	{	$CreateVVCmd +=" -wait $Wait "	}
		}
	if($Comment)			{	$CreateVVCmd +=" -comment $Comment "	}
	if($Sectors_per_track)	{	$CreateVVCmd +=" -spt $Sectors_per_track "	}
	if($Heads_per_cylinder)	{	$CreateVVCmd +=" -hpc $Heads_per_cylinder "}
	if($Snp_Cpg)			{	$CreateVVCmd +=" -snp_cpg $CPGName "}
	if($Snp_aw)				{	$CreateVVCmd +=" -snp_aw $Snp_aw "	}
	if($Snp_al)				{	$CreateVVCmd +=" -snp_al $Snp_al "	}
	$CreateVVCmd +=" $CPGName $vvName $Size"			
	$Result1 = $Result2 = $Result3 = ""
	$Result1 = Invoke-A9CLICommand -cmds  $CreateVVCmd
	#write-host "Result = ",$Result1
	if([string]::IsNullOrEmpty($Result1))
		{	$successmsg += "Success : Created vv $vvName"
		}
	else
		{	$failuremsg += "FAILURE : While creating vv $vvName"
		}
	write-verbose " Creating Virtual Name with the command --> $CreatevvCmd"  
	# If VolumeSet is specified then add vv to existing Volume Set
	if ($vvSetName)
		{	## Check vvSet Name 
			if ( !( Test-A9CLIObject -objectType 'vv set' -objectName $vvSetName -SANConnection $SANConnection))
				{	write-verbose " Volume Set $vvSetName does not exist. Use New-vVolumeSet to create a Volume set before creating vLUN"  
					$CreatevvSetCmd = "createvvset $vvSetName"
					$Result2 =Invoke-A9CLICommand -cmds  $CreatevvSetCmd
					if([string]::IsNullOrEmpty($Result2))
						{	$successmsg += "Success : Created vvset $vvSetName"
						}
					else
						{	$failuremsg += "FAILURE : While creating vvset $vvSetName"					
						}
					write-verbose " Creating Volume set with the command --> $CreatevvSetCmd" 
				}
			$AddVVCmd = "createvvset -add $vvSetName $vvName" 	## Add vv to existing Volume set
			$Result3 = Invoke-A9CLICommand -cmds  $AddVVCmd
			if([string]::IsNullOrEmpty($Result3))
				{	$successmsg += "Success : vv $vvName added to vvset $vvSetName"
				}
			else
				{	$failuremsg += "FAILURE : While adding vv $vvName to vvset $vvSetName"					
				}					
			write-verbose " Adding vv to Volume set with the command --> $AddvvCmd"
		}
	if(([string]::IsNullOrEmpty($Result1)) -and ([string]::IsNullOrEmpty($Result2)) -and ([string]::IsNullOrEmpty($Result3)))
		{	return $successmsg 
		}
	else
		{	return $failuremsg
		}			 
}
}

Function New-A9VvSet_CLI
{
<#
.SYNOPSIS
    Creates a new VolumeSet 
.DESCRIPTION
	Creates a new VolumeSet
.PARAMETER vvSetName 
    Specify new name of the VolumeSet
.PARAMETER Domain 
    Specify the domain where the Volume set will reside
.PARAMETER vvName 
    Specify the VV  to add  to the Volume set 
.PARAMETER Comment 
    Specifies any comment or additional information for the set.	
.PARAMETER Count
	Add a sequence of <num> VVs starting with "vvname". vvname should be of the format <basename>.<int>
	For each VV in the sequence, the .<int> suffix of the vvname is incremented by 1.
.PARAMETER Add 
	Specifies that the VVs listed should be added to an existing set. At least one VV must be specified.	
.EXAMPLE
    PS:> New-A9VvSet_CLI -vvSetName "MyVolumeSet"  

	Creates a VolumeSet named MyVolumeSet
.EXAMPLE	
	PS:> New-A9VvSet_CLI -vvSetName "MYVolumeSet" -Domain MyDomain

	Creates a VolumeSet named MyVolumeSet in the domain MyDomain
.EXAMPLE
	PS:> New-A9VvSet_CLI -vvSetName "MYVolumeSet" -Domain MyDomain -vvName "MyVV"

	Creates a VolumeSet named MyVolumeSet in the domain MyDomain and adds VV "MyVV" to that vvset
.EXAMPLE
	PS:> New-A9VvSet_CLI -vvSetName "MYVolumeSet" -vvName "MyVV"

	adds vv "MyVV"  to existing vvset "MyVolumeSet" if vvset exist, if not it will create vvset and adds vv to vvset
.EXAMPLE
	PS:> New-A9VvSet_CLI -vvSetName asVVset2 -vvName "as4 as5 as6"
.EXAMPLE
	PS:> New-A9VvSet_CLI -vvSetName set:asVVset3 -Add -vvName as3
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]			[String]	$vvSetName,
		[Parameter()]	[switch]	$Add,
		[Parameter()]	[String]	$Count,
		[Parameter()]	[String]	$Comment,
		[Parameter()]	[String]	$Domain,		
		[Parameter()]	[String]	$vvName
	)	
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$CreateVolumeSetCmd = "createvvset "
	if($Add) 	{	$CreateVolumeSetCmd += " -add "				}
	if($Count) 	{	$CreateVolumeSetCmd += " -cnt $Count "		}
	if($Comment){	$CreateVolumeSetCmd += " -comment $Comment "}
	if($Domain) {	$CreateVolumeSetCmd += " -domain $Domain "	}
	if($vvSetName){	$CreateVolumeSetCmd += " $vvSetName "		}
	if($vvName)	{	$CreateVolumeSetCmd += " $vvName "			}
	$Result = Invoke-A9CLICommand -cmds  $CreateVolumeSetCmd
	if($Add)
		{	if([string]::IsNullOrEmpty($Result))
				{	return "Success : command executed vv : $vvName is added to vvSet : $vvSetName"
				}
			else{	return $Result	}
		}	
	else
	{	if([string]::IsNullOrEmpty($Result))
		{	return "Success :  command executed vvSet : $vvSetName is created with vv : $vvName"
		}
		else
		{	return $Result
		}			
	}		
	
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

Function Set-A9Template_CLI
{
<#
.SYNOPSIS
	Add, modify or remove template properties
.DESCRIPTION
	The Set Template command modifies the properties of existing templates.
.PARAMETER Option_Value
	Indicates the specified options and their values (if any) are added to an existing template. The specified option replaces the existing option
	in the template. For valid options, refer to createtemplate command.
.PARAMETER Template_Name
	Specifies the name of the template to be modified, using up to 31 characters.
.PARAMETER Remove
	Indicates that the option(s) that follow -remove are removed from the
	existing template. When specifying an option for removal, do not specify
	the option's value. For valid options, refer to createtemplate command.
.EXAMPLE
	In the following example, template vvtemp1 is modified to support the
	availability of data should a drive magazine fail (mag) and to use the
	the stale_ss policy:

	PS:> Set-A9Template_CLI -Option_Value " -ha mag -pol stale_ss v" -Template_Name vtemp1
.EXAMPLE 
	In the following example, the -nrw and -ha mag options are added to the
	template template1, and the -t option is removed:

	PS:> Set-A9Template_CLI -Option_Value "-nrw -ha mag -remove -t" -Template_Name template1
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$True)]	[String]	$Option_Value,
		[Parameter(Mandatory=$True)]	[String]	$Template_Name,
		[Parameter()]					[String]	$Remove
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " settemplate -f "
	if($Remove)			{	$Cmd += " -remove $Remove "	}
	if($Option_Value)	{	$Cmd += " $Option_Value " }
	if($Template_Name)	{ 	$Cmd += " $Template_Name " }
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
.PARAMETER Pattern
	Remove the snapshot administration and snapshot data spaces from all the virtual volumes that match any of the specified glob-style patterns.
.PARAMETER VV_Name
	Specifies the virtual volume name, using up to 31 characters.
.EXAMPLE
	PS:> Set-A9VvSpace_CLI -VV_Name xxx
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]					[switch]	$Pattern,
		[Parameter(Mandatory=$True)]	[String]	$VV_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " freespace -f "
	if($Pattern)	{	$Cmd += " -pat "}
	if($VV_Name)	{	$Cmd += " $VV_Name "}
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
	Specifies the logical disk name.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	The following example displays the region of logical disk v0.usr.0 that is used for a virtual volume: 
	
	PS:> Show-A9LdMappingToVvs_CLI -LD_Name v0.usr.0
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

Function Show-A9Template
{
<#
.SYNOPSIS
	Show templates.
.DESCRIPTION
	The command displays existing templates that can be used for Virtual Volume (VV), Logical Disk (LD) Common Provisioning Group (CPG) creation.
.PARAMETER T
	Specifies that the template type displayed is a VV, LD, or CPG template.
.PARAMETER Fit
	Specifies that the properties of the template is displayed to fit within 80 character lines.
.PARAMETER Template_name_or_pattern
	Specifies the name of a template, using up to 31 characters or glob-style pattern for matching multiple template names. If not specified, all templates are displayed.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$T,
		[Parameter()]	[switch]	$Fit,
		[Parameter()]	[String]	$Template_name_or_pattern,
		[Parameter()]	[switch]	$ShowRaw
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process 
{	$Cmd = " showtemplate "
	if($T)	{	$Val = "vv","cpg" ,"ld"
				if($Val -eq $T.ToLower())
					{	$Cmd += " -t $T "	}
				else{	return " Illegal template type LDA, must be either vv,cpg or ld "	}
			}
	if($Fit) 						{	$Cmd += " -fit " }
	if($Template_name_or_pattern) 	{	$Cmd += " $Template_name_or_pattern " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
}
End
{	if($Result.count -gt 1 -and (-not $ShowRaw) -and (-not ($Result -match "SYNTAX")))
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count				
			foreach ($S in  $Result[0..($Result.count-1)] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempfile -Value $s				
				}
			$result = Import-Csv $tempFile 
			Remove-Item $tempFile	
		}
	Return  $Result	
}
}

Function Show-A9VvMappedToPD
{
<#
.SYNOPSIS
	Show which virtual volumes are mapped to a physical disk (or a chunklet in that physical disk).
.DESCRIPTION
	The command displays the virtual volumes that are mapped to a particular physical disk.
.EXAMPLE
	PS:> Show-A9VvMappedToPD_CLI -PD_ID 4
.PARAMETER PD_ID
	Specifies the physical disk ID using an integer. This specifier is not required if -p option is used, otherwise it must be used at least once on the command line.
.PARAMETER Sum
	Shows number of chunklets used by virtual volumes for different space types for each physical disk.
.PARAMETER P
	Specifies a pattern to select <PD_ID> disks. The following arguments can be specified as patterns for this option: An item is specified as an integer, a comma-separated list of integers,
	or a range of integers specified from low to high.
.PARAMETER Nd
	Specifies one or more nodes. Nodes are identified by one or more integers (item). Multiple nodes are separated with a single comma
	(e.g. 1,2,3). A range of nodes is separated with a hyphen (e.g. 0-7). The primary path of the disks must be on the specified node(s).
.PARAMETER St
	Specifies one or more PCI slots. Slots are identified by one or more integers (item). Multiple slots are separated with a single comma
	(e.g. 1,2,3). A range of slots is separated with a hyphen (e.g. 0-7). The primary path of the disks must be on the specified PCI slot(s).
.PARAMETER Pt
	Specifies one or more ports. Ports are identified by one or more integers (item). Multiple ports are separated with a single comma
	(e.g. 1,2,3). A range of ports is separated with a hyphen (e.g. 0-4). The primary path of the disks must be on the specified port(s).
.PARAMETER Cg
	Specifies one or more drive cages. Drive cages are identified by one or more integers (item). Multiple drive cages are separated with a
	single comma (e.g. 1,2,3). A range of drive cages is separated with a hyphen (e.g. 0-3). The specified drive cage(s) must contain disks.
.PARAMETER Mg
	Specifies one or more drive magazines. The "1." or "0." displayed in the CagePos column of showpd output indicating the side of the
	cage is omitted when using the -mg option. Drive magazines are identified by one or more integers (item). Multiple drive magazines
	are separated with a single comma (e.g. 1,2,3). A range of drive magazines is separated with a hyphen(e.g. 0-7). The specified drive
	magazine(s) must contain disks.
.PARAMETER Pn
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers (item). Multiple
	disk positions are separated with a single comma(e.g. 1,2,3). A range of disk positions is separated with a hyphen(e.g. 0-3). The
	specified position(s) must contain disks.
.PARAMETER Dk
	Specifies one or more physical disks. Disks are identified by one or more integers(item). Multiple disks are separated with a single
	comma (e.g. 1,2,3). A range of disks is separated with a hyphen(e.g. 0-3).  Disks must match the specified ID(s).
.PARAMETER Tc_gt
	Specifies that physical disks with total chunklets greater than the number specified be selected.
.PARAMETER Tc_lt
	Specifies that physical disks with total chunklets less than the number specified be selected.
.PARAMETER Fc_gt
	Specifies that physical disks with free chunklets greater than the number specified be selected.
.PARAMETER Fc_lt
	Specifies that physical disks with free chunklets less than the	number specified be selected.
.PARAMETER Devid
	Specifies that physical disks identified by their models be selected. Models can be specified in a comma-separated list.
	Models can be displayed by issuing the "showpd -i" command.
.PARAMETER Devtype
	Specifies that physical disks must have the specified device type (FC for Fast Class, NL for Nearline, SSD for Solid State Drive)
	to be used. Device types can be displayed by issuing the "showpd" command.
.PARAMETER Rpm
	Drives must be of the specified relative performance metric, as shown in the "RPM" column of the "showpd" command. 
	The number does not represent a rotational speed for the drives without spinning media (SSD). It is meant as a rough estimation of
	the performance difference between the drive and the other drives in the system.  For FC and NL drives, the number corresponds to
	both a performance measure and actual rotational speed. For SSD drives, the number is to be treated as a relative performance
	benchmark that takes into account I/O's per second, bandwidth and access time.
	Disks that satisfy all of the specified characteristics are used. For example -p -fc_gt 60 -fc_lt 230 -nd 2 specifies all the disks that
	have greater than 60 and less than 230 free chunklets and that are connected to node 2 through their primary path.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc:Sort in increasing order (default).
		dec:Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted
	by values in later columns.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	PS:> Show-A9VvMappedToPD_CLI -Sum -PD_ID 4
.EXAMPLE
	PS:> Show-A9VvMappedToPD_CLI -P -Nd 1 -PD_ID 4
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[switch]	$Sum,
	[Parameter()]	[switch]	$P,
	[Parameter()]	[String]	$Nd,
	[Parameter()]	[String]	$St,
	[Parameter()]	[String]	$Pt,
	[Parameter()]	[String]	$Cg,
	[Parameter()]	[String]	$Mg,
	[Parameter()]	[String]	$Pn,
	[Parameter()]	[String]	$Dk,
	[Parameter()]	[String]	$Tc_gt,
	[Parameter()]	[String]	$Tc_lt,
	[Parameter()]	[String]	$Fc_gt,
	[Parameter()]	[String]	$Fc_lt,
	[Parameter()]	[String]	$Devid,
	[Parameter()]	[String]	$Devtype,
	[Parameter()]	[String]	$Rpm,
	[Parameter()]	[String]	$Sortcol,
	[Parameter()]	[String]	$PD_ID,
	[Parameter()]	[switch]	$ShowRaw
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{ 	$Cmd = " showpdvv "
	if($Sum)		{	$Cmd += " -sum "		 		}
	if($P)			{	$Cmd += " -p "					}
	if($Nd)			{	$Cmd += " -nd $Nd " 			}
	if($St)			{	$Cmd += " -st $St "				}
	if($Pt)			{	$Cmd += " -pt $Pt "				}
	if($Cg)			{	$Cmd += " -cg $Cg "				}
	if($Mg)			{	$Cmd += " -mg $Mg "				}
	if($Pn)			{	$Cmd += " -pn $Pn "				}
	if($Dk) 		{	$Cmd += " -dk $Dk " 			}
	if($Tc_gt)		{	$Cmd += " -tc_gt $Tc_gt "		}
	if($Tc_lt)		{	$Cmd += " -tc_lt $Tc_lt "		}
	if($Fc_gt)		{	$Cmd += " -fc_gt $Fc_gt "		}
	if($Fc_lt)		{	$Cmd += " -fc_lt $Fc_lt " 		}
	if($Devid) 		{	$Cmd += " -devid $Devid " 		}
	if($Devtype)	{	$Cmd += " -devtype $Devtype " 	}
	if($Rpm) 		{	$Cmd += " -rpm $Rpm " 			}
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol " 	}
	if($PD_ID) 		{	$Cmd += " PD_ID "			 	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1 -and (-not $ShowRaw) -and ( -not $Result -match "SYNTAX" ) )
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

Function Show-A9VvMapping
{
<#
.SYNOPSIS
	Show mapping from the virtual volume to logical disks.
.DESCRIPTION
	The command displays information about how virtual volume regions are mapped to logical disks.
.PARAMETER VV_Name
	The virtual volume name.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$True)]	[String]	$VV_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showvvmap "
	if($VV_Name)	{	$Cmd += " $VV_Name "}
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
	The command displays virtual volume (VV) distribution across physical disks (PD). Use Get-A9VVList to obtain the name which is the VV_name
.PARAMETER VV_Name
	Specifies the virtual volume with the specified name (31 character maximum) or matches the glob-style pattern for which information is
	displayed. This specifier can be repeated to display configuration information about multiple virtual volumes. This specifier is not
	required. If not specified, configuration information for all virtual volumes in the system is displayed.
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc : Sort in increasing order (default).
		dec : Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted by values in later columns.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	PS:> Show-A9VvpDistribution_CLI -VV_Name Zertobm9 | format-table

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
param(	[Parameter()]	[String]	$Sortcol,
		[Parameter()]	[String]	$VV_Name,
		[Parameter()]	[switch]	$ShowRaw
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showvvpd "
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol " }
	if($VV_Name) 	{	$Cmd += " $VV_Name " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1 -and (-not $ShowRaw) -and (-not ($Result -match "SYNTAX" ) ))
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			foreach ($S in  $Result[0..$LastItem] )
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempfile -Value $s				
				}
			$Result = Import-Csv $tempFile 
			remove-item $tempFile	
		}
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
param(	[Parameter()]					[switch]	$Override,
		[Parameter(Mandatory)]	[String]	$LD_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{ 	$Cmd = " startld "
	if($Override)	{	$Cmd += " -ovrd " }
	if($LD_Name) 	{	$Cmd += " $LD_Name " }
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
		[Parameter(Mandatory=$True)][String]	$VV_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " startvv "
	if($Override)	{	$Cmd += " -ovrd "	}
	if($VV_Name)	{	$Cmd += " $VV_Name "	}
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
	If none are specified, all VVs will be updated.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$VV_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " updatesnapspace "
	if($VV_Name)	{	$Cmd += " $VV_Name " }
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
.PARAMETER Name
	Specifies that the name of the virtual volume be changed to a new name (as indicated by the <new_name> specifier) that uses up to 31 characters.
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
.PARAMETER Exp
	Specifies the relative time from the current time that volume will expire. <time> is a positive integer value and in the range of 1 minute - 1825 days. 
	Time can be specified in days, hours, or minutes.  Use "d" or "D" for days, "h" or "H" for hours, or "m" or "M" for minutes following the entered time value.
	To remove the expiration time for the volume, enter 0 for <time>.
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the volume. Use -comment "" to remove the comments.
.PARAMETER Retain
	Specifies the amount of time, relative to the current time, that the volume will be retained. <time> is a positive integer value and in the
	range of 1 minute - 1825 days. Time can be specified in days, hours, or minutes.  Use "d" or "D" for days, "h" or "H" for hours, or "m" or "M"
	for minutes following the entered time value.	
	Note: If the volume is not in any domain, then its retention time cannot exceed the value of the system's VVRetentionTimeMax. The default
	value for the system's VVRetentionTimeMax is 14 days. If the volume belongs to a domain, then its retention time cannot exceed the value of
	the domain's VVRetentionTimeMax, if set. The retention time cannot be removed or reduced once it is set. If the volume has its retention time
	set, it cannot be removed within its retention time. If both expiration time and retention time are specified, then the retention time cannot
	be longer than the expiration time. This option requires the Virtual Lock license. Contact your
	local service provider for more information.
.PARAMETER Pol
	Specifies the following policies that the created virtual volume follows.
.PARAMETER Snp_cpg
	Specifies that the volume snapshot space is to be provisioned from the specified CPG. If no snp_cpg is currently defined, 
	or no snapshots exist for the volume, the snp_cpg may be set to any CPG.
.PARAMETER Snp_aw
	Enables a snapshot space allocation warning. A warning alert is generated when the reserved snapshot space of the VV exceeds the indicated percentage of the VV size.
.PARAMETER Snp_al
	Sets a snapshot space allocation limit. The snapshot space of the VV is prevented from growing beyond the indicated  percentage of the virtual volume size.
	The following options can only be used on thinly provisioned volumes:
.PARAMETER Usr_aw
	This option enables user space allocation warning. Generates a warning alert when the user data space of the TPVV exceeds the specified
	percentage of the virtual volume size.
.PARAMETER Usr_al
	Indicates the user space allocation limit. The user space of the TPVV is prevented from growing beyond the indicated percentage of the virtual
	volume size. After this limit is reached, any new writes to the virtual volume will fail.
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
	Use the command to change the name:
	
	PS:> Update-A9VvProperties_CLI setvv -name newtest test
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
param(	[Parameter()]	[String]	$Name,
		[Parameter()]	[String]	$Wwn,
		[Parameter()]	[String]	$Udid,
		[Parameter()]	[switch]	$Clrrsv,
		[Parameter()]	[switch]	$Clralua,
		[Parameter()]	[String]	$Exp,
		[Parameter()]	[String]	$Comment,
		[Parameter()]	[String]	$Retain,
		[Parameter()]	[String]	$Pol,
		[Parameter()]	[String]	$Snp_cpg,
		[Parameter()]	[String]	$Snp_aw,
		[Parameter()]	[String]	$Snp_al,
		[Parameter()]	[String]	$Usr_aw,
		[Parameter()]	[String]	$Usr_al,
		[Parameter()]	[String]	$Spt,
		[Parameter()]	[String]	$Hpc,
		[Parameter(Mandatory=$True)]	[String]	$Vvname
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " setvv -f "
	if($Name)		{	$Cmd += " -name $Name " 	}
	if($Wwn)		{	$Cmd += " -wwn $Wwn " 		}
	if($Udid)		{	$Cmd += " -udid $Udid " 	}
	if($Clrrsv)		{	$Cmd += " -clrrsv " 		}
	if($Clralua)	{	$Cmd += " -clralua " 		}
	if($Exp) 		{	$Cmd += " -exp $Exp " 		}
	if($Comment)	{	$Cmd += " -comment $Comment "}
	if($Retain)		{	$Cmd += " -retain $Retain " }
	if($Pol) 		{	$Cmd += " -pol $Pol " 		}
	if($Snp_cpg)	{	$Cmd += " -snp_cpg $Snp_cpg "}
	if($Snp_aw) 	{	$Cmd += " -snp_aw $Snp_aw " }
	if($Snp_al)		{	$Cmd += " -snp_al $Snp_al " }
	if($Usr_aw)		{	$Cmd += " -usr_aw $Usr_aw "	}
	if($Usr_al)		{	$Cmd += " -usr_al $Usr_al " }
	if($Spt)		{	$Cmd += " -spt $Spt " 		}
	if($Hpc)		{	$Cmd += " -hpc $Hpc " 		}
	if($Pol)		{	$Cmd += " -pol $Pol " 		}
	if($Vvname) 	{	$Cmd += " $Vvname " 		}
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

Function Set-A9Host_CLI
{
<#
.SYNOPSIS
    Add WWN or iSCSI name to an existing host.
.DESCRIPTION
	Add WWN or iSCSI name to an existing host.
.PARAMETER hostName
    Name of an existing host
.PARAMETER Address
    Specify the list of WWNs for the new host
.PARAMETER iSCSI
    If present, the address provided is an iSCSI address instead of WWN
.PARAMETER Add
	Add the specified WWN(s) or iscsi_name(s) to an existing host (at least one WWN or iscsi_name must be specified).  Do not specify host persona.
.PARAMETER Domain <domain | domain_set>
	Create the host in the specified domain or domain set.
.PARAMETER Loc <location>
	Specifies the host's location.
.PARAMETER  IP <IP address>
	Specifies the host's IP address.
.PARAMETER  OS <OS>
	Specifies the operating system running on the host.
.PARAMETER Model <model>
	Specifies the host's model.
.PARAMETER  Contact <contact>
	Specifies the host's owner and contact information.
.PARAMETER  Comment <comment>
	Specifies any additional information for the host.
.PARAMETER  Persona <hostpersonaval>
	Sets the host persona that specifies the personality for all ports which are part of the host set.  
.EXAMPLE
    PS:> Set-A9Host_CLI -hostName HV01A -Address  10000000C97B142E, 10000000C97B142F
	Adds WWN 10000000C97B142E, 0000000C97B142F to host HV01A
.EXAMPLE	
	PS:> Set-A9Host_CLI -hostName HV01B  -iSCSI:$true -Address  iqn.1991-06.com.microsoft:dt-391-xp.hq.3par.com
	Adds iSCSI  iqn.1991-06.com.microsoft:dt-391-xp.hq.3par.com to host HV01B
.EXAMPLE
    PS:> Set-A9Host_CLI -hostName HV01A  -Domain D_Aslam
.EXAMPLE
    PS:> Set-A9Host_CLI -hostName HV01A  -Add
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]		[String]	$hostName,		
		[Parameter()][String[]]	$Address,
		[Parameter()][Switch]    $iSCSI=$false,
		[Parameter()][Switch]    $Add,
		[Parameter()][String[]]  $Domain,
		[Parameter()][String[]]	$Loc,
		[Parameter()][String[]]	$IP,
		[Parameter()][String[]]	$OS,
		[Parameter()][String[]]	$Model,
		[Parameter()][String[]]	$Contact,
		[Parameter()][String[]]	$Comment,
		[Parameter()][String[]]	$Persona		
)		
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
process
{	$SetHostCmd = "createhost -f "			 
	if ($iSCSI)			{ 	$SetHostCmd +=" -iscsi "	}
	if($Add)			{	$SetHostCmd +=" -add "		}
	if($Domain)			{	$SetHostCmd +=" -domain $Domain"}
	if($Loc)			{	$SetHostCmd +=" -loc $Loc"	}
	if($Persona)		{	$SetHostCmd +=" -persona $Persona"	}
	if($IP)				{	$SetHostCmd +=" -ip $IP"}
	if($OS)				{	$SetHostCmd +=" -os $OS"	}
	if($Model)			{	$SetHostCmd +=" -model $Model"	}
	if($Contact)		{	$SetHostCmd +=" -contact $Contact"	}
	if($Comment)		{	$SetHostCmd +=" -comment $Comment"	}	
	$Addr = [string]$Address
	$SetHostCmd +=" $hostName $Addr"
	$Result1 = Invoke-A9CLICommand -cmds  $SetHostCmd
	write-verbose " Setting  Host with the command --> $SetHostCmd" 
	if([string]::IsNullOrEmpty($Result1))
		{	return "Success : Set host $hostName with Optn_Iscsi $Optn_Iscsi $Addr "
		}
	else
		{	return $Result1
		}			
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

Function Resize-A9Vv_CLI
{
<#
.SYNOPSIS
	Consolidate space in virtual volumes (VVs). (HIDDEN)
.PARAMETER VVName
	Specifies the name of the VV.
.PARAMETER PAT
	Compacts VVs that match any of the specified patterns. This option must be used if the pattern specifier is used.
.EXAMPLE
	VVName testv
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$VVName,
		[Parameter()]	[switch]	$Pattern
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
PROCESS
	{	$Cmd = " compactvv -f "
		if($Pattern){	$Cmd += " -pat "	}
		if($VVName)	{	$Cmd += " $VVName " }
		$Result = Invoke-A9CLICommand -cmds  $Cmd
		Return $Result 
	}
}

