#!/usr/bin/env bash
# Runs the store-screenshot UI tests against nilumio in the 1080p Apple TV simulator.
# Usage: Scripts/Screenshots/run.sh <output dir> [ScreenshotTests/SignIn | ScreenshotTests/StoreScreenshots]
# Sign in once with SignIn (Quick Connect), then StoreScreenshots writes 01-…06-*.png.
set -euo pipefail
cd "$(dirname "$0")"
OUT=${1:?Ausgabeordner fehlt}; mkdir -p "$OUT"
SIM=$(xcrun simctl list devices available | grep "Apple TV 4K (3rd generation) (at 1080p)" | head -1 | grep -oE '[0-9A-F-]{36}')
export TEST_RUNNER_SHOT_DIR="$OUT" TEST_RUNNER_SERVER_URL="${SERVER_URL:-https://black-nas.synology.me:8920}"
xcodebuild test -project Screenshots.xcodeproj -scheme ScreenshotTests -destination "id=$SIM" \
  -derivedDataPath "${TMPDIR:-/tmp}/nilumio-screenshots-dd" ${2:+-only-testing:$2} > "$OUT/xcodebuild.log" 2>&1 || true; grep -E "error:|Test Case|\*\* TEST" "$OUT/xcodebuild.log" || true
