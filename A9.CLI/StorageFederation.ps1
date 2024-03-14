####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Join-A9Federation_CLI
{
<#
.SYNOPSIS  
	The Join-Federation command makes the StoreServ system a member of the Federation identified by the specified name and UUID.
.DESCRIPTION
	The Join-Federation command makes the StoreServ system a member of the Federation identified by the specified name and UUID.
.EXAMPLE
	Join-Federation -FedName test -UUID 12345
.EXAMPLE
	Join-Federation -Comment hello -UUID 12345
.EXAMPLE
	Join-Federation -Comment hello -UUID 12345 -FedName test
.EXAMPLE
	Join-Federation -Setkv 10 -UUID 12345 -FedName test
.EXAMPLE
	Join-Federation -Setkvifnotset 20  -UUID 12345 -FedName test
.PARAMETER Force
	If the StoreServ system is already a member of a Federation, the option forcefully removes the system from the current Federation and makes it a
	member of the new Federation identified by the specified name and UUID.
.PARAMETER Comment
	Specifies any additional textual information.
.PARAMETER Setkv
	Sets or resets key/value pairs on the federation. <key> is a string of alphanumeric characters. <value> is a string of characters other than "=", "," or ".".
.PARAMETER Setkvifnotset
	Sets key/value pairs on the federation if not already set. A key/value pair is not reset on a federation if it already
	exists.  If a key already exists, it is not treated as an error and the value is left as it is.
.PARAMETER UUID
	Specifies the UUID of the Federation to be joined.
.PARAMETER FedName
	Specifies the name of the Federation to be joined.
#>
[CmdletBinding()]
param(	[Parameter()]	[Switch]	$Force ,
		[Parameter()]	[String]	$UUID ,
		[Parameter()]	[String]	$FedName ,
		[Parameter()]	[String]	$Comment ,
		[Parameter()]	[String]	$Setkv ,
		[Parameter()]	[String]	$Setkvifnotset 
)		
Begin
{	Test-A9CLIConnection
}
Process
{	if($FedName )
		{	if($UUID )
				{	$Cmd = "joinfed "
					if($Force)	{	$Cmd+= " -force "	}
					if($Comment){	$Cmd+= " -comment $Comment"	}
					if($Setkv)	{	$Cmd+= " -setkv $Setkv"		}
					if($Setkvifnotset)	{	$Cmd+= " -setkvifnotset $Setkvifnotset"	}			
					$Cmd += " $UUID $FedName "
					$Result = Invoke-CLICommand -cmds  $Cmd
					return  "$Result"	
				}
			else{	return "FAILURE : UUID Not specified."	}
		}
	else	{	return "FAILURE : Federation Name Not specified"	}
}
}

Function New-A9Federation_CLI
{
<#
.SYNOPSIS
	The New-Federation command generates a UUID for the named Federation and makes the StoreServ system a member of that Federation.
.DESCRIPTION
	The New-Federation command generates a UUID for the named Federation and makes the StoreServ system a member of that Federation.
.EXAMPLE
	New-Federation -Fedname XYZ
.EXAMPLE
	New-Federation –CommentString XYZ -Fedname XYZ
.EXAMPLE
	New-Federation -Setkv TETS -Fedname XYZ
.EXAMPLE
	New-Federation -Setkvifnotset TETS -Fedname XYZ
.PARAMETER comment
	Specifies any additional textual information.
.PARAMETER Setkv 
	Sets or resets key/value pairs on the federation. <key> is a string of alphanumeric characters. <value> is a string of characters other than "=", "," or ".".
.PARAMETER Setkvifnotset
	Sets key/value pairs on the federation if not already set. A key/value pair is not reset on a federation if it already exists.
.PARAMETER Fedname
	Specifies the name of the Federation to be created. The name must be between 1 and 31 characters in length
	and must contain only letters, digits, or punctuation characters '_', '-', or '.'
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$Fedname ,
		[Parameter()]	[String]	$Comment ,
		[Parameter()]	[String]	$Setkv ,
		[Parameter()]	[String]	$Setkvifnotset
)		
Begin
{	Test-A9CLIConnection
}
Process	
{	$cmd = "createfed"
	if($Comment)	{	$cmd+= " -comment $Comment" }
	if($Setkv)		{	$cmd+= " -setkv $Setkv"		}
	if($Setkvifnotset){	$cmd+= " -setkvifnotset $Setkvifnotset"	}
	$cmd += " $Fedname"
	$Result = Invoke-CLICommand -cmds  $cmd
	return  "$Result"				
}
}

Function Set-A9Federation_CLI
{
<#
.SYNOPSIS
	The Set-Federation command modifies name, comment, or key/value attributes of the Federation of which the StoreServ system is member.
.DESCRIPTION 
	The Set-Federation command modifies name, comment, or key/value attributes of the Federation of which the StoreServ system is member.
.EXAMPLE
	Set-Federation -FedName test
.EXAMPLE
	Set-Federation -Comment hello
.EXAMPLE
	Set-Federation -ClrAllKeys
.EXAMPLE
	Set-Federation -Setkv 1
.PARAMETER Comment
	Specifies any additional textual information.
.PARAMETER Setkv
	Sets or resets key/value pairs on the federation. <key> is a string of alphanumeric characters. <value> is a string of characters other than "=", "," or ".".
.PARAMETER Setkvifnotset
	Sets key/value pairs on the federation if not already set. A key/value pair is not reset on a federation if it already
	exists.  If a key already exists, it is not treated as an error and the value is left as it is.
.PARAMETER ClrallKeys
	Clears all key/value pairs on the federation.
.PARAMETER ClrKey
	Clears key/value pairs, regardless of the value. If a specified key does not exist, this is not treated as an error.
.PARAMETER ClrKV
	Clears key/value pairs only if the value matches the given key. Mismatches or keys that do not exist are not treated as errors.
.PARAMETER IfKV
	Checks whether given key/value pairs exist. If not, any subsequent key/value options on the command line will be ignored for the federation.
.PARAMETER FedName
	Specifies the new name of the Federation.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$FedName ,
		[Parameter()]	[String]	$Comment ,
		[Parameter()]	[String]	$Setkv ,	
		[Parameter()]	[String]	$Setkvifnotset ,
		[Parameter()]	[switch]	$ClrAllKeys ,
		[Parameter()]	[String]	$ClrKey ,
		[Parameter()]	[String]	$ClrKV ,
		[Parameter()]	[String]	$IfKV 
)		
Begin
{	Test-A9CLIConnection
}
Process
{	$cmd = "setfed"	
	if($FedName)	{	$cmd += " -name $FedName "		}
	if($Comment)	{	$cmd += " -comment $Comment "	}
	if($Setkv)		{	$cmd += " -setkv $Setkv "		}
	if($Setkvifnotset){	$cmd += " -setkvifnotset $Setkvifnotset "}
	if($ClrAllKeys)	{	$cmd += "  -clrallkeys "		}
	if($ClrKey)		{	$cmd += " -clrkey $ClrKey "		}
	if($ClrKV)		{	$cmd += " -clrkv $ClrKV "		}
	if($IfKV)		{	$cmd += " -ifkv $IfKV "			}
	$Result = Invoke-CLICommand -cmds  $cmd
	if([string]::IsNullOrEmpty($Result))	{	return "Success : Set-Federation command executed successfully."}
	else									{	return $Result	}	
}
}

Function Remove-A9Federation_CLI
{
<#
.SYNOPSIS
	The Remove-Federation command removes the StoreServ system from Federation membership.
.DESCRIPTION 
	The Remove-Federation command removes the StoreServ system from Federation membership.
.EXAMPLE	
	Remove-Federation	
#>
[CmdletBinding()]
param()		
Begin
{	Test-A9CLIConnection
}
Process
{	$cmd = " removefed -f"
	$Result = Invoke-CLICommand -cmds  $cmd
	return  "$Result"				
}
}

Function Show-A9Federation_CLI
{
<#
.SYNOPSIS 
	The Show-Federation command displays the name, UUID, and comment of the Federation of which the StoreServ system is member.
.DESCRIPTION 
	The Show-Federation command displays the name, UUID, and comment
	of the Federation of which the StoreServ system is member.
.EXAMPLE	
	Show-Federation	
#>
[CmdletBinding()]
param()		
Begin
{	Test-A9CLIConnection
}
Process
{	$cmd = " showfed"
	$Result = Invoke-CLICommand -cmds  $cmd
	write-verbose "  Executing Show-Federation Command.--> "
	$tempFile = [IO.Path]::GetTempFileName()
	$LastItem = $Result.Count  
	#Write-Host " Result Count =" $Result.Count
	foreach ($s in  $Result[0..$LastItem] )
		{	$s= [regex]::Replace($s,"^ ","")			
			$s= [regex]::Replace($s," +",",")	
			$s= [regex]::Replace($s,"-","")
			$s= $s.Trim() 	
			Add-Content -Path $tempFile -Value $s
		}
	Import-Csv $tempFile 
	Remove-Item  $tempFile
	if($Result -match "Name")	{	return  " Success : Executing Show-Federation "	}
	else						{	return $Result		}		
}
} 
