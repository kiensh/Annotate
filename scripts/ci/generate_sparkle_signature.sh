#!/bin/bash
set -euo pipefail

# Usage: ./generate_sparkle_signature.sh <DMG_PATH> <TAG_NAME> <PRIVATE_KEY>

DMG_PATH="$1"
TAG_NAME="$2"
PRIVATE_KEY="$3"

echo "Generating Sparkle signature for $DMG_PATH..."

# Create temporary directory and copy DMG
TEMP_DIR=$(mktemp -d)
cp "$DMG_PATH" "$TEMP_DIR/"

echo "Using directory: $TEMP_DIR"
echo "Files in temp dir:"
ls -la "$TEMP_DIR"

# Write the private key directly to a file (preserve original format)
TEMP_KEY=$(mktemp)
echo "$PRIVATE_KEY" > "$TEMP_KEY"

echo "Private key written to: $TEMP_KEY"
echo "Private key format check:"
if [ -s "$TEMP_KEY" ]; then
  echo "✅ Key file created and has content ($(wc -c < "$TEMP_KEY") bytes)"
  echo "Key lines: $(wc -l < "$TEMP_KEY")"
  # Check if it's PEM format
  if grep -q "BEGIN.*PRIVATE KEY" "$TEMP_KEY"; then
    echo "Format: PEM (with headers)"
  else
    echo "Format: Raw base64 or other"
  fi
  # Show first few characters for debugging (not the full key for security)
  echo "Key starts with: $(head -c 30 "$TEMP_KEY")..."
else
  echo "❌ Key file is empty or missing"
  exit 1
fi

# Generate signature using Sparkle's sign_update tool (more reliable)
echo "Using sign_update to generate signature..."
SIGNATURE=$(~/bin/sign_update "$DMG_PATH" "$TEMP_KEY" 2>&1 || echo "SIGN_ERROR: $?")

# Cleanup the temp key file
rm -f "$TEMP_KEY"

echo "Sign_update output:"
echo "$SIGNATURE"

# Check if signature generation was successful
if echo "$SIGNATURE" | grep -q "SIGN_ERROR"; then
  echo "❌ sign_update failed:"
  echo "$SIGNATURE"
  exit 1
fi

# Validate signature format (base64-like string)
if [ -z "$SIGNATURE" ] || [ ${#SIGNATURE} -lt 10 ]; then
  echo "❌ Invalid or empty signature generated"
  exit 1
fi

echo "✅ Generated signature: $SIGNATURE"

# Cleanup
rm -rf "$TEMP_DIR"

# Output signature for use in workflow
echo "signature=$SIGNATURE" >> "$GITHUB_OUTPUT"

echo "Sparkle signature generated successfully: $SIGNATURE"