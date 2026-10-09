<#
.SYNOPSIS
	Resolves the full path to the pio and platformio executables
.DESCRIPTION
	Looks on PATH first, then falls back to the PlatformIO's own penv directory (honouring PLATFORMIO_CORE_DIR).
	Results are cached per name.
#>
function Get-PlatformIOExe {
		[CmdletBinding()]
		param(
			[ValidateSet('pio', 'platformio', 'python')]
			[string] $Name = 'pio'
		)

		# Instantiate the cache if not done yet
		if (-not $Script:PioExeCache) {
			$Script:PioExeCache = @{}
		}

		# If we have a valid cached path, return that
		$cached = $Script:PioExeCache[$Name]
		if ($cached -and (Test-Path -LiteralPath $cached)) {
			return $cached
		}

		$path = $null

		# Check PATH environment variable first
		$cmd = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
		if ($cmd) {
			$path = $cmd.Source
		}
		# Fallback to PlatformIO's private Python environment
		else {
			$isWindows = $Env:OS -eq "Windows_NT"
			$binDir = Get-PlatformIOScriptsDir -IsWindows:$isWindows
			$fileName = if ($isWindows) { "$Name.exe" } else { $Name }
			$candidate = Join-Path $binDir $fileName
			if (Test-Path -LiteralPath $candidate) { $path = $candidate }
		}

		if (-not $path) {
			throw "Could not find '$Name' on PATH or in the PlatformIO core directory. Is PlatformIO installed?"
		}

		# Cache the path for subsequent calls
		$Script:PioExeCache[$Name] = $path

		# Return the executable's path
		return $path
}
