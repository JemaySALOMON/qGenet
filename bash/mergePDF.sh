#!/bin/bash
# ============================================================
# mergePDF.sh — Merge multiple PDF files into one
# Author  : Jemay SALOMON
# Date    : 2025-10-10
# Version : 1.0
# License : MIT
# ============================================================
# Description:
#   This script merges multiple PDF files into a single PDF file.
#   It automatically checks whether 'pdftk' is installed,
#   installs it if missing, and handles input validation safely.
#
# Usage:
#   ./mergePDF.sh output.pdf file1.pdf file2.pdf [file3.pdf ...]
#
# Example:
#   ./mergePDF.sh merged.pdf chapter1.pdf chapter2.pdf appendix.pdf
#
# Notes:
#   - Requires 'pdftk' (PDF Toolkit).
#   - If not found, the script attempts to install it via apt (Debian/Ubuntu).
#   - Compatible with Linux systems using Bash.
# ============================================================

# Exit immediately if a command fails
set -e

# --- Step 1. Check arguments ---
if [ "$#" -lt 3 ]; then
  echo "❌ Error: insufficient arguments."
  echo "Usage: $0 output.pdf input1.pdf input2.pdf [input3.pdf ...]"
  exit 1
fi

output="$1"
shift  # shift removes the first argument so "$@" now contains only input files

# --- Step 2. Check if 'pdftk' is installed ---
if ! command -v pdftk &> /dev/null; then
  echo "⚠️  'pdftk' is not installed on your system."
  read -p "Would you like to install it now? (y/n): " install_choice
  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    if [ "$(id -u)" -ne 0 ]; then
      echo "🔑 Administrator privileges are required. Please enter your password if prompted."
      sudo apt update && sudo apt install -y pdftk
    else
      apt update && apt install -y pdftk
    fi
  else
    echo "🚫 Aborting: 'pdftk' is required to merge PDFs."
    exit 1
  fi
fi

# --- Step 3. Merge PDFs ---
echo "📄 Merging PDF files..."
pdftk "$@" cat output "$output"

# --- Step 4. Confirmation message ---
echo "✅ Merged PDF saved as: $output"
echo "🎉 Merge completed successfully!"