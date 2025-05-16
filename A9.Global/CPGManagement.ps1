####################################################################################
## 	© 2025 Hewlett Packard Enterprise Development LP
##

Function Remove-A9CPG
{
<#
.SYNOPSIS
    Removes a Common Provisioning Group(CPG)
.DESCRIPTION
	Removes a Common Provisioning Group(CPG)
.PARAMETER saLDname
	Specifies that the logical disk, as identified with the <LD_name> argument, used for snapshot administration space allocation is removed.
	The <LD_name> argument can be repeated to specify multiple logical disks.
	This option is deprecated and will be removed in a subsequent release and only available via SSH connections.
.PARAMETER sdLDname
	Specifies that the logical disk, as identified with the <LD_name> argument, used for snapshot data space allocation is removed. The
	<LD_name> argument can be repeated to specify multiple logical disks. This option is deprecated and will be removed in a subsequent release and only available via SSH connections.
.PARAMETER cpgName 
    Specify name of the CPG. This is a required Parameter for both a SSH and API connection. If this i the only parameter, it will be attempted via API first
.PARAMETER Pattern
    The specified patterns are treated as glob-style patterns and that all common provisioning groups matching the specified pattern are removed and only available via SSH connections.
.EXAMPLE
    Remove-A9CPG -cpgName "MyCPG" 
	
	Removes a Common Provisioning Group(CPG) "MyCPG"
.NOTES
	This command requires a API or SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	[Parameter(Mandatory,ParameterSetName='SSH')]		
        [Parameter(Mandatory,ParameterSetName='API')]	[String]	$cpgName,
		[Parameter(ParameterSetName='SSH')]			    [String]	$sdLDname,
		[Parameter(ParameterSetName='SSH')]			    [String]	$saLDname,
		[Parameter(ParameterSetName='SSH')]			    [string]	$Pattern
	)
Begin 
    {	if ( $PSCmdlet.ParameterSetName -eq 'API' )
            {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                    {	$PSetName = 'API'
                    }
                else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                            {	$PSetName = 'SSH'
                            }
                    }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'ssh' )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process
{	switch ($PSetName)
    {   'API'   {   $uri = '/cpgs/'+$CPGName
                    $Result = $null
                    write-verbose "Executing the following API DELETE command `n $url" 
                    $Result = Invoke-A9API -uri $uri -type 'DELETE'
                    $status = $Result.StatusCode
                    if($status -eq 200)
                        {	write-host "Cmdlet executed successfully" -foreground green
                            return 		
                        }
                    else
                        {	write-error "FAILURE : While Removing CPG:$CPGName " 
                            return $Result.StatusDescription
                        }   
                }
        'SSH'   {   $RemoveCPGCmd = "removecpg -f "	
                    if ($Pattern)	{	$RemoveCPGCmd +=" -pat $Pattern"}
                    if ($saLDname)	{	$RemoveCPGCmd +=" -sa $saLDname "}
                    if ($sdLDname)	{	$RemoveCPGCmd +=" -sd $sdLDname "	}
                    $RemoveCPGCmd += " $cpgName "
                    write-verbose "Executing the following SSH command `n $cmd" 
                    $Result = Invoke-A9CLICommand -cmds  $RemoveCPGCmd
                    return $Result		
                }
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
.PARAMETER ShowRaw
    This will show the raw output of the SSH connection instead of a PowerShell object
.PARAMETER UseSSH
    This will force the command to use the SSH type connection instead of an API type connection.
.EXAMPLE
	PS:> Get-A9CPG -useSSH

	Id    : 0
	Name  : SSD_r6
	Warn% : -
	VVs   : 28
	TPVVs : 0
	TDVVs : 12
	Used  : 318675
	Free  : 12334875
	Total : 13472025
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
	PS:> Get-A9CPG -ShowRaw

					----Volumes---- ----------(MiB)----------
	Id Name   Warn% VVs TPVVs TDVVs    Used     Free    Total
	0 SSD_r6     -  28     0    12 2424450 10229100 12653550	
	---------------------------------------------------------
	1 total                        2424450 10229100 12653550
.EXAMPLE
	PS:> Get-A9CPG -Domain_Name '*'

	Id    : 0
	Name  : SSD_r6
	Warn% : -
	VVs   : 28
	TPVVs : 0
	TDVVs : 12
	Used  : 2328900
	Free  : 10324650
	Total : 12653550
.NOTES
	This command requires a SSH or API type connection. If no parameters are used or only CPGName it will attempt to use API, otherwise it will use SSH, and will always failback to SSH.
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	[Parameter(ParameterSetName='SSH')]	[switch]	$ListCols,
		[Parameter(ParameterSetName='SSH')]	[switch]	$Detailed, 
		[Parameter(ParameterSetName='SSH')]	[switch]	$RawSpace,
		[Parameter(ParameterSetName='SSH')]	[switch]	$Alert,
		[Parameter(ParameterSetName='SSH')]	[switch]	$AlertTime,
		[Parameter(ParameterSetName='SSH')]	[switch]	$SAG,
		[Parameter(ParameterSetName='SSH')]	[switch]	$SDG,
		[Parameter(ParameterSetName='SSH')]	[switch]	$Space,
		[Parameter(ParameterSetName='SSH')]	[switch]	$History,
		[Parameter(ParameterSetName='SSH')]	[String]	$Domain_Name,
		[Parameter(ParameterSetName='API')]	
        [Parameter(ParameterSetName='SSH')]	[String]	$cpgName,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$ShowRaw,
        [Parameter(ParameterSetName='SSH')]	[Switch]	$UseSSH
        
	)		
Begin 
    {	if ( $PSCmdlet.ParameterSetName -eq 'API' )
            {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                    {	$PSetName = 'API'
                    }
                else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                            {	$PSetName = 'SSH'
                            }
                    }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'ssh' )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process
{	switch ($PSetName)
    {   'API'   {   if($CPGName)
                        {	$uri = '/cpgs/'+$CPGName
                            $Result = Invoke-A9API -uri $uri -type 'GET' 
                            if($Result.StatusCode -eq 200)
                                {	$dataPS = $Result.content | ConvertFrom-Json
                                }
                        }
                    else
                        {	$Result = Invoke-A9API -uri '/cpgs' -type 'GET'
                            if($Result.StatusCode -eq 200)
                                {	$dataPS = ($Result.content | ConvertFrom-Json).members
                                }		
                        }
                    if($Result.StatusCode -eq 200)
                        {	write-host "Executed successfully" -foreground green
                            return $dataPS
                        }
                    else
                        {	write-error "FAILURE : While Executing Get-Cpg_WSAPI CPG:$CPGName "
                            return $Result.StatusDescription
                    }
                }
        'SSH'   {	$GetCPGCmd = "showcpg "
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
                    if ($cpgName)		{	$GetCPGCmd += "  $cpgName"	}	
                    write-verbose "Executing the following SSH command `n $cmd" 
                    $Result = Invoke-A9CLICommand -cmds  $GetCPGCmd	
                    if ( -not ($Result.count -gt 1 ))
                        {	write-warning "The Command failed to return valid data.."
                        }
                    $tempFile = [IO.Path]::GetTempFileName()		
                    if( ($PSBoundParameters.count -eq 0) -or $SDG -or $Sag -or $Space -or $Domain_Name )
                        {	$head = ($Result[1].split(' ')).trim(' ') 
                            $head = ($head | where-object {$_ -ne '' } ) -join ','
                            Add-Content -Path $tempFile -Value $head
                            foreach( $Line in $Result[2..($Result.count - 3 )] )
                                {	$line = ($Line.split(' ')).trim(' ')
                                    $line = ($line | where-object {$_ -ne ''} ) -join ','
                                    Add-Content -Path $tempFile -Value $line
                                }
                            $Result = Import-Csv $tempFile 
                        }
                    if( $AlertTime )
                        {	$tempFile = [IO.Path]::GetTempFileName()
                            $head = ($Result[1].split(' ')).trim(' ') 
                            $head = ($head | where-object {$_ -ne '' } ) -join ','
                            Add-Content -Path $tempFile -Value $head
                            foreach( $Line in $Result[2..($Result.count - 1 )] )
                                {	$line = ($Line.split(' ')).trim(' ')
                                    $line = ($line | where-object {$_ -ne ''} ) -join ','
                                    Add-Content -Path $tempFile -Value $line
                                }
                            $Result = Import-Csv $tempFile 
                        }
                    if( $Alert )
                        {	$tempFile = [IO.Path]::GetTempFileName()
                            $head = ($Result[2].split(' ')).trim(' ') 
                            $head = ($head | where-object {$_ -ne '' } ) -join ','
                            Add-Content -Path $tempFile -Value $head
                            foreach( $Line in $Result[3..($Result.count - 1 )] )
                                {	$line = ($Line.split(' ')).trim(' ')
                                    $line = ($line | where-object {$_ -ne ''} ) -join ','
                                    Add-Content -Path $tempFile -Value $line
                                }
                            $Result = Import-Csv $tempFile 
                        }
                    if( ( $Detailed)  )
                        {	$tempFile = [IO.Path]::GetTempFileName()
                            $head = @('Id', 'Name', 'Warn%', 'Volume VVs', 'Volume TPVVs',',Volumes TDVVs','MIB Used', 'MIB Free','MIB Total','LD Usr','LD SD','RCUsage Usr','Shared Version')
                            $head = ($head | where-object {$_ -ne '' } ) -join ','
                            Add-Content -Path $tempFile -Value $head
                            foreach( $Line in $Result[2..($Result.count - 3 )] )
                                {	$line = ($Line.split(' ')).trim(' ')
                                    $line = ($line | where-object {$_ -ne ''} ) -join ','
                                    Add-Content -Path $tempFile -Value $line
                                }
                            $Result = Import-Csv $tempFile 
                        }
                    Remove-Item  $tempFile
                    return $Result
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
.PARAMETER Template
	Specifies the name of the template from which the CPG is created.
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
    New-A9CPG_CLI -cpgName "MyCPG" -Size 32G	-RAIDType r1 
	Creates a CPG named MyCPG with initial size of 32GB and Raid configuration is r1 (RAID 1)
.EXAMPLE 
	PS:> New-A9CPG -cpgName asCpg
.EXAMPLE 
	PS:> New-A9CPG -cpgName asCpg1 -TemplateName temp
.EXAMPLE	
	PS:> New-A9CPG -cpgName asCpg1 -AW 1
.EXAMPLE	
	PS:> New-A9CPG -cpgName asCpg1 -SDGS 1
.EXAMPLE	
	PS:> New-A9CPG -cpgName asCpg1 -SDGL 12241
.EXAMPLE	
	PS:> New-A9CPG -cpgName asCpg1 -saLD_name XYZ
.EXAMPLE	
	PS:> New-A9CPG -cpgName asCpg1 -sdLD_name XYZ
.EXAMPLE	
	PS:> New-A9CPG -cpgName asCpg1 -RAIDType r1	
.EXAMPLE    
	PS:> New-A9Cpg -CPGName XYZ 
.EXAMPLE	
	PS:> New-A9Cpg -CPGName "MyCPG" -Domain Chef_Test
.EXAMPLE	
	PS:> New-A9Cpg -CPGName "MyCPG" -Domain Chef_Test -Template Test_Temp
.EXAMPLE	
	PS:> New-A9Cpg -CPGName "MyCPG" -Domain Chef_Test -Template Test_Temp -GrowthIncrementMiB 100
.EXAMPLE	
	PS:> New-A9Cpg -CPGName "MyCPG" -Domain Chef_Test -RAIDType R0
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(
	[Parameter(Mandatory,ParameterSetName='API')]
	[Parameter(Mandatory,ParameterSetName='SSH')]	[String]	$CPGName,
	[Parameter(ParameterSetName='API')]
	[Parameter(ParameterSetName='SSH')]	            [String]	$Domain,
	[Parameter(ParameterSetName='API')]
	[Parameter(ParameterSetName='SSH')]		        [String]	$Template,
    [Parameter(ParameterSetName='API')]
	[Parameter(ParameterSetName='SSH')]		        [Int]		$GrowthIncrementMiB,
    [Parameter(ParameterSetName='API')]
	[Parameter(ParameterSetName='SSH')]	    	    [int]		$GrowthLimitMiB,
    [Parameter(ParameterSetName='API')]
	[Parameter(ParameterSetName='SSH')] 	    	[int]		$UsedLDWarningAlertMiB,
	[Parameter(ParameterSetName='API')]
    [Parameter(ParameterSetName='SSH')]
        [ValidateSet('R0','R1','R5','R6')]      	[string]	$RAIDType, 
	[Parameter(ParameterSetName='SSH')]    	        [int]		$SetSize,
    [Parameter(ParameterSetName='API')]
    [Parameter(ParameterSetName='SSH')]
        [ValidateSet('mag','cage','port')]          [string]	$HA,
    [Parameter(ParameterSetName='API')]
    [Parameter(ParameterSetName='SSH')]
        [ValidateSet('first','last')]               [string]	$Chunklets,
    [Parameter(ParameterSetName='SSH')]             [String]	$StepSize,
    [Parameter(ParameterSetName='SSH')]	
        [ValidateRange(0,100)]                      [String]	$AdministrativeSnapShotWarningPercent,
    [Parameter(ParameterSetName='API')]
    [Parameter(ParameterSetName='SSH')]
            [ValidateSet('FC','NL','SSD')]	        [string]	$DiskType,
    [Parameter(ParameterSetName='API')]
    [Parameter(ParameterSetName='SSH')]             [int]		$Rpm,
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
	[Parameter(ParameterSetName='API')]         	[int]		$FreeChunkletsLessThan,
    [Parameter(ParameterSetName='SSH')]	            [String]	$RowSet
)
Begin 
    {	if ( $PSCmdlet.ParameterSetName -eq 'API' )
            {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                    {	$PSetName = 'API'
                    }
                else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                            {	$PSetName = 'SSH'
                            }
                    }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'ssh' )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process
{	switch ($PSetName)
    {   'API'   
                {   $body = @{}	
                    $body["name"] = "$($CPGName)"
                    If ($Domain) 			{	$body["domain"] = "$($Domain)"	}
                    If ($Template)			{	$body["template"] = "$($Template)"	} 
                    If ($GrowthIncrementMiB){	$body["growthIncrementMiB"] = $GrowthIncrementMiB	} 
                    If ($GrowthLimitMiB)    {	$body["growthLimitMiB"] = $GrowthLimitMiB    } 
                    If ($UsedLDWarningAlertMiB){$body["usedLDWarningAlertMiB"] = $UsedLDWarningAlertMiB} 
                    $LDLayoutBody = @{}
                    if ($RAIDType)
                        {	if($RAIDType -eq "R0")		{	$LDLayoutBody["RAIDType"] = 1	}
                            elseif($RAIDType -eq "R1")	{	$LDLayoutBody["RAIDType"] = 2	}
                            elseif($RAIDType -eq "R5")	{	$LDLayoutBody["RAIDType"] = 3	}
                            else						{	$LDLayoutBody["RAIDType"] = 4	}
                        }
                    if ($SetSize)			{	$LDLayoutBody["setSize"] = $SetSize			}
                    if ($HA)
                        {	if($HA -eq "port")			{	$LDLayoutBody["HA"] = 1			}
                            elseif($HA -eq "cage")		{	$LDLayoutBody["HA"] = 2			}
                            else						{	$LDLayoutBody["HA"] = 3			}
                        }
                    if ($Chunklets)
                        {	if($Chunklets -eq "first")	{	$LDLayoutBody["chunkletPosPref"] = 1	}
                            else 						{	$LDLayoutBody["chunkletPosPref"] = 2	}
                        }
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
                        {
                            $cagList=@{}
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
                    if($LDLayoutDiskPatternsBody.Count -gt 0)	{	$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody		}		
                    if($LDLayoutBody.Count -gt 0)				{	$body["LDLayout"] = $LDLayoutBody 	}	
                    $Result = $null	
                    $Result = Invoke-A9API -uri '/cpgs' -type 'POST' -body $body 
                    $status = $Result.StatusCode
                    if($status -eq 201)
                    {	write-host "Cmdlet executed successfully" -foreground green
                        return Get-A9Cpg -CPGName $CPGName
                    }
                    else
                    {	write-error "FAILURE : While creating CPG:$CPGName "
                        return $Result.StatusDescription
                    }	
                }
        'SSH'   
                {   $CreateCPGCmd =" createcpg -f" 
                    if($Template)	{	$CreateCPGCmd += " -templ $TemplateName "	}
                    if($AdministrativeSnapShotWarningPercent)				{	$CreateCPGCmd += " -aw $AdministrativeSnapShotWarningPercent "	}
                    if($GrowthIncrementMiB)	{	$CreateCPGCmd += " -sdgs $GrowthIncrementMiB "	}
                    if($GrowthLimitMiB)			{	$CreateCPGCmd += " -sdgl $GrowthLimitMiB "	}
                    if($UsedLDWarningAlertMiB)			{	$CreateCPGCmd += " -sdgw $UsedLDWarningAlertMiB "	}
                    if($Domain)			{	$CreateCPGCmd += " -domain $Domain "}
                    if($RAIDType)		{	$CreateCPGCmd += " -t $RAIDType "	}
                    if($RowSet)			{	$CreateCPGCmd += " -rs $RowSet "		}
                    if($StepSize)		{	$CreateCPGCmd += " -ss $StepSize "		}
                    if($HA)				{	$CreateCPGCmd += " -ha $HA "		}
                    if($Chunklets)		{	$CreateCPGCmd += " -ch $Chunklets "		}
                    if($DiskType)		{	$CreateCPGCmd += " -devtype $DiskType "		}
                    if($RPM)			{	$CreateCPGCmd += " -rpm $RPM "		}
                    $CreateCPGCmd += " $cpgName"
                    write-verbose "Executing the following SSH command `n $cmd" 
                    $Result1 = Invoke-A9CLICommand -cmds  $CreateCPGCmd	
                    return $Result1
                }
    }
}
}

Function Set-A9Cpg 
{
<#
.SYNOPSIS
	The sET-A9Cpg command Update a Common Provisioning Group (CPG).
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
.PARAMETER Rpm
	Disks must be of the specified speed.
.PARAMETER Sa
	Specifies that existing logical disks are added to the CPG and are used for snapshot admin (SA) space allocation. The <LD_name> argument can be
	repeated to specify multiple logical disks. This option is deprecated and will be removed in a subsequent release.
.PARAMETER Sd
	Specifies that existing logical disks are added to the CPG and are used for snapshot data (SD) space allocation. The <LD_name> argument can be
	repeated to specify multiple logical disks. This option is deprecated and will be removed in a subsequent release.
.PARAMETER Aw
	Specifies the percentage of used snapshot administration or snapshot data space that results in a warning alert. A percent value of 0
	disables the warning alert generation. The default is 0. This option is deprecated and will be removed in a subsequent release.
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
.EXAMPLE   
	PS:> Set-A9Cpg -CPGName ascpg -NewName as_cpg
.EXAMPLE 	
	PS:> Set-A9Cpg  -CPGName xxx -RAIDType R1
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
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory, ParameterSetName='API')]
	[Parameter(Mandatory, ParameterSetName='SSH')]	[String]	$CPGName,
	[Parameter(ParameterSetName='SSH')]	
    [Parameter(ParameterSetName='API')]	            [String]	$NewName,
	[Parameter(ParameterSetName='SSH')]	
    [Parameter(ParameterSetName='API')]		        [int]		$Rpm,	
    [Parameter(ParameterSetName='API')]
    [Parameter(ParameterSetName='SSH')]
        [ValidateSet('CAGE','PORT','MAG')]		    [string]	$HA,					
    [Parameter(ParameterSetName='API')]
    [Parameter(ParameterSetName='SSH')] 		    [string]	$Chunklets,				

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
	[Parameter(ParameterSetName='API')]
    [Parameter(ParameterSetName='SSH')]
        [ValidateSet('FC','NL','SSD')]	        [int]		$DiskType,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Sa,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Sd,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Aw,
	[Parameter(ParameterSetName='SSH')]	        [String]	$T,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Ssz,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Rs,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Ss,
	[Parameter(ParameterSetName='SSH')]	        [switch]	$P,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Nd,
	[Parameter(ParameterSetName='SSH')]	        [String]	$St,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Pt,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Cg,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Mg,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Pn,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Dk,
	[Parameter(ParameterSetName='SSH')]	        [int]	$Tc_gt,
	[Parameter(ParameterSetName='SSH')]	        [int]	$Tc_lt,
	[Parameter(ParameterSetName='SSH')]	        [int]	$Fc_gt,
	[Parameter(ParameterSetName='SSH')]	        [int]	$Fc_lt,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Devid,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Sax,
	[Parameter(ParameterSetName='SSH')]	        [String]	$Sdx
)
Begin 
    {	if ( $PSCmdlet.ParameterSetName -eq 'API' )
            {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                    {	$PSetName = 'API'
                    }
                else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                            {	$PSetName = 'SSH'
                            }
                    }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'ssh' )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process
{	switch ($PSetName)
    {   'API'   
                {   $body = @{}
                    If ($NewName) 							{ $body["newName"] ="$($NewName)" } 
                    If (-not($null -eq $DisableAutoGrow))	{ $body["disableAutoGrow"] =$DisableAutoGrow } 
                    If (-not($null -eq $GrowthIncrement)){ $body["growthIncrementMiB"] = $GrowthIncrement } 
                    If (-not($null -eq $GrowthLimit)) 		{ $body["growthLimitMiB"] = $GrowthLimit } 
                    If (-not($null -eq $WarningAlert)) 		{ $body["WarningLDWarningAlertMiB"] = $WarningAlert } 
                    $LDLayoutBody = @{}
                    if ($RAIDType)
                        {	if($RAIDType -eq "R0")		{	$LDLayoutBody["RAIDType"] = 1	}
                            elseif($RAIDType -eq "R1")	{	$LDLayoutBody["RAIDType"] = 2	}
                            elseif($RAIDType -eq "R5")	{	$LDLayoutBody["RAIDType"] = 3	}
                            else						{	$LDLayoutBody["RAIDType"] = 4	}
                        }
                    if ($SetSize)			{	$LDLayoutBody["setSize"] = $SetSize		}
                    if ($HA)
                        {	if($HA -eq "PORT")			{	$LDLayoutBody["HA"] = 1			}
                            elseif($HA -eq "CAGE")		{	$LDLayoutBody["HA"] = 2			}
                            else						{	$LDLayoutBody["HA"] = 3			}
                        }
                    if ($Chunklets)
                        {	if($Chunklets -eq "FIRST")	{	$LDLayoutBody["chunkletPosPref"] = 1	}
                            else 						{	$LDLayoutBody["chunkletPosPref"] = 2	}
                        }
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
                    $Result = $null
                    $uri = '/cpgs/'+$CPGName	
                    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body	
                    $status = $Result.StatusCode
                    if($status -eq 200)
                        {	write-host "Cmdlet executed successfully" -foreground green
                            if($NewName)
                                {	return Get-A9Cpg -CPGName $NewName
                                }
                            else
                                {	return Get-A9Cpg -CPGName $CPGName
                                }
                        }
                    else
                        {	write-error "FAILURE : While Updating CPG:$CPGName " 
                            return $Result.StatusDescription
                        }
                }
        'SSH'   
                {   $Cmd = " setcpg -f"
                    if($Sa)		{	$Cmd += " -sa $Sa " }
                    if($Sd) 	{	$Cmd += " -sd $Sd " }
                    if($Aw) 	{	$Cmd += " -aw $Aw " }
                    if($growthIncrement){	$Cmd += " -sdgs $growthIncrement " }
                    if($GrowthLimit) 	{	$Cmd += " -sdgl $GrowthLimit " }
                    if($WarningAlert) 	{	$Cmd += " -sdgw $WarningAlert " }
                    if($T) 		{	$Cmd += " -t $T " }
                    if($Ssz)	{	$Cmd += " -ssz $Ssz " }
                    if($Rs) 	{	$Cmd += " -rs $Rs " }
                    if($Ss)		{	$Cmd += " -ss $Ss " }
                    if($Ha)		{	$Cmd += " -ha $Ha " }
                    if($Chunklets) 	{	$Cmd += " -ch $Chunklets " }
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
                    if($DiskType){	$Cmd += " -devtype $Disktype " }
                    if($Rpm)	{	$Cmd += " -rpm $Rpm " }
                    if($Sax)	{	$Cmd += " -sax $Sax "	}
                    if($Sdx)	{	$Cmd += " -sdx $Sdx " }
                    if($NewName){	$Cmd += " -name $NewName " }
                    if($CPGname){	$Cmd += " $CPGname " }
                    else		{	Return "CPG Name is mandatory please enter..." }
                    $Result = Invoke-A9CLICommand -cmds  $Cmd
                    if ([string]::IsNullOrEmpty($Result))	{    Get-CPG -Detailed -cpgName $CPGname }
                    else	{ 	Return $Result	}
                }
    }
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
.PARAMETER Pattern
	Compacts CPGs that match any of the specified patterns. This option must be used if the pattern specifier is used. Option only available using SSH
.PARAMETER Waittask
	Waits for any created tasks to complete. Option only available using SSH
.PARAMETER Trimonly
	Removes unused logical disks after consolidating the space. This option will not perform any region moves.
.PARAMETER Nomatch
	Removes only unused logical disks whose characteristics do not match the growth characteristics of the CPG. Must be used with the -trimonly
	option. If all logical disks match the CPG growth characteristics, this option has no effect.
.PARAMETER DryRun
	Specifies that the operation is a dry run, and the tasks are not actually performed. Option only available using SSH
.PARAMETER UseSSH
    This option overrides the default to API behavior and forces the commnad to use SSH instead. 
.EXAMPLE
	PS:> Compress-A9CPG -CPG_name xxx 
.EXAMPLE
	PS:> Compress-A9CPG -CPG_name tstCPG
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='SSH')]	            [switch]	$Pattern,
		[Parameter(ParameterSetName='SSH')]	            [switch]	$Waittask,
		[Parameter(ParameterSetName='SSH')]
        [Parameter(ParameterSetName='API')]	            [switch]	$Trimonly,
		[Parameter(ParameterSetName='SSH')]
        [Parameter(ParameterSetName='API')]	            [switch]	$Nomatch,
		[Parameter(ParameterSetName='SSH')]	            [switch]	$DryRun,
		[Parameter(Mandatory,ParameterSetName='API')]
        [Parameter(Mandatory,ParameterSetName='SSH')]   [String]	$CPG_name,
        [Parameter(ParameterSetName='SSH')]	            [switch]	$UseSSH
		
)
Begin 
    {	if ( $PSCmdlet.ParameterSetName -eq 'API' )
            {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                    {	$PSetName = 'API'
                    }
                else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                            {	$PSetName = 'SSH'
                            }
                    }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'ssh' )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process
{	switch ($PSetName)
    {   'SSH'   
                {   $Cmd = " compactcpg -f "
                    if($Pattern) 		{	$Cmd += " -pat " }
                    if($Waittask) 		{	$Cmd += " -waittask " }
                    if($Trimonly) 		{	$Cmd += " -trimonly " }
                    if($Nomatch)		{	$Cmd += " -nomatch " }
                    if($DryRun)			{	$Cmd += " -dr " }
                    if($CPG_name)		{	$Cmd += " $CPG_name "}
                    else				{	Return "CPG Name is mandatory please enter...." }
                    $Result = Invoke-A9CLICommand -cmds  $Cmd
                    Return $Result
                }
        'API'   
                {   $body = @{}
                    $Result = $null
                    $uri = '/cpgs/'+$CPGName	
                    $Body['action'] = 1
                    if ( $Trimonly )
                        {   $Body['trimonly'] = $Trimonly
                            if ( $noMatch )
                                {   $Body['noMatch']=$Nomatch
                                }
                        }
                    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body	
                    $status = $Result.StatusCode
                    if($status -eq 200)
                        {	write-host "Cmdlet executed successfully" -foreground green
                            if($NewName)
                                {	return Get-A9Cpg -CPGName $NewName
                                }
                            else
                                {	return Get-A9Cpg -CPGName $CPGName
                                }
                        }
                    else
                        {	write-error "FAILURE : While Updating CPG:$CPGName " 
                            return $Result.StatusDescription
                        }
                }
    }
}
}

# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBUos+YpDZi
# DbcbsMf2ooffXLlo7dvahYphLLjoZXLU60MXOJDn9xY4eaLG2wxzHZQZc8OQjUF1
# RI2aoWMZ5E7/oIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG58wghubAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQFN4/3VTFtGzBNIWNeGHtqW8yjR+SNhQivOuU+dd6QKOO26FDeNbincd
# DNmYQ8E88x9b34LId2eEX896nV054AYwDQYJKoZIhvcNAQEBBQAEggGAKW6vNHiI
# LgVIHHbBydFxq16au6MdwlWZl8tR0V4wfW72Tnoir883N1PqqYCbcQt5FMQVr9vK
# qZGtyYOYhnr6Ppnjo7iQyykpTuJjo9cXtADA+u7mmrO9CjggOQ3U1ymqjUwFkaPN
# LcyAwgxxWIj4CCLj6vhrvxBTlwZB63yeNlIHGAw+X4D3Yf6+sCdeLFCgPvW+TqGw
# GkOgyjtFOeRt3BWvSSdJ7NRCApSSzhfcR5whx1EeLnVYtofI25FD6RFFE8Ymg6GL
# 8V/ZRG+ugaf7PcyqXg8g3ZjTqRgwMNdTLm48/O2Vi9B+Fi4m+6ASKl2qUb/0RpB6
# QGDWK+S+3IWe0pSGWvWCScjnwR1/3kB0PHHwSvWIKC5jcpxO7vMko6zV44tjyzIu
# 6SqCiJL6futa70hycWZ8p/iStEHJKKkLtW5sYPnM7dnxPEFuUXhI0lgKJY5Y2mRZ
# CddpXSxB+oyC5i+hcdVmbysvFToO94RuOIHwLozFl+CjdugMYQOAPySDoYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMH88QKsTwpz5OYPM1v0fhssQ1OCvqbXS
# W/OXTF0ob9WcQ5hCr+9gyqKbjoeTL9m5SgIUA0WmXGOwfA0W7fWTUQNqBQSoPocY
# DzIwMjUwNTE1MDIzOTQ3WqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
# c3QgWW9ya3NoaXJlMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMT
# J1NlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNqCCEwQwggZi
# MIIEyqADAgECAhEApCk7bh7d16c0CIetek63JDANBgkqhkiG9w0BAQwFADBVMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNTAzMjcwMDAw
# MDBaFw0zNjAzMjEyMzU5NTlaMHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5XZXN0
# IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzYwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDThJX0bqRTePI9EEt4Egc83JSBU2dhrJ+w
# Y7JgReuff5KQNhMuzVytzD+iXazATVPMHZpH/kkiMo1/vlAGFrYN2P7g0Q8oPEcR
# 3h0SftFNYxxMh+bj3ZNbbYjwt8f4DsSHPT+xp9zoFuw0HOMdO3sWeA1+F8mhg6uS
# 6BJpPwXQjNSHpVTCgd1gOmKWf12HSfSbnjl3kDm0kP3aIUAhsodBYZsJA1imWqkA
# VqwcGfvs6pbfs/0GE4BJ2aOnciKNiIV1wDRZAh7rS/O+uTQcb6JVzBVmPP63k5xc
# ZNzGo4DOTV+sM1nVrDycWEYS8bSS0lCSeclkTcPjQah9Xs7xbOBoCdmahSfg8Km8
# ffq8PhdoAXYKOI+wlaJj+PbEuwm6rHcm24jhqQfQyYbOUFTKWFe901VdyMC4gRwR
# Aq04FH2VTjBdCkhKts5Py7H73obMGrxN1uGgVyZho4FkqXA8/uk6nkzPH9QyHIED
# 3c9CGIJ098hU4Ig2xRjhTbengoncXUeo/cfpKXDeUcAKcuKUYRNdGDlf8WnwbyqU
# blj4zj1kQZSnZud5EtmjIdPLKce8UhKl5+EEJXQp1Fkc9y5Ivk4AZacGMCVG0e+w
# wGsjcAADRO7Wga89r/jJ56IDK773LdIsL3yANVvJKdeeS6OOEiH6hpq2yT+jJ/lH
# a9zEdqFqMwIDAQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNh
# lxmiMpswHQYDVR0OBBYEFIhhjKEqN2SBKGChmzHQjP0sAs5PMA4GA1UdDwEB/wQE
# AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1Ud
# IARDMEEwNQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8v
# Y3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5j
# cmwwegYIKwYBBQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYB
# BQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IB
# gQACgT6khnJRIfllqS49Uorh5ZvMSxNEk4SNsi7qvu+bNdcuknHgXIaZyqcVmhrV
# 3PHcmtQKt0blv/8t8DE4bL0+H0m2tgKElpUeu6wOH02BjCIYM6HLInbNHLf6R2qH
# C1SUsJ02MWNqRNIT6GQL0Xm3LW7E6hDZmR8jlYzhZcDdkdw0cHhXjbOLsmTeS0Se
# RJ1WJXEzqt25dbSOaaK7vVmkEVkOHsp16ez49Bc+Ayq/Oh2BAkSTFog43ldEKgHE
# DBbCIyba2E8O5lPNan+BQXOLuLMKYS3ikTcp/Qw63dxyDCfgqXYUhxBpXnmeSO/W
# A4NwdwP35lWNhmjIpNVZvhWoxDL+PxDdpph3+M5DroWGTc1ZuDa1iXmOFAK4iwTn
# lWDg3QNRsRa9cnG3FBBpVHnHOEQj4GMkrOHdNDTbonEeGvZ+4nSZXrwCW4Wv2qyG
# DBLlKk3kUW1pIScDCpm/chL6aUbnSsrtbepdtbCLiGanKVR/KC1gsR0tC6Q0RfWO
# I4owggYUMIID/KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUA
# MFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNV
# BAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AM2Y2ENBq26CK+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStS
# VjeYXIjfa3ajoW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQ
# BaCxpectRGhhnOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE
# 9cbY11XxM2AVZn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExS
# Lnh+va8WxTlA+uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OII
# q/fWlwBp6KNL19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGd
# F+z+Gyn9/CRezKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w
# 76kOLIaFVhf5sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4Cllg
# rwIDAQABo4IBXDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUw
# HQYDVR0OBBYEFF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjAS
# BgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28u
# Y29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEF
# BQcBAQRwMG4wRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0O
# NVgMnoEdJVj9TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc
# 6ZvIyHI5UkPCbXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1
# OSkkSivt51UlmJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz
# 2wSKr+nDO+Db8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y
# 4Il6ajTqV2ifikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVM
# CMPY2752LmESsRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBe
# Nh9AQO1gQrnh1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupia
# AeNHe0pWSGH2opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU
# +CCQaL0cJqlmnx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/Sjws
# usWRItFA3DE8MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7
# xpMeYRriWklUPsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs6
# 56Oz3TbLyXVoMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAs
# BgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJ
# BZvMWhUP2ZQQRLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQn
# Oh2qmcxGzjqemIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypo
# GJrruH/drCio28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0p
# KG9ki+PC6VEfzutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13j
# QEV1JnUTCm511n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9
# YrcmXcLgsrAimfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/y
# Vl4jnDcw6ULJsBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVg
# h60KmLmzXiqJc6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/
# OLoanEWP6Y52Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+Nr
# LedIxsE88WzKXqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58N
# Hs57ZPUfECcgJC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9U
# gOHYm8Cd8rIDZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1Ud
# DwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0
# eS5jcmwwNQYIKwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3
# OyWM637ayBeR7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJ
# JlFfym1Doi+4PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0m
# UGQHbRcF57olpfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTw
# bD/zIExAopoe3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i
# 111TW7HV1AtsQa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGe
# zjM6CRpcWed/ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+
# 8aW88WThRpv8lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH
# 29308ZkpKKdpkiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrs
# xrYJD+3f3aKg6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6
# Ii8+CQOYDwXM+yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz
# 7NgAnOgpCdUo4uDyllU9PzGCBJIwggSOAgEBMGowVTELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMg
# VGltZSBTdGFtcGluZyBDQSBSMzYCEQCkKTtuHt3XpzQIh616TrckMA0GCWCGSAFl
# AwQCAgUAoIIB+TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTI1MDUxNTAyMzk0N1owPwYJKoZIhvcNAQkEMTIEMHuD/Yp2oBNuILPj
# cVLJemJbAvoa1A5GhF74bDQ5hq44sbhxZQVCbSy3oEf791bW+DCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAIgtMFiQoNumFxzA3/IJx3W4aii4nuqNS6KHqZrhgn8keYiczHp8Fx0Qf
# 7VzE8U19Mf//rNIzr9Al55t+DPmTVg6dJUiRB2PyZfzJYozJg8+dpT4YG/JHcwKG
# ELjz16bjEbhwwxRX5/l9I3frzDNGfuyxwuzoBaXDGHdvrTvlnI9Q2d1LPUs0vZcc
# FhAUFrfai9TLz/xvU0vFjENVk/2+gqKuVBVM60JjNYulbwgva6R5jnkmGvRnR19+
# YYNgo5ludMseUTFE7R8NHoZ6CtC6Jjx4EuIUZclJAmTilkOOBV7lUFOicsQb/Sid
# fzDVRYnSIYGgufR7SeVOOADhC5aslTB2msWO4UwdgqjySJiEx2KSporj4jCJrGtW
# uSac7pZAXUw/mvUFYoAZNNSdpOurPPIEjEgvR83juLP3LZwZ0jnMz3xNzjgsz4y/
# ZZAbm1ltkfnlO5dnfQKJ77c37GtbDSQ6PuJdYBDLw8EiKDRP9OAkNMC4ZZfwXIP1
# qHmKs3atbyo8M/V18zh8R4zVS4KEKxQwTUpLo5aoCoNQAePTCXi8vYiUwLuPIogD
# ypjbZHtcQrY6m4YZ4pXNZzQ9HmfPf0DvbrqeRgyXnEnkjbSOS6bRiQlIBeNljhW6
# TPU7utGbzR6Bc4lD70vDGIKlOI8iKZS3xVw0sKC5aso91rfedns=
# SIG # End signature block
