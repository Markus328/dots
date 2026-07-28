{ config, ... }:
{
  fileSystems =
    let

      options = [
        "rw"
        "noatime"
        "space_cache=v2"
      ];
      compress.options = options ++ [ "compress-force=zstd:22" ]; # Tune for very slow drives

      device = "UUID=606b3d07-4bd2-4c7b-9987-4c5f7e2c8030";
      fsType = "btrfs";
    in
    {
      "/" = {
        inherit device;
        options = compress.options ++ [ "subvol=/@" ];
        inherit fsType;
      };
      "/userdata" = {
        inherit device;
        options = compress.options ++ [ "subvol=/@userdata" ];
        inherit fsType;
      };
      "/nix" = {
        inherit device;
        options = compress.options ++ [ "subvol=/@nix" ];
        inherit fsType;
      };
      "/home" = {
        inherit device;
        options = compress.options ++ [ "subvol=@home" ];
        inherit fsType;
      };
    };
}
