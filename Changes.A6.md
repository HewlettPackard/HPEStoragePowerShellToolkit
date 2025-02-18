HPE Storage PowerShell Toolkit - Alletra 6000 and Nimble Storage 4.0.0.0 README
==================================================
README
==================================================


Table of Contents
=================

* New Features in the HPE Storage PowerShell Toolkit 4.0.0.0
* Installing the HPE Storage PowerShell Toolkit
* Getting help with the HPE Storage PowerShell Toolkit
* Tips and Tricks 
* Resolved Issues
* Known Issues
1. The New PowerShell Toolkit is primarily testetd against PowerShel Version 7.2 and newer. Please use the following PowerShell command to download the latest version of PowerShell to your platform and run these commands from that newer PowerShell version. <code>iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"</code>


New Features in the HPE Toolkit 4.0.0.0
=================================================================================

The following features were added in the 4.0.0.0 version of the toolkit:

* You can download the toolkit from Microsoft PowerShell Gallery. The toolkit is available under the module name:

        "HPEStorage*", version 4.0.0.0

1. Added support for the HPE Alletra Storage MP B10000 Platform

No other changes were made to the Alletra 5000,6000, or Nimble Storage parts of the Toolkit

* Support for new Nimble OS 6.0+ and Alletra 6000 Storage OS 6.0.x+ . 



Installing the HPE Storage PowerShell Toolkit
======================================================================

To install the HPE Storage PowerShell Toolkit:

1. Right-click on the downloaded ZIP file. If the file has the blocked property set, you must choose Unblock to download the file.

2. Unzip the file into the following location:

        C:\Windows\System32\WindowsPowerShell\v1.0\Modules\

3. Verify that HPEStorage.psd1 exists in the following location:

        C:\Windows\System32\WindowsPowerShell\v1.0\Modules\HPEStorage\HPEStorage.psd1

Alternate Installation Method

1. From a powershell 7.x prompt type the following command;

<code>Find-Module HPEStorage* | install-module</code>

Forcing the installation of the SubModule for the Alletra6000 and Nimble Storage Powershell Toolkit
=================================================================
This may be needed if you wish to use the legacy Nimble Connection Command to allow you to import the array certificate. Once this 
certificate is installed, you should no longer need to use this override method of loading the legacy connection method and the default
Connect-HPESAN command will connect properly. 
To use the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit:

1. From a PowerShell prompt in the HPEStorage Module Directory, import the HPE Nimble Storage PowerShell module by running the following command:

        PS:&gt; Import-Module .\HPEAlletra6000andNimbleStoragePowerShellToolkit.psd1

2. Connect to an existing Group using one of the following commands:

        PS:&gt; Connect-NSGroup -group 192.168.1.50 -credential (get-credential) -ImportServerCertificate
		-or-	
        PS:&gt; Connect-NSGroup -group 192.168.1.50 -credential (get-credential) -IgnoreServerCertificate
	
        A pop-up box appears that prompts you for your password.
	
        If you choose to use the -ImportServerCertificate option, it only needs to done the first time you connect to the array. The import process requires
        that you have an Administrative PowerShell Window. 


Getting help with the HPE Storage Toolkit for Alletra 6000 and Nimble Storage specific commands
=============================================================================

You can get help information about either a single command or multiple commands:

* To get a complete list of PowerShell commands, run the following command:

	PS:&gt; Get-Command -module HPENimblePowerShellToolkit
        -or-
        PS:&gt; Get-Command *-NS*
	
* To get detailed help about a single command, run Get-Help with the name of the command, as shown in the following examples:

	PS:&gt; Get-Help new-NSVolume
	PS:&gt; Get-Help new-NSVolume -full
	PS:&gt; Get-Help new-NSVolume -examples

	
Tips and Tricks
=============== 

The HPE Alletra 6000 and Nimble Storage PowerShell Toolkit and the HPE Alletra 6000 and Nimble Storage API use a common ID number to uniquely 
identify an object, such as a volume or an initiator group. Many commands, such as Set-NSVolume, expect you to identify the object to be acted 
on. This number can be hard to transcribe manually. 

Instead, you might find it useful to embed a "get-ns" type command in your "set-ns" type command. For example, if you wanted to modify a volume named 
"MyTestVolume", you could use the following set of commands:

	$MyID = $(get-nsvolume -name "MyTestVolume").id
	set-nsvolume -id $MyID -description "This is My Test Volume"

Alternately, if you wanted to issue this same command from a single line, you could use the following:

	set-nsvolume -id $(get-nsvolume -name "MyTestVolume").id -description "My Test Volume"


Resolved Issues in HPE Alletra 6000 and Nimble Storage PowerShell Toolkit 4.0.0
================================================================================
None

Known Issues in HPE Storage Toolkit - Alletra 6000 and Nimble Storage 4.0.0
=============================================================================

PST-70: Powershell toolkit issues when working with Linux or on a Mac
	Description: Neither the IgnoreCertificate nor the ImportCertificate options work in Linux or on a Mac. 
	Workaround: To connect using these platforms, you must download the certificate and install it separately.
	
PST-111: PowerShell Core performance issue occurs when the return objects are huge
	Description: In the case of very large return objects, such as Get-NSEvents where the number of returned objects are in the thousands, 
        the PowerShell Core can take significantly longer to complete a task than regular PowerShell. When retrieving 26,000 objects, the regular 
        PowerShell completed the task in 5 minutes. The PowerShell Core completed the same task in 55 minutes.