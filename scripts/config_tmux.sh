#!/bin/sh

# This script to config tmux

# if tpm is not installed, install it.
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "install tpm"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# installing plugins
echo "install plugins"
tmux new-session -d
tmux source ~/.tmux.conf
~/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-server

echo "####################"
echo "config tmux done!"
echo "####################"
echo ""