function Get-WebsiteCertificate {
    param(
        [string]$Url
    )
    try {
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.Timeout = 5000 
        $response = $request.GetResponse()
        $certificate = $request.ServicePoint.Certificate
        $response.Close()
        return $certificate
    }
    catch {
        Write-Error "Failed to retrieve certificate from '$Url': $($_.Exception.Message)"
        return $null
    }
}

$websiteUrl = "https://www.example.com"
$certificate = Get-WebsiteCertificate -Url $websiteUrl

if ($certificate) {
    Write-Output "Certificate for '$websiteUrl':"
    Write-Output "  Subject: $($certificate.Subject)"
    Write-Output "  Issuer: $($certificate.Issuer)"
    Write-Output "  Valid from: $($certificate.NotBefore)"
    Write-Output "  Valid to: $($certificate.NotAfter)"
    Write-Output "  Thumbprint: $($certificate.Thumbprint)"
}

Function Get-RemoteSSLCertificate{
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $ComputerName,

    [int]
    $Port = 443
)

$Certificate = $null
$TcpClient = New-Object -TypeName System.Net.Sockets.TcpClient
try {

    $TcpClient.Connect($ComputerName, $Port)
    $TcpStream = $TcpClient.GetStream()

    $Callback = { param($sender, $cert, $chain, $errors) return $true }

    $SslStream = New-Object -TypeName System.Net.Security.SslStream -ArgumentList @($TcpStream, $true, $Callback)
    try {

        $SslStream.AuthenticateAsClient('')
        $Certificate = $SslStream.RemoteCertificate

    } finally {
        $SslStream.Dispose()
    }

} finally {
    $TcpClient.Dispose()
}

if ($Certificate) {
    if ($Certificate -isnot [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
        $Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $Certificate
    }

    Write-Output $Certificate
}
}

function Get-PublicKey
{
# https://stackoverflow.com/questions/22233702/how-to-download-the-ssl-certificate-from-a-website-using-powershell
[OutputType([System.Security.Cryptography.X509Certificates.X509Certificate])]
PARAM (    [Uri]$Uri   )

    if (-Not ($uri.Scheme -eq "https"))
        {   Write-Error "You can only get keys for https addresses"
            return
        }
    $request = [System.Net.HttpWebRequest]::Create($uri)
    try {   #Make the request but ignore (dispose it) the response, since we only care about the service point
            $request.GetResponse().Dispose()
        }
    catch [System.Net.WebException]
        {   if ($_.Exception.Status -eq [System.Net.WebExceptionStatus]::TrustFailure)
                {   #We ignore trust failures, since we only want the certificate, and the service point is still populated at this point
                }
            else
                {   #Let other exceptions bubble up, or write-error the exception and return from this method
                    throw
                }
        }
    #The ServicePoint object should now contain the Certificate for the site.
    $servicePoint = $request.ServicePoint
    $certificate = $servicePoint.Certificate
    Return $certificate
}

function Test1
{   param ($myuri)
    $request = [System.Net.Sockets.TcpClient]::new($myuri, '443')
    $stream = [System.Net.Security.SslStream]::new($request.GetStream())
    try {   $stream.AuthenticateAsClient($myuri)
        }
    catch{  write-warning  "The Authentication As Client failed."
        }
    if ( $Stream.RemoteCertificate )
        {   return $Stream.RemoteCertificate
        }
    else{   write-warning "The End Device did not respond with a Certificate."
        }
}
