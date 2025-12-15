{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.programs.caelestia-dots.hypr._meta.active {
    programs.caelestia-dots = {
      hypr = {
        variables = {
          fileExplorer = "dolphin";
          editor = "nvim";
          browser = "firefox";

          volumeStep = 20;

          blurEnabled = false;
          shadowEnabled = false;
          windowOpacity = 0.999;

          windowGapsOut = 20;
          singleWindowGapsOut = 15;

          cursorTheme = "Bibata-Modern-Ice";
        };
        hyprland = {
          gestures.enable = false;
          env.settings.env = ["APP2UNIT_SLICES, a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice"];
          animations.settings.animations.animation.__replace = [["specialWorkspace, 1, 4" "specialWorkspace, 1, 7"] ["slidefadevert 15%" "slide bottom 110%"]];
          rules.settings = {
            windowrule = {
              __replace = [
                ["blueman-manager" ".blueman-manager-wrapped"]
              ];
              __append = [
                # Transparency and blur on all windows.
                "plugin:shadewindow chromakey, fullscreen:0"
                "float, class:footclient"
                "workspace special:todo, initialTitle: Stories - Obsidian.*"
                "float, class:org.kde.dolphin"
                "size 70% 70%, class:org.kde.dolphin"
                "float, class:org.keepassxc.KeePassXC"
                "workspace special:password, class:org.keepassxc.KeePassXC"
              ];
            };
          };
          misc.settings = {
            misc = {
              enable_swallow = true;
              swallow_regex = "foot.*";
              swallow_exception_regex = "wev";
            };
            render = {
              send_content_type = false;
            };
          };
        };
      };
    };

    home.pointerCursor.package = pkgs.bibata-cursors;

    wayland.windowManager.hyprland = {
      plugins = with pkgs.hyprlandPlugins; [hypr-darkwindow hypr-dynamic-cursors];
    };

    systemd.user = {
      enable = true;
      slices = {
        "app-graphical" = {
          Unit = {
            description = "Graphical Applications Slice";
            wantedBy = ["multi-user.target"];
          };
          Slice = {
            CPUWeight = 100;
            # Add other limits as needed, e.g.:
            MemoryHigh = "6G";
            CPUQuota = "700%";
          };
        };
        "session" = {
          Unit = {
            description = "Session slice";
            wantedBy = ["multi-user.target"];
          };
          Slice = {
            CPUWeight = 500;
          };
        };
      };
    };

    programs.hm-ricing-mode.apps = {
      hypr.dest_dir = ".config/hypr";
    };
  };
}
