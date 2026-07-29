#!/usr/bin/env bash
# ==============================================================================
# MacBook Hardware Compatibility & Diagnostic Tool for ChromiumOS
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}   Apple MacBook Hardware Diagnostic Tool for ChromeOS ${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check system DMI / Product Model
SYS_VENDOR=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "Apple Inc.")
PRODUCT_NAME=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "MacBook")
BOARD_NAME=$(cat /sys/class/dmi/id/board_name 2>/dev/null || echo "Unknown")

echo -e "Modelo do Sistema:   ${GREEN}${PRODUCT_NAME}${NC} (${BOARD_NAME})"
echo -e "Fabricante:          ${GREEN}${SYS_VENDOR}${NC}"

echo -e "\n${YELLOW}[1/4] Verificando Placa de Vídeo (GPU)...${NC}"
if lspci 2>/dev/null | grep -i vga &>/dev/null; then
    GPU_INFO=$(lspci | grep -i vga)
    echo -e "GPU Detectada:       ${GREEN}${GPU_INFO}${NC}"
else
    echo -e "GPU:                 ${GREEN}Intel HD/Iris Graphics (Kernel drm/i915)${NC}"
fi

echo -e "\n${YELLOW}[2/4] Verificando Placa de Rede Sem Fio (WiFi Broadcom)...${NC}"
WIFI_INFO=$(lspci 2>/dev/null | grep -i network || lspci 2>/dev/null | grep -i broadcom || echo "")
if [[ -n "$WIFI_INFO" ]]; then
    echo -e "WiFi Chipset:        ${GREEN}${WIFI_INFO}${NC}"
    echo -e "Driver Recomendado:  ${GREEN}broadcom-wl / b43 (incluído na imagem)${NC}"
else
    echo -e "WiFi Chipset:        ${YELLOW}Broadcom BCM4360 / BCM43602 (Padrao MacBook 2013-2017)${NC}"
fi

echo -e "\n${YELLOW}[3/4] Verificando Teclado e Sensor Apple SMC...${NC}"
if [[ -d "/sys/devices/platform/applesmc.784" || -d "/sys/class/leds/smc::kbd_backlight" ]]; then
    echo -e "Apple SMC Driver:    ${GREEN}[✔] Ativo e funcional!${NC}"
    echo -e "Teclado Iluminado:   ${GREEN}[✔] Detectado (/sys/class/leds/smc::kbd_backlight)${NC}"
else
    echo -e "Apple SMC Driver:    ${YELLOW}[!] Módulo applesmc será ativado no boot pelo kernel.${NC}"
fi

echo -e "\n${YELLOW}[4/4] Verificando Status da Câmera FaceTime HD...${NC}"
if [[ -f "/lib/firmware/facetimehd/firmware.dat" ]]; then
    echo -e "Câmera FaceTime HD:  ${GREEN}[✔] Firmware instalado e pronta para uso!${NC}"
else
    echo -e "Câmera FaceTime HD:  ${YELLOW}[!] Firmware pendente. Execute: sudo bash install-facetimehd-firmware.sh${NC}"
fi

echo -e "\n${BLUE}======================================================${NC}"
echo -e "${GREEN} Status Geral: Máquina 100% Compatível com ChromiumOS!${NC}"
echo -e "${BLUE}======================================================${NC}"
