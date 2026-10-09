# Source the Private files
Get-ChildItem -Path "$PSScriptRoot/Private" -Filter *.ps1 | ForEach-Object {
	. $_.FullName
}

# Source the Public files and export
Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 | ForEach-Object {
	. $_.FullName
}
