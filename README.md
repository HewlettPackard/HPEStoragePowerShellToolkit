# HPEStoragePowerShellToolkit
This is actually a Set of Toolkits combined into a single Download Package.
The HPEStorage PowerShell Toolkit (version 4.0.0.0) and the HPE Alletra6K Nimble Storage PowerShell Toolkit (version 3.5.0.0)
Since these toolkits contain no conflicting file names, they can both co-exist in the same folder structure. 

When you load the HPEStorage Toolkit, it will contain a command called 'Connect-HPEStorage'. You can run this command as follows
<code>PS:> Connect-HPEStorage -ArrayNameOrIPAddress 1.2.3.4 -credential (Get-Credential) -ArrayType {3Par | AlletraMP-B10000 |Primera | Alletra9000 | Nimble | Alletra6000 | MSA}</code>
    
This command will connect to the array type and then load the commands specific to that type of array. 
- If the Array type is 3Par/Primera/Alletra9000/AlletraMP-B10000 the command will load additional commands from the HPEAlletra9000andPrimeraand3Par_* modules.
- If the Array type is 3par Specific it will also load the additional File Persona Commands from the HPE3ParFilePersona modules.
- If the Array type is Nimble/Alletra6000 the command will load the additional commands from the HPEALLETRA6000AndNimbleStorage module.
- If the Array type is MSA the command will load the additional commands from the HPEMSA module.

Additionally, to get the command list for each array type run the following commands

Once connected to a AlletraMP-B10000/Alletra9000/Primera/3Par type array, run the following command;

<code>PS:> Get-Command -Module (Get-Module HPEAlletra9000andPrimeraand3Par_*) </code>

Once connected to a Alletra6000/Nimble type array, run the following command;

<code>PS:> Get-Command -Module (Get-Module HPEAlletra6000andNimbleStorage) </code>

Once connected to a Alletra6000/Nimble type array, run the following command;

<code>PS:> Get-Command -Module (Get-Module HPEMSA) </code>

Each of these toolkit is being upgraded to remove duplicate or depreciated commands, fix bugs, and streamline operations. These new versions are called out below;
HPEStorage version 3.5. These changes to the existing toolkits are outlined in the called Changes with the prefix depending on the class of array;
- For the Changes to the Alletra9000/Primera/3PAR class of array is the file called 'Changes_A9.md'
- For the Changes to the Alletra6000/Nimble class of array is the file called 'Changes_A6.md'
- For the Changes to the MSA class of array is the file called 'Changes_MSA.md'

These commands were tested against PowerShell version 7.x. If you run into problems, please consider downloading 
PowerShell 7.x and run the commands in that version. To obtain PowerShell 7.x please use the following PowerShell Command.

<code>PS:> iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI" </code>

Future:
1. The next version of the Toolkit will include a suite of Pester Tests to enhance toolkit testing
