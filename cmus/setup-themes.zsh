#!/bin/zsh
set -eu

script_dir=${0:A:h}
config_dir=${CMUS_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/cmus}
mkdir -p "$config_dir"

download_dir=$(mktemp -d)
trap 'rm -rf "$download_dir"' EXIT

git clone --depth 1 https://github.com/johnnymatthews/cmus-themes "$download_dir/cmus-themes"
cp "$download_dir"/cmus-themes/themes/*.theme "$config_dir"/
cp "$script_dir"/catppuccin-*.theme "$config_dir"/
