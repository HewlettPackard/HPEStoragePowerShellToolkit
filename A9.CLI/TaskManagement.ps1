####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Remove-A9Task
{
<#
.SYNOPSIS
    Remove one or more tasks or task details.                                                                                                           .
.DESCRIPTION
    The Remove-Task command removes information about one or more completed tasks
    and their details.
.PARAMETER All
    Remove all tasks including details.
.PARAMETER Details
    Remove task details only.
.PARAMETER Time <hours>
  Removes tasks that have not been active within the past <hours>, where <hours> is an integer from 1 through 99999.
.PARAMETER TaskID <int>
    Allows you to specify tasks to be removed using their task IDs.
.EXAMPLE
    Remove a task based on the task ID

    PS:> Remove-A9Task 2
.EXAMPLE
    Remove all tasks, including details

    PS:> Remove-A9Task -A
.NOTES
  With this command, the specified task ID and any information associated with it are removed from the system. However, task IDs are not recycled, so the
  next task started on the system uses the next whole integer that has not already been used. Task IDs roll over at 29999. The system stores
  information for the most recent 2000 tasks.
  Authority: Super, Edit
    Any role granted the task_remove right.
  Usage:
  - With this command, the specified task ID and any information associated with it are removed from the system. However, task IDs are not recycled, so the next task started on the system uses the next whole integer that has not already been used. Task IDs roll over at 29999. The system stores information for the most recent 2,000 tasks.
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  [Parameter(parametersetname='One')]   [String]   $TaskID,
        [Parameter(parametersetname='All')]   [Switch]   $All,
        [Parameter()]                         [Switch]   $Details,
        [Parameter(parametersetname='Time')]  [int]      $Time	
    )	
Begin
  { Test-A9Connection -CLientType 'SshClient'
  }
process	
  { $cmd = "removetask -f "	
    if ($TaskID)  {   $cmd += "$TaskID"	}
    if ($All)     {   $cmd += " -a"     }
    if ($Details) {   $cmd += " -d"		  }
    if ($Time)    {   $cmd += " -t $T"  }	
    $Result = Invoke-A9CLICommand -cmds  $cmd
    return 	$Result	
  }
}

Function Wait-A9Task
{
<#
.SYNOPSIS
  Wait for tasks to complete.
.DESCRIPTION
  The Wait Task cmdlet asks the CLI to wait for a task to complete before proceeding. The cmdlet automatically notifies you when the specified task is finished.
.PARAMETER Detailed
  Displays the detailed status of the task specified by <TaskID> as it executes. When the task completes, this command exits.
.PARAMETER TaskID
  Indicates one or more tasks to wait for using their task IDs. When no task IDs are specified, the command waits for all non-system tasks
  to complete. To wait for system tasks, <TaskID> must be specified.
.PARAMETER Quiet
  Quiet; do not report the end state of the tasks, only wait for them to exit.
.EXAMPLE
  The following example shows how to wait for a task using the task ID. When successful, the command returns only after the task completes.
  
  PS:> Wait-A9Task 1  
  Task 1 done      
.NOTES
	This command requires a SSH type connection.
  Authority: Any role in the system
#>
[CmdletBinding()]
param(  [Parameter(parametersetname='Loud',mandatory)]  [Switch]  $Detailed, 
        [Parameter(parametersetname='Loud',mandatory)] 
        [Parameter(parametersetname='Quiet',mandatory)] [String]  $TaskID,
        [Parameter(parametersetname='Quiet',mandatory)] [Switch]  $Quiet
    )	
Begin
  { Test-A9Connection -ClientType 'SshClient'
  }
process	
  { $cmd = "waittask "	
    if ($Detailed)  {  $cmd += " -v "	    }
    if ($TaskID)    {  $cmd += "$TaskID"  }
    if ($Quiet)     {  $cmd += " -q"		  }    	
    $Result = Invoke-A9CLICommand -cmds  $cmd
    return $Result
  }
} 

Function Set-A9Task
{
<#
.SYNOPSIS
  The settask command sets the priority on specified task.
.DESCRIPTION
  The settask command sets the priority on specified task.
.PARAMETER Priority <high|med|low|auto>
  Specifies the priority of the task.
.PARAMETER TaskID
  Indicates one or more tasks to modify using their task IDs. 
.EXAMPLE
  The following example shows how to wait for a task using the task ID. When successful, the command returns only after the task completes.
  
  PS:> Set-A9Task -TaskID 1234 -Priority high 
.NOTES
	This command requires a SSH type connection.
  Authority: Super, Edit
    Any role granted the task_set right.
  Usage:
  - Task priorities can only be set one at a time. If the specified task is not active or valid, attempting to set its priority will result in an error.
#>
[CmdletBinding()]
param(  [Parameter(mandatory)]                    [String]  $TaskID,
        [Parameter(mandatory)]   
        [ValidateSet('high','med','low','auto')]  [String]  $Priority
    )	
Begin
  { Test-A9Connection -ClientType 'SshClient'
  }
process	
  { $cmd = "settask -f  "	
    $cmd += " -pri $Priority "
    $cmd += "$TaskID"  
    $Result = Invoke-A9CLICommand -cmds $cmd
    return $Result
  }
} 
