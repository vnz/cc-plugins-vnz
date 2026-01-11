# justfile for cc-plugins-vnz
# Run `just` to see available recipes

set quiet  # Don't echo recipe lines

# List available recipes
default:
    just --list

# Install development dependencies (pre-commit hooks)
setup:
    prek install

# Run all pre-commit hooks
lint:
    prek run --all-files

# Validate plugin structure (version consistency, required files)
validate:
    ./scripts/validate-plugins.sh

# Format shell scripts with shfmt
fmt:
    shfmt -i 2 -ci -w plugins/**/*.sh

# Check shell scripts without modifying (lint only)
check:
    shellcheck plugins/**/*.sh

# Run all checks (lint + validate)
all: lint validate
