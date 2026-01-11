# terraform-ls

Terraform language server plugin for Claude Code, providing code intelligence features for Terraform/HCL files.

## Features

| Feature | Description |
|---------|-------------|
| **goToDefinition** | Navigate to resource/variable/module definitions |
| **findReferences** | Find all usages across your codebase |
| **hover** | Inline documentation for resources and attributes |
| **diagnostics** | Real-time validation and error checking |

## Supported Files

| Extension | Language ID | Description |
|-----------|-------------|-------------|
| `.tf` | `terraform` | Terraform configuration |
| `.tfvars` | `terraform-vars` | Variable definitions |

> **Note:** `.tftest.hcl` files are not yet supported by terraform-ls ([tracking issue](https://github.com/hashicorp/terraform-ls/issues/1648)).

## Prerequisites

Requires [terraform-ls](https://github.com/hashicorp/terraform-ls) (HashiCorp's official Terraform Language Server) in your PATH.

```bash
# macOS
brew install hashicorp/tap/terraform-ls

# Other platforms
# See https://github.com/hashicorp/terraform-ls/releases
```

## Installation

```bash
# Add marketplace from vnz/cc-plugins (aliased as cc-plugins-vnz)
/plugin marketplace add vnz/cc-plugins

# Install plugin from the new marketplace
/plugin install terraform-ls@cc-plugins-vnz
```

Enable LSP in your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "env": {
    "ENABLE_LSP_TOOL": "1"
  }
}
```

## Troubleshooting

### Plugin not visible
Run `/plugin list` and verify the plugin appears. Try reinstalling if needed.

### LSP not working
1. Verify terraform-ls is in your PATH: `which terraform-ls`
2. Check that `ENABLE_LSP_TOOL=1` is set in your settings and restart Claude Code.
3. Check Claude Code logs for any `terraform-ls` errors.

## Links

- [terraform-ls GitHub](https://github.com/hashicorp/terraform-ls)
- [terraform-ls Usage Guide](https://github.com/hashicorp/terraform-ls/blob/main/docs/USAGE.md)
- [HashiCorp Terraform](https://www.terraform.io/)
