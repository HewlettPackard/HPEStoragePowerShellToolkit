## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9UserConnection
{
<#
.SYNOPSIS
    Displays information about users who are currently connected (logged in) to the storage system.  
.DESCRIPTION
	Displays information about users who are currently connected (logged in) to the storage system.
	Note that this command always shows detailed data.
.PARAMETER Current
	Shows all information about the current connection only.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object.  
.EXAMPLE
    PS:> Get-A9UserConnection

	Shows information about users who are currently connected (logged in) to the storage system.
.EXAMPLE
    PS:> Get-A9UserConnection 

	Shows all information about the current connection only.
.EXAMPLE
    PS:> Get-A9UserConnection -current

	Specifies the more detailed information about the user connection
.NOTES
	This command utilizes the SSH command 'showuserconn'
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Current ,
		[Parameter()]	[Switch]	$ShowRaw 
	)
Begin
{ Test-A9Connection -CLientType 'SshClient'
}
process	
{	$cmd2 = "showuserconn "
	if ($Current)	{	$cmd2 += " -current " }
	$cmd2 += " -d "
	$Result = Invoke-A9CLICommand -cmds  $cmd2
	if (-not $ShowRaw)
		{	$InRecord=$False
			$RecordCollection = @()
			foreach($s in $result[0..($result.count - 1)])
				{	$t = ($s.split(':')).trim() 
					if ( $t.count -gt 1 )
						{	# This is for a line in the middle of a record, add more values to that single current record
							$Tname = $t[0].trim()
							$Tval = $t[1..$($t.count)] -join ':'
							$NewRecord+= @{$Tname = $Tval }
						}
					elseif ( $t.Contains('---Conn') ) 
						{	# This is the first line of an expected record, so create a new object for it. 
							$z=($t.split(' ')).trim('-')
							$Tname = $z[0]
							$Tval = $z[1]
							$NewRecord=@{$Tname = $Tval }
							$InRecord=$true
						}
					elseif ($InRecord -eq $true )
						{	# This line is if the line being processed is blank, and a record is in progres of being made...close the current record and add it to the record collection
							$RecordCollection += ,$Newrecord
							$InRecord=$false
						}
										
				}
			$Result = $RecordCollection
			$Result = $Result | convertto-json | convertfrom-json
			$NewObj = @(    foreach( $Item in $Result)	
                                        {   $NewItem=@{PSTypeName = "HPE.A9Storage.UserConnection"}
                                            $Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
											$DataSetType = "HPE.A9Storage.UserConnection"
											$NewItem.PSTypeNames.Insert(0,$DataSetType)
											$DataSetType = $DataSetType + ".TypeName"
											$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
											[PSCustomObject]$NewItem
										}
						            )
			$Result = $NewObj
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
						
try		{	$result = Invoke-A9CLICommand -cmds  $cmd2
			Write-verbose "Complete Command for SSH session closure."	
		}
catch	{ 	write-warning "SSH Command may have failed"
		 	$result | out-string
		}
try		{	$result = Invoke-A9CLICommand -cmds  $cmd1	
			Write-verbose "Complete Command for API session closure."	
		}
catch	{ 	write-warning "WSAPI Command may have failed" 
			$result | out-string
		}
}
}
