"""
Walk PlatformIO's Click command tree and print it as JSON.
"""

from __future__ import annotations

import json
import click

# Run with PlatformIO's own interpreter (penv) so that `platformio` is importable
from platformio.__main__ import cli


def first_line(text: str | None) -> str:
    """Helper function to get the first line of the given text"""
    return (text or "").strip().split("\n")[0]


def walk(cmd: click.Command, ctx: click.Context) -> dict:
    """Walk a Click command and return its structure as a dictionary"""

    # Initialize the node dictionary with help text, options, and subcommands
    node = {
        "help": first_line(getattr(cmd, 'short_help', None) or cmd.help),
        "options": [],
        "commands": {},
    }

    # Iterate over the command's parameters
    for param in cmd.params:
        # Skip non-option parameters and hidden options
        if not isinstance(param, click.Option) or getattr(param, 'hidden', False):
            continue

        # Collect information about the option
        node['options'].append({
            "names": list(param.opts) + list(param.secondary_opts),
            "flag": bool(param.is_flag or param.count),
            "choices": list(param.type.choices) if isinstance(param.type, click.Choice) else None,
            "help": first_line(param.help),
        })

    # Click adds --help on top of cmd.params
    node['options'].append({"names": ["--help"], "flag": True, "choices": None, "help": "Show help"})

    # Recurse into subcommands if the command has any
    if hasattr(cmd, 'list_commands'):
        for name in cmd.list_commands(ctx):
            subcmd = cmd.get_command(ctx, name)
            if subcmd is None or getattr(subcmd, 'hidden', False):
                continue
            node['commands'][name] = walk(subcmd, click.Context(subcmd, parent=ctx, info_name=name))

    return node


# ----
# MAIN
# ----

if __name__ == "__main__":
    root_ctx = click.Context(cli, info_name="pio")  # Create the root context for the CLI
    tree = walk(cli, root_ctx)                      # Walk the CLI command tree and store it in a dictionary
    print(json.dumps(tree))                         # Print the command tree as JSON
