## 	©2025 Hewlett Packard Enterprise Development LP

Function Get-A9Host
{
<#
.SYNOPSIS
	Get Single or list of Hotes.
.DESCRIPTION
	Get Single or list of Hotes. You may filter the hosts by host name, or wwn or iscsi.
.PARAMETER HostName
	Specify name of the Host.
.PARAMETER WWN
	Specify WWN of the Host.
.PARAMETER ISCSI
	Specify ISCSI of the Host.
.PARAMETER ListPersona
    This option allows you to interrogate the array to determine which host personas are supported.
.EXAMPLE
	PS:> get-a9host | format-table
    Cmdlet executed successfully

    id name              descriptors          FCPaths                                                                      iSCSIPaths
    -- ----              -----------          -------                                                                      ----------
    0 bm9                @{os=VMware (ESXi)}  {@{wwn=10009440C9CF767B; portPos=}, @{wwn=10009440C9CF767B; portPos=}…} {}
    5 virt-r-node3                            {}                                                                           {@{name=iqn…
    7 ftc-tmaas-cl1-esx1 @{os=VMware (ESXi)}  {@{wwn=1000FC15B443AE94; portPos=}, @{wwn=1000FC15B443AE94; portPos=}}  {}
.EXAMPLE
    PS:> get-a9host -hostname | convertto-json -depth 5

    This command will replicate the '-d', 'persona' as well as the '-verbose' option from the CLI, as you can gather exactly the same information from the API returned data
.EXAMPLE
	Get-A9HostWithFilter -WWN 123 

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
.EXAMPLE
    Get-A9Host -ListPersona
    Cmdlet executed successfully

    wsapiAssignedId  name             OS
    ---------------  ----             --
    2                Generic-ALUA     {Citrix Hypervisor(XenServer), OE Linux UEK, Oracle VM x86, RHE Linux…}
    8                VMware           {VMware (ESXi)}
    10               HPUX             {HP-UX}
    11               WindowsServer    {Windows Server}
    12               AIX              {AIX, IBM VIO Server}
    17               Solaris          {Solaris}
.NOTES
    To obtain the supported list of host personas, use Get-A9HostPersona. 
    Additionally, the command Get-A9HostWithFilters functionality has been added to this commands functionality
#>
[CmdletBinding(DefaultParameterSetName="None")]
Param(	[Parameter(mandatory, ParameterSetName='ByHostname')]       [String]	$HostName,
        [Parameter(ParameterSetName='ByFilter')]                    [String[]]	$ISCSI,
        [Parameter(ParameterSetName='ByFilter')]                    [String[]]	$WWN,
        [Parameter(mandatory, ParameterSetName='Persona')]          [switch]	$ListPersona        
    )
Begin 
    {	Test-A9Connection -CLientType 'API'
    }
Process 
    {	$Result = $null
        $dataPS = $null	
        $Query="?query=""  """	                    
        switch($PSCmdlet.ParameterSetName)
            {   'none'      
                            {   $uri = '/hosts'
                            }
                'ByHostname'
                            {   $uri = '/hosts/'+$HostName                
                            }
                'ByFilter'  
                            {   if($WWN)
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
                                    {	if($WWN)
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
                                $uri = '/hosts/'+$Query
                            }
                'Persona'   
                            {   $Result = Invoke-A9API -uri '/hostpersonas' -type 'GET' 
                                If($Result.StatusCode -eq 200)
                                    {	$dataPS = ($Result.content | ConvertFrom-Json).members	
                                        write-host "Cmdlet executed successfully" -foreground green
                                        $NewObj = @(    foreach( $Item in $DataPS)	
                                                            {   $NewItem=@{PSTypeName = "HPE.A9Storage.HostPersona"}
                                                                $Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
                                                                $DataSetType = "HPE.A9Storage.HostPersona"
                                                                $NewItem.PSTypeNames.Insert(0,$DataSetType)
                                                                $DataSetType = $DataSetType + ".TypeName"
                                                                $NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
                                                                [PSCustomObject]$NewItem
                                                            }
						                            )
                                        write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                                        return $NewObj
                                    }
                                else
                                    {	Write-Error "Failure:  While Executing Get-A9HostPersona." 
                                        return $Result.StatusDescription
                                    }
            
                            }
            }
        $Result = Invoke-A9API -uri $uri -type 'GET' 
        If($Result.StatusCode -eq 200)
            {	$dataPS = ($Result.content | ConvertFrom-Json).members
                if($dataPS.Count -gt 0)
                    {	write-host "Cmdlet executed successfully" -foreground green
                        $NewObj = @(    foreach( $Item in $DataPS)	
                                        {   $NewItem=@{PSTypeName = "HPE.A9Storage.Host"}
                                            $Enum = $Item.persona
												Switch ($Enum)
													{   1	{   $desc = 'Generic'       }
                                                        2	{   $desc = 'Generic_ALUA'  }
                                                        3	{   $desc = 'Generic_Legacy'}
                                                        4	{   $desc = 'HPUX_Legacy'   }
                                                        5	{   $desc = 'AIX_Legacy'    }
                                                        6	{   $desc = 'Egenera'       }
                                                        7	{   $desc = 'ONTAP_Legacy'  }
                                                        8	{   $desc = 'VMWare'        }
                                                        9	{   $desc = 'OpenVMS'       }
                                                        10	{   $desc = 'HPUX'          }
                                                        11	{   $desc = 'WindowsServer' }
                                                        12	{   $desc = 'AIX_ALUA'      }
                                                        17  {   $desc = 'Solaris'       }
													}
												if ($Desc) 
													{   $NewItem['personaDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}
										    $Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
											$DataSetType = "HPE.A9Storage.Host"
											$NewItem.PSTypeNames.Insert(0,$DataSetType)
											$DataSetType = $DataSetType + ".TypeName"
											$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
											[PSCustomObject]$NewItem
										}
						            )

                        write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
                        return $NewObj
                    }
                else
                    {	Write-warning "warning:  While Executing Get-Host. Command Executed successfully but returned not results " 
                        return 
                    }		
            }
        else
            {	Write-Error "Failure:  While Executing Get-Host" 
                return $Result.StatusDescription
            }                
    }
}

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
.PARAMETER IQN
	Set one or more iSCSI IQN (iSCSI Qualified Name) for the host.
.PARAMETER NQN
	Set one or more NQN (NVMe Qualified Name) for the host.
.PARAMETER NQNTransportType
    This parameter is required when setting a NQN type host record, and can be either FC or TCP types. 
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
    You must pass in a Port type object. which will look like this @( @{node=1}; @{slot=3}; @{cardPort=2} )	
    Specifies the desired relationship between the array ports and the host for target-driven zoning. Use this option when the Smart SAN license is installed only.
.EXAMPLE
	New-A9Host -HostName MyHost -Persona WINDOWS -IQN 'iqn.1995-05.com.microsoft:hera.lionetti.lab'

	Creates a new host of type Windows Server with the given iSCSI IQN.
.EXAMPLE
	New-A9Host -HostName MyHost -Persona WINDOWS -WWPN '51402ec001178f6f'

	Creates a new host of type Windows Server with the give Fibre Channel World Wide Name.
.EXAMPLE
	New-A9Host -HostName MyHost -persona GENERIC_ALUA -NQN 'nqn.2016-06.lab.lionetti.zeus:zeus' -NQNtransportType TCP

	Creates a new host of type Generic_ALUA which supports Linux with the given NVMe Qualified Name using a TCP based transport type.
.Example 
	New-A9Host -HostName MyHost -Persona WINDOWS -IQN 'iqn.1995-05.com.microsoft:hera.lionetti.lab' -ports @(@(@{node=0};@{slot=3};@{cardPort=3}),@(@{node=1};@{slot=3};@{cardPort=3}))
    
	Creates a new host of type Windows Server but only expose that device on the following ports (0,3,3) and (1,3,3), and please be aware that cardPort is case sensitive.
#>
[CmdletBinding(DefaultParameterSetName='None')]
Param(	[Parameter(Mandatory)]							[String]	$HostName,
		[Parameter()]							        [String]	$IPAddr,
		[Parameter(ParameterSetName='FC',mandatory)]	[String[]]	$WWPN,
		[Parameter(ParameterSetName='iSCSI',mandatory)]	[String[]]	$IQN,
		[Parameter(ParameterSetName='NQN',mandatory)]	[String[]]	$NQN,
        [Parameter(ParameterSetName='NQN',mandatory)]   [ValidateSet('FC','TCP')]					
                                                        [String]    $NQNTransferType,
		[Parameter()][ValidateSet('WINDOWS','GENERIC','GENERIC_ALUA','GENERIC_LEGACY','HPUX_LEGACY','AIX_LEGACY','EGENERA','ONTAP_LEGACY','VMWARE','OPENVMS','HPUX')]
												        [String]	$Persona,
		[Parameter()]							        [object[]]	$Port,
		[Parameter()]							        [String]	$OS,
		[Parameter()]							        [String]	$Model,
		[Parameter()]							        [String]	$Contact,
		[Parameter()]							        [String]	$Location,
		[Parameter()]							        [String]	$Comment,		
		[Parameter()]							        [String]	$Domain,
		[Parameter()]							        [Boolean]	$ForceTearDown
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["name"] = "$($HostName)"
    If ($Domain)  		{	$body["domain"] = "$($Domain)"    	}
	If ($WWPN)    		{	$body["FCWWNs"] = @($WWPN)    		} 
	If ($NQN)    		{	$body["NQNs"] = @($NQN)    		    
                            $NQNHash = @{'FC' = 1;'TCP'=2}
                            $body["transportType"] = $NQNHash[$NQNTransferType]
                        } 
	If ($ForceTearDown)	{	$body["forceTearDown"] = $ForceTearDown}
	If ($IQN)	        {  	$body["iSCSINames"] = $IQN	        }
	$PersonaHash = @{ 'GENERIC' = 1;'GENERIC_ALUA'=2;'GENERIC_LEGACY'=3;'HPUX_LEGACY'=4;'AIX_LEGACY'=5;'EGENERA'=6;'ONTAP_LEGACY'=7;'VMWARE'=8;'OPENVMS'=9;'HPUX'=10; 'WINDOWS'=11}
	if ($Persona)		{	$body['persona'] = $PersonaHash[$Persona] }
	If ($Port)     		{	$body["port"] = $Port    			}
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
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
			Get-A9Host -HostName $HostName
		}
	else
		{	Write-Error "Failure:  While creating Host:$HostName " 
			return $Result.StatusDescription
		}	
}
}

Function Remove-A9Host
{
<#
.SYNOPSIS
	Remove a Host record from the array.
.DESCRIPTION
	Remove a Host record from the array. 
    Any user with Super or Edit role, or any role granted host_remove permission, can perform this operation. Requires access to all domains.
.PARAMETER HostName 
	Specify the name of Host to be removed.
.EXAMPLE    
	PS:> Remove-Host -HostName MyHost
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
		{	write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
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
.PARAMETER ChapSecretHex    
    The string given for the Chap Secret is in hex, otherwise it is expected to be alphanumeric
.EXAMPLE
	PS:> Set-a9host -hostname CurrentHostName -newName MyHost1

    This example renames a host record from 'CurrentHostName' to 'MyHost1'
.EXAMPLE 
	PS:> Set-a9host -hostname CurrentHostName -AddInitiator -InitiatorWWNorIQN 'iqn.1995-05.com.microsoft:hera.lionetti.lab' 

    This example adds an iSCSI IQN 'iqn.1995-05.com.microsoft:hera.lionetti.lab' to the Host record, note that you can use the command "Get-Initiator | format-table NodeAddress" to obtain your host iSCSI.
.EXAMPLE
	PS:> Set-a9host -hostname CurrentHostName -AddInitiator -InitiatorWWNorIQN '51402ec001178f6f' 

    This example adds a World Wide Port Name '51402ec001178f6f' to the Host record, note that you can use the command "Get-Initiator | format-table PortAddress" to obtain your host World Wide Port Address.
#>
[CmdletBinding(DefaultParameterSetName="Add")]
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
        [Parameter(ParameterSetName='ChapAddRemove')]           [String]	$CHAPSecret,
        [Parameter(ParameterSetName='ChapAddRemove')]    		[Switch]	$ChapSecretHex,
        [Parameter(ParameterSetName='Modify')]          		[Switch]	$ChapRemoveTargetOnly
)
Begin 
{	Test-A9Connection -CLientType 'API'
}
Process 
{	
    $body = @{}    
    switch($PSCmdlet.ParameterSetName)
        {   'Basic' {

                    }
            'Add'   
					{   if ( $InitiatorWWNorIQN.length -eq 16 )
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
            'Remove'
					{   if ( $InitiatorWWNorIQN.length -eq 16 )
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
                        if ( $ForcePathRemoval)         {   $body["forcePathRemoval"] = $true    }
                        $body["pathOperation"] = 2  
                    }
            'Modify'
					{   if ( $NewName )                 {   $body["newName"] = $NewName }
                        if ( $NewPersona )              {   $PersonaHash = @{'GENERIC'=1;'GENERIC_ALUA'=2;'GENERIC_LEGACY'=3;'AIX_LEGACY'=5;'NetApp_ONTAP'=7;'VMWARE'=8;'OPENVMS'=9;'HPUX'=10;'WindowsServer'=11;'AIX_ALUA'=12;'Solaris'=13 }
                                                            $PersonaValue = $personahash["$NewPersona"]
                                                            $body["persona"] = $PersonaValue
                                                        }
                        if ( $NewDescription)           {   $body["descriptors"] = $NewDescription  }
                        if ( $ChapRemoveTargetOnly )    {   $body["chapRemoveTargetOnly"] = $true   }
                    }
            'ChapAddRemove'
                    {   $body["chapName"]= $ChapName
                        $ChapModifyHash=@{"add"=1; "remove"=2}
                        $ChapModifyValue = $ChapModifyHash["$ChapModify"]  
					    $body["chapOperation"]=$ChapModifyValue
                        $ChapOperationModeHash = @{"Initiator"=1; "Target"=2}
                        $chapOperationModeValue = $ChapOperationModeHash["$ChapOperationMode"] 
                        $body["chapOperationMode"]=$ChapOperationModeValue
                        if ( $ChapSecret )  { $body["chapSecret"]=$Chapsecret
                                                if ( $ChapSecretHex )  { $body["chapSecretHex"] = $true } 
                                            }

                    }
        }
    $Result = $null
    $uri = $uri + '/hosts/' + $hostname
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if ( $Result.StatusCode -eq 201 )
		{	Write-Error "Failure:  While creating Host:$HostName " 
			return $Result.StatusDescription
		}	
    write-host "Success : Executing $($PSCmdlet.MyInvocation.MyCommand.Name)" -ForegroundColor Green
	Get-A9Host -HostName $HostName
}
}
