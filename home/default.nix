{
  host,
  inputs,
  pkgs,
  ...
}:
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [./home.nix ./hosts/${host} ../overlays];
  extraSpecialArgs = {
    inherit inputs host;
  };
}
