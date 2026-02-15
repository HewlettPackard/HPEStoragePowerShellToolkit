####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function Open-A9SSE 
{
<#   
.SYNOPSIS	
	Establishing a communication channel for Server-Sent Event (SSE).
.DESCRIPTION
	Establishing a communication channel for Server-Sent Event (SSE) 
.EXAMPLE
	PS:> Open-A9SSE
#>
[CmdletBinding()]
Param()
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Result = Invoke-A9API -uri '/eventstream' -type 'GET' 
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
		}	
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $dataPS		
		}
	else
		{	write-error "FAILURE : While Executing Open-SSE_WSAPI."
			return $Result.StatusDescription
		}
}	
}

Function Get-A9EventLogs 
{
<#
.SYNOPSIS	
	Get all past events from system event logs or a logged event information for the available resources. 
.DESCRIPTION
	Get all past events from system event logs or a logged event information for the available resources. 
.EXAMPLE
	PS:> Get-A9EventLogs
#>
[CmdletBinding()]
Param()
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$Result = $null
	$dataPS = $null	
	Write-Progress -Activity "Invoke RestAPI Call (May take 30 seconds)" -status "10% Complete" -PercentComplete 10
	$Result = Invoke-A9API -uri '/eventlog' -type 'GET'
	
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			$ItemCount = $dataPS.count
			Write-Progress -Activity "Processing $ItemCount Items..." -status "40% Complete" -PercentComplete 40
			$Current=1
			[int]$LastCountperc = 40
			$NewObj = @(    foreach( $Item in $DataPS)	
                                        {   $NewItem=@{PSTypeName = "HPE.A9Storage.EventLog"}

                                            $Enum = $Item.class
												Switch ($Enum)
													{   1	{   $desc = 'ALERT'       	}
                                                        2	{   $desc = 'CREATION'  	}
                                                        3	{   $desc = 'REMOVAL'		}
                                                        4	{   $desc = 'MODIFICATION'  }
                                                        5	{   $desc = 'STATUS_CHANGE' }
                                                        99	{   $desc = 'UNKNOWN'       }
													}
												if ($Desc) 
													{   $NewItem['ClassDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}

												$Enum = $Item.category
												Switch ($Enum)
													{   1	{   $desc = 'LIFECYCE'      }
                                                        2	{   $desc = 'ALERT'  		}
													}
												if ($Desc) 
													{   $NewItem['CategoryDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}
												$Enum = $Item.severity
												Switch ($Enum)
													{   1	{   $desc = 'FATAL'     	}
                                                        2	{   $desc = 'CRITICAL'  	}
                                                        3	{   $desc = 'MAJOR'  		}
                                                        4	{   $desc = 'MINOR'  		}
                                                        5	{   $desc = 'DEGRADED'  	}
                                                        6	{   $desc = 'INFORMATIONAL'	}
                                                        7	{   $desc = 'DEBUG'  		}
                                                        99	{   $desc = 'UNKNOWN'  		}
													}
												if ($Desc) 
													{   $NewItem['SeverityDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}

												$Enum = $Item.component
												Switch ($Enum)
													{   2	{   $desc = 'VLUN'     	}
                                                        3	{   $desc = 'PORT'  	}
                                                        4	{   $desc = 'VOLUME'  	}
                                                        41	{   $desc = 'SFP'  		}
													}
												if ($Desc) 
													{   $NewItem['ComponentDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}
			
												$Enum = $Item.resource
												Switch ($Enum)
													{   2	{   $desc = 'VLUN'     	}
                                                        3	{   $desc = 'PORT'  	}
                                                        4	{   $desc = 'VOLUME'  	}
                                                    }
												if ($Desc) 
													{   $NewItem['ResourceDescription'] = $Desc
												    	remove-variable Desc -erroraction SilentlyContinue
														remove-variable Enum -erroraction SilentlyContinue
													}
											$Item.psobject.properties | foreach-object { $NewItem[$_.Name] = $_.Value }
											$DataSetType = "HPE.A9Storage.EventLog"
											$NewItem.PSTypeNames.Insert(0,$DataSetType)
											$DataSetType = $DataSetType + ".TypeName"
											$NewItem.PSObject.TypeNames.Insert(0,$DataSetType)
											[PSCustomObject]$NewItem
											
											[int]$Perc = ( ($Current / $ItemCount * 100) / 2 )  + 45
											if ( $Perc -ge ($LastPercCount + 5) )
													{	$LastPercCount += 5
														if ($Perc -le 100)
															{	Write-Progress -Activity "Processing $ItemCount Items..." -status "$($Perc)% Complete" -PercentComplete $Perc
																
															}
													}
											$Current += 1
										}
						            )
			Write-Progress -Activity "Processing $ItemCount Items..." -status "100% Complete" -PercentComplete 100
			start-sleep 3
			Write-Progress -Activity "Processing $ItemCount Items..." -Completed
			write-host "Cmdlet executed successfully" -foreground green
			return $NewObj		
		}
	else
		{	write-error "FAILURE : While Executing Get-EventLogs_WSAPI."
			return $Result.StatusDescription
		}
}	
}
