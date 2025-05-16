####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Find-A9Cage
{
<#
.SYNOPSIS
	The command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs.
.DESCRIPTION
	The command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs. 
.PARAMETER Time 
	Specifies the number of seconds, from 0 through 255 seconds, to blink the LED. 
	If the argument is not specified, the option defaults to 60 seconds.
.PARAMETER CageName 
	Specifies the drive cage name as shown in the Name column of Get-Cage command output.
.PARAMETER ModuleName
	Indicates the module name to locate. Accepted values are
	pcm|iom|drive. The iom specifier is not supported for node enclosures.
.PARAMETER 3ParModuleName
	Indicates the module name to locate. Accepted values are
	pcm|iom|drive. The iom specifier is not supported for node enclosures.
.PARAMETER ModuleNumber
	Indicates the module number to locate. The cage and module number can be found
	by issuing showcage -d <cage_name>.
.PARAMETER Mag 
	Indicates the drive magazine by number.
	• For DC1 drive cages, accepted values are 0 through 4.
	• For DC2 and DC4 drive cages, accepted values are 0 through 9.
	• For DC3 drive cages, accepted values are 0 through 15.
.PARAMETER PortName  
	Indicates the port specifiers. Accepted values are A0|B0|A1|B1|A2|B2|A3|B3. 
	If a port is specified, the port LED will oscillate between green and off.
.PARAMETER 3ParOnly
	This forces the parameter set to use the 3Par only options
.EXAMPLE
	PS:> Find-A9Cage -Time 30 -CageName cage0	
	
	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds.
.EXAMPLE  
	PS:> Find-A9Cage -Time 30 -CageName cage0 -mag 3	

	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds,Indicates the drive magazine by number 3.
.EXAMPLE  
	PS:> Find-A9Cage -Time 30 -CageName cage0 -PortName demo1

	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds, If a port is specified, the port LED will oscillate between green and off.
.EXAMPLE  	
	PS:> Find-A9Cage -CageName cage1 -Mag 2	

	This example causes the Fibre Channel LEDs on the drive CageName cage1 to blink, Indicates the drive magazine by number 2.	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='A9')]
param(	[Parameter()]
		[ValidateRange(0,255)]	[String]	$Time,
		[Parameter(Mandatory)]	[String]	$CageName,
		[Parameter(ParameterSetName='A9')]	
		[ValidateSet('pcm','iom','drive')]
								[String]	$ModuleName,
		[Parameter(ParameterSetName='3Par')]	
		[ValidateSet('enclosure','fan','powersupply','battery','iocard','disk','magazine')]
								[String]	$3ParModuleName,
		[Parameter()]			[String]	$ModuleNumber,
		[Parameter(ParameterSetName='3Par')]
		[ValidateRange(0,23)]	[String]	$Mag,
		[Parameter(ParameterSetName='3Par')]
		[ValidateSet('A0','B0','A1','B1','A2','B2','A3','B3')]
								[String]	$PortName,
		[Parameter(ParameterSetName='3Par')]
								[switch]	$3ParOnly
)		
Begin	
	{   Test-A9Connection -ClientType 'SshClient'
		if ( 	( ($ArrayType.ToLower() -ne "3par") -and ($PSCmdlet.ParameterSetName -eq '3Par') ) -or
					( ($ArrayType.ToLower() -eq "3par") -and ($PSCmdlet.ParameterSetName -ne '3Par') ) )
				{	write-warning "You selected a parameter set that doesnt match the type of Array you have"
					write-warning "If the Arraytype is 3Par you must select the -3ParOnly, If it is not you must not select any of the parameters that are 3par specific."
					return
				}
	}
Process
	{	$cmd= "locatecage "	
		if ($time)	{	$cmd+=" -t $time"	}
		$cmd+=" $CageName"
		if ($ModuleName)	{	$cmd +=" $ModuleName"  	}		
		if ($ModuleNumber)	{	$cmd +=" $ModuleNumber"	}
		if ($ArrayType.ToLower() -eq "3par")
			{	if ($Mag)		{	$cmd +=" $Mag"		}
				if ($PortName)	{	$cmd +=" $PortName"	}				
			}	
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd	
	}
end
	{	if($Result)	{	write-error "FAILURE : While Executing Find-Cage `n "	} 	
		else		{	write-host "Success : Find-Cage Command Executed Successfully" -ForegroundColor Green }
		return$Result
	}
}

Function Get-A9Cage
{
<#
.SYNOPSIS
	The command displays information about drive cages.
.DESCRIPTION
	The command displays information about drive cages.    
.PARAMETER ErrorInformation  
	Displays error information.
.PARAMETER CachedData
	Specifies to use cached information. This option displays information faster because the cage does
	not need to be probed, however, some information might not be up-to-date without that probe.
.PARAMETER State
	Specifies that detailed state information is displayed. If the State is Normal, DetailedState is also Normal. 
	If the State is non-Normal, DetailedState displays a list of conditions in the cage which map to cage 
	alerts and status in the -all option.
.PARAMETER SFP  
	Specifies information about the SFP(s) attached to a cage. Currently, additional SFP information
	can only be displayed for DC2 and DC4 cages.
.PARAMETER I	
	Specifies that inventory information about the drive cage is displayed. If this option is not used,
	then only summary information about the drive cages is displayed.
.PARAMETER DDm
	Specifies the SFP DDM information. This option can only be used with the
	-sfp option and cannot be used with the -d option.
.PARAMETER SVC
	Displays inventory information with HPE serial number, spare part number, and so on. it is supported only on HPE 3PAR Storage 7000 Storagesystems and  HPE 3PAR 8000 series systems"
.PARAMETER All
	Displays all the components status information.
.PARAMETER Connector
	Displays the internal and external enclosure IO module SAS connector status information, e.g., disabled, link speed, status.
.PARAMETER Cooling
	Displays the cooling status information, e.g., speed, cooling LEDs, status.
.PARAMETER Enclosure
	Displays the enclosure status information, e.g., enclosure LEDs, status.
.PARAMETER Env
	Displays the temperature, current, and voltage sensors information.
.PARAMETER Expander
	Displays the expander status information, e.g., address, status.
.PARAMETER IOM
	Displays the IO module status information, e.g., IOM LEDs, status.
.PARAMETER Mag
	Displays the magazine (drive bay) status information, e.g., power, bypass, drive bay LEDs, status.
.PARAMETER Power
	Displays the power status information, e.g., power LEDs, status.
.PARAMETER Sep
	Displays the SEP status information, e.g., firmware version/status, address, status.
.PARAMETER Temperature
	Displays the temperature sensor status information, e.g., temperature, threshold, status.
.PARAMETER CageName  
	Specifies a drive cage name for which information is displayed. This specifier can be repeated to display information for multiple cages
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	PS:> Get-A9Cage
	
	This examples display information for a single system’s drive cages.
.EXAMPLE  
	PS:> Get-A9Cage -I -CageName cage2
	
	Specifies that inventory information about the drive cage is displayed. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter(parametersetname='3Par')]			[Switch]	$ErrorInformation,
		[Parameter(parametersetname='3Par')]			[Switch]	$CachedData,
		[Parameter(parametersetname='3Par')]			[Switch]	$State,
		[Parameter()]									[Switch]	$DDM,
		[Parameter()]									[Switch]	$SFP,
		[Parameter()]									[Switch]	$I,
		[Parameter()]									[Switch]	$SVC,
		[Parameter(ParameterSetName='A9All')]			[Switch]	$All,
		[Parameter(ParameterSetName='A9Connector')]		[Switch]	$Connector,
		[Parameter(ParameterSetName='A9Cool')]			[Switch]	$Cooling,
		[Parameter(ParameterSetName='A9Enclosure')]		[Switch]	$Enclosure,
		[Parameter(ParameterSetName='A9End')]			[Switch]	$Env,
		[Parameter(ParameterSetName='A9Expander')]		[Switch]	$Expander,
		[Parameter(ParameterSetName='A9Iom')]			[Switch]	$IOM,
		[Parameter(ParameterSetName='A9Mag')]			[Switch]	$Mag,
		[Parameter(ParameterSetName='A9Power')]			[Switch]	$Power,
		[Parameter(ParameterSetName='A9Sep')]			[Switch]	$Sep,
		[Parameter(ParameterSetName='A9Temp')]			[Switch]	$Temperature,
		[Parameter(mandatory=$false)]					[String]	$CageName,
		[Parameter(ParameterSetName='3Par')]			[switch]	$3ParOnly,
		[Parameter()]									[Switch]	$ShowRaw
	)		
Begin	
	{   Test-A9Connection -ClientType 'SshClient' 
		if ( 	( ($ArrayType.ToLower() -ne "3par") -and ($PSCmdlet.ParameterSetName -eq '3Par') ) -or
						( ($ArrayType.ToLower() -eq "3par") -and ($PSCmdlet.ParameterSetName -ne '3Par') ) )
					{	write-warning "You selected a parameter set that doesnt match the type of Array you have"
						write-warning "If the Arraytype is 3Par you must select the -3ParOnly, If it is not you must not select any of the parameters that are 3par specific."
						return
					}
	}
Process
	{	$cmd= "showcage "
		if($ErrorInformation )	
			{	if ( ($arraytype.ToLower() -eq '3Par') ) 	
					{ 	$cmd +=" -e "}
				else{	$cmd +=" -error " }
			}
		if($CachedData 			-and ($arraytype.ToLower() -eq '3Par') ) 	{ 	$cmd +=" -c "}
		if($State 				-and ($arraytype.ToLower() -eq '3Par') ) 	{ 	$cmd +=" -state "}
		if($SFP)		{ 	$cmd +=" -sfp " }
		if($DDM)		{ 	$cmd +=" -ddm " }
		if($SVC)		{ 	$cmd +=" -svc -i"}
		elseif($I) 		{ 	$cmd +=" -i " }
		if($All)		{ 	$cmd +=" -all " }
		if($Connector)	{ 	$cmd +=" -con " }
		if($Cool)		{ 	$cmd +=" -cooling " }
		if($Enclosure)	{	$cmd +=" -enc " }
		if($Env)		{ 	$cmd +=" -env " }
		if($Expander)	{ 	$cmd +=" -exp " }
		if($IOM)		{ 	$cmd +=" -iom " }
		if($Mag)		{ 	$cmd +=" -mag " }
		if($Power)		{ 	$cmd +=" -power " }
		if($sep)		{ 	$cmd +=" -sep " }
		if($temperature){ 	$cmd +=" -temp " }
		$cmd+=" $CageName "
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds $cmd
	}
end
	{	if($ShowRaw -or $i -or $svc -or $all) { return $Result }
		if($Result.Count -gt 1)
				{	if ( ($PSBoundParameters.count -eq 0) -or $Cooling)
						{ 	$HeaderLine = 0
							$StartIndex=1
							$EndIndex=$Result.count-1
						}
					elseif ($Connector -or $IOM -or $mag -or $Power -or $Sep -or $Enclosure)
						{	$HeaderLine = 0
							$StartIndex=1
							$EndIndex=$Result.count-3
						}
					elseif ($Env -or $Temperature -or $sfp)
						{	$HeaderLine = 1
							$StartIndex=2
							$EndIndex=$Result.count-3
						}
				}
		else{	write-warning "FAILURE : While Executing Get-Cage"
				Return $Result
			}	
		$tempFile = [IO.Path]::GetTempFileName()	
		$ResultHeader = ((($Result[$HeaderLine].split(' ')).trim()).trim('-') | where-object { $_ -ne '' } ) -join ','
		Add-Content -Path $tempFile -Value $ResultHeader
		foreach ($s in $Result[$StartIndex..$EndIndex])
			{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
				Add-Content -Path $tempFile -Value $s
			}	
		$returndata = Import-Csv $tempFile
		Remove-Item $tempFile
		return $returndata
	}
}

Function Set-A9Cage
{
<#
.SYNOPSIS
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.DESCRIPTION
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.PARAMETER Position  
	Sets a description for the position of the cage in the cabinet, where <position> is a description to be assigned by service personnel (for example, left-top)
.PARAMETER PSModel	  
	Sets the model of a cage power supply, where <model> is a model name to be assigned to the power supply by service personnel. get information regarding PSModel try using  [ Get-Cage -option d ]
.PARAMETER CageName	 
	Indicates the name of the drive cage that is the object of the setcage operation.	
.EXAMPLE
	PS:> Set-A9Cage -Position left -CageName cage1

	This example demonstrates how to assign cage1 a position description of Side Left.
.EXAMPLE
	PS:> Set-A9Cage -Position left -PSModel 1 -CageName cage1

	This  example demonstrates how to assign model names to the power supplies in cage1. Inthisexample, cage1 hastwopowersupplies(0 and 1).
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]				[String]	$Position,
		[Parameter()]				[String]	$PSModel,
		[Parameter(Mandatory)]		[String]	$CageName
)	
Begin	
	{   Test-A9Connection -ClientType 'SshClient' 
	}
Process
	{	$cmd= "setcage "
		if ($Position )	{	$cmd+=" position $Position "}		
		if ($PSModel)	{	$cmd+=" ps $PSModel "	}	
		if ($CageName)	{	$cmd +="$CageName "	}
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd
	}
end
	{	if($Result)	{	write-warning "FAILURE : While Executing Set-Cage:" 	} 	
		else 		{	write-host "Success : Executing Set-Cage Command" -ForegroundColor Green }
		return$Result
	}
}


# SIG # Begin signature block
# MIIt4gYJKoZIhvcNAQcCoIIt0zCCLc8CAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAKluOoL4/w
# RApi0j4JdojCngEFtKECXdmKm0h/4L959V5vG3Zgxepl3hdaHPg/BbcYPamiDjtW
# nXzs7/t36wqNoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQGgUD/wvqcMudf+VXV+YZ6jyqUJvrjxsrczW3+eePWZVvZ91ej4PwLGZ
# Imft2iC5BCEiUayoCQFsuyVgmUsy26gwDQYJKoZIhvcNAQEBBQAEggGAX5qfmUfA
# uOkVj9eI8qDOHX+FwHfz9MTUCPzoY1+/RNQVlGhdTNd4E6BfklKelGudevofiBGB
# BQPVwztWzarpg1cjXMJg0qfTtaA0xxzEnFFXP4rktswRmccG/qkJ5sW0BhS7EXiI
# IgozjvLTc4fDJwE43YomBUIL2NR+y9gSUWMss/8HArE1CXymCp3IoP/NoKKqplPw
# eZeYa6Wz3nA0tdifAOpQ5gjnY6sjxksRjvTcOXoVrg/xpvhil4pN+aRxanxF2aRp
# 3+leO4yC7lpK+eOz0WNJm51niqPJmGxwflmPEFK4/A3SoMQHEYrUg4MWzj5vucC0
# A7He56C2baKcbiTCMzZPCxOElRpAYpidBt2UmPBBjvrtHKedbVWLn4UxHI9k1NEq
# 3/ifL6m+Nk9o+fZXrKT9/1yJQ4dyXHP+LtDZS7OqzWjhS4KS8ngMxKDqXCTpNpr1
# QkRNQWpGVrEOWd3hLibrgrck75brSDyTdhpFvsG2r7Kb/Aw73XcazGWAoYIY6DCC
# GOQGCisGAQQBgjcDAwExghjUMIIY0AYJKoZIhvcNAQcCoIIYwTCCGL0CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQcGCyqGSIb3DQEJEAEEoIH3BIH0MIHxAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMLxQ161kmF7c32euQCCQcbi+AVV/iY34
# jURJwEpveO6hw+xJOHGTEc/4tRMoQMwGhAIUWrcW6qDnqH4uqBFPDx7Dc0ffhVAY
# DzIwMjUwNTE1MDIxNDAyWqB2pHQwcjELMAkGA1UEBhMCR0IxFzAVBgNVBAgTDldl
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
# AQkFMQ8XDTI1MDUxNTAyMTQwMlowPwYJKoZIhvcNAQkEMTIEMJSv+L8WwKYZ7B5C
# Jswl/7aijhr+BcQbSYd4KBkXidVp2r5c5tZnhrRoX66z8o0WnDCCAXoGCyqGSIb3
# DQEJEAIMMYIBaTCCAWUwggFhMBYEFDjJFIEQRLTcZj6T1HRLgUGGqbWxMIGHBBTG
# rlTkeIbxfD1VEkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1l
# IFN0YW1waW5nIFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KC
# YXzQkDXEkd6SwULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEB
# BQAEggIAOLDCeLVUac0p80GliK/AXJuwDNmVEpJniECXk3X+NcAvD4x4MoQZJIq2
# bIQQUCy2bE9Ha9yYeV+0LbKt4A9gjE4U1zgVbynSUI8ONgxEOXZ/bijS25R9OFcI
# R/kfx3hOY9sQkovZCwm9+BoTgyTo4y+lLlysAY7CAgzywj+28i9Ygsh5cYy0PhK4
# 5luQwEjILbg994RBNliRFC7SteG31EI2a+KbIWMj2EYmbow6ece/1WqpA8kQfGfL
# qwFuzDIRoBfYCpU7ImrxgxSsTfTyE8hBwpZQDaTcVLqQDrI66aQ3zt2sRPpvfyQm
# 4ke6oVUNvzKEABzGHF27oB579KqonOhRD+LQ0SvfLEYiCjiN6yITjuB+1DrreqFA
# SXjqVe3W9mFIxqAs9M3g41Nb4IrxIzphIbzdt21WUUVl6wCHt3NwQyTrKGEKrTX6
# dxk6MoaKIWW7F/5s3TnzyqrXlQf42/akBgSomf+i4AITYZyxwAwAUeGpjvIc2LXJ
# 4qIzpRj+ZGK+m/n+0HXoP6TmfrI45tVKaYqi/TqkhEhUcCLBUU1jrRJlnXGr2p3Q
# C2HaWasOX6i8BE8tv5Hs0hasK0tMxCFFOqQF3hg6At72wMqEMOgvb8AtXQZg9s+e
# njNiWnd7/kVA1C4lAUh+esC5FMxodStuCqqOVVnzcfMnMtB/zbU=
# SIG # End signature block
