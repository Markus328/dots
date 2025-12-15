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
        "eDP-1,1440x810,1440x276, 1" # laptop display
      ];

      xwayland.force_zero_scaling = true; # Fix x11/electron apps in laptop display

      exec-once = ["hyprctl switchxkblayout at-translated-set-2-keyboard next"]; # Use workman by default
    };
  };

  # Fix dolphin "Open with"
  xdg.configFile."menus/applications.menu".source = "${pkgs.libsForQt5.kservice.bin}/etc/xdg/menus/applications.menu";

  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.kfind

    qbittorrent
    materialgram
    zapzap
    libreoffice-qt6
    android-studio
    waydroid-helper
  ];
}
