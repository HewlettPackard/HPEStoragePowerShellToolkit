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
        if($HostSetName)    {	$uri += '/' + $HostSetName    }
        $Result = Invoke-A9API -uri $uri -type 'GET'
        If ($Result.StatusCode -eq 200)
            {	# if the return data is one item, then the sub-object members does not exist
                $dataPSM = ($Result.content | ConvertFrom-Json).members
                $dataPS1 = ($Result.content | ConvertFrom-Json)
                if ($dataPSM) { $dataPS = $dataPSM } else { $dataPS = $dataPS1 }
                if($dataPS.Count -gt 0)
                    {	write-host "Cmdlet executed successfully" -foreground green
                        return $dataPS
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
	Get Single or list of Hotes. the command will attempt to use the API to accomplish the task, 
    if the API is unavalable or other parameters are used, the command will attempt to fail back to a SSH type connection to accomplish the goal. 
.PARAMETER HostName
	Specify name of the Host.
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
.NOTES
    To obtain the supported list of host personas, use Get-A9HostPersona. 
#>
[CmdletBinding()]
Param(	[Parameter()]     [String]	$HostName
    )
Begin 
    {	Test-A9Connection -CLientType 'API'
    }
Process 
    {	if($HostName)
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
}

