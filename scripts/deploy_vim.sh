#!/bin/sh

# This script to config nvim

vim_plug_path="~/.local/share/nvim/site/autoload"

if [ -f "$vim_plug_path" ]; then
    echo "vim-plug is already installed."
else
    echo "install vim-plug"
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # Automatically install plugins
    echo "install plugins"
    nvim -u ~/.config/nvim/init.vim +PlugInstall +qall
    nvim -u ~/.config/nvim/init.vim +UpdateRemotePlugins +qall
fi

echo "####################"
echo "config nvim done!"
echo "####################"
echo ""