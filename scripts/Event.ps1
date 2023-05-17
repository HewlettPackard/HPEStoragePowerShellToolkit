# Event.ps1: This is an autogenerated file. Part of Nimble Group Management SDK. All edits to this file will be lost!
#
# © Copyright 2017 Hewlett Packard Enterprise Development LP.


function Get-NSEvent {
  # .ExternalHelp ../NimPSSDK.psm1-help.xml
  [CmdletBinding(DefaultParameterSetName='id')]
  param(
    [Parameter(ParameterSetName='id')]
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet('id','type','name','scope','target','target_type','timestamp','category','severity','summary','activity','alarm_id','params','tenant_id')]
    [string[]]$fields,

    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{2})([0-9a-f]{16})([0-9a-f]{16})([0-9a-f]{8})')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$type,

    [Parameter(ParameterSetName='nonId')]
    [string]$name,

    [Parameter(ParameterSetName='nonId')]
    [string]$scope,

    [Parameter(ParameterSetName='nonId')]
    [string]$target,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'anon', 'controller', 'test', 'protection_set', 'pool', 'nic', 'shelf', 'volume', 'disk', 'fan', 'iscsi', 'nvram', 'power_supply', 'partner', 'array', 'service', 'temperature', 'ntb', 'fc', 'initiator_group', 'raid', 'group')]
    [string]$target_type,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$timestamp,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'replication', 'volume', 'security', 'test', 'cloud_console', 'configuration', 'service', 'update', 'array_upgrade', 'unknown', 'hardware')]
    [string]$category,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'critical', 'warning', 'info', 'notice')]
    [string]$severity,

    [Parameter(ParameterSetName='nonId')]
    [string]$summary,

    [Parameter(ParameterSetName='nonId')]
    [string]$activity,

    [Parameter(ParameterSetName='nonId')]
    [string]$alarm_id,

    [Parameter(ParameterSetName='nonId')]
    [Object[]]$params,

    [Parameter(ParameterSetName='nonId')]
    [string]$tenant_id

  )

  process
  {
    $API = 'events'
    $Param = @{
      ObjectName = 'Event'
      APIPath = 'events'
    }

    if ($fields)
    {
        $Param.Fields = $fields
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





# SIG # Begin signature block
# MIIh0QYJKoZIhvcNAQcCoIIhwjCCIb4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDNFSHIIQXjEXmP
# CuJaHvioGLeU+7cnFNZRTVQn61bNNqCCEKwwggUqMIIEEqADAgECAhEAvNU51iSY
# 0pIemSd4RhoKzjANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJHQjEbMBkGA1UE
# CBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3RpZ28gUlNBIENvZGUgU2ln
# bmluZyBDQTAeFw0yMTA1MjgwMDAwMDBaFw0yMjA1MjgyMzU5NTlaMIGQMQswCQYD
# VQQGEwJVUzETMBEGA1UECAwKQ2FsaWZvcm5pYTESMBAGA1UEBwwJUGFsbyBBbHRv
# MSswKQYDVQQKDCJIZXdsZXR0IFBhY2thcmQgRW50ZXJwcmlzZSBDb21wYW55MSsw
# KQYDVQQDDCJIZXdsZXR0IFBhY2thcmQgRW50ZXJwcmlzZSBDb21wYW55MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyo5MH8CMlPL4CA+tkPZO/A7zvMst
# 2DmdLgU7GJoMsXv8PYnYJzxb/ILnmaCIlCCimzZ7YmtuS1F0kMQLedMu0CyY92SW
# 0CCqJRMICtIE/ahCIPAHcN3dHjc/CNAezTGvMoqh3oSOGW4KbDk8buzIyVp6O4E8
# Q4SBKjo3Ly+yzBT63Oak+C7GTu7en0r50BPel7STQEaAPLEQbBJCafvCyZwHzF1l
# NzPWcnSITN7x9FIJ5H1quYnMhxWaDXY0GXZLW9UoNG0u87Emz3gBCxNrQf6y89qu
# wEF4IGDFL0l/PmHN70HXCOHWJhydRjAm7JER80NaBSqKWuDX+BPE63pQ/QIDAQAB
# o4IBkDCCAYwwHwYDVR0jBBgwFoAUDuE6qFM6MdWKvsG7rWcaA4WtNA4wHQYDVR0O
# BBYEFBLk4qaHNH/WpWNTozuiAfRQ3keeMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMB
# Af8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBEGCWCGSAGG+EIBAQQEAwIEEDBK
# BgNVHSAEQzBBMDUGDCsGAQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczov
# L3NlY3RpZ28uY29tL0NQUzAIBgZngQwBBAEwQwYDVR0fBDwwOjA4oDagNIYyaHR0
# cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUlNBQ29kZVNpZ25pbmdDQS5jcmww
# cwYIKwYBBQUHAQEEZzBlMD4GCCsGAQUFBzAChjJodHRwOi8vY3J0LnNlY3RpZ28u
# Y29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNydDAjBggrBgEFBQcwAYYXaHR0
# cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQELBQADggEBAHrs/rf97Zyr
# AqyaXhXV58W3q38egR7o5Dxyd8cIDBunhxY1v3e4syOmVU+APjU+49XThv1EHmt1
# Tbhi/NR+ZLBKwVH6rls7WiIQXGT4idWaFFItOlC5SaW0HLbEBLpCK/gva9aZzXfs
# EbgIgzBTqxmfpdIseptvdN5F6WIoPLRMaLJH4oCm0V2E5joqYawXunj0TNWzPoah
# Otq9x+Q8cinHNOXeqFVAfsQg8DdxX/xsVGyNl/TDU59+/VFZynHWneXi8ND8I6om
# iFuzPzKpr7vMiOveAs2wjrdxnaU+4HBL4E2g2WitRi890cmUaTLQrvNM52afdDEk
# 538pYKjmCUgwggWBMIIEaaADAgECAhA5ckQ6+SK3UdfTbBDdMTWVMA0GCSqGSIb3
# DQEBDAUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQIDBJHcmVhdGVyIE1hbmNoZXN0
# ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoMEUNvbW9kbyBDQSBMaW1pdGVk
# MSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2VydmljZXMwHhcNMTkwMzEyMDAw
# MDAwWhcNMjgxMjMxMjM1OTU5WjCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5l
# dyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNF
# UlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNh
# dGlvbiBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCA
# EmUXNg7D2wiz0KxXDXbtzSfTTK1Qg2HiqiBNCS1kCdzOiZ/MPans9s/B3PHTsdZ7
# NygRK0faOca8Ohm0X6a9fZ2jY0K2dvKpOyuR+OJv0OwWIJAJPuLodMkYtJHUYmTb
# f6MG8YgYapAiPLz+E/CHFHv25B+O1ORRxhFnRghRy4YUVD+8M/5+bJz/Fp0YvVGO
# NaanZshyZ9shZrHUm3gDwFA66Mzw3LyeTP6vBZY1H1dat//O+T23LLb2VN3I5xI6
# Ta5MirdcmrS3ID3KfyI0rn47aGYBROcBTkZTmzNg95S+UzeQc0PzMsNT79uq/nRO
# acdrjGCT3sTHDN/hMq7MkztReJVni+49Vv4M0GkPGw/zJSZrM233bkf6c0Plfg6l
# ZrEpfDKEY1WJxA3Bk1QwGROs0303p+tdOmw1XNtB1xLaqUkL39iAigmTYo61Zs8l
# iM2EuLE/pDkP2QKe6xJMlXzzawWpXhaDzLhn4ugTncxbgtNMs+1b/97lc6wjOy0A
# vzVVdAlJ2ElYGn+SNuZRkg7zJn0cTRe8yexDJtC/QV9AqURE9JnnV4eeUB9XVKg+
# /XRjL7FQZQnmWEIuQxpMtPAlR1n6BB6T1CZGSlCBst6+eLf8ZxXhyVeEHg9j1uli
# utZfVS7qXMYoCAQlObgOK6nyTJccBz8NUvXt7y+CDwIDAQABo4HyMIHvMB8GA1Ud
# IwQYMBaAFKARCiM+lvEH7OKvKe+CpX/QMKS0MB0GA1UdDgQWBBRTeb9aqitKz1SA
# 4dibwJ3ysgNmyzAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zARBgNV
# HSAECjAIMAYGBFUdIAAwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5jb21v
# ZG9jYS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNAYIKwYBBQUHAQEE
# KDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wDQYJKoZI
# hvcNAQEMBQADggEBABiHUdx0IT2ciuAntzPQLszs8ObLXhHeIm+bdY6ecv7k1v6q
# H5yWLe8DSn6u9I1vcjxDO8A/67jfXKqpxq7y/Njuo3tD9oY2fBTgzfT3P/7euLSK
# 8JGW/v1DZH79zNIBoX19+BkZyUIrE79Yi7qkomYEdoiRTgyJFM6iTckys7roFBq8
# cfFb8EELmAAKIgMQ5Qyx+c2SNxntO/HkOrb5RRMmda+7qu8/e3c70sQCkT0ZANMX
# XDnbP3sYDUXNk4WWL13fWRZPP1G91UUYP+1KjugGYXQjFrUNUHMnREd/EF2JKmuF
# MRTE6KlqTIC8anjPuH+OdnKZDJ3+15EIFqGjX5UwggX1MIID3aADAgECAhAdokgw
# b5smGNCC4JZ9M9NqMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoT
# FVRoZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBD
# ZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xODExMDIwMDAwMDBaFw0zMDEyMzEy
# MzU5NTlaMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0
# ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEk
# MCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhiKNMoV6GJ9J8JYvYwgeLdx8nxTP4ya2JWYp
# QIZURnQxYsUQ7bKHJ6aZy5UwwFb1pHXGqQ5QYqVRkRBq4Etirv3w+Bisp//uLjMg
# +gwZiahse60Aw2Gh3GllbR9uJ5bXl1GGpvQn5Xxqi5UeW2DVftcWkpwAL2j3l+1q
# cr44O2Pej79uTEFdEiAIWeg5zY/S1s8GtFcFtk6hPldrH5i8xGLWGwuNx2YbSp+d
# gcRyQLXiX+8LRf+jzhemLVWwt7C8VGqdvI1WU8bwunlQSSz3A7n+L2U18iLqLAev
# Rtn5RhzcjHxxKPP+p8YU3VWRbooRDd8GJJV9D6ehfDrahjVh0wIDAQABo4IBZDCC
# AWAwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFA7h
# OqhTOjHVir7Bu61nGgOFrTQOMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAG
# AQH/AgEAMB0GA1UdJQQWMBQGCCsGAQUFBwMDBggrBgEFBQcDCDARBgNVHSAECjAI
# MAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1c3Qu
# Y29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMHYGCCsG
# AQUFBwEBBGowaDA/BggrBgEFBQcwAoYzaHR0cDovL2NydC51c2VydHJ1c3QuY29t
# L1VTRVJUcnVzdFJTQUFkZFRydXN0Q0EuY3J0MCUGCCsGAQUFBzABhhlodHRwOi8v
# b2NzcC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQBNY1DtRzRKYaTb
# 3moqjJvxAAAeHWJ7Otcywvaz4GOz+2EAiJobbRAHBE++uOqJeCLrD0bs80ZeQEaJ
# EvQLd1qcKkE6/Nb06+f3FZUzw6GDKLfeL+SU94Uzgy1KQEi/msJPSrGPJPSzgTfT
# t2SwpiNqWWhSQl//BOvhdGV5CPWpk95rcUCZlrp48bnI4sMIFrGrY1rIFYBtdF5K
# dX6luMNstc/fSnmHXMdATWM19jDTz7UKDgsEf6BLrrujpdCEAJM+U100pQA1aWy+
# nyAlEA0Z+1CQYb45j3qOTfafDh7+B1ESZoMmGUiVzkrJwX/zOgWb+W/fiH/AI57S
# HkN6RTHBnE2p8FmyWRnoao0pBAJ3fEtLzXC+OrJVWng+vLtvAxAldxU0ivk2zEOS
# 5LpP8WKTKCVXKftRGcehJUBqhFfGsp2xvBwK2nxnfn0u6ShMGH7EezFBcZpLKewL
# PVdQ0srd/Z4FUeVEeN0B3rF1mA1UJP3wTuPi+IO9crrLPTru8F4XkmhtyGH5pvEq
# CgulufSe7pgyBYWe6/mDKdPGLH29OncuizdCoGqC7TtKqpQQpOEN+BfFtlp5MxiS
# 47V1+KHpjgolHuQe8Z9ahyP/n6RRnvs5gBHN27XEp6iAb+VT1ODjosLSWxr6MiYt
# aldwHDykWC6j81tLB9wyWfOHpxptWDGCEHswghB3AgEBMIGRMHwxCzAJBgNVBAYT
# AkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZv
# cmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBS
# U0EgQ29kZSBTaWduaW5nIENBAhEAvNU51iSY0pIemSd4RhoKzjANBglghkgBZQME
# AgEFAKB8MBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEi
# BCCLRMsgXybzQgOc8OFbCz7bOvHj+5HbJM7h5Y+ve2BDPTANBgkqhkiG9w0BAQEF
# AASCAQBXLL8wWolzcMj16VXvStoZBadlvQfx5egXwFb4Zkydhe/s1Lq94Z664n6X
# l3v3Ew94ssc0kM3kaUmjhg/oGsNWswn8MotvzU/oVEEhTYQgYb1HP3jL8KdrqiHX
# w5giZU7Z2siBO9bdGK8uCdta08wBgU+otcNeG9b0c3R4PrRAmmeA1I65H29c91yo
# UJE8D0jPlDMvhDDiYGCsqqPB3wBrbYC/JmR+0V2a3RwFxS34A9rL50uRr1p9lVwZ
# KZSy+OCb35kVTQohffD+CBVkiuOkc+xvSjJqeC782f8FJevfTKLpr/YLB45R/X/0
# +VQ3Uxtcljy4QmbITRnnA454R7YgoYIOPDCCDjgGCisGAQQBgjcDAwExgg4oMIIO
# JAYJKoZIhvcNAQcCoIIOFTCCDhECAQMxDTALBglghkgBZQMEAgEwggEOBgsqhkiG
# 9w0BCRABBKCB/gSB+zCB+AIBAQYLYIZIAYb4RQEHFwMwMTANBglghkgBZQMEAgEF
# AAQguxRgaV9LlgLxRNWRjRlG00wC6v6lKpsd3yYGkHSFahQCFCgQ7xm2ZqbTaDwX
# lXyR1vJZ/yNBGA8yMDIyMDIxMTAxNTY0MlowAwIBHqCBhqSBgzCBgDELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZT
# eW1hbnRlYyBUcnVzdCBOZXR3b3JrMTEwLwYDVQQDEyhTeW1hbnRlYyBTSEEyNTYg
# VGltZVN0YW1waW5nIFNpZ25lciAtIEczoIIKizCCBTgwggQgoAMCAQICEHsFsdRJ
# aFFE98mJ0pwZnRIwDQYJKoZIhvcNAQELBQAwgb0xCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0
# d29yazE6MDgGA1UECxMxKGMpIDIwMDggVmVyaVNpZ24sIEluYy4gLSBGb3IgYXV0
# aG9yaXplZCB1c2Ugb25seTE4MDYGA1UEAxMvVmVyaVNpZ24gVW5pdmVyc2FsIFJv
# b3QgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTYwMTEyMDAwMDAwWhcNMzEw
# MTExMjM1OTU5WjB3MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29y
# cG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxKDAmBgNV
# BAMTH1N5bWFudGVjIFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQC7WZ1ZVU+djHJdGoGi61XzsAGtPHGsMo8Fa4aa
# JwAyl2pNyWQUSym7wtkpuS7sY7Phzz8LVpD4Yht+66YH4t5/Xm1AONSRBudBfHkc
# y8utG7/YlZHz8O5s+K2WOS5/wSe4eDnFhKXt7a+Hjs6Nx23q0pi1Oh8eOZ3D9Jqo
# 9IThxNF8ccYGKbQ/5IMNJsN7CD5N+Qq3M0n/yjvU9bKbS+GImRr1wOkzFNbfx4Db
# ke7+vJJXcnf0zajM/gn1kze+lYhqxdz0sUvUzugJkV+1hHk1inisGTKPI8EyQRtZ
# Dqk+scz51ivvt9jk1R1tETqS9pPJnONI7rtTDtQ2l4Z4xaE3AgMBAAGjggF3MIIB
# czAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADBmBgNVHSAEXzBd
# MFsGC2CGSAGG+EUBBxcDMEwwIwYIKwYBBQUHAgEWF2h0dHBzOi8vZC5zeW1jYi5j
# b20vY3BzMCUGCCsGAQUFBwICMBkaF2h0dHBzOi8vZC5zeW1jYi5jb20vcnBhMC4G
# CCsGAQUFBwEBBCIwIDAeBggrBgEFBQcwAYYSaHR0cDovL3Muc3ltY2QuY29tMDYG
# A1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9zLnN5bWNiLmNvbS91bml2ZXJzYWwtcm9v
# dC5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwgwKAYDVR0RBCEwH6QdMBsxGTAXBgNV
# BAMTEFRpbWVTdGFtcC0yMDQ4LTMwHQYDVR0OBBYEFK9j1sqjToVy4Ke8QfMpojh/
# gHViMB8GA1UdIwQYMBaAFLZ3+mlIR59TEtXC6gcydgfRlwcZMA0GCSqGSIb3DQEB
# CwUAA4IBAQB16rAt1TQZXDJF/g7h1E+meMFv1+rd3E/zociBiPenjxXmQCmt5l30
# otlWZIRxMCrdHmEXZiBWBpgZjV1x8viXvAn9HJFHyeLojQP7zJAv1gpsTjPs1rST
# yEyQY0g5QCHE3dZuiZg8tZiX6KkGtwnJj1NXQZAv4R5NTtzKEHhsQm7wtsX4YVxS
# 9U72a433Snq+8839A9fZ9gOoD+NT9wp17MZ1LqpmhQSZt/gGV+HGDvbor9rsmxgf
# qrnjOgC/zoqUywHbnsc4uw9Sq9HjlANgCk2g/idtFDL8P5dA4b+ZidvkORS92uTT
# w+orWrOVWFUEfcea7CMDjYUq0v+uqWGBMIIFSzCCBDOgAwIBAgIQe9Tlr7rMBz+h
# ASMEIkFNEjANBgkqhkiG9w0BAQsFADB3MQswCQYDVQQGEwJVUzEdMBsGA1UEChMU
# U3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5l
# dHdvcmsxKDAmBgNVBAMTH1N5bWFudGVjIFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0Ew
# HhcNMTcxMjIzMDAwMDAwWhcNMjkwMzIyMjM1OTU5WjCBgDELMAkGA1UEBhMCVVMx
# HTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRl
# YyBUcnVzdCBOZXR3b3JrMTEwLwYDVQQDEyhTeW1hbnRlYyBTSEEyNTYgVGltZVN0
# YW1waW5nIFNpZ25lciAtIEczMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEArw6Kqvjcv2l7VBdxRwm9jTyB+HQVd2eQnP3eTgKeS3b25TY+ZdUkIG0w+d0d
# g+k/J0ozTm0WiuSNQI0iqr6nCxvSB7Y8tRokKPgbclE9yAmIJgg6+fpDI3VHcAyz
# X1uPCB1ySFdlTa8CPED39N0yOJM/5Sym81kjy4DeE035EMmqChhsVWFX0fECLMS1
# q/JsI9KfDQ8ZbK2FYmn9ToXBilIxq1vYyXRS41dsIr9Vf2/KBqs/SrcidmXs7Dby
# lpWBJiz9u5iqATjTryVAmwlT8ClXhVhe6oVIQSGH5d600yaye0BTWHmOUjEGTZQD
# RcTOPAPstwDyOiLFtG/l77CKmwIDAQABo4IBxzCCAcMwDAYDVR0TAQH/BAIwADBm
# BgNVHSAEXzBdMFsGC2CGSAGG+EUBBxcDMEwwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# ZC5zeW1jYi5jb20vY3BzMCUGCCsGAQUFBwICMBkaF2h0dHBzOi8vZC5zeW1jYi5j
# b20vcnBhMEAGA1UdHwQ5MDcwNaAzoDGGL2h0dHA6Ly90cy1jcmwud3Muc3ltYW50
# ZWMuY29tL3NoYTI1Ni10c3MtY2EuY3JsMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MA4GA1UdDwEB/wQEAwIHgDB3BggrBgEFBQcBAQRrMGkwKgYIKwYBBQUHMAGGHmh0
# dHA6Ly90cy1vY3NwLndzLnN5bWFudGVjLmNvbTA7BggrBgEFBQcwAoYvaHR0cDov
# L3RzLWFpYS53cy5zeW1hbnRlYy5jb20vc2hhMjU2LXRzcy1jYS5jZXIwKAYDVR0R
# BCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0yMDQ4LTYwHQYDVR0OBBYEFKUT
# AamfhcwbbhYeXzsxqnk2AHsdMB8GA1UdIwQYMBaAFK9j1sqjToVy4Ke8QfMpojh/
# gHViMA0GCSqGSIb3DQEBCwUAA4IBAQBGnq/wuKJfoplIz6gnSyHNsrmmcnBjL+NV
# KXs5Rk7nfmUGWIu8V4qSDQjYELo2JPoKe/s702K/SpQV5oLbilRt/yj+Z89xP+Yz
# CdmiWRD0Hkr+Zcze1GvjUil1AEorpczLm+ipTfe0F1mSQcO3P4bm9sB/RDxGXBda
# 46Q71Wkm1SF94YBnfmKst04uFZrlnCOvWxHqcalB+Q15OKmhDc+0sdo+mnrHIsV0
# zd9HCYbE/JElshuW6YUI6N3qdGBuYKVWeg3IRFjc5vlIFJ7lv94AvXexmBRyFCTf
# xxEsHwA/w0sUxmcczB4Go5BfXFSLPuMzW4IPxbeGAk5xn+lmRT92MYICWjCCAlYC
# AQEwgYswdzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0
# aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMSgwJgYDVQQDEx9T
# eW1hbnRlYyBTSEEyNTYgVGltZVN0YW1waW5nIENBAhB71OWvuswHP6EBIwQiQU0S
# MAsGCWCGSAFlAwQCAaCBpDAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJ
# KoZIhvcNAQkFMQ8XDTIyMDIxMTAxNTY0MlowLwYJKoZIhvcNAQkEMSIEIIrlMHZ9
# 22PZUZXn0rC2ctK6pP/2l0ZN4VZVaBQnocdyMDcGCyqGSIb3DQEJEAIvMSgwJjAk
# MCIEIMR0znYAfQI5Tg2l5N58FMaA+eKCATz+9lPvXbcf32H4MAsGCSqGSIb3DQEB
# AQSCAQBBBUQalYqhwDNNzI6H4pWvMb070lDgF939V7q3ltZ+A1CxGU+vRE8NuB7y
# m2JFn5zpdjfkF5GleV+aR0IbhcHsO0b9amdzt4yB+gmyQOkRK3GbDXZdp4LcPNvv
# GnrgLvuMw1YEP4oVsGit+1AfhyQR4MQlrPHvqjfolMlSsY4W81/tdEUku/JlWqC1
# GAkgK5gB/O74cVJjm+0lAABCd69SfeHv+dtLsyBjbt204zTMnG7CNReVlviLPU7l
# uZh/l48D4Xa3Zt66Jm5GgwQhXAbz4Y6tdImQrldgnyGK34dRNzKTxCJ6J94gBhmb
# YIoKvHG7uOJJ/zLSuPUzRPE7/HFG
# SIG # End signature block
