#!/usr/bin/env zsh

# Keep the Dock hidden with a 24-hour hover delay
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.67

# Show hidden files and folders, including /usr, /opt, /var, /sbin
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show absolute paths in Finder window titles
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Show the path bar, starting from the filesystem root
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder PathBarRootAtHome -bool false

# Restart to apply
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
