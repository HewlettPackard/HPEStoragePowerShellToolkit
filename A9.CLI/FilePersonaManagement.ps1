####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Start-A9FSNDMP
{
<#
.SYNOPSIS   
	Used to start both NDMP service and ISCSI service. 
.DESCRIPTION  
	The command is used to start both NDMP service and ISCSI service.
.EXAMPLE	
	PS:> Start-A9FSNDMP
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()		
Begin	
{	Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "startfsndmp "	
	$Result = Invoke-A9CLICommand -cmds  $cmd
	Return $Result	
}
}

Function Stop-A9FSNDMP
{
<#
.SYNOPSIS   
	Stop both NDMP service and ISCSI service.
.DESCRIPTION  
	The command is used to stop both NDMP service and ISCSI service.
.EXAMPLE	
	PS:> Stop-A9FSNDMP	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param()		
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
Process	
{	$cmd= "stopfsndmp "
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	write-verbose "  Executing  Stop-FSNDMP command that displays information iSNS table for iSCSI ports in the system  "	
	return $Result	
}
}
