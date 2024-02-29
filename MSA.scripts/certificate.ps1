function Get-MSACertificate
{
<#
.SYNOPSIS
    Shows the status of the system's security certificate.
.DESCRIPTION
    Shows the status of the system's security certificate.
.EXAMPLE
    PS:> Get-MSACertificate

    object-name                : certificate-status
    meta                       : /meta/certificate-status
    controller                 : A
    controller-numeric         : 1
    certificate-status         : Customer-supplied
    certificate-status-numeric : 8286
    certificate-time           : 2022-06-04 01:06:27
    certificate-signature      : 29:C6:8B:80:3C:BF:E6:17:31:9F:94:7E:77:BE:89:A5:9C:F7:53:1F
    certificate-text           : Certificate:\n    Data:\n        Version: 1 (0x0)\n        Serial Number:\n            ba:90:62:6d:9e:20:11:65\n    Signature Algorithm:
                                sha256WithRSAEncryption\n        Issuer: C=US, ST=WA, L=Seattle, O=HPE, CN=HPEMSA2060A.mgmt\n        Validity\n            Not Before: Jun  4
                                01:06:27 2022 GMT\n            Not After : Jun  1 01:06:27 2032 GMT\n        Subject: C=US, ST=WA, L=Seattle, O=HPE, CN=HPEMSA2060A.mgmt\n
                                Subject Public Key Info:\n            Public Key Algorithm: rsaEncryption\n                Public-Key: (2048 bit)\n                Modulus:\n
                                00:c9:96:58:ad:5b:d3:cf:30:d1:57:0a:36:4e:9b:\n                    17:1c:f3:3d:41:b4:79:f3:13:66:a6:f9:97:f2:71:\n
                                28:bf:e1:08:09:02:73:8d:a2:b1:5d:b5:bb:02:2d:\n                    72:a5\n                Exponent: 65537 (0x10001)\n    Signature Algorithm:
                                sha256WithRSAEncryption\n         7c:20:3c:6a:d8:29:35:0b:e6:66:3a:6f:a1:f5:66:81:ad:98:\n
                                68:30:d2:64:e8:59:12:d2:ad:da:6e:13:f2:d8:a2:37:2c:2a:\n         70:f9:ca:52:5f:82:7e:53:63:15:cf:ae:e3:d1:2a:a7:24:e8:\n
                                45:3e:d5:75:78:8e:67:6e:76:8a:6c:6b:82:7c:3d:b6:0a:35:\n         25:57:fa:ee\n

    object-name                : certificate-status
    meta                       : /meta/certificate-status
    controller                 : B
    controller-numeric         : 0
    certificate-status         : Customer-supplied
    certificate-status-numeric : 8286
    certificate-time           : 2022-06-04 01:06:29
    certificate-signature      : BC:1B:8D:14:F6:DB:B3:71:0C:06:95:07:3D:0B:A2:FD:A1:84:E5:38
    certificate-text           : Certificate:\n    Data:\n        Version: 1 (0x0)\n        Serial Number:\n            fb:fd:56:03:f8:90:15:02\n    Signature Algorithm:
                                sha256WithRSAEncryption\n        Issuer: C=US, ST=WA, L=Seattle, O=HPE, CN=HPEMSA2060A.mgmt\n        Validity\n            Not Before: Jun  4
                                01:06:29 2022 GMT\n            Not After : Jun  1 01:06:29 2032 GMT\n        Subject: C=US, ST=WA, L=Seattle, O=HPE, CN=HPEMSA2060A.mgmt\n
                                Subject Public Key Info:\n            Public Key Algorithm: rsaEncryption\n                Public-Key: (2048 bit)\n                Modulus:\n
                                            00:c7:48:25:c5:4f:fd:b5:90:05:8b:1a:56:22:8d:\n                    a8:c7:f4:14:65:a9:3f:f9:2a:9a:94:ce:b1:f8:49:\n
                                2a:06:8d:a9:c6:e0:88:34:89:95:f6:47:90:50:c4:\n                    16:86:e9:92:41:a4:8e:a0:32:0c:91:82:fa:6d:e4:\n
                                8a:87:f8:52:b5:cf:ae:75:8d:ed:34:41:e8:f6:4b:\n                    b0:2b\n                Exponent: 65537 (0x10001)\n    Signature Algorithm:
                                sha256WithRSAEncryption\n         7e:97:8d:05:64:c1:78:61:3e:eb:26:44:28:40:54:b2:28:0f:\n
                                47:db:0a:47:27:7f:4a:d1:68:d8:ee:01:61:5e:f7:75:45:20:\n         03:3f:ca:7e:84:65:bf:57:f1:f1:63:85:2d:54:32:c9:fe:c9:\n
                                a7:06:44:66:a5:ed:81:a3:b0:fc:bd:9b:17:14:ed:b6:ee:45:\n         f5:86:bd:91\n

    
#>
    $result = Invoke-MSAStorageRestAPI -noun certificate -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSACipher
{
<#
.SYNOPSIS
    Shows the ciphers that the system is using to securely communicate with hosts.
.DESCRIPTION
    Shows the ciphers that the system is using to securely communicate with hosts.
.EXAMPLE
    PS:> Get-MSACipher

    object-name     meta          ciphers
    -----------     ----          -------
    active-ciphers  /meta/ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:DHE-R…
    user-ciphers    /meta/ciphers
    default-ciphers /meta/ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:DHE-R…

#>
    $result = Invoke-MSAStorageRestAPI -noun 'ciphers' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

function Get-MSAProtocol
{
<#
.SYNOPSIS
    Shows which management services and protocols are enabled or disabled
.DESCRIPTION
    Shows which management services and protocols are enabled or disabled
.EXAMPLE
    PS:> Get-MSAProtocol

    object-name               : services-security-protocols
    meta                      : /meta/security-communications-protocols
    wbi-http                  : Enabled
    wbi-http-numeric          : 1
    wbi-https                 : Enabled
    wbi-https-numeric         : 1
    cli-telnet                : Enabled
    cli-telnet-numeric        : 1
    cli-ssh                   : Enabled
    cli-ssh-numeric           : 1
    smis                      : Enabled
    smis-numeric              : 1
    usmis                     : Disabled
    usmis-numeric             : 0
    slp                       : Enabled
    slp-numeric               : 1
    ftp                       : Disabled
    ftp-numeric               : 0
    sftp                      : Enabled
    sftp-numeric              : 1
    snmp                      : Enabled
    snmp-numeric              : 1
    debug-interface           : Disabled
    debug-interface-numeric   : 0
    inband-ses                : Disabled
    inband-ses-numeric        : 0
    activity-progress         : Disabled
    activity-progress-numeric : 0
#>
    $result = Invoke-MSAStorageRestAPI -noun 'protocols' -verb show
    $objResult = Register-MSAObjectType $result
    return $objResult
}

