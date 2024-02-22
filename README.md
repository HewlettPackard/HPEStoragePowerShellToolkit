# HPEStoragePowerShellToolkit
This is actually a set of PowerShell Toolkits combined into a single Download Package.
 * HPEStorage PowerShell Toolkit (version 3.1)
 * HPE Alletra6K Nimble Storage PowerShell Toolkit (version 3.4.1)
 * HPE MSA PowerShell Toolkit (version 0.9)
Since these toolkits contain no conflicting file names, they can both co-exist in the same folder structure. 

By default when you load this HPE Storage Toolkit, you wil only obtain a single Connection Command since the toolkits for each seperate toolkit can be confusing and use similar terms. The single command to run will be;
* <code> Connect-HPEStorage -IPorFQDN 1.2.3.4 -credential (get-credentialobject) -arraytype {Nimble/Alletra6K/3Par/Primera/Alletra9K/MSA}</code>
Once you use this command, the correct individual toolkit will be loaded. i.e. If your arraytype is 3PAR, the master command will load all of the commands that exclusivly work on 3PAR type devices.

Alternately You can load this individual toolkiits manually using any of the following commands
* <code>Import-Module .\HPEStoragePowerShellToolkit</code>
* <code>Import-Module .\HPEAlletra6000andNimbleStoragePSTK</code>
* <code>Import-Module .\HPEMSA</code>

Each of these toolkit is being upgraded to remove duplicate or depreciated commands, fix bugs, and streamline operations. These new versions are called out below;
For the changes to the HPEStorage Toolkit that supports 3Par/Primera/Alletra9K please refer to the changes files called Changes.A9.md
For the changes to the HPEAlletra6000andNimbleStorage Toolkit that supports Nimble/Alletra6K please refer to the changes files called Changes.A6.md
For the changes to the HPEMSA Toolkit that supports MSA Gen 6 please refer to the initial release file called Changes.MSA.md

TODO: 

1). Once these toolkits are updated, they will be combined into a single Toolkit Loader which will simply be called HPEStorage.
This single loader will also combine the connectivity commands such that a single Connect command will be able to connect to any of these devices
types and the proper commands will be accessable.

2). Once you have successfully connected to a specific device type such as NimbleStorage; the toolkit will use parameter sets so allow a single Command
to create volumes, or alter hosts initiator groups, etc. 

* Note that this toolkit is still under development. This readme file will be updated to reflect when this toolkit is ready to be used.
