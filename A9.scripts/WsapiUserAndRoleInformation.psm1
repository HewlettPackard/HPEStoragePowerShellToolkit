####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##	Description: 	WSAPI user and role information cmdlets 
##		

Function Get-Users_WSAPI 
{
  <#   
  .SYNOPSIS	
	Get all or single WSAPI users information.
  
  .DESCRIPTION
	Get all or single WSAPI users information.
        
  .EXAMPLE
	Get-Users_WSAPI
	Get all WSAPI users information.

  .EXAMPLE
	Get-Users_WSAPI -UserName XYZ
	Get single WSAPI users information.
	
  .PARAMETER UserName
	Name Of The User.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-Users_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-Users_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $UserName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null
		
	if($UserName)
	{
		#Request
		$uri = '/users/'+$UserName
		
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}
	}	
	else
	{
		#Request
		
		$Result = Invoke-WSAPI -uri '/users' -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}	
	}
		  
	if($Result.StatusCode -eq 200)
	{	
		if($dataPS.Count -eq 0)
		{
			return "No data Fount."
		}
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Command Get-Users_WSAPI Successfully Executed" $Info
		
		return $dataPS		
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-Users_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-Users_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}

Function Get-Roles_WSAPI 
{
  <#   
  .SYNOPSIS	
	Get all or single WSAPI role information.
  
  .DESCRIPTION
	Get all or single WSAPI role information.
        
  .EXAMPLE
	Get-Roles_WSAPI
	Get all WSAPI role information.

  .EXAMPLE
	Get-Roles_WSAPI -RoleName XYZ
	Get single WSAPI role information.
	
  .PARAMETER WsapiConnection 
	Name of the Role.
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Get-Roles_WSAPI   
    LASTEDIT: February 2020
    KEYWORDS: Get-Roles_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
   
  #>
  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $RoleName,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	)

  Begin 
  {
	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
	$Result = $null
	$dataPS = $null
		
	if($RoleName)
	{
		#Request
		$uri = '/roles/'+$RoleName
		
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
		}
	}	
	else
	{
		#Request
		
		$Result = Invoke-WSAPI -uri '/roles' -type 'GET' -WsapiConnection $WsapiConnection
		if($Result.StatusCode -eq 200)
		{
			$dataPS = ($Result.content | ConvertFrom-Json).members
		}	
	}
		  
	if($Result.StatusCode -eq 200)
	{	
		if($dataPS.Count -eq 0)
		{
			return "No data Fount."
		}
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Command Get-Roles_WSAPI Successfully Executed" $Info
		
		return $dataPS		
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-Roles_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-Roles_WSAPI." $Info
		
		return $Result.StatusDescription
	}
  }	
}

Export-ModuleMember Get-Users_WSAPI , Get-Roles_WSAPI
