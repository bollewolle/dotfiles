#!/bin/bash
# run_onchange_after_ scripts are run in alphabetical order after updating the dotfiles and only when the content of the file changes.
# Purpose: Use this script to set various MacOS system defaults after the dotfiles have been updated. See https://macos-defaults.com/ for a good resource. Also see https://apps.tempel.org/PrefsEditor/ as very useful app.
# Main inspiration: https://gist.github.com/ChristopherA/98628f8cd00c94f11ee6035d53b0d3c6
# Other inspirations: https://github.com/kevinSuttle/macOS-Defaults/blob/master/.macos

if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/installation-type.sh
else
    echo "☢️  No installation type set, did you run this script directly? Set INSTALLATION_TYPE using an env var if needed."
fi

if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/source-tooling.sh
fi

darwin_check_full_disk_access() {
  if [ "$(uname -s)" = "Darwin" ]; then
    if ! plutil -lint /Library/Preferences/com.apple.TimeMachine.plist >/dev/null ; then
      echo "This script requires your terminal app to have Full Disk Access. Add this terminal to the Full Disk Access list in System Preferences > Security & Privacy, quit the app, and re-run this script."
      open 'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles'
      exit 1
    else
      echo "Your terminal has Full Disk Access"
    fi
  fi
}

darwin_check_full_disk_access

sudo -v

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
# GENERAL
## Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en-BE" "nl-BE" >> /dev/null
defaults write NSGlobalDomain AppleLocale -string "en_BE@currency=EUR" >> /dev/null
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters" >> /dev/null
defaults write NSGlobalDomain AppleMetricUnits -bool true >> /dev/null

## Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "Europe/Brussels" 2>/dev/null 1>&2

## Always use exanded print panel
defaults write -g PMPrintingExpandedStateForPrint -bool true >> /dev/null

## Always use exanded save panel
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true >> /dev/null

# Enable SSH for admins
sudo systemsetup -setremotelogin on
if ! dseditgroup com.apple.access_ssh &> /dev/null; then
  dseditgroup -o create -q com.apple.access_ssh
fi
sudo dseditgroup -o edit -a admin -t group com.apple.access_ssh

# Enable ARD for admins
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -access -on -users admin -privs -all -restart -agent -menu

## Never go into computer sleep mode
# sudo systemsetup -setcomputersleep Off > /dev/null >> /dev/null
# TODO: this command returns an error when running the script in Sonoma

## Hibernate mode 3: Copy RAM to disk so the system state can still be restored in case of a power failure.
sudo pmset -a hibernatemode 3 >> /dev/null

## Enable powernap
sudo pmset -a powernap 1 >> /dev/null

## Disable lowpowermode
sudo pmset -a lowpowermode 0 >> /dev/null

# APPEARANCE
# >>> Specific settings for workstation/server <<<
if [ "$INSTALLATION_TYPE" = "server" ] || [ "$INSTALLATION_TYPE" = "workstation" ]; then
  # Require password immediately after sleep or screen saver begins
  # defaults write com.apple.screensaver askForPasswordDelay -int 0 >> /dev/null

  # Dark mode
  defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark" >> /dev/null
fi

# SOUND
## Alert sound
defaults write NSGlobalDomain com.apple.sound.beep.sound -string "/System/Library/Sounds/Tink.aiff" >> /dev/null

## Play user interface sound effects (default: 1)
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0 >> /dev/null


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

## Set the icon size of Dock items in pixels (default: 36)
defaults write com.apple.dock tilesize -int 36 >> /dev/null

## Minimize animation effect
# Genie       : `genie` (default)
# Scale       : `scale`
# Suck        : `suck`
defaults write com.apple.dock "mineffect" -string "genie" >> /dev/null

## Enable dock magnification (default: false)
defaults write com.apple.dock magnification -bool true >> /dev/null

## Set dock magnificated icon size.
defaults write com.apple.dock largesize -int 71 >> /dev/null    

## Only show opened apps in Dock
## Default "false"
# defaults write com.apple.dock "static-only" -bool "false" && killall Dock

## Scroll to Exposé app
defaults write com.apple.dock scroll-to-open -bool true >> /dev/null


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

killall Dock

#================================================
# *               FINDER GENERAL
#================================================

# Disable Window animations and Get Info animations (default: false)
# defaults write com.apple.finder DisableAllAnimations -bool true

# File extension change warning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false >> /dev/null

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
defaults write com.apple.finder ShowPathBar -bool true >> /dev/null

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
defaults write com.apple.finder ShowPathbar -bool true >> /dev/null
## later versions use "ShowPathbar"

# Always show icon in the titlebar
defaults write com.apple.universalaccess "showWindowTitlebarIcons" -bool "true" >> /dev/null

#================================================
# *              FINDER SIDE BAR
#================================================

# size of Finder sidebar icons, small=1, default=2, large=3
# (TBD: maybe for Catalina 10.15+ only?)
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "2" >> /dev/null


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
defaults write com.apple.finder ShowMountedServersOnDesktop     -bool false >> /dev/null
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

killall Finder

#================================================
# *             FILEVIEWER DIALOG
#================================================

# by default iCloud Documents are the default directory opened in the fileviewer dialog when saving a new document
# "true" to default to iCloud, false to default to home directory
# (TBD: maybe for Catalina 10.15+ only?)
# defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false" 


#================================================
# *                   SAFARI
#================================================

# NOTE: Safari is Sandboxed, the preferences can now be found here:
# ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.plist

# NOTE: Many of those that worked before don't work anymore, and those that do require Terminal
# to have Full Disk Access (which is tested and set above).
# https://lapcatsoftware.com/articles/containers.html
# TODO: test each setting if works in Sonoma


## GENERAL
# Safari opens with: "All windows from last session"
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true >> /dev/null

# Homepage
defaults write com.apple.Safari HomePage -string 'about:blank' >> /dev/null

# Open "safe" files after downloading (default: true)
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false >> /dev/null


## AUTOFILL
# Autofill web forms - "Usernames and password" (default: true)
defaults write com.apple.Safari AutoFillPasswords -bool false >> /dev/null


## ADVANCED
# Smart Search Field - Show full website address (default: false)
defaults write com.apple.safari ShowFullURLInSmartSearchField -bool true >> /dev/null



## VARIOUS
# Show hovering overlay on links (default: false) (set via "View" menu)
defaults write com.apple.Safari ShowOverlayStatusBar -bool true >> /dev/null

# Show favorites bar (default: false) (set via "View" menu)
defaults write com.apple.Safari ShowFavoritesBar-v2 -bool true >> /dev/null

# Show Develop menu in Safari
# defaults write com.apple.Safari IncludeDevelopMenu -bool true
# No longer works like this, is now a value within dictionary "PreferencesModulesMinimumWidths"

# Enable Safari’s Debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true >> /dev/null
# * [x] Does work in Safari 15 on macOS Monterey

killall Safari

#================================================
# *                 SCRIPT MENU
#================================================

#Enable Script Menu (scripts in ~/Library/Scripts/ will be listed in menu bar)
defaults write com.apple.scriptmenu.plist ScriptMenuEnabled true >> /dev/null