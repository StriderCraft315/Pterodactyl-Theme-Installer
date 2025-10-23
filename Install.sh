#!/bin/bash
# Zycron Theme + Cloudflared Installer ⚡
# by StriderCraft315

# ────────────────────────────────────────────────
# COLORS
# ────────────────────────────────────────────────
BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

# ────────────────────────────────────────────────
# ASCII BANNER
# ────────────────────────────────────────────────
clear
echo -e "${BLUE}"
cat <<'EOF'
███████╗██╗   ██╗ ██████╗██████╗  ██████╗ ███╗   ██╗
██╔════╝╚██╗ ██╔╝██╔════╝██╔══██╗██╔═══██╗████╗  ██║
███████╗ ╚████╔╝ ██║     ██████╔╝██║   ██║██╔██╗ ██║
╚════██║  ╚██╔╝  ██║     ██╔══██╗██║   ██║██║╚██╗██║
███████║   ██║   ╚██████╗██║  ██║╚██████╔╝██║ ╚████║
╚══════╝   ╚═╝    ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝\033[93m⚡
EOF
echo -e "${RESET}"
echo -e "${YELLOW}Welcome to the Zycron Theme Installer${RESET}"

# ────────────────────────────────────────────────
# ROOT CHECK
# ────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run this script as root.${RESET}"
    exit 1
fi

# ────────────────────────────────────────────────
# CONFIRMATION
# ────────────────────────────────────────────────
read -rp "$(echo -e "${YELLOW}Proceed with Zycron setup? (y/n): ${RESET}")" confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Setup cancelled.${RESET}"
    exit 0
fi

# ────────────────────────────────────────────────
# SETUP VARIABLES
# ────────────────────────────────────────────────
INSTALL_DIR="/var/www/pterodactyl"
BLUEPRINTS=(
  "https://cdn.discordapp.com/attachments/1426458069176680498/1430381228351029441/resourcealerts.blueprint?ex=68f991d4&is=68f84054&hm=cfc15b0a16b83d2512bb8a9479df01d432b6e78792d03269420ae7dc30ee2221&"
  "https://cdn.discordapp.com/attachments/1426458069176680498/1430381228758138910/simplefooters.blueprint?ex=68f991d4&is=68f84054&hm=83d8ffe4d5e9bb3743000c3420be5b7f154910f692b377a5a0b9523d7e4f2def&"
  "https://cdn.discordapp.com/attachments/1426458069176680498/1430381229059997836/nebula.blueprint?ex=68f991d4&is=68f84054&hm=681a16b28bf64c823b4d070850cfaed42e3c61d645d0e5fdf624cde6acceb4ba&"
  "https://cdn.discordapp.com/attachments/1426458069176680498/1430381229425033216/huxregister.blueprint?ex=68f991d4&is=68f84054&hm=86130fbbd764d1ef42797be92f923083d012a04611c75df59a2ca1a471acc74c&"
)

# ────────────────────────────────────────────────
# CHANGE DIRECTORY
# ────────────────────────────────────────────────
echo -e "${BLUE}Navigating to /var/www/pterodactyl...${RESET}"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || { echo -e "${RED}Failed to enter directory.${RESET}"; exit 1; }

# ────────────────────────────────────────────────
# DOWNLOAD BLUEPRINT FILES
# ────────────────────────────────────────────────
echo -e "${BLUE}Downloading theme blueprints...${RESET}"
for url in "${BLUEPRINTS[@]}"; do
    file=$(basename "${url%%\?*}")
    echo -e "${YELLOW}→ Downloading $file...${RESET}"
    curl -L -o "$file" "$url"
done

# ────────────────────────────────────────────────
# INSTALL BLUEPRINTS
# ────────────────────────────────────────────────
echo -e "${GREEN}Installing downloaded blueprints...${RESET}"
if command -v blueprint >/dev/null 2>&1; then
    blueprint -install *.blueprint
    echo -e "${GREEN}✅ Blueprints installed successfully.${RESET}"
else
    echo -e "${RED}⚠️  Blueprint command not found. Skipping theme installation.${RESET}"
fi

# ────────────────────────────────────────────────
# CLOUDFLARED INSTALL (OFFICIAL METHOD)
# ────────────────────────────────────────────────
echo -e "\n${BLUE}Installing Cloudflared (official method)...${RESET}"

sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

sudo apt-get update -y && sudo apt-get install -y cloudflared

if command -v cloudflared >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Cloudflared installed successfully!${RESET}"
    echo -e "${YELLOW}Version:${RESET} $(cloudflared --version)"
else
    echo -e "${RED}❌ Cloudflared installation failed.${RESET}"
fi

# ────────────────────────────────────────────────
# COMPLETION MESSAGE
# ────────────────────────────────────────────────
echo -e "\n${GREEN}⚡ Zycron Setup Completed Successfully!${RESET}"
echo -e "${BLUE}Theme files and Cloudflared are now installed.${RESET}"
echo -e "${YELLOW}You can now continue with your Cloudflare configuration manually.${RESET}"
