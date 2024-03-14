####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##


Function Get-UserConnection
{
<#
.SYNOPSIS
    Displays information about users who are currently connected (logged in) to the storage system.  
.DESCRIPTION
	Displays information about users who are currently connected (logged in) to the storage system.
.EXAMPLE
    Get-UserConnection  
	Shows information about users who are currently connected (logged in) to the storage system.
.EXAMPLE
    Get-UserConnection   -Current
	Shows all information about the current connection only.
.EXAMPLE
    Get-UserConnection   -Detailed
	Specifies the more detailed information about the user connection
.PARAMETER Current
	Shows all information about the current connection only.
.PARAMETER Detailed
	Specifies the more detailed information about the user connection.
.PARAMETER SANConnection 
    Specify the SAN Connection object created with New-PoshSshConnection or New-CLIConnection
#Requires HPE 3par cli.exe 
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$Current ,		
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Detailed 
	)
process	
{	if ( -not $(Test-A9CLI) ) 	{	return }
	$cmd2 = "showuserconn "
	if ($Current)	{	$cmd2 += " -current " }
	if($Detailed)	{	$cmd2 += " -d "
						$result = Invoke-CLICommand -cmds  $cmd2
						return $result
					}
	$result = Invoke-CLICommand -cmds  $cmd2
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

Function Set-Password
{
<#
.SYNOPSIS
	Creates a encrypted password file on client machine
.DESCRIPTION
	Creates a encrypted password file on client machine
.EXAMPLE
    Set-Password -CLIDir "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin" -ArrayNameOrIPAddress "15.212.196.218"  -epwdFile "C:\HPE3paradmepwd.txt"	
	This examples stores the encrypted password file HPE3paradmepwd.txt on client machine c:\ drive, subsequent commands uses this encryped password file 
.PARAMETER ArrayNameOrIPAddress 
    Specify the SAN IP address.
.PARAMETER CLIDir 
    Specify the absolute path of HPE 3par cli.exe. Default is "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin"
.PARAMETER epwdFile 
    Specify the file location to create encrypted password file
#Requires HPE 3par cli.exe 
#>
[CmdletBinding()]
param(	[Parameter()]					[String]	$CLIDir="C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter(Mandatory=$true)]	[String]	$ArrayNameOrIPAddress=$null,
		[Parameter(Mandatory=$true)]	[String]	$epwdFile ="C:\HPE3parepwdlogin.txt"
)	
process
{	if( Test-Path $epwdFile)	{	Write-verbose "Running: Encrypted password file found. It will be overwritten" }	
	$passwordFile = $epwdFile	
	$cmd1 = $CLIDir+"\setpassword.bat" 
	& $cmd1 -saveonly -sys $ArrayNameOrIPAddress -file $passwordFile
	if(!($?	))
		{	Write-error "STOP: CLI directory path not founf or system is not accessible or the commands.bat file path not configured properly " 
			return "`nFailure : FATAL ERROR"
		}
	$global:epwdFile = $passwordFile
	return "Success : The encrypted password file is successfully created and the file is located in $passwordfile "
}
}
