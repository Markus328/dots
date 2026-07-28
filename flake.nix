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

    niri-local = {
      url = "git+file:///userdata/@workspace/niri";
      flake = false;
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        niri-unstable.follows = "niri-local";
      };
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-nix = {
      url = "github:Markus328/caelestia-nix";
      # url = "github:Markus328/caelestia-nix/staging";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        caelestia-shell.follows = "caelestia-shell";
      };
    };

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hm-ricing-mode = {
      url = "github:Markus328/hm-ricing-mode/fix-hm-module";
    };

    nixarr.url = "github:rasmus-kirk/nixarr";

    extra-container = {
      url = "github:erikarvstedt/extra-container";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    inputs:
    let
      inherit (inputs) nixpkgs;

      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      nixosSystem = host: import ./nixos { inherit host inputs pkgs; };
      homeConfiguration = host: import ./home { inherit host inputs pkgs; };
    in
    {
      nixosConfigurations."nixos-desktop-notebook" = nixosSystem "nixos-desktop-notebook";
      nixosConfigurations."nixos-remote" = nixosSystem "nixos-remote";
      nixosConfigurations."nixos-portable" = nixosSystem "nixos-portable";

      homeConfigurations."markus@nixos-desktop-notebook" = homeConfiguration "nixos-desktop-notebook";
      homeConfigurations."markus@nixos-remote" = homeConfiguration "nixos-remote";
    };
}
