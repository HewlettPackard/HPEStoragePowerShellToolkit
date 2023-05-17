####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
##	File Name:		StorageFederation.psm1
##	Description: 	Storage Federation cmdlets 
##		
##	Created:		March 2020
##	Last Modified:	March 2020
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## FUNCTION Test-CLIObject
############################################################################################################################################
Function Test-CLIObject 
{
Param( 	
    [string]$ObjectType, 
	[string]$ObjectName ,
	[string]$ObjectMsg = $ObjectType, 
	$SANConnection = $global:SANConnection
	)

	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")
	{
		$IsObjectExisted = $false
	}
	return $IsObjectExisted
	
} # End FUNCTION Test-CLIObject

######################################################################################################################
## FUNCTION Join-Federation
######################################################################################################################
Function Join-Federation
{
<#
  .SYNOPSIS  
	The Join-Federation command makes the StoreServ system a member of the Federation identified by the specified name and UUID.
   
  .DESCRIPTION
	The Join-Federation command makes the StoreServ system a member
	of the Federation identified by the specified name and UUID.
   
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
	If the StoreServ system is already a member of a Federation, the option
	forcefully removes the system from the current Federation and makes it a
	member of the new Federation identified by the specified name and UUID.
 
  .PARAMETER Comment
	Specifies any additional textual information.

  .PARAMETER Setkv
	Sets or resets key/value pairs on the federation.
	<key> is a string of alphanumeric characters.
	<value> is a string of characters other than "=", "," or ".".

  .PARAMETER Setkvifnotset
	Sets key/value pairs on the federation if not already set.
	A key/value pair is not reset on a federation if it already
	exists.  If a key already exists, it is not treated as an error
	and the value is left as it is.

  .PARAMETER UUID
	Specifies the UUID of the Federation to be joined.

  .PARAMETER FedName
	Specifies the name of the Federation to be joined.

  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
	NAME: Join-Federation  
	LASTEDIT: March 2020
	KEYWORDS: Join-Federation
   
	.Link
		http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
[CmdletBinding()]
	param(
	
		[Parameter(Position=1, Mandatory=$false)]
		[Switch]
		$Force ,
	
		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$UUID ,
		
		[Parameter(Position=2, Mandatory=$false)]
		[System.String]
		$FedName ,
		
		[Parameter(Position=3, Mandatory=$false)]
		[System.String]
		$Comment ,
		
		[Parameter(Position=4, Mandatory=$false)]
		[System.String]
		$Setkv ,
		
		[Parameter(Position=5, Mandatory=$false)]
		[System.String]
		$Setkvifnotset ,
				
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Join-Federation - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Join-Federation since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Join-Federation since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	if($FedName )
	{	
		if($UUID )
		{
			$Cmd = "joinfed "
			
			if($Force)
			{
				$Cmd+= " -force "						
			}
			if($Comment)
			{
				$Cmd+= " -comment $Comment"						
			}
			if($Setkv)
			{
				$Cmd+= " -setkv $Setkv"						
			}
			if($Setkvifnotset)
			{
				$Cmd+= " -setkvifnotset $Setkvifnotset"						
			}
				
			$Cmd += " $UUID $FedName "
			#write-host "Command = 	$Cmd"
			$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
			write-debuglog "  Executing Join-Federation Command.--> " "INFO:" 
			return  "$Result"	
		}
		else
		{
			write-debugLog "UUID Not specified." "ERR:" 
			return "FAILURE : UUID Not specified."
		}
	}
	else
	{
		write-debugLog "Federation Name Not specified ." "ERR:" 
		return "FAILURE : Federation Name Not specified"
	}
} ##  End-of  Join-Federation 

######################################################################################################################
## FUNCTION New-Federation
######################################################################################################################
Function New-Federation
{
<#
  .SYNOPSIS
   The New-Federation command generates a UUID for the named Federation and makes the StoreServ system a member of that Federation.
   
  .DESCRIPTION
   The New-Federation command generates a UUID for the named Federation
    and makes the StoreServ system a member of that Federation.
   
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
	Sets or resets key/value pairs on the federation.
	<key> is a string of alphanumeric characters.
	<value> is a string of characters other than "=", "," or ".".

  .PARAMETER Setkvifnotset
	Sets key/value pairs on the federation if not already set.
	A key/value pair is not reset on a federation if it already
	exists.
		
  .PARAMETER Fedname
	Specifies the name of the Federation to be created.
	The name must be between 1 and 31 characters in length
	and must contain only letters, digits, or punctuation
	characters '_', '-', or '.'
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME: New-Federation  
    LASTEDIT: March 2020
    KEYWORDS: New-Federation 
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$Fedname ,
		
		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$Comment ,
		
		[Parameter(Position=2, Mandatory=$false)]
		[System.String]
		$Setkv ,
		
		[Parameter(Position=3, Mandatory=$false)]
		[System.String]
		$Setkvifnotset ,
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In New-Federation - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting New-Federation since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet New-Federation since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	if($Fedname)
	{		
		$cmd = "createfed"
		
		if($Comment)
		{
			$cmd+= " -comment $Comment"						
		}
		if($Setkv)
		{
			$cmd+= " -setkv $Setkv"						
		}
		if($Setkvifnotset)
		{
			$cmd+= " -setkvifnotset $Setkvifnotset"						
		}
		
		$cmd += " $Fedname"
		$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
		write-debuglog "  Executing New-Federation Command.--> " "INFO:" 
		return  "$Result"				
	}
	else
	{
		write-debugLog "No Federation Name specified ." "ERR:" 
		return "FAILURE : No Federation name specified"
	}
} ##  End-of  New-Federation

######################################################################################################################
## FUNCTION Set-Federation
######################################################################################################################
Function Set-Federation
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
	Sets or resets key/value pairs on the federation.
	<key> is a string of alphanumeric characters.
	<value> is a string of characters other than "=", "," or ".".

  .PARAMETER Setkvifnotset
	Sets key/value pairs on the federation if not already set.
	A key/value pair is not reset on a federation if it already
	exists.  If a key already exists, it is not treated as an error
	and the value is left as it is.

  .PARAMETER ClrallKeys
		Clears all key/value pairs on the federation.

  .PARAMETER ClrKey
	Clears key/value pairs, regardless of the value.
	If a specified key does not exist, this is not
	treated as an error.

  .PARAMETER ClrKV
	Clears key/value pairs only if the value matches the given key.
	Mismatches or keys that do not exist are not treated as errors.

  .PARAMETER IfKV
	Checks whether given key/value pairs exist. If not, any subsequent
	key/value options on the command line will be ignored for the
	federation.
			
  .PARAMETER FedName
	 Specifies the new name of the Federation.
		 
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
	NAME: Set-Federation  
	LASTEDIT: March 2020
	KEYWORDS: Set-Federation

	.Link
		http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
[CmdletBinding()]
	param(		
		
		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$FedName ,
		
		[Parameter(Position=2, Mandatory=$false)]
		[System.String]
		$Comment ,
		
		[Parameter(Position=3, Mandatory=$false)]
		[System.String]
		$Setkv ,	
		
		[Parameter(Position=4, Mandatory=$false)]
		[System.String]
		$Setkvifnotset ,
		
		[Parameter(Position=5, Mandatory=$false)]
		[switch]
		$ClrAllKeys ,
		
		[Parameter(Position=6, Mandatory=$false)]
		[System.String]
		$ClrKey ,
		
		[Parameter(Position=7, Mandatory=$false)]
		[System.String]
		$ClrKV ,
		
		[Parameter(Position=8, Mandatory=$false)]
		[System.String]
		$IfKV ,
				
		[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Set-Federation - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Set-Federation since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Set-Federation since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}		
	
	$cmd = "setfed"	

	if($FedName)
	{
		$cmd += " -name $FedName "	
	}
	if($Comment)
	{
		$cmd += " -comment $Comment "	
	}
	if($Setkv)
	{
		$cmd += " -setkv $Setkv "	
	}
	if($Setkvifnotset)
	{
		$cmd += " -setkvifnotset $Setkvifnotset "	
	}
	if($ClrAllKeys)
	{
		$cmd += "  -clrallkeys "	
	}
	if($ClrKey)
	{
		$cmd += " -clrkey $ClrKey "	
	}
	if($ClrKV)
	{
		$cmd += " -clrkv $ClrKV "	
	}
	if($IfKV)
	{
		$cmd += " -ifkv $IfKV "	
	}
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog "  Executing Set-Federation Command.-->  " "INFO:" 
	if([string]::IsNullOrEmpty($Result))
	{
		return "Success : Set-Federation command executed successfully."
	}
	else
	{
		return $Result
	}
	
} ##  End-of  Set-Federation 


######################################################################################################################
## FUNCTION Remove-Federation
######################################################################################################################
Function Remove-Federation
{
<#
  .SYNOPSIS
	The Remove-Federation command removes the StoreServ system from Federation membership.
   
  .DESCRIPTION 
	The Remove-Federation command removes the StoreServ system from Federation membership.
   
  .EXAMPLE	
	Remove-Federation	
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
	NAME: Remove-Federation  
	LASTEDIT: March 2020
	KEYWORDS: Remove-Federation
   
	.Link
		http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
[CmdletBinding()]
	param(	
		[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Remove-Federation - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Remove-Federation since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Remove-Federation since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}	
	$cmd = " removefed -f"
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog "  Executing Remove-Federation Command.-->  " "INFO:" 
	return  "$Result"				
	
} ##  End-of  Remove-Federation 

######################################################################################################################
## FUNCTION Show-Federation
######################################################################################################################
Function Show-Federation
{
<#
  .SYNOPSIS 
	The Show-Federation command displays the name, UUID, and comment of the Federation of which the StoreServ system is member.
   
  .DESCRIPTION 
	The Show-Federation command displays the name, UUID, and comment
	of the Federation of which the StoreServ system is member.
   
  .EXAMPLE	
	Show-Federation	
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
	NAME: Show-Federation  
	LASTEDIT: March 2020
	KEYWORDS: Show-Federation

	.Link
		http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
[CmdletBinding()]
	param(	
		[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Show-Federation - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Show-Federation since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Show-Federation since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}	
	$cmd = " showfed"
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog "  Executing Show-Federation Command.--> " "INFO:"
	$tempFile = [IO.Path]::GetTempFileName()
	$LastItem = $Result.Count  
	#Write-Host " Result Count =" $Result.Count
	foreach ($s in  $Result[0..$LastItem] )
	{		
		$s= [regex]::Replace($s,"^ ","")			
		$s= [regex]::Replace($s," +",",")	
		$s= [regex]::Replace($s,"-","")
		$s= $s.Trim() 	
		Add-Content -Path $tempFile -Value $s
		#Write-Host	" First if statement $s"		
	}
	Import-Csv $tempFile 
	del $tempFile
	if($Result -match "Name")
	{	
		return  " Success : Executing Show-Federation "		
	}
	else
	{
		return $Result		 		
	}		
	
} ##  End-of  Show-Federation 

Export-ModuleMember Join-Federation , New-Federation , Remove-Federation , Set-Federation , Show-Federation
# SIG # Begin signature block
# MIIhEQYJKoZIhvcNAQcCoIIhAjCCIP4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBXOWF/YQpJuPxd
# rtp3CvEJac9Q/C4pzqa+S9syB66lCaCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPvDCCD7gCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# k2MlnMxlglHa1tbLGnnbCinMKaxUNVfxqITKYuqYffkwDQYJKoZIhvcNAQEBBQAE
# ggEATu+jVPVhwaBILVJjGwSBk1Cvu3XZOyn2vL/ljII630ZOpxviALDvyKRLR0W1
# 6YJPvosWP4eBbUD1S0UO2IHD48rgNCQ/BykmfSOa8laAQRlufPZUQavSX3EZC1j4
# mDkinmaACuM+kM+F3VBDxAhaCOIT1sh3GnFTTjW2Hw95VuMCzP0nlCZs+YUfKwJ9
# EK9KAcY7Wgye7d/3tH7oeeNCbHU53JR3It/EsRjnALGa/h0AkQoLMnx09PIdB2lG
# N9uvFKXfIirW7X+GvQDNxpqcYQg8k45t7A2g9alPVASJKUZEpdg88Z8sqbzZepGb
# KKiqtj9eIIpI0pCkEkVi0EjSN6GCDX4wgg16BgorBgEEAYI3AwMBMYINajCCDWYG
# CSqGSIb3DQEHAqCCDVcwgg1TAgEDMQ8wDQYJYIZIAWUDBAIBBQAweAYLKoZIhvcN
# AQkQAQSgaQRnMGUCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCBKZC8I
# PlKyNwbWf81QYN56kwiC16BhXkIXhu4D81SD+AIRANoGexyCr+ZsFdIMuyBgV6AY
# DzIwMjEwNjE5MDQyNDU5WqCCCjcwggT+MIID5qADAgECAhANQkrgvjqI/2BAIc4U
# APDdMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERp
# Z2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwHhcNMjEwMTAx
# MDAwMDAwWhcNMzEwMTA2MDAwMDAwWjBIMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIx
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwuZhhGfFivUNCKRFymNr
# Udc6EUK9CnV1TZS0DFC1JhD+HchvkWsMlucaXEjvROW/m2HNFZFiWrj/ZwucY/02
# aoH6KfjdK3CF3gIY83htvH35x20JPb5qdofpir34hF0edsnkxnZ2OlPR0dNaNo/G
# o+EvGzq3YdZz7E5tM4p8XUUtS7FQ5kE6N1aG3JMjjfdQJehk5t3Tjy9XtYcg6w6O
# LNUj2vRNeEbjA4MxKUpcDDGKSoyIxfcwWvkUrxVfbENJCf0mI1P2jWPoGqtbsR0w
# wptpgrTb/FZUvB+hh6u+elsKIC9LCcmVp42y+tZji06lchzun3oBc/gZ1v4NSYS9
# AQIDAQABo4IBuDCCAbQwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwQQYDVR0gBDowODA2BglghkgBhv1sBwEwKTAn
# BggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMB8GA1UdIwQY
# MBaAFPS24SAd/imu0uRhpbKiJbLIFzVuMB0GA1UdDgQWBBQ2RIaOpLqwZr68KC0d
# RDbd42p6vDBxBgNVHR8EajBoMDKgMKAuhixodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vc2hhMi1hc3N1cmVkLXRzLmNybDAyoDCgLoYsaHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmwwgYUGCCsGAQUFBwEBBHkwdzAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME8GCCsGAQUFBzAChkNo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNzdXJlZElE
# VGltZXN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IBAQBIHNy16ZojvOca
# 5yAOjmdG/UJyUXQKI0ejq5LSJcRwWb4UoOUngaVNFBUZB3nw0QTDhtk7vf5EAmZN
# 7WmkD/a4cM9i6PVRSnh5Nnont/PnUp+Tp+1DnnvntN1BIon7h6JGA0789P63ZHdj
# XyNSaYOC+hpT7ZDMjaEXcw3082U5cEvznNZ6e9oMvD0y0BvL9WH8dQgAdryBDvjA
# 4VzPxBFy5xtkSdgimnUVQvUtMjiB2vRgorq0Uvtc4GEkJU+y38kpqHNDUdq9Y9Yf
# W5v3LhtPEx33Sg1xfpe39D+E68Hjo0mh+s6nv1bPull2YYlffqe0jmd4+TaY4cso
# 2luHpoovMIIFMTCCBBmgAwIBAgIQCqEl1tYyG35B5AXaNpfCFTANBgkqhkiG9w0B
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTYwMTA3MTIwMDAwWhcNMzEwMTA3MTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# VGltZXN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# vdAy7kvNj3/dqbqCmcU5VChXtiNKxA4HRTNREH3Q+X1NaH7ntqD0jbOI5Je/YyGQ
# mL8TvFfTw+F+CNZqFAA49y4eO+7MpvYyWf5fZT/gm+vjRkcGGlV+Cyd+wKL1oODe
# Ij8O/36V+/OjuiI+GKwR5PCZA207hXwJ0+5dyJoLVOOoCXFr4M8iEA91z3FyTgqt
# 30A6XLdR4aF5FMZNJCMwXbzsPGBqrC8HzP3w6kfZiFBe/WZuVmEnKYmEUeaC50ZQ
# /ZQqLKfkdT66mA+Ef58xFNat1fJky3seBdCEGXIX8RcG7z3N1k3vBkL9olMqT4Ud
# xB08r8/arBD13ays6Vb/kwIDAQABo4IBzjCCAcowHQYDVR0OBBYEFPS24SAd/imu
# 0uRhpbKiJbLIFzVuMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMBIG
# A1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqg
# OKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMFAGA1UdIARJMEcwOAYKYIZIAYb9bAACBDAq
# MCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAsGCWCG
# SAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAQEAcZUS6VGHVmnN793afKpjerN4zwY3
# QITvS4S/ys8DAv3Fp8MOIEIsr3fzKx8MIVoqtwU0HWqumfgnoma/Capg33akOpMP
# +LLR2HwZYuhegiUexLoceywh4tZbLBQ1QwRostt1AuByx5jWPGTlH0gQGF+JOGFN
# YkYkh2OMkVIsrymJ5Xgf1gsUpYDXEkdws3XVk4WTfraSZ/tTYYmo9WuWwPRYaQ18
# yAGxuSh1t5ljhSKMYcp5lH5Z/IwP42+1ASa2bKXuh1Eh5Fhgm7oMLSttosR+u8Ql
# K0cCCHxJrhO24XxCQijGGFbPQTS2Zl22dHv1VjMiLyI2skuiSpXY9aaOUjGCAoYw
# ggKCAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0ECEA1CSuC+Ooj/YEAhzhQA8N0w
# DQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwG
# CSqGSIb3DQEJBTEPFw0yMTA2MTkwNDI0NTlaMCsGCyqGSIb3DQEJEAIMMRwwGjAY
# MBYEFOHXgqjhkb7va8oWkbWqtJSmJJvzMC8GCSqGSIb3DQEJBDEiBCDbVUfWE9RG
# Du0yheVKsFj5SnD7dwvaAlFZePR3DjUuHjA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCCzEJAGvArZgweRVyngRANBXIPjKSthTyaWTI01cez1qTANBgkqhkiG9w0BAQEF
# AASCAQCHzMEECTKlCnQ/NCIXslwwyQtBhWY8XUDcykMhYa011LcDXe/PFdYN5XGO
# q/56PveGlbaqlRRjnDUVF32HvYBHqCL0rVICSNNNB5gu9hcjnme7UpO3vxF1WZJz
# ohyMXKjfGJQhfNKxt0x+jH+ufFONjMRnUtU+ptuaYy1nJ5H+NMGo5+2Zy83FzuL1
# dFY9xUoiDFwsdoW6qbgz0PLMv6bNTrFi1c3pcQgn8Fz+OwTFXfBgVoqhXH31zQho
# ryUlLeynpbA/u8RTcvVV+w3MArYSsVa0lCwdssULHX5wTmw23pN5IwZkYZkGPR1P
# pFFFx1VSP3WQkns+4c9i/WNcZvr0
# SIG # End signature block
