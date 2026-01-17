# prettier

Auto-formats files after Claude Code writes or edits them using [Prettier](https://prettier.io/) — the opinionated code formatter.

## Features

- **EditorConfig support**: Prettier automatically reads `.editorconfig` for `indent_style`, `tab_width`, and `end_of_line`
- **Zero config**: Works out of the box with Prettier's defaults, or uses your existing `.prettierrc`
- **No global install**: Uses `npx prettier` so Prettier doesn't need to be globally installed

### Supported File Types

| Category              | Extensions                                                   |
| --------------------- | ------------------------------------------------------------ |
| JavaScript/TypeScript | `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `.mts`, `.cts` |
| JSON                  | `.json`, `.json5`, `.jsonc`                                  |
| CSS                   | `.css`, `.scss`, `.sass`, `.less`                            |
| HTML/Templates        | `.html`, `.htm`, `.vue`, `.svelte`, `.astro`                 |
| Markdown              | `.md`, `.mdx`, `.markdown`                                   |
| Data formats          | `.yaml`, `.yml`, `.graphql`, `.gql`                          |

## Prerequisites

Node.js must be installed (`npx` comes with npm).

## Installation

```bash
/plugin install prettier@cc-plugins-vnz
```

## How It Works

1. Claude Code writes or edits a file
2. The PostToolUse hook triggers automatically
3. `npx prettier --write <file>` formats the file in-place
4. Prettier uses your `.prettierrc` and/or `.editorconfig` settings

## Configuration

### Using .prettierrc

Create a `.prettierrc` in your project root:

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```

### Using .editorconfig

Prettier automatically respects these EditorConfig properties:

```ini
[*]
indent_style = space
indent_size = 2
end_of_line = lf
```

## Troubleshooting

### Hook not running?

1. Verify plugin is enabled: `/plugin` → Installed tab
2. Verify hooks are registered: `/hooks`

### Files not being formatted?

1. Check if the file extension is supported (see table above)
2. Test manually: `npx prettier --write path/to/file.js`
3. Check for Prettier errors: `npx prettier --check path/to/file.js`

## License

MIT
