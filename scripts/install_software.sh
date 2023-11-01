#!/bin/sh

# if zsh is not installed, install it.
if [ ! -f "$(whereis zsh | awk '{print $2}')" ]; then
    install_software zsh
    if [ ! -f "$(whereis zsh | awk '{print $2}')" ]; then
        echo "zsh" >> $log_dir/uninstalled_software.logs
    fi
fi
# if git is not installed, install it.
if [ ! -f "$(whereis git | awk '{print $2}')" ]; then
    install_software git
    if [ ! -f "$(whereis git | awk '{print $2}')" ]; then
        echo "git" >> $log_dir/uninstalled_software.logs
    fi
fi
# if wget is not installed, install it.
if [ ! -f "$(whereis wget | awk '{print $2}')" ]; then
    install_software wget
    if [ ! -f "$(whereis wget | awk '{print $2}')" ]; then
        echo "wget" >> $log_dir/uninstalled_software.logs
    fi
fi
# if curl is not installed, install it.
if [ ! -f "$(whereis curl | awk '{print $2}')" ]; then
    install_software curl
    if [ ! -f "$(whereis curl | awk '{print $2}')" ]; then
        echo "curl" >> $log_dir/uninstalled_software.logs
    fi
fi
# if playerctl is not installed, install it.
if [ ! -f "$(whereis playerctl | awk '{print $2}')" ]; then
    install_software playerctl
    if [ ! -f "$(whereis playerctl | awk '{print $2}')" ]; then
        echo "playerctl" >> $log_dir/uninstalled_software.logs
    fi
fi
# if ctags is not installed, install it.
if [ ! -f "$(whereis ctags | awk '{print $2}')" ]; then
    install_software ctags
    if [ ! -f "$(whereis ctags | awk '{print $2}')" ]; then
        echo "ctags" >> $log_dir/uninstalled_software.logs
    fi
fi
# if logo-ls is not installed, install it.
if [ ! -f "/usr/bin/logo-ls" ]; then
    if [ $os = "arch" ]; then
        install_aur_software logo-ls
    else
        wget https://github.com/Yash-Handa/logo-ls/releases/download/v1.3.7/logo-ls_Linux_arm64.tar.gz -O logo-ls.tar.gz
        tar -zxvf logo-ls.tar.gz
        rm -rf logo-ls.tar.gz
        mv logo-ls /usr/bin/
    fi
fi

# if nodejs is not installed, install it.
if [ ! -f "$(whereis node | awk '{print $2}')" ]; then
    install_software nodejs
    if [ ! -f "$(whereis node | awk '{print $2}')" ]; then
        echo "nodejs" >> $log_dir/uninstalled_software.logs
    fi
fi
# if npm is not installed, install it.
if [ ! -f "$(whereis npm | awk '{print $2}')" ]; then
    install_software npm
    if [ ! -f "$(whereis npm | awk '{print $2}')" ]; then
        echo "npm" >> $log_dir/uninstalled_software.logs
    fi
    sudo npm install -g n
    sudo n lts
fi
# if yarn is not installed, install it.
if [ ! -f "$(whereis yarn | awk '{print $2}')" ]; then
    sudo npm install -g yarn
    if [ ! -f "$(whereis yarn | awk '{print $2}')" ]; then
        echo "yarn" >> $log_dir/uninstalled_software.logs
    fi
fi

# if picgo is not installed, install it.
if [ ! -f "$(whereis picgo | awk '{print $2}')" ]; then
    sudo npm install -g picgo
    if [ ! -f "$(whereis picgo | awk '{print $2}')" ]; then
        echo "picgo" >> $log_dir/uninstalled_software.logs
    fi
fi

# if nvim is not installed, install it.
if [ ! -f "$(whereis nvim | awk '{print $2}')" ]; then
    if [ $os = "arch" ]; then
        install_software neovim
    elif [ $os = "ubuntu" ]; then
        install_software software-properties-common
        sudo add-apt-repository ppa:neovim-ppa/stable
        sudo apt update
        install_software neovim
    fi
    if [ ! -f "$(whereis nvim | awk '{print $2}')" ]; then
        echo "nvim" >> $log_dir/uninstalled_software.logs
    fi
fi

# if tmux is not installed, install it.
if [ ! -f "$(whereis tmux | awk '{print $2}')" ]; then
    install_software tmux
    if [ ! -f "$(whereis tmux | awk '{print $2}')" ]; then
        echo "tmux" >> $log_dir/uninstalled_software.logs
    fi
fi

# if ranger is not installed, install it.
if [ ! -f "$(whereis ranger | awk '{print $2}')" ]; then
    install_software ranger
    if [ ! -f "$(whereis ranger | awk '{print $2}')" ]; then
        echo "ranger" >> $log_dir/uninstalled_software.logs
    fi
fi

# if fzf is not installed, install it.
if [ ! -f "$(whereis fzf | awk '{print $2}')" ]; then
    install_software fzf
    if [ ! -f "$(whereis fzf | awk '{print $2}')" ]; then
        echo "fzf" >> $log_dir/uninstalled_software.logs
    fi
fi

echo "####################"
echo "install software done"
echo "####################"
echo ""