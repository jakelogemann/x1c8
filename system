#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 python3Packages.typer python3Packages.ipython
# -*- coding: utf-8 -*-
# ===================================================
# Quick Setup:
#  - copy this script to somewhere on your $PATH and mark it executable.
#  - `pip install -U "typer[all]" IPython requests`
#
# ===================================================

__doc__ = """An example app.

I always said I'd replace myself with a "small bash script"; I was so close. I
should have known it'd be python...
"""

import os
import pathlib
import platform
import subprocess

EDITOR = os.environ.get("EDITOR", "nvim")
PAGER = os.environ.get("PAGER", "bat")
USER = os.environ.get("USER", "nobody")
SCRIPT = pathlib.Path(__file__).absolute()


def say(something: str):
    """
    say something!
    """
    print(f"I say: {something}")


def edit(file: str = str(SCRIPT), editor: str = EDITOR):
    """
    quickly open a given file with the default editor; or an editor you
    specify.
    """
    subprocess.call([editor, file])


def cat(file: str = str(SCRIPT), pager: str = PAGER):
    """
    quickly print a given file with the default pager; or a pager you
    specify.
    """
    subprocess.call([pager, file])


def shell():
    """
    Open an interactive IPython REPL to "play" with this CLI.
    """
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


def main():
    """main entrypoint to the command-line application."""
    # smartly tell the user if they're missing typer. this is really
    # nice for bootstrapping new environments.
    try:
        from typer import Typer
    except Exception as e:
        print("Could not import typer (is it installed?): ", e)
        return None
    # define our command-line application.
    cli = Typer(help=__doc__, no_args_is_help=True)
    # add all commands to the command-line application we defined.
    for cmd in [say, edit, cat, shell]:
        cli.command()(cmd)
    # finally, execute the finished command-line application.
    return cli()


if __name__ == "__main__":
    main()
