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
        'API'   {   if($HostName)
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

# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEClagt6oidi
# CIxZwsocAAn9r4egI8IxfVeSFydSi4hBKRC99BM7XwYBJaFhe+plf5LFd79Pub5n
# hAepJ0n3FHIzoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG58wghubAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQLSsyiwdF7wmO/7b7sy/SAkOa6StSB0HSwZ/3FwJyb0ks2ZnlQbeVjJU
# 39fi4ijCrGU0ULmITRI3y2Sz1feJWfgwDQYJKoZIhvcNAQEBBQAEggGAEBhhdUxC
# Eljz+PguD/7uIR3ER81cZVKA3w0fdrkJRviz/WL/Ox+YPiF1Vy0K5X852ryjCKf5
# Mz7Ys37rv1ju7H+gAVP+QNyozXkg/S7D+8HWOT3Cjw5fuA2u7K8tPuqVwa+INoiv
# 4JcVtMFHNpL0q/Kjjg1bX032bGqKbworFpmMnuIxvUPxH8TGRyQ/RNeNMX1+HJy0
# z9Ob51iFkG4Gl9+lZHQ0zsNz/MWerhTFcnm+BxdYN0zkBC7zvUohX85fWH19qNIt
# icpZB20kKq6kLjPxVkZKR4SDH824Q0+AlYA26gRzhTSREtmrpz59UZDA9J9mlVGo
# gClav4f/jObBd6OXpLAhtmhRKQvp84Pe4zH//+kDxK4mpJX4HkhsNSGxI+dpfHo3
# n0Ikg2tmwh0yfZ8TtGEEOERIAp7C84kuxZGoZeqlPGEHSb+dphan5Wpx0LVkUHXj
# 1aevF0OCKQKtiXcR8fTPNoHx7blG8jOGkvjh65j2S3PxtWh9deUZMJ0toYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMEJSNEbm1MfLBh8ZPxkaYZLWphcBj8EJ
# pMAZWW473ZjN5yZce0RTRaD7UtQqU3syOQIUaMIUl2pAsLKy6meVsUsJn8MNHtoY
# DzIwMjUwNTE1MDI0MDM2WqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
# c3QgWW9ya3NoaXJlMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMT
# J1NlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNqCCEwQwggZi
# MIIEyqADAgECAhEApCk7bh7d16c0CIetek63JDANBgkqhkiG9w0BAQwFADBVMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNTAzMjcwMDAw
# MDBaFw0zNjAzMjEyMzU5NTlaMHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5XZXN0
# IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQDEydT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzYwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDThJX0bqRTePI9EEt4Egc83JSBU2dhrJ+w
# Y7JgReuff5KQNhMuzVytzD+iXazATVPMHZpH/kkiMo1/vlAGFrYN2P7g0Q8oPEcR
# 3h0SftFNYxxMh+bj3ZNbbYjwt8f4DsSHPT+xp9zoFuw0HOMdO3sWeA1+F8mhg6uS
# 6BJpPwXQjNSHpVTCgd1gOmKWf12HSfSbnjl3kDm0kP3aIUAhsodBYZsJA1imWqkA
# VqwcGfvs6pbfs/0GE4BJ2aOnciKNiIV1wDRZAh7rS/O+uTQcb6JVzBVmPP63k5xc
# ZNzGo4DOTV+sM1nVrDycWEYS8bSS0lCSeclkTcPjQah9Xs7xbOBoCdmahSfg8Km8
# ffq8PhdoAXYKOI+wlaJj+PbEuwm6rHcm24jhqQfQyYbOUFTKWFe901VdyMC4gRwR
# Aq04FH2VTjBdCkhKts5Py7H73obMGrxN1uGgVyZho4FkqXA8/uk6nkzPH9QyHIED
# 3c9CGIJ098hU4Ig2xRjhTbengoncXUeo/cfpKXDeUcAKcuKUYRNdGDlf8WnwbyqU
# blj4zj1kQZSnZud5EtmjIdPLKce8UhKl5+EEJXQp1Fkc9y5Ivk4AZacGMCVG0e+w
# wGsjcAADRO7Wga89r/jJ56IDK773LdIsL3yANVvJKdeeS6OOEiH6hpq2yT+jJ/lH
# a9zEdqFqMwIDAQABo4IBjjCCAYowHwYDVR0jBBgwFoAUX1jtTDF6omFCjVKAurNh
# lxmiMpswHQYDVR0OBBYEFIhhjKEqN2SBKGChmzHQjP0sAs5PMA4GA1UdDwEB/wQE
# AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1Ud
# IARDMEEwNQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAgGBmeBDAEEAjBKBgNVHR8EQzBBMD+gPaA7hjlodHRwOi8v
# Y3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5j
# cmwwegYIKwYBBQUHAQEEbjBsMEUGCCsGAQUFBzAChjlodHRwOi8vY3J0LnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdDQVIzNi5jcnQwIwYIKwYB
# BQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4IB
# gQACgT6khnJRIfllqS49Uorh5ZvMSxNEk4SNsi7qvu+bNdcuknHgXIaZyqcVmhrV
# 3PHcmtQKt0blv/8t8DE4bL0+H0m2tgKElpUeu6wOH02BjCIYM6HLInbNHLf6R2qH
# C1SUsJ02MWNqRNIT6GQL0Xm3LW7E6hDZmR8jlYzhZcDdkdw0cHhXjbOLsmTeS0Se
# RJ1WJXEzqt25dbSOaaK7vVmkEVkOHsp16ez49Bc+Ayq/Oh2BAkSTFog43ldEKgHE
# DBbCIyba2E8O5lPNan+BQXOLuLMKYS3ikTcp/Qw63dxyDCfgqXYUhxBpXnmeSO/W
# A4NwdwP35lWNhmjIpNVZvhWoxDL+PxDdpph3+M5DroWGTc1ZuDa1iXmOFAK4iwTn
# lWDg3QNRsRa9cnG3FBBpVHnHOEQj4GMkrOHdNDTbonEeGvZ+4nSZXrwCW4Wv2qyG
# DBLlKk3kUW1pIScDCpm/chL6aUbnSsrtbepdtbCLiGanKVR/KC1gsR0tC6Q0RfWO
# I4owggYUMIID/KADAgECAhB6I67aU2mWD5HIPlz0x+M/MA0GCSqGSIb3DQEBDAUA
# MFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNV
# BAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwHhcNMjEw
# MzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBVMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIENBIFIzNjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AM2Y2ENBq26CK+z2M34mNOSJjNPvIhKAVD7vJq+MDoGD46IiM+b83+3ecLvBhStS
# VjeYXIjfa3ajoW3cS3ElcJzkyZlBnwDEJuHlzpbN4kMH2qRBVrjrGJgSlzzUqcGQ
# BaCxpectRGhhnOSwcjPMI3G0hedv2eNmGiUbD12OeORN0ADzdpsQ4dDi6M4YhoGE
# 9cbY11XxM2AVZn0GiOUC9+XE0wI7CQKfOUfigLDn7i/WeyxZ43XLj5GVo7LDBExS
# Lnh+va8WxTlA+uBvq1KO8RSHUQLgzb1gbL9Ihgzxmkdp2ZWNuLc+XyEmJNbD2OII
# q/fWlwBp6KNL19zpHsODLIsgZ+WZ1AzCs1HEK6VWrxmnKyJJg2Lv23DlEdZlQSGd
# F+z+Gyn9/CRezKe7WNyxRf4e4bwUtrYE2F5Q+05yDD68clwnweckKtxRaF0VzN/w
# 76kOLIaFVhf5sMM/caEZLtOYqYadtn034ykSFaZuIBU9uCSrKRKTPJhWvXk4Cllg
# rwIDAQABo4IBXDCCAVgwHwYDVR0jBBgwFoAU9ndq3T/9ARP/FqFsggIv0Ao9FCUw
# HQYDVR0OBBYEFF9Y7UwxeqJhQo1SgLqzYZcZojKbMA4GA1UdDwEB/wQEAwIBhjAS
# BgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQK
# MAgwBgYEVR0gADBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLnNlY3RpZ28u
# Y29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LmNybDB8BggrBgEF
# BQcBAQRwMG4wRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY1RpbWVTdGFtcGluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAEtd7IK0O
# NVgMnoEdJVj9TC1ndK/HYiYh9lVUacahRoZ2W2hfiEOyQExnHk1jkvpIJzAMxmEc
# 6ZvIyHI5UkPCbXKspioYMdbOnBWQUn733qMooBfIghpR/klUqNxx6/fDXqY0hSU1
# OSkkSivt51UlmJElUICZYBodzD3M/SFjeCP59anwxs6hwj1mfvzG+b1coYGnqsSz
# 2wSKr+nDO+Db8qNcTbJZRAiSazr7KyUJGo1c+MScGfG5QHV+bps8BX5Oyv9Ct36Y
# 4Il6ajTqV2ifikkVtB3RNBUgwu/mSiSUice/Jp/q8BMk/gN8+0rNIE+QqU63JoVM
# CMPY2752LmESsRVVoypJVt8/N3qQ1c6FibbcRabo3azZkcIdWGVSAdoLgAIxEKBe
# Nh9AQO1gQrnh1TA8ldXuJzPSuALOz1Ujb0PCyNVkWk7hkhVHfcvBfI8NtgWQupia
# AeNHe0pWSGH2opXZYKYG4Lbukg7HpNi/KqJhue2Keak6qH9A8CeEOB7Eob0Zf+fU
# +CCQaL0cJqlmnx9HCDxF+3BLbUufrV64EbTI40zqegPZdA+sXCmbcZy6okx/Sjws
# usWRItFA3DE8MORZeFb6BmzBtqKJ7l939bbKBy2jvxcJI98Va95Q5JnlKor3m0E7
# xpMeYRriWklUPsetMSf2NvUQa/E5vVyefQIwggaCMIIEaqADAgECAhA2wrC9fBs6
# 56Oz3TbLyXVoMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0yMTAzMjIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMFcxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAs
# BgNVBAMTJVNlY3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgUm9vdCBSNDYwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCIndi5RWedHd3ouSaBmlRUwHxJ
# BZvMWhUP2ZQQRLRBQIF3FJmp1OR2LMgIU14g0JIlL6VXWKmdbmKGRDILRxEtZdQn
# Oh2qmcxGzjqemIk8et8sE6J+N+Gl1cnZocew8eCAawKLu4TRrCoqCAT8uRjDeypo
# GJrruH/drCio28aqIVEn45NZiZQI7YYBex48eL78lQ0BrHeSmqy1uXe9xN04aG0p
# KG9ki+PC6VEfzutu6Q3IcZZfm00r9YAEp/4aeiLhyaKxLuhKKaAdQjRaf/h6U13j
# QEV1JnUTCm511n5avv4N+jSVwd+Wb8UMOs4netapq5Q/yGyiQOgjsP/JRUj0MAT9
# YrcmXcLgsrAimfWY3MzKm1HCxcquinTqbs1Q0d2VMMQyi9cAgMYC9jKc+3mW62/y
# Vl4jnDcw6ULJsBkOkrcPLUwqj7poS0T2+2JMzPP+jZ1h90/QpZnBkhdtixMiWDVg
# h60KmLmzXiqJc6lGwqoUqpq/1HVHm+Pc2B6+wCy/GwCcjw5rmzajLbmqGygEgaj/
# OLoanEWP6Y52Hflef3XLvYnhEY4kSirMQhtberRvaI+5YsD3XVxHGBjlIli5u+Nr
# LedIxsE88WzKXqZjj9Zi5ybJL2WjeXuOTbswB7XjkZbErg7ebeAQUQiS/uRGZ58N
# Hs57ZPUfECcgJC+v2wIDAQABo4IBFjCCARIwHwYDVR0jBBgwFoAUU3m/WqorSs9U
# gOHYm8Cd8rIDZsswHQYDVR0OBBYEFPZ3at0//QET/xahbIICL9AKPRQlMA4GA1Ud
# DwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0
# eS5jcmwwNQYIKwYBBQUHAQEEKTAnMCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAOvmVB7WhEuOWhxdQRh+S3
# OyWM637ayBeR7djxQ8SihTnLf2sABFoB0DFR6JfWS0snf6WDG2gtCGflwVvcYXZJ
# JlFfym1Doi+4PfDP8s0cqlDmdfyGOwMtGGzJ4iImyaz3IBae91g50QyrVbrUoT0m
# UGQHbRcF57olpfHhQEStz5i6hJvVLFV/ueQ21SM99zG4W2tB1ExGL98idX8ChsTw
# bD/zIExAopoe3l6JrzJtPxj8V9rocAnLP2C8Q5wXVVZcbw4x4ztXLsGzqZIiRh5i
# 111TW7HV1AtsQa6vXy633vCAbAOIaKcLAo/IU7sClyZUk62XD0VUnHD+YvVNvIGe
# zjM6CRpcWed/ODiptK+evDKPU2K6synimYBaNH49v9Ih24+eYXNtI38byt5kIvh+
# 8aW88WThRpv8lUJKaPn37+YHYafob9Rg7LyTrSYpyZoBmwRWSE4W6iPjB7wJjJpH
# 29308ZkpKKdpkiS9WNsf/eeUtvRrtIEiSJHN899L1P4l6zKVsdrUu1FX1T/ubSrs
# xrYJD+3f3aKg6yxdbugot06YwGXXiy5UUGZvOu3lXlxA+fC13dQ5OlL2gIb5lmF6
# Ii8+CQOYDwXM+yd9dbmocQsHjcRPsccUd5E9FiswEqORvz8g3s+jR3SFCgXhN4wz
# 7NgAnOgpCdUo4uDyllU9PzGCBJIwggSOAgEBMGowVTELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMg
# VGltZSBTdGFtcGluZyBDQSBSMzYCEQCkKTtuHt3XpzQIh616TrckMA0GCWCGSAFl
# AwQCAgUAoIIB+TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTI1MDUxNTAyNDAzNlowPwYJKoZIhvcNAQkEMTIEMNLMSI3HkuqQSnaG
# Q2HWgVVnbtCnPu1rak2BPvMMhKdkTwEOYzwUdnaTMcu1XTfnRTCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAXi03C4YlR458GYo1ne6u1cckj6YKtrQfH4rEBVSvWlHTJy3fYGFoT+xp
# nCIpORneGdgV7MTKR3yk5+4zx9fg9rvPxgApEDGS6wYLSSXihpA+1e2bdnCu7Sjt
# 5822Zi9e1ksJm8X4f4l3dp58N5dhE1fK3slf+v3BWQ61a2R6J88gu8KjbZMCLIR0
# 6nK8MURRRoFYsHtOchpn/6+aillBFDt3TGoCHPK+eWa7pBPoIWYI0MjTpfzPFQlq
# 6icHJ0K2BFtU/uV2rDFoxAHLrSjAwiPtjLdoaGZyA/zistp7z7/+pkFnR+M9nXit
# dNAmqjmya9qiiJy65rFFvKPw+WqeMhWZerL2mgc/2snwzpXnjU5C8pC9dQfmdwMp
# Pkn/1hs4Le2+6xJLtigL8Y77Mcps7p2FRCua5SIwyogcEpBvBQs6kDMct9cdqc3L
# VLA7mO1q9aIP54LuMmQWOlXYPWM/gHXRejsqEv057NtJKp9qTa22bdqElVZe62DT
# pn2Zf4tmImbrV7723VBZVOJ36qhJzh3+vWmhQHxst4Vyq3NmuY4uDEm9luZaBvfe
# PBnc2JSfGhPx5zE3HZ2Gdmo9vmW+76ErnbMDcqDQGXZASf/JOonOCCnNMvINozt8
# ljMn1I1S2kThdeYqpD7AhamI7s4zzxGJ65o5h5ZWd2vPpTSbRck=
# SIG # End signature block
