function Get-MSAInitiator
{
<#
.SYNOPSIS
    Shows information about initiators.
.DESCRIPTION
    The command will show information about all initiators by default, or you can use parameters to filter the output.
    Initiator entries are automatically created for host initiators that have sent a SCSI INQUIRYcommand or a SCSI
    REPORT LUNScommand to the system. This typically happens when the physical host containing an initiator boots up
    or scans for devices. When the command is received, the system saves the host port information. However, the
    information is retained after a restart only if you have set a name for the initiator.
.EXAMPLE
    PS:> Get-MSAInitiator

    durable-id nickname        disco mapped host-bus id                                                     host-id                        host
                               vered        -type                                                                                          -key
    ---------- --------        ----- ------ -------- --                                                     -------                        ----
    I0         PSKT2019        No    Yes    iSCSI    iqn.1991-05.com.microsoft:pstk2019.lionetti.lab        00c0ff50437d0000467e096001010… H0
    I1         CrusherIQN      No    Yes    iSCSI    iqn.1991-05.com.microsoft:crusher.lionetti.lab         00c0ff504392000079aa465f01010… H1
    I2         Riker-IQN       No    Yes    iSCSI    iqn.1991-05.com.microsoft:riker.lionetti.lab           00c0ff50437d000062a63f5f01010… H2
#>
    $result = Invoke-MSAStorageRestAPI -noun initiators -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}