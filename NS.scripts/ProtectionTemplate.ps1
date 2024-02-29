# ProtectionTemplate.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSProtectionTemplate {
<#
.SYNOPSIS
  Create a protection template with given attributes.
.DESCRIPTION
  Create a protection template with given attributes.
.PARAMETER name
  User provided identifier.
.PARAMETER description
  Text description of protection template.
.PARAMETER app_sync
  Application synchronization ({none|vss|vmware|generic}).
.PARAMETER app_server
  Application server hostname.This is only required when the app_sync is set to vss AND the application is 
  NOT running within a Windows Failover Cluster
.PARAMETER app_id
  Application ID running on the server. Application ID can only be specified if application synchronization is VSS.
.PARAMETER app_cluster_name
  If the application is running within a Windows cluster environment then this is the cluster name.
  This is only required when the app_sync is set to vss AND the application is running within a Windows Failover Cluster
.PARAMETER app_service_name
  If the application is running within a Windows cluster environment then this is the instance name of the service running within the cluster environment.
  This is only required when the app_sync is set to vss AND the application is running within a Windows Failover Cluster
.PARAMETER vcenter_hostname
  VMware vCenter hostname. Custom port number can be specified with vCenter hostname using :.
  This is only required when the app_sync is set to vmware.
.PARAMETER vcenter_username
  VMware vCenter username. This is only required when the app_sync is set to vmware.
.PARAMETER vcenter_password
  VMware vCenter password. This is only required and valid when the app_sync is set to vmware.
.PARAMETER agent_hostname
  Generic Backup agent hostname. Custom port number can be specified with agent hostname using \\":\\".
  This is not required when the app_sync method is set to vmware or vss or none.
.PARAMETER agent_username
  Generic Backup agent username. This is not required when the app_sync method is set to vmware or vss or none.
.PARAMETER agent_password
  Generic Backup agent password. This is not required when the app_sync method is set to vmware or vss or none.
#>
[CmdletBinding()]
param(
  [Parameter(ParameterSetName='none', Mandatory = $True)]
  [Parameter(ParameterSetName='vmware', Mandatory = $True)]
  [Parameter(ParameterSetName='generic', Mandatory = $True)]
  [Parameter(ParameterSetName='vss-standalone', Mandatory = $True)]
  [Parameter(ParameterSetName='vss-cluster', Mandatory = $True)]    [string]  $name,

  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]
  [Parameter(ParameterSetName='vss-standalone')]
  [Parameter(ParameterSetName='vss-cluster')]                       [string]  $description,

  [Parameter(ParameterSetName='none', Mandatory = $True)]
  [Parameter(ParameterSetName='generic', Mandatory = $True)]
  [Parameter(ParameterSetName='vmware', Mandatory = $True)]
  [Parameter(ParameterSetName='vss-standalone', Mandatory = $True)]
  [Parameter(ParameterSetName='vss-cluster', Mandatory = $True)]
  [ValidateSet( 'vss', 'vmware', 'none', 'generic')]                [string]  $app_sync,

  [Parameter(ParameterSetName='vss-standalone', Mandatory = $True)] [string]  $app_server,

  [Parameter(ParameterSetName='vss-standalone', Mandatory = $True)]
  [Parameter(ParameterSetName='vss-cluster', Mandatory = $True)]                              [ValidateSet( 'exchange_dag', 'sql2012', 'sql2014', 'inval', 'sql2005', 'sql2016', 'exchange', 'sql2017', 'sql2008', 'hyperv')]
                                                                    [string]  $app_id,
  [Parameter(ParameterSetName='vss-cluster', Mandatory = $True)]    [string]  $app_cluster_name,
  [Parameter(ParameterSetName='vss-cluster', Mandatory = $True)]    [string]  $app_service_name,
  [Parameter(ParameterSetName='vmware', Mandatory = $True)]         [string]  $vcenter_hostname,
  [Parameter(ParameterSetName='vmware', Mandatory = $True)]         [string]  $vcenter_username,
  [Parameter(ParameterSetName='vmware', Mandatory = $True)]         [string]  $vcenter_password,
  [Parameter(ParameterSetName='generic', Mandatory = $True)]        [string]  $agent_hostname,
  [Parameter(ParameterSetName='generic', Mandatory = $True)]        [string]  $agent_username,
  [Parameter(ParameterSetName='generic', Mandatory = $True)]        [string]  $agent_password
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
            ObjectName = 'ProtectionTemplate'
            APIPath = 'protection_templates'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSProtectionTemplate {
<#
.SYNOPSIS
  Read a set of protection templates or a single template.
.DESCRIPTION
  Read a set of protection templates or a single template.
.PARAMETER id
  Identifier for protection template.
.PARAMETER name
  User provided identifier.
.PARAMETER full_name
  Fully qualified name of protection template.
.PARAMETER search_name
  Name of protection template used for object search.
.PARAMETER description
  Text description of protection template.
.PARAMETER app_sync
  Application synchronization ({none|vss|vmware|generic}).
.PARAMETER app_server
  Application server hostname.
.PARAMETER app_id
  Application ID running on the server. Application ID can only be specified if application synchronization is VSS.
.PARAMETER app_cluster_name
  If the application is running within a Windows cluster environment then this is the cluster name.
.PARAMETER app_service_name
  If the application is running within a Windows cluster environment then this is the instance name of the service running within the cluster environment.
.PARAMETER vcenter_hostname
  VMware vCenter hostname. Custom port number can be specified with vCenter hostname using :.
.PARAMETER vcenter_username
  VMware vCenter username.
.PARAMETER agent_hostname
  Generic Backup agent hostname. Custom port number can be specified with agent hostname using \\":\\".
.PARAMETER agent_username
  Generic Backup agent username.
.EXAMPLE
  C:\> Get-NSProtectionTemplate

  agent_hostname   :
  agent_password   :
  agent_username   :
  app_cluster_name :
  app_id           :
  app_server       :
  app_service_name :
  app_sync         : none
  creation_time    : 0
  description      : Provides daily snapshots retained for 30 days
  full_name        : Retain-30Daily
  id               : 1228eada7f8dd99d3b000000000000000000000001
  last_modified    : 0
  name             : Retain-30Daily
  repl_priority    : normal
  schedule_list    : {@{at_time=0; days=all; disable_appsync=False; downstream_partner=; downstream_partner_id=; downstream_partner_name=;
                    id=0c28eada7f8dd99d3b000000000000000000000001; name=daily; num_retain=30; num_retain_replica=1; period=1; period_unit=days; repl_alert_thres=86400;
                    replicate_every=0; schedule_id=0c28eada7f8dd99d3b000000000000000000000001; schedule_name=daily; schedule_type=regular; skip_db_consistency_check=False;
                    snap_verify=False; until_time=86399}}
  search_name      : Retain-30Daily
  vcenter_hostname :
  vcenter_username :

  agent_hostname   :
  agent_password   :
  agent_username   :
  app_cluster_name :
  app_id           :
  app_server       :
  app_service_name :
  app_sync         : none
  creation_time    : 0
  description      : Provides daily snapshots retained for 90 days
  full_name        : Retain-90Daily
  id               : 1228eada7f8dd99d3b000000000000000000000002
  last_modified    : 0
  name             : Retain-90Daily
  repl_priority    : normal
  schedule_list    : {@{at_time=0; days=all; disable_appsync=False; downstream_partner=; downstream_partner_id=; downstream_partner_name=;
                    id=0c28eada7f8dd99d3b000000000000000000000002; name=daily; num_retain=90; num_retain_replica=1; period=1; period_unit=days; repl_alert_thres=86400;
                    replicate_every=0; schedule_id=0c28eada7f8dd99d3b000000000000000000000002; schedule_name=daily; schedule_type=regular; skip_db_consistency_check=False;
                    snap_verify=False; until_time=86399}}
  search_name      : Retain-90Daily
  vcenter_hostname :
  vcenter_username :

  This command will retrieve the Protection Template from the array.
.EXAMPLE
  C:\> Get-NSProtectionTemplate -name Retain-90Daily

  agent_hostname   :
  agent_password   :
  agent_username   :
  app_cluster_name :
  app_id           :
  app_server       :
  app_service_name :
  app_sync         : none
  creation_time    : 0
  description      : Provides daily snapshots retained for 90 days
  full_name        : Retain-90Daily
  id               : 1228eada7f8dd99d3b000000000000000000000002
  last_modified    : 0
  name             : Retain-90Daily
  repl_priority    : normal
  schedule_list    : {@{at_time=0; days=all; disable_appsync=False; downstream_partner=; downstream_partner_id=; downstream_partner_name=;
                    id=0c28eada7f8dd99d3b000000000000000000000002; name=daily; num_retain=90; num_retain_replica=1; period=1; period_unit=days; repl_alert_thres=86400;
                    replicate_every=0; schedule_id=0c28eada7f8dd99d3b000000000000000000000002; schedule_name=daily; schedule_type=regular; skip_db_consistency_check=False;
                    snap_verify=False; until_time=86399}}
  search_name      : Retain-90Daily
  vcenter_hostname :
  vcenter_username :
    
  This command will retrieve a specific Protection Template from the array by name.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]    [ValidatePattern('([0-9a-f]{42})')]   [string] $id,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]
    [Parameter(ParameterSetName='vss-standalone')]
    [Parameter(ParameterSetName='vss-cluster')]                                 [string]$name,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]
    [Parameter(ParameterSetName='vss-standalone')]
    [Parameter(ParameterSetName='vss-cluster')]                                 [string]$full_name,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]
    [Parameter(ParameterSetName='vss-standalone')]
    [Parameter(ParameterSetName='vss-cluster')]                                 [string]$search_name,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]
    [Parameter(ParameterSetName='vss-standalone')]
    [Parameter(ParameterSetName='vss-cluster')]                                 [string]$description,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]
    [Parameter(ParameterSetName='vss-standalone')]
    [Parameter(ParameterSetName='vss-cluster')] [ValidateSet( 'vss', 'vmware', 'none', 'generic')]
                                                                                [string]$app_sync,
    [Parameter(ParameterSetName='vss-standalone')]
    [Parameter(ParameterSetName='vss-cluster')]                                 [string]$app_server,
    [Parameter(ParameterSetName='vss-standalone')]
    [Parameter(ParameterSetName='vss-cluster')]
    [ValidateSet( 'exchange_dag', 'sql2012', 'sql2014', 'inval', 'sql2005', 'sql2016', 'exchange', 'sql2017', 'sql2008', 'hyperv')]
                                                                                [string]$app_id,
    [Parameter(ParameterSetName='vss-cluster')]                                 [string]$app_cluster_name,

    [Parameter(ParameterSetName='vss-standalone')]
    [Parameter(ParameterSetName='vss-cluster')]                                 [string]$app_service_name,

    [Parameter(ParameterSetName='vmware')]                                      [string]$vcenter_hostname,
    [Parameter(ParameterSetName='vmware')]                                      [string]$vcenter_username,
    [Parameter(ParameterSetName='generic')]                                     [string]$agent_hostname,
    [Parameter(ParameterSetName='generic')]                                     [string]$agent_username
  )
process
  {
    $API = 'protection_templates'
    $Param = @{
      ObjectName = 'ProtectionTemplate'
      APIPath = 'protection_templates'
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

function Set-NSProtectionTemplate {
<#
.SYNOPSIS
  Modify protection templates.
.DESCRIPTION
  Modify protection templates.
.PARAMETER id 
  Identifier for protection template.
.PARAMETER name
  User provided identifier.
.PARAMETER description
  Text description of protection template.
.PARAMETER app_sync
  Application synchronization ({none|vss|vmware|generic}).
.PARAMETER app_server
  Application server hostname.
.PARAMETER app_id
  Application ID running on the server. Application ID can only be specified if application synchronization is VSS.
.PARAMETER app_cluster_name
  If the application is running within a Windows cluster environment then this is the cluster name.
.PARAMETER app_service_name
  If the application is running within a Windows cluster environment then this is the instance name of the service running within the cluster environment.
.PARAMETER vcenter_hostname
  VMware vCenter hostname. Custom port number can be specified with vCenter hostname using :.
.PARAMETER vcenter_username
  VMware vCenter username.
.PARAMETER vcenter_password
  VMware vCenter password.
.PARAMETER agent_hostname
  Generic Backup agent hostname. Custom port number can be specified with agent hostname using \\":\\".
.PARAMETER agent_username
  Generic Backup agent username.
.PARAMETER agent_password
  Generic Backup agent password.
.EXAMPLE
  C:\> Set-NSProtectionTemplate -id 1228eada7f8dd99d3b00000000000000000000009c -description "My Test Template"

  agent_hostname   :
  agent_password   :
  agent_username   :
  app_cluster_name :
  app_id           :
  app_server       :
  app_service_name :
  app_sync         : none
  creation_time    : 1533274196
  description      : My Test Template
  full_name        : test2
  id               : 1228eada7f8dd99d3b00000000000000000000009c
  last_modified    : 1533274196
  name             : test2
  repl_priority    : normal
  schedule_list    :
  search_name      : test2
  vcenter_hostname :
  vcenter_username :

  This command updates the given property of a given Protection Template.
#>  
[CmdletBinding()]
param(
  [Parameter(ParameterSetName='id', Mandatory=$true)] [ValidatePattern('([0-9a-f]{42})')]   [string] $id,
  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]
  [Parameter(ParameterSetName='vss-standalone')]
  [Parameter(ParameterSetName='vss-cluster')]                                 [string]$name,
  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]
  [Parameter(ParameterSetName='vss-standalone')]
  [Parameter(ParameterSetName='vss-cluster')]                                 [string]$full_name,
  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]
  [Parameter(ParameterSetName='vss-standalone')]
  [Parameter(ParameterSetName='vss-cluster')]                                 [string]$search_name,
  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]
  [Parameter(ParameterSetName='vss-standalone')]
  [Parameter(ParameterSetName='vss-cluster')]                                 [string]$description,
  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]
  [Parameter(ParameterSetName='vss-standalone')]
  [Parameter(ParameterSetName='vss-cluster')] [ValidateSet( 'vss', 'vmware', 'none', 'generic')]
                                                                              [string]$app_sync,
  [Parameter(ParameterSetName='vss-standalone')]
  [Parameter(ParameterSetName='vss-cluster')]                                 [string]$app_server,
  [Parameter(ParameterSetName='vss-standalone')]
  [Parameter(ParameterSetName='vss-cluster')]
  [ValidateSet( 'exchange_dag', 'sql2012', 'sql2014', 'inval', 'sql2005', 'sql2016', 'exchange', 'sql2017', 'sql2008', 'hyperv')]
                                                                              [string]$app_id,
  [Parameter(ParameterSetName='vss-cluster')]                                 [string]$app_cluster_name,

  [Parameter(ParameterSetName='vss-standalone')]
  [Parameter(ParameterSetName='vss-cluster')]                                 [string]$app_service_name,

  [Parameter(ParameterSetName='vmware')]                                      [string]$vcenter_hostname,
  [Parameter(ParameterSetName='wmware')]                                      [string]$vcenter_username,
  [Parameter(ParameterSetName='wmware')]                                      [string]$vcenter_password,
  [Parameter(ParameterSetName='generic')]                                     [string]$agent_hostname,
  [Parameter(ParameterSetName='generic')]                                     [string]$agent_username,
  [Parameter(ParameterSetName='generic')]                                     [string]$agent_password
  )
process{# Gather request params based on user input.
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
        $Params = @{  ObjectName = 'ProtectionTemplate'
                      APIPath = 'protection_templates'
                      Id = $id
                      Properties = $RequestData
                  }
        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSProtectionTemplate {
<#
.SYNOPSIS
    Delete protection templates.
.DESCRIPTION
    Delete protection templates.
.PARAMETER id
  Identifier for protection template. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.EXAMPLE
  -------------------- Example 1 --------------------

  C:\> Remove-NSProtectionTemplate -id 1228eada7f8dd99d3b00000000000000000000009c

  This command will remove a Protection Template specified by its ID.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')] 
        [string]$id
    )
process {   $Params = @{  ObjectName = 'ProtectionTemplate'
                          APIPath = 'protection_templates'
                          Id = $id
                      }
            Remove-NimbleStorageAPIObject @Params
        }
}
