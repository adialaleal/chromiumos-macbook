# 🍏 ChromiumOS para Apple MacBook (2013 - 2017)

> **Esteira de Build Automatizada (CI/CD) & Overlay do ChromiumOS para MacBooks com Mapeamento de Teclado Perfeito, Controle de Retroiluminação e Suporte a Câmera FaceTime HD.**

---

## 🚀 Sobre o Projeto

Transforme seu **MacBook Air** ou **MacBook Pro** antigo (modelos de 2013 a 2017) em um Chromebook ultra-rápido, moderno e completamente funcional.

Em vez de compilar o kernel manualmente a cada atualização, este repositório estabelece um **pipeline de CI/CD automatizado via GitHub Actions** que monitora o repositório oficial do ChromiumOS, aplica os patches de hardware da Apple, gera a imagem flashável `.img.xz` e a disponibiliza diretamente na seção de **Releases**.

---

## 🛠️ Recursos e Funcionalidades

### 1. ⌨️ Mapeamento Perfeito do Teclado MacBook
- **Teclas de Função (F1-F12)**:
  - `F1` / `F2`: Controle fino do Brilho da Tela (`KEY_BRIGHTNESSDOWN` / `UP`).
  - `F3`: Mission Control / Visão geral das janelas (`KEY_SCALE`).
  - `F4`: Launcher / Launchpad (`KEY_HOMEPAGE`).
  - `F5` / `F6`: Retroiluminação do Teclado (`KEY_KBDILLUMDOWN` / `UP`).
  - `F7` - `F9`: Controles de Mídia (Voltar, Play/Pause, Avançar).
  - `F10` - `F12`: Mute, Volume Down, Volume Up.
- **Teclas Modificadoras Mac**:
  - `Command` (⌘) mapeado nativamente para a busca/super do ChromeOS.
  - `Option` (⌥) mapeado perfeitamente para `Alt`.

### 2. 💡 Retroiluminação Automática do Teclado (`applesmc`)
- Serviço systemd integrado (`macbook-backlight.service`) com controle via `/sys/class/leds/smc::kbd_backlight/brightness`.

### 3. 📷 Suporte à Câmera FaceTime HD (Extração Legal de Firmware)
- Para respeitar os termos de licença da Apple sem violar direitos autorais, o firmware da câmera (`firmware.dat`) **não** é distribuído na imagem.
- O script pós-instalação [`scripts/install-facetimehd-firmware.sh`](scripts/install-facetimehd-firmware.sh) baixa a atualização oficial de recuperação da Apple, extrai o firmware localmente e ativa a webcam FaceTime HD no módulo do kernel `facetimehd`.

---

## ⚙️ Arquitetura do Pipeline CI/CD

```
[ Upstream ChromiumOS ] + [ Overlay Apple (Kernel/hwdb/ALSA) ]
                                    │
                                    ▼
                     [ GitHub Actions (Weekly Cron / Dispatch) ]
                                    │ (cros_sdk / Docker Build)
                                    ▼
                 [ Release do Fork (chromiumos-macbook.img.xz) ]
                                    │
                                    ▼
                [ Instalação no MacBook + Script de Firmware ]
```

---

## 💻 Guia de Instalação Rápida

### Passo 1: Baixar a Imagem Pronta
1. Vá para a seção de **Releases** deste repositório no GitHub.
2. Baixe o arquivo `chromiumos-macbook.img.xz` e o script `install-facetimehd-firmware.sh`.

### Passo 2: Gravar no Pendrive
Use o **BalenaEtcher** ou a linha de comando (`dd`):
```bash
xz -d chromiumos-macbook.img.xz
sudo dd if=chromiumos-macbook.img of=/dev/sdX bs=4M status=progress conv=fsync
```

### Passo 3: Dar Boot no MacBook
1. Desligue o MacBook.
2. Ligue segurando a tecla **Option (⌥)** até aparecer o menu de boot.
3. Selecione o pendrive **EFI Boot**.
4. Siga as instruções na tela para instalar o ChromiumOS no SSD do MacBook.

### Passo 4: Ativar a Câmera FaceTime HD
Após o primeiro boot e configuração inicial, abra o terminal do ChromeOS (Ctrl + Alt + T -> digite `shell`) ou faça login via TTY (Ctrl + Alt + F2):
```bash
sudo bash install-facetimehd-firmware.sh
```
O script baixará o firmware oficial diretamente da Apple e ativará a câmera!

---

## 📂 Estrutura do Repositório

- `.github/workflows/build-macbook-chromiumos.yml`: Esteira de integração contínua do GitHub Actions.
- `overlay-macbook/`: Overlay do Gentoo/ChromiumOS com configurações e ebuilds da Apple.
- `overlay-macbook/chromeos-base/macbook-config/files/60-macbook-keyboard.hwdb`: Tabela de mapeamento udev hwdb do teclado Mac.
- `scripts/install-facetimehd-firmware.sh`: Extrator automático e legal do firmware FaceTime HD.
- `scripts/setup_poc_build.sh`: Script para rodar o build localmente em containers Docker.

---

## 📄 Licença

Este projeto é disponibilizado sob a licença BSD 3-Clause. Os direitos dos firmwares da Apple pertencem à Apple Inc.
