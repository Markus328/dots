{
  host,
  inputs,
  pkgs,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  modules = [./configuration.nix ./hosts/${host}/configuration.nix ../overlays];
  specialArgs = {
    inherit host inputs;
  };
}
