{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../../fs/portable.nix
  ];

  boot.initrd.kernelModules = [
    "vmd"
    "usb_storage"
    "uas"
    "xhci_pci"
    "ehci_pci"
  ]; # on some hardware this may be needed to discover filesystems

  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      efiInstallAsRemovable = true;
      efiSupport = true;
      device = "nodev";
      extraConfig = "nvme_load=YES";
    };
  };

  systemd.coredump = {
    enable = true;
    extraConfig = ''
      MaxUse=256M
    '';
  };

  networking.hostName = "nixos-portable";

  hardware.graphics.extraPackages = with pkgs; [
    vaapiIntel
    intel-media-driver
  ];

  # VirtualBox guest support
  virtualisation.virtualbox.guest = {
    enable = true;
    seamless = true;
    draganddrop = true;
    clipboard = true;
  };

}
