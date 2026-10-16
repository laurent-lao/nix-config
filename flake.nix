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
          { imports = [ /etc/nixos/hardware-configuration.nix ]; }

          inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Point to home.nix in the same directory as flake.nix
              home-manager.users."${fileEnv.userName}" = import ./home/home.nix;
            }
        ];
      };

      # x86_64 VM
      "vm" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/vm/configuration.nix
          { imports = [ /etc/nixos/hardware-configuration.nix ]; }

          inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Point to home.nix in the same directory as flake.nix
              home-manager.users."${fileEnv.userName}" = import ./home/home.nix;
            }
        ];
      };

      # ARM/Apple Silicon VM
      "armvm" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/armvm/configuration.nix
          { imports = [ /etc/nixos/hardware-configuration.nix ]; }

          inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Point to home.nix in the same directory as flake.nix
              home-manager.users."${fileEnv.userName}" = import ./home/home.nix;
            }
        ];
      };
    };

    # Standalone Home-Manager
    homeConfigurations = {
      # home-manager switch --flake ~/nix-config#lone-86
      "lone" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home/home.nix ];
      };

      # home-manager switch --flake ~/nix-config#lone-arm
      "lone-arm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home/home.nix ];
      };
    };
  };
}
