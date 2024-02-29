# © Copyright 2023 Hewlett Packard Enterprise Development LP

# HPE MSA PowerShell Toolkit Module manifest
@{ 	RootModule = 'HPEMSA.psm1'
	ModuleVersion = '0.9.0'
	CompanyName = 'Hewlett Packard Enterprise Company'
	Copyright = '© Copyright 2023 Hewlett Packard Enterprise Development LP'
	PowerShellVersion = '3.0'
	GUID = 'aadcec82-0636-499c-a1a8-0ed13b863e2d'
	Author = 'Hewlett Packard Enterprise Co.'
	Description = 'Windows PowerShell Scripting Toolkit for MSA Array'
	FileList = @()
	FormatsToProcess = 'Formatters/HPEMSA.format.ps1xml'          	
	ScriptsToProcess = @()     
	FunctionsToExport = '*'   
	CmdletsToExport = '*'       
	VariablesToExport = '*'    
	PrivateData = @{
                    PSData = @{ Tags = @('Hewlett','Packard','Enterprise','HPEMSA','HPE','MSA')		
                                ReleaseNotes = 'See the ReadMe.txt packaged with the module'
							}   
					} 
}
