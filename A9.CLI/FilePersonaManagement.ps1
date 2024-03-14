####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Start-A9FSNDMP_CLI
{
<#
.SYNOPSIS   
	The Start-FSNDMP command is used to start both NDMP service and ISCSI service. 
.DESCRIPTION  
	The Start-FSNDMP command is used to start both NDMP service and ISCSI service.
.EXAMPLE	
	Start-FSNDMP
#>
[CmdletBinding()]
param()		
Begin	
{	Test-A9CLIConnection
}
Process
{	$cmd= "startfsndmp "	
	$Result = Invoke-CLICommand -cmds  $cmd
	Return $Result	
}
}

Function Stop-A9FSNDMP_CLI
{
<#
.SYNOPSIS   
	The Stop-FSNDMP command is used to stop both NDMP service and ISCSI service.
.DESCRIPTION  
	The Stop-FSNDMP command is used to stop both NDMP service and ISCSI service.
.EXAMPLE	
	Stop-FSNDMP	
#>
[CmdletBinding()]
param()		
Begin
{	Test-CLIConnection
}
Process	
{	$cmd= "stopfsndmp "
	$Result = Invoke-CLICommand -cmds  $cmd	
	write-verbose "  Executing  Stop-FSNDMP command that displays information iSNS table for iSCSI ports in the system  "	
	return $Result
	
}
}
