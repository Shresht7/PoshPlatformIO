<#
.SYNOPSIS
    Returns the path to the PoshPlatformIO index.
.DESCRIPTION
    This script retrieves and returns the path to the PoshPlatformIO index cache on the system.
#>
function Get-PoshPlatformIOIndexPath {
    $basePath = if ($Env:OS -eq 'Windows_NT') { $Env:LOCALAPPDATA }
                elseif ($Env:XDG_CACHE_HOME) { $Env:XDG_CACHE_HOME }
                else                          { Join-Path $HOME '.cache' }
    Join-Path (Join-Path $basePath 'PoshPlatformIO') 'index.json'
}
