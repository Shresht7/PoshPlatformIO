<#
.SYNOPSIS
    Rebuilds the cached index of PlatformIO's commands and options.
.DESCRIPTION
    Runs the `scan-cli.py` script with PlatformIO's own Python interpreter and stores the
    resulting dictionary with the PlatformIO version it was built from.
#>
function Update-PoshPlatformIOIndex {
    $python = Get-PlatformIOExe -Name python
    $scanner = Join-Path $Script:ModuleRoot 'Scripts/scan-cli.py'
    $version = Get-PlatformIOVersion

    # Run the scan-cli.py script and capture its output as a JSON string
    $tree = (& $python $scanner) -join ''
    if ($LASTEXITCODE -ne 0 -or -not $tree) {
        throw "scan-cli.py failed (exit code $LASTEXITCODE)"
    }

    # Ensure that the JSON is not malformed
    try {
        $null = $tree | ConvertFrom-Json
    }
    catch {
        throw "scan-cli.py produced invalid JSON: $_"
    }

    # Since the tree should already be valid JSON, we can splice it in directly rather than reparsing and reserializing it
    $envelope = '{"version":' + (ConvertTo-Json $version) + ',"tree":' + $tree + '}'

    $path = Get-PoshPlatformIOIndexPath
    if ($null -eq $path) {
        throw "Failed to determine the path to the PlatformIO index"
    }

    New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null  # Ensure the directory exists

    # Write the JSON envelope to the index file
    $tmp = "$path.tmp"
    [IO.File]::WriteAllText($tmp, $envelope, [Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $tmp -Destination $path -Force

    Write-Verbose "Wrote index for '$version' to '$path'"
}
