#!/bin/bash

# Update appcast.xml with new release entry
# Usage: ./update_appcast.sh <tag_name> <semver> <bundle_version> <signature> <file_size> <dmg_path> <release_body>

if [ $# -ne 7 ]; then
    echo "Usage: $0 <tag_name> <semver> <bundle_version> <signature> <file_size> <dmg_path> <release_body>"
    exit 1
fi

set -euo pipefail

TAG_NAME="$1"
SEMVER="$2"
BUNDLE_VERSION="$3"
SIGNATURE="$4"
FILE_SIZE="$5"
DMG_PATH="$6"
RELEASE_BODY="$7"

DMG_FILENAME=$(basename "$DMG_PATH")

echo "📺 Updating appcast.xml for $TAG_NAME"

# Create new appcast entry
cat > new_entry.xml << EOF
        <item>
            <title>Version $TAG_NAME</title>
            <link>https://github.com/epilande/Annotate/releases/tag/$TAG_NAME</link>
            <description><![CDATA[
$RELEASE_BODY
            ]]></description>
            <pubDate>$(date -R)</pubDate>
            <enclosure url="https://github.com/epilande/Annotate/releases/download/$TAG_NAME/$DMG_FILENAME"
                       sparkle:version="$BUNDLE_VERSION"
                       sparkle:shortVersionString="$SEMVER"
                       sparkle:edSignature="$SIGNATURE"
                       length="$FILE_SIZE"
                       type="application/octet-stream" />
        </item>
EOF

echo "📄 Generated appcast entry:"
cat new_entry.xml

# Insert new entry into appcast.xml after the channel description
echo "📝 Updating appcast.xml..."
sed -i.bak '/^        <description>.*<\/description>$/r new_entry.xml' appcast.xml
rm new_entry.xml appcast.xml.bak

echo "✅ appcast.xml updated successfully"