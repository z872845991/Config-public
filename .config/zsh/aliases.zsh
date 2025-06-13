alias ra="ranger"
alias lz="lazygit"
alias rg="rg --sort path"
alias tsb="trans :zh -shell -brief"
alias ts="trans :zh -shell"
alias xp="xclip -selection clipboard"
alias lls="logo-ls"
alias td="todoist-cli q"
unalias z
z() {
  cd "$(zshz -l 2>&1 | sed 's/^[0-9,.]* *//' | fzf -q "$_last_z_args")"
}
