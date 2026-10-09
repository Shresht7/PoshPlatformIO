# Maps canonical option names to dynamic value provider functions.
# The completer dispatches to these when an option has no static 'choices'.
$Script:PlatformIOValueProviders = @{
    '--environment' = 'Get-PlatformIOEnvironmentNames'
}
