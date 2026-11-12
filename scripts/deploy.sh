#!/bin/bash
set -euo pipefail

BASE="/home/rohand/linux-capstone"
SERVICE="rohand-linux-lab.service"
HEALTH_URL="http://127.0.0.1:8090/health.txt"

TMP=$(mktemp -d "$BASE/.deploy.XXXXXX")
BACKUP="$BASE/backups/app-$(date -u +%Y%m%dT%H%M%S)"

cleanup() {
    rm -rf "$TMP"
}
trap cleanup EXIT

echo "Receiving deployment package..."

tar -xzf - -C "$TMP"

test -f "$TMP/app/index.html"
test -f "$TMP/app/health.txt"
grep -qx 'OK' "$TMP/app/health.txt"

echo "Creating backup..."

cp -a "$BASE/app" "$BACKUP"

echo "Installing new application..."

rm -rf "$BASE/app.next"
cp -a "$TMP/app" "$BASE/app.next"

mv "$BASE/app" "$BASE/app.previous"
mv "$BASE/app.next" "$BASE/app"

echo "Restarting $SERVICE..."

sudo -n /usr/bin/systemctl restart "$SERVICE"

sleep 2

if curl -fsS "$HEALTH_URL" | grep -qx 'OK'; then
    echo "Deployment successful."
    rm -rf "$BASE/app.previous"
    exit 0
fi

echo "Health check failed. Rolling back..." >&2

rm -rf "$BASE/app"
mv "$BASE/app.previous" "$BASE/app"

sudo -n /usr/bin/systemctl restart "$SERVICE"

echo "Rollback completed." >&2
exit 1
