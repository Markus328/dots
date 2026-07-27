{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.syncthing.enable = true;
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "desc:XXW HDMI,1440x900,0x0,1"
        "eDP-1,1440x810,1440x276, 1" # laptop display
      ];

      xwayland.force_zero_scaling = true; # Fix x11/electron apps in laptop display

      exec-once = [ "hyprctl switchxkblayout at-translated-set-2-keyboard next" ]; # Use workman by default
    };
  };

  # Fix dolphin "Open with"
  xdg.configFile."menus/applications.menu".source =
    "${pkgs.kdePackages.kservice}/etc/xdg/menus/applications.menu";

  xdg.configFile."sunshine/apps.json".text =
    let
      wlr-randr = lib.getExe pkgs.wlr-randr;
      jq = lib.getExe pkgs.jq;

      fix-abs-input-do =
        focus_output:
        pkgs.writeShellScript "fix-abs-input-do-sunshine" ''
          mkdir -p /tmp/sunshine-fix-abs-input/

          mapfile -t uneeded_outputs < <(${wlr-randr} --json | ${jq} '.[] | select(.enabled and .name != "${focus_output}") | .name' -r)
          for o in "''${uneeded_outputs[@]}"; do
            ${wlr-randr} --output "$o" --off
          done
          echo "''${uneeded_outputs[@]}" > /tmp/sunshine-fix-abs-input/last_active_outputs

          preferredPos="$(${wlr-randr} --json | ${jq} '.[] | select(.name == "${focus_output}").position | "\(.x),\(.y)"' -r)"
          echo "$preferredPos" > /tmp/sunshine-fix-abs-input/last_focus_pos

          ${wlr-randr} --output ${focus_output} --pos 0,0
        '';
      fix-abs-input-undo =
        focus_output:
        pkgs.writeShellScript "fix-abs-input-undo-sunshine" ''
          preferredPos="$(cat /tmp/sunshine-fix-abs-input/last_focus_pos)"
          ${wlr-randr} --output ${focus_output} --pos "$preferredPos"

          read -a last_active_outputs < <(cat /tmp/sunshine-fix-abs-input/last_active_outputs)
          for o in "''${last_active_outputs[@]}"; do
            ${wlr-randr} --output "$o" --on
          done

          rm -rf /tmp/sunshine-fix-abs-input/
        '';

      touch-gestures-do = pkgs.writeShellScript "lisgd-gestures-do" ''
        ${lib.getExe pkgs.ligsd} \                                                       ⌂ 22:51
          -d /dev/input/event19 \
          -r 25 \
          -g '1,DLUR,BL,*,R,niri msg action toggle-overview' \
          -g '3,LR,N,L,R,niri msg action focus-column-first' \
          -g '3,LR,N,S,R,niri msg action focus-column-left' \
          -g '3,RL,N,L,R,niri msg action focus-column-last' \
          -g '3,RL,N,S,R,niri msg action focus-column-right'    
      '';

    in
    builtins.toJSON {
      apps = [
        {
          image-path = "desktop.png";
          name = "Desktop (private)";
          prep-cmd = [
            { do = "niri msg output Virtual-1 on"; }
            {
              do = fix-abs-input-do "Virtual-1";
              undo = fix-abs-input-undo "Virtual-1";
            }
            # {
            #   do = "niri msg output HDMI-A-1 off";
            #   undo = "niri msg output HDMI-A-1 on";
            # }
            # {
            #   do = "niri msg output eDP-1 off";
            #   undo = "niri msg output eDP-1 on";
            # }
            { undo = "sh -c \"niri msg output Virtual-1 off && sleep 2\""; }
            {
              do = "sh -c \"wlr-randr --output Virtual-1 --custom-mode \${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@60 --scale 1.25\"";
            }
            {
              do = "dms ipc inhibit enable";
              undo = "dms ipc inhibit disable";
            }
            { undo = "dms ipc lock lock"; }
          ];
        }
        {
          image-path = "desktop.png";
          name = "Desktop (extra monitor)";
          prep-cmd = [
            {
              do = "niri msg output Virtual-1 on";
              undo = "niri msg output Virtual-1 off";
            }
            {
              do = "sh -c \"wlr-randr --output Virtual-1 --custom-mode \${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@60 --scale 1.25\"";
            }
          ];
        }
        {
          image-path = "desktop.png";
          name = "Games";
          prep-cmd = [
            {
              do = fix-abs-input-do "eDP-1";
              undo = fix-abs-input-undo "eDP-1";
            }
            {
              do = "sh -c \"wlr-randr --output eDP-1 --custom-mode \${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@60 --scale 1.25\"";
              undo = "sh -c \"wlr-randr --output eDP-1 --custom-mode 1440x810@60 --scale 1\"";
            }
            {
              do = "dms ipc inhibit enable";
              undo = "dms ipc inhibit disable";
            }
            { undo = "dms ipc lock"; }
          ];
        }
        {
          image-path = "desktop.png";
          name = "test";
        }
      ];
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
      };
    };

  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.kfind

    qbittorrent
    materialgram
    zapzap
    libreoffice-qt6
    android-studio
    waydroid-helper
    vesktop
  ];

  home.activation.monitor-setup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe pkgs.wlr-randr} --output HDMI-A-1 --pos 0,0 || true
    ${lib.getExe pkgs.wlr-randr} --output eDP-1 --pos 1440,265 || true
  '';

  specialisation = {
    gaming.configuration = {
      services.syncthing.enable = lib.mkForce false;
      services.kdeconnect.enable = lib.mkForce false;

      home.activation.monitor-setup = lib.mkForce (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${lib.getExe pkgs.wlr-randr} --output HDMI-A-1 --pos 0,0 || true
          ${lib.getExe pkgs.wlr-randr} --output eDP-1 --pos 2000,265 || true # place it far to avoid cursor lose focus of game
        ''
      );
    };
  };
}
