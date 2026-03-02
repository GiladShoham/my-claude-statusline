# my-claude-statusline

My custom [ccstatusline](https://github.com/sirmalloc/ccstatusline) configuration and scripts for [Bit](https://bit.dev) workspaces.

## Setup

1. Install ccstatusline following the [installation instructions](https://github.com/sirmalloc/ccstatusline#-quick-start)
2. Clone this repo to `~/dev/my-claude-statusline`
3. Symlink the settings file:
   ```bash
   ln -sf ~/dev/my-claude-statusline/settings.json ~/.config/ccstatusline/settings.json
   ```

## Scripts

### `scripts/default-scope.sh`

Displays the Bit workspace default scope from `workspace.jsonc`.

| Scenario | Output |
|---|---|
| Bit workspace | The `defaultScope` value (e.g. `my-scope`) |
| Bit workspace without scope | `no scope` |
| Not a Bit workspace | `no bit` |

### `scripts/lane-name.sh`

Displays the current Bit lane name from `.bitmap`.

| Scenario | Output |
|---|---|
| On a lane | `scope/lane-name` (e.g. `my-org.my-scope/feature-lane`) |
| On main (no lane) | `main` |
| Not a Bit workspace | `no bit` |

## Configuration

`settings.json` is the ccstatusline configuration file, symlinked from `~/.config/ccstatusline/settings.json`. Any changes made via the ccstatusline TUI are automatically reflected here.
