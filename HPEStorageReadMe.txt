===============================================================================================
								CONTENT
===============================================================================================
OVERVIEW
	Features of HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit
	New features in HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit 3.1
	Supported Host Operating Systems
	Supported Storage Platforms
	
PRE-REQUISITES FOR HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT 3.1
	Establish Secure Shell connections
	Installation of POSH SSH Module
	Starting and Configuring the WSAPI server
	
INSTALLING HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT 3.1

POWERSHELL CMDLETS HELP
	Connection Management cmdlets
	Session Management
===============================================================================================






===============================================================================================
	OVERVIEW
===============================================================================================
The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit provides storage administrators 
the convenience of managing HPE Alletra 9000 or HPE Primera or HPE 3PAR Storage Systems 
from a Microsoft Windows PowerShell environment.

Features of HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit
-----------------------------------------------------------------------------------------------
HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit 3.1 works with PowerShell 3.1 or 
later up to PowerShell 5.1, PowerShell Core 6.x, and PowerShell 7. 
 
It can be used in the following ways:

1. With Native HPE Primera and HPE 3PAR storage CLI command.
	When you run the cmdlets, the following actions take place:
	- A secure connection to the HPE Alletra 9000 or HPE Primera and HPE 3PAR storage is 
	  established over a secure shell.
	- The native HPE Alletra 9000 or HPE Primera or HPE 3PAR storage CLI command and parameters 
	  are formed based on the PowerShell cmdlet and parameters.
	- The native HPE Alletra 9000 or HPE Primera or HPE 3PAR storage CLI command is executed.
	- The output of the cmdlets is returned as PowerShell objects. This output can be piped 
	  to other PowerShell cmdlets for further processing.

2. With HPE Alletra 9000 or HPE Primera or HPE 3PAR storage Web Service API (WSAPI 1.6.4 & 1.7)
	When you run a WSAPI-based cmdlet, the following actions take place:
	- A secure connection using WSAPI is established as a session key (credential). 
	  Unused session keys expire after 15 minutes.
	- The WSAPI and parameters are formed based on the PowerShell cmdlet and parameters.
	- The WSAPI uses the HTTPS protocol to enable programmatic management of HPE Alletra 9000 
	  or HPE Primera or HPE 3PAR storage servers and 
	  provides client access to web services at specified HTTPS locations. 
	  Clients communicate with the WSAPI server 
	  using HTTPS methods and data structures represented with JSON.
	-The output of the cmdlets is returned as PowerShell objects. This output can be piped 
	  to other PowerShell cmdlets for search.

New features in HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit 3.1
-----------------------------------------------------------------------------------------------
• PowerShell Core 6.x and PowerShell 7 support for CLI and WSAPI connections
• Support for HPE Alletra 9000 OS 9.3.0 with CLI and WSAPI based cmdlets
• Support for HPE Primera OS 4.3.0 with CLI and WSAPI based cmdlets

• HPE Primera and HPE 3PAR CLI cmdlets for the following:
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

• HPE 3PAR WSAPI v1.6.4 cmdlets for the following:
	- NVMe for portProtocol and hardwaretype enumeration.
	- SCM disk type support for system reporters (CPG space report, physical disk space report, 
	  and physical disk statistical data report).
	- No check SCM size for Flash Cache creation.
	- Added deviceType property to Flash Cache query response objects.

NOTE: PowerShell Core 6.x and PowerShell 7 are supported only for CLI and WSAPI connections. 
Not supported for PoshSSH Connection.

Supported Host Operating Systems
-----------------------------------------------------------------------------------------------
• Windows Server 2019
• Windows Server 2016
• Windows Server 2012 R2
• Windows Server 2012
• Windows Server 2008 R2 SP1
• Windows Server 2008 R2
• Windows Server 2008 SP1
• Windows 10
• Windows 8
• Windows 7 SP1
• Windows 7

Supported Storage Platforms
-----------------------------------------------------------------------------------------------
• HPE Alletra 9000
• HPE Primera 630, 650, and 670 series
• HPE 3PAR Storage 7000, 9000, 8000, and 20000 series

Supported firmware for HPE Alletra 9000
-----------------------------------------------------------------------------------------------
• 9.3.0

Supported firmware for HPE Primera
-----------------------------------------------------------------------------------------------
• 4.0.0, 4.1.0, 4.2.0, 4.3.0

Supported firmware for HPE 3PAR
-----------------------------------------------------------------------------------------------
• 3.3.1 (MU1, MU2, MU3, MU4 & MU5)
• 3.2.2 (including all MUs)
• 3.2.1 (including all MUs)



===============================================================================================
	PRE-REQUISITES FOR HPE Alletra 9000 AND Primera AND 3PAR POWERSHELL TOOLKIT 3.1
===============================================================================================
Toolkit needs PowerShell 3.0 or above and .NET Framework 4.0 or above. 
Toolkit needs PowerShell Core 6.x or 7.x and .NET Core 2.1 or above. 

Establish Secure Shell connections
-----------------------------------------------------------------------------------------------
To Establish Secure Shell connections you must have either of the following software 
installed:
• HPE 3PAR CLI client
• Open source POSH SSH Module

Installation of POSH SSH Module
-----------------------------------------------------------------------------------------------
POSH SSH module is hosted in GitHub at https://github.com/darkoperator/Posh-SSH. 
All source code for the cmdlets and the module is available there and it is licensed 
under the BSD 3-Clause License. 
It requires PowerShell 3.0 and .NET Framework 4.0. 

The quickest way to install the module is by running:
Ex. (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")
This will download the latest version of Posh-SSH and install it in the user’s profile. 
Once it finishes downloading and copying the module to the right place, it will list 
the commands available:
 
Refer to the below link for more details:
http://www.powershellmagazine.com/2014/07/03/posh-ssh-open-source-ssh-powershell-module/

You can also download it from PowerShell Gallery:
https://www.powershellgallery.com/packages/Posh-SSH/2.0.2


Starting and Configuring the WSAPI server
-----------------------------------------------------------------------------------------------
WSAPI uses HPE Alletra 9000 or HPE Primera or HPE 3PAR CLI commands to start, configure, and modify the WSAPI server.

For more information about using the CLI, see:
	• HPE Alletra 9000 or HPE Primera or HPE 3PAR Command Line Interface Administrator Guide
	• HPE Alletra 9000 or HPE Primera or HPE 3PAR Command Line Interface Reference
	  For more information, see http://www.hpe.com/info/storage/docs/
	  
Starting the WSAPI server
-----------------------------------------------------------------------------------------------
The WSAPI server does not start automatically. Using the CLI, enter startwsapi to manually 
start the WSAPI server.

Configuring the WSAPI server
-----------------------------------------------------------------------------------------------
To configure WSAPI, enter setwsapi in the CLI.

NOTE:
The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit also provides cmdlets for starting 
and configuring the WSAPI server. 
So users have a choice to start and configure the WSAPI server either from CLI or 
from PowerShell Toolkit.

The HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit Cmdlets for starting and 
configuring the WSAPI server:
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
1. Unzip the package and copy the folder HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit to any location: 
   Ex: C:\Home\Projects\HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit

2. Install the HPE 3PAR CLI software to establish a secure connection. 
   OR
   Install the POSH SSH module to establish a secure connection. For more information on 
   installing the POSH SSH module, refer to the pre-requisites section.

3. ForHPE Alletra 9000 or HPE Primera or HPE 3PAR Web Service API Cmdlets, you must configure the WSAPI server first, 
   to establish a secure connection. Refer to the pre-requisites section for starting and configuring the WSAPI server.

4. Open an interactive PowerShell console.

5. Go to the location where “HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit” is saved in Step 1.
   PS C :> cd "C:\Home\PSToolkit\HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit” (Press Enter)
   PS C:\Home\PSToolkit\HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit>

6. Import all the Toolkit PowerShell modules into the supported Windows host. 
   Follow the steps:

	- HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit contains one PowerShell Data file (HPEStoragePowerShellToolkit.psd1):
   	
	NOTE: PSD1 file is used as the file extension for PowerShell Modules Manifests files and it 
	stores all module manifests. While importing the HPEStoragePowerShellToolkit.psd1, it imports all PowerShell modules into the Host.

	- To import the PowerShell Data file, execute the command:
	  Ex: PS C:\Home\PSToolkit\HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit> Import-Module .\HPEStoragePowerShellToolkit.psd1 (Press Enter)
	
7. The log file locations are:
   The log file location will be the base location where HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit is saved. 
   For example, if my HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit location is “C:\Home\PSToolkit\HPEAlletra9000AndPrimeraAnd3PARPowerShellToolkit” 
   then my log life location is “C:\Home\PSToolkit\Log”.


===============================================================================================
	POWERSHELL CMDLETS HELP
===============================================================================================

To get the list of cmdlets offered by HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit, 
run the below cmdlet:
	PS C:\> Get-CmdList
	PS C:\> Get-CmdList -CLI
	PS C:\> Get-CmdList -WSAPI

To get cmdlet specific help, run the cmdlet:
	PS C:\> Get-Help <cmdlet name>	

To get cmdlet specific help using the -example option, run the cmdlet:
	PS C:\> Get-Help <cmdlet name> -examples
	
To get cmdlet specific detailed help using the -detailed option, run the cmdlet:
	PS C:\> Get-Help <cmdlet name> -detailed

To get cmdlet specific help using the –full option, run the cmdlet:
	PS C:\> Get-Help <cmdlet name> -full


Connection Management cmdlets
-----------------------------------------------------------------------------------------------
New-PoshSshConnection                  :- Builds a SAN connection object using a Posh SSH connection.
New-CLIConnection                      :- Builds a SAN connection object using HPE 3PAR CLI
New-WSAPIConnection                    :- Builds a SAN connection object using HPE Alletra 9000 or HPE Primera or HPE 3PAR WSAPI			
Set-PoshSshConnectionPasswordFile      :- Creates an encrypted password file on client machine
Set-PoshSshConnectionUsingPasswordFile :- Creates a SAN Connection object using Encrypted password file

NOTE:  Toolkit command name and parameter name is case insensitive whereas parameter values are case sensitive.


Session Management (Using Session Variable)
-----------------------------------------------------------------------------------------------

To run cmdlets using sessions, follow the below steps:

1. Create the connection object to the array, save the connection object into a variable

2. Create as many sessions as required on the same or different arrays. Each time save the 
   connection object into a variable.
   Note: You can create multiple sessions to one array with different credentials. 
   Creating multiple sessions to the same array using the same credentials is not allowed.
   
3. Run the cmdlets using required connection object
   Example:-
   $Connection1 = New-PoshSshConnection -ArrayNameOrIPAddress 1.2.3.4 -SANUserName ABC	(Creates session to 1.2.3.4)
   $Connection2 = New-PoshSshConnection -ArrayNameOrIPAddress 1.1.1.1 -SANUserName XYZ	(Creates session to 1.1.1.1)

   Get-Version -SANConnection $Connection1 (cmdlet runs on array 1.1.1.1)
   Get-Version -SANConnection $Connection2 (cmdlet runs on array 1.2.2.1)   

   Same thing you can do for WSAPI cmdlets as below:
   $Connection3 = New-WSAPIConnection -ArrayFQDNorIPAddress 1.2.3.4 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType 3par    (Creates session to 1.1.1.1)
   $Connection4 = New-WSAPIConnection -ArrayFQDNorIPAddress 1.1.1.1 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType primera (Creates session to 1.2.2.1)
   $Connection5 = New-WSAPIConnection -ArrayFQDNorIPAddress 1.1.1.1 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType alletra9000 (Creates session to 1.3.3.1)

   Get-Version_WSAPI -SANConnection $Connection3 (cmdlet runs on array 1.1.1.1)
   Get-Version_WSAPI -SANConnection $Connection4 (cmdlet runs on array 1.2.2.1)
   Get-Version_WSAPI -SANConnection $Connection4 (cmdlet runs on array 1.3.4.1)
	
   Note: we cannot use the CLI Session Variable with WSAPI.
