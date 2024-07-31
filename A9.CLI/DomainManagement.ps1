####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Get-A9Domain
{
<#
.SYNOPSIS
	Show information about domains in the system.
.DESCRIPTION
	Displays a list of domains in a system.
.PARAMETER D
	Specifies that detailed information is displayed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$D
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " showdomain "
	if($D)	{	$Cmd += " -d " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1) 
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -2  
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim() 
					$temp1 = $s -replace 'CreationTime','Date,Time,Zone'
					$s = $temp1		
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item  $tempFile 	
		}
	else{	return  $Result }
	if($Result.count -gt 1)	{	return  " Success : Executing Get-Domain" }
	else	{	return  $Result } 
}
}

Function Get-A9DomainSet
{
<#
.SYNOPSIS
	show domain set information
.DESCRIPTION
	Lists the domain sets defined on the system and their members.
.EXAMPLE
	PS:> Get-A9DomainSet -D
.PARAMETER D
	Show a more detailed listing of each set.
.PARAMETER DomainShow 
	domain sets that contain the supplied domains or patterns
.PARAMETER SetOrDomainName
	specify either Domain Set name or domain name (member of Domain set)
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$D,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Domain, 
		[Parameter(ValueFromPipeline=$true)]	[String]	$SetOrDomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " showdomainset "
	if($D)		{	$Cmd += " -d " }
	if($Domain)	{	$Cmd += " -domain " } 
	if($SetOrDomainName)	{	$Cmd += " $SetOrDomainName " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)	{	return  $Result }
	else	{	return  $Result }
}
}

Function Move-A9Domain
{
<#
.SYNOPSIS
	Move objects from one domain to another, or into/out of domains
.DESCRIPTION
	Moves objects from one domain to another.
.PARAMETER ObjName
	Specifies the name of the object to be moved.
.PARAMETER DomainName
	Specifies the domain or domain set to which the specified object is moved. 
	The domain set name must start with "set:". To remove an object from any domain, specify the string "-unset" for the domain name or domain set specifier.
.PARAMETER Vv
	Specifies that the object is a virtual volume.
.PARAMETER Cpg
	Specifies that the object is a common provisioning group (CPG).
.PARAMETER Host
	Specifies that the object is a host.
.PARAMETER F
	Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$vv,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Cpg,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Host,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$F,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$ObjName,
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]		[String]	$DomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " movetodomain "
	if($Vv) 	{	$Cmd += " -vv " }
	if($Cpg)	{	$Cmd += " -cpg " }
	if($Host)	{	$Cmd += " -host " }
	if($F)		{	$Cmd += " -f " }
	if($ObjName){	$Cmd += " $ObjName " }
	if($DomainName){$Cmd += " $DomainName " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result -match "Id")
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -1  
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim()
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item  $tempFile 	
		}
	if($Result -match "Id")	{	return  " Success : Executing Move-Domain"}
	else					{	return "FAILURE : While Executing Move-Domain `n $Result"	}
}
}

Function New-A9Domain
{
<#
.SYNOPSIS
	Create a domain.
.DESCRIPTION
	The New-Domain command creates system domains.
.EXAMPLE
	Domain_name xxx
.EXAMPLE
	PS:> New-A9Domain -Domain_name xxx -Comment "Hello"
.PARAMETER Domain_name
	Specifies the name of the domain you are creating. The domain name can be no more than 31 characters. The name "all" is reserved.
.PARAMETER Comment
	Specify any comments or additional information for the domain. The comment can be up to 511 characters long. Unprintable characters are not allowed. 
	The comment must be placed inside quotation marks if it contains spaces.
.PARAMETER Vvretentiontimemax
	Specify the maximum value that can be set for the retention time of a volume in this domain. <time> is a positive integer value and in the range of 0 - 43,800 hours (1825 days).
	Time can be specified in days or hours providing either the 'd' or 'D' for day and 'h' or 'H' for hours following the entered time value.
	To disable setting the volume retention time in the domain, enter 0 for <time>.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Vvretentiontimemax,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Domain_name
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
} 
Process
{	$Cmd = " createdomain "
	if($Comment)			{	$Cmd += " -comment " + '" ' + $Comment +' "'	 }
	if($Vvretentiontimemax) {	$Cmd += " -vvretentiontimemax $Vvretentiontimemax " } 
	if($Domain_name) 		{	$Cmd += " $Domain_name " }
	else {	return "Domain Required.." }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
	if ([string]::IsNullOrEmpty($Result))	{   Return $Result = "Domain : $Domain_name Created Successfully."	}
	else									{	Return $Result	}
}
}

Function New-A9DomainSet
{
<#
.SYNOPSIS
	Create a domain set or add domains to an existing set
.DESCRIPTION
	The command defines a new set of domains and provides the option of assigning one or more existing domains to that set. 
	The command also allows the addition of domains to an existing set by use of the -add option.
.EXAMPLE
	New-A9DomainSet -SetName xyz 
.PARAMETER SetName
	Specifies the name of the domain set to create or add to, using up to 27 characters in length.
.PARAMETER Add
	Specifies that the domains listed should be added to an existing set. At least one domain must be specified.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SetName,
		[Parameter(Mandatory=$false , ValueFromPipeline=$true)]	[switch]	$Add,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " createdomainset " 
	if($Add) 		{	$Cmd += " -add " }
	if($Comment)	{	$Cmd += " -comment " + '" ' + $Comment +' "' }
	if($SetName)	{	$Cmd += " $SetName " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Remove-A9Domain
{
<#
.SYNOPSIS
	Remove a domain
.DESCRIPTION
	The command removes an existing domain from the system.
.EXAMPLE
	Remove-A9Domain -DomainName xyz
.PARAMETER DomainName
	Specifies the domain that is removed. If the -pat option is specified the DomainName will be treated as a glob-style pattern, and multiple domains will be considered.
.PARAMETER Pat
	Specifies that names will be treated as glob-style patterns and that all domains matching the specified pattern are removed.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]					[switch]	$Pat,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$DomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " removedomain -f "
	if($Pat)		{	$Cmd += " -pat " }
	if($DomainName)	{	$Cmd += " $DomainName " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Remove-A9DomainSet
{
<#
.SYNOPSIS
	Remove a domain set or remove domains from an existing set
.DESCRIPTION
	The command removes a domain set or removes domains from an existing set.
.EXAMPLE
	PS:> Remove-A9DomainSet -SetName xyz
.PARAMETER SetName
	Specifies the name of the domain set. If the -pat option is specified the setname will be treated as a glob-style pattern, and multiple domain sets will be considered.
.PARAMETER Domain
	Optional list of domain names that are members of the set. If no <Domain>s are specified, the domain set is removed, otherwise the specified <Domain>s are removed from the domain set. 
	If the -pat option is specified the domain will be treated as a glob-style pattern, and multiple domains will be considered.
.PARAMETER F
	Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
.PARAMETER Pat
	Specifies that both the set name and domains will be treated as glob-style patterns.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]					[switch]	$F,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$Pat,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SetName,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Domain
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " removedomainset "
	if($F) 		{	$Cmd += " -f "	}
	if($Pat)	{	$Cmd += " -pat " }
	if($SetName){	$Cmd += " $SetName " }
	if($Domain)	{	$Cmd += " $Domain " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Set-A9Domain
{
<#
.SYNOPSIS
	Change current domain CLI environment parameter.
.DESCRIPTION
	The command changes the current domain CLI environment parameter.
.EXAMPLE
	PS:> Set-A9Domain
.EXAMPLE
	PS:> Set-A9Domain -Domain "XXX"
.PARAMETER Domain
	Name of the domain to be set as the working domain for the current CLI session. If the <domain> parameter is not present or is equal to -unset then the working domain is set to no current domain.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Domain
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " changedomain "
	if($Domain)	{	$Cmd += " $Domain " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if([String]::IsNullOrEmpty($Domain))
		{	$Result = "Working domain is unset to current domain."
			Return $Result
		}
	else{	if([String]::IsNullOrEmpty($Result))
				{	$Result = "Domain : $Domain to be set as the working domain for the current CLI session."
					Return $Result
				}
			else{	Return $Result}	
		}
}
}

Function Update-A9Domain
{
<#
.SYNOPSIS
	Set parameters for a domain.
.DESCRIPTION
	The command sets the parameters and modifies the properties of a domain.
.EXAMPLE
	Update-A9Domain -DomainName xyz
.PARAMETER DomainName
	Indicates the name of the domain.(Existing Domain Name)
.PARAMETER NewName
	Changes the name of the domain.
.PARAMETER Comment
	Specifies comments or additional information for the domain. The comment can be up to 511 characters long and must be enclosed in quotation
	marks. Unprintable characters are not allowed within the <comment> specifier.
.PARAMETER Vvretentiontimemax
	Specifies the maximum value that can be set for the retention time of a volume in this domain. <time> is a positive integer value and in the
	range of 0 - 43,800 hours (1825 days). Time can be specified in days or hours providing either the 'd' or 'D' for day and 'h' or 'H' for hours
	following the entered time value. To remove the maximum volume retention time for the domain, enter '-vvretentiontimemax ""'. As a result, the maximum 
	volume retention time for the system is used instead. To disable setting the volume retention time in the domain, enter 0 for <time>.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$NewName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Vvretentiontimemax,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$DomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " setdomain "
	if($NewName)	{	$Cmd += " -name $NewName " }
	if($Comment){	$Cmd += " -comment " + '" ' + $Comment +' "'}
	if($Vvretentiontimemax)	{	$Cmd += " -vvretentiontimemax $Vvretentiontimemax "	}
	if($DomainName)	{	$Cmd += " $DomainName "}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Update-A9DomainSet
{
<#
.SYNOPSIS
	set parameters for a domain set
.DESCRIPTION
	The command sets the parameters and modifies the properties of a domain set.
.EXAMPLE
	Update-A9DomainSet -DomainSetName xyz
.PARAMETER DomainSetName
	Specifies the name of the domain set to modify.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
.PARAMETER NewName
	Specifies a new name for the domain set, using up to 27 characters in length.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]	[String]	$NewName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$DomainSetName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " setdomainset "
	if($Comment)	{	$Cmd += " -comment " + '" ' + $Comment +' "' }
	if($NewName)	{  	$Cmd += " -name $NewName " }
	if($DomainSetName){	$Cmd += " $DomainSetName " }
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
} 

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDW+3egHMIO
# kN05YKlWgqeNsU9zDVqgN/B2J4L8kCct2onJKxW5rZW58FxvL3ajHPUQcTPZ/tqR
# nSRKv2In8T2AoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQP1Pc+lH0fhTDANBAo1sbTU+uBl5QBNaQvKkmMznrA+SXOYzDNrEA4WP
# egk+K8kUfmwN7yQGYDQez6ZmCgtVD60wDQYJKoZIhvcNAQEBBQAEggGACPI3ERXe
# u7bnvzWm78A52LLYeO6pO8FfDabZlZYYwhv20tVWvZY6N73H7+btpr66J6KL7JXq
# AgcnDuA5rMWXqz/bmmysqN2hpMH/3qzfyQ4i8OnUoXd0eZK1EbkuWtTyElAXm0eF
# ha3QhlfNz7SQJOWDubXiCh05wMTKO4rzrUhomq6qZJ/8g1IvZlgmlEqg4UyuQCDU
# Yb9VINjWz6YJKupvwBwRnCcORXKEAw4A7LchX3+otHqjzgLRChrKsig0EnBCDMZQ
# 7X1+NHOFxsFa6JJ8lH9BTeVim+nvdryufq8FNqC29k0Mc31vAUvhAHrTEtka2hnM
# 1pi7XfjggUmnvqnanc2HfmUjjRTRayYdHopCd4GSgjRdpQRlcVehVxNdphzVWNck
# lJTlcP0GVCi94sz+FeDDnqFUgeNbli0gM1j5/cMBRTEga3+NyURpPu9MlzpRvmyG
# CxE7XbNXnCXcwS3FWIPCp5PkD3tsqQh7z1wneBfxOKqja6CaYyxzm/k7oYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDBZI+CH9TTaJiaK+2uZTTd1ZJA9ZBULwcmnOSHH
# 8NAqA9nnfS221t0d6l9iVUNkDaMCEQCt+kKunOD96sDJS+41FS6mGA8yMDI0MDcz
# MTE5MjAwM1qgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
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
# MjAwM1owKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMFHOjzKlZO/KiSa49V52xgHG3jSG
# uzXXhGFLpVFscyECgLfGqARmxyz6NzLHFUQJ0zANBgkqhkiG9w0BAQEFAASCAgBF
# I0IecOteiyuqv1PUW1TkcarlQbrlRxhDb5baajU5y6lP4IgnBjUy7YqLW4pFz/+g
# OzVtgWh7VMGt6ZrOIuUjucqQ90pHaI2ukyCAKUe+I5LjJEngP//gZtXgTc4Avak2
# YFDbfpn0iHgQy7/KZhMj0PYhrCV0v9GCrwbS5MUrpaq8rOXjSYLK8biGjWipEoyq
# 2NIVLrF2EyrbrtdWddS/x4h6ZJM7wIHZcxEoam1st8Rc8+VUQra79khsvcqEqQEk
# SLzzDUzQJGKf9f8TdfJ8K43zqyEQTYWDaDk7tFxC/YlwZEnTInuSLn43luSEqhp/
# 0sAau1k3CxgW1V+nN7XrjhZDDgyR8aFtdQNVZpg17GW2aFDxQrKiKb23Au4sK/7V
# vZmp+qPBdwTVgM54L9qi+QFUge5oWhfnd4zrKBkSItrscGOBN3LjQZSom2TZSwUE
# Lmin5V5lDq5ip1DjQdkWlOTjt8NAVtjDLXTs0UamvjWB/dN4JmtX5Kc2CHAUe06e
# Qo0PdbwEubVnVNhXOdus6C9Ty/Yp86kUemZcpvvKSgvp1Seu687rJp2VQ21IwIru
# yTz9lJ547IjBEqELpda6p+aG5Wcz3WrV73JseSb9YQDNhrBZ04TciMVWqYPdiSRS
# mkEDCgYEpHF5nShSjyjw9cQrP3Ncs4xtpn8hh2rfcg==
# SIG # End signature block
