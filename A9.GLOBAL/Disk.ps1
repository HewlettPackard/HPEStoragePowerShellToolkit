####################################################################################
## 	© 2024 Hewlett Packard Enterprise Development LP
##

Function Get-A9Disk
{
[CmdletBinding(DefaultParameterSetName='API')]
<#
.SYNOPSIS
	Displays configuration information about the physical disks (PDs) on a system. 
.DESCRIPTION
	Displays configuration information about the physical disks (PDs) on a system. 
.EXAMPLE  
	PS:> Get-A9Disk

	This example displays configuration information about all the physical disks (PDs) on a system. 
.EXAMPLE  
	PS:> Get-A9Disk -PD_ID 5

	This example displays configuration information about specific or given physical disks (PDs) on a system. 
.EXAMPLE  
	PS:> Get-A9Disk -C 

	This example displays chunklet use information for all disks. 
.EXAMPLE  
	PS:> Get-A9Disk -C -PD_ID 5

	This example will display chunklet use information for all disks with the physical disk ID. 
.EXAMPLE  
	PS:> Get-A9Disk -Node 0 -PD_ID 5
.EXAMPLE  
	PS:> Get-A9Disk -I -Pattern -ND 1 -PD_ID 5
.EXAMPLE
	PS:> Get-A9Disk -C -Pattern -Devtype FC  	
.EXAMPLE  
	PS:> Get-A9PhysicalDisk -option p -pattern mg -patternValue 0

	TThis example will display all the FC disks in magazine 0 of all cages.
.PARAMETER Listcols
	List the columns available to be shown in the -showcols option
	described below (see 'clihelp -col showpd' for help on each column).
.PARAMETER I
	Show disk inventory (inquiry) data.

	The following columns are shown:
	Id CagePos State Node_WWN MFR Model Serial FW_Rev Protocol MediaType AdmissionTime.
.PARAMETER E
	Show disk environment and error information. Note that reading this information places a significant load on each disk.
	The following columns are shown:
	Id CagePos Type State Rd_CErr Rd_UErr Wr_CErr Wr_UErr Temp_DegC LifeLeft_PCT.
.PARAMETER C
	Show chunklet usage information. Any chunklet in a failed disk will be shown as "Fail".

	The following columns are shown:
	Id CagePos Type State Total_Chunk Nrm_Used_OK Nrm_Used_Fail
	Nrm_Unused_Free Nrm_Unused_Uninit Nrm_Unused_Unavail Nrm_Unused_Fail
	Spr_Used_OK Spr_Used_Fail Spr_Unused_Free Spr_Unused_Uninit Spr_Unused_Fail.
.PARAMETER S
	Show detailed state information. This option is deprecated and will be removed in a subsequent release.
.PARAMETER State
	Show detailed state information. This is the same as -s.

	The following columns are shown:	Id CagePos Type State Detailed_State SedState.
.PARAMETER Path
	Show current and saved path information for disks.

	The following columns are shown: Id CagePos Type State Path_A0 Path_A1 Path_B0 Path_B1 Order.
.PARAMETER Space
	Show disk capacity usage information (in MB).

	The following columns are shown: Id CagePos Type State Size_MB Volume_MB Spare_MB Free_MB Unavail_MB Failed_MB.
.PARAMETER Failed
	Specifies that only failed physical disks are displayed.
.PARAMETER Degraded
	Specifies that only degraded physical disks are displayed. If both -failed and -degraded are specified, the command shows failed disks and degraded disks.
.PARAMETER Pattern
	Physical disks matching the specified pattern are displayed.
.PARAMETER ND
	Specifies one or more nodes. Nodes are identified by one or more integers (item). Multiple nodes are separated with a single comma
	(e.g. 1,2,3). A range of nodes is separated with a hyphen (e.g. 0-7). The primary path of the disks must be on the specified node(s).
.PARAMETER ST
	Specifies one or more PCI slots. Slots are identified by one or more integers (item). Multiple slots are separated with a single comma
	(e.g. 1,2,3). A range of slots is separated with a hyphen (e.g. 0-7). The primary path of the disks must be on the specified PCI slot(s).
.PARAMETER PT
	Specifies one or more ports. Ports are identified by one or more integers (item). Multiple ports are separated with a single comma
	(e.g. 1,2,3). A range of ports is separated with a hyphen (e.g. 0-4). The primary path of the disks must be on the specified port(s).
.PARAMETER CG
	Specifies one or more drive cages. Drive cages are identified by one or more integers (item). Multiple drive cages are separated with a
	single comma (e.g. 1,2,3). A range of drive cages is separated with a hyphen (e.g. 0-3). The specified drive cage(s) must contain disks.
.PARAMETER MG
	Specifies one or more drive magazines. The "1." or "0." displayed in the CagePos column of showpd output indicating the side of the cage is omitted when 
	using the -mg option. Drive magazines are identified by one or more integers (item). Multiple drive magazines are separated with a single comma (e.g. 1,2,3). 
	A range of drive magazines is separated with a hyphen(e.g. 0-7). The specified drive magazine(s) must contain disks.
.PARAMETER PN
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers (item). Multiple disk positions 
	are separated with a single comma(e.g. 1,2,3). A range of disk positions is separated with a hyphen(e.g. 0-3). The specified position(s) must contain disks.
.PARAMETER DK
	Specifies one or more physical disks. Disks are identified by one or more integers(item). Multiple disks are separated with a single
	comma (e.g. 1,2,3). A range of disks is separated with a hyphen(e.g. 0-3).  Disks must match the specified ID(s).
.PARAMETER Devtype
	Specifies that physical disks must have the specified device type (FC for Fast Class, NL for Nearline, SSD for Solid State Drive)
	to be used. Device types can be displayed by issuing the "showpd" command.
.PARAMETER RPM
	Drives must be of the specified relative performance metric, as shown in the "RPM" column of the "showpd" command. The number does not represent a rotational 
	speed for the drives without spinning media (SSD). It is meant as a rough estimation of the performance difference between the drive and the other drives
	in the system.  For FC and NL drives, the number corresponds to both a performance measure and actual rotational speed. For SSD drives, the number is to be 
	treated as a relative performance benchmark that takes into account I/O's per second, bandwidth and access time.
.PARAMETER Node
	Specifies that the display is limited to specified nodes and physical disks connected to those nodes. The node list is specified as a series
	of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the node list is not specified, all disks on all nodes are displayed.
.PARAMETER Slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified as a series of 
	integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all disks on all slots are displayed.
.PARAMETER Ports
	Specifies that the display is limited to specified ports and physical disks connected to those ports. The port list is specified as a series of integers separated 
	by commas (e.g. 1,2,3). The list can also consist of a single integer. If the port list is not specified, all disks on all ports are displayed.
.PARAMETER WWN
	Specifies the WWN of the physical disk. This option and argument can be specified if the <PD_ID> specifier is not used. This option should be the last option in the command line.
.NOTES
	This command requires a SSH type connection.
#>
param(	[Parameter(ParameterSetName='ssh')]	[switch]	$I,
		[Parameter(ParameterSetName='ssh')]	[switch]	$E,
		[Parameter(ParameterSetName='ssh')]	[switch]	$C,
		[Parameter(ParameterSetName='ssh')]	[switch]	$StateInfo,
		[Parameter(ParameterSetName='ssh')]	[switch]	$State,
		[Parameter(ParameterSetName='ssh')]	[switch]	$Path,
		[Parameter(ParameterSetName='ssh')]	[switch]	$Space,
		[Parameter(ParameterSetName='ssh')]	[switch]	$Failed,
		[Parameter(ParameterSetName='ssh')]	[switch]	$Degraded,
		[Parameter(ParameterSetName='ssh')]	[String]	$Node ,
		[Parameter(ParameterSetName='ssh')]	[String]	$Slots ,
		[Parameter(ParameterSetName='ssh')]	[String]	$Ports ,
		[Parameter(ParameterSetName='ssh')]	[String]	$WWN ,
		[Parameter(ParameterSetName='sshPattern',Mandatory)]	[switch]	$Pattern,
		[Parameter(ParameterSetName='sshPattern')]	[String]	$ND ,
		[Parameter(ParameterSetName='sshPattern')]	[String]	$ST ,
		[Parameter(ParameterSetName='sshPattern')]	[String]	$PT ,
		[Parameter(ParameterSetName='sshPattern')]	[String]	$CG ,
		[Parameter(ParameterSetName='sshPattern')]	[String]	$MG ,
		[Parameter(ParameterSetName='sshPattern')]	[String]	$PN ,
		[Parameter(ParameterSetName='sshPattern')]	[String]	$DK ,
		[Parameter(ParameterSetName='sshPattern')]	
		[Parameter(ParameterSetName='API')]	
        [ValidateSet('FC','NL','SSD','SCM')]            [String]	$Devtype ,
		[Parameter(ParameterSetName='sshPattern')]	    [String]	$RPM ,
		[Parameter(ParameterSetName='ssh')]	            [String]	$PD_ID ,
		[Parameter(ParameterSetName='ssh')]	            [switch]	$Listcols,
        [Parameter(ParameterSetName='ssh')]	            [switch]	$UseSSH

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
            elseif ( ($PSCmdlet.ParameterSetName -eq 'ssh') -or ($PSCmdlet.ParameterSetName -eq 'ssPattern') )	
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
    {   'API'   {   $uri = '/disks'
                    if($Devtype)
                        {	switch($Devtype)
                                {   'FC'    {   $uri += '="<type EQ 1>"' }
                                    'NL'    {   $uri += '="<type EQ 2>"' }
                                    'SSD'   {   $uri += '="<type EQ 3>"' }
                                    default {   $uri += '/'              }
                                }
                            $Result = Invoke-A9API -uri $uri -type 'GET' 
                            If($Result.StatusCode -eq 200)			{	$dataPS = $Result.content | ConvertFrom-Json	}	
                        }	
                    else
                        {   $uri += '/'	
                            $Result = Invoke-A9API -uri $uri -type 'GET'
                            If($Result.StatusCode -eq 200)		{	$dataPS = ($Result.content | ConvertFrom-Json).members		}		
                        }
                    If($Result.StatusCode -eq 200)
                        {	write-host "Cmdlet executed successfully" -foreground green
                            return $dataPS
                        }
                    else
                        {	Write-Error "Failure:  While Executing Get-Host_WSAPI." 
                            return $Result.StatusDescription
                        }
                }
        'SSH'   {   $cmd= "showpd "	
                    if($Listcols)
                                {	$cmd+=" -listcols "
                                    $Result = Invoke-A9CLICommand -cmds  $cmd
                                    return $Result
                                }
                    if($I)		{	$cmd+=" -i "	}
                    if($E)		{	$cmd+=" -e "	}
                    if($C)		{	$cmd+=" -c "	}
                    if($StateInfo){	$cmd+=" -s "	}
                    if($State)	{	$cmd+=" -state "}
                    if($Path)	{	$cmd+=" -path "	}
                    if($Space)	{	$cmd+=" -space "}
                    if($Failed)	{	$cmd+=" -failed "}
                    if($Degraded){	$cmd+=" -degraded "	}
                    if($Node)	{	$cmd+=" -nodes $Node "	}
                    if($Slots)	{	$cmd+=" -slots $Slots "	}
                    if($Ports)	{	$cmd+=" -ports $Ports "	}
                    if($WWN)	{	$cmd+=" -w $WWN "	}
                    if($Pattern)
                                {	if($ND)	{	$cmd+=" -p -nd $ND "	}
                                    if($ST)	{	$cmd+=" -p -st $ST "	}
                                    if($PT)	{	$cmd+=" -p -pt $PT "	}
                                    if($CG)	{	$cmd+=" -p -cg $CG "	}
                                    if($MG)	{	$cmd+=" -p -mg $MG "	}
                                    if($PN)	{	$cmd+=" -p -pn $PN "	}
                                    if($DK)	{	$cmd+=" -p -dk $DK "	}
                                    if($Devtype){	$cmd+=" -p -devtype $Devtype "	}
                                    if($RPM)	{	$cmd+=" -p -rpm $RPM "}
                                }		
                    if ($PD_ID) 
                                {	$PD=$PD_ID		
                                    $pdd="showpd $PD"
                                    $Result1 = Invoke-A9CLICommand -cmds  $pdd	
                                    if($Result1 -match "No PDs listed" )
                                        {	return " FAILURE : $PD_ID is not available id pLease try using only [Show-PD] to get the list of PD_ID Available. "			
                                        }
                                    else{	$cmd+=" $PD_ID "
                                        }
                                }	
                    $Result = Invoke-A9CLICommand -cmds  $cmd
                    
                    if($Result -match "Invalid device type")	{	return $Result	}
                    if($Result.Count -lt 2)						{	return $Result	}
                    
                    if($I -Or $State -Or $StateInfo)
                        {	$flag = "True"
                            $tempFile = [IO.Path]::GetTempFileName()
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
                            $returnvalue = Import-Csv $tempFile 
                            Remove-Item  $tempFile
                            return $returnvalue
                        }
                    ElseIf($C)
                        {	$tempFile = [IO.Path]::GetTempFileName()
                            $LastItem = $Result.Count -3  
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
                            $returnvalue = Import-Csv $tempFile 
                            Remove-Item  $tempFile
                            return $returnvalue
                        }
                    ElseIf($E)
                        {	$tempFile = [IO.Path]::GetTempFileName()
                            $LastItem = $Result.Count -3  
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
                            $returnvalue = Import-Csv $tempFile
                            Remove-Item  $tempFile
                            return $returnvalue
                        }
                    else
                        {	if($Result -match "Id")
                                {	$tempFile = [IO.Path]::GetTempFileName()
                                    $LastItem = $Result.Count -3  
                                    foreach ($s in  $Result[1..$LastItem] )
                                    {	$s= [regex]::Replace($s,"^ ","")			
                                        $s= [regex]::Replace($s," +",",")
                                        $s= [regex]::Replace($s,"-","")
                                        $s= $s.Trim() 	
                                        Add-Content -Path $tempFile -Value $s
                                    }
                                    if($Space)
                                        {	write-host "Size | Volume | Spare | Free | Unavail & Failed values are in (MiB)."
                                        }
                                    else
                                        {	write-host "Total and Free values are in (MiB)."
                                        }				
                                    $returnvalue = Import-Csv $tempFile 
                                    Remove-Item  $tempFile
                                    return $returnvalue
                                }
                        }		
                    if($Result.Count -gt 1)
                        {	return "Success : Command Show-PD execute Successfully."
                        }
                    else{	return $Result		
                        } 	
                }
    }
}
}