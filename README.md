# nix-config

 My Nix/NixOS config files

--- 
## Requirements

- Expects a `environment.nix` file at `/etc/nixos/environment.nix` or `/etc/nix/environment.nix` (template provided)

- Also expects my [dotfiles](https://github.com/laurent-lao/dotfiles) cloned into `~/dotfiles`

---

## On NixOS

Run with `sudo nixos-rebuild switch --impure --flake ~/nix-config#thinkpad`

## On Standalone Home-Manager

Run with `home-manager switch --impure --flake ~/nix-config#lone-x86`

---
