# InitiatorGroup.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSInitiatorGroup {
<#
.SYNOPSIS
  Create an initiator group used for authentication.
.DESCRIPTION
  Create an initiator group used for authentication.
.PARAMETER name
  Name of initiator group. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER description
  Text description of initiator group. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER access_protocol
  Initiator group access protocol. Possible values: 'iscsi', 'fc'.
.PARAMETER host_type
  Initiator group host type. Available options are auto and hpux. The default option is auto. This attribute will be 
  applied to all the initiators in the initiator group. Initiators with different host OSes
  should not be kept in the same initiator group having a non-default host type attribute.
.PARAMETER target_subnets
  List of target subnet labels. If specified, discovery and access to volumes will be restricted to the specified subnets.
.PARAMETER iscsi_initiators
  List of iSCSI initiators. When create/update iscsi_initiators, either iqn or ip_address is always required with label.
.PARAMETER fc_initiators
  List of FC initiators. When create/update fc_initiators, wwpn is required.
.PARAMETER app_uuid
  Application identifier of initiator group.
.EXAMPLE
  C:\> New-NSInitiatorGroup -name Testfolder-503 -access_protocol iscsi

  Name           Access_Protocol Description id
  ----           --------------- ----------- --
  Testfolder-503 iscsi                       0228eada7f8dd99d3b000000000000000000000059

  This command create a new initiator group.
#>
[CmdletBinding()]
param(  [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
        [Parameter(ParameterSetName='fc', Mandatory = $True)]
        [string] $name,

        [Parameter(ParameterSetName='iscsi')]
        [Parameter(ParameterSetName='fc')]
        [string] $description,

        [Parameter(ParameterSetName='iscsi', Mandatory = $True)]
        [Parameter(ParameterSetName='fc', Mandatory = $True)]
        [ValidateSet( 'iscsi', 'fc')]
        [string] $access_protocol,

        [Parameter(ParameterSetName='iscsi')]
        [Parameter(ParameterSetName='fc')]
        [string] $host_type,

        [Parameter(ParameterSetName='iscsi')]
        [Object[]] $target_subnets,

        [Parameter(ParameterSetName='iscsi')]
        [Object[]] $iscsi_initiators,

        [Parameter(ParameterSetName='fc')]
        [Object[]] $fc_initiators,

        [Parameter(ParameterSetName='iscsi')]
        [Parameter(ParameterSetName='fc')]
        [string] $app_uuid
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
            ObjectName = 'InitiatorGroup'
            APIPath = 'initiator_groups'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSInitiatorGroup {
<#
.SYNOPSIS
  List a set of initiator groups used for authentication.
.DESCRIPTION
  List a set of initiator groups used for authentication.
.DESCRIPTION
    List a set of initiator groups used for authentication.
.PARAMETER id
  Name of initiator group. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER name
  Name of initiator group.
.PARAMETER full_name
  Initiator group's full name.
.PARAMETER search_name
  Initiator group name used for search.
.PARAMETER description
  Text description of initiator group.
.PARAMETER access_protocol
  Initiator group access protocol.
.PARAMETER host_type
  Initiator group host type. Available options are auto and hpux. The default option is auto. 
  This attribute will be applied to all the initiators in the initiator group. Initiators with different host OSes
  should not be kept in the same initiator group having a non-default host type attribute.
.PARAMETER app_uuid
  Application identifier of initiator group.
.EXAMPLE
  C:\> Get-NSInitiatorGroup

  Name         Access_Protocol Description id
  ----         --------------- ----------- --
  test2        iscsi                       0228eada7f8dd99d3b000000000000000000000001
  test1        iscsi                       0228eada7f8dd99d3b000000000000000000000002
  test         iscsi                       0228eada7f8dd99d3b000000000000000000000003
  TestInit-981 iscsi           Test        0228eada7f8dd99d3b000000000000000000000019

  This command will retrieve the initiator groups from the array.
.EXAMPLE
  C:\> Get-NSInitiatorGroup -name test2

  Name  Access_Protocol Description id
  ----  --------------- ----------- --
  test2 iscsi                       0228eada7f8dd99d3b000000000000000000000001

  This command will retrieve a specific initiator group from the array by name.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')] [ValidatePattern('([0-9a-f]{42})')]    [string] $id,
    [Parameter(ParameterSetName='nonId')]                                     [string]$name,
    [Parameter(ParameterSetName='nonId')]                                     [string]$full_name,
    [Parameter(ParameterSetName='nonId')]                                     [string]$search_name,
    [Parameter(ParameterSetName='nonId')]                                     [string]$description,
    [Parameter(ParameterSetName='nonId')] [ValidateSet( 'iscsi', 'fc')]       [string]$access_protocol,
    [Parameter(ParameterSetName='nonId')]                                     [string]$host_type,
    [Parameter(ParameterSetName='nonId')]                                     [string]$app_uuid
  )
process{
    $API = 'initiator_groups'
    $Param = @{
      ObjectName = 'InitiatorGroup'
      APIPath = 'initiator_groups'
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
                {   $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Set-NSInitiatorGroup {
<#
.SYNOPSIS
  Modify the specified initiator group attributes.
.DESCRIPTION
  Modify the specified initiator group attributes.
.PARAMETER id <string>
  Identifier for initiator group.
.PARAMETER name [<string>]
  Name of initiator group.
.PARAMETER description [<string>]
  Text description of initiator group.
.PARAMETER host_type [<string>]
  Initiator group host type. Available options are auto and hpux. The default option is auto. 
  This attribute will be applied to all the initiators in the initiator group. Initiators with different host OSes
  should not be kept in the same initiator group having a non-default host type attribute.
.PARAMETER target_subnets [<Object[]>]
  List of target subnet labels. If specified, discovery and access to volumes will be restricted to the specified subnets.
.PARAMETER iscsi_initiators [<Object[]>]
  List of iSCSI initiators. When create/update iscsi_initiators, either iqn or ip_address is always required with label.
.PARAMETER fc_initiators [<Object[]>]
  List of FC initiators. When create/update fc_initiators, wwpn is required.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [string] $name,

    [string] $description,

    [string] $host_type,

    [Object[]] $target_subnets,

    [Object[]] $iscsi_initiators,

    [Object[]] $fc_initiators,

    [Nullable[bool]] $vp_override
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
            ObjectName = 'InitiatorGroup'
            APIPath = 'initiator_groups'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSInitiatorGroup {
<#
.SYNOPSIS
    Delete the specified initiator group.
.DESCRIPTION
    Delete the specified initiator group.
.PARAMETER id
  ID of the initiator group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE
  C:\> Remove-NSInitiatorGroup -id 0228eada7f8dd99d3b00000000000000000000005a

  This command will remove an initiator group specified by its ID.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')] [string]$id
    )
process {
    $Params = @{
        ObjectName = 'InitiatorGroup'
        APIPath = 'initiator_groups'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}

function Resolve-NSInitiatorGroupMerge {
<#
.SYNOPSIS
  Suggest a new LUN number to use for a specific Initiator Group
.DESCRIPTION
  Suggest a new LUN number to use for a specific Initiator Group
.PARAMETER id
  ID of the initiator group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER vol_id
  ID of the volume. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)] [ValidatePattern('([0-9a-f]{42})')] [string]  $id,
        [Parameter(ValueFromPipelineByPropertyName=$True)]                    [ValidatePattern('([0-9a-f]{42})')] [string]  $vol_id
  )
process{
    $Params = @{
        APIPath = 'initiator_groups'
        Action = 'suggest_lun'
        ReturnType = 'NsLunReturn'
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

function Test-NSInitiatorGroupLunAvailability {
<#
.SYNOPSIS
  Validate an LU number for the volume and initiator group combination.
.DESCRIPTION
  Validate an LU number for the volume and initiator group combination.
.PARAMETER id
  ID of the initiator group. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER vol_id
  ID of the volume. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER lun
  LU number to validate in decimal. Unsigned 64-bit integer. Example: 1234.
#>
[CmdletBinding()]
param ( [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)] [ValidatePattern('([0-9a-f]{42})')] [string]  $id,
        [Parameter(ValueFromPipelineByPropertyName=$True)]                    [ValidatePattern('([0-9a-f]{42})')] [string]  $vol_id,
        [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]                                     [long]    $lun
  )
process{  $Params = @{  APIPath = 'initiator_groups'
                        Action = 'validate_lun'
                        ReturnType = 'void'
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
