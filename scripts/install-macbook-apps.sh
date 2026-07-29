#!/usr/bin/env bash
# ==============================================================================
# Essential Applications & Flatpak Installer for ChromiumOS MacBook Edition
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}  Instalador de Aplicativos Essenciais para MacBook ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Ensure Flatpak and Flathub repository are configured
echo -e "${YELLOW}[1/3] Configurando suporte a Flatpak / Flathub...${NC}"
if ! command -v flatpak &>/dev/null; then
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y flatpak
    elif command -v emerge &>/dev/null; then
        sudo emerge -qn sys-apps/flatpak
    fi
fi

if command -v flatpak &>/dev/null; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
fi

echo -e "${YELLOW}[2/3] Escolha os softwares que deseja instalar:${NC}"
echo " 1) 🌐 Firefox (Navegador alternativo com DRM/Netflix nativo)"
echo " 2) 📝 Visual Studio Code (Editor de Código)"
echo " 3) 🎵 Spotify (Música e Podcasts)"
echo " 4) 🎬 VLC Media Player (Reprodutor de Vídeos HD)"
echo " 5) 💬 Discord (Comunicação)"
echo " 6) 📄 LibreOffice (Suíte de Escritório Completa)"
echo " 7) 🚀 Todos os acima (Instalação Completa Recomendada)"
echo " 0) 🔙 Cancelar"

read -r -p "Digite a opção desejada [0-7]: " APP_CHOICE

install_app() {
    local app_id="$1"
    local app_name="$2"
    echo -e "${CYAN}Instalando ${app_name}...${NC}"
    if command -v flatpak &>/dev/null; then
        sudo flatpak install -y flathub "$app_id" || echo -e "${YELLOW}Aviso: Falha ao instalar $app_name via Flatpak.${NC}"
    fi
}

case "$APP_CHOICE" in
    1) install_app "org.mozilla.firefox" "Firefox" ;;
    2) install_app "com.visualstudio.code" "Visual Studio Code" ;;
    3) install_app "com.spotify.Client" "Spotify" ;;
    4) install_app "org.videolan.VLC" "VLC Media Player" ;;
    5) install_app "com.discordapp.Discord" "Discord" ;;
    6) install_app "org.libreoffice.LibreOffice" "LibreOffice" ;;
    7)
        install_app "org.mozilla.firefox" "Firefox"
        install_app "com.visualstudio.code" "Visual Studio Code"
        install_app "com.spotify.Client" "Spotify"
        install_app "org.videolan.VLC" "VLC Media Player"
        install_app "com.discordapp.Discord" "Discord"
        install_app "org.libreoffice.LibreOffice" "LibreOffice"
        ;;
    0)
        echo "Operação cancelada."
        exit 0
        ;;
    *)
        echo "Opção inválida!"
        exit 1
        ;;
esac

echo -e "\n${GREEN}[3/3] Instalação concluída com sucesso!${NC}"
echo "Os aplicativos agora estão disponíveis no Launcher do ChromiumOS."
