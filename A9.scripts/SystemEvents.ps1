####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Open-A9SSE 
{
<#   
.SYNOPSIS	
	Establishing a communication channel for Server-Sent Event (SSE).
.DESCRIPTION
	Establishing a communication channel for Server-Sent Event (SSE) 
.EXAMPLE
	PS:> Open-A9SSE
#>
[CmdletBinding()]
Param()
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Result = Invoke-A9API -uri '/eventstream' -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
		}	
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	write-error "FAILURE : While Executing Open-SSE_WSAPI."
			return $Result.StatusDescription
		}
}	
}

Function Get-A9EventLogs 
{
<#
.SYNOPSIS	
	Get all past events from system event logs or a logged event information for the available resources. 
.DESCRIPTION
	Get all past events from system event logs or a logged event information for the available resources. 
.EXAMPLE
	PS:> Get-A9EventLogs
#>
[CmdletBinding()]
Param()
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Result = Invoke-A9API -uri '/eventlog' -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
		}	
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	write-error "FAILURE : While Executing Get-EventLogs_WSAPI."
			return $Result.StatusDescription
		}
}	
}
