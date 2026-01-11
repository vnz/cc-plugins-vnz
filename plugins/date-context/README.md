# Date Context Plugin

Fixes the "Claude Code date bug" where Claude defaults to older years (2024/2025)
when performing web searches, due to its training data cutoff.

## Problem

Claude's training data has a cutoff around mid-2025. When starting sessions in 2026+,
Claude may default to 2025 assumptions, causing:
- Web searches to use outdated years (e.g., "best practices 2024")
- Incorrect date-sensitive reasoning
- Outdated time-based recommendations

## How it works

A `SessionStart` hook runs at the beginning of each session and injects the current
date/time from the system into Claude's context window. This ensures Claude uses the
correct year for web searches and all date-sensitive operations.

The hook outputs:
- Human-readable date with timezone
- ISO 8601 timestamp
- Explicit year with note about model training cutoff

## Installation

### From GitHub
```bash
/plugin marketplace add vnz/cc-plugins
/plugin install date-context@cc-plugins-vnz
```

### From local development
```bash
/plugin marketplace add ~/code/vnz/cc-plugins
/plugin install date-context@cc-plugins-vnz
```

## Verification

After enabling:
1. Start a new Claude Code session
2. Ask Claude to search for something current (e.g., "latest React 19 features")
3. Check that the web search uses the current year (2026), not 2024/2025

## Credits

Based on the fix described in "The Claude Code Date Bug That's Sabotaging Your Web Searches"
and uses the same `SessionStart` hook pattern as Anthropic's official `explanatory-output-style` plugin.
