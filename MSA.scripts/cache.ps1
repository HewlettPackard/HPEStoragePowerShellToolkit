function Get-MSACache
{
<#
.SYNOPSIS
    Shows cache settings and status for the system and optionally for a volume.
.DESCRIPTION
    Shows cache settings and status for the system and optionally for a volume. 
.EXAMPLE
    PS:> Get-MSACache

    object-name                 : system-cache-parameters
    meta                        : /meta/cache-settings
    operation-mode              : Active-Active ULP
    operation-mode-numeric      : 8
    pi-format                   : Disabled
    pi-format-numeric           : 0
    cache-block-size            : 512
    controller-cache-parameters : {@{object-name=controller-b-cache-parameters; meta=/meta/controller-cache-parameters; durable-id=cache-params-b; controller-id=B;
                                controller-id-numeric=0; name=Controller B Cache Parameters; write-back-status=Enabled; write-back-status-numeric=0; memory-card-status=Unknown;
                                memory-card-status-numeric=5; memory-card-health=Unknown; memory-card-health-numeric=3; cache-flush=Enabled; cache-flush-numeric=1}}
.EXAMPLE
    PS:> (Get-MSACache).'controller-cache-parameters'

    object-name                : controller-b-cache-parameters
    meta                       : /meta/controller-cache-parameters
    durable-id                 : cache-params-b
    controller-id              : B
    controller-id-numeric      : 0
    name                       : Controller B Cache Parameters
    write-back-status          : Enabled
    write-back-status-numeric  : 0
    memory-card-status         : Unknown
    memory-card-status-numeric : 5
    memory-card-health         : Unknown
    memory-card-health-numeric : 3
    cache-flush                : Enabled
    cache-flush-numeric        : 1
#>
    $result = Invoke-MSAStorageRestAPI -noun 'cache-parameters' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}
