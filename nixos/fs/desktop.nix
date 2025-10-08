# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{config, ...}: {
  swapDevices = [
    {
      label = "swap8G";
      priority = 0;
    }
  ];
  zramSwap = {
    enable = true;
    swapDevices = 4;
    algorithm = "zstd";
    priority = 32767;
  };

  #FILESYSTEM
  fileSystems = let
    options = ["rw" "noatime" "ssd" "space_cache=v2"];
    compress.options = options ++ ["compress-force=zstd"];
    label = "root";
    fsType = "btrfs";
  in {
    "/" = {
      inherit label;
      options = compress.options ++ ["subvol=/nixos/@"];
      inherit fsType;
    };
    "/nix" = {
      inherit label;
      options = compress.options ++ ["subvol=/@nix"];
      inherit fsType;
    };
    "/var/lib/flatpak" = {
      inherit label;
      options = compress.options ++ ["subvol=/@flatpak"];
      inherit fsType;
    };
    "/userdata" = {
      inherit label;
      options = compress.options ++ ["subvol=/@userdata"];
      inherit fsType;
    };
    "/home" = {
      inherit label;
      options = compress.options ++ ["subvol=@home"];
      inherit fsType;
    };
    "/.snapshots" = {
      inherit label;
      options = compress.options ++ ["subvol=/snapshots/root/@nixos"];
      inherit fsType;
    };
    "/home/.snapshots" = {
      inherit label;
      options = compress.options ++ ["subvol=/snapshots/@home"];
      inherit fsType;
    };
    "/userdata/@dotfiles/.snapshots" = {
      inherit label;
      options = compress.options ++ ["subvol=/snapshots/@dotfiles"];
      inherit fsType;
    };
    "/userdata/@workspace/.snapshots" = {
      inherit label;
      options = compress.options ++ ["subvol=/snapshots/@workspace"];
      inherit fsType;
    };
  };

  environment.sessionVariables.NIXCONFIG = "/userdata/@dotfiles";
}
