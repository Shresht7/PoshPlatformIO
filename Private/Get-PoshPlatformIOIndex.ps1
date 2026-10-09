<#
.SYNOPSIS
    Returns the cached CLI index, loading it once per session.
.DESCRIPTION
    Rebuilds the index if it is missing, unreadable, or was built from a different version of PlatformIO.
#>
function Get-PoshPlatformIOIndex {

    # Return the cached index if it has already been loaded in this session
    if ($Script:PoshPlatformIOIndex) {
        return $Script:PoshPlatformIOIndex
    }

    $path = Get-PoshPlatformIOIndexPath
    $index = $null

    # Attempt to load the existing index from the file if it exists
    if (Test-Path -LiteralPath $path) {
        try { $index = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json }
        catch { $index = $null }
    }

    # Rebuild the index if it is missing, unreadable, or was built from a different version of PlatformIO
    if (-not $index -or $index.version -ne (Get-PlatformIOVersion)) {
        Update-PoshPlatformIOIndex
        $index = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    }

    # Cache the loaded index in the session variable
    $Script:PoshPlatformIOIndex = $index

    return $index
}
