# nix-config

 My Nix/NixOS config files

--- 
## Requirements

- Expects a `environment.nix` file at `/etc/nixos/environment.nix` or `/etc/nix/environment.nix` (template provided)
    - On a Fresh Install create the file at `/mnt/etc/nixos/environment.nix`

- Also expects my [dotfiles](https://github.com/laurent-lao/dotfiles) cloned into `~/dotfiles`

---

## Usage

Note: `--impure` flag required to look for the `environment.nix` file

### On NixOS

Fresh install with `sudo nixos-install --impure --root /mnt --flake github:laurent-lao/nix-config#thinkpad`


Rebuild with `sudo nixos-rebuild switch --impure --flake ~/nix-config#thinkpad`

### On Standalone Home-Manager

Rebuild with `home-manager switch --impure --flake ~/nix-config#lone-x86`

