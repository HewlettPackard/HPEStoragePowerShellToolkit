####################################################################################
## 	© 2024 Hewlett Packard Enterprise Development LP
##

Function Get-A9System
{
<#
.SYNOPSIS	
	Retrieve informations about the array.
.DESCRIPTION
	Retrieve informations about the array.
.PARAMETER Detailed
	Specifies that more detailed information about the system is displayed. THe use of this option will force the connection type to be SSH
.PARAMETER SystemParameters
	Specifies that the system parameters are displayed. THe use of this option will force the connection type to be SSH
.PARAMETER Fan
	Displays the system fan information. THe use of this option will force the connection type to be SSH
.PARAMETER SystemCapacity
	Displays the system capacity information in MiB. THe use of this option will force the connection type to be SSH
.PARAMETER vvSpace
	Displays the system capacity information in MiB with an emphasis on VVs. THe use of this option will force the connection type to be SSH
.PARAMETER Domainspace
	Displays the system capacity information broken down by domain in MiB. THe use of this option will force the connection type to be SSH
.PARAMETER Descriptor
	Displays the system descriptor properties. THe use of this option will force the connection type to be SSH
.PARAMETER DevType FC|NL|SSD
	Displays the system capacity information where the disks must have a device type string matching the specified device type; either Fast
	Class (FC), Nearline (NL), Solid State Drive (SSD). This option can only be issued with -space or -vvspace. THe use of this option will force the connection type to be SSH
.PARAMETER ShowRaw
    This parameter will force the SSH type command to return the raw data instead of the proper PowerShell object
.PARAMETER UseSSL
    This option will force the command to use an SSH connection type even if no other paramters are selected.
    .EXAMPLE
    PS:> Get-A9System_CLI 

	Command displays the Storage system information.such as system name, model, serial number, and system capacity information.
.EXAMPLE
    PS:> Get-A9System -useSSL

    ID        : 0x7F4DC
    Name      : ST10-DedicatedArcus
    Model     : HPE
    Serial    : Alletra
    Nodes     : Storage
    Master    : MP
    TotalCap  : 4UW0005393
    AllocCap  : 4
    FreeCap   : 1
    FailedCap : 87834624
.EXAMPLE
    PS:> Get-A9System

    Cmdlet executed successfully

    id                   : 521436
    name                 : ST10-DedicatedArcus
    systemVersion        : 10.4.2.9
    IPv4Addr             : 192.168.1.2
    model                : HPE Alletra Storage MP
    serialNumber         : 4UW0005393
    totalNodes           : 4
    masterNode           : 1
    onlineNodes          : {0, 1, 2, 3}
    clusterNodes         : {0, 1, 2, 3}
    chunkletSizeMiB      : 1024
    totalCapacityMiB     : 87834624
    ...
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='API')]
Param(
        [Parameter(ParameterSetName='SSH')]	  [switch]    $Detailed,
        [Parameter(ParameterSetName='SSH')]   [switch]    $SystemParameters,
        [Parameter(ParameterSetName='SSH')]   [switch]    $Fan,
        [Parameter(ParameterSetName='SSH')]   [switch]    $SystemCapacity,
        [Parameter(ParameterSetName='SSH')]   [switch]    $vvSpace,
        [Parameter(ParameterSetName='SSH')]   [switch]    $DomainSpace,
        [Parameter(ParameterSetName='SSH')]   [switch]    $Descriptor,
        [Parameter(ParameterSetName='SSH')]   [String]    $DevType,
        [Parameter(ParameterSetName='SSH')]   [Switch]    $ShowRaw,
        [Parameter(ParameterSetName='SSH')]   [Switch]    $UseSSL
)
Begin 
    {	if ( $PSCmdlet.ParameterSetName -eq 'API' )
            {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                    {	$PSetName = 'API'
                    }
                else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                            {	$PSetName = 'SSH'
                            }
                    }
            }
            elseif ( $PSCmdlet.ParameterSetName -eq 'SSH' )	
            {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                    {	$PSetName = 'SSH'
                    }
                else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                        return
                    }
            }
    }
Process 
    {	switch ($PSetName)
        {   'API' 
                    {   $Result = Invoke-A9API -uri '/system' -type 'GET' 
                        if($Result.StatusCode -eq 200)
                            {	$dataPS = $Result.content | ConvertFrom-Json
                                write-host "Cmdlet executed successfully" -foreground green
                                return $dataPS
                            }
                        else
                            {	Write-Error "Failure:  While Executing Get-System" 
                                return $Result.StatusDescription
                            }
                    }
            'SSH'
                    {
                        $sysinfocmd = "showsys "
                        if ($Detailed) 			{    $sysinfocmd += " -d " 		}
                        if ($SystemParameters) 	{    $sysinfocmd += " -param "	}
                        if ($Fan) 				{    $sysinfocmd += " -fan "	}
                        if ($SystemCapacity) 	{    $sysinfocmd += " -space " 	}
                        if ($vvSpace) 			{    $sysinfocmd += " -vvspace "}
                        if ($DomainSpace) 		{    $sysinfocmd += " -domainspace "}
                        if ($Descriptor) 		{	 $sysinfocmd += " -desc "	}
                        if ($DevType) 			{    $sysinfocmd += " -devtype $DevType"}
                        write-verbose "The following command will be sent `n $Cmd"
                        $Result = Invoke-A9CLICommand -cmds  $sysinfocmd	
                        if ($ShowRaw -or $Detailed -or $VVSpace -or $Devtype -or $SystemCapacity) { Return $Result }
                        if($Result.Count -gt 1)
                            {	if ( (-not ( $Detailed -or $SystemParameters -or $Fan -or $SystemCapacity -or $VVSpace -or $DomainSpace -or $Descriptor -or $DevType)) )
                                            { 	$HeaderLine = 1
                                                $StartIndex=2
                                                $EndIndex=$Result.count-1
                                            }
                                        elseif ($DomainSpace)
                                            {	$tempFile = [IO.Path]::GetTempFileName()
                                                $HeaderLine = 'Domain,Legacy_Used,CPG_Used,CPG_Shared,CPG_Free,Unmapped,Total,Compact,Dedup,Compress,DataReduce,Overprov'
                                                Add-Content -Path $tempFile -Value $HeaderLine 
                                                $StartIndex=2
                                                $EndIndex=$Result.count-3
                                                foreach ($s in $Result[$StartIndex..$EndIndex])
                                                    {	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
                                                        Add-Content -Path $tempFile -Value $s
                                                    }
                                                $returndata = Import-Csv $tempFile
                                                Remove-Item $tempFile
                                                return $returndata	
                                            }
                                        elseif($SystemParameters -or $Descriptor)
                                            {	$ReturnData=@{}
                                                if ($Descriptor) { $StartIndex = 1} else {StartIndex = 4}
                                                foreach ($s in $Result[$StartIndex..($Result.count-1)])
                                                        {	$s = ($s.split(':')).trim() 
                                                            if ($s.count -gt 2) 
                                                                {	$s[1] = $s[1..($s.count-1)] -join ":"
                                                                    write-host $s[1]
                                                                }
                                                            if ( $s[0] ) 
                                                                { $ReturnData.add($s[0], $s[1]) 
                                                                }
                                                        }	
                                                return $returndata	
                                            }
                            }
                        else{	write-warning "FAILURE"
                                Return $Result
                            }	
                        $tempFile = [IO.Path]::GetTempFileName()	
                        if ($Result)    {   $ResultHeader = ((($Result[$HeaderLine].split(' ')).trim()).trim('-') | where-object { $_ -ne '' } ) -join ','
                                            Add-Content -Path $tempFile -Value $ResultHeader
                                            foreach ($s in $Result[$StartIndex..$EndIndex])
                                                    {	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
                                                        Add-Content -Path $tempFile -Value $s
                                                    }	
                                            $Result = Import-Csv $tempFile
                                            Remove-Item $tempFile
                                        }
                        return $Result
                    }
        }
    }
}

