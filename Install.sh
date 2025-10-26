#!/usr/bin/env bash
# ==========================================================
#  ZYCRON INSTALLER ⚡ - Final build (optimized, colored, animated)
#  Options:
#    1) Install Blueprints (auto: all files from assets)
#    2) Install Cloudflared (official commands, no tunnel)
#    3) Exit
# ==========================================================

set -uo pipefail

# -------- Colors ----------
BLUE='\033[1;34m'; CYAN='\033[1;36m'; GREEN='\033[1;32m'
YELLOW='\033[1;33m'; RED='\033[1;31m'; RESET='\033[0m'

# -------- Config ----------
GITHUB_RAW_BASE="https://raw.githubusercontent.com/StriderCraft315/Pterodactyl-Theme-Installer/main/assets"
INSTALL_DIR="/var/www/pterodactyl"

# list of blueprint basenames (no .blueprint)
BLUEPRINTS=( "playerlisting" "nebula" "resourcealerts" "simplefooters" "votifiertester" )

# -------- Spinner ----------
spinner() {
  # usage: spinner <pid> "<text ...>"
  local pid=$1; shift
  local msg="${*:-working...}"
  local delay=0.08
  local spin='|/-\'
  printf "  %s " "$msg"
  while kill -0 "$pid" 2>/dev/null; do
    for c in ${spin}; do
      printf "\b%c" "$c"
      sleep $delay
    done
  done
  printf "\b \n"
}

# -------- Helpers ----------
require_root_for_cloudflared() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Cloudflared install needs sudo/root. You will be prompted for sudo during install.${RESET}"
  fi
}

confirm_prompt() {
  local prompt="${1:-Are you sure? (y/n): }"
  read -rp "$(echo -e "${YELLOW}${prompt}${RESET}")" ans
  [[ "${ans}" =~ ^[Yy]$ ]] || { echo -e "${RED}Cancelled.${RESET}"; return 1; }
  return 0
}

fail_exit() {
  echo -e "${RED}❌ $1${RESET}" >&2
  exit "${2:-1}"
}

# -------- Banner ----------
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
echo -e "${RESET}${CYAN}Welcome to the Zycron Universal Installer${RESET}\n"

# -------- Menu ----------
echo -e "${YELLOW}Select an option:${RESET}"
echo -e "${GREEN}1) Install Pterodactyl Blueprints (all)${RESET}"
echo -e "${CYAN}2) Install Cloudflared (official)${RESET}"
echo -e "${RED}3) Exit${RESET}\n"

read -rp "Enter your choice (1, 2, or 3): " CHOICE
echo ""

# -------- Option 1: Install Blueprints ----------
if [[ "$CHOICE" == "1" ]]; then
  confirm_prompt "Install all blueprints into ${INSTALL_DIR}? (y/n): " || exit 0

  # ensure install dir exists
  if ! mkdir -p "$INSTALL_DIR" 2>/dev/null; then
    fail_exit "Unable to create/access ${INSTALL_DIR}. Check permissions."
  fi

  cd "$INSTALL_DIR" || fail_exit "Failed to cd into ${INSTALL_DIR}."

  echo -e "${CYAN}Starting downloads of .blueprint files to ${INSTALL_DIR}${RESET}"

  for name in "${BLUEPRINTS[@]}"; do
    file="${name}.blueprint"
    url="${GITHUB_RAW_BASE}/${file}"
    echo -e "${YELLOW}→ Downloading ${file} ...${RESET}"
    # run curl in background so spinner can show
    ( curl -fsSL -o "${file}" "${url}" ) &
    pid=$!
    spinner "$pid" "Downloading ${file}"
    wait "$pid" || fail_exit "Download failed for ${file}. Check URL or network."
    echo -e "${GREEN}Downloaded:${RESET} ${file}"
  done

  echo -e "${CYAN}\nAll files downloaded. Installing with blueprint -i <name> ...${RESET}"

  # Install each blueprint (without extension)
  for name in "${BLUEPRINTS[@]}"; do
    echo -e "${YELLOW}→ Installing ${name} ...${RESET}"
    ( blueprint -i "${name}" ) &
    pid=$!
    spinner "$pid" "Installing ${name}"
    wait "$pid"
    if [ "$?" -ne 0 ]; then
      echo -e "${RED}Warning: blueprint -i ${name} returned non-zero exit code.${RESET}"
      # continue to next rather than aborting entirely
    else
      echo -e "${GREEN}Installed:${RESET} ${name}"
    fi
  done

  echo -e "\n${GREEN}✅ All blueprint install attempts finished.${RESET}"
  exit 0
fi

# -------- Option 2: Install Cloudflared ----------
if [[ "$CHOICE" == "2" ]]; then
  confirm_prompt "Proceed to install Cloudflared (official method)? (y/n): " || exit 0

  require_root_for_cloudflared

  echo -e "${CYAN}Installing Cloudflared from official Cloudflare repository...${RESET}"

  # run the exact official commands you provided
  # create keyrings dir
  sudo mkdir -p --mode=0755 /usr/share/keyrings || fail_exit "Failed to create keyrings dir."

  # fetch GPG key into keyring
  sudo curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg \
    || fail_exit "Failed to fetch Cloudflare GPG key."

  # add apt source
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
    sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null \
    || fail_exit "Failed to write cloudflared apt source."

  # update & install
  ( sudo apt-get update -qq ) &
  pid=$!; spinner "$pid" "Updating apt"
  wait "$pid" || fail_exit "apt update failed."

  ( sudo apt-get install -y cloudflared ) &
  pid=$!; spinner "$pid" "Installing cloudflared"
  wait "$pid" || fail_exit "cloudflared install failed."

  if command -v cloudflared >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Cloudflared installed successfully!${RESET}"
    echo -e "${YELLOW}Version:${RESET} $(cloudflared --version 2>/dev/null || echo 'unknown')"
    exit 0
  else
    fail_exit "cloudflared binary not found after install."
  fi
fi

# -------- Option 3: Exit ----------
if [[ "$CHOICE" == "3" ]]; then
  echo -e "${CYAN}Exiting Zycron Installer. Goodbye! ⚡${RESET}"
  exit 0
fi

# -------- Invalid Input ----------
echo -e "${RED}Invalid choice. Exiting.${RESET}"
exit 1
