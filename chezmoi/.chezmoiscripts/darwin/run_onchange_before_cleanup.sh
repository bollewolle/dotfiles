#!/bin/bash
# run_onchange_before_ scripts are run in alphabetical order before updating the dotfiles and only when the content of the file changes.
# Purpose: Use this script to add packages/software which was used before but that need to be removed as they are no longer used
if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/source-tooling.sh
fi

echo "🗑️ Cleanup packages..."

if ! command -v brew &> /dev/null; then
  echo "brew not found, nothing to clean..."
  exit 0
fi

# use mise
brew remove asdf
rm -rf ~/.asdf
brew remove direnv || true
brew remove uv pipx pixi || true

# nope
brew remove "windsurf" || true
brew remove "cursor" || true
brew remove "visual-studio-code" || true
brew remove "visual-studio-code@insiders" || true
brew remove "vscodium@insiders" || true

# use brew proper
brew remove 1password/tap/1password-cli || true
brew untap 1password/tap || true
