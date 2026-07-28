{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.noctalia-shell.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      audio = {
        enable_overdrive = true;
        enable_sounds = true;
        sound_volume = 1;
      };
      bar = {
        default = {
          end = [
            "tray"
            "notifications"
            "network"
            "bluetooth"
            "volume"
            "control-center"
            "session"
          ];
          reserve_space = false;
          scale = 1.25;
          smart_auto_hide = true;
          start = [
            "launcher"
            "workspaces"
          ];
          thickness = 40;
        };
      };
      brightness = {
        enable_ddcutil = true;
        minimum_brightness = 0.1;
        sync_all_monitors = true;
      };
      calendar = {
        account = {
          google_account = {
            name = "Calendar";
            type = "google";
          };
        };
        enabled = true;
      };
      control_center = {
        calendar = {
          show_events_card = false;
        };
        hidden_tabs = [ "screen-time" ];
        width = 960;
      };
      dock = {
        active_monitor_only = true;
        auto_hide = true;
        enabled = true;
        icon_size = 36;
        pinned = [ "zen-beta" ];
        reserve_space = false;
        show_dots = true;
        show_instance_count = false;
      };
      idle = {
        behavior = {
          lock = {
            action = "lock";
            enabled = true;
            timeout = 300;
          };
          lock-and-suspend = {
            action = "lock_and_suspend";
            enabled = false;
            timeout = 900;
          };
          screen-off = {
            action = "screen_off";
            enabled = true;
            timeout = 240;
          };
        };
        behavior_order = [
          "screen-off"
          "lock"
          "lock-and-suspend"
        ];
        pre_action_fade_seconds = 5;
      };
      lockscreen_widgets = {
        enabled = false;
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        schema_version = 2;
        widget = {
          "lockscreen-login-box@HDMI-A-1" = {
            box_height = 70;
            box_width = 400;
            cx = 720;
            cy = 781;
            output = "HDMI-A-1";
            rotation = 0;
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12;
              center_password_text = false;
              input_opacity = 1;
              input_radius = 6;
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_password_hint = true;
            };
            type = "login_box";
          };
          "lockscreen-login-box@eDP-1" = {
            box_height = 70;
            box_width = 400;
            cx = 640;
            cy = 601;
            output = "eDP-1";
            rotation = 0;
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12;
              center_password_text = false;
              input_opacity = 1;
              input_radius = 6;
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_password_hint = true;
            };
            type = "login_box";
          };
        };
        widget_order = [
          "lockscreen-login-box@eDP-1"
          "lockscreen-login-box@HDMI-A-1"
        ];
      };
      shell = {
        font_family = "DejaVu Sans";
        launch_apps_as_systemd_services = true;
        launcher = {
          compact = true;
          fetch_exchange_rates = false;
          providers = {
            calculator = {
              global = false;
              prefix = ".";
            };
          };
        };
        niri_overview_type_to_launch_enabled = true;
        panel = {
          launcher_placement = "attached";
        };
        screenshot = {
          confirm_region = true;
        };
      };
      theme = {
        builtin = "Noctalia";
        community_palette = "Oxocarbon";
        source = "wallpaper";
        templates = {
          builtin_ids = [
            "btop"
            "foot"
            "gtk3"
            "gtk4"
            "niri"
            "qt"
          ];
          community_ids = [
            "zen-browser"
            "obsidian"
            "steam"
            "zathura"
          ];
        };
        wallpaper_scheme = "m3-content";
      };
      wallpaper = {
        default = {
          path = "/home/markus/Pictures/Wallpapers/Mihawk.jpeg";
        };
        directory = "/home/markus/Pictures/Wallpapers";
        last = {
          path = "/home/markus/Pictures/Wallpapers/Mihawk.jpeg";
        };
        monitors = {
          HDMI-A-1 = {
            path = "/home/markus/Pictures/Wallpapers/Mihawk.jpeg";
          };
          eDP-1 = {
            path = "/home/markus/Pictures/Wallpapers/Mihawk.jpeg";
          };
        };
      };
      widget = {
        network = {
          capsule = true;
        };
        tray = {
          anchor = true;
          capsule = true;
          drawer = true;
        };
      };
    };
  };

  xdg.configFile."niri/noctalia-binds.kdl".text = ''
    binds {
        // Core Noctalia binds
        Mod+H { spawn-sh "noctalia msg panel-toggle launcher"; }
        Mod+Backspace { spawn-sh "noctalia msg panel-toggle control-center"; }
    }
  '';

  # Force update files that noctalia messes to apply the theme, even if theres no reason.
  xdg.configFile."btop/btop.conf".force = true;
  xdg.configFile."foot/foot.ini".force = true;
}
