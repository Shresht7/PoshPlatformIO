# PoshPlatformIO module entry point
$Script:ModuleRoot = $PSScriptRoot

# Source the Private files
Get-ChildItem -Path "$PSScriptRoot/Private" -Filter *.ps1 | ForEach-Object {
	. $_.FullName
}

# Source the Public files
Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 | ForEach-Object {
	. $_.FullName
}

# Pre-build the completion index on import, if required, so that tab-completion is available immediately
try {
	$null = Get-PoshPlatformIOIndex
}
catch {
	Write-Verbose "Failed to pre-build the completion index: $_"
}
