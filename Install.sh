#!/usr/bin/env bash
set -euo pipefail

# ===== Colors =====
BLUE='\033[1;34m'; CYAN='\033[1;36m'; GREEN='\033[1;32m'
YELLOW='\033[1;33m'; RED='\033[1;31m'; RESET='\033[0m'

# ===== Config =====
GITHUB_RAW_BASE="https://raw.githubusercontent.com/StriderCraft315/Pterodactyl-Theme-Installer/main/Assets"
INSTALL_DIR="/var/www/pterodactyl"
BLUEPRINTS=( "playerlisting" "nebula" "resourcealerts" "simplefooters" "votifiertester" "mcplugins" )

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
echo -e "${YELLOW}1) Install Blueprints (all)${RESET}"
echo -e "${CYAN}2) Install Cloudflared${RESET}"
echo -e "${RED}3) Exit${RESET}\n"
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
  confirm "Install all blueprints into ${INSTALL_DIR}?" || exit 0

  mkdir -p "$INSTALL_DIR" || fail_exit "Failed to create/access ${INSTALL_DIR}"
  cd "$INSTALL_DIR" || fail_exit "Failed to cd into ${INSTALL_DIR}"

  echo -e "${CYAN}Step 1/2 — Downloading all blueprint files from GitHub...${RESET}"
  for name in "${BLUEPRINTS[@]}"; do
    file="${name}.blueprint"
    url="${GITHUB_RAW_BASE}/${file}"
    echo -e "${YELLOW}→ Downloading ${file}${RESET}"
    if ! curl -fsSL -o "${file}" "${url}"; then
      echo -e "${RED}❌ Download failed for ${file} — skipping this file.${RESET}"
      rm -f "${file}" 2>/dev/null || true
      continue
    fi
    if [ ! -s "${file}" ]; then
      echo -e "${RED}❌ Downloaded ${file} but file is empty — skipping.${RESET}"
      rm -f "${file}" 2>/dev/null || true
      continue
    fi
    echo -e "${GREEN}✔ Downloaded ${file}${RESET}"
  done

  echo ""
  echo -e "${CYAN}Step 2/2 — Installing downloaded blueprints (using: blueprint -i <name>)${RESET}"

  if ! command -v blueprint >/dev/null 2>&1; then
    fail_exit "'blueprint' command not found. Install Blueprint first and re-run this script."
  fi

  # Build list of successfully downloaded names
  to_install=()
  for name in "${BLUEPRINTS[@]}"; do
    if [ -s "${name}.blueprint" ]; then
      to_install+=( "$name" )
    fi
  done

  if [ "${#to_install[@]}" -eq 0 ]; then
    fail_exit "No blueprint files available to install."
  fi

  total=${#to_install[@]}
  idx=0
  for name in "${to_install[@]}"; do
    ((idx++))
    echo -e "${YELLOW}→ Installing (${idx}/${total}) ${name}${RESET}"
    # show a short progress bar during the install call
    # run blueprint but don't splice its output to keep terminal clean; show success/fail
    if blueprint -i "${name}" >/dev/null 2>&1; then
      progress_bar 25
      echo -e "${GREEN}✔ Installed ${name}${RESET}\n"
    else
      echo -e "${RED}❌ blueprint -i ${name} failed. Check blueprint tool output manually.${RESET}\n"
    fi
  done

  echo -e "${GREEN}✅ All available blueprint install attempts completed.${RESET}"
  exit 0
fi

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
if [[ "$CHOICE" == "3" ]]; then
  echo -e "${CYAN}Exiting Zycron Installer. Goodbye! ⚡${RESET}"
  exit 0
fi

echo -e "${RED}Invalid choice. Exiting.${RESET}"
exit 1
