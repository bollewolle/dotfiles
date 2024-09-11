#!/bin/bash
# run_onchange_after_ scripts are run in alphabetical order after updating the dotfiles and only when the content of the file changes.
# Purpose: Use this script to set various MacOS system defaults after the dotfiles have been updated. See https://macos-defaults.com/ for a good resource. Also see https://apps.tempel.org/PrefsEditor/ as very useful app.
# Main inspiration: https://gist.github.com/ChristopherA/98628f8cd00c94f11ee6035d53b0d3c6
# Other inspiractions: https://github.com/kevinSuttle/macOS-Defaults/blob/master/.macos

echo "🔧 Setting a couple of macos defaults..."

#================================================
# *           CLOSE SYSTEM PREFERENCES
#================================================

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

#================================================
# *           GLOBAL SYSTEM SETTINGS
#================================================
## Set Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark" >> /dev/null

## Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en-BE" "nl-BE" >> /dev/null
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


#================================================
# *                  VARIOUS
#================================================
# Menu Bar
## Reduce menu bar spacing
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 10 >> /dev/null
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 10 >> /dev/null

## Set menubar digital clock format
defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm:ss\"" >> /dev/null

# Screenshots
## Set Location - Save screenshots to the ~/Pictures/Screenshots folder
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots" >> /dev/null

# Bluetooth
## Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40 >> /dev/null


#================================================
# *                     DOCK
#================================================

## Set position of the Dock
# defaults write com.apple.dock orientation bottom #default
# defaults write com.apple.dock orientation right #right

## Set the icon size of Dock items to 27 pixels
defaults write com.apple.dock tilesize -int 27 >> /dev/null
# defaults write com.apple.dock tilesize -int ??

## Scroll to Exposé app
defaults write com.apple.dock scroll-to-open -bool true >> /dev/null


#================================================
# *               FINDER GENERAL
#================================================

# Disable Window animations and Get Info animations (default: false)
# defaults write com.apple.finder DisableAllAnimations -bool true

# File extension change warning
# defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true >> /dev/null
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true >> /dev/null

# Disk image verification
# defaults write com.apple.frameworks.diskimages skip-verify        -bool true
# defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
# defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted
# defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool false
# defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool false
# defaults write com.apple.finder OpenWindowForNewRemovableDisk    -bool false

# AirDrop over Ethernet and on unsupported Macs running Lion
# defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Warning before emptying Trash
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely
# defaults write com.apple.finder EmptyTrashSecurely -bool false


#================================================
# *               FINDER WINDOWS
#================================================

# Visibility of hidden files (default: false)
# I lately use `⌘-.` to switch between showing hidden files manually
defaults write com.apple.finder AppleShowAllFiles -bool true >> /dev/null

# Filename extensions (default: false)
# See my applescript for showing and hiding extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true >> /dev/null

# Status bar (default: false)
defaults write com.apple.finder ShowStatusBar -bool true >> /dev/null

# Full POSIX path as window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool false >> /dev/null

# Path bar
defaults write com.apple.finder ShowPathbar -bool true >> /dev/null

# Text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true >> /dev/null

# Search scope
# This Mac       : `SCev`
# Current Folder : `SCcf`
# Previous Scope : `SCsp`
# I prefer current folder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" >> /dev/null

# Arrange by
# Kind, Name, Application, Date Last Opened,
# Date Added, Date Modified, Date Created, Size, Tags, None
defaults write com.apple.finder FXPreferredGroupBy -string "Name" >> /dev/null

# Spring loaded directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true >> /dev/null

# Delay for spring loaded directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0.3 >> /dev/null

# Preferred view style
# Icon View   : `icnv`
# List View   : `Nlsv`
# Column View : `clmv`
# Cover Flow  : `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "clmv" >> /dev/null

# After configuring preferred view style, clear all `.DS_Store` files
# to ensure settings are applied for every directory
find . -name '.DS_Store' -type f -delete

# Keep folders on top when sorting by name
# defaults write com.apple.finder _FXSortFoldersFirst -bool true

# View Options
# ! This no longer works in Monterey 12.0.1
# ColumnShowIcons    : Show preview column
# ShowPreview        : Show icons
# ShowIconThumbnails : Show icon preview
# ArrangeBy          : Sort by
#   dnam : Name
#   kipl : Kind
#   ludt : Date Last Opened
#   pAdd : Date Added
#   modd : Date Modified
#   ascd : Date Created
#   logs : Size
#   labl : Tags
# /usr/libexec/PlistBuddy \
#     -c "Set :StandardViewOptions:ColumnViewOptions:ColumnShowIcons bool    false" \
#     -c "Set :StandardViewOptions:ColumnViewOptions:FontSize        integer 11"    \
#     -c "Set :StandardViewOptions:ColumnViewOptions:ShowPreview     bool    true"  \
#     -c "Set :StandardViewOptions:ColumnViewOptions:ArrangeBy       string  dnam"  \
#     ~/Library/Preferences/com.apple.finder.plist

# New window target
# Computer     : `PfCm`
# Volume       : `PfVo`
# $HOME        : `PfHm`
# Desktop      : `PfDe`
# Documents    : `PfDo`
# All My Files : `PfAF`
# Other…       : `PfLo`
defaults write com.apple.finder NewWindowTarget -string 'PfHm' >> /dev/null
#defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

# show full POSIX path as Finder window title, default false
defaults write com.apple.finder _FXShowPosixPathInTitle -bool false >> /dev/null

# show status bar in Finder windows
defaults write com.apple.finder ShowStatusBar -bool true >> /dev/null

# show path bar in Finder windows
defaults write com.apple.finder ShowPathBar -bool true >> /dev/null
## later versions use "ShowPathbar"


#================================================
# *              FINDER SIDE BAR
#================================================

# size of Finder sidebar icons, small=1, default=2, large=3
# (TBD: maybe for Catalina 10.15+ only?)
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "1" >> /dev/null


#================================================
# *              FINDER DESKTOP
#================================================

# Desktop Enabled
defaults write com.apple.finder CreateDesktop -bool true >> /dev/null

# Quitting via ⌘ + Q; doing so will also hide desktop icons
# defaults write com.apple.finder QuitMenuItem -bool true

# Icons for hard drives, servers, and removable media on the desktop (default: false)
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true >> /dev/null
defaults write com.apple.finder ShowHardDrivesOnDesktop         -bool true >> /dev/null
defaults write com.apple.finder ShowMountedServersOnDesktop     -bool true >> /dev/null
defaults write com.apple.finder ShowRemovableMediaOnDesktop     -bool true >> /dev/null

# Size of icons on the desktop and in other icon views (default: 64)
# /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 32" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist

# Grid spacing for icons on the desktop and in other icon views (default: 54)
# /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist

# Show item info near icons on the desktop and in other icon views (default: false)
# /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo false" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo false" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo false" ~/Library/Preferences/com.apple.finder.plist

# Show item info about the icons on the desktop (default: false)
# /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist


#================================================
# *             FILEVIEWER DIALOG
#================================================

# by default iCloud Documents are the default directory opened in the fileviewer dialog when saving a new document
# "true" to default to iCloud, false to default to home directory
# (TBD: maybe for Catalina 10.15+ only?)
# defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false" 


#================================================
# *                 HOT CORNERS
#================================================
# Hot corners
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
defaults write com.apple.dock wvous-br-corner -int 2 >> /dev/null
defaults write com.apple.dock wvous-br-modifier -int 0 >> /dev/null


#================================================
# *                   SAFARI
#================================================

# ? NOTE: Many of these don't work anymore, and those that do require Terminal
# ? to have Full Disk Access (which is tested and set above).
# ? https://lapcatsoftware.com/articles/containers.html
# TODO: test each setting if works in Monterey & Big Sur.

# Delete the old redundant .plist file, the correct location is
# ~/Library/Containers/com.apple.Safari since Safari 13 in Catalina 10.15

# Get Safari Version
read osx_safari_version osx_safari_version_major osx_safari_version_minor osx_safari_version_patch \
    <<< $(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" \
    /Applications/Safari.app/Contents/Info.plist | \
    awk -F. '{print $0 " " $1 " " $2 " " $3}')

# If Safari 13 or greater, delete outdated redundant pref file from earlier Safari
if [[ -f ~/Library/Preferences/com.apple.Safari.plist && "$osx_safari_version_major" -ge 13 ]]; then
    rm ~/Library/Preferences/com.apple.Safari.plist
fi

# Show status bar
# defaults write com.apple.Safari ShowStatusBar -bool true
# ! Doesn't seem to work Safari 15 on macOS Monterey

# Show hovering overlay on links
defaults write com.apple.Safari ShowOverlayStatusBar -bool true #default is false
# * [x] Does work in Safari 15 on macOS Monterey

# Safari opens with: last session
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true
# * [x] Does work in Safari 15 on macOS Monterey
# * [x] Does work in Safari 14.1.2 on macOS Mojave 10.14.6

# Set Safari’s home page to `about:blank` for faster loading
# defaults write com.apple.Safari HomePage -string "about:blank"
# ! Doesn't seem to work Safari 15 on macOS Monterey
# ? [ ] Set manually

# Don't open files in Safari after downloading:
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
# * [x] Does work in Safari 15 on macOS Monterey

# Show Develop menu in Safari
# defaults write com.apple.Safari IncludeDevelopMenu -bool true
# ! Doesn't seem to work Safari 15 on macOS Monterey, as it is now Debug
# TODO wrap these to test safari version

# Enable Safari’s Debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
# * [x] Does work in Safari 15 on macOS Monterey

#================================================
# *                 SCRIPT MENU
#================================================

#Enable Script Menu (scripts in ~/Library/Scripts/ will be listed in menu bar)
defaults write com.apple.scriptmenu.plist ScriptMenuEnabled true