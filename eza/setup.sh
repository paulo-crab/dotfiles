theme=$THEME

echo("Setting eza theme to: $THEME")

export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"

themes_dir="$XDG_DATA_HOME/eza-themes"
eza_config_dir="$XDG_CONFIG_HOME/eza"

if [[ ! -d "$themes_dir/.git" ]]; then
  git clone https://github.com/eza-community/eza-themes.git "$themes_dir"
fi

mkdir -p "$eza_config_dir"


ln -sf \
  "$themes_dir/themes/${theme}.yml" \
  "$eza_config_dir/theme.yml"
