#!/bin/bash
set -e
cd "$(dirname "$0")/.."

APP="build/Whip.app"
DMG="build/Whip-1.0.0.dmg"

if [ ! -d "$APP" ]; then
    echo "Build the app first: bash Scripts/build.sh"
    exit 1
fi

echo "📀 Creating DMG..."

# Create temp DMG folder
DMG_DIR="build/dmg"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"
cp -r "$APP" "$DMG_DIR/"

# Create symlink to Applications
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
rm -f "$DMG"
hdiutil create -volname "Whip" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$DMG" \
    -quiet

rm -rf "$DMG_DIR"

SIZE=$(du -sh "$DMG" | cut -f1)
echo "✅ Created: $DMG ($SIZE)"
echo ""
echo "Share this file — users drag Whip.app to Applications."
