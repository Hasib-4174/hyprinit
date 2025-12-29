# fastfetch
# fastfetch --logo /home/hasib/.config/fastfetch/pngs/pochita.png --logo-type alacritty-direct --logo-width 40 --logo-height 15
# fastfetch --kitty-direct /home/hasib/.config/fastfetch/pngs/makima.png --logo-width 40 --logo-height 15

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"


# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

zinit ice depth=1; zinit light romkatv/powerlevel10k


# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions


# Load completions
autoload -Uz compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.
# zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# Aliases
alias ls='ls --color'
alias vi='vim'
alias vim='nvim'
alias c='clear'


[[ $TERM_PROGRAM == "alacritty" && -z $TMUX ]] && exec tmux



#export GTK_IM_MODULE=ibus
#export QT_IM_MODULE=ibus
#export XMODIFIERS=@im=ibus

#export PATH="$HOME/flutter/bin:$PATH"

# Java
# export JAVA_HOME=/usr/lib/jvm/java-25-openjdk
# export PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME=/usr/lib/jvm/openjdk-zulu-ca-fx-bin
export PATH=$JAVA_HOME/bin:$PATH

# Android SDK
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH

# Flutter
export PATH=$PATH:$HOME/flutter/bin

#.npm-global
export PATH="$HOME/.npm-global/bin:$PATH"
export GEMINI_API_KEY=$(cat ~/.gemini_api_key)
export PATH=$HOME/.local/bin:$PATH
alias gemini2.5p='gemini chat --model=gemini-2.5-pro'
alias gemini1.5f='gemini chat --model=gemini-1.5-flash'
alias gemini2.5f='gemini chat --model=gemini-2.5-flash'

# --- Rust ---
source "$HOME/.cargo/env"
