export LANG="en_US.UTF-8"
export LANGUAGE="en_US"
export XDG_CONFIG_HOME="$HOME/.config"
export GOPATH="$HOME/go"
export EDITOR="nvim"
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# PATH: prepend high-priority, append low-priority
path=(
  $HOME/.local/bin
  $path
  /usr/local/bin
  $HOME/go/bin
  $HOME/.cargo/bin
)

[[ -d /opt/texlive/2025/bin/x86_64-linux ]] && path+=(/opt/texlive/2025/bin/x86_64-linux)
# Deduplicate PATH entries
typeset -U path
