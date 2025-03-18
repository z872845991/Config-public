export PLUG_DIR=$HOME/.zim
if [[ ! -d $PLUG_DIR ]]; then
	curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
	rm ~/.zimrc
	ln -s ~/.config/zsh/zimrc ~/.zimrc
	zimfw install
fi

if [[ ! -d $HOME/.fzf ]]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	$HOME/.fzf/install
fi


