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

# Parse properties into variables efficiently (single pass)
INDENT_STYLE="" INDENT_SIZE="" TAB_WIDTH=""
END_OF_LINE="" TRIM_TRAILING="" INSERT_FINAL_NL=""

while IFS='=' read -r key value; do
  value=${value//[[:space:]]/}
  case "$key" in
    indent_style) INDENT_STYLE=$value ;;
    indent_size) INDENT_SIZE=$value ;;
    tab_width) TAB_WIDTH=$value ;;
    end_of_line) END_OF_LINE=$value ;;
    trim_trailing_whitespace) TRIM_TRAILING=$value ;;
    insert_final_newline) INSERT_FINAL_NL=$value ;;
  esac
done <<<"$PROPS"

# Use tab_width as fallback for indent_size
[[ -z "$INDENT_SIZE" && -n "$TAB_WIDTH" ]] && INDENT_SIZE="$TAB_WIDTH"
[[ -z "$TAB_WIDTH" && -n "$INDENT_SIZE" ]] && TAB_WIDTH="$INDENT_SIZE"

# Default indent_size to 4 if indent_style is set but size isn't
[[ -n "$INDENT_STYLE" && -z "$INDENT_SIZE" ]] && INDENT_SIZE="4"

# Create temp file for modifications
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE" "$TEMP_FILE.tmp"' EXIT
cp "$FILE_PATH" "$TEMP_FILE"

# Track if file was modified
MODIFIED=false

# 1. Trim trailing whitespace (portable: use temp file instead of sed -i)
if [[ "$TRIM_TRAILING" == "true" ]]; then
  sed 's/[[:space:]]*$//' "$TEMP_FILE" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
  MODIFIED=true
fi

# 2. Handle end_of_line (only LF supported - safest option)
# CRLF/CR conversion is complex and error-prone, so we only normalize CRLF→LF
if [[ "$END_OF_LINE" == "lf" ]]; then
  # Remove carriage returns at end of lines (CRLF→LF)
  # This is safe and won't corrupt files with \r in string literals
  sed 's/\r$//' "$TEMP_FILE" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
  MODIFIED=true
fi

# 3. Handle indent_style conversion
if [[ -n "$INDENT_STYLE" && -n "$INDENT_SIZE" ]]; then
  case "$INDENT_STYLE" in
    space)
      # Convert leading tabs to spaces using --initial (only leading whitespace)
      if command -v expand &>/dev/null; then
        # GNU expand has --initial, BSD expand has -i
        if expand --help 2>&1 | grep -q -- '--initial'; then
          expand --initial -t "$INDENT_SIZE" "$TEMP_FILE" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
        else
          # Fallback: BSD expand with -i flag
          expand -i -t "$INDENT_SIZE" "$TEMP_FILE" >"$TEMP_FILE.tmp" 2>/dev/null && mv "$TEMP_FILE.tmp" "$TEMP_FILE" || true
        fi
        MODIFIED=true
      fi
      ;;
    tab)
      # Convert leading spaces to tabs
      if command -v unexpand &>/dev/null; then
        # GNU unexpand has --first-only, BSD has -a (opposite meaning)
        if unexpand --help 2>&1 | grep -q -- '--first-only'; then
          unexpand --first-only -t "$INDENT_SIZE" "$TEMP_FILE" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
        else
          # BSD unexpand only converts leading spaces by default
          unexpand -t "$INDENT_SIZE" "$TEMP_FILE" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
        fi
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
  # Remove trailing newlines
  if [[ -s "$TEMP_FILE" ]]; then
    printf '%s' "$(cat "$TEMP_FILE")" >"$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
    MODIFIED=true
  fi
fi

# Only copy back if modifications were made
if [[ "$MODIFIED" == "true" ]]; then
  cp "$TEMP_FILE" "$FILE_PATH"
fi

exit 0
