# nix-config

 My Nix/NixOS config files

## Requirements

- Expects a `environment.nix` file at `/etc/nixos/environment.nix` or `/etc/nix/environment.nix` or `~/nix-config/environment.nix` (template provided)
    - On a Fresh Install create the file at `/mnt/etc/nixos/environment.nix`
    - When rebuilding, just symlink it from the repo with `sudo ln -s environment.nix /etc/nixos/environment.nix`

- Also expects [stow](https://www.gnu.org/software/stow/)-styled (`/dotfiles/nvim/.config/nvim`) dotfiles cloned into `~/dotfiles` (here are [mine](https://github.com/laurent-lao/dotfiles))

## Usage

Note: `--impure` flag required to look for the `environment.nix` file

### On NixOS

Fresh install with `sudo nixos-install --impure --root /mnt --flake github:laurent-lao/nix-config#thinkpad`


Rebuild with `sudo nixos-rebuild switch --impure --flake ~/nix-config#thinkpad`

### On Standalone Home-Manager

Rebuild with `home-manager switch --impure --flake ~/nix-config#lone`

