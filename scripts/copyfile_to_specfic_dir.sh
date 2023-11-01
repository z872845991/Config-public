#!/bin/sh

# This script copy the files to the specific directory.

# copy .gitconfig
if [ ! -f "$HOME/.gitconfig" ]; then
    echo "copy .gitconfig to $HOME"
    cp $father_dir/.gitconfig $HOME
else
    echo "$HOME/.gitconfig is already exist."
fi

# copy .xinirc
if [ ! -f "$HOME/.xinirc" ]; then
    echo "copy .xinirc to $HOME"
    cp $father_dir/.xinirc $HOME
else
    echo "$HOME/.xinirc is already exist."
fi

# copy clash
if [ ! -d "$HOME/.config/clash" ]; then
    echo "copy clash to $HOME"
    cp -r $father_dir/.config/clash $HOME/.config
else
    echo "$HOME/.config/clash is already exist."
fi

# copy .Xresources
if [ ! -f "$HOME/.Xresources" ]; then
    echo "copy .Xresources to $HOME"
    cp $father_dir/.Xresources $HOME
else
    echo "$HOME/.Xresources is already exist."
fi

# copy .xprofile
if [ ! -f "$HOME/.xprofile" ]; then
    echo "copy .xprofile to $HOME"
    cp $father_dir/.xprofile $HOME
else
    echo "$HOME/.xprofile is already exist."
fi

# copy .config to $HOME
if [ -d "$father_dir/.config" ]; then
    echo "copy .config to $HOME"
    for file in $(ls $father_dir/.config); do
        if [ ! -d "$HOME/.config/$file" ]; then
            cp -r $father_dir/.config/$file $HOME/.config
        fi
    done
    echo "copy .config to $HOME done!"
else
    echo "There is no .config directory in $father_dir"
fi
# 

# copy .tmux.conf to $HOME
if [ ! -f "$HOME/.tmux.conf" ]; then
    echo "copy .tmux.conf to $HOME"
    cp $father_dir/.tmux.conf $HOME
else
    echo "$HOME/.tmux.conf is already exist."
fi

# copy zshfiles to $HOME
if [ ! -d $HOME/zim ]; then
    echo "copy zshfiles to $HOME"
    unzip $father_dir/zshfile.zip -d $HOME
else
    echo "$HOME/zshfiles is already exist."
fi

# copy .dir_colors to $HOME
if [ ! -f "$HOME/.dir_colors" ]; then
    echo "copy .dir_colors to $HOME"
    cp $father_dir/.dir_colors $HOME
else
    echo "$HOME/.dir_colors is already exist."
fi
# copy .p10k.zsh to $HOME
if [ ! -f "$HOME/.p10k.zsh" ]; then
    echo "copy .p10k.zsh to $HOME"
    cp $father_dir/.p10k.zsh $HOME
else
    echo "$HOME/.p10k.zsh is already exist."
fi
# copy .ssh to $HOME
if [ -d "$father_dir/.ssh" ]; then
    echo "copy .ssh to $HOME"
    for file in $(ls $father_dir/.ssh); do
        if [ ! -d "$HOME/.ssh/$file" ]; then
            cp -r $father_dir/.ssh/$file $HOME/.ssh
        fi
    done
    sudo chmod 700 $HOME/.ssh
    sudo chmod 600 $HOME/.ssh/*
fi

# echo copy done info by include by #####
echo "####################################"
echo "copy done!"
echo "####################################"
echo ""
