﻿####################################################################################
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
.EXAMPLE
	PS:> Add-Vv -VV_WWN  migvv.0:50002AC00037001A

	Specifies the local name that should be given to the volume being admitted and Specifies the World Wide Name (WWN) of the remote volumes to be admitted.
.EXAMPLE
	PS:> Add-A9Vv -VV_WWN  "migvv.0:50002AC00037001A migvv.1:50002AC00047001A"
.EXAMPLE
	PS:> Add-A9Vv -DomainName XYZ -VV_WWN X:Y

	Create the admitted volume in the specified domain. The default is to create it in the current domain, or no domain if the current domain is not set.
.PARAMETER DomainName
	Create the admitted volume in the specified domain   
.PARAMETER VV_WWN
	Specifies the World Wide Name (WWN) of the remote volumes to be admitted.
.PARAMETER VV_WWN_NewWWN 
	Specifies the World Wide Name (WWN) for the local copy of the remote volume. If the keyword "auto" is specified the system automatically generates a WWN for the virtual volume
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName="wwn")]							
		[Parameter(ParameterSetName="wwn")]						[String]	$DomainName ,
		[Parameter(Mandatory=$true, ParameterSetName="WWN")]	[String]	$VV_WWN ,
		[Parameter(Mandatory=$true, ParameterSetName="New")]	[String] 	$VV_WWN_NewWWN
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
process	
{	if($VV_WWN -Or $VV_WWN_NewWWN)
	{	$cmd = "admitvv"
		if($DomainName)	{	$Cmd+= " -domain $DomainName"	}		
		if($VV_WWN)	
			{	$cmd += " $VV_WWN"
				$Result = Invoke-A9CLICommand -cmds  $cmd
				return  "$Result"
			}
		if($VV_WWN_NewWWN)	
			{	$cmd += " $VV_WWN_NewWWN"
				$Result = Invoke-A9CLICommand -cmds  $cmd
				return  $Result
			}		
	}
} 
}

Function Compress-A9LogicalDisk
{
<#
.SYNOPSIS
	Consolidate space in logical disks (LD).
.DESCRIPTION
	The command consolidates space on the LDs.
.PARAMETER Pat
	Compacts the LDs that match any of the specified patterns.
.PARAMETER Cons
	This option consolidates regions into the fewest possible LDs. When this option is not specified, the regions of each LD will be compacted within the same LD.
.PARAMETER Waittask
	Waits for any created tasks to complete.
.PARAMETER Taskname
	Specifies a name for the task. When not specified, a default name is chosen.
.PARAMETER Dr
	Specifies that the operation is a dry run, and the tasks will not actually be performed.
.PARAMETER Trimonly
	Only unused LD space is removed. Regions are not moved.
.PARAMETER LD_Name
	Specifies the name of the LD to be compacted. Multiple LDs can be specified.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Pat,
		[Parameter()]	[switch]	$Cons,
		[Parameter()]	[switch]	$Waittask,
		[Parameter()]	[String]	$Taskname,
		[Parameter()]	[switch]	$Dr,
		[Parameter()]	[switch]	$Trimonly,
		[Parameter(Mandatory=$True)]	[String]	$LD_Name
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
PROCESS
{	$Cmd = " compactld -f "
	if($Pat)		{	$Cmd += " -pat " }
	if($Cons) 		{	$Cmd += " -cons " }
	if($Waittask) 	{	$Cmd += " -waittask "}
	if($Taskname)	{	$Cmd += " -taskname $Taskname " }	
	if($Dr) 		{	$Cmd += " -dr "}
	if($Trimonly) 	{	$Cmd += " -trimonly " }
	if($LD_Name)	{ $Cmd += " $LD_Name " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Find-A9LogicalDisk
{
<#
.SYNOPSIS
	Perform validity checks of data on logical disks (LD).
.DESCRIPTION
	The command executes consistency checks of data on LDs
	in the event of an uncontrolled system shutdown and optionally repairs
	inconsistent LDs.
.PARAMETER Y
	Specifies that if errors are found they are either modified so they are
	valid (-y) or left unmodified (-n). If not specified, errors are left
	unmodified (-n).
.PARAMETER N
	Specifies that if errors are found they are either modified so they are
	valid (-y) or left unmodified (-n). If not specified, errors are left
	unmodified (-n).
.PARAMETER Progress
	Poll sysmgr to get ldck report.
.PARAMETER Recover
	Attempt to recover the chunklet specified by giving physical disk (<pdid>) and the chunklet's position on that disk (<pdch>). If this options is
	specified, -y must be specified as well.
.PARAMETER Rs
	Check only the specified RAID set.
.PARAMETER LD_Name
	Requests that the integrity of a specified LD is checked. This specifier can be repeated to execute validity checks on multiple LDs.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[switch]	$Y,
	[Parameter()]	[switch]	$N,
	[Parameter()]	[switch]	$Progress,
	[Parameter()]	[String]	$Recover,
	[Parameter()]	[String]	$Rs,
	[Parameter(Mandatory=$True)]	[String]	$LD_Name
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
PROCESS
{	$Cmd = " checkld "
	if($Y) 		{	$Cmd += " -y " }
	if($N)		{	$Cmd += " -n " }
	if($Progress){	$Cmd += " -progress " }
	if($Recover){	$Cmd += " -recover $Recover " }
	if($Rs)		{	$Cmd += " -rs $Rs " }
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
.PARAMETER Sortcol
	Sorts command output based on column number (<col>). Columns are numbered from left to right, beginning with 0. At least one column must
	be specified. In addition, the direction of sorting (<dir>) can be specified as follows:
		inc: Sort in increasing order (default).
		dec: Sort in decreasing order.
	Multiple columns can be specified and separated by a colon (:). Rows with the same information in them as earlier columns will be sorted
	by values in later columns.
.PARAMETER D
	Requests that more detailed layout information is displayed.
.PARAMETER Ck
	Requests that checkld information is displayed.
.PARAMETER P
	Requests that policy information about the LD is displayed.
.PARAMETER State
	Requests that the detailed state information is displayed.	This is the same as s.
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Cpg,
		[Parameter()]	[String]	$Vv,
		[Parameter()]	[String]	$Domain,
		[Parameter()]	[switch]	$Degraded,
		[Parameter()]	[String]	$Sortcol,
		[Parameter()]	[switch]	$D,
		[Parameter()]	[switch]	$Ck,
		[Parameter()]	[switch]	$P,
		[Parameter()]	[switch]	$State,
		[Parameter()]	[String]	$LD_Name
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
	if($Sortcol){	$Cmd += " -sortcol $Sortcol " }
	if($D)		{	$Cmd += " -d " }
	if($Ck)		{	$Cmd += " -ck " }
	if($P)		{	$Cmd += " -p "	}
	if($State) 	{	$Cmd += " -state " }
	if($LD_Name){ 	$Cmd += " $LD_Name " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	if($Cpg)	{	Return  $Result	}
	else
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count - 3   
			foreach ($S in  $Result[0..$LastItem] )
			{	$s= [regex]::Replace($s,"^ ","")			
				$s= [regex]::Replace($s,"^ ","")
				$s= [regex]::Replace($s,"^ ","")			
				$s= [regex]::Replace($s,"^ ","")		
				$s= [regex]::Replace($s," +",",")			
				$s= [regex]::Replace($s,"-","")			
				$s= $s.Trim()			
				Add-Content -Path $tempfile -Value $s				
			}
			$Result = Import-Csv $tempFile 
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
param(	[Parameter()]	[switch]	$Degraded,
		[Parameter()]	[String]	$Lformat,
		[Parameter()]	[String]	$Linfo,
		[Parameter()]	[String]	$LD_Name,
		[Parameter()]	[Switch]	$WhatIf

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
	if($WhatIf)		{ 	write-host "Command to be sent via CLI`n $Cmd"; return }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count - 3 
			$FristCount = 0
			if($Lformat -Or $Linfo)	{	$FristCount = 1	}
			foreach ($S in  $Result[$FristCount..$LastItem] )
			{	$s= [regex]::Replace($s,"^ ","")			
				$s= [regex]::Replace($s,"^ ","")
				$s= [regex]::Replace($s,"^ ","")			
				$s= [regex]::Replace($s,"^ ","")		
				$s= [regex]::Replace($s," +",",")			
				$s= $s.Trim()			
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
.PARAMETER Cage 
	Specifies one or more drive cages. Drive cages are identified by one or more integers (item).
	Multiple drive cages are separated with a single comma (1,2,3). A range of drive cages is
	separated with a hyphen (0–3). The specified drive cage(s) must contain disks.
.PARAMETER Disk
	Specifies one or more disks. Disks are identified by one or more integers (item). Multiple disks
	are separated with a single comma (1,2,3). A range of disks is separated with a hyphen (0–3).
	Disks must match the specified ID(s).
.PARAMETER History
	Specifies that free space history over time for CPGs specified
.PARAMETER SSZ
	Specifies the set size in terms of chunklets.
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='CPGName')]
param(	[Parameter(ValueFromPipeline=$true,parametersetname='CPGName')]	[String]	$cpgName,
		[Parameter(ValueFromPipeline=$true,parametersetname='RaidType')]
		[ValidateSet('r0','r1','r5','r6')]								[String]	$RaidType,
		[Parameter(ValueFromPipeline=$true,parametersetname='Cage')]	[String]	$Cage,
		[Parameter(ValueFromPipeline=$true,parametersetname='Disk')]	[String]	$Disk,
		[Parameter(ValueFromPipeline=$true,parametersetname='History')]	[Switch]	$History,
		[Parameter(ValueFromPipeline=$true,parametersetname='SSZ')]		
		[ValidateRange(0,65536)]										[String]	$SSZ
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{	$sysspacecmd = "showspace "
	$sysinfo = @{}	
	if($cpgName)
		{	$sysspacecmd += " -cpg $cpgName"
			$Result = Invoke-A9CLICommand -cmds  $sysspacecmd
			if ($Result -match "FAILURE :")	{	return "FAILURE : no CPGs found or matched"	}
			if( $Result -match "There is no free space information")	{	return "FAILURE : There is no free space information"		}
			if( $Result.Count -lt 4 )		{	return "$Result"	}
			$tempFile = [IO.Path]::GetTempFileName()
			$3parosver = Get-A9Version -S 
			$incre = "true" 
			foreach ($s in  $Result[2..$Result.Count] )
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +"," ")
					$s= [regex]::Replace($s," ",",")
					if($3parosver -eq "3.1.1")	{	$s= $s.Trim() -replace 'Name,RawFree,LDFree,Total,Used,Total,Used,Total,Used','CPG_Name,EstFree_RawFree(MB),EstFree_LDFree(MB),Usr_Total(MB),Usr_Used(MB),Snp_Total(MB),Snp_Used(MB),Adm_Total(MB),Adm_Used(MB)'	}
					if($3parosver -eq "3.1.2")	{	$s= $s.Trim() -replace 'Name,RawFree,LDFree,Total,Used,Total,Used,Total,Used','CPG_Name,EstFree_RawFree(MB),EstFree_LDFree(MB),Usr_Total(MB),Usr_Used(MB),Snp_Total(MB),Snp_Used(MB),Adm_Total(MB),Adm_Used(MB)' 	}
					else						{	$s= $s.Trim() -replace 'Name,RawFree,LDFree,Total,Used,Total,Used,Total,Used,Compaction,Dedup','CPG_Name,EstFree_RawFree(MB),EstFree_LDFree(MB),Usr_Total(MB),Usr_Used(MB),Snp_Total(MB),Snp_Used(MB),Adm_Total(MB),Adm_Used(MB),Compaction,Dedup'	}
					if($incre -eq "true")
						{	$sTemp = $s.Split(',')							
							$sTemp[1]="RawFree(MiB)"				
							$sTemp[2]="LDFree(MiB)"
							$sTemp[3]="OPFree(MiB)"				
							$sTemp[4]="Base(MiB)"
							$sTemp[5]="Snp(MiB)"				
							$sTemp[6]="Free(MiB)"
							$sTemp[7]="Total(MiB)"		
							$newTemp= [regex]::Replace($sTemp,"^ ","")			
							$newTemp= [regex]::Replace($sTemp," ",",")				
							$newTemp= $newTemp.Trim()
							$s=$newTemp							
						}			
					Add-Content -Path $tempFile -Value $s
					$incre="false"
				}		
			Import-Csv $tempFile
			Remove-Item $tempFile
			return
		}		
	if($RaidType)
		{	$RaidType = $RaidType.toLower()
			$sysspacecmd += " -t $RaidType"
			foreach ($s in $Result[2..$Result.count])
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")
					$s = $s.split(",")
					$sysinfo.add("RawFree(MB)",$s[0])
					$sysinfo.add("UsableFree(MB)",$s[1])
					$sysinfo
				}
			return
		}
	if($Cage)
		{	if(($RaidType) -or ($cpgName) -or($Disk))	{	return "FAILURE : Use only One parameter at a time."	}
			$sysspacecmd += " -p -cg $Cage"
			$Result = Invoke-A9CLICommand -cmds  $sysspacecmd
			if ($Result -match "Illegal pattern integer or range")	{	return "FAILURE : $Result "	}
			foreach ($s in $Result[2..$Result.count])
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")
					$s = $s.split(",")
					$sysinfo.add("RawFree(MB)",$s[0])
					$sysinfo.add("UsableFree(MB)",$s[1])
					$sysinfo
				}
			return
		}
	if($Disk)
		{	$sysspacecmd += "-p -dk $Disk"
			$Result = Invoke-A9CLICommand -cmds  $sysspacecmd
			if ($Result -match "Illegal pattern integer or range")	{	return "FAILURE : Illegal pattern integer or range: $Disk"	}
			foreach ($s in $Result[2..$Result.count])
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")
					$s = $s.split(",")
					$sysinfo.add("RawFree(MB)",$s[0])
					$sysinfo.add("UsableFree(MB)",$s[1])
					$sysinfo
				}
		}
	if($History)
		{	$sysspacecmd += " -hist "
		}
	if($SSZ)
	{	$sysspacecmd += " -ssz $SSZ "
		$Result = Invoke-A9CLICommand -cmds  $sysspacecmd
		if ($Result -match "Invalid setsize")
			{	return "FAILURE : $Result"
			}		
		foreach ($s in $Result[2..$Result.count])
			{	$s= [regex]::Replace($s,"^ +","")
				$s= [regex]::Replace($s," +",",")
				$s = $s.split(",")
				$sysinfo.add("RawFree(MB)",$s[0])
				$sysinfo.add("UsableFree(MB)",$s[1])
				$sysinfo
			}
		return
	}
	if(-not(( ($Disk) -or ($Cage)) -or (($RaidType) -or ($cpg))))
		{	$Result = Invoke-A9CLICommand -cmds  $sysspacecmd
			if ($Result -match "Illegal pattern integer or range")
				{	return "FAILURE : Illegal pattern integer or range: $Disk"
				}
			foreach ($s in $Result[2..$Result.count])
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")
					$s = $s.split(",")
					$sysinfo.add("RawFree(MB)",$s[0])
					$sysinfo.add("UsableFree(MB)",$s[1])
					$sysinfo
				}
		}
}
}


Function Get-A9VvList_CLI
{
<#
.SYNOPSIS
    The Get-VvList command displays information about all Virtual Volumes (VVs) or a specific VV in a system. 
.DESCRIPTION
    The Get-VvList command displays information about all Virtual Volumes (VVs) or a specific VV in a system.
.EXAMPLE
    PS:> Get-A9VvList_CLI

	List all virtual volumes
.EXAMPLE	
	PS:> Get-A9VvList_CLI -vvName xyz 

	List virtual volume xyz
.EXAMPLE	
	PS:> Get-A9VvList_CLI -Space -vvName xyz 
.EXAMPLE	
	PS:> Get-A9VvList_CLI -Pattern -Prov full

	List virtual volume  provision type as "tpvv"
.EXAMPLE	
	PS:> Get-A9VvList_CLI -Pattern -Type base

	List snapshot(vitual copy) volumes 
.EXAMPLE	
	PS:> Get-A9VvList_CLI -R -Pattern -Prov tp* -Host TTest -Baseid 50
.EXAMPLE	
	PS:> Get-A9VvList_CLI -Showcols "Id,Name"
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
.PARAMETER R
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
.PARAMETER Pattern
	Pattern for matching VVs to show (see below for description of <pattern>) If the -p option is specified multiple times, each
	instance of <pattern> adds additional candidate VVs that match that pattern.        
.PARAMETER CPG
    Show only VVs whose UsrCPG or SnpCPG matches the one or more of the cpgname_or_patterns.
.PARAMETER Prov
    Show only VVs with Prov (provisioning) values that match the prov_or_pattern.
.PARAMETER Type
	Show only VVs of types that match the type_or_pattern.
.PARAMETER HostV
    Show only VVs that are exported as VLUNs to hosts with names that match one or more of the hostname_or_patterns.
.PARAMETER Baseid
    Show only VVs whose BsId column matches one more of the baseid_or_patterns.
.PARAMETER Copyof
    Show only VVs whose CopyOf column matches one more of the vvname_or_patterns.
.PARAMETER Rcopygroup
	Show only VVs that are in Remote Copy groups that match one or more of the groupname_or_patterns.
.PARAMETER Policy
	Show only VVs whose policy matches the one or more of the policy_or_pattern.
.PARAMETER vmName
	Show only VVs whose vmname matches one or more of the vvname_or_patterns.
.PARAMETER vmId
	Show only VVs whose vmid matches one or more of the vmids.
.PARAMETER vmHost
	Show only VVs whose vmhost matches one or more of the vmhost_or_patterns.
.PARAMETER vvolState
	Show only VVs whose vvolstate matches the specified state - bound or unbound.
.PARAMETER vvolsc
	Show only VVs whose storage container (vvset) name matches one or more of the vvset_name_or_patterns.
.PARAMETER vvName 
    Specify name of the volume.  If prefixed with 'set:', the name is a volume set name.	
.PARAMETER Prov 
    Specify name of the Prov type (full | tpvv |tdvv |snp |cpvv ). 
.PARAMETER Type 
    Specify name of the Prov type ( base | vcopy ).
.PARAMETER ShowCols 
        Explicitly select the columns to be shown using a comma-separated list of column names.  For this option the full column names are shown in the header.
        Run 'showvv -listcols' to list the available columns.
        Run 'clihelp -col showvv' for a description of each column.
.EXAMPLE
	PS:> Get-A9VvList_CLI | format-table

	Id    Name                            Prov Compr Dedup Type  CopyOf                          BsId  Rd -Detailed_State-
	--    ----                            ---- ----- ----- ----  ------                          ----  -- ----------------
	2     .mgmtdata                       full NA    NA    base  -                               2     RW normal
	420   tmaas_cluster1_veeam12_vol.0    tdvv v1    Yes   base  -                               420   RW normal
	424   vsa-ds1                         tdvv v1    Yes   base  -                               424   RW normal
	425   vsa-ds2                         tdvv v1    Yes   base  -                               425   RW normal
	606   BackupVol                       tdvv v1    Yes   base  -                               606   RW normal
	652   virt-Alletra9050-orai1db1-v.0   tdvv v1    Yes   base  -                               652   RW normal
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
	param(
		[Parameter()]	[switch]	$Listcols,
		[Parameter()]	[switch]	$D,
		[Parameter()]	[switch]	$Pol,
		[Parameter()]	[switch]	$Space,
		[Parameter()]	[switch]	$R,
		[Parameter()]	[switch]	$Zone,
		[Parameter()]	[switch]	$G,
		[Parameter()]	[switch]	$Alert,
		[Parameter()]	[switch]	$AlertTime,
		[Parameter()]	[switch]	$CPProg,	
		[Parameter()]	[switch]	$CpgAlloc,	
		[Parameter()]	[switch]	$State,	
		[Parameter()]	[switch]	$Hist,	
		[Parameter()]	[switch]	$RCopy,	
		[Parameter()]	[switch]	$NoTree,	
		[Parameter()]	[String]	$Domain,	
		[Parameter()]	[switch]	$Expired,	
		[Parameter()]	[switch]	$Retained,	
		[Parameter()]	[switch]	$Failed,		
		[Parameter()]	[String]	$vvName,
		[Parameter()]	[String]	$Type,	
		[Parameter()]	[String]	$Prov,	
		[Parameter()]	[switch]	$Pattern,	
		[Parameter()]	[String]	$CPG,	
		[Parameter()]	[String]	$HostV,
		[Parameter()]	[String]	$Baseid,
		[Parameter()]	[String]	$Copyof,
		[Parameter()]	[String]	$Rcopygroup,
		[Parameter()]	[String]	$Policy,
		[Parameter()]	[String]	$vmName,
		[Parameter()]	[String]	$vmId,
		[Parameter()]	[String]	$vmHost,	
		[Parameter()]	[String]	$vvolState,
		[Parameter()]	[String]	$vvolsc,
		[Parameter()]	[String]	$ShowCols
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
process	
{	$GetvVolumeCmd = "showvv "
	$cnt=1
	if ($Listcols)	{	$GetvVolumeCmd += "-listcols "
						$Result = Invoke-A9CLICommand -cmds  $GetvVolumeCmd
						return $Result				
					}
	if($D)			{	$GetvVolumeCmd += "-d "; 		$cnt=0	}	
	if($Pol)		{	$GetvVolumeCmd += "-pol ";		$cnt=0	}
	if($Space)		{	$GetvVolumeCmd += "-space ";	$cnt=2	}	
	if($R)			{	$GetvVolumeCmd += "-r ";		$cnt=2	}
	if($Zone)		{	$GetvVolumeCmd += "-zone ";		$cnt=1	}
	if($G)			{	$GetvVolumeCmd += "-g ";		$cnt=0	}
	if($Alert)		{	$GetvVolumeCmd += "-alert ";	$cnt=2	}
	if($AlertTime)	{	$GetvVolumeCmd += "-alerttime ";$cnt=2	}
	if($CPProg)		{	$GetvVolumeCmd += "-cpprog ";	$cnt=0	}
	if($CpgAlloc)	{	$GetvVolumeCmd += "-cpgalloc ";	$cnt=0	}
	if($State)		{	$GetvVolumeCmd += "-state ";	$cnt=0	}
	if($Hist)		{	$GetvVolumeCmd += "-hist ";		$cnt=0	}
	if($RCopy)		{	$GetvVolumeCmd += "-rcopy ";	$cnt=1	}
	if($NoTree)		{	$GetvVolumeCmd += "-notree ";	$cnt=1	}
	if($Domain)		{	$GetvVolumeCmd += "-domain $Domain ";	$cnt=0	}
	if($Expired)	{	$GetvVolumeCmd += "-expired ";	$cnt=1	}
	if($Retained)	{	$GetvVolumeCmd += "-retained ";	$cnt=0	}
	if($Failed)		{	$GetvVolumeCmd += "-failed ";	$cnt=1	}
	if($pattern)
		{	if($CPG)	{	$GetvVolumeCmd += "-p -cpg $CPG "	}
			if($Prov)	{	$GetvVolumeCmd += "-p -prov $Prov "	}
			if($Type)	{	$GetvVolumeCmd += "-p -type $Type "	}
			if($HostV)	{	$GetvVolumeCmd += "-p -host $Host "	}
			if($Baseid)	{	$GetvVolumeCmd += "-p -baseid $Baseid "	}
			if($Copyof)	{	$GetvVolumeCmd += "-p -copyof $Copyof "	}
			if($Rcopygroup)	{$GetvVolumeCmd += "-p -rcopygroup $Rcopygroup "}
			if($Policy)	{	$GetvVolumeCmd += "-p -policy $Policy "	}
			if($vmName)	{	$GetvVolumeCmd += "-p -vmname $vmName "	}
			if($vmId)	{	$GetvVolumeCmd += "-p -vmid $vmId "	}
			if($vmHost)	{	$GetvVolumeCmd += "-p -vmhost $vmHost "	}
			if($vvolState){	$GetvVolumeCmd += "-p -vvolstate $vvolState "	}		
			if($vvolsc)	{	$GetvVolumeCmd += "-p -vvolsc $vvolsc "	}
		}
	if($ShowCols)	{	$GetvVolumeCmd += "-showcols $ShowCols ";	$cnt=0	}	
	if ($vvName)	{	$GetvVolumeCmd += " $vvName"	}
	$Result = Invoke-A9CLICommand -cmds  $GetvVolumeCmd
	if($Result -match "no vv listed")	{	return "FAILURE : No vv $vvName found"	}
	if ( $Result.Count -gt 1)
		{	$incre = "true"
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -3  
			foreach ($s in  $Result[$cnt..$LastItem] )
			{	$s= [regex]::Replace($s,"^ +","")
				$s= [regex]::Replace($s,"-+","-")
				$s= [regex]::Replace($s," +",",")		
				$s= $s.Trim()
				$temp1 = $s -replace 'Adm,Snp,Usr,VSize','Adm(MB),Snp(MB),Usr(MB),VSize(MB)' 
				$s = $temp1			
				$temp2 = $s -replace '-CreationTime-','Date(Creation),Time(Creation),Zone(Creation)'
				$s = $temp2	
				$temp3 = $s -replace '-SpaceCalcTime-','Date,Time,Zone'
				$s = $temp3	
				if($Space)
					{	if($incre -eq "true")
							{	$sTemp1=$s				
								$sTemp = $sTemp1.Split(',')	
								$sTemp[6]="Rsvd(MiB/Snp)"					
								$sTemp[7]="Used(MiB/Snp)"				
								$sTemp[8]="Used(VSize/Snp)"
								$sTemp[9]="Wrn(VSize/Snp)"
								$sTemp[10]="Lim(VSize/Snp)"  
								$sTemp[11]="Rsvd(MiB/Usr)"					
								$sTemp[12]="Used(MiB/Usr)"				
								$sTemp[13]="Used(VSize/Usr)"
								$sTemp[14]="Wrn(VSize/Usr)"
								$sTemp[15]="Lim(VSize/Usr)"
								$sTemp[16]="Rsvd(MiB/Total)"					
								$sTemp[17]="Used(MiB/Total)"
								$newTemp= [regex]::Replace($sTemp,"^ ","")			
								$newTemp= [regex]::Replace($sTemp," ",",")				
								$newTemp= $newTemp.Trim()
								$s=$newTemp							
							}
					}
				if($R)
					{	if($incre -eq "true")
							{	$sTemp1=$s				
								$sTemp = $sTemp1.Split(',')	
								$sTemp[6]="RawRsvd(Snp)"					
								$sTemp[7]="Rsvd(Snp)"				
								$sTemp[8]="RawRsvd(Usr)"
								$sTemp[9]="Rsvd(Usr)"
								$sTemp[10]="RawRsvd(Tot)"  
								$sTemp[11]="Rsvd(Tot)"					
								$newTemp= [regex]::Replace($sTemp,"^ ","")			
								$newTemp= [regex]::Replace($sTemp," ",",")				
								$newTemp= $newTemp.Trim()
								$s=$newTemp							
							}
					}
				if($Zone)
					{	if($incre -eq "true")
							{	$sTemp1=$s				
								$sTemp = $sTemp1.Split(',')											
								$sTemp[7]="Zn(Adm)"				
								$sTemp[8]="Free_Zn(Adm)"
								$sTemp[9]="Zn(Snp)"	
								$sTemp[10]="Free_Zn(Snp)"
								$sTemp[11]="Zn(Usr)"		
								$sTemp[12]="Free_Zn(Usr)"					
								$newTemp= [regex]::Replace($sTemp,"^ ","")			
								$newTemp= [regex]::Replace($sTemp," ",",")				
								$newTemp= $newTemp.Trim()
								$s=$newTemp				
							}
					}
				if($Alert)
					{	if($incre -eq "true")
							{	$sTemp1=$s				
								$sTemp = $sTemp1.Split(',')											
								$sTemp[7]="Used(Snp(%VSize))"				
								$sTemp[8]="Wrn(Snp(%VSize))"
								$sTemp[9]="Lim(Snp(%VSize))"	
								$sTemp[10]="Used(Usr(%VSize))"				
								$sTemp[11]="Wrn(Usr(%VSize))"
								$sTemp[12]="Lim(Usr(%VSize))"	
								$sTemp[13]="Fail(Adm)"	
								$sTemp[14]="Fail(Snp)"	
								$sTemp[15]="Wrn(Snp)"	
								$sTemp[16]="Lim(Snp)"	
								$sTemp[17]="Fail(Usr)"	
								$sTemp[18]="Wrn(Usr)"	
								$sTemp[19]="Lim(Usr)"					
								$newTemp= [regex]::Replace($sTemp,"^ ","")			
								$newTemp= [regex]::Replace($sTemp," ",",")				
								$newTemp= $newTemp.Trim()
								$s=$newTemp							
							}
					}
				if($AlertTime)
					{	if($incre -eq "true")
							{	$sTemp1=$s				
								$sTemp = $sTemp1.Split(',')											
								$sTemp[2]="Fail(Adm))"				
								$sTemp[3]="Fail(Snp)"
								$sTemp[4]="Wrn(Snp)"	
								$sTemp[5]="Lim(Snp)"				
								$sTemp[6]="Fail(Usr)"
								$sTemp[7]="Wrn(Usr)"	
								$sTemp[8]="Lim(Usr)"										
								$newTemp= [regex]::Replace($sTemp,"^ ","")			
								$newTemp= [regex]::Replace($sTemp," ",",")				
								$newTemp= $newTemp.Trim()
								$s=$newTemp							
							}
					}
				Add-Content -Path $tempFile -Value $s
				$incre="false"
			}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}	
	else{	return "FAILURE : No vv $vvName found Error : $Result"	}	
}
}

Function Get-A9VvSet_CLI
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
    Specifies that the sets containing virtual volumes	
.EXAMPLE
	PS:> Get-A9VvSet | format-table
	Cmdlet executed successfully

	id uuid                                 name              setmembers                                          count vvolStorageContainerEnabled qosEnabled
	-- ----                                 ----              ----------                                          ----- --------------------------- ----------
	1 51d61280-2ef2-4fdc-88a5-9e1b4b0d97a7 vvset_dscc-test    {dscc-test}                                          1                       False      False
	5 2f00cefc-b14d-4098-a9c9-d4cd6cbcb044 vvset_Oradata1     {MySQLData}                                          1                       False      False
	7 b8f1a3e6-81ff-47da-887f-5fd529427789 AppSet_SAP_HANA    {HANA_data, HANA_log, HANA_shared, Veeam_datastore}  4                       False      False
.NOTES
	This command requires a SSH type connection
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[switch]	$VV,
		[Parameter()]	[switch]	$Summary,
		[Parameter()]	[String]	$vvSetName,
		[Parameter()]	[String]	$vvName
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
	if($Result -match "No vv set listed")	{	return "FAILURE : No vv set listed"	}
	if($Result -match "total")
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -3		
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= $s.Trim()			
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile 
			Remove-Item $tempFile
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Usrcpg ,
		[Parameter()]	[String]	$Snapname ,		
		[Parameter()]	[String]	$Snp_cpg ,		
		[Parameter()]	[switch]	$NoCons ,
		[Parameter()]	[String]	$Priority ,
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
	if($Priority)
		{	$opt="high","med","low"		
			if ($opt -eq $Priority)
				{	$Cmd+= " -pri $Priority"
				}
			else
				{	return " FAILURE : Invalid Priority $Priority ,Please use [high | med | low]."
				}
		}
	if ($Job_ID)	{	$Cmd+= " -jobid $Job_ID"}
	if($NoTask)		{	$Cmd+= " -notask "}
	if($Cleanup)	{	$Cmd+= " -clrsrc "	}
	if($TpVV)		{	$Cmd+= " -tpvv "	}
	if($TdVV)		{	$Cmd+= " -tdvv "	}
	if($DeDup)		{	$Cmd+= " -dedup "	}
	if($Compr)		{	$Cmd+= " -compr "	}
	if($MinAlloc)	{	$Cmd+= " -minalloc $MinAlloc"	}
	if($Usrcpg)		{	$Cmd += " $Usrcpg "	}
	else{	return "FAILURE : No CPG Name specified ."	}	
	if($VVName)		{	$Cmd += " $VVName"	}	
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	return  "$Result"	
}
} 

Function New-A9Vv_CLI
{
<#
.SYNOPSIS
    Creates a vitual volume.
.DESCRIPTION
	Creates a vitual volume.
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
.PARAMETER vvName 
    Specify new name of the virtual volume
.PARAMETER Force
	Force to execute
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]			[String]	$vvName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Size="1G", 	# Default is 1GB
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]    $CPGName,		
		[Parameter(ValueFromPipeline=$true)]	[String]    $vvSetName,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Force,
		[Parameter(ValueFromPipeline=$true)]	[String]    $Template,
		[Parameter(ValueFromPipeline=$true)]	[String]    $Volume_ID,
		[Parameter(ValueFromPipeline=$true)]	[String]    $Count,
		[Parameter(ValueFromPipeline=$true)]	[String]    $Wait,
		[Parameter(ValueFromPipeline=$true)]	[String]    $Comment,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Shared,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$tpvv,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$tdvv,
		[Parameter(ValueFromPipeline=$true)]	[Switch]	$Snp_Cpg,
		[Parameter(ValueFromPipeline=$true)]	[String]    $Sectors_per_track,
		[Parameter(ValueFromPipeline=$true)]	[String]    $Heads_per_cylinder,
		[Parameter(ValueFromPipeline=$true)]	[String]    $minAlloc,
		[Parameter(ValueFromPipeline=$true)]	[String]    $Snp_aw,
		[Parameter(ValueFromPipeline=$true)]	[String]    $Snp_al
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
	$CreateVVCmd = "createvv"
	if($Force)	{	$CreateVVCmd +=" -f "	}
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]			[String]	$vvSetName,
		[Parameter()]	[switch]	$Add,
		[Parameter()]	[String]	$Count,
		[Parameter()]	[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Domain,		
		[Parameter(ValueFromPipeline=$true)]	[String]	$vvName
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
.EXAMPLE
	PS:> Remove-A9LogicalDisk -LD_Name xxx
.PARAMETER Pat
	Specifies glob-style patterns. All LDs matching the specified pattern are removed. By default, confirmation is required to proceed
	with the command unless the -f option is specified. This option must be	used if the pattern specifier is used.
.PARAMETER Dr
	Specifies that the operation is a dry run and no LDs are removed.
.PARAMETER LD_Name
	Specifies the LD name, using up to 31 characters. Multiple LDs can be specified.
.PARAMETER Rmsys
	Specifies that system resource LDs such as logging LDs and preserved data LDs are removed.
.PARAMETER Unused
	Specifies the command to remove non-system LDs. This option cannot be used with the  -rmsys option.
	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Pat,
		[Parameter()]	[switch]	$Dr,
		[Parameter()]	[switch]	$Rmsys,
		[Parameter()]	[switch]	$Unused,
		[Parameter(Mandatory=$True)][String]	$LD_Name
		)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " removeld -f "
	if($Pat) 	{	$Cmd += " -pat " }
	if($Dr) 	{	$Cmd += " -dr " }
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
.EXAMPLE
	PS:> Remove-A9Vv_Ld_Cpg_Templates_CLI -Template_Name xxx
.PARAMETER Template_Name
	Specifies the name of the template to be deleted, using up to 31 characters. This specifier can be repeated to remove multiple templates
.PARAMETER Pat
	The specified patterns are treated as glob-style patterns and that all templates matching the specified pattern are removed. By default,
	confirmation is required to proceed with the command unless the -f option is specified. This option must be used if the pattern specifier is used.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Template_Name,
		[Parameter()]	[switch]	$Pat
)
Begin
{	Test-A9Connection -Clienttype 'SshClient'
}
process
{	$Cmd = " removetemplate -f "
	if($Pat)	{	$Cmd += " -pat "	}
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
.EXAMPLE
	In the following example, template vvtemp1 is modified to support the
	availability of data should a drive magazine fail (mag) and to use the
	the stale_ss policy:

	PS:> Set-A9Template_CLI -Option_Value " -ha mag -pol stale_ss v" -Template_Name vtemp1
.EXAMPLE 
	In the following example, the -nrw and -ha mag options are added to the
	template template1, and the -t option is removed:

	PS:> Set-A9Template_CLI -Option_Value "-nrw -ha mag -remove -t" -Template_Name template1
.PARAMETER Option_Value
	Indicates the specified options and their values (if any) are added to an existing template. The specified option replaces the existing option
	in the template. For valid options, refer to createtemplate command.
.PARAMETER Template_Name
	Specifies the name of the template to be modified, using up to 31 characters.
.PARAMETER Remove
	Indicates that the option(s) that follow -remove are removed from the
	existing template. When specifying an option for removal, do not specify
	the option's value. For valid options, refer to createtemplate command.
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
.EXAMPLE
	PS:> Set-A9VvSpace_CLI -VV_Name xxx
.PARAMETER Pat
	Remove the snapshot administration and snapshot data spaces from all the virtual volumes that match any of the specified glob-style patterns.
.PARAMETER VV_Name
	Specifies the virtual volume name, using up to 31 characters.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]					[switch]	$Pat,
		[Parameter(Mandatory=$True)]	[String]	$VV_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " freespace -f "
	if($Pat)		{	$Cmd += " -pat "}
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
.EXAMPLE
	The following example displays the region of logical disk v0.usr.0 that is used for a virtual volume: 
	
	PS:> Show-A9LdMappingToVvs_CLI -LD_Name v0.usr.0
.PARAMETER LD_Name
	Specifies the logical disk name.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(		[Parameter(Mandatory=$True)]	[String]	$LD_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showldmap "
	if($LD_Name)	{	$Cmd += " $LD_Name " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count  
			foreach ($S in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")			
					$s= $s.Trim()			
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item $tempFile	
		}
	else{	Return  $Result}
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
		[Parameter()]	[String]	$VV_Name
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
	if($Result.count -gt 1)
		{	if($Result -match "SYNTAX" )	{	Return $Result	}
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count		
			foreach ($S in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")			
					$s= $s.Trim()			
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$T,
		[Parameter()]	[switch]	$Fit,
		[Parameter()]	[String]	$Template_name_or_pattern
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
	if($Result.count -gt 1)
		{	if($Result -match "SYNTAX" )	{	Return $Result	}
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count				
			foreach ($S in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")			
					$s= $s.Trim()			
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item $tempFile	
		}
	else{	Return  $Result	}
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
.EXAMPLE
	PS:> Show-A9VvMappedToPD_CLI -Sum -PD_ID 4
.EXAMPLE
	PS:> Show-A9VvMappedToPD_CLI -P -Nd 1 -PD_ID 4
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
	[Parameter()]	[String]	$PD_ID
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
	if($Result.count -gt 1)
		{	if($Result -match "SYNTAX" )	{	Return $Result	}
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			foreach ($S in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")			
					$s= $s.Trim()			
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item $tempFile	
		}
	else
		{	Return  $Result }
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
	if($Result.count -gt 1)
		{	if($Result -match "SYNTAX" )	{	Return $Result	}
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			foreach ($S in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")			
					$s= $s.Trim()			
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item $tempFile	
		}
	else
		{	Return  $Result	}
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
.EXAMPLE
	PS:> Show-A9VvpDistribution_CLI -VV_Name Zertobm9 | format-table

	Id                          Cage_Pos SA SD usr total
	--                          -------- -- -- --- -----
	0                           0:0:0    1  0  2   3
	1                           0:1:0    0  0  2   2
	2                           0:2:0    1  0  2   3
	3                           0:3:0    1  0  2   3
	4                           0:4:0    0  0  2   2
	5                           0:5:0    1  0  2   3
	6                           0:6:0    0  0  2   2
	7                           0:7:0    1  0  2   3
	8                           0:8:0    1  0  2   3
	9                           0:9:0    0  0  2   2
	---------------------------
	10                          total    6  0  20  26
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Sortcol,
		[Parameter()]	[String]	$VV_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " showvvpd "
	if($Sortcol)	{	$Cmd += " -sortcol $Sortcol " }
	if($VV_Name) 	{	$Cmd += " $VV_Name " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)
		{	if($Result -match "SYNTAX" )	{	Return $Result	}
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			foreach ($S in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")
					$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s,"^ ","")		
					$s= [regex]::Replace($s," +",",")			
					$s= $s.Trim()			
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			remove-item $tempFile	
		}
	else
		{	Return  $Result	}
}
} 

Function Start-A9LD_CLI
{	
<#
.SYNOPSIS
	Start a logical disk (LD).  
.DESCRIPTION
	The command starts data services on a LD that has not yet been started.
.EXAMPLE
	Start-A9LD_CLI -LD_Name xxx
.PARAMETER LD_Name
	Specifies the LD name, using up to 31 characters.
.PARAMETER Ovrd
	Specifies that the LD is forced to start, even if some underlying data is missing.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]					[switch]	$Ovrd,
		[Parameter(Mandatory=$True)]	[String]	$LD_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{ 	$Cmd = " startld "
	if($Ovrd)		{	$Cmd += " -ovrd " }
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
.EXAMPLE
	Start-A9Vv_CLI
.PARAMETER VV_Name
	Specifies the VV name, using up to 31 characters.
.PARAMETER Ovrd
	Specifies that the logical disk is forced to start, even if some underlying data is missing.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]				[switch]	$Ovrd,
		[Parameter(Mandatory=$True)][String]	$VV_Name
)
Begin	
{	Test-A9Connection -ClientType 'SshClient'
}
process
{	$Cmd = " startvv "
	if($Ovrd)	{	$Cmd += " -ovrd "	}
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
.EXAMPLE
	PS:> Test-A9Vv_CLI -VVName XYZ
.EXAMPLE
	PS:> Test-A9Vv_CLI -Yes -VVName XYZ
.EXAMPLE
	PS:> Test-A9Vv_CLI -Offline -VVName XYZ
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
.EXAMPLE
	Update-VvSetProperties
.PARAMETER Setname
	Specifies the name of the vv set to modify.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.

.PARAMETER Name
	Specifies a new name for the VV set using up to 27 characters.
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]		[String]	$hostName,		
		[Parameter(ValueFromPipeline=$true)][String[]]	$Address,
		[Parameter(ValueFromPipeline=$true)][Switch]    $iSCSI=$false,
		[Parameter(ValueFromPipeline=$true)][Switch]    $Add,
		[Parameter(ValueFromPipeline=$true)][String[]]  $Domain,
		[Parameter(ValueFromPipeline=$true)][String[]]	$Loc,
		[Parameter(ValueFromPipeline=$true)][String[]]	$IP,
		[Parameter(ValueFromPipeline=$true)][String[]]	$OS,
		[Parameter(ValueFromPipeline=$true)][String[]]	$Model,
		[Parameter(ValueFromPipeline=$true)][String[]]	$Contact,
		[Parameter(ValueFromPipeline=$true)][String[]]	$Comment,
		[Parameter(ValueFromPipeline=$true)][String[]]	$Persona		
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
.EXAMPLE	
	PS:> Show-A9Peer_CLI
#>
[CmdletBinding()]
param()	
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}	
process	
{	$cmd = " showpeer"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	write-verbose "  Executing Show-Peer Command.-->"
	if($Result -match "No peers")	{	return $Result	}
	else	{	$tempFile = [IO.Path]::GetTempFileName()
				$LastItem = $Result.Count  
				#Write-Host " Result Count =" $Result.Count
				foreach ($s in  $Result[0..$LastItem] )
					{	$s= [regex]::Replace($s,"^ ","")			
						$s= [regex]::Replace($s," +",",")	
						$s= [regex]::Replace($s,"-","")
						$s= $s.Trim() 	
						Add-Content -Path $tempFile -Value $s
					}
				Import-Csv $tempFile 
				remove-item $tempFile
			}
	if($Result -match "No peers")	{	return $Result	}
	else	{	return  " Success : Executing Show-Peer "	}		
}
} 

Function Resize-A9Vv_CLI
{
<#
.SYNOPSIS
	Consolidate space in virtual volumes (VVs). (HIDDEN)
.EXAMPLE
	VVName testv
.PARAMETER VVName
	Specifies the name of the VV.
.PARAMETER PAT
	Compacts VVs that match any of the specified patterns. This option must be used if the pattern specifier is used.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$VVName,
		[Parameter()]	[switch]	$PAT
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
PROCESS
{	$Cmd = " compactvv -f "
	if($PAT)	{	$Cmd += " -pat "	}
	if($VVName)	{	$Cmd += " $VVName " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result 
}
}

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDJcx0WQh+i
# f7WHRztpgvDVd4pZ86Z0Zeg4Urd/5hXD2aozVNOxesrPKeDS9vckD6UHR3TkNm3n
# x3i2wAevhIIXoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhgwghoUAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQMwtsRCkFzwWG8+gZHUfLh56WW+V9XAE4ih1XfIvKKuI6ip5Q2KsGdk7
# YZY9qZIB5RJsHaPgf0dF7Lp8GRZGHJwwDQYJKoZIhvcNAQEBBQAEggGAOGXLKkGs
# vGTWqjT/UcwEXiVw6GU8nJFWk27vgakoMm8kDblOozdtBnNCyhEurMH6mDm4z0dy
# Kl/rUcONzK/2l2tl/AAJPanCpY4tB39DT1UkV4vuOpwqTGuE/Gvjz+i5+HMOqnpF
# fpZVY6ZIx8TnYsGJXpfCJYQDOHJiOCIxmqdjJ0n1xgUntwwZ3fGG/pz5pDEIt7G9
# xxWq7Sah6MPULtEc1XpWfvCv03j3TJH99BO1joZmFDToAy1NXlCH1bvSvAhG5Ni7
# dgWDSvM6PRkYrcah9em1uwVsCMyoNfmF0x4ucUPEGbFrBJAGDumGUQsb2ZhqtY8F
# koZOcjk+uKg/S2QpWLIFsOKx3nRUV9O5gLsNiC2GcSJmYU+kb2NRjuPtgGXATS8q
# rILEiMl74bG+WuAe0M7GDSlNt7padAUbqglLP7711IwSp6S3ZK4vtnKd4paeh75A
# adrYeIFMIJQXrFx4ko7cu8W1bK8GnQgmCPk82CoY7cuZrkI/w6gVNBd5oYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDAlIsO6I0JH5z4y6SGpxDY9MWOotb69tbOoArhi
# fcChcrqUQlu5pL7ekhaOECfm0BsCEQCc/ggoyQLydvlmeQK1HWk7GA8yMDI0MDcz
# MTE5Mjg1NlqgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVow
# SDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQD
# ExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVY
# wamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isg
# HMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFe
# xAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gp
# OWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28
# mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkH
# NwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58
# ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXH
# g2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W
# 1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK
# 8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn
# 783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+K
# PGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1I
# jrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP
# 2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ
# 5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON
# 1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S
# 88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbU
# uXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145
# WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6
# F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso
# /zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG
# 70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEM
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zC
# pyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf
# 1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x
# 4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEio
# ZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7ax
# xLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZ
# OjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJ
# l2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz
# 2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH
# 4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb
# 5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ
# 9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0g
# ADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs
# 7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq
# 3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/
# Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9
# /HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWoj
# ayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEB
# MHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgIFAKCB4TAaBgkq
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTE5
# Mjg1NlowKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMPU7ToysOpGPX1ILgDiXpAtHZtOG
# cL6shwptxiC35pRkpKwJpl1/9JZPHc3osOYv2TANBgkqhkiG9w0BAQEFAASCAgAp
# aeyS0SZyd5NojX3x3sBOzyVIGcaBGbQ7J3XiT9Jm5sPe5a2XuFkgDbyj+59oglxf
# tbPu4pu5GQbTOMmR1vFwAj0nF4VOXa8n5+AdfmvjHMEbpt4xrMWu4r1DO+X6zJMD
# ewgH1KWxNbsRXd9J0KE81tzojgQg7iBgyla8H5T/YTTCykuBLf4o8UI+odqBMRp3
# e5bcj1srWVLvaYvmD+Wy06O10RFAhm5dLqV6Wipz7h6bJzVOG9rLo+XogM7g9NRr
# ZanJ/4JtcHrhlevshWGOMz4O5vT8kXIhYTFpqtn4DBofmGE1NuMoKOZJnJNh9Z79
# cgBuBnUt+2Tcxz8NONagovnrfEiM+EifQcWrSrQfXJfWRYY86gD1DursgVk/7Pli
# P1gbNwdUPT8GaJ1ewa7LenxNgMGR4VsenGUjVJ+P1r1+vX+9FRDFneYdtac9aHIj
# hTFJoSeYcx1RtM5a4ufSjHmiCRmNTSi9s1ukGegyclm02+hctH7mb4+q6LzbJ/KB
# fO2+12VH2KBj8I5SIKaoomdQho5a9WJvIjmZpjvvLjk4VJt7ACAShy5n8u2Wwwg8
# c+YI5h08Y9c1WtrNKoZOPwXWNHKSVWmtBkW3ycLxSZgTaOmfLsPaSEv6sJ/8ddH4
# DpEzscw0td9NKALOVprP+vN2GhhAwiH0TMtl7SsPyA==
# SIG # End signature block
