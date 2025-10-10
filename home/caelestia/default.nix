{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.caelestia-nix.homeManagerModules.default
    ./keybinds.nix
  ];

  programs.caelestia-dots = {
    enable = true;

    hypr = {
      variables = {
        terminal = "footclient";
        fileExplorer = "dolphin";
        editor = "nvim";
        browser = "firefox";

        blurEnabled = false;
        shadowEnabled = false;
        windowOpacity = 0.999;

        windowGapsOut = 20;
        singleWindowGapsOut = 15;

        cursorTheme = "Bibata-Modern-Ice";
      };
      hyprland = {
        gestures.enable = false;
        execs.settings.exec-once = ["foot --server"];
        rules.settings = {
          windowrulev2 = [
            # Transparency and blur on all windows.
            "plugin:shadewindow chromakey, fullscreen:0"
            "float, class:footclient"
            "workspace special:todo, initialTitle: Stories - Obsidian.*"
            "float, class:org.kde.dolphin"
            "size 70% 70%, class:org.kde.dolphin"
          ];
        };
      };
    };

    caelestia = {
      shell = {
        package = pkgs.caelestia-shell;
        settings = {
          paths = {
            wallpaperDir = "~/Imagens/Wallpapers";
            mediaGif = ../../assets/gif/dancing.gif;
            sessionGif = ../../assets/gif/mihawk.gif;
          };
          general.idle = {
            timeouts = _:
              [
                {
                  timeout = 240;
                  idleAction = "lock";
                }
              ]
              ++ lib.drop 1 _;
          };

          appearance = {
            transparency = {
              enabled = true;
              base = 0.98;
              layers = 1;
            };
            padding.scale = 0.8;
          };

          # Compact bar items
          bar = {
            # Remove logo and power button
            entries = lib.sublist 1 7;

            workspaces.shown = 4;
            clock.showIcon = false;
            tray = {
              compact = true;
              recolour = true;
            };
          };

          lock.recolourLogo = true;

          notifs = {
            actionOnClick = true;
            expire = true;
          };
        };
      };
      cli = {
        package = pkgs.caelestia-cli;

        settings = {
          music = {
            spotify.enable = false;
            feishin.enable = false;
          };
          toggles = {
            todo = {
              "todoist.desktop".enable = false; # Disable todoist
              obisidian = {
                enable = true;
                match = [{class = "obsidian";}];
                command = ["obsidian"];
                move = false;
              };
            };
            communication = {
              telegram = {
                enable = true;
                match = [{class = "io.github.kotatogram";}];
                command = ["kotatogram-desktop"];
              };
              whatsapp = {
                command = ["zapzap"];
                match = _: [{class = "ZapZap";}];
              };

              discord.enable = false;
            };
            sysmon.btop.command = _: lib.take 5 _ ++ ["${pkgs.btop}/bin/btop"]; # run btop directly instead of starting shell
          };
        };
      };
    };
  };

  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [hypr-darkwindow hypr-dynamic-cursors];
  };
  programs.hm-ricing-mode.apps = {
    hypr.dest_dir = ".config/hypr";
    caelestia.dest_dir = ".config/caelestia";
  };
}
