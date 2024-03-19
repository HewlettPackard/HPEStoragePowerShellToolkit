####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Show-A9CIM
{
<#
.SYNOPSIS
    Show the CIM server information
.DESCRIPTION
    This cmdlet displays the CIM server service state being configured, either enabled or disabled. It also displays the server current running
    status, either active or inactive. It displays the current status of the HTTP and HTTPS ports and their port numbers. In addition, it shows the
    current status of the SLP port, that is either enabled or disabled.
.PARAMETER Pol
    Show CIM server policy information
.EXAMPLE
    The following example shows the current CIM status:

        PS:> Show-A9CIM

        -Service- -State-- --SLP-- SLPPort -HTTP-- HTTPPort -HTTPS- HTTPSPort PGVer  CIMVer
        Enabled   Active   Enabled     427 Enabled     5988 Enabled      5989 2.14.1 3.3.1

.EXAMPLE
    The following example shows the current CIM policy:

        PS:> Show-A9CIM -Pol

        --------------Policy---------------
        replica_entity,one_hwid_per_view,use_pegasus_interop_namespace,no_tls_strict
#>
[CmdletBinding()]
param(  [Parameter()]    [Switch]    $Pol
)	
	
Begin 
{ Test-A9Connection -ClientType 'SshClient' 
}
process
{   $cmd = "showcim "
    if ($Pol) {    $cmd += " -pol "    }	
    $Result = Invoke-CLICommand -cmds $cmd
    write-verbose " Executed the Show-CIM cmdlet" 
    return 	$Result	

}
}

Function Start-A9CIM
{
<#
.SYNOPSIS
    Start the CIM server to service CIM requests
.DESCRIPTION
    The cmdlet starts the CIM server to service CIM requests. By default, the CIM server is not started until this command is issued.
.EXAMPLE
    The following example starts the CIM server:

    PS:> Start-A9CIM

    CIM server will start shortly.
#>
[CmdletBinding()]
param()	
begin
{   Test-A9Connection -ClientType 'SshClient' 
}	
process 
{   $cmd = "startcim "
    $Result = Invoke-CLICommand  -cmds  $cmd
    write-verbose " Executed the Start-CIM cmdlet" 
    return 	$Result	
}
}

Function Set-A9CIM
{
<#
.SYNOPSIS
    Set the CIM server properties
.DESCRIPTION
    The cmdlet sets properties of the CIM server, including options to enable/disable the HTTP and HTTPS ports for the CIM server. setcim allows
    a user to enable/disable the SLP port. The command also sets the CIM server policy.
.PARAMETER F
    Forces the operation of the setcim command, bypassing the typical confirmation message.
.PARAMETER Slp
    Enables or disables the SLP port 427.
.PARAMETER Http
    Enables or disables the HTTP port 5988
.PARAMETER Https
    Enables or disables the HTTPS port 5989
.PARAMETER Pol
    Sets the cim server policy:
        replica_entity   - complies with SMI-S standard for usage of Replication Entity objects in associations. This is the default policy setting.
        no_replica_entity- does not comply with SMI-S standard for Replication Entity usage. Use only as directed by HPE support personnel or Release Notes.
        one_hwid_per_view - calling exposePaths with multiple initiatorPortIDs to create new view will result in the creation of multiple
                            SCSCIProtocolControllers (SPC), one StorageHardwareID per SPC. Multiple hosts will be created each containing one FC WWN or
                            iscsiname. This is the default policy setting. This is the default policy setting.
        no_one_hwid_per_view - calling exposePaths with multiple initiatorPortIDs to create new view will result in the creation of only one
                            SCSCIProtocolController (SPC) that contains all the StorageHardwareIDs. One host will be created that contains all the FC WWNs or iscsinames.
        use_pegasus_interop_namespace - use the pegasus defined interop namespace root/PG_interop.  This is the default policy setting.
        no_use_pegasus_interop_namespace - use the SMI-S conformant interop namespace root/interop.
        tls_strict       - Only TLS connections using TLS 1.2 with secure ciphers will be accepted if HTTPS is enabled.
        no_tls_strict    - TLS connections using TLS 1.0 - 1.2 will be accepted if HTTPS is enabled. This is the default policy setting.
.EXAMPLE
    To disable the HTTPS ports:

    PS:> Set-A9CIM -F -Https Disable
.EXAMPLE
    To enable the HTTPS port:

    PS:> Set-A9CIM -F -Https Enable
.EXAMPLE
    To disable the HTTP port and enable the HTTPS port:

    PS:> Set-A9CIM -F -Http Disable -Https Enable
.EXAMPLE
    To set the no_use_pegasus_interop_namespace policy:

    PS:> Set-A9CIM -F -Pol no_use_pegasus_interop_namespace
.EXAMPLE
    To set the replica_entity policy:

    PS:> Set-A9CIM -F -Pol replica_entity
.NOTES
    Access to all domains is required to run this command.    You cannot disable both of the HTTP and HTTPS ports.

    When the CIM server is active, a warning message will be prompted to inform you of the current status of the CIM server and asks for the confirmation to
    continue or not. The -F option forces the action without a warning message.
#>
[CmdletBinding()]
param(  [Parameter()]   [Switch]    $F,
        [Parameter()]   [ValidateSet("enable", "disable")]     
                        [String]    $Slp,
        [Parameter()]   [ValidateSet("enable", "disable")]      
                        [String]    $Http,
        [Parameter()]   [ValidateSet("enable", "disable")]
                        [String]    $Https,
        [Parameter()]   [ValidateSet("replica_entity", "no_replica_entity", "one_hwid_per_view", "no_one_hwid_per_view", "use_pegasus_interop_namespace", "no_use_pegasus_interop_namespace", "tls_strict", "no_tls_strict")]
                        [String]    $Pol
)	
Begin	
{   Test-A9Connection -ClientType 'SshClient'
}
Process
{   $cmd = "setcim "
    if ($F) {    $cmd += " -f "    }
    else    {    Return "Force set option is only supported with the Set-CIM cmdlet."    }
    if (($Slp) -or ($Http) -or ($Https) -or ($Pol)) 
        {   if ($Slp)   {   $cmd += " -slp $Slp"    }
            if ($Http)  {   $cmd += " -http $Http"  }
            if ($Https) {   $cmd += " -https $Https"}
            if ($Pol)   {   $cmd += " -pol $Pol"    }
        }
    else{   Return "At least one of the options -Slp, -Http, -Https, or -Pol are required."
        }
    $Result = Invoke-CLICommand -cmds  $cmd
    return 	$Result	
}
}

Function Stop-A9CIM
{
<#
.SYNOPSIS
    Stop the CIM server. Future CIM requests will be not supported.
.DESCRIPTION
    The cmdlet stops the CIM server from servicing CIM requests.
.PARAMETER F
    Specifies that the operation is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
.PARAMETER X
    Specifies that the operation terminates the server immediately without graceful shutdown notice.

.EXAMPLE
    The following example stops the CIM server without confirmation

    PS:> Stop-A9CIM -F        

    The following example stops the CIM server immediately without graceful shutdown notice and confirmation:

    PS:> Stop-A9CIM -F -X        
#>
[CmdletBinding()]
param(  [Parameter()]
        [Switch]    $F,
        [Parameter()]        
        [Switch]    $X
    )	
Begin	
{   Test-A9Connection -ClientType 'SshClient'
}
Process
{   $cmd = "setcim "	
    if ($F)     {    $cmd += " -f " }
    else        {   Return "Force set option is only supported with the Stop-CIM cmdlet."}
    if ($X) {    $cmd += " -x "}
    $Result = Invoke-CLICommand -cmds  $cmd
    return 	$Result	
}
}

