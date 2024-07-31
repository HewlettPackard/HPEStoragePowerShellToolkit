# HPE MSA PowerShell Toolkit.
# File: helpers.ps1
# Description: This file contains common helper routines. These functions are called by generated SDK Cmdlet functions.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.
function Connect-MSAGroup {
<#
.SYNOPSIS
    Connects to a MSA Storage device.
.DESCRIPTION
    Connect-MSAGroup is an advanced function that provides the initial connection to a MSA
    device so that other subsequent commands can be run without having to authenticate individually.
    It is recommended to ignore the server certificate validation (-IgnoreServerCertificate param)
    since Nimble uses an untrusted SSL certificate.
.PARAMETER FQDNorIP
    The DNS name or IP address of the MSA device.
.PARAMETER Username
    Specifies a Username for a user account that has permission to perform this action. This parameter is
    mandatory so this function prompts you for a username if one is not given.
.PARAMETER Password
    Specifies a password for a user account that has permission to perform this action. This parameter is
    mandatory so this function prompts you for a password if one is not given.
.PARAMETER IgnoreServerCertificate
    Ignore the server SSL certificate.
.EXAMPLE
     Connect-MSAGroup -FQDNofIP MSA01.yourdns.local -Username chris -Password Pa55w0rd! -IgnoreServerCertificate

     *Note: IgnoreServerCertificate parameter is not available with PowerShell Core
.EXAMPLE
     Connect-MSAGroup -FQDNofIP 192.168.100.98 -Username chris -Password Pa55w0rd! -IgnoreServerCertificate

     *Note: IgnoreServerCertificate parameter is not available with PowerShell Core
.EXAMPLE
     Connect-MSAGroup -FQDNorIP MSA01.yourdns.local -Username Chris -Password Pa55w0rd! -ImportServerCertificate
#>
[cmdletbinding(DefaultParameterSetName='IgnoreServerCertificate')]
param(  [Parameter(Mandatory)]                                  [string]    $FQDNorIP,
        [Parameter(Mandatory)]                                              $Username,
        [Parameter(Mandatory)]                                              $Password,
        [Parameter(ParameterSetName='ImportServerCertificate')] [switch]    $ImportServerCertificate,
        [Parameter(ParameterSetName='IgnoreServerCertificate')] [switch]    $IgnoreServerCertificate
    )
Begin
{   clear-variable MyMSASecurityHeader -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}
Process
{   if ($PSBoundParameters.IgnoreServerCertificate) 
        {   $Global:MSAIgnoreServerCertificate = $true
            IgnoreServerCertificate
        }
    else 
        {   $Global:MSAIgnoreServerCertificate = $false
            $Global:GlobalImportServerCertificate = $ImportServerCertificate
            ValidateServerCertificate $FQDNorIP 
        }
    # Import-LocalizedData -BaseDirectory (Split-Path $PSScriptRoot -parent) -FileName "HPENimblePowerShellToolkit.psd1" -BindingVariable "ModuleData"
    #if ( [bool]( $FQDNorIP -as [ipaddress] ) )
    #    {   write-host "You entered an IP Address instead of a FQDN (Fully Qualified Domain Name), but to use the certificate we will extract the FQDN. This will require DNS Resolution"
    #        try {   $FQDNorIP = (Resolve-DnsName $FQDN).NameHost
    #            }
    #        catch 
    #            {   # unable to resolve the cert hostname. Host not reachable. Error out!.
    #                Write-Error "Unable to resolve the certificate hostname. Host not reachable. `n`n $_.Exception.Message"  -ErrorAction Stop
    #                return
    #            }
    #   }
    $Global:MSABaseUri = "https://$FQDNorIP/api"
    $AuthUri = "https://$FQDNorIP/api/login"
    
    $AuthHeader = @{    Authorization   = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($username):$($Password)")))"
                        datatype        = 'json' 
                    }
    try{    $MSAStorageTokenRaw = (Invoke-RestMethod -Uri $AuthURI -Method get -Headers $AuthHeader -SkipCertificateCheck)
            $MSAStorageTokenData = $MSAStorageTokenRaw.status
            if ($MSAStorageTokenData.'response-type' -like 'Success' )
                {   $Global:MSASecurityHeader = @{ SessionKey = $MSAStorageTokenData.response ; dataType = 'json' }
                }
            else 
                {   Write-Warning "The Connection was NOT successful. `n`tThis is likely due to an incorrect username or password; `n`t$($MSAStorageTokenData.response) "
                    clear-variable MSAStorageTokenData
                    clear-variable BaseUri -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                }
        }
    catch
        {   Write-error "Failed to connect with array $FQDNorIP `n`n $_.Exception.Message" -ErrorAction Stop
            clear-variable BaseUri -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
    $Global:MSAStorageCommonPSParams=@('Debug','Verbose','ErrorAction','ErrorVariable','InformationAction','InformationVariable','OutBuffer','OutVariable','PipelineVariable','Verbose','WarningAction','WarningVariable','WhatIf','Confim','ItemType')
}
end
{   return $MSAStorageTokenData
}
}


function IgnoreServerCertificate 
{
    [CmdletBinding()]
    param()
                <#
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            add-type @"
                using System.Net;
                using System.Security.Cryptography.X509Certificates;

                public class IDontCarePolicy : ICertificatePolicy {
                public IDontCarePolicy() {}
                public bool CheckValidationResult(
                    ServicePoint sPoint, X509Certificate cert,
                    WebRequest wRequest, int certProb) {
                    return true;
                }
                }
            "@

            [System.Net.ServicePointManager]::CertificatePolicy = new-object IDontCarePolicy
                write-verbose 'Server certificate ignored'
                #>
     if (-not ([System.Management.Automation.PSTypeName]'CustomCertificateValidationCallback').Type)
    {

      add-type @"
      using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;

    public static class CustomCertificateValidationCallback {
        public static void Install()
        {
            ServicePointManager.ServerCertificateValidationCallback += CustomCertificateValidationCallback.CheckValidationResult;
        }


        public static bool CheckValidationResult(
            object sender,
            X509Certificate certificate,
            X509Chain chain,
            SslPolicyErrors sslPolicyErrors)
        {
            // please don't do this. do some real validation with explicit exceptions.
            return true;
        }
    }
"@
    }
    [CustomCertificateValidationCallback]::Install()
}

function Register-MSAObjectType
{   param (                 $ObjectToModify,
                [string]    $SubobjectName='undefined',
                [string]    $ObjectTypeName='undefined'
                
)
process
{   write-verbose "RegisterMSAOBjectType: "
    if ($SubobjectName -eq 'undefined')
        {   write-verbose "RegisterMSAOBjectType: Subobject name not given, In Subobjectname definition"
            $ListOfNoteProps = $ObjectToModify | get-member | where-object { $_.membertype -eq 'NoteProperty' -and $_.name -ne 'status' }
            if ( $ListOfNoteProps.count -eq 1 )
                {   # There must only be a single data type. It must be the type
                    $SubobjectName = $ListOfNoteProps.name
                }
        }
    write-verbose "RegisterMSAOBjectType: The Subobjectname = $SubobjectName"
    if ( $ObjectToModify."$SubObjectName" )
    {   write-verbose "RegisterMSAOBjectType: In object modification if"
        foreach( $I in $ObjectToModify."$SubObjectname" )
        {   if ( $ObjectTypeName -eq 'undefined' )
                {   $NewTypeName = $I.'object-name'
                }
            else{   $NewTypeName = $ObjectTypeName 
                }
            $DataSetType = "MSAStorage.$NewTypeName"
            $DataSetTypeExt = $DataSetType + ".TypeName"
            write-verbose "RegisterMSAOBjectType: In object assert loop, setting for each object: type = $NewTypeName"
            $I.PSTypeNames.Insert(0,$DataSetType)
            $I.PSObject.TypeNames.Insert(0,$DataSetTypeExt)
        }            
    }
    return $ObjectToModify."$SubobjectName"
}
}

function Invoke-MSAStorageRestAPI ()
{
param(  [Parameter(Mandatory=$true)]
        [string] $Noun,
        
        [ValidateSet('show','Clear','Create','Delete','Map','Fail','Expand','Query')] 
        [string] $Verb = 'show',
        [hashtable] $RequestParams = @{}

    )
process
{    if (!(Get-Variable MSASecurityHeader -Scope Global -ErrorAction SilentlyContinue)) 
        {   Write-Error -Message "Authentication Info missing. Please use Connect-MSAGroup to login." -ErrorAction Stop
        }
    if ( $MSAIgnoreServerCertificate ) { IgnoreServerCertificate }

    switch($Verb)
    {   'show'      {   $Method = 'GET' }
        default     {   $Method = 'GET' } 
    }
    # Form the parameters to Invoke-RestMethod call.
    $WebRequestParams = @{
        Uri = "$MSABaseUri/$Verb/$Noun"
        Header = $MSASecurityHeader
        Method = $Method
    }
    # Copy request params to different variable. We may need to specifically process few of them.
    $RequestData = @{}
<#    foreach ($key in $RequestParams.keys)
        {   # PowerShell serializes Booleans in JSON as True/False. We need all lowercase for Nimble Array's REST Server.
            if ($RequestParams.$key.getType() -eq [bool])
                {   $RequestData.Add($key, $RequestParams.$key.ToString().ToLower())
                }
            else
                {   $RequestData.Add($key, $RequestParams.$key);
                }
        }
#>
<#    switch($Method) {
        'GET' {
            # Hashmap supplied in Body for GET request gets converted to query params automatically.
            $WebRequestParams.Add('Body',$RequestData)
        }

        'POST' {
            # Encapsulate request payload in 'data'..
            $RequestDataForNimbleAPI = @{
                data = $RequestData
            }

            $WebRequestParams.Add('Body',($RequestDataForNimbleAPI | ConvertTo-Json -Depth 10))
        }

        'PUT'{
            $RequestDataForNimbleAPI = @{
                data = $RequestData
            }

            $WebRequestParams.Add('Body',($RequestDataForNimbleAPI | ConvertTo-Json -Depth 10))
        }

        'DELETE' {
            # Do nothing. No Body expected/required for delete request.
        }
    }
#>
    Write-Verbose ($WebRequestParams | ConvertTo-Json -Depth 50)
    $max_retry_count = 5
    $retry_count = 0

    do {
        try
            {
          
              if ($retry_count -ne 0)
              {
                Start-Sleep -Milliseconds 30
              }
              $JsonResponse = (Invoke-RestMethod @WebRequestParams -SkipCertificateCheck | ConvertTo-Json -Depth 50)
              Write-Verbose "Server Response: $JsonResponse"

              #
              #  The Invoke-Restmethod was successful we should exit the retry loop. 
              #  To do that we will force the retry count max surpass the max.
              #
              $retry_count  = $max_retry_count  + 1
            }
        catch
        {
            if ($_.Exception.Response -ne $null) 
            {
               # APIExceptionHandler
            }
            else
            {     
                # if the Error response buffer is null then we will go for retries.
                # if we exhaust the retries we will thrown and error.
                $retry_count = $retry_count + 1
                
                if ($retry_count -gt $max_retry_count)
                {
                    Write-Verbose $_.exception
                    Write-Error "Error occoured while invoking restapi method, Please retry" -ErrorAction Stop 
                }

            }
        }
      
   }until ($retry_count -gt $max_retry_count) 
   
    return ($JsonResponse | ConvertFrom-Json)
}
}
<#
function Get-NimbleStorageAPIObject()
{
    param(
        [Parameter(Mandatory=$true)][string] $ObjectName,
        [Parameter(Mandatory=$true)][string] $APIPath,
        [Parameter(Mandatory=$true)][string] $Id,
        [System.Collections.ArrayList] $Fields
    )

    $Params = @{
        ResourcePath = $APIPath + "/$Id"
        Method = 'GET'
    }

    if ($Fields)
    {
        $Params.Add('RequestParams', @{ fields = ($Fields | Select-Object) -join ','})
    }

    $APIObject = (Invoke-NimbleStorageRestAPI @Params).data
    $DataSetType = "NimbleStorage.$ObjectName"
    $APIObject.PSTypeNames.Insert(0,$DataSetType)
    $DataSetType = $DataSetType + ".TypeName"
    $APIObject.PSObject.TypeNames.Insert(0,$DataSetType)

    return $APIObject
}

function Get-NimbleStorageAPIObjectList()
{
    param(
        [Parameter(Mandatory=$true)][string] $ObjectName,
        [Parameter(Mandatory=$true)][string] $APIPath,
        [hashtable] $Filters,
        [System.Collections.ArrayList] $Fields
    )

    # First fetch all the objects (only id and name) matching the given filter.
    # Then for each of the objects, retrieve either all the details or given fields.
    $Params = @{
        ResourcePath = $APIPath
        Method = 'GET'
        RequestParams = $Filters
    }

    # Get the list of objects matching given criteria
    $JSONResponseObject = (Invoke-NimbleStorageRestAPI @Params)
    [System.Collections.ArrayList] $APIObjects = $JSONResponseObject.data

    # We are expecting a list. If total items/objects on the array for this query are more than 1024,
    # array will send back only first 1024 objects along with total count of objects in 'totalRows'.
    if ($JSONResponseObject.endRow -and $JSONResponseObject.totalRows -and ($JSONResponseObject.endRow -lt $JSONResponseObject.totalRows))
    {
        # There are more objects. Keep getting those until we reach the end.
        while ($JSONResponseObject.endRow -lt $JSONResponseObject.totalRows)
        {
            $Params.RequestParams.startRow = $JSONResponseObject.endRow
            $JSONResponseObject = Invoke-NimbleStorageRestAPI @Params
            $APIObjects.AddRange($JSONResponseObject.data) | out-null
        }
    }

    [System.Collections.ArrayList] $APIObjectsDetailed = @()

    # Fetch needed detailes of all the objects.
    foreach ($APIObject in $APIObjects)
    {
        $Params = @{
            ObjectName = $ObjectName
            APIPath = $APIPath
            Id = $APIObject.id
        }
        if ($Fields)
        {
            $Params.Add('Fields', $Fields)
        }

        $APIObject = (Get-NimbleStorageAPIObject @Params)
        $DataSetType = "NimbleStorage.$ObjectName"
        $APIObject.PSTypeNames.Insert(0,$DataSetType)
        $DataSetType = $DataSetType + ".TypeName"
        $APIObject.PSObject.TypeNames.Insert(0,$DataSetType)
        $APIObjectsDetailed.Add($APIObject) | out-null
    }
    Write-Verbose ("Found " + $APIObjectsDetailed.Count + " objects.")
    return ,$APIObjectsDetailed
}

function New-NimbleStorageAPIObject()
{
    param(
        [Parameter(Mandatory=$true)][string] $ObjectName,
        [Parameter(Mandatory=$true)][string] $APIPath,
        [Parameter(Mandatory=$true)][hashtable] $Properties
    )

    $Params = @{
        ResourcePath = $APIPath
        Method = 'POST'
        RequestParams = $Properties
    }

    $ResponseObject = (Invoke-NimbleStorageRestAPI @Params)
    $APIObject = $ResponseObject.data
    if ($APIObject)
    {$DataSetType = "NimbleStorage.$ObjectName"
        $APIObject.PSTypeNames.Insert(0,$DataSetType)
        $DataSetType = $DataSetType + ".TypeName"
        $APIObject.PSObject.TypeNames.Insert(0,$DataSetType)
    }
    else
    {
        $APIObject = $ResponseObject
        $DataSetType = "NimbleStorage.Messages"
        $APIObject.PSTypeNames.Insert(0,$DataSetType)
        $DataSetType = $DataSetType + ".TypeName"
        $APIObject.PSObject.TypeNames.Insert(0,$DataSetType)
    }

    return $APIObject
}

function Set-NimbleStorageAPIObject()
{
    param(
        [Parameter(Mandatory=$true)][string] $ObjectName,
        [Parameter(Mandatory=$true)][string] $APIPath,
        [Parameter(Mandatory=$true)][string] $Id,
        [Parameter(Mandatory=$true)][hashtable] $Properties
    )

    $Params = @{
        ResourcePath = $APIPath + "/$Id"
        Method = 'PUT'
        RequestParams = $Properties
    }

    $ResponseObject = (Invoke-NimbleStorageRestAPI @Params)
    $APIObject = $ResponseObject.data
    if ($APIObject)
    {$DataSetType = "NimbleStorage.$ObjectName"
        $APIObject.PSTypeNames.Insert(0,$DataSetType)
        $DataSetType = $DataSetType + ".TypeName"
        $APIObject.PSObject.TypeNames.Insert(0,$DataSetType)
    }
    else
    {
        $APIObject = $ResponseObject
        $DataSetType = "NimbleStorage.Messages"
        $APIObject.PSTypeNames.Insert(0,$DataSetType)
        $DataSetType = $DataSetType + ".TypeName"
        $APIObject.PSObject.TypeNames.Insert(0,$DataSetType)
    }

    return $APIObject
}

function Remove-NimbleStorageAPIObject()
{
    param(
        [Parameter(Mandatory=$true)][string] $ObjectName,
        [Parameter(Mandatory=$true)][string] $APIPath,
        [Parameter(Mandatory=$true)][string] $Id
    )

    $Params = @{
        ResourcePath = $APIPath + "/$Id"
        Method = 'DELETE'
    }

    $APIObject = (Invoke-NimbleStorageRestAPI @Params).data
}

function Invoke-NimbleStorageAPIAction()
{
    param(
        [Parameter(Mandatory=$true)][string] $APIPath,
        [Parameter(Mandatory=$true)][string] $Action,
        [Parameter(Mandatory=$true)][hashtable] $Arguments,
        [Parameter(Mandatory=$true)][string] $ReturnType
    )

    $Params = @{
        ResourcePath = $APIPath + "/actions/$Action"
        Method = 'POST'
        RequestParams = $Arguments
    }

    if ($Arguments.id)
    {
        $id = $($Arguments.id)
        $Params.ResourcePath = $APIPath + "/$id/actions/$Action"
        $Arguments.Remove('id')
    }

    $ResponseObject = (Invoke-NimbleStorageRestAPI @Params)
    if ($ReturnType -eq "void")
    {
        # Return empty object
        return $ResponseObject
    }
    $APIObject = $ResponseObject.data
    $DataSetType = "NimbleStorage.$ReturnType"
    $APIObject.PSTypeNames.Insert(0,$DataSetType)
    $DataSetType = $DataSetType + ".TypeName"
    $APIObject.PSObject.TypeNames.Insert(0,$DataSetType)

    return $APIObject
}
#>

function ValidateServerCertificate() 
{
param(  [Parameter(Mandatory,Position=0)]    [string]$Group )

    $Code = @'
        using System;
        using System.Collections.Generic;
        using System.Net.Http;
        using System.Net.Security;
        using System.Security.Cryptography.X509Certificates;

        namespace CertificateCapture
        {
            public class Utility
            {
                 public static Func<HttpRequestMessage,X509Certificate2,X509Chain,SslPolicyErrors,Boolean> ValidationCallback = 
                    (message, cert, chain, errors) => {
                        var newCert = new X509Certificate2(cert);
                        var newChain = new X509Chain();
                        newChain.Build(newCert);
                        CapturedCertificates.Add(new CapturedCertificate(){
                            Certificate =  newCert,
                            CertificateChain = newChain,
                            PolicyErrors = errors,
                            URI = message.RequestUri
                        });
                        return true; 
                    };
                public static List<CapturedCertificate> CapturedCertificates = new List<CapturedCertificate>();
            }

            public class CapturedCertificate 
            {
                public X509Certificate2 Certificate { get; set; }
                public X509Chain CertificateChain { get; set; }
                public SslPolicyErrors PolicyErrors { get; set; }
                public Uri URI { get; set; }
            }
        }
'@

if ($PSEdition -ne 'Core')
    {   $webrequest=[net.webrequest]::Create("https://$Group")
        try { $response=$webrequest.getresponse() } catch {}
        $cert=$webrequest.servicepoint.certificate
        if($cert -ne $null)
            {   $Thumbprint = $webrequest.ServicePoint.Certificate.GetCertHashString()
                $bytes=$cert.export([security.cryptography.x509certificates.x509contenttype]::cert)
                $tfile=[system.io.path]::getTempFileName()
                set-content -value $bytes -encoding byte -path $tfile
                $certdetails = $cert | select * | ft -AutoSize | Out-String
                if ($($GlobalImportServerCertificate))  
                    {   try     {   $output =import-certificate -filepath $tfile -certStoreLocation 'Cert:\localmachine\Root'
                                    $certdetails = $output | select -Property Thumbprint,subject | ft -AutoSize | Out-String
                                }
                        catch   {   Write-Error "Failed to import the server certificate `n`n $_.Exception.Message"  -ErrorAction Stop
                                }
                        Write-Host "Successfully imported the server certificate `n $certdetails"
                    }
                else{   if((Get-ChildItem -Path Cert:\LocalMachine\root | Where-Object {$_.Thumbprint -eq $Thumbprint}))
                            { 
                            }                
                        else{   write-Error "The security certificate presented by host $Group was not issued by a trusted certificate authority. Please verify the certificate details shown below and use ImportServerCertificate command line parameter to proceed. `n $certdetails `n`n" -ErrorAction Stop 
                            }
                    }
                ResolveIPtoHost $cert.subject $Group
            }
        else{   Write-Error "Failed to import the server certificate `n`n"  -ErrorAction Stop
            }  
    }
else 
    {   Add-Type $Code
        $Certs = [CertificateCapture.Utility]::CapturedCertificates
        $Handler = [System.Net.Http.HttpClientHandler]::new()
        $Handler.ServerCertificateCustomValidationCallback = [CertificateCapture.Utility]::ValidationCallback
        $Client = [System.Net.Http.HttpClient]::new($Handler)
        $Url = "https://$Group"
        $Result = $Client.GetAsync($Url).Result
        $cert= $Certs[-1].Certificate
        if($certs -ne $null)
            {   $certdetails = $cert | select -Property Thumbprint,subject | ft -AutoSize | Out-String
                if ($($GlobalImportServerCertificate))  
                    {   $bytes=$cert.export([security.cryptography.x509certificates.x509contenttype]::cert)
                        $OpenFlags = [System.Security.Cryptography.X509Certificates.OpenFlags]
                        $store = new-object system.security.cryptography.X509Certificates.X509Store -argumentlist "Root","LocalMachine"
                        try{    $Store.Open($OpenFlags::ReadWrite)
                                $Store.Add($Cert)
                                $Store.Close()
                                Write-Host "Successfully imported the server certificate `n $certdetails" 
                            }
                        catch{  write-warning "The Certificate may not match the current DNS record. Please investigate."
                                Write-Error "Failed to import the server certificate `n`n $_.Exception.Message"  -ErrorAction Stop
                            }
                    }
                else
                    {   if((Get-ChildItem -Path Cert:\LocalMachine\root | Where-Object {$_.Thumbprint -eq $cert.Thumbprint}))
                            { 
                            }                
                        else{   write-Error "The security certificate presented by host $Group was not issued by a trusted certificate authority. Please verify the certificate details shown below and use ImportServerCertificate command line parameter to proceed. `n $certdetails `n`n" -ErrorAction Stop 
                            }
                    }
                ResolveIPtoHost $cert.subject $Group
            }
        else{   Write-Error "Failed to import the server certificate `n`n"  -ErrorAction Stop
            }
}
}

function ResolveIPtoHost
{
param(  [Parameter(Mandatory)]      [string]$CertSubject, 
        [Parameter(Mandatory)]      [string]$Group
        )

# we will check if the host name given as input matches the host name in the certificate.
# if IP is given as input and the certificate has hostname (FQDN) then we will use the hostname name but 
# before that we will ensurelookup from hostname to IP works.            
$global:cert_hostname = ($CertSubject.Substring(($CertSubject.IndexOf("=")+1),($CertSubject.IndexOf(",")-3))).trim()            
# check if the input and cert hostname matches, if yes we are good to go
            # Else the input must have ben the IP address, we will if cert hostname can be resolved to match the input hostname (IP).
            if ($Group -ne $cert_hostname)
            {
                # we will look up the DNS to resolve the cert_hostname. 
                # we could do this with either cert hostname or ibput hostname(IP), but cert hostname has better chance of getting resolved.
                
                try
                {
                    $resolved_name = [System.Net.DNS]::GetHostEntry($cert_hostname).AddressList 
                    $resolved_name = $resolved_name | select -ExpandProperty IPAddressToString
                   # $Group = $resolved_name
                    # will come here if the host got resolved.
                    
                     Write-Verbose " $cert_hostname is host-name for provided input $Group IP address"
                    
                    if ($resolved_name -ne $Group)             
                    {
                        # most probably this will not happen, just to be defensive adding this code.
                        # this is the same host as the certificate hostname got resolved to the input hostname(IP)
                        # we  will start using the cert hostname for all the calls from this point in this session.
                        
                        Write-Error "Unable to resolve the certificate hostname to match the provided input hostname/IP. `n`n $_.Exception.Message"  -ErrorAction Stop
                    }
                    else
                    {
                        # we are good to go.
                        Write-Verbose " Resolved name and input name matches: $Group IP address"
                        $global:Group = $cert_hostname
                    }
                }
                catch 
                {   # unable to resolve the cert hostname. Host not reachable. Error out!.
                    Write-Error "Unable to resolve the certificate hostname. Host not reachable. `n`n $_.Exception.Message"  -ErrorAction Stop
                }
            }
            else
            {   # we are good to go.    
                Write-Verbose "Host-name given as input matches with certificate name"
            }
}

Function APIExceptionHandler
{
   #Exception message handle differently for core and non core environment
   #GetResponseStream method does not work in core environment

   if(Get-Member -inputobject $_.Exception.Response -name "GetResponseStream" -Membertype Method)
   {
       $JsonResponse = $_.Exception.Response.GetResponseStream()
       $reader = New-Object System.IO.StreamReader($JsonResponse)
       $reader.BaseStream.Position = 0
       $reader.DiscardBufferedData()
       $responseBody = $reader.ReadToEnd();
       if (($responseBody | ConvertFrom-Json).messages -ne $null)
       {
           foreach( $errorMsg in ($responseBody | ConvertFrom-Json).messages) {
           if($errorMsg.text -ne $null) {$exceptionString += $errorMsg.text + "  "}
       }
       throw [System.Exception] $exceptionString
       }
       else
       {
           throw $_.Exception
       }
   }
   else
   {
        
        $responseBody = $_.ErrorDetails
       if (($responseBody | ConvertFrom-Json).messages -ne $null)
       {
           foreach( $errorMsg in ($responseBody | ConvertFrom-Json).messages) {
           if($errorMsg.text -ne $null) {$exceptionString += $errorMsg.text + "  "}
       }
       throw [System.Exception] $exceptionString
       }
       else
       {
           throw $_.Exception
       }
   }       
}

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEBJ1pmu1bis
# NypsBWRgYoTOASgg05s1tJVQGnNncsbPRJ9qFtP//vs7nhVaU116k+dfxYJMKyN/
# azWH6AjI3u7eoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
# KoZIhvcNAQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExp
# bWl0ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0yMTA1
# MjUwMDAwMDBaFw0yODEyMzEyMzU5NTlaMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AI3nlBIiBCR0Lv8WIwKSirauNoWsR9QjkSs+3H3iMaBRb6yEkeNSirXilt7Qh2Mk
# iYr/7xKTO327toq9vQV/J5trZdOlDGmxvEk5mvFtbqrkoIMn2poNK1DpS1uzuGQ2
# pH5KPalxq2Gzc7M8Cwzv2zNX5b40N+OXG139HxI9ggN25vs/ZtKUMWn6bbM0rMF6
# eNySUPJkx6otBKvDaurgL6en3G7X6P/aIatAv7nuDZ7G2Z6Z78beH6kMdrMnIKHW
# uv2A5wHS7+uCKZVwjf+7Fc/+0Q82oi5PMpB0RmtHNRN3BTNPYy64LeG/ZacEaxjY
# cfrMCPJtiZkQsa3bPizkqhiwxgcBdWfebeljYx42f2mJvqpFPm5aX4+hW8udMIYw
# 6AOzQMYNDzjNZ6hTiPq4MGX6b8fnHbGDdGk+rMRoO7HmZzOatgjggAVIQO72gmRG
# qPVzsAaV8mxln79VWxycVxrHeEZ8cKqUG4IXrIfptskOgRxA1hYXKfxcnBgr6kX1
# 773VZ08oXgXukEx658b00Pz6zT4yRhMgNooE6reqB0acDZM6CWaZWFwpo7kMpjA4
# PNBGNjV8nLruw9X5Cnb6fgUbQMqSNenVetG1fwCuqZCqxX8BnBCxFvzMbhjcb2L+
# plCnuHu4nRU//iAMdcgiWhOVGZAA6RrVwobx447sX/TlAgMBAAGjggESMIIBDjAf
# BgNVHSMEGDAWgBSgEQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUMuuSmv81
# lkgvKEBCcCA2kVwXheYwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEE
# ATBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFD
# ZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAQEA
# Er+h74t0mphEuGlGtaskCgykime4OoG/RYp9UgeojR9OIYU5o2teLSCGvxC4rnk7
# U820+9hEvgbZXGNn1EAWh0SGcirWMhX1EoPC+eFdEUBn9kIncsUj4gI4Gkwg4tsB
# 981GTyaifGbAUTa2iQJUx/xY+2wA7v6Ypi6VoQxTKR9v2BmmT573rAnqXYLGi6+A
# p72BSFKEMdoy7BXkpkw9bDlz1AuFOSDghRpo4adIOKnRNiV3wY0ZFsWITGZ9L2PO
# mOhp36w8qF2dyRxbrtjzL3TPuH7214OdEZZimq5FE9p/3Ef738NSn+YGVemdjPI6
# YlG87CQPKdRYgITkRXta2DCCBeEwggRJoAMCAQICEQCZcNC3tMFYljiPBfASsES3
# MA0GCSqGSIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBD
# QSBSMzYwHhcNMjIwNjA3MDAwMDAwWhcNMjUwNjA2MjM1OTU5WjB3MQswCQYDVQQG
# EwJVUzEOMAwGA1UECAwFVGV4YXMxKzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBF
# bnRlcnByaXNlIENvbXBhbnkxKzApBgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRl
# cnByaXNlIENvbXBhbnkwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCi
# DYlhh47xvo+K16MkvHuwo3XZEL+eEWw4MQEoV7qsa3zqMx1kHryPNwVuZ6bAJ5OY
# oNch6usNWr9MZlcgck0OXnRGrxl2FNNKOqb8TAaoxfrhBSG7eZ1FWNqxJAOlzXjg
# 6KEPNdlhmfVvsSDolVDGr6yEXYK9WVhVtEApyLbSZKLED/0OtRp4CtjacOCF/unb
# vfPZ9KyMVKrCN684Q6BpknKH3ooTZHelvfAzUGbHxfKvq5HnIpONKgFhbpdZXKN7
# kynNjRm/wrzfFlp+m9XANlmDnXieTeKEeI3y3cVxvw9HTGm4yIFt8IS/iiZwsKX6
# Y94RkaDzaGB1fZI19FnRo2Fx9ovz187imiMrpDTsj8Kryl4DMtX7a44c8vORYAWO
# B17CKHt52W+ngHBqEGFtce3KbcmIqAH3cJjZUNWrji8nCuqu2iL2Lq4bjcLMdjqU
# +2Uc00ncGfvP2VG2fY+bx78e47m8IQ2xfzPCEBd8iaVKaOS49ZE47/D9Z8sAVjcC
# AwEAAaOCAYkwggGFMB8GA1UdIwQYMBaAFA8qyyCHKLjsb0iuK1SmKaoXpM0MMB0G
# A1UdDgQWBBRtaOAY0ICfJkfK+mJD1LyzN0wLzjAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBKBgNVHSAEQzBBMDUGDCsG
# AQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQ
# UzAIBgZngQwBBAEwSQYDVR0fBEIwQDA+oDygOoY4aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQVIzNi5jcmwweQYIKwYBBQUH
# AQEEbTBrMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNydDAjBggrBgEFBQcwAYYXaHR0cDov
# L29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggGBACPwE9q/9ANM+zGO
# lq4SZg7qDpsDW09bDbdjyzAmxxJk2GhD35Md0IluPppla98zFjnuXWpVqakGk9vM
# KxiooQ9QVDrKYtx9+S8Qui21kT8Ekhrm+GYecVfkgi4ryyDGY/bWTGtX5Nb5G5Gp
# DZbv6wEuu3TXs6o531lN0xJSWpJmMQ/5Vx8C5ZwRgpELpK8kzeV4/RU5H9P07m8s
# W+cmLx085ndID/FN84WmBWYFUvueR5juEfibuX22EqEuuPBORtQsAERoz9jStyza
# gj6QxPG9C4ItZO5LT+EDcHH9ti6CzxexePIMtzkkVV9HXB6OUjgeu6MbNClduKY4
# qFiutdbVC8VPGncuH2xMxDtZ0+ip5swHvPt/cnrGPMcVSEr68cSlUU26Ln2u/03D
# eZ6b0R3IUdwWf4K/1X6NwOuifwL9gnTM0yKuN8cOwS5SliK9M1SWnF2Xf0/lhEfi
# VVeFlH3kZjp9SP7v2I6MPdI7xtep9THwDnNLptqeF79IYoqT3TCCBhowggQCoAMC
# AQICEGIdbQxSAZ47kHkVIIkhHAowDQYJKoZIhvcNAQEMBQAwVjELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAwMFoXDTM2
# MDMyMTIzNTk1OVowVDELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIENBIFIz
# NjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJsrnVP6NT+OYAZDasDP
# 9X/2yFNTGMjO02x+/FgHlRd5ZTMLER4ARkZsQ3hAyAKwktlQqFZOGP/I+rLSJJmF
# eRno+DYDY1UOAWKA4xjMHY4qF2p9YZWhhbeFpPb09JNqFiTCYy/Rv/zedt4QJuIx
# eFI61tqb7/foXT1/LW2wHyN79FXSYiTxcv+18Irpw+5gcTbXnDOsrSHVJYdPE9s+
# 5iRF2Q/TlnCZGZOcA7n9qudjzeN43OE/TpKF2dGq1mVXn37zK/4oiETkgsyqA5lg
# AQ0c1f1IkOb6rGnhWqkHcxX+HnfKXjVodTmmV52L2UIFsf0l4iQ0UgKJUc2RGarh
# OnG3B++OxR53LPys3J9AnL9o6zlviz5pzsgfrQH4lrtNUz4Qq/Va5MbBwuahTcWk
# 4UxuY+PynPjgw9nV/35gRAhC3L81B3/bIaBb659+Vxn9kT2jUztrkmep/aLb+4xJ
# bKZHyvahAEx2XKHafkeKtjiMqcUf/2BG935A591GsllvWwIDAQABo4IBZDCCAWAw
# HwYDVR0jBBgwFoAUMuuSmv81lkgvKEBCcCA2kVwXheYwHQYDVR0OBBYEFA8qyyCH
# KLjsb0iuK1SmKaoXpM0MMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYEVR0gADAIBgZn
# gQwBBAEwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRv
# MG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAG/4Lhd2M2bnuhFSCb
# E/8E/ph1RGHDVpVx0ZE/haHrQECxyNbgcv2FymQ5PPmNS6Dah66dtgCjBsULYAor
# 5wxxcgEPRl05pZOzI3IEGwwsepp+8iGsLKaVpL3z5CmgELIqmk/Q5zFgR1TSGmxq
# oEEhk60FqONzDn7D8p4W89h8sX+V1imaUb693TGqWp3T32IKGfIgy9jkd7GM7YCa
# 2xulWfQ6E1xZtYNEX/ewGnp9ZeHPsNwwviJMBZL4xVd40uPWUnOJUoSiugaz0yWL
# ODRtQxs5qU6E58KKmfHwJotl5WZ7nIQuDT0mWjwEx7zSM7fs9Tx6N+Q/3+49qTtU
# vAQsrEAxwmzOTJ6Jp6uWmHCgrHW4dHM3ITpvG5Ipy62KyqYovk5O6cC+040Si15K
# JpuQ9VJnbPvqYqfMB9nEKX/d2rd1Q3DiuDexMKCCQdJGpOqUsxLuCOuFOoGbO7Uv
# 3RjUpY39jkkp0a+yls6tN85fJe+Y8voTnbPU1knpy24wUFBkfenBa+pRFHwCBB1Q
# tS+vGNRhsceP3kSPNrrfN2sRzFYsNfrFaWz8YOdU254qNZQfd9O/VjxZ2Gjr3xgA
# NHtM3HxfzPYF6/pKK8EE4dj66qKKtm2DTL1KFCg/OYJyfrdLJq1q2/HXntgr2GVw
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhgwghoUAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQNOXvFSFHhUdK9ogoBomzkAw0Sfxnt8AvwWCm9tvxm2AMz+Fj4Cw4J3G
# h89UE+VE3dkdOgQU5FUEVuJvLTEnVs4wDQYJKoZIhvcNAQEBBQAEggGAlfisOYYG
# Y0jQkafG5A4YfKyCtGoZTQaxKfxOfiYB7DCDM0q976u7QxNSDRvRVOlzz55L2rBv
# 84y61zsGzE6DUfn5c/0EMIIK9tU+hgEFWnSubvCR+BEkeJopFzZj6Mbus7vcw//p
# YgQ3vKPU/52b/l+LXzvMAMu7Oy+aMiOJdwfe+/9bXITS1UGErSSNFEgEGGAlfD1V
# fu1+1nKkMaLIPkRG54b7HWEowh0Dyymn0S1dUo+oZQOg5gRmV4/8/fp1iFYKrYto
# kZLhJhKewDvIc9iJkLTokR7ZTdafejkVwvbNPGte5s9B+KJFo3ACL0o/d3X8AhAZ
# nbaR/OQ6Y7qNQZfdg7DY+Y6Q+dkumfUn51ktsthZyErlA4lvhPy73uHNCBg92rgt
# p1wNjzO6LobkowwQNQmRseFTvtgmFvihPP5ulu0reVV8b3AoJ2cxd+//KVaOg7nc
# V5P5TBCfL4k5vrjbC6gj22Ojn2XoLJK8LZa6XNljObEnfYE/aI6x8usloYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDDmvv2dzaqkykJcLRxZpvV4+3MhMjrW6Ai+vBeb
# NUnVqVLinJvj01sZ1D288Zx7oSoCEQCd4ZsXYaYEqZxXAeUqaDhXGA8yMDI0MDcz
# MTIwMzE1M1qgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVow
# SDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQD
# ExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVY
# wamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isg
# HMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFe
# xAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gp
# OWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28
# mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkH
# NwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58
# ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXH
# g2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W
# 1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK
# 8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn
# 783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+K
# PGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1I
# jrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP
# 2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ
# 5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON
# 1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S
# 88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbU
# uXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145
# WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6
# F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso
# /zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG
# 70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEM
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zC
# pyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf
# 1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x
# 4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEio
# ZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7ax
# xLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZ
# OjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJ
# l2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz
# 2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH
# 4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb
# 5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ
# 9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0g
# ADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs
# 7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq
# 3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/
# Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9
# /HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWoj
# ayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEB
# MHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgIFAKCB4TAaBgkq
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTIw
# MzE1M1owKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEME+bQmLp7Uzxaq0FEovttvAO8v3U
# GQaypK2sYcyh78EIleMoYyQHzq29Wsvt9urj2jANBgkqhkiG9w0BAQEFAASCAgA1
# 0t6hL716bf3qTJzdGgLGYcsjevpBt/Z2EsLXsKMTjo6TETk4SrBgO56Q7ViqRikj
# +rAW6lQcTC7ebd3voEr0bm5SldVqIRQP/77In4hmK9Dk3DjTuipE3m3aMWicfi3I
# mnvx6/Ei7cuvF3QjLCF9jHdw+UoYStfSw1I0JXD0X98KxQfrLMynDH7YqWALs2co
# ZOqJfgvH+BBYOsYX7AkMZGOsqghfMWqHJcySOZk+Gb/++opwCK92Bh3q1J2iw6gL
# PzjZERS/4U1enumgPpj4TcmzjWeKZj4qR5OiWSy97Gsd9gW3hBA5sL46w0sDIkDe
# fibC4lzb4xVRe56WEd/UMbgpeO1riu9UpUqjKwZL5gM/2q75fRgP4iFPciiaDgYN
# lsMCLKAZLEKUO+N0wVlv6lzPzLshqwmwatczJa84Z4iYmGDlakxl/9SmBoLAuWxJ
# oELC0FBJxFTXai+o9D+lyyxHnrJnMkZE10s2dsm7Mzrne6N9pz6SNvgNoIW5sbZz
# j9wBlYfdA3EwWL0cwZSgPbn/LaJROOWCZDjSa8WxLxkZYDhcb9sBFtdDbYCcMpiI
# MT7U5cZGLXplnPF8focQHDzHYRoxQ7HhCoYHuKB8oQRR8cBPG9dW5cLirqEf1X0I
# k6IWp7BduxCGCkoXQwqWpQZmpZtLb0jG0udWBjZiqg==
# SIG # End signature block
