#!/bin/bash
# ============================================================
# R_CMD_tools - Build, Check, and Install R packages with flags
# Author : Jemay SALOMON
# Date   : 2025-10-22
# ============================================================

# Only enable strict mode when executed directly, not when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -e
fi

# ============================================================
# Internal core function
# ============================================================
_run_build_and_check() {
  local PKG_PATH="$1"; shift
  local MODE="$1"; shift
  local CHECK_ARGS=()
  local BUILD_ARGS=()

  # Parse optional arguments
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      --args)
        shift; CHECK_ARGS=($1); shift ;;
      --build_args)
        shift; BUILD_ARGS=($1); shift ;;
      *)
        echo "⚠️  Warning: unknown argument $1 ignored"; shift ;;
    esac
  done

  # Verify package path
  if [ ! -f "$PKG_PATH/DESCRIPTION" ]; then
    echo "❌ Error: DESCRIPTION file not found in '$PKG_PATH'"
    return 1
  fi

  local PKG_NAME=$(basename "$PKG_PATH")
  local PKG_VER=$(grep -m1 '^Version:' "$PKG_PATH/DESCRIPTION" | awk '{print $2}')
  local PKG_TAR="${PKG_NAME}_${PKG_VER}.tar.gz"

  mkdir -p "$PKG_PATH/bld"
  local TMP_PATH="$PKG_PATH/bld"

  echo "📦 Package: $PKG_NAME"
  echo "📁 Path   : $PKG_PATH"
  echo "--------------------------------------------"

  # Clean up old builds
  echo "🧹 Cleaning old builds..."
  find /tmp -maxdepth 1 -type f -name "${PKG_NAME}_*.tar.gz" -delete || true
  find "$PKG_PATH" -maxdepth 1 -type d -name "${PKG_NAME}.Rcheck" -exec rm -rf {} +

  # Build
  echo "🏗️  Building the package..."
  cd "$TMP_PATH"
  if [ ${#BUILD_ARGS[@]} -eq 0 ]; then
    echo "🔧 Running: R CMD build $PKG_PATH"
    R CMD build "$PKG_PATH"
  else
    echo "🔧 Running: R CMD build $PKG_PATH ${BUILD_ARGS[@]}"
    R CMD build "$PKG_PATH" "${BUILD_ARGS[@]}"
  fi

  # Check
  echo "🔍 Checking the package..."
  set +e
  if [ ${#CHECK_ARGS[@]} -eq 0 ]; then
    echo "🔧 Running: R CMD check $PKG_TAR"
    R CMD check "$PKG_TAR"
  else
    echo "🔧 Running: R CMD check $PKG_TAR ${CHECK_ARGS[@]}"
    R CMD check "$PKG_TAR" "${CHECK_ARGS[@]}"
  fi
  local CHECK_STATUS=$?
  set -e

  # Handle check/install results
  if [ "$MODE" = "check" ]; then
    if [ $CHECK_STATUS -ne 0 ]; then
      echo "⚠️  Package check encountered errors."
      echo "❌  See ${PKG_NAME}.Rcheck/00check.log for details."
    else
      echo "✅ Check passed successfully!"
    fi
  elif [ "$MODE" = "install" ]; then
    if [ $CHECK_STATUS -ne 0 ]; then
      echo "⚠️  Check encountered errors."
      read -p "Would you still like to install the package? (y/n): " proceed
      if [[ "$proceed" =~ ^[Yy]$ ]]; then
        echo "📥 Installing the package despite errors..."
        R CMD INSTALL "$PKG_TAR"
        echo "✅ Installation completed (with warnings)."
      else
        echo "🚫 Installation canceled."
        return 1
      fi
    else
      echo "✅ Check passed successfully. Installing the package..."
      R CMD INSTALL "$PKG_TAR"
      echo "✅ Installation completed successfully."
    fi
  fi

  echo "🧽 Cleaning up build artifacts..."
  rm -rf "$TMP_PATH" || true

  echo "--------------------------------------------"
  echo "✨ All done! Package built, checked${MODE:+, $MODE} and cleaned."
}

# ============================================================
# Public functions
# ============================================================
R_CMD_check() {
  if [ -z "$1" ]; then
    echo "❌ Usage: R_CMD_check /path/to/pkg [--args \"flags\"] [--build_args \"flags\"]"
    return 1
  fi
  _run_build_and_check "$(realpath "$1")" "check" "${@:2}"
}

R_CMD_install() {
  if [ -z "$1" ]; then
    echo "❌ Usage: R_CMD_install /path/to/pkg [--args \"flags\"] [--build_args \"flags\"]"
    return 1
  fi
  _run_build_and_check "$(realpath "$1")" "install" "${@:2}"
}

# ============================================================
# Exports (only when sourced)
# ============================================================
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  export -f R_CMD_check
  export -f R_CMD_install
fi

# ============================================================
# Optional CLI entry point
# ============================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  CMD="$1"; shift || true
  case $CMD in
    check)   R_CMD_check "$@" ;;
    install) R_CMD_install "$@" ;;
    *)
      echo "Usage:"
      echo "  R_CMD_tools check /path/to/pkg [--args \"flags\"] [--build_args \"flags\"]"
      echo "  R_CMD_tools install /path/to/pkg [--args \"flags\"] [--build_args \"flags\"]"
      ;;
  esac
fi
