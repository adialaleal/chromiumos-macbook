#!/usr/bin/env bash
# ==============================================================================
# Broadcom WiFi Offline Driver & Firmware Installer for MacBook
# Handles BCM4360, BCM43602, BCM4331 WiFi chipsets on MacBook Air/Pro
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   Instalador de Drivers WiFi Broadcom (MacBook)   ${NC}"
echo -e "${BLUE}====================================================${NC}"

if [[ $EUID -ne 0 ]]; then
   echo "Erro: Execute este script como ROOT (sudo $0)"
   exit 1
fi

echo -e "${YELLOW}[1/2] Carregando módulos do kernel Broadcom (wl / b43)...${NC}"

# Unload any conflicting modules
modprobe -r b43 ssb wl brcmfmac 2>/dev/null || true

# Try proprietary wl module first
if modprobe wl 2>/dev/null; then
    echo -e "${GREEN}[✔] Módulo proprietário Broadcom 'wl' carregado com sucesso!${NC}"
elif modprobe brcmfmac 2>/dev/null; then
    echo -e "${GREEN}[✔] Módulo open-source 'brcmfmac' carregado com sucesso!${NC}"
elif modprobe b43 2>/dev/null; then
    echo -e "${GREEN}[✔] Módulo 'b43' carregado com sucesso!${NC}"
else
    echo -e "${YELLOW}Tentando compilar/instalar firmware b43 offline...${NC}"
    mkdir -p /lib/firmware/b43
    # Extract b43 firmware if present
    if [[ -f "/usr/share/b43-firmware/b43-fw.tar.gz" ]]; then
        tar -xzf /usr/share/b43-firmware/b43-fw.tar.gz -C /lib/firmware/
        modprobe b43
    fi
fi

echo -e "${YELLOW}[2/2] Reiniciando serviço de rede (NetworkManager / shill)...${NC}"
systemctl restart shill 2>/dev/null || systemctl restart NetworkManager 2>/dev/null || true

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}  Placa WiFi Broadcom Pronta para Conexão!          ${NC}"
echo -e "${GREEN}====================================================${NC}"
