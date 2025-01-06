####################################################################################
## 	© 2024 Hewlett Packard Enterprise Development LP
##
# Contains the Following API/CLI joined commands
# Get-A9Task
# Stop-A9Task
#

Function Get-A9Task
{
<#
.SYNOPSIS
    Displays information about tasks.
.DESCRIPTION
    Displays information about tasks.
.EXAMPLE
    PS:> Get-A9Task
	
    Display all tasks. This will attempt to use the API if connected, and fail back to SSH if needed.
.EXAMPLE	
	PS:> Get-A9Task -taskID 4
	
    Show detailed task status for specified task 4. This will attempt to use the API if connected, and fail back to SSH if needed.
.EXAMPLE	
	PS:> Get-A9Task -taskID 4 -UseSSH
	
    Show detailed task status for specified task 4. This force the use SSH only.
.EXAMPLE
    PS:> Get-A9Task -All
	
    Display all tasks. Unless the -all option is specified, system tasks are not displayed.
.EXAMPLE		
	PS:> Get-A9Task -Done
	
    Display includes only tasks that are successfully completed
.EXAMPLE
	PS:> Get-A9Task -Failed

	Display includes only tasks that are unsuccessfully completed.
.EXAMPLE	
	PS:> Get-A9Task -Active
	
    Display includes only tasks that are currently in progress.
.EXAMPLE	
	PS:> Get-A9Task -Hours 10
	
    Show only tasks started within the past <hours>
.EXAMPLE	
	PS:> Get-A9Task -Task_type xyz
	
    Specifies that specified patterns are treated as glob-style patterns and that all tasks whose types match the specified pattern are displayed
.EXAMPLE	
	PS:> Get-A9Task -detailed -taskID 4
	
    Show detailed task status for specified task 4.
.PARAMETER All	
	Displays all tasks. This parameter is only available if using an SSH type connection
.PARAMETER Detailed
	Only value when speicfying a TaskID and gives detailed information about the task. This parameter is only available if using an SSH type connection
.PARAMETER Done	
	Displays only tasks that are successfully completed. This parameter is only available if using an SSH type connection
.PARAMETER Failed	
	Displays only tasks that are unsuccessfully completed. This parameter is only available if using an SSH type connection
.PARAMETER Active	
	Displays only tasks that are currently in progress. This parameter is only available if using an SSH type connection
.PARAMETER Hours 
    Show only tasks started within the past <hours>, where <hours> is an integer from 1 through 99999. This parameter is only available if using an SSH type connection
.PARAMETER Task_type 
    Specifies that specified patterns are treated as glob-style patterns and that all tasks whose types match the specified pattern are displayed. To see the different task types use the showtask column help.
    This parameter is only available if using an SSH type connection
.PARAMETER TaskID 
    Show detailed task status for specified tasks. Tasks must be explicitly specified using their task IDs <task_ID>. Multiple task IDs can be specified. This option cannot be used in conjunction with other options.
.NOTES
	This command requires a either a API or SSH type connection.
    Authority:Any role in the system
    Usage:
    - By default, showtask shows all non-system tasks that were active within the last 24 hours.
    - The system stores information for the most recent 2,000 tasks. Task ID numbers roll at 29999.
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	[Parameter(Parametersetname='API')]	
        [Parameter(Parametersetname='SSHOne')]  [String]	$TaskID, 
        [Parameter(parametersetname='SSHAll')]	[String]	$Task_type,
        [Parameter(parametersetname='SSHAll')]	[Switch]	$All,	
        [Parameter(parametersetname='SSHAll')]	[Switch]	$Done,
        [Parameter(parametersetname='SSHAll')]	[Switch]	$Failed,
        [Parameter(parametersetname='SSHAll')]	[Switch]	$Active,
        [Parameter(parametersetname='SSHAll')]	[int] 	    $Hours,
        [Parameter(Parametersetname='SSHOne')]	[String]	$Detailed,
        [Parameter(Parametersetname='SSHOne')]
        [Parameter(parametersetname='SSHAll')]	[Switch]	$UseSSH
        
        
	)		
Begin
    {   if ( $PSCmdlet.ParameterSetName -eq 'API' )
            {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                    {	$PSetName = 'API'
                    }
                else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                            {	$PSetName = 'SSH'
                            }
                    }
            }
        elseif ( ($PSCmdlet.ParameterSetName -eq 'SSHAll') -or ($PSCmdlet.ParameterSetName -eq 'SSHOne') )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process
    {	switch( $PSetName )
        {   
            'API'   {   $uri='/tasks'
                        if($TaskID)		{	$uri = $uri+'/'+$TaskID		}
                        $Result = Invoke-A9API -uri $uri -type 'GET' 
                        if($Result.StatusCode -eq 200)
                            {	$dataPS = $Result.content | ConvertFrom-Json
                                return $dataPS
                            }
                        else
                            {	Write-Error "Failure:  While Executing Get-Task_WSAPI." 
                                return $Result.StatusDescription
                            }
                    }
            'SSH'   {   $taskcmd = "showtask "	
                        if($Task_type){		$taskcmd +=" -type $Task_type "	}	
                        if($All)		  {		$taskcmd +=" -all "	}
                        if($Done)		  {		$taskcmd +=" -done "	}
                        if($Failed)		{		$taskcmd +=" -failed "	}
                        if($Active)		{		$taskcmd +=" -active "	}
                        if($Hours)		{		$taskcmd +=" -t $Hours "	}	
                        if($Detailed)	{		$taskcmd +=" -d "	}
                        if($TaskID)		{		$taskcmd +=" $TaskID "	}
                        $result = Invoke-A9CLICommand -cmds  $taskcmd
                        if($TaskID)	{	return $result	}	
                        if($Result -match "Id" )
                        { $tempFile = [IO.Path]::GetTempFileName()
                            $LastItem = $Result.Count  
                            $incre = "true"
                            foreach ($s in  $Result[0..$LastItem] )
                            { $s= [regex]::Replace($s,"^ ","")			
                                $s= [regex]::Replace($s," +",",")	
                                $s= [regex]::Replace($s,"-","")			
                                $s= $s.Trim() -replace 'StartTime,FinishTime','Date(ST),Time(ST),Zome(ST),Date(FT),Time(FT),Zome(FT)' 
                                if($incre -eq "true") { $s=$s.Substring(1)	}
                                Add-Content -Path $tempFile -Value $s
                                $incre="false"		
                            }
                            $returnresult = Import-Csv $tempFile 
                            remove-item $tempFile
                            return $returnresult
                        }	
                        if($Result -match "Id")	{	return}
                        else                    {	return  $Result	}	
                    }
        }
    }
}

Function Stop-A9Task 
{	
<#
.SYNOPSIS
    Cancel one or more tasks
.DESCRIPTION
    The Stop Task command cancels one or more tasks.
.PARAMETER ALL
    Cancels all active tasks. If not specified, a task ID(s) must be specified. The All option requires an SSH type connection.
.PARAMETER TaskID
    Cancels only tasks identified by their task IDs. TaskID must be an unsigned integer within 1-29999 range. If this is unset, then ALL must be set.
.EXAMPLE
    Cancel a task using the task ID

    PS:> Stop-A9Task 1        
.EXAMPLE
    Cancel all ongoing tasks using the all option

    PS:> Stop-A9Task -all        
.NOTES
    The Stop-Task command can return before a cancellation is completed. Thus, resources reserved for a task might not be immediately available. This can
    prevent actions like restarting the canceled task. Use the waittask command to ensure orderly completion of the cancellation before taking other
    actions. See waittask for more details.
    A Service user is only allowed to cancel tasks started by that specific user.
	This command will use the API if available, otherwise will default back to a SSH type connection.
    Authority:Super, Service, Edit
    Any role granted the task_cancel right
    Usage:
    - The canceltask command can return before a cancellation is completed. Thus, resources reserved for a task might not be immediately available. 
    This can prevent actions like restarting the canceled task. Use the waittask command to ensure orderly completion of the cancellation before taking other actions. 
    See waittask for more details.
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	[Parameter(ParameterSetName='API',Mandatory)]
        [Parameter(ParameterSetName='SSHONE',Mandatory)]    [String]	$TaskID,
        [Parameter(ParameterSetName='SSHALL',Mandatory)]    [String]    $All,	
        [Parameter(ParameterSetName='SSHONE',Mandatory)]    [Switch]    $UseSSH	
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
        elseif ( ($PSCmdlet.ParameterSetName -eq 'SSHAll') -or ($PSCmdlet.ParameterSetName -eq 'SSHONE') )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process 
    {	switch( $PSetName )
        {   'SSH'   {   $cmd = "canceltask -f "	
                        if ($TaskID){   $cmd += "$TaskID"		}
                        if ($All)   {   $cmd += " -all"		  }    	
                        $Result = Invoke-A9CLICommand -cmds  $cmd
                        return 	$Result	
                    }
            'API'   {   $body = @{}	
                        $body["action"] = 4
                        $Result = $null	
                        $uri = "/tasks/" + $TaskID
                        $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
                        if($Result.StatusCode -eq 200)
                            {	write-host "Cmdlet executed successfully" -foreground green
                                return $Result		
                            }
                        else
                            {	Write-Error "Failure:  While Cancelling the ongoing task : $TaskID " 
                                return $Result.StatusDescription
                            }
                    }
        }
    }
}
