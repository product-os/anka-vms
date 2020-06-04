#!/bin/sh

set -ueix

NAME=macOSCatalinaNodejs

# For Catalina Anka VMs, –ram-size value should be 4G
# and –disk-size should be 80G.
ANKA_DEFAULT_USER=anka \
ANKA_DEFAULT_PASSWD=admin \
anka create \
  --ram-size 4G \
  --cpu-count 2 \
  --disk-size 80G \
  --app /Applications/Install\ macOS\ Catalina.app \
  "$NAME"

UUID="$(anka show "$NAME" uuid)"

anka start "$UUID"

run() {
  anka run --no-volume --wait-network --wait-time "$UUID" "$@"
}

#################################################
# Homebrew
#################################################

HOMEBREW_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"

# The CI option ensures that the Homebrew install script
# doesn't request interactive user input.
run env CI=1 /bin/bash -c "$(curl -fsSL "$HOMEBREW_INSTALL_SCRIPT_URL")"

#################################################
# Xcode
#################################################

# Provides `xcversion`.
# See https://github.com/KrauseFx/xcode-install
run sudo gem install xcode-install

# Set the right Apple Developer username/email & password
# TODO: Create a Fastlane session for CI purposes, otherwise
# we get the 2FA prompt.
# See https://github.com/fastlane/fastlane/tree/master/spaceship#2-step-verification
run env FASTLANE_USER=XXX FASTLANE_PASSWORD=XXX xcversion install 11

#################################################
# Base Dependencies
#################################################

run brew install git jq python nodejs
