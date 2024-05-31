@{
    RootModule          = 'HPE3ParPrimeA9_API.psm1'
    ModuleVersion       = '3.5.0.0'
    GUID                = '46a7e8f6-729c-45d0-b979-96c684fb28fe'
    Author              = 'Hewlett Packard Enterprise Development LP'
    CompanyName         = 'Hewlett Packard Enterprise Development LP'
    Copyright           = '© 2020,2021, 2024 Hewlett Packard Enterprise Development LP'
    Description         = 'HPE Alletra 9000 and Primera and 3PAR PowerShell Toolkit provides storage administrators the convenience of managing from a PowerShell environment.'
    PowerShellVersion   = '5.0'
    FunctionsToExport   = '*'
    CmdletsToExport     = '*'
    VariablesToExport   = '*'
    AliasesToExport     = '*'
    PrivateData         = @{
            PSData      = @{    Tags = @('Alletra' , 'Primera' , '3PAR' , 'Nimble', 'MSA') 
                                LicenseUri  = 'https://github.com/HewlettPackard/HPEStoragePowerShellToolkit/blob/main/BSD-3License.txt'
                                ProjectUri  = 'https://github.com/HewlettPackard/HPEStoragePowerShellToolkit/'
                                IconUri     = 'https://github.com/HewlettPackard/HPEStoragePowerShellToolkit/blob/main/hpesm_pri_grn_rev_rgb.png'
                                ReleaseNotes= 'Please see the ReadMe.MD and the Changes.A9.MD in this modules root directory.'
            } 
        } 
}
