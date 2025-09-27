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

echo "🔍 Debugging archive structure..."

# Check if archive exists and its structure
echo "Archive path: $ARCHIVE_PATH"
ls -la "$ARCHIVE_PATH" || echo "❌ Archive not found!"

# Check archive Info.plist
echo "📋 Archive Info.plist:"
plutil -p "$ARCHIVE_PATH/Info.plist" || echo "❌ Cannot read archive Info.plist"

# Check what's in the archive
echo "📁 Archive contents:"
find "$ARCHIVE_PATH" -maxdepth 3 -type f -name "*.plist" | head -5

# Check if there's an app in the archive
echo "🔍 Apps in archive:"
find "$ARCHIVE_PATH" -name "*.app" -type d

# Check the main app's Info.plist for team/bundle info
echo "📱 Main app Info.plist:"
plutil -p "$ARCHIVE_PATH/Products/Applications/Annotate.app/Contents/Info.plist" | head -10

# Check if the app is properly signed
echo "🔏 App signing status:"
codesign -dv "$ARCHIVE_PATH/Products/Applications/Annotate.app" 2>&1 || echo "❌ App not signed"

echo "🔐 Preparing export options with Team ID..."

# Substitute the TEAM_ID placeholder in the export plist
sed "s/__TEAM_ID__/$TEAM_ID/g" "$EXPORT_PLIST" > "$TEMP_EXPORT_PLIST"

# Debug: Show the actual export plist contents
echo "📋 Export options plist contents:"
cat "$TEMP_EXPORT_PLIST"

# Validate the plist is well-formed
echo "🔍 Validating export plist:"
plutil -lint "$TEMP_EXPORT_PLIST" || echo "❌ Export plist is malformed!"

echo "📦 Exporting app with proper Developer ID signing..."

# Use xcodebuild -exportArchive instead of manual copying
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$TEMP_EXPORT_PLIST" \
    | xcpretty || {
        echo "❌ Export failed. Trying without xcpretty for detailed output..."
        xcodebuild -exportArchive \
            -archivePath "$ARCHIVE_PATH" \
            -exportPath "$EXPORT_DIR" \
            -exportOptionsPlist "$TEMP_EXPORT_PLIST"
    }

echo "✅ App exported to: $EXPORT_DIR/$APP_NAME.app"

# Verify the exported app is properly signed
echo "🔍 Verifying exported app signature:"
codesign -dv "$EXPORT_DIR/$APP_NAME.app" 2>&1 || echo "❌ App signature verification failed"

echo "✅ Validating app before creating DMG..."

echo "Verifying app signature and entitlements..."
if codesign --verify --deep --strict --verbose=2 "$EXPORT_DIR/$APP_NAME.app"; then
    echo "✅ App signature verification passed"
else
    echo "❌ App signature verification failed"
    exit 1
fi

echo "📦 Creating DMG..."

chmod +x packaging/make_dmg.sh
DMG_PATH=$(./packaging/make_dmg.sh)
echo "DMG created at: $DMG_PATH"

echo "☁️  Notarizing DMG..."

# Submit and capture the submission ID for detailed error info
SUBMISSION_OUTPUT=$(xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$NOTARIZE_PASSWORD" \
    --team-id "$TEAM_ID" \
    --wait)

echo "$SUBMISSION_OUTPUT"

# Extract submission ID and get detailed log if it failed
SUBMISSION_ID=$(echo "$SUBMISSION_OUTPUT" | grep "id:" | head -1 | awk '{print $2}')
if echo "$SUBMISSION_OUTPUT" | grep -q "status: Invalid"; then
    echo "❌ Notarization failed. Getting detailed log..."
    xcrun notarytool log "$SUBMISSION_ID" \
        --apple-id "$APPLE_ID" \
        --password "$NOTARIZE_PASSWORD" \
        --team-id "$TEAM_ID" || echo "Could not retrieve detailed log"
    exit 1
fi

echo "✅ Stapling notarization ticket..."

echo "Stapling notarization ticket to DMG..."
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

echo "🔍 Final verification of stapled DMG:"
spctl -a -vvv --type open --context context:primary-signature "$DMG_PATH" || echo "❌ DMG verification failed"

echo "✅ Notarization complete: $DMG_PATH"
echo "DMG_PATH=$DMG_PATH" >> "${GITHUB_OUTPUT:-/dev/null}"

# Clean up temporary file
rm -f "$TEMP_EXPORT_PLIST"