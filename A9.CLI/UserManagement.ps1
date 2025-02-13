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
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning object. 
.NOTES
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
	if ($Detailed)	{	$cmd2 += " -d "
						$result = Invoke-A9CLICommand -cmds  $cmd2
						return $result
					}
	$result = Invoke-A9CLICommand -cmds  $cmd2
}
End
{	if (-not $ShowRaw)
		{	$tempFile = [IO.Path]::GetTempFileName()
			Add-Content -Path $tempFile -Value "Id,Name,IP_Addr,Role,Connected_since_Date,Connected_since_Time,Connected_since_TimeZone,Current,Client,ClientName"
			foreach($s in $result[1..($result.count - 3)])
				{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempFile -Value $s
				}
			$Result = Import-CSV $tempFile
			remove-item $tempFile
		}
	return $Result

}
}

