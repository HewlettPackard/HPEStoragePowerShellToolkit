####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Get-A9Domain
{
<#
.SYNOPSIS
	Show information about domains in the system.
.DESCRIPTION
	Displays a list of domains in a system.
.PARAMETER Detailed
	Specifies that detailed information is displayed.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[ switch]	$ShowRaw
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " showdomain "
	if($Detailed)	{	$Cmd += " -d " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
}
End
{	if ($ShowRaw) {return $Result }
	if($Result.count -gt 1) 
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -2  
			$s = ( ( ($s.split(' ')).trim()).trim('-') | where-object { $_ -ne '' } ) -join ','
			$s = $s -replace 'CreationTime','Date,Time,Zone'
			Add-Content -Path $tempfile -Value $s				
			foreach ($s in  $Result[0..$LastItem] )
				{	$s = ( ( ($s.split(' ')).trim()).trim('-') | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempfile -Value $s				
				}
			$Result = Import-Csv $tempFile 
			Remove-Item  $tempFile 	
		}
	if($Result.count -gt 1)	{	Write-Host " Success : Executing Get-Domain" -ForegroundColor green }
	return  $Result
}
}

Function Get-A9DomainSet
{
<#
.SYNOPSIS
	show domain set information
.DESCRIPTION
	Lists the domain sets defined on the system and their members.
.PARAMETER Detailed
	Show a more detailed listing of each set.
.PARAMETER DomainShow 
	domain sets that contain the supplied domains or patterns
.PARAMETER SetOrDomainName
	specify either Domain Set name or domain name (member of Domain set)
.EXAMPLE
	PS:> Get-A9DomainSet -Detailed
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[switch]	$Domain, 
		[Parameter()]	[String]	$SetOrDomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " showdomainset "
	if($Detailed)			{	$Cmd += " -d " }
	if($Domain)				{	$Cmd += " -domain " } 
	if($SetOrDomainName)	{	$Cmd += " $SetOrDomainName " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if($Result.count -gt 1)	{	Write-Host " Success : Executing Get-Domain" -ForegroundColor green }
	return $Result 
}
}

Function Move-A9Domain
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
.PARAMETER Hosts
	Specifies that the object is a host.
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]				[switch]	$vv,
		[Parameter()]				[switch]	$Cpg,
		[Parameter()]				[switch]	$Hosts,
		[Parameter(Mandatory)]		[String]	$ObjName,
		[Parameter(Mandatory)]		[String]	$DomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " movetodomain "
	if($Vv) 	{	$Cmd += " -vv " }
	if($Cpg)	{	$Cmd += " -cpg " }
	if($Hosts)	{	$Cmd += " -host " }
	$Cmd += " -f "
	if($ObjName){	$Cmd += " $ObjName " }
	if($DomainName){$Cmd += " $DomainName " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
}	
End
{	if($Result -match "Id")
		{	$tempFile = [IO.Path]::GetTempFileName()
			foreach ($s in  $Result[0..($Result.Count -1)])
				{	$s= ( ( ($s.split(' ')).trim()).trim('-') | where-object { $_ -ne '' } ) -join ','
					Add-Content -Path $tempfile -Value $s				
				}
			$Result = Import-Csv $tempFile 
			Remove-Item  $tempFile 	
		}
	if($Result -match "Id")	{	Write-Host " Success : Executing Move-Domain" -ForegroundColor green }
	return  $Result
}
}

Function New-A9Domain
{
<#
.SYNOPSIS
	Create a domain.
.DESCRIPTION
	The New-Domain command creates system domains.
.PARAMETER Domain_name
	Specifies the name of the domain you are creating. The domain name can be no more than 31 characters. The name "all" is reserved.
.PARAMETER Comment
	Specify any comments or additional information for the domain. The comment can be up to 511 characters long. Unprintable characters are not allowed. 
	The comment must be placed inside quotation marks if it contains spaces.
.PARAMETER Vvretentiontimemax
	Specify the maximum value that can be set for the retention time of a volume in this domain. <time> is a positive integer value and in the range of 0 - 43,800 hours (1825 days).
	Time can be specified in days or hours providing either the 'd' or 'D' for day and 'h' or 'H' for hours following the entered time value.
	To disable setting the volume retention time in the domain, enter 0 for <time>.
.EXAMPLE
	PS:> New-A9Domain -Domain_name xxx
.EXAMPLE
	PS:> New-A9Domain -Domain_name xxx -Comment "Hello"
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$Comment,
		[Parameter()]	[String]	$Vvretentiontimemax,
		[Parameter(mandatory)]	[String]	$Domain_name
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
} 
Process
{	$Cmd = " createdomain "
	if($Comment)			{	$Cmd += " -comment " + '" ' + $Comment +' "'	 }
	if($Vvretentiontimemax) {	$Cmd += " -vvretentiontimemax $Vvretentiontimemax " } 
	$Cmd += " $Domain_name "
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
	if ([string]::IsNullOrEmpty($Result))	{  Write-Host "Domain : $Domain_name Created Successfully."	-ForegroundColor green }
	Return $Result
}
}

Function New-A9DomainSet
{
<#
.SYNOPSIS
	Create a domain set or add domains to an existing set
.DESCRIPTION
	The command defines a new set of domains and provides the option of assigning one or more existing domains to that set. 
	The command also allows the addition of domains to an existing set by use of the -add option.
.PARAMETER SetName
	Specifies the name of the domain set to create or add to, using up to 27 characters in length.
.PARAMETER Add
	Specifies that the domains listed should be added to an existing set. At least one domain must be specified.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
.EXAMPLE
	New-A9DomainSet -SetName xyz 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory)]	[String]	$SetName,
		[Parameter()]			[switch]	$Add,
		[Parameter()]			[String]	$Comment
)
Begin
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$Cmd = " createdomainset " 
	if($Add) 		{	$Cmd += " -add " }
	if($Comment)	{	$Cmd += " -comment " + '" ' + $Comment +' "' }
	if($SetName)	{	$Cmd += " $SetName " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Remove-A9Domain
{
<#
.SYNOPSIS
	Remove a domain
.DESCRIPTION
	The command removes an existing domain from the system.
.PARAMETER DomainName
	Specifies the domain that is removed. If the -pat option is specified the DomainName will be treated as a glob-style pattern, and multiple domains will be considered.
.PARAMETER Pattern
	Specifies that names will be treated as glob-style patterns and that all domains matching the specified pattern are removed.
.EXAMPLE
	Remove-A9Domain -DomainName xyz
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]				[switch]	$Pattern,
		[Parameter(Mandatory)]		[String]	$DomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " removedomain -f "
	if($Pattern)	{	$Cmd += " -pat " }
	if($DomainName)	{	$Cmd += " $DomainName " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Remove-A9DomainSet
{
<#
.SYNOPSIS
	Remove a domain set or remove domains from an existing set
.DESCRIPTION
	The command removes a domain set or removes domains from an existing set.
.PARAMETER SetName
	Specifies the name of the domain set. If the -pat option is specified the setname will be treated as a glob-style pattern, and multiple domain sets will be considered.
.PARAMETER Domain
	Optional list of domain names that are members of the set. If no <Domain>s are specified, the domain set is removed, otherwise the specified <Domain>s are removed from the domain set. 
	If the -pat option is specified the domain will be treated as a glob-style pattern, and multiple domains will be considered.
.PARAMETER Pattern
	Specifies that both the set name and domains will be treated as glob-style patterns.
.EXAMPLE
	PS:> Remove-A9DomainSet -SetName xyz
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]			[switch]	$Pattern,
		[Parameter(Mandatory)]	[String]	$SetName,
		[Parameter()]			[String]	$Domain
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " removedomainset "
	$Cmd += " -f "
	if($Pattern){	$Cmd += " -pat " }
	if($SetName){	$Cmd += " $SetName " }
	if($Domain)	{	$Cmd += " $Domain " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
}

Function Set-A9Domain
{
<#
.SYNOPSIS
	Change current domain CLI environment parameter.
.DESCRIPTION
	The command changes the current domain CLI environment parameter.
.EXAMPLE
	PS:> Set-A9Domain
.PARAMETER Domain
	Name of the domain to be set as the working domain for the current CLI session. If the <domain> parameter is not present or is equal to -unset then the working domain is set to no current domain.
.EXAMPLE
	PS:> Set-A9Domain -Domain "XXX"
.NOTES
	This command requires a SSH type connection.
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
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	if([String]::IsNullOrEmpty($Domain))
		{	$Result = "Working domain is unset to current domain."
		}
	elseif([String]::IsNullOrEmpty($Result))
		{	$Result = "Domain : $Domain to be set as the working domain for the current CLI session."
		}
	return $Result
}
}

Function Update-A9Domain
{
<#
.SYNOPSIS
	Set parameters for a domain.
.DESCRIPTION
	The command sets the parameters and modifies the properties of a domain.
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
.EXAMPLE
	Update-A9Domain -DomainName xyz
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]			[String]	$NewName,
		[Parameter()]			[String]	$Comment,
		[Parameter()]			[String]	$Vvretentiontimemax,
		[Parameter(Mandatory)]	[String]	$DomainName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " setdomain "
	if($NewName)			{	$Cmd += " -name $NewName " }
	if($Comment)			{	$Cmd += " -comment " + '" ' + $Comment +' "'}
	if($Vvretentiontimemax)	{	$Cmd += " -vvretentiontimemax $Vvretentiontimemax "	}
	if($DomainName)			{	$Cmd += " $DomainName "}
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
}
}

Function Update-A9DomainSet
{
<#
.SYNOPSIS
	set parameters for a domain set
.DESCRIPTION
	The command sets the parameters and modifies the properties of a domain set.
.PARAMETER DomainSetName
	Specifies the name of the domain set to modify.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
.PARAMETER NewName
	Specifies a new name for the domain set, using up to 27 characters in length.
.EXAMPLE
	Update-A9DomainSet -DomainSetName xyz
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]			[String]	$Comment,
		[Parameter()]			[String]	$NewName,
		[Parameter(Mandatory)]	[String]	$DomainSetName
)
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process
{	$Cmd = " setdomainset "
	if($Comment)	{	$Cmd += " -comment " + '" ' + $Comment +' "' }
	if($NewName)	{  	$Cmd += " -name $NewName " }
	if($DomainSetName){	$Cmd += " $DomainSetName " }
	write-verbose "Executing the following SSH command `n`t $cmd"
	$Result = Invoke-A9CLICommand -cmds  $Cmd
	Return $Result
} 
} 
