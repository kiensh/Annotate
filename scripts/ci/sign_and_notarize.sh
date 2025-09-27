#!/bin/bash

# Sign, export, and notarize the app
# Usage: ./sign_and_notarize.sh <apple_id> <password> <team_id>

if [ $# -ne 3 ]; then
    echo "Usage: $0 <apple_id> <password> <team_id>"
    exit 1
fi

set -euo pipefail

APPLE_ID="$1"
NOTARIZE_PASSWORD="$2"
TEAM_ID="$3"

APP_NAME="Annotate"
ARCHIVE_PATH="Annotate.xcarchive"
EXPORT_DIR="build/export"
EXPORT_PLIST="packaging/ExportOptions.plist"
TEMP_EXPORT_PLIST="/tmp/ExportOptions.plist"

echo "🔐 Preparing export options with Team ID..."

# Substitute the TEAM_ID placeholder in the export plist
sed "s/__TEAM_ID__/$TEAM_ID/g" "$EXPORT_PLIST" > "$TEMP_EXPORT_PLIST"

echo "📦 Copying app from archive (skipping xcodebuild export)..."

mkdir -p "$EXPORT_DIR"
# Copy the app directly from the archive instead of using exportArchive
cp -R "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app" "$EXPORT_DIR/"

echo "🔒 Signing with Developer ID and hardened runtime..."

codesign --force --sign "Developer ID Application" \
    -o runtime --timestamp \
    --entitlements "$APP_NAME/$APP_NAME.entitlements" \
    "$EXPORT_DIR/$APP_NAME.app"

echo "📦 Creating DMG..."

chmod +x packaging/make_dmg.sh
DMG_PATH=$(./packaging/make_dmg.sh)
echo "DMG created at: $DMG_PATH"

echo "☁️  Notarizing DMG..."

xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$NOTARIZE_PASSWORD" \
    --team-id "$TEAM_ID" \
    --wait

echo "✅ Validating and stapling..."

echo "Verifying app signature and entitlements..."
codesign --verify --deep --strict --verbose=2 "$EXPORT_DIR/$APP_NAME.app"
spctl -a -vvv --type exec "$EXPORT_DIR/$APP_NAME.app"

echo "Stapling notarization ticket to DMG..."
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

echo "✅ Notarization complete: $DMG_PATH"
echo "DMG_PATH=$DMG_PATH" >> "${GITHUB_OUTPUT:-/dev/null}"

# Clean up temporary file
rm -f "$TEMP_EXPORT_PLIST"