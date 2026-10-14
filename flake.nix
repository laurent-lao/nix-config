{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia + Umbriel
    noctalia.url = "github:noctalia-dev/noctalia";
    umbriel.url = "github:noctalia-dev/umbriel";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let

    # Get environment variables from environment.nix or use fallbacks
    nixosEnvPath = /etc/nixos/environment.nix;
    loneEnvPath = /etc/nix/environment.nix;

    # Check which file exist
    fileEnv =
      if builtins.pathExists nixosEnvPath then
        import nixosEnvPath
      else if builtins.pathExists loneEnvPath then
        import (builtins.toPath loneEnvPath)
      else
        {};

    fallbacks = {
      hostName = "nixos";
      userName = "nixos-user";
      gitName = "Anonymous User";
      gitEmail = "anonymous@example.com";
    };

    finalEnv = fallbacks // fileEnv;
  in
  {
    # NixOS
    nixosConfigurations = {
      # ThinkPad
      "thinkpad" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/thinkpad/configuration.nix
          { imports = [ ./hosts/thinkpad/hardware-configuration.nix ]; }

          inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Point to home.nix in the same directory as flake.nix
              home-manager.users."${finalEnv.userName}" = import ./home.nix;
            }
        ];
      };

      # Mac VM (Apple Silicon)
      "macvm" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/macvm/configuration.nix
          { imports = [ ./hosts/macvm/hardware-configuration.nix ]; }

          inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Point to home.nix in the same directory as flake.nix
              home-manager.users."${finalEnv.userName}" = import ./home.nix;
            }
        ];
      };
    };

    # Standalone Home-Manager
    homeConfigurations = {
      # home-manager switch --flake ~/nix-config#lone-86
      "lone-x86" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };

      # home-manager switch --flake ~/nix-config#lone-arm
      "lone-arm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
  };
}
