#!/usr/bin/env bash
# Zycron Pterodactyl Theme Installer
# Author: StriderCraft315
# Description: Installs Zycron blueprints with a fancy ASCII logo + confirmation.

set -e  # Stop on any error

clear

# ────────────────────────────────────────────────
# Colors
# ────────────────────────────────────────────────
BLUE='\e[34m'
CYAN='\e[96m'
GREEN='\e[92m'
YELLOW='\e[93m'
RED='\e[91m'
RESET='\e[0m'

# ────────────────────────────────────────────────
# Zycron ASCII Banner
# ────────────────────────────────────────────────
echo -e "${BLUE}"
cat <<'EOF'
███████╗██╗   ██╗ ██████╗██████╗  ██████╗ ███╗   ██╗
██╔════╝╚██╗ ██╔╝██╔════╝██╔══██╗██╔═══██╗████╗  ██║
███████╗ ╚████╔╝ ██║     ██████╔╝██║   ██║██╔██╗ ██║
╚════██║  ╚██╔╝  ██║     ██╔══██╗██║   ██║██║╚██╗██║
███████║   ██║   ╚██████╗██║  ██║╚██████╔╝██║ ╚████║
╚══════╝   ╚═╝    ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                              ⚡
EOF
echo -e "${RESET}"
sleep 1

# ────────────────────────────────────────────────
# Menu
# ────────────────────────────────────────────────
echo -e "\n${CYAN}[1]${RESET} Install Setup"
echo -ne "\nEnter your choice: "
read -r choice

if [[ "$choice" == "1" ]]; then
    echo -ne "\nAre you sure you want to install Zycron setup? (y/n): "
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "\n${CYAN}Starting Zycron installation...${RESET}"
        sleep 1

        # ────────────────────────────────────────────────
        # Change Directory
        # ────────────────────────────────────────────────
        if [[ -d "/var/www/pterodactyl" ]]; then
            cd /var/www/pterodactyl
        else
            echo -e "${RED}❌ Directory /var/www/pterodactyl not found.${RESET}"
            exit 1
        fi

        # ────────────────────────────────────────────────
        # Download Blueprints
        # ────────────────────────────────────────────────
        echo -e "\n${BLUE}Downloading Blueprints...${RESET}"
        curl -L -o resourcealerts.blueprint "https://cdn.discordapp.com/attachments/1426458069176680498/1430381228351029441/resourcealerts.blueprint?ex=68f991d4&is=68f84054&hm=cfc15b0a16b83d2512bb8a9479df01d432b6e78792d03269420ae7dc30ee2221&"
        curl -L -o simplefooters.blueprint "https://cdn.discordapp.com/attachments/1426458069176680498/1430381228758138910/simplefooters.blueprint?ex=68f991d4&is=68f84054&hm=83d8ffe4d5e9bb3743000c3420be5b7f154910f692b377a5a0b9523d7e4f2def&"
        curl -L -o nebula.blueprint "https://cdn.discordapp.com/attachments/1426458069176680498/1430381229059997836/nebula.blueprint?ex=68f991d4&is=68f84054&hm=681a16b28bf64c823b4d070850cfaed42e3c61d645d0e5fdf624cde6acceb4ba&"
        curl -L -o huxregister.blueprint "https://cdn.discordapp.com/attachments/1426458069176680498/1430381229425033216/huxregister.blueprint?ex=68f991d4&is=68f84054&hm=86130fbbd764d1ef42797be92f923083d012a04611c75df59a2ca1a471acc74c&"

        # ────────────────────────────────────────────────
        # Install Blueprints
        # ────────────────────────────────────────────────
        echo -e "\n${CYAN}Installing Blueprints...${RESET}"
        if command -v blueprint >/dev/null 2>&1; then
            blueprint -install *.blueprint
        else
            echo -e "${YELLOW}⚠️  Blueprint command not found. Please ensure it's installed.${RESET}"
            exit 1
        fi

        echo -e "\n${GREEN}✅ Zycron installation completed successfully!${RESET}"
    else
        echo -e "\n${YELLOW}Installation canceled by user.${RESET}"
        exit 0
    fi
else
    echo -e "\n${RED}Invalid option. Please select 1.${RESET}"
    exit 1
fi
