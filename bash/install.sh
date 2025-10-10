#!/bin/bash
# ============================================================
# install - Global R package build/check/install helper
# Author  : Jemay SALOMON
# Date    : 2025-10-10
# Version : 1.0
# License : MIT
# ============================================================
# Description:
#   This script automates the standard workflow for R package development.
#   It can be executed from anywhere on your system and will:
#     1. Clean old build artifacts and .Rcheck folders.
#     2. Build the R package (.tar.gz) using `R CMD build`.
#     3. Validate the package with `R CMD check`.
#     4. Optionally install the package locally even if the check fails.
#
#   The script ensures a consistent, repeatable process for building and
#   testing R packages, reducing manual steps and minimizing human error.
#   It is particularly useful for developers maintaining multiple R packages
#   or working on package automation pipelines.
#
# Usage:
#   install /path/to/package
#
# Example:
#   install ~/Documents/myPackage
#
# Notes:
#   - Works system-wide if placed in /usr/local/bin or in ~/bin with PATH updated.
#   - Requires R to be installed and accessible from the command line.
#   - Safe to run multiple times; old builds are automatically cleaned.
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
