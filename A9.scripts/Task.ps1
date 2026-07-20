## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9Task
{
<#
.SYNOPSIS
    Displays information about tasks.
.DESCRIPTION
    Displays information about tasks.
.PARAMETER Status	
	Displays only tasks that are of the type ACTIVE, DONE, FAILED, or CANCELLED
.PARAMETER Task_type 
    Specifies that specified task type is used. The valid task types are as follows; ' VV_COPY ','PHYS_COPY_RESYNC','MOVE_REGIONS','PROMOTE_SV','REMOTE_COPY_SYNC',
    'REMOTE_COPY_REVERSE','REMOTE_COPY_FAILOVER','REMOTE_COPY_RECOVER','REMOTE_COPY_RESTORE','COMPACT_CPG','COMPACT_IDS','SNAPSHOT_ACCOUNTING','CHECK_VV','SCHEDULED_TASK',
    'SYSTEM_TASK','BACKGROUND_TASK','IMPORT_VV','ONLINE_COPY','CONVERT_VV','BACKGROUND_COMMAND','CLX_SYNC','CLX_RECOVERY','TUNE_SD','TUNE_VV','TUNE_VV_ROLLBACK',
    'TUNE_VV_RESTART','SYSTEM_TUNING','NODE_RESCUE','REPAIR_SYNC','REMOTE_COPY_SWOVER','DEFRAGMENTATION','ENCRYPTION_CHANGE','REMOTE_COPY_FAILSAFE','TUNE_TPVV',
    'REMOTE_COPY_CHG_MODE','ONLINE_PROMOTE','RELOCATE_PD','PERIODIC_CSS','TUNEVV_LARGE','SD_META_FIXER','DEDUP_DRYRUN','COMPR_DRYRUN','DEDUP_COMPR_DRYRUN','UKNOWN'
.PARAMETER TaskID 
    Show detailed task status for specified tasks. Tasks must be explicitly specified using their task IDs <task_ID>. Multiple task IDs can be specified. This option cannot be used in conjunction with other options.
.PARAMETER Detailed
    This will deliver very detailed timeline information on each task. This may take time if an ID is not used.
    To see the detail you will likely need to pipe the output to format-list as the table view cannot show this level of detail.
.PARAMETER HOURS
    Show events that have happened in the last number of hours specified.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE
    PS:> Get-A9Task
	
    Display all tasks. This will attempt to use the API if connected, and fail back to SSH if needed.
.EXAMPLE	
	PS:> Get-A9Task -taskID 4
	
    Show detailed task status for specified task 4. 
.EXAMPLE	
	PS:> Get-A9Task -taskID IMPORT_VV	

    Show detailed task status for all tasks that identify as an 'IMPORT_VV' type task
.EXAMPLE		
	PS:> Get-A9Task -Status DONE
	
    Display includes only tasks that are successfully completed
.EXAMPLE	
	PS:> Get-A9Task -Hours 10
	
    Show only tasks started within the past <hours>
.NOTES
	The CLI parameter HOURs which shows commands that have started in the last x hours can be replicated using one of the examples above, so the parameter was removed. This allows you to measure by minutes|hours|seconds|days since the 
    task started|finished.
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	[Parameter(Parametersetname='API')]	
                                                        [String]	$TaskID,
        [Parameter(parametersetname='API')]
        [ValidateSet('VV_COPY','PHYS_COPY_RESYNC','MOVE_REGIONS','PROMOTE_SV','REMOTE_COPY_SYNC','REMOTE_COPY_REVERSE','REMOTE_COPY_FAILOVER','REMOTE_COPY_RECOVER','REMOTE_COPY_RESTORE','COMPACT_CPG','COMPACT_IDS',
                    'SNAPSHOT_ACCOUNTING','CHECK_VV','SCHEDULED_TASK','SYSTEM_TASK','BACKGROUND_TASK','IMPORT_VV','ONLINE_COPY','CONVERT_VV','BACKGROUND_COMMAND','CLX_SYNC','CLX_RECOVERY','TUNE_SD','TUNE_VV',
                    'TUNE_VV_ROLLBACK','TUNE_VV_RESTART','SYSTEM_TUNING','NODE_RESCUE','REPAIR_SYNC','REMOTE_COPY_SWOVER','DEFRAGMENTATION','ENCRYPTION_CHANGE','REMOTE_COPY_FAILSAFE','TUNE_TPVV','REMOTE_COPY_CHG_MODE',
                    'ONLINE_PROMOTE','RELOCATE_PD','PERIODIC_CSS','TUNEVV_LARGE','SD_META_FIXER','DEDUP_DRYRUN','COMPR_DRYRUN','DEDUP_COMPR_DRYRUN','UKNOWN')]	        
                                                        [String]	$TaskType,
        [Parameter(parametersetname='API')]
        [VAlidateSet('DONE','ACTIVE','CANCELLED','FAILED')]	        
                                                        [string]	$Status,
        [Parameter(parametersetname='API')]             [Switch]    $Detailed,
        [Parameter(parametersetname='API')]             [int]       $Hours,
        [Parameter()]                                   [Switch]    $ShowAPI
	)		
Begin
    {   Test-A9Connection -CLientType 'API' 
    }
Process
    {	$uri='/tasks'
        if($TaskID)		{	$uri = $uri+'/'+$TaskID		}
        if ( $ShowAPI )
            {   $Result = Invoke-A9API -uri $uri -type 'GET' -whatif
                return
            }
        $Result = Invoke-A9API -uri $uri -type 'GET' 
        if ($Detailed -and (-not $TaskId) )
            {   if($Result.StatusCode -eq 200)
                    {	$dataPS = $Result.content | ConvertFrom-Json
                        if ($dataPS.members ) { $dataPS = $dataPS.members }
                        $perc = 0
                        $Count = $dataPS.count
                        $current=1
                        write-progress -Activity "Processing..." -Status "$perc% Complete." -PercentComplete $perc
                        $MyObj = @( foreach( $Item in $DataPS )
                                        {   Get-A9Task -TaskId $Item.id
                                            $current+=1
                                            if ( [int]$($current/$count * 100) -gt $perc)
                                                {   $Perc+=1
                                                    write-progress -Activity "Processing..." -Status "$perc% Complete." -PercentComplete $perc  
                                                }
                                        }
                                  )
                        write-progress -Activity "Processing..." -Status "$perc% Complete." -PercentComplete 100
                        start-sleep 2
                        write-progress -Activity "Processing..." -Completed
                        return $MyObj
                    }
                else
                    {	Write-Error "Failure:  While Executing Get-A9Task." 
                        return $Result.StatusDescription
                    }
            }
        if($Result.StatusCode -eq 200)
            {	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                $dataPS = $Result.content | ConvertFrom-Json
                if ($dataPS.members ) { $dataPS = $dataPS.members }
                $NewObj = @(    foreach( $Item in $DataPS)	{   $NewItem=@{PSTypeName = "HPE.A9Storage.Task"}
																$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
																		$Enum = $Item.type
																				Switch ($Enum)
																					{   1   {   $Desc = ' VV_COPY '             }
                                                                                        2   {   $Desc = ' PHYS_COPY_RESYNC'     }
                                                                                        3   {   $Desc = 'MOVE_REGIONS'          }
                                                                                        4   {   $Desc = 'PROMOTE_SV'            }
                                                                                        5   {   $Desc = 'REMOTE_COPY_SYNC'      }
                                                                                        6   {   $Desc = 'REMOTE_COPY_REVERSE'   }
                                                                                        7   {   $Desc = 'REMOTE_COPY_FAILOVER'  }
                                                                                        8   {   $Desc = 'REMOTE_COPY_RECOVER'   }
                                                                                        9   {   $Desc = 'REMOTE_COPY_RESTORE'   }
                                                                                        10  {   $Desc = 'COMPACT_CPG'           }
                                                                                        11  {   $Desc = 'COMPACT_IDS'           }
                                                                                        12  {   $Desc = 'SNAPSHOT_ACCOUNTING'   }
                                                                                        13  {   $Desc = 'CHECK_VV'              }
                                                                                        14  {   $Desc = 'SCHEDULED_TASK'        }
                                                                                        15  {   $Desc = 'SYSTEM_TASK'           }
                                                                                        16  {   $Desc = 'BACKGROUND_TASK'       }
                                                                                        17  {   $Desc = ' IMPORT_VV'            }
                                                                                        18  {   $Desc = 'ONLINE_COPY'           }
                                                                                        19  {   $Desc = 'CONVERT_VV'            }
                                                                                        20  {   $Desc = 'BACKGROUND_COMMAND'    }
                                                                                        21  {   $Desc = 'CLX_SYNC'              }
                                                                                        22  {   $Desc = 'CLX_RECOVERY'          }
                                                                                        23  {   $Desc = 'TUNE_SD'               }
                                                                                        24  {   $Desc = 'TUNE_VV'               }
                                                                                        25  {   $Desc = 'TUNE_VV_ROLLBACK'      }
                                                                                        26  {   $Desc = 'TUNE_VV_RESTART'       }
                                                                                        27  {   $Desc = 'SYSTEM_TUNING'         }
                                                                                        28  {   $Desc = 'NODE_RESCUE'           }
                                                                                        29  {   $Desc = 'REPAIR_SYNC'           }
                                                                                        30  {   $Desc = 'REMOTE_COPY_SWOVER'    }
                                                                                        31  {   $Desc = 'DEFRAGMENTATION'       }
                                                                                        32  {   $Desc = 'ENCRYPTION_CHANGE'     }
                                                                                        33  {   $Desc = 'REMOTE_COPY_FAILSAFE'  }
                                                                                        34  {   $Desc = 'TUNE_TPVV'             }
                                                                                        35  {   $Desc = 'REMOTE_COPY_CHG_MODE'  }
                                                                                        37  {   $Desc = 'ONLINE_PROMOTE'        }
                                                                                        38  {   $Desc = 'RELOCATE_PD'           }
                                                                                        39  {   $Desc = 'PERIODIC_CSS'          }
                                                                                        40  {   $Desc = 'TUNEVV_LARGE'          }
                                                                                        41  {   $Desc = 'SD_META_FIXER'         }
                                                                                        42  {   $Desc = 'DEDUP_DRYRUN'          }
                                                                                        43  {   $Desc = 'COMPR_DRYRUN'          }
                                                                                        44  {   $Desc = 'DEDUP_COMPR_DRYRUN'    }
                                                                                        99  {   $Desc = 'UKNOWN'                }
                                                                                    }
																				if ($Desc) 
																					{   $NewItem['TypeDescription'] = $Desc
																						remove-variable $Desc -erroraction SilentlyContinue
																						remove-variable $Enum -erroraction SilentlyContinue
																					}
																		$Enum = $Item.'status'
																				Switch ($Enum)
																					{   1   {   $Desc = 'DONE'      }
																						2   {   $Desc = 'ACTIVE'    }
																						3   {   $Desc = 'CANCELLED' }
																						4   {   $Desc = 'FAILED'    }
																					}
																				if ($Desc) 
																					{   $NewItem['StatusDescription'] = $Desc
																						remove-variable $Desc -erroraction SilentlyContinue
																						remove-variable $Enum -erroraction SilentlyContinue
																					}
                                                                        $Enum = $Item.startTime
                                                                            $NewItem['StartTimeDesc'] = [datetime]::parse($Enum.substring(0,$Enum.length-3))
                                                                        $Enum = $Item.finishTime
                                                                            $NewItem['FinishTimeDesc'] = [datetime]::parse($Enum.substring(0,$Enum.length-3))
                                                                        remove-variable $Enum -erroraction SilentlyContinue
																$DataSetType = "HPE.A9Storage.Task"
																$NewItem.PSTypeNames.Insert(0,$DataSetType)
																$DataSetType = $DataSetType + ".TypeName"
																$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
																[PSCustomObject]$NewItem
															}
							)
                    if ($TaskType)
                        {   $NewObj = $NewObj | where-object {$_.TypeDescription -like $TaskType }
                        }
                    if ($Status)
                        {   $NewObj = $NewObj | where-object {$_.StatusDescription -like $Status }
                        }
                    if ($Hours)
                        {   $NewObj = $NewObj | where-object {$Hours -gt $( New-TimeSpan -Start $_.StartTimeDesc -End $(Get-Date) ).TotalHours }
                        }
                    return $NewObj
            }
        else
            {	Write-Error "Failure:  While Executing Get-A9Task." 
                return $Result.StatusDescription
            }
    }
}

Function Stop-A9Task 
{	
<#
.SYNOPSIS
    Cancel one task
.DESCRIPTION
    The Stop Task command cancels a task.
.PARAMETER TaskID
    Cancels only tasks identified by their task IDs. TaskID must be an unsigned integer within 1-29999 range. If this is unset, then ALL must be set.
.PARAMETER ShowAPI 
    This option will show you the API call that would be made instead of making the API call. 
	This can be used for debugging as well as a method to learn how the RestAPI functions.
.EXAMPLE
    Cancel a task using the task ID

    PS:> Stop-A9Task 1234       
.NOTES
    The Stop-Task command can return before a cancellation is completed. Thus, resources reserved for a task might not be immediately available. This can
    prevent actions like restarting the canceled task. Use the waittask command to ensure orderly completion of the cancellation before taking other
    actions. See waittask for more details.
    A Service user is only allowed to cancel tasks started by that specific user.
	This command will use the API if available, otherwise will default back to a SSH type connection.
    Authority:Super, Service, Edit
    Any role granted the task_cancel right
    Usage:
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	[Parameter(Mandatory)]  [String]	$TaskID,
        [Parameter()]           [Switch]    $ShowAPI
	)
Begin 
    {	Test-A9Connection -CLientType 'API' 
    }
Process 
    {	$body = @{}	
        $body["action"] = 1
        $Result = $null	
        $uri = "/tasks/" + $TaskID
        if ( $ShowAPI )
        {   $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body -whatif
            return
        } 
        $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
        if($Result.StatusCode -eq 200)
            {	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                return $Result		
            }
        else{	Write-Error "Failure:  While Cancelling the ongoing task : $TaskID " 
                return $Result.StatusDescription
            }
    }
}
