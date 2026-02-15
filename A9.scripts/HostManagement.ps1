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
.PARAMETER HostName
	Specifies the host name. Required for creating a host.
.PARAMETER IPAddr
	The host’s IP address.
.PARAMETER Domain
	Create the host in the specified domain, or in the default domain, if unspecified.
.PARAMETER FCWWN
	Set WWNs for the host.
.PARAMETER ISCSINames
	Set one or more iSCSI names for the host.
.PARAMETER NQNNames
	Set one or more NQN names for the host.
.PARAMETER ForceTearDown
	If set to true, forces tear down of low-priority VLUN exports.
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
.EXAMPLE
	New-A9Host -HostName MyHost

	Creates a new host.
.EXAMPLE
	PS:> New-A9Host -HostName MyHost -FCWWN 51aCaEC0CABBFA6F -Persona GENERIC_ALUA
#>
[CmdletBinding()]
Param(	[Parameter()]							[String]	$HostName,
		[Parameter()]							[String]	$IPAddr,
		[Parameter(ParameterSetName='FC')]		[String[]]	$FCWWN,
		[Parameter(ParameterSetName='iSCSI')]	[String[]]	$ISCSINames,
		[Parameter(ParameterSetName='NQN')]		[String[]]	$NQNNames,
		[Parameter()][ValidateSet('WINDOWS','GENERIC','GENERIC_ALUA','GENERIC_LEGACY','HPUX_LEGACY','AIX_LEGACY','EGENERA','ONTAP_LEGACY','VMWARE','OPENVMS','HPUX')]
												[String]	$Persona,
		[Parameter()]							[object[]]	$Port,
		[Parameter()]							[String]	$OS,
		[Parameter()]							[String]	$Model,
		[Parameter()]							[String]	$Contact,
		[Parameter()]							[String]	$Location,
		[Parameter()]							[String]	$Comment,		
		[Parameter()]							[String]	$Domain,
		[Parameter()]							[Boolean]	$ForceTearDown
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["name"] = "$($HostName)"
    If ($Domain)  		{	$body["domain"] = "$($Domain)"    	}
	If ($FCWWN)    		{	$body["FCWWNs"] = @($FCWWN)    		} 
	# If ($Port)     		{	$body["port"] = @("0:3:3") }
	
	If ($ForceTearDown)	{	$body["forceTearDown"] = $ForceTearDown}
	If ($ISCSINames)	{	$body["iSCSINames"] = $ISCSINames	}
	$PersonaHash = @{ 'GENERIC' = 1;'GENERIC_ALUA'=2;'GENERIC_LEGACY'=3;'HPUX_LEGACY'=4;'AIX_LEGACY'=5;'EGENERA'=6;'ONTAP_LEGACY'=7;'VMWARE'=8;'OPENVMS'=9;'HPUX'=10; 'WINDOWS'=11}
	if ($Persona)		{	$body['persona'] = $PersonaHash[$Persona] }
	# If ($Port)     		{	$body["port"] = $Port    			}
	# BElow are the Descriptors
	
	$DescriptorsBody = @{}   
	If ($IPAddr) 		{	$DescriptorsBody["IPAddr"] = "$($IPAddr)"	    }
	If ($OS)  			{	$DescriptorsBody["os"] = "$($OS)" 				}
	If ($Model) 		{	$DescriptorsBody["model"] = "$($Model)"    		}
	If ($Contact)		{	$DescriptorsBody["contact"] = "$($Contact)" 	}
	If ($Comment)		{	$DescriptorsBody["Comment"] = "$($Comment)"		}
	If ($Location)		{	$DescriptorsBody["location"] = "$($Location)"   }
	if($DescriptorsBody.Count -gt 0){	$body["descriptors"] = $DescriptorsBody}
    
	$Result = $null
    $Result = Invoke-A9API -uri '/hosts' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			Get-A9Host -HostName $HostName
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
.EXAMPLE
	PS:> Add-A9RemoveHostWWN -HostName MyHost -FCWWNs "$wwn" -AddWwnToHost
.EXAMPLE	
	PS:> Add-A9RemoveHostWWN -HostName MyHost -FCWWNs "$wwn" -RemoveWwnFromHost
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
	[Parameter(Mandatory)]  [String]	$HostName,
	[Parameter()]    		[String]	$ChapName,
	[Parameter()] 			[int]		$ChapOperationMode,
	[Parameter()]    		[Switch]	$ChapRemoveTargetOnly,
	[Parameter()]    		[String]	$ChapSecret,
	[Parameter()]    		[Switch]	$ChapSecretHex,
	[Parameter()]
    [ValidateSet('INITIATOR','TARGET')]		
							[String]	$ChapOperation,
	[Parameter()]    		[String]	$Descriptors,
	[Parameter()]    		[String[]]	$FCWWN,
	[Parameter()]    		[Switch]	$ForcePathRemoval,
	[Parameter()]    		[String[]]	$iSCSINames,
	[Parameter()]			[String]	$NewName,
	[Parameter()]
	[ValidateSet('ADD','REMOVE')]			
							[String]	$PathOperation,
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
			if($NewName)	{	Get-A9Host -HostName $NewName	}
			else			{	Get-A9Host -HostName $HostName }
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
	PS:> Remove-Host -HostName MyHost
.PARAMETER HostName 
	Specify the name of Host to be removed.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[String]	$HostName
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

Function Set-A9Host
{
<#
.SYNOPSIS
	Modify a Single Host record.
.DESCRIPTION
	This comamnd will let you add or remove paths from a single host, or add or remove Chap secrets from a single host record, or change the persona, name, or description of a host record.. 
.EXAMPLE
	PS:> Set-a9host 
.PARAMETER HostName
	Specify name of the Host record that is to be modified, this is a required parameter.
.PARAMETER AddInitiator
    This switch is used to tell the command that you be adding an initiator to a host, either iSCSI or FC or NVMe
.PARAMETER RemoveInitiator
    This switch is used to tell the command that you will be removing an initiator from a host record, either iSCSI, FC, or NVMe
.PARAMETER ForcePathRemoval
    This switch is only used on an initiator remmoval, and will override the default behaviour. By default an initiator in use with mapped paths, will not be removed.
.PARAMETER NewName
    This allows you to change the name of the Host Record
.PARAMETER NewDescription
    This allows you to alter the description of a Host Record.
.PARAMETER NewPersona
    This allows you to change the persona of a host, which alters the way multipathing and volume presenation is made to a host. 
    The valid values are 'GENERIC','GENERIC_ALUA','GENERIC_LEGACY','AIX_LEGACY','NetApp_ONTAP','VMWARE','OPENVMS','HPUX','WindowsServer','AIX_ALUA','Solaris'
.PARAMETER InitiatorWWNorIQN
    This is the value of the initiator to be added or removed, this will either be a Fc WWPN (hexidecimal 16 digits) or an iSCSI IQN.
.PARAMETER ChapName
    This allows you to either create a new iSCSI CHAP relationship or remove an existing one, you must supply the name to call this chap relationship
.PARAMETER ChapModify   
    This tells the command that you either want to add a chap secret or remove a chap secret, Add and Remove are the only valid options.
.PARAMETER CHAPOperationMode
    This identifies if the chap secret is an Initiator or Target secret, The only valid values are Initiator or Target
.PARAMETER CHAPSecret
    This is the string value of the Chap secret to be installed if a Chap relationship is being added.
#>
[CmdletBinding(DefaultParameterSetName="ADD")]
Param(	[Parameter(mandatory, ParameterSetName='Add')]
        [Parameter(mandatory, ParameterSetName='Remove')]	
        [Parameter(mandatory, ParameterSetName='Chapaddremove')]	
        [Parameter(mandatory, ParameterSetName='ChapModify')]	
        [Parameter(mandatory, ParameterSetName='Modify')]       [String]	$HostName,

        [Parameter(mandatory, ParameterSetName='Add')]          [switch]    $AddInitiator,
        [Parameter(mandatory, ParameterSetName='Remove')]       [switch]    $RemoveInitiator,
        [Parameter(	ParameterSetName='Remove')]      	 		[switch]    $ForcePathRemoval,
        
        [Parameter(ParameterSetName='Modify')]                  [String]	$NewName,
        [Parameter(ParameterSetName='Modify')]                  [String]	$NewDescription,
        [Parameter(ParameterSetName='Modify')] 
        [ValidateSet('GENERIC','GENERIC_ALUA','GENERIC_LEGACY','AIX_LEGACY','NetApp_ONTAP','VMWARE','OPENVMS','HPUX','WindowsServer','AIX_ALUA','Solaris')]
                                                                [String]	$NewPersona,

        [Parameter(mandatory, ParameterSetName='Add')]      
        [Parameter(mandatory, ParameterSetName='Remove')]	    [string]    $InitiatorWWNorIQN,

        [Parameter(mandatory, ParameterSetName='ChapAddRemove')][string]    $ChapName,        

        [Parameter(mandatory, ParameterSetName='ChapAddRemove')][string]   
        [ValidateSet('Add','Remove')]                           [string]    $ChapModify,

        [Parameter(mandatory, ParameterSetName='ChapAddRemove')]  
        [validateset('Initiator','Target')]                     [String]    $CHAPOperationMode,
        
        [Parameter(ParameterSetName='ChapAddRemove')]           [String]	$CHAPSecret
)
Begin 
{	if ( $PSCmdlet.ParameterSetName -eq 'API' )
        {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                {	$PSetName = 'API'
                }
            else{	return "No Connection Found"
                }
        }
}
Process 
{	
    $body = @{}    
    switch($PSCmdlet.ParameterSetName)
        {   'Add'   {   if ( $InitiatorWWNorIQN.length -eq 16 )
                            {   write-verbose "Detected in $InitiatorWWNorIQN that this appears to be a WWPN" 
                                $body["FCWWNs"] = @{ wwn= $InitiatorWWNorIQN}
                            }
                        elseif ( $InitiatorWWNorIQN.contains('iqn') ) 
                            {   write-verhose "Detected in $InitiatorWWNorIQN that this appears to be a WWPN"
                                $body["iSCSINames"] = $InitiatorWWNorIQN
                            }
                        else{   write-warning "The $InitiatorWWNorIQN apperas to be neither a WWN or an iSCSI IQN"  
                                return
                            }
                        $body["pathOperation"] = 1
                    }
            'Remove'{   if ( $InitiatorWWNorIQN.length -eq 16 )
                            {   write-verbose "Detected in $InitiatorWWNorIQN that this appears to be a WWPN" 
                                $body["FCWWNs"] = @($InitiatorWWNorIQN)
                            }
                        elseif ( $InitiatorWWNorIQN.contains('iqn') ) 
                            {   write-verhose "Detected in $InitiatorWWNorIQN that this appears to be a WWPN"
                                $body["iSCSINames"] = $InitiatorWWNorIQN
                            }
                        else{   write-warning "The $InitiatorWWNorIQN apperas to be neither a WWN or an iSCSI IQN"  
                                return
                            }
                        if ( $ForcePathRemoval) 
                            {   $body["forcePathRemoval"] = $true
                            }
                        $body["pathOperation"] = 2  
                    }
            'Modify'{   if ( $NewName ) 
                            {   $body["newName"] = $NewName }
                        if ( $NewPersona )
                            {   $PersonaHash = @{'GENERIC'=1;'GENERIC_ALUA'=2;'GENERIC_LEGACY'=3;'AIX_LEGACY'=5;'NetApp_ONTAP'=7;'VMWARE'=8;'OPENVMS'=9;'HPUX'=10;'WindowsServer'=11;'AIX_ALUA'=12;'Solaris'=13 }
                                $PersonaValue = $personahash["$NewPersona"]
                                $body["persona"] = $PersonaValue
                            }
                        if ( $NewDescription) 
                            {   $body["descriptors"] = $NewDescription
                            }
                    }
            'ChapAddRemove'
                    {   $body["chapName"]= $ChapName
                        $ChapModifyHash=@{"add"=1; "remove"=2}
                        $ChapModifyValue = $ChapModifyHash["$ChapModify"]  
					    $body["chapOperation"]=$ChapModifyValue

                        $ChapOperationModeHash = @{"Initiator"=1; "Target"=2}
                        $chapOperationModeValue = $ChapOperationModeHash["$ChapOperationMode"] 
                        $body["chapOperationMode"]=$ChapOperationModeValue
    
                        if ( $ChapSecret ) { $body["chapSecret"]=$Chapsecret }
                    }
        }
    $Result = $null
    $uri = $uri + '/hosts/' + $hostname
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			Get-A9Host -HostName $HostName
		}
	else
		{	Write-Error "Failure:  While creating Host:$HostName " 
			return $Result.StatusDescription
		}	
}
}

