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
	[Parameter(Mandatory)]    [String]	$HostName,
	[Parameter()]    [String]	$ChapName,
	[Parameter()] 	[int]		$ChapOperationMode,
	[Parameter()]    [Switch]	$ChapRemoveTargetOnly,
	[Parameter()]    [String]	$ChapSecret,
	[Parameter()]    [Switch]	$ChapSecretHex,
	[Parameter()]
    [ValidateSet('INITIATOR','TARGET')]		[String]	$ChapOperation,
	[Parameter()]    [String]	$Descriptors,
	[Parameter()]    [String[]]	$FCWWN,
	[Parameter()]    [Switch]	$ForcePathRemoval,
	[Parameter()]    [String[]]	$iSCSINames,
	[Parameter()]	[String]	$NewName,
	[Parameter()]
	[ValidateSet('ADD','REMOVE')]			[String]	$PathOperation,
	[Parameter()]
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
# MIIsVQYJKoZIhvcNAQcCoIIsRjCCLEICAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBJhNzj4LfR
# zWVzHNms+4dn2KUTul6tbKsNw+AIpyqE9y3f26s4CkA7YgZ4vZpFQrZ70gDYL3kL
# ouES1cwuyjDNoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhIwghoOAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQIk9qggjctHKMZuNug/eFqAGCxIVfRZxOCJEWzjSTAd74RhJCdHa7kRm
# l7Ekl3/JOebw5RoWBihrgbQBupLwGaowDQYJKoZIhvcNAQEBBQAEggGAB7ax4xb2
# j2FyeqQX+47vKMMomnM45WAyWdO2eC01l17NoaIZ9g2lEUXLV8wEj4jQLkCyp+lv
# 32EamT2LU8OnxyQ8KrFk9/aw7c6lSFf8xO5HuJTy06/TEhkLVVWJCqEYrM3caDUf
# fiQpXNPJ4A0auezm+tLV/dasgBtw6JKC98R2IX4AKWSYWePcTbIV2/f8aolWxDhZ
# OueC3rqVHTOXE8YTV4XOd8El0rkmFB2ci5zkKbNm6ljCUsTnQTx7H/+krfqbrSR5
# RgRX0hSkjXSN/bb7kFRBZZb6CAqocT0R7UnhnIcaRF+85jX+oquULvMAyY4nJTC+
# UUEPOGfE7hKGebER1uGzR+v2hekUvpbmWwu1CI6T6prscsaaRBt76GErwr4ju/5H
# wCNlViKTVwycUgHWyKT7yHoGGYSTU4Xhx+rcAND+u/7rFvEg4CKEeKKTWc0Zy65N
# X62y+pIaVHWl3jW+UTssGxEuTGjfS73ZMS5VyLSbmkvjb4Huedba3Q8ooYIXWzCC
# F1cGCisGAQQBgjcDAwExghdHMIIXQwYJKoZIhvcNAQcCoIIXNDCCFzACAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDA2TsWwrVcs24VxMPGLIRblPeZKDVmb6eBUDAQb
# K/64bqMrBRdmPz1sXXDKqv4A7jECEQCM2QuoeFuwgqZhTMB0pHduGA8yMDI1MDUx
# NTIyNTM1MlqgghMDMIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVow
# QjELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdp
# Q2VydCBUaW1lc3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL5qc5/2lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L
# 660x5XltSVhhK64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLusl
# xdr9Qq82aKcpA9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7a
# vVnpUVmPvkxT8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl
# 7/r419CvEYVIrH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+N
# BikDO0mlUh902wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVki
# qLq+ISTdEjJKGjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5
# n10jxmGpxoMc6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h
# 6gYldp4FCMgrXdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNe
# REXAu2xUDEW8aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLq
# fY/M/SdV6mwWTyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIB
# hzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggr
# BgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0j
# BBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGal
# Y17uT5IfdqBbMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBp
# bmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tO
# CB3RKE/P09x7gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSX
# gmUrDKNSQqGTdpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPn
# vIWrqVogK0qM8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM
# 2UeUUW/8z3fvjxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlT
# VYzqfLDbe9PpBKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ
# /xll/HjO9JbNVekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef
# 4uaZFORNekUgQHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk91
# 04WQzYuVNsxyoVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7
# ucykW7eaCuWBsBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZD
# BD+XgbF+23/zBjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3K
# eFUCS7tpFk7CrDqkMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkq
# hkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBU
# cnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFV
# xyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8z
# H1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE9
# 8NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iE
# ZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXm
# G6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVV
# JnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz
# +ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8
# ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkr
# qPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKo
# wSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3I
# XjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaA
# FOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4
# oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqG
# SIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQ
# XeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwI
# gqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs
# 5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAn
# gkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnG
# E4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9
# P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt
# +8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Z
# iza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgx
# tGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimH
# CUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCC
# BY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290
# IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE9
# 8orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9S
# H8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g
# 1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RY
# jgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgD
# EI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNA
# vwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDg
# ohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQA
# zH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOk
# GLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHF
# ynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gd
# LfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYE
# FOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# dDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkq
# hkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7
# IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/5
# 9PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0
# POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISf
# b8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhU
# LSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEBMHcwYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QQIQC65mvFq6f5WHxvnpBOMzBDANBglghkgBZQMEAgIFAKCB4TAaBgkqhkiG9w0B
# CQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI1MDUxNTIyNTM1Mlow
# KwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQU29OF7mLb0j575PZxSFCHJNWGW0UwNwYL
# KoZIhvcNAQkQAi8xKDAmMCQwIgQgdnafqPJjLx9DCzojMK7WVnX+13PbBdZluQWT
# mEOPmtswPwYJKoZIhvcNAQkEMTIEMDkzJ+XqE2THvMudDedGyoXamR4jQP0nxO+K
# mC4R6n4+9Cvxa1UZ2OwGjWCgeXa1TjANBgkqhkiG9w0BAQEFAASCAgCABVRuM34+
# ltQ3mkGkqqiiKvmIgFEeVwKYXQ0yM9SnPNggRkCI8P/5Tm/6uhm5cY+okZGvZaIR
# gl4TAJYYeX0g6EjRwmhYJOarsz7PBZHAbWtdTt0yIO0B8tEtW8pw2xyrc83g8Jsk
# gwOGe2o67Q2Ix3my1m1ULOTnt8awc4SokxCw74N/DJTmxyKneBNiVXgqc9BU00sN
# yvGOI+DKw8VcbJJjpMZYqlzaU9RZvk5DpuedERw/9VugVoA998Lb5S2oAE0MxOoM
# f9vMUidyroAKMUL1qjCnReBLjjSSdmPkhYrRVXkJ1KxVVk08kWJtzujlH3MDPF4W
# jmV9Qfp71jOhrPwNVa9zsPe9v6QPvTYedkTGIpE6q3xb7+229KxgV8ApcCPyhZGf
# 1+l3WMjMaPoT3g5nXV6X6lCYB1kCY+oliaTVDIwE020q78XXTFETd3POhLXgmnRz
# OJkASrMwZP+pqV+g4cIQJ7pkqdXCWFDkIlqPkJhQOUmmQKQ1BPl6Ay1bG2KczYXN
# n5Jv/nD8crmogR45KmbNjwGJbTZ3QuCxw2pu9qNtbMBULb0wGNJFjRrinBAhLnGD
# 2xJvyAz17McFehDjimij3mPbtd1JCr7+NzrF13S2+YUtYfFlb2IYHRPR+jTw51k0
# 88TG099XvAS2ET2WtnpiY660pCy5uogO3Q==
# SIG # End signature block
