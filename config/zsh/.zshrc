# ============================
# .zshrc - Zsh Configuration
# ============================
# Clean configuration for Hyprland setup
# Uses Zinit plugin manager with Powerlevel10k theme

# ----------------------------
# Powerlevel10k Instant Prompt
# ----------------------------
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------
# Zinit Plugin Manager
# ----------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if not present
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# ----------------------------
# Theme and Plugins
# ----------------------------
# Powerlevel10k theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Load completions
autoload -Uz compinit && compinit

# Load p10k config if exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ----------------------------
# Keybindings
# ----------------------------
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ----------------------------
# History Settings
# ----------------------------
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

# ----------------------------
# Aliases
# ----------------------------
alias ls='ls --color'
alias ll='ls -la'
alias la='ls -A'
alias vi='vim'
alias vim='nvim'
alias c='clear'

# ----------------------------
# Auto-start Tmux in Alacritty
# ----------------------------
[[ $TERM_PROGRAM == "alacritty" && -z $TMUX ]] && exec tmux

# ----------------------------
# PATH Configuration
# ----------------------------
# Local bin directory
export PATH="$HOME/.local/bin:$PATH"

# NPM global packages (if using npm without sudo)
if [[ -d "$HOME/.npm-global/bin" ]]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Rust/Cargo (if installed)
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# ----------------------------
# Environment Variables
# ----------------------------
# Uncomment and modify these as needed:
# export EDITOR=nvim
# export VISUAL=nvim

# Wayland-specific (already set by Hyprland, but just in case)
# export XDG_SESSION_TYPE=wayland
# export QT_QPA_PLATFORM=wayland
