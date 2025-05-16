####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function New-a9Vv 
{
<#      
.SYNOPSIS
	Creates a vitual volume
.DESCRIPTION
    This cmdlet (New-Vv_WSAPI) will be deprecated in a later version of PowerShell Toolkit. Consider using the cmdlet  (New-Vv_WSAPI) instead.
	Creates a vitual volume
.EXAMPLE    
	PS:> New-a9Vv -VVName xxx -CpgName xxx -SizeMiB 1
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -Id 1010
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -Comment "This is test vv"
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -OneHost $true
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -Caching $true
.EXAMPLE                         
	PS:> New-A9Vv -VVName xxx -CpgName xxx -SizeMiB 1 -HostDIF NO_HOST_DIF
.PARAMETER VVName
	Volume Name.
.PARAMETER CpgName
	Volume CPG.
.PARAMETER SizeMiB
	Volume size.
.PARAMETER Id
	Specifies the ID of the volume. If not specified, the next available ID is chosen.
.PARAMETER Comment
	Additional informations about the volume.
.PARAMETER StaleSS
	True—Stale snapshots. If there is no space for a copyon- write operation, the snapshot can go stale but the host write proceeds without an error. 
	false—No stale snapshots. If there is no space for a copy-on-write operation, the host write fails.
.PARAMETER OneHost
	True—Indicates a volume is constrained to export to one host or one host cluster. 
	false—Indicates a volume exported to multiple hosts for use by a cluster-aware application, or when port presents VLUNs are used.
.PARAMETER ZeroDetect
	True—Indicates that the storage system scans for zeros in the incoming write data. 
	false—Indicates that the storage system does not scan for zeros in the incoming write data.
.PARAMETER System
	True— Special volume used by the system. false—Normal user volume.
.PARAMETER Caching
	This is a read-only policy and cannot be set. true—Indicates that the storage system is enabled for write caching, read caching, and read ahead for the volume. 
	false—Indicates that the storage system is disabled for write caching, read caching, and read ahead for the volume.
.PARAMETER Fsvc
	This is a read-only policy and cannot be set. true —Indicates that File Services uses this volume. false —Indicates that File Services does not use this volume.
.PARAMETER HostDIF
	Type of host-based DIF policy, 3PAR_HOST_DIF is for 3PAR host-based DIF supported, 
	STD_HOST_DIF is for Standard SCSI host-based DIF supported and NO_HOST_DIF is for Volume does not support host-based DIF.
.PARAMETER SnapCPG
	Specifies the name of the CPG from which the snapshot space will be allocated.
.PARAMETER SsSpcAllocWarningPct
	Enables a snapshot space allocation warning. A warning alert is generated when the reserved snapshot space of the volume exceeds 
	the indicated percentage of the volume size.
.PARAMETER SsSpcAllocLimitPct
	Sets a snapshot space allocation limit. The snapshot space of the volume is prevented from growing beyond the indicated percentage of the volume size.
.PARAMETER tpvv
	Create thin volume.
.PARAMETER tdvv
	Enables (true) or disables (false) TDVV creation. Defaults to false.
	With both tpvv and tdvv set to FALSE or unspecified, defaults to FPVV .
.PARAMETER Reduce
	Enables (true) or disables (false) a thinly deduplicated and compressed volume.
.PARAMETER UsrSpcAllocWarningPct
	Create fully provisionned volume.
.PARAMETER UsrSpcAllocLimitPct
	Space allocation limit.
.PARAMETER ExpirationHours
	Specifies the relative time (from the current time) that the volume expires. Value is a positive integer with a range of 1–43,800 hours (1825 days).
.PARAMETER RetentionHours
	Specifies the amount of time relative to the current time that the volume is retained. Value is a positive integer with a range of 1– 43,800 hours (1825 days).
.PARAMETER Compression   
	Enables (true) or disables (false) creating thin provisioned volumes with compression. Defaults to false (create volume without compression).
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory)]
								[String]	$VVName,
		[Parameter(Mandatory)]	[String]	$CpgName,
		[Parameter(Mandatory)]	[int]		$SizeMiB,
		[Parameter()]			[int]		$Id,
		[Parameter()]			[String]	$Comment,
		[Parameter()]			[Boolean]	$StaleSS ,
		[Parameter()]			[Boolean]	$OneHost,
		[Parameter()]			[Boolean]	$ZeroDetect,
		[Parameter()]			[Boolean]	$System ,
		[Parameter()]			[Boolean]	$Caching ,
		[Parameter()]			[Boolean]	$Fsvc ,
		[Parameter()]	[ValidateSet('3PAR_HOST_DIF','STD+HOST_DIF','NO_HOST_DIF')]
								[string]	$HostDIF ,
		[Parameter()]			[String]	$SnapCPG,
		[Parameter()]			[int]		$SsSpcAllocWarningPct ,
		[Parameter()]			[int]		$SsSpcAllocLimitPct ,
		[Parameter()]			[Boolean]	$TPVV,
		[Parameter()]			[Boolean]	$TDVV,
		[Parameter()]			[Boolean]	$Reduce,
		[Parameter()]			[int]		$UsrSpcAllocWarningPct,
		[Parameter()]			[int]		$UsrSpcAllocLimitPct,
		[Parameter()]			[int]		$ExpirationHours,
		[Parameter()]			[int]		$RetentionHours,
		[Parameter()]			[Boolean]	$Compression
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}	
	$body["name"] = "$($VVName)"
	$body["cpg"] = "$($CpgName)"
    If ($SizeMiB) 	{	$body["sizeMiB"] = $SizeMiB  }
    If ($Id) 		{	$body["id"] = $Id }
	$VvPolicies = @{}
	If ($StaleSS) 	{	$VvPolicies["staleSS"] = $true		}	
	If ($OneHost) 	{	$VvPolicies["oneHost"] = $true    	} 
	If ($ZeroDetect){	$VvPolicies["zeroDetect"] = $true   }	
	If ($System) 	{	$VvPolicies["system"] = $true    	}
	If ($Caching) 	{	$VvPolicies["caching"] = $true    	}	
	If ($Fsvc) 		{	$VvPolicies["fsvc"] = $true    		}	
	If ($HostDIF) 	
		{	if($HostDIF -eq "3PAR_HOST_DIF")	{	$VvPolicies["hostDIF"] = 1	}
			elseif($HostDIF -eq "STD_HOST_DIF")	{	$VvPolicies["hostDIF"] = 2	}
			elseif($HostDIF -eq "NO_HOST_DIF")	{	$VvPolicies["hostDIF"] = 3	}
		} 	
    If ($Comment) 	{	$body["comment"] = "$($Comment)"}
	If ($SnapCPG) 	{	$body["snapCPG"] = "$($SnapCPG)" }
	If ($SsSpcAllocWarningPct) 	{	$body["ssSpcAllocWarningPct"] = $SsSpcAllocWarningPct }
	If ($SsSpcAllocLimitPct) {	$body["ssSpcAllocLimitPct"] = $SsSpcAllocLimitPct }
    If ($TPVV) 		{	$body["tpvv"] = $true	}
	If ($TDVV) 		{	$body["tdvv"] = $true	}
	If($Reduce) 	{	$body["reduce"] = $true }
    If ($UsrSpcAllocWarningPct) {	$body["usrSpcAllocWarningPct"] = $UsrSpcAllocWarningPct }
	If ($UsrSpcAllocLimitPct) 	{	$body["usrSpcAllocLimitPct"] = $UsrSpcAllocLimitPct } 
	If ($ExpirationHours) 		{ 	$body["expirationHours"] = $ExpirationHours	}
	If ($RetentionHours) 		{	$body["retentionHours"] = $RetentionHours	}
	If ($Compression) 			{ 	$body["compression"] = $true }
	if($VvPolicies.Count -gt 0){$body["policies"] = $VvPolicies }
	$Result = $null
	# write-verbose "The call will be made to /volumes and contain the body;"
	#$body | convertto-json
    $Result = Invoke-A9API -uri '/volumes' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return Get-A9Vv -VVName $VVName
		}
	else
		{	Write-Error "Failure:  While creating Volumes: $VVName " 
			return $Result.StatusDescription
		}
}
}

Function Get-A9VvSpaceDistribution
{
<#
.SYNOPSIS
	Display volume space distribution for all and for a specific virtual volumes among CPGs.
.DESCRIPTION
	Display volume space distribution for all and for a specific virtual volumes among CPGs.
.EXAMPLE    
	Get-A9VvSpaceDistribution

	Display volume space distribution for all virtual volumes among CPGs.
.EXAMPLE    
	PS:> Get-A9VvSpaceDistribution	-VVName XYZ

	Display space distribution for a specific virtual volume or a volume set.
.PARAMETER VVName 
	Either a single virtual volume name or a volume set name (start with set: to use a 	volume set name o, for example set:vvset1). 
	If you use a volume set name, the system displays the space distribution for all volumes in that volume set.
#>
[CmdletBinding()]
Param(
	[Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [String]$VVName
)
Begin 
{	Test-A9Connection -ClientType 'API'	
}
Process 
{	$Result = $null
	$dataPS = $null			
	if($VVName)
	{	$uri = '/volumespacedistribution/'+$VVName
		$Result = Invoke-A9API -uri $uri -type 'GET' 
		if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
		}
	}
	else
	{	$Result = Invoke-A9API -uri '/volumespacedistribution' -type 'GET' 
		if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members 
		}			
	}
	If($Result.StatusCode -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return $dataPS
	}
	else
	{	Write-Error "Failure:  While Executing Get-A9VvSpaceDistribution." 
		return $Result.StatusDescription
	}
    
}
}

Function Resize-a9Vv 
{
<#
.SYNOPSIS
	Increase the size of a virtual volume.
.DESCRIPTION
	Increase the size of a virtual volume.
.EXAMPLE    
	PS:> Resize-A9Vv -VVName xxx -SizeMiB xx

	Increase the size of a virtual volume xxx to xx.
.PARAMETER VVName 
	Name of the volume to be grown.
.PARAMETER SizeMiB
    Specifies the size (in MiB) to add to the volume user space. Rounded up to the next multiple of chunklet size (256 MiB or 1,000 MiB).
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]	[String]	$VVName,
		[Parameter(Mandatory = $true)]	[int]		$SizeMiB
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$body["action"] = 3 # GROW_VOLUME 3 Increase the size of a virtual volume. refer Volume custom action enumeration
	If ($SizeMiB)	{	$body["sizeMiB"] = $SizeMiB }
    $Result = $null	
	$uri = '/volumes/'+$VVName 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return Get-Vv_WSAPI -VVName $VVName		
	}
	else
	{	Write-Error "Failure:  While Growing Volumes: $VVName " 
		return $Result.StatusDescription
	}
}
}

Function Compress-A9Vv
{
<#
.SYNOPSIS
	Tune a volume.
.DESCRIPTION
    This cmdlet (Compress-Vv_WSAPI) will be deprecated in a later version of PowerShell Toolkit. Consider using the cmdlet  (Compress-Vv_WSAPI) instead.
	Tune a volume.
.EXAMPLE    
	PS:> Compress-A9Vv -VVName xxx -TuneOperation USR_CPG -KeepVV xxx
.EXAMPLE	
	PS:> Compress-A9Vv -VVName xxx -TuneOperation USR_CPG -UserCPG xxx -KeepVV xxx
.EXAMPLE
	PS:> Compress-A9Vv -VVName xxx -TuneOperation SNP_CPG -SnapCPG xxx -KeepVV xxx
.EXAMPLE	
	PS:> Compress-A9Vv -VVName xxx -TuneOperation USR_CPG -UserCPG xxx -ConversionOperation xxx -KeepVV xxx
.EXAMPLE	
	PS:> Compress-A9Vv -VVName xxx -TuneOperation USR_CPG -UserCPG xxx -Compression $true -KeepVV xxx
.PARAMETER VVName 
	Name of the volume to be tune.
.PARAMETER TuneOperation
	Tune operation
	USR_CPG Change the user CPG of the volume.
	SNP_CPG Change the snap CPG of the volume.
.PARAMETER UserCPG
	Specifies the new user CPG to which the volume will be tuned.
.PARAMETER SnapCPG
	Specifies the snap CPG to which the volume will be tuned.
.PARAMETER ConversionOperation
	TPVV  :Convert the volume to a TPVV.
	FPVV : Convert the volume to an FPVV.
	TDVV : Convert the volume to a TDVV.
	CONVERT_TO_DECO : Convert the volume to deduplicated and compressed.
.PARAMETER KeepVV
	Name of the new volume where the original logical disks are saved.
.PARAMETER Compression
	Enables (true) or disables (false) compression. You cannot compress a fully provisioned volume.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]	[String]$VVName,
		[Parameter(Mandatory = $true)]	[string]	$TuneOperation,
		[Parameter()]					[String]	$UserCPG,
		[Parameter()]					[String]	$SnapCPG,
		[Parameter()]					[string]	$ConversionOperation,
		[Parameter(Mandatory = $true)]	[String]	$KeepVV,
		[Parameter()]					[Boolean]	$Compression
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{} 	
	$body["action"] = 6	
	If ($TuneOperation) 
		{	if($TuneOperation -eq "USR_CPG")	{	$body["tuneOperation"] = 1	}
			elseif($TuneOperation -eq "SNP_CPG"){	$body["tuneOperation"] = 2	}
			else{ 	write-error "FAILURE : -TuneOperation :- $TuneOperation is an Incorrect used USR_CPG and SNP_CPG only. "
					Return  
				}          
		}
	If ($UserCPG) 	{	$body["userCPG"] = "$($UserCPG)" }
	else	{	If ($TuneOperation -eq "USR_CPG") 	
					{	write-error "Stop Executing Compress-A9Vv, UserCPG is Required with TuneOperation 1" 
						return 
					}
			}
	If ($SnapCPG) {	$body["snapCPG"] = "$($SnapCPG)" }
	else{	If ($TuneOperation -eq "SNP_CPG") 
				{	return "Stop Executing Compress-Vv_WSAPI, SnapCPG is Required with TuneOperation 1"
				}
		}
	If ($ConversionOperation) 
		{	if($ConversionOperation -eq "TPVV")		{	$body["conversionOperation"] = 1	}
			elseif($ConversionOperation -eq "FPVV")	{	$body["conversionOperation"] = 2	}
			elseif($ConversionOperation -eq "TDVV")	{	$body["conversionOperation"] = 3	}
			elseif($ConversionOperation -eq "CONVERT_TO_DECO")	{	$body["conversionOperation"] = 4	}
			else	{	Return "FAILURE : -ConversionOperation :- $ConversionOperation is an Incorrect used TPVV,FPVV,TDVV or CONVERT_TO_DECO only. "	}          
		}
	If ($KeepVV) 		{	$body["keepVV"] = "$($KeepVV)"    }
	If ($Compression) 	{	$body["compression"] = $false    } 
    $Result = $null	
	$uri = '/volumes/'+$VVName 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			Get-Vv_WSAPI -VVName $VVName		
		}
	else
		{	Write-Error "Failure:  While Tuning Volumes: $VVName " 
			return $Result.StatusDescription
		}
}
}

# SIG # Begin signature block
# MIIsVAYJKoZIhvcNAQcCoIIsRTCCLEECAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAVtUw4BcOg
# 7eujhIzDpaATGaM5e1WmCf3C0AfNGg0B1xiS2/AYzxYnnJGxt2TVoBBXasHL4UsA
# oa4pDTzBPfl4oIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhEwghoNAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQIcqD1xj4+Vv2TEPNACHRWBJKVKKv0X5Q/99JLbj9a9INOSnnKSHuNVa
# EgvoUEJpi/BUG19tGkw9CIUAK4MlJwowDQYJKoZIhvcNAQEBBQAEggGAklImhNl4
# 59EIHoIECJHcyiSDZYH/eLCFCYXIgGaKNQhBEnas5FuAPlEbzBjGCcO4pjWPNcrJ
# xkBD8cyuRga0PUY0PzC8W0d0qZJ+hLdzXmprhjBD3Lx1YIvzVEmfEh7iju+HcUXG
# 2Kh0DcJS7x/403xkn0jLAeKD8RmfnQ4XfBnZ4JrYRort8aWOoyYxTjzlt7IiKf9h
# AQX7zGlxnG9WXlD2IKdoX2//ft7CY8rZLn1fIG1w11HR2194n/uLsfgPhYDmUbgn
# Plsh/SsY5G5KV9jrCaKhGaQTIn3ig4Tu99VCisk44jjIbD2jV2z9VlGS6+Pl/J/7
# xdiyWvKP+yHg1m1i1jraNZJiVwl3o5fh6jylZ/prc8DmE48n8o+Shu4VtMWMVNXj
# VcgLYCNp7i/pMH8+VW5HhgfT0tP2OxsgNuZLS1wCf0PtMUFKLuFji5aZN8fLshr2
# ffLBiBB6GKT2zoCNSGcKREKqwjBGvRLKjsNrZKj6+/aB2ClwKrRWXc4DoYIXWjCC
# F1YGCisGAQQBgjcDAwExghdGMIIXQgYJKoZIhvcNAQcCoIIXMzCCFy8CAQMxDzAN
# BglghkgBZQMEAgIFADCBhwYLKoZIhvcNAQkQAQSgeAR2MHQCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDCZJanmQqYDLLaVbrIgzQ6yvaTeEm6evE2QQEU1
# NVh5gyCAPA9C/6hSp3HdNB757wwCEBm68v629XE9mDKtgP5qrB0YDzIwMjUwNTE1
# MjI1NjE5WqCCEwMwgga8MIIEpKADAgECAhALrma8Wrp/lYfG+ekE4zMEMA0GCSqG
# SIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwHhcNMjQwOTI2MDAwMDAwWhcNMzUxMTI1MjM1OTU5WjBC
# MQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxIDAeBgNVBAMTF0RpZ2lD
# ZXJ0IFRpbWVzdGFtcCAyMDI0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAvmpzn/aVIauWMLpbbeZZo7Xo/ZEfGMSIO2qZ46XB/QowIEMSvgjEdEZ3v4vr
# rTHleW1JWGErrjOL0J4L0HqVR1czSzvUQ5xF7z4IQmn7dHY7yijvoQ7ujm0u6yXF
# 2v1CrzZopykD07/9fpAT4BxpT9vJoJqAsP8YuhRvflJ9YeHjes4fduksTHulntq9
# WelRWY++TFPxzZrbILRYynyEy7rS1lHQKFpXvo2GePfsMRhNf1F41nyEg5h7iOXv
# +vjX0K8RhUisfqw3TTLHj1uhS66YX2LZPxS4oaf33rp9HlfqSBePejlYeEdU740G
# KQM7SaVSH3TbBL8R6HwX9QVpGnXPlKdE4fBIn5BBFnV+KwPxRNUNK6lYk2y1WSKo
# ur4hJN0SMkoaNV8hyyADiX1xuTxKaXN12HgR+8WulU2d6zhzXomJ2PleI9V2yfmf
# XSPGYanGgxzqI+ShoOGLomMd3mJt92nm7Mheng/TBeSA2z4I78JpwGpTRHiT7yHq
# BiV2ngUIyCtd0pZ8zg3S7bk4QC4RrcnKJ3FbjyPAGogmoiZ33c1HG93Vp6lJ415E
# RcC7bFQMRbxqrMVANiav1k425zYyFMyLNyE1QulQSgDpW9rtvVcIH7WvG9sqYup9
# j8z9J1XqbBZPJ5XLln8mS8wWmdDLnBHXgYly/p1DhoQo5fkCAwEAAaOCAYswggGH
# MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSME
# GDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUn1csA3cOKBWQZqVj
# Xu5Pkh92oFswWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NB
# LmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGlu
# Z0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAPa0eH3aZW+M4hBJH2UOR9hHbm04I
# HdEoT8/T3HuBSyZeq3jSi5GXeWP7xCKhVireKCnCs+8GZl2uVYFvQe+pPTScVJeC
# ZSsMo1JCoZN2mMew/L4tpqVNbSpWO9QGFwfMEy60HofN6V51sMLMXNTLfhVqs+e8
# haupWiArSozyAmGH/6oMQAh078qRh6wvJNU6gnh5OruCP1QUAvVSu4kqVOcJVozZ
# R5RRb/zPd++PGE3qF1P3xWvYViUJLsxtvge/mzA75oBfFZSbdakHJe2BVDGIGVNV
# jOp8sNt70+kEoMF+T6tptMUNlehSR7vM+C13v9+9ZOUKzfRUAYSyyEmYtsnpltD/
# GWX8eM70ls1V6QG/ZOB6b6Yum1HvIiulqJ1Elesj5TMHq8CWT/xrW7twipXTJ5/i
# 5pkU5E16RSBAdOp12aw8IQhhA/vEbFkEiF2abhuFixUDobZaA0VhqAsMHOmaT3XT
# hZDNi5U2zHKhUs5uHHdG6BoQau75KiNbh0c+hatSF+02kULkftARjsyEpHKsF7u5
# zKRbt5oK5YGwFvgc4pEVUNytmB3BpIiowOIIuDgP5M9WArHYSAR16gc0dP2XdkME
# P5eBsX7bf/MGN4K3HP50v/01ZHo/Z5lGLvNwQ7XHBx1yomzLP8lx4Q1zZKDyHcp4
# VQJLu2kWTsKsOqQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMy
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcg
# Q0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
# JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMf
# UBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w
# 1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRk
# tFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYb
# qMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUm
# cJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP6
# 5x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzK
# QtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo
# 80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjB
# Jgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXche
# MBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd
# 4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiC
# qBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl
# /Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
# RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYT
# gAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/
# a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37
# xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmL
# NriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0
# YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJ
# RyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIF
# jTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3y
# ithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1If
# xp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDV
# ySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiO
# DCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQ
# jdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/
# CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCi
# EhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADM
# fRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QY
# uKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXK
# chYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t
# 9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6ch
# nfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0
# MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqG
# SIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi
# +IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n0
# 96wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ8
# 7PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9v
# ytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQt
# J37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDhjCCA4ICAQEwdzBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# AhALrma8Wrp/lYfG+ekE4zMEMA0GCWCGSAFlAwQCAgUAoIHhMBoGCSqGSIb3DQEJ
# AzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjUwNTE1MjI1NjE5WjAr
# BgsqhkiG9w0BCRACDDEcMBowGDAWBBTb04XuYtvSPnvk9nFIUIck1YZbRTA3Bgsq
# hkiG9w0BCRACLzEoMCYwJDAiBCB2dp+o8mMvH0MLOiMwrtZWdf7Xc9sF1mW5BZOY
# Q4+a2zA/BgkqhkiG9w0BCQQxMgQw9gVFpX4THDHCPlSeGRbQoi3tyNv5xMYC17GY
# Og+NC+HQI2tWoh9sbOsPDriqG9nOMA0GCSqGSIb3DQEBAQUABIICAED3hzGOAErJ
# kui/OWX7Vfgzqq90nNOqO1vipS49ta8+z3eq/Xwx0Nr++b0TQ6CGO4czm4o6qVGn
# RfK/904PYjUDrBxlC6FNdbNKDPkO/+6hClT2guXzinJa2dllpBgtNZFEyE1R2ftt
# zbsbXtiNLVvowBPvgfQC85LR7vg5eXiKupXKKRs909dmQPzM/plrYxc9aGQoGtf4
# hpa+qW391RZTs+KsmT2dEOu+wmuVpzNIO8qv2LfMhbh9HWGK0e+VUBeP+xFYO6na
# +4mY8KMY0yCMxPzrBYFQYI5gVl02Nh7mlGV4LBd0QqmBd1q22wnvylD+wb+Adcmk
# snVoqUYte/izkiWWm37HQ6Rbr7z2SmO0Ngo1B7BbFOQyl4jGdzesWDztG0eikVs4
# T8ydc21OE5PsT0CdHK+1+PGfEqfYWATU06WZqeYjHwLuR4KwLOyQN/Ti80R+SoSH
# aSORJst4Yjh9U0BqqPjMYBsbgtW4ouzHi0JScwKoTUcqvaOCYzMUzuBOyhAeM3qc
# ldJExCMUxTc9pZU1pbM/us6Kj/iZmNZ5V55KayfpdXwh3BJLQzK1SqVQYOcoYJR9
# 6a85vq5j5J71A2USLdvDrundsEbmVXl+D8WiQod0VHrVIC1kaQAS7fSVK1/fhElL
# byci4SSsVccfNP+U/fin9btXZ9OABvPf
# SIG # End signature block
