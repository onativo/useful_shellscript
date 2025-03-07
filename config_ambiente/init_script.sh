#!/bin/bash

set -e  # Para encerrar o script em caso de erro

echo "Atualizando pacotes e repositórios..."
sudo apt update && sudo apt upgrade -y

echo "Instalando ferramentas essenciais..."
sudo apt install -y \
    curl \
    git \
    gnupg \
    gpg-agent \
    gpg \
    grep \
    gzip \
    net-tools \
    nmap \
    openssl \
    unzip \
    wget \
    zip \
    vim \
    zsh \
    nala

echo "Instalando pacotes de desenvolvimento..."
sudo apt install -y \
    g++-12 \
    gcc-12 \
    python3-nautilus \
    python3-pip \
    python3-venv \
    python3.10-venv \
    yamllint

echo "Instalando pacotes para multimídia e utilitários..."
sudo apt install -y \
    flameshot \
    libreoffice \
    vlc \
    kitty \
    mousetweaks \
    diodon \
    pulseaudio \
    pulseaudio-module-bluetooth \
    gsettings-ubuntu-schemas

echo "Instalando PostgreSQL Client..."
sudo apt install -y postgresql-client-common postgresql-client

echo "Instalando Redis..."
sudo apt install -y redis

echo "Instalando Google Chrome..."
wget -qO- https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update && sudo apt install -y google-chrome-stable

echo "Instalando Microsoft Edge..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/microsoft-edge-keyring.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
sudo apt update && sudo apt install -y microsoft-edge-stable

echo "Instalando Brave Browser..."
sudo apt install -y curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update && sudo apt install -y brave-browser

echo "Instalando DBeaver..."
wget -O- https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/dbeaver-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/dbeaver-keyring.gpg] https://dbeaver.io/debs/dbeaver-ce/ stable main" | sudo tee /etc/apt/sources.list.d/dbeaver.list
sudo apt update && sudo apt install -y dbeaver-ce

echo "Instalando FortiClient VPN..."
wget -O forticlient.deb "https://repo.fortinet.com/repo/forticlient/7.0/debian/forticlient_vpn_7.0.7.0246_amd64.deb"
sudo apt install -y ./forticlient.deb
rm forticlient.deb

echo "Instalando OpenVPN..."
sudo apt install -y openvpn3

echo "Instalando Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

echo "Instalando TeamViewer..."
wget -O teamviewer.deb "https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb"
sudo apt install -y ./teamviewer.deb
rm teamviewer.deb

echo "Instalando MongoDB Mongosh..."
wget -qO- https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/mongodb-keyring.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update && sudo apt install -y mongodb-mongosh

echo "Instalando Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install -y code

echo "Instalando temas Yaru..."
sudo apt install -y \
    yaru-theme-gnome-shell \
    yaru-theme-gtk \
    yaru-theme-icon \
    yaru-theme-sound

echo "Definindo Zsh como shell padrão..."
chsh -s $(which zsh)

echo "Finalizado! Só falta reiniciar o sistema para aplicar todas as mudanças."
