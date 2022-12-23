#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 python3Packages.typer python3Packages.ipython python3Packages.rich
# -*- coding: utf-8 -*-
# ===================================================


import os
import json
import pathlib
import platform
import subprocess
import functools
from pprint import pp
from enum import Enum

# smartly tell the user if they're missing typer. this is really
# nice for bootstrapping new environments.
try:
    from typer import Typer
except Exception as e:
    print("Could not import third-party libraries... (are they installed?): ", e)
    os.exit(-1)

EDITOR = os.environ.get("EDITOR", "nvim")
PAGER = os.environ.get("PAGER", "bat")
USER = os.environ.get("USER", "nobody")
HOST = os.environ.get("HOST", "laptop")
SCRIPT = pathlib.Path(__file__).absolute()
REPO = pathlib.Path(__file__).absolute().parent

# prepare our command-line app's options.
cli_opts = dict(no_args_is_help=True)
cli_opts["rich_markup_mode"] = "rich"
cli_opts["add_completion"] = False
cli_opts["help"] = """Interface for managing {REPO}.""".format(**globals())
cli_opts["epilog"] = " ".join([
        "[italic]"
        "I always said I'd replace myself \"with a small Bash script\" ..."
        "I was [bold]so close[/bold]... its Python."
        "[/italic]"
        ])

# define our command-line application.
cli = Typer(**cli_opts)

class Flake:
    _inputs = None
    _outputs = None

    @staticmethod
    def uri():
        return "{}#{}".format(REPO, HOST)

    @classmethod
    def outputs(cls):
        if cls._outputs is None:
            cls._outputs = json.loads(subprocess.getoutput("nix flake metadata --quiet --json {}".format(REPO)))
        return cls._outputs

    @classmethod
    def inputs(cls):
        if cls._inputs is None:
            cls._inputs = json.loads(subprocess.getoutput("nix flake show --quiet --json {}".format(REPO)))
        return cls._inputs


class NixOS:
    class RebuildCommand(Enum):
        Switch = "switch"
        Build = "build"
        DryActivate = "dry-activate"
        DryBuild = "dry-build"
        Test = "test"
        Boot = "boot"
        VmWithBootloader = "build-vm-with-bootloader"

    @cli.command()
    def rebuild(subcmd: RebuildCommand = "build"):
        """Wraps `nixos-rebuild`."""

        return subprocess.run(["nixos-rebuild", "--flake", NixFlake.uri(), subcmd.value])

@cli.command()
def deps():
    """
    prints the system dependencies as reported by nix.
    """
    return subprocess.call(["nix", "flake", "metadata"])


@cli.command()
def outputs():
    """
    prints the system outputs as reported by nix.
    """
    s = _get_flake_stuff()



@cli.command()
def edit(file: str = str(SCRIPT), editor: str = EDITOR):
    """
    quickly open a given file with the default editor; or an editor you
    specify.
    """
    subprocess.call([editor, file])


@cli.command()
def shell():
    """Open interactive IPython shell."""
    import IPython
    import traitlets

    class MyPrompt(IPython.terminal.prompts.Prompts):
        """Custom IPython prompt. Cuz why not?"""
        def in_prompt_tokens(self, cli=None):
            from IPython.terminal.prompts import Token
            prev_ok = self.shell.last_execution_succeeded
            return [
                (Token.OutPrompt, f"{SCRIPT.parent.stem}"),
                (Token.Name.Entity, f" {SCRIPT.name}"),
                (Token.Name.Class, f" v{platform.python_version()}"),
                (Token.Prompt, f" ©{USER}"),
                (Token.Prompt if prev_ok else Token.Generic.Error, "\n❯ "),
            ]

        def out_prompt_tokens(self, cli=None):
            return []

    cfg = traitlets.config.loader.Config()
    # cfg.InteractiveShellApp.exec_lines = list()
    # cfg.InteractiveShellApp.exec_lines.append('import math')
    cfg.HistManager.hist_file = ":memory:"
    cfg.IPCompleter.omit__names = 1
    cfg.InteractiveShell.ast_node_interactivity = "last_expr_or_assign"
    cfg.InteractiveShell.auto_match = True
    cfg.InteractiveShell.autoawait = True
    cfg.InteractiveShell.autocall = 2
    cfg.InteractiveShell.autoformatter = "yapf"
    cfg.InteractiveShell.banner1 = f"{SCRIPT.name} shell: 👋{USER}"
    cfg.InteractiveShell.banner2 = ""
    cfg.InteractiveShell.confirm_exit = False
    cfg.InteractiveShell.display_page = False
    cfg.InteractiveShell.editing_mode = "emacs"
    cfg.InteractiveShell.editor = EDITOR
    cfg.InteractiveShell.emacs_bindings_in_vi_insert_mode = True
    cfg.InteractiveShell.extra_open_editor_shortcuts = True
    cfg.InteractiveShell.mouse_support = False
    cfg.InteractiveShell.quiet = False
    cfg.InteractiveShell.separate_in = "\\n"
    cfg.InteractiveShell.separate_out = ""
    cfg.InteractiveShell.term_title = True
    cfg.TerminalInteractiveShell.highlighting_style = "dracula"
    cfg.InteractiveShell.term_title_format = f"{SCRIPT.name} shell"
    cfg.InteractiveShell.true_color = True
    cfg.StoreMagics.autorestore = False
    cfg.TerminalIPythonApp.display_banner = True
    cfg.TerminalIPythonApp.exec_PYTHONSTARTUP = True
    cfg.TerminalIPythonApp.quick = False
    cfg.TerminalInteractiveShell.confirm_exit = False
    cfg.TerminalInteractiveShell.colors = "Linux"
    cfg.TerminalInteractiveShell.prompts_class = MyPrompt
    cfg.InteractiveShellApp.exec_lines = [
        "import os, sys, json, inspect, IPython, math",
        "from os import environ",
        "from pprint import pp",
        "from pathlib import Path",
    ]
    ipy_args = dict(config=cfg, argv=[], user_ns=globals())
    return IPython.start_ipython(**ipy_args)


if __name__ == "__main__":
    # ensure the script is always run from the repo's directory.
    os.chdir(REPO)
    # finally, execute the finished command-line application.
    cli()
