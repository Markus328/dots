{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  programs.caelestia-dots.hypr = {
    variables = {
      kbToggleWindowFloating = "Super, Space";
      kbCloseWindow = "Super, W";
      kbTerminal = "Ctrl+Alt, A";
      kbBrowser = "Super, B";
      kbLock = "Ctrl+Alt, L";
      kbRestoreLock = "Ctrl+Alt+Shift, L";
      kbShowPanels = "Super, Backspace";
      kbUngroup = "Super, y";
    };
    hyprland = {
      input.settings.input = _: builtins.removeAttrs _ ["kb_layout"]; # Dont mess with kb_layout
      keybinds.settings = {
        _2launcher = _: {
          bind = ["Super, D, global, caelestia:launcher"];
        };
        bind = {
          __replace = [
            [" up" "K"]
            [" down" "J"]
            [" left" "H"]
            [" right" "L"]
          ];
          __remove = [
            "Super+Alt, E"

            # Disable global bindings to this
            "$kbMusic"
            "$kbCommunication"
            "$kbTodo"
            "$kbSystemMonitor"
          ];

          __append = [
            "Super, Return, focusmonitor, +1"
            "$kbToggleWindowFloating, centerwindow" # Also centers when floating
          ];
        };
        binde.__replace = [
          ["Ctrl+Alt, Tab" "Super, u"]
          ["Ctrl+Shift+Alt, Tab" "Super, i"]
        ];

        marks = {
          _0 = {
            bind = ["Super, M, submap, mark"];
            submap = "mark";
          };
          _1.bind = [
            # "Super, Y, exec, pypr toggle keepass"
            "Super, K, exec, caelestia toggle communication"
            "Super, S, exec, caelestia toggle sysmon"
            "Super, L, exec, caelestia toggle todo"
            # "Super, N, exec, pypr toggle volume"
            # "Super, T, exec, pypr fetch_client_menu"
            # "Super, H, exec, pypr unfetch_client"
            "Super, M , submap, global"
          ];
          _2.submap = "global";
        };
      };
    };
  };
}
