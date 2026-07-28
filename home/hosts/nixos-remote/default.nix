{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../dms
  ];

  programs.caelestia-dots.enable = lib.mkForce false;
  home.packages = with pkgs; [
    foot
    firefox
    wlr-randr
  ];

  services.easyeffects.enable = lib.mkForce false; # Not working well with sunshine audio forwarding

  wayland.windowManager.labwc = {
    enable = true;
    systemd.enable = true;
    autostart = [
      "systemctl --user import-environment PATH XDG_DATA_DIRS"
      # "${lib.getExe pkgs.wlr-randr} --output HEADLESS-1 --custom-mode 2160x1220 --scale 1.5"
    ];
    rc = {
      keyboard = {
        keybind = [
          {
            "@key" = "C-A-a";
            action = {
              "@name" = "Execute";
              "@command" = "foot";
            };
          }
        ];
      };
    };
  };

  programs.dank-material-shell = {
    # No need to lock and dpms off causes troubles
    settings = {
      acLockTimeout = lib.mkForce 0;
      acMonitorTimeout = lib.mkForce 0;
    };
  };
}
