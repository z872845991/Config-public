command -v yazi >/dev/null 2>&1 && alias ra="yazi"
command -v lazygit >/dev/null 2>&1 && alias lz="lazygit"
command -v eza >/dev/null 2>&1 && alias lls="eza --sort type"
alias rg="rg --sort path"
alias tsb="trans :zh -shell -brief"
alias ts="trans :zh -shell"
alias xp="xclip -selection clipboard"
alias td="todoist-cli q"

unalias z 2>/dev/null

z() {
  command -v zshz >/dev/null 2>&1 || return 1
  command -v fzf >/dev/null 2>&1 || return 1

  local dest
  dest="$(zshz -l 2>/dev/null | sed 's/^[0-9,.]* *//' | fzf -q "${_last_z_args:-}")" || return 0
  [[ -n "$dest" ]] && cd -- "$dest"
}
