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
