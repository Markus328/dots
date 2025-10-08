{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs; {
  fonts.fontconfig.enable = true;
  home.packages = [
    fantasque-sans-mono
  ];
}
