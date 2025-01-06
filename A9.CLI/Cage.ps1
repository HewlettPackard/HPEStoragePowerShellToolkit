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
.PARAMETER Time 
	Specifies the number of seconds, from 0 through 255 seconds, to blink the LED. 
	If the argument is not specified, the option defaults to 60 seconds.
.PARAMETER CageName 
	Specifies the drive cage name as shown in the Name column of Get-Cage command output.
.PARAMETER ModuleName
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
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]				[String]	$Time,
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]	$CageName,
		[Parameter(ValueFromPipeline=$true)]				[String]	$ModuleName,
		[Parameter(alse,ValueFromPipeline=$true)]			[String]	$ModuleNumber,
		[Parameter(ValueFromPipeline=$true)]				[String]	$Mag,
		[Parameter(ValueFromPipeline=$true)]				[String]	$PortName
)		
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "locatecage "	
	if ($time)
		{	$s = 0..255
			$demo = $time
			if($s -match $demo)
				{	$str="time"
					$cmd+=" -t $time"
				}
			else{	return " Error : -time $time is Not valid use seconds, from 0 through 255 Only "
				}
		}
	if ($CageName)
		{	$cmd2="showcage "
			$Result2 = Invoke-A9CLICommand -cmds  $cmd2
			if($Result2 -match $CageName)
				{	$cmd+=" $CageName"
				}
			else{return "FAILURE : -CageName $CageName  is Unavailable `n Try using [Get-Cage] Command "
				}
		}
	else{	return "Error :  -CageName is mandatory. "
		}
	if ($ModuleName)	{	$cmd+=" $ModuleName"  }	
	if ($ModuleNumber)	{	$cmd+=" $ModuleNumber"}
	if ($Mag)
		{	$a = 0..15
			$demo = $Mag
			if($a -match $demo)
				{	$str="mag"
					$cmd +=" $Mag"
				}
			else{	return "Error : -Mag $Mag is Not valid use seconds,from 0 through 15 Only"		
				}
		}	
	if ($PortName)
		{	$s=$str
			if ($s -match "mag" )	{	return "FAILURE : -Mag $Mag cannot be used along with  -PortName $PortName "	}
			else
				{	$a = $PortName
					$b = "A0","B0","A1","B1","A2","B2","A3","B3"
					if($b -eq $a)	{	$cmd +=" $PortName"	}
					else			{	return "Error : -PortName $PortName is invalid use [ A0| B0 | A1 | B1 | A2 | B2 | A3 | B3 ] only  "	}
				}	
		}	
	$Result = Invoke-A9CLICommand -cmds  $cmd	
	write-verbose "  Executing Find-Cage Command , surface scans or diagnostics on physical disks with the command   " 	
	if([string]::IsNullOrEmpty($Result))
		{	return  "Success : Find-Cage Command Executed Successfully $Result"
		}
	else{	return  "FAILURE : While Executing Find-Cage `n $Result"
		} 		
}
}

Function Get-A9Cage
{
<#
.SYNOPSIS
	The command displays information about drive cages.
.DESCRIPTION
	The command displays information about drive cages.    
.EXAMPLE
	PS:> Get-A9Cage
	
	This examples display information for a single system’s drive cages.
.EXAMPLE  
	PS:> Get-A9Cage -D -CageName cage2	
	
	Specifies that more detailed information about the drive cage is displayed
.EXAMPLE  
	PS:> Get-A9Cage -I -CageName cage2
	
	Specifies that inventory information about the drive cage is displayed. 
.PARAMETER D
	Specifies that more detailed information about the drive cage is displayed. If this option is not
	used, then only summary information about the drive cages is displayed. 
.PARAMETER E  
	Displays error information.
.PARAMETER C  
	Specifies to use cached information. This option displays information faster because the cage does
	not need to be probed, however, some information might not be up-to-date without that probe.
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
.PARAMETER CageName  
	Specifies a drive cage name for which information is displayed. This specifier can be repeated to display information for multiple cages
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter()]	[Switch]	$D,
		[Parameter()]	[Switch]	$E,
		[Parameter()]	[Switch]	$C,
		[Parameter()]	[Switch]	$SFP,
		[Parameter()]	[Switch]	$DDM,
		[Parameter()]	[Switch]	$I,
		[Parameter()]	[Switch]	$SVC,
		[Parameter()]	[String]	$CageName
	)		
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "showcage "
	$testCmd= "showcage "
	if($D)	{ 	$cmd +=" -d "}
	if($E) 	{ 	$cmd +=" -e "}
	if($C) 	{ 	$cmd +=" -c "}
	if($SFP){ 	$cmd +=" -sfp " }
	if($DDM){ 	$cmd +=" -ddm " }
	if($I) 	{ 	$cmd +=" -i " }
	if($SVC){ 	$cmd +=" -svc -i"}
	if ($CageName) 
		{	$cmd+=" $CageName "
			$testCmd+=" $CageName "
		}
	$Result = Invoke-A9CLICommand -cmds  $cmd
	write-verbose "  Executing  Get-Cage command that displays information about drive cages. with the command   " 
	if($cmd -eq "showcage " -or ($cmd -eq $testCmd))
		{	if($Result.Count -gt 1)
				{	$tempFile = [IO.Path]::GetTempFileName()
					$LastItem = $Result.Count 
					#Write-Host " Result Count =" $Result.Count
					foreach ($s in  $Result[0..$LastItem] )
						{	$s= [regex]::Replace($s,"^ ","")			
							$s= [regex]::Replace($s," +",",")	
							$s= $s.Trim() 	
							Add-Content -Path $tempFile -Value $s
						}
					Import-Csv $tempFile 
					Remove-Item  $tempFile
					Return  " Success : Executing Get-Cage"
				}
			else{	Return  " FAILURE : While Executing Get-Cage `n $Result"		
				}		
		}
	if($Result -match "Cage" )
		{	$result	
			Return  " Success : Executing Get-Cage"
		} 
	else{	Return  " FAILURE : While Executing Get-Cage `n $Result"
		} 
}
}

Function Set-A9Cage
{
<#
.SYNOPSIS
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.DESCRIPTION
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.EXAMPLE
	PS:> Set-A9Cage -Position left -CageName cage1

	This example demonstrates how to assign cage1 a position description of Side Left.
.EXAMPLE
	PS:> Set-A9Cage -Position left -PSModel 1 -CageName cage1

	This  example demonstrates how to assign model names to the power supplies in cage1. Inthisexample, cage1 hastwopowersupplies(0 and 1).
.PARAMETER Position  
	Sets a description for the position of the cage in the cabinet, where <position> is a description to be assigned by service personnel (for example, left-top)
.PARAMETER PSModel	  
	Sets the model of a cage power supply, where <model> is a model name to be assigned to the power supply by service personnel. get information regarding PSModel try using  [ Get-Cage -option d ]
.PARAMETER CageName	 
	Indicates the name of the drive cage that is the object of the setcage operation.	
.NOTES
	This command requires a SSH type connection.
#>
[CmdletBinding()]
param(	[Parameter(ValueFromPipeline=$true)]	[String]	$Position,
		[Parameter(ValueFromPipeline=$true)]	[String]	$PSModel,
		[Parameter(ValueFromPipeline=$true)]	[String]	$CageName
)	
Begin	
{   Test-A9Connection -ClientType 'SshClient' 
}
Process
{	$cmd= "setcage "
	if ($Position ){	$cmd+="position $Position "}		
	if ($PSModel)
		{	$cmd2="showcage -d"
			$Result2 = Invoke-A9CLICommand -cmds  $cmd2
			if($Result2 -match $PSModel)	{	$cmd+=" ps $PSModel "	}	
			else{	return "Failure: -PSModel $PSModel is Not available. To Find Available Model `n Try  [Get-Cage -option d ] Command"
				}
		}		
	if ($CageName)
		{	$cmd1="showcage"
			$Result1 = Invoke-A9CLICommand -cmds  $cmd1
			if($Result1 -match $CageName)	{	$cmd +="$CageName "	}
			else{	return "Failure:  -CageName $CageName is Not available `n Try using [ Get-Cage ] Command to get list of Cage Name "
				}	
		}	
	else
		{	return "ERROR: -CageName is a required parameter"
		}		
	$Result = Invoke-A9CLICommand -cmds  $cmd
	write-verbose " The Set-Cage command enables service personnel to set or modify parameters for a drive cage  " 		
	if([string]::IsNullOrEmpty($Result))
		{	return  "Success : Executing Set-Cage Command $Result "
		}
	else
		{	return  "FAILURE : While Executing Set-Cage $Result"
		} 		
}
}

