# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#
# anyrouter
export ANTHROPIC_AUTH_TOKEN=sk-kN1lu1bmlfZhQZ4z9kjr2YrLooGxK7x2EvR1xhJu2RH2kDtW
export ANTHROPIC_BASE_URL=https://anyrouter.top
export ANTHROPIC_MODEL=claude-opus-4-6
# yunwu
# export ANTHROPIC_AUTH_TOKEN="sk-qMVu86Elc9L67nY7lJ9pj4tv7pqapWkMNLUnOkqjQwQBNh25"
# export ANTHROPIC_BASE_URL="https://api3.wlai.vip"
# export ANTHROPIC_MODEL=claude-opus-4-6

#honoursoft
# export ANTHROPIC_AUTH_TOKEN="sk-YlvKxn8Nj4ISuzFFMSYyzDzly7zSajuxbJQgSl4pJV6y8Y2f"
# export ANTHROPIC_AUTH_TOKEN="sk-WTyKJqIllafmixzwXzyAoEB7nrt8dLJ5Pn8pNYcWNRcBdPMb"
# export ANTHROPIC_BASE_URL="https://cc.honoursoft.cn"

# # fox 
# export ANTHROPIC_AUTH_TOKEN="sk-ant-oat01-qzOpNk93oiu9EXImfEmparjhYcNkNHmm3onqiiUNOnvv9ivxrGx5SSgV4TNAGt-wLjcduJbAKRq-83QZ8X_7njMR_9H3QAA"
# export ANTHROPIC_BASE_URL="https://code.newcli.com/claude/aws"

# yunwu gemini
# export GOOGLE_GEMINI_BASE_URL="https://yunwu.ai"
# export GEMINI_API_KEY="sk-jKz8yJHFRa5czx6p639XpBHpLfjI20qv4BBXahz69qH2JJ8h"
# export GEMINI_MODEL="gemini-3.1-pro-preview"

# right code claude
# export ANTHROPIC_BASE_URL=https://right.codes/claude 
# export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"
# export ANTHROPIC_AUTH_TOKEN=sk-629a2c92545f4c268eb62abe7bbd0122

# right code gemini
export GOOGLE_GEMINI_BASE_URL="https://right.codes/gemini"
export GEMINI_API_KEY="sk-3f1aa2d77e1b44f3a1dd9b73b7d164ca"
export GEMINI_MODEL="gemini-3-pro-preview"

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

source ~/.config/zsh/zshrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
(( ! ${+functions[p10k]} )) || p10k finalize
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/jesse/.anaconda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/jesse/.anaconda/etc/profile.d/conda.sh" ]; then
        . "/home/jesse/.anaconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/jesse/.anaconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export UB_OUTPUT=wayland
export PATH="$HOME/.npm-global/bin:$PATH"
