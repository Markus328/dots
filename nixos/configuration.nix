# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  imports = [
    ./hardware-configuration.nix
    ./cachix.nix
  ];

  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", TAG+="uaccess"
  '';

  #NIX
  nix = {
    package = pkgs.lix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      build-dir = "/nix/var/build";
    };
  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = ["mitigations=off" "boot.shell_on_fail"];
  boot.tmp.useTmpfs = true;

  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot/efi"; ## Set yourself
    };
    grub = {
      enable = true;
      efiInstallAsRemovable = true;
      efiSupport = true;
      device = "nodev";
    };
  };

  time.hardwareClockInLocalTime = true;

  systemd = {
    services = {
      # snapshots = {
      #   enable = true;
      #   description = "Do a root and home snapshot";
      #   serviceConfig = {
      #     ExecStart = "${inputs.self.scripts.snapshots}/bin/snapshots -r";
      #   };
      # };
      auto-gc = {
        enable = true;
        description = "collect nix garbage";
        serviceConfig = {
          ExecStart = "nix-collect-garbage";
        };
      };
    };

    timers = {
      snapshots = {
        enable = true;
        description = "Timer to run snapshots.service every day at 5pm.";
        timerConfig = {
          OnCalendar = "*-*-* 17:00:00";
          Persistent = true;
        };
        wantedBy = ["timers.target"];
      };
      auto-gc = {
        enable = true;
        description = "Timer to run auto-gc.service each week";
        timerConfig = {
          OnCalendar = "Sun *-*-* 00:00:00";
          Persistent = true;
        };
        wantedBy = ["timers.target"];
      };
    };
  };

  #DESKTOP
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  services.tailscale.enable = true;
  services.resolved.enable = true;

  services.udisks2.enable = true;

  services.geoclue2 = {
    enable = true;
  };

  programs.adb.enable = true;

  programs.zsh.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = pkgs.hyprland;
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];

  security.pam.services.login.enableGnomeKeyring = true;

  #USERS
  users.users = {
    markus = {
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = ["wheel" "markus" "adbusers"]; # Enable ‘sudo’ for the user.
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
    microcode-intel
    # python38
    firefox
    wl-clipboard

    nixos-rebuild-wrapper
    nixos-chspec
  ];

  #EXTRA
  networking = {
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };
  time.timeZone = "America/Fortaleza";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
    ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.gpu-screen-recorder.enable = true;

  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  system.stateVersion = "25.11";

  specialisation = {
    default = {}; # Allow -c default to use the default specialisation
    niri = {
      configuration = {
        environment.sessionVariables.NIXOS_SPEC = "niri";
        imports = [
          inputs.niri-flake.nixosModules.niri
        ];
        programs.niri = {
          enable = true;
          package = pkgs.niri-unstable;
        };
        programs.hyprland.enable = lib.mkForce false;
      };
    };
  };
}
