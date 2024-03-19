####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9AOConfiguration 
{
<#   
.SYNOPSIS	
	Get all or single WSAPI AO configuration information.
.DESCRIPTION
	Get all or single WSAPI AO configuration information if one exists. The command will return nothing if an AO configuration does not exist.
.PARAMETER AOconfigName
	AO configuration name.
.EXAMPLE
	PS:> Get-A9AOConfiguration
.EXAMPLE
	PS:> Get-A9AOConfiguration -AOconfigName XYZ
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$AOconfigName
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$Result = $null
	$dataPS = $null
	$uri = '/aoconfigurations'
	if($AOconfigName)	{	$uri = $uri+'/'+$AOconfigName	}	
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
			if($dataPS.Count -eq 0)
				{	write-verbose "No data Found." 
					return 
				}
			write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
	{	write-error "While Executing Get-AOConfiguration_WSAPI." 
		return $Result.StatusDescription
	}
}	
}
