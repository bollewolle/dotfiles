#!/bin/bash
# run_onchange_before_ scripts are run in alphabetical order before updating the dotfiles and only when the content of the file changes.
# Purpose: Use this script to add packages/software which need to be installed
echo "💡 Install all the things..."

if [ ! -f "/usr/local/bin/brew" ] && [ ! -f "/opt/homebrew/bin/brew" ]; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/installation-type.sh
else
    echo "☢️  No installation type set, did you run this script directly? Set INSTALLATION_TYPE using an env var if needed."
fi

if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/source-tooling.sh
fi

if [[ "$(uname)" == "Darwin" && "$(uname -m)" == "arm64" && ! $(/usr/bin/pgrep oahd) ]]; then
    echo "🔧 Installing Rosetta.."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi

if [ -d "/Applications/Xcode.app" ]; then
    echo "Full Xcode is installed"

    if /usr/bin/xcodebuild -license status &> /dev/null; then
        echo "Xcode license has already been accepted."
    else
        echo "You have not agreed to the Xcode license. Accepting the Xcode license..."
        sudo xcodebuild -license accept
        if [ $? -ne 0 ]; then
            echo "Failed to accept the Xcode license. Please run 'sudo xcodebuild -license' manually and accept the terms."
            exit 1
        fi
    fi
elif [ -d "/Library/Developer/CommandLineTools" ]; then
    echo "Only Command Line Tools are installed"
    echo "Consider installing full Xcode if you need additional development features"
else
    echo "Neither Xcode nor Command Line Tools are installed"
    echo "Installing Command Line Tools..."
    xcode-select --install
    exit 1
fi

# Install prerequisites with Brew Bundle
echo "🔧 Brew: Installing prerequisites"
brew bundle --no-upgrade --force --file=/dev/stdin <<EOF
brew "zsh" # shell
brew "eza" # ls replacement
brew "vivid" # colorizer
brew "bat" # cat replacement
brew "bat-extras" # more bat
brew "fzf" # fuzzy finder
brew "fd" # find replacement
brew "btop" # top replacement
brew "jq" # json processor
brew "yq" # yaml, json and xml processor
brew "xq" # xml & html processor
brew "fx" # json viewer
brew "ripgrep" # grep replacement
brew "delta" # diff viewer
brew "diff-so-fancy" # diff viewer
brew "xh" # curl replacement
brew "navi" # cheatsheet
brew "starship" # prompt
brew "zoxide" # cd replacement
brew "sheldon" # plugin manager
brew "watch" # watch command
brew "git" # version control
brew "procs" # ps replacement
brew "dust" # du replacement
brew "duf" # df replacement
brew "prettyping" # ping replacement
brew "iperf3" # network speed test
brew "doggo" # dig replacement
brew "coreutils" # gnu coreutils
brew "m-cli" # swiss army knife for macos
brew "mas" # mac app store cli
brew "tag" # manipulate and query tags on macos files
brew "topgrade" # update all the things
brew "neovim" # text editor
brew "neofetch" # system info
cask "ghostty" # terminal
cask "keka" # file archiver
cask "applite" # homebrew gui
cask "hyper" # terminal
cask "font-hack-nerd-font" # standalone nerd font
cask "font-roboto-mono-nerd-font" # standalone nerd font
cask "font-readex-pro" 
EOF

if [ "$APPLY_SECRETS" = "true" ] || [ "$INSTALLATION_TYPE" = "regular" ] || [ "$INSTALLATION_TYPE" = "workstation" ]; then
    echo "🔧 Installing 1Password"
    brew bundle --no-upgrade --force --file=/dev/stdin <<EOF
# 1password
cask "1password" # 1password
cask "1password/tap/1password-cli" # 1password cli
mas "1Password for Safari", id: 1569813296 # 1password safari extension
EOF
    # TODO check if op ... is configured correcly, if not, exit script and ask user to configure, then run bootstrap again
    op_account_size="$(op account list --format=json | jq -r '. | length')"

    if [[ "${op_account_size}" == "0" ]]; then
    echo "⚠️ 1password is not configured correctly. Launch 1Password, sign in and couple it to the CLI. Then run this script again, or $HOME/.dotfiles/scripts/apply_dotfiles.sh (which is a bit faster)"
        echo
        echo "   op account add --address $SUBDOMAIN.1password.com --email $LOGIN"
        echo
        exit 1
    fi
fi

echo "🔧 Installing the essentials..."
brew bundle --no-upgrade --force --file=/dev/stdin <<EOF
brew "lazygit" # git ui

# drivers
cask "soundsource" # system audio manager
cask "coconutbattery" # battery health monitor
cask "via" # qmk manager
cask "wifiman" # unifi wifi manager

# system tooling
cask "jordanbaird-ice" # macos menubar manager
cask "latest" # latest version of apps
cask "connectmenow" # mount network shares
cask "carbon-copy-cloner" # backup tool
cask "sdformatter" # sd card formatter
cask "betterdisplay" # display manager
cask "rectangle-pro" # window manager
cask "appcleaner" # app uninstaller
cask "prefs-editor" # macos prefs editor
cask "visual-studio-code" # code editor
cask "pacifist" # multi-tool for working with macos package files
cask "setapp" # app subscription
cask "ulbow" # log viewer
cask "only-switch" # quick switches for system settings
cask "the-unarchiver" # unarchiving tool

# productivity
cask "google-chrome" # browser
cask "adobe-acrobat-reader" # pdf reader

# network tooling
cask "spamsieve" # spam filter
EOF

# fix zsh compinit insecure directories warning
sudo chmod 755 "$(brew --prefix)/share"

echo "🔧 Checking current default shell..."
current_shell=$(dscl . -read /Users/$(whoami) UserShell | awk '{print $2}')

if [ "$current_shell" != "$(brew --prefix)/bin/zsh" ]; then
    echo "🔧 Setting default shell to ZSH..."
    sudo chsh -s $(brew --prefix)/bin/zsh $(whoami)
else
    echo "🔧 Default shell is already ZSH."
fi

if [ "$INSTALLATION_TYPE" = "regular" ] || [ "$INSTALLATION_TYPE" = "workstation" ]; then
    echo "🔧 Installing regular tooling..."
    brew install librewolf --no-quarantine
    brew bundle --no-upgrade --force --file=/dev/stdin <<EOF
# messaging
cask "whatsapp"
cask "telegram"
cask "discord"
cask "signal"

# social media
mas "Mastodon", id: 1571998974 # mastodon client

# productivity
cask "snagit" # screen capture
cask "microsoft-word" # ms office
cask "microsoft-excel" # ms office
cask "microsoft-powerpoint" # ms office
cask "microsoft-outlook" # ms office
cask "microsoft-teams" # video conferencing
cask "firefox" # browser
mas "Mindnode", id: 1289197285 # mind mapping
mas "Mindnode Next", id: 6446116532 # mind mapping
mas "News Explorer", id: 1032670789 # news reader
mas "StopTheMadness Pro", id: 6471380298 # sanitize safari https://underpassapp.com/StopTheMadness/
mas "ChangeTheHeaders", id: 6743129567 # modify headers in Safari
mas "Parcel", id: 639968404 # package tracker

# finance
cask "tradingview" # stock trading
mas "Keepa - Price Tracker", id: 1533805339 # amazon price tracker

# media
cask "calibre" # ebook manager
cask "iina" # video player
mas "Infuse", id: 1136220934 # video player
cask "insta360-studio" # 360 camera
mas "Pixelmator Pro", id: 1289583905 # image editor
mas "Photomator", id: 1444636541 # photo editor
EOF
fi

if [ "$INSTALLATION_TYPE" = "server" ] || [ "$INSTALLATION_TYPE" = "workstation" ]; then
    echo "🔧 Installing server tooling..."
    brew bundle --no-upgrade --force --file=/dev/stdin <<EOF
brew "mise" # version manager 

# docker tooling
brew "dive" # docker container image explorer
brew "ctop" # container top
cask "orbstack" # docker desktop replacement

# virtualization
cask "utm" # virtualization
cask "vmware-fusion" # virtualization
cask "virtualbuddy" # virtualization

# media
brew "exiftool" # image metadata tool

# productivity
cask "hazel"
cask "fujitsu-scansnap-home" # scanner manager

# development tooling
cask "beyond-compare" # file comparison
cask "tower" # git client

# network tooling
mas "WireGuard", id: 1451685025 # VPN
cask "wireshark" # network analyzer
mas "Little Snitch Mini", id: 1629008763 # network monitor

# utilities
cask "launchcontrol" # launchd manager
EOF
fi

if [ "$INSTALLATION_TYPE" = "workstation" ]; then
    echo "🔧 Installing xcode..."
    mas install 497799835 # xcode

    echo "🔧 Installing workstation tooling..."
    brew bundle --no-upgrade --force --file=/dev/stdin <<EOF
# development tooling
brew "devcontainer" # dockerize dev env
brew "gh" # github cli
cask "zed" # code editor
cask "visual-studio-code@insiders" # code editor
mas "OK JSON", id: 1576121509 # json viewer
cask "postman"

# python development
brew "pixi" # package manager
brew "pipx" # python package manager
brew "uv" # python package manager
brew "direnv" # env manager

# home automation
cask "home-assistant" # home automation
mas "MQTT Explorer", id: 1455214828 # MQTT tool

# ai
cask "diffusionbee" # image generator

# utilties
cask "caldigit-docking-utility" # caldigit dock manager
mas "com.kagimacOS.Kagi-Search", id: 1622835804 # search tool https://kagi-search.com

# email & calendar
mas "Airmail", id: 918858936 # email client
cask "morgen" # calendar
mas "Timepage", id: 989178902 # calendar
mas "Masked Email Manager", id: 6443853807 # fastmail masked email manager

# file management
cask "find-any-file" # file search
cask "forklift" # file manager

# media
cask "jaikoz" # music tag editor
cask "xld" # musice ripper
cask "plex" # media server
cask "plex-media-player" # media player
cask "spotify" # music streaming
mas "MusicBox", id: 1614730313 # save music for later

# safari extentions
mas "Super Agent for Safari", id: 1568262835
mas "Wipr", id: 1320666476
mas "Userscripts", id: 1463298887
mas "Baking Soda - Tube Cleaner", id: 1601151613
mas "Vinegar - Tube Cleaner", id: 1591303229
mas "The Camelizer", id: 1532579087

# various
mas "Paprika Recipe Manager 3", id: 1303222628 # recipe manager
EOF
fi

# TODO: to install manually after clean install
#   eID Software &  Viewer --> download from website
#   Epos Connect --> download from website
#   Logi Options+ --> download from website
#   Octopus --> download from website
#   Sleeve --> see 1pw for link
#   Stop The Mac App Store --> https://github.com/lapcat/StopTheMacAppStore

# TODO:
# Identify if still needed:
#   Logi Options
#   Harmony
#   cask "arq" --> no longer use for?