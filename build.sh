#!/bin/bash
# Build and install aircrack-ng from source on Ubuntu 24.04 arm64
# https://github.com/slofi/aircrack-ng-arm64

set -e

AIRCRACK_REPO="https://github.com/aircrack-ng/aircrack-ng"
BUILD_DIR="/tmp/aircrack-ng-build"

echo ""
echo "aircrack-ng builder for Ubuntu 24.04 arm64"
echo "-------------------------------------------"
echo ""

# Check we're on arm64
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    echo "Warning: this script is intended for arm64 (aarch64). You're running $ARCH."
    echo "It might still work, but no guarantees."
    echo ""
fi

# Check for sudo
if ! sudo -n true 2>/dev/null; then
    echo "This script needs sudo for installing dependencies and the final install step."
    echo "You'll be prompted for your password."
    echo ""
fi

echo "[1/4] Installing build dependencies..."
sudo apt-get update -qq
sudo apt-get install -y \
    build-essential autoconf automake libtool pkg-config \
    libnl-3-dev libnl-genl-3-dev libssl-dev ethtool rfkill \
    zlib1g-dev libpcap-dev libsqlite3-dev libpcre2-dev \
    libhwloc-dev libcmocka-dev iw git

echo ""
echo "[2/4] Cloning aircrack-ng source (latest)..."
rm -rf "$BUILD_DIR"
git clone --depth=1 "$AIRCRACK_REPO" "$BUILD_DIR"

echo ""
echo "[3/4] Compiling... (this takes a few minutes on slower hardware)"
cd "$BUILD_DIR"
autoreconf -i
./configure --with-experimental
make -j$(nproc)

echo ""
echo "[4/4] Installing..."
sudo make install

echo ""
echo "Done. Verifying install:"
aircrack-ng --help 2>&1 | head -1
echo ""
echo "Tools installed:"
for tool in aircrack-ng airmon-ng airodump-ng aireplay-ng airdecap-ng; do
    if command -v "$tool" &>/dev/null; then
        echo "  $tool -> $(which $tool)"
    fi
done

echo ""
echo "Cleaning up build directory..."
rm -rf "$BUILD_DIR"

echo ""
echo "All done. To get started, put your adapter in monitor mode:"
echo "  sudo airmon-ng start <interface>"
echo ""
