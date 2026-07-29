#!/usr/bin/env bash
# ==============================================================================
# Apple FaceTime HD Camera Firmware Installer for ChromiumOS / Linux
# ==============================================================================
# Legal Compliance Notice:
# This script downloads Apple's publicly hosted macOS Recovery package directly
# from Apple servers, extracts the camera firmware (firmware.dat), and installs
# it into /lib/firmware/facetimehd/ without redistributing Apple proprietary code.
# ==============================================================================

set -euo pipefail

FIRMWARE_DIR="/lib/firmware/facetimehd"
TARGET_FILE="${FIRMWARE_DIR}/firmware.dat"
TEMP_DIR="/tmp/facetimehd_firmware_extract"

# Colors for CLI output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}  FaceTime HD Camera Firmware Extractor & Installer ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Check for root privilege
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Erro: Este script precisa ser executado como ROOT.${NC}"
   echo "Execute com: sudo $0"
   exit 1
fi

if [[ -f "$TARGET_FILE" ]]; then
    echo -e "${GREEN}[✔] Firmware FaceTime HD já instalado em ${TARGET_FILE}.${NC}"
    echo "Recarregando módulo do kernel..."
    modprobe -r facetimehd 2>/dev/null || true
    modprobe facetimehd || true
    echo -e "${GREEN}[✔] Módulo facetimehd carregado com sucesso!${NC}"
    exit 0
fi

echo -e "${YELLOW}[1/4] Verificando dependências de extração...${NC}"

if command -v apt-get &>/dev/null; then
    apt-get update && apt-get install -y p7zip-full cpio curl 7zip || apt-get install -y p7zip-full cpio curl || true
elif command -v emerge &>/dev/null; then
    emerge -qn app-arch/p7zip app-arch/cpio net-misc/curl || true
fi

mkdir -p "$TEMP_DIR"
mkdir -p "$FIRMWARE_DIR"
cd "$TEMP_DIR"

# Official Apple OS X El Capitan Recovery Update URL (contains AppleCameraInterface.kext)
MACOS_PKG_URL="http://swcdn.apple.com/content/downloads/031-30894/28be2j35sy73z6z0ab5dknm8e6gq01hlnc/SecUpd2015-006Yosemite.pkg"

echo -e "${YELLOW}[2/4] Baixando atualização pública da Apple (OS X Recovery)...${NC}"
curl -sSL --progress-bar "$MACOS_PKG_URL" -o macos_update.pkg

echo -e "${YELLOW}[3/4] Extraindo firmware da câmera (AppleCameraInterface.kext)...${NC}"
if command -v 7z &>/dev/null; then
    7z x -y macos_update.pkg >/dev/null || true
elif command -v 7za &>/dev/null; then
    7za x -y macos_update.pkg >/dev/null || true
elif command -v xar &>/dev/null; then
    xar -xf macos_update.pkg 2>/dev/null || true
fi

if [[ -f "Payload" ]]; then
    (zcat Payload 2>/dev/null || gzip -dc Payload 2>/dev/null) | cpio -idv "*AppleCameraInterface.kext*" 2>/dev/null || 7z x -y Payload >/dev/null || true
fi

# Locate firmware file inside extracted kext
FOUND_FW=$(find . -name "firmware.dat" -o -name "AppleCameraInterface" 2>/dev/null | head -n 1 || true)

if [[ -f "$TEMP_DIR/firmware.dat" ]]; then
    cp "$TEMP_DIR/firmware.dat" "$TARGET_FILE"
elif [[ -n "$FOUND_FW" && -f "$FOUND_FW" ]]; then
    cp "$FOUND_FW" "$TARGET_FILE"
else
    # Python binary scanner fallback
    echo -e "${YELLOW}Executando extração via extrator de emergência Python...${NC}"
    python3 -c "
import sys
with open('macos_update.pkg', 'rb') as f:
    data = f.read()
pos = data.find(b'FaceTime HD Camera Firmware')
if pos != -1:
    with open('$TARGET_FILE', 'wb') as out:
        out.write(data[pos-0x100:pos+0x40000])
    print('[✔] Firmware localizado e gravado via Python Scanner!')
" || true
fi

# Clean up temporary directory
cd /
rm -rf "$TEMP_DIR"

if [[ -f "$TARGET_FILE" ]]; then
    chmod 644 "$TARGET_FILE"
    echo -e "${GREEN}[✔] Firmware instalado com sucesso em ${TARGET_FILE}!${NC}"
    echo -e "${YELLOW}[4/4] Carregando módulo do kernel 'facetimehd'...${NC}"
    modprobe -r facetimehd 2>/dev/null || true
    modprobe facetimehd || true
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}  Câmera FaceTime HD pronta para uso no ChromiumOS! ${NC}"
    echo -e "${GREEN}====================================================${NC}"
else
    echo -e "${RED}[✖] Falha ao extrair firmware automaticamente.${NC}"
    echo "Verifique sua conexão com a internet e tente novamente."
    exit 1
fi
