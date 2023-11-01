#!/bin/sh

# This script to modify the specific files.

# modify /etc/environment
# if EDITOR=vim is not in /etc/environment, or EDITOR is not equal vim, change it.
if [ ! -f "/etc/environment" ]; then
    sudo echo "EDITOR=vim" > /etc/environment
else
    if [ ! -f "$(cat /etc/environment | grep -E '^EDITOR=')" ]; then
        sudo echo "EDITOR=vim" >> /etc/environment
    else
        if [ "$(cat /etc/environment | grep -E '^EDITOR=')" != "EDITOR=vim" ]; then
            sudo sed -i 's/^EDITOR=.*/EDITOR=vim/g' /etc/environment
        fi
    fi
fi

# modify /etc/profile
# add EDITOR=vim to /etc/profile
if [ ! -f "$(cat /etc/profile | grep -E '^EDITOR=')" ]; then
    sudo echo "EDITOR=vim" >> /etc/profile
else
    if [ "$(cat /etc/profile | grep -E '^EDITOR=')" != "EDITOR=vim" ]; then
        sudo sed -i 's/^EDITOR=.*/EDITOR=vim/g' /etc/profile
    fi
fi

echo "####################"
echo "modify specific files done!"
echo "####################"
echo ""