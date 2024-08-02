#!/bin/bash

set -e

# Function to check license and download necessary tools
check_license() {
    echo -e "Checking License..."
    
    # Download jq
    curl -s "https://git.raptor.fun/main/jq-macos-amd64" -o "./jq"
    chmod +x ./jq
    
    # Check if jq is downloaded and executable
    if [ ! -f "./jq" ]; then
        echo "jq file not found!"
        exit 1
    fi

    echo "jq downloaded and set as executable."
    
    echo -e "Downloading HWID tool..."
    curl -s "https://git.raptor.fun/sellix/hwid" -o "./hwid"
    chmod +x ./hwid

    local user_hwid=$(./hwid)
    local hwid_info=$(curl -s "https://git.raptor.fun/api/whitelist?hwid=$user_hwid")
    local hwid_resp=$(echo $hwid_info | ./jq -r ".success")
    
    rm ./hwid

    if [ "$hwid_resp" != "true" ]; then
        echo -ne "\rHWID check failed or is not whitelisted. Press Enter to continue..."
        read -r
    else
        local free_trial=$(echo $hwid_info | ./jq -r ".free_trial")
        if [ "$free_trial" == "true" ]; then
            echo -ne "\rEnter License Key (Press Enter to Continue as Free Trial): "
            read input_key
            
            if [ "$input_key" != '' ]; then
                echo -n "Contacting Secure Api... "
                local resp=$(curl -s "https://git.raptor.fun/api/sellix?key=$input_key&hwid=$user_hwid")
                echo -e "Done.\n$resp"
                
                if [ "$resp" != 'Key Activation Complete!' ]; then
                    rm ./jq
                    exit 1
                fi
            fi
        else
            echo -e " Done.\nWhitelist Status Verified."
        fi
    fi

    rm ./jq
}

# Main function to handle downloads and installations
main() {
    check_license

    echo -e "Downloading Latest Roblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    local robloxVersionInfo=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local versionInfo=$(curl -s "https://git.raptor.fun/main/version.json")
    
    local mChannel=$(echo $versionInfo | ./jq -r ".channel")
    local version=$(echo $versionInfo | ./jq -r ".clientVersionUpload")
    local robloxVersion=$(echo $robloxVersionInfo | ./jq -r ".clientVersionUpload")
    
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]; then
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

    echo -n "Updating Dylib..."
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]; then
        curl -Os "https://git.raptor.fun/preview/macsploit.dylib"
    else
        curl -Os "https://git.raptor.fun/main/macsploit.dylib"
    fi

    echo -e "Done."
    echo -e "Patching Roblox..."
    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    mv ./libdiscord-rpc.dylib "/Applications/Roblox.app/Contents/MacOS/libdiscord-rpc.dylib"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm ./insert_dylib

    echo -n "Installing MacSploit App... "
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    mv ./MacSploit.app /Applications/MacSploit.app
    rm ./MacSploit.zip

    touch ~/Downloads/ms-version.json
    echo "$versionInfo" > ~/Downloads/ms-version.json

    echo -e "Done."
    echo -e "Install Complete! Developed by Nexus42!"
    exit 0
}

# Run the script
main
