{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  services.syncthing.enable = true;

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "desc:XXW HDMI,1440x900,0x0,1"
        "eDP-1,preferred,1440x276, 1.33" # laptop display
      ];

      xwayland.force_zero_scaling = true; # Fix x11/electron apps in laptop display

      exec = ["hyprctl switchxkblayout at-translated-set-2-keyboard next"]; # Use workman by default
    };
  };

  # Fix dolphin "Open with"
  xdg.configFile."menus/applications.menu".source = "${pkgs.libsForQt5.kservice.bin}/etc/xdg/menus/applications.menu";

  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.kfind

    qbittorrent
    kotatogram-desktop
    zapzap
    libreoffice-qt6
  ];
}
