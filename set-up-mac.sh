#!/usr/bin/env bash
echo "Running script using bash version:"
echo $BASH_VERSION

# This is my set-up, my way
# If you're not me, *really* think before running this script--it's all on you

echo "Shell script to set-up a new Mac"
echo "You were warned: This is *my* set-up, *my* way!"
echo "Here we go ..."


# Make my directories
echo "Making my directories under HOME (~), i.e. under $HOME"
mkdir ~/bin
mkdir ~/iso
mkdir ~/lab
mkdir ~/tmp
mkdir ~/vm-share
mkdir ~/repos
echo "Directory structure under HOME (~) is now:"
ls -d */


# SSH keys
echo "Generating SSH keys"
echo "You will be prompted for email, file location (enter for default) and passphrase"
read -p "Enter SSH key email: " SSH_EMAIL
ssh-keygen -t rsa -b 4096 -C "$SSH_EMAIL"
echo "Adding SSH private key to ssh-agent and storing passphrase in keychain"
echo "You will be prompted for the passphrase again"
eval "$(ssh-agent -s)"
cat <<EOT >> ~/.ssh/config
Host *
	AddKeysToAgent yes
	UseKeychain yes
	IdentityFile ~/.ssh/id_rsa

EOT
ssh-add -K ~/.ssh/id_rsa


## Install Homebrew itself
echo "Installing and updating xcode ..."
xcode-select —-install
# Reset xcode
xcode-select -r

echo "Installing Homebrew ..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew upgrade
echo "Done ..."


# Install packages and software using Homebrew
echo "Installing packages and software using Homebrew ..."

# Bash
echo "First, the latest version of bash"
brew install bash
echo "You will now be prompted for root password *twice*"
echo "First time to add the new version of bash to /etc/shells"
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
echo "Second time to change the default shell to the new version of bash"
chsh -s /usr/local/bin/bash

# Terminal tools and commands
brew cask install hyper
brew install bash-completion
brew install tmux
brew install tree
brew install wget
brew install rsync

# Dev tools
brew install git
brew install bash-git-prompt
brew cask install docker

# Productivity
brew cask install microsoft-office
brew cask install microsoft-teams
brew cask install alfred
# brew cask install google-chrome
brew cask install firefox

# R

# XQuartz is required for R packages that use X11, which is no longer installed on macOS
echo "Installing XQuartz. You will be prompted for root password."
brew cask install xquartz

# R.app is the macOS version of CRAN-R
brew cask install r-app

# Linking the BLAS (vecLib) from Apple's Accelerate Framework to make R run multi-threaded where it can by default
# https://developer.apple.com/documentation/accelerate/blas

# The approach for linking the BLAS provided on CRAN **doesn't work**, since libRblas.vecLib.dylib does not exist (at least not in that location)
# https://cran.r-project.org/bin/macosx/RMacOSX-FAQ.html#Which-BLAS-is-used-and-how-can-it-be-changed_003f

# Instead this works to link the Apple Accelerate BLAS to R
# Links for the current version of R, but since this is set-up from scratch there is only one version installed
echo "Linking version of R just installed to the BLAS in the Apple Accelerate Framework"
ln -sf \
  /System/Library/Frameworks/Accelerate.framework/Versions/Current/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib \
  /Library/Frameworks/R.framework/Versions/Current/Resources/lib/libRblas.dylib
echo "To restore the default BLAS that comes with R use:"
echo "  $ ln -sf /Library/Frameworks/R.framework/Versions/Current/Resources/lib/libRblas.0.dylib /Library/Frameworks/R.framework/Versions/Current/Resources/lib/libRblas.dylib"

# Not yet sure if need to do anything about linknig the LAPACK

# Microsoft R Open
# Not sure if can be installed side-by-side with other R, ambiguous wording on installation site
# https://mran.microsoft.com/documents/rro/installation#revorinst-osx
# Uncomment when/if decide want it installed too
# brew cask install microsoft-r-open

# Python (Homebrew version)
brew install python

# Node.js (required for JupyterLab extensions)
brew install node

# Text editors and IDEs
brew cask install visual-studio-code
brew cask install rstudio
#brew cask install azure-data-studio
#brew cask install sublime-text
#brew cask install pycharm

# Cloud command-line interfaces and tools
#brew install awscli
#brew install azure-cli
#brew cask install microsoft-azure-storage-explorer

# SQL
# Still thinking these over, uncomment when ready
# brew install postgresql
# brew cask install postgres

# Misc
#brew cask install spotify

# Mac tools
#brew cask install scroll-reverser

# Homebrew installations complete
brew cleanup
echo "Homebrew software installations complete"


# Conda
echo "Installing Miniconda using their bash script (not Homebrew). You will be prompted multiple times."
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -P ~/tmp
bash ~/tmp/Miniconda3-latest-MacOSX-x86_64.sh
rm ~/tmp/Miniconda3-latest-MacOSX-x86_64.sh

# Conda adds content to .bash_profile, but we want to manually call that when turning Conda on
# So put all that stuff into another script, and we'll get .bash_profile later
mv ~/.bash_profile ~/bin/conda-on.sh
echo "echo \"Conda ready to use\"" >> ~/bin/conda-on.sh
source ~/bin/conda-on.sh

conda update conda
conda --version

echo "Setting up Conda and Jupyter, including sandbox environment(s) for data science ..."

# JupyterLab, installed into base env, configured so it can work across Conda environments
# At the moment, JupyterLab needs to be installed from conda-forge
conda activate base
conda install --channel conda-forge --name base --yes jupyterlab
conda install --name base --yes nb_conda_kernels

# Sandbox Python environment
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/python-sandbox-env.yml -P ~/tmp
conda env create --file ~/tmp/python-sandbox-env.yml
conda activate python-sandbox
# TensorFlow 2 not yet available via conda or conda-forge
#pip install tensorflow==2.0.0-alpha0
pip install pysnooper
conda activate base
rm ~/tmp/python-sandbox-env.yml

# Install IRkernel so can use R in Jupyter
# This needs to be done while conda base environment is active, because it needs to see the Jupyter installation
conda activate base
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/install-irkernel.R -P ~/tmp
Rscript --verbose --vanilla ~/tmp/install-irkernel.R
rm ~/tmp/install-irkernel.R

# Clean up conda
conda activate base
conda clean --all --yes

echo "List of conda environments now on your system"
conda info --envs

# Turn off conda
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/conda-off.sh -P ~/bin 
source ~/bin/conda-off.sh


# Configure Git
echo "Configuring Git settings and aliases ..."
read -p "Enter global default Git email: " GIT_EMAIL

# Configure Git settings
git config --global user.name "mitchstockdale"
git config --global user.email "$GIT_EMAIL"
git config --global core.editor "vim"

# Git aliases
#git config --global alias.unstage 'reset HEAD --' 
#git config --global alias.unmod 'checkout --' 
#git config --global alias.last 'log -1 HEAD' 
#git config --global alias.pub 'push -u origin HEAD' 
#git config --global alias.setemail 'config user.email mitchstockdale@users.noreply.github.com' 
#git config --global alias.cm 'commit -m' 
#git config --global alias.co checkout 
#git config --global alias.cob 'checkout -b' 
#git config --global alias.aa 'add -A' 
#git config --global alias.s status 
#git config --global alias.ss 'status -s' 
#git config --global alias.dm diff 
#git config --global alias.ds 'diff --staged'

echo "... Done"


# macOS settings
echo "macOS settings being configured"

echo "First closing System Preferences window if open to avoid conflicts"
# Close System Preferences to prevent conflicts with the settings changes
# The following is AppleScript called from the command line
# http://osxdaily.com/2016/08/19/run-applescript-command-line-macos-osascript/
osascript -e 'tell application "System Preferences" to quit'

echo "Finder settings"

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

killall -HUP Finder


echo "Dock settings"

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Only Show Open Applications In The Dock  
defaults write com.apple.dock static-only -bool true

# Minimise to Dock using "scale" effect
defaults write com.apple.dock mineffect -string scale

defaults write com.apple.dock orientation -string left

defaults write com.apple.dock magnification -bool false

defaults write com.apple.dock show-process-indicators -bool false

defaults write com.apple.dock tilesize -float 40

defaults write com.apple.dock show-recents -bool false

# Don't minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool false

killall Dock


echo ".DS_Store files settings"
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true


echo "TextEdit settings"
# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0


echo "Screen saver password settings"
# Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0


echo "Screenshot settings"

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"


echo "Dialog settings"
# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Dot files
# References:
#   - https://www.davidculley.com/dotfiles/
#   - https://superuser.com/questions/183870/difference-between-bashrc-and-bash-profile/183980#183980

echo "Download dot files"

# .aliases
echo "Downloading .aliases"
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/.aliases -P ~
cat ~/.aliases

# .profile
echo "Downloading .profile"
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/.profile -P ~
cat ~/.profile

# .bashrc
echo "Downloading .bashrc"
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/.bashrc -P ~
cat ~/.bashrc

# .bash_profile
echo "Downloading .bash_profile"
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/.bash_profile -P ~
cat ~/.bash_profile

# Z Shell
echo "Updating Zsh ..."
brew install zsh
echo "You will now be prompted for root password *twice*"
echo "First time to add the new version of bash to /etc/shells"
sudo bash -c 'echo /usr/local/bin/zsh >> /etc/shells'
echo "Second time to change the default shell to the new version of zsh"
chsh -s /usr/local/bin/zsh
echo "Installing pure-prompt ..."
npm install --global pure-prompt

# cat <<EOT > ~/.zprofile
# [[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'

# EOT

# cat <<EOT > ~/.zshrc
# source .aliases

# EOT
# cat ~/.zprofile

# .vimrc (Vim)
echo "Downloading .vimrc"
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/.vimrc -P ~
cat ~/.vimrc

# .condarc (Conda)
echo "Downloading .condarc"
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/.condarc -P ~
cat ~/.condarc

# .git-prompt-colors.sh (bash-git-prompt)
echo "Downloading .git-prompt-colors.sh"
wget https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master/.git-prompt-colors.sh -P ~
cat ~/.git-prompt-colors.sh


# End
echo "Mac set-up completed--enjoy!"
echo "Close terminal and re-open to get everything"
echo "It's probably a good idea to reboot now"
echo ""
