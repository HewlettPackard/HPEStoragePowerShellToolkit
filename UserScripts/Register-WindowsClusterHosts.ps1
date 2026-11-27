function Write-HostChecklist
{
[CmdletBinding(defaultparametersetname='Status')]

    param   (   [Parameter(parametersetname='Status', mandatory, Position=1)]   [String]    $Message,
                [Parameter(parametersetname='Status')]                          [switch]    $Indent,
                [Parameter(parameterSetName='Answer', mandatory)]           
                [ValidateSet('OK','NO','FAIL','YES','N/A')]                     [string]    $Answer
            )
    if ($Indent)
        {   write-host "`t" -nonewline }
    if ( $Message )
        {   write-host "[    ] $Message"                -nonewline
            write-host $("`b" * ($Message.length+6) )   -nonewline
            write-host "TEST" -ForegroundColor yellow   -nonewline
            write-host $("`b" * 4 )                     -nonewline
            start-sleep -seconds 2
        }
    if ( $Answer )
        {   switch ($Answer)
            {   'OK'    {   write-host " $Answer " -ForegroundColor green
                        }
                'YES'   {   write-host " $Answer" -ForegroundColor green
                        }
                'NO'    {   write-host " $Answer " -ForegroundColor yellow
                        }
                'N/A'   {   write-host " $Answer" -ForegroundColor green
                        }
                'FAIL'  {   write-host "$Answer" -ForegroundColor red
                        }
            }
        }
    return
}

Function Test-WindowsPSRemote
{
[CmdletBinding()]
param   (   [Parameter(mandatory, ValueFromPipeline = $true)]      [System.Management.Automation.PSCredential]     $Credential,
            [Parameter(mandatory, ValueFromPipeline = $true)]      [String]                                        $WindowsHost
        )
process{    Write-HostCheckList "Validating corrent DNS Resolution for the given Host $WindowsHost"
            if ( [bool](Resolve-DnsName -name $WindowsHost -erroraction silentlycontinue))
                {   Write-HostChecklist -answer "OK"
                }
            else{   write-hostCheckList -answer "FAIL"
                    Write-Warning "The Given Hostname $WindowsHost does not resolve to a valid Host. Please check your DNS Resolution."
                }
            Write-HostCheckList -indent "Checking if PowerShell Remoting is enabled on the Remote Server WindowsHost" 
            if ( [bool](Test-WSMan -ComputerName $WindowsHost -ErrorAction SilentlyContinue ) )
                {   write-hostCheckList -answer "OK"
                }
            else{   Write-HostCheckList -answer "FAIL"
                    write-warning "PowerShell Remoting must be enabled to run commands against this host. From a PowerShell window on the remote host you must issue the following PowerShell command; PS:> Enable-PSRemoting -Force"
                    return $false
                }
            write-hostCheckList -indent "Testing PSRemote Credentials with the remote Server $WindowsHost"
            try {   $Inits = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { get-initiatorport } -ErrorAction stop            
                    write-hostCheckList -answer 'OK'
                    return $True
                }
            catch
                {   write-hostCheckList -answer 'FAIL'
                    $ErrorMessage = $_.Exception.Message
                    $ErrorType = $_.Exception.GetType().FullName
                    if ($ErrorMessage -like "*Access is denied*" -or $ErrorMessage -like "*Authentication failed*") 
                        {    Write-error "Bad credentials or unauthorized access for [$WindowsHost]." 
                        }
                    else
                        {   # Fallback for other WinRM issues (e.g., firewall, trusted hosts)
                            Write-error "OTHER ERROR on [$WindowsHost]: $ErrorMessage"
                        }
                    return $false
                }       
        }
}

Function Get-WindowsClusterFromNode
{   
[CmdletBinding()]
param   (   [Parameter(ValueFromPipeline = $true, mandatory)]      [System.Management.Automation.PSCredential]     $Credential,
            [Parameter(ValueFromPipeline = $true, mandatory)]      [String]                                        $WindowsHost
        )
process
{   $ReturnObj = @()
    # Check to See if part of a Windows Failover Cluster.   
    write-hostCheckList "Detect if Failover Clustering Service installed and running on node $WinHost" 
    $FCService = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { get-windowsFeature } -ErrorAction stop | where-object { $_.name -like 'Failover-Clustering'}
    if ( $FCService.Installed -eq $True )
        {       write-hostCheckList -answer "OK"
                $ClusterRunning=$true
                write-hostCheckList "Failover Clustering Obtain Node List from $WinHost." 
                write-hostCheckList -answer "OK"
                $Nodes = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { get-clusternode } -ErrorAction stop 
                foreach ( $Node in $Nodes )
                    {   $NodeName = $Node.Name
                        $ClusName = $Node.Cluster
                        write-host "`tCluster $ClusName : Node $NodeName" -ForegroundColor green
                    }
                return [PSCustomObject]@{   WindowsHost = [string[]]$($Nodes | select-object Name).Name 
                                            ClusterName = $ClusName    
                                            ClusterServiceInstalled = $true
                                            Credential = $Credential 
                                        }
                }
    else{   write-hostCheckList -answer "N/A"
            return [PSCustomObject]@{    ClusterServiceInstalled = $false 
                            WindowsHost = $WindowsHost  
                            Credential = $Credential
                        }
        }
}
}

Function Test-HpeMPIO
{
[CmdletBinding()]
param   (   [Parameter(mandatory,ValueFromPipelineByPropertyName = $true)]      [System.Management.Automation.PSCredential]     $Credential,
            [Parameter(mandatory,ValueFromPipelineByPropertyName = $true)]      [String]                                        $WindowsHost,
            [Parameter()]               [boolean]                                       $RebootIfNeeded = $false
        )
process
        {   $MPIOObject = @{}
            write-hostCheckList "MPIO feature is installed on $WindowsHost." 
            $MPIOService = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { get-windowsFeature } -ErrorAction stop | where-object { $_.name -like 'Multipath-IO'}
            if ( $MPIOService.Installed -eq $True )
                            {   write-hostCheckList -answer 'OK'
                                $MPIOObject += @{ 'MPIOInstalled' = $True }
                            }
                        else{   write-hostCheckList -answer "FAIL"
                                if ( $RebootIfNeeded )
                                    {   Write-host "`t`tAttempting to install the MPIO Feature on node $WinHost."
                                        invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { Add-WindowsFeature -Name ‘Multipath-IO’ }  
                                        $MPIOObject += @{ 'MPIOInstalled' = 'Installing' }
                                    }
                                else{   Write-warning "`t`tCan not install MPIO as the -RebootIfNeeded option was not selected. To install this feature, rerun this script using the -rebootifneeded switch. "
                                        write-warning "`t`tAlternativly you can issue the following command directly on the host named $WindowsHost : PS:> Add-WindowsFeature -Name 'Multipath-IO' -Restart"
                                        $MPIOObject += @{ 'MPIOInstalled' = $false }
                                        return $ReturnObject
                                }
                            }

            write-hostCheckList -indent "Alletra MP B10000 Registered with MPIO on $WindowsHost."
            $MPIORegistration = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { get-MSDSMSupportedHW | where-object { $_.ProductId -like 'VV' -and $_.VendorId -like '3PARdata'} } 
            if ( $MPIORegistration )
                {   write-hostCheckList -answer "OK"
                    write-host "`t`tProduct ID= $($MPIORegistration.ProductId), Verdor ID = $($MPIORegistration.VendorId)" -ForegroundColor DarkGray   
                    $MPIOObject += @{ 'MPIORegisteredB10K' = $True }         
                }
            else 
                {   write-hostchecklist -answer "FAIL" 
                    if ( $RebootIfNeeded )
                        {   write-host "`t`tAttempting to add the HPE Alletra MP B10K setting to MPIO on host $WindowsHost."
                            invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { New-MSDSMSupportedHW -VendorId VV -ProductId 3PARdata } 
                            $MPIOObject += @{ 'MPIORegisteredB10K' = 'Installing' }         
                        }
                    else{   write-host "`t`tCan not install MPIO as the -RebootIfNeeded option was not selected. To install this feature, rerun this script using the -rebootifneeded switch. "
                            write-warning "`t`tAlternativly you can issue the following command directly on the host named $WinHost : PS:> New-MSDSMSupportedHW -VendorId VV -ProductId 3PARdata"
                            $MPIOObject+= @{ 'MPIORegisteredB10K' = $False }
                            return $MPIOObject
                    }
                }
            write-hostCheckList -indent "Alletra MP B10000 Path Verification State set correctly (enabled) on $WindowsHost."
            $MPIOPathVerify = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { (get-MPIOSetting).PathVerificationState } 
            if ( $MPIOPathVerify -like 'Enabled' )
                {   write-hostCheckList -answer "OK"  
                    $MPIOObject += @{ 'MPIOPathVerify' = $True }         
                }
            else 
                {   write-hostchecklist -answer "FAIL" 
                    write-host "`t`tAttempting to set the DSM setting for Path verification state on how $WindowsHost."
                    invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { Set-MPIOSetting -newPathVerificationState Enabled }
                    $MPIOObject += @{ 'MPIOPathVerify' = 'Installing' }         
                }
  
            write-hostCheckList -indent "MPIO feature requires Reboot on $WindowsHost. (OK = Does not require REBOOT)"        
            $RestartNeeded = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue) -ne $null } -ErrorAction stop
            if ( $RestartNeeded -ne $True)
                {   write-hostCheckList -answer "OK"
                    $MPIOObject += @{ 'MPIORequiresReboot' = $false }         
                }
            else 
                {   write-hostCheckList -answer "FAIL"
                    if ($RebootIfNeeded)
                        {   Write-host "`t`tDetecting if the Nodes C:\ Drive is Bitlockered, as a reboot with changes may require your recovery key:"
                            $DriveBitlocker = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { Get-BitLockerVolume -MountPoint C: }
                            if ( $DriveBitLocker.VolumeStatus -like "FullyEncrypted" )
                                {   Write-host "`t`tThe Boot Drive (C:) on host $WindowsHost is Fully Encrypted, after reboot if the drive is Bitlocker Locked and requires a recovery key, use the following;"
                                    $DriveKey = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { (Get-BitLockerVolume -MountPoint C:).KeyProtector.RecoveryPassword }
                                    Write-host "`t`t$DriveKey"
                                    $MPIOObject += @{ 'BitlockerKey' = $DriveKey }         
                                    $MPIOObject += @{ 'MPIORequiresReboot' = 'Rebooting'}         
                                }
                            else{   Write-host "`t`tThe Boot Drive (C:) on $WindowsHost does not appear to be Bitlocker encrypted."
                                }
                            write-host "`t`tIssuing Reboot Command now. "
                            # invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { restart-computer -force }
                            write-warning "A Restart was issued to $WindowsHost. Please wait until that host returns before running this script again."
                        }
                    else{   write-host "`t`tThis command cannot issue a reboot command to host $WindowsHost. You need to either rerun this script with the -RebootIfRequired option or reboot that node yourself."
                            $MPIOObject += @{ 'MPIORequiresReboot' = $True }        
                        }
                    return $MPIOObject
                }
            return $MPIOObject
}
}

Function Update-HPEFCHBA
{
[CmdletBinding()]
param   (   [Parameter(mandatory, ValueFromPipeline = $true)]       [System.Management.Automation.PSCredential]         $Credential,
            [Parameter(mandatory, ValueFromPipeline = $true)]       [String]                                            $WindowsHost,
            [Parameter(ValueFromPipeline = $true)]                  [Boolean]                                           $RebootIfNeeded = $false
        )
Process
{   # Set all Dedicated Versions for Code
    # HPE SN1600Q / HPE SN1610Q / HPE SN1700Q Firmware 9.15.15 Driver 
                $SN1600QMinFWVersion    = "9.15.05"
                $SN1600QMinFWVersionURL = "https://downloads.hpe.com/pub/softlib2/software1/sc-windows-fw-sys/p1958280170/v280417/cp070515.exe"
                $SN1600QFWFile          = "cp070515.exe"
                $SN1600QDriverVersion   = '9.4.11.20'
                $SN1600QDriverURL       = 'https://downloads.hpe.com/pub/softlib2/software1/sc-windows/p253438872/v280731/cp070602.exe'
                $SN1600QDriverFile      = 'cp070602.exe'
    # HPE SN1600E / SN1610E / SN1700E / SN1710E Firmware 14.4.731.21
                $SN1600EMinFWVersion    = "14.4.731.21"
                $SN1600EMinFWVersionURL = "https://downloads.hpe.com/pub/softlib2/software1/sc-windows-fw-sys/p499646890/v283424/cp071322.exe"
                $SN1600EFWFile          = 'cp071322.exe'
                $SN1600EDriverVersion   = '14.4.624.1'
                $SN1600EDriverURL       = "https://downloads.hpe.com/pub/softlib2/software1/sc-windows/p1044485669/v285309/cp071874.exe"
                $SN1600EDriverFile      = 'cp071874.exe'
    # Detect FC HBAs and Firmware/Drivers
    write-hostCheckList "2+ x Fibre Channel HBAs are Present on $WindowsHost."
    $FCInits = invoke-command -ComputerName $WindowsHost -Credential $cred -ScriptBlock { Get-InitiatorPort | where-object { $_.ConnectionType -like 'Fibre Channel' } }
    if ( $FCInits.count -ge 2 ) 
        {           write-hostCheckList -answer "OK"
                    # Lets load the Drivers Locally to this machine.
                    $NewDir = $PSScriptRoot + '\Drivers'
                    write-host "`tEnsuring $NewDir exists on local machine, if not will create." -ForegroundColor darkgray
                    New-Item -ItemType Directory -Force -Path $NewDir | Out-Null
                    $FCObjects=@()
                    foreach ( $FCHBA in $FCInits) 
                        {   # $FCList = @()
                            $TestPath = invoke-command -ComputerName $WindowsHost -Credential $cred -ScriptBlock { test-path -path "C:\drivers" -pathtype Container }
                            if ( -not $TestPath )
                                {   write-host "`tDrivers Folder does not exist. Creating it a C:\Drivers Folder on $WindowsHost." -ForegroundColor darkgray
                                    $Result = invoke-command -ComputerName $WindowsHost -Credential $cred -ScriptBlock { New-Item -ItemType Directory -path "C:\Drivers" }
                                }
                            $FCDetails = invoke-command -ComputerName $WindowsHost -Credential $cred -ScriptBlock { Get-CimInstance -Namespace "root\WMI" -ClassName MSFC_FCAdapterHBAAttributes }
                            $FCDetail = $FCDetails | where-object { $_.InstanceName -like $FCHBA.InstanceName }
                            if ( -not $FCDetail)
                                {   write-host "`tWorld Wide Port Names = $($FCHBA.PortAddress) " -ForegroundColor darkgray                    
                                }
                            else{   write-host "`tWorld Wide Port Names = $($FCHBA.PortAddress), HBA Model = $($FCDetail.Model) : Driver = $($FCDetail.DriverVersion) : Firmware = $($FCDetail.FirmwareVersion) : Serial Number = $($FCDetail.SerialNumber)" -ForegroundColor darkGray  
                                    if      (   $FCDetail.Model -like 'SN1600Q' -or $FCDetail.Model -like 'SN1610Q' -or $FCDetail.Model -like 'SN1700Q' -or $FCDetail.Model -like 'SN1710Q' )
                                        {   # Lets ensure that the drivers are always downloaded locally. 
                                            $HBACard = 'Qlogic' 
                                            $HBAFWVer       = $SN1600QMinFWVersion    
                                            $HBAFWURL       = $SN1600QMinFWVersionURL 
                                            $HBAFWFile      = $SN1600QFWFile         
                                            $HBADriverVer   = $SN1600QDriverVersion  
                                            $HBADriverURL   = $SN1600QDriverURL       
                                            $HBADriverFile  = $SN1600QDriverFile      
                                        }
                                    elseif  (   $FCDetail.Model -like 'SN1600Q' -or $FCDetail.Model -like 'SN1610Q' -or $FCDetail.Model -like 'SN1700Q' -or $FCDetail.Model -like 'SN17100Q' )
                                        {   # Lets ensure that the drivers are always downloaded locally. 
                                            $HBACard = 'Emulex'
                                            $HBAFWVer       = $SN1600EMinFWVersion
                                            $HBAFWURL       = $SN1600EMinFWVersionURL
                                            $HBAFWFile      = $SN1600EFWFile
                                            $HBADriverVer   = $SN1600EDriverVersion
                                            $HBADriverURL   = $SN1600EDriverURL
                                            $HBADriverFile  = $SN1600EDriverFile
                                        }
                                    else{   $HBACard = 'Unsupported' 
                                        }                              
                                    if      (   $HBACard -eq 'Qlogic' -or $HBACard -eq 'Emulex' )   
                                        {   $FCList = @{    'HBAModel'          = $FCDetail.Model
                                                            'HBAFirmware'       = $FCDetail.FirmwareVersion 
                                                            'HBADriver'         = $FCDetail.DriverVersion 
                                                            'HBAFirmwareTarget' = $HBAFWVer
                                                            'HBADriverTarget'   = $HBADriverVer
                                                            'WWPN'              = $FCHBA.PortAddress
                                                        }  
                                            # First lets see if a exist Drivers Directory exists on the current Script running server.
                                            #### FIRMWARE
                                            $NewFile = $NewDir+"\"+$HBAFWFile
                                            # write-host "`tHBA $($FCDetail.Model) firmware version $HBAFWVer, filename = $HBAFWFile" -ForegroundColor darkgray
                                            Write-HostChecklist -Indent "Downloading Minimum Firmware to LOCAL Machine. (Ok = Downloading, NA = Already Exists)"
                                            if ( Test-path -path $NewFile )
                                                {   write-hostCheckList -answer "N/A"
                                                }
                                            else{   invoke-webrequest -uri $HBAFWURL -outfile $NewFile
                                                    unblock-file $NewFile
                                                    Write-hostChecklist -answer "OK"
                                                }
                                            Write-HostChecklist -Indent "Downloading Minimum Firmware for $($FCDetail.Model) firmware version $HBAFWVer, filename = $HBAFWFile to Remote Machine $WinHost in C:\Drivers\"
                                            $FileSession = New-PSSession -ComputerName $WindowsHost -Credential $cred
                                            Copy-Item -Path $NewFile -Destination "C:\Drivers\" -ToSession $FileSession
                                            Write-hostChecklist -answer "OK"
                                            
                                            #### DRIVERS
                                            $NewFile = $NewDir+"\"+$HBADriverFile
                                            Write-HostChecklist -Indent "Downloading Minimum Driver for $($FCDetail.Model) Driver version $HBADriverVer, filename = $HBADriverFile to LOCAL Machine. (Ok = Downloading, NA = Already Exists)" 
                                            if ( Test-path -path $NewFile )
                                                {   write-hostCheckList -answer "N/A"
                                                }
                                            else{   invoke-webrequest -uri $HBADriverURL -outfile $NewFile
                                                    unblock-file $NewFile
                                                    Write-hostChecklist -answer "OK"
                                                }

                                            Write-HostChecklist -Indent "Downloading Minimum Driver for $($FCDetail.Model) Driver Versions $HBADriverVer, filename = $HBADriverFile to Remote Machine $WindowsHost in C:\Drivers\"   
                                            Copy-Item -Path $NewFile -Destination "C:\Drivers\" -ToSession $FileSession
                                            remove-PSSession -session $FileSession
                                            Write-hostChecklist -answer "OK"

                                            Write-HostChecklist -Indent "Validating Minimum Firmware Versions Installed."
                                            if ( [Version]$FCDetail.FirmwareVersion -lt [version]$HBAFWVer )
                                                {   write-hostCheckList -answer "FAIL"
                                                    write-host "`tMinimum Firmware version of $HBAFWVer not installed on this HBA." -ForegroundColor red
                                                    Write-hostCheckList -indent "If the $WindowsHost C:\ Drive Bitlockered, a reboot may require your recovery key: (N/A = Drive is not Bitlockered)"
                                                    $DriveBitlocker = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { Get-BitLockerVolume -MountPoint C: }
                                                    if ( $DriveBitLocker.VolumeStatus -like "FullyEncrypted" )
                                                        {   Write-hostCheckList -answer "OK"
                                                            $DriveKey = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { (Get-BitLockerVolume -MountPoint C:).KeyProtector.RecoveryPassword }
                                                            Write-host "`tRecovery Key = $DriveKey" -ForegroundColor darkgray
                                                            $ReturnObject[$IndexLocation]+= @{ 'BitlockerKey' = $DriveKey }
                                                        }
                                                    else{   Write-hostChecklist -answer "N/A"
                                                        }
                                                    if ($RebootIfNeeded)
                                                        {   write-host "`tAttempting to do a Firmware Update on the HBA. This will require a server reboot."
                                                            invoke-command -ComputerName $WindowsHost -Credential $cred -ScriptBlock { Start-Process -filepath "C:\Drivers\$($Using:HBAFWFile)" -argumentlist "/s /f /unf" -wait -nonewwindow }
                                                            write-host "`t`tIssuing Reboot Command now. "
                                                            invoke-command -ComputerName $WinHost -Credential $Credential -scriptblock { restart-computer -force }
                                                            write-warning "A Restart was issued to $WindowsHost. Please wait until that host returns before running this script again."                                    
                                                            $FCList += @{ 'FirmwareStatus' = 'Updating' }
                                                            return $FCList
                                                        }
                                                    else{   Write-warning "Firmware Updated required, either manually update this firmware on host $WindowsHost and reboot that server or rerun this script using the -RebootIfNeeded option."
                                                            Write-Warning "To Update the Firmware on the node issue the following command: Start-process C:\Drivers\$HBAFWFile -argumentlist '/s /f /unf' -wait -nonewwindow"
                                                            $FCList+= @{ 'FirmwareStatus' = 'NON-Compliant' }                                                                                                                 
                                                        } 
                                                }
                                            else{   write-hostCheckList -answer "OK"
                                                    $FCList+= @{ 'FirmwareStatus' = 'OK' }
                                                }
                                                            
                                            Write-HostChecklist -Indent "Validating Minimum Driver Versions Installed." 
                                            if ( [Version]$FCDetail.DriverVersion -lt [version]$HBADriverVer )
                                                {   write-hostCheckList -answer "FAIL"
                                                    write-host "`tMinimum Driver version of $HBADriverVer not installed on this HBA." -ForegroundColor red    
                                                    if ($RebootIfNeeded) 
                                                        {   write-host "`tAttempting to do a Driver Update on the HBA." -ForegroundColor darkgray
                                                            invoke-command -ComputerName azurelocalnode2 -Credential $cred -ScriptBlock { Start-Process -filepath "C:\Drivers\$($Using:HBADriverFile)" -argumentlist "/s /f /unf" -wait -nonewwindow }
                                                            $HBADriverStatus = 'Updating'
                                                        }
                                                    else{   Write-warning "Driver Updated required, either manually update on host $WindowsHost and reboot that server or rerun this script using the -RebootIfNeeded option."
                                                            Write-Warning "To Update the Firmware on the node issue the following command: Start-process C:\Drivers\$HBADriverFile -argumentlist '/s /f /unf' -wait -nonewwindow"
                                                            $HBADriverStatus = 'OutOfCompliance'
                                                        }                                                                                      
                                                }
                                            else{   write-hostCheckList -answer "OK"
                                                    $HBADriverStatus = 'OK'
                                                }
                                            $FCList+= @{ 'DriverStatus' = $HBADriverStatus }
                                            $FCObjects += $FCList
                                        }
                                }
                    }                
                    $FCRunning=$True
                }
            else{   write-hostCheckList -answer "NO"
                    $FCRunning=$False
                    $FCObjects = $false
                }
            return $FCObjects
}
}
function Register-WindowsHost
{
[CmdletBinding()]
param   (   [Parameter(ValueFromPipelineByPropertyName = $true,mandatory)]      [System.Management.Automation.PSCredential]     $Credential,
            [Parameter(ValueFromPipelineByPropertyName = $true,mandatory)]      [String[]]                                      $WindowsHost,
            [Parameter(mandatory)]      [System.Management.Automation.PSCredential]     $ArrayCredential,
            [Parameter(mandatory)]      [String]                                        $ArrayIP,
            [Parameter()]               [Switch]                                        $RebootIfNeeded
        )

Process{
    $ReturnObject = @()
    if ($RebootIfNeeded) { $RIN = $True } else { $RIN = $false }
    foreach ( $WinHost in $WindowsHost)
        {   # Set up the initial return Object
            $WinObj = @( [ordered]@{ 'Hostname' = $WinHost } )
            $ReturnObject += $WinObj 
        }

    foreach ( $WinHost in $WindowsHost) 
        {   # Test to make sure that PowerShell Remoting works with the provided credential object   
            $IndexLocation = 0..($ReturnObject.count -1) | where-object { $ReturnObject[$_].Hostname -eq $WinHost }
            if ( Test-WindowsPSRemote -WindowsHost $WinHost -Credential $Credential)
                {   $ReturnObject[$IndexLocation]+= @{ RemotePowerShellEnabled = $True }
                }
            else{   $ReturnObject[$IndexLocation]+= @{ RemotePowerShellEnabled = $False }
                }
        }

    foreach ( $WinHost in $WindowsHost )
        {   # Check to See if part of a Windows Failover Cluster.   
            write-hostCheckList "Failover Clustering Service installed and running on node $WinHost." 
            $IndexLocation = 0..($ReturnObject.count -1) | where-object { $ReturnObject[$_].Hostname -eq $WinHost }
            $ReturnVal = Get-WindowsClusterFromNode -Credential $cred -WindowsHost $WinHost 
            $Hostlist = $ReturnVal.WindowsHost
            $ClusInstalled = $ReturnVal.ClusterServiceInstalled
            $ClusterName = $ReturnVal.ClusterName
            $ReturnObject[$IndexLocation]+= @{  ClusterNodes = $HostList 
                                                ClusterInstalled = $ClusInstalled
                                                ClusterName = $ClusterName
                                            }
        }

    foreach ( $WinHost in $WindowsHost )    
        {   # Detect is MPIO is installed and configured correctly.
            $IndexLocation = 0..($ReturnObject.count -1) | where-object { $ReturnObject[$_].Hostname -eq $WinHost }
            $ReturnObject[$IndexLocation]+= Test-HpeMPIO -Credential $Credential -WindowsHost $WinHost -RebootIfNeeded $RIN
        }

    foreach ( $WinHost in $WindowsHost ) 
    {   # Detect FC HBAs and Firmware/Drivers
        $IndexLocation = 0..($ReturnObject.count -1) | where-object { $ReturnObject[$_].Hostname -eq $WinHost }
        If ($RebootIfNeeded){ $RIN = $true } else { $RIN = $false }
        $UpdateReturnData = Update-HPEFCHBA -WindowsHost $WinHost -Credential $Credential -rebootIfNeeded $RIN 
        $ReturnObject[$IndexLocation]+=  @{ HBAs = $UpdateReturnData }
    }
    foreach ( $WinHost in $WindowsHost )
    {   # Detect if iSCSI is running, and what the iSCSI IQN is   
        write-hostCheckList "iSCSI Service is running." 
        $IndexLocation = 0..($ReturnObject.count -1) | where-object { $ReturnObject[$_].Hostname -eq $WinHost }
        [bool]$iSCSIRunning = invoke-command -ComputerName $WinHost -Credential $cred -ScriptBlock { (get-service | where-object {$_.name -like 'MSiSCSI' }).Status -like 'Running'}
        $ReturnObject[$IndexLocation]+= @{ 'iSCSIEnabled' = $iSCSIRunning }
        if ( $iSCSIRunning)
            {   # invoke-command -ComputerName azurelocalnode2 -Credential $cred -ScriptBlock { get-service | where-object {$_.name -like 'MSiSCSI' }}
                write-hostCheckList -answer "OK"
                $iSCSIInits = invoke-command -ComputerName $WinHost -Credential $Credential -scriptblock { get-initiatorport | where-object { $_.ConnectionType -like 'iSCSI' }} -ErrorAction stop            
                write-host "`tThe iSCSI IQN is: $($iSCSIInits.NodeAddress)" -ForegroundColor green
                $ReturnObject[$IndexLocation]+= @{ 'iSCSIIQN' = $iSCSIInits.NodeAddress }
            }
        else{   write-hostCheckList -answer "NO"                
            }
    }

    foreach ( $WinHost in $WindowsHost )
    {   # Ensure that either FC or iSCI is loaded/configured
        write-hostCheckList "Either FC or iSCSI in installed and running."
        $iSCSIInits = invoke-command -ComputerName $WinHost -Credential $Credential -scriptblock { get-initiatorport } -ErrorAction stop            
        if ( $FCRunning -or $iSCSIRunning)
            {   write-hostCheckList -answer "OK"
            }
        else{   write-hostCheckList -answer "FAIL"
            }
    }

    ############### Ensure the HPE PowerShell Storage Toolkit is installed locally. 
    write-hostCheckList "Ensure Local HPEStorage 4.2+ Toolkit Installed."
    if ( (Get-Module -name HPEStorage 6> $NULL).Version -ge 4.2)
        {   write-hostCheckList -answer "OK"
            write-hostCheckList "Validate RestAPI Connectivity to the Alletra MP B10000. (OK = Connecting using given Credentials, N/A = already connected, FAIL = Given Credentials dont work)" 
            $A9Vols = Get-A9Volume -erroraction SilentlyContinue 6> $null
            if ( $A9Vols )
                {   write-hostCheckList -answer "N/A"
                }
            else{   # Lets Attampt to connect
                    $connect = connect-hpeSAN -ArrayNameOrIPAddress $ArrayIP -ArrayType AlletraMP-B10000 -Credential $ArrayCredential 6> $null
                    $A9Vols = Get-A9Volume -erroraction SilentlyContinue 6> $null
                    if ( $A9Vols )
                        {   write-hostCheckList -answer "OK"
                        }
                    else{   write-hostCheckList -answer "FAIL"
                            return
                        }   
                }
        }
    else{   write-hostCheckList -answer "FAIL"
            write-warning "Please download an install the newest HPE Storage PowerShell Toolkit version 4.2 or newer."
            return
        }

    foreach ( $WinHost in $WindowsHost )
        {   # Detect if The Array Based Host Groups match the Local FC HBAs 
            write-hostCheckList "FC Service on Hosts is running." 
            $IndexLocation = 0..($ReturnObject.count -1) | where-object { $ReturnObject[$_].Hostname -eq $WinHost }
            if ( $ReturnObject[$indexLocation].FCEnabled )
                {   # First Lets check to see if this servers HBAs are already Registerd. 
                    Write-hostCheckList -answer "OK"
                    $WWPNSet = $($ReturnObject[$IndexLocation].HBAs).WWPN
                    $ListOfHostRecords = @()
                    foreach($LocalWWPN in $WWPNSet)
                    {   write-hostCheckList "Checking WWPN $LocalWWPN for a valid Host Record on the Array" 
                        $HostRecordList = Get-A9Host 6> $Null| Where-object { $($_.FCPaths).wwn -like $LocalWWPN }
                        if ( $HostRecordList )
                            {   write-hostchecklist -answer "OK"
                                write-host "`tThe Host Record set = $($HostRecordList.name)"
                                $ListOfHostRecords += $($HostRecordList.name)
                            }
                        else{   write-hostchecklist -answer "FAIL"
                                write-host "`tNo Host record for $LocalWWPN exists on this array."
                            }
                    }
                    Write-HostCheckList "Checking if all WWPNs are Registered to Host Records."
                    if ( $ListOfHostRecords.count -eq $WWPNSet.count )
                        {   write-hostCheckList -answer "OK"
                        }
                    else{   write-hostCheckList -answer "FAIL"
                        }
                    if ( $ListOfHostRecords )
                    {   write-host "`tThe Singular Host Record Group that contain these WWPNs is $($ListOfHostRecords | get-unique)"
                    }

                }
            else{   Write-hostCheckList -answer "N/A"
                }
        }
    
    foreach ( $WinHost in $WindowsHost )
        {   # Detect if The Array Based iSCSI Targets and compair to local NICs 
            write-hostCheckList "If iSCSI Service is running. Detect the Array Based iSCSI Target Ports." 
            $IndexLocation = 0..($ReturnObject.count -1) | where-object { $ReturnObject[$_].Hostname -eq $WinHost }
            $ArrayiSCSIPorts = Get-A9Port 6>$null | where-object { $_.ModeDescription -like 'TARGET' } | where-object { $_.iSCSIName }
            if ($ArrayiSCSIPorts)
                {   write-hostchecklist -answer "OK"
                } 
            else{   write-hostchecklist -answer "NA"

                }
            $ArrayTargs = @()
            foreach ($TargPort in $ArrayiSCSIPorts)
            {   $IPI = $TargPort.iSCSIPortInfo
                write-host "`t`tiSCSI Target IP Address = $($IPI.IPAddr) with Subnet Mask = $($IPI.Netmask)" 
                $ThisTarg = @{  'IPAddress'     = $IPI.IPAddr 
                                'IPSubnet'      = $IPI.Netmask
                            }
                $ArrayTargs += $ThisTarg
            }
            $ReturnObject[$IndexLocation]+= @{ 'ArrayISCSITargets' = $ArrayTargs }

<#            [bool]$iSCSIRunning = invoke-command -ComputerName $WinHost -Credential $cred -ScriptBlock { (get-service | where-object {$_.name -like 'MSiSCSI' }).Status -like 'Running'}
            $ReturnObject[$IndexLocation]+= @{ 'iSCSIEnabled' = $iSCSIRunning }
            if ( $iSCSIRunning)
                {   # invoke-command -ComputerName azurelocalnode2 -Credential $cred -ScriptBlock { get-service | where-object {$_.name -like 'MSiSCSI' }}
                    write-hostCheckList -answer "OK"
                    $iSCSIInits = invoke-command -ComputerName $WinHost -Credential $Credential -scriptblock { get-initiatorport | where-object { $_.ConnectionType -like 'iSCSI' }} -ErrorAction stop            
                    write-host "`tThe iSCSI IQN is: $($iSCSIInits.NodeAddress)" -ForegroundColor green
                    $ReturnObject[$IndexLocation]+= @{ 'iSCSIIQN' = $iSCSIInits.NodeAddress }
                }
            else{   write-hostCheckList -answer "NO"                
                }
        
#>
        }
    foreach ( $WinHost in $WindowsHost )
    {   # Check to make sure a Array Host Group Exists

    }
    foreach ( $WinHost in $WindowsHost )
    {   # Inventory the Cluster for a list of Cluster Shared Volumes
        write-hostCheckList "Failover Clustering Obtain CSV List for host $WinHost."
        $CSVs = invoke-command -ComputerName $WinHost -Credential $Credential -scriptblock {Get-ClusterSharedVolume | Select-Object Name, State, @{Name="VolumePath"; Expression={$_.SharedVolumeInfo.FriendlyVolumeName}} }
        if ( $CSVs ) 
            {   write-hostCheckList -answer "OK"
            }
        else{   write-hostCheckList -answer "FAIL"
            }
        foreach ( $CSV in $CSVs )
            {   write-host "`tHost = $WinHost, Name = $($CSV.Name), VolumePath = $($CSV.VolumePath) " -ForegroundColor Green
            }

        write-hostCheckList "Gettting list of WinDisks for host $WinHost." 
        $WinDisks = invoke-command -ComputerName $WinHost -Credential $Credential -scriptblock { get-disk } -ErrorAction stop 
        write-hostCheckList -answer "OK"
        foreach ($WinDisk in $WinDisks)
            {       write-host "`tHost = $Winhost, Disk $($WinDisk.DiskNumber), Manufacturer = $($WinDisk.Manufacturer), Unique ID = $($WinDisk.UniqueID), Status = $($WinDisk.OperationalStatus), Size = $($WinDisk.Size)" -ForegroundColor green
            }

        write-hostCheckList "Matching up SAN Based CSVs to WinDisks on host $WinHost." 
        write-hostCheckList -answer "OK"
        $CSVs = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock {Get-ClusterSharedVolume | Select-Object Name, State, @{Name="VolumePath"; Expression={$_.SharedVolumeInfo.FriendlyVolumeName}} }
        $WinDisks = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { get-disk } -ErrorAction stop
        Foreach ( $CSV in $CSVs)
        {   $vp =$($CSV.VolumePath)   
            $VolInfo = invoke-command -ComputerName $WinHost -Credential $Credential -scriptblock { Get-Item -path $using:vp }
            $DiskInfo =  invoke-command -ComputerName $WinHost -Credential $Credential -scriptblock { Get-Item $using:vp | Get-Volume | get-partition | Get-Disk }
            foreach ( $WinDisk in $WinDisks)
            {   if ( $DiskInfo.Number -eq $WinDisk.Number )
                    {  write-host "`tHost = $WinHost, Match $VolInfo = Windisk $($WinDisk.Number) = $($WinDisk.UniqueID) " -ForegroundColor green
                    }
            }
        }
    }

    write-hostCheckList "Mapping CSVs to Alletra MP B10000 Volumes."
    $CSVs = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock {Get-ClusterSharedVolume | Select-Object Name, State, @{Name="VolumePath"; Expression={$_.SharedVolumeInfo.FriendlyVolumeName}} }
    $WinDisks = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { get-disk } -ErrorAction stop
    write-hostCheckList -answer "OK"
    Foreach ( $CSV in $CSVs)
    {   $vp =$($CSV.VolumePath)   
        $VolInfo = invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { Get-Item -path $using:vp }
        $DiskInfo =  invoke-command -ComputerName $WindowsHost -Credential $Credential -scriptblock { Get-Item $using:vp | Get-Volume | get-partition | Get-Disk }
        foreach ( $WinDisk in $WinDisks)
        {   if ( $DiskInfo.Number -eq $WinDisk.Number )
                {  if ( $Windisk.Manufacturer -like '3PARdata')
                    {   # Appears to be a matching disk, and 3PAR, lets find its VVol
                        $ArrayVol = Get-A9Volume 6>$null | where-object {$_.wwn -like $WinDisk.UniqueId }
                        if ( $ArrayVol )
                            {   write-host "`t $VolInfo = AlletraVolume $($ArrayVol.Name)" -ForegroundColor green
                            }
                    }
                }
        }
    }
return ( $ReturnObject | convertto-json -depth 4 | convertfrom-json )

}

}

<#
Step 1 : If the host is a remote host, 
    Test the credential on the remote host
    test the DNS entry for the host. does it resolve.

Step 2 : Detect if member of a cluster
    Step 2A: Detect other nodes in the cluster

Step 3 : Detect if MPIO is installed
    Detect if reboot is still required
    detect if the 3PAR MPIO is claimed

Step 3 : detect if FC WWPNs exist
    Step 3A : Find if a Host Record exists with the FC
    Step 3B : If no record exists create one
    Step 3c : If Record exists, verify the memberships (FC)
    Step 3d : If Record exists, verify the Record Name
    Step 3e : If Record exists, verify the if part of HostSet
    Step 3f : If Record exists, verify the if volumes Mapped    
    
Step 4 : detect if iSCSI IQN exists
    Step 3c : If Record exists, verify the memberships (IQN)
    Step 3d : If Record exists, verify the Record Name
    Step 3e : If Record exists, verify the if part of HostSet
    Step 3f : If Record exists, verify the if volumes Mapped    

Step 5 : detect existing iSCSI sessions
    Create the iSCSI sessions

Step 5 : detect how many paths exist


Step 6 : If 
#>
