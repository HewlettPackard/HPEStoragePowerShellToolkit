####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function New-A9Host
{
<#
.SYNOPSIS
	Creates a new host.
.DESCRIPTION    
	Creates a new host. Any user with Super or Edit role, or any role granted host_create permission, can perform this operation. Requires access to all domains.    
.EXAMPLE
	New-A9Host -HostName MyHost
    Creates a new host.
.EXAMPLE
	New-A9Host -HostName MyHost -Domain MyDoamin	
	Create the host MyHost in the specified domain MyDoamin.
.EXAMPLE
	New-A9Host -HostName MyHost -Domain MyDoamin -FCWWN XYZ
	Create the host MyHost in the specified domain MyDoamin with WWN XYZ
.EXAMPLE
	New-A9Host -HostName MyHost -Domain MyDoamin -FCWWN XYZ -Persona GENERIC_ALUA
.EXAMPLE	
	New-A9Host -HostName MyHost -Domain MyDoamin -Persona GENERIC
.EXAMPLE	
	New-A9Host -HostName MyHost -Location 1
.EXAMPLE
	New-A9Host -HostName MyHost -IPAddr 1.0.1.0
.EXAMPLE	
	New-A9Host -HostName $hostName -Port 1:0:1
.PARAMETER HostName
	Specifies the host name. Required for creating a host.
.PARAMETER Domain
	Create the host in the specified domain, or in the default domain, if unspecified.
.PARAMETER FCWWN
	Set WWNs for the host.
.PARAMETER ForceTearDown
	If set to true, forces tear down of low-priority VLUN exports.
.PARAMETER ISCSINames
	Set one or more iSCSI names for the host.
.PARAMETER Location
	The host’s location.
.PARAMETER IPAddr
	The host’s IP address.
.PARAMETER OS
	The operating system running on the host.
.PARAMETER Model
	The host’s model.
.PARAMETER Contact
	The host’s owner and contact.
.PARAMETER Comment
	Any additional information for the host.
.PARAMETER Persona
	Uses the default persona "GENERIC_ALUA" unless you specify the host persona.
	1	GENERIC
	2	GENERIC_ALUA
	3	GENERIC_LEGACY
	4	HPUX_LEGACY
	5	AIX_LEGACY
	6	EGENERA
	7	ONTAP_LEGACY
	8	VMWARE
	9	OPENVMS
	10	HPUX
	11	WindowsServer
	12	AIX_ALUA
.PARAMETER Port
	Specifies the desired relationship between the array ports and the host for target-driven zoning. Use this option when the Smart SAN license is installed only.
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$HostName,
		[Parameter()]   [String]	$Domain,
		[Parameter()]	[String[]]	$FCWWN,
		[Parameter()]	[Boolean]	$ForceTearDown,
		[Parameter()]	[String[]]	$ISCSINames,
		[Parameter()]   [String]	$Location,
		[Parameter()]	[String]	$IPAddr,
		[Parameter()]   [String]	$OS,
		[Parameter()]	[String]	$Model,
		[Parameter()]	[String]	$Contact,
		[Parameter()]   [String]	$Comment,
		[Parameter()][ValidateSet('GENERIC','GENERIC_ALUA','GENERIC_LEGACY','HPUX_LEGACY','AIX_LEGACY','EGENERA','ONTAP_LEGACY','VMWARE','OPENVMS','HPUX')]
						[String]	$Persona,
		[Parameter()]	[String[]]	$Port
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}    
    $body["name"] = "$($HostName)"
    If ($Domain)  		{	$body["domain"] = "$($Domain)"    	}
    If ($FCWWN)    		{	$body["FCWWNs"] = $FCWWN    		} 
	If ($ForceTearDown)	{$body["forceTearDown"] = $ForceTearDown}
	If ($ISCSINames)	{	$body["iSCSINames"] = $ISCSINames	}
	$PersonaHash = @{ 'GENERIC' = 1;'GENERIC_ALUA'=2;'GENERIC_LEGACY'=3;'HPUX_LEGACY'=4;'AIX_LEGACY'=5;'EGENERA'=6;'ONTAP_LEGACY'=7;'VMWARE'=8;'OPENVMS'=9;'HPUX'=10}
	if($Persona)		{	$body['persona'] = $PersonaHash[$Persona] }
	If ($Port)     		{	$body["port"] = $Port    			}
	$DescriptorsBody = @{}   
	If ($Location)		{	$DescriptorsBody["location"] = "$($Location)"   }
	If ($IPAddr) 		{	$DescriptorsBody["IPAddr"] = "$($IPAddr)"	    }
	If ($OS)  			{	$DescriptorsBody["os"] = "$($OS)" 				}
	If ($Model) 		{	$DescriptorsBody["model"] = "$($Model)"    		}
	If ($Contact)		{	$DescriptorsBody["contact"] = "$($Contact)" 	}
	If ($Comment)		{	$DescriptorsBody["Comment"] = "$($Comment)"		}
	if($DescriptorsBody.Count -gt 0){	$body["descriptors"] = $DescriptorsBody}
    $Result = $null
    $Result = Invoke-WSAPI -uri '/hosts' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			Get-Host_WSAPI -HostName $HostName
		}
	else
		{	Write-Error "Failure:  While creating Host:$HostName " 
			return $Result.StatusDescription
		}	
}
}

Function Add-A9RemoveHostWWN
{
<#
.SYNOPSIS
	Add or remove a host WWN from target-driven zoning
.DESCRIPTION    
	Add a host WWN from target-driven zoning.
    Any user with Super or Edit role, or any role granted host_create permission, can perform this operation. Requires access to all domains.    
.EXAMPLE
	Add-A9RemoveHostWWN -HostName MyHost -FCWWNs "$wwn" -AddWwnToHost
.EXAMPLE	
	Add-A9RemoveHostWWN -HostName MyHost -FCWWNs "$wwn" -RemoveWwnFromHost
.PARAMETER HostName
	Host Name.
.PARAMETER FCWWNs
	WWNs of the host.
.PARAMETER Port
	Specifies the ports for target-driven zoning. Use this option when the Smart SAN license is installed only.
	This field is NOT supported for the following actions:ADD_WWN_TO_HOST REMOVE_WWN_FROM_H OST, It is a required field for the following actions:ADD_WWN_TO_TZONE REMOVE_WWN_FROM_T ZONE.
.PARAMETER AddWwnToHost
	its a action to be performed. Recommended method for adding WWN to host. Operates the same as using a PUT method with the pathOperation specified as ADD.
.PARAMETER RemoveWwnFromHost
	Recommended method for removing WWN from host. Operates the same as using the PUT method with the pathOperation specified as REMOVE.
.PARAMETER AddWwnToTZone   
	Adds WWN to target driven zone. Creates the target driven zone if it does not exist, and adds the WWN to the host if it does not exist.
.PARAMETER RemoveWwnFromTZone
	Removes WWN from the targetzone. Removes the target driven zone unless it is the last WWN. Does not remove the last WWN from the host.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true)]				[String]	$HostName,
		[Parameter(Mandatory=$true)]				[String[]]	$FCWWNs,
		[Parameter(ParameterSetName='AddZone')]
		[Parameter(ParameterSetName='RemZone')]		[String[]]	$Port,
		[Parameter(ParameterSetName='AddHost', Mandatory=$true)]	[switch]	$AddWwnToHost,
		[Parameter(ParameterSetName='RemHost', Mandatory=$true)]	[switch]	$RemoveWwnFromHost,
		[Parameter(ParameterSetName='AddZone', Mandatory=$true)]	[switch]	$AddWwnToTZone,
		[Parameter(ParameterSetName='RemZone', Mandatory=$true)]	[switch]	$RemoveWwnFromTZone
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}
    If($AddWwnToHost) 			{	$body["action"] = 1    }
	elseif($RemoveWwnFromHost)	{	$body["action"] = 2	}
	elseIf($AddWwnToTZone)     	{	$body["action"] = 3    }
	elseif($RemoveWwnFromTZone)	{	$body["action"] = 4	}
	$ParametersBody = @{} 
    If($FCWWNs) 			    {	$ParametersBody["FCWWNs"] = $FCWWNs }
	If($Port)					{	$ParametersBody["port"] = $Port    }
	if($ParametersBody.Count -gt 0){$body["parameters"] = $ParametersBody 	}
    $Result = $null
	$uri = '/hosts/'+$HostName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			Get-Host_WSAPI -HostName $HostName
		}
	else
		{	Write-Error "Failure:  Cmdlet Execution failed with Host : $HostName." 
			return $Result.StatusDescription
		}	
}
}


Function Update-A9Host 
{
<#      
.SYNOPSIS	
	Update Host.
.DESCRIPTION	    
    Update Host.
.EXAMPLE	
	Update-A9Host -HostName MyHost
.EXAMPLE	
	Update-A9Host -HostName MyHost -ChapName TestHostAS	
.EXAMPLE	
	Update-A9Host -HostName MyHost -ChapOperationMode 1 
.PARAMETER HostName
	Neme of the Host to Update.
.PARAMETER ChapName
	The chap name.
.PARAMETER ChapOperationMode
	Initiator or target.
.PARAMETER ChapRemoveTargetOnly
	If true, then remove target chap only.
.PARAMETER ChapSecret
	The chap secret for the host or the target
.PARAMETER ChapSecretHex
	If true, then chapSecret is treated as Hex.
.PARAMETER ChapOperation
	Add or remove.
	1) INITIATOR : Set the initiator CHAP authentication information on the host.
	2) TARGET : Set the target CHAP authentication information on the host.
.PARAMETER Descriptors
	The description of the host.
.PARAMETER FCWWN
	One or more WWN to set for the host.
.PARAMETER ForcePathRemoval
	If true, remove WWN(s) or iSCSI(s) even if there are VLUNs that are exported to the host. 
.PARAMETER iSCSINames
	One or more iSCSI names to set for the host.
.PARAMETER NewName
	New name of the host.
.PARAMETER PathOperation
	If adding, adds the WWN or iSCSI name to the existing host. 
	If removing, removes the WWN or iSCSI names from the existing host.
	1) ADD : Add host chap or path.
	2) REMOVE : Remove host chap or path.
.PARAMETER Persona
	The ID of the persona to modify the host’s persona to.
	1	GENERIC
	2	GENERIC_ALUA
	3	GENERIC_LEGACY
	4	HPUX_LEGACY
	5	AIX_LEGACY
	6	EGENERA
	7	ONTAP_LEGACY
	8	VMWARE
	9	OPENVMS
	10	HPUX
	11	WindowsServer
	12	AIX_ALUA
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]    [String]	$HostName,
	[Parameter(ValueFromPipeline=$true)]    [String]	$ChapName,
	[Parameter(ValueFromPipeline=$true)] 	[int]		$ChapOperationMode,
	[Parameter(ValueFromPipeline=$true)]    [Switch]	$ChapRemoveTargetOnly,
	[Parameter(ValueFromPipeline=$true)]    [String]	$ChapSecret,
	[Parameter(ValueFromPipeline=$true)]    [Switch]	$ChapSecretHex,
	[Parameter(ValueFromPipeline=$true)]
    [ValidateSet('INITIATOR','TARGET')]		[String]	$ChapOperation,
	[Parameter(ValueFromPipeline=$true)]    [String]	$Descriptors,
	[Parameter(ValueFromPipeline=$true)]    [String[]]	$FCWWN,
	[Parameter(ValueFromPipeline=$true)]    [Switch]	$ForcePathRemoval,
	[Parameter(ValueFromPipeline=$true)]    [String[]]	$iSCSINames,
	[Parameter(ValueFromPipeline=$true)]	[String]	$NewName,
	[Parameter(ValueFromPipeline=$true)]
	[ValidateSet('ADD','REMOVE')]			[String]	$PathOperation,
	[Parameter(ValueFromPipeline=$true)]
	[ValidateSet('GENERIC','GENERIC_ALUA','GENERIC_LEGACY','HPUX_LEGACY','AIX_LEGACY','EGENERA','ONTAP_LEGACY','VMWARE','OPENVMS','HPUX')]
											[String]	$Persona
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}		
	If($ChapName) 					{	$body["chapName"] = "$($ChapName)"    			}
	If($ChapOperationMode) 			{	$body["chapOperationMode"] = $ChapOperationMode	}
	If($ChapRemoveTargetOnly) 		{	$body["chapRemoveTargetOnly"] = $true    		}
	If($ChapSecret) 				{	$body["chapSecret"] = "$($ChapSecret)"    		}
	If($ChapSecretHex) 				{	$body["chapSecretHex"] = $true    				}
	$ChapHash=@{'INITIATOR'=1;'TARGET'=2}
	If($ChapOperation) 				{	$body["chapOperation"]=$ChapHash[$ChapOperation]}
	If($Descriptors) 				{	$body["descriptors"] = "$($Descriptors)"    	}
	If($FCWWN) 						{	$body["FCWWNs"] = $FCWWN    					}
	If($ForcePathRemoval) 			{	$body["forcePathRemoval"] = $true    			}
	If($iSCSINames) 				{	$body["iSCSINames"] = $iSCSINames 				}
	If($NewName) 					{	$body["newName"] = "$($NewName)"    			}
	If($PathOperation -eq 'ADD')	{	$body["pathOperation"] = 1						}
	If($PathOperation -eq 'REMOVE')	{	$body["pathOperation"] = 2						}
	$PersonaHash = @{ 'GENERIC' = 1;'GENERIC_ALUA'=2;'GENERIC_LEGACY'=3;'HPUX_LEGACY'=4;'AIX_LEGACY'=5;'EGENERA'=6;'ONTAP_LEGACY'=7;'VMWARE'=8;'OPENVMS'=9;'HPUX'=10}
	if($Persona)					{	$body['persona'] = $PersonaHash[$Persona] }
    $Result = $null
	$uri = '/hosts/'+$HostName
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)	{	Get-Host_WSAPI -HostName $NewName	}
			else			{	Get-Host_WSAPI -HostName $HostName	}
		}
	else
		{	Write-Error "Failure:  While Updating Host : $HostName." 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9Host
{
<#
.SYNOPSIS
	Remove a Host.
.DESCRIPTION
	Remove a Host. Any user with Super or Edit role, or any role granted host_remove permission, can perform this operation. Requires access to all domains.
.EXAMPLE    
	Remove-Host_WSAPI -HostName MyHost
.PARAMETER HostName 
	Specify the name of Host to be removed.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]	[String]$HostName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$uri = '/hosts/'+$HostName
	$Result = $null
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return
		}
	else
		{	Write-Error "Failure:  While Removing Host:$HostName " 
			return $Result.StatusDescription
		}    	
}
}

Function Get-A9Host
{
<#
.SYNOPSIS
	Get Single or list of Hotes.
.DESCRIPTION
	Get Single or list of Hotes.
.EXAMPLE
	Get-A9Host

	Display a list of host.
.EXAMPLE
	Get-A9Host -HostName MyHost

	Get the information of given host.
.PARAMETER HostName
	Specify name of the Host.
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$HostName
)
Begin 
{	Test-WSAPIConnection	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	if($HostName)
	{	$uri = '/hosts/'+$HostName
		$Result = Invoke-WSAPI -uri $uri -type 'GET' 
		If($Result.StatusCode -eq 200)			{	$dataPS = $Result.content | ConvertFrom-Json	}	
	}	
	else
		{	$Result = Invoke-WSAPI -uri '/hosts' -type 'GET'
			If($Result.StatusCode -eq 200)		{	$dataPS = ($Result.content | ConvertFrom-Json).members		}		
		}
	If($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $dataPS
		}
	else
		{	Write-Error "Failure:  While Executing Get-Host_WSAPI." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9HostWithFilter 
{
<#
.SYNOPSIS
	Get Single or list of Hotes information with WWN filtering.
.DESCRIPTION
	Get Single or list of Hotes information with WWN filtering. specify the FCPaths WWN or the iSCSIPaths name.
.EXAMPLE
	Get-A9HostWithFilter_WSAPI -WWN 123 

	Get a host detail with single wwn name
.EXAMPLE
	Get-A9HostWithFilter -WWN "123,ABC,000" 

	Get a host detail with multiple wwn name
.EXAMPLE
	Get-A9HostWithFilter -ISCSI 123 

	Get a host detail with single ISCSI name
.EXAMPLE
	Get-A9HostWithFilter -ISCSI "123,ABC,000" 

	Get a host detail with multiple ISCSI name
.EXAMPLE	
	Get-A9HostWithFilter -WWN "xxx,xxx,xxx" -ISCSI "xxx,xxx,xxx" 
.PARAMETER WWN
	Specify WWN of the Host.
.PARAMETER ISCSI
	Specify ISCSI of the Host.
#>
[CmdletBinding()]
Param(	[Parameter()]	[String]	$WWN,
		[Parameter()]	[String]	$ISCSI
)

Begin 
{	Test-WSAPIConnection	 
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """	
	if($WWN)
		{	$Query = $Query.Insert($Query.Length-3," FCPaths[ ]")
			$count = 1
			$lista = $WWN.split(",")
			foreach($sub in $lista)
				{	$Query = $Query.Insert($Query.Length-4," wwn EQ $sub")			
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$Query = $Query.Insert($Query.Length-4," OR ")
									$count = $count + 1
								}				
						}
				}		
		}	
	if($ISCSI)
		{	$Link
			if($WWN)
				{	$Query = $Query.Insert($Query.Length-2," OR iSCSIPaths[ ]")
					$Link = 3
				}
			else
				{	$Query = $Query.Insert($Query.Length-3," iSCSIPaths[ ]")
					$Link = 5
				}		
			$count = 1
			$lista = $ISCSI.split(",")
			foreach($sub in $lista)
				{	$Query = $Query.Insert($Query.Length-$Link," name EQ $sub")			
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$Query = $Query.Insert($Query.Length-$Link," OR ")
									$count = $count + 1
								}				
						}
				}		
		}
	if($ISCSI -Or $WWN)
		{	$uri = '/hosts/'+$Query
		}
	else
		{	return "Please select at list any one from [ISCSI | WWN]"
		}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members			
		}	
	If($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-HostWithFilter_WSAPI. Expected Result Not Found with Given Filter Option : ISCSI/$ISCSI WWN/$WWN." 
					return 
				}		
		}
	else
		{	Write-Error "Failure:  While Executing Get-HostWithFilter_WSAPI." 
			return $Result.StatusDescription
		}
}
}

Function Get-A9HostPersona 
{
<#
.SYNOPSIS
	Get Single or list of host persona,.
.DESCRIPTION  
	Get Single or list of host persona,.
.EXAMPLE
	Get-A9HostPersona

	Display a list of host persona.
.EXAMPLE
	Get-A9HostPersona -Id 10

	Display a host persona of given id.
.EXAMPLE
	Get-A9HostPersona -WsapiAssignedId 100

	Display a host persona of given Wsapi Assigned Id.
.EXAMPLE
	Get-A9HostPersona -Id 10

	Get the information of given host persona.
.EXAMPLE	
	Get-A9HostPersona -WsapiAssignedId "1,2,3"

	Multiple Host.
.PARAMETER Id
	Specify host persona id you want to query.
.PARAMETER WsapiAssignedId
	To filter by wsapi Assigned Id.
#>
[CmdletBinding()]
Param(	[Parameter()]	[int]		$Id,
		[Parameter()]	[String]	$WsapiAssignedId
)
Begin 
{	Test-WSAPIConnection	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($Id)
		{	$uri = '/hostpersonas/'+$Id
			$Result = Invoke-WSAPI -uri $uri -type 'GET' 
			If($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
					write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}		
			else
				{	Write-Error "Failure:  While Executing Get-HostPersona_WSAPI." 
					return $Result.StatusDescription
				}
		}
	elseif($WsapiAssignedId)
		{	$count = 1
			$lista = $WsapiAssignedId.split(",")
			foreach($sub in $lista)
				{	$Query = $Query.Insert($Query.Length-3," wsapiAssignedId EQ $sub")			
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$Query = $Query.Insert($Query.Length-3," OR ")
									$count = $count + 1
								}				
						}
				}
			$uri = '/hostpersonas/'+$Query		
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			If($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members	
					if($dataPS.Count -gt 0)
						{	write-host "Cmdlet executed successfully" -foreground green
							return $dataPS
						}
					else
						{	Write-Error "Failure:  While Executing Get-HostPersona_WSAPI. Expected Result Not Found with Given Filter Option : WsapiAssignedId/$WsapiAssignedId." 
							return 
						}
				}
			else
				{	Write-Error "Failure:  While Executing Get-HostPersona_WSAPI." 
					return $Result.StatusDescription
				}
		}
	else
		{	$Result = Invoke-WSAPI -uri '/hostpersonas' -type 'GET' 
			If($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members	
					write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else
				{	Write-Error "Failure:  While Executing Get-HostPersona_WSAPI." 
					return $Result.StatusDescription
				}
		}
}
}
