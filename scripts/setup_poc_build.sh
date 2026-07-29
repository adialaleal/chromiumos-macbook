#!/usr/bin/env bash
# Local Setup & PoC Build Script for ChromiumOS MacBook Overlay

set -euo pipefail

WORKSPACE_DIR="${HOME}/chromiumos"
OVERLAY_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/overlay-macbook"

echo "====================================================="
echo "   Setting up ChromiumOS PoC Build Environment"
echo "====================================================="
echo "Workspace Directory: ${WORKSPACE_DIR}"
echo "Overlay Source:      ${OVERLAY_SRC}"

mkdir -p "${WORKSPACE_DIR}"

if ! command -v depot_tools &>/dev/null; then
    if [[ ! -d "${HOME}/depot_tools" ]]; then
        echo "[1/4] Cloning depot_tools..."
        git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "${HOME}/depot_tools"
    fi
    export PATH="${HOME}/depot_tools:${PATH}"
fi

echo "[2/4] Verifying cros_sdk availability..."
if ! command -v cros_sdk &>/dev/null; then
    echo "Note: cros_sdk must be run inside a full ChromiumOS checkout tree."
    echo "To pull ChromiumOS source:"
    echo "  cd ${WORKSPACE_DIR}"
    echo "  repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --repo-url https://chromium.googlesource.com/external/repo.git"
    echo "  repo sync -j$(nproc)"
fi

echo "[3/4] Linking overlay-macbook into board overlays..."
mkdir -p "${WORKSPACE_DIR}/src/overlays"
if [[ ! -d "${WORKSPACE_DIR}/src/overlays/overlay-macbook" ]]; then
    ln -s "${OVERLAY_SRC}" "${WORKSPACE_DIR}/src/overlays/overlay-macbook"
    echo "[✔] Overlay linked to src/overlays/overlay-macbook"
fi

echo "[4/4] Commands to compile image inside cros_sdk:"
echo "-----------------------------------------------------"
echo "  cros_sdk"
echo "  setup_board --board=amd64-generic"
echo "  ./set_shared_user_password.sh"
echo "  build_packages --board=amd64-generic"
echo "  build_image --board=amd64-generic dev"
echo "-----------------------------------------------------"
echo "Completed PoC environment configuration!"
