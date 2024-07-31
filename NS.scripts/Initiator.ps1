# Initiator.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSInitiator {
<#
.SYNOPSIS
  Create an initiator used for authentication.
.DESCRIPTION
  reate an initiator used for authentication.
.PARAMETER id
  Identifier for initiator. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER access_protocol
  Access protocol used by the initiator. Valid values are 'iscsi' and 'fc'.
.PARAMETER initiator_group_id
  Identifier of the initiator group that this initiator is assigned to.
.PARAMETER initiator_group_name
  Name of the initiator group that this initiator is assigned to.
.PARAMETER label
  Unique Identifier of the iSCSI initiator. Label is required when creating iSCSI initiator.
.PARAMETER iqn
  IQN name of the iSCSI initiator. Each initiator IQN name must have an associated IP address specified 
  using the 'ip_address' attribute. You can choose not to enter the IP address for an initiator if you
  prefer not to authenticate using both name and IP address, in this case the IP address will be returned as '*'.
.PARAMETER ip_address
  IP address of the iSCSI initiator. Each initiator IP address must have an associated name specified 
  using 'name' attribute. You can choose not to enter the name for an initiator if you prefer not to
  authenticate using both name and IP address, in this case the IQN name will be returned as '*'.
.PARAMETER alias
  Alias of the Fibre Channel initiator. Maximum alias length is 32 characters. Each initiator alias must have an 
  associated WWPN specified using the 'wwpn' attribute. You can choose not to enter the WWPN for
  an initiator when using previously saved initiator alias.
.PARAMETER chapuser_id
  Identifier for the CHAP user.
.PARAMETER wwpn
  WWPN (World Wide Port Name) of the Fibre Channel initiator. WWPN is required when creating a Fibre Channel initiator. 
  Each initiator WWPN can have an associated alias specified using the 'alias' attribute.
  You can choose not to enter the alias for an initiator if you prefer not to assign an initiator alias.
.PARAMETER vp_override
  Flag to allow modifying VP created initiator groups. When set to true, user can add this initiator to a VP created initiator group.
.PARAMETER creation_time
  Time when this initiator group was created.
.PARAMETER last_modified
  Time when this initiator group was last modified.
.PARAMETER override_existing_alias
  Forcibly add Fibre Channel initiator to initiator group by updating or removing conflicting Fibre Channel initiator aliases.
.EXAMPLE
  C:\> New-NSInitiator -label TestInitiator-134 -initiator_group_id 0228eada7f8dd99d3b000000000000000000000057 -access_protocol iscsi -iqn "iqn.2007-11.com.storage:TEST3"

  Label             IQN                           WWPN
  -----             ---                           ----
  TestInitiator-134 iqn.2007-11.com.storage:TEST3

  This command create a new initiator group.
#>
[CmdletBinding()]
param(
    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [ValidateSet( 'iscsi', 'fc')]
    [string] $access_protocol,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [string] $initiator_group_id,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [string] $label,

    [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
    [string] $iqn,

    [Parameter(ParameterSetName='iscsi')]
    [Parameter(ParameterSetName='fc')]
    [string] $ip_address,

    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [string] $alias,

    [Parameter(ParameterSetName='iscsi')]
    [string] $chapuser_id,

    [Parameter(ParameterSetName='fc',    Mandatory = $True)]
    [string] $wwpn,

    [Parameter(ParameterSetName='iscsi')]
    [Parameter(ParameterSetName='fc')]
    [bool] $vp_override,

    [Parameter(ParameterSetName='iscsi')]
    [Parameter(ParameterSetName='fc')]
    [bool]  $override_existing_alias
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
            ObjectName = 'Initiator'
            APIPath = 'initiators'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSInitiator {
<#
.SYNOPSIS
  List a set of initiators used for authentication.
.DESCRIPTION
  List a set of initiators used for authentication.
.PARAMETER id
  Identifier for initiator. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER access_protocol
  Access protocol used by the initiator. Valid values are 'iscsi' and 'fc'.
.PARAMETER initiator_group_id
  Identifier of the initiator group that this initiator is assigned to.
.PARAMETER initiator_group_name
  Name of the initiator group that this initiator is assigned to.
.PARAMETER label
  Unique Identifier of the iSCSI initiator. Label is required when creating iSCSI initiator.
.PARAMETER iqn
  IQN name of the iSCSI initiator. Each initiator IQN name must have an associated IP address specified using the 'ip_address' 
  attribute. You can choose not to enter the IP address for an initiator if you prefer not to authenticate using both name and 
  IP address, in this case the IP address will be returned as '*'.
.PARAMETER ip_address
  IP address of the iSCSI initiator. Each initiator IP address must have an associated name specified using 'name' attribute. 
  You can choose not to enter the name for an initiator if you prefer not to authenticate using both name and IP address, 
  in this case the IQN name will be returned as '*'.
.PARAMETER alias
  Alias of the Fibre Channel initiator. Maximum alias length is 32 characters. Each initiator alias must have an associated 
  WWPN specified using the 'wwpn' attribute. You can choose not to enter the WWPN for an initiator when using previously 
  saved initiator alias.
.PARAMETER wwpn
  WWPN (World Wide Port Name) of the Fibre Channel initiator. WWPN is required when creating a Fibre Channel initiator. 
  Each initiator WWPN can have an associated alias specified using the 'alias' attribute.
  You can choose not to enter the alias for an initiator if you prefer not to assign an initiator alias.
.EXAMPLE
  PS:> Get-NSInitiator

  Label                          IQN                                                     WWPN
  -----                          ---                                                     ----
  Crypt                          iqn.1991-05.com.microsoft:crypt
  NSSQL-Autocreated              iqn.1991-05.com.microsoft:nssql.lionetti.lab
  NSSCVMM-Autocreated            iqn.1991-05.com.microsoft:nsscvmm.lionetti.lab
  NSSCOM-Autocreated             iqn.1991-05.com.microsoft:nsscom.lionetti.lab
  NSSCORCH-Autocreated           iqn.1991-05.com.microsoft:nsscorch.lionetti.lab
  NSSCDPM-Autocreated            iqn.1991-05.com.microsoft:nsscdpm.lionetti.lab
  DaxIQN                         iqn.1991-05.com.microsoft:dax.lionetti.lab
  DFSR1IQN                       iqn.1991-05.com.microsoft:dfsr1.lionetti.lab
  TardisIQN                      iqn.1991-05.com.microsoft:tardis.lionetti.lab
  Hera-iqn                       iqn.1991-05.com.microsoft:hera.lionetti.lab
.EXAMPLE
  PS:> Get-NSInitiator -label 'Crypt'

  Label                          IQN                                                     WWPN
  -----                          ---                                                     ----
  Crypt                          iqn.1991-05.com.microsoft:crypt
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]   [string]    $id,
    [Parameter(ParameterSetName='iscsi')]
    [Parameter(ParameterSetName='fc')]
    [ValidateSet( 'iscsi', 'fc')]         [string]    $access_protocol,
    [Parameter(ParameterSetName='iscsi')]
    [Parameter(ParameterSetName='fc')]
    [ValidatePattern('([0-9a-f]{42})')]   [string]    $initiator_group_id,
    [Parameter(ParameterSetName='iscsi')]
    [Parameter(ParameterSetName='fc')]    [string]    $initiator_group_name,
    [Parameter(ParameterSetName='iscsi')] [string]    $label,
    [Parameter(ParameterSetName='iscsi')] [string]    $iqn,
    [Parameter(ParameterSetName='iscsi')] [string]    $ip_address,
    [Parameter(ParameterSetName='fc')]    [string]    $alias,
    [Parameter(ParameterSetName='fc')]    [string]    $wwpn
  )
process{
    $API = 'initiators'
    $Param = @{
      ObjectName = 'Initiator'
      APIPath = 'initiators'
    }
    if ($id)
    {   # Get a single object for given Id.
        $Param.Id = $id
        $ResponseObject = Get-NimbleStorageAPIObject @Param
        return $ResponseObject
    }
    else
    {   # Get list of objects matching the given filter.
        $Param.Filter = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        { if ($key.ToLower() -ne 'fields')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                { $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Remove-NSInitiator {
<#
.SYNOPSIS
  Delete the specified initiator.
.DESCRIPTION
  Delete the specified initiator.
.PARAMETER id
  Identifier for initiator. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
[ValidatePattern('([0-9a-f]{42})')] [string]$id
    )
process { 
      $Params = @{  ObjectName = 'Initiator'
                    APIPath = 'initiators'
                    Id = $id
                }
      Remove-NimbleStorageAPIObject @Params
}
}

# SIG # Begin signature block
# MIIt2QYJKoZIhvcNAQcCoIItyjCCLcYCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEC7Vxa2dSZ/
# ZqiH0IQdSJCnSs9Z6j/uzeOEw/mxfFTInFceHgVsuYffjohEN7brQ7/e3BKcgJy0
# 3XgJoR9qVgBkoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCG5YwghuSAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQIYUgPLmmdPZFWH7O6TSgt5ApmPrpWMbWzrfugewRQkJWQi+cfwTcBwu
# u60Sz5NxNLlrbfaufJVGDtr70aGEtYIwDQYJKoZIhvcNAQEBBQAEggGAk0MgqFWc
# XhhJNoh1xsvYvonZUUeFVCdGIH9ptu5mcCwpmSrTF7r2xqUsWDnQS5sLDe9fbeFU
# z+ADji0qE0h+8do45BTIV338Qy7Kh1b3w/UHM3E3mAHV7WHQwjUHelb/r/6Um+mt
# N2pa4LNtQzIxs4yZ6jA0/SbGA9jrxEamTbp6vzh5+5MpG1tEwnMHwI+79WPcOlOt
# foq6F1Pj8zjFqm4RYMvzxEjw++0FqmE7TM8RnRo8ftPC2zIi71wlgq/bqvG2K/9j
# q/XXE3TheQhxN7vX4AvWti4rQ4jPngVwGWAIqWtrwItQAHuA4EYhczTpV9T9py8A
# +gKnF/OCpUN0ADhx5hsZMS06FX6K/iUGceEeYKiGniQf5lGa88wsRrNs0XmZqJvR
# z2SlqAGzubQhHgTjEz8jmogo00oaVZ9Yr2velVcdrR2yCtTkQrDkjKjJkgI5xhXc
# XC+8jgJAF8t7lPjvv2P3Rkh/Xm9pzZ/G6sQpcrnQgwNjtN7P2chKvD9woYIY3zCC
# GNsGCisGAQQBgjcDAwExghjLMIIYxwYJKoZIhvcNAQcCoIIYuDCCGLQCAQMxDzAN
# BglghkgBZQMEAgIFADCCAQQGCyqGSIb3DQEJEAEEoIH0BIHxMIHuAgEBBgorBgEE
# AbIxAgEBMEEwDQYJYIZIAWUDBAICBQAEMB3qtyLDux1CjiMqVQ6ql1wPeewZ6kGT
# jwwnXvmV5dYcpUrW3pic9sZgEaszwg08MQIVAPjU5tr5sc3YlBOCNrImoerJwcOP
# GA8yMDI0MDczMTIwNTI1OVqgcqRwMG4xCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpN
# YW5jaGVzdGVyMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMTJ1Nl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNaCCEv8wggZdMIIE
# xaADAgECAhA6UmoshM5V5h1l/MwS2OmJMA0GCSqGSIb3DQEBDAUAMFUxCzAJBgNV
# BAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3Rp
# Z28gUHVibGljIFRpbWUgU3RhbXBpbmcgQ0EgUjM2MB4XDTI0MDExNTAwMDAwMFoX
# DTM1MDQxNDIzNTk1OVowbjELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1hbmNoZXN0
# ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEwMC4GA1UEAxMnU2VjdGlnbyBQ
# dWJsaWMgVGltZSBTdGFtcGluZyBTaWduZXIgUjM1MIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAjdFn9MFIm739OEk6TWGBm8PY3EWlYQQ2jQae45iWgPXU
# GVuYoIa1xjTGIyuw3suUSBzKiyG0/c/Yn++d5mG6IyayljuGT9DeXQU9k8GWWj2/
# BPoamg2fFctnPsdTYhMGxM06z1+Ft0Bav8ybww21ii/faiy+NhiUM195+cFqOtCp
# JXxZ/lm9tpjmVmEqpAlRpfGmLhNdkqiEuDFTuD1GsV3jvuPuPGKUJTam3P53U4LM
# 0UCxeDI8Qz40Qw9TPar6S02XExlc8X1YsiE6ETcTz+g1ImQ1OqFwEaxsMj/WoJT1
# 8GG5KiNnS7n/X4iMwboAg3IjpcvEzw4AZCZowHyCzYhnFRM4PuNMVHYcTXGgvuq9
# I7j4ke281x4e7/90Z5Wbk92RrLcS35hO30TABcGx3Q8+YLRy6o0k1w4jRefCMT7b
# 5mTxtq5XPmKvtgfPuaWPkGZ/tbxInyNDA7YgOgccULjp4+D56g2iuzRCsLQ9ac6A
# N4yRbqCYsG2rcIQ5INTyI2JzA2w1vsAHPRbUTeqVLDuNOY2gYIoKBWQsPYVoyzao
# BVU6O5TG+a1YyfWkgVVS9nXKs8hVti3VpOV3aeuaHnjgC6He2CCDL9aW6gteUe0A
# mC8XCtWwpePx6QW3ROZo8vSUe9AR7mMdu5+FzTmW8K13Bt8GX/YBFJO7LWzwKAUC
# AwEAAaOCAY4wggGKMB8GA1UdIwQYMBaAFF9Y7UwxeqJhQo1SgLqzYZcZojKbMB0G
# A1UdDgQWBBRo76QySWm2Ujgd6kM5LPQUap4MhTAOBgNVHQ8BAf8EBAMCBsAwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBKBgNVHSAEQzBBMDUG
# DCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29t
# L0NQUzAIBgZngQwBBAIwSgYDVR0fBEMwQTA/oD2gO4Y5aHR0cDovL2NybC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3JsMHoGCCsG
# AQUFBwEBBG4wbDBFBggrBgEFBQcwAoY5aHR0cDovL2NydC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljVGltZVN0YW1waW5nQ0FSMzYuY3J0MCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAYEAsNwuyfpP
# NkyKL/bJT9XvGE8fnw7Gv/4SetmOkjK9hPPa7/Nsv5/MHuVus+aXwRFqM5Vu51qf
# rHTwnVExcP2EHKr7IR+m/Ub7PamaeWfle5x8D0x/MsysICs00xtSNVxFywCvXx55
# l6Wg3lXiPCui8N4s51mXS0Ht85fkXo3auZdo1O4lHzJLYX4RZovlVWD5EfwV6Ve1
# G9UMslnm6pI0hyR0Zr95QWG0MpNPP0u05SHjq/YkPlDee3yYOECNMqnZ+j8onoUt
# Z0oC8CkbOOk/AOoV4kp/6Ql2gEp3bNC7DOTlaCmH24DjpVgryn8FMklqEoK4Z3Io
# UgV8R9qQLg1dr6/BjghGnj2XNA8ujta2JyoxpqpvyETZCYIUjIs69YiDjzftt37r
# QVwIZsfCYv+DU5sh/StFL1x4rgNj2t8GccUfa/V3iFFW9lfIJWWsvtlC5XOOOQsw
# r1UmVdNWQem4LwrlLgcdO/YAnHqY52QwnBLiAuUnuBeshWmfEb5oieIYMIIGFDCC
# A/ygAwIBAgIQeiOu2lNplg+RyD5c9MfjPzANBgkqhkiG9w0BAQwFADBXMQswCQYD
# VQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0
# aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAw
# MFoXDTM2MDMyMTIzNTk1OVowVTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3Rp
# Z28gTGltaXRlZDEsMCoGA1UEAxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGlu
# ZyBDQSBSMzYwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQDNmNhDQatu
# givs9jN+JjTkiYzT7yISgFQ+7yavjA6Bg+OiIjPm/N/t3nC7wYUrUlY3mFyI32t2
# o6Ft3EtxJXCc5MmZQZ8AxCbh5c6WzeJDB9qkQVa46xiYEpc81KnBkAWgsaXnLURo
# YZzksHIzzCNxtIXnb9njZholGw9djnjkTdAA83abEOHQ4ujOGIaBhPXG2NdV8TNg
# FWZ9BojlAvflxNMCOwkCnzlH4oCw5+4v1nssWeN1y4+RlaOywwRMUi54fr2vFsU5
# QPrgb6tSjvEUh1EC4M29YGy/SIYM8ZpHadmVjbi3Pl8hJiTWw9jiCKv31pcAaeij
# S9fc6R7DgyyLIGflmdQMwrNRxCulVq8ZpysiSYNi79tw5RHWZUEhnRfs/hsp/fwk
# Xsynu1jcsUX+HuG8FLa2BNheUPtOcgw+vHJcJ8HnJCrcUWhdFczf8O+pDiyGhVYX
# +bDDP3GhGS7TmKmGnbZ9N+MpEhWmbiAVPbgkqykSkzyYVr15OApZYK8CAwEAAaOC
# AVwwggFYMB8GA1UdIwQYMBaAFPZ3at0//QET/xahbIICL9AKPRQlMB0GA1UdDgQW
# BBRfWO1MMXqiYUKNUoC6s2GXGaIymzAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/
# BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAECjAIMAYGBFUd
# IAAwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0
# aWdvUHVibGljVGltZVN0YW1waW5nUm9vdFI0Ni5jcmwwfAYIKwYBBQUHAQEEcDBu
# MEcGCCsGAQUFBzAChjtodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJs
# aWNUaW1lU3RhbXBpbmdSb290UjQ2LnA3YzAjBggrBgEFBQcwAYYXaHR0cDovL29j
# c3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBABLXeyCtDjVYDJ6BHSVY
# /UwtZ3Svx2ImIfZVVGnGoUaGdltoX4hDskBMZx5NY5L6SCcwDMZhHOmbyMhyOVJD
# wm1yrKYqGDHWzpwVkFJ+996jKKAXyIIaUf5JVKjccev3w16mNIUlNTkpJEor7edV
# JZiRJVCAmWAaHcw9zP0hY3gj+fWp8MbOocI9Zn78xvm9XKGBp6rEs9sEiq/pwzvg
# 2/KjXE2yWUQIkms6+yslCRqNXPjEnBnxuUB1fm6bPAV+Tsr/Qrd+mOCJemo06ldo
# n4pJFbQd0TQVIMLv5koklInHvyaf6vATJP4DfPtKzSBPkKlOtyaFTAjD2Nu+di5h
# ErEVVaMqSVbfPzd6kNXOhYm23EWm6N2s2ZHCHVhlUgHaC4ACMRCgXjYfQEDtYEK5
# 4dUwPJXV7icz0rgCzs9VI29DwsjVZFpO4ZIVR33LwXyPDbYFkLqYmgHjR3tKVkhh
# 9qKV2WCmBuC27pIOx6TYvyqiYbntinmpOqh/QPAnhDgexKG9GX/n1PggkGi9HCap
# Zp8fRwg8RftwS21Ln61euBG0yONM6noD2XQPrFwpm3GcuqJMf0o8LLrFkSLRQNwx
# PDDkWXhW+gZswbaiie5fd/W2ygcto78XCSPfFWveUOSZ5SqK95tBO8aTHmEa4lpJ
# VD7HrTEn9jb1EGvxOb1cnn0CMIIGgjCCBGqgAwIBAgIQNsKwvXwbOuejs902y8l1
# aDANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBK
# ZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRS
# VVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlv
# biBBdXRob3JpdHkwHhcNMjEwMzIyMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjBXMQsw
# CQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVT
# ZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIFJvb3QgUjQ2MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAiJ3YuUVnnR3d6LkmgZpUVMB8SQWbzFoVD9mU
# EES0QUCBdxSZqdTkdizICFNeINCSJS+lV1ipnW5ihkQyC0cRLWXUJzodqpnMRs46
# npiJPHrfLBOifjfhpdXJ2aHHsPHggGsCi7uE0awqKggE/LkYw3sqaBia67h/3awo
# qNvGqiFRJ+OTWYmUCO2GAXsePHi+/JUNAax3kpqstbl3vcTdOGhtKShvZIvjwulR
# H87rbukNyHGWX5tNK/WABKf+Gnoi4cmisS7oSimgHUI0Wn/4elNd40BFdSZ1Ewpu
# ddZ+Wr7+Dfo0lcHflm/FDDrOJ3rWqauUP8hsokDoI7D/yUVI9DAE/WK3Jl3C4LKw
# Ipn1mNzMyptRwsXKrop06m7NUNHdlTDEMovXAIDGAvYynPt5lutv8lZeI5w3MOlC
# ybAZDpK3Dy1MKo+6aEtE9vtiTMzz/o2dYfdP0KWZwZIXbYsTIlg1YIetCpi5s14q
# iXOpRsKqFKqav9R1R5vj3NgevsAsvxsAnI8Oa5s2oy25qhsoBIGo/zi6GpxFj+mO
# dh35Xn91y72J4RGOJEoqzEIbW3q0b2iPuWLA911cRxgY5SJYubvjay3nSMbBPPFs
# yl6mY4/WYucmyS9lo3l7jk27MAe145GWxK4O3m3gEFEIkv7kRmefDR7Oe2T1HxAn
# ICQvr9sCAwEAAaOCARYwggESMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKy
# A2bLMB0GA1UdDgQWBBT2d2rdP/0BE/8WoWyCAi/QCj0UJTAOBgNVHQ8BAf8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAE
# CjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1
# c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMDUG
# CCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEADr5lQe1oRLjlocXUEYfktzsljOt+2sgX
# ke3Y8UPEooU5y39rAARaAdAxUeiX1ktLJ3+lgxtoLQhn5cFb3GF2SSZRX8ptQ6Iv
# uD3wz/LNHKpQ5nX8hjsDLRhsyeIiJsms9yAWnvdYOdEMq1W61KE9JlBkB20XBee6
# JaXx4UBErc+YuoSb1SxVf7nkNtUjPfcxuFtrQdRMRi/fInV/AobE8Gw/8yBMQKKa
# Ht5eia8ybT8Y/Ffa6HAJyz9gvEOcF1VWXG8OMeM7Vy7Bs6mSIkYeYtddU1ux1dQL
# bEGur18ut97wgGwDiGinCwKPyFO7ApcmVJOtlw9FVJxw/mL1TbyBns4zOgkaXFnn
# fzg4qbSvnrwyj1NiurMp4pmAWjR+Pb/SIduPnmFzbSN/G8reZCL4fvGlvPFk4Uab
# /JVCSmj59+/mB2Gn6G/UYOy8k60mKcmaAZsEVkhOFuoj4we8CYyaR9vd9PGZKSin
# aZIkvVjbH/3nlLb0a7SBIkiRzfPfS9T+JesylbHa1LtRV9U/7m0q7Ma2CQ/t392i
# oOssXW7oKLdOmMBl14suVFBmbzrt5V5cQPnwtd3UOTpS9oCG+ZZheiIvPgkDmA8F
# zPsnfXW5qHELB43ET7HHFHeRPRYrMBKjkb8/IN7Po0d0hQoF4TeMM+zYAJzoKQnV
# KOLg8pZVPT8xggSRMIIEjQIBATBpMFUxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9T
# ZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMTI1NlY3RpZ28gUHVibGljIFRpbWUgU3Rh
# bXBpbmcgQ0EgUjM2AhA6UmoshM5V5h1l/MwS2OmJMA0GCWCGSAFlAwQCAgUAoIIB
# +TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0
# MDczMTIwNTI1OVowPwYJKoZIhvcNAQkEMTIEMCAmMxqOJxdVAxOvJf7zvkjyOGZm
# 9eowa/AUYByxD7PwhdDtQgGHWFoEz+/xxsRaHTCCAXoGCyqGSIb3DQEJEAIMMYIB
# aTCCAWUwggFhMBYEFPhgmBmm+4gs9+hSl/KhGVIaFndfMIGHBBTGrlTkeIbxfD1V
# EkiMacNKevnC3TBvMFukWTBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5n
# IFJvb3QgUjQ2AhB6I67aU2mWD5HIPlz0x+M/MIG8BBSFPWMtk4KCYXzQkDXEkd6S
# wULaxzCBozCBjqSBizCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJz
# ZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNU
# IE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkCEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEBBQAEggIAWDsY
# dUNgABSFIHvXa04Q/Tnvu7aKwvGTrnQv/ph6LGj/uqFyR7IUsvLaME+JuQ/RmFv/
# NDyDzY1FcU6tBu48E4b0DsVAEf5T83gE/DRsbp6aW+t2I9zdceDfOkmxhjpW/GUv
# ohjO7BODi4IbVl+35YgMK2mYUNh/O6fyUYnbvgwEx7jTQbNo7ZTqexBFdpx4TzFV
# Phxu1GS43nUqnBzs6NW0utqM8WLx7yuQ9VC+XZb787qQNwFkS5lY5K7mMm1gbGnI
# 49DLVt05jiN30ReI3bVrUO08pLimjYdgUUwafWDcfPZ7F3I17Q+VNd7fL5zQyZly
# Msjm3y9luyYN6OBcEUyzMgkpxvu6J4l8azFG0aXuYCU79Xtcu2cV1iAgl8QLgWk1
# X7lX44+f2fv8iWINS6ZXPpnyIh/r3MUp03Y8uv0lNwdggnZg84z3zelLcCcnYHYl
# ggM19LWfCp1Op69kwMymXc1MinPHM6FNBNoxdGs+LiRZ9SMOumxfwK6ELuNbCx8p
# vF/n4LImhMeqcliH88J0JNKYEdudvBtUNwCvvpxzHlIV1Qy9psVRZnjPXGbOM0MR
# XTuBIJ+b5QcozdwKZK+IgnbuCX+KlR2EavzLXIh+dopZkAwolg2zzyn2QknwkZuk
# hTg37OMqaRvor38+EIic5DZfusnq0xhtZwIH4Fs=
# SIG # End signature block
