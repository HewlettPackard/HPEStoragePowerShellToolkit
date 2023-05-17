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
##	File Name:		SessionKeysAndWsapiSystemAccess.psm1
##	Description: 	Session keys and WSAPI system access cmdlets 
##		
##	Created:		January 2020
##	Last Modified:	April 2021
##	History:		v3.0 - Created
## 					v3.1 - Added support for Primera 4.2 and Alletra 9000 storage system
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
$global:ArrayType = $null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## New-WSAPIConnection
############################################################################################################################################
Function New-WSAPIConnection {
<#	
  .SYNOPSIS
	Create a WSAPI session key
  
  .DESCRIPTION
	To use Web Services, you must create a session key. Use the same username and password that you use to
	access the storage system through the 3PAR CLI or the 3PAR MC. Creating this authorization allows
	you to complete the same operations using WSAPI as you would the CLI or MC.
        
  .EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType 3par
	create a session key with array.
	
  .EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType primera
	create a session key with Primera array.
	
  .EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType alletra9000
	create a session key with Alletra 9000 array.

  .PARAMETER ArrayFQDNorIPAddress 
    Specify the Array FQDN or Array IP address.
	
  .PARAMETER UserName 
    Specify the user name
	
  .PARAMETER Password 
    Specify the password 
		
  .PARAMETER ArrayType
	Specify the array type ie. 3Par, Primera or Alletra9000
              
  .Notes
    NAME    : New-WSAPIConnection    
    LASTEDIT: April 2021
    KEYWORDS: New-WSAPIConnection
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0
#>
[CmdletBinding()]
	param(
			[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
			[System.String]
			$ArrayFQDNorIPAddress,

			[Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
			[System.String]
			$SANUserName=$null,

			[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
			[System.String]
			$SANPassword=$null ,

			[Parameter(Position=3, Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Enter array type : 3par, primera or alletra9000")]
			[ValidateSet("3par", "primera", "alletra9000")]
			[System.String]
			$ArrayType
		)
#(self-signed) certificate,

if ($PSEdition -eq 'Core')
{
    
} 
else 
{

add-type @" 
using System.Net; 
using System.Security.Cryptography.X509Certificates; 
public class TrustAllCertsPolicy : ICertificatePolicy { 
	public bool CheckValidationResult( 
		ServicePoint srvPoint, X509Certificate certificate, 
		WebRequest request, int certificateProblem) { 
		return true; 
	} 
} 
"@  
		[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

#END of (self-signed) certificate,
		if(!($SANPassword))
		{
			$SANPassword1 = Read-host "SANPassword" -assecurestring
			#$globalpwd = $SANPassword1
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SANPassword1)
			$SANPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		}
		
		#Write-DebugLog "start: Entering function New-WSAPIConnection. Validating IP Address format." $Debug	
		#if(-not (Test-IPFormat $ArrayFQDNorIPAddress))		
		#{
		#	Write-DebugLog "Stop: Invalid IP Address $ArrayFQDNorIPAddress" "ERR:"
		#	return "FAILURE : Invalid IP Address $ArrayFQDNorIPAddress"
		#}
		
		<#
		# -------- Check any active CLI/PoshSSH session exists ------------ starts		
		if($global:SANConnection){
			$confirm = Read-Host "An active CLI/PoshSSH session exists.`nDo you want to close the current CLI/PoshSSH session and start a new WSAPI session (Enter y=yes n=no)"
			if ($confirm.tolower() -eq 'y') {
				Close-Connection
			}
			elseif ($confirm.tolower() -eq 'n') {
				return
			}
		}
		# -------- Check any active CLI/PoshSSH session exists ------------ ends
		
		# -------- Check any active WSAPI session exists ------------------ starts
		if($global:WsapiConnection){
			$confirm = Read-Host "An active WSAPI session exists.`nDo you want to close the current WSAPI session and start a new WSAPI session (Enter y=yes n=no)"
			if ($confirm.tolower() -eq 'y') {
				Close-WSAPIConnection
			}
			elseif ($confirm.tolower() -eq 'n') {
				return
			}
		}
		# -------- Check any active WSAPI session exists ------------------ ends		
		#>
		
		#Write-DebugLog "Running: Completed validating IP address format." $Debug		
		#Write-DebugLog "Running: Authenticating credentials - Invoke-WSAPI for user $SANUserName and SANIP= $ArrayFQDNorIPAddress" $Debug
		
		#URL
		$APIurl = $null
		if($ArrayType.ToLower() -eq "3par")
		{
			$global:ArrayType = "3par" 
			$APIurl = "https://$($ArrayFQDNorIPAddress):8080/api/v1" 	
		}
		elseif($ArrayType.ToLower() -eq "primera")
		{
			$global:ArrayType = "Primera" 
			$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	
		}
		elseif($ArrayType.ToLower() -eq "alletra9000")
		{
			$global:ArrayType = "Alletra9000" 
			$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	
		}
		else
		{
			write-host " You have entered an unsupported Array type : $ArrayType. Please enter the array type as 3par, Primera or Alletra 9000." -foreground yellow
			Return
		}
		
		#connect to WSAPI
		$postParams = @{user=$SANUserName;password=$SANPassword} | ConvertTo-Json 
		$headers = @{}  
		$headers["Accept"] = "application/json" 
		
		Try
		{
			Write-DebugLog "Running: Invoke-WebRequest for credential data." $Debug
			if ($PSEdition -eq 'Core')
			{				
				$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing -SkipCertificateCheck
			} 
			else 
			{				
				$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing 
			}
		}
		catch
		{
			Write-DebugLog "Stop: Exception Occurs" $Debug
			Show-RequestException -Exception $_
			write-host ""
			write-host "FAILURE : While establishing the connection " -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While establishing the connection " $Info
			throw
		}
		
		#$global:3parArray = $ArrayFQDNorIPAddress
		$key = ($credentialdata.Content | ConvertFrom-Json).key
		#$global:3parKey = $key
		if(!$key)
		{
			Write-DebugLog "Stop: No key Generated"
			return "Error: No key Generated"
		}
		
		$SANC1 = New-Object "WSAPIconObject"
		
		$SANC1.IPAddress = $ArrayFQDNorIPAddress					
		$SANC1.Key = $key
				
		$Result = Get-System_WSAPI -WsapiConnection $SANC1
		
		$SANC = New-Object "WSAPIconObject"
		
		$SANC.Id = $Result.id
		$SANC.Name = $Result.name
		$SANC.SystemVersion = $Result.systemVersion
		$SANC.Patches = $Result.patches
		$SANC.IPAddress = $ArrayFQDNorIPAddress
		$SANC.Model = $Result.model
		$SANC.SerialNumber = $Result.serialNumber
		$SANC.TotalCapacityMiB = $Result.totalCapacityMiB
		$SANC.AllocatedCapacityMiB = $Result.allocatedCapacityMiB
		$SANC.FreeCapacityMiB = $Result.freeCapacityMiB					
		$SANC.Key = $key
		
		$global:WsapiConnection = $SANC
		
		$global:ArrayName = $Result.name

		# Set to the prompt as "Array Name:Connection Type (WSAPI|CLI)>"		
		Function global:prompt {
		if ($global:WsapiConnection -ne $null){
			$global:ArrayName + ":WSAPI>"
			} 
		else{
				(Get-Location).Path + ">"
			}
		}
			
		Write-DebugLog "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used" $Info		
		#Write-Verbose -Message "Acquired token: $global:3parKey"
		Write-Verbose -Message 'You are now connected to the HPE Storage system'
		Write-Verbose -Message 'Show array informations:'	
		
		return $SANC
}
#End of New-WSAPIConnection

############################################################################################################################################
## FUNCTION Close-WSAPIConnection
############################################################################################################################################
Function Close-WSAPIConnection
 {
  <#

  .SYNOPSIS
	Delete a WSAPI session key.
  
  .DESCRIPTION
	When finishes making requests to the server it should delete the session keys it created .
	Unused session keys expire automatically after the configured session times out.
	
  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .EXAMPLE
    Close-WSAPIConnection
	Delete a WSAPI session key.
              
  .Notes
    NAME    : Close-WSAPIConnection    
    LASTEDIT: January 2020
    KEYWORDS: Close-WSAPIConnection
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0
  
  #>
  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	$WsapiConnection = $global:WsapiConnection 
  )
  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {
    if ($pscmdlet.ShouldProcess($h.name,"Disconnect from array")) 
	{
      #Build uri
	  
	  #$ip = $WsapiConnection.IPAddress
	  $key = $WsapiConnection.Key
	  
	  Write-DebugLog "Running: Building uri to close wsapi connection cmdlet." $Debug
      $uri = '/credentials/'+$key

      #init the response var
      $data = $null

      #Request
	  Write-DebugLog "Request: Request to close wsapi connection (Invoke-WSAPI)." $Debug
      $data = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection

	  $global:WsapiConnection = $null
	  
		# Set to the default prompt as current path
		if ($global:WsapiConnection -eq $null)
		{
			Function global:prompt {(Get-Location).Path + ">"}
		}
		
	  return $data
	  <#
      If ($global:3parkey) 
	  {
        Write-Verbose -Message "Delete key session: $global:3parkey"
        Remove-Variable -name 3parKey -scope global
		Write-DebugLog "End: Key Deleted" $Debug
      }
	  If ($global:3parArray) 
	  {
        Write-Verbose -Message "Delete Array: $global:3parArray"
        Remove-Variable -name 3parArray -scope global
		Write-DebugLog "End: Delete Array: $global:3parArray" $Debug
      }
	  #>
    }
	Write-DebugLog "End: Close-WSAPIConnection" $Debug
  }
  End {}  
}
#END Close-WSAPIConnection

Export-ModuleMember New-WSAPIConnection , Close-WSAPIConnection
# SIG # Begin signature block
# MIIh0AYJKoZIhvcNAQcCoIIhwTCCIb0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBgNfMCqC2m+PhB
# UU4Sde0axzqT0BNuy1eZ9HE3k54t46CCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIQezCCEHcCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# JhDKR56BE/Dz//DKzx2yb2YsaDk9gpKu9Pl0GlCBDAEwDQYJKoZIhvcNAQEBBQAE
# ggEA1p3rfhVpFRa3ky59Fz01g2RXYHpWeOM5hfaU2EvkVE6EY+mZg9+AErcAs4zY
# vtZFDIo03VZtz2xPiNTy5teb20s5FafqA5EepzzEwHEOUNaqxvMS2WuJJKZYKcMg
# QT2xVCf1FHtaxltE5o+83pyDu6RUjNq8PvkDhd4iAuLEyqF7C6Bcdy/SZel6BEVB
# QKH49NQB7QwdfpelB8HOB324cDwlI1IkIveu+mBzbAuWUIMPXbbnJ5CWh7xvqSO1
# ZGnwe55DdcY250OL0aNKefaU8doEUGp4vu92OLItRv7U+Xf1vPIJKFPc3FE035c2
# otazLeS3eIGqtYYzxf4nst1bAKGCDj0wgg45BgorBgEEAYI3AwMBMYIOKTCCDiUG
# CSqGSIb3DQEHAqCCDhYwgg4SAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDwYLKoZIhvcN
# AQkQAQSggf8EgfwwgfkCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# IIb8GDcFDK5o4H1cReDbWu38vL3uEyje+xb5ij7/WLeRAhUA6Ykll+Ss0hmKNX7c
# 7iNAp9XrTLkYDzIwMjEwNjE5MDUyMjExWjADAgEeoIGGpIGDMIGAMQswCQYDVQQG
# EwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5
# bWFudGVjIFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBU
# aW1lU3RhbXBpbmcgU2lnbmVyIC0gRzOgggqLMIIFODCCBCCgAwIBAgIQewWx1Elo
# UUT3yYnSnBmdEjANBgkqhkiG9w0BAQsFADCBvTELMAkGA1UEBhMCVVMxFzAVBgNV
# BAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3
# b3JrMTowOAYDVQQLEzEoYykgMjAwOCBWZXJpU2lnbiwgSW5jLiAtIEZvciBhdXRo
# b3JpemVkIHVzZSBvbmx5MTgwNgYDVQQDEy9WZXJpU2lnbiBVbml2ZXJzYWwgUm9v
# dCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xNjAxMTIwMDAwMDBaFw0zMTAx
# MTEyMzU5NTlaMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jw
# b3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEoMCYGA1UE
# AxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALtZnVlVT52Mcl0agaLrVfOwAa08cawyjwVrhpon
# ADKXak3JZBRLKbvC2Sm5Luxjs+HPPwtWkPhiG37rpgfi3n9ebUA41JEG50F8eRzL
# y60bv9iVkfPw7mz4rZY5Ln/BJ7h4OcWEpe3tr4eOzo3HberSmLU6Hx45ncP0mqj0
# hOHE0XxxxgYptD/kgw0mw3sIPk35CrczSf/KO9T1sptL4YiZGvXA6TMU1t/HgNuR
# 7v68kldyd/TNqMz+CfWTN76ViGrF3PSxS9TO6AmRX7WEeTWKeKwZMo8jwTJBG1kO
# qT6xzPnWK++32OTVHW0ROpL2k8mc40juu1MO1DaXhnjFoTcCAwEAAaOCAXcwggFz
# MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMGYGA1UdIARfMF0w
# WwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNvbS9ycGEwLgYI
# KwYBBQUHAQEEIjAgMB4GCCsGAQUFBzABhhJodHRwOi8vcy5zeW1jZC5jb20wNgYD
# VR0fBC8wLTAroCmgJ4YlaHR0cDovL3Muc3ltY2IuY29tL3VuaXZlcnNhbC1yb290
# LmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAoBgNVHREEITAfpB0wGzEZMBcGA1UE
# AxMQVGltZVN0YW1wLTIwNDgtMzAdBgNVHQ4EFgQUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwHwYDVR0jBBgwFoAUtnf6aUhHn1MS1cLqBzJ2B9GXBxkwDQYJKoZIhvcNAQEL
# BQADggEBAHXqsC3VNBlcMkX+DuHUT6Z4wW/X6t3cT/OhyIGI96ePFeZAKa3mXfSi
# 2VZkhHEwKt0eYRdmIFYGmBmNXXHy+Je8Cf0ckUfJ4uiNA/vMkC/WCmxOM+zWtJPI
# TJBjSDlAIcTd1m6JmDy1mJfoqQa3CcmPU1dBkC/hHk1O3MoQeGxCbvC2xfhhXFL1
# TvZrjfdKer7zzf0D19n2A6gP41P3CnXsxnUuqmaFBJm3+AZX4cYO9uiv2uybGB+q
# ueM6AL/OipTLAduexzi7D1Kr0eOUA2AKTaD+J20UMvw/l0Dhv5mJ2+Q5FL3a5NPD
# 6itas5VYVQR9x5rsIwONhSrS/66pYYEwggVLMIIEM6ADAgECAhB71OWvuswHP6EB
# IwQiQU0SMA0GCSqGSIb3DQEBCwUAMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRT
# eW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0
# d29yazEoMCYGA1UEAxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAe
# Fw0xNzEyMjMwMDAwMDBaFw0yOTAzMjIyMzU5NTlaMIGAMQswCQYDVQQGEwJVUzEd
# MBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVj
# IFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgU2lnbmVyIC0gRzMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCvDoqq+Ny/aXtUF3FHCb2NPIH4dBV3Z5Cc/d5OAp5LdvblNj5l1SQgbTD53R2D
# 6T8nSjNObRaK5I1AjSKqvqcLG9IHtjy1GiQo+BtyUT3ICYgmCDr5+kMjdUdwDLNf
# W48IHXJIV2VNrwI8QPf03TI4kz/lLKbzWSPLgN4TTfkQyaoKGGxVYVfR8QIsxLWr
# 8mwj0p8NDxlsrYViaf1OhcGKUjGrW9jJdFLjV2wiv1V/b8oGqz9KtyJ2ZezsNvKW
# lYEmLP27mKoBONOvJUCbCVPwKVeFWF7qhUhBIYfl3rTTJrJ7QFNYeY5SMQZNlANF
# xM48A+y3API6IsW0b+XvsIqbAgMBAAGjggHHMIIBwzAMBgNVHRMBAf8EAjAAMGYG
# A1UdIARfMF0wWwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9k
# LnN5bWNiLmNvbS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9ycGEwQAYDVR0fBDkwNzA1oDOgMYYvaHR0cDovL3RzLWNybC53cy5zeW1hbnRl
# Yy5jb20vc2hhMjU2LXRzcy1jYS5jcmwwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# DgYDVR0PAQH/BAQDAgeAMHcGCCsGAQUFBwEBBGswaTAqBggrBgEFBQcwAYYeaHR0
# cDovL3RzLW9jc3Aud3Muc3ltYW50ZWMuY29tMDsGCCsGAQUFBzAChi9odHRwOi8v
# dHMtYWlhLndzLnN5bWFudGVjLmNvbS9zaGEyNTYtdHNzLWNhLmNlcjAoBgNVHREE
# ITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtNjAdBgNVHQ4EFgQUpRMB
# qZ+FzBtuFh5fOzGqeTYAex0wHwYDVR0jBBgwFoAUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwDQYJKoZIhvcNAQELBQADggEBAEaer/C4ol+imUjPqCdLIc2yuaZycGMv41Up
# ezlGTud+ZQZYi7xXipINCNgQujYk+gp7+zvTYr9KlBXmgtuKVG3/KP5nz3E/5jMJ
# 2aJZEPQeSv5lzN7Ua+NSKXUASiulzMub6KlN97QXWZJBw7c/hub2wH9EPEZcF1rj
# pDvVaSbVIX3hgGd+Yqy3Ti4VmuWcI69bEepxqUH5DXk4qaENz7Sx2j6aescixXTN
# 30cJhsT8kSWyG5bphQjo3ep0YG5gpVZ6DchEWNzm+UgUnuW/3gC9d7GYFHIUJN/H
# ESwfAD/DSxTGZxzMHgajkF9cVIs+4zNbgg/Ft4YCTnGf6WZFP3YxggJaMIICVgIB
# ATCBizB3MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRp
# b24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxKDAmBgNVBAMTH1N5
# bWFudGVjIFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEHvU5a+6zAc/oQEjBCJBTRIw
# CwYJYIZIAWUDBAIBoIGkMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkq
# hkiG9w0BCQUxDxcNMjEwNjE5MDUyMjExWjAvBgkqhkiG9w0BCQQxIgQg+KRCroUE
# oCxrTJAqlzK/RLCVIXT97iLWyj1poziB9PYwNwYLKoZIhvcNAQkQAi8xKDAmMCQw
# IgQgxHTOdgB9AjlODaXk3nwUxoD54oIBPP72U+9dtx/fYfgwCwYJKoZIhvcNAQEB
# BIIBAHcFWQubQO9s3586pOVhdraPLSxA5n4KBBc6U8dbLO6HQvQ5nrevMkx8R+Fa
# +yCJ6W5zFf6+sZf867jkPZPBEFIDAlEEPCHQug47B34ZBz8/6OZUw6CN8rxNyfEF
# y/8BCge5liUyTO2ngttvnThmCiL6qH3nMwQ6buEZ2ur2LV/IBMmd2ys7igqawh5B
# hd2SQgUZJ9phLdZ2eDe2ZtR707hwOP74JbSxOFE3CqqL+iwkXjjaote55nRHciGs
# QF/6SsQINR0p5cO6u35ZIkpLoWxvfJljcVdjNKlm9P3HqtQkmfC0RKWKkhRZHImR
# wEY3gdpB2TQLWOAMWVcSWh0rZhQ=
# SIG # End signature block
