#!/bin/bash
# ==============================================================================
# EduHub Server Monitor & Cloudflare Quick Tunnel Snippet
# Add this block to your /home/ubuntu/monitor.sh
# ==============================================================================

LOGFILE="/home/ubuntu/monitor.log"
APP_DIR="/home/ubuntu/eduhub"
PORT=3000

echo "==> Kontroluji EduHub Server (Port $PORT)..." | tee -a $LOGFILE

if ! nc -z localhost $PORT; then
    echo "   -> [CHYBA] EduHub Server NEBĚŽÍ. Zahajuji start..." | tee -a $LOGFILE

    if screen -list | grep -q "\.eduhub"; then
        screen -S eduhub -X stuff "^C\nnode server.js\n"
        echo "   -> [AKCE] Odeslán příkaz k restartu do existujícího screenu 'eduhub'." | tee -a $LOGFILE
    else
        cd "$APP_DIR" && screen -dmS eduhub node server.js
        echo "   -> [AKCE] Vytvořen nový screen 'eduhub'." | tee -a $LOGFILE
    fi
else
    echo "   -> [OK] EduHub Server běží na portu $PORT." | tee -a $LOGFILE
fi

# Kontrola Cloudflare tunelu pro EduHub
if ! pgrep -f "cloudflared tunnel --url http://localhost:$PORT" > /dev/null; then
    echo "   -> [CHYBA] Cloudflare tunel pro EduHub neběží. Startuji..." | tee -a $LOGFILE
    screen -dmS eduhubtunnel bash -c "cloudflared tunnel --url http://localhost:$PORT 2>&1 | tee /home/ubuntu/eduhubtunnel.log"
    echo "   -> [OK] Cloudflare tunel spuštěn ve screenu 'eduhubtunnel'." | tee -a $LOGFILE
fi
