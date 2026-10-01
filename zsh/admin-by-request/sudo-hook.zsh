# Source this file from an interactive zsh configuration.
typeset -g _abr_sudo_helper="${${(%):-%x}:A:h}/before-sudo.applescript"

function sudo {
  # Standalone help/version/cache commands do not need a new admin session.
  if (( $# == 0 )); then
    /usr/bin/sudo "$@"
    return
  fi
  if (( $# == 1 )); then
    case "$1" in
      -h|--help|-V|--version|-k|-K)
        /usr/bin/sudo "$@"
        return
        ;;
    esac
  fi

  /usr/bin/osascript "$_abr_sudo_helper" >/dev/null || return
  /usr/bin/sudo "$@"
}
