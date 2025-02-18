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
	SSH Verbose reporting
	AutoLogging
	Codebase Refactoring
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



