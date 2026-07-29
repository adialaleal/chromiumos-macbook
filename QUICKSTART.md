# ⚡ Guia Rápido de Instalação no MacBook

Este guia explica como instalar a imagem compilada do ChromiumOS no seu **MacBook Air / Pro (2013-2017)** e ativar todas as funções de hardware.

---

## 📋 Pré-requisitos
1. Um Pendrive USB de pelo menos **8 GB**.
2. O aplicativo [BalenaEtcher](https://balena.io/etcher) (ou utilitário `dd` no Linux/macOS).
3. Conexão Wi-Fi ativa no MacBook.

---

## 🛠️ Passo a Passo

### 1. Gravação da Imagem no Pendrive
1. Faça o download da última release `chromiumos-macbook.img.xz`.
2. Abra o BalenaEtcher.
3. Selecione o arquivo `chromiumos-macbook.img.xz`.
4. Selecione o seu Pendrive USB.
5. Clique em **Flash!**.

---

### 2. Boot no MacBook
1. Conecte o pendrive gravado no MacBook.
2. Ligue o MacBook mantendo pressionada a tecla **Option (⌥)**.
3. Quando a tela amarela/prateada de seleção de disco surgir, clique em **EFI Boot**.

---

### 3. Ajustes de Teclado no Primeiro Uso
O sistema iniciará com o mapeamento nativo de hardware aplicado:
- **Brilho da Tela**: Teclas `F1` e `F2`.
- **Brilho do Teclado**: Teclas `F5` e `F6`.
- **Volume e Mídia**: Teclas `F7` a `F12`.
- **Tecla Cmd (⌘)**: Funciona como a tecla de Busca / Launcher do ChromeOS.

---

### 4. Ativação da Câmera FaceTime HD
Para ativar a webcam FaceTime HD:
1. Abra o terminal (pressione `Ctrl` + `Alt` + `T` e digite `shell`).
2. Digite o seguinte comando:
```bash
sudo bash /usr/bin/install-facetimehd-firmware.sh
```
3. O script baixará e instalará o firmware. Em alguns segundos, a luz da câmera piscará e o aplicativo de Câmera do ChromeOS detectará o dispositivo!
