{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../fs/desktop.nix
    ../../secrets/templates.nix
  ];

  services.xserver = {
    enable = true;
    excludePackages = with pkgs; [ xterm ];

    xkb = {
      layout = "us,br";
      variant = "workman,abnt2";
      options = "grp:win_space_toggle";
    };

    displayManager.lightdm.enable = false;
  };
  services.libinput.enable = true;
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ "markus" ];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
  services.logind.settings.Login = {
    handleLidSwitch = "lock";
    handleLidSwitchExternalPower = "lock";
  };
  # services.upower.ignoreLid = true;
  # services.acpid = {
  #   enable = true;
  #   handlers."acpi-power" = {
  #     event = "button/power.*";
  #     # action = "${inputs.self.scripts.acpi-power}/bin/acpi-power $@";
  #   };
  # };
  # Device-specific fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.monofur
    ];
    fontDir.enable = true;
  };

  # User-specific configuration
  users.users.markus.subUidRanges = [
    {
      startUid = 100000;
      count = 65536;
    }
  ];
  users.users.markus.subGidRanges = [
    {
      startGid = 100000;
      count = 65536;
    }
  ];

  # Virtualization
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    waydroid.enable = true;
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;

    settings = {
      # capture = "kms";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt # QSV
    ];
  };

  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [ podman-compose ];

  # networking.nftables.enable = true;

  networking.firewall.checkReversePath = "loose";
  services.tailscale.useRoutingFeatures = "both";

  # CLOUDFLARED
  services.cloudflared = {
    enable = true;
    certificateFile = config.sops.secrets.cloudflared-cert.path;
  };

  specialisation.gaming.configuration = {
    environment.etc."specialisation".text = "gaming";
    programs.steam = {
      enable = true;
    };
    programs.gamemode.enable = true;
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-unwrapped"
        "steam-run"
      ];
  };
}
