####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Compress-A9VV_CLI
{
<#
.SYNOPSIS   
	The Compress-VV command is used to change the properties of a virtual volume that was created with the createvv command by associating it with a different CPG.
.DESCRIPTION  
	The Compress-VV command is used to change the properties of a virtual volume that was created with the createvv command by associating it with a different CPG.
.EXAMPLE	
	PS:> Compress-A9VV_CLI -SUBCommand usr_cpg -CPGName XYZ
.EXAMPLE
	PS:> Compress-A9VV_CLI -SUBCommand usr_cpg -CPGName XYZ -VVName XYZ
.EXAMPLE
	PS:> Compress-A9VV_CLI -SUBCommand usr_cpg -CPGName XYZ -Option XYZ -VVName XYZ
.EXAMPLE
	PS:> Compress-A9VV_CLI -SUBCommand usr_cpg -CPGName XYZ -Option keepvv -KeepVVName XYZ -VVName XYZ
.EXAMPLE
	PS:> Compress-A9VV_CLI -SUBCommand snp_cpg -CPGName XYZ -VVName XYZ
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
.PARAMETER VVName
	Specifies the name of the existing virtual volume.
.PARAMETER WaitTask
	Specifies that the command will wait for any created tasks to complete.
.PARAMETER DryRun
	Specifies that the command is a dry run and that no logical disks or virtual volumes are actually tuned.  Cannot be used with the -tpvv, -dedup, -full, or -compr options.
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
.PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(		[Parameter(Mandatory=$true)][ValidateSet('usr_cpg','snp_cpg','restart','rollback')]
											[String]	$SUBCommand ,
			[Parameter(Mandatory=$true)]	[String]	$VVName ,
			[Parameter()]					[String]	$CPGName ,	
			[Parameter()]					[switch]	$WaitTask ,		
			[Parameter()]					[switch]	$DryRun ,		
			[Parameter()]					[String]	$Count ,
			[Parameter()]					[switch]	$TPVV ,
			[Parameter()]					[switch]	$TDVV ,
			[Parameter()]					[switch]	$DeDup ,
			[Parameter()]					[switch]	$Full ,
			[Parameter()]					[switch]	$Compr ,
			[Parameter()]					[String]	$KeepVV ,		
			[Parameter()]					[String]	$Threshold , 
			[Parameter()]					[String]	$SliceSize , 		
			[Parameter()]					[String]	$Src_Cpg 
)	
Begin	
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " tunevv "
	if($SUBCommand)
		{	$Cmd += " $SUBCommand"
			if($SUBCommand -eq "usr_cpg" -Or $SUBCommand -eq "snp_cpg")
				{	if($CPGName)	{	$Cmd += " $CPGName"	}
					else			{	return "SubCommand : $SUBCommand,Must Require CPG Name."	}
				}
		}
	$Cmd += " -f "	
	if($WaitTask)	{	$Cmd += " -waittask "	}
	if($DryRun)		{	$Cmd += " -dr "	}
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
	if($VVName)		{	$Cmd += " $VVName"	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	return  $Result

}
}

Function Get-A9HistogramChunklet
{
<#
.SYNOPSIS
    The Get-HistChunklet command displays a histogram of service times in a timed loop for individual chunklets
.DESCRIPTION
	The Get-HistChunklet command displays a histogram of service times in a timed loop for individual chunklets
.EXAMPLE
    PS:> Get-A9HistogramChunklet -Iteration 1 

	This example displays one iteration of a histogram of service
.EXAMPLE
    PS:> Get-A9HistogramChunklet –LDname dildil -Iteration 1 

	identified by name, from which chunklet statistics are sampled.
.EXAMPLE
	PS:> Get-A9HistogramChunklet -Iteration 1 -Previous
.PARAMETER Chunklet_num
	Specifies that statistics are limited to only the specified chunklet, identified
	by number.
.PARAMETER Metric both|time|size
	Selects which metric to display. Metrics can be one of the following:
		both - (Default)Display both I/O time and I/O size histograms
		time - Display only the I/O time histogram
		size - Display only the I/O size histogram
.PARAMETER Percentage
	Shows the access count in each bucket as a percentage. If this option is not specified, the histogram shows the access counts.
.PARAMETER Previous
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). If no option is specified, the
	histogram shows data from the beginning of the command's execution.
.PARAMETER Beginning
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). If no option is specified, the
	histogram shows data from the beginning of the command's execution.
.PARAMETER RW
	Specifies that the display includes separate read and write data. If not specified, the total is displayed.
.PARAMETER Interval
	Specifies the interval in seconds that statistics are sampled from using an integer from 1 through 2147483. If no count is specified, the
	command defaults to 2 seconds.
.PARAMETER Iteration
	Specifies that the histogram is to stop after the indicated number of iterations using an integer from 1 through 2147483647.
.PARAMETER NI
	Specifies that histograms for only non-idle devices are displayed. This option is shorthand for the option -filt t,0,0.
.PARAMETER LDname 
    Specifies the Logical Disk (LD), identified by name, from which chunklet statistics are sampled.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$LDname,
		[Parameter()]	[String]	$Chunklet_num,
		[Parameter()]	[String]	$Metric,
		[Parameter(Mandatory=$true)]	[String]	$Iteration,
		[Parameter()]	[switch]	$Percentage,
		[Parameter()]	[switch]	$Previous,
		[Parameter()]	[switch]	$Beginning,
		[Parameter()]	[switch]	$RW,
		[Parameter()]	[String]	$Interval,
		[Parameter()]	[switch]	$NI	
)		
begin	
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$histchCMD = "histch"
	$histchCMD+=" -iter $iteration"
	if($LDname)		{	$histchCMD +=" -ld $LDname "	}
	if($Chunklet_num){	$histchCMD +=" -ch $Chunklet_num "	} 
	if($Metric)		{	$histchCMD +=" -metric $Metric "	}
	if($Percentage)	{	$histchCMD +=" -pct "	}
	if($Previous)	{	$histchCMD +=" -prev "	}
	if($Beginning)	{	$histchCMD +=" -begin "	}
	if($RW)			{	$histchCMD +=" -rw "	}
	if($Interval)	{	$histchCMD +=" -d $Interval "	}
	if($NI)			{	$histchCMD +=" -ni "	}	
	$Result = Invoke-A9CLICommand -cmds  $histchCMD	
	$range1 = $Result.count
	if($range1 -le "5")	{	return "No data available Please try with valid input."	}
	Write-Verbose " displays a histogram of service -->$histchCMD" 
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count		
			if($RW)	{	$LastItem = $LastItem - 4	}		
			Add-Content -Path $tempFile -Value 'Ldid,Ldname,logical_Disk_CH,Pdid,PdCh,0.5,1.0,2.0,4.0,8.0,16,32,64,128,256,4k,8k,16k,32k,64k,128k,256k,512k,1m,time,date'
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "millisec")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$split1=$s.split(",")
							$global:time1 = $split1[0]
							$global:date1 = $split1[1]
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "Ldname"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +"," ")
					$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
					$aa=$s.split(",").length
					if ($aa -eq "20")	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}	
}
}

Function Get-A9HistogramLogicalDisk
{
<#
.SYNOPSIS
    The Get-HistLD command displays a histogram of service times for Logical Disks (LDs) in a timed loop.
.DESCRIPTION
	The Get-HistLD command displays a histogram of service times for Logical Disks (LDs) in a timed loop.
.EXAMPLE
    PS:> Get-A9HistogramLogicalDisk -Iteration 1

	displays a histogram of service Iteration number of times
.EXAMPLE
	PS:> Get-A9HistogramLogicalDisk -LdName abcd -Iteration 1

	displays a histogram of service linked with LD_NAME on  Iteration number of times
.EXAMPLE
	PS:> Get-A9HistogramLogicalDisk -Iteration 1 -VV_Name ZXZX

	Shows only logical disks that are mapped to virtual volumes with names matching any of the names or patterns specified.
.EXAMPLE
	PS:> Get-A9HistogramLogicalDisk -Iteration 1 -Domain ZXZX

	Shows only logical disks that are in domains with names matching any of the names or patterns specified.
.EXAMPLE
	PS:> Get-A9HistogramLogicalDisk -Iteration 1 -Percentage Shows the access count in each bucket as a percentage.
.PARAMETER Timecols
	For the I/O time histogram, shows the columns from the first column <fcol> through last column <lcol>. The available columns range from 0 through 31.

	The first column (<fcol>) must be a value greater than or equal to 0, but less than the value of the last column (<lcol>).

	The last column (<lcol>) must be less than or equal to 31.

	The first column includes all data accumulated for columns less than the first column and the last column includes accumulated data for all columns greater than the last column.

	The default value of <fcol> is 6.
	The default value of <lcol> is 15.
.PARAMETER Sizecols
	For the I/O size histogram, shows the columns from the first column (<fcol>) through the last column (<lcol>). Available columns range from 0 through 15.

	The first column (<fcol>) must be a value greater than or equal to 0, but less than the value of the last column (<lcol>) (default value of 3). 
	The last column (<lcol>) must be less than or equal to 15 (default value of 11).

	The default value of <fcol> is 3.
	The default value of <lcol> is 11.
.PARAMETER Percentage
	Shows the access count in each bucket as a percentage. If this option is not specified, the histogram shows the access counts.
.PARAMETER Secs
	Specifies the interval in seconds that statistics are sampled from using an integer from 1 through 2147483. If no count is specified, the command defaults to 2 seconds.
.PARAMETER NI
	Specifies that histograms for only non-idle devices are displayed. This option is shorthand for the option -filt t,0,0.	
.PARAMETER Iteration 
    displays a histogram of service Iteration number of times
.PARAMETER LdName 
    displays a histogram of service linked with LD_NAME
.PARAMETER VV_Name
	Shows only logical disks that are mapped to virtual volumes with names matching any of the names or patterns specified. Multiple volumes or patterns can be repeated using a comma separated list.
.PARAMETER Domain
	Shows only logical disks that are in domains with names matching any of the names or patterns specified. Multiple domain names or patterns can be repeated using a comma separated list.
.PARAMETER Metric
	Selects which metric to display. Metrics can be one of the following:
		both - (Default)Display both I/O time and I/O size histograms
		time - Display only the I/O time histogram
		size - Display only the I/O size histogram
.PARAMETER Previous 
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). If no option is specified, the histogram shows data from the beginning of the command's execution.
.PARAMETER Beginning
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). If no option is specified, the histogram shows data from the beginning of the command's execution.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	
		[Parameter()]	[String]	$Iteration,	
		[Parameter()][ValidateSet('both','time','size')]
						[String]	$Metric,
		[Parameter()]	[String]	$VV_Name,
		[Parameter()]	[String]	$Domain,
		[Parameter()]	[String]	$Timecols,
		[Parameter()]	[String]	$Sizecols, 
		[Parameter()]	[Switch]	$Percentage,
		[Parameter()]	[Switch]	$Previous,
		[Parameter()]	[Switch]	$Beginning,
		[Parameter()]	[Switch]	$NI,
		[Parameter()]	[String]	$Secs,
		[Parameter()]	[String]	$LdName
)		
Begin	
{	Test-A9Connection -ClientType 'SshClient' 
}
Process	
{	$histldCmd = "histld "
	if ($Iteration)	{	$histldCmd += " -iter $Iteration "	}
	else			{	return "Error :  -Iteration is mandatory. "	}
	if ($Metric)	{	$histldCmd+=" -metric $Metric "				}
	if($VV_Name)	{	$cmd= "showvv "
						$demo = Invoke-A9CLICommand -cmds  $Cmd
						if($demo -match $VV_Name )	{	$histldCmd+=" -vv $VV_Name"	}
						else						{ 	return  "FAILURE : No Virtual Volume : $VV_Name found, Please try with valid input."	}		
					} 
	if($Domain)
	{	$cmd= "showdomain "
		$demo = Invoke-A9CLICommand -cmds  $Cmd
		if($demo -match $Domain )	{	$histldCmd+=" -domain $Domain"	}
		else	{ 	return  "FAILURE : No Domain : $Domain found, Please try with valid input."	}
	}	
	if($Timecols)	{	$histldCmd+=" -timecols $Timecols "	}
	if($Sizecols)	{	$histldCmd+=" -sizecols $Sizecols"	}	
	if ($Percentage){	$histldCmd += " -pct "	}
	if ($Previous)	{	$histldCmd += " -prev "	}	
	if ($Beginning)	{	$histldCmd += " -begin "	}
	if($Secs)		{	$histldCmd+=" -d $Secs"	}
	if ($NI)		{	$histldCmd += " -ni "	}
	if ($LdName)	{	$cmd= "showld "
						$demo = Invoke-A9CLICommand -cmds  $Cmd
						if($demo -match $LdName )	{	$histldCmd += "  $LdName"	}
						else	{ 	return  "FAILURE : No LD_name $LdName found "	}
					}	
	$Result = Invoke-A9CLICommand -cmds  $histldCmd
	write-verbose "  The Get-HistLD command displays a histogram of service times for Logical Disks (LDs) in a timed loop.->$cmd"	
	$range1 = $Result.count
	#write-host "count = $range1"
	if($range1 -lt "5")		{	return "No data available Please Try With Valid Data. `n"	}	
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			if ($Metric -eq "time")		{	Add-Content -Path $tempFile -Value  'Logical_Disk_Name,0.50,1,2,4,8,16,32,64,128,256,time,date'	}
			if ($Metric -eq "size")		{	Add-Content -Path $tempFile -Value  'Logical_Disk_Name,4k,8k,16k,32k,64k,128k,256k,512k,1m,time,date' 	}
			else						{	Add-Content -Path $tempFile -Value  'Logical_Disk_Name,0.50,1,2,4,8,16,32,64,128,256,4k,8k,16k,32k,64k,128k,256k,512k,1m,time,date' 	}
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "millisec")
					{	$s= [regex]::Replace($s,"^ +","")
						$s= [regex]::Replace($s," +"," ")
						$s= [regex]::Replace($s," ",",")
						$split1=$s.split(",")
						$global:time1 = $split1[0]
						$global:date1 = $split1[1]
						continue
					}
					if (($s -match "-------") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "Ldname"))	{	continue	}
					#write-host "s = $s"
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +"," ")
					$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	else{	return $Result	}
} 
}

Function Get-A9HistogramPhysicalDisk
{
<#
.SYNOPSIS
    The Get-HistPD command displays a histogram of service times for Physical Disks (PDs).
.DESCRIPTION
    The Get-HistPD command displays a histogram of service times for Physical Disks (PDs).
.EXAMPLE
    PS:> Get-A9HistogramPhysicalDisk -iteration 1 -WWN abcd

	Specifies the world wide name of the PD for which service times are displayed.
.EXAMPLE
	PS:> Get-A9HistogramPhysicalDisk -iteration 1

	The Get-HistPD displays a histogram of service iteration number of times Histogram displays data from when the system was last started (–begin).
.EXAMPLE	
	PS:> Get-A9HistogramPhysicalDisk -iteration 1 -Devinfo

	Indicates the device disk type and speed.
.EXAMPLE	
	PS:> Get-A9HistogramPhysicalDisk -iteration 1 -Metric both

	(Default)Display both I/O time and I/O size histograms
.PARAMETER WWN
	Specifies the world wide name of the PD for which service times are displayed.
.PARAMETER Nodes
	Specifies that the display is limited to specified nodes and physical disks connected to those nodes. The node list is specified as a series
	of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the node list is not specified, all disks on all nodes are displayed.
.PARAMETER Slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified
	as a series of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all disks on all slots are displayed.
.PARAMETER Ports
	Specifies that the display is limited to specified ports and physical disks connected to those ports. The port list is specified as a series of integers separated 
	by commas (e.g. 1,2,3). The list can also consist of a single integer. If the port list is not specified, all disks on all ports are displayed.
.PARAMETER Percentage
	Shows the access count in each bucket as a percentage. If this option is not specified, the histogram shows the access counts.
.PARAMETER Previous 
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). 
	If no option is specified, the histogram shows data from the beginning of the command's execution.
.PARAMETER Beginning
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). 
	If no option is specified, the histogram shows data from the beginning of the command's execution.
.PARAMETER Devinfo
	Indicates the device disk type and speed.
.PARAMETER Metric both|time|size
	Selects which metric to display. Metrics can be one of the following:
		both - (Default)Display both I/O time and I/O size histograms
		time - Display only the I/O time histogram
		size - Display only the I/O size histogram
.PARAMETER Iteration 
    Specifies that the histogram is to stop after the indicated number of iterations using an integer from 1 up-to 2147483647.
.PARAMETER FSpec
	Specifies that histograms below the threshold specified by the <fspec> argument are not displayed. The <fspec> argument is specified in the syntax of <op>,<val_ms>, <count>.
	<op>
		The <op> argument can be specified as one of the following:
			r - Specifies read statistics.
			w - Specifies write statistics.
			t - Specifies total statistics.
			rw - Specifies total read and write statistics.
	<val_ms>
		Specifies the threshold service time in milliseconds.
	<count>: Specifies the minimum number of access above the threshold service time. When filtering is done, the <count> is compared with the sum of all columns 
			starting with the one which corresponds to the threshold service time. For example, -t,8,100 means to only display the rows where the 8ms column
			and all columns to the right adds up to more than 100.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Iteration,
		[Parameter()]	[String]	$WWN,
		[Parameter()]	[String]	$Nodes,
		[Parameter()]	[String]	$Slots,
		[Parameter()]	[String]	$Ports,
		[Parameter()]	[Switch]	$Devinfo,
		[Parameter()]	[ValidateSet('both','time','size')]
						[String]	$Metric,
		[Parameter()]	[Switch]	$Percentage,
		[Parameter()]	[Switch]	$Previous,
		[Parameter()]	[Switch]	$Beginning,	
		[Parameter()]	[String]	$FSpec
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = "histpd "
	if($Iteration)	{	$Cmd += "-iter $Iteration"	}
	else			{	return "Error :  -Iteration is mandatory. "}	
	if ($WWN)		{	$Cmd += " -w $WWN"}
	if ($Nodes)		{	$Cmd += " -nodes $Nodes"	}
	if ($Slots)		{	$Cmd += " -slots $Slots"	}
	if ($Ports)		{	$Cmd += " -ports $Ports"	}
	if ($Devinfo)	{	$Cmd += " -devinfo "	}
	if($Metric)		{	$Met = $Metric
						$c = "both","time","size"
						$Metric = $metric.toLower()
						if($c -eq $Met)		{	$Cmd += " -metric $Metric "}
						else	{	return "FAILURE: -Metric $Metric is Invalid. Use only [ both | time | size ]."	}
					}
	if ($Previous)		{	$Cmd += " -prev "}
	if ($Beginning)		{	$Cmd += " -begin "}
	if ($Percentage)	{	$Cmd += " -pct "	}	
	if ($FSpec)			{	$Cmd += " -filt $FSpec"	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd 
	write-verbose " The Get-HistPD command displays a histogram of service times for Physical Disks (PDs). " 
	$range1 = $Result.count
	if($range1 -lt "5")	{	return "No data available"	}		
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			if("time" -eq $Metric.trim().tolower())
				{	Add-Content -Path $tempFile -Value 'ID,Port,0.50,1,2,4,8,16,32,64,128,256,time,date'
					$LastItem = $Result.Count - 3
				}
			elseif("size" -eq $Metric.trim().tolower())
				{	Add-Content -Path $tempFile -Value 'ID,Port,4k,8k,16k,32k,64k,128k,256k,512k,1m,time,date'	
					$LastItem = $Result.Count - 3
				}
			elseif ($Devinfo)	{	Add-Content -Path $tempFile -Value  'ID,Port,Type,K_RPM,0.50,1,2,4,8,16,32,64,128,256,4k,8k,16k,32k,64k,128k,256k,512k,1m,time,date'	}
			else				{	Add-Content -Path $tempFile -Value  'ID,Port,0.50,1,2,4,8,16,32,64,128,256,4k,8k,16k,32k,64k,128k,256k,512k,1m,time,date'				}
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "millisec")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$split1=$s.split(",")
							$global:time1 = $split1[0]
							$global:date1 = $split1[1]
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "ID"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s,"-+","-")
					$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line			
					$aa=$s.split(",").length
					if ($aa -eq "20") 	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	else{	return $Result	}
}
}

Function Get-A9HistogramPort
{
<#
.SYNOPSIS
    The command displays a histogram of service times for ports within the system.
.DESCRIPTION
	The command displays a histogram of service times for ports within the system.
.EXAMPLE
    PS:> Get-A9HistogramPort -iteration 1

	displays a histogram of service times with option it can be one of these [both|ctrl|data].
.EXAMPLE
	PS:> Get-A9HistogramPort -iteration 1 -Both

	Specifies that both control and data transfers are displayed(-both)
.EXAMPLE
	PS:> Get-A9HistogramPort -iteration 1 -Nodes nodesxyz

	Specifies that the display is limited to specified nodes and physical disks connected to those nodes.
.EXAMPLE	
	PS:> Get-A9HistogramPort –Metric both -iteration 1

	displays a histogram of service times with -metric option. metric can be one of these –metric [both|time|size]
.PARAMETER Both 
	Specifies that both control and data transfers are displayed(-both), only control transfers are displayed (-ctl), or only data transfers are
	displayed (-data). If this option is not specified, only data transfers are displayed.
.PARAMETER CTL 
	Specifies that both control and data transfers are displayed(-both), only control transfers are displayed (-ctl), or only data transfers are
	displayed (-data). If this option is not specified, only data transfers are displayed.
.PARAMETER Data
	Specifies that both control and data transfers are displayed(-both), only control transfers are displayed (-ctl), or only data transfers are 
	displayed (-data). If this option is not specified, only data transfers are displayed.
.PARAMETER Nodes
	Specifies that the display is limited to specified nodes and physical disks connected to those nodes. The node list is specified as a series
	of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the node list is not specified, all disks on all nodes are displayed.
.PARAMETER Slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified as a series of integers 
	separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all disks on all slots are displayed.
.PARAMETER Ports
	Specifies that the display is limited to specified ports and physical disks connected to those ports. The port list is specified as a series of integers separated 
	by commas (e.g. 1,2,3). The list can also consist of a single integer. If the port list is not specified, all disks on all ports are displayed.
.PARAMETER HostE
	Specifies to display only host ports (target ports), only disk ports (initiator ports), only Fibre Channel Remote Copy configured ports, or
	only Fibre Channel ports for Data Migration. If no option is specified, all ports are displayed.
.PARAMETER Disk 
	Specifies to display only host ports (target ports), only disk ports (initiator ports), only Fibre Channel Remote Copy configured ports, or
	only Fibre Channel ports for Data Migration. If no option is specified, all ports are displayed.
.PARAMETER RCFC 
	Specifies to display only host ports (target ports), only disk ports (initiator ports), only Fibre Channel Remote Copy configured ports, or
	only Fibre Channel ports for Data Migration. If no option is specified, all ports are displayed.
.PARAMETER PEER
	Specifies to display only host ports (target ports), only disk ports (initiator ports), only Fibre Channel Remote Copy configured ports, or
	only Fibre Channel ports for Data Migration. If no option is specified, all ports are displayed.
.PARAMETER Metric
	Selects which metric to display. Metrics can be one of the following:
		both - (Default)Display both I/O time and I/O size histograms
		time - Display only the I/O time histogram
		size - Display only the I/O size histogram
.PARAMETER Iteration 
    Specifies that the histogram is to stop after the indicated number of iterations using an integer from 1 up-to 2147483647.
.PARAMETER Percentage
	Shows the access count in each bucket as a percentage. If this option is not specified, the histogram shows the access counts.
.PARAMETER Previous 
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). If no option is specified, the
	histogram shows data from the beginning of the command's execution.
.PARAMETER Beginning
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). If no option is specified, the
	histogram shows data from the beginning of the command's execution.
.PARAMETER RW	
	Specifies that the display includes separate read and write data. If not specified, the total is displayed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$Iteration,	
		[Parameter()]	[Switch]	$Both,
		[Parameter()]	[Switch]	$CTL,
		[Parameter()]	[Switch]	$Data,
		[Parameter()]	[String]	$Nodes,
		[Parameter()]	[String]	$Slots,
		[Parameter()]	[String]	$Ports,
		[Parameter()]	[Switch]	$HostE,
		[Parameter()]	[Switch]	$PEER,
		[Parameter()]	[Switch]	$Disk,
		[Parameter()]	[Switch]	$RCFC,
		[Parameter()]	[String]	$Metric,		
		[Parameter()]	[Switch]	$Percentage,
		[Parameter()]	[Switch]	$Previous,
		[Parameter()]	[Switch]	$Beginning,
		[Parameter()]	[Switch]	$RW
)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$Cmd = "histport "
	$Cmd +=" -iter $Iteration"	
	if ($Both)	{	$Cmd +=" -both "	}
	if ($CTL)	{	$Cmd +=" -ctl "		}
	if ($Data)	{	$Cmd +=" -data "	}
	if ($Nodes)	{	$Cmd += " -nodes $Nodes"	}
	if ($Slots)	{	$Cmd += " -slots $Slots"	}
	if ($Ports)	{	$Cmd += " -ports $Ports"	}
	if ($HostE)	{	$Cmd +=" -host "	}
	if ($Disk)	{	$Cmd +=" -disk "	}
	if ($RCFC)	{	$Cmd +=" -rcfc "	}
	if ($PEER)	{	$Cmd +=" -peer "	}
	if ($Metric){	$Cmd += " -metric "
					$a1="both","time","size"
					$Metric = $Metric.toLower()
					if($a1 -eq $Metric )	{	$Cmd += "$Metric "	}		
					else					{	return "FAILURE:  -Metric $Metric  is Invalid. Only [ both | time | size ] can be used."	}
				}	
	if ($Previous)	{	$Cmd += " -prev "	}
	if ($Beginning)	{	$Cmd += " -begin "	}
	if ($Percentage){	$Cmd += " -pct "	}
	if ($RW)		{	$Cmd += " -rw "		}
	$Result = Invoke-A9CLICommand -cmds  $Cmd 	
	$range1 = $Result.count
	#write-host "count = $range1"
	if ($range1 -lt "5")	{	return "No data available"	}		
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			if("time" -eq $Metric.trim().tolower())		{	Add-Content -Path $tempFile -Value 'Port,Data/Ctrl,0.50,1,2,4,8,16,32,64,128,256,time,date'	}
			elseif("size" -eq $Metric.trim().tolower())	{	Add-Content -Path $tempFile -Value 'Port,Data/Ctrl,4k,8k,16k,32k,64k,128k,256k,512k,1m,time,date'	}
			elseif($RW)									{	Add-Content -Path $tempFile -Value 'Port,Data/Ctrl,R/W,0.50,1,2,4,8,16,32,64,128,256,4k,8k,16k,32k,64k,128k,256k,512k,1m,time,date'	}
			else										{	Add-Content -Path $tempFile -Value 'Port,Data/Ctrl,0.50,1,2,4,8,16,32,64,128,256,4k,8k,16k,32k,64k,128k,256k,512k,1m,time,date'	}
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "millisec")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$split1=$s.split(",")
							$global:time1 = $split1[0]
							$global:date1 = $split1[1]
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "Ldname"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s,"-+","-")
					$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
					$s +=",$global:time1,$global:date1"	
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	else{	return $Result	}
}
}

Function Get-A9HistogramRemoteCopyVv
{
<#
.SYNOPSIS
	The command shows a histogram of total remote-copy service times and backup system remote-copy service times in a timed loop.
.DESCRIPTION
	Thecommand shows a histogram of total remote-copy service times and backup system 	remote-copy service times in a timed loop        
.EXAMPLE
	PS:> Get-A9HistogramRemoteCopyVv -iteration 1

	The command shows a histogram of total remote-copy service iteration number of times
.EXAMPLE
    PS:> Get-A9HistogramRemoteCopyVv -iteration 1 -Sync

	The command shows a histogram of total remote-copy service iteration number of times with option sync
.EXAMPLE	
	PS:> Get-A9HistogramRemoteCopyVv -group groupvv_1 -iteration
.EXAMPLE	
	PS:> Get-A9HistogramRemoteCopyVv -iteration 1 -Periodic
.EXAMPLE	
	PS:> Get-A9HistogramRemoteCopyVv -iteration 1 -PortSum
.EXAMPLE	
	PS:> Get-A9HistogramRemoteCopyVv -target name_vv1 -iteration 1

	The command shows a histogram of total remote-copy service with specified target name.
.EXAMPLE	
	PS:> Get-A9HistogramRemoteCopyVv -group groupvv_1 -iteration   

	The command shows a histogram of total remote-copy service with specified Group name.
.PARAMETER Async
	Show only volumes which are being copied in asynchronous mode.
.PARAMETER sync
	Show only volumes that are being copied in synchronous mode.
.PARAMETER periodic
	Show only volumes which are being copied in asynchronous periodic mode.
.PARAMETER primary
	Show only virtual volumes in the primary role.
.PARAMETER secondary
	Show only virtual volumes in the secondary role.
.PARAMETER targetsum
	Displays the sums for all volumes of a target.
.PARAMETER portsum
	Displays the sums for all volumes on a port.
.PARAMETER groupsum
	Displays the sums for all volumes of a volume group.
.PARAMETER vvsum
	Displays the sums for all targets and links of a virtual volume.
.PARAMETER domainsum
	Displays the sums for all volumes of a domain.
.PARAMETER VV_Name
	Displays statistics only for the specified virtual volume or volume name pattern. Multiple volumes or patterns can be repeated (for example,
    <VV_name> <VV_name>). If not specified, all virtual volumes that are configured for remote copy are listed.
.PARAMETER interval 
    <secs>  Specifies the interval in seconds that statistics are sampled from using an integer from 1 through 2147483. If no count is specified, the  command defaults to 2 seconds. 
.PARAMETER Pct
	Shows the access count in each bucket as a percentage. If this option is not specified, the histogram shows the access counts.
.PARAMETER Prev
	Specifies that the histogram displays data from a previous sample. If no option is specified, the histogram shows data from the beginning of the command's execution.
.PARAMETER domain
	Shows only the virtual volumes that are in domains with names that match the specified domain name(s) or pattern(s).
.PARAMETER target
	Shows only volumes whose group is copied to the specified target name or pattern. Multiple target names or patterns may be specified using a comma-separated list.
.PARAMETER group
    Shows only volumes whose volume group matches the specified group name or pattern of names. Multiple group names or patterns may be specified using a comma-separated list..PARAMETER iteration
    Specifies that the statistics are to stop after the indicated number of iterations using an integer from 1 through 2147483647.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$ASync,
		[Parameter()]	[switch]	$Sync,
		[Parameter()]	[switch]	$Periodic,
		[Parameter()]	[switch]	$Primary,
		[Parameter()]	[switch]	$Secondary,
		[Parameter()]	[switch]	$TargetSum,
		[Parameter()]	[switch]	$PortSum,
		[Parameter()]	[switch]	$GroupSum,
		[Parameter()]	[switch]	$VVSum,
		[Parameter()]	[switch]	$DomainSum,
		[Parameter()]	[switch]	$Pct,
		[Parameter()]	[switch]	$Prev,
		[Parameter()]	[String]	$VV_Name,
		[Parameter()]	[String]	$interval,	
		[Parameter()]	[String]	$domain,
		[Parameter()]	[String]	$group,
		[Parameter()]	[String]	$target,
		[Parameter()]	[String]	$iteration	
	)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$Cmd = "histrcvv "
	if($ASync)		{	$Cmd += " -async "			}
	if($Sync)		{	$Cmd += " -sync "			}
	if($Periodic)	{	$Cmd += " -periodic "		}
	if($Primary)	{	$Cmd += " -primary "		}
	if($Secondary)	{	$Cmd += " -secondary "		}
	if($TargetSum)	{	$Cmd += " -targetsum "		}
	if($PortSum)	{	$Cmd += " -portsum "		}
	if($GroupSum)	{	$Cmd += " -groupsum "		}
	if($VVSum)		{	$Cmd += " -vvsum "			}
	if($DomainSum)	{	$Cmd += " -domainsum "		}
	if($Pct)		{	$Cmd += " -pct "			}
	if($Prev)		{	$Cmd += " -prev "			}	
	if($interval)	{	$Cmd += " -d $interval"		}
	if ($domain)	{ 	$Cmd += " -domain  $domain"	}
	if ($group)		{ 	$Cmd += " -g $group"		}
	if ($target)	{ 	$Cmd += " -t $target"		}
	if ($VV_Name)	{ 	$Cmd += " $VV_Name"			}
	if ($iteration)	{ 	$Cmd += " -iter $iteration "}	
	else			{	return "Error :  -Iteration is mandatory. "	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	write-verbose " histograms sums for all synchronous remote - copy volumes" 
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count - 2
			if($VVSum)			{	Add-Content -Path $tempFile -Value "VVname,RCGroup,Target,Mode,Svt_0.50,Svt_1,Svt_2,Svt_4,Svt_8,Svt_16,Svt_32,Svt_64,Svt_128,Svt_256,Rmt_0.50,Rmt_1,Rmt_2,Rmt_4,Rmt_8,Rmt_16,Rmt_32,Rmt_64,Rmt_128,Rmt_256,Time,Date" }
			elseif($PortSum) 	{	Add-Content -Path $tempFile -Value "Link,Target,Type,Svt_0.50,Svt_1,Svt_2,Svt_4,Svt_8,Svt_16,Svt_32,Svt_64,Svt_128,Svt_256,Rmt_0.50,Rmt_1,Rmt_2,Rmt_4,Rmt_8,Rmt_16,Rmt_32,Rmt_64,Rmt_128,Rmt_256,Time,Date"}
			elseif($GroupSum) 	{	Add-Content -Path $tempFile -Value "Group,Target,Mode,Svt_0.50,Svt_1,Svt_2,Svt_4,Svt_8,Svt_16,Svt_32,Svt_64,Svt_128,Svt_256,Rmt_0.50,Rmt_1,Rmt_2,Rmt_4,Rmt_8,Rmt_16,Rmt_32,Rmt_64,Rmt_128,Rmt_256,Time,Date"	}
			elseif($TargetSum)	{	Add-Content -Path $tempFile -Value "Target,Svt_0.50,Svt_1,Svt_2,Svt_4,Svt_8,Svt_16,Svt_32,Svt_64,Svt_128,Svt_256,Rmt_0.50,Rmt_1,Rmt_2,Rmt_4,Rmt_8,Rmt_16,Rmt_32,Rmt_64,Rmt_128,Rmt_256,Time,Date"}
			elseif($DomainSum)	{	Add-Content -Path $tempFile -Value "Domain,Svt_0.50,Svt_1,Svt_2,Svt_4,Svt_8,Svt_16,Svt_32,Svt_64,Svt_128,Svt_256,Rmt_0.50,Rmt_1,Rmt_2,Rmt_4,Rmt_8,Rmt_16,Rmt_32,Rmt_64,Rmt_128,Rmt_256,Time,Date"	}
			else 				{	Add-Content -Path $tempFile -Value "VVname,RCGroup,Target,Mode,Port,Type,Svt_0.50,Svt_1,Svt_2,Svt_4,Svt_8,Svt_16,Svt_32,Svt_64,Svt_128,Svt_256,Rmt_0.50,Rmt_1,Rmt_2,Rmt_4,Rmt_8,Rmt_16,Rmt_32,Rmt_64,Rmt_128,Rmt_256,Time,Date"	}
			foreach($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +"," ")
					$s= [regex]::Replace($s," ",",")
					if($s -match "millisec")
						{	$split1=$s.split(",")
							$global:time1 = $split1[0]
							$global:date1 = $split1[1]
							continue
						}
					$lent=$s.split(",").length
					$var2 = $lent[0]
					if( "total" -eq $var2)	{	continue	}	
					if(($s -match "-------") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "RCGroup"))	{	continue	}	
					$s +=",$global:time1,$global:date1"	
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	elseif($Result -match "No virtual volume")	{ 	Return "No data available : $Result"}
	else{	return $Result	}
}
}

Function Get-A9HistogramVLun
{
<#
.SYNOPSIS
	The command displays Virtual Volume Logical Unit Number (VLUN) service time histograms.
.DESCRIPTION
    The command displays Virtual Volume Logical Unit Number (VLUN) service time histograms.
.EXAMPLE
	PS:> Get-A9HistogramVLun -iteration 1

	This example displays two iterations of a histogram of service times for all VLUNs.	
.EXAMPLE	
	PS:> Get-A9HistogramVLun -iteration 1 -nodes 1

	This example displays two iterations of a histogram only exports from the specified nodes.	
.EXAMPLE	
	PS:> Get-A9HistogramVLun -iteration 1 -domain DomainName
	Shows only VLUNs whose Virtual Volumes (VVs) are in domains with names that match one or more of the specified domain names or patterns.
.EXAMPLE	
	PS:> Get-A9HistogramVLun -iteration 1 -Percentage

	Shows the access count in each bucket as a percentage.	 
.PARAMETER domain
	Shows only VLUNs whose Virtual Volumes (VVs) are in domains with names that match one or more of the specified domain names or patterns. Multiple domain names or patterns can be
	repeated using a comma-separated list.
.PARAMETER hostE
	Shows only VLUNs exported to the specified host(s) or pattern(s). Multiple host names or patterns can be repeated using a comma-separated list.
.PARAMETER vvname
	Requests that only LDs mapped to VVs that match and of the specified names or patterns be displayed. Multiple volume names or patterns can be repeated using a comma-separated list.
.PARAMETER Nodes
	Specifies that the display is limited to specified nodes and physical disks connected to those nodes. The node list is specified as a series
	of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the node list is not specified, all disks on all nodes are displayed.
.PARAMETER Slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified as a series of integers separated 
	by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all disks on all slots are displayed.
.PARAMETER Ports
	Specifies that the display is limited to specified ports and physical disks connected to those ports. The port list is specified as a series of integers separated 
	by commas (e.g. 1,2,3). The list can also consist of a single integer. If the port list is not specified, all disks on all ports are displayed.
.PARAMETER Metric
	Selects which metric to display. Metrics can be one of the following:
		both - (Default)Display both I/O time and I/O size histograms
		time - Display only the I/O time histogram
		size - Display only the I/O size histogram
.PARAMETER Percentage
	Shows the access count in each bucket as a percentage. If this option is not specified, the histogram shows the access counts.
.PARAMETER Previous
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). 
	If no option is specified, the histogram shows data from the beginning of the command's execution.
.PARAMETER Beginning
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). If no option is specified, the histogram shows data from the beginning of the command's execution.
.PARAMETER Lun      
	Specifies that VLUNs with LUNs matching the specified LUN(s) or pattern(s) are displayed. Multiple LUNs or patterns can be repeated using a comma-separated list.
.PARAMETER iteration
	Specifies that the statistics are to stop after the indicated number of iterations using an integer from 1 through 2147483647.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$iteration,
		[Parameter()]	[String]	$domain,
		[Parameter()]	[String]	$hostE,
		[Parameter()]	[String]	$vvname,
		[Parameter()]	[String]	$lun,
		[Parameter()]	[String]	$Nodes,
		[Parameter()]	[String]	$Slots,
		[Parameter()]	[String]	$Ports,
		[Parameter()]	[Switch]	$Percentage,
		[Parameter()]	[Switch]	$Previous,
		[Parameter()]	[Switch]	$Beginning,
		[Parameter()]	[String]	$Metric			
)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$Cmd = "histvlun "
	if ($iteration)	{ 	$Cmd += " -iter $iteration"	}	
	else			{	return "Error : -Iteration is mandatory. "	}
	if ($domain)	{ 	$Cmd += " -domain $domain"	}	
	if($hostE)		{	$objType = "host"
						$objMsg  = "hosts"		
						if ( -not (Test-A9CLIObject -objectType $objType -objectName $host -objectMsg $objMsg))	{	return "FAILURE : No host $host found"	}		
						$Cmd += " -host $host "		
					}
	if ($vvname)	{	$GetvVolumeCmd="showvv"
						$Res = Invoke-A9CLICommand -cmds  $GetvVolumeCmd
						if ($Res -match $vvname)
							{	$Cmd += " -v $vvname"
							}
						else{ 	write-verbose "vvname $vvname does not exist. Nothing to List" 
								return "FAILURE : No vvname $vvname found"			
							}
					}	
	if ($lun)		{	$Cmd += " -l $lun"	}
	if ($Nodes)		{	$Cmd += " -nodes $Nodes"	}
	if ($Slots)		{	$Cmd += " -slots $Slots"	}
	if ($Ports)		{	$Cmd += " -ports $Ports"	}	
	if($Metric)		{	$Met = $Metric
						$c = "both","time","size"
						$Metric = $metric.toLower()
						if($c -eq $Met)	{	$Cmd += " -metric $Metric "	}
						else			{	return "FAILURE: -Metric $Metric is Invalid. Use only [ both | time | size ]."	}
					}
	if ($Previous)	{	$Cmd += " -prev "	}
	if ($Beginning)	{	$Cmd += " -begin "	}
	if ($Percentage){	$Cmd += " -pct "	}		
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	write-verbose " histograms The Get-HistVLun command displays Virtual Volume Logical Unit Number (VLUN)  " 
	$range1 = $Result.Count
	if($range1 -le "5" ){	return "No Data Available"	}	
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count 
			if("time" -eq $Metric.trim().tolower())
				{	Add-Content -Path $tempFile -Value 'Lun,VVname,Host,Port,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),time,date'
					$LastItem = $Result.Count -3
				}
			elseif("size" -eq $Metric.trim().tolower())
				{	Add-Content -Path $tempFile -Value 'Lun,VVname,Host,Port,4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes),time,date'
					$LastItem = $Result.Count -3
				}
			else	{	Add-Content -Path $tempFile -Value 'Lun,VVname,Host,Port,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes),time,date'	}
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "millisec")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$split1=$s.split(",")
							$global:time1 = $split1[0]
							$global:date1 = $split1[1]
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "VVname"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s,"-+","-")
					$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
					$aa=$s.split(",").length
					if ($aa -eq "20")	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}	
	else{	return $Result	}
}
}

Function Get-A9HistogramVv
{
<#
.SYNOPSIS
	The Get-A9HistogramVv command displays Virtual Volume (VV) service time histograms in a timed loop.
.DESCRIPTION
	The Get-A9HistogramVv command displays Virtual Volume (VV) service time histograms in a timed loop.
.EXAMPLE
    PS:> Get-A9HistogramVv -iteration 1

	This Example displays Virtual Volume (VV) service time histograms service iteration number of times.
.EXAMPLE
	PS:> Get-A9HistogramVv -iteration 1 -domain domain.com
	This Example Shows only the VVs that are in domains with names that match the specified domain name(s)
.EXAMPLE	
	PS:> Get-A9HistogramVv -iteration 1 –Metric both
	This Example Selects which Metric to display.
.EXAMPLE
	PS:> Get-A9HistogramVv -iteration 1 -Timecols "1 2"
.EXAMPLE
	PS:> Get-A9HistogramVv -iteration 1 -Sizecols "1 2"
.EXAMPLE	
	PS:> Get-A9HistogramVv –Metric both -VVname demoVV1 -iteration 1

	This Example Selects which Metric to display. associated with Virtual Volume name.
.PARAMETER domain
	Shows only the VVs that are in domains with names that match the specified domain name(s) .
.PARAMETER Metric
	Selects which Metric to display. Metrics can be one of the following:
	1)both - (Default) Displays both I/O time and I/O size histograms.
	2)time - Displays only the I/O time histogram.
	3)size - Displays only the I/O size histogram.
.PARAMETER Timecols
	For the I/O time histogram, shows the columns from the first column <fcol> through last column <lcol>. The available columns range from 0 through 31.

	The first column (<fcol>) must be a value greater than or equal to 0, but less than the value of the last column (<lcol>).

	The last column (<lcol>) must be less than or equal to 31.

	The first column includes all data accumulated for columns less than the first column and the last column includes accumulated data for all columns greater than the last column.

	The default value of <fcol> is 6.
	The default value of <lcol> is 15.
.PARAMETER Sizecols
	For the I/O size histogram, shows the columns from the first column (<fcol>) through the last column (<lcol>). Available columns range from 0 through 15.

	The first column (<fcol>) must be a value greater than or equal to 0, but less than the value of the last column (<lcol>) (default value of 3).
	The last column (<lcol>) must be less than or equal to 15 (default value of 11).

	The default value of <fcol> is 3.
	The default value of <lcol> is 11.
.PARAMETER Percentage
	Shows the access count in each bucket as a percentage. If this option isnot specified, the histogram shows the access counts.
.PARAMETER Previous
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). If no option is specified, the
	histogram shows data from the beginning of the command's execution.
.PARAMETER Beginning
	Histogram displays data either from a previous sample(-prev) or from when the system was last started(-begin). If no option is specified, the
	histogram shows data from the beginning of the command's execution.
.PARAMETER RW
	Specifies that the display includes separate read and write data. If not
	specified, the total is displayed.
.PARAMETER IntervalInSeconds
	Specifies the interval in seconds that statistics are sampled from using an integer from 1 through 2147483. If no count is specified, the command defaults to 2 seconds.
.PARAMETER FSpace 
	Specifies that histograms below the threshold specified by the <fspec> argument are not displayed. The <fspec> argument is specified in the
	syntax of <op>,<val_ms>, <count>.
	<op>
		The <op> argument can be specified as one of the following:
			r - Specifies read statistics.
			w - Specifies write statistics.
			t - Specifies total statistics.
			rw - Specifies total read and write statistics.
	<val_ms>
		Specifies the threshold service time in milliseconds.
	<count>
	Specifies the minimum number of access above the threshold service time. When filtering is done, the <count> is compared with the sum
	of all columns starting with the one which corresponds to the threshold service time. For example, -t,8,100 means to only display
	the rows where the 8ms column and all columns to the right adds up to more than 100.
.PARAMETER VVName
	Virtual Volume name
.PARAMETER iteration
	Specifies that the statistics are to stop after the indicated number of iterations using an integer from 1 through 2147483647.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$iteration,
		[Parameter()]	[String]	$domain,
		[Parameter()]	[String]	$Metric,
		[Parameter()]	[String]	$Timecols,
		[Parameter()]	[String]	$Sizecols,
		[Parameter()]	[String]	$VVname,		
		[Parameter()]	[Switch]	$Percentage,
		[Parameter()]	[Switch]	$Previous,	
		[Parameter()]	[Switch]	$RW,
		[Parameter()]	[String]	$IntervalInSeconds,
		[Parameter()]	[String]	$FSpace
	)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$Cmd = "histvv "
	if ($iteration)	{ 	$Cmd += " -iter $iteration "		}
	else			{	return "Error :  -Iteration is mandatory. "	}
	if ($domain)	{ 	$Cmd += " -domain $domain "	}
	if ($Metric)	{	$opt="both","time","size"
						$Metric = $Metric.toLower()
						if ($opt -eq $Metric)	{	$Cmd += " -metric $Metric"						}
						else 					{	return " metrics $Metric not found only [ both | time | size ] can be passed one at a time "	}
					}
	if ($Timecols)	{ 	$Cmd += " -timecols $Timecols "			}
	if ($Sizecols)	{ 	$Cmd += " -sizecols $Sizecols "			}
	if ($Previous)	{	$Cmd += " -prev "	}	
	if ($Percentage){	$Cmd += " -pct "	}
	if ($RW)		{	$Cmd += " -rw "	}
	if ($IntervalInSeconds)	{ 	$Cmd += " -d $IntervalInSeconds "	}
	if ($FSpace)	{ 	$Cmd += " -filt $FSpace "			}
	if ($VVname)
		{	$vv=$VVname
			$Cmd1 ="showvv"
			$Result1 = Invoke-A9CLICommand -cmds  $Cmd1
			if($Result1 -match $vv)	{	$cmd += " $vv "	}
			else					{	Return "Error: -VVname $VVname is not available `n Try Using Get-VvList to list all the VV's Available  "	}
		}		
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	write-verbose " Get-HistVv command displays Virtual Volume Logical Unit Number (VLUN)  " 
	$range1 = $Result.count
	if($range1 -le "5")	{	return "No data available"	}	
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			if("time" -eq $Metric.trim().tolower())		{	Add-Content -Path $tempFile -Value 'VVname,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),time,date'	}
			elseif("size" -eq $Metric.trim().tolower())	{	Add-Content -Path $tempFile -Value 'VVname,4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes),time,date'	}
			else										{	Add-Content -Path $tempFile -Value 'VVname,0.50(millisec),1(millisec),2(millisec),4(millisec),8(millisec),16(millisec),32(millisec),64(millisec),128(millisec),256(millisec),4k(bytes),8k(bytes),16k(bytes),32k(bytes),64k(bytes),128k(bytes),256k(bytes),512k(bytes),1m(bytes),time,date'	}
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "millisec")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$split1=$s.split(",")
							$global:time1 = $split1[0]
							$global:date1 = $split1[1]
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "VVname"))	{	continue	}			
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s,"-+","-")
					$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line			
					$s +=",$global:time1,$global:date1"	
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	else{	return $Result	}
}
}

Function Get-A9StatisticsChunklet
{
<#
.SYNOPSIS
	The command displays chunklet statistics in a timed loop.
.DESCRIPTION
	The command displays chunklet statistics in a timed loop. 
.EXAMPLE
	PS:> Get-A9StatisticsChunklet -Iterration 1

	This example displays chunklet statistics in a timed loop.
.EXAMPLE
	PS:>Get-A9StatisticsChunklet -RW -Iteration 1

	This example Specifies that reads and writes are displayed separately.while displays chunklet statistics in a timed loop.  
.EXAMPLE  
	PS:> Get-A9StatisticsChunklet -LDname demo1 -CHnum 5 -Iterration 1 
	
	This example Specifies particular chunklet number & logical disk.
.PARAMETER RW	
	Specifies that reads and writes are displayed separately. If this option is not used, then the total of reads plus writes is displayed.
.PARAMETER Idlep
	Specifies the percent of idle columns in the output.
.PARAMETER Begin
	Specifies that I/O averages are computed from the system start time. If not specified, the average is computed since the first iteration of the command.
.PARAMETER NI
	Specifies that statistics for only non-idle devices are displayed
.PARAMETER Delay 
	Specifies the interval, in seconds, that statistics are sampled using an integer from 1 through 2147483.
.PARAMETER LDname 
	Specifies that statistics are restricted to chunklets from a particular logical disk.
.PARAMETER CHnum  
	Specifies that statistics are restricted to a particular chunklet number.
.PARAMETER Iteration 
	Specifies that CMP statistics are displayed a specified number of times as indicated by the num argument using an integer
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$Iteration ,
		[Parameter()]	[switch]	$RW,
		[Parameter()]	[switch]	$IDLEP,
		[Parameter()]	[switch]	$Begin,
		[Parameter()]	[switch]	$NI,
		[Parameter()]	[String]	$Delay,
		[Parameter()]	[String]	$LDname ,
		[Parameter()]	[String]	$CHnum 
	)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statch"
	$cmd+=" -iter $Iteration "
	else		{	return "Error :  -Iteration is mandatory. "			}
	if($RW)		{	$cmd +=" -rw "		}
	if($IDLEP)	{	$cmd+=" -idlep "	}
	if($Begin)	{	$cmd+=" -begin "	}
	if($NI)		{	$cmd+=" -ni "		}
	if($Delay)	{	$cmd+=" -d $Delay"	}
	if($LDname)	{	$ld="showld"
					$Result1 = Invoke-A9CLICommand -cmds  $ld
					if($Result1 -match $LDname )	{	$cmd+=" -ld $LDname "	}
					else{	Return "FAILURE : -LDname $LDname is not available . "	}
				}
	if($CHnum)	{	$cmd+=" -ch $CHnum "	}
	$Result = Invoke-A9CLICommand -cmds  $cmd
	write-verbose "  Executing  Get-StatChunklet command displays chunklet statistics in a timed loop. with the command  " 
	$range1 = $Result.Count
	if($range1 -le "5" )	{	return "No Data Available"	}
	if( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			if($IDLEP)	{	Add-Content -Path $tempFile -Value "Logical_Disk_I.D,LD_Name,Ld_Ch,Pd_id,Pd_Ch,R/W,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max,Svt_Cur,Svt_Avg,IOSz_Cur,IOSz_Avg,Qlen,Idle_Cur,Idle_Avg,Time,Date" 	}
			else 		{	Add-Content -Path $tempFile -Value "Logical_Disk_I.D,LD_Name,Ld_Ch,Pd_id,Pd_Ch,R/W,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max,Svt_Cur,Svt_Avg,IOSz_Cur,IOSz_Avg,Qlen,Time,Date"	}
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "r/w")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$global:time1 = $s.substring(0,8)
							$global:date1 = $s.substring(9,19)
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "Qlen"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")# Replace one or more spaces with comma to build CSV line
					$aa=$s.split(",").length
					if ($aa -eq "11")	{	continue	}
					if (($aa -eq "13") -and ($IDLEP))	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}	
	else{	return $Result	}	
}
}

Function Get-A9StatCacheMemoryPages
{
<#
.SYNOPSIS
	The command displays Cache Memory Page (CMP) statistics by node or by Virtual Volume (VV).
.DESCRIPTION
	The command displays Cache Memory Page (CMP) statistics by node or by Virtual Volume (VV).
.EXAMPLE
	PS:> Get-A9StatCacheMemoryPages -Iteration 1

	This Example displays Cache Memory Page (CMP).
.EXAMPLE
	PS:> Get-A9StatCacheMemoryPages -VVname Demo1 -Iteration 1

	This Example displays Cache Memory Page (CMP) statistics by node or by Virtual Volume (VV).
.PARAMETER VVname   
	Specifies that statistics are displayed for virtual volumes matching the specified name or pattern.
.PARAMETER Domian 
	Shows VVs that are in domains with names that match one or more of the specified domains or patterns.
.PARAMETER Delay  
	Specifies the interval, in seconds, that statistics are sampled using an integer from 1 through 2147483.
.PARAMETER NI
	Specifies that statistics for only non-idle VVs are displayed. This option is valid only if -v is also specified.
.PARAMETER Iteration 
	Specifies that CMP statistics are displayed a specified number of times as indicated by the num argument using an integer
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$NI,
		[Parameter()]	[String]	$VVname ,
		[Parameter()]	[String]	$Domian ,
		[Parameter()]	[String]	$Delay  ,
		[Parameter()]	[String]	$Iteration 
)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statcmp -v "	
	if($Iteration)	{	$cmd+=" -iter $Iteration "	}
	else	{	return "Error :  -Iteration is mandatory. "	}	
	if ($NI)	{	$cmd +=" -ni "	}
	if($VVname)	{	$cmd+=" -n $VVname "	}		
	if ($Domian){	$cmd+= " -domain $Domian "	}
	if($Delay)	{	$cmd+=" -d $Delay"	}		
	$Result = Invoke-A9CLICommand -cmds  $cmd
	write-verbose "  Executing  Get-StatCMP command displays Cache Memory Page (CMP) statistics. with the command  " 
	$range1 = $Result.count
	if($range1 -le "3")	{	return "No data available"	}	
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			Add-Content -Path $tempFile -Value "VVid,VVname,Type,Curr_Accesses,Curr_Hits,Curr_Hit%,Total_Accesses,Total_Hits,Total_Hit%,Time,Date"
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +"," ")
					$s= [regex]::Replace($s," ",",")
					if ($s -match "Current")
						{	$a=$s.split(",")
							$global:time1 = $a[0]
							$global:date1 = $a[1]
							continue
						}
					if (($s -match "---") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "VVname"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")# Replace one or more spaces with comma to build CSV line
					$aa=$s.split(",").length
					if ($aa -eq "11")	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	else{	return $Result	}
}
}

Function Get-A9CPUStatisticalDataReports_CLI
{
<#
.SYNOPSIS
	The command displays CPU statistics for all nodes.
.DESCRIPTION
	The command displays CPU statistics for all nodes.
.EXAMPLE
	PS:> Get-A9CPUStatisticalDataReports_CLI -iteration 1	
	
	This Example Displays CPU statistics for all nodes.
.EXAMPLE  
	PS:> Get-A9CPUStatisticalDataReports_CLI -delay 2  -total -iteration 1	

	This Example Show only the totals for all the CPUs on each node.
.PARAMETER delay    
	Specifies the interval, in seconds, that statistics are sampled using an integer from 1 through 2147483
.PARAMETER total 
	Show only the totals for all the CPUs on each node.
.PARAMETER Iteration 
	Specifies that CMP statistics are displayed a specified number of times as indicated by the num argument using an integer
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$delay,
		[Parameter()]	[switch]	$total,
		[Parameter(Mandatory=$true)]	[String]	$Iteration 
)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statcpu "
	$cmd+=" -iter $Iteration "
	if($delay)	{	$cmd+=" -d $delay "	}
	if ($total)	{	$cmd+= " -t "		}
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	write-verbose "  Executing  Get-StatCPU command displays Cache Memory Page (CMP) statistics. with the command  " 
	$range1 = $Result.count
	if($range1 -eq "5"){	return "No data available"	}		
	if ( $Result.Count -gt 1)
		{	$flg = "False"
			$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			Add-Content -Path $tempFile -Value "node,cpu,user,sys,idle,intr/s,ctxt/s,Time,Date"
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s,"-+","-")
					$s= [regex]::Replace($s," +",",")
					$s= [regex]::Replace($s,"---","")
					$s= [regex]::Replace($s,"-","")  
					$a=$s.split(",")
					$c=$a.length
					$b=$a.length
					if ( 2 -eq $b )
						{	$a=$s.split(",")
							$global:time1 = $a[0]
							$global:date1 = $a[1]
						}
					if (([string]::IsNullOrEmpty($s)) -or ($s -match "node"))	{	continue	}
					if($c -eq "6")	{	$s +=",,$global:time1,$global:date1"	}
					else	{	$s +=",$global:time1,$global:date1"	}
					if($flg -eq "True")	{	Add-Content -Path $tempFile -Value $s		}
					$flg = "True"			
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	else{	return $Result	}
} 
}

Function Get-A9LogicalDiskStatisticsReports_CLI
{
<#
.SYNOPSIS
	The command displays read/write (I/O) statistics about Logical Disks (LDs) in a timed loop.
.DESCRIPTION
	The command displays read/write (I/O) statistics about Logical Disks (LDs) in a timed loop.
.EXAMPLE
	PS:> Get-A9LogicalDiskStatisticsReports_CLI -Iteration 1
	
	This example displays read/write (I/O) statistics about Logical Disks (LDs).
.EXAMPLE
	PS:> Get-A9LogicalDiskStatisticsReports_CLI -rw -Iteration 1	
	
	This example displays statistics about Logical Disks (LDs).with Specification read/write
.EXAMPLE  
	PS:> Get-StatLD -Begin -delay 2 -Iteration 1

	This example displays statistics about Logical Disks (LDs).with Specification begin & delay in execution of 2 sec.	
.EXAMPLE  
	PS:> Get-A9LogicalDiskStatisticsReports_CLI -Begin -VVname demo1 -Delay 2 -Iteration 1

	This example displays statistics about Logical Disks (LDs) Show only LDs that are mapped to Virtual Volumes (VVs)	
.EXAMPLE  
	PS:> Get-A9LogicalDiskStatisticsReports_CLI -begin -LDname demoLD1 -delay 2 -Iteration 1

	This example displays statistics about Logical Disks (LDs).With Only statistics are displayed for the specified LD
.PARAMETER RW		
	Specifies that reads and writes are displayed separately. If this option is not used, then the total of reads plus writes is displayed.
.PARAMETER Begin	
	Specifies that I/O averages are computed from the system start time. If not specified, the average is computed since the first iteration of the command.
.PARAMETER IDLEP	
    Specifies the percent of idle columns in the output.
.PARAMETER VVname  
	Show only LDs that are mapped to Virtual Volumes (VVs) with names matching any of names or patterns specified
.PARAMETER LDname  
	Only statistics are displayed for the specified LD or pattern
.PARAMETER Domain
	Shows only LDs that are in domains with names matching any of the names or specified patterns.
.PARAMETER Delay 
	Specifies the interval, in seconds, that statistics are sampled using an integer from 1 through 2147483.
.PARAMETER Iteration 
	Specifies that I/O statistics are displayed a specified number of times as indicated by the number argument using an integer from 1 through 2147483647.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$RW,
		[Parameter()]	[switch]	$IDLEP,
		[Parameter()]	[switch]	$Begin,
		[Parameter()]	[switch]	$NI,
		[Parameter()]	[String]	$VVname ,
		[Parameter()]	[String]	$LDname,
		[Parameter()]	[String]	$Domain,
		[Parameter()]	[String]	$Delay,
		[Parameter(Mandatory=$true)]	[String]	$Iteration
	)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statld -iter $Iteration "	
	if($RW)		{	$cmd +=" -rw "		}
	if($IDLEP)	{	$cmd+=" -idlep "	}
	if($Begin)	{	$cmd+=" -begin "	}
	if($NI)		{	$cmd+=" -ni "		}
	if($VVname)	
		{	$ld="showvv"
			$Result1 = Invoke-A9CLICommand -cmds  $ld
			if($Result1 -match $VVname )	{	$cmd+=" -vv $VVname "	}
			else 							{	Return "FAILURE : -VVname $VVname is not available .`n Try Using Get-VvList to get all available VV  "	}
		}
	if($LDname)	
		{	if($cmd -match "-vv")	{	return "Stop: Executing -VVname $VVname and  -LDname $LDname cannot be done in a single Execution "	}
			$ld="showld"
			$Result1 = Invoke-A9CLICommand -cmds  $ld		
			if($Result1 -match $LDname )	{	$cmd+=" $LDname "	}
			else 							{	Return "FAILURE : -LDname $LDname is not available . "	}
		}	
	if($Domain)		{	$cmd+=" -domain $Domain "	}	
	if($Delay)		{	$cmd+=" -d $Delay "	}		
	$Result = Invoke-A9CLICommand -cmds  $cmd
	$range1 = $Result.count
	if($range1 -le "5")	{	return "No data available" }	
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count - 1		
			if($IDLEP)	{	Add-Content -Path $tempFile -Value "Ldname,r/w,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max,Svt_Cur,Svt_Avg,IOSz_Cur,IOSz_Avg,Qlen,Idle_Cur,Idle_Avg,Time,Date"}
			else 		{	Add-Content -Path $tempFile -Value "Ldname,r/w,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max,Svt_Cur,Svt_Avg,IOSz_Cur,IOSz_Avg,Qlen,Time,Date"		}
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "r/w")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$a=$s.split(",")
							$global:time1 = $a[0]
							$global:date1 = $a[1]
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "Ldname"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")# Replace one or more spaces with comma to build CSV line
					$aa=$s.split(",").length
					if ($aa -eq "11")	{	continue	}
					if (($aa -eq "13") -and ($IDLEP))	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s		
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	else{	return $Result	}
} 
}

Function Get-A9StatisticLinkUtilization
{
<#
.SYNOPSIS
	The Get-StatLink command displays statistics for link utilization for all nodes in a timed loop.
.DESCRIPTION
	The Get-StatLink command displays statistics for link utilization for all nodes in a timed loop.

.EXAMPLE
	PS:> Get-A9StatisticLinkUtilization -Iteration 1

	This Example displays statistics for link utilization for all nodes in a timed loop.
.EXAMPLE
	PS:> Get-A9StatisticLinkUtilization -Interval 3 -Iteration 1 
	
	This Example displays statistics for link utilization for all nodes in a timed loop, with a delay of 3 sec.
.EXAMPLE
	PS:> Get-A9StatisticLinkUtilization -Detail -Iteration 1
.PARAMETER Detail
	Displays detailed information regarding the Queue statistics.	 
.PARAMETER Interval
	Specifies the interval, in seconds, that statistics are sampled using an integer from 1 through 2147483.
.PARAMETER Iteration 
	Specifies that I/O statistics are displayed a specified number of times as indicated by the number argument using an integer from 1 through 2147483647.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]					[switch]	$Detail,
		[Parameter(Mandatory=$true)]	[String]	$Interval,
		[Parameter()]					[String]	$Iteration
	)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statlink -iter $Iteration "
	if ($Detail)	{	$cmd+=" -detail "	}
	if ($Interval)	{	$cmd+=" -d $Interval "	}
	$Result = Invoke-A9CLICommand -cmds  $cmd
	$range1 = $Result.count
	if($range1 -eq "3")	{	return "No data available"	}	
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			Add-Content -Path $tempFile -Value "Node,Q,ToNode,XCB_Cur,XCB_Avg,XCB_Max,KB_Cur,KB_Avg,KB_Max,XCBSz_KB_Cur,XCBSz_KB_Avg,Time,Date"
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "Local DMA 0")
						{	$s= [regex]::Replace($s,"Local DMA 0","Local_DMA_0")			
						}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s,"-+","-")
					$s= [regex]::Replace($s," +",",")
					if ($s -match "XCB_sent_per_second")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$a=$s.split(",")
							$global:time1 = $a[0]
							$global:date1 = $a[1]
							continue
						}
					if ($s -match "Local DMA 0")
						{	 $s= [regex]::Replace($s,"Local DMA 0","Local_DMA_0")			
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "ToNode"))	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	else{	return $Result	}
} 
}

Function Get-APhysicalDiskStatisticsReports_CLI
{
<#
.SYNOPSIS
	The Get-StatPD command displays the read/write (I/O) statistics for physical disks in a timed loop.
.DESCRIPTION
    The Get-StatPD command displays the read/write (I/O) statistics for physical disks in a timed loop.   
.EXAMPLE
	PS:> Get-APhysicalDiskStatisticsReports_CLI -RW –Iteration 1
	
	This example displays one iteration of I/O statistics for all PDs.
.EXAMPLE  
	PS:> Get-APhysicalDiskStatisticsReports_CLI -IDLEP –nodes 2 –Iteration 1

	This example displays one iteration of I/O statistics for all PDs with the specification idlep preference of node 2.
.EXAMPLE  
	PS:> Get-APhysicalDiskStatisticsReports_CLI -NI -wwn 1122112211221122 –nodes 2 –Iteration 1

	This Example Specifies that statistics for a particular Physical Disk (PD) identified by World Wide Names (WWNs) and nodes
.PARAMETER Devinfo
	Indicates the device disk type and speed.
.PARAMETER RW
	Specifies that reads and writes are displayed separately. If this option is not used, then the total of reads plus writes is displayed.
.PARAMETER Begin
    Specifies that I/O averages are computed from the system start time. If not specified, the average is computed since the first iteration of the command.
.PARAMETER IDLEP
	Specifies the percent of idle columns in the output.
.PARAMETER NI
	Specifies that statistics for only non-idle devices are displayed. This option is shorthand for the option				
.PARAMETER wwn 
	Specifies that statistics for a particular Physical Disk (PD) identified by World Wide Names (WWNs) are displayed.
.PARAMETER nodes  
	Specifies that the display is limited to specified nodes and PDs connected to those nodes
.PARAMETER ports   
	Specifies that the display is limited to specified ports and PDs connected to those ports
.PARAMETER  Iteration
	Specifies that the histogram is to stop after the indicated number of iterations using an integer from 1 through 2147483647.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$RW,
		[Parameter()]	[switch]	$IDLEP,
		[Parameter()]	[switch]	$Begin,
		[Parameter()]	[switch]	$NI,	
		[Parameter()]	[String]	$wwn ,
		[Parameter()]	[String]	$nodes,
		[Parameter()]	[String]	$slots,
		[Parameter()]	[String]	$ports ,
		[Parameter(Mandatory=$true)]	[String]	$Iteration ,
		[Parameter()]	[switch]	$DevInfo		
	)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statpd "	
	$cmd+=" -iter $Iteration "
	if($RW)		{	$cmd +=" -rw "	}
	if($Begin)	{	$cmd+=" -begin "	}
	if($IDLEP)	{	$cmd+=" -idlep "	}	
	if($NI)		{	$cmd+=" -ni "	}
	if($DevInfo){	$cmd+=" -devinfo "	}
	if ($wwn)	{	$cmd+=" -w $wwn "	}	
	if ($nodes)	{	$cmd+=" -nodes $nodes "	}	
	if ($slots)	{	$cmd+=" -slots $slots "	}	
	if ($ports ){	$cmd+=" -ports $ports "	}			
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	$range1 = $Result.count	
	if($range1 -eq "4")	{	return "No data available"	}	
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count - 3
			if($DevInfo)	{	Add-Content -Path $tempFile -Value "ID,Port,Type,K_RPM,r/w,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max,Svt_Cur,Svt_Avg,IOSz_Cur,IOSz_Avg,Qlen,Idle_Cur,Idle_Avg,Time,Date"	}
			else			{	Add-Content -Path $tempFile -Value "ID,Port,r/w,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max,Svt_Cur,Svt_Avg,IOSz_Cur,IOSz_Avg,Qlen,Idle_Cur,Idle_Avg,Time,Date"	}
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "r/w")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$a=$s.split(",")
							$global:time1 = $a[0]
							$global:date1 = $a[1]				
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "Port"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")# Replace one or more spaces with comma to build CSV line
					$aa=$s.split(",").length
					if ($aa -eq "13")	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}
	else{	return $Result	}
}
}

Function Get-A9PortStatisticsReports_CLI
{
<#
.SYNOPSIS
	The command displays read/write (I/O) statistics for ports.
.DESCRIPTION
	The command displays read/write (I/O) statistics for ports.
.EXAMPLE
	PS:> Get-A9PortStatisticsReports_CLI -Iteration 1
	This example displays one iteration of I/O statistics for all ports.
.EXAMPLE  
	PS:> Get-A9PortStatisticsReports_CLI -Both -Iteration 1
	This example displays one iteration of I/O statistics for all ports,Show data transfers only. 
.EXAMPLE  
	Get-A9PortStatisticsReports_CLI -Host -nodes 2 -Iteration 1
	This example displays I/O statistics for all ports associated with node 2.
.PARAMETER Both
	Show data transfers only.
.PARAMETER Ctl
	Show control transfers only.
.PARAMETER Data
	Show both data and control transfers only.
.PARAMETER Rcfc
	includes only statistics for Remote Copy over Fibre Channel ports related to cached READ requests
.PARAMETER Rcip
	Includes only statistics for Ethernet configured Remote Copy ports.
.PARAMETER RW
	Specifies that the display includes separate read and write data.
.PARAMETER Begin
	Specifies that I/O averages are computed from the system start time
.PARAMETER Idlep
	Specifies the percent of idle columns in the output.
.PARAMETER HostPort
	Displays only host ports (target ports).
.PARAMETER Disk
	Displays only disk ports (initiator ports).
.PARAMETER Rcfc
	Displays only Fibre Channel remote-copy configured ports.
.PARAMETER NI
	Specifies that statistics for only non-idle devices are displayed.
.PARAMETER FS
	Includes only statistics for File Persona ports.
.PARAMETER Peer
	Specifies to display only host ports (target ports), only disk ports (initiator ports), only Fibre Channel Remote Copy configured ports, or
	only Fibre Channel ports for Data Migration. If no option is specified, all ports are displayed.
.PARAMETER nodes  
	Specifies that the display is limited to specified nodes and PDs connected to those nodes
.PARAMETER ports   
	Specifies that the display is limited to specified ports and PDs connected to those ports
.PARAMETER slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified
	as a series of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all
	disks on all slots are displayed.
.PARAMETER  Iteration
	Specifies that the histogram is to stop after the indicated number of iterations using an integer from
	1 through 2147483647.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Both ,
		[Parameter()]	[switch]	$Ctl ,
		[Parameter()]	[switch]	$Data ,
		[Parameter()]	[switch]	$Rcfc ,
		[Parameter()]	[switch]	$Rcip ,
		[Parameter()]	[switch]	$RW ,
		[Parameter()]	[switch]	$FS ,	
		[Parameter()]	[switch]	$HostPort ,
		[Parameter()]	[switch]	$Peer ,
		[Parameter()]	[switch]	$IDLEP,
		[Parameter()]	[switch]	$Begin,
		[Parameter()]	[switch]	$NI,
		[Parameter()]	[switch]	$Disk,
		[Parameter()]	[String]	$nodes,
		[Parameter()]	[String]	$slots,
		[Parameter()]	[String]	$ports ,	
		[Parameter(Mandatory=$true)]	[String]	$Iteration 
	)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statport "
	$cmd+=" -iter $Iteration "		
	if($Both)		{	$cmd +=" -both "	}
	if($Ctl)		{	$cmd +=" -ctl "		}
	if($Data)		{	$cmd +=" -data "	}
	if($Rcfc)		{	$cmd +=" -rcfc "	}
	if($Rcip)		{	$cmd +=" -rcip "	}
	if($FS)			{	$cmd +=" -fs "		}
	if($HostPort)	{	$cmd +=" -host "	}
	if($Disk)		{	$cmd +=" -disk "	}
	if($Peer)		{	$cmd +=" -peer "	}	
	if($RW)			{	$cmd +=" -rw "		}
	if($Begin)		{	$cmd+=" -begin "	}
	if($IDLEP)		{	$cmd+=" -idlep "	}	
	if($NI)			{	$cmd+=" -ni "		}
	if ($nodes)		{	$cmd+=" -nodes $nodes "	}
	if ($slots)		{	$cmd+=" -slots $slots "	}
	if ($ports )	{	$cmd+=" -ports $ports "	}				
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	$range1 = $Result.count
	if($range1 -eq "4")	{	return "No data available"	}
	if(($Both) -And ($range -eq "6"))	{	return "No data available"	}
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -3
			if($Rcip)		{	Add-Content -Path $tempFile -Value "Port,r/w,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max,Errs,Drops,Time,Date"	}
			elseif ($IDLEP)	{	Add-Content -Path $tempFile -Value "Port,D/C,r/w,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max, Svt_Cur, Svt_Avg,IOSz_Cur,IOSz_Avg,Qlen,Idle_Cur,Idle_Avg,Time,Date"	}
			else			{	Add-Content -Path $tempFile -Value "Port,D/C,r/w,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max, Svt_Cur, Svt_Avg,IOSz_Cur,IOSz_Avg,Qlen,Time,Date"	}	
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "r/w")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$a=$s.split(",")
							$global:time1 = $a[0]
							$global:date1 = $a[1]
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "Port"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")# Replace one or more spaces with comma to build CSV line
					$aa=$s.split(",").length
					if (($aa -eq "12") -or ($aa -eq "8") -or ($aa -eq "8"))	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			Remove-Item $tempFile
		}	
	else{	return $Result	}
}
}

Function Get-A9RCopyStatisticalReports_CLI
{
<#
.SYNOPSIS
	The command displays statistics for remote-copy volumes in a timed loop.
.DESCRIPTION
    The command displays statistics for remote-copy volumes in a timed loop.
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports_CLI -Iteration 1
	This Example displays statistics for remote-copy volumes in a timed loop.
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports_CLI -Iteration 1 -ASync
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports_CLI -Iteration 1 -Sync -VVname $VV
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports_CLI -Iteration 1 -TargetSum
.EXAMPLE
	PS:> Get-A9RCopyStatisticalReports_CLI -Iteration 1 -VVSum   
.EXAMPLE  
	PS:> Get-A9RCopyStatisticalReports_CLI -Iteration 1 -periodic 

	This Example displays statistics for remote-copy volumes in a timed loop and show only volumes that are being copied in asynchronous periodic mode	
.EXAMPLE  
	PS:> Get-A9RCopyStatisticalReports_CLI -target demotarget1  -Iteration 1

	This Example displays statistics for remote-copy volumes in a timed loop and Show only volumes whose group is copied to the specified target name.
.PARAMETER Async     
	Show only volumes which are being copied in asynchronous mode.
.PARAMETER sync		
	Show only volumes that are being copied in synchronous mode.
.PARAMETER periodic	
	Show only volumes that are being copied in asynchronous periodic mode	
.PARAMETER primary		
	Show only volumes that are in the primary role.
.PARAMETER secondary	
	Show only volumes that are in the secondary role.
.PARAMETER targetsum	
	Specifies that the sums for all volumes of a target are displayed.
.PARAMETER portsum	
	Specifies that the sums for all volumes on a port are displayed.
.PARAMETER groupsum	
	Specifies that the sums for all volumes of a group are displayed.
.PARAMETER vvsum	
	Specifies that the sums for all targets and links of a volume are displayed.
.PARAMETER domainsum	
	Specifies that the sums for all volumes of a domain are displayed.
.PARAMETER ni			
	Specifies that statistics for only non-idle devices are displayed.
.PARAMETER target   
	Show only volumes whose group is copied to the specified target name.
.PARAMETER port    
	Show only volumes that are copied over the specified port or pattern.
.PARAMETER group 
	Show only volumes whose group matches the specified group name or pattern.
.PARAMETER VVname	
	Displays statistics only for the specified virtual volume or volume name pattern.
.PARAMETER  Iteration
	Specifies that the histogram is to stop after the indicated number of iterations using an integer from 1 through 2147483647.
.PARAMETER DomainName
	Shows only the virtual volumes that are in domains with names that match the specified domain name(s) or pattern(s).	
.PARAMETER Interval
	Specifies the interval in seconds that statistics are sampled from
	using an integer from 1 through 2147483. If no count is specified, the
	command defaults to 2 seconds.
.PARAMETER Subset
	Show subset statistics for Asynchronous Remote Copy on a per group basis.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)][String]	$Iteration ,		
		[Parameter()]				[String]	$Interval ,	
		[Parameter()]				[String]	$Target ,		
		[Parameter()]				[String]	$Port,
		[Parameter()]				[String]	$Group ,
		[Parameter()]				[String]	$VVname  ,
		[Parameter()]				[String]	$DomainName  ,
		[Parameter()]				[switch]	$ASync,
		[Parameter()]				[switch]	$Sync,	
		[Parameter()]				[switch]	$Periodic,
		[Parameter()]				[switch]	$Primary,		
		[Parameter()]				[switch]	$Secondary,		
		[Parameter()]				[switch]	$TargetSum,
		[Parameter()]				[switch]	$PortSum,	
		[Parameter()]				[switch]	$GroupSum,
		[Parameter()]				[switch]	$VVSum,
		[Parameter()]				[switch]	$DomainSum,
		[Parameter()]				[switch]	$NI,
		[Parameter()]				[switch]	$SubSet
	)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statrcvv "	
	$cmd+=" -iter $Iteration "
	if ($Interval)	{	$cmd+=" -d $Interval"	}	
	if ($Target)	{	$cmd+=" -t $Target"	}	
	if ($Port)		{	$cmd+=" -port $Port "	}
	if ($Group)		{	$cmd+=" -g $Group"	}
	if($ASync)		{	$cmd += " -async "	}
	if($Sync)		{	$cmd += " -sync "	}
	if($Periodic)	{	$cmd += " -periodic "	}
	if($Primary)	{	$cmd += " -primary "	}
	if($Secondary)	{	$cmd += " -secondary "	}
	if($TargetSum)	{	$cmd += " -targetsum "	}
	if($PortSum)	{	$cmd += " -portsum "	}
	if($GroupSum)	{	$cmd += " -groupsum "	}
	if($VVSum)		{	$cmd += " -vvsum "	}
	if($DomainSum)	{	$cmd += " -domainsum "	}
	if($DomainName)	{	$cmd += " -domain $DomainName "	}
	if($NI)			{	$cmd += " -ni "	}
	if($SubSet)		{	$cmd += " -subset "	}
	if ($VVname)
		{	$s= Get-A9Vv_CLI -vvName  $VVname
			if ($s -match $VVname )		{	$cmd+=" $VVname"	}
			else						{	Return "FAILURE : -VVname $VVname  is Unavailable to execute. "	}		
		}
	$Result = Invoke-A9CLICommand -cmds  $cmd
	$range1 = $Result.count
	if($range1 -eq "4")	{	return "No data available"	}
	if( $Result.Count -gt 1)
	{	$tempFile = [IO.Path]::GetTempFileName()
		$LastItem = $Result.Count - 2
		if($TargetSum)		{	Add-Content -Path $tempFile -Value "Target,Mode,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
		elseif ($PortSum)	{	Add-Content -Path $tempFile -Value "Link,Target,Type,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
		elseif ($GroupSum)	{	Add-Content -Path $tempFile -Value "Group,Target,Mode,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
		elseif ($VVSum)		{	Add-Content -Path $tempFile -Value "VVname,RCGroup,Target,Mode,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
		elseif ($DomainSum)	{	Add-Content -Path $tempFile -Value "Domain,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
		else 				{	Add-Content -Path $tempFile -Value "VVname,RCGroup,Target,Mode,Port,Type,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"}
		foreach ($s in  $Result[0..$LastItem] )
		{	$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
			if ($s -match "I/O")
				{	$a=$s.split(",")
					$global:time1 = $a[0]
					$global:date1 = $a[1]
					continue
				}
			if (($s -match "-------") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "Avg"))	{	continue	}
			$aa=$s.split(",").length
			if ($aa -eq "11")	{	continue	}			
			$s +=",$global:time1,$global:date1"
			Add-Content -Path $tempFile -Value $s		
		}
		Import-Csv $tempFile
		remove-item $tempFile
	}
	else
	{	return $Result
	}
}
}
Function Get-A9vLunStatisticsReports_CLI
{
<#
.SYNOPSIS
	The command displays statistics for Virtual Volumes (VVs) and Logical Unit Number (LUN) host attachments.
.DESCRIPTION
	The Get-StatVLun command displays statistics for Virtual Volumes (VVs) and Logical Unit Number (LUN) host attachments.
.EXAMPLE
	PS:> Get-A9vLunStatisticsReports_CLI -Iteration 1

	This example displays statistics for Virtual Volumes (VVs) and Logical Unit Number (LUN) host attachments.
.EXAMPLE  
	PS:> Get-A9vLunStatisticsReports_CLI -vvSum -Iteration 1

	This example displays statistics for Virtual Volumes (VVs) and Specifies that sums for VLUNs of the same VV are displayed.
.EXAMPLE  
	PS:> Get-A9vLunStatisticsReports_CLI -vvSum -RW -Iteration 1
.EXAMPLE  
	PS:> Get-A9vLunStatisticsReports_CLI -vvSum -RW -VVname xxx -Iteration 1
.EXAMPLE  
	PS:> Get-A9vLunStatisticsReports_CLI -VVname demovv1 -Iteration 1

	This example displays statistics for Virtual Volumes (VVs) and only Logical Disks (LDs) mapped to VVs that match any of the specified names to be displayed.
.PARAMETER LW  
	Lists the host’s World Wide Name (WWN) or iSCSI names.
.PARAMETER Domainsum
	Specifies that sums for VLUNs are grouped by domain in the display.
.PARAMETER vvSum
	Specifies that sums for VLUNs of the same VV are displayed.
.PARAMETER Hostsum
	Specifies that sums for VLUNs are grouped by host in the display.
.PARAMETER RW
	Specifies reads and writes to be displayed separately.
.PARAMETER Begin
	Specifies that I/O averages are computed from the system start time.
.PARAMETER IDLEP 
	Includes a percent idle columns in the output.
.PARAMETER NI
	Specifies that statistics for only nonidle devices are displayed.
.PARAMETER domian    
	Shows only Virtual Volume Logical Unit Number (VLUNs) whose VVs are in domains with names that match one or more of the specified domain names or patterns.
.PARAMETER VVname     
	Requests that only Logical Disks (LDs) mapped to VVs that match any of the specified names to be displayed.
.PARAMETER LUN  
	Specifies that VLUNs with LUNs matching the specified LUN(s) or pattern(s) are displayed.
.PARAMETER nodes
	Specifies that the display is limited to specified nodes and Physical Disks (PDs) connected to those
	nodes.
.PARAMETER  Iteration
	Specifies that the histogram is to stop after the indicated number of iterations using an integer from
	1 through 2147483647.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]		[switch]	$RW,
		[Parameter()]		[switch]	$IDLEP,
		[Parameter()]		[switch]	$Begin,
		[Parameter()]		[switch]	$NI, 
		[Parameter()]		[switch]	$LW,
		[Parameter()]		[switch]	$DomainSum,
		[Parameter()]		[switch]	$vvSum,
		[Parameter()]		[switch]	$HostSum,
		[Parameter()]		[String]	$domian  ,
		[Parameter()]		[String]	$VVname ,
		[Parameter()]		[String]	$LUN ,
		[Parameter()]		[String]	$nodes,
		[Parameter(Mandatory=$true)]	[String]	$Iteration 
)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statvlun "
	if($Iteration)	{	$cmd+=" -iter $Iteration "		}
	if($RW)			{	$cmd +=" -rw "	}
	if($Begin)		{	$cmd+=" -begin "	}
	if($IDLEP)		{	$cmd+=" -idlep "	}	
	if($NI)			{	$cmd+=" -ni "	}	
	if($LW)			{	$cmd +=" -lw "	}
	if($DomainSum)	{	$cmd+=" -domainsum "	}
	if($vvSum)		{	$cmd+=" -vvsum "	}	
	if($HostSum)	{	$cmd+=" -hostsum "	}
	if ($domian)	{	$cmd+=" -domain $domian"	}	
	if ($VVname)
		{	$s= Get-Vv -vvName  $VVname
			if ($s -match $VVname )	{	$cmd+=" -v $VVname"	}
			else					{	Return "FAILURE : -VVname $VVname  is Unavailable to execute. "	}		
		}
	if ($LUN)	{	$cmd+=" -l $LUN"	}	
	if ($nodes)	{	$cmd+=" -nodes $nodes"	}				
	$Result = Invoke-A9CLICommand -cmds  $cmd
	$range1 = $Result.count
	if($range1 -eq "4")					{	return "No data available"	}	
	if(($range1 -eq "6") -and ($NI))	{	return "No data available"	}
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count - 3
			if($LW)				{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,Host_WWN/iSCSI_Name,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"}
			elseif($DomainSum)	{	Add-Content -Path $tempFile -Value "Domain,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date" 	}
			elseif($vvSum)		{	Add-Content -Path $tempFile -Value "VVname,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
			elseif($RW)			{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
			elseif($Begin)		{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
			elseif($IDLEP)		{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,IOSz_Cur,IOSz_Avg,Time,Date"	}
			elseif($NI)			{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
			elseif($HostSum)	{	Add-Content -Path $tempFile -Value "Hostname,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
			else				{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date" 	}
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")	
					if ($s -match "r/w")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$a=$s.split(",")
							$global:time1 = $a[0]
							$global:date1 = $a[1]
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "cur"))	{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")# Replace one or more spaces with comma to build CSV line
					$aa=$s.split(",").length
					if ($aa -eq "11")	{	continue	}
					if (($aa -eq "13") -And ($IDLEP))	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile
			remove-item $tempFile
		}
	else{	return $Result	}
}
} 

Function Get-A9VvStatisticsReports
{
<#
.SYNOPSIS
	The command displays statistics for Virtual Volumes (VVs) in a timed loop.
.DESCRIPTION
	The command displays statistics for Virtual Volumes (VVs) in a timed loop.
.EXAMPLE
	PS:> Get-A9VvStatisticsReports -Iteration 1
	
	This Example displays statistics for Virtual Volumes (VVs) in a timed loop.
.EXAMPLE  
	PS:> Get-A9VvStatisticsReports  -RW -Iteration 1

	This Example displays statistics for Virtual Volumes (VVs) with specification of read/write option.
.EXAMPLE  
	PS:> Get-A9VvStatisticsReports -Delay -Seconds 2 -Iteration 1

	Specifies the interval in seconds that statistics are sampled from using an integer from 1 through 2147483.
.EXAMPLE  
	PS:> Get-A9VvStatisticsReports -RW -domain ZZZ -VVname demovv1 -Iteration 1
	This Example displays statistics for Virtual Volumes (VVs) with Only statistics are displayed for the specified VVname.			
.PARAMETER RW
	Specifies reads and writes to be displayed separately.
.PARAMETER Delay
	<Seconds> Specifies the interval in seconds that statistics are sampled from using an integer from 1 through 2147483. 
	If no count is specified, the command defaults to 2 seconds.
.PARAMETER NI
	Specifies that statistics for only non-idle devices are displayed. This option is shorthand for the option -filt curs,t,iops,0.
.PARAMETER domian    
	Shows only Virtual Volume Logical Unit Number (VLUNs) whose VVs are in domains with names that match one or more of the specified domain names or patterns.
.PARAMETER  Iteration
	Specifies that the histogram is to stop after the indicated number of iterations using an integer from
	1 through 2147483647.
.PARAMETER  VVname
	Only statistics are displayed for the specified VV.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]				[switch]	$RW ,
		[Parameter()]				[switch]	$NI ,
		[Parameter()]				[String]	$Delay  ,
		[Parameter()]				[String]	$domian  ,
		[Parameter()]				[String]	$VVname ,	
		[Parameter(Mandatory=$true)][String]	$Iteration
	)			
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd= "statvv "
	if($Iteration)	{	$cmd+=" -iter $Iteration "	}
	if ($RW)		{	$cmd+=" -rw "				}
	if ($Delay)		{	$cmd+=" -d $Delay "			}
	if ($NI)		{	$cmd+=" -ni "				}
	if ($domian)	{	$cmd+=" -domain $domian"	}			
	if ($VVname)	{	$cmd+="  $VVname"			}	
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	$range1 = $Result.count
	if($range1 -eq "4")	{	return "No data available"	}	
	if ( $Result.Count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count
			Add-Content -Path $tempFile -Value "VVname,r/w,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,KB_Max,Svt_Cur,Svt_Avg,IOSz_Cur,IOSz_Avg,Qlen,Time,Date"
			foreach ($s in  $Result[0..$LastItem] )
				{	if ($s -match "r/w")
						{	$s= [regex]::Replace($s,"^ +","")
							$s= [regex]::Replace($s," +"," ")
							$s= [regex]::Replace($s," ",",")
							$a=$s.split(",")
							$global:time1 = $a[0]
							$global:date1 = $a[1]
							continue
						}
					if (($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "VVname"))		{	continue	}
					$s= [regex]::Replace($s,"^ +","")
					$s= [regex]::Replace($s," +",",")# Replace one or more spaces with comma to build CSV line
					$aa=$s.split(",").length
					if ($aa -eq "11")	{	continue	}
					$s +=",$global:time1,$global:date1"
					Add-Content -Path $tempFile -Value $s
				}
			Import-Csv $tempFile	
			remove-item $tempFile
		}
	else{	return $Result	}	
}
}

Function Set-A9StatisticsInUseChunklets
{
<#
.SYNOPSIS
    The Set-Statch command sets the statistics collection mode for all in-use chunklets on a Physical Disk (PD).
.DESCRIPTION
	The Set-Statch command sets the statistics collection mode for all in-use chunklets on a Physical Disk (PD).
.EXAMPLE 
	PS:> Set-A9StatisticsInUseChunklets -Start -LDname test1 -CLnum 1  
	
	This example starts and stops the statistics collection mode for chunklets.with the LD name test1.
.PARAMETER Start  
    Specifies that the collection of statistics is either started or stopped for the specified Logical Disk (LD) and chunklet.
.PARAMETER Stop  
    Specifies that the collection of statistics is either started or stopped for the specified Logical Disk (LD) and chunklet.
.PARAMETER LDname 	
	Specifies the name of the logical disk in which the chunklet to be configured resides.
.PARAMETER CLnum 	
	Specifies the chunklet that is configured using the setstatch command.	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]											[switch]	$Start,
		[Parameter()]											[switch]	$Stop,
		[Parameter(ValueFromPipeline=$true, Mandatory=$true)]	[String]	$LDname,
		[Parameter(ValueFromPipeline=$true, Mandatory=$true)]	[String]	$CLnum
	)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd1 = "setstatch "
	if ($Start)		{	$cmd1 += " start "	}
	if ($Stop)		{	$cmd1 += " stop "	}
	if($LDname)		{	$cmd2="showld"
						$Result1 = Invoke-A9CLICommand -cmds  $cmd2
						if($Result1 -match $LDname)	{	$cmd1 += " $LDname "	}
						Else		{	return "Error:  LDname  is Invalid ."	}
					}
	if($CLnum)		{	$cmd1+="$CLnum"	}
	$Result = Invoke-A9CLICommand -cmds  $cmd1
	write-verbose "   The Set-Statch command sets the statistics collection mode for all in-use chunklets on a Physical Disk (PD).->$cmd"
	if([string]::IsNullOrEmpty($Result))
		{	return  "Success : Set-Statch $Result "	}
	else
		{	return  "FAILURE : While Executing Set-Statch $Result"	} 
} 
}

Function Set-A9StatisticsCollectionPhysicalDiskChunklets
{
<#
.SYNOPSIS
    The command starts and stops the statistics collection mode for chunklets.
.DESCRIPTION
    The command starts and stops the statistics collection mode for chunklets.
.EXAMPLE
	PS:> Set-A9StatisticsCollectionPhysicalDiskChunklets -Start -PD_ID 2
	
	This Example sets the statistics collection mode for all in-use chunklets on a Physical Disk (PD) 2.
.PARAMETER Start  
    Specifies that the collection of statistics is either started or stopped for the specified Logical Disk (LD) and chunklet.
.PARAMETER Stop  
    Specifies that the collection of statistics is either started or stopped for the specified Logical Disk (LD) and chunklet.
.PARAMETER PD_ID   
    Specifies the PD ID.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]					[switch]	$Start,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$Stop,
		[Parameter(ValueFromPipeline=$true, Mandatory=$true)]	[String]	$PD_ID
	)			
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd1 = "setstatpdch "
	if ($Start)		{	$cmd1 += " start "	}
	if ($Stop)		{	$cmd1 += " stop "	}
	$cmd2="showpd"
	$Result1 = Invoke-A9CLICommand -cmds  $cmd2
	if($Result1 -match $PD_ID)	{	$cmd1 += " $PD_ID "	}
	Else						{	return "Error:  PD_ID   is Invalid ."	}						
	$Result = Invoke-A9CLICommand -cmds  $cmd1
	if([string]::IsNullOrEmpty($Result))
		{	write-host "Success : Executing Set-StatPdch 	 " -ForegroundColor green
			return $Result  
		}
	else
	{	write-warning "FAILURE : While Executing Set-StatPdch 	"
		return $Result  
	} 
}
}

Function Measure-A9System
{
<#
.SYNOPSIS
	Change the layout of a storage system.
.DESCRIPTION
	The Measure-SYS command is used to analyze and detect poor layout and disk utilization across an entire storage system. The
	command runs a series of low level operations to re-balance resources on the system.
.PARAMETER Cpg
	Limits the scope of a Measure-SYS operation to the named CPG(s). The specified CPGs must all be in the same domain as the user.
	If this option is specified the intra-node (tunenodech) phase is not run. -chunkpct and -tunenodech cannot be used with this option.
.PARAMETER Nodepct
	Controls the detection of utilization imbalances between nodes. If any node has a PD devtype where the average utilization is
	more than <percentage> less than the average for that devtype, then detailed VV level analysis is performed. VVs which are
	poorly balanced between nodes will have a tune generated to correct the imbalance. <percentage> must be between 1 and 100. The default value is 3.
.PARAMETER Spindlepct
	Specifies the percentage difference between node pairs that can exist before Measure-SYS warns that an imbalance exists. The percentage
	difference calculated between node pairs must be less than spindlepct. <percentage> must be between 1 and 200. 200 is the
	least restrictive and would allow the Measure-SYS to not warn with any difference in the number of PDs, while 1 is the most
	restrictive. 0 cannot be specified as this would always generate a warning. The default for <percentage> is 50 (allow for a 50% difference).
.PARAMETER Force
	Bypass top-level inter-node balance checks and force detailed analysis of every VV. This option can be used to complete the
	re-balance of a relatively well balanced system where only a few volumes are unbalanced.
.PARAMETER Slth
	Slice threshold. Volumes above this size will be tuned in slices. <threshold> must be in multiples of 128GiB. Minimum is 128GiB. Default is 2TiB. Maximum is 16TiB.
.PARAMETER Slsz
	Slice size. Size of slice to use when volume size is greater than <threshold>. <size> must be in multiples of 128GiB. Minimum is 128GiB. Default is 2TiB. Maximum is 16TiB.
.PARAMETER Chunkpct
	Controls the detection of any imbalance in PD chunklet allocation between PDs owned by individual nodes. If a PD has
	utilization of more than <percentage> less than the average for that device type, then that disk can potentially be tuned.
	<percentage> must be between 1 and 100. The default value is 10. This option cannot be used with the -cpg option.
.PARAMETER Devtype
	Only tune the specified device type. Applies to the intra-node tune phase only and must be used with the -tunenodech option. Multiple
	devtypes can be specified. If -devtype is not used, all devtypes will be tuned when -tunenodech is specified.
.PARAMETER Fulldiskpct
	This option is used in the intra-node tuning phase. If a PD has more than <percentage> of its capacity utilized, chunklet
	movement is used to reduce its usage to <percentage> before LD tuning is used to complete the rebalance. For example, if a PD is 98% utilized
	and <percentage> is 90, chunklets will be redistributed to other PDs until the utilization is less than 90%. If <percentage> is less than the
	devtype average then the calculated average will be used instead. <percentage> must be between 1 and 100. The default value is 90.
.PARAMETER Maxchunk
	Specifies the maximum number of chunklets which can be moved from any PD in a single operation. <number> must be between 1 and 8. The default value is 8.
.PARAMETER Tunenodech
	Specifies that only intra-node rebalancing should be performed.
	LD tuning options:
.PARAMETER Ss
	Trigger LD re-tuning for any LD where the stepsize value does not match the parent CPG.
    Cleaning and compacting options:
.PARAMETER Cleanwait
	Maximum number of minutes to wait for chunklet cleaning after each tune. <value> must be between 0 (tunes will be started immediately) and
	720 (12 hours). The default value is 120 (2 hours).
.PARAMETER Compactmb
	Used in the inter-node and LD tuning phases. Once tunes have moved an amount of space greater than <value> the source CPG will be compacted.
	<value> can be between 0 (compact after every tune) and 2TiB. The default is 512GiB.
	General tuning options:
.PARAMETER Dr
	Specifies that the command is a dry run and that the system will not be tuned. The result of the analysis will be displayed.
.PARAMETER Maxtasks
	Specifies the maximum number of individual inter-node tune tasks which the Measure-SYS command can run simultaneously. <number> must	
	be between 1 and 8. The default value is 2.
.PARAMETER Maxnodetasks
	Specifies the maximum number of tunenodech tasks which the Measure-SYS command can run simultaneously. <number> must be between 1 and 8. The default value is 1.
.PARAMETER Waittask
	Wait for all tasks created by this command to complete before returning.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(
	[Parameter()]	[String]	$Cpg,
	[Parameter()]	[String]	$Nodepct,
	[Parameter()]	[String]	$Spindlepct,
	[Parameter()]	[switch]	$Force,
	[Parameter()]	[String]	$Slth,
	[Parameter()]	[String]	$Slsz,
	[Parameter()]	[String]	$Chunkpct,
	[Parameter()]	[String]	$Devtype,
	[Parameter()]	[String]	$Fulldiskpct,
	[Parameter()]	[String]	$Maxchunk,
	[Parameter()]	[switch]	$Tunenodech,
	[Parameter()]	[switch]	$Ss,
	[Parameter()]	[String]	$Cleanwait,
	[Parameter()]	[String]	$Compactmb,
	[Parameter()]	[switch]	$Dr,
	[Parameter()]	[String]	$Maxtasks,
	[Parameter()]	[String]	$Maxnodetasks,
	[Parameter()]	[switch]	$Waittask
)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$Cmd = " tunesys -f "
	if($Cpg)		{	$Cmd += " -cpg $Cpg " }
	if($Nodepct)	{	$Cmd += " -nodepct $Nodepct " }
	if($Spindlepct)	{	$Cmd += " -spindlepct $Spindlepct " }
	if($Force)		{	$Cmd += " -force " }
	if($Slth)		{	$Cmd += " -slth $Slth " }
	if($Slsz)		{	$Cmd += " -slsz $Slsz " }
	if($Chunkpct)	{	$Cmd += " -chunkpct $Chunkpct " }
	if($Devtype)	{	$Cmd += " -devtype $Devtype " }
	if($Fulldiskpct){	$Cmd += " -fulldiskpct $Fulldiskpct " }
	if($Maxchunk)	{	$Cmd += " -maxchunk $Maxchunk " }
	if($Tunenodech)	{	$Cmd += " -tunenodech " }
	if($Ss) 		{	$Cmd += " -ss " }
	if($Cleanwait)	{	$Cmd += " -cleanwait $Cleanwait " }
	if($Compactmb)	{	$Cmd += " -compactmb $Compactmb " }
	if($Dr)			{	$Cmd += " -dr "	}
	if($Maxtasks)	{	$Cmd += " -maxtasks $Maxtasks " }
	if($Maxnodetasks){	$Cmd += " -maxnodetasks $Maxnodetasks " }
	if($Waittask)	{	$Cmd += " -waittask " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}
Function Optimize-A9PhysicalDisk
{
<#
.SYNOPSIS
	show physical disks with high service times and optionally perform load balancing.
.DESCRIPTION
	The command identifies physical disks with high service times and optionally executes load balancing.
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
.PARAMETER VV_Name
	Specifies that the physical disks used by the indicated virtual volume name are included for statistic sampling.
.PARAMETER D
	Specifies the interval, in seconds, that statistics are sampled using an integer from 1 through 2147483. If no interval is specified, the option defaults to 30 seconds.
.PARAMETER Iter
	Specifies that I/O statistics are sampled a specified number of times as indicated by the number argument using an integer greater than 0. If 0
	is specified, I/O statistics are looped indefinitely. If this option is not specified, the command defaults to 1 iteration.
.PARAMETER Freq
	Specifies the interval, in minutes, that the command enters standby mode between iterations using an integer greater than 0. If this option is
	not specified, the number of iterations is looped indefinitely.
.PARAMETER Vvlayout
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
.NOTES
	This command requires a SSH type connection. 
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Nodes,
		[Parameter()]	[String]	$Slots,
		[Parameter()]	[String]	$Ports,
		[Parameter()]	[String]	$VV_Name,
		[Parameter()]	[String]	$D,
		[Parameter()]	[String]	$Iter,
		[Parameter()]	[String]	$Freq,
		[Parameter()]	[switch]	$Vvlayout,
		[Parameter()]	[switch]	$Portstat,
		[Parameter()]	[switch]	$Pdstat,
		[Parameter()]	[switch]	$Chstat,
		[Parameter()]	[String]	$Maxpd,
		[Parameter(Mandatory=$true)]
		[ValidateSet('auto','manual')]	[switch]	$Movech,
		[Parameter()]	[String]	$MaxSvct,
		[Parameter()]	[String]	$AvgSvct
)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$Cmd = " tunepd "
	if($Nodes)			{	$Cmd += " -nodes $Nodes "		}
	if($Slots)			{	$Cmd += " -slots $Slots "		}
	if($Ports)			{	$Cmd += " -ports $Ports "		}
	if($VV_Name)		{	$Cmd += " -vv $VV_Name "		} 
	if($D)				{	$Cmd += " -d $D "				}
	if($Iter)			{	$Cmd += " -iter $Iter "			} 
	if($Freq)			{	$Cmd += " -freq $Freq "			}
	if($Vvlayout)		{	$Cmd += " -vvlayout "			}		
	if($Portstat)		{	$Cmd += " -portstat"			}
	if($Pdstat)			{	$Cmd += " -pdstat" 				}
	if($Chstat)			{	$Cmd += " -chstat" 				}
	if($Maxpd)			{	$Cmd += " -maxpd $Maxpd " 		}
	if($Movech)			{	$Cmd += " -movech $Movech " 	}
	if($MaxSvct)		{	$Cmd += " maxSvct $MaxSvct "	} 
	elseif($AvgSvct)	{	$Cmd += " avgsvct $AvgSvct "	}
	else				{	return	"Please select at list one from [ MaxSvct or AvgSvct]."	}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}


# SIG # Begin signature block
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBaLtCgqpgn
# uUzvmu0pW0kCC6XGBLJc7iXJXe1puZZQQII1/l6AdLnulN57kzdDoeKN14YmjZnz
# sKn5QqtfcnNioIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5UwghuRAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQLwh5vM3gRjXBt+Cza5pPW8Ik4xBBhvFRLR2EH1EHJ7f+ameSnbNBf27
# k/nYH8Bhtjo8Otn8KpzBoki19VrGfnswDQYJKoZIhvcNAQEBBQAEggGAkchU75dD
# HwIp0JaS/V7mpBbn9h9CvXkETGYckRZuCfZpoW8IZZt6Y50d580A5RjcbAJm+SjH
# 1Ywi2b0uqUR5AkyZGKVLJhY+b9HaQgc2acisbopZKRv8xFPtBXzEnAf7H+yajFIx
# NlwL4mrUMOpMiZUCdZyWEIo3PxTARn8FxpqFVnC9EaR0FlI8yytYbY1fCDh8SZgI
# lJTJKrmVIoCzqZRvYbOa1RUFw7LnZavRSJrKa4DRvS07JqsRW6UGiHgxRYVql5c/
# YgShVOBkrzwgM1wGwZIR3ZZG5RWpuBUk/Kc6H5hl/meqFeVy7FOUO81ghACL6eEB
# jEEWZjEHt7gzjOxyq7CO9478sRCCKvaM1P3IucDBf0eCA3aF5PI69C7o4MWwPbvN
# Mta965F1Ng7uRhxnDxLNbgyPccEe6YALZpUm8+mOBkh4N8bCVN7S8Sk666MRGjxb
# HSDTcdnk2ezl2bn/DiiXh878+x9Zd7aTCPILqudfBjFg3KWslnb6TYL+oYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMAtKJ6b/ssmr8pDQG7+TPRJxl6Lvw0bn
# Ig11q9TC8qeG+ka5ncZ8UGXl+7qjvuJmdQIUSbaxLN37J4+qZfP926x6UOqM+hwY
# DzIwMjQwNzMxMTkyNDI0WqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
# bmNoZXN0ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2Vj
# dGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1oIIS/zCCBl0wggTF
# oAMCAQICEDpSaiyEzlXmHWX8zBLY6YkwDQYJKoZIhvcNAQEMBQAwVTELMAkGA1UE
# BhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGln
# byBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjQwMTE1MDAwMDAwWhcN
# MzUwNDE0MjM1OTU5WjBuMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFuY2hlc3Rl
# cjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydTZWN0aWdvIFB1
# YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzUwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN0Wf0wUibvf04STpNYYGbw9jcRaVhBDaNBp7jmJaA9dQZ
# W5ighrXGNMYjK7Dey5RIHMqLIbT9z9if753mYbojJrKWO4ZP0N5dBT2TwZZaPb8E
# +hqaDZ8Vy2c+x1NiEwbEzTrPX4W3QFq/zJvDDbWKL99qLL42GJQzX3n5wWo60Kkl
# fFn+Wb22mOZWYSqkCVGl8aYuE12SqIS4MVO4PUaxXeO+4+48YpQlNqbc/ndTgszR
# QLF4MjxDPjRDD1M9qvpLTZcTGVzxfViyIToRNxPP6DUiZDU6oXARrGwyP9aglPXw
# YbkqI2dLuf9fiIzBugCDciOly8TPDgBkJmjAfILNiGcVEzg+40xUdhxNcaC+6r0j
# uPiR7bzXHh7v/3RnlZuT3ZGstxLfmE7fRMAFwbHdDz5gtHLqjSTXDiNF58IxPtvm
# ZPG2rlc+Yq+2B8+5pY+QZn+1vEifI0MDtiA6BxxQuOnj4PnqDaK7NEKwtD1pzoA3
# jJFuoJiwbatwhDkg1PIjYnMDbDW+wAc9FtRN6pUsO405jaBgigoFZCw9hWjLNqgF
# VTo7lMb5rVjJ9aSBVVL2dcqzyFW2LdWk5Xdp65oeeOALod7YIIMv1pbqC15R7QCY
# LxcK1bCl4/HpBbdE5mjy9JR70BHuYx27n4XNOZbwrXcG3wZf9gEUk7stbPAoBQID
# AQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNhlxmiMpswHQYD
# VR0OBBYEFGjvpDJJabZSOB3qQzks9BRqngyFMA4GA1UdDwEB/wQEAwIGwDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1UdIARDMEEwNQYM
# KwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20v
# Q1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8vY3JsLnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcmwwegYIKwYB
# BQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYBBQUHMAGGF2h0
# dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IBgQCw3C7J+k82
# TIov9slP1e8YTx+fDsa//hJ62Y6SMr2E89rv82y/n8we5W6z5pfBEWozlW7nWp+s
# dPCdUTFw/YQcqvshH6b9Rvs9qZp5Z+V7nHwPTH8yzKwgKzTTG1I1XEXLAK9fHnmX
# paDeVeI8K6Lw3iznWZdLQe3zl+Rejdq5l2jU7iUfMkthfhFmi+VVYPkR/BXpV7Ub
# 1QyyWebqkjSHJHRmv3lBYbQyk08/S7TlIeOr9iQ+UN57fJg4QI0yqdn6PyiehS1n
# SgLwKRs46T8A6hXiSn/pCXaASnds0LsM5OVoKYfbgOOlWCvKfwUySWoSgrhncihS
# BXxH2pAuDV2vr8GOCEaePZc0Dy6O1rYnKjGmqm/IRNkJghSMizr1iIOPN+23futB
# XAhmx8Ji/4NTmyH9K0UvXHiuA2Pa3wZxxR9r9XeIUVb2V8glZay+2ULlc445CzCv
# VSZV01ZB6bgvCuUuBx079gCcepjnZDCcEuIC5Se4F6yFaZ8RvmiJ4hgwggYUMIID
# /KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUAMFcxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEwMzIyMDAwMDAw
# WhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAM2Y2ENBq26C
# K+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStSVjeYXIjfa3aj
# oW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQBaCxpectRGhh
# nOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE9cbY11XxM2AV
# Zn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExSLnh+va8WxTlA
# +uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OIIq/fWlwBp6KNL
# 19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGdF+z+Gyn9/CRe
# zKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w76kOLIaFVhf5
# sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4CllgrwIDAQABo4IB
# XDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUwHQYDVR0OBBYE
# FF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8E
# CDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0g
# ADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEFBQcBAQRwMG4w
# RwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1Ymxp
# Y1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2Nz
# cC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0ONVgMnoEdJVj9
# TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc6ZvIyHI5UkPC
# bXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1OSkkSivt51Ul
# mJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz2wSKr+nDO+Db
# 8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y4Il6ajTqV2if
# ikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVMCMPY2752LmES
# sRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBeNh9AQO1gQrnh
# 1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupiaAeNHe0pWSGH2
# opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU+CCQaL0cJqlm
# nx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/SjwsusWRItFA3DE8
# MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7xpMeYRriWklU
# PsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs656Oz3TbLyXVo
# MA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEpl
# cnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJV
# U1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9u
# IEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMFcxCzAJ
# BgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJBZvMWhUP2ZQQ
# RLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQnOh2qmcxGzjqe
# mIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypoGJrruH/drCio
# 28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0pKG9ki+PC6VEf
# zutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13jQEV1JnUTCm51
# 1n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9YrcmXcLgsrAi
# mfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/yVl4jnDcw6ULJ
# sBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVgh60KmLmzXiqJ
# c6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/OLoanEWP6Y52
# Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+NrLedIxsE88WzK
# XqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58NHs57ZPUfECcg
# JC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rID
# ZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1UdDwEB/wQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVz
# dC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwNQYI
# KwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3Qu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3OyWM637ayBeR
# 7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJJlFfym1Doi+4
# PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0mUGQHbRcF57ol
# pfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTwbD/zIExAopoe
# 3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i111TW7HV1Ats
# Qa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGezjM6CRpcWed/
# ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+8aW88WThRpv8
# lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH29308ZkpKKdp
# kiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrsxrYJD+3f3aKg
# 6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6Ii8+CQOYDwXM
# +yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz7NgAnOgpCdUo
# 4uDyllU9PzGCBJEwggSNAgEBMGkwVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1Nl
# Y3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFt
# cGluZyBDQSBSMzYCEDpSaiyEzlXmHWX8zBLY6YkwDQYJYIZIAWUDBAICBQCgggH5
# MBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQw
# NzMxMTkyNDI0WjA/BgkqhkiG9w0BCQQxMgQwMY82l+6ANtB1LmmMSd/uuF0KI/oj
# nQDXQrzd7DYrefmKz0VEuE/pwgtyQAad82OyMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgAh1JNr
# uCNBe8GDHWdAXt73QjthkFiCH3CyVDwLqIldENVKe8+13VZwaREV93y7oJ/yGam6
# U8vXF/4l+5nl71G4uUl2zEy58DXnZozqnwVwF1z0jblPwlud6zFmerBnHWtg/GOt
# IzfK+aZC2VEcd/mEARo3w5LBCEuPxedAfhEuyBQ7M4QEfe5GXfgmtLd74Xs2zTSB
# wmzl7kGtvgEPgbqiU0qL7wuQkO+US9fc2p3ZDfu6PZ7fpCUgieShVQ22aGTxZhPX
# TNw2/xFBsk7reuAgXaH0L+sEo0jjTJeHzX+JO23WQIwy6uBSUtkKAmr0VdQL5YZN
# hsr5YQVM4sgjyIWPdWWV50WRYDy+eNqPb4Wgv//f9ZTedequnHk5CJkomx5HA/Ty
# GGuHVDWgSDSUYZW60PpEns5sDwsW0i+oDJanAity4qGZAXboF/P5qufXBSQHBZ2j
# eSZcVnSV9ts+QHkul9J+Gk3kstkdDyyaXFuzc7yV4lyIkRynkzff/g5xd60bv9Dk
# i87g83PEOsmKG6BG4nERUXdG04/wsigLzPmGS6cXuyJf2YN4N3545y5+4ZDfTNrv
# bhx0yGgw2el+JBbxr596AlXyI41mzGVb+i/Y1e2REXorJtItQP5owNNliJa5GXEL
# y7ArqoZEYJ44+WFKYWkypIkiMZKvqKNvgWi1PA==
# SIG # End signature block
