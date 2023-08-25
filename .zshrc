#------------------
# Zsh Config
#------------------
source ~/.aliases

#------------------
# From setup script
#------------------
# Add Homebrew to PATH
export PATH="/opt/homebrew/bin:$PATH"

# Ensure secure connections for brew
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha

# Enable 'history' config in ZSH
source ~/.zsh/history.zsh

# Enable key bindings in ZSH
source ~/.zsh/key-bindings.zsh

# Auto-completion
# Load completion config
source ~/.zsh/completion.zsh

# Initialize the completion system
autoload -Uz compinit

# Cache completion if nothing changed - faster startup time
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi
# Enhanced form of menu completion called 'menu selection'
zmodload -i zsh/complist

# Enable the addition of zsh hook functions
autoload -U add-zsh-hook

# Zsh syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Zsh auto-suggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Allow the use of the z plugin to easily navigate directories
source $(brew --prefix)/etc/profile.d/z.sh

# Use starship prompt
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship.toml

# Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="$(pyenv root)/shims:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# General python
export PYTHONDONTWRITEBYTECODE=1

# Jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# colorls tab completion for flags
source /Library/Ruby/Gems/2.6.0/gems/colorls-$(gem list | grep -i "colorls" | grep -o "\d\.\d\.\d")/lib/tab_complete.sh

# terraform
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C $(brew --prefix)/bin/terraform terraform
export AWS_DEFAULT_REGION=ap-southeast-2
