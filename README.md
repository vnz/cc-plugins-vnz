# vnz Claude Plugins

![CI](https://github.com/vnz/cc-plugins/actions/workflows/ci.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

Personal Claude Code plugin marketplace by vnz.

## Installation

### From GitHub
```bash
/plugin marketplace add vnz/cc-plugins
```

### For local development
```bash
/plugin marketplace add ~/code/vnz/cc-plugins
```

## Available Plugins

| Plugin | Description |
|--------|-------------|
| `date-context` | Injects current date/time at session start to fix web search year issues |
| `terraform-ls` | Terraform language server for code intelligence (go-to-definition, hover, diagnostics) |

## Usage

After adding the marketplace, install any plugin:
```bash
/plugin install date-context@cc-plugins-vnz
/plugin install terraform-ls@cc-plugins-vnz
```

## Development

Requires [just](https://github.com/casey/just) command runner.

```bash
# Install pre-commit hooks
just setup

# Run all linters
just lint

# Format shell scripts
just fmt

# Run all checks
just all
```

## License

MIT
