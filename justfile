# justfile for cc-plugins-vnz
# Run `just` to see available recipes
#
# Hook groups (all via prek):
#   fmt      → shfmt (modifies files)
#   lint     → shellcheck, json-validate, script-permissions (read-only)
#   validate → validate-plugins (structure checks)

set quiet  # Don't echo recipe lines

# List available recipes
default:
    just --list

# Install development dependencies (pre-commit hooks)
setup:
    prek install

# Format code (shfmt - modifies files)
fmt:
    prek run shfmt --all-files

# Lint code (shellcheck, json, permissions - read-only)
lint:
    prek run shellcheck --all-files
    prek run json-validate --all-files
    prek run script-permissions --all-files

# Validate plugin structure (version consistency, required files)
validate:
    prek run validate-plugins --all-files

# Run all checks (what CI runs)
all:
    prek run --all-files

# Alias: check = lint (for familiarity)
check: lint
