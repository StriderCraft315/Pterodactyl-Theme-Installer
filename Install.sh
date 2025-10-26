#!/usr/bin/env bash
set -euo pipefail

# ===== Colors =====
BLUE='\033[1;34m'; CYAN='\033[1;36m'; GREEN='\033[1;32m'
YELLOW='\033[1;33m'; RED='\033[1;31m'; RESET='\033[0m'

# ===== Config =====
GITHUB_RAW_BASE="https://raw.githubusercontent.com/StriderCraft315/Pterodactyl-Theme-Installer/main/Assets"
INSTALL_DIR="/var/www/pterodactyl"
BLUEPRINTS=( "playerlisting" "nebula" "resourcealerts" "simplefooters" "votifiertester" )

# ===== Loading bar animation =====
progress_bar() {
  local duration=$1
  local progress=0
  local width=30
  while [ $progress -lt $duration ]; do
    local filled=$((progress * width / duration))
    local empty=$((width - filled))
    printf "\r[${GREEN}%${filled}s${RESET}${BLUE}%${empty}s${RESET}] %d%%" "#" " " $((progress * 100 / duration))
    sleep 0.05
    ((progress++))
  done
  printf "\r[${GREEN}%${width}s${RESET}] 100%%\n" "#" 
}

# ===== Banner =====
clear
echo -e "${BLUE}"
cat <<'EOF'
 ______                          
 |___  /                          
    / /_   _  ___ _ __ ___  _ __  
   / /| | | |/ __| '__/ _ \| '_ \ 
  / /_| |_| | (__| | | (_) | | | |
 /_____\__, |\___|_|  \___/|_| |_|
        __/ |                     
       |___/                      
EOF
echo -e "${CYAN}       Zycron Installer ⚡${RESET}\n"

# ===== Menu =====
echo -e "${YELLOW}1) Install Blueprints${RESET}"
echo -e "${CYAN}2) Install Cloudflared${RESET}"
echo -e "${RED}3) Exit${RESET}\n"
read -rp "Enter choice (1-3): " CHOICE
echo ""

# ===== Helper =====
confirm() {
  read -rp "$(echo -e "${YELLOW}$1 (y/n): ${RESET}")" ans
  [[ "${ans}" =~ ^[Yy]$ ]]
}

# ===== Option 1: Install Blueprints =====
if [[ "$CHOICE" == "1" ]]; then
  confirm "Install all blueprints into ${INSTALL_DIR}?" || exit 0
  mkdir -p "$INSTALL_DIR" || { echo -e "${RED}Failed to access ${INSTALL_DIR}${RESET}"; exit 1; }
  cd "$INSTALL_DIR" || exit 1

  if ! command -v blueprint >/dev/null; then
    echo -e "${RED}Blueprint command not found!${RESET}"
    exit 1
  fi

  echo -e "${CYAN}Starting installation of Zycron Blueprints...${RESET}\n"
  for name in "${BLUEPRINTS[@]}"; do
    file="${name}.blueprint"
    url="${GITHUB_RAW_BASE}/${file}"
    echo -e "${YELLOW}→ Downloading ${file}${RESET}"
    if curl -fsSL -o "${file}" "${url}"; then
      progress_bar 30
      echo -e "${CYAN}→ Installing ${name}${RESET}"
      if blueprint -i "${name}" >/dev/null 2>&1; then
        progress_bar 25
        echo -e "${GREEN}✔ Installed ${name}${RESET}\n"
      else
        echo -e "${RED}❌ Failed to install ${name}${RESET}\n"
      fi
    else
      echo -e "${RED}❌ Download failed for ${file}${RESET}\n"
    fi
  done
  echo -e "${GREEN}✅ All installations completed!${RESET}"
  exit 0
fi

# ===== Option 2: Cloudflared =====
if [[ "$CHOICE" == "2" ]]; then
  confirm "Install Cloudflared (official method)?" || exit 0
  echo -e "${CYAN}Installing Cloudflared...${RESET}"
  sudo mkdir -p --mode=0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
    sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y cloudflared >/dev/null 2>&1 && echo -e "${GREEN}✅ Cloudflared installed successfully!${RESET}" || echo -e "${RED}❌ Installation failed.${RESET}"
  exit 0
fi

# ===== Option 3: Exit =====
if [[ "$CHOICE" == "3" ]]; then
  echo -e "${CYAN}Goodbye from Zycron Installer ⚡${RESET}"
  exit 0
fi

echo -e "${RED}Invalid choice. Exiting.${RESET}"
exit 1
