<#
.SYNOPSIS
    Gets the PlatformIO core directory
.DESCRIPTION
    This function returns the directory where PlatformIO core is installed. 
	It checks the PLATFORMIO_CORE_DIR environment variable and falls back
	to the default location in the user's home directory if the environment variable is not set.
#>
function Get-PlatformIODir {
	$coreDir = if ($Env:PLATFORMIO_CORE_DIR) { $Env:PLATFORMIO_CORE_DIR } else { Join-Path $HOME ".platformio" }
	return $coreDir
}

<#
.SYNOPSIS
    Gets the PlatformIO scripts directory
.DESCRIPTION
    This function returns the directory where PlatformIO scripts are located.
	It determines the PlatformIO core directory and appends the appropriate subdirectory
	based on the operating system: "penv\Scripts" for Windows and "penv/bin" for other systems.
#>
function Get-PlatformIOScriptsDir {
	[CmdletBinding()]
	param(
		[switch] $IsWindows = $Env:OS -eq "Windows_NT"
	)

	$coreDir = Get-PlatformIODir
	$binDir = if ($IsWindows) {
		Join-Path $coreDir "penv" "Scripts"
	}
 else { 
		Join-Path $coreDir "penv" "bin" 
	}
	return $binDir
}
