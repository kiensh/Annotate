#!/bin/bash

# Generate Sparkle appcast signature and metadata
# Usage: ./generate_appcast.sh <dmg_path> <private_key>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <dmg_path> <private_key>"
    exit 1
fi

set -euo pipefail

DMG_PATH="$1"
PRIVATE_KEY="$2"
APP_NAME="Annotate"
EXPORT_DIR="build/export"

echo "📊 Generating appcast metadata for: $(basename "$DMG_PATH")"

# Install Sparkle tools if not present
if [ ! -d "Sparkle-2.8.0" ]; then
    echo "📥 Installing Sparkle tools..."
    curl -L https://github.com/sparkle-project/Sparkle/releases/download/2.8.0/Sparkle-2.8.0.tar.xz | tar -xJ
fi

# Get file size
FILE_SIZE=$(stat -f%z "$DMG_PATH")
echo "📏 File size: $FILE_SIZE bytes"

# Generate EdDSA signature
echo "$PRIVATE_KEY" > private_key.pem
SIGNATURE=$(./Sparkle-2.8.0/bin/sign_update "$DMG_PATH" private_key.pem)
echo "🔐 Generated signature: $SIGNATURE"
rm private_key.pem

# Get bundle version from built app
BUNDLE_VERSION=$(defaults read "$EXPORT_DIR/$APP_NAME.app/Contents/Info.plist" CFBundleVersion)
echo "📦 Bundle version: $BUNDLE_VERSION"

# Output for GitHub Actions
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "file_size=$FILE_SIZE" >> "$GITHUB_OUTPUT"
    echo "signature=$SIGNATURE" >> "$GITHUB_OUTPUT"
    echo "bundle_version=$BUNDLE_VERSION" >> "$GITHUB_OUTPUT"
fi

echo "✅ Appcast metadata generated successfully"