# hosts/macvm/home.nix
{ pkgs, lib, config, inputs, ... }@args:
let
  # Load required environment values from environment.nix.
  nixosEnvPath = /etc/nixos/environment.nix;
  loneEnvPath = /etc/nix/environment.nix;
  repoEnvPath = ./environment.nix;

  # Check which file exists and fail if none is available.
  fileEnv =
    if builtins.pathExists nixosEnvPath then
      import nixosEnvPath
    else if builtins.pathExists loneEnvPath then
      import (builtins.toPath loneEnvPath)
    else if builtins.pathExists repoEnvPath then
      import (builtins.toPath repoEnvPath)
    else
      throw "Missing environment.nix: expected /etc/nixos/environment.nix, /etc/nix/environment.nix, or ${toString repoEnvPath}";

  # Detect platform
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # Define base paths
  homeDir = if isDarwin then "/Users/${fileEnv.userName}" else "/home/${fileEnv.userName}";

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
  home.username = fileEnv.userName;
  home.homeDirectory = homeDir;

  # Global
  programs.home-manager.enable = true;
  home.sessionVariables = {EDITOR = "nvim"; Visual = "nvim"; };
  programs.zsh.enable = true;

  # Terminal Shell
  # programs.bash.enable = true;
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.starship.enable = true;

  # Mise
  programs.mise.enable = true;

  xdg.enable = if isLinux then true else false;
  fonts.fontconfig.enable = isLinux;

  # Git
  programs.git = {
    enable = if isLinux then true else false;
    settings = {
      user = {
        name = fileEnv.gitName;
        email = fileEnv.gitEmail;
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  # Optional host-specific modules, followed by OS-dependent imports.
  imports = (args.extraHomeModules or []) ++ (if isLinux then [
    # Plasma-manager themes
    inputs.plasma-manager.homeModules.plasma-manager
    {
      programs.plasma = {
        enable = true;
        workspace = {
          lookAndFeel = "org.kde.breezedark.desktop";
          theme = "breeze-dark";
          colorScheme = "GruvboxColors";
          splashScreen = {
            engine = "KSplashQML";
            theme = "NixOS-Splash-Plasma6";
          };
        };
      };
    }
  ] else []);

  # OS-dependent Dotfiles
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

  # OS-Dependent Packages
  home.packages = with pkgs; [
    # All platforms

    # Editors
    neovim
    nano
    vscode

    # CLI utilities
    bat
    eza
    fd
    fzf

    # System information and monitoring
    fastfetch
    htop
    btop
  ] ++ (if isLinux then [
    # Linux only packages

    # Terminals
    alacritty
    kitty

    # Password management
    bitwarden-desktop
    bitwarden-cli

    # Voice input and clipboard
    voxtype
    wl-clipboard
    wtype

    # Documents
    texlive.combined.scheme-full
    zathura

    # File sharing
    localsend

    # Fonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans

    # AI tools
    chatgpt
    codex
    opencode
    herdr
    # antigravity-cli
    # claude-code
    # gemini-cli
    # github-copilot-cli

    # Desktop appearance
    inputs.nixos-splash-plasma6.packages.${pkgs.system}.default
  ] else if isDarwin then [
    # macOS only packages
  ] else []);
}
