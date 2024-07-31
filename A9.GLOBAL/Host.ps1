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
# SIG # Begin signature block
# MIIt2QYJKoZIhvcNAQcCoIItyjCCLcYCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDh4kLYimNI
# 34gY3dKHXTqtj24cxGhYs9SjOvFg4k7Z1lJI7aaJp7F8jvUF5/creTyRmwir3vz4
# sgMvvRgBS6JIoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5YwghuSAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQBCofszsjxZuGZytY7jcXLe+9g35G5qGWN0QKNHk3brRiFHmIJK2gIj/
# Xy0Ky3BrltjOc86sXM4g4gvpkwlw+gowDQYJKoZIhvcNAQEBBQAEggGAOtWC07Qx
# ZyM5x0xzoLBAIdE3jA9D2lV99eirWrU8IBAYNnnq4QkTuYFqhdZbYLcg9a9BBWnU
# LmhD61v9zfy2a0besgHR57Gmx+9uv+cuq6E4TcB5qn5eyIWlJ8tzD5Ti8d9T0ww0
# sKtmlcWFvz5O+KnPn7yo9w65NiEsKC1ViI+EVMdr0cbH4Puj+cXfB00DVGbJ5f08
# de0MardDAvwGZ2R0AeQ0g39tHPQFSRvjXX+44VT5b3660cE+/0s/1xjsoPTItaRr
# jBxDf7yNA1VqZLoGtHz/WEt+vSPDHPacYnx/3pARUqxa3rFsPCbPkogyYDkINjT+
# EYvqoftPTBKmaaX2n6z9qzF1dr6FOsHPW+wzjp7n9BMwo6mgTg6lPNw9vufPvF4H
# wmN1r7fJNSnElBsWRX5L5Z6JGTzOAiq+EDWGBdRGZ0SlLeyWMr1wcCfOltuNAXr8
# 349E2bPazRpEjsCKkkakI+JCGgTz2vYjnRNus7nm9PeqiGZeTlmdPaMJoYIY3zCC
# GNsGCisGAQQBgjcDAwExghjLMIIYxwYJKoZIhvcNAQcCoIIYuDCCGLQCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQQGCyqGSIb3DQEJEAEEoIH0BIHxMIHuAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMCKQ3frlifzcZMqTcgC9VXD2HJVdLBHq
# LGItoICH9eYWVLZVDHVIyeg3jgbQG+S8lwIVAIoFXsJAWH4hz8skcowuFDRdzfM5
# GA8yMDI0MDczMTIwMTAyOFqgcqRwMG4xCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpN
# YW5jaGVzdGVyMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMTJ1Nl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNaCCEv8wggZdMIIE
# xaADAgECAhA6UmoshM5V5h1l/MwS2OmJMA0GCSqGSIb3DQEBDAUAMFUxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgQ0EgUjM2MB4XDTI0MDExNTAwMDAwMFoX
# DTM1MDQxNDIzNTk1OVowbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1hbmNoZXN0
# ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2VjdGlnbyBQ
# dWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1MIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAjdFn9MFIm739OEk6TWGBm8PY3EWlYQQ2jQae45iWgPXU
# GVuYoIa1xjTGIyuw3suUSBzKiyG0/c/Yn++d5mG6IyayljuGT9DeXQU9k8GWWj2/
# BPoamg2fFctnPsdTYhMGxM06z1+Ft0Bav8ybww21ii/faiy+NhiUM195+cFqOtCp
# JXxZ/lm9tpjmVmEqpAlRpfGmLhNdkqiEuDFTuD1GsV3jvuPuPGKUJTam3P53U4LM
# 0UCxeDI8Qz40Qw9TPar6S02XExlc8X1YsiE6ETcTz+g1ImQ1OqFwEaxsMj/WoJT1
# 8GG5KiNnS7n/X4iMwboAg3IjpcvEzw4AZCZowHyCzYhnFRM4PuNMVHYcTXGgvuq9
# I7j4ke281x4e7/90Z5Wbk92RrLcS35hO30TABcGx3Q8+YLRy6o0k1w4jRefCMT7b
# 5mTxtq5XPmKvtgfPuaWPkGZ/tbxInyNDA7YgOgccULjp4+D56g2iuzRCsLQ9ac6A
# N4yRbqCYsG2rcIQ5INTyI2JzA2w1vsAHPRbUTeqVLDuNOY2gYIoKBWQsPYVoyzao
# BVU6O5TG+a1YyfWkgVVS9nXKs8hVti3VpOV3aeuaHnjgC6He2CCDL9aW6gteUe0A
# mC8XCtWwpePx6QW3ROZo8vSUe9AR7mMdu5+FzTmW8K13Bt8GX/YBFJO7LWzwKAUC
# AwEAAaOCAY4wggGKMB8GA1UdIwQYMBaAFF9Y7UwxeqJhQo1SgLqzYZcZojKbMB0G
# A1UdDgQWBBRo76QySWm2Ujgd6kM5LPQUap4MhTAOBgNVHQ8BAf8EBAMCBsAwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBKBgNVHSAEQzBBMDUG
# DCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29t
# L0NQUzAIBgZngQwBBAIwSgYDVR0fBEMwQTA/oD2gO4Y5aHR0cDovL2NybC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3JsMHoGCCsG
# AQUFBwEBBG4wbDBFBggrBgEFBQcwAoY5aHR0cDovL2NydC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3J0MCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAYEAsNwuyfpP
# NkyKL/bJT9XvGE8fnw7Gv/4SetmOkjK9hPPa7/Nsv5/MHuVus+aXwRFqM5Vu51qf
# rHTwnVExcP2EHKr7IR+m/Ub7PamaeWfle5x8D0x/MsysICs00xtSNVxFywCvXx55
# l6Wg3lXiPCui8N4s51mXS0Ht85fkXo3auZdo1O4lHzJLYX4RZovlVWD5EfwV6Ve1
# G9UMslnm6pI0hyR0Zr95QWG0MpNPP0u05SHjq/YkPlDee3yYOECNMqnZ+j8onoUt
# Z0oC8CkbOOk/AOoV4kp/6Ql2gEp3bNC7DOTlaCmH24DjpVgryn8FMklqEoK4Z3Io
# UgV8R9qQLg1dr6/BjghGnj2XNA8ujta2JyoxpqpvyETZCYIUjIs69YiDjzftt37r
# QVwIZsfCYv+DU5sh/StFL1x4rgNj2t8GccUfa/V3iFFW9lfIJWWsvtlC5XOOOQsw
# r1UmVdNWQem4LwrlLgcdO/YAnHqY52QwnBLiAuUnuBeshWmfEb5oieIYMIIGFDCC
# A/ygAwIBAgIQeiOu2lNplg+RyD5c9MfjPzANBgkqhkiG9w0BAQwFADBXMQswCQYD
# VQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0
# aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAw
# MFoXDTM2MDMyMTIzNTk1OVowVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3Rp
# Z28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGlu
# ZyBDQSBSMzYwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQDNmNhDQatu
# givs9jN+JjTkiYzT7yISgFQ+7yavjA6Bg+OiIjPm/N/t3nC7wYUrUlY3mFyI32t2
# o6Ft3EtxJXCc5MmZQZ8AxCbh5c6WzeJDB9qkQVa46xiYEpc81KnBkAWgsaXnLURo
# YZzksHIzzCNxtIXnb9njZholGw9djnjkTdAA83abEOHQ4ujOGIaBhPXG2NdV8TNg
# FWZ9BojlAvflxNMCOwkCnzlH4oCw5+4v1nssWeN1y4+RlaOywwRMUi54fr2vFsU5
# QPrgb6tSjvEUh1EC4M29YGy/SIYM8ZpHadmVjbi3Pl8hJiTWw9jiCKv31pcAaeij
# S9fc6R7DgyyLIGflmdQMwrNRxCulVq8ZpysiSYNi79tw5RHWZUEhnRfs/hsp/fwk
# Xsynu1jcsUX+HuG8FLa2BNheUPtOcgw+vHJcJ8HnJCrcUWhdFczf8O+pDiyGhVYX
# +bDDP3GhGS7TmKmGnbZ9N+MpEhWmbiAVPbgkqykSkzyYVr15OApZYK8CAwEAAaOC
# AVwwggFYMB8GA1UdIwQYMBaAFPZ3at0//QET/xahbIICL9AKPRQlMB0GA1UdDgQW
# BBRfWO1MMXqiYUKNUoC6s2GXGaIymzAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/
# BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAECjAIMAYGBFUd
# IAAwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0
# aWdvUHVibGljVGltZVN0YW1waW5nUm9vdFI0Ni5jcmwwfAYIKwYBBQUHAQEEcDBu
# MEcGCCsGAQUFBzAChjtodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJs
# aWNUaW1lU3RhbXBpbmdSb290UjQ2LnA3YzAjBggrBgEFBQcwAYYXaHR0cDovL29j
# c3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBABLXeyCtDjVYDJ6BHSVY
# /UwtZ3Svx2ImIfZVVGnGoUaGdltoX4hDskBMZx5NY5L6SCcwDMZhHOmbyMhyOVJD
# wm1yrKYqGDHWzpwVkFJ+996jKKAXyIIaUf5JVKjccev3w16mNIUlNTkpJEor7edV
# JZiRJVCAmWAaHcw9zP0hY3gj+fWp8MbOocI9Zn78xvm9XKGBp6rEs9sEiq/pwzvg
# 2/KjXE2yWUQIkms6+yslCRqNXPjEnBnxuUB1fm6bPAV+Tsr/Qrd+mOCJemo06ldo
# n4pJFbQd0TQVIMLv5koklInHvyaf6vATJP4DfPtKzSBPkKlOtyaFTAjD2Nu+di5h
# ErEVVaMqSVbfPzd6kNXOhYm23EWm6N2s2ZHCHVhlUgHaC4ACMRCgXjYfQEDtYEK5
# 4dUwPJXV7icz0rgCzs9VI29DwsjVZFpO4ZIVR33LwXyPDbYFkLqYmgHjR3tKVkhh
# 9qKV2WCmBuC27pIOx6TYvyqiYbntinmpOqh/QPAnhDgexKG9GX/n1PggkGi9HCap
# Zp8fRwg8RftwS21Ln61euBG0yONM6noD2XQPrFwpm3GcuqJMf0o8LLrFkSLRQNwx
# PDDkWXhW+gZswbaiie5fd/W2ygcto78XCSPfFWveUOSZ5SqK95tBO8aTHmEa4lpJ
# VD7HrTEn9jb1EGvxOb1cnn0CMIIGgjCCBGqgAwIBAgIQNsKwvXwbOuejs902y8l1
# aDANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBK
# ZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRS
# VVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlv
# biBBdXRob3JpdHkwHhcNMjEwMzIyMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjBXMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAiJ3YuUVnnR3d6LkmgZpUVMB8SQWbzFoVD9mU
# EES0QUCBdxSZqdTkdizICFNeINCSJS+lV1ipnW5ihkQyC0cRLWXUJzodqpnMRs46
# npiJPHrfLBOifjfhpdXJ2aHHsPHggGsCi7uE0awqKggE/LkYw3sqaBia67h/3awo
# qNvGqiFRJ+OTWYmUCO2GAXsePHi+/JUNAax3kpqstbl3vcTdOGhtKShvZIvjwulR
# H87rbukNyHGWX5tNK/WABKf+Gnoi4cmisS7oSimgHUI0Wn/4elNd40BFdSZ1Ewpu
# ddZ+Wr7+Dfo0lcHflm/FDDrOJ3rWqauUP8hsokDoI7D/yUVI9DAE/WK3Jl3C4LKw
# Ipn1mNzMyptRwsXKrop06m7NUNHdlTDEMovXAIDGAvYynPt5lutv8lZeI5w3MOlC
# ybAZDpK3Dy1MKo+6aEtE9vtiTMzz/o2dYfdP0KWZwZIXbYsTIlg1YIetCpi5s14q
# iXOpRsKqFKqav9R1R5vj3NgevsAsvxsAnI8Oa5s2oy25qhsoBIGo/zi6GpxFj+mO
# dh35Xn91y72J4RGOJEoqzEIbW3q0b2iPuWLA911cRxgY5SJYubvjay3nSMbBPPFs
# yl6mY4/WYucmyS9lo3l7jk27MAe145GWxK4O3m3gEFEIkv7kRmefDR7Oe2T1HxAn
# ICQvr9sCAwEAAaOCARYwggESMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKy
# A2bLMB0GA1UdDgQWBBT2d2rdP/0BE/8WoWyCAi/QCj0UJTAOBgNVHQ8BAf8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAE
# CjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1
# c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMDUG
# CCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEADr5lQe1oRLjlocXUEYfktzsljOt+2sgX
# ke3Y8UPEooU5y39rAARaAdAxUeiX1ktLJ3+lgxtoLQhn5cFb3GF2SSZRX8ptQ6Iv
# uD3wz/LNHKpQ5nX8hjsDLRhsyeIiJsms9yAWnvdYOdEMq1W61KE9JlBkB20XBee6
# JaXx4UBErc+YuoSb1SxVf7nkNtUjPfcxuFtrQdRMRi/fInV/AobE8Gw/8yBMQKKa
# Ht5eia8ybT8Y/Ffa6HAJyz9gvEOcF1VWXG8OMeM7Vy7Bs6mSIkYeYtddU1ux1dQL
# bEGur18ut97wgGwDiGinCwKPyFO7ApcmVJOtlw9FVJxw/mL1TbyBns4zOgkaXFnn
# fzg4qbSvnrwyj1NiurMp4pmAWjR+Pb/SIduPnmFzbSN/G8reZCL4fvGlvPFk4Uab
# /JVCSmj59+/mB2Gn6G/UYOy8k60mKcmaAZsEVkhOFuoj4we8CYyaR9vd9PGZKSin
# aZIkvVjbH/3nlLb0a7SBIkiRzfPfS9T+JesylbHa1LtRV9U/7m0q7Ma2CQ/t392i
# oOssXW7oKLdOmMBl14suVFBmbzrt5V5cQPnwtd3UOTpS9oCG+ZZheiIvPgkDmA8F
# zPsnfXW5qHELB43ET7HHFHeRPRYrMBKjkb8/IN7Po0d0hQoF4TeMM+zYAJzoKQnV
# KOLg8pZVPT8xggSRMIIEjQIBATBpMFUxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9T
# ZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3RpZ28gUHVibGljIFRpbWUgU3Rh
# bXBpbmcgQ0EgUjM2AhA6UmoshM5V5h1l/MwS2OmJMA0GCWCGSAFlAwQCAgUAoIIB
# +TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0
# MDczMTIwMTAyOFowPwYJKoZIhvcNAQkEMTIEMB/DSh/bFgGwpjgYa/TbXWMcbL3i
# GNJdhn5rBFRc1lMmVbNGafID4Mnz0ZQboscItTCCAXoGCyqGSIb3DQEJEAIMMYIB
# aTCCAWUwggFhMBYEFPhgmBmm+4gs9+hSl/KhGVIaFndfMIGHBBTGrlTkeIbxfD1V
# EkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KCYXzQkDXEkd6S
# wULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJz
# ZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNU
# IE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEBBQAEggIARTmO
# 5UmtCyTmJqFcLs3VTU48t1l+lsBUmYwog9uBDjZd3VNQM3HwOAy2/DaDG7BNGUCY
# 00Sn2bUPOXNtfl87yuPnXjn8FGRHRspLRfr6Y+zFA0E7PZj1zihgta4y8DT10hQG
# fbLxAe/GJWFOkP9J86y+S07vlv3H0wsQIzjBbvSUI1qTQ+DUE4BOCq9L4GX7xYp1
# 6CvKwD4p5xCTLq/qJkh/yhNRKEVeRH1m8mhkq0PbHeyptgF/AfKOXeokZp2CXRms
# ALzSJwMAXCigR70jIEA08A4CHLEiNnre/+JeuzG7FzbTD7sUTb692O0d3I3LUJR/
# MaIZtThbnXI56DIqVijLbaslOHYuaT4IDwWTfVFTtZLcv7Ep3efEZRdWZXRhN/fU
# 9/VY/thOdAugPWrYsaIGQXgtSrCN9PewKnVpjEUCrsQM9UG3T+OsF/IwXA2jiQCo
# or9DtCU51lai1y7xX6pLzObroxdY4nSkyGQWmekr6ygU+kz0p4fJdqh9055MFrd4
# Pt69OkMFL4pgbY4kxCDrFrffOAFXQn3Pud41UzC74ZH7BWrQrbOvEKMdIDRiouRZ
# NsxgL8AyPbOiNoh5lmrkAHsjqvEC2tuP0+korxWM8s2+uaQzKErvcIHKc4cEDfUG
# 2hUqH2g88McCoeQ5A8UlbcKp4828V/0rBHJOSQ8=
# SIG # End signature block
