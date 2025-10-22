#!/bin/bash
# ============================================================
# check - R package build/check helper with runtime flags
# Author : Jemay SALOMON
# Date   : 2025-10-21
# ============================================================
# Usage :
#   R_CMD_check /path/to/package [--args "flags"] [--build_args "flags"]
# ============================================================

set -e  # Exit on error

if [ -z "$1" ]; then
  echo "❌ Error: please specify the path to the R package."
  echo "Usage: ./R_CMD_check /path/to/pkg [--args \"flags\"] [--build_args \"flags\"]"
  exit 1
fi

PKG_PATH=$(realpath "$1")
shift

# Default empty arrays
CHECK_ARGS=()
BUILD_ARGS=()

# Parse optional flags
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --args)
      shift
      CHECK_ARGS=($1)
      shift
      ;;
    --build_args)
      shift
      BUILD_ARGS=($1)
      shift
      ;;
    *)
      echo "⚠️  Warning: unknown argument $1 ignored"
      shift
      ;;
  esac
done

# Verify package
if [ ! -f "$PKG_PATH/DESCRIPTION" ]; then
  echo "❌ Error: DESCRIPTION file not found in '$PKG_PATH'"
  exit 1
fi

PKG_NAME=$(basename "$PKG_PATH")
PKG_VER=$(grep -m1 '^Version:' "$PKG_PATH/DESCRIPTION" | awk '{print $2}')
PKG_TAR="${PKG_NAME}_${PKG_VER}.tar.gz"

# Build directory
mkdir -p "$PKG_PATH/bld"
TMP_PATH="$PKG_PATH/bld"

echo "📦 Package: $PKG_NAME"
echo "📁 Path   : $PKG_PATH"
echo "--------------------------------------------"

# Clean old builds
echo "🧹 Cleaning old builds..."
find /tmp -maxdepth 1 -type f -name "${PKG_NAME}_*.tar.gz" -delete || true
find "$PKG_PATH" -maxdepth 1 -type d -name "${PKG_NAME}.Rcheck" -exec rm -rf {} +

# -------------------
# Build
# -------------------
echo "🏗️  Building the package..."
cd "$TMP_PATH"

if [ ${#BUILD_ARGS[@]} -eq 0 ]; then
  echo "🔧 Running: R CMD build $PKG_PATH"
  R_CMD_BUILD=(R CMD build "$PKG_PATH")
else
  echo "🔧 Running: R CMD build $PKG_PATH ${BUILD_ARGS[@]}"
  R_CMD_BUILD=(R CMD build "$PKG_PATH" "${BUILD_ARGS[@]}")
fi
# Execute build command
"${R_CMD_BUILD[@]}"

# -------------------
# Check
# -------------------
echo "🔍 Checking the package..."
set +e
if [ ${#CHECK_ARGS[@]} -eq 0 ]; then
  echo "🔧 Running: R CMD check $PKG_TAR"
  R_CMD_CHECK=(R CMD check "$PKG_TAR")
else
  echo "🔧 Running: R CMD check $PKG_TAR ${CHECK_ARGS[@]}"
  R_CMD_CHECK=(R CMD check "$PKG_TAR" "${CHECK_ARGS[@]}")
fi
# Execute check command
"${R_CMD_CHECK[@]}"
CHECK_STATUS=$?
set -e

# -------------------
# Evaluate results
# -------------------
if [ "$CHECK_STATUS" -ne 0 ]; then
  echo "⚠️  Package check encountered errors."
  echo "❌  See ${PKG_NAME}.Rcheck/00check.log for details."
  EXIT_CODE=1
else
  echo "✅ Check passed successfully!"
  EXIT_CODE=0
fi

# -------------------
# Clean up
# -------------------
echo "🧽 Cleaning up build artifacts..."
rm -rf "$TMP_PATH" || true

echo "--------------------------------------------"
echo "✨ All done! Package built, checked, and cleaned."

exit $EXIT_CODE
# ============================================================
