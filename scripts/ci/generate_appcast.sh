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
if [ ! -f "bin/sign_update" ]; then
    echo "📥 Installing Sparkle tools..."
    curl -L https://github.com/sparkle-project/Sparkle/releases/download/2.8.0/Sparkle-2.8.0.tar.xz | tar -xJ
fi

# Get file size
FILE_SIZE=$(stat -f%z "$DMG_PATH")
echo "📏 File size: $FILE_SIZE bytes"

# Generate EdDSA signature
echo "🔑 Writing private key to file..."
KEY_FILE="private_key.pem"

# GitHub secrets often store newlines as literal \n sequences. Normalise them
# back to real newlines so the key format matches what sign_update expects.
SPARKLE_KEY_CONTENT="$PRIVATE_KEY" python3 <<'PY' > "$KEY_FILE"
import os

raw_key = os.environ["SPARKLE_KEY_CONTENT"]
if "\\n" in raw_key:
    raw_key = raw_key.replace("\\n", "\n")
sys.stdout.write(raw_key)
PY

if [ ! -s "$KEY_FILE" ]; then
    echo "❌ Failed to write private key to $KEY_FILE"
    exit 1
fi

# Sparkle's sign_update expects the raw base64-encoded EdDSA key (64 bytes when
# decoded). If the secret is provided as a PEM/PKCS#8 file, convert it first.
if grep -q "BEGIN .*PRIVATE KEY" "$KEY_FILE"; then
    echo "🔄 Converting PEM private key to Sparkle's raw format..."
    ./bin/sign_update --convert-private-key "$KEY_FILE" "${KEY_FILE}.converted"
    mv "${KEY_FILE}.converted" "$KEY_FILE"
fi

echo "🔍 Checking if sign_update exists..."
if [ ! -f "./bin/sign_update" ]; then
    echo "❌ sign_update not found at ./bin/sign_update"
    ls -la ./bin/ || echo "bin/ directory not found"
    exit 1
fi

echo "✅ sign_update found, generating signature..."
echo "🔧 Running: ./bin/sign_update --ed-key-file private_key.pem \"$DMG_PATH\""

# Temporarily disable exit on error to capture output
set +e
SIGNATURE=$(./bin/sign_update --ed-key-file "$KEY_FILE" "$DMG_PATH" 2>&1)
SIGN_EXIT_CODE=$?
set -e

echo "🔐 Sign_update exit code: $SIGN_EXIT_CODE"
echo "🔐 Sign_update output: $SIGNATURE"

if [ $SIGN_EXIT_CODE -ne 0 ]; then
    echo "❌ sign_update failed with exit code $SIGN_EXIT_CODE"
    rm "$KEY_FILE"
    exit 1
fi

echo "✅ Generated signature: $SIGNATURE"
rm "$KEY_FILE"

# Get bundle version from built app
echo "📦 Reading bundle version from: $EXPORT_DIR/$APP_NAME.app/Contents/Info.plist"
if [ ! -f "$EXPORT_DIR/$APP_NAME.app/Contents/Info.plist" ]; then
    echo "❌ Info.plist not found at expected location"
    echo "🔍 Checking export directory contents:"
    ls -la "$EXPORT_DIR/" || echo "Export directory not found"
    exit 1
fi

# Temporarily disable exit on error to capture output
set +e
BUNDLE_VERSION=$(defaults read "$EXPORT_DIR/$APP_NAME.app/Contents/Info.plist" CFBundleVersion 2>&1)
BUNDLE_EXIT_CODE=$?
set -e

if [ $BUNDLE_EXIT_CODE -ne 0 ]; then
    echo "❌ Failed to read bundle version: $BUNDLE_VERSION"
    exit 1
fi

echo "✅ Bundle version: $BUNDLE_VERSION"

# Output for GitHub Actions
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "file_size=$FILE_SIZE" >> "$GITHUB_OUTPUT"
    echo "signature=$SIGNATURE" >> "$GITHUB_OUTPUT"
    echo "bundle_version=$BUNDLE_VERSION" >> "$GITHUB_OUTPUT"
fi

echo "✅ Appcast metadata generated successfully"