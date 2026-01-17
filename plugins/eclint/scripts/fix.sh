#!/usr/bin/env bash
# eclint PostToolUse hook - fixes EditorConfig violations after file edits
# Requires: npm install -g eclint

set -euo pipefail

# Read JSON input from Claude Code hook
INPUT=$(cat)

# Extract file path from hook input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit early if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# Exit if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Check if eclint is available
if ! command -v eclint &>/dev/null; then
  echo "eclint not found. Install with: npm install -g eclint" >&2
  exit 0
fi

# Run eclint fix on the file
# eclint will automatically find and use .editorconfig
if eclint fix "$FILE_PATH" 2>/dev/null; then
  # eclint doesn't output anything on success, so we add our own message
  # Only show message if file was actually modified (eclint exits 0 either way)
  :
fi

exit 0
