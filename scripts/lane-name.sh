#!/bin/bash

# Read the JSON data from stdin (passed by ccstatusline)
INPUT=$(cat)

# Extract cwd from the JSON (no jq dependency)
CWD=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | head -1 | cut -d'"' -f4)

# If no cwd from JSON, fall back to current directory
if [ -z "$CWD" ]; then
  CWD="$(pwd)"
fi

BITMAP_FILE="$CWD/.bitmap"

# Check if .bitmap exists
if [ ! -f "$BITMAP_FILE" ]; then
  echo "no bit"
  exit 0
fi

# _bit_lane is always near the end of .bitmap - only read the tail
LANE_BLOCK=$(tail -10 "$BITMAP_FILE" | grep -A4 '"_bit_lane"')

if [ -z "$LANE_BLOCK" ]; then
  echo "main"
else
  SCOPE=$(echo "$LANE_BLOCK" | grep '"scope"' | cut -d'"' -f4)
  NAME=$(echo "$LANE_BLOCK" | grep '"name"' | cut -d'"' -f4)
  echo "$SCOPE/$NAME"
fi
