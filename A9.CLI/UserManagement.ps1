## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9UserConnection
{
<#
.SYNOPSIS
    Displays information about users who are currently connected (logged in) to the storage system.  
.DESCRIPTION
	Displays information about users who are currently connected (logged in) to the storage system.
.PARAMETER Current
	Shows all information about the current connection only.
.PARAMETER Detailed
	Specifies the more detailed information about the user connection.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object.  
.EXAMPLE
    PS:> Get-A9UserConnection

	Shows information about users who are currently connected (logged in) to the storage system.
.EXAMPLE
    PS:> Get-A9UserConnection -Current

	Shows all information about the current connection only.
.EXAMPLE
    PS:> Get-A9UserConnection -Detailed

	Specifies the more detailed information about the user connection
.NOTES
	This command utilizes the SSH command 'showuserconn'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Current ,		
		[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[Switch]	$ShowRaw 
	)
Begin
{ Test-A9Connection -CLientType 'SshClient'
}
process	
{	$cmd2 = "showuserconn "
	if ($Current)	{	$cmd2 += " -current " }
	if ($Detailed)	{	$cmd2 += " -d "	}
	$result = Invoke-A9CLICommand -cmds  $cmd2
	if (-not $ShowRaw -and -not $Detailed)
		{	$tempFile = [IO.Path]::GetTempFileName()
			Add-Content -Path $tempFile -Value "Id,Name,IP_Addr,Role,Connected_since_Date,Connected_since_Time,Connected_since_TimeZone,Current,Client,ClientName"
			foreach($s in $result[1..($result.count - 3)])
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempFile -Value $s
				}
			$Result = Import-CSV $tempFile
			remove-item $tempFile
		}
	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	return $Result
}
}

Function Remove-A9UserConnection
{
<#
.SYNOPSIS
    Removes a session of a currently connected (logged in) user.  
.DESCRIPTION
    Removes a session of a currently connected (logged in) user. Use the command Get-A9UserConnection to gather this information.
.PARAMETER id
	a number such as 1234
.PARAMETER userName
	The username for whom the session is being disconnected
.PARAMETER IPAddress
	An IP Address of the user such as 192.168.10.42
.EXAMPLE
    PS:> Remove-A9UserConnection -userID 8347247 -useranme MyAdmin -IPAddress 192.168.100.44

.NOTES
	This command utilizes the SSH command 'removewsapisession', 'removeuserconn'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(mandatory)]	[string]	$userID ,		
		[Parameter(mandatory)]	[string]	$userName,
		[Parameter(mandatory)]	[String]	$IPAddress 
	)
Begin
{ Test-A9Connection -CLientType 'SshClient'
}
process	
{	$cmd1 = "removewsapisession -f $userid $userName $IPAddress "
	$cmd2 = "removeuserconn -f $userid $userName $IPAddress "
						
try		{	write-verbose "About to execute the following command : $cmd2"
			$result = Invoke-A9CLICommand -cmds  $cmd2
			Write-verbose "Complete Command for SSH session closure."	
		}
catch	{ 	write-warning "SSH Command may have failed"
		 	$result | out-string
		}
try		{	write-verbose "About to execute the following command : $cmd1"
			$result = Invoke-A9CLICommand -cmds  $cmd1	
			Write-verbose "Complete Command for API session closure."	
		}
catch	{ 	write-warning "WSAPI Command may have failed" 
			$result | out-string
		}

}
}
