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
.EXAMPLE

    PS C:\Users\clionetti\Desktop\Powershell\HPEStoragePowerShellToolkit> Get-A9HostSet
    Cmdlet executed successfully

    id uuid                                 name             setmembers
    -- ----                                 ----             ----------
    0  a6751a4a-35f0-4641-a20c-6ab79f644c9a test             {bm9}
    25 9377a9b4-e1c3-445f-a34d-c6d571ba5c82 tmaas_cluster1   {ftc-tmaas-cl1-esx1, ftc-tmaas-cl1-esx2, ftc-tmaas-cl1-esx3, ftc-tmaas-cl1-esx4…}
    28 9a8fc3dc-30c6-4c95-a8b0-bc3437217a6c Veeambkpsrv      {veeam12bkpsrv}
.EXAMPLE
    PS C:\Users\clionetti\Desktop\Powershell\HPEStoragePowerShellToolkit> Get-A9HostSet -UseSSH
    Id Name             Members
    0 test              bm9
    25 tmaas_cluster1   ftc-tmaas-cl1-esx1
                        ftc-tmaas-cl1-esx2
                        ftc-tmaas-cl1-esx3
                        ftc-tmaas-cl1-esx4
                        ftc-tmaas-cl1-esx5
.EXAMPLE
	PS:> Get-A9HostSet -HostSetName MyHostSet

	Get the information of given Hotes Set.
.EXAMPLE
	PS:> Get-A9HostSet -Members MyHost

	Get the information of Hotes Set that contain MyHost as Member.
.EXAMPLE
	PS:> Get-A9HostSet -Members "MyHost,MyHost1,MyHost2"

	Multiple Members.
.EXAMPLE
	PS:> Get-A9HostSet -Id 10

	Filter Host Set with Id
.EXAMPLE
	PS:> Get-A9HostSet -Uuid 10

	Filter Host Set with uuid
.EXAMPLE
	PS:> Get-A9HostSet -Members "MyHost,MyHost1,MyHost2" -Id 10 -Uuid 10

	Multiple Filter
.PARAMETER HostSetName
	Specify name of the Hotes Set. This Parameter is valid for API and SSH type connections.
.PARAMETER Members
	Specify name of the Hotes. This Parameter is valid for API and SSH type connections.
.PARAMETER Id
	Specify id of the Hotes Set. This Parameter is only available when using a API type connection.
.PARAMETER Uuid
	Specify uuid of the Hotes Set. This Parameter is only available when using a API type connection.
.PARAMETER D
	Show a more detailed listing of each set. This Parameter is only available when using a SSH type connection.
.PARAMETER summary 
    Shows host sets with summarized output with host set names and number of hosts in those sets. This Parameter is only available when using a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(	[Parameter(ParameterSetName='API')]	    
        [Parameter(ParameterSetName='SSH')]	    [String]	$HostSetName,
        [Parameter(ParameterSetName='SSH')]
		[Parameter(ParameterSetName='API')]	    [String]	$Members,
		[Parameter(ParameterSetName='API')]	    [String]	$Id,
		[Parameter(ParameterSetName='API')]	    [String]	$Uuid,
		[Parameter(ParameterSetName='SSH')]	    [Switch]	$D,
		[Parameter(ParameterSetName='SSH')]	    [Switch]	$summary,
        [Parameter(ParameterSetName='SSH')]     [Switch]    $UseSSH 
)
Begin 
{	if ( $PSCmdlet.ParameterSetName -eq 'API' )
        {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                {	$PSetName = 'API'
                }
            else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                        {	$PSetName = 'SSH'
                        }
                }
        }
        elseif ( $PSCmdlet.ParameterSetName -eq 'SSH' )	
        {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                {	$PSetName = 'SSH'
                }
            else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                    return
                }
        }
}
Process 
{	switch ($PSetName)
    {
        'API'   {   $Result = $null
                    $dataPS = $null		
                    $Query="?query=""  """
                    if($HostSetName)
                        {	$uri = '/hostsets/'+$HostSetName
                            $Result = Invoke-A9API -uri $uri -type 'GET' 
                            If($Result.StatusCode -eq 200)
                                {	$dataPS = $Result.content | ConvertFrom-Json
                                    write-host "Cmdlet executed successfully" -foreground green
                                    return $dataPS
                                }
                            else
                                {	Write-Error "Failure:  While Executing Get-HostSet_WSAPI." 
                                    return $Result.StatusDescription
                                }
                        }
                    if($Members)
                        {	$count = 1
                            $lista = $Members.split(",")
                            foreach($sub in $lista)
                                {	$Query = $Query.Insert($Query.Length-3," setmembers EQ $sub")			
                                    if($lista.Count -gt 1)
                                        {	if($lista.Count -ne $count)
                                                {	$Query = $Query.Insert($Query.Length-3," OR ")
                                                    $count = $count + 1
                                                }				
                                        }
                                }		
                        }
                    if($Id)
                        {	if($Members)	{	$Query = $Query.Insert($Query.Length-3," OR id EQ $Id")	}
                            else			{	$Query = $Query.Insert($Query.Length-3," id EQ $Id")	}
                        }
                    if($Uuid)
                        {	if($Members -or $Id)	{	$Query = $Query.Insert($Query.Length-3," OR uuid EQ $Uuid")	}
                            else					{	$Query = $Query.Insert($Query.Length-3," uuid EQ $Uuid")	}
                        }	
                    $uri = '/hostsets'
                    if($Members -Or $Id -Or $Uuid)
                        {	$uri = $uri+'/'+$Query
                        }	
                    $Result = Invoke-A9API -uri $uri -type 'GET'	
                    If($Result.StatusCode -eq 200)
                        {	$dataPS = ($Result.content | ConvertFrom-Json).members
                            if($dataPS.Count -gt 0)
                                {	write-host "Cmdlet executed successfully" -foreground green
                                    return $dataPS
                                }
                            else
                                {	Write-Error "Failure:  While Executing Get-HostSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid." 
                                    return 
                                }		
                        }
                    else
                        {	Write-Error "Failure:  While Executing Get-HostSet_WSAPI." 
                            return $Result.StatusDescription
                        }
        

                }
        'SSH'   {   $GetHostSetCmd = "showhostset "
                    if($D)			{	$GetHostSetCmd +=" -d"				}
                    if($summary)	{	$GetHostSetCmd +=" -summary"		}	
                    if ($Members)	{	$GetHostSetCmd +=" -host $Members"	}
                    if ($hostSetName){	$GetHostSetCmd +=" $hostSetName"	}	
                    else			{	write-verbose "HostSet parameter is empty. Simply return all hostset information "	}
                    $Result = Invoke-A9CLICommand  -cmds  $GetHostSetCmd
                    return $Result
                }
    }
    
}
}


Function Get-A9Host
{
<#
.SYNOPSIS
	Get Single or list of Hotes.
.DESCRIPTION
	Get Single or list of Hotes. the command will attempt to use the API to accomplish the task, 
    if the API is unavalable or other parameters are used, the command will attempt to fail back to a SSH type connection to accomplish the goal. 
.EXAMPLE
	PS:> get-a9host | format-table
    Cmdlet executed successfully

    id name              descriptors          FCPaths                                                                      iSCSIPaths
    -- ----              -----------          -------                                                                      ----------
    0 bm9                @{os=VMware (ESXi)}  {@{wwn=10009440C9CF767B; portPos=}, @{wwn=10009440C9CF767B; portPos=}…} {}
    5 virt-r-node3                            {}                                                                           {@{name=iqn…
    7 ftc-tmaas-cl1-esx1 @{os=VMware (ESXi)}  {@{wwn=1000FC15B443AE94; portPos=}, @{wwn=1000FC15B443AE94; portPos=}}  {}
.EXAMPLE
    PS C:\Users\clionetti\Desktop\Powershell\HPEStoragePowerShellToolkit> get-a9host -usessh | format-table

    Address               Name    Persona       ID Port
    -------               ----    -------       -- ----
    100070106F76081F      bm8     VMware        16 0:3:3
    10009440C9CF767C      bm9     VMware        0  0:3:3
    1000E0071BCE3B3B      BM45    WindowsServer 42 1:3:2
    1000E0071BCE3B3A      BM45    WindowsServer 42 1:3:1
.PARAMETER HostName
	Specify name of the Host.
    .PARAMETER D
	Shows a detailed listing of host and path information. This option can be used with -agent and -domain options. This parameter is only valid for SSH type connections.
.PARAMETER Verb
	Shows a verbose listing of all host information. This option cannot be used with -d. This parameter is only valid for SSH type connections.
.PARAMETER CHAP
	Shows the CHAP authentication properties. This option cannot be used with -d. This parameter is only valid for SSH type connections.
.PARAMETER Descriptor
	Shows the host descriptor information. This option cannot be used with -d. This parameter is only valid for SSH type connections.
.PARAMETER Agent
	Shows information provided by host agent. This parameter is only valid for SSH type connections.
.PARAMETER Pathsum
	Shows summary information about hosts and paths. This option cannot be used with -d. This parameter is only valid for SSH type connections.
.PARAMETER Persona
	Shows the host persona settings in effect. This option cannot be used with -d. This parameter is only valid for SSH type connections.
.PARAMETER Listpersona
	Lists the defined host personas. This option cannot be used with -d. This parameter is only valid for SSH type connections.
.PARAMETER NoName
	Shows only host paths (WWNs and iSCSI names) not assigned to any host. This option cannot be used with -d. This parameter is only valid for SSH type connections.
.PARAMETER Domain 
	Shows only hosts that are in domains or domain sets that match one or more of the specifier <domainname_or_pattern> or set <domainset>
	arguments. The set name <domain_set> must start with "set:". This specifier does not allow listing objects within a domain of which the
	user is not a member. This parameter is only valid for SSH type connections.
.PARAMETER CRCError
	Shows the CRC error counts for the host/port.
.PARAMETER UseSSH
    Will override the parameter set and force the command to use the SSH type operation instead of an API call.
#>
[CmdletBinding(DefaultParameterSetName="API")]
Param(	[Parameter(ParameterSetName='API')]
        [Parameter(ParameterSetName='SSH')]	[String]	$HostName,
        [Parameter(ParameterSetName='SSH')]	[String]	$Domain,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$D,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$Verb,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$CHAP,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$Descriptor,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$Agent,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$Pathsum,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$Persona,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$Listpersona,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$NoName,
		[Parameter(ParameterSetName='SSH')]	[Switch]	$CRCError,
        [Parameter(ParameterSetName='SSH')] [Switch]    $UseSSH 
)
Begin 
{	if ( $PSCmdlet.ParameterSetName -eq 'API' )
        {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                {	$PSetName = 'API'
                }
            else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                        {	$PSetName = 'SSH'
                        }
                }
        }
        elseif ( $PSCmdlet.ParameterSetName -eq 'SSH' )	
        {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                {	$PSetName = 'SSH'
                }
            else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                    return
                }
        }
}
Process 
{	switch( $PSetName )
    {   
        'API'   {
                    $Result = $null
                    $dataPS = $null		
                    if($HostName)
                    {	$uri = '/hosts/'+$HostName
                        $Result = Invoke-A9API -uri $uri -type 'GET' 
                        If($Result.StatusCode -eq 200)			{	$dataPS = $Result.content | ConvertFrom-Json	}	
                    }	
                    else
                        {	$Result = Invoke-A9API -uri '/hosts' -type 'GET'
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
        'SSH'   {   
                    $CurrentId = $CurrentName = $CurrentPersona = $null
                    $ListofvHosts = @()	
                    $GetHostCmd = "showhost "	
                    if ($Domain)		{	$GetHostCmd +=" -domain $Domain"}
                    if ($D)				{	$GetHostCmd +=" -d "			}
                    if ($Verb)			{	$GetHostCmd +=" -verbose "		}
                    if ($CHAP)			{	$GetHostCmd +=" -chap "			}
                    if ($Descriptor)	{	$GetHostCmd +=" -desc "			}
                    if ($Agent)			{	$GetHostCmd +=" -agent "		}
                    if ($Pathsum)		{	$GetHostCmd +=" -pathsum "		}
                    if ($Persona)		{	$GetHostCmd +=" -persona "		}
                    if ($Listpersona)	{	$GetHostCmd +=" -listpersona "	}
                    if ($NoName)		{	$GetHostCmd +=" -noname "		}
                    if ($CRCError)		{	$GetHostCmd +=" -lesb "			}	
                    if($hostName)		{	$objType = "host"
                                            $objMsg  = "hosts"
                                            if ( -not (Test-A9CLIObject -objectType $objType -objectName $hostName -objectMsg $objMsg ))
                                                {	return "FAILURE : No host $hostName found"
                                                }
                                        }
                    $GetHostCmd+=" $hostName"
                    $Result = Invoke-A9CLICommand -cmds  $GetHostCmd	
                    write-verbose "Get list of Hosts" 
                    if ($Result -match "no hosts listed")	{	return "Success : no hosts listed"	}
                    if ($Verb -or $Descriptor)				{	return $Result	}	
                    $tempFile = [IO.Path]::GetTempFileName()
                    $Header = $Result[0].Trim() -replace '-WWN/iSCSI_Name-' , ' Address' 
                    set-content -Path $tempFile -Value $Header
                    $Result_Count = $Result.Count - 3
                    if($Agent)	{	$Result_Count = $Result.Count - 3	}
                    if($Result.Count -gt 3)
                        {	$CurrentId = $null
                            $CurrentName = $null
                            $CurrentPersona = $null		
                            $address = $null
                            $Port = $null
                            $Flg = "false"
                            foreach ($s in $Result[1..$Result_Count])
                                {	if($Pathsum)
                                        {	$s =  [regex]::Replace($s , "," , "|"  )  # Replace ','  with "|"	
                                        }			
                                    if($Flg -eq "true")
                                        {	$temp = $s.Trim()
                                            $temp1 = $temp.Split(',')
                                            if($temp1[0] -match "--")
                                                {	$temp =  [regex]::Replace($temp , "--" , ""  )  # Replace '--'  with ""				
                                                    $s = $temp
                                                }
                                        }
                                    $Flg = "true"	
                                    $match = [regex]::match($s, "^  +")   # Match Line beginning with 1 or more spaces
                                    if (-not ($match.Success))
                                        {	$s= $s.Trim()				
                                            $s= [regex]::Replace($s, " +" , "," )	# Replace spaces with comma (,)
                                            $sTemp = $s.Split(',')
                                            $TempCnt = $sTemp.Count
                                            if($TempCnt -eq 2)
                                                {	$address = $sTemp[0]
                                                    $Port = $sTemp[1] # [regex]::Replace($sTemp[4] , "-+" , ""  )  # Replace '----'  with ""  
                                                }
                                            else{	$CurrentId =  $sTemp[0]
                                                    $CurrentName = $sTemp[1]
                                                    $CurrentPersona = $sTemp[2]			
                                                    $address = $sTemp[3]
                                                    $Port = $sTemp[4] # [regex]::Replace($sTemp[4] , "-+" , ""  )  # Replace '----'  with ""
                                                }
                                        }			
                                    else{	$s = $s.trim()
                                            $s= [regex]::Replace($s, " +" , "," )								
                                            $sTemp = $s.Split(',')
                                            $TempCnt1 = $sTemp.Count
                                            if($TempCnt1 -eq 2)
                                                {	$address = $sTemp[0]
                                                    $Port = $sTemp[1] # [regex]::Replace($sTemp[4] , "-+" , ""  )  # Replace '----'  with ""  
                                                }
                                            else{	$CurrentId =  $sTemp[0]
                                                    $CurrentName = $sTemp[1]
                                                    $CurrentPersona = $sTemp[2]			
                                                    $address = $sTemp[3]
                                                    $Port = $sTemp[4] # [regex]::Replace($sTemp[4] , "-+" , ""  )  # Replace '----'  with ""
                                                }
                                            
                                        }
                                    $vHost= @{	ID 		= $CurrentId
                                                Persona = $currentPersona
                                                Name = $CurrentName
                                                Address = $address
                                                Port= $port
                                            } 
                                    $ListofvHosts += $vHost		
                                }	
                        }	
                    else{	Remove-Item  $tempFile
                            return "Success : No Data Available for Host Name :- $hostName"
                        }
                    Remove-Item  $tempFile
                    return ( $ListofvHosts | convertto-json | convertfrom-json)	
                }
    }
}
}