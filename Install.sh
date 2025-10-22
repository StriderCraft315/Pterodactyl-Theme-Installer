#!/bin/bash
clear

# ────────────────────────────────────────────────
# Fancy Zycron ASCII Logo (Blue Gradient + Bolt)
# ────────────────────────────────────────────────
echo -e "\e[34m"
cat <<'EOF'
███████╗██╗   ██╗ ██████╗██████╗  ██████╗ ███╗   ██╗
██╔════╝╚██╗ ██╔╝██╔════╝██╔══██╗██╔═══██╗████╗  ██║
███████╗ ╚████╔╝ ██║     ██████╔╝██║   ██║██╔██╗ ██║
╚════██║  ╚██╔╝  ██║     ██╔══██╗██║   ██║██║╚██╗██║
███████║   ██║   ╚██████╗██║  ██║╚██████╔╝██║ ╚████║
╚══════╝   ╚═╝    ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                              ⚡
EOF
echo -e "\e[0m"
sleep 1

# ────────────────────────────────────────────────
# Menu
# ────────────────────────────────────────────────
echo -e "\n\e[94m[1]\e[0m Install Setup"
echo -ne "\nEnter your choice: "
read -r choice

if [[ "$choice" == "1" ]]; then
    echo -ne "\nAre you sure you want to install setup? (y/n): "
    read -r confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "\n\e[96mStarting Zycron installation...\e[0m"
        sleep 1
        cd /var/www/pterodactyl || { echo "❌ Directory not found"; exit 1; }

        echo -e "\n\e[94mDownloading Blueprints...\e[0m"
        curl -L -o resourcealerts.blueprint "https://cdn.discordapp.com/attachments/1426458069176680498/1430381228351029441/resourcealerts.blueprint?ex=68f991d4&is=68f84054&hm=cfc15b0a16b83d2512bb8a9479df01d432b6e78792d03269420ae7dc30ee2221&"
        curl -L -o simplefooters.blueprint "https://cdn.discordapp.com/attachments/1426458069176680498/1430381228758138910/simplefooters.blueprint?ex=68f991d4&is=68f84054&hm=83d8ffe4d5e9bb3743000c3420be5b7f154910f692b377a5a0b9523d7e4f2def&"
        curl -L -o nebula.blueprint "https://cdn.discordapp.com/attachments/1426458069176680498/1430381229059997836/nebula.blueprint?ex=68f991d4&is=68f84054&hm=681a16b28bf64c823b4d070850cfaed42e3c61d645d0e5fdf624cde6acceb4ba&"
        curl -L -o huxregister.blueprint "https://cdn.discordapp.com/attachments/1426458069176680498/1430381229425033216/huxregister.blueprint?ex=68f991d4&is=68f84054&hm=86130fbbd764d1ef42797be92f923083d012a04611c75df59a2ca1a471acc74c&"

        echo -e "\n\e[94mInstalling Blueprints...\e[0m"
        blueprint -install *.blueprint

        echo -e "\n\e[92m✅ Zycron installation completed successfully!\e[0m"
    else
        echo -e "\n\e[93mInstallation canceled.\e[0m"
    fi
else
    echo -e "\n\e[91mInvalid option.\e[0m"
fi
