####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Get-A9CIM
{
<#
.SYNOPSIS
    Show the CIM server information including policy
.DESCRIPTION
    This cmdlet displays the CIM server service state being configured, either enabled or disabled. It also displays the server current running
    status, either active or inactive. It displays the current status of the HTTP and HTTPS ports and their port numbers. In addition, it shows the
    current status of the SLP port, that is either enabled or disabled.
.EXAMPLE
    The following example shows the current CIM status:
        PS:> Get-A9Cim
        CIMVer    : 10.4.2
        PGVer     : 2.14.1
        SLP       : Disabled
        SLPPort   : 427
        HTTPS     : Disabled
        Service   : Disabled
        Policy    : {replica_entity, one_hwid_per_view, use_pegasus_interop_namespace, tls_strict}
        HTTPSPort : 5989
        State     : Inactive
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(  [Parameter()]    [Switch]    $Policy
)		
Begin 
    { Test-A9Connection -ClientType 'SshClient' 
    }
process
    {   $cmd = "showcim "
        write-verbose "Executing the following SSH command `n $cmd"
        $Result1 = Invoke-A9CLICommand -cmds $cmd
        $cmd += " -pol " 	
        write-verbose "Executing the following SSH command `n $cmd"
        $Result2 = Invoke-A9CLICommand -cmds $cmd
    }
end
    {   if ( $Result1.count -gt 1)
            {   $Result2 = @{Policy = @($Result2[1].split(',')) }                 
                $tempFile = [IO.Path]::GetTempFileName()
                        $Head = (($Result1[0].split(' ') | where-object {$_ -ne ''}).trim('-')) -join ","
                        $Data = (($Result1[1].split(' ') | where-object {$_ -ne ''}).trim(' ')) -join ","
                        $tempFile = [IO.Path]::GetTempFileName()
                        Add-Content -Path $tempFile -Value $Head
                        Add-Content -Path $tempFile -Value $Data
                        $Result1 = Import-Csv $tempFile
                        Remove-Item  $tempFile
                        # Must force import as a Hashtable instead of a PSCustom Object or else I cant add them together
                        $Result3 = ($result1 | convertto-json | convertfrom-json -asHashTable) + ($result2 | convertto-json | convertfrom-json -asHashTable)
                        $Result3 = $Result3 | convertto-json | convertfrom-json
            }
        else 
            {  Write-Warning "The Command did not complete properly"
            }
        return 	$Result3
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()	
begin
    {   Test-A9Connection -ClientType 'SshClient' 
    }	
process 
{   $cmd = "startcim "
    write-verbose "Executing the following SSH command `n $cmd"
    $Result = Invoke-A9CLICommand  -cmds  $cmd
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

    PS:> Set-A9CIM -Https Disable
.EXAMPLE
    To enable the HTTPS port:

    PS:> Set-A9CIM -Https Enable
.EXAMPLE
    To disable the HTTP port and enable the HTTPS port:

    PS:> Set-A9CIM -Http Disable -Https Enable
.EXAMPLE
    To set the no_use_pegasus_interop_namespace policy:

    PS:> Set-A9CIM -Pol no_use_pegasus_interop_namespace
.EXAMPLE
    To set the replica_entity policy:

    PS:> Set-A9CIM -Pol replica_entity
.NOTES
    This command requires a SSH type connection.
    Access to all domains is required to run this command.    You cannot disable both of the HTTP and HTTPS ports.

    When the CIM server is active, a warning message will be prompted to inform you of the current status of the CIM server and asks for the confirmation to
    continue or not. The -F option forces the action without a warning message.
#>
[CmdletBinding()]
param(  [Parameter(parametersetname='SLP',mandatory)]       
            [ValidateSet("enable", "disable")]          [String]    $Slp,
        [Parameter(parametersetname='HTTP',mandatory)]
            [ValidateSet("enable", "disable")]          [String]    $Http,
        [Parameter(parametersetname='HTTPS',mandatory)]   
            [ValidateSet("enable", "disable")]          [String]    $Https,
        [Parameter(parametersetname='Policy',mandatory)]   
            [ValidateSet("replica_entity", "no_replica_entity", "one_hwid_per_view", "no_one_hwid_per_view", "use_pegasus_interop_namespace", "no_use_pegasus_interop_namespace", "tls_strict", "no_tls_strict")]
                                                        [String]    $Policy
)	
Begin	
    {   Test-A9Connection -ClientType 'SshClient'
    }
Process
    {   $cmd = "setcim "
        $cmd += " -f "
        if ($Slp)   {   $cmd += " -slp $Slp"    }
        if ($Http)  {   $cmd += " -http $Http"  }
        if ($Https) {   $cmd += " -https $Https"}
        if ($Policy){   $cmd += " -pol $Pol"    }
        write-verbose "Executing the following SSH command `n $cmd"
        $Result = Invoke-A9CLICommand -cmds  $cmd
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
.PARAMETER Immediate
    Specifies that the operation terminates the server immediately without graceful shutdown notice.

.EXAMPLE
    The following example stops the CIM server without confirmation

    PS:> Stop-A9CIM       

    The following example stops the CIM server immediately without graceful shutdown notice and confirmation:

    PS:> Stop-A9CIM -Immediate
.NOTES
	This command requires a SSH type connection. 
    Authority: Super, Service
        Any role granted the cim_stop right
    Usage:  
    - Access to all domains is required to run this command.
    - By default, the CIM server is not started until the startcim command is issued.     
#>
[CmdletBinding()]
param(  [Parameter()]   [Switch]    $Immediate
    )	
Begin	
    {   Test-A9Connection -ClientType 'SshClient'
    }
Process
    {   $cmd = "setcim "	
        $cmd += " -f " 
        if ($Immediate) {    $cmd += " -x "}
        write-verbose "Executing the following SSH command `n $cmd"
        $Result = Invoke-A9CLICommand -cmds $cmd
        return 	$Result	
    }
}

