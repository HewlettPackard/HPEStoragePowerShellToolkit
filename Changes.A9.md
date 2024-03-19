===============================================================================================
								CONTENT
===============================================================================================
OVERVIEW
	Features of HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit
	New features in HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit
	Supported Host Operating Systems
	Supported Storage Platforms
	
PRE-REQUISITES FOR HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT
	Establish Secure Shell connections
	Recommendations for Installation of POSH SSH Module
	Starting and Configuring the WSAPI server
	
INSTALLING HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT 3.5

POWERSHELL CMDLETS HELP
	Connection Management cmdlets
	Session Management

Major Command Changes
	
===============================================================================================

===============================================================================================
	OVERVIEW
===============================================================================================
The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit provides storage administrators 
the convenience of managing HPE Alletra 9000 or HPE Primera or HPE 3PAR Storage Systems from a Microsoft PowerShell environment.

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

New features in HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit 3.1
-----------------------------------------------------------------------------------------------
� PowerShell Core 6.x and PowerShell 7 support for CLI and WSAPI connections
� Support for HPE Alletra 9000 OS 9.3.0 with CLI and WSAPI based cmdlets
� Support for HPE Primera OS 4.3.0 with CLI and WSAPI based cmdlets

� HPE Primera and HPE 3PAR CLI cmdlets for the following:
	- Adaptive Optimization(AO)
	- CPG Management
	- Disk Enclosure Management
	- Domain Management
	- File Persona Management
	- Flashcache
	- Health and Alert Management
	- Host Management
	- Inventory Management
	- Maintenance Mode
	- Node Subsystem Management
	- Performance Management
	- Replication
	- Service Commands
	- SnapShot Management
	- Sparing
	- Storage Federation
	- System Manager
	- Task Management
	- CIM Management
	- User Management
	- VASA
	- Virtual Volume Management
	- vLUN Management
	- Web Services API (WSAPI)

� HPE 3PAR WSAPI v1.6.4 cmdlets for the following:
	- NVMe for portProtocol and hardwaretype enumeration.
	- SCM disk type support for system reporters (CPG space report, physical disk space report, 
	  and physical disk statistical data report).
	- No check SCM size for Flash Cache creation.
	- Added deviceType property to Flash Cache query response objects.

Supported Host Operating Systems
-----------------------------------------------------------------------------------------------
� Windows Server 2022/2019/2016
� Windows 11/10

Supported Storage Platforms
-----------------------------------------------------------------------------------------------
� HPE Alletra 9000
� HPE Primera 630, 650, and 670 series
� HPE 3PAR Storage 7000, 9000, 8000, and 20000 series

Supported firmware for HPE Alletra 9000
-----------------------------------------------------------------------------------------------
� 9.3.0

Supported firmware for HPE Primera
-----------------------------------------------------------------------------------------------
� 4.0.0, 4.1.0, 4.2.0, 4.3.0

Supported firmware for HPE 3PAR
-----------------------------------------------------------------------------------------------
� 3.3.1 (MU1, MU2, MU3, MU4 & MU5)
� 3.2.2 (including all MUs)
� 3.2.1 (including all MUs)



===============================================================================================
	PRE-REQUISITES FOR HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT 3.5
===============================================================================================
Toolkit needs PowerShell 5.0 or  
Toolkit needs PowerShell 7.x and .NET Core 2.1 or above. 

Establish Secure Shell connections
-----------------------------------------------------------------------------------------------
To Establish Secure Shell connections you must have either of the following software installed:
� Open source POSH SSH Module

Installation of POSH SSH Module
-----------------------------------------------------------------------------------------------
POSH SSH module is hosted in GitHub at https://github.com/darkoperator/Posh-SSH. 
All source code for the cmdlets and the module is available there and it is licensed under the BSD 3-Clause License. 
It requires PowerShell 3.0 and .NET Framework 4.0. 

The quickest way to install the module is by running:
Ex. (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")
This will download the latest version of Posh-SSH and install it in the user�s profile. Once it finishes downloading and copying the module to the right place, it will list 
the commands available:
 
Refer to the below link for more details:
http://www.powershellmagazine.com/2014/07/03/posh-ssh-open-source-ssh-powershell-module/

You can also download it from PowerShell Gallery:
https://www.powershellgallery.com/packages/Posh-SSH/2.0.2


Starting and Configuring the WSAPI server
-----------------------------------------------------------------------------------------------
WSAPI uses HPE Alletra 9000 or HPE Primera or HPE 3PAR CLI commands to start, configure, and modify the WSAPI server.

For more information about using the CLI, see:
	� HPE Alletra 9000 or HPE Primera or HPE 3PAR Command Line Interface Administrator Guide
	� HPE Alletra 9000 or HPE Primera or HPE 3PAR Command Line Interface Reference For more information, see http://www.hpe.com/info/storage/docs/
	  
Starting the WSAPI server
-----------------------------------------------------------------------------------------------
The WSAPI server does not start automatically. Using the CLI, enter startwsapi to manually start the WSAPI server.

Configuring the WSAPI server
-----------------------------------------------------------------------------------------------
To configure WSAPI, enter setwsapi in the CLI.

NOTE:
The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit also provides cmdlets for starting and configuring the WSAPI server. 
So users have a choice to start and configure the WSAPI server either from CLI or from PowerShell Toolkit.

The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit Cmdlets for starting and configuring the WSAPI server:
	Stop-Wsapi  
	Start-Wsapi  
	Get-Wsapi
	Get-WsapiSession
	Set-Wsapi
	Remove-WsapiSession

========================================================================================================================
	INSTALLING HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT 3.1 from GitHub or My HPE Software License Page
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

These two commands will show you the commands available for each of the connection types. Using the Connection command in the base Module will attempt both a CLI and API connection at the same time. If the API connectivity is not enabled, and the connection attempt fails, the module containing those API based commands will not be loaded. Likewise If the CLI SSH module is unavailabe or the CLI connection is denied, the CLI based module will not be loaded. 

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
Connect-HPESan                   		:- Builds a SAN connection object and if the array type is Alletra9K based, will attempt both a SSH and API type connection
Connect-A9API                      		:- Builds a SAN connection object specifically with a 3Par/Primera/Alletra9K using the WSAPI
Connect-A9CLI                      		:- Builds a SAN connection object specifically with a 3Par/Primera/Alletra9K using the SSH

NOTE:  Toolkit command name and parameter name is case insensitive whereas parameter values are case sensitive.


Session Management (Using Session Variable)
-----------------------------------------------------------------------------------------------

To run cmdlets using sessions, follow the below steps:

1. Running these connection commands will create a global variable for the connected session, All further commands will use this session
   
2. Run the cmdlets as follows
   Example:-
   PS:> Connect-HPESAN -ArrayNameOrIPAddress 1.2.3.4 -credential (get-Credential) -ArrayType Alletra9000

   PS:> Get-A9Version 

Major Design Changes
-------------------------------------------------------------------------------------------------
Previous versions of the toolkit used improper PowerShell Naming Criteria and as such there were a number of command collisions with well known Microsoft PowerShell
commands such as Get-Host. To follow best practices, all Commands follow the Microsoft Recommended naming scheme as follows.

Each Command starts with an approved Verb as defined by the microsoft; Followed by a dash, and then a 2 or 3 letter designator to identify the Commands master module;
Followed by the Noun of what the verb is acting upon. If an optional action is designated, this action can be added after this noun. An example is below
- {Verb}-{VendorId}{Noun}{optionalAction}

You will note that the array non-specific connection command uses this method, and uses HPE as the Vendor ID, so 'Connect-HPESAN' where SAN represents the Noun.

You will also note that a command specifically written to support the arrays that share the Alletra9000 API/CLI use a VendorId of A9. 
Additionally commands that support Nimble Storage (and the Alletra6K) all use NS as the VendorId, and the MSA uses MSA as this VendorId.

Since the CLI based commands for Alletra 9000 and the API based commands, there were a number of collisions, As such, where collisions exist, the names of the commands 
which utilize the CLI were suffixed to add a _CLI to indicate this. You can also determine which commands use the CLI versus which use the API by reading the '.NOTES' field in the 
commands help, or by using the 'Get-Command CommandName' operation, and noting that the Module that shows in the source field will have an _CLI or _API at the end.


