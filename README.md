# `PoshPlatformIO`

PowerShell Tab-Completions for the [PlatformIO][PlatformIO] CLI (`pio`/`platformio`)

---

## Requirements

- PowerShell 7.0+
- PlatformIO
  
## Install

```powershell
Import-Module ./PoshPlatformIO.psd1
```

The command index builds automatically on import, so tab completion should work immediately.
Run `Update-PoshPlatformIOIndex` to rebuild it if necessary.

## Usage

Type a `pio` or `platformio` command and press <kbd>Tab</kbd> to complete subcommands, options and option values:

```powershell
pio <Tab>                       # completes subcommands
platformio run -e <Tab>         # completes environment names
pio project init --board <Tab>  # completes board names
```

## How it works

[`Scripts/scan-cli.py`](Scripts/scan-cli.py) uses PlatformIO's own environment and python interpreter to walk the CLI command tree and emits a JSON representation of it, which is cached under `$Env:LOCALAPPDATA\PoshPlatformIO` on Windows, or `$XDG_CACHE_HOME/PoshPlatformIO` or `~/.cache/PoshPlatformIO` on Linux. The index is rebuilt when missing or when the installed version changes.

Options with no fixed value list (`-e/--environment`, `-b/--board`) are completed dynamically at runtime using the registered value providers.

## Related

- [PlatformIO][PlatformIO]
- [PlatformIO Documentation][PlatformIO-Docs]
- [PlatformIO Core (GitHub)][PlatformIO-Core-GitHub]

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.



[PlatformIO]: https://platformio.org/
[PlatformIO-Docs]: https://docs.platformio.org/
[PlatformIO-Core-GitHub]: https://github.com/platformio/platformio-core
