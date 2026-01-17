# eclint

Automatically enforces `.editorconfig` rules after Claude Code writes or edits files using [eclint](https://github.com/jednano/eclint).

## Features

This plugin installs a **PostToolUse hook** that runs `eclint fix` after every `Write` or `Edit` operation. eclint supports all standard EditorConfig properties:

| Property | Support |
|----------|---------|
| `indent_style` | ✅ Converts tabs ↔ spaces |
| `indent_size` | ✅ Full |
| `tab_width` | ✅ Full |
| `end_of_line` | ✅ LF, CRLF, CR |
| `charset` | ✅ Full |
| `trim_trailing_whitespace` | ✅ Full |
| `insert_final_newline` | ✅ Full |
| `max_line_length` | ✅ Unofficial but supported |

## Prerequisites

eclint must be installed globally:

```bash
npm install -g eclint
```

## Installation

```bash
/plugin install eclint@cc-plugins-vnz
```

## How It Works

1. Claude Code writes or edits a file
2. The PostToolUse hook triggers automatically
3. `eclint fix <file>` runs on the modified file
4. eclint finds the nearest `.editorconfig` and applies all matching rules

## Example .editorconfig

```ini
root = true

[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
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
2. Check eclint is installed: `which eclint`
3. Verify hooks are registered: `/hooks`

### eclint not fixing files?

1. Ensure `.editorconfig` exists in your project or parent directories
2. Test manually: `eclint check <file>` then `eclint fix <file>`
3. Check file matches a section in `.editorconfig`

## Why eclint?

eclint is the only EditorConfig tool that can both **check AND fix** violations. Other tools like `editorconfig-checker` only validate.

| Tool | Check | Fix | Language |
|------|-------|-----|----------|
| eclint | ✅ | ✅ | Node.js |
| editorconfig-checker | ✅ | ❌ | Go |

## License

MIT
