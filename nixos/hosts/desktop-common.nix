{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../fs/desktop.nix
  ];

  services.xserver = {
    enable = true;
    excludePackages = with pkgs; [xterm];

    xkb = {
      layout = "us,br";
      variant = "workman,abnt2";
      options = "grp:win_space_toggle";
    };

    displayManager.lightdm.enable = false;
  };
  services.libinput.enable = true;
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["markus"];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
  services.logind.settings.Login = {
    handlePowerKey = "ignore";
    handlePowerKeyLongPress = "ignore";
    handleLidSwitchDocked = "lock";
  };
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
    podman.enable = true;
    waydroid.enable = true;
  };

  networking.firewall.checkReversePath = "loose";
  services.tailscale.useRoutingFeatures = "both";
}
