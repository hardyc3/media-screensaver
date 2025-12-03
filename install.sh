#!/bin/bash

# Roku Media Screensaver Install Script
# Usage: ./install.sh <ROKU_IP> <DEVELOPER_PASSWORD>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <ROKU_IP> <DEVELOPER_PASSWORD>"
    echo "Example: $0 192.168.1.100 mypassword"
    exit 1
fi

ROKU_IP=$1
DEV_PASSWORD=$2

echo "Installing Media Screensaver to Roku at $ROKU_IP..."

# Build the app
cd source
python3 -c "
import zipfile
import os

# Create zip file
with zipfile.ZipFile('../makefile/dist/apps/MediaScreensaver.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk('.'):
        for file in files:
            if not file.endswith('.DS_Store'):
                file_path = os.path.join(root, file)
                zipf.write(file_path, file_path)

print('MediaScreensaver.zip created successfully')
"

# Install to Roku
echo "Installing to Roku..."
curl --user rokudev:$DEV_PASSWORD --digest --show-error \
    -F "mysubmit=Install" \
    -F "archive=@../makefile/dist/apps/MediaScreensaver.zip" \
    http://$ROKU_IP/plugin_install

echo ""
echo "Installation complete! Look for 'Media Screensaver' on your Roku TV."
echo "Press * key to open settings once the app is running."