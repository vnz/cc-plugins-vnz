#!/usr/bin/env bash
set -euo pipefail

# Get current date/time info (portable across GNU and BSD date)
HUMAN_DATE=$(date +"%A, %Y-%m-%d %H:%M:%S %Z")
ISO_DATE=$(date +"%Y-%m-%dT%H:%M:%S%z")
YEAR=$(date +%Y)

# Output JSON with additionalContext (same pattern as explanatory-output-style)
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "[DATE CONTEXT] ${HUMAN_DATE} | ISO: ${ISO_DATE} | Year: ${YEAR} (model cutoff ~mid-2025). Use ${YEAR} for searches."
  }
}
EOF
