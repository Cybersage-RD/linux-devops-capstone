#!/bin/bash

URL="http://127.0.0.1:8090/health.txt"
LOG="$HOME/linux-capstone/logs/health.log"

if curl -fsS "$URL" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') UP" >> "$LOG"
    exit 0
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') DOWN" >> "$LOG"
    exit 1
fi
