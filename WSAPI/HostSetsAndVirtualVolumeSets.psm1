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
##	File Name:		HostSetsAndVirtualVolumeSets.psm1
##	Description: 	Host sets and virtual volume sets cmdlets 
##		
##	Created:		February 2020
##	Last Modified:	February 2020
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## FUNCTION New-HostSet_WSAPI
############################################################################################################################################
Function New-HostSet_WSAPI 
{
  <#
  
  .SYNOPSIS
	Creates a new host Set.
	
  .DESCRIPTION
	Creates a new host Set.
    Any user with the Super or Edit role can create a host set. Any role granted hostset_set permission can add hosts to a host set.
	You can add hosts to a host set using a glob-style pattern. A glob-style pattern is not supported when removing hosts from sets.
	For additional information about glob-style patterns, see “Glob-Style Patterns” in the HPE 3PAR Command Line Interface Reference.
	  
  .PARAMETER HostSetName
	Name of the host set to be created.
  
  .PARAMETER Comment
	Comment for the host set.
	
  .PARAMETER Domain
	The domain in which the host set will be created.
	
  .PARAMETER SetMembers
	The host to be added to the set. The existence of the hist will not be checked.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command

  .EXAMPLE
	New-HostSet_WSAPI -HostSetName MyHostSet
    Creates a new host Set with name MyHostSet.
	
  .EXAMPLE
	New-HostSet_WSAPI -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain
    Creates a new host Set with name MyHostSet.
	
  .EXAMPLE
	New-HostSet_WSAPI -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers MyHost
	Creates a new host Set with name MyHostSet with Set Members MyHost.
	
  .EXAMPLE	
	New-HostSet_WSAPI -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers "MyHost,MyHost1,MyHost2"
    Creates a new host Set with name MyHostSet with Set Members MyHost.	

  .Notes
    NAME    : New-HostSet_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: New-HostSet_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $HostSetName,	  
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Comment,	
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Domain, 
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [String[]]
	  $SetMembers,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    # Creation of the body hash
	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}    
    $body["name"] = "$($HostSetName)"
   
    If ($Comment) 
    {
		$body["comment"] = "$($Comment)"
    }  

	If ($Domain) 
    {
		$body["domain"] = "$($Domain)"
    }
	
	If ($SetMembers) 
    {
		$body["setmembers"] = $SetMembers
    }
    
    $Result = $null
	
    #Request
    $Result = Invoke-WSAPI -uri '/hostsets' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode	
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Host Set:$HostSetName created successfully" $Info
		
		Get-HostSet_WSAPI -HostSetName $HostSetName
		Write-DebugLog "End: New-HostSet_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating Host Set:$HostSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating Host Set:$HostSetName " $Info
		
		return $Result.StatusDescription
	}	
  }
  End 
  {
  }  
}
#ENG New-HostSet_WSAPI

############################################################################################################################################
## FUNCTION Update-HostSet_WSAPI
############################################################################################################################################
Function Update-HostSet_WSAPI 
{
  <#
  .SYNOPSIS
	Update an existing Host Set.
  
  .DESCRIPTION
	Update an existing Host Set.
    Any user with the Super or Edit role can modify a host set. Any role granted hostset_set permission can add a host to the host set or remove a host from the host set.   
	
  .EXAMPLE    
	Update-HostSet_WSAPI -HostSetName xxx -RemoveMember -Members as-Host4
		
  .EXAMPLE
	Update-HostSet_WSAPI -HostSetName xxx -AddMember -Members as-Host4
	
  .EXAMPLE	
	Update-HostSet_WSAPI -HostSetName xxx -ResyncPhysicalCopy
	
  .EXAMPLE	
	Update-HostSet_WSAPI -HostSetName xxx -StopPhysicalCopy 
		
  .EXAMPLE
	Update-HostSet_WSAPI -HostSetName xxx -PromoteVirtualCopy
		
  .EXAMPLE
	Update-HostSet_WSAPI -HostSetName xxx -StopPromoteVirtualCopy
		
  .EXAMPLE
	Update-HostSet_WSAPI -HostSetName xxx -ResyncPhysicalCopy -Priority high
		
  .PARAMETER HostSetName
	Existing Host Name
	
  .PARAMETER AddMember
	Adds a member to the VV set.
	
  .PARAMETER RemoveMember
	Removes a member from the VV set.
	
  .PARAMETER ResyncPhysicalCopy
	Resynchronize the physical copy to its VV set.
  
  .PARAMETER StopPhysicalCopy
	Stops the physical copy.
  
  .PARAMETER PromoteVirtualCopy
	Promote virtual copies in a VV set.
	
  .PARAMETER StopPromoteVirtualCopy
	Stops the promote virtual copy operations in a VV set.
	
  .PARAMETER NewName
	New name of the set.
	
  .PARAMETER Comment
	New comment for the VV set or host set.
	To remove the comment, use “”.

  .PARAMETER Members
	The volume or host to be added to or removed from the set.
  
  .PARAMETER Priority
	1: high
	2: medium
	3: low

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Update-HostSet_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Update-HostSet_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0      
  #>

  [CmdletBinding()]
  Param(
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
	[System.String]
	$HostSetName,
	
	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$AddMember,	
	
	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$RemoveMember,
	
	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$ResyncPhysicalCopy,
	
	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$StopPhysicalCopy,
	
	[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$PromoteVirtualCopy,
	
	[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$StopPromoteVirtualCopy,
	
	[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$NewName,
	
	[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Comment,
	
	[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
	[String[]]
	$Members,
	
	[Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Priority,

	[Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
	$WsapiConnection = $global:WsapiConnection	
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}
	$counter
	
    If ($AddMember) 
	{
          $body["action"] = 1
		  $counter = $counter + 1
    }
	If ($RemoveMember) 
	{
          $body["action"] = 2
		  $counter = $counter + 1
    }
	If ($ResyncPhysicalCopy) 
	{
          $body["action"] = 3
		  $counter = $counter + 1
    }
	If ($StopPhysicalCopy) 
	{
          $body["action"] = 4
		  $counter = $counter + 1
    }
	If ($PromoteVirtualCopy) 
	{
          $body["action"] = 5
		  $counter = $counter + 1
    }
	If ($StopPromoteVirtualCopy) 
	{
          $body["action"] = 6
		  $counter = $counter + 1
    }
	if($counter -gt 1)
	{
		return "Please Select Only One from [ AddMember | RemoveMember | ResyncPhysicalCopy | StopPhysicalCopy | PromoteVirtualCopy | StopPromoteVirtualCopy]. "
	}
	
	If ($NewName) 
	{
          $body["newName"] = "$($NewName)"
    }
	
	If ($Comment) 
	{
          $body["comment"] = "$($Comment)"
    }
	
	If ($Members) 
	{
          $body["setmembers"] = $Members
    }
	
	If ($Priority) 
	{	
		$a = "high","medium","low"
		$l=$Priority
		if($a -eq $l)
		{
			if($Priority -eq "high")
			{
				$body["priority"] = 1
			}	
			if($Priority -eq "medium")
			{
				$body["priority"] = 2
			}
			if($Priority -eq "low")
			{
				$body["priority"] = 3
			}
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Priority $Priority in incorrect "
			Return "FAILURE : -Priority :- $Priority is an Incorrect Priority  [high | medium | low]  can be used only . "
		} 
    }
	
    $Result = $null	
	$uri = '/hostsets/'+$HostSetName 
	
    #Request
	Write-DebugLog "Request: Request to Update-HostSet_WSAPI : $HostSetName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Host Set:$HostSetName successfully Updated" $Info
				
		# Results
		if($NewName)
		{
			Get-HostSet_WSAPI -HostSetName $NewName
		}
		else
		{
			Get-HostSet_WSAPI -HostSetName $HostSetName
		}
		Write-DebugLog "End: Update-HostSet_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Updating Host Set: $HostSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Updating Host Set: $HostSetName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Update-HostSet_WSAPI

############################################################################################################################################
## FUNCTION Remove-HostSet_WSAPI
############################################################################################################################################
Function Remove-HostSet_WSAPI
 {
  <#
  .SYNOPSIS
	Remove a Host Set.
  
  .DESCRIPTION
	Remove a Host Set.
	Any user with Super or Edit role, or any role granted host_remove permission, can perform this operation. Requires access to all domains.
        
  .EXAMPLE    
	Remove-HostSet_WSAPI -HostSetName MyHostSet
	
  .PARAMETER HostSetName 
	Specify the name of Host Set to be removed.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Remove-HostSet_WSAPI     
    LASTEDIT: February 2020
    KEYWORDS: Remove-HostSet_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0	
  #>
  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specifies the name of Host Set.')]
	[String]$HostSetName,
	
	[Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
	$WsapiConnection = $global:WsapiConnection
	)
  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {    
	#Build uri
	Write-DebugLog "Running: Building uri to Remove-HostSet_WSAPI." $Debug
	$uri = '/hostsets/'+$HostSetName
	
	$Result = $null

	#Request
	Write-DebugLog "Request: Request to Remove-HostSet_WSAPI : $HostSetName (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Host Set:$HostSetName successfully remove" $Info
		Write-DebugLog "End: Remove-HostSet_WSAPI" $Debug
		
		return ""
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Removing Host Set:$HostSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating Host Set:$HostSetName " $Info
		Write-DebugLog "End: Remove-HostSet_WSAPI" $Debug
		
		return $Result.StatusDescription
	}    
	
  }
  End {}  
}
#END Remove-HostSet_WSAPI

############################################################################################################################################
## FUNCTION Get-HostSet_WSAPI
############################################################################################################################################
Function Get-HostSet_WSAPI 
{
  <#
  .SYNOPSIS
	Get Single or list of Hotes Set.
  
  .DESCRIPTION
	Get Single or list of Hotes Set.
        
  .EXAMPLE
	Get-HostSet_WSAPI
	Display a list of Hotes Set.
	
  .EXAMPLE
	Get-HostSet_WSAPI -HostSetName MyHostSet
	Get the information of given Hotes Set.
	
  .EXAMPLE
	Get-HostSet_WSAPI -Members MyHost
	Get the information of Hotes Set that contain MyHost as Member.
	
  .EXAMPLE
	Get-HostSet_WSAPI -Members "MyHost,MyHost1,MyHost2"
	Multiple Members.
	
  .EXAMPLE
	Get-HostSet_WSAPI -Id 10
	Filter Host Set with Id
	
  .EXAMPLE
	Get-HostSet_WSAPI -Uuid 10
	Filter Host Set with uuid
	
  .EXAMPLE
	Get-HostSet_WSAPI -Members "MyHost,MyHost1,MyHost2" -Id 10 -Uuid 10
	Multiple Filter
	
  .PARAMETER HostSetName
	Specify name of the Hotes Set.
	
  .PARAMETER Members
	Specify name of the Hotes.

  .PARAMETER Id
	Specify id of the Hotes Set.
	
  .PARAMETER Uuid
	Specify uuid of the Hotes Set.
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Get-HostSet_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Get-HostSet_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $HostSetName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Members,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Id,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Uuid,
	  
	  [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection	 
  }

  Process 
  {
	Write-DebugLog "Request: Request to Get-HostSet_WSAPI HostSetName : $HostSetName (Invoke-WSAPI)." $Debug
    #Request
    
	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	
	# Results
	if($HostSetName)
	{
		#Build uri
		$uri = '/hostsets/'+$HostSetName
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
			
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-HostSet_WSAPI successfully Executed." $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-HostSet_WSAPI." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-HostSet_WSAPI. " $Info
			
			return $Result.StatusDescription
		}
	}
	if($Members)
	{		
		$count = 1
		$lista = $Members.split(",")
		foreach($sub in $lista)
		{			
			$Query = $Query.Insert($Query.Length-3," setmembers EQ $sub")			
			if($lista.Count -gt 1)
			{
				if($lista.Count -ne $count)
				{
					$Query = $Query.Insert($Query.Length-3," OR ")
					$count = $count + 1
				}				
			}
		}		
	}
	if($Id)
	{
		if($Members)
		{
			$Query = $Query.Insert($Query.Length-3," OR id EQ $Id")
		}
		else
		{
			$Query = $Query.Insert($Query.Length-3," id EQ $Id")
		}
	}
	if($Uuid)
	{
		if($Members -or $Id)
		{
			$Query = $Query.Insert($Query.Length-3," OR uuid EQ $Uuid")
		}
		else
		{
			$Query = $Query.Insert($Query.Length-3," uuid EQ $Uuid")
		}
	}
	
	if($Members -Or $Id -Or $Uuid)
	{
		#Build uri
		$uri = '/hostsets/'+$Query
		
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{			
			$dataPS = ($Result.content | ConvertFrom-Json).members			
		}
	}	
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/hostsets' -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{			
			$dataPS = ($Result.content | ConvertFrom-Json).members			
		}		
	}

	If($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-HostSet_WSAPI successfully Executed." $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-HostSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-HostSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid." $Info
			
			return 
		}		
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-HostSet_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-HostSet_WSAPI. " $Info
		
		return $Result.StatusDescription
	}
  }
	End {}
}#END Get-HostSet_WSAPI

############################################################################################################################################
## FUNCTION New-VvSet_WSAPI
############################################################################################################################################
Function New-VvSet_WSAPI 
{
  <#
  
  .SYNOPSIS
	Creates a new virtual volume Set.
	
  .DESCRIPTION
	Creates a new virtual volume Set.
    Any user with the Super or Edit role can create a host set. Any role granted hostset_set permission can add hosts to a host set.
	You can add hosts to a host set using a glob-style pattern. A glob-style pattern is not supported when removing hosts from sets.
	For additional information about glob-style patterns, see “Glob-Style Patterns” in the HPE 3PAR Command Line Interface Reference.
	
  .EXAMPLE
	New-VvSet_WSAPI -VVSetName MyVVSet
    Creates a new virtual volume Set with name MyVVSet.
	
  .EXAMPLE
	New-VvSet_WSAPI -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain
    Creates a new virtual volume Set with name MyVVSet.
	
  .EXAMPLE
	New-VvSet_WSAPI -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers xxx
	 Creates a new virtual volume Set with name MyVVSet with Set Members xxx.
	
  .EXAMPLE	
	New-VvSet_WSAPI -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers "xxx1,xxx2,xxx3"
    Creates a new virtual volume Set with name MyVVSet with Set Members xxx.
	
  .PARAMETER VVSetName
	Name of the virtual volume set to be created.
  
  .PARAMETER Comment
	Comment for the virtual volume set.
	
  .PARAMETER Domain
	The domain in which the virtual volume set will be created.
	
  .PARAMETER SetMembers
	The virtual volume to be added to the set. The existence of the hist will not be checked.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : New-VvSet_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: New-VvSet_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VVSetName,	  
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Comment,	
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Domain, 
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [String[]]
	  $SetMembers,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    # Creation of the body hash
	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}    
    $body["name"] = "$($VVSetName)"
   
    If ($Comment) 
    {
		$body["comment"] = "$($Comment)"
    }  

	If ($Domain) 
    {
		$body["domain"] = "$($Domain)"
    }
	
	If ($SetMembers) 
    {
		$body["setmembers"] = $SetMembers
    }
    
    $Result = $null
	
    #Request
    $Result = Invoke-WSAPI -uri '/volumesets' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode	
	if($status -eq 201)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: virtual volume Set:$VVSetName created successfully" $Info
		
		Get-VvSet_WSAPI -VVSetName $VVSetName
		Write-DebugLog "End: New-VvSet_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While creating virtual volume Set:$VVSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating virtual volume Set:$VVSetName " $Info
		
		return $Result.StatusDescription
	}	
  }
  End 
  {
  }  
}
#ENG New-VvSet_WSAPI

############################################################################################################################################
## FUNCTION Update-VvSet_WSAPI
############################################################################################################################################
Function Update-VvSet_WSAPI 
{
  <#
  .SYNOPSIS
	Update an existing virtual volume Set.
  
  .DESCRIPTION
	Update an existing virtual volume Set.
    Any user with the Super or Edit role can modify a host set. Any role granted hostset_set permission can add a host to the host set or remove a host from the host set.   
	
  .EXAMPLE
	Update-VvSet_WSAPI -VVSetName xxx -RemoveMember -Members testvv3.0
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -AddMember -Members testvv3.0
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -ResyncPhysicalCopy 
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -StopPhysicalCopy 
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -PromoteVirtualCopy
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -StopPromoteVirtualCopy
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -Priority xyz
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -ResyncPhysicalCopy -Priority high
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -ResyncPhysicalCopy -Priority medium
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -ResyncPhysicalCopy -Priority low
	
  .EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -NewName as-vvSet1 -Comment "Updateing new name"

  .PARAMETER VVSetName
	Existing virtual volume Name
	
  .PARAMETER AddMember
	Adds a member to the virtual volume set.
	
  .PARAMETER RemoveMember
	Removes a member from the virtual volume set.
	
  .PARAMETER ResyncPhysicalCopy
	Resynchronize the physical copy to its virtual volume set.
  
  .PARAMETER StopPhysicalCopy
	Stops the physical copy.
  
  .PARAMETER PromoteVirtualCopy
	Promote virtual copies in a virtual volume set.
	
  .PARAMETER StopPromoteVirtualCopy
	Stops the promote virtual copy operations in a virtual volume set.
	
  .PARAMETER NewName
	New name of the virtual volume set.
	
  .PARAMETER Comment
	New comment for the virtual volume set or host set.
	To remove the comment, use “”.

  .PARAMETER Members
	The volume to be added to or removed from the virtual volume set.
  
  .PARAMETER Priority
	1: high
	2: medium
	3: low
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Update-VvSet_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Update-VvSet_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0      
  #>

  [CmdletBinding()]
  Param(
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
	[System.String]
	$VVSetName,
	
	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$AddMember,	
	
	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$RemoveMember,
	
	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$ResyncPhysicalCopy,
	
	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$StopPhysicalCopy,
	
	[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$PromoteVirtualCopy,
	
	[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$StopPromoteVirtualCopy,
	
	[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$NewName,
	
	[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Comment,
	
	[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
	[String[]]
	$Members,
	
	[Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Priority,

	[Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
	$WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}
	$counter
	
    If ($AddMember) 
	{
          $body["action"] = 1
		  $counter = $counter + 1
    }
	If ($RemoveMember) 
	{
          $body["action"] = 2
		  $counter = $counter + 1
    }
	If ($ResyncPhysicalCopy) 
	{
          $body["action"] = 3
		  $counter = $counter + 1
    }
	If ($StopPhysicalCopy) 
	{
          $body["action"] = 4
		  $counter = $counter + 1
    }
	If ($PromoteVirtualCopy) 
	{
          $body["action"] = 5
		  $counter = $counter + 1
    }
	If ($StopPromoteVirtualCopy) 
	{
          $body["action"] = 6
		  $counter = $counter + 1
    }
	if($counter -gt 1)
	{
		return "Please Select Only One from [ AddMember | RemoveMember | ResyncPhysicalCopy | StopPhysicalCopy | PromoteVirtualCopy | StopPromoteVirtualCopy]. "
	}
	
	If ($NewName) 
	{
          $body["newName"] = "$($NewName)"
    }
	
	If ($Comment) 
	{
          $body["comment"] = "$($Comment)"
    }
	
	If ($Members) 
	{
          $body["setmembers"] = $Members
    }
	
	If ($Priority) 
	{	
		$a = "high","medium","low"
		$l=$Priority
		if($a -eq $l)
		{
			if($Priority -eq "high")
			{
				$body["priority"] = 1
			}	
			if($Priority -eq "medium")
			{
				$body["priority"] = 2
			}
			if($Priority -eq "low")
			{
				$body["priority"] = 3
			}
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Since -Priority $Priority in incorrect "
			Return "FAILURE : -Priority :- $Priority is an Incorrect Priority  [high | medium | low]  can be used only . "
		} 
    }
	
    $Result = $null	
	$uri = '/volumesets/'+$VVSetName 
	
    #Request
	Write-DebugLog "Request: Request to Update-VvSet_WSAPI : $VVSetName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	if($Result.StatusCode -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: virtual volume Set:$VVSetName successfully Updated" $Info
				
		# Results
		if($NewName)
		{
			Get-VvSet_WSAPI -VVSetName $NewName
		}
		else
		{
			Get-VvSet_WSAPI -VVSetName $VVSetName
		}
		Write-DebugLog "End: Update-VvSet_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Updating virtual volume Set: $VVSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Updating virtual volume Set: $VVSetName " $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Update-VvSet_WSAPI

############################################################################################################################################
## FUNCTION Remove-VvSet_WSAPI
############################################################################################################################################
Function Remove-VvSet_WSAPI
 {
  <#
  .SYNOPSIS
	Remove a virtual volume Set.
  
  .DESCRIPTION
	Remove a virtual volume Set.
	Any user with Super or Edit role, or any role granted host_remove permission, can perform this operation. Requires access to all domains.
        
  .EXAMPLE    
	Remove-VvSet_WSAPI -VVSetName MyvvSet
	
  .PARAMETER VVSetName 
	Specify the name of virtual volume Set to be removed.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Remove-VvSet_WSAPI     
    LASTEDIT: February 2020
    KEYWORDS: Remove-VvSet_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0	
  #>
  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specifies the name of virtual volume Set.')]
	[String]$VVSetName,
	
	[Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
	$WsapiConnection = $global:WsapiConnection
	)
  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {    
	#Build uri
	Write-DebugLog "Running: Building uri to Remove-VvSet_WSAPI." $Debug
	$uri = '/volumesets/'+$VVSetName
	
	$Result = $null

	#Request
	Write-DebugLog "Request: Request to Remove-VvSet_WSAPI : $VVSetName (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: virtual volume Set:$VVSetName successfully remove" $Info
		Write-DebugLog "End: Remove-VvSet_WSAPI" $Debug
		
		return ""
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Removing virtual volume Set:$VVSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating virtual volume Set:$VVSetName " $Info
		Write-DebugLog "End: Remove-VvSet_WSAPI" $Debug
		
		return $Result.StatusDescription
	}    
	
  }
  End {}  
}
#END Remove-VvSet_WSAPI

############################################################################################################################################
## FUNCTION Get-VvSet_WSAPI
############################################################################################################################################
Function Get-VvSet_WSAPI 
{
  <#
  .SYNOPSIS
	Get Single or list of virtual volume Set.
  
  .DESCRIPTION
	Get Single or list of virtual volume Set.
        
  .EXAMPLE
	Get-VvSet_WSAPI
	Display a list of virtual volume Set.
	
  .EXAMPLE
	Get-VvSet_WSAPI -VVSetName MyvvSet
	Get the information of given virtual volume Set.
	
  .EXAMPLE
	Get-VvSet_WSAPI -Members Myvv
	Get the information of virtual volume Set that contain MyHost as Member.
	
  .EXAMPLE
	Get-VvSet_WSAPI -Members "Myvv,Myvv1,Myvv2"
	Multiple Members.
	
  .EXAMPLE
	Get-VvSet_WSAPI -Id 10
	Filter virtual volume Set with Id
	
  .EXAMPLE
	Get-VvSet_WSAPI -Uuid 10
	Filter virtual volume Set with uuid
	
  .EXAMPLE
	Get-VvSet_WSAPI -Members "Myvv,Myvv1,Myvv2" -Id 10 -Uuid 10
	Multiple Filter
	
  .PARAMETER VVSetName
	Specify name of the virtual volume Set.
	
  .PARAMETER Members
	Specify name of the virtual volume.

  .PARAMETER Id
	Specify id of the virtual volume Set.
	
  .PARAMETER Uuid
	Specify uuid of the virtual volume Set.
 
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
 
  .Notes
    NAME    : Get-VvSet_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Get-VvSet_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $VVSetName,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Members,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Id,
	  
	  [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
      [System.String]
	  $Uuid,
	  
	  [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection	 
  }

  Process 
  {
	Write-DebugLog "Request: Request to Get-VvSet_WSAPI VVSetName : $VVSetName (Invoke-WSAPI)." $Debug
    #Request
    
	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	
	# Results
	if($VVSetName)
	{
		#Build uri
		$uri = '/volumesets/'+$VVSetName
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection		 
		If($Result.StatusCode -eq 200)
		{
			$dataPS = $Result.content | ConvertFrom-Json
			
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-VvSet_WSAPI successfully Executed." $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-VvSet_WSAPI." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-VvSet_WSAPI. " $Info
			
			return $Result.StatusDescription
		}
	}
	if($Members)
	{		
		$count = 1
		$lista = $Members.split(",")
		foreach($sub in $lista)
		{			
			$Query = $Query.Insert($Query.Length-3," setmembers EQ $sub")			
			if($lista.Count -gt 1)
			{
				if($lista.Count -ne $count)
				{
					$Query = $Query.Insert($Query.Length-3," OR ")
					$count = $count + 1
				}				
			}
		}		
	}
	if($Id)
	{
		if($Members)
		{
			$Query = $Query.Insert($Query.Length-3," OR id EQ $Id")
		}
		else
		{
			$Query = $Query.Insert($Query.Length-3," id EQ $Id")
		}
	}
	if($Uuid)
	{
		if($Members -or $Id)
		{
			$Query = $Query.Insert($Query.Length-3," OR uuid EQ $Uuid")
		}
		else
		{
			$Query = $Query.Insert($Query.Length-3," uuid EQ $Uuid")
		}
	}
	
	if($Members -Or $Id -Or $Uuid)
	{
		#Build uri
		$uri = '/volumesets/'+$Query
		
		#Request
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection	
		If($Result.StatusCode -eq 200)
		{			
			$dataPS = ($Result.content | ConvertFrom-Json).members			
		}
	}	
	else
	{
		#Request
		$Result = Invoke-WSAPI -uri '/volumesets' -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)
		{			
			$dataPS = ($Result.content | ConvertFrom-Json).members			
		}		
	}

	If($Result.StatusCode -eq 200)
	{
		if($dataPS.Count -gt 0)
		{
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Get-VvSet_WSAPI successfully Executed." $Info
			
			return $dataPS
		}
		else
		{
			write-host ""
			write-host "FAILURE : While Executing Get-VvSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-VvSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid." $Info
			
			return 
		}
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Executing Get-VvSet_WSAPI." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While Executing Get-VvSet_WSAPI. " $Info
		
		return $Result.StatusDescription
	}
  }
	End {}
}#END Get-VvSet_WSAPI

############################################################################################################################################
## FUNCTION Set-VvSetFlashCachePolicy_WSAPI
############################################################################################################################################
Function Set-VvSetFlashCachePolicy_WSAPI 
{
  <#      
  .SYNOPSIS	
	Setting a VV-set Flash Cache policy.
	
  .DESCRIPTION	
    Setting a VV-set Flash Cache policy.
	
  .EXAMPLE	
	Set-VvSetFlashCachePolicy_WSAPI
	
  .PARAMETER VvSet
	Name Of the VV-set to Set Flash Cache policy.
  
  .PARAMETER Enable
	To Enable VV-set Flash Cache policy
	
  .PARAMETER Disable
	To Disable VV-set Flash Cache policy
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
  
  .Notes
    NAME    : Set-VvSetFlashCachePolicy_WSAPI    
    LASTEDIT: February 2020
    KEYWORDS: Set-VvSetFlashCachePolicy_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0     
  #>

  [CmdletBinding()]
  Param(
	  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
      [System.String]
	  $VvSet,
	  
	  [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Enable,
	  
	  [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
      [Switch]
	  $Disable,
	  
	  [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	  $WsapiConnection = $global:WsapiConnection
	  
	  )

  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    $Massage = ""
    Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}		
	
	If($Enable) 
	{
		$body["flashCachePolicy"] = 1
		$Massage = "Enable"
    }		
	elseIf($Disable) 
	{
		$body["flashCachePolicy"] = 2 
		$Massage = "Disable"
    }
	else
	{
		$body["flashCachePolicy"] = 2 
		$Massage = "Default (Disable)"
    }		
	
    $Result = $null
		
    #Request
	Write-DebugLog "Request: Request to Set-VvSetFlashCachePolicy_WSAPI(Invoke-WSAPI)." $Debug	
	
	#Request
	$uri = '/volumesets/'+$VvSet
	
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: Successfully Set Flash Cache policy $Massage to vv-set $VvSet." $Info
				
		# Results
		return $Result
		Write-DebugLog "End: Set-VvSetFlashCachePolicy_WSAPI" $Debug
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Setting Flash Cache policy $Massage to vv-set $VvSet." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : VV-set Flash Cache policy To $Massage." $Info
		
		return $Result.StatusDescription
	}
  }

  End {  }

}#END Set-VvSetFlashCachePolicy_WSAPI


Export-ModuleMember New-HostSet_WSAPI , Update-HostSet_WSAPI , Remove-HostSet_WSAPI , Get-HostSet_WSAPI , New-VvSet_WSAPI ,
Update-VvSet_WSAPI , Remove-VvSet_WSAPI , Get-VvSet_WSAPI , Set-VvSetFlashCachePolicy_WSAPI
# SIG # Begin signature block
# MIIh0AYJKoZIhvcNAQcCoIIhwTCCIb0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCtdu3VLajF+VSe
# PLJ8Byal3r763Rkm5Ieljt0uOU7tZqCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIQezCCEHcCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# aejtam3fcBzRxXaMCo3ljWMut2eE6l8cYpoH5OeQu9wwDQYJKoZIhvcNAQEBBQAE
# ggEASHmjTvUgcxlQCEI5vFMSw2nBarqMF4fOC1Owczad3E8kyiIhf74JnZnVMFNE
# UtwdbfHYwkFtBO9M//42eeau8oI3uuhsY1BPSNhHyO63tOjhULYdza/RZmfwS/DH
# RpqWNjdrK4/rzzAZRTI7ZOpyfLX4WJcDt+FqAZB7KRA2kIqygd3BBuQ87Weg6Xgp
# 4PPZ2iOepvJIj2fDHupeYiJKTeMKjCpebJlCZK9sRepjVezJOMk2vDa0rsHfc8TS
# lch0SsRSziN5dFllqHWfmPEc6wg+BKA9l4QWH2oGMwbp8jUyiO9dwcOM5bJT1zJ/
# 3b2UUpX/m9omBuib7URE5D8PgqGCDj0wgg45BgorBgEEAYI3AwMBMYIOKTCCDiUG
# CSqGSIb3DQEHAqCCDhYwgg4SAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDwYLKoZIhvcN
# AQkQAQSggf8EgfwwgfkCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# IDY2jv1MYD/O9+WCalbRbMiRCkK474V7/aUxF+dbhHG+AhUAk34aH9ppiFMttRLr
# e1jYPwU/bbUYDzIwMjEwNjE5MDUxOTEyWjADAgEeoIGGpIGDMIGAMQswCQYDVQQG
# EwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5
# bWFudGVjIFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBU
# aW1lU3RhbXBpbmcgU2lnbmVyIC0gRzOgggqLMIIFODCCBCCgAwIBAgIQewWx1Elo
# UUT3yYnSnBmdEjANBgkqhkiG9w0BAQsFADCBvTELMAkGA1UEBhMCVVMxFzAVBgNV
# BAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3
# b3JrMTowOAYDVQQLEzEoYykgMjAwOCBWZXJpU2lnbiwgSW5jLiAtIEZvciBhdXRo
# b3JpemVkIHVzZSBvbmx5MTgwNgYDVQQDEy9WZXJpU2lnbiBVbml2ZXJzYWwgUm9v
# dCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xNjAxMTIwMDAwMDBaFw0zMTAx
# MTEyMzU5NTlaMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jw
# b3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEoMCYGA1UE
# AxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALtZnVlVT52Mcl0agaLrVfOwAa08cawyjwVrhpon
# ADKXak3JZBRLKbvC2Sm5Luxjs+HPPwtWkPhiG37rpgfi3n9ebUA41JEG50F8eRzL
# y60bv9iVkfPw7mz4rZY5Ln/BJ7h4OcWEpe3tr4eOzo3HberSmLU6Hx45ncP0mqj0
# hOHE0XxxxgYptD/kgw0mw3sIPk35CrczSf/KO9T1sptL4YiZGvXA6TMU1t/HgNuR
# 7v68kldyd/TNqMz+CfWTN76ViGrF3PSxS9TO6AmRX7WEeTWKeKwZMo8jwTJBG1kO
# qT6xzPnWK++32OTVHW0ROpL2k8mc40juu1MO1DaXhnjFoTcCAwEAAaOCAXcwggFz
# MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMGYGA1UdIARfMF0w
# WwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNvbS9ycGEwLgYI
# KwYBBQUHAQEEIjAgMB4GCCsGAQUFBzABhhJodHRwOi8vcy5zeW1jZC5jb20wNgYD
# VR0fBC8wLTAroCmgJ4YlaHR0cDovL3Muc3ltY2IuY29tL3VuaXZlcnNhbC1yb290
# LmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAoBgNVHREEITAfpB0wGzEZMBcGA1UE
# AxMQVGltZVN0YW1wLTIwNDgtMzAdBgNVHQ4EFgQUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwHwYDVR0jBBgwFoAUtnf6aUhHn1MS1cLqBzJ2B9GXBxkwDQYJKoZIhvcNAQEL
# BQADggEBAHXqsC3VNBlcMkX+DuHUT6Z4wW/X6t3cT/OhyIGI96ePFeZAKa3mXfSi
# 2VZkhHEwKt0eYRdmIFYGmBmNXXHy+Je8Cf0ckUfJ4uiNA/vMkC/WCmxOM+zWtJPI
# TJBjSDlAIcTd1m6JmDy1mJfoqQa3CcmPU1dBkC/hHk1O3MoQeGxCbvC2xfhhXFL1
# TvZrjfdKer7zzf0D19n2A6gP41P3CnXsxnUuqmaFBJm3+AZX4cYO9uiv2uybGB+q
# ueM6AL/OipTLAduexzi7D1Kr0eOUA2AKTaD+J20UMvw/l0Dhv5mJ2+Q5FL3a5NPD
# 6itas5VYVQR9x5rsIwONhSrS/66pYYEwggVLMIIEM6ADAgECAhB71OWvuswHP6EB
# IwQiQU0SMA0GCSqGSIb3DQEBCwUAMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRT
# eW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0
# d29yazEoMCYGA1UEAxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAe
# Fw0xNzEyMjMwMDAwMDBaFw0yOTAzMjIyMzU5NTlaMIGAMQswCQYDVQQGEwJVUzEd
# MBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVj
# IFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgU2lnbmVyIC0gRzMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCvDoqq+Ny/aXtUF3FHCb2NPIH4dBV3Z5Cc/d5OAp5LdvblNj5l1SQgbTD53R2D
# 6T8nSjNObRaK5I1AjSKqvqcLG9IHtjy1GiQo+BtyUT3ICYgmCDr5+kMjdUdwDLNf
# W48IHXJIV2VNrwI8QPf03TI4kz/lLKbzWSPLgN4TTfkQyaoKGGxVYVfR8QIsxLWr
# 8mwj0p8NDxlsrYViaf1OhcGKUjGrW9jJdFLjV2wiv1V/b8oGqz9KtyJ2ZezsNvKW
# lYEmLP27mKoBONOvJUCbCVPwKVeFWF7qhUhBIYfl3rTTJrJ7QFNYeY5SMQZNlANF
# xM48A+y3API6IsW0b+XvsIqbAgMBAAGjggHHMIIBwzAMBgNVHRMBAf8EAjAAMGYG
# A1UdIARfMF0wWwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9k
# LnN5bWNiLmNvbS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9ycGEwQAYDVR0fBDkwNzA1oDOgMYYvaHR0cDovL3RzLWNybC53cy5zeW1hbnRl
# Yy5jb20vc2hhMjU2LXRzcy1jYS5jcmwwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# DgYDVR0PAQH/BAQDAgeAMHcGCCsGAQUFBwEBBGswaTAqBggrBgEFBQcwAYYeaHR0
# cDovL3RzLW9jc3Aud3Muc3ltYW50ZWMuY29tMDsGCCsGAQUFBzAChi9odHRwOi8v
# dHMtYWlhLndzLnN5bWFudGVjLmNvbS9zaGEyNTYtdHNzLWNhLmNlcjAoBgNVHREE
# ITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtNjAdBgNVHQ4EFgQUpRMB
# qZ+FzBtuFh5fOzGqeTYAex0wHwYDVR0jBBgwFoAUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwDQYJKoZIhvcNAQELBQADggEBAEaer/C4ol+imUjPqCdLIc2yuaZycGMv41Up
# ezlGTud+ZQZYi7xXipINCNgQujYk+gp7+zvTYr9KlBXmgtuKVG3/KP5nz3E/5jMJ
# 2aJZEPQeSv5lzN7Ua+NSKXUASiulzMub6KlN97QXWZJBw7c/hub2wH9EPEZcF1rj
# pDvVaSbVIX3hgGd+Yqy3Ti4VmuWcI69bEepxqUH5DXk4qaENz7Sx2j6aescixXTN
# 30cJhsT8kSWyG5bphQjo3ep0YG5gpVZ6DchEWNzm+UgUnuW/3gC9d7GYFHIUJN/H
# ESwfAD/DSxTGZxzMHgajkF9cVIs+4zNbgg/Ft4YCTnGf6WZFP3YxggJaMIICVgIB
# ATCBizB3MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRp
# b24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxKDAmBgNVBAMTH1N5
# bWFudGVjIFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEHvU5a+6zAc/oQEjBCJBTRIw
# CwYJYIZIAWUDBAIBoIGkMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkq
# hkiG9w0BCQUxDxcNMjEwNjE5MDUxOTEyWjAvBgkqhkiG9w0BCQQxIgQgCU+C5vly
# 4/LuHAvgQ9oJkPMM/mv06MSOWMmHVQvdnAowNwYLKoZIhvcNAQkQAi8xKDAmMCQw
# IgQgxHTOdgB9AjlODaXk3nwUxoD54oIBPP72U+9dtx/fYfgwCwYJKoZIhvcNAQEB
# BIIBAB2kV5DLzdevm39sXihxzMRXXTVh5MvkXr2hSPn2gcQi0wNxJXYpHYGkfVCS
# R0vPVmxzzriSjhnCpd8BZ93X5Weq9yfeNHHcq1mgJXTMzF0f65kEpwYEeg6CCnsZ
# McoeYyxIzRwEj1cNoIn8P2m0/wzX9VEuJYeIjQ4AkcL3heyrdNAvFUuUmTFArqD7
# i5RGJ6lcuuOEs9R4vYcwh3phYUHWo2f15dcRefYSwbWroKwNTvyYBziB0hXgTN+E
# 3u4FAl5xG3mVwF0fWU1l8/tGqioxR8fkN+lQitFafOkYUiTd5TbEvqSVIi7szMDi
# HOzpn2jSkMHJKjearMg+OkYRnAw=
# SIG # End signature block
