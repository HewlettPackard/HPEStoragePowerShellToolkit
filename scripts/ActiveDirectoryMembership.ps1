# ActiveDirectoryMembership.ps1: This is an autogenerated file. Part of Nimble Group Management SDK. All edits to this file will be lost!
#
# © Copyright 2017 Hewlett Packard Enterprise Development LP.

function New-NSActiveDirectoryMembership {
  # .ExternalHelp ../NimPSSDK.psm1-help.xml
  [CmdletBinding()]
  param(
    [Parameter(ParameterSetName='allButId')]
    [AllowEmptyString()]
    [string] $name,

    [Parameter(ParameterSetName='allButId')]
    [AllowEmptyString()]
    [string] $netbios,

    [Parameter(ParameterSetName='allButId')]
    [AllowEmptyString()]
    [string] $server_list,

    [Parameter(ParameterSetName='allButId')]
    [AllowEmptyString()]
    [string] $computer_name,

    [Parameter(ParameterSetName='allButId')]
    [AllowEmptyString()]
    [string] $organizational_unit,

    [Parameter(ParameterSetName='allButId', Mandatory = $True)]
    [AllowEmptyString()]
    [string] $user,

    [Parameter(ParameterSetName='allButId', Mandatory = $True)]
    [AllowEmptyString()]
    [string] $password,

    [Parameter(ParameterSetName='allButId')]
    
    [Nullable[bool]] $enabled

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
            ObjectName = 'ActiveDirectoryMembership'
            APIPath = 'active_directory_memberships'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSActiveDirectoryMembership {
  # .ExternalHelp ../NimPSSDK.psm1-help.xml
  [CmdletBinding(DefaultParameterSetName='id')]
  param(
    [Parameter(ParameterSetName='id')]
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet('id','description','name','netbios','server_list','computer_name','organizational_unit','user','password','enabled')]
    [string[]]$fields,

    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{2})([0-9a-f]{16})([0-9a-f]{16})([0-9a-f]{8})')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$description,

    [Parameter(ParameterSetName='nonId')]
    [string]$name,

    [Parameter(ParameterSetName='nonId')]
    [string]$netbios,

    [Parameter(ParameterSetName='nonId')]
    [string]$server_list,

    [Parameter(ParameterSetName='nonId')]
    [string]$computer_name,

    [Parameter(ParameterSetName='nonId')]
    [string]$organizational_unit,

    [Parameter(ParameterSetName='nonId')]
    [string]$user,

    [Parameter(ParameterSetName='nonId')]
    [string]$password,

    [Parameter(ParameterSetName='nonId')]
    [Nullable[bool]]$enabled

  )

  process
  {
    $API = 'active_directory_memberships'
    $Param = @{
      ObjectName = 'ActiveDirectoryMembership'
      APIPath = 'active_directory_memberships'
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

function Set-NSActiveDirectoryMembership {
  # .ExternalHelp ../NimPSSDK.psm1-help.xml
  [CmdletBinding()]
  param(

    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='all')]
    [string]$id,

    [Parameter(ParameterSetName='all')]
    [AllowEmptyString()]
    [string] $description,

    [Parameter(ParameterSetName='all')]
    [AllowEmptyString()]
    [string] $server_list,

    [Parameter(ParameterSetName='all')]
    
    [Nullable[bool]] $enabled

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
            ObjectName = 'ActiveDirectoryMembership'
            APIPath = 'active_directory_memberships'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}


function Remove-NSActiveDirectoryMembership {
    # .ExternalHelp ../NimPSSDK.psm1-help.xml
    [CmdletBinding(DefaultParameterSetName='allArgs')]
    param (
    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [AllowEmptyString()]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [AllowEmptyString()]
    [string]$user,

    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [AllowEmptyString()]
    [string]$password,

    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs')]
    
    [Nullable[bool]]$force

  )

  process{
    $Params = @{
        APIPath = 'active_directory_memberships'
        Action = 'remove'
        ReturnType = 'void'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}
function Test-NSActiveDirectoryMembership {
    # .ExternalHelp ../NimPSSDK.psm1-help.xml
    [CmdletBinding(DefaultParameterSetName='allArgs')]
    param (
    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [AllowEmptyString()]
    [string]$id

  )

  process{
    $Params = @{
        APIPath = 'active_directory_memberships'
        Action = 'report_status'
        ReturnType = 'NsADReportStatusReturn'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}
function Test-NSActiveDirectoryMembershipUser {
    # .ExternalHelp ../NimPSSDK.psm1-help.xml
    [CmdletBinding(DefaultParameterSetName='allArgs')]
    param (
    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [AllowEmptyString()]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [AllowEmptyString()]
    [string]$name

  )

  process{
    $Params = @{
        APIPath = 'active_directory_memberships'
        Action = 'test_user'
        ReturnType = 'NsADTestUserReturn'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}
function Test-NSActiveDirectoryMembershipGroup {
    # .ExternalHelp ../NimPSSDK.psm1-help.xml
    [CmdletBinding(DefaultParameterSetName='allArgs')]
    param (
    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [AllowEmptyString()]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, ParameterSetName='allArgs', Mandatory = $True)]
    [AllowEmptyString()]
    [string]$name

  )

  process{
    $Params = @{
        APIPath = 'active_directory_memberships'
        Action = 'test_group'
        ReturnType = 'void'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}


# SIG # Begin signature block
# MIIhEwYJKoZIhvcNAQcCoIIhBDCCIQACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBg7eaqwfQDQkiH
# fmjQHKj+Pt+D7Vv3lNr+5cT0LaUaFaCCEKwwggUqMIIEEqADAgECAhEAvNU51iSY
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
# aldwHDykWC6j81tLB9wyWfOHpxptWDGCD70wgg+5AgEBMIGRMHwxCzAJBgNVBAYT
# AkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZv
# cmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBS
# U0EgQ29kZSBTaWduaW5nIENBAhEAvNU51iSY0pIemSd4RhoKzjANBglghkgBZQME
# AgEFAKB8MBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEi
# BCAWpd/P7TEb3+zvkC5+xO9zEvJwZEDSQKvdcn7pEIqRvzANBgkqhkiG9w0BAQEF
# AASCAQAugxqMlVAhSuiaKdq01ViZ9bxBc2j8JnTI4BRf2mXElxr6/NPYh0mvkrBJ
# g8RngI3miXdKaRwdudfaOrGKMzhVUJAiTlsB6iqNMbS4zg3s55JaHQJBzbEU66my
# QrIOZZrQk4YqKa/KY/acyO5GZCDFJwuXvunN+PH7hbkj+Bn9ytKIpj84kTcxSSwc
# 9uD9JhVFOA2dudHSjK3+AaoajxOoM3/1j735ebQgnbEiFSk1Y89EGPniRCUs6p/P
# PWQ9nVnxdPj1A7xoUdD/OWkeJOQI1RigNctopOIoXrEhl1MrMXzyOLIQTxp70ct2
# syO5kO3UhIYcw8Vswk+Egd6CkPQ1oYINfjCCDXoGCisGAQQBgjcDAwExgg1qMIIN
# ZgYJKoZIhvcNAQcCoIINVzCCDVMCAQMxDzANBglghkgBZQMEAgEFADB4BgsqhkiG
# 9w0BCRABBKBpBGcwZQIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEILLu
# OjkYT0iFau2yQIL03wIZlQj3W4jsUWJ7y93TSH2fAhEA4qYi286Z505hIVppD0S3
# ZRgPMjAyMjAyMTEwMTQ2NDlaoIIKNzCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAh
# zhQA8N0wDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERp
# Z2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMo
# RGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAx
# MDEwMDAwMDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIw
# MjEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXK
# Y2tR1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj
# /TZqgfop+N0rcIXeAhjzeG28ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2
# j8aj4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDr
# Do4s1SPa9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1ux
# HTDCm2mCtNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1J
# hL0BAgMBAAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAW
# BgNVHSUBAf8EDDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATAp
# MCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0j
# BBgwFoAU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwo
# LR1ENt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9zaGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdp
# Y2VydC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKG
# Q2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVk
# SURUaW1lc3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO8
# 5xrnIA6OZ0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQC
# Zk3taaQP9rhwz2Lo9VFKeHk2eie38+dSn5On7UOee+e03UEiifuHokYDTvz0/rdk
# d2NfI1Jpg4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO
# +MDhXM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j
# 1h9bm/cuG08THfdKDXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5Npjh
# yyjaW4emii8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHkBdo2l8IVMA0GCSqGSIb3
# DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAX
# BgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3Vy
# ZWQgSUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0zMTAxMDcxMjAwMDBaMHIx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJ
# RCBUaW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC90DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5fU1ofue2oPSNs4jkl79j
# IZCYvxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb6+NGRwYaVX4LJ37AovWg
# 4N4iPw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU46gJcWvgzyIQD3XPcXJO
# Cq3fQDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mIUF79Zm5WYScpiYRR5oLn
# RlD9lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfxFwbvPc3WTe8GQv2iUypP
# hR3EHTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAdBgNVHQ4EFgQU9LbhIB3+
# Ka7S5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8w
# EgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYI
# KwYBBQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgw
# OqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJ
# RFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkwRzA4BgpghkgBhv1sAAIE
# MCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJ
# YIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLpUYdWac3v3dp8qmN6s3jP
# BjdAhO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQdaq6Z+CeiZr8JqmDfdqQ6
# kw/4stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC4HLHmNY8ZOUfSBAYX4k4
# YU1iRiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+tpJn+1Nhiaj1a5bA9Fhp
# DXzIAbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6HUSHkWGCbugwtK22ixH67
# xCUrRwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIvIjayS6JKldj1po5SMYIC
# hjCCAoICAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IElu
# YzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQg
# U0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw
# 3TANBglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQw
# HAYJKoZIhvcNAQkFMQ8XDTIyMDIxMTAxNDY0OVowKwYLKoZIhvcNAQkQAgwxHDAa
# MBgwFgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJKoZIhvcNAQkEMSIEIMJg+Xbr
# GD6TfwA2NutmffPH9pUmym7HlCBnU9fdKf7pMDcGCyqGSIb3DQEJEAIvMSgwJjAk
# MCIEILMQkAa8CtmDB5FXKeBEA0Fcg+MpK2FPJpZMjTVx7PWpMA0GCSqGSIb3DQEB
# AQUABIIBAF0fogd0D8srfk9JOVBgXRx8PJ+0FvkwBKsqCiRas/8cIOOb1s3mElOD
# Gh9v/xYTn6hGz6xKGo99V45Df03WdoiAuPsDi9kbu3i47d5Q4sgCl3qqqKTrM8SK
# wp4+83UIGRoNKWVQP5+lbUD/fBHHh5Jr8tdGVFap9ome2YPOxGOUmDQV7zrFpO02
# uCAVvGumlOXfwBiAMwjTcn+/pnTbh6HCRsTtrYvzuUdao8OBlsrjbJwk2JaCvFAH
# hRgR9SDcbJDJ/7/HzlRzCKQuC7dksolvRhOD64HioQgFuQ+3ZzwpEC+S7R5a/zxt
# AjfPhQmFyvfPFB9WCR1osbFmswqgMuU=
# SIG # End signature block
