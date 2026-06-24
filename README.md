# HPEStoragePowerShellToolkit
This is actually a Set of Toolkits combined into a single Download Package.
The HPEStorage PowerShell Toolkit (version 4.0.0.0) and the HPE Alletra6K Nimble Storage PowerShell Toolkit (version 3.5.0.0). 

To connect to these arrays your PowerShell enviornment must trust the Certificate of the Array you are connecting to for Secure Sockets Layer (SSL) 
communication. In an effort to simplify this process, we have supplied a command which will allow you to read the Certificate of the remote 
storage array and insert that certificate into the local machine. The command is as follows;
<code> PS:> Import-HPESANCertificate -ArrayNameOrIPAddress 1.2.3.4</code>
If this command is run using a PowerShell Administrator prompt, the command will install the certificate to the Local Machine Certificate Store.
If this command is run using a PowerShell non-administrator prompt, the command will install the certificate to the Current User Store. 
This certificate installation process only ever be run once per machine as the certificate will remain installed for any later PowerShell session.

The HPEStorage Toolkit will also contain a command called 'Connect-HPESAN'. You can run this command as follows
<code> PS:> Connect-HPESAN -ArrayNameOrIPAddress 1.2.3.4 -credential (Get-Credential) -ArrayType {3Par | AlletraMP-B10000 |Primera | Alletra9000 | Nimble | Alletra6000 | MSA}</code>
    
This command will connect to the array type and then load the commands specific to that type of array. 
- If the Array type is 3Par the command will load commands that use the A9 Prefix and will include HPE3ParFilePersona commands.
- If the Array type is Primera / Alletra 9000 / Alletra MP B10K Specific it will load commands that all use the A9 Prefix.
- If the Array type is Nimble / Alletra 6000 / Alletra 5000 the command will load Commands that use the A6 Prefix.
- If the Array type is MSA the command will load commands that use the MSA Prefix.
The Prefix is used in the following scheme;
- 'Verb'-'Prefix''Noun'
The Verbs are Get, Set, Remove, and New, along with other powershell approved verbs
The Prefix will be either A6, A9, or MSA depending on the hardware platform
The Noun will be the object to manipulate such as Volume, Port, HostSet, etc.
- Examples of such commands are 'Remove-A9Volume', 'Set-A6Host', 'Get-MSAVolume'

Once connected to a AlletraMP-B10000/Alletra9000/Primera/3Par type array, run the following command;
<code>PS:> Get-Command -Module HPEStorage </code>
If you want to see the available commands which can be used with each hardware platform, you can use the command will will expose those commands without connecting to an array first.
<code>PS:> Show-HPESANArrayCommandSet -ArrayType Alletra6000</code>

Each of these toolkit is being upgraded to remove duplicate or depreciated commands, fix bugs, and streamline operations. These new versions are called out below;
HPEStorage version 4.0. These changes to the existing toolkits are outlined in the called Changes with the prefix depending on the class of array;
- For the Changes to the Alletra9000/Primera/3PAR class of array is the file called 'Changes_A9.md'
- For the Changes to the Alletra6000/Nimble class of array is the file called 'Changes_A6.md'
- For the Changes to the MSA class of array is the file called 'Changes_MSA.md'

These commands were tested against PowerShell version 7.x. If you run into problems, please consider downloading 
PowerShell 7.x and run the commands in that version. To obtain PowerShell 7.x please use the following PowerShell Command.

<code>PS:> iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI" </code>
