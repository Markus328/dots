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
    ./hypr.nix
    ./term.nix
  ];

  programs.caelestia-dots = {
    enable = true;

    caelestia = {
      shell = {
        package = pkgs.caelestia-shell;
        settings = {
          paths = {
            wallpaperDir = "~/Pictures/Wallpapers";
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
          services = {
            maxVolume = 1.5;
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
            password = {
              keepass = {
                enable = true;
                match = [{class = "org.keepassxc.KeePassXC";}];
                move = true;
                command = ["keepassxc"];
              };
            };
          };
        };
      };
    };
  };

  programs.hm-ricing-mode.apps = {
    caelestia.dest_dir = ".config/caelestia";
  };
}
