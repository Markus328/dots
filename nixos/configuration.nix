# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = [
    ./cachix.nix
    inputs.niri-flake.nixosModules.niri
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux"; # All my hosts pretend to be on x86_64-linux

  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", TAG+="uaccess"
  '';

  #NIX
  nix = {
    package = pkgs.lix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      build-dir = "/nix/var/build";
    };
  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [ ];

  boot.tmp.useTmpfs = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  services.udisks2.enable = true;

  services.geoclue2 = {
    enable = true;
  };

  programs.zsh.enable = true;

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  services.gnome.gnome-keyring.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;

  #USERS
  users.users = {
    markus = {
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "markus"
        "input"
      ]; # Enable ‘sudo’ for the user.
    };
    root.shell = pkgs.zsh;
  };

  #PACKAGES
  environment.systemPackages = with pkgs; [
    wget
    git
    vim
    zip
    unzip
    compsize
    patchelf
    wl-clipboard

    nixos-rebuild-wrapper
    nixos-chspec

    android-tools
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
    ];
  };

  # security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.pam.loginLimits = lib.mkIf (config.boot.isContainer) (lib.mkForce [ ]); # Disable limits that usually won't work in rootless containers

  programs.gpu-screen-recorder.enable = true;

  documentation.man.cache.enable = true;

  system.stateVersion = "25.11";
}
