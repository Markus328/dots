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

        windowGapsOut = 20;
        singleWindowGapsOut = 15;
      };
      hyprland = {
        gestures.enable = false;
        execs.settings.exec-once = ["foot --server"];
        rules.settings = {
          windowrulev2 = [
            # Transparency and blur on all windows.
            "plugin:shadewindow chromakey, fullscreen:0"
            "opacity 0.999, fullscreen:0" # Workaround for https://github.com/micha4w/Hypr-DarkWindow/issues/19

            "float, class:footclient"
            "workspace special:todo, initialTitle: Stories - Obsidian.*"
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
          idle = {
            timeouts = _:
              [
                {
                  timeout = 240;
                  idleAction = "lock";
                }
              ]
              ++ lib.drop 1 _;
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
