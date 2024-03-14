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
    Get-CPG

	List all/specified common provisioning groups (CPGs) in the system.  
.EXAMPLE
	Get-CPG -cpgName "MyCPG" 

	List Specified CPG name "MyCPG"
.EXAMPLE
	Get-CPG -Detailed -cpgName "MyCPG" 

	Displays detailed information about the CPGs.
.EXAMPLE
	Get-CPG -RawSpace -cpgName "MyCPG" 

	Specifies that raw space used by the CPGs is displayed.
.EXAMPLE
	Get-CPG -AlertTime -cpgName "MyCPG" 

	Show times when alerts were posted (when applicable).
.EXAMPLE
	Get-CPG -Domain_Name XYZ -cpgName "MyCPG" 

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
{   Test-A9CLIConnection
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
							if ( -not ( Test-CLIObject -objectType $objType -objectName $cpgName -objectMsg $objMsg )) 
									{	return "FAILURE : No cpg $cpgName found"
									}
							$GetCPGCmd += "  $cpgName"
						}	
	$Result = Invoke-CLICommand -cmds  $GetCPGCmd	
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
    The New-CPG command creates a Common Provisioning Group (CPG).
.DESCRIPTION
    The New-CPG command creates a Common Provisioning Group (CPG).
.EXAMPLE
    New-CPG -cpgName "MyCPG" -Size 32G	-RAIDType r1 
	Creates a CPG named MyCPG with initial size of 32GB and Raid configuration is r1 (RAID 1)
.EXAMPLE 
	New-CPG -cpgName asCpg
.EXAMPLE 
	New-CPG -cpgName asCpg1 -TemplateName temp
.EXAMPLE	
	New-CPG -cpgName asCpg1 -AW 1
.EXAMPLE	
	New-CPG -cpgName asCpg1 -SDGS 1
.EXAMPLE	
	New-CPG -cpgName asCpg1 -SDGL 12241
.EXAMPLE	
	New-CPG -cpgName asCpg1 -saLD_name XYZ
.EXAMPLE	
	New-CPG -cpgName asCpg1 -sdLD_name XYZ
.EXAMPLE	
	New-CPG -cpgName asCpg1 -RAIDType r1	
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
{   Test-A9CLIConnection
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
	$Result1 = Invoke-CLICommand -cmds  $CreateCPGCmd	
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
    Remove-CPG -cpgName "MyCPG"  -force
	
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
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$force,
		[Parameter(Mandatory=$true)]	[String]	$cpgName,
		[Parameter()]	[String]	$sdLDname,
		[Parameter()]	[String]	$saLDname,
		[Parameter()]	[switch]	$Pat
	)
Begin	
{   Test-A9CLIConnection
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
			if ( -not ( Test-CLIObject -objectType $objType -objectName $cpgName -objectMsg $objMsg )) 
				{	write-verbose " CPG $cpgName does not exist. Nothing to remove"   
					return "FAILURE: No cpg $cpgName found"
				}
			else
				{	if($force)		{	$RemoveCPGCmd +=" -f "	}
					if($Pat)	{	$RemoveCPGCmd +=" -pat "}
					if ($saLDname)	{	$RemoveCPGCmd +=" -sa $saLDname "}
					if ($sdLDname)	{	$RemoveCPGCmd +=" -sd $sdLDname "	}
					$RemoveCPGCmd += " $cpgName "
					$Result3 = Invoke-CLICommand -cmds  $RemoveCPGCmd
					write-verbose "Removing CPG  with the command --> $RemoveCPGCmd" 
					if (Test-CLIObject -objectType $objType -objectName $cpgName -objectMsg $objMsg)
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

Function Set-A9CPG_CLI
{
<#
.SYNOPSIS
	Set-CPG - Update a Common Provisioning Group (CPG)
.DESCRIPTION
	The Set-CPG command modifies existing Common Provisioning Groups (CPG).
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
{   Test-A9CLIConnection
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
	$Result = Invoke-CLICommand -cmds  $Cmd
	if ([string]::IsNullOrEmpty($Result))	{    Get-CPG -Detailed -cpgName $CPG_name }
	else	{ 	Return $Result	}
}
}

Function Compress-A9CPG_CLI
{
<#
.SYNOPSIS
	Compress-CPG - Consolidate space in common provisioning groups.
.DESCRIPTION
	The Compress-CPG command consolidates logical disk space in Common Provisioning Groups (CPGs) into as few logical disks as possible, allowing
	unused logical disks to be removed and their space reclaimed.
.EXAMPLE
	Compress-CPG -CPG_name xxx 
.EXAMPLE
	Compress-CPG -CPG_name tstCPG
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
{   Test-A9CLIConnection
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
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}
