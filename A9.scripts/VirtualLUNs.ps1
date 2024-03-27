####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##	Description: 	Virtual LUNs cmdlets 
##		

Function New-A9vLun 
{
<#
.SYNOPSIS
	Creating a VLUN
.DESCRIPTION
	Creating a VLUN. Any user with Super or Edit role, or any role granted vlun_create permission, can perform this operation.
.PARAMETER VolumeName
	Name of the volume or VV set to export.
.PARAMETER LUNID
	LUN ID.	
.PARAMETER HostName  
	Name of the host or host set to which the volume or VV set is to be exported.
	The host set should be in set:hostset_name format.
.PARAMETER NSP
	System port of VLUN exported to. It includes node number, slot number, and card port number.
.PARAMETER NoVcn
	Specifies that a VCN not be issued after export (-novcn). Default: false.
.EXAMPLE
	PS:> New-A9vLun -VolumeName xxx -LUNID x -HostName xxx

.EXAMPLE
	PS:> New-A9vLun -VolumeName xxx -LUNID x -HostName xxx -NSP 1:1:1
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[int]		$LUNID,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$HostName,
		[Parameter(ValueFromPipeline=$true)]					[String]	$NSP,
		[Parameter(ValueFromPipeline=$true)]					[Boolean]	$NoVcn = $false
	)
Begin 
{	Test-A9Connection -ClientType 'API' 
}
Process 
{	$body = @{}    
    $body["volumeName"] ="$($VolumeName)" 
	$body["lun"] =$LUNID
	$body["hostname"] ="$($HostName)" 
	If ($NSP) 
		{	$NSPbody = @{} 
			$list = $NSP.split(":")
			$NSPbody["node"] = [int]$list[0]		
			$NSPbody["slot"] = [int]$list[1]
			$NSPbody["cardPort"] = [int]$list[2]		
			$body["portPos"] = $NSPbody		
		}
	If ($NoVcn) 
		{	$body["noVcn"] = $NoVcn
		}
    $Result = $null
    $Result = Invoke-WSAPI -uri '/vluns' -type 'POST' -body $body 
	$status = $Result.StatusCode	
	if($status -eq 201)
		{	write-host "Cmdlet executed successfully" -foreground green
			return Get-A9vLun -VolumeName $VolumeName -LUNID $LUNID -HostName $HostName
		}
	else
		{	write-error "FAILURE : While Creating a VLUN" 
			return $Result.StatusDescription
		}	
}
}



