alias v='nvim'
alias vim='nvim'
alias vi='nvim'
alias ls='eza --color=always --icons=always'
alias ll='eza -l --long --git --color=always --no-permissions --icons=always --no-user --no-time'
alias la='eza -la --long --git --color=always --no-permissions --icons=always --no-user --no-time'
alias tree='eza --tree'
alias cpdir='cp -R'
alias cat='bat'
#alias cd='z'

vc() {
  local file
  file=$(fd --type f --hidden . "$HOME/.config/nvim" | fzf --preview 'bat --color=always --style=numbers --line-range=:200 {}') || return
  nvim "$file"
}

zc() {
  local file
  file=$(fd --type f --hidden --no-ignore . "$ZDOTDIR" | fzf --preview 'bat --color=always --style=numbers --line-range=:200 {}') || return
  nvim "$file"
}
