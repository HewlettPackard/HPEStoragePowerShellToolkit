####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9FcPorts
{
<#
.SYNOPSIS
	Query to get FC ports
.DESCRIPTION
	Get information for FC Ports
.NOTES
	This command requires a SSH type connection.
#>

[CmdletBinding()]
Param()
Begin
{	Test-A9Connection -ClientType 'SshClient'
}	
Process
{	Write-host "Controller,WWN"	
	$ListofPorts = Get-A9HostPorts_cli | where-object { ( $_.Type -eq "host" ) -and ($_.Protocol -eq "FC")}
	$Port_Pattern = "(\d):(\d):(\d)"							# Pattern matches value of port: 1:2:3
	$WWN_Pattern = "([0-9a-f][0-9a-f])" * 8						# Pattern matches value of WWN
	foreach ($Port in $ListofPorts)
		{	$NSP  = $Port.Device
			$NSP = $NSP -replace $Port_Pattern , 'N$1:S$2:P$3'
			$WWN = $Port.Port_WWN
			$WWN = $WWN -replace $WWN_Pattern , '$1:$2:$3:$4:$5:$6:$7:$8'
			Write-Host "$NSP,$WWN"
		}
} 
}

Function Get-A9FcPortsToCsv
{
<#
.SYNOPSIS
	Query to get FC ports
.DESCRIPTION
	Get information for FC Ports
.PARAMETER ResultFile
	CSV file created that contains all Ports definitions
.PARAMETER Demo
	Switch to list the commands to be executed 
.EXAMPLE
    PS:> Get-A9FcPortsToCsv_CLI -ResultFile C:\3PAR-FC.CSV

	creates C:\3PAR-FC.CSV and stores all FCPorts information
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]$ResultFile	)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	if(!($ResultFile))	{	return "FAILURE : Please specify csv file path `n example: -ResultFIle C:\portsfile.csv"	}	
	Set-Content -Path $ResultFile -Value "Controller,WWN,SWNumber"
	$ListofPorts = Get-HostPorts -SANConnection $SANConnection| where { ( $_.Type -eq "host" ) -and ($_.Protocol -eq "FC")}
	if (!($ListofPorts))	{	return "FAILURE : No ports to display"	}
	$Port_Pattern = "(\d):(\d):(\d)"							# Pattern matches value of port: 1:2:3
	$WWN_Pattern = "([0-9a-f][0-9a-f])" * 8						# Pattern matches value of WWN
	foreach ($Port in $ListofPorts)
		{	$NSP  = $Port.Device
			$SW = $NSP.Split(':')[-1]
			# Check whether the number is odd
			if ( [Bool]($SW % 2) )	{	$SwitchNumber = 1	}
			else					{	$SwitchNumber = 2	}
			$NSP = $NSP -replace $Port_Pattern , 'N$1:S$2:P$3'
			$WWN = $Port.Port_WWN
			$WWN = $WWN -replace $WWN_Pattern , '$1:$2:$3:$4:$5:$6:$7:$8'
			Add-Content -Path $ResultFile -Value "$NSP,$WWN,$SwitchNumber"
		}
	Write-Verbose "FC ports are stored in $ResultFile" 
	return "Success: FC ports information stored in $ResultFile"
}
}

Function Test-A9CLIObject 
{
Param( 	
    [string]	$ObjectType, 
	[string]	$ObjectName ,
	[string]	$ObjectMsg = $ObjectType
)
Process
{	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"
	write-verbose "Executing the following SSH command `n`t $cmds"
			$Result = Invoke-A9CLICommand -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")	{	$IsObjectExisted = $false	}
	return $IsObjectExisted
}	
} 

