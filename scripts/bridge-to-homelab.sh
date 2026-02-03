#!/bin/bash

# This script sets up a temporary bridge to the homelab platform repository
# so that a coding agent can work on both repos simultaneously.

BRIDGE_DIR=".homelab-bridge"
PLATFORM_REPO="https://github.com/SiderealMollusk/rita-pve02.git"

echo "🏗️ Setting up Homelab Bridge..."

if [ -d "$BRIDGE_DIR" ]; then
    echo "⚠️ Bridge directory already exists. Pulling latest changes..."
    cd "$BRIDGE_DIR" && git pull && cd ..
else
    echo "📥 Cloning platform repository into $BRIDGE_DIR..."
    git clone "$PLATFORM_REPO" "$BRIDGE_DIR"
fi

# Ensure the bridge is ignored by git
if ! grep -q "$BRIDGE_DIR" .gitignore; then
    echo "🙈 Adding $BRIDGE_DIR to .gitignore..."
    echo "" >> .gitignore
    echo "# Homelab Bridge" >> .gitignore
    echo "$BRIDGE_DIR/" >> .gitignore
fi

echo "✅ Bridge ready. You can now start your coding agent in the root of this project."
echo "💡 The agent will have access to both the app (src/) and the infrastructure ($BRIDGE_DIR/)."
