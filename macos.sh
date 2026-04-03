#!/usr/bin/env bash
set -euo pipefail # Exit on error, undefined variables, and pipe failures

# Optional debug tracing
# Run with DEBUG=1 ./macos.sh to print every command to the console
[[ "${DEBUG:-}" ]] && set -x

###############################################################################
# Helper functions                                                            #
###############################################################################

# Prompt user to do something, then wait for a keypress before continuing.
prompt_user() {
    local message="$1"
    echo ""
    echo "$message"
    read -n 1 -s -p "Press any key to continue..."
    echo ""
}

###############################################################################
# Dock                                                                        #
###############################################################################

# Maximise icon to dock ratio with maximum size
defaults write com.apple.dock tilesize -int 47

# Place dock on the right
defaults write com.apple.dock orientation -string "right"

# Remove default apps from dock
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock persistent-others -array

# Prevent showing windows in dock
defaults write com.apple.dock minimize-to-application -bool true

# Disable genie effect when minimising windows
defaults write com.apple.dock mineffect -string "scale"

# Disable hot corners
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-br-corner -int 0

# Add apps to dock
apps=(
    "/Applications/Firefox.app"
    "/Applications/Signal.app"
)

for app in "${apps[@]}"; do
    defaults write com.apple.dock persistent-apps -array-add \
    "<dict>
        <key>tile-data</key>
        <dict>
            <key>file-data</key>
            <dict>
                <key>_CFURLString</key>
                <string>$app</string>
                <key>_CFURLStringType</key>
                <integer>0</integer>
            </dict>
        </dict>
    </dict>"
done

###############################################################################
# Desktop                                                                     #
###############################################################################

# Hide widgets from desktop
defaults write com.apple.WindowManager StandardHideWidgets -bool true

# Disable clicking wallpaper to show desktop items
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

###############################################################################
# AirDrop                                                                     #
###############################################################################

# Allow AirDrop to receive from Everyone
defaults write com.apple.sharingd DiscoverableMode -string "Everyone"

###############################################################################
# Finder                                                                      #
###############################################################################

# Create custom main folder
mkdir -p "$HOME/jameswalden"

# New Finder windows show ~/jameswalden
_finder_url="file://${HOME}/jameswalden/"
defaults write com.apple.finder NewWindowTargetPath -string "${_finder_url// /%20}"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search the current folder when performing a search
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Hide Recent Tags from sidebar
defaults write com.apple.finder ShowRecentTags -bool false

# Show path bar at bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true

# Default to list view for all folders
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# View options (list): sort by name
FINDER_PLIST="$HOME/Library/Preferences/com.apple.finder.plist"
/usr/libexec/PlistBuddy -c "Add :StandardViewSettings dict" "$FINDER_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :StandardViewSettings:ExtendedListViewSettingsV2 dict" "$FINDER_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :StandardViewSettings:ExtendedListViewSettingsV2:sortColumn string name" "$FINDER_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:ExtendedListViewSettingsV2:sortColumn name" "$FINDER_PLIST" 2>/dev/null || true

###############################################################################
# Apply changes                                                               #
###############################################################################

killall Dock WindowManager sharingd Finder 2>/dev/null || true

###############################################################################
# Homebrew                                                                    #
###############################################################################

command -v brew > /dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install git

casks=(
    affinity-photo
    cursor
    firefox
    onlyoffice
    protonvpn
    signal
    spotify
    vlc
)

for cask in "${casks[@]}"; do
    brew install --cask --adopt "$cask"
done

###############################################################################
# Manual steps                                                                #
###############################################################################

prompt_user "Name this laptop: System Settings > General > About > Name: Enter a name for this laptop."
prompt_user "Enable FileVault: System Settings > Privacy & Security > FileVault: Turn on and save recovery key."
prompt_user "Set Low Power Mode: System Settings > Battery: Set Low Power Mode to 'On battery' only, and enable 'Optimize video streaming while on battery'."
prompt_user "Disable startup sound: System Settings > Sound: Disable startup sound."
prompt_user "Limit Spotlight to apps only: System Settings > Spotlight: Disable basically everything except Applications."
prompt_user "Set shortcut Cmd+Shift+S for 'Copy picture of selected area to clipboard': System Settings > Keyboard > Keyboard Shortcuts: Set shortcut Cmd+Shift+S for 'Copy picture of selected area to clipboard'."
prompt_user "Swap Command and Globe: System Settings > Keyboard > Modifier Keys: Swap Command and Globe."
prompt_user "Invert scroll direction: System Settings > Trackpad > Scroll & Zoom: Disable 'Natural scrolling'."
prompt_user "Set key repeat rate to max: System Settings > Keyboard: Set 'Key repeat rate' to Fast and 'Delay until repeat' to Short."

prompt_user "Show battery percentage: Menu bar > Right click on Battery icon > Enable 'Show percentage'."

prompt_user "Clear Finder sidebar: Finder > Settings > Sidebar: clear sidebar, then enable only: Applications, Downloads, External disks, CDs, DVDs and iOS devices."
prompt_user "Add ~/jameswalden to Finder sidebar: Finder: Drag ~/jameswalden into the sidebar under Favourites."
prompt_user "Customize Finder toolbar: Finder: Customize toolbar to keep only the back and forward buttons (remove all other toolbar items)."

prompt_user "Set up Find My: Sign in to iCloud and enable Find My"

prompt_user "Sign in to your Firefox account so bookmarks, passwords, and extensions sync."
prompt_user "Install and enable your NextDNS profile: download the configuration/profile from your NextDNS account and install it in System Settings > VPN, DNS & Profiles."

