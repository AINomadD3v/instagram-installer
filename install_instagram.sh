#!/usr/bin/env bash

# Instagram APK Installation Script
# Automatically installs Instagram APK splits on connected Android device

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_APK="$SCRIPT_DIR/base.apk"
SPLIT_APK="$SCRIPT_DIR/split_config.xxxhdpi.apk"

echo "=== Instagram APK Installer ==="

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo "ERROR: ADB not found. Please install Android platform tools."
    exit 1
fi

# Check for connected devices
echo "Checking for connected devices..."
DEVICES=$(adb devices | grep -E "device$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    echo "ERROR: No Android devices connected."
    echo "Please connect a device with USB debugging enabled."
    exit 1
elif [ "$DEVICES" -gt 1 ]; then
    echo "WARNING: Multiple devices connected. Using first available device."
fi

# Show connected device
DEVICE_ID=$(adb devices | grep -E "device$" | head -1 | awk '{print $1}')
echo "Connected device: $DEVICE_ID"

# Check if APK files exist
if [ ! -f "$BASE_APK" ]; then
    echo "ERROR: Base APK not found at $BASE_APK"
    echo "Please ensure Instagram APK files are in the current directory"
    exit 1
fi

if [ ! -f "$SPLIT_APK" ]; then
    echo "ERROR: Split APK not found at $SPLIT_APK"
    echo "Please ensure Instagram APK files are in the current directory"
    exit 1
fi

echo "Found APK files:"
echo "  Base APK: $BASE_APK ($(du -h "$BASE_APK" | cut -f1))"
echo "  Split APK: $SPLIT_APK ($(du -h "$SPLIT_APK" | cut -f1))"

# Check if Instagram is already installed
if adb shell pm list packages | grep -q "com.instagram.android"; then
    echo "WARNING: Instagram is already installed on this device."
    read -p "Do you want to reinstall? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    echo "Uninstalling existing Instagram..."
    adb uninstall com.instagram.android || echo "Uninstall failed, continuing..."
fi

# Install Instagram APKs
echo "Installing Instagram..."
cd "$SCRIPT_DIR"

if adb install-multiple base.apk split_config.xxxhdpi.apk; then
    echo "✅ Instagram successfully installed on device $DEVICE_ID"
    echo "The app should now be available in the device's app drawer."
else
    echo "❌ Installation failed."
    echo "Try the following troubleshooting steps:"
    echo "1. Ensure USB debugging is enabled"
    echo "2. Check if the device allows installation from unknown sources"
    echo "3. Try uninstalling any existing Instagram version first"
    exit 1
fi

echo "Installation complete!"