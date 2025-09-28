#!/bin/bash
set -euo pipefail

# Usage: ./update_appcast_xml.sh <DMG_PATH> <TAG_NAME> <SEMVER> <BUNDLE_VERSION> <SIGNATURE> <RELEASE_NOTES>

DMG_PATH="$1"
TAG_NAME="$2"
SEMVER="$3"
BUNDLE_VERSION="$4"
SIGNATURE="$5"
RELEASE_NOTES="$6"

echo "Updating appcast.xml..."

# Get file info
FILE_SIZE=$(stat -f%z "$DMG_PATH")
DMG_FILENAME=$(basename "$DMG_PATH")
DOWNLOAD_URL="https://github.com/epilande/Annotate/releases/download/${TAG_NAME}/${DMG_FILENAME}"

# Update appcast.xml using Python
python3 << EOF
import xml.etree.ElementTree as ET
from datetime import datetime

# Parse existing appcast.xml
tree = ET.parse('appcast.xml')
root = tree.getroot()

# Find the channel
channel = root.find('channel')
if channel is None:
    raise Exception("Could not find channel in appcast.xml")

# Get existing items to insert new one at the beginning
items = channel.findall('item')

# Create new item element
new_item = ET.Element('item')

# Add title
title = ET.SubElement(new_item, 'title')
title.text = 'Annotate ${SEMVER}'

# Add link
link = ET.SubElement(new_item, 'link')
link.text = 'https://github.com/epilande/Annotate/releases/tag/${TAG_NAME}'

# Add description
description = ET.SubElement(new_item, 'description')
description.text = '''${RELEASE_NOTES}'''

# Add publication date
pub_date = ET.SubElement(new_item, 'pubDate')
pub_date.text = datetime.now().strftime('%a, %d %b %Y %H:%M:%S +0000')

# Add enclosure with all required attributes
enclosure = ET.SubElement(new_item, 'enclosure')
enclosure.set('url', '${DOWNLOAD_URL}')
enclosure.set('length', '${FILE_SIZE}')
enclosure.set('type', 'application/octet-stream')
enclosure.set('sparkle:version', '${BUNDLE_VERSION}')
enclosure.set('sparkle:shortVersionString', '${SEMVER}')
enclosure.set('sparkle:edSignature', '${SIGNATURE}')

# Insert new item at the beginning (after title, link, description)
# Find the insertion point (after channel metadata, before first item)
insertion_index = 0
for i, child in enumerate(channel):
    if child.tag == 'item':
        insertion_index = i
        break
    elif child.tag not in ['title', 'link', 'description', 'language']:
        insertion_index = i + 1

if items:
    channel.insert(insertion_index, new_item)
else:
    channel.append(new_item)

# Write updated XML
tree.write('appcast.xml', encoding='utf-8', xml_declaration=True)
print("Successfully updated appcast.xml")
EOF

echo "Appcast updated successfully"