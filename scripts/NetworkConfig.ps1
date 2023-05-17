# NetworkConfig.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSNetworkConfig {
<#
.SYNOPSIS
  Creates a network configuration whose role is 'draft'. Modify the draft configuration in stages until it is ready to be validated and activated.
.DESCRIPTION
  Creates a network configuration whose role is 'draft'. Modify the draft configuration in stages until it is ready to be validated and activated.
.PARAMETER name
  Name of the network configuration. Use the name 'draft' when creating a draft configuration. Possible values: 'active', 'backup', 'draft'.
.PARAMETER mgmt_ip
  Management IP for the Group. Four numbers in the range [0,255] separated by periods. Example: '128.0.0.1'.
.PARAMETER iscsi_automatic_connection_method
  Whether automatic connection method is enabled. Enabling this means means redirecting connections from the 
  specified iSCSI discovery IP to the best data IP based on connection counts. Possible values: 'true', 'false'.
.PARAMETER iscsi_connection_rebalancing
  Whether rebalancing is enabled. Enabling this means rebalancing iSCSI connections by periodically 
  breaking existing connections that are out-of-balance, allowing the host to reconnect to a more 
  appropriate data IP. Possible values: 'true', 'false'.
.PARAMETER route_list
  List of static routes. List of route configs. Use the (Get-NSNetworkConfig).route_list 
  to extract an example of what the object format will be.
.PARAMETER subnet_list
  List of subnet configs. List of subnet configs. Use the (Get-NSNetworkConfig).subnet_list
  to extract an example of what the object format will be.
.PARAMETER array_list
  List of array network configs. Use the (Get-NSNetworkConfig).array_list to extract an example of what the object format will be.
#>
[CmdletBinding()]
param(  [Parameter(Mandatory = $True)]
        [ValidateSet( 'backup', 'draft', 'active')]
        [string] $name,

        [Parameter(Mandatory = $True)]
        [string] $mgmt_ip,

        [Parameter(Mandatory = $True)]    
        [bool] $iscsi_automatic_connection_method,

        [Parameter(Mandatory = $True)]
        [bool] $iscsi_connection_rebalancing,

        [Parameter(Mandatory = $True)]
        [Object[]] $route_list,

        [Parameter(Mandatory = $True)]
        [Object[]] $subnet_list,

        [Parameter(Mandatory = $True)]
        [Object[]] $array_list
  )
process { # Gather request params based on user input.
          $RequestData = @{}
          $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
          foreach ($key in $ParameterList.keys)
            { $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
              if ($var -and ($PSBoundParameters.ContainsKey($key)))
                { $RequestData.Add("$($var.name)", ($var.value))
                }
            }
          $Params = @{  ObjectName = 'NetworkConfig'
                        APIPath = 'network_configs'
                        Properties = $RequestData
                    }
          $ResponseObject = New-NimbleStorageAPIObject @Params
          return $ResponseObject
        }
}

function Get-NSNetworkConfig {
<#
.SYNOPSIS
  List a set of network configurations or a single network configuration.
.DESCRIPTION
  List a set of network configurations or a single network configuration.
.PARAMETER id
  Identifier for network configuration.
.PARAMETER name
  Name of the network configuration. Use the name 'draft' when creating a draft configuration.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{2})([0-9a-f]{16})([0-9a-f]{16})([0-9a-f]{8})')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'backup', 'draft', 'active')]
    [string]$name
  )
process
  { $API = 'network_configs'
    $Param = @{ ObjectName = 'NetworkConfig'
                APIPath = 'network_configs'
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

function Set-NSNetworkConfig {
<#
.SYNOPSIS
  Modify attributes of a network configuration.
.DESCRIPTION
  Modify attributes of a network configuration.
.PARAMETER 
.PARAMETER id
  Identifier for network configuration.
.PARAMETER name
  Name of the network configuration. Use the name 'draft' when creating a draft configuration.
.PARAMETER mgmt_ip
  Management IP address for the Group.
.PARAMETER secondary_mgmt_ip
  Secondary management IP address for the Group.
.PARAMETER role [<string>]
  Role of network configuration.
.PARAMETER iscsi_automatic_connection_method
  Whether automatic connection method is enabled. Enabling this means means redirecting connections from 
  the specified iSCSI discovery IP address to the best data IP address based on connection counts.
.PARAMETER iscsi_connection_rebalancing
  Whether rebalancing is enabled. Enabling this means rebalancing iSCSI connections by periodically breaking 
  existing connections that are out-of-balance, allowing the host to reconnect to a more appropriate
  data IP address.
.PARAMETER route_list
  List of static routes.
.PARAMETER subnet_list
  List of subnet configs.
.PARAMETER array_list
  List of array network configs.
.PARAMETER group_leader_array
  Name of the group leader array.
.PARAMETER creation_time
  Time when this net configuration was created.
.PARAMETER last_modified
  Time when this network configuration was last modified.
.PARAMETER active_since
  Start time of activity.
.PARAMETER last_active
  Time of last activity.
.PARAMETER ignore_validation_mask
  Indicates whether to ignore the validation.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [string]  $id,

        [Parameter(Mandatory = $True)]
        [ValidateSet( 'backup', 'draft', 'active')]
        [string] $name,

        [Parameter(Mandatory = $True)]
        [string] $mgmt_ip,

        [string] $secondary_mgmt_ip,

        [Parameter(Mandatory = $True)]
        [bool] $iscsi_automatic_connection_method,

        [Parameter(Mandatory = $True)]
        [bool] $iscsi_connection_rebalancing,

        [Parameter(Mandatory = $True)]
        [Object[]] $route_list,

        [Parameter(Mandatory = $True)]
        [Object[]] $subnet_list,

        [Parameter(Mandatory = $True)]
        [Object[]] $array_list,

        [long] $ignore_validation_mask
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {   if ($key.ToLower() -ne 'id')
              { $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                  { $RequestData.Add("$($var.name)", ($var.value))
                  }
              }
        }
        $Params = @{  ObjectName = 'NetworkConfig'
                      APIPath = 'network_configs'
                      Id = $id
                      Properties = $RequestData
                  }
        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSNetworkConfig {
<#
.SYNOPSIS
  Delete a network configuration. This operation is only valid for network configurations whose role is 'draft'.
.DESCRIPTION
  Delete a network configuration. This operation is only valid for network configurations whose role is 'draft'.
.PARAMETER id
  Identifier for network configuration. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [string]$id
    )
process { $Params = @{  ObjectName = 'NetworkConfig'
                        APIPath = 'network_configs'
                        Id = $id
                    }
          Remove-NimbleStorageAPIObject @Params
        }
}

function Initialize-NSNetworkConfig {
<#
.SYNOPSIS
  Activate a network configuration.
.DESCRIPTION
  Activate a network configuration.
.PARAMETER id
  ID of the netconfig to activate.
.PARAMETER ignore_validation_mask
  Whether to ignore validation or not. Whether to ignore validation or not. Unsigned 64-bit integer. Example: 1234.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]    
    [long]$ignore_validation_mask
  )
process{
    $Params = @{
        APIPath = 'network_configs'
        Action = 'activate_netconfig'
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

function Test-NSNetworkConfig {
<#
.SYNOPSIS
  Validate a network configuration.
.DESCRIPTION
  Validate a network configuration.
.PARAMETER id
  ID of the netconfig to validate.
.PARAMETER ignore_validation_mask
  hether to ignore validation or not. Whether to ignore validation or not. Unsigned 64-bit integer. Example: 1234.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [long]$ignore_validation_mask
  )
process{
    $Params = @{
        APIPath = 'network_configs'
        Action = 'validate_netconfig'
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
