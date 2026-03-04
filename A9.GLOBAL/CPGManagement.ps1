## 	©2025 Hewlett Packard Enterprise Development LP

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
{	switch -wildcard ($PsCmdlet.ParameterSetName)
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
                        {	write-error "FAILURE : While Executing Get-A9Cpg CPG:$CPGName "
                            return $Result.StatusDescription
                    }
                }
        "SSH*"   {	$GetCPGCmd = "showcpg "
                    if($Alert)			{	$GetCPGCmd += "-alert -hist "
                                            $IndexHeader=3; $StartIndex=4; $EndIndex=6; $history=$true
                                		}
                    if($SAG)			{	$GetCPGCmd += "-sag -hist "
                                            $IndexHeader=2; $StartIndex=3; $EndIndex=5; $history=$true
                                		}
                    if($SDG)			{	$GetCPGCmd += "-sdg -hist"
                                            $IndexHeader=2; $StartIndex=3; $EndIndex=4; $history=$true
                                		}
                    if($DomainName)	{	$GetCPGCmd += "-domain $DomainName "
                                    	}
                    if ($cpgName)		{	if (-not $Alert -and -not $SAG -and -not $SDG )
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
Param(
	[Parameter(Mandatory, ParameterSetName='API')][String]	$NewName,
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
	[Parameter(ParameterSetName='API')]			[int]		$FreeChunkletsLessThan
)
Begin 
    {	Test-A9Connection -CLientType 'API'
    }
Process
{	 $body = @{}
    If ($NewName) 							{ $body["newName"] ="$($NewName)" } 
    If (-not($null -eq $DisableAutoGrow))	{ $body["disableAutoGrow"] =$DisableAutoGrow } 
    If ( -not($null -eq $GrowthIncrement) ){ $body["growthIncrementMiB"] = $GrowthIncrement } 
    If ( -not($null -eq $GrowthLimit) ) 		{ $body["growthLimitMiB"] = $GrowthLimit } 
    If ( -not($null -eq $WarningAlert) ) 		{ $body["WarningLDWarningAlertMiB"] = $WarningAlert } 
    $LDLayoutBody = @{}
    if ( $RAIDType -eq "R0" )  {	$LDLayoutBody["RAIDType"] = 1	}
    if ( $RAIDType -eq "R1" )	{	$LDLayoutBody["RAIDType"] = 2	}
    if ( $RAIDType -eq "R5" )	{	$LDLayoutBody["RAIDType"] = 3	}
    if ( $RAIDType -eq "R6" )	{	$LDLayoutBody["RAIDType"] = 4	}
    if ( $SetSize )			{	$LDLayoutBody["setSize"] = $SetSize		}
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
.PARAMETER Trimonly
	Removes unused logical disks after consolidating the space. This option will not perform any region moves.
.PARAMETER Nomatch
	Removes only unused logical disks whose characteristics do not match the growth characteristics of the CPG. Must be used with the -trimonly
	option. If all logical disks match the CPG growth characteristics, this option has no effect.
.EXAMPLE
	PS:> Compress-A9CPG -CPG_name xxx 
.EXAMPLE
	PS:> Compress-A9CPG -CPG_name tstCPG
.NOTES
	This command requires a SSH type connection.
    the Wait option has been removed since if you want to use a wait option you can use the Get-Task command with the Wait option.
    #>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='API')]	            [switch]	$Trimonly,
		[Parameter(ParameterSetName='API')]	            [switch]	$Nomatch,
		[Parameter(Mandatory,ParameterSetName='API')]   [String]	$CPG_name
)
Begin 
    {	Test-A9Connection -CLientType 'API'
    }
Process
{	$body = @{}
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
