#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo bash install.sh"
    exit 1
fi

clear

cat <<'BANNER'
#
#
#                            ██
#       ▒██▒                 ██
#       ▓██▓                 ██
#       ████
#       ████    ██░████    ████     ██▓█▒██▒   ░████▒
#      ▒█▓▓█▒   ███████▓   ████     ████████  ░██████▒
#      ▓█▒▒█▓   ███  ▒██     ██     ██░██░██  ██▒  ▒██
#      ██  ██   ██    ██     ██     ██ ██ ██  ████████
#      ██████   ██    ██     ██     ██ ██ ██  ████████
#     ░██████░  ██    ██     ██     ██ ██ ██  ██
#     ▒██  ██▒  ██    ██     ██     ██ ██ ██  ███░  ▒█
#     ███  ███  ██    ██  ████████  ██ ██ ██  ░███████
#     ██▒  ▒██  ██    ██  ████████  ██ ██ ██   ░█████▒
#
#
#
#
BANNER

echo "=================================================="
echo "           ANIME VPS HOSTING BOT V8"
echo "             INCUS / LXD / LXC"
echo "=================================================="
echo ""

BOT_DIR="/root/Vps-Deployer-Bot"
REPO="https://github.com/AnimePlays/Vps-Deployer-Bot.git"

echo "[1/7] Updating system..."
apt update
apt install -y python3 python3-pip python3-venv git curl snapd

echo ""
echo "Select Container Runtime:"
echo "1) Incus"
echo "2) LXD"
read -rp "Choose (1-2): " OPTION

case "$OPTION" in
    1)
        apt install -y incus
        ;;
    2)
        snap install lxd
        ;;
    *)
        echo "Invalid option!"
        exit 1
        ;;
esac

echo "[2/7] Cloning repository..."

if [[ -d "$BOT_DIR/.git" ]]; then
    git -C "$BOT_DIR" pull
else
    if [[ -e "$BOT_DIR" ]]; then
        echo "ERROR: $BOT_DIR exists but is not a Git repository."
        exit 1
    fi
    git clone "$REPO" "$BOT_DIR"
fi

cd "$BOT_DIR"

if [[ ! -f bot.py ]]; then
    echo "ERROR: bot.py not found in repository!"
    exit 1
fi

echo "[3/7] Creating Python environment..."
python3 -m venv venv

echo "[4/7] Installing dependencies..."
./venv/bin/pip install --upgrade pip
./venv/bin/pip install discord.py python-dotenv PyNaCl davey

echo "[5/7] Configuring environment..."
touch .env
echo "Configure your bot token and required settings:"
nano .env

echo "[6/7] Creating systemd service..."

cat > /etc/systemd/system/anime-bot.service <<EOF
[Unit]
Description=Anime VPS Hosting Bot V8
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$BOT_DIR
ExecStart=$BOT_DIR/venv/bin/python $BOT_DIR/bot.py
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

echo "[7/7] Starting bot..."
systemctl daemon-reload
systemctl enable anime-bot
systemctl restart anime-bot

echo ""
echo "=================================================="
echo "       ANIME VPS HOSTING BOT V8 INSTALLED!"
echo "=================================================="
echo ""
echo "Start:   systemctl start anime-bot"
echo "Stop:    systemctl stop anime-bot"
echo "Restart: systemctl restart anime-bot"
echo "Status:  systemctl status anime-bot"
echo "Logs:    journalctl -u anime-bot -f"
echo ""
echo "=================================================="
echo "              ENJOY ANIME VPS!"
echo "=================================================="

