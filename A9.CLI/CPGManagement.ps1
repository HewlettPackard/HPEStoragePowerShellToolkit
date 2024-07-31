####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9CPG_CLI
{
<#
.SYNOPSIS
    Get list of common provisioning groups (CPGs) in the system.
.DESCRIPTION
    Get list of common provisioning groups (CPGs) in the system.
.EXAMPLE
    PS:> Get-A9CPG_CLI

	List all/specified common provisioning groups (CPGs) in the system.  
.EXAMPLE
	PS:> Get-A9CPG_CLI -cpgName "MyCPG" 

	List Specified CPG name "MyCPG"
.EXAMPLE
	PS:> Get-A9CPG_CLI -Detailed -cpgName "MyCPG" 

	Displays detailed information about the CPGs.
.EXAMPLE
	PS:> Get-A9CPG_CLI -RawSpace -cpgName "MyCPG" 

	Specifies that raw space used by the CPGs is displayed.
.EXAMPLE
	PS:> Get-A9CPG_CLI -AlertTime -cpgName "MyCPG" 

	Show times when alerts were posted (when applicable).
.EXAMPLE
	PS:> Get-A9CPG_CLI -Domain_Name XYZ -cpgName "MyCPG" 

	Show times with domain name depict.
.PARAMETER cpgName 
    Specify name of the cpg to be listed.
.PARAMETER ListCols
	List the columns available to be shown in the -showcols option described below (see "clihelp -col showcpg" for help on each column).
.PARAMETER Detailed
	Displays detailed information about the CPGs. The following columns are shown:
	Id Name Warn% VVs TPVVs TDVVs UsageUsr UsageSnp Base SnpUsed Free Total
	LDUsr LDSnp RC_UsageUsr RC_UsageSnp DDSType DDSSize
.PARAMETER RawSpace
	Specifies that raw space used by the CPGs is displayed. The following columns are shown:
	Id Name Warn% VVs TPVVs TDVVs UsageUsr UsageSnp Base RBase SnpUsed SnpRUsed Free RFree Total RTotal
.PARAMETER Alert
	Indicates whether alerts are posted. The following columns are shown: Id Name Warn% UsrTotal DataWarn DataLimit DataAlertW% DataAlertW DataAlertL DataAlertF
.PARAMETER Alerttime
	Show times when alerts were posted (when applicable). The following columns are shown:
	Id Name DataAlertW% DataAlertW DataAlertL DataAlertF
.PARAMETER SAG
	Specifies that the snapshot admin space auto-growth parameters are displayed. The following columns are displayed:
	Id Name AdmWarn AdmLimit AdmGrow AdmArgs
.PARAMETER SDG
	Specifies that the snapshot data space auto-growth parameters are displayed. The following columns are displayed:
	Id Name DataWarn DataLimit DataGrow DataArgs
.PARAMETER Space
	Show the space saving of CPGs. The following columns are displayed: Id Name Warn% Shared Private Free Total Compaction Dedup DataReduce Overprov
.PARAMETER Hist
	Specifies that current data from the CPG, as well as the CPG's history data is displayed.
.PARAMETER Domain_Name
	Shows only CPGs that are in domains with names matching one or more of the <domain_name_or_pattern> argument. This option does not allow
	listing objects within a domain of which the user is not a member. Patterns are glob-style (shell-style) patterns (see help on sub,globpat).
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$ListCols,
		[Parameter()]	[switch]	$Detailed, 
		[Parameter()]	[switch]	$RawSpace,
		[Parameter()]	[switch]	$Alert,
		[Parameter()]	[switch]	$AlertTime,
		[Parameter()]	[switch]	$SAG,
		[Parameter()]	[switch]	$SDG,
		[Parameter()]	[switch]	$Space,
		[Parameter()]	[switch]	$History,
		[Parameter()]	[String]	$Domain_Name,
		[Parameter()]	[String]	$cpgName
	)		
Begin	
{   Test-A9Connection -ClientType 'SshClient'
}
Process
{	$GetCPGCmd = "showcpg "
	if($ListCols)		{	$GetCPGCmd += "-listcols "	}
	if($Detailed)		{	$GetCPGCmd += "-d "			}
	if($RawSpace)		{	$GetCPGCmd += "-r "			}
	if($Alert)			{	$GetCPGCmd += "-alert "		}
	if($AlertTime)		{	$GetCPGCmd += "-alerttime "	}
	if($SAG)			{	$GetCPGCmd += "-sag "		}
	if($SDG)			{	$GetCPGCmd += "-sdg "		}
	if($Space)			{	$GetCPGCmd += "-space "		}
	if($History)		{	$GetCPGCmd += "-hist "		}
	if($Domain_Name)	{	$GetCPGCmd += "-domain $Domain_Name "	}
	if ($cpgName)		{	$objType = "cpg"
							$objMsg  = "cpg"
							if ( -not ( Test-A9CLIObject -objectType $objType -objectName $cpgName -objectMsg $objMsg )) 
									{	return "FAILURE : No cpg $cpgName found"
									}
							$GetCPGCmd += "  $cpgName"
						}	
	$Result = Invoke-A9CLICommand -cmds  $GetCPGCmd	
	if($ListCols -or $History)	{	return $Result	}
	if ( $Result.Count -gt 1)
		{	$3parosver = Get-Version -S 
			if($3parosver -eq "3.2.2")
				{	if($Alert -Or $AlertTime -Or $SAG -Or $SDG)
						{	$Cnt
							if($Alert)	{	$Cnt=2	}
							if($AlertTime -Or $SAG -Or $SDG )	{	$Cnt=1	}
							$tempFile = [IO.Path]::GetTempFileName()
							$LastItem = $Result.Count
							$incre = "true"
							foreach ($s in  $Result[$Cnt..$LastItem] )
								{	$s= [regex]::Replace($s,"^ ","")						
									$s= [regex]::Replace($s," +",",")			
									$s= [regex]::Replace($s,"-","")			
									$s= $s.Trim()
									if($AlertTime)	{	$TempRep = $s -replace 'L','L_Date,L_Time,L_Zone'
														$s = $TempRep
													}
									if($incre -eq "true")
										{	$sTemp1=$s				
											$sTemp = $sTemp1.Split(',')
											if($Alert)
												{	$sTemp[3]="Total_MB_Data"
													$sTemp[10]="Total_MB_Adm"							
													$sTemp[11]="W%_Alerts_Adm"
													$sTemp[12]="F_Alerts_Adm"
												}
											if($AlertTime)
												{	$sTemp[2]="W%_DataAlerts"
													$sTemp[3]="W_DataAlerts"
													$sTemp[7]="F_DataAlerts"
													$sTemp[8]="W%_AdmAlerts"
													$sTemp[9]="F_AdmAlerts"
												}						
											$newTemp= [regex]::Replace($sTemp,"^ ","")			
											$newTemp= [regex]::Replace($sTemp," ",",")				
											$newTemp= $newTemp.Trim()
											$s=$newTemp							
										}
									Add-Content -Path $tempFile -Value $s
									$incre="false"					
								}
							if ($CPGName)	{	Import-Csv $tempFile | where-object  {$_.Name -like $CPGName} }
							else			{	Import-Csv $tempFile	}			
							Remove-Item  $tempFile
						}
					elseif($Space -or $Domain_Name)
						{	$tempFile = [IO.Path]::GetTempFileName()
							$LastItem = $Result.Count-2
							$incre = "true" 			
							foreach ($s in  $Result[2..$LastItem] )
								{	$s= [regex]::Replace($s,"^ ","")						
									$s= [regex]::Replace($s," +",",")			
									$s= [regex]::Replace($s,"-","")			
									$s= $s.Trim()
									if($incre -eq "true")
									{	$sTemp1=$s				
										$sTemp = $sTemp1.Split(',')
										if($Space)
											{	$sTemp[2]="Warn%_User_MB"
												$sTemp[3]="Total_User_MB"							
												$sTemp[4]="Used_User_MB"
												$sTemp[5]="Total_Snp_MB"							
												$sTemp[6]="Used_Snp_MB"
												$sTemp[7]="Total_Adm_MB"							
												$sTemp[8]="Used_Adm_MB"
											}	
										if($Domain_Name)
											{	$sTemp[8]="Total_User_MB"							
												$sTemp[9]="Used_User_MB"
												$sTemp[10]="Total_Snp_MB"							
												$sTemp[11]="Used_Snp_MB"
												$sTemp[12]="Total_Adm_MB"							
												$sTemp[13]="Used_Adm_MB"
											}
										$newTemp= [regex]::Replace($sTemp,"^ ","")			
										$newTemp= [regex]::Replace($sTemp," ",",")				
										$newTemp= $newTemp.Trim()
										$s=$newTemp							
									}
									Add-Content -Path $tempFile -Value $s
									$incre="false"				
								}
							if ($CPGName)	{	Import-Csv $tempFile | where-object  {$_.Name -like $CPGName} 	}
							else			{	Import-Csv $tempFile 	}			
							Remove-Item  $tempFile
						}
					else{	$tempFile = [IO.Path]::GetTempFileName()
							$LastItem = $Result.Count - 2
							$incre = "true" 			
							foreach ($s in  $Result[2..$LastItem] )
								{	$s= [regex]::Replace($s,"^ ","")						
									$s= [regex]::Replace($s," +",",")			
									$s= [regex]::Replace($s,"-","")			
									$s= $s.Trim()			
									if($incre -eq "true")
										{	$sTemp1=$s				
											$sTemp = $sTemp1.Split(',')
											if($Detailed)
												{	$sTemp[6]="Usr_Usage"
													$sTemp[7]="Snp_Usage"
													$sTemp[8]="Total_User_MB"							
													$sTemp[9]="Used_User_MB"
													$sTemp[10]="Total_Snp_MB"							
													$sTemp[11]="Used_Snp_MB"
													$sTemp[12]="Total_Adm_MB"							
													$sTemp[13]="Used_Adm_MB"
													$sTemp[14]="Usr_LD"
													$sTemp[15]="Snp_LD"
													$sTemp[16]="Adm_LD"
													$sTemp[17]="Usr_RC_Usage"
													$sTemp[18]="Snp_RC_Usage"	
												}
											elseif($RawSpace)
												{	$sTemp[6]="Usr_Usage"
													$sTemp[7]="Snp_Usage"
													$sTemp[8]="Total_User_MB"
													$sTemp[9]="RTotal_User_MB"							
													$sTemp[10]="Used_User_MB"
													$sTemp[11]="RUsed_User_MB"
													$sTemp[12]="Total_Snp_MB"
													$sTemp[13]="RTotal_Snp_MB"
													$sTemp[14]="Used_Snp_MB"
													$sTemp[15]="RUsed_Snp_MB"
													$sTemp[16]="Total_Adm_MB"
													$sTemp[17]="RTotal_Adm_MB"
													$sTemp[18]="Used_Adm_MB"
													$sTemp[19]="RUsed_Adm_MB"
												}
											else{	$sTemp[6]="Usr_Usage"
													$sTemp[7]="Snp_Usage"
													$sTemp[8]="Total_User_MB"							
													$sTemp[9]="Used_User_MB"
													$sTemp[10]="Total_Snp_MB"							
													$sTemp[11]="Used_Snp_MB"
													$sTemp[12]="Total_Adm_MB"							
													$sTemp[13]="Used_Adm_MB"
												}					
											$newTemp= [regex]::Replace($sTemp,"^ ","")			
											$newTemp= [regex]::Replace($sTemp," ",",")				
											$newTemp= $newTemp.Trim()
											$s=$newTemp							
										}						
									Add-Content -Path $tempFile -Value $s	
									$incre="false"
								}
							if ($CPGName)	{	Import-Csv $tempFile | where-object  {$_.Name -like $CPGName} 	}
							else			{	Import-Csv $tempFile	}			
							Remove-Item  $tempFile
						}
				}
			else{	if($Alert -Or $AlertTime -Or $SAG -Or $SDG)
						{	$Cnt
							if($Alert)	{	$Cnt=2	}
							if($AlertTime -Or $SAG -Or $SDG )	{	$Cnt=1	}
							$tempFile = [IO.Path]::GetTempFileName()
							$LastItem = $Result.Count						
							foreach ($s in  $Result[$Cnt..$LastItem] )
								{	$s= [regex]::Replace($s,"^ ","")						
									$s= [regex]::Replace($s," +",",")			
									$s= [regex]::Replace($s,"-","")			
									$s= $s.Trim()									
									Add-Content -Path $tempFile -Value $s				
								}
							if ($CPGName)	{ 	Import-Csv $tempFile | where-object  {$_.Name -like $CPGName} 	}
							else			{	Import-Csv $tempFile	}			
							Remove-Item  $tempFile
						}
					elseif($Space -or $Domain_Name)
						{	$tempFile = [IO.Path]::GetTempFileName()
							$LastItem = $Result.Count-2
							$incre = "true" 			
							foreach ($s in  $Result[1..$LastItem] )
								{	$s= [regex]::Replace($s,"^ ","")						
									$s= [regex]::Replace($s," +",",")			
									$s= [regex]::Replace($s,"-","")			
									$s= $s.Trim()
									if($incre -eq "true")
										{	$sTemp1=$s				
											$sTemp = $sTemp1.Split(',')
											if($Space)
												{	$sTemp[3]="Base(Private(MiB))"
													$sTemp[4]="Snp(Private(MiB))"							
													$sTemp[5]="Shared(MiB)"
													$sTemp[6]="Free(MiB)"
													$sTemp[7]="Total(MiB)"							
													$sTemp[8]="Compact(Efficiency)"						
													$sTemp[9]="Dedup(Efficiency)"						
													$sTemp[10]="Compress(Efficiency)"						
													$sTemp[11]="DataReduce(Efficiency)"	
													$sTemp[12]="Overprov(Efficiency)"
												}	
											if($Domain_Name)
												{	$sTemp[3]="VVs(Volumes)"
													$sTemp[4]="TPVVs(Volumes)"							
													$sTemp[5]="TDVVs(Volumes)"
													$sTemp[6]="Usr(Usage)"
													$sTemp[7]="Snp(Usage)"							
													$sTemp[8]="Base(MiB)"						
													$sTemp[9]="Snp(MiB)"						
													$sTemp[10]="Free(MiB)"						
													$sTemp[11]="Total(MiB)"
												}
											$newTemp= [regex]::Replace($sTemp,"^ ","")			
											$newTemp= [regex]::Replace($sTemp," ",",")				
											$newTemp= $newTemp.Trim()
											$s=$newTemp							
										}
									Add-Content -Path $tempFile -Value $s
									$incre="false"				
								}
							if ($CPGName)	{	Import-Csv $tempFile | where-OBJECT  {$_.Name -like $CPGName} 	}
							else			{	Import-Csv $tempFile 	}			
							Remove-Item  $tempFile
						}
					else{	$tempFile = [IO.Path]::GetTempFileName()
							$LastItem = $Result.Count - 2
							$incre = "true" 			
							foreach ($s in  $Result[1..$LastItem] )
								{	$s= [regex]::Replace($s,"^ ","")						
									$s= [regex]::Replace($s," +",",")			
									$s= [regex]::Replace($s,"-","")			
									$s= $s.Trim()
									if($incre -eq "true")
										{	$sTemp1=$s				
											$sTemp = $sTemp1.Split(',')
											if($Detailed)
												{	$sTemp[3]="VVs(Volumes)"
													$sTemp[4]="TPVVs(Volumes)"							
													$sTemp[5]="TDVVs(Volumes)"
													$sTemp[6]="Usr(Usage)"
													$sTemp[7]="Snp(Usage)"							
													$sTemp[8]="Base(MiB)"						
													$sTemp[9]="Snp(MiB)"						
													$sTemp[10]="Free(MiB)"						
													$sTemp[11]="Total(MiB)"	
													$sTemp[12]="Usr(LD)"
													$sTemp[13]="Snp(LD)"
													$sTemp[14]="Usr(RC_Usage)"
													$sTemp[15]="Snp(RC_Usage)"
												}
											elseif($RawSpace)
												{	$sTemp[3]="VVs(Volumes)"
													$sTemp[4]="TPVVs(Volumes)"							
													$sTemp[5]="TDVVs(Volumes)"
													$sTemp[6]="Usr(Usage)"
													$sTemp[7]="Snp(Usage)"							
													$sTemp[8]="Base(MiB)"
													$sTemp[9]="RBase(MiB)"
													$sTemp[10]="Snp(MiB)"
													$sTemp[11]="RSnp(MiB)"
													$sTemp[12]="Free(MiB)"
													$sTemp[13]="RFree(MiB)"
													$sTemp[14]="Total(MiB)"
													$sTemp[15]="RTotal(MiB)"
												}
											else{	$sTemp[3]="VVs(Volumes)"
													$sTemp[4]="TPVVs(Volumes)"							
													$sTemp[5]="TDVVs(Volumes)"
													$sTemp[6]="Usr(Usage)"
													$sTemp[7]="Snp(Usage)"							
													$sTemp[8]="Base(MiB)"						
													$sTemp[9]="Snp(MiB)"						
													$sTemp[10]="Free(MiB)"						
													$sTemp[11]="Total(MiB)"
												}					
											$newTemp= [regex]::Replace($sTemp,"^ ","")			
											$newTemp= [regex]::Replace($sTemp," ",",")				
											$newTemp= $newTemp.Trim()
											$s=$newTemp
										}						
									Add-Content -Path $tempFile -Value $s	
									$incre="false"
								}
							if ($CPGName)	{	Import-Csv $tempFile 	}
							else			{	Import-Csv $tempFile	}			
							Remove-Item  $tempFile
						}
				}
		}
	elseif($Result -match "FAILURE")	{	return $Result}
	else								{	return $Result }
}
} 

Function New-A9CPG_CLI
{
<#
.SYNOPSIS
    The command creates a Common Provisioning Group (CPG).
.DESCRIPTION
    The command creates a Common Provisioning Group (CPG).
.EXAMPLE
    New-A9CPG_CLI -cpgName "MyCPG" -Size 32G	-RAIDType r1 
	Creates a CPG named MyCPG with initial size of 32GB and Raid configuration is r1 (RAID 1)
.EXAMPLE 
	PS:> New-A9CPG_CLI -cpgName asCpg
.EXAMPLE 
	PS:> New-A9CPG_CLI -cpgName asCpg1 -TemplateName temp
.EXAMPLE	
	PS:> New-A9CPG_CLI -cpgName asCpg1 -AW 1
.EXAMPLE	
	PS:> New-A9CPG_CLI -cpgName asCpg1 -SDGS 1
.EXAMPLE	
	PS:> New-A9CPG_CLI -cpgName asCpg1 -SDGL 12241
.EXAMPLE	
	PS:> New-A9CPG_CLI -cpgName asCpg1 -saLD_name XYZ
.EXAMPLE	
	PS:> New-A9CPG_CLI -cpgName asCpg1 -sdLD_name XYZ
.EXAMPLE	
	PS:> New-A9CPG_CLI -cpgName asCpg1 -RAIDType r1	
.PARAMETER TemplateName
	Use the options defined in template <template_name>. The template is created using the createtemplate command.  Options specified in the
	template are read-only or read-write. The read-write options may be overridden with new options at the time of their creation, but read-only
	options may not be overridden at the time of creation.

	Options not explicitly specified in the template take their default values, and all of these options are either read-only or read-write
	(using the -nro or -nrw options of the createtemplate command).
.PARAMETER AW
	Specifies the percentage of used snapshot administration or snapshot data space that results in a warning alert. A percent value of 0
	disables the warning alert generation. The default is 0. This option is deprecated and will be removed in a subsequent release.
.PARAMETER SDGS
	Specifies the growth increment, the amount of logical disk storage created on each auto-grow operation. The default growth increment may
	vary according to the number of controller nodes in the system. If <size> is non-zero it must be 8G or bigger. The size can be specified in MB (default)
	or GB (using g or G) or TB (using t or T). A size of 0 disables the auto-grow feature. The following table displays the default and minimum growth
	increments per number of nodes:
					Number of Nodes       Default     Minimum
						1-2               32G          8G
						3-4               64G         16G
						5-6               96G         24G
						7-8              128G         32G
.PARAMETER SDGL
	Specifies that the auto-grow operation is limited to the specified	storage amount. The storage amount can be specified in MB (default) or
	GB (using g or G) or TB (using t or T). A size of 0 (default) means no limit is enforced.  To disable auto-grow, set the limit to 1.
.PARAMETER SDGW
	Specifies that the threshold of used logical disk space, when exceeded,	results in a warning alert. The size can be specified in MB (default) or
	GB (using g or G) or TB (using t or T). A size of 0 (default) means no warning limit is enforced. To set the warning for any used space, set the limit to 1.
.PARAMETER saLD_name
	Specifies that existing logical disks are added to the CPG and are used for snapshot admin (SA) space allocation. The <LD_name> argument can be
	repeated to specify multiple logical disks. This option is deprecated and will be removed in a subsequent release.
.PARAMETER sdLD_name
	Specifies that existing logical disks are added to the CPG and are used for snapshot data (SD) space allocation. The <LD_name> argument can be
	repeated to specify multiple logical disks. This option is deprecated and will be removed in a subsequent release.
.PARAMETER Domain
	Specifies the name of the domain with which the object will reside. The object must be created by a member of a particular domain with Edit or
	Super role. The default is to create it in the current domain, or no domain if the current domain is not set.
.PARAMETER RAID_type
	Specifies the RAID type of the logical disk: r0 for RAID-0, r1 for RAID-1, r5 for RAID-5, or r6 for RAID-6. If no RAID type is specified,
	then the default is r6.
.PARAMETER SSZ
	Specifies the set size in terms of chunklets. The default depends on the RAID type specified: 2 for RAID-1, 4 for RAID-5, and 8 for RAID-6.
.PARAMETER RS
	Specifies the number of sets in a row. The <size> is a positive integer. If not specified, no row limit is imposed.
.PARAMETER SS
	Specifies the step size from 32 KB to 512 KB. The step size should be a power of 2 and a multiple of 32. The default value depends on raid type and
	device type used. If no value is entered and FC or NL drives are used, the step size defaults to 256 KB for RAID-0 and RAID-1, and 128 KB for RAID-5.
	If SSD drives are used, the step size defaults to 32 KB for RAID-0 and RAID-1, and 64 KB for RAID-5. For RAID-6, the default is a function of the set size.
.PARAMETER HA
	Specifies that the layout must support the failure of one port pair, one cage, or one drive magazine (mag). This option has no meaning for RAID-0. The default is cage availability.
.PARAMETER CH
	Specifies the chunklet location characteristics: either first (attempt to use the lowest numbered available chunklets) or last(attempt to 
	use the highest numbered available chunklets). If no argument is specified, the default characteristic is first.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(mandatory=$true)]	
						[String]	$cpgName,	
		[Parameter()]	[String]	$TemplateName,
		[Parameter()]	[String]	$AW,
		[Parameter()]	[String]	$SDGS,
		[Parameter()]	[String]	$SDGL,
		[Parameter()]	[String]	$SDGW,
		[Parameter()]	[String]	$saLD_name,
		[Parameter()]	[String]	$sdLD_name,
		[Parameter()]	[String]	$Domain,
		[Parameter()]	[String]	$RAIDType,
		[Parameter()]	[String]	$SSZ,
		[Parameter()]	[String]	$RS,
		[Parameter()]	[String]	$SS,
		[Parameter()]	[ValidateSet('mag','cage','port')]	
						[String]	$HA,
		[Parameter()]	[ValidateSet('first','last')]	
						[String]	$CH
	)		
Begin	
{   Test-A9Connection -ClientType 'SshClient'
}
Process
{	$CreateCPGCmd =" createcpg -f" 
	if($TemplateName)	{	$CreateCPGCmd += " -templ $TemplateName "	}
	if($AW)				{	$CreateCPGCmd += " -aw $AW "	}
	if($SDGS)			{	$CreateCPGCmd += " -sdgs $SDGS "	}
	if($SDGL)			{	$CreateCPGCmd += " -sdgl $SDGL "	}
	if($SDGW)			{	$CreateCPGCmd += " -sdgw $SDGW "	}
	if($saLD_name)		{	$CreateCPGCmd += " -sa $saLD_name "	}
	if($sdLD_name)		{	$CreateCPGCmd += " -sd $sdLD_name "	}
	if($Domain)			{	$CreateCPGCmd += " -domain $Domain "}
	if($RAIDType)		{	$CreateCPGCmd += " -t $RAIDType "	}
	if($SSZ)			{	$CreateCPGCmd += " -ssz $SSZ "		}
	if($RS)				{	$CreateCPGCmd += " -rs $RS "		}
	if($SS)				{	$CreateCPGCmd += " -ss $SS "		}
	if($HA)				{	$CreateCPGCmd += " -ha $HA "		}
	if($CH)				{	$CreateCPGCmd += " -ch $CH "		}
	$CreateCPGCmd += " $cpgName"
	$Result1 = Invoke-A9CLICommand -cmds  $CreateCPGCmd	
	return $Result1
} 
}

Function Remove-A9CPG_CLI
{
<#
.SYNOPSIS
    Removes a Common Provisioning Group(CPG)
.DESCRIPTION
	Removes a Common Provisioning Group(CPG)
.EXAMPLE
    Remove-A9CPG_CLI -cpgName "MyCPG"  -force
	
	Removes a Common Provisioning Group(CPG) "MyCPG"
.PARAMETER force
	forcefully execute the command.
.PARAMETER saLDname
	Specifies that the logical disk, as identified with the <LD_name> argument, used for snapshot administration space allocation is removed.
	The <LD_name> argument can be repeated to specify multiple logical disks.
	This option is deprecated and will be removed in a subsequent release.
.PARAMETER sdLDname
	Specifies that the logical disk, as identified with the <LD_name> argument, used for snapshot data space allocation is removed. The
	<LD_name> argument can be repeated to specify multiple logical disks. This option is deprecated and will be removed in a subsequent release.
.PARAMETER cpgName 
    Specify name of the CPG
.PARAMETER Pat 
    The specified patterns are treated as glob-style patterns and that all common provisioning groups matching the specified pattern are removed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$force,
		[Parameter(Mandatory=$true)]	[String]	$cpgName,
		[Parameter()]	[String]	$sdLDname,
		[Parameter()]	[String]	$saLDname,
		[Parameter()]	[switch]	$Pat
	)
Begin	
{   Test-A9Connection -ClientType 'SshClient'
}
Process
{	if ($cpgName)
		{	if(!($force))
				{	write-verbose "no force option selected to remove CPG, Exiting...."
					return "FAILURE: No -force option selected to remove cpg $cpgName"
				}
			$objType = "cpg"
			$objMsg  = "cpg"
			$RemoveCPGCmd = "removecpg "
			if ( -not ( Test-A9CLIObject -objectType $objType -objectName $cpgName -objectMsg $objMsg )) 
				{	write-verbose " CPG $cpgName does not exist. Nothing to remove"   
					return "FAILURE: No cpg $cpgName found"
				}
			else
				{	if($force)		{	$RemoveCPGCmd +=" -f "	}
					if($Pat)	{	$RemoveCPGCmd +=" -pat "}
					if ($saLDname)	{	$RemoveCPGCmd +=" -sa $saLDname "}
					if ($sdLDname)	{	$RemoveCPGCmd +=" -sd $sdLDname "	}
					$RemoveCPGCmd += " $cpgName "
					$Result3 = Invoke-A9CLICommand -cmds  $RemoveCPGCmd
					write-verbose "Removing CPG  with the command --> $RemoveCPGCmd" 
					if (Test-A9CLIObject -objectType $objType -objectName $cpgName -objectMsg $objMsg)
						{	write-verbose " CPG $cpgName exists. Nothing to remove"   
							return "FAILURE: While removing cpg $cpgName `n $Result3"
						}
					else
						{	if ($Result3 -match "Removing CPG")	{	return "Success : Removed cpg $cpgName"}
							else								{	return "FAILURE: While removing cpg $cpgName $Result3"	}
						}			
				}		
		}
}		
}

Function Set-A9CPG
{
<#
.SYNOPSIS
	Update a Common Provisioning Group (CPG)
.DESCRIPTION
	The command modifies existing Common Provisioning Groups (CPG).
.PARAMETER Sa
	Specifies that existing logical disks are added to the CPG and are used for snapshot admin (SA) space allocation. The <LD_name> argument can be
	repeated to specify multiple logical disks. This option is deprecated and will be removed in a subsequent release.
.PARAMETER Sd
	Specifies that existing logical disks are added to the CPG and are used for snapshot data (SD) space allocation. The <LD_name> argument can be
	repeated to specify multiple logical disks. This option is deprecated and will be removed in a subsequent release.
.PARAMETER Aw
	Specifies the percentage of used snapshot administration or snapshot data space that results in a warning alert. A percent value of 0
	disables the warning alert generation. The default is 0. This option is deprecated and will be removed in a subsequent release.
.PARAMETER Sdgs
	Specifies the growth increment, the amount of logical disk storage created on each auto-grow operation. The default growth increment may
	vary according to the number of controller nodes in the system. If <size> is non-zero it must be 8G or bigger. The size can be specified in MB (default)
	or GB (using g or G) or TB (using t or T). A size of 0 disables the auto-grow feature. The following table displays the default and minimum growth
	increments per number of nodes:
		Number of Nodes       Default     Minimum	
		1-2               32G          8G
		3-4               64G         16G
		5-6               96G         24G
		7-8              128G         32G
.PARAMETER Sdgl
	Specifies that the auto-grow operation is limited to the specified storage amount. The storage amount can be specified in MB (default) or
	GB (using g or G) or TB (using t or T). A size of 0 (default) means no limit is enforced.  To disable auto-grow, set the limit to 1.
.PARAMETER Sdgw
	Specifies that the threshold of used logical disk space, when exceeded, results in a warning alert. The size can be specified in MB (default) or
	GB (using g or G) or TB (using t or T). A size of 0 (default) means no warning limit is enforced. To set the warning for any used space, set the limit to 1.
.PARAMETER T
	Specifies the RAID type of the logical disk: r1 for RAID-1, or r6 for RAID-6. If no RAID type is specified, then the default is r6.
.PARAMETER Ssz
	Specifies the set size in terms of chunklets. The default depends on the RAID type specified: 3 for RAID-1, and 8 for RAID-6.
.PARAMETER Rs
	Specifies the number of sets in a row. The <size> is a positive integer. If not specified, no row limit is imposed.
.PARAMETER Ss
	Specifies the step size from 32 KiB to 512 KiB. The step size should be a power of 2 and a multiple of 32. The default value depends on raid type and
	device type used. If no value is entered and FC or NL drives are used, the step size defaults to 256 KiB for RAID-1. If SSD drives are used, the step 
	size defaults to 32 KiB for RAID-1. For RAID-6, the default is a function of the set size.
.PARAMETER Ha
	Specifies that the layout must support the failure of one port pair, one cage, or one drive magazine (mag). The default is cage availability.
.PARAMETER Ch
	Specifies the chunklet location characteristics: either first (attempt to use the lowest numbered available chunklets) or last(attempt to use
	the highest numbered available chunklets). If no argument is specified, the default characteristic is first.
.PARAMETER P
	Specifies a pattern for candidate disks. Patterns are used to select disks that are used for creating logical disks. If no pattern is
	specified, the option defaults to Fast Class (FC) disks. If specified multiple times, each instance of the specified pattern adds additional
	candidate disks that match the pattern. The -devtype pattern cannot be used to mix Nearline (NL), FC, and Solid State Drive (SSD) drives. An
	item is specified as an integer, a comma-separated list of integers, or a range of integers specified from low to high.
	The following arguments can be specified as patterns for this option: An item is specified as an integer, a comma-separated list of integers,
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
	Specifies that physical disks with free chunklets less than the number specified be selected.
.PARAMETER Devid
	Specifies that physical disks identified by their models be selected. Models can be specified in a comma-separated list.
	Models can be displayed by issuing the "showpd -i" command.
.PARAMETER Devtype
	Specifies that physical disks must have the specified device type (FC for Fast Class, NL for Nearline, SSD for Solid State Drive) to
	be used. Device types can be displayed by issuing the "showpd" command. If it is not specified, the default device type is FC.
.PARAMETER Rpm
	Disks must be of the specified speed. Device speeds are shown in the RPM column of the showpd command. The number does not represent a
	rotational speed for the drives without spinning media (SSD). It is meant as a rough estimation of the performance difference between
	the drive and the other drives in the system. For FC and NL drives, the number corresponds to both a performance measure and actual
	rotational speed. For SSD drive, the number is to be treated as relative performance benchmark that takes into account in I/O per
	second, bandwidth and the access time. Disks that satisfy all of the specified characteristics are used.
	For example -p -fc_gt 60 -fc_lt 230 -nd 2 specifies all the disks that have greater than 60 and less than 230 free chunklets and that are
	connected to node 2 through their primary path.
.PARAMETER Sax
	Specifies that the logical disk, as identified with the <LD_name> argument, used for snapshot administration space allocation be removed.
	The <LD_name> argument can be repeated to specify multiple logical disks
.PARAMETER Sdx
	Specifies that the logical disk, as identified with the <LD_name> argument, used for snapshot data space allocation be removed. The
	<LD_name> argument can be repeated to specify multiple logical disks.
.PARAMETER NewName
	Specifies the name of the Common Provisioning Group (CPG) to be modified to. <newname> can be up to 31 characters in length.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Sa,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Sd,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Aw,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Sdgs,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Sdgl,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Sdgw,
		[Parameter(ValueFromPipeline=$true)]	[String]	$T,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Ssz,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Rs,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Ss,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Ha,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Ch,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$P,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Nd,
		[Parameter(ValueFromPipeline=$true)]	[String]	$St,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Pt,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Cg,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Mg,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Pn,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Dk,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Tc_gt,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Tc_lt,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Fc_gt,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Fc_lt,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Devid,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Devtype,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Rpm,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Sax,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Sdx,
		[Parameter(ValueFromPipeline=$true)]	[String]	$NewName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$CPG_name
)
Begin	
{   Test-A9Connection -ClientType 'SshType'
}
Process
{	$Cmd = " setcpg -f"
	if($Sa)		{	$Cmd += " -sa $Sa " }
	if($Sd) 	{	$Cmd += " -sd $Sd " }
	if($Aw) 	{	$Cmd += " -aw $Aw " }
	if($Sdgs)	{	$Cmd += " -sdgs $Sdgs " }
	if($Sdgl) 	{	$Cmd += " -sdgl $Sdgl " }
	if($Sdgw) 	{	$Cmd += " -sdgw $Sdgw " }
	if($T) 		{	$Cmd += " -t $T " }
	if($Ssz)	{	$Cmd += " -ssz $Ssz " }
	if($Rs) 	{	$Cmd += " -rs $Rs " }
	if($Ss)		{	$Cmd += " -ss $Ss " }
	if($Ha)		{	$Cmd += " -ha $Ha " }
	if($Ch) 	{	$Cmd += " -ch $Ch " }
	if($P)		{	$Cmd += " -p " }
	if($Nd)		{	$Cmd += " -nd $Nd " }
	if($St)		{	$Cmd += " -st $St " }
	if($Pt) 	{	$Cmd += " -pt $Pt " }
	if($Cg)		{	$Cmd += " -cg $Cg " }
	if($Mg)		{	$Cmd += " -mg $Mg " }
	if($Pn) 	{	$Cmd += " -pn $Pn " }
	if($Dk) 	{	$Cmd += " -dk $Dk " }
	if($Tc_gt) 	{	$Cmd += " -tc_gt $Tc_gt " }
	if($Tc_lt) 	{	$Cmd += " -tc_lt $Tc_lt " }
	if($Fc_gt)	{	$Cmd += " -fc_gt $Fc_gt " }
	if($Fc_lt) 	{	$Cmd += " -fc_lt $Fc_lt " }
	if($Devid)	{	$Cmd += " -devid $Devid " }
	if($Devtype){	$Cmd += " -devtype $Devtype " }
	if($Rpm)	{	$Cmd += " -rpm $Rpm " }
	if($Sax)	{	$Cmd += " -sax $Sax "	}
	if($Sdx)	{	$Cmd += " -sdx $Sdx " }
	if($NewName){	$Cmd += " -name $NewName " }
	if($CPG_name){	$Cmd += " $CPG_name " }
	else		{	Return "CPG Name is mandatory please enter..." }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if ([string]::IsNullOrEmpty($Result))	{    Get-CPG -Detailed -cpgName $CPG_name }
	else	{ 	Return $Result	}
}
}

Function Compress-A9CPG
{
<#
.SYNOPSIS
	Consolidate space in common provisioning groups.
.DESCRIPTION
	The command consolidates logical disk space in Common Provisioning Groups (CPGs) into as few logical disks as possible, allowing
	unused logical disks to be removed and their space reclaimed.
.EXAMPLE
	PS:> Compress-A9CPG -CPG_name xxx 
.EXAMPLE
	PS:> Compress-A9CPG -CPG_name tstCPG
.PARAMETER Pat
	Compacts CPGs that match any of the specified patterns. This option must be used if the pattern specifier is used.
.PARAMETER Waittask
	Waits for any created tasks to complete.
.PARAMETER Trimonly
	Removes unused logical disks after consolidating the space. This option will not perform any region moves.
.PARAMETER Nomatch
	Removes only unused logical disks whose characteristics do not match the growth characteristics of the CPG. Must be used with the -trimonly
	option. If all logical disks match the CPG growth characteristics, this option has no effect.
.PARAMETER Dr
	Specifies that the operation is a dry run, and the tasks are not actually performed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$Pat,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Waittask,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Trimonly,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Nomatch,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Dr,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$CPG_name
)
Begin	
{   Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " compactcpg -f "
	if($Pat) 		{	$Cmd += " -pat " }
	if($Waittask) 	{	$Cmd += " -waittask " }
	if($Trimonly) 	{	$Cmd += " -trimonly " }
	if($Nomatch)	{	$Cmd += " -nomatch " }
	if($Dr)			{	$Cmd += " -dr " }
	if($CPG_name)	{	$Cmd += " $CPG_name "}
	else			{	Return "CPG Name is mandatory please enter...." }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

# SIG # Begin signature block
# MIIt2AYJKoZIhvcNAQcCoIItyTCCLcUCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEA0q4yifc7S
# EDLXr77mDX9Tx1f5GPKhM/W/Zei+IgTqpm30gkScYoH+G7ku54aY96laentkaTpz
# WFUBIb5RhTUzoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQA4PLYwR0EYg9vIJDGNkvSO6BkJU8EUp17cT66UCSWk2QBnvoe6FRmDB
# YiHlFW+z3mBZuIVXr9Qn+GtIUagcIRkwDQYJKoZIhvcNAQEBBQAEggGAM1FhL2k8
# xVl2WX7IggTzXSALE5v78hgZKhzCNMEpk42zrQO4rm8ZZTBLWyoVRMYPtiRAd3sB
# S3h08whandARQ/g5TmJ54YAWKSOjMNg32msuwLAFiklZXuCXQVcrRGYLdddE97MV
# By6kUYr1GShIea7CkgIFK5+yJFsCEw0+BrNSjZFWC32GcaIchqYIa+hPUCGUfJGy
# +GwcL3bZRj8fJz4bTS8hbNb6zZ+EG1a4h8Om2yZ6E8ALPTqFAjq0D1vObVP7w7tt
# CtXW9h708ry0qEpR1OwBpnYI581DogKLUuTndPp7sM0d5+bSLCNtEbsu4SpQWEgr
# zjtUUWnGgYWk95eM04vAvmECMUeBC24FZKBZQ0ZTqs37idwzuY/ZpoO265liHN6k
# 77rXxsvsq9HJ8PUiaF9PR0dShqMfxYrtB0zc8aRKF0rNgXs0jTIlvSdwf3XgGE5c
# Wp0HjQ1EBm47YyiAwTK/BlT9aPLON7OZohy0IRGWq3uUQ1M9CfW16f96oYIY3jCC
# GNoGCisGAQQBgjcDAwExghjKMIIYxgYJKoZIhvcNAQcCoIIYtzCCGLMCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQMGCyqGSIb3DQEJEAEEoIHzBIHwMIHtAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMBvu/vjCIth2u9YENrUF81UidDjCVS72
# fj9ZbZGR7t7xDrKenUv2TBqRkh8JxRhXQwIULHNI+mDByR7zjb/vN0LHCyspTwIY
# DzIwMjQwNzMxMTkxOTA2WqBypHAwbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
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
# NzMxMTkxOTA2WjA/BgkqhkiG9w0BCQQxMgQwjJlEwCqO+I+ncOvi/xS6FWfvOUd+
# tjc99hgfu5cYeKF/d0I7PFUyt84QOA+8pdDRMIIBegYLKoZIhvcNAQkQAgwxggFp
# MIIBZTCCAWEwFgQU+GCYGab7iCz36FKX8qEZUhoWd18wgYcEFMauVOR4hvF8PVUS
# SIxpw0p6+cLdMG8wW6RZMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcg
# Um9vdCBSNDYCEHojrtpTaZYPkcg+XPTH4z8wgbwEFIU9Yy2TgoJhfNCQNcSR3pLB
# QtrHMIGjMIGOpIGLMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eQIQNsKwvXwbOuejs902y8l1aDANBgkqhkiG9w0BAQEFAASCAgBqStDw
# b6OCd8Pb6wx1670DYV/b73SPWKGxnKrgToFSeRSFn3YCLLP64vZgJK4xZhfMReme
# QqZZ2dSqGCJGQuQENL7se1HCX0h4DXpFbGaTDr27LOuI2F3Ih20qzzBDZJTbvn25
# HbW9AL0Bqckq+/yiW/dxKYDPdhEvnVw2l7AqwH0upkcVVH1/O8FsFmcrIHrtfSJ4
# Ou6Xd8mvS1m4s51fzk3bDMHLDWZ6RP6sEYgUfm0MGNwqLKJx3EgOE0LzEqiPde8m
# 3LXVZW+grJJAnP5fGJ1kBdFwegh5sa7lxfM90SVwx3lxIYn950TadlgbLebAeZBA
# YrTnMsXHd7AJy5sYDpUJKyeG5delM25GrADIOCxCvYEPW3pF0oiCUZxfs2UE62kz
# +nMVdlqMe5htSjPIWl1avddH9fT91qzInzHe05ur1T/l7T63uZv1YO/tUqrPfVsZ
# FikFmbWEOp/nn47qJEXJn9ruWmSSVlfOXEUHAFlBhuVBQLaj34vIn+4mZWyf7RBu
# P53CiENAphcU9oGxz47X6jajvsYIuEgX35KAXPJzNq9CsjIfrjYbzwTHrjqweyZm
# Pm9ez7+OlL70/VbjC8m8D6oTis2ujLWqVX96dGPZknGmCHGG+ie7DW5MZ5EA3mjl
# ODJ7Yg30Ro0f/mShY7bp36FZl0htkA0CeL1YXw==
# SIG # End signature block
