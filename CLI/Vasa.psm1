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
##	File Name:		Vasa.psm1
##	Description: 	VASA cmdlets 
##		
##	Created:		January 2020
##	Last Modified:	January 2020
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

####################################################################################################################
## FUNCTION Show-vVolvm
####################################################################################################################
Function Show-vVolvm
{
<#
  .SYNOPSIS
    The Show-vVolvm command displays information about all virtual machines
    (VVol-based) or a specific virtual machine in a system.  This command
    can be used to determine the association between virtual machines and
    their associated virtual volumes. showvvolvm will also show the
    accumulation of space usage information for a virtual machine.

  .DESCRIPTION
    The Show-vVolvm command displays information about all virtual machines
    (VVol-based) or a specific virtual machine in a system.  This command
    can be used to determine the association between virtual machines and
    their associated virtual volumes. showvvolvm will also show the
    accumulation of space usage information for a virtual machine.

  .EXAMPLE
	Show-vVolvm -container_name XYZ -option listcols 
	
  .EXAMPLE
	Show-vVolvm -container_name XYZ -Detailed 
	
  .EXAMPLE
	Show-vVolvm -container_name XYZ -StorageProfiles
	
  .EXAMPLE
	Show-vVolvm -container_name XYZ -Summary 
	
  .EXAMPLE
	Show-vVolvm -container_name XYZ -Binding
	
  .EXAMPLE
	Show-vVolvm -container_name XYZ -VVAssociatedWithVM	
	
  .PARAMETER container_name
    The name of the virtual volume storage container. May be "sys:all" to display all VMs.
 
  .PARAMETER Listcols
	List the columns available to be shown in the -showcols option
	below (see "clihelp -col showvvolvm" for help on each column).

	By default with mandatory option -sc, (if none of the information selection options
	below are specified) the following columns are shown:
	VM_Name GuestOS VM_State Num_vv Physical Logical
    
  .PARAMETER Detailed
	Displays detailed information about the VMs. The following columns are shown:
	VM_Name UUID Num_vv Num_snap Physical Logical GuestOS VM_State UsrCPG SnpCPG Container CreationTime

  .PARAMETER StorageProfiles
	Shows the storage profiles with constraints associated with the VM.
	Often, all VVols associated with a VM will use the same storage profile.
	However, if vSphere has provisioned different VMDK volumes with different
	storage profiles, only the storage profile for the first virtual disk
	(VMDK) VVol will be displayed. In this case, use the -vv option to display
	storage profiles for individual volumes associated with the VM. Without
	the -vv option, the following columns are shown:
	VM_Name SP_Name SP_Constraint_List

  .PARAMETER Summary
	Shows the summary of virtual machines (VM) in the system, including
	the total number of the following: VMs, VVs, and total physical and
	exported space used. The following columns are shown:
	Num_vm Num_vv Physical Logical

  .PARAMETER Binding
	Shows the detailed binding information for the VMs. The binding could
	be PoweredOn, Bound (exported), or Unbound. When it is bound,
	showvvolvm displays host names to which it is bound. When it is bound
	and -vv option is used, showvvolvm displays the exported LUN templates
	for each volume, and the state for actively bound VVols. PoweredOn
	means the VM is powered on. Bound means the VM is not powered on,
	but either being created, modified, queried or changing powered state
	from on to off or off to on. Unbound means the VM is powered off.
	The following columns are shown:
	VM_Name VM_State Last_Host Last_State_Time Last_Pwr_Time

	With the -vv option, the following columns are shown:
	VM_Name VVol_Name VVol_Type VVol_State VVol_LunId Bind_Host Last_State_Time

  .PARAMETER VVAssociatedWithVM
	Shows all the VVs (Virtual Volumes) associated with the VM.
	The following columns are shown:
	VM_Name VV_ID VVol_Name VVol_Type Prov Physical Logical

	The columns displayed can change when used with other options.
	See the -binding option above.

  .PARAMETER RemoteCopy
	Shows the remote copy group name, sync status, role, and last sync time of the
	volumes associated with a VM. Note that if a VM does not report as synced, the
	last sync time for the VM DOES NOT represent a consistency point. True
	consistency points are only represented by the showrcopy LastSyncTime. This
	option may be combined with the -vv, -binding, -d, and -sp options.

  .PARAMETER AutoDismissed
	Shows only VMs containing automatically dismissed volumes. Shows only
	automatically dismissed volumes when combined with the -vv option.
		
  .PARAMETER VM_name 
	Specifies the VMs with the specified name (up to 80 characters in length).
	This specifier can be repeated to display information about multiple VMs.
	This specifier is not required. If not specified, showvvolvm displays
	information for all VMs in the specified storage container.
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Show-vVolvm
    LASTEDIT: January 2020
    KEYWORDS: Show-vVolvm
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
	
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$container_name,

		[Parameter(Position=1, Mandatory=$false)]
		[switch]
		$ListCols,

		[Parameter(Position=2, Mandatory=$false)]
		[System.String]
		$ShowCols,
		
		[Parameter(Position=3, Mandatory=$false)]
		[switch]
		$Detailed,
		
		[Parameter(Position=4, Mandatory=$false)]
		[switch]
		$StorageProfiles,
		
		[Parameter(Position=5, Mandatory=$false)]
		[switch]
		$Summary,
		
		[Parameter(Position=6, Mandatory=$false)]
		[switch]
		$Binding,
		
		[Parameter(Position=7, Mandatory=$false)]
		[switch]
		$VVAssociatedWithVM,
		
		[Parameter(Position=8, Mandatory=$false)]
		[switch]
		$RemoteCopy,
		
		[Parameter(Position=9, Mandatory=$false)]
		[switch]
		$AutoDismissed,
		
		[Parameter(Position=10, Mandatory=$false,ValueFromPipeline=$true)]
		[System.String]
		$VM_name,
				
		[Parameter(Position=11, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection       
	)	
	
	Write-DebugLog "Start: In Show-vVolvm   - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Show-vVolvm since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Show-vVolvm since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}

	$cmd = "showvvolvm "
	
	if($ListCols)
	{
		$cmd +=" -listcols "
		$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
		write-debuglog " The Show-vVolvm command creates and admits physical disk definitions to enable the use of those disks  " "INFO:" 
		return 	$Result	
	}
	if ($ShowCols)
	{		
		$cmd +=" -showcols $ShowCols "	
	}
	if ($Detailed)
	{		
		$cmd +=" -d "	
	}
	if ($StorageProfiles)
	{		
		$cmd +=" -sp "	
	}
	if ($Summary)
	{		
		$cmd +=" -summary "	
	}
	if ($Binding)
	{		
		$cmd +=" -binding "	
	}
	if ($VVAssociatedWithVM)
	{		
		$cmd +=" -vv "	
	}
	if ($RemoteCopy)
	{		
		$cmd +=" -rcopy "	
	}
	if ($AutoDismissed)
	{		
		$cmd +=" -autodismissed "	
	}	
	if ($container_name)
	{		
		$cmd+="  -sc $container_name "	
	}	
	else
	{
		return " FAILURE :  container_name is mandatory to execute Show-vVolvm command "
	}	
	if ($VM_name)
	{		
		$cmd+=" $VM_name "	
	}	
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog " The Show-vVolvm command creates and admits physical disk definitions to enable the use of those disks " "INFO:" 
	return 	$Result	
} # End Show-vVolvm

####################################################################################################################
## FUNCTION Get-vVolSc
####################################################################################################################
Function Get-vVolSc
{
<#
  .SYNOPSIS
     The Get-vVolSc command displays VVol storage containers, used to contain
    VMware Volumes for Virtual Machines (VVols).

  .DESCRIPTION
     The Get-vVolSc command displays VVol storage containers, used to contain
    VMware Volumes for Virtual Machines (VVols).

  .EXAMPLE
	Get-vVolSc 
	
  .EXAMPLE
	Get-vVolSc -Detailed -SC_name test

  .PARAMETER Listcols
	List the columns available to be shown in the -showcols option described
	below.

  .PARAMETER Detailed
	Displays detailed information about the storage containers, including any
	VVols that have been auto-dismissed by remote copy DR operations.

		
  .PARAMETER SC_name  
	Storage Container
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Get-vVolSc
    LASTEDIT: January 2020
    KEYWORDS: Get-vVolSc
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(			

		[Parameter(Position=0, Mandatory=$false)]
		[switch]
		$Detailed,
		
		[Parameter(Position=1, Mandatory=$false)]
		[switch]
		$Listcols,
		
		[Parameter(Position=2, Mandatory=$false)]
		[System.String]
		$SC_name,
				
		[Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection       
	)	
	
	Write-DebugLog "Start: In Get-vVolSc   - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Get-vVolSc since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Get-vVolSc since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}		
	$cmd= "showvvolsc "	
		
	if ($Listcols)
	{	
		$cmd+=" -listcols "	
	}
	if ($Detailed)
	{	
		$cmd+=" -d "	
	}
	if ($SC_name)
	{		
		$cmd+=" $SC_name "	
	}	
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog " The Get-vVolSc command creates and admits physical disk definitions to enable the use of those disks  " "INFO:" 
	return 	$Result	
} # End Get-vVolSc

####################################################################################################################
## FUNCTION Set-VVolSC
####################################################################################################################
Function Set-VVolSC
{
<#
  .SYNOPSIS
    Set-VVolSC can be used to create and remove storage containers for VMware Virtual Volumes (VVols).

    VVols are managed by the vSphere environment, and storage containers are
    used to maintain a logical collection of them. No physical space is
    pre-allocated for a storage container. Special VV sets (see showvvset) are 
	used to manage VVol storage containers.

  .DESCRIPTION    
    Set-VVolSC can be used to create and remove storage containers for
    VMware Virtual Volumes (VVols).

    VVols are managed by the vSphere environment, and storage containers are
    used to maintain a logical collection of them. No physical space is
    pre-allocated for a storage container. The special VV sets (see showvvset) 
	are used to manage VVol storage containers.

  .EXAMPLE
	Set-VVolSC -vvset XYZ (Note: set: already include in code please dont add with vvset)
	
  .EXAMPLE
	Set-VVolSC -Create -vvset XYZ

  .PARAMETER Create
	An empty existing <vvset> not already marked as a VVol Storage
	Container will be updated. The VV set should not contain any
	existing volumes (see -keep option below), must not be already
	marked as a storage container, nor may it be in use for other
	services, such as for remote copy groups, QoS, etc.

  .PARAMETER Remove
	If the specified VV set is a VVol storage container, this option will remove the VV set storage container and remove all of the associated volumes. The user will be asked to confirm that the associated volumes
	in this storage container should be removed.

  .PARAMETER Keep
	Used only with the -create option. If specified, allows a VV set with existing volumes to be marked as a VVol storage container.  However,
	this option should only be used if the existing volumes in the VV set
	are VVols.
	
  .PARAMETER vvset
	The Virtual Volume set (VV set) name, which is used, or to be used, as a VVol storage container.

  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Set-VVolSC
    LASTEDIT: 03/08/2017
    KEYWORDS: Set-VVolSC
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(			
		
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$vvset,
		
		[Parameter(Position=1, Mandatory=$false)]
		[switch]
		$Create,
		
		[Parameter(Position=2, Mandatory=$false)]
		[switch]
		$Remove,
		
		[Parameter(Position=3, Mandatory=$false)]
		[switch]
		$Keep,
		
		[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection       
	)	
	
	Write-DebugLog "Start: In Set-VVolSC   - validating input values" $Debug 
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
				Write-DebugLog "Stop: Exiting Set-VVolSC since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Set-VVolSC since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}		
	$cmd= " setvvolsc -f"
			
	if ($Create)
	{
		$cmd += " -create "
	}
	if ($Remove)
	{
		$cmd += " -remove "
	}
	if($Keep)
	{
		$cmd += " -keep "
	}
	if ($vvset)
	{		
		$cmd +="  set:$vvset "	
	}	
	else
	{
		return " FAILURE :  vvset is mandatory to execute Set-VVolSC command"
	}
	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	write-debuglog " The Set-VVolSC command creates and admits physical disk definitions to enable the use of those disks" "INFO:" 
	return 	$Result	
	
} # End Set-VVolSC

Export-ModuleMember Show-vVolvm , Get-vVolSc , Set-VVolSC
# SIG # Begin signature block
# MIIh0AYJKoZIhvcNAQcCoIIhwTCCIb0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBLBos4uawo0yxh
# hGs8+TQk6DPm+0wU2COeMt2fpST8FaCCEKswggUpMIIEEaADAgECAhB4Lu4fcD9z
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
# V3AcPKRYLqPzW0sH3DJZ84enGm1YMYIQezCCEHcCAQEwgZAwfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0ECEHgu7h9wP3PFSAP6N/U6iqUwDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# xSMwPvaxQHreGG5Kj2UClKb4H1yQLkf425HjzltCzkcwDQYJKoZIhvcNAQEBBQAE
# ggEAAjDPIlZ166Upw5RDN8ZSyoeJLVa9SJKjY6NtkT2DsyWScSxDi9PD6yjot/20
# BcaEC99oVtTTYh9sd5wxsfNHju+9wKGZ6IWGZZoPxORDAGKIqHpc+TxrQjHVpyiV
# Cnb6DFs2/4DVGovGtzK8ERad7jk8gRH7jixgixYUm7ltX8mG6yFsyj0ytFCx0wtA
# UvJ1ZfiAqGmv5mEAttfsnuKy/sKSS7TTrhnzlebtCeCKS00z6R4BWl1sS/tYmI2O
# zrU7ZFh47VHPwQ7l7oVxGBHw64iN/DCsz379yUDUs/z+rRlI2SNRkny3G5e6yS66
# F8NtIjk6tYiaDKwBtbPMzmh0j6GCDj0wgg45BgorBgEEAYI3AwMBMYIOKTCCDiUG
# CSqGSIb3DQEHAqCCDhYwgg4SAgEDMQ0wCwYJYIZIAWUDBAIBMIIBDwYLKoZIhvcN
# AQkQAQSggf8EgfwwgfkCAQEGC2CGSAGG+EUBBxcDMDEwDQYJYIZIAWUDBAIBBQAE
# INzaVXd2elm2BRjYxn91lLBxd2erVeOUEMQwP3zdJ6acAhUA64Gr6nPVzEzL+iaT
# ltfmBzvtKwsYDzIwMjEwNjE5MDQzMjE1WjADAgEeoIGGpIGDMIGAMQswCQYDVQQG
# EwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5
# bWFudGVjIFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBU
# aW1lU3RhbXBpbmcgU2lnbmVyIC0gRzOgggqLMIIFODCCBCCgAwIBAgIQewWx1Elo
# UUT3yYnSnBmdEjANBgkqhkiG9w0BAQsFADCBvTELMAkGA1UEBhMCVVMxFzAVBgNV
# BAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3
# b3JrMTowOAYDVQQLEzEoYykgMjAwOCBWZXJpU2lnbiwgSW5jLiAtIEZvciBhdXRo
# b3JpemVkIHVzZSBvbmx5MTgwNgYDVQQDEy9WZXJpU2lnbiBVbml2ZXJzYWwgUm9v
# dCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xNjAxMTIwMDAwMDBaFw0zMTAx
# MTEyMzU5NTlaMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jw
# b3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEoMCYGA1UE
# AxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALtZnVlVT52Mcl0agaLrVfOwAa08cawyjwVrhpon
# ADKXak3JZBRLKbvC2Sm5Luxjs+HPPwtWkPhiG37rpgfi3n9ebUA41JEG50F8eRzL
# y60bv9iVkfPw7mz4rZY5Ln/BJ7h4OcWEpe3tr4eOzo3HberSmLU6Hx45ncP0mqj0
# hOHE0XxxxgYptD/kgw0mw3sIPk35CrczSf/KO9T1sptL4YiZGvXA6TMU1t/HgNuR
# 7v68kldyd/TNqMz+CfWTN76ViGrF3PSxS9TO6AmRX7WEeTWKeKwZMo8jwTJBG1kO
# qT6xzPnWK++32OTVHW0ROpL2k8mc40juu1MO1DaXhnjFoTcCAwEAAaOCAXcwggFz
# MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMGYGA1UdIARfMF0w
# WwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNvbS9ycGEwLgYI
# KwYBBQUHAQEEIjAgMB4GCCsGAQUFBzABhhJodHRwOi8vcy5zeW1jZC5jb20wNgYD
# VR0fBC8wLTAroCmgJ4YlaHR0cDovL3Muc3ltY2IuY29tL3VuaXZlcnNhbC1yb290
# LmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAoBgNVHREEITAfpB0wGzEZMBcGA1UE
# AxMQVGltZVN0YW1wLTIwNDgtMzAdBgNVHQ4EFgQUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwHwYDVR0jBBgwFoAUtnf6aUhHn1MS1cLqBzJ2B9GXBxkwDQYJKoZIhvcNAQEL
# BQADggEBAHXqsC3VNBlcMkX+DuHUT6Z4wW/X6t3cT/OhyIGI96ePFeZAKa3mXfSi
# 2VZkhHEwKt0eYRdmIFYGmBmNXXHy+Je8Cf0ckUfJ4uiNA/vMkC/WCmxOM+zWtJPI
# TJBjSDlAIcTd1m6JmDy1mJfoqQa3CcmPU1dBkC/hHk1O3MoQeGxCbvC2xfhhXFL1
# TvZrjfdKer7zzf0D19n2A6gP41P3CnXsxnUuqmaFBJm3+AZX4cYO9uiv2uybGB+q
# ueM6AL/OipTLAduexzi7D1Kr0eOUA2AKTaD+J20UMvw/l0Dhv5mJ2+Q5FL3a5NPD
# 6itas5VYVQR9x5rsIwONhSrS/66pYYEwggVLMIIEM6ADAgECAhB71OWvuswHP6EB
# IwQiQU0SMA0GCSqGSIb3DQEBCwUAMHcxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRT
# eW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0
# d29yazEoMCYGA1UEAxMfU3ltYW50ZWMgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAe
# Fw0xNzEyMjMwMDAwMDBaFw0yOTAzMjIyMzU5NTlaMIGAMQswCQYDVQQGEwJVUzEd
# MBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVj
# IFRydXN0IE5ldHdvcmsxMTAvBgNVBAMTKFN5bWFudGVjIFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgU2lnbmVyIC0gRzMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCvDoqq+Ny/aXtUF3FHCb2NPIH4dBV3Z5Cc/d5OAp5LdvblNj5l1SQgbTD53R2D
# 6T8nSjNObRaK5I1AjSKqvqcLG9IHtjy1GiQo+BtyUT3ICYgmCDr5+kMjdUdwDLNf
# W48IHXJIV2VNrwI8QPf03TI4kz/lLKbzWSPLgN4TTfkQyaoKGGxVYVfR8QIsxLWr
# 8mwj0p8NDxlsrYViaf1OhcGKUjGrW9jJdFLjV2wiv1V/b8oGqz9KtyJ2ZezsNvKW
# lYEmLP27mKoBONOvJUCbCVPwKVeFWF7qhUhBIYfl3rTTJrJ7QFNYeY5SMQZNlANF
# xM48A+y3API6IsW0b+XvsIqbAgMBAAGjggHHMIIBwzAMBgNVHRMBAf8EAjAAMGYG
# A1UdIARfMF0wWwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9k
# LnN5bWNiLmNvbS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNv
# bS9ycGEwQAYDVR0fBDkwNzA1oDOgMYYvaHR0cDovL3RzLWNybC53cy5zeW1hbnRl
# Yy5jb20vc2hhMjU2LXRzcy1jYS5jcmwwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# DgYDVR0PAQH/BAQDAgeAMHcGCCsGAQUFBwEBBGswaTAqBggrBgEFBQcwAYYeaHR0
# cDovL3RzLW9jc3Aud3Muc3ltYW50ZWMuY29tMDsGCCsGAQUFBzAChi9odHRwOi8v
# dHMtYWlhLndzLnN5bWFudGVjLmNvbS9zaGEyNTYtdHNzLWNhLmNlcjAoBgNVHREE
# ITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtNjAdBgNVHQ4EFgQUpRMB
# qZ+FzBtuFh5fOzGqeTYAex0wHwYDVR0jBBgwFoAUr2PWyqNOhXLgp7xB8ymiOH+A
# dWIwDQYJKoZIhvcNAQELBQADggEBAEaer/C4ol+imUjPqCdLIc2yuaZycGMv41Up
# ezlGTud+ZQZYi7xXipINCNgQujYk+gp7+zvTYr9KlBXmgtuKVG3/KP5nz3E/5jMJ
# 2aJZEPQeSv5lzN7Ua+NSKXUASiulzMub6KlN97QXWZJBw7c/hub2wH9EPEZcF1rj
# pDvVaSbVIX3hgGd+Yqy3Ti4VmuWcI69bEepxqUH5DXk4qaENz7Sx2j6aescixXTN
# 30cJhsT8kSWyG5bphQjo3ep0YG5gpVZ6DchEWNzm+UgUnuW/3gC9d7GYFHIUJN/H
# ESwfAD/DSxTGZxzMHgajkF9cVIs+4zNbgg/Ft4YCTnGf6WZFP3YxggJaMIICVgIB
# ATCBizB3MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRp
# b24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxKDAmBgNVBAMTH1N5
# bWFudGVjIFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEHvU5a+6zAc/oQEjBCJBTRIw
# CwYJYIZIAWUDBAIBoIGkMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkq
# hkiG9w0BCQUxDxcNMjEwNjE5MDQzMjE1WjAvBgkqhkiG9w0BCQQxIgQgHMxHM3ul
# TslLzbYJ7zGznUvoAjIwOxxSQ/WHeMftG+AwNwYLKoZIhvcNAQkQAi8xKDAmMCQw
# IgQgxHTOdgB9AjlODaXk3nwUxoD54oIBPP72U+9dtx/fYfgwCwYJKoZIhvcNAQEB
# BIIBAJPJhsm4D6vpdWDWiWJsNWs37XUTAjDbBb/WMYlkIOCbjcuYieFIlZYJFATV
# 1eaAZR+tBQ4s3NOW8XK9mjfPY+uGcquxdEaXsjqX79VxP7pmEglfE5oWwelsq43j
# 59/0C0EtWyUx3LB4/Y/Uhu0I5s0d5gX5xxei3zyZVDD3+KJ/K8MZR3gKWFcAVwIT
# 7KUEEI50YNddWdYIHPK406WwKUEElAV4hEAWW9k0ER/XePvmjIlJj9jVwMdVvTga
# mjFDphra9RruRGyKIRiKn+oTAhpZ+4is57yDF9h4/9+YYt6UOoUKWOCLzE/tMH0q
# GVdsOd7fzom9rRwrG8GJjGA03Yc=
# SIG # End signature block
