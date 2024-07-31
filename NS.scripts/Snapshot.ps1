# Snapshot.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSSnapshot {
<#
.SYNOPSIS
  Create a snapshot with the given attributes. 
.DESCRIPTION
  Create a snapshot with the given attributes. VSS application-synchronized snapshot must specify the 'writable' parameter and set it to 'true'.
.PARAMETER name 
  Name of snapshot.
.PARAMETER description
  Text description of snapshot.
.PARAMETER vol_id
  Name of the parent volume in which the snapshot will be created
.PARAMETER online
  Online state for a snapshot means it could be mounted for data restore.
.PARAMETER writable
  Allow snapshot to be writable. Mandatory and must be set to 'true' for VSS application synchronized snapshots.
.PARAMETER app_uuid
  Application identifier of snapshots.
.PARAMETER metadata
  Key-value pairs that augment a snapshot's attributes.
.PARAMETER agent_type
  External management agent type. Possible values: 'none', 'smis', 'vvol', 'openstack', 'openstackv2'.
.EXAMPLE
    C:\> PS:> New-nsSnapshot -name TestSnap-896 -vol_id 0628eada7f8dd99d3b000000000000000000000006

    name                                id                                            vol_name      schedule_name online        description
    ----                                --                                            --------      ------------- ------        -----------
    TestSnap-896                        0428eada7f8dd99d3b0000000000000007000000b6    TestVol4                    False

    This command will create a new Snapshot using the minimal number of parameters.
#>
[CmdletBinding()]
param(  [Parameter(Mandatory = $True)]  [string]  $name,
                                        [string]  $description,
        [Parameter(Mandatory = $True)]  [ValidatePattern('([0-9a-f]{42})')]
                                        [string]  $vol_id,
                                        [bool]    $online,
                                        [bool]    $writable,
                                        [string]  $app_uuid,
                                        [Object[]]$metadata,
    [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]
                                        [string]  $agent_type
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
            ObjectName = 'Snapshot'
            APIPath = 'snapshots'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSSnapshot {
<#
.SYNOPSIS
  Retrieve snapshot attributes.
.DESCRIPTION
  Retreive snapshot attributes.
.PARAMETER id
  Identifier for the snapshot.
.PARAMETER name
  Name of snapshot.
.PARAMETER description
  Text description of snapshot.
.PARAMETER size
  Size of volume at time of snapshot (in bytes).
.PARAMETER vol_name
        Name of the parent volume in which the snapshot belongs to.
.PARAMETER vol_id
        Parent volume ID.
.PARAMETER snap_collection_name
        Name of snapshot collection.
.PARAMETER snap_collection_id
        Identifier of snapshot collection.
.PARAMETER online
        Online state for a snapshot means it could be mounted for data restore.
.PARAMETER writable
        Allow snapshot to be writable. Mandatory and must be set to 'true' for VSS application synchronized snapshots.
.PARAMETER offline_reason
        Snapshot offline reason - possible entries: one of 'user', 'recovery', 'replica', 'over_volume_limit', 'over_snapshot_limit', 'over_volume_reserve', 'nvram_loss_recovery', 'pool_free_space_exhausted' .
.PARAMETER origin_name
        Origination group name.
.PARAMETER is_replica 
        Snapshot is a replica from upstream replication partner.
.PARAMETER is_unmanaged 
        Indicates whether the snapshot is unmanaged. The snapshot will not be deleted automatically unless the unmanaged cleanup feature is enabled.
.PARAMETER replication_status 
        Replication status.
.PARAMETER serial_number
        Identifier for the SCSI protocol.
.PARAMETER target_name 
        The iSCSI Qualified Name (IQN) or the Fibre Channel World Wide Node Name (WWNN) of the target snapshot.
.PARAMETER creation_time 
        Time when this snapshot was created.
.PARAMETER schedule_name 
        Name of protection schedule.
.PARAMETER schedule_id 
        Identifier of protection schedule.
.PARAMETER app_uuid 
        Application identifier of snapshots.
.PARAMETER new_data_valid
        Indicate the usage infomation is valid.
.PARAMETER agent_type
        External management agent type.
.PARAMETER vpd_t10
        The snapshot's T10 Vendor ID-based identifier.
.PARAMETER vpd_ieee0 
        The first 64 bits of the snapshots's EUI-64 identifier, encoded as a hexadecimal string.
.PARAMETER vpd_ieee1
        The last 64 bits of the snapshots's EUI-64 identifier, encoded as a hexadecimal string.
.EXAMPLE
    C:\> Set-NSSnapshot -id  0428eada7f8dd99d3b0000000000000007000000b7 -online $False

    name                                id                                            vol_name      schedule_name online        description
    ----                                --                                            --------      ------------- ------        -----------
    TestSnap-491                        0428eada7f8dd99d3b0000000000000007000000b7    TestVol4                    False

    This command will set the value of offline for the Snapshot specified by id.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [Parameter(ParameterSetName='nonId')] [string]  $name,
    [Parameter(ParameterSetName='nonId')] [string]  $description,
    [Parameter(ParameterSetName='nonId')] [long]    $size,
    [Parameter(ParameterSetName='nonId')] [string]  $vol_name,
    [Parameter(ParameterSetName='nonId')] 
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $vol_id,
    [Parameter(ParameterSetName='nonId')] [string]  $snap_collection_name,
    [Parameter(ParameterSetName='nonId')] 
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $snap_collection_id,
    [Parameter(ParameterSetName='nonId')] [bool]    $online,
    [Parameter(ParameterSetName='nonId')] [bool]    $writable,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'replica', 'recovery', 'nvram_loss_recovery', 'serial_number_collision', 'encryption_key_deleted', 'over_volume_usage_limit', 'over_folder_overdraft_limit', 'cache_unpin_in_progress', 'vvol_unbind', 'over_volume_limit', 'over_snapshot_limit', 'encryption_inactive', 'pool_free_space_exhausted', 'srep_unconfigured', 'user', 'over_volume_reserve', 'over_snapshot_reserve')]
                                          [string]  $offline_reason,

    [Parameter(ParameterSetName='nonId')] [string]  $origin_name,
    [Parameter(ParameterSetName='nonId')] [bool]    $is_replica,
    [Parameter(ParameterSetName='nonId')] [bool]    $is_unmanaged,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'fail', 'in_progress', 'pending', 'complete')]
                                          [string]  $replication_status,
    [Parameter(ParameterSetName='nonId')] [string]  $serial_number,
    [Parameter(ParameterSetName='nonId')] [string]  $target_name,
    [Parameter(ParameterSetName='nonId')] [long]    $creation_time,
    [Parameter(ParameterSetName='nonId')] [string]  $schedule_name,
    [Parameter(ParameterSetName='nonId')] 
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $schedule_id,
    [Parameter(ParameterSetName='nonId')] [string]  $app_uuid,
    [Parameter(ParameterSetName='nonId')] [bool]    $new_data_valid,
    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'smis', 'vvol', 'openstack', 'openstackv2', 'none')]
                                          [string]  $agent_type,
    [Parameter(ParameterSetName='nonId')] [string]  $vpd_t10,
    [Parameter(ParameterSetName='nonId')] [string]  $vpd_ieee0,
    [Parameter(ParameterSetName='nonId')] [string]  $vpd_ieee1
  )
process{
    $API = 'snapshots'
    $Param = @{
      ObjectName = 'Snapshot'
      APIPath = 'snapshots'
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
        {   if ($key.ToLower() -ne 'fields')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {   $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Set-NSSnapshot {
<#
.SYNOPSIS
  Modify snapshot attributes.
.DESCRIPTION
  Modify snapshot attributes.
.PARAMETER name
  Name of snapshot. String of up to 215 alphanumeric, hyphenated, colon, or period-separated characters; but 
  cannot begin with hyphen, colon or period. This type is used for object sets containing volumes, 
  snapshots, snapshot collections and protocol endpoints.
.PARAMETER description
  Text description of snapshot. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER vol_id
  Parent volume ID. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER online
  Online state for a snapshot means it could be mounted for data restore. Possible values: 'true', 'false'.
.PARAMETER writable
  Allow snapshot to be writable. Mandatory and must be set to 'true' for VSS application synchronized snapshots. Possible values: 'true', 'false'.
.PARAMETER app_uuid
  Application identifier of snapshots. String of up to 255 alphanumeric characters, hyphen, colon, dot and
  underscore are allowed. Example: 'rfc4122.943f7dc1-5853-497c-b530-f689ccf1bf18'.
.PARAMETER metadata
  Key-value pairs that augment a snapshot's attributes. List of key-value pairs. Keys must be unique and non-empty. 
  When creating an object, values must be non-empty. When updating an object, an empty value causes the corresponding key to be removed.
.PARAMETER agent_type
  External management agent type. Possible values: 'none', 'smis', 'vvol', 'openstack', 'openstackv2'.
.EXAMPLE
  C:\> Set-NSSnapshot -id  0428eada7f8dd99d3b0000000000000007000000b7 -online $False

  name                                id                                            vol_name      schedule_name online        description
  ----                                --                                            --------      ------------- ------        -----------
  TestSnap-491                        0428eada7f8dd99d3b0000000000000007000000b7    TestVol4                    False

  This command will set the value of offline for the Snapshot specified by id.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]
    [string]  $id,
    [string]  $name,
    [string]  $description,
    [ValidatePattern('([0-9a-f]{42})')]
    [string]  $vol_id,
    [bool]    $online,
    [bool]    $writable,
    [string]  $app_uuid,
    [Object[]]$metadata,
    [ValidateSet('none', 'smis', 'vvol', 'openstack', 'openstackv2')]
    [string]  $agent_type
  )
process {
        # Gather request params based on user input.
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
        $Params = @{
            ObjectName = 'Snapshot'
            APIPath = 'snapshots'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSSnapshot {
<#
.SYNOPSIS
  Remove a Snapshot from the system.
.DESCRIPTION
  Delete a snapshot with the given name or identifier.Snapshots cannot be deleted if they are in use by replication 
  on the affected volume. Replication must be paused or unconfigured in order for the deletion to proceed.
.PARAMETER id
  The ID of the snapshot to be removed.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process { $Params = @{  ObjectName = 'Snapshot'
                        APIPath = 'snapshots'
                        Id = $id
                    }
          Remove-NimbleStorageAPIObject @Params
  }
}

function New-NSSnapshotBulk {
<#
.SYNOPSIS
  Create a set of snapshots together
.DESCRIPTION
  Create a set of snapshots together. The snapvollit is an object that will contain details on each snapshot to create.
.PARAMETER snap_vol_list
  You will need to provide an object that contains all of the values of each individual snapshot. An example of this object might
  look like '@( @{ vol_id = "06004d300000000000007"; snap_name = 'vol1'; online = $false}, @{ vol_id = "06004d300000000000008"; 
  snap_name = 'vol2'; snap_description = 'vol2 snap'} )' . The valid subitems in each snapshot request are 'snap_name', 'snap_description', 
  'cookie', 'online', and 'writable'
.PARAMETER replicate
  Allow snapshot to be replicated. Possible values: 'true', 'false'.
.PARAMETER vss_snap
  VSS app-synchronized snapshot; we don't support creation of non app-synchronized sanpshots through this 
  interface; must be set to true. Possible values: 'true', 'false'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [Object[]]$snap_vol_list,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [bool]$replicate,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]    
    [bool]$vss_snap
  )
process{
    $Params = @{  APIPath     = 'snapshots'
                  Action      = 'bulk_create'
                  ReturnType  = 'NsSnapVolListReturn'
              }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
          {   $Params.Arguments.Add("$($var.name)", ($var.value))
          }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}


# SIG # Begin signature block
# MIIsWgYJKoZIhvcNAQcCoIIsSzCCLEcCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDmSTmFXYRf
# aW8tFqYPssLROqn4LW/lzhJbjJKBbA9qEbodC06gWKM5oygIl6NLOEeQvNS9x5HC
# pyMbY+US4qR2oIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhcwghoTAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQCTZrex2y0dZJTcmK/GmZSJJy2+63b072H2DW0f+Fj5xo0FlopYQmbwl
# Utz1hgihpa1UnCI2KxyJIIqsf9aTqSAwDQYJKoZIhvcNAQEBBQAEggGADfzIP3Ua
# pk2ZDfpaQC6r0XhgAXK1ywtK1z92BE94R3Bch2WPBbBFLz27fibF0gcxkyCZQS9H
# cfy/4g8toIeU5wpztzMEFW567HtalAWLjdUlzGmSIhTqR6mKUdexUZpOZTOUqjVb
# 2fEjoVLLfxV71wXt6LEJOhuasUIADExQtFQwOqe8Jv6+TbYftuhktn1xfYfGxDCQ
# l90sOi0gyFifrv0TG5DXASEjY3KXoOzJx2SyaBbn/jpB4SItJqss9rR6tut0EAWb
# eSHHZMyK+Gcov9CVWYB9ErY1pmDDyZLV29rlxkPhTdAQ0mbDkyelNLi3WWJlyXHt
# StryPE9oC/LahBVKvfHE2PCFqXBOckdR6y6rUTHCr+syYHGy0eufSFaCHgQoLXCv
# hoPiJZGfYE2MVtXbWloZW2ZYi6whaQ+awQ2YF3pg+PruyXF8iIkYkHBy7AOPw4b2
# 500iTL93hN/K0lfhAz2tc/6H5za1HacbXqi+/i8cf2xcGnx8mJMNjib3oYIXYDCC
# F1wGCisGAQQBgjcDAwExghdMMIIXSAYJKoZIhvcNAQcCoIIXOTCCFzUCAQMxDzAN
# BglghkgBZQMEAgIFADCBhwYLKoZIhvcNAQkQAQSgeAR2MHQCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDBOdCThFFR6HTyXfKXxjGq/Afb3whseNyzoyoMT
# AFWNyyaKqMCiz6cM1e6p0ZEZKAgCECvd6FEf1jR3/ZEGdtkqzo4YDzIwMjQwNzMx
# MjA1OTQyWqCCEwkwggbCMIIEqqADAgECAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCSqG
# SIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwHhcNMjMwNzE0MDAwMDAwWhcNMzQxMDEzMjM1OTU5WjBI
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xIDAeBgNVBAMT
# F0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIzMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAo1NFhx2DjlusPlSzI+DPn9fl0uddoQ4J3C9Io5d6OyqcZ9xiFVjB
# qZMRp82qsmrdECmKHmJjadNYnDVxvzqX65RQjxwg6seaOy+WZuNp52n+W8PWKyAc
# wZeUtKVQgfLPywemMGjKg0La/H8JJJSkghraarrYO8pd3hkYhftF6g1hbJ3+cV7E
# Bpo88MUueQ8bZlLjyNY+X9pD04T10Mf2SC1eRXWWdf7dEKEbg8G45lKVtUfXeCk5
# a+B4WZfjRCtK1ZXO7wgX6oJkTf8j48qG7rSkIWRw69XloNpjsy7pBe6q9iT1Hbyb
# HLK3X9/w7nZ9MZllR1WdSiQvrCuXvp/k/XtzPjLuUjT71Lvr1KAsNJvj3m5kGQc3
# AZEPHLVRzapMZoOIaGK7vEEbeBlt5NkP4FhB+9ixLOFRr7StFQYU6mIIE9NpHnxk
# TZ0P387RXoyqq1AVybPKvNfEO2hEo6U7Qv1zfe7dCv95NBB+plwKWEwAPoVpdceD
# ZNZ1zY8SdlalJPrXxGshuugfNJgvOuprAbD3+yqG7HtSOKmYCaFxsmxxrz64b5bV
# 4RAT/mFHCoz+8LbH1cfebCTwv0KCyqBxPZySkwS0aXAnDU+3tTbRyV8IpHCj7Arx
# ES5k4MsiK8rxKBMhSVF+BmbTO77665E42FEHypS34lCh8zrTioPLQHsCAwEAAaOC
# AYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAf
# BgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUpbbvE+fv
# zdBkodVWqWUxo97V40kwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFt
# cGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVT
# dGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAgRrW3qCptZgXvHCNT4o8
# aJzYJf/LLOTN6l0ikuyMIgKpuM+AqNnn48XtJoKKcS8Y3U623mzX4WCcK+3tPUiO
# uGu6fF29wmE3aEl3o+uQqhLXJ4Xzjh6S2sJAOJ9dyKAuJXglnSoFeoQpmLZXeY/b
# JlYrsPOnvTcM2Jh2T1a5UsK2nTipgedtQVyMadG5K8TGe8+c+njikxp2oml101Dk
# RBK+IA2eqUTQ+OVJdwhaIcW0z5iVGlS6ubzBaRm6zxbygzc0brBBJt3eWpdPM43U
# jXd9dUWhpVgmagNF3tlQtVCMr1a9TMXhRsUo063nQwBw3syYnhmJA+rUkTfvTVLz
# yWAhxFZH7doRS4wyw4jmWOK22z75X7BC1o/jF5HRqsBV44a/rCcsQdCaM0qoNtS5
# cpZ+l3k4SF/Kwtw9Mt911jZnWon49qfH5U81PAC9vpwqbHkB3NpE5jreODsHXjlY
# 9HxzMVWggBHLFAx+rrz+pOt5Zapo1iLKO+uagjVXKBbLafIymrLS2Dq4sUaGa7oX
# /cR3bBVsrquvczroSUa31X/MtjjA2Owc9bahuEMs305MfR5ocMB3CtQC4Fxguyj/
# OOVSWtasFyIjTvTs0xf7UGv/B3cfcZdEQcm4RtNsMnxYL2dHZeUbc7aZ+WssBkbv
# QR7w8F/g29mtkIBEr4AQQYowggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5b
# MA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5
# NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPB
# PXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/
# nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLc
# Z47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mf
# XazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3N
# Ng1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yem
# j052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g
# 3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD
# 4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDS
# LFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwM
# O1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU
# 7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0j
# BBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8E
# PDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# DQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPO
# vxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQ
# TGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWae
# LJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPBy
# oyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfB
# wWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8l
# Y5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/
# O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbb
# bxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3
# OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBl
# dkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt
# 1nz8MIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwF
# ADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElE
# IFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKn
# JS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/W
# BTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHi
# LQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhm
# V1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHE
# tWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6
# MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mX
# aXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZ
# xd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfh
# vbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvl
# EFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn1
# 5GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNV
# HQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4Ix
# LVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAA
# MA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzs
# hV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre
# +i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8v
# C6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38
# dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNr
# Iv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDhjCCA4ICAQEw
# dzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCWCGSAFlAwQCAgUAoIHhMBoGCSqG
# SIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQwNzMxMjA1
# OTQyWjArBgsqhkiG9w0BCRACDDEcMBowGDAWBBRm8CsywsLJD4JdzqqKycZPGZzP
# QDA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCDS9uRt7XQizNHUQFdoQTZvgoraVZqu
# MxavTRqa1Ax4KDA/BgkqhkiG9w0BCQQxMgQwBfIClEI53f1zH23k4d6GHLmnKOxF
# SUkbhLw+TDoEcdf2E0TLO5R2ZpxByGt00fbvMA0GCSqGSIb3DQEBAQUABIICAJ2V
# EHf5TrQGggIIGoRD82SnS+60QmrruQ490ijluyyJDYfSbNFSAdX2CDtqMajfSlKJ
# IyyI7tuSoz3XyHB7gsUopdXCchN04cwRnwRl14SK2Cff85BZOCEXjgj7TQBZCMlZ
# G8vihqRsEw6m7gVR9ROhC1+9Cq2Q9ES/qgPflI7oLJQVXUjqoEQHgvLEFjEBAPdu
# pO5eAtVGHvP+AHv3iCoVjcWtcEz8V39k49BISe8aKMFF4FtCqxtWsGseDsGaDHiJ
# lfwN7qrSRTdgFC61tm4b7LF0dWVAoSUZ/GBbQ+Lc8+i19seuWa9VStzsrQuOznLK
# fFIwLgyIVIJWBzf1dnnRk+vhzjXsJBScTRFl9rlbh//Kd5/KoSYiNEq2sVhv64cT
# BQOolIh6pyD9dRxSY3gtfYTQwiff1QRPptv6tAp2OXnYTP2Ddd6nebsMEfv+Tr+T
# AVuxma77F7OTTFWImbB9QnSuh+hcMKJ5H7OTzSGS/5E1xSq3894dSFm0ewZf7dzZ
# aEh0XJayucvKgQg26ADK6ryIGSclpmB9Nuethdc2BNxkKXMisiBDlPfF5QKTvP7d
# wMvHqVvFCoIDpuU+ClbW05+yBKWT0k9Tnfq5vzLvl28rQACseLHjyLUfThP4DccX
# RRziEXA9sBWzPX7E0qsoDb71mFy8+0q33Dz2/o8P
# SIG # End signature block
