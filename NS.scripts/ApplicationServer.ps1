# ApplicationServer.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSApplicationServer {
<#
.SYNOPSIS
  Create a new application server.
.DESCRIPTION
  Create a new application server.
.PARAMETER name
  Name for the application server. String of up to 64 alphanumeric characters, - and . and : are 
  allowed after first character. Example: 'myobject-5'.
.PARAMETER hostname
  Application server hostname. String of alphanumeric characters, valid range is from 2 to 255; 
  Each label must be between 1 and 63 characters long; - and . are allowed after the first and 
  before the last character. Example: 'example-1.com'.
.PARAMETER port
  Application server port number. Positive integer value up to 65535 representing TCP/IP port. Example: 1234.
.PARAMETER username
  Application server username. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER description
  Text description of application server. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER password
  Application server password. A password with few constraints. A string of up to 255 characters. Example: 'password_25-24'.
.PARAMETER server_type
  Application server type ({invalid|vss|vmware}). Possible values: 'vss', 'vmware'.
.PARAMETER metadata
  Key-value pairs that augment an application server's attributes. List of key-value pairs. Keys must be unique and non-empty. 
  When creating an object, values must be non-empty. When updating an object, an empty value causes the corresponding key to be removed.
.EXAMPLE
  C:\> New-NSApplicatinServer -name 10.18.237.115 -hostname TestCreate1

  name          id                                         description
  ----          --                                         -----------
  10.18.237.115 2928eada7f8dd99d3b000000000000000000000048

  This command will Create a new Application Server using the bare minimum fields required.
.EXAMPLE
  C:\> New-NSApplicationServer -name TestCreate2 -hostname 10.18.238.159 -port 1337 -username MyUser -password MySecret -description "My Wordy Description" -server_type vss

  name        id                                         description
  ----        --                                         -----------
  TestCreate2 2928eada7f8dd99d3b000000000000000000000049 My Wordy Description

  This command will Create a new Application Server using all of the fields.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string]  $name,

    [Parameter(Mandatory = $True)]
    [string]  $hostname,

    [int]     $port,

    [string]  $username,

    [string]  $description,

    [string]  $password,

    [ValidateSet('vss', 'vmware', 'cisco', 'container_node', 'stack_vision')]
    [string]  $server_type,

    [Object[]] $metadata
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
            ObjectName = 'ApplicationServer'
            APIPath = 'application_servers'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSApplicationServer {
<#
.SYNOPSIS
  List application servers.
.DESCRIPTION
  List application servers.
.PARAMETER id
  Identifier for the application server. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
  Name for the application server. 
  String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER hostname
  Application server hostname. String of alphanumeric characters, valid range is from 2 to 255; Each label must be 
  between 1 and 63 characters long; - and . are allowed after the first and before the last character. Example: 'example-1.com'.
.PARAMETER port 
  Application server port number. Positive integer value up to 65535 representing TCP/IP port. Example: 1234.
.PARAMETER username
  Application server username. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER description
  Text description of application server. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER server_type
  Application server type ({invalid|vss|vmware}). Possible values: 'vss', 'vmware'.
.PARAMETER metadata
  Key-value pairs that augment an application server's attributes. List of key-value pairs. Keys must be unique and non-empty. 
  When creating an object, values must be non-empty. When updating an object, an empty value causes the corresponding key to be removed.
.EXAMPLE
  C:\> Get-NSApplicatinServer

  name          id                                         description
  ----          --                                         -----------
  TestServer1   2928eada7f8dd99d3b000000000000000000000001 My First Test Server
  TestServer2   2928eada7f8dd99d3b000000000000000000000002 My Second Test Server
  TestServer3   2928eada7f8dd99d3b000000000000000000000003 My Second Test Server
  TestCreate1   2928eada7f8dd99d3b000000000000000000000020
  TestCreate2   2928eada7f8dd99d3b000000000000000000000046 My Wordy Description
  10.18.237.115 2928eada7f8dd99d3b000000000000000000000047 Adding A Description

  This command will retrieves list of current Application Server.
.EXAMPLE
  C:\> Get-NSApplicatinServer -name TestServer1

  name        id                                         description
  ----        --                                         -----------
  TestServer1 2928eada7f8dd99d3b000000000000000000000001 My First Test Server

  This command will retrieve a specific Application Server specified by name.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [Parameter(ParameterSetName='nonId')] [string]  $name,
    [Parameter(ParameterSetName='nonId')] [string]  $hostname,
    [Parameter(ParameterSetName='nonId')] [int]     $port,
    [Parameter(ParameterSetName='nonId')] [string]  $username,
    [Parameter(ParameterSetName='nonId')] [string]  $description,
    [Parameter(ParameterSetName='nonId')]                           [ValidateSet( 'vss', 'vmware', 'cisco', 'container_node', 'stack_vision')]
                                          [string]  $server_type,
    [Parameter(ParameterSetName='nonId')] [Object[]]$metadata
  )
process{
    $API = 'application_servers'
    $Param = @{ ObjectName = 'ApplicationServer'
                APIPath = 'application_servers'
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

function Set-NSApplicationServer {
<#
.SYNOPSIS
  Modify attributes of the specified application server.
.DESCRIPTION
  Modify attributes of the specified application server.
.PARAMETER id
  Identifier for the application server. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER name
  Name for the application server. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER hostname
  Application server hostname. String of alphanumeric characters, valid range is from 2 to 255; Each label must be between 1 and 63 characters 
  long; - and . are allowed after the first and before the last character. Example: 'example-1.com'.
.PARAMETER port
  Application server port number. Positive integer value up to 65535 representing TCP/IP port. Example: 1234.
.PARAMETER username
  Application server username. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER description
  Text description of application server. String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER password
  Application server password. A password with few constraints. A string of up to 255 characters. Example: 'password_25-24'.
.PARAMETER server_type
  Application server type ({invalid|vss|vmware}). Possible values: 'vss', 'vmware'.
.PARAMETER metadata
  Key-value pairs that augment an application server's attributes. List of key-value pairs. Keys must be unique and non-empty. 
  When creating an object, values must be non-empty. When updating an object, an empty value causes the corresponding key to be removed.
.EXAMPLE
  C:\> Set-NSApplicatinServer -id 2928eada7f8dd99d3b00000000000000000000004a -description "Adding A Description"

  name          id                                         description
  ----          --                                         -----------
  10.18.237.115 2928eada7f8dd99d3b00000000000000000000004a Adding A Description

  This command will add a description to an existing Application Server.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]                                       [string] $id,
                                                                              [string] $name,
                                                                              [string] $hostname,
    [ValidateRange(0,65535)]                                                  [int]    $port,
                                                                              [string] $username,
                                                                              [string] $description,
                                                                              [string] $password,
    [ValidateSet( 'vss', 'vmware', 'cisco', 'container_node', 'stack_vision')][string] $server_type,
                                                                              [Object[]] $metadata
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {   if ($key.ToLower() -ne 'id')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                  {   $RequestData.Add("$($var.name)", ($var.value))
                  }
            }
        }
        $Params = @{  ObjectName = 'ApplicationServer'
                      APIPath = 'application_servers'
                      Id = $id
                      Properties = $RequestData
                    }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSApplicationServer {
<#
.SYNOPSIS
  Delete the specified application server.
.DESCRIPTION
  Delete the specified application server.
.PARAMETER id
  Identifier for the application server.
.EXAMPLE
  C:\> Remove-NSApplicatinServer -id 2928eada7f8dd99d3b000000000000000000000048

  This command will remove Application Server using the supplied ID number.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]   [string]  $id
  )
process {
    $Params = @{  ObjectName = 'ApplicationServer'
                  APIPath = 'application_servers'
                  Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}