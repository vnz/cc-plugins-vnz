#!/usr/bin/env bash
# EditorConfig PostToolUse hook - enforces .editorconfig rules after file edits
# Requires: editorconfig CLI (apt install editorconfig / brew install editorconfig)

set -euo pipefail

# Read file path from Claude Code hook JSON input (stdin)
FILE_PATH=$(jq -r '.tool_input.file_path // empty')

# Exit early if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# Exit if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Check if editorconfig CLI is available
if ! command -v editorconfig &>/dev/null; then
  echo "editorconfig not found. Install with: apt install editorconfig" >&2
  exit 0
fi

# Get EditorConfig properties for this file
# Output format: key=value (one per line)
PROPS=$(editorconfig "$FILE_PATH" 2>/dev/null) || exit 0

# Exit if no properties found (no .editorconfig applies)
[[ -z "$PROPS" ]] && exit 0

# Parse properties into variables
get_prop() {
  echo "$PROPS" | grep -E "^$1=" | cut -d= -f2 | tr -d '[:space:]'
}

INDENT_STYLE=$(get_prop "indent_style")
INDENT_SIZE=$(get_prop "indent_size")
TAB_WIDTH=$(get_prop "tab_width")
END_OF_LINE=$(get_prop "end_of_line")
TRIM_TRAILING=$(get_prop "trim_trailing_whitespace")
INSERT_FINAL_NL=$(get_prop "insert_final_newline")

# Use tab_width as fallback for indent_size
[[ -z "$INDENT_SIZE" && -n "$TAB_WIDTH" ]] && INDENT_SIZE="$TAB_WIDTH"
[[ -z "$TAB_WIDTH" && -n "$INDENT_SIZE" ]] && TAB_WIDTH="$INDENT_SIZE"

# Default indent_size to 4 if indent_style is set but size isn't
[[ -n "$INDENT_STYLE" && -z "$INDENT_SIZE" ]] && INDENT_SIZE="4"

# Track if file was modified
MODIFIED=false

# Create temp file for modifications
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT
cp "$FILE_PATH" "$TEMP_FILE"

# 1. Trim trailing whitespace
if [[ "$TRIM_TRAILING" == "true" ]]; then
  sed -i 's/[[:space:]]*$//' "$TEMP_FILE"
  MODIFIED=true
fi

# 2. Handle end_of_line
case "$END_OF_LINE" in
  lf)
    # Convert CRLF and CR to LF
    sed -i 's/\r$//' "$TEMP_FILE"
    sed -i 's/\r/\n/g' "$TEMP_FILE"
    MODIFIED=true
    ;;
  crlf)
    # First normalize to LF, then convert to CRLF
    sed -i 's/\r$//' "$TEMP_FILE"
    sed -i 's/$/\r/' "$TEMP_FILE"
    MODIFIED=true
    ;;
  cr)
    # Convert to CR only (rare)
    sed -i 's/\r$//' "$TEMP_FILE"
    tr '\n' '\r' <"$TEMP_FILE" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
    MODIFIED=true
    ;;
esac

# 3. Handle indent_style conversion
if [[ -n "$INDENT_STYLE" && -n "$INDENT_SIZE" ]]; then
  case "$INDENT_STYLE" in
    space)
      # Convert tabs to spaces
      if command -v expand &>/dev/null; then
        expand -t "$INDENT_SIZE" "$TEMP_FILE" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
        MODIFIED=true
      fi
      ;;
    tab)
      # Convert leading spaces to tabs
      if command -v unexpand &>/dev/null; then
        unexpand -t "$INDENT_SIZE" --first-only "$TEMP_FILE" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
        MODIFIED=true
      fi
      ;;
  esac
fi

# 4. Insert final newline
if [[ "$INSERT_FINAL_NL" == "true" ]]; then
  # Check if file ends with newline
  if [[ -s "$TEMP_FILE" ]] && [[ "$(tail -c 1 "$TEMP_FILE" | wc -l)" -eq 0 ]]; then
    echo "" >>"$TEMP_FILE"
    MODIFIED=true
  fi
elif [[ "$INSERT_FINAL_NL" == "false" ]]; then
  # Remove trailing newlines (keep one if file has content)
  if [[ -s "$TEMP_FILE" ]]; then
    # Remove all trailing newlines
    printf '%s' "$(cat "$TEMP_FILE")" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
    MODIFIED=true
  fi
fi

# Only copy back if modifications were made
if [[ "$MODIFIED" == "true" ]]; then
  cp "$TEMP_FILE" "$FILE_PATH"
fi

exit 0
