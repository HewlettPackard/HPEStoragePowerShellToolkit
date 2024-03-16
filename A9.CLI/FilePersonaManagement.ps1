####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Start-A9FSNDMP_CLI
{
<#
.SYNOPSIS   
	Used to start both NDMP service and ISCSI service. 
.DESCRIPTION  
	The command is used to start both NDMP service and ISCSI service.
.EXAMPLE	
	Start-A9FSNDMP_CLI
#>
[CmdletBinding()]
param()		
Begin	
{	Test-A9Connection -ClientType 'SshClient' 
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
	Stop both NDMP service and ISCSI service.
.DESCRIPTION  
	The command is used to stop both NDMP service and ISCSI service.
.EXAMPLE	
	PS:> Stop-A9FSNDMP_CLI	
#>
[CmdletBinding()]
param()		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd= "stopfsndmp "
	$Result = Invoke-CLICommand -cmds  $cmd	
	write-verbose "  Executing  Stop-FSNDMP command that displays information iSNS table for iSCSI ports in the system  "	
	return $Result	
}
}
