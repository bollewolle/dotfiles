#!/bin/bash
# run_onchange_before_ scripts are run in alphabetical order before updating the dotfiles and only when the content of the file changes.
# Purpose: Use this script to add packages/software which was used before but that need to be removed as they are no longer used
echo "🗑️ Cleanup packages..."

# Install source tooling (e.g. PATH)
if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/source-tooling.sh
fi

if ! command -v brew &> /dev/null; then
  echo "brew not found, nothing to clean..."
  exit 0
fi

# E.g. remove from brew if no longer used
# brew remove xxx || true