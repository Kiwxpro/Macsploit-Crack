#!/bin/bash

set -e

echo -e "Downloading JSON Parser..."
curl -s "https://cdn.discordapp.com/attachments/1000184107281690696/1154250203650605107/jq-macos-amd64" -o "./jq"
chmod +x ./jq

echo -e "Downloading Latest Roblox..."
[ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer" | ./jq -r ".clientVersionUpload" > robloxVersion.txt
robloxVersion=$(cat robloxVersion.txt)
curl -s "https://git.raptor.fun/main/version.json" | ./jq -r ".clientVersionUpload" > version.txt
version=$(cat version.txt)

if [ "$version" != "$robloxVersion" ]; then
    curl "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
else
    curl "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
fi

echo -n "Installing Latest Roblox... "
[ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"
unzip -o -q "./RobloxPlayer.zip"
mv ./RobloxPlayer.app /Applications/Roblox.app
rm ./RobloxPlayer.zip
echo -e "Done."

echo -e "Downloading MacSploit..."
curl -sL "https://git.raptor.fun/main/macsploit.zip" -o "./MacSploit.zip"

echo -n "Installing MacSploit... "
unzip -o -q "./MacSploit.zip"
echo -e "Done."

echo -e "Install Complete!"
