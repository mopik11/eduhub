#!/bin/bash
# ==============================================================================
# EduHub - Jednorázové spuštění serveru a Cloudflare tunelu
# ==============================================================================

PORT=3005
LOGFILE="/home/ubuntu/eduhubtunnel.log"
APP_DIR="/home/ubuntu/eduhub"

echo "=================================================="
echo "  🎓 Spouštím EduHub na portu $PORT..."
echo "=================================================="

# 1. Kontrola / spuštění server.js
if ! nc -z localhost $PORT; then
    echo "[*] Server na portu $PORT neběží. Spouštím ve screenu 'eduhub'..."
    screen -S eduhub -X quit 2>/dev/null
    cd "$APP_DIR" || cd "$(dirname "$0")"
    screen -dmS eduhub node server.js $PORT
    sleep 2
else
    echo "[+] Server na portu $PORT již běží."
fi

# 2. Kontrola / spuštění cloudflared tunelu
echo "[*] Spouštím Cloudflare tunel pro http://localhost:$PORT..."
screen -S eduhubtunnel -X quit 2>/dev/null
rm -f "$LOGFILE"
touch "$LOGFILE"

screen -dmS eduhubtunnel bash -c "cloudflared tunnel --url http://localhost:$PORT 2>&1 | tee $LOGFILE"

echo "[*] Čekám na vygenerování veřejné HTTPS adresy (max 25s)..."

CF_URL=""
for i in {1..25}; do
    CF_URL=$(grep -o 'https://[-a-z0-9]*\.trycloudflare\.com' "$LOGFILE" 2>/dev/null | grep -vE "api\.trycloudflare|update\.trycloudflare" | head -n 1)
    if [ -n "$CF_URL" ]; then
        break
    fi
    sleep 1
    echo -n "."
done
echo ""

if [ -n "$CF_URL" ]; then
    echo "=================================================="
    echo "  🎉 ÚSPĚCH! EduHub je online přes Cloudflare!"
    echo ""
    echo "  🌐 Vaše veřejná adresa:"
    echo "     $CF_URL"
    echo ""
    echo "=================================================="
    echo "$CF_URL" > public_tunnel_url.txt
else
    echo "[!] Nepodařilo se automaticky vyčíst URL. Zkontrolujte log:"
    echo "    cat $LOGFILE"
    echo "Nebo zkontrolujte screen:"
    echo "    screen -r eduhubtunnel"
fi
