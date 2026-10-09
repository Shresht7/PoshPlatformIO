<#
.SYNOPSIS
    Retrieves the names of the environments defined in the PlatformIO project configuration file (platformio.ini)
.DESCRIPTION
    This function reads the PlatformIO project configuration file (platformio.ini) 
    and extracts the names of all defined environments
    along with their platform, board, and framework details for completions sake.
.OUTPUTS
    Objects with Value and Tooltip properties representing the environment names and their details.
#>
function Get-PlatformIOEnvironmentNames {

    [CmdletBinding()]
    param(
        # Context assembled by the completer (ProjectDir/ProjectConf)
        [hashtable] $Context = @{}
    )

    # Determine the path to the platformio.ini file based on the provided context
    $ini = if ($Context.ProjectConf) { $Context.ProjectConf }
    elseif ($Context.ProjectDir) { Join-Path $Context.ProjectDir 'platformio.ini' }
    else { Join-Path $PWD.ProviderPath 'platformio.ini' }

    # Return if the platformio.ini file does not exist
    if (-not (Test-Path -LiteralPath $ini)) { return }

    $envs = [ordered]@{}
    $currentEnv = $null

    foreach ($line in Get-Content -LiteralPath $ini) {
        $trimmedLine = $line.Trim()

        # Skip empty lines and comments
        if (-not $trimmedLine -or $trimmedLine.StartsWith(';') -or $trimmedLine.StartsWith('#')) { continue }

        # Match lines that define an environment section, e.g., [env:uno]
        if ($trimmedLine -match '^\[env:(?<name>.*)\]$') {
            $currentEnv = $Matches['name'].Trim()
            $envs[$currentEnv] = [ordered]@{
                platform  = $null;
                board     = $null;
                framework = $null;
            }
        }
        # Match key-value pairs within the current environment section
        elseif ($currentEnv -and -not $trimmedLine.StartsWith('[') -and $trimmedLine -match '^(?<key>[^=\s]+)\s*=\s*(?<value>.*)$') {
            $key = $Matches['key'].ToLowerInvariant()
            if ($envs[$currentEnv].Contains($key)) {
                $envs[$currentEnv][$key] = $Matches['value'].Trim()
            }
        }
    }

    # Output the collected environment names and their details
    foreach ($entry in $envs.GetEnumerator()) {
        [PSCustomObject]@{
            Value   = $entry.Key
            Tooltip = (@(
                    if ($entry.Value.platform) { "platform = $($entry.Value.platform)" }
                    if ($entry.Value.board) { "board = $($entry.Value.board)" }
                    if ($entry.Value.framework) { "framework = $($entry.Value.framework)" }
                ) -join ', ')
        }
    }
}
