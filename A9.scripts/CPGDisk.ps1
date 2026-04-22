## 	©2025 Hewlett Packard Enterprise Development LP

Function Remove-A9CPG
{
<#
.SYNOPSIS
    Removes a Common Provisioning Group(CPG)
.DESCRIPTION
	Removes a Common Provisioning Group(CPG)
.PARAMETER cpgName 
    Specify name of the CPG. This is a required Parameter for both a SSH and API connection. If this i the only parameter, it will be attempted via API first
.EXAMPLE
    Remove-A9CPG -cpgName "MyCPG" 
	
	Removes a Common Provisioning Group(CPG) "MyCPG"
.NOTES
	This command requires an API type connection.
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	[Parameter(Mandatory,ParameterSetName='API')]	[String]	$cpgName
	)
Begin 
    {	Test-A9Connection -CLientType 'API'
    }
Process
{	$uri = '/cpgs/'+$CPGName
    write-verbose "Executing the following API DELETE command `n $url" 
    $Result = Invoke-A9API -uri $uri -type 'DELETE'
    if ( $Result.StatusCode -eq 200 )
        {	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
            return 		
        }
    else
        {	write-error "FAILURE : While Removing CPG:$CPGName " 
            return $Result.StatusDescription
        }   
}
}

Function Get-A9CPG
{
<#
.SYNOPSIS
    Get list of common provisioning groups (CPGs) in the system.
.DESCRIPTION
    Get list of common provisioning groups (CPGs) in the system.
.PARAMETER cpgName 
    Specify name of the cpg to be listed. If this is the only parameter used, the command will use a API type connection.
.PARAMETER Alert
	Indicates whether alerts are posted. The following columns are shown: Id Name Warn% UsrTotal DataWarn DataLimit DataAlertW% DataAlertW DataAlertL DataAlertF
.PARAMETER SAG
	Specifies that the snapshot admin space auto-growth parameters are displayed. The following columns are displayed:
	Id Name AdmWarn AdmLimit AdmGrow AdmArgs
.PARAMETER SDG
	Specifies that the snapshot data space auto-growth parameters are displayed. The following columns are displayed:
	Id Name DataWarn DataLimit DataGrow DataArgs
.PARAMETER DomainName
	Shows only CPGs that are in domains with names matching one or more of the <domain_name_or_pattern> argument. This option does not allow
	listing objects within a domain of which the user is not a member. Patterns are glob-style (shell-style) patterns (see help on sub,globpat).
.PARAMETER ShowRaw
    This will show the raw output of the SSH connection instead of a PowerShell object, only valid when using a SSH type connection
.PARAMETER UseSSH
    This will force the command to use the SSH type connection instead of an API type connection.
.EXAMPLE
    PS:> get-A9CPG -cpgName SSD_r6 -sdg

    Time               Warn Grow  Dev_Type SetSz  Limit  Avail
    ----               ---- ----  -------- -----  -----  -----
    Feb 20 03:37:02    -    19950 SSD      6      -      cage
    Feb 19 03:37:03    -    19950 SSD      6      -      cage
    Feb 18 03:37:03    -    19950 SSD      6      -      cage
    Feb 17 03:37:03    -    19950 SSD      6      -      cage
    Feb 16 03:37:03    -    19950 SSD      6      -      cage
.EXAMPLE
	PS:> get-A9CPG -cpgName SSD_r6 -sag

    Time           Warn Grow  Dev_Type Limit  Avail
    ----           ---- ----  -------- -----  -----
    Feb 20 03:37:… -    4096  SSD      -      cage
    Feb 19 03:37:… -    4096  SSD      -      cage
    Feb 18 03:37:… -    4096  SSD      -      cage
    Feb 17 03:37:… -    4096  SSD      -      cage
    Feb 16 03:37:… -    4096  SSD      -      cage
.EXAMPLE
	PS:> Get-A9CPG 

    Executed successfully

    id                : 0
    uuid              : 6e09d45c-dca8-4b92-a22e-59ce83a1d933
    name              : SSD_r6
    shortName         : SSD_r6
    numFPVVs          : 16
    numTPVVs          : 0
    numTDVVs          : 12
    UsrUsage          : @{totalMiB=14597100; rawTotalMiB=17516520; usedMiB=14597100; rawUsedMiB=17516520}
    SAUsage           : @{totalMiB=344064; rawTotalMiB=1032192; usedMiB=129024; rawUsedMiB=387072}
    SDUsage           : @{totalMiB=4895100; rawTotalMiB=5874120; usedMiB=0; rawUsedMiB=0}
    privateSpaceMiB   : @{base=13459950; rawBase=17245620; snapshot=0; rawSnapshot=0}
    sharedSpaceMiB    : 1137150
    rawSharedSpaceMiB : 270900
    freeSpaceMiB      : 4895100
    rawFreeSpaceMiB   : 5874120
    totalSpaceMiB     : 19492200
    rawTotalSpaceMiB  : 23390640
    SAGrowth          : @{incrementMiB=4096; LDLayout=}
    SDGrowth          : @{incrementMiB=19950; LDLayout=}
    state             : 1
    failedStates      : {}
    degradedStates    : {}
    additionalStates  : {}
    dedupCapable      : True
    tdvvVersion       : 1
    ddsRsvdMiB        : 67108864
.EXAMPLE
	PS:> get-A9CPG -cpgName SSD_r6 -useSSH

    Time               TDVVs  TPVVs  VVs    Free         Used         Warn%  Total
    ----               -----  -----  ---    ----         ----         -----  -----
    Feb 20 11:09:40    275    336    627    27717375     52032750     -      79750125
    Feb 20 03:37:02    271    335    622    27754125     51955050     -      79709175
    Feb 19 03:37:03    271    325    612    28530600     49991025     -      78521625
    Feb 18 03:37:03    262    312    590    31862775     46065075     -      77927850

.NOTES
	This command requires a SSH or API type connection. If no parameters are used or only CPGName it will attempt to use API, otherwise it will use SSH, and will always failback to SSH.
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	
        [Parameter(Mandatory, ParameterSetName='SSHAlert')]	[switch]	$Alert,
		
        [Parameter(Mandatory, ParameterSetName='SSHSAG')]	[switch]	$SAG,
		
        [Parameter(Mandatory, ParameterSetName='SSHSDG')]	[switch]	$SDG,

        [Parameter(ParameterSetName='SSHu')]
        [Parameter(ParameterSetName='SSHSAG')]
        [Parameter(ParameterSetName='SSHSDG')]
        [Parameter(ParameterSetName='SSHAlert')]
                    	                                    [String]	$DomainName,
		
        [Parameter(ParameterSetName='API')]
        [Parameter(ParameterSetName='SSHu')]
        [Parameter(ParameterSetName='SSHSAG')]
        [Parameter(ParameterSetName='SSHSDG')]
                    	                                    [String]	$cpgName,

        [Parameter(ParameterSetName='SSHSAG')]
        [Parameter(ParameterSetName='SSHSDG')]
        [Parameter(ParameterSetName='SSHAlert')]
		[Parameter(parametersetname='SSHu')]	             [Switch]	$ShowRaw,

        [Parameter(parametersetname='SSHu')]                 [Switch]    $useSSH

	)		
Begin 
    {	if ($PSCmdlet.ParameterSetName -ne 'API' -and -not (Test-A9COnnection -ClientType 'SshClient' -returnBoolean ) )
            {	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                return
            }
    }
Process
{	switch -wildcard ($PsCmdlet.ParameterSetName)
    {   'API'   {   $uri = '/cpgs'
                    if($CPGName)                {	$uri = $uri + '/'+$CPGName    }        
                    $Result = Invoke-A9API -uri $uri -type 'GET' 
                    $dataPS = $Result.content
                    if ( $DataPs.members )      {   $DataPS = $DataPS.members    }
                    if ( $Result.StatusCode -ne 200 )
                        {	write-error "FAILURE : While Executing Get-A9Cpg CPG:$CPGName "
                            return $Result.StatusDescription
                        }
                    write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                    return $dataPS
                }
        "SSH*"   {	$GetCPGCmd = "showcpg "
                    if ( $Alert)		{	$GetCPGCmd += "-alert -hist "
                                            $IndexHeader=3; $StartIndex=4; $EndIndex=6; $history=$true
                                		}
                    if ( $SAG )			{	$GetCPGCmd += "-sag -hist "
                                            $IndexHeader=2; $StartIndex=3; $EndIndex=5; $history=$true
                                		}
                    if ( $SDG )			{	$GetCPGCmd += "-sdg -hist"
                                            $IndexHeader=2; $StartIndex=3; $EndIndex=4; $history=$true
                                		}
                    if ( $DomainName )	{	$GetCPGCmd += "-domain $DomainName "
                                    	}
                    if ( $cpgName )		{	if (-not $Alert -and -not $SAG -and -not $SDG )
                                                {   $GetCPGCmd +=" -hist "
                                                }
                                            $GetCPGCmd += " $cpgName "
                                            $IndexHeader=2; $StartIndex=3; $EndIndex=4; $history=$true
                                    	}	
                    write-verbose "Executing the following SSH command `n $cmd" 
                    $Result = Invoke-A9CLICommand -cmds  $GetCPGCmd	
                    if ( -not ($Result.count -gt 1 ))
                        {	write-warning "The Command failed to return valid data.."
                        }
                    if ($ShowRaw ) 
                        {   return $Result
                        }
                    $tempFile = [IO.Path]::GetTempFileName()	
                     if(  $SDG -or $sag -or $alert -or $PsCmdlet.ParameterSetName -eq 'SSHu')
                        {	$head = ($Result[$IndexHeader].split(' ')).trim(' ') 
                            $head = ($head | where-object {$_ -ne '' } ) -join ','
                            Add-Content -Path $tempFile -Value $head
                            foreach( $Line in $Result[$startIndex..($Result.count - $endIndex )] )
                                {	$line = ($Line.split(' ')).trim(' ')
                                    if ( $History )
                                        {   $line[0] = $line[0]+' '+$line[1]+' '+$line[2]
                                            $line[1] = '' ; $line[2] = '' 
                                        }
                                    $line = ($line | where-object {$_ -ne ''} ) -join ','
                                    Add-Content -Path $tempFile -Value $line
                                }
                            $DataPS = Import-Csv $tempFile 
                        }
                    if ( $SDG )     { $TypeVal = 'CPGSnapDataSpace'}
                    if ( $SAG )     { $TypeVal = 'CPGSnapAdminSpace'}
                    if ( $Alert )   { $TypeVal = 'CPGAlert'}   
                    if ( $PsCmdlet.ParameterSetName -eq 'SSHu' )   { $TypeVal = 'CPGSSH'}                  
                    $NewObj = @(    foreach( $Item in $DataPS)	
                                        {   $NewItem=@{PSTypeName = "HPE.A9Storage.$TypeVal"}
											$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
											$DataSetType = "HPE.A9Storage.$TypeVal"
											$NewItem.PSTypeNames.Insert(0,$DataSetType)
											$DataSetType = $DataSetType + ".TypeName"
											$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
											[PSCustomObject]$NewItem
										}
								)
                    if ( $SAG)      {   $Result2 = $NewObj | Where-object { $_.Grow -ne 'UNKNOWN'  } }
                    if ( $SDG)      {   $Result2 = $NewObj | Where-object { $_.Grow -ne 'unknown'  } }
                    if ( $Alert)    {   $Result2 = $NewObj | Where-object { $_.Total -ne "0"       } }
                    if ( $PsCmdlet.ParameterSetName -eq 'SSHu' ) 
                                    {   $Result2 = $NewObj | Where-object { $_.Total -ne "0"       } }
                    Remove-Item  $tempFile
                    write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                    return $Result2
                }
        }
    }   
}    

Function New-A9Cpg 
{
<#
.SYNOPSIS
	The New-A9Cpg command creates a Common Provisioning Group (CPG).
.DESCRIPTION
	The New-A9Cpg command creates a Common Provisioning Group (CPG).
.PARAMETER CPGName
	Specifies the name of the CPG.  
.PARAMETER Domain
	Specifies the name of the domain in which the object will reside.  
.PARAMETER GrowthIncrementMiB
	Specifies the growth increment, in MiB, the amount of logical disk storage created on each auto-grow operation.  
.PARAMETER GrowthLimitMiB
	Specifies that the autogrow operation is limited to the specified storage amount, in MiB, that sets the growth limit.
.PARAMETER UsedLDWarningAlertMiB
	Specifies that the threshold of used logical disk space, in MiB, when exceeded results in a warning alert.
.PARAMETER RAIDType
	RAID type for the logical disk
	R0 RAID level 0
	R1 RAID level 1
	R5 RAID level 5
	R6 RAID level 6
.PARAMETER SetSize
	Specifies the set size in the number of chunklets.
.PARAMETER HA
	Specifies that the layout must support the failure of one port pair, one cage, or one magazine.
	PORT Support failure of a port.
	CAGE Support failure of a drive cage.
	MAG Support failure of a drive magazine.
.PARAMETER Chunklets
	FIRST Lowest numbered available chunklets, where transfer rate is the fastest.
	LAST  Highest numbered available chunklets, where transfer rate is the slowest.
.PARAMETER NodeList
	Specifies one or more nodes. Nodes are identified by one or more integers. Multiple nodes are separated with a single comma (1,2,3). 
	A range of nodes is separated with a hyphen (0–7). The primary path of the disks must be on the specified node number.
.PARAMETER SlotList
	Specifies one or more PCI slots. Slots are identified by one or more integers. Multiple slots are separated with a single comma (1,2,3). 
	A range of slots is separated with a hyphen (0–7). The primary path of the disks must be on the specified PCI slot number(s).
.PARAMETER PortList
	Specifies one or more ports. Ports are identified by one or more integers. Multiple ports are separated with a single comma (1,2,3). 
	A range of ports is separated with a hyphen (0–4). The primary path of the disks must be on the specified port number(s).
.PARAMETER CageList
	Specifies one or more drive cages. Drive cages are identified by one or more integers. Multiple drive cages are separated with a single comma (1,2,3). 
	A range of drive cages is separated with a hyphen (0– 3). The specified drive cage(s) must contain disks.
.PARAMETER MagList 
	Specifies one or more drive magazines. Drive magazines are identified by one or more integers. Multiple drive magazines are separated with a single comma (1,2,3). 
	A range of drive magazines is separated with a hyphen (0–7). The specified magazine(s) must contain disks.  
.PARAMETER DiskPosList
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers. Multiple disk positions are separated with a single comma (1,2,3). 
	A range of disk positions is separated with a hyphen (0–3). The specified portion(s) must contain disks.
.PARAMETER DiskList
	Specifies one or more physical disks. Disks are identified by one or more integers. Multiple disks are separated with a single comma (1,2,3). 
	A range of disks is separated with a hyphen (0–3). Disks must match the specified ID(s). 
.PARAMETER TotalChunkletsGreaterThan
	Specifies that physical disks with total chunklets greater than the number specified be selected.  
.PARAMETER TotalChunkletsLessThan
	Specifies that physical disks with total chunklets less than the number specified be selected. 
.PARAMETER FreeChunkletsGreaterThan
	Specifies that physical disks with free chunklets less than the number specified be selected.  
.PARAMETER FreeChunkletsLessThan
	Specifies that physical disks with free chunklets greater than the number specified be selected. 
.PARAMETER DiskType
	Specifies that physical disks must have the specified device type, which can only be FC (Fibre Channel), NL (NearLine), or SSD (SSD).
.PARAMETER Rpm
	Disks must be of the specified speed.
.PARAMETER AdministrativeSnapShotWarningPercent
	Specifies the percentage of used snapshot administration or snapshot data space that results in a warning alert. A percent value of 0
	disables the warning alert generation. The default is 0. This option is deprecated and will be removed in a subsequent release.
.PARAMETER GrowthIncrementMiB
	Specifies the growth increment, the amount of logical disk storage created on each auto-grow operation. The default growth increment may
	vary according to the number of controller nodes in the system. If <size> is non-zero it must be 8G or bigger. The size can be specified in MB (default)
	or GB (using g or G) or TB (using t or T). A size of 0 disables the auto-grow feature. The following table displays the default and minimum growth
	increments per number of nodes:
					Number of Nodes       Default     Minimum
						1-2               32G          8G
						3-4               64G         16G
						5-6               96G         24G
						7-8              128G         32G
.PARAMETER GrowthLimitMiB
	Specifies that the auto-grow operation is limited to the specified	storage amount. The storage amount can be specified in MB (default) or
	GB (using g or G) or TB (using t or T). A size of 0 (default) means no limit is enforced.  To disable auto-grow, set the limit to 1.
.PARAMETER UsedLDWarningAlertMiB
	Specifies that the threshold of used logical disk space, when exceeded,	results in a warning alert. The size can be specified in MB (default) or
	GB (using g or G) or TB (using t or T). A size of 0 (default) means no warning limit is enforced. To set the warning for any used space, set the limit to 1.
.PARAMETER RowSet
	Specifies the number of sets in a row. The <size> is a positive integer. If not specified, no row limit is imposed.
.PARAMETER StepSize
	Specifies the step size from 32 KB to 512 KB. The step size should be a power of 2 and a multiple of 32. The default value depends on raid type and
	device type used. If no value is entered and FC or NL drives are used, the step size defaults to 256 KB for RAID-0 and RAID-1, and 128 KB for RAID-5.
	If SSD drives are used, the step size defaults to 32 KB for RAID-0 and RAID-1, and 64 KB for RAID-5. For RAID-6, the default is a function of the set size.
.EXAMPLE
    New-A9CPG_CLI -cpgName "MyCPG" -RAIDType R6

	Creates a CPG named MyCPG with initial size of 32GB and Raid configuration is R6 (RAID 6)
.EXAMPLE 
	PS:> New-A9CPG -cpgName asCpg
.EXAMPLE	
	PS:> New-A9Cpg -CPGName "MyCPG" -Domain Chef_Test
.NOTES
	This command requires a API type connection.
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory,ParameterSetName='API')]   [String]	$CPGName,
	[Parameter(ParameterSetName='API')]             [String]	$Domain,
    [Parameter(ParameterSetName='API')]		        [Int]		$GrowthIncrementMiB,
    [Parameter(ParameterSetName='API')]	    	    [int]		$GrowthLimitMiB,
    [Parameter(ParameterSetName='API')] 	    	[int]		$UsedLDWarningAlertMiB,
    [Parameter(ParameterSetName='API')]
        [ValidateSet('R0','R1','R5','R6')]      	[string]	$RAIDType, 
    [Parameter(ParameterSetName='API')]
        [ValidateSet('mag','cage','port')]          [string]	$HA,
    [Parameter(ParameterSetName='API')]
        [ValidateSet('first','last')]               [string]	$Chunklets,
    [Parameter(ParameterSetName='API')]
            [ValidateSet('FC','NL','SSD')]	        [string]	$DiskType,
    [Parameter(ParameterSetName='API')]             [int]		$Rpm,
    [Parameter(ParameterSetName='API')]		        [String]	$NodeList,
    [Parameter(ParameterSetName='API')]		        [String]	$SlotList,
	[Parameter(ParameterSetName='API')]   	        [String]	$PortList,
	[Parameter(ParameterSetName='API')]    	        [String]	$CageList,
	[Parameter(ParameterSetName='API')]    	        [String]	$MagList,
	[Parameter(ParameterSetName='API')]    	        [String]	$DiskPosList,
	[Parameter(ParameterSetName='API')]    	        [String] 	$DiskList,
	[Parameter(ParameterSetName='API')]    	        [int]		$TotalChunkletsGreaterThan,
	[Parameter(ParameterSetName='API')]    	        [int]		$TotalChunkletsLessThan,
	[Parameter(ParameterSetName='API')]		        [int]		$FreeChunkletsGreaterThan,
	[Parameter(ParameterSetName='API')]         	[int]		$FreeChunkletsLessThan
)
Begin 
    {	Test-A9Connection -CLientType 'API' 
    }
Process
{	$body = @{}	
    $body["name"] = "$($CPGName)"
    If ( $Domain ) 			        {	$body["domain"]             = "$($Domain)"	        }
    If ( $Template )			    {	$body["template"]           = "$($Template)"	    } 
    If ( $GrowthIncrementMiB )      {	$body["growthIncrementMiB"] = $GrowthIncrementMiB	} 
    If ( $GrowthLimitMiB )          {	$body["growthLimitMiB"]     = $GrowthLimitMiB       } 
    If ( $UsedLDWarningAlertMiB )   {$body["usedLDWarningAlertMiB"]  = $UsedLDWarningAlertMiB} 
    $LDLayoutBody = @{}
        if ($RAIDType)      {	if ( $RAIDType -eq "R0" )		{	$LDLayoutBody["RAIDType"] = 1	}
                                elseif ( $RAIDType -eq "R1" )	{	$LDLayoutBody["RAIDType"] = 2	}
                                elseif ( $RAIDType -eq "R5" )	{	$LDLayoutBody["RAIDType"] = 3	}
                                else						    {	$LDLayoutBody["RAIDType"] = 4	}
                                if ( ( ( $PersistArrayType -eq 'AlletraMP-B10000' ) -or ( $PersistArrayType -eq 'Alletra9000' ) )  -and ( $RaidType -ne 'R6' ) )
                                    {   Write-Warning "The Given Controller type only Supports RAID6. Command Aborted!"
                                        Return
                                    }
                            }
    if ( $SetSize )		    {	$LDLayoutBody["setSize"] = $SetSize			}
    if ( $HA )              {	if ( $HA -eq "port" )		    {	$LDLayoutBody["HA"] = 1			}
                                elseif ( $HA -eq "cage" )	    {	$LDLayoutBody["HA"] = 2			}
                                else					    	{	$LDLayoutBody["HA"] = 3			}
                            }
    if ( $Chunklets )         {	if ( $Chunklets -eq "first" )	{	$LDLayoutBody["chunkletPosPref"] = 1	}
                                else 						    {	$LDLayoutBody["chunkletPosPref"] = 2	}
                            }
    $LDLayoutDiskPatternsBody=@()	
    if ( $NodeList )        {	$nodList=@{}
                                $nodList["nodeList"] = "$($NodeList)"	
                                $LDLayoutDiskPatternsBody += $nodList 			
                            }
    if ( $SlotList )        {	$sList=@{}
                                $sList["slotList"] = "$($SlotList)"	
                                $LDLayoutDiskPatternsBody += $sList 		
                            }
    if ( $PortList )        {	$pList=@{}
                                $pList["portList"] = "$($PortList)"	
                                $LDLayoutDiskPatternsBody += $pList 		
                            }	
    if ( $CageList )        {   $cagList=@{}
                                $cagList["cageList"] = "$($CageList)"	
                                $LDLayoutDiskPatternsBody += $cagList 		
                            }
    if ( $MagList )         {	$mList=@{}
                                $mList["magList"] = "$($MagList)"	
                                $LDLayoutDiskPatternsBody += $mList 		
                            }
    if ( $DiskPosList )     {	$dpList=@{}
                                $dpList["diskPosList"] = "$($DiskPosList)"	
                                $LDLayoutDiskPatternsBody += $dpList 		
                            }
    if ( $DiskList )        {	$dskList=@{}
                                $dskList["diskList"] = "$($DiskList)"	
                                $LDLayoutDiskPatternsBody += $dskList 		
                            }
    if ( $TotalChunkletsGreaterThan )
                            {	$tcgList=@{}
                                $tcgList["totalChunkletsGreaterThan"] = $TotalChunkletsGreaterThan	
                                $LDLayoutDiskPatternsBody += $tcgList 		
                            }	
    if ( $TotalChunkletsLessThan )
                            {	$tclList=@{}
                                $tclList["totalChunkletsLessThan"] = $TotalChunkletsLessThan	
                                $LDLayoutDiskPatternsBody += $tclList 		
                            }
    if ( $FreeChunkletsGreaterThan )
                            {	$fcgList=@{}
                                $fcgList["freeChunkletsGreaterThan"] = $FreeChunkletsGreaterThan	
                                $LDLayoutDiskPatternsBody += $fcgList 		
                            }
    if ( $FreeChunkletsLessThan )
                            {	$fclList=@{}
                                $fclList["freeChunkletsLessThan"] = $FreeChunkletsLessThan	
                                $LDLayoutDiskPatternsBody += $fclList 		
                            }
    if ( $DiskType )
                            {	$dtList=@{}
                                if		( $DiskType -eq "FC" )		{	$dtList["diskType"] = 1		}
                                elseif	( $DiskType -eq "NL" )		{	$dtList["diskType"] = 2		}
                                elseif	( $DiskType -eq "SSD" )		{	$dtList["diskType"] = 3		}
                                elseif	( $DiskType -eq "SCM" )		{	$dtList["diskType"] = 4		}
                                elseif	( $DiskType -eq "QLC" )		{	$dtList["diskType"] = 5		}
                                if ( $PersistArrayType -eq 'AlletraMP-B10K' -and $DiskType -lt 3 )
                                        {   Write-Host "The Given Controller type only Supports drive types of SSD, SCM, and QLC. Command Aborted!"
                                            return
                                        }
                                elseif ( $DiskType -gt 3 )
                                        {    Write-Host "The Given Controller type only Supports drive types of FC, NL, and SSD. Command Aborted!"
                                            return
                                        }
                                $LDLayoutDiskPatternsBody += $dtList
                            }	
    if ( $Rpm )
                            {	$rpmList=@{}
                                $rpmList["RPM"] = $Rpm	
                                $LDLayoutDiskPatternsBody += $rpmList
                            }	
    if ( $LDLayoutDiskPatternsBody.Count -gt 0 )	{	$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody		}		
    if ( $LDLayoutBody.Count -gt 0 )				{	$body["LDLayout"] = $LDLayoutBody 	}	
    $Result = Invoke-A9API -uri '/cpgs' -type 'POST' -body $body 
    if ( $Result.StatusCode -ne 201 )  {	write-error "FAILURE : While creating CPG:$CPGName "
                                return $Result.StatusDescription
                            }	
    write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
    return Get-A9Cpg -CPGName $CPGName
}
}

Function Set-A9Cpg 
{
<#
.SYNOPSIS
	The SET-A9Cpg command Update a Common Provisioning Group (CPG).
.DESCRIPTION
	The sET-A9Cpg command Update a Common Provisioning Group (CPG).
	This operation requires access to all domains, as well as Super, Service, or Edit roles, or any role granted cpg_set permission.
.PARAMETER CPGName,
	pecifies the name of Existing CPG.  
.PARAMETER NewName,
	Specifies the name of CPG to Update.
.PARAMETER RmGrowthLimit
	Enables (false) or disables (true) auto grow limit enforcement. Defaults to false.  
.PARAMETER DisableAutoGrow
	Enables (false) or disables (true) CPG auto grow. Defaults to false..
.PARAMETER RmWarningAlert
	Enables (false) or disables (true) warning limit enforcement. Defaults to false..
.PARAMETER RAIDType
	RAID type for the logical disk
	R0 RAID level 0
	R1 RAID level 1
	R5 RAID level 5
	R6 RAID level 6
.PARAMETER SetSize
	Specifies the set size in the number of chunklets.
.PARAMETER HA
	Specifies that the layout must support the failure of one port pair, one cage, or one magazine.
	PORT Support failure of a port.
	CAGE Support failure of a drive cage.
	MAG Support failure of a drive magazine.
.PARAMETER Chunklets
	FIRST Lowest numbered available chunklets, where transfer rate is the fastest.
	LAST  Highest numbered available chunklets, where transfer rate is the slowest.
.PARAMETER NodeList
	Specifies one or more nodes. Nodes are identified by one or more integers. Multiple nodes are separated with a single comma (1,2,3). 
	A range of nodes is separated with a hyphen (0–7). The primary path of the disks must be on the specified node number.
.PARAMETER SlotList
	Specifies one or more PCI slots. Slots are identified by one or more integers. Multiple slots are separated with a single comma (1,2,3). 
	A range of slots is separated with a hyphen (0–7). The primary path of the disks must be on the specified PCI slot number(s).
.PARAMETER PortList
	Specifies one or more ports. Ports are identified by one or more integers. Multiple ports are separated with a single comma (1,2,3). 
	A range of ports is separated with a hyphen (0–4). The primary path of the disks must be on the specified port number(s).
.PARAMETER CageList
	Specifies one or more drive cages. Drive cages are identified by one or more integers. Multiple drive cages are separated with a single comma (1,2,3). 
	A range of drive cages is separated with a hyphen (0– 3). The specified drive cage(s) must contain disks.
.PARAMETER MagList 
	Specifies one or more drive magazines. Drive magazines are identified by one or more integers. Multiple drive magazines are separated with a single comma (1,2,3). 
	A range of drive magazines is separated with a hyphen (0–7). The specified magazine(s) must contain disks.  
.PARAMETER DiskPosList
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers. Multiple disk positions are separated with a single comma (1,2,3). 
	A range of disk positions is separated with a hyphen (0–3). The specified portion(s) must contain disks.
.PARAMETER DiskList
	Specifies one or more physical disks. Disks are identified by one or more integers. Multiple disks are separated with a single comma (1,2,3). 
	A range of disks is separated with a hyphen (0–3). Disks must match the specified ID(s). 
.PARAMETER TotalChunkletsGreaterThan
	Specifies that physical disks with total chunklets greater than the number specified be selected.  
.PARAMETER TotalChunkletsLessThan
	Specifies that physical disks with total chunklets less than the number specified be selected. 
.PARAMETER FreeChunkletsGreaterThan
	Specifies that physical disks with free chunklets less than the number specified be selected.  
.PARAMETER FreeChunkletsLessThan
	Specifies that physical disks with free chunklets greater than the number specified be selected. 
.PARAMETER DiskType
	Specifies that physical disks must have the specified device type.
	FC Fibre Channel
	NL Near Line
	SSD SSD
.PARAMETER GrowthIncrement
	Specifies the growth increment, the amount of logical disk storage created on each auto-grow operation. The default growth increment may
	vary according to the number of controller nodes in the system. If <size> is non-zero it must be 8G or bigger. The size can be specified in MB (default)
	or GB (using g or G) or TB (using t or T). A size of 0 disables the auto-grow feature. The following table displays the default and minimum growth
	increments per number of nodes:
		Number of Nodes       Default     Minimum	
		1-2               32G          8G
		3-4               64G         16G
		5-6               96G         24G
		7-8              128G         32G
.PARAMETER GrowthLimit
	Specifies that the auto-grow operation is limited to the specified storage amount. The storage amount can be specified in MB (default) or
	GB (using g or G) or TB (using t or T). A size of 0 (default) means no limit is enforced.  To disable auto-grow, set the limit to 1.
.PARAMETER WarningAlert
	Specifies that the threshold of used logical disk space, when exceeded, results in a warning alert. The size can be specified in MB (default) or
	GB (using g or G) or TB (using t or T). A size of 0 (default) means no warning limit is enforced. To set the warning for any used space, set the limit to 1.
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
.PARAMETER Compress
    The command consolidates logical disk space in Common Provisioning Groups (CPGs) into as few logical disks as possible, allowing
	unused logical disks to be removed and their space reclaimed.
.PARAMETER Trimonly
	Removes unused logical disks after consolidating the space. This option will not perform any region moves.
.PARAMETER Nomatch
	Removes only unused logical disks whose characteristics do not match the growth characteristics of the CPG. Must be used with the -trimonly
	option. If all logical disks match the CPG growth characteristics, this option has no effect.
.EXAMPLE   
	PS:> Set-A9Cpg -CPGName ascpg -NewName as_cpg
.EXAMPLE 	
	PS:> Set-A9Cpg  -CPGName xxx -DisableAutoGrow $true
.EXAMPLE 	
	PS:> Set-A9Cpg  -CPGName xxx -RmGrowthLimit $true
.EXAMPLE 	
	PS:> Set-A9Cpg  -CPGName xxx -RmWarningAlert $true
.EXAMPLE 
	PS:> Set-A9Cpg  -CPGName xxx -SetSize 10
.EXAMPLE 	
	PS:> Set-A9Cpg  -CPGName xxx -HA PORT
.EXAMPLE 	
	PS:> Set-A9Cpg  -CPGName xxx -Chunklets FIRST
.EXAMPLE 	
	PS:> Set-A9Cpg  -CPGName xxx -NodeList 0
.NOTES
    More options are available via the CLI for other platforms, only options for the CLI that are compabile with the Alletra MP B10K are shown to reduce complexity

#>
[CmdletBinding()]
Param(  [Parameter(Mandatory,ParameterSetName='API')][String]	$CPGname,
        [Parameter(Mandatory,ParameterSetName='API')][String]	$NewName,
        [Parameter(ParameterSetName='API')]		    [int]		$Rpm,	
        [Parameter(ParameterSetName='API')]
            [ValidateSet('CAGE','DISK','PORT')]		[string]	$HA,					
        [Parameter(ParameterSetName='API')]
            [ValidateSet('FIRST','LAST')] 		    [string]	$Chunklets,				
        [Parameter(ParameterSetName='API')]			[Boolean]	$DisableAutoGrow,		
        [Parameter(ParameterSetName='API')]			[Boolean]	$GrowthLimit,			
        [Parameter(ParameterSetName='API')]			[Boolean]	$WarningAlert,
        [Parameter(ParameterSetName='API')]			[int]		$growthIncrement,		
        [Parameter(ParameterSetName='API')]
            [ValidateSet('R0','R1','R5','R6')]		[string]	$RAIDType, 				
        [Parameter(ParameterSetName='API')]    		[int]		$SetSize,
        [Parameter(ParameterSetName='API')]			[String]	$NodeList,				
        [Parameter(ParameterSetName='API')]			[String]	$SlotList,				
        [Parameter(ParameterSetName='API')]			[String]	$PortList,				
        [Parameter(ParameterSetName='API')]			[String]	$CageList,				
        [Parameter(ParameterSetName='API')]			[String]	$MagList,				
        [Parameter(ParameterSetName='API')]			[String]	$DiskPosList,			
        [Parameter(ParameterSetName='API')]			[String]	$DiskList,				
        [Parameter(ParameterSetName='API')]			[int]		$TotalChunkletsGreaterThan,
        [Parameter(ParameterSetName='API')]			[int]		$TotalChunkletsLessThan,
        [Parameter(ParameterSetName='API')]			[int]		$FreeChunkletsGreaterThan,
        [Parameter(ParameterSetName='API')]			[int]		$FreeChunkletsLessThan,
        [Parameter(Mandatory,ParameterSetName='Compress')]
                                                    [switch]    $Compress,
        [Parameter(ParameterSetName='Compress')]	[switch]	$Trimonly,
        [Parameter(ParameterSetName='Compress')]    [switch]	$Nomatch
)
Begin 
    {	Test-A9Connection -CLientType 'API'
    }
Process
{	$body = @{}
    $uri = '/cpgs/'+$CPGName	
    switch ($PSCmdlet.ParameterSetName)
        {   'API'       {   If ($NewName) 							{ $body["newName"] ="$($NewName)" } 
                            If (-not($null -eq $DisableAutoGrow))	{ $body["disableAutoGrow"] =$DisableAutoGrow } 
                            If ( -not($null -eq $GrowthIncrement) ) { $body["growthIncrementMiB"] = $GrowthIncrement } 
                            If ( -not($null -eq $GrowthLimit) ) 	{ $body["growthLimitMiB"] = $GrowthLimit } 
                            If ( -not($null -eq $WarningAlert) )	{ $body["WarningLDWarningAlertMiB"] = $WarningAlert } 
                            $LDLayoutBody = @{}
                            if ( $RAIDType -eq "R0" )   {	$LDLayoutBody["RAIDType"] = 1	}
                            if ( $RAIDType -eq "R1" )	{	$LDLayoutBody["RAIDType"] = 2	}
                            if ( $RAIDType -eq "R5" )	{	$LDLayoutBody["RAIDType"] = 3	}
                            if ( $RAIDType -eq "R6" )	{	$LDLayoutBody["RAIDType"] = 4	}
                            if ( $SetSize )			    {	$LDLayoutBody["setSize"] = $SetSize		}
                            if ( $HA -eq "PORT" )		{	$LDLayoutBody["HA"] = 1	}
                            if ( $HA -eq "CAGE" )		{	$LDLayoutBody["HA"] = 2	}
                            if ( $HA -eq "CAGE" )		{	$LDLayoutBody["HA"] = 4 }
                            if ( $Chunklets -eq "FIRST" )	{	$LDLayoutBody["chunkletPosPref"] = 1	}
                            if ( $Chunklets -eq "LAST" )	{	$LDLayoutBody["chunkletPosPref"] = 2	}
                            $LDLayoutDiskPatternsBody=@()	
                            if ($NodeList)
                                {	$nodList=@{}
                                    $nodList["nodeList"] = "$($NodeList)"	
                                    $LDLayoutDiskPatternsBody += $nodList 			
                                }
                            if ($SlotList)
                                {	$sList=@{}
                                    $sList["slotList"] = "$($SlotList)"	
                                    $LDLayoutDiskPatternsBody += $sList 		
                                }
                            if ($PortList)
                                {	$pList=@{}
                                    $pList["portList"] = "$($PortList)"	
                                    $LDLayoutDiskPatternsBody += $pList 		
                                }	
                            if ($CageList)
                                {	$cagList=@{}
                                    $cagList["cageList"] = "$($CageList)"	
                                    $LDLayoutDiskPatternsBody += $cagList 		
                                }
                            if ($MagList)
                                {	$mList=@{}
                                    $mList["magList"] = "$($MagList)"	
                                                    $LDLayoutDiskPatternsBody += $mList 		
                                }
                            if ($DiskPosList)
                                                {	$dpList=@{}
                                                    $dpList["diskPosList"] = "$($DiskPosList)"	
                                                    $LDLayoutDiskPatternsBody += $dpList 		
                                                }
                            if ($DiskList)
                                                {	$dskList=@{}
                                                    $dskList["diskList"] = "$($DiskList)"	
                                                    $LDLayoutDiskPatternsBody += $dskList 		
                                                }
                            if ($TotalChunkletsGreaterThan)
                                                {	$tcgList=@{}
                                                    $tcgList["totalChunkletsGreaterThan"] = $TotalChunkletsGreaterThan	
                                                    $LDLayoutDiskPatternsBody += $tcgList 		
                                                }
                            if ($TotalChunkletsLessThan)
                                                {	$tclList=@{}
                                                    $tclList["totalChunkletsLessThan"] = $TotalChunkletsLessThan	
                                                    $LDLayoutDiskPatternsBody += $tclList 		
                                                }
                            if ($FreeChunkletsGreaterThan)
                                                {	$fcgList=@{}
                                                    $fcgList["freeChunkletsGreaterThan"] = $FreeChunkletsGreaterThan	
                                                    $LDLayoutDiskPatternsBody += $fcgList 		
                                                }
                            if ($FreeChunkletsLessThan)
                                                {	$fclList=@{}
                                                    $fclList["freeChunkletsLessThan"] = $FreeChunkletsLessThan	
                                                    $LDLayoutDiskPatternsBody += $fclList 		
                                                }	
                            if ($DiskType)
                                                {	$dtList=@{}
                                                    if		($DiskType -eq "FC")		{	$dtList["diskType"] = 1		}
                                                    elseif	($DiskType -eq "NL")		{	$dtList["diskType"] = 2		}
                                                    elseif	($DiskType -eq "SSD")		{	$dtList["diskType"] = 3		}
                                                    $LDLayoutDiskPatternsBody += $dtList
                                                }	
                            if ($Rpm)
                                                {	$rpmList=@{}
                                                    $rpmList["RPM"] = $Rpm	
                                                    $LDLayoutDiskPatternsBody += $rpmList
                                                }	
                            if($LDLayoutDiskPatternsBody.Count -gt 0)	{	$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody	}		
                            if($LDLayoutBody.Count -gt 0)				{	$body["LDLayout"] = $LDLayoutBody }
                            
                        }
            'Compress'  {	$Body['action'] = 1
                            if ( $Trimonly )    {   $Body['trimonly'] = $Trimonly
                                                    if ( $noMatch )     {   $Body['noMatch']=$Nomatch
                                                                        }
                                                }
                        }
        }
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body	
    if ( $Result.StatusCode -ne 200 )
        {	write-error "FAILURE : While Updating CPG:$CPGName " 
            return $Result.StatusDescription
        }
    write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
            if($NewName)    {	return Get-A9Cpg -CPGName $NewName
                            }
            else            {	return Get-A9Cpg -CPGName $CPGName
                            }
}
}

Function Get-A9PhysicalDisk
{
[CmdletBinding(DefaultParameterSetName='API')]
<#
.SYNOPSIS
	Displays configuration information about the physical disks (PDs) on a system. 
.DESCRIPTION
	Displays configuration information about the physical disks (PDs) on a system. 
.PARAMETER ErrorInfo
	Show disk environment and error information. Note that reading this information places a significant load on each disk.
	The following columns are shown:
	Id CagePos Type State Rd_CErr Rd_UErr Wr_CErr Wr_UErr Temp_DegC LifeLeft_PCT.
.PARAMETER Chunklets
	Show chunklet usage information. Any chunklet in a failed disk will be shown as "Fail".

	The following columns are shown:
	Id CagePos Type State Total_Chunk Nrm_Used_OK Nrm_Used_Fail
	Nrm_Unused_Free Nrm_Unused_Uninit Nrm_Unused_Unavail Nrm_Unused_Fail
	Spr_Used_OK Spr_Used_Fail Spr_Unused_Free Spr_Unused_Uninit Spr_Unused_Fail.
.PARAMETER Path
	Show current and saved path information for disks.

	The following columns are shown: Id CagePos Type State Path_A0 Path_A1 Path_B0 Path_B1 Order.
.PARAMETER Space
	Show disk capacity usage information (in MB).

	The following columns are shown: Id CagePos Type State Size_MB Volume_MB Spare_MB Free_MB Unavail_MB Failed_MB.
.EXAMPLE  
	PS:> Get-A9Disk

    Cmdlet executed successfully

    id   position StateDescr manufacturer model            mfgCapa TypeDesc serialNumber     fwVersion  WWN
                iption                                   cityGB  ription
    --   -------- ---------- ------------ -----            ------- -------- ------------     ---------  ---
    1    1:2      Normal     SAMSUNG      AEGL3840P5xnFTRI 3840    MLC      S5UNNC0WA07421   3P03       0025389A315041C7
    2    1:3      Normal     SAMSUNG      AEGL3840P5xnFTRI 3840    MLC      S5UNNC0WA07729   3P03       0025389A315042FB
    3    1:4      Normal     SAMSUNG      AEGL3840P5xnFTRI 3840    MLC      S5UNNC0WA07809   3P03       0025389A3150434B
.EXAMPLE  
	PS:> get-a9disk -PD_ID 1 -Path

    Id               : 1
    CagePos          : 1:2
    Type             : SSD
    State            : normal
    PrimaryPortCount : 2
    Paths            : 0:12:1*
.EXAMPLE  
	PS:> Get-A9Disk -Chunklets -pd_id 1 

    Id                           : 1
    CagePos                      : 1:2
    Type                         : SSD
    State                        : normal
    Total                        : 3575
    OK(NormalChunklets)          : 1707
    Fail(NormalChunklets/Used)   : 0
    Free(NormalChunklets)        : 1818
    Uninit(NormalChunklets)      : 0
    Unavail                      : 0
    Fail(NormalChunklets/UnUsed) : 0
    OK(SpareChunklets)           : 0
    Fail(SpareChunklets/Used)    : 0
    Free(SpareChunklets)         : 50
    Uninit(SpareChunklets)       : 0
    Fail(SpareChunklets/UnUsed)  : 0

    This example displays chunklet use information for a disk, leave off the PD_ID and it will return all drives 
.EXAMPLE  
	PS:> get-a9disk -PD_ID 1 -State

    Id             : 1
    CagePos        : 1:2
    Type           : SSD
    State          : normal
    Detailed_State : normal
    SedState       : fips_capable
.EXAMPLE
	PS:> get-a9disk -PD_ID 1 -ErrorInfo

    Id                 : 1
    CagePos            : 1:2
    Type               : SSD
    State              : normal
    Corr(ReadError)    : N/A
    UnCorr(ReadError)  : N/A
    Corr(WriteError)   : N/A
    UnCorr(WriteError) : N/A
    T(C)               : 36
    LifeLeft%          : 99	
.NOTES
	This command requires a SSH type connection if using any arguments.
    The same data from the API is given as it presented from the option -i (inquery, so -i has been depreciated)
#>
param(	[Parameter(ParameterSetName='sshErrors')]	[switch]	$ErrorInfo,
		[Parameter(ParameterSetName='sshChunk')]	[switch]	$Chunklets,
		[Parameter(ParameterSetName='sshState')]	[switch]	$State,
		[Parameter(ParameterSetName='sshPath')]	    [switch]	$Path,
		[Parameter(ParameterSetName='sshSpace')]	[switch]	$Space,
		[Parameter()]                               [String]	$PD_ID ,
        [Parameter(ParameterSetName='ssh')]	        [switch]	$UseSSH,
        [Parameter(ParameterSetName='ssh')]         [switch]    $ShowRaw
)		
Begin 
    {	if ( ($PSCmdlet.ParameterSetName -eq 'ssh') -or ($PSCmdlet.ParameterSetName -eq 'ssPattern') -and -not (Test-A9COnnection -ClientType 'SshClient' -returnBoolean) )	
            {	write-warning "No SSH connection was Detected and the parameters selected require an SSH connection. Please use the Connect-HPESAN command to reconnect."
                return
            }
    }
Process
{	switch -wildcard ($PSCmdlet.ParameterSetName)
    {   'API'   
                {   $uri = '/disks/'	
                    $Result = Invoke-A9API -uri $uri -type 'GET'		
                    If($Result.StatusCode -eq 200)
                        {	$dataPS = ($Result.content | ConvertFrom-Json).members
                            write-host "Cmdlet executed successfully" -foreground green
                            write-verbose "This is how many objects were returned."
                            $NewObj = @(    foreach( $Item in $DataPS)
                                                    {   $NewItem=@{PSTypeName = "HPE.A9Storage.Disk"}
                                                        $Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
                                                        $StateEnum = $Item.State
                                                            Switch ($StateEnum)
                                                                {   1   {   $StateDesc = 'Normal'   }
                                                                    2   {   $StateDesc = 'Degraded' }
                                                                    3   {   $StateDesc = 'New'      }
                                                                    4   {   $StateDesc = 'Failed'   }
                                                                    99  {   $StateDesc = 'Unknown'  }
                                                                }
                                                            if ($StateDesc) 
                                                                {   $NewItem['StateDescription'] = $StateDesc
                                                                    remove-variable $StateDesc -erroraction SilentlyContinue
                                                                }
                                                        $TypeEnum = $Item.'type'
                                                            Switch ($TypeEnum)
                                                                {   1   {   $TypeDesc = 'Magnetic' }
                                                                    2   {   $TypeDesc = 'SLC'      }
                                                                    3   {   $TypeDesc = 'MLC'      }
                                                                    4   {   $TypeDesc = 'cMLC'     }
                                                                    5   {   $TypeDesc = '3DX'      }
                                                                    6   {   $TypeDesc = 'QLC'      }
                                                                    99  {   $TypeDesc = 'Unknown'  }
                                                                }
                                                            if ($StateDesc) 
                                                                {   $NewItem['StateDescription'] = $StateDesc
                                                                    remove-variable $StateDesc -erroraction SilentlyContinue
                                                                }
                                                            if ($TypeDesc) 
                                                                {   $NewItem['TypeDescription'] = $TypeDesc
                                                                    remove-variable $StateDesc -erroraction SilentlyContinue
                                                                }
                                                            $DataSetType = "HPE.A9Storage.Disk"
                                                            $NewItem.PSTypeNames.Insert(0,$DataSetType)
                                                            $DataSetType = $DataSetType + ".TypeName"
                                                            $NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
                                                        [PSCustomObject]$NewItem
                                                    }
                                        )
                            write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                            return $NewObj
                        }
                    else
                        {	Write-Error "Failure:  While Executing Get-A9Host." 
                            return $Result.StatusDescription
                        }
                }
        "SSH*"  {   $cmd= "showpd "	
                    if ( $ErrorInfo )   {	$cmd+=" -e "	        }
                    if ( $Chunklets )   {	$cmd+=" -c "	        }
                    if ( $State )	    {	$cmd+=" -state "        }
                    if ( $Path )	    {	$cmd+=" -path "	        }
                    if ( $Space )	    {	$cmd+=" -space "        }
                    if ( $PD_ID )       {	$cmd+=" $PD_ID "        }	
                    $Result = Invoke-A9CLICommand -cmds  $cmd
                    if ( $ShowRaw -or $Result -match "Invalid device type" -or $Result.Count -lt 2)
                        {   return $Result          }
                    $tempFile = [IO.Path]::GetTempFileName()
                    if ( $State )
                        {	$flag = "True"
                            $LastItem = $Result.Count -3  
                            foreach ($s in  $Result[0..$LastItem] )
                                {	$s= [regex]::Replace($s,"^ ","")			
                                    $s= [regex]::Replace($s," +",",")	
                                    $s= [regex]::Replace($s,"-","")
                                    $s= $s.Trim()
                                    if($I)
                                        {	if($flag -eq "True")
                                                {	$sTemp1=$s
                                                    $sTemp = $sTemp1.Split(',')
                                                    $sTemp[10]="AdmissionDate,AdmissionTime,AdmissionZone" 				
                                                    $newTemp= [regex]::Replace($sTemp," ",",")	
                                                    $newTemp= $newTemp.Trim()
                                                    $s=$newTemp
                                                }	
                                        }			
                                    Add-Content -Path $tempFile -Value $s
                                    $flag="false"		
                                }				
                        }
                    ElseIf($Chunklets)
                        {	$LastItem = [int]$Result.Count -3  
                            $incre = "true"			
                            foreach ($s in  $Result[2..$LastItem] )
                                {	$s= [regex]::Replace($s,"^ ","")			
                                    $s= [regex]::Replace($s," +",",")
                                    $s= [regex]::Replace($s,"-","")
                                    $s= $s.Trim()				
                                    if($incre -eq "true")
                                        {	$sTemp1=$s
                                            $sTemp = $sTemp1.Split(',')
                                            $sTemp[5]="OK(NormalChunklets)" 
                                            $sTemp[6]="Fail(NormalChunklets/Used)" 
                                            $sTemp[7]="Free(NormalChunklets)"
                                            $sTemp[8]="Uninit(NormalChunklets)"
                                            $sTemp[10]="Fail(NormalChunklets/UnUsed)"
                                            $sTemp[11]="OK(SpareChunklets)" 
                                            $sTemp[12]="Fail(SpareChunklets/Used)" 
                                            $sTemp[13]="Free(SpareChunklets)"
                                            $sTemp[14]="Uninit(SpareChunklets)"
                                            $sTemp[15]="Fail(SpareChunklets/UnUsed)"
                                            $newTemp= [regex]::Replace($sTemp," ",",")	
                                            $newTemp= $newTemp.Trim()
                                            $s=$newTemp
                                        }				
                                    Add-Content -Path $tempFile -Value $s
                                    $incre="false"				
                                }			

                        }
                    ElseIf($ErrorInfo)
                            {	$LastItem = $Result.Count -3  
                                $incre = "true"			
                                foreach ($s in  $Result[1..$LastItem] )
                                    {	$s= [regex]::Replace($s,"^ ","")			
                                        $s= [regex]::Replace($s," +",",")
                                        $s= [regex]::Replace($s,"-","")
                                        $s= $s.Trim()				
                                        if($incre -eq "true")
                                            {	$sTemp1=$s
                                                $sTemp = $sTemp1.Split(',')
                                                $sTemp[4]="Corr(ReadError)" 
                                                $sTemp[5]="UnCorr(ReadError)" 
                                                $sTemp[6]="Corr(WriteError)"
                                                $sTemp[7]="UnCorr(WriteError)"
                                                $newTemp= [regex]::Replace($sTemp," ",",")	
                                                $newTemp= $newTemp.Trim()
                                                $s=$newTemp
                                            }				
                                        Add-Content -Path $tempFile -Value $s
                                        $incre="false"				
                                    }
                            }
                    elseif($Path)
                            {	$LastItem = $Result.Count -3  
                                foreach ($s in  $Result[0..$LastItem] )
                                    {	$s= [regex]::Replace($s,"^ ","")			
                                        $s= [regex]::Replace($s," +",",")
                                        $s= [regex]::Replace($s,"-","")
                                        $s= $s.Trim() 	
                                        Add-Content -Path $tempFile -Value $s
                                    }				
                            }	
                    elseif($Result -match "Id")
                            {	$LastItem = $Result.Count -3  
                                foreach ($s in  $Result[1..$LastItem] )
                                    {	$s= [regex]::Replace($s,"^ ","")			
                                        $s= [regex]::Replace($s," +",",")
                                        $s= [regex]::Replace($s,"-","")
                                        $s= $s.Trim() 	
                                        Add-Content -Path $tempFile -Value $s
                                    }				
                            }
                    else    {    return $Result		   	
                            }
                    $returnvalue = Import-Csv $tempFile 
                    Remove-Item  $tempFile
                    write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                    return $returnvalue
                }
    }
}
}