{pkgs, ...}: {
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
        rules.settings = {
          windowrule = [
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
        misc.settings.misc = {
          enable_swallow = true;
          swallow_regex = "foot.*";
          swallow_exception_regex = "wev";
        };
      };
    };
  };

  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [hypr-darkwindow hypr-dynamic-cursors];
  };

  programs.hm-ricing-mode.apps = {
    hypr.dest_dir = ".config/hypr";
  };
}
