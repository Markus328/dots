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

    editor.enable = false;
    caelestia = {
      enable = config.programs.caelestia-dots.hypr._meta.active; # do not work outside hyprland in pratique
      shell = {
        package = pkgs.caelestia-shell;
        settings = {
          paths = {
            wallpaperDir = "~/Pictures/Wallpapers";
            mediaGif = ../../assets/gif/dancing.gif;
            sessionGif = ../../assets/gif/mihawk.gif;
          };

          launcher.actions.__infuse = [
            {
              # Append new actions
              __append = [
                {
                  name = "Annotator";
                  icon = "brush";
                  dangerous = false;
                  description = "Draw, write, annotate stuff on the screen";
                  command = ["${pkgs.distrobox}/bin/distrobox" "enter" "apps" "--" "wayscriber" "--active"];
                }
              ];
            }
            # Choose which actions to show, in order
            (actions:
              map (name:
                lib.findFirst (action: action.name == name) {
                  inherit name;
                  description = "Not found";
                }
                actions) [
                "Calculator"
                "Annotator"
                "Wallpaper"
                "Lock"
                "Sleep"
              ])
          ];
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
            smartScheme = false;
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
                match = [{class = "io.github.kukuruzka165.materialgram";}];
                command = ["materialgram"];
              };
              whatsapp = {
                command = ["zapzap"];
                match = _: [{class = "ZapZap";}];
              };

              discord.enable = false;
            };
            sysmon.btop.command = _: lib.take 5 _ ++ ["zsh" "-c" "btop"];
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

  systemd.user = lib.mkIf config.programs.caelestia-dots.caelestia.cli._meta.active {
    timers."caelestia-wallpaper" = {
      Unit = {
        Description = "Hourly timer for caelestia-wallpaper";
      };
      Timer = {
        OnCalendar = "hourly";
      };
      Install = {
        WantedBy = ["timers.target"];
      };
    };
    services."caelestia-wallpaper" = {
      Unit = {
        Description = "Ramdomize Caelestia wallpaper every hour";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.caelestia-cli}/bin/caelestia wallpaper -r -N";
      };
      Install = {
        WantedBy = ["caelestia.service"];
      };
    };
  };

  programs.hm-ricing-mode.apps = lib.mkIf config.programs.caelestia-dots.caelestia._meta.active {
    caelestia.dest_dir = ".config/caelestia";
  };
}
