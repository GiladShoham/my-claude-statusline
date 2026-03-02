#!/bin/bash

# Read the JSON data from stdin (passed by ccstatusline)
INPUT=$(cat)

# Extract cwd from the JSON (no jq dependency)
CWD=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | head -1 | cut -d'"' -f4)

# If no cwd from JSON, fall back to current directory
if [ -z "$CWD" ]; then
  CWD="$(pwd)"
fi

WORKSPACE_FILE="$CWD/workspace.jsonc"

# Check if workspace.jsonc exists
if [ ! -f "$WORKSPACE_FILE" ]; then
  echo "no bit"
  exit 0
fi

# Extract defaultScope directly - no need for comment stripping since
# the key is on its own line and not inside a comment block
SCOPE=$(grep '"defaultScope"' "$WORKSPACE_FILE" | cut -d'"' -f4)

if [ -z "$SCOPE" ]; then
  echo "no scope"
else
  echo "$SCOPE"
fi
