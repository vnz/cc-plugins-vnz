# editorconfig

Enforces `.editorconfig` rules after Claude Code writes or edits files. **Only applies whitespace rules** — no code style changes like Prettier.

## Features

This plugin applies these EditorConfig properties:

| Property                   | Support                      |
| -------------------------- | ---------------------------- |
| `indent_style`             | ✅ Converts tabs ↔ spaces    |
| `indent_size`              | ✅ Full                      |
| `tab_width`                | ✅ Full                      |
| `end_of_line`              | ✅ LF, CRLF, CR              |
| `trim_trailing_whitespace` | ✅ Full                      |
| `insert_final_newline`     | ✅ Full                      |
| `charset`                  | ❌ Not implemented           |
| `max_line_length`          | ❌ Not implemented           |

## Prerequisites

The `editorconfig` CLI must be installed:

```bash
# Debian/Ubuntu
apt install editorconfig

# macOS
brew install editorconfig

# Arch Linux
pacman -S editorconfig-core-c
```

## Installation

```bash
/plugin install editorconfig@cc-plugins-vnz
```

## How It Works

1. Claude Code writes or edits a file
2. The PostToolUse hook triggers automatically
3. `editorconfig <file>` reads the applicable rules from `.editorconfig`
4. Shell commands apply the whitespace fixes:
   - `sed` for trailing whitespace and line endings
   - `expand`/`unexpand` for tab ↔ space conversion

## Example .editorconfig

```ini
root = true

[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{js,ts,json,yaml,yml}]
indent_style = space
indent_size = 2

[*.go]
indent_style = tab

[*.md]
trim_trailing_whitespace = false
```

## Troubleshooting

### Hook not running?

1. Verify plugin is enabled: `/plugin` → Installed tab
2. Check editorconfig is installed: `which editorconfig`
3. Verify hooks are registered: `/hooks`

### Rules not being applied?

1. Ensure `.editorconfig` exists in your project or parent directories
2. Test manually: `editorconfig path/to/file` (shows applicable rules)
3. Check file matches a section in `.editorconfig`

## Why not Prettier/eclint?

| Tool         | Scope             | Dependencies   |
| ------------ | ----------------- | -------------- |
| editorconfig | Whitespace only   | C binary       |
| Prettier     | Full code style   | Node.js        |
| eclint       | Whitespace only   | Node.js (unmaintained) |

This plugin uses standard Unix tools (`sed`, `expand`, `unexpand`) after parsing config with the official `editorconfig` CLI — minimal dependencies, no code style changes.

## License

MIT
