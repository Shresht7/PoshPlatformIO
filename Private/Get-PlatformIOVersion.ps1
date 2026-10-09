<#
.SYNOPSIS
    Returns the version of PlatformIO installed on the system.
.DESCRIPTION
    This script retrieves and returns the version of PlatformIO installed on the system.
    As printed by `platformio --version`
#>
function Get-PlatformIOVersion {
    $output = & (Get-PlatformIOExe -Name platformio) --version 2>$null

    if ($LASTEXITCODE -ne 0 -or -not $output) {
        throw "Could not determine the PlatformIO version"
    }

    return ($output -join ' ').Trim()
}
