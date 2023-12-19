function Get-MSAMap
{
<#
.SYNOPSIS
    Shows information about mappings between volumes and initiators.
.DESCRIPTION
    If no parameter is specified, this command shows information for all mapped volumes.
    In a dual-controller system, if a mapping uses corresponding ports on both controllers, such as A1 and B1, the Ports field
    will simply show 1.
.EXAMPLE
    PS:> Get-MSAMap

    durable-id volume-serial                    volume-name  volume-view-mappings
    ---------- -------------                    -----------  --------------------
    V0         00c0ff50437d0000d9c73e5f01000000 Vol1         {@{object-name=host-view; meta=/meta/volume-view-mappings; durable-id…
    V1         00c0ff50437d000052ab465f01000000 Crush50      {@{object-name=host-view; meta=/meta/volume-view-mappings; durable-id…
    V2         00c0ff50437d00004e7e096001000000 MyVol1       {@{object-name=host-view; meta=/meta/volume-view-mappings; durable-id…

#>
    $result = Invoke-MSAStorageRestAPI -noun maps -verb show
    $objResult = Register-MSAObjectType $result -subobjectname 'volume-view'
    return $objResult

}