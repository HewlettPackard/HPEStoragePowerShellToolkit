####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
##	File Name:		CimManagement.psm1
##	Description: 	CIM Management cmdlets 
##		
##	Created:		May 2021
##	Last Modified:	May 2021
##	History:		v3.1 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## FUNCTION Test-CLIObject
############################################################################################################################################
Function Test-CLIObject 
{
Param( 	
    [string]$ObjectType, 
	[string]$ObjectName ,
	[string]$ObjectMsg = $ObjectType, 
	$SANConnection = $global:SANConnection
	)

	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")
	{
		$IsObjectExisted = $false
	}
	return $IsObjectExisted
	
} # End FUNCTION Test-CLIObject

####################################################################################################################
## FUNCTION Show-CIM
####################################################################################################################
Function Show-CIM {
    <#
  .SYNOPSIS
    Show the CIM server information
                                                                                                           .
  .DESCRIPTION
    The Show-CIM cmdlet displays the CIM server service state being configured,
    either enabled or disabled. It also displays the server current running
    status, either active or inactive. It displays the current status of the
    HTTP and HTTPS ports and their port numbers. In addition, it shows the
    current status of the SLP port, that is either enabled or disabled.

  .PARAMETER Pol
      Show CIM server policy information

  .EXAMPLES
    The following example shows the current CIM status:

        Show-CIM

        -Service- -State-- --SLP-- SLPPort -HTTP-- HTTPPort -HTTPS- HTTPSPort PGVer  CIMVer
        Enabled   Active   Enabled     427 Enabled     5988 Enabled      5989 2.14.1 3.3.1

    The following example shows the current CIM policy:

        Show-CIM -Pol

        --------------Policy---------------
        replica_entity,one_hwid_per_view,use_pegasus_interop_namespace,no_tls_strict
  
  .NOTES    

    NAME:  Show-CIM
    LASTEDIT: 25/04/2021
    KEYWORDS: Show-CIM
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [Switch]
        $Pol, 

        [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true)]
        $SANConnection = $global:SANConnection        
    )	
	
    Write-DebugLog "Start: In Show-CIM   - validating input values" $Debug 
    #check if connection object contents are null/empty
    if (!$SANConnection) {
        #check if connection object contents are null/empty
        $Validate1 = Test-CLIConnection $SANConnection
        if ($Validate1 -eq "Failed") {
            #check if global connection object contents are null/empty
            $Validate2 = Test-CLIConnection $global:SANConnection
            if ($Validate2 -eq "Failed") {
                Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
                Write-DebugLog "Stop: Exiting Show-CIM since SAN connection object values are null/empty" $Debug
                return "Unable to execute the cmdlet Show-CIM since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."               
            }
        }
    }
    $plinkresult = Test-PARCli
    if ($plinkresult -match "FAILURE :") {
        write-debuglog "$plinkresult" "ERR:" 
        return $plinkresult
    }

    $cmd = "showcim "

    if ($Pol) {
        $cmd += " -pol "
    }
	
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds $cmd

    write-debuglog " Executed the Show-CIM cmdlet" "INFO:" 

    return 	$Result	

} # End Show-CIM

####################################################################################################################
## FUNCTION Start-CIM
####################################################################################################################
Function Start-CIM {
    <#
  .SYNOPSIS
    Start the CIM server to service CIM requests
                                                                                                           .
  .DESCRIPTION
    The Start-CIM cmdlet starts the CIM server to service CIM requests. By
    default, the CIM server is not started until this command is issued.

  .EXAMPLES
    The following example starts the CIM server:

    Start-CIM
    CIM server will start shortly.
  
  .NOTES
    Access to all domains is required to run this command.

    By default, the CIM server is not started until this command is issued.

    Use Stop-CIM to stop the CIM server.

    NAME:  Start-CIM
    LASTEDIT: 25/04/2021
    KEYWORDS: Start-CIM
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
        $SANConnection = $global:SANConnection        
    )	
	
    Write-DebugLog "Start: In Start-CIM   - validating input values" $Debug 
    #check if connection object contents are null/empty
    if (!$SANConnection) {
        #check if connection object contents are null/empty
        $Validate1 = Test-CLIConnection $SANConnection
        if ($Validate1 -eq "Failed") {
            #check if global connection object contents are null/empty
            $Validate2 = Test-CLIConnection $global:SANConnection
            if ($Validate2 -eq "Failed") {
                Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
                Write-DebugLog "Stop: Exiting Start-CIM since SAN connection object values are null/empty" $Debug
                return "Unable to execute the cmdlet Start-CIM since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."               
            }
        }
    }
    $plinkresult = Test-PARCli
    if ($plinkresult -match "FAILURE :") {
        write-debuglog "$plinkresult" "ERR:" 
        return $plinkresult
    }		
    $cmd = "startcim "
	
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd

    write-debuglog " Executed the Start-CIM cmdlet" "INFO:" 

    return 	$Result	

} # End Start-CIM

####################################################################################################################
## FUNCTION Set-CIM
####################################################################################################################
Function Set-CIM {
    <#
  .SYNOPSIS
    Set the CIM server properties
                                                                                                           .
  .DESCRIPTION
    The Set-CIM cmdlet sets properties of the CIM server, including options to
    enable/disable the HTTP and HTTPS ports for the CIM server. setcim allows
    a user to enable/disable the SLP port. The command also sets the CIM server
    policy.

  .PARAMETER F
    Forces the operation of the setcim command, bypassing the typical
    confirmation message.
   
  .PARAMETER Slp
      Enables or disables the SLP port 427.

  .PARAMETER Http
      Enables or disables the HTTP port 5988

  .PARAMETER Https
      Enables or disables the HTTPS port 5989

  .PARAMETER Pol
      Sets the cim server policy:

            replica_entity   - complies with SMI-S standard for usage of
                               Replication Entity objects in associations.
                               This is the default policy setting.
            no_replica_entity- does not comply with SMI-S standard for
                               Replication Entity usage. Use only as directed
                               by HPE support personnel or Release Notes.
            one_hwid_per_view - calling exposePaths with multiple
                               initiatorPortIDs to create new view will result
                               in the creation of multiple
                               SCSCIProtocolControllers (SPC), one
                               StorageHardwareID per SPC. Multiple hosts will
                               be created each containing one FC WWN or
                               iscsiname. This is the default policy setting.
                               This is the default policy setting.
            no_one_hwid_per_view - calling exposePaths with multiple
                               initiatorPortIDs to create new view will result
                               in the creation of only one
                               SCSCIProtocolController (SPC) that contains all
                               the StorageHardwareIDs. One host will be created
                               that contains all the FC WWNs or iscsinames.
            use_pegasus_interop_namespace - use the pegasus defined interop
                               namespace root/PG_interop.  This is the default
                               policy setting.
            no_use_pegasus_interop_namespace - use the SMI-S conformant
                               interop namespace root/interop.
            tls_strict       - Only TLS connections using TLS 1.2 with
                               secure ciphers will be accepted if HTTPS is
                               enabled.
            no_tls_strict    - TLS connections using TLS 1.0 - 1.2 will be
                               accepted if HTTPS is enabled. This is the
                               default policy setting.

  .EXAMPLES
    To disable the HTTPS ports:

        Set-CIM -F -Https Disable

    To enable the HTTPS port:

        Set-CIM -F -Https Enable

    To disable the HTTP port and enable the HTTPS port:

        Set-CIM -F -Http Disable -Https Enable

    To set the no_use_pegasus_interop_namespace policy:

        Set-CIM -F -Pol no_use_pegasus_interop_namespace

    To set the replica_entity policy:

        Set-CIM -F -Pol replica_entity
  
  .NOTES
    Access to all domains is required to run this command.

    You cannot disable both of the HTTP and HTTPS ports.

    When the CIM server is active, a warning message will be prompted to inform
    you of the current status of the CIM server and asks for the confirmation to
    continue or not. The -F option forces the action without a warning message.

    NAME:  Set-CIM
    LASTEDIT: 25/04/2021
    KEYWORDS: Set-CIM
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false, HelpMessage = "To forces the operation")]
        [Switch]
        $F,

        [Parameter(Position = 1, Mandatory = $false, HelpMessage = "To enables or disables the SLP port 427")]
        [ValidateSet("enable", "disable")]
        [System.String]
        $Slp,

        [Parameter(Position = 2, Mandatory = $false, HelpMessage = "To enables or disables the HTTP port 5988")]
        [ValidateSet("enable", "disable")]
        [System.String]
        $Http,

        [Parameter(Position = 3, Mandatory = $false, HelpMessage = "To enables or disables the HTTPS port 5989")]
        [ValidateSet("enable", "disable")]
        [System.String]
        $Https,

        [Parameter(Position = 4, Mandatory = $false, HelpMessage = "To sets the cim server policy")]
        [ValidateSet("replica_entity", "no_replica_entity", "one_hwid_per_view", "no_one_hwid_per_view", "use_pegasus_interop_namespace", "no_use_pegasus_interop_namespace", "tls_strict", "no_tls_strict")]
        [System.String]
        $Pol,
		
        [Parameter(Position = 5, Mandatory = $false, ValueFromPipeline = $true)]
        $SANConnection = $global:SANConnection        
    )	
	
    Write-DebugLog "Start: In Set-CIM   - validating input values" $Debug 
    #check if connection object contents are null/empty
    if (!$SANConnection) {
        #check if connection object contents are null/empty
        $Validate1 = Test-CLIConnection $SANConnection
        if ($Validate1 -eq "Failed") {
            #check if global connection object contents are null/empty
            $Validate2 = Test-CLIConnection $global:SANConnection
            if ($Validate2 -eq "Failed") {
                Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
                Write-DebugLog "Stop: Exiting Set-CIM since SAN connection object values are null/empty" $Debug
                return "Unable to execute the cmdlet Set-CIM since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."               
            }
        }
    }
    $plinkresult = Test-PARCli
    if ($plinkresult -match "FAILURE :") {
        write-debuglog "$plinkresult" "ERR:" 
        return $plinkresult
    }

    $cmd = "setcim "

    if ($F) {
        $cmd += " -f "
    }
    else {
        Return "Force set option is only supported with the Set-CIM cmdlet."
    }
	
    if (($Slp) -or ($Http) -or ($Https) -or ($Pol)) {

        if ($Slp) {
            $cmd += " -slp $Slp"
        }

        if ($Http) {
            $cmd += " -http $Http"
        }

        if ($Https) {
            $cmd += " -https $Https"
        }

        if ($Pol) {
            $cmd += " -pol $Pol"
        }
    }
    else {
        Return "At least one of the options -Slp, -Http, -Https, or -Pol are required."
    }
	
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd

    write-debuglog " Executed the Set-CIM cmdlet" "INFO:" 

    return 	$Result	

} # End Set-CIM

####################################################################################################################
## FUNCTION Stop-CIM
####################################################################################################################
Function Stop-CIM {
    <#
  .SYNOPSIS
    Stop the CIM server. Future CIM requests will be not supported.
                                                                                                           .
  .DESCRIPTION
     The Stop-CIM cmdlet stops the CIM server from servicing CIM requests.

  .PARAMETER F
    Specifies that the operation is forced. If this option is not used,
    the command requires confirmation before proceeding with its
    operation.
   
  .PARAMETER X
      Specifies that the operation terminates the server immediately
      without graceful shutdown notice.

  .EXAMPLES
    The following example stops the CIM server without confirmation

        Stop-CIM -F        

    The following example stops the CIM server immediately without graceful
    shutdown notice and confirmation:

        Stop-CIM -F -X        
  
  .NOTES
    Access to all domains is required to run this command.
    By default, the CIM server is not started until the Start-CIM cmdlet is issued.

    NAME:  Stop-CIM
    LASTEDIT: 25/04/2021
    KEYWORDS: Stop-CIM
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false, HelpMessage = "To forces the operation")]
        [Switch]
        $F,

        [Parameter(Position = 1, Mandatory = $false, HelpMessage = "To terminates the server immediately without graceful shutdown notice")]        
        [Switch]
        $X,
		
        [Parameter(Position = 5, Mandatory = $false, ValueFromPipeline = $true)]
        $SANConnection = $global:SANConnection        
    )	
	
    Write-DebugLog "Start: In Stop-CIM   - validating input values" $Debug 
    #check if connection object contents are null/empty
    if (!$SANConnection) {
        #check if connection object contents are null/empty
        $Validate1 = Test-CLIConnection $SANConnection
        if ($Validate1 -eq "Failed") {
            #check if global connection object contents are null/empty
            $Validate2 = Test-CLIConnection $global:SANConnection
            if ($Validate2 -eq "Failed") {
                Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
                Write-DebugLog "Stop: Exiting Stop-CIM since SAN connection object values are null/empty" $Debug
                return "Unable to execute the cmdlet Stop-CIM since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."               
            }
        }
    }
    $plinkresult = Test-PARCli
    if ($plinkresult -match "FAILURE :") {
        write-debuglog "$plinkresult" "ERR:" 
        return $plinkresult
    }

    $cmd = "setcim "	
	
    if ($F) {
        $cmd += " -f "
    }
    else {
        Return "Force set option is only supported with the Stop-CIM cmdlet."
    }

    if ($X) {
        $cmd += " -x "
    }
	
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd

    write-debuglog " Executed the Stop-CIM cmdlet" "INFO:" 

    return 	$Result	

} # End Stop-CIM

Export-ModuleMember Show-CIM , Start-CIM , Set-CIM , Stop-CIM
# SIG # Begin signature block
# MIIhzwYJKoZIhvcNAQcCoIIhwDCCIbwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCVBIUf1uQsB/Iq
# sRTevmf1IUaLjVoHAx8FIKYmVWnOkqCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIQejCCEHYCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# 0hPl7YQ906qmYRRr39ZtQ+uG/jJdCUt8/C4mYz5Yjp0wDQYJKoZIhvcNAQEBBQAE
# ggEA2/tILqPnuogCSPMdGZ1WJ1dwBt3+YlzUKI9OSZLm31S2rWbFcardec1vZ8gE
# vw3CoKZ2WpFahFBSVOhRAT1S16jdEIzWUYVj7gGWoLdcOo2jBp9EwAYdyjEgDnl/
# R/AkH/TA6nuQwZzFt0PwZRueT7uvFxfKjAuWvt03tD7KcuEWSjngrPrTS18WTn5f
# 67HOiCpFDxGt/OIcNJX7FIjgaj5cMeO5TqHaS4kqI7smzpc6daETu5HX4i4WwZ1f
# 5K1YxNga10PhZWOkwdr7TjVhqjSgRqhmFv67uxR/imCJxU2sQzNgmod0hihn8/VA
# IFmbMq/T1LoTofR3DwXnLPtpg6GCDjwwgg44BgorBgEEAYI3AwMBMYIOKDCCDiQG
# CSqGSIb3DQEHAqCCDhUwgg4RAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDgYLKoZIhvcN
# AQkQAQSggf4EgfswgfgCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# IDXRspAou8RaTOfzFE4CUrMPeXFnrOhcr8ja4yWBdhwBAhRc0nL0kkzYDPgdaWDQ
# xeotsRo6HBgPMjAyMTA2MTkwNDAyMDNaMAMCAR6ggYakgYMwgYAxCzAJBgNVBAYT
# AlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3lt
# YW50ZWMgVHJ1c3QgTmV0d29yazExMC8GA1UEAxMoU3ltYW50ZWMgU0hBMjU2IFRp
# bWVTdGFtcGluZyBTaWduZXIgLSBHM6CCCoswggU4MIIEIKADAgECAhB7BbHUSWhR
# RPfJidKcGZ0SMA0GCSqGSIb3DQEBCwUAMIG9MQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdv
# cmsxOjA4BgNVBAsTMShjKSAyMDA4IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhv
# cml6ZWQgdXNlIG9ubHkxODA2BgNVBAMTL1ZlcmlTaWduIFVuaXZlcnNhbCBSb290
# IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE2MDExMjAwMDAwMFoXDTMxMDEx
# MTIzNTk1OVowdzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBv
# cmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMSgwJgYDVQQD
# Ex9TeW1hbnRlYyBTSEEyNTYgVGltZVN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAu1mdWVVPnYxyXRqBoutV87ABrTxxrDKPBWuGmicA
# MpdqTclkFEspu8LZKbku7GOz4c8/C1aQ+GIbfuumB+Lef15tQDjUkQbnQXx5HMvL
# rRu/2JWR8/DubPitljkuf8EnuHg5xYSl7e2vh47Ojcdt6tKYtTofHjmdw/SaqPSE
# 4cTRfHHGBim0P+SDDSbDewg+TfkKtzNJ/8o71PWym0vhiJka9cDpMxTW38eA25Hu
# /rySV3J39M2ozP4J9ZM3vpWIasXc9LFL1M7oCZFftYR5NYp4rBkyjyPBMkEbWQ6p
# PrHM+dYr77fY5NUdbRE6kvaTyZzjSO67Uw7UNpeGeMWhNwIDAQABo4IBdzCCAXMw
# DgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwZgYDVR0gBF8wXTBb
# BgtghkgBhvhFAQcXAzBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Quc3ltY2IuY29t
# L2NwczAlBggrBgEFBQcCAjAZGhdodHRwczovL2Quc3ltY2IuY29tL3JwYTAuBggr
# BgEFBQcBAQQiMCAwHgYIKwYBBQUHMAGGEmh0dHA6Ly9zLnN5bWNkLmNvbTA2BgNV
# HR8ELzAtMCugKaAnhiVodHRwOi8vcy5zeW1jYi5jb20vdW5pdmVyc2FsLXJvb3Qu
# Y3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMIMCgGA1UdEQQhMB+kHTAbMRkwFwYDVQQD
# ExBUaW1lU3RhbXAtMjA0OC0zMB0GA1UdDgQWBBSvY9bKo06FcuCnvEHzKaI4f4B1
# YjAfBgNVHSMEGDAWgBS2d/ppSEefUxLVwuoHMnYH0ZcHGTANBgkqhkiG9w0BAQsF
# AAOCAQEAdeqwLdU0GVwyRf4O4dRPpnjBb9fq3dxP86HIgYj3p48V5kApreZd9KLZ
# VmSEcTAq3R5hF2YgVgaYGY1dcfL4l7wJ/RyRR8ni6I0D+8yQL9YKbE4z7Na0k8hM
# kGNIOUAhxN3WbomYPLWYl+ipBrcJyY9TV0GQL+EeTU7cyhB4bEJu8LbF+GFcUvVO
# 9muN90p6vvPN/QPX2fYDqA/jU/cKdezGdS6qZoUEmbf4Blfhxg726K/a7JsYH6q5
# 4zoAv86KlMsB257HOLsPUqvR45QDYApNoP4nbRQy/D+XQOG/mYnb5DkUvdrk08Pq
# K1qzlVhVBH3HmuwjA42FKtL/rqlhgTCCBUswggQzoAMCAQICEHvU5a+6zAc/oQEj
# BCJBTRIwDQYJKoZIhvcNAQELBQAwdzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5
# bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3
# b3JrMSgwJgYDVQQDEx9TeW1hbnRlYyBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4X
# DTE3MTIyMzAwMDAwMFoXDTI5MDMyMjIzNTk1OVowgYAxCzAJBgNVBAYTAlVTMR0w
# GwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMg
# VHJ1c3QgTmV0d29yazExMC8GA1UEAxMoU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFt
# cGluZyBTaWduZXIgLSBHMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AK8Oiqr43L9pe1QXcUcJvY08gfh0FXdnkJz93k4Cnkt29uU2PmXVJCBtMPndHYPp
# PydKM05tForkjUCNIqq+pwsb0ge2PLUaJCj4G3JRPcgJiCYIOvn6QyN1R3AMs19b
# jwgdckhXZU2vAjxA9/TdMjiTP+UspvNZI8uA3hNN+RDJqgoYbFVhV9HxAizEtavy
# bCPSnw0PGWythWJp/U6FwYpSMatb2Ml0UuNXbCK/VX9vygarP0q3InZl7Ow28paV
# gSYs/buYqgE4068lQJsJU/ApV4VYXuqFSEEhh+XetNMmsntAU1h5jlIxBk2UA0XE
# zjwD7LcA8joixbRv5e+wipsCAwEAAaOCAccwggHDMAwGA1UdEwEB/wQCMAAwZgYD
# VR0gBF8wXTBbBgtghkgBhvhFAQcXAzBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Qu
# c3ltY2IuY29tL2NwczAlBggrBgEFBQcCAjAZGhdodHRwczovL2Quc3ltY2IuY29t
# L3JwYTBABgNVHR8EOTA3MDWgM6Axhi9odHRwOi8vdHMtY3JsLndzLnN5bWFudGVj
# LmNvbS9zaGEyNTYtdHNzLWNhLmNybDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwdwYIKwYBBQUHAQEEazBpMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wOwYIKwYBBQUHMAKGL2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3NoYTI1Ni10c3MtY2EuY2VyMCgGA1UdEQQh
# MB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC02MB0GA1UdDgQWBBSlEwGp
# n4XMG24WHl87Map5NgB7HTAfBgNVHSMEGDAWgBSvY9bKo06FcuCnvEHzKaI4f4B1
# YjANBgkqhkiG9w0BAQsFAAOCAQEARp6v8LiiX6KZSM+oJ0shzbK5pnJwYy/jVSl7
# OUZO535lBliLvFeKkg0I2BC6NiT6Cnv7O9Niv0qUFeaC24pUbf8o/mfPcT/mMwnZ
# olkQ9B5K/mXM3tRr41IpdQBKK6XMy5voqU33tBdZkkHDtz+G5vbAf0Q8RlwXWuOk
# O9VpJtUhfeGAZ35irLdOLhWa5Zwjr1sR6nGpQfkNeTipoQ3PtLHaPpp6xyLFdM3f
# RwmGxPyRJbIblumFCOjd6nRgbmClVnoNyERY3Ob5SBSe5b/eAL13sZgUchQk38cR
# LB8AP8NLFMZnHMweBqOQX1xUiz7jM1uCD8W3hgJOcZ/pZkU/djGCAlowggJWAgEB
# MIGLMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlv
# bjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEoMCYGA1UEAxMfU3lt
# YW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQe9Tlr7rMBz+hASMEIkFNEjAL
# BglghkgBZQMEAgGggaQwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqG
# SIb3DQEJBTEPFw0yMTA2MTkwNDAyMDNaMC8GCSqGSIb3DQEJBDEiBCB4Ms+niqyp
# /z9btdFCAya7P9N0FvZyILS1a/FfQOjezTA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCDEdM52AH0COU4NpeTefBTGgPniggE8/vZT7123H99h+DALBgkqhkiG9w0BAQEE
# ggEAQ4RD5sRRQaiLGawV8RUG92PhUCC+z6cPlsPh9ZlDW53ynQ5EMqPOpOzhjEW6
# h460gWQ7GpO9/bp504rxXK4sqSTCBR0vVqK/dWi6cXW8bl3unAhf8jwGfjtVRXrQ
# yez8rCI/u0SOqUT2ya+09J32+8biuqn28JyFvSeo1cu9Y6WerWg3rafo2+6e201x
# LkqN6IHGWJmgW1+c3+pRW1l7V3xqCI9NepGPcJb9N9IqKFgVwfk11DSJTXQCCLEl
# t3nE2Y8KttW0Ylb3TNkEWez1d8ULzfCfCYCyPG7dErtWOZnhDtxVVsnN017Pbu/o
# PQ6ip5PWkWPzWoq8jPKxtpGk+A==
# SIG # End signature block
