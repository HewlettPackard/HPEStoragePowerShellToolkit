####################################################################################
## 	© 2024 Hewlett Packard Enterprise Development LP
##

Function Get-A9HostSet 
{
<#
.SYNOPSIS
	Get Single or list of Hotes Set.
.DESCRIPTION
	Get Single or list of Hotes Set.  the command will attempt to use the API to accomplish the task, 
    if the API is unavalable or other parameters are used, the command will attempt to fail back to a SSH type connection to accomplish the goal.  
.PARAMETER HostSetName
	Specify name of the Hotes Set. This Parameter is valid for API and SSH type connections.
.EXAMPLE
    PS:> Get-A9HostSet | format-table
    
    Cmdlet executed successfully
    id uuid                                 name             setmembers
    -- ----                                 ----             ----------
    0  a6751a4a-35f0-4641-a20c-6ab79f644c9a test             {bm9}
    25 9377a9b4-e1c3-445f-a34d-c6d571ba5c82 tmaas_cluster1   {ftc-tmaas-cl1-esx1, ftc-tmaas-cl1-esx2, ftc-tmaas-cl1-esx3, ftc-tmaas-cl1-esx4…}
    28 9a8fc3dc-30c6-4c95-a8b0-bc3437217a6c Veeambkpsrv      {veeam12bkpsrv}
.EXAMPLE
	PS:> Get-A9HostSet -HostSetName MyHostSet

	Get the information of given Hotes Set.
.EXAMPLE
	PS:> Get-A9HostSet | where {$_.setmembers -contains 'MyServer' }

	This replicates the old feature of -members so that the command can be simplified. This allows you to only return HostSets that contains a specific server.
.EXAMPLE
	PS:> Get-A9HostSet | where {$_.id -like '16'}

	The following replicates using an ID Filter to retreive only a known ID HostSet
.EXAMPLE
	PS:> Get-A9HostSet | where {$_.uuid -like '4eee167a-1a69-4620-9c0e-86a2c9b5772f'}

	The following replicates using an ID Filter to retreive only a known ID HostSet
.NOTES
    CLI Options such as -D or Members can be derived directly from the returned objects, as such they are not valid parameteres to include in the command.
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	[Parameter(ParameterSetName='API')]	    [String]	$HostSetName
    )
Begin 
    {	Test-A9Connection -CLientType 'API'
    }
Process 
    {	$Result = $null
        $dataPS = $null		
        $uri = '/hostsets'
        # if($HostSetName)    {	$uri += '/' + $HostSetName    }
        $Result = Invoke-A9API -uri $uri -type 'GET'
        If ($Result.StatusCode -eq 200)
            {	# if the return data is one item, then the sub-object members does not exist
                $dataPS1 = ($Result.content | ConvertFrom-Json)
                if ($dataPS1.members) { $dataPS = $dataPS1.members }
                if ($dataPS.Count -gt 0)
                    {	write-host "Cmdlet executed successfully" -foreground green
                        $NewObj = @(    foreach( $Item in $DataPS)	
                                            {   $NewItem=@{PSTypeName = "HPE.A9Storage.HostSet"}
                                                $Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
                                                $DataSetType = "HPE.A9Storage.HostSet"
                                                $NewItem.PSTypeNames.Insert(0,$DataSetType)
                                                $DataSetType = $DataSetType + ".TypeName"
                                                $NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
                                                [PSCustomObject]$NewItem
                                            }
                                    )
                        if ( $HostSetName ) 
                            {   return ($NewObj | where-object {$_.name -like $HostSetName } )
                            }
                        else
                            {   return $NewObj
                            }
                    }
                else
                    {	Write-Error "Failure:  While Executing Get-A9HostSet. Expected Result Not Found." 
                        return 
                    }		
            }
        else
            {	Write-Error "Failure:  While Executing Get-A9HostSet." 
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
                                        return $NewObj
                                    }
                                else
                                    {	Write-Error "Failure:  While Executing Get-HostPersona_WSAPI." 
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

