# Flake Conversion Guide

## What Changed

1. **Created `flake.nix`** - Main flake configuration that:
   - Pins nixpkgs to 25.11 release
   - Manages home-manager and sops-nix as flake inputs
   - Defines the system configuration

2. **Updated `configuration.nix`**:
   - Removed `let` block with tarball fetches
   - Removed home-manager and sops-nix imports (now handled by flake)
   - Added `nix.settings.experimental-features` to enable flakes

3. **Home-manager integration** moved to flake.nix

## How to Apply

On the NixOS laptop:

```bash
cd ~/nixos-config

# Commit current changes
git add .
git commit -m "Convert to flakes"
git push

# Generate flake.lock (first time only)
nix flake lock

# Rebuild using flakes
sudo nixos-rebuild switch --flake .#nixos

# If successful, commit the lock file
git add flake.lock
git commit -m "Add flake.lock"
git push
```

## New Rebuild Command

From now on, use:
```bash
sudo nixos-rebuild switch --flake .#nixos
```

Or from anywhere:
```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

## Benefits

- ✅ Exact version pinning (see `flake.lock`)
- ✅ Reproducible builds
- ✅ Faster evaluation
- ✅ Consistent with your server setup

## Updating

To update all inputs (nixpkgs, home-manager, sops-nix):
```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos
git add flake.lock
git commit -m "Update flake inputs"
```

To update just one input:
```bash
nix flake lock --update-input nixpkgs
```
