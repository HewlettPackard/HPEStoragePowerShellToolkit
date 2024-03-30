####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9UserConnection
{
<#
.SYNOPSIS
    Displays information about users who are currently connected (logged in) to the storage system.  
.DESCRIPTION
	Displays information about users who are currently connected (logged in) to the storage system.
.EXAMPLE
    PS:> Get-A9UserConnection

	Shows information about users who are currently connected (logged in) to the storage system.
.EXAMPLE
    PS:> Get-A9UserConnection -Current

	Shows all information about the current connection only.
.EXAMPLE
    PS:> Get-A9UserConnection -Detailed

	Specifies the more detailed information about the user connection
.PARAMETER Current
	Shows all information about the current connection only.
.PARAMETER Detailed
	Specifies the more detailed information about the user connection.
.PARAMETER SANConnection 
    Specify the SAN Connection object created with New-PoshSshConnection or New-CLIConnection
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$Current ,		
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Detailed 
	)
Begin
{ Test-A9Connection -CLientType 'SshClient'
}
process	
{	$cmd2 = "showuserconn "
	if ($Current)	{	$cmd2 += " -current " }
	if($Detailed)	{	$cmd2 += " -d "
						$result = Invoke-A9CLICommand -cmds  $cmd2
						return $result
					}
	$result = Invoke-A9CLICommand -cmds  $cmd2
	$count = $result.count - 3
	$tempFile = [IO.Path]::GetTempFileName()
	Add-Content -Path $tempFile -Value "Id,Name,IP_Addr,Role,Connected_since_Date,Connected_since_Time,Connected_since_TimeZone,Current,Client,ClientName"
	foreach($s in $result[1..$count])
		{	$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			$s = $s.trim()
			Add-Content -Path $tempFile -Value $s
		}
	Import-CSV $tempFile
	remove-item $tempFile
}
}

