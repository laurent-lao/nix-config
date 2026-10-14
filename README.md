# nix-config

 My Nix/NixOS config files

--- 

 Expects a `environment.nix` file at `/etc/nixos/` or `/etc/nix` (template provided)

 Also expects my `dotfiles` cloned into `~/dotfiles`

---

## On NixOS

Run with `sudo nixos-rebuild switch --impure --flake ~/nix-config#thinkpad`

## On Standalone Home-Manager

Run with `home-manager switch --impure --flake ~/nix-config#lone-x86`

---
