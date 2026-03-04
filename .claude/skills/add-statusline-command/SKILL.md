---
name: add-statusline-command
description: >
  Guide for adding custom command scripts to the ccstatusline configuration.
  Use this skill whenever the user wants to create a new statusline script,
  add a custom command to the statusline, build a new statusline widget,
  or modify how scripts display in ccstatusline. Also use when the user asks
  about statusline colors, script configuration, or how ccstatusline custom
  commands work.
---

# Adding a Custom Command to ccstatusline

This guide covers how to create a new custom command script and wire it into the ccstatusline configuration.

## How Custom Commands Work

ccstatusline executes your script as a child process and displays its stdout as a statusline segment. The key thing to understand: **ccstatusline pipes JSON data to your script via stdin**. This JSON contains context like the current working directory (`cwd`), session info, and more.

Your script **must consume stdin** even if it doesn't need the data — otherwise the pipe breaks and the command fails silently. Two patterns:

```bash
# If you need the context data
INPUT=$(cat)
CWD=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | head -1 | cut -d'"' -f4)

# If you don't need it
cat > /dev/null
```

## Creating the Script

Scripts live in the `scripts/` directory and follow these conventions:

- **Bash only** — no Python, no Node, no external interpreters
- **No jq dependency** — parse JSON with `grep`/`cut` to keep things portable
- **Single line of output** — the script's stdout becomes the segment text
- **Exit 0** — always exit cleanly so ccstatusline doesn't show an error

### Script Template

```bash
#!/bin/bash

# Consume stdin (ccstatusline pipes JSON context)
cat > /dev/null

# Your logic here...

echo "output text"
```

After creating the script, make it executable:

```bash
chmod +x scripts/my-script.sh
```

### Using Dynamic Colors (ANSI Escape Codes)

If your script needs to change its color based on state (e.g., green for OK, red for error), output ANSI escape codes directly:

```bash
RED='\033[31m'
GREEN='\033[32m'
ORANGE='\033[33m'   # yellow/orange
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
RESET='\033[0m'

printf "${GREEN}all good${RESET}"
```

For this to work, the segment config in `settings.json` **must** have `"preserveColors": true`. Without it, ccstatusline strips all ANSI codes from the output. When `preserveColors` is enabled, the powerline theme's foreground color is skipped — your ANSI codes control the text color, while the theme still handles backgrounds.

## Adding the Segment to settings.json

Open `settings.json` and add a new object to one of the arrays inside `lines`. Each array is a row in the statusline.

### Required Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | A unique UUID (generate one or use any unique string) |
| `type` | string | Must be `"custom-command"` |
| `commandPath` | string | Path to script (supports `~` expansion) |

### Optional Fields

| Field | Type | Default | Description |
|---|---|---|---|
| `preserveColors` | boolean | `false` | Pass through ANSI color codes from script output |
| `timeout` | number | `1000` | Max execution time in ms. Increase for network calls |
| `maxWidth` | number | none | Truncate output to this many characters |
| `backgroundColor` | string | theme | Background color (e.g., `"bgCyan"`, `"bgMagenta"`) |

### Example Segment

```json
{
  "id": "unique-uuid-here",
  "type": "custom-command",
  "commandPath": "~/dev/my-claude-statusline/scripts/my-script.sh",
  "preserveColors": true,
  "timeout": 5000
}
```

If passing arguments to the script, include them in `commandPath`:

```json
"commandPath": "~/dev/my-claude-statusline/scripts/my-script.sh 'arg1' 'arg2'"
```

## Testing

Test your script by piping JSON to it manually:

```bash
echo '{}' | bash scripts/my-script.sh
```

To test with realistic context data:

```bash
echo '{"cwd":"/path/to/project"}' | bash scripts/my-script.sh
```

If using environment variables for configuration, set them inline:

```bash
MY_VAR="value" SOME_MODE="test" echo '{}' | bash scripts/my-script.sh
```

## Checklist

After creating a new script:

1. Create the script in `scripts/`
2. `chmod +x scripts/my-script.sh`
3. Add segment to `settings.json` (in the appropriate `lines` array)
4. Set `preserveColors: true` if using ANSI colors
5. Increase `timeout` if the script makes network calls
6. Update `README.md` with a scenario table documenting the script's outputs
7. Test with `echo '{}' | bash scripts/my-script.sh`

## Existing Scripts for Reference

- `scripts/default-scope.sh` — Reads `cwd` from stdin JSON, checks `workspace.jsonc` for Bit scope. Simple file-based lookup pattern.
- `scripts/lane-name.sh` — Reads `cwd` from stdin JSON, parses `.bitmap` for lane info. Shows multi-field extraction from a file.
- `scripts/oref-alert.sh` — Doesn't use stdin context. Uses ANSI colors with `preserveColors`, fetches an external API with curl, and supports a test mode via environment variable. Good reference for network-dependent scripts with dynamic colors.
