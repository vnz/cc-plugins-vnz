# Dependabot Plugin

Check for dependency updates across your project using the official [Dependabot CLI](https://github.com/dependabot/cli) with automatic ecosystem detection.

## Prerequisites

1. **Dependabot CLI** - Install from https://github.com/dependabot/cli
2. **GitHub CLI (gh)** - For authentication via `gh auth token`

## Installation

```bash
/plugin install dependabot@cc-plugins-vnz
```

## Usage

### Scan All Ecosystems

```
use dependabot
```

Auto-detects all package managers in your repository and checks for updates.

### Scan Specific Ecosystem

```
use dependabot for terraform
use dependabot for npm
use dependabot for github-actions
```

## Supported Ecosystems

| Ecosystem | Trigger Aliases | Detection Files |
|-----------|-----------------|-----------------|
| GitHub Actions | `github-actions`, `actions`, `workflows` | `.github/workflows/*.yml` |
| Terraform | `terraform`, `tf` | `*.tf` |
| npm/yarn/pnpm | `npm`, `yarn`, `pnpm` | `package.json` |
| Go | `go`, `golang` | `go.mod` |
| Python | `python`, `pip`, `pipenv` | `requirements.txt`, `pyproject.toml`, `Pipfile`, `setup.py` |
| Ruby | `ruby`, `bundler`, `gems` | `Gemfile` |
| Rust | `rust`, `cargo` | `Cargo.toml` |
| Docker | `docker` | `Dockerfile`, `*.dockerfile`, `docker-compose.yml` |
| Maven | `maven`, `java` | `pom.xml` |
| Gradle | `gradle` | `build.gradle`, `build.gradle.kts` |
| Composer | `composer`, `php` | `composer.json` |
| NuGet | `nuget`, `dotnet`, `csharp` | `*.csproj`, `packages.config`, `*.fsproj` |
| Helm | `helm` | `Chart.yaml` |
| Pub (Dart) | `dart`, `flutter`, `pub` | `pubspec.yaml` |
| Swift | `swift` | `Package.swift` |
| Hex (Elixir) | `elixir`, `hex` | `mix.exs` |

## Workflow

1. **Prerequisites check** - Verifies `dependabot` and `gh` CLIs are installed
2. **Ecosystem detection** - Finds package managers based on config files
3. **Update scan** - Runs `dependabot update --local` for each ecosystem
4. **Results presentation** - Shows available updates in a table
5. **PR creation** (optional) - Offers to apply updates and open PR(s)

## PR Strategy

When updates are found, you'll be asked:
- **One PR per ecosystem** - Separate PRs for npm, terraform, etc.
- **Single combined PR** - All updates in one PR

## Authentication

The plugin uses `gh auth token` to obtain a GitHub access token. Ensure you're authenticated with the GitHub CLI:

```bash
gh auth login
```

## How It Works

The Dependabot CLI runs locally against your repository:

```bash
# Dry-run mode (check for updates)
LOCAL_GITHUB_ACCESS_TOKEN=$(gh auth token) dependabot update <ecosystem> <owner/repo> --local .

# Apply mode (modify files)
LOCAL_GITHUB_ACCESS_TOKEN=$(gh auth token) dependabot update <ecosystem> <owner/repo>
```

The `--local .` flag runs in dry-run mode, showing what would be updated without making changes.

## Links

- [Dependabot CLI Repository](https://github.com/dependabot/cli)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
