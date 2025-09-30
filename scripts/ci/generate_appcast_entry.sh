#!/bin/bash

# Generate and insert new appcast entry
# Usage: ./generate_appcast_entry.sh <tag_name> <version_number> <sparkle_version> <signature> <zip_size> <download_url> [appcast_file]

set -euo pipefail

if [ $# -lt 6 ] || [ $# -gt 7 ]; then
    echo "Usage: $0 <tag_name> <version_number> <sparkle_version> <signature> <zip_size> <download_url> [appcast_file]"
    echo ""
    echo "Parameters:"
    echo "  tag_name        - Git tag (e.g., v1.0.7-test)"
    echo "  version_number  - Version string (e.g., 1.0.7-test)"
    echo "  sparkle_version - Sparkle version (e.g., 107test)"
    echo "  signature       - Sparkle EdDSA signature"
    echo "  zip_size        - ZIP file size in bytes"
    echo "  download_url    - Full download URL"
    echo "  appcast_file    - Optional: appcast file path (default: appcast.xml)"
    exit 1
fi

TAG_NAME="$1"
VERSION_NUMBER="$2"
SPARKLE_VERSION="$3"
SIGNATURE="$4"
ZIP_SIZE="$5"
DOWNLOAD_URL="$6"
APPCAST_FILE="${7:-appcast.xml}"

# Validate inputs
if [ ! -f "$APPCAST_FILE" ]; then
    echo "❌ Appcast file not found: $APPCAST_FILE"
    exit 1
fi

if [ -z "$TAG_NAME" ] || [ -z "$VERSION_NUMBER" ] || [ -z "$SPARKLE_VERSION" ] || [ -z "$SIGNATURE" ] || [ -z "$ZIP_SIZE" ] || [ -z "$DOWNLOAD_URL" ]; then
    echo "❌ All parameters are required and cannot be empty"
    exit 1
fi

# Generate publication date
PUB_DATE=$(date -u +"%a, %d %b %Y %H:%M:%S %z")

echo "📝 Generating appcast entry for $TAG_NAME..."
echo "  Version: $VERSION_NUMBER"
echo "  Sparkle Version: $SPARKLE_VERSION"
echo "  File Size: $ZIP_SIZE bytes"
echo "  Download URL: $DOWNLOAD_URL"

# Generate new appcast entry
cat > new_entry.xml << EOF
        <item>
            <title>Version $TAG_NAME</title>
            <link>https://github.com/epilande/Annotate/releases/tag/$TAG_NAME</link>
            <description><![CDATA[
<h2>🚀 Annotate $TAG_NAME</h2>

<p>See the <a href="https://github.com/epilande/Annotate/releases/tag/$TAG_NAME">full changelog</a> for details.</p>
            ]]></description>
            <pubDate>$PUB_DATE</pubDate>
            <enclosure url="$DOWNLOAD_URL"
                       sparkle:version="$SPARKLE_VERSION"
                       sparkle:shortVersionString="$VERSION_NUMBER"
                       sparkle:edSignature="$SIGNATURE"
                       length="$ZIP_SIZE"
                       type="application/octet-stream" />
        </item>
EOF

echo "📄 Generated entry:"
cat new_entry.xml

# Backup original appcast
cp "$APPCAST_FILE" "${APPCAST_FILE}.backup"

# Insert new entry after channel description
echo "📝 Updating $APPCAST_FILE..."
if sed -i.tmp '/^        <description>.*<\/description>$/r new_entry.xml' "$APPCAST_FILE"; then
    rm "${APPCAST_FILE}.tmp" new_entry.xml
    echo "✅ Successfully updated $APPCAST_FILE"
else
    echo "❌ Failed to update $APPCAST_FILE"
    # Restore backup on failure
    mv "${APPCAST_FILE}.backup" "$APPCAST_FILE"
    rm -f new_entry.xml
    exit 1
fi

# Validate the updated XML
if command -v xmllint >/dev/null 2>&1; then
    if xmllint --noout "$APPCAST_FILE" 2>/dev/null; then
        echo "✅ Updated appcast.xml is valid XML"
        rm "${APPCAST_FILE}.backup"
    else
        echo "❌ Updated appcast.xml is invalid XML, restoring backup"
        mv "${APPCAST_FILE}.backup" "$APPCAST_FILE"
        exit 1
    fi
else
    echo "⚠️  xmllint not available, skipping XML validation"
    rm "${APPCAST_FILE}.backup"
fi

echo "✅ Appcast entry generation completed successfully"