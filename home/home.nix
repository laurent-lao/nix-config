# hosts/macvm/home.nix
{ pkgs, lib, config, ... }:
let
  # Get environment variables from environment.nix or use fallbacks
  nixosEnvPath = /etc/nixos/environment.nix;
  loneEnvPath = /etc/nix/environment.nix;
  repoEnvPath = ./environment.nix;

  # Check which file exist
  fileEnv =
    if builtins.pathExists nixosEnvPath then
      import nixosEnvPath
    else if builtins.pathExists loneEnvPath then
      import (builtins.toPath loneEnvPath)
    else if builtins.pathExists repoEnvPath then
      import (builtins.toPath repoEnvPath)
    else
      {};

  fallbacks = {
    hostName = "nixos";
    userName = "nixos-user";
    gitName = "Anonymous User";
    gitEmail = "anonymous@example.com";
  };

  finalEnv = fallbacks // fileEnv;

  # Detect platform
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # Define base paths
  homeDir = if isDarwin then "/Users/${finalEnv.userName}" else "/home/${finalEnv.userName}";

  dotfiles = "${homeDir}/dotfiles";

  # Shortcuts to link stow-styled dotfiles
  # ~/dotfiles/nvim/.config/nvim -> ~/.config/nvim
  linkConfig = name: {
    name = ".config/${name}";
    value.source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${name}/.config/${name}";
  };
  # ~/dotfiles/starship/.config/starship.toml -> ~/.config/starship.toml
  linkConfigFile = name: file: {
    name = ".config/${file}";
    value.source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${name}/.config/${file}";
  };
in
{
  home.stateVersion = "26.05";

  # User identity
  home.username = finalEnv.userName;
  home.homeDirectory = homeDir;

  # Global
  programs.home-manager.enable = true;
  programs.zsh.enable = true;
  # programs.bash.enable = true;
  home.sessionVariables = {EDITOR = "nvim"; Visual = "nvim"; };

  xdg.enable = if isLinux then true else false;

  # Git
  programs.git = {
    enable = if isLinux then true else false;
    settings = {
      user = {
        name = finalEnv.gitName;
        email = finalEnv.gitEmail;
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  # Dotfiles
  home.file = builtins.listToAttrs (
    if isLinux then [
      (linkConfig "nvim")
      (linkConfig "umbriel")
      # (linkConfig "alacritty")
      # (linkConfig "starship" "starship.toml")
    ] else if isDarwin then [
      # (linkConfig "alacritty")
      # (linkConfig "nvim")
      # (linkConfig "starship" "starship.toml")
    ] else []
  );

  home.packages = with pkgs; [
    # All platforms
    neovim
  ] ++ (if isLinux then [
    # Linux only packages
    alacritty
    kitty
    bitwarden-desktop
    bitwarden-cli
    btop
  ] else if isDarwin then [
    # macOS only packages
  ] else []);
}
