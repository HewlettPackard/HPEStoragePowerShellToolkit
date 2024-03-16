####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
	
Function Show-A9vVolvm_CLI
{
<#
.SYNOPSIS
    The Show-vVolvm command displays information about all virtual machines (VVol-based) or a specific virtual machine in a system.  This command
    can be used to determine the association between virtual machines and their associated virtual volumes. showvvolvm will also show the
    accumulation of space usage information for a virtual machine.
.DESCRIPTION
    The Show-vVolvm command displays information about all virtual machines (VVol-based) or a specific virtual machine in a system.  This command
    can be used to determine the association between virtual machines and their associated virtual volumes. showvvolvm will also show the
    accumulation of space usage information for a virtual machine.
.EXAMPLE
	PS:> Show-A9vVolvm_CLI -container_name XYZ -option listcols 
.EXAMPLE
	PS:> Show-A9vVolvm_CLI -container_name XYZ -Detailed 
.EXAMPLE
	PS:> Show-A9vVolvm_CLI -container_name XYZ -StorageProfiles
.EXAMPLE
	PS:> Show-A9vVolvm_CLI -container_name XYZ -Summary 
.EXAMPLE
	PS:> Show-A9vVolvm_CLI -container_name XYZ -Binding
.EXAMPLE
	PS:> Show-A9vVolvm_CLI -container_name XYZ -VVAssociatedWithVM	
.PARAMETER container_name
    The name of the virtual volume storage container. May be "sys:all" to display all VMs.
.PARAMETER Listcols
	List the columns available to be shown in the -showcols option below (see "clihelp -col showvvolvm" for help on each column).

	By default with mandatory option -sc, (if none of the information selection options below are specified) the following columns are shown:
	VM_Name GuestOS VM_State Num_vv Physical Logical
.PARAMETER Detailed
	Displays detailed information about the VMs. The following columns are shown: VM_Name UUID Num_vv Num_snap Physical Logical GuestOS VM_State UsrCPG SnpCPG Container CreationTime
.PARAMETER StorageProfiles
	Shows the storage profiles with constraints associated with the VM. Often, all VVols associated with a VM will use the same storage profile.
	However, if vSphere has provisioned different VMDK volumes with different storage profiles, only the storage profile for the first virtual disk
	(VMDK) VVol will be displayed. In this case, use the -vv option to display storage profiles for individual volumes associated with the VM. Without
	the -vv option, the following columns are shown: VM_Name SP_Name SP_Constraint_List
.PARAMETER Summary
	Shows the summary of virtual machines (VM) in the system, including the total number of the following: VMs, VVs, and total physical and
	exported space used. The following columns are shown: Num_vm Num_vv Physical Logical
.PARAMETER Binding
	Shows the detailed binding information for the VMs. The binding could be PoweredOn, Bound (exported), or Unbound. When it is bound,
	showvvolvm displays host names to which it is bound. When it is bound and -vv option is used, showvvolvm displays the exported LUN templates
	for each volume, and the state for actively bound VVols. PoweredOn means the VM is powered on. Bound means the VM is not powered on,
	but either being created, modified, queried or changing powered state from on to off or off to on. Unbound means the VM is powered off.
	The following columns are shown: VM_Name VM_State Last_Host Last_State_Time Last_Pwr_Time

	With the -vv option, the following columns are shown: VM_Name VVol_Name VVol_Type VVol_State VVol_LunId Bind_Host Last_State_Time
.PARAMETER VVAssociatedWithVM
	Shows all the VVs (Virtual Volumes) associated with the VM. The following columns are shown:
	VM_Name VV_ID VVol_Name VVol_Type Prov Physical Logical

	The columns displayed can change when used with other options.
	See the -binding option above.
.PARAMETER RemoteCopy
	Shows the remote copy group name, sync status, role, and last sync time of the volumes associated with a VM. Note that if a VM does not report as synced, the
	last sync time for the VM DOES NOT represent a consistency point. True consistency points are only represented by the showrcopy LastSyncTime. This
	option may be combined with the -vv, -binding, -d, and -sp options.
.PARAMETER AutoDismissed
	Shows only VMs containing automatically dismissed volumes. Shows only automatically dismissed volumes when combined with the -vv option.
.PARAMETER VM_name 
	Specifies the VMs with the specified name (up to 80 characters in length). This specifier can be repeated to display information about multiple VMs.
	This specifier is not required. If not specified, showvvolvm displays information for all VMs in the specified storage container.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$container_name,
		[Parameter()]	[switch]	$ListCols,
		[Parameter()]	[String]	$ShowCols,
		[Parameter()]	[switch]	$Detailed,
		[Parameter()]	[switch]	$StorageProfiles,
		[Parameter()]	[switch]	$Summary,
		[Parameter()]	[switch]	$Binding,
		[Parameter()]	[switch]	$VVAssociatedWithVM,
		[Parameter()]	[switch]	$RemoteCopy,
		[Parameter()]	[switch]	$AutoDismissed,
		[Parameter(ValueFromPipeline=$true)]	[String]	$VM_name
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{	$cmd = "showvvolvm "
	if($ListCols)
		{	$cmd +=" -listcols "
			$Result = Invoke-CLICommand -cmds  $cmd
			write-verbose " The Show-vVolvm command creates and admits physical disk definitions to enable the use of those disks  "  
			return 	$Result	
		}
	if ($ShowCols)			{	$cmd +=" -showcols $ShowCols "	}
	if ($Detailed)			{	$cmd +=" -d "		}
	if ($StorageProfiles)	{	$cmd +=" -sp "	}
	if ($Summary)			{	$cmd +=" -summary "	}
	if ($Binding)			{	$cmd +=" -binding "	}
	if ($VVAssociatedWithVM){	$cmd +=" -vv "	}
	if ($RemoteCopy)		{	$cmd +=" -rcopy "	}
	if ($AutoDismissed)		{	$cmd +=" -autodismissed "	}	
	if ($container_name)	{	$cmd+="  -sc $container_name "	}	
	else					{	return " FAILURE :  container_name is mandatory to execute Show-vVolvm command "	}	
	if ($VM_name)			{	$cmd+=" $VM_name "	}	
	$Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
}
}

Function Get-A9vVolSc_CLI
{
<#
.SYNOPSIS
    The command displays VVol storage containers, used to contain
    VMware Volumes for Virtual Machines (VVols).
.DESCRIPTION
    The command displays VVol storage containers, used to contain
    VMware Volumes for Virtual Machines (VVols).
.EXAMPLE
	PS:> Get-A9vVolSc_CLI 
.EXAMPLE
	PS:> Get-A9vVolSc_CLI -Detailed -SC_name test
.PARAMETER Listcols
	List the columns available to be shown in the -showcols option described below.
.PARAMETER Detailed
	Displays detailed information about the storage containers, including any
	VVols that have been auto-dismissed by remote copy DR operations.
.PARAMETER SC_name  
	Storage Container
#>
[CmdletBinding()]
param(	[Parameter()]	[switch]	$Detailed,	
		[Parameter()]	[switch]	$Listcols,
		[Parameter()]	[String]	$SC_name
	)	
Begin
{	Test-A9Connection -ClientType 'SshClient'
}
process	
{	$cmd= "showvvolsc "	
	if ($Listcols)		{	$cmd+=" -listcols "	}
	if ($Detailed)		{	$cmd+=" -d "		}
	if ($SC_name)		{	$cmd+=" $SC_name "	}	
	$Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
}
}

Function Set-A9VVolSC_CLI
{
<#
.SYNOPSIS
    Used to create and remove storage containers for VMware Virtual Volumes (VVols).

    VVols are managed by the vSphere environment, and storage containers are used to maintain a logical collection of them. No physical space is
    pre-allocated for a storage container. Special VV sets (see showvvset) are used to manage VVol storage containers.
.DESCRIPTION    
    Used to create and remove storage containers for VMware Virtual Volumes (VVols).

    VVols are managed by the vSphere environment, and storage containers are used to maintain a logical collection of them. No physical space is
    pre-allocated for a storage container. The special VV sets (see showvvset) are used to manage VVol storage containers.
.EXAMPLE
	PS:> Set-A9VVolSC_CLI -vvset XYZ (Note: set: already include in code please dont add with vvset)
.EXAMPLE
	PS:> Set-A9VVolSC_CLI -Create -vvset XYZ
.PARAMETER Create
	An empty existing <vvset> not already marked as a VVol Storage Container will be updated. The VV set should not contain any
	existing volumes (see -keep option below), must not be already marked as a storage container, nor may it be in use for other
	services, such as for remote copy groups, QoS, etc.
.PARAMETER Remove
	If the specified VV set is a VVol storage container, this option will remove the VV set storage container and remove all of the associated volumes. 
	The user will be asked to confirm that the associated volumes in this storage container should be removed.
.PARAMETER Keep
	Used only with the -create option. If specified, allows a VV set with existing volumes to be marked as a VVol storage container.  However,
	this option should only be used if the existing volumes in the VV set
	are VVols.
.PARAMETER vvset
	The Virtual Volume set (VV set) name, which is used, or to be used, as a VVol storage container.
#>
[CmdletBinding()]
param(	[Parameter()]	[String]	$vvset,
		[Parameter()]	[switch]	$Create,
		[Parameter()]	[switch]	$Remove,
		[Parameter()]	[switch]	$Keep
	)	
Begin
{	Test-A9Connection -ClientType "SshClient"
}
process
{	$cmd= " setvvolsc -f"			
	if ($Create){	$cmd += " -create "	}
	if ($Remove){	$cmd += " -remove "	}
	if($Keep)	{	$cmd += " -keep "	}
	if ($vvset)	{	$cmd +="  set:$vvset "	}	
	else		{	return " FAILURE :  vvset is mandatory to execute Set-VVolSC command"	}
	$Result = Invoke-CLICommand -cmds  $cmd
	return 	$Result	
}
}
