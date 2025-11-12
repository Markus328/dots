{
  description = "My dotfiles";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/tags/v0.51.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprdarkwindow = {
      url = "github:micha4w/Hypr-DarkWindow/tags/v0.51.1";
      inputs.hyprland.follows = "hyprland";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs = {
        hyprland.follows = "hyprland";
        nixpkgs.follows = "hyprland/nixpkgs";
      };
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-nix = {
      url = "github:Markus328/caelestia-nix";
      # url = "github:Markus328/caelestia-nix/staging";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        caelestia-shell.follows = "caelestia-shell";
      };
    };

    hm-ricing-mode = {
      url = "github:Markus328/hm-ricing-mode/fix-hm-module";
    };
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    nixosSystem = host: import ./nixos {inherit host inputs pkgs;};
    homeConfiguration = host: import ./home {inherit host inputs pkgs;};
  in {
    nixosConfigurations."nixos-desktop-notebook" = nixosSystem "nixos-desktop-notebook";
    homeConfigurations."markus@nixos-desktop-notebook" = homeConfiguration "nixos-desktop-notebook";
  };
}
