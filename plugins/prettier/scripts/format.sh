#!/usr/bin/env bash
# Prettier PostToolUse hook - formats files after edits
# Uses: npx prettier (no global install needed)

set -euo pipefail

# Read file path from Claude Code hook JSON input (stdin)
FILE_PATH=$(jq -r '.tool_input.file_path // empty')

# Exit early if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# Exit if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Check if Prettier can format this file by checking for an inferred parser.
# This avoids maintaining a static list of extensions and relies on Prettier's own detection.
PARSER=$(npx --yes prettier --file-info "$FILE_PATH" 2>/dev/null | jq -r '.inferredParser // "null"') || PARSER="null"

if [[ "$PARSER" != "null" ]]; then
  # Format the file in-place using prettier.
  # --write modifies in place, --log-level=error reduces noise.
  # We use `|| true` to ensure the hook doesn't fail even if prettier does (e.g. syntax error),
  # but we allow stderr to pass through to aid in debugging such failures.
  npx --yes prettier --write --log-level=error "$FILE_PATH" || true
fi

exit 0
