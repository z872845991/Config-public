#!/bin/sh
# This script creates by Jesse.
# This script is used to initialize the environment.

# 1. Create the directory of Desktop, Documents, Downloads, Music, Pictures, Public, Templates, Videos.

LC_ALL=C xdg-user-dirs-update --force

# 2. Install the software.

os=$(cat /etc/os-release | grep -E '^ID=' | awk -F= '{print $2}' | sed 's/\"//g')

echo "Your os is $os."

name=$(whoami)

echo "Your user is $name."

# get the script directory
script_dir=$(cd "$(dirname "$0")"; pwd)
# get the script father directory
father_dir=$(dirname $script_dir)
# set log directory 
log_dir=$father_dir/logs

# if log directory is not exist, create it.
if [ ! -d $log_dir ]; then
    mkdir -p $log_dir
fi

if [ $name = "root" ]; then
    alias sudo=""
fi

if [ $os = "arch" ]; then
    alias update_software="sudo pacman -Syu"
    alias install_software="sudo pacman -S --noconfirm"
    alias remove_software="sudo pacman -R --noconfirm"
    alias search_software="sudo pacman -Ss"
    # if git is not installed, install it.
    if [ ! -f "$(whereis git | awk '{print $2}')" ]; then
        echo "git is not installed, install it."
        install_software git
        if [ ! -f "$(whereis git | awk '{print $2}')" ]; then
            echo "git" >> $log_dir/uninstalled_software.logs
        fi
    fi
    # if yay is not installed, install it.
    if [ ! -f "$(whereis yay | awk '{print $2}')" ]; then
        echo "yay is not installed, install it."
        sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
        if [ ! -f "$(whereis yay | awk '{print $2}')" ]; then
            echo "yay" >> $log_dir/uninstalled_software.logs
        fi
    fi
    alias update_aur_software="yay -Syu"
    alias install_aur_software="yay -S --noconfirm"
    alias remove_aur_software="yay -R --noconfirm"
    alias search_aur_software="yay -Ss"
    # if pip is not installed, install it.
    if [ ! -f "$(whereis pip | awk '{print $2}')" ]; then
        echo "pip is not installed, install it."
        install_software python-pip
        if [ ! -f "$(whereis pip | awk '{print $2}')" ]; then
            echo "python-pip" >> $log_dir/uninstalled_software.logs
        fi
    fi
elif [ $os = "ubuntu" ]; then
    alias update_software="sudo apt update && sudo apt upgrade"
    alias install_software="sudo apt install -y"
    alias remove_software="sudo apt remove -y"
    alias search_software="apt search"
    # if pip is not installed, install it.
    if [ ! -f "$(whereis pip | awk '{print $2}')" ]; then
        install_software python3-pip
        if [ ! -f "$(whereis pip | awk '{print $2}')" ]; then
            echo "python3-pip" >> $log_dir/uninstalled_software.logs
        fi
    fi
elif [ $os = "debian" ]; then
    alias update_software="sudo apt update && sudo apt upgrade"
    alias install_software="sudo apt install -y"
    alias remove_software="sudo apt remove -y"
    alias search_software="apt search"
elif [ $os = "fedora" ]; then
    alias update_software="sudo dnf update"
    alias install_software="sudo dnf install -y"
    alias remove_software="sudo dnf remove -y"
    alias search_software="dnf search"
elif [ $os = "centos" ]; then
    alias update_software="sudo yum update"
    alias install_software="sudo yum install -y"
    alias remove_software="sudo yum remove -y"
    alias search_software="yum search"
elif [ $os = "opensuse" ]; then
    alias update_software="sudo zypper update"
    alias install_software="sudo zypper install -y"
    alias remove_software="sudo zypper remove -y"
    alias search_software="zypper search"
fi

# copy files
# if unzip is not installed, install it.
if [ ! -f "$(whereis unzip | awk '{print $2}')" ]; then
    install_software unzip
    if [ ! -f "$(whereis unzip | awk '{print $2}')" ]; then
        echo "unzip" >> $log_dir/uninstalled_software.logs
    fi
else
    echo "unzip is already installed."
fi
echo "####################"
echo "copy files"
echo "####################"
source $script_dir/copyfile_to_specfic_dir.sh

# intall software
echo "####################"
echo "install software" 
echo "####################"
source $script_dir/install_software.sh

# config nvim
echo "####################"
echo "config nvim"
echo "####################"
source $script_dir/deploy_vim.sh

# modify specific files
echo "####################"
echo "modify specific files"
echo "####################"
source $script_dir/mod_specific_files.sh

# config tmux
echo "####################"
echo "config tmux"
echo "####################"
source $script_dir/config_tmux.sh