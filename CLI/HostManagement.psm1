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
##	File Name:		HostManagement.psm1
##	Description: 	Host Management cmdlets 
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

############################################################################################################################################
################################################################## FUNCTION Get-Host #######################################################
############################################################################################################################################
Function Get-Host
{
<#
  .SYNOPSIS
	Lists hosts
  
  .DESCRIPTION
	Queries hosts
        
  .EXAMPLE
    Get-Host 
	Lists all hosts

  .EXAMPLE	
	Get-Host -hostName HV01A
	List host HV01A
	
  .EXAMPLE
	Get-Host -Domain scvmm
	
  .EXAMPLE	
	Get-Host -D

  .EXAMPLE
	Get-Host -CHAP

  .EXAMPLE
	Get-Host -Descriptor

  .EXAMPLE
	Get-Host -Agent

  .EXAMPLE
	Get-Host -Pathsum

  .EXAMPLE
	Get-Host -Persona

  .EXAMPLE
	Get-Host -Listpersona

  .PARAMETER D
	Shows a detailed listing of host and path information. This option can
	be used with -agent and -domain options.

  .PARAMETER Verb
	Shows a verbose listing of all host information. This option cannot
	be used with -d.

  .PARAMETER CHAP
	Shows the CHAP authentication properties. This option cannot be used
	with -d.

  .PARAMETER Descriptor
	Shows the host descriptor information. This option cannot be used with
	-d.

  .PARAMETER Agent
	Shows information provided by host agent.

  .PARAMETER Pathsum
	Shows summary information about hosts and paths. This option cannot be
	used with -d.

  .PARAMETER Persona
	Shows the host persona settings in effect. This option cannot be used
	with -d.

  .PARAMETER Listpersona
	Lists the defined host personas. This option cannot be used with -d.

  .PARAMETER NoName
	Shows only host paths (WWNs and iSCSI names) not assigned to any host.
	This option cannot be used with -d.

  .PARAMETER Domain 
	Shows only hosts that are in domains or domain sets that match one or
	more of the specifier <domainname_or_pattern> or set <domainset>
	arguments. The set name <domain_set> must start with "set:". This
	specifier does not allow listing objects within a domain of which the
	user is not a member.

  .PARAMETER CRCError
	Shows the CRC error counts for the host/port.
	
  .PARAMETER hostName
    Specify new name of the host
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Get-Host  
    LASTEDIT: 19/11/2019
    KEYWORDS: Get-Host
   
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
		[Switch]
		$D,
		
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Verb,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$CHAP,
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Descriptor,
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Agent,
		
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Pathsum,
		
		[Parameter(Position=7, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Persona,
		
		[Parameter(Position=8, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$Listpersona,
		
		[Parameter(Position=9, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$NoName,
		
		[Parameter(Position=10, Mandatory=$false, ValueFromPipeline=$true)]
		[Switch]
		$CRCError,
		
		[Parameter(Position=11, Mandatory=$false)]
		[System.String]
		$hostName,
		
		[Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Get-Host - validating input values" $Debug 
	#check if connection object contents are null/empty
	if (!$SANConnection)
	{		
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Get-Host since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Get-Host since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	
	$cliresult1 = Test-PARCli -SANConnection $SANConnection
	if($cliresult1 -match "FAILURE :")
	{
		write-debuglog "$cliresult1" "ERR:" 
		return $cliresult1
	}
	
	$CurrentId = $CurrentName = $CurrentPersona = $null
	$ListofvHosts = @()	
	
	$GetHostCmd = "showhost "
	
	if ($Domain)
	{
		$GetHostCmd +=" -domain $Domain"
	}
	if ($D)
	{
		$GetHostCmd +=" -d "
	}
	if ($Verb)
	{
		$GetHostCmd +=" -verbose "
	}
	if ($CHAP)
	{
		$GetHostCmd +=" -chap "
	}
	if ($Descriptor)
	{
		$GetHostCmd +=" -desc "
	}
	if ($Agent)
	{
		$GetHostCmd +=" -agent "
	}
	if ($Pathsum)
	{
		$GetHostCmd +=" -pathsum "
	}
	if ($Persona)
	{
		$GetHostCmd +=" -persona "
	}
	if ($Listpersona)
	{
		$GetHostCmd +=" -listpersona "
	}
	if ($NoName)
	{
		$GetHostCmd +=" -noname "
	}
	if ($CRCError)
	{
		$GetHostCmd +=" -lesb "
	}	
	if($hostName)
	{
		$objType = "host"
		$objMsg  = "hosts"
		
		## Check Host Name 
		##
		if ( -not (Test-CLIObject -objectType $objType -objectName $hostName -objectMsg $objMsg -SANConnection $SANConnection))
		{
			write-debuglog "host $hostName does not exist. Nothing to List" "INFO:" 
			return "FAILURE : No host $hostName found"
		}
	}
	
	$GetHostCmd+=" $hostName"
	#write-host "$GetHostCmd"
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $GetHostCmd	
	write-debuglog "Get list of Hosts" "INFO:" 
	if ($Result -match "no hosts listed")
	{
		return "Success : no hosts listed"
	}
	if ($Verb -or $Descriptor)
	{
		return $Result
	}
	
	$tempFile = [IO.Path]::GetTempFileName()
	$Header = $Result[0].Trim() -replace '-WWN/iSCSI_Name-' , ' Address' 
	
	set-content -Path $tempFile -Value $Header
	$Result_Count = $Result.Count - 3
	if($Agent)
	{
		$Result_Count = $Result.Count - 3			
	}
	if($Result.Count -gt 3)
	{	
		$CurrentId = $null
		$CurrentName = $null
		$CurrentPersona = $null		
		$address = $null
		$Port = $null
		
		$Flg = "false"
		
		foreach ($s in $Result[1..$Result_Count])
		{	
			if($Pathsum)
			{
				$s =  [regex]::Replace($s , "," , "|"  )  # Replace ','  with "|"	
			}			
			if($Flg -eq "true")
			{
				$temp = $s.Trim()
				$temp1 = $temp.Split(',')
				if($temp1[0] -match "--")
				{
					$temp =  [regex]::Replace($temp , "--" , ""  )  # Replace '--'  with ""				
					$s = $temp
				}
			}
		    $Flg = "true"
			
			$match = [regex]::match($s, "^  +")   # Match Line beginning with 1 or more spaces
			if (-not ($match.Success))
			{
				$s= $s.Trim()				
				$s= [regex]::Replace($s, " +" , "," )	# Replace spaces with comma (,)
								
				$sTemp = $s.Split(',')
				$TempCnt = $sTemp.Count
				if($TempCnt -eq 2)
				{
					$address = $sTemp[0]
					$Port = $sTemp[1] # [regex]::Replace($sTemp[4] , "-+" , ""  )  # Replace '----'  with ""  
				}
				else
				{
					$CurrentId =  $sTemp[0]
					$CurrentName = $sTemp[1]
					$CurrentPersona = $sTemp[2]			
					$address = $sTemp[3]
					$Port = $sTemp[4] # [regex]::Replace($sTemp[4] , "-+" , ""  )  # Replace '----'  with ""
				}
				
				$vHost = New-Object -TypeName _vHost 
				$vHost.ID = $CurrentId
				$vHost.Persona = $currentPersona
				$vHost.Name = $CurrentName
				$vHost.Address = $address
				$vHost.Port= $port
			}			
			else
			{
				$s = $s.trim()
				$s= [regex]::Replace($s, " +" , "," )								
				$sTemp = $s.Split(',')
				$TempCnt1 = $sTemp.Count
				
				if($TempCnt1 -eq 2)
				{
					$address = $sTemp[0]
					$Port = $sTemp[1] # [regex]::Replace($sTemp[4] , "-+" , ""  )  # Replace '----'  with ""  
				}
				else
				{
					$CurrentId =  $sTemp[0]
					$CurrentName = $sTemp[1]
					$CurrentPersona = $sTemp[2]			
					$address = $sTemp[3]
					$Port = $sTemp[4] # [regex]::Replace($sTemp[4] , "-+" , ""  )  # Replace '----'  with ""
				}
				
				$vHost = New-Object -TypeName _vHost 
				$vHost.ID = $CurrentId
				$vHost.Persona = $currentPersona
				$vHost.Name = $CurrentName
				$vHost.Address = $address
				$vHost.Port= $port
			}
			
			$ListofvHosts += $vHost		
		}	
	}	
	else
	{
		del $tempFile
		return "Success : No Data Available for Host Name :- $hostName"
	}
	del $tempFile
	$ListofvHosts	
	
} # ENd Get-Host

#####################################################################################################################
## FUNCTION Get-HostSet
#####################################################################################################################
Function Get-HostSet
{
<#
  .SYNOPSIS
    show host set(s) information	
  
  .DESCRIPTION
    The showhostset command lists the host sets defined on the storage system and their members.
        
  .EXAMPLE
    Get-HostSet	
	List all host set information

  .EXAMPLE
	Get-HostSet -D myset
	Show the details of myset
	
  .EXAMPLE
	Get-HostSet -hostSetName "MyVVSet"	
	List Specific HostSet name "MyVVSet"
	
  .EXAMPLE	
	Get-HostSet -hostName "MyHost"	 
	Show the host sets containing host "MyHost"	
	
  .EXAMPLE	
	Get-HostSet -D	 
	Show a more detailed listing of each set
	
  .PARAMETER D
	Show a more detailed listing of each set.
	
  .PARAMETER hostSetName 
    Specify name of the hostsetname to be listed.

  .PARAMETER hostName 
    Show host sets that contain the supplied hostnames or patterns.

  .PARAMETER summary 
    Shows host sets with summarized output with host set names and number of hosts in those sets.
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Get-HostSet  
    LASTEDIT: 29/05/2021
    KEYWORDS: Get-HostSet
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$hostSetName,
		
		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$hostName,

		[Parameter(Position=2, Mandatory=$false)]
		[Switch]
		$D,
		
		[Parameter(Position=3, Mandatory=$false)]
		[Switch]
		$summary,
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)		
	
	Write-DebugLog "Start: In Get-HostSet - validating input values" $Debug 
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
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Get-HostSet since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Get-HostSet since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}

	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	$GetHostSetCmd = "showhostset "
	if($D)
	{
		$GetHostSetCmd +=" -d"
	}
	if($summary)
	{
		$GetHostSetCmd +=" -summary"
	}	
	if ($hostName)
	{		
		$GetHostSetCmd +=" -host $hostName"
	}
	if ($hostSetName)
	{		
		$GetHostSetCmd +=" $hostSetName"
	}	
	else
	{
		write-debuglog "HostSet parameter is empty. Simply return all hostset information " "INFO:"
	}
		
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $GetHostSetCmd
	$Result
	
	<#
	if($Result -match "total")
	{	
		if($summary)
		{
			$ID = $null
			$Name = $null
			$HOST_Cnt = $null
			$VVOLSC = $null
			$Flashcache = $null
			$QoS = $null
			$RC_host = $null

			$ListofvHosts = @()	
			
			$tempFile = [IO.Path]::GetTempFileName()
			$Header = $Result[0].Trim() -replace 'id' , ' ID' 
			set-content -Path $tempFile -Value $Header
			
			$LastItem = $Result.Count -3  
			#Write-Host " Result Count =" $Result.Count
			foreach ($s in  $Result[1..$LastItem] )
			{				
				$s= $s.Trim()				
				$s= [regex]::Replace($s, " +" , "," )	# Replace spaces with comma (,)						
				$sTemp = $s.Split(',')
				$TempCnt = $sTemp.Count			
				
				if($TempCnt -gt 1)
				{
					$ID = $sTemp[0]
					$Name = $sTemp[1]
					$HOST_Cnt = $sTemp[2]
					$VVOLSC = $sTemp[3]
					$Flashcache = $sTemp[4]
					$QoS = $sTemp[5]
					$RC_host = $sTemp[6]						
				}				
				$vHostSummary = New-Object -TypeName _vHostSetSummary
				$vHostSummary.ID = $ID
				$vHostSummary.Name = $Name
				$vHostSummary.HOST_Cnt = $HOST_Cnt
				$vHostSummary.VVOLSC = $VVOLSC
				$vHostSummary.Flashcache = $Flashcache
				$vHostSummary.QoS = $QoS
				$vHostSummary.RC_host = $RC_host
				
				$ListofvHosts += $vHostSummary
			}
		}
		else
		{
			$ID = $null
			$Name = $null
			$Membr = $null		
			#$address = $null
			
			$ListofvHosts = @()	
			
			$tempFile = [IO.Path]::GetTempFileName()
			$Header = $Result[0].Trim() -replace 'id' , ' ID' 
			set-content -Path $tempFile -Value $Header
		
			$LastItem = $Result.Count -3  
			#Write-Host " Result Count =" $Result.Count
			foreach ($s in  $Result[1..$LastItem] )
			{				
				$s= $s.Trim()				
				$s= [regex]::Replace($s, " +" , "," )	# Replace spaces with comma (,)						
				$sTemp = $s.Split(',')
				$TempCnt = $sTemp.Count			
				
				if($TempCnt -gt 1)
				{
					$ID =  $sTemp[0]
					$Name = $sTemp[1]
					$Membr = $sTemp[2]	
				}
				else
				{
					$Membr = $sTemp[0]
				}
				
				$vHost = New-Object -TypeName _vHostSet 
				$vHost.ID = $ID
				$vHost.Name = $Name
				$vHost.Members = $Membr			
				
				$ListofvHosts += $vHost
			}
		}
	}
	else
	{
		return $Result
	}
	del $tempFile
	$ListofvHosts
	
	<#
	if($Result -match "total")
	{
		Return $Result + "`n `n Success : Executing Get-HostSet"
	}
	else
	{
		return $Result
	}
	#>
	
} # End Get-HostSet

############################################################################################################################################
## FUNCTION New-Host
############################################################################################################################################
Function New-Host
{
<#
  .SYNOPSIS
    Creates a new host.
  
  .DESCRIPTION
	Creates a new host.
        
  .EXAMPLE
    New-Host -HostName HV01A -Persona 2 -WWN 10000000C97B142E
	Creates a host entry named HV01A with WWN equals to 10000000C97B142E
	
  .EXAMPLE	
	New-Host -HostName HV01B -Persona 2 -iSCSI
	Creates a host entry named HV01B with iSCSI equals to iqn.1991-06.com.microsoft:dt-391-xp.hq.3par.com
	
  .EXAMPLE
    New-Host -HostName HV01A -Persona 2 

  .EXAMPLE New-Host -HostName Host3 -iSCSI

  .EXAMPLE New-Host -HostName Host4 -iSCSI -Domain ZZZ
	
  .PARAMETER HostName
    Specify new name of the host
	
  .PARAMETER Add
	Add the specified WWN(s) or iscsi_name(s) to an existing host (at least
	one WWN or iscsi_name must be specified).  Do not specify host persona.

  .PARAMETER Domain
	Create the host in the specified domain or domain set. The default is to
	create it in the current domain, or no domain if the current domain is
	not set. The domain set name must start with "set:".

  .PARAMETER Forces
	Forces the tear down of lower priority VLUN exports if necessary.

  .PARAMETER Persona
	Sets the host persona that specifies the personality for all ports
	which are part of the host set.  This selects certain variations in
	scsi command behavior which certain operating systems expect.
	<hostpersonaval> is the host persona id number with the desired
	capabilities.  These can be seen with showhost -listpersona.

  .PARAMETER Location
	Specifies the host's location.

  .PARAMETER IPAddress
	Specifies the host's IP address.

  .PARAMETER OS
	Specifies the operating system running on the host.

  .PARAMETER Model
	Specifies the host's model.

  .PARAMETER Contact
	Specifies the host's owner and contact information.

  .PARAMETER Comment
	Specifies any additional information for the host.

  .PARAMETER NSP
	Specifies the desired relationship between the array port(s) and host
	for target-driven zoning. Multiple array ports can be specified by
	either using a pattern or a comma-separated list.  This option is used
	only when the Smart SAN license is installed.  At least one WWN needs
	to be specified with this option.
	
  .PARAMETER WWN
	Specifies the World Wide Name(WWN) to be assigned or added to an
	existing host. This specifier can be repeated to specify multiple WWNs.
	This specifier is optional.

  .PARAMETER IscsiName
	Host iSCSI name to be assigned or added to a host. This specifier is
	optional.

  .PARAMETER iSCSI
    when specified, it means that the address is an iSCSI address
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  New-Host  
    LASTEDIT: 19/11/2019
    KEYWORDS: New-Host
   
	.Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$HostName,	
		
		[Parameter(Position=1, Mandatory=$false)]
		[switch]
		$Iscsi,
		
		[Parameter(Position=2, Mandatory=$false)]
		[switch]
		$Add,
		
		[Parameter(Position=3, Mandatory=$false)]
		[System.String]
		$Domain,
		
		[Parameter(Position=4, Mandatory=$false)]
		[switch]
		$Forces, 
		
		[Parameter(Position=5, Mandatory=$false)]
		[System.String]
		$Persona = 2,
		
		[Parameter(Position=6, Mandatory=$false)]
		[System.String]
		$Location,
		
		[Parameter(Position=7, Mandatory=$false)]
		[System.String]
		$IPAddress,
		
		[Parameter(Position=8, Mandatory=$false)]
		[System.String]
		$OS,
		
		[Parameter(Position=9, Mandatory=$false)]
		[System.String]
		$Model,
		
		[Parameter(Position=10, Mandatory=$false)]
		[System.String]
		$Contact,
		
		[Parameter(Position=11, Mandatory=$false)]
		[System.String]
		$Comment,
		
		[Parameter(Position=12, Mandatory=$false)]
		[System.String]
		$NSP,
		
		[Parameter(Position=13, Mandatory=$false)]
		[System.String]
		$WWN,
		
		[Parameter(Position=14, Mandatory=$false)]
		[System.String]
		$IscsiName,
		
		[Parameter(Position=15, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In New-Host - validating input values" $Debug 
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
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting New-Host since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet New-Host since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	$cmd ="createhost "
	
	if($Iscsi)
	{
		$cmd +="-iscsi "
	}
	if($Add)
	{
		$cmd +="-add "
	}
	if($Domain)
	{
		$cmd +="-domain $Domain "
	}
	if($Forces)
	{
		$cmd +="-f "
	}
	if($Persona)
	{
		$cmd +="-persona $Persona "
	}
	if($Location)
	{
		$cmd +="-loc $Location "
	}
	if($IPAddress)
	{
		$cmd +="-ip $IPAddress "
	}
	if($OS)
	{
		$cmd +="-os $OS "
	}
	if($Model)
	{
		$cmd +="-model $Model "
	}
	if($Contact)
	{
		$cmd +="-contact $Contact "
	}
	if($Comment)
	{
		$cmd +="-comment $Comment "
	}
	if($NSP)
	{
		$cmd +="-port $NSP "
	}
	if ($HostName)
	{
		$cmd +="$HostName "
	}
	else
	{
		write-debugLog "No name specified for new host. Skip creating host" "ERR:"
		Get-help New-Host
		return
	}
	if ($WWN)
	{
		$cmd +="$WWN "
	}
	if ($IscsiName)
	{
		$cmd +="$IscsiName "
	}
		
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds $cmd	
		
	if([string]::IsNullOrEmpty($Result))
	{
		write-host""
		return "Success : New-Host command executed Host Name : $HostName is created."
	}
	else
	{
		write-host""
		return $Result
	}	   
	 
} # End New-Host

############################################################################################################################################
## FUNCTION New-HostSet
############################################################################################################################################
Function New-HostSet
{
<#
  .SYNOPSIS
    Creates a new host set.
  
  .DESCRIPTION
	Creates a new host set.
        
  .EXAMPLE
    New-HostSet -HostSetName xyz 
	Creates an empty host set named "xyz"

  .EXAMPLE
	To create an empty hostset:
    New-HostSet hostset

  .EXAMPLE
    To add a host to the set:
    New-HostSet -Add -HostSetName hostset -HostName hosta

  .EXAMPLE
    To create a host set with hosts in it:
    New-HostSet -HostSetName hostset -HostName "host1 host2"
    or
    New-HostSet -HostSetName set:hostset -HostName "host1 host2" 

  .EXAMPLE
    To create a host set with a comment and a host in it:
    New-HostSet -Comment "A host set" -HostSetName hostset -HostName hosta
	
  .EXAMPLE
    New-HostSet -HostSetName xyz -Domain xyz
	Create the host set in the specified domain
	
  .EXAMPLE
    New-HostSet -hostSetName HV01C-HostSet -hostName "MyHost"
	Creates an empty host set and  named "HV01C-HostSet" and adds host "MyHost" to hostset
			(or)
	Adds host "MyHost" to hostset "HV01C-HostSet" if hostset already exists
	
  .PARAMETER HostSetName
    Specify new name of the host set

  .PARAMETER hostName
    Specify new name of the host

  .PARAMETER Add
	Specifies that the hosts listed should be added to an existing set.
	At least one host must be specified.

  .PARAMETER Comment
	Specifies any comment or additional information for the set. The
	comment can be up to 255 characters long. Unprintable characters are
	not allowed.

  .PARAMETER Domain
	Create the host set in the specified domain. For an empty set the
	default is to create it in the current domain, or no domain if the
	current domain is not set. A host set must be in the same domain as
	its members; if hosts are specified as part of the creation then
	the set will be created in their domain. The -domain option should
	still be used to specify which domain to use for the set when the
	hosts are members of domain sets. A domain cannot be specified
	when adding a host to an existing set with the -add option.
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  New-HostSet  
    LASTEDIT:19/11/2019
    KEYWORDS: New-HostSet
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$HostSetName,

		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$hostName,
		
		[Parameter(Position=2, Mandatory=$false)]
		[switch]
		$Add,
		
		[Parameter(Position=3, Mandatory=$false)]
		[System.String]
		$Comment,
		
		[Parameter(Position=4, Mandatory=$false)]
		[System.String]
		$Domain,				
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In New-HostSet - validating input values" $Debug 
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
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting New-HostSet since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet New-HostSet since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	
	$cmdCrtHostSet =" createhostset "
	
	if($Add)
	{
		$cmdCrtHostSet +="-add "
	}
	if($Comment)
	{
		$cmdCrtHostSet +="-comment $Comment "
	}
	if($Domain)
	{
		$cmdCrtHostSet +="-domain $Domain "
	}	
	if ($HostSetName)
	{
		$cmdCrtHostSet +=" $HostSetName "
	}
	else
	{
		write-debugLog "No name specified for new host set. Skip creating host set" "ERR:"
		Get-help New-HostSet
		return	
	}
	if($hostName)
	{
		$cmdCrtHostSet +=" $hostName "
	}
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmdCrtHostSet
	if($Add)
	{
		if([string]::IsNullOrEmpty($Result))
		{
			write-host""
			return "Success : New-HostSet command executed Host Name : $hostName is added to Host Set : $HostSetName"
		}
		else
		{
			write-host""
			return $Result
		}
	}	
	else
	{
		if([string]::IsNullOrEmpty($Result))
		{
			write-host""
			return "Success : New-HostSet command executed Host Set : $HostSetName is created with Host : $hostName"
		}
		else
		{
			write-host""
			return $Result
		}			
	}	
		 
} # End New-HostSet

############################################################################################################################################
## FUNCTION Remove-Host
############################################################################################################################################
Function Remove-Host
{
<#
  .SYNOPSIS
    Removes a host.
  
  .DESCRIPTION
	Removes a host.
 
  .EXAMPLE
    Remove-Host -hostName HV01A 
	Remove the host named HV01A
	
  .EXAMPLE
    Remove-Host -hostName HV01A -address 10000000C97B142E
	Remove the WWN address of the host named HV01A
	
  .EXAMPLE	
	Remove-Host -hostName HV01B -iSCSI -Address  iqn.1991-06.com.microsoft:dt-391-xp.hq.3par.com
	Remove the iSCSI address of the host named HV01B
	
  .PARAMETER hostName
    Specify name of the host.

  .PARAMETER Address
    Specify the list of addresses to be removed.
	
  .PARAMETER Rvl
    Remove WWN(s) or iSCSI name(s) even if there are VLUNs exported to the host.

  .PARAMETER iSCSI
    Specify twhether the address is WWN or iSCSI
	
  .PARAMETER Pat
	Specifies that host name will be treated as a glob-style pattern and that all hosts matching the specified pattern are removed. T

  .PARAMETER  Port 
	Specifies the NSP(s) for the zones, from which the specified WWN will be removed in the target driven zoning. 
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Remove-Host  
    LASTEDIT: 19/11/2019
    KEYWORDS: Remove-Host
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$hostName,
		
		[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
		[switch] $Rvl,
				
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
		[switch] $ISCSI = $false,
		
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
		[switch] $Pat = $false,
		
		[Parameter(Position=4, Mandatory=$false)]
		[System.String]
		$Port,
		
		[Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
		[System.String[]]
		$Address,
		
		[Parameter(Position=6, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Remove-Host - validating input values" $Debug 
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
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Remove-Host since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Remove-Host since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}      
	if ($hostName)
	{
		$objType = "host"
		$objMsg  = "hosts"
		
		## Check Host Name 
		if ( -not ( Test-CLIObject -objectType $objType -objectName $hostName -objectMsg $objMsg -SANConnection $SANConnection)) 
		{
			write-debuglog " Host $hostName does not exist. Nothing to remove"  "INFO:"  
			return "FAILURE : No host $hostName found"
		}
		else
		{
		    $RemoveCmd = "removehost "			
			if ($address)
			{			
				if($Rvl)
				{
					$RemoveCmd += " -rvl "
				}	
				if($ISCSI)
				{
					$RemoveCmd += " -iscsi "
				}
				if($Pat)
				{
					$RemoveCmd += " -pat "
				}
				if($Port)
				{
					$RemoveCmd += " -port $Port "
				}
			}			
			$Addr = [string]$address 
			$RemoveCmd += " $hostName $Addr"
			$Result1 = Get-HostSet -hostName $hostName -SANConnection $SANConnection
			
			if(($Result1 -match "No host set listed"))
			{
				$Result2 = Invoke-CLICommand -Connection $SANConnection -cmds  $RemoveCmd
				write-debuglog "Removing host  with the command --> $RemoveCmd" "INFO:" 
				if([string]::IsNullOrEmpty($Result2))
				{
					return "Success : Removed host $hostName"
				}
				else
				{
					return "FAILURE : While removing host $hostName"
				}				
			}
			else
			{
				$Result3 = Invoke-CLICommand -Connection $SANConnection -cmds  $RemoveCmd
				return "FAILURE : Host $hostName is still a member of set"
			}			
		}				
	}
	else
	{
		write-debuglog  "No host name mentioned to remove" "INFO:"
		Get-help Remove-Host			
	}
} # End of Remove-Host

#####################################################################################################################
## FUNCTION Remove-HostSet
#####################################################################################################################

Function Remove-HostSet
{
<#
  .SYNOPSIS
    Remove a host set or remove hosts from an existing set
  
  .DESCRIPTION
	Remove a host set or remove hosts from an existing set
        
  .EXAMPLE
    Remove-HostSet -hostsetName "MyHostSet"  -force 
	Remove a hostset  "MyHostSet"
	
  .EXAMPLE
	Remove-HostSet -hostsetName "MyHostSet" -hostName "MyHost" -force
	Remove a single host "MyHost" from a hostset "MyHostSet"
	
  .PARAMETER hostsetName 
    Specify name of the hostsetName

  .PARAMETER hostName 
    Specify name of  a host to remove from hostset
 
  .PARAMETER force
	If present, perform forcible delete operation
	
  .PARAMETER Pat
	Specifies that both the set name and hosts will be treated as glob-style patterns.
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
              
  .Notes
    NAME:  Remove-HostSet 
    LASTEDIT: 19/11/2019
    KEYWORDS: Remove-HostSet
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[System.String]
		$hostsetName,
		
		[Parameter(Position=1, Mandatory=$false)]
		[System.String]
		$hostName,
		
		[Parameter(Position=2, Mandatory=$false)]
		[switch]
		$force,
		
		[Parameter(Position=3, Mandatory=$false)]
		[switch]
		$Pat,
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		

	Write-DebugLog "Start: In Remove-HostSet - validating input values" $Debug 
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
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Remove-HostSet since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Remove-HostSet since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli -SANConnection $SANConnection
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	
	$RemovehostsetCmd = "removehostset "
	if ($hostsetName)
	{
		if (!($force))
		{
			write-debuglog "no force option selected to remove hostset, Exiting...." "INFO:"
			return "FAILURE : no -force option selected to remove hostset"
		}
		$objType = "hostset"
		$objMsg  = "host set"
		
		## Check hostset Name 
		##
		if ( -not ( Test-CLIObject -objectType $objType -objectName $hostsetName -objectMsg $objMsg -SANConnection $SANConnection)) 
		{
			write-debuglog " hostset $hostsetName does not exist. Nothing to remove"  "INFO:"  
			return "FAILURE : No hostset $hostsetName found"
		}
		else
		{	
			if($force)
			{
				$RemovehostsetCmd += " -f "
			}
			if($Pat)
			{
				$RemovehostsetCmd += " -pat "
			}
			
			$RemovehostsetCmd += " $hostsetName "
			
			if($hostName)
			{
				$RemovehostsetCmd +=" $hostName"
			}
		
			$Result2 = Invoke-CLICommand -Connection $SANConnection -cmds  $RemovehostsetCmd
			
			write-debuglog "Removing hostset  with the command --> $RemovehostsetCmd" "INFO:"
			if([string]::IsNullOrEmpty($Result2))
			{
				if($hostName)
				{
					return "Success : Removed host $hostName from hostset $hostsetName "
				}
				else
				{
					return "Success : Removed hostset $hostsetName "
				}
			}
			else
			{
				return "FAILURE : While removing hostset $hostsetName"
			}			
		}
	}
	else
	{
			write-debuglog  "No hostset name mentioned to remove" "INFO:"
			Get-help Remove-HostSet
	}
} # End of Remove-HostSet 

##########################################################################
######################### FUNCTION Update-HostSet ####################
##########################################################################
Function Update-HostSet()
{
<#
  .SYNOPSIS
   Update-HostSet - set parameters for a host set

  .DESCRIPTION
   The Update-HostSet command sets the parameters and modifies the properties of a host set.

  .EXAMPLE

  .PARAMETER Setname
	Specifies the name of the host set to modify.
  
  .PARAMETER Comment
   Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.

  .PARAMETER NewName
   Specifies a new name for the host set, using up to 27 characters in length.

  .Notes
    NAME: Update-HostSet
    LASTEDIT 19/11/2019
    KEYWORDS: Update-HostSet
  
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
	$Setname,

	[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Update-HostSet - validating input values" $Debug 
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
			Write-DebugLog "Stop: Exiting Update-HostSet since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Update-HostSet since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

	$Cmd = " sethostset "
	
 if($Comment)
 {
	$Cmd += " -comment $Comment "
 }

 if($NewName)
 {
	$Cmd += " -name $NewName "
 } 

 if($Setname)
 {
	$Cmd += " $Setname "
 } 
 else
 {
	return "Setname is mandatory Please enter..."
 } 
 
 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing Function : Update-HostSet Command -->" INFO: 
 
 if ([string]::IsNullOrEmpty($Result))
 {
    Get-HostSet -hostSetName $NewName
 }
 else
 { 
	Return $Result
 }
} ##  End-of Update-HostSet


Export-ModuleMember Get-Host , Get-HostSet , New-Host , New-HostSet , Remove-Host , Remove-HostSet , Update-HostSet
# SIG # Begin signature block
# MIIhEQYJKoZIhvcNAQcCoIIhAjCCIP4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCFuc6/3ipRw4wN
# k5gFfAtzmMp8ealYUS3Lg7DlMEKtt6CCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIPvDCCD7gCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# 2c1eZmUdk6990oh7jKAyluauUXdxW+/peWO/f0NUo1wwDQYJKoZIhvcNAQEBBQAE
# ggEA2XMftm+4Wrdd4NeqFEBU+vdwBeKKNSVyJDOHR2wA+1bWUlan0e3+mba51+Ua
# owR95mkqwKlelWNjEsQuxMd1+KuPXmwvRiJZx67/BHubxMPGmHiVuRlq12F+7rau
# iIasbL80+1Z33Po+seHK5l8wi/ru9WhZ1ALRoLaa752RsfMAbZT+BTk1UsaJxbBr
# TDr+uegbyVju+7XMHP+1lYea1KJqFB7Ng88yCMOGJeowVMckSMvnUKzo8jFUGT9y
# cFR6DvAxWM8TRqw0BwhxQtBdd8iBuvJHxpSRXcbIHmhstY2cAb516d9mjgEISHOi
# Kp37GHzHwzOABboKhTGaSnHdGaGCDX4wgg16BgorBgEEAYI3AwMBMYINajCCDWYG
# CSqGSIb3DQEHAqCCDVcwgg1TAgEDMQ8wDQYJYIZIAWUDBAIBBQAweAYLKoZIhvcN
# AQkQAQSgaQRnMGUCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQCAQUABCACDnsu
# H0d8Oe9BUQR+qOPYCQNL91Ezlx1MAskQPL2FQAIRAOSAbJ+3877c2IUiN/eP0CQY
# DzIwMjEwNjE5MDQxMTI1WqCCCjcwggT+MIID5qADAgECAhANQkrgvjqI/2BAIc4U
# APDdMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERp
# Z2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwHhcNMjEwMTAx
# MDAwMDAwWhcNMzEwMTA2MDAwMDAwWjBIMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIx
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwuZhhGfFivUNCKRFymNr
# Udc6EUK9CnV1TZS0DFC1JhD+HchvkWsMlucaXEjvROW/m2HNFZFiWrj/ZwucY/02
# aoH6KfjdK3CF3gIY83htvH35x20JPb5qdofpir34hF0edsnkxnZ2OlPR0dNaNo/G
# o+EvGzq3YdZz7E5tM4p8XUUtS7FQ5kE6N1aG3JMjjfdQJehk5t3Tjy9XtYcg6w6O
# LNUj2vRNeEbjA4MxKUpcDDGKSoyIxfcwWvkUrxVfbENJCf0mI1P2jWPoGqtbsR0w
# wptpgrTb/FZUvB+hh6u+elsKIC9LCcmVp42y+tZji06lchzun3oBc/gZ1v4NSYS9
# AQIDAQABo4IBuDCCAbQwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwQQYDVR0gBDowODA2BglghkgBhv1sBwEwKTAn
# BggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMB8GA1UdIwQY
# MBaAFPS24SAd/imu0uRhpbKiJbLIFzVuMB0GA1UdDgQWBBQ2RIaOpLqwZr68KC0d
# RDbd42p6vDBxBgNVHR8EajBoMDKgMKAuhixodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vc2hhMi1hc3N1cmVkLXRzLmNybDAyoDCgLoYsaHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmwwgYUGCCsGAQUFBwEBBHkwdzAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME8GCCsGAQUFBzAChkNo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNzdXJlZElE
# VGltZXN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IBAQBIHNy16ZojvOca
# 5yAOjmdG/UJyUXQKI0ejq5LSJcRwWb4UoOUngaVNFBUZB3nw0QTDhtk7vf5EAmZN
# 7WmkD/a4cM9i6PVRSnh5Nnont/PnUp+Tp+1DnnvntN1BIon7h6JGA0789P63ZHdj
# XyNSaYOC+hpT7ZDMjaEXcw3082U5cEvznNZ6e9oMvD0y0BvL9WH8dQgAdryBDvjA
# 4VzPxBFy5xtkSdgimnUVQvUtMjiB2vRgorq0Uvtc4GEkJU+y38kpqHNDUdq9Y9Yf
# W5v3LhtPEx33Sg1xfpe39D+E68Hjo0mh+s6nv1bPull2YYlffqe0jmd4+TaY4cso
# 2luHpoovMIIFMTCCBBmgAwIBAgIQCqEl1tYyG35B5AXaNpfCFTANBgkqhkiG9w0B
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTYwMTA3MTIwMDAwWhcNMzEwMTA3MTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# VGltZXN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# vdAy7kvNj3/dqbqCmcU5VChXtiNKxA4HRTNREH3Q+X1NaH7ntqD0jbOI5Je/YyGQ
# mL8TvFfTw+F+CNZqFAA49y4eO+7MpvYyWf5fZT/gm+vjRkcGGlV+Cyd+wKL1oODe
# Ij8O/36V+/OjuiI+GKwR5PCZA207hXwJ0+5dyJoLVOOoCXFr4M8iEA91z3FyTgqt
# 30A6XLdR4aF5FMZNJCMwXbzsPGBqrC8HzP3w6kfZiFBe/WZuVmEnKYmEUeaC50ZQ
# /ZQqLKfkdT66mA+Ef58xFNat1fJky3seBdCEGXIX8RcG7z3N1k3vBkL9olMqT4Ud
# xB08r8/arBD13ays6Vb/kwIDAQABo4IBzjCCAcowHQYDVR0OBBYEFPS24SAd/imu
# 0uRhpbKiJbLIFzVuMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMBIG
# A1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqg
# OKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMFAGA1UdIARJMEcwOAYKYIZIAYb9bAACBDAq
# MCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAsGCWCG
# SAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAQEAcZUS6VGHVmnN793afKpjerN4zwY3
# QITvS4S/ys8DAv3Fp8MOIEIsr3fzKx8MIVoqtwU0HWqumfgnoma/Capg33akOpMP
# +LLR2HwZYuhegiUexLoceywh4tZbLBQ1QwRostt1AuByx5jWPGTlH0gQGF+JOGFN
# YkYkh2OMkVIsrymJ5Xgf1gsUpYDXEkdws3XVk4WTfraSZ/tTYYmo9WuWwPRYaQ18
# yAGxuSh1t5ljhSKMYcp5lH5Z/IwP42+1ASa2bKXuh1Eh5Fhgm7oMLSttosR+u8Ql
# K0cCCHxJrhO24XxCQijGGFbPQTS2Zl22dHv1VjMiLyI2skuiSpXY9aaOUjGCAoYw
# ggKCAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0ECEA1CSuC+Ooj/YEAhzhQA8N0w
# DQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwG
# CSqGSIb3DQEJBTEPFw0yMTA2MTkwNDExMjVaMCsGCyqGSIb3DQEJEAIMMRwwGjAY
# MBYEFOHXgqjhkb7va8oWkbWqtJSmJJvzMC8GCSqGSIb3DQEJBDEiBCBi/J/PU+CU
# x+twv3FrpCcPe/t7zMmV0ab5YpbYgVT1DTA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCCzEJAGvArZgweRVyngRANBXIPjKSthTyaWTI01cez1qTANBgkqhkiG9w0BAQEF
# AASCAQAcSmbMDJyiV8wUPyN57Rmp9B5PV48ugirhcHkmuMEXBQkDnqzVj3eLYFvL
# FfeYEtAXh0Gg97/brLU/y135h+xr7QYjvjRnG+zKcX+ICXj5vfZPiQrNmtsDJfbD
# 0jQmvOaX8YhVmoerXdqFvrGMAlOMEwPNMl9rBOom0JC1ZOAjM1OIV2cNZqrCdfB7
# /Gj9gy+zVxih3Lhd+4kCVCVAr4UIugzyBYunoZnw6mvBoLYK+1uEhC4QhtpZok1L
# fzZuVJsjHgHkkc6N0peUF+w0+UNZCJ0KtJocTniaiAoLN8pfLrlLPCo6rpPrrAzV
# oH2g3NszMk9j9H8KmnmU7P8qClLk
# SIG # End signature block
