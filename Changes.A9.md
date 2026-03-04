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
The following CLI based commands have changed.

	Set-A9WsAPI command has new options to both Start and Stop the WsAPI servive allowing the remove of the following;
		Stop-A9WSAPI						--> Set-A9WsAPI
		Start-A9WsAPI						--> Set-A9WsAPI
		
	Get-A9Alert detailed option removed and always recieves detrailed information. Allows the removal of the OneLine and Wide formatting options and instead uses default formatters
	
	The Following Host and VV Commands have be deduplicated such that the CLI version have been removed when a API version can accomplish the same processed;
		New-A9Host_CLI,						--> New-A9Host
		Remove-A9Host_CLI,					--> Remove-A9Host
		Remove-A9HostSet_CLI, 				--> Remove-A9HostSet
		Get-A9VVList,						--> Get-A9VV
		Get-A9VVSet,						--> Get-A9VVSet
		New-A9VV_CLI,						--> New-A9VV
		New-A9VVSet_CLI,					--> New-A9VVSet
		Update-A9VVProperties_CLI,			--> Set-A9VV
		Set-A9Host_CLI,						--> Set-A9Host
		Test-A9CLIObject,					-->	No longer used
		Get-A9WsAPISession,					--> Get-A9CIM
		Show-A9UnrecognizedTargetsInfo,		--> Get-A9vLUN
		Get-A9EventLog, 					--> Get-A9Event
		Get-A9FCPort,						--> Get-A9Port
		Get-A9FCPortToCSV,					--> Get-A9Port | ConvertTo-CSV
		Get-A9Cert							--> Get-A9Certificate
		Approve-A9Disk						--> Set-A9Disk
		Switch-A9Disk						--> Set-A9Disk
		Stop-A9CIM							--> Set-A9CIM
		Start-A9Cim							--> Set-A9CIM
		Get-A9Space_CLI 					-->	Get-A9CPGSpaceDataReports 
		
	The following command have been renamed
		Update-A9Host_CLI 	--> Set-A9Host_CLI
		Get-A9Space 		-->	Get-A9Space_CLI
		Set-A9NodesDate 	--> Set-A9Date	- And added using local time option

	The Pattern/DryRun options have been removed as a non-interactive SSH session does not allow confirmation from the following commands
		Set-A9VVSpace_CLI,	Remove-A9WsAPISession,	Compress-A9LogicalDisk,	Remove-A9Alert

	Show-A9Template has more descriptive paramters. i.e. Fit becomes Fit80Comlumns, T becomes TemplateType

	Show-A9VVMappedToPD has all parameters except PD_ID and SUM removed since PowerShell Filtering can replace those parameters

	Move-A9Chunklet has been expanded to support PD->PD, PD->Spare, Ch->Ch, CH->spare making the following commands obsolete
		Move-A9ChunkletToSpare				--> Move-A9Chunklet
		Move-A9RelocPhysicalDisk			--> Move-A9Chunklet
		Move-A9RelocPhysicalDisk			--> Move-A9Chunklet
		Move-A9ClearPhysicalDisk			--> Move-A9Chunklet
		Move-A9PhysicalDiskChunkletToSpare	--> Move-A9Chunklet

	Get-A9Alert now uses default formatters and returns proper objects. removed all unneeded options. returns detailed.

	Set-A9Alert has been greatly simplified

	Get-A9Cage have added PCI|CDM options and remove -EXP, and fixed parameter sets to prevent illegal combinations
	
	Get-A9Spare now has a progress spinner and uses formatted output.

	The following Federation Commands have be relagated to 3PAR only Arrays, allows removal for Primera/Alletra9K/AlletraMPB10K of the following commands
		Join-A9Federation
		New-A9Federation, 
		Set-A9Federation, 
		Remove-A9Federation
		Show-A9Federation

	The following Flashcache Commands have be relagated to 3PAR only Arrays, allows removal for Primera/Alletra9K/AlletraMPB10K of the following commands
		New-A9Flashcache_cli
		Set-A9FlashCache_CLI
		Remove-A9Flashcache_cli

	The Following Remote Copy Commands have be deduplicated such that the CLI version have been removed when a API version can accomplish the same processed;
		New-A9RemoteCopyTarget_CLI 		-->  	New-A9RCopyTarget
		Start-A9RCopyGroup_CLI 			--> 	Start-A9RCopyGroup
		Stop-A9RCopyGroup_CLI			-->		Stop-A9RCopyGroup
		Sync-A9RCopyGroup_CLI 			-->		Sync-A9RCopyGroup
		Start-A9RCopy_CLI				-->		Start-A9RCopyGroup
		Stop-A9RCopy_CLI 				-->		Stop-A9RCopy
		Sync-A9RCopy_CLI				-->		Sync-A9RCopy
		Disable-A9RCopyVv_CLI			-->		Remove-A9VvFromRCopyGroup
		Disable-A9RCopyTarget_CLI		-->		Remove-A9TargetFromRCopyGroup
		Remove-A9RCopyGroup_CLI			-->		Remove-A9RCopyGroup
		Remove-A9RCopyTargetFromGroup_CLI->		Remove-A9TargetFromRCopyGroup
		Remove-A9RCopyTarget_CLI		-->		Remove-A9RCopyGroup
		Remove-A9RCopyVVFromGroup		-->		Remove-A9VvFromRCopyGroup
		New-A9RCopyGroup_CLI			-->		New-A9RCopyGroup
		Add-A9RCopyVv_CLI				-->		Add-A9VvToRCopyGroup
		Show-A9RCopyTransport_CLI		-->		Get-A9RCopyLink
		Add-A9RCopyTarget_CLI			-->		Add-A9TargetToRCopyGroup
		Get-A9RCopy_CLI					-->		Get-A9RCopyInfo
		Set-A9RCopyGroupPol_CLI			-->		Update-A9RCopyGroup (Rename to Set-A9RCopyGroup)
		Set-A9RCopyTarget_CLI			-->		Update-A9RCopyTarget
		Set-A9RCopyTargetName_CLI		-->		Update-A9RCopyTarget (Rename to Set-A9RCopyTarget)
		Set-A9RCopyTargetWitness_CLI	-->		Set-A9RCopyTarget

	The Following Reports Commands have be deduplicated such that the CLI version have been removed when a API version can accomplish the same processed;
		Get-A9SystemReportCpgSpace			-->		Get-A9CPGSpaceDataReports (renamed to Get-A9CPGSpaceReport)		
		Get-A9SystemReporterStatCache		--> 	Get-A9CacheReport
		Get-A9SystemReporterStatCacheMemoryPages-->	Get-A9CacheReport replaces the functionality of the  so the Get-A9SystemReporterStatCacheMemoryPages can be removed
		Get-A9SystemReporterStatCPU			--> 	Get-A9CPUReport
		Get-A9SystemReporterPhysicalDiskSpace->		Get-A9PDCapacityReports,Get-A9PDSpaceReport
		Get-A9CPGStatisticsDataReports		-->		Get-A9CPGIOPSReport 
		Get-A9PDStatisticsDataReports		-->		Get-A9PDIOPSReport
		Get-A9PortStatisticsReport			-->		Get-A9PortIOPSReport
		Get-A9QoSStatisticsReport			-->		Get-A9QoSIOPSReport
		Get-A9RCopyStatisticsReports 		-->		Get-A9RCopyIOPsReport
		Get-A9SystemReporterStatPhysicalDisk-->		Get-A9PDIOPsReport 
		Get-A9SystemReporterStatLD 			-->		removed 
		Get-A9SystemReporterVvSpace 		-->		Get-A9VVSpaceReport

	The following were renamed
		Get-A9PDCapacityReports 			-->		Get-A9PDCapacityReport
		Get-A9PDSpaceReports				-->		Get-A9PDSpaceReport 
		Get-A9CPUStatisticalDataReports		-->		Get-A9CPUReport 
		Get-A9CacheMemoryStatisticsDataReports-->	Get-A9CachStatReport
		
	The following commands were consolidated
		Get-A9HostListPersona			-->		Get-A9Host -ListPersona
		Get-A9HostWithFilter			--> 	Get-A9Host
		Show-A9ToCGen					-->		Get-A9ToCGen
		Show-A9SystemResources			--> 	Get-A9ToCGen
		New-A9VVGroupSnapshot			-->		New-A9VVSnapshot (now covers Groups)
		Resize-A9VV						--> 	Set-A9VV -resize
		Compress-A9VV 					--> 	Set-A9VV -compress
		Reset-A9iSCSIPort 				--> 	Set-A9iSCSIPort

	The following commands used to have options to run in API and in CLI if available, in the following cases all of the CLI dependancies on parameters have been removed
		Get-A9Host
		Get-A9HostSet
		Get-A9Task
		Stop-A9Task,		
		Get-A9VV,	
		Remove-A9VVSet,	
		Set-A9VV,	
		Get-A9Vlun,	
		Remove-A9Vlun,	 
		New-A9vLun,	 
		Set-A9Host,
		New-A9VVSnapshot,	
		New-A9VVGroupSnapshot,		
		Get-A9TocGen
		Set-A9CPG
		Compress-A9CPG
	Get-A9Disk removed the Pattern option and its parameters as these are move easily accomplished using standard powershell filters. If using the API version of the command, will output using default formatters
	
	  It also adds more human readable descriptors to cryptic output.

		
	The Template technology has been removed from the current codebase, and since Powershell can automate, templates are no longer needed. Removing the following commands
		Show-A9Template	
		Set-A9Template_CLI
	The  command gives the same information as the Get-A9TOCGen, the Show-A9TocGen can be deleted

	The  Show-A9Portdevices_CLI command have been changed to prevent invalid parameter sets. 

	ConfigWebServiceAPI.PS1 has been renamed to ConfigCIMandWSAPI.ps1

	Moved the Get-A9Cim and Set-A9CIM to the new ConfigCIMandWSAPI.ps1 allowing the deletions of the CIMManagement.PS1 File.
	
	The command Get-A9Inventory is moved from inventory.ps1 to systemmanager.ps1 allows the deletiong of the file Inventory.PS1

	The following files have been renamed
		Update-A9VV 			-->	Set-A9VV
		Get-A9Users				--> Get-A9User
		Get-A9WSAPIConfigInfo 	-->	Get-A9WsAPI
		Update-A9Domain			--> Set-A9Domain
		Move-A9Domain			--> Move-A9DomainObject

	The Set-A9Domain command has been removed as it is only usable in an interactive sense which makes it do nothing for a noninteractive command.

	The following Commands have been modified to add more human readable descriptions to returned objects
		Get-A9VVSet,	Get-A9Port,		Get-A9Role

	SessionKeysAndWSAPISystemAccess.ps1 file has been eliminated

	New-A9VV now has paramter validators to help people select valid parameter options.

	Get-A9Events now returns detailed events, and since it can take time, it provides a progress bar. This also includes descriptions to describe cryptic values as well as default formatters

	WSAPIUserAndRoleInformation.PS1 has been renamed to UserRole.ps1

	SystemInformationQueriesAndManagement.ps1 has been renamed to System.PS1
	

	Get-A9CapacityInfo was moved to the System.ps1 file allowing the removal of the File AvailableSpace.PS1

	New Command Get-A9VVStats which returns default formmated data.

	The Command Set-A9ServiceCage renamed to Invoke-A9CageService

	the Command Update-A9ServiceCage features of firmware upgrade have been moved to the invoke-A9CageService command
	
	The command Set-A9VVSnashot has been expanded to support the creation of single Volume Snapshots, Groups of Snapshots, or complete Volume Sets


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



