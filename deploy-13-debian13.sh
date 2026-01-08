#!/bin/bash

#############
# VARIABLES #
#############

# Colores para el output
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

echo -e "${YELLOW}[*] Iniciando script de configuración de entorno debian i3...${RESET}"

# Real user
REAL_USER=$(logname)
USER_ZSHRC="/home/$REAL_USER/.zshrc"

# Verificar si se ejecuta como root
if [[ "$EUID" -ne 0 ]]; then
  echo -e "${RED}[!] Este script debe ejecutarse como root. Usa sudo.${RESET}"
  exit 1
fi

# Función para verificar si un paquete está instalado
check_installed() {
  if dpkg -s "$1" &>/dev/null; then
    echo -e "${YELLOW}[-] $1 ya está instalado.${RESET}"
    return 0  # Paquete ya instalado
  else
    return 1  # Paquete no instalado
  fi
}


###############
# APT INSTALL #
###############

# Instalar aplicaciones
sudo apt update
sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting kitty curl git flameshot python3-pip python3-venv pipx docker.io docker-compose locate golang tree i3 i3blocks i3lock i3lock-fancy i3status i3-wm picom rofi feh fonts-font-awesome jq dmenu mitm6 xsel xdotool libxfixes-dev make gcc -y


#############
# PIP TOOLS #
#############
pip3 install i3-workspace-names-daemon --break-system-packages


################
# APLICACIONES #
################

# Instalar Obsidian
if ! check_installed obsidian; then
  echo -e "${GREEN}[+] Instalando Obsidian...${RESET}"
  OBSIDIAN_DEB="/tmp/obsidian.deb"
  wget -q https://github.com/obsidianmd/obsidian-releases/releases/download/v1.8.10/obsidian_1.8.10_amd64.deb -O "$OBSIDIAN_DEB"
  dpkg -i "$OBSIDIAN_DEB" || apt -f install -y
  rm "$OBSIDIAN_DEB"
else
  echo -e "${YELLOW}[!] Obsidian ya está instalado, omitiendo instalación.${RESET}"
fi

# Instalar Google Chrome
if ! check_installed google-chrome-stable; then
  echo -e "${GREEN}[+] Instalando Google Chrome...${RESET}"
  CHROME_DEB="/tmp/google-chrome.deb"
  wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O "$CHROME_DEB"
  dpkg -i "$CHROME_DEB" || apt -f install -y
  rm "$CHROME_DEB"
else
  echo -e "${YELLOW}[!] Google Chrome ya está instalado, omitiendo instalación.${RESET}"
fi

# Instalar ProtonVPN GUI oficial
if ! check_installed proton-vpn-gnome-desktop; then
  echo -e "${GREEN}[+] Instalando ProtonVPN (GUI oficial)...${RESET}"
  PROTON_DEB="/tmp/protonvpn-stable-release_1.0.8_all.deb"
  if [[ ! -f "$PROTON_DEB" ]]; then
    wget -q https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb -O "$PROTON_DEB"
  else
    echo -e "${YELLOW}[-] Paquete de ProtonVPN ya descargado.${RESET}"
  fi
  dpkg -i "$PROTON_DEB" && apt update
  apt install proton-vpn-gnome-desktop -y
else
  echo -e "${YELLOW}[!] ProtonVPN ya está instalado, omitiendo instalación.${RESET}"
fi

# Instalar VSCodium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

echo 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list

sudo apt update && sudo apt install codium

# Instalar clipmenu
echo -e "${GREEN}[+] Instalando Clipmenu...${RESET}"
CLIPMENU_DIR="/opt/clipmenu"
git clone https://github.com/cdown/clipmenu.git "$CLIPMENU_DIR"
cd "$CLIPMENU_DIR"
make clean
make
make install
sudo make install

# Añadir servicio de clipmenu para el usuario
sudo -u "$REAL_USER" systemctl --user daemon-reexec
sudo -u "$REAL_USER" systemctl --user daemon-reload
sudo -u "$REAL_USER" systemctl --user enable --now clipmenud.service
echo -e "${GREEN}[+] Creado el servicio de usuario clipmenud${RESET}"


############
# TERMINAL #
############

# Instalar OhMyZsh
echo -e "${GREEN}[+] Instalando Oh My Zsh para usuario $REAL_USER...${RESET}"

if [ ! -d "/home/$REAL_USER/.oh-my-zsh" ]; then
  sudo -u "$REAL_USER" -H bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
else
  echo -e "${YELLOW}[-] Oh My Zsh ya está instalado para $REAL_USER. Omitiendo.${RESET}"
fi

# Instalar Oh My Zsh si no está ya instalado
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${GREEN}[+] Instalando Oh My Zsh...${RESET}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo -e "${YELLOW}[-] Oh My Zsh ya está instalado. Omitiendo instalación.${RESET}"
fi

# Añadiendo los plugins a la ZSH
echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$USER_ZSHRC"
echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /root/.zshrc
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$USER_ZSHRC"
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /root/.zshrc

# Cambiar el tema robbyrussell.zsh-theme solo para root
echo -e "${GREEN}[+] Personalizando tema robbyrussell para el usuario root...${RESET}"

cat > /root/.oh-my-zsh/themes/robbyrussell.zsh-theme << 'EOF'
PROMPT="%(?:%{$fg_bold[red]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[red]%}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[green]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%})"
EOF


#######################
# i3 ENTORNO COMPLETO #
#######################

# Fuentes
cd /home/$REAL_USER/Auto-i3-Debian13/
sudo -u "$REAL_USER" mkdir Fonts
cd Fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Ubuntu.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/UbuntuMono.zip
unzip Ubuntu.zip
rm -rf *.txt *.md
unzip UbuntuMono.zip
rm -rf *.txt *.md
sudo mkdir -p /usr/local/share/fonts
cp *.ttf /usr/local/share/fonts
cd ..

# Permisos de ejecucion a los .sh
chmod +x config/i3/scripts/*.sh
chmod +x config/i3blocks/scripts/*.sh

# Crear carpetas necesarias en .config
sudo -u "$REAL_USER" mkdir -p /home/$REAL_USER/.config/i3
sudo -u "$REAL_USER" mkdir -p /home/$REAL_USER/.config/i3blocks
sudo -u "$REAL_USER" mkdir -p /home/$REAL_USER/.config/kitty
sudo -u "$REAL_USER" mkdir -p /home/$REAL_USER/.config/picom
sudo -u "$REAL_USER" mkdir -p /home/$REAL_USER/.config/rofi

# Copia de los dot files y la fuente
cp -r Wallpapers/* /home/$REAL_USER/Pictures/
cp -r config/* /home/$REAL_USER/.config/
