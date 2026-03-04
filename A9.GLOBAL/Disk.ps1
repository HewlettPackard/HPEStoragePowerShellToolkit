## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9Disk
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
                    return $returnvalue
                }
    }
}
}