# © Copyright 2022 Hewlett Packard Enterprise Development LP

# NimPowerShellToolkit Module manifest
@{      RootModule = 'HPEA6NS.psm1'
        ModuleVersion = '3.5.0'
        CompanyName = 'HPE Storage, A Hewlett Packard Enterprise Company'
        Copyright = '© Copyright 2021 Hewlett Packard Enterprise Development LP'
        PowerShellVersion = '5.0'
        FormatsToProcess = 'Formatters/HPEA6NS.format.ps1xml'
        GUID = 'ebdcec82-0636-499c-a1a8-0ed13b843e2d'
        Author = 'Hewlett Packard Enterprise Co.'
	Description = 'Windows PowerShell Scripting Toolkit for HPE Alletra 6000 and Nimble Arrays'
	FileList = @()
	ScriptsToProcess = @()
	FunctionsToExport = '*'
	CmdletsToExport = '*'
	VariablesToExport = '*'
	PrivateData = @{
                PSData = @{     # Tags applied to this module. These help with module discovery in online galleries.
                        Tags = @('Hewlett','Packard','Enterprise','HPEAlletra6000andNimbleStoragePowerShellToolkit','HPE')
                        ProjectUri = 'https://github.com/HewlettPackard/HPEStoragePowerShellToolkit/'
                        ReleaseNotes = 'Please see the ReadMe.MD and the Changes_*.MD in this modules root directory.'
			} 
		} 
}