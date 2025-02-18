function Get-MSAEnclosure
{
<#
.SYNOPSIS
    Shows information about the enclosures in the storage system.
.DESCRIPTION
    Shows information about the enclosures in the storage system. Full detail available in API output only.
.EXAMPLE
    PS:> Get-MSAEnclosure

    object-name                   : enclosures
    meta                          : /meta/enclosures
    durable-id                    : enclosure_1
    enclosure-id                  : 1
    url                           : /enclosures/1
    enclosure-wwn                 : 500C0FF05038E83C
    name                          :
    type                          : Xyratex24
    type-numeric                  : 10
    iom-type                      : XyratexRbod
    iom-type-numeric              : 2
    platform-type                 : Indium LX
    platform-type-numeric         : 11
    board-model                   : Indium Raidhead-12G
    board-model-numeric           : 19
    location                      :
    rack-number                   : 0
    rack-position                 : 0
    number-of-coolings-elements   : 4
    number-of-disks               : 14
    number-of-power-supplies      : 2
    status                        : OK
    status-numeric                : 1
    extended-status               : 00000000
    midplane-serial-number        : 7CE928D069
    vendor                        : HPE
    model                         : MSA2060-ENCL-SFF
    fru-tlapn                     : R0Q76A
    fru-shortname                 :
    fru-location                  : MID-PLANE SLOT
    part-number                   : P12942-001
    mfg-date                      : 2019-07-08 14:36:00
    mfg-date-numeric              : 1562596560
    mfg-location                  :
    description                   : SPS-MSA 2060 SFF Chassis
    revision                      : A
    dash-level                    :
    emp-a-rev                     : 5316
    emp-b-rev                     : 5316
    gem-version-a                 : N/A
    gem-version-b                 : N/A
    rows                          : 1
    columns                       : 24
    slots                         : 24
    locator-led                   : Off
    locator-led-numeric           : 0
    drive-orientation             : vertical
    drive-orientation-numeric     : 0
    enclosure-arrangement         : vertical
    enclosure-arrangement-numeric : 0
    emp-a-busid                   : 00
    emp-a-targetid                : 127
    emp-b-busid                   : 01
    emp-b-targetid                : 127
    emp-a                         :
    emp-a-ch-id-rev               : 00:127 5316
    emp-b                         :
    emp-b-ch-id-rev               : 01:127 5316
    midplane-type                 : 2U24-12Gv3
    midplane-type-numeric         : 25
    midplane-rev                  : 0
    enclosure-power               : 122.41
    pcie2-capable                 : False
    pcie2-capable-numeric         : 0
    health                        : OK
    health-numeric                : 0
    controllers                   : {@{object-name=controller; meta=/meta/controllers; durable-id=controller_a; controller-id=A; controller-id-numeric=1; url=/controllers/A;
                                    serial-number=7CE935R053; hardware-version=5.0; cpld-version=2.5; mac-address=00:C0:FF:50:43:7D; node-wwn=208000C0FF5038E8;
                                    ip-address=192.168.100.98; ip-subnet-mask=255.255.255.0; ip-gateway=192.168.100.1; ip6-link-local-address=fe80::2c0:ffff:fe50:437d;
                                    ip6-link-local-gateway=::; autoconfig=Enabled; autoconfig-numeric=1; ip6-auto-address=::/0; dhcpv6=::; slaac-ip=::;
                                    ip6-auto-address-source=DHCPv6; ip6-auto-address-source-numeric=0; ip6-auto-gateway=::; ip61-address=::; ip61-gateway=::; ip62-address=::;
                                    ip62-gateway=::; ip63-address=::; ip63-gateway=::; ip64-address=::; ip64-gateway=::; disks=14; number-of-storage-pools=2; virtual-disks=2;
                                    cache-memory-size=4096; system-memory-size=12288; host-ports=4; drive-channels=2; drive-bus-type=SAS; drive-bus-type-numeric=8;
                                    redundancy-status=Redundant; redundancy-status-numeric=2; network-parameters=System.Object[]; port=System.Object[];
                                    expander-ports=System.Object[]; expanders=System.Object[]}}
    power-supplies                : {@{object-name=power-supply; meta=/meta/power-supplies; durable-id=psu_1.1; url=/power-supplies/psu_1.1; enclosures-url=/enclosures/1;
                                    enclosure-id=1; dom-id=1; serial-number=7CE928T007; part-number=P12954-001; description=SPS-MSA PWR supply OneStor 580W AC; name=PSU 1, Left;
                                    fw-revision=033E; revision=A; model=P12954-001; vendor=; location=Enclosure 1 - Left; position=Left; position-numeric=0; dash-level=;
                                    configuration-serialnumber=7CE928T008; dc12v=0; dc5v=0; dc33v=0; dc12i=0; dc5i=0; dctemp=0; health=OK; health-numeric=0; health-reason=;
                                    health-recommendation=; status=Up; status-numeric=0; fan=System.Object[]}}

#>
    $result = Invoke-MSAStorageRestAPI -noun enclosures -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAFan
{
<#
.SYNOPSIS
    Shows information about each fan in the storage system.
.DESCRIPTION
    Shows information about each fan in the storage system.
.EXAMPLE
    PS:> Get-MSAFan

    durable-id name   location                       status-ses status position serial-number part-number locator-led speed  health
    ---------- ----   --------                       ---------- ------ -------- ------------- ----------- ----------- -----  ------
    fan_1.1    Fan 1  Enclosure 1, PSU 1 - Left      OK         Up     Left     N/A           N/A         Off         4740   OK
    fan_1.2    Fan 2  Enclosure 1, PSU 1 - Left      OK         Up     Left     N/A           N/A         Off         4740   OK
    fan_1.3    Fan 3  Enclosure 1, PSU 2 - Right     OK         Up     Right    N/A           N/A         Off         4800   OK
    fan_1.4    Fan 4  Enclosure 1, PSU 2 - Right     OK         Up     Right    N/A           N/A         Off         4740   OK

#>
    $result = Invoke-MSAStorageRestAPI -noun fans -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
} 

function Get-MSAPowerSupply
{
<#
.SYNOPSIS
    Shows information about each power supply in the storage system
.DESCRIPTION
    Shows information about each power supply in the storage system
.EXAMPLE
    PS:> Get-MSAPowerSupply

    durable serial-number part-number description                                   name         fw-rev revision  model      location             health status
    -id                                                                                          ision
    ------- ------------- ----------- -----------                                   ----         ------ --------  -----      --------             ------ ------
    psu_1.1 7CE928T007    P12954-001  SPS-MSA PWR supply OneStor 580W AC            PSU 1, Left  033E   A         P12954-001 Enclosure 1 - Left   OK     Up
    psu_1.2 7CE928T008    P12954-001  SPS-MSA PWR supply OneStor 580W AC            PSU 2, Right 033E   A         P12954-001 Enclosure 1 - Right  OK     Up
#>
    $result = Invoke-MSAStorageRestAPI -noun power-supplies -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAFru
{
<#
.SYNOPSIS
    Shows SKU and FRU (field-replaceable unit) information for the storage system.
.DESCRIPTION
    Shows SKU and FRU (field-replaceable unit) information for the storage system.
    Some information is for use by service technicians.
.PARAMETER SkuInfoOnly
    This switch will return only the part information for the complete enclosure (or SKU).
.EXAMPLE
    PS:> Get-MSAFru

    durable-id name   location                       status-ses status position serial-number part-number locator-led speed  health
    ---------- ----   --------                       ---------- ------ -------- ------------- ----------- ----------- -----  ------
    fan_1.1    Fan 1  Enclosure 1, PSU 1 - Left      OK         Up     Left     N/A           N/A         Off         4740   OK
    fan_1.2    Fan 2  Enclosure 1, PSU 1 - Left      OK         Up     Left     N/A           N/A         Off         4740   OK
    fan_1.3    Fan 3  Enclosure 1, PSU 2 - Right     OK         Up     Right    N/A           N/A         Off         4800   OK
    fan_1.4    Fan 4  Enclosure 1, PSU 2 - Right     OK         Up     Right    N/A           N/A         Off         4740   OK
.EXAMPLE
    PS:> Get-MSAFru -SkuInfoOnly

    object-name      : sku
    meta             : /meta/enclosure-sku
    sku-partnumber   : R0Q76A
    sku_serialnumber : 7CE928D069
    sku-revision     :
    enclosure-id     : 1
#>
param   ( [switch]    $SkuInfoOnly
        )
process{
    $result = Invoke-MSAStorageRestAPI -noun frus -verb show
    if ( $SkuInfoOnly ) 
        {   $objResult = Register-MSAObjectType $result -SubobjectName 'enclosure-sku'
        }
    else{   $objResult = Register-MSAObjectType $result -SubobjectName 'enclosure-fru'
        }
    return $objResult
} 
}
