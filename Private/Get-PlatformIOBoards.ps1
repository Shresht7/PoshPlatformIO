function Get-PlatformIOBoards {

    [CmdletBinding()]
    param(
        # The context hashtable containing the project directory and configuration file path
        [hashtable] $Context = @{}
    )

    # Returns the cached board list for this session
    if ($null -ne $Script:PlatformIOBoardsCache) {
        return $Script:PlatformIOBoardsCache
    }

    # If the cache is not available, retrieve the board list from PlatformIO and cache it
    $output = & (Get-PlatformIOExe pio) boards --installed --json-output 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $output) { return } # Failed to get boards

    try {
        $boards = @(($output -join '') | ConvertFrom-Json)
    }
    catch {
        return # Malformed output
    }

    # Dedupe by board id (the same id can exist under several platforms)
    $seen = @{}
    $unique = foreach ($board in $boards) {
        if ($seen.ContainsKey($board.id)) { continue }
        $seen[$board.id] = $true
        [PSCustomObject]@{
            Value   = $board.id
            Tooltip = "$($board.name) $($board.mcu) $($board.platform)"
        }
    }

    # Cache the unique board list for this session
    $Script:PlatformIOBoardsCache = $unique
    return $unique

}

