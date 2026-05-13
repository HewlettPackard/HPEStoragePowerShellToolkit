===============================================================================================
								CONTENT
===============================================================================================
OVERVIEW
	Features of HPE Alletra MP B10K and Alletra 9000 and Primera and 3PAR PowerShell Toolkit
	New features in HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit
	Supported Host Operating Systems
	Supported Storage Platforms
	
PRE-REQUISITES FOR HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT
	Establish Secure Shell connections
	Recommendations for Installation of POSH SSH Module
	Starting and Configuring the WSAPI server
	
INSTALLING HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT 4.0.0.0

POWERSHELL CMDLETS HELP
	Connection Management cmdlets
	Session Management
Major Command Changes
	List of changes from 4.0.0 to 4.2.0
	SSH Verbose reporting
	AutoLogging
	Codebase Refactoring
===============================================================================================

===============================================================================================
	OVERVIEW
===============================================================================================
The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit provides storage administrators 
the convenience of managing HPE Alletra 9000 or HPE Primera or HPE 3PAR Storage Systems from a Microsoft PowerShell environment.

New Features in the HPE Toolkit 4.2.0.0
=======================================
The following command was added to the toolkit to assist customers in connecting to all array types.

Import-HPESANCertificate : 
        This command allows you to download the arrays Certificate to the local certificate store to allow SSH and HTTPS connectivity. 
        The PowerShell window must be an adminstrative window as adding a certificate to the local store requires this authority. This only needs to be done once
        and your array connection commands will continue to use the localled saved certificate to connect.
                PS:> import-hpesanCertificate -ArrayNameOrIPAddress 192.168.20.19 

The number of commands has been reduced as commands have been combined, as well as obsolete commands have been removed from arrays that don't support them. 
Please see the detailed list of all changes later in this document under "Detailed List of Changes"

Features of HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit
-----------------------------------------------------------------------------------------------
HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit 3.5 works with PowerShell 5.0 or later up However PowerShell 7+ is recommended. 
 
It can be used in the following ways:

1. With Native HPE Primera and HPE 3PAR storage CLI command.
	When you run the cmdlets, the following actions take place:
	- A secure connection to the HPE Alletra 9000 or HPE Primera and HPE 3PAR storage is established over a secure shell.
	- The native HPE Alletra 9000 or HPE Primera or HPE 3PAR storage CLI command and parameters are formed based on the PowerShell cmdlet and parameters.
	- The native HPE Alletra 9000 or HPE Primera or HPE 3PAR storage CLI command is executed.
	- The output of the cmdlets is returned as PowerShell objects. This output can be piped to other PowerShell cmdlets for further processing.

2. With HPE Alletra 9000 or HPE Primera or HPE 3PAR storage Web Service API (WSAPI 1.6.4 & 1.7)
	When you run a WSAPI-based cmdlet, the following actions take place:
	- A secure connection using WSAPI is established as a session key (credential).  Unused session keys expire after 15 minutes.
	- The WSAPI and parameters are formed based on the PowerShell cmdlet and parameters.
	- The WSAPI uses the HTTPS protocol to enable programmatic management of HPE Alletra 9000 or HPE Primera or HPE 3PAR storage servers and provides 
  		client access to web services at specified HTTPS locations. Clients communicate with the WSAPI server using HTTPS methods and data structures represented with JSON.
	-The output of the cmdlets is returned as PowerShell objects. This output can be piped to other PowerShell cmdlets for search.

New features in HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit 4.0.0
-----------------------------------------------------------------------------------------------
� PowerShell Core 5.x and PowerShell 7.z (recommended) support for CLI and WSAPI connections
� Support for HPE Alletra MP B10K OS 9.3.0 with CLI and WSAPI based cmdlets
� Support for HPE Alletra 9000 OS 9.3.0 with CLI and WSAPI based cmdlets
� Support for HPE Primera OS 4.3.0 with CLI and WSAPI based cmdlets
� Support for HPE 3Par OS 3.3.0+ with CLI and WSAPI based cmdlets

Supported Host Operating Systems
-----------------------------------------------------------------------------------------------
� Windows Server 2025/2022/2019/2016
� Windows 11/10

Supported Storage Platforms
-----------------------------------------------------------------------------------------------
� HPE Alletra 9000
� HPE Primera 630, 650, and 670 series
� HPE 3PAR Storage 7000, 9000, 8000, and 20000 series

Establish Secure Shell connections
-----------------------------------------------------------------------------------------------
To Establish Secure Shell connections you must have either of the following software installed:
� Open source POSH SSH Module

Installation of POSH SSH Module
-----------------------------------------------------------------------------------------------
POSH SSH module is hosted in GitHub at https://github.com/darkoperator/Posh-SSH and the PSGallery at https://www.powershellgallery.com/packages/Posh-SSH
All source code for the cmdlets and the module is available there and it is licensed under the BSD 3-Clause License. 

Refer to the below link for more details:
http://www.powershellmagazine.com/2014/07/03/posh-ssh-open-source-ssh-powershell-module/

Starting and Configuring the WSAPI server
-----------------------------------------------------------------------------------------------
WSAPI uses HPE Alletra 9000 or HPE Primera or HPE 3PAR CLI commands to start, configure, and modify the WSAPI server.

For more information about using the CLI, see:
	� HPE Alletra 9000 or HPE Primera or HPE 3PAR Command Line Interface Administrator Guide
	� HPE Alletra 9000 or HPE Primera or HPE 3PAR Command Line Interface Reference For more information, see http://www.hpe.com/info/storage/docs/
	  
Starting the WSAPI server
-----------------------------------------------------------------------------------------------
The WSAPI server does not start automatically. Using the CLI, enter start-wsapi to manually start the WSAPI server.

Configuring the WSAPI server
-----------------------------------------------------------------------------------------------
To configure WSAPI, enter setwsapi in the CLI.

NOTE:
The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit also provides cmdlets for starting and configuring the WSAPI server. 
So users have a choice to start and configure the WSAPI server either from CLI or from PowerShell Toolkit.

The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit Cmdlets for starting and configuring the WSAPI server:
	Stop-A9Wsapi  
	Start-A9Wsapi  
	Get-A9Wsapi
	Set-A9Wsapi
	
========================================================================================================================
	INSTALLING HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT 4.0.0 from GitHub or My HPE Software License Page
========================================================================================================================
The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit is provided as a zipped package. 
1. Unzip the package and copy the folder HPEStoragePowerShellToolkit to any location: 
   Ex: C:\Home\Projects\HPEStoragePowerShellToolkit

2. Install the POSH SSH module to establish a secure connection. For more information on 
   installing the POSH SSH module, refer to the pre-requisites section.

3. ForHPE Alletra 9000 or HPE Primera or HPE 3PAR Web Service API Cmdlets, you must configure the WSAPI server first, 
   to establish a secure connection. Refer to the pre-requisites section for starting and configuring the WSAPI server.

4. Open an interactive PowerShell console.

5. Go to the location where �HPEStoragePowerShellToolkit� is saved in Step 1.
   PS C :> cd "C:\Home\PSToolkit\HPEStoragePowerShellToolkit� (Press Enter)
   PS C:\Home\PSToolkit\HPEStoragePowerShellToolkit>

6. Import all the Toolkit PowerShell modules into the supported Windows host. 
   Follow the steps:

	- HPEStoragePowerShellToolkit contains one PowerShell Data file (HPEStoragePowerShellToolkit.psd1):
   	
	NOTE: PSD1 file is used as the file extension for PowerShell Modules Manifests files and it 
	stores all module manifests. While importing the HPEStoragePowerShellToolkit.psd1, it imports all PowerShell modules into the Host.

	- To import the PowerShell Data file, execute the command:
	  Ex: PS C:\Home\PSToolkit\HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit> Import-Module .\HPEStorage.psd1 (Press Enter)


===============================================================================================
	POWERSHELL CMDLETS HELP
===============================================================================================

To get the list of cmdlets offered by HPE Storage PowerShell Toolkit, 
run the below cmdlet:
	PS C:\> Get-Command -module HPEStorage 

This will return a small list of commands that are used ONLY for connecting your powershell Session. Once a session has been connected, the additional toolkits will be loaded which represent the additional commands specific to that storage platform. i.e. If you connect to a Nimble Storage Device, only the Nimble Storage additional commands will be loaded.

	PS C:\> Get-Command -module HPEAlletra9000andPrimeraand3Par_CLI 
	PS C:\> Get-Command -module HPEAlletra9000andPrimeraand3Par_API 
	PS C:\> Get-Command -module HPE3ParFilePersona

	* this last sub-module is only availabe on 3par type arrays.

These commands will show you the commands available for each of the connection types. Using the Connection command in the base Module will attempt both a CLI and API connection at the same time. If the API connectivity is not enabled, and the connection attempt fails, the module containing those API based commands will not be loaded. Likewise If the CLI SSH module is unavailabe or the CLI connection is denied, the CLI based module will not be loaded. 

To get cmdlet specific help, run the cmdlet:
	PS C:\> Get-Help <cmdlet name>	

To get cmdlet specific help using the -example option, run the cmdlet:
	PS C:\> Get-Help <cmdlet name> -examples
	
To get cmdlet specific detailed help using the -detailed option, run the cmdlet:
	PS C:\> Get-Help <cmdlet name> -detailed

To get cmdlet specific help using the �full option, run the cmdlet:
	PS C:\> Get-Help <cmdlet name> -full


Connection Management cmdlets
-----------------------------------------------------------------------------------------------
Connect-HPESan                   		:- Builds a SAN connection object and if the array type is Alletra9K or Alletra MP B10K based, will attempt both a SSH and API type connection

NOTE:  Toolkit command name and parameter name is case insensitive whereas parameter values are case sensitive.
Session Management (Using Session Variable)
-----------------------------------------------------------------------------------------------

To run cmdlets using sessions, follow the below steps:

1. Running these connection commands will create a global variable for the connected session, All further commands will use this session
   
2. Run the cmdlets as follows
   Example:-
   PS:> Connect-HPESAN -ArrayNameOrIPAddress '1.2.3.4' -credential (get-Credential) -ArrayType Alletra9000

   PS:> Get-A9Version 

Changes from the HPEStorage Toolkit version 4.0.0 to 4.2.0
==========================================================
You will find that Almost all commands have been altered in some form to conform to PowerShell Best practices as well as to limit command sprawl which makes the toolkit more consumable and easier to use for new users.
Thes changes fall into a number of categoriesd.
	1: Commands that are completely covered by the API based version of the same command. In these cases the CLI version of the command has been removed.
	2: Commands that perform simple functions that are better combined in a single 'Set' type command. In this case the combined command replaces the many seperate commands. 
	3: Command only works agains a specific platform that is not use. If you connect to a Alletra 9000 series, you don't need access to the 3Par Only File Persona commands. These commands will appear only if you connect to a 3Par type array
	4: Many commands dont follow standard naming process. The command names were normalized.
	5: In very common commands, descriptors have been added to make the object returned more human readable, i.e. ProvisioningType = 2 means little, so an added field ProvisioningTypeDescriptoin is added with human readable words like 'Thin Provisioned and Deduplicated'
	6: In All commands, the DryRun option has been removed as the SSH type operation does not lend itself towards the interactive sessions that a Dry Run requires.
	7: In All Commands, the term VV (Virtual Volume) has simply been replace with the noun Volume as it is far easier for new users to decipher, and matches other platforms.
	8: In All commands, single letter non-descriptive parameters such as -d to mean seconds, has been replaced with a more proper descriptive parameter name like -Interval
	9: In All commands, the parameter Volume will refer to the VolumeName, and VolumeId will require a Volume Id. We will not user parameters like VV | VV_ID | VVName | VVId. 
	10: Long running commands such as get-A9Event will now include status bars to warn the user of the expected longer timeframe.
	11: In many commands that return proper objects, there are parameters that are only used for filtering. That filtering type of operation if more easily done from the powershell command line and for simplicity those unneeded parameters have been removed.
	12: Some feature have been depreciated on all platforms, those commands have been removed.

Below are the specfic commands
		New-A9Host_CLI,						--> 	New-A9Host
		Remove-A9Host_CLI,					--> 	Remove-A9Host
		Remove-A9HostSet_CLI, 				--> 	Remove-A9HostSet
		Get-A9VVList,						--> 	Get-A9Volume
		Get-A9VVSet,						--> 	Get-A9VolumeSet
		New-A9VV_CLI,						--> 	New-A9Volume
		New-A9VVSet_CLI,					--> 	New-A9VolumeSet
		Update-A9VVProperties_CLI,			--> 	Set-A9Volume
		Set-A9Host_CLI,						--> 	Set-A9Host
		Test-A9CLIObject,					-->		No longer used
		Get-A9WsAPISession,					--> 	Get-A9CIM
		Show-A9UnrecognizedTargetsInfo,		--> 	Get-A9vLUN
		Get-A9EventLog, 					--> 	Get-A9Event
		Get-A9FCPort,						--> 	Get-A9Port
		Get-A9FCPortToCSV,					--> 	Get-A9Port | ConvertTo-CSV
		Get-A9Cert							--> 	Get-A9Certificate
		Approve-A9Disk						--> 	Set-A9PhysicalDisk
		Switch-A9Disk						--> 	Set-A9PhysicalDisk
		Stop-A9CIM							--> 	Set-A9CIM
		Start-A9Cim							--> 	Set-A9CIM
		Get-A9Space_CLI 					-->		Get-A9CPGSpaceDataReports 
		Update-A9VVSetProperties_CLI 		--> 	Set-A9VVSet
		New-A9RemoteCopyTarget_CLI 			-->  	New-A9RCopyTarget
		Start-A9RCopyGroup_CLI 				--> 	Start-A9RCopyGroup
		Stop-A9RCopyGroup_CLI				-->		Stop-A9RCopyGroup
		Sync-A9RCopyGroup_CLI 				-->		Sync-A9RCopyGroup
		Start-A9RCopy_CLI					-->		Start-A9RCopyGroup
		Stop-A9RCopy_CLI 					-->		Stop-A9RCopy
		Sync-A9RCopy_CLI					-->		Sync-A9RCopy
		Disable-A9RCopyVv_CLI				-->		Remove-A9VvFromRCopyGroup
		Disable-A9RCopyTarget_CLI			-->		Remove-A9TargetFromRCopyGroup
		Remove-A9RCopyGroup_CLI				-->		Remove-A9RCopyGroup
		Remove-A9RCopyTargetFromGroup_CLI	-->		Remove-A9TargetFromRCopyGroup
		Remove-A9RCopyTarget_CLI			-->		Remove-A9RCopyGroup
		Remove-A9RCopyVVFromGroup			-->		Remove-A9VvFromRCopyGroup
		New-A9RCopyGroup_CLI				-->		New-A9RCopyGroup
		Add-A9RCopyVv_CLI					-->		Add-A9VvToRCopyGroup
		Show-A9RCopyTransport_CLI			-->		Get-A9RCopyLink
		Add-A9RCopyTarget_CLI				-->		Add-A9TargetToRCopyGroup
		Get-A9RCopy_CLI						-->		Get-A9RCopyInfo
		Set-A9RCopyGroupPol_CLI				-->		Update-A9RCopyGroup (Rename to Set-A9RCopyGroup)
		Set-A9RCopyTarget_CLI				-->		Update-A9RCopyTarget
		Set-A9RCopyTargetName_CLI			-->		Update-A9RCopyTarget (Rename to Set-A9RCopyTarget)
		Set-A9RCopyTargetWitness_CLI		-->		Set-A9RCopyTarget
		Show-A9NodeProperties				-->		Get-A9Node
		Get-A9SystemReportCpgSpace			-->		Get-A9CPGSpaceDataReports (renamed to Get-A9CPGSpaceReport)		
		Get-A9SystemReporterStatCache		--> 	Get-A9CacheReport
		Get-A9SystemReporterStatCacheMemoryPages-->	Get-A9CacheReport replaces the functionality of the  so the Get-A9SystemReporterStatCacheMemoryPages can be removed
		Get-A9SystemReporterStatCPU			--> 	Get-A9CPUReport
		Get-A9SystemReporterPhysicalDiskSpace->		Get-A9PDCapacityReports,Get-A9PDSpaceReport
		Get-A9CPGStatisticsDataReports		-->		Get-A9SystemReporterIOPs -CPGIOPsReport
		Get-A9PDStatisticsDataReports		-->		Get-A9SystemReporterIOPs -DiskIOPsReport
		Get-A9PortStatisticsReport			-->		Get-A9SystemReporterIOPs -PortIOPsReport
		Get-A9QoSStatisticsReport			-->		Get-A9SystemReporterIOPs -QoSIOPsReport
		Get-A9RCopyStatisticsReports 		-->		Get-A9SystemReporterIOPs -RCopyIOPsReport
		Get-A9SystemReporterStatPhysicalDisk-->		Get-A9SystemReporterIOPs -DiskIOPsReport
		Get-A9SystemReporterStatLD 			-->		removed 
		Get-A9SystemReporterVvSpace 		-->		Get-A9VVSpaceReport
		New-A9VvListGroupSnapshot 			--> 	New-A9VVSnapshot -Volumename vol1,vol2,vol3
		New-A9VvCopy_CLI					--> 	New-A9VVPhysicalCopy 	--> Change name to New-A9VVCopy
		New-A9GroupVvCopy_CLI				--> 	New-A9VVSetPhysicalCopy --> Rename to New-A9VVSetCopy
		Sync-A9RecoverDRRcopyGroup			-->		Set-A9RCopyGroup -Sync
		Get-A9RCopyGroupTarget				-->		Get-A9RCopyGroup -TargetName
		Get-A9RCopyGroupVV					-->		Get-A9RCopyGroup -TargetVolumeName
		Get-A9SystemReporterStatVLun		-->		Get-A9vLunIOPsReport
		Get-A9SystemReporterStatqos			-->		Get-A9QoSIOPsReport
		Get-A9SystemReporterStatPort		-->		Get-A9PortIOPsReport
		Get-A9VV							-->		Get-A9Volume
		Get-A9VVStats						--> 	Get-A9Volume -Statistics
		Get-A9VVSpaceDistribution			--> 	Get-A9Volume -SpaceDistribution
		Remove-A9VV							-->		Remove-A9Volume
		New-A9VV							-->		New-A9Volume
		Set-A9VV							-->		Set-A9Volume
		Get-A9PDCapacityReports 			-->		Get-A9PDCapacityReport
		Get-A9PDSpaceReports				-->		Get-A9PDSpaceReport 
		Get-A9CPUStatisticalDataReports		-->		Get-A9CPUReport 
		Get-A9CacheMemoryStatisticsDataReports-->	Get-A9CachStatReport
		Update-A9HostSet					--> 	Set-A9HostSet
		New-A9VVSnapshot					-->		New-A9Snapshot
		Update-A9System						-->		Set-A9System
		Set-A9Host_CLI						-->		Set-A9Host
		New-A9HostSet_CLI					-->		New-A9HostSet

The Following commands were removed and that functionality was added to the command on the right using the specfic parameter
		Get-A9SystemReporterStatLink		--> 	Get-A9SystemReport -CacheReport
		Start-A9LD_CLI						--> 	Set-A9LogicalDisk -Start
		Compress-A9LD						--> 	Set-A9LogicalDisk -consolidate -trimonly
		Comfirm-A9LD						-->		Set-A9LogicalDisk -fixerror -recover -progress
		Get-A9LogicalDiskChunklet			--> 	Get-A9LogicalDisk -LogicalDiskChunklet

The following Commands were consolidated into parent 'Set' commands
		Stop-A9WSAPI						--> 	Set-A9WsAPI -Start
		Start-A9WsAPI						--> 	Set-A9WsAPI -Stop
		Move-A9ChunkletToSpare				--> 	Move-A9Chunklet
		Move-A9RelocPhysicalDisk			--> 	Move-A9Chunklet -PhysicalDeviceToSpare
		Move-A9RelocPhysicalDisk			--> 	Move-A9Chunklet -RelocateChunklet
		Move-A9ClearPhysicalDisk			--> 	Move-A9Chunklet -ClearPhysicalDevice
		Move-A9PhysicalDiskChunkletToSpare	--> 	Move-A9Chunklet -ChunkletToSpare
		Start-A9vv_CLI						--> 	Set-A9VV_CLI -start
		Stop-A9VV_CLI						--> 	Set-A9VV_CLI -stop
		Test-A9VV_CLI						--> 	Set-A9VV_CLI -test
		Update-A9VVSetProperties_CLI		--> 	Set-A9VV_CLI
		Show-A9VVolStorageContainerVM_CLI 	-->		Get-A9VASAStorageContainer -ShowVASAStorageContainerVM
		Get-A9HostListPersona				-->		Get-A9Host -ListPersona
		Get-A9HostWithFilter				--> 	Get-A9Host
		Show-A9ToCGen						-->		Get-A9ToCGen
		Show-A9SystemResources				--> 	Get-A9ToCGen
		New-A9VVGroupSnapshot				-->		New-A9VVSnapshot (now covers Groups)
		Resize-A9VV							--> 	Set-A9VV -resize
		Compress-A9VV 						--> 	Set-A9VV -compress
		Reset-A9iSCSIPort 					--> 	Set-A9iSCSIPort
		Test-A9Disk							--> 	Set-A9Disk -Diag | Set-A9Disk -Scrub
		Compress-A9CPG						--> 	Set-A9CPG -compress
		Reset-A9VVSetPhyscialCopy			-->		Set-A9VolumeSetCopy -reset
		Move-A9VVSetPhyscialCopy			-->		Set-A9VolumeSetCopy -move
		Stop-A9VVSetPhyscialCopy			-->		Set-A9VolumeSetCopy -Stop
		Update-A9VVSetPhyscialCopy			-->		Set-A9VolumeSetCopy -Update
		Update-A9VVSetProperties_CLI		--> 	Set-A9Volume 
		Stop-A9VVPhysicalCopy				-->		Set-A9VolumeCopy -stop
		Move-A9VVPhysicalCopy				-->		Set-A9VolumeCopy -Promote
		Update-A9VVPhysicalcopy				--> 	Set-A9VolumeCopy -StopPromote
		Resync-A9VVPhysicalCopy				-->		Set-A9VolumeCopy -Resync
		New-A9VVSetPhysicalCopy				--> 	New-A9VolumeSetCopy
		New-A9PhyscialCopy					--> 	New-A9VolumeCopy
		Update-A9Host						--> 	Set-A9Host
		Start-A9RCopyGroup 					--> 	Set-A9RCopyGroup -Start
		Stop-A9RCopyGroup 					--> 	Set-A9RCopyGroup -Start
		Sync-A9RCopyGroup 					--> 	Set-A9RCopyGroup -Sync
		Restore-A9CopyGroup					--> 	Set-A9RCopyGroup -Restore
		Get-A9RCopyLink						-->		Get-A9RCopyInfo -LinkName
		Get-A9SystemReportHistogramPhysicalDisk	--> Get-A9SystemReporterHistogram -PhysicalDiskHistogram
		Get-A9SystemReportHistogramLogicalDisk	--> Get-A9SystemReporterHistogram -LogicalDiskHistogram
		Get-A9SystemReportHistogramPorrt	--> 	Get-A9SystemReporterHistogram -PortHistogram
		Get-A9SystemReportHistogramvLun		--> 	Get-A9SystemReporterHistogram -vLunHistogram
		Get-A9CacheReport					-->		Get-A9SystemReporter -CacheReport
		Get-A9CPUReport						-->		Get-A9SystemReporter -CPUReport
		Show-A9Battery						-->		Get-A9SystemInfo -ShowBatteryInfo
		Show-A9FirmwareDB					-->		Get-A9SystemInfo -ShowFirmwareDBInfo
		Show-A9NodeEnvironmentStatus		-->		Get-A9SystemInfo -ShowEnviornmentalInfo
		Get-A9SystemManager					-->		Get-A9SystemInfo -ShowSysMgrInfo
		Show-A9NetworkDetail				-->		Get-A9SystemInfo -ShowNetworkInfo
		Show-A9SystemResourcesSummary		-->		Get-A9SystemInfo -ShowResourceInfo
		Show-A9Node							-->		Get-A9SystemInfo -ShowNodeInfo
		Get-A9HistogramChunklet				-->		Get-A9Histogram -ChunkletHistogram        
		Get-A9HistogramLogicalDisk			-->		Get-A9Histogram -LogicalDiskHistogram     
		Get-A9HistogramPhysicalDisk			-->		Get-A9Histogram -PhysicalDiskHistogram   
		Get-A9HistogramRemoteCopyVv			-->		Get-A9Histogram -RemoteCopyVVHistogram        
		Get-A9HistogramPort					-->		Get-A9Histogram -PortHistogram   
		Get-A9HistogramVLun					-->		Get-A9Histogram -vLunHistogram  
		Get-A9HistogramVv					-->		Get-A9Histogram -VolumeHistogram
		Get-A9PhyscialDiskSpaceReport		-->		Get-A9SpaceReport -PhysicalDiskSpaceReport
		Get-A9CPGSpaceReport				--> 	Get-A9SpaceReport -CPGSpaceReport
		Get-A9VVSpaceReport					-->		Get-A9SpaceReport -VolumeSpaceReport
		Get-A9SystemReportCPGSpace			--> 	Get-A9SpaceReport -CPGSpaceReport
		Get-A9SystemReportCPGSpace			--> 	Get-A9SpaceReport -LogicalDiskSpaceReport
		Set-A9StatisticsCollectionPhysicalDiskChunklets -->  Set-A9StatisticsChunklets -physicalDiskId
		Set-A9RCopyTargetPol_CLI			--> 	Target Policies are no longer supported
	  	Remove-A9VvLogicalDiskCpgTemplates	-->		Templates no longer needed/supported
		Update-A9Host						--> 	Set-A9Host
		Show-A9PDMappingtoVV_CLI			--> 	Get-A9Mapping -PhysicalDisk
		Show-A9VvMappedToPD					-->		Get-A9Mapping -ShowVolumeToPhysicalDiskMapping
		Show-A9VvpDistribution				-->		Get-A9Mapping -ShowVolumeToLogicalDiskMapping
		Show-A9LdMappingToVvs_CLI			--> 	Get-A9Mapping -LogicalDiskId
		Set-A9VVProperties_CLI				-->		Set-A9Volume_CLI
		Set-A9VVSpace_CLI					--> 	Set-A9Volume_CLI -freespace
		Show-A9SystemReporterStatIscsi		--> 	Get-A9SystemReporterStat -ShowiSCSIStats
		Show-A9SystemReporterStatIscsiSession-->	Get-A9SystemReporterStat -ShowiSCSISessionSttts
		Show-A9SystemReporterStatRCopy		-->		Get-A9SystemReporterStat -ShowRCopyStats
		Get-A9StatCacheMemoryPages			-->		Get-A9Statistics -ReturnCacheStats
		Get-A9StatChunklets					-->		Get-A9Statistics -ReturnChunkletStats
		Get-A9CPUStatisticalDataReports_CLI	--> 	Get-A9Statistics -ReturnCPUStats
		Get-A9LogicalDiskStatisticsReports_CLI-->	Get-A9Statistics -ReturnLogicalDiskStats
		Get-A9StatisticLinkUtilization		-->		Get-A9Statistics -ReturnLinkUtilizationStats
		Get-A9PortStatisticsReports_CLI 	-->		Get-A9Statistics -ReturnPortStats
		Get-APhysicalDiskStatisticsReports_CLI-->	Get-A9Statistics -ReturnPhysicalDiskStats
		Get-A9RCopyStatisticalReports_CLI	-->		Get-A9Statistics -ReturnRemoteCopyVolumeStats
		Get-A9vLunStatisticsReports_CLI		-->		Get-A9Statistics -ReturnVLunStats
		Get-A9VvStatisticsReports			-->		Get-A9Statistics -ReturnVolumeStats
		Get-A9iSCSIStats					--> 	Get-A9Statistics -ReturniSCSIStats
		Show-A9FCOEStatistics				-->		Get-A9Statistics -ReturnFCOEStats
		Compress-A9VV_CLI					-->		Set-A9Volume_ClI -Compress
		Add-A9VV_cli						-->		Set-A9Volume_cli -Admit
		Import-A9VV_CLI						-->		Set-A9Volume_cli -import
		Optimize-A9PhysicalDisk				--> 	Set-A9Disk -optimize
		Get-A9HostPorts_CLI					-->		Get-A9Port_CLI
		Show-A9PortiSCS						--> 	Get-A9Port_CLI -ShowiSNS
		Show-A9PortDevices_CLI				-->		Get-A9PortDevice_CLI
		New-A9RCopyGroupCPG_CLI				-->		New-A9RCopyGroup_CLI
		Set-A9RCopyGroupPeriod_CLI			-->		Set-A9RCopyGroup_CLI
		
The following Commands were renamed to follow best practices
		Update-A9Host_CLI 					--> 	Set-A9Host_CLI
		Get-A9Space 						-->		Get-A9Space_CLI
		Set-A9NodesDate 					--> 	Set-A9Date	- And added using local time option
		Show-A9ISCSIStatistics				--> 	Get-A9iSCSIStats
		remove-a9disk						--> 	Remove-A9PhysicalDisk
		Set-A9VVolStorageContainer        	-->  	Set-A9VASAStorageContainer
		Show-A9VVolStorageContainer_CLI   	-->		Get-A9VASAStorageContainer
		Update-A9VV 						-->		Set-A9Volume
		Get-A9Users							--> 	Get-A9User
		Get-A9WSAPIConfigInfo			 	-->		Get-A9WsAPI
		Update-A9Domain						--> 	Set-A9Domain
		Move-A9Domain						--> 	Move-A9DomainObject
		Show-A9iSCSISession					-->		Get-A9iSCSISession
		Show-A9VvScsiReservations			-->		Get-A9VvScsiReservations
		Show-A9Peer_CLI						-->		Get-A9Peer_CLI
		Push-A9VVCopy						-->		Set-A9VolumeCopy -UpdateVolume
		Push-A9GroupSnapVolume				-->		Set-A9VolumeSnapshot -PromoteGroupSnapVolume
		Push-A9SnapVolume					-->		Set-A9VolumeSnapshot -PromoteSnapVolume
		Push-A9VolumeCopy					-->		Set-A9VolumeCopy -PromoteVolume

The Following Commands have been relegated to only 3Par devices and no longer appear for other platforms.
		Join-A9Federation
		New-A9Federation, 
		Set-A9Federation, 
		Remove-A9Federation
		Show-A9Federation
		Get-A9SystemReporterStatfssnapshot
		New-A9Flashcache_cli
		Set-A9FlashCache_CLI
		Remove-A9Flashcache_cli
		Show-A9EEProm
		Get-A9SystemReporterRegionIODensity

The following commands have been removed as they have been retired from the current codebase.
	The Template technology has been removed from the current codebase, and since Powershell can automate, templates are no longer needed. Removing the following commands
		Show-A9Template	
		Set-A9Template_CLI
		Optimize-A9Node		--> The underlying CLI TuneNodeCh no longer exists, was never a supported CLI command.
		Optimize-A9LD		--> The underlying CLI TuneLD no longer exists, was never a supported CLI command.

	The command Set-A9VVSnashot has been expanded to support the creation of single Volume Snapshots, Groups of Snapshots, or complete Volume Sets

	The Following are new commands added to support additional functions.
		Find-A9Command		--> Helps a user find a CLI call a command uses, or helps find a powershell command that uses a known CLI command.
		Set-A9RCopyService	--> Allows the starting and stoping of the RCopy Service on the array.

Known Issues
------------------------------------------------------------------------------------------------
Currently there is a fault in the command 'Reset-A9Node' for Alletra9000 and Alletra MP B10000 platforms. This bug will be fixed in a future bug release (4.0.1)

Major Design Changes
-------------------------------------------------------------------------------------------------
- Added support for the HPE Alletra Storage MP B10000 Platform
- All File Persona Commands have been moved into a seperate module since they only apply to 3Par users, and only load when connecting to a 3par type array.
- Removing the File Persona Commands from the Main Stream as well as refactoring code, reduces the command count an additional 25 commands.
* Support for the new Alletra MP, 9000 OS version 9.6

Major Changes introduced in the previous (3.5.0) toolkit
-------------------------------------------------------------------
These are retained in this changes document to support customers updating from previous versions of the toolkit to this version who skip version 3.5.0. 

- SSH Verbose reporting
	In the case of running a SSH based (CLI based) command, if the option -verbose is used the command will show the raw SSH Command being sent to the array.

- SSH Raw output return
	If the command uses an SSH (CLI based) connection, and returns a powershell object, by using the -ShowRaw option, you can have the command instead return the raw text output. This can be valuable 
	when the array may be running out of date firmware and a question arises is the PowerShell object is correctly mapping the columns to from the raw output to the columes. The raw output on some commands
	may also be easier to read if you don't need to object based nature of the returned data.

- Codebase Refactoring
	The previous version of the toolkit was 75,967 lines of code. The new code base has been reduced to 32,000+ lines by utilizing PowerShell best practices such as using parameter sets instead of complex
	test conditions inside of functions as well as refactoring to relocate commonalities into common internal functions among other changes. 



