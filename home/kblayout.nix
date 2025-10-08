{config, ...}: {
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "br, workman";
      kb_options = "grp:ctrls_toggle, ctrl:swapcaps";
      kb_variant = "abnt2,";
    };
  };
  xdg.configFile."xkb/symbols/workman".source = ./xkb/symbols/workman;
  xdg.configFile."xkb/symbols/custom".source = ./xkb/symbols/custom;
}
