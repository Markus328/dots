{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.niri-flake.homeModules.niri
    ./noctalia.nix
    ./dms.nix
  ];

  programs.dank-material-shell.enable = lib.mkForce false; # Using noctalia
  home.packages = [ pkgs.xwayland-satellite ];
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  xdg.portal = {
    enable = true;
    config.niri = {
      "default" = "gnome;gtk";
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.Access" = "gtk";
      "org.freedesktop.impl.portal.Notification" = "gtk";
      "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
    };
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "workman, br"
                options "ctrl:swapcaps"
            }
            repeat-delay 250
            repeat-rate 35
        }
        touchpad {
            tap
            dwt
            // dwtp
            // drag false
            // drag-lock
            natural-scroll
            accel-speed 0.5
            // accel-profile "flat"
            // scroll-method "two-finger"
            disabled-on-external-mouse
        }

        mouse {
            // natural-scroll
            accel-speed 0.9
            // accel-profile "flat"
            // scroll-method "no-scroll"
        }

        trackpoint {
        }

        focus-follows-mouse max-scroll-amount="60%"
    }

    output "eDP-1" {
            hot-corners {
                // top-left
                top-right
            }
        mode custom=true "1440x810@60"

        transform "normal"

        position x=1440 y=265
    }


    output "HDMI-A-1" {
        position x=0 y=0
    }

    switch-events {
        lid-close { spawn "loginctl" "lock-session"; }
    }

    workspace "communication" {
        open-on-output "eDP-1"
        layout {
            focus-ring {
                active-color "purple"
            }
        }
    }

    layout {
        gaps 16

        center-focused-column "never"
        always-center-single-column
        empty-workspace-above-first
        default-column-display "tabbed"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667

        }


        default-column-width {  }
        focus-ring {
            width 2
            active-color "#7fc8ff"
            inactive-color "#505050"

        }

        border {
            off
            width 4
            active-color "#ffc87f"
            inactive-color "#505050"
            urgent-color "#9b0000"
        }

        shadow {
            off
            softness 30

            // Spread expands the shadow.
            spread 10

            // Offset moves the shadow relative to the window.
            offset x=0 y=10

            // You can also change the shadow color and opacity.
            color "#0007"
        }

        struts {
            // left 64
            // right 64
            // top 16
            // bottom 64
        }
        tab-indicator {
            hide-when-single-tab
        }
    }


    hotkey-overlay {
        skip-at-startup
    }

    prefer-no-csd


    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {

        slowdown 2

        recent-windows-close {
            off
            spring damping-ratio=1.0 stiffness=800 epsilon=0.001
        }
        workspace-switch {
            spring damping-ratio=0.7 stiffness=800 epsilon=0.0001
        }
        overview-open-close {
            duration-ms 200
            curve "cubic-bezier" 0.71 1.27 0.61 1.18
        }
        horizontal-view-movement {
            spring damping-ratio=0.8 stiffness=1200 epsilon=0.001
        }

    }

    window-rule {
        match app-id=r#"ZapZap"#
        open-on-workspace "communication"
    }

    // Block from screencast
    window-rule {
        match app-id=r#"^org\.keepassxc\.KeePassXC$"#

        block-out-from "screencast"
    }

    ${lib.optionalString config.programs.noctalia.enable ''
      window-rule {
        match app-id="dev.noctalia.Noctalia"
        open-floating true
        default-column-width { fixed 1080; }
        default-window-height { fixed 920; }
      }
    ''}


    // Indicate screencasted windows with red colors.
    window-rule {
        match is-window-cast-target=true

        focus-ring {
            active-color "#f38ba8"
            inactive-color "#7d0d2d"
        }

        border {
            inactive-color "#7d0d2d"
        }

        shadow {
            color "#7d0d2d70"
        }

        tab-indicator {
            active-color "#f38ba8"
            inactive-color "#7d0d2d"
        }
    }

    window-rule {
        match app-id=r#"io.github.kotatogram|KotatogramDesktop|io.github.kukuruzka165.materialgram"#
        open-on-workspace "communication"
    }
    window-rule {
        match app-id=r#"vesktop"#
        open-on-workspace "communication"
    }

    ${lib.optionalString config.programs.dank-material-shell.enable ''
      layer-rule {
        match namespace="^dms:blurwallpaper$"
        place-within-backdrop true
      }
    ''}
    ${lib.optionalString config.programs.noctalia.enable ''
      layer-rule {
        match namespace="^noctalia-backdrop"
        place-within-backdrop true
      }
    ''}

    // Big floating windows
    window-rule {
        match app-id=r#".*materialgram$"# title="^Media viewer$"
        match app-id=r#"^org.keepassxc.KeePassXC$"#
        match app-id="org.kde.dolphin"


        open-fullscreen false
        open-floating true
        default-column-width {proportion 0.7;}
        default-window-height {proportion 0.9;}
    }

    // Open the Firefox picture-in-picture player as floating by default.
    window-rule {
        // This app-id regular expression will work for both:
        // - host Firefox (app-id is "firefox")
        // - Flatpak Firefox (app-id is "org.mozilla.firefox")
        match app-id=r#"^zen*"# title="^Picture-in-Picture$"
        open-floating true
        default-column-width {fixed 480;}
        default-window-height {fixed 270;}
        default-floating-position x=10 y=10 relative-to="bottom-right"
    }


    window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        Mod+Ctrl+Space {switch-layout "next"; }

        Mod+Ctrl+L { set-dynamic-cast-window;}
        Mod+Ctrl+K { set-dynamic-cast-monitor;}
        Mod+Ctrl+V { clear-dynamic-cast-target;}

        Ctrl+Alt+A hotkey-overlay-title="Open a Terminal: foot" { spawn "foot"; }

        Super+Alt+S allow-when-locked=true hotkey-overlay-title=null { spawn-sh "pkill orca || exec orca"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

        XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

        Mod+P repeat=false { toggle-overview; }

        Mod+D repeat=false { close-window; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+Y     { focus-column-left; }
        Mod+N     { focus-window-down; }
        Mod+E     { focus-window-up; }
        Mod+O     { focus-column-right; }

        Mod+U {focus-column-last;}
        Mod+F {focus-column-first;}

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Y     { move-column-left; }
        Mod+Shift+N     { move-window-down; }
        Mod+Shift+E     { move-window-up; }
        Mod+Shift+O     { move-column-right; }

        // Alternative commands that move across workspaces when reaching
        // the first or last window in a column.
        // Mod+J     { focus-window-or-workspace-down; }
        // Mod+K     { focus-window-or-workspace-up; }
        // Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
        // Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }
        Mod+Shift+Home { move-column-to-first; }
        Mod+Shift+End  { move-column-to-last; }

        // Mod+Shift+Left  { focus-monitor-left; }
        // Mod+Shift+Down  { focus-monitor-down; }
        // Mod+Shift+Up    { focus-monitor-up; }
        // Mod+Shift+Right { focus-monitor-right; }
        Mod+Return     { focus-monitor-previous; }
        // Mod+Shift+N     { focus-monitor-down; }
        // Mod+Shift+E     { focus-monitor-up; }
        // Mod+Shift+O     { focus-monitor-right; }

        Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
        Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }


        Mod+Alt+N      { focus-workspace-down; }
        Mod+Alt+E        { focus-workspace-up; }
        Mod+Alt+Shift+N { move-column-to-workspace-down; }
        Mod+Alt+Shift+E   { move-column-to-workspace-up; }

        // Mod+Shift+Page_Down { move-workspace-down; }
        // Mod+Shift+Page_Up   { move-workspace-up; }
        Mod+Ctrl+N         { move-workspace-down; }
        Mod+Ctrl+E         { move-workspace-up; }

        Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

        Mod+WheelScrollRight      { focus-column-right; }
        Mod+WheelScrollLeft       { focus-column-left; }
        Mod+Ctrl+WheelScrollRight { move-column-right; }
        Mod+Ctrl+WheelScrollLeft  { move-column-left; }

        Mod+Shift+WheelScrollDown      { focus-column-right; }
        Mod+Shift+WheelScrollUp        { focus-column-left; }
        Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
        Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

        // Mod+TouchpadScrollDown { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+"; }
        // Mod+TouchpadScrollUp   { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-"; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        // Mod+Ctrl+1 { move-window-to-workspace 1; }

        // Mod+Tab { focus-workspace-previous; }

        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }

        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        // Mod+R { switch-preset-column-width-back; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+T { maximize-column; }
        Mod+Shift+T { fullscreen-window; }
        Ctrl+Mod+T {maximize-window-to-edges;}

        Mod+Ctrl+F { expand-column-to-available-width; }

        Mod+C { center-column; }

        // Mod+Ctrl+C { center-visible-columns; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        Mod+Space       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        Mod+W { toggle-column-tabbed-display; }


        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

        Ctrl+Alt+R { quit; }

        Mod+Shift+P { power-off-monitors; }
        Mod+Shift+Ctrl+T { toggle-debug-tint; }
        Mod+Shift+Ctrl+D { debug-toggle-damage; }
        Mod+Shift+Ctrl+O { debug-toggle-opaque-regions; }
    }

    cursor {
        hide-when-typing
    }

    overview {
        zoom 0.4
    }

    debug {
        disable-direct-scanout
        // disable-transactions
        // disable-resize-throttling
        // enable-overlay-planes
        // strict-new-window-focus-policy
        dbus-interfaces-in-non-session-instances
        honor-xdg-activation-with-invalid-serial
        deactivate-unfocused-windows
    }
    include "${./nirimation/roll-drop.kdl}"
    ${lib.optionalString (config.programs.dank-material-shell.enable) "include \"dms/binds.kdl\""}
    ${lib.optionalString (config.programs.noctalia.enable) ''
      include "noctalia-binds.kdl"
      include "noctalia.kdl"
    ''}
  '';

  programs.hm-ricing-mode.apps.niri.dest_dir = ".config/niri";
}
