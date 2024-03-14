####################################################################################
## 	© 2019,2020 Hewlett Packard Enterprise Development LP
##

$curPath = Split-Path -Path $MyInvocation.MyCommand.Definition |Split-path  

$pathLogs = join-path $curPath "X-Logs"

[String]$temp = Get-Date -f s
$timeStamp = $temp.ToString().Replace(":","-")

$timeStampPath = "\Log-{0}.log" -f $timeStamp     
$LogFile = ($pathLogs + $timeStampPath)

$timeStampPath = "\DebugLog-{0}.log" -f $timeStamp     
$dbgLogFile = ($pathLogs + $timeStampPath) 

$timeStampPath = "\Result-{0}.txt" -f $timeStamp     

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
	(	[parameter(mandatory = $true)]				$TextLog,	    	   
		[parameter()]					[Switch]	$Error,
		[parameter()]					[Switch]	$Warn
	)     
    
    if ($TextLog.GetType.Name -eq "Hashtable")
		{	$TextLog.GetEnumerator() | Sort-Object Name | foreach-object {Write-Output "{0},{1}" -f $_.Name,$_.Value | Out-File $LogFile -Append}    
		}
	elseif($TextLog.GetType.Name -eq "Object[]")
		{	$TextLog.GetEnumerator() | Sort-Object Name | foreach-object {Write-Output $_ | Out-File $LogFile -Append}
		}
	elseif($TextLog -is [Array])
		{    $TextLog.GetEnumerator() | Sort-Object Name | foreach-object {Write-Output $_ | Out-File $LogFile -Append}
		}
    else
		{	if ($Error)		{    Write-Error $TextLog	}
			if ($Warn)			{	Write-Warning $TextLog	}       
		}
	$strLog = "Error :" + $TextLog
	Write-verbose $strLog
}

