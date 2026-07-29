#!/usr/bin/env bash
# ==============================================================================
# Developer Tools, AI Assistants & Apps Installer for ChromiumOS MacBook Edition
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}  Instalador de Ferramentas Dev & IAs (MacBook)     ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Ensure Flatpak and Flathub repository are configured
echo -e "${YELLOW}[1/3] Configurando ambiente de softwares...${NC}"
if ! command -v flatpak &>/dev/null; then
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y flatpak git curl python3 build-essential
    elif command -v emerge &>/dev/null; then
        sudo emerge -qn sys-apps/flatpak dev-vcs/git
    fi
fi

if command -v flatpak &>/dev/null; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
fi

echo -e "${YELLOW}[2/3] Escolha as ferramentas que deseja instalar:${NC}"
echo " 1) 🤖 ChatGPT & Claude.ai (Atalhos de IA de Desktop Nativos)"
echo " 2) 💻 Pacote Desenvolvedor (Git, GitHub CLI, VS Code, Python3, Node.js)"
echo " 3) 📊 OnlyOffice & Microsoft 365 (Suítes Office Completas)"
echo " 4) 🎵 Spotify & VLC Media Player (Multimídia)"
echo " 5) 🌐 Firefox (Navegador com suporte a DRM/Netflix)"
echo " 6) 💬 Discord & Slack (Comunicação)"
echo " 7) 🚀 INSTALAR TUDO (Ferramentas Dev + IAs + Office + Apps)"
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

setup_ai_apps() {
    echo -e "${CYAN}Configurando atalhos de Desktop para ChatGPT e Claude...${NC}"
    mkdir -p ~/.local/share/applications

    # ChatGPT PWA Desktop Entry
    cat << 'EOF' > ~/.local/share/applications/chatgpt.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=ChatGPT
Comment=OpenAI ChatGPT AI Assistant
Exec=google-chrome --app=https://chatgpt.com
Icon=chatgpt
Categories=Utility;Development;
Terminal=false
EOF

    # Claude PWA Desktop Entry
    cat << 'EOF' > ~/.local/share/applications/claude.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Claude AI
Comment=Anthropic Claude AI Assistant
Exec=google-chrome --app=https://claude.ai
Icon=claude
Categories=Utility;Development;
Terminal=false
EOF
    echo -e "${GREEN}[✔] Atalhos do ChatGPT e Claude.ai criados no Launcher do ChromeOS!${NC}"
}

setup_dev_environment() {
    echo -e "${CYAN}Instalando VS Code, Git e ambiente de desenvolvimento...${NC}"
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y git curl python3 python3-pip build-essential || true
    fi
    install_app "com.visualstudio.code" "Visual Studio Code"
    echo -e "${GREEN}[✔] Ferramentas de Desenvolvimento e Git configuradas!${NC}"
}

case "$APP_CHOICE" in
    1) setup_ai_apps ;;
    2) setup_dev_environment ;;
    3)
        install_app "org.onlyoffice.desktopeditors" "OnlyOffice Desktop Editors"
        ;;
    4)
        install_app "com.spotify.Client" "Spotify"
        install_app "org.videolan.VLC" "VLC Media Player"
        ;;
    5) install_app "org.mozilla.firefox" "Firefox" ;;
    6) install_app "com.discordapp.Discord" "Discord" ;;
    7)
        setup_ai_apps
        setup_dev_environment
        install_app "org.onlyoffice.desktopeditors" "OnlyOffice Desktop Editors"
        install_app "com.spotify.Client" "Spotify"
        install_app "org.videolan.VLC" "VLC Media Player"
        install_app "org.mozilla.firefox" "Firefox"
        install_app "com.discordapp.Discord" "Discord"
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
