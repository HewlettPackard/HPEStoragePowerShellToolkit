# PerformancePolicy.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSPerformancePolicy {
<#
.SYNOPSIS
  Create performance policy.
.DESCRIPTION
  Create performance policy.
.PARAMETER name
  Name of the Performance Policy.
.PARAMETER description
  Description of a performance policy.
.PARAMETER block_size
  Block Size in bytes to be used by the volumes created with this specific performance policy. Supported block sizes 
  are 4096 bytes (4 KB), 8192 bytes (8 KB), 16384 bytes(16 KB), and 32768 bytes (32 KB). Block size of a performance 
  policy cannot be changed once the performance policy is created.
.PARAMETER compress
  Flag denoting if data in the associated volume should be compressed.
.PARAMETER cache
  Flag denoting if data in the associated volume should be cached.
.PARAMETER cache_policy
  Specifies how data of associated volume should be cached. Supports two policies, 'normal' and 'aggressive'. 'normal' 
  policy caches data but skips in certain conditions such as sequential I/O. 'aggressive' policy will accelerate caching 
  of all data belonging to this volume, regardless of sequentiality.
.PARAMETER space_policy
  Specifies the state of the volume upon space constraint violation such as volume limit violation or volumes above 
  their volume reserve, if the pool free space is exhausted. Supports two policies, 'offline' and 'non_writable'.
.PARAMETER app_category
  Specifies the application category of the associated volume.
.PARAMETER dedupe_enabled
  Specifies if dedupe is enabled for volumes created with this performance policy.
.EXAMPLE
  C:\> New-NSPerformancePolicy -name MyTestPolicy1

  name          id                                         app_category block_size description cache_policy compress dedupe_enabled predefined space_policy
  ----          --                                         ------------ ---------- ----------- ------------ -------- -------------- ---------- ------------
  MyTestPolicy1 0328eada7f8dd99d3b000000000000000000000061 Unassigned   4096                   normal       True     False          False      offline

  This command will create a new minimal performance policy from the array. Most settings such as block size will use the default 4K.
.EXAMPLE
  C:\> New-NSPerformancePolicy -name MyTestPolicy2 -description "My Test Perf Policy" -block_size 8192 -compress True

  name          id                                         app_category block_size description         cache_policy compress dedupe_enabled predefined space_policy
  ----          --                                         ------------ ---------- -----------         ------------ -------- -------------- ---------- ------------
  MyTestPolicy2 0328eada7f8dd99d3b000000000000000000000062 Unassigned   8192       My Test Perf Policy normal       True     False          False      offline

  This command will create a common performance policy from the array.
#>
[CmdletBinding()]
param(
    [Parameter(ParameterSetName='allButId', Mandatory = $True)]
    [AllowEmptyString()]
    [string] $name,

    [Parameter(ParameterSetName='allButId')]
    [AllowEmptyString()]
    [string] $description,

    [long] $block_size,

    [bool] $compress,

    [bool] $cache,

    [ValidateSet( 'normal', 'no_write', 'aggressive_read_no_write', 'disabled', 'aggressive')]
    [string] $cache_policy,

    [ValidateSet( 'offline', 'login_only', 'non_writable', 'read_only', 'invalid')]
    [string] $space_policy,

    [string] $app_category,

    [bool] $dedupe_enabled
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
            $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
            if($var -and ($PSBoundParameters.ContainsKey($key)))
            {
                $RequestData.Add("$($var.name)", ($var.value))
            }
        }
        $Params = @{
            ObjectName = 'PerformancePolicy'
            APIPath = 'performance_policies'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSPerformancePolicy {
<#
.SYNOPSIS
  List all the performance policies.
.DESCRIPTION
  List all the performance policies.
.PARAMETER id
  Unique Identifier for the Performance Policy.
.PARAMETER name
  Name of the Performance Policy.
.PARAMETER full_name
  Fully qualified name of the Performance Policy.
.PARAMETER search_name
  Name of the Performance Policy used for object search.
.PARAMETER description
  Description of a performance policy.
.PARAMETER block_size
  Block Size in bytes to be used by the volumes created with this specific performance policy. Supported block sizes are 4096 bytes 
  (4 KB), 8192 bytes (8 KB), 16384 bytes(16 KB), and 32768 bytes (32 KB). Block size of a performance policy cannot be changed 
  once the performance policy is created.
.PARAMETER compress
  Flag denoting if data in the associated volume should be compressed.
.PARAMETER cache
  Flag denoting if data in the associated volume should be cached.
.PARAMETER cache_policy
  Specifies how data of associated volume should be cached. Supports two policies, 'normal' and 'aggressive'. 'normal' policy 
  caches data but skips in certain conditions such as sequential I/O. 'aggressive' policy will accelerate caching of all data 
  belonging to this volume, regardless of sequentiality.
.PARAMETER space_policy
  Specifies the state of the volume upon space constraint violation such as volume limit violation or volumes above their volume 
  reserve, if the pool free space is exhausted. Supports two policies, 'offline' and 'non_writable'.
.PARAMETER app_category
  Specifies the application category of the associated volume.
.PARAMETER dedupe_enabled
  Specifies if dedupe is enabled for volumes created with this performance policy.
.PARAMETER deprecated
  Specifies if this performance policy is deprecated.
.PARAMETER predefined
  Specifies if this performance policy is predefined (read-only).
.EXAMPLE
  C:\> Get-NSPerformancePolicy

  name                     id                                         app_category block_size description                                                                 cache_policy
  ----                     --                                         ------------ ---------- -----------                                                                 ------------
  default                  0328eada7f8dd99d3b000000000000000000000001 Other        4096       Default performance policy                                                  normal
  Exchange 2003 data store 0328eada7f8dd99d3b000000000000000000000002 Exchange     4096       Performance policy suitable for use with Microsoft Exchange 2003 data store normal
  Exchange 2007 data store 0328eada7f8dd99d3b000000000000000000000003 Exchange     8192       Performance policy suitable for use with Microsoft Exchange 2007 data store normal
  Exchange log             0328eada7f8dd99d3b000000000000000000000004 Exchange     16384      Performance policy suitable for use with Microsoft Exchange log             normal

  This command will retrieve the initiator groups from the array.
.EXAMPLE
  C:\> PS:> Get-NSPerformancePolicy -name 'SQL Server'

  name       id                                         app_category block_size description                                                   cache_policy compress dedupe_enabled pre

  ----       --                                         ------------ ---------- -----------                                                   ------------ -------- -------------- ---
  SQL Server 0328eada7f8dd99d3b000000000000000000000005 SQL Server   8192       Performance policy suitable for use with Microsoft SQL Server normal       True     False          Tru

  This command will retrieve a specific Performance Policy from the array by name.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{2})([0-9a-f]{16})([0-9a-f]{16})([0-9a-f]{8})')]
    [string]  $id,

    [Parameter(ParameterSetName='nonId')]
    [string]  $name,

    [Parameter(ParameterSetName='nonId')]
    [string]  $full_name,

    [Parameter(ParameterSetName='nonId')]
    [string]  $search_name,

    [Parameter(ParameterSetName='nonId')]
    [string]  $description,

    [Parameter(ParameterSetName='nonId')]
    [long]  $block_size,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $compress,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $cache,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'normal', 'no_write', 'aggressive_read_no_write', 'disabled', 'aggressive')]
    [string]  $cache_policy,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'offline', 'login_only', 'non_writable', 'read_only', 'invalid')]
    [string]  $space_policy,

    [Parameter(ParameterSetName='nonId')]
    [string]  $app_category,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $dedupe_enabled,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $deprecated,

    [Parameter(ParameterSetName='nonId')]
    [bool]  $predefined
  )
  process
  {
    $API = 'performance_policies'
    $Param = @{
      ObjectName = 'PerformancePolicy'
      APIPath = 'performance_policies'
    }
    if ($id)
    {
        # Get a single object for given Id.
        $Param.Id = $id
        $ResponseObject = Get-NimbleStorageAPIObject @Param
        return $ResponseObject
    }
    else
    {
        # Get list of objects matching the given filter.
        $Param.Filter = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
            if ($key.ToLower() -ne 'fields')
            {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {
                    $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Set-NSPerformancePolicy {
<#
.SYNOPSIS
  Update attributes of a performance policy. Block size of a performance policy cannot be changed once the perfomance policy is created.
.DESCRIPTION
  Update attributes of a performance policy. Block size of a performance policy cannot be changed once the perfomance policy is created.
.PARAMETER id
  Unique Identifier for the Performance Policy.
.PARAMETER name
  Name of the Performance Policy.
.PARAMETER description
  Description of a performance policy.
.PARAMETER compress
  Flag denoting if data in the associated volume should be compressed.
.PARAMETER cache
  Flag denoting if data in the associated volume should be cached.
.PARAMETER cache_policy
  Specifies how data of associated volume should be cached. Supports two policies, 'normal' and 'aggressive'. 'normal' policy 
  caches data but skips in certain conditions such as sequential I/O. 'aggressive' policy will accelerate caching of all data 
  belonging to this volume, regardless of sequentiality.
.PARAMETER space_policy
  Specifies the state of the volume upon space constraint violation such as volume limit violation or volumes above their 
  volume reserve, if the pool free space is exhausted. Supports two policies, 'offline' and 'non_writable'.
.PARAMETER app_category
  Specifies the application category of the associated volume.
.PARAMETER dedupe_enabled
  Specifies if dedupe is enabled for volumes created with this performance policy.
.EXAMPLE
  C:\> Set-NSPerformancePolicy -id 0328eada7f8dd99d3b000000000000000000000061 -description "My New Description"

  name          id                                         app_category block_size description        cache_policy compress dedupe_enabled predefined space_policy
  ----          --                                         ------------ ---------- -----------        ------------ -------- -------------- ---------- ------------
  MyTestPolicy1 0328eada7f8dd99d3b000000000000000000000061 Unassigned   4096       My New Description normal       True     False          False      offline

  This command will Modify a setting of the specified Performance Policy.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [string] $name,

    [string] $description,

    [bool] $compress,

    [boolean] $cache,

    [ValidateSet( 'normal', 'no_write', 'aggressive_read_no_write', 'disabled', 'aggressive')]
    [string] $cache_policy,

    [ValidateSet( 'offline', 'login_only', 'non_writable', 'read_only', 'invalid')]
    [string] $space_policy,

    [string] $app_category,

    [boolean] $dedupe_enabled
  )
process {   # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        { if ($key.ToLower() -ne 'id')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {   $RequestData.Add("$($var.name)", ($var.value))
                }
            }
        }
        $Params = @{  ObjectName = 'PerformancePolicy'
                      APIPath = 'performance_policies'
                      Id = $id
                      Properties = $RequestData
                  }
        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSPerformancePolicy {
<#
.SYNOPSIS
  Delete a performance policy.
.DESCRIPTION
  Delete a performance policy.
.PARAMETER id
  Unique Identifier for the Performance Policy.
.EXAMPLE
  C:\> Remove-NSPerformancePolicy -id 0328eada7f8dd99d3b000000000000000000000061

  This command will remove the specified Performance Policy.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [string]$id
    )
process { $Params = @{  ObjectName = 'PerformancePolicy'
                        APIPath = 'performance_policies'
                        Id = $id
                    }
          Remove-NimbleStorageAPIObject @Params
        }
}

# SIG # Begin signature block
# MIIt4wYJKoZIhvcNAQcCoIIt1DCCLdACAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABECBwiFIDYPV
# wjh8kwJso6xmn9WfsLcHhdhFMvnT1WPBm8ULdj5aZlmdmw/JVTtVW4Ga2sJgiaBJ
# 7uWiQoj4zEZ1oIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQMiuZwXYxRBISQNz7oLEiKxAURHaWtWikT0Nk8ZYsS4+i1pQkyKvga1e
# yzG/6x98Runjv4iBOVarGOBnUrd5UBswDQYJKoZIhvcNAQEBBQAEggGAnBnMAb63
# wyKYnFWaQx5P46mA7ZNBQhTQk9V88w9kwjxLq2NzdIXa2altoc8RGhBUAJCY0HF5
# qngsuRVrk7/DiL+q+emXLKpU3o/lwZcpl6FeQJEjbU4N4f8wLKmybBymq8pD2oPw
# 9eMc2DtlHQBlyCKGgRKti3i1YjQ+QnTXAaJ2+cQTllzYqP1oxkpTvfid5VL3f3UD
# 7IyNASdnT2j0G79xwspHM9xkQdmTN0scoyPY9Vo3/izzyWnv8Nrq38wSFJISiBHX
# 783d4Oh4J/6I6J6eNc/lK32wSqXciVLdQ14Ueq8UqUHSoKrcYcJRTVdqNM1+4xM6
# DvWDzV0r7mAyaUnwC/u146Cy914mAvCf9QHvQWoJ24wF5PeRbTm0yrXpbh/z0c/f
# P8gA4a0kWxFY84f01hQHYp4S8rkKMXOpFIYglH32+Wvb7yXuvQSRA+inzOw+ypHW
# p3ae3VdEb/Vt/3b1SnOnzRLZZnk+IC/bN0rdmh0v6DQrd45LxFM/lTQloYIY6TCC
# GOUGCisGAQQBgjcDAwExghjVMIIY0QYJKoZIhvcNAQcCoIIYwjCCGL4CAQMxDzAN
# BglghkgBZQMEAgIFADCCAQgGCyqGSIb3DQEJEAEEoIH4BIH1MIHyAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMG3qZCABy0tEfFAtxRvtucZEJ03E95ln
# pDHWDIR4fUzl7U5DIyrqtpK2HcUJ7dr+nQIVAKqyhN6MQPkojva2WBRJnNDaLhYJ
# GA8yMDI1MDUxNTIyMzMwNVqgdqR0MHIxCzAJBgNVBAYTAkdCMRcwFQYDVQQIEw5X
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
# DQEJBTEPFw0yNTA1MTUyMjMzMDVaMD8GCSqGSIb3DQEJBDEyBDDAx89j51xi+6GJ
# 5Ftt4y8DGgDNWL1no9yTjVsHcTbsY1/fu/mwnoLddrfyp5WdNRswggF6BgsqhkiG
# 9w0BCRACDDGCAWkwggFlMIIBYTAWBBQ4yRSBEES03GY+k9R0S4FBhqm1sTCBhwQU
# xq5U5HiG8Xw9VRJIjGnDSnr5wt0wbzBbpFkwVzELMAkGA1UEBhMCR0IxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEuMCwGA1UEAxMlU2VjdGlnbyBQdWJsaWMgVGlt
# ZSBTdGFtcGluZyBSb290IFI0NgIQeiOu2lNplg+RyD5c9MfjPzCBvAQUhT1jLZOC
# gmF80JA1xJHeksFC2scwgaMwgY6kgYswgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhl
# IFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRp
# ZmljYXRpb24gQXV0aG9yaXR5AhA2wrC9fBs656Oz3TbLyXVoMA0GCSqGSIb3DQEB
# AQUABIICAKZNKreh2qgNVmCEYeJAIAKrQappWEqHbcvuaoBZvLpdKszLqwBv/t6a
# /AqET/TcBqQocmCVpHVd1zqN86Y6HwcWlX5urrfU2npAL8EpESm2ObzOYW6ZZS5m
# Up/WPZn8Z+vQPf2ZobosjwDz2pZR+W7vDGueiCB6GhXsXEC90y/nYfEOLsQZvF4d
# iznA0i5O6k7EZSKeWw14pnPceMYchmvUuKMUCo1/TIGjbduRy3/8HOjSucSw9E94
# 0vukGbcUxdpC3fvDLAakm88hRjGkjETMY/0+OTCy10nqs9NcDBGPaZ+yI5wVl9b/
# 68L6j6wtQKg4CxeUMNajUxvVbN1SpLnKZzqyUEyuUSWIlAwLhZxVrMc9M3SCr2/7
# erNaLHmvc9awBHMWsfJ+0Dyf5IwH17Xnohf84GI89BulAPDpefPNmxCCOYAYuSKB
# KTX9VXyWBg127rad3FDl7DsMqST5Yfg9pbEpB7mia50IomYExlN2NUV8hLs/mEHB
# LXQLLn9Z8y9UCA1UZO9cBfgxFYEg0RjDXhz1syN85sIEjU7VdIw2FEJjUmaJ+oTZ
# +KYpohyuhV9H2feAAMQWDkRcxHE83kogtlTX9RC56qn5Yn30iNTzh/cFN8E43W7b
# zq0yGBQ0000rsUxbp0OOcCa+bFl5T8VtKxk8JKkA8DEFpWpeZcXD
# SIG # End signature block
