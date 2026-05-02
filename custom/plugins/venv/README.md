# venv

A zsh plugin that detects Python virtual environments along the path of the
current working directory and offers to activate them. When you leave the
directory tree of a venv this plugin activated, it is deactivated automatically.

The plugin looks for a directory named `venv`, `virtualenv`, `.venv`, or
`.virtualenv` that lives as a child of an ancestor of `$PWD` and contains a
`bin/activate` script. Bare `env` / `.env` are intentionally not matched
since `.env` is overwhelmingly used as a dotenv file.

## Behavior

- On `cd` (and once at shell startup) the nearest matching venv is detected.
- If no venv is currently active, you are prompted to activate it. Pressing
  Enter accepts the default (Yes). Press `n` to decline; you will not be
  re-prompted for that same venv until you leave its tree. Press `d` to
  disable auto-activation entirely until you re-enable it.
- If you decline, an `activate` function is left in scope so you can run
  `activate` later to load it.
- When you leave the tree of a venv this plugin activated, it is deactivated
  automatically. Environments you activated yourself (with `source ...` or
  outside the plugin) are never touched.

## Toggling auto-activation

Use `autovenv` to control the prompting hook:

```
autovenv          # status
autovenv disable  # stop prompting / auto-deactivating
autovenv enable   # resume (and re-check the current directory)
```

Pressing `d` at the activation prompt is a shortcut for `autovenv disable`.

## Installation

Add `venv` to the plugins array in your `.zshrc`:

```
plugins=(... venv)
```

## Creating a venv

The plugin also provides a `venv` command:

```
venv             # creates ./.venv
venv myenv       # creates ./myenv
```

It runs `python3 -m venv` and then offers to activate the new environment.
