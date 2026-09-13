#!/bin/bash
set -e

echo "=== Homebrew setup (ZDOTDIR aware) ==="

# --- Determine ZDOTDIR ---
if [[ -n "$ZDOTDIR" ]]; then
  ZDOTDIR_EXISTING=true
else
  ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"
  ZDOTDIR_EXISTING=false
fi

mkdir -p "$ZDOTDIR"

# Optionally export ZDOTDIR in ~/.zprofile if not already set
ZSH_PROFILE="$HOME/.zprofile"
if [[ "$ZDOTDIR_EXISTING" == "false" ]] && ! grep -q "ZDOTDIR" "$ZSH_PROFILE" 2>/dev/null; then
  echo "Setting ZDOTDIR=$ZDOTDIR in $ZSH_PROFILE..."
  {
    echo ""
    echo "# Dotfiles-managed Zsh config"
    echo "export ZDOTDIR=\"$ZDOTDIR\""
    echo "if [[ -f \"\$ZDOTDIR/.zshrc\" ]]; then"
    echo "  source \"\$ZDOTDIR/.zshrc\""
    echo "fi"
  } >> "$ZSH_PROFILE"
fi

# --- Install Homebrew if missing ---
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing..."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ "$(uname -m)" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
  else
    BREW_PREFIX="/usr/local"
  fi

  # Add to current shell environment
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"

  # Write Homebrew config into $ZDOTDIR/env.zsh
  ENV_ZSH="$ZDOTDIR/env.zsh"
  if ! grep -q "brew shellenv" "$ENV_ZSH" 2>/dev/null; then
    echo "Configuring $ENV_ZSH for Homebrew..."
    {
      echo ""
      echo "# Homebrew (managed by dotfiles)"
      echo 'if [[ "$(uname -m)" == "arm64" ]]; then'
      echo '  BREW_PREFIX="/opt/homebrew"'
      echo 'else'
      echo '  BREW_PREFIX="/usr/local"'
      echo 'fi'
      echo 'eval "$(${BREW_PREFIX}/bin/brew shellenv)"'
    } >> "$ENV_ZSH"
  fi
else
  echo "Homebrew already installed."
fi

# Ensure brew is on PATH in this script
if [[ "$(uname -m)" == "arm64" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
else
  export PATH="/usr/local/bin:$PATH"
fi
