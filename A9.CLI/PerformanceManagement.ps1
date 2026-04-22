## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9Histogram_CLI
{
<#
.SYNOPSIS
	The Get-A9Histogram command displays Virtual Volume service time histograms in a timed loop.
.DESCRIPTION
	The Get-A9Histogram command displays Virtual Volume service time histograms in a timed loop.
.PARAMETER domain
	Shows only the Volumes that are in domains with names that match the specified domain name(s) .
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
.PARAMETER Volume
	Requests that only LDs mapped to Volumes that match and of the specified names or patterns be displayed. Multiple volume names or patterns can be repeated using a comma-separated list.
.PARAMETER iteration
	Specifies that the statistics are to stop after the indicated number of iterations using an integer from 1 through 2147483647.
.PARAMETER hostE
	Shows only VLUNs exported to the specified host(s) or pattern(s). Multiple host names or patterns can be repeated using a comma-separated list.
.PARAMETER Nodes
	Specifies that the display is limited to specified nodes and physical disks connected to those nodes. The node list is specified as a series
	of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the node list is not specified, all disks on all nodes are displayed.
.PARAMETER Slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified as a series of integers separated 
	by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all disks on all slots are displayed.
.PARAMETER Ports
	Specifies that the display is limited to specified ports and physical disks connected to those ports. The port list is specified as a series of integers separated 
	by commas (e.g. 1,2,3). The list can also consist of a single integer. If the port list is not specified, all disks on all ports are displayed.
.PARAMETER Lun      
	Specifies that VLUNs with LUNs matching the specified LUN(s) or pattern(s) are displayed. Multiple LUNs or patterns can be repeated using a comma-separated list.
.PARAMETER Both 
	Specifies that both control and data transfers are displayed(-both), only control transfers are displayed (-ctl), or only data transfers are
	displayed (-data). If this option is not specified, only data transfers are displayed.
.PARAMETER CTL 
	Specifies that both control and data transfers are displayed(-both), only control transfers are displayed (-ctl), or only data transfers are
	displayed (-data). If this option is not specified, only data transfers are displayed.
.PARAMETER Data
	Specifies that both control and data transfers are displayed(-both), only control transfers are displayed (-ctl), or only data transfers are 
	displayed (-data). If this option is not specified, only data transfers are displayed.
.PARAMETER Disk 
	Specifies to display only host ports (target ports), only disk ports (initiator ports), only Fibre Channel Remote Copy configured ports, or
	only Fibre Channel ports for Data Migration. If no option is specified, all ports are displayed.
.PARAMETER RCFC 
	Specifies to display only host ports (target ports), only disk ports (initiator ports), only Fibre Channel Remote Copy configured ports, or
	only Fibre Channel ports for Data Migration. If no option is specified, all ports are displayed.
.PARAMETER PEER
	Specifies to display only host ports (target ports), only disk ports (initiator ports), only Fibre Channel Remote Copy configured ports, or
	only Fibre Channel ports for Data Migration. If no option is specified, all ports are displayed.
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
.PARAMETER sum
	Displays the sums for items of a target, or a Port, or of a Volume, or of a group, or of a domain.
.PARAMETER interval 
    <secs>  Specifies the interval in seconds that statistics are sampled from using an integer from 1 through 2147483. If no count is specified, the  command defaults to 2 seconds. 
.PARAMETER Percentage
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
.PARAMETER Chunklet_num
	Specifies that statistics are limited to only the specified chunklet, identified
	by number.
.PARAMETER NoIdle
	Specifies that histograms for only non-idle devices are displayed. This option is shorthand for the option -filt t,0,0.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
    PS:> Get-A9Histogram -iteration 1

	This Example displays Virtual Volume service time histograms service iteration number of times.
.EXAMPLE
	PS:> Get-A9Histogram -iteration 1 -domain domain.com
	This Example Shows only the that are in domains with names that match the specified domain name(s)
.EXAMPLE	
	PS:> Get-A9Histogram -iteration 1 –Metric both
	This Example Selects which Metric to display.
.EXAMPLE
	PS:> Get-A9Histogram -iteration 1 -Timecols "1 2"
.EXAMPLE
	PS:> Get-A9Histogram -iteration 1 -Sizecols "1 2"
.EXAMPLE	
	PS:> Get-A9Histogram –Metric both -Volume demoVV1 -iteration 1

	This Example Selects which Metric to display. associated with Virtual Volume name.
.NOTES
	This command utilizes the SSH command 'HistCh', 'HistLD', 'HistPD', 'HistPort', 'HistQOS','HistVLUN', 'HistVV'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	# Common
		[Parameter(Mandatory, ParameterSetName='Volume')]	[Switch]	$VolumeHistogram,
		[Parameter(Mandatory, ParameterSetName='VLUN')]		[Switch]	$VLunHistogram,
		[Parameter(Mandatory, ParameterSetName='Port')]		[Switch]	$PortHistogram,
		[Parameter(Mandatory, ParameterSetName='RCVV')]		[Switch]	$RemoteCopyHistogram,
		[Parameter(Mandatory,ParameterSetName='PhysicalDisk')][String]	$PhysicalDiskHistogram,
		[Parameter(Mandatory,ParameterSetName='LogicalDisk')][String]	$LogicalDiskHistogram,
		[Parameter(Mandatory,ParameterSetName='Chunklet')]	[String]	$ChunkletHistogram,		
		[Parameter()]										[String]	$iteration,
		[Parameter()]										[String]	$domain,
		[Parameter()]										[Switch]	$Percentage,
		[Parameter()]										[Switch]	$Previous,	
		# VV 
		[Parameter(ParameterSetName='Port')]
		[Parameter(ParameterSetName='Chunklet')]
		[Parameter(ParameterSetName='Volume')]				[Switch]	$RW,
		[Parameter(ParameterSetName='Volume')]	
		[Parameter(ParameterSetName='LogicalDisk')]	
		[Parameter(ParameterSetName='Chunklet')]
		[Parameter(ParameterSetName='RCVV')]				[String]	$IntervalInSeconds,
		[Parameter(ParameterSetName='Volume')]				[String]	$FSpace,
		[Parameter(ParameterSetName='Port')]
		[Parameter(ParameterSetName='RCVV')]
		[Parameter(ParameterSetName='LogicalDisk')]
		[Parameter(ParameterSetName='Volume')]				[String]	$Volume,
		# VLUN
		[Parameter(ParameterSetName='Port')]
		[Parameter(ParameterSetName='VLUN')]				[String]	$hostE,
		[Parameter(ParameterSetName='VLUN')]				[String]	$lun,
		[Parameter(ParameterSetName='Port')]
		[Parameter(ParameterSetName='PhysicalDisk')]
		[Parameter(ParameterSetName='VLUN')]				[String]	$Nodes,
		[Parameter(ParameterSetName='Port')]
		[Parameter(ParameterSetName='PhysicalDisk')]
		[Parameter(ParameterSetName='VLUN')]				[String]	$Slots,
		[Parameter(ParameterSetName='Port')]
		[Parameter(ParameterSetName='PhysicalDisk')]
		[Parameter(ParameterSetName='VLUN')]				[String]	$Ports,
		[Parameter(ParameterSetName='Port')]
		[Parameter(ParameterSetName='PhysicalDisk')]
		[Parameter(ParameterSetName='LogicalDisk')]	
		[Parameter(ParameterSetName='Chunklet')]
		[Parameter(ParameterSetName='VLUN')]				[Switch]	$Beginning,
		#Port
		[Parameter(ParameterSetName='Port')]				[Switch]	$Both,
		[Parameter(ParameterSetName='Port')]				[Switch]	$CTL,
		[Parameter(ParameterSetName='Port')]				[Switch]	$Data,
		[Parameter(ParameterSetName='Port')]				[Switch]	$PEER,
		[Parameter(ParameterSetName='Port')]				[Switch]	$Disk,
		[Parameter(ParameterSetName='Port')]				[Switch]	$RCFC,
		# RCVV
		[Parameter(ParameterSetName='RCVV')]				[switch]	$Sync,
		[Parameter(ParameterSetName='RCVV')]				[switch]	$Periodic,
		[Parameter(ParameterSetName='RCVV')]				[switch]	$Primary,
		[Parameter(ParameterSetName='RCVV')]				[switch]	$Secondary,
		[Parameter(ParameterSetName='RCVV')]	
		[ValidateSet('Target','Port','Group','Volume','Domain')]
															[switch]	$Sum,
		[Parameter(ParameterSetName='RCVV')]				[switch]	$Prev,
		[Parameter(ParameterSetName='RCVV')]				[String]	$group,
		[Parameter(ParameterSetName='RCVV')]				[String]	$target,
		# Physical Disk
		[Parameter(ParameterSetName='PhysicalDisk')]		[String]	$WWN,
		[Parameter(ParameterSetName='PhysicalDisk')]		[Switch]	$Devinfo,
		[Parameter(ParameterSetName='PhysicalDisk')]		[String]	$FSpec,
		# Logical Disk
		[Parameter(ParameterSetName='LogicalDisk')]	
		[Parameter(ParameterSetName='Chunklet')]			[Switch]	$NonIdle,
		[Parameter(ParameterSetName='Chunklet')]
		[Parameter(ParameterSetName='LogicalDisk')]			[String]	$LdName,
		# Chunklet
		[Parameter(ParameterSetName='Chunklet')]			[String]	$Chunklet_num,
		[Parameter()]										[switch]	$ShowRaw
	)
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$tempFile = [IO.Path]::GetTempFileName()
	switch($PSCmdlet.ParameterSetName)
		{	'Volume'
					{	$Cmd = "histvv "
						if ( $iteration )	{ 	$Cmd += " -iter $iteration"				}		
						else				{	$Cmd += " -iter 1"						}
						if ( $domain )		{ 	$Cmd += " -domain $domain"				}
						if ( $Previous )	{	$Cmd += " -prev"						}	
						if ( $Percentage )	{	$Cmd += " -pct"							}
						if ( $RW )			{	$Cmd += " -rw"							}
						if ( $IntervalInSeconds )	{ 	$Cmd += " -d $IntervalInSeconds"}
						if ( $FSpace )		{ 	$Cmd += " -filt $FSpace"				}
						if ( $Volume )		{	$cmd += " $Volume"						}		
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $Cmd
						if ( $ShowRaw -or $rw ) { return $Result } 
						$range1 = $Result.count
						if ( $range1 -le "5")	{	return "No data available"	}	
						if ( $Result.Count -gt 1)
							{	$LastItem = $Result.Count
								Add-Content -Path $tempFile -Value 'VVname,0.5ms,0.75ms,1ms,1.5ms,2ms,3ms,4ms,6ms,8ms,12ms,16ms,4KB,8KB,16KB,32KB,64KB,128KB,256KB,512KB,1MB,time,date'	
								foreach ( $s in  $Result[0..$LastItem] )
									{	if ( $s -match "millisec" )
											{	$s= [regex]::Replace($s,"^ +","")
												$s= [regex]::Replace($s," +"," ")
												$s= [regex]::Replace($s," ",",")
												$split1=$s.split(",")
												$global:time1 = $split1[0]
												$global:date1 = $split1[1]
												continue
											}
										if ( ($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "VVname") )	{	continue	}			
										$s= [regex]::Replace($s,"^ +","")
										$s= [regex]::Replace($s,"-+","-")
										$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line			
										$s +=",$global:time1,$global:date1"	
										Add-Content -Path $tempFile -Value $s
									}
								$Result = Import-Csv $tempFile
							}
					}
			'VLUN'	
					{	$Cmd = "histvlun "
						if ( $iteration )	{ 	$Cmd += " -iter $iteration "}	
						else				{	$Cmd += " -iter 1 "			}
						if ( $domain )		{ 	$Cmd += " -domain $domain "	}	
						if ( $hostE )		{	$Cmd += " -host $host "		}
						if ( $Volume )		{	$Cmd += " -v $Volume "		}
						if ( $lun )			{	$Cmd += " -l $lun "			}
						if ( $Nodes )		{	$Cmd += " -nodes $Nodes"	}
						if ( $Slots )		{	$Cmd += " -slots $Slots"	}
						if ( $Ports )		{	$Cmd += " -ports $Ports"	}	
						if ( $Metric )		{	$Cmd += " -metric $Metric "	}
						if ( $Previous )	{	$Cmd += " -prev "			}
						if ( $Beginning )	{	$Cmd += " -begin "			}
						if ( $Percentage )	{	$Cmd += " -pct "			}		
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $Cmd 
						if ( $ShowRaw ) 	{ 	return $ShowRaw }
						$range1 = $Result.Count
						if ( $range1 -le "5" ){	return "No Data Available"	}	
						if ( $Result.Count -gt 1)
							{	$LastItem = $Result.Count 
								Add-Content -Path $tempFile -Value 'Lun,VVname,Host,Port,0.5ms,0.75ms,1ms,1.5ms,2ms,3ms,4ms,6ms,8ms,12ms,16ms,4KB,8KB,16KB,32KB,64KB,128KB,256KB,512KB,1MB,time,date'	
								foreach ( $s in  $Result[0..$LastItem] )
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
								$Result = Import-Csv $tempFile
							}	
					}	
			'Port'	
					{	$Cmd = "histport "
						if ( $iteration )		{ 	$Cmd += " -iter $iteration "}	
						else					{	$Cmd += " -iter 1 "			}
						if ( $Both )			{	$Cmd +=" -both "	}
						if ( $CTL )				{	$Cmd +=" -ctl "		}
						if ( $Data )			{	$Cmd +=" -data "	}
						if ( $Nodes )			{	$Cmd += " -nodes $Nodes"	}
						if ( $Slots )			{	$Cmd += " -slots $Slots"	}
						if ( $Ports )			{	$Cmd += " -ports $Ports"	}
						if ( $HostE )			{	$Cmd +=" -host "	}
						if ( $Disk )			{	$Cmd +=" -disk "	}
						if ( $RCFC )			{	$Cmd +=" -rcfc "	}
						if ( $PEER )			{	$Cmd +=" -peer "	}
						if ( $Previous )		{	$Cmd += " -prev "	}
						if ( $Beginning )		{	$Cmd += " -begin "	}
						if ( $Percentage )		{	$Cmd += " -pct "	}
						if ( $RW )				{	$Cmd += " -rw "		}
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $Cmd 	
						if ( $ShowRaw -or $RW ) 		{ 	return $Result 		}
						$range1 = $Result.count
						if ( $range1 -lt "5" )	{	return "No data available"	}		
						if ( $Result.Count -gt 1)
							{	$LastItem = $Result.Count
								if($RW)			{	Add-Content -Path $tempFile -Value 'Port,Data/Ctrl,R/W,0.5ms,0.75ms,1ms,1.5ms,2ms,3ms,4ms,6ms,8ms,12ms,16ms,4KB,8KB,16KB,32KB,64KB,128KB,256KB,512KB,1MB,time,date'	}
								else		    {	Add-Content -Path $tempFile -Value 'Port,Data/Ctrl,0.5ms,0.75ms,1ms,1.5ms,2ms,3ms,4ms,6ms,8ms,12ms,16ms,4KB,8KB,16KB,32KB,64KB,128KB,256KB,512KB,1MB,time,date'	}
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
								$Result = Import-Csv $tempFile
							}
					}
			'RCVV'	
					{	$Cmd = "histrcvv "
						if ( $iteration )		{ 	$Cmd += " -iter $iteration "}	
						else					{	$Cmd += " -iter 1 "			}
						if ( $Sync )			{	$Cmd += " -sync "			}
						if ( $Periodic )		{	$Cmd += " -periodic "		}
						if ( $Primary )			{	$Cmd += " -primary "		}
						if ( $Secondary )		{	$Cmd += " -secondary "		}
						if ( $Sum -eq 'Target')	{	$Cmd += " -targetsum "		}
						if ( $Sum -eq 'Port')	{	$Cmd += " -portsum "		}
						if ( $Sum -eq 'Group' )	{	$Cmd += " -groupsum "		}
						if ( $Sum -eq 'Volume' ){	$Cmd += " -vvsum "			}
						if ( $Sum -eq 'Domain')	{	$Cmd += " -domainsum "		}
						if ( $Percentage )		{	$Cmd += " -pct "			}
						if ( $Prev )			{	$Cmd += " -prev "			}	
						if ( $IntervalInSeconds ){	$Cmd += " -d $IntervalInSeconds "}
						if ( $domain )			{ 	$Cmd += " -domain  $domain"	}
						if ( $group )			{ 	$Cmd += " -g $group"		}
						if ( $target )			{ 	$Cmd += " -t $target"		}
						if ( $Volume )			{ 	$Cmd += " $Volume"			}
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $Cmd
						if ($ShowRaw) { return $ShowRaw }
						if ( $Result.Count -gt 1)
							{	$LastItem = $Result.Count - 2
								if($VolumeSum)		{	Add-Content -Path $tempFile -Value "VVname,RCGroup,Target,Mode,Svt_0.50,Svt_1,Svt_2,Svt_4,Svt_8,Svt_16,Svt_32,Svt_64,Svt_128,Svt_256,Rmt_0.50,Rmt_1,Rmt_2,Rmt_4,Rmt_8,Rmt_16,Rmt_32,Rmt_64,Rmt_128,Rmt_256,Time,Date" }
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
								$Result = Import-Csv $tempFile
							}
					}
			'PhyscialDisk'
					{	$Cmd = "histpd "
						if ( $Iteration)	{	$Cmd += "-iter $Iteration"	}
						else				{	$Cmd += "-iter 1 "			}	
						if ( $WWN )			{	$Cmd += " -w $WWN"			}
						if ( $Nodes )		{	$Cmd += " -nodes $Nodes"	}
						if ( $Slots )		{	$Cmd += " -slots $Slots"	}
						if ( $Ports )		{	$Cmd += " -ports $Ports"	}
						if ( $Devinfo )		{	$Cmd += " -devinfo "		}
						if ( $Previous )	{	$Cmd += " -prev "			}
						if ( $Beginning )	{	$Cmd += " -begin "			}
						if ( $Percentage )	{	$Cmd += " -pct "			}	
						if ( $FSpec )		{	$Cmd += " -filt $FSpec"		}
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $Cmd 
						if ( $ShowRaw ) 	{	$ShowRaw }
						$range1 = $Result.count
						if ( $range1 -lt "5" )	{	return "No data available"	}		
						if ( $Result.Count -gt 1 )
							{	$LastItem = $Result.Count
								if   ( $Devinfo )	{	Add-Content -Path $tempFile -Value  'ID,Port,Type,K_RPM,0.5ms,1ms,2ms,4ms,8ms,16ms,32ms,64ms,128ms,256ms,4KB,8KB,16KB,32KB,64KB,128KB,256KB,512KB,1MB,time,date'	}
								else				{	Add-Content -Path $tempFile -Value  'ID,Port,0.5ms,0.75ms,1ms,1.5ms,2ms,3ms,4ms,6ms,8ms,12ms,16ms,4KB,8KB,16KB,32KB,64KB,128KB,256KB,512KB,1MB,time,date'				}
								foreach ( $s in  $Result[0..$LastItem] )
									{	if ( $s -match "millisec" )
											{	$s= [regex]::Replace($s,"^ +","")
												$s= [regex]::Replace($s," +"," ")
												$s= [regex]::Replace($s," ",",")
												$split1=$s.split(",")
												$global:time1 = $split1[0]
												$global:date1 = $split1[1]
												continue
											}
										if ( ($s -match "----") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "ID") )	{	continue	}
										$s= [regex]::Replace($s,"^ +","")
										$s= [regex]::Replace($s,"-+","-")
										$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line			
										$aa=$s.split(",").length
										if ( $aa -eq "20" ) 	{	continue	}
										$s +=",$global:time1,$global:date1"
										Add-Content -Path $tempFile -Value $s
									}
								$Result = Import-Csv $tempFile
							}
					}
			'LogicalDisk'
					{	$Cmd = "histld -iter $Iteration "
						if ( $Iteration )		{	$Cmd += " -iter $Iteration "		}
						else 					{	$Cmd += " -iter 1 "					}
						if ( $Volume )			{	$Cmd += " -vv $Volume "				} 
						if ( $Domain )			{	$Cmd += " -domain $Domain"			}
						if ( $Percentage )		{	$Cmd += " -pct "					}
						if ( $Previous )		{	$Cmd += " -prev "					}				
						if ( $Beginning )		{	$Cmd += " -begin "					}
						if ( $IntervalInSeconds ){	$Cmd += " -d $IntervalInSeconds "	}
						if ( $NonIdle )			{	$Cmd += " -ni "						}
						if ( $LdName )			{	$Cmd += "  $LdName "				}
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $Cmd
						if ( $ShowRaw ) 		{ $ShowRaw }
						$range1 = $Result.count
						#write-host "count = $range1"
						if ( $range1 -lt "5" )		{	return "No data available Please Try With Valid Data. `n"	}	
						if ( $Result.Count -gt 1 )
							{	$LastItem = $Result.Count
								Add-Content -Path $tempFile -Value  'Logical_Disk_Name,0.5ms,0.75ms,1ms,1.5ms,2ms,3ms,4ms,6ms,8ms,12ms,16ms,4KB,8KB,16KB,32KB,64KB,128KB,256KB,512KB,1MB,time,date'
								foreach ( $s in  $Result[0..$LastItem] )
									{	if ( $s -match "millisec" )
											{	$s= [regex]::Replace($s,"^ +","")
												$s= [regex]::Replace($s," +"," ")
												$s= [regex]::Replace($s," ",",")
												$split1=$s.split(",")
												$global:time1 = $split1[0]
												$global:date1 = $split1[1]
												continue
											}
										if ( ($s -match "-------") -or ([string]::IsNullOrEmpty($s)) -or ($s -match "Ldname") )	{	continue	}
										#write-host "s = $s"
										$s= [regex]::Replace($s,"^ +","")
										$s= [regex]::Replace($s," +"," ")
										$s= [regex]::Replace($s," +",",")			# Replace one or more spaces with comma to build CSV line
										$s +=",$global:time1,$global:date1"
										Add-Content -Path $tempFile -Value $s
									}
								$result = Import-Csv $tempFile
							}
					}
			'Chunklet'
					{	$Cmd = "histch"
						if ( $Iteration )		{	$Cmd += " -iter $Iteration "	}
						else 					{	$Cmd += " -iter 1 "				}
						if ( $LDname )			{	$CMD +=" -ld $LDname "			}
						if ( $Chunklet_num )	{	$Cmd +=" -ch $Chunklet_num "	} 
						if ( $Percentage )		{	$Cmd +=" -pct "					}
						if ( $Previous )		{	$Cmd +=" -prev "				}
						if ( $Beginning )		{	$Cmd +=" -begin "				}
						if ( $RW )				{	$Cmd +=" -rw "					}
						if ( $IntervalInSeconds ){	$Cmd +=" -d $IntervalInSeconds "}
						if ( $NonIdle )			{	$Cmd +=" -ni "					}	
						write-verbose "Executing the following SSH command `n`t $cmd"
						$Result = Invoke-A9CLICommand -cmds  $histchCMD	
						$range1 = $Result.count
						if ( $range1 -le "5")	{	return "No data available Please try with valid input."	}
						if ( $ShowRaw -or $rw ) 		{ 	return $Result }
						if ( $Result.Count -gt 1)
							{	$LastItem = $Result.Count		
								if ( $RW )	{	$LastItem = $LastItem - 4	}		
								Add-Content -Path $tempFile -Value 'Ldid,Ldname,logical_Disk_CH,Pdid,PdCh,0.5ms,0.75ms,1ms,1.5ms,2ms,3ms,4ms,6ms,8ms,12ms,16ms,4KB,8KB,16KB,32KB,64KB,128KB,256KB,512KB,1MB,time,date'
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
								$result = Import-Csv $tempFile
							}	
					}
		}
	Remove-Item $tempFile
	if ( $Result.count -gt 1 )
	{	$NewObj = @(    foreach( $Item in $Result )	
                                        {   $NewItem=@{PSTypeName = "HPE.A9Storage.Histogram"}
											if ( $Item."0.5ms")
												{	$MillisecondBucket=@()
													# 0.5ms,0.75ms,1ms,1.5ms,2ms,3ms,4ms,6ms,8ms,12ms,16ms
													$MillisecondBucket  += $Item.'0.5ms'
													$MillisecondBucket  += $Item.'0.75ms'
													$MillisecondBucket  += $Item.'1ms'
													$MillisecondBucket  += $Item.'1.5ms'
													$MillisecondBucket  += $Item.'2ms'
													$MillisecondBucket  += $Item.'3ms'
													$MillisecondBucket  += $Item.'4ms'
													$MillisecondBucket  += $Item.'6ms'
													$MillisecondBucket  += $Item.'8ms'
													$MillisecondBucket  += $Item.'12ms'
													$MillisecondBucket  += $Item.'16ms'
													$MillisecondTotal = 0
													foreach($num in $MillisecondBucket)
														{   $MillisecondTotal += $num
														}
													$BottomBucket   = @(0,0.5,0.75,1,1.5,2,3,4,6,8,12 )
													$TopBucket      = @(0.5,0.75,1,1.5,2,3,4,6,8,12,16)
													$Index=1
													[decimal[]]$BottomPercBucket=@()
													[decimal[]]$TopPercBucket=@()
													[decimal[]]$BottomPercBucket   += 0
													try {	[decimal[]]$TopPercBucket      += [math]::Round($MillisecondBucket[0] / $MillisecondTotal,3)
														}
													catch [System.DivideByZeroException]
														{	[decimal[]]$TopPercBucket      += 0
														}
													while ($Index -lt 10)
														{   try	{	$BottomPercBucket   += [math]::Round($TopPercBucket[$Index-1],3)
																	$TopPercBucket      += [math]::Round($BottomPercBucket[$index] + $BucketPerc,3)
																}
															catch [System.DivideByZeroException] 
															    { 	$BucketPerc[$Index] = 0
																	TopPercBucket[$index] = 0 
																} 
															$Index+=1
														}
													$Index=0
													$RunningIOPS = 0
													while ($Index -lt 11)
													{   $RunningIOPS += $MillisecondBucket[$index]
														if ( $TopPercBucket[$Index] -gt 0.50 -and $BottomPercBucket[$index] -lt 0.50 )
															{   $fpnum = [math]::round($MillisecondTotal / 2)
																$iopsbot = $RunningIOPS - $MillisecondBucket[$index]
																$ThisBucket = $fpnum - $iopsbot
																$Between = $ThisBucket / $MillisecondBucket[$Index]
																$ThisLatency = [math]::round( ($TopBucket[$index] - $BottomBucket[$index]) * ($between) + $BottomBucket[$index], 2)
																$NewItem['50thPercentile'] = $ThisLatency
															}
														if ( $TopPercBucket[$Index] -gt 0.95 -and $BottomPercBucket[$index] -lt 0.95 )
															{   $fpnum = [math]::round($MillisecondTotal * 0.95)
																$iopsbot = $RunningIOPS - $MillisecondBucket[$index]
																$ThisBucket = $fpnum - $iopsbot
																$Between = $ThisBucket / $MillisecondBucket[$Index]
																$ThisLatency = [math]::round( ($TopBucket[$index] - $BottomBucket[$index]) * ($between) + $BottomBucket[$index], 2 )
																$NewItem['95thPercentile'] = $ThisLatency
															}
														if ( $TopPercBucket[$Index] -gt 0.99 -and $BottomPercBucket[$index] -lt 0.99 )
															{   $fpnum = [math]::round($MillisecondTotal * 0.99)
																$iopsbot = $RunningIOPS - $MillisecondBucket[$index]
																$ThisBucket = $fpnum - $iopsbot
																$Between = $ThisBucket / $MillisecondBucket[$Index]
																$ThisLatency = [math]::round( ($TopBucket[$index] - $BottomBucket[$index]) * ($between) + $BottomBucket[$index], 2 )
																$NewItem['99thPercentile'] = $ThisLatency
															}
														$Index+=1
													}
												}
										    $Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
											$DataSetType = "HPE.A9Storage.Histogram"
											$NewItem.PSTypeNames.Insert(0,$DataSetType)
											$DataSetType = $DataSetType + ".TypeName"
											$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
											[PSCustomObject]$NewItem
										}
						            )
                        write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                        return $NewObj	
	}
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	return $result
}
}

Function Get-A9Statistics_CLI
{
<#
.SYNOPSIS
	The command displays statistics for Chunklets, Cache, CPU, Logical Disk, Physical Disk, Link Utilization, Ports, Remote Copy Volumes, Volumes, and VLuns, iSCSI, and FCoE.
.DESCRIPTION
	The command displays statistics for Chunklets, Cache, CPU, Logical Disk, Physical Disk, Link Utilization, Ports, Remote Copy Volumes, Volumes, and VLuns, iSCSI, and FCoE.
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
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.PARAMETER Volume
	Specifies that statistics are displayed for virtual volumes matching the specified name or pattern.
.PARAMETER total 
	Show only the totals for all the CPUs on each node.
.PARAMETER Domain
	Shows only LDs that are in domains with names matching any of the names or specified patterns.
.PARAMETER Devinfo
	Indicates the device disk type and speed.
.PARAMETER wwn 
	Specifies that statistics for a particular Physical Disk (PD) identified by World Wide Names (WWNs) are displayed.
.PARAMETER node  
	Specifies that the display is limited to specified nodes and PDs connected to those nodes
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
.PARAMETER HostPort
	Displays only host ports (target ports).
.PARAMETER Disk
	Displays only disk ports (initiator ports).
.PARAMETER Rcfc
	Displays only Fibre Channel remote-copy configured ports.
.PARAMETER FS
	Includes only statistics for File Persona ports.
.PARAMETER Peer
	Specifies to display only host ports (target ports), only disk ports (initiator ports), only Fibre Channel Remote Copy configured ports, or
	only Fibre Channel ports for Data Migration. If no option is specified, all ports are displayed.
.PARAMETER slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified
	as a series of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all
	disks on all slots are displayed.
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
.PARAMETER target   
	Show only volumes whose group is copied to the specified target name.
.PARAMETER port    
	Show only volumes that are copied over the specified port or pattern.
.PARAMETER group 
	Show only volumes whose group matches the specified group name or pattern.
.PARAMETER DomainName
	Shows only the virtual volumes that are in domains with names that match the specified domain name(s) or pattern(s).	
.PARAMETER Subset
	Show subset statistics for Asynchronous Remote Copy on a per group basis.
.PARAMETER LW  
	Lists the host’s World Wide Name (WWN) or iSCSI names.
.PARAMETER Domainsum
	Specifies that sums for VLUNs are grouped by domain in the display.
.PARAMETER Hostsum
	Specifies that sums for VLUNs are grouped by host in the display.
.PARAMETER LUN  
	Specifies that VLUNs with LUNs matching the specified LUN(s) or pattern(s) are displayed.
.PARAMETER Fullcounts
	Shows the values for the full list of counters instead of the default packets and KBytes for the specified protocols. 
	The values are shown in three columns:
		o Current   - Counts since the last sample.
        o CmdStart  - Counts since the start of the command.
        o Begin     - Counts since the port was reset.
	This option cannot be used with the -prot option. If the -fullcounts option is not specified, the metrics from the start of the command are displayed.
.PARAMETER Prev
	Shows the differences from the previous sample.
.EXAMPLE
	PS:> Get-A9Statistics -ReturnChunkletStats
.EXAMPLE
	PS:> Get-A9Statistics -ReturnCacheStats
.EXAMPLE
	PS:> Get-A9Statistics -ReturnCPUStats
.EXAMPLE
	PS:> Get-A9Statistics -$ReturnLinkUtilizationStats
.EXAMPLE
	PS:> Get-A9Statistics -ReturnRemoteCopyVolumeStats
.EXAMPLE
	PS:> Get-A9Statistics -ReturnCacheStats
.EXAMPLE
	PS:> Get-A9Statistics ReturnVLunStats
.EXAMPLE
	PS:> Get-A9Statistics -ReturnVolumeStats
.NOTES
	This command utilizes the SSH command 'statch', 'statcmp', 'statCpu', 'statld', 'StatLink', 'StatPd', 'StatRCVv', 'StatvLun', 'StatVv', 'StatiSCSI'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='statch',Mandatory)]	[switch]	$ReturnChunkletStats,
		[Parameter(ParameterSetName='statcmp',Mandatory)]	[switch]	$ReturnCacheStats,		
		[Parameter(ParameterSetName='statcpu',Mandatory)]	[switch]	$ReturnCPUStats,
		[Parameter(ParameterSetName='statld',Mandatory)]	[switch]	$ReturnLogicalDiskStats,
		[Parameter(ParameterSetName='statlink',Mandatory)]	[switch]	$ReturnLinkUtilizationStats,
		[Parameter(ParameterSetName='statport',Mandatory)]	[switch]	$ReturnPortStats,
		[Parameter(ParameterSetName='statpd',Mandatory)]	[switch]	$ReturnPhysicalDiskStats,
		[Parameter(ParameterSetName='statrcvv',Mandatory)]	[switch]	$ReturnRemoteCopyVolumeStats,
		[Parameter(ParameterSetName='statvlun',Mandatory)]	[switch]	$ReturnVLunStats,
		[Parameter(ParameterSetName='statvv',Mandatory)]	[switch]	$ReturnVolumeStats,
		[Parameter(ParameterSetName='statiscsi',Mandatory)]	[switch]	$ReturniSCSIStats,
		[Parameter(ParameterSetName='statfcoe',Mandatory)]	[switch]	$ReturnFCoEStats,
		
		[Parameter(ParameterSetName='statch')]	
		[Parameter(ParameterSetName='statcmp')]			
		[Parameter(ParameterSetName='statcpu')]	
		[Parameter(ParameterSetName='statld')]	
		[Parameter(ParameterSetName='statlink')]	
		[Parameter(ParameterSetName='statport')]	
		[Parameter(ParameterSetName='statpd')]	
		[Parameter(ParameterSetName='statrcvv')]	
		[Parameter(ParameterSetName='statvlun')]	
		[Parameter(ParameterSetName='statvv')]
		[Parameter(ParameterSetName='statiscsi')]			[switch]	$ShowRaw,
		[Parameter(ParameterSetName='statch')]	
		[Parameter(ParameterSetName='statcmp')]			
		[Parameter(ParameterSetName='statcpu')]	
		[Parameter(ParameterSetName='statld')]	
		[Parameter(ParameterSetName='statport')]	
		[Parameter(ParameterSetName='statlink')]	
		[Parameter(ParameterSetName='statpd')]	
		[Parameter(ParameterSetName='statrcvv')]	
		[Parameter(ParameterSetName='statvlun')]	
		[Parameter(ParameterSetName='statvv')]
		[Parameter(ParameterSetName='statiscsi')]
		[Parameter(ParameterSetName='statfcoe')]			[String]	$Iteration,
		[Parameter(ParameterSetName='statch')]	
		[Parameter(ParameterSetName='statld')]	
		[Parameter(ParameterSetName='statport')]
		[Parameter(ParameterSetName='statpd')]	
		[Parameter(ParameterSetName='statvlun')]
		[Parameter(ParameterSetName='statvv')]				[switch]	$RW,
		[Parameter(ParameterSetName='statch')]				
		[Parameter(ParameterSetName='statcmp')]	
		[Parameter(ParameterSetName='statld')]	
		[Parameter(ParameterSetName='statport')]
		[Parameter(ParameterSetName='statpd')]
		[Parameter(ParameterSetName='statrcvv')]
		[Parameter(ParameterSetName='statvlun')]
		[Parameter(ParameterSetName='statvv')]				[switch]	$NI,
		[Parameter(ParameterSetName='statcmp')]	
		[Parameter(ParameterSetName='statch')]
		[Parameter(ParameterSetName='statld')]	
		[Parameter(ParameterSetName='statcpu')]	
		[Parameter(ParameterSetName='statvv')]	
		[Parameter(ParameterSetName='statiscsi')]			[String]	$Delay,
		[Parameter(ParameterSetName='statport')]
		[Parameter(ParameterSetName='statch')]	
		[Parameter(ParameterSetName='statld')]
		[Parameter(ParameterSetName='statpd')]
		[Parameter(ParameterSetName='statiscsi')]	
		[Parameter(ParameterSetName='statvlun')]	
		[Parameter(ParameterSetName='statfcoe')]			[switch]	$Begin,
		[Parameter(ParameterSetName='statch')]
		[Parameter(ParameterSetName='statld')]	
		[Parameter(ParameterSetName='statport')]
		[Parameter(ParameterSetName='statvlun')]
		[Parameter(ParameterSetName='statpd')]				[switch]	$IDLEP,
		[Parameter(ParameterSetName='statcmp')]	
		[Parameter(ParameterSetName='statvlun')]
		[Parameter(ParameterSetName='statvv')]	
		[Parameter(ParameterSetName='statrcvv')]
		[Parameter(ParameterSetName='statld')]				[String]	$Domian ,
		[Parameter(ParameterSetName='statch')]	
		[Parameter(ParameterSetName='statld')]				[String]	$LDname ,
		[Parameter(ParameterSetName='statld')]
		[Parameter(ParameterSetName='statcmp')]
		[Parameter(ParameterSetName='statrcvv')]
		[Parameter(ParameterSetName='statvlun')]
		[Parameter(ParameterSetName='statvv')]				[String]	$Volume ,
		[Parameter(ParameterSetName='statport')]
		[Parameter(ParameterSetName='statvlun')]
		[Parameter(ParameterSetName='statpd')]
		[Parameter(ParameterSetName='statiscsi')]	
		[Parameter(ParameterSetName='statfcoe')]			[String]	$node,
		[Parameter(ParameterSetName='statch')]				[String]	$CHnum,
		[Parameter(ParameterSetName='statcpu')]				[switch]	$total,
		[Parameter(ParameterSetName='statlink')]			[switch]	$Detail,
		[Parameter(Mandatory,ParameterSetName='statlink')]
		[Parameter(ParameterSetName='statrcvv')]		
		[Parameter(ParameterSetName='statfcos')]			[String]	$Interval,
		[Parameter(ParameterSetName='statport')]			[switch]	$Both ,
		[Parameter(ParameterSetName='statport')]			[switch]	$Ctl ,
		[Parameter(ParameterSetName='statport')]			[switch]	$Data ,
		[Parameter(ParameterSetName='statport')]			[switch]	$Rcfc ,
		[Parameter(ParameterSetName='statport')]			[switch]	$Rcip ,
		[Parameter(ParameterSetName='statport')]			[switch]	$FS ,	
		[Parameter(ParameterSetName='statport')]			[switch]	$HostPort ,
		[Parameter(ParameterSetName='statport')]			[switch]	$Peer ,
		[Parameter(ParameterSetName='statport')]			[switch]	$Disk,
		[Parameter(ParameterSetName='statport')]
		[Parameter(ParameterSetName='statpd')]	
		[Parameter(ParameterSetName='statiscsi')]
		[Parameter(ParameterSetName='statfcoe')]			[String]	$slot,
		[Parameter(ParameterSetName='statport')]
		[Parameter(ParameterSetName='statpd')]
		[Parameter(ParameterSetName='statiscsi')]
		[Parameter(ParameterSetName='statrcvv')]	
		[Parameter(ParameterSetName='statfcoe')]			[String]	$port , 
		[Parameter(ParameterSetName='statpd')]				[String]	$wwn ,
		[Parameter(ParameterSetName='statpd')]				[switch]	$DevInfo,
		[Parameter(ParameterSetName='statrcvv')]			[String]	$Target ,		
		[Parameter(ParameterSetName='statrcvv')]			[String]	$Group ,
		[Parameter(ParameterSetName='statrcvv')]			[switch]	$ASync,
		[Parameter(ParameterSetName='statrcvv')]			[switch]	$Sync,	
		[Parameter(ParameterSetName='statrcvv')]			[switch]	$Periodic,
		[Parameter(ParameterSetName='statrcvv')]			[switch]	$Primary,		
		[Parameter(ParameterSetName='statrcvv')]			[switch]	$Secondary,		
		[Parameter(ParameterSetName='statrcvv')]			[switch]	$TargetSum,
		[Parameter(ParameterSetName='statrcvv')]			[switch]	$PortSum,	
		[Parameter(ParameterSetName='statrcvv')]			[switch]	$GroupSum,
		[Parameter(ParameterSetName='statrcvv')]
		[Parameter(ParameterSetName='statvlun')]			[switch]	$VolumeSum,
		[Parameter(ParameterSetName='statrcvv')]
		[Parameter(ParameterSetName='statvlun')]			[switch]	$DomainSum,
		[Parameter(ParameterSetName='statrcvv')]			[switch]	$SubSet,
		[Parameter(ParameterSetName='statvlun')]			[switch]	$LW,
		[Parameter(ParameterSetName='statvlun')]			[switch]	$HostSum,
		[Parameter(ParameterSetName='statvlun')]			[String]	$LUN,
		[Parameter(ParameterSetName='statiscsi')]
		[Parameter(ParameterSetName='statfcoe')]		
		[ValidateSet('current','cmdstart','begin')]			[Switch]	$Fullcounts,
		[Parameter(ParameterSetName='statiscsi')]	
		[Parameter(ParameterSetName='statfcoe')]			[Switch]	$Prev,
		[Parameter(ParameterSetName='statfcoe')]			[switch]	$Counts
	)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$Cmd = $PSCmdlet.ParameterSetName
	if ( $Iteration )	{	$cmd += " iter $iteration " }
	else 				{	$cmd += " iter 1 "			}
	$tempFile = [IO.Path]::GetTempFileName()
	if ( $RW )		{	$cmd +=" -rw "		}
	if ( $IDLEP )	{	$cmd+=" -idlep "	}
	if ( $NI )		{	$cmd+=" -ni "		}
	if ( $Begin )	{	$cmd+=" -begin "	}
	Switch ( $PSCmdlet.ParameterSetName )
		{	'statch'	
				{	if ( $Delay )	{	$cmd+=" -d $Delay"	}
					if ( $LDname ) 	{	$ld="showld"
									$Result1 = Invoke-A9CLICommand -cmds  $ld
									if($Result1 -match $LDname )	{	$cmd+=" -ld $LDname "	}
									else{	Return "FAILURE : -LDname $LDname is not available . "	}
								}
					if($CHnum)	{	$cmd+=" -ch $CHnum "	}
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd
					write-verbose "  Executing  Get-StatChunklet command displays chunklet statistics in a timed loop. with the command  " 
					if ($ShowRaw) { return $Reult }
					$range1 = $Result.Count
					if($range1 -le "5" )	{	return "No Data Available"	}
					if( $Result.Count -gt 1)
						{	$LastItem = $Result.Count
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
							$Result = Import-Csv $tempFile
						}		
				}
			'statcmp'
				{	if ( $Volume )	{	$cmd+=" -n $Volume "		}		
					if ( $Domian )	{	$cmd+= " -domain $Domian "	}
					if ( $Delay )	{	$cmd+=" -d $Delay"			}		
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd
					write-verbose "  Executing  Get-StatCMP command displays Cache Memory Page (CMP) statistics. with the command  " 
					if ($ShowRaw) { return $Result }
					$range1 = $Result.count
					if($range1 -le "3")	{	return "No data available"	}	
					if ( $Result.Count -gt 1)
						{	$LastItem = $Result.Count
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
							$Result = Import-Csv $tempFile
						}	
				}
			'statcpu'	
				{	if ( $delay )	{	$cmd+=" -d $delay "	}
					if ( $total )	{	$cmd+= " -t "		}
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd	
					write-verbose "  Executing  Get-StatCPU command displays Cache Memory Page (CMP) statistics. with the command  " 
					if ($ShowRaw) { return $Result}
					$range1 = $Result.count
					if ( $range1 -eq "5" )	{	return "No data available"	}		
					if ( $Result.Count -gt 1 )
						{	$flg = "False"
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
							$Result = Import-Csv $tempFile
						}
				}
			'statld'
				{	if ( $Volume )	{	$cmd+=" -vv $Volume "	}
					if ( $LDname )	{	if ( $cmd -match "-vv" )	{	return "Stop: Executing -Volume $Volume and  -LDname $LDname cannot be done in a single Execution "	}
										$cmd+=" $LDname "	
									}	
					if ( $Domain )	{	$cmd+=" -domain $Domain "	}	
					if ( $Delay )	{	$cmd+=" -d $Delay "	}		
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd
					$range1 = $Result.count
					if ( $ShowRaw ) 		{ return $Result }
					if ( $range1 -le "5" )	{	return "No data available" }	
					if ( $Result.Count -gt 1)
						{	$LastItem = $Result.Count - 1		
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
							$Result = Import-Csv $tempFile
						}
				}
			'statlink'	
				{	if ( $Detail )	{	$cmd+=" -detail "		}
					if ( $Interval) {	$cmd+=" -d $Interval "	}
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd
					if ($ShowRaw) { return $Result }
					$range1 = $Result.count
					if($range1 -eq "3")	{	return "No data available"	}	
					if ( $Result.Count -gt 1)
						{	$LastItem = $Result.Count
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
							$Result = Import-Csv $tempFile
						}
				}
			'statpd'
				{	if ( $DevInfo )	{	$cmd+=" -devinfo "	}
					if ( $wwn )		{	$cmd+=" -w $wwn "	}	
					if ( $node )	{	$cmd+=" -nodes $node "	}	
					if ( $slot )	{	$cmd+=" -slots $slot "	}	
					if ( $port )	{	$cmd+=" -ports $port "	}			
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd
					if ( $ShowRaw ) { return $Result }	
					$range1 = $Result.count	
					if ( $range1 -eq "4" )	{	return "No data available"	}	
					if ( $Result.Count -gt 1 )
						{	$LastItem = $Result.Count - 3
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
							$Result = Import-Csv $tempFile
						}	
				}
			'statport'
				{	if ( $Both )	{	$cmd +=" -both "	}
					if ( $Ctl )		{	$cmd +=" -ctl "		}
					if ( $Data )	{	$cmd +=" -data "	}
					if ( $Rcfc )	{	$cmd +=" -rcfc "	}
					if ( $Rcip )	{	$cmd +=" -rcip "	}
					if ( $FS )		{	$cmd +=" -fs "		}
					if ( $HostPort ){	$cmd +=" -host "	}
					if ( $Disk )	{	$cmd +=" -disk "	}
					if ( $Peer )	{	$cmd +=" -peer "	}	
					if ( $Begin )	{	$cmd+=" -begin "	}
					if ( $node )	{	$cmd+=" -nodes $node "	}
					if ( $slot )	{	$cmd+=" -slots $slot "	}
					if ( $port )	{	$cmd+=" -ports $port "	}				
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd	
					if ($ShowRaw) { return $Reusult }
					$range1 = $Result.count
					if ( $range1 -eq "4" )	{	return "No data available"	}
					if ( ($Both) -And ($range -eq "6") )	{	return "No data available"	}
					if ( $Result.Count -gt 1 )
						{	$LastItem = $Result.Count -3
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
							$Result = Import-Csv $tempFile
						}		
				}
			'statrcvv'
				{	if ( $Interval ){	$cmd+=" -d $Interval"		}	
					if ( $Target )	{	$cmd+=" -t $Target"			}	
					if ( $Port )	{	$cmd+=" -port $Port "		}
					if ( $Group )	{	$cmd+=" -g $Group"			}
					if ( $ASync )	{	$cmd += " -async "			}
					if ( $Sync )	{	$cmd += " -sync "			}
					if ( $Periodic ){	$cmd += " -periodic "		}
					if ( $Primary )	{	$cmd += " -primary "		}
					if ( $Secondary ){	$cmd += " -secondary "		}
					if ( $TargetSum ){	$cmd += " -targetsum "		}
					if ( $PortSum )	{	$cmd += " -portsum "		}
					if ( $GroupSum ){	$cmd += " -groupsum "		}
					if ( $VolumeSum ){	$cmd += " -vvsum "			}
					if ( $DomainSum ){	$cmd += " -domainsum "		}
					if ( $Domain )	{	$cmd += " -domain $Domain "	}
					if ( $SubSet )	{	$cmd += " -subset "			}
					if ( $Volume )	{	$cmd += " $Volume"			}
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd
					if ( $ShowRaw ) { return $Result}
					$range1 = $Result.count
					if( $range1 -eq "4" )	{	return "No data available"	}
					if( $Result.Count -gt 1)
						{	$LastItem = $Result.Count - 2
							if ( $TargetSum )		{	Add-Content -Path $tempFile -Value "Target,Mode,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
							elseif ( $PortSum )		{	Add-Content -Path $tempFile -Value "Link,Target,Type,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
							elseif ( $GroupSum )	{	Add-Content -Path $tempFile -Value "Group,Target,Mode,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
							elseif ( $VolumeSum )	{	Add-Content -Path $tempFile -Value "VVname,RCGroup,Target,Mode,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
							elseif ( $DomainSum )	{	Add-Content -Path $tempFile -Value "Domain,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"	}
							else 					{	Add-Content -Path $tempFile -Value "VVname,RCGroup,Target,Mode,Port,Type,I/O_Cur,I/O_Avg,I/O_Max,KBytes_Cur,KBytes_Avg,KBytes_Max,Svt_Cur,Svt_Avg,Rmt_Cur,Rmt_Avg,IOSz_Cur,IOSz_Avg,Time,Date"}
							foreach ( $s in  $Result[0..$LastItem] )
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
							$Result = Import-Csv $tempFile
						}
				}
			'statvlun'
				{	if ( $LW )			{	$cmd+= " -lw "				}
					if ( $DomainSum )	{	$cmd+= " -domainsum "		}
					if ( $VolumeSum )		{	$cmd+= " -vvsum "		}	
					if ( $HostSum )		{	$cmd+= " -hostsum "			}
					if ( $domian )		{	$cmd+= " -domain $domian"	}	
					if ( $Volume )		{	$cmd+= " -v $Volume"		}			
					if ( $LUN )			{	$cmd+= " -l $LUN"			}	
					if ( $nodes )		{	$cmd+= " -nodes $nodes"		}				
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd
					if ($ShowRaw) { return $Result }
					$range1 = $Result.count
					if($range1 -eq "4")					{	return "No data available"	}	
					if(($range1 -eq "6") -and ($NI))	{	return "No data available"	}
					if ( $Result.Count -gt 1)
						{	$LastItem = $Result.Count - 3
							if ( $LW )				{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,Host_WWN/iSCSI_Name,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"}
							elseif ( $DomainSum )	{	Add-Content -Path $tempFile -Value "Domain,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date" 	}
							elseif ( $VolumeSum )	{	Add-Content -Path $tempFile -Value "VVname,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
							elseif ( $RW )			{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
							elseif ( $Begin )		{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
							elseif ( $IDLEP )		{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,IOSz_Cur,IOSz_Avg,Time,Date"	}
							elseif ( $NI )			{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
							elseif ( $HostSum )		{	Add-Content -Path $tempFile -Value "Hostname,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date"	}
							else					{	Add-Content -Path $tempFile -Value "Lun,VVname,Host,Port,r/w,r/w_Cur,r/w_Avg,r/w_Max,I/O_Cur,I/O_Avg,I/O_Max,KB_Cur,KB_Avg,Svt_Cur,Svt_Avg,Qlen,Time,Date" 	}
							foreach ( $s in  $Result[0..$LastItem] )
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
							$Result = Import-Csv $tempFile
						}
				}
			'statvv'
				{	if ( $Delay )	{	$cmd+=" -d $Delay "			}
					if ( $domian )	{	$cmd+=" -domain $domian"	}			
					if ( $Volume )	{	$cmd+="  $Volume"			}	
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd	
					if ( $ShowRaw ) { return $Result }
					$range1 = $Result.count
					if ( $range1 -eq "4" )	{	return "No data available"	}	
					if ( $Result.Count -gt 1)
						{	$LastItem = $Result.Count
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
							$Result = Import-Csv $tempFile	
						}
				}
			'statisci'
				{	if ( $Iterations )	{	$cmd= " statiscsi -dd -iter $Iterations "	}
					else 				{	$cmd= " statiscsi -dd -iter 1 "	}
					if ( $Delay)		{	$cmd+=" -d $Delay "				}	
					if ( $Node)			{	$cmd+=" -nodes $Node "			}
					if ( $Slot)			{	$cmd+=" -slots $Slot "			}
					if ( $Port)			{	$cmd+=" -ports $Port "			}
					if ( $Fullcounts)	{	$cmd+=" -fullcounts "			}
					if ( $Prev)			{	$cmd+=" -prev "					}
					if ( $Begin)		{	$cmd+=" -begin "				}	
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $cmd
					write-verbose "  Executing Get-A9iSCSIStats command that displays information iSNS table for iSCSI ports in the system  " 	
					if ( $ShowRaw )	{ return $result }
					if($Result -match "Total" -or $Result.Count -gt 1)
						{	$LastItem = $Result.Count 
							$Flag = "False"
							$Loop_Cnt = 2	
							if($Fullcounts)	{	$Loop_Cnt = 1	}		
							foreach ($s in  $Result[$Loop_Cnt..$LastItem] )
								{	if($Flag -eq "true")
										{	if(($s -match "From start of statiscsi command") -or ($s -match "----Receive---- ---Transmit---- -----Total-----") -or ($s -match "port    Protocol Pkts/s KBytes/s Pkts/s KBytes/s Pkts/s KBytes/s Errs/") -or ($s -match "Counts/sec") -or ($s -match "Port Counter                             Current CmdStart   Begin"))
												{	if(($s -match "port    Protocol Pkts/s KBytes/s Pkts/s KBytes/s Pkts/s KBytes/s Errs/") -or ($s -match "Port Counter                             Current CmdStart   Begin"))
														{	$temp="=============================="
															Add-Content -Path $tempFile -Value $temp
														}
												}
											else{	$s= [regex]::Replace($s,"^ ","")			
													$s= [regex]::Replace($s," +",",")	
													$s= [regex]::Replace($s,"-","")
													$s= $s.Trim() -replace 'Pkts/s,KBytes/s,Pkts/s,KBytes/s,Pkts/s,KBytes/s','Pkts/s(Receive),KBytes/s(Receive),Pkts/s(Transmit),KBytes/s(Transmit),Pkts/s(Total),KBytes/s(Total)' 	
													if($s.length -ne 0)
														{	if(-not $Fullcounts)	{	$s=$s.Substring(1)		}
														}				
													Add-Content -Path $tempFile -Value $s	
												}
										}
									else{	$s= [regex]::Replace($s,"^ ","")			
											$s= [regex]::Replace($s," +",",")	
											$s= [regex]::Replace($s,"-","")
											$s= $s.Trim() -replace 'Pkts/s,KBytes/s,Pkts/s,KBytes/s,Pkts/s,KBytes/s','Pkts/s(Receive),KBytes/s(Receive),Pkts/s(Transmit),KBytes/s(Transmit),Pkts/s(Total),KBytes/s(Total)' 	
											if($s.length -ne 0)
												{	if(-not $Fullcounts)	{	$s=$s.Substring(1)	}					
												}				
											Add-Content -Path $tempFile -Value $s	
										}
									$Flag = "true"			
								}
							$Result = Import-Csv $tempFile 
						}
				}
			'statfcoe'
				{	if ( $interval )	{	$Cmd += " -d $interval " 	}
					if ( $Iteration )	{	$Cmd += " -iter $Iteration "}
					if ( $Node )		{	$Cmd += " -nodes $Node " 	}
					if ( $Slot )		{	$Cmd += " -slots $Slot " 	}
					if ( $Port )		{	$Cmd += " -ports $Port " 	}
					if ( $Counts )		{	$Cmd += " -counts " 		}
					if ( $Fullcounts )	{	$Cmd += " -fullcounts " 	}
					if ( $Prev )		{	$Cmd += " -prev " 			}
					if ( $Begin )		{	$Cmd += " -begin " 			}
					write-verbose "Executing the following SSH command `n`t $cmd"
					$Result = Invoke-A9CLICommand -cmds  $Cmd
					Return $Result
				}
		}
	Remove-Item $tempFile
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	return $Result	
}
}

Function Set-A9StatisticsChunklets_CLI
{
<#
.SYNOPSIS
    The Set-Statch command sets the statistics collection mode for all in-use chunklets on a Physical Disk (PD).
.DESCRIPTION
	The Set-Statch command sets the statistics collection mode for all in-use chunklets on a Physical Disk (PD).
.PARAMETER Action
	You must select either Start or Stop as the action to start or stop the collection of statistics
.PARAMETER Chunklet 	
	Specifies the chunklet that is configured using the setstatch command.	
.PARAMETER PhysicalDiskId
	Use the Get-A9PhysicalDisk to get the valid physical disk Ids.
.EXAMPLE
	PS:> Set-A9StatisticsChunklets -action Start -PhysicalDiskId 2 
	
	This Example sets the statistics collection mode for all in-use chunklets on a Physical Disk (PD) 2.
.EXAMPLE 
	PS:> Set-A9StatisticsChunklet -action Start -Logicaldiskname test1 -Chunklet 1  
	
	This example starts and stops the statistics collection mode for chunklets.with the Logicaldisk named test1.
.NOTES
	This command utilizes the SSH command 'SetStatCh', 'setstatpdch'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='setstatch',Mandatory)]		[String]	$LogicalDiskName,
		[Parameter(ParameterSetName='setstatch',Mandatory)]		[String]	$Chunklet,
		[Parameter(ParameterSetName='SetStatPdCh',Mandatory)]	
		[Parameter(ParameterSetName='setstatch',Mandatory)]	
		[ValidateSet('start','stop')]							[string]	$Action,
		[Parameter(ParameterSetName='SetStatPdCh',Mandatory)]	[String]	$PhysicalDiskID
	)		
Begin
{	Test-A9Connection -ClientType SshClient
}
Process	
{	$cmd = $PSCmdlet.ParameterSetName + ' ' +  $action
	switch ($PSCmdlet.ParameterSetName)
		{	'setstatch'
				{	$cmd += $LogicalDiskName
					if ( $Chunklet ) 	{	$cmd+=" $Chunklet"	}
				}
			'setstatpdch'
				{	$cmd += " $PhysicalDiskId"
				}
		}
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if([string]::IsNullOrEmpty($Result))
		{	write-host "Success : Executing Command 	 " -ForegroundColor green
		}
	else{	write-warning "FAILURE : While Executing $Cmd"
		}
	return $Result 
	
} 
}

Function Measure-A9System_CLI
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
	This command utilizes the SSH command 'tuneSys'
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}
