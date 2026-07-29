#!/usr/bin/env bash
# ==============================================================================
# Essential Applications & Office Suite Installer for ChromiumOS MacBook Edition
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}  Instalador de Aplicativos e Suíte Office (MacBook) ${NC}"
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

echo -e "${YELLOW}[2/3] Escolha os softwares/suítes office que deseja instalar:${NC}"
echo " 1) 📊 OnlyOffice (Visual idêntico ao MS Office: Word, Excel, PowerPoint)"
echo " 2) 📄 LibreOffice (Suíte de Escritório Completa Offline)"
echo " 3) 🌐 Microsoft 365 (Cria atalho do MS Office PWA no ChromeOS)"
echo " 4) 📝 Visual Studio Code (Editor de Código)"
echo " 5) 🎵 Spotify (Música e Podcasts)"
echo " 6) 🎬 VLC Media Player (Reprodutor de Vídeos HD)"
echo " 7) 🌐 Firefox (Navegador alternativo com DRM/Netflix nativo)"
echo " 8) 💬 Discord (Comunicação)"
echo " 9) 🚀 Instalação Completa Recomendada (OnlyOffice + VS Code + Spotify + VLC + Firefox)"
echo " 0) 🔙 Cancelar"

read -r -p "Digite a opção desejada [0-9]: " APP_CHOICE

install_app() {
    local app_id="$1"
    local app_name="$2"
    echo -e "${CYAN}Instalando ${app_name}...${NC}"
    if command -v flatpak &>/dev/null; then
        sudo flatpak install -y flathub "$app_id" || echo -e "${YELLOW}Aviso: Falha ao instalar $app_name via Flatpak.${NC}"
    fi
}

create_ms_office_pwa() {
    echo -e "${CYAN}Configurando atalhos do Microsoft 365 (PWA)...${NC}"
    mkdir -p ~/.local/share/applications
    cat << 'EOF' > ~/.local/share/applications/ms-office-365.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Microsoft 365 (Office)
Comment=Acesse Word, Excel, PowerPoint e OneDrive online
Exec=google-chrome --app=https://www.office.com
Icon=office
Categories=Office;
Terminal=false
EOF
    echo -e "${GREEN}[✔] Atalho do Microsoft 365 criado no Launcher do ChromeOS!${NC}"
}

case "$APP_CHOICE" in
    1) install_app "org.onlyoffice.desktopeditors" "OnlyOffice Desktop Editors" ;;
    2) install_app "org.libreoffice.LibreOffice" "LibreOffice" ;;
    3) create_ms_office_pwa ;;
    4) install_app "com.visualstudio.code" "Visual Studio Code" ;;
    5) install_app "com.spotify.Client" "Spotify" ;;
    6) install_app "org.videolan.VLC" "VLC Media Player" ;;
    7) install_app "org.mozilla.firefox" "Firefox" ;;
    8) install_app "com.discordapp.Discord" "Discord" ;;
    9)
        install_app "org.onlyoffice.desktopeditors" "OnlyOffice Desktop Editors"
        create_ms_office_pwa
        install_app "com.visualstudio.code" "Visual Studio Code"
        install_app "com.spotify.Client" "Spotify"
        install_app "org.videolan.VLC" "VLC Media Player"
        install_app "org.mozilla.firefox" "Firefox"
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
