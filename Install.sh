#!/bin/bash
# ==========================================================
#  ZYCRON INSTALLER ⚡ - Optimized universal setup script
#  Options: 1) Install Pterodactyl Themes  2) Install Cloudflared
# ==========================================================

# --- Colors ---
blue='\033[1;34m'; cyan='\033[1;36m'; green='\033[1;32m'; red='\033[1;31m'; reset='\033[0m'

clear
echo -e "${blue}"
cat << "EOF"
 ______                          
 |___  /                          
    / /_   _  ___ _ __ ___  _ __  
   / /| | | |/ __| '__/ _ \| '_ \ 
  / /_| |_| | (__| | | (_) | | | |
 /_____\__, |\___|_|  \___/|_| |_|
        __/ |                     
       |___/                      
EOF
echo -e "${reset}${cyan}Welcome to the Zycron Universal Installer${reset}"
echo ""
echo "1) Install Pterodactyl Themes"
echo "2) Install Cloudflared"
echo ""

read -rp "Enter your choice (1 or 2): " choice
echo ""

# --- Helper: Confirm before running ---
confirm() {
    read -rp "Are you sure? (y/n): " c
    [[ "$c" =~ ^[Yy]$ ]] || { echo -e "${red}❌ Cancelled.${reset}"; exit 0; }
}

# --- Option 1: Install Pterodactyl Themes ---
if [[ "$choice" == "1" ]]; then
    confirm
    echo -e "${green}Installing Pterodactyl Themes...${reset}"

    cd /var/www/pterodactyl 2>/dev/null || { echo -e "${red}❌ Directory not found: /var/www/pterodactyl${reset}"; exit 1; }

    urls=(
        "https://cdn.discordapp.com/attachments/1426458069176680498/1430381228351029441/resourcealerts.blueprint?ex=68f991d4&is=68f84054&hm=cfc15b0a16b83d2512bb8a9479df01d432b6e78792d03269420ae7dc30ee2221&"
        "https://cdn.discordapp.com/attachments/1426458069176680498/1430381228758138910/simplefooters.blueprint?ex=68f991d4&is=68f84054&hm=83d8ffe4d5e9bb3743000c3420be5b7f154910f692b377a5a0b9523d7e4f2def&"
        "https://cdn.discordapp.com/attachments/1426458069176680498/1430381229059997836/nebula.blueprint?ex=68f991d4&is=68f84054&hm=681a16b28bf64c823b4d070850cfaed42e3c61d645d0e5fdf624cde6acceb4ba&"
        "https://cdn.discordapp.com/attachments/1426458069176680498/1430381229425033216/huxregister.blueprint?ex=68f991d4&is=68f84054&hm=86130fbbd764d1ef42797be92f923083d012a04611c75df59a2ca1a471acc74c&"
    )

    echo -e "${cyan}↓ Downloading blueprints...${reset}"
    for url in "${urls[@]}"; do
        curl -s -O "$url" || { echo -e "${red}Failed to download $url${reset}"; exit 1; }
    done

    echo -e "${cyan}Installing themes using Blueprint...${reset}"
    blueprint -install *.blueprint && echo -e "${green}✅ Pterodactyl Themes installed successfully!${reset}"
    exit 0
fi

# --- Option 2: Install Cloudflared ---
if [[ "$choice" == "2" ]]; then
    confirm
    echo -e "${green}Installing Cloudflared...${reset}"

    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
        sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
    sudo apt-get update -qq && sudo apt-get install -y cloudflared >/dev/null

    echo -e "${green}✅ Cloudflared installed successfully!${reset}"
    exit 0
fi

# --- Invalid Input ---
echo -e "${red}Invalid choice. Exiting.${reset}"
exit 1
