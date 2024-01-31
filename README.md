# HPEStoragePowerShellToolkit
This is actually a pair of PowerShell Toolkits combined into a single Download Package.
The HPEStorage PowerShell Toolkit (version 3.1) and the HPE Alletra6K Nimble Storage PowerShell Toolkit (version 3.4.1)
Since these toolkits contain no conflicting file names, they can both co-exist in the same folder structure. 

To load the Toolkit that supports the Alletra 9000, Primera and 3PAR type devices, import the module called HPESTORAGE.
To load the Toolkit that supports the Alletra 6000, and Nimble Storage devices, import the module called HPEALLETRA6000AndNimbleStoragePowerShellToolkit

Each of these toolkit is being upgraded to remove duplicate or depreciated commands, fix bugs, and streamline operations. These new versions are called out below;
HPEStorage version 3.4
HPEAlletra6000AndNimbleStoragePowerShellTooliit Version 3.5 --> In Progress

TODO: 
1). Once these toolkits are updated, they will be combined into a single Toolkit Loader which will simply be called HPEStorage.
This single loader will also combine the connectivity commands such that a single Connect command will be able to connect to any of these devices
types and the proper commands will be accessable.

2). Once you have successfully connected to a specific device type such as NimbleStorage; the toolkit will use parameter sets so allow a single Command
to create volumes, or alter hosts initiator groups, etc. 

Note that this toolkit is still under development. This readme file will be updated to reflect when this toolkit is ready to be used.
