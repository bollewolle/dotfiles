#!/bin/bash
# run_onchange_before_ scripts are run in alphabetical order before updating the dotfiles and only when the content of the file changes.
# Purpose: Use this script to add packages/software which need to be installed
echo "💡 Install all the things..."

if [ ! -f "/usr/local/bin/brew" ] && [ ! -f "/opt/homebrew/bin/brew" ]; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    chmod -R go-w "$(brew --prefix)/share"
fi

# if ! type nix &>/dev/null; then
#     echo "❄️ Installing nix..."
#     curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
#     . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
# fi

echo "You are using $CHEZMOI_SOURCE_DIR as Chezmoi source directory."

if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/installation-type.sh
else
    echo "☢️  No installation type set, did you run this script directly? Assuming 'workstation' installation."
    INSTALLATION_TYPE=workstation
fi

# Install source tooling (e.g. PATH)
if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/source-tooling.sh
fi

# Install minimal tooling with Brew Bundle
echo "🔧 Brew: Installing minimal tooling"
brew bundle --no-lock --file=/dev/stdin <<EOF
brew "zsh"
brew "eza"
brew "bat"
brew "fzf"
brew "btop"
brew "jq"
brew "ripgrep"
brew "xh"
brew "navi"
brew "starship"
brew "zoxide"
brew "sheldon"
brew "watch"
brew "git"
brew "procs"
brew "dust"
brew "duf"
brew "prettyping"
brew "topgrade"
brew "neovim"
brew "coreutils"
brew "terminal-notifier"
brew "m-cli"
brew "mas"
EOF

# Install additional tooling in case of workstation with Brew Bundle
if [ "$INSTALLATION_TYPE" = "workstation" ]; then
    echo "🔧 Brew: Installing workstation tooling"
    brew bundle --force --no-lock --file=/dev/stdin <<EOF
brew "node"
brew "ruby"
brew "direnv"
brew "exiftool"
cask "prefs-editor"
cask "1password/tap/1password-cli"
cask "coconutbattery"
cask "jordanbaird-ice"
cask "orbstack"
cask "whatsapp"
cask "telegram"
cask "hyper"
cask "only-switch"
cask "postman"
cask "xld"
cask "carbon-copy-cloner"
cask "calibre"
cask "betterdisplay"
cask "rectangle-pro"
cask "appcleaner"
cask "iina"
cask "discord"
cask "tower"
cask "wireshark"
cask "visual-studio-code"
cask "google-chrome"
cask "firefox"
cask "setapp"
cask "plex"
cask "soundsource"
cask "spotify"
cask "jaikoz"
cask "the-unarchiver"
cask "home-assistant"
cask "hazel"
cask "fujitsu-scansnap-home"
cask "connectmenow"
cask "morgen"
EOF

# TEMP deactivation for testing purposes
# cask "vmware-fusion"
# cask "snagit"
# cask "microsoft-teams"
# cask "microsoft-outlook"
# cask "microsoft-word"
# cask "microsoft-excel"
# cask "microsoft-powerpoint"

# TODO Review if needed
# cask "arq" --> no longer use for?

fi

# Install additional apps from the MacOS App Store in case of workstation via mas-cli with Brew Bundle
if [ "$INSTALLATION_TYPE" = "workstation" ]; then
    echo "🔧 App Store: Installing workstation tooling"
    brew bundle --force --no-lock --file=/dev/stdin <<EOF
mas "OK JSON", id: 1576121509
mas "MQTT Explorer", id: 1455214828
mas "MindNode", id: 1289197285
mas "Xcode", id: 497799835
mas "Infuse", id: 1136220934
mas "Pixelmator Pro", id: 1289583905
mas "Photomator", id: 1444636541
mas "Timepage", id: 989178902
mas "Airmail", id: 918858936
mas "Parcel", id: 639968404
mas "MusicBox", id: 1614730313
mas "Paprika Recipe Manager 3", id: 1303222628
mas "WireGuard", id: 1451685025
mas "Little Snitch Mini", id: 1629008763
mas "1Password for Safari", id: 1569813296
mas "Super Agent for Safari", id: 1568262835
mas "Wipr", id: 1320666476
mas "Keepa - Price Tracker", id: 1533805339
mas "StopTheMadness Pro ", id: 2118554294
mas "Userscripts", id: 1463298887
mas "Baking Soda - Tube Cleaner", id: 1601151613
mas "Vinegar - Tube Cleaner", id: 1591303229
mas "The Camelizer", id: 1532579087
EOF

# mas "Home Assistant", id:1099568401

fi

# Finalize installing workstation tooling
if [ "$INSTALLATION_TYPE" = "workstation" ]; then
    echo "🔧 Finalize installing workstation tooling"

    echo "🔧 Checking current default shell..."
    current_shell=$(dscl . -read /Users/$(whoami) UserShell | awk '{print $2}')

    if [ "$current_shell" != "$(brew --prefix)/bin/zsh" ]; then
        echo "🔧 Setting default shell to ZSH..."
        sudo chsh -s $(brew --prefix)/bin/zsh $(whoami)
    else
        echo "🔧 Default shell is already ZSH."
    fi

    echo "🔧 Installing ASDF..."
    if [ ! -d $HOME/.asdf ]; then
        echo "💡 Installing asdf..."
        git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf
        . "$HOME/.asdf/asdf.sh"
        asdf update
    fi

    . "$HOME/.asdf/asdf.sh"

    asdf plugin add nodejs
    asdf plugin add python

fi

# TODO:
# Find way to install:
#   Epos Connect
#   Sleeve
#   CoconutBattery
#   Logi Options
#   Logi Options+
#   eID Viewer
#   Mastodon
#   Octopus
#   Harmony