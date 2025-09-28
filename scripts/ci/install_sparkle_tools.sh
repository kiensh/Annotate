#!/bin/bash
set -euo pipefail

echo "Installing Sparkle tools..."

SPARKLE_VERSION="2.8.0"
ARCHIVE="Sparkle-${SPARKLE_VERSION}.tar.xz"
DOWNLOAD_URL="https://github.com/sparkle-project/Sparkle/releases/download/${SPARKLE_VERSION}/${ARCHIVE}"

curl -L -o "$ARCHIVE" "$DOWNLOAD_URL"

tar -xf "$ARCHIVE"

SPARKLE_DIR="Sparkle-${SPARKLE_VERSION}"
if [ ! -d "$SPARKLE_DIR/bin" ]; then
  echo "❌ Unable to locate Sparkle binaries in $SPARKLE_DIR/bin"
  exit 1
fi

mkdir -p bin
cp "$SPARKLE_DIR/bin/generate_appcast" bin/
cp "$SPARKLE_DIR/bin/sign_update" bin/
chmod +x bin/generate_appcast bin/sign_update

# Also expose the tools on the PATH for backwards compatibility
mkdir -p ~/bin
cp "$SPARKLE_DIR/bin/generate_appcast" ~/bin/
cp "$SPARKLE_DIR/bin/sign_update" ~/bin/
chmod +x ~/bin/generate_appcast ~/bin/sign_update

rm -rf "$SPARKLE_DIR" "$ARCHIVE"

echo "Sparkle tools installed successfully"
