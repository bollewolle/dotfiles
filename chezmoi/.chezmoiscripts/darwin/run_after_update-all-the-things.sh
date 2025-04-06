#!/bin/bash
# run_after_ scripts are always run in alphabetical order after updating the dotfiles
# Purpose: Use this script to update everything on your system after the dotfiles have been updated.

# DEACTIVATED BUT NOT YET DELETED - KEEP FOR REFERENCE
# echo "You are using $CHEZMOI_SOURCE_DIR as Chezmoi source directory."

# if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
#     . ${CHEZMOI_SOURCE_DIR}/../scripts/installation-type.sh
# else
#     echo "☢️  No installation type set, did you run this script directly? Assuming 'workstation' installation."
#     INSTALLATION_TYPE=workstation
# fi

if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/source-tooling.sh
fi

bat cache --build
# mise install && mise prune --yes

echo "💡 Upgrade all the things..."
chezmoi upgrade

topgrade || true
brew reinstall librewolf --no-quarantine