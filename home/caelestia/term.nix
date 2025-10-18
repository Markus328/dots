{lib, ...}: {
  programs.caelestia-dots = {
    hypr.variables.terminal = "footclient";
    foot = {
      settings = {
        main = {
          shell = "zsh";
          pad = "2x2";
        };
        colors = {
          alpha = 0.95;
          background = "000000";
        };
      };
    };
    fish.enable = false;
  };

  programs.foot = {
    enable = true;
    server.enable = true;
  };

  # Caelestia colors for zsh
  programs.zsh.initContent = lib.mkBefore ''
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null
  '';

  programs.hm-ricing-mode.apps = {
    foot.dest_dir = ".config/foot";
  };
}
