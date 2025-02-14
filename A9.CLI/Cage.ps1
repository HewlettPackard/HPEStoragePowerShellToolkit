####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

Function Find-A9Cage
{
<#
.SYNOPSIS
	The command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs.
.DESCRIPTION
	The command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs. 
.PARAMETER Time 
	Specifies the number of seconds, from 0 through 255 seconds, to blink the LED. 
	If the argument is not specified, the option defaults to 60 seconds.
.PARAMETER CageName 
	Specifies the drive cage name as shown in the Name column of Get-Cage command output.
.PARAMETER ModuleName
	Indicates the module name to locate. Accepted values are
	pcm|iom|drive. The iom specifier is not supported for node enclosures.
.PARAMETER 3ParModuleName
	Indicates the module name to locate. Accepted values are
	pcm|iom|drive. The iom specifier is not supported for node enclosures.
.PARAMETER ModuleNumber
	Indicates the module number to locate. The cage and module number can be found
	by issuing showcage -d <cage_name>.
.PARAMETER Mag 
	Indicates the drive magazine by number.
	• For DC1 drive cages, accepted values are 0 through 4.
	• For DC2 and DC4 drive cages, accepted values are 0 through 9.
	• For DC3 drive cages, accepted values are 0 through 15.
.PARAMETER PortName  
	Indicates the port specifiers. Accepted values are A0|B0|A1|B1|A2|B2|A3|B3. 
	If a port is specified, the port LED will oscillate between green and off.
.PARAMETER 3ParOnly
	This forces the parameter set to use the 3Par only options
.EXAMPLE
	PS:> Find-A9Cage -Time 30 -CageName cage0	
	
	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds.
.EXAMPLE  
	PS:> Find-A9Cage -Time 30 -CageName cage0 -mag 3	

	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds,Indicates the drive magazine by number 3.
.EXAMPLE  
	PS:> Find-A9Cage -Time 30 -CageName cage0 -PortName demo1

	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds, If a port is specified, the port LED will oscillate between green and off.
.EXAMPLE  	
	PS:> Find-A9Cage -CageName cage1 -Mag 2	

	This example causes the Fibre Channel LEDs on the drive CageName cage1 to blink, Indicates the drive magazine by number 2.	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='A9')]
param(	[Parameter()]
		[ValidateRange(0,255)]	[String]	$Time,
		[Parameter(Mandatory)]	[String]	$CageName,
		[Parameter(ParameterSetName='A9')]	
		[ValidateSet('pcm','iom','drive')]
								[String]	$ModuleName,
		[Parameter(ParameterSetName='3Par')]	
		[ValidateSet('enclosure','fan','powersupply','battery','iocard','disk','magazine')]
								[String]	$3ParModuleName,
		[Parameter()]			[String]	$ModuleNumber,
		[Parameter(ParameterSetName='3Par')]
		[ValidateRange(0,23)]	[String]	$Mag,
		[Parameter(ParameterSetName='3Par')]
		[ValidateSet('A0','B0','A1','B1','A2','B2','A3','B3')]
								[String]	$PortName,
		[Parameter(ParameterSetName='3Par')]
								[switch]	$3ParOnly
)		
Begin	
	{   Test-A9Connection -ClientType 'SshClient'
		if ( 	( ($ArrayType.ToLower() -ne "3par") -and ($PSCmdlet.ParameterSetName -eq '3Par') ) -or
					( ($ArrayType.ToLower() -eq "3par") -and ($PSCmdlet.ParameterSetName -ne '3Par') ) )
				{	write-warning "You selected a parameter set that doesnt match the type of Array you have"
					write-warning "If the Arraytype is 3Par you must select the -3ParOnly, If it is not you must not select any of the parameters that are 3par specific."
					return
				}
	}
Process
	{	$cmd= "locatecage "	
		if ($time)	{	$cmd+=" -t $time"	}
		$cmd+=" $CageName"
		if ($ModuleName)	{	$cmd +=" $ModuleName"  	}		
		if ($ModuleNumber)	{	$cmd +=" $ModuleNumber"	}
		if ($ArrayType.ToLower() -eq "3par")
			{	if ($Mag)		{	$cmd +=" $Mag"		}
				if ($PortName)	{	$cmd +=" $PortName"	}				
			}	
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd	
	}
end
	{	if($Result)	{	write-error "FAILURE : While Executing Find-Cage `n "	} 	
		else		{	write-host "Success : Find-Cage Command Executed Successfully" -ForegroundColor Green }
		return$Result
	}
}

Function Get-A9Cage
{
<#
.SYNOPSIS
	The command displays information about drive cages.
.DESCRIPTION
	The command displays information about drive cages.    
.PARAMETER ErrorInformation  
	Displays error information.
.PARAMETER CachedData
	Specifies to use cached information. This option displays information faster because the cage does
	not need to be probed, however, some information might not be up-to-date without that probe.
.PARAMETER State
	Specifies that detailed state information is displayed. If the State is Normal, DetailedState is also Normal. 
	If the State is non-Normal, DetailedState displays a list of conditions in the cage which map to cage 
	alerts and status in the -all option.
.PARAMETER SFP  
	Specifies information about the SFP(s) attached to a cage. Currently, additional SFP information
	can only be displayed for DC2 and DC4 cages.
.PARAMETER I	
	Specifies that inventory information about the drive cage is displayed. If this option is not used,
	then only summary information about the drive cages is displayed.
.PARAMETER DDm
	Specifies the SFP DDM information. This option can only be used with the
	-sfp option and cannot be used with the -d option.
.PARAMETER SVC
	Displays inventory information with HPE serial number, spare part number, and so on. it is supported only on HPE 3PAR Storage 7000 Storagesystems and  HPE 3PAR 8000 series systems"
.PARAMETER All
	Displays all the components status information.
.PARAMETER Connector
	Displays the internal and external enclosure IO module SAS connector status information, e.g., disabled, link speed, status.
.PARAMETER Cooling
	Displays the cooling status information, e.g., speed, cooling LEDs, status.
.PARAMETER Enclosure
	Displays the enclosure status information, e.g., enclosure LEDs, status.
.PARAMETER Env
	Displays the temperature, current, and voltage sensors information.
.PARAMETER Expander
	Displays the expander status information, e.g., address, status.
.PARAMETER IOM
	Displays the IO module status information, e.g., IOM LEDs, status.
.PARAMETER Mag
	Displays the magazine (drive bay) status information, e.g., power, bypass, drive bay LEDs, status.
.PARAMETER Power
	Displays the power status information, e.g., power LEDs, status.
.PARAMETER Sep
	Displays the SEP status information, e.g., firmware version/status, address, status.
.PARAMETER Temperature
	Displays the temperature sensor status information, e.g., temperature, threshold, status.
.PARAMETER CageName  
	Specifies a drive cage name for which information is displayed. This specifier can be repeated to display information for multiple cages
.PARAMETER ShowRaw
	This option will show the raw returned data instead of returning a proper PowerShell object. 
.EXAMPLE
	PS:> Get-A9Cage
	
	This examples display information for a single system’s drive cages.
.EXAMPLE  
	PS:> Get-A9Cage -I -CageName cage2
	
	Specifies that inventory information about the drive cage is displayed. 
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[Parameter(parametersetname='3Par')]			[Switch]	$ErrorInformation,
		[Parameter(parametersetname='3Par')]			[Switch]	$CachedData,
		[Parameter(parametersetname='3Par')]			[Switch]	$State,
		[Parameter()]									[Switch]	$DDM,
		[Parameter()]									[Switch]	$SFP,
		[Parameter()]									[Switch]	$I,
		[Parameter()]									[Switch]	$SVC,
		[Parameter(ParameterSetName='A9All')]			[Switch]	$All,
		[Parameter(ParameterSetName='A9Connector')]		[Switch]	$Connector,
		[Parameter(ParameterSetName='A9Cool')]			[Switch]	$Cooling,
		[Parameter(ParameterSetName='A9Enclosure')]		[Switch]	$Enclosure,
		[Parameter(ParameterSetName='A9End')]			[Switch]	$Env,
		[Parameter(ParameterSetName='A9Expander')]		[Switch]	$Expander,
		[Parameter(ParameterSetName='A9Iom')]			[Switch]	$IOM,
		[Parameter(ParameterSetName='A9Mag')]			[Switch]	$Mag,
		[Parameter(ParameterSetName='A9Power')]			[Switch]	$Power,
		[Parameter(ParameterSetName='A9Sep')]			[Switch]	$Sep,
		[Parameter(ParameterSetName='A9Temp')]			[Switch]	$Temperature,
		[Parameter(mandatory=$false)]					[String]	$CageName,
		[Parameter(ParameterSetName='3Par')]			[switch]	$3ParOnly,
		[Parameter()]									[Switch]	$ShowRaw
	)		
Begin	
	{   Test-A9Connection -ClientType 'SshClient' 
		if ( 	( ($ArrayType.ToLower() -ne "3par") -and ($PSCmdlet.ParameterSetName -eq '3Par') ) -or
						( ($ArrayType.ToLower() -eq "3par") -and ($PSCmdlet.ParameterSetName -ne '3Par') ) )
					{	write-warning "You selected a parameter set that doesnt match the type of Array you have"
						write-warning "If the Arraytype is 3Par you must select the -3ParOnly, If it is not you must not select any of the parameters that are 3par specific."
						return
					}
	}
Process
	{	$cmd= "showcage "
		if($ErrorInformation )	
			{	if ( ($arraytype.ToLower() -eq '3Par') ) 	
					{ 	$cmd +=" -e "}
				else{	$cmd +=" -error " }
			}
		if($CachedData 			-and ($arraytype.ToLower() -eq '3Par') ) 	{ 	$cmd +=" -c "}
		if($State 				-and ($arraytype.ToLower() -eq '3Par') ) 	{ 	$cmd +=" -state "}
		if($SFP)		{ 	$cmd +=" -sfp " }
		if($DDM)		{ 	$cmd +=" -ddm " }
		if($SVC)		{ 	$cmd +=" -svc -i"}
		elseif($I) 		{ 	$cmd +=" -i " }
		if($All)		{ 	$cmd +=" -all " }
		if($Connector)	{ 	$cmd +=" -con " }
		if($Cool)		{ 	$cmd +=" -cooling " }
		if($Enclosure)	{	$cmd +=" -enc " }
		if($Env)		{ 	$cmd +=" -env " }
		if($Expander)	{ 	$cmd +=" -exp " }
		if($IOM)		{ 	$cmd +=" -iom " }
		if($Mag)		{ 	$cmd +=" -mag " }
		if($Power)		{ 	$cmd +=" -power " }
		if($sep)		{ 	$cmd +=" -sep " }
		if($temperature){ 	$cmd +=" -temp " }
		$cmd+=" $CageName "
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds $cmd
	}
end
	{	if($ShowRaw -or $i -or $svc -or $all) { return $Result }
		if($Result.Count -gt 1)
				{	if ( ($PSBoundParameters.count -eq 0) -or $Cooling)
						{ 	$HeaderLine = 0
							$StartIndex=1
							$EndIndex=$Result.count-1
						}
					elseif ($Connector -or $IOM -or $mag -or $Power -or $Sep -or $Enclosure)
						{	$HeaderLine = 0
							$StartIndex=1
							$EndIndex=$Result.count-3
						}
					elseif ($Env -or $Temperature -or $sfp)
						{	$HeaderLine = 1
							$StartIndex=2
							$EndIndex=$Result.count-3
						}
				}
		else{	write-warning "FAILURE : While Executing Get-Cage"
				Return $Result
			}	
		$tempFile = [IO.Path]::GetTempFileName()	
		$ResultHeader = ((($Result[$HeaderLine].split(' ')).trim()).trim('-') | where-object { $_ -ne '' } ) -join ','
		Add-Content -Path $tempFile -Value $ResultHeader
		foreach ($s in $Result[$StartIndex..$EndIndex])
			{	$s = ( ($s.split(' ')).trim() | where-object { $_ -ne '' } ) -join ','
				Add-Content -Path $tempFile -Value $s
			}	
		$returndata = Import-Csv $tempFile
		Remove-Item $tempFile
		return $returndata
	}
}

Function Set-A9Cage
{
<#
.SYNOPSIS
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.DESCRIPTION
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.PARAMETER Position  
	Sets a description for the position of the cage in the cabinet, where <position> is a description to be assigned by service personnel (for example, left-top)
.PARAMETER PSModel	  
	Sets the model of a cage power supply, where <model> is a model name to be assigned to the power supply by service personnel. get information regarding PSModel try using  [ Get-Cage -option d ]
.PARAMETER CageName	 
	Indicates the name of the drive cage that is the object of the setcage operation.	
.EXAMPLE
	PS:> Set-A9Cage -Position left -CageName cage1

	This example demonstrates how to assign cage1 a position description of Side Left.
.EXAMPLE
	PS:> Set-A9Cage -Position left -PSModel 1 -CageName cage1

	This  example demonstrates how to assign model names to the power supplies in cage1. Inthisexample, cage1 hastwopowersupplies(0 and 1).
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]				[String]	$Position,
		[Parameter()]				[String]	$PSModel,
		[Parameter(Mandatory)]		[String]	$CageName
)	
Begin	
	{   Test-A9Connection -ClientType 'SshClient' 
	}
Process
	{	$cmd= "setcage "
		if ($Position )	{	$cmd+=" position $Position "}		
		if ($PSModel)	{	$cmd+=" ps $PSModel "	}	
		if ($CageName)	{	$cmd +="$CageName "	}
		write-verbose "Executing the following SSH command `n`t $cmd"
		$Result = Invoke-A9CLICommand -cmds  $cmd
	}
end
	{	if($Result)	{	write-warning "FAILURE : While Executing Set-Cage:" 	} 	
		else 		{	write-host "Success : Executing Set-Cage Command" -ForegroundColor Green }
		return$Result
	}
}

