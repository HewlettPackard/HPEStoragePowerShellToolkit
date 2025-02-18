# Controller.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function Get-NSController {
<#
.SYNOPSIS
    List of controllers or controller attributes.
.DESCRIPTION
    List of controllers or controller attributes.
.PARAMETER id
  Identifier of the controller. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
  Name of the controller. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER array_name
  Name of the array containing this controller. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.	
.PARAMETER array_id
  Rest ID of the array containing this controller. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER serial
  Serial number for this controller. Example: 'AC-109084-C2'.
.PARAMETER model
  Model of this controller. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER hostname
  Host name for the controller. 
  String of up to 63 alphanumeric and can include hyphens characters but cannot start with hyphen.
.PARAMETER support_address
  IP address used for support. 
  Four numbers in the range [0,255] separated by periods. Example: '128.0.0.1'.
.PARAMETER support_netmask
  IP netmask used for support. 
  A netmask expressed as a 32 bit binary value must have the highest bit set (2^31) and the 
  lowest bit clear (2^0) with the first zero followed by only zeros. Example: '255.255.255.0'.
.PARAMETER support_nic
  Network card used for support. Name for a network card.
.PARAMETER power_status
  Overall power supply status for the controller. 
  Possible values: 'ps_unknown', 'ps_okay', 'ps_alerted', 'ps_failed'.
.PARAMETER fan_status
  Overall fan status for the controller. 
  Possible values: 'fan_unknown', 'fan_okay', 'fan_alerted', 'fan_failed'.
.PARAMETER temperature_status
  Overall temperature status for the controller. 
  Possible values: 'temperature_unknown', 'temperature_okay', 'temperature_alerted', 'temperature_failed'.
.PARAMETER power_supplies
  Status for each power supply in the controller. A list of sensor information.
.PARAMETER fans
  Status for each fan in the controller. A list of sensor information.
.PARAMETER temperature_sensors
  Status for temperature sensor in the controller.
.PARAMETER ctrlr_side
  Identifies which controller this is on its array.
.PARAMETER state
  Indicates whether this controller is active or not.
.EXAMPLE
  C:\> Get-NSController

  id                                         name array_name   array_id
  --                                         ---- ----------   --------
  c328eada7f8dd99d3b000000000000000100000000 A    chapi-afa-a1 0928eada7f8dd99d3b000000000000000000000001
  c328eada7f8dd99d3b000000000000000100000001 B    chapi-afa-a1 0928eada7f8dd99d3b000000000000000000000001

  This command will retrieve the controller status.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]     [string] $id,
    [Parameter(ParameterSetName='nonId')]   [string]$name,
    [Parameter(ParameterSetName='nonId')]   [string]$array_name,
    [Parameter(ParameterSetName='nonId')]                               [ValidatePattern('([0-9a-f]{42})')]
                                            [string]$array_id,
    [Parameter(ParameterSetName='nonId')]   [string]$serial,
    [Parameter(ParameterSetName='nonId')]   [string]$model,
    [Parameter(ParameterSetName='nonId')]   [string]$hostname,
    [Parameter(ParameterSetName='nonId')]   [string]$support_address,
    [Parameter(ParameterSetName='nonId')]   [string]$support_netmask,
    [Parameter(ParameterSetName='nonId')]   [string]$support_nic,
    [Parameter(ParameterSetName='nonId')]                               [ValidateSet( 'ps_alerted', 'ps_okay', 'ps_failed', 'ps_unknown')]
                                            [string]$power_status,
    [Parameter(ParameterSetName='nonId')]                               [ValidateSet( 'fan_failed', 'fan_okay', 'fan_alerted', 'fan_unknown')]
                                            [string]$fan_status,
    [Parameter(ParameterSetName='nonId')]                               [ValidateSet( 'temperature_unknown', 'temperature_alerted', 'temperature_okay', 'temperature_fail')]
                                            [string]$temperature_status,
    [Parameter(ParameterSetName='nonId')]                               [ValidateSet( 'A', 'B')]
                                            [string]$ctrlr_side,
    [Parameter(ParameterSetName='nonId')]                               [ValidateSet( 'start_active', 'start_standby', 'stale', 'standby', 'active', 'solo', 'none')]
                                            [string]$state
  )
process{
    $API = 'controllers'
    $Param = @{
      ObjectName = 'Controller'
      APIPath = 'controllers'
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
