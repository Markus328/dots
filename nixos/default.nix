{
  host,
  inputs,
  pkgs,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  modules = [./configuration.nix ./hosts/${host} ../overlays];
  specialArgs = {
    inherit host inputs;
  };
}
