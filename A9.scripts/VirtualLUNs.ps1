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
{	Test-WSAPIConnection 
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

Function Remove-A9vLun
{
<#
.SYNOPSIS
	Removing a VLUN.
.DESCRIPTION
	Removing a VLUN. Any user with the Super or Edit role, or any role granted with the vlun_remove right, can perform this operation.    
.PARAMETER VolumeName
	Name of the volume or VV set to be exported.
	The VV set should be in set:<volumeset_name> format.
.PARAMETER LUNID
	Lun Id
.PARAMETER HostName
	Name of the host or host set to which the volume or VV set is to be exported. For VLUN of port type, the value is empty.
	The host set should be in set:<hostset_name> format.required if volume is exported to host or host set,or to both the host or host set and port
.PARAMETER NSP
	Specifies the system port of the VLUN export. It includes the system node number, PCI bus slot number, and card port number on the FC card in the format:<node>:<slot>:<port>
	required if volume is exported to port, or to both host and port .Notes NAME : Remove-vLun_WSAPI 
.EXAMPLE    
	Remove-vLun_WSAPI -VolumeName xxx -LUNID xx -HostName xxx
.EXAMPLE    
	Remove-vLun_WSAPI -VolumeName xxx -LUNID xx -HostName xxx -NSP x:x:x	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VolumeName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[int]		$LUNID,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$HostName,
		[Parameter(ValueFromPipeline=$true)]					[String]	$NSP
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{   Write-DebugLog "Running: Building uri to Remove-vLun_WSAPI  ." $Debug
	$uri = "/vluns/"+$VolumeName+","+$LUNID+","+$HostName
	if($NSP)
		{	$uri = $uri+","+$NSP
		}	
	$Result = $null
	Write-verbose "Request: Request to Remove-vLun_WSAPI : $CPGName (Invoke-WSAPI)." 
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			Write-verbose "SUCCESS: VLUN Successfully removed with Given Values [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP ]." $Info
			return $Result		
		}
	else
		{	write-error "While Removing VLUN with Given Values [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP ]. "
			return $Result.StatusDescription
		}    	
}
}

Function Get-A9vLun 
{
<#
.SYNOPSIS
	Get Single or list of VLun.
.DESCRIPTION
	Get Single or list of VLun
.PARAMETER VolumeName
	Name of the volume to filter the results.	
.PARAMETER LUNID
	The LUN ID of the volume to filter the results
.PARAMETER HostName
	Name of the host to which the volume is to be exported. 
.PARAMETER VolumeWWN
	The Volume WWN of the volume to filter the results
.PARAMETER RemoteName
	The RemoteName of the volume to filter the results
.PARAMETER Serial
	The Serial of the volume to filter the results
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device. The format of this should be a three numbers seperated by colons. i.e. '1:3:4'
.EXAMPLE
	PS:> Get-A9vLun | format-table
	
	Cmdlet executed successfully

	lun volumeName     hostname remoteName       portPos                       type volumeWWN                        multipathing failedPathPol failedPathInterval active Subsystem_NQN
	--- ----------     -------- ----------       -------                       ---- ---------                        ------------ ------------- ------------------ ------ -------------
	1 dpesxicluvol.1 dpesxi03 51402EC001C82750 @{node=0; slot=3; cardPort=3}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
	1 dpesxicluvol.1 dpesxi03 51402EC001C82752 @{node=0; slot=3; cardPort=4}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
	1 dpesxicluvol.1 dpesxi03 51402EC001C82750 @{node=0; slot=3; cardPort=1}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
	1 dpesxicluvol.1 dpesxi03 51402EC001C82750 @{node=1; slot=3; cardPort=1}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
	1 dpesxicluvol.1 dpesxi03 51402EC001C82750 @{node=1; slot=3; cardPort=3}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
	1 dpesxicluvol.1 dpesxi03 51402EC001C82752 @{node=0; slot=3; cardPort=2}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
	1 dpesxicluvol.1 dpesxi03 51402EC001C82752 @{node=1; slot=3; cardPort=2}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
	1 dpesxicluvol.1 dpesxi03 51402EC001C82752 @{node=1; slot=3; cardPort=4}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…
.EXAMPLE 
	PS:> Get-A9vLun -LUNID 1 -VolumeName dpesxicluvol.1 -nsp '1:3:4'-HostName dpesxi03 | format-table
	Cmdlet executed successfully

	lun volumeName     hostname remoteName       portPos                       type volumeWWN                        multipathing failedPathPol failedPathInterval active Subsystem_NQN
	--- ----------     -------- ----------       -------                       ---- ---------                        ------------ ------------- ------------------ ------ -------------
	1 dpesxicluvol.1 dpesxi03 51402EC001C82752 @{node=1; slot=3; cardPort=4}    5 60002AC000000000000034470007EB2E            1             1                  0   True nqn.2020-07.com.hpe:72391dbc…

#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$VolumeName,
		[Parameter(ValueFromPipeline=$true)]	[int]		$LUNID,
		[Parameter(ValueFromPipeline=$true)]	[String]	$HostName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$RemoteName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$VolumeWWN,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Serial,		
		[Parameter(ValueFromPipeline=$true)]	
		[ValidatePattern("[0-9]:[0-9]:[0-9]")]	[String]	$NSP
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	Write-Verbose "Request: Request to Get-vLun_WSAPI [ VolumeName : $VolumeName | LUNID : $LUNID | HostName : $HostName | NSP : $NSP] (Invoke-WSAPI)."
    $Result = $null
	$dataPS = $null		
	write-verbose "Making URL call to /vluns"
	$Result = Invoke-WSAPI -uri '/vluns' -type 'GET' 
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members			
		}		
	If($Result.StatusCode -eq 200)
		{	if ( $VolumeName )	{	$dataPS = $dataPS | where-object {$_.volumeName -like $VolumeName }		}
			if ( $LUNID )		{	$dataPS = $dataPS | where-object {$_.lun -like $LUNID }					}
			if ( $RemoteName )	{	$dataPS = $dataPS | where-object {$_.remoteName -like $RemoteName }		}
			if ( $VolumeWWN )	{	$dataPS = $dataPS | where-object {$_.volumeWWN -like $VolumeWWN }		}
			if ( $Serial )		{	$dataPS = $dataPS | where-object {$_.serial -like $Serial }				}
			if ( $HostName )	{	$dataPS = $dataPS | where-object {$_.hostname -like $HostName }			}
			if ( $NSP )			{	$dataPS = $dataPS | where-object {($_.portPos).node 	-like $NSP.split(':')[0] }
									$dataPS = $dataPS | where-object {($_.portPos).slot 	-like $NSP.split(':')[1] }
									$dataPS = $dataPS | where-object {($_.portPos).cardPort -like $NSP.split(':')[2] }
								}
			if($dataPS.Count -gt 0)
					{	write-host "Cmdlet executed successfully" -foreground green
						return $dataPS
					}
				else
					{	write-verbose "No data Found."
						return 
					}
		}
	else
		{	write-error "While Executing Get-A9vLun."
			return $Result.StatusDescription
		}
}
}

