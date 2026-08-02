#!/usr/bin/env bash
# ==============================================================================
# Script de Compilação Automatizada do ChromiumOS Macbook para Linux x86_64
# ==============================================================================
# Este script automatiza 100% o processo de download, configuração do chroot,
# aplicação das otimizações para Apple MacBook e geração da imagem do ChromiumOS.
# ==============================================================================

set -euo pipefail

echo "==========================================================="
echo " 🚀 Iniciando Compilação do ChromiumOS para Apple MacBook"
echo "==========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_DIR="${PROJECT_ROOT}/build_workspace"
BOARD="amd64-generic"

# 1. Instalar dependências necessárias do sistema host Linux
echo "📦 [1/6] Verificando dependências do host (git, curl, python3, zstd, p7zip)..."
if command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y git curl python3 p7zip-full cpio zstd
elif command -v dnf &>/dev/null; then
    sudo dnf install -y git curl python3 p7zip cpio zstd
elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm git curl python p7zip cpio zstd
fi

# 2. Configurar depot_tools e repo
echo "🛠️ [2/6] Configurando depot_tools..."
mkdir -p "${WORKSPACE_DIR}"
cd "${WORKSPACE_DIR}"

if [ ! -d "${WORKSPACE_DIR}/depot_tools" ]; then
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "${WORKSPACE_DIR}/depot_tools"
fi

export PATH="${WORKSPACE_DIR}/depot_tools:${WORKSPACE_DIR}/chromite/bin:${PATH}"

# 3. Inicializar e Sincronizar o Código-Fonte do ChromiumOS (se ainda não baixado)
if [ ! -d "${WORKSPACE_DIR}/.repo" ]; then
    echo "📥 [3/6] Inicializando repositório do ChromiumOS..."
    repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --no-clone-bundle --depth=1
    echo "🔄 Sincronizando código-fonte (pode levar algum tempo)..."
    repo sync -j"$(nproc)"
else
    echo "✅ [3/6] Código-fonte do ChromiumOS já presente em build_workspace."
fi

# 4. Vincular o Overlay do MacBook ao código do ChromiumOS
echo "🔗 [4/6] Configurando overlay-macbook..."
OVERLAY_TARGET="${WORKSPACE_DIR}/src/overlays/overlay-${BOARD}"
if [ -d "${OVERLAY_TARGET}" ]; then
    mkdir -p "${OVERLAY_TARGET}/chromeos-base/macbook-config"
    cp -rf "${PROJECT_ROOT}/overlay-macbook/"* "${OVERLAY_TARGET}/" 2>/dev/null || true
    echo "✅ Overlay overlay-macbook integrado em ${OVERLAY_TARGET}"
fi

# 5. Criar o Chroot e Configurar a Placa amd64-generic
echo "🔨 [5/6] Criando SDK Chroot e configurando placa ${BOARD}..."
cros_sdk --create -- setup_board --board="${BOARD}"

# 6. Compilar pacotes e gerar imagem final do ChromiumOS
echo "⚙️ [6/6] Compilando pacotes e gerando a imagem DEV do ChromiumOS..."
cros_sdk -- build_packages --board="${BOARD}"
cros_sdk -- build_image --board="${BOARD}" dev

IMAGE_PATH="${WORKSPACE_DIR}/src/build/images/${BOARD}/latest/chromiumos_image.bin"

echo "==========================================================="
echo " 🎉 COMPILAÇÃO CONCLUÍDA COM SUCESSO!"
echo " 📁 Imagem gerada em: ${IMAGE_PATH}"
echo " 💾 Para gravar no pendrive: sudo dd if=${IMAGE_PATH} of=/dev/sdX bs=4M status=progress"
echo "==========================================================="
