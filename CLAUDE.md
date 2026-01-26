# cc-plugins-vnz

Personal Claude Code plugin marketplace by vnz.

## Adding a New Plugin

1. Create plugin directory: `plugins/<plugin-name>/`
2. Add required files:
   - `.claude-plugin/plugin.json` - Plugin manifest
   - `README.md` - Documentation
   - Plus any: `commands/`, `agents/`, `skills/`, `hooks/`
3. Register in `.claude-plugin/marketplace.json`
4. Validate: `prek run --all-files`
5. Commit and test: `/plugin install <name>@cc-plugins-vnz`

## Skill Structure (Recommended)

Use the subdirectory format for skills with reference files:

```
skills/
└── <skill-name>/
    ├── SKILL.md              # Main skill (required)
    └── references/           # Optional reference data
        └── <topic>.md
```

This enables progressive disclosure — Claude loads SKILL.md first, then fetches reference files only when needed.

## Development

```bash
# Install pre-commit hooks
prek install

# Run validation manually
prek run --all-files
```

## Pre-commit Hooks

- `json-validate` - Validates all JSON files with jq
- `script-permissions` - Ensures .sh files are executable
