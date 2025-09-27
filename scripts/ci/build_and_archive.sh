#!/bin/bash

# Build and archive Xcode project
# Usage: ./build_and_archive.sh <marketing_version> <team_id>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <marketing_version> <team_id>"
    exit 1
fi

set -euo pipefail

MARKETING_VERSION="$1"
TEAM_ID="$2"
ENTRY="-project Annotate.xcodeproj"
SCHEME="Annotate"
CONFIG="Release"
ARCHIVE_PATH="build/Annotate.xcarchive"

echo "🏗️  Building and archiving $SCHEME ($MARKETING_VERSION)..."

mkdir -p build

echo "🔐 Building with Developer ID signing (Team: $TEAM_ID)"

# Run the build directly instead of storing in a variable to avoid quoting issues
if xcodebuild \
    $ENTRY \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS" \
    ARCHS=arm64 \
    SKIP_INSTALL=NO \
    MARKETING_VERSION="$MARKETING_VERSION" \
    CODE_SIGN_IDENTITY="Developer ID Application" \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    clean archive | xcpretty; then
    echo "✅ Archive created at: $ARCHIVE_PATH"
else
    BUILD_EXIT_CODE=${PIPESTATUS[0]}
    echo "❌ Build failed with exit code: $BUILD_EXIT_CODE"
    echo "🔍 Running build again without xcpretty to see full error output:"
    echo ""
    xcodebuild \
        $ENTRY \
        -scheme "$SCHEME" \
        -configuration "$CONFIG" \
        -archivePath "$ARCHIVE_PATH" \
        -destination "generic/platform=macOS" \
        ARCHS=arm64 \
        SKIP_INSTALL=NO \
        MARKETING_VERSION="$MARKETING_VERSION" \
        CODE_SIGN_IDENTITY="Developer ID Application" \
        CODE_SIGN_STYLE=Manual \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        clean archive
    exit $BUILD_EXIT_CODE
fi