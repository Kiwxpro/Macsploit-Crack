#!/bin/bash

set -e

# Download and install jq
echo -e "Downloading JSON Parser..."
curl -sL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64 -o ./jq
chmod +x ./jq

# Verify jq installation
if ! ./jq --version >/dev/null 2>&1; then
    echo -e "Failed to download or make jq executable."
    exit 1
fi

echo -e "Downloading Latest Roblox..."
[ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip

robloxVersionInfo=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
versionInfo=$(curl -s "https://git.raptor.fun/main/version.json")

robloxVersion=$(echo "$robloxVersionInfo" | ./jq -r ".clientVersionUpload")
version=$(echo "$versionInfo" | ./jq -r ".clientVersionUpload")

if [ "$version" != "$robloxVersion" ]; then
    curl -L "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
else
    curl -L "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
fi

echo -n "Installing Latest Roblox... "
[ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"
unzip -o -q "./RobloxPlayer.zip"
mv ./RobloxPlayer.app /Applications/Roblox.app
rm ./RobloxPlayer.zip
echo -e "Done."

echo -e "Downloading MacSploit..."
curl -L "https://git.raptor.fun/main/macsploit.zip" -o "./MacSploit.zip"

echo -n "Installing MacSploit... "
unzip -o -q "./MacSploit.zip"
echo -e "Done."

echo -e "Install Complete!"

