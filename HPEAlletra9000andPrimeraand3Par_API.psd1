# Module manifest for module 'HPEStoragePowerShellToolkit'
#
@{
    RootModule = 'HPE3ParPrimeA9_API.psm1'
    ModuleVersion = '3.5.0.0'
    GUID = '46a7e8f6-729c-45d0-b979-96c684fb28fe'
    Author = 'Hewlett Packard Enterprise Development LP'
    CompanyName = 'Hewlett Packard Enterprise Development LP'
    Copyright = '© 2020,2021 Hewlett Packard Enterprise Development LP'
    Description = 'HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit provides storage administrators the convenience of managing from a PowerShell environment.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'
    FunctionsToExport = '*'
    CmdletsToExport = '*'
    VariablesToExport = '*'
    AliasesToExport = '*'
    PrivateData = @{
        PSData = @{     # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Alletra' , 'Primera' , '3PAR' , 'Nimble', 'MSA') 
            LicenseUri = 'https://github.com/HewlettPackard/HPEStoragePowerShellToolkit/blob/main/BSD-3License.txt'
            ProjectUri = 'https://github.com/HewlettPackard/HPEStoragePowerShellToolkit/'

            # IconUri = ''
            ReleaseNotes = 'Please see the ReadMe.MD and the Changes_*.MD in this modules root directory.'
        } 
    } 
    # DefaultCommandPrefix = ''
}

