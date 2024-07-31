﻿####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Join-A9Federation
{
<#
.SYNOPSIS  
	The Join-Federation command makes the StoreServ system a member of the Federation identified by the specified name and UUID.
.DESCRIPTION
	The Join-Federation command makes the StoreServ system a member of the Federation identified by the specified name and UUID.
.EXAMPLE
	PS:> Join-A9Federation -FedName test -UUID 12345
.EXAMPLE
	PS:> Join-A9Federation -Comment hello -UUID 12345
.EXAMPLE
	PS:> Join-A9Federation -Comment hello -UUID 12345 -FedName test
.EXAMPLE
	PS:> Join-A9Federation -Setkv 10 -UUID 12345 -FedName test
.EXAMPLE
	PS:> Join-A9Federation -Setkvifnotset 20  -UUID 12345 -FedName test
.PARAMETER Force
	If the StoreServ system is already a member of a Federation, the option forcefully removes the system from the current Federation and makes it a
	member of the new Federation identified by the specified name and UUID.
.PARAMETER Comment
	Specifies any additional textual information.
.PARAMETER Setkv
	Sets or resets key/value pairs on the federation. <key> is a string of alphanumeric characters. <value> is a string of characters other than "=", "," or ".".
.PARAMETER Setkvifnotset
	Sets key/value pairs on the federation if not already set. A key/value pair is not reset on a federation if it already
	exists.  If a key already exists, it is not treated as an error and the value is left as it is.
.PARAMETER UUID
	Specifies the UUID of the Federation to be joined.
.PARAMETER FedName
	Specifies the name of the Federation to be joined.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[Switch]	$Force ,
		[Parameter()]	[String]	$UUID ,
		[Parameter()]	[String]	$FedName ,
		[Parameter()]	[String]	$Comment ,
		[Parameter()]	[String]	$Setkv ,
		[Parameter()]	[String]	$Setkvifnotset 
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	if($FedName )
		{	if($UUID )
				{	$Cmd = "joinfed "
					if($Force)	{	$Cmd+= " -force "	}
					if($Comment){	$Cmd+= " -comment $Comment"	}
					if($Setkv)	{	$Cmd+= " -setkv $Setkv"		}
					if($Setkvifnotset)	{	$Cmd+= " -setkvifnotset $Setkvifnotset"	}			
					$Cmd += " $UUID $FedName "
					$Result = Invoke-A9CLICommand -cmds  $Cmd
					return  "$Result"	
				}
			else{	return "FAILURE : UUID Not specified."	}
		}
	else	{	return "FAILURE : Federation Name Not specified"	}
}
}

Function New-A9Federation
{
<#
.SYNOPSIS
	The New-Federation command generates a UUID for the named Federation and makes the StoreServ system a member of that Federation.
.DESCRIPTION
	The New-Federation command generates a UUID for the named Federation and makes the StoreServ system a member of that Federation.
.EXAMPLE
	PS:> New-A9Federation -Fedname XYZ
.EXAMPLE
	PS:> New-A9Federation –CommentString XYZ -Fedname XYZ
.EXAMPLE
	PS:> New-A9Federation -Setkv TETS -Fedname XYZ
.EXAMPLE
	PS:> New-A9Federation -Setkvifnotset TETS -Fedname XYZ
.PARAMETER comment
	Specifies any additional textual information.
.PARAMETER Setkv 
	Sets or resets key/value pairs on the federation. <key> is a string of alphanumeric characters. <value> is a string of characters other than "=", "," or ".".
.PARAMETER Setkvifnotset
	Sets key/value pairs on the federation if not already set. A key/value pair is not reset on a federation if it already exists.
.PARAMETER Fedname
	Specifies the name of the Federation to be created. The name must be between 1 and 31 characters in length
	and must contain only letters, digits, or punctuation characters '_', '-', or '.'
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$Fedname ,
		[Parameter()]	[String]	$Comment ,
		[Parameter()]	[String]	$Setkv ,
		[Parameter()]	[String]	$Setkvifnotset
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd = "createfed"
	if($Comment)	{	$cmd+= " -comment $Comment" }
	if($Setkv)		{	$cmd+= " -setkv $Setkv"		}
	if($Setkvifnotset){	$cmd+= " -setkvifnotset $Setkvifnotset"	}
	$cmd += " $Fedname"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	return  "$Result"				
}
}

Function Set-A9Federation
{
<#
.SYNOPSIS
	The command modifies name, comment, or key/value attributes of the Federation of which the StoreServ system is member.
.DESCRIPTION 
	The command modifies name, comment, or key/value attributes of the Federation of which the StoreServ system is member.
.EXAMPLE
	PS:> Set-A9Federation -FedName test
.EXAMPLE
	PS:> Set-A9Federation -Comment hello
.EXAMPLE
	PS:> Set-A9Federation -ClrAllKeys
.EXAMPLE
	PS:> Set-A9Federation -Setkv 1
.PARAMETER Comment
	Specifies any additional textual information.
.PARAMETER Setkv
	Sets or resets key/value pairs on the federation. <key> is a string of alphanumeric characters. <value> is a string of characters other than "=", "," or ".".
.PARAMETER Setkvifnotset
	Sets key/value pairs on the federation if not already set. A key/value pair is not reset on a federation if it already
	exists.  If a key already exists, it is not treated as an error and the value is left as it is.
.PARAMETER ClrallKeys
	Clears all key/value pairs on the federation.
.PARAMETER ClrKey
	Clears key/value pairs, regardless of the value. If a specified key does not exist, this is not treated as an error.
.PARAMETER ClrKV
	Clears key/value pairs only if the value matches the given key. Mismatches or keys that do not exist are not treated as errors.
.PARAMETER IfKV
	Checks whether given key/value pairs exist. If not, any subsequent key/value options on the command line will be ignored for the federation.
.PARAMETER FedName
	Specifies the new name of the Federation.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$FedName ,
		[Parameter()]	[String]	$Comment ,
		[Parameter()]	[String]	$Setkv ,	
		[Parameter()]	[String]	$Setkvifnotset ,
		[Parameter()]	[switch]	$ClrAllKeys ,
		[Parameter()]	[String]	$ClrKey ,
		[Parameter()]	[String]	$ClrKV ,
		[Parameter()]	[String]	$IfKV 
)		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = "setfed"	
	if($FedName)	{	$cmd += " -name $FedName "		}
	if($Comment)	{	$cmd += " -comment $Comment "	}
	if($Setkv)		{	$cmd += " -setkv $Setkv "		}
	if($Setkvifnotset){	$cmd += " -setkvifnotset $Setkvifnotset "}
	if($ClrAllKeys)	{	$cmd += "  -clrallkeys "		}
	if($ClrKey)		{	$cmd += " -clrkey $ClrKey "		}
	if($ClrKV)		{	$cmd += " -clrkv $ClrKV "		}
	if($IfKV)		{	$cmd += " -ifkv $IfKV "			}
	$Result = Invoke-A9CLICommand -cmds  $cmd
	if([string]::IsNullOrEmpty($Result))	{	return "Success : Set-Federation command executed successfully."}
	else									{	return $Result	}	
}
}

Function Remove-A9Federation
{
<#
.SYNOPSIS
	The command removes the StoreServ system from Federation membership.
.DESCRIPTION 
	The command removes the StoreServ system from Federation membership.
.EXAMPLE	
	PS:> Remove-A9Federation	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = " removefed -f"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	return  "$Result"				
}
}

Function Show-A9Federation
{
<#
.SYNOPSIS 
	The Show Federation command displays the name, UUID, and comment of the Federation of which the StoreServ system is member.
.DESCRIPTION 
	The Show Federation command displays the name, UUID, and comment
	of the Federation of which the StoreServ system is member.
.EXAMPLE	
	PS:> Show-A9Federation
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$cmd = " showfed"
	$Result = Invoke-A9CLICommand -cmds  $cmd
	write-verbose "  Executing Show-Federation Command.--> "
	$tempFile = [IO.Path]::GetTempFileName()
	$LastItem = $Result.Count  
	#Write-Host " Result Count =" $Result.Count
	foreach ($s in  $Result[0..$LastItem] )
		{	$s= [regex]::Replace($s,"^ ","")			
			$s= [regex]::Replace($s," +",",")	
			$s= [regex]::Replace($s,"-","")
			$s= $s.Trim() 	
			Add-Content -Path $tempFile -Value $s
		}
	Import-Csv $tempFile 
	Remove-Item  $tempFile
	if($Result -match "Name")	{	return  " Success : Executing Show-Federation "	}
	else						{	return $Result		}		
}
} 

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABECeeUpUCj1x
# a9y3uLVboLLMP42puPN8haUB7VaQHTUvk6b72U/5NoLuGR8H/+//YR9BOTLDl6ra
# gwmhM9yz95S0oIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhgwghoUAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQNHLnbEeePyroycU+vhixt0PUaAwrIXw/VPtD368h1+J8GUNf4qxdNUk
# HicOz8x+AC0hXJYdssUFqD2g4iwzLHAwDQYJKoZIhvcNAQEBBQAEggGAka4hxiqg
# SSJSURUsXxx5q17IqaYCABUBOGjyphgqBvXwGT7KLUC+f48WPItRhcYNtD24ExzL
# DIz+1gPwxnjk3ZuWa7Ls6TmKspYiHZVorpF/TlUeXEE6Ja474JwtQfRUrHjKyUEg
# VNa+eRJaIPQig6Mkq74C1y0ZxoahbLCKYdwJ92wF5gq5aiGz3+8Adm/7L1yYQqql
# yMQ/UxfW5uaAfJAldrhIOOrCWKjHAWmaOry1ejHhmlx6Y7so7D/q1/GK9QPRHn7T
# vNsLEPUB6u45rSsLYYzGekWTH+w8eOOwr0SxVsrwvnbqRad38pgkOKpt+Uab3aj/
# +kHhdAprm3idV2sas2O+6LqGYqBv7faC5/isxb60SXXLi4+6G/W3bsy33HSYd0Lk
# 6+YGrkfrJ9jtHjkznJ2X7YduQDAAlWiXkx8TxT89AVstEm7oArWJOqSFY/0l68lv
# lBay2+kLDNPdSBlEtgzEWl2QemXp3t+xvpIoVRNjdQ1WLfzLvR+1EVS+oYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDBz0A2p0aameGwvuJpAu3ATHIaUmVdQvo7zFDQE
# 9IU0cRQmMv8Bfq8VdtjZuBczwpECEQCiaQz6SabALHFpDBqIN/7vGA8yMDI0MDcz
# MTE5MjY0NlqgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVow
# SDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQD
# ExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVY
# wamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isg
# HMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFe
# xAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gp
# OWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28
# mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkH
# NwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58
# ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXH
# g2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W
# 1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK
# 8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn
# 783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+K
# PGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1I
# jrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP
# 2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ
# 5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON
# 1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S
# 88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbU
# uXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145
# WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6
# F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso
# /zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG
# 70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEM
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zC
# pyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf
# 1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x
# 4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEio
# ZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7ax
# xLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZ
# OjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJ
# l2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz
# 2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH
# 4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb
# 5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ
# 9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0g
# ADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs
# 7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq
# 3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/
# Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9
# /HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWoj
# ayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEB
# MHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgIFAKCB4TAaBgkq
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTE5
# MjY0NlowKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMC8vFrdzFN6f7HK+KKUi9+HgAvv0
# thazNeigHjE6PDeA6IJf6xtAzul6x4MViM71+TANBgkqhkiG9w0BAQEFAASCAgCY
# tqHAOrEfI2rqfbT57bQKlU+zeinoa2ZCQOFUp6zzZ2q/swhnjM4glDOY6nKegP8d
# TDFYUfF1RT0UzSRG1Gq+zkS4reFCvpfWYcxjZ9v9cbrmiUruW9NY8vO4ZZJjaluD
# 6C0LhYvnbbBgxLiXDrb+6WPS97Z+2TjSjitBZZNsTMv3HWZ+cjhF6iWaapM1oJxT
# bzdkixZXEK6+N9JvyLPJ9qrBUVZ2ykp0+anj6HToio0GRJ2RMle9tcyTt0uQIGW6
# W+f09khq5WAr4FIQeyp2m63kWjqiYVHenNAStJ9KF/3cfRdmx9GKLZhMf5utB0Yp
# U66JtrPLUISAZfS+N+RIY3MM5saQlHL9peXTW1+6jhPm5BMGQrlzqqkOsiimqQWr
# EovWnOsKamXeyp73rQZ6e5hlQBvmDO8tAZYZpixvJ4m/kutawIqyhVA89xGBZwrz
# 7MqrBqNj/mtyGklbLjT4iZi4T5WVsZQhP0hwTBU4e0DCGoeuU22XYicguBl/OCyp
# I7nsbjvnboi5RJr6sEcFW3wImPy2x6ecRFiF+Vy3HcPjQMUcPupcI585U9Y+P2so
# YT5YvmmgSAW7g18E8ZHHH554zGSzFLNcOL5BCweIqWddoNbs8fDF+TJ66xHfeel/
# 2XvEOAvH50Rs2j9kIEyYl4bK9j1ToV9nH5h7iiZ0EA==
# SIG # End signature block
