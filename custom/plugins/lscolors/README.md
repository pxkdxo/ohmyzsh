# lscolors

This plugin sets the `LS_COLORS` environment variable, which is used by many text-based programs (including `ls`) to enable custom output styles for different file types.

---

## Setting LS_COLORS

### `vivid`

If [`vivid`](https://github.com/sharkdp/vivid), the plugin will use it to generate the value of `LS_COLORS`.

The shell variable `VIVID_THEME` can be set to the name or path of a theme, and if set, it will be passed to `vivid generate` to generate the value of `LS_COLORS`.

If `VIVID_THEME` is not set, the plugin will check for themes at following paths and use the first found:

- `$XDG_CONFIG_HOME/vivid/themes/default.yaml`
- `$XDG_CONFIG_HOME/vivid/theme.yaml`
- `$XDG_CONFIG_HOME/vivid.yaml`

_NOTE: If `XDG_CONFIG_HOME` is empty or unset, the default `~/.config` will be checked instead._

If the variable `VIVID_THEME` is not set and none of these files exist, the plugin will attempt to use [`dircolors`](#./dircolors) to instead.

---

### `dircolors`

Otherwise, we use [`dircolors(1)`](man:dircolors(1)).

The plugin will look for files at the following locations and call `dircolors` with the first one found:

- `$XDG_CONFIG_HOME/dircolors`
- `~/.dircolors`
- `/etc/dircolors`

Of none of these files exist, the plugin will run `dircolors` without a file argument and set `LS_COLORS` default output string.

---

If neither [`vivid`](https://github.com/sharkdp/vivid) or [`dircolors(1)`](man:dircolors(1)) is installed, LS_COLORS will not be set.

---

## See Also

[**dircolors(1)**](man:dircolors(1)), [**ls(1)**](man:ls), [**vivid**](https://github.com/sharkdp/vivid)
