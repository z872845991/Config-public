export PLUG_DIR=$HOME/.zim
if [[ ! -d $PLUG_DIR ]]; then
    if [[ -f ~/.zim ]]; then
        rm ~/.zimrc
    fi
	ln -s ~/.config/zsh/zimrc ~/.zimrc
	curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
fi

if [[ ! -d $HOME/.fzf ]]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	$HOME/.fzf/install
fi


