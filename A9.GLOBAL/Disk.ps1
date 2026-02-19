## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9Disk
{
[CmdletBinding(DefaultParameterSetName='API')]
<#
.SYNOPSIS
	Displays configuration information about the physical disks (PDs) on a system. 
.DESCRIPTION
	Displays configuration information about the physical disks (PDs) on a system. 
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
	PS:> Get-A9Disk -C -Pattern -Devtype FC  	
.EXAMPLE  
	PS:> Get-A9PhysicalDisk -option p -pattern mg -patternValue 0

	TThis example will display all the FC disks in magazine 0 of all cages.
.NOTES
	This command requires a SSH type connection if using any arguments.
    The same data from the API is given as it presented from the option -i (inquery, so -i has been depreciated)
#>
param(	[Parameter(ParameterSetName='ssh')]	[switch]	$E,
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
                            return $NewObj
                        }
                    else
                        {	Write-Error "Failure:  While Executing Get-A9Host." 
                            return $Result.StatusDescription
                        }
                }
        'SSH'   {   $cmd= "showpd "	
                    if($E)		{	$cmd+=" -e "	}
                    if($C)		{	$cmd+=" -c "	}
                    if($State)	{	$cmd+=" -state "}
                    if($Path)	{	$cmd+=" -path "	}
                    if($Space)	{	$cmd+=" -space "}
                    if($Failed)	{	$cmd+=" -failed "}
                    if($Degraded){	$cmd+=" -degraded "	}
                    if($Node)	{	$cmd+=" -nodes $Node "	}
                    if($Slots)	{	$cmd+=" -slots $Slots "	}
                    if($Ports)	{	$cmd+=" -ports $Ports "	}
                    if($WWN)	{	$cmd+=" -w $WWN "	}
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
                    
                    if($State -Or $StateInfo)
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