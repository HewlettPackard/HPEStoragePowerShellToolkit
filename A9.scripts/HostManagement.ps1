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
	PS:> New-A9Host -HostName MyHost -Domain MyDoamin -FCWWN XYZ -Persona GENERIC_ALUA
.EXAMPLE	
	PS:> New-A9Host -HostName MyHost -Domain MyDoamin -Persona GENERIC
.EXAMPLE	
	PS:> New-A9Host -HostName MyHost -Location 1
.EXAMPLE
	PS:> New-A9Host -HostName MyHost -IPAddr 1.0.1.0
.EXAMPLE	
	PS:> New-A9Host -HostName $hostName -Port 1:0:1
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
{	Test-A9Connection -ClientType 'API'
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
    $Result = Invoke-A9API -uri '/hosts' -type 'POST' -body $body 
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

Function Set-A9HostTargetZoneingWWN
{
<#
.SYNOPSIS
	Add or remove a host WWN from target-driven zoning
.DESCRIPTION    
	Add a host WWN from target-driven zoning.
    Any user with Super or Edit role, or any role granted host_create permission, can perform this operation. Requires access to all domains.    
.EXAMPLE
	PS:> Add-A9RemoveHostWWN -HostName MyHost -FCWWNs "$wwn" -AddWwnToHost
.EXAMPLE	
	PS:> Add-A9RemoveHostWWN -HostName MyHost -FCWWNs "$wwn" -RemoveWwnFromHost
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
{	Test-A9Connection -ClientType 'API'
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
    $Result = Invoke-A9API -uri $uri -type 'POST' -body $body 
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
	PS:> Update-A9Host -HostName MyHost
.EXAMPLE	
	PS:> Update-A9Host -HostName MyHost -ChapName TestHostAS	
.EXAMPLE	
	PS:> Update-A9Host -HostName MyHost -ChapOperationMode 1 
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
{	Test-A9Connection -ClientType 'API'
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
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
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
	PS:> Remove-Host_WSAPI -HostName MyHost
.PARAMETER HostName 
	Specify the name of Host to be removed.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]	[String]$HostName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$uri = '/hosts/'+$HostName
	$Result = $null
	$Result = Invoke-A9API -uri $uri -type 'DELETE' 
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
{	Test-A9Connection -ClientType 'API'	 
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
	$Result = Invoke-A9API -uri $uri -type 'GET' 
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
	PS:> Get-A9HostPersona -Id 10

	Display a host persona of given id.
.EXAMPLE
	PS:> Get-A9HostPersona -WsapiAssignedId 100

	Display a host persona of given Wsapi Assigned Id.
.EXAMPLE
	PS:> Get-A9HostPersona -Id 10

	Get the information of given host persona.
.EXAMPLE	
	PS:> Get-A9HostPersona -WsapiAssignedId "1,2,3"

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
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($Id)
		{	$uri = '/hostpersonas/'+$Id
			$Result = Invoke-A9API -uri $uri -type 'GET' 
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
			$Result = Invoke-A9API -uri $uri -type 'GET'
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
		{	$Result = Invoke-A9API -uri '/hostpersonas' -type 'GET' 
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

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABECpbnYegEf5
# OoInn6IxxgFd61TjAiEzFdAidFnVjJGri23fkd4QhqU7knsh7yM4nOnpadXa7m2G
# +I4teB+JvXKeoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
# KoZIhvcNAQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExp
# bWl0ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0yMTA1
# MjUwMDAwMDBaFw0yODEyMzEyMzU5NTlaMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AI3nlBIiBCR0Lv8WIwKSirauNoWsR9QjkSs+3H3iMaBRb6yEkeNSirXilt7Qh2Mk
# iYr/7xKTO327toq9vQV/J5trZdOlDGmxvEk5mvFtbqrkoIMn2poNK1DpS1uzuGQ2
# pH5KPalxq2Gzc7M8Cwzv2zNX5b40N+OXG139HxI9ggN25vs/ZtKUMWn6bbM0rMF6
# eNySUPJkx6otBKvDaurgL6en3G7X6P/aIatAv7nuDZ7G2Z6Z78beH6kMdrMnIKHW
# uv2A5wHS7+uCKZVwjf+7Fc/+0Q82oi5PMpB0RmtHNRN3BTNPYy64LeG/ZacEaxjY
# cfrMCPJtiZkQsa3bPizkqhiwxgcBdWfebeljYx42f2mJvqpFPm5aX4+hW8udMIYw
# 6AOzQMYNDzjNZ6hTiPq4MGX6b8fnHbGDdGk+rMRoO7HmZzOatgjggAVIQO72gmRG
# qPVzsAaV8mxln79VWxycVxrHeEZ8cKqUG4IXrIfptskOgRxA1hYXKfxcnBgr6kX1
# 773VZ08oXgXukEx658b00Pz6zT4yRhMgNooE6reqB0acDZM6CWaZWFwpo7kMpjA4
# PNBGNjV8nLruw9X5Cnb6fgUbQMqSNenVetG1fwCuqZCqxX8BnBCxFvzMbhjcb2L+
# plCnuHu4nRU//iAMdcgiWhOVGZAA6RrVwobx447sX/TlAgMBAAGjggESMIIBDjAf
# BgNVHSMEGDAWgBSgEQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUMuuSmv81
# lkgvKEBCcCA2kVwXheYwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEE
# ATBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFD
# ZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAQEA
# Er+h74t0mphEuGlGtaskCgykime4OoG/RYp9UgeojR9OIYU5o2teLSCGvxC4rnk7
# U820+9hEvgbZXGNn1EAWh0SGcirWMhX1EoPC+eFdEUBn9kIncsUj4gI4Gkwg4tsB
# 981GTyaifGbAUTa2iQJUx/xY+2wA7v6Ypi6VoQxTKR9v2BmmT573rAnqXYLGi6+A
# p72BSFKEMdoy7BXkpkw9bDlz1AuFOSDghRpo4adIOKnRNiV3wY0ZFsWITGZ9L2PO
# mOhp36w8qF2dyRxbrtjzL3TPuH7214OdEZZimq5FE9p/3Ef738NSn+YGVemdjPI6
# YlG87CQPKdRYgITkRXta2DCCBeEwggRJoAMCAQICEQCZcNC3tMFYljiPBfASsES3
# MA0GCSqGSIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBD
# QSBSMzYwHhcNMjIwNjA3MDAwMDAwWhcNMjUwNjA2MjM1OTU5WjB3MQswCQYDVQQG
# EwJVUzEOMAwGA1UECAwFVGV4YXMxKzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBF
# bnRlcnByaXNlIENvbXBhbnkxKzApBgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRl
# cnByaXNlIENvbXBhbnkwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCi
# DYlhh47xvo+K16MkvHuwo3XZEL+eEWw4MQEoV7qsa3zqMx1kHryPNwVuZ6bAJ5OY
# oNch6usNWr9MZlcgck0OXnRGrxl2FNNKOqb8TAaoxfrhBSG7eZ1FWNqxJAOlzXjg
# 6KEPNdlhmfVvsSDolVDGr6yEXYK9WVhVtEApyLbSZKLED/0OtRp4CtjacOCF/unb
# vfPZ9KyMVKrCN684Q6BpknKH3ooTZHelvfAzUGbHxfKvq5HnIpONKgFhbpdZXKN7
# kynNjRm/wrzfFlp+m9XANlmDnXieTeKEeI3y3cVxvw9HTGm4yIFt8IS/iiZwsKX6
# Y94RkaDzaGB1fZI19FnRo2Fx9ovz187imiMrpDTsj8Kryl4DMtX7a44c8vORYAWO
# B17CKHt52W+ngHBqEGFtce3KbcmIqAH3cJjZUNWrji8nCuqu2iL2Lq4bjcLMdjqU
# +2Uc00ncGfvP2VG2fY+bx78e47m8IQ2xfzPCEBd8iaVKaOS49ZE47/D9Z8sAVjcC
# AwEAAaOCAYkwggGFMB8GA1UdIwQYMBaAFA8qyyCHKLjsb0iuK1SmKaoXpM0MMB0G
# A1UdDgQWBBRtaOAY0ICfJkfK+mJD1LyzN0wLzjAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBKBgNVHSAEQzBBMDUGDCsG
# AQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQ
# UzAIBgZngQwBBAEwSQYDVR0fBEIwQDA+oDygOoY4aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQVIzNi5jcmwweQYIKwYBBQUH
# AQEEbTBrMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNydDAjBggrBgEFBQcwAYYXaHR0cDov
# L29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggGBACPwE9q/9ANM+zGO
# lq4SZg7qDpsDW09bDbdjyzAmxxJk2GhD35Md0IluPppla98zFjnuXWpVqakGk9vM
# KxiooQ9QVDrKYtx9+S8Qui21kT8Ekhrm+GYecVfkgi4ryyDGY/bWTGtX5Nb5G5Gp
# DZbv6wEuu3TXs6o531lN0xJSWpJmMQ/5Vx8C5ZwRgpELpK8kzeV4/RU5H9P07m8s
# W+cmLx085ndID/FN84WmBWYFUvueR5juEfibuX22EqEuuPBORtQsAERoz9jStyza
# gj6QxPG9C4ItZO5LT+EDcHH9ti6CzxexePIMtzkkVV9HXB6OUjgeu6MbNClduKY4
# qFiutdbVC8VPGncuH2xMxDtZ0+ip5swHvPt/cnrGPMcVSEr68cSlUU26Ln2u/03D
# eZ6b0R3IUdwWf4K/1X6NwOuifwL9gnTM0yKuN8cOwS5SliK9M1SWnF2Xf0/lhEfi
# VVeFlH3kZjp9SP7v2I6MPdI7xtep9THwDnNLptqeF79IYoqT3TCCBhowggQCoAMC
# AQICEGIdbQxSAZ47kHkVIIkhHAowDQYJKoZIhvcNAQEMBQAwVjELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAwMFoXDTM2
# MDMyMTIzNTk1OVowVDELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIENBIFIz
# NjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJsrnVP6NT+OYAZDasDP
# 9X/2yFNTGMjO02x+/FgHlRd5ZTMLER4ARkZsQ3hAyAKwktlQqFZOGP/I+rLSJJmF
# eRno+DYDY1UOAWKA4xjMHY4qF2p9YZWhhbeFpPb09JNqFiTCYy/Rv/zedt4QJuIx
# eFI61tqb7/foXT1/LW2wHyN79FXSYiTxcv+18Irpw+5gcTbXnDOsrSHVJYdPE9s+
# 5iRF2Q/TlnCZGZOcA7n9qudjzeN43OE/TpKF2dGq1mVXn37zK/4oiETkgsyqA5lg
# AQ0c1f1IkOb6rGnhWqkHcxX+HnfKXjVodTmmV52L2UIFsf0l4iQ0UgKJUc2RGarh
# OnG3B++OxR53LPys3J9AnL9o6zlviz5pzsgfrQH4lrtNUz4Qq/Va5MbBwuahTcWk
# 4UxuY+PynPjgw9nV/35gRAhC3L81B3/bIaBb659+Vxn9kT2jUztrkmep/aLb+4xJ
# bKZHyvahAEx2XKHafkeKtjiMqcUf/2BG935A591GsllvWwIDAQABo4IBZDCCAWAw
# HwYDVR0jBBgwFoAUMuuSmv81lkgvKEBCcCA2kVwXheYwHQYDVR0OBBYEFA8qyyCH
# KLjsb0iuK1SmKaoXpM0MMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYEVR0gADAIBgZn
# gQwBBAEwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRv
# MG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAG/4Lhd2M2bnuhFSCb
# E/8E/ph1RGHDVpVx0ZE/haHrQECxyNbgcv2FymQ5PPmNS6Dah66dtgCjBsULYAor
# 5wxxcgEPRl05pZOzI3IEGwwsepp+8iGsLKaVpL3z5CmgELIqmk/Q5zFgR1TSGmxq
# oEEhk60FqONzDn7D8p4W89h8sX+V1imaUb693TGqWp3T32IKGfIgy9jkd7GM7YCa
# 2xulWfQ6E1xZtYNEX/ewGnp9ZeHPsNwwviJMBZL4xVd40uPWUnOJUoSiugaz0yWL
# ODRtQxs5qU6E58KKmfHwJotl5WZ7nIQuDT0mWjwEx7zSM7fs9Tx6N+Q/3+49qTtU
# vAQsrEAxwmzOTJ6Jp6uWmHCgrHW4dHM3ITpvG5Ipy62KyqYovk5O6cC+040Si15K
# JpuQ9VJnbPvqYqfMB9nEKX/d2rd1Q3DiuDexMKCCQdJGpOqUsxLuCOuFOoGbO7Uv
# 3RjUpY39jkkp0a+yls6tN85fJe+Y8voTnbPU1knpy24wUFBkfenBa+pRFHwCBB1Q
# tS+vGNRhsceP3kSPNrrfN2sRzFYsNfrFaWz8YOdU254qNZQfd9O/VjxZ2Gjr3xgA
# NHtM3HxfzPYF6/pKK8EE4dj66qKKtm2DTL1KFCg/OYJyfrdLJq1q2/HXntgr2GVw
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhgwghoUAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQNHMXGcKTvS+1BVH0aUkhS+GaVfDunvXFQLq4icfIxSi5ovjSM6kjGvz
# YqWu4gblE3l88X0isZKZk0Hq/7zwZHYwDQYJKoZIhvcNAQEBBQAEggGAiTfMNXHc
# JLQmiypkQw5owDa4c/KvpHR6cYBNtaFlYmlKPmQIPThGHtfvZwOdgePCiMLesI26
# I235j2zFvAVMjhTqgiWtCfK8bVN8H47fM8LUES68z0N+F8IjQarQSP83AJ8mI8OB
# Kj+LMfkapgJP8sde/o0bx3aHW3BvnNu46rtUumCpI/xBfhIEnTY59+kGeI70z2K6
# 8zeYyPbpbVY+dpvbX6vsXcszc03+/uvm+t+OzrL12LaO1X2wnPg7/TRj6Zr+ztFM
# abmnmT0UO/dVnPUZfg4g4ZMwCZlmAgWIRPjdB5pwhVgIju8/asn94DbTInRiDL6a
# wmrIpMzU49Cvx7Nqly6amrIb2ZKBr6SLQGKQE40/Z2GlaRgEgVPwhaRHdmn8YGUp
# B2P+WYQwJVo6B9IQEgbw8OdWWUDlpGfh1ZkvrvniJ3TBXnRoag1pa2GIusxbw1ZF
# 9Q6fTAK8W56A5PVDAfzSBgP8S1hp7KaxBihZ4yjHvlk57YVo1GYrfMCUoYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDCltmCqdHEYu5XpjhfTZc3M7WrwQjv3HZco5TcX
# c6Udw0xhyQVIQu3509zby01Kc8wCEQCMbhy32iE/HHLcMLZ3TvEuGA8yMDI0MDcz
# MTIwMTk0MFqgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVow
# SDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQD
# ExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVY
# wamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isg
# HMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFe
# xAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gp
# OWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28
# mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkH
# NwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58
# ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXH
# g2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W
# 1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK
# 8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn
# 783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+K
# PGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1I
# jrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP
# 2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ
# 5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON
# 1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S
# 88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbU
# uXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145
# WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6
# F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso
# /zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG
# 70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEM
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zC
# pyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf
# 1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x
# 4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEio
# ZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7ax
# xLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZ
# OjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJ
# l2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz
# 2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH
# 4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb
# 5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ
# 9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0g
# ADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs
# 7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq
# 3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/
# Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9
# /HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWoj
# ayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEB
# MHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgIFAKCB4TAaBgkq
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTIw
# MTk0MFowKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMGQVLldw7ZHwUEJjywidfwhBgKDh
# 6IiJPAbIeM8PmrIa+tojEKmCDovLwX5/4/KkxjANBgkqhkiG9w0BAQEFAASCAgBs
# MwSUdLQqNvBEMsC0voQMTvuHzDzvkRm6KWnVA4ciixV/mpf2cKDdv2Tbe7bZGV8b
# L9AgdKZrR9LGVCtxnsGub+/TqdusvFP//3MqErp+Lm023/ISzIRFNgxj8aL4yvT7
# /SlxsEj6Ww2b2TjUeNaAH3vWNlS6s+GzqFOCBQlvXQkMO8RenSX1tsuznDB1Vx2f
# bhSKh3GzxKQSGMIXBH/Nz9yf1KMXf4uiHWvhUn1Cg6rQkox4c9saGqyqVFSkEEl8
# qlbE3k5ofA4EWA/qIF4ysu3Rue5ui0HsdsVsAoneldZk2vCxtbZZA5dh3hvgchAo
# DJHxAlmRQGI6m+YSo2YMr/eZbDJKSBp2pl+EXLDJ2Say1TOQeC8rCrbZ5TdYheuB
# F89DjJituNOpEK4TX6QgvbDYpSB0CAwb1lM8ObEMKRzRoDRzpJgpbJb2QQNyxU64
# aDW2yFUDq3deuME/J8v0alpbWfYrmKJ550YOb3ggj2q81P8eE+tG5+eEt1OfzPbu
# c5D4y3FJLZSKCXh2nGjeIxrNK5TaB8WepoIAereIDFxAnXmhX7amQ33lDpTZWQ63
# SzBmwjPem0Jd2sti+K01fBGfomHWmLhYQ64YF+0GKzSjhOL0gdDjcuBMxqbkWEIS
# fglPDGQ0kp1YHN0RLqQ59+fHOqWjFYUUsjReNb63IQ==
# SIG # End signature block
