#!/usr/bin/env bash
set -euo pipefail

# ===== Colors =====
BLUE='\033[1;34m'; CYAN='\033[1;36m'; GREEN='\033[1;32m'
YELLOW='\033[1;33m'; RED='\033[1;31m'; RESET='\033[0m'


# ===== Loading bar animation =====
progress_bar() {
  local duration=$1
  local width=30
  for ((i=0;i<duration;i++)); do
    local filled=$(( (i*width)/duration ))
    local empty=$(( width-filled ))
    printf "\r["
    printf "%*s" "$filled" '' | tr ' ' '#'
    printf "%*s" "$empty" ''
    printf "] %3d%%" $(( i*100/duration ))
    sleep 0.03
  done
  printf "\r["
  printf "%*s" "$width" '' | tr ' ' '#'
  printf "] 100%%\n"
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
echo -e "${YELLOW}1) Vm Tool${RESET}"
echo -e "${CYAN}2) Install Cloudflared${RESET}"
echo -e "${YELLOW}3) Configure Pterodactyl Wings${RESET}"
echo -e "${RED}0) Exit${RESET}\n"
read -rp "Enter choice (1-3): " CHOICE
echo ""

confirm() {
  read -rp "$(echo -e "${YELLOW}$1 (y/n): ${RESET}")" ans
  [[ "${ans}" =~ ^[Yy]$ ]]
}

fail_exit() {
  echo -e "${RED}❌ $1${RESET}"
  exit 1
}

# ===== Option 1: download ALL, then install ALL =====
if [[ "$CHOICE" == "1" ]]; then
  bash <(curl -s https://raw.githubusercontent.com/StriderCraft315/Codes/refs/heads/main/srv/vm/vps.sh)

# ===== Option 2: Cloudflared installer (official commands only) =====
if [[ "$CHOICE" == "2" ]]; then
  confirm "Install Cloudflared (official method)?" || exit 0
  echo -e "${CYAN}Installing Cloudflared...${RESET}"
  sudo mkdir -p --mode=0755 /usr/share/keyrings
  sudo curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
    sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y cloudflared >/dev/null 2>&1 && echo -e "${GREEN}✅ Cloudflared installed successfully!${RESET}" || echo -e "${RED}❌ Cloudflared installation failed.${RESET}"
  exit 0
fi

# ===== Option 3: Exit =====
if [[ "$CHOICE" == "1" ]]; then
bash <(curl -s https://raw.githubusercontent.com/StriderCraft315/Codes/refs/heads/main/srv/wings/auto1.sh)

if [[ "$CHOICE" == "0" ]]; then
  echo -e "${CYAN}Exiting Zycron Installer. Goodbye! ⚡${RESET}"
  exit 0
fi

echo -e "${RED}Invalid choice. Exiting.${RESET}"
exit 1
