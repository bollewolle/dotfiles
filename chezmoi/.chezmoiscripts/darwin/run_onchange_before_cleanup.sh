#!/bin/bash
# run_onchange_before_ scripts are run in alphabetical order before updating the dotfiles and only when the content of the file changes.
# Purpose: Use this script to add packages/software which was used before but that need to be removed as they are no longer used
echo "🗑️ Cleanup packages..."

# E.g. remove from brew if no longer used
# brew remove xxx || true