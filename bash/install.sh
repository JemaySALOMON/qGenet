#!/bin/bash
# ============================================================
# install - Global R package build/check/install helper
# Author : Jemay SALOMON
# Date   : 2025-10-10
# ============================================================
# Usage :
#   install /path/to/package
# Example :
#   install ~/Documents/myPackage
# ============================================================

set -e  # Exit if any command fails

if [ -z "$1" ]; then
  echo "❌ Error: please specify the path to the R package."
  echo "Usage: install /path/to/package"
  exit 1
fi

PKG_PATH=$(realpath "$1")
if [ ! -f "$PKG_PATH/DESCRIPTION" ]; then
  echo "❌ Error: DESCRIPTION file not found in $PKG_PATH"
  exit 1
fi

PKG_NAME=$(basename "$PKG_PATH")
PKG_VER=$(grep -m1 'Version:' "$PKG_PATH/DESCRIPTION" | awk '{print $2}')
PKG_TAR="${PKG_NAME}_${PKG_VER}.tar.gz"

echo "📦 Package: $PKG_NAME"
echo "📁 Path   : $PKG_PATH"
echo "--------------------------------------------"

# Clean old builds (globally safe)
echo "🧹 Cleaning old builds..."
find /tmp -maxdepth 1 -type f -name "${PKG_NAME}_*.tar.gz" -delete || true
find "$PKG_PATH" -maxdepth 1 -type d -name "${PKG_NAME}.Rcheck" -exec rm -rf {} +

# Build
echo "🏗️  Building the package..."
cd "$PKG_PATH"
R CMD build "$PKG_PATH"

# Check
echo "🔍 Checking the package..."
set +e
R CMD check "$PKG_TAR"
CHECK_STATUS=$?
set -e

# Install logic
if [ $CHECK_STATUS -ne 0 ]; then
  echo "⚠️  Check encountered errors."
  read -p "Would you still like to install the package? (y/n): " proceed
  if [[ "$proceed" =~ ^[Yy]$ ]]; then
    echo "📥 Installing the package despite errors..."
    R CMD INSTALL "$PKG_TAR"
    echo "✅ Installation completed (with warnings)."
  else
    echo "🚫 Installation canceled."
    exit 1
  fi
else
  echo "✅ Check passed successfully. Installing the package..."
  R CMD INSTALL "$PKG_TAR"
  echo "✅ Installation completed successfully."
fi
