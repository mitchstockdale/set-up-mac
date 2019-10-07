#------------------
# Shell Variables
#------------------

# Set VS Code as default code editor
export EDITOR=visual-studio-code

#------------------
# PATH Manipulations
#------------------

#------------------
# Zsh hooks
#------------------

# Enable the addition of zsh hook functions
autoload -U add-zsh-hook

#------------------
# Aliases (for a full list of aliases, run `alias`)
#------------------

# Note: the following aliases overwrite any aliases specified in the Oh My Zsh plugins

# Git Aliases
alias gcm="git commit -m"
alias gcam='git commit -a -m'
alias gca="git commit --amend --no-edit"
alias gcae="git commit --amend"
alias gcaa="git add --all && git commit --amend --no-edit"
alias gcaae="git add --all && git commit --amend"
alias gap="git add -p"
alias gnope="git checkout ."
alias gwait="git reset HEAD"
alias gundo="git reset --soft HEAD^"
alias greset="git clean -f && git reset --hard HEAD" # Removes all changes, even untracked files
alias gl="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glb='git log --oneline --decorate --graph --all'
alias gst='git status -s'
alias gpl="git pull --rebase"
alias gps="git push"
alias gpsf="git push --force-with-lease"
alias grb="git rebase"
alias grbi='git rebase -i'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
# Remove local branches that have already been merged in the remote repository
alias gcmb="git branch --merged | grep -Ev '(^\*|master)' | xargs git branch -d"
# Sets the upstream branch to be the same branch as the locally named branch
alias gset='git branch --set-upstream-to=origin/`git symbolic-ref --short HEAD`'
# Do an interactive rebase back N number of commits (e.g. grn 3)
grn() { git rebase -i HEAD~"$1"; }
# Do an interactive rebase to a supplied commit hash (e.g. grbc 80e1625)
grbic() { git rebase -i "$1"; }

# General Aliases

# Open .zshrc to be editor in VS Code
alias change="code ~/.zshrc"
# Re-run source command on .zshrc to update current terminal session with new settings
alias update="source ~/.zshrc"
# View files/folder alias using colorsls (https://github.com/athityakumar/colorls)
#alias l='colorls --group-directories-first --almost-all'
#alias ll='colorls --group-directories-first --almost-all --long'
# Clear terminal
alias c='clear'

#------------------
# Miscellaneous
#------------------

# Allow the use of the z plugin to easily navigate directories
. /usr/local/etc/profile.d/z.sh

# Set pure as a prompt
autoload -U promptinit
promptinit
prompt pure

# Add colors to terminal commands (green command means that the command is valid)
source /usr/local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh