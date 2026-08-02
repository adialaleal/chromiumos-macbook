#!/usr/bin/env bash
# ==============================================================================
# Interface TUI Interativa para Gravação da Imagem ChromiumOS no Pendrive
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
IMAGE_PATH="${PROJECT_ROOT}/build_workspace/src/build/images/amd64-generic/latest/chromiumos_image.bin"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}"
echo "==========================================================="
echo " 💾 CHROMIUMOS MACBOOK - GRAVADOR DE PENDRIVE (TUI)"
echo "==========================================================="
echo -e "${NC}"

# Check if image exists
if [ ! -f "${IMAGE_PATH}" ]; then
    echo -e "${YELLOW}⚠️ Imagem compilada não encontrada no caminho padrão:${NC}"
    echo "   ${IMAGE_PATH}"
    echo ""
    read -rp "Digite o caminho completo para a imagem .bin (ou Enter para cancelar): " CUSTOM_PATH
    if [ -n "${CUSTOM_PATH}" ] && [ -f "${CUSTOM_PATH}" ]; then
        IMAGE_PATH="${CUSTOM_PATH}"
    else
        echo -e "${RED}❌ Nenhuma imagem válida informada. Encerrando.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Imagem selecionada:${NC} ${IMAGE_PATH}"
IMAGE_SIZE=$(du -h "${IMAGE_PATH}" | cut -f1)
echo -e "   Tamanho da imagem: ${BOLD}${IMAGE_SIZE}${NC}"
echo ""

# Detect OS
OS_TYPE="$(uname -s)"

echo -e "${CYAN}🔍 Buscando dispositivos USB / Pendrives conectados...${NC}"
echo ""

# Array for drives
DRIVES=()
DRIVE_NAMES=()

if [ "${OS_TYPE}" = "Darwin" ]; then
    # macOS diskutil
    while IFS= read -r line; do
        DRIVES+=("${line}")
    done < <(diskutil list | grep -E "^/dev/disk" | awk '{print $1}')
else
    # Linux lsblk
    while IFS= read -r line; do
        DRIVES+=("${line}")
    done < <(lsblk -d -n -o NAME,TYPE,SIZE,MODEL | grep -E "disk" | awk '{print "/dev/"$1" ("$3" - "$4")"}')
fi

if [ ${#DRIVES[@]} -eq 0 ]; then
    echo -e "${RED}❌ Nenhum pendrive/disco foi detectado.${NC}"
    echo "Por favor, conecte o pendrive e tente novamente."
    exit 1
fi

echo -e "${BOLD}Selecione o Pendrive para a Gravação:${NC}"
echo "-----------------------------------------------------------"

for i in "${!DRIVES[@]}"; do
    echo -e "  ${CYAN}[$((i+1))]${NC} ${DRIVES[$i]}"
done

echo "-----------------------------------------------------------"
read -rp "Digite o número do Pendrive desejado (1-${#DRIVES[@]}): " CHOICE

if ! [[ "${CHOICE}" =~ ^[0-9]+$ ]] || [ "${CHOICE}" -lt 1 ] || [ "${CHOICE}" -gt "${#DRIVES[@]}" ]; then
    echo -e "${RED}❌ Opção inválida. Operação cancelada.${NC}"
    exit 1
fi

TARGET_DRIVE_FULL="${DRIVES[$((CHOICE-1))]}"
TARGET_DRIVE=$(echo "${TARGET_DRIVE_FULL}" | awk '{print $1}')

echo ""
echo -e "${RED}${BOLD}⚠️  ATENÇÃO: TODOS OS DADOS EM ${TARGET_DRIVE} SERÃO APAGADOS! ⚠️${NC}"
echo -e "Disco alvo: ${YELLOW}${TARGET_DRIVE_FULL}${NC}"
echo ""
read -rp "Tem certeza que deseja gravar a imagem neste dispositivo? (s/N): " CONFIRM

if [[ "${CONFIRM}" != "s" && "${CONFIRM}" != "S" ]]; then
    echo -e "${YELLOW}Operação cancelada pelo usuário.${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}🚀 Desmontando volumes e iniciando a gravação com dd...${NC}"

if [ "${OS_TYPE}" = "Darwin" ]; then
    diskutil unmountDisk "${TARGET_DRIVE}" || true
    echo -e "${GREEN}Gravando via dd (solicitando senha sudo se necessário)...${NC}"
    sudo dd if="${IMAGE_PATH}" of="${TARGET_DRIVE}" bs=4m status=progress
    diskutil eject "${TARGET_DRIVE}" || true
else
    # Linux
    sudo umount "${TARGET_DRIVE}"* 2>/dev/null || true
    echo -e "${GREEN}Gravando via dd (solicitando senha sudo se necessário)...${NC}"
    sudo dd if="${IMAGE_PATH}" of="${TARGET_DRIVE}" bs=4M status=progress conv=fdatasync
fi

echo ""
echo -e "${GREEN}${BOLD}===========================================================${NC}"
echo -e "${GREEN}${BOLD} 🎉 GRAVAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
echo -e "${GREEN}${BOLD} O seu Pendrive de Boot do ChromiumOS para MacBook está pronto!${NC}"
echo -e "${GREEN}${BOLD}===========================================================${NC}"
