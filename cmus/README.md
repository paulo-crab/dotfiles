# cmus themes

This directory includes 256-color cmus themes for all four [Catppuccin](https://github.com/catppuccin/palette) flavours: Latte, Frappé, Macchiato, and Mocha. The colours approximate the official hex palette within the terminal's 256-colour palette.

Run `./setup-themes.zsh` to install these themes alongside the [johnnymatthews/cmus-themes](https://github.com/johnnymatthews/cmus-themes) collection. The script copies `.theme` files into `${CMUS_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/cmus}`.

Select a theme inside cmus with `:colorscheme catppuccin-mocha`, replacing `mocha` with `latte`, `frappe`, or `macchiato`. To make one persistent, add `colorscheme catppuccin-mocha` to your cmus `rc` file. cmus saves colours in its autosave file, so reselect a theme after changing its `.theme` file.
