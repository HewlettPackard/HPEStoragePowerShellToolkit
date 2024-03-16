####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Get-A9Domain_CLI
{
<#
.SYNOPSIS
	Show information about domains in the system.
.DESCRIPTION
	Displays a list of domains in a system.
.PARAMETER D
	Specifies that detailed information is displayed.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$D
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " showdomain "
	if($D)	{	$Cmd += " -d " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	if($Result.count -gt 1) 
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -2  
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim() 
					$temp1 = $s -replace 'CreationTime','Date,Time,Zone'
					$s = $temp1		
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item  $tempFile 	
		}
	else{	return  $Result }
	if($Result.count -gt 1)	{	return  " Success : Executing Get-Domain" }
	else	{	return  $Result } 
}
}

Function Get-A9DomainSet_CLI
{
<#
.SYNOPSIS
	show domain set information
.DESCRIPTION
	Lists the domain sets defined on the system and their members.
.EXAMPLE
	PS:> Get-A9DomainSet_CLI -D
.PARAMETER D
	Show a more detailed listing of each set.
.PARAMETER DomainShow 
	domain sets that contain the supplied domains or patterns
.PARAMETER SetOrDomainName
	specify either Domain Set name or domain name (member of Domain set)
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$D,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Domain, 
		[Parameter(ValueFromPipeline=$true)]	[String]	$SetOrDomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " showdomainset "
	if($D)		{	$Cmd += " -d " }
	if($Domain)	{	$Cmd += " -domain " } 
	if($SetOrDomainName)	{	$Cmd += " $SetOrDomainName " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	if($Result.count -gt 1)	{	return  $Result }
	else	{	return  $Result }
}
}

Function Move-A9Domain_CLI
{
<#
.SYNOPSIS
	Move objects from one domain to another, or into/out of domains
.DESCRIPTION
	Moves objects from one domain to another.
.PARAMETER ObjName
	Specifies the name of the object to be moved.
.PARAMETER DomainName
	Specifies the domain or domain set to which the specified object is moved. 
	The domain set name must start with "set:". To remove an object from any domain, specify the string "-unset" for the domain name or domain set specifier.
.PARAMETER Vv
	Specifies that the object is a virtual volume.
.PARAMETER Cpg
	Specifies that the object is a common provisioning group (CPG).
.PARAMETER Host
	Specifies that the object is a host.
.PARAMETER F
	Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[switch]	$vv,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Cpg,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$Host,
		[Parameter(ValueFromPipeline=$true)]	[switch]	$F,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$ObjName,
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]		[String]	$DomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " movetodomain "
	if($Vv) 	{	$Cmd += " -vv " }
	if($Cpg)	{	$Cmd += " -cpg " }
	if($Host)	{	$Cmd += " -host " }
	if($F)		{	$Cmd += " -f " }
	if($ObjName){	$Cmd += " $ObjName " }
	if($DomainName){$Cmd += " $DomainName " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	if($Result -match "Id")
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -1  
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim()
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			Remove-Item  $tempFile 	
		}
	if($Result -match "Id")	{	return  " Success : Executing Move-Domain"}
	else					{	return "FAILURE : While Executing Move-Domain `n $Result"	}
}
}

Function New-A9Domain_CLI
{
<#
.SYNOPSIS
	Create a domain.
.DESCRIPTION
	The New-Domain command creates system domains.
.EXAMPLE
	Domain_name xxx
.EXAMPLE
	PS:> New-A9Domain_CLI -Domain_name xxx -Comment "Hello"
.PARAMETER Domain_name
	Specifies the name of the domain you are creating. The domain name can be no more than 31 characters. The name "all" is reserved.
.PARAMETER Comment
	Specify any comments or additional information for the domain. The comment can be up to 511 characters long. Unprintable characters are not allowed. 
	The comment must be placed inside quotation marks if it contains spaces.
.PARAMETER Vvretentiontimemax
	Specify the maximum value that can be set for the retention time of a volume in this domain. <time> is a positive integer value and in the range of 0 - 43,800 hours (1825 days).
	Time can be specified in days or hours providing either the 'd' or 'D' for day and 'h' or 'H' for hours following the entered time value.
	To disable setting the volume retention time in the domain, enter 0 for <time>.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Vvretentiontimemax,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Domain_name
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
} 
Process
{	$Cmd = " createdomain "
	if($Comment)			{	$Cmd += " -comment " + '" ' + $Comment +' "'	 }
	if($Vvretentiontimemax) {	$Cmd += " -vvretentiontimemax $Vvretentiontimemax " } 
	if($Domain_name) 		{	$Cmd += " $Domain_name " }
	else {	return "Domain Required.." }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
	if ([string]::IsNullOrEmpty($Result))	{   Return $Result = "Domain : $Domain_name Created Successfully."	}
	else									{	Return $Result	}
}
}

Function New-A9DomainSet_CLI
{
<#
.SYNOPSIS
	Create a domain set or add domains to an existing set
.DESCRIPTION
	The command defines a new set of domains and provides the option of assigning one or more existing domains to that set. 
	The command also allows the addition of domains to an existing set by use of the -add option.
.EXAMPLE
	New-A9DomainSet_CLI -SetName xyz 
.PARAMETER SetName
	Specifies the name of the domain set to create or add to, using up to 27 characters in length.
.PARAMETER Add
	Specifies that the domains listed should be added to an existing set. At least one domain must be specified.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SetName,
		[Parameter(Mandatory=$false , ValueFromPipeline=$true)]	[switch]	$Add,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " createdomainset " 
	if($Add) 		{	$Cmd += " -add " }
	if($Comment)	{	$Cmd += " -comment " + '" ' + $Comment +' "' }
	if($SetName)	{	$Cmd += " $SetName " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Remove-A9Domain_CLI
{
<#
.SYNOPSIS
	Remove a domain
.DESCRIPTION
	The command removes an existing domain from the system.
.EXAMPLE
	Remove-A9Domain_CLI -DomainName xyz
.PARAMETER DomainName
	Specifies the domain that is removed. If the -pat option is specified the DomainName will be treated as a glob-style pattern, and multiple domains will be considered.
.PARAMETER Pat
	Specifies that names will be treated as glob-style patterns and that all domains matching the specified pattern are removed.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]					[switch]	$Pat,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$DomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " removedomain -f "
	if($Pat)		{	$Cmd += " -pat " }
	if($DomainName)	{	$Cmd += " $DomainName " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Remove-A9DomainSet_CLI
{
<#
.SYNOPSIS
	Remove a domain set or remove domains from an existing set
.DESCRIPTION
	The command removes a domain set or removes domains from an existing set.
.EXAMPLE
	PS:> Remove-A9DomainSet_CLI -SetName xyz
.PARAMETER SetName
	Specifies the name of the domain set. If the -pat option is specified the setname will be treated as a glob-style pattern, and multiple domain sets will be considered.
.PARAMETER Domain
	Optional list of domain names that are members of the set. If no <Domain>s are specified, the domain set is removed, otherwise the specified <Domain>s are removed from the domain set. 
	If the -pat option is specified the domain will be treated as a glob-style pattern, and multiple domains will be considered.
.PARAMETER F
	Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
.PARAMETER Pat
	Specifies that both the set name and domains will be treated as glob-style patterns.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]					[switch]	$F,
		[Parameter(ValueFromPipeline=$true)]					[switch]	$Pat,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$SetName,
		[Parameter(ValueFromPipeline=$true)]					[String]	$Domain
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " removedomainset "
	if($F) 		{	$Cmd += " -f "	}
	if($Pat)	{	$Cmd += " -pat " }
	if($SetName){	$Cmd += " $SetName " }
	if($Domain)	{	$Cmd += " $Domain " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Set-A9Domain_CLI
{
<#
.SYNOPSIS
	Change current domain CLI environment parameter.
.DESCRIPTION
	The command changes the current domain CLI environment parameter.
.EXAMPLE
	PS:> Set-A9Domain_CLI
.EXAMPLE
	PS:> Set-Domain -Domain "XXX"
.PARAMETER Domain
	Name of the domain to be set as the working domain for the current CLI session. If the <domain> parameter is not present or is equal to -unset then the working domain is set to no current domain.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Domain
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " changedomain "
	if($Domain)	{	$Cmd += " $Domain " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	if([String]::IsNullOrEmpty($Domain))
		{	$Result = "Working domain is unset to current domain."
			Return $Result
		}
	else{	if([String]::IsNullOrEmpty($Result))
				{	$Result = "Domain : $Domain to be set as the working domain for the current CLI session."
					Return $Result
				}
			else{	Return $Result}	
		}
}
}

Function Update-A9Domain_CLI
{
<#
.SYNOPSIS
	Set parameters for a domain.
.DESCRIPTION
	The command sets the parameters and modifies the properties of a domain.
.EXAMPLE
	Update-A9Domain_CLI -DomainName xyz
.PARAMETER DomainName
	Indicates the name of the domain.(Existing Domain Name)
.PARAMETER NewName
	Changes the name of the domain.
.PARAMETER Comment
	Specifies comments or additional information for the domain. The comment can be up to 511 characters long and must be enclosed in quotation
	marks. Unprintable characters are not allowed within the <comment> specifier.
.PARAMETER Vvretentiontimemax
	Specifies the maximum value that can be set for the retention time of a volume in this domain. <time> is a positive integer value and in the
	range of 0 - 43,800 hours (1825 days). Time can be specified in days or hours providing either the 'd' or 'D' for day and 'h' or 'H' for hours
	following the entered time value. To remove the maximum volume retention time for the domain, enter '-vvretentiontimemax ""'. As a result, the maximum 
	volume retention time for the system is used instead. To disable setting the volume retention time in the domain, enter 0 for <time>.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$NewName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Vvretentiontimemax,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$DomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " setdomain "
	if($NewName)	{	$Cmd += " -name $NewName " }
	if($Comment){	$Cmd += " -comment " + '" ' + $Comment +' "'}
	if($Vvretentiontimemax)	{	$Cmd += " -vvretentiontimemax $Vvretentiontimemax "	}
	if($DomainName)	{	$Cmd += " $DomainName "}
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Update-A9DomainSet_CLI
{
<#
.SYNOPSIS
	set parameters for a domain set
.DESCRIPTION
	The command sets the parameters and modifies the properties of a domain set.
.EXAMPLE
	Update-A9DomainSet_CLI -DomainSetName xyz
.PARAMETER DomainSetName
	Specifies the name of the domain set to modify.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
.PARAMETER NewName
	Specifies a new name for the domain set, using up to 27 characters in length.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]	[String]	$NewName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$DomainSetName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " setdomainset "
	if($Comment)	{	$Cmd += " -comment " + '" ' + $Comment +' "' }
	if($NewName)	{  	$Cmd += " -name $NewName " }
	if($DomainSetName){	$Cmd += " $DomainSetName " }
	$Result = Invoke-CLICommand -cmds  $Cmd
	Return $Result
} 
} 
