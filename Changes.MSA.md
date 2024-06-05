README
==================================================


Table of Contents
=================

* New Features in the HPE MSA Storage PowerShell Toolkit 0.9.0
* Installing the HPE MSA Storage PowerShell Toolkit
* Getting help with the HPE MSA Storage PowerShell Toolkit
* Tips and Tricks 
* Resolved Issues
* Known Issues


New Features in the HPE MSA Storage PowerShell Toolkit 0.9.0
===============================================================


Installing the HPE MSA Storage PowerShell Toolkit
====================================================

To install the HPE MSA Storage PowerShell Toolkit:

1. Right-click on the downloaded ZIP file. If the file has the blocked
   property set, you must choose Unblock to download the file.

2. Unzip the file into the following location:

   C:\Windows\System32\WindowsPowerShell\v1\Modules\
	
3. Verify that HPENimblePowerShellToolkit.psd1 exists in the following location:

   C:\Windows\System32\WindowsPowerShell\v1\Modules\HPEMSA\HPEMSA.psd1
	


Using the HPE MSA Storage PowerShell Toolkit
===============================================

To use the HPE MSA Storage PowerShell Toolkit:

1. From a PowerShell prompt, import the HPE Nimble Storage PowerShell module
   by running the following command:

   PS:> Import-Module HPEMSA

2. Connect to an existing Nimble Group using one of the following commands:

   PS:> Connect-MSA -group 192.168.1.50 -credential Username -ImportServerCertificate
		-or-	
   PS:> Connect-MSA -group 192.168.1.50 -credential Username -IgnoreServerCertificate
	
   A pop-up box appears that prompts you for your password.
	
   If you choose to use the -ImportServerCertificate option, it only needs 
   to done the first time you connect to the array. The import process requires
   that you have an Administrative PowerShell Window. 


Getting help with the HPE MSA Storage PowerShell Toolkit
===========================================================

You can get help information about either a single command or multiple commands:

* To get a complete list of PowerShell commands, run the following command:

	PS:> get-command -module HPEMSA
	
* To get detailed help about a single command, run Get-Help with the name of the 
  command, as shown in the following examples:

	PS:> get-help new-MSAVolume
	PS:> get-help new-MSAVolume -full
	PS:> get-help new-MSAVolume -examples

	
Tips and Tricks
=============== 


Resolved Issues in HPE MSA Storage PowerShell Toolkit 0.9.0
==============================================================
This is the Initial Implementation

Known Issues in HPE MSA Storage PowerShell Toolkit 0.9.0
===========================================================
This toolkit has only implemented the Read Operations for this array. Future versions of this
toolkit will implement the write operations (New/Set/Remove). 