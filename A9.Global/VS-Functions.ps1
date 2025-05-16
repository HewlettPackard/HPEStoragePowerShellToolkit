####################################################################################
## 	© 2019,2020 Hewlett Packard Enterprise Development LP
##
##	File Name:		VS-Functions.psm1
##	Description: 	Common Module functions.
##		
##	Pre-requisites: Needs POSH SSH Module for New-PoshSshConnection
##					WSAPI uses array based HPE WSAPI service.
##					
##					Starting the WSAPI server    : The WSAPI server does not start automatically.
##					Using SSH, enter startwsapi to manually start the WSAPI server.
## 					Configuring the WSAPI server: To configure WSAPI, enter set-A9wsapi in the SSH command set.
##
##	Created:		June 2015
##	Last Modified:	March 2024
##
##	History:		v1.0 - Created
##					v2.0 - Added support for HP3PAR CLI
##                     v2.1 - Added support for POSH SSH Module
##					v2.2 - Added support for WSAPI
##                  v2.3 - Added Support for all CLI cmdlets
##                     v2.3.1 - Added support for primara array with wsapi
##                  v3.0 - Added Support for wsapi 1.7 
##                  v3.0 - Modularization
##                  v3.0.1 (07/30/2020) - Fixed the Show-RequestException function to show the actual error message
##					v3.5.0 (03/17/2024) - Refactored all commands. Removed CLI access. only uses SSH or WSAPI now.

Function Invoke-A9CLICommand 
{
<#
.SYNOPSIS
	Execute a command against a device using HP3PAR CLI
.DESCRIPTION
	Execute a command against a device using HP3PAR CLI
.PARAMETER Connection
	Pointer to an object that contains passwordfile, HP3parCLI installed path and IP address
.PARAMETER Cmds
	Command to be executed
.EXAMPLE		
	Invoke-A9CLICommand -Connection $global:SANConnection -Cmds "showsysmgr"

	The command queries a array to get the system information
	$global:SANConnection is created wiith the cmdlet New-CLIConnection or New-PoshSshConnection
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]	[string]	$Cmds  
	)
	if ( -not (Test-A9Connection -ClientType 'SshClient' -returnBoolean) ) 
		{	Write-Warning  "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-*Connection and pass it as parameter" 
			Write-Warning  "Stop: Exiting Invoke-A9CLICommand since connection object values are null/empty"
			return
		}
	$Result = Invoke-SSHCommand -Command $Cmds -SessionId $SANConnection.SessionId
	if ($Result.ExitStatus -eq 0) 	
		{	return $Result.Output	}
	else{	$ErrorString = "Error :-" + $Result.Error + $Result.Output			    
			return $ErrorString
		}	
}

function Invoke-A9API 
{
[CmdletBinding()]
Param (	[parameter(Mandatory = $true, HelpMessage = "Enter the resource URI (ex. /volumes)")]
		[ValidateScript( { if ($_.startswith('/')) { $true } else { throw "-URI must begin with a '/' (eg. /volumes) in its value. Correct the value and try again." } })]
		[string]	$uri,
		
		[parameter(Mandatory = $true)][ValidateSet('GET','POST','DELETE')]
		[string]	$type,
		
		[parameter()]
		[array]		$body,
		
		[Parameter()]
		$WsapiConnection = $global:WsapiConnection
	)
	Write-Verbose  "Request: Request Invoke-A9API URL : $uri TYPE : $type " 
	$ip = $WsapiConnection.IPAddress
	$key = $WsapiConnection.Key
	$arrtyp = $global:ArrayType
	if ($arrtyp.ToLower() -eq "3par") {
		$APIurl = 'https://' + $ip + ':8080/api/v1' 	
	}
	Elseif(($arrtyp.ToLower() -eq "primera") -or ($arrtyp.ToLower() -eq "alletra9000")) 
		{	$APIurl = 'https://' + $ip + ':443/api/v1'	
		}
	else{	return "Array type is Null."
		}
	$url = $APIurl + $uri
	Write-Verbose  "Running: Constructing header." 
	$headers = @{}
	$headers["Accept"] = "application/json"
	$headers["Accept-Language"] = "en"
	$headers["Content-Type"] = "application/json"
	$headers["X-HP3PAR-WSAPI-SessionKey"] = $key
	$data = $null
	If ($type -eq 'GET') 
		{	Try 	{	if ($PSEdition -eq 'Core') 
							{	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
							} 
						else{	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
							}
						return $data
					}
			Catch 	{	$_
						return
					}
		}
	If (($type -eq 'POST') -or ($type -eq 'PUT')) 
		{	Try {	Write-Verbose  "Request: Invoke-WebRequest for Data, Request Type : $type" 
					$json = $body | ConvertTo-Json  -Compress -Depth 10	
					if ($PSEdition -eq 'Core') 
						{	$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
						}
					else{	$data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing 
						}
					return $data
				}
			Catch 	
				{	$_
					return
				}
		}
	If ($type -eq 'DELETE') 
		{	Try {	if ($PSEdition -eq 'Core') 
						{	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
						} 
					else{    $data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
						}
					return $data
				}
			Catch 
				{	$_
					return
				}
		}
}


# SIG # Begin signature block
# MIIt4wYJKoZIhvcNAQcCoIIt1DCCLdACAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEB9jAQdLNkm
# cfkbR4kbqgSMxlr4najzshdoPEgvxumzwbZZn5jHDmglDtW9nqhCH2LMsjaJtayG
# TnK/o6PZ0YLmoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG6AwghucAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQJAhhE03zot1CxQrje9uqSf2JNVojL5vHLpQVvUaTCNFXepRSTpJdk7J
# FOIUP+P8+49ZvzskUir82bK/OLj5AgUwDQYJKoZIhvcNAQEBBQAEggGAiyM0w6MO
# Ma+f/9UsoLNhOFYYJ57Weeya1H2G8qZlEidVU3DjTvW2+TxdWjScRktiwo2uEi7f
# EfSLkY/mz/89Vr5uwgDOKBsp27YLh/eF+gOPjLVezPStDSyJITZ48LVh2FnNyJda
# KdVpM5nz35Iy99/e9IhUYWoTiw9s0LnJ0riWVAgvWd0yTE+3c2yuiTfhhXNdTrRg
# z15tEWX3Buxalv9iwQU+ZQUehOCBwoPz7rKMQPnIv1pgngU22fXcWSz6wiQ8OGTz
# 5QcXVUuf30eaxr7tcccMVjqBz3cQpHDKbk7qy46b+TQw/1beShdbFFqVUK05cvgJ
# TghF+9Epz8NehFArr8VGnZV+Ec6cJdMZbad6TWZnwYtZvl7ozj22m5CFSRAKu1OT
# J37TGq3a5q23Pt9m8Ft/TikgfsLNPuU+/Zio4aAEj+1QbWNQX08OkN3PAMmDK7Bz
# nCAobXHL1WXK+Q0gV/qyREKwwFVKI83rWD6HmMEwUGQc/RPg3b9DlSZkoYIY6TCC
# GOUGCisGAQQBgjcDAwExghjVMIIY0QYJKoZIhvcNAQcCoIIYwjCCGL4CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQgGCyqGSIb3DQEJEAEEoIH4BIH1MIHyAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMFW2j2iNF0JdHMTFAqqL+LGHxG7n/NnI
# 9Wil06Ihn/OszIpKRfqDiPEK4VjqASDsFAIVAMj9vRdhl22LGV+NC2G1g53nAjSG
# GA8yMDI1MDUxNTAyNDIwMlqgdqR0MHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5X
# ZXN0IFlvcmtzaGlyZTEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTAwLgYDVQQD
# EydTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFNpZ25lciBSMzagghMEMIIG
# YjCCBMqgAwIBAgIRAKQpO24e3denNAiHrXpOtyQwDQYJKoZIhvcNAQEMBQAwVTEL
# MAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMj
# U2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwHhcNMjUwMzI3MDAw
# MDAwWhcNMzYwMzIxMjM1OTU5WjByMQswCQYDVQQGEwJHQjEXMBUGA1UECBMOV2Vz
# dCBZb3Jrc2hpcmUxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMn
# U2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM2MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA04SV9G6kU3jyPRBLeBIHPNyUgVNnYayf
# sGOyYEXrn3+SkDYTLs1crcw/ol2swE1TzB2aR/5JIjKNf75QBha2Ddj+4NEPKDxH
# Ed4dEn7RTWMcTIfm492TW22I8LfH+A7Ehz0/safc6BbsNBzjHTt7FngNfhfJoYOr
# kugSaT8F0IzUh6VUwoHdYDpiln9dh0n0m545d5A5tJD92iFAIbKHQWGbCQNYplqp
# AFasHBn77OqW37P9BhOASdmjp3IijYiFdcA0WQIe60vzvrk0HG+iVcwVZjz+t5Oc
# XGTcxqOAzk1frDNZ1aw8nFhGEvG0ktJQknnJZE3D40GofV7O8WzgaAnZmoUn4PCp
# vH36vD4XaAF2CjiPsJWiY/j2xLsJuqx3JtuI4akH0MmGzlBUylhXvdNVXcjAuIEc
# EQKtOBR9lU4wXQpISrbOT8ux+96GzBq8TdbhoFcmYaOBZKlwPP7pOp5Mzx/UMhyB
# A93PQhiCdPfIVOCINsUY4U23p4KJ3F1HqP3H6Slw3lHACnLilGETXRg5X/Fp8G8q
# lG5Y+M49ZEGUp2bneRLZoyHTyynHvFISpefhBCV0KdRZHPcuSL5OAGWnBjAlRtHv
# sMBrI3AAA0Tu1oGvPa/4yeeiAyu+9y3SLC98gDVbySnXnkujjhIh+oaatsk/oyf5
# R2vcxHahajMCAwEAAaOCAY4wggGKMB8GA1UdIwQYMBaAFF9Y7UwxeqJhQo1SgLqz
# YZcZojKbMB0GA1UdDgQWBBSIYYyhKjdkgShgoZsx0Iz9LALOTzAOBgNVHQ8BAf8E
# BAMCBsAwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBKBgNV
# HSAEQzBBMDUGDCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRwczovL3Nl
# Y3RpZ28uY29tL0NQUzAIBgZngQwBBAIwSgYDVR0fBEMwQTA/oD2gO4Y5aHR0cDov
# L2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYu
# Y3JsMHoGCCsGAQUFBwEBBG4wbDBFBggrBgEFBQcwAoY5aHR0cDovL2NydC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3J0MCMGCCsG
# AQUFBzABhhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOC
# AYEAAoE+pIZyUSH5ZakuPVKK4eWbzEsTRJOEjbIu6r7vmzXXLpJx4FyGmcqnFZoa
# 1dzx3JrUCrdG5b//LfAxOGy9Ph9JtrYChJaVHrusDh9NgYwiGDOhyyJ2zRy3+kdq
# hwtUlLCdNjFjakTSE+hkC9F5ty1uxOoQ2ZkfI5WM4WXA3ZHcNHB4V42zi7Jk3ktE
# nkSdViVxM6rduXW0jmmiu71ZpBFZDh7Kdens+PQXPgMqvzodgQJEkxaION5XRCoB
# xAwWwiMm2thPDuZTzWp/gUFzi7izCmEt4pE3Kf0MOt3ccgwn4Kl2FIcQaV55nkjv
# 1gODcHcD9+ZVjYZoyKTVWb4VqMQy/j8Q3aaYd/jOQ66Fhk3NWbg2tYl5jhQCuIsE
# 55Vg4N0DUbEWvXJxtxQQaVR5xzhEI+BjJKzh3TQ026JxHhr2fuJ0mV68AluFr9qs
# hgwS5SpN5FFtaSEnAwqZv3IS+mlG50rK7W3qXbWwi4hmpylUfygtYLEdLQukNEX1
# jiOKMIIGFDCCA/ygAwIBAgIQeiOu2lNplg+RyD5c9MfjPzANBgkqhkiG9w0BAQwF
# ADBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYD
# VQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MB4XDTIx
# MDMyMjAwMDAwMFoXDTM2MDMyMTIzNTk1OVowVTELMAkGA1UEBhMCR0IxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGlt
# ZSBTdGFtcGluZyBDQSBSMzYwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIB
# gQDNmNhDQatugivs9jN+JjTkiYzT7yISgFQ+7yavjA6Bg+OiIjPm/N/t3nC7wYUr
# UlY3mFyI32t2o6Ft3EtxJXCc5MmZQZ8AxCbh5c6WzeJDB9qkQVa46xiYEpc81KnB
# kAWgsaXnLURoYZzksHIzzCNxtIXnb9njZholGw9djnjkTdAA83abEOHQ4ujOGIaB
# hPXG2NdV8TNgFWZ9BojlAvflxNMCOwkCnzlH4oCw5+4v1nssWeN1y4+RlaOywwRM
# Ui54fr2vFsU5QPrgb6tSjvEUh1EC4M29YGy/SIYM8ZpHadmVjbi3Pl8hJiTWw9ji
# CKv31pcAaeijS9fc6R7DgyyLIGflmdQMwrNRxCulVq8ZpysiSYNi79tw5RHWZUEh
# nRfs/hsp/fwkXsynu1jcsUX+HuG8FLa2BNheUPtOcgw+vHJcJ8HnJCrcUWhdFczf
# 8O+pDiyGhVYX+bDDP3GhGS7TmKmGnbZ9N+MpEhWmbiAVPbgkqykSkzyYVr15OApZ
# YK8CAwEAAaOCAVwwggFYMB8GA1UdIwQYMBaAFPZ3at0//QET/xahbIICL9AKPRQl
# MB0GA1UdDgQWBBRfWO1MMXqiYUKNUoC6s2GXGaIymzAOBgNVHQ8BAf8EBAMCAYYw
# EgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAE
# CjAIMAYGBFUdIAAwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nUm9vdFI0Ni5jcmwwfAYIKwYB
# BQUHAQEEcDBuMEcGCCsGAQUFBzAChjtodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290UjQ2LnA3YzAjBggrBgEFBQcwAYYX
# aHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBABLXeyCt
# DjVYDJ6BHSVY/UwtZ3Svx2ImIfZVVGnGoUaGdltoX4hDskBMZx5NY5L6SCcwDMZh
# HOmbyMhyOVJDwm1yrKYqGDHWzpwVkFJ+996jKKAXyIIaUf5JVKjccev3w16mNIUl
# NTkpJEor7edVJZiRJVCAmWAaHcw9zP0hY3gj+fWp8MbOocI9Zn78xvm9XKGBp6rE
# s9sEiq/pwzvg2/KjXE2yWUQIkms6+yslCRqNXPjEnBnxuUB1fm6bPAV+Tsr/Qrd+
# mOCJemo06ldon4pJFbQd0TQVIMLv5koklInHvyaf6vATJP4DfPtKzSBPkKlOtyaF
# TAjD2Nu+di5hErEVVaMqSVbfPzd6kNXOhYm23EWm6N2s2ZHCHVhlUgHaC4ACMRCg
# XjYfQEDtYEK54dUwPJXV7icz0rgCzs9VI29DwsjVZFpO4ZIVR33LwXyPDbYFkLqY
# mgHjR3tKVkhh9qKV2WCmBuC27pIOx6TYvyqiYbntinmpOqh/QPAnhDgexKG9GX/n
# 1PggkGi9HCapZp8fRwg8RftwS21Ln61euBG0yONM6noD2XQPrFwpm3GcuqJMf0o8
# LLrFkSLRQNwxPDDkWXhW+gZswbaiie5fd/W2ygcto78XCSPfFWveUOSZ5SqK95tB
# O8aTHmEa4lpJVD7HrTEn9jb1EGvxOb1cnn0CMIIGgjCCBGqgAwIBAgIQNsKwvXwb
# Ouejs902y8l1aDANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVU
# aGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2Vy
# dGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMjEwMzIyMDAwMDAwWhcNMzgwMTE4MjM1
# OTU5WjBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4w
# LAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAiJ3YuUVnnR3d6LkmgZpUVMB8
# SQWbzFoVD9mUEES0QUCBdxSZqdTkdizICFNeINCSJS+lV1ipnW5ihkQyC0cRLWXU
# JzodqpnMRs46npiJPHrfLBOifjfhpdXJ2aHHsPHggGsCi7uE0awqKggE/LkYw3sq
# aBia67h/3awoqNvGqiFRJ+OTWYmUCO2GAXsePHi+/JUNAax3kpqstbl3vcTdOGht
# KShvZIvjwulRH87rbukNyHGWX5tNK/WABKf+Gnoi4cmisS7oSimgHUI0Wn/4elNd
# 40BFdSZ1EwpuddZ+Wr7+Dfo0lcHflm/FDDrOJ3rWqauUP8hsokDoI7D/yUVI9DAE
# /WK3Jl3C4LKwIpn1mNzMyptRwsXKrop06m7NUNHdlTDEMovXAIDGAvYynPt5lutv
# 8lZeI5w3MOlCybAZDpK3Dy1MKo+6aEtE9vtiTMzz/o2dYfdP0KWZwZIXbYsTIlg1
# YIetCpi5s14qiXOpRsKqFKqav9R1R5vj3NgevsAsvxsAnI8Oa5s2oy25qhsoBIGo
# /zi6GpxFj+mOdh35Xn91y72J4RGOJEoqzEIbW3q0b2iPuWLA911cRxgY5SJYubvj
# ay3nSMbBPPFsyl6mY4/WYucmyS9lo3l7jk27MAe145GWxK4O3m3gEFEIkv7kRmef
# DR7Oe2T1HxAnICQvr9sCAwEAAaOCARYwggESMB8GA1UdIwQYMBaAFFN5v1qqK0rP
# VIDh2JvAnfKyA2bLMB0GA1UdDgQWBBT2d2rdP/0BE/8WoWyCAi/QCj0UJTAOBgNV
# HQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEFBQcD
# CDARBgNVHSAECjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2Ny
# bC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3Jp
# dHkuY3JsMDUGCCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3Au
# dXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEADr5lQe1oRLjlocXUEYfk
# tzsljOt+2sgXke3Y8UPEooU5y39rAARaAdAxUeiX1ktLJ3+lgxtoLQhn5cFb3GF2
# SSZRX8ptQ6IvuD3wz/LNHKpQ5nX8hjsDLRhsyeIiJsms9yAWnvdYOdEMq1W61KE9
# JlBkB20XBee6JaXx4UBErc+YuoSb1SxVf7nkNtUjPfcxuFtrQdRMRi/fInV/AobE
# 8Gw/8yBMQKKaHt5eia8ybT8Y/Ffa6HAJyz9gvEOcF1VWXG8OMeM7Vy7Bs6mSIkYe
# YtddU1ux1dQLbEGur18ut97wgGwDiGinCwKPyFO7ApcmVJOtlw9FVJxw/mL1TbyB
# ns4zOgkaXFnnfzg4qbSvnrwyj1NiurMp4pmAWjR+Pb/SIduPnmFzbSN/G8reZCL4
# fvGlvPFk4Uab/JVCSmj59+/mB2Gn6G/UYOy8k60mKcmaAZsEVkhOFuoj4we8CYya
# R9vd9PGZKSinaZIkvVjbH/3nlLb0a7SBIkiRzfPfS9T+JesylbHa1LtRV9U/7m0q
# 7Ma2CQ/t392ioOssXW7oKLdOmMBl14suVFBmbzrt5V5cQPnwtd3UOTpS9oCG+ZZh
# eiIvPgkDmA8FzPsnfXW5qHELB43ET7HHFHeRPRYrMBKjkb8/IN7Po0d0hQoF4TeM
# M+zYAJzoKQnVKOLg8pZVPT8xggSSMIIEjgIBATBqMFUxCzAJBgNVBAYTAkdCMRgw
# FgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3RpZ28gUHVibGlj
# IFRpbWUgU3RhbXBpbmcgQ0EgUjM2AhEApCk7bh7d16c0CIetek63JDANBglghkgB
# ZQMEAgIFAKCCAfkwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3
# DQEJBTEPFw0yNTA1MTUwMjQyMDJaMD8GCSqGSIb3DQEJBDEyBDCDQbZAY1QLCX5U
# 0Wkngo9PZrff2HAuNSZwSkK0sxg559xSQOAW5cVeWenjfE6AduMwggF6BgsqhkiG
# 9w0BCRACDDGCAWkwggFlMIIBYTAWBBQ4yRSBEES03GY+k9R0S4FBhqm1sTCBhwQU
# xq5U5HiG8Xw9VRJIjGnDSnr5wt0wbzBbpFkwVzELMAkGA1UEBhMCR0IxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEuMCwGA1UEAxMlU2VjdGlnbyBQdWJsaWMgVGlt
# ZSBTdGFtcGluZyBSb290IFI0NgIQeiOu2lNplg+RyD5c9MfjPzCBvAQUhT1jLZOC
# gmF80JA1xJHeksFC2scwgaMwgY6kgYswgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhl
# IFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRp
# ZmljYXRpb24gQXV0aG9yaXR5AhA2wrC9fBs656Oz3TbLyXVoMA0GCSqGSIb3DQEB
# AQUABIICACXRZbJmkc+5Zw6OtkeS3H/GZb6SE4IC74bwawePav/K8z80gtOFA+g3
# RRgd/IyGQBxflgqkh8GF5dc8sYOXi9ESghGvhaGlWv0ITiwdIRt7QUzCVrvUkOaL
# Pw7pLjGISklMQuEPxqRIhVB7BJY498nr5PONEeZzLHlxZIQwdiWFef7Wz8pfZxUL
# CEq5SzDT5FeVPRJn+iwedUeuYkWD2xVvmt/V4vJNPmvSiHxVxYQXiTW2Rxk3luF+
# lSWFr5FtFqvjcs3rrxcDJxYGdJcZB8l4barwO/XffH3kzJUk0rPgMIBpioUzhYPh
# 0vH6HZYrf4Sg7sgu5Wvl3fpPEnZiRqvXFFduacXkZotJmwRTGHHs+kN9QS/+FF5x
# w4yfVMV//VycRzkZgcDBaEusyEN6ppLsmKvdyNpBw16zTBqZOainCBq/+BrCLZ/v
# IOT3fCLj6lxliF6u31OWG4u538Cejfw8bcATX7V/UY8Pn6JaIPggCpvrUr1wZHVq
# 7YTkE3bLol3SHCHI8WRl7M8lhjmvlSNBeMLK6gGEiXiOIaGVg4NYsmM7CzLemNL0
# 975DD40Od2oa7ZqMmbCmq3rd4qyGKJlxxhcqW6setSQsJDVinEceCcmjTqX2OmZ5
# 2PZtQZ/4vTdm+cSATwiCTkByZP7H/51BDDC6zoKBVAkjPqLYcFqm
# SIG # End signature block
