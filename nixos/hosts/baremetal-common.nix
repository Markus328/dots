{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../hardware-configuration.nix
    ../containers
    ../../secrets
  ];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModulePackages = with config.boot.kernelPackages; [evdi];
  boot.kernelParams = ["mitigations=off" "boot.shell_on_fail"];

  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      efiInstallAsRemovable = true;
      efiSupport = true;
      device = "nodev";
    };
  };

  # Fix issues with Windows dualboot
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

  # Allow realtime prio to user processes
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];
  security.rtkit.enable = true;

  # VPN to allow remote access
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];

  services.resolved = {
    enable = true;
      settings = {
        Resolve = {
          DNSSEC = "true";
          Domains = ["~."];
          FallbackDNS = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
          DNSOverTLS = "true";
        };
      };
  };

  networking = {
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };
  time.timeZone = "America/Fortaleza";

  # SYNCTHING
  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    systemService = false; # Managed by home-manager
  };

  specialisation.gaming.configuration = {
    services.syncthing.enable = lib.mkForce false;
  };
}
