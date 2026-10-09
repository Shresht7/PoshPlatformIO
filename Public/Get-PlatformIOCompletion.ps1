<#
.SYNOPSIS
    Works out completions for `pio`/`platformio` from the cached index
.DESCRIPTION
    This function retrieves the cached index of PlatformIO commands and options and provides
    completions for the `pio` or `platformio` CLI based on the current input context.
.OUTPUTS
    Objects with Value and Tooltip. 
    Emits nothing when there is nothing to offer, so PowerShell falls back to its own path completions.
#>
function Get-PlatformIOCompletion {
    [CmdletBinding()]
    param(
        # The already-completed words after the program name
        [string[]] $Typed = @(),

        # The current word being typed ('' if the cursor is on a new word)
        [string] $Current = ''
    )

    $cmp = [StringComparison]::OrdinalIgnoreCase
    $node = (Get-PoshPlatformIOIndex).tree
    $pending = $null    # an option that is still waiting for its value

    # Walk the words already typed to find the command we're completing for
    foreach ($word in $Typed) {
        if ($pending) { $pending; $null; continue } # This word was the option's value
        # Handle options and subcommands
        if ($word.StartsWith('-')) {
            if ($word.Contains('=')) { continue } # --opt=value is self-contained
            $opt = $node.options | Where-Object { $_.names -contains $word } | Select-Object -First 1
            if ($opt -and -not $opt.flag) { $pending = $opt }
        }
        else {
            $sub = $node.commands.PSObject.Properties[$word]
            if ($sub) { $node = $sub.Value }
        }
    }

    # The cursor is on the value of an option
    if ($pending) {
        foreach ($choice in $pending.choices) {
            if ($choice.StartsWith($Current, $cmp)) {
                [PSCustomObject]@{
                    Value   = $choice;
                    Tooltip = $pending.help;
                }
            }
        }
        return
    }

    # The user is typing an option name
    if ($Current.StartsWith('-')) {
        foreach ($opt in $node.options) {
            foreach ($name in $opt.names) {
                if ($name.StartsWith($Current, $cmp)) {
                    [PSCustomObject]@{
                        Value   = $name;
                        Tooltip = $opt.help;
                    }
                }
            }
        }
        return
    }

    # Otherwise offer subcommands (if there are any)
    foreach ($entry in $node.commands.PSObject.Properties) {
        if ($entry.Name.StartsWith($Current, $cmp)) {
            [PSCustomObject]@{
                Value   = $entry.Name;
                Tooltip = $entry.Value.help;
            }
        }
    }
}
