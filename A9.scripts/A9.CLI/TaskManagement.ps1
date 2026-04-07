## 	©2025 Hewlett Packard Enterprise Development LP

Function Remove-A9Task
{
<#
.SYNOPSIS
    Remove one or more tasks or task details.                                                                                                           .
.DESCRIPTION
    The Remove-Task command removes information about one or more completed tasks
    and their details.  With this command, the specified task ID and any information associated with it are removed from the system. However, task IDs are not recycled, so the
    next task started on the system uses the next whole integer that has not already been used. Task IDs roll over at 29999. The system stores
    information for the most recent 2000 tasks.

    - With this command, the specified task ID and any information associated with it are removed from the system. However, task IDs are not recycled, so the next task 
    started on the system uses the next whole integer that has not already been used. Task IDs roll over at 29999. The system stores information for the most recent 2,000 tasks.
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
	This command utilizes the SSH command 'removetask'
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
.PARAMETER WaitForTaskCompletition
  This option will query the status of a task, and only return once that task is completed
.EXAMPLE
  The following example shows how to wait for a task using the task ID. When successful, the command returns only after the task completes.
  
  PS:> Set-A9Task -TaskID 1234 -Priority high 
.EXAMPLE
  The following example shows how to wait for a task using the task ID. When successful, the command returns only after the task completes.
  
  PS:> Set-A9Task -TaskID 1234 -WaitForTaskCompletion
  Task 13492 done

.NOTES
	This command utilizes the SSH command 'settask', 'waittask'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  [Parameter(mandatory,parametersetname='wait')]
        [Parameter(mandatory,parametersetname='set')]   [String]  $TaskID,
        [Parameter(mandatory,parametersetname='set')]   
        [ValidateSet('high','med','low','auto')]        [String]  $Priority,
        [Parameter(mandatory,parametersetname='wait')]  [Switch]  $WaitForTaskCompletion   
    )	
Begin
  { Test-A9Connection -ClientType 'SshClient'
  }
process	
  { if ($Priority)              { $cmd = "settask -f -pri $Priority $TaskID"  } 
    if ($WaitForTaskCompletion) { $cmd = "waittask $TaskID"  }
    $Result = Invoke-A9CLICommand -cmds  $cmd
    return $Result
  }
} 

