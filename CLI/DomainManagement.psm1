####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
## 	Permission is hereby granted, free of charge, to any person obtaining a
## 	copy of this software and associated documentation files (the "Software"),
## 	to deal in the Software without restriction, including without limitation
## 	the rights to use, copy, modify, merge, publish, distribute, sublicense,
## 	and/or sell copies of the Software, and to permit persons to whom the
## 	Software is furnished to do so, subject to the following conditions:
##
## 	The above copyright notice and this permission notice shall be included
## 	in all copies or substantial portions of the Software.
##
## 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## 	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## 	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## 	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## 	OTHER DEALINGS IN THE SOFTWARE.
##
##	File Name:		DomainManagement.psm1
##	Description: 	Domain Management cmdlets 
##		
##	Created:		November 2019
##	Last Modified:	November 2019
##	History:		v3.0 - Created	
#####################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

############################################################################################################################################
## FUNCTION Test-CLIObject
############################################################################################################################################
Function Test-CLIObject 
{
Param( 	
    [string]$ObjectType, 
	[string]$ObjectName ,
	[string]$ObjectMsg = $ObjectType, 
	$SANConnection = $global:SANConnection
	)

	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")
	{
		$IsObjectExisted = $false
	}
	return $IsObjectExisted
	
} # End FUNCTION Test-CLIObject

##########################################################################
######################### FUNCTION Get-Domain #########################
##########################################################################
Function Get-Domain()
{
<#
  .SYNOPSIS
   Get-Domain - Show information about domains in the system.

  .DESCRIPTION
   The Get-Domain command displays a list of domains in a system.

  .EXAMPLE

  .PARAMETER D
   Specifies that detailed information is displayed.

  .Notes
    NAME: Get-Domain
    LASTEDIT 19-11-2019 
    KEYWORDS: Get-Domain
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$D,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Get-Domain - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Get-Domain since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Get-Domain since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " showdomain "

 if($D)
 {
	$Cmd += " -d "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Get-Domain Command -->" INFO: 
  
 if($Result.count -gt 1)
 {
	$Cnt = $Result.count
		
 	$tempFile = [IO.Path]::GetTempFileName()
	$LastItem = $Result.Count -2  
	
	foreach ($s in  $Result[0..$LastItem] )
	{		
		$s= [regex]::Replace($s,"^ ","")			
		$s= [regex]::Replace($s," +",",")	
		$s= [regex]::Replace($s,"-","")
		$s= $s.Trim() 
		$temp1 = $s -replace 'CreationTime','Date,Time,Zone'
		$s = $temp1		
		Add-Content -Path $tempfile -Value $s				
	}
	Import-Csv $tempFile 
	del $tempFile 	
 }
 else
 {
	return  $Result
 }
 
 if($Result.count -gt 1)
 {
	return  " Success : Executing Get-Domain"
 }
 else
 {			
	return  $Result
 } 
 
} ##  End-of Get-Domain

##########################################################################
######################### FUNCTION Get-DomainSet #########################
##########################################################################
Function Get-DomainSet()
{
<#
  .SYNOPSIS
   Get-DomainSet - show domain set information

  .DESCRIPTION
   The Get-DomainSet command lists the domain sets defined on the system and
   their members.

  .EXAMPLE
   Get-DomainSet -D

  .PARAMETER D
   Show a more detailed listing of each set.

  .PARAMETER Domain
   Show domain sets that contain the supplied domains or patterns

  .PARAMETER SetOrDomainName
	specify either Domain Set name or domain name (member of Domain set)
   
  .Notes
    NAME: Get-DomainSet
    LASTEDIT 19-11-2019
    KEYWORDS: Get-DomainSet
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$D,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Domain, 

	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$SetOrDomainName,

	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Get-DomainSet - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Get-DomainSet since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Get-DomainSet since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " showdomainset "

 if($D)
 {
  $Cmd += " -d "
 }

 if($Domain)
 {
  $Cmd += " -domain "
 } 

 if($SetOrDomainName)
 {
  $Cmd += " $SetOrDomainName "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Get-DomainSet Command -->" INFO:
 
 <#
 if($Result.count -gt 1)
 {
	$Cnt = $Result.count
		
 	$tempFile = [IO.Path]::GetTempFileName()
	$LastItem = $Result.Count -2  
	
	foreach ($s in  $Result[0..$LastItem] )
	{
		$s= [regex]::Replace($s,"^ ","")		
		$s= [regex]::Replace($s,"^ ","")				
		$s= [regex]::Replace($s," +",",")				
		$s= [regex]::Replace($s,"-","")	
		$s= $s.Trim()			
		Add-Content -Path $tempfile -Value $s				
	}
	Import-Csv $tempFile 
	del $tempFile 	
 }
 #>
 if($Result.count -gt 1)
 {
	#return  " Success : Executing Get-DomainSet"
	return  $Result
 }
 else
 {			
	return  $Result
 }
 
} ##  End-of Get-DomainSet

##########################################################################
######################### FUNCTION Move-Domain #########################
##########################################################################
Function Move-Domain()
{
<#
  .SYNOPSIS
   Move-Domain - Move objects from one domain to another, or into/out of domains

  .DESCRIPTION
   The Move-Domain command moves objects from one domain to another.

  .EXAMPLE
  
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
   Specifies that the command is forced. If this option is not used, the
   command requires confirmation before proceeding with its operation.

  .Notes
    NAME: Move-Domain
    LASTEDIT 19-11-2019
    KEYWORDS: Move-Domain
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
 [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
 [switch]
 $vv,

 [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
 [switch]
 $Cpg,

 [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
 [switch]
 $Host,

 [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
 [switch]
 $F,

 [Parameter(Position=4, Mandatory=$true, ValueFromPipeline=$true)]
 [System.String]
 $ObjName,

 [Parameter(Position=5, Mandatory=$true, ValueFromPipeline=$true)]
 [System.String]
 $DomainName,

 [Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
 $SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Move-Domain - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Move-Domain since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Move-Domain since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " movetodomain "

 if($Vv)
 {
	$Cmd += " -vv "
 }

 if($Cpg)
 {
	$Cmd += " -cpg "
 }

 if($Host)
 {
	$Cmd += " -host "
 }

 if($F)
 {
	$Cmd += " -f "
 }
	
 if($ObjName)
 {
	$Cmd += " $ObjName "
 }
 
 if($DomainName)
 {
	$Cmd += " $DomainName "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Move-Domain Command -->" INFO: 
 
 if($Result -match "Id")
 {
	$Cnt = $Result.count
		
 	$tempFile = [IO.Path]::GetTempFileName()
	$LastItem = $Result.Count -1  
	
	foreach ($s in  $Result[0..$LastItem] )
	{		
		$s= [regex]::Replace($s,"^ ","")			
		$s= [regex]::Replace($s," +",",")	
		$s= [regex]::Replace($s,"-","")
		$s= $s.Trim()
		Add-Content -Path $tempfile -Value $s				
	}
	Import-Csv $tempFile 
	del $tempFile 	
 }
 
 if($Result -match "Id")
 {
	return  " Success : Executing Move-Domain"
 }
 else
 {			
	return "FAILURE : While Executing Move-Domain `n $Result"
 }
 
} ##  End-of Move-Domain

##########################################################################
######################### FUNCTION New-Domain #########################
##########################################################################
Function New-Domain()
{
<#
  .SYNOPSIS
   New-Domain : Create a domain.

  .DESCRIPTION
   The New-Domain command creates system domains.

  .EXAMPLE
	New-Domain -Domain_name xxx
  
  .EXAMPLE
	New-Domain -Domain_name xxx -Comment "Hello"

  .PARAMETER Domain_name
	Specifies the name of the domain you are creating. The domain name can be no more than 31 characters. The name "all" is reserved.
	
  .PARAMETER Comment
   Specify any comments or additional information for the domain. The comment can be up to 511 characters long. Unprintable characters are not allowed. 
   The comment must be placed inside quotation marks if it contains spaces.

  .PARAMETER Vvretentiontimemax
   Specify the maximum value that can be set for the retention time of a volume in this domain. <time> is a positive integer value and in the range of 0 - 43,800 hours (1825 days).
   Time can be specified in days or hours providing either the 'd' or 'D' for day and 'h' or 'H' for hours following the entered time value.
   To disable setting the volume retention time in the domain, enter 0 for <time>.

  .Notes
    NAME: New-Domain
    LASTEDIT 19-11-2019 
    KEYWORDS: New-Domain
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false , ValueFromPipeline=$true)]
	[System.String]
	$Comment,

	[Parameter(Position=1, Mandatory=$false , ValueFromPipeline=$true)]
	[System.String]
	$Vvretentiontimemax,

	[Parameter(Position=2, Mandatory=$true , ValueFromPipeline=$true)]
	[System.String]
	$Domain_name,

	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In New-Domain - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
  #check if connection object contents are null/empty
  $Validate1 = Test-CLIConnection $SANConnection
  if($Validate1 -eq "Failed")
  {
    #check if global connection object contents are null/empty
    $Validate2 = Test-CLIConnection $global:SANConnection
    if($Validate2 -eq "Failed")
    {
        Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
        Write-DebugLog "Stop: Exiting New-Domain since SAN connection object values are null/empty" $Debug 
        Return "Unable to execute the cmdlet New-Domain since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
    }
  }
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " createdomain "


 if($Comment)
 {
	$Cmd += " -comment " + '" ' + $Comment +' "'	
 }
 
 if($Vvretentiontimemax)
 {
	$Cmd += " -vvretentiontimemax $Vvretentiontimemax "
 } 

 if($Domain_name)
 {
	$Cmd += " $Domain_name "
 }
 else
 {
	return "Domain Required.."
 }
  
 #write-host "CMD = $cmd"
  
 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : New-Domain Command -->" INFO: 
 
 Return $Result

 
 if ([string]::IsNullOrEmpty($Result))
 {
    Return $Result = "Domain : $Domain_name Created Successfully."
 }
 else
 {
	 Return $Result
 }
} ##  End-of New-Domain

##########################################################################
######################### FUNCTION New-DomainSet #########################
##########################################################################
Function New-DomainSet()
{
<#
  .SYNOPSIS
   New-DomainSet : create a domain set or add domains to an existing set

  .DESCRIPTION
   The New-DomainSet command defines a new set of domains and provides the option of assigning one or more existing domains to that set. 
   The command also allows the addition of domains to an existing set by use of the -add option.

  .EXAMPLE
   New-DomainSet -SetName xyz 

  .PARAMETER SetName
	Specifies the name of the domain set to create or add to, using up to 27 characters in length.
  
  .PARAMETER Add
   Specifies that the domains listed should be added to an existing set. At least one domain must be specified.

  .PARAMETER Comment
   Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.

  .Notes
    NAME: New-DomainSet
    LASTEDIT 19-11-2019
    KEYWORDS: New-DomainSet
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
 
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
	[System.String]
	$SetName,
	
	[Parameter(Position=1, Mandatory=$false , ValueFromPipeline=$true)]
	[switch]
	$Add,

	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Comment,	
	
	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In New-DomainSet - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting New-DomainSet since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet New-DomainSet since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

 $Cmd = " createdomainset " 
 
 if($Add)
 {
	$Cmd += " -add "
 }

 if($Comment)
 {
	$Cmd += " -comment " + '" ' + $Comment +' "'
 }
 
 if($SetName)
 {
	$Cmd += " $SetName "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : New-DomainSet Command -->" INFO: 
 
 Return $Result
} ##  End-of New-DomainSet

##########################################################################
######################### FUNCTION Remove-Domain #########################
##########################################################################
Function Remove-Domain()
{
<#
  .SYNOPSIS
   Remove-Domain - Remove a domain

  .DESCRIPTION
   The Remove-Domain command removes an existing domain from the system.

  .EXAMPLE
   Remove-Domain -DomainName xyz

  .PARAMETER DomainName
	Specifies the domain that is removed. If the -pat option is specified the DomainName will be treated as a glob-style pattern, and multiple domains will be considered.

  .PARAMETER Pat
   Specifies that names will be treated as glob-style patterns and that all domains matching the specified pattern are removed.

  .Notes
    NAME: Remove-Domain
    LASTEDIT 19-11-2019
    KEYWORDS: Remove-Domain
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]
	$Pat,

	[Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
	[System.String]
	$DomainName,

	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Remove-Domain - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Remove-Domain since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Remove-Domain since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " removedomain -f "

 if($Pat)
 {
	$Cmd += " -pat "
 }

 if($DomainName)
 {
	$Cmd += " $DomainName "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Remove-Domain Command -->" INFO: 
 Return $Result
 
} ##  End-of Remove-Domain

##########################################################################
######################### FUNCTION Remove-DomainSet #########################
##########################################################################
Function Remove-DomainSet()
{
<#
  .SYNOPSIS
   Remove-DomainSet : remove a domain set or remove domains from an existing set

  .DESCRIPTION
   The Remove-DomainSet command removes a domain set or removes domains from an existing set.

  .EXAMPLE
	Remove-DomainSet -SetName xyz
	
  .PARAMETER SetName
	Specifies the name of the domain set. If the -pat option is specified the setname will be treated as a glob-style pattern, and multiple domain sets will be considered.

  .PARAMETER Domain
	Optional list of domain names that are members of the set.
	If no <Domain>s are specified, the domain set is removed, otherwise the specified <Domain>s are removed from the domain set. 
	If the -pat option is specified the domain will be treated as a glob-style pattern, and multiple domains will be considered.
  
  .PARAMETER F
   Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.

  .PARAMETER Pat
   Specifies that both the set name and domains will be treated as glob-style patterns.

  .Notes
    NAME: Remove-DomainSet
    LASTEDIT 19-11-2019
    KEYWORDS: Remove-DomainSet
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
 [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
 [switch]
 $F,

 [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
 [switch]
 $Pat,

 [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
 [System.String]
 $SetName,

 [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
 [System.String]
 $Domain,

 [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
 $SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Remove-DomainSet - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Remove-DomainSet since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Remove-DomainSet since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " removedomainset "

 if($F)
 {
  $Cmd += " -f "
 }

 if($Pat)
 {
  $Cmd += " -pat "
 }

 if($SetName)
 {
  $Cmd += " $SetName "
 }

 if($Domain)
 {
  $Cmd += " $Domain "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Remove-DomainSet Command -->" INFO: 
 
 Return $Result
} ##  End-of Remove-DomainSet

##########################################################################
######################### FUNCTION Set-Domain #########################
##########################################################################
Function Set-Domain()
{
<#
  .SYNOPSIS
   Set-Domain Change current domain CLI environment parameter.

  .DESCRIPTION
   The Set-Domain command changes the current domain CLI environment parameter.

  .EXAMPLE
   Set-Domain
   
  .EXAMPLE
   Set-Domain -Domain "XXX"
   
  .PARAMETER Domain
	Name of the domain to be set as the working domain for the current CLI session.  
	If the <domain> parameter is not present or is equal to -unset then the working domain is set to no current domain.
	

  .Notes
    NAME: Set-Domain
    LASTEDIT 19-11-2019
    KEYWORDS: Set-Domain
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
 [CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[System.String]
	$Domain,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Set-Domain - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
  #check if connection object contents are null/empty
  $Validate1 = Test-CLIConnection $SANConnection
  if($Validate1 -eq "Failed")
  {
    #check if global connection object contents are null/empty
    $Validate2 = Test-CLIConnection $global:SANConnection
    if($Validate2 -eq "Failed")
    {
        Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
        Write-DebugLog "Stop: Exiting Set-Domain since SAN connection object values are null/empty" $Debug 
        Return "Unable to execute the cmdlet Set-Domain since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
    }
  }
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " changedomain "

 if($Domain)
 {
	$Cmd += " $Domain "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Set-Domain Command" INFO: 
 
 if([System.String]::IsNullOrEmpty($Domain))
 {
	$Result = "Working domain is unset to current domain."
	Return $Result
 }
 else
 {
	if([System.String]::IsNullOrEmpty($Result))
	 {
		$Result = "Domain : $Domain to be set as the working domain for the current CLI session."
		Return $Result
	 }
	 else
	 {
		Return $Result
	 }	
 }
 
} ##  End-of Set-Domain

##########################################################################
######################### FUNCTION Update-Domain #########################
##########################################################################
Function Update-Domain()
{
<#
  .SYNOPSIS
   Update-Domain : Set parameters for a domain.

  .DESCRIPTION
   The Update-Domain command sets the parameters and modifies the properties of a
   domain.

  .EXAMPLE
   Update-Domain -DomainName xyz
 
  .PARAMETER DomainName
	Indicates the name of the domain.(Existing Domain Name)

  .PARAMETER NewName
   Changes the name of the domain.

  .PARAMETER Comment
   Specifies comments or additional information for the domain. The comment can be up to 511 characters long and must be enclosed in quotation
   marks. Unprintable characters are not allowed within the <comment> specifier.

  .PARAMETER Vvretentiontimemax
   Specifies the maximum value that can be set for the retention time of
   a volume in this domain. <time> is a positive integer value and in the
   range of 0 - 43,800 hours (1825 days). Time can be specified in days or
   hours providing either the 'd' or 'D' for day and 'h' or 'H' for hours
   following the entered time value.
   To remove the maximum volume retention time for the domain, enter
   '-vvretentiontimemax ""'. As a result, the maximum volume retention
   time for the system is used instead.
   To disable setting the volume retention time in the domain, enter 0
   for <time>.

  .Notes
    NAME: Update-Domain
    LASTEDIT 19-11-2019
    KEYWORDS: Update-Domain
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$NewName,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Comment,

	[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
	[System.String]
	$Vvretentiontimemax,

	[Parameter(Position=3, Mandatory=$true, ValueFromPipeline=$true)]
	[System.String]
	$DomainName,

	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Update-Domain - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Update-Domain since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Update-Domain since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

	$Cmd = " setdomain "

 if($NewName)
 {
	$Cmd += " -name $NewName "
 }

 if($Comment)
 {
	$Cmd += " -comment " + '" ' + $Comment +' "'
 }

 if($Vvretentiontimemax)
 {
	$Cmd += " -vvretentiontimemax $Vvretentiontimemax "
 }

 if($DomainName)
 {
	$Cmd += " $DomainName "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Update-Domain Command -->" INFO: 
 
 Return $Result
} ##  End-of Update-Domain

##########################################################################
######################### FUNCTION Update-DomainSet #########################
##########################################################################
Function Update-DomainSet()
{
<#
  .SYNOPSIS
   Update-DomainSet : set parameters for a domain set

  .DESCRIPTION
   The Update-DomainSet command sets the parameters and modifies the properties of
   a domain set.

  .EXAMPLE
   Update-DomainSet -DomainSetName xyz
  
  .PARAMETER DomainSetName
	Specifies the name of the domain set to modify.
	
  .PARAMETER Comment
   Specifies any comment or additional information for the set. The
   comment can be up to 255 characters long. Unprintable characters are
   not allowed.

  .PARAMETER NewName
   Specifies a new name for the domain set, using up to 27 characters in length.

  .Notes
    NAME: Update-DomainSet
    LASTEDIT 19-11-2019
    KEYWORDS: Update-DomainSet
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
 [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
 [System.String]
 $Comment,

 [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
 [System.String]
 $NewName,

 [Parameter(Position=2, Mandatory=$true, ValueFromPipeline=$true)]
 [System.String]
 $DomainSetName,

 [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
 $SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Update-DomainSet - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Update-DomainSet since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Update-DomainSet since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " setdomainset "

 if($Comment)
 {
	$Cmd += " -comment " + '" ' + $Comment +' "'
 }

 if($NewName)
 {
  $Cmd += " -name $NewName "
 }

 if($DomainSetName)
 {
  $Cmd += " $DomainSetName "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Update-DomainSet Command -->" INFO: 
 
 Return $Result
 
} ##  End-of Update-DomainSet


Export-ModuleMember Get-Domain , Get-DomainSet , Move-Domain , New-Domain , New-DomainSet , Remove-Domain , Remove-DomainSet , Set-Domain , Update-Domain , Update-DomainSet
# SIG # Begin signature block
# MIIhEAYJKoZIhvcNAQcCoIIhATCCIP0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDD2EsM8Mhluvmt
# WGklfPL5eHoZvH3wWJsen6GRtIQzyaCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
# xUgD+jf1OoqlMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDUyODAwMDAwMFoXDTIyMDUyODIzNTk1OVowgZAxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlQYWxvIEFsdG8x
# KzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkxKzAp
# BgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRlcnByaXNlIENvbXBhbnkwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDmclZSXJBXA55ijwwFymuq+Y4F/quF
# mm2vRdEmjFhzRvTpnGjIYtVcG11ka4JGCROmNVDZGAelnqcXn5DKO710j5SICTBC
# 5gXOLwga7usifs21W+lVT0BsZTiUnFu4hEhuFTlahJIEvPGVgO1GBcuItD2QqB4q
# 9j15GDI5nGBSzIyJKMctcIalxsTSPG1kiDbLkdfsIivhe9u9m8q6NRqDUaYYQTN+
# /qGCqVNannMapH8tNHqFb6VdzUFI04t7kFtSk00AkdD6qUvA4u8mL2bUXAYz8K5m
# nrFs+ckx5Yqdxfx68EO26Bt2qbz/oTHxE6FiVzsDl90bcUAah2l976ebAgMBAAGj
# ggGQMIIBjDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUlC56g+JaYFsl5QWK2WDVOsG+pCEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAY+1n2UUlQU6Z
# VoEVaZKqZf/zrM/d7Kbx+S/t8mR2E+uNXStAnwztElqrm3fSr+5LMRzBhrYiSmea
# w9c/0c7qFO9mt8RR2q2uj0Huf+oAMh7TMuMKZU/XbT6tS1e15B8ZhtqOAhmCug6s
# DuNvoxbMpokYevpa24pYn18ELGXOUKlqNUY2qOs61GVvhG2+V8Hl/pajE7yQ4diz
# iP7QjMySms6BtZV5qmjIFEWKY+UTktUcvN4NVA2J0TV9uunDbHRt4xdY8TF/Clgz
# Z/MQHJ/X5yX6kupgDeN2t3o+TrColetBnwk/SkJEsUit0JapAiFUx44j4w61Qanb
# Zmi0tr8YGDCCBYEwggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcN
# AQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQx
# ITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAw
# MDBaFw0yODEyMzEyMzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3
# IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIAS
# ZRc2DsPbCLPQrFcNdu3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3
# KBErR9o5xrw6GbRfpr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/
# owbxiBhqkCI8vP4T8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41
# pqdmyHJn2yFmsdSbeAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpN
# rkyKt1yatLcgPcp/IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5p
# x2uMYJPexMcM3+EyrsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVm
# sSl8MoRjVYnEDcGTVDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWI
# zYS4sT+kOQ/ZAp7rEkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/
# NVV0CUnYSVgaf5I25lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79
# dGMvsVBlCeZYQi5DGky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK6
# 1l9VLupcxigIBCU5uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0j
# BBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh
# 2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1Ud
# IAQKMAgwBgYEVR0gADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9k
# b2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG
# 9w0BAQwFAAOCAQEAGIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qof
# nJYt7wNKfq70jW9yPEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrw
# kZb+/UNkfv3M0gGhfX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx
# 8VvwQQuYAAoiAxDlDLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdc
# Ods/exgNRc2ThZYvXd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4Ux
# FMToqWpMgLxqeM+4f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBv
# myYY0ILgln0z02owDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENl
# cnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIz
# NTk1OVowfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilA
# hlRGdDFixRDtsocnppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6
# DBmJqGx7rQDDYaHcaWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpy
# vjg7Y96Pv25MQV0SIAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52B
# xHJAteJf7wtF/6POF6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G
# 2flGHNyMfHEo8/6nxhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIB
# YDAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6
# qFM6MdWKvsG7rWcaA4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgw
# BgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5j
# b20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYB
# BQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20v
# VVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9v
# Y3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNve
# aiqMm/EAAB4dYns61zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS
# 9At3WpwqQTr81vTr5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3
# ZLCmI2pZaFJCX/8E6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1
# fqW4w2y1z99KeYdcx0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6f
# ICUQDRn7UJBhvjmPeo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIe
# Q3pFMcGcTanwWbJZGehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lk
# uk/xYpMoJVcp+1EZx6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9
# V1DSyt39ngVR5UR43QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoK
# C6W59J7umDIFhZ7r+YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLj
# tXX4oemOCiUe5B7xn1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1q
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPuzCCD7cCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# u79H72ek2qi+ZN1L3HPS68pnaCmxm0o2pWRFdKsZhIowDQYJKoZIhvcNAQEBBQAE
# ggEAhMEE9Um9CwuK/FNJ18b0KtzmyMZFl1Xv/dQh3A3jkU8qAjahr4t2hgUIJ6Or
# 9KF1JGtz0MqqggyusP8Xf3njna/BJNkGAFUHe3k41MJR/TV4mph9FZDg/ygGj/x7
# j1ot3Sy1tW4RLClbdhhVH+ZkYsiNPFeJRqB85jKsGQ630/gF4UPRO4OHBRz9mC+V
# pp1xzBunQ8sjjJXrS5TviYuytCzBQbrB0ppbBhc+eatIpflaEzV0DvTaTzMFvt6n
# /HzBdG0tDfAFgbN+AavyKVj1PG4wd6y0Id4QCoklNPmRP8AX10C1ZF7S0EGhQvhM
# bQ4ij2GCNP8sO3k0r0eW9iRKN6GCDX0wgg15BgorBgEEAYI3AwMBMYINaTCCDWUG
# CSqGSIb3DQEHAqCCDVYwgg1SAgEDMQ8wDQYJYIZIAWUDBAIBBQAwdwYLKoZIhvcN
# AQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCB0qjDl
# Zre0xCMc5YszKXXRdDa2GByNvO2PbA1cYG504AIQKtikXP7TFhiw59rBu+H2RBgP
# MjAyMTA2MTkwNDA2MThaoIIKNzCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA
# 8N0wDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAxMDEw
# MDAwMDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjEw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXKY2tR
# 1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj/TZq
# gfop+N0rcIXeAhjzeG28ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj
# 4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDrDo4s
# 1SPa9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDC
# m2mCtNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1JhL0B
# AgMBAAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATApMCcG
# CCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgw
# FoAU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwoLR1E
# Nt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9zaGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdpY2Vy
# dC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURU
# aW1lc3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrn
# IA6OZ0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQCZk3t
# aaQP9rhwz2Lo9VFKeHk2eie38+dSn5On7UOee+e03UEiifuHokYDTvz0/rdkd2Nf
# I1Jpg4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO+MDh
# XM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j1h9b
# m/cuG08THfdKDXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5Npjhyyja
# W4emii8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHkBdo2l8IVMA0GCSqGSIb3DQEB
# CwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQg
# SUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0zMTAxMDcxMjAwMDBaMHIxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBU
# aW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9
# 0DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5fU1ofue2oPSNs4jkl79jIZCY
# vxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb6+NGRwYaVX4LJ37AovWg4N4i
# Pw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU46gJcWvgzyIQD3XPcXJOCq3f
# QDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mIUF79Zm5WYScpiYRR5oLnRlD9
# lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfxFwbvPc3WTe8GQv2iUypPhR3E
# HTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAdBgNVHQ4EFgQU9LbhIB3+Ka7S
# 5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wEgYD
# VR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4
# oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkwRzA4BgpghkgBhv1sAAIEMCow
# KAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJYIZI
# AYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLpUYdWac3v3dp8qmN6s3jPBjdA
# hO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4
# stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC4HLHmNY8ZOUfSBAYX4k4YU1i
# RiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+tpJn+1Nhiaj1a5bA9FhpDXzI
# AbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6HUSHkWGCbugwtK22ixH67xCUr
# RwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIvIjayS6JKldj1po5SMYIChjCC
# AoICAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hB
# MiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TAN
# BglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJ
# KoZIhvcNAQkFMQ8XDTIxMDYxOTA0MDYxOFowKwYLKoZIhvcNAQkQAgwxHDAaMBgw
# FgQU4deCqOGRvu9ryhaRtaq0lKYkm/MwLwYJKoZIhvcNAQkEMSIEIA0KJ0vKC29p
# WkfSljhwrALulBHJgCpefOc5spsI8DU0MDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIE
# ILMQkAa8CtmDB5FXKeBEA0Fcg+MpK2FPJpZMjTVx7PWpMA0GCSqGSIb3DQEBAQUA
# BIIBAKAioVtWk4jjrmGkiXapLBoBpPczy1NOvyP2KIdML84mt57U6GEJyY2kti6g
# 9r6X7d5s/p5T0VxiSHmT5Jt+vauwX+bKLaTBdSg5WTc82JXZdMfEsmVfQ1hFEouH
# dxGvefi30uo/Tn2dwH9+D8gZ/BBU4sCo5piskwrHSC9dIg6CDHv6yDHMFzezQDpa
# CxVQaQKkfCDQqwr6C2lDv3G/vRI7nCoqSI5RO35ElEBKt6uwDzYUoYCoZEFYgzeY
# H2gOn+2r/K35kqHv8y4dslcR1q8YwFn4tR1p3CDXuSefvW2f3NwR0FipZ/BfnbEy
# 9z/M7dHTirZ87wN1I/EDzLQMKD0=
# SIG # End signature block
