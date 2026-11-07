{ pkgs, ... }:

{
  # Additional packages for the ThinkPad only.
  home.packages = with pkgs; [
    # Communication
    discord

    # Productivity and synchronization
    obsidian
    onlyoffice-desktopeditors
    nextcloud-client

    # Browser
    chromium

    # Database tools
    dbeaver-bin

    # Media
    mpv
    plex-desktop
    iptvnator

    # Desktop utilities
    pavucontrol
    playerctl
    kanshi

    # Virtualization (virt-manager also provides virt-install)
    virt-manager
    virt-viewer
  ];
}
