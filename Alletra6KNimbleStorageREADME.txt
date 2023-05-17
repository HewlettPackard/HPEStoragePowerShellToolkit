HPE Alletra 6000 and Nimble Storage PowerShell Toolkit 3.5.0 README
====================================================================


Table of Contents
=================

* New Features in the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit 3.5.0
* Installing the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit
* Getting help with the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit
* Tips and Tricks 
* Resolved Issues
* Known Issues


New Features in the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit 3.4.1
=================================================================================

The following features were added in the 3.4.1 version of the toolkit:

* You can download the toolkit from Microsoft PowerShell Gallery. The 
  toolkit is available under the module name:
   
      "HPEAlletra6000andNimbleStoragePowerShellToolkit", version 3.5.0 

* Replace the external help file with embedded command help that more 
  accuretly describes the commands

* Increased levels of type checking and parameter sets to enforce the 
  commands only sending valid operations to the restAPI endpoint.


Installing the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit
======================================================================

To install the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit:

1. Right-click on the downloaded ZIP file. If the file has the blocked
   property set, you must choose 'Unblock' to download the file.

2. Unzip the file into the following location:

   C:\Windows\System32\WindowsPowerShell\v1.0\Modules\
	
3. Verify that HPEAlletra6000andNimbleStoragePowerShellToolkit.psd1 exists in the following location:

   C:\Windows\System32\WindowsPowerShell\v1.0\Modules\HPEAlletra6000andNimbleStoragePowerShellToolkit\HPEAlletra6000andNimbleStoragePowerShellToolkit.psd1

4. Addded support for PowerShell Verson 7 on Windows as well as Linux and Mac platforms.	


Using the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit
=================================================================

To use the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit:

1. From a PowerShell prompt, import the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit module
   by running the following command:

   PS:> Import-Module HPEAlletra6000andNimbleStoragePowerShellToolkit

2. Connect to an existing Group using one of the following commands:

   PS:> Connect-NSGroup -group 192.168.1.50 -credential Username -ImportServerCertificate
		-or-	
   PS:> Connect-NSGroup -group 192.168.1.50 -credential Username -IgnoreServerCertificate
	
   A pop-up box appears that prompts you for your password.
	
   If you choose to use the '-ImportServerCertificate' option, it only needs 
   to done the first time you connect to the array. The import process requires
   that you have an Administrative PowerShell Window. 


Getting help with the HPE Alletra 6000 and Nimble Storage PowerShell Toolkit
=============================================================================

You can get help information about either a single command or multiple commands:

* To get a complete list of PowerShell commands, run the following command:

	PS:> get-command -module HPEAlletra6000andNimbleStoragePowerShellToolkit
	
* To get detailed help about a single command, run Get-Help with the name of the command, as shown in the following examples:

	PS:> get-help new-NSVolume
	PS:> get-help new-NSVolume -full
	PS:> get-help new-NSVolume -examples

	
Tips and Tricks
=============== 

The HPE Alletra 6000 and Nimble Storage PowerShell Toolkit and the HPE Alletra 6000 and Nimble Storage API use a 
common ID number to uniquely identify an object, such as a volume or an initiator group. Many commands, such as 
Set-NSVolume, expect you to identify the object to be acted on. This number can be hard to transcribe manually. 

Instead, you might find it useful to embed a "get-ns" type command in your "set-ns" type command. For example, if 
you wanted to modify a volume named "MyTestVolume", you could use the following set of commands:

	$MyID = $(get-nsvolume -name "MyTestVolume").id
	set-nsvolume -id $MyID -description "This is My Test Volume"

Alternately, if you wanted to issue this same command from a single line, you could use the following:
                                                                               
	set-nsvolume -id $(get-nsvolume -name "MyTestVolume").id -description "My Test Volume"


Resolved Issues in HPE Alletra 6000 and Nimble Storage PowerShell Toolkit 3.5.0
================================================================================
PST-80: New-NS* commands appear to accept ID as a valid parameter
	Description: The help for the command shows ID as a valid parameter. But, because you are creating a new object, 
        the API assigns a new ID to the object. As a result, the ID cannot be passed in as a parameter.

PST-79: Remove-NSSnapshot only accepts the ID parameter
	Description: The help for the command shows several parameters, such as name, but the command only accepts ID as 
        the valid parameter. The documentation should state that the ID is the only valid parameter to use to remove a snapshot.

PST-101: Three Commands missing Synopsis
	Description: The Synopsis is missing in the help for the following three commands: Move-NSGroup, Show-NSShelf, 
        and Stop-NSGroupSoftwareDownload

PST-102: Command help syntax incorrectly shows that each parameter is a parameter set
	Description: The multiple options are shown on different lines, which incorrectly indicates that they are parameter sets. 
        They are actually all part of the same parameter set.

PST-48: Cmdlet help shows invalid parameters 
	Description: New-NS<Object> and Set-NS<Object> cmdlets do not accept all of the object attributes as valid operation parameters. 
        In a few instances, the cmdlet help shows these attributes as valid parameters. For example, start_online is not accepted by the 
        Set-NSSnapshotCollection cmdlet as a valid attribute, but the cmdlet help lists it as valid.

PST-78: Failed to create a Protection template
	Description: The failure message stating that the Protection template failed to be created is reported incorrectly. This message 
        appears when the Protection template was actually created. The last part of the error message states: "The request was accepted 
        and is being processed in the background."

PST-77: Get-NSVolume doesn't report back usage
	Description: In the Get-NSVolume cmdlet, there is no option to get usage.
	Note: There is a field for total_usage_bytes, but that is not the same as usage.
        Answer : This is a lack in the API. The RestApi is exposed by the toolkit, but the toolkit does not change the existing API.

PST-57/58: Get-NSSoftwareVersion returns valid information, but also throws an exception
	Description: Get-NSSoftwareVersion fails with following exception: URL pattern in the request does not support HTTP method GET. The 
        error can be ignored and the objects returned by the execution can be processed as usual, either by storing the object in a variable 
        or sending it to the pipeline.For example you could have: "$versions = Get-NSSoftwareVersion" or "Get-NSSoftwareVersion | select version,status" 

PST-69: sched_owner_id/sched_owner_name options to Get-NSProtectionSchedule commandlet not working

Known Issues in HPE Alletra 6000 and Nimble Storage PowerShell Toolkit 3.5.0
=============================================================================
PST-130: Failed to connect to array using PSTK due to SSL/TLS error

PST-70: Powershell toolkit issues when working with Linux or on a Mac
	Description: Neither the IgnoreCertificate nor the ImportCertificate options work in Linux or on a Mac. 
	Workaround: To connect using these platforms, you must download the certificate and install it separately.
	
PST-111: PowerShell Core performance issue occurs when the return objects are huge
	Description: In the case of very large return objects, such as Get-NSEvents where the number of returned objects are in the thousands, 
        the PowerShell Core can take significantly longer to complete a task than regular PowerShell. When retrieving 26,000 objects, the regular 
        PowerShell completed the task in 5 minutes. The PowerShell Core completed the same task in 55 minutes.