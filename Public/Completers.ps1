$Script:PlatformIOCompleter = {
    param($wordToComplete, $commandAst, $cursorPosition)

    # Everything you typed up to the cursor as plain strings
    $words = @(
        $commandAst.CommandElements |
        Where-Object { $_.Extent.StartOffset -lt $cursorPosition } |
        ForEach-Object { $_.Extent.Text }
    )

    $name = [IO.Path]::GetFileNameWithoutExtension($words[0]).ToLower()
    if ($name -notin 'pio', 'platformio') { return } # Only provide completions for `pio` or `platformio` commands

    # Drop the program name, and the word being completed
    $typed = @($words | Select-Object -Skip 1)
    if ($wordToComplete -ne '' -and $typed.Count -gt 0) {
        $typed = @($typed | Select-object -SkipLast 1)
    }

    try {
        $results = Get-PlatformIOCompletion -Typed $typed -Current $wordToComplete
    }
    catch {
        return # Failed to get completions
    }

    foreach ($r in $results) {
        $tooltip = if ($r.Tooltip) { $r.Tooltip } else { $r.Value }
        [System.Management.Automation.CompletionResult]::new($r.Value, $r.Value, 'ParameterValue', $tooltip)
    }
}

# Register the argument completer for `pio` and `platformio` commands
Register-ArgumentCompleter -Native -CommandName 'pio', 'platformio' -ScriptBlock $Script:PlatformIOCompleter
