---
name: dependabot
description: This skill should be used when the user asks to "check dependencies", "find outdated packages", "scan for updates", "use dependabot", "run dependabot", "check for security updates", "what needs updating", or requests dependency scanning for specific ecosystems like npm, terraform, or github-actions. Supports scanning all ecosystems or specific ones with "use dependabot for <ecosystem>".
---

# Dependabot Update Skill

Scan for dependency updates using the official Dependabot CLI and optionally create PRs for found updates.

**Reference files:**
- `references/ecosystems.md` - Complete list of supported ecosystems with aliases and detection methods

## 1. Prerequisites Check

Before running, verify the required tools are installed:

```bash
# Check if dependabot CLI is installed
command -v dependabot || echo "NOT_FOUND"

# Check if gh CLI is installed (needed for authentication)
command -v gh || echo "NOT_FOUND"
```

**If dependabot CLI is not found:**
- Inform the user: "The Dependabot CLI is not installed."
- Provide installation link: https://github.com/dependabot/cli
- Stop execution until the CLI is available.

**If gh CLI is not found:**
- Inform the user: "The GitHub CLI (gh) is needed for authentication."
- Suggest installation via their package manager.

## 2. Parse User Intent

Analyze the user's trigger phrase:

- **"use dependabot"** → Scan ALL detected ecosystems
- **"use dependabot for terraform"** → Scan only `terraform` ecosystem
- **"use dependabot for npm"** → Scan only `npm_and_yarn` ecosystem
- **"use dependabot for github-actions"** or **"use dependabot for actions"** → Scan only `github_actions` ecosystem

For the complete ecosystem alias mapping and detection methods, see `references/ecosystems.md`.

## 3. Ecosystem Auto-Detection

If scanning all ecosystems, detect which are present using file existence checks. See `references/ecosystems.md` for the full detection table.

Report detected ecosystems to the user before proceeding:
> "Detected ecosystems: npm_and_yarn, github_actions, terraform"

If a specific ecosystem was requested but not detected:
> "The 'terraform' ecosystem was requested but no Terraform files were found in this repository."

## 4. Run Dependabot Updates

For each ecosystem to scan, run the Dependabot CLI:

```bash
# Get the repository name dynamically
REPO=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name')
LOCAL_GITHUB_ACCESS_TOKEN=$(gh auth token) dependabot update <ecosystem> "$REPO" --local . 2>&1
```

Where `<ecosystem>` is the CLI ecosystem value (e.g., `npm_and_yarn`, `terraform`, `github_actions`).

**Run ecosystems serially** (one at a time) to avoid output confusion.

**Understanding the output:**
- The CLI outputs **JSON lines** (one JSON object per line), NOT human-readable tables
- The CLI **never modifies files directly** - it only outputs data describing what would change
- The `--local .` flag means "use local filesystem as source" — this prevents the CLI from cloning from GitHub and instead uses your working directory (it's NOT a "dry-run" flag)
- Output can be very large (40KB+) - it may be truncated
- **Important:** Use `2>&1` to capture both stdout and stderr, as the CLI mixes log messages (stderr) with JSON output (stdout)

## 5. Parse Results from JSON Output

The CLI outputs multiple JSON objects. Look for `create_pull_request` events to find updates:

```bash
# Filter for PR creation events (these contain the updates)
<output> | grep '"type":"create_pull_request"'
```

Each `create_pull_request` event contains:
- `dependencies[].name` - Package name
- `dependencies[].previous-version` - Current version
- `dependencies[].version` - Available version
- `pr-title` - Suggested PR title
- `updated-dependency-files[]` - The actual file changes to apply

**Determining if updates exist:**
- ✅ **Updates found:** One or more `create_pull_request` events in the output
- ❌ **No updates:** Only `mark_as_processed` events appear (no `create_pull_request`)

This is the definitive way to check — if you grep for `create_pull_request` and get no results, that ecosystem is up-to-date.

## 6. Present Results

Summarize findings in a clear format:

```
## Dependabot Scan Results

### github_actions
| Dependency | Current | Available |
|------------|---------|-----------|
| actions/checkout | v4 | v6 |
| extractions/setup-just | v2 | v3 |

### npm_and_yarn
No updates available.
```

If no updates are found across all ecosystems:
> "All dependencies are up-to-date!"

## 7. Offer PR Creation

If updates were found, ask the user:

> "Would you like to apply these updates and create a PR?"

**If yes, and multiple ecosystems have updates, ask about PR strategy:**

> "How would you like to organize the updates?"
> 1. **One PR per ecosystem** - Separate PRs for npm, terraform, etc.
> 2. **Single combined PR** - All updates in one PR

## 8. Apply Updates and Create PR(s)

Based on user's choice:

### For Each PR to Create:

1. **Create a feature branch:**
   ```bash
   # Ensure main is up-to-date before branching
   git checkout main && git pull origin main

   # If branch already exists from a previous run, delete it first:
   git branch -D dependabot/<ecosystem>-updates 2>/dev/null || true

   git checkout -b dependabot/<ecosystem>-updates
   # or for combined: dependabot/all-updates
   ```

2. **Apply changes manually:**
   From the `create_pull_request` JSON events, extract the `updated-dependency-files` array.
   Each entry contains:
   - `name` - The file path (e.g., `.github/workflows/ci.yml`)
   - `content` - The new file content
   - `directory` - The directory (usually `/`)

   Use the Edit tool to update each file with the new content, or apply targeted edits
   based on the `dependencies` array showing old → new versions.

3. **Stage and commit changes:**
   ```bash
   git add <modified-files>
   git commit -m "chore(deps): update <ecosystem> dependencies

   Updated by Dependabot CLI

   Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
   ```

4. **Push and create PR:**
   ```bash
   git push -u origin dependabot/<ecosystem>-updates
   gh pr create --title "chore(deps): update <ecosystem> dependencies" \
     --body "## Summary
   - Dependency updates detected by Dependabot CLI

   ## Updates
   <list updates with old → new versions>

   ## Test plan
   - [ ] Verify build passes
   - [ ] Verify tests pass
   - [ ] Review changelog for breaking changes

   🤖 Generated with [Claude Code](https://claude.com/claude-code)"
   ```

5. **Return to original branch** after PR creation.

## Important Notes

- Always use `gh auth token` for authentication - never ask for tokens directly
- Some ecosystems may require additional configuration (e.g., private registries)
- If dependabot fails for an ecosystem, report the error and continue with others
