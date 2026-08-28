#!/bin/bash
# ==============================================================================
# EduHub Server Monitor & Cloudflare Tunnel Snippet
# Přidejte tento blok do vašeho /home/ubuntu/monitor.sh
# ==============================================================================

LOGFILE="/home/ubuntu/monitor.log"
APP_DIR="/home/ubuntu/eduhub"
PORT=3005

echo "=============================================" | tee -a $LOGFILE
echo "==> Kontrola EduHub (Port $PORT)..." | tee -a $LOGFILE
echo "=============================================" | tee -a $LOGFILE

# 1. Kontrola běhu Node.js serveru
if ! nc -z localhost $PORT; then
    echo "   -> [CHYBA] EduHub Server NEBĚŽÍ. Zahajuji start..." | tee -a $LOGFILE

    if screen -list | grep -q "\.eduhub"; then
        screen -S eduhub -X stuff "^C\nnode server.js $PORT\n"
        echo "   -> [AKCE] Odeslán příkaz k restartu do existujícího screenu 'eduhub'." | tee -a $LOGFILE
    else
        cd "$APP_DIR" && screen -dmS eduhub node server.js $PORT
        echo "   -> [AKCE] Vytvořen nový screen 'eduhub'." | tee -a $LOGFILE
    fi
else
    echo "   -> [OK] EduHub Server běží na portu $PORT." | tee -a $LOGFILE
fi

# 2. Kontrola Cloudflare tunelu pro EduHub (Port 3005)
echo "==> Kontroluji Cloudflare tunel pro EduHub..." | tee -a $LOGFILE

if ! pgrep -f "cloudflared tunnel --url http://localhost:$PORT" > /dev/null; then
    echo "   -> [CHYBA] Cloudflare tunel pro EduHub NEBĚŽÍ. Startuji..." | tee -a $LOGFILE

    screen -S eduhubtunnel -X quit 2>/dev/null
    rm -f /home/ubuntu/eduhubtunnel.log
    touch /home/ubuntu/eduhubtunnel.log

    screen -dmS eduhubtunnel bash -c "cloudflared tunnel --url http://localhost:$PORT 2>&1 | tee /home/ubuntu/eduhubtunnel.log"
    echo "   -> [AKCE] Vytvořen nový screen 'eduhubtunnel'. Čekám na URL..." | tee -a $LOGFILE

    EDU_CF_URL=""
    for i in {1..20}; do
        EDU_CF_URL=$(grep -o 'https://[-a-z0-9]*\.trycloudflare\.com' /home/ubuntu/eduhubtunnel.log 2>/dev/null | grep -vE "api\.trycloudflare|update\.trycloudflare" | head -n 1)
        if [ -n "$EDU_CF_URL" ]; then
            break
        fi
        sleep 1
    done

    if [ -n "$EDU_CF_URL" ]; then
        echo "   -> [ÚSPĚCH] EduHub Cloudflare adresa: $EDU_CF_URL" | tee -a $LOGFILE
        echo "$EDU_CF_URL" > /home/ubuntu/eduhub/public_tunnel_url.txt
    else
        echo "   -> [CHYBA] Nepodařilo se vyčíst URL z /home/ubuntu/eduhubtunnel.log." | tee -a $LOGFILE
    fi
else
    CURRENT_CF=$(grep -o 'https://[-a-z0-9]*\.trycloudflare\.com' /home/ubuntu/eduhubtunnel.log 2>/dev/null | grep -vE "api\.trycloudflare|update\.trycloudflare" | head -n 1)
    echo "   -> [OK] Cloudflare tunel pro EduHub běží: $CURRENT_CF" | tee -a $LOGFILE
fi
