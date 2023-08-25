#!/usr/bin/env bash

# Original Source:
#  Hacked up version of this gist: https://gist.github.com/codeinthehole/26b37efa67041e1307db
#  and Rob's repo: https://github.com/jarvisrob/set-up-mac

printf "Starting bootstrapping\n"
printf "Running script using bash version: $BASH_VERSION\n"

printf "Install XCode"

xcode-select --install
read -n 1 -s -p "Install XCode dialog requested. Install and then press any key to continue..."

GIT_URL="https://raw.githubusercontent.com/mitchstockdale/set-up-mac/master"

SOFTWARE_LISTS=( brew-casks brew-fonts brew-packages vscode-extensions )
for file in "${SOFTWARE_LISTS[@]}"; do
	echo "Downloading $file"
 	curl "${GIT_URL}"/"${file}" -o "$file"
done

# Load in variables without dependence on bash >= 4.0
while IFS=\= read package; do
    PACKAGES+=($package)
done < <(grep -v '^#' < ./brew-packages)

while IFS=\= read cask; do
    CASKS+=($cask)
done < <(grep -v '^#' < ./brew-casks)

while IFS=\= read font; do
    FONTS+=($font)
done < <(grep -v '^#' < ./brew-fonts)

while IFS=\= read vscode_extension; do
    VSCODE_EXTENSIONS+=($vscode_extension)
done < <(grep -v '^#' < ./vscode-extensions)

echo "Creating directories under $HOME"
mkdir -p ~/bin
mkdir -p ~/iso
mkdir -p ~/lab
mkdir -p ~/tmp
mkdir -p ~/vm-share
mkdir -p ~/code
mkdir -p ~/.config
echo "Directory structure under $HOME:"
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
read -p "Copy key details and then press <return> to continue"

echo "Installing Homebrew ..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH="/opt/homebrew/bin:$PATH"
brew update
brew upgrade
echo "Done ..."

# Disable Brew Analytics
brew analytics off

# Homebrew taps
brew tap aws/tap
brew tap hashicorp/tap
brew tap homebrew/cask-fonts

printf "Installing packages...\n"
# Loop to avoid missing shas from preventing all package installations
for package in "${PACKAGES[@]}"; do
	echo "Installing $package"
 	brew install --formula $package
done

printf "Installing cask apps...\n"
# Loop to avoid missing shas from preventing all package installations
for cask in "${CASKS[@]}"; do
	echo "Installing $cask"
 	brew install --cask $cask
done

printf "Installing fonts...\n"
# Loop to avoid missing shas from preventing all package installations
for font in "${FONTS[@]}"; do
	echo "Installing $font"
 	brew install --cask $font
done

printf "Cleaning up Brew...\n"
brew cleanup -s
rm -rf "$(brew --cache)"

# Bash
echo 'You will be prompted for root password to add the new version of bash to /etc/shells'
echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells 1>/dev/null

# Zsh
echo 'You will be prompted for root password to add the new version of zsh to /etc/shells'
echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells 1>/dev/null
# Create a `.zsh` directory to store our plugins in one place
mkdir -p ~/.zsh

# Dot files
# References:
#   - https://www.davidculley.com/dotfiles/
#   - https://superuser.com/questions/183870/difference-between-bashrc-and-bash-profile/183980#183980

echo "Downloading dot files..."
DOT_FILES=( .aliases .profile .bashrc .bash_profile .zprofile .zshrc .hyper.js .vimrc .git-prompt-colors.sh )
for file in "${DOT_FILES[@]}"; do
	echo "Downloading $file"
 	wget -N "${GIT_URL}"/"${file}" -P ~
done

echo "Downloading starship prompt config"
wget -N "${GIT_URL}"/starship.toml -P ~/.config

# Download history config
wget -N https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/lib/history.zsh -P ~/.zsh

# Download key bindings config
wget -N https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/lib/key-bindings.zsh -P ~/.zsh

# Download completion config
wget -N https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/lib/completion.zsh -P ~/.zsh

echo "Installing VS Code Extensions..."
for ext in "${VSCODE_EXTENSIONS[@]}"; do
   code --install-extension "${ext//$'\n'}"
done

# Pycharm/IntelliJ theme
# wget https://raw.githubusercontent.com/JordanForeman/idea-snazzy/master/snazzy.icls -P ~

sudo gem install colorls

# Configure Git
echo "Configuring Git settings and aliases ..."
read -p "Enter global default Git email: " GIT_EMAIL

# Configure Git settings
git config --global user.name "Mitch Stockdale"
git config --global user.email "$GIT_EMAIL"
git config --global core.editor "code"
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

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles true

# Show status bar (# of items and disk space)
defaults write com.apple.finder ShowStatusBar true

# Show path bar
defaults write com.apple.finder ShowPathbar true

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
# Require password immediately after sleep or screen saver begins
# Start screen saver after 5 mins of idle
defaults write com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPasswordDelay -int 0
defaults -currentHost write com.apple.screensaver idleTime 300

echo "Screenshot settings"
# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"
# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

echo "Dialog settings"
# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Make Zsh the default shell
echo 'Making Homebrew installed and updated Zsh the default shell. You will be prompted for root password.'
chsh -s /opt/hombrew/bin/zsh

# Cleanup after ourselves
for file in "${SOFTWARE_LISTS[@]}"; do
	echo "Removing $file"
 	rm -f  "$file"
done

# End
echo "Mac set-up completed--enjoy!"
echo "Close terminal and re-open to get everything"
echo "It's probably a good idea to reboot now"
echo ""
