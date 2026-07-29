#!/usr/bin/env bash
# ==============================================================================
# ChromiumOS MacBook Local Build & Compilation Environment Setup
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

WORKSPACE_DIR="${HOME}/chromiumos"
OVERLAY_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/overlay-macbook"

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}   Configurando Ambiente de Build do ChromiumOS      ${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo -e "Diretório do Workspace: ${GREEN}${WORKSPACE_DIR}${NC}"
echo -e "Caminho do Overlay:      ${GREEN}${OVERLAY_SRC}${NC}"

mkdir -p "${WORKSPACE_DIR}"

echo -e "\n${YELLOW}[1/4] Verificando e instalando Google depot_tools...${NC}"
if [[ ! -d "${HOME}/depot_tools" ]]; then
    echo "Clonando depot_tools..."
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "${HOME}/depot_tools"
fi
export PATH="${HOME}/depot_tools:${PATH}"

echo -e "\n${YELLOW}[2/4] Verificando ferramenta 'repo' do Android/ChromiumOS...${NC}"
if ! command -v repo &>/dev/null; then
    mkdir -p "${HOME}/bin"
    curl -s https://storage.googleapis.com/git-repo-downloads/repo > "${HOME}/bin/repo"
    chmod a+rx "${HOME}/bin/repo"
    export PATH="${HOME}/bin:${PATH}"
fi

echo -e "\n${YELLOW}[3/4] Vinculando overlay-macbook ao workspace...${NC}"
mkdir -p "${WORKSPACE_DIR}/src/overlays"
if [[ ! -d "${WORKSPACE_DIR}/src/overlays/overlay-macbook" ]]; then
    ln -sf "${OVERLAY_SRC}" "${WORKSPACE_DIR}/src/overlays/overlay-macbook"
    echo -e "${GREEN}[✔] Overlay vinculado em src/overlays/overlay-macbook!${NC}"
fi

echo -e "\n${YELLOW}[4/4] Passos para iniciar a compilação no Terminal:${NC}"
echo -e "${CYAN}-----------------------------------------------------${NC}"
echo "1) Entre no diretório do workspace:"
echo "   cd ~/chromiumos"
echo ""
echo "2) Inicialize o código-fonte do ChromiumOS (se ainda não fez):"
echo "   repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --repo-url https://chromium.googlesource.com/external/repo.git"
echo "   repo sync -j\$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"
echo ""
echo "3) Inicie o container do SDK e compile a imagem para MacBook (amd64-generic):"
echo "   cros_sdk"
echo "   setup_board --board=amd64-generic"
echo "   build_packages --board=amd64-generic"
echo "   build_image --board=amd64-generic dev"
echo -e "${CYAN}-----------------------------------------------------${NC}"
echo -e "${GREEN}[✔] Ambiente de compilação configurado com sucesso!${NC}"
