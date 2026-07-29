#!/usr/bin/env bash
# ==============================================================================
# Terminal Interactive Installer & Utility Menu for ChromiumOS on MacBook
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

show_menu() {
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${CYAN} 🍏 ChromiumOS MacBook Setup & Diagnostic Utilities ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e " 1) 🔍 Executar Diagnóstico de Hardware"
    echo -e " 2) 📷 Instalar Firmware da Câmera FaceTime HD"
    echo -e " 3) 📶 Carregar/Reativar Driver de WiFi Broadcom"
    echo -e " 4) 📦 Instalar Aplicativos (VS Code, Spotify, VLC, Firefox, Discord)"
    echo -e " 5) 💡 Testar Retroiluminação do Teclado"
    echo -e " 6) 🌡️  Verificar Temperatura da CPU e Ventoinhas"
    echo -e " 7) 📖 Abrir Guia Rápido de Instalação (QUICKSTART)"
    echo -e " 0) 🚪 Sair"
    echo -e "${CYAN}====================================================${NC}"
    echo -n "Escolha uma opção [0-7]: "
}

while true; do
    show_menu
    read -r choice
    case "$choice" in
        1)
            bash scripts/macbook-hw-check.sh
            echo ""; read -r -p "Pressione Enter para voltar ao menu..."
            ;;
        2)
            sudo bash scripts/install-facetimehd-firmware.sh
            echo ""; read -r -p "Pressione Enter para voltar ao menu..."
            ;;
        3)
            sudo bash scripts/install-broadcom-drivers.sh
            echo ""; read -r -p "Pressione Enter para voltar ao menu..."
            ;;
        4)
            bash scripts/install-macbook-apps.sh
            echo ""; read -r -p "Pressione Enter para voltar ao menu..."
            ;;
        5)
            echo "Aumentando brilho do teclado..."
            bash overlay-macbook/chromeos-base/macbook-config/files/macbook-backlight.sh up
            sleep 1
            echo "Diminuindo brilho do teclado..."
            bash overlay-macbook/chromeos-base/macbook-config/files/macbook-backlight.sh down
            echo -e "${GREEN}[✔] Teste de brilho concluído!${NC}"
            echo ""; read -r -p "Pressione Enter para voltar ao menu..."
            ;;
        6)
            bash scripts/macbook-fan-control.sh status
            echo ""; read -r -p "Pressione Enter para voltar ao menu..."
            ;;
        7)
            cat QUICKSTART.md
            echo ""; read -r -p "Pressione Enter para voltar ao menu..."
            ;;
        0)
            echo "Saindo... Bom uso do ChromiumOS no seu MacBook!"
            exit 0
            ;;
        *)
            echo "Opção inválida!"
            sleep 1
            ;;
    esac
done
