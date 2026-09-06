{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.myContainers;
  condImport =
    container: name:
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }@args:
    {
      config = lib.mkIf config.myContainers.${name}.enable (import container args);
    };
in
{
  imports = [
    inputs.extra-container.nixosModules.default
    (condImport ./media-server "media-server")
    (condImport ./nixos-remote.nix "nixos-remote")
    (condImport ./open-notebook.nix "open-notebook")
  ];
  options.myContainers = with lib; {
    media-server.enable = mkEnableOption "Enable Media Server container";
    nixos-remote.enable = mkEnableOption "Enable nixos-remote container";
    open-notebook.enable = mkEnableOption "Enable Open Notebook container";
  };
  config = {
    boot.enableContainers = true;
    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "ens3";
    };

    # Disable containers when gaming
    specialisation.gaming.configuration = {
      # myContainers.nixarr.enable = lib.mkForce false;
      myContainers.nixos-remote.enable = lib.mkForce false;
      myContainers.open-notebook.enable = lib.mkForce false;
    };

    # Enable oci containers with podman
    virtualisation.oci-containers.backend = "podman";
    virtualisation.podman.enable = true;
  };
}
