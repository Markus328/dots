{
  host,
  inputs,
  pkgs,
  ...
}:
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [./home.nix ../overlays];
  extraSpecialArgs = {
    inherit inputs host;
  };
}
