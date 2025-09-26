#!/bin/bash

# Prepare release notes and metadata
# Usage: ./prepare_release.sh <tag_name> <release_body> <is_prerelease>

if [ $# -ne 3 ]; then
    echo "Usage: $0 <tag_name> <release_body> <is_prerelease>"
    exit 1
fi

set -euo pipefail

TAG_NAME="$1"
RELEASE_BODY="$2"
IS_PRERELEASE="$3"

echo "📝 Preparing release metadata for: $TAG_NAME"

# Extract semantic version (remove 'v' prefix if present)
SEMVER="${TAG_NAME#v}"
echo "🔢 Semantic version: $SEMVER"

# Fallback if release body is empty
if [ -z "$RELEASE_BODY" ]; then
    RELEASE_BODY="## 🚀 Annotate $TAG_NAME

Enhanced drawing tools, performance improvements, and bug fixes."
    echo "📄 Using fallback release body"
fi

echo "📋 Release type: $([ "$IS_PRERELEASE" = "true" ] && echo "prerelease" || echo "stable")"

# Output for GitHub Actions
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "semantic_version=$SEMVER" >> "$GITHUB_OUTPUT"
    echo "is_prerelease=$IS_PRERELEASE" >> "$GITHUB_OUTPUT"
    
    # Use heredoc for multi-line output
    echo "release_body<<EOF" >> "$GITHUB_OUTPUT"
    echo "$RELEASE_BODY" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"
fi

echo "✅ Release metadata prepared"