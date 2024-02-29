####################################################################################
## 	© 2019,2020 Hewlett Packard Enterprise Development LP
##
##	File Name:		Logger.psm1
##	Description: 	Common Logger 
##		
##	Created:		June 2015
##	Last Modified:	January 2019
##	History:		v1.0 - Created
##					v2.2 - Added functions to write Exceptions
##	
#####################################################################################

$global:LogInfo = $true
$global:DisplayInfo = $true

if(!$global:VSVersion)
{
	$global:VSVersion = "v3.0"
}

if(!$global:ConfigDir) 
{
	$global:ConfigDir = $null 
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$curPath = Split-Path -Path $MyInvocation.MyCommand.Definition |Split-path  

$pathLogs = join-path $curPath "X-Logs"
if(-Not (Test-Path $pathLogs) )
{
    try{
		New-Item $pathLogs -Type Directory | Out-Null
	}
	catch
	{
		$global:LogInfo = $false
		Write-Warning "Failed to create Logs Directory $_.Exception.ToString() Log file will not be created."
	}
}
[String]$temp = Get-Date -f s
$timeStamp = $temp.ToString().Replace(":","-")

$timeStampPath = "\Log-{0}.log" -f $timeStamp     
$LogFile = ($pathLogs + $timeStampPath)

$timeStampPath = "\DebugLog-{0}.log" -f $timeStamp     
$dbgLogFile = ($pathLogs + $timeStampPath) 

$timeStampPath = "\Result-{0}.txt" -f $timeStamp     
$resultFile = ($pathLogs + $timeStampPath)

Function Write-Exception 
{
<#
.SYNOPSIS
    Logs exception message to a log file under Logs directory.
.DESCRIPTION
	Logs exception message to a log file under Logs directory. This directory is directory one level above of the current executing path of the module.
.EXAMPLE
    Write-Exception -TextLog "Exception Occured"
.PARAMETER TextLog 
    Specify the exception message
.PARAMETER Error 
    Specify the switch -error to indicate it as Error: 
.PARAMETER Warn 
    Specify the switch -warn to indicate it as Warning: 
.Notes
    NAME:  Write-Exception    
    LASTEDIT: 05/15/2012
    KEYWORDS: Write-Exception
#>
[cmdletbinding()]
Param
	(
	    [parameter(mandatory = $true)]    
	    $TextLog,	    	   
	    [parameter(mandatory = $False)]
	    [Switch]
	    $Error,
	    [parameter(mandatory = $False)]
	    [Switch]
	    $Warn
	 )     
    
    if ($TextLog.GetType.Name -eq "Hashtable")
    {
      $TextLog.GetEnumerator() | Sort-Object Name | foreach-object {Write-Output "{0},{1}" -f $_.Name,$_.Value | Out-File $LogFile -Append}
                        
    }elseif($TextLog.GetType.Name -eq "Object[]")
    {
        $TextLog.GetEnumerator() | Sort-Object Name | foreach-object {Write-Output $_ | Out-File $LogFile -Append}
    
    }elseif($TextLog -is [Array])
    {
        $TextLog.GetEnumerator() | Sort-Object Name | foreach-object {Write-Output $_ | Out-File $LogFile -Append}
    }
    else
    {			       
        if ($Error)
        {
            Write-Error $TextLog
        }
        if ($Warn)
        {
            Write-Warning $TextLog
        }       
    }
	
	# Write to debug log file the error message if debug log is set to true
	$strLog = "Error :" + $TextLog
	Write-LogFile -TextLog $strLog
}

Function Write-LogFile 
{
<#
.SYNOPSIS
    Logs general debug messages to a log file under Logs directory. This is internal method not exposed to public.
.DESCRIPTION
	Logs general debug messages to a log file under Logs directory. This directory is directory one level above of the current executing path of the module.
.EXAMPLE
    Write-LogFile -TextLog "My Debugging message"
.PARAMETER TextLog 
    Specify the exception message
.Notes
    NAME:  Write-LogFile    
    LASTEDIT: 05/15/2012
    KEYWORDS: Write-LogFile
#>
[cmdletbinding()]
Param
	(
	    [parameter(Position=0, mandatory = $true)]   
	    $TextLog
		
		#[parameter(Position=1 ,mandatory = $true)]		
	    #$LogDebugInfo
	 )

	# Sometimes Logs folder is not getting created in a scenario where the modules are imported and then the Logs folder is deleted by the user.
	# Just to make sure we have the folder created, doing this check again.
	if(-Not (Test-Path $pathLogs) )
    {       
	   try{
		New-Item $pathLogs -Type Directory | Out-Null
		}
		catch
		{
			$global:LogInfo = $false
			Write-Warning "Failed to create Logs Directory $_.Exception.ToString() Log file will not be created."
		}		
    }
	
	if($global:LogInfo)
	{
	   Write-Output "$(Get-Date) $TextLog" | Out-File $dbgLogFile -Append       
	          
	} 
}

Function Write-DebugLog
{
<#
  .SYNOPSIS
    Logs general debug messages to a console and also to a log file if Set-DebugLog is set to $true. See Set-DebugLog for more info.
  
  .DESCRIPTION
	 Logs general debug messages to a console and also to a log file if Set-DebugLog is set to $true. See Set-DebugLog for more info. Log directory is created
	 which is one level above of the current executing path of the module.
        
  .EXAMPLE
    Write-DebugLog -TextLog "My Debugging message" -MessageType "INFO:"
	MessageType can take values "INFO:" , "ERR:" , "WARN:" , "DEBUG:" , "OTH:". Message type is case sensitive and must match 
	as seen in the expected values.
    
  .PARAMETER TextLog 
    Specify the exception message
           
  .PARAMETER MsssageType
    Specify the type of message. MessageType can take values "INFO:" , "ERR:" , "WARN:" , "DEBUG:" , "OTH:". Message type is case sensitive and must match 
	as seen in the expected values.
.Notes
    NAME:  Write-DebugLog    
    LASTEDIT: 05/15/2012
    KEYWORDS: Write-DebugLog
#>
	
	[cmdletbinding()]
	Param
	(
	    [parameter(Position=0, mandatory = $true)]
	    [System.String]
	    $Message,
		[parameter(Position=1, mandatory = $false)]
	    [System.String]
	    $MessageType     
	 )

	#User Preference if he wants to see the display on PS console. User can swith the Display on/off by calling Set-DebugInfo $true $true.
	# Display is disabled by default. 
	$datetimeMessage = "$(Get-Date) " + $Message
	if ($global:DisplayInfo)	{
	
		If ($MessageType -match "ERR:") {
		   # write-host $datetimeMessage -ForegroundColor RED
		} elseIf ($MessageType -match "WARN:") {
		    #write-host $datetimeMessage -ForegroundColor DARKYELLOW 
		} elseIf ($MessageType -match "WARNING:") {
		    #write-host $datetimeMessage -ForegroundColor DARKYELLOW 
		} elseIf ($MessageType -match "INFO:") {
		    #write-host $datetimeMessage -ForegroundColor DARKGRAY 
		} elseIf ($MessageType -match "DEBUG:") {
		    #write-host $datetimeMessage -ForegroundColor DARKGREEN 
			# dont write any DEBUG messages on the console. Let them only be written in the log file.
		} elseIf ($MessageType -match "OTH:") {
		   #write-host $datetimeMessage -ForegroundColor BLACK 
		} Else {
		    #write-host $datetimeMessage
		}
	}
	
	
	# Write to the debug log file the error message if  Set-DebugLog is set to true
	$LogMessage = $MessageType + " " + $Message
	Write-LogFile -TextLog $LogMessage
	
}

Export-ModuleMember Write-DebugLog , Write-Exception
