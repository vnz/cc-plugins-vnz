---
description: Check for dependency updates using Dependabot CLI. Trigger with "use dependabot" to scan all ecosystems or "use dependabot for <ecosystem>" for a specific one (e.g., terraform, npm, github-actions).
---

# Dependabot Update Skill

Scan for dependency updates using the official Dependabot CLI and optionally create PRs for found updates.

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

Map common aliases to Dependabot CLI ecosystem values:
| User Says | CLI Ecosystem |
|-----------|---------------|
| npm, yarn, pnpm | `npm_and_yarn` |
| github-actions, actions, workflows | `github_actions` |
| terraform, tf | `terraform` |
| go, golang | `go_modules` |
| python, pip, pipenv | `pip` |
| ruby, bundler, gems | `bundler` |
| rust, cargo | `cargo` |
| docker | `docker` |
| maven, java | `maven` |
| gradle | `gradle` |
| composer, php | `composer` |
| nuget, dotnet, csharp | `nuget` |
| helm | `helm` |
| dart, flutter, pub | `pub` |
| swift | `swift` |
| elixir, hex | `hex` |

## 3. Ecosystem Auto-Detection

If scanning all ecosystems, detect which are present using file existence checks:

| Ecosystem | CLI Value | Detection Method |
|-----------|-----------|------------------|
| GitHub Actions | `github_actions` | Glob: `.github/workflows/*.yml` or `.github/workflows/*.yaml` |
| Terraform | `terraform` | Glob: `*.tf` or `**/*.tf` (check root and subdirs) |
| npm/yarn/pnpm | `npm_and_yarn` | File exists: `package.json` |
| Go | `go_modules` | File exists: `go.mod` |
| Python (pip) | `pip` | File exists: `requirements.txt`, `pyproject.toml`, `Pipfile`, or `setup.py` |
| Ruby | `bundler` | File exists: `Gemfile` |
| Rust | `cargo` | File exists: `Cargo.toml` |
| Docker | `docker` | Glob: `Dockerfile` or `*.dockerfile` or `docker-compose.yml` |
| Maven | `maven` | File exists: `pom.xml` |
| Gradle | `gradle` | File exists: `build.gradle` or `build.gradle.kts` |
| Composer | `composer` | File exists: `composer.json` |
| NuGet | `nuget` | Glob: `*.csproj` or `packages.config` or `*.fsproj` |
| Helm | `helm` | File exists: `Chart.yaml` |
| Pub (Dart) | `pub` | File exists: `pubspec.yaml` |
| Swift | `swift` | File exists: `Package.swift` |
| Hex (Elixir) | `hex` | File exists: `mix.exs` |

Report detected ecosystems to the user before proceeding:
> "Detected ecosystems: npm_and_yarn, github_actions, terraform"

If a specific ecosystem was requested but not detected:
> "The 'terraform' ecosystem was requested but no Terraform files were found in this repository."

## 4. Run Dependabot Updates

For each ecosystem to scan, run the Dependabot CLI:

```bash
# Get the repository name dynamically
REPO=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name')
LOCAL_GITHUB_ACCESS_TOKEN=$(gh auth token) dependabot update <ecosystem> "$REPO" --local .
```

Where `<ecosystem>` is the CLI ecosystem value (e.g., `npm_and_yarn`, `terraform`, `github_actions`).

**Run ecosystems serially** (one at a time) to avoid output confusion.

**Understanding the output:**
- The CLI outputs **JSON lines** (one JSON object per line), NOT human-readable tables
- The CLI **never modifies files directly** - it only outputs data describing what would change
- The `--local .` flag means "use local filesystem as source" (not "dry-run")
- Output can be very large (40KB+) - it may be truncated

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

If no `create_pull_request` events are found, or only `mark_as_processed` appears, there are no updates.

## 6. Present Results

Summarize findings in a clear format:

```
## Dependabot Scan Results

### github_actions
| Dependency | Current | Available | Type |
|------------|---------|-----------|------|
| actions/checkout | v4 | v6 | update |
| extractions/setup-just | v2 | v3 | update |

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
   git checkout -b dependabot/<ecosystem>-updates
   # or for combined: dependabot/all-updates
   ```

2. **Apply changes manually:**
   The CLI doesn't modify files - you must apply the changes yourself.

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

   🤖 Generated with [Claude Code](https://claude.ai/claude-code)"
   ```

5. **Return to original branch** after PR creation.

## Important Notes

- Always use `gh auth token` for authentication - never ask for tokens directly
- The CLI **outputs JSON describing changes** - it never modifies files directly
- The `--local .` flag means "use local directory as repo source" (avoids cloning from GitHub)
- Without `--local`, the CLI clones from GitHub but still doesn't modify your local files
- Some ecosystems may require additional configuration (e.g., private registries)
- If dependabot fails for an ecosystem, report the error and continue with others
- JSON output can be 40KB+ - grep for `create_pull_request` to find relevant data
