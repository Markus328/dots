{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../desktop-common.nix
    ../notebook-common.nix
  ];

  # Device-specific boot configuration
  boot.initrd.kernelModules = [
    "vmd"
  ];
  boot.loader.grub.extraConfig = "nvme_load=YES";

  # Device-specific networking
  networking.hostName = "nixos-desktop-notebook";
}
