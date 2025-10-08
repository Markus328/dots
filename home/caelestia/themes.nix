{
  cofig,
  lib,
  pkgs,
  ...
}:
with pkgs; {
  home = {
    pointerCursor = {
      gtk.enable = true;
      name = "Bibata-Modern-Ice";
      size = 24;
      package = bibata-icon-ice;
    };
  };
}
