# add some config to ~/.zshrc
sed -i '1i\if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then\n  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"\nfi' ~/.zshrc
sed -i '1i\export LC_LANG=en_US.UTF-8' ~/.zshrc
sed -i '1i\export LC_CTYPE=en_US.UTF-8' ~/.zshrc
sed -i 's/bindkey -e/bindkey -v/' ~/.zshrc
sed -i '$ a\ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc
sed -i '$ a\eval "$(dircolors ~/.dir_colors)"' ~/.zshrc
sed -i '$ a\setopt nonomatch' ~/.zshrc
sed -i '$ a\setopt globdots' ~/.zshrc
sed -i '$ a\alias ra="ranger"' ~/.zshrc
sed -i '$ a\alias lz="lazygit"' ~/.zshrc
sed -i '$ a\alias rg="rg --sort path"' ~/.zshrc
sed -i '$ a\alias tsb="trans :zh -shell -brief"' ~/.zshrc
sed -i '$ a\alias ts="trans :zh -shell"' ~/.zshrc
sed -i '$ a\alias xp="xclip -selection clipboard"' ~/.zshrc
sed -i '$ a\alias lls="logo-ls"' ~/.zshrc
sed -i '$ a\alias grub2-theme-preview="/home/jesse/.local/bin/grub2-theme-preview"' ~/.zshrc
sed -i '$ a\[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' ~/.zshrc
