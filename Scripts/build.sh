#!/bin/bash
set -e
cd "$(dirname "$0")/.."
ROOT=$(pwd)

echo "🤠 Building Whip.app..."
echo ""

# Step 1: Generate sounds if missing
if [ ! -f Resources/crack_1.wav ]; then
    echo "  🔊 Generating whip sounds..."
    python3 Resources/generate_sounds.py
fi

# Step 2: Generate icon if missing
if [ ! -f Resources/AppIcon.icns ]; then
    echo "  🎨 Generating app icon..."
    python3 Resources/generate_icon.py
fi

# Step 3: Create .app bundle structure
APP="$ROOT/build/Whip.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

# Step 4: Compile Swift
echo "  ⚙️  Compiling Swift..."
swiftc Sources/WhipApp.swift \
    -o "$APP/Contents/MacOS/Whip" \
    -framework Cocoa \
    -framework AVFoundation \
    -framework CoreImage \
    -framework QuartzCore \
    -O \
    -suppress-warnings

# Step 5: Copy resources
echo "  📦 Bundling resources..."
cp Resources/crack_*.wav "$APP/Contents/Resources/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"

# Step 6: Create Info.plist
cat > "$APP/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Whip</string>
    <key>CFBundleDisplayName</key>
    <string>Whip</string>
    <key>CFBundleIdentifier</key>
    <string>com.whipapp.whip</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackagetype</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>Whip</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>MIT License</string>
</dict>
</plist>
PLIST

# Step 7: Report
SIZE=$(du -sh "$APP" | cut -f1)
echo ""
echo "  ✅ Built: $APP ($SIZE)"
echo ""
echo "  Install:"
echo "    cp -r build/Whip.app /Applications/"
echo "    open /Applications/Whip.app"
echo ""
echo "  Or run directly:"
echo "    open build/Whip.app"
