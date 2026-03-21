# NixOS config utilities
# Requires: nh, nix-output-monitor, nvd, statix, alejandra

hostname := `hostname`

# List available recipes
default:
    @just --list

# Quick eval check - fastest, no building
check:
    nix eval .#nixosConfigurations.{{hostname}}.config.system.build.toplevel

# Validate flake schema and expressions
flake-check:
    nix flake check

# Dry run - resolve full closure without building
dry:
    nixos-rebuild dry-run --flake .#{{hostname}}

# Full build with pretty output (no switch)
build:
    nh os build .

# Build and switch to new generation
switch:
    nh os switch .

# Lint with statix
lint:
    statix check .

# Format with alejandra
fmt:
    alejandra .

# Format check without writing (for CI)
fmt-check:
    alejandra --check .

# Diff current vs last generation
diff:
    nvd diff /run/current-system $(ls -d /nix/var/nix/profiles/system-*-link | sort -V | tail -1)

# Search nix documentation
docs query:
    manix "{{query}}"

# Inspect nix store TUI
inspect:
    nix-inspect

# Run all checks (eval + lint + fmt-check)
ci: check lint fmt-check
    @echo "All checks passed"

