#!/usr/bin/env zsh
set -euo pipefail

# Load env variables
source "$(dirname "$0")/zsh/env.sh"

REPO_DIR=$PWD
BACKUP_SUFFIX=".before-dotfiles.$(date +%Y%m%d-%H%M%S)"

link() {
  local source_path="$1"
  local destination_path="$2"

  mkdir -p "${destination_path:h}"

  if [[ -L "$destination_path" ]]; then
    rm "$destination_path"
  elif [[ -e "$destination_path" ]]; then
    mv "$destination_path" "${destination_path}${BACKUP_SUFFIX}"
    echo "Backed up: $destination_path"
  fi

  ln -s "$source_path" "$destination_path"
  echo "Linked: $destination_path → $source_path"
}

link "$REPO_DIR/home/.zshenv" "$HOME/.zshenv"
link "$REPO_DIR/zsh" "$HOME/.config/zsh"
link "$REPO_DIR/nvim" "$HOME/.config/nvim"
link "$REPO_DIR/starship.toml" "$HOME/.config/starship.toml"

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Homebrew installation could not be found."
  exit 1
fi

if [[ -f "$REPO_DIR/brew/Brewfile" ]]; then
  brew bundle --file="$REPO_DIR/brew/Brewfile"
fi

if [[ -L "$XDG_CONFIG_HOME/eza/theme.yml" ]]; then
    echo "eza theme is already set up"
else    
    echo "Setting up eza theme: $THEME"
    zsh "$REPO_DIR/eza/setup.zsh"
fi
