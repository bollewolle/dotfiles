#!/bin/bash
# run_onchange_after_ scripts are run in alphabetical order after updating the dotfiles and only when the content of the file changes.
# Purpose: Use this script to set various MacOS system defaults after the dotfiles have been updated. See https://macos-defaults.com/ for a good resource. Other inspiractions: https://github.com/kevinSuttle/macOS-Defaults/blob/master/.macos
echo "🔧 Setting a couple of macos defaults..."

# Global System Settings
## Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en" "nl" >> /dev/null
defaults write NSGlobalDomain AppleLocale -string "en_BE@currency=EUR" >> /dev/null
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters" >> /dev/null
defaults write NSGlobalDomain AppleMetricUnits -bool true >> /dev/null

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
# sudo systemsetup -settimezone "Europe/Brussels" > /dev/null

## Always use exapnded print dialog
defaults write -g PMPrintingExpandedStateForPrint -bool TRUE >> /dev/null

## Enable SSH
sudo systemsetup -setremotelogin on

## Never go into computer sleep mode
sudo systemsetup -setcomputersleep Off > /dev/null >> /dev/null

## Hibernate mode 3: Copy RAM to disk so the system state can still be restored in case of a power failure.
sudo pmset -a hibernatemode 3 >> /dev/null

## Enable powernap
sudo pmset -a powernap 1 >> /dev/null

## Disable lowpowermode
sudo pmset -a lowpowermode 0 >> /dev/null

# Reduce menu bar spacing
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 10 >> /dev/null
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 10 >> /dev/null

# Desktop & Dock
## Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true >> /dev/null
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true >> /dev/null

## Scroll to Exposé app
defaults write com.apple.dock scroll-to-open -bool true >> /dev/null

## Hotcorners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lockscreen
# 14: Quick Note
# Top left screen corner --> Show application windows
defaults write com.apple.dock wvous-tl-corner -int 3 >> /dev/null
defaults write com.apple.dock wvous-tl-modifier -int 0 >> /dev/null
# Top right screen corner --> Desktop
defaults write com.apple.dock wvous-tr-corner -int 4 >> /dev/null
defaults write com.apple.dock wvous-tr-modifier -int 0 >> /dev/null
# Bottom left screen corner --> Quick Note
defaults write com.apple.dock wvous-bl-corner -int 14 >> /dev/null
defaults write com.apple.dock wvous-bl-modifier -int 0 >> /dev/null
# Bottom right screen corner --> Mission Control
defaults write com.apple.dock wvous-bl-corner -int 2 >> /dev/null
defaults write com.apple.dock wvous-bl-modifier -int 0 >> /dev/null

# Finder
## Show Hard Drives on Desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true >> /dev/null

## Default view style
defaults write com.apple.finder FXPreferredViewStyle -string "clmv" >> /dev/null

## Show hidden files inside the Finder
defaults write com.apple.finder AppleShowAllFiles -bool true >> /dev/null

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true >> /dev/null

# Menu Bar
## Set menubar digital clock format
defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm:ss\"" >> /dev/null

# Screenshots
## Set Location - Save screenshots to the ~/Pictures/Screenshots folder
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots" >> /dev/null

# Bluetooth
## Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40 >> /dev/null