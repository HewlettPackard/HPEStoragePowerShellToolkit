
####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##


Function Get-A9AdaptiveOptimizationConfig
{
<#
.SYNOPSIS
	Show Adaptive Optimization configurations.
.DESCRIPTION
	This command shows Adaptive Optimization configurations in the system.
.PARAMETER Domain
	Shows only AO configurations that are in domains with names matching one or more of the <domain_name_or_pattern> argument. This option
	does not allow listing objects within a domain of which the user is not a member. Patterns are glob-style (shell-style) patterns (see help on sub,globpat)
.PARAMETER AOConfigurationName
	Specifies that AO configurations matching either the specified AO configuration name or those AO configurations matching 
	the specified pattern are displayed. This specifier can be repeated to display information for multiple AO configurations. 
	If not specified, all AO configurations in the system are displayed.
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	PS:> Get-A9AdaptiveOptimizationConfig
.NOTES
	This command requires a SSH type connection.
	Usage:
	- AO will limit the space utilization of a CPG to the lowest of: max, warn, or limit. If none of these values is set for the AOCFG tier or CPG, then AO will only be bounded by the available raw space of the CPG characteristics.
#>
[CmdletBinding(DefaultParameterSetName='API')]
param(	[Parameter(ParameterSetName='SSH')]             [String]	$Domain,
		[Parameter()]	                                [String]	$ConfigName,
        [Parameter(ParameterSetName='SSH',Mandatory)]   [switch]    $useSSL
)
begin
    {	if ( $PSCmdlet.ParameterSetName -eq 'API' )
        {	if ( Test-A9Connection -CLientType 'API' -returnBoolean )
                {	$PSetName = 'API'
                }
            else{	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                        {	$PSetName = 'SSH'
                        }
                }
        }
        elseif ( ($PSCmdlet.ParameterSetName -eq 'ssh') )	
        {	if ( Test-A9COnnection -ClientType 'SshClient' -returnBoolean )
                {	$PSetName = 'SSH'
                }
            else{	write-warning "No SSH connection was Detected to complete the command. Please use the Connect-HPESAN command to reconnect."
                    return
                }
        }
    }
process
    {   switch ($PSetName)
            {   'API'   
                    {   $Result = $null
                        $dataPS = $null
                        $uri = '/aoconfigurations'
                        if($AOconfigName)	{	$uri = $uri+'/'+$ConfigName	}	
                        $Result = Invoke-A9API -uri $uri -type 'GET' 
                        return $Result
                    }
                'SSH'   
                    {	$Cmd = " showaocfg "
                        if($Domain)	{	$Cmd += " -domain $Domain "	}
                        if($ConfigName)	{	$Cmd += " $ConfigName " }
                        $Result = Invoke-A9CLICommand -cmds  $Cmd
                        
                    }
            }            
    }
end
    {   if ($ShowRaw)   { Return $Result }
        if ( $PSSetName -eq 'SSH')
            {   if($Result.count -gt 1)
                    {	$tempFile = [IO.Path]::GetTempFileName()
                        $LastItem = $Result.Count -2  
                        $oneTimeOnly = "True"
                        foreach ($s in  $Result[1..$LastItem] )
                            {	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
                                $s= $s.Trim()		
                                if($oneTimeOnly -eq "True")
                                    {	$sTemp1=$s				
                                        $sTemp = $sTemp1.Split(',')							
                                        $sTemp[2] = "T0(CPG)"
                                        $sTemp[3] = "T1(CPG)"
                                        $sTemp[4] = "T2(CPG)"
                                        $sTemp[5] = "T0Min(MB)"
                                        $sTemp[6] = "T1Min(MB)"
                                        $sTemp[7] = "T2Min(MB)"
                                        $sTemp[8] = "T0Max(MB)"
                                        $sTemp[9] = "T1Max(MB)"
                                        $sTemp[10] = "T2Max(MB)"
                                        $sTemp[11] = "T0Warn(MB)"
                                        $sTemp[12] = "T1Warn(MB)"
                                        $sTemp[13] = "T2Warn(MB)"
                                        $sTemp[14] = "T0Limit(MB)"
                                        $sTemp[15] = "T1Limit(MB)"
                                        $sTemp[16] = "T2Limit(MB)"
                                        $newTemp= [regex]::Replace($sTemp,"^ ","")			
                                        $newTemp= [regex]::Replace($sTemp," ",",")				
                                        $newTemp= $newTemp.Trim()
                                        $s=$newTemp			
                                    }
                                Add-Content -Path $tempfile -Value $s
                                $oneTimeOnly = "False"		
                            }
                        $Result = Import-Csv $tempFile 
                        Remove-Item  $tempFile 
                    }
                else{	Return $Result	}
            }
        else
            {	write-error "While Executing Get-AOConfiguration" 
                return $Result.StatusDescription
            }
    }
}

