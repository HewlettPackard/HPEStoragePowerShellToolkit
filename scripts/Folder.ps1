# Folder.ps1:  This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSFolder {
<#
.SYNOPSIS
        Create a new folder.
.DESCRIPTION
        Create a new folder.
.PARAMETER name
        Name of folder. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER description
        Text description of folder.
.PARAMETER pool_id
        ID of the pool where the folder resides.
.PARAMETER limit_size_bytes
        Folder size limit in bytes. If limit_size_bytes is not specified when a folder is created, or if limit_size_bytes is set to -1, 
        then the folder has no limit. Otherwise, a limit smaller than the capacity of the pool can be set. Folders with an agent_type 
        of 'smis' or 'vvol' must have a size limit.
.PARAMETER agent_type
        External management agent type.
.PARAMETER inherited_vol_perfpol_id
        Identifier of the default performance policy for a newly created volume.
.PARAMETER appserver_id
        Identifier of the application server associated with the folder.
.PARAMETER limit_iops
        IOPS limit for this folder. If limit_iops is not specified when a folder is created, or if limit_iops is set to -1, then the 
        folder has no IOPS limit. IOPS limit should be in range [256, 4294967294] or -1 for unlimited.
.PARAMETER limit_mbps
        Throughput limit for this folder in MB/s. If limit_mbps is not specified when a folder is created, or if limit_mbps is set 
        to -1, then the folder has no throughput limit. MBPS limit should be in range [1, 4294967294] or -1 for unlimited.
.EXAMPLE
        C:\> New-NSFolder -name Testfolder-937 -description "Test Folder" -pool_id 0a28eada7f8dd99d3b000000000000000000000001

        name           id                                         full_name               agent_type limit_bytes appserver_name description
        ----           --                                         ---------               ---------- ----------- -------------- -----------
        Testfolder-937 2f28eada7f8dd99d3b0000000000000000000000c3 default:/Testfolder-937 none       23478977434                test folder

        This command create a new folder in the specified pool.
.EXAMPLE
        C:\> New-NSFolder -name Testfolder-478453 -pool_id 0a28eada7f8dd99d3b000000000000000000000001 -agent_type smis -limit_size_bytes 102400

        name              id                                         full_name                  agent_type limit_bytes appserver_name description
        ----              --                                         ---------                  ---------- ----------- -------------- -----------
        Testfolder-478453 2f28eada7f8dd99d3b0000000000000000000000c4 default:/Testfolder-478453 smis       102400

        This command create a new folder in the specified pool for exclusive use as an SMI-S Target folder.
#>
[CmdletBinding()]
param(
        [Parameter(Mandatory = $True)]  [string]        $name,
                                        [string]        $description,
        [Parameter(Mandatory = $True)]                                  [ValidatePattern('([0-9a-f]{42})')]
                                        [string]        $pool_id,
        [Alias('limit_bytes')]          [long]          $limit_size_bytes,
                                                                        [ValidateSet( 'smis', 'vvol', 'openstack', 'none')]
                                        [string]        $agent_type,
                                                                        [ValidatePattern('([0-9a-f]{42})')]
                                        [string]        $inherited_vol_perfpol_id,
                                                                        [ValidatePattern('([0-9a-f]{42})')]
                                        [string]        $appserver_id,
                                        [long]          $limit_iops,
                                        [long]          $limit_mbps
        )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {       $RequestData.Add("$($var.name)", ($var.value))
                }
        }
        $Params = @{    ObjectName = 'Folder'
                        APIPath = 'folders'
                        Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
        }
}

function Get-NSFolder {
<#
.SYNOPSIS
        List a set of folders.
.DESCRIPTION
        List a set of folders.
.PARAMETER id
        Identifier for the folder.
.PARAMETER name
        Name of folder.
.PARAMETER fqn
        Fully qualified name of folder in the pool.
.PARAMETER full_name
        Fully qualified name of folder in the group.
.PARAMETER search_name
        Name of folder used for object search.
.PARAMETER description
        Text description of folder.
.PARAMETER pool_name
        Name of the pool where the folder resides.
.PARAMETER pool_id
        ID of the pool where the folder resides.
.PARAMETER limit_bytes_specified
        Indicates whether the folder has a limit.
.PARAMETER limit_bytes
        Folder limit size in bytes. By default, a folder (except SMIS and VVol types) does not have a limit. 
        If limit_bytes is not specified when a folder is created, or if limit_bytes is set to the largest possible
        64-bit signed integer (9223372036854775807), then the folder has no limit. Otherwise, a limit smaller 
        than the capacity of the pool can be set. On output, if the folder has a limit, the limit_bytes_specified
        attribute will be true and limit_bytes will be the limit. If the folder does not have a limit, the 
        limit_bytes_specified attribute will be false and limit_bytes will be interpreted based on the value of the
        usage_valid attribute. If the usage_valid attribute is true, limits_byte will be the capacity of the pool. 
        Otherwise, limits_bytes is not meaningful and can be null. SMIS and VVol folders require a sizelimit. 
        This attribute is superseded by limit_size_bytes.
.PARAMETER limit_size_bytes
        Folder size limit in bytes. If limit_size_bytes is not specified when a folder is created, or if 
        limit_size_bytes is set to -1, then the folder has no limit. Otherwise, a limit smaller than the capacity of
        the pool can be set. Folders with an agent_type of 'smis' or 'vvol' must have a size limit.
.PARAMETER overdraft_limit_pct
        Amount of space to consider as overdraft range for this folder as a percentage of folder used limit.
        Valid values are from 0% - 200%. This is the limit above the folder usage limit beyond which enforcement
        action(volume offline/non-writable) is issued.
.PARAMETER capacity_bytes
        Capacity of the folder in bytes. If the folder's size has a usage limit, capacity_bytes will be the 
        folder's usage limit. If the folder's size does not have a usage limit, capacity_bytes will be the pool's
        capacity. This field is meaningful only when the usage_valid attribute is true.
.PARAMETER usage_valid
        Indicate whether the space usage attributes of folder are valid.
.PARAMETER agent_type
        External management agent type.
.PARAMETER inherited_vol_perfpol_id
        Identifier of the default performance policy for a newly created volume.
.PARAMETER inherited_vol_perfpol_name
        Name of the default performance policy for a newly created volume.
.PARAMETER num_snaps
        Number of snapshots inside the folder. This attribute is deprecated and has no meaningful value.
.PARAMETER num_snapcolls
        Number of snapshot collections inside the folder. This attribute is deprecated and has no meaningful value.
.PARAMETER app_uuid
        Application identifier of the folder.
.PARAMETER volume_list
        List of volumes contained by the folder.
.PARAMETER appserver_id
        Identifier of the application server associated with the folder. 
        Lost A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER appserver_name
        Name of the application server associated with the folder.
.PARAMETER folset_id
        Identifier of the folder set associated with the folder. Only VVol folder can be associated with the folder set. 
        The folder and the containing folder set must be associated with the same application server.
.PARAMETER folset_name
        Name of the folder set associated with the folder. Only VVol folder can be associated with the folder set. 
        The folder and the containing folder set must be associated with the same application server.
.PARAMETER limit_iops
        IOPS limit for this folder. If limit_iops is not specified when a folder is created, or if limit_iops is set to -1, then 
        the folder has no IOPS limit. IOPS limit should be in range [256, 4294967294] or -1
        for unlimited.
.PARAMETER limit_mbps
        Throughput limit for this folder in MB/s. If limit_mbps is not specified when a folder is created, or if 
        limit_mbps is set to -1, then the folder has no throughput limit. MBPS limit should be in range [1,
        4294967294] or -1 for unlimited.
.PARAMETER access_protocol
        Access protocol of the folder. This attribute is used by the VASA Provider to determine the access protocol 
        of the bind request. If not specified in the creation request, it will be the access protocol
        supported by the group. If the group supports multiple protocols, the default will be Fibre Channel. 
        This field is meaningful only to VVol folder.
.EXAMPLE
        C:\> Get-NSFolder

        name              id                                         full_name                  agent_type limit_bytes appserver_name description
        ----              --                                         ---------                  ---------- ----------- -------------- -----------
        Testfolder-461372 2f28eada7f8dd99d3b00000000000000000000004e default:/Testfolder-461372 smis       102400
        Testfolder-551725 2f28eada7f8dd99d3b000000000000000000000049 default:/Testfolder-551725 smis       102400
        Testfolder-959    2f28eada7f8dd99d3b000000000000000000000044 default:/Testfolder-959    smis       102400
        Testfolder-811415 2f28eada7f8dd99d3b000000000000000000000062 default:/Testfolder-811415 smis       102400
        Testfolder-799    2f28eada7f8dd99d3b000000000000000000000039 default:/Testfolder-799    smis       102400

        This command will retrieve the Folders from the array.
.EXAMPLE
        C:\> Get-NSFolder -name Testfolder-576

        name           id                                         full_name               agent_type limit_bytes appserver_name description
        ----           --                                         ---------               ---------- ----------- -------------- -----------
        Testfolder-576 2f28eada7f8dd99d3b0000000000000000000000c2 default:/Testfolder-576 none       23478977434                test folder

        This command will retrieve only the folder that matches the folder named.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
        [Parameter(ParameterSetName='id')][ValidatePattern('([0-9a-f]{42})')]   [string]        $id,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $name,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $fqn,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $full_name,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $search_name,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $description,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $pool_name,
        [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{42})')][string]        $pool_id,
        [Parameter(ParameterSetName='nonId')]                                   [bool]          $limit_bytes_specified,
        [Parameter(ParameterSetName='nonId')][Alias('limit_bytes')]             [long]          $limit_size_bytes,
        [Parameter(ParameterSetName='nonId')]                                   [bool]          $usage_valid,
        [Parameter(ParameterSetName='nonId')][ValidateSet( 'smis', 'vvol', 'openstack', 'none')][string]$agent_type,
        [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{42})')][string]        $inherited_vol_perfpol_id,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $inherited_vol_perfpol_name,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $app_uuid,
        [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{42})')][string]        $appserver_id,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $appserver_name,
        [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{42})')][string]        $folset_id,
        [Parameter(ParameterSetName='nonId')                                    ][string]       $folset_name,
        [Parameter(ParameterSetName='nonId')]                                   [long]          $limit_iops,
        [Parameter(ParameterSetName='nonId')]                                   [long]          $limit_mbps,
        [Parameter(ParameterSetName='nonId')][ValidateSet( 'iscsi', 'fc')]      [string]        $access_protocol
)
process{ 
        $API = 'folders'
        $Param = @{     ObjectName = 'Folder'
                        APIPath = 'folders'
                }
        if ($id)
        {       # Get a single object for given Id.
                $Param.Id = $id
                $ResponseObject = Get-NimbleStorageAPIObject @Param
                return $ResponseObject
        }
        else
        {       # Get list of objects matching the given filter.
                $Param.Filter = @{}
                $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
                foreach ($key in $ParameterList.keys)
                {       if ($key.ToLower() -ne 'fields')
                        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                                if($var -and ($PSBoundParameters.ContainsKey($key)))
                                {       $Param.Filter.Add("$($var.name)", ($var.value))
                                }
                        }
                }
                $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
                return $ResponseObjectList
        }
}
}

function Set-NSFolder {
<#
.SYNOPSIS
        Modify attributes of specified folder.
.DESCRIPTION
        Modify attributes of specified folder.
.PARAMETER id
        Identifier for the folder. 
        A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'
.PARAMETER name 
        Name of folder. 
        String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER description 
        Text description of folder. 
        String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER limit_size_bytes
        Folder size limit in bytes. If limit_size_bytes is not specified when a folder is created, or if limit_size_bytes 
        is set to -1, then the folder has no limit. Otherwise, a limit smaller than the capacity of the pool can be set. 
        Folders with an agent_type of 'smis' or 'vvol' must have a size limit. Signed 64-bit integer. Example: -1234.
.PARAMETER inherited_vol_perfpol_id 
        Identifier of the default performance policy for a newly created volume. 
        A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER appserver_id 
	Identifier of the application server associated with the folder. 
        A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'
.PARAMETER limit_iops
        IOPS limit for this folder. If limit_iops is not specified when a folder is created, or if limit_iops 
        is set to -1, then the folder has no IOPS limit. IOPS limit should be in range [256, 4294967294] or -1 for unlimited. 
        Signed 64-bit integer. Example: -1234.
.PARAMETER limit_mbps
        Throughput limit for this folder in MB/s. If limit_mbps is not specified when a folder is created, or 
        if limit_mbps is set to -1, then the folder has no throughput limit. MBPS limit should be in 
        range [1, 4294967294] or -1 for unlimited. Signed 64-bit integer. Example: -1234.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]     [string]        $id,
                                                [string]        $name,
                                                [string]        $description,
        [Alias('limit_size')]                   [long]          $limit_size_bytes,
        [ValidatePattern('([0-9a-f]{42})')]     [string]        $inherited_vol_perfpol_id,
        [ValidatePattern('([0-9a-f]{42})')]     [string]        $appserver_id,
                                                [long]          $limit_iops,
                                                [long]          $limit_mbps
        )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       if ($key.ToLower() -ne 'id')
                {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                        if($var -and ($PSBoundParameters.ContainsKey($key)))
                        {       $RequestData.Add("$($var.name)", ($var.value))
                        }
                }
        }
        $Params = @{    ObjectName = 'Folder'
                        APIPath = 'folders'
                        Id = $id
                        Properties = $RequestData
                }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
}
}

function Remove-NSFolder {
<#
.SYNOPSIS 
        Deletes the Folder identified by the ID
.DESCRIPTION
        Deletes the Folder identified by the ID. 
.PARAMETER id
        Identifier for the folder. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]$id
)
process { $Params = @{  ObjectName = 'Folder'
                        APIPath = 'folders'
                        Id = $id
                }
        Remove-NimbleStorageAPIObject @Params
        }
}