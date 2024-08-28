#!/bin/sh

# exit immediately if password-manager-binary is already in $PATH
type password-manager-binary >/dev/null 2>&1 && exit

case "$(uname -s)" in
Darwin)
    echo "Installing Homebrew and 1Password"
    # commands to install password-manager-binary on Darwin
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew list 1password &>/dev/null || brew install 1password
    brew list 1password-cli &>/dev/null || brew install 1password-cli
    if [[ $(op account list | wc -l) -lt 1 ]]; then
        open -a '1Password'
        read -p "Log into 1Password and enable 1Password-CLI integration. Enter to continue..."
    fi
    echo "Please provide your 1Password account to log in:"
    read 1pwaccount
    eval $(op signin --account $1pwaccount)
    ;;
Linux)
    echo "Script incomplete to install 1Password, do manually"
    # commands to install password-manager-binary on Linux
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac