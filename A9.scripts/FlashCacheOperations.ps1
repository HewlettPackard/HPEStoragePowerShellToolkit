####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Set-A9FlashCache 
{
<#
.SYNOPSIS
	Setting Flash Cache policy
.DESCRIPTION
	Setting Flash Cache policy
.EXAMPLE
	PS:> Set-A9FlashCache -Enable

	Enable Flash Cache policy
.EXAMPLE
	PS:> Set-A9FlashCache -Disable

	Disable Flash Cache policy
.PARAMETER Enable
	Enable Flash Cache policy
.PARAMETER Disable
	Disable Flash Cache policy
#>
[CmdletBinding()]
Param(	[Parameter(ParameterSetName = "Enabled",  Mandatory=$true, ValueFromPipeline=$true)]	[switch]	$Enable,
		[Parameter(ParameterSetName = "disabled", Mandatory=$true, ValueFromPipeline=$true)]	[switch]	$Disable
)
Begin 
{	# Test if connection exist
    Test-WSAPIConnection
}
Process 
{	$body = @{}	
	If ($Enable) 	{	$body["flashCachePolicy"] = 1	}
	If ($Disable)	{	$body["flashCachePolicy"] = 2	}
    $Result = $null	
    $Result = Invoke-WSAPI -uri '/system' -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result		
		}
	else
		{	write-error "FAILURE : While Setting Flash Cache policy." 
			return $Result.StatusDescription
		}
}
}

Function New-A9FlashCache
{
<#      
.SYNOPSIS	
	Creating a Flash Cache.
.DESCRIPTION	
    Creating a Flash Cache.
.EXAMPLE	
	PS:> New-A9FlashCache -SizeGiB 64 -Mode 1 -RAIDType R1
.EXAMPLE	
	PS:> New-A9FlashCache -SizeGiB 64 -Mode 1 -RAIDType R0
.EXAMPLE	
	PS:> New-A9FlashCache -NoCheckSCMSize "true"
.EXAMPLE	
	PS:> New-A9FlashCache -NoCheckSCMSize "false"
.PARAMETER SizeGiB
	Specifies the node pair size of the Flash Cache on the system.
.PARAMETER Mode
	Can be set to Simulator or Real (default)
.PARAMETER RAIDType  
	Raid Type of the logical disks for flash cache. When unspecified, storage system chooses the default(R0 Level0,R1 Level1).
.PARAMETER NoCheckSCMSize
	Overrides the size comparison check to allow Adaptive Flash Cache creation with mismatched SCM device sizes.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[int]		$SizeGiB,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('Simulator','Real')]		[string]	$Mode='Real',
		[Parameter(ValueFromPipeline=$true)]	
		[ValidateSet("R0","R1")]				[String]	$RAIDType,
		[Parameter(ValueFromPipeline=$true)]	[boolean]	$NoCheckSCMSize
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$body = @{}
	$FlashCacheBody = @{} 
	If($SizeGiB) 				{	$FlashCacheBody["sizeGiB"] = $SizeGiB }
	If($Mode -eq 'Simulator')	{	$FlashCacheBody["mode"] = 1    }
	If($Mode -eq 'Real')		{	$FlashCacheBody["mode"] = 2    }
	if($RAIDType -eq "R0")		{	$FlashCacheBody["RAIDType"] = 1	}
	if($RAIDType -eq "R1")		{	$FlashCacheBody["RAIDType"] = 2	}		
	If($NoCheckSCMSize) 		{	$FlashCacheBody["noCheckSCMSize"] = $NoCheckSCMSize }
	if($FlashCacheBody.Count -gt 0){$body["flashCache"] = $FlashCacheBody }
    $Result = $null
    $Result = Invoke-WSAPI -uri '/' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 201)
	{	write-host "Cmdlet executed successfully" -foreground green
		return $Result
	}
	else
	{	write-error "FAILURE : While creating a Flash Cache." 
		return $Result.StatusDescription
	}
}
}

Function Remove-A9FlashCache
{
<#      
.SYNOPSIS	
	Removing a Flash Cache.
.DESCRIPTION	
    Removing a Flash Cache.
.EXAMPLE	
	PS:> Remove-A9FlashCache
#>
[CmdletBinding()]
Param()
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = Invoke-WSAPI -uri '/flashcache' -type 'DELETE' -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return $Result
	}
	else
	{	write-Error "FAILURE : While Removing Flash Cache." 
		return $Result.StatusDescription
	}
}
}

Function Get-FlashCache_WSAPI 
{
<#
.SYNOPSIS	
	Get Flash Cache information.
.DESCRIPTION
	Get Flash Cache information.
.EXAMPLE
	PS:> Get-A9FlashCache

	Get Flash Cache information.
#>
[CmdletBinding()]
Param()
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null
	$Result = Invoke-WSAPI -uri '/flashcache' -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
		}
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	write-error "FAILURE : While Executing Get-FlashCache_WSAPI." 
			return $Result.StatusDescription
		}
}	
}
