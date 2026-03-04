#!/bin/bash

# Oref Alert statusline script
# Monitors Israel Home Front Command (Pikud HaOref) alerts
# and displays color-coded status for a configured city.
#
# City config (script arg takes priority over env var):
#   Env var:    export OREF_ALERT_CITY="תל אביב - מזרח"
#   Script arg: oref-alert.sh 'חולון'
#
# Test mode (skips API, simulates output):
#   OREF_TEST_MODE=shelter|clear|none

# Consume stdin (ccstatusline pipes JSON context, not needed here)
cat > /dev/null

# ANSI color codes
RED='\033[31m'
GREEN='\033[32m'
ORANGE='\033[33m'
RESET='\033[0m'

# City: script argument takes priority, then env var
CITY="${1:-$OREF_ALERT_CITY}"

if [ -z "$CITY" ]; then
  printf "${ORANGE}oref: no city${RESET}"
  exit 0
fi

# Test mode — return simulated output without hitting the API
if [ -n "$OREF_TEST_MODE" ]; then
  case "$OREF_TEST_MODE" in
    shelter)
      printf "${RED}SHELTER NOW - ${CITY}${RESET}"
      ;;
    clear)
      printf "${GREEN}All clear - ${CITY}${RESET}"
      ;;
    none)
      printf "${GREEN}Safe - ${CITY}${RESET}"
      ;;
    *)
      printf "${ORANGE}unknown test: ${OREF_TEST_MODE}${RESET}"
      ;;
  esac
  exit 0
fi

# Fetch alerts from Oref API
RESPONSE=$(curl -s --max-time 3 \
  -H 'Referer: https://www.oref.org.il/' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36' \
  -H 'X-Requested-With: XMLHttpRequest' \
  'https://www.oref.org.il/WarningMessages/alert/alerts.json' 2>/dev/null)

# Strip UTF-8 BOM the API may return
RESPONSE=$(printf '%s' "$RESPONSE" | LC_ALL=C sed 's/^\xef\xbb\xbf//')

# Empty or whitespace-only response = no active alerts
CLEAN=$(printf '%s' "$RESPONSE" | tr -d '[:space:]')
if [ -z "$CLEAN" ]; then
  printf "${GREEN}Safe - ${CITY}${RESET}"
  exit 0
fi

# Check if our city appears in the response data array
CITY_FOUND=$(printf '%s' "$RESPONSE" | grep -F "\"$CITY\"")

if [ -z "$CITY_FOUND" ]; then
  printf "${GREEN}Safe - ${CITY}${RESET}"
  exit 0
fi

# City found in alert — extract category, title, description
CAT=$(printf '%s' "$RESPONSE" | grep -o '"cat":"[^"]*"' | head -1 | cut -d'"' -f4)
TITLE=$(printf '%s' "$RESPONSE" | grep -o '"title":"[^"]*"' | head -1 | cut -d'"' -f4)
DESC=$(printf '%s' "$RESPONSE" | grep -o '"desc":"[^"]*"' | head -1 | cut -d'"' -f4)

case "$CAT" in
  1)
    printf "${RED}SHELTER NOW${RESET}"
    ;;
  10)
    printf "${GREEN}All clear${RESET}"
    ;;
  *)
    printf "${ORANGE}unknown-${CAT}-${DESC}-${TITLE}${RESET}"
    ;;
esac
