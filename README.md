# vnz Claude Plugins

Personal Claude Code plugin marketplace by vinz.

## Installation

### From GitHub
```bash
/plugin marketplace add vnz/cc-plugins-vnz
```

### For local development
```bash
/plugin marketplace add ~/code/vnz/cc-plugins-vnz
```

## Available Plugins

| Plugin | Description |
|--------|-------------|
| `date-context` | Injects current date/time at session start to fix web search year issues |

## Usage

After adding the marketplace:
```bash
/plugin install date-context@cc-plugins-vnz
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
