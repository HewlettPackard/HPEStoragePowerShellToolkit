# Disk.ps1: This is an autogenerated file. Part of Nimble Group Management SDK. All edits to this file will be lost!
#
# © Copyright 2017 Hewlett Packard Enterprise Development LP.


function Get-NSDisk {
  # .ExternalHelp ../NimPSSDK.psm1-help.xml
  [CmdletBinding(DefaultParameterSetName='id')]
  param(
    [Parameter(ParameterSetName='id')]
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet('id','is_dfc','serial','path','shelf_serial','shelf_location','shelf_id','shelf_location_id','vshelf_id','slot','bank','model','vendor','firmware_version','hba','port','size','state','type','block_type','raid_id','raid_resync_percent','raid_resync_current_speed','raid_resync_average_speed','raid_state','disk_internal_stat_1','smart_attribute_list','disk_op','force','array_name','array_id','partial_response_ok')]
    [string[]]$fields,

    [Parameter(ParameterSetName='id')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[bool]]$is_dfc,

    [Parameter(ParameterSetName='nonId')]
    [string]$serial,

    [Parameter(ParameterSetName='nonId')]
    [string]$path,

    [Parameter(ParameterSetName='nonId')]
    [string]$shelf_serial,

    [Parameter(ParameterSetName='nonId')]
    [string]$shelf_location,

    [Parameter(ParameterSetName='nonId')]
    [string]$shelf_id,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$shelf_location_id,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$vshelf_id,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$slot,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$bank,

    [Parameter(ParameterSetName='nonId')]
    [string]$model,

    [Parameter(ParameterSetName='nonId')]
    [string]$vendor,

    [Parameter(ParameterSetName='nonId')]
    [string]$firmware_version,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$hba,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$port,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$size,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'valid', 'void', 'removed', 't_fail', 'in use', 'absent', 'failed', 'foreign')]
    [string]$state,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'ssd', 'hdd')]
    [string]$type,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'block_512e', 'block_4Kn', 'block_none', 'block_512n')]
    [string]$block_type,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$raid_id,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$raid_resync_percent,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$raid_resync_current_speed,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[long]]$raid_resync_average_speed,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'okay', 'N/A', 'resynchronizing', 'faulty', 'spare')]
    [string]$raid_state,

    [Parameter(ParameterSetName='nonId')]
    [string]$disk_internal_stat_1,

    [Parameter(ParameterSetName='nonId')]
    [Object[]]$smart_attribute_list,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'add', 'remove')]
    [string]$disk_op,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[bool]]$force,

    [Parameter(ParameterSetName='nonId')]
    [string]$array_name,

    [Parameter(ParameterSetName='nonId')]
    [string]$array_id,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[bool]]$partial_response_ok

  )

  process
  {
    $API = 'disks'
    $Param = @{
      ObjectName = 'Disk'
      APIPath = 'disks'
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

function Set-NSDisk {
  # .ExternalHelp ../NimPSSDK.psm1-help.xml
  [CmdletBinding()]
  param(

    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='all')]
    [string]$id,

    [Parameter(ParameterSetName='all', Mandatory = $True)]
    [ValidateSet( 'add', 'remove')]
    [string] $disk_op,

    [Parameter(ParameterSetName='all')]
    
    [Nullable[bool]] $force

  )

    process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
            if ($key.ToLower() -ne 'id')
            {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {
                    $RequestData.Add("$($var.name)", ($var.value))
                }
            }
        }
        $Params = @{
            ObjectName = 'Disk'
            APIPath = 'disks'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}




# SIG # Begin signature block
# MIIhEgYJKoZIhvcNAQcCoIIhAzCCIP8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCnJaGvaYSnaLcv
# 4/QifyCYikNb9tt/q9kDCQG9EMYrnaCCEKwwggUqMIIEEqADAgECAhEAvNU51iSY
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
# aldwHDykWC6j81tLB9wyWfOHpxptWDGCD7wwgg+4AgEBMIGRMHwxCzAJBgNVBAYT
# AkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZv
# cmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBS
# U0EgQ29kZSBTaWduaW5nIENBAhEAvNU51iSY0pIemSd4RhoKzjANBglghkgBZQME
# AgEFAKB8MBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEi
# BCCuRZEZMA8n6C9zFt5dbIpcXjPEtuvR4b+2GdfzgHlTyjANBgkqhkiG9w0BAQEF
# AASCAQCEr/F0MAuuP2Wr67kSnMXABaTZTvqIhSeCirxq2cXB2/7/E2nAKy95aSWX
# KV3C0skZjLaFYonwHhUuPc3OoemnbaRHnC7USQrOA8KjbQ6ZjYct79IAOJyBelpV
# /BybYubMpxfiUH6cb3e/dSKuK83R+Y94Mh+VFs6KNpxjEbbtvXO1DH7NEzVuNwTz
# Eb3P9rCFbiSs/HCZR1RgdLEX4gPD8FWta8S8c3NRdaJvblnZr0RlzWpsagI8JrMj
# BAIXhdvBnOgAwiBXfyH+WT0E/66t4TK/gMcwbu3qMlZFcB91N9EE7ASDi36xpVtl
# 9dubWwnG6x4bzNNLLLubkwJ/7Ks9oYINfTCCDXkGCisGAQQBgjcDAwExgg1pMIIN
# ZQYJKoZIhvcNAQcCoIINVjCCDVICAQMxDzANBglghkgBZQMEAgEFADB3BgsqhkiG
# 9w0BCRABBKBoBGYwZAIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIKic
# PY9Amy7aAEtJnMc+6Df3m5JdJeXZz+1I6CeSaqqCAhAHzfv5fM1nwP/zodhck1dX
# GA8yMDIyMDIxMTAxNTYxN1qgggo3MIIE/jCCA+agAwIBAgIQDUJK4L46iP9gQCHO
# FADw3TANBgkqhkiG9w0BAQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhE
# aWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENBMB4XDTIxMDEw
# MTAwMDAwMFoXDTMxMDEwNjAwMDAwMFowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoT
# DkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAy
# MTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMLmYYRnxYr1DQikRcpj
# a1HXOhFCvQp1dU2UtAxQtSYQ/h3Ib5FrDJbnGlxI70Tlv5thzRWRYlq4/2cLnGP9
# NmqB+in43Stwhd4CGPN4bbx9+cdtCT2+anaH6Yq9+IRdHnbJ5MZ2djpT0dHTWjaP
# xqPhLxs6t2HWc+xObTOKfF1FLUuxUOZBOjdWhtyTI433UCXoZObd048vV7WHIOsO
# jizVI9r0TXhG4wODMSlKXAwxikqMiMX3MFr5FK8VX2xDSQn9JiNT9o1j6BqrW7Ed
# MMKbaYK02/xWVLwfoYervnpbCiAvSwnJlaeNsvrWY4tOpXIc7p96AXP4Gdb+DUmE
# vQECAwEAAaOCAbgwggG0MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYG
# A1UdJQEB/wQMMAoGCCsGAQUFBwMIMEEGA1UdIAQ6MDgwNgYJYIZIAYb9bAcBMCkw
# JwYIKwYBBQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAfBgNVHSME
# GDAWgBT0tuEgHf4prtLkYaWyoiWyyBc1bjAdBgNVHQ4EFgQUNkSGjqS6sGa+vCgt
# HUQ23eNqerwwcQYDVR0fBGowaDAyoDCgLoYsaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL3NoYTItYXNzdXJlZC10cy5jcmwwMqAwoC6GLGh0dHA6Ly9jcmw0LmRpZ2lj
# ZXJ0LmNvbS9zaGEyLWFzc3VyZWQtdHMuY3JsMIGFBggrBgEFBQcBAQR5MHcwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBPBggrBgEFBQcwAoZD
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RFRpbWVzdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAQEASBzctemaI7zn
# GucgDo5nRv1CclF0CiNHo6uS0iXEcFm+FKDlJ4GlTRQVGQd58NEEw4bZO73+RAJm
# Te1ppA/2uHDPYuj1UUp4eTZ6J7fz51Kfk6ftQ55757TdQSKJ+4eiRgNO/PT+t2R3
# Y18jUmmDgvoaU+2QzI2hF3MN9PNlOXBL85zWenvaDLw9MtAby/Vh/HUIAHa8gQ74
# wOFcz8QRcucbZEnYIpp1FUL1LTI4gdr0YKK6tFL7XOBhJCVPst/JKahzQ1HavWPW
# H1ub9y4bTxMd90oNcX6Xt/Q/hOvB46NJofrOp79Wz7pZdmGJX36ntI5nePk2mOHL
# KNpbh6aKLzCCBTEwggQZoAMCAQICEAqhJdbWMht+QeQF2jaXwhUwDQYJKoZIhvcN
# AQELBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJl
# ZCBJRCBSb290IENBMB4XDTE2MDEwNzEyMDAwMFoXDTMxMDEwNzEyMDAwMFowcjEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElE
# IFRpbWVzdGFtcGluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AL3QMu5LzY9/3am6gpnFOVQoV7YjSsQOB0UzURB90Pl9TWh+57ag9I2ziOSXv2Mh
# kJi/E7xX08PhfgjWahQAOPcuHjvuzKb2Mln+X2U/4Jvr40ZHBhpVfgsnfsCi9aDg
# 3iI/Dv9+lfvzo7oiPhisEeTwmQNtO4V8CdPuXciaC1TjqAlxa+DPIhAPdc9xck4K
# rd9AOly3UeGheRTGTSQjMF287DxgaqwvB8z98OpH2YhQXv1mblZhJymJhFHmgudG
# UP2UKiyn5HU+upgPhH+fMRTWrdXyZMt7HgXQhBlyF/EXBu89zdZN7wZC/aJTKk+F
# HcQdPK/P2qwQ9d2srOlW/5MCAwEAAaOCAc4wggHKMB0GA1UdDgQWBBT0tuEgHf4p
# rtLkYaWyoiWyyBc1bjAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAS
# BgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggr
# BgEFBQcDCDB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6
# oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEUm9vdENBLmNybDBQBgNVHSAESTBHMDgGCmCGSAGG/WwAAgQw
# KjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzALBglg
# hkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggEBAHGVEulRh1Zpze/d2nyqY3qzeM8G
# N0CE70uEv8rPAwL9xafDDiBCLK938ysfDCFaKrcFNB1qrpn4J6JmvwmqYN92pDqT
# D/iy0dh8GWLoXoIlHsS6HHssIeLWWywUNUMEaLLbdQLgcseY1jxk5R9IEBhfiThh
# TWJGJIdjjJFSLK8pieV4H9YLFKWA1xJHcLN11ZOFk362kmf7U2GJqPVrlsD0WGkN
# fMgBsbkodbeZY4UijGHKeZR+WfyMD+NvtQEmtmyl7odRIeRYYJu6DC0rbaLEfrvE
# JStHAgh8Sa4TtuF8QkIoxhhWz0E0tmZdtnR79VYzIi8iNrJLokqV2PWmjlIxggKG
# MIICggIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBT
# SEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENBAhANQkrgvjqI/2BAIc4UAPDd
# MA0GCWCGSAFlAwQCAQUAoIHRMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAc
# BgkqhkiG9w0BCQUxDxcNMjIwMjExMDE1NjE3WjArBgsqhkiG9w0BCRACDDEcMBow
# GDAWBBTh14Ko4ZG+72vKFpG1qrSUpiSb8zAvBgkqhkiG9w0BCQQxIgQgjbIjJwxj
# fxk8ahQjB7BlanAnRHkTkXYLcLGQvnqZiJswNwYLKoZIhvcNAQkQAi8xKDAmMCQw
# IgQgsxCQBrwK2YMHkVcp4EQDQVyD4ykrYU8mlkyNNXHs9akwDQYJKoZIhvcNAQEB
# BQAEggEASZTQkZxmNNDI90C+/DMJ3j9bjeO4PFnxv2pyUNelkCTn6GHCAvzjw8wg
# QaLpsQ/Woi0Pz0Cq/OaRyNZ1iQ4RD1UEFndX+/gFwdWg5iBcXmUfQnxnsZ3FCUqu
# 770KVIhstaTuAanOAiBEy1z7xTL4J+esHRV9CbV2RrRvs+qSjmSnQok9D2aHuaHw
# 2bpQvk2L+BnB3v9p85UzBSqvoYh1DG0GoGfmZP7WlcjvbpjOOzEKYDF7JpV5Hkg5
# 1lu6Cp/1uPJXuqpvBK3Go5ZDARGOrjEmcvtSqpBcl2E02cscTU50FSJ24Lzng+PE
# Kz3m4n//lrsUAzk10o4Hv2XBvCpmaA==
# SIG # End signature block
