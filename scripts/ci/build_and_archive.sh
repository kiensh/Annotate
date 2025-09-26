#!/bin/bash

# Build and archive Xcode project
# Usage: ./build_and_archive.sh <marketing_version>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <marketing_version>"
    exit 1
fi

set -euo pipefail

MARKETING_VERSION="$1"
ENTRY="-project Annotate.xcodeproj"
SCHEME="Annotate"
CONFIG="Release"
ARCHIVE_PATH="build/Annotate.xcarchive"

echo "🏗️  Building and archiving $SCHEME ($MARKETING_VERSION)..."

mkdir -p build

xcodebuild \
    $ENTRY \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS" \
    ARCHS=arm64 \
    CODE_SIGNING_ALLOWED=NO \
    SKIP_INSTALL=NO \
    MARKETING_VERSION="$MARKETING_VERSION" \
    clean archive | xcpretty && exit ${PIPESTATUS[0]}

echo "✅ Archive created at: $ARCHIVE_PATH"